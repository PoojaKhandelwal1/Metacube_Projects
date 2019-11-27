/**
 * Author: Nikhil Kumar Srivastava
 * Since: April 16, 2019
 * Name: AccountingCustomerBatchSchedulerTest
 * Description: test Class for AccountingCustomerBatchScheduler.
**/

@isTest
public with sharing  class AccountingCustomerBatchSchedulerTest {
	
	@testSetup
    private static void setupTestData() { 
       	TestUtil.createIFWConfigForXero();
       	Account testCustomer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
    	system.assertEquals(true, String.isNotBlank(testCustomer.Id));
    }
    
	static testmethod void AccountingCustomerBatchSchedulerTest() { 
		List<IFW_IntegrationConfig__c> IFWConfigObj = [Select Id from IFW_IntegrationConfig__c];
		IFW_IntegrationConfigItem__c IFWConfigItemObj = TestUtil.createIFWConfigItemForXero('Contacts' , IFWConfigObj[0].Id);
		List<Account> accList = [Select Id,Is_Customer__c from Account where Is_Customer__c = true Limit 1];
		system.assertEquals(1,accList.size());
		system.assertEquals(true,accList[0].Is_Customer__c);
		test.startTest();
		XeroScriptUtil.syncCustomers(25,60,25);
		test.stopTest();
	 }
}