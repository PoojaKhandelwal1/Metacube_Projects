@isTest
private class PopulateTotalsOnInvoiceBatchTest {
    @testsetup
    private static void setup(){
    	Account customer = TestDataFactory.createCustomer('Test001', 'Individual', 'Fname', 'Lname');
    	CO_Header__c coHeader = TestDataFactory.createCoHeader(customer.Id);
    	List<CO_Invoice_Header__c> coInvoiceHeaderList = new List<CO_Invoice_Header__c>();
    	for(Integer i = 0; i < 20; i++){
    		CO_Invoice_Header__c coInvoiceHeader = TestDataFactory.sampleCOInvoiceHeader(coHeader.Id, 'Closed');
    		coInvoiceHeader.Checkout_Type__c = 'Deal';
    		coInvoiceHeaderList.add(coInvoiceHeader);
    	}
    	insert coInvoiceHeaderList;
    }
    
    @isTest
    private static void test(){
    	Test.startTest();
    	Id batchId = Database.executeBatch(new PopulateTotalsOnInvoiceBatch());
    	Test.stopTest();
    	List<CO_Invoice_Header__c> coInvoiceHeaderList = new List<CO_Invoice_Header__c>([SELECT Id, Taxable_Total__c FROM CO_Invoice_Header__c]);
    	system.assertEquals(0.00, coInvoiceHeaderList[0].Taxable_Total__c);
    }
}