/**
 * Author: Rajat Jain
 * Since: June 5, 2018
 * Name: IntegrityCheckForQBSchedulerTest
 * Description: test Class for IntegrityCheckForQBSchedulerTest.
**/

@isTest
public with sharing class IntegrityCheckForQBSchedulerTest {
    static String CRON_EXP = '0 0 0 * * ? *';
    
    @testSetup
    static void setup() {
        insert new BP_Configurations__c(Support_Email_Recipient__c = 'rajat.jain@metacube.com');
        BP_Configurations__c bpConfigObj = BP_Configurations__c.getOrgDefaults() ;
        system.assertEquals(true, String.isNotBlank(bpConfigObj.Support_Email_Recipient__c));
    }
   
    static testmethod void accSync_ItemCategoryTest() {
        Test.startTest();
        IntegrityCheckForQBScheduler integrityCheckObj = new IntegrityCheckForQBScheduler();
        integrityCheckObj.executeEmailScheduler(); 
        system.schedule('IntegrityCheckForQBScheduler', CRON_EXP, integrityCheckObj);
        Test.stopTest();
        BP_Configurations__c bpConfigObj = BP_Configurations__c.getOrgDefaults() ;
        system.assertEquals(true, String.isNotBlank(bpConfigObj.Support_Email_Recipient__c));
    }
}