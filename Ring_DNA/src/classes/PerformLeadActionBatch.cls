public class PerformLeadActionBatch implements Database.Batchable<sObject>, Database.stateful, Database.AllowsCallouts {

	public PerformLeadActionBatch() {  
	}
 
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String query = PerformCadenceActionBatchHelper.formQuery(CadenceConstants.LEAD_OBJECT_NAME) ;
		return Database.getQueryLocator(query);
	} 
 
	public void execute(Database.BatchableContext bc, List<SObject> participantList) {
		PerformCadenceActionBatchService.runSequenceEngine(CadenceConstants.LEAD_OBJECT_NAME, participantList, null);
	}

	public void finish(Database.BatchableContext bc) {
	}
}