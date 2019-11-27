public interface IPatricipant {
	
	Map<Id, SObject> getParticipantIdToParentRecordMap(List<SObject> participantList);
	
	Map<Id, Cadence__c> getActiveSequences(String objectType, List<SObject> participantList);
	
	List<SObject> checkExitCriteria(string participantType, List<SObject> participnatList, Map<Id, Cadence__c> sequenceMap, List<string> participantTypeAndParantGroupsList);
	
	//List<SObject> checkExitCriteria(List<SObject> participantList);	
	
	//Maps SequenceId to list of participant 	
	Map<Id, List<SObject>> checkEntryCriteria(List<SObject> participnatList, Map<Id, Cadence__c> sequenceIdToSequenceMap, Map<Id, SObject> participantIdToParentRecordMap);
	
	List<SObject> associateParticipant(Map<Id, List<SObject>> sequenceIdToParticipantListMap, Map<Id, Set<Id>> participantIdToSequenceIdSetMap);
	
	List<SObject> unAssociateParticipants(List<SObject> participantList, string participantType);
	
	Map<Id, Set<Id>> getSequenceHistory();
	
	void createParticipantActions(List<SObject> participnatList, Map<Id, Cadence__c> sequenceIdToSequenceMap);//Map<Id, List<Id>> participantIdToSequenceActionIdListMap
	
	//List<SObject> objList, Map<Id, List<Sequence_Action__c>> partActionsMap
	Map<Id, List<Sequence_Action__c>> performParticipantActions(List<sObject> participantList, Map<Id, List<Sequence_Action__c>> participantIdToParticipantActionsMap);
	
	void updateSObjectFields(List<sObject> participantList, Map<Id, List<Sequence_Action__c>> participantIdToPerformedParticipantActionsMap, string participantType, boolean isTrigger);
	
}