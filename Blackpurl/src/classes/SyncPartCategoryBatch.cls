global without sharing class SyncPartCategoryBatch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    global List<Part__c> partCategoryListToUpdate;
    global SyncPartCategoryBatch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return null;
    }

    global void execute(Database.batchableContext bc, List<Part__c> listPartCategories) {
    }
 
    global void finish(Database.batchableContext bc){
    }
}