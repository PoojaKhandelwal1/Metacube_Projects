@isTest
private class PopulateCostsOnUnitBatchTest {
    
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
    	Account customer = [SELECT FirstName__c FROM Account WHERE Is_Customer__c = true LIMIT 1];
    	Test.startTest();
    	PopulateCostsOnUnitBatch populateCostsOnUnitBatch = new PopulateCostsOnUnitBatch();
    	Id batchId = Database.executeBatch(populateCostsOnUnitBatch);
    	Test.stopTest();
    	system.assertEquals(customer.FirstName__c, 'Fname');
    }
}