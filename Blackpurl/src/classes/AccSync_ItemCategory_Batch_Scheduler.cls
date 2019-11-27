/**
 * Author: Richa Mittal
 * Since: Dec 26, 2016
 * Name: AccSync_ItemCategory_Batch_Scheduler
 * Description: Apex class to schedule AccSync_ItemCategory_Batch.
**/
global class AccSync_ItemCategory_Batch_Scheduler implements Schedulable {
	
	global void execute(SchedulableContext SC) {
		Id batchstart = Database.executeBatch(new AccSync_ItemCategory_Batch(), 10);
	}
}