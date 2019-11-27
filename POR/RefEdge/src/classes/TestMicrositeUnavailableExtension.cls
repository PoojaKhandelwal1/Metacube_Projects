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
@isTest(SeeAllData=false)
private class TestMicrositeUnavailableExtension {
    // Unit Test Method
    static testMethod void myUnitTest01() {
        Microsite__c microsite = new Microsite__c(Name = 'test');
        //Start test method
        test.startTest();
            insert microsite;
            ApexPages.StandardController sc = new ApexPages.StandardController(microsite);
            MicrositeUnavailableExtension con = new MicrositeUnavailableExtension(sc);
            con.cancelMicrosite();
            con.updateMicrosite();
            
            list<Microsite__c> listMicrosite = [select Id from Microsite__c where Id =: microsite.Id];
            system.assertEquals(0, listMicrosite.size());
        //Stop test method
        test.stopTest();
    }
    
    //Unit Test Method
    static testMethod void myUnitTest02() {
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
            
            ApexPages.StandardController sc = new ApexPages.StandardController(microsite);
            MicrositeUnavailableExtension con = new MicrositeUnavailableExtension(sc);
            con.cancelMicrosite();
            con.updateMicrosite();
            
            list<Microsite__c> listMicrosite = [select Id from Microsite__c where Id =: microsite.Id];
            system.assertEquals(1, listMicrosite.size());
        //Stop test method  
        test.stopTest();
    }
}