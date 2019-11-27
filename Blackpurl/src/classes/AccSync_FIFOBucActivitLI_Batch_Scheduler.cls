/**
 * Author: Richa Mittal
 * Since: Jan 18, 2017
 * Name: AccSync_FIFOBucActivitLI_Batch_Scheduler
 * Description: Apex class to schedule AccSync_FIFOBucketActivityLineItem_Batch.
**/
global class AccSync_FIFOBucActivitLI_Batch_Scheduler implements Schedulable {
	
	global Set<Id> recordIdSet;
    global Integer batchSize;
    
    global AccSync_FIFOBucActivitLI_Batch_Scheduler(Set<Id> recordIdSet, Integer batchSize){
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
    global void execute(SchedulableContext sc) {
        AccSync_FIFOBucketActivityLineItem_Batch clsAccSyncBatch = new AccSync_FIFOBucketActivityLineItem_Batch();
        clsAccSyncBatch.setPartFIFOBucketActivityLineItemIds = recordIdSet;
        system.debug('Bucket Activity Line item Id for AccSync_FIFOBucActivitLI_Batch_Scheduler \n\n' + 
                clsAccSyncBatch.setPartFIFOBucketActivityLineItemIds);
        Database.executebatch(clsAccSyncBatch, batchSize);
    }
}