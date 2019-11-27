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
 * Apex Class: RefRequestProjectControllerSLDS.cls
 * Description: test class for lightnig project detail page
 * author: Gaurav Saini (8 Apr, 2018)
 */
@isTest(seeAllData = false)
public with sharing class TestRefRequestProjectControllerSLDS {

    //REF-1964
    public static List < Account > accounts;
    public static List < Contact > contacts;
    public static List < Referenceability_Type__c > refTypeList;
    public static List<Reference_Request__c> rrList;
    public static List < Reference_Request_Account__c > arList;
    public static List < Unspecified_Request__c > urList;
    public static List < Community_Invite__c  > CIs;
    public static List < Community_Invite_Contact__c > CICs;
    public static List < Reward__c > rewards;
    

    /**
     * method to test constructor
     * author: Gaurav Saini (8 Apr, 2018)
     */
    public static testmethod void testConstructor() {
    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
        Apexpages.currentPage().getParameters().put('rrId', 'testRRId');
        Apexpages.currentPage().getParameters().put('arId', 'testRRId');
        Apexpages.currentPage().getParameters().put('urId', 'testRRId');
    	RefRequestProjectControllerSLDS testObj = new RefRequestProjectControllerSLDS();
    	system.assert(testObj.refRequestId == 'testRRId');
    }

    /**
     * method to test getPermissionsMessage method
     * author: Gaurav Saini (8 Apr, 2018)
     */
    public static testmethod void testGetPermissionsMessage() {
    	List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
        List<String> refTypeIds = new List<String>();
        List<Reference_Type_Mapping__c> rtmList = new List<Reference_Type_Mapping__c>();
        Integer count = 0;

        for (Referenceability_Type__c rt : refTypeList) {
            refTypeIds.add(rt.Id);
            rtmList.add(new Reference_Type_Mapping__c(Name = 'name' + count++, Visible__c = true, Referenceability_Type__c = rt.Id));
        }
        insert rtmList;
        String result = RefRequestProjectControllerSLDS.getPermissionsMessage('edit request', true, JSON.serialize(refTypeIds));
    	system.assert(result != null);
        result = RefRequestProjectControllerSLDS.getPermissionsMessage('edit filters', true, JSON.serialize(refTypeIds));
    	system.assert(result != null);
        result = RefRequestProjectControllerSLDS.getPermissionsMessage('delete cic', true, JSON.serialize(refTypeIds));
    	system.assert(result != null);
        result = RefRequestProjectControllerSLDS.getPermissionsMessage('post to community', true, JSON.serialize(refTypeIds));
    	system.assert(result != null);
    }

    /**
     * method to test getEmailTemplate method
     * author: Gaurav Saini (8 Apr, 2018)
     */
    public static testmethod void testGetEmailTemplate() {
    	/*
        EmailTemplate et = new EmailTemplate(DeveloperName = 'Community_Reference_Opportunity_Invitation', Subject = 'test',
                                            Body = 'test', HTMLValue = 'test');
        insert et;
        */
        String result = RefRequestProjectControllerSLDS.getEmailTemplate();
    	system.assert(result != null);
    }

    /**
     * method to test getStatusPicklist method
     * author: Gaurav Saini (8 Apr, 2018)
     */
    public static testmethod void testGetStatusPicklist() {
        String result = RefRequestProjectControllerSLDS.getStatusPicklist();
    	system.assert(result != null);
    }

    /**
     * method to test getRefTypesMap method
     * author: Gaurav Saini (8 Apr, 2018)
     */
    public static testmethod void testGetRefTypesMap() {
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
        Attachment testAtt = new Attachment();   	
        testAtt.Name = 'communityPic.jpg';
        Blob bodyBlob = Blob.valueOf('Test Attachment Body');
        testAtt.body = bodyBlob;
        testAtt.ParentId = refTypeList[0].Id;
        insert testAtt;
        String result = RefRequestProjectControllerSLDS.getRefTypesMap();
    	system.assert(result != null);

        RefRequestProjectControllerSLDS.PicklistOptionWrapper testOption = new RefRequestProjectControllerSLDS.PicklistOptionWrapper('test', 'test');
    }

    /**
     * method to test createCommunityInvite method
     * author: Gaurav Saini (8 Apr, 2018)
     */
    public static testmethod void testCreateCommunityInvite() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        Contact con = new Contact();
        con.AccountId = accounts[0].Id;
        con.LastName = 'doe';
        con.FirstName = 'john';
        con.Email = 'john.doe@seven.com';
        insert con;
        Reference_Basic_Information__c conRBI = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = con.AccountId, Contact__c = con.Id);
        insert conRBI;
        User u = TestDataFactory.createCommunityUser(con);
        insert u;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
        List<Reference_Request__c> rrList = TestDataFactory.createReferenceRequest();
        insert rrList;
        List<Reference_Request_Account__c> arList = TestDataFactory.createAccountRequests(accounts, rrList, refTypeList);
        insert arList;
        List<Unspecified_Request__c> urList = TestDataFactory.createUnspecifiedRequest(rrList, refTypeList);
        insert urList;
        List<Label__c> filterList = TestDataFactory.createLabels();
        insert filterList;
        List<Attribute__c> attributeList = new List<Attribute__c>();
        attributeList.add(new Attribute__c(Name = 'Root Attribute', Parent__c = null, ParentIds__c = null));
        insert attributeList;
        List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attributeList, 1, 2);
        insert childAttList;
        List<Attributes_Labels__c> attLabelList = TestDataFactory.setUpAttributeLabels(filterList, attributeList);

        Test.startTest();
            Map<String, RefRequestProjectControllerSLDS.CommunityUserWrapper> communityUserMap = new Map<String, RefRequestProjectControllerSLDS.CommunityUserWrapper>();
            communityUserMap.put(u.ContactId, new RefRequestProjectControllerSLDS.CommunityUserWrapper(u));

            Map<String, Set<String>> filterAttMap = new Map<String, Set<String>>();
            filterAttMap.put(filterList[0].Id, new Set<String> { childAttList[0].Id });

            Map<String, String> emailMap = new Map<String, String>();
            emailMap.put('refTypeId', refTypeList[0].Id);
            emailMap.put('refTypeName', refTypeList[0].Name);
            emailMap.put('deadline', Date.today().year() + '-' + Date.today().month() + '-' + (Date.today().day() + 1));
            emailMap.put('details', 'test');
            emailMap.put('withValue', 'test');
            emailMap.put('accountId', accounts[0].Id);
            emailMap.put('body', 'test');
            emailMap.put('subject', 'test');

            String result = RefRequestProjectControllerSLDS.createCommunityInvite(JSON.serialize(emailMap), rrList[0].Id, JSON.serialize(communityUserMap), JSON.serialize(filterAttMap), true);
            system.assertEquals(result, 'success');

            emailMap = new Map<String, String>();
            emailMap.put('refTypeId', refTypeList[0].Id);
            emailMap.put('refTypeName', refTypeList[0].Name);
            emailMap.put('deadline', Date.today().year() + '-' + Date.today().month() + '-' + (Date.today().day() + 1));
            emailMap.put('details', 'test');
            emailMap.put('withValue', 'test');
            emailMap.put('accountId', accounts[0].Id);
            emailMap.put('body', 'test' + '{!Community_Invite__c.Community_Yes_Im_In_Link__c}' + '{!Community_Invite__c.Community_No_Thanks_Link__c}' + '{!Community_Invite__c.Community_Participate_Link__c}');
            emailMap.put('subject', 'test');

            result = RefRequestProjectControllerSLDS.createCommunityInvite(JSON.serialize(emailMap), rrList[0].Id, JSON.serialize(communityUserMap), JSON.serialize(filterAttMap), true);
            system.assertEquals(result, 'success');

            result = RefRequestProjectControllerSLDS.createCommunityInvite('', rrList[0].Id, JSON.serialize(communityUserMap), JSON.serialize(filterAttMap), true);
            system.assertNotEquals(result, 'success');

            List<Community_Invite_Contact__c> cicList = [SELECT Id FROM Community_Invite_Contact__c WHERE Community_Invite__r.Reference_Request__c = :rrList[0].Id];
            String delResult = RefRequestProjectControllerSLDS.deleteCommunityInvite(cicList[0].Id);
            String errResult = RefRequestProjectControllerSLDS.deleteCommunityInvite('error id');

            Hit_List__c testHL = new Hit_List__c(Note__c = 'test hl', Reference_Request__c = rrList[0].Id, Deadline__c = system.today(), Account__c = con.AccountId, Contact__c = con.Id);
            insert testHL;

            String ciListResult = RefRequestProjectControllerSLDS.getCommunityInviteList(rrList[0].Id);
            system.assert(ciListResult != null);

            List<RefRequestProjectControllerSLDS.CommunityInviteWrapper> cicWrapperList
                    = (List<RefRequestProjectControllerSLDS.CommunityInviteWrapper>)JSON.deserialize(ciListResult, List<RefRequestProjectControllerSLDS.CommunityInviteWrapper>.class);
            Map<String, String> requestMap = new Map<String, String>();
            requestMap.put('refTypeId', refTypeList[0].Id);
            requestMap.put('accRequestId', arList[0].Id);
            requestMap.put('deadline', Date.today().year() + '-' + Date.today().month() + '-' + (Date.today().day()));
            requestMap.put('reqNotes', 'test');
            requestMap.put('addInfoId', '');
            requestMap.put('accountId', accounts[0].Id);
            requestMap.put('requestStatus', 'In Progress');

            result = RefRequestProjectControllerSLDS.assignCicToRequest(JSON.serialize(cicWrapperList[0]), rrList[0].Id, rrList[0].Requester__c, false, JSON.serialize(requestMap), 'Member');
            system.assert(result != null);

            result = RefRequestProjectControllerSLDS.assignCicToRequest(JSON.serialize(cicWrapperList[0]), rrList[0].Id, rrList[0].Requester__c, false, JSON.serialize(requestMap), 'Candidate');
            system.assert(result != null);

            requestMap = new Map<String, String>();
            requestMap.put('refTypeId', refTypeList[0].Id);
            requestMap.put('unspecRequestId', urList[0].Id);
            requestMap.put('deadline', Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day());
            requestMap.put('reqNotes', 'test');
            requestMap.put('addInfoId', '');
            requestMap.put('accountId', '');
            requestMap.put('requestStatus', 'In Progress');
            
            result = RefRequestProjectControllerSLDS.assignCicToRequest(JSON.serialize(cicWrapperList[0]), rrList[0].Id, rrList[0].Requester__c, true, JSON.serialize(requestMap), 'Member');
            system.assert(result != null);
            
            result = RefRequestProjectControllerSLDS.assignCicToRequest('', rrList[0].Id, rrList[0].Requester__c, true, JSON.serialize(requestMap), 'Member');
            system.assert(result != null);
        Test.stopTest();
    }

    /**
     * method to test getCommunityMatchingMembers method
     * author: Gaurav Saini (8 Apr, 2018)
     */
    public static testmethod void testGetCommunityMatchingMembers() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        Contact con = new Contact();
        con.AccountId = accounts[0].Id;
        con.LastName = 'doe';
        con.FirstName = 'john';
        con.Email = 'john.doe@seven.com';
        insert con;
        User u = TestDataFactory.createCommunityUser(con);
        insert u;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
        List<Reference_Request__c> rrList = TestDataFactory.createReferenceRequest();
        insert rrList;
        List<Reference_Request_Account__c> arList = TestDataFactory.createAccountRequests(accounts, rrList, refTypeList);
        insert arList;
        List<Unspecified_Request__c> urList = TestDataFactory.createUnspecifiedRequest(rrList, refTypeList);
        insert urList;
        List<Label__c> filterList = TestDataFactory.createLabels();
        insert filterList;
        List<Attribute__c> attributeList = new List<Attribute__c>();
        attributeList.add(new Attribute__c(Name = 'Root Attribute', Parent__c = null, ParentIds__c = null));
        insert attributeList;
        List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attributeList, 1, 2);
        insert childAttList;
        List<Attributes_Labels__c> attLabelList = TestDataFactory.setUpAttributeLabels(filterList, attributeList);
        Reference_Basic_Information__c conRBI = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Attribute_Ids__c = childAttList[0].Id, Account__c = con.AccountId, Contact__c = con.Id);
        insert conRBI;

        Test.startTest();
            Map<String, Set<String>> filterAttMap = new Map<String, Set<String>>();
            filterAttMap.put(filterList[0].Id, new Set<String> { childAttList[0].Id });

            String result = RefRequestProjectControllerSLDS.getCommunityMatchingMembers('', '', JSON.serialize(filterAttMap));
            system.assert(result != null);

            String result1 = RefRequestProjectControllerSLDS.getCommunityMatchingMembers('', '', JSON.serialize(new Map<String, Set<String>>()));
            system.assert(result1 != null);
        Test.stopTest();
    }

    /**
     * method to test createReminder method
     * author: Gaurav Saini (8 Apr, 2018)
     */
    public static testmethod void testCreateReminder() {
        Account acc = new Account(Name = 'test account');
        insert acc;
        Map<String, String> reminderMap = new Map<String, String>();
        reminderMap.put('time', '10:30');
        reminderMap.put('date', Date.today().year() + '-' + Date.today().month() + '-' + (Date.today().day() + 1));
        reminderMap.put('hitListId', acc.Id);
        reminderMap.put('subject', 'test');
        reminderMap.put('notes', 'test');
        String result = RefRequestProjectControllerSLDS.createReminder(JSON.serialize(reminderMap), true);
        result = RefRequestProjectControllerSLDS.createReminder(JSON.serialize(reminderMap), false);
        reminderMap.put('time', '10:30');
        reminderMap.put('date', Date.today().year() + '-' + Date.today().month() + '-' + (Date.today().day() - 1));
        reminderMap.put('hitListId', acc.Id);
        reminderMap.put('subject', 'test');
        reminderMap.put('notes', 'test');
        result = RefRequestProjectControllerSLDS.createReminder(JSON.serialize(reminderMap), false);
        result = RefRequestProjectControllerSLDS.createReminder('', false);
    	system.assert(result != null);
    }

    /**
     * method to test createNote method
     * author: Gaurav Saini (8 Apr, 2018)
     */
    public static testmethod void testCreateNote() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
        User u = TestDataFactory.createUser();
        insert u;
        List<Reference_Request__c> rrList = TestDataFactory.createReferenceRequest();
        rrList[0].Adv_Routing_Group__c = 'a,b';
        insert rrList;
        List<Reference_Request_Additional_Info__c> addInfoList = createAddInfo(u);
        insert addInfoList;
        List<Reference_Request_Account__c> arList = TestDataFactory.createAccountRequests(accounts, rrList, refTypeList);
        insert arList;
        arList[0].Reference_Request_Additional_Info__c = addInfoList[0].Id;
        arList[1].Reference_Request_Additional_Info__c = addInfoList[0].Id;
        arList[2].Reference_Request_Additional_Info__c = addInfoList[0].Id;
        update arList;
        List<Reference_Request_Account_Contact__c> crList = TestDataFactory.createContactRequests(contacts, arList, refTypeList);
        insert crList;
        List<Unspecified_Request__c> urList = TestDataFactory.createUnspecifiedRequest(rrList, refTypeList);
        insert urList;

        Test.startTest();
            List<Reference_Note__c> noteList = new List<Reference_Note__c>();
            Reference_Note__c testNote = new Reference_Note__c();
            testNote.Reference_Request__c = rrList[0].Id;
            testNote.Unspecified_Request__c = urList[0].Id;
            testNote.Note_Date__c = Date.today();
            testNote.Note__c = 'test note value';
            noteList.add(testNote);
            testNote = new Reference_Note__c();
            testNote.Reference_Request__c = rrList[0].Id;
            testNote.Account_Request__c = arList[0].Id;
            testNote.Note_Date__c = Date.today();
            testNote.Note__c = 'test note value aa';
            noteList.add(testNote);
            insert noteList;
            Map<String, String> noteMap = new Map<String, String>();
            noteMap.put('refNoteId', noteList[0].Id);
            noteMap.put('noteDate', Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day());
            noteMap.put('noteValue', 'new note value');
            noteMap.put('refRequestId', rrList[0].Id);
            noteMap.put('relatedRecordId', urList[0].Id);
            String result = RefRequestProjectControllerSLDS.createNote(JSON.serialize(noteMap), true);
            system.assert(result == 'success');
            noteMap = new Map<String, String>();
            noteMap.put('refNoteId', noteList[0].Id);
            noteMap.put('noteDate', Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day());
            noteMap.put('noteValue', 'new note value');
            noteMap.put('refRequestId', rrList[0].Id);
            noteMap.put('relatedRecordId', arList[0].Id);
            result = RefRequestProjectControllerSLDS.createNote(JSON.serialize(noteMap), false);
            system.assert(result == 'success');
            result = RefRequestProjectControllerSLDS.createNote('', false);
            system.assert(result != 'success');
        Test.stopTest();
    }

    /**
     * method to test getRefRequestObject method
     * author: Gaurav Saini (8 Apr, 2018)
     */
    public static testmethod void testGetRefRequestObject() {
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
        User u = TestDataFactory.createUser();
        insert u;
        List<Reference_Request__c> rrList = TestDataFactory.createReferenceRequest();
        rrList[0].Adv_Routing_Group__c = 'a,b';
        insert rrList;
        List<Reference_Request_Additional_Info__c> addInfoList = createAddInfo(u);
        insert addInfoList;
        List<Reference_Request_Account__c> arList = TestDataFactory.createAccountRequests(accounts, rrList, refTypeList);
        insert arList;
        arList[0].Reference_Request_Additional_Info__c = addInfoList[0].Id;
        arList[1].Reference_Request_Additional_Info__c = addInfoList[0].Id;
        arList[2].Reference_Request_Additional_Info__c = addInfoList[0].Id;
        update arList;
        List<Reference_Request_Account_Contact__c> crList = TestDataFactory.createContactRequests(contacts, arList, refTypeList);
        insert crList;
        List<Unspecified_Request__c> urList = TestDataFactory.createUnspecifiedRequest(rrList, refTypeList);
        insert urList;
        List<Label__c> filterList = TestDataFactory.createLabels();
        insert filterList;
        List<Reference_Request_Label__c> rrLabelList = new List<Reference_Request_Label__c>();
        rrLabelList.add(new Reference_Request_Label__c(Label__c = filterList[0].Id, Reference_Request__c = rrList[0].Id));
        insert rrLabelList;

        Test.startTest();
            List<Community_Invite__c> ciList = TestDataFactory.createCommunityInvite(arList);
            insert ciList;
            List<String> refTypeIds = new List<String>();
            List<Reference_Type_Mapping__c> rtmList = new List<Reference_Type_Mapping__c>();

            for (Referenceability_Type__c rt : refTypeList) {
                refTypeIds.add(rt.Id);
                rtmList.add(new Reference_Type_Mapping__c(Name = 'OwnerId', Visible__c = true, Referenceability_Type__c = rt.Id));
            }
            rtmList.add(new Reference_Type_Mapping__c(Name = 'rtm to delete', Visible__c = true, Referenceability_Type__c = refTypeList[0].Id));
            insert rtmList;
            String result = RefRequestProjectControllerSLDS.getRefRequestObject(rrList[0].Id);

            String result1 = RefRequestProjectControllerSLDS.getAdditionalFieldsInfo(refTypeList[0].Id, addInfoList[0].Id);

            String result2 = RefRequestProjectControllerSLDS.getAlreadyPostedRefTypes(rrList[0].Id);
            system.assert(result != null);

            String result3 = RefRequestProjectControllerSLDS.saveRequestSubject('test new subject', rrList[0].Id);
            system.assert(result3 == 'success');
            String result4 = RefRequestProjectControllerSLDS.saveRequestSubject('test new subject', 'error id');
            system.assert(result4 != 'success');

        Test.stopTest();
    }

    /**
     * method to test addNewRequest method
     * author: Gaurav Saini (8 Apr, 2018)
     */
    public static testmethod void testAddNewRequest() {
        Custom_Settings__c cs = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
        User u = TestDataFactory.createUser();
        insert u;
        List<Reference_Request__c> rrList = TestDataFactory.createReferenceRequest();
        insert rrList;
        List<Reference_Request_Account__c> arList = TestDataFactory.createAccountRequests(accounts, rrList, refTypeList);
        insert arList;
        List<Unspecified_Request__c> urList = TestDataFactory.createUnspecifiedRequest(rrList, refTypeList);
        insert urList;

        Test.startTest();
            Map<String, String> requestMap = new Map<String, String>();
            requestMap.put('accountId', accounts[0].Id);
            requestMap.put('refRequestId', rrList[0].Id);
            requestMap.put('refTypeId', refTypeList[0].Id);
            requestMap.put('deadline', Date.today().year() + '-' + Date.today().month() + '-' + (Date.today().day() + 2));
            requestMap.put('requesterId', rrList[0].Requester__c);
            requestMap.put('accountId', accounts[0].Id);
            requestMap.put('accountId', accounts[0].Id);

            String result = RefRequestProjectControllerSLDS.addNewRequest(JSON.serialize(requestMap));
            system.assert(result != null);

            requestMap.put('accountId', '');
            result = RefRequestProjectControllerSLDS.addNewRequest(JSON.serialize(requestMap));
            system.assert(result != null);

            result = RefRequestProjectControllerSLDS.addNewRequest('');
            system.assert(result != null);

            List<Reference_Note__c> refNotesList = new List<Reference_Note__c>();
            refNotesList.add(new Reference_Note__c(Note__c = 'test', Note_Date__c = Date.today(), Reference_Request__c = rrList[0].Id));
            refNotesList.add(new Reference_Note__c(Note__c = 'test', Note_Date__c = Date.today(), Account_Request__c = arList[0].Id));
            refNotesList.add(new Reference_Note__c(Note__c = 'test', Note_Date__c = Date.today(), Unspecified_Request__c = urList[0].Id));
            insert refNotesList;
            List<String> requestIds = new List<String>();
            requestIds.add(rrList[0].Id);
            requestIds.add(urList[0].Id);
            requestIds.add(arList[0].Id);
            result = RefRequestProjectControllerSLDS.getRelatedNotes(JSON.serialize(requestIds));

            result = RefRequestProjectControllerSLDS.deleteRefNote(refNotesList[0].Id);
            result = RefRequestProjectControllerSLDS.deleteRefNote('error id');
        Test.stopTest();
    }

    /**
     * method to test getHitListRecords method
     * author: Gaurav Saini (8 Apr, 2018)
     */
    public static testmethod void testGetHitListRecords() {
        Custom_Settings__c cs = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        Contact con = new Contact();
        con.AccountId = accounts[0].Id;
        con.LastName = 'doe';
        con.FirstName = 'john';
        con.Email = 'john.doe@seven.com';
        insert con;
        Reference_Basic_Information__c conRBI = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = con.AccountId, Contact__c = con.Id);
        insert conRBI;
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
        User u = TestDataFactory.createUser();
        insert u;
        List<Reference_Request__c> rrList = TestDataFactory.createReferenceRequest();
        insert rrList;
        List<Reference_Request_Account__c> arList = TestDataFactory.createAccountRequests(accounts, rrList, refTypeList);
        insert arList;
        List<Unspecified_Request__c> urList = TestDataFactory.createUnspecifiedRequest(rrList, refTypeList);
        insert urList;

        Test.startTest();
            List<Hit_List__c> hitListRecords = new List<Hit_List__c>();
            hitListRecords.add(new Hit_List__c(Note__c = 'test con hl', Reference_Request__c = rrList[0].Id, Deadline__c = Date.today(), Account__c = con.AccountId, Contact__c = con.Id));
            hitListRecords.add(new Hit_List__c(Note__c = 'test acc hl', Reference_Request__c = rrList[0].Id, Deadline__c = Date.today(), Account__c = accounts[1].Id));
            insert hitListRecords;

            List<String> hlIds = new List<String>();
            hlIds.add(hitListRecords[0].Id);
            hlIds.add(hitListRecords[1].Id);

            String hlWrapperListJson = RefRequestProjectControllerSLDS.getHitListRecords(rrList[0].Id);
            system.assert(hlWrapperListJson != null);

            Map<String, String> requestMap = new Map<String, String>();
            requestMap.put('refTypeId', refTypeList[0].Id);
            requestMap.put('accRequestId', arList[0].Id);
            requestMap.put('deadline', Date.today().year() + '-' + Date.today().month() + '-' + (Date.today().day()));
            requestMap.put('reqNotes', 'test');
            requestMap.put('addInfoId', '');
            requestMap.put('accountId', accounts[0].Id);
            requestMap.put('requestStatus', 'In Progress');

            List<RefRequestProjectControllerSLDS.HitListWrapper> hlWrapperList
                    = (List<RefRequestProjectControllerSLDS.HitListWrapper>)JSON.deserialize(hlWrapperListJson, List<RefRequestProjectControllerSLDS.HitListWrapper>.class);
            
            /*
            String result = RefRequestProjectControllerSLDS.assignHitRecordToRequest(JSON.serialize(hlWrapperList[0]), false, JSON.serialize(requestMap), true, rrList[0].Id, rrList[0].Requester__c);
            system.assert(result != null);
            */

            hlWrapperList[1].disposition = 'Released: Contact Declined';
            String result = RefRequestProjectControllerSLDS.dispositionHitList(JSON.serialize(hlWrapperList[1]), false, JSON.serialize(requestMap), rrList[0].Id, rrList[0].Requester__c);
            system.assert(result != null);

            hlWrapperList[1].disposition = 'Released: Contact Unresponsive';
            result = RefRequestProjectControllerSLDS.dispositionHitList(JSON.serialize(hlWrapperList[1]), false, JSON.serialize(requestMap), rrList[0].Id, rrList[0].Requester__c);
            system.assert(result != null);

            hlWrapperList[1].disposition = 'Agreed';
            result = RefRequestProjectControllerSLDS.dispositionHitList(JSON.serialize(hlWrapperList[1]), false, JSON.serialize(requestMap), rrList[0].Id, rrList[0].Requester__c);
            system.assert(result != null);

            hlWrapperList[1].disposition = 'Agreed';
            result = RefRequestProjectControllerSLDS.dispositionHitList('', false, JSON.serialize(requestMap), rrList[0].Id, rrList[0].Requester__c);
            system.assert(result != null);
            
            requestMap = new Map<String, String>();
            requestMap.put('refTypeId', refTypeList[0].Id);
            requestMap.put('unspecRequestId', urList[0].Id);
            requestMap.put('deadline', Date.today().year() + '-' + Date.today().month() + '-' + (Date.today().day()));
            requestMap.put('reqNotes', 'test');
            requestMap.put('addInfoId', '');
            requestMap.put('accountId', '');
            requestMap.put('requestStatus', 'In Progress');

            /*
            result = RefRequestProjectControllerSLDS.assignHitRecordToRequest(JSON.serialize(hlWrapperList[1]), true, JSON.serialize(requestMap), true, rrList[0].Id, rrList[0].Requester__c);
            system.assert(result != null);
            */

            hlWrapperList[1].disposition = 'Agreed';
            result = RefRequestProjectControllerSLDS.dispositionHitList(JSON.serialize(hlWrapperList[1]), true, JSON.serialize(requestMap), rrList[0].Id, rrList[0].Requester__c);
            system.assert(result != null);

            result = RefRequestProjectControllerSLDS.assignHitRecordToRequest('', true, JSON.serialize(requestMap), true, rrList[0].Id, rrList[0].Requester__c);
            system.assert(result != null);

            result = RefRequestProjectControllerSLDS.releaseAllHitLists(JSON.serialize(hlIds));
            system.assert(result != null);

            result = RefRequestProjectControllerSLDS.releaseAllHitLists('');
            system.assert(result != null);

            hlWrapperList[0].notes = 'test new notes';
            result = RefRequestProjectControllerSLDS.updateHitListNote(JSON.serialize(hlWrapperList[0]));

            hlWrapperList[0].notes = 'test new notes';
            result = RefRequestProjectControllerSLDS.updateHitListNote('');
            system.assert(result != null);
        Test.stopTest();
    }

    /**
     * method to test getRefRequestObject method
     * author: Gaurav Saini (8 Apr, 2018)
     */
    public static testmethod void testGetRefRequestObject1() {
    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
        User u = TestDataFactory.createUser();
        insert u;
        List<Reference_Request__c> rrList = TestDataFactory.createReferenceRequest();
        rrList[0].Adv_Routing_Group__c = 'a,b';
        insert rrList;
        List<Reference_Request_Additional_Info__c> addInfoList = createAddInfo(u);
        insert addInfoList;
        List<Reference_Request_Account__c> arList = TestDataFactory.createAccountRequests(accounts, rrList, refTypeList);
        insert arList;
        arList[0].Reference_Request_Additional_Info__c = addInfoList[0].Id;
        arList[1].Reference_Request_Additional_Info__c = addInfoList[0].Id;
        arList[2].Reference_Request_Additional_Info__c = addInfoList[0].Id;
        update arList;
        List<Reference_Request_Account_Contact__c> crList = TestDataFactory.createContactRequests(contacts, arList, refTypeList);
        insert crList;
        List<Unspecified_Request__c> urList = TestDataFactory.createUnspecifiedRequest(rrList, refTypeList);
        insert urList;
        List<Label__c> filterList = TestDataFactory.createLabels();
    	filterList[0].Show_in_P2P__c = true;
    	filterList[0].Required_in_P2P__c = true;
        insert filterList;
        cs.Adv_Rt_Acct_Team_Object__c = 'Opportunity';
        cs.Adv_Rt_Acct_Team_Routeby__c = 'StageName';
        cs.Adv_Rt_Acct_Team_User__c = 'CreatedById';
        update cs;
        List<Attribute__c> attributeList = new List<Attribute__c>();
        attributeList.add(new Attribute__c(Name = 'Root Attribute', Parent__c = null, ParentIds__c = null));
        insert attributeList;
        List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attributeList, 1, 5);
        insert childAttList;
        List<Attributes_Labels__c> attLabelList = TestDataFactory.setUpAttributeLabels(filterList, attributeList);

        Test.startTest();
            List<Reference_Type_Mapping__c> rtmList = new List<Reference_Type_Mapping__c>();
            List<String> refTypeIds = new List<String>();
            List<String> advRoutingGroups = new List<String>();
            advRoutingGroups.add('Test 1');

            for (Referenceability_Type__c rt : refTypeList) {
                refTypeIds.add(rt.Id);
                rtmList.add(new Reference_Type_Mapping__c(Name = 'OwnerId', Visible__c = true, Required__c = true, Referenceability_Type__c = rt.Id));
            }
            rtmList[0].Label__c = filterList[0].Id;
            rtmList[1].Label__c = filterList[1].Id;
            rtmList[2].Label__c = filterList[2].Id;
            insert rtmList;
            List<Advanced_Routing__c> advRoutingList = new List<Advanced_Routing__c>();
            advRoutingList.add(new Advanced_Routing__c(Adv_Routing_Attribute__c = childAttList[0].Id, Adv_Routing_Client_Value__c = 'Test 1'));
            insert advRoutingList;
            List<Reference_Request_Label__c> rrLabelList = new List<Reference_Request_Label__c>();
            rrLabelList.add(new Reference_Request_Label__c(Label__c = filterList[0].Id, Reference_Request__c = rrList[0].Id));
            rrLabelList.add(new Reference_Request_Label__c(Label__c = filterList[1].Id, Reference_Request__c = rrList[0].Id));
            insert rrLabelList;
            Set<String> rrLabelIds = new Set<String>();

            for (Reference_Request_Label__c rrl : rrLabelList) {
                rrLabelIds.add(rrl.Id);
            }
            List<Reference_Request_Label_Attribute__c> rrLabelAtt = new List<Reference_Request_Label_Attribute__c>();
            rrLabelAtt.add(new Reference_Request_Label_Attribute__c(Attribute__c = childAttList[0].Id, Reference_Request_Label__c = rrLabelList[0].Id));
            rrLabelAtt.add(new Reference_Request_Label_Attribute__c(Attribute__c = childAttList[1].Id, Reference_Request_Label__c = rrLabelList[0].Id));
            rrLabelAtt.add(new Reference_Request_Label_Attribute__c(Attribute__c = childAttList[0].Id, Reference_Request_Label__c = rrLabelList[1].Id));
            rrLabelAtt.add(new Reference_Request_Label_Attribute__c(Attribute__c = childAttList[1].Id, Reference_Request_Label__c = rrLabelList[1].Id));
            insert rrLabelAtt;

            String result1 = RefRequestProjectControllerSLDS.getFiltersInfo(JSON.serialize(rrLabelIds), JSON.serialize(refTypeIds), JSON.serialize(advRoutingGroups),false, true);
            system.assert(result1 != null);

            String result2 = RefRequestProjectControllerSLDS.getFiltersInfo(JSON.serialize(rrLabelIds), JSON.serialize(refTypeIds), JSON.serialize(new List<String>()),false, true);
            system.assert(result2 != null);

            Map<String, List<RefRequestProjectControllerSLDS.AttributeLabelWrapper>> filterAttributesMap
                    = (Map<String, List<RefRequestProjectControllerSLDS.AttributeLabelWrapper>>)JSON.deserialize(result2, Map<String, List<RefRequestProjectControllerSLDS.AttributeLabelWrapper>>.class);
            Map<String, Set<String>> oldFilterMap = new Map<String, Set<String>>();
            Map<String, Set<String>> newFilterMap = new Map<String, Set<String>>();
            newFilterMap.put(filterList[2].Id, new Set<String>());
            newFilterMap.get(filterList[2].Id).add(childAttList[2].Id);
            Map<String, String> rrLabelMap = new Map<String, String>();
            rrLabelMap.put(rrList[0].Id, filterList[0].Id);

            for (String filterId : filterAttributesMap.keySet()) {
                oldFilterMap.put(filterId, new Set<String>());

                for (RefRequestProjectControllerSLDS.AttributeLabelWrapper att : filterAttributesMap.get(filterId)) {
                    
                    if (oldFilterMap.get(filterId).size() == 0) {
                        oldFilterMap.get(filterId).add(att.attId);
                    }
                }

                if (newFilterMap.containsKey(filterId) && newFilterMap.size() == 0) {
                    newFilterMap.put(filterId, new Set<String>());
                    
                    for (RefRequestProjectControllerSLDS.AttributeLabelWrapper att : filterAttributesMap.get(filterId)) {
                        newFilterMap.get(filterId).add(att.attId);
                    }
                }
            }

            String saveResult = RefRequestProjectControllerSLDS.saveFiltersInfo(JSON.serialize(oldFilterMap), JSON.serialize(newFilterMap), rrList[0].Id, JSON.serialize(rrLabelMap));
            system.assert(saveResult != null);

            saveResult = RefRequestProjectControllerSLDS.saveFiltersInfo(JSON.serialize(oldFilterMap), JSON.serialize(newFilterMap), rrList[0].Id, JSON.serialize(new Map<String, String>()));
            system.assert(saveResult != null);

            saveResult = RefRequestProjectControllerSLDS.saveFiltersInfo('', JSON.serialize(newFilterMap), rrList[0].Id, JSON.serialize(new Map<String, String>()));
            system.assert(saveResult != null);
        Test.stopTest();
    }

    static List<Reference_Request_Additional_Info__c> createAddInfo(User u) {
        List<Reference_Request_Additional_Info__c> tempAddInfo = new List<Reference_Request_Additional_Info__c>();
        tempAddInfo.add(new Reference_Request_Additional_Info__c(OwnerId = u.Id));
        return tempAddInfo;
    }

    //REF-1964
    public static void setUpData() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        accounts = TestDataFactory.createAccounts();
        insert accounts;
        contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpAccountRBI(accounts);
        refTypeList = TestDataFactory.createUserRewardReferenceabilityType();
        insert refTypeList;
        rrList = TestDataFactory.createReferenceRequest();
        insert rrList;
        arList = TestDataFactory.createAccountRequests(accounts, rrList, refTypeList);
        insert arList;
        urList = TestDataFactory.createUnspecifiedRequest(rrList, refTypeList);
        urList[0].Influitive_Challenge_Id__c = 'test123';
        urList[0].Influitive_Challenge_Status__c = 'Unpublish';
        insert urList;
        Community_Invite__c comInvite = new Community_Invite__c();
        comInvite.Referenceability_Type__c = urList[0].Reference_Type_Needed__c;
        comInvite.Reference_Request__c = urList[0].Reference_Request__c;
        comInvite.Unspecified_Request__c = urList[0].Id;
        insert comInvite;
        CIs = new List<Community_Invite__c> {comInvite};
        Community_Invite_Contact__c newCIC = new Community_Invite_Contact__c();
        newCIC.Community_Invite__c = comInvite.Id;
        newCIC.Contact__c = contacts[0].Id;
        newCIC.Response__c = 'No Response';
        newCIC.Challenge_Id__c = 'test123';
        insert newCIC;
        CICs = new List<Community_Invite_Contact__c> {newCIC};
        rewards = TestDataFactory.createRewards(accounts, contacts);
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = rrList[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
    }
    
    @isTest static void testPostChallengeInInfluitive() {
        setUpData();
        String inflWrap = '{"participantLimit":"4","notes":"test","endAt":"2019-3-29","advocatesId":["' + 
                           contacts[0].id + '"],"listOfCIC":[],"unspecifiedRequestId":"'+ 
                           urList[0].id +'","accountName":"Unspecified","reftypeId":"' + refTypeList[0].id + '"}';
            
        Test.startTest();
        String result = RefRequestProjectControllerSLDS.postChallengeInInfluitive(inflWrap);
        Test.stopTest();
        
        System.assert(result != null, 'Challenge Posted.');
    }
    
    @isTest static void testCreateCommunityInviteContactRecords() {
        setUpData();
        
        RefRequestProjectControllerSLDS.InfluitiveWrapper influtiveWrap = new RefRequestProjectControllerSLDS.InfluitiveWrapper();
        influtiveWrap.endAt = '2019-4-6';
        influtiveWrap.unspecifiedRequestId = urList[0].id;
        influtiveWrap.challengeId = 'test123';
        influtiveWrap.reftypeId = refTypeList[0].id;
        Set<String> contactIds = new Set<String>();
        contactIds.add(contacts[0].id);
        
        Test.startTest();
        List<Community_Invite_Contact__c> result = RefRequestProjectControllerSLDS.createCommunityInviteContactRecords(influtiveWrap,contactIds);
        Test.stopTest();
        
        System.assert(result != null, 'CIC records created.');
    }
    
    @isTest static void testGetRelatedCICByChallengeId() {
        setUpData();
        List<String> challengeId = new List<String>();
        challengeId.add('test123');
        
        Test.startTest();
        Map<String,List<Community_Invite_Contact__c>> result = RefRequestProjectControllerSLDS.getRelatedCICByChallengeId(JSON.serialize(challengeId));
        Test.stopTest();
        
        System.assert(result != null, 'Get CIC by ChallengeId.');
    }
    
    @isTest static void testAsignAdvocateToChallenge() {
        setUpData();
        
        Test.startTest();
        String result = RefRequestProjectControllerSLDS.assignAdvocateToChallenge(contacts[0].Id,urList[0].id);
        Test.stopTest();
        
        System.assert(result != null, 'Advocate assigned to challenge.');
    }
    
    @isTest static void testUpdateChallengeStatus() {
        setUpData();
            
        Test.startTest();
        String result = RefRequestProjectControllerSLDS.updateChallengeStatus('Publish',urList[0].id);
        Test.stopTest();
        
        System.assert(result != null, 'Challenge status updated.');
    }
    
    @isTest static void testGetFilesAssociatedWithReferenceRequest() {
        setUpData();
            
        Test.startTest();
        String result = RefRequestProjectControllerSLDS.getFilesAssociatedWithReferenceRequest(rrList[0].id);
        Test.stopTest();
        
        System.assert(result != null, 'Got files associated with request.');
    }
}