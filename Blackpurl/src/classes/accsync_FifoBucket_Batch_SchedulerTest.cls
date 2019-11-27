/**
 * Author: Rajat Jain
 * Since: June 5, 2018
 * Name: accsync_FifoBucket_Batch_SchedulerTest test
 * Description: test Class for accsync_FifoBucket_Batch_SchedulerTest.
**/

@isTest
public with sharing class accsync_FifoBucket_Batch_SchedulerTest {
	static String CRON_EXP = '0 0 0 * * ? *';
	
	@testSetup
   	static void setup() {
   		TestUtil.setQuickBooksConfigurations(true);
		Account vendor = TestUtil.createVendor(true, 'Test Vendor', 'test.vendor@gmail.com', 'Jaipur', '123456789');
		Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
   		Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
		system.assertEquals(true, String.isNotBlank(vendor.Id));
	}
   
    static testmethod void accSync_Customer_Batch_SchedulerTest() {
		Test.startTest();
		TestUtil.setQuickBooksConfigurations(false);
		Map<Id, Part_FIFO_Bucket__c> partFIFOIdToRecMap = new Map<Id, Part_FIFO_Bucket__c>([select  AccountingId__c, AccountingResponse__c from Part_FIFO_Bucket__c]);
   		AccSync_FIFOBucket_Batch_Scheduler partFIFOSchObj = new AccSync_FIFOBucket_Batch_Scheduler(partFIFOIdToRecMap.keySet(), 10);
   		//system.schedule('AccSync_FIFOBucket_Batch_Scheduler', CRON_EXP, partFIFOSchObj);
   		partFIFOSchObj.execute(null);
   		Test.stopTest();
   		
        system.assertEquals('675', [select  AccountingId__c from Part_FIFO_Bucket__c][0].AccountingId__c);
	}
}