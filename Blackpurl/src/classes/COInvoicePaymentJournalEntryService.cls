public with sharing class COInvoicePaymentJournalEntryService {
    
    public static Integer MAX_RECORDS_UPDATE_LIMIT = 500; 
    
    public static void syncCOInvoicePayments(Set<Id> COInvoicePaymentIds){
        AccSync_COInvoicePayment_Batch.runCOInvoicePaymentsForSync(COInvoicePaymentIds, 10);
    }
    
    public static List<Log__c> syncAccountingServer(AccountingCOInvoicePayment COInvoicePaymentRecord, List<CO_Invoice_Payment__c> COInvoicePaymentListToUpdate){
        List<Log__c> errorLogToInsert = new List<Log__c>();
        if(QBUtil.isQBEnabled()) {
        	errorLogToInsert = syncToQuickBooks(COInvoicePaymentRecord, COInvoicePaymentListToUpdate);
        }
        return errorLogToInsert;
    }
    
    
    public static List<Log__c> syncToQuickBooks(AccountingCOInvoicePayment COInvoicePaymentRecord, List<CO_Invoice_Payment__c> COInvoicePaymentListToUpdate){
        CO_Invoice_Payment__c COInvoicePayment = new CO_Invoice_Payment__c();
        COInvoicePayment.Id = COInvoicePaymentRecord.COInvoicePaymentId;
        List<Log__c> errorLogList = new List<Log__c>();
        try{
            if(COInvoicePaymentRecord.JournalEntrySyncToken != null){
                HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('journalentry', COInvoicePaymentRecord.JournalEntryAccountingId);
                if(getResponse.getStatusCode() == 200){ 
                    QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry COInvoicePaymentJEGetResponce = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(getResponse.getBody(), QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                    COInvoicePaymentRecord.JournalEntrySyncToken = COInvoicePaymentJEGetResponce.JournalEntry.SyncToken;
                } else {
                	errorLogList.add(new LogService().createErrorLog('COInvoicePaymentJournalEntryService', 'syncToQuickBooks() - Get sync token Request From QB', getResponse.getBody(), getResponse.getStatusCode(), null, 
                                              COInvoicePaymentRecord + LogService.METHOD_PARAM_SEPERATOR + COInvoicePaymentListToUpdate, LogService.QUICKBOOKS, false));
                }
            }
            QBJournalEntryServiceHelper.QuickBooksJournalEntry QCOInvPaymentJE = new QBJournalEntryServiceHelper.QuickBooksJournalEntry(COInvoicePaymentRecord);
            String COInvoicePaymentJEJSONBody = System.JSON.serialize(QCOInvPaymentJE);
            HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('journalentry', COInvoicePaymentJEJSONBody);
            System.debug(res);
            String responseJE = COInvoicePaymentJEJSONBody;
            if(res.getStatusCode() == 200){ 
                String resParams = res.getBody();
                QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry COInvoicePaymentJEPostResponse = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(resParams, QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                
                COInvoicePayment.AccountingIdForJournalEntry__c = COInvoicePaymentJEPostResponse.JournalEntry.Id;
                COInvoicePayment.SyncTokenForJournalEntry__c = COInvoicePaymentJEPostResponse.JournalEntry.SyncToken;
                responseJE += '\n\n' + resParams;
                COInvoicePayment.availForQBJournalEntrySync__c = false;
                COInvoicePayment.accountingLastSyncTime__c = System.now(); 
            } else {
                responseJE += res.getBody() + '\n\n' + res.getStatus();
                errorLogList.add(new LogService().createErrorLog('COInvoicePaymentJournalEntryService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                              COInvoicePaymentRecord + LogService.METHOD_PARAM_SEPERATOR + COInvoicePaymentListToUpdate, LogService.QUICKBOOKS, false));
            }
            COInvoicePayment.AccountingResponseForJournalEntry__c = QBUtil.truncateString(responseJE, 131072);
        }catch(Exception e){
            COInvoicePayment.availForQBJournalEntrySync__c = true;
            COInvoicePayment.AccountingResponseForJournalEntry__c = e.getMessage();
        	errorLogList.add(new LogService().createErrorLog('COInvoicePaymentJournalEntryService', 'syncToQuickBooks() - exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
        	                                  COInvoicePaymentRecord + LogService.METHOD_PARAM_SEPERATOR + COInvoicePaymentListToUpdate, LogService.QUICKBOOKS, false));
        }
        
        if(COInvoicePaymentListToUpdate.size() > MAX_RECORDS_UPDATE_LIMIT){
            AccSync_COInvoicePayment_Batch.updateCOInvoicePayments(COInvoicePaymentListToUpdate);
            COInvoicePaymentListToUpdate = new List<CO_Invoice_Payment__c>();
        }
        COInvoicePaymentListToUpdate.add(COInvoicePayment);
        
        return errorLogList;
     }
}