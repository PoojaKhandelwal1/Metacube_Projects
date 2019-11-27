/*
    Apex class to sync customer with accounting server
*/
global with sharing class AccSync_FIFOBucket_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    public String strQuery;
    public Set<Id> setPartFIFOBucketIds;
    public static boolean preventOnAccountingSync = false;
    global List<Part_FIFO_Bucket__c> partFIFOBucketListToUpdate; 
    global List<Log__c> errorLogToInsert;   
    
    public static void runPartFIFOBucketForSync(Set<Id> setPartFIFOBucketIdVal , Integer batchSize) {
        AccSync_FIFOBucket_Batch clsAccSyncBatch = new AccSync_FIFOBucket_Batch();
        clsAccSyncBatch.setPartFIFOBucketIds = setPartFIFOBucketIdVal;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :setPartFIFOBucketIds';
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);
    }
        
    public static String getBaseQuery() {
        String baseQuery = 'SELECT '; 
        for(String fieldName : AccountingFIFOBucket.fieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM Part_FIFO_Bucket__c ';
        baseQuery += 'WHERE availForQBSync__c = true';
        return baseQuery;
    }
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
        partFIFOBucketListToUpdate = new List<Part_FIFO_Bucket__c>();
        errorLogToInsert = new List<Log__c>();
        if(String.isBlank(strQuery)){
            strQuery = getBaseQuery();
            if(setPartFIFOBucketIds != null && setPartFIFOBucketIds.size() > 0) {
                strQuery += ' AND Id IN :setPartFIFOBucketIds';
            }
        }
        return Database.getQueryLocator(strQuery); 
    }
    
    global void execute(Database.batchableContext bc, List<Part_FIFO_Bucket__c> listPartFIFOBuckets) {
        List<AccountingFIFOBucket> accountingPartFIFOBucketList = new List<AccountingFIFOBucket>();
        for(Part_FIFO_Bucket__c partFIFOBucket : listPartFIFOBuckets){
            errorLogToInsert.addAll(FIFOBucketService.syncAccountingServer(new AccountingFIFOBucket(partFIFOBucket), partFIFOBucketListToUpdate));
        }
    }   
 
    global void finish(Database.batchableContext bc) {
        updatePartFIFOBuckets(partFIFOBucketListToUpdate);
        if(errorLogToInsert.size() > 0) {
          insert errorLogToInsert;
        }
    }
    
    public static void updatePartFIFOBuckets(List<Part_FIFO_Bucket__c> partFIFOBucketListToUpdate) {
        if(AccessControl.ifObjectFieldIsUpdateable('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(partFIFOBucketListToUpdate != null && partFIFOBucketListToUpdate.size() > 0) { 
            preventOnAccountingSync = true;
            update partFIFOBucketListToUpdate;
        }
    }
}