/**
 * Author: Richa Mittal
 * Since: Jun. 13, 2018
 * Name: AccSync_PartCategory_Batch_Scheduler
 * Description: Scheduler class for AccSync_PartCategory_Batch
**/
global with sharing class AccSync_PartCategory_Batch_Scheduler implements Schedulable {
    
    global Set<Id> recordIdSet;
    global Integer batchSize;
    
    global AccSync_PartCategory_Batch_Scheduler(Set<Id> recordIdSet, Integer batchSize){
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
    global void execute(SchedulableContext sc) {
        AccSync_PartCategory_Batch clsAccSyncBatch = new AccSync_PartCategory_Batch();
        clsAccSyncBatch.partIdSet = recordIdSet;
        system.debug('partIdSet for AccSync_PartCategory_Batch_Scheduler ' + clsAccSyncBatch.partIdSet);
        Database.executebatch(clsAccSyncBatch, batchSize);
    }
}