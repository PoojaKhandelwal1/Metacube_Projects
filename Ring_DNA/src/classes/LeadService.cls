public class LeadService implements IParticipant { 
      
    public static String nameSpace = CadenceConstants.NAMESPACE;
        
    public Map<Id, Set<Id>> getSequenceHistory()  
    {    	
    	Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap = new Map<Id, Set<Id>>();
    	for(Participant_Sequence_History__c participantSequenceHistory : [SELECT Lead_Id__c, Sequence_Id__c FROM Participant_Sequence_History__c WHERE Lead_Id__c != null]) {
           
           if(!participantIdToSequenceIdHistorySetMap.containsKey(participantSequenceHistory.Lead_Id__c))
           {
           	  participantIdToSequenceIdHistorySetMap.put(participantSequenceHistory.Lead_Id__c, new Set<Id>());
           }                       
           participantIdToSequenceIdHistorySetMap.get(participantSequenceHistory.Lead_Id__c).add(participantSequenceHistory.Sequence_Id__c);             
        }  
    	return participantIdToSequenceIdHistorySetMap;
    }
			
	//return participant with matching criteria
	public SequenceEngineWrapper checkExitCriteria(string participantType, List<SObject> participnatList, List<SObject> parentParticipantList, Map<Id, Cadence__c> sequenceMap)
	{
		SequenceEngineWrapper sequenceEngineWrapper = new SequenceEngineWrapper();
		sequenceEngineWrapper.participantList = SequenceEngineHelper.getParticipantsWithMatchingExitCriteria(participantType, participnatList, sequenceMap);
		 	
		return sequenceEngineWrapper;		
	}	
		
	public List<SObject> unAssociateParticipants(SequenceEngineWrapper sequenceEngineWrapper, string participantType)
    {
    	List<Participant_Sequence_History__c> newSequenceHistory = new List<Participant_Sequence_History__c>();
    	List<SObject> unAssociatedParticipantList = new List<Sobject>(); 
    	
    	for(SObject participant : sequenceEngineWrapper.participantList)
    	{
    		System.Debug('SequenceId: ' + (Id)participant.get(nameSpace+'Cadence_Id__c'));
    		Id sequenceId = (Id)participant.get(nameSpace+'Cadence_Id__c'); 
    		newSequenceHistory.add(SequenceEngineHelper.createHistoryObject(sequenceId, (Id)participant.get('Id'), participantType));          
            
    		participant.put(nameSpace+'Cadence_Id__c', null);
			participant.put(nameSpace+'isActivated__c', false);
			participant.put(nameSpace+'EntranceCriteria_Matched_Date__c', null);					
			unAssociatedParticipantList.add(participant); 
    	}
    	
    	if(newSequenceHistory != null && newSequenceHistory.size() > 0)
            insert newSequenceHistory;
            
    	if(unAssociatedParticipantList != null && unAssociatedParticipantList.size() > 0)
        {
        	update unAssociatedParticipantList;
        }
    	return unAssociatedParticipantList;
    }
		
	public Map<Id, List<SObject>> checkEntryCriteria(List<SObject> participantList, List<SObject> parentParticipantList, Map<Id, Cadence__c> sequenceIdToSequenceMap, Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap)
	{	
		Map<Id, List<SObject>> sequenceIdToParticipationListMap = new Map<Id, List<SObject>>();	
				
		Map<Id, CriterionSet> sequenceIdToSequenceCriteriasMap = RuleCriterionMatcherHelper.getCadenceWiseCriterions(sequenceIdToSequenceMap.values(), CadenceConstants.CRITERION_TYPE_ENTRY);
		Map<Id, CriterionSet> sequenceIdToExitSequenceCriteriasMap = RuleCriterionMatcherHelper.getCadenceWiseCriterions(sequenceIdToSequenceMap.values(), CadenceConstants.CRITERION_TYPE_EXIT);
		Boolean isCriterionMatches = false;
		for(SObject participant : participantList)
		{	
			if (participant.get(nameSpace+'Cadence_Id__c') != null ){
				continue;
			}
			
			for(Id sequenceId :  sequenceIdToSequenceMap.keySet())
			{	
				If(participantIdToSequenceIdHistorySetMap.containsKey(participant.Id) && participantIdToSequenceIdHistorySetMap.get(participant.Id).contains(sequenceId))
				{
				  continue;
				}
				
				If(RuleCriterionMatcherHelper.cadenceCriterionMatches(participant, null, sequenceIdToExitSequenceCriteriasMap.get(sequenceId), null))
				{
				  continue;
				}
				
				if(sequenceIdToSequenceCriteriasMap.containsKey(sequenceId))
				{	
					isCriterionMatches = RuleCriterionMatcherHelper.cadenceCriterionMatches(participant, null, sequenceIdToSequenceCriteriasMap.get(sequenceId), null);
					if(isCriterionMatches) {
						if(!sequenceIdToParticipationListMap.containsKey(sequenceId))
						{
							sequenceIdToParticipationListMap.put(sequenceId, new List<SObject>());
						}
						sequenceIdToParticipationListMap.get(sequenceId).add(participant);
						break;
					}				
				}				
			}
		}
		return sequenceIdToParticipationListMap;
	}
	
	public List<SObject> associateParticipant(Map<Id, List<SObject>> sequenceIdToParticipantListMap)
	{
		//system.assert(false,sequenceIdToParticipantListMap);
		List<SObject> lstParticipant = new List<SObject>();
		for(Id sequenceId : sequenceIdToParticipantListMap.keySet())
		{
			for(Lead lead : (List<Lead>)sequenceIdToParticipantListMap.get(sequenceId))
			{				
				lead.put(nameSpace+'Cadence_Id__c', sequenceId);
				lead.put(namespace+'isActivated__c', true);
				lead.put(namespace+'EntranceCriteria_Matched_Date__c', System.now());
				
				lstParticipant.add(lead);
			}
		}
		update lstParticipant;
		
		return lstParticipant;
	}
	
	public void createParticipantActions(List<SObject> participantListToCreateParticipantActions, Map<Id, Cadence__c> activeSequenceIdToSequenceMap)
	{
	    List<Sequence_Action__c> participantActionsToCreate = new List<Sequence_Action__c>();	
	    
		for(Lead lead : (List<Lead>) participantListToCreateParticipantActions)
		{	
			if(activeSequenceIdToSequenceMap.containsKey(lead.Cadence_Id__c))
			{
				//--to do to check execution Date calculation
				DateTime entranceDate = System.now();  //lead.EntranceCriteria_Matched_Date__c;
				Integer day = 0, hour = 0;
				//--to do to check end
				for(CadenceAction__c sequenceAction :  activeSequenceIdToSequenceMap.get(lead.Cadence_Id__c).CadenceActions__r)
				{
					Sequence_Action__c participantAction = new Sequence_Action__c();
					participantAction.Name = sequenceAction.Name;
					participantAction.CadenceAction_ID__c = sequenceAction.Id;
					//--to do to check execution Date calculation
					if(sequenceAction.Day__c != null) {
                    	day = day + (Integer)sequenceAction.Day__c;
	                }
	                if(sequenceAction.Hour__c != null) {
	                    hour = hour + (Integer)sequenceAction.Hour__c;
	                }	                
					participantAction.Expected_Execution_Date__c = CadenceUtil.addTimeInDate(entranceDate, day, hour);
					//--to do to check end
					participantAction.Lead_Id__c = lead.Id;
					
					participantActionsToCreate.add(participantAction);
				}		
			}	
		}				
		
        if(participantActionsToCreate != null && participantActionsToCreate.size()>0){
            insert participantActionsToCreate;	
        }
	}
	
	public Map<Id, List<Sequence_Action__c>> performParticipantActions(List<sObject> participantListToPerformParticipantAction, Map<Id, List<Sequence_Action__c>> participantIdToUnperformedParticipantActionsMap, Map<Id, Cadence__c> activeSequenceIdToSequenceMap, string participantType)
	{	
		//system.assert(false,participantListToPerformParticipantAction +' \n UnperformedParticipantActionsMap \n ' + participantIdToUnperformedParticipantActionsMap + ' \n Active Sequence Id \n ' + activeSequenceIdToSequenceMap );
		//Map<Id, List<Sequence_Action__c>> participantIdToSequenceActionsToPerformMap =  SequenceEngineHelper.getTopMostUnPerformedParticipantActions(participantListToPerformParticipantAction, participantIdToUnperformedParticipantActionsMap, null, activeSequenceIdToSequenceMap, participantType);
		//participantIdToUnperformedParticipantActionsMap = participantIdToSequenceActionsToPerformMap;		
		
		Map<Id, List<Sequence_Action__c>> participantIdToPerformedParticipantActionsMap = new Map<Id, List<Sequence_Action__c>>();	
		Map<Id, List<Sequence_Action__c>> participantIdToRemainingParticipantActionsMap = new Map<Id, List<Sequence_Action__c>>();	
        Map<Id, SObject> participantIdToParticipantMap = new Map<Id, SObject>(participantListToPerformParticipantAction);         
        List<Sequence_Action__c> participantActionToUpdate = new List<Sequence_Action__c>();
        List<Task> tasksToCreate = new List<Task>();
        List<Messaging.MassEmailMessage> emailsToSend = new List<Messaging.MassEmailMessage>();
        List<NativeEmailMessage> nativeEmailToSend = new List<NativeEmailMessage>();
        List<Id> emailTemplateIdList = new List<Id>();
        
        //Return if no unperformed participant actions 
        if(participantIdToUnperformedParticipantActionsMap == null || participantIdToUnperformedParticipantActionsMap.isEmpty()) {
            return participantIdToPerformedParticipantActionsMap;
        }         
        //Processing the data to perform 
        for(Id participantId : participantIdToUnperformedParticipantActionsMap.keySet()) {
        	if(!participantIdToUnperformedParticipantActionsMap.containsKey(participantId))
        	{
        		continue;
        	}
        	
        	Boolean performed = false, isTaskNotCompleted = false;
            for(Sequence_Action__c participationAction : participantIdToUnperformedParticipantActionsMap.get(participantId)) {
                performed = false;
                isTaskNotCompleted = false;
                if(participationAction.CadenceAction_Id__r.Action_Id__r.Activation_Type__c.equals(CadenceConstants.PARTICIPANT_ACTIVATION_AUTOMATIC)) {
                    //Processing email type of participant action
                    if(participationAction.CadenceAction_Id__r.Action_Id__r.Type__c != null && participationAction.CadenceAction_Id__r.Action_Id__r.Type__c.equals(CadenceConstants.ACTION_TYPE_EMAIL)) {
                        if(participantIdToParticipantMap.containsKey(participantId) && participantIdToParticipantMap.get(participantId).get('Email')!=null) {
                            String nativeMailTo = String.valueOf(participantIdToParticipantMap.get(participantId).get('Email'));
                            String nativeNameTo = String.valueOf(participantIdToParticipantMap.get(participantId).get('Name'));
                            String participantOwnerId = String.valueOf(participantIdToParticipantMap.get(participantId).get('OwnerId'));
                            Id userId = Id.valueOf(participantOwnerId);
                            if(participationAction.CadenceAction_Id__r.Action_Id__r.Email_Type__c != null && participationAction.CadenceAction_Id__r.Action_Id__r.Email_Type__c.equals(CadenceConstants.NATIVE_EMAIL_TYPE)){
                                nativeEmailToSend.add(SequenceEngineHelper.createNativeEmailMessage(nativeMailTo, participationAction.CadenceAction_Id__r.Action_Id__r.Template_Id__c, 
                                                                               participantId, participationAction.Id, nativeNameTo, userId));
                            }else{
                                emailsToSend.add(SequenceEngineHelper.createEmailMessage(participantId, participationAction.CadenceAction_Id__r.Action_Id__r.Template_Id__c));
                            }
                            tasksToCreate.add(SequenceEngineHelper.getEmailTask(participationAction.Id, participationAction.Name, participantId, participationAction.CadenceAction_Id__r.Action_Id__r.Template_Id__c));
                            performed = true;
                        } 
                    }
                } else {
            	   if(participationAction.CadenceAction_Id__r.Action_Id__r.Type__c.equals(CadenceConstants.ACTION_TYPE_TASK)) {
                        Task task = SequenceEngineHelper.performTaskAction(participantId, participationAction.CadenceAction_Id__r.Action_Id__r.Task_Description__c);
                        task.Sequence_Action__c = participationAction.Id; 
                        tasksToCreate.add(task);
                        if(task.Status == 'Completed'){
                            performed = true;   
                        }else{
                        	isTaskNotCompleted = true;
                        }                        
                    }
                    else{
                    	participationAction.Show_on_Target_List__c = true;
                		participantActionToUpdate.add(participationAction);    
                	}
                }
                
                if(performed) {
                    participationAction.Actual_Execution_Date__c = System.Now();
                    participationAction.isActionPerformed__c = true;
                    participantActionToUpdate.add(participationAction);
                    if(!participantIdToPerformedParticipantActionsMap.containsKey(participantId)) {
                       participantIdToPerformedParticipantActionsMap.put(participantId, new List<Sequence_Action__c>());
                    }
                    participantIdToPerformedParticipantActionsMap.get(participantId).add(participationAction);
                }
                else
                {
                	if(!participantIdToRemainingParticipantActionsMap.containsKey(participantId)) {
                       participantIdToRemainingParticipantActionsMap.put(participantId, new List<Sequence_Action__c>());
                    }
                    participantIdToRemainingParticipantActionsMap.get(participantId).add(participationAction);
                }
                
                if(isTaskNotCompleted) {
                    participationAction.Show_on_Target_List__c = true;
                    participationAction.isActionPerformed__c = false;
                    participantActionToUpdate.add(participationAction);                  
                }
        	}
        } 
        
        if(!nativeEmailToSend.isEmpty()) {
            List<Messaging.MassEmailMessage> failedNativeEmailList = SequenceEngineHelper.SendNativeEmail(nativeEmailToSend);
            if (!failedNativeEmailList.isEmpty()){
                emailsToSend.addAll(failedNativeEmailList);
            }
        }
        
        if(!emailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend, false);
        }
	    
        if(!tasksToCreate.isEmpty()) {
            if(System.isBatch()) {
                Database.SaveResult[] results = Database.insert(tasksToCreate, false);
            } else {
                String tasksJson = JSON.serialize(tasksToCreate); 
                SequenceEngineHelper.createTasks(tasksJson);
            }
        } 
	    
        if(!participantActionToUpdate.isEmpty()) {
            Database.update(participantActionToUpdate, false);
        } 
	    
	    updateRemainingParticipantAction(participantIdToPerformedParticipantActionsMap, participantIdToRemainingParticipantActionsMap);
	    
        return participantIdToPerformedParticipantActionsMap;        
	}
	
	public List<SObject> updateParticipantFields(List<sObject> participantListToPerformParticipantAction, Map<Id, List<Sequence_Action__c>> participantIdToPerformedParticipantActionsMap, List<SObject> parentParticipantList, string participantType, boolean isTrigger)
	{		
		//Returning if list is empty		
        if(participantIdToPerformedParticipantActionsMap == null || participantIdToPerformedParticipantActionsMap.isEmpty()) {
            return new List<SObject>();
        }     
                
        Map<Id, SObject> participantIdToParticipantMapToUpdate = new Map<Id, SObject>();
        Map<Id, SObject> participantIdToParticipantMap = new Map<Id, SObject>(participantListToPerformParticipantAction);
        List<Sequence_Action__c> participantActionList = new List<Sequence_Action__c>();
        
        //Getting fields map 
        Map<String, List<String>> fieldNameToDataTypeMap = SequenceEngineHelper.getObjectFieldsType(participantType);
        
        //Gettting participant action list 
        for(Id participantId : participantIdToPerformedParticipantActionsMap.keySet()) {
            participantActionList.addAll(participantIdToPerformedParticipantActionsMap.get(participantId));
        } 		               
        
        //Updating the obj fields 
        for(Sequence_Action__c participantAction : participantActionList) {
            String fieldsToUpdate = participantAction.CadenceAction_Id__r.Fields_To_Update_Action__c;
            if(fieldsToUpdate != null && !fieldsToUpdate.equals('')) {
                Map<String, Object> fieldMap = (Map<String, Object>)(JSON.deserializeUntyped(fieldsToUpdate));
                fieldMap.remove('sobjectType');
                Id leadId;
                if(participantAction.Lead_Id__c != null) {
                    leadId = participantAction.Lead_Id__c;
                }
                
                Object valuesToUpdate = '';
				SObject participantWithUpdatedFieldsValues = participantIdToParticipantMap.get(leadId);
                for(String fieldName : fieldMap.keySet()) {
                    List<String> apiList;                    
                    apiList = fieldNameToDataTypeMap.get(fieldName);
                    valuesToUpdate = SequenceEngineHelper.GetUpdateValue(fieldMap.get(fieldName), apiList[1],valuesToUpdate);
					SequenceEngineHelper.updateFieldValue(participantIdToParticipantMap.get(leadId), apiList[0], valuesToUpdate, apiList[1]);
                    participantWithUpdatedFieldsValues = SequenceEngineHelper.updateFieldValue(participantWithUpdatedFieldsValues, apiList[0], fieldMap.get(fieldName), apiList[1]);  //need to move                    
                }
                participantIdToParticipantMapToUpdate.put(leadId, participantWithUpdatedFieldsValues);					
            }
        }        
        return participantIdToParticipantMapToUpdate.values();
	}
	
	public void updateParticipants(List<SObject> participantListToUpdateFields)
	{	
		 if(participantListToUpdateFields != null && participantListToUpdateFields.size() > 0) {                    
               Database.SaveResult[] results = Database.update(participantListToUpdateFields, false); 
          }
	}	
	
	// private methods
		
	private void updateRemainingParticipantAction(Map<Id, List<Sequence_Action__c>> participantIdToPerformedParticipantActionsMap, Map<Id, List<Sequence_Action__c>> participantIdToRemainingParticipantActionsMap){
        //Updating dates on remaining participant objects 
        List<Sequence_Action__c> sequenceActionToUpdate = new List<Sequence_Action__c>();
        for(Id objId : participantIdToPerformedParticipantActionsMap.keySet()) {
            for(Sequence_Action__c sequenceAction : participantIdToPerformedParticipantActionsMap.get(objId)) { 
                Id partId = sequenceAction.Lead_Id__c == null ? sequenceAction.Contact_Id__c : sequenceAction.Lead_Id__c; 
                sequenceActionToUpdate.addAll(updateActionOnParticipantExpectedDate(sequenceAction.Actual_Execution_Date__c, (Integer)sequenceAction.CadenceAction_Id__r.Index__c, participantIdToPerformedParticipantActionsMap.get(partId)));
            }
        }
       
        if(!sequenceActionToUpdate.isEmpty()) {
            update sequenceActionToUpdate;
        }
    }	
	 
	private List<Sequence_Action__c> updateActionOnParticipantExpectedDate(DateTime lastExecutionDate, Integer index, List<Sequence_Action__c> updateActions) {
        List<Sequence_Action__c> sequenceActionToUpdate = new List<Sequence_Action__c>();
        Integer day = 0, hour = 0;
        DateTime executionDate = lastExecutionDate,nextDate;
        if(lastExecutionDate == null)
        {
        	return sequenceActionToUpdate;
        }
        if(updateActions == null) {
            return sequenceActionToUpdate;
        }
        for(Sequence_Action__c sequenceAction : updateActions) {
            if(sequenceAction.Actual_Execution_Date__c == null && sequenceAction.isActionPerformed__c == false && sequenceAction.CadenceAction_Id__r.Index__c > index) {
                if(sequenceAction.CadenceAction_ID__r.Day__c != null) {
                    day = day + (Integer)sequenceAction.CadenceAction_ID__r.Day__c;
                }
                if(sequenceAction.CadenceAction_ID__r.Hour__c != null) {
                    hour = hour + (Integer)sequenceAction.CadenceAction_ID__r.Hour__c;
                }
                nextDate = CadenceUtil.addTimeInDate(executionDate, day, hour);
                sequenceAction.Expected_Execution_Date__c = nextDate;
                sequenceActionToUpdate.add(sequenceAction);
            }	    
        }
        return sequenceActionToUpdate;
    }
}