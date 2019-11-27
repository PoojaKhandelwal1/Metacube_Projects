public class CadenceProgressIndicatorController {
	public static String nameSpace = CadenceConstants.NAMESPACE;

	@AuraEnabled
	public static String saveCadence(string cadenceObjString,  string listCadenceActionString, List<String> caIdsList){
		Cadence__c cadenceObj;
		List<CadenceAction__c> listCadenceAction = New  List<CadenceAction__c>();
		Sequence sequence = (Sequence)System.JSON.deserialize(cadenceObjString, Sequence.class); 
		List<SequenceAction> sequenceActionList = (List<SequenceAction>)System.JSON.deserialize(listCadenceActionString, List<SequenceAction>.class); 
		for (SequenceAction sequenceAction : sequenceActionList){
			listCadenceAction.add(getCadenceAction(sequenceAction));
		}
		cadenceObj = getCadence(sequence);
		if (sequence.id != null && string.valueOf(sequence.id) != '' ){
			cadenceObj.Id = Id.valueOf(sequence.id);
		}
		populatePostFixExpressions(cadenceObj);   
		upsert cadenceObj;
		Map < Id, CadenceAction__c > mapofOldCadenceAction = CadenceSelector.getCadenceActionsByIds(New set < Id > {
			cadenceObj.Id
		});
		deleteCadenceAction(cadenceObj, caIdsList);
		List < CadenceAction__c > caListToInsert = new List < CadenceAction__c > ();
	    List < CadenceAction__c > caListToupdate = new List < CadenceAction__c > ();
		for (CadenceAction__c caObj: listCadenceAction) {
			if (caObj.Cadence_Id__c == null) {
				caObj.Cadence_Id__c = cadenceObj.Id;
			}
			populateCadActionPostFixExpression(caObj);
			if (mapofOldCadenceAction.containskey(caObj.id)) {
				If(mapofOldCadenceAction.get(caObj.id) != null && (mapofOldCadenceAction.get(caObj.id).Day__c != caObj.Day__c || mapofOldCadenceAction.get(caObj.id).Hour__c != caObj.Hour__c)){
					if(caObj.Trigger_Type__c =='Immediate' && (caObj.Day__c == null || caObj.Hour__c == null)){	
						caObj.Day__c=0;
						caObj.Hour__c =0;
					}
					caListToInsert.add(caObj);                    
				}
				else{
                    caListToupdate.add(caObj);
                }
			} else {
				caListToInsert.add(caObj);
			}
		}
		Database.UpsertResult[] results = Database.upsert(caListToInsert);
		Map<Id, Boolean> createdAndUpdateCadenceActions = new Map<Id, Boolean>();
		Map<Id, CadenceAction__c> cadenceActionsToInsertMap = new Map<Id, CadenceAction__c>();
		for (Integer index = 0, size = results.size(); index < size; index++) {
			if (results[index].isSuccess()) {
				if (results[index].isCreated()) {
					cadenceActionsToInsertMap.put(caListToInsert[index].Id, caListToInsert[index]);
					createdAndUpdateCadenceActions.put(caListToInsert[index].Id, true);
				} else {
					cadenceActionsToInsertMap.put(caListToInsert[index].Id, caListToInsert[index]);
					createdAndUpdateCadenceActions.put(caListToInsert[index].Id, false);
				}
			}
		}
		if(caListToupdate != null && caListToupdate.size() > 0){
             Database.update(caListToupdate,false);
        }
		addActionOnParticipant(cadenceObj, cadenceActionsToInsertMap, createdAndUpdateCadenceActions, mapofOldCadenceAction);
		return String.valueOf(cadenceObj.Id);
	}

	public static CadenceAction__c getCadenceAction(SequenceAction sequenceAction){
		CadenceAction__c cadenceAction = new CadenceAction__c();
		cadenceAction.Name = sequenceAction.name;
		if (sequenceAction.cadenceId != null && sequenceAction.cadenceId != ''){
			cadenceAction.Cadence_Id__c = Id.valueOf(sequenceAction.cadenceId);
		}
		if (sequenceAction.id != null && string.valueOf(sequenceAction.id) != '' ){
			cadenceAction.Id = ID.valueOf(sequenceAction.id);
		}
		cadenceAction.Action_Criterion__c = sequenceAction.actionCriterion;
		cadenceAction.Action_Id__c = Id.valueOf(sequenceAction.actionId);
		if (sequenceAction.day != null && sequenceAction.day != '')
			cadenceAction.Day__c = Integer.valueOf(sequenceAction.day);
		cadenceAction.Fields_To_Update_Action__c = sequenceAction.fieldsToUpdateAction;
		if (sequenceAction.hour != null && sequenceAction.hour != '')
			cadenceAction.Hour__c = Integer.valueOf(sequenceAction.hour);
		if (sequenceAction.index != null && sequenceAction.index != '')
			cadenceAction.Index__c = Integer.valueOf(sequenceAction.index);
		cadenceAction.Priority__c = sequenceAction.priority;
		if (sequenceAction.priorityNumber != null && sequenceAction.priorityNumber != '')
			cadenceAction.Priority_number__c = Integer.valueOf(sequenceAction.priorityNumber);
		cadenceAction.Trigger_Type__c = sequenceAction.triggerType;
		return cadenceAction;
	}
	public static Cadence__c getCadence(Sequence sequence){
		Cadence__c cadence = new Cadence__c();
		cadence.Name = sequence.name;
		cadence.Entrance_Criteria__c = sequence.entranceCriteria;
		cadence.Exit_Criteria__c = sequence.exitCriteria;
		cadence.matching_priority__c = sequence.matchingPriority;
		cadence.Participent_Activation__c = sequence.participentActivation;
		cadence.Record_Type__c = sequence.recordType;
		return cadence;
	}
	public static void populatePostFixExpressions(Cadence__c cadenceObj) {
		String entryCriterion = cadenceObj.Entrance_Criteria__c;
		CriterionSet ecs = CriterionSet.parse(entryCriterion);
		if(ecs.criterionPriorityFormula != null && !ecs.criterionPriorityFormula.equals('')) {
			cadenceObj.Entrance_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(ecs.criterionPriorityFormula);	
		}
		String exitCriterion = cadenceObj.Exit_Criteria__c;
		ecs = CriterionSet.parse(exitCriterion);
		if(ecs.criterionPriorityFormula != null && !ecs.criterionPriorityFormula.equals('')) {
			cadenceObj.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(ecs.criterionPriorityFormula);	
		}
	}

	public static void populateCadActionPostFixExpression(CadenceAction__c cadAction) {
		String actionCriterion = cadAction.Action_Criterion__c;
		if(actionCriterion != null && !actionCriterion.equals('')) {
			CriterionSet ecs = CriterionSet.parse(actionCriterion);
			if(ecs.criterionPriorityFormula != null && !ecs.criterionPriorityFormula.equals('')) {
				cadAction.Action_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(ecs.criterionPriorityFormula);	
			}	
		}
	}
	/**
	 * @description - Used to create ParticipantActions by CadenceActions.
	 * @param cadenceObj - cadence object , caIds - CadenceActions id list
	 */
	public static void createParticipantActionsByCadenceActions(Cadence__c cadenceObj, Map<Id, String> caIds){
		List<SObject> soList = CadenceSelector.getParticipantsOfCadence(cadenceObj.Id , cadenceObj.Record_Type__c);
		List<Sequence_Action__c> paList = New List<Sequence_Action__c>();
		for (SObject sObj : soList){
			for(Id caId : caIds.keySet()){
				Sequence_Action__c paObj = New Sequence_Action__c();
				paObj.CadenceAction_ID__c = caId;
				paObj.Name = caIds.get(caId);
				if (cadenceObj.Record_Type__c == CadenceConstants.LEAD_OBJECT_NAME){
					paObj.Lead_Id__c = (String)sObj.get('Id');
					paList.add(paObj);
				} else {
					paObj.Contact_Id__c = (String)sObj.get('Id');
					paList.add(paObj);
				} 
			}
		}
		insert paList;
	}

	public static void deleteParticipantActionsByCadenceActions(List<Id> caIds){
		List<Sequence_Action__c> paList = CadenceSelector.getParticipantActionsByCadenceActionsIds(caIds);
		if (paList.size() > 0){
			delete paList;
		}
	}
	/*********************Updated logic for delete AOP*******************/
	public static void deleteCadenceAction(Cadence__c cadence, List<Id> caIdList){
		List<CadenceAction__c> ListOfCadenceActionToDelete = [Select id from CadenceAction__c where Id in :caIdList];
		if (ListOfCadenceActionToDelete.size() > 0){
			updateCadenceActionAndDelete(cadence, caIdList);
			delete ListOfCadenceActionToDelete;
		}
	}

	public static List<Sequence_Action__c> getParticipantActionsByCadenceActionsIds(List<Id> caIdList){
		List<Id> caIds = caIdList;
		String query = CadenceSelector.getQueryForObject(nameSpace+'Sequence_Action__c');
		query += ' WHERE '+nameSpace+'isActionPerformed__c = false AND ' +nameSpace+'CadenceAction_ID__c=:caIds';
		return Database.query(query); 
	} 

	public static void updateCadenceActionAndDelete(Cadence__c cadence, List<Id> caIdsToDelete){
		Set<Id> participantIdsList = New Set<Id>();
		Set<Id> deletedAOPIds = New Set<Id>();
		List<Sequence_Action__c> aopToUpdateList = New List<Sequence_Action__c>();
		List<Sequence_Action__c> aopToDeleteRelatedToCadence = new List<Sequence_Action__c>();

		List<Sequence_Action__c> aopToDeleteList = getParticipantActionsByCadenceActionsIds(caIdsToDelete);
		Map<Id, Sequence_Action__c> aopToDeleteMap = New Map<Id, Sequence_Action__c>(aopToDeleteList);
		deletedAOPIds = aopToDeleteMap.keySet();


		list<SObject> participantList = CadenceSelector.getParticipantsOfCadence(cadence.Id, cadence.Record_Type__c); 
		Map<Id, SObject> participantMap = New Map<Id, SObject>(participantList);
		participantIdsList = participantMap.keySet();

		Map<Id, List<Sequence_Action__c>>  participantSequenceActionMap = CadenceService.getRemainingParticipantAction(participantIdsList, cadence.Record_Type__c);


		for (Id sobjID : participantIdsList ){
			List<Sequence_Action__c> saList = participantSequenceActionMap.get(sobjID);
			Integer day = 0, hour = 0;
			DateTime entranceDate;  
			if(saList != null && saList.size() > 0){
				for (Sequence_Action__c sa : saList){
					if (deletedAOPIds.contains(sa.Id)){ 
						aopToDeleteRelatedToCadence.add(sa);
						if (entranceDate == null && sa.Expected_Execution_Date__c != null){
							if (sa.Expected_Execution_Date__c <  system.now()){
								entranceDate = system.now();
							}else{
								day = sa.CadenceAction_Id__r.Day__c != null ? -(Integer)sa.CadenceAction_Id__r.Day__c : 0;
								hour = sa.CadenceAction_Id__r.Hour__c != null ? -(Integer)sa.CadenceAction_Id__r.Hour__c : 0;
								entranceDate = sa.Expected_Execution_Date__c;
								entranceDate = CadenceUtil.addTimeInDate(entranceDate, day, hour);
								if (entranceDate < system.now()){
									entranceDate = system.now();
								}
							}
						}
					}else if (entranceDate != null){
						day = sa.CadenceAction_Id__r.Day__c != null ? (Integer)sa.CadenceAction_Id__r.Day__c : 0;
						hour = sa.CadenceAction_Id__r.Hour__c != null ? (Integer)sa.CadenceAction_Id__r.Hour__c : 0;
						entranceDate = CadenceUtil.addTimeInDate(entranceDate, day, hour);
						sa.Expected_Execution_Date__c = entranceDate;
						aopToUpdateList.add(sa);
					}
				}
			}
		}
		if (aopToUpdateList.size() > 0 ){
			update aopToUpdateList; 
		}

		if (aopToDeleteRelatedToCadence.size() > 0 ){
			delete aopToDeleteRelatedToCadence;
		}
	}
	/*********************Updated logic for add  AOP*******************/
	public static void addActionOnParticipant(Cadence__c cadence, Map<Id, CadenceAction__c> cadenceActionsToInsertMap,Map<Id,Boolean> createdAndUpdateCadenceActions,Map<Id, CadenceAction__c> mapofOldCadenceAction){
        List<Sequence_Action__c> saToInsert = New List<Sequence_Action__c>();
        Set<Id> participantIdsList = New Set<Id>();
        list<SObject> participantList = CadenceSelector.getParticipantsOfCadence(cadence.Id, cadence.Record_Type__c);
        Map<Id, SObject> participantMap = New Map<Id, SObject>(participantList);
        participantIdsList = participantMap.keySet();
        Map<Id, List<Sequence_Action__c>> participantSequenceActionMap = New Map<Id, List<Sequence_Action__c>>();

        participantSequenceActionMap = CadenceService.getRemainingParticipantActions(participantIdsList, cadence.Record_Type__c);
        for (Id sobjID: participantIdsList) {
            List < Sequence_Action__c > saList = new List < Sequence_Action__c > ();
            saList = participantSequenceActionMap.get(sobjID);
            Integer lastIndex = 0;
            if (saList != null) {
                lastIndex = saList.size() - 1;
                Sequence_Action__c sa = saList.get(0);
                DateTime entranceDate = sa.Expected_Execution_Date__c;
                DateTime prevSequenceActionDate ;
                Boolean isupdate = false;
                for (Sequence_Action__c seqAction: saList) {
                    if (cadenceActionsToInsertMap.containskey(seqAction.CadenceAction_ID__c) || isupdate) {
                        CadenceAction__c cadenceAction = mapofOldCadenceAction.containskey(seqAction.CadenceAction_ID__c) ? mapofOldCadenceAction.get(seqAction.CadenceAction_ID__c) : New CadenceAction__c();
                        Sequence_Action__c updateSequenceAction = seqAction;
                        if (cadence.Record_Type__c == CadenceConstants.LEAD_OBJECT_NAME) {
                            updateSequenceAction.Lead_Id__c = (String) sobjID;
                        } else {
                            updateSequenceAction.Contact_Id__c = (String) sobjID;
                        }
                        Integer day = 0, hour = 0;
                        if (!isupdate && cadenceActionsToInsertMap.get(seqAction.CadenceAction_ID__c) != null) {
                            decimal updateDayOfCadenceAction = cadenceActionsToInsertMap.get(seqAction.CadenceAction_ID__c).Day__c != null ? cadenceActionsToInsertMap.get(seqAction.CadenceAction_ID__c).Day__c : 0.0;
                            decimal updateHourOfCadenceAction = cadenceActionsToInsertMap.get(seqAction.CadenceAction_ID__c).Hour__c != null ? cadenceActionsToInsertMap.get(seqAction.CadenceAction_ID__c).Hour__c : 0.0;
                            decimal OldDayOfCadenceAction = cadenceAction.Day__c != null ? cadenceAction.Day__c : 0.0;
                            decimal OldHourOfCadenceAction = cadenceAction.Hour__c != null ? cadenceAction.Hour__c : 0.0;
                            day = (Integer)(updateDayOfCadenceAction - OldDayOfCadenceAction);
                            hour = (Integer)(updateHourOfCadenceAction - OldHourOfCadenceAction);
                            if(seqAction.Expected_Execution_Date__c != null){
                            	entranceDate = seqAction.Expected_Execution_Date__c;  
                            }
                        } else {
                            day = updateSequenceAction.CadenceAction_Id__r.Day__c != null ? (Integer) updateSequenceAction.CadenceAction_Id__r.Day__c : 0;
                            hour = updateSequenceAction.CadenceAction_Id__r.Hour__c != null ? (Integer) updateSequenceAction.CadenceAction_Id__r.Hour__c : 0;
                        }
                        DateTime updatedDateTime = CadenceUtil.addTimeInDate(entranceDate, day, hour);
                        prevSequenceActionDate= prevSequenceActionDate == null ?updatedDateTime: prevSequenceActionDate;
                        if(updatedDateTime >= prevSequenceActionDate){
                           entranceDate = updatedDateTime;
                        }
                        updateSequenceAction.Expected_Execution_Date__c = entranceDate;
                        saToInsert.add(updateSequenceAction);
                        isupdate = true;
                    }
                    prevSequenceActionDate = seqAction.Expected_Execution_Date__c;
                }
                if (!isupdate) {
                    entranceDate = saList.get(lastIndex).Expected_Execution_Date__c;
                }
                saToInsert.addAll(createNewSequenceAction(cadenceActionsToInsertMap, entranceDate, sobjID, cadence, createdAndUpdateCadenceActions));
            } else {
                DateTime entranceDate = system.now();
                saToInsert.addAll(createNewSequenceAction(cadenceActionsToInsertMap, entranceDate, sobjID, cadence, createdAndUpdateCadenceActions));
            }
        }
        if (saToInsert != null && saToInsert.Size() > 9500) {
            Create_Action_On_Participant_Batch actionPartBatch = new Create_Action_On_Participant_Batch(saToInsert);
            Database.executeBatch(actionPartBatch);
        } else {
            CadenceService.createandUpdateActionOnPart(saToInsert);
        }
    }

	private static List < Sequence_Action__c > createNewSequenceAction(Map < Id, CadenceAction__c > cadenceActionsToInsertMap, DateTime entranceDate, Id sobjID, Cadence__c cadence, Map < Id, Boolean > createdAndUpdateCadenceActions) {
		List < Sequence_Action__c > listOfNewSequenceActions = new List < Sequence_Action__c > ();
		for (Id cadenceActionId: cadenceActionsToInsertMap.keySet()) {
			if (createdAndUpdateCadenceActions.containskey(cadenceActionId) && createdAndUpdateCadenceActions.get(cadenceActionId)) {
				CadenceAction__c cadenceAction = cadenceActionsToInsertMap.get(cadenceActionId);
				Sequence_Action__c newSequenceAction = New Sequence_Action__c();
				newSequenceAction.CadenceAction_ID__c = cadenceActionId;
				newSequenceAction.Name = cadenceAction.Name;
				if (cadence.Record_Type__c == CadenceConstants.LEAD_OBJECT_NAME) {
					newSequenceAction.Lead_Id__c = (String) sobjID;
				} else {
					newSequenceAction.Contact_Id__c = (String) sobjID;
				}
				Integer day = 0, hour = 0;
				day = cadenceAction.Day__c != null ? (Integer) cadenceAction.Day__c : 0;
				hour = cadenceAction.Hour__c != null ? (Integer) cadenceAction.Hour__c : 0;

				entranceDate = CadenceUtil.addTimeInDate(entranceDate, day, hour);
				if(entranceDate >=System.now()){
					newSequenceAction.Expected_Execution_Date__c = entranceDate;
				}
				else{
					newSequenceAction.Expected_Execution_Date__c = System.now(); 
				}
				listOfNewSequenceActions.add(newSequenceAction);
			}
		}
		return listOfNewSequenceActions;
	}
}