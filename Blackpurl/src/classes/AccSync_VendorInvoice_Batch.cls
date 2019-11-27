/**
 * Author: Pooja Khandelwal
 * Since: Jan. 6, 2017
 * Name: AccSync_VendorInvoice_Batch
 * Description: Batch for AccSync Vendor Invoice (QB Integration)
**/
global with sharing class AccSync_VendorInvoice_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    public String strQuery;
    public Set<Id> setVIHeaderIds;
    public static boolean preventOnAccountingSync = false;
    global List<Vendor_Invoicing_Header__c> VIHeaderListToUpdate; 
    public List<Account> accountListToUpdateToSyncVIHeaders; 
    public Set<Id> alreadyRequestedAccountIdSet;
    global List<Log__c> errorLogToInsert;
    
    public static void runVIHeadersForSync( Set<Id> setVIHeaderIdVal , Integer batchSize) {
        runVIHeadersForSync(setVIHeaderIdVal, new Set<Id>(), batchSize);
    }
    
    public static void runVIHeadersForSync(Set<Id> setVIHeaderIdVal, Set<Id> alreadyRequestedAccountIdSet, Integer batchSize){
        AccSync_VendorInvoice_Batch clsAccSyncBatch = new AccSync_VendorInvoice_Batch();
        clsAccSyncBatch.setVIHeaderIds = setVIHeaderIdVal;
        clsAccSyncBatch.alreadyRequestedAccountIdSet = alreadyRequestedAccountIdSet;
        clsAccSyncBatch.strQuery = getBaseQuery();
        clsAccSyncBatch.strQuery += ' AND Id IN :setVIHeaderIds';
        Id batchstart = Database.executeBatch(clsAccSyncBatch, batchSize);
    }
        
    public static String getBaseQuery(){
        String baseQuery = 'SELECT '; 
        //fields of VI Header  
        for(String fieldName : AccountingVendorInvoice.objectToFieldMap.get('VIHeader')){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        
        baseQuery = baseQuery.substring(0, baseQuery.length()-2);
		baseQuery += ' FROM Vendor_Invoicing_Header__c ';
        baseQuery += 'WHERE availForQBSync__c = true AND Status__c = \'Invoiced\'';
        return baseQuery;
    }
        
        
    global Database.QueryLocator start(Database.BatchableContext bc){
        VIHeaderListToUpdate = new List<Vendor_Invoicing_Header__c>();
        errorLogToInsert = new List<Log__c>();
        if(String.isBlank(strQuery)){
            strQuery = getBaseQuery();
            if(setVIHeaderIds != null && setVIHeaderIds.size() > 0) {
                strQuery += ' AND Id IN :setVIHeaderIds';
            }
        }
        return Database.getQueryLocator(strQuery); 
    }

    global void execute(Database.batchableContext bc, List<Vendor_Invoicing_Header__c> listVIHeaders) {
        Set<Id> vendorInvoiceIdSet = new Set<Id>();
        for(Vendor_Invoicing_Header__c vendorInvoiceRec : listVIHeaders) {
        	vendorInvoiceIdSet.add(vendorInvoiceRec.Id);
        }
        
    	List<Vendor_Invoicing_Group__c> viGroupsList = getVIGroupsListByVIHeaderId(vendorInvoiceIdSet);
    	List<Other_Charges__c> otherChargesList = getOtherChargesListByVIHeaderId(vendorInvoiceIdSet);
    	List<Part_FIFO_Bucket__c> PartFIFOBucketList = getPartFifoBucketListByVIHeaderId(vendorInvoiceIdSet);
    	
    	Map<Id, List<Vendor_Invoicing_Group__c>> viHeaderIdToVIGroupsListMap = new Map<Id, List<Vendor_Invoicing_Group__c>>();
    	Map<Id, List<Other_Charges__c>> viHeaderIdToOtherChargesListMap = new Map<Id, List<Other_Charges__c>>();
    	Map<Id, List<Part_FIFO_Bucket__c>> viHeaderIdPartFifoBucketListMap = new Map<Id, List<Part_FIFO_Bucket__c>>();
    	
    	for(Vendor_Invoicing_Group__c viGroupRec : viGroupsList) {
    		if(!viHeaderIdToVIGroupsListMap.containsKey(viGroupRec.Vendor_Invoicing_Header__c)) {
    			viHeaderIdToVIGroupsListMap.put(viGroupRec.Vendor_Invoicing_Header__c, new List<Vendor_Invoicing_Group__c>());
    		}
    		viHeaderIdToVIGroupsListMap.get(viGroupRec.Vendor_Invoicing_Header__c).add(viGroupRec);
    	}
    	
    	for(Other_Charges__c otherChargeRec : otherChargesList) {
    		if(!viHeaderIdToOtherChargesListMap.containsKey(otherChargeRec.Vendor_Invoicing_Header__c)) {
    			viHeaderIdToOtherChargesListMap.put(otherChargeRec.Vendor_Invoicing_Header__c, new List<Other_Charges__c>());
    		}
    		viHeaderIdToOtherChargesListMap.get(otherChargeRec.Vendor_Invoicing_Header__c).add(otherChargeRec);
    	}
    	
    	for(Part_FIFO_Bucket__c partFifoBucketRec : PartFIFOBucketList) {
    		if(!viHeaderIdPartFifoBucketListMap.containsKey(partFifoBucketRec.Vendor_Invoicing_Header__c)) {
    			viHeaderIdPartFifoBucketListMap.put(partFifoBucketRec.Vendor_Invoicing_Header__c, new List<Part_FIFO_Bucket__c>());
    		}
    		viHeaderIdPartFifoBucketListMap.get(partFifoBucketRec.Vendor_Invoicing_Header__c).add(partFifoBucketRec);
    	}
        
        accountListToUpdateToSyncVIHeaders = new List<Account>();	
        for(Vendor_Invoicing_Header__c VIHeader : listVIHeaders){
            if(!Test.isRunningTest() && VIHeader.Vendor__c != null  && VIHeader.Vendor__r.Vendor_AccountingId__c == null && !alreadyRequestedAccountIdSet.contains(VIHeader.Vendor__c)) {
    			List<Account> accountListToUpdate = AccSync_Vendor_Batch.getAccountListToUpdateById(new Set<Id>{VIHeader.Vendor__c});
		    	for(Account account: accountListToUpdate) {
		    		accountListToUpdateToSyncVIHeaders.add(account);
		    		alreadyRequestedAccountIdSet.add(account.Id);
		    	}	
    		} else {
    			errorLogToInsert.addAll(VendorInvoiceService.syncAccountingServer(new AccountingVendorInvoice(VIHeader, (viHeaderIdToVIGroupsListMap.containsKey(VIHeader.Id) ? viHeaderIdToVIGroupsListMap.get(VIHeader.Id) : new List<Vendor_Invoicing_Group__c>()),
    										 (viHeaderIdPartFifoBucketListMap.containsKey(VIHeader.Id) ? viHeaderIdPartFifoBucketListMap.get(VIHeader.Id) : new List<Part_FIFO_Bucket__c>()),
    										(viHeaderIdToOtherChargesListMap.containsKey(VIHeader.Id) ? viHeaderIdToOtherChargesListMap.get(VIHeader.Id) : new List<Other_Charges__c>())), 
    										 VIHeaderListToUpdate));
    		}
        }
        
    }  
 
    global void finish(Database.batchableContext bc){
        updateVIHeaders(VIHeaderListToUpdate);
        
        if(accountListToUpdateToSyncVIHeaders != null && accountListToUpdateToSyncVIHeaders.size() > 0) {
    		AccSync_Vendor_Batch.updateVendors(accountListToUpdateToSyncVIHeaders);
    		accountListToUpdateToSyncVIHeaders = null;
    		runVIHeadersForSync(setVIHeaderIds, alreadyRequestedAccountIdSet, 10);
    	}
        if(errorLogToInsert.size() > 0) {
    	    insert errorLogToInsert;
    	}
    }
    
    public static void updateVIHeaders(List<Vendor_Invoicing_Header__c> VIHeaderListToUpdate){
    	if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Invoicing_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(VIHeaderListToUpdate != null && VIHeaderListToUpdate.size() > 0){ 
            preventOnAccountingSync = true;
            update VIHeaderListToUpdate;
        }
    }
    
    private static List<Vendor_Invoicing_Group__c> getVIGroupsListByVIHeaderId(Set<Id> vendorInvoiceIdSet){
        String viGroupQueryStr = 'SELECT ';
        for(String fieldName : AccountingVendorInvoice.objectToFieldMap.get('VIGroup')){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            viGroupQueryStr += fieldName + ', ';
        }
        viGroupQueryStr = viGroupQueryStr.substring(0, viGroupQueryStr.length()-2);
        viGroupQueryStr += ' FROM Vendor_Invoicing_Group__c WHERE Vendor_Invoicing_Header__c IN: vendorInvoiceIdSet';
    	if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	return Database.query(viGroupQueryStr);
    }
    
    private static List<Other_Charges__c> getOtherChargesListByVIHeaderId(Set<Id> vendorInvoiceIdSet){
        String otherChargeQueryStr = 'SELECT ';
        for(String fieldName : AccountingVendorInvoice.objectToFieldMap.get('OtherCharges')){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            otherChargeQueryStr += fieldName + ', ';
        }
        otherChargeQueryStr = otherChargeQueryStr.substring(0, otherChargeQueryStr.length()-2);
        otherChargeQueryStr += ' FROM Other_Charges__c WHERE Vendor_Invoicing_Header__c IN: vendorInvoiceIdSet';
    	
    	if(AccessControl.ifObjectFieldIsAccessible('Other_Charges__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	return Database.query(otherChargeQueryStr);
    }
    
    private static List<Part_FIFO_Bucket__c> getPartFifoBucketListByVIHeaderId(Set<Id> vendorInvoiceIdSet){
        String partFifoBucketQueryStr = 'SELECT ';
        for(String fieldName : AccountingFIFOBucket.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            partFifoBucketQueryStr += fieldName + ', ';
        }
        partFifoBucketQueryStr = partFifoBucketQueryStr.substring(0, partFifoBucketQueryStr.length()-2);
        partFifoBucketQueryStr += ' FROM Part_FIFO_Bucket__c WHERE Vendor_Invoicing_Header__c IN: vendorInvoiceIdSet';
    	
    	if(AccessControl.ifObjectFieldIsAccessible('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	return Database.query(partFifoBucketQueryStr);
    }
}