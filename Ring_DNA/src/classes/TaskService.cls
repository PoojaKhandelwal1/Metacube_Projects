public class TaskService {

	public static Map<Id, List<Sequence_Action__c>> getAllParticipantActionsForTaskOwner(List<Task> tasks) {

		Map<Id, List<Sequence_Action__c>> objToPartActMap = new Map<Id, List<Sequence_Action__c>>();

		//Separating tasks for lead and contact
		Set<Id> objIds = new Set<Id>();
		for(Task t : tasks) {
			if(t.WhoId == null) {
				continue;
			} 
			objIds.add(t.WhoId); 
		}

		//Getting unperformed participants actions for contacts 
		if(!objIds.isEmpty()) {
			objToPartActMap = CadenceService.getRemainingParticipantAction(objIds, CadenceConstants.CONTACT_OBJECT_NAME);    	
		}

		if(objToPartActMap == null || objToPartActMap.size() == 0){
			objToPartActMap = CadenceService.getRemainingParticipantAction(objIds, CadenceConstants.OPPORTUNITY_OBJECT_NAME);
		}
		return objToPartActMap;
	}

	public static Boolean isCallTypeTask(Task t) {
		if(t.TaskSubtype != null && t.TaskSubtype.equalsIgnoreCase(CadenceConstants.ACTION_TYPE_CALL)) {
			return true;
		}
		return false;
	}

	public static Boolean isSmsTypeTask(Task t) {
		if(t.Subject != null && t.Subject.containsIgnoreCase('Outbound Message')) {
			return true;
		}
		return false;
	}

	public static Boolean isEmailTypeTask(Task t) {
		if((t.TaskSubtype != null && t.TaskSubtype.equalsIgnoreCase(CadenceConstants.ACTION_TYPE_EMAIL)) || 
				(t.TaskSubtype == null && t.Subject != null && t.Subject.containsIgnoreCase('Email'))) {
			return true;
		}
		return false;
	}

	public static Boolean isTaskType(Task t) {
		if(t.TaskSubtype != null && t.TaskSubtype.equalsIgnoreCase(CadenceConstants.ACTION_TYPE_TASK)) {
			return true;
		}
		return false;
	}    

	public static String getTaskType (Task t) {
		String type = '';
		if(TaskService.isCallTypeTask(t)) {
			type = CadenceConstants.ACTION_TYPE_CALL_VOICEMAIL; 
		} else if(TaskService.isEmailTypeTask(t)) {
			type = CadenceConstants.ACTION_TYPE_EMAIL;
		} else if(TaskService.isSmsTypeTask(t)) {
			type = CadenceConstants.ACTION_TYPE_SMS;
		} 
		else if(TaskService.isTaskType(t)) {
			type = CadenceConstants.ACTION_TYPE_TASK;
		}
		return type;
	}


	public static void updateObjectFields(List<Sequence_Action__c> actPartList) {

		//Returning if list is empty		
		if(actPartList == null || actPartList.isEmpty()) {
			return;
		}
		//Updating the fields
		List<SObject> sObjListToUpdate = new List<SObject>();
		Map<String, List<String>> leadfieldDataTypeMap = CadenceUtil.getObjectFieldsType(CadenceConstants.LEAD_OBJECT_NAME);
		Map<String, List<String>> contactfieldDataTypeMap = CadenceUtil.getObjectFieldsType(CadenceConstants.CONTACT_OBJECT_NAME);
		Map<String, List<String>> opportunityfieldDataTypeMap = CadenceUtil.getObjectFieldsType(CadenceConstants.OPPORTUNITY_OBJECT_NAME);

		for(Sequence_Action__c partAct : actPartList) {
			SObject sObj;
			if(partAct.Opportunity_Id__c != null && String.isNotBlank(partAct.Opportunity_Id__c)) { 
				sObj = new Opportunity();
				sObj.put('Id', partAct.Opportunity_Id__c);
			} else if(partAct.Lead_Id__c != null) { 
				sObj = new Lead();
				sObj.put('Id', partAct.Lead_Id__c);
			} else if(partAct.Contact_Id__c != null) { 
				sObj = new Contact();
				sObj.put('Id', partAct.Contact_Id__c);
			}
			String fieldsToUpdate = partAct.CadenceAction_Id__r.Fields_To_Update_Action__c;
			if(fieldsToUpdate != null && !fieldsToUpdate.equals('')) {
				Map<String, Object> fieldMap = (Map<String, Object>)(JSON.deserializeUntyped(fieldsToUpdate));
				fieldMap.remove('sobjectType');
				for(String fieldName : fieldMap.keySet()) {
					List<String> apiList;
					if(partAct.Cadence_Type__c.equals(CadenceConstants.OPPORTUNITY_OBJECT_NAME) && String.isNotBlank(partAct.Opportunity_Id__c)){
						apiList = opportunityfieldDataTypeMap.get(fieldName);
					} else if(partAct.Lead_Id__c != null) { 
						apiList = leadfieldDataTypeMap.get(fieldName);
					} else if(partAct.Contact_Id__c != null) { 
						apiList = contactfieldDataTypeMap.get(fieldName);
					}

					String fieldApiName = apiList[0];
					String fieldApiType = apiList[1];
					CadenceUtil.updateFieldValue(sObj, fieldApiName, fieldMap.get(fieldName), fieldApiType);
				}
				sObjListToUpdate.add(sObj);					
			}
		}
		if(!sObjListToUpdate.isEmpty()) {
			Database.SaveResult[] results = Database.update(sObjListToUpdate, false);
		}
	}

}