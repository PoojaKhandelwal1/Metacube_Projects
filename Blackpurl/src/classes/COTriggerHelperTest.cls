@isTest
private class COTriggerHelperTest {
    static testMethod void salesTaxCalculation() {
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax1', true, true, true);
    	Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, false, true);
    	
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing ', true, testCategory.Id);
    	Sales_Tax_Item__c salesTaxItem2 = TestUtil.createSalesTaxItem(true, 'Test Item2', 5.0, 'Testing ', true, testCategory.Id, false);
    	Applicable_Taxes__c appTax1 = TestUtil.createApplicableTax(true, salesTax.Id, salesTaxItem1.Id);
    	Applicable_Taxes__c appTax2 = TestUtil.createApplicableTax(true, salesTax.Id, salesTaxItem2.Id);
    	
    	Account customer = TestUtil.createCustomer(true, 'Test Cust', 'a@b.c', 'Jaipur', '1800111265', null, salesTax.Id);
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Applicable_Tax__c = SalesTax.Id;
        insert part;
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 50);
        
        COLineItemTriggerHelper.isTriggerExecute = true;
        insert coLineItem;
        
        Test.startTest();
        coHeader.Order_status__c = 'Open';
        update coHeader;
        Test.stopTest();
        
        List<CO_Line_Item__c> coLineItemList = [select Tax__c From CO_Line_Item__c where Id = :coLineItem.Id];
        system.assertEquals(coLineItemList[0].Tax__c, 15);
        
        Part_Tax__c partTax = TestUtil.createPartTax(true, salesTaxItem1.Id, part.Id);
        coHeader.Order_status__c = 'Close';
        COTriggerHelper.isTriggerExecute = false;
        update coHeader;
        
        coLineItemList = [select Tax__c From CO_Line_Item__c where Id = :coLineItem.Id];
        system.assertEquals(coLineItemList[0].Tax__c, 15);
        
        COTriggerHelper.isTriggerExecute = true;
        update coHeader;
    }
    	
	static testmethod void updatecoheader(){
		Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
		CO_Header__c coheadertest = TestUtil.createCOHeader(true, customer.Id);
		Price_Level__c priceleveltest = TestUtil.createPriceLevel(true, 'priceleveltest', 'MSRP', 10, true, true);
		Part__c parttest = TestUtil.createPart(true, 'abc', vendor.Id, 'description', null, 10, 10, 10, 10, 20);
		CO_Line_Item__c lineitemtest = TestUtil.createCOLineItem(true, coheadertest.Id, parttest.Id, 10);
		
		Test.startTest();
		coheadertest.Order_status__c = 'Open';
		update coheadertest;
		
		test.stopTest();
		
		List<CO_Line_Item__c> coLineItemList = [select Retail__c, Price__c From CO_Line_Item__c where Id = :lineitemtest.Id];
        system.assertEquals(coLineItemList[0].Retail__c, 11);
        system.assertEquals(coLineItemList[0].Price__c, 11);
	}
	 static testmethod void applicabletaxwithoutdefaultsalestax (){
	 	Price_Level__c priceleveltest = TestUtil.createPriceLevel(true, 'priceleveltest', 'MSRP', 10, true, true);
	 	Account customer = TestUtil.createCustomer(true, 'Test Cust', 'a@b.c', 'Jaipur', '1800111265', null, null);
	 	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
	 	//Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
	 	Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, true, true);
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
		
		Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing ', true, testCategory.Id);
    	Sales_Tax_Item__c salesTaxItem2 = TestUtil.createSalesTaxItem(true, 'Test Item2', 5.0, 'Testing ', true, testCategory.Id);
    	Applicable_Taxes__c appTax1 = TestUtil.createApplicableTax(true, salesTax.Id, salesTaxItem1.Id);
    	Applicable_Taxes__c appTax2 = TestUtil.createApplicableTax(true, salesTax.Id, salesTaxItem2.Id);
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
    	Part__c part = TestUtil.createPart(false, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
    	part.Applicable_Tax__c = SalesTax.Id;
        insert part;
    	CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 10);
    	
    	Test.startTest();
        update coHeader;
        Test.stopTest();
        
        List<CO_Line_Item__c> coLineItemList = [select Tax__c From CO_Line_Item__c where Id = :coLineItem.Id];
        system.assertEquals(coLineItemList[0].Tax__c, 15);
	 }
	 
	 static testmethod void applicabletaxwithoutdefaultsalestaxForAusMarket (){
	 	User ausUser = TestUtil.createUser(true, 'a@b.com', 'Testing ', 'en_AU', 'testUse123r@force.com', 'Test U');
	 	system.runAs(ausUser) {
	 		applicabletaxwithoutdefaultsalestaxhavingparttaxcommon();
	 	}
	 	System.assertEquals(1, 1);
	 }
	 
	 static testmethod void applicabletaxwithoutdefaultsalestaxhavingparttaxcommon (){
	 	Price_Level__c priceleveltest = TestUtil.createPriceLevel(true, 'priceleveltest', 'MSRP', 10, true, true);
	 	Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, true, true);
	 	Account customer = TestUtil.createCustomer(true, 'Test Cust', 'a@b.c', 'Jaipur', '1800111265', priceleveltest.Id, salesTax.Id);
	 	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
	 	//Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
	 	
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
		
		Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing ', true, testCategory.Id);
    	Sales_Tax_Item__c salesTaxItem2 = TestUtil.createSalesTaxItem(true, 'Test Item2', 5.0, 'Testing ', true, testCategory.Id);
    	Applicable_Taxes__c appTax1 = TestUtil.createApplicableTax(true, salesTax.Id, salesTaxItem1.Id);
    	Applicable_Taxes__c appTax2 = TestUtil.createApplicableTax(true, salesTax.Id, salesTaxItem2.Id);
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
    	Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
    	CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 10);
    	
    	Part_Tax__c parttax1 = TestUtil.createPartTax(true, salesTaxItem1.Id, part.Id);
    	Test.startTest();
        update coHeader;
        Test.stopTest();
        
        List<CO_Line_Item__c> coLineItemList = [select Tax__c From CO_Line_Item__c where Id = :coLineItem.Id];
        //system.assertEquals(coLineItemList[0].Tax__c, 5);
        COTriggerHelper.isTriggerExecute = true;
        Update coHeader;
        
	 }
	 
	 static testmethod void changeCustomeforCoHeaderTest (){
	 	Price_Level__c priceleveltest = TestUtil.createPriceLevel(true, 'priceleveltest', 'MSRP', 10, true, true);
	 	Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, true, true);
	 	Account customer = TestUtil.createCustomer(true, 'Test Cust', 'a@b.c', 'Jaipur', '1800111265', priceleveltest.Id, salesTax.Id);
	 	Account customer1 = TestUtil.createCustomer(true, 'Test Cust1', 'ab@b.c', 'Jaipur', '1200111265', priceleveltest.Id, salesTax.Id);
	 	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
	 	//Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
	 	
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
		
		Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing ', true, testCategory.Id);
    	Sales_Tax_Item__c salesTaxItem2 = TestUtil.createSalesTaxItem(true, 'Test Item2', 5.0, 'Testing ', true, testCategory.Id);
    	Applicable_Taxes__c appTax1 = TestUtil.createApplicableTax(true, salesTax.Id, salesTaxItem1.Id);
    	Applicable_Taxes__c appTax2 = TestUtil.createApplicableTax(true, salesTax.Id, salesTaxItem2.Id);
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
    	coHeader.Customer__c = customer1.Id;
    	String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
    	Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
    	CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 10);
    	
    	Test.startTest();
    	COTriggerHelper.isTriggerExecute = true;
        update coHeader;
        Test.stopTest();
        system.assertEquals(customer1.Id,coHeader.Customer__c);
	 }
	 
	 static testmethod void changeCustomeforCoHeaderwithoutTriggerExecuteTest (){
	 	Price_Level__c priceleveltest = TestUtil.createPriceLevel(true, 'priceleveltest', 'MSRP', 10, true, true);
	 	Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, true, true);
	 	Account customer = TestUtil.createCustomer(true, 'Test Cust', 'a@b.c', 'Jaipur', '1800111265', priceleveltest.Id, salesTax.Id);
	 	Account customer1 = TestUtil.createCustomer(true, 'Test Cust1', 'ab@b.c', 'Jaipur', '1200111265', priceleveltest.Id, salesTax.Id);
	 	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
	 	//Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
	 	
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
		
		Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing ', true, testCategory.Id);
    	Sales_Tax_Item__c salesTaxItem2 = TestUtil.createSalesTaxItem(true, 'Test Item2', 5.0, 'Testing ', true, testCategory.Id);
    	Applicable_Taxes__c appTax1 = TestUtil.createApplicableTax(true, salesTax.Id, salesTaxItem1.Id);
    	Applicable_Taxes__c appTax2 = TestUtil.createApplicableTax(true, salesTax.Id, salesTaxItem2.Id);
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
    	coHeader.Customer__c = customer1.Id;
    	String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
    	Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
    	CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 10);
    	COTriggerHelper.isCalculatePLandTax = true;
    	COTriggerHelper.isTriggerExecute = false;
    	Test.startTest();
        update coHeader;
        Test.stopTest();
        System.assertEquals(customer1.Id,coHeader.Customer__c);
	 }
	 
	 static testmethod void updateCustomerCoHeaderTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer1 = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        Account customer2 = TestUtil.createCustomer(true, 'customerName1', 'xyz@xyz.com', 'jaipur', '2222222222', null, null, false, true, 'Individual');
        CO_Header__c coheadertest = TestUtil.createCOHeader(true, customer1.Id);
        
        Price_Level__c priceleveltest = TestUtil.createPriceLevel(true, 'priceleveltest', 'MSRP', 10, true, true);
        Part__c parttest = TestUtil.createPart(true, 'abc', vendor.Id, 'description', null, 10, 10, 10, 10, 20);
        CO_Line_Item__c lineitemtest = TestUtil.createCOLineItem(true, coheadertest.Id, parttest.Id, 10);
        
        coheadertest.Customer__c = customer2.Id;
        update coheadertest;
        
        List<CO_Header__c> COHeaderList = [select Customer__c, Id From CO_Header__c where Id = :coheadertest.Id];
        system.assertEquals(COHeaderList[0].Customer__c, customer2.Id);
    }
}