/**
 * Author: Richa Mittal
 * Since: Jan 19, 2017
 * Name: AccSync_COInvoiceJE_Batch_Scheduler
 * Description: Apex class to schedule AccSync_COInvoiceJournalEntry_Batch.
**/
global class AccSync_COInvoiceJE_Batch_Scheduler implements Schedulable {
	global void execute(SchedulableContext SC) {
		AccSync_COInvoiceJournalEntry_Batch clsAccSyncBatch = new AccSync_COInvoiceJournalEntry_Batch();
		Id batchstart = Database.executeBatch(clsAccSyncBatch, 10);
	}
}