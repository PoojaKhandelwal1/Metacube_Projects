@isTest 
private class TaxExemptionsBatchTest {
    
    @testSetup
    private static void setupTestData() {
        List<Account> customerList = new List<Account>();
        List<CO_Header__c> cOHeaderList = new List<CO_Header__c>();
        List<Service_Order_Header__c> serviceOrderHeaderList = new List<Service_Order_Header__c>();
        for(Integer i = 0; i < 10; i++) {
            customerList.add(TestDataFactory.sampleCustomer('Test Customer' + i, 'Individual', 'Test', 'Customer' + i));
        }
        insert customerList;
        for(Integer i = 0; i < 10; i++) {
            cOHeaderList.add(TestDataFactory.sampleCoHeader(customerList[i].Id));
        }
        insert cOHeaderList;
        
        for(Integer i = 0; i < 10; i++) {
            serviceOrderHeaderList.add(TestDataFactory.sampleSOHeader(cOHeaderList[i].Id));
        }
        insert serviceOrderHeaderList;
    }
    
    @isTest
    private static void taxExemptionsBatchTest() {
        Test.startTest();
        DataBase.executeBatch(new TaxExemptionsBatch());
        Test.stopTest();
        system.assertEquals([SELECT Id from CO_Header__c].size(), 10);
    }
}