@isTest 
public class ReportSchedulerTest {
	
	@testSetup
    private static void setupTestData() {
    	List<Account> vendorList = new List<Account>();
    	List<Account> customerList = new List<Account>();
    	for(Integer i = 0; i < 5; i++) {
    		vendorList.add(TestDataFactory.sampleVendor('Test Vendor' + i));
    	}
    	insert vendorList;
    	for(Integer i = 0; i < 5; i++) {
    		customerList.add(TestDataFactory.sampleCustomer('Test Customer' + i, 'Business', 'Test', 'Customer' + i));
    	}
    	insert customerList;
    	
    	Reporting__c reportingRec = TestDataFactory.sampleReporting();
    	reportingRec.Reporting_Objects__c = 'Customer';
    	reportingRec.Receipient_Email__c = 'somi.vishnoi@metacube.com';
    	insert reportingRec;
    }
    
    @isTest
	private static void  testSchedule() {
		Test.StartTest();
		ReportScheduler reportSchedulerRec = new ReportScheduler();      
		String scheduleString = '0 38 17 * * ?';
		system.schedule('Test check', scheduleString, reportSchedulerRec);
		Test.stopTest();
		system.assertEquals([SELECT Id from Account].size(), 10);
	}
}