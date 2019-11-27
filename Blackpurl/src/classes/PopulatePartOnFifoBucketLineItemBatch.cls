/**
 * Author: Rajat Jain
 * Since: Jan 14, 2018
 * Name: PopulatePartOnFifoBucketLineItemBatch
 * Description: Batch for Populating part look up on fifo bucket line item
**/
global without sharing class PopulatePartOnFifoBucketLineItemBatch implements Database.Batchable<sobject> {
	
	global Database.QueryLocator start(Database.BatchableContext bc) {
        String partStrQuery = 'Select Part__c,Part_FIFO_Bucket__r.Part__c ' +
         					  'FROM Part_FIFO_Bucket_Activity_Line_Item__c ' + 
         					  'WHERE Part_Fifo_Bucket__r.Is_Fifo_Bucket__c = true';
		return Database.getQueryLocator(partStrQuery);
	}
	
    global void execute(Database.batchableContext bc, List<Part_FIFO_Bucket_Activity_Line_Item__c> partFifoList) {
    	for(Part_FIFO_Bucket_Activity_Line_Item__c partFifoLi : partFifoList) {
		    partFifoLi.Part__c = partFifoLi.Part_FIFO_Bucket__r.Part__c;
		}
		update partFifoList;
    }
    
    global void finish(Database.batchableContext bc) {
    }
}