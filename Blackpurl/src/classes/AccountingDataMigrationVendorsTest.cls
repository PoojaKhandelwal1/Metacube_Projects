/**
 * Name: AccountingDataMigrationVendorTest
 * Since: 12 February,2016
 * Author: Anurag Anand
 * Description: Test Class is used to test AccountingDataMigrationVendor class
**/
@isTest
private class AccountingDataMigrationVendorsTest {
    
    @testSetup
    private static void setupTestData() { 
    	List<Account> vendorsList = new List<Account>();
    	for(Integer i = 0; i < 10; i++) {
    		vendorsList.add(TestDataFactory.sampleVendor('Test vendor' + i));
    	}
    	insert vendorsList;
    }
    
    @isTest
    static void testAccountingDataMigrationVendors() {
    	Test.startTest();
    	AccountingDataMigrationVendors accountingDataMigrationVendors = new AccountingDataMigrationVendors();
    	Database.executeBatch(accountingDataMigrationVendors);
    	Test.stopTest();
    	system.assertEquals(10, [SELECT Id from Account].size());
    }
     
    @isTest
    static void testConstructor() {
    	Test.startTest();
    	Map<Id, Account> vendorsMap = new Map<Id, Account>([SELECT Id from Account]);
    	AccountingDataMigrationVendors accountingDataMigrationVendors1 = new AccountingDataMigrationVendors(new List<Id>(vendorsMap.keyset()), true);
    	AccountingDataMigrationVendors accountingDataMigrationVendors2 = new AccountingDataMigrationVendors(new List<Id>(vendorsMap.keyset()), 
    	                                                               true, '2', DateTime.newInstance(2019,02,01), DateTime.newInstance(2019,02,10));
    	Test.stopTest();
    	system.assertNotEquals(accountingDataMigrationVendors1, null);
    }
}