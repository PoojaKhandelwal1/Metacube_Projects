/**
 * Author: Nidhi Sharma
 * updated: Oct 24, 2016
 * Name: OptionAndFeeTriggerTest
 * Description: Test class for option and feee trigger
**/
@isTest
private class OptionAndFeeTriggerTest {

    static testMethod void optionAndFeeTriggerWithMSRPTest() {
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.Id, null, false, true,'Individual');
    	customer.Is_Customer__c = true;
    	insert customer;
    	
    	Part__c testPart = TestUtil.createPart(false, '123', vendor.Id, 'Test Part', testCategory.Id, 20, 40, 50, 100, 100);
    	testPart.Applicable_Tax__c = defaultSalesTax.Id;
    	insert testPart;
    	Test.startTest();
    	CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
    	insert coHeader;
    	Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
    	Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
    	List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
    	Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
    	dealItemRec.Unit_Model__c = unitmodel.Id;
    	dealItemRec.Deal__c = dealList[0].Id;
    	insert dealItemRec;
		
		Option_Fee__c optionAndFeeRecWithPart = new Option_Fee__c(); 
		optionAndFeeRecWithPart.Deal_Item__c = dealItemRec.Id;
		optionAndFeeRecWithPart.Part__c = testPart.Id;
		insert optionAndFeeRecWithPart;
		List<Option_Fee__c> optionAndFeeList = [Select Retail__c, Price__c from Option_Fee__c where Id = :optionAndFeeRecWithPart.Id];
		
		System.assertEquals(1, optionAndFeeList.size());
        system.assertEquals(55, optionAndFeeList[0].Retail__c);
        system.assertEquals(55, optionAndFeeList[0].Price__c);
        
        /*
        defaultPriceLevel.Name__c = 'Price';
        update defaultPriceLevel;
        update optionAndFeeRecWithPart;
        optionAndFeeList = [Select Retail__c, Price__c from Option_Fee__c where Id = :optionAndFeeRecWithPart.Id];
		
		System.assertEquals(1, optionAndFeeList.size());
        system.assertEquals(110, optionAndFeeList[0].Retail__c);
        system.assertEquals(110, optionAndFeeList[0].Price__c);
        */
    }
    
    static testMethod void optionAndFeeTriggerWithRetailPriceTest() {
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'Price', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.Id, null, false, true,'Individual');
    	customer.Is_Customer__c = true;
    	insert customer;
    	
    	Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 20, 40, 50, 100, 200);
    	Test.startTest();
    	CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
    	insert coHeader;
    	Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
    	Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
    	List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
    	Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
    	dealItemRec.Unit_Model__c = unitmodel.Id;
    	dealItemRec.Deal__c = dealList[0].Id;
    	insert dealItemRec;
		
		Option_Fee__c optionAndFeeRecWithPart = new Option_Fee__c(); 
		optionAndFeeRecWithPart.Deal_Item__c = dealItemRec.Id;
		optionAndFeeRecWithPart.Part__c = testPart.Id;
		insert optionAndFeeRecWithPart;
		List<Option_Fee__c> optionAndFeeList = [Select Retail__c, Price__c from Option_Fee__c where Id = :optionAndFeeRecWithPart.Id];
		
		System.assertEquals(1, optionAndFeeList.size());
        system.assertEquals(110, optionAndFeeList[0].Retail__c);
        system.assertEquals(110, optionAndFeeList[0].Price__c);
    }
    
    static testMethod void optionAndFeeTriggerWithCostTest() {
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'Cost', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.Id, null, false, true,'Individual');
    	customer.Is_Customer__c = true;
    	insert customer;
    	
    	Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 20, 40, 50, 100, 100);
    	Test.startTest();
    	CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
    	insert coHeader;
    	Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
    	Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
    	List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
    	Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
    	dealItemRec.Unit_Model__c = unitmodel.Id;
    	dealItemRec.Deal__c = dealList[0].Id;
    	insert dealItemRec;
		
		Option_Fee__c optionAndFeeRecWithPart = new Option_Fee__c(); 
		optionAndFeeRecWithPart.Deal_Item__c = dealItemRec.Id;
		optionAndFeeRecWithPart.Part__c = testPart.Id;
		insert optionAndFeeRecWithPart;
		List<Option_Fee__c> optionAndFeeList = [Select Retail__c, Price__c from Option_Fee__c where Id = :optionAndFeeRecWithPart.Id];
		
		System.assertEquals(1, optionAndFeeList.size());
        system.assertEquals(44, optionAndFeeList[0].Retail__c);
        system.assertEquals(44, optionAndFeeList[0].Price__c);
    }
    
    static testMethod void optionAndFeeTriggerWithAustraliaPricingOnTest() {
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        Applicable_Taxes__c applicabletax1 = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem1.Id);
        
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.Id, null, false, true,'Individual');
    	customer.Is_Customer__c = true;
    	insert customer;
    	
    	Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 20, 40, 50, 100, 100);
    	Test.startTest();
    	CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
    	insert coHeader;
    	Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
    	Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
    	List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
    	Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
    	dealItemRec.Unit_Model__c = unitmodel.Id;
    	dealItemRec.Deal__c = dealList[0].Id;
    	insert dealItemRec;
		
		TestUtil.createtaxsettingInGeneralConfig();
        
        Fee__c testFee = TestUtil.createFee(false, true, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, true);
        testFee.Applicable_Tax__c = salestax.Id;
        insert testFee;
        Option_Fee__c optionAndFeeRecWithFee = new Option_Fee__c();
        optionAndFeeRecWithFee.Deal_Item__c = dealItemRec.Id;
		optionAndFeeRecWithFee.Fee__c = testFee.Id;
		insert optionAndFeeRecWithFee;
		List<Option_Fee__c> optionAndFeeList = [Select Retail__c, Price__c from Option_Fee__c where Id = :optionAndFeeRecWithFee.Id];
		Test.stopTest();
		system.assertEquals(84.75, optionAndFeeList[0].Retail__c.setScale(2));
		system.assertEquals(84.75, optionAndFeeList[0].Price__c.setScale(2));
    }
}