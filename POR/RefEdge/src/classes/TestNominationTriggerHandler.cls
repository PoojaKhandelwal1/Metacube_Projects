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
public with sharing class TestNominationTriggerHandler {
    
    //Test method for Nomination rejection
    static testMethod void rejectNominationAccount() {
        //Start Test method
        try{
            test.startTest();
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                Account account = new Account( Name = 'test account');
                insert account;
                PageReference pageRef = Page.NominationForm;
                Test.setCurrentPage(pageRef);
                pageRef.getParameters().put('AccountId', String.valueOf(account.Id));
                ApexPages.StandardController sc = new ApexPages.StandardController(new Nomination__c());
                NominationFormControllerSLDS form = new NominationFormControllerSLDS(sc);
                NominationFormControllerSLDS.InfoWrapper info = NominationFormControllerSLDS.fetchInfo(account.Id, '', '', false);
                String result = NominationFormControllerSLDS.submit(JSON.serialize(info), '');
                Nomination__c nomination = [select Id, Account__C, Contact__c from Nomination__c where Account__c = :account.Id];
                nomination.Note__c = 'rejection note';
                nomination.Disposition__c = ConstantsController.DECLINED;
                update nomination;
                nomination = [select Id, Status__c, Disposition__c, Account__C, Contact__c from Nomination__c where Id = : nomination.Id];
                system.assertEquals('Completed', nomination.Status__c);
                system.assertEquals(ConstantsController.DECLINED, nomination.Disposition__c);
            test.stopTest();
        } catch(Exception e) {}
    }
    
    //Test method 
    static testMethod void acceptNominationAccount() {
        //Start Test method
        try{
            test.startTest();
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                Account account = new Account( Name = 'test account');
                insert account;
                PageReference pageRef = Page.NominationForm;
                Test.setCurrentPage(pageRef);
                pageRef.getParameters().put('AccountId', String.valueOf(account.Id));
                ApexPages.StandardController sc = new ApexPages.StandardController(new Nomination__c());
                NominationFormControllerSLDS form = new NominationFormControllerSLDS(sc);
                NominationFormControllerSLDS.InfoWrapper info = NominationFormControllerSLDS.fetchInfo(account.Id, '', '', false);
                String result = NominationFormControllerSLDS.submit(JSON.serialize(info), '');
                Nomination__c nomination = [select Id, Account__C, Contact__c from Nomination__c where Account__c = :account.Id];
                nomination.Disposition__c = ConstantsController.APPROVED;
                update nomination;
                nomination = [select Id, Status__c, Disposition__c, Account__C, Contact__c from Nomination__c where Id = : nomination.Id];
                system.assertEquals('Completed', nomination.Status__c);
                system.assertEquals(ConstantsController.APPROVED, nomination.Disposition__c);
            //Stop test method
            test.stopTest();
        }catch(Exception e){
            
        }
    }
    //Test method for Nomination rejection
    static testMethod void rejectNominationContact() {
        //Start Test method
        try{
            test.startTest();
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                Account account = new Account( Name = 'test account');
                insert account;
                Contact contact = new Contact (lastName = 'test Contact', AccountId = account.Id);
                insert contact;
                PageReference pageRef = Page.NominationForm;
                Test.setCurrentPage(pageRef);
                pageRef.getParameters().put('AccountId', String.valueOf(account.Id));
                pageRef.getParameters().put('ContactId', String.valueOf(contact.Id));
                ApexPages.StandardController sc = new ApexPages.StandardController(new Nomination__c());
                NominationFormControllerSLDS form = new NominationFormControllerSLDS(sc);
                NominationFormControllerSLDS.InfoWrapper info = NominationFormControllerSLDS.fetchInfo(account.Id, contact.Id, '', true);
                String result = NominationFormControllerSLDS.submit(JSON.serialize(info), '');
                Nomination__c nomination = [select Id, Account__C, Contact__c from Nomination__c where Account__c = :account.Id AND Contact__c = :contact.Id];
                nomination.Note__c = 'rejection note';
                nomination.Disposition__c = ConstantsController.DECLINED;
                update nomination;
                nomination = [select Id, Status__c, Disposition__c, Account__C, Contact__c from Nomination__c where Id = : nomination.Id];
                system.assertEquals('Completed', nomination.Status__c);
                system.assertEquals(ConstantsController.DECLINED, nomination.Disposition__c);
            test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    //Test method 
    static testMethod void acceptNominationContact() {
        //Start Test method
        try{
            test.startTest();
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                Account account = new Account( Name = 'test account');
                insert account;
                Contact contact = new Contact (lastName = 'test Contact', AccountId = account.Id);
                insert contact;
                PageReference pageRef = Page.NominationForm;
                Test.setCurrentPage(pageRef);
                pageRef.getParameters().put('AccountId', String.valueOf(account.Id));
                pageRef.getParameters().put('ContactId', String.valueOf(contact.Id));
                ApexPages.StandardController sc = new ApexPages.StandardController(new Nomination__c());
                NominationFormControllerSLDS form = new NominationFormControllerSLDS(sc);
                NominationFormControllerSLDS.InfoWrapper info = NominationFormControllerSLDS.fetchInfo(account.Id, contact.Id, '', true);
                String result = NominationFormControllerSLDS.submit(JSON.serialize(info), '');
                Nomination__c nomination = [select Id, Account__C, Contact__c from Nomination__c where Account__c = :account.Id AND Contact__c = :contact.Id];
                nomination.Disposition__c = ConstantsController.APPROVED;
                update nomination;
                nomination = [select Id, Status__c, Disposition__c, Account__C, Contact__c from Nomination__c where Id = : nomination.Id];
                system.assertEquals('Completed', nomination.Status__c);
                system.assertEquals(ConstantsController.APPROVED, nomination.Disposition__c);
            //Stop test method
            test.stopTest();
        }catch(Exception e){
            
        }
    }
    //Test method 
    static testMethod void nominationerrors() {
        TestDataFactory.createCustomNotifications();
        //Start Test method
        test.startTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            Account account = new Account( Name = 'test account');
            insert account;
            Contact contact = new Contact (lastName = 'test Contact', AccountId = account.Id);
            insert contact;
            PageReference pageRef = Page.NominationForm;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('AccountId', String.valueOf(account.Id));
            pageRef.getParameters().put('ContactId', String.valueOf(contact.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(new Nomination__c());
            NominationFormControllerSLDS form = new NominationFormControllerSLDS(sc);
            NominationFormControllerSLDS.InfoWrapper info = NominationFormControllerSLDS.fetchInfo(account.Id, contact.Id, '', true);
            String result = NominationFormControllerSLDS.submit(JSON.serialize(info), '');
            Nomination__c nomination = [select Id, Account__C, Contact__c from Nomination__c where Account__c = :account.Id AND Contact__c = :contact.Id];
            try{
                nomination.Disposition__c = ConstantsController.DECLINED;
                nomination.Note__c = '';
                update nomination;
            }
            catch(exception e){}
            try{
                nomination.Status__c = ConstantsController.COMPLETED;
                nomination.Disposition__c = '';
                update nomination;
            }
            catch(exception e){}
            nomination.Disposition__c = ConstantsController.APPROVED;
            update nomination;
            try{
                nomination.Disposition__c = '';
                update nomination;
            }
            catch(exception e){}
            nomination = [select Id, Status__c, Disposition__c, Account__C, Contact__c from Nomination__c where Id = : nomination.Id];
            system.assertEquals('Completed', nomination.Status__c);
            system.assertEquals(ConstantsController.APPROVED, nomination.Disposition__c);
        //Stop test method
        test.stopTest();
    }
}