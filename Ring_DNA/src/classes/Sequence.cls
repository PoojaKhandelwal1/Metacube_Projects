public class Sequence {
	@AuraEnabled public Id id {get; set;}
	@AuraEnabled public string entranceCriteria {get; set;}
	@AuraEnabled public string entranceCriteriaPE {get; set;}
	@AuraEnabled public string exitCriteria {get; set;}
	@AuraEnabled public string exitCriteriaPE {get; set;}
	@AuraEnabled public string matchingPriority {get; set;}
	@AuraEnabled public string name {get; set;}
	@AuraEnabled public string participentActivation {get; set;}
	@AuraEnabled public string recordType {get; set;}
	@AuraEnabled public string status {get; set;}
	@AuraEnabled public string totalParticipants {get; set;} 
	@AuraEnabled public List<SequenceAction> cadenceActions  {get; set;}

	public Sequence (){

	}

	public Sequence (Id sequenceId, string sequenceEntranceCriteria, string sequenceEntranceCriteriaPE, string sequenceExitCriteria, 
			string sequenceExitCriteriaPE, string sequenceMatchingPriority, string sequenceName, string  sequenceParticipentActivation,
			string sequenceRecordType, string sequenceStatus, string sequenceTotalParticipants){
		id = sequenceId;
		entranceCriteria = sequenceEntranceCriteria;
		entranceCriteriaPE = sequenceEntranceCriteriaPE;
		exitCriteria = sequenceExitCriteria;
		exitCriteriaPE = sequenceExitCriteriaPE;
		matchingPriority = sequenceMatchingPriority;
		name = sequenceName;
		participentActivation = sequenceParticipentActivation;
		recordType = sequenceRecordType;
		status = sequenceStatus;
		totalParticipants = sequenceTotalParticipants;
	}
}