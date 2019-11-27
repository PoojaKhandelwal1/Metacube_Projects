@isTest 
public class ReportsToEmailTest {
	
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
    private static void orgInfoTest() {
    	system.assertEquals(ReportsToEmail.orgInfo(), [Select Name From Organization LIMIT 1].Name);
    }
    
    @isTest
    private static void getOrgReportsTest() {
    	ReportsToEmail.getOrgReports();
    	system.assertEquals([SELECT Id from Account].size(), 10);
    }
}