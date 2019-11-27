/**
 * Author: Richa Mittal
 * Since: Jan 18, 2017
 * Name: AccSync_FIFOBucket_Batch_Scheduler
 * Description: Apex class to schedule AccSync_FIFOBucket_Batch.
**/
global class AccSync_FIFOBucket_Batch_Scheduler implements Schedulable {
    
    global Set<Id> recordIdSet;
    global Integer batchSize;
    
    global AccSync_FIFOBucket_Batch_Scheduler(Set<Id> recordIdSet, Integer batchSize){
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
    global void execute(SchedulableContext sc) {
        AccSync_FIFOBucket_Batch clsAccSyncBatch = new AccSync_FIFOBucket_Batch();
        clsAccSyncBatch.setPartFIFOBucketIds = recordIdSet;
        system.debug('FIFO Bucket Id Set for AccSync_FIFOBucket_Batch_Scheduler ' + clsAccSyncBatch.setPartFIFOBucketIds);
        Database.executebatch(clsAccSyncBatch, batchSize);
    }
}