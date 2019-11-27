global without sharing class SyncCOInvoiceJEBatch extends BaseSyncingBatch {
	
    global override Database.QueryLocator start(Database.BatchableContext bc) {
    	Map<String, List<String>> childObjectAPINameToFieldsList = new Map<String, List<String>>{	'CO_Invoice_Items__r' => new List<String>(AccountingCustomerInvoice.objectToFieldMap.get('COInvoiceItem')),
    																								'CO_Invoice_Payments__r' => new List<String>(AccountingCOInvoicePayment.fieldsList())
    																							};
        return Database.getQueryLocator(getBaseQuery('CO_Invoice_Header__c', new List<String>(AccountingCustomerInvoice.objectToFieldMap.get('COInvoiceHeader')), IntegrationUtility.CO_INVOICE_JE, childObjectAPINameToFieldsList));
    }
    
    global void execute(Database.batchableContext bc, List<CO_Invoice_Header__c> listCOInvoice) {
    	for(CO_Invoice_Header__c customerInvoice : listCOInvoice) {
			String accId = String.valueOf(customerInvoice.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.CO_INVOICE_JE).Integration_Id_API_Name__c));
			Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.JOURNAL_ENTRY => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
	    	this.webserviceLogs.addAll(integrationInstanceList[0].sync(new List<AccountingCustomerInvoice>{new AccountingCustomerInvoice(customerInvoice, customerInvoice.CO_Invoice_Items__r,customerInvoice.CO_Invoice_Payments__r,null)}, (List<SObject>) sobjctListToUpdate, 
	                                    IntegrationUtility.CO_INVOICE_JE, integrationEntityNameToActionMap));
        }
    }
    
    global override void finish(Database.batchableContext bc){
        finishAction();
    }
}
