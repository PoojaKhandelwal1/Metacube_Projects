/**
 * Author: Ashish Garg
 * Since: Jan. 13, 2015
 * Name: AccountingDataMigrationvendorReceiving
 * Description: Class is used for migration of Vendor Receiving object records to  Accounting Software
**/ 
global with sharing class AccountingDataMigrationvendorReceiving implements Database.batchable<sObject>, Database.Stateful {
    
    global AccountingDataMigrationvendorReceiving() {}
	global AccountingDataMigrationvendorReceiving(List<Id> recordIds, boolean exportAllData) {}
	global AccountingDataMigrationvendorReceiving(List<Id> recordIds, boolean exportAllData, String timePeriod, DateTime fromDate, DateTime toDate) {}
	
	private String objName = 'Vendor_Receiving_Group__c';
	private String generalJournalEntriesData = '';
	private Integer indexVal = 1;
	private Integer recordCount = 0;
	
	private String query;  
	private DateTime Last_Synched_Date; 
	private String timePeriodForFilter;
	private DateTime fromDate;
	private DateTime toDate;
	private	Accounting_Data_Migration__c dataMigration;
	private String accountNumber = AccountingUtil.getChartofAccount('A/P Inventory Accrual');
	private Vendor_Receiving_Group__c prevVRGroup;
	private Decimal totalAmount;
	
	/**
     * Name: executeDataMigrationBatch
     * Desc: Constructor to start the batch for data export
    **/
    public static Id executeDataMigrationBatch(Integer batchSize, List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
        Id batchId = Database.executeBatch(new AccountingDataMigrationvendorReceiving(recordIds, timePeriod, fromDate, toDate, objNameToExport), batchSize);
        return batchId;
    }
    
    /**
     * Name: AccountingDataMigrationvendorReceiving
     * Desc: Constructor to start the batch for data export
    **/
    global AccountingDataMigrationVendorReceiving(List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
        if(AccessControl.ifObjectFieldIsAccessible('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        this.timePeriodForFilter = timePeriod;
		this.fromDate = fromDate;
		this.toDate = toDate;
        dataMigration = DataExportUtil.getAccountingDataMigrationRec(objNameToExport);
		Last_Synched_Date = dataMigration.Last_Synched_Date__c;
    	dataMigration = DataExportUtil.getDateRange(timePeriod, Last_Synched_Date, fromDate, toDate, new List<Accounting_Data_Migration__c>{dataMigration});
    	
		if(AccessControl.ifObjectFieldIsAccessible('Vendor_Receiving_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	query = DataExportUtil.createQuery(recordIds, 'Id', this.timePeriodForFilter, Last_Synched_Date, fromDate, toDate, 'Vendor_Receiving_Group__c');
    } 
    
    /**
     * Name: start
     * Desc: Batch start method - Create query and execute query locator
     * @param: 
     * @return: Database.QueryLocator
    **/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    /**
     * Name: execute
     * Desc: Batch execute method to process the exported data records
     * @param:  1. Database.BatchableContext BC
     *          2. List<sObject> scope
     * @return:
    **/
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Vendor_Receiving_Group__c> vrRecords = (List<Vendor_Receiving_Group__c>) scope;
        if(vrRecords.size() > 0) {
        	Map<Integer, Map<String,String>> generalJournalEntryRecords = new Map<Integer, Map<String, String>>();
        	totalAmount = 0;
        	for(Vendor_Receiving_Group__c vrGroupRec : vrRecords) {
        		if(prevVRGroup != null && prevVRGroup.Vendor_Receiving_Header__c != vrGroupRec.Vendor_Receiving_Header__c) {
        			generalJournalEntryRecords.put(indexVal++, createEntryForReceivngHeader(prevVRGroup, totalAmount, accountNumber));
        			totalAmount = 0;
        			generalJournalEntryRecords.put(indexVal++, new Map<String, String>());
        		}
        		generalJournalEntryRecords.put(indexVal++, createEntryForReceivingGroup(vrGroupRec));
    			totalAmount += (vrGroupRec.Cost__c != null ? vrGroupRec.Cost__c : 0) * (vrGroupRec.Recieved__c != null ? vrGroupRec.Recieved__c : 0);
    			prevVRGroup = vrGroupRec;
    			recordCount++;
        	}
        	generalJournalEntriesData += DataExportUtil.createImportableText(generalJournalEntryRecords, this.objName);
        }
    }
    
    /**
     * Name: finish
     * Desc: Batch finish method to insert a attachment for exported data in text file
     * @param:  1. Database.BatchableContext BC
     * @return:
    **/
    global void finish(Database.BatchableContext BC) {
        createEntryForLastReceivingHeader();
        if(AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
      	if(AccessControl.ifObjectFieldIsUpdateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        dataMigration.Records_Processed__c = recordCount;
        upsert dataMigration;
        
        if(dataMigration.Records_Processed__c > 0) {
        	if(AccessControl.ifObjectFieldIsCreateable('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	    	insert DataExportUtil.createAttachment(generalJournalEntriesData, 'GENERAL_JOURNAL_', dataMigration, recordCount);
    	}
    	
    	// Call batch class of FIFo Bucket.
        AccDataMigrationFIFOBkt.executeDataMigrationBatch(200, null, timePeriodForFilter, fromDate, toDate, DataExportUtil.VENDOR_RECEIVING_ACCOUNTING_OBJECT_NAME); // Commented by richa 3 april Added in DataExportService class 
    }
    
    private void createEntryForLastReceivingHeader() {
    	Map<Integer, Map<String, String>> lastReceivingHeaderData = 
    						new Map<Integer, Map<String, String>>{ indexVal => createEntryForReceivngHeader(prevVRGroup, totalAmount, accountNumber)};
    	generalJournalEntriesData += DataExportUtil.createImportableText(lastReceivingHeaderData, this.objName);
    }
    
    /**
     * Name: createEntryForReceivingGroup 
     * Desc: Method to create a General Journal Entries record by Vendor_Receiving_Group__c record.
     * @param: Vendor_Receiving_Group__c vrGroup
     * @return: Map<String, String>
    **/
    private static Map<String, String> createEntryForReceivingGroup(Vendor_Receiving_Group__c vrGroup) {
    	Map<String, String> generalJournalEntry = new Map<String, String>();
    	generalJournalEntry.put('Journal_Number__c', (vrGroup.Vendor_Receiving_Header__c != null) ? 
    													vrGroup.Vendor_Receiving_Header__r.Name.replace('-', '') : '');
    	Date finaldate = vrGroup.Vendor_Receiving_Header__r.Finalized_Date__c;
    	generalJournalEntry.put('Date__c', DateTime.newInstance(finaldate.year(), finaldate.month(), finaldate.day()).format(DataExportService.dateFormat));
    	generalJournalEntry.put('Memo__c', vrGroup.Vendor_Receiving_Header__r.Vendor__r.Name + ';' + vrGroup.Vendor_Receiving_Header__r.Packing_Slip_Number__c + ';Receiving');
    	generalJournalEntry.put('Reporting__c', 'P');
    	generalJournalEntry.put('Inclusive__c', 'X');
    	if(vrGroup.Part__c != null) {
    	    generalJournalEntry.put('Account_No__c', (vrGroup.Part__r.Category__r.Inventory_GL__c != null) ? vrGroup.Part__r.Category__r.Inventory_GL__c : '');
    	} else if(vrGroup.Sublet__c != null) {
    	    generalJournalEntry.put('Account_No__c', (vrGroup.Sublet__r.Category__r.Inventory_GL__c != null) ? vrGroup.Sublet__r.Category__r.Inventory_GL__c : '');
    	}
    	generalJournalEntry.put('Is_Credit__c', (vrGroup.Recieved__c > 0) ? 'N' : 'Y');
    	generalJournalEntry.put('Amount__c', ((vrGroup.Total__c >= 0) ? '$' : '-$') + ((vrGroup.Total__c >= 0) ? vrGroup.Total__c.setScale(2, RoundingMode.HALF_UP) : (vrGroup.Total__c * -1).setScale(2, RoundingMode.HALF_UP)));
    	generalJournalEntry.put('Tax_Code__c', 'N-T');
    	if(vrGroup.Part__c != null) {
            generalJournalEntry.put('Allocation_Memo__c', vrGroup.Part__r.Part_Number__c + ' - ' + vrGroup.Part__r.Description__c + ' ' + vrGroup.Recieved__c + '@$' + vrGroup.Cost__c);
        } else if(vrGroup.Sublet__c != null) {
            generalJournalEntry.put('Allocation_Memo__c', vrGroup.Service_Order_Line_Item__r.Item_Code__c + (vrGroup.Service_Order_Line_Item__r.Item_Description__c != null ? '-' + vrGroup.Service_Order_Line_Item__r.Item_Description__c : '') + ' ' + vrGroup.Recieved__c + '@$' + vrGroup.Cost__c);
        }
    	return generalJournalEntry;
    }
    
    /**
     * Name: createEntryForReceivngHeader 
     * Desc: Method to create a General Journal Entries record by Vendor_Receiving_Header__c record. 
     * @param: Vendor_Receiving_Group__c vrGroup
     *			Decimal totalAmount
     *			String accountNumber - General Account Number
     * @return: Map<String, String>
    **/
    private static Map<String, String> createEntryForReceivngHeader(Vendor_Receiving_Group__c vrGroup, Decimal totalAmount, String accountNumber) {
    	Map<String, String> generalJournalEntry = new Map<String, String>();
    	if(vrGroup != null && vrGroup.Id != null) {
	    	generalJournalEntry.put('Journal_Number__c', (vrGroup.Vendor_Receiving_Header__c != null) ? vrGroup.Vendor_Receiving_Header__r.Name.replace('-', '') : '');
	    	Date finaldate = vrGroup.Vendor_Receiving_Header__r.Finalized_Date__c;
	    	generalJournalEntry.put('Date__c', DateTime.newInstance(finaldate.year(), finaldate.month(), finaldate.day()).format(DataExportService.dateFormat));
	    	generalJournalEntry.put('Memo__c', vrGroup.Vendor_Receiving_Header__r.Vendor__r.Name + ';' + vrGroup.Vendor_Receiving_Header__r.Packing_Slip_Number__c + ';Receiving');
	    	generalJournalEntry.put('Reporting__c', 'P');
	    	generalJournalEntry.put('Inclusive__c', 'X');
	    	generalJournalEntry.put('Account_No__c', accountNumber);
	    	generalJournalEntry.put('Is_Credit__c', (vrGroup.Recieved__c > 0 && vrGroup.Cost__c > 0) ? 'Y' : 'N');
	    	generalJournalEntry.put('Amount__c', ((totalAmount >= 0) ? '$' : '-$') + totalAmount.setScale(2, RoundingMode.HALF_UP));
	    	generalJournalEntry.put('Tax_Code__c', 'N-T');
	    	generalJournalEntry.put('Allocation_Memo__c', 'Total Receiving');
    	}
    	return generalJournalEntry;
    }
}