@isTest
private class QBErrorHandlingServiceTest {
    @testsetup
    private static void setup(){
    	QuickBooks_Configurations__c qbConfig = TestDataFactory.createQBConfig();
    }
    
    @isTest
    private static void testExecuteRetryForCustomer(){
    	Test.startTest();
    	QBErrorHandlingService qbErrorHandlingServiceObj = new QBErrorHandlingService(Constants.READ_TIMED_OUT_ERROR_MESSAGE, new Set<Id>(), 'Customer');
    	QBErrorHandlingService.addDelayToBatch();
    	qbErrorHandlingServiceObj.executeRetry(10);
    	system.assertEquals(qbErrorHandlingServiceObj.syncEntity, 'Customer');
    	Test.stopTest();
    }
    
    @isTest
    private static void testExecuteRetryForVendor(){
    	Test.startTest();
    	QBErrorHandlingService qbErrorHandlingServiceObj = new QBErrorHandlingService(Constants.READ_TIMED_OUT_ERROR_MESSAGE, new Set<Id>(), 'Vendor');
    	QBErrorHandlingService.addDelayToBatch();
    	qbErrorHandlingServiceObj.executeRetry(10);
    	system.assertEquals(qbErrorHandlingServiceObj.syncEntity, 'Vendor');
    	Test.stopTest();
    }
}