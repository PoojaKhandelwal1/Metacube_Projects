/**
 * Author: Richa Mittal
 * Since: Dec 18, 2018
 * Name: CashDrawerCtrlTest
 * Description: It includes test methods for CashDrawerCtrl.
**/
@isTest
private class CashDrawerCtrlTest {
	
	@testsetup
	private static void setup() {
		Account customer = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test Fname', 'Test Lname');
		List<Cash_Drawer__c> cashDrawerListToInsert = new List<Cash_Drawer__c>();
        cashDrawerListToInsert.add(TestDataFactory.sampleCashDrawer('Main Cash Drawer'));
        cashDrawerListToInsert.add(TestDataFactory.sampleCashDrawer('Service Counter'));
        insert cashDrawerListToInsert;
        
        IFW_IntegrationConfig__c ifwIntegration = TestUtil.createIFWConfigForXero();
	}
	
	@isTest
	private static void constructorTest() {
		CashDrawerCtrl cashDrawerCtrl = new CashDrawerCtrl();
		CashDrawerCtrl cashDrawerCtrlHomePage = new CashDrawerCtrl(new NewHomePageCtrl());
	}
	
	@isTest
    private static void getAllCashDrawerListTest() {
    	Test.startTest();
        String result = BPUtility.getDecodedString(CashDrawerCtrl.getAllCashDrawerList());
        List<CashDrawerWrapper> resultList = (List<CashDrawerWrapper>) System.JSON.deserialize(result, List<CashDrawerWrapper>.class);
        system.assertEquals(resultList.size(), 2);
        Test.stopTest();
    }
    
    @isTest
    private static void saveCashDrawerTest() {
    	Test.startTest();
        Cash_Drawer__c cashDrawerRec = TestDataFactory.sampleCashDrawer('Test Cash Drawer');
        CashDrawerWrapper cashDrawerWrapper = new CashDrawerWrapper(cashDrawerRec);
        String cashDrawerJSON = BPUtility.getEncodedString(System.JSON.serialize(cashDrawerWrapper));
        String result = BPUtility.getDecodedString(CashDrawerCtrl.saveCashDrawer(cashDrawerJSON));
        ResponseWrapper responseObject = (ResponseWrapper)System.JSON.deserialize(result, ResponseWrapper.class);
        system.assertEquals(responseObject.response, 'success');
        Test.stopTest();
    }
    
    @isTest
    private static void saveDuplicateCashDrawerTest() {
    	Test.startTest();
        Cash_Drawer__c cashDrawerRecDup = TestDataFactory.sampleCashDrawer('Main Cash Drawer');
        CashDrawerWrapper cashDrawerWrapperDup = new CashDrawerWrapper(cashDrawerRecDup);
        String cashDrawerJSONDup = BPUtility.getEncodedString(System.JSON.serialize(cashDrawerWrapperDup));
        String result = BPUtility.getDecodedString(CashDrawerCtrl.saveCashDrawer(cashDrawerJSONDup));
        ResponseWrapper responseObject = (ResponseWrapper)System.JSON.deserialize(result, ResponseWrapper.class);
        system.assertEquals(responseObject.responseStatus, 'error');
        Test.stopTest();
    }
    
    @isTest
    private static void saveInactiveCashDrawerTest() {
    	Test.startTest();
        Cash_Drawer__c cashDrawer = [SELECT Id FROM Cash_Drawer__c LIMIT 1];
        cashDrawer.Active__c = false;
        CashDrawerWrapper cashDrawerWrapperToUpdate = new CashDrawerWrapper(cashDrawer);
        String cashDrawerJSONToUpdate = BPUtility.getEncodedString(System.JSON.serialize(cashDrawerWrapperToUpdate));
        String result = BPUtility.getDecodedString(CashDrawerCtrl.saveCashDrawer(cashDrawerJSONToUpdate));
        ResponseWrapper responseObject = (ResponseWrapper)System.JSON.deserialize(result, ResponseWrapper.class);
        system.assertEquals(responseObject.responseStatus, 'success');
        Test.stopTest();
    }
    
    @isTest
    private static void saveCashDrawerCannotBeInactiveTest() {
    	Test.startTest();
    	Cash_Drawer__c cashDrawerRec = [SELECT Name, Active__c FROM Cash_Drawer__c LIMIT 1];
    	Cash_Reconciliation__c cashReconciliation = TestDataFactory.createCashReconciliation('Unreconciled');
    	Cash_Drawer_Reconciliation__c cashDrawerReconciliation = TestDataFactory.createCashDrawerReconciliation(cashDrawerRec.Id, cashReconciliation.Id);
    	Cash_Reconciliation_Payment__c cashReconciliationPayment = TestDataFactory.createCashReconciliationPayment(cashDrawerReconciliation.Id, cashReconciliation.Id);
    	cashDrawerRec.Active__c = false;
    	CashDrawerWrapper cashDrawerWrapperToUpdate = new CashDrawerWrapper(cashDrawerRec);
        String cashDrawerJSONToUpdate = BPUtility.getEncodedString(System.JSON.serialize(cashDrawerWrapperToUpdate));
        String result = BPUtility.getDecodedString(CashDrawerCtrl.saveCashDrawer(cashDrawerJSONToUpdate));
        ResponseWrapper responseObject = (ResponseWrapper)System.JSON.deserialize(result, ResponseWrapper.class);
        system.assertEquals(responseObject.responseStatus, 'error');
    	Test.stopTest();
    }
    
    @isTest
    private static void deleteCashDrawerTest() {
    	Test.startTest();
        Cash_Drawer__c cashDrawerRec = [SELECT Id FROM Cash_Drawer__c LIMIT 1];
        String cashDrawerId = BPUtility.getEncodedString(cashDrawerRec.Id);
        String result = BPUtility.getDecodedString(CashDrawerCtrl.deleteCashDrawer(cashDrawerId));
        ResponseWrapper responseObject = (ResponseWrapper)System.JSON.deserialize(result, ResponseWrapper.class);
        system.assertEquals(responseObject.response, 'success');
        Test.stopTest();
    }
    
    @isTest
    private static void isCashDrawerCanBeDeletedTest() {
    	Test.startTest();
    	Cash_Drawer__c cashDrawerRec = [SELECT Id FROM Cash_Drawer__c LIMIT 1];
    	String cashDrawerRecId = BPUtility.getEncodedString(cashDrawerRec.Id);
    	String result = BPUtility.getDecodedString(CashDrawerCtrl.isCashDrawerCanBeDeleted(cashDrawerRecId));
    	system.assertEquals(result, '{"isDeleteAvailable" : true}');
    	Test.stopTest();
    }
    
    @isTest
    private static void isCashDrawerCanNotBeDeletedTest(){
    	Test.startTest();
    	Cash_Drawer__c cashDrawer = [SELECT Id FROM Cash_Drawer__c LIMIT 1];
    	Account customer = [SELECT Id FROM Account WHERE Is_Customer__c = true LIMIT 1];
    	CO_Header__c coHeader = TestDataFactory.createCoHeader(customer.Id);
    	CO_Invoice_Header__c coInvoiceHeader = TestDataFactory.createCOInvoiceHeader(coHeader.Id, 'Active');
    	CO_Invoice_Payment__C coInvoicePayment = TestDataFactory.createCOInvoicePayment(cashDrawer.Id, coInvoiceHeader.Id);
    	CO_Deposit__C coDeposit = TestDataFactory.createCODeposit(coHeader.Id, cashDrawer.Id, 'Visa', 100);
    	String cashDrawerRecId = BPUtility.getEncodedString(cashDrawer.Id);
    	String result = BPUtility.getDecodedString(CashDrawerCtrl.isCashDrawerCanBeDeleted(cashDrawerRecId));
    	system.assertEquals(result, '{"isDeleteAvailable" : false}');
    	Test.stopTest();
    }
    
    @isTest
    private static void isCashDrawerCanBeInactiveTest() {
    	Test.startTest();
    	Cash_Drawer__c cashDrawer = [SELECT Id, Name, Active__c FROM Cash_Drawer__c LIMIT 1];
    	CashDrawerWrapper cashDrawerWrapper = new CashDrawerWrapper(cashDrawer);
    	String cashDrawerWrapperJSON = BPUtility.getEncodedString(System.JSON.serialize(cashDrawerWrapper));
    	String result = BPUtility.getDecodedString(CashDrawerCtrl.isCashDrawerCanBeInactive(cashDrawerWrapperJSON));
    	system.assertEquals(result, '{"isInactiveAllowed" : true}');
    	Test.stopTest();
    }
    
    @isTest
    private static void isCashDrawerCanNotBeInactiveTest() {
    	Test.startTest();
    	Cash_Drawer__c cashDrawer = [SELECT Id, Name, Active__c FROM Cash_Drawer__c LIMIT 1];
    	Cash_Reconciliation__c cashReconciliation = TestDataFactory.createCashReconciliation('Unreconciled');
    	Cash_Drawer_Reconciliation__c cashDrawerReconciliation = TestDataFactory.createCashDrawerReconciliation(cashDrawer.Id, cashReconciliation.Id);
    	Cash_Reconciliation_Payment__c cashReconciliationPayment = TestDataFactory.createCashReconciliationPayment(cashDrawerReconciliation.Id, cashReconciliation.Id);
    	CashDrawerWrapper cashDrawerWrapper = new CashDrawerWrapper(cashDrawer);
    	String cashDrawerWrapperJSON = BPUtility.getEncodedString(System.JSON.serialize(cashDrawerWrapper));
    	String result = BPUtility.getDecodedString(CashDrawerCtrl.isCashDrawerCanBeInactive(cashDrawerWrapperJSON));
    	system.assertEquals(result, '{"isInactiveAllowed" : false}');
    	Test.stopTest();
    }
}