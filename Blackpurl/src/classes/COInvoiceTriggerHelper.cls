/**
 * Author: Pooja Khandelwal
 * Since: Dec. 23, 2014
 * Name: COInvoiceTriggerHelper
 * Description: Helper class for triggers on COInvoice object
**/
public with sharing class COInvoiceTriggerHelper {
    // List to store trigger new list
    public static List<CO_Invoice_Header__c> invoiceNewList = new List<CO_Invoice_Header__c>();
    
    // List to store trigger old list
    public static List<CO_Invoice_Header__c> invoiceOldList = new List<CO_Invoice_Header__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, CO_Invoice_Header__c> invoiceNewMap = new Map<Id, CO_Invoice_Header__c>();

    // Map to store Old Trigger Map
    public static Map<Id, CO_Invoice_Header__c> invoiceOldMap = new Map<Id, CO_Invoice_Header__c>();
     
    // Trigger run boolean
    public static Boolean preventOnAccountingSync = false;
    
    private static BaseIntegrationService integrationRec;
    
    public static void populatesAccountingSyncFields() {
        if(QBUtil.isQBEnabled()) {
            invoiceNewList = QBSyncFlagService.manageCOInvoiceSyncFlag(invoiceNewList, invoiceOldMap);
        } else {
            integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
            if(integrationRec != null) {
                IntegrationSyncFlagService.manageCOInvoiceSyncFlag(new List<BaseIntegrationService>{integrationRec}, invoiceNewList,invoiceOldMap);
            }
        }
    }
    
    public static void setCOInvoiceDataForAccountSync() {
        Set<Id> setCOInvoiceIds = new Set<Id>();
        Set<Id> setCOInvoiceIdsForJE = new Set<Id>();
        for(CO_Invoice_Header__c COInvoice : invoiceNewList) {
            if(QBUtil.isQBEnabled()) {
                if(COInvoice.availForQBSync__c) {
                    setCOInvoiceIds.add(COInvoice.Id);
                } else if(COInvoice.availForQBJournalEntrySync__c) {
                    setCOInvoiceIdsForJE.add(COInvoice.Id);
                }
            } else if(integrationRec != null) {
                if(COInvoice.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.INVOICE).Sync_Flag_API_Name__c) != null && 
                    Boolean.valueOf(COInvoice.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.INVOICE).Sync_Flag_API_Name__c))) {
                    setCOInvoiceIds.add(COInvoice.Id);
                } else if(COInvoice.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.CO_INVOICE_JE).Sync_Flag_API_Name__c) != null && 
                    Boolean.valueOf(COInvoice.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.CO_INVOICE_JE).Sync_Flag_API_Name__c))) {
                    setCOInvoiceIdsForJE.add(COInvoice.Id);
                }
            }
        }
        if(setCOInvoiceIds.size() > 0) {
            if(QBUtil.isQBEnabled()) { // only calling invoce syncing function which in turn will call invoice JE syncing function
                CustomerInvoiceService.syncCustomerInvoices(setCOInvoiceIds);
            } else {
                IntegrationBatchService.initiateBatch(setCOInvoiceIds, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.INVOICE);
            }  
            
        } else if(setCOInvoiceIdsForJE.size() > 0) { // if there is no record for invoice sync then call invoice JE sync from here
            if(QBUtil.isQBEnabled()) { 
                COInvoiceJournalEntryService.syncCustomerInvoices(setCOInvoiceIdsForJE);
            } else {
                IntegrationBatchService.initiateBatch(setCOInvoiceIdsForJE, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.CO_INVOICE_JE);
            } 
            
        }
    }
}
