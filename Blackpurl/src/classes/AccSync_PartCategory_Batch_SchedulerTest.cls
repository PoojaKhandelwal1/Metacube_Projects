@isTest
private class AccSync_PartCategory_Batch_SchedulerTest {
	
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';
	
    @testsetup
    private static void setup(){
    	Account vendor = TestDataFactory.createVendor('Test Vendor');
    	Category__c categoryRec = TestDataFactory.createCategory('category001');
    	Part__c part = TestDataFactory.createPart(vendor.Id,  10, 20, 50, 100, 100, categoryRec.Id);
    }
    
    @isTest
    private static void test(){
    	Test.startTest();
    	Part__c part = [SELECT Id FROM Part__c LIMIT 1];
    	Set<Id> recordIdSet = new Set<Id>();
    	recordIdSet.add(part.Id);
    	String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new AccSync_PartCategory_Batch_Scheduler(recordIdSet, 1));
    	Test.stopTest();
    	system.assertEquals(1, [SELECT Id FROM Account].size());
    }
}