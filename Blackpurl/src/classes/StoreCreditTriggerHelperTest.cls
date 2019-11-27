/**
 * Author: Richa Mittal
 * updated: Aug 25, 2017
 * Name: StoreCreditTriggerHelperTest
 * Description: It includes Store Credit creation test cases.
**/
@isTest
private class StoreCreditTriggerHelperTest {
	
    static testMethod void addStoreCreditTest() {
    	Account testCustomer = TestUtil.createCustomer(false, 'Test Customer', 'a.b@gmail.com', 'Jaipur', '987456123');
    	testCustomer.Is_Customer__c = true;
    	insert testCustomer;
    	Store_Credit__c storeCreditObj = new Store_Credit__c();
		storeCreditObj.Customer__c = testCustomer.Id;
		storeCreditObj.Amount__c = 100;
		storeCreditObj.Reference__c = 'Ref1';
        Test.startTest();
        insert storeCreditObj;   
        Test.stopTest();
        
        List<Store_Credit__c> storeCreditList = [select Amount__c From Store_Credit__c];
        system.assertEquals(storeCreditList[0].Amount__c, 100);
    }
}