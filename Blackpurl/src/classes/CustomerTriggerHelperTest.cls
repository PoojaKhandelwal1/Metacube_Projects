@isTest
private class CustomerTriggerHelperTest {
    
    static testMethod void customerInsertOperationTest() {
        Constants.IS_RECENT_CUSTOMER_TO_BE_CREATED = true;
        Test.startTest();
        Account testCustomer1 = TestUtil.createCustomer(true, 'Test Customer 1', 'test1@gmail.com', 'Jaipur', '147258369');
        Account testCustomer2 = TestUtil.createCustomer(true, 'Test Customer 2', 'test2@gmail.com', 'Delhi', '147252569');
        Account testVendor = TestUtil.createVendor(true, 'Test Vendor');
        Test.stopTest();
        List<Account> reccentCustomers = [select Id from Account];
        system.assertEquals(reccentCustomers.size(), 3);
    }
    
    static testMethod void customerUpdateOperationTest() {
        Constants.IS_RECENT_CUSTOMER_TO_BE_CREATED = true;
        
        Account testCustomer1 = TestUtil.createCustomer(true, 'Test Customer 1', 'test1@gmail.com', 'Jaipur', '147258369');
        Account testCustomer2 = TestUtil.createCustomer(true, 'Test Customer 2', 'test2@gmail.com', 'Delhi', '147252569');
        
        Test.startTest();
        testCustomer2.BillingStreet = 'C-153, Near Railway Station';
        update testCustomer2;
        Test.stopTest();
        
        List<Account> reccentCustomers = [select Id from Account];
        system.assertEquals(reccentCustomers.size(), 2);
    }
    
    static testMethod void customerDeleteOperationTest() {
        Constants.IS_RECENT_CUSTOMER_TO_BE_CREATED = true;
        
        Account testCustomer1 = TestUtil.createCustomer(true, 'Test Customer 1', 'test1@gmail.com', 'Jaipur', '147258369');
        Account testCustomer2 = TestUtil.createCustomer(true, 'Test Customer 2', 'test2@gmail.com', 'Delhi', '147252569');
        
        Test.startTest();
        delete testCustomer2;
        //CustomerTriggerHelper.accountDeleteOperation();
        Test.stopTest();
        
        List<Account> reccentCustomers = [select Id from Account];
        system.assertEquals(reccentCustomers.size(), 1);
    }
}