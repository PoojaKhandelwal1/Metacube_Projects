public class SequenceEngine { 
	  
	public static void processSequences(string participantType, List<SObject> participantList, List<SObject> parentParticipantList, boolean isTrigger)
	{
        SequenceEngineService.disableParticipantTrigger(participantType);
		SequenceEngineWrapper sequenceEngineWrapper = new SequenceEngineWrapper();
		
		//Created a factory map using all participant types.
		Map<String, Type> sequenceEngineFactory = new Map<String, Type> {CadenceConstants.CONTACT_OBJECT_NAME => ContactService.class, CadenceConstants.LEAD_OBJECT_NAME => LeadService.class, CadenceConstants.OPPORTUNITY_OBJECT_NAME => OpportunityService.class };
		
		//Initiation of service class	
		IParticipant participantService = (IParticipant)sequenceEngineFactory.get(participantType).newInstance();
		 
		//Fetch all the Active sequences 
		Map<Id, Cadence__c> activeSequenceIdToSequenceMap  = SequenceEngineHelper.getActiveSequenceIdToSequenceMap(new List<String> {participantType}); 
		
		//Fetch participant list which have exit criteria matched in sequence(further those participant will be unassociated.)
		//List<SObject> participantOrParentParticipantListWithMatchedCriteria = participantService.checkExitCriteria(participantType, participantList, parentParticipantList, activeSequenceIdToSequenceMap);
		sequenceEngineWrapper = participantService.checkExitCriteria(participantType, participantList, parentParticipantList, activeSequenceIdToSequenceMap);
		
		List<SObject> unAssociatedParticipantList = new List<SObject>();
			
		If(sequenceEngineWrapper.participantList != null && sequenceEngineWrapper.participantList.size() > 0)	
		{ 
			unAssociatedParticipantList = participantService.unAssociateParticipants(sequenceEngineWrapper, participantType);					
			SequenceEngineHelper.deleteUnPerformedParticipantActions(unAssociatedParticipantList);
		}
		
		List<SObject> participantListToCreateParticipantActions = new List<SObject>();
		List<SObject> participantListToPerformParticipantAction = new List<SObject>();
       
		if (isTrigger) {
		     Map<String, List<SObject>> filteredParticipantListsMap = SequenceEngineHelper.getFilteredParticipantListsBySequnce(participantList);
			 List<SObject> participantListWithSequence = filteredParticipantListsMap.get('participantListWithSequence');
        	 List<SObject> participantListWithoutSequence = filteredParticipantListsMap.get('participantListWithoutSequence');
        
			 Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap = participantService.getSequenceHistory(); 
			 
			 Map<Id, List<SObject>> sequenceIdToParticipantListMap = participantService.checkEntryCriteria(participantListWithoutSequence, parentParticipantList, activeSequenceIdToSequenceMap, participantIdToSequenceIdHistorySetMap);
			 participantListToCreateParticipantActions = participantService.associateParticipant(sequenceIdToParticipantListMap);
			 participantListWithSequence.addAll(participantListToCreateParticipantActions); 
			 participantListToPerformParticipantAction = participantListWithSequence;		 
		}
		else {
		     participantListToPerformParticipantAction = SequenceEngineHelper.removeChildListItemsFromParentList(participantList, unAssociatedParticipantList);		
		     participantListToCreateParticipantActions = SequenceEngineHelper.getParticipantListToCreateParticipantActions(participantListToPerformParticipantAction, activeSequenceIdToSequenceMap, participantType);	   
		}
			
		participantService.createParticipantActions(participantListToCreateParticipantActions, activeSequenceIdToSequenceMap);
		
		Map<Id, List<Sequence_Action__c>> participantIdToUnperformedParticipantActionsMap = SequenceEngineHelper.getUnPerformedParticipantActions(participantListToPerformParticipantAction, participantType);
		system.debug('participantIdToUnperformedParticipantActionsMap ' + participantIdToUnperformedParticipantActionsMap);
		Map<Id, List<Sequence_Action__c>> participantIdToPerformedParticipantActionsMap = participantService.performParticipantActions(participantListToPerformParticipantAction, participantIdToUnperformedParticipantActionsMap, activeSequenceIdToSequenceMap, participantType);
		system.debug('participantIdToPerformedParticipantActionsMap ' + participantIdToPerformedParticipantActionsMap);
		List<SObject> participantListToUpdate = participantService.updateParticipantFields(participantListToPerformParticipantAction, participantIdToPerformedParticipantActionsMap, parentParticipantList, participantType, isTrigger);
		
		participantService.updateParticipants(participantListToUpdate);
	}     
}