/**
 * Author: Pooja Khandelwal
 * Since: May. 15, 2019
 * Name: SequenceEngineService
 * Description: Service class for Sequence related operations
**/
public class SequenceEngineService {
    /**
    * Name: activateSequences
    * Desc: Method to activate sequences and then assign this sequence id to all participants (which matches criteria) 
    * @param:  (1) sequenceIdList - List<Id> - List of sequence ids to activate
    * @return: 
    **/
    public static void activateSequences(List<Id> sequenceIdList) {
		if(sequenceIdList == null || sequenceIdList.size() == 0) {
			return;
		}
		
		// Start: Sequence activation
		List<Cadence__c> sequenceListToUpdate = new List<Cadence__c>();
		for(Id sequenceId: sequenceIdList) {
			sequenceListToUpdate.add(new Cadence__c(Id = sequenceId, Status__c = true));
		}
		update sequenceListToUpdate;
		// End: Sequence activation
		
		// Start: Participants Association to sequence
		if(sequenceIdList.size() == 1) {
			associateParticipantsToSequence(sequenceIdList[0]);
		} else {
			associateParticipantsToSequences(sequenceIdList);
		}
		// Start: Participants Association to sequence
	}
	
	/**
    * Name: associateParticipantsToSequence
    * Desc: Method to associate participants using multiple sequence (which matches criteria) 
    * @param:  (1) sequenceId - Id - Id of sequence for which we have to associate participants
    * @return: 
    **/
	public static void associateParticipantsToSequence(Id sequenceId) {
		Map<Id, Cadence__c> sequenceIdToSequenceMap = SequenceEngineHelper.getActiveSequenceIdToSequenceMapByFieldValue(new Map<String, Set<String>>{'Id' => new Set<String>{sequenceId}});
		
		if(!sequenceIdToSequenceMap.containsKey(sequenceId)) {
			return;
		}
		
		String sequenceRecordType = sequenceIdToSequenceMap.get(sequenceId).Record_Type__c;
		String query;
		
		if(!sequenceRecordType.equalsIgnoreCase(CadenceConstants.OPPORTUNITY_OBJECT_NAME)) { // Handling for Contact and Lead
			query = formParticipantSelectQuery(sequenceRecordType, sequenceIdToSequenceMap.get(sequenceId));
		}
		else{ // Handling for Opportunity
			//query = formQueryOpportunity(objName,cadence);
		}
		
		List<SObject> participantListToUpdate = new List<SObject>();
		Map<Id, List<CadenceAction__c>> particiapntIdToSequenceActionListMap = new Map<Id, List<CadenceAction__c>>();
		
		// Set required association fields on participants
		for(SObject participant : Database.query(query + ' order by lastmodifieddate')) {
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
		
		// If limited records are there to update then directly update them, else run batch to process to all records to associate them 
		if(participantListToUpdate !=  null && participantListToUpdate.size() > 0 && participantListToUpdate.size() < SequenceEngineHelper.getAvailableDMLRowsLimit()) {
			disableParticipantTrigger(sequenceRecordType);
			Database.SaveResult[] saveResults = Database.update(participantListToUpdate, false);
			enableParticipantTrigger();
		} else if(participantListToUpdate !=  null && participantListToUpdate.size() > 0 && participantListToUpdate.size() >= SequenceEngineHelper.getAvailableDMLRowsLimit()) {
			AssociateParticipantsBatch associateParticipantsBatch = new AssociateParticipantsBatch(sequenceId); 
			Database.executeBatch(associateParticipantsBatch, 200);
		}
	}
	
	/**
    * Name: associateParticipantsToSequences
    * Desc: Method to associate participants using multiple sequence (which matches criteria) 
    * @param:  (1) sequenceIdList - List<Id> - Ids of sequences for which we have to associate participants
    * @return: 
    **/
    public static void associateParticipantsToSequences(List<Id> sequenceIdList) {
    	// to do - Handling for multiple sequences	
	}
	
	
	// to do - move to util - used here and in batch
	/**
    * Name: formParticipantSelectQuery
    * Desc: Method to create select query for participants with all entry and exit matching criteria where clause  
    * @param:  (1) objectName - String - Record type on sequence (Object name in org) - Lead/Contact - for which we have to query records
    		   (2) sequence - Cadence__c - Sequence record for which we have to associate participants
    * @return: query  - String - Participant select query includes all entry and exit matching criteria in where clause
    **/
	public Static String formParticipantSelectQuery(String objectName, Cadence__c sequence) {
		String query = 'Select Cadence_ID__c,isActivated__c,EntranceCriteria_Matched_Date__c from '+ objectName +' Where (Cadence_ID__c = null) AND ';
		
		Map<Id, CriterionSet> sequenceIdToEntryCriteriaSetMap =  new Map<Id, CriterionSet>();
		Map<Id, CriterionSet> sequenceIdToExitCriteriaSetMap =  new Map<Id, CriterionSet>();
	
		if(sequence != null) {
			sequenceIdToEntryCriteriaSetMap = RuleCriterionMatcherHelper.getCadenceWiseCriterions(new List<Cadence__c>{sequence}, CadenceConstants.CRITERION_TYPE_ENTRY);
			sequenceIdToExitCriteriaSetMap = RuleCriterionMatcherHelper.getCadenceWiseCriterions(new List<Cadence__c>{sequence}, CadenceConstants.CRITERION_TYPE_EXIT);

			// Filter condition for entry criteria - Participant should match sequence entry criteria 
			if(sequenceIdToEntryCriteriaSetMap.keyset().size() > 0) {
				query = query+ '(('+CadenceController.criteriaFilters(sequenceIdToEntryCriteriaSetMap,sequence,true)+')';
			}
				
			// Filter condition for exit criteria - Participant should not match sequence exit criteria 
			if(sequenceIdToExitCriteriaSetMap.keyset().size() > 0) {
				query = query+ +' AND (NOT('+CadenceController.criteriaFilters(sequenceIdToExitCriteriaSetMap,sequence,false) +')))';
			}
		}
		return removeBraces(query);
	}
	
	// to do - can move to util
	public Static void disableParticipantTrigger(String sequenceRecordType) {
		Contacts.fireTrigger = (sequenceRecordType == CadenceConstants.CONTACT_OBJECT_NAME) ? false : true;
		Leads.fireTrigger = (sequenceRecordType == CadenceConstants.LEAD_OBJECT_NAME) ? false : true;
	}
	
	// to do - can move to util
	public Static void enableParticipantTrigger() {
		Contacts.fireTrigger = true;
		Leads.fireTrigger = true;
	}
	
	// to do - move to util
	private Static string removeBraces(string query) {
        Integer open,close ;
        open = query.countMatches('(');
        close = query.countMatches(')');
        if(close > open	)
            query = query.removeEnd(')');
        
        return query;
    }
}