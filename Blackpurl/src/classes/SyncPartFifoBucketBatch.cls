global without sharing class SyncPartFifoBucketBatch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    global List<Part_FIFO_Bucket__c> partFifoBucketListToUpdate;
    
    global SyncPartFifoBucketBatch() {
    }
     
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return null;
    }

    global void execute(Database.batchableContext bc, List<Part_FIFO_Bucket__c> listPartFIFOBuckets) {
    }
    
    global void finish(Database.batchableContext bc) {
    }
}