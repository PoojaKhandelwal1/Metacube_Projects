/**
 * Author: Rajat Jain
 * updated: May 25, 2018
 * Name: LogTriggerHelperTest
 * Description: It includes scenario based test cases for log record.
**/

@isTest
private class LogTriggerHelperTest {
    static testMethod void myUnitTest() {
        Test.startTest();
        new LogService().createErrorLog('VendorService', 'syncToQuickBooks()',' res.getBody()', 'res.getStatusCode()', LogService.NOT_APPLICABLE, 
                                              'customerRecord' + LogService.METHOD_PARAM_SEPERATOR + 'accountListToUpdate', LogService.QUICKBOOKS);
        List<Log__c> logRecordList = [SELECT Id, Name, Apex_Class__c, CreatedDate FROM Log__c WHERE CreatedDate = TODAY LIMIT 2];
        system.assertEquals(1,logRecordList.size());
        Test.stopTest();
        
    }
}