global with sharing class AccSync_VORJournalEntry_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    
	public String strQuery;
    public Set<Id> setVORIds;
    public static boolean preventOnAccountingSync = false;
    global List<Vendor_Receiving_Header__c> VORListToUpdate;  
	public List<Account> accountListToUpdateToSyncVORs; 
	public Set<Id> alreadyRequestedAccountIdSet;
    global List<Log__c> errorLogToInsert;
	
    public static void runVORsForSync(Set<Id> setVORIdVal, Integer batchSize) {
        runVORsForSync(setVORIdVal, new Set<Id>(), batchSize);
	}
    
    public static void runVORsForSync(Set<Id> setVORIdVal, Set<Id> alreadyRequestedAccountIdSet, Integer batchSize) {
        AccSync_VORJournalEntry_Batch clsAccSyncBatch = new AccSync_VORJournalEntry_Batch();
        clsAccSyncBatch.setVORIds = setVORIdVal;
        clsAccSyncBatch.alreadyRequestedAccountIdSet = alreadyRequestedAccountIdSet;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :setVORIds';
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);
	}
    	
	public static String getBaseQuery(){
        String baseQuery = 'SELECT '; 
        //fields of VOR header 
        for(String fieldName : AccountingVendorReceiving.objectToFieldMap.get('VORHeader')) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
	        
        // Child Query: fields of CO Invoice Item 
        baseQuery += '( SELECT ';
        for(String fieldName : AccountingVendorReceiving.objectToFieldMap.get('VORGroup')) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
        baseQuery += ' FROM Vendor_Receiving_Groups__r ) '; 
	        
        baseQuery += 'FROM Vendor_Receiving_Header__c ';
        baseQuery += 'WHERE availForQBJournalEntrySync__c = true';
        return baseQuery;
    }
        
    global Database.QueryLocator start(Database.BatchableContext bc) {
    	VORListToUpdate = new List<Vendor_Receiving_Header__c>();
        errorLogToInsert = new List<Log__c>();
    	if(String.isBlank(strQuery)){
	    	strQuery = getBaseQuery();
	    	if(setVORIds != null && setVORIds.size() > 0) {
                strQuery += ' AND Id IN :setVORIds';
            }
    	}
        return Database.getQueryLocator(strQuery); 
    }

    global void execute(Database.batchableContext bc, List<Vendor_Receiving_Header__c> listVORs) {
        List<AccountingVendorReceiving> accountingVORList = new List<AccountingVendorReceiving>();
        
        accountListToUpdateToSyncVORs = new List<Account>();	
        for(Vendor_Receiving_Header__c VOR : listVORs){
            if(!Test.isRunningTest() && VOR.Vendor__c != null && VOR.Vendor__r.Vendor_AccountingId__c == null && !alreadyRequestedAccountIdSet.contains(VOR.Vendor__c)) {
    			List<Account> accountListToUpdate = AccSync_Vendor_Batch.getAccountListToUpdateById(new Set<Id>{VOR.Vendor__c});
		    	for(Account account: accountListToUpdate){
		    		accountListToUpdateToSyncVORs.add(account);
		    		alreadyRequestedAccountIdSet.add(account.Id);
		    	}	
    		} else {
    			errorLogToInsert.addAll(VORJournalEntryService.syncAccountingServer(new AccountingVendorReceiving(VOR, VOR.Vendor_Receiving_Groups__r), VORListToUpdate));
    		}
        }
    }  
 
    global void finish(Database.batchableContext bc) {
    	updateVORs(VORListToUpdate);
    	
    	if(accountListToUpdateToSyncVORs != null && accountListToUpdateToSyncVORs.size() > 0) {
    		AccSync_Vendor_Batch.updateVendors(accountListToUpdateToSyncVORs);
    		accountListToUpdateToSyncVORs = null;
    		runVORsForSync(setVORIds, alreadyRequestedAccountIdSet, 10);
    	}
        if(errorLogToInsert.size() > 0) {
    	    insert errorLogToInsert;
    	}
    }
    
    public static void updateVORs(List<Vendor_Receiving_Header__c> VORListToUpdate) {
    	if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Receiving_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	if(VORListToUpdate != null && VORListToUpdate.size() > 0){ 
    		preventOnAccountingSync = true;
    		update VORListToUpdate;
    	}
    }
}