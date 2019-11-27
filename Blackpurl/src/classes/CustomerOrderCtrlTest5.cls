/**
 * Author: Tarun Khandelwal
 * Since: Oct 18, 2018
 * Name: CustomerOrderCtrlTest5 test
 * Description: Controller test Class of Customer order ctrl.
**/
@isTest
private class CustomerOrderCtrlTest5 {
    
    @testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
    }
    
    static testMethod void addUnitToDealTest() {
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        String statusToUpdate = 'In Progress';
        CO_Header__c co = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert co;
        DealWrapper dealWrapperObj = (DealWrapper)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(co.Id))),DealWrapper.class);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Unit_Price_Cost__c unitPriceAndCost1 = new Unit_Price_Cost__c(Customer_Owned_Unit__c = customerOwnedUnit.Id, Type__c = 'Factory', Cost__c = 3000);
        Unit_Price_Cost__c unitPriceAndCost2 = new Unit_Price_Cost__c(Customer_Owned_Unit__c = customerOwnedUnit.Id, Type__c = 'Dealer', Cost__c = 3555);
        insert new List<Unit_Price_Cost__c>{unitPriceAndCost1, unitPriceAndCost2};
        
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        Test.startTest();
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :co.Id];
        String dealItemJson = BPUtility.getDecodedString(CustomerOrderCtrl.saveTemporaryUnit(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItemJsonToSave)));
        
        dealWrapperObj = (DealWrapper)Json.deserialize(dealItemJson, DealWrapper.class);
        dealWrapperObj = (DealWrapper)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealWrapperObj.DealInfo.Id))), DealWrapper.class);
        
        //List<Deal_Item__c> dealItems = [Select Id from Deal_Item__c where Deal__c =: dealWrapperObj.DealInfo.Id]; 
        //dealWrapperObj = (DealWrapper)Json.deserialize(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(dealItems[0].Id),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealWrapperObj.DealInfo.Id)), DealWrapper.class);
        Test.stopTest();
        System.assertEquals(2, dealWrapperObj.UnitList.size());
        
    }
    /* Added by Ankit */
    
    static testMethod void removeUnitFromDealTest() {
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        CO_Header__c co = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert co;
        Deal__c dealRec = new Deal__c(CO_Header__c = co.Id, Status__c = 'Quotation', Unit_Status__c = 'Temporary');
        insert dealRec;
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016, Deal__c = dealRec.Id); 
        insert dealItemRec;
        Test.startTest();
        List<Deal_Item__c> dealItemList = [Select id from Deal_Item__c where Deal__c = :dealRec.Id];
        System.assertEquals(dealItemList.size(),1);
        CustomerOrderCtrl.removeUnitFromDeal(BPUtility.getEncodedString(dealRec.Id),BPUtility.getEncodedString(dealItemList[0].id));
        dealItemList = [Select Id from Deal_Item__c where Deal__c =: dealRec.Id]; 
        Test.stopTest();
        System.assertEquals(0, dealItemList.size());
    }
    /* Added by Ankit */
    /**nidhi
    static testMethod void createPriceAndCostLineItemTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1 = TestUtil.createCOInvoiceItem(true, testCategory.Id, coinvoiceHeader1.Id, null );
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c();
        soHeaderRec.Id = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        soHeaderRec.Name__c = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name;
        soHeaderRec.SO_Type__c = 'Internal Service';
        soHeaderRec.Customer_Owned_Unit__c = customerOwnedUnit.Id;
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        update soHeaderRec;
        List<CO_Invoice_Item__c> COInvoiceItems = [select Category__c, CO_Line_Item__c, isActive__c, Item_Category_Code__c, Item_ID__c, Item_Type__c, Price__c, Qty__c from CO_Invoice_Item__c];
        String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coinvoiceHeader1.Id)));
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedorderAction(BPUtility.getEncodedString(COInvoiceItemJSON), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('Internal')));
        List<Unit_Price_Cost__c> unitPriceCostList = [Select id from Unit_Price_Cost__c];
        System.assertEquals(1,unitPriceCostList.size());
    }nidhi**/
    /* Added by ANkit 
    static testMethod void updateDealUnitCostPriceTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c();
        soHeaderRec.Id = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        soHeaderRec.Name__c = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name;
        soHeaderRec.SO_Type__c = 'Internal Service';
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        
        soHeaderRec.Customer_Owned_Unit__c = customerOwnedUnit.Id;
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        update soHeaderRec;
        List<CO_Invoice_Item__c> COInvoiceItems = [select Category__c, CO_Line_Item__c, isActive__c, Item_Category_Code__c, Item_ID__c, Item_Type__c, Price__c, Qty__c from CO_Invoice_Item__c];
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1 = TestUtil.createCOInvoiceItem(true, testCategory.Id, coinvoiceHeader1.Id, null );
        Unit_Price_Cost__c  unitPriceCost = new Unit_Price_Cost__c();
        unitPriceCost.Customer_Owned_Unit__c = customerOwnedUnit.Id;
        unitPriceCost.CO_Invoice_Header__c = coinvoiceHeader1.Id;
        lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        List<Service_Order_Header__c> soHeaderList = [select Status__c, (select Id,Kit_Price__c,Actual_Kit_Price__c,Qty_Needed__c from Service_Order_Line_Items__r) from Service_Order_Header__c where Id =: soHeaderRec.Id];
        update soHeaderRec;
        CO_Header__c co = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c = 'Unit Deal', Customer__c=customer.Id);
        insert co;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(co.Id));
        String dealJson = BPUtility.getDecodedString(CustomerOrderCtrl.getDealDetails(BPUtility.getEncodedString(co.Id), null));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealJson);
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :co.Id];
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        Test.startTest();
        String dealItemJson = BPUtility.getDecodedString(CustomerOrderCtrl.saveTemporaryUnit(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItemJsonToSave)));
        List<Deal_Item__c> dealItems = [Select Id from Deal_Item__c]; 
      //  CustomerOrderCtrl.updateDealUnitCostPrice(BPUtility.getEncodedString(Json.serialize(soHeaderList[0].Service_Order_Line_Items__r)),BPUtility.getEncodedString(dealWrapperObj.Id),BPUtility.getEncodedString(dealItems[0].id));
        
    }*/
     /* Added By Ankit
        Modified by Nidhi */
    static testMethod void updateDealStatusTest() {
        TestUtil.createtaxsettingInGeneralConfigA();
        String expectedStatus = 'In Progress';
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Test.startTest();
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnitRec = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnitRec.Unit_Type__c = 'STOCK';
        customerOwnedUnitRec.Status__c = 'Available';
        insert customerOwnedUnitRec;
        CO_Header__c co = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c = 'Unit Deal', Customer__c=customer.Id);
        insert co;
        Deal__c dealRec = new Deal__c(CO_Header__c = co.Id, Status__c = 'Quotation', Unit_Status__c = 'Temporary');
        insert dealRec;
        Deal_Item__c dealItemRec = new Deal_Item__c(Customer_Owned_Unit__c = customerOwnedUnitRec.id); 
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :co.Id];
        String dealItemJson = BPUtility.getDecodedString(CustomerOrderCtrl.saveTemporaryUnit(BPUtility.getEncodedString(dealRec.Id),BPUtility.getEncodedString(dealItemJsonToSave)));
        Test.stopTest();
        
        String dealJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(expectedStatus)));
        DealWrapper.DealInfoWrapper dealWrapperInfoObj  = (DealWrapper.DealInfoWrapper)Json.deserialize(dealJson,DealWrapper.DealInfoWrapper.class); 
        System.assertEquals(expectedStatus, dealWrapperInfoObj.DealStatus);
    }
    //Edited by kv 01/31/2017
    static testMethod void updateDealUnitCostPriceTest() {
        TestUtil.createtaxsettingInGeneralConfigA();
        
        Decimal expectedQty = 3;
        Decimal expectedPrice = 6000;
        Deal_Unit_Price_Cost__c dealUnitPriceCostRec = new Deal_Unit_Price_Cost__c(Item_Description__c = 'Test Deal Unit Price And Cost 2', Price__c = 7000, Qty__c = 1, Type__c ='Factory');
        insert dealUnitPriceCostRec;
        
        List<Deal_Unit_Price_Cost__c> dealUnitPriceCostList = [Select id, Qty__c, Price__c from Deal_Unit_Price_Cost__c where Id = :dealUnitPriceCostRec.Id];
        System.assertEquals(1, dealUnitPriceCostList[0].Qty__c);
        
        List<DealWrapper.FactoryOption> dealFactoryOption = new List<DealWrapper.FactoryOption>{new DealWrapper.FactoryOption(dealUnitPriceCostRec)};
        dealFactoryOption[0].Qty = expectedQty;
        dealFactoryOption[0].Price = expectedPrice;
        String dealJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealUnitCostPrice(BPUtility.getEncodedString(System.JSON.serialize(dealFactoryOption)), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null)));
        dealUnitPriceCostList = [Select id, Qty__c, Price__c from Deal_Unit_Price_Cost__c where Id = :dealUnitPriceCostRec.Id];
        system.assertEquals(expectedQty, dealUnitPriceCostList[0].Qty__c);
        system.assertEquals(expectedPrice, dealUnitPriceCostList[0].Price__c);
    }
    
    static testMethod void saveSoReviewInfoTest() {
        
        TestUtil.createtaxsettingInGeneralConfigA();
        
        //Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
        defaultPriceLevel.Labour_Rate__c = 60 ;
        Insert defaultPriceLevel;
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        Applicable_Taxes__c applicabletax1 = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem1.Id);
        
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Labour_Code__c labourCode = TestUtil.createLabourCode(false, true, testCategory.Id, 'Code', null, 'Description', true, 2, 'LabourCodeName', 50, true);
        labourCode.Applicable_Tax__c = salestax.Id;
        insert labourCode;
        Tax_Exemption__c taxExemption = Testutil.createTaxExemption(true, customer.Id, salestaxItem.Id);
        
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        
        String SOReviewInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOReviewInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('{"OdometerOnDeparture":0,"ManualNotes":["test"],"KitHeaderNotes":[],"Id":"'+soHeaderDetailsObj.SOList[0].SOReviewRec.Id+'"}')));
        SOHeaderWrapper.SOReview soHeaderDetailsObj1 = (SOHeaderWrapper.SOReview) System.JSON.deserialize(SOReviewInfo, SOHeaderWrapper.SOReview.Class);
    }
     /**
     * Name: parsePageAttrs
     * Desc: Method to Parse JSON String to class instance for Pagination and sort attributes
     * @param:  (1) JSONString - String - JSON String 
     * @return: RelatedListPaginationSorting - Class Object
    **/
    public static VendorPaginationSorting parsePageAttrs(String json) { 
        System.assertEquals(1, 1);
        return (VendorPaginationSorting) System.JSON.deserialize(json, VendorPaginationSorting.class);
    }  
           
    static testMethod void getServiceWorksheetPrintDetailTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, unitmake.Id, unitmodel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        customerOwnedUnit.Status__c = 'Sold';
        insert customerOwnedUnit;
        
        Test.startTest();
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        soHeaderDetailsObj.SOList[0].SOHeaderInfo.COUId = customerOwnedUnit.Id;
        String jsonStr = System.Json.serialize(soHeaderDetailsObj.SOList[0].SOHeaderInfo);
        
        String soHeader1Json = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        String serviceWorksheetPrintDetailJson = BPUtility.getDecodedString(CustomerOrderCtrl.getServiceWorksheetPrintDetail(BPUtility.getEncodedString(coHeader.Id)));
        Test.stopTest();
        List<SOWorkSheetWrapper.ServiceWorkSheetPrintDetail> soPrintDetailListObj = 
                    (List<SOWorkSheetWrapper.ServiceWorkSheetPrintDetail>) System.JSON.deserialize(serviceWorksheetPrintDetailJson, List<SOWorkSheetWrapper.ServiceWorkSheetPrintDetail>.class);
        system.assertEquals(true, soPrintDetailListObj[0].IsUnitSelected);
        system.assertEquals(1, soPrintDetailListObj[0].SOInfoWrapperList.size());       
    }  
   
    static testMethod void saveWorkseetSelectionJsonTest() {
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        String expectedText = 'Test Json';
        CustomerOrderCtrl.saveWorkseetSelectionJson(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(expectedText));
        List<CO_Header__c> coHeaderList = [Select SO_Worksheet_User_selection__c from CO_Header__c where Id =: coHeader.Id];
        system.assertEquals(expectedText, coHeaderList[0].SO_Worksheet_User_selection__c);
    }
    //Internal Service CO
    
    /*static testMethod void createInternalServiceCO(){
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(false, null);
        coHeader.CO_Type__c = 'Internal Service';
        insert coHeader; 
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        String decodedSOHeaderDetails =  BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.id)));
        SOHeaderWrapper soHeaderObj = (SOHeaderWrapper)Json.deserialize(decodedSOHeaderDetails,SOHeaderWrapper.class);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnitRec = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnitRec.Unit_Type__c = 'STOCK';
        insert customerOwnedUnitRec;
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        List<Service_Order_Header__c> serviceOrderHeaderRec = [Select id,Customer_Owned_Unit__c from Service_Order_Header__c where id =: soHeaderObj.SOList[0].SOHeaderInfo.id];
        serviceOrderHeaderRec[0].Customer_Owned_Unit__c =    customerOwnedUnitRec.Id;
        update serviceOrderHeaderRec;
        Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id);
        Test.startTest();
        CustomerOrderCtrl.addLineItems(testPart.id, soHeaderObj.SOList[0].SOHeaderInfo.id, coHeader.id,customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        CustomerOrderCtrl.addLineItems(labourCode.id, soHeaderObj.SOList[0].SOHeaderInfo.id, coHeader.id,customer.Id);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, LabourCode.Id, testPart.Id, 1, 5.0);
        CustomerOrderCtrl.addLineItems(kitHeaderLineItem.id, soHeaderObj.SOList[0].SOHeaderInfo.id, coHeader.id,customer.Id);
        Fee__c fee = TestUtil.createFee(true, true, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        CustomerOrderCtrl.addLineItems(fee.id, soHeaderObj.SOList[0].SOHeaderInfo.id, coHeader.id,customer.Id);
        Test.stopTest();
        
    }*/
    
    /** Comment added by nidhi - 09-11-2016
    //Internal Service CO
    static testMethod void createInternalServiceCO1(){
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
        defaultPriceLevel.Labour_Rate__c = 60 ;
        insert defaultPriceLevel;
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        coHeader.CO_Type__c = 'Internal Service';
        insert coHeader; 
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        SOHeaderWrapper soHeaderObj = (SOHeaderWrapper)Json.deserialize(soHeader,SOHeaderWrapper.class);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnitRec = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnitRec.Unit_Type__c = 'STOCK';
        insert customerOwnedUnitRec;
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        
        List<Service_Order_Header__c> serviceOrderHeader = [Select id,Customer_Owned_Unit__c from Service_Order_Header__c where id =: soHeaderObj.SOList[0].SOHeaderInfo.id];
        serviceOrderHeader[0].Customer_Owned_Unit__c = customerOwnedUnitRec.Id;
        update  serviceOrderHeader;
        Part__c testpart = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        String soHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(testPart.id),BPUtility.getEncodedString(serviceOrderHeader[0].id),BPUtility.getEncodedString(coHeader.id),BPUtility.getEncodedString(customer.Id)));
        soHeaderObj = (SOHeaderWrapper)Json.deserialize(soHeaderDetails,SOHeaderWrapper.class);
        soHeaderObj.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(labourCode.id),BPUtility.getEncodedString(serviceOrderHeader[0].id),BPUtility.getEncodedString(coHeader.id),BPUtility.getEncodedString(customer.Id));
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, null, testPart.Id, 1, 5.0);
        CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeaderLineItem.id),BPUtility.getEncodedString(serviceOrderHeader[0].id),BPUtility.getEncodedString(coHeader.id),BPUtility.getEncodedString(customer.Id));
        Fee__c fee = TestUtil.createFee(true, true, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, true);
        Test.startTest();
        soHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(fee.id), BPUtility.getEncodedString(soHeaderObj.SOList[0].SOHeaderInfo.id),BPUtility.getEncodedString(coHeader.id),BPUtility.getEncodedString(customer.Id)));
        soHeaderObj = (SOHeaderWrapper)Json.deserialize(soHeaderDetails,SOHeaderWrapper.class);
        //SOHeaderWrapper.SOHeader soHeaderObj = new SOHeaderWrapper.SOHeader();
        List<CO_Invoice_Item__c> COInvoiceItems = [select Category__c, CO_Line_Item__c, isActive__c, Item_Category_Code__c, Item_ID__c, Item_Type__c, Price__c, Qty__c from CO_Invoice_Item__c];
        List<CO_Invoice_Header__c> coInvoiceHeaders = new List<CO_Invoice_Header__c>();
        coInvoiceHeaders = SOQLUtil.getCOInvoiceHeaderByCOHeaderId(coHeader.Id);
        String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaders[0].Id)));
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedorderAction(BPUtility.getEncodedString(COInvoiceItemJSON), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('Internal')));
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(closedOrder, COHeaderWrapper.class);
        String coDetailsJSON1 = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetailsByGridName(BPUtility.getEncodedString( coHeader.Id), BPUtility.getEncodedString( null)));
        COHeaderWrapper coDetails1 = (COHeaderWrapper) System.JSON.deserialize(coDetailsJSON1, COHeaderWrapper.class);
        
        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].Total,165);
        
        //System.assert(false,customerOwnedUnitRec);
        CO_Header__c dealCOHeader = TestUtil.createCOHeader(false, customer.Id);
        dealCOHeader.CO_Type__c = 'Customer';
        insert dealCOHeader; 
        String dealdetails = BPUtility.getDecodedString(CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(dealCOHeader.id)));
        DealWrapper.DealInfoWrapper dealWrapperInfoObj = (DealWrapper.DealInfoWrapper)Json.deserialize(dealdetails,DealWrapper.DealInfoWrapper.class);
        
        Deal_Item__c dealItemRec = new Deal_Item__c(Customer_Owned_Unit__c = customerOwnedUnitRec.id); 
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :dealCOHeader.Id];
        String dealItemJson = BPUtility.getDecodedString(CustomerOrderCtrl.saveTemporaryUnit(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItemJsonToSave)));
        dealItemObj = (DealItem)Json.deserialize(dealItemJson,DealItem.class);
        List<Deal_Item__c> dealItems = [Select Id from Deal_Item__c]; 
        
        
        dealWrapperInfoObj = (DealWrapper.DealInfoWrapper)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(dealItems[0].id),BPUtility.getEncodedString(customerOwnedUnitRec.id),BPUtility.getEncodedString(dealWrapperInfoObj.Id))),DealWrapper.DealInfoWrapper.class);
        Test.stopTest();
        Decimal totalOfDealerInstalledOption = 0;
        DealWrapper dealWrapperObj = (DealWrapper)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.getDealDetails(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(null))),DealWrapper.class);
        for(DealWrapper.DealerInstalledOption dealerinstalledOptionRec : dealWrapperObj.UnitList[0].DealerInstalledOptionList){
            totalOfDealerInstalledOption += dealerinstalledOptionRec.TotalPrice; 
        }
        //Needs to be corrected as Functionality not working now 
        System.assertEquals(totalOfDealerInstalledOption,110);  
        //COHeaderWrapper coheaderWrapperRec = (COHeaderWrapper)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(dealCOHeader.id)),COHeaderWrapper.class);
        
        //System.assert(false,coheaderWrapperRec);
        //System.assert(false,dealWrapperInfoObj);
        //List<Deal_Unit_Price_Cost__c> dealUnitPriceCostRec = [Select Id,Price__C,Qty__c from Deal_Unit_Price_Cost__c];
        //System.assert(false,dealUnitPriceCostRec);   
        
    }**/
    
    //Internal Service CO
    static testMethod void createInternalServiceCO2(){
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
        defaultPriceLevel.Labour_Rate__c = 60 ;
        insert defaultPriceLevel;
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        coHeader.CO_Type__c = 'Internal Service';
        insert coHeader; 
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        //Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        SOHeaderWrapper soHeaderObj = (SOHeaderWrapper)Json.deserialize(soHeader,SOHeaderWrapper.class);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnitRec = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnitRec.Unit_Type__c = 'STOCK';
        customerOwnedUnitRec.Status__c = 'Available';
        insert customerOwnedUnitRec;
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        
        //START : Commented and added by nidhi - 09/11/2016
        update new Service_Order_Header__c(Id = soHeaderObj.SOList[0].SOHeaderInfo.Id, Customer_Owned_Unit__c = customerOwnedUnitRec.Id);
        //END : Commented and added by nidhi - 09/11/2016
        Test.startTest();
        Part__c testpart = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        String soHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(testPart.id),BPUtility.getEncodedString(soHeaderObj.SOList[0].SOHeaderInfo.id),BPUtility.getEncodedString(coHeader.id),BPUtility.getEncodedString(customer.Id)));
        soHeaderObj = (SOHeaderWrapper)Json.deserialize(soHeaderDetails,SOHeaderWrapper.class);
        List<CO_Invoice_Item__c> COInvoiceItems = [select Category__c, CO_Line_Item__c, isActive__c, Item_Category_Code__c, Item_ID__c, Item_Type__c, Price__c, Qty__c from CO_Invoice_Item__c];
        List<CO_Invoice_Header__c> coInvoiceHeaders = new List<CO_Invoice_Header__c>();
        coInvoiceHeaders = SOQLUtil.getCOInvoiceHeaderByCOHeaderId(coHeader.Id);
        Test.stopTest();
        createInternalServiceCO2_future(coInvoiceHeaders[0].Id, coHeader.Id);
        /*String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaders[0].Id)));
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedorderAction(BPUtility.getEncodedString(COInvoiceItemJSON), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('Internal')));
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(closedOrder, COHeaderWrapper.class);
        String coDetailsJSON1 = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetailsByGridName(BPUtility.getEncodedString( coHeader.Id), BPUtility.getEncodedString( null)));
        COHeaderWrapper coDetails1 = (COHeaderWrapper) System.JSON.deserialize(coDetailsJSON1, COHeaderWrapper.class);
        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].Total,55);*/
    }
    
    @future
    private static void createInternalServiceCO2_future(String invHeaderId, String coHeaderId) {
        String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(invHeaderId)));
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedorderAction(BPUtility.getEncodedString(COInvoiceItemJSON), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('Internal')));
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(closedOrder, COHeaderWrapper.class);
        String coDetailsJSON1 = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString( null)));
        COHeaderWrapper coDetails1 = (COHeaderWrapper) System.JSON.deserialize(coDetailsJSON1, COHeaderWrapper.class);
        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].Total,55);
    }
    
    //By default Labour Need is set to 1 
    static testMethod void logServiceHours(){
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        coHeader.CO_Type__c = 'Customer';
        insert coHeader;
        Technician__c technicianRec1 = new Technician__c(Technician_Name__c = 'Test Name', Active__c = true);
        insert technicianRec1;
        Technician__c technicianRec2 = new Technician__c(Technician_Name__c = 'Test Name', Active__c = true);
        insert technicianRec2;
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsList);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1'); 
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', true, 10, 'LabourCodeName', 10, true);
        
        CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(labourCode.id),BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.id),BPUtility.getEncodedString(coHeader.id),BPUtility.getEncodedString(customer.Id));
        
        List<User> currentUserInfo = SOQLUtil.getCurrentUserInfo();
        User testUser = TestUtil.createUser(true, 'a@b.c', 'Sharma', 'en_US', 'Shantanu.Sharma@metacube.com', 'sshar');
        Hours_Logged__c hoursLoggedRec = new Hours_Logged__c();
        hoursLoggedRec.Technician__c = technicianRec1.id;
        hoursLoggedRec.Time_Spent_h__c = 2;
        hoursLoggedRec.Start_Date_Time__c = datetime.newInstance(2017, 12, 12, 10, 30, 0);
        hoursLoggedRec.Work_Performed_Date__c = Date.newInstance(2017, 12, 9);
        hoursLoggedRec.End_Date_Time__c= datetime.newInstance(2017, 12, 12, 12, 30, 0);
        hoursLoggedRec.Service_Order_Header__c = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        insert hoursLoggedRec;
        String soHeaderId = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        List<Hours_Logged__c> hoursLoggedList = [Select Technician__c,Start_Date_Time__c,Calculated_Hours__c,End_Date_Time__c, Total_Hours__c,Technician__r.Technician_Name__c, Employee__c,Employee__r.Name ,Notes__c,Original_Estimate__c,Previously_Logged__c,Remaining_Estimate_d__c,Remaining_Estimate_h__c,Remaining_Estimate_m__c,Service_Order_Header__c,Work_Performed_Date__c,Time_Spent_m__c,Time_Spent__c,Name,Time_Spent_d__c,Service_Order_Header__r.Status__c,Time_Spent_h__c,Notes_Required__c,CreatedDate from Hours_Logged__c where id =: hoursLoggedRec.id];
        SOHeaderWrapper.HoursLogged hourLoggedJson = new SOHeaderWrapper.HoursLogged(hoursLoggedList[0]);
        String hourLoggedJsonString = Json.serialize(hourLoggedJson);
        List<SOHeaderWrapper.HoursLogged> hoursLoggedWrapperList = (List<SOHeaderWrapper.HoursLogged>)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.saveHoursLogged(BPUtility.getEncodedString(hourLoggedJsonString),BPUtility.getEncodedString(coHeader.Id))),List<SOHeaderWrapper.HoursLogged>.class);
        
        Hours_Logged__c hoursLoggedRec1 = new Hours_Logged__c();
        hoursLoggedRec1.Technician__c = technicianRec2.id;
        hoursLoggedRec1.Time_Spent_h__c = 3;
        hoursLoggedRec1.Service_Order_Header__c = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        hoursLoggedRec1.Start_Date_Time__c = datetime.newInstance(2017, 12, 12, 10, 30, 0);
        hoursLoggedRec1.Work_Performed_Date__c = Date.newInstance(2017, 12, 9);
        hoursLoggedRec1.End_Date_Time__c= datetime.newInstance(2017, 12, 12, 12, 30, 0);
        insert hoursLoggedRec1;
        // added for package upload by gourav
        Test.startTest();
        List<Hours_Logged__c> hoursLoggedList1 = [Select Technician__c,Start_Date_Time__c,Calculated_Hours__c,End_Date_Time__c, Total_Hours__c,Technician__r.Technician_Name__c, Employee__c,Employee__r.Name ,Notes__c,Original_Estimate__c,Previously_Logged__c,Remaining_Estimate_d__c,Remaining_Estimate_h__c,Remaining_Estimate_m__c,Service_Order_Header__c,Work_Performed_Date__c,Time_Spent_m__c,Time_Spent__c,Name,Time_Spent_d__c,Service_Order_Header__r.Status__c,Time_Spent_h__c,Notes_Required__c,CreatedDate from Hours_Logged__c where id =: hoursLoggedRec1.id];
        SOHeaderWrapper.HoursLogged hourLoggedJson1 = new SOHeaderWrapper.HoursLogged(hoursLoggedList1[0]);
        String hourLoggedJsonString1 = Json.serialize(hourLoggedJson);
        List<SOHeaderWrapper.HoursLogged> hoursLoggedWrapperList1 = (List<SOHeaderWrapper.HoursLogged>)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.saveHoursLogged(BPUtility.getEncodedString(hourLoggedJsonString1),BPUtility.getEncodedString(coHeader.Id))),List<SOHeaderWrapper.HoursLogged>.class);
        List<Technician_Hour__c> technicalHoursLoggedList = new List<Technician_Hour__c>();
        technicalHoursLoggedList = [Select Total_Hours__c from Technician_Hour__c];
        System.assertEquals(technicalHoursLoggedList[0].Total_Hours__c,4.00);
        System.assertEquals(technicalHoursLoggedList[1].Total_Hours__c,6.00);
        List<Service_Order_Line_Item__c> soliList = [select Id from Service_Order_Line_Item__c];
        CustomerOrderCtrl.removeLineItems(BPUtility.getEncodedString(soliList[0].id),BPUtility.getEncodedString(coHeader.id),BPUtility.getEncodedString(soHeaderId));
        
        String SOHeaderDetails3 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader,soItemGrid,checkOut,specialOrder')));
        SOHeaderWrapper soHeaderDetailsObj3 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails3, SOHeaderWrapper.class);
        List<Technician_Hour__c> technicalHoursLoggedList1 = new List<Technician_Hour__c>();
        technicalHoursLoggedList1 = [Select Total_Hours__c from Technician_Hour__c];
        Test.stopTest();
        //System.assertEquals(technicalHoursLoggedList1[0].Total_Hours__c,0);
        //System.assertEquals(technicalHoursLoggedList1[1].Total_Hours__c,0);
        
    }   
    
    //By default Labour Need is set to 1 
    /*static testMethod void logServiceHoursMovementCheck(){
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        coHeader.CO_Type__c = 'Customer';
        insert coHeader;
        Technician__c technicianRec1 = new Technician__c(Technician_Name__c = 'Test Name', Active__c = true);
        insert technicianRec1;
        
        Technician__c technicianRec2 = new Technician__c(Technician_Name__c = 'Test Name', Active__c = true);
        insert technicianRec2;
        //logServiceHoursMovementCheckAsyncHandling(coHeader.Id, technicianRec1.id, customer.Id, testCategory.Id,technicianRec2.id);
        
        // Service Job 1
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsList);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1'); 
        Test.startTest();
        List<User> currentUserInfo = SOQLUtil.getCurrentUserInfo();
        User testUser = TestUtil.createUser(true, 'a@b.c', 'Sharma', 'en_US', 'Shantanu.Sharma@metacube.com', 'sshar');
        Hours_Logged__c hoursLoggedRec = new Hours_Logged__c();
        hoursLoggedRec.Technician__c = technicianRec1.id;
        hoursLoggedRec.Time_Spent_h__c = 2;
        hoursLoggedRec.Service_Order_Header__c = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        hoursLoggedRec.Start_Date_Time__c = datetime.newInstance(2017, 12, 12, 10, 30, 0);
        hoursLoggedRec.Work_Performed_Date__c = Date.newInstance(2017, 12, 9);
        hoursLoggedRec.End_Date_Time__c= datetime.newInstance(2017, 12, 12, 12, 30, 0);
        insert hoursLoggedRec;
        String soHeaderId = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        // added for package upload by gourav
        List<Hours_Logged__c> hoursLoggedList = [Select Technician__c,Start_Date_Time__c,Calculated_Hours__c,End_Date_Time__c,Total_Hours__c, Technician__r.Technician_Name__c, Employee__c,Employee__r.Name ,Notes__c,Original_Estimate__c,Previously_Logged__c,Remaining_Estimate_d__c,Remaining_Estimate_h__c,Remaining_Estimate_m__c,Service_Order_Header__c,Work_Performed_Date__c,Time_Spent_m__c,Time_Spent__c,Name,Time_Spent_d__c,Service_Order_Header__r.Status__c,Time_Spent_h__c,Notes_Required__c,CreatedDate from Hours_Logged__c where id =: hoursLoggedRec.id];
        SOHeaderWrapper.HoursLogged hourLoggedJson = new SOHeaderWrapper.HoursLogged(hoursLoggedList[0]);
        String hourLoggedJsonString = Json.serialize(hourLoggedJson);
        List<SOHeaderWrapper.HoursLogged> hoursLoggedWrapperList = (List<SOHeaderWrapper.HoursLogged>)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.saveHoursLogged(BPUtility.getEncodedString(hourLoggedJsonString),BPUtility.getEncodedString(coHeader.Id))),List<SOHeaderWrapper.HoursLogged>.class);
        
        Hours_Logged__c hoursLoggedRec1 = new Hours_Logged__c();
        hoursLoggedRec1.Technician__c = technicianRec2.id;
        hoursLoggedRec1.Time_Spent_h__c = 3;
        hoursLoggedRec1.Service_Order_Header__c = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        insert hoursLoggedRec1;
        List<Hours_Logged__c> hoursLoggedList1 = [Select Technician__c,Start_Date_Time__c,Calculated_Hours__c,End_Date_Time__c,Total_Hours__c, Technician__r.Technician_Name__c, Employee__c,Employee__r.Name ,Notes__c,Original_Estimate__c,Previously_Logged__c,Remaining_Estimate_d__c,Remaining_Estimate_h__c,Remaining_Estimate_m__c,Service_Order_Header__c,Work_Performed_Date__c,Time_Spent_m__c,Time_Spent__c,Name,Time_Spent_d__c,Service_Order_Header__r.Status__c,Time_Spent_h__c,Notes_Required__c,CreatedDate from Hours_Logged__c where id =: hoursLoggedRec1.id];
        SOHeaderWrapper.HoursLogged hourLoggedJson1 = new SOHeaderWrapper.HoursLogged(hoursLoggedList1[0]);
        String hourLoggedJsonString1 = Json.serialize(hourLoggedJson);
        List<SOHeaderWrapper.HoursLogged> hoursLoggedWrapperList1 = (List<SOHeaderWrapper.HoursLogged>)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.saveHoursLogged(BPUtility.getEncodedString(hourLoggedJsonString1),BPUtility.getEncodedString(coHeader.Id))),List<SOHeaderWrapper.HoursLogged>.class);
        
        // Service Job 2 
        String soHeader1 = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails3 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj3 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails3, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsList);
        System.assertEquals(soHeaderDetailsObj3.SOList[1].SOHeaderInfo.Name, 'Service Job 2'); 
        
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', true, 10, 'LabourCodeName', 10, true);
        
        CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(labourCode.id),BPUtility.getEncodedString(soHeaderDetailsObj3.SOList[0].SOHeaderInfo.id),BPUtility.getEncodedString(coHeader.Id),BPUtility.getEncodedString(customer.Id));
        
        List<Service_Order_Line_Item__c> soliList = [select Id from Service_Order_Line_Item__c];
        
        CustomerOrderCtrl.moveLineItem(BPUtility.getEncodedString('[object object]'),BPUtility.getEncodedString(soliList[0].id),BPUtility.getEncodedString(soHeaderDetailsObj3.SOList[1].SOHeaderInfo.id),BPUtility.getEncodedString(coHeader.Id));
        
        List<Technician_Hour__c> technicalHoursLoggedList = new List<Technician_Hour__c>();
        technicalHoursLoggedList = [Select Total_Hours__c from Technician_Hour__c];
        Test.stopTest();
        System.assertEquals(technicalHoursLoggedList[0].Total_Hours__c,4.00);
        System.assertEquals(technicalHoursLoggedList[1].Total_Hours__c,6.00);
    }  */
    
    /**@future
    private static void logServiceHoursMovementCheckAsyncHandling(String coHeaderId, String technicianRec1Id, String customerId, String testCategoryId, String technicianRec2Id) {
        // Service Job 1
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeaderId)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsList);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1'); 
        
        List<User> currentUserInfo = SOQLUtil.getCurrentUserInfo();
        User testUser = TestUtil.createUser(true, 'a@b.c', 'Sharma', 'en_US', 'Shantanu.Sharma@metacube.com', 'sshar');
        Hours_Logged__c hoursLoggedRec = new Hours_Logged__c();
        hoursLoggedRec.Technician__c = technicianRec1Id;
        hoursLoggedRec.Time_Spent_h__c = 2;
        hoursLoggedRec.Service_Order_Header__c = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        hoursLoggedRec.Start_Date_Time__c = datetime.newInstance(2017, 12, 12, 10, 30, 0);
        hoursLoggedRec.Work_Performed_Date__c = Date.newInstance(2017, 12, 9);
        hoursLoggedRec.End_Date_Time__c= datetime.newInstance(2017, 12, 12, 12, 30, 0);
        insert hoursLoggedRec;
        String soHeaderId = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        // added for package upload by gourav
        List<Hours_Logged__c> hoursLoggedList = [Select Technician__c,Start_Date_Time__c,Calculated_Hours__c,End_Date_Time__c,Total_Hours__c, Technician__r.Technician_Name__c, Employee__c,Employee__r.Name ,Notes__c,Original_Estimate__c,Previously_Logged__c,Remaining_Estimate_d__c,Remaining_Estimate_h__c,Remaining_Estimate_m__c,Service_Order_Header__c,Work_Performed_Date__c,Time_Spent_m__c,Time_Spent__c,Name,Time_Spent_d__c,Service_Order_Header__r.Status__c,Time_Spent_h__c,Notes_Required__c,CreatedDate from Hours_Logged__c where id =: hoursLoggedRec.id];
        SOHeaderWrapper.HoursLogged hourLoggedJson = new SOHeaderWrapper.HoursLogged(hoursLoggedList[0]);
        String hourLoggedJsonString = Json.serialize(hourLoggedJson);
        List<SOHeaderWrapper.HoursLogged> hoursLoggedWrapperList = (List<SOHeaderWrapper.HoursLogged>)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.saveHoursLogged(BPUtility.getEncodedString(hourLoggedJsonString),BPUtility.getEncodedString(coHeaderId))),List<SOHeaderWrapper.HoursLogged>.class);
        
        Hours_Logged__c hoursLoggedRec1 = new Hours_Logged__c();
        hoursLoggedRec1.Technician__c = technicianRec2Id;
        hoursLoggedRec1.Time_Spent_h__c = 3;
        hoursLoggedRec1.Service_Order_Header__c = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        insert hoursLoggedRec1;
        List<Hours_Logged__c> hoursLoggedList1 = [Select Technician__c,Start_Date_Time__c,Calculated_Hours__c,End_Date_Time__c,Total_Hours__c, Technician__r.Technician_Name__c, Employee__c,Employee__r.Name ,Notes__c,Original_Estimate__c,Previously_Logged__c,Remaining_Estimate_d__c,Remaining_Estimate_h__c,Remaining_Estimate_m__c,Service_Order_Header__c,Work_Performed_Date__c,Time_Spent_m__c,Time_Spent__c,Name,Time_Spent_d__c,Service_Order_Header__r.Status__c,Time_Spent_h__c,Notes_Required__c,CreatedDate from Hours_Logged__c where id =: hoursLoggedRec1.id];
        SOHeaderWrapper.HoursLogged hourLoggedJson1 = new SOHeaderWrapper.HoursLogged(hoursLoggedList1[0]);
        String hourLoggedJsonString1 = Json.serialize(hourLoggedJson);
        List<SOHeaderWrapper.HoursLogged> hoursLoggedWrapperList1 = (List<SOHeaderWrapper.HoursLogged>)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.saveHoursLogged(BPUtility.getEncodedString(hourLoggedJsonString1),BPUtility.getEncodedString(coHeaderId))),List<SOHeaderWrapper.HoursLogged>.class);
        
        // Service Job 2 
        String soHeader1 = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeaderId)));
        String SOHeaderDetails3 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj3 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails3, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsList);
        System.assertEquals(soHeaderDetailsObj3.SOList[1].SOHeaderInfo.Name, 'Service Job 2'); 
        
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategoryId, 'Code', coHeaderId, 'Description', true, 10, 'LabourCodeName', 10, true);
        
        CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(labourCode.id),BPUtility.getEncodedString(soHeaderDetailsObj3.SOList[0].SOHeaderInfo.id),BPUtility.getEncodedString(coHeaderid),BPUtility.getEncodedString(customerId));
        
        List<Service_Order_Line_Item__c> soliList = [select Id from Service_Order_Line_Item__c];
        
        CustomerOrderCtrl.moveLineItem(BPUtility.getEncodedString('[object object]'),BPUtility.getEncodedString(soliList[0].id),BPUtility.getEncodedString(soHeaderDetailsObj3.SOList[1].SOHeaderInfo.id),BPUtility.getEncodedString(coHeaderid));
        
        List<Technician_Hour__c> technicalHoursLoggedList = new List<Technician_Hour__c>();
        technicalHoursLoggedList = [Select Total_Hours__c from Technician_Hour__c];
        
        System.assertEquals(technicalHoursLoggedList[0].Total_Hours__c,4.00);
        System.assertEquals(technicalHoursLoggedList[1].Total_Hours__c,6.00);
    } */
    
        static testMethod void changeCustomerTest() {
            
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Claims_for_Service_Work__c = true;
        insert vendor;
        
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        
        Part__c part = TestUtil.createPart(true, 'part', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.Id, null);
        
        //Tax_Exemption__c taxExemption = Testutil.createTaxExemption(true, customer.Id, salestaxItem.Id);
        
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 1);
        
        String coDetailsJSON1 = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        COHeaderWrapper coDetails1 = (COHeaderWrapper) System.JSON.deserialize(coDetailsJSON1, COHeaderWrapper.class);
        System.assertEquals( coDetails1.allCOLineItemRecs[0].price, 55);
        
        Price_Level__c defaultPriceLevel1 = TestUtil.createPriceLevel(true, 'Default Price Level12', 'MSRP', 20 , true, true);
        Account customer1 =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel1.Id, null);
        
        Test.startTest();
        String coLineItems = BPUtility.getDecodedString(CustomerOrderCtrl.addCustomer(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer1.Id)));
        Test.stopTest();
        
        String coDetailsJSON2 = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        COHeaderWrapper coDetails2 = (COHeaderWrapper) System.JSON.deserialize(coDetailsJSON2, COHeaderWrapper.class);
        System.assertEquals( coDetails2.allCOLineItemRecs[0].price, 60);
        
    }
    
    static testMethod void saveOptionFeesLineItemTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
            
        TestUtil.createtaxsettingInGeneralConfigA();
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id);
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        Test.startTest();
        BPUtility.getDecodedString(CustomerOrderCtrl.saveTemporaryUnit(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItemJsonToSave)));
        
        List<Deal_Item__c> dealItems = [Select Id from Deal_Item__c]; 
        String optionAndFeeToSaveJson = '';
        Option_Fee__c optionAndFeeRec = new Option_Fee__c();
        optionAndFeeRec.Deal_Item__c = dealItems[0].Id;
        optionAndFeeRec.Qty__c = 2;
        optionAndFeeRec.Part__c = testPart.Id;
        DealWrapper.OptionAndFeeInfo optionAndFeeObj = new DealWrapper.OptionAndFeeInfo(optionAndFeeRec);

        BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItems[0].Id),BPUtility.getEncodedString(JSON.serialize(optionAndFeeObj))));
        List<Option_Fee__c> optionAndFeeList = [Select Deal__c, Part__c from Option_Fee__c];
        
        System.assertEquals(1, optionAndFeeList.size());
        System.assertEquals(dealList[0].Id, optionAndFeeList[0].Deal__c);
        System.assertEquals(testPart.Id, optionAndFeeList[0].Part__c);
        
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', true, 10, 'LabourCodeName', 10, true);
        
        optionAndFeeObj.Id = optionAndFeeList[0].Id;
        optionAndFeeObj.PartId = null;
        optionAndFeeObj.LabourId = labourCode.Id;
        BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItems[0].Id),BPUtility.getEncodedString(JSON.serialize(optionAndFeeObj))));
        
        optionAndFeeList = [Select Labour_Code__c from Option_Fee__c];
        System.assertEquals(1, optionAndFeeList.size());
        System.assertEquals(labourCode.Id, optionAndFeeList[0].Labour_Code__c);
    }
    
    static testMethod void removeOptionFeesLineItemTest() {
        TestUtil.createtaxsettingInGeneralConfigA();
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];   
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        Test.startTest();
        BPUtility.getDecodedString(CustomerOrderCtrl.saveTemporaryUnit(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItemJsonToSave)));
        
        List<Deal_Item__c> dealItems = [Select Id from Deal_Item__c]; 
        String optionAndFeeToSaveJson = ''; 
        Option_Fee__c optionAndFeeRec = new Option_Fee__c();
        optionAndFeeRec.Deal_Item__c = dealItems[0].Id;
        optionAndFeeRec.Qty__c = 2;
        optionAndFeeRec.Is_Install__c = false;
        optionAndFeeRec.Fee__c = fee.Id;
        DealWrapper.OptionAndFeeInfo optionAndFeeObj = new DealWrapper.OptionAndFeeInfo(optionAndFeeRec);
        Test.stopTest();
        
        BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItems[0].Id),BPUtility.getEncodedString(JSON.serialize(optionAndFeeObj))));
        
        List<Option_Fee__c> optionAndFeeList = [Select Fee__c from Option_Fee__c];
        system.assertEquals(1, optionAndFeeList.size());
        
        BPUtility.getDecodedString(CustomerOrderCtrl.removeOptionFeesLineItem(BPUtility.getEncodedString(dealItems[0].Id), BPUtility.getEncodedString(optionAndFeeList[0].Id)));
        optionAndFeeList = [Select Fee__c from Option_Fee__c];
        system.assertEquals(0, optionAndFeeList.size());
    }         
    
    static testMethod void updateTradeInTest() {
        TestUtil.createtaxsettingInGeneralConfigA();
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];   
        Deal_Item__c dealItemRec = new Deal_Item__c(Agreed_Value__c = 2000, Appraisal_Method__c = 'Visual', Appraisal_Notes__c = 'Test Trade In', Appraisal_Status__c = 'Pending Appraisal'); 
        DealItem dealItemObj = new DealItem(dealItemRec);
        Test.startTest();
        String tradeInJSON = BPUtility.getDecodedString(CustomerOrderCtrl.updateTradeIn(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealItemObj))));
        dealItemObj = DealItem.parse(tradeInJSON);
        Test.stopTest();
        
        system.assertEquals(Constants.DEAL_ITEM_TYPE_TRADE_IN, dealItemObj.Type);
    }      
    
     static testMethod void savePartAndLaborAsOptionFeesLineItemTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
            
        TestUtil.createtaxsettingInGeneralConfigA();
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id);
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        Test.startTest();
        BPUtility.getDecodedString(CustomerOrderCtrl.saveTemporaryUnit(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItemJsonToSave)));
        
        List<Deal_Item__c> dealItems = [Select Id from Deal_Item__c]; 
        String optionAndFeeToSaveJson = '';
        Option_Fee__c optionAndFeeRec = new Option_Fee__c();
        optionAndFeeRec.Deal_Item__c = dealItems[0].Id;
        optionAndFeeRec.Qty__c = 2;
        optionAndFeeRec.Part__c = testPart.Id;
        DealWrapper.OptionAndFeeInfo optionAndFeeObj = new DealWrapper.OptionAndFeeInfo(optionAndFeeRec);

        String optionsAndFee  = CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItems[0].Id),BPUtility.getEncodedString(JSON.serialize(optionAndFeeObj)));
        DealWrapper.UnitSectionWrapper optionAndFeeInfoObjRec  = (DealWrapper.UnitSectionWrapper) System.JSON.deserialize(BPUtility.getDecodedString(optionsAndFee), DealWrapper.UnitSectionWrapper.class);
        //system.assert(false, optionAndFeeInfoObjRec);
        
        system.assertEquals(optionAndFeeInfoObjRec.OptionAndFeeList[0].Price, 33);
        system.assertEquals(optionAndFeeInfoObjRec.OptionAndFeeList[0].Total, 66);
        
        List<Option_Fee__c> optionAndFeeList = [Select Deal__c, Part__c from Option_Fee__c];
        
        System.assertEquals(1, optionAndFeeList.size());
        System.assertEquals(dealList[0].Id, optionAndFeeList[0].Deal__c);
        System.assertEquals(testPart.Id, optionAndFeeList[0].Part__c);
        
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', true, 10, 'LabourCodeName', 10, true);
        
        List<Deal_Item__c> dealItems1 = [Select Id from Deal_Item__c]; 
        String optionAndFeeToSaveJson1 = '';
        Option_Fee__c optionAndFeeRec1 = new Option_Fee__c();
        optionAndFeeRec1.Deal_Item__c = dealItems1[0].Id;
        optionAndFeeRec1.Qty__c = 2;
        //optionAndFeeRec.Part__c = null;
        optionAndFeeRec1.Labour_Code__c= labourCode.Id;
        DealWrapper.OptionAndFeeInfo optionAndFeeObj1 = new DealWrapper.OptionAndFeeInfo(optionAndFeeRec1);
        
        String optionsAndFee1  = CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItems1[0].Id),BPUtility.getEncodedString(JSON.serialize(optionAndFeeObj1)));
        DealWrapper.UnitSectionWrapper optionAndFeeInfoObjRec1  = (DealWrapper.UnitSectionWrapper) System.JSON.deserialize(BPUtility.getDecodedString(optionsAndFee1), DealWrapper.UnitSectionWrapper.class);
        //system.assert(false, optionAndFeeInfoObjRec1);
        system.assertEquals(optionAndFeeInfoObjRec1.TotalOptionAndFee, 166);

    }
    
    static testMethod void QuickCashSaleWorkflowActionTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 20);
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        
        String addFee = CustomerOrderCtrl.insertFeeInQuickCashSale(BPUtility.getEncodedString(fee.Id), BPUtility.getEncodedString(coHeader.Id));
        
        String coDetailsJSON1 = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(BPUtility.getEncodedString(coHeader.Id)));
        COHeaderWrapper coDetails1 = (COHeaderWrapper) System.JSON.deserialize(coDetailsJSON1, COHeaderWrapper.class);
       // system.assert(false, coDetails1 );
        System.JSON.serialize(coDetails1.allCOLineItemRecs);
        String saveLineItems = CustomerOrderCtrl.saveLineItemInQuickCashSale(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(coDetails1.allCOLineItemRecs)));
        
        
        list<CO_Invoice_Header__c> coInvoiceHeaderlist = [select  Status__c, Total_Payment__c from CO_Invoice_Header__c];
        //system.assert(false, coInvoiceHeaderlist );
       
         List<CO_Invoice_Item__c> COInvoiceItems = [select Category__c, CO_Line_Item__c, isActive__c, Item_Category_Code__c, Item_ID__c, Item_Type__c, Price__c, Qty__c from CO_Invoice_Item__c];
        //system.assert(false, COInvoiceItems );
        
        Test.startTest();
        String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaderlist[0].Id)));
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.finalizeQuickSale(BPUtility.getEncodedString(COInvoiceItemJSON), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('Customer')));
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(closedOrder, COHeaderWrapper.class);
        Test.stopTest();
        
       
        //system.assert(false, coHeaderDetails1);
        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].NumberOfItems, 2);
        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].Total, 1200);
        system.assertEquals(coHeaderDetails1.coHeaderRec.OrderStatus, 'Closed');
        
        List<Part__c> parts = [select AvailableParts__c from Part__c where Id = :part.id ];
        system.assertEquals(parts[0].AvailableParts__c, 80);
        
        }
        
        static testMethod void addKitHavingfeeTest() {
            
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<PaginationSorting.SortAttrs>{new PaginationSorting.SortAttrs('Item', 'ASC')};
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
       // Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        //Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, LabourCode.Id, Part.Id, 1, 5.0);
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, true, unitMake.Id, unitModel.Id);
        //Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, LabourCode.Id, Part.Id, 1, 5.0);
        String kitHeaderLineItem = BPUtility.getDecodedString(ViewKitCtrl.insertKitLineItem(BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(fee.Id), BPUtility.getEncodedString('{"ChangesCount":6,"CurrentPage":1,"PageSize":10,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}'), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String kitHeaderDetails = BPUtility.getDecodedString(ViewKitCtrl.getKitDetails(BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString('lineitems'), null, BPUtility.getEncodedString('{"ChangesCount":6,"CurrentPage":1,"PageSize":10,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}'), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        ViewKitCtrl.KitHeaderWrapper kitDetails = (ViewKitCtrl.KitHeaderWrapper) System.JSON.deserialize(kitHeaderDetails, ViewKitCtrl.KitHeaderWrapper.class);
        
       
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        Test.startTest();
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj1);
        Test.stopTest();
        system.assertEquals(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].IsPart, false);
        system.assertEquals(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].IsLabour, false);
        system.assertEquals(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].IsFee, true);
    }
    
    
    static testMethod void createUnresolvedFulfillmentForNewAddInMerchTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        Part__c testPart2 = TestUtil.createPart(true, 'Part12', vendor.Id, 'Test Part2', testCategory.Id);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        //Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        //DealItem dealItemObj = new DealItem(dealItemRec);
        //dealItemObj.Model = unitmodel.Id;
        
        //String dealItemObjJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveTemporaryUnit(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealItemObj))));
        //DealWrapper dealObj = DealWrapper.parse(dealItemObjJSON);
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        //q-71
        Test.startTest();
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 2;
        optionAndFeeRec1.PartId = testPart1.Id;
        optionAndFeeRec1.IsInstall = false; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        
        system.assertEquals(1, DealFulfillmentSectionObj.DealMerchandiseList.size());
        CO_Line_Item__c coliRec = new CO_Line_Item__c(Part__c = testPart2.Id, Qty__c = 10, Price__c = 100);
        COLineItem coli = new COLineItem(coliRec);
        coli.DealId = dealList[0].Id;
        coli.Price = 100;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveCOLineItem(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(new List<COLineItem>{coli}))));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        Test.stopTest();
        system.assertEquals(1, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        system.assertEquals(testPart2.Id, dealWrapperObj.DealUnresolvedFulfillmentList[0].partId);
        system.assertEquals('Add to Deal', dealWrapperObj.DealUnresolvedFulfillmentList[0].ActionRequired);
    }
    
     static testMethod void createUnresolvedFulfillmentForUpdateInMerchTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        Part__c testPart2 = TestUtil.createPart(true, 'Part12', vendor.Id, 'Test Part2', testCategory.Id);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        //Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        //DealItem dealItemObj = new DealItem(dealItemRec);
        //dealItemObj.Model = unitmodel.Id;
        Test.startTest();
        //String dealItemObjJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveTemporaryUnit(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealItemObj))));
        //DealWrapper dealObj = DealWrapper.parse(dealItemObjJSON);
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 2;
        optionAndFeeRec1.PartId = testPart1.Id;
        optionAndFeeRec1.IsInstall = false; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);

        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        
        system.assertEquals(1, DealFulfillmentSectionObj.DealMerchandiseList.size());
        system.assertEquals(2, DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList[0].Qty);
        DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList[0].Qty = 4;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveCOLineItem(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(DealFulfillmentSectionObj.DealMerchandiseList))));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        Test.stopTest();
        //system.assertEquals(1, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        //system.assertEquals(testPart1.Id, dealWrapperObj.DealUnresolvedFulfillmentList[0].partId);
        //system.assertEquals(4, dealWrapperObj.DealUnresolvedFulfillmentList[0].UpdatedQty);
       // system.assertEquals('Update Deal', dealWrapperObj.DealUnresolvedFulfillmentList[0].ActionRequired);
    } 
    
    static testMethod void createUnresolvedFulfillmentForRemoveInMerchTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        Part__c testPart2 = TestUtil.createPart(true, 'Part12', vendor.Id, 'Test Part2', testCategory.Id);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        Test.startTest();
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 2;
        optionAndFeeRec1.PartId = testPart1.Id;
        optionAndFeeRec1.IsInstall = false; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        
        BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        
        system.assertEquals(1, DealFulfillmentSectionObj.DealMerchandiseList.size());
        system.assertEquals(2, DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList[0].Qty);
        Test.stopTest();
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.removeLineItemsInMerchGrid(BPUtility.getEncodedString(DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList[0].CoLineItemId), BPUtility.getEncodedString(coHeader.Id)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        
        system.assertEquals(1, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        system.assertEquals(testPart1.Id, dealWrapperObj.DealUnresolvedFulfillmentList[0].partId);
        system.assertEquals('Remove from Deal', dealWrapperObj.DealUnresolvedFulfillmentList[0].ActionRequired);
    } 
    
   static testMethod void updateDealFinanceDetailsTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        Part__c testPart2 = TestUtil.createPart(true, 'Part12', vendor.Id, 'Test Part2', testCategory.Id);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        Test.startTest();
        dealList[0].Type__c = 'Financed';
        update dealList;
        
        DealWrapper.DealFinanceWrapper dealFinanceWrapperObj = new DealWrapper.DealFinanceWrapper(new Deal_Finance__c());
        dealFinanceWrapperObj.DownPayment = 100;
        String dealFinanceJSON = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealFinanceDetails(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealFinanceWrapperObj))));
        DealWrapper.DealFinanceWrapper DealFinanceObj = (DealWrapper.DealFinanceWrapper) System.JSON.deserialize(dealFinanceJSON, DealWrapper.DealFinanceWrapper.class);
        system.assertEquals(100, DealFinanceObj.DownPayment);
        system.assertEquals('Quotation', DealFinanceObj.Status);
    }
    
   static testMethod void closedorderActionForDealCheckoutTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        Test.startTest();  
        closedorderActionForDealCheckoutTestAsyncHandling(coHeader.Id, customerOwnedUnit.Id,testPart1.Id);
        Test.stopTest();
    }
    
    @future
    private static void closedorderActionForDealCheckoutTestAsyncHandling(String coHeaderId, String customerOwnedUnitId, String testPart1Id) {
        Deal__c dealRec = new Deal__c(CO_Header__c = coHeaderId, Status__c = Constants.QUOTATION, Type__c = Constants.CASH_DEAL, Unit_Status__c = Constants.TEMPORARY);
        insert dealRec;
        List<Deal__c> dealList = new List<Deal__c>{dealRec};
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnitId),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 2;
        optionAndFeeRec1.PartId = testPart1Id;
        optionAndFeeRec1.IsInstall = false; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeaderId)));
        
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        List<CO_Invoice_Item__c> COInvoiceItems = [select CO_Line_Item__c, Deal__c from CO_Invoice_Item__c];
        
        List<CO_Invoice_Header__c> coInvoiceHeaderlist = [select  Status__c, Total_Payment__c from CO_Invoice_Header__c where Status__c = 'Active'];
        
        String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaderlist[0].Id)));
        List<COInvoiceItem> coInvoiceItemList = (List<COInvoiceItem>) System.JSON.deserialize(COInvoiceItemJSON, List<COInvoiceItem>.class);
        //Test.startTest();
        List<String> invIdList = new List<String>{DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList[0].CoLineItemId};
        CustomerOrderCtrl_V2.finalizeInvoice(BPUtility.getEncodedString(System.JSON.serialize(invIdList)), BPUtility.getEncodedString(coHeaderId));
       //system.assert(false,  [select (Select id from CO_Invoice_Items__r), Status__c, Total_Payment__c from CO_Invoice_Header__c Order By CreatedDate ASC][0].CO_Invoice_Items__r);
        String closedInvoice = BPUtility.getDecodedString(COService.getCOHeaderDetailsByGridName(coHeaderId, null));    
        coInvoiceHeaderlist = [select  Status__c, Total_Payment__c from CO_Invoice_Header__c where Status__c = 'Active'];
        COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaderlist[0].Id)));
        coInvoiceItemList = (List<COInvoiceItem>) System.JSON.deserialize(COInvoiceItemJSON, List<COInvoiceItem>.class);
        for(COInvoiceItem coInvoiceItemObj : coInvoiceItemList) {
            if(String.isNotBlank(coInvoiceItemObj.DealId)) {
                coInvoiceItemObj.isActive = true;
            }
        }
        
        List <Deal__C> dealList1 = [Select Status__c from Deal__c where Id = :dealList[0].Id];
        system.assertEquals('Fulfilled', dealList1[0].Status__c);
        
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedInvoiceAction(BPUtility.getEncodedString(System.JSON.serialize(coInvoiceItemList)), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('Customer')));
        
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(closedOrder, COHeaderWrapper.class);
        //Test.stopTest();
        dealList = [Select Status__c from Deal__c where Id = :dealList[0].Id];
        system.assertEquals('Invoiced', dealList[0].Status__c);
        List<Customer_Owned_Unit__c> unitList = [Select Status__c from Customer_Owned_Unit__c where Id = :customerOwnedUnitId];
        
        system.assertEquals('Sold', unitList[0].Status__c);
    }
    
    static testMethod void resolvedFulfillmentForNewAddInMerchTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
        
        insert new List<SObject>{customer, vendor, testCategory};
        Part__c testPart1 = TestUtil.createPart(false, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        Part__c testPart2 = TestUtil.createPart(false, 'Part12', vendor.Id, 'Test Part2', testCategory.Id);
        insert new List<SObject>{testPart1, testPart2};
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        Test.startTest();
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 2;
        optionAndFeeRec1.PartId = testPart1.Id;
        optionAndFeeRec1.IsInstall = false; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        Test.stopTest();
        /*system.assertEquals(1, DealFulfillmentSectionObj.DealMerchandiseList.size()); 
        CO_Line_Item__c coliRec = new CO_Line_Item__c(Part__c = testPart2.Id, Qty__c = 10, Price__c = 100);
        COLineItem coli = new COLineItem(coliRec);
        coli.DealId = dealList[0].Id;
        coli.Price = 100;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveCOLineItem(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(new List<COLineItem>{coli}))));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        
        system.assertEquals(1, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        system.assertEquals(testPart2.Id, dealWrapperObj.DealUnresolvedFulfillmentList[0].partId);
        system.assertEquals('Add to Deal', dealWrapperObj.DealUnresolvedFulfillmentList[0].ActionRequired);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.resolveFulfillment(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealWrapperObj.DealUnresolvedFulfillmentList[0])),BPUtility.getEncodedString('Do Not Invoice'), BPUtility.getEncodedString(customerOwnedUnit.Id)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        
        system.assertEquals(0, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        system.assertEquals(2, dealWrapperObj.UnitList[0].OptionAndFeeList.size());*/
    }
    
    static testMethod void resolvedFulfillmentForUpdateInMerchTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        Test.startTest();
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 1;
        optionAndFeeRec1.PartId = testPart1.Id;
        optionAndFeeRec1.IsInstall = false; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0; 
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);

        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        
        system.assertEquals(1, DealFulfillmentSectionObj.DealMerchandiseList.size()); 
        system.assertEquals(1, DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList[0].Qty); 
        DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList[0].Qty = 4;
        Test.stopTest();
        String coliList = System.JSON.serialize(DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList);
        resolvedFulfillmentForUpdateInMerchTest_future(coHeader.Id, coliList, dealList[0].Id, customerOwnedUnit.Id);
    }
    
    
    @future
    static void resolvedFulfillmentForUpdateInMerchTest_future(String coHeaderId, String coliList, String dealId, String couId) {   
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveCOLineItem(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(coliList)));
        DealWrapper dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        system.assertEquals(1, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        system.assertEquals(4, dealWrapperObj.DealUnresolvedFulfillmentList[0].UpdatedQty);
        system.assertEquals('Update Deal', dealWrapperObj.DealUnresolvedFulfillmentList[0].ActionRequired);
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.resolveFulfillment(BPUtility.getEncodedString(dealId),BPUtility.getEncodedString(System.JSON.serialize(dealWrapperObj.DealUnresolvedFulfillmentList[0])),BPUtility.getEncodedString('Invoice'), BPUtility.getEncodedString(couId)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        system.assertEquals(0, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        system.assertEquals(1, dealWrapperObj.UnitList[0].DealKitHeaderList[0].OptionAndFeeList.size());
    }
    
    static testMethod void resolveFulfillmentForRemoveInMerchTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(false, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        Part__c testPart2 = TestUtil.createPart(false, 'Part12', vendor.Id, 'Test Part2', testCategory.Id);
        
        insert new List<Part__c>{testPart1, testPart2};
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        //Test.startTest();
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 2;
        optionAndFeeRec1.PartId = testPart1.Id;
        optionAndFeeRec1.IsInstall = false; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        
        Test.startTest();
        BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        
        resolveFulfillmentForRemoveInMerchTest_future(coHeader.Id, DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList[0].CoLineItemId, dealList[0].Id, customerOwnedUnit.Id);
    }
    
    @future
    static void resolveFulfillmentForRemoveInMerchTest_future(String coHeaderId, String coliId, String dealId, String couId) {
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.removeLineItemsInMerchGrid(BPUtility.getEncodedString(coliId), BPUtility.getEncodedString(coHeaderId)));
        
        DealWrapper dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        
        system.assertEquals(1, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.resolveFulfillment(BPUtility.getEncodedString(dealId),BPUtility.getEncodedString(System.JSON.serialize(dealWrapperObj.DealUnresolvedFulfillmentList[0])),BPUtility.getEncodedString(null), BPUtility.getEncodedString(couId)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        
        system.assertEquals(0, dealWrapperObj.DealUnresolvedFulfillmentList.size());
    }
    
    //Added by nidhi
    static testMethod void updateDealFinanceStatusTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Finance_Company__c = true;
        insert vendor;
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);
        
        Test.startTest();
        dealList[0].Type__c = 'Financed';
        update dealList;
        
        DealWrapper.DealFinanceWrapper dealFinanceWrapperObj = new DealWrapper.DealFinanceWrapper(new Deal_Finance__c());
        dealFinanceWrapperObj.FinanceCompanyId = vendor.Id;
        dealFinanceWrapperObj.DownPayment = 100;
        dealFinanceWrapperObj.DealId = dealList[0].Id;
        String dealFinanceJSON = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealFinanceDetails(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealFinanceWrapperObj))));
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        
        dealFinanceJSON = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealFinanceStatus(BPUtility.getEncodedString(coHeader.Id),BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealFinanceJSON), BPUtility.getEncodedString('Submitted')));
        List<Deal_Finance__c> dealFinanceList = [Select Id, Status__c from Deal_Finance__c where Deal__c = :dealList[0].Id];
        system.assertEquals('Submitted', dealFinanceList[0].Status__c);
    }
    //Added by nidhi
    static testMethod void removeFAndIProductLineItemTest() {
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Finance_Company__c = true;
        insert vendor;
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        
        Product__c testProduct1 = TestUtil.createProduct(false, testCategory.Id, 'Test Product2', vendor.Id);
        testProduct1.Type__c = 'Financing Product';
        insert testProduct1;
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);

        Test.startTest();
        dealList[0].Type__c = 'Financed';
        update dealList;
        
        DealWrapper.DealFinanceWrapper dealFinanceWrapperObj = new DealWrapper.DealFinanceWrapper(new Deal_Finance__c());
        dealFinanceWrapperObj.FinanceCompanyId = vendor.Id;
        dealFinanceWrapperObj.DownPayment = 100;
        String dealFinanceJSON = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealFinanceDetails(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealFinanceWrapperObj))));
        
        DealWrapper.FIProductWrapper fAndIproductObj = new DealWrapper.FIProductWrapper(new F_I_Product__c());
        fAndIproductObj.ProductId = testProduct1.Id;
        fAndIproductObj.DealId = dealList[0].Id;
        fAndIproductObj.DealFinanceId = [Select Id from Deal_Finance__c limit 1].Id;
        
        String fAndIproductJson = BPUtility.getDecodedString(CustomerOrderCtrl.saveDealFAndIProduct(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(fAndIproductObj))));
        DealWrapper.FIProductWrapper DealFAndIProductObj = (DealWrapper.FIProductWrapper) System.JSON.deserialize(fAndIproductJson, DealWrapper.FIProductWrapper.class);
        system.assertEquals(testProduct1.Id, DealFAndIProductObj.ProductId);
        
        fAndIproductJson = BPUtility.getDecodedString(CustomerOrderCtrl.removeFAndIProductLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(DealFAndIProductObj.Id)));
        List<F_I_Product__c> fAndIProductList = [Select Id from F_I_Product__c where Deal__c = :dealList[0].Id];
        system.assertEquals(0, fAndIProductList.size());
    }
    // START: by kv 12/15/2016  
    static testMethod void createUnresolvedFulfillmentForUpdateInServiceOrderTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', true, 10, 'LabourCodeName', 10, true);
        
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        
        Test.startTest();
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 2;
        optionAndFeeRec1.LabourId = labourCode.Id;
        optionAndFeeRec1.IsInstall = true;
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        List<Service_Order_Header__c> soList = [Select Id, (Select Id, Labour_Code__c, Qty_Needed__c, Kit_Price__c from Service_Order_Line_Items__r) from Service_Order_Header__c where CO_Header__c = :coHeader.Id];
        system.assertEquals(1, soList.size());
        system.assertEquals(1, soList[0].Service_Order_Line_Items__r.size());
        system.assertEquals(10, soList[0].Service_Order_Line_Items__r[0].Qty_Needed__c);
        
        soList[0].Service_Order_Line_Items__r[0].Qty_Needed__c = 4;
        soList[0].Service_Order_Line_Items__r[0].Deal__c = dealWrapperObj.DealInfo.Id;
        soList[0].Service_Order_Line_Items__r[0].Deal_Item__c = dealWrapperObj.UnitList[0].DealItemObj.Id;
        
        SOHeaderWrapper.SOLineItem soliObj = new SOHeaderWrapper.SOLineItem(soList[0].Service_Order_Line_Items__r[0]);
        Test.stopTest();
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soliObj)), BPUtility.getEncodedString(coHeader.Id)));
        List<DealWrapper.DealUnresolvedFulfillmentWrapper> unresolvedFulfillmentList = (List<DealWrapper.DealUnresolvedFulfillmentWrapper>) System.JSON.deserialize(dealWrapperJSON, List<DealWrapper.DealUnresolvedFulfillmentWrapper>.class);
        
        system.assertEquals(1,unresolvedFulfillmentList.size());
        system.assertEquals(labourCode.Id,unresolvedFulfillmentList[0].LabourId);
        system.assertEquals(4,unresolvedFulfillmentList[0].UpdatedQty);
        system.assertEquals('Update Deal',unresolvedFulfillmentList[0].ActionRequired);
    }
    // END: by kv 12/15/2016
    
    
        static testMethod void TaxCalculationForFAndIProductLineItemTest() {
        
        TestUtil.createtaxsettingInGeneralConfig();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Finance_Company__c = true;
        insert vendor;
        //Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        
        Product__c testProduct1 = TestUtil.createProduct(false, testCategory.Id, 'Test Product2', vendor.Id);
        testProduct1.Type__c = 'Financing Product';
        testProduct1.Taxable__c = true ;
        testProduct1.Applicable_Tax__c = salestax.Id;
        testProduct1.Cost__c = 100;
        testProduct1.Price__c = 100;
        insert testProduct1;
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);

        Test.startTest();
        dealList[0].Type__c = 'Financed';
        update dealList;
        
        DealWrapper.DealFinanceWrapper dealFinanceWrapperObj = new DealWrapper.DealFinanceWrapper(new Deal_Finance__c());
        dealFinanceWrapperObj.FinanceCompanyId = vendor.Id;
        dealFinanceWrapperObj.DownPayment = 100;
        String dealFinanceJSON = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealFinanceDetails(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealFinanceWrapperObj))));
        
        DealWrapper.FIProductWrapper fAndIproductObj = new DealWrapper.FIProductWrapper(new F_I_Product__c());
        fAndIproductObj.ProductId = testProduct1.Id;
        fAndIproductObj.DealId = dealList[0].Id;
        fAndIproductObj.DealFinanceId = [Select Id from Deal_Finance__c limit 1].Id;
        
        String fAndIproductJson = BPUtility.getDecodedString(CustomerOrderCtrl.saveDealFAndIProduct(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(fAndIproductObj))));
        DealWrapper.FIProductWrapper DealFAndIProductObj = (DealWrapper.FIProductWrapper) System.JSON.deserialize(fAndIproductJson, DealWrapper.FIProductWrapper.class);
        system.assertEquals(DealFAndIProductObj.SalesTax, 7.41);
        system.assertEquals(DealFAndIProductObj.Total, 92.59);
        system.assertEquals(testProduct1.Id, DealFAndIProductObj.ProductId);
    }
    
     static testMethod void TaxCalculationForFAndIProductLineItemTestA() {
        
        TestUtil.createtaxsettingInGeneralConfigA();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Finance_Company__c = true;
        insert vendor;
        //Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        
        Product__c testProduct1 = TestUtil.createProduct(false, testCategory.Id, 'Test Product2', vendor.Id);
        testProduct1.Type__c = 'Financing Product';
        testProduct1.Taxable__c = true ;
        testProduct1.Applicable_Tax__c = salestax.Id;
        testProduct1.Cost__c = 100;
        testProduct1.Price__c = 100;
        insert testProduct1;
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);

        Test.startTest();
        dealList[0].Type__c = 'Financed';
        update dealList;
        
        DealWrapper.DealFinanceWrapper dealFinanceWrapperObj = new DealWrapper.DealFinanceWrapper(new Deal_Finance__c());
        dealFinanceWrapperObj.FinanceCompanyId = vendor.Id;
        dealFinanceWrapperObj.DownPayment = 100;
        String dealFinanceJSON = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealFinanceDetails(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealFinanceWrapperObj))));
        
        DealWrapper.FIProductWrapper fAndIproductObj = new DealWrapper.FIProductWrapper(new F_I_Product__c());
        fAndIproductObj.ProductId = testProduct1.Id;
        fAndIproductObj.DealId = dealList[0].Id;
        fAndIproductObj.DealFinanceId = [Select Id from Deal_Finance__c limit 1].Id;
         
        String fAndIproductJson = BPUtility.getDecodedString(CustomerOrderCtrl.saveDealFAndIProduct(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(fAndIproductObj))));
        DealWrapper.FIProductWrapper DealFAndIProductObj = (DealWrapper.FIProductWrapper) System.JSON.deserialize(fAndIproductJson, DealWrapper.FIProductWrapper.class);
        system.assertEquals(DealFAndIProductObj.SalesTax, 8);
        system.assertEquals(DealFAndIProductObj.Total, 100);
        system.assertEquals(testProduct1.Id, DealFAndIProductObj.ProductId);
    }
    
    public class VendorPaginationSorting {
        public Integer ChangesCount;
        public Integer CurrentPage;
        public Integer PageSize;
        public List<SortAttrs> Sorting;
    }
    
    public class SortAttrs {
        public String FieldName;
        public String SortDirection;
        public SortAttrs(String FieldName, String SortDirection){
            this.FieldName = FieldName;
            this.SortDirection = SortDirection;
        }
    }
}