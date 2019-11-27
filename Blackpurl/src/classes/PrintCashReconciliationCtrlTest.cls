@isTest
private class PrintCashReconciliationCtrlTest {
    @testsetup
    private static void setup(){
    	Account customer = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test Fname', 'Test Lname');
		List<Cash_Drawer__c> cashDrawerListToInsert = new List<Cash_Drawer__c>();
        cashDrawerListToInsert.add(TestDataFactory.sampleCashDrawer('Main Cash Drawer'));
        cashDrawerListToInsert.add(TestDataFactory.sampleCashDrawer('Service Counter'));
        insert cashDrawerListToInsert;
    }
    
    @isTest
    private static void testGetCashReconciliationDetails(){
    	Test.startTest();
    	PrintCashReconciliationCtrl printCashReconciliationCtrlObj = new PrintCashReconciliationCtrl();
    	PrintCashReconciliationCtrl printCashReconciliationCtrlObjWithHomePage = new PrintCashReconciliationCtrl(new NewHomePageCtrl());
    	Cash_Drawer__c cashDrawerRec = [SELECT Id FROM Cash_Drawer__c LIMIT 1];
    	String result = BPUtility.getDecodedString(PrintCashReconciliationCtrl.getCashReconciliationDetails(BPUtility.getEncodedString('16/03/2019'), BPUtility.getEncodedString(cashDrawerRec.Id)));
    	PrintCashReconciliationCtrl.CashReconciliationDetail cashReconciliationDetail =  (PrintCashReconciliationCtrl.CashReconciliationDetail)json.deserialize(result, PrintCashReconciliationCtrl.CashReconciliationDetail.class);
    	system.assertEquals('Friday 03 April 2020', cashReconciliationDetail.ReconciliationDate);
    	Test.stopTest();
    }
}