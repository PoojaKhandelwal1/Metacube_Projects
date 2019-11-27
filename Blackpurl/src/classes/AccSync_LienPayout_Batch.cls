/**
 * Author: Pooja Khandelwal
 * Since: Nov. 26, 2018
 * Name: AccSync_LienPayout_Batch
 * Description: Batch for AccSync Lien Payout (QB Integration)
**/
global with sharing class AccSync_LienPayout_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    public String strQuery;
    public Set<Id> setDealItemIds;
    public static boolean preventOnAccountingSync = false;
    global List<Deal_Item__c> dealItemListToUpdate; 
    public List<Account> accountListToUpdateToSyncLienPayouts; 
    public Set<Id> alreadyRequestedAccountIdSet = new Set<Id>();
    global List<Log__c> errorLogToInsert;
         
    /**public static void runLienPayoutForSync( Set<Id> setDealItemIdVal , Integer batchSize) {
        runLienPayoutForSync(setDealItemIdVal, new Set<Id>(), batchSize);
    }*/
    
    public static void runLienPayoutForSync(Set<Id> setDealItemIdVal, Set<Id> alreadyRequestedAccountIdSet, Integer batchSize) {
        AccSync_LienPayout_Batch clsAccSyncBatch = new AccSync_LienPayout_Batch();
        clsAccSyncBatch.setDealItemIds = setDealItemIdVal;
        clsAccSyncBatch.alreadyRequestedAccountIdSet = alreadyRequestedAccountIdSet;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :setDealItemIds';
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);
    }
        
    public static String getBaseQuery(){
        String baseQuery = 'SELECT '; 
        for(String fieldName : AccountingLienPayout.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM Deal_Item__c ';
        baseQuery += 'WHERE Type__c = \'Trade In\' AND Lien_Payout__c > 0 AND Finance_Company__c != null';
        baseQuery += ' AND Lien_Payout_Avail_For_QB_Sync__c = true AND Deal__r.Status__c = \'Invoiced\'';
        return baseQuery;
    }
        
        
    global Database.QueryLocator start(Database.BatchableContext bc){
        dealItemListToUpdate = new List<Deal_Item__c>();
        errorLogToInsert = new List<Log__c>();
        if(String.isBlank(strQuery)){
            strQuery = getBaseQuery();
            if(setDealItemIds != null && setDealItemIds.size() > 0) {
                strQuery += ' AND Id IN :setDealItemIds';
            }
        }
        if(!AccessControl.ifObjectFieldIsAccessible('Deal_Item__c')) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.getQueryLocator(strQuery); 
    }

    global void execute(Database.batchableContext bc, List<Deal_Item__c> listdealItems) {
        accountListToUpdateToSyncLienPayouts = new List<Account>();	
        for(Deal_Item__c dealItem : listdealItems){
        	if(!Test.isRunningTest() && dealItem.Finance_Company__c != null  && dealItem.Finance_Company__r.Vendor_AccountingId__c == null && !alreadyRequestedAccountIdSet.contains(dealItem.Finance_Company__c)) {
    			List<Account> accountListToUpdate = AccSync_Vendor_Batch.getAccountListToUpdateById(new Set<Id>{dealItem.Finance_Company__c});
		    	for(Account account: accountListToUpdate) {
		    		accountListToUpdateToSyncLienPayouts.add(account);
		    		alreadyRequestedAccountIdSet.add(account.Id);
		    	}	
    		} else {
    			errorLogToInsert.addAll(LienPayoutService.syncAccountingServer(new AccountingLienPayout(dealItem), dealItemListToUpdate));
    		}
        }
        
    }  
 
    global void finish(Database.batchableContext bc){
        updateDealItems(dealItemListToUpdate);
        
        if(accountListToUpdateToSyncLienPayouts != null && accountListToUpdateToSyncLienPayouts.size() > 0) {
    		AccSync_Vendor_Batch.updateVendors(accountListToUpdateToSyncLienPayouts);
    		accountListToUpdateToSyncLienPayouts = null;
    		runLienPayoutForSync(setDealItemIds, alreadyRequestedAccountIdSet, 10);
    	}
    	if(errorLogToInsert.size() > 0) {
    	    insert errorLogToInsert;
    	}
    }
    
    public static void updateDealItems(List<Deal_Item__c> dealItemListToUpdate){
    	if(AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(dealItemListToUpdate != null && dealItemListToUpdate.size() > 0){ 
            preventOnAccountingSync = true;
            update dealItemListToUpdate;
        }
    }
}