/**
 * Author: Richa Mittal
 * Since: Jan 19, 2017
 * Name: AccSync_COInvoicePayment_Batch_Scheduler
 * Description: Apex class to schedule AccSync_COInvoicePayment_Batch.
**/
global class AccSync_COInvoicePayment_Batch_Scheduler implements Schedulable {
    
    global Set<Id> recordIdSet;
    global Integer batchSize;
    
    global AccSync_COInvoicePayment_Batch_Scheduler(Set<Id> recordIdSet, Integer batchSize) {
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
    global void execute(SchedulableContext sc) {
        AccSync_COInvoicePayment_Batch clsAccSyncBatch = new AccSync_COInvoicePayment_Batch();
        clsAccSyncBatch.setCOInvoicePaymentIds = recordIdSet;
        system.debug('Customer Invoice Payment for AccSync_COInvoicePayment_Batch ' + clsAccSyncBatch.setCOInvoicePaymentIds);
        Database.executebatch(clsAccSyncBatch, batchSize);
    }
}