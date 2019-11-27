/**
 * Author: Richa Mittal
 * Since: Aug 24, 2017
 * Name: StoreCreditTriggerHelper
 * Description: Helper class for triggers on Store Credit object
**/
public with sharing class StoreCreditTriggerHelper {
    // List to store trigger new list
    public static List<Store_Credit__c> storeCreditNewList = new List<Store_Credit__c>();
    
    // List to store trigger old list
    public static List<Store_Credit__c> storeCreditOldList = new List<Store_Credit__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Store_Credit__c> storeCreditNewMap = new Map<Id, Store_Credit__c>();

    // Map to store Old Trigger Map
    public static Map<Id, Store_Credit__c> storeCreditOldMap = new Map<Id, Store_Credit__c>();
    
    private static BaseIntegrationService integrationRec;
     
    // Trigger run boolean
    public static Boolean preventOnAccountingSync = false;
    
    public static void populatesAccountingSyncFields() {
        if(QBUtil.isQBEnabled()) {
            QBSyncFlagService.manageStoreCreditSyncFlag(storeCreditNewList);
        } else {
        		try{
		        	integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
		        		if(integrationRec != null) {
		            		IntegrationSyncFlagService.manageStoreCreditSyncFlag(new List<BaseIntegrationService>{integrationRec}, storeCreditNewList);
		        		}
        		} catch(exception e){
        		}	
        }
    }
    
    public static void setStoreCreditDataForAccountSync() { 
    	Set<Id> storeCreditIdSet = new Set<Id>();
    	for(Store_Credit__c storeCreditRec : StoreCreditNewList){ 
			if(QBUtil.isQBEnabled()) {	
				if(storeCreditRec.availForQBSync__c) {
	    			storeCreditIdSet.add(storeCreditRec.Id);
	    		}
    		} else if(integrationRec != null) {
    	    	if(storeCreditRec.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.STORE_CREDIT).Sync_Flag_API_Name__c) != null && 
    	    			Boolean.valueOf(storeCreditRec.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.STORE_CREDIT).Sync_Flag_API_Name__c))) {
    	        		storeCreditIdSet.add(storeCreditRec.Id);
    	    	}
    	    }	 
    	if(storeCreditIdSet.size() > 0) { 
    		if(QBUtil.isQBEnabled()) {
    			StoreCreditJournalEntryService.syncStoreCredits(storeCreditIdSet);
    		} else {
    			IntegrationBatchService.initiateBatch(storeCreditIdSet, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.STORE_CREDIT);
    		}
    		}
    	}
	}
}