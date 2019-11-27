public with sharing class FIFOBucketActivityLineItemService {
    
    public static Integer MAX_RECORDS_UPDATE_LIMIT = 500; 
     
    public static void syncPartFIFOBucketActivityLineItems(Set<Id> partFIFOBucketActivityLineItemIds) {
        AccSync_FIFOBucketActivityLineItem_Batch.runPartFIFOBucketActivityLineItemForSync(partFIFOBucketActivityLineItemIds, 10);
    }
    
    public static List<Log__c> syncAccountingServer(AccountingFIFOBucketActivityLineItem partFIFOBucketActivityLineItemRecord, List<Part_FIFO_Bucket_Activity_Line_Item__c> partFIFOBucketActivityLineItemListToUpdate){
        List<Log__c> errorLogToInsert = new List<Log__c>();
        if(QBUtil.isQBEnabled()) {
            syncToQuickBooks(partFIFOBucketActivityLineItemRecord, partFIFOBucketActivityLineItemListToUpdate);
        }
        return errorLogToInsert;
    }
    
    public static List<Log__c> syncToQuickBooks(AccountingFIFOBucketActivityLineItem FIFOBucketActivityLineItemRecord, List<Part_FIFO_Bucket_Activity_Line_Item__c> partFIFOBucketActivityLineItemListToUpdate) {
        Part_FIFO_Bucket_Activity_Line_Item__c partFIFOBucketActivityLineItem = new Part_FIFO_Bucket_Activity_Line_Item__c();
        partFIFOBucketActivityLineItem.Id = FIFOBucketActivityLineItemRecord.Id;
        List<Log__c> errorLogList = new List<Log__c>();
        try{
            if(FIFOBucketActivityLineItemRecord.SyncToken != null) {
                HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('journalentry', FIFOBucketActivityLineItemRecord.AccountingId);
                if(getResponse.getStatusCode() == 200) { 
                    QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry JournalEntryGetResponce = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(getResponse.getBody(), QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                    FIFOBucketActivityLineItemRecord.SyncToken = JournalEntryGetResponce.JournalEntry.SyncToken;
                } else {
                    errorLogList.add(new LogService().createErrorLog('FIFOBucketActivityLineItemService', 'syncToQuickBooks() - Get sync token Request From QB', getResponse.getBody(), getResponse.getStatusCode(), null, 
                                              FIFOBucketActivityLineItemRecord + LogService.METHOD_PARAM_SEPERATOR + partFIFOBucketActivityLineItemListToUpdate, LogService.QUICKBOOKS, false));
                }
            }
            QBJournalEntryServiceHelper.QuickBooksJournalEntry QBJournalEntry = new QBJournalEntryServiceHelper.QuickBooksJournalEntry(FIFOBucketActivityLineItemRecord);
            String partFIFOBucketActivityLineItemJSONBody = System.JSON.serialize(QBJournalEntry);
            System.debug('*************');
            System.debug(partFIFOBucketActivityLineItemJSONBody);
            String response = partFIFOBucketActivityLineItemJSONBody;
            HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('journalentry', partFIFOBucketActivityLineItemJSONBody);
            System.debug(res);
            if(res.getStatusCode() == 200) { 
                String resParams = res.getBody();
                QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry JournalEntryPostResponse = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(resParams, QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                partFIFOBucketActivityLineItem.AccountingId__c = JournalEntryPostResponse.JournalEntry.Id;
                partFIFOBucketActivityLineItem.SyncToken__c = JournalEntryPostResponse.JournalEntry.SyncToken;
                response += '\n\n'+resParams; 
                partFIFOBucketActivityLineItem.availForQBSync__c = false;
                partFIFOBucketActivityLineItem.accountingLastSyncTime__c = System.now(); 
            } else {
                response += '\n\n'+res.getBody();
                response += '\n\n'+res.getStatus();
                errorLogList.add(new LogService().createErrorLog('FIFOBucketActivityLineItemService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                              FIFOBucketActivityLineItemRecord + LogService.METHOD_PARAM_SEPERATOR + partFIFOBucketActivityLineItemListToUpdate, LogService.QUICKBOOKS, false));
            }
            partFIFOBucketActivityLineItem.AccountingResponse__c = QBUtil.truncateString(response, 32768);
        } catch(Exception e) {
            partFIFOBucketActivityLineItem.availForQBSync__c = true;
            partFIFOBucketActivityLineItem.AccountingResponse__c = e.getMessage();
            errorLogList.add(new LogService().createErrorLog('FIFOBucketActivityLineItemService', 'syncToQuickBooks() - exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              FIFOBucketActivityLineItemRecord + LogService.METHOD_PARAM_SEPERATOR + partFIFOBucketActivityLineItemListToUpdate, LogService.QUICKBOOKS, false));
        }
        if(partFIFOBucketActivityLineItemListToUpdate.size() > MAX_RECORDS_UPDATE_LIMIT){
            AccSync_FIFOBucketActivityLineItem_Batch.updatePartFIFOBucketActivityLineItems(partFIFOBucketActivityLineItemListToUpdate);
            partFIFOBucketActivityLineItemListToUpdate = new List<Part_FIFO_Bucket_Activity_Line_Item__c>();
        }
        partFIFOBucketActivityLineItemListToUpdate.add(partFIFOBucketActivityLineItem); 
        
        return errorLogList;
        
    }
}