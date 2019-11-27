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
public class TestInvitationExpiredController {
    
    //Unit Test Method
    static testMethod void unitTest01() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        User u = TestDataFactory.CreateUser();
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
        Invitation__c invitation = new Invitation__c(Microsite__c = microsite.Id, Opportunity__c = opprt.Id, Name = 'testInvitation', Is_Expired__c = false);
        insert invitation;
        PageReference pageRef = Page.InvitationExpired;
        pageRef.getParameters().put('InvitationId', String.valueOf(invitation.Id));
        Test.setCurrentPage(pageRef);
        //Start Test method
        test.startTest();
            InvitationExpiredController iec = new InvitationExpiredController();
            iec.updateInvitation();
            Invitation__c inv = [select Is_Expired__c from Invitation__c where Id = : invitation.Id];
            system.assertEquals(true, inv.Is_Expired__c);
        //Stop test method
        test.stopTest();
    }
}