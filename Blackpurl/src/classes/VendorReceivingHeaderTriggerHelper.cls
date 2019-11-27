/**
 * Author: Richa Mittal
 * Since: Jan 09, 2017
 * Name: VendorReceivingHeaderTriggerHelper
 * Description: Helper class for triggers on Vendor_Receiving_Header__c object
**/
public with sharing class VendorReceivingHeaderTriggerHelper {
    // List to store trigger new list
    public static List<Vendor_Receiving_Header__c> receivingNewList = new List<Vendor_Receiving_Header__c>();
    
    // List to store trigger old list
    public static List<Vendor_Receiving_Header__c> receivingOldList = new List<Vendor_Receiving_Header__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Vendor_Receiving_Header__c> receivingNewMap = new Map<Id, Vendor_Receiving_Header__c>();

    // Map to store Old Trigger Map
    public static Map<Id, Vendor_Receiving_Header__c> receivingOldMap = new Map<Id, Vendor_Receiving_Header__c>();
     
    // Trigger run boolean
    public static Boolean isTriggerRun;
    
    // Trigger run boolean
    public static Boolean preventOnAccountingSync = false;
    
    private static BaseIntegrationService integrationRec;
    
    
    public static void populatesAccountingSyncFields() {
		if(QBUtil.isQBEnabled()) {
            receivingNewList = QBSyncFlagService.manageVendorReceivingSyncFlag(receivingNewList, receivingOldMap);
        } else {
        	integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
        	if(integrationRec != null) {
                IntegrationSyncFlagService.manageVendorReceivingSyncFlag(new List<BaseIntegrationService>{integrationRec}, receivingNewList, receivingOldMap);
        	}
        }
    }
    
    public static void setVendorReceivingDataForAccountSync() {
        Set<Id> setVendorReceivingIds = new Set<Id>();
        for(Vendor_Receiving_Header__c vendorReceiving : receivingNewList) { 
        	if(QBUtil.isQBEnabled()) {
	            if(vendorReceiving.availForQBJournalEntrySync__c) {
                    setVendorReceivingIds.add(vendorReceiving.Id);
                }
        	} else if(integrationRec != null) {
    	    	if(vendorReceiving.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.VENDOR_RECEIVING).Sync_Flag_API_Name__c) != null && 
	    			Boolean.valueOf(vendorReceiving.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.VENDOR_RECEIVING).Sync_Flag_API_Name__c))) {
    	        	setVendorReceivingIds.add(vendorReceiving.Id);
    	    	}
        	}
        }
        
        if(setVendorReceivingIds.size() > 0) {
        	if(QBUtil.isQBEnabled()) {
            	 VORJournalEntryService.syncVORs(setVendorReceivingIds);
        	} else {
    			IntegrationBatchService.initiateBatch(setVendorReceivingIds, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.VENDOR_RECEIVING);
    		}
        }   
    }
}