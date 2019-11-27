/**
 * Author: Durga Singh
 * Since: march 1, 2015
 * Name: HomeSearchCtrlTest
 * Description: It includes test methods for HomeSearchCtrl page.
**/
@isTest
private class HomeSearchCtrlTest {

    @testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
        List<General_Configurations__c> config = [SELECT Id FROM General_Configurations__c LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
        System.assertNotEquals(0, config.size());
        
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
        List<User> UserList = [ Select Id from User where IsActive = true and  (Profile.Name = 'System Administrator' OR Profile.Name = 'BlackPurl')];

        List<String> usersList = new List<String>();
        for(User userRec : userList){
            usersList.add(userRec.Id);
        }
        
        UserSettingCtrl.assignUserToGroup(BPUtility.getEncodedString(System.JSON.serialize(usersList)), BPUtility.getEncodedString(userGroupList[0].Id));
        
        //TestUtil.createUserGroup();
    }
    
    static testMethod void getFilteredRecordsTest() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        List<Id> fixedSearchResults = new List<Id>{part.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customers'};
        filterWrapper.People_Name = 'Harley';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, customerdetails);
        //system.assertEquals(details.CustomerRecords[0].Name, 'Harley');
        system.assertEquals(details.CustomerRecords.size(), 1);
    }
    
     static testMethod void getFilteredRecordsforPartsTest() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c part1 = TestUtil.createPart(true, '56', vendor.Id, 'Test Part1', testCategory.Id, 10, 20, 50, 100, 100);
        
        List<Id> fixedSearchResults = new List<Id>{part.Id, part1.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Parts'};
        filterWrapper.Product_Item = '123';
        
        //filterWrapper.People_Name = 'Harley';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details);
        system.assertEquals(details.PartRecords[0].Description, 'Test Part');
        system.assertequals(details.PartRecords.size(), 1);
    }
    
    static testMethod void getFilteredRecordsforPartsTestA() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c part1 = TestUtil.createPart(true, '56', vendor.Id, 'Test Part1', testCategory.Id, 12, 13, 50, 40, 50);
        
        List<Id> fixedSearchResults = new List<Id>{part.Id, part1.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Parts'};
        filterWrapper.Product_Item = '56';
        filterWrapper.SearchText = '5';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        filterWrapper.Status = 'In Stock';
        filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        filterWrapper.Part_InStock = new HomeSearchFilterWrapper.BetweenFilter('1', '50', null);
        filterWrapper.Part_InStock = new HomeSearchFilterWrapper.BetweenFilter('2', '60', null);
        filterWrapper.Part_InStock = new HomeSearchFilterWrapper.BetweenFilter('5', '40', '100');
        filterWrapper.Part_PackagedPart = '2' ;
        filterWrapper.Part_Vendor = 'Test Vendor';
        //filterWrapper.Part_AverageCost = new HomeSearchFilterWrapper.BetweenFilter('1', '12', null);
        filterWrapper.Part_Cost = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Product_Price = new HomeSearchFilterWrapper.BetweenFilter('5', '30', '50');
        filterWrapper.Product_Category = testCategory.Id;
        filterWrapper.Product_Description = 'Test Part1';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details);
        system.assertEquals(details.PartRecords[0].Description, 'Test Part1');
        system.assertequals(details.PartRecords.size(), 1);
         System.assertEquals(true,true);
        
    }
    
    static testMethod void getFilteredRecordsforKitsTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'Average Cost', 20 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c part1 = TestUtil.createPart(true, 'TestPart1', vendor.Id, 'TestPart1', testCategory.Id, 5, 10, 25, 50, 50);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', defaultPriceLevel.Id, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        // fixed price flag for kit header is false and kit is service kit
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', null, false, true, unitMake.Id, unitModel.Id);
        // fixed price and flag both are false for both line item 
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, null, null, Part.Id, 1, null);
        KitLineItemtriggerHelper.PermitRun_BeforeInsert = true;
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, null, null, Part1.Id, 1, null);     
        KitLineItemtriggerHelper.PermitRun_BeforeInsert = true;
        Kit_Header_Line_Item__c kitHeaderLineItem2 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 10, labourCode.Id, null, 1, 10);        
        KitHeaderTriggerHelper.PermitRun_BeforeUpdate = true;
        kitHeader.Fixed_Price__c = 200;
        kitHeader.Fixed_Price_Flag__c= true;
        update kitHeader ;
        
         // fixed price flag for kit header is false and kit is service kit
        Kit_Header__c kitHeader1 = TestUtil.createKitHeader(true, true, true, 'Cause1', 'Code1', 'Concern1', 'Correction1', 'Description1', null, false, true, unitMake.Id, unitModel.Id);
        // fixed price and flag both are false for both line item 
        Kit_Header_Line_Item__c kitHeaderLineItem11 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader1.Id, null, null, Part.Id, 1, null);
        KitLineItemtriggerHelper.PermitRun_BeforeInsert = true;
        Kit_Header_Line_Item__c kitHeaderLineItem12 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader1.Id, null, null, Part1.Id, 1, null);       
        KitLineItemtriggerHelper.PermitRun_BeforeInsert = true;
        Kit_Header_Line_Item__c kitHeaderLineItem13 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader1.Id, 10, labourCode.Id, null, 1, 10);      
        
        List<Id> fixedSearchResults = new List<Id>{kitHeader.Id, kitHeader1.Id, part.Id, part1.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Kits'};
        filterWrapper.Product_Item = 'code';
        filterWrapper.SearchText = 'co';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        filterWrapper.Product_Description = 'Description';
        filterWrapper.Product_Price = new HomeSearchFilterWrapper.BetweenFilter('1', '200', null);
        filterWrapper.Kit_FixedPrice = '1' ;
        filterWrapper.Kit_ServiceKit = '1' ;
        filterWrapper.Kit_KitPrice = new HomeSearchFilterWrapper.BetweenFilter('5', '150', '250');
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details);
        system.assertEquals(details.KitRecords[0].Description, 'Code - Description'); 
        System.assertEquals(true,true);
        
    }
    
        static testMethod void getFilteredRecordsforKitsTestA() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'Average Cost', 20 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c part1 = TestUtil.createPart(true, 'TestPart1', vendor.Id, 'TestPart1', testCategory.Id, 5, 10, 25, 50, 50);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', defaultPriceLevel.Id, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        // fixed price flag for kit header is false and kit is service kit
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', null, false, true, unitMake.Id, unitModel.Id);
        // fixed price and flag both are false for both line item 
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, null, null, Part.Id, 1, null);
        KitLineItemtriggerHelper.PermitRun_BeforeInsert = true;
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, null, null, Part1.Id, 1, null);     
        KitLineItemtriggerHelper.PermitRun_BeforeInsert = true;
        Kit_Header_Line_Item__c kitHeaderLineItem2 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 10, labourCode.Id, null, 1, 10);        
        KitHeaderTriggerHelper.PermitRun_BeforeUpdate = true;
        kitHeader.Fixed_Price__c = 200;
        kitHeader.Fixed_Price_Flag__c= true;
        update kitHeader ;
        
         // fixed price flag for kit header is false and kit is service kit
        Kit_Header__c kitHeader1 = TestUtil.createKitHeader(true, true, true, 'Cause1', 'Code1', 'Concern1', 'Correction1', 'Description1', null, false, true, unitMake.Id, unitModel.Id);
        // fixed price and flag both are false for both line item 
        Kit_Header_Line_Item__c kitHeaderLineItem11 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader1.Id, null, null, Part.Id, 1, null);
        KitLineItemtriggerHelper.PermitRun_BeforeInsert = true;
        Kit_Header_Line_Item__c kitHeaderLineItem12 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader1.Id, null, null, Part1.Id, 1, null);       
        KitLineItemtriggerHelper.PermitRun_BeforeInsert = true;
        Kit_Header_Line_Item__c kitHeaderLineItem13 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader1.Id, 10, labourCode.Id, null, 1, 10);      
        
        List<Id> fixedSearchResults = new List<Id>{kitHeader.Id, kitHeader1.Id, part.Id, part1.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Kits'};
        filterWrapper.Product_Item = 'code';
        filterWrapper.SearchText = 'co';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        filterWrapper.Product_Description = 'Description';
        filterWrapper.Product_Price = new HomeSearchFilterWrapper.BetweenFilter('1', '200', null);
        //filterWrapper.Kit_FixedPrice = '2' ;
        //filterWrapper.Kit_ServiceKit = '2' ;
        filterWrapper.Kit_KitPrice = new HomeSearchFilterWrapper.BetweenFilter('5', '150', '250');
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details);
        system.assertEquals(details.KitRecords[0].Description, 'Code - Description');
         System.assertEquals(true,true);
    }
    
    static testMethod void getFilteredRecordsforFeeTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Labour');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'Fee', CoHeader.Id, 'Description', 100, True);
        Fee__c fee1 = TestUtil.createFee(True, false, testCategory.Id, 'code', CoHeader.Id, 'xyz', 100, false);
        
        List<Id> fixedSearchResults = new List<Id>{fee.Id, fee1.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Fees'};
        filterWrapper.Product_Item = 'fe';
        //filterWrapper.SearchText = 'ABC';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now().addDays(1)).format('MM/dd/yyyy')));
        filterWrapper.Product_Description = 'Description';
        filterWrapper.Product_Category = testCategory.Id;
        filterWrapper.Product_Price = new HomeSearchFilterWrapper.BetweenFilter('5', '50', '150');
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        
        system.assertEquals(details.FeeRecords[0].Description, 'Fee - Description');
    }
    
        static testMethod void getFilteredRecordsforLabourTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Labour');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'CodeName', 10, true);
        Labour_Code__c labourCode1 = TestUtil.createLabourCode(true, true, testCategory.Id, 'labour', coHeader.Id, 'details', True, 10, 'LabourName', 10, true);
        List<Id> fixedSearchResults = new List<Id>{labourCode.Id, labourCode1.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Labor Codes'};
        filterWrapper.Product_Item = 'labour';
        filterWrapper.SearchText = 'lab';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        filterWrapper.Product_Description = 'details';
        filterWrapper.Product_Category = testCategory.Id;
        filterWrapper.Product_Price = new HomeSearchFilterWrapper.BetweenFilter('5', '5', '15');
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details);
        system.assertEquals(details.LabourRecords[0].Description, 'details');
         System.assertEquals(true,true);
    }
    
        static testMethod void getFilteredRecordsforCustomerOrdersTest() {
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 2;
        insert part;
        
        COLineItemTriggerHelper.isTotalCalculated = false;
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 50);
        
        
        Account customer1 =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.Id, null, false, true,'Individual');
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, customer1.Id);
        Part__c part1 = TestUtil.createPart(false, 'partNumberP02', vendor.Id, 'Test Part12', testCategory.Id, 10, 20, 50, 100, 100);
        part1.Packaged_Part__c = false;
        part1.Qty_On_Order__c = 0;
        part1.Order_Lots__c = 2;
        insert part1;
        COLineItemTriggerHelper.isTotalCalculated = false;
        CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(true, coHeader1.Id, part1.Id, 60);
        
        List<CO_Header__c> coHeaderList = [select Total_Deposit__c, Total_Payment__c, Total_Order_Value__c, Order_Total__c from CO_Header__c];
        
        List<Id> fixedSearchResults = new List<Id>{coHeader1.Id, coHeader.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customer Orders'};
        filterWrapper.Product_Item = 'co';
        filterWrapper.SearchText = 'co';
        //filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        //filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        //filterWrapper.Product_Description = 'details';
        filterWrapper.Customer_Sales_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '3000', '4000');
        /*filterWrapper.Customer_Sales_Balance_Due = new HomeSearchFilterWrapper.BetweenFilter('1', '0', null);
        filterWrapper.Customer_Order_Payments = new HomeSearchFilterWrapper.BetweenFilter('5', '-55', '15');
        filterWrapper.Customer_Order_Deposits = new HomeSearchFilterWrapper.BetweenFilter('5', '-5', '15');*/
        filterWrapper.Customer_Order_Payments =  new HomeSearchFilterWrapper.BetweenFilter('1', '0', 'null');
        filterWrapper.Customer_Order_Deposits =  new HomeSearchFilterWrapper.BetweenFilter('1', '0', 'null');
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
//      system.assert(false, details);
        system.assertEquals(details.CustomerOrderRecords[0].Total, 3300);
    }
    
        static testMethod void saveFilterRecordTest() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        List<Id> fixedSearchResults = new List<Id>{part.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customers'};
        filterWrapper.People_Name = 'Harley';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        
        String filterRecord = BPUtility.getDecodedString(HomeSearchCtrl.saveFilterRecord(BPUtility.getEncodedString(null), BPUtility.getEncodedString('Durga'), BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","FieldLabel":"Modified","SortDirection":"DESC","$$hashKey":"object:624"}]}'), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), false));
        //HomeSearchCtrl.FilterItem filterDetails = (HomeSearchCtrl.FilterItem) System.JSON.deserialize(filterRecord, HomeSearchCtrl.FilterItem.class);
        HomeSearchCtrl.FilterItemWrapper filterDetails = (HomeSearchCtrl.FilterItemWrapper) System.JSON.deserialize(filterRecord, HomeSearchCtrl.FilterItemWrapper.class);
        system.assertEquals(filterDetails.CurrentFilter.Name, 'Durga');
        system.assertEquals(filterDetails.CurrentFilter.Type, 'Custom');
    }
    
        static testMethod void getFilterFieldsTest() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        List<Id> fixedSearchResults = new List<Id>{part.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customers'};
        filterWrapper.People_Name = 'Harley';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        
        String filterRecord = BPUtility.getDecodedString(HomeSearchCtrl.saveFilterRecord(BPUtility.getEncodedString(null), BPUtility.getEncodedString('Durga'), BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","FieldLabel":"Modified","SortDirection":"DESC","$$hashKey":"object:624"}]}'), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), false));
        //HomeSearchCtrl.FilterItem filterDetails = (HomeSearchCtrl.FilterItem) System.JSON.deserialize(filterRecord, HomeSearchCtrl.FilterItem.class);
        HomeSearchCtrl.FilterItemWrapper filterDetails = (HomeSearchCtrl.FilterItemWrapper) System.JSON.deserialize(filterRecord, HomeSearchCtrl.FilterItemWrapper.class);
        String filterFields = BPUtility.getDecodedString(HomeSearchCtrl.getFilterFields(BPUtility.getEncodedString(filterDetails.CurrentFilter.Id)));
        HomeSearchCtrl.GenericFilterWrapper filterFieldDetails = (HomeSearchCtrl.GenericFilterWrapper) System.JSON.deserialize(filterFields, HomeSearchCtrl.GenericFilterWrapper.class);
        //system.assert(false, filterFieldDetails);
        system.assertEquals(filterFieldDetails.FilterLabel, 'Durga');
        system.assertEquals(filterDetails.CurrentFilter.Name, 'Durga');
        system.assertEquals(filterDetails.CurrentFilter.Type, 'Custom');
    }
    
        static testMethod void deleteFilterRecordTest() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        List<Id> fixedSearchResults = new List<Id>{part.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customers'};
        filterWrapper.People_Name = 'Harley';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        
        String filterRecord = BPUtility.getDecodedString(HomeSearchCtrl.saveFilterRecord(BPUtility.getEncodedString(null), BPUtility.getEncodedString('Durga'), BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","FieldLabel":"Modified","SortDirection":"DESC","$$hashKey":"object:624"}]}'), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), false));
        HomeSearchCtrl.FilterItemWrapper filterDetails = (HomeSearchCtrl.FilterItemWrapper) System.JSON.deserialize(filterRecord, HomeSearchCtrl.FilterItemWrapper.class);
        String filterFields = BPUtility.getDecodedString(HomeSearchCtrl.deleteFilterRecord(BPUtility.getEncodedString(filterDetails.CurrentFilter.Id)));
        HomeSearchCtrl.GenericFilterWrapper filterFieldDetails = (HomeSearchCtrl.GenericFilterWrapper) System.JSON.deserialize(filterFields, HomeSearchCtrl.GenericFilterWrapper.class);
        system.assertEquals(filterFieldDetails.FilterLabel, null);
    }
    
       static testMethod void CopyFilterRecordTest() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        List<Id> fixedSearchResults = new List<Id>{part.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customers'};
        filterWrapper.People_Name = 'Harley';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        
        String filterRecord = BPUtility.getDecodedString(HomeSearchCtrl.saveFilterRecord(BPUtility.getEncodedString(null), BPUtility.getEncodedString('DurgaS'), BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","FieldLabel":"Modified","SortDirection":"DESC","$$hashKey":"object:624"}]}'), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), false));
        //HomeSearchCtrl.FilterItem filterDetails = (HomeSearchCtrl.FilterItem) System.JSON.deserialize(filterRecord, HomeSearchCtrl.FilterItem.class);
        HomeSearchCtrl.FilterItemWrapper filterDetails = (HomeSearchCtrl.FilterItemWrapper) System.JSON.deserialize(filterRecord, HomeSearchCtrl.FilterItemWrapper.class);
        String filterFields = BPUtility.getDecodedString(HomeSearchCtrl.getFilterFields(BPUtility.getEncodedString(filterDetails.CurrentFilter.Id)));
        String filterFields1 = BPUtility.getDecodedString(HomeSearchCtrl.renameCopyFilterRecord(BPUtility.getEncodedString(filterDetails.CurrentFilter.Id), BPUtility.getEncodedString('DurgaSingh'), true));
        HomeSearchCtrl.GenericFilterWrapper filterFieldDetails = (HomeSearchCtrl.GenericFilterWrapper) System.JSON.deserialize(filterFields1, HomeSearchCtrl.GenericFilterWrapper.class);
        //system.assert(false, filterFields);
        List<Filter__c> filterlist = [select Filter_Label__c from Filter__c where (Filter_Label__c = 'DurgaS' OR Filter_Label__c = 'DurgaSingh') limit 2];
        //system.assert(false, filterFieldDetails);
        //system.assertEquals(filterlist[0].Filter_Label__c, 'DurgaS');
        //system.assertEquals(filterlist[1].Filter_Label__c, 'DurgaSingh');
        system.assertEquals(filterlist.size(), 2);
        
    }
    
        static testMethod void renameFilterRecordTest() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        List<Id> fixedSearchResults = new List<Id>{part.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customers'};
        filterWrapper.People_Name = 'Harley';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        
        String filterRecord = BPUtility.getDecodedString(HomeSearchCtrl.saveFilterRecord(BPUtility.getEncodedString(null), BPUtility.getEncodedString('Durga'), BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","FieldLabel":"Modified","SortDirection":"DESC","$$hashKey":"object:624"}]}'), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), false));
        //HomeSearchCtrl.FilterItem filterDetails = (HomeSearchCtrl.FilterItem) System.JSON.deserialize(filterRecord, HomeSearchCtrl.FilterItem.class);
        HomeSearchCtrl.FilterItemWrapper filterDetails = (HomeSearchCtrl.FilterItemWrapper) System.JSON.deserialize(filterRecord, HomeSearchCtrl.FilterItemWrapper.class);
        String filterFields = BPUtility.getDecodedString(HomeSearchCtrl.getFilterFields(BPUtility.getEncodedString(filterDetails.CurrentFilter.Id)));
        String filterFields1 = BPUtility.getDecodedString(HomeSearchCtrl.renameCopyFilterRecord(BPUtility.getEncodedString(filterDetails.CurrentFilter.Id), BPUtility.getEncodedString('DurgaSingh'), false));
        HomeSearchCtrl.GenericFilterWrapper filterFieldDetails = (HomeSearchCtrl.GenericFilterWrapper) System.JSON.deserialize(filterFields1, HomeSearchCtrl.GenericFilterWrapper.class);
        //system.assert(false, filterFields);
        List<Filter__c> filterlist = [select Filter_Label__c from Filter__c where Id =: filterDetails.CurrentFilter.Id limit 100];
        //system.assert(false, filterlist);
        //system.assertEquals(filterlist[0].Filter_Label__c, 'Durga');
        system.assertEquals(filterlist[0].Filter_Label__c, 'DurgaSingh');
        system.assertEquals(filterlist.size(), 1);
        
    }
    
    
        static testMethod void markFilterAsFavoriteTest() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        List<Id> fixedSearchResults = new List<Id>{part.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customers'};
        filterWrapper.People_Name = 'Harley';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        
        String filterRecord = BPUtility.getDecodedString(HomeSearchCtrl.saveFilterRecord(BPUtility.getEncodedString(null), BPUtility.getEncodedString('Durga'), BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","FieldLabel":"Modified","SortDirection":"DESC","$$hashKey":"object:624"}]}'), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), false));
        //HomeSearchCtrl.FilterItem filterDetails = (HomeSearchCtrl.FilterItem) System.JSON.deserialize(filterRecord, HomeSearchCtrl.FilterItem.class);
        HomeSearchCtrl.FilterItemWrapper filterDetails = (HomeSearchCtrl.FilterItemWrapper) System.JSON.deserialize(filterRecord, HomeSearchCtrl.FilterItemWrapper.class);
        String filterFields =  BPUtility.getDecodedString(HomeSearchCtrl.getFilterFields(BPUtility.getEncodedString(filterDetails.CurrentFilter.Id)));
        String filterFields1 =  BPUtility.getDecodedString(HomeSearchCtrl.markFilterAsFavorite(BPUtility.getEncodedString(filterDetails.CurrentFilter.Id), true));
        //HomeSearchCtrl.GenericFilterWrapper filterFieldDetails = (HomeSearchCtrl.GenericFilterWrapper) System.JSON.deserialize(filterFields1, HomeSearchCtrl.GenericFilterWrapper.class);
        
        List<Filter__c> filterlist = [select Filter_Label__c, favorite__c from Filter__c where favorite__c = true limit 100];
            //system.assert(false, filterlist);
        system.assertEquals(filterlist[0].favorite__c, true);
        
    }
    
    static testMethod void getFilterObjectTypesTest() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        List<Id> fixedSearchResults = new List<Id>{part.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customers'};
        filterWrapper.People_Name = 'Harley';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        
        String filterRecord = BPUtility.getDecodedString(HomeSearchCtrl.saveFilterRecord(BPUtility.getEncodedString(null), BPUtility.getEncodedString('Durga'), BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","FieldLabel":"Modified","SortDirection":"DESC","$$hashKey":"object:624"}]}'), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), false));
        //HomeSearchCtrl.FilterItem filterDetails = (HomeSearchCtrl.FilterItem) System.JSON.deserialize(filterRecord, HomeSearchCtrl.FilterItem.class);
        HomeSearchCtrl.FilterItemWrapper filterDetails = (HomeSearchCtrl.FilterItemWrapper) System.JSON.deserialize(filterRecord, HomeSearchCtrl.FilterItemWrapper.class);
        String filterFields = BPUtility.getDecodedString(HomeSearchCtrl.getFilterFields(BPUtility.getEncodedString(filterDetails.CurrentFilter.Id)));
        HomeSearchCtrl.GenericFilterWrapper filterFieldDetails = (HomeSearchCtrl.GenericFilterWrapper) System.JSON.deserialize(filterFields, HomeSearchCtrl.GenericFilterWrapper.class);
        
        String objectTypes = BPUtility.getDecodedString(HomeSearchCtrl.getFilterObjectTypes());
        HomeSearchCtrl.HomeSearchMasterData objectTypesDetails = (HomeSearchCtrl.HomeSearchMasterData) System.JSON.deserialize(objectTypes, HomeSearchCtrl.HomeSearchMasterData.class);
        //system.assert(false, objectTypesDetails);
        system.assertEquals(objectTypes.contains('Durga'), true);
        String configuration = BPUtility.getDecodedString(HomeSearchCtrl.getGridFilterConfigurations(BPUtility.getEncodedString('null')));
        String columnConfigurations= BPUtility.getDecodedString(HomeSearchCtrl.getGridColumnsConfiguration(BPUtility.getEncodedString('null'), BPUtility.getEncodedString(jsonStr)));
        String similarFilter = BPUtility.getDecodedString(HomeSearchCtrl.checkForSimilarFilter(BPUtility.getEncodedString(jsonStr)));
        system.assertEquals(similarFilter, 'Durga');
    }
    
            /*
     * Name: getFilterRecordsforCustomerInvoices
     * Desc: Test to check filterrecordsforcustomerinvoices.
     * @param: 
     * @return: 
    **/
     static testMethod void getFilterRecordsforCustomerInvoices() {
        
        //Created test data to check scenario
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
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
            // create PO type and vendor order
        
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        
        VendorOrderReceivingCtrl_PartialTest.getFilterRecordsforCustomerInvoices(vendor.Id,voHeader.Id,coHeader.Id); 
}


     static testMethod void getFilterRecordsforVendorOrders() {
        
        //Created test data to check scenario
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
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
            // create PO type and vendor order
        
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        
         VendorOrderReceivingCtrl_PartialTest.getFilterRecordsforVendorOrders(vendor.Id,voHeader.Id,coHeader.Id); 
}

            /*
     * Name: getFilterRecordsforVendorReceivings
     * Desc: Test to check getFilterRecordsforVendorReceivings.
     * @param: 
     * @return: 
    **/
     static testMethod void getFilterRecordsforVendorReceivings() {
        
        //Created test data to check scenario
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
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
            // create PO type and vendor order
        
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        Test.StartTest();
            //  group all required parts for vendor
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(voHeader.Id), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
            // vendor order submitted
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));

            // created vendorOrderReceive header
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vorId), true));
            // Add all lineitem for receiving
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(voLineItems.VendorOrderLineItemGroupList[0].Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
            //  receiving all parts from vendor
            Test.StopTest();
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        
       
        List<Vendor_Receiving_Header__c> vendorReceivingList = [select In_Progress_VI__c, Status__c, Vendor__c, Receiving_Total__c, Receiving_From_Invoice_Total__c from Vendor_Receiving_Header__c];
        //system.assert(false, vendorReceivingList );
        
        
        //String closedInvoiceAction = CustomerOrderCtrl.closedInvoiceAction('[{"Total":8250.000,"TaxAmount":null,"Saving":null,"RetailPrice":null,"QtyRequired":null,"Qty":null,"Price":null,"Item":"Service Job 1","IsInvoiceable":true,"IsActive":true,"COLineItemId":null,"COInvoiceItemNumber":null,"COInvoiceItemId":"'+coHeaderDetails.coInvoiceItemRecs[0].COInvoiceItemId+'","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'","$$hashKey":"object:56"}]', coHeader.Id, 'Customer');
        
        
        List<Id> fixedSearchResults = new List<Id>{vendorReceivingList[0].Id, vendorReceivingList[1].Id };
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Vendor Receivings'};
        filterWrapper.Status = 'Stocked';
        //filterWrapper.SearchText = 'co';
        //filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        //filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        //filterWrapper.Product_Description = 'details';
        //filterWrapper.Customer_Sales_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '3000', '15000');
        /*filterWrapper.Customer_Sales_Balance_Due = new HomeSearchFilterWrapper.BetweenFilter('1', '0', null);
        filterWrapper.Customer_Order_Payments = new HomeSearchFilterWrapper.BetweenFilter('5', '-55', '15');
        filterWrapper.Customer_Order_Deposits = new HomeSearchFilterWrapper.BetweenFilter('5', '-5', '15');*/
        filterWrapper.Vendor_Ordering_Vendor = 'Test Vendor';
        filterWrapper.Vendor_Ordering_Total = new HomeSearchFilterWrapper.BetweenFilter('1', '1000', null);
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details1 = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details1);
        system.assertEquals(details1.VendorRecievingRecords[0].Total, 1000);
         System.assertEquals(true,true);
}

/**
     * Name: GetFilterrecordsforVendorInvoice 
     * Desc: Test to finalize invoicing for vendor order
     * @param: 
     * @return: 
    **/    
static testMethod void GetFilterrecordsforVendorInvoice() {
        
        //System.JSON.serialize(pageSort)

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

        VendorOrderReceivingCtrl_PartialTest.GetFilterrecordsforVendorInvoice(vendor.Id, part.Id, part2.Id);
        
    }
    
	static testMethod void getFilteredRecordsforCustomers() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.id, defaultSalesTax.Id, false, true,'Individual');
        
        List<Account> customerList = [select Name, Email__c, Phone, BillingCity, Price_Level__c, Sales_Tax__c , Type__c from Account];
        //system.assert(false, customerList );
        
        List<Id> fixedSearchResults = new List<Id>{customer.Id, vendor.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customers'};
        filterWrapper.People_BillingCity = 'Jaipur';
        filterWrapper.People_Email = 'abc@abc.com';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        //filterWrapper.People_Id = customer.Id;
        filterWrapper.People_Name = 'customerName' ;
        filterWrapper.People_Phone = '1111111111' ;
        filterWrapper.People_PriceLevel = defaultPriceLevel.Id ;
        filterWrapper.People_SalesTax = defaultSalesTax.Id ;
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details1 = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details1);
        system.assertEquals(details1.CustomerRecords[0].Billing_City, 'jaipur'); 
        System.assertEquals(true,true);
        
}

static testMethod void getFilteredRecordsforpeopleGroup() {
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.id, defaultSalesTax.Id, false, true,'Individual');
        
        List<Account> customerList = [select Name, Email__c, Phone, BillingCity, Price_Level__c, Sales_Tax__c , Type__c from Account];
        //system.assert(false, customerList );
        
        List<Id> fixedSearchResults = new List<Id>{customer.Id, vendor.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'People'};
        filterWrapper.People_BillingCity = 'Jaipur';
        filterWrapper.People_Email = 'abc@abc.com';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        //filterWrapper.People_Id = customer.Id;
        filterWrapper.People_Name = 'customerName' ;
        filterWrapper.People_Phone = '1111111111' ;
        filterWrapper.People_PriceLevel = defaultPriceLevel.Id ;
        filterWrapper.People_SalesTax = defaultSalesTax.Id ;
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details1 = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details1);
        system.assertEquals(details1.PeopleRecords[0].Billing_City, 'jaipur');
         System.assertEquals(true,true);
}

static testMethod void getFilteredRecordsforPeople() {
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.id, defaultSalesTax.Id, false, true,'Individual');
        
        List<Account> customerList = [select Name, Email__c, Phone, BillingCity, Price_Level__c, Sales_Tax__c , Type__c from Account];
        //system.assert(false, customerList );
        
        List<Id> fixedSearchResults = new List<Id>{customer.Id, vendor.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'People'};
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details1 = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
         System.assertEquals(true,true);
}

static testMethod void getFilteredRecordsforVendors() {
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.id, defaultSalesTax.Id, true, false,'Individual');
        
        List<Account> customerList = [select Name, Email__c, Phone, BillingCity, Price_Level__c, Sales_Tax__c , Type__c from Account];
        //system.assert(false, customerList );
        
        List<Id> fixedSearchResults = new List<Id>{customer.Id, vendor.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Vendors'};
        filterWrapper.People_BillingCity = 'Jaipur';
        filterWrapper.People_Email = 'abc@abc.com';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        //filterWrapper.People_Id = customer.Id;
        filterWrapper.People_Name = 'customerName' ;
        filterWrapper.People_Phone = '1111111111' ;
        filterWrapper.People_PriceLevel = defaultPriceLevel.Id ;
        filterWrapper.People_SalesTax = defaultSalesTax.Id ;
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details1 = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details1);
        system.assertEquals(details1.VendorRecords[0].Billing_City, 'jaipur');
         System.assertEquals(true,true);
}

     static testMethod void getFilterRecordsforVendorOrdering() {
        
        //Created test data to check scenario
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
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
            // create PO type and vendor order
        
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        Test.StartTest();
            //  group all required parts for vendor
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(voHeader.Id), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
            // vendor order submitted
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));

            // created vendorOrderReceive header
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vorId), true));
            // Add all lineitem for receiving
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(voLineItems.VendorOrderLineItemGroupList[0].Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
            //  receiving all parts from vendor
            Test.StopTest();
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        
        
        List<Vendor_Receiving_Header__c> vendorReceivingList = [select In_Progress_VI__c, Status__c, Vendor__c, Receiving_Total__c, Receiving_From_Invoice_Total__c from Vendor_Receiving_Header__c];
        //system.assert(false, vendorReceivingList );
        
        
        //String closedInvoiceAction = CustomerOrderCtrl.closedInvoiceAction('[{"Total":8250.000,"TaxAmount":null,"Saving":null,"RetailPrice":null,"QtyRequired":null,"Qty":null,"Price":null,"Item":"Service Job 1","IsInvoiceable":true,"IsActive":true,"COLineItemId":null,"COInvoiceItemNumber":null,"COInvoiceItemId":"'+coHeaderDetails.coInvoiceItemRecs[0].COInvoiceItemId+'","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'","$$hashKey":"object:56"}]', coHeader.Id, 'Customer');
        
        
        List<Id> fixedSearchResults = new List<Id>{vendorReceivingList[0].Id, vendorReceivingList[1].Id };
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Vendor Orders', 'Vendor Receivings'};
        filterWrapper.Status = 'Stocked';
        //filterWrapper.SearchText = 'co';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        //filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        //filterWrapper.Product_Description = 'details';
        //filterWrapper.Customer_Sales_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '3000', '15000');
        /*filterWrapper.Customer_Sales_Balance_Due = new HomeSearchFilterWrapper.BetweenFilter('1', '0', null);
        filterWrapper.Customer_Order_Payments = new HomeSearchFilterWrapper.BetweenFilter('5', '-55', '15');
        filterWrapper.Customer_Order_Deposits = new HomeSearchFilterWrapper.BetweenFilter('5', '-5', '15');*/
        filterWrapper.Vendor_Ordering_Vendor = 'Test Vendor';
        filterWrapper.Vendor_Ordering_Total = new HomeSearchFilterWrapper.BetweenFilter('1', '1000', null);
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details1 = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details1);
        //system.assertEquals(details1.VendorOrderingRecords[0].Total, 8250);
        system.assertEquals(details1.VendorOrderingRecords[0].Status, 'Stocked');
}

            /*
     * Name: getFilterRecordsforCustomerSales
     * Desc: Test to check filterrecordsforcustomerSales.
     * @param: 
     * @return: 
    **/
     static testMethod void getFilterRecordsforCustomerSales() {
        
        //Created test data to check scenario
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
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
            // create PO type and vendor order
        
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        Test.StartTest();
            //  group all required parts for vendor
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(voHeader.Id), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
            // vendor order submitted
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));

            // created vendorOrderReceive header
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vorId), true));
            // Add all lineitem for receiving
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(voLineItems.VendorOrderLineItemGroupList[0].Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
            //  receiving all parts from vendor
            Test.StopTest();
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
            
            // Getting customer order details again
        String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(BPUtility.getEncodedString(coHeader.Id)));
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
        system.assertEquals(coHeaderDetails.COInvoiceItemRecs[0].Total, 8250.000);
         
            // adding payments on CO
        String savedCOInvoicePayment = BPUtility.getDecodedString(CustomerOrderCtrl.saveCOInvoicePayment(BPUtility.getEncodedString('[{"ReverseLink":null,"PaymentMethod":"Cash","Amount":"8250.000","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'"}]')));
        
            // Closing invoice
        List<CO_Invoice_Header__c> coInvoiceList = [select Total_Payment__c, Invoice_Status__c, CO_Header__c from CO_Invoice_Header__c];
        //system.assert(false, coInvoiceList );
        
        List<CO_Header__c> coHeaderList = [select name from CO_Header__c];
        //system.assertEquals(false, coHeaderList );
        
        
        //String closedInvoiceAction = CustomerOrderCtrl.closedInvoiceAction('[{"Total":8250.000,"TaxAmount":null,"Saving":null,"RetailPrice":null,"QtyRequired":null,"Qty":null,"Price":null,"Item":"Service Job 1","IsInvoiceable":true,"IsActive":true,"COLineItemId":null,"COInvoiceItemNumber":null,"COInvoiceItemId":"'+coHeaderDetails.coInvoiceItemRecs[0].COInvoiceItemId+'","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'","$$hashKey":"object:56"}]', coHeader.Id, 'Customer');
        
        
        List<Id> fixedSearchResults = new List<Id>{coInvoiceList[0].Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customer Orders', 'Customer Invoices'};
        //filterWrapper.Product_Item = 'co';
        //filterWrapper.SearchText = 'INV';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        //filterWrapper.Product_Description = 'details';
        filterWrapper.Customer_Sales_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '100', '15000');
        filterWrapper.Customer_Sales_Customer = 'customerName';
        filterWrapper.Customer_Sales_Total = new HomeSearchFilterWrapper.BetweenFilter('1', '8250', null);
        filterWrapper.CO_Invoice_Header_Customer_Order = coHeaderList[0].Name ;
        /*filterWrapper.Customer_Order_Payments = new HomeSearchFilterWrapper.BetweenFilter('5', '-55', '15');
        filterWrapper.Customer_Order_Deposits = new HomeSearchFilterWrapper.BetweenFilter('5', '-5', '15');*/
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details1 = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details1);
        system.assertEquals(details1.CustomerSalesRecords[0].Total, 8250);
         System.assertEquals(true,true);
}

 static testMethod void getFilteredRecordsforProducts() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c part1 = TestUtil.createPart(true, '56', vendor.Id, 'Test Part1', testCategory.Id, 10, 20, 50, 100, 100);
        
        //Account customer =    TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
         Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', null, false, true, unitMake.Id, unitModel.Id);
        // fixed price and flag both are false for both line item 
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, null, null, Part.Id, 1, null);
        KitLineItemtriggerHelper.PermitRun_BeforeInsert = true;
        
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'Fee', CoHeader.Id, 'Description', 100, True);
        
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'CodeName', 10, true);
        
        List<Id> fixedSearchResults = new List<Id>{part.Id, part1.Id, customer.Id, kitHeader.Id, fee.id, labourCode.Id };
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Kits', 'Fees', 'Parts', 'Labor Codes'};
        //filterWrapper.Product_Item = '123';
        
        //filterWrapper.People_Name = 'Harley';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details);
        //system.assertEquals(details.ProductRecords[0].Description, '123');
        system.assertequals(details.ProductRecords.size(), 5);
    }
    
     static testMethod void getFilteredRecordsforItemcategory() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Category__c testCategory1 = TestUtil.createCategory(true, 'Test Category1');
        
        
        List<Id> fixedSearchResults = new List<Id>{testCategory.Id, testCategory1.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Item Categories', 'Customers'};
        //filterWrapper.Status = 'Active';
        //filterWrapper.People_Name = 'Harley';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details);
        system.assertEquals(details.AnyObjectRecords[0].Summary, 'Testing Category');
         System.assertEquals(true,true);
    }
    
 static testMethod void getFilteredRecordsforItemcategoryA() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Category__c testCategory1 = TestUtil.createCategory(true, 'Test Category1');
        
        
        List<Id> fixedSearchResults = new List<Id>{testCategory.Id, testCategory1.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Item Categories'};
        //filterWrapper.Status = 'Active';
        //filterWrapper.People_Name = 'Harley';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //.assert(false, details);
        system.assertEquals(details.CategoryRecords[0].Description, 'Testing Category');
         System.assertEquals(true,true);
    }
    
     static testMethod void getFilteredRecordsforPriceLevel() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Labour');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        
        List<Id> fixedSearchResults = new List<Id>{defaultPriceLevel.Id, defaultSalesTax.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Price Levels'};
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //System.assert(false, details);
        system.assertEquals(details.PriceLevelRecords[0].Status, 'Active');
    }
    
 static testMethod void getFilteredRecordsforSalestax() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Labour');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        
        List<Id> fixedSearchResults = new List<Id>{defaultPriceLevel.Id, defaultSalesTax.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Sales Taxes'};
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //System.assert(false, details);
        system.assertEquals(details.SalesTaxRecords[0].Status, 'Active');
    }
    
     static testMethod void getFilteredRecordsforSettings() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Labour');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        
        List<Id> fixedSearchResults = new List<Id>{defaultPriceLevel.Id, defaultSalesTax.Id, testCategory.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Price Levels', 'Item Categories'};
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //System.assert(false, details);
        system.assertEquals(details.SettingRecords[0].code, 'Default Price Level');
    }
    
 static testMethod void getFilteredRecordsforUsers() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Labour');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        User ausUser = TestUtil.createUser(true, 'a@b.com', 'Testing ', 'en_AU', 'testUse123r@force.com', 'Test U');
        
        
        List<Id> fixedSearchResults = new List<Id>{ausUser.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Users'};
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //System.assert(false, details);
        system.assertEquals(details.UserRecords[0].Name, 'Testing');
    }
    
     static testMethod void getFilteredRecordsforUsersA() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Labour');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        User ausUser = TestUtil.createUser(true, 'a@b.com', 'Testing ', 'en_AU', 'testUse123r@force.com', 'ram');
        User ausUser1 = TestUtil.createUser(true, 'ab@b.com', 'abcd ', 'en_AU', 'testUse123raw@force.com', 'shyam');
        
        
        
        List<Id> fixedSearchResults = new List<Id>{ausUser1.Id};
        Test.setFixedSearchResults(fixedSearchResults); 
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Users'};
        //filterWrapper.SearchText = 'shyam';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //System.assert(false, details);
        //system.assertEquals(details.UserRecords[0].Name, 'Testing');
         System.assertEquals(true,true);
    }
    
    static testMethod void getFilteredRecordsforSublets() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Labour');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        User ausUser = TestUtil.createUser(true, 'a@b.com', 'Testing ', 'en_AU', 'testUse123r@force.com', 'ram');
        User ausUser1 = TestUtil.createUser(true, 'ab@b.com', 'abcd ', 'en_AU', 'testUse123raw@force.com', 'shyam');
        
        Product__c sublet = Testutil.createSublet(true, testCategory.Id, 'Code', 100, 'Description', 10, 1000, 'Active',  vendor.Id );
        
        
        
        List<Id> fixedSearchResults = new List<Id>{ausUser.Id, ausUser1.Id, sublet.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Vendor Product'};
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //System.assert(false, details);
        system.assertEquals(details.VendorProductRecords[0].Description, 'Description');
    }
    
        static testMethod void getFilteredRecordsforproductsIncludeSublet() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Labour');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        User ausUser = TestUtil.createUser(true, 'a@b.com', 'Testing ', 'en_AU', 'testUse123r@force.com', 'ram');
        User ausUser1 = TestUtil.createUser(true, 'ab@b.com', 'abcd ', 'en_AU', 'testUse123raw@force.com', 'shyam');
        
        Product__c sublet = Testutil.createSublet(true, testCategory.Id, 'Code', 100, 'Description', 10, 1000, 'Active',  vendor.Id );
         Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        
        
        List<Id> fixedSearchResults = new List<Id>{ausUser.Id, ausUser1.Id, sublet.Id, part.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Sublets', 'Parts'};
        filterWrapper.Status = 'Active';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //System.assert(false, details);
        system.assertEquals(details.ProductRecords[0].Description, 'Description');
    }
    
 static testMethod void getFilteredRecordsforAny() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Labour');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        User ausUser = TestUtil.createUser(true, 'a@b.com', 'Testing ', 'en_AU', 'testUse123r@force.com', 'ram');
        User ausUser1 = TestUtil.createUser(true, 'ab@b.com', 'abcd ', 'en_AU', 'testUse123raw@force.com', 'shyam');
        
        Product__c sublet = Testutil.createSublet(true, testCategory.Id, 'Code', 100, 'Description', 10, 1000, 'Active',  vendor.Id );
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', defaultPriceLevel.Id, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
         CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 60);
        
        List<CO_Header__c> coHeaderList = [select Total_Deposit__c, Total_Payment__c from CO_Header__c];
        
        
        List<Id> fixedSearchResults = new List<Id>{ausUser.Id, ausUser1.Id, sublet.Id, part.Id, customer.Id, coHeader.Id, defaultSalesTax.Id, vendor.Id };
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        //filterWrapper.Type.objects = new Set<String>{'Sublets', 'Parts', 'Customers', 'Customer Orders', 'vendors', 'Sales Taxes', 'Users' };
        filterWrapper.Type.objects = new Set<String>{'Sublets','Parts', 'Customers', 'Customer Orders','Sales Taxes', 'Users', 'Vendors' };
        //filterWrapper.Status = 'Active';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //System.assert(false, details);
         System.assertEquals(true,true);
    }
    
     static testMethod void getSummaryTotalforCustomerOrdersTest() {
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 2;
        insert part;
        COLineItemTriggerHelper.isTotalCalculated = false;
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 50);
        
        
        Account customer1 =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.Id, null, false, true,'Individual');
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, customer1.Id);
        Part__c part1 = TestUtil.createPart(false, 'partNumberP02', vendor.Id, 'Test Part12', testCategory.Id, 10, 20, 50, 100, 100);
        part1.Packaged_Part__c = false;
        part1.Qty_On_Order__c = 0;
        part1.Order_Lots__c = 2;
        insert part1;
        COLineItemTriggerHelper.isTotalCalculated = false;
        CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(true, coHeader1.Id, part1.Id, 60);
        
        List<CO_Header__c> coHeaderList = [select Total_Deposit__c, Total_Payment__c from CO_Header__c];
        //system.assert(false, coHeaderList );
        
        List<Id> fixedSearchResults = new List<Id>{coHeader1.Id, coHeader.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customer Orders'};
        filterWrapper.Product_Item = 'co';
        //filterWrapper.SearchText = 'co';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        //filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        //filterWrapper.Product_Description = 'details';
        filterWrapper.Customer_Sales_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '2000', '4000');
        /*filterWrapper.Customer_Sales_Balance_Due = new HomeSearchFilterWrapper.BetweenFilter('1', '0', null);
        filterWrapper.Customer_Order_Payments = new HomeSearchFilterWrapper.BetweenFilter('5', '-55', '15');
        filterWrapper.Customer_Order_Deposits = new HomeSearchFilterWrapper.BetweenFilter('5', '-5', '15');*/
        filterWrapper.Customer_Order_Payments =  new HomeSearchFilterWrapper.BetweenFilter('1', '0', 'null');
        filterWrapper.Customer_Order_Deposits =  new HomeSearchFilterWrapper.BetweenFilter('1', '0', 'null');
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        
        String reportData = BPUtility.getDecodedString(HomeSearchCtrl.getReportingRecords(BPUtility.getEncodedString(System.Json.serialize(filterWrapper))));
        List<HomeSearchReportResultWrapper> details1 = (List<HomeSearchReportResultWrapper>) System.JSON.deserialize(reportData, List<HomeSearchReportResultWrapper>.class);
        system.assertEquals(details1[0].TotalValue, 2);
        system.assertEquals(details1[1].TotalValue, 6050);
         System.assertEquals(true,true);
}

     static testMethod void getSummaryTotalforPartsTest() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c part1 = TestUtil.createPart(true, '56', vendor.Id, 'Test Part1', testCategory.Id, 10, 20, 50, 100, 100);
        
        List<Id> fixedSearchResults = new List<Id>{part.Id, part1.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Parts'};
        //filterWrapper.Product_Item = '123';
        
        //filterWrapper.People_Name = 'Harley';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        
        String reportData = BPUtility.getDecodedString(HomeSearchCtrl.getReportingRecords(BPUtility.getEncodedString(System.Json.serialize(filterWrapper))));
        List<HomeSearchReportResultWrapper> details1 = (List<HomeSearchReportResultWrapper>) System.JSON.deserialize(reportData, List<HomeSearchReportResultWrapper>.class);
        system.assertEquals(details1[0].TotalValue, 2);
        system.assertEquals(details1[1].TotalValue, 200);
    }
    
        static testMethod void getReportforPartsTest() {
        Account customer = TestUtil.createCustomer(true, 'Harley', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c part1 = TestUtil.createPart(true, '56', vendor.Id, 'Test Part1', testCategory.Id, 10, 20, 50, 100, 100);
        
        List<Id> fixedSearchResults = new List<Id>{part.Id, part1.Id, customer.Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Parts'};
        //filterWrapper.Product_Item = '123';
        
        //filterWrapper.People_Name = 'Harley';
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        
        String reportData = BPUtility.getDecodedString(HomeSearchCtrl.getReportingRecords(BPUtility.getEncodedString(System.Json.serialize(filterWrapper))));
        List<HomeSearchReportResultWrapper> details1 = (List<HomeSearchReportResultWrapper>) System.JSON.deserialize(reportData, List<HomeSearchReportResultWrapper>.class);
        
        String reportData1 =  BPUtility.getDecodedString(HomeSearchCtrl.getReportData(BPUtility.getEncodedString(System.Json.serialize(filterWrapper)), BPUtility.getEncodedString('Parts'), BPUtility.getEncodedString(null)));
        HomeSearchReportUtil.ReportWrapper details2 = (HomeSearchReportUtil.ReportWrapper) System.JSON.deserialize(reportData1, HomeSearchReportUtil.ReportWrapper.class);
        
        system.assertEquals(details2.TotalRecords, 2);
    }
    
    static testMethod void getSummaryTotalforVendorOrdersTest() {
                //Created test data to check scenario
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
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
            // create PO type and vendor order
        
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        Test.StartTest();
            //  group all required parts for vendor
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(voHeader.Id), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
            // vendor order submitted
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));

            // created vendorOrderReceive header
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vorId), true));
            // Add all lineitem for receiving
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(voLineItems.VendorOrderLineItemGroupList[0].Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
            //  receiving all parts from vendor
            Test.StopTest();
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        
        
        List<Vendor_Receiving_Header__c> vendorReceivingList = [select In_Progress_VI__c, Status__c, Vendor__c, Receiving_Total__c, Receiving_From_Invoice_Total__c from Vendor_Receiving_Header__c];
        //system.assert(false, vendorReceivingList );
        
        
        //String closedInvoiceAction = CustomerOrderCtrl.closedInvoiceAction('[{"Total":8250.000,"TaxAmount":null,"Saving":null,"RetailPrice":null,"QtyRequired":null,"Qty":null,"Price":null,"Item":"Service Job 1","IsInvoiceable":true,"IsActive":true,"COLineItemId":null,"COInvoiceItemNumber":null,"COInvoiceItemId":"'+coHeaderDetails.coInvoiceItemRecs[0].COInvoiceItemId+'","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'","$$hashKey":"object:56"}]', coHeader.Id, 'Customer');
        
        
        List<Id> fixedSearchResults = new List<Id>{vendorReceivingList[0].Id, vendorReceivingList[1].Id };
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Vendor Orders', 'Vendor Receivings'};
        filterWrapper.Status = 'Stocked';
        //filterWrapper.SearchText = 'co';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        //filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        //filterWrapper.Product_Description = 'details';
        //filterWrapper.Customer_Sales_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '3000', '15000');
        /*filterWrapper.Customer_Sales_Balance_Due = new HomeSearchFilterWrapper.BetweenFilter('1', '0', null);
        filterWrapper.Customer_Order_Payments = new HomeSearchFilterWrapper.BetweenFilter('5', '-55', '15');
        filterWrapper.Customer_Order_Deposits = new HomeSearchFilterWrapper.BetweenFilter('5', '-5', '15');*/
        filterWrapper.Vendor_Ordering_Vendor = 'Test Vendor';
        filterWrapper.Vendor_Ordering_Total = new HomeSearchFilterWrapper.BetweenFilter('1', '1000', null);
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String reportData = BPUtility.getDecodedString(HomeSearchCtrl.getReportingRecords(BPUtility.getEncodedString(System.Json.serialize(filterWrapper))));
        List<HomeSearchReportResultWrapper> details1 = (List<HomeSearchReportResultWrapper>) System.JSON.deserialize(reportData, List<HomeSearchReportResultWrapper>.class);
        //system.assert(false, details1);
        system.assertEquals(details1[0].TotalValue, 1);
        system.assertEquals(details1[1].TotalValue, 1000);
    }
    
        static testMethod void getSummaryTotalforVendorReceiveTest() {
                //Created test data to check scenario
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
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
            // create PO type and vendor order
        
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        Test.StartTest();
            //  group all required parts for vendor
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(voHeader.Id), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
            // vendor order submitted
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));

            // created vendorOrderReceive header
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vorId), true));
            // Add all lineitem for receiving
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(voLineItems.VendorOrderLineItemGroupList[0].Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
            //  receiving all parts from vendor
            Test.StopTest();
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        
        
        List<Vendor_Receiving_Header__c> vendorReceivingList = [select In_Progress_VI__c, Status__c, Vendor__c, Receiving_Total__c, Receiving_From_Invoice_Total__c from Vendor_Receiving_Header__c];
        //system.assert(false, vendorReceivingList );
        
        
        //String closedInvoiceAction = CustomerOrderCtrl.closedInvoiceAction('[{"Total":8250.000,"TaxAmount":null,"Saving":null,"RetailPrice":null,"QtyRequired":null,"Qty":null,"Price":null,"Item":"Service Job 1","IsInvoiceable":true,"IsActive":true,"COLineItemId":null,"COInvoiceItemNumber":null,"COInvoiceItemId":"'+coHeaderDetails.coInvoiceItemRecs[0].COInvoiceItemId+'","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'","$$hashKey":"object:56"}]', coHeader.Id, 'Customer');
        
        
        List<Id> fixedSearchResults = new List<Id>{vendorReceivingList[0].Id, vendorReceivingList[1].Id };
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Vendor Orders', 'Vendor Receivings'};
        //filterWrapper.Status = 'Stocked';
        //filterWrapper.SearchText = 'co';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        //filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        //filterWrapper.Product_Description = 'details';
        //filterWrapper.Customer_Sales_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '3000', '15000');
        /*filterWrapper.Customer_Sales_Balance_Due = new HomeSearchFilterWrapper.BetweenFilter('1', '0', null);
        filterWrapper.Customer_Order_Payments = new HomeSearchFilterWrapper.BetweenFilter('5', '-55', '15');
        filterWrapper.Customer_Order_Deposits = new HomeSearchFilterWrapper.BetweenFilter('5', '-5', '15');*/
        //filterWrapper.Vendor_Ordering_Vendor = 'Test Vendor';
        //filterWrapper.Vendor_Ordering_Total = new HomeSearchFilterWrapper.BetweenFilter('1', '1000', null);
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String reportData = BPUtility.getDecodedString(HomeSearchCtrl.getReportingRecords(BPUtility.getEncodedString(System.Json.serialize(filterWrapper))));
        List<HomeSearchReportResultWrapper> details1 = (List<HomeSearchReportResultWrapper>) System.JSON.deserialize(reportData, List<HomeSearchReportResultWrapper>.class);
        
        system.assertEquals(details1[1].TotalValue, 2000);
    }
    
    static testMethod void getSummaryTotalforVendorInvoiceTest() {
        
        //System.JSON.serialize(pageSort)

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
        
       VendorOrderReceivingCtrl_PartialTest.getSummaryTotalforVendorInvoiceTest(vendor.Id,voHeader.Id,coHeader.Id,part.Id,part2.Id);
    
    }
    
    static testMethod void serviceJobSearchTest(){
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
        defaultPriceLevel.Labour_Rate__c = 60 ;
        Sales_Tax__c salestax =  TestUtil.createSalesTax(false, 'HST');
        
        Account customer = TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        
        insert new List<SObject>{defaultPriceLevel, salestax, customer};
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
        customerOwnedUnitRec.Status__c = 'Available';
        insert customerOwnedUnitRec;
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Test.startTest();
        
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
        
        Test.stopTest();
        
        soHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(fee.id), BPUtility.getEncodedString(soHeaderObj.SOList[0].SOHeaderInfo.id),BPUtility.getEncodedString(coHeader.id),BPUtility.getEncodedString(customer.Id)));
        soHeaderObj = (SOHeaderWrapper)Json.deserialize(soHeaderDetails,SOHeaderWrapper.class);
        
        VendorOrderReceivingCtrl_PartialTest.serviceJobSearchFutureTest(coHeader.Id); 
    }
    
    static testMethod void TechnicianHoursSearch(){
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        coHeader.CO_Type__c = 'Customer';
        insert coHeader;
        Technician__c technicianRec1 = new Technician__c(Technician_Name__c = 'Test Name', Active__c = true);
        insert technicianRec1;
        
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
        hoursLoggedRec.Service_Order_Header__c = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        hoursLoggedRec.Start_Date_Time__c = datetime.newInstance(2017, 12, 12, 10, 30, 0);
        hoursLoggedRec.Work_Performed_Date__c = Date.newInstance(2017, 12, 9);
        hoursLoggedRec.End_Date_Time__c= datetime.newInstance(2017, 12, 12, 12, 30, 0);
        insert hoursLoggedRec;
        
        //added for package upload by gourav
        List<Hours_Logged__c> hoursLoggedList = [Select Technician__c,Start_Date_Time__c,Calculated_Hours__c,End_Date_Time__c, Total_Hours__c, Technician__r.Technician_Name__c, Employee__c,Employee__r.Name ,Notes__c,Original_Estimate__c,Previously_Logged__c,Remaining_Estimate_d__c,Remaining_Estimate_h__c,Remaining_Estimate_m__c,Service_Order_Header__c,Work_Performed_Date__c,Time_Spent_m__c,Time_Spent__c,Name,Time_Spent_d__c,Service_Order_Header__r.Status__c,Time_Spent_h__c,Notes_Required__c,CreatedDate from Hours_Logged__c where id =: hoursLoggedRec.id];
        SOHeaderWrapper.HoursLogged hourLoggedJson = new SOHeaderWrapper.HoursLogged(hoursLoggedList[0]);
        String hourLoggedJsonString = Json.serialize(hourLoggedJson);
        List<SOHeaderWrapper.HoursLogged> hoursLoggedWrapperList = (List<SOHeaderWrapper.HoursLogged>)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.saveHoursLogged(BPUtility.getEncodedString(hourLoggedJsonString),BPUtility.getEncodedString(coHeader.Id))),List<SOHeaderWrapper.HoursLogged>.class);
        
        List<Service_Order_Header__c> serviceOrderHeaderList = [select Status__c, Total_Parts__c, Work_Status__c, Hrs_Billed__c, Hrs_Logged__c, Technician_Name__c  from Service_Order_Header__c];
        //system.assert(false, serviceOrderHeaderList );
        
        
        
        
        List<Id> fixedSearchResults = new List<Id>{serviceOrderHeaderList[0].Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Service Jobs'};
        //filterWrapper.Status = 'In Progress';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //System.assert(false, details);
         System.assertEquals(details.ServiceJobs[0].Hrs_Billed, 10.00);
         System.assertEquals(details.ServiceJobs[0].Hrs_Logged, 2.00);
                
    }
        
}