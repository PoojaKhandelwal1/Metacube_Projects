public with sharing class FIFOBucketService {
    
    public static Integer MAX_RECORDS_UPDATE_LIMIT = 500; 
    
    public static void syncPartFIFOBuckets(Set<Id> partFIFOBucketIds) {
        AccSync_FIFOBucket_Batch.runPartFIFOBucketForSync(partFIFOBucketIds, 10);
    }
    
    public static List<Log__c> syncAccountingServer(AccountingFIFOBucket partFIFOBucketRecord, List<Part_FIFO_Bucket__c> partFIFOBucketListToUpdate) {
        List<Log__c> errorLogToInsert = new List<Log__c>();
        if(QBUtil.isQBEnabled()) {
            errorLogToInsert = syncToQuickBooks(partFIFOBucketRecord, partFIFOBucketListToUpdate);
        }
        return errorLogToInsert;
    }
    
    public static List<Log__c> syncToQuickBooks(AccountingFIFOBucket FIFOBucketRecord, List<Part_FIFO_Bucket__c> partFIFOBucketListToUpdate) {
        Part_FIFO_Bucket__c partFIFOBucket = new Part_FIFO_Bucket__c();
        partFIFOBucket.Id = FIFOBucketRecord.Id;
        List<Log__c> errorLogList = new List<Log__c>();
        try{
            if(FIFOBucketRecord.SyncToken != null){
                HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('journalentry', FIFOBucketRecord.AccountingId);
                if(getResponse.getStatusCode() == 200){ 
                    QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry JournalEntryGetResponce = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(getResponse.getBody(), QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                    FIFOBucketRecord.SyncToken = JournalEntryGetResponce.JournalEntry.SyncToken;
                } else {
                    errorLogList.add(new LogService().createErrorLog('FIFOBucketService', 'syncToQuickBooks() - Get sync token Request From QB', getResponse.getBody(), getResponse.getStatusCode(), null, 
                                              FIFOBucketRecord + LogService.METHOD_PARAM_SEPERATOR + partFIFOBucketListToUpdate, LogService.QUICKBOOKS, false));
                }
            }
            QBJournalEntryServiceHelper.QuickBooksJournalEntry QBJournalEntry = new QBJournalEntryServiceHelper.QuickBooksJournalEntry(FIFOBucketRecord);
            String partFIFOBucketJSONBody = System.JSON.serialize(QBJournalEntry);
            System.debug('*************');
            System.debug(partFIFOBucketJSONBody);
            String response  = partFIFOBucketJSONBody;
            HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('journalentry', partFIFOBucketJSONBody);
            System.debug(res);
            if(res.getStatusCode() == 200) { 
                String resParams = res.getBody();
                QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry JournalEntryPostResponse = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(resParams, QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                partFIFOBucket.AccountingId__c = JournalEntryPostResponse.JournalEntry.Id;
                partFIFOBucket.SyncToken__c = JournalEntryPostResponse.JournalEntry.SyncToken;
                response += '\n\n'+resParams; 
                partFIFOBucket.availForQBSync__c = false;
                partFIFOBucket.accountingLastSyncTime__c = System.now(); 
            } else {
                response += '\n\n'+res.getBody();
                response += '\n\n'+res.getStatus();
                errorLogList.add(new LogService().createErrorLog('FIFOBucketService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                              FIFOBucketRecord + LogService.METHOD_PARAM_SEPERATOR + partFIFOBucketListToUpdate, LogService.QUICKBOOKS, false));
            }
            partFIFOBucket.AccountingResponse__c = QBUtil.truncateString(response, 32768);
        } catch(Exception e) {
            partFIFOBucket.availForQBSync__c = true;
            partFIFOBucket.AccountingResponse__c = e.getMessage();
            errorLogList.add(new LogService().createErrorLog('FIFOBucketService', 'syncToQuickBooks() - exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              FIFOBucketRecord + LogService.METHOD_PARAM_SEPERATOR + partFIFOBucketListToUpdate, LogService.QUICKBOOKS, false));
        }
        if(partFIFOBucketListToUpdate.size() > MAX_RECORDS_UPDATE_LIMIT) {
            AccSync_FIFOBucket_Batch.updatePartFIFOBuckets(partFIFOBucketListToUpdate);
            partFIFOBucketListToUpdate = new List<Part_FIFO_Bucket__c>();
        }
        partFIFOBucketListToUpdate.add(partFIFOBucket);
        
        return errorLogList;
    }
}