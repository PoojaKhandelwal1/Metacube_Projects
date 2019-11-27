global without sharing class SyncCOInvoiceBatch extends BaseSyncingBatch {
    
    global override Database.QueryLocator start(Database.BatchableContext bc) {
    	Map<String, List<String>> childObjectAPINameToFieldsList = new Map<String, List<String>>{	'CO_Invoice_Items__r' => new List<String>(AccountingCustomerInvoice.objectToFieldMap.get('COInvoiceItem')),
    																								'CO_Invoice_Payments__r' => new List<String>(AccountingCOInvoicePayment.fieldsList())
    																							};
        return Database.getQueryLocator(getBaseQuery('CO_Invoice_Header__c', new List<String>(AccountingCustomerInvoice.objectToFieldMap.get('COInvoiceHeader')), IntegrationUtility.INVOICE, childObjectAPINameToFieldsList));
    }
    
    global void execute(Database.batchableContext bc, List<CO_Invoice_Header__c> listCOInvoice) {
    	for(CO_Invoice_Header__c customerInvoice : listCOInvoice) {
			Decimal invoiceTotal = customerInvoice.Total__c != null ? customerInvoice.Total__c : 0;
    		String syncingObjectType;
    		if(invoiceTotal < 0) {
    			syncingObjectType = IntegrationUtility.CREDIT_NOTE;
    		} else {
    			syncingObjectType = IntegrationUtility.INVOICE;
    		}
			String accId = String.valueOf(customerInvoice.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.INVOICE).Integration_Id_API_Name__c));
			Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{syncingObjectType => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
	    	this.webserviceLogs.addAll(integrationInstanceList[0].sync(new List<AccountingCustomerInvoice>{new AccountingCustomerInvoice(customerInvoice, customerInvoice.CO_Invoice_Items__r,customerInvoice.CO_Invoice_Payments__r,null)}, (List<SObject>) sobjctListToUpdate, 
	                                    IntegrationUtility.INVOICE, integrationEntityNameToActionMap));
        }
    }
    
    global override void finish(Database.batchableContext bc){
        IntegrationBatchService.initiateBatch(idSet, integrationInstanceList, IntegrationUtility.CO_INVOICE_JE);
        Set<Id> dealItemIdSet = checkLienPayoutsForSync(idSet);
        if(dealItemIdSet.size() > 0) {
        	new IntegrationUtility().getIntegrationEntityMetadata(integrationInstanceList, IntegrationUtility.LIEN_PAYOUT);
        	IntegrationBatchService.initiateBatch(dealItemIdSet, integrationInstanceList, IntegrationUtility.LIEN_PAYOUT);
        }
        finishAction();
    }
    
    private static Set<Id> checkLienPayoutsForSync(Set<Id> setcustomerInvoiceIds) {
    	if(!AccessControl.ifObjectFieldIsAccessible('Deal_Item__c')) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Set<Id> dealItemIdSet = new Set<Id>();
        List<Deal_Item__c> dealItemList = [SELECT Id FROM Deal_Item__c WHERE Type__c =: Constants.DEAL_ITEM_TYPE_TRADE_IN AND Lien_Payout__c > 0 
        										AND Finance_Company__c != null AND Lien_Payout_Avail_For_Xero_Sync__c = true 
        										AND Deal__r.Invoice_Number__c IN: setcustomerInvoiceIds];
        for(Deal_Item__c dealItemRec : dealItemList) {
        	dealItemIdSet.add(dealItemRec.Id);
        }
        return dealItemIdSet;
    }
}
