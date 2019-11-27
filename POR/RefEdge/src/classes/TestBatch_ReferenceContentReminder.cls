/**
 * ReferenceEdge
 * 
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc.
 * @website : www.point-of-reference.com
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED "AS-IS" BY POINT OF REFERENCE ("POR"), 
 * WITH NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE, 
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * POR SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, 
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. POR IS NOT LIABLE FOR, 
 * AND MAKES NO REPRESENTATIONS OR WARRANTIES REGARDING, THE ACTIONS OR OMISSIONS OF 
 * ANY THIRD PARTIES (OR THE PRODUCTS OR SERVICES OFFERED BY ANY THIRD PARTIES) INCLUDING, 
 * WITHOUT LIMIATION, SALESFORCE.COM. COPY, USE OR DISTRIBUTION PROHIBITED WITHOUT EXPRESS 
 * WRITTEN CONSENT FROM COMPANY.
 */ 
 @isTest(seeAllData = false)
 public with sharing class TestBatch_ReferenceContentReminder {
     
     static testmethod void myUnitTest01() {
         Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
         List<Data_Mapping__c> dmList = TestDataFactory.createDataCollectorForm();
         List<Reference_Content__c> rfContent = TestDataFactory.createReferenceContent();
         List<Account> accounts = TestDataFactory.createAccounts();
         insert accounts;
         List<Opportunity> opps = TestDataFactory.createOpportunity(accounts);
         insert opps;
         Reference_Content__c refCon = new Reference_Content__c();
         refCon.Title__c = ConstantsController.REFERENCE_CONTENT_TYPE;
         refCon.Reminder_Date__c = system.today();
         refCon.Opportunity__c = opps[0].Id;
         refCon.Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE;
         refCon.Data_Collector_Status__c = 'New';
         insert refCon;
         System.assertEquals(opps[0].Id,refCon.Opportunity__c );
         test.startTest();
            Batch_ReferenceContentReminder batchrrr = new Batch_ReferenceContentReminder();
            ID batchprocessid = database.executebatch(batchrrr);
        test.stopTest();
     }
     
     static testmethod void myUnitTest02() {
         Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
         List<Data_Mapping__c> dmList = TestDataFactory.createDataCollectorForm();
         List<Reference_Content__c> rfContent = TestDataFactory.createReferenceContent();
         List<Account> accounts = TestDataFactory.createAccounts();
         insert accounts;
         List<Opportunity> opps = TestDataFactory.createOpportunity(accounts);
         insert opps;
         Reference_Content__c refCon = new Reference_Content__c();
         refCon.Title__c = ConstantsController.REFERENCE_CONTENT_TYPE;
         refCon.Reminder_Date__c = system.today();
         refCon.Number_of_Reminders_Sent__c = customSetting.Number_Of_Reminders_To_Be_Sent__c - 1;
         refCon.Opportunity__c = opps[0].Id;
         refCon.Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE;
         refCon.Data_Collector_Status__c = 'New';
         insert refCon;
         System.assertEquals(opps[0].Id,refCon.Opportunity__c );
         test.startTest();
            Batch_ReferenceContentReminder batchrrr = new Batch_ReferenceContentReminder();
            ID batchprocessid = database.executebatch(batchrrr);
        test.stopTest();
     }
 }