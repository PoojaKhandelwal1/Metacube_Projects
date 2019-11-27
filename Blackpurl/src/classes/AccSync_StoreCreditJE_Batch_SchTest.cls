/**
 * Author: Rajat Jain
 * Since: June 5, 2018
 * Name: AccSync_StoreCreditJE_Batch_SchTest
 * Description: test Class for AccSync_StoreCreditJE_Batch_SchTest.
**/

@isTest
public with sharing class AccSync_StoreCreditJE_Batch_SchTest {
    static String CRON_EXP = '0 0 0 * * ? *';
    
    @testSetup
    static void setup() {
        TestUtil.setQuickBooksConfigurations(true);
        Account testCustomer = TestUtil.createCustomer(false, 'Test Customer', 'a.b@gmail.com', 'Jaipur', '987456123');
    	testCustomer.Is_Customer__c = true;
    	insert testCustomer;
    	Store_Credit__c storeCreditObj = new Store_Credit__c();
		storeCreditObj.Customer__c = testCustomer.Id;
		storeCreditObj.Amount__c = 100;
		storeCreditObj.Reference__c = 'Ref1';
        insert storeCreditObj;
        system.assertEquals(true, String.isNotBlank(testCustomer.Id));
    }
   
    static testmethod void accSync_ItemCategoryTest() {
        Test.startTest();
        TestUtil.setQuickBooksConfigurations(false);
        Map<Id, Store_Credit__c> storeCreditIdToRecMap = new Map<Id, Store_Credit__c>([Select Id, AccountingId__c FROM Store_Credit__c]);
        
        AccSync_StoreCreditJE_Batch_Scheduler storeCreditSchObj = new AccSync_StoreCreditJE_Batch_Scheduler(storeCreditIdToRecMap.keySet(), 10);
        //system.schedule('AccSync_StoreCreditJE_Batch_Scheduler', CRON_EXP, storeCreditSchObj);
        storeCreditSchObj.execute(null);
        Test.stopTest();
        system.assertEquals('675',[Select AccountingId__c From Store_Credit__c][0].AccountingId__c ); 
    }
}