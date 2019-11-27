public class SequenceEngineHelper {
     
    public static String nameSpace = CadenceConstants.NAMESPACE;
    
    /** 
     * Name: getAvailableQueryRowsLimit
     * Desc: Getter method which returns available  limit of query rows which can be returned by a SOQL in the context
     * @param:
     * @return: Integer - Available query rows limit  
    **/
    public static Integer getAvailableQueryRowsLimit() {
        return Limits.getLimitQueryRows() - Limits.getQueryRows(); 
    }  
    
    /** 
     * Name: getAvailableDMLRowsLimit
     * Desc: Getter method which returns available  limit of DML reocrds which can be proceesed by a DML statement in the context
     * @param:
     * @return: Integer - Available query rows limit  
    **/
    public static Integer getAvailableDMLRowsLimit() {
    	return Limits.getLimitDMLRows() - Limits.getDMLRows();
    }
     
    /**
    * Name: deleteUnPerformedParticipantActions and update sequenceId and fields of participation list.
    * Desc: Method to delete un-performed participation actions (sequences) from Participation action Junction object 
    * @param:  (1) unAssociatedParticipantList - List<SObject> - List of participant to delete participation actions
    **/
    public static void deleteUnPerformedParticipantActions(List<SObject> unAssociatedParticipantList)
    {
    	Set<Id> unAssociatedParticipantsIdSet = new map<Id, SObject>(unAssociatedParticipantList).keyset();  
    	//--to do to create a common query to get unperformed participation actions  	
    	List<Sequence_Action__c> unperformedParticipationActionList = [SELECT Id, Lead_Id__c, Contact_Id__c, CadenceAction_Id__c, CadenceAction_Id__r.Cadence_Id__c FROM Sequence_Action__c WHERE (Lead_Id__c IN :unAssociatedParticipantsIdSet OR Contact_Id__c IN :unAssociatedParticipantsIdSet) AND isActionPerformed__c=false Limit: getAvailableQueryRowsLimit()];
        if(unperformedParticipationActionList.size() > 0)
        {
    		delete unperformedParticipationActionList;
        }
        //--to do  call trigger        
    	update unAssociatedParticipantList;
    }
    
    //move to util
    public static List<SObject> removeChildListItemsFromParentList(List<SObject> parentList, List<Sobject> childList)
    {   
    	Map<Id,Sobject> parentListMap = (new Map<Id,SObject>(parentList));
    	if(parentList == null || childList == null || childList.size() == 0)
    	{
    		return parentList;
    	}
    	    	
    	Set<Id> resultIds = (new Map<Id,SObject>(childList)).keySet();
    	if(resultIds.size() > 0)
    	{
    		for(Id participantId : resultIds)
    		{
    			parentListMap.remove(participantId);
    		}
    	}
    	return parentListMap.values(); 	
    }    
    
    // to do - Can Depricate to - getActiveSequenceIdToSequenceMapByFieldValue()
    public static Map<Id, Cadence__c> getActiveSequenceIdToSequenceMap(List<string> participantType)
    {
    	return new Map<Id, Cadence__c>([SELECT Id, Name, Entrance_Criteria__c, Entrance_Criteria_PE__c, Exit_Criteria__c, Exit_Criteria_PE__c,
                                       Participent_Activation__c, Record_Type__c, Status__c, matching_priority__c, CreatedDate,LastModifiedDate,
                                       (SELECT Id, Name, Action_Criterion__c, Action_Criteria_PE__c, Action_Id__c,
                                        Cadence_Id__c, Day__c, Hour__c, Trigger_Type__c, Fields_To_Update_Action__c, Action_Id__r.Activation_Type__c, 
                                        Action_Id__r.Task_Description__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c  
                                        FROM CadenceActions__r order by Index__c) 
                                       FROM Cadence__c WHERE Status__c = true AND Record_Type__c in : participantType Limit: getAvailableQueryRowsLimit()]);
    }
    
    public static Map<Id, Cadence__c> getActiveSequenceIdToSequenceMapByFieldValue(Map<String, Set<String>> fieldNameToFieldValueSetMap) {
    	String query = 'SELECT Id, Name, Entrance_Criteria__c, Entrance_Criteria_PE__c, Exit_Criteria__c, Exit_Criteria_PE__c, ';
        query += 'Participent_Activation__c, Record_Type__c, Status__c, matching_priority__c, CreatedDate,LastModifiedDate, ';
        query += '(SELECT Id, Name, Action_Criterion__c, Action_Criteria_PE__c, Action_Id__c, ';
        query += 'Cadence_Id__c, Day__c, Hour__c, Trigger_Type__c, Fields_To_Update_Action__c, Action_Id__r.Activation_Type__c, ';
        query += 'Action_Id__r.Task_Description__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c ';
        query += 'FROM CadenceActions__r order by Index__c) ';
        query += 'FROM Cadence__c WHERE Status__c = true';
        
        Boolean isWhereClauseAdded = true;
        for(String fieldName : fieldNameToFieldValueSetMap.keySet()) {
        	String fieldValueSetStr = '(';
            for(String fieldValue : fieldNameToFieldValueSetMap.get(fieldName)){
                if(fieldValue != null){
                    fieldValueSetStr += '\'' + fieldValue + '\'' + ',';
                }
            }
            fieldValueSetStr = fieldValueSetStr.subString(0, fieldValueSetStr.length() - 1);
            fieldValueSetStr += ')';
                
            if(String.isNotBlank(fieldName)) {
            	fieldName = String.escapeSingleQuotes(fieldName);
            	if(isWhereClauseAdded) {
	                query += ' AND ' + fieldName + ' IN ' + fieldValueSetStr;
	            } else {
	                query += ' WHERE ' + fieldName + ' IN ' + fieldValueSetStr;
	                isWhereClauseAdded = true;
	            }
            }
        }
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        
        return new Map<Id, Cadence__c>((List<Cadence__c>)DataBase.query(query));
    }
    
    
    /**
    * Name: getParticipantListToCreateParticipantActions
    * Desc: Method to get participant list for which Participant Actions are not created 
    * @param:  (1) participantList - List<SObject> - List of Contact or Lead records
    * 		   (2) sequenceIdToSequenceMap - Map<Id, Cadence__c> - sequence Id to Sequence record (with sequence actions) list map
    * 		   (3) participantType - String - object Type (Lead/Contact)
    * @return: List<SObject> - participant list for which Participant Actions are not created
    **/
    public static List<SObject> getParticipantListToCreateParticipantActions(List<SObject> participantList, Map<Id, Cadence__c> sequenceIdToSequenceMap, 
    																					String participantType) {
	   	Map<Id,Set<Id>> participantIdToSequenceActionIdSetMap = getParticipantIdToSequenceActionIdSetMap(participantList);
	   	Map<Id, Set<Id>> sequenceIdToSequenceActionIdSetMap = new Map<Id, Set<Id>>();
	   	for(Id sequenceId : sequenceIdToSequenceMap.keySet()) {
	   		if(sequenceIdToSequenceMap.get(sequenceId).CadenceActions__r != null) {
	   			sequenceIdToSequenceActionIdSetMap.put(sequenceId, new Set<Id>());
	   			for(CadenceAction__c sequenceAction : sequenceIdToSequenceMap.get(sequenceId).CadenceActions__r) {
	   				sequenceIdToSequenceActionIdSetMap.get(sequenceId).add(sequenceAction.Id);
	   			}
	   		}
	   	}
	   	
	   	List<SObject> requiredParticipantList = new List<SObject>();
	   	for(SObject participant: participantList) {
	   		Set<Id> participantSequenceActionIdSet = participantIdToSequenceActionIdSetMap.containsKey(participant.Id) ? participantIdToSequenceActionIdSetMap.get(participant.Id) 
	   												: new Set<Id>();
	   		Set<Id> SequenceActionIdSet;
	   		 
	   		if(participantType == 'Contact' || participantType == 'Opportunity') {
	   			Contact contactRecord = (Contact)participant;
	   			SequenceActionIdSet = sequenceIdToSequenceActionIdSetMap.containsKey(contactRecord.Cadence_ID__c) ? sequenceIdToSequenceActionIdSetMap.get(contactRecord.Cadence_ID__c)
	   									: new Set<Id>(); 
	   		} else {
	   			Lead leadRecord = (Lead)participant;
	   			SequenceActionIdSet = sequenceIdToSequenceActionIdSetMap.containsKey(leadRecord.Cadence_ID__c) ? sequenceIdToSequenceActionIdSetMap.get(leadRecord.Cadence_ID__c)
	   									: new Set<Id>(); 
	   		}
	   		
   			if(!participantSequenceActionIdSet.equals(SequenceActionIdSet)) {
   				requiredParticipantList.add(participant);
   			}
	   	}
	   	return requiredParticipantList;
	}
	
	
    /**
    * Name: getParticipantIdToSequenceActionIdSetMap
    * Desc: Method to get participant id and related Participant action's parent sequence action's id set 
    * @param:  (1) participantList - List<SObject> - List of Contact or Lead records
    * @return: Map<Id,Set<Id>> - participant Id To Participant action's parent sequence action's id set Map
    **/
    private static Map<Id,Set<Id>> getParticipantIdToSequenceActionIdSetMap(List<SObject> participantList) {
	   	Map<Id,Set<Id>> participantIdToSequenceActionIdSetMap = new Map<Id,Set<Id>>();
	   	System.debug('participantList.size='+participantList.size());
	   	Map<Id, SObject> participantIdToParticipantMap = new Map<Id, SObject>(participantList);
	   	
	   	List<Sequence_Action__c> participantActions = [SELECT Contact_Id__c, Lead_Id__c, CadenceAction_ID__c FROM Sequence_Action__c WHERE Contact_Id__c IN: 
	   													participantIdToParticipantMap.keySet() OR Lead_Id__c IN: participantIdToParticipantMap.keySet() Limit: getAvailableQueryRowsLimit()];
	   	
	   	Id participantId = null;
	   	
	   	for(Sequence_Action__c participantAction :participantActions) {
	   		participantId = (String.isNotBlank(participantAction.Contact_Id__c)) ? participantAction.Contact_Id__c : 
	   							(String.isNotBlank(participantAction.Lead_Id__c) ? participantAction.Lead_Id__c : null); 
	   	
		    if(participantId != null ) {
		    	if(!participantIdToSequenceActionIdSetMap.containsKey(participantId)) {
			    	participantIdToSequenceActionIdSetMap.put(participantId, new Set<Id>());
			   	} 
		    	participantIdToSequenceActionIdSetMap.get(participantId).add(participantAction.CadenceAction_ID__c);
		    }
	   	}
	   	return participantIdToSequenceActionIdSetMap;
	}
	
	public static Map<Id, List<Sequence_Action__c>> getUnPerformedParticipantActions(List<SObject> participantList, string participantType) 
	{	    
	    Map<Id, SObject> participationIdToParticipantMap = new Map<Id, SObject>(participantList);
	    
	    Set<Id> participantIds = participationIdToParticipantMap.keySet();
	    
	    Map<Id, List<Sequence_Action__c>> participantIdToUnperformedParticipantActionsMap = new Map<Id, List<Sequence_Action__c>>();
        
        //Getting all the available and unperformed action for object
        //--to do to create a common query to get unperformed participation actions
        List<Sequence_Action__c> unperformedParticipantActionList = [Select Id, Name, CadenceAction_ID__c, Show_on_Target_List__c, Lead_Id__c, Contact_Id__c,Opportunity_Id__c,Cadence_Type__c, isActionPerformed__c, CadenceAction_Id__r.Day__c,
                                  CadenceAction_Id__r.Hour__c, CadenceAction_Id__r.Action_Id__r.Type__c, CadenceAction_Id__r.Fields_To_Update_Action__c,
                                  CadenceAction_Id__r.Action_Id__r.Activation_Type__c, CadenceAction_Id__r.Trigger_Type__c, CadenceAction_Id__r.Action_Id__r.Email_Type__c,
                                  CadenceAction_Id__r.Action_Id__r.Task_Description__c, CadenceAction_Id__r.Action_Id__r.Template_Id__c, 
                                  CadenceAction_Id__r.Index__c, Expected_Execution_Date__c, Actual_Execution_Date__c From Sequence_Action__c 
                                  where (Lead_Id__c IN :participantIds OR Contact_Id__c IN : participantIds) AND CadenceAction_ID__r.Cadence_Id__r.Record_Type__c = : participantType AND isActionPerformed__c = false AND isDeferred__c = false 
                                  order by CadenceAction_Id__r.Index__c Limit: getAvailableQueryRowsLimit()]; //identify use of isDeferred__c where clause
                                  
        for(Sequence_Action__c participantAction : unperformedParticipantActionList) {
            if(participantAction.Lead_Id__c == null && participantAction.Contact_Id__c == null) {
                continue;
            }
			
            if(participantAction.Lead_Id__c == null) {
                if(!participantIdToUnperformedParticipantActionsMap.containsKey(participantAction.Contact_Id__c)) {
                    participantIdToUnperformedParticipantActionsMap.put(participantAction.Contact_Id__c, new List<Sequence_Action__c>());	    
                }
                participantIdToUnperformedParticipantActionsMap.get(participantAction.Contact_Id__c).add(participantAction);
                	    
            } else {
                if(!participantIdToUnperformedParticipantActionsMap.containsKey(participantAction.Lead_Id__c)) {
                    participantIdToUnperformedParticipantActionsMap.put(participantAction.Lead_Id__c, new List<Sequence_Action__c>());	    
                }
                participantIdToUnperformedParticipantActionsMap.get(participantAction.Lead_Id__c).add(participantAction);
            }
        }
       
        return participantIdToUnperformedParticipantActionsMap;
	}
	
	 /**
    * Name: createHistoryObject
    * Desc: Method to create an object of Sequence History
    * @param:  (1) sequenceId - SequenceId of participant
    * @param:  (2) participantId - Id of participant
    * @param:  (2) participantType - Type of participant
    * @return: Participant_Sequence_History__c - object of sequence history
    **/
	public static Participant_Sequence_History__c createHistoryObject(Id sequenceId, Id participantId, string participantType){
        Participant_Sequence_History__c history = new Participant_Sequence_History__c();
        history.Sequence_Id__c = sequenceId;
        if(participantType.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
            history.Lead_Id__c = participantId;
        }
        else{
            history.Contact_Id__c = participantId;
        }
        return history;
    }   
    
    //--to do  move to util class
    public static Task getEmailTask(Id sequenceActionId, String actionName, Id sObjectId, Id templateId) {
        Task t = new Task();
        t.Subject = 'Emails: '+ actionName;
        t.Description = templateId;
        t.WhoId = sObjectId;
        t.TaskSubtype = 'Email'; 
        t.Sequence_Action__c = sequenceActionId;
        t.Status = 'Completed';
        return t;
    }
    
    /* Method to create email message
	 * @Param : sObjectId - List of sobject having email Ids,EmailTemplateId - Email Template Id
	 */
    public static Messaging.MassEmailMessage createEmailMessage(Id sObjectId,Id EmailTemplateId){
        Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
        mail.setSaveAsActivity(false);
        mail.setTargetObjectIds(new List<Id>{sObjectId});
        mail.setTemplateId(EmailTemplateId);
        return mail; 
    }
    
     public static NativeEmailMessage createNativeEmailMessage(String nativeMailTo,Id EmailTemplateId,Id participantId, Id actionId, String nameTo, Id usreId ){
        NativeEmailMessage emailMessage= NativeEmailController.resolveMergeFields(String.valueOf(participantId) , String.valueOf(EmailTemplateId));
        NativeEmailMessage nativeEmail = new NativeEmailMessage (nativeMailTo, '','', emailMessage.subject, emailMessage.Body,EmailTemplateId, actionId, nameTo, participantId, usreId);
        return nativeEmail; 
    }
    
    /* 
	* Method to perform Task Actions
	* @Param : Id - Id of sobject (Lead/Contact),taskDescription - Json OfTaskObj
	*/
    public static Task performTaskAction(Id sObjectId, String taskDescription){
        Task taskObj = (Task)JSON.deserialize(taskDescription, Task.class);
        taskObj.WhoId = sObjectId;
        return taskObj;
    }
    
    public static List<Messaging.MassEmailMessage> SendNativeEmail(List<NativeEmailMessage> nativeEmailToSend ){
        RingDNAApiCallouts ringDNAApiCallout = new RingDNAApiCallouts(true);
        List<NativeEmailMessage> nativeEmailMessageList = new List<NativeEmailMessage>();
        List<Messaging.MassEmailMessage> sfdcEmailMessageList = New List<Messaging.MassEmailMessage>(); 
        if (System.isBatch()){
            List<NativeEmailRespose> nativeEmailResposeList = new List<NativeEmailRespose>();
            try{
            	nativeEmailResposeList = ringDNAApiCallout.sendNativeMassEmail(nativeEmailToSend);    
            }catch(exception ex){
                for(NativeEmailMessage nativeEmailMessage :nativeEmailToSend ){
                    sfdcEmailMessageList.add(createEmailMessage(nativeEmailMessage.ParticipantId, nativeEmailMessage.TemplateId));
                }
            }
            // Create map of actionId and nativeEmailMessage
            Map<Id, NativeEmailMessage> actionIdNativeEmailMessageMap = new Map<Id, NativeEmailMessage>();
            for(NativeEmailMessage nativeEmailMessage : nativeEmailToSend ){
                actionIdNativeEmailMessageMap.put(NativeEmailMessage.ActionId, NativeEmailMessage);
            }
            if (nativeEmailResposeList != null && nativeEmailResposeList.size() > 0 ) {
                for (NativeEmailRespose nativeEmailRespose : nativeEmailResposeList){
                    if (nativeEmailRespose.success == false){
                        NativeEmailMessage nativeEmailMessage = actionIdNativeEmailMessageMap.get(nativeEmailRespose.actionId);
                        sfdcEmailMessageList.add(createEmailMessage(nativeEmailMessage.ParticipantId, nativeEmailMessage.TemplateId));
                    }
                }
            }
        }else{
            nativeEmailMessageList = nativeEmailToSend;
        }
        if(nativeEmailMessageList != null && nativeEmailMessageList.size() > 0){
            sendNativeEmailTroughTrigger(JSON.serialize(nativeEmailMessageList));
        }
        return sfdcEmailMessageList;
    }    
    
    /**
	 * @description Get object fields data types map.
	 * @param objType - Object type to get object fields info
	 * @param fields - Set of fields for which we need data type
	 * @return Map of field name to data type.
	 */
	public static Map<String, list<String>> getObjectFieldsType(String objType) {

		Map<String, list<String>> objectFieldDataTypeMap = new Map<String, list<String>>();

		Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap();
		for(String fieldName : fieldMap.keySet()) {
			list<String> apiList = new list<String>();
			String dataType = fieldMap.get(fieldName).getDescribe().getType().name();
			Schema.sObjectField fieldAPIName = fieldMap.get(fieldName);
			//String nameLable = fieldAPIName.getDescribe().getLabel();
			String nameLable = fieldAPIName.getDescribe().getName();
			apiList.add(fieldAPIName.getDescribe().getName());
			apiList.add(dataType);
			objectFieldDataTypeMap.put(nameLable, apiList);
		}
		return objectFieldDataTypeMap;
	}
    
    /**
	 * @description Get object fields data types map.
	 * @param obj - Object to set value
	 * @param fieldName - field to update
	 * @param value- value to update in obj field
	 * @param fieldType - type of field in sf
	 */
	public static SObject updateFieldValue(SObject obj, String fieldName, Object value, String fieldType) {
		if(fieldType.equalsIgnoreCase('currency') || fieldType.equalsIgnoreCase('double') || fieldType.equalsIgnoreCase('percent') || fieldType.equalsIgnoreCase('decimal')) {
			obj.put(fieldName, Decimal.valueOf(String.valueOf(value))); 
		} else if(fieldType.equalsIgnoreCase('boolean')) {
			obj.put(fieldName, Boolean.valueOf(value));
		} else if(fieldType.equalsIgnoreCase('date')) {
			obj.put(fieldName, date.valueOf(String.valueOf(value)));
		} else if(fieldType.equalsIgnoreCase('datetime')) {
			DateTimeCriterionEvaluator dtEval = new DateTimeCriterionEvaluator();
			obj.put(fieldName, dtEval.getDateTime(value)); 
		} else if(fieldType.equalsIgnoreCase('integer')) {
			obj.put(fieldName, (Integer.valueOf(value)));
		} else if(fieldType.equalsIgnoreCase('reference')){
			obj.put(fieldName, (ID)value);
		} else {
			obj.put(fieldName, (string)value);
		}   
		return obj;
	}
	
	public static Map<Id, List<Sequence_Action__c>> getTopMostUnPerformedParticipantActions(List<sObject> participantListToPerformParticipantAction, Map<Id, List<Sequence_Action__c>> participantIdToUnperformedParticipantActionsMap, Map<Id, SObject> participantIdToParentRecordMap, Map<Id, Cadence__c> activeSequenceIdToSequenceMap, string participantType)
	{
	   Map<Id, List<Sequence_Action__c>> participantIdToPerformParticipantActions = new  Map<Id, List<Sequence_Action__c>>();
	   
	   for(SObject participant : participantListToPerformParticipantAction) {
            if(participantIdToUnperformedParticipantActionsMap != null && !participantIdToUnperformedParticipantActionsMap.containsKey(participant.Id)) {
                continue;
            }
            Sequence_Action__c sequenceAction = participantIdToUnperformedParticipantActionsMap.get(participant.Id).get(0);
            if((Boolean)participant.get(nameSpace+'isActivated__c') && sequenceAction.Show_on_Target_List__c == false) {
                SObject parentParticipant;
                if(participantIdToParentRecordMap != null && participantIdToParentRecordMap.containsKey(participant.Id)) {
                    parentParticipant = participantIdToParentRecordMap.get(participant.Id);
                }
                List<Sequence_Action__c> participantAdditionalActionsList = RuleCriterionMatcher.getMatchingParticipantActions(activeSequenceIdToSequenceMap.get((Id)participant.get(nameSpace+'Cadence_Id__c')), participant, parentParticipant, new List<Sequence_Action__c>{sequenceAction}, participantType);
                if(!participantAdditionalActionsList.isEmpty()) {
                    participantIdToPerformParticipantActions.put(participant.Id, participantAdditionalActionsList);		
                }
            } 	
        } 	   
	   return participantIdToPerformParticipantActions;
	}
	
	public static List<SObject> getParticipantsWithMatchingExitCriteria(string participantType, List<SObject> participnatList, Map<Id, Cadence__c> sequenceIdToSequenceMap)
    {
    	List<SObject> participantListWithMatchingCriteria = new List<SObject>();
    	
    	For(SObject participant : participnatList)
    	{    		
    		SObject objParticipant = participant.clone();
    		Cadence__c sequence =  sequenceIdToSequenceMap.get((Id)objParticipant.get(CadenceConstants.NAMESPACE + 'Cadence_Id__c'));
    		    		
    		//return SObject if exit criteria matches otherwise sends null
    		SObject matchedCriteria = RuleCriterionMatcher.matchExitCriterion(sequence, objParticipant, null, participantType); //--to do  //check how to convert the participantTypeAndParantGroupsList to SObject and pass as third argument
    		If(matchedCriteria != null)
    		{    			
    			participantListWithMatchingCriteria.add(participant);
    		}    		
    	}    	
    	return participantListWithMatchingCriteria; 
    }
    
    public static Object GetUpdateValue(Object value, String fieldType, Object multipicklistvalues){
		if(fieldType == CadenceConstants.MultiPickList){
			return (Object)((string)multipicklistvalues + (string)value + ';');
		} else {
			return value;
		}
	}  
    
    
    @future(callout=true)
    public static void sendNativeEmailTroughTrigger(String serializeNativeEmailMessageList)
    {   
        RingDNAApiCallouts ringDNAApiCallout = new RingDNAApiCallouts(true);
        Map<String, Object> responseMap = new Map<String, Object>();
        List<Messaging.MassEmailMessage> sfdcEmailMessageList = New List<Messaging.MassEmailMessage>();        
        List<NativeEmailMessage> nativeEmailMessageList = (List<NativeEmailMessage>) JSON.deserialize(serializeNativeEmailMessageList, List<NativeEmailMessage>.class);
        List<NativeEmailRespose> nativeEmailResposeList = new List<NativeEmailRespose>();
        try{
            nativeEmailResposeList = ringDNAApiCallout.sendNativeMassEmail(nativeEmailMessageList);    
        }catch(exception ex){
            for(NativeEmailMessage nativeEmailMessage : nativeEmailMessageList ){
                sfdcEmailMessageList.add(createEmailMessage(nativeEmailMessage.ParticipantId, nativeEmailMessage.TemplateId));
            }
        }
        // Create map of actionId and nativeEmailMessage
        Map<Id, NativeEmailMessage> actionIdNativeEmailMessageMap = new Map<Id, NativeEmailMessage>();
        for(NativeEmailMessage nativeEmailMessage : nativeEmailMessageList ){
            actionIdNativeEmailMessageMap.put(NativeEmailMessage.ActionId, NativeEmailMessage);
        }
        if (nativeEmailResposeList != null && nativeEmailResposeList.size() > 0 ) {
            for (NativeEmailRespose nativeEmailRespose : nativeEmailResposeList){
                if (nativeEmailRespose.success == false){
                    NativeEmailMessage nativeEmailMessage = actionIdNativeEmailMessageMap.get(nativeEmailRespose.actionId);
                    sfdcEmailMessageList.add(createEmailMessage(nativeEmailMessage.ParticipantId, nativeEmailMessage.TemplateId));                    
                }
            }
        }
        if(sfdcEmailMessageList.isEmpty() == false) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(sfdcEmailMessageList, false);
        }                                        
    }
    
    @future
    public static void createTasks(String tasksJson) {
        List<Task> tasks = (List<Task>)JSON.deserialize(tasksJson, List<Task>.class);
        //insert tasks; 
        Database.SaveResult[] results = Database.insert(tasks, false);
    }
}