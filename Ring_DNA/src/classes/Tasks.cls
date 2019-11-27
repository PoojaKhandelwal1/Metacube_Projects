public with sharing class Tasks extends SObjectDomain {

	List<Task> records;

	public Tasks(List<Task> sObjectList)
	{
		super(sObjectList);
		records = sObjectList;
	} 

	public class Constructor implements SObjectDomain.IConstructable {
		public SObjectDomain construct(List<SObject> sObjectList) {
			return new Tasks(sObjectList);
		}
	}

	public override void onBeforeInsert() {
		Map<Id, List<Sequence_Action__c>> objToPartActMap = new Map<Id, List<Sequence_Action__c>>();
		List<Sequence_Action__c> actionToUpdate = new List<Sequence_Action__c>();
		Map<Id, List<CadenceAction__c>> objToCadActListMap = new Map<Id, List<CadenceAction__c>>();
		objToPartActMap = TaskService.getAllParticipantActionsForTaskOwner((List<Task>)records);
		if(objToPartActMap == null || objToPartActMap.isEmpty()) {
			return;
		}
		//Updating performed actions
		for(Task t : (List<Task>)records) {

			if(t.WhoId == null || t.Subject == null || t.Sequence_Action__c != null) {
				continue;
			}

			String taskType = TaskService.getTaskType(t);
			if(taskType.equals('')) {
				continue;
			}

			if(objToPartActMap.containsKey(t.WhoId)) {
				for(Sequence_Action__c action : objToPartActMap.get(t.WhoId)) {
					if(action == null || action.isActionPerformed__c == true || action.Show_on_Target_List__c == false || action.CadenceAction_Id__c == null) {
						continue;
					}
					if(taskType.containsIgnoreCase(action.CadenceAction_Id__r.Action_Id__r.Type__c)) {
						action.isActionPerformed__c = true;
						action.Actual_Execution_Date__c = System.now();
						t.Sequence_Action__c = action.Id;   
						actionToUpdate.add(action);
						break;	    
					}
				}
			}
		}
		if(!actionToUpdate.isEmpty()) {
			update actionToUpdate;
			TaskService.updateObjectFields(actionToUpdate);
		}

		//Updating dates on remaining participant objects
		List<Sequence_Action__c> saToUpdate = new List<Sequence_Action__c>();
		for(Sequence_Action__c sa : actionToUpdate) {
			Id objId = sa.Lead_Id__c == null ? sa.Contact_Id__c : sa.Lead_Id__c;
			saToUpdate.addAll(CadenceService.updateActionOnParticipantExpectedDate(sa.Actual_Execution_Date__c, (Integer)sa.CadenceAction_Id__r.Index__c, objToPartActMap.get(objId)));
		}

		if(!saToUpdate.isEmpty()) {
			update saToUpdate;
		}

	}


	public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {

		Map<Id, List<Sequence_Action__c>> objToPartActMap = new Map<Id, List<Sequence_Action__c>>();
		List<Sequence_Action__c> actionToUpdate = new List<Sequence_Action__c>();
		Map<Id, List<CadenceAction__c>> objToCadActListMap = new Map<Id, List<CadenceAction__c>>();
		List<Task> tasksToProcess = new List<Task>();

		for(Task t : (List<Task>)records) {
			if(existingRecords.get(t.Id).get('WhoId') == null && t.WhoId != null) {
				tasksToProcess.add(t);
			}
		}

		objToPartActMap = TaskService.getAllParticipantActionsForTaskOwner(tasksToProcess);
		if(objToPartActMap == null || objToPartActMap.isEmpty()) {
			return;
		}

		//Updating performed actions
		for(Task t : tasksToProcess) {

			if(t.WhoId == null || t.Subject == null || t.Sequence_Action__c != null) {
				continue;
			}

			String taskType = TaskService.getTaskType(t);
			if(taskType.equals('')) {
				continue;
			}

			if(objToPartActMap.containsKey(t.WhoId)) {

				for(Sequence_Action__c action : objToPartActMap.get(t.WhoId)) {
					if(action == null || action.isActionPerformed__c == true || action.Show_on_Target_List__c == false || action.CadenceAction_Id__c == null) {
						continue;
					}

					if(taskType.containsIgnoreCase(action.CadenceAction_Id__r.Action_Id__r.Type__c)) {
						action.isActionPerformed__c = true;
						action.Actual_Execution_Date__c = System.now();
						t.Sequence_Action__c = action.Id;   
						actionToUpdate.add(action);
						break;	    
					}
				}
			}
		}

		if(!actionToUpdate.isEmpty()) {
			update actionToUpdate;
			TaskService.updateObjectFields(actionToUpdate);
		}

		//Updating dates on remaining participant objects
		List<Sequence_Action__c> saToUpdate = new List<Sequence_Action__c>();
		for(Sequence_Action__c sa : actionToUpdate) {
			Id objId = sa.Lead_Id__c == null ? sa.Contact_Id__c : sa.Lead_Id__c;
			saToUpdate.addAll(CadenceService.updateActionOnParticipantExpectedDate(sa.Actual_Execution_Date__c, (Integer)sa.CadenceAction_Id__r.Index__c, objToPartActMap.get(objId)));
		}

		if(!saToUpdate.isEmpty()) {
			update saToUpdate;
		}

	}

	public override void onafterUpdate(Map<Id,SObject> existingRecords){
		CadenceService.updateIsPerformedOnActionOnParticipant(existingRecords.keySet());
	}
}