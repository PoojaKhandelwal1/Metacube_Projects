@isTest
public with sharing class BPGlobalHeaderCtrlTest {
    
    @testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
        System.assertEquals(1, 1);
    }
    
    static testMethod void getCurrentUserImageURLTest(){
    	BPGlobalHeaderCtrl BPGHCtrl = new BPGlobalHeaderCtrl();
    	System.assertEquals(BPGHCtrl.Load_New_UI, false);
    	String imageURL = BPGHCtrl.getCurrentUserImageURL();
    	System.assertNotEquals(imageURL, null);
    }
    
    static testMethod void createCustomerOrderTest(){
    	BPGlobalHeaderCtrl.createCustomerOrder();
    	List<CO_Header__c> coHeaderList = [select id from CO_Header__c];
    	System.assertEquals(coHeaderList.size(), 1);
    }
    
    
    static testMethod void createVendorOrderTest(){
    	BPGlobalHeaderCtrl.createVendorOrder();
    	List<Vendor_Order_Header__c> voHeaderList = [select id from Vendor_Order_Header__c];
    	System.assertEquals(voHeaderList.size(), 1);
    }
    
    static testMethod void createVOReceivingTest(){
    	BPGlobalHeaderCtrl.createVOReceiving();
    	List<Vendor_Receiving_Header__c> vrHeaderList = [select id from Vendor_Receiving_Header__c];
    	System.assertEquals(vrHeaderList.size(), 1);
    }
     
    static testMethod void createVOInvoicingTest(){
    	BPGlobalHeaderCtrl.createVOInvoicing();
    	List<Vendor_Invoicing_Header__c> viHeaderList = [select id from Vendor_Invoicing_Header__c];
    	System.assertEquals(viHeaderList.size(), 1);
    }
    
    static testMethod void createNewVendorOrderTest(){
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	BPGlobalHeaderCtrl.createNewVendorOrder(BPUtility.getEncodedString(vendor.Id));
    	List<Vendor_Order_Header__c> voHeaderList = [select id from Vendor_Order_Header__c];
    	System.assertEquals(voHeaderList.size(), 1);
    }
    
    static testMethod void createNewVendorReceivingTest(){
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	BPGlobalHeaderCtrl.createNewVendorReceiving(BPUtility.getEncodedString(vendor.Id));
    	List<Vendor_Receiving_Header__c> vrHeaderList = [select id from Vendor_Receiving_Header__c];
    	System.assertEquals(vrHeaderList.size(), 1);
    }
     
    static testMethod void createNewVendorInvoicingTest(){
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	BPGlobalHeaderCtrl.createNewVendorInvoicing(BPUtility.getEncodedString(vendor.Id));
    	List<Vendor_Invoicing_Header__c> viHeaderList = [select id from Vendor_Invoicing_Header__c];
    	System.assertEquals(viHeaderList.size(), 1);
    }
    
    static testMethod void createPartSaleTypeNewCustomerOrderTest(){
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account acc = TestUtil.createCustomer(false, 'Test Customer', 'test@test.com', 'NY', '5214789630');
    	acc.Is_Customer__c = true;
    	insert acc;
    	BPGlobalHeaderCtrl.createNewCustomerOrder(BPUtility.getEncodedString(acc.Id), BPUtility.getEncodedString('Part Sale'));
    	List<CO_Header__c> coHeaderList = [select id from CO_Header__c];
    	System.assertEquals(coHeaderList.size(), 1);
    }
    
    static testMethod void createUnitDealTypeNewCustomerOrderTest(){
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account acc = TestUtil.createCustomer(false, 'Test Customer', 'test@test.com', 'NY', '5214789630');
    	acc.Is_Customer__c = true;
    	insert acc;
    	BPGlobalHeaderCtrl.createNewCustomerOrder(BPUtility.getEncodedString(acc.Id), BPUtility.getEncodedString('Unit Deal'));
    	Test.startTest();
    	List<CO_Header__c> coHeaderList = [select id from CO_Header__c];
    	List<Deal__c> dealList = [select id from Deal__c];
    	Test.stopTest();
    	System.assertEquals(coHeaderList.size(), 1);
    	System.assertEquals(dealList.size(), 1);
    }
    
    static testMethod void createCashSaleTypeNewCustomerOrderTest(){
    	BPGlobalHeaderCtrl.createNewCustomerOrder(null, BPUtility.getEncodedString('Cash Sale'));
    	Test.startTest();
    	List<CO_Header__c> coHeaderList = [select id,Customer__c from CO_Header__c];
    	Test.stopTest();
    	System.assertEquals(coHeaderList.size(), 1);
    	System.assertEquals(null, coHeaderList[0].Customer__c);
    }
    
    static testMethod void getActiveCustomerOrdersByIdTest(){
    	Account customer = 	TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	CO_Header__c coHeader1 = TestUtil.createCOHeader(false, customer.Id);
    	coHeader1.Order_status__c = 'Open';
    	
    	CO_Header__c coHeader2 = TestUtil.createCOHeader(false, customer.Id);
    	coHeader2.Order_status__c = 'Open';
    	
    	CO_Header__c coHeader3 = TestUtil.createCOHeader(false, customer.Id);
    	coHeader3.Order_status__c = 'Closed';
    	
    	insert new List<CO_Header__c>{coHeader1, coHeader2, coHeader3};
    	
    	String activeOrderWrapperJSON = BPUtility.getDecodedString(BPGlobalHeaderCtrl.getActiveCustomerOrdersById(BPUtility.getEncodedString(customer.Id)));
    	GlobalSearchResultsWrapper wrapperObj = (GlobalSearchResultsWrapper) System.JSON.deserialize(activeOrderWrapperJSON, GlobalSearchResultsWrapper.class);
        
    	System.assertEquals(2, wrapperObj.TotalRecords);
    	List<CO_Header__c> coHeaderList = [Select Id from CO_Header__c];
    	System.assertEquals(3, coHeaderList.size());
    }
    
}