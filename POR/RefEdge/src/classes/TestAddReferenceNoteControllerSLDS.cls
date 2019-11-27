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
/**
 * Class: AddReferenceNoteControllerSLDS
 * Description : class to test and cover AddReferenceNoteControllerSLDS
 * Created by: Rekha Jangir @9 June 2017
 */
@isTest(seeAllData = false)
public class TestAddReferenceNoteControllerSLDS {
   
    /**
     * Method to test from Account
     */
    static testmethod void testAddReferenceNoteFromAccount() {
        test.startTest();
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Account__c = accounts[0].Id, Note__c = 'test Notes');
            //insert referNotes;
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            AddReferenceNoteControllerSLDS refNoteObj = new AddReferenceNoteControllerSLDS(controller);
            //fetch all required information
            AddReferenceNoteControllerSLDS.InfoWrapper info = AddReferenceNoteControllerSLDS.fetchInfo(refNoteObj.recordId, refNoteObj.returnId, refNoteObj.fromWhere);
            
            // set all data 
            info.note = 'test note new';
            info.noteDateNew = date.today();
            // save reward
            String result = AddReferenceNoteControllerSLDS.submit(JSON.serialize(info));
            List<Reference_Note__c> notes = [SELECT Id FROM Reference_Note__c WHERE Account__c = :accounts[0].Id];
            system.assertEquals(1, notes.size());
            system.assertNotEquals(refNoteObj.dateString, null);
        test.stopTest();
    }
    /**
     * Method to test from Account
     */
    static testmethod void testEditReferenceNoteFromAccount() {
        test.startTest();
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Account__c = accounts[0].Id, Note__c = 'test Notes');
            insert referNotes;
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            AddReferenceNoteControllerSLDS refNoteObj = new AddReferenceNoteControllerSLDS(controller);
            //fetch all required information
            AddReferenceNoteControllerSLDS.InfoWrapper info = AddReferenceNoteControllerSLDS.fetchInfo(refNoteObj.recordId, refNoteObj.returnId, refNoteObj.fromWhere);
            
            // set all data 
            info.note = 'test note new';
            // save reward
            String result = AddReferenceNoteControllerSLDS.submit(JSON.serialize(info));
            List<Reference_Note__c> notes = [SELECT Id FROM Reference_Note__c WHERE Account__c = :accounts[0].Id];
            system.assertEquals(1, notes.size());
            //check dateFormat
            system.assertNotEquals(AddReferenceNoteControllerSLDS.getDateFormat(), '');
        test.stopTest();
    }
    /**
     * Method to test from Contact
     */
    static testmethod void testAddReferenceNoteFromContact() {
        test.startTest();
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            List<Contact> contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Contact__c = contacts[0].Id, Note__c = 'test Notes');
            //insert referNotes;
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            AddReferenceNoteControllerSLDS refNoteObj = new AddReferenceNoteControllerSLDS(controller);
            //fetch all required information
            AddReferenceNoteControllerSLDS.InfoWrapper info = AddReferenceNoteControllerSLDS.fetchInfo(refNoteObj.recordId, refNoteObj.returnId, refNoteObj.fromWhere);
            
            // set all data 
            info.note = 'test note new';
            info.noteDateNew = date.today();
            // save reward
            String result = AddReferenceNoteControllerSLDS.submit(JSON.serialize(info));
            List<Reference_Note__c> notes = [SELECT Id FROM Reference_Note__c WHERE Contact__c = :contacts[0].Id];
            system.assertEquals(1, notes.size());
        test.stopTest();
    }
    /**
     * Method to test from Contact
     */
    static testmethod void testEditReferenceNoteFromContact() {
        test.startTest();
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            List<Contact> contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Contact__c = contacts[0].Id, Note__c = 'test Notes');
            insert referNotes;
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            AddReferenceNoteControllerSLDS refNoteObj = new AddReferenceNoteControllerSLDS(controller);
            //fetch all required information
            AddReferenceNoteControllerSLDS.InfoWrapper info = AddReferenceNoteControllerSLDS.fetchInfo(refNoteObj.recordId, refNoteObj.returnId, refNoteObj.fromWhere);
            
            // set all data 
            info.note = 'test note new';
            // save reward
            String result = AddReferenceNoteControllerSLDS.submit(JSON.serialize(info));
            List<Reference_Note__c> notes = [SELECT Id FROM Reference_Note__c WHERE Contact__c = :contacts[0].Id];
            system.assertEquals(1, notes.size());
        test.stopTest();
    }
    /**
     * Method to test from Content
     */
    static testmethod void testAddReferenceNoteFromRefContent() {
        test.startTest();
            List<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
            insert referObject;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Reference_Content__c = referObject[0].Id, Note__c = 'test Notes');
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            AddReferenceNoteControllerSLDS refNoteObj = new AddReferenceNoteControllerSLDS(controller);
            //fetch all required information
            AddReferenceNoteControllerSLDS.InfoWrapper info = AddReferenceNoteControllerSLDS.fetchInfo(refNoteObj.recordId, refNoteObj.returnId, refNoteObj.fromWhere);
            
            // set all data 
            info.note = 'test note new';
            info.noteDateNew = date.today();
            // save reward
            String result = AddReferenceNoteControllerSLDS.submit(JSON.serialize(info));
            List<Reference_Note__c> notes = [SELECT Id FROM Reference_Note__c WHERE Reference_Content__c = :referObject[0].Id];
            system.assertEquals(1, notes.size());
        test.stopTest();
    }
    /**
     * Method to test from Content
     */
    static testmethod void testEditReferenceNoteFromRefContent() {
        test.startTest();
            List<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
            insert referObject;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Reference_Content__c = referObject[0].Id, Note__c = 'test Notes');
            insert referNotes;
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            AddReferenceNoteControllerSLDS refNoteObj = new AddReferenceNoteControllerSLDS(controller);
            //fetch all required information
            AddReferenceNoteControllerSLDS.InfoWrapper info = AddReferenceNoteControllerSLDS.fetchInfo(refNoteObj.recordId, refNoteObj.returnId, refNoteObj.fromWhere);
            
            // set all data 
            info.note = 'test note new';
            // save reward
            String result = AddReferenceNoteControllerSLDS.submit(JSON.serialize(info));
            List<Reference_Note__c> notes = [SELECT Id FROM Reference_Note__c WHERE Reference_Content__c = :referObject[0].Id];
            system.assertEquals(1, notes.size());
        test.stopTest();
    }
	/**
     * Method to test from Reference Request
     */
    static testmethod void testAddReferenceNoteFromRR() {
        test.startTest();
            Reference_Request__c rr = new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'In Progress');
            insert rr;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Reference_Request__c = rr.Id, Note__c = 'test Notes');
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            AddReferenceNoteControllerSLDS refNoteObj = new AddReferenceNoteControllerSLDS(controller);
            //fetch all required information
            AddReferenceNoteControllerSLDS.InfoWrapper info = AddReferenceNoteControllerSLDS.fetchInfo(refNoteObj.recordId, refNoteObj.returnId, refNoteObj.fromWhere);
            
            // set all data 
            info.note = 'test note new';
            info.noteDateNew = date.today();
            // save reward
            String result = AddReferenceNoteControllerSLDS.submit(JSON.serialize(info));
            List<Reference_Note__c> notes = [SELECT Id FROM Reference_Note__c WHERE Reference_Request__c = :rr.Id];
            system.assertEquals(1, notes.size());
        test.stopTest();
    }
    
	/**
     * Method to test from Reference Request
     */
    static testmethod void testEditReferenceNoteFromRR() {
        test.startTest();
            Reference_Request__c rr = new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'In Progress');
            insert rr;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Reference_Request__c = rr.Id, Note__c = 'test Notes');
            insert referNotes;
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            AddReferenceNoteControllerSLDS refNoteObj = new AddReferenceNoteControllerSLDS(controller);
            //fetch all required information
            AddReferenceNoteControllerSLDS.InfoWrapper info = AddReferenceNoteControllerSLDS.fetchInfo(refNoteObj.recordId, refNoteObj.returnId, refNoteObj.fromWhere);
            
            // set all data 
            info.note = 'test note new';
            info.noteDateNew = date.today();
            // save reward
            String result = AddReferenceNoteControllerSLDS.submit(JSON.serialize(info));
            List<Reference_Note__c> notes = [SELECT Id FROM Reference_Note__c WHERE Reference_Request__c = :rr.Id];
            system.assertEquals(1, notes.size());
        test.stopTest();
    }
    /**
     * Method to test from Account Request
     */
    static testmethod void testAddReferenceNoteFromAR() {
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
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            AddReferenceNoteControllerSLDS refNoteObj = new AddReferenceNoteControllerSLDS(controller);
            //fetch all required information
            AddReferenceNoteControllerSLDS.InfoWrapper info = AddReferenceNoteControllerSLDS.fetchInfo(refNoteObj.recordId, refNoteObj.returnId, refNoteObj.fromWhere);
            
            // set all data 
            info.note = 'test note new';
            info.noteDateNew = date.today();
            // save reward
            String result = AddReferenceNoteControllerSLDS.submit(JSON.serialize(info));
            List<Reference_Note__c> notes = [SELECT Id FROM Reference_Note__c WHERE Account_Request__c = :rra.Id];
            system.assertEquals(1, notes.size());
        test.stopTest();
    }
    /**
     * Method to test from Account Request
     */
    static testmethod void testEditReferenceNoteFromAR() {
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
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            AddReferenceNoteControllerSLDS refNoteObj = new AddReferenceNoteControllerSLDS(controller);
            //fetch all required information
            AddReferenceNoteControllerSLDS.InfoWrapper info = AddReferenceNoteControllerSLDS.fetchInfo(refNoteObj.recordId, refNoteObj.returnId, refNoteObj.fromWhere);
            
            // set all data 
            info.note = 'test note new';
            // save reward
            String result = AddReferenceNoteControllerSLDS.submit(JSON.serialize(info));
            List<Reference_Note__c> notes = [SELECT Id FROM Reference_Note__c WHERE Account_Request__c = :rra.Id];
            system.assertEquals(1, notes.size());
        test.stopTest();
    }
    
    /**
     * Method to test from Unspecified
     */
    static testmethod void testAddReferenceNoteFromUR() {
        test.startTest();
            Reference_Request__c rr = new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'In Progress');
            insert rr;
            Referenceability_Type__c refType = new Referenceability_Type__c(Name = 'Analyst Call', Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true, min_lead_time_per_request_type__c = 10, max_accounts_per_request_type__c = 15, Reward_points__c = 100, Note__c = 'test notes');
            insert refType;
            Unspecified_Request__c ur = new Unspecified_Request__c(Requester__c = UserInfo.getUserId(), Reference_Type_Needed__c = refType.Id, Reference_Request__c = rr.Id, Deadline__c = system.today(), Unspecified_Request_Status__c = 'In Progress');
            insert ur;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Unspecified_Request__c = ur.Id, Note__c = 'test Notes');
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            AddReferenceNoteControllerSLDS refNoteObj = new AddReferenceNoteControllerSLDS(controller);
            //fetch all required information
            AddReferenceNoteControllerSLDS.InfoWrapper info = AddReferenceNoteControllerSLDS.fetchInfo(refNoteObj.recordId, refNoteObj.returnId, refNoteObj.fromWhere);
            
            // set all data 
            info.note = 'test note new';
            info.noteDateNew = date.today();
            // save reward
            String result = AddReferenceNoteControllerSLDS.submit(JSON.serialize(info));
            List<Reference_Note__c> notes = [SELECT Id FROM Reference_Note__c WHERE Unspecified_Request__c = :ur.Id];
            system.assertEquals(1, notes.size());
        test.stopTest();
    }
    
    /**
     * Method to test from Unspecified
     */
    static testmethod void testEditReferenceNoteFromUR() {
        test.startTest();
            Reference_Request__c rr = new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'In Progress');
            insert rr;
            Referenceability_Type__c refType = new Referenceability_Type__c(Name = 'Analyst Call', Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true, min_lead_time_per_request_type__c = 10, max_accounts_per_request_type__c = 15, Reward_points__c = 100, Note__c = 'test notes');
            insert refType;
            Unspecified_Request__c ur = new Unspecified_Request__c(Requester__c = UserInfo.getUserId(), Reference_Type_Needed__c = refType.Id, Reference_Request__c = rr.Id, Deadline__c = system.today(), Unspecified_Request_Status__c = 'In Progress');
            insert ur;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Unspecified_Request__c = ur.Id, Note__c = 'test Notes');
            insert referNotes;
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            AddReferenceNoteControllerSLDS refNoteObj = new AddReferenceNoteControllerSLDS(controller);
            //fetch all required information
            AddReferenceNoteControllerSLDS.InfoWrapper info = AddReferenceNoteControllerSLDS.fetchInfo(refNoteObj.recordId, refNoteObj.returnId, refNoteObj.fromWhere);
            
            // set all data 
            info.note = 'test note new';
            // save reward
            String result = AddReferenceNoteControllerSLDS.submit(JSON.serialize(info));
            List<Reference_Note__c> notes = [SELECT Id FROM Reference_Note__c WHERE Unspecified_Request__c = :ur.Id];
            system.assertEquals(1, notes.size());
        test.stopTest();
    }
    /**
     * Method to test Exception
     */
    static testmethod void testReferenceNoteException() {
        test.startTest();
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = null, Account__c = accounts[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            AddReferenceNoteControllerSLDS refNoteObj = new AddReferenceNoteControllerSLDS(controller);
            //fetch all required information
            AddReferenceNoteControllerSLDS.InfoWrapper info = AddReferenceNoteControllerSLDS.fetchInfo(refNoteObj.recordId, refNoteObj.returnId, refNoteObj.fromWhere);
            
            // set all data 
            info.note = 'test note new';
            
            // save reward
            String result = AddReferenceNoteControllerSLDS.submit(JSON.serialize(info));
            system.assertNotEquals('', result);
            result = AddReferenceNoteControllerSLDS.getPermissionsMessage('');
            result = AddReferenceNoteControllerSLDS.getPermissionsMessage(accounts[0].Id);
        test.stopTest();
    }
}