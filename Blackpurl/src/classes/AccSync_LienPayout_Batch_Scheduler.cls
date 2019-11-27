/**
 * Author: Pooja Khandelwal
 * Since: Nov. 27, 2018
 * Name: AccSync_LienPayout_Batch_Scheduler
 * Description: Apex class to schedule AccSync_LienPayout_Batch.
**/
global class AccSync_LienPayout_Batch_Scheduler implements Schedulable {
    
    global Set<Id> recordIdSet;
    global Integer batchSize;
    
    global AccSync_LienPayout_Batch_Scheduler(Set<Id> recordIdSet, Integer batchSize) {
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
	global void execute(SchedulableContext SC) {
	    AccSync_LienPayout_Batch clsAccSyncBatch = new AccSync_LienPayout_Batch();
        clsAccSyncBatch.setDealItemIds = recordIdSet;
        Database.executebatch(clsAccSyncBatch, batchSize);
	}
}