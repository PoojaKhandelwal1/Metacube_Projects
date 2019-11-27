/**
 * Author: Rajat Jain
 * Since: June 5, 2018
 * Name: AccSync_ItemCategory_Batch_SchedulerTest
 * Description: test Class for AccSync_ItemCategory_Batch_SchedulerTest.
**/

@isTest
public with sharing class AccSync_ItemCategory_Batch_SchedulerTest {
    static String CRON_EXP = '0 0 0 * * ? *';
    
    @testSetup
    static void setup() {
        TestUtil.setQuickBooksConfigurations(true);
        Category__c categoryObj =  TestUtil.createCategory(true, 'Qb Category');
        system.assertEquals(true, String.isNotBlank(categoryObj.Id));
    }
   
    static testmethod void accSync_ItemCategoryTest() {
        Test.startTest();
        TestUtil.setQuickBooksConfigurations(false);
        List<Category__c> catgList = [Select Id from Category__c];
        catgList[0].Income_GL__c = '40';
        update catgList;
        AccSync_ItemCategory_Batch_Scheduler catgSchObj = new AccSync_ItemCategory_Batch_Scheduler();
        //system.schedule('AccSync_ItemCategory_Batch_Scheduler', CRON_EXP, catgSchObj);
        catgSchObj.execute(null);
        Test.stopTest();
        system.assertEquals('82', [Select AccountingId__c From Category__c][0].AccountingId__c ); 
    }
}