@isTest
public with sharing class AccountingDataMigrationDepositsTest {
	
	@testSetup
	private static void setupTestData() {
		TestUtil.createNameSpaceInGeneralConfig();
		System.assertEquals(1, 1);
	}
	
	 @isTest
	static void executeDataMigrationBatchTest(){
		Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	
    	CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec = TestUtil.createCOLineItem(true, coHeader1.Id, part.Id, 50);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader1.Id, 'Debit', 500);
        
        String coDepositJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCODepositByCOHeaderId(BPUtility.getEncodedString((coHeader1.Id))));
        
        coDepositJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveCODeposit(BPUtility.getEncodedString(coDepositJSON)));
        
         List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'ReceiveMoneyTxn_Deposit', 'Receive Money');
        
        Test.startTest();
        AccountingDataMigrationDeposits accountingDataMigrationDepositsObj1 = new AccountingDataMigrationDeposits();
    	AccountingDataMigrationDeposits accountingDataMigrationDepositsObj2 = new AccountingDataMigrationDeposits(null, true);
    	AccountingDataMigrationDeposits accountingDataMigrationDepositsObj3 = new AccountingDataMigrationDeposits(null, true, null, null, null);
        Id batchId = AccountingDataMigrationDeposits.executeDepositsDataMigrationBatch(200, null, 'THIS_WEEK', null, null, DataExportUtil.DEPOSITS_ACCOUNTING_OBJECT_NAME);
        Test.stopTest();
        List<Accounting_Data_Migration__c>  accountMigrateId = [ SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c = 'ReceiveMoneyTxn_Deposit' ];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId in :accountMigrateId ];
        system.assertEquals(1, attachmentList.size());
	}
    
}