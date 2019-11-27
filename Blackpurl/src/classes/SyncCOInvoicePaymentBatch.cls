global without sharing class SyncCOInvoicePaymentBatch extends BaseSyncingBatch {
    public String strQuery;
    global List<CO_Invoice_Payment__c> coInvoicePaymentListToUpdate;
    public List<WebService_Log__c> webserviceLogs;
    
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        coInvoicePaymentListToUpdate = new List<CO_Invoice_Payment__c>();
        strQuery = IntegrationBatchService.getBaseQuery('CO_Invoice_Payment__c', AccountingCOInvoicePayment.fieldsList(), 
                        integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.CO_INVOICE_PAYMENT).Sync_Flag_API_Name__c);
        if(idSet != null) {
            strQuery += ' AND Id IN :idSet';
        } 
        integrationInstanceList[0].failedRecordsMap = new Map<String, List<Object>>();
        integrationInstanceList[0].errorLogs = new List<Log__c>();
        this.webserviceLogs = new List<WebService_Log__c>();
        return Database.getQueryLocator(strQuery);
    }

    global void execute(Database.batchableContext bc, List<CO_Invoice_Payment__c> coInvoicePaymentList) {
        for(CO_Invoice_Payment__c coInvoicePaymentRec : coInvoicePaymentList){
            String accId = String.valueOf(coInvoicePaymentRec.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.CO_INVOICE_PAYMENT).Integration_Id_API_Name__c));
            if(String.isNotBlank(accId)) {
                Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.JOURNAL_ENTRY => IntegrationUtility.UPDATE_ACTION};
                this.webserviceLogs.addAll(integrationInstanceList[0].sync(new List<AccountingCOInvoicePayment>{new AccountingCOInvoicePayment(coInvoicePaymentRec)}, (List<SObject>) coInvoicePaymentListToUpdate, 
                                                IntegrationUtility.CO_INVOICE_PAYMENT, integrationEntityNameToActionMap));
            } else {
                Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.JOURNAL_ENTRY => IntegrationUtility.CREATE_ACTION};
                this.webserviceLogs.addAll(integrationInstanceList[0].sync(new List<AccountingCOInvoicePayment>{new AccountingCOInvoicePayment(coInvoicePaymentRec)}, (List<SObject>) coInvoicePaymentListToUpdate, 
                                                IntegrationUtility.CO_INVOICE_PAYMENT, integrationEntityNameToActionMap));
            }
        }
    }
 
    global override void finish(Database.batchableContext bc){
        updatepartFifoBucketActivityLineItems(coInvoicePaymentListToUpdate);
        //get a cloned map for exception to failed entities
        Map<String, List<Object>> failureMap = integrationInstanceList[0].getAndResetFailedRecordsMap();
        //Handle exceptions based on errors
        if(!failureMap.IsEmpty()) {
            IntegrationExceptionHandler integrationExceptionHandler = new IntegrationExceptionHandler(IntegrationUtility.CO_INVOICE_PAYMENT);
            for(String exceptionMessage :  failureMap.keySet()) {
                integrationExceptionHandler.handleException(exceptionMessage, integrationInstanceList[0].failedRecordsMap.get(exceptionMessage));
            }
        }
        if(integrationInstanceList[0].errorLogs.size() > 0) {
            insert integrationInstanceList[0].errorLogs;
            integrationInstanceList[0].errorLogs = new List<Log__c>();
        }
        if(!this.webserviceLogs.isEmpty()) {
           insert this.webserviceLogs;
        }
    }
    
    public static void updatepartFifoBucketActivityLineItems(List<CO_Invoice_Payment__c> coInvoicePaymentList){
        //system.assert(false, partFifoBucketActivityLineItemlist);
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(coInvoicePaymentList != null && coInvoicePaymentList.size() > 0){
            update coInvoicePaymentList;
        }
    }
}