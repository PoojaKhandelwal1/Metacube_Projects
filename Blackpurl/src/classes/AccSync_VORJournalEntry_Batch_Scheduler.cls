/**
 * Author: Richa Mittal
 * Since: Jan 18, 2017
 * Name: AccSync_VORJournalEntry_Batch_Scheduler
 * Description: Apex class to schedule AccSync_VORJournalEntry_Batch.
**/
global class AccSync_VORJournalEntry_Batch_Scheduler implements Schedulable {
    
    global Set<Id> recordIdSet;
    global Integer batchSize;
    
    global AccSync_VORJournalEntry_Batch_Scheduler(Set<Id> recordIdSet, Integer batchSize){
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
	global void execute(SchedulableContext SC) {
	    AccSync_VORJournalEntry_Batch clsAccSyncBatch = new AccSync_VORJournalEntry_Batch();
        clsAccSyncBatch.setVORIds = recordIdSet;
        system.debug('VR Id Set for AccSync_VORJournalEntry_Batch_Scheduler ' + clsAccSyncBatch.setVORIds);
        Database.executebatch(clsAccSyncBatch, batchSize);
	}
}