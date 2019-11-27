@isTest 
public class AccSyncCOInvoiceJournalEntryBatchSchTest {
	  
	@testSetup
    private static void setupTestData() {
    	Account customerRec = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test', 'Customer');
    	CO_Header__c coHeaderRec = TestDataFactory.createCoHeader(customerRec.Id);
    	CO_Invoice_Header__c coInvoiceHeaderRec = TestDataFactory.sampleCOInvoiceHeader(coHeaderRec.Id, 'Pending');
    	coInvoiceHeaderRec.availForQBJournalEntrySync__c = true;
    	coInvoiceHeaderRec.Invoice_Status__c = 'Closed';
    	insert coInvoiceHeaderRec;
    	
    	Category__c categoryRec = TestDataFactory.createCategory('Test Category');
    	CO_Invoice_Item__c coInvoiceItemRec = TestDataFactory.createCoInvoiceItem(categoryRec.Id, coInvoiceHeaderRec.Id);
    }
    
    @isTest
	private static void  testSchedule() {
		Test.StartTest();
		List<CO_Invoice_Header__c> coInvoiceHeaderList = [SELECT ID from CO_Invoice_Header__c];
		Set<Id> resultIdSet = (new Map<Id,CO_Invoice_Header__c>(coInvoiceHeaderList)).keySet();
		AccSync_COInvoiceJournalEntry_Batch_Sch schedulerRec = new AccSync_COInvoiceJournalEntry_Batch_Sch(resultIdSet, 2);      
		String scheduleString = '0 38 17 * * ?';
		system.schedule('Test check', scheduleString, schedulerRec);
		Test.stopTest();
		system.assertEquals([SELECT Id from CO_Header__c].size(), 1);
	}
}