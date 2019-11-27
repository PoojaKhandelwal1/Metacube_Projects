public with sharing class CODepositJournalEntryService {
    
    public static Integer MAX_RECORDS_UPDATE_LIMIT = 500; 
    
    public static void syncCODeposits(Set<Id> CODepositIds){
        AccSync_CODepositJournalEntry_Batch.runCODepositsForSync(CODepositIds, 10);
    }
    
    public static List<Log__c> syncAccountingServer(AccountingCODeposit CODepositRecord, List<CO_Deposit__c> CODepositListToUpdate){
    	List<Log__c> errorLogToInsert = new List<Log__c>();
    	if(QBUtil.isQBEnabled()) {
        	errorLogToInsert = syncToQuickBooks(CODepositRecord, CODepositListToUpdate);
    	}
    	return errorLogToInsert;
    }
    
    
    public static List<Log__c> syncToQuickBooks(AccountingCODeposit CODepositRecord, List<CO_Deposit__c> CODepositListToUpdate){
        CO_Deposit__c CODeposit = new CO_Deposit__c();
        CODeposit.Id = CODepositRecord.CODepositId;
        List<Log__c> errorLogList = new List<Log__c>();
        try{
            if(CODepositRecord.JournalEntrySyncToken != null){
                HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('journalentry', CODepositRecord.JournalEntryAccountingId);
                if(getResponse.getStatusCode() == 200){ 
                    QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry CODepositJEGetResponce = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(getResponse.getBody(), QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                    CODepositRecord.JournalEntrySyncToken = CODepositJEGetResponce.JournalEntry.SyncToken;
                } else {
                	errorLogList.add(new LogService().createErrorLog('CODepositJournalEntryService', 'syncToQuickBooks() - Get sync token Request From QB', getResponse.getBody(), getResponse.getStatusCode(), null, 
                                              CODepositRecord + LogService.METHOD_PARAM_SEPERATOR + CODepositListToUpdate, LogService.QUICKBOOKS, false));
                }
            }
            QBJournalEntryServiceHelper.QuickBooksJournalEntry QCODepositJE = new QBJournalEntryServiceHelper.QuickBooksJournalEntry(CODepositRecord);
            String CODepositJEJSONBody = System.JSON.serialize(QCODepositJE);
            HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('journalentry', CODepositJEJSONBody);
            System.debug(res);
            String response =  CODepositJEJSONBody;
            if(res.getStatusCode() == 200){ 
                String resParams = res.getBody();
                QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry CODepositJEPostResponse = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(resParams, QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                
                CODeposit.AccountingIdForJournalEntry__c = CODepositJEPostResponse.JournalEntry.Id;
                CODeposit.SyncTokenForJournalEntry__c = CODepositJEPostResponse.JournalEntry.SyncToken;
                response += '\n\n' + resParams;
                CODeposit.availForQBJournalEntrySync__c = false;
                CODeposit.accountingLastSyncTime__c = System.now(); 
            }else{
                response += res.getBody() + '\n\n' + res.getStatus();
                errorLogList.add(new LogService().createErrorLog('CODepositJournalEntryService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                              CODepositRecord + LogService.METHOD_PARAM_SEPERATOR + CODepositListToUpdate, LogService.QUICKBOOKS, false));
            }
            CODeposit.AccountingResponseForJournalEntry__c = QBUtil.truncateString(response, 32768);
        }catch(Exception e){
            CODeposit.availForQBJournalEntrySync__c = true;
            CODeposit.AccountingResponseForJournalEntry__c = e.getMessage();
            errorLogList.add(new LogService().createErrorLog('CODepositJournalEntryService', 'syncToQuickBooks() - exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
        	                                  CODepositRecord + LogService.METHOD_PARAM_SEPERATOR + CODepositListToUpdate, LogService.QUICKBOOKS, false));
        }
        if(CODepositListToUpdate.size() > MAX_RECORDS_UPDATE_LIMIT){
            AccSync_CODepositJournalEntry_Batch.updateCODeposits(CODepositListToUpdate);
            CODepositListToUpdate = new List<CO_Deposit__c>();
        }
        CODepositListToUpdate.add(CODeposit);
        return errorLogList;
     }
}