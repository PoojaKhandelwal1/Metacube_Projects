/**
 * Author: Durga Singh
 * Since: August 13, 2015
 * Name: VendorOrderLineItemTriggerHelperTest
 * Description: Test trigger and update calculation for VOLI generated after creating COLI.
**/
@isTest
private class VendorOrderLineItemTriggerHelperTest {
	
	                                                   /**
     * Name: afterUpdateCalculationTest
     * Desc: Test to get calculations for VOLI after committing COLI
     * @param: 
     * @return: 
    **/

    static testMethod void afterUpdateCalculationTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 1;
        insert part;
		
		PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        Test.startTest();
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        Test.stopTest();
        
        List<Vendor_Order_Line_Item__c> vendorOrderList = [select Id, Qty_Needed__c, Qty_Ordered__c from Vendor_Order_Line_Item__c limit 100];
        //system.assert(false,vendorOrderList );
        system.assertEquals(vendorOrderList[0].Qty_Needed__c, 50.000);
    }
    
    static testMethod void afterUpdateCalculationTestWithSpecialOrder() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 1;
        insert part;
		
		PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        Test.startTest();
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        Test.stopTest();
        
        List<Vendor_Order_Line_Item__c> vendorOrderList = [select Id, Qty_Needed__c, Qty_Ordered__c, Vendor_Order_Header__c, Is_required_For_Customer__c, CO_Line_Item__c from Vendor_Order_Line_Item__c limit 100];
        //system.assert(false,vendorOrderList );
        system.assertEquals(vendorOrderList[0].Qty_Needed__c, 50.000);
        
        vendorOrderList[0].Qty_Needed__c = 60;
        vendorOrderList[0].CO_Line_Item__c = coLineItem.Id;
        vendorOrderList[0].Vendor_Order_Header__c = voHeader.Id;
        update vendorOrderList[0];
        vendorOrderList = [select Id, Qty_Needed__c, Qty_Ordered__c from Vendor_Order_Line_Item__c limit 100];
        system.assertEquals(vendorOrderList[0].Qty_Needed__c, 60.000);
    }
    
    static testMethod void afterUpdateCalculationTestWithNoSpecialOrder() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 1;
        insert part;
		
		PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        Test.startTest();
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        Test.stopTest();
        
        Vendor_Order_Line_Item__c voLineItem = TestUtil.createVendorOrderLineItem(false, voHeader.Id, part.Id, 150);
        voLineItem.CO_Line_Item__c = coLineItem.Id;
        voLineItem.Qty_Needed__c = 50;
        voLineItem.Is_required_For_Customer__c = true;
        insert voLineItem;
        
        List<Vendor_Order_Line_Item__c> vendorOrderList = [select Id, Qty_Needed__c, Qty_Ordered__c, Vendor_Order_Header__c, Is_required_For_Customer__c, CO_Line_Item__c from Vendor_Order_Line_Item__c where Id =:voLineItem.Id];

        system.assertEquals(vendorOrderList[0].Qty_Needed__c, 50.000);

        vendorOrderList[0].Vendor_Order_Header__c = null;
        update vendorOrderList[0];
        vendorOrderList = [select Id, Qty_Needed__c, Vendor_Order_Header__c from Vendor_Order_Line_Item__c where Id =:voLineItem.Id];
        system.assertEquals(vendorOrderList[0].Vendor_Order_Header__c, null);
        system.assertEquals(vendorOrderList[0].Qty_Needed__c, 50.000);
    }
    
	static testMethod void testDealerNameUpdate() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 1;
        insert part;
		
		PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        Test.startTest();
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        Test.stopTest();
        
        List<Vendor_Order_Line_Item__c> vendorOrderList = [select Id, Qty_Needed__c, Qty_Ordered__c, Vendor_Order_Header__c, Is_required_For_Customer__c, CO_Line_Item__c from Vendor_Order_Line_Item__c limit 100];
        //system.assert(false,vendorOrderList );
        system.assertEquals(vendorOrderList[0].Qty_Needed__c, 50.000);
        
        String expectedDealerName = 'business 1';
        
        List<Business_Profile__c> businessProfileList = [Select Business_Name__c from Business_Profile__c LIMIT 1];
        
        if(businessProfileList.size() > 0) {
        	expectedDealerName = businessProfileList[0].Business_Name__c;
        } else {
        	Business_Profile__c businessProfileObject = new Business_Profile__c();
        	businessProfileObject.Business_Street_Address1__c = 'test street1';
        	businessProfileObject.Business_Street_Address2__c = 'test street1';
        	businessProfileObject.Business_City__c = 'test city'; 
        	businessProfileObject.Business_Name__c = expectedDealerName;
        	businessProfileObject.Shipping_Postal_Code__c = '302022';
        	insert businessProfileObject;
        	
        }
        
        vendorOrderList[0].Is_required_For_Customer__c = false;
        vendorOrderList[0].Vendor_Order_Header__c = voHeader.Id;
        update vendorOrderList[0];
        
        vendorOrderList = [select Id, Dealer_Name__c from Vendor_Order_Line_Item__c where Id = :vendorOrderList[0].Id];
        system.assertEquals(expectedDealerName, vendorOrderList[0].Dealer_Name__c);
    }
}