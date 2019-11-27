@isTest 
public class ScheduleQBSyncTest {
	
	@testSetup
    private static void setupTestData() {
    	List<Category__c> categoryList = new List<Category__c>();
    	List<Sales_Tax_Item__c> salesTexItemList = new List<Sales_Tax_Item__c>();
    	for(Integer i = 0; i < 10; i++) {
    		categoryList.add(TestDataFactory.sampleCategory('Test Category' + i));
    	}
    	insert categoryList;
    	for(Integer i = 0; i < 10; i++) {
    		salesTexItemList.add(TestDataFactory.sampleSalesTaxItem('Test tax' + i, 1, 'Test form' + i, categoryList[i].Id, true));
    	}
    	insert salesTexItemList;
    	
    	QuickBooks_Configurations__c qbConfig = TestDataFactory.sampleQBConfig();
    	qbConfig.Tax_Agency_Name__c = 'Test Agency';
    	qbConfig.Tax_Agency_Id__c = '123456';
    	insert qbConfig;
    }
    
    @isTest
	private static void  testschedule() {
		Test.StartTest();
		ScheduleQBSync scheduleQBSyncRec = new ScheduleQBSync();      
		String scheduleString = '0 38 17 * * ?';
		system.schedule('Test check', scheduleString, scheduleQBSyncRec);
		Test.stopTest();
		QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getInstance();
		system.assertEquals('Test Agency', qbConfig.Tax_Agency_Name__c);
	}
	
	@isTest
	private static void  testscheduleTaxAgency() {
		Test.StartTest();
		ScheduleQBSync scheduleQBSyncRec = new ScheduleQBSync('TaxAgency');      
		String scheduleString = '0 42 17 * * ?';
		system.schedule('Test check', scheduleString, scheduleQBSyncRec);
		Test.stopTest();
		QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getInstance();
		system.assertEquals('Test Agency', qbConfig.Tax_Agency_Name__c);
	}
	
	@isTest
	private static void  testscheduleTaxCode() {
		Test.StartTest();
		ScheduleQBSync scheduleQBSyncRec = new ScheduleQBSync('TaxCode');      
		String scheduleString = '0 42 17 * * ?';
		system.schedule('Test check', scheduleString, scheduleQBSyncRec);
		Test.stopTest();
		QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getInstance();
		system.assertEquals('Test Agency', qbConfig.Tax_Agency_Name__c);
	}
}