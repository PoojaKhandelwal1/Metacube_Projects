/**
 * Author: Rajat Jain
 * Since: June 5, 2018
 * Name: AccSync_Customer_Batch_SchedulerTest test
 * Description: test Class for AccSync_Customer_Batch_SchedulerTest.
**/

@isTest
public with sharing class AccSync_Customer_Batch_SchedulerTest {
	static String CRON_EXP = '0 0 0 * * ? *';
	
	@testSetup
   	static void setup() {
   		TestUtil.setQuickBooksConfigurations(true);
		Account testCustomer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
		system.assertEquals(true, String.isNotBlank(testCustomer.Id));
	}
   
    static testmethod void accSync_Customer_Batch_SchedulerTest() {
		Test.startTest();
		TestUtil.setQuickBooksConfigurations(false);
		Map<Id, Account> customerIdToRecMap = new Map<Id, Account>([select  AccountingId__c, AccountingResponse__c from Account]);
   		AccSync_Customer_Batch_Scheduler customerSchObj = new AccSync_Customer_Batch_Scheduler(customerIdToRecMap.keySet(), 10);
   		//system.schedule('AccSync_Customer_Batch_Scheduler', CRON_EXP, customerSchObj);
   		customerSchObj.execute(null);
   		Test.stopTest();
   		
        system.assertEquals('149', [select  AccountingId__c from Account][0].AccountingId__c);
	}
}