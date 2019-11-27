/**
 * Author: Tarun Khandelwal
 * Since: May 22, 2018
 * Name: AccSync_VendorReturn_Batch_Scheduler
 * Description: Scheduler class for AccSync_VendorReturn_Batch
**/
global with sharing class AccSync_VendorReturn_Batch_Scheduler implements Schedulable {
    
    global Set<Id> recordIdSet;
    global Integer batchSize;
    
    global AccSync_VendorReturn_Batch_Scheduler(Set<Id> recordIdSet, Integer batchSize){
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
    global void execute(SchedulableContext sc) {
        AccSync_VendorReturn_Batch clsAccSyncBatch = new AccSync_VendorReturn_Batch();
        clsAccSyncBatch.setRVOHeaderIds = recordIdSet;
        system.debug('Vendor Return Id Set for AccSync_VendorReturn_Batch_Scheduler ' + clsAccSyncBatch.setRVOHeaderIds);
        Database.executebatch(clsAccSyncBatch, batchSize);
    }
}