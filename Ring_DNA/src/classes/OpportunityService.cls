public class OpportunityService implements IParticipant {
	  
    public static String nameSpace = CadenceConstants.NAMESPACE;
        
    public Map<Id, Set<Id>> getSequenceHistory()  
    {    	
    	Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap = new Map<Id, Set<Id>>();
    	for(Participant_Sequence_History__c participantSequenceHistory : [SELECT Contact_Id__c, Sequence_Id__c FROM Participant_Sequence_History__c WHERE Contact_Id__c != null]) {
           
           if(!participantIdToSequenceIdHistorySetMap.containsKey(participantSequenceHistory.Contact_Id__c))
           {
           	  participantIdToSequenceIdHistorySetMap.put(participantSequenceHistory.Contact_Id__c, new Set<Id>());
           }                       
           participantIdToSequenceIdHistorySetMap.get(participantSequenceHistory.Contact_Id__c).add(participantSequenceHistory.Sequence_Id__c);             
        }  
    	return participantIdToSequenceIdHistorySetMap;  	
    }
    
  	//return participant with matching criteria
	public SequenceEngineWrapper checkExitCriteria(string participantType, List<SObject> participnatList, List<SObject> opportunityList, Map<Id, Cadence__c> sequenceMap)
	{	
		SequenceEngineWrapper sequenceEngineWrapper = new SequenceEngineWrapper();
		sequenceEngineWrapper.parentParticipantList = SequenceEngineHelper.getParticipantsWithMatchingExitCriteria(participantType, opportunityList, sequenceMap);
		sequenceEngineWrapper.participantList = participnatList;
		return sequenceEngineWrapper;	
	}	
		
	public static List<SObject> unAssociateParticipants(SequenceEngineWrapper sequenceEngineWrapper, string participantType)
    {    	
    	List<Participant_Sequence_History__c> newSequenceHistory = new List<Participant_Sequence_History__c>();
    	List<SObject> unAssociatedParticipantList = new List<Sobject>(); 
    	List<SObject> unAssociatedParentParticipantList = new List<Sobject>(); 
    	
    	Map<Id, Sobject> opportunityIdToOpportunityMap = new Map<Id, SObject>(sequenceEngineWrapper.parentParticipantList);
    	Map<Id, Sobject> contactIdToContactMap = new Map<Id, SObject>(sequenceEngineWrapper.participantList);
    	
    	List<SObject> contractRoleListForOppertunityList = getContactRoleListFromOpportunityList(sequenceEngineWrapper.parentParticipantList);
    	
    	for(SObject contactRole : contractRoleListForOppertunityList)
    	{
    		Id opportunityId = (Id)contactRole.get(nameSpace+'OpportunityId');
    		Id contactId = (Id)contactRole.get(nameSpace+'ContactId');
    		
    		SObject contact = contactIdToContactMap.get(contactId);
    		Id sequenceId = (Id)contact.get(nameSpace+'Cadence_Id__c'); 
    		newSequenceHistory.add(SequenceEngineHelper.createHistoryObject(sequenceId, (Id)contact.get('Id'), participantType));  
    		
    		contact.put(nameSpace+'Cadence_Id__c', null);
			contact.put(nameSpace+'isActivated__c', false);
			contact.put(nameSpace+'EntranceCriteria_Matched_Date__c', null);
    		unAssociatedParticipantList.add(contact); 
    		
    		SObject opportunity = opportunityIdToOpportunityMap.get(opportunityId);
    		opportunity.put(nameSpace+'Cadence_Id__c', null);  
    		unAssociatedParentParticipantList.add(opportunity);
    	}
    	
    	if(newSequenceHistory != null && newSequenceHistory.size() > 0)
    	{
            insert newSequenceHistory;
    	}
        if(unAssociatedParentParticipantList != null && unAssociatedParentParticipantList.size() > 0)
        {
        	update unAssociatedParentParticipantList;
        }
    
    	return unAssociatedParticipantList;
    }
		
	public Map<Id, List<SObject>> checkEntryCriteria(List<SObject> participantList, List<SObject> opportunityList, Map<Id, Cadence__c> sequenceIdToSequenceMap, Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap)
	{
		Map<Id, List<SObject>> sequenceIdToParticipationListMap = new Map<Id, List<SObject>>();
		RuleCriteriaMatcherDataSets ruleCriteriaMatcherDataSet = new RuleCriteriaMatcherDataSets();		
		Map<Id, Sobject> participantIdWithParticipantMap = new Map<Id, SObject>(participantList);		
		List<SObject> matchedOpportunityToUpdate = new List<SObject>();
			
		Map<Id, CriterionSet> sequenceIdToSequenceCriteriasMap = RuleCriterionMatcherHelper.getCadenceWiseCriterions(sequenceIdToSequenceMap.values(), CadenceConstants.CRITERION_TYPE_ENTRY);
		Map<Id, CriterionSet> sequenceIdToExitSequenceCriteriasMap = RuleCriterionMatcherHelper.getCadenceWiseCriterions(sequenceIdToSequenceMap.values(), CadenceConstants.CRITERION_TYPE_EXIT);
		Boolean isCriterionMatches = false; 
		
		for(SObject opportunity : opportunityList)
		{
			for(Id sequenceId : sequenceIdToSequenceMap.keySet())
			{
				If(participantIdToSequenceIdHistorySetMap.containsKey(opportunity.Id) && participantIdToSequenceIdHistorySetMap.get(opportunity.Id).contains(sequenceId))
				{
				  continue; 
				}
				
				If(RuleCriterionMatcherHelper.cadenceCriterionMatches(opportunity, null, sequenceIdToExitSequenceCriteriasMap.get(sequenceId), null))
				{
				  continue;
				}
				
				if(sequenceIdToSequenceCriteriasMap.containsKey(sequenceId))
				{
					isCriterionMatches = RuleCriterionMatcherHelper.cadenceCriterionMatches(opportunity, null, sequenceIdToSequenceCriteriasMap.get(sequenceId), ruleCriteriaMatcherDataSet);
					if(isCriterionMatches) {
						List<SObject> matchedContactsToUpdateList = new List<Sobject>();	
						Set<String> matchedRolesForOpportunity = ruleCriteriaMatcherDataSet.opportunityIdwithMatchedContactRoleIds.get(opportunity.Id);
						for(OpportunityContactRole opportunityContactRole : ((Opportunity)opportunity).getSObjects('OpportunityContactRoles'))
						{								
							if(matchedRolesForOpportunity.contains(opportunityContactRole.Id))
							{
								Contact contact = new Contact(id=opportunityContactRole.ContactId);
								contact.Opportunity_Id__c =	opportunity.Id;							
	                            matchedContactsToUpdateList.add(contact);
	                                
	                            opportunity.put(nameSpace+'Cadence_Id__c', sequenceId); 
	                            matchedOpportunityToUpdate.add(opportunity);
							}												
						} 							
						if(!sequenceIdToParticipationListMap.containsKey(sequenceId))
						{
							sequenceIdToParticipationListMap.put(sequenceId, new List<SObject>());
						}
						sequenceIdToParticipationListMap.get(sequenceId).addAll(matchedContactsToUpdateList);
						break;
					}				
				}				
			}
		}		
		
		if(matchedOpportunityToUpdate != null && matchedOpportunityToUpdate.size() > 0)
		{
			update matchedOpportunityToUpdate;
		}		
		return sequenceIdToParticipationListMap;
	}

	public List<SObject> associateParticipant(Map<Id, List<SObject>> sequenceIdToParticipantListMap)
	{		
		List<SObject> lstParticipant = new List<SObject>();
		for(Id sequenceId : sequenceIdToParticipantListMap.keySet())
		{			
			for(Contact contact : (List<Contact>)sequenceIdToParticipantListMap.get(sequenceId))
			{		
				System.debug('contact_opp_Id' + contact.Opportunity_Id__c);		
				contact.put(nameSpace+'Cadence_Id__c', sequenceId);
				contact.put(namespace+'isActivated__c', true);
				contact.put(namespace+'EntranceCriteria_Matched_Date__c', System.now());
				
				lstParticipant.add(contact);
			}
		}
		update lstParticipant;
		
		return lstParticipant;
	}
	
	public void createParticipantActions(List<SObject> participantListToCreateParticipantActions, Map<Id, Cadence__c> activeSequenceIdToSequenceMap)
	{
	    List<Sequence_Action__c> participantActionsToCreate = new List<Sequence_Action__c>();	
	    
		for(Contact contact : (List<Contact>) participantListToCreateParticipantActions)
		{	
			if(activeSequenceIdToSequenceMap.containsKey(contact.Cadence_Id__c))
			{
				//--to do to check execution Date calculation
				DateTime entranceDate = System.now();
				Integer day = 0, hour = 0;
				//--to do to check end
				for(CadenceAction__c sequenceAction :  activeSequenceIdToSequenceMap.get(contact.Cadence_Id__c).CadenceActions__r)
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
					participantAction.contact_Id__c = contact.Id;
					
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
	
	public List<SObject> updateParticipantFields(List<sObject> participantListToPerformParticipantAction, Map<Id, List<Sequence_Action__c>> participantIdToPerformedParticipantActionsMap, List<SObject> opportunityList, string participantType, boolean isTrigger)
	{		
		//Returning if list is empty		
        if(participantIdToPerformedParticipantActionsMap == null || participantIdToPerformedParticipantActionsMap.isEmpty()) {
            return new List<SObject>();
        }    
                
        Map<Id, SObject> participantIdToParticipantMapToUpdate = new Map<Id, SObject>();
        Map<Id, SObject> opportunityIdToOpportunityMap = new Map<Id, SObject>();
        List<Sequence_Action__c> participantActionList = new List<Sequence_Action__c>();
        Map<Id, Id> contactIdToOpportunityIdMap = new Map<Id, Id>();
       
        List<SObject> contactRoleList = getContactRoleListFromOpportunityList(opportunityList);
        for(OpportunityContactRole contactRole : (List<OpportunityContactRole>)contactRoleList)
        {
        	contactIdToOpportunityIdMap.put(contactRole.ContactId, contactRole.OpportunityId);
        }
        
        //Getting fields map 
        Map<String, List<String>> fieldNameToDataTypeMap = SequenceEngineHelper.getObjectFieldsType(participantType);
        System.debug('opportunityList:' + opportunityList);
        opportunityIdToOpportunityMap = new Map<Id, SObject>(opportunityList);
        
        //Gettting participant action list 
        for(Id participantId : participantIdToPerformedParticipantActionsMap.keySet()) {
            participantActionList.addAll(participantIdToPerformedParticipantActionsMap.get(participantId));
        } 	
      
        //Updating the participant fields 
        for(Sequence_Action__c participantAction : participantActionList) {
            String fieldsToUpdate = participantAction.CadenceAction_Id__r.Fields_To_Update_Action__c;
            if(fieldsToUpdate != null && !fieldsToUpdate.equals('')) {
                Map<String, Object> fieldMap = (Map<String, Object>)(JSON.deserializeUntyped(fieldsToUpdate));
                fieldMap.remove('sobjectType');
                Id opportunityId = contactIdToOpportunityIdMap.get(participantAction.Contact_Id__c);                
                system.debug('opportunityId ' + opportunityId);
                Object valuesToUpdate = '';
				SObject participantWithUpdatedFieldsValues = opportunityIdToOpportunityMap.get(opportunityId);
                for(String fieldName : fieldMap.keySet()) {
                    List<String> apiList;                    
                    apiList = fieldNameToDataTypeMap.get(fieldName);
                    valuesToUpdate = SequenceEngineHelper.GetUpdateValue(fieldMap.get(fieldName), apiList[1],valuesToUpdate);   
                    System.debug('participantWithUpdatedFieldsValues:' + participantWithUpdatedFieldsValues);                 
					participantWithUpdatedFieldsValues = SequenceEngineHelper.updateFieldValue(participantWithUpdatedFieldsValues, apiList[0], valuesToUpdate, apiList[1]);                    
                }
                participantIdToParticipantMapToUpdate.put(opportunityId, participantWithUpdatedFieldsValues);					
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
    
    //private methods
    private static List<SObject> getContactRoleListFromOpportunityList(List<SObject> opportunityList)
    {
    	List<SObject> contactRoleList = new List<Sobject>();    
    	for(SObject opportunity : opportunityList)
    	{    	
    		contactRoleList.addAll(((Opportunity)opportunity).getSObjects('OpportunityContactRoles'));
    	}
    	return contactRoleList;
    }
}