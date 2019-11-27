public with sharing class CadenceController {
	public static String nameSpace = CadenceConstants.NAMESPACE;
	public static Set<Id>  listOfOppContactIds;
	private static string contactRole ='';

	@AuraEnabled
	public static cadenceDataWrapper getCadenceData(Id cadenceId){
		cadenceDataWrapper adWObj = new cadenceDataWrapper();
		Cadence__c cObj  = CadenceController.getCadenceDetail(cadenceId);
		adWObj.cObj  = cObj;
		Sequence sequence  = new Sequence(cObj.Id, cObj.Entrance_Criteria__c, '', cObj.Exit_Criteria__c, 
				'', cObj.matching_priority__c, cObj.Name, cObj.Participent_Activation__c,
				cObj.Record_Type__c, string.valueOf(cObj.Status__c), string.valueOf(cObj.Total_Participants__c));

		adWObj.fieldList = getFields(adWObj.cObj.Record_Type__c);
		List<CadenceAction__c> listCadenceAction = cObj.CadenceActions__r;
		List<SequenceAction> sequenceActionList = new List<SequenceAction>();

		for (CadenceAction__c cadenceAction : listCadenceAction){
			SequenceAction sequenceAction = new SequenceAction (cadenceAction.Id, cadenceAction.Action_Criterion__c, 
					null, string.valueOf(cadenceAction.Action_Id__c), 
					string.valueOf(cadenceAction.Day__c), 
					cadenceAction.Fields_To_Update_Action__c, 
					string.valueOf(cadenceAction.Hour__c), null, 
					cadenceAction.Name, cadenceAction.Priority__c,
					null, string.valueOf(cadenceAction.Cadence_Id__c), 
					cadenceAction.Trigger_Type__c);
			sequenceAction.actiontemplateId = cadenceAction.Action_Id__r.Template_Id__c;
			sequenceAction.actiontype = cadenceAction.Action_Id__r.Type__c;
			sequenceActionList.add(sequenceAction);
		}
		sequence.cadenceActions =sequenceActionList;
		adWObj.sObj  = sequence;
		return adWObj;
	}
	@AuraEnabled
	public static cadenceDataWrapper getObjCriList(String objectType){
		cadenceDataWrapper adWObj = new cadenceDataWrapper();
		adWObj.fieldList = getFields(objectType);
		return adWObj;
	}

	public class cadenceDataWrapper{
		@AuraEnabled public Cadence__c cObj;
		@AuraEnabled public Sequence sObj;
		@AuraEnabled public List<CriterionWrapper> fieldList = New List<CriterionWrapper>{New CriterionWrapper()};
	}
	@AuraEnabled
	public static Cadence__c getCadenceDetail(Id cadenceId){
		List<Cadence__c> cadence = [Select Id, Name, Entrance_Criteria__c, Exit_Criteria__c, 
		                            Participent_Activation__c, Record_Type__c, Matching_Priority__c ,
		                            Status__c, Total_Participants__c,
		                            (
		                            		Select id, name , Cadence_Id__c, Action_Id__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c, Fields_To_Update_Action__c, Hour__c, Day__c, Trigger_Type__c, Action_Criterion__c, Priority__c from 
		                            		CadenceActions__r order by Index__c
		                            		)
		                            from Cadence__c where Id=: cadenceId];
		return cadence[0];								
	}

	@AuraEnabled
	public static List<CriterionWrapper> getFields(String objectStr){
		List<String> objectList = getObjectListByType(objectStr);
		List<CriterionWrapper> criterions = CadenceService.getFieldsWithLabels(objectList);
		return criterions;
	}
	@AuraEnabled
	public static List<CriterionWrapper> getFieldsForSA(String objectStr){
		List<String> objectList = new List<String>(); 
		if(objectStr == CadenceConstants.OPPORTUNITY_OBJECT_NAME){
			objectList =new List<String>{CadenceConstants.OPPORTUNITY_OBJECT_NAME};
		} else if(objectStr == CadenceConstants.LEAD_OBJECT_NAME ){
			objectList =new List<String>{CadenceConstants.LEAD_OBJECT_NAME};
		} else if(objectStr == CadenceConstants.CONTACT_OBJECT_NAME ){
			objectList =new List<String>{CadenceConstants.CONTACT_OBJECT_NAME };
		}
		List<CriterionWrapper> criterions = CadenceService.getFieldsWithLabelsForUpdate(objectList);
		return criterions;
	}
	
	//Deprecated in new architecture - activateSequences
	@AuraEnabled
	public static void activateCadence(Id cadId) {
		Cadence__c cad = new Cadence__c(Id=cadId, Status__c=true);
		upsert cad;
		updateParticipants(cadId); 
		CadenceService.setParticipantsActivation(cadId, true);
	}
	
	@AuraEnabled
	public static void activateSequences(List<Id> sequenceIdList) {
		SequenceEngineService.activateSequences(sequenceIdList); 
	} 
	
	@AuraEnabled
	public static void updateParticipants(Id cadId) {
		Cadence__c cadence = CadenceSelector.getCadenceById(cadId);
		Map<Id, List<CadenceAction__c>> objIdToAllCadActListMap = new Map<Id, List<CadenceAction__c>>();
		String objName = cadence.Record_Type__c;
		String query2;

		if(!objName.equalsIgnoreCase(CadenceConstants.OPPORTUNITY_OBJECT_NAME))
			query2 = formQuery2(objName,cadence);
		else{
			query2 = formQueryOpportunity(objName,cadence);
		}

		List<SObject> sObjectListToUpdate = new List<SObject>();
		if(query2 != null && query2 != ''){
			for(Sobject obj : Database.query(RemoveBraces(query2) + ' order by lastmodifieddate limit 100')){
				obj.put(nameSpace+'Cadence_Id__c', cadence.Id);
				if(cadence.Participent_Activation__c.equalsIgnoreCase(CadenceConstants.PARTICIPANT_ACTIVATION_AUTOMATIC)) {
					obj.put(nameSpace+'isActivated__c', true);
					obj.put(nameSpace+'EntranceCriteria_Matched_Date__c', System.now());
					objIdToAllCadActListMap.put((Id)obj.get('Id'), cadence.CadenceActions__r);
				} else {
					obj.put(nameSpace+'isActivated__c', false);
					obj.put(nameSpace+'EntranceCriteria_Matched_Date__c', System.now());
				}
				sObjectListToUpdate.add(obj);
			}
			if(!objIdToAllCadActListMap.isEmpty()) {
				List<Sequence_Action__c> testcreateActionParticipants =CadenceService.createActionParticipants(objIdToAllCadActListMap, new Map<Id, SObject>(sObjectListToUpdate), objName);
			}
			if(sObjectListToUpdate !=  null && sObjectListToUpdate.size() > 0) {
				Database.SaveResult[] results = Database.update(sObjectListToUpdate, false);
				Set<Id> resultIds = (new Map<Id,SObject>(sObjectListToUpdate)).keySet();
				for(Database.saveResult r: results){
					if(r.isSuccess()){
						resultIds.remove(r.getId());
					}
				}
				CadenceSelector.DeleteParticipantAction(resultIds);
			}
		}      
	}   
	@AuraEnabled
	public static void deactivateCadence(Id cadId) {
		Cadence__c cad = new Cadence__c(Id=cadId, Status__c=false);
		upsert cad;
		CadenceService.setParticipantsActivation(cadId, false);
	}   
	public Static String formQuery2(String objName,Cadence__c cadence){
		String query = 'Select Cadence_ID__c,isActivated__c,EntranceCriteria_Matched_Date__c from '+ objName +' Where (Cadence_ID__c = null) AND ';
		Set<String> allowedFields = new Set<String>();
		Map<Id, CriterionSet> mapofCadenceWiseEntryCriterions =  new Map<Id, CriterionSet>();
		Map<Id, CriterionSet> mapofCadenceWiseExitCriterions =  new Map<Id, CriterionSet>();
		Map<Id, CriterionSet> mapofCadenceActionCriterions =  new Map<Id, CriterionSet>();
		list<Cadence__c> listOfcadence =  new List<Cadence__c>();
		if(cadence != null){
			listOfcadence.add(cadence);
			mapofCadenceWiseEntryCriterions = RuleCriterionMatcherHelper.getCadenceWiseCriterions(listOfcadence,CadenceConstants.CRITERION_TYPE_ENTRY);
			mapofCadenceWiseExitCriterions = RuleCriterionMatcherHelper.getCadenceWiseCriterions(listOfcadence,CadenceConstants.CRITERION_TYPE_EXIT);

			if(cadence.CadenceActions__r != null && cadence.CadenceActions__r.size() >0)
				mapofCadenceActionCriterions = RuleCriterionMatcherHelper.getActionWiseCriterions(cadence.CadenceActions__r);	

			// Filter condition for entry criteria 
			if(mapofCadenceWiseEntryCriterions.keyset().size() > 0)
				query = query+ '(('+criteriaFilters(mapofCadenceWiseEntryCriterions,cadence,true)+')';

			// Filter condition for exit criteria  
			if(mapofCadenceWiseExitCriterions.keyset().size() > 0)
				query = query+ +' AND (NOT('+criteriaFilters(mapofCadenceWiseExitCriterions,cadence,false) +')))';

		}
		return query;
	}

	public static String criteriaFilters( Map<Id, CriterionSet> mapofCadenceWiseEntryCriterions,Cadence__c cadence,Boolean isEntry){
		DateTimeCriterionEvaluator dt = new DateTimeCriterionEvaluator();
		string query ='';
		if(mapofCadenceWiseEntryCriterions.keySet().size() > 0){
			if(mapofCadenceWiseEntryCriterions.containskey(cadence.id) && mapofCadenceWiseEntryCriterions.get(cadence.id).criterions != null){
				if(mapofCadenceWiseEntryCriterions.get(cadence.id).condition != null ){
					map<integer,Criterion> mapofCriterion = new map<integer,Criterion>();
					mapofCriterion = mapofCadenceWiseEntryCriterions.get(cadence.id).criterions;
					integer listcount=0;
					String conditionforAll='';
					if(mapofCadenceWiseEntryCriterions.get(cadence.id).condition.contains('conditions are met'))
						conditionforAll = mapofCadenceWiseEntryCriterions.get(cadence.id).condition.contains('AND') ? ' AND':(mapofCadenceWiseEntryCriterions.get(cadence.id).condition.contains('OR')?' OR':'');  
					else
						conditionforAll =mapofCadenceWiseEntryCriterions.get(cadence.id).condition;

					List<Integer> listOfMapKey =new List<Integer>();
					listOfMapKey.addAll(mapofCriterion.keyset());
					listOfMapKey.sort();
					for( Integer num : listOfMapKey){
						if(mapofCadenceWiseEntryCriterions.get(cadence.id).condition.containsIgnoreCase('Custom logic') && num ==1 && mapofCadenceWiseEntryCriterions.get(cadence.id).criterionPriorityFormula.startswith('('))
							query = query +'(';
						if(mapofCriterion.get(num).fieldDataType == 'phone') {
							query += '(';
						}
						if(mapofCriterion.get(num).fieldName.equalsIgnoreCase('OpportunityContactRole.Role') && cadence != null && cadence.Record_Type__c.equalsIgnoreCase(CadenceConstants.OPPORTUNITY_OBJECT_NAME)){
							if(query.endsWithIgnoreCase(' AND '))
								query = query.removeEndIgnoreCase(' AND ');
							else if(query.endsWithIgnoreCase(' OR '))
								query = query.removeEndIgnoreCase(' OR ');
							if(isEntry)
								contactRole = mapofCriterion.get(num).value;
						}else{
							query = query + mapofCriterion.get(num).fieldName;
							if(mapofCriterion.get(num).operation == 'contains'){
								if(mapofCriterion.get(num).fieldDataType =='picklist' )
									query =query+' LIKE  \'%' +mapofCriterion.get(num).value + '%\'';
								else if (mapofCriterion.get(num).fieldDataType =='multipicklist')
									query =query+' INCLUDES ( \''+mapofCriterion.get(num).value+ '\' )';
								else
									query =query+' LIKE  \'%' +mapofCriterion.get(num).value + '%\'';
							} 
							else if(mapofCriterion.get(num).operation =='not_equals'){
								if(mapofCriterion.get(num).fieldDataType =='Number')
									query =query+' !='+  decimal.valueOf(mapofCriterion.get(num).value);
								else if(mapofCriterion.get(num).fieldDataType =='Boolean')
									query =query+' !='+  mapofCriterion.get(num).value; 
								else if(mapofCriterion.get(num).fieldDataType =='phone') {
									String phoneNo = (String)mapofCriterion.get(num).value;
									query += ' !=\''+  phoneNo +'\''+ ' OR '+ mapofCriterion.get(num).fieldName;
									phoneNo = phoneNo.trim();
									query += ' !=\''+  '('+ phoneNo.substring(0, 3) + ')'+ ' '+ phoneNo.substring(3, 6) + '-' + phoneNo.substring(6) +'\''+ ')';
								} else if(mapofCriterion.get(num).fieldDataType =='Date') {
									query =query+' !='+  getDateFormat(Date.valueOf((String)mapofCriterion.get(num).value));
								} else if(mapofCriterion.get(num).fieldDataType =='DateTime') {
									query =query+' !='+  dt.getDateTime(mapofCriterion.get(num).value).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
								}else if(mapofCriterion.get(num).fieldDataType == CadenceConstants.MultiPickList )
                                	query =query+' EXCLUDES (  \'' + mapofCriterion.get(num).value + '\')';   
								else 
									query =query+' !=\''+  mapofCriterion.get(num).value +'\''; 
							}
							else if(mapofCriterion.get(num).operation =='equals'){
								if(mapofCriterion.get(num).fieldDataType =='Number')
									query =query+' ='+  decimal.valueOf(mapofCriterion.get(num).value);
								else if(mapofCriterion.get(num).fieldDataType =='Boolean')
									query =query+' ='+  mapofCriterion.get(num).value; 
								else if(mapofCriterion.get(num).fieldDataType =='phone') {
									String phoneNo = (String)mapofCriterion.get(num).value;
									query += ' =\''+  phoneNo +'\''+ ' OR '+ mapofCriterion.get(num).fieldName;
									phoneNo = phoneNo.trim();
									query += ' =\''+  '('+ phoneNo.substring(0, 3) + ')'+ ' '+ phoneNo.substring(3, 6) + '-' + phoneNo.substring(6) +'\''+ ')';
								} else if(mapofCriterion.get(num).fieldDataType =='Date') {
									query =query+' ='+ getDateFormat(Date.valueOf((String)mapofCriterion.get(num).value));
								} else if(mapofCriterion.get(num).fieldDataType =='DateTime') { 
									query =query+' ='+  dt.getDateTime(mapofCriterion.get(num).value).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
								} else if(mapofCriterion.get(num).fieldDataType == CadenceConstants.MultiPickList )
                                	query =query+' INCLUDES (  \'' + mapofCriterion.get(num).value + '\')'; 
								 else
									query =query+' =\''+  mapofCriterion.get(num).value +'\'';  
							}
							else if(mapofCriterion.get(num).fieldDataType =='Number' || mapofCriterion.get(num).fieldDataType =='Date' || mapofCriterion.get(num).fieldDataType =='DateTime'){ 
								if(mapofCriterion.get(num).operation =='greater'){
									if(mapofCriterion.get(num).fieldDataType =='Number')
									{
										if(isEntry){
											query =query+' >'+  decimal.valueOf(mapofCriterion.get(num).value); 
										} 
										else{
											decimal numb = decimal.valueOf(mapofCriterion.get(num).value);
											query += ' != NULL AND '+ mapofCriterion.get(num).fieldName;                                        
											query += ' >'+  numb;
										}
									} 
									if(mapofCriterion.get(num).fieldDataType =='Date')
										query =query+' >'+  getDateFormat(Date.valueOf((String)mapofCriterion.get(num).value));
									if(mapofCriterion.get(num).fieldDataType =='DateTime')
										query =query+' >'+  dt.getDateTime(mapofCriterion.get(num).value).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');	    
								}
								else  if(mapofCriterion.get(num).operation =='greater_or_equals'){ 
									if(mapofCriterion.get(num).fieldDataType =='Number')
									{
										if(isEntry){
											query =query+' >='+  decimal.valueOf(mapofCriterion.get(num).value); 
										} 
										else{
											decimal numb = decimal.valueOf(mapofCriterion.get(num).value);
											query += ' != NULL AND '+ mapofCriterion.get(num).fieldName;
											query += ' >='+  numb;
										}
									} 
									if(mapofCriterion.get(num).fieldDataType =='Date')
										query =query+' >='+  getDateFormat(Date.valueOf((String)mapofCriterion.get(num).value));
									if(mapofCriterion.get(num).fieldDataType =='DateTime')
										query =query+' >='+  dt.getDateTime(mapofCriterion.get(num).value).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
								}
								else if(mapofCriterion.get(num).operation =='less_or_equals'){ 
									if(mapofCriterion.get(num).fieldDataType =='Number')
									{
										if(isEntry){
											decimal numb = decimal.valueOf(mapofCriterion.get(num).value);
											query += ' = NULL OR '+ mapofCriterion.get(num).fieldName;
											query += ' <='+  numb;                                                                          
										} 
										else{
											decimal numb = decimal.valueOf(mapofCriterion.get(num).value);
											query += ' != NULL AND '+ mapofCriterion.get(num).fieldName;
											query += ' <='+  numb;                                     
										}
									}   
									if(mapofCriterion.get(num).fieldDataType =='Date')
										query =query+' <='+  getDateFormat(Date.valueOf((String)mapofCriterion.get(num).value));
									if(mapofCriterion.get(num).fieldDataType =='DateTime')
										query =query+' <='+  dt.getDateTime(mapofCriterion.get(num).value).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
								}
								else  if(mapofCriterion.get(num).operation =='less_than'){ 
									if(mapofCriterion.get(num).fieldDataType =='Number')
									{
										if(isEntry){
											decimal numb = decimal.valueOf(mapofCriterion.get(num).value);
											query += ' = NULL OR '+ mapofCriterion.get(num).fieldName;
											query += ' <'+  numb;                                  
										} 
										else{
											decimal numb = decimal.valueOf(mapofCriterion.get(num).value);
											query += ' != NULL AND '+ mapofCriterion.get(num).fieldName;
											query += ' <'+  numb;
										}
									}                                    
									if(mapofCriterion.get(num).fieldDataType =='Date')
										query =query+' <'+ getDateFormat(Date.valueOf((String)mapofCriterion.get(num).value));
									if(mapofCriterion.get(num).fieldDataType =='DateTime')
										query =query+' <'+  dt.getDateTime(mapofCriterion.get(num).value).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
								}
							}
							else if(mapofCriterion.get(num).operation == 'start_with')
							{

								query =query+' LIKE  \'' +mapofCriterion.get(num).value + '%\'';
							}
							else
							{
								query =query+' LIKE  \'%' +mapofCriterion.get(num).value +'\''; 

							}
							listcount++;
							if(listcount <= mapofCriterion.keyset().size()){
								if(!conditionforAll.containsIgnoreCase('Custom logic') && num != mapofCriterion.keyset().size()){
									query = query + conditionforAll +' ';
								}

								else{
									String conditionLogic = mapofCadenceWiseEntryCriterions.get(cadence.id).criterionPriorityFormula != null ? mapofCadenceWiseEntryCriterions.get(cadence.id).criterionPriorityFormula.trim():'';
									String temp ='';
									if(conditionLogic.containsIgnoreCase(String.valueof(num+1))){
										temp = conditionLogic.substringBetween(String.valueof(num)+'',String.valueof(num+1)); 
									}

									else{
										temp = conditionLogic.substringAfter(String.valueof(num));    
									}
									query = query + ' '+temp +' ';
								}
							}
						}
					}   
				}
			}        
		}
		return query;
	} 

	public static String getDateFormat(Date d) {
		String dateFormatString = 'yyyy-MM-dd';
		Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
		String dateString = dt.format(dateFormatString);
		return dateString; 
	}

	public static List<String> getObjectListByType(String type){
		List<String> objectList = new List<String>(); 
		if(type == CadenceConstants.OPPORTUNITY_OBJECT_NAME){
			objectList =new List<String>{CadenceConstants.OPPORTUNITY_OBJECT_NAME,CadenceConstants.ACCOUNT_OBJECT_NAME,CadenceConstants.CONTRACT_OBJECT_NAME,CadenceConstants.PRICE_BOOK_OBJECT_NAME,CadenceConstants.CAMPAIGN_OBJECT_NAME,'OpportunityContactRole' };
		} else if(type == CadenceConstants.LEAD_OBJECT_NAME ){
			Schema.sObjectType sObjectName = Schema.getGlobalDescribe().get(CadenceConstants.DB_OBJECT_NAME);
			if (sObjectName != null){
				objectList =new List<String>{CadenceConstants.LEAD_OBJECT_NAME,CadenceConstants.DB_OBJECT_NAME };
			} else{
				objectList =new List<String>{CadenceConstants.LEAD_OBJECT_NAME};
			}

		} else if(type == CadenceConstants.CONTACT_OBJECT_NAME ){
			objectList =new List<String>{CadenceConstants.CONTACT_OBJECT_NAME,CadenceConstants.ACCOUNT_OBJECT_NAME };
		}
		return objectList;
	}

	public Static String formQueryOpportunity(String objName, Cadence__c cadence){
		String query;
		Map<Id,List<Id>> opportunityContactMap = new Map<Id,List<Id>>();
		List<Id> contactIds = new List<Id>();
		if(objName.equalsIgnoreCase(CadenceConstants.OPPORTUNITY_OBJECT_NAME)){
			String opporQuery = getOpportunityQuery(objName,cadence);

			List<Opportunity> listOfopprtunityToUpdate = new List<Opportunity>();
			List<Opportunity> listOfopprtunity = Database.query(opporQuery);
			CadenceService.mapOfOppcontact = CadenceService.opporContactMap(listOfopprtunity);
			String oppContactRoleQuery;
			if(contactRole!='')
				oppContactRoleQuery='Select ContactId,OpportunityId From OpportunityContactRole Where OpportunityId In :listOfopprtunity and Role =\''+String.escapeSingleQuotes(contactRole)+'\'';    
			else{
				oppContactRoleQuery='Select ContactId,OpportunityId From OpportunityContactRole Where OpportunityId In :listOfopprtunity';   
			}
			Set<String> setForDuplicateCheck =  new Set<String>();
			for(OpportunityContactRole oppCont : Database.query(oppContactRoleQuery)){
				if(oppCont.ContactId != null){
					contactIds.clear();
					if(opportunityContactMap.containsKey(oppCont.OpportunityId) ){
						contactIds = opportunityContactMap.get(oppCont.OpportunityId);
					}
					contactIds.add(oppCont.ContactId);
					opportunityContactMap.put(oppCont.OpportunityId,contactIds);

					if(!setForDuplicateCheck.contains(oppCont.OpportunityId)){
						Opportunity opp= new Opportunity(id=oppCont.OpportunityId,Cadence_Id__c=cadence.Id);
						listOfopprtunityToUpdate.add(opp);
						setForDuplicateCheck.add(oppCont.OpportunityId);
					}
				}
			}

			Set<Id> resultIds = new Set<Id>();

			if (listOfopprtunityToUpdate != null && listOfopprtunityToUpdate.size() > 0) {
				Database.SaveResult[] results = Database.update(listOfopprtunityToUpdate, false);
				for (Database.SaveResult sr: results) {
					if (sr.isSuccess()) {
						resultIds.add(sr.getId());
					}
				}
			}
			listOfOppContactIds = new set<Id>();
			if(opportunityContactMap != null && opportunityContactMap.size() > 0){
				for(Id opportunityId : resultIds){
					if(opportunityContactMap.containsKey(opportunityId) ){
						listOfOppContactIds.addAll(opportunityContactMap.get(opportunityId));
					}
				}
			}
			if(listOfOppContactIds != null && listOfOppContactIds.size() > 0){
				objName =CadenceConstants.CONTACT_OBJECT_NAME;
				query = 'Select Cadence_ID__c,isActivated__c,EntranceCriteria_Matched_Date__c from '+ objName +' Where (Cadence_ID__c = null) AND Id In :listOfOppContactIds';
				return  query;
			}
		}  
		else{
			query = 'Select Cadence_ID__c,isActivated__c,EntranceCriteria_Matched_Date__c from '+ objName +' Where (Cadence_ID__c = null) AND ';
			Set<String> allowedFields = new Set<String>();
			Map<Id, CriterionSet> mapofCadenceWiseEntryCriterions =  new Map<Id, CriterionSet>();
			Map<Id, CriterionSet> mapofCadenceWiseExitCriterions =  new Map<Id, CriterionSet>();
			Map<Id, CriterionSet> mapofCadenceActionCriterions =  new Map<Id, CriterionSet>();
			list<Cadence__c> listOfcadence =  new List<Cadence__c>();
			if(cadence != null){
				listOfcadence.add(cadence);
				mapofCadenceWiseEntryCriterions = RuleCriterionMatcherHelper.getCadenceWiseCriterions(listOfcadence,CadenceConstants.CRITERION_TYPE_ENTRY);
				mapofCadenceWiseExitCriterions = RuleCriterionMatcherHelper.getCadenceWiseCriterions(listOfcadence,CadenceConstants.CRITERION_TYPE_EXIT);

				if(cadence.CadenceActions__r != null && cadence.CadenceActions__r.size() >0)
					mapofCadenceActionCriterions = RuleCriterionMatcherHelper.getActionWiseCriterions(cadence.CadenceActions__r);	

				// Filter condition for entry criteria 
				if(mapofCadenceWiseEntryCriterions.keyset().size() > 0)
					query = query+ '(('+criteriaFilters(mapofCadenceWiseEntryCriterions,cadence,true)+')';

				// Filter condition for exit criteria  
				if(mapofCadenceWiseExitCriterions.keyset().size() > 0)
					query = query+ +' AND (NOT('+criteriaFilters(mapofCadenceWiseExitCriterions,cadence,false) +')))';
			}
		}

		if(query == null){
			query='';
		}

		return query;
	}

	public Static String getOpportunityQuery(String objName,Cadence__c cadence){
		String query = 'Select id from '+ objName +' Where ';
		Set<String> allowedFields = new Set<String>();
		Map<Id, CriterionSet> mapofCadenceWiseEntryCriterions =  new Map<Id, CriterionSet>();
		Map<Id, CriterionSet> mapofCadenceWiseExitCriterions =  new Map<Id, CriterionSet>();
		Map<Id, CriterionSet> mapofCadenceActionCriterions =  new Map<Id, CriterionSet>();
		list<Cadence__c> listOfcadence =  new List<Cadence__c>();
		if(cadence != null){
			listOfcadence.add(cadence);
			mapofCadenceWiseEntryCriterions = RuleCriterionMatcherHelper.getCadenceWiseCriterions(listOfcadence,CadenceConstants.CRITERION_TYPE_ENTRY);
			mapofCadenceWiseExitCriterions = RuleCriterionMatcherHelper.getCadenceWiseCriterions(listOfcadence,CadenceConstants.CRITERION_TYPE_EXIT);

			if(cadence.CadenceActions__r != null && cadence.CadenceActions__r.size() >0)
				mapofCadenceActionCriterions = RuleCriterionMatcherHelper.getActionWiseCriterions(cadence.CadenceActions__r);	

			// Filter condition for entry criteria 
			if(mapofCadenceWiseEntryCriterions.keyset().size() > 0){
				String isCriteriaChecked= criteriaFilters(mapofCadenceWiseEntryCriterions,cadence,true);
				if(isCriteriaChecked != null && isCriteriaChecked !=''){
					query = query+ '(('+isCriteriaChecked+')';
				}
			}

			// Filter condition for exit criteria  
			if(mapofCadenceWiseExitCriterions.keyset().size() > 0){
				String isCriteriaChecked= criteriaFilters(mapofCadenceWiseExitCriterions,cadence,false);
				if(isCriteriaChecked != null && isCriteriaChecked !=''){
					if(query.endsWithIgnoreCase('Where ')){
						query = query+'NOT('+isCriteriaChecked +')';
					}
					else
						query = query+' AND (NOT('+isCriteriaChecked +')))';    
				}
				else if(query.endsWithIgnoreCase('Where ')){
					query = query.removeEndIgnoreCase('Where ');
				}
				else{
					query =Query+')';
				}
			}
		}

        return RemoveBraces(query);
    }
    
    public Static string RemoveBraces(string query){
        Integer open,close ;
        open = query.countMatches('(');
        close = query.countMatches(')');
        if(close > open	)
            query = query.removeEnd(')');
        
        return query;
    }
}