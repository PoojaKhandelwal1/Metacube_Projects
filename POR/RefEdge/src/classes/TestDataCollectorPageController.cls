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
 public with sharing class TestDataCollectorPageController {
 
    static testmethod void myUnitTest01() {
         //Start test Method
        test.startTest();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Data_Mapping__c> dmList = TestDataFactory.createDataCollectorForm();
        list<Reference_Content__c> refcontent = TestDataFactory.createMultipleReferenceContent();
        system.assertNotEquals(0, dmList.size());
        Apexpages.currentPage().getParameters().put('customFormId', dmList[0].Id);  
        Apexpages.currentPage().getParameters().put('id', refcontent[0].Id);     
        DataCollectorPageController testObject = new DataCollectorPageController();
        DataCollectorCustomController.getPermissionsMessage();
        testObject.goBack(); 
         //Stop test method
        test.stopTest();
    }

    static testmethod void myUnitTest02() {
        //Start test Method
        test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserPOR@testorg.com');
        insert u;
        System.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List<Data_Mapping__c> dmList = TestDataFactory.createDataCollectorForm();
            system.assertNotEquals(0, dmList.size());
            list<Reference_Content__c> refcontent = TestDataFactory.createMultipleReferenceContent();
            List<Account> accList = TestDataFactory.createAccounts();
            insert accList;
            List<Opportunity> oppList = TestDataFactory.createOpportunity(accList);
            insert oppList;
            Reference_Content__c refconRecord = new Reference_Content__c();
            refconRecord = refcontent[0];
            refconRecord.Data_Collector_Status__c = 'New';
            refconRecord.Opportunity__c = oppList[0].Id;
            refconRecord.ownerId = u.id;
            refconRecord.Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE+'@#';
            insert refconRecord;     
            Apexpages.currentPage().getParameters().put('customFormId', dmList[10].Id);   
            Apexpages.currentPage().getParameters().put('customSettingId', customSetting.Id);    
            Apexpages.currentPage().getParameters().put('id', refconRecord.Id); 
            DataCollectorPageController testObject = new DataCollectorPageController();  
            testObject.isSave = true;           
            testObject.updateContent();
            testObject.reset();        
            testObject.cancel();
            testObject.goBack();         
            //Stop test method
            test.stopTest();
        }
    }
        
    static testmethod void myUnitTest03() {
        //Start test Method
        test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserRefEdge@testorg.com');
        insert usr;
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, ManagerId = usr.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserPOR@testorg.com');
        insert u;
        System.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List<Data_Mapping__c> dmList = TestDataFactory.createDataCollectorForm();
            system.assertNotEquals(0, dmList.size());
            list<Reference_Content__c> refcontent = TestDataFactory.createMultipleReferenceContent();
            List<Account> accList = TestDataFactory.createAccounts();
            insert accList;
            List<Opportunity> oppList = TestDataFactory.createOpportunity(accList);
            insert oppList;
            Reference_Content__c refconRecord = new Reference_Content__c();
            refconRecord = refcontent[0];
            refconRecord.Data_Collector_Status__c = 'New';
            refconRecord.Opportunity__c = oppList[0].Id;
            refconRecord.ownerId = u.id;
            refconRecord.Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE;
            insert refconRecord;     
            Apexpages.currentPage().getParameters().put('customFormId', dmList[0].Id);   
            Apexpages.currentPage().getParameters().put('customSettingId', customSetting.Id);    
            Apexpages.currentPage().getParameters().put('id', refconRecord.Id); 
            DataCollectorPageController testObject = new DataCollectorPageController();             
            testObject.updateContent();
            testObject.reset();        
            testObject.cancel();
            testObject.goBack();         
            //Stop test method
            test.stopTest();
        }
    }
}