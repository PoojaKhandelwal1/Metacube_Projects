/**
 * Author: Pooja Khandelwal
 * Since: Dec. 26, 2016
 * Name: AccSync_Customer_Batch_Scheduler
 * Description: Scheduler class for AccSync_Customer_Batch
**/
global with sharing class AccSync_Customer_Batch_Scheduler implements Schedulable {
    
    global Set<Id> recordIdSet;
    global Integer batchSize;
    
    global AccSync_Customer_Batch_Scheduler(Set<Id> recordIdSet, Integer batchSize){
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
    global void execute(SchedulableContext sc) {
        AccSync_Customer_Batch clsAccSyncBatch = new AccSync_Customer_Batch();
        clsAccSyncBatch.customerRecordIdSet = recordIdSet;
        system.debug('customerIdSet for AccSync_Customer_Batch_Scheduler ' + clsAccSyncBatch.customerRecordIdSet);
        Database.executebatch(clsAccSyncBatch, batchSize);
    }
}