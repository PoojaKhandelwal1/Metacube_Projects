/**
 * Author: Nidhi Shara
**/

@isTest
private class CustomerOrderCtrlTest2 {
    
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
    
    static testMethod void deleteCustomerOrderTest() {
        
        Account testCustomer = TestUtil.createCustomer(true, 'Test Customer', 'a.b@gmail.com', 'Jaipur', '987456123');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        CO_Header__c coHeader = TestUtil.createCOHeader(false, testCustomer.Id);
        coHeader.Order_Status__c = 'Open';
        insert coHeader;
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 50);
        
        String response = BPUtility.getDecodedString(CustomerOrderCtrl.deleteCustomerOrder(BPUtility.getEncodedString(coHeader.Id)));
        system.assertEquals('Error', response);
        
        String coLineItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.deleteCOLineItem(BPUtility.getEncodedString(coLineItemRec.Id), BPUtility.getEncodedString(coHeader.Id)));
        
        response = BPUtility.getDecodedString(CustomerOrderCtrl.deleteCustomerOrder(BPUtility.getEncodedString(coHeader.Id)));
        system.assertEquals('Success', response);
    }
    
    static testMethod void deleteDealTest() {
        
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
        
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :co.Id];
         Test.startTest();
        String dealItemJson = BPUtility.getDecodedString(CustomerOrderCtrl.saveTemporaryUnit(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItemJsonToSave)));
       
        dealWrapperObj = (DealWrapper)Json.deserialize(dealItemJson, DealWrapper.class);
        dealWrapperObj = (DealWrapper)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealWrapperObj.DealInfo.Id))), DealWrapper.class);
        
        Test.stopTest();
        String response = BPUtility.getDecodedString(CustomerOrderCtrl.removeDeal(BPUtility.getEncodedString(dealList[0].Id)));
        ResponseWrapper responseObj = (ResponseWrapper)Json.deserialize(response, ResponseWrapper.class);
        system.assertEquals('error', responseObj.responseStatus);
        system.assertEquals('First remove unit to remove deal', responseObj.response);
        
        //BPUtility.getDecodedString(CustomerOrderCtrl.removeUnitFromDeal(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(dealItemList[0].id)));
        
        /*response = BPUtility.getDecodedString(CustomerOrderCtrl.removeDeal(BPUtility.getEncodedString(dealList[0].Id)));
        responseObj = (ResponseWrapper)Json.deserialize(response, ResponseWrapper.class);
        system.assertEquals('Open', responseObj.response);*/
        deleteDealTest_future(dealList[0].Id);        
    }
    
    @future
    static void deleteDealTest_future(String dealId) {   
		List<Deal_Item__c> dealItemList = [Select id from Deal_Item__c where Deal__c = :dealId];
		BPUtility.getDecodedString(CustomerOrderCtrl.removeUnitFromDeal(BPUtility.getEncodedString(dealId), BPUtility.getEncodedString(dealItemList[0].id)));
		String response = BPUtility.getDecodedString(CustomerOrderCtrl.removeDeal(BPUtility.getEncodedString(dealId)));
		ResponseWrapper responseObj =(ResponseWrapper)Json.deserialize(response, ResponseWrapper.class);
        system.assertEquals('Open', responseObj.response);
    }
    
     static testMethod void setStatusAsQuoteTest() {
        
        //Created test data to check scenario
        General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
           //Price level of 10% on MSRP
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
           // Part with available qty 100 and having MSRP $50
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
            // created customer order
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        // Setting a Customer order as a quote
        
        BPUtility.getDecodedString(CustomerOrderCtrl.setCOStatusAsQuote(BPUtility.getEncodedString(coHeader.Id)));
        // Added a line item to customer order
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 90);
        List<CO_Line_Item__c> colineitemList = [select Part__c, Qty_Committed__c, Qty__c, Status__c, Sub_Total_Without_Tax__c, Sub_Total_With_Tax__c from CO_Line_Item__c limit 100];
        
        Test.startTest();
        String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(BPUtility.getEncodedString(coHeader.Id)));
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
        // Fetching part details
        List<Part__c> parts = [select AvailableParts__c, Qty_Committed__c, Qty_In_Stock__c from Part__c where Id = :part.id ];
        system.assertEquals(parts[0].AvailableParts__c, 100);
        system.assertEquals(parts[0].Qty_Committed__c, 0);
        system.assertEquals(parts[0].Qty_In_Stock__c, 100);
        // status of customer order
        List<CO_Header__c> coHeader1 = [select Status__c, Customer__c, Order_status__c from CO_Header__c];
        system.assertEquals(coHeader1[0].Status__c, 'Quote');
        Test.stopTest();
        // Activating a customer order  from status Quote 
        BPUtility.getDecodedString(CustomerOrderCtrl.activateQuoteCO(BPUtility.getEncodedString(coHeader.Id)));
        // Fetching part details
        List<Part__c> parts1 = [select AvailableParts__c, Qty_Committed__c, Qty_In_Stock__c from Part__c where Id = :part.id ];
        system.assertEquals(parts1[0].AvailableParts__c, 10);
        system.assertEquals(parts1[0].Qty_Committed__c, 90);
        system.assertEquals(parts1[0].Qty_In_Stock__c, 100);
        
        List<CO_Line_Item__c> colineitemList1 = [select Id from CO_Line_Item__c];
        // removing line item from Customer order
        BPUtility.getDecodedString(CustomerOrderCtrl.removeLineItemsInMerchGrid(BPUtility.getEncodedString(colineitemList1[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        BPUtility.getDecodedString(CustomerOrderCtrl.deleteQuoteCustomerOrder(BPUtility.getEncodedString(coHeader.Id)));
        // Fetching Customer order details
        List<CO_Header__c> coHeader2 = [select Status__c, Customer__c, Order_status__c from CO_Header__c];
        system.assertEquals(coHeader2.size(), 0);
        // Fetching part details
        List<Part__c> parts2 = [select AvailableParts__c, Qty_Committed__c, Qty_In_Stock__c from Part__c where Id = :part.id ];
        system.assertEquals(parts2[0].AvailableParts__c, 100);
        system.assertEquals(parts2[0].Qty_Committed__c, 0);
        system.assertEquals(parts2[0].Qty_In_Stock__c, 100);
     }
     
     static testMethod void setCOStatusQuoteFromSOSection(){
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
        defaultPriceLevel.Labour_Rate__c = 60 ;
        insert defaultPriceLevel;
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        //insert transactionType ;
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        coHeader.Order_Status__c = 'Open';
        insert coHeader;
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        SOHeaderWrapper soHeaderObj = (SOHeaderWrapper)Json.deserialize(soHeader,SOHeaderWrapper.class);
       
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(true, 'Quote', 'Quote');
        soHeaderDetailsObj.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        
        String jsonStr = System.Json.serialize(soHeaderDetailsObj.SOList[0].SOHeaderInfo);
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        BPUtility.getDecodedString(CustomerOrderCtrl.setCOStatusAsQuote(BPUtility.getEncodedString(coHeader.Id)));
        List<CO_Header__c> coHeader1 = [select Status__c, Customer__c, Order_status__c from CO_Header__c];
        system.assertEquals(coHeader1[0].Status__c, 'Quote');
    }
    
    static testMethod void excludeQuoteOnHomePageTest() {
        
        //Created test data to check scenario
        General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
           //Price level of 10% on MSRP
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
           // Part with available qty 100 and having MSRP $50
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
            // created customer order
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        BPUtility.getDecodedString(CustomerOrderCtrl.setCOStatusAsQuote(BPUtility.getEncodedString(coHeader.Id)));
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 90);
        
        List<CO_Line_Item__c> colineitemList = [select Part__c, Qty_Committed__c, Qty__c, Status__c, Sub_Total_Without_Tax__c, Sub_Total_With_Tax__c from CO_Line_Item__c limit 100];
        //system.assert(false, colineitemList);
        Test.startTest();
        String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(BPUtility.getEncodedString(coHeader.Id)));
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
        
        List<Part__c> parts = [select AvailableParts__c, Qty_Committed__c, Qty_In_Stock__c from Part__c where Id = :part.id ];
        //system.assert(false, parts);
        system.assertEquals(parts[0].AvailableParts__c, 100);
        system.assertEquals(parts[0].Qty_Committed__c, 0);
        system.assertEquals(parts[0].Qty_In_Stock__c, 100);
        List<CO_Header__c> coHeader1 = [select Status__c, Customer__c, Order_status__c from CO_Header__c];
        system.assertEquals(coHeader1[0].Status__c, 'Quote');
         
        List<Id> fixedSearchResults = new List<Id>{coHeader1[0].Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customer Orders'};
        filterWrapper.Include_Quotes = false;
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details1 = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        
        system.assertEquals(details1.CustomerOrderRecords.size(), 0);
        //system.assertEquals(details1[1].TotalValue, 6050);
    }

    static testMethod void searchQuoteOnHomePageTest() {
        
        //Created test data to check scenario
        General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
           //Price level of 10% on MSRP
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
           // Part with available qty 100 and having MSRP $50
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
            // created customer order
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        BPUtility.getDecodedString(CustomerOrderCtrl.setCOStatusAsQuote(BPUtility.getEncodedString(coHeader.Id)));
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 90);
        
        List<CO_Line_Item__c> colineitemList = [select Part__c, Qty_Committed__c, Qty__c, Status__c, Sub_Total_Without_Tax__c, Sub_Total_With_Tax__c from CO_Line_Item__c limit 100];
        //system.assert(false, colineitemList);
        Test.startTest();
        String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(BPUtility.getEncodedString(coHeader.Id)));
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
        
        List<Part__c> parts = [select AvailableParts__c, Qty_Committed__c, Qty_In_Stock__c from Part__c where Id = :part.id ];
        //system.assert(false, parts);
        system.assertEquals(parts[0].AvailableParts__c, 100);
        system.assertEquals(parts[0].Qty_Committed__c, 0);
        system.assertEquals(parts[0].Qty_In_Stock__c, 100);
        List<CO_Header__c> coHeader1 = [select Status__c, Customer__c, Order_status__c from CO_Header__c];
        system.assertEquals(coHeader1[0].Status__c, 'Quote');
         
        List<Id> fixedSearchResults = new List<Id>{coHeader1[0].Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customer Orders'};
        filterWrapper.Include_Quotes = true;
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details1 = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        
        system.assertEquals(details1.CustomerOrderRecords.size(), 1);
        system.assertEquals(details1.FilterLabelList[1].Value, 'Include Quotes');
     }
     
     
                       /*
    * Name: addEnvirofeeTest
     * Desc: addEnviroFeetest
     * @param: 
     * @return: 
    **/
    
        static testMethod void addEnviroFeeTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
       
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        Part__c part = TestUtil.createPart(false, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        part.Enviro_Fee__c = 100 ;
        Part.Enviro_Fee_Code__c = Fee.id ;
        Insert part ;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
       
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsList);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj1);
        system.assertEquals(soHeaderDetailsObj1.SOList[0].SOGridItems.size(), 2);
    }
}