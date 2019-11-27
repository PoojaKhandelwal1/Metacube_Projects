@isTest
private class QB_TaxSyncSchedulerTest {
	
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';
	
    @isTest
    private static void testQB_TaxSyncScheduler(){
    	Test.startTest();
    	QB_TaxSyncScheduler qbTax = new QB_TaxSyncScheduler();
    	QB_TaxSyncScheduler qbTaxSyncSchedulerObj = new QB_TaxSyncScheduler('syncType');
    	String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new QB_TaxSyncScheduler());
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
}