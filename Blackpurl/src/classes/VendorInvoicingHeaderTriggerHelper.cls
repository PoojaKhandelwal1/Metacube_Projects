/**
 * Author: Pooja Khandelwal
 * Since: Dec. 23, 2014
 * Name: VendorInvoicingHeaderTriggerHelper
 * Description: Helper class for triggers on COInvoice object
**/
public with sharing class VendorInvoicingHeaderTriggerHelper {
    // List to store trigger new list
    public static List<Vendor_Invoicing_Header__c> invoiceNewList = new List<Vendor_Invoicing_Header__c>();
    
    // List to store trigger old list
    public static List<Vendor_Invoicing_Header__c> invoiceOldList = new List<Vendor_Invoicing_Header__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Vendor_Invoicing_Header__c> invoiceNewMap = new Map<Id, Vendor_Invoicing_Header__c>();

    // Map to store Old Trigger Map
    public static Map<Id, Vendor_Invoicing_Header__c> invoiceOldMap = new Map<Id, Vendor_Invoicing_Header__c>();
     
    // Trigger run boolean
    public static Boolean preventOnAccountingSync = false;
    
    private static BaseIntegrationService integrationRec;
    
    public static void populatesAccountingSyncFields() {
        if(QBUtil.isQBEnabled()) {
            QBSyncFlagService.manageVendorInvoiceSyncFlag(invoiceNewList, invoiceOldMap);
        } else {
            integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
            if(integrationRec != null) {
                IntegrationSyncFlagService.manageVOInvoiceSyncFlag(new List<BaseIntegrationService>{integrationRec}, invoiceNewList, invoiceOldMap);
            }
        }
    }
    
    public static void setVendorInvoiceDataForAccountSync() {
        Set<Id> vendorInvoiceIdSet = new Set<Id>();
        for(Vendor_Invoicing_Header__c vendorInvoiceRec : invoiceNewList) { 
	        if(vendorInvoiceRec.availForQBSync__c)   {
                vendorInvoiceIdSet.add(vendorInvoiceRec.Id);
	        } else if(integrationRec != null) {
                if(vendorInvoiceRec.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.VO_INVOICE).Sync_Flag_API_Name__c) != null && 
                    Boolean.valueOf(vendorInvoiceRec.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.VO_INVOICE).Sync_Flag_API_Name__c))) {
                    vendorInvoiceIdSet.add(vendorInvoiceRec.Id);
                }
            }
        }
        if(vendorInvoiceIdSet.size() > 0) {
            if(QBUtil.isQBEnabled()) {
                VendorInvoiceService.syncVIHeaders(vendorInvoiceIdSet);
            } else {
                IntegrationBatchService.initiateBatch(vendorInvoiceIdSet, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.VO_INVOICE);
            } 
        }
    }
}
