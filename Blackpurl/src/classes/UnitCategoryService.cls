public with sharing class UnitCategoryService {
    
    public static void syncUnits(Set<Id> unitIds) {
        AccSync_UnitCategory_Batch.runUnitForSync(unitIds, 10);
    }
    
    public static void syncAccountingServer(AccountingUnit unitRecord, List<Customer_Owned_Unit__c> unitListToUpdate) {
        if(QBUtil.isQBEnabled()) {
            syncToQuickBooks(unitRecord, unitListToUpdate);
        }
    }
    
    public static void syncToQuickBooks(AccountingUnit unitRecord, List<Customer_Owned_Unit__c> unitListToUpdate) {
        Customer_Owned_Unit__c unitRecToUpdate = new Customer_Owned_Unit__c();
        unitRecToUpdate.Id = unitRecord.Id;
        try{
            QBJournalEntryServiceHelper.QuickBooksJournalEntry QBJournalEntry = new QBJournalEntryServiceHelper.QuickBooksJournalEntry(unitRecord);
            String unitJSONBody = System.JSON.serialize(QBJournalEntry);
            unitRecToUpdate.Accounting_Response_Category__c = unitJSONBody;
            HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('journalentry', unitJSONBody);
            if(res.getStatusCode() == 200) { 
                String resParams = res.getBody();
                QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry JournalEntryPostResponse = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(resParams, QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                unitRecToUpdate.Accounting_Id_Category__c = JournalEntryPostResponse.JournalEntry.Id;
                unitRecToUpdate.Sync_Token_Category__c = JournalEntryPostResponse.JournalEntry.SyncToken;
                unitRecToUpdate.Accounting_Response_Category__c += '\n\n'+resParams; 
                unitRecToUpdate.Avail_For_QB_Sync_Category__c = false;
                unitRecToUpdate.Accounting_Last_Sync_Time_Category__c = System.now(); 
            } else {
                unitRecToUpdate.Accounting_Response_Category__c += '\n\n'+res.getBody();
                unitRecToUpdate.Accounting_Response_Category__c += '\n\n'+res.getStatus();
                new LogService().createErrorLog('UnitCategoryService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                              unitRecord + LogService.METHOD_PARAM_SEPERATOR + unitListToUpdate, LogService.QUICKBOOKS);
            }
        } catch(Exception e) {
            unitRecToUpdate.Avail_For_QB_Sync_Category__c = true;
            unitRecToUpdate.Accounting_Response_Category__c = e.getMessage();
            new LogService().createErrorLog('UnitCategoryService', 'syncToQuickBooks() - exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              unitRecord + LogService.METHOD_PARAM_SEPERATOR + unitListToUpdate, LogService.QUICKBOOKS);
        }
        if(unitListToUpdate.size() > QBUtil.MAX_RECORDS_UPDATE_LIMIT) {
            AccSync_UnitCategory_Batch.updateUnits(unitListToUpdate);
            unitListToUpdate = new List<Customer_Owned_Unit__c>();
        }
        unitListToUpdate.add(unitRecToUpdate);
    }
}