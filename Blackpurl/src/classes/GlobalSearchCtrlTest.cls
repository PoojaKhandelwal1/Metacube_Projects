/**
 * Author: Richa Mittal
 * Since: Sept 9, 2016
 * Name: GlobalSearchCtrlTest
 * Description: It includes test methods for GlobalSearchCtrl page.
**/
@isTest
public with sharing class GlobalSearchCtrlTest {
    
    @testSetup
	private static void setupTestData() {
		TestUtil.createNameSpaceInGeneralConfig();
		
		User testUser = TestUtil.createUser(true, 'a@b.c', 'Sharma', 'en_US', 'Shantanu.Sharma@metacube.com', 'sshar');
		User_Group__c userGroup = new User_Group__c(name='testing user group',OwnerId =testUser.id, Colour_Code__c='rgba(255,100,88,1)',Accounting_settings_export__c='Primary',
                                           Costs__c='Primary',Customer_invoicing__c='Primary',customers__c='Primary',Deal__c='Primary',fees__c='Primary',Internal_Service__c='Primary',
                                           kits__c='Secondary',labor__c='Secondary',Merchandise__c='Primary',Override_price__c='Primary',Oversell_inventory__c='Primary',parts__c='Primary',
                                           Price_file_import__c='Secondary',Price_Levels__c='Secondary',quick_sale__c='Secondary',Returns__c='Secondary',Sales_Taxes__c='Secondary',Service_job__c='Secondary',
                                           Special_order__c='None',stock_units__c='Secondary',System_Settings__c='Primary',Vendor_invoicing__c='Primary',Vendor_order__c='Primary',
                                           vendor_products__c='Primary',Vendor_receiving__c='Primary',vendors__c='Primary');
		insert userGroup;
  		
  		List<User_Group__c> userGroupList = [select Id from User_Group__c];
  		String userId = UserInfo.getUserId();
  		List<String> usersList = new List<String>();
  		usersList.add(userId);
  		
  		UserSettingCtrl.assignUserToGroup(BPUtility.getEncodedString(System.JSON.serialize(usersList)), BPUtility.getEncodedString(userGroupList[0].Id));
	}
	//For testing Customer in search
	private static testmethod void checkCustomerSearch(){
    	Account customer = TestUtil.createCustomer(false, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
    	customer.Work_Number__c = '3123132213';
    	customer.Is_Customer__c = true;
    	customer.Is_Vendor__c = false;
    	customer.Email__c = null;
    	customer.Home_Number__c = '213231132';
    	customer.Other_Email__c = 'testother@gmail.com';
    	customer.Preferred_Email__c = null;
    	customer.Work_Email__c = null;
    	insert customer;
    	Test.startTest();
    	GlobalSearchResultsWrapper.GlobalQueryJSON globalQueryJSON = new GlobalSearchResultsWrapper.GlobalQueryJSON();
		globalQueryJSON.GlobalSearchText = 'Harley';
		globalQueryJSON.GlobalSearchKeyword = 'Customers';
	   	globalQueryJSON.GlobalSearchKeywordKey = 'Customer';
	    String jsonStr = System.Json.serialize(globalQueryJSON);
	   	String  searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
	   	GlobalSearchResultsWrapper globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
	   	system.assertEquals(globalSearchResults.TotalRecords, 1);
    	Test.stopTest();
	}
	//For testing Sales Tax Search
	private static testmethod void checkSalesTaxSearch(){
		Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        GlobalSearchResultsWrapper.GlobalQueryJSON globalQueryJSON = new GlobalSearchResultsWrapper.GlobalQueryJSON();
		globalQueryJSON.GlobalSearchText = 'Test Sales Tax';
	   	globalQueryJSON.GlobalSearchKeyword = 'Sales Taxes';
	   	globalQueryJSON.GlobalSearchKeywordKey = 'Tax';
	    String jsonStr = System.Json.serialize(globalQueryJSON);
	    String searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
	   	GlobalSearchResultsWrapper globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
	   	system.assertEquals(globalSearchResults.TotalRecords, 1);
	}
	//For testing People Search
	private static testmethod void checkPeopleSearch(){
		GlobalSearchResultsWrapper.GlobalQueryJSON globalQueryJSON = new GlobalSearchResultsWrapper.GlobalQueryJSON();
		globalQueryJSON.GlobalSearchText = ' ';
	    globalQueryJSON.GlobalSearchKeyword = 'People';
	    globalQueryJSON.GlobalSearchKeywordKey = ' ';
	    String jsonStr = System.Json.serialize(globalQueryJSON);
	    String searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
	   	GlobalSearchResultsWrapper globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
	   	system.assertEquals(globalSearchResults.TotalRecords, 0);
	}
	//For testing Category Search
	private static testmethod void checkCategorySearch(){
		Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
		GlobalSearchResultsWrapper.GlobalQueryJSON globalQueryJSON = new GlobalSearchResultsWrapper.GlobalQueryJSON();
		globalQueryJSON.GlobalSearchText = 'Test Category';
        globalQueryJSON.GlobalSearchKeyword = 'Item Categories';
        globalQueryJSON.GlobalSearchKeywordKey = 'Category';
        String jsonStr = System.Json.serialize(globalQueryJSON);
        String searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
       	GlobalSearchResultsWrapper globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
       	system.assertEquals(globalSearchResults.TotalRecords, 1);
	}
	//FOr testing Part in Search
	private static testmethod void checkPartSearch(){
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
		vendor.Is_Customer__c = false;
		vendor.Is_Vendor__c = true;
		vendor.Other_Email__c = 'testvendor@gmail.com';
		vendor.Preferred_Email__c = null;
		vendor.Work_Email__c = null;
		insert vendor;
		Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
		GlobalSearchResultsWrapper.GlobalQueryJSON globalQueryJSON = new GlobalSearchResultsWrapper.GlobalQueryJSON();
        globalQueryJSON.GlobalSearchText = 'test';
	 	globalQueryJSON.GlobalSearchKeyword = 'Parts';
		globalQueryJSON.GlobalSearchKeywordKey = 'Part';
		String jsonStr = System.Json.serialize(globalQueryJSON);
		Test.startTest();
		String searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
		GlobalSearchResultsWrapper globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
		Test.stopTest();
		system.assertEquals(globalSearchResults.TotalRecords, 1);
	}   	
	//For testing Vendor Invoicing in search
	private static testmethod void checkVendorInvoicingSearch(){
		PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
        
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true;
        Part.Package_Qty__c = 22;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 1;
        //part.Qty_On_Order__c = 0;
        //insert part;
        
        Part__c part2 = TestUtil.createPart(false, 'partNumberP03', vendor.Id, 'Test Part03', testCategory.Id, 10, 20, 50, 100, 50);
        insert new List<SObject>{part, part2};
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 150);
        CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(false, coHeader.Id, part2.Id, 150);
		insert new List<SObject>{coLineItem, coLineItem1};
            
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
		Test.startTest();
        //Vendor_Receiving_Header__c vor = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
		String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(voHeader.Id), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        //String groupLineItems = VendorOrderCtrl.groupAllSimilarVOLineItem(vendor.Id, part.Id, voHeader.Id, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(false, vendor.Id, 'In Progress');
        vrh.Packing_Slip_Number__c = '12133';
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vorId), true));
        
        
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part.id), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 10, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        Test.stopTest();
        String UpdatedItemsSubsection2 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part2.id), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[1].Id), 40, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);

        
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        Vendor_Invoicing_Header__c viHeader = TestUtil.createVendorInvoiceHeader(true, vendor.Id, 'In Progress');
         
        String vendorInvoices = BPUtility.getDecodedString(VendorInvoicingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String addedVendorInvoice = BPUtility.getDecodedString(VendorInvoicingCtrl.addToItemsSubsection(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        
        VendorInvoicingCtrl.VIHeaderWrapper vendorInvoice = (VendorInvoicingCtrl.VIHeaderWrapper)System.JSON.deserialize(addedVendorInvoice, VendorInvoicingCtrl.VIHeaderWrapper.class);
		GlobalSearchResultsWrapper.GlobalQueryJSON globalQueryJSON = new GlobalSearchResultsWrapper.GlobalQueryJSON();
        globalQueryJSON.GlobalSearchText = vendorInvoice.VIGroupList[0].PackingNumber;
        
	   	globalQueryJSON.GlobalSearchKeyword = 'Vendor Invoices';
	   	globalQueryJSON.GlobalSearchKeywordKey = 'VI';
	    String jsonStr = System.Json.serialize(globalQueryJSON);
	    String searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
	   	GlobalSearchResultsWrapper globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
		system.assertEquals(globalSearchResults.TotalRecords , 1);			
	}
	//For testing Vendor Receivings in search
	static testmethod void checkVendorReceivingsSearch(){
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
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
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 1;
        //part.Qty_On_Order__c = 0;
        insert part;
        
        Part__c part2 = TestUtil.createPart(true, 'partNumberP03', vendor.Id, 'Test Part03', testCategory.Id, 10, 20, 50, 100, 50);
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(true, coHeader.Id, part2.Id, 150);

        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
		Test.startTest();
		String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(voHeader.Id), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(false, vendor.Id, 'In Progress');
       	vrh.Packing_Slip_Number__c = '12133';
       	insert vrh;
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vorId), true));
        
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        GlobalSearchResultsWrapper.GlobalQueryJSON globalQueryJSON = new GlobalSearchResultsWrapper.GlobalQueryJSON();
		globalQueryJSON.GlobalSearchText = 'VR-';
	   	globalQueryJSON.GlobalSearchKeyword = 'Vendor Receivings';
	   	globalQueryJSON.GlobalSearchKeywordKey = 'VR';
	    String jsonStr = System.Json.serialize(globalQueryJSON);
	    String searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
	   	GlobalSearchResultsWrapper globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
	   	Test.stopTest();
	   	system.assertEquals(globalSearchResults.TotalRecords, 2);
		
	}
	
	
	//For testing Price Level in search
	static testmethod void checkPriceLevelSearch(){
		Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        GlobalSearchResultsWrapper.GlobalQueryJSON globalQueryJSON = new GlobalSearchResultsWrapper.GlobalQueryJSON();
		globalQueryJSON.GlobalSearchText = 'Default Price Level';
	   	globalQueryJSON.GlobalSearchKeyword = 'Price Levels';
	   	globalQueryJSON.GlobalSearchKeywordKey = 'CO';
	    String jsonStr = System.Json.serialize(globalQueryJSON);
	    Test.startTest();
	    String searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
	   	GlobalSearchResultsWrapper globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
	   	Test.stopTest();
	   	system.assertEquals(globalSearchResults.TotalRecords, 1);
		
	}
	
	/*Commented as this old method for global search will not be used from now on - #3774
	static testMethod void getGlobalSearchResultsTest() {
		Account customer = TestUtil.createCustomer(false, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
    	customer.Work_Number__c = '3123132213';
    	customer.Is_Customer__c = true;
    	customer.Is_Vendor__c = false;
    	customer.Email__c = null;
    	customer.Home_Number__c = '213231132';
    	customer.Other_Email__c = 'testother@gmail.com';
    	customer.Preferred_Email__c = null;
    	customer.Work_Email__c = null;
    	insert customer;
    	Account customer1 = TestUtil.createCustomer(false, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
    	customer1.Work_Email__c = 'testwork1@gmail.com';
    	customer1.Other_Email__c = 'testother1@gmail.com';
    	insert customer1;
    	Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	vendor.Is_Customer__c = false;
    	vendor.Is_Vendor__c = true;
    	vendor.Other_Email__c = 'testvendor@gmail.com';
    	vendor.Preferred_Email__c = null;
    	vendor.Work_Email__c = null;
    	insert vendor;
    	Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, true);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, LabourCode.Id, Part.Id, 1, 5.0);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Payment__c coinvoicepayment1  = TestUtil.createCOInvoicePayment(true, coinvoiceHeader1.Id );
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(true, Vendor.Id);
        Product__c sublet = Testutil.createSublet(true, testCategory.Id, 'Code', 100, 'Description', 10, 1000, 'Active',  vendor.Id );
        User testUser = TestUtil.createUser(true, 'a@b.c', 'Sharma', 'en_US', 'Shantanu.Sharma@metacube.com', 'sshar');
        
        
        
        GlobalSearchResultsWrapper.GlobalQueryJSON globalQueryJSON = new GlobalSearchResultsWrapper.GlobalQueryJSON();
        globalQueryJSON.GlobalSearchText = 'harley';
        globalQueryJSON.GlobalSearchKeyword = '';
        globalQueryJSON.GlobalSearchKeywordKey = '';
        
        String jsonStr = System.Json.serialize(globalQueryJSON);
        
        String searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
       	GlobalSearchResultsWrapper globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
       	system.assertEquals(globalSearchResults.TotalRecords, 2); // 4 -> 2: Assertion Failed: expected 2, actual 4: Changed by Pooja 7 Jul 2017
 
        globalQueryJSON.GlobalSearchText = 'test';
        globalQueryJSON.GlobalSearchKeywordKey = 'skit';
        globalQueryJSON.GlobalSearchKeyword = 'People';

        jsonStr = System.Json.serialize(globalQueryJSON);
        searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
       	globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
       	system.assertEquals(globalSearchResults.TotalRecords, 0);

       

        globalQueryJSON.GlobalSearchText = '';
        globalQueryJSON.GlobalSearchKeyword = 'Kits';
        globalQueryJSON.GlobalSearchKeywordKey = 'Kit';
        jsonStr = System.Json.serialize(globalQueryJSON);
        searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
       	globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
       	system.assertEquals(globalSearchResults.TotalRecords, 1);
        
        
        
		globalQueryJSON.GlobalSearchText = '';
		globalQueryJSON.GlobalSearchKeyword = 'Labor Codes';
	    globalQueryJSON.GlobalSearchKeywordKey = 'Labor Code';
	    jsonStr = System.Json.serialize(globalQueryJSON);
	    searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
	   	globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
	   	system.assertEquals(globalSearchResults.TotalRecords, 1);
        
        globalQueryJSON.GlobalSearchText = 'Fee';
		globalQueryJSON.GlobalSearchKeyword = 'Fees';
	    globalQueryJSON.GlobalSearchKeywordKey = 'Fee';
	    jsonStr = System.Json.serialize(globalQueryJSON);
	    searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
	   	globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
	   	system.assertEquals(globalSearchResults.TotalRecords, 1);
	   	
	   	globalQueryJSON.GlobalSearchText = '';
	   	globalQueryJSON.GlobalSearchKeyword = 'Customer Orders';
	   	globalQueryJSON.GlobalSearchKeywordKey = 'CO';
	    jsonStr = System.Json.serialize(globalQueryJSON);
	    searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
	   	globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
	   	system.assertEquals(globalSearchResults.TotalRecords, 1);

		
	   	
	   	globalQueryJSON.GlobalSearchText = '';
	   	globalQueryJSON.GlobalSearchKeyword = 'Customer Payments';
	   	globalQueryJSON.GlobalSearchKeywordKey = 'Payment';
	    jsonStr = System.Json.serialize(globalQueryJSON);
	    searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
	   	globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
	   	system.assertEquals(globalSearchResults.TotalRecords, 1);
	    
	    
	   	
	   	globalQueryJSON.GlobalSearchText = '';
	   	globalQueryJSON.GlobalSearchKeyword = 'Customer Invoices';
	   	globalQueryJSON.GlobalSearchKeywordKey = 'CI';
	    jsonStr = System.Json.serialize(globalQueryJSON);
	    searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
	   	globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
	   	system.assertEquals(globalSearchResults.TotalRecords, 1);
	
		globalQueryJSON.GlobalSearchText = '';
	   	globalQueryJSON.GlobalSearchKeyword = 'Vendor Orders';
	   	globalQueryJSON.GlobalSearchKeywordKey = 'VO';
	    jsonStr = System.Json.serialize(globalQueryJSON);
	    searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
	   	globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
	   	system.assertEquals(globalSearchResults.TotalRecords, 1);
	
		globalQueryJSON.GlobalSearchText = '';
	   	globalQueryJSON.GlobalSearchKeyword = 'Vendor Product'; // Sublets
	   	globalQueryJSON.GlobalSearchKeywordKey = 'Vendor Product'; // Sublet
	    jsonStr = System.Json.serialize(globalQueryJSON);
	    searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
	   	globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
	   	system.assertEquals(globalSearchResults.TotalRecords, 1);
				
		
	   	globalQueryJSON.GlobalSearchText = '';
	   	globalQueryJSON.GlobalSearchKeyword = 'Users';
	   	globalQueryJSON.GlobalSearchKeywordKey = 'User';
	    jsonStr = System.Json.serialize(globalQueryJSON);
	    searchResults = BPUtility.getDecodedString(GlobalSearchCtrl.getGlobalSearchResults(BPUtility.getEncodedString(jsonStr)));
	   	globalSearchResults = (GlobalSearchResultsWrapper)Json.deserialize(searchResults,GlobalSearchResultsWrapper.class);
		system.assertNotEquals(globalSearchResults.TotalRecords , 0);
		
		
	   	
	   	
	}*/
}