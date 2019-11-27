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
public with sharing class TestMicrositePreviewController {
    /*
    //Unit Test Method
    static testMethod void unitTest01() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        User u = TestDataFactory.createUser();
        insert u;
        POR_App_Configuration__c appConfig = new POR_App_Configuration__c();
        insert appConfig;
        Account account = new Account(Name = 'Acc1');
        insert account;
        Contact contact = new Contact(FirstName = 'con1', LastName = 'test', AccountID = account.Id, Email = 'abc@gmail.com');
        insert contact;
        ContentVersion CV = new ContentVersion(Title = 'Content Version1', PathOnClient = 'text', VersionData = TestDataFactory.createFile());
        insert CV; 
        Reference_Content__c RC = new Reference_Content__c(Title__c = 'cont1', Content_Status__c = 'Active', Language__c = 'English', Content_ID__c = CV.Id);
        insert RC;
        Opportunity opprt = new Opportunity(Name = 'opp1', Account = account, CloseDate = system.today(), StageName = 'Prospecting');
        insert opprt;
        Microsite__c microsite = new Microsite__c(Name = 'test');
        insert microsite;
        Account_Reference_Content__c ARC = new Account_Reference_Content__c(Account__c = account.Id, Reference_Content__c = RC.Id);
        insert ARC;
        //Start test method
        test.startTest();
            PageReference pageRef1 = Page.Invitation_New;
            pageRef1.getParameters().put('opportunityId', String.valueOf(opprt.Id));
            pageRef1.getParameters().put('selectRefContent', String.valueOf(RC.Id));
            Test.setCurrentPage(pageRef1);
            InvitationController ic = new InvitationController();
            ic.defaultExpirationDays = (customSetting.Default_Expiration_Days__c != null ? customSetting.Default_Expiration_Days__c : 0);
            ic.maximumExpirationDays = (customSetting.Maximum_Expiration_Days__c != null ? customSetting.Maximum_Expiration_Days__c : 0);
            ic.onLoad();
            ic.contactIds = contact.Id;
            ic.contactEmailIds = contact.Id;
            ic.invitation.Subject__c = 'test subject';
            ic.message = 'test message';
            ic.invitation.Microsite__c = microsite.Id;
            ic.createInvitation();
            list<Invitee__c> invits = [select Id, URL__c From Invitee__c where Invitation__c = :ic.invitation.Id and Contact__c = :contact.Id];
            system.assertEquals(1, invits.size());
            string key = invits[0].URL__c;
            PageReference pageRef = Page.MicrositePreview;
            pageRef.getParameters().put('key', String.valueOf(key.substringAfter('key=')));
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(microsite);
            MicrositePreviewController con = new MicrositePreviewController();
            con.refContentId = RC.Id;
            con.rating = '3.00';
            con.saveRating();
            con.selectedRefContentId = RC.id;
            con.updateInvitationContent();
            con.updateInvitee();
         //Stop test method
         test.stopTest();
    }
    
    //Unit Test Method
    static testMethod void unitTest02() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        User u = TestDataFactory.createUser();
        insert u;
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
        Microsite__c microsite = new Microsite__c(Name = 'test');
        insert microsite;
        Account_Reference_Content__c ARC = new Account_Reference_Content__c(Account__c = account.Id, Reference_Content__c = RC.Id);
        insert ARC;
        //Start test method
        test.startTest();
            PageReference pageRef = Page.MicrositePreview;
            pageRef.getParameters().put('micrositeId', String.valueOf(microsite.Id));
            pageRef.getParameters().put('selectRefContent', String.valueOf(RC.Id));
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(microsite);
            MicrositePreviewController con = new MicrositePreviewController();
            con.refContentId = RC.Id;
            con.rating = '3.00';
            //con.saveRating();
            con.selectedRefContentId = RC.id;
            con.updateInvitationContent();
            con.updateInvitee();
            List<Invitation_ReferenceContent__c> invContents = [select Id from Invitation_ReferenceContent__c];
            system.assertEquals(invContents.size(),0);
         //Stop test method
         test.stopTest();
    }*/
}