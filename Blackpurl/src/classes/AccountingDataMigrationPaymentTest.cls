@isTest
public with sharing class AccountingDataMigrationPaymentTest {
    
    @testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
        System.assertEquals(1, 1);
    }
    
    @isTest
    static void executePaymentsDataMigrationBatchTest(){
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(true, 'Customer', 'Customer');
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        
        CO_Invoice_Header__c coinvoiceHeader = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Payment__c coinvoicepayment  = TestUtil.createCOInvoicePayment(false, coinvoiceHeader.Id );
        DateTime dT = System.now();
        coinvoicepayment.Payment_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
        insert coinvoicepayment;
        CO_Invoice_Payment__c coinvoicepayment1  = TestUtil.createCOInvoicePayment(false, coinvoiceHeader.Id );
        coinvoicepayment.Payment_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
        coinvoicepayment1.Payment_Method__c = 'Cash Rounding';
        insert coinvoicepayment1;
        Test.StartTest();
        List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'ReceiveMoneyTxn_Payment', 'Receive Money');
        AccountingDataMigrationPayment accountingDataMigrationRMPaymentObj1 = new AccountingDataMigrationPayment();
        AccountingDataMigrationPayment accountingDataMigrationRMPaymentObj2 = new AccountingDataMigrationPayment(null, true);
        AccountingDataMigrationPayment accountingDataMigrationRMPaymentObj3 = new AccountingDataMigrationPayment(null, true, null, null, null);
        Id batchId = AccountingDataMigrationPayment.executePaymentsDataMigrationBatch(200, null ,'THIS_WEEK', DateTime.now(),DateTime.now().addDays(2), DataExportUtil.PAYMENT_ACCOUNTING_OBJECT_NAME);
        Test.stopTest();
        List<Accounting_Data_Migration__c>  accountMigrateId = [ SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c = 'ReceiveMoneyTxn_Payment' ];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId in :accountMigrateId ];
        system.assertEquals(1, attachmentList.size());
    }
}