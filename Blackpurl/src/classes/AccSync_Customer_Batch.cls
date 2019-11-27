/*
    Apex class to sync customer with accounting server
*/

global without sharing class AccSync_Customer_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, 
			 Database.Stateful {

    public String strQuery;
    public Set<Id> customerRecordIdSet;
    public Set<Id> vendorRecordIdSet;
    global List<Account> accountListToUpdate;
    global List<Log__c> errorLogToInsert;
    public Set<Id> customerRecordIdSetToRetry;
    public Integer retrialAttempt;
    public Boolean isSystemSleep;
    
    public static void runCustomersForSync(Set<Id> customerIdSet, Integer batchSize, Integer retrialAttemptNumber, Boolean isSystemSleep){
        runForSync(customerIdSet, new Set<Id>(), batchSize, retrialAttemptNumber, isSystemSleep);
    }
    
    public static void runCustomersAndVendorsForSync(Set<Id> customerIdSet, Set<Id> vendorIdSet, Integer batchSize, Boolean isSystemSleep){
        runForSync(customerIdSet, vendorIdSet, batchSize, 0, isSystemSleep);
    }
    
    private static void runForSync(Set<Id> customerRecordIdSet, Set<Id> vendorRecordIdSet, Integer batchSize, Integer retrialAttemptNumber, Boolean isSystemSleep) {
    	String strQuery;
        AccSync_Customer_Batch clsAccSyncBatch = new AccSync_Customer_Batch();
        clsAccSyncBatch.customerRecordIdSet = customerRecordIdSet;
        clsAccSyncBatch.vendorRecordIdSet = vendorRecordIdSet;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :customerRecordIdSet';
        clsAccSyncBatch.retrialAttempt = retrialAttemptNumber;
        clsAccSyncBatch.isSystemSleep = isSystemSleep;
        Id batchId = Database.executeBatch(clsAccSyncBatch, batchSize);
    }
    
    private static String getBaseQuery() {
        String baseQuery = 'SELECT '; 
        for(String fieldName : AccountingCustomer.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM Account ';
        baseQuery += 'WHERE availForQBSync__c = true';
        return baseQuery;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
    	if(isSystemSleep != null && isSystemSleep) {//for retry we need to wait for our request to be completed so a sleep is added here
            QBErrorHandlingService.addDelayToBatch();
        }
    	accountListToUpdate = new List<Account>();
    	errorLogToInsert = new List<Log__c>();
    	customerRecordIdSetToRetry = new Set<Id>();
    	if(String.isBlank(strQuery)) {
	    	strQuery = getBaseQuery();
	    	if(customerRecordIdSet != null && customerRecordIdSet.size() > 0) {
	    	    strQuery += ' AND Id IN :customerRecordIdSet';
	    	}
    	}
    	system.debug('Inside Batch of AccSync_Customer_Batch ' + customerRecordIdSet + ' - ' + strQuery);
        return Database.getQueryLocator(strQuery); 
    }

    global void execute(Database.batchableContext bc, List<Account> listCustomers) {
        for(Account customer : listCustomers) {
           errorLogToInsert.addAll(CustomerService.syncAccountingServer(new AccountingCustomer(customer), accountListToUpdate, customerRecordIdSetToRetry, retrialAttempt));
        }
    }
 
    global void finish(Database.batchableContext bc) {
    	updateCustomers(accountListToUpdate);
    	if(errorLogToInsert.size() > 0) {
    	    insert errorLogToInsert;
    	}
    	if(vendorRecordIdSet != null && vendorRecordIdSet.size() > 0) {
    		VendorService.syncVendors(vendorRecordIdSet);
    	}
        if(customerRecordIdSetToRetry.size() > 0 && retrialAttempt < QuickbookConnector.QUICKBOOKS_MAX_RETRY_COUNT) {
            new QBErrorHandlingService('Read timed out', customerRecordIdSetToRetry, 'Customer').executeRetry(retrialAttempt);
        }
    }
    
    
    public static void updateCustomers(List<Account> accountListToUpdate) {
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
    	for(Account customer : accountList) {
           CustomerService.syncAccountingServer(new AccountingCustomer(customer), accountsToUpdate, new Set<Id>(), 0);
        }
        return accountsToUpdate;
    }
}