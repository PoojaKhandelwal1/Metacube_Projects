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
public with sharing class TestInvitationController {
    
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
        list<Reference_Content__c> RCList = new list<Reference_Content__c>();
        RCList.add(new Reference_Content__c(Title__c = 'cont1', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = CV.Id,Custom_Reference_Content__c=true));
        RCList.add(new Reference_Content__c(Title__c = 'cont2', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = CV.Id));
        insert RCList;
        List<Account_Reference_Content__c> ARCList = new list<Account_Reference_Content__c>();
        ARCList.add(new Account_Reference_Content__c(Account__c = account.Id, Reference_Content__c = RCList[0].Id));
        ARCList.add(new Account_Reference_Content__c(Account__c = account.Id, Reference_Content__c = RCList[1].Id));
        insert ARCList;
        Opportunity opprt = new Opportunity(Name = 'opp1', Account = account, CloseDate = system.today(), StageName = 'Prospecting');
        insert opprt;
        Microsite__c microsite = new Microsite__c(Name = 'test', Available_for_Use__c = true);
        insert microsite;
         
         //edit
        Case casea = new Case(Status = 'New',Origin = 'Email',Account = account);
        insert casea;
        //end
        //Start test method     
        test.startTest();
            PageReference pageRef = Page.Invitation_New;
            Test.setCurrentPage(pageRef);
            Reference_Content__c RC = RCList[0];
            InvitationController ic = new InvitationController();
            ic.defaultExpirationDays = (customSetting.Default_Expiration_Days__c != null ? customSetting.Default_Expiration_Days__c : 0);
            ic.maximumExpirationDays = (customSetting.Maximum_Expiration_Days__c != null ? customSetting.Maximum_Expiration_Days__c : 0);
            ic.onLoad();
            ic.opportunityId = opprt.Id;
        	ic.caseId=casea.id;
            ic.selectedRefContents = String.valueOf(RC.Id)+','+String.valueOf(RCList[1].Id);
            ic.createInvitation();
            ic.showCoworkers();
            ic.invitation.Invitation_Expiration__c = system.today() - 1;
            ic.createInvitation();
            ic.invitation.Invitation_Expiration__c = system.today() + Integer.valueOf(customSetting.Maximum_Expiration_Days__c) + 1;
            ic.createInvitation();
            ic.invitation.Invitation_Expiration__c = system.today() + 1;
            ic.createInvitation();
            ic.contactIds = contact.Id;
            ic.contactEmailIds = contact.Id;
            ic.coworkerIds = u.Id;
            ic.createInvitation();
            //ic.refresh();
        	ic.showRefContents();
            ic.contentIdToRemove = RCList[1].Id;
            ic.removeContent();
            ic.invitation.Subject__c = 'test subject';
            ic.invitation.Message__c = 'test message';
            ic.createInvitation();
            ic.invitation.Microsite__c = microsite.Id;
            ic.setDefaultTemplate();
            system.assertEquals(UtilityController.getMicrositeTemplete(), microsite.Id);
            ic.createInvitation();
            list<Invitee__c> invits = [select Id, URL__c From Invitee__c where Invitation__c = :ic.invitation.Id and Contact__c = :contact.Id];
            //system.assertEquals(1, invits.size());
            ic.returnOpportunity();
        	ic.pageUrl='/';
       		ic.opportunityId=null;
        	//returnOpportunity if opporetunityId is null
        	ic.returnOpportunity();
        	ic.caseId=null;
        	//returnOpportunity if caseId and opporetunityId is null
       		ic.returnOpportunity();
        	ContentVersion cv1=[select Id from ContentVersion where id =:CV.id];
        	ic.hoverContentId=cv1.Id;
        	ic.fetchHoverContentItem();
       		Reference_Content__c refContC=[select id from Reference_content__c where id=:RCList[0].Id];
        	ic.hoverContentId=null;
        	ic.hoverRefContentId=refContC.id;
        	ic.fetchHoverContentItem();
        	ic.singleContentDownload();
        //Stop test method  
        test.stopTest();
    }
    
    //Unit Test Method
    static testMethod void unitTest02() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        User u = TestDataFactory.createUser();
        insert u;
        
        Microsite__c microsite = new Microsite__c(Name = 'test', Available_for_Use__c = true);
        insert microsite;
        
        POR_App_Configuration__c appConfig = new POR_App_Configuration__c();
        appConfig.Microsite_default_template__c = microsite.id;
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
        //Start test method 
        test.startTest();
            PageReference pageRef = Page.Invitation_New;
            Test.setCurrentPage(pageRef);
            InvitationController ic = new InvitationController();
            ic.defaultExpirationDays = (customSetting.Default_Expiration_Days__c != null ? customSetting.Default_Expiration_Days__c : 0);
            ic.maximumExpirationDays = (customSetting.Maximum_Expiration_Days__c != null ? customSetting.Maximum_Expiration_Days__c : 0);
            ic.onLoad();
            ic.opportunityId = opprt.Id;
            ic.selectedRefContents = String.valueOf(RC.Id);
            ic.createInvitation();
            ic.showCoworkers();
            ic.invitation.Invitation_Expiration__c = system.today() - 1;
            ic.createInvitation();
            ic.invitation.Invitation_Expiration__c = system.today() + Integer.valueOf(customSetting.Maximum_Expiration_Days__c) + 1;
            ic.createInvitation();
            ic.invitation.Invitation_Expiration__c = system.today() + 1;
            ic.createInvitation();
            ic.contactIds = contact.Id;
            ic.coworkerIds = u.Id;
            ic.createInvitation();
            ic.invitation.Subject__c = 'test subject';
            ic.invitation.Message__c = 'test message';
            ic.previewEmail();
            ic.createInvitation();
            ic.invitation.Microsite__c = microsite.Id;
            ic.setDefaultTemplate();
            system.assertEquals(UtilityController.getMicrositeTemplete(), microsite.Id);
            ic.createInvitation();
            list<Invitee__c> invits = [select Id, URL__c From Invitee__c where Invitation__c = :ic.invitation.Id and Contact__c = :contact.Id];
            //system.assertEquals(1, invits.size());
            //ic.backToSearch();
            ic.opportunityId = '';
            //ic.backToSearch();
        //Stop test method  
        test.stopTest();
    }
}