/**
 * Author: Rajat Jain
 * Since: June 5, 2018
 * Name: AccSync_COInvoiceJE_Batch_SchedulerTest 
 * Description: test Class for AccSync_COInvoiceJE_Batch_SchedulerTest.
**/

@isTest
public with sharing class AccSync_COInvoiceJE_Batch_SchedulerTest {
	static String CRON_EXP = '0 0 0 * * ? *';
	
	@testSetup
   	static void setup() {
   		TestUtil.setQuickBooksConfigurations(true); 
   		Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
   		Account vendor = TestUtil.createVendor(true, 'Test Vendor', 'test.vendor@gmail.com', 'Jaipur', '123456789');
		Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
		Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
   		Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
		CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
	    CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 20);
	    system.assertEquals(true, String.isNotBlank(customer.Id));
   	} 
   	
   	static testmethod void accSyncCustomerInvoiceSchedulerTest() {
		Test.startTest();
		TestUtil.setQuickBooksConfigurations(false);
		list<CO_Invoice_Header__c> coInvoiceHeaderlist = [select  Status__c, Total_Payment__c from CO_Invoice_Header__c];
	    list<CO_Invoice_Item__c> COInvoiceItems = [select Category__c, CO_Line_Item__c, isActive__c, Item_Category_Code__c, Item_ID__c, Item_Type__c, Price__c, Qty__c from CO_Invoice_Item__c];
	    list<CO_Header__c> coHeaderIdlist = [select Id from CO_Header__c];
	    String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaderlist[0].Id)));
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedorderAction(BPUtility.getEncodedString(COInvoiceItemJSON), BPUtility.getEncodedString(coHeaderIdlist[0].Id), BPUtility.getEncodedString('Customer')));
		
		Map<Id, CO_Invoice_Header__c> coInvoiceHeaderIdToRecMap = new Map<Id, CO_Invoice_Header__c>([select Id,AccountingId__c from CO_Invoice_Header__c]);
	    AccSync_COInvoiceJE_Batch_Scheduler customerInvoiceJEObj = new AccSync_COInvoiceJE_Batch_Scheduler();
	    customerInvoiceJEObj.execute(null);
   		Test.stopTest();
	    system.assertEquals('675', [select  Id, AccountingId__c, JournalEntryAccountingId__c from CO_Invoice_Header__c ][0].JournalEntryAccountingId__c);
	} 
}