/**
 * Author: Rajat Jain
 * Since: June 5, 2018
 * Name: AccSync_CODepositJE_Batch_SchedulerTest test
 * Description: test Class for AccSync_CODepositJE_Batch_SchedulerTest.
**/

@isTest
public with sharing class AccSync_CODepositJE_Batch_SchedulerTest {
	static String CRON_EXP = '0 0 0 * * ? *';
	
	
	@testSetup
   	static void setup() {
   		TestUtil.setQuickBooksConfigurations(true);
		Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
		CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader.Id, 'Cash', 500);
		system.assertEquals(true, String.isNotBlank(coDeposit.Id));
	}
   
    static testmethod void accSync_CODepositJETest() {
		Test.startTest();
		TestUtil.setQuickBooksConfigurations(false);
		Map<Id, CO_Deposit__c> coDepositIdToRecMap = new Map<Id, CO_Deposit__c>([Select Id, availForQBJournalEntrySync__c FROM CO_Deposit__c]);
   		//system.assertEquals(true, coDepositIdToRecMap.values()[0].availForQBJournalEntrySync__c);
   		
   		//TestUtil.setQuickBooksConfigurations(false);
   		AccSync_CODepositJE_Batch_Scheduler coDepositJEObj = new AccSync_CODepositJE_Batch_Scheduler(coDepositIdToRecMap.keySet(), 10);
   		coDepositJEObj.execute(null);
   		//system.schedule('AccSync_CODepositJE_Batch_SchedulerTest', CRON_EXP, coDepositJEObj);
   		Test.stopTest();
   		
        system.assertEquals(false, [Select Id, availForQBJournalEntrySync__c FROM CO_Deposit__c][0].availForQBJournalEntrySync__c);
	}
}