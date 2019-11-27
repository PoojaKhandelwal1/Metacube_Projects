/**
 * Author: Hitesh Gupta
 * Since: Oct, 10, 2017
 * Name: ReturnVOHeaderTriggerHelper
 * Description: Helper class for triggers on ReturnVO object
**/
public with sharing class ReturnVOHeaderTriggerHelper {
	
    // List to store trigger new list
    public static List<Return_VO_Header__c> returnVONewList = new List<Return_VO_Header__c>();
    
    // List to store trigger old list
    public static List<Return_VO_Header__c> returnVOOldList = new List<Return_VO_Header__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Return_VO_Header__c> returnVONewMap = new Map<Id, Return_VO_Header__c>();

    // Map to store Old Trigger Map
    public static Map<Id, Return_VO_Header__c> returnVOOldMap = new Map<Id, Return_VO_Header__c>();
    
    private static BaseIntegrationService integrationRec;
    
    // Trigger run boolean
    public static Boolean preventOnAccountingSync = false;
    
    public static void populatesAccountingSyncFields(){
        if(QBUtil.isQBEnabled()) {
            QBSyncFlagService.manageVendorReturnSyncFlag(returnVONewList, returnVOOldMap);
        } else {
            integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
            if(integrationRec != null) {
                IntegrationSyncFlagService.manageVOReturnSyncFlag(new List<BaseIntegrationService>{integrationRec}, returnVONewList, returnVOOldMap);
            }
        }
    }
    
    public static void setVendorInvoiceDataForAccountSync(){
        Set<Id> setReturnVOIds = new Set<Id>();
        for(Return_VO_Header__c returnVOHeader : returnVONewList){ 
            if(returnVOHeader.availForQBSync__c) {
                setReturnVOIds.add(returnVOHeader.Id);
            } else if(integrationRec != null) {
                if(returnVOHeader.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.VO_RETURN).Sync_Flag_API_Name__c) != null && 
                    Boolean.valueOf(returnVOHeader.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.VO_RETURN).Sync_Flag_API_Name__c))) {
                    setReturnVOIds.add(returnVOHeader.Id);
                }
            }
        }
        if(setReturnVOIds.size() > 0) {
            if(QBUtil.isQBEnabled()) {
                VendorReturnService.syncRVOHeaders(setReturnVOIds);
            } else {
                IntegrationBatchService.initiateBatch(setReturnVOIds, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.VO_RETURN);
            } 
        }
    }
}