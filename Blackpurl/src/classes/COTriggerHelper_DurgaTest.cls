@isTest
public with sharing class COTriggerHelper_DurgaTest {
    /*
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
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
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
        
        List<User> config = [SELECT Id FROM User LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
        System.assertNotEquals(0, config.size());
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
        
        List<Account> accList = [select Id, Name from Account limit 100];
        system.assertEquals(accList.size(), 2);
        
        COTriggerHelper.isTriggerExecute = true;
        Update coHeader;
        
     }
     */
}