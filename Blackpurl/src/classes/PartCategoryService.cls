public with sharing class PartCategoryService {
    
    public static void syncParts(Set<Id> partIds) {
        AccSync_PartCategory_Batch.runPartForSync(partIds, 10);
    }
    
    public static void syncAccountingServer(AccountingPart partRecord, List<Part__c> partListToUpdate) {
    	if(QBUtil.isQBEnabled()) {
	        syncToQuickBooks(partRecord, partListToUpdate);
    	}
    }
    
    public static void syncToQuickBooks(AccountingPart partRecord, List<Part__c> partListToUpdate) {
        Part__c partRecToUpdate = new Part__c();
        partRecToUpdate.Id = partRecord.Id;
        try{
            QBJournalEntryServiceHelper.QuickBooksJournalEntry QBJournalEntry = new QBJournalEntryServiceHelper.QuickBooksJournalEntry(partRecord);
            String partJSONBody = System.JSON.serialize(QBJournalEntry);
            partRecToUpdate.Accounting_Response_Category__c = partJSONBody;
            HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('journalentry', partJSONBody);
            if(res.getStatusCode() == 200) { 
                String resParams = res.getBody();
                QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry JournalEntryPostResponse = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(resParams, QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                partRecToUpdate.Accounting_Id_Category__c = JournalEntryPostResponse.JournalEntry.Id;
                partRecToUpdate.Sync_Token_Category__c = JournalEntryPostResponse.JournalEntry.SyncToken;
                partRecToUpdate.Accounting_Response_Category__c += '\n\n'+resParams; 
                partRecToUpdate.Avail_For_QB_Sync_Category__c = false;
                partRecToUpdate.Accounting_Last_Sync_Time_Category__c = System.now(); 
            } else {
                partRecToUpdate.Accounting_Response_Category__c += '\n\n'+res.getBody();
                partRecToUpdate.Accounting_Response_Category__c += '\n\n'+res.getStatus();
                new LogService().createErrorLog('PartCategoryService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                              partRecord + LogService.METHOD_PARAM_SEPERATOR + partListToUpdate, LogService.QUICKBOOKS);
            }
        } catch(Exception e) {
            partRecToUpdate.Avail_For_QB_Sync_Category__c = true;
            partRecToUpdate.Accounting_Response_Category__c = e.getMessage();
            new LogService().createErrorLog('PartCategoryService', 'syncToQuickBooks() - exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
        	                                  partRecord + LogService.METHOD_PARAM_SEPERATOR + partListToUpdate, LogService.QUICKBOOKS);
        }
        if(partListToUpdate.size() > QBUtil.MAX_RECORDS_UPDATE_LIMIT) {
            AccSync_PartCategory_Batch.updateParts(partListToUpdate);
            partListToUpdate = new List<Part__c>();
        }
        partListToUpdate.add(partRecToUpdate);
    }
}