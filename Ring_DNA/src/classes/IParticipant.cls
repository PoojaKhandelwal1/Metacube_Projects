public interface IParticipant {
        
	SequenceEngineWrapper checkExitCriteria(string participantType, List<SObject> participnatList, List<SObject> parentParticipantList, Map<Id, Cadence__c> sequenceMap);
				 
	Map<Id, List<SObject>> checkEntryCriteria(List<SObject> participnatList, List<SObject> parentParticipantList, Map<Id, Cadence__c> sequenceIdToSequenceMap,  Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap);
	 
	List<SObject> associateParticipant(Map<Id, List<SObject>> sequenceIdToParticipantListMap); 
	
	List<SObject> unAssociateParticipants(SequenceEngineWrapper sequenceEngineWrapper, string participantType);
	
	Map<Id, Set<Id>> getSequenceHistory(); 
	
	void createParticipantActions(List<SObject> participantListToCreateParticipantActions, Map<Id, Cadence__c> sequenceIdToSequenceMap);
	
	Map<Id, List<Sequence_Action__c>> performParticipantActions(List<sObject> participantListToPerformParticipantAction, Map<Id, List<Sequence_Action__c>> participantIdToUnperformedParticipantActionsMap, Map<Id, Cadence__c> activeSequenceIdToSequenceMap, string participantType);
	
	List<SObject> updateParticipantFields(List<sObject> participantListToPerformParticipantAction, Map<Id, List<Sequence_Action__c>> participantIdToPerformedParticipantActionsMap, List<SObject> parentParticipantList, string participantType, boolean isTrigger);
	
	void updateParticipants(List<SObject> participantListToPerformParticipantAction, List<SObject> participantListToUpdate, boolean isTrigger);
	
}