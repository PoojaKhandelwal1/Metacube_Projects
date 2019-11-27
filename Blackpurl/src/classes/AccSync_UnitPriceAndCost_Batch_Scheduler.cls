/**
 * Author: Richa Mittal
 * Since: Jan 19, 2017
 * Name: AccSync_UnitPriceAndCost_Batch_Scheduler
 * Description: Apex class to schedule AccSync_UnitPriceAndCost_Batch_Scheduler.
**/
global class AccSync_UnitPriceAndCost_Batch_Scheduler implements Schedulable {
    
    global Set<Id> recordIdSet;
    global Integer batchSize;
    
    global AccSync_UnitPriceAndCost_Batch_Scheduler(Set<Id> recordIdSet, Integer batchSize){
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
	global void execute(SchedulableContext SC) {
	    AccSync_UnitPriceAndCost_Batch clsAccSyncBatch = new AccSync_UnitPriceAndCost_Batch();
        clsAccSyncBatch.setUnitPriceAndCostIds = recordIdSet;
        system.debug('Unit Price and Cost for AccSync_UnitPriceAndCost_Batch ' + clsAccSyncBatch.setUnitPriceAndCostIds);
        Database.executebatch(clsAccSyncBatch, batchSize);
	}
}