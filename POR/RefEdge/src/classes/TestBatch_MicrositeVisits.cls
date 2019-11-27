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
public class TestBatch_MicrositeVisits {
    
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
        Reference_Content__c RC = new Reference_Content__c(Title__c = 'cont1', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = CV.Id);
        insert RC;
        Opportunity opprt = new Opportunity(Name = 'opp1', Account = account, CloseDate = system.today(), StageName = 'Prospecting');
        insert opprt;
        Microsite__c microsite = new Microsite__c(Name = 'test');
        insert microsite;
        Invitation__c invitation = new Invitation__c(Microsite__c = microsite.Id, Opportunity__c = opprt.Id, Name = 'testInvitation');
        insert invitation;
        
        Invitation_ReferenceContent__c IRC = new Invitation_ReferenceContent__c(Invitation__c = invitation.Id, Reference_Content__c = RC.Id, Rating__c = 1.00);
        insert IRC;
        
        list<Invitee__c> invitees = new list<Invitee__c>();
        invitees.add(new Invitee__c(Contact__c = contact.id, Invitation__c = invitation.Id, URL__c = 'www.google.com', First_Visit__c = datetime.now(), Visits_clicks__c = 1));
        invitees.add(new Invitee__c(User__c = u.id, Invitation__c = invitation.Id, URL__c = 'www.google.com', First_Visit__c = datetime.now(), Visits_clicks__c = 1));
        insert invitees;
        //Start test method
        test.startTest();
            invitees[0].Visits_clicks__c = 2;
            update invitees;
            Batch_MicrositeVisits batchMicrosite = new Batch_MicrositeVisits();
            ID batchprocessid = database.executebatch(batchMicrosite); 
        //Stop test method
        test.stopTest();
        List <Invitee__c> inviteeList = [select Visits_clicks__c from Invitee__c where Id = : invitees[0].Id];
        system.assertEquals(inviteeList[0].Visits_clicks__c, 2);
    }
}