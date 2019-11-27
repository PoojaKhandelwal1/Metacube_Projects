/*
    Apex class to sync trade in journal entry with accounting server
*/
global with sharing class AccSync_DealItem_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    public String strQuery;
    public Set<Id> dealItemIdSet;
    public static boolean preventOnAccountingSync = false;
    global List<Deal_Item__c> dealItemListToUpdate;
        
    public static void runDealItemForSync(Set<Id> setDealItemIdVal, Integer batchSize) {
        AccSync_DealItem_Batch clsAccSyncBatch = new AccSync_DealItem_Batch();
        clsAccSyncBatch.dealItemIdSet = setDealItemIdVal;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :dealItemIdSet';
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);
    }
        
    public static String getBaseQuery() {
        String baseQuery = 'SELECT '; 
        for(String fieldName : AccountingDealItem.fieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM Deal_Item__c ';
        baseQuery += 'WHERE Avail_For_QB_Sync__c = true';
        return baseQuery;
    }
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
        dealItemListToUpdate = new List<Deal_Item__c>();
        if(String.isBlank(strQuery)){
            strQuery = getBaseQuery();
            if(dealItemIdSet != null && dealItemIdSet.size() > 0) {
                strQuery += ' AND Id IN :dealItemIdSet';
            }
        }
        return Database.getQueryLocator(strQuery); 
    }
    
    global void execute(Database.batchableContext bc, List<Deal_Item__c> listDealItems) {
        for(Deal_Item__c dealItemRec : listDealItems) {
            DealItemService.syncAccountingServer(new AccountingDealItem(dealItemRec), dealItemListToUpdate);
        }
    }
 
    global void finish(Database.batchableContext bc) {
        updateDealItems(dealItemListToUpdate);
    }
    
    public static void updateDealItems(List<Deal_Item__c> dealItemListToUpdate) {
        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(dealItemListToUpdate != null && dealItemListToUpdate.size() > 0) {
            update dealItemListToUpdate;
        }
    }
}