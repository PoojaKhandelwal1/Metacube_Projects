@isTest
private class VendorOrderHeaderTriggerTest {

    static testMethod void testUpdateVendorOrderHeader(){
    	
        Vendor_Order_Header__c voHeader = new Vendor_Order_Header__c(Status__c = 'Open');
        insert voHeader;
        
        voHeader.Status__c = 'Locked';
        update voHeader;
        
        voHeader = [Select id, Name, Status__c from Vendor_Order_Header__c Limit 1];
        System.assert(String.valueOf(voHeader.Status__c).equalsIgnoreCase('Locked'), 'Record not updated successfully');
        
        List<Contact> accList = [select Id, Name from Contact limit 100];
		system.assertEquals(accList.size(), 0);
    }
    
    
    static testMethod void testUpdateVendorOrderHeaderProgressVR(){
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Vendor_Receiving_Header__c vor1 = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
    	Vendor_Receiving_Header__c vor2 = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
    	    	   	
        Vendor_Order_Header__c voHeader = new Vendor_Order_Header__c(Status__c = 'Open');
        voHeader.In_Progress_VR__c = vor1.Id;
        insert voHeader;
       
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Vendor_Receiving_Group__c vrg = new Vendor_Receiving_Group__c();
        vrg.Vendor_Receiving_Header__c = vor2.Id;
        vrg.Part__c = part.Id;
        insert vrg;
        
        Vendor_Order_Line_Item__c voLineItem = TestUtil.createVendorOrderLineItem(false, voHeader.Id, part.Id, 150);
        voLineItem.Vendor_Receiving_Group__c = vrg.Id;
        insert voLineItem;
        
        voHeader.Status__c = 'Locked';
        voHeader.In_Progress_VR__c = null;
        update voHeader;
        
        voHeader = [Select id, Name, Status__c from Vendor_Order_Header__c where id = :voHeader.Id Limit 1];
        System.assert(String.valueOf(voHeader.Status__c).equalsIgnoreCase('Locked'), 'Record not updated successfully');
        
        List<Contact> accList = [select Id, Name from Contact limit 100];
		system.assertEquals(accList.size(), 0);
    }
        
    static testMethod void updateExpectedDeliveryDateTest(){    
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	PO_Type__c POType1 = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
    	PO_Type__c POType2 = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        
        Vendor_Order_Header__c voHeader = new Vendor_Order_Header__c(Status__c = 'Open');
        voHeader.Purchase_Order_Type__c = POType1.Id;
        insert voHeader;
        
        voHeader.Status__c = 'Locked';
        voHeader.Purchase_Order_Type__c = POType2.Id;
        update voHeader;
        
        voHeader = [Select id, Name, Status__c from Vendor_Order_Header__c where id = :voHeader.Id Limit 1];
        System.assert(String.valueOf(voHeader.Status__c).equalsIgnoreCase('Locked'), 'Record not updated successfully');
        
        List<Contact> accList = [select Id, Name from Contact limit 100];
		system.assertEquals(accList.size(), 0);
    }
}