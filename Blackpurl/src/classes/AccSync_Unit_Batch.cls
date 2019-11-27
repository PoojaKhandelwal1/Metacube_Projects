/**
 * Author: Richa Mittal
 * Since: Dec. 14, 2017
 * Name: AccSync_Unit_Batch
 * Description: Batch for AccSync Unit (QB Integration)
**/
global with sharing class AccSync_Unit_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    public String strQuery;
    public Set<Id> setCOUIds;
    public static boolean preventOnAccountingSync = false;
    global List<Customer_Owned_Unit__c> COUListToUpdate;  
    public List<Account> accountListToUpdateToSyncCOUs;
    public Set<Id> alreadyRequestedAccountIdSet;
    global List<Log__c> errorLogToInsert;
    
    public static void runCOUsForSync(Set<Id> setCOUIdVal, Integer batchSize) {
        runCOUsForSync(setCOUIdVal, new Set<Id>(), batchSize);
    }
    
    public static void runCOUsForSync(Set<Id> setCOUIdVal, Set<Id> alreadyRequestedAccountIdSet, Integer batchSize){
        AccSync_Unit_Batch clsAccSyncBatch = new AccSync_Unit_Batch();
        clsAccSyncBatch.setCOUIds = setCOUIdVal;
        clsAccSyncBatch.alreadyRequestedAccountIdSet = alreadyRequestedAccountIdSet;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :setCOUIds';
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);
    }
        
    public static String getBaseQuery(){
        String baseQuery = 'SELECT '; 
        for(String fieldName : AccountingUnit.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM Customer_Owned_Unit__c ';
        baseQuery += 'WHERE availForQBSync__c = true AND Total_Cost__c != 0';
        return baseQuery;
    }
        
    global Database.QueryLocator start(Database.BatchableContext bc){
        COUListToUpdate = new List<Customer_Owned_Unit__c>();
        errorLogToInsert = new List<Log__c>();
        if(String.isBlank(strQuery)){
            strQuery = getBaseQuery();
            if(setCOUIds != null && setCOUIds.size() > 0) {
                strQuery += ' AND Id IN :setCOUIds';
            }
        }
        return Database.getQueryLocator(strQuery); 
    }

    global void execute(Database.batchableContext bc, List<Customer_Owned_Unit__c> listCOUs) {
        accountListToUpdateToSyncCOUs = new List<Account>();	
        for(Customer_Owned_Unit__c cou : listCOUs){
            if(!Test.isRunningTest() && cou.Referenced_Unit__r.Vendor__c != null && cou.Referenced_Unit__r.Vendor__r.Vendor_AccountingId__c == null
            	&& !alreadyRequestedAccountIdSet.contains(cou.Referenced_Unit__r.Vendor__c)) {
    			List<Account> accountListToUpdate = AccSync_Vendor_Batch.getAccountListToUpdateById(new Set<Id>{cou.Referenced_Unit__r.Vendor__c});
		    	for(Account account: accountListToUpdate){
		    		accountListToUpdateToSyncCOUs.add(account);
		    		alreadyRequestedAccountIdSet.add(account.Id);
		    	}	
    		} else {
    			errorLogToInsert.addAll(UnitService.syncAccountingServer(new AccountingUnit(cou), COUListToUpdate));
            }
        }
    }  
    
    global void finish(Database.batchableContext bc){
        updateCOUs(COUListToUpdate);
        
        if(accountListToUpdateToSyncCOUs != null && accountListToUpdateToSyncCOUs.size() > 0) {
    		AccSync_Vendor_Batch.updateVendors(accountListToUpdateToSyncCOUs);
    		accountListToUpdateToSyncCOUs = null;
    		runCOUsForSync(setCOUIds, alreadyRequestedAccountIdSet, 10);
    	}
        if(errorLogToInsert.size() > 0) {
        	insert errorLogToInsert;
        }
    }
    
    public static void updateCOUs(List<Customer_Owned_Unit__c> COUListToUpdate){
    	if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(COUListToUpdate != null && COUListToUpdate.size() > 0){ 
            preventOnAccountingSync = true;
            update COUListToUpdate;
        }
    }
}