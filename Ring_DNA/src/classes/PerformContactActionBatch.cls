public class PerformContactActionBatch implements Database.Batchable<sObject>, Database.stateful, Database.AllowsCallouts {

	public PerformContactActionBatch() {  
	} 

	public Database.QueryLocator start(Database.BatchableContext bc) {
		String query = PerformCadenceActionBatchHelper.formQuery(CadenceConstants.CONTACT_OBJECT_NAME) ;
		return Database.getQueryLocator(query);
	}
  
	public void execute(Database.BatchableContext bc, List<SObject> participantList) {
		PerformCadenceActionBatchService.runSequenceEngine(CadenceConstants.CONTACT_OBJECT_NAME, participantList, null);
	}

	public void finish(Database.BatchableContext bc) {
	}
}