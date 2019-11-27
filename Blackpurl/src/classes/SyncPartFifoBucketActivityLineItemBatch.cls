global without sharing class SyncPartFifoBucketActivityLineItemBatch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    global List<Part_FIFO_Bucket_Activity_Line_Item__c> partFifoBucketActivityLineItemListToUpdate;
    
    global SyncPartFifoBucketActivityLineItemBatch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return null;
    }

    global void execute(Database.batchableContext bc, List<Part_FIFO_Bucket_Activity_Line_Item__c> partFifoBucketActivityLineItemlist) {
    }
 
    global void finish(Database.batchableContext bc){
    }
}