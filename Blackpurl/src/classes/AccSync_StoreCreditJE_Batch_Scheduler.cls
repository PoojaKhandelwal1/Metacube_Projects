/**
 * Author: Richa Mittal
 * Since: Aug 24, 2017
 * Name: AccSync_StoreCreditJE_Batch_Scheduler
 * Description: Apex class to schedule AccSync_StoreCreditJE_Batch_Scheduler.
**/
global class AccSync_StoreCreditJE_Batch_Scheduler implements Schedulable {
    global Set<Id> recordIdSet;
    global Integer batchSize;
    
    global AccSync_StoreCreditJE_Batch_Scheduler(Set<Id> recordIdSet, Integer batchSize){
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
	global void execute(SchedulableContext SC) {
	    AccSync_StoreCreditJournalEntry_Batch clsAccSyncBatch = new AccSync_StoreCreditJournalEntry_Batch();
        clsAccSyncBatch.setStoreCreditIds = recordIdSet;
        system.debug('customerIdSet for AccSync_StoreCreditJE_Batch_Scheduler ' + clsAccSyncBatch.setStoreCreditIds);
        Database.executebatch(clsAccSyncBatch, batchSize);
	}
}