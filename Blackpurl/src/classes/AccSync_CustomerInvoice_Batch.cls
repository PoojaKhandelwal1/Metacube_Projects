global with sharing class AccSync_CustomerInvoice_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    
    public String strQuery;
    public Set<Id> setcustomerInvoiceIds;
    public static Set<Id> customerInvoiceIds;
    global List<CO_Invoice_Header__c> customerInvoiceListToUpdate;
    public List<Account> accountListToUpdateToSyncCOInvoice;
    public Set<Id> alreadyRequestedAccountIdSet;
    global List<Log__c> errorLogToInsert;
    
    public static void runCustomerInvoicesForSync(Set<Id> setCustomerInvoiceIdVal, Integer batchSize) {
        runCustomerInvoicesForSync(setCustomerInvoiceIdVal, new Set<Id>(), batchSize);
    }
    
    public static void runCustomerInvoicesForSync(Set<Id> setCustomerInvoiceIdVal, Set<Id> alreadyRequestedAccountIdSet, Integer batchSize) {
        AccSync_CustomerInvoice_Batch clsAccSyncBatch = new AccSync_CustomerInvoice_Batch();
        clsAccSyncBatch.setcustomerInvoiceIds = setCustomerInvoiceIdVal;
        clsAccSyncBatch.alreadyRequestedAccountIdSet = alreadyRequestedAccountIdSet;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :setcustomerInvoiceIds';
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);
    }
        
    public static String getBaseQuery() {
        String baseQuery = 'SELECT '; 
        //fields of CO Invoice header 
        for(String fieldName : AccountingCustomerInvoice.objectToFieldMap.get('COInvoiceHeader')) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
            
        // Child Query: fields of CO Invoice Item 
        baseQuery += '( SELECT ';
        for(String fieldName : AccountingCustomerInvoice.objectToFieldMap.get('COInvoiceItem')) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM CO_Invoice_Items__r ), '; 

        // Child Query: fields of CO Invoice Payment 
        baseQuery += '( SELECT ';
        for(String fieldName : AccountingCOInvoicePayment.fieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM CO_Invoice_Payments__r ) ';
        
        baseQuery += 'FROM CO_Invoice_Header__c ';
        baseQuery += 'WHERE availForQBSync__c = true'; //  AND Invoice_Status__c = \'Closed\'
        return baseQuery;
    }
        
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
        customerInvoiceListToUpdate = new List<CO_Invoice_Header__c>();
        errorLogToInsert = new List<Log__c>();
        if(String.isBlank(strQuery)) {
            strQuery = getBaseQuery();
            if(setcustomerInvoiceIds != null && setcustomerInvoiceIds.size() > 0) {
                strQuery += ' AND Id IN :setcustomerInvoiceIds';
            }
        } 
        return Database.getQueryLocator(strQuery); 
    }

    global void execute(Database.batchableContext bc, List<CO_Invoice_Header__c> listCustomerInvoices) {
        Map<Id, Id> soHeaderIdToInvoiceHeaderIdMap = new Map<Id, Id>();
        Map<Id, CO_Invoice_Item__c> coInvoiceHeaderIdToCOInvoiceItemRecMap = new Map<Id, CO_Invoice_Item__c>();
        for(CO_Invoice_Header__c customerInvoice : listCustomerInvoices) {
            for(CO_Invoice_Item__c coInvoiceItem: customerInvoice.CO_Invoice_Items__r) {
                if(coInvoiceItem.Service_Order_Header__c != null && coInvoiceItem.Service_Order_Header__r.Transaction_Type__r.Type__c == 'Third-Party' && customerInvoice.Checkout_Type__c != null && customerInvoice.Checkout_Type__c == 'Third-Party') {
                    soHeaderIdToInvoiceHeaderIdMap.put(coInvoiceItem.Service_Order_Header__c, customerInvoice.Id);
                    coInvoiceHeaderIdToCOInvoiceItemRecMap.put(customerInvoice.Id, coInvoiceItem);
                }
            }
        }
        Map<Id, String> invoiceHeaderIdToClaimNumberMap = new Map<Id, String>();
        List<Claim__c> claimList = [Select Service_Order_Header__c, Provider_Claim_Number__c from Claim__c where Service_Order_Header__c IN : soHeaderIdToInvoiceHeaderIdMap.keySet()];
        for(Claim__c claimRec : claimList) {
            invoiceHeaderIdToClaimNumberMap.put(soHeaderIdToInvoiceHeaderIdMap.get(claimRec.Service_Order_Header__c), claimRec.Provider_Claim_Number__c);
        }
        
        accountListToUpdateToSyncCOInvoice = new List<Account>();
        for(CO_Invoice_Header__c customerInvoice : listCustomerInvoices) {
            if(customerInvoice.Checkout_Type__c != 'Deal') {
                if(coInvoiceHeaderIdToCOInvoiceItemRecMap.size() > 0 && coInvoiceHeaderIdToCOInvoiceItemRecMap.get(customerInvoice.Id).Service_Order_Header__r.Provider__c != null
                    && coInvoiceHeaderIdToCOInvoiceItemRecMap.get(customerInvoice.Id).Service_Order_Header__r.Provider__r.AccountingId__c == null
                    && !alreadyRequestedAccountIdSet.contains(coInvoiceHeaderIdToCOInvoiceItemRecMap.get(customerInvoice.Id).Service_Order_Header__r.Provider__c)) {
                    Id providerId = coInvoiceHeaderIdToCOInvoiceItemRecMap.get(customerInvoice.Id).Service_Order_Header__r.Provider__c;
                    List<Account> accountListToUpdate = AccSync_Customer_Batch.getAccountListToUpdateById(new Set<Id>{providerId});
                    for(Account account: accountListToUpdate){
                        accountListToUpdateToSyncCOInvoice.add(account);
                        alreadyRequestedAccountIdSet.add(account.Id);
                    }   
                } else if(customerInvoice.CO_Header__r.Customer__c != null && customerInvoice.CO_Header__r.Customer__r.AccountingId__c == null 
                    && alreadyRequestedAccountIdSet != null && !alreadyRequestedAccountIdSet.contains(customerInvoice.CO_Header__r.Customer__c)) {
                    List<Account> accountListToUpdate = AccSync_Customer_Batch.getAccountListToUpdateById(new Set<Id>{customerInvoice.CO_Header__r.Customer__c});
                    for(Account account: accountListToUpdate){
                        accountListToUpdateToSyncCOInvoice.add(account);
                        alreadyRequestedAccountIdSet.add(account.Id);
                    }
                } else {
                    errorLogToInsert.addAll(CustomerInvoiceService.syncAccountingServer(new List<AccountingCustomerInvoice> { new AccountingCustomerInvoice(customerInvoice, customerInvoice.CO_Invoice_Items__r, customerInvoice.CO_Invoice_Payments__r, invoiceHeaderIdToClaimNumberMap.get(customerInvoice.Id))}, customerInvoiceListToUpdate));
                }
            }
        }
    }  
 
    global void finish(Database.batchableContext bc) {
        updateCustomerInvoices(customerInvoiceListToUpdate);
        if(errorLogToInsert.size() > 0) {
            insert errorLogToInsert;
        }
        if(accountListToUpdateToSyncCOInvoice != null && accountListToUpdateToSyncCOInvoice.size() > 0) {
            AccSync_Customer_Batch.updateCustomers(accountListToUpdateToSyncCOInvoice);
            accountListToUpdateToSyncCOInvoice = null;
            runCustomerInvoicesForSync(setcustomerInvoiceIds, alreadyRequestedAccountIdSet, 10);
        }
        COInvoiceJournalEntryService.syncCustomerInvoices(setcustomerInvoiceIds);
    	
        Set<Id> dealItemIdSet = checkForLienPayoutsQBSync(setcustomerInvoiceIds);
        if(dealItemIdSet.size() > 0) {
        	LienPayoutService.syncLienPayouts(dealItemIdSet);
        }
    }
    
    public static void updateCustomerInvoices(List<CO_Invoice_Header__c> customerInvoiceListToUpdate) {
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(customerInvoiceListToUpdate != null && customerInvoiceListToUpdate.size() > 0) {
            update customerInvoiceListToUpdate;
        }
    }
    
    private static Set<Id> checkForLienPayoutsQBSync(Set<Id> setcustomerInvoiceIds) {
    	if(!AccessControl.ifObjectFieldIsAccessible('Deal_Item__c')) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Set<Id> dealItemIdSet = new Set<Id>();
        List<Deal_Item__c> dealItemList = [SELECT Id FROM Deal_Item__c WHERE Type__c =: Constants.DEAL_ITEM_TYPE_TRADE_IN AND Lien_Payout__c > 0 
        										AND Finance_Company__c != null AND Lien_Payout_Avail_For_QB_Sync__c = true 
        										AND Deal__r.Invoice_Number__c IN: setcustomerInvoiceIds];
        for(Deal_Item__c dealItemRec : dealItemList) {
        	dealItemIdSet.add(dealItemRec.Id);
        }
        return dealItemIdSet;
    }
}