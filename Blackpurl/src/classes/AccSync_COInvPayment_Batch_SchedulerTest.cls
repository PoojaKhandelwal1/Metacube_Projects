/**
 * Author: Rajat Jain
 * Since: June 5, 2018
 * Name: AccSync_CODepositJE_Batch_SchedulerTest test
 * Description: test Class for AccSync_CODepositJE_Batch_SchedulerTest.
**/

@isTest
public with sharing class AccSync_COInvPayment_Batch_SchedulerTest {
	static String CRON_EXP = '0 0 0 * * ? *';
	
	@testSetup
   	static void setup() {
   		TestUtil.setQuickBooksConfigurations(true);
		Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec = TestUtil.createCOLineItem(true, coHeader1.Id, part.Id, 50);
        CO_Invoice_Header__c coinvoiceHeader = TestUtil.createCOInvoiceHeader(true, coHeader1.Id, 'Active');
        CO_Invoice_Payment__c coinvoicepayment  = TestUtil.createCOInvoicePayment(true, coinvoiceHeader.Id );
        
		system.assertEquals(true, String.isNotBlank(vendor.Id));
	}
   
    static testmethod void accSync_COInvPaymentTest() {
		Test.startTest();
		TestUtil.setQuickBooksConfigurations(false);
		Map<Id, CO_Invoice_Payment__c> cOInvoicePaymentsIdToRecMap = new Map<Id, CO_Invoice_Payment__c>([select Name, AccountingIdForJournalEntry__c from CO_Invoice_Payment__c]);
   		AccSync_COInvoicePayment_Batch_Scheduler coInvoicePaymentObj = new AccSync_COInvoicePayment_Batch_Scheduler(cOInvoicePaymentsIdToRecMap.keySet(), 10);
   		coInvoicePaymentObj.execute(null);
   		
   		Test.stopTest();
   		
        system.assertEquals('675', [select Id, AccountingIdForJournalEntry__c from CO_Invoice_Payment__c][0].AccountingIdForJournalEntry__c);
	}
}