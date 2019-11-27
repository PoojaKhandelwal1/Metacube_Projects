/**
 * Author: Richa Mittal
 * Since: Jan 3, 2017
 * Name: AccSync_JournalEntry_Batch_Test test
 * Description: batch test Class of Journal Entry sync to QuickBooks.
**/
@isTest
public with sharing class AccSync_JournalEntry_Batch_Test {
	@testSetup
    static void setup() {
        QuickBooks_Configurations__c qbConfig = new QuickBooks_Configurations__c();
        qbConfig.Consumer_Key__c = 'qyprdFawAAiD3SLud6d5RvREaVOoAn';
        qbConfig.End_Point_URL__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        qbConfig.Consumer_Secret__c = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr';
        qbConfig.OAuth_Token__c = 'qyprdAVMsASHRkSalO3JwbyPdnzistYmRRfJBFbAxL6AOlDj';
        qbConfig.OAuth_Token_Secret__c = 'TN3csfs1tTSX77SW5ysYkcVxJo1gIq8Lq3wusQKO';
        qbConfig.Company_Id__c = '123145730762509';
        qbConfig.Enable_QuickBooks__c = true;   
        insert qbConfig;
        
        insert new General_Configurations__c(Enable_QB_Accounting__c = true);
        system.assert(true,true);
    }
	
	static testmethod void testPartFIFOBucketJournalEntry() {
		Test.startTest();
		Account vendor = TestUtil.createVendor(true, 'Test Vendor', 'test.vendor@gmail.com', 'Jaipur', '123456789');
		Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
   		Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
   		Test.stopTest();
   		
   		List<Part_FIFO_Bucket__c> testPartFIFOBuckets = [select Name, AccountingId__c from Part_FIFO_Bucket__c where Part__c = :part.Id];
   		PartFIFOBucketTriggerHelper.preventOnAccountingSync = false;
        testPartFIFOBuckets[0].SyncToken__c = '1';
        update testPartFIFOBuckets;
        List<Part_FIFO_Bucket__c> updatedTestPartFIFOBuckets = [select Name, AccountingId__c, SyncToken__c from Part_FIFO_Bucket__c where Part__c = :part.Id];
   		system.assertEquals('675', testPartFIFOBuckets[0].AccountingId__c);
	}
    
    static testmethod void testCODepositJournalEntry() {
		Test.startTest();
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec = TestUtil.createCOLineItem(true, coHeader1.Id, part.Id, 50);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader1.Id, 'Debit', 500);
   		Test.stopTest();
   		
   		List<CO_Deposit__c> testCODeposits = [select Name, AccountingIdForJournalEntry__c from CO_Deposit__c where CO_Header__c = :coHeader1.Id];
        CODepositTriggerHelper.preventOnAccountingSync = false;
        testCODeposits[0].SyncTokenForJournalEntry__c = '1';
        update testCODeposits;
        List<CO_Deposit__c> updatedtestCODeposits = [select Name, AccountingIdForJournalEntry__c, SyncTokenForJournalEntry__c from CO_Deposit__c where CO_Header__c = :coHeader1.Id];
   		system.assertEquals('675', testCODeposits[0].AccountingIdForJournalEntry__c);
	}
    
    static testmethod void testCOInvoicePaymentJournalEntry() {
		Test.startTest();
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec = TestUtil.createCOLineItem(true, coHeader1.Id, part.Id, 50);
        
        
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader1.Id, 'Active');
        CO_Invoice_Payment__c coinvoicepayment1  = TestUtil.createCOInvoicePayment(true, coinvoiceHeader1.Id );
        
   		Test.stopTest();
   		
   		List<CO_Invoice_Payment__c> testCOInvoicePayments = [select Name, AccountingIdForJournalEntry__c from CO_Invoice_Payment__c where CO_Invoice_Header__c = :coinvoiceHeader1.Id];
        COInvoicePaymentTriggerHelper.preventOnAccountingSync = false;
        testCOInvoicePayments[0].SyncTokenForJournalEntry__c = '1';
        update testCOInvoicePayments;
        List<CO_Invoice_Payment__c> updatedtestCOInvoicePayments = [select Name, AccountingIdForJournalEntry__c, SyncTokenForJournalEntry__c from CO_Invoice_Payment__c where CO_Invoice_Header__c = :coinvoiceHeader1.Id];
   		system.assertEquals('675', testCOInvoicePayments[0].AccountingIdForJournalEntry__c);
	}
    
}