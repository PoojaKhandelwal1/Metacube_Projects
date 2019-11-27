public class Sequences extends SObjectDomain {
    List<Cadence__c> sequenceNewList;
    
    public Sequences(List<Cadence__c> sequenceNewList) { 
        super(sequenceNewList);
        this.sequenceNewList = (List<Cadence__c>)sequenceNewList;
    }
    
    public class Constructor implements SObjectDomain.IConstructable {
        public SObjectDomain construct(List<SObject> sObjectList) {
            return new Sequences(sObjectList);
        }
    }
    
    //public override void onBeforeInsert() {} 

	//public override void onAfterInsert() {}

	//public override void onbeforeUpdate(Map<Id,SObject> sequenceOldMap){}
	
	public override void onAfterUpdate(Map<Id, SObject> sequenceOldMap) {
		associateCriteriaMatchedParticipantsToSequence(sequenceOldMap);
 	}
 	
 	private void associateCriteriaMatchedParticipantsToSequence(Map<Id, SObject> sequenceOldMap){
 		Set<Id> sequenceIdSet = new Set<Id>();
		for(Cadence__c sequence : sequenceNewList) {
			if(sequence.Entrance_Criteria__c != (String)sequenceOldMap.get(sequence.Id).get(CadenceConstants.NAMESPACE+'Entrance_Criteria__c')) { 
				sequenceIdSet.add(sequence.Id);
			} 
		}
		
		// Start: Participants Association to sequence
		if(sequenceIdSet.size() > 0) {
			if(sequenceIdSet.size() == 1) {
				SequenceEngineService.associateParticipantsToSequence(new List<Id>(sequenceIdSet)[0]);
			} else {
				SequenceEngineService.associateParticipantsToSequences(new List<Id>(sequenceIdSet));
			}
		}
		// Start: Participants Association to sequence
 	}
}