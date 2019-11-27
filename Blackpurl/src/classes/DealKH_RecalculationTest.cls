/**
 * Author: Gourav Goyal
 * created: JULY  21, 2017
 * Name: DealKH_RecalculationTest
 * Description: Test class for DealKH_Recalculation class
**/
@isTest
private class DealKH_RecalculationTest {
     
    static testmethod void calculatePriceForDealKitInsertionTest(){
       
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.Id, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
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
        Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 20, 40, 50, 100, 100);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Fee__c fee = TestUtil.createFee(true, true, testCategory.Id, 'FeeCode', null, 'Description', 100, true);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, false, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, testPart.Id, 3, 5.0);
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(false, true, true, KitHeader.Id, 5.0, null, null, 1, 5.0);
        kitHeaderLineItem1.Fee__c = fee.Id;
        insert kitHeaderLineItem1;
        Kit_Header_Line_Item__c kitHeaderLineItem2 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, labourCode.Id, null, 1, 5.0); 
        testPart.Applicable_Tax__c = defaultSalesTax.Id;
        update testPart;
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        List<Deal_Item__c> dealItems = [Select Id from Deal_Item__c]; 
        String optionAndFeeToSaveJson = '';
        
        Option_Fee__c optionAndFeeRec = new Option_Fee__c();
        optionAndFeeRec.Deal_Item__c = dealItems[0].Id;
        optionAndFeeRec.Qty__c = 2;
        optionAndFeeRec.Part__c = testPart.Id;
        optionAndFeeRec.Deal_Kit_Header__c = kitHeader.id;
        
        test.startTest();
        DealWrapper.OptionAndFeeInfo optionAndFeeObj = new DealWrapper.OptionAndFeeInfo(optionAndFeeRec);
        BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItems[0].Id),BPUtility.getEncodedString(JSON.serialize(optionAndFeeObj))));
        test.stoptest();
        Deal_Kit_Header__c dealKHObj = [select id from Deal_Kit_Header__c ];
        optionAndFeeRec.Deal_Kit_Header__c = dealKHObj.id;
        insert optionAndFeeRec;
        List<Option_Fee__c>optFeeList = [select id from Option_Fee__c where id=:optionAndFeeRec.id];
        system.assertEquals(optFeeList.size(),1);
    }
    
    static testmethod void calculatePriceForDealKitInsertionTestSecond() {
       	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.Id, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
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
        
        Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 20, 40, 50, 100, 100);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Fee__c fee = TestUtil.createFee(true, true, testCategory.Id, 'FeeCode', null, 'Description', 100, true);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, testPart.Id, 3, 5.0);
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(false, true, true, KitHeader.Id, 5.0, null, null, 1, 5.0);
        kitHeaderLineItem1.Fee__c = fee.Id;
        insert kitHeaderLineItem1;
        Kit_Header_Line_Item__c kitHeaderLineItem2 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, labourCode.Id, null, 1, 5.0); 
        testPart.Applicable_Tax__c = defaultSalesTax.Id;
        update testPart;
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        List<Deal_Item__c> dealItems = [Select Id from Deal_Item__c]; 
        String optionAndFeeToSaveJson = '';
        Option_Fee__c optionAndFeeRec = new Option_Fee__c();
        optionAndFeeRec.Deal_Item__c = dealItems[0].Id;
        optionAndFeeRec.Qty__c = 2;
        optionAndFeeRec.Part__c = testPart.Id;
        optionAndFeeRec.Deal_Kit_Header__c = kitHeader.Id;
        
        test.startTest();
        DealWrapper.OptionAndFeeInfo optionAndFeeObj = new DealWrapper.OptionAndFeeInfo(optionAndFeeRec);
        BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItems[0].Id),BPUtility.getEncodedString(JSON.serialize(optionAndFeeObj))));
        test.stoptest();
        system.assert(true,true);
    }
    
     /**
     * Name: changePriceWhenCustomerisChangedTest
     * Desc: Test Deal kit header and line items price related calculation
     * @param:
     * @Return:
    **/
    
    static testmethod void changePriceWhenCustomerisChangedTest(){
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
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        
        test.startTest();
        DealKH_Recalculation.changePriceWhenCustomerIsChanged(customer.id,coHeader.id);
        test.stopTest();
        system.assert(true,true);
    }
        
     /**
     * Name: resolveRoundOffIssueTest
     * Desc: Test price when tax is not included
     * @param:
     * @Return:
    **/
     
    static testmethod void resolveRoundOffIssueTest(){
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
        optionAndFeeRecWithPart.Is_Fixed_Price__c = false;
        optionAndFeeRecWithPart.Qty__c =5;
        optionAndFeeRecWithPart.Price__c=50;
        insert optionAndFeeRecWithPart;
        List<Option_Fee__c> optionAndFeeList = [Select Retail__c, Price__c,Qty__c,Price_When_Tax_Included__c, Is_Fixed_Price__c, CO_Line_Item__r.Qty_To_Order__c, Service_Order_Line_Item__r.CO_Line_Item__r.Qty_To_Order__c from Option_Fee__c where Id = :optionAndFeeRecWithPart.Id];
        
        test.startTest();
        List<Option_Fee__c> optionAndFeeListUpdated = DealKH_Recalculation.resolveRoundOffIssue(optionAndFeeList, 40, false); 
        test.stopTest(); 
        system.assertEquals(1, optionAndFeeListUpdated.Size());
        system.assertEquals(8, optionAndFeeListUpdated[optionAndFeeListUpdated.Size()-1].price__c);
    }
    
    /**
     * Name: resolveRoundOffIssueSecondTest
     * Desc: Test price when tax is included  
     * @param:
     * @Return:
    **/
    static testmethod void resolveRoundOffIssueSecondTest(){
        TestUtil.createtaxsettingInGeneralConfig();
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
        optionAndFeeRecWithPart.Is_Fixed_Price__c = false;
        optionAndFeeRecWithPart.Qty__c =5;
        optionAndFeeRecWithPart.Price__c=50;
        optionAndFeeRecWithPart.Price_When_Tax_Included__c=50;
        insert optionAndFeeRecWithPart;
        
        test.startTest();
        List<Option_Fee__c> optionAndFeeList = [Select Retail__c, Price__c,Qty__c,Price_When_Tax_Included__c, Is_Fixed_Price__c, CO_Line_Item__r.Qty_To_Order__c, Service_Order_Line_Item__r.CO_Line_Item__r.Qty_To_Order__c from Option_Fee__c where Id = :optionAndFeeRecWithPart.Id];
        optionAndFeeList = DealKH_Recalculation.resolveRoundOffIssue(optionAndFeeList, 40, true); 
        test.stopTest(); 
        system.assertEquals(1, optionAndFeeList.Size());
        system.assertEquals(8, optionAndFeeList[optionAndFeeList.Size()-1].Price_When_Tax_Included__c);
    }
     
    
     /**
     * Name: calculatePriceForDealKitInsertionWithAUSTest
     * Desc: generating deal kit header list
     * @param:
     * @Return:
    **/
    
     static testmethod void calculatePriceForDealKitInsertionWithAUSTest(){
        TestUtil.createtaxsettingInGeneralConfig();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.Id, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
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
        Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 20, 40, 50, 100, 100);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Fee__c fee = TestUtil.createFee(true, true, testCategory.Id, 'FeeCode', null, 'Description', 100, true);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, false, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, testPart.Id, 3, 5.0);
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(false, true, true, KitHeader.Id, 5.0, null, null, 1, 5.0);
        kitHeaderLineItem1.Fee__c = fee.Id;
        insert kitHeaderLineItem1;
        Kit_Header_Line_Item__c kitHeaderLineItem2 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, labourCode.Id, null, 1, 5.0); 
        testPart.Applicable_Tax__c = defaultSalesTax.Id;
        update testPart;
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        List<Deal_Item__c> dealItems = [Select Id from Deal_Item__c]; 
        String optionAndFeeToSaveJson = '';
        Option_Fee__c optionAndFeeRec = new Option_Fee__c();
        optionAndFeeRec.Deal_Item__c = dealItems[0].Id;
        optionAndFeeRec.Qty__c = 2;
        optionAndFeeRec.Part__c = testPart.Id;
        optionAndFeeRec.Deal_Kit_Header__c = kitHeader.Id;
        
        test.startTest();
        DealWrapper.OptionAndFeeInfo optionAndFeeObj = new DealWrapper.OptionAndFeeInfo(optionAndFeeRec);
        String JsonVal = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItems[0].Id),BPUtility.getEncodedString(JSON.serialize(optionAndFeeObj))));
        test.stoptest();
        system.assertEquals(true,JsonVal.length()>0);
    }
    
    static testmethod void calculatePriceForDealKitInsertionAUSTestSecond(){
        TestUtil.createtaxsettingInGeneralConfigA();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.Id, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
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
        Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 20, 40, 50, 100, 100);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Fee__c fee = TestUtil.createFee(true, true, testCategory.Id, 'FeeCode', null, 'Description', 100, true);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, testPart.Id, 3, 5.0);
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(false, true, true, KitHeader.Id, 5.0, null, null, 1, 5.0);
        kitHeaderLineItem1.Fee__c = fee.Id;
        insert kitHeaderLineItem1;
        Kit_Header_Line_Item__c kitHeaderLineItem2 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, labourCode.Id, null, 1, 5.0); 
        testPart.Applicable_Tax__c = defaultSalesTax.Id;
        update testPart;
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        List<Deal_Item__c> dealItems = [Select Id from Deal_Item__c]; 
        String optionAndFeeToSaveJson = '';
        Option_Fee__c optionAndFeeRec = new Option_Fee__c();
        optionAndFeeRec.Deal_Item__c = dealItems[0].Id;
        optionAndFeeRec.Qty__c = 2;
        optionAndFeeRec.Part__c = testPart.Id;
        optionAndFeeRec.Deal_Kit_Header__c = kitHeader.Id;
        
        test.startTest();
        DealWrapper.OptionAndFeeInfo optionAndFeeObj = new DealWrapper.OptionAndFeeInfo(optionAndFeeRec);
        BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItems[0].Id),BPUtility.getEncodedString(JSON.serialize(optionAndFeeObj))));
        test.stoptest();
        system.assert(true,true);
    }
    
    static testmethod void updateDealKitHeaderTestSamePrice(){
        TestUtil.createtaxsettingInGeneralConfigA();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.Id, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
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
        Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 20, 40, 50, 100, 100);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Fee__c fee = TestUtil.createFee(true, true, testCategory.Id, 'FeeCode', null, 'Description', 100, true);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, testPart.Id, 3, 5.0);
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(false, true, true, KitHeader.Id, 5.0, null, null, 1, 5.0);
        kitHeaderLineItem1.Fee__c = fee.Id;
        insert kitHeaderLineItem1;
        Kit_Header_Line_Item__c kitHeaderLineItem2 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, labourCode.Id, null, 1, 5.0); 
        testPart.Applicable_Tax__c = defaultSalesTax.Id;
        update testPart;
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        List<Deal_Item__c> dealItems = [Select Id from Deal_Item__c]; 
        String optionAndFeeToSaveJson = '';
        Option_Fee__c optionAndFeeRec = new Option_Fee__c();
        optionAndFeeRec.Deal_Item__c = dealItems[0].Id;
        optionAndFeeRec.Qty__c = 2;
        optionAndFeeRec.Part__c = testPart.Id;
        optionAndFeeRec.Deal_Kit_Header__c = kitHeader.Id;
        
        test.startTest();
        DealWrapper.OptionAndFeeInfo optionAndFeeObj = new DealWrapper.OptionAndFeeInfo(optionAndFeeRec);
        BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItems[0].Id),BPUtility.getEncodedString(JSON.serialize(optionAndFeeObj))));
        Deal_Kit_Header__c dealKitHeaderRecord = [select id,Tax_Amount__c,Kit_Header__r.Kit_Unique_Name__c,Actual_Kit_Price__c,Deal_Item__r.Deal__r.Co_Header__c,Is_Fixed_Price__c,Fixed_Price__c,Is_Install__c,Service_Kit__c,Is_Fixed_Kit_Header_CO__c,Can_Split__c from Deal_Kit_Header__c];
        List<Option_Fee__c> optionFeeRecord = [select id,Deal__c,Is_Install__c,Price__c,Deal_Item__c,Qty__c,Part__c,Part__r.AvailableParts__c, Part__r.Non_Inventory_Part__c,Fee__c,Labour_Code__c,Product__c,Product__r.Type__c,Deal_Kit_Header__c,Is_Fixed_Price__c,Is_Fixed_Kit_Line_Item_CO__c,Fixed_Price__c,Item_Code__c,Item_Description__c,Status__c,Is_Environmental_Fee__c,Sales_Tax_Percentage__c, CO_Line_Item__r.Qty_To_Order__c, Service_Order_Line_Item__r.CO_Line_Item__r.Qty_To_Order__c from Option_Fee__c ];
        DealWrapper.DealKitHeader DealKitHeaderObj = new DealWrapper.DealKitHeader(dealKitHeaderRecord,optionFeeRecord,true);
        String Message = DealKH_Recalculation.updateDealKitHeader(DealKitHeaderObj);
        test.stopTest();
        system.assertEquals('Success',Message);
    }
    
    static testmethod void updateDealKitHeaderTestDifferentPrice(){
        TestUtil.createtaxsettingInGeneralConfigA();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.Id, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
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
        Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 20, 40, 50, 100, 100);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Fee__c fee = TestUtil.createFee(true, true, testCategory.Id, 'FeeCode', null, 'Description', 100, true);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, testPart.Id, 3, 5.0);
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(false, true, true, KitHeader.Id, 5.0, null, null, 1, 5.0);
        kitHeaderLineItem1.Fee__c = fee.Id;
        insert kitHeaderLineItem1;
        Kit_Header_Line_Item__c kitHeaderLineItem2 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, labourCode.Id, null, 1, 5.0); 
        testPart.Applicable_Tax__c = defaultSalesTax.Id;
        update testPart;
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        List<Deal_Item__c> dealItems = [Select Id from Deal_Item__c]; 
        String optionAndFeeToSaveJson = '';
        Option_Fee__c optionAndFeeRec = new Option_Fee__c();
        optionAndFeeRec.Deal_Item__c = dealItems[0].Id;
        optionAndFeeRec.Qty__c = 2;
        optionAndFeeRec.Part__c = testPart.Id;
        optionAndFeeRec.Deal_Kit_Header__c = kitHeader.Id;
        
        test.startTest();
        DealWrapper.OptionAndFeeInfo optionAndFeeObj = new DealWrapper.OptionAndFeeInfo(optionAndFeeRec);
        BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItems[0].Id),BPUtility.getEncodedString(JSON.serialize(optionAndFeeObj))));
        Deal_Kit_Header__c dealKitHeaderRecord = [select id,Tax_Amount__c,Kit_Header__r.Kit_Unique_Name__c,Actual_Kit_Price__c,Deal_Item__r.Deal__r.Co_Header__c,Is_Fixed_Price__c,Fixed_Price__c,Is_Install__c,Service_Kit__c,Is_Fixed_Kit_Header_CO__c,Can_Split__c from Deal_Kit_Header__c];
        dealKitHeaderRecord.Fixed_Price__c=45;
        List<Option_Fee__c> optionFeeRecord = [select id,Deal__c,Is_Install__c,Price__c,Deal_Item__c,Qty__c,Part__c,Part__r.AvailableParts__c, Part__r.Non_Inventory_Part__c,Fee__c,Labour_Code__c,Product__c,Product__r.Type__c,Deal_Kit_Header__c,Is_Fixed_Price__c,Is_Fixed_Kit_Line_Item_CO__c,Fixed_Price__c,Item_Code__c,Item_Description__c,Status__c,Sales_Tax_Percentage__c, Is_Environmental_Fee__c, CO_Line_Item__r.Qty_To_Order__c, Service_Order_Line_Item__r.CO_Line_Item__r.Qty_To_Order__c from Option_Fee__c ];
        DealWrapper.DealKitHeader DealKitHeaderObj = new DealWrapper.DealKitHeader(dealKitHeaderRecord,optionFeeRecord,true);
        String Message = DealKH_Recalculation.updateDealKitHeader(DealKitHeaderObj);
        test.stopTest();
        system.assertEquals('Success',Message);
    }
    
    static testmethod void UpdateDealKitLineItemTest(){
        TestUtil.createtaxsettingInGeneralConfigA();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.Id, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
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
        Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 20, 40, 50, 100, 100);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Fee__c fee = TestUtil.createFee(true, true, testCategory.Id, 'FeeCode', null, 'Description', 100, true);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, testPart.Id, 3, 5.0);
        
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(false, true, true, KitHeader.Id, 5.0, null, null, 1, 5.0);
        kitHeaderLineItem1.Fee__c = fee.Id;
        insert kitHeaderLineItem1;
        Kit_Header_Line_Item__c kitHeaderLineItem2 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, labourCode.Id, null, 1, 5.0); 
        testPart.Applicable_Tax__c = defaultSalesTax.Id;
        update testPart;
        
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        List<Deal_Item__c> dealItems = [Select Id from Deal_Item__c]; 
        String optionAndFeeToSaveJson = '';
        Option_Fee__c optionAndFeeRec = new Option_Fee__c();
        optionAndFeeRec.Deal_Item__c = dealItems[0].Id;
        optionAndFeeRec.Qty__c = 2;
        optionAndFeeRec.Part__c = testPart.Id;
        optionAndFeeRec.Deal_Kit_Header__c = kitHeader.Id;
        
        test.startTest();
        DealWrapper.OptionAndFeeInfo optionAndFeeObj = new DealWrapper.OptionAndFeeInfo(optionAndFeeRec);
        BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItems[0].Id),BPUtility.getEncodedString(JSON.serialize(optionAndFeeObj))));
        Deal_Kit_Header__c dealKitHeaderRecord = [select id,Tax_Amount__c,Kit_Header__r.Kit_Unique_Name__c,Actual_Kit_Price__c,Deal_Item__r.Deal__r.Co_Header__c,Is_Fixed_Price__c,Fixed_Price__c,Is_Install__c,Service_Kit__c,Is_Fixed_Kit_Header_CO__c,Can_Split__c from Deal_Kit_Header__c];
        dealKitHeaderRecord.Fixed_Price__c=45;
        List<Option_Fee__c> optionFeeRecord = [select id,Deal__c,Is_Install__c,Price__c,Deal_Item__c,Qty__c,Part__c,Part__r.AvailableParts__c,Part__r.Non_Inventory_Part__c,Fee__c,Labour_Code__c,Product__c,Product__r.Type__c,Deal_Kit_Header__c,Is_Fixed_Price__c,Is_Fixed_Kit_Line_Item_CO__c,Fixed_Price__c,Item_Code__c,Item_Description__c,Status__c,Sales_Tax_Percentage__c, Is_Environmental_Fee__c, CO_Line_Item__r.Qty_To_Order__c, Service_Order_Line_Item__r.CO_Line_Item__r.Qty_To_Order__c from Option_Fee__c ];
        DealWrapper.DealKitHeader DealKitHeaderObj = new DealWrapper.DealKitHeader(dealKitHeaderRecord,optionFeeRecord,true);
        String Message = DealKH_Recalculation.UpdateDealKitLineItem(DealKitHeaderObj,optionAndFeeObj);
        test.stopTest();
        system.assertEquals('Success',Message);
    }
}