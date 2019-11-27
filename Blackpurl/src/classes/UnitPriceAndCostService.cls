public with sharing class UnitPriceAndCostService {
    
    public static Integer MAX_RECORDS_UPDATE_LIMIT = 500; 
    
    public static void syncUnitPriceAndCosts(Set<Id> unitPriceAndCostIds){
        AccSync_UnitPriceAndCost_Batch.runUnitPriceAndCostForSync(unitPriceAndCostIds, 10);
    }
    
    public static List<Log__c> syncAccountingServer(AccountingUnitPriceAndCost unitPriceAndCostRecord, List<Unit_Price_Cost__c> unitPriceAndCostListToUpdate){
    	List<Log__c> errorLogToInsert = new List<Log__c>();
    	if(QBUtil.isQBEnabled()) {
	        errorLogToInsert = syncToQuickBooks(unitPriceAndCostRecord, unitPriceAndCostListToUpdate);
    	}
    	return errorLogToInsert;
    }
    
    public static List<Log__c> syncToQuickBooks(AccountingUnitPriceAndCost PriceAndCostRecord, List<Unit_Price_Cost__c> unitPriceAndCostListToUpdate){
        Unit_Price_Cost__c unitPriceAndCost = new Unit_Price_Cost__c();
        unitPriceAndCost.Id = PriceAndCostRecord.Id;
        List<Log__c> errorLogList = new List<Log__c>();
        try{
            if(PriceAndCostRecord.JournalEntrySyncToken != null){
                HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('journalentry', PriceAndCostRecord.JournalEntryAccountingId);
                if(getResponse.getStatusCode() == 200){ 
                    QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry JournalEntryGetResponce = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(getResponse.getBody(), QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                    PriceAndCostRecord.JournalEntrySyncToken = JournalEntryGetResponce.JournalEntry.SyncToken;
                } else {
                	errorLogList.add(new LogService().createErrorLog('UnitPriceAndCostService', 'syncToQuickBooks() - Get sync token Request From QB', getResponse.getBody(), getResponse.getStatusCode(), null, 
                                              PriceAndCostRecord + LogService.METHOD_PARAM_SEPERATOR + unitPriceAndCostListToUpdate, LogService.QUICKBOOKS, false));
                }
            }
            QBJournalEntryServiceHelper.QuickBooksJournalEntry QBJournalEntry = new QBJournalEntryServiceHelper.QuickBooksJournalEntry(PriceAndCostRecord);
            String unitPriceAndCostJSONBody = System.JSON.serialize(QBJournalEntry);
            System.debug('*************');
            System.debug(unitPriceAndCostJSONBody);
            String response= unitPriceAndCostJSONBody;
            HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('journalentry', unitPriceAndCostJSONBody);
            System.debug(res);
            if(res.getStatusCode() == 200){ 
                String resParams = res.getBody();
                QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry JournalEntryPostResponse = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(resParams, QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                unitPriceAndCost.AccountingId__c = JournalEntryPostResponse.JournalEntry.Id;
                unitPriceAndCost.SyncToken__c = JournalEntryPostResponse.JournalEntry.SyncToken;
                response+= '\n\n'+resParams; 
                unitPriceAndCost.availForQBSync__c = false;
                unitPriceAndCost.accountingLastSyncTime__c = System.now(); 
            }else{
                response+= '\n\n'+res.getBody();
                response+= '\n\n'+res.getStatus();
                errorLogList.add(new LogService().createErrorLog('UnitPriceAndCostService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                              PriceAndCostRecord + LogService.METHOD_PARAM_SEPERATOR + unitPriceAndCostListToUpdate, LogService.QUICKBOOKS, false));
            }
            unitPriceAndCost.AccountingResponse__c  = QBUtil.truncateString(response, 32768);
        }catch(Exception e){
            unitPriceAndCost.availForQBSync__c = true;
            unitPriceAndCost.AccountingResponse__c += e.getMessage();
            errorLogList.add(new LogService().createErrorLog('UnitPriceAndCostService', 'syncToQuickBooks() - exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
        	                                  PriceAndCostRecord + LogService.METHOD_PARAM_SEPERATOR + unitPriceAndCostListToUpdate, LogService.QUICKBOOKS, false));
        }
        if(unitPriceAndCostListToUpdate.size() > MAX_RECORDS_UPDATE_LIMIT){
            AccSync_UnitPriceAndCost_Batch.updateUnitPriceAndCosts(unitPriceAndCostListToUpdate);
            unitPriceAndCostListToUpdate = new List<Unit_Price_Cost__c>();
        }
        unitPriceAndCostListToUpdate.add(unitPriceAndCost);
     	return errorLogList;
    }
}