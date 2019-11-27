/**
 * Author: Nikhil Kumar Srivastava
 * Since: Dec. 26, 2018
 * Name: AccDataMigrationVendorReceiving
 * Description: Class is used for migration of Vendor Receiving object records to  Accounting Software(MYOB)
**/ 
global with sharing class AccDataMigrationVendorReceiving implements Database.batchable<sObject>, Database.Stateful {
    
    global AccDataMigrationVendorReceiving() {}
	global AccDataMigrationVendorReceiving(List<Id> recordIds, boolean exportAllData) {}
	global AccDataMigrationVendorReceiving(List<Id> recordIds, boolean exportAllData, String timePeriod, DateTime fromDate, DateTime toDate) {}
	
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
	private Return_VO_Line_Item__c preReturnVOLIHeaderRec;
	private Decimal totalAmount;
	
	/**
     * Name: executeDataMigrationBatch
     * Desc: Constructor to start the batch for data export
    **/
    public static Id executeDataMigrationBatch(Integer batchSize, List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
        Id batchId = Database.executeBatch(new AccDataMigrationVendorReceiving(recordIds, timePeriod, fromDate, toDate, objNameToExport), batchSize);
        return batchId;
    }
    
    /**
     * Name: AccDataMigrationVendorReceiving
     * Desc: Constructor to start the batch for data export
    **/
    global AccDataMigrationVendorReceiving(List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
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
    	if(AccessControl.ifObjectFieldIsAccessible('Return_VO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	query = DataExportUtil.createQuery(recordIds, 'Id', this.timePeriodForFilter, Last_Synched_Date, fromDate, toDate, 'Vendor_Receiving_Group__c');
    }
    
    /**
     * Name: start
     * Desc: Batch start method - Create query and execute query locator
     * @param: 
     * @return: Database.QueryLocator
    **/
   	global Iterable<Sobject> start(Database.BatchableContext BC) {
        //return Database.getQueryLocator(query);
        String returnVOLineItemQuery = DataExportUtil.createQuery(null, null, this.timePeriodForFilter, Last_Synched_Date, fromDate, toDate, 'Return_VO_Line_Item__c');
		returnVOLineItemQuery = returnVOLineItemQuery.replace('Return_VO_Header__r.Status__c = \'Credited\'','Return_VO_Header__r.Status__c = \'Approved\'');
		returnVOLineItemQuery = returnVOLineItemQuery.replace('Credited_Date__c ','Returned_Date__c ');
		returnVOLineItemQuery = returnVOLineItemQuery.replace('T00:00:00Z ','');
		//system.assert(false,returnVOLineItemQuery);
		return getRecords(query,returnVOLineItemQuery);
    }
    
    private List<Sobject> getRecords(String query, String query1) {
		List<SObject> sObjectList = new List<SObject>();
		List<sObject> resultList = Database.query(query);
		if(resultList.size() > 0) {
			sObjectList.addAll(resultList);
		}
		resultList = Database.query(query1);
		if(resultList.size() > 0) {
			sObjectList.addAll(resultList);
		}
		//system.assert(false,sObjectList);
		return sObjectList;
		
	}
	
    /**
     * Name: execute
     * Desc: Batch execute method to process the exported data records
     * @param:  1. Database.BatchableContext BC
     *          2. List<sObject> scope
     * @return:
    **/
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
	    if(scope.size() > 0) {
	    	Map<Integer, Map<String,String>> generalJournalEntryRecords = new Map<Integer, Map<String, String>>();
	    	totalAmount = 0;
	        for(Sobject sobj : scope) {
				Id recordId = String.valueOf(sobj.get('Id'));
				if(recordId.getSObjectType().getDescribe().getName() == Constants.Namespace + 'Vendor_Receiving_Group__c') {
					Vendor_Receiving_Group__c vrRecords = (Vendor_Receiving_Group__c)sobj;
		        	if((prevVRGroup != null && prevVRGroup.Vendor_Receiving_Header__c != vrRecords.Vendor_Receiving_Header__c) || 
		        		(prevVRGroup == null && preReturnVOLIHeaderRec != null)) {
		        		generalJournalEntryRecords.put(indexVal++, createEntryForReceivngHeader(prevVRGroup, totalAmount, accountNumber));
		        		totalAmount = 0;
		        		generalJournalEntryRecords.put(indexVal++, new Map<String, String>());
		        	}   
	        		generalJournalEntryRecords.put(indexVal++, createEntryForReceivingGroup(vrRecords));
	    			totalAmount += (vrRecords.Cost__c != null ? vrRecords.Cost__c : 0) * (vrRecords.Recieved__c != null ? vrRecords.Recieved__c : 0);
	    			prevVRGroup = vrRecords;
	    			preReturnVOLIHeaderRec = null;
	    			recordCount++;
	        		
	           } else if(recordId.getSObjectType().getDescribe().getName() == Constants.Namespace + 'Return_VO_Line_Item__c') {
		    		Return_VO_Line_Item__c returnVOLIRec = (Return_VO_Line_Item__c)sobj;
		    		if ((preReturnVOLIHeaderRec != null && preReturnVOLIHeaderRec.Return_VO_Header__c != returnVOLIRec.Return_VO_Header__c) ||
		    			(preReturnVOLIHeaderRec == null && prevVRGroup != null)) {
	    				if(preReturnVOLIHeaderRec != null) {
	    					generalJournalEntryRecords.put(indexVal++, createEntryForReturnVendorHeader(preReturnVOLIHeaderRec, totalAmount, accountNumber));
	    				} else if(prevVRGroup != null) {
	    					generalJournalEntryRecords.put(indexVal++, createEntryForReceivngHeader(prevVRGroup, totalAmount, accountNumber));
	    				}
	    				totalAmount = 0;
		    			generalJournalEntryRecords.put(indexVal++, new Map<String, String>());
		    		}	
	    			generalJournalEntryRecords.put(indexVal++, createEntryForReturnVendorLineItem(returnVOLIRec));
	    			totalAmount += (returnVOLIRec.Inventory_Cost__c != null ? returnVOLIRec.Inventory_Cost__c : 0);
	    			preReturnVOLIHeaderRec = returnVOLIRec;
	    			prevVRGroup = null;
		    		recordCount++;
		    	 }
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
    	if(prevVRGroup != null) {
    		createEntryForLastReceivingHeader();
    	} else if(preReturnVOLIHeaderRec != null) {
    		createEntryForLastReturnVOHeader();
    	}
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
    private void createEntryForLastReturnVOHeader() {
    	Map<Integer, Map<String, String>> lastReturnVOHeaderData = 
    						new Map<Integer, Map<String, String>>{ indexVal => createEntryForReturnVendorHeader(preReturnVOLIHeaderRec, totalAmount, accountNumber)};
    	generalJournalEntriesData += DataExportUtil.createImportableText(lastReturnVOHeaderData, this.objName);
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
    
    private static Map<String, String> createEntryForReturnVendorLineItem(Return_VO_Line_Item__c returnVOLIRec) {
    	Map<String, String> generalJournalEntry = new Map<String, String>();
    	if(returnVOLIRec != null && returnVOLIRec.Id != null) {
	    	generalJournalEntry.put('Journal_Number__c', (returnVOLIRec.Return_VO_Header__r.Name != null) ? returnVOLIRec.Return_VO_Header__r.Name.replace('-', '') : '');
	    	Date finaldate = returnVOLIRec.Return_VO_Header__r.Returned_Date__c;
	    	generalJournalEntry.put('Date__c', DateTime.newInstance(finaldate.year(), finaldate.month(), finaldate.day()).format(DataExportService.dateFormat));
	    	generalJournalEntry.put('Memo__c', returnVOLIRec.Return_VO_Header__r.Vendor__r.Name + ';' + returnVOLIRec.Return_VO_Header__r.RMA__c + ';Return');
	    	generalJournalEntry.put('Reporting__c', 'P');
	    	generalJournalEntry.put('Inclusive__c', 'X');
	    	if(returnVOLIRec.Part__c != null) {
	    	    generalJournalEntry.put('Account_No__c', (returnVOLIRec.Part__r.Category__r.Inventory_GL__c != null) ? returnVOLIRec.Part__r.Category__r.Inventory_GL__c : '');
	    	}
	    	generalJournalEntry.put('Is_Credit__c', (returnVOLIRec.Return_Qty__c * returnVOLIRec.Item_Cost__c > 0) ? 'Y' : 'N');
	    	generalJournalEntry.put('Amount__c', ((returnVOLIRec.Inventory_Cost__c >= 0) ? '$' : '-$') + ((returnVOLIRec.Inventory_Cost__c >= 0) ? returnVOLIRec.Inventory_Cost__c.setScale(2, RoundingMode.HALF_UP) : (returnVOLIRec.Inventory_Cost__c * -1).setScale(2, RoundingMode.HALF_UP)));
	    	generalJournalEntry.put('Tax_Code__c', 'N-T');
	    	if(returnVOLIRec.Part__c != null) {
	    		Decimal perItemCost = ((returnVOLIRec.Inventory_Cost__c != null ? returnVOLIRec.Inventory_Cost__c : 0) / 
	    							((returnVOLIRec.Return_Qty__c != null && returnVOLIRec.Return_Qty__c != 0) ? returnVOLIRec.Return_Qty__c : 1));
            	generalJournalEntry.put('Allocation_Memo__c', returnVOLIRec.Part__r.Part_Number__c + ' - ' + returnVOLIRec.Part__r.Description__c + ' ' + returnVOLIRec.Return_Qty__c + '@$' + perItemCost);
	    	}
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
    
    private static Map<String, String> createEntryForReturnVendorHeader(Return_VO_Line_Item__c returnVOLIRec, Decimal totalAmount, String accountNumber) {
    	Map<String, String> generalJournalEntry = new Map<String, String>();
    	if(returnVOLIRec != null && returnVOLIRec.Id != null) {
	    	generalJournalEntry.put('Journal_Number__c', (returnVOLIRec.Return_VO_Header__r.Name != null) ? returnVOLIRec.Return_VO_Header__r.Name.replace('-', '') : '');
	    	Date finaldate = returnVOLIRec.Return_VO_Header__r.Returned_Date__c;
	    	generalJournalEntry.put('Date__c', DateTime.newInstance(finaldate.year(), finaldate.month(), finaldate.day()).format(DataExportService.dateFormat));
	    	generalJournalEntry.put('Memo__c', returnVOLIRec.Return_VO_Header__r.Vendor__r.Name + ';' + returnVOLIRec.Return_VO_Header__r.RMA__c + ';Return');
	    	generalJournalEntry.put('Reporting__c', 'P');
	    	generalJournalEntry.put('Inclusive__c', 'X');
	    	generalJournalEntry.put('Account_No__c',accountNumber);
	    	generalJournalEntry.put('Is_Credit__c', (returnVOLIRec.Return_Qty__c * returnVOLIRec.Item_Cost__c > 0) ? 'N' : 'Y');
	    	generalJournalEntry.put('Amount__c', ((totalAmount >= 0) ? '$' : '-$') + totalAmount.setScale(2, RoundingMode.HALF_UP));
	    	generalJournalEntry.put('Tax_Code__c', 'N-T');
	    	generalJournalEntry.put('Allocation_Memo__c', 'Total Return');
    	}
    	return generalJournalEntry;
    }
}