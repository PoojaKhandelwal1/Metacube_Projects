/**
 * Author: Tarun Khandelwal
 * Since: May 21, 2018
 * Name: AccSync_COInvoiceJournalEntry_Batch_Sch
 * Description: Apex class to schedule AccSync_COInvoiceJournalEntry_Batch.
**/
global class AccSync_COInvoiceJournalEntry_Batch_Sch implements Schedulable {
    
    global Set<Id> recordIdSet;
    global Integer batchSize;
    
    global AccSync_COInvoiceJournalEntry_Batch_Sch(Set<Id> recordIdSet, Integer batchSize) {
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
    global void execute(SchedulableContext sc) {
        AccSync_COInvoiceJournalEntry_Batch clsAccSyncBatch = new AccSync_COInvoiceJournalEntry_Batch();
        clsAccSyncBatch.setcustomerInvoiceIds = recordIdSet;
        system.debug('Invoice for AccSync_COInvoiceJournalEntry_Batch ' + clsAccSyncBatch.setcustomerInvoiceIds);
        Database.executebatch(clsAccSyncBatch, batchSize);
    }
}