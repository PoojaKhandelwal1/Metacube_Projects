public class Create_Action_On_Participant_Batch implements Database.Batchable<sObject> {
	public List<Sequence_Action__c> listOfSequenceActionToUpdate;
	public Create_Action_On_Participant_Batch(List<Sequence_Action__c> listOfSequenceActionToUpdate){
		this.listOfSequenceActionToUpdate = listOfSequenceActionToUpdate;          
	}

	public List<Sequence_Action__c> start(Database.BatchableContext BC){
		return this.listOfSequenceActionToUpdate;
	}

	public  void execute(Database.BatchableContext BC,List<Sequence_Action__c> scope){
		CadenceService.createandUpdateActionOnPart(scope);
	}

	public void finish(Database.BatchableContext BC){
	}
}