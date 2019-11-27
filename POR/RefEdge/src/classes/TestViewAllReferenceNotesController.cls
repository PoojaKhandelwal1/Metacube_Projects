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
public with sharing class TestViewAllReferenceNotesController {
	
    /**
     * Method to test from Account
     */
    static testmethod void referenceNoteFromAccountTest() {
        test.startTest();
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Account__c = accounts[0].Id, Note__c = 'test Notes');
            insert referNotes;
            Apexpages.currentPage().getParameters().put('AccountId', accounts[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            ViewAllReferenceNotesController refNoteObj = new ViewAllReferenceNotesController(controller);
            system.assertEquals(refNoteObj.referenceNotes.size(), 1);
            refNoteObj.cancel();
        test.stopTest();
    }
    
    /**
     * Method to test from Contact
     */
    static testmethod void referenceNoteFromContactTest() {
        test.startTest();
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            List<Contact> contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Contact__c = contacts[0].Id, Note__c = 'test Notes');
            insert referNotes;
            Apexpages.currentPage().getParameters().put('ContactId', contacts[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            ViewAllReferenceNotesController refNoteObj = new ViewAllReferenceNotesController(controller);
            system.assertEquals(refNoteObj.referenceNotes.size(), 1);
            refNoteObj.cancel();
        test.stopTest();
    }
    /**
     * Method to test from Content
     */
    static testmethod void referenceNoteFromContentTest() {
        test.startTest();
            list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
            insert referObject;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Reference_Content__c = referObject[0].Id, Note__c = 'test Notes');
            insert referNotes;
            Apexpages.currentPage().getParameters().put('ContentId', referObject[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            ViewAllReferenceNotesController refNoteObj = new ViewAllReferenceNotesController(controller);
            system.assertEquals(refNoteObj.referenceNotes.size(), 1);
            refNoteObj.cancel();
        test.stopTest();
    }
    /**
     * Method to test from Reference Request
     */
    static testmethod void referenceNoteFromRRTest() {
        test.startTest();
            Reference_Request__c rr = new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'In Progress');
            insert rr;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Reference_Request__c = rr.Id, Note__c = 'test Notes');
            insert referNotes;
            Apexpages.currentPage().getParameters().put('RefReqId', rr.Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            ViewAllReferenceNotesController refNoteObj = new ViewAllReferenceNotesController(controller);
            system.assertEquals(refNoteObj.referenceNotes.size(), 1);
            refNoteObj.cancel();
        test.stopTest();
    }
    /**
     * Method to test from Account Request
     */
    static testmethod void ReferenceNoteFromARTest() {
        test.startTest();
        	List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            Referenceability_Type__c refType = new Referenceability_Type__c(Name = 'Analyst Call', Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true, min_lead_time_per_request_type__c = 10, max_accounts_per_request_type__c = 15, Reward_points__c = 100, Note__c = 'test notes');
            insert refType;
            Reference_Request__c rr = new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'In Progress');
            insert rr;
            Reference_Request_Account__c rra = new Reference_Request_Account__c(Requester__c = UserInfo.getUserId(), Reference_Type_Needed__c = refType.Id, Activity_Date__c = system.today(), Reference_Request__c = rr.Id, Deadline__c = system.today(), Reference_Use__c = false, Account__c = accounts[0].Id, Account_Request_Status__c = 'In Progress');
            insert rra;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Account_Request__c = rra.Id, Note__c = 'test Notes');
            insert referNotes;
            Apexpages.currentPage().getParameters().put('AccountReqId', rra.Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            ViewAllReferenceNotesController refNoteObj = new ViewAllReferenceNotesController(controller);
            system.assertEquals(refNoteObj.referenceNotes.size(), 1);
            refNoteObj.cancel();
        test.stopTest();
    }
    /**
     * Method to test from Unspecified
     */
    static testmethod void referenceNoteFromUNTest() {
        test.startTest();
            Reference_Request__c rr = new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'In Progress');
            insert rr;
            Referenceability_Type__c refType = new Referenceability_Type__c(Name = 'Analyst Call', Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true, min_lead_time_per_request_type__c = 10, max_accounts_per_request_type__c = 15, Reward_points__c = 100, Note__c = 'test notes');
            insert refType;
            Unspecified_Request__c ur = new Unspecified_Request__c(Requester__c = UserInfo.getUserId(), Reference_Type_Needed__c = refType.Id, Reference_Request__c = rr.Id, Deadline__c = system.today(), Unspecified_Request_Status__c = 'In Progress');
            insert ur;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Unspecified_Request__c = ur.Id, Note__c = 'test Notes');
            insert referNotes;
            Apexpages.currentPage().getParameters().put('UnspecId', ur.Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            ViewAllReferenceNotesController refNoteObj = new ViewAllReferenceNotesController(controller);
            system.assertEquals(refNoteObj.referenceNotes.size(), 1);
            refNoteObj.cancel();
        test.stopTest();
    }
    /**
     * Method to test from Nomination
     */
    static testmethod void referenceNoteFromNominationTest() {
        test.startTest();
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            Nomination__c nomi = new Nomination__c(Other_Info__c = 'test', Status__c = 'On Hold');
            insert nomi;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Nomination__c = nomi.Id, Note__c = 'test Notes');
            insert referNotes;
            Apexpages.currentPage().getParameters().put('NomiId', nomi.Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            ViewAllReferenceNotesController refNoteObj = new ViewAllReferenceNotesController(controller);
            system.assertEquals(refNoteObj.referenceNotes.size(), 1);
            refNoteObj.cancel();
        test.stopTest();
    }
}