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
@isTest
public with sharing class TestAddNewReferenceabilitySLDS {
    
    /**
     * test method for constructor
     * author: Gaurav Saini (27 Sep, 2017)
     */
    static testmethod void testConstructor() {
    	List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> contactRBIs = TestDataFactory.setUpContactRBI(contacts);
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Referenceability__c> refList = TestDataFactory.createReferenceability(accounts, contacts, refTypes);
        insert refList;
        AddNewReferenceabilitySLDS testObj = new AddNewReferenceabilitySLDS(new ApexPages.StandardController(refList[0]));
        AddNewReferenceabilitySLDS testObj1 = new AddNewReferenceabilitySLDS();
        String namespace = testObj.nameSpace;
        system.assertNotEquals(testObj.dateString, null);
        system.assertNotEquals(AddNewReferenceabilitySLDS.getDateFormat(), '');
    }
    
    /**
     * test method for getAccountWrapperList method
     * author: Gaurav Saini (27 Sep, 2017)
     */
    static testmethod void testGetAccountWrapperList() {
    	Schema.DescribeSObjectResult describeResult = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c').getDescribe();
    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
    	cs.Shared_Contacts__c = true;
        cs.Shared_Contact_Object__c = describeResult.getName();
		cs.Shared_Account_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe().getName();
		cs.Shared_Contact_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Contact__c').getDescribe().getName();
		cs.Roll_up_Attributes_to_Primary_Account__c = true;
        cs.Roll_up_Referenceability_to_Primary_Acc__c = true;
        cs.Inherit_Attributes_from_All_Accounts__c = true;
		update cs;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        Reference_Basic_Information__c accRBI = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[0].Id);
        insert accRBI;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Hit_List__c> sharedContacts = new List<Hit_List__c>();
        sharedContacts.add(new Hit_List__c(Account__c = accounts[0].Id, Contact__c = contacts[1].Id));
        insert sharedContacts;
        String accWrapListJSON = AddNewReferenceabilitySLDS.getAccountWrapperList(contacts[1].Id, '');
        System.assertNotEquals(accWrapListJSON, '');
    }
    
    /**
     * test method for existing getting referenceability object
     * author: Gaurav Saini (28 Sep, 2017)
     */
    static testmethod void testGetReferenceabilityObj() {
    	List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> contactRBIs = TestDataFactory.setUpContactRBI(contacts);
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Referenceability__c> refList = TestDataFactory.createReferenceability(accounts, contacts, refTypes);
        insert refList;
        String refObject = AddNewReferenceabilitySLDS.getReferenceabilityObj(refList[0].Id);
        system.assertNotEquals(refObject, '');
        String refObject1 = AddNewReferenceabilitySLDS.getReferenceabilityObj('');
        system.assertEquals(refObject1, '');
    }
    
    /**
     * test method for getting list of contacts
     * author: Gaurav Saini (28 Sep, 2017)
     */
    static testMethod void testGetContactWrapperList() {
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        Reference_Basic_Information__c conRBI = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[0].Id, Contact__c = contacts[0].Id);
        insert conRBI;
        String contactWrapperJSON = AddNewReferenceabilitySLDS.getContactWrapperList('', accounts[0].Id);
        List<AddNewReferenceabilitySLDS.ContactWrapper> contactWrapList = new List<AddNewReferenceabilitySLDS.ContactWrapper>();
        contactWrapList = (List<AddNewReferenceabilitySLDS.ContactWrapper>)JSON.deserialize(contactWrapperJSON, List<AddNewReferenceabilitySLDS.ContactWrapper>.class);
        system.assertEquals(contactWrapList.size(), 2);
        
        String contactWrapperJSON1 = AddNewReferenceabilitySLDS.getContactWrapperList('', accounts[1].Id);
        List<AddNewReferenceabilitySLDS.ContactWrapper> contactWrapList1 = new List<AddNewReferenceabilitySLDS.ContactWrapper>();
        contactWrapList1 = (List<AddNewReferenceabilitySLDS.ContactWrapper>)JSON.deserialize(contactWrapperJSON1, List<AddNewReferenceabilitySLDS.ContactWrapper>.class);
        system.assertEquals(contactWrapList1.size(), 2);
        
        String contactWrapperJSON2 = AddNewReferenceabilitySLDS.getContactWrapperList(null, null);
        system.assertEquals(contactWrapperJSON2, '');
    }
    
    /**
     * test method for getting list ref types
     * author: Gaurav Saini (28 Sep, 2017)
     */
    static testMethod void testgetRefTypeWrapperList() {
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        String refTypesJSON = AddNewReferenceabilitySLDS.getRefTypeWrapperList();
        List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper> refTypeWrapList
        			= (List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper>)JSON.deserialize(refTypesJSON, List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper>.class);
        system.assertNotEquals(refTypeWrapList.size(), 0);
    }
    
    /**
     * test method for getting ref type status picklist values
     * author: Gaurav Saini (28 Sep, 2017)
     */
    static testMethod void testGetStatusPickList() {
        List<String> options = (List<String>)JSON.deserialize(AddNewReferenceabilitySLDS.getStatusPickList(), List<String>.class);
        system.assertNotEquals(options.size(), 0);
    }
    
    /**
     * test method for getting reference status of contact
     * author: Gaurav Saini (28 Sep, 2017)
     */
    static testMethod void testGetContactReferenceStatus() {
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> conRBIList = new List<Reference_Basic_Information__c>();
        conRBIList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[0].Id, Contact__c = contacts[0].Id));
        conRBIList.add(new Reference_Basic_Information__c(Reference_Program_Candidate__c = true, Is_Referenceable__c = false, Account__c = accounts[1].Id, Contact__c = contacts[1].Id));
        conRBIList.add(new Reference_Basic_Information__c(Reference_Program_Candidate__c = false, Is_Referenceable__c = false, Account__c = accounts[2].Id, Contact__c = contacts[2].Id));
        insert conRBIList;
        String contactReferenceStatus = AddNewReferenceabilitySLDS.getContactReferenceStatus(contacts[0].Id);
        String contactIsReferenceable = contactReferenceStatus.split(',')[0];
        system.assertEquals(contactIsReferenceable, 'true');
        contactReferenceStatus = AddNewReferenceabilitySLDS.getContactReferenceStatus(contacts[1].Id);
        contactIsReferenceable = contactReferenceStatus.split(',')[0];
        system.assertEquals(contactIsReferenceable, 'false');
        contactReferenceStatus = AddNewReferenceabilitySLDS.getContactReferenceStatus(contacts[2].Id);
        contactIsReferenceable = contactReferenceStatus.split(',')[0];
        system.assertEquals(contactIsReferenceable, 'false');
        contactReferenceStatus = AddNewReferenceabilitySLDS.getContactReferenceStatus(contacts[3].Id);
        contactIsReferenceable = contactReferenceStatus.split(',')[0];
        system.assertEquals(contactIsReferenceable, 'false');
    }
    
    /**
     * test method for getting reference status of account
     * author: Gaurav Saini (28 Sep, 2017)
     */
    static testMethod void testGetAccountReferenceStatus() {
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = new List<Reference_Basic_Information__c>();
        accRBIList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[0].Id));
        accRBIList.add(new Reference_Basic_Information__c(Reference_Program_Candidate__c = true, Is_Referenceable__c = false, Account__c = accounts[1].Id));
        accRBIList.add(new Reference_Basic_Information__c(Reference_Program_Candidate__c = false, Is_Referenceable__c = false, Account__c = accounts[2].Id));
        insert accRBIList;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> contactRBIs = TestDataFactory.setUpContactRBI(contacts);
        String accountReferenceStatus = AddNewReferenceabilitySLDS.getAccountReferenceStatus(accounts[0].Id);
        String accountIsReferenceable = accountReferenceStatus.split(',')[0];
        system.assertEquals(accountIsReferenceable, 'true');
        accountReferenceStatus = AddNewReferenceabilitySLDS.getAccountReferenceStatus(accounts[1].Id);
        accountIsReferenceable = accountReferenceStatus.split(',')[0];
        system.assertEquals(accountIsReferenceable, 'false');
        accountReferenceStatus = AddNewReferenceabilitySLDS.getAccountReferenceStatus(accounts[2].Id);
        accountIsReferenceable = accountReferenceStatus.split(',')[0];
        system.assertEquals(accountIsReferenceable, 'false');
        accountReferenceStatus = AddNewReferenceabilitySLDS.getAccountReferenceStatus(accounts[3].Id);
        accountIsReferenceable = accountReferenceStatus.split(',')[0];
        system.assertEquals(accountIsReferenceable, 'false');
    }
    
    /**
     * test method for saving referenceability with shared contacts
     * author: Gaurav Saini (28 Sep, 2017)
     */
    static testMethod void testSaveNewReferenceability() {
        Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c');
		Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Shared_Contacts__c = true;
        customSetting.Shared_Contact_Object__c = describeResult.getName();
		customSetting.Shared_Account_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe().getName();
		customSetting.Shared_Contact_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Contact__c').getDescribe().getName();
		customSetting.Roll_up_Attributes_to_Primary_Account__c = true;
        customSetting.Roll_up_Referenceability_to_Primary_Acc__c = true;
        customSetting.Inherit_Attributes_from_All_Accounts__c = true;
		update customSetting;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(contacts);
    	conRBIList[1].Roll_up_Referenceability_to_All_Accounts__c = true;
    	conRBIList[1].Roll_up_Referenceability_to_Primary_Acc__c = false;
    	conRBIList[1].Inherit_Attributes_from_All_Accounts__c = true;
    	conRBIList[1].Inherit_Attributes_from_Primary_Account__c = false;
    	conRBIList[1].Roll_up_Attributes_to_All_Accounts__c = true;
    	conRBIList[1].Roll_up_Attributes_to_Primary_Account__c = false;
    	update conRBIList;
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        
        Test.startTest();
	    String accWrapListJSON = AddNewReferenceabilitySLDS.getAccountWrapperList(contacts[1].Id, '');
	    List<AddNewReferenceabilitySLDS.AccountWrapper> accWrapList
	    			= (List<AddNewReferenceabilitySLDS.AccountWrapper>)JSON.deserialize(accWrapListJSON, List<AddNewReferenceabilitySLDS.AccountWrapper>.class);
	    
	    String refTypesWrapperJSON = AddNewReferenceabilitySLDS.getRefTypeWrapperList();
	    List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper> refTypeWrapList
	    			= (List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper>)JSON.deserialize(refTypesWrapperJSON, List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper>.class);
	    
	    AddNewReferenceabilitySLDS.ReferenceabilityWrapper refWrapperObj
	    			= new AddNewReferenceabilitySLDS.ReferenceabilityWrapper();
	    refWrapperObj.selectedContact = contacts[1].Id;
	    refWrapperObj.selectedAccounts = accWrapList;
	    refWrapperObj.selectedRefTypes = new List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper> { refTypeWrapList[0] };
	    refWrapperObj.refStatus = 'Approved';
	    refWrapperObj.comments = 'test comments';
	    refWrapperObj.verifiedDate = system.today();
	    
	    String saveResult = AddNewReferenceabilitySLDS.saveReferenceability(JSON.serialize(refWrapperObj), true, false, true, false, '', '', '', false, false);
	    system.assertEquals(saveResult, '');
	    
        customSetting.Roll_up_Referenceability_to_Primary_Acc__c = false;
        customSetting.Roll_up_Referenceability_to_All_Accounts__c = true;
		update customSetting;
		
		refWrapperObj = new AddNewReferenceabilitySLDS.ReferenceabilityWrapper();
	    refWrapperObj.selectedContact = contacts[1].Id;
	    refWrapperObj.selectedAccounts = accWrapList;
	    refWrapperObj.selectedRefTypes = new List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper> { refTypeWrapList[1] };
	    refWrapperObj.refStatus = 'Approved';
	    refWrapperObj.comments = 'test comments';
	    refWrapperObj.verifiedDate = system.today();
	    
	    saveResult = AddNewReferenceabilitySLDS.saveReferenceability(JSON.serialize(refWrapperObj), true, false, true, false, '', '', '', false, false);
	    system.assertEquals(saveResult, '');
	    
        Test.stopTest();
    }
    
    /**
     * test method for saving referenceability without shared contacts
     * author: Gaurav Saini (28 Sep, 2017)
     */
    static testMethod void testSaveNewReferenceability1() {
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(contacts);
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        
        Test.startTest();
	    String accWrapListJSON = AddNewReferenceabilitySLDS.getAccountWrapperList(contacts[1].Id, '');
	    List<AddNewReferenceabilitySLDS.AccountWrapper> accWrapList
	    			= (List<AddNewReferenceabilitySLDS.AccountWrapper>)JSON.deserialize(accWrapListJSON, List<AddNewReferenceabilitySLDS.AccountWrapper>.class);
	    
	    String refTypesWrapperJSON = AddNewReferenceabilitySLDS.getRefTypeWrapperList();
	    List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper> refTypeWrapList
	    			= (List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper>)JSON.deserialize(refTypesWrapperJSON, List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper>.class);
	    AddNewReferenceabilitySLDS.ReferenceabilityWrapper refWrapperObj
	    			= new AddNewReferenceabilitySLDS.ReferenceabilityWrapper();
	    refWrapperObj.selectedContact = contacts[1].Id;
	    refWrapperObj.selectedAccounts = accWrapList;
	    refWrapperObj.selectedRefTypes = new List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper> { refTypeWrapList[0] };
	    refWrapperObj.refStatus = 'Approved';
	    refWrapperObj.comments = 'test comments';
	    refWrapperObj.verifiedDate = system.today();
	    
	    String saveResult = AddNewReferenceabilitySLDS.saveReferenceability(JSON.serialize(refWrapperObj), true, false, true, false, '', '', '', false, false);
	    system.assertEquals(saveResult, '');
	    
	    refWrapperObj = new AddNewReferenceabilitySLDS.ReferenceabilityWrapper();
	    refWrapperObj.selectedContact = '';
	    refWrapperObj.selectedAccounts = accWrapList;
	    refWrapperObj.selectedRefTypes = new List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper> { refTypeWrapList[1] };
	    refWrapperObj.refStatus = 'Approved';
	    refWrapperObj.comments = 'test comments';
	    refWrapperObj.verifiedDate = system.today();
	    
	    saveResult = AddNewReferenceabilitySLDS.saveReferenceability(JSON.serialize(refWrapperObj), true, false, true, false, '', '', '', false, false);
	    system.assertEquals(saveResult, '');
	    
	    saveResult = AddNewReferenceabilitySLDS.saveReferenceability(JSON.serialize(refWrapperObj), true, false, true, false, '', '', '', false, false);
	    system.assertNotEquals(saveResult, '');
	    
        Test.stopTest();
    }
    
    /**
     * test method for editing an existing referenceability
     * author: Gaurav Saini (29 Sep, 2017)
     */
    static testMethod void testEditReferenceability() {
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(contacts);
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        Referenceability__c testRef = new Referenceability__c(Account__c = accounts[1].Id, Contact__c = null, Referenceability_Type__c = refTypes[0].Id, Verified__c = system.today(), Status__c = 'Approved');
        insert testRef;
        
        Test.startTest();
	    String accWrapListJSON = AddNewReferenceabilitySLDS.getAccountWrapperList(contacts[1].Id, '');
	    List<AddNewReferenceabilitySLDS.AccountWrapper> accWrapList
	    			= (List<AddNewReferenceabilitySLDS.AccountWrapper>)JSON.deserialize(accWrapListJSON, List<AddNewReferenceabilitySLDS.AccountWrapper>.class);
	    
	    String refTypesWrapperJSON = AddNewReferenceabilitySLDS.getRefTypeWrapperList();
	    List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper> refTypeWrapList
	    			= (List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper>)JSON.deserialize(refTypesWrapperJSON, List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper>.class);
	    AddNewReferenceabilitySLDS.ReferenceabilityWrapper refWrapperObj
	    			= new AddNewReferenceabilitySLDS.ReferenceabilityWrapper();
	    refWrapperObj.selectedContact = contacts[1].Id;
	    refWrapperObj.selectedAccounts = accWrapList;
	    refWrapperObj.selectedRefTypes = refTypeWrapList;
	    refWrapperObj.refStatus = 'Approved';
	    refWrapperObj.comments = 'test comments';
	    refWrapperObj.verifiedDate = system.today();
	    
	    String existingRefJSON = AddNewReferenceabilitySLDS.getReferenceabilityObj(testRef.Id);
	    
	    String saveResult = AddNewReferenceabilitySLDS.saveReferenceability(JSON.serialize(refWrapperObj), true, false, true, false, existingRefJSON, '', '', false, false);
	    system.assertEquals(saveResult, '');
	    
        Test.stopTest();
    }
    
    /**
     * test method for save referenceability from profile update
     * author: Gaurav Saini (29 Sep, 2017)
     */
    static testMethod void testSaveReferenceabilityFromProfileUpdate() {
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(contacts);
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        Referenceability_Type__c testRefType = new Referenceability_Type__c(Name = 'test ref type', Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true, min_lead_time_per_request_type__c = 10, max_accounts_per_request_type__c = 15, Reward_points__c = 100, Note__c = 'test notes', Sales_Point__c = 500);
        insert testRefType;
        Referenceability__c testRef = new Referenceability__c(Account__c = accounts[0].Id, Contact__c = null, Referenceability_Type__c = testRefType.Id, Verified__c = system.today(), Status__c = 'Approved');
        insert testRef;
        List<Reference_Refresh__c> refRefreshList = TestDataFactory.createRefRefreshRecords(accounts, accRBIList);
        refRefreshList[1].Quarantined__c = true;
        update refRefreshList[1];
        List<Reference_Refresh_Update__c> refRefreshUpdateList = new List<Reference_Refresh_Update__c>();
    	refRefreshUpdateList.add(new Reference_Refresh_Update__c(Reference_Refresh__c = refRefreshList[0].Id, Account__c = accounts[0].Id, Accept_Reject__c = 'Accept', RecordsToBeInsertedId__c = testRef.Id, Added__c = true, Referenceability__c = true));
    	insert refRefreshUpdateList;
        
        Test.startTest();
	    String accWrapListJSON = AddNewReferenceabilitySLDS.getAccountWrapperList(contacts[1].Id, '');
	    List<AddNewReferenceabilitySLDS.AccountWrapper> accWrapList
	    			= (List<AddNewReferenceabilitySLDS.AccountWrapper>)JSON.deserialize(accWrapListJSON, List<AddNewReferenceabilitySLDS.AccountWrapper>.class);
	    
	    String refTypesWrapperJSON = AddNewReferenceabilitySLDS.getRefTypeWrapperList();
	    List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper> refTypeWrapList
	    			= (List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper>)JSON.deserialize(refTypesWrapperJSON, List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper>.class);
	    AddNewReferenceabilitySLDS.ReferenceabilityWrapper refWrapperObj
	    			= new AddNewReferenceabilitySLDS.ReferenceabilityWrapper();
	    refWrapperObj.selectedContact = contacts[0].Id;
	    refWrapperObj.selectedAccounts = accWrapList;
	    refWrapperObj.selectedRefTypes = new List<AddNewReferenceabilitySLDS.ReferenceabilityTypeWrapper> { refTypeWrapList[2] };
	    refWrapperObj.refStatus = 'Approved';
	    refWrapperObj.comments = 'test comments';
	    refWrapperObj.verifiedDate = system.today();
	    
	    String profileUpdateJSON = AddNewReferenceabilitySLDS.getProfileUpdateRecord(refRefreshList[0].Id);
	    List<AddNewReferenceabilitySLDS.ProfileUpdateWrapper> profileUpdateList
	    			= (List<AddNewReferenceabilitySLDS.ProfileUpdateWrapper>)JSON.deserialize(profileUpdateJSON, List<AddNewReferenceabilitySLDS.ProfileUpdateWrapper>.class);
	    
	    String saveResult = AddNewReferenceabilitySLDS.saveReferenceability(JSON.serialize(refWrapperObj), true, false, true, false, '', JSON.serialize(profileUpdateList[0]), JSON.serialize(new Set<String>()), true, false);
	    system.assertEquals(saveResult, '');
	    
	    refWrapperObj = new AddNewReferenceabilitySLDS.ReferenceabilityWrapper();
	    refWrapperObj.selectedContact = contacts[1].Id;
	    refWrapperObj.selectedAccounts = accWrapList;
	    refWrapperObj.selectedRefTypes = refTypeWrapList;
	    refWrapperObj.refStatus = 'Approved';
	    refWrapperObj.comments = 'test comments';
	    refWrapperObj.verifiedDate = system.today();
	    
	    profileUpdateJSON = AddNewReferenceabilitySLDS.getProfileUpdateRecord(refRefreshList[1].Id);
	    profileUpdateList = (List<AddNewReferenceabilitySLDS.ProfileUpdateWrapper>)JSON.deserialize(profileUpdateJSON, List<AddNewReferenceabilitySLDS.ProfileUpdateWrapper>.class);
	    
	    saveResult = AddNewReferenceabilitySLDS.saveReferenceability(JSON.serialize(refWrapperObj), true, false, true, false, '', JSON.serialize(profileUpdateList[0]), JSON.serialize(new Set<String>()), true, false);
	    system.assertEquals(saveResult, '');
	    
        Test.stopTest();
    }
    
    /**
     * test method for getting profile update referenceabilities
     * author: Gaurav Saini (29 Sep, 2017)
     */
    static testMethod void testGetProfileUpdateRefData() {
    	List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(contacts);
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Referenceability__c> accRefsList = TestDataFactory.createReferenceability(accounts, new List<Contact>(), refTypes);
        insert accRefsList;
        List<Referenceability__c> conRefsList = TestDataFactory.createReferenceability(new List<Account>(), contacts, refTypes);
        insert conRefsList;
        
        Test.startTest();
        String accProfileUpdateRefsJSON = AddNewReferenceabilitySLDS.getProfileUpdateRefData(new List<String>(), accounts[0].Id, '');
        system.assert(accProfileUpdateRefsJSON != '');
        String conProfileUpdateRefsJSON = AddNewReferenceabilitySLDS.getProfileUpdateRefData(new List<String>(), '', contacts[0].Id);
        system.assert(conProfileUpdateRefsJSON != '');
        Test.stopTest();
    }
    
    /**
     * test method for deleting referenceability
     * author: Gaurav Saini (29 Sep, 2017)
     */
    static testMethod void testDeleteReferenceability() {
    	List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(contacts);
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Referenceability__c> accRefsList = TestDataFactory.createReferenceability(accounts, new List<Contact>(), refTypes);
        insert accRefsList;
        List<Referenceability__c> conRefsList = TestDataFactory.createReferenceability(new List<Account>(), contacts, refTypes);
        insert conRefsList;
        List<Reference_Refresh__c> refRefreshList = TestDataFactory.createRefRefreshRecords(accounts, accRBIList);
        
        Test.startTest();
        String accProfileUpdateRefsJSON = AddNewReferenceabilitySLDS.getProfileUpdateRefData(new List<String>(), accounts[0].Id, '');
        String permissionMsg = AddNewReferenceabilitySLDS.getPermissionsMessage(false, true);
        String deleteResult = AddNewReferenceabilitySLDS.deleteReferenceability(accRefsList[0].Id, accProfileUpdateRefsJSON, false, refRefreshList[0].Id);
        system.assert(deleteResult == '');
        Test.stopTest();
    }
}