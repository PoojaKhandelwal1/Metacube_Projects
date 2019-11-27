@isTest
public with sharing class AccountingDataMigrationvenReceivingTest{

	 @testSetup
	 private static void setupTestData(){
		  TestUtil.createNameSpaceInGeneralConfig();
		  List <General_Configurations__c> config = [SELECT Id FROM General_Configurations__c LIMIT: SOQLUtil.getAvailableQueryRowsLimit()];
		  system.assertNotEquals(0, config.size());
	 }
	
	 @isTest
	 static void executeDataMigrationBatchTest(){
	    PaginationSorting pageSort = new PaginationSorting();
	  	pageSort.CurrentPage = 1;
	  	pageSort.PageSize = 10;
	  	pageSort.Sorting = new List <PaginationSorting.SortAttrs>{
	  		new PaginationSorting.SortAttrs('Item', 'ASC')
	  	};
	 
	  	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
	  	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
	  	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
	  	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
	  	Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
	  	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
	 
	  	Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
	  	Part.Packaged_Part__c = true;
	  	Part.Package_Qty__c = 22;
	  	Part.Auto_reorder_Min__c = 0;
	  	part.Auto_reorder_Max__c = 100;
	  	part.Order_Lots__c = 1;
	  	insert part;
	
	  	CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
	 	Account customer1 = TestUtil.createCustomer(true, 'customerName1', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
	  	CO_Header__c coHeader1 = TestUtil.createCOHeader(true, customer1.Id);
	
	  	CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(true, coHeader1.Id, part.Id, 130);
	
	  	PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
	  	Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
	  	voHeader.Purchase_Order_Type__c = POType.Id;
	  	insert voHeader;
		  
	  	Vendor_Receiving_Header__c vor = TestUtil.createVendorOrderReceiveHeader(false, vendor.Id, 'Stocked');
	  	vor.Finalized_Date__c = Date.today().addDays(3);
	  	insert vor;
	
	  	List <string> voHeaderFields = VendorInvoicingCtrl.voHeaderFieldsList(); //for code coverage 
	  	String groupLineItems = VendorOrderCtrl.addVOLineItemFromSearchToAdd(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(voHeader.Id), 120, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(null), true);
	  	String finalizedLineItems = VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
	  	VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vor.Id), true);
	  
	  	Test.startTest();
	  	String addItems = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vor.Id), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
	
	  	Vendor_Receiving_Header__c vor1 = TestUtil.createVendorOrderReceiveHeader(false, vendor.Id, 'Stocked');
	 	vor1.Finalized_Date__c = Date.today().addDays(3);
	  	insert vor1;
	 
	  	Vendor_Receiving_Group__c vrg = new Vendor_Receiving_Group__c();
	  	vrg.Vendor_Receiving_Header__c = vor1.Id;
	  	vrg.Part__c = part.Id;
	  	vrg.Cost__c = 10;
	  	vrg.Recieved__c = 128;
	  	insert vrg;
	  
	  	Vendor_Order_Line_Item__c voLineItem = TestUtil.createVendorOrderLineItem(false, voHeader.Id, part.Id, 150);
	  	voLineItem.Vendor_Receiving_Group__c = vrg.Id;
	  	insert voLineItem;
	
	  	List <Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'General Journal Entries', 'General Journal Entries');
	  	Id batchId = AccountingDataMigrationvendorReceiving.executeDataMigrationBatch(200, null, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2), DataExportUtil.VENDOR_RECEIVING_ACCOUNTING_OBJECT_NAME);
	  	Test.stopTest();
	  
	  	List <Accounting_Data_Migration__c> accountMigrateList = [SELECT Id FROM Accounting_Data_Migration__c WHERE Object_Name__c = 'General Journal Entries'];
	  	List <Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId IN: accountMigrateList];
	  	system.assertEquals(1, attachmentList.size());
	 }
	
	 	@isTest
	 	static void ConstructorCallTest(){
	  		AccountingDataMigrationvendorReceiving accountingDataMigrationvendorReceivingObj1 = new AccountingDataMigrationvendorReceiving();
	  		AccountingDataMigrationvendorReceiving accountingDataMigrationvendorReceivingObj2 = new AccountingDataMigrationvendorReceiving(null, true);
	  		AccountingDataMigrationvendorReceiving accountingDataMigrationvendorReceivingObj3 = new AccountingDataMigrationvendorReceiving(null, true, null, null, null);
	  		System.assertEquals(0, [Select count() from account]);
	 }
}