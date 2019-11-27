/**
 * Author: Richa Mittal
 * Since: Jan 19, 2017
 * Name: AccSync_CODepositJE_Batch_Scheduler
 * Description: Apex class to schedule AccSync_CODepositJournalEntry_Batch.
**/
global class AccSync_CODepositJE_Batch_Scheduler implements Schedulable {
    
    global Set<Id> recordIdSet;
    global Integer batchSize;
    
    global AccSync_CODepositJE_Batch_Scheduler(Set<Id> recordIdSet, Integer batchSize){
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
	global void execute(SchedulableContext SC) {
	    AccSync_CODepositJournalEntry_Batch clsAccSyncBatch = new AccSync_CODepositJournalEntry_Batch();
        clsAccSyncBatch.setCODepositIds = recordIdSet;
        system.debug('CODeposit Id Set for AccSync_CODepositJE_Batch_Scheduler ' + clsAccSyncBatch.setCODepositIds);
        Database.executebatch(clsAccSyncBatch, batchSize);
	}
}