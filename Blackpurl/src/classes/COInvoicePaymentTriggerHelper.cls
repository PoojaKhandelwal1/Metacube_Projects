/**
 * Author: Pooja Khandelwal
 * Since: Jan. 13, 2017
 * Name: COInvoicePaymentTriggerHelper
 * Description: Helper class for triggers on CO Invoice Payment object
**/
public with sharing class COInvoicePaymentTriggerHelper {
    // List to store trigger new list
    public static List<CO_Invoice_Payment__c> COInvoicePaymentNewList = new List<CO_Invoice_Payment__c>();
    
    // List to store trigger old list
    public static List<CO_Invoice_Payment__c> COInvoicePaymentOldList = new List<CO_Invoice_Payment__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, CO_Invoice_Payment__c> COInvoicePaymentNewMap = new Map<Id, CO_Invoice_Payment__c>();

    // Map to store Old Trigger Map
    public static Map<Id, CO_Invoice_Payment__c> COInvoicePaymentOldMap = new Map<Id, CO_Invoice_Payment__c>();
     
    // Trigger run boolean
    public static Boolean isTriggerRun;
    
    // Trigger run boolean
    public static Boolean preventOnAccountingSync = false;
    
    private static BaseIntegrationService integrationRec;
    
    
    public static void populatesAccountingSyncFields() {
    	if(QBUtil.isQBEnabled()) {
			COInvoicePaymentNewList = QBSyncFlagService.manageCOInvoicePaymentJESyncFlag(COInvoicePaymentNewList);
		} else {
		    try {
               integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
               IntegrationSyncFlagService.manageCOInvoicePaymentSyncFlag(new List<BaseIntegrationService>{integrationRec}, COInvoicePaymentNewList);
            } catch(Exception e) {
               //handle here, do nothing
            }
        }
    }
    
    public static void setCOInvoicePaymentDataForAccountSync(){
    	Set<Id> setCOInvoicePaymentIds = new Set<Id>();
    	for(CO_Invoice_Payment__c COInvoicePaymentRec : COInvoicePaymentNewList){
    	    if(QBUtil.isQBEnabled()) { 
				if(COInvoicePaymentRec.availForQBJournalEntrySync__c) {
	    			setCOInvoicePaymentIds.add(COInvoicePaymentRec.Id);
				}
    	    }else if(integrationRec != null) {
                if(COInvoicePaymentRec.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.CO_INVOICE_PAYMENT).Sync_Flag_API_Name__c) != null && 
                        Boolean.valueOf(COInvoicePaymentRec.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.CO_INVOICE_PAYMENT).Sync_Flag_API_Name__c))) {
                    setCOInvoicePaymentIds.add(COInvoicePaymentRec.Id);
                }
            }
    	}

    	if(setCOInvoicePaymentIds.size() > 0) {
    		if(QBUtil.isQBEnabled()) {
                COInvoicePaymentJournalEntryService.syncCOInvoicePayments(setCOInvoicePaymentIds);
            } else {
                IntegrationBatchService.initiateBatch(setCOInvoicePaymentIds, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.CO_INVOICE_PAYMENT);
            }
    	}
    }
    
    
    
    public static void createStoreCredit(){
    	if(AccessControl.ifObjectFieldIsCreateable('Store_Credit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
    	List<CO_Invoice_Payment__c> newPaymentsList = [select Id, CO_Invoice_Header__r.CO_Header__r.Customer__c,
    													Payment_Method__c, CO_Invoice_Header__c, Amount__c
    													from CO_Invoice_Payment__c
    													where Id IN : COInvoicePaymentNewList];
    	List<Store_Credit__c> storeCreditListToInsert = new List<Store_Credit__c>(); 
    	Store_Credit__c storeCreditObj;
		for(CO_Invoice_Payment__c payment : newPaymentsList){ 
			if(payment.Payment_Method__c == 'Store Credit'){
				if(payment.CO_Invoice_Header__r.CO_Header__r.Customer__c == null){
					payment.addError('Store Credit can be used for Customer Only');
				}else{
					storeCreditObj = new Store_Credit__c();
					storeCreditObj.Customer__c = payment.CO_Invoice_Header__r.CO_Header__r.Customer__c;
					storeCreditObj.CO_Invoice_Header__c = payment.CO_Invoice_Header__c;
					storeCreditObj.Amount__c = -1 * payment.Amount__c;
					if(payment.Amount__c >= 0){
						storeCreditObj.Reference__c = 'Invoice Payment';
					}else{
						storeCreditObj.Reference__c = 'Return Invoice';
					}
					storeCreditListToInsert.add(storeCreditObj);
				}
			}
		}
		insert storeCreditListToInsert;    	
    }
}
