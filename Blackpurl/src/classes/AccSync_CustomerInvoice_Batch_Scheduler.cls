/**
 * Author: Pooja Khandelwal
 * Since: Dec. 26, 2016
 * Name: AccSync_CustomerInvoice_Batch_Scheduler
 * Description: Scheduler class for AccSync_CustomerInvoice_Batch
**/
global with sharing class AccSync_CustomerInvoice_Batch_Scheduler implements Schedulable {
    
    global Set<Id> recordIdSet;
    global Integer batchSize;
    
    global AccSync_CustomerInvoice_Batch_Scheduler(Set<Id> recordIdSet, Integer batchSize) {
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
    global void execute(SchedulableContext sc) {
        AccSync_CustomerInvoice_Batch clsAccSyncBatch = new AccSync_CustomerInvoice_Batch();
        clsAccSyncBatch.setcustomerInvoiceIds = recordIdSet;
        system.debug('Invoice for AccSync_Vendor_Batch_Scheduler ' + clsAccSyncBatch.setcustomerInvoiceIds);
        Database.executebatch(clsAccSyncBatch, batchSize);
    }
}