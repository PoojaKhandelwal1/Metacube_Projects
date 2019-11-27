@isTest
private class SyncVOInvoiceBatchTest {
    
    @testsetup
    private static void setup(){
    	IFW_IntegrationConfig__c IFWConfigObj = TestUtil.sampleIFWConfigForXero();
    	IFWConfigObj.Enabled__c = true;
    	insert IFWConfigObj;
    	
    	IFW_IntegrationConfigItem__c IFWConfigItemObj = TestUtil.createIFWConfigItemForXero('Invoices', IFWConfigObj.Id);
    	
    	Account vendor = TestUtil.createVendor(true, 'Vendor001');
    	Account customer = TestUtil.createCustomer(true, 'Cust001', 'cust@bp.com', 'jp', '11111111111');
    	Category__c category = TestUtil.createCategory(true, 'Category001', 'Part', 'Testing Category', true, true);
    	Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'description', category.Id);
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	
    	Product__c sublet = TestUtil.createSublet(false, category.Id, 'Code', 100, 'Description', 10, 1000, 'Active',  vendor.Id );
    	sublet.Type__c = 'Sublet';
    	insert sublet;
    	
    	Vendor_Order_Header__c vendorOrderHeader = TestUtil.createVendorOrderHeader(true, vendor.Id);
    	Vendor_Order_Line_Item__c vendorOrderLineItem = TestUtil.createVendorOrderLineItem(true, vendorOrderHeader.Id, part.Id, 20);
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
    	CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 1);
    	
    	CO_Invoice_Header__c coInvoiceHeader = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Closed');
    	
    	Service_Order_Header__c soHeaderRec = TestUtil.createSOHeader(coHeader.Id, coInvoiceHeader.Id);
    	Service_Order_Line_Item__c serviceOrderLineItem = TestUtil.createServiceOrderLineItem(soHeaderRec.Id);
    	
    	Vendor_Receiving_Header__c vendorReceivingHeader = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'Stocked');
		Vendor_Receiving_Group__c vendorReceivingGroup = TestUtil.sampleVendorReceivingGroup(vendorReceivingHeader.Id);
		vendorReceivingGroup.Service_Order_Line_Item__c = serviceOrderLineItem.Id;
		vendorReceivingGroup.Sublet__c = sublet.Id;
		insert vendorReceivingGroup;
		
		Vendor_Receiving_Group__c vendorReceivingGroupPart = TestUtil.sampleVendorReceivingGroup(vendorReceivingHeader.Id);
		vendorReceivingGroupPart.Part__c = part.Id;
		insert vendorReceivingGroupPart;

    	Vendor_Invoicing_Header__c vendorInvoicingHeader = TestUtil.createVendorInvoiceHeader(true, vendor.Id, 'In Progress');
        
        Part_FIFO_Bucket__c fifoBucket = TestUtil.createFifoBucket(false, part.Id, 20, 40, 'Vendor receiving');
        fifoBucket.Vendor_Receiving_Header__c = vendorReceivingHeader.Id;
        fifoBucket.Vendor_Invoicing_Header__c = vendorInvoicingHeader.Id;
        insert fifoBucket;
        
        TestUtil.createFifoBucketLI(true, fifoBucket.Id, 7, part.Id);
    	Fee__c fee = TestUtil.createFee(true, true, category.Id, '8963', null, 'test fee 8963', 20, true);
    	Other_Charges__c otherCharges = TestUtil.createOtherCharges(fee.Id, vendorInvoicingHeader.Id);
    	
    	Vendor_Invoicing_Group__c vendorInvoicingGroup = TestUtil.createVendorInvoicingGroup(vendorInvoicingHeader.Id, vendorReceivingGroup.Id, 0.00);
    	Vendor_Invoicing_Group__c vendorInvoicingGroupPart = TestUtil.createVendorInvoicingGroup(vendorInvoicingHeader.Id, vendorReceivingGroupPart.Id, 0.00);
    }
    
    @isTest
    private static void test(){
    	Vendor_Invoicing_Header__c vendorInvoicingHeader = [SELECT Id, Status__c FROM Vendor_Invoicing_Header__c LIMIT 1];
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
    	vendorInvoicingHeader.Status__c = 'Invoiced';
    	update vendorInvoicingHeader;
    	Test.stopTest();
    	Vendor_Invoicing_Header__c vendorInvoicingHeaderAfterUpdation = [SELECT Id, Xero_Accounting_Id__c FROM Vendor_Invoicing_Header__c LIMIT 1];
    	system.assertNotEquals(vendorInvoicingHeaderAfterUpdation.Xero_Accounting_Id__c, null);
    }
    
    @isTest
    private static void testWithVariance(){
    	List<Vendor_Receiving_Group__c> vendorReceivingGroupList = [SELECT Id FROM Vendor_Receiving_Group__c];
    	vendorReceivingGroupList[0].Recieved__c = 2;
    	vendorReceivingGroupList[1].Recieved__c = 2;
    	update vendorReceivingGroupList;
    	
    	List<Vendor_Invoicing_Group__c> vendorInvoicingGroupList = [SELECT Id FROM Vendor_Invoicing_Group__c];
    	vendorInvoicingGroupList[0].VI_Cost__c = 20;
    	vendorInvoicingGroupList[0].VI_Discount__c = 2;
    	
    	vendorInvoicingGroupList[1].VI_Cost__c = 20;
        vendorInvoicingGroupList[1].VI_Discount__c = 2;
    	update vendorInvoicingGroupList;
    	
    	Vendor_Invoicing_Header__c vendorInvoicingHeader = [SELECT Id FROM Vendor_Invoicing_Header__c LIMIT 1];
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
    	vendorInvoicingHeader.Status__c = 'Invoiced';
    	update vendorInvoicingHeader;
    	Test.stopTest();
    	
    	Vendor_Invoicing_Header__c vendorInvoicingHeaderAfterUpdation = [SELECT Id, Xero_Accounting_Id__c FROM Vendor_Invoicing_Header__c LIMIT 1];
    	system.assertNotEquals(vendorInvoicingHeaderAfterUpdation.Xero_Accounting_Id__c, null);
    }
    
    @isTest
    private static void testWithVarianceWithoutTaxable(){
    	Fee__c fee = [SELECT Taxable__c FROM Fee__c LIMIT 1];
    	fee.Taxable__c = false;
    	update fee;
    	
    	List<Vendor_Receiving_Group__c> vendorReceivingGroupList = [SELECT Cost__c FROM Vendor_Receiving_Group__c];
        vendorReceivingGroupList[0].Recieved__c = 2;
        vendorReceivingGroupList[1].Recieved__c = 2;
        update vendorReceivingGroupList;
        
        List<Vendor_Invoicing_Group__c> vendorInvoicingGroupList = [SELECT VI_Discount__c, VI_Cost__c FROM Vendor_Invoicing_Group__c];
        vendorInvoicingGroupList[0].VI_Cost__c = 20;
        vendorInvoicingGroupList[0].VI_Discount__c = 2;
        
        vendorInvoicingGroupList[1].VI_Cost__c = 20;
        vendorInvoicingGroupList[1].VI_Discount__c = 2;
        update vendorInvoicingGroupList;
    	
    	Vendor_Invoicing_Header__c vendorInvoicingHeader = [SELECT Id, Status__c FROM Vendor_Invoicing_Header__c LIMIT 1];
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
    	vendorInvoicingHeader.Status__c = 'Invoiced';
    	update vendorInvoicingHeader;
    	Test.stopTest();
    	
    	Vendor_Invoicing_Header__c vendorInvoicingHeaderAfterUpdation = [SELECT Id, Xero_Accounting_Id__c FROM Vendor_Invoicing_Header__c LIMIT 1];
    	system.assertNotEquals(vendorInvoicingHeaderAfterUpdation.Xero_Accounting_Id__c, null);
    }
}