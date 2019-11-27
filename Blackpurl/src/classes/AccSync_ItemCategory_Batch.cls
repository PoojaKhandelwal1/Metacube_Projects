/*
    Apex class to sync Item Category with accounting server
*/
global without sharing class AccSync_ItemCategory_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {

    public String strQuery;
    public Set<Id> setItemCategoryIds;
    global List<Category__c> itemCategoryListToUpdate;
    global List<Log__c> errorLogToInsert;
     
    public static void runItemCategoriesForSync(Set<Id> setItemCategoryIdVal, Integer batchSize ){
        String strQuery;
        AccSync_ItemCategory_Batch clsAccSyncBatch = new AccSync_ItemCategory_Batch();
        clsAccSyncBatch.setItemCategoryIds = setItemCategoryIdVal;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :setItemCategoryIds';
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);
    }
    
    public static String getBaseQuery() {
        String baseQuery = 'SELECT '; 
        for(String fieldName : AccountingItemCategory.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length() - 2);
        baseQuery += ' FROM Category__c WHERE availForQBSync__c = true';
        return baseQuery;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        itemCategoryListToUpdate = new List<Category__c>();
        errorLogToInsert = new List<Log__c>();
        if(String.isBlank(strQuery)){
            strQuery = getBaseQuery();
        }
        return Database.getQueryLocator(strQuery);
    }

    global void execute(Database.batchableContext bc, List<Category__c> listItemCategories) {
        for(Category__c itemCategory : listItemCategories){
            errorLogToInsert.addAll(ItemCategoryService.syncAccountingServer(new List<AccountingItemCategory>{new AccountingItemCategory(itemCategory)}, itemCategoryListToUpdate));
        }
    }
 
    global void finish(Database.batchableContext bc){
        updateItemCategories(itemCategoryListToUpdate);
        if(errorLogToInsert.size() > 0) {
            insert errorLogToInsert;
        }
    }
    
    public static void updateItemCategories(List<Category__c> categoryList){
        if(AccessControl.ifObjectFieldIsUpdateable('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(categoryList != null && categoryList.size() > 0){
            update categoryList;
        }
    }
}