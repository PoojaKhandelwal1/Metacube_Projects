/**
 * Author: Pooja Khandelwal
 * Since: May. 15, 2019
 * Name: AssociateParticipantsBatchService
 * Description: Service class for AssociateParticipantsBatch - It will Associate participants to any sequnce - In case if (total number participants to be associated to sequence > max size)
**/
public class AssociateParticipantsBatchService {
	static Integer MAX_RECORDS_UPDATE_LIMIT = 9900; 
	
    public static void associateParticipantsToSequence(Id sequenceId, Map<Id, Cadence__c> sequenceIdToSequenceMap, List<SObject> participantList, List<SObject> participantListToUpdate, String sequenceRecordType) {
		
		Map<Id, List<CadenceAction__c>> particiapntIdToSequenceActionListMap = new Map<Id, List<CadenceAction__c>>();
		
		for(SObject participant : participantList) {
			// to do - Can use code mehtod of participant service to only set fields for participants association (eg: LeadService.associateParticipant())
			participant.put(CadenceConstants.NAMESPACE+'Cadence_Id__c', sequenceIdToSequenceMap.get(sequenceId).Id);
			if(sequenceIdToSequenceMap.get(sequenceId).Participent_Activation__c.equalsIgnoreCase(CadenceConstants.PARTICIPANT_ACTIVATION_AUTOMATIC)) {
				participant.put(CadenceConstants.NAMESPACE+'isActivated__c', true);
				participant.put(CadenceConstants.NAMESPACE+'EntranceCriteria_Matched_Date__c', System.now());
			} else {
				participant.put(CadenceConstants.NAMESPACE+'isActivated__c', false);
			}
			participantListToUpdate.add(participant);
		}
		
		if(participantListToUpdate !=  null && participantListToUpdate.size() < 9900) {
			SequenceEngineService.disableParticipantTrigger(sequenceRecordType);
			Database.update(participantListToUpdate, false);
			SequenceEngineService.enableParticipantTrigger(); 
			
			participantListToUpdate = new List<SObject>();
		} 
	}
}