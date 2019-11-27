public with sharing class RuleCriterionMatcher {

	public static String nameSpace = CadenceConstants.NAMESPACE;
	public static List<SObject> participantsList;
	public static String objName;

	public static void assignCadenceToParticipants(Cadence__c cad) {

		String objName = cad.Record_Type__c; 

	} 

	public static Cadence__c assignCadenceToNotAssignedParticipant(Map<Id, Cadence__c> cadenceMap, SObject partObj, SObject parentObj, String objName) {
		List<Cadence__c> matchingCadences = new List<Cadence__c>(); 
		Cadence__c cadToUpdate;
		Map<Id, CriterionSet> cadCriterion = New Map<Id, CriterionSet>();
		Map<Id, CriterionSet> cadExitCriterion = New Map<Id, CriterionSet>();

		if (cadenceMap != null){
			cadCriterion = RuleCriterionMatcherHelper.getCadenceWiseCriterions(cadenceMap.values(), CadenceConstants.CRITERION_TYPE_ENTRY);
			cadExitCriterion = RuleCriterionMatcherHelper.getCadenceWiseCriterions(cadenceMap.values(), CadenceConstants.CRITERION_TYPE_EXIT);
		}

		//Getting matching cadences	
		for(Id cadId : cadCriterion.keySet()) {
			Boolean isExitCriterionMatches = RuleCriterionMatcherHelper.cadenceCriterionMatches(partObj, parentObj, cadExitCriterion.get(cadId), null);
			if(isExitCriterionMatches) {
				continue;
			}
			Boolean isCriterionMatches = RuleCriterionMatcherHelper.cadenceCriterionMatches(partObj, parentObj, cadCriterion.get(cadId), null);
			if(isCriterionMatches) {
				matchingCadences.add(cadenceMap.get(cadId));
			} 
		}

		//Return if no matching cadence found 
		if(matchingCadences.isEmpty()) {
			return null;
		}

		//Setting matched cadence
		if(matchingCadences.size() == 1) {
			cadToUpdate = matchingCadences.get(0);
		} else {
			cadToUpdate = RuleCriterionMatcherHelper.getPriorityCadence(matchingCadences);
		}

		partObj.put(nameSpace+'Cadence_Id__c', cadToUpdate.Id); 

		if(!objName.equalsIgnoreCase(CadenceConstants.OPPORTUNITY_OBJECT_NAME)){
			//Setting matching cadence data to participant
			if(cadToUpdate.Participent_Activation__c.equalsIgnoreCase(CadenceConstants.PARTICIPANT_ACTIVATION_AUTOMATIC)) {
				partObj.put(nameSpace+'isActivated__c', true);
				partObj.put(nameSpace+'EntranceCriteria_Matched_Date__c', System.now());
			} else {
				partObj.put(nameSpace+'isActivated__c', false);
			}
		}
		return cadToUpdate;  
	}

	public static SObject matchExitCriterion(Cadence__c cad, SObject partObj, SObject parentObj, String objName) {
		//Returning if given cad is null
		if(cad == null) {
			return null;
		}
		//Getting cadence criterion for cadence		
		Map<Id, CriterionSet> cadCriterion = RuleCriterionMatcherHelper.getCadenceWiseCriterions(new List<Cadence__c>{cad}, CadenceConstants.CRITERION_TYPE_EXIT);

		//Checking for exit Cadence Criterion mathcing or not 
		Boolean isCriterionMatches = RuleCriterionMatcherHelper.cadenceCriterionMatches(partObj, parentObj, cadCriterion.get(cad.Id), null);

		//Removing cadence details from participnat if it matches it's exit criterion 
		if(isCriterionMatches) {
			/*partObj.put(nameSpace+'Cadence_Id__c', null);
			partObj.put(nameSpace+'isActivated__c', false);
			partObj.put(nameSpace+'EntranceCriteria_Matched_Date__c', null);
			if(objName == CadenceConstants.CONTACT_OBJECT_NAME){
				partObj.put(nameSpace+'Opportunity_Id__c', null);
			}*/
			return partObj;
		} 
		return null;
	}
	public static Boolean matchExitCriterionOpp(Cadence__c cad, SObject partObj, SObject parentObj, String objName) {

		//Returning if given cad is null
		if(cad == null) {
			return false;
		} 
		//Getting cadence criterion for cadence		
		Map<Id, CriterionSet> cadCriterion = RuleCriterionMatcherHelper.getCadenceWiseCriterions(new List<Cadence__c>{cad}, CadenceConstants.CRITERION_TYPE_EXIT);
		Boolean isCriterionMatches = RuleCriterionMatcherHelper.cadenceCriterionMatches(partObj, parentObj, cadCriterion.get(cad.Id), null);
		return isCriterionMatches;
	}

	public static List<CadenceAction__c> getMatchingActions(Cadence__c cad, SObject obj, SObject parentObj, String objName, List<Sequence_Action__c> partActions) {

		List<CadenceAction__c> allCadActions = cad.CadenceActions__r;
		List<CadenceAction__c> actionsToPerform = new List<CadenceAction__c>();
		Map<Id, CadenceAction__c> cadActionsMap = new Map<Id, CadenceAction__c>();
		Map<Id, Sequence_Action__c> partActionsMap = new Map<Id, Sequence_Action__c>();

		//Getting action on participants map to cadenceAction
		if(partActions != null && !partActions.isEmpty()) {
			for(Sequence_Action__c partAct : partActions) {
				partActionsMap.put(partAct.CadenceAction_Id__c, partAct);
			}
			for(CadenceAction__c cadAct : allCadActions) {
				if(partActionsMap.containsKey(cadAct.Id)) {
					cadActionsMap.put(cadAct.Id, cadAct);
				}
			}
		} else {
			cadActionsMap = new Map<Id, CadenceAction__c>(allCadActions);
		}

		//Getting the time difference from matched cadence date to today 
		Map<String, String> timeDiffMap = CadenceUtil.getTimeDiff(System.now(), (DateTime)obj.get(nameSpace+'EntranceCriteria_Matched_Date__c'));  
		Integer day = Integer.valueOf(timeDiffMap.get('day'));
		Integer hour = Integer.valueOf(timeDiffMap.get('hour'));

		//Getting actions criterion
		Map<Id, CriterionSet> cadActionCriterion = RuleCriterionMatcherHelper.getActionWiseCriterions(cadActionsMap.values());		

		//Chekcing the criterion to match the criterion
		for(Id cadActId : cadActionCriterion.keySet()) {
			CadenceAction__c cadAct = cadActionsMap.get(cadActId);
			if(cadAct == null) {
				continue;
			}
			if(day==0 && hour ==0) {
				if(cadAct.Trigger_Type__c.equals(CadenceConstants.CADENCE_ACTION_TRIGGER_TYPE_IMMEDIATE)) {
					if(cadActionCriterion.get(cadAct.Id) != null) {
						Boolean isCriterionMatches = RuleCriterionMatcherHelper.cadenceCriterionMatches(obj, parentObj, cadActionCriterion.get(cadActId), null);
						if(isCriterionMatches) {
							actionsToPerform.add(cadAct);
						}
					} else {
						actionsToPerform.add(cadAct);
					}
				}				
			} else {
				if(cadAct.Day__c == day && cadAct.Hour__c == hour) {
					if(cadAct.Trigger_Type__c.equals(CadenceConstants.CADENCE_ACTION_TRIGGER_TYPE_TIME_BASED)) {
						if(cadActionCriterion.get(cadAct.Id) != null) {
							Boolean isCriterionMatches = RuleCriterionMatcherHelper.cadenceCriterionMatches(obj, parentObj, cadActionCriterion.get(cadActId), null);
							if(isCriterionMatches) {
								actionsToPerform.add(cadAct);
							}	
						} else {
							actionsToPerform.add(cadAct);
						}
					}
				}
			}		
		}
		return actionsToPerform;
	}


	public static String getPostFixExpression(String criterionFormula) {
		String postFixExp = '';
		List<String> formattedExpression = CadenceUtil.getFormattedExpressoion(criterionFormula);
		List<String> postFixExpression = CadenceUtil.infixToPostfixConversion(formattedExpression);
		postFixExp = System.JSON.serialize(postFixExpression);
		return postFixExp; 
	}


	public static List<Sequence_Action__c> getMatchingParticipantActions(Cadence__c cad, SObject obj, SObject parentObj, List<Sequence_Action__c> partActions, String objName) {

		//Returning if no action to be performed
		List<Sequence_Action__c> actionsToPerform = new List<Sequence_Action__c>();
		if(partActions == null || partActions.isEmpty() || cad == null || cad.CadenceActions__r == null) {
			return actionsToPerform;
		}
		Map<Id, CadenceAction__c> allCadActionMap = new Map<Id, CadenceAction__c>(cad.CadenceActions__r);
		List<CadenceAction__c> remainingCadActions = new List<CadenceAction__c>();

		//Getting cad actions which are un performed
		for(Sequence_Action__c partAct : partActions) {
			remainingCadActions.add(allCadActionMap.get(partAct.CadenceAction_Id__c));
		}

		//Getting actions criterion
		Map<Id, CriterionSet> cadActionCriterion = RuleCriterionMatcherHelper.getActionWiseCriterions(remainingCadActions);
       
		//Getting matching criterions 
		for(Sequence_Action__c partAct : partActions) {
			if(partAct == null || partAct.CadenceAction_Id__r.Trigger_Type__c == null) {
				continue;
			}
			if(partAct.Expected_Execution_Date__c <= System.now()) {
				if(cadActionCriterion.get(partAct.CadenceAction_Id__c) != null) { 
					Boolean isCriterionMatches = RuleCriterionMatcherHelper.cadenceCriterionMatches(obj, parentObj, cadActionCriterion.get(partAct.CadenceAction_Id__c), null);
					System.debug('AdditionalCriteria: isCriterionMatches:' + isCriterionMatches);
					if(isCriterionMatches) {
						actionsToPerform.add(partAct);
					}
				} else {
					actionsToPerform.add(partAct);
				}
			}
		}
		return actionsToPerform;
	}
}