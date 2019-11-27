/**
 * Author: Richa Mittal
 * Since: Jun. 13, 2018
 * Name: AccSync_UnitCategory_Batch_Scheduler
 * Description: Scheduler class for AccSync_UnitCategory_Batch
**/
global with sharing class AccSync_UnitCategory_Batch_Scheduler implements Schedulable {
    
    global Set<Id> recordIdSet;
    global Integer batchSize;
    
    global AccSync_UnitCategory_Batch_Scheduler(Set<Id> recordIdSet, Integer batchSize){
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
    global void execute(SchedulableContext sc) {
        AccSync_UnitCategory_Batch clsAccSyncBatch = new AccSync_UnitCategory_Batch();
        clsAccSyncBatch.unitIdSet = recordIdSet;
        system.debug('unitIdSet for AccSync_UnitCategory_Batch_Scheduler ' + clsAccSyncBatch.unitIdSet);
        Database.executebatch(clsAccSyncBatch, batchSize);
    }
}