@isTest
private class COPaymentServiceTest {
    @testsetup
    private static void setup(){
    	Account customer = TestDataFactory.createCustomer('Test001', 'Individual', 'Fname', 'Lname');
		CO_Header__c coHeader =  TestDataFactory.createCOHeader(customer.Id);
		Cash_Drawer__c cashDrawerRec1 = TestDataFactory.createCashDrawer('Main Cash Drawer');
		Cash_Drawer__c cashDrawerRec2 = TestDataFactory.createCashDrawer('Test Cash Drawer');
		CO_Invoice_Header__c coInvoiceHeaderRec = TestDataFactory.createCOInvoiceHeader(coHeader.Id, 'Active');
    	CO_Invoice_Payment__c coInvoicePaymentRec1 = TestDataFactory.createCOInvoicePayment(cashDrawerRec1.Id, coInvoiceHeaderRec.Id);
    	CO_Invoice_Payment__c coInvoicePaymentRec2 = TestDataFactory.createCOInvoicePayment(cashDrawerRec2.Id, coInvoiceHeaderRec.Id);
    	coInvoicePaymentRec1.Reverse_Link__c = coInvoicePaymentRec2.Id;
    	update coInvoicePaymentRec1;
    }
    
    @isTest
    private static void testCreateCOPaymentRecord(){
    	Test.startTest();
		String query = 'SELECT ';  
    	for(String fieldsName : COInvoicePayment.fieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
        	query += fieldsName + ', ';  
    	}
    	query = query.substring(0, query.length()-2);
    	query += ' FROM CO_Invoice_Payment__c LIMIT 1';
    	CO_Invoice_Payment__c coInvoicePaymentRec = Database.query(query);
    	
    	CO_Invoice_Header__c coInvoiceHeaderRec = [SELECT Id FROM CO_Invoice_Header__c LIMIT 1];
    	
    	COInvoicePayment coInvoicePaymentObj = new COInvoicePayment(coInvoicePaymentRec);
    	CO_Invoice_Payment__c result = COPaymentService.createCOPaymentRecord(coInvoicePaymentObj);
    	system.assertEquals(result.CO_Invoice_Header__c, coInvoiceHeaderRec.Id);
    	Test.stopTest();
    }
}