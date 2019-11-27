@isTest
private class AccountingDataMigrationCustomersTest {

    @testSetup
	private static void setupTestData() {
		TestUtil.createNameSpaceInGeneralConfig();
		List<General_Configurations__c> config = [SELECT Id FROM General_Configurations__c LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
		system.assertNotEquals(0, config.size());
	}
	
	/**
     * Name: executeCustomerCardsDataMigrationBatchTest
     * Desc: Test the account Data Migration Batch 
     * @param:
     * @Return:
    **/
    @isTest
    static void executeCustomerCardsDataMigrationBatchTest(){
    	List<Account> CustAccount = TestUtil.createCustomerAccount(true, 2);
    	
    	Integer batchSize = 500;
		List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'Customers Card', 'Customers Cards');
    	Test.startTest();
    	AccountingDataMigrationCustomers accountingDataMigrationCustomerObj1 = new AccountingDataMigrationCustomers();
    	AccountingDataMigrationCustomers accountingDataMigrationCustomerObj2 = new AccountingDataMigrationCustomers(null, true);
    	AccountingDataMigrationCustomers accountingDataMigrationCustomerObj3 = new AccountingDataMigrationCustomers(null, true, null, null, null);
    	
    	Id batchId = AccountingDataMigrationCustomers.executeCardsDataMigrationBatch(batchSize, null, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2), 'Customers Card');
    	Test.stopTest();
    	
    	List<Accounting_Data_Migration__c> accountMigrateList = [SELECT Id FROM Accounting_Data_Migration__c WHERE Object_Name__c = 'Customers Card'];
    	List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId IN: accountMigrateList];
    	system.assertEquals(1, attachmentList.Size());
    }
    
    @isTest
    static void executeVendorCardsDataMigrationBatchTest(){
    	List<Account> CustAccount = TestUtil.createVendorAccount(false, 2);
    	for(Integer indexValue = 0; indexValue < CustAccount.size(); indexValue++) {
	    	CustAccount[indexValue].ShippingStreet = CustAccount[indexValue].ShippingStreet +'\n Xyz';
	    	CustAccount[indexValue].BillingStreet = CustAccount[indexValue].BillingStreet +'\n Xyz';
    	}
    	insert CustAccount;
    	
    	Integer batchSize = 500;
		List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'Supplier Card', 'Supplier Card');
    	Test.startTest();
    	Id batchId = AccountingDataMigrationCustomers.executeCardsDataMigrationBatch(batchSize, null, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2), 'Supplier Card');
    	Test.stopTest();
    	
    	List<Accounting_Data_Migration__c> accountMigrateList = [SELECT Id FROM Accounting_Data_Migration__c WHERE Object_Name__c = 'Supplier Card'];
    	List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId IN: accountMigrateList];
    	system.assertEquals(1, attachmentList.Size());
    }
}