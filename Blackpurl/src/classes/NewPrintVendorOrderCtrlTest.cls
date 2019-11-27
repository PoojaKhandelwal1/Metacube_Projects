@isTest
public with sharing class NewPrintVendorOrderCtrlTest {
     
    @testSetup
    private static void setup() {
        BP_Configurations__c BPConfigurationsRec = new BP_Configurations__c();
        BPConfigurationsRec.Company_Logo_URL__c = 'https://c.na3.content.force.com/servlet/servlet.ImageServer?id=01550000002sQtj&oid=00D50000000bV4K&lastMod=1474442215000';
        insert BPConfigurationsRec;
        system.assert(true,true);
    }
    
    static testMethod void getVODetailsTest() {
        
        Country__c country = TestUtil.createCountry(true, 'Test Country 1', true, true);
        State__c state = TestUtil.createState(true, 'Test State 1', country.Id, true);
        Business_Profile__c BusinessProfileRec = new Business_Profile__c();
        BusinessProfileRec.Business_City__c = 'jaipur';
        BusinessProfileRec.Business_Country__c = country.Id;
        BusinessProfileRec.Business_Email__c = 'hitesh.gupta@metacube.com';
        BusinessProfileRec.Business_Name__c = 'Metacube';
        BusinessProfileRec.Business_Phone__c = '1235678921';
        BusinessProfileRec.Business_State__c = state.Id;
        BusinessProfileRec.Business_Street_Address1__c = 'street 1'; 
        BusinessProfileRec.Business_Street_Address2__c = 'street 2';
        BusinessProfileRec.Business_Postal_Code__c = '302012';
        BusinessProfileRec.Same_As_Business_Address__c = false;
        BusinessProfileRec.Shipping_City__c = 'jaipur'; 
        BusinessProfileRec.Company_Name_Optional__c = 'Metacube optional';
        BusinessProfileRec.Shipping_Country__c = country.Id;
        BusinessProfileRec.Shipping_State__c = state.Id;
        BusinessProfileRec.Shipping_Street_Address1__c = 'street 1';
        BusinessProfileRec.Shipping_Street_Address2__c = 'street 2';
        BusinessProfileRec.Shipping_Postal_Code__c = '302012';
        insert BusinessProfileRec;
        
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Preferred_Email__c = 'Preferred@email.com';
        vendor.Other_Email__c = 'Preferred@email.com'; 
        vendor.Preferred_Phone__c = '1212121212';
        vendor.Work_Number__c = '1212121212';
        insert vendor;
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, true, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = true ;
        part.Package_Qty__c = 5;
        insert part;
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Ordered_Date__c = Date.Today();
        insert voHeader;
        Vendor_Order_Line_Item_Group__c vendorOrderGroup1 = TestUtil.createVendorOrderLineItemGroup(true, voHeader.Id, part.Id);
        Vendor_Order_Line_Item_Group__c vendorOrderGroup2 = TestUtil.createVendorOrderLineItemGroup(true, voHeader.Id, part.Id);
        Vendor_Order_Line_Item__c voLineItem = TestUtil.createVendorOrderLineItem(true, voHeader.Id, part.Id, 150);
        
        // Create current page ref
        PageReference pageRef = Page.PrintVendorOrder;
        pageRef.getParameters().put('id', String.valueOf(voHeader.Id));
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        NewPrintVendorOrderCtrl newPrintVendorOrderCtrlObj = new NewPrintVendorOrderCtrl();
        system.assertEquals(1, [select Id from Vendor_Order_Header__c].size());
        String companylogoStr = newPrintVendorOrderCtrlObj.companyLogoURL;
        Test.stopTest();
    }
    
    static testMethod void getVODetailsCaseTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, true, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(true, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Ordered_Date__c = Date.Today();
        insert voHeader;
        Vendor_Order_Line_Item_Group__c vendorOrderGroup1 = TestUtil.createVendorOrderLineItemGroup(true, voHeader.Id, part.Id);
        Vendor_Order_Line_Item_Group__c vendorOrderGroup2 = TestUtil.createVendorOrderLineItemGroup(true, voHeader.Id, part.Id);
        Vendor_Order_Line_Item__c voLineItem = TestUtil.createVendorOrderLineItem(true, voHeader.Id, part.Id, 150);
        
        // Create current page ref
        PageReference pageRef = Page.PrintVendorOrder;
        pageRef.getParameters().put('id', String.valueOf(voHeader.Id));
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        NewPrintVendorOrderCtrl newPrintVendorOrderCtrlObj = new NewPrintVendorOrderCtrl();
        system.assertEquals(1, [select Id from Vendor_Order_Header__c].size());
        Test.stopTest();
    }
}