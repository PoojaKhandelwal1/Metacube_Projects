public with sharing class DealItemService {
    
    public static void syncDealItems(Set<Id> dealItemIds) {
        AccSync_DealItem_Batch.runDealItemForSync(dealItemIds, 10);
    }
    
    public static void syncAccountingServer(AccountingDealItem dealItemRecord, List<Deal_Item__c> dealItemListToUpdate) {
        if(QBUtil.isQBEnabled()) {
            syncToQuickBooks(dealItemRecord, dealItemListToUpdate);
        }
    }
    
    public static void syncToQuickBooks(AccountingDealItem dealItemRecord, List<Deal_Item__c> dealItemListToUpdate) {
        Deal_Item__c dealItemRecToUpdate = new Deal_Item__c();
        dealItemRecToUpdate.Id = dealItemRecord.Id;
        try{
            QBJournalEntryServiceHelper.QuickBooksJournalEntry QBJournalEntry = new QBJournalEntryServiceHelper.QuickBooksJournalEntry(dealItemRecord);
            String dealItemJSONBody = System.JSON.serialize(QBJournalEntry);
            dealItemRecToUpdate.Accounting_Response__c = dealItemJSONBody;
            HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('journalentry', dealItemJSONBody);
            if(res.getStatusCode() == 200) { 
                String resParams = res.getBody();
                QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry JournalEntryPostResponse = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(resParams, QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                dealItemRecToUpdate.Accounting_Id__c = JournalEntryPostResponse.JournalEntry.Id;
                dealItemRecToUpdate.Sync_Token__c = JournalEntryPostResponse.JournalEntry.SyncToken;
                dealItemRecToUpdate.Accounting_Response__c += '\n\n'+resParams; 
                dealItemRecToUpdate.Avail_For_QB_Sync__c = false;
                dealItemRecToUpdate.Accounting_Last_Sync_Time__c = System.now(); 
            } else {
                dealItemRecToUpdate.Accounting_Response__c += '\n\n'+res.getBody();
                dealItemRecToUpdate.Accounting_Response__c += '\n\n'+res.getStatus();
                new LogService().createErrorLog('DealItemService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                              dealItemRecord + LogService.METHOD_PARAM_SEPERATOR + dealItemListToUpdate, LogService.QUICKBOOKS);
            }
        } catch(Exception e) {
            dealItemRecToUpdate.Avail_For_QB_Sync__c = true;
            dealItemRecToUpdate.Accounting_Response__c = e.getMessage();
            new LogService().createErrorLog('DealItemService', 'syncToQuickBooks() - exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              dealItemRecord + LogService.METHOD_PARAM_SEPERATOR + dealItemListToUpdate, LogService.QUICKBOOKS);
        }
        if(dealItemListToUpdate.size() > QBUtil.MAX_RECORDS_UPDATE_LIMIT) {
            AccSync_DealItem_Batch.updateDealItems(dealItemListToUpdate);
            dealItemListToUpdate = new List<Deal_Item__c>();
        }
        dealItemListToUpdate.add(dealItemRecToUpdate);
    }
}