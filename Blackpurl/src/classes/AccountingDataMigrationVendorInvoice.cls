/**
 * Author: Ashish Garg
 * Since: Jan. 13, 2015
 * Name: AccountingDataMigrationVendorInvoice
 * Description: Class is used for migration of Vendor Invoice (Vendor Order Invoice) records to  Accounting Software
**/
global with sharing class AccountingDataMigrationVendorInvoice implements Database.batchable<sObject>,Database.Stateful {
	
	global AccountingDataMigrationVendorInvoice() {}
	global AccountingDataMigrationVendorInvoice(List<Id> recordIds, boolean exportAllData) {}
	global AccountingDataMigrationVendorInvoice(List<Id> recordIds, boolean exportAllData, String timePeriod, DateTime fromDate, DateTime toDate) {}
	/*
	private String objName = 'Vendor_Invoicing_Group__c';
	private String miscPurchasesExportTextData = '';
	private Integer miscPurchasesIndexVal = 1;
	private Integer recordCount = 0;
	
	private String query;  
	private DateTime Last_Synched_Date;
	private String timePeriodForFilter;
	private DateTime fromDate;
	private DateTime toDate;
	private	Accounting_Data_Migration__c dataMigration;
	private Map<String, List<Sales_Tax_Item__c>> purchaseTaxIdToTaxItemListMap;
	private static String glAccountNumber = AccountingUtil.getChartofAccount('A/P Inventory Accrual');
	private Vendor_Invoicing_Group__c preVIGroup;
	
	/**
     * Name: executeDataMigrationBatch
     * Desc: Method to initiate the coInvoiceItems export
     * @param:
     * @return: Id
    **
	public static Id executeDataMigrationBatch(Integer batchSize, List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
		Id batchId = Database.executeBatch(new AccountingDataMigrationVendorInvoice(recordIds, timePeriod, fromDate, toDate, objNameToExport), batchSize);
		return batchId;
	}*/
	
	/**
     * Name: AccountingDataMigrationVendorInvoice
     * Desc: Constructor to start the batch for data export
    **/
	global AccountingDataMigrationVendorInvoice(List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
		/*if(AccessControl.ifObjectFieldIsAccessible('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		if(AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
		if(AccessControl.ifObjectFieldIsUpdateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
		
		this.timePeriodForFilter = timePeriod;
		this.fromDate = fromDate;
		this.toDate = toDate;
		dataMigration = DataExportUtil.getAccountingDataMigrationRec(objNameToExport);
		Last_Synched_Date = dataMigration.Last_Synched_Date__c;
		dataMigration = DataExportUtil.getDateRange(timePeriod, Last_Synched_Date, fromDate, toDate, dataMigration);
    	dataMigration.Last_Synched_Date__c = Datetime.now();
    	upsert dataMigration;
    	
		if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	query = DataExportUtil.createQuery(recordIds, 'Id', this.timePeriodForFilter, Last_Synched_Date, fromDate, toDate, 'Vendor_Invoicing_Group__c');*/
	}
	/*
	private Map<String, List<Sales_Tax_Item__c>> getTaxDetail(Set<Id> purchaseTaxIdSet) {
		Map<String, List<Sales_Tax_Item__c>> purchaseTaxIdToTaxItemsMap = new Map<String, List<Sales_Tax_Item__c>>();
		List<Applicable_Taxes__c> applicableTaxList = [select Sales_Tax__c, Sales_Tax_Item__r.Name__c, Sales_Tax_Item__r.Rate__c,
															Sales_Tax_Item__r.Category__r.Income_GL__c from Applicable_Taxes__c 
															Where Sales_Tax__c IN: purchaseTaxIdSet];
		
		List<Category__c> categoryList = [Select Type__c, Income_GL__c from Category__c where Default__c = true AND Active__c = true AND Type__c = 'Tax'];
		String defaultGLforTax = '';
		if(categoryList.size() > 0) {
			defaultGLforTax = categoryList[0].Income_GL__c;
		} else {
			defaultGLforTax = AccountingUtil.getChartofAccount('Sales Tax');
		}
		
		for(Applicable_Taxes__c appTaxRec : applicableTaxList) {
			Sales_Tax_Item__c salesTaxItemRec = new Sales_Tax_Item__c(Name__c = appTaxRec.Sales_Tax_Item__r.Name__c);
			salesTaxItemRec.Rate__c = (appTaxRec.Sales_Tax_Item__r.Rate__c != null) ? appTaxRec.Sales_Tax_Item__r.Rate__c : 0;
			salesTaxItemRec.put('Migration_Id__c', (appTaxRec.Sales_Tax_Item__r.Category__r.Income_GL__c != null) ? 
													appTaxRec.Sales_Tax_Item__r.Category__r.Income_GL__c : defaultGLforTax);									 
			if(!purchaseTaxIdToTaxItemsMap.containsKey(appTaxRec.Sales_Tax__c)) {
				purchaseTaxIdToTaxItemsMap.put(appTaxRec.Sales_Tax__c, new List<Sales_Tax_Item__c>());
			}
			purchaseTaxIdToTaxItemsMap.get(appTaxRec.Sales_Tax__c).add(salesTaxItemRec);
		}				
		return new Map<String, List<Sales_Tax_Item__c>>();								
	}
	
	/**
     * Name: start
     * Desc: Batch start method - Create query and execute query locator
     * @param: 
     * @return: Database.QueryLocator
    **/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = '';
		return Database.getQueryLocator(query);
	}
	
	/**
     * Name: execute
     * Desc: Batch execute method to process the exported data records
     * @param:	1. Database.BatchableContext BC
     * 			2. List<sObject> scope
     * @return:
    **/
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		/*List<Vendor_Invoicing_Group__c> voInvoiceList = (List<Vendor_Invoicing_Group__c>) scope;
		system.assert(false, scope);
		if(voInvoiceList.size() > 0){
	    	Map<Integer, Map<String,String>> voInvoiceRecords = new Map<Integer, Map<String, String>>();
	    	
	    	// For each co voInvoice account, create a MiscellaneousPurchases entry:
	    	Set<String> partIdSet = new Set<String>();
	    	Set<Id> purchaseTaxIdSet = new Set<Id>();
	    	Set<Id> vendorInvoiceHeaderIdSet = new Set<Id>();
	    	for(Vendor_Invoicing_Group__c voInvoice : voInvoiceList){
	    		partIdSet.add(voInvoice.Vendor_Receiving_Group__r.Part__c);
	    		purchaseTaxIdSet.add(voInvoice.Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__c);
	    		vendorInvoiceHeaderIdSet.add(voInvoice.Vendor_Invoicing_Header__c);
	    	}
	    	partIdSet.remove(null);
	    	purchaseTaxIdSet.remove(null);
	    	vendorInvoiceHeaderIdSet.remove(null);
	    	//purchaseTaxIdToTaxItemListMap = getTaxDetail(purchaseTaxIdSet);
	    	
	    	if(AccessControl.ifObjectFieldIsAccessible('Part_FIFO_Bucket_Activity_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	    	List<Part_FIFO_Bucket_Activity_Line_Item__c> activityLineItemList = 
	    			[SELECT Id, Part_FIFO_Bucket__r.Part__c, Part_FIFO_Bucket__r.Cost__c, Qty_Out__c, Part_FIFO_Bucket__r.VRCost__c, 
	    					Part_FIFO_Bucket__r.Variance__c, Part_FIFO_Bucket__r.Vendor_Invoicing_Header__c 
	    					FROM Part_FIFO_Bucket_Activity_Line_Item__c WHERE Part_FIFO_Bucket__r.Variance__c != 0 
	    							AND Part_FIFO_Bucket__r.Part__c IN: partIdSet 
	    							AND Part_FIFO_Bucket__r.Vendor_Invoicing_Header__c IN: vendorInvoiceHeaderIdSet];
	    	
	    	Map<String, List<Part_FIFO_Bucket_Activity_Line_Item__c>> partIdToBucketActivityListMap = new Map<String, List<Part_FIFO_Bucket_Activity_Line_Item__c>>();																		 
	    	for(Part_FIFO_Bucket_Activity_Line_Item__c bucketLineItemRec : activityLineItemList) {
	    		if(!partIdToBucketActivityListMap.containsKey(bucketLineItemRec.Part_FIFO_Bucket__r.Part__c)){
	    			partIdToBucketActivityListMap.put(bucketLineItemRec.Part_FIFO_Bucket__r.Part__c, new List<Part_FIFO_Bucket_Activity_Line_Item__c>());
	    		}
	    		partIdToBucketActivityListMap.get(bucketLineItemRec.Part_FIFO_Bucket__r.Part__c).add(bucketLineItemRec);
	    	}
	    	
	    	if(AccessControl.ifObjectFieldIsAccessible('Other_Charges__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	    	List<Other_Charges__c> otherChargeList = [SELECT Cost__c, Fee__c, Item_Desc__c, Tax_Percent__c, Vendor_Invoicing_Header__c,
	    					 Vendor_Invoicing_Header__r.Status__c, Vendor_Invoicing_Header__r.Invoice_Date__c, CreatedDate, Vendor_Invoicing_Header__r.Vendor__c,
	    					 Vendor_Invoicing_Header__r.Vendor__r.Name, Vendor_Invoicing_Header__r.Invoice_Number__c, Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Rate__c,
	    					 Fee__r.Category__r.Income_GL__c, Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Name__c, Vendor_Invoicing_Header__r.Vendor__r.Vendor_Code__c,
	    					 Vendor_Invoicing_Header__r.Name FROM Other_Charges__c 
	    					WHERE Vendor_Invoicing_Header__c IN: vendorInvoiceHeaderIdSet];
	    	Map<Id, List<Other_Charges__c>> viIdToOtherChargeListMap = new Map<Id, List<Other_Charges__c>>();
	    	for(Other_Charges__c otherChargeRec : otherChargeList) {
	    		if(!viIdToOtherChargeListMap.containsKey(otherChargeRec.Vendor_Invoicing_Header__c)) {
	    			viIdToOtherChargeListMap.put(otherChargeRec.Vendor_Invoicing_Header__c, new List<Other_Charges__c>());
	    		}	
	    		viIdToOtherChargeListMap.get(otherChargeRec.Vendor_Invoicing_Header__c).add(otherChargeRec);
	    	}
	    	
	    	String lastInvoiceNumber = '';
	    	Integer loopIndex = 0;
	    	for(Vendor_Invoicing_Group__c voInvoice : voInvoiceList){
	    		recordCount++;
	    		loopIndex++;
	    		decimal totalInvoicePayment = voInvoice.VI_SubTotal__c;
	    		decimal receivingGroupTotalAmount = 0;
	    		if(voInvoice.Vendor_Receiving_Group__r.Recieved__c != null && voInvoice.Vendor_Receiving_Group__r.Cost__c != null) {
	    			receivingGroupTotalAmount = voInvoice.Vendor_Receiving_Group__r.Recieved__c * voInvoice.Vendor_Receiving_Group__r.Cost__c;
	    		}
	    		
	    		if(lastInvoiceNumber != '' && lastInvoiceNumber != String.valueOf(voInvoice.Vendor_Invoicing_Header__c)) {
	    			// Create Other Charges Lines
	    			if(viIdToOtherChargeListMap.containsKey(preVIGroup.Vendor_Invoicing_Header__c)) {
		    			List<Other_Charges__c> relatedOtherChargeList = viIdToOtherChargeListMap.get(preVIGroup.Vendor_Invoicing_Header__c);
		    			for(Other_Charges__c otherChargeRec : relatedOtherChargeList) {
		    				voInvoiceRecords.put(miscPurchasesIndexVal++, createOtherChargeLines(otherChargeRec));
		    			}
	    			}
		    		voInvoiceRecords.put(miscPurchasesIndexVal++, new Map<String, String>());
		    		preVIGroup = new Vendor_Invoicing_Group__c();
	    		}
	    		
	    		// Add the data for a record in export text string
	    		voInvoiceRecords.put(miscPurchasesIndexVal++, createMiscellaneousPurchasesRecordFromInvoiceItem(voInvoice, glAccountNumber));
	    		
	    		// If total of Invoice Items is different from receiving total, then add a Variance record for the difference value
	    		if((voInvoice.Vendor_Receiving_Group__r.Cost__c != voInvoice.VI_Cost__c || voInvoice.VI_Discount__c != 0) && totalInvoicePayment != receivingGroupTotalAmount ){
	    			decimal varianceAmount = receivingGroupTotalAmount - totalInvoicePayment;
	    			voInvoiceRecords.put(miscPurchasesIndexVal++, createMiscellaneousPurchasesRecordFromAdjustment(voInvoice, varianceAmount, 'Receiving Adjustment'));
	    			
	    			decimal discountAmount = totalInvoicePayment - receivingGroupTotalAmount;
	    			voInvoiceRecords.put(miscPurchasesIndexVal++, createMiscellaneousPurchasesRecordFromAdjustment(voInvoice, discountAmount, 'Inventory Adjustment'));
	    		}
	    		
	    		if(partIdToBucketActivityListMap.containsKey(voInvoice.Vendor_Receiving_Group__r.Part__c)){
	    			for(Part_FIFO_Bucket_Activity_Line_Item__c activityRec : partIdToBucketActivityListMap.get(voInvoice.Vendor_Receiving_Group__r.Part__c)){
	    				if(activityRec.Part_FIFO_Bucket__r.Vendor_Invoicing_Header__c == voInvoice.Vendor_Invoicing_Header__c) {
	    					Decimal vendorRecevingAmount = 0;
			    			Decimal vendorInvoiceAmount = 0;
			    			if(activityRec.Qty_out__c != null) {
			    				vendorRecevingAmount = (activityRec.Part_FIFO_Bucket__r.VRCost__c != null) ? activityRec.Part_FIFO_Bucket__r.VRCost__c * activityRec.Qty_out__c : 0;
			    				vendorInvoiceAmount = (activityRec.Part_FIFO_Bucket__r.Cost__c != null) ? activityRec.Part_FIFO_Bucket__r.Cost__c * activityRec.Qty_out__c : 0;
			    			}
			    			
			    			decimal varianceAmount = vendorRecevingAmount - vendorInvoiceAmount;
			    			voInvoiceRecords.put(miscPurchasesIndexVal++, createMiscellaneousPurchasesRecordForAdjustment(voInvoice, (vendorInvoiceAmount - vendorRecevingAmount), 'Inventory Adjustment'));
			    			voInvoiceRecords.put(miscPurchasesIndexVal++, createMiscellaneousPurchasesRecordForAdjustment(voInvoice, varianceAmount, 'COSGL Adjustment'));
	    				}
	    			}
	    			voInvoiceRecords.put(miscPurchasesIndexVal++, new Map<String, String>());
	    		}
	    		// Process to include new line for new invoice included
	    		if(lastInvoiceNumber != String.valueOf(voInvoice.Vendor_Invoicing_Header__c)){
	    			lastInvoiceNumber = voInvoice.Vendor_Invoicing_Header__c;
	    		}
	    		preVIGroup = voInvoice;
	    	}
	    	
	    	// Create Entry for last Vendor Invoice
	    	if(viIdToOtherChargeListMap.containsKey(preVIGroup.Vendor_Invoicing_Header__c) && preVIGroup.Id != null) {
				List<Other_Charges__c> relatedOtherChargeList = viIdToOtherChargeListMap.get(preVIGroup.Vendor_Invoicing_Header__c);
				for(Other_Charges__c otherChargeRec : relatedOtherChargeList) {
					voInvoiceRecords.put(miscPurchasesIndexVal++, createOtherChargeLines(otherChargeRec));
				}
	    	}
	    	
	    	miscPurchasesExportTextData += DataExportUtil.createImportableText(voInvoiceRecords, 'Vendor Invoice');
    	}*/
	}
	
	/**
     * Name: finish
     * Desc: Batch finish method to insert a attachment for exported data in text file
     * @param:	1. Database.BatchableContext BC
     * @return:
    **/
	global void finish(Database.BatchableContext BC) {
		/*if(AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
      	if(AccessControl.ifObjectFieldIsUpdateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
    	dataMigration.Records_Processed__c = recordCount;
    	upsert dataMigration;
    	
    	if(dataMigration.Records_Processed__c > 0) {
    		if(AccessControl.ifObjectFieldIsCreateable('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	    	insert DataExportUtil.createAttachment(miscPurchasesExportTextData, 'MISCPURCHASE_', dataMigration, recordCount);
    	}*/
	}
	
    /**
     * Name: createMiscellaneousPurchasesSFFieldToAccountingFieldsMap
     * Desc: Method to create a map of MiscellaneousPurchases Purchasesforce fields to Accounting field map so as to map in generated TXT file
     * @param: 
     * @return: Map<String, String>
    **
    @TestVisible
    private static Map<String, String> createMiscellaneousPurchasesSFFieldToAccountingFieldsMap() {
    	Map<String, String> miscPurchaseSFFieldToAccountingFieldsMap = new Map<String, String>{ 'Last_Name__c'			=>	'Co./Last Name',
																								'Date__c'				=>	'Date',
																								'Supplier_Invoice_No__c'=>	'Supplier Invoice No.',
																								'Inclusive__c'			=>	'Inclusive',
																								'Memo__c'				=>	'Memo',
																								'Description__c'		=>	'Description',
																								'Account_No__c'			=>	'Account Number',
																								'Amount__c'				=>	'Amount',
																								'Tax_Code__c'			=>	'Tax Code',
																								'Tax_Amount__c'			=>	'Tax Amount',
																								'Payment_Status__c'		=>	'Payment Status',
		    																					'Card_ID__c'			=>	'Card ID'
		    																				};
    	return miscPurchaseSFFieldToAccountingFieldsMap;
    }
    
    private Map<String, String> createOtherChargeLines(Other_Charges__c otherChargeRec) {
		DateTime invoiceDate = (otherChargeRec.Vendor_Invoicing_Header__r.Status__c == 'Invoiced') ? 
									datetime.newInstance(otherChargeRec.Vendor_Invoicing_Header__r.Invoice_Date__c.year(), 
															otherChargeRec.Vendor_Invoicing_Header__r.Invoice_Date__c.month(), 
															otherChargeRec.Vendor_Invoicing_Header__r.Invoice_Date__c.day())  :
    								otherChargeRec.CreatedDate;
    	Map<String, String> miscPurchases = new Map<String, String>();
		miscPurchases.put('Last_Name__c', (otherChargeRec.Vendor_Invoicing_Header__r.Vendor__c != null) ? otherChargeRec.Vendor_Invoicing_Header__r.Vendor__r.Name : '');
		miscPurchases.put('Date__c', invoiceDate.format(DataExportService.dateFormat));
		miscPurchases.put('Supplier_Invoice_No__c', otherChargeRec.Vendor_Invoicing_Header__r.Invoice_Number__c);
		miscPurchases.put('Inclusive__c', (otherChargeRec.Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Rate__c != null) ? 'X' : 'N');
		miscPurchases.put('Memo__c', otherChargeRec.Vendor_Invoicing_Header__r.Vendor__r.Name + ';' + otherChargeRec.Vendor_Invoicing_Header__r.Name.replace('VI-', '') + ';OtherCharge');
		
		Decimal cost = (otherChargeRec.Cost__c != null) ? otherChargeRec.Cost__c : 0;
		miscPurchases.put('Description__c', otherChargeRec.Item_Desc__c + ' ' +'@$' + cost);
		miscPurchases.put('Account_No__c', (otherChargeRec.Fee__r.Category__r.Income_GL__c != null) ? otherChargeRec.Fee__r.Category__r.Income_GL__c : '');
		miscPurchases.put('Amount__c', ((otherChargeRec.Cost__c >= 0) ? '$' : '-$') + ((otherChargeRec.Cost__c >=0) ? otherChargeRec.Cost__c : (-1 * otherChargeRec.Cost__c)));
		miscPurchases.put('Tax_Code__c', otherChargeRec.Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Name__c);
		miscPurchases.put('Payment_Status__c', 'B');
		miscPurchases.put('Card_ID__c', otherChargeRec.Vendor_Invoicing_Header__r.Vendor__r.Vendor_Code__c);
		miscPurchases.put('Tax_Amount__c', '$0');
		
    	return miscPurchases;
	}
	
    /**
     * Name: createMiscellaneousPurchasesRecordFromInvoiceItem
     * Desc: Method to create a MiscellaneousPurchases record by cocoInvoiceItem record. MiscellaneousPurchases record is a map of field name to equivalent value for field
     * @param: Vendor_Invoicing_Group__c voInvoice, Map<String, String> GLAccountMap
     * @return: Map<String, String>
    **
    private static Map<String, String> createMiscellaneousPurchasesRecordFromInvoiceItem(Vendor_Invoicing_Group__c voInvoice, String glAccNumber) {
    	DateTime invoiceDate = (voInvoice.Vendor_Invoicing_Header__r.Status__c == 'Invoiced') ? 
									datetime.newInstance(voInvoice.Vendor_Invoicing_Header__r.Invoice_Date__c.year(), 
															voInvoice.Vendor_Invoicing_Header__r.Invoice_Date__c.month(), 
															voInvoice.Vendor_Invoicing_Header__r.Invoice_Date__c.day())  :
    								voInvoice.CreatedDate;
    	decimal taxAmount = (voInvoice.Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Rate__c != null) ? 
    							(voInvoice.VI_SubTotal__c * voInvoice.Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Rate__c / 100) : 0;
    	Map<String, String> miscPurchases = new Map<String, String>();
		miscPurchases.put('Last_Name__c', (voInvoice.Vendor_Invoicing_Header__r.Vendor__c != null) ? voInvoice.Vendor_Invoicing_Header__r.Vendor__r.Name : '');
		miscPurchases.put('Date__c', invoiceDate.format(DataExportService.dateFormat));
		miscPurchases.put('Supplier_Invoice_No__c', voInvoice.Vendor_Invoicing_Header__r.Invoice_Number__c);
		miscPurchases.put('Inclusive__c', (voInvoice.Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Rate__c != null) ? 'X' : 'N');
		miscPurchases.put('Memo__c', voInvoice.Vendor_Invoicing_Header__r.Vendor__r.Name + ';' + voInvoice.Vendor_Invoicing_Header__r.Name.replace('VI-', '') + ';Purchase');
		
		Decimal cost = (voInvoice.VI_SubTotal__c != null && voInvoice.VI_Qty__c != null) ? (voInvoice.VI_SubTotal__c / voInvoice.VI_Qty__c).setScale(2, RoundingMode.HALF_UP) : voInvoice.VI_Cost__c;
		miscPurchases.put('Description__c', voInvoice.Vendor_Receiving_Group__r.Part__r.Part_Number__c + '-' + voInvoice.Vendor_Receiving_Group__r.Part__r.Description__c 
												+ ' ' + voInvoice.VI_Qty__c + '@$' + cost);
		miscPurchases.put('Account_No__c', (glAccNumber != null) ? glAccNumber : '');
		miscPurchases.put('Amount__c', ((voInvoice.VI_SubTotal__c >= 0) ? '$' : '-$') + ((voInvoice.VI_SubTotal__c >= 0) ? voInvoice.VI_SubTotal__c.setScale(2, RoundingMode.HALF_UP) : (voInvoice.VI_SubTotal__c * -1).setScale(2, RoundingMode.HALF_UP)));
		miscPurchases.put('Tax_Code__c', voInvoice.Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Name__c);
		miscPurchases.put('Payment_Status__c', 'B');
		miscPurchases.put('Card_ID__c', voInvoice.Vendor_Invoicing_Header__r.Vendor__r.Vendor_Code__c);
		miscPurchases.put('Tax_Amount__c', '$0');
		
    	return miscPurchases;
    }
    
    /**
     * Name: createMiscellaneousPurchasesRecordFromAdjustment
     * Desc: Method to create a MiscellaneousPurchases record by cocoInvoiceItem Adjustment record. MiscellaneousPurchases record is a map of field name to equivalent value for field
     * @param: Vendor_Invoicing_Group__c voInvoice, Map<String, String> GLAccountMap
     * @return: Map<String, String>
    **
    private static Map<String, String> createMiscellaneousPurchasesRecordFromAdjustment(Vendor_Invoicing_Group__c voInvoice, 
    																					decimal amount, 
    																					String description) {
    	DateTime invoiceDate = (voInvoice.Vendor_Invoicing_Header__r.Status__c == 'Invoiced') ? datetime.newInstance(voInvoice.Vendor_Invoicing_Header__r.Invoice_Date__c.year(), voInvoice.Vendor_Invoicing_Header__r.Invoice_Date__c.month(), voInvoice.Vendor_Invoicing_Header__r.Invoice_Date__c.day()) : voInvoice.CreatedDate;
    	Map<String, String> miscPurchases = new Map<String, String>{'Last_Name__c'			=>	(voInvoice.Vendor_Invoicing_Header__r.Vendor__c != null) ? voInvoice.Vendor_Invoicing_Header__r.Vendor__r.Name : '',
    																'Date__c'				=>	invoiceDate.format(DataExportService.dateFormat),
    																'Supplier_Invoice_No__c'=>	voInvoice.Vendor_Invoicing_Header__r.Invoice_Number__c,
    																'Inclusive__c'			=>	'X',
    																'Memo__c'				=>	voInvoice.Vendor_Invoicing_Header__r.Vendor__r.Name + ';' + voInvoice.Vendor_Invoicing_Header__r.Name.replace('VI-', '') + ';Purchase',
    																'Description__c'		=>	voInvoice.Vendor_Receiving_Group__r.Part__r.Part_Number__c + '-' + voInvoice.Vendor_Receiving_Group__r.Part__r.Description__c + ' ' + description,
    																'Account_No__c'			=>	(glAccountNumber != null) ? glAccountNumber : '',
	    															'Amount__c'				=>	((amount >= 0) ? '$' : '-$') + ((amount >= 0) ? amount.setScale(2, RoundingMode.HALF_UP) : (amount * -1).setScale(2, RoundingMode.HALF_UP)),
																	'Tax_Code__c'			=>	'N-T',
																	'Tax_Amount__c'			=>	'$0',
																	'Payment_Status__c'		=>	'B',
																	'Card_ID__c'			=>	voInvoice.Vendor_Invoicing_Header__r.Vendor__r.Vendor_Code__c
																};
    	
    	/*if(description == 'Receiving Adjustment'){
    		miscPurchases.put('Account_No__c', (GLAccountMap.containsKey('Received Inventory Accrual')) ? GLAccountMap.get('Received Inventory Accrual') : '');
    	} else *if(description == 'Inventory Adjustment'){
    		miscPurchases.put('Account_No__c', ((voInvoice.Vendor_Receiving_Group__r.Part__r.Category__r != null && voInvoice.Vendor_Receiving_Group__r.Part__r.Category__r.Inventory_GL__c != null) ? voInvoice.Vendor_Receiving_Group__r.Part__r.Category__r.Inventory_GL__c : ''));
    	}
    	
    	return miscPurchases;
    }
    
    
    /**
     * Name: createMiscellaneousPurchasesRecordFromAdjustment
     * Desc: Method to create a MiscellaneousPurchases record by cocoInvoiceItem Adjustment record. MiscellaneousPurchases record is a map of field name to equivalent value for field
     * @param: Vendor_Invoicing_Group__c voInvoice, Map<String, String> GLAccountMap
     * @return: Map<String, String>
    **
    private static Map<String, String> createMiscellaneousPurchasesRecordForAdjustment(Vendor_Invoicing_Group__c voInvoice, 
    																					decimal amount, 
    																					String description) {
    	DateTime invoiceDate = (voInvoice.Vendor_Invoicing_Header__r.Status__c == 'Invoiced') ? datetime.newInstance(voInvoice.Vendor_Invoicing_Header__r.Invoice_Date__c.year(), voInvoice.Vendor_Invoicing_Header__r.Invoice_Date__c.month(), voInvoice.Vendor_Invoicing_Header__r.Invoice_Date__c.day()) : voInvoice.CreatedDate;
    	Map<String, String> miscPurchases = new Map<String, String>{'Last_Name__c'			=>	(voInvoice.Vendor_Invoicing_Header__r.Vendor__c != null) ? voInvoice.Vendor_Invoicing_Header__r.Vendor__r.Name : '',
    																'Date__c'				=>	invoiceDate.format(DataExportService.dateFormat),
    																'Supplier_Invoice_No__c'=>	voInvoice.Vendor_Invoicing_Header__r.Invoice_Number__c,
    																'Inclusive__c'			=>	'X',
    																'Memo__c'				=>	voInvoice.Vendor_Invoicing_Header__r.Vendor__r.Name + ';' + voInvoice.Vendor_Invoicing_Header__r.Name.replace('VI-', '') + ';Purchase',
    																'Description__c'		=>	voInvoice.Vendor_Receiving_Group__r.Part__r.Part_Number__c + '-' + voInvoice.Vendor_Receiving_Group__r.Part__r.Description__c + ' ' + 'pre-sold Cost Adjustment',
    																'Account_No__c'			=>	(glAccountNumber != null) ? glAccountNumber : '',
	    															'Amount__c'				=>	((amount >= 0) ? '$' : '-$') + ((amount >= 0) ? amount.setScale(2, RoundingMode.HALF_UP) : (amount * -1).setScale(2, RoundingMode.HALF_UP)),
																	'Tax_Code__c'			=>	'N-T',
																	'Tax_Amount__c'			=>	'$0',
																	'Payment_Status__c'		=>	'B',
																	'Card_ID__c'			=>	voInvoice.Vendor_Invoicing_Header__r.Vendor__r.Vendor_Code__c
																};
    	
    	if(description == 'COSGL Adjustment'){
    		miscPurchases.put('Account_No__c', ((voInvoice.Vendor_Receiving_Group__r.Part__r.Category__r != null && voInvoice.Vendor_Receiving_Group__r.Part__r.Category__r.COGS_GL__c != null) ? voInvoice.Vendor_Receiving_Group__r.Part__r.Category__r.COGS_GL__c : ''));
    	} else if(description == 'Inventory Adjustment'){
    		miscPurchases.put('Account_No__c', ((voInvoice.Vendor_Receiving_Group__r.Part__r.Category__r != null && voInvoice.Vendor_Receiving_Group__r.Part__r.Category__r.Inventory_GL__c != null) ? voInvoice.Vendor_Receiving_Group__r.Part__r.Category__r.Inventory_GL__c : ''));
    	}
    	return miscPurchases;
    }*/
}