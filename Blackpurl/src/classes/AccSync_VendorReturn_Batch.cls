/**
 * Author: Hitesh Gupta
 * Since: Oct 11, 2017
 * Name: AccSync_VendorReturn_Batch
 * Description: Batch for AccSync Vendor Return (QB Integration)
**/
global with sharing class AccSync_VendorReturn_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    
    public String strQuery;
    public Set<Id> setRVOHeaderIds;
    public static boolean preventOnAccountingSync = false;
    global List<Return_VO_Header__c> RVOHeaderListToUpdate; 
    public List<Account> accountListToUpdateToSyncRVOHeaders; 
    public Set<Id> alreadyRequestedAccountIdSet;
    global List<Log__c> errorLogToInsert;
    
    public static void runRVOHeadersForSync( Set<Id> setRVOHeaderIdVal , Integer batchSize) {
        runRVOHeadersForSync(setRVOHeaderIdVal, new Set<Id>(), batchSize);
    }
    
    public static void runRVOHeadersForSync(Set<Id> setRVOHeaderIdVal, Set<Id> alreadyRequestedAccountIdSet, Integer batchSize){
        AccSync_VendorReturn_Batch clsAccSyncBatch = new AccSync_VendorReturn_Batch();
        clsAccSyncBatch.setRVOHeaderIds = setRVOHeaderIdVal;
        clsAccSyncBatch.alreadyRequestedAccountIdSet = alreadyRequestedAccountIdSet;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :setRVOHeaderIds';
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);
    }
        
    public static String getBaseQuery(){
        String baseQuery = 'SELECT '; 
        //fields of VI Header  
        for(String fieldName : AccountingVendorReturn.getReturnVOFieldList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        // Child Query: fields of RVO Line Items 
        baseQuery += '( SELECT ';
        for(String fieldName : AccountingVendorReturn.getReturnVOLIFieldList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM Return_VO_Line_Items__r) '; 
            
        baseQuery += 'FROM Return_VO_Header__c WHERE availForQBSync__c = true AND Status__c = \'Credited\'';
        return baseQuery;
    }
        
    global Database.QueryLocator start(Database.BatchableContext bc){
        RVOHeaderListToUpdate = new List<Return_VO_Header__c>();
        errorLogToInsert = new List<Log__c>();
        if(String.isBlank(strQuery)){
            strQuery = getBaseQuery();
            if(setRVOHeaderIds != null && setRVOHeaderIds.size() > 0) {
                strQuery += ' AND Id IN :setRVOHeaderIds';
            }
        }
        return Database.getQueryLocator(strQuery); 
    }

    global void execute(Database.batchableContext bc, List<Return_VO_Header__c> listRVOHeaders) {
        accountListToUpdateToSyncRVOHeaders = new List<Account>();	
        for(Return_VO_Header__c RVOHeader : listRVOHeaders){
            if(!Test.isRunningTest() && RVOHeader.Vendor__c != null && RVOHeader.Vendor__r.Vendor_AccountingId__c == null && !alreadyRequestedAccountIdSet.contains(RVOHeader.Vendor__c)) {
    			List<Account> accountListToUpdate = AccSync_Vendor_Batch.getAccountListToUpdateById(new Set<Id>{RVOHeader.Vendor__c});
		    	for(Account account: accountListToUpdate){
		    		accountListToUpdateToSyncRVOHeaders.add(account);
		    		alreadyRequestedAccountIdSet.add(account.Id);
		    	}	
    		} else {
    			errorLogToInsert.addAll(VendorReturnService.syncAccountingServer(new AccountingVendorReturn(RVOHeader), RVOHeaderListToUpdate));
    		}
        }
    }  
 
    global void finish(Database.batchableContext bc){
        updateRVOHeaders(RVOHeaderListToUpdate);
        
        if(accountListToUpdateToSyncRVOHeaders != null && accountListToUpdateToSyncRVOHeaders.size() > 0) {
    		AccSync_Vendor_Batch.updateVendors(accountListToUpdateToSyncRVOHeaders);
    		accountListToUpdateToSyncRVOHeaders = null;
    		runRVOHeadersForSync(setRVOHeaderIds, alreadyRequestedAccountIdSet, 10);
    	}
        if(errorLogToInsert.size() > 0) {
    	    insert errorLogToInsert;
    	}
    }
    
    public static void updateRVOHeaders(List<Return_VO_Header__c> RVOHeaderListToUpdate){
    	if(AccessControl.ifObjectFieldIsUpdateable('Return_VO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(RVOHeaderListToUpdate != null && RVOHeaderListToUpdate.size() > 0){ 
            preventOnAccountingSync = true;
            update RVOHeaderListToUpdate;
        }
    }
}