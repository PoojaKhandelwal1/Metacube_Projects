/*
    Apex class to sync unit price and costs with accounting server
*/
global with sharing class AccSync_UnitPriceAndCost_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
	public String strQuery;
    public Set<Id> setUnitPriceAndCostIds;
    public static boolean preventOnAccountingSync = false;
    global List<Unit_Price_Cost__c> unitPriceAndCostListToUpdate; 
    public List<Account> accountListToUpdateToSyncUnitPriceAndCost;
    public Set<Id> alreadyRequestedAccountIdSet;
     global List<Log__c> errorLogToInsert;
	    
    public static void runUnitPriceAndCostForSync(Set<Id> setUnitPriceAndCostIdVal, Integer batchSize) {
        runUnitPriceAndCostForSync(setUnitPriceAndCostIdVal, new Set<Id>(), batchSize);
	}
	
	public static void runUnitPriceAndCostForSync(Set<Id> setUnitPriceAndCostIdVal, Set<Id> alreadyRequestedAccountIdSet, Integer batchSize){
        AccSync_UnitPriceAndCost_Batch clsAccSyncBatch = new AccSync_UnitPriceAndCost_Batch();
        clsAccSyncBatch.setUnitPriceAndCostIds = setUnitPriceAndCostIdVal;
        clsAccSyncBatch.alreadyRequestedAccountIdSet = alreadyRequestedAccountIdSet;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :setUnitPriceAndCostIds';
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);
	}
    	
    public static String getBaseQuery(){
        String baseQuery = 'SELECT '; 
        for(String fieldName : AccountingUnitPriceAndCost.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM Unit_Price_Cost__c ';
        baseQuery += 'WHERE availForQBSync__c = true AND Customer_Owned_Unit__c != null AND Customer_Owned_Unit__r.Unit_Type__c = \'STOCK\' AND Ref_No__c Like \'UA-%\' AND Total_Cost__c != null AND Total_Cost__c != 0';
        return baseQuery;
    }
        
    global Database.QueryLocator start(Database.BatchableContext bc){
    	unitPriceAndCostListToUpdate = new List<Unit_Price_Cost__c>();
    	errorLogToInsert = new List<Log__c>();
    	if(String.isBlank(strQuery)){
	    	strQuery = getBaseQuery();
	    	if(setUnitPriceAndCostIds != null && setUnitPriceAndCostIds.size() > 0) {
                strQuery += ' AND Id IN :setUnitPriceAndCostIds';
            }
    	}
        return Database.getQueryLocator(strQuery); 
    }

    global void execute(Database.batchableContext bc, List<Unit_Price_Cost__c> listUnitPriceAndCosts) {
        List<AccountingUnitPriceAndCost> accountingUnitPriceAndCostList = new List<AccountingUnitPriceAndCost>();
        accountListToUpdateToSyncUnitPriceAndCost = new List<Account>();
        for(Unit_Price_Cost__c unitPriceAndCost : listUnitPriceAndCosts){
           	if(!Test.isRunningTest() && unitPriceAndCost.Customer_Owned_Unit__r.Referenced_Unit__r.Vendor__c != null
           		&& unitPriceAndCost.Customer_Owned_Unit__r.Referenced_Unit__r.Vendor__r.Vendor_AccountingId__c == null 
           		&& !alreadyRequestedAccountIdSet.contains(unitPriceAndCost.Customer_Owned_Unit__r.Referenced_Unit__r.Vendor__c)) {
       			Id vendorId = unitPriceAndCost.Customer_Owned_Unit__r.Referenced_Unit__r.Vendor__c;
    			List<Account> accountListToUpdate = AccSync_Vendor_Batch.getAccountListToUpdateById(new Set<Id>{vendorId});
		    	for(Account account: accountListToUpdate){
		    		accountListToUpdateToSyncUnitPriceAndCost.add(account);
		    		alreadyRequestedAccountIdSet.add(account.Id);
		    	}	
    		} else {
    			errorLogToInsert.addAll(UnitPriceAndCostService.syncAccountingServer(new AccountingUnitPriceAndCost(unitPriceAndCost), unitPriceAndCostListToUpdate));
            }
        }
    }  
 
    global void finish(Database.batchableContext bc){
    	updateUnitPriceAndCosts(unitPriceAndCostListToUpdate);
    	
    	if(accountListToUpdateToSyncUnitPriceAndCost != null && accountListToUpdateToSyncUnitPriceAndCost.size() > 0) {
    		AccSync_Vendor_Batch.updateVendors(accountListToUpdateToSyncUnitPriceAndCost);
    		accountListToUpdateToSyncUnitPriceAndCost = null;
    		runUnitPriceAndCostForSync(setUnitPriceAndCostIds, alreadyRequestedAccountIdSet, 10);
    	}
    	if(errorLogToInsert.size() > 0) {
    	    insert errorLogToInsert;
    	}
    }
    
    public static void updateUnitPriceAndCosts(List<Unit_Price_Cost__c> unitPriceAndCostListToUpdate){
    	if(AccessControl.ifObjectFieldIsUpdateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	if(unitPriceAndCostListToUpdate != null && unitPriceAndCostListToUpdate.size() > 0){ 
    		preventOnAccountingSync = true;
    		update unitPriceAndCostListToUpdate;
    	}
    }
}