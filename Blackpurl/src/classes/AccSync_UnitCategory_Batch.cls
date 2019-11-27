/*
    Apex class to sync unit category with accounting server on change of inventory GL of categoy
*/
global with sharing class AccSync_UnitCategory_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    public String strQuery;
    public Set<Id> unitIdSet;
    public static boolean preventOnAccountingSync = false;
    global List<Customer_Owned_Unit__c> unitListToUpdate;
        
    public static void runUnitForSync(Set<Id> setunitIdVal, Integer batchSize) {
        AccSync_UnitCategory_Batch clsAccSyncBatch = new AccSync_UnitCategory_Batch();
        clsAccSyncBatch.unitIdSet = setunitIdVal;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :unitIdSet';
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);
    }
        
    public static String getBaseQuery() {
        String baseQuery = 'SELECT '; 
        for(String fieldName : AccountingUnit.fieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM Customer_Owned_Unit__c ';
        baseQuery += 'WHERE Avail_For_QB_Sync_Category__c = true';
        return baseQuery;
    }
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
        unitListToUpdate = new List<Customer_Owned_Unit__c>();
        if(String.isBlank(strQuery)){
            strQuery = getBaseQuery();
            if(unitIdSet != null && unitIdSet.size() > 0) {
                strQuery += ' AND Id IN :unitIdSet';
            }
        }
        return Database.getQueryLocator(strQuery); 
    }
    
    global void execute(Database.batchableContext bc, List<Customer_Owned_Unit__c> listUnits) {
        for(Customer_Owned_Unit__c unitRec : listUnits) {
            UnitCategoryService.syncAccountingServer(new AccountingUnit(unitRec), unitListToUpdate);
        }
    }
 
    global void finish(Database.batchableContext bc) {
        updateUnits(unitListToUpdate);
    }
    
    public static void updateUnits(List<Customer_Owned_Unit__c> unitListToUpdate) {
        if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(unitListToUpdate != null && unitListToUpdate.size() > 0) {
            update unitListToUpdate;
        }
    }
}