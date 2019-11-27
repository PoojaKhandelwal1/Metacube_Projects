@isTest
public with sharing class AccountingDataMigrationRMPaymentTest {
    
    @testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
        System.assertEquals(1, 1);
    }
    
    
    @isTest
    static void executePaymentsDataMigrationBatchTest(){
        Test.StartTest();
        List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'ReceiveMoneyTxn_Payment', 'Receive Money');
        AccountingDataMigrationRMPayment accountingDataMigrationRMPaymentObj1 = new AccountingDataMigrationRMPayment();
    	AccountingDataMigrationRMPayment accountingDataMigrationRMPaymentObj2 = new AccountingDataMigrationRMPayment(null, true);
    	AccountingDataMigrationRMPayment accountingDataMigrationRMPaymentObj3 = new AccountingDataMigrationRMPayment(null, true, null, null, null);
        Id batchId = Database.executeBatch(accountingDataMigrationRMPaymentObj3, 200);
        Test.stopTest();
        List<Accounting_Data_Migration__c>  accountMigrateId = [ SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c = 'ReceiveMoneyTxn_Payment' ];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId in :accountMigrateId ];
        system.assertEquals(0, attachmentList.size());
    }
}