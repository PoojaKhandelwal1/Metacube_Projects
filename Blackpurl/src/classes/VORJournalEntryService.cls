public with sharing class VORJournalEntryService {
    
    public static Integer MAX_RECORDS_UPDATE_LIMIT = 500; 
    
    public static void syncVORs(Set<Id> VORIds){
        //System.assert(false, VORIds);
        AccSync_VORJournalEntry_Batch.runVORsForSync(VORIds, 10);
    }
    
    public static List<Log__c> syncAccountingServer(AccountingVendorReceiving VORRecord, List<Vendor_Receiving_Header__c> VORListToUpdate){
        List<Log__c> errorLogToInsert = new List<Log__c>();
        if(QBUtil.isQBEnabled()) {
            errorLogToInsert = syncToQuickBooks(VORRecord, VORListToUpdate);
        }
        return errorLogToInsert;
    }
    
    public static List<Log__c> syncToQuickBooks(AccountingVendorReceiving VORRecord, List<Vendor_Receiving_Header__c> VORListToUpdate){
        //System.assert(false, 0);
        Vendor_Receiving_Header__c VORHeader = new Vendor_Receiving_Header__c();
        VORHeader.Id = VORRecord.AccountingVORHeaderRec.VORId;
        List<Log__c> errorLogList = new List<Log__c>();
        try{
            if(VORRecord.AccountingVORHeaderRec.JournalEntrySyncToken != null){
                HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('journalentry', VORRecord.AccountingVORHeaderRec.JournalEntryAccountingId);
                if(getResponse.getStatusCode() == 200){ 
                    QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry VORJournalEntryGetResponce = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(getResponse.getBody(), QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                    VORRecord.AccountingVORHeaderRec.JournalEntrySyncToken = VORJournalEntryGetResponce.JournalEntry.SyncToken;
                } else {
                	errorLogList.add(new LogService().createErrorLog('VORJournalEntryService', 'syncToQuickBooks() - Get sync token Request From QB', getResponse.getBody(), getResponse.getStatusCode(), null, 
                                              VORRecord + LogService.METHOD_PARAM_SEPERATOR + VORListToUpdate, LogService.QUICKBOOKS, false));
                }
            }
            QBJournalEntryServiceHelper.QuickBooksJournalEntry QVORJE = new QBJournalEntryServiceHelper.QuickBooksJournalEntry(VORRecord);
            String VORJournalEntryJSONBody = System.JSON.serialize(QVORJE);
            System.debug('*************');
            System.debug(VORJournalEntryJSONBody);
            String response = VORJournalEntryJSONBody;
            HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('journalentry', VORJournalEntryJSONBody);
            System.debug(res);
            if(res.getStatusCode() == 200){ 
                String resParams = res.getBody();
                QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry VORJournalEntryPostResponse = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(resParams, QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                VORHeader.AccountingIdForJournalEntry__c = VORJournalEntryPostResponse.JournalEntry.Id;
                VORHeader.SyncTokenForJournalEntry__c = VORJournalEntryPostResponse.JournalEntry.SyncToken;
                response += '\n\n'+resParams; 
                VORHeader.availForQBJournalEntrySync__c = false;
                VORHeader.accountingLastSyncTime__c = System.now(); 
            }else{
                response += '\n\n'+res.getBody();
                response += '\n\n'+res.getStatus();
                errorLogList.add(new LogService().createErrorLog('VORJournalEntryService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                              VORRecord + LogService.METHOD_PARAM_SEPERATOR + VORListToUpdate, LogService.QUICKBOOKS, false));
            }
            VORHeader.AccountingResponseForJournalEntry__c = QBUtil.truncateString(response, 131072);
        }catch(Exception e){
            //System.assert(false, e);
            VORHeader.availForQBJournalEntrySync__c = true;
            VORHeader.AccountingResponseForJournalEntry__c = e.getMessage();
            errorLogList.add(new LogService().createErrorLog('VORJournalEntryService', 'syncToQuickBooks() - exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
        	                                  VORRecord + LogService.METHOD_PARAM_SEPERATOR + VORListToUpdate, LogService.QUICKBOOKS, false));
        }
        if(VORListToUpdate.size() > MAX_RECORDS_UPDATE_LIMIT){
            AccSync_VORJournalEntry_Batch.updateVORs(VORListToUpdate);
            VORListToUpdate = new List<Vendor_Receiving_Header__c>();
        }
        VORListToUpdate.add(VORHeader); 
        
        return errorLogList;
    } 
}