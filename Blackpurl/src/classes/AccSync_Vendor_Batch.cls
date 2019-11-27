/*
    Apex class to sync vendor with accounting server
*/
global without sharing class AccSync_Vendor_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, 
			 Database.Stateful {
    public String strQuery;
    public Set<Id> setVendorIds;
    public static Set<Id> vendorIds;
    global List<Account> accountListToUpdate; 
    global List<Log__c> errorLogToInsert;
    public Set<Id> vendorRecordIdSetToRetry;
    public Integer retrialAttempt;
    public Boolean isSystemSleep;
    public static void runVendorsForSync(Set<Id> setVendorIdVal, Integer batchSize, Integer retrialAttemptNumber, Boolean isSystemSleep) {
        String strQuery;
        AccSync_Vendor_Batch clsAccSyncBatch = new AccSync_Vendor_Batch();
        clsAccSyncBatch.setVendorIds = setVendorIdVal;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :setVendorIds';
        clsAccSyncBatch.retrialAttempt = retrialAttemptNumber;
        clsAccSyncBatch.isSystemSleep = isSystemSleep;
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);

    }
    
    public static String getBaseQuery(){
        String baseQuery = 'SELECT '; 
        for(String fieldName : AccountingVendor.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM Account ';
        baseQuery += 'WHERE Is_Vendor__c = true AND Vendor_AvailForQBSync__c = true';
        return baseQuery;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
    	if(isSystemSleep != null && isSystemSleep) { //for retry we need to wait for our request to be completed so a sleep is added here
            QBErrorHandlingService.addDelayToBatch();
        }
    	accountListToUpdate = new List<Account>();
        vendorRecordIdSetToRetry = new Set<Id>();
    	errorLogToInsert = new List<Log__c>();
    	if(String.isBlank(strQuery)){
	    	strQuery = getBaseQuery();
	    	if(setVendorIds != null && setVendorIds.size() > 0) {
                strQuery += ' AND Id IN :setVendorIds';
            }
    	}
        return Database.getQueryLocator(strQuery); 
    }

    global void execute(Database.batchableContext bc, List<Account> listVendors) {
        for(Account vendor : listVendors){
            errorLogToInsert.addAll(VendorService.syncAccountingServer(new AccountingVendor(vendor), accountListToUpdate, vendorRecordIdSetToRetry, retrialAttempt));
        }
    }
 
    global void finish(Database.batchableContext bc){
    	updateVendors(accountListToUpdate);
    	if(errorLogToInsert.size() > 0) {
    	    insert errorLogToInsert;
    	}
        if(vendorRecordIdSetToRetry.size() > 0 && retrialAttempt < QuickbookConnector.QUICKBOOKS_MAX_RETRY_COUNT) {
            new QBErrorHandlingService('Read timed out', vendorRecordIdSetToRetry, 'Vendor').executeRetry(retrialAttempt);
        }
    }
    
    
    public static void updateVendors(List<Account> accountListToUpdate){
    	if(AccessControl.ifObjectFieldIsUpdateable('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	if(accountListToUpdate != null && accountListToUpdate.size() > 0){ 
    		update accountListToUpdate;
    	}
    }
    
    public static List<Account> getAccountListToUpdateById(Set<Id> accountIdSet) {
    	if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	String strQuery = getBaseQuery(); 
    	strQuery += ' AND Id IN :accountIdSet';
    	List<Account> accountList = Database.query(strQuery); 
    	List<Account> accountsToUpdate = new List<Account>();
    	for(Account vendor : accountList) {
    		VendorService.syncAccountingServer(new AccountingVendor(vendor), accountsToUpdate, new Set<Id>(), 0);
        }
        return accountsToUpdate;
    }
}