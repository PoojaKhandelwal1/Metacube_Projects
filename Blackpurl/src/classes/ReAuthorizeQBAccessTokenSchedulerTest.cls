@isTest 
public class ReAuthorizeQBAccessTokenSchedulerTest {
	
	@testSetup
    private static void setupTestData() {
    	BP_Configurations__c bpConfig = TestDataFactory.sampleBpConfiguration();
    	bpConfig.Support_Email_Recipient__c = 'test@gmail.com';
    	insert bpConfig;
    	QuickBooks_Configurations__c qbConfig = TestDataFactory.sampleQBConfig();
    	qbConfig.Access_Token_Generation_Date__c = Date.newInstance(2018,10,15);
    	insert qbConfig;
    }
    
    @isTest
	public static void  testSchedule() {
		Test.StartTest();
		ReAuthorizeQBAccessTokenScheduler schedulerObj = new ReAuthorizeQBAccessTokenScheduler();      
		String sch = '0 38 17 * * ?';
		system.schedule('Test check', sch, schedulerObj);
		Test.stopTest();
		QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getInstance();
		System.assertNotEquals(qbConfig, null);
	}
}