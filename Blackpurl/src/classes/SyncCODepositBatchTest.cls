/**
 * Author: Dhirendra Singh Sisodia
 * Name: SyncCODepositBatchTest 
 * Description: Test class for SyncCODepositBatch.
**/
@isTest
public with sharing class SyncCODepositBatchTest {
    @testSetup
    private static void setupTestData() { 
       	TestUtil.createIFWConfigForXero();
	   	List<IFW_IntegrationConfig__c> IFWConfigObj = [Select Id from IFW_IntegrationConfig__c];
		IFW_IntegrationConfigItem__c IFWConfigItemObj = TestUtil.createIFWConfigItemForXero('Journal Entry' , IFWConfigObj[0].Id);
		Account customer = TestUtil.createCustomer(true, 'testcustomer', 'customer@gmail.com', 'Jaipur', '8058704475');
	    Account vendor = TestUtil.createVendor(true, 'Test Vendor');
	    Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
	    
	    Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
	    Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
	    
	    CO_Header__c coHeader1 = TestUtil.createCOHeader(true, customer.Id);
	    
	    List<Part__c> partList = new List<Part__c> ();
	    Part__c partObject1 = TestUtil.createPart(true, '101', vendor.id, 'test1', testCategory.id, 200, 200, 100, 20, 20);
	    partList.add(partObject1);
	    List<String> partidList = new List<String>{partObject1.id};
	    
	    CO_Line_Item__c coLineItemRec = TestUtil.createCOLineItem(true, coHeader1.Id, partObject1.Id, 50);
    }
    
    static testMethod void createCODepositStoreCreditTest() {
       	Test.startTest();
       	List<CO_Header__c> coHeaderObj = [Select Id from CO_Header__c limit 1];
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(false, coHeaderObj[0].Id, 'Store Credit', 500);
        coDeposit.Reverse_Link__c = 'a0Af400000IulYzEAJ';
        insert coDeposit;
        Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
   		Test.stopTest();
   		
   		List<CO_Deposit__c> coDepositRes = [Select Id,Name,Xero_Accounting_Id__c,Available_For_Xero_Sync__c from CO_Deposit__c Limit 1];
       	system.assertEquals(coDepositRes[0].Available_For_Xero_Sync__c,false);
       	system.assertEquals(coDepositRes[0].Xero_Accounting_Id__c,'6d037ca7-113b-4919-b4dd-22432503e76a');
	}
	
	static testMethod void createCODepositDirectDepositTest() {
       	Test.startTest();
       	List<CO_Header__c> coHeaderObj = [Select Id from CO_Header__c limit 1];
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeaderObj[0].Id, 'Direct Deposit', -200);
        Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
   		Test.stopTest();
   		
   		List<CO_Deposit__c> coDepositRes = [Select Id,Name,Xero_Accounting_Id__c,Available_For_Xero_Sync__c from CO_Deposit__c Limit 1];
       	system.assertEquals(coDepositRes[0].Available_For_Xero_Sync__c,false);
       	system.assertEquals(coDepositRes[0].Xero_Accounting_Id__c,'6d037ca7-113b-4919-b4dd-22432503e76a');
	}
	
	static testMethod void createCODepositFinancedTest() {
       	Test.startTest();
       	List<CO_Header__c> coHeaderObj = [Select Id from CO_Header__c limit 1];
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeaderObj[0].Id, 'Financed', 500);
        Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
   		Test.stopTest();
   		
   		List<CO_Deposit__c> coDepositRes = [Select Id,Name,Xero_Accounting_Id__c,Available_For_Xero_Sync__c from CO_Deposit__c Limit 1];
       	system.assertEquals(coDepositRes[0].Available_For_Xero_Sync__c,false);
       	system.assertEquals(coDepositRes[0].Xero_Accounting_Id__c,'6d037ca7-113b-4919-b4dd-22432503e76a');
	}
	
	static testMethod void createCODepositInvoiceTest() {
       	Test.startTest();
       	List<CO_Header__c> coHeaderObj = [Select Id from CO_Header__c limit 1];
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeaderObj[0].Id, 'Invoice', 500);
        Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
   		Test.stopTest();
   		
   		List<CO_Deposit__c> coDepositRes = [Select Id,Name,Xero_Accounting_Id__c,Available_For_Xero_Sync__c from CO_Deposit__c Limit 1];
       	system.assertEquals(coDepositRes[0].Available_For_Xero_Sync__c,false);
       	system.assertEquals(coDepositRes[0].Xero_Accounting_Id__c,'6d037ca7-113b-4919-b4dd-22432503e76a');
	}
	
	static testMethod void createCODepositCashTest() {
       	Test.startTest();
       	List<CO_Header__c> coHeaderObj = [Select Id from CO_Header__c limit 1];
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeaderObj[0].Id, 'Cash', 500);
        Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
   		Test.stopTest();
   		
   		List<CO_Deposit__c> coDepositRes = [Select Id,Name,Xero_Accounting_Id__c,Available_For_Xero_Sync__c from CO_Deposit__c Limit 1];
       	system.assertEquals(coDepositRes[0].Available_For_Xero_Sync__c,false);
       	system.assertEquals(coDepositRes[0].Xero_Accounting_Id__c,'6d037ca7-113b-4919-b4dd-22432503e76a');
	}
}