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
public with sharing class TestInvitationTrigger {
    
    //Unit Test Method
    static testMethod void afterInsertTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        POR_App_Configuration__c appConfig = new POR_App_Configuration__c();
        insert appConfig;
        Account account = new Account(Name = 'Acc1');
        insert account;
        Contact contact = new Contact(FirstName = 'con1', LastName = 'test', AccountID = account.Id, Email = 'abc@gmail.com');
        insert contact;
        ContentVersion CV = new ContentVersion(Title = 'Content Version1', PathOnClient = 'text', VersionData = TestDataFactory.createFile());
        insert CV; 
        Reference_Content__c RC = new Reference_Content__c(Title__c = 'cont1', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = CV.Id);
        insert RC;
        Opportunity opprt = new Opportunity(Name = 'opp1', Account = account, CloseDate = system.today(), StageName = 'Prospecting');
        insert opprt;
        Microsite__c microsite = new Microsite__c(Name = 'test', Available_for_Use__c = true);
        insert microsite;
        
        //Start test method     
        test.startTest();
            Invitation__c invitation = new Invitation__c(Name = 'Invitation '+System.now(), Invitation_Expiration__c = Date.Today().addDays(20), Start_Date__c = Date.Today());
            invitation.Subject__c = 'Test Subject';
            invitation.Microsite__c = microsite.Id;
            invitation.Opportunity__c = opprt.Id;
            insert invitation;
            list<Reference_Requests_and_Invitations__c> listRRI = [select Id from Reference_Requests_and_Invitations__c where Invitation__c =: invitation.Id];
            system.assertEquals(1, listRRI.size());
        //Stop test method  
        test.stopTest();
    }
    
    //Unit Test Method
    static testMethod void afterUpdateTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        POR_App_Configuration__c appConfig = new POR_App_Configuration__c();
        insert appConfig;
        Account account = new Account(Name = 'Acc1');
        insert account;
        Contact contact = new Contact(FirstName = 'con1', LastName = 'test', AccountID = account.Id, Email = 'abc@gmail.com');
        insert contact;
        ContentVersion CV = new ContentVersion(Title = 'Content Version1', PathOnClient = 'text', VersionData = TestDataFactory.createFile());
        insert CV; 
        Reference_Content__c RC = new Reference_Content__c(Title__c = 'cont1', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = CV.Id);
        insert RC;
        Opportunity opprt = new Opportunity(Name = 'opp1', Account = account, CloseDate = system.today(), StageName = 'Prospecting');
        insert opprt;
        
        Opportunity opprt1 = new Opportunity(Name = 'opp2', Account = account, CloseDate = system.today(), StageName = 'Prospecting');
        insert opprt1;
        Microsite__c microsite = new Microsite__c(Name = 'test', Available_for_Use__c = true);
        insert microsite;
        
        //Start test method     
        test.startTest();
            Invitation__c invitation = new Invitation__c(Name = 'Invitation '+System.now(), Invitation_Expiration__c = Date.Today().addDays(20), Start_Date__c = Date.Today());
            invitation.Subject__c = 'Test Subject';
            invitation.Microsite__c = microsite.Id;
            invitation.Opportunity__c = opprt.Id;
            insert invitation;
            
            invitation.Opportunity__c = opprt1.Id;
            update invitation;
            list<Reference_Requests_and_Invitations__c> listRRI = [select Id from Reference_Requests_and_Invitations__c where Invitation__c =: invitation.Id];
            system.assertEquals(1, listRRI.size());
        //Stop test method  
        test.stopTest();
    }
    
    //Unit Test Method
    static testMethod void afterDeleteTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        POR_App_Configuration__c appConfig = new POR_App_Configuration__c();
        insert appConfig;
        Account account = new Account(Name = 'Acc1');
        insert account;
        Contact contact = new Contact(FirstName = 'con1', LastName = 'test', AccountID = account.Id, Email = 'abc@gmail.com');
        insert contact;
        ContentVersion CV = new ContentVersion(Title = 'Content Version1', PathOnClient = 'text', VersionData = TestDataFactory.createFile());
        insert CV; 
        Reference_Content__c RC = new Reference_Content__c(Title__c = 'cont1', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = CV.Id);
        insert RC;
        Opportunity opprt = new Opportunity(Name = 'opp1', Account = account, CloseDate = system.today(), StageName = 'Prospecting');
        insert opprt;
        Microsite__c microsite = new Microsite__c(Name = 'test', Available_for_Use__c = true);
        insert microsite;
        
        //Start test method     
        test.startTest();
            Invitation__c invitation = new Invitation__c(Name = 'Invitation '+System.now(), Invitation_Expiration__c = Date.Today().addDays(20), Start_Date__c = Date.Today());
            invitation.Subject__c = 'Test Subject';
            invitation.Microsite__c = microsite.Id;
            invitation.Opportunity__c = opprt.Id;
            insert invitation;
            
            delete invitation;
            list<Reference_Requests_and_Invitations__c> listRRI = [select Id from Reference_Requests_and_Invitations__c where Invitation__c =: invitation.Id];
            system.assertEquals(0, listRRI.size());
        //Stop test method  
        test.stopTest();
    }
    
    //Unit Test Method
    static testMethod void afterUndeleteTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        POR_App_Configuration__c appConfig = new POR_App_Configuration__c();
        insert appConfig;
        Account account = new Account(Name = 'Acc1');
        insert account;
        Contact contact = new Contact(FirstName = 'con1', LastName = 'test', AccountID = account.Id, Email = 'abc@gmail.com');
        insert contact;
        ContentVersion CV = new ContentVersion(Title = 'Content Version1', PathOnClient = 'text', VersionData = TestDataFactory.createFile());
        insert CV; 
        Reference_Content__c RC = new Reference_Content__c(Title__c = 'cont1', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = CV.Id);
        insert RC;
        Opportunity opprt = new Opportunity(Name = 'opp1', Account = account, CloseDate = system.today(), StageName = 'Prospecting');
        insert opprt;
        Microsite__c microsite = new Microsite__c(Name = 'test', Available_for_Use__c = true);
        insert microsite;
        
        //Start test method     
        test.startTest();
            Invitation__c invitation = new Invitation__c(Name = 'Invitation '+System.now(), Invitation_Expiration__c = Date.Today().addDays(20), Start_Date__c = Date.Today());
            invitation.Subject__c = 'Test Subject';
            invitation.Microsite__c = microsite.Id;
            invitation.Opportunity__c = opprt.Id;
            insert invitation;
            
            delete invitation;
            
            undelete invitation;
            list<Reference_Requests_and_Invitations__c> listRRI = [select Id from Reference_Requests_and_Invitations__c where Invitation__c =: invitation.Id];
            system.assertEquals(1, listRRI.size());
        //Stop test method  
        test.stopTest();
    }
}