/*
    Apex class to sync Store Credit with accounting server
*/
global without sharing class AccSync_StoreCreditJournalEntry_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {

    public String strQuery;
    public Set<Id> setStoreCreditIds;
    global List<Store_Credit__c> StoreCreditListToUpdate; 
    public List<Account> accountListToUpdateToSyncStoreCredits; 
    public Set<Id> alreadyRequestedAccountIdSet;
    global List<Log__c> errorLogToInsert;
    
    public static void runStoreCreditsForSync(Set<Id> setStoreCreditIdVal, Integer batchSize){
        runStoreCreditsForSync(setStoreCreditIdVal, new Set<Id>(), batchSize);
    }
    
    public static void runStoreCreditsForSync(Set<Id> setStoreCreditIdVal, Set<Id> alreadyRequestedAccountIdSet, Integer batchSize){
        String strQuery;
        AccSync_StoreCreditJournalEntry_Batch clsAccSyncBatch = new AccSync_StoreCreditJournalEntry_Batch();
        clsAccSyncBatch.setStoreCreditIds = setStoreCreditIdVal;
        clsAccSyncBatch.alreadyRequestedAccountIdSet = alreadyRequestedAccountIdSet;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :setStoreCreditIds';
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);
    }
    
    public static String getBaseQuery(){
        String baseQuery = 'SELECT '; 
        for(String fieldName : AccountingStoreCredit.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM Store_Credit__c ';
        baseQuery += 'WHERE availForQBSync__c = true';
        return baseQuery;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
    	StoreCreditListToUpdate = new List<Store_Credit__c>();
    	errorLogToInsert = new List<Log__c>();
    	if(String.isBlank(strQuery)){
	    	strQuery = getBaseQuery();
	    	if(setStoreCreditIds != null && setStoreCreditIds.size() > 0) {
                strQuery += ' AND Id IN :setStoreCreditIds';
            }
    	}
        return Database.getQueryLocator(strQuery); 
    }

    global void execute(Database.batchableContext bc, List<Store_Credit__c> listStoreCredits) {
    	system.debug('******' + listStoreCredits);
    	
    	accountListToUpdateToSyncStoreCredits = new List<Account>();	
        for(Store_Credit__c StoreCredit : listStoreCredits){
        	if(!Test.isRunningTest() && StoreCredit.Customer__c != null  && StoreCredit.Customer__r.AccountingId__c == null && !alreadyRequestedAccountIdSet.contains(StoreCredit.Customer__c)) {
    			List<Account> accountListToUpdate = AccSync_Customer_Batch.getAccountListToUpdateById(new Set<Id>{StoreCredit.Customer__c});
		    	for(Account account: accountListToUpdate){
		    		accountListToUpdateToSyncStoreCredits.add(account);
		    		alreadyRequestedAccountIdSet.add(account.Id);
		    	}	
    		} else {
    			errorLogToInsert.addAll(StoreCreditJournalEntryService.syncAccountingServer(new AccountingStoreCredit(StoreCredit), StoreCreditListToUpdate));
    		}
        }
    } 
 
    global void finish(Database.batchableContext bc){
    	updateStoreCredits(StoreCreditListToUpdate);
    	if(accountListToUpdateToSyncStoreCredits != null && accountListToUpdateToSyncStoreCredits.size() > 0) {
    		AccSync_Customer_Batch.updateCustomers(accountListToUpdateToSyncStoreCredits);
    		accountListToUpdateToSyncStoreCredits = null;
    		runStoreCreditsForSync(setStoreCreditIds, alreadyRequestedAccountIdSet, 10);
    	}
    	if(errorLogToInsert.size() > 0) {
    	    insert errorLogToInsert;
    	}
    }
    
    public static void updateStoreCredits(List<Store_Credit__c> StoreCreditListToUpdate){
    	if(AccessControl.ifObjectFieldIsUpdateable('Store_Credit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	if(StoreCreditListToUpdate != null && StoreCreditListToUpdate.size() > 0){ 
    		update StoreCreditListToUpdate;
    	}
    }
}