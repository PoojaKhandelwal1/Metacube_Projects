global without sharing class SyncItemCategoryBatch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    global List<Category__c> itemCategoryListToUpdate;
    global SyncItemCategoryBatch() {}
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return null;
    }

    global void execute(Database.batchableContext bc, List<Category__c> listItemCategories) {}
 
    global void finish(Database.batchableContext bc){}
}