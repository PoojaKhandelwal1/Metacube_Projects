/*
    Apex class to sync part category with accounting server
*/
global with sharing class AccSync_PartCategory_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    public String strQuery;
    public Set<Id> partIdSet;
    public static boolean preventOnAccountingSync = false;
    global List<Part__c> partListToUpdate;
        
    public static void runPartForSync(Set<Id> setPartIdVal, Integer batchSize) {
        AccSync_PartCategory_Batch clsAccSyncBatch = new AccSync_PartCategory_Batch();
        clsAccSyncBatch.partIdSet = setPartIdVal;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :partIdSet';
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);
    }
        
    public static String getBaseQuery() {
        String baseQuery = 'SELECT '; 
        for(String fieldName : AccountingPart.fieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM Part__c ';
        baseQuery += 'WHERE Avail_For_QB_Sync_Category__c = true';
        return baseQuery;
    }
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
        partListToUpdate = new List<Part__c>();
        if(String.isBlank(strQuery)){
            strQuery = getBaseQuery();
            if(partIdSet != null && partIdSet.size() > 0) {
                strQuery += ' AND Id IN :partIdSet';
            }
        }
        return Database.getQueryLocator(strQuery); 
    }
    
    global void execute(Database.batchableContext bc, List<Part__c> listParts) {
        for(Part__c partRec : listParts) {
            PartCategoryService.syncAccountingServer(new AccountingPart(partRec), partListToUpdate);
        }
    }  
 
    global void finish(Database.batchableContext bc) {
        updateParts(partListToUpdate);
    }
    
    public static void updateParts(List<Part__c> partListToUpdate) {
        if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(partListToUpdate != null && partListToUpdate.size() > 0) {
            update partListToUpdate;
        }
    }
}