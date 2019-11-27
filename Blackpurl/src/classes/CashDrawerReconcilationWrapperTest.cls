@isTest
private class CashDrawerReconcilationWrapperTest {
    @testsetup
    private static void setup(){
   		Account customer = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test Fname', 'Test Lname');
   		CO_Header__c coHeader =  TestDataFactory.createCOHeader(customer.Id);
   		Cash_Drawer__c cashDrawerRec = TestDataFactory.createCashDrawer('Main Cash Drawer');
        Cash_Reconciliation__c cashReconciliationRec = TestDataFactory.createCashReconciliation('Reconciled');
        Cash_Drawer_Reconciliation__c cashDrawerReconciliationRec = TestDataFactory.createCashDrawerReconciliation(cashDrawerRec.Id, cashReconciliationRec.Id); 
        CO_Deposit__c coDeposit = TestDataFactory.createCODeposit(coHeader.Id, cashDrawerRec.Id, '	Visa', 100);  
        CO_Invoice_Header__c coInvoiceHeaderRec = TestDataFactory.createCOInvoiceHeader(coHeader.Id, 'Active');
        CO_Invoice_Payment__c coInvoicePaymentRec = TestDataFactory.createCOInvoicePayment(cashDrawerRec.Id, coInvoiceHeaderRec.Id);
    } 
   
    @isTest
    private static void testCashDrawerReconcilationWrapper(){
   		Test.startTest();
   		
   		String query = 'SELECT ';  
    	for(String fieldsName : CashDrawerReconcilationWrapper.getCashDrawerReconciliationFieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
        	query += fieldsName + ', ';  
    	}
    	query = query.substring(0, query.length()-2);
    	query += ' FROM Cash_Drawer_Reconciliation__c LIMIT 1';
    	Cash_Drawer_Reconciliation__c cashDrawerReconciliationRec = Database.query(query);
		
		Account customer = [SELECT Id FROM Account WHERE Is_customer__c = true LIMIT 1];
		CO_Header__c coHeader = [SELECT Id FROM CO_Header__c LIMIT 1];
		Cash_Drawer__c cashDrawerRec = [SELECT Name FROM Cash_Drawer__c LIMIT 1];
        
    	List<Reconciliation_Payment__mdt> paymentTypeList = new List<Reconciliation_Payment__mdt>();
    	paymentTypeList.add(TestDataFactory.sampleReconciliationPayment('Cash/Credit'));
    	paymentTypeList.add(TestDataFactory.sampleReconciliationPayment('Other'));
    	
    	CashDrawerReconcilationWrapper cashDrawerReconcilationWrapper = new CashDrawerReconcilationWrapper(cashDrawerRec, cashDrawerReconciliationRec, paymentTypeList, true);
    	system.assertEquals(cashDrawerReconcilationWrapper.Id, cashDrawerReconciliationRec.Id);
    	
   		Test.stopTest();	
    }
}