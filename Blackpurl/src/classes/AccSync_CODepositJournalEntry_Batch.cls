/*
    Apex class to sync CO Deposit with accounting server
*/
global without sharing class AccSync_CODepositJournalEntry_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, 
			 Database.Stateful {

    public String strQuery;
    public Set<Id> setCODepositIds;
    public static Set<Id> CODepositIds;
    global List<CO_Deposit__c> CODepositListToUpdate; 
    public List<Account> accountListToUpdateToSyncCODeposits;
    public Set<Id> alreadyRequestedAccountIdSet;  
    global List<Log__c> errorLogToInsert;
    
    public static void runCODepositsForSync(Set<Id> setCODepositIdVal , Integer batchSize){
        runCODepositsForSync(setCODepositIdVal, new Set<Id>(), batchSize);
    }
    
    public static void runCODepositsForSync(Set<Id> setCODepositIdVal, Set<Id> alreadyRequestedAccountIdSet, Integer batchSize) {
        String strQuery;
        AccSync_CODepositJournalEntry_Batch clsAccSyncBatch = new AccSync_CODepositJournalEntry_Batch();
        clsAccSyncBatch.setCODepositIds = setCODepositIdVal;
        clsAccSyncBatch.alreadyRequestedAccountIdSet = alreadyRequestedAccountIdSet;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :setCODepositIds';
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);
    }
    
    public static String getBaseQuery() {
        String baseQuery = 'SELECT '; 
        for(String fieldName : AccountingCODeposit.fieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM CO_Deposit__c ';
        baseQuery += 'WHERE availForQBJournalEntrySync__c = true';
        return baseQuery;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
    	CODepositListToUpdate = new List<CO_Deposit__c>();
        errorLogToInsert = new List<Log__c>();
    	if(String.isBlank(strQuery)) {
	    	strQuery = getBaseQuery();
            if(setCODepositIds != null && setCODepositIds.size() > 0) {
                strQuery += ' AND Id IN :setCODepositIds';
            }
    	}
        return Database.getQueryLocator(strQuery); 
    }

    global void execute(Database.batchableContext bc, List<CO_Deposit__c> listCODeposits) {
    	System.debug('******' + listCODeposits);
        
        accountListToUpdateToSyncCODeposits = new List<Account>();	
        for(CO_Deposit__c CODeposit : listCODeposits){
            if(!Test.isRunningTest() && CODeposit.CO_Header__r.Customer__c != null && CODeposit.CO_Header__r.Customer__r.AccountingId__c == null && !alreadyRequestedAccountIdSet.contains(CODeposit.CO_Header__r.Customer__c)) {
    			List<Account> accountListToUpdate = AccSync_Customer_Batch.getAccountListToUpdateById(new Set<Id>{CODeposit.CO_Header__r.Customer__c});
		    	for(Account account: accountListToUpdate){
		    		accountListToUpdateToSyncCODeposits.add(account);
		    		alreadyRequestedAccountIdSet.add(account.Id);
		    	}	
    		} else {
    			errorLogToInsert.addAll(CODepositJournalEntryService.syncAccountingServer(new AccountingCODeposit(CODeposit), CODepositListToUpdate));
    		}
        }
    } 
 
    global void finish(Database.batchableContext bc) {
    	updateCODeposits(CODepositListToUpdate);
    	
    	if(accountListToUpdateToSyncCODeposits != null && accountListToUpdateToSyncCODeposits.size() > 0) {
    		AccSync_Customer_Batch.updateCustomers(accountListToUpdateToSyncCODeposits);
    		accountListToUpdateToSyncCODeposits = null;
    		runCODepositsForSync(setCODepositIds, alreadyRequestedAccountIdSet, 10);
    	}
        if(errorLogToInsert.size() > 0) {
    	    insert errorLogToInsert;
    	}
    }
    
    
    public static void updateCODeposits(List<CO_Deposit__c> CODepositListToUpdate) {
    	if(AccessControl.ifObjectFieldIsUpdateable('CO_Deposit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	if(CODepositListToUpdate != null && CODepositListToUpdate.size() > 0) { 
    		update CODepositListToUpdate;
    	}
    }
    
}