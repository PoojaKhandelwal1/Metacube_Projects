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
 * Test class for profile update lightning page
 * author: Gaurav Saini (12 Sep, 2017)
 */
@isTest(seeAllData = false)
public with sharing class TestReferenceRefreshControllerSLDS {
    
    /**
	 * method to test constructor
	 * author: Gaurav Saini (12 Sep, 2017)
	 */
    public static testMethod void testConstructor() {
    	Apexpages.currentPage().getParameters().put('userId', 'testUserId');
    	Apexpages.currentPage().getParameters().put('accountId', 'testAccId');
    	Apexpages.currentPage().getParameters().put('pageno', '2');
    	Apexpages.currentPage().getParameters().put('showmore', 'true');
		ReferenceRefreshControllerSLDS testObj = new ReferenceRefreshControllerSLDS();
		system.assertNotEquals(testObj.userId, '');
    }
    
    /**
	 * method to test getProfileUpdatesList method
	 * author: Gaurav Saini (12 Sep, 2017)
	 */
    public static testMethod void testGetProfileUpdatesList() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
    	List<Reference_Refresh__c> refRefreshList = TestDataFactory.createRefRefreshRecords(accounts, accRBIList);
    	String profileUpdateListJSON = ReferenceRefreshControllerSLDS.getProfileUpdatesList(Userinfo.getUserId());
    	List<ReferenceRefreshControllerSLDS.ProfileUpdateWrapper> profileUpdateList = (List<ReferenceRefreshControllerSLDS.ProfileUpdateWrapper>)JSON.deserialize(profileUpdateListJSON, List<ReferenceRefreshControllerSLDS.ProfileUpdateWrapper>.class);
    	system.assert(profileUpdateList.size() > 0);
    }
    
    /**
	 * method to test getProfileUpdatesListForPageNo method
	 * author: Gaurav Saini (12 Sep, 2017)
	 */
    public static testMethod void testGetProfileUpdatesListForPageNo() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
    	List<Reference_Refresh__c> refRefreshList = TestDataFactory.createRefRefreshRecords(accounts, accRBIList);
    	String profileUpdateListJSON = ReferenceRefreshControllerSLDS.getProfileUpdatesListForPageNo(Userinfo.getUserId(), 0);
    	List<ReferenceRefreshControllerSLDS.ProfileUpdateWrapper> profileUpdateList = (List<ReferenceRefreshControllerSLDS.ProfileUpdateWrapper>)JSON.deserialize(profileUpdateListJSON, List<ReferenceRefreshControllerSLDS.ProfileUpdateWrapper>.class);
    	system.assert(profileUpdateList.size() > 0);
    }
    
    /**
	 * method to test getAlreadyPresentProfileUpdates method
	 * author: Gaurav Saini (12 Sep, 2017)
	 */
    public static testMethod void testGetAlreadyPresentProfileUpdates() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
    	List<Reference_Refresh__c> refRefreshList = TestDataFactory.createRefRefreshRecords(accounts, accRBIList);
    	Set<String> profileUpdateIds = new Set<String>();
    	
    	for (Reference_Refresh__c rr : refRefreshList) {
    		profileUpdateIds.add(rr.Id);
    	}
    	String profileUpdateListJSON = ReferenceRefreshControllerSLDS.getAlreadyPresentProfileUpdates(Userinfo.getUserId(), JSON.serialize(profileUpdateIds));
    	List<ReferenceRefreshControllerSLDS.ProfileUpdateWrapper> profileUpdateList = (List<ReferenceRefreshControllerSLDS.ProfileUpdateWrapper>)JSON.deserialize(profileUpdateListJSON, List<ReferenceRefreshControllerSLDS.ProfileUpdateWrapper>.class);
    	system.assert(profileUpdateList.size() > 0);
    }
    
    /**
	 * method to test getAlreadyNotPresentProfileUpdates method
	 * author: Gaurav Saini (12 Sep, 2017)
	 */
    public static testMethod void testGetAlreadyNotPresentProfileUpdates() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
    	List<Reference_Refresh__c> refRefreshList = TestDataFactory.createRefRefreshRecords(accounts, accRBIList);
    	Set<String> profileUpdateIds = new Set<String>();
    	
    	for (Reference_Refresh__c rr : refRefreshList) {
    		profileUpdateIds.add(rr.Id);
    		
    		if (profileUpdateIds.size() == 2) {
    			break;
    		}
    	}
    	String profileUpdateListJSON = ReferenceRefreshControllerSLDS.getAlreadyNotPresentProfileUpdates(Userinfo.getUserId(), JSON.serialize(profileUpdateIds));
    	List<ReferenceRefreshControllerSLDS.ProfileUpdateWrapper> profileUpdateList = (List<ReferenceRefreshControllerSLDS.ProfileUpdateWrapper>)JSON.deserialize(profileUpdateListJSON, List<ReferenceRefreshControllerSLDS.ProfileUpdateWrapper>.class);
    	system.assert(profileUpdateList.size() > 0);
    }
    
    /**
	 * method to test getAccountContactIdsMap method
	 * author: Gaurav Saini (12 Sep, 2017)
	 */
    public static testMethod void testGetAccountContactIdsMap() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<String> accIds = new List<String>();
    	
    	for (Account acc : accounts) {
    		accIds.add(acc.Id);
    	}
    	String accountContactsMapJSON = ReferenceRefreshControllerSLDS.getAccountContactIdsMap(accIds);
    	system.assert(accountContactsMapJSON != null);
    }
    
    /**
	 * method to test getAttMappings method
	 * author: Gaurav Saini (12 Sep, 2017)
	 */
    public static testMethod void testGetAttMappings() {
    	List<Attribute_Mapping__c> attMapping = new List<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Account', Field__c = 'Industry', Attribute_Name__c = 'Test 1', Filter_Label_Name__c = 'Test 1', Field_Api_Name__c = 'Industry', Is_Related_Mapping__c = false, Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Inheritable__c = true));
        insert attMapping;
        String attMappingsListJSON = ReferenceRefreshControllerSLDS.getAttMappings();
        List<ReferenceRefreshControllerSLDS.AttributeMappingWrapper> attMappingsList = (List<ReferenceRefreshControllerSLDS.AttributeMappingWrapper>)JSON.deserialize(attMappingsListJSON, List<ReferenceRefreshControllerSLDS.AttributeMappingWrapper>.class);
        system.assert(attMappingsList.size() > 0);
    }
    
    /**
	 * method to test getProfileUpdateDetailList method
	 * author: Gaurav Saini (12 Sep, 2017)
	 */
    public static testMethod void testGetProfileUpdateDetailList() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
    	List<Attribute__c> attributeList = TestDataFactory.createAttribute();
    	insert attributeList;
    	List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attributeList, 1, 2);
    	insert childAttList;
    	Account_Attribute__c accAtt = new Account_Attribute__c(Account__c = accounts[0].Id, Attribute__c = childAttList[0].Id, Inheritable__c = true);
    	insert accAtt;
    	List<Reference_Refresh__c> refRefreshList = TestDataFactory.createRefRefreshRecords(accounts, accRBIList);
    	List<Reference_Refresh_Update__c> refRefreshUpdateList = new List<Reference_Refresh_Update__c>();
    	refRefreshUpdateList.add(new Reference_Refresh_Update__c(Reference_Refresh__c = refRefreshList[0].Id, Account__c = accounts[0].Id, Accept_Reject__c = 'Accept', RecordsToBeInsertedId__c = accAtt.Id, Added__c = true, Attribute__c = true));
    	insert refRefreshUpdateList;
    	String profileUpdateDetailJSON = ReferenceRefreshControllerSLDS.getProfileUpdateDetailList(refRefreshList[0].Id);
    	List<ReferenceRefreshControllerSLDS.ProfileUpdateDetailWrapper> profileUpdateDetailList = (List<ReferenceRefreshControllerSLDS.ProfileUpdateDetailWrapper>)JSON.deserialize(profileUpdateDetailJSON, List<ReferenceRefreshControllerSLDS.ProfileUpdateDetailWrapper>.class);
    	system.assert(profileUpdateDetailList.size() > 0);
    }
    
    /**
	 * method to test getAccountAttributesMap method
	 * author: Gaurav Saini (12 Sep, 2017)
	 */
    public static testMethod void testGetAccountAttributesMap() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
    	List<Attribute__c> attributeList = TestDataFactory.createAttribute();
    	insert attributeList;
    	List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attributeList, 1, 2);
    	insert childAttList;
    	List<Label__c> filterList = TestDataFactory.createLabels();
    	insert filterList;
    	TestDataFactory.createAttributeLabels(filterList, childAttList);
    	Attributes_Labels__c attLabel = new Attributes_Labels__c(Label__c = filterList[0].Id, Attribute__c = childAttList[1].Id);
    	insert attLabel;
    	List<Account_Attribute__c> accAttList = TestDataFactory.createAccountAttributes(accounts, childAttList, true);
    	List<String> attsToAddAccount = new List<String>();
    	attsToAddAccount.add(accAttList[0].Id);
    	String accountAttsMapJSON = ReferenceRefreshControllerSLDS.getAccountAttributesMap(accounts[0].Id, attsToAddAccount, new List<String>());
    	Map<String, String> accAttsMap = (Map<String, String>)JSON.deserialize(accountAttsMapJSON, Map<String, String>.class);
    	system.assert(accAttsMap.size() > 0);
    }
    
    /**
	 * method to test getAccountReferenceabilities method
	 * author: Gaurav Saini (12 Sep, 2017)
	 */
    public static testMethod void testGetAccountReferenceabilities() {
    	List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
    	List<Referenceability__c> accRefList = TestDataFactory.createReferenceability(accounts, new List<Contact>(), refTypeList);
    	insert accRefList;
    	String accRefsListJSON = ReferenceRefreshControllerSLDS.getAccountReferenceabilities(accounts[0].Id, new List<String>());
    	List<ReferenceRefreshControllerSLDS.ReferenceabilityWrapper> accRefList1 = (List<ReferenceRefreshControllerSLDS.ReferenceabilityWrapper>)JSON.deserialize(accRefsListJSON, List<ReferenceRefreshControllerSLDS.ReferenceabilityWrapper>.class);
    	system.assert(accRefList1.size() > 0);
    }
    
    /**
	 * method to test getContactWrapperList method
	 * author: Gaurav Saini (12 Sep, 2017)
	 */
    public static testMethod void testGetContactWrapperList() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
    	List<Contact> contacts = TestDataFactory.createContacts(accounts);
    	insert contacts;
    	List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(contacts);
    	List<String> contactIds = new List<String>();
    	contactIds.add(contacts[0].Id);
    	List<Attribute_Mapping__c> attMapping = new List<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Contact', Field__c = 'LeadSource', Attribute_Name__c = 'Test 1', Filter_Label_Name__c = 'Test 1', Field_Api_Name__c = 'LeadSource', Is_Related_Mapping__c = false, Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c ='Contact', Inheritable__c = true, Filter_Label_Name__c = 'Industry', Field__c = 'Industry', Field_Api_Name__c = 'Industry', Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Attribute_Name__c = 'Industry', Is_Related_Mapping__c = true, Related_Object__c = 'Account', Mapping_Type__c='Parent Object', RelationShip_Name__c = 'AccountId'));
        insert attMapping;
        String attMappingsJSON = ReferenceRefreshControllerSLDS.getAttMappings();
        Map<String, Set<String>> attributesToExcludeContact = new Map<String, Set<String>>();
        attributesToExcludeContact.put(contacts[0].Id, new Set<String>());
        List<Attribute__c> attributeList = TestDataFactory.createAttribute();
    	insert attributeList;
    	List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attributeList, 1, 2);
    	insert childAttList;
    	List<Label__c> filterList = TestDataFactory.createLabels();
    	insert filterList;
    	TestDataFactory.createAttributeLabels(filterList, childAttList);
    	Attributes_Labels__c attLabel = new Attributes_Labels__c(Label__c = filterList[0].Id, Attribute__c = childAttList[1].Id);
    	insert attLabel;
    	List<Contact_Attribute__c> conAttList = TestDataFactory.createContactAttributes(contacts, childAttList);
        Map<String, Set<String>> attributeToAddContact = new Map<String, Set<String>>();
        attributeToAddContact.put(contacts[0].Id, new Set<String>());
        attributeToAddContact.get(contacts[0].Id).add(conAttList[0].Id);
        Map<String, Set<String>> referenceabilityTypesToExcludeContact = new Map<String, Set<String>>();
        referenceabilityTypesToExcludeContact.put(contacts[0].Id, new Set<String>());
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
    	Referenceability_Type__c testRefType1 = new Referenceability_Type__c(Name = 'testRefType1', Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true, min_lead_time_per_request_type__c = 10, max_accounts_per_request_type__c = 15, Reward_points__c = 100, Note__c = 'test notes', Sales_Point__c = 500);
    	insert testRefType1;
    	Referenceability_Type__c testRefType2 = new Referenceability_Type__c(Name = 'testRefType2', Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true, min_lead_time_per_request_type__c = 10, max_accounts_per_request_type__c = 15, Reward_points__c = 100, Note__c = 'test notes', Sales_Point__c = 500);
    	insert testRefType2;
        Map<String, Set<String>> referenceabilityToAddContact = new Map<String, Set<String>>();
        referenceabilityToAddContact.put(contacts[0].Id, new Set<String>());
        referenceabilityToAddContact.get(contacts[0].Id).add(testRefType1.Name);
        referenceabilityToAddContact.get(contacts[0].Id).add(testRefType2.Name);
        List<Referenceability__c> conRefList = TestDataFactory.createReferenceability(new List<Account>(), contacts, refTypeList);
    	insert conRefList;
        String contactWrapperListJSON = ReferenceRefreshControllerSLDS.getContactWrapperList(contactIds, attMappingsJSON, JSON.serialize(attributesToExcludeContact), JSON.serialize(attributeToAddContact), JSON.serialize(referenceabilityTypesToExcludeContact), JSON.serialize(referenceabilityToAddContact));
        List<ReferenceRefreshControllerSLDS.ContactWrapper> contactWrapperList = (List<ReferenceRefreshControllerSLDS.ContactWrapper>)JSON.deserialize(contactWrapperListJSON, List<ReferenceRefreshControllerSLDS.ContactWrapper>.class);
        system.assert(contactWrapperList.size() > 0);
    }
    
    /**
	 * method to test saveUpdates method
	 * author: Gaurav Saini (13 Sep, 2017)
	 */
    public static testMethod void testSaveUpdates() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
    	List<Reference_Refresh__c> refRefreshList = TestDataFactory.createRefRefreshRecords(accounts, accRBIList);
    	List<Contact> contacts = TestDataFactory.createContacts(accounts);
    	Contact testContact = new Contact(AccountId = accounts[0].Id, LastName = 'TestContact');
    	contacts.add(testContact);
    	insert contacts;
    	List<Reference_Basic_Information__c> conRBIList = new List<Reference_Basic_Information__c>();
    	
    	for (Contact con : contacts) {
    		conRBIList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = con.AccountId, Contact__c = con.Id ));
    	}
    	insert conRBIList;
    	List<String> contactIds = new List<String>();
    	contactIds.add(contacts[0].Id);
    	List<Attribute_Mapping__c> attMapping = new List<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Contact', Field__c = 'LeadSource', Attribute_Name__c = 'Test 1', Filter_Label_Name__c = 'Test 1', Field_Api_Name__c = 'LeadSource', Is_Related_Mapping__c = false, Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c ='Contact', Inheritable__c = true, Filter_Label_Name__c = 'Industry', Field__c = 'Industry', Field_Api_Name__c = 'Industry', Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Attribute_Name__c = 'Industry', Is_Related_Mapping__c = true, Related_Object__c = 'Account', Mapping_Type__c='Parent Object', RelationShip_Name__c = 'AccountId'));
        insert attMapping;
        String attMappingsJSON = ReferenceRefreshControllerSLDS.getAttMappings();
        Map<String, Set<String>> attributesToExcludeContact = new Map<String, Set<String>>();
        attributesToExcludeContact.put(contacts[0].Id, new Set<String>());
        List<Attribute__c> attributeList = TestDataFactory.createAttribute();
    	insert attributeList;
    	List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attributeList, 1, 2);
    	insert childAttList;
    	List<Label__c> filterList = TestDataFactory.createLabels();
    	insert filterList;
    	TestDataFactory.createAttributeLabels(filterList, childAttList);
    	Attributes_Labels__c attLabel = new Attributes_Labels__c(Label__c = filterList[0].Id, Attribute__c = childAttList[1].Id);
    	insert attLabel;
    	List<Contact_Attribute__c> conAttList = TestDataFactory.createContactAttributes(contacts, childAttList);
        Map<String, Set<String>> attributeToAddContact = new Map<String, Set<String>>();
        attributeToAddContact.put(contacts[0].Id, new Set<String>());
        attributeToAddContact.get(contacts[0].Id).add(conAttList[0].Id);
        Map<String, Set<String>> referenceabilityTypesToExcludeContact = new Map<String, Set<String>>();
        referenceabilityTypesToExcludeContact.put(contacts[0].Id, new Set<String>());
        Test.startTest();
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
        refTypeList.add(new Referenceability_Type__c(Name = 'Profile Update', Referenceability_code__c = ConstantsController.PROFILE_UPDATE, Sales_Reward__c = true, Sales_Point__c = 100, Visible__c  = true));
    	Referenceability_Type__c testRefType1 = new Referenceability_Type__c(Name = 'testRefType1', Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true, min_lead_time_per_request_type__c = 10, max_accounts_per_request_type__c = 15, Reward_points__c = 100, Note__c = 'test notes', Sales_Point__c = 500);
    	refTypeList.add(testRefType1);
    	Referenceability_Type__c testRefType2 = new Referenceability_Type__c(Name = 'testRefType2', Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true, min_lead_time_per_request_type__c = 10, max_accounts_per_request_type__c = 15, Reward_points__c = 100, Note__c = 'test notes', Sales_Point__c = 500);
        refTypeList.add(testRefType2);
    	insert refTypeList;
        Map<String, Set<String>> referenceabilityToAddContact = new Map<String, Set<String>>();
        referenceabilityToAddContact.put(contacts[0].Id, new Set<String>());
        referenceabilityToAddContact.get(contacts[0].Id).add(testRefType1.Name);
        referenceabilityToAddContact.get(contacts[0].Id).add(testRefType2.Name);
        List<Referenceability__c> refList = TestDataFactory.createReferenceability(accounts, contacts, refTypeList);
    	insert refList;
        String contactWrapperListJSON = ReferenceRefreshControllerSLDS.getContactWrapperList(contactIds, attMappingsJSON, JSON.serialize(attributesToExcludeContact), JSON.serialize(attributeToAddContact), JSON.serialize(referenceabilityTypesToExcludeContact), JSON.serialize(referenceabilityToAddContact));
        List<ReferenceRefreshControllerSLDS.ContactWrapper> contactWrapperList = (List<ReferenceRefreshControllerSLDS.ContactWrapper>)JSON.deserialize(contactWrapperListJSON, List<ReferenceRefreshControllerSLDS.ContactWrapper>.class);
        contactWrapperList[0].contactNotReferenceable = true;
        contactWrapperList[0].contactNotReferenceableReason = 'test Contact inactive reason';
        List<ReferenceRefreshControllerSLDS.AttributeWrapper> accAttWrapperList = new List<ReferenceRefreshControllerSLDS.AttributeWrapper>();
        ReferenceRefreshControllerSLDS.AttributeWrapper accAttWrapper = new ReferenceRefreshControllerSLDS.AttributeWrapper();
        accAttWrapper.labelname = filterList[0].Name;
        accAttWrapper.attributes = childAttList[0].Name;
        accAttWrapper.attMappingId = '';
        accAttWrapper.isRelatedMapping = false;
        accAttWrapper.parentAttributeMappingId = '';
        accAttWrapperList.add(accAttWrapper);
        ReferenceRefreshControllerSLDS.AttributeWrapper accAttWrapper0 = new ReferenceRefreshControllerSLDS.AttributeWrapper();
        accAttWrapper0.labelname = filterList[0].Name;
        accAttWrapper0.attributes = childAttList[1].Name;
        accAttWrapper0.attMappingId = '';
        accAttWrapper0.isRelatedMapping = false;
        accAttWrapper0.parentAttributeMappingId = '';
        accAttWrapperList.add(accAttWrapper0);
        ReferenceRefreshControllerSLDS.AttributeWrapper accAttWrapper1 = new ReferenceRefreshControllerSLDS.AttributeWrapper();
        accAttWrapper1.labelname = attMapping[0].Filter_Label_Name__c;
        accAttWrapper1.attributes = 'Partner';
        accAttWrapper1.attMappingId = attMapping[0].Id;
        accAttWrapper1.isRelatedMapping = false;
        accAttWrapper1.isFromMapping = true;
        accAttWrapper1.parentAttributeMappingId = attMapping[0].Field_Api_Name__c;
        accAttWrapperList.add(accAttWrapper1);
        ReferenceRefreshControllerSLDS.AttributeWrapper accAttWrapper2 = new ReferenceRefreshControllerSLDS.AttributeWrapper();
        accAttWrapper2.labelname = attMapping[1].Filter_Label_Name__c;
        accAttWrapper2.attributes = '';
        accAttWrapper2.attMappingId = attMapping[1].Id;
        accAttWrapper2.isRelatedMapping = true;
        accAttWrapper2.isFromMapping = true;
        accAttWrapper2.parentAttributeMappingId = attMapping[1].Field_Api_Name__c;
        accAttWrapperList.add(accAttWrapper2);
        String accAttWrapperListJSON = JSON.serialize(accAttWrapperList);
        String accountReferenceability = testRefType1.Name + ', ' + testRefType2.Name;
        List<Account_Attribute__c> accAttList = TestDataFactory.createAccountAttributes(accounts, childAttList, true);
        String saveUpdatesResult = ReferenceRefreshControllerSLDS.saveUpdates(refRefreshList[0].Id, false, refRefreshList[0].Reference_Account__c, true, 'Test inactive reason', JSON.serialize(contactWrapperList), accAttWrapperListJSON, accountReferenceability, false);
        system.assertEquals(saveUpdatesResult, 'success');
        Test.stopTest();
    }
    
    /**
	 * method to test saveUpdates method with quarantined checked
	 * author: Gaurav Saini (13 Sep, 2017)
	 */
    public static testMethod void testSaveUpdatesQuarantined() {
    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
    	cs.Enable_Sales_Rewards_Notification__c = true;
    	cs.Reference_Refresh_Update_Chatter__c = true;
    	update cs;
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
    	List<Reference_Refresh__c> refRefreshList = TestDataFactory.createRefRefreshRecords(accounts, accRBIList);
    	List<Contact> contacts = TestDataFactory.createContacts(accounts);
    	Contact testContact = new Contact(AccountId = accounts[0].Id, LastName = 'TestContact');
    	contacts.add(testContact);
    	insert contacts;
    	List<Reference_Basic_Information__c> conRBIList = new List<Reference_Basic_Information__c>();
    	
    	for (Contact con : contacts) {
    		conRBIList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = con.AccountId, Contact__c = con.Id ));
    	}
    	insert conRBIList;
    	List<String> contactIds = new List<String>();
    	contactIds.add(contacts[0].Id);
    	List<Attribute_Mapping__c> attMapping = new List<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Contact', Field__c = 'LeadSource', Attribute_Name__c = 'Test 1', Filter_Label_Name__c = 'Test 1', Field_Api_Name__c = 'LeadSource', Is_Related_Mapping__c = false, Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c ='Contact', Inheritable__c = true, Filter_Label_Name__c = 'Industry', Field__c = 'Industry', Field_Api_Name__c = 'Industry', Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Attribute_Name__c = 'Industry', Is_Related_Mapping__c = true, Related_Object__c = 'Account', Mapping_Type__c='Parent Object', RelationShip_Name__c = 'AccountId'));
        insert attMapping;
        String attMappingsJSON = ReferenceRefreshControllerSLDS.getAttMappings();
        Map<String, Set<String>> attributesToExcludeContact = new Map<String, Set<String>>();
        attributesToExcludeContact.put(contacts[0].Id, new Set<String>());
        List<Attribute__c> attributeList = TestDataFactory.createAttribute();
    	insert attributeList;
    	List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attributeList, 1, 2);
    	insert childAttList;
    	List<Label__c> filterList = TestDataFactory.createLabels();
    	insert filterList;
    	TestDataFactory.createAttributeLabels(filterList, childAttList);
    	Attributes_Labels__c attLabel = new Attributes_Labels__c(Label__c = filterList[0].Id, Attribute__c = childAttList[1].Id);
    	insert attLabel;
    	List<Contact_Attribute__c> conAttList = TestDataFactory.createContactAttributes(contacts, childAttList);
        Map<String, Set<String>> attributeToAddContact = new Map<String, Set<String>>();
        attributeToAddContact.put(contacts[0].Id, new Set<String>());
        attributeToAddContact.get(contacts[0].Id).add(conAttList[0].Id);
        Map<String, Set<String>> referenceabilityTypesToExcludeContact = new Map<String, Set<String>>();
        referenceabilityTypesToExcludeContact.put(contacts[0].Id, new Set<String>());
        Test.startTest();
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
        refTypeList.add(new Referenceability_Type__c(Name = 'Profile Update', Referenceability_code__c = ConstantsController.PROFILE_UPDATE, Sales_Reward__c = true, Sales_Point__c = 100, Visible__c  = true));
    	Referenceability_Type__c testRefType1 = new Referenceability_Type__c(Name = 'testRefType1', Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true, min_lead_time_per_request_type__c = 10, max_accounts_per_request_type__c = 15, Reward_points__c = 100, Note__c = 'test notes', Sales_Point__c = 500);
    	refTypeList.add(testRefType1);
    	Referenceability_Type__c testRefType2 = new Referenceability_Type__c(Name = 'testRefType2', Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true, min_lead_time_per_request_type__c = 10, max_accounts_per_request_type__c = 15, Reward_points__c = 100, Note__c = 'test notes', Sales_Point__c = 500);
        refTypeList.add(testRefType2);
    	insert refTypeList;
        Map<String, Set<String>> referenceabilityToAddContact = new Map<String, Set<String>>();
        referenceabilityToAddContact.put(contacts[0].Id, new Set<String>());
        referenceabilityToAddContact.get(contacts[0].Id).add(testRefType1.Name);
        referenceabilityToAddContact.get(contacts[0].Id).add(testRefType2.Name);
        List<Referenceability__c> refList = TestDataFactory.createReferenceability(accounts, contacts, refTypeList);
    	insert refList;
        String contactWrapperListJSON = ReferenceRefreshControllerSLDS.getContactWrapperList(contactIds, attMappingsJSON, JSON.serialize(attributesToExcludeContact), JSON.serialize(attributeToAddContact), JSON.serialize(referenceabilityTypesToExcludeContact), JSON.serialize(referenceabilityToAddContact));
        List<ReferenceRefreshControllerSLDS.ContactWrapper> contactWrapperList = (List<ReferenceRefreshControllerSLDS.ContactWrapper>)JSON.deserialize(contactWrapperListJSON, List<ReferenceRefreshControllerSLDS.ContactWrapper>.class);
        contactWrapperList[0].contactNotReferenceable = true;
        contactWrapperList[0].contactNotReferenceableReason = 'test Contact inactive reason';
        List<ReferenceRefreshControllerSLDS.AttributeWrapper> accAttWrapperList = new List<ReferenceRefreshControllerSLDS.AttributeWrapper>();
        ReferenceRefreshControllerSLDS.AttributeWrapper accAttWrapper = new ReferenceRefreshControllerSLDS.AttributeWrapper();
        accAttWrapper.labelname = filterList[0].Name;
        accAttWrapper.attributes = childAttList[0].Name;
        accAttWrapper.attMappingId = '';
        accAttWrapper.isRelatedMapping = false;
        accAttWrapper.parentAttributeMappingId = '';
        accAttWrapperList.add(accAttWrapper);
        ReferenceRefreshControllerSLDS.AttributeWrapper accAttWrapper0 = new ReferenceRefreshControllerSLDS.AttributeWrapper();
        accAttWrapper0.labelname = filterList[0].Name;
        accAttWrapper0.attributes = childAttList[1].Name;
        accAttWrapper0.attMappingId = '';
        accAttWrapper0.isRelatedMapping = false;
        accAttWrapper0.parentAttributeMappingId = '';
        accAttWrapperList.add(accAttWrapper0);
        ReferenceRefreshControllerSLDS.AttributeWrapper accAttWrapper1 = new ReferenceRefreshControllerSLDS.AttributeWrapper();
        accAttWrapper1.labelname = attMapping[0].Filter_Label_Name__c;
        accAttWrapper1.attributes = 'Partner';
        accAttWrapper1.attMappingId = attMapping[0].Id;
        accAttWrapper1.isRelatedMapping = false;
        accAttWrapper1.isFromMapping = true;
        accAttWrapper1.parentAttributeMappingId = attMapping[0].Field_Api_Name__c;
        accAttWrapperList.add(accAttWrapper1);
        ReferenceRefreshControllerSLDS.AttributeWrapper accAttWrapper2 = new ReferenceRefreshControllerSLDS.AttributeWrapper();
        accAttWrapper2.labelname = attMapping[1].Filter_Label_Name__c;
        accAttWrapper2.attributes = '';
        accAttWrapper2.attMappingId = attMapping[1].Id;
        accAttWrapper2.isRelatedMapping = true;
        accAttWrapper2.isFromMapping = true;
        accAttWrapper2.parentAttributeMappingId = attMapping[1].Field_Api_Name__c;
        accAttWrapperList.add(accAttWrapper2);
        String accAttWrapperListJSON = JSON.serialize(accAttWrapperList);
        String accountReferenceability = testRefType1.Name + ', ' + testRefType2.Name;
        List<Account_Attribute__c> accAttList = TestDataFactory.createAccountAttributes(accounts, childAttList, true);
        List<Reference_Refresh_Update__c> refRefreshUpdateList = new List<Reference_Refresh_Update__c>();
    	refRefreshUpdateList.add(new Reference_Refresh_Update__c(Reference_Refresh__c = refRefreshList[0].Id, Account__c = accounts[0].Id, Accept_Reject__c = 'Accept', RecordsToBeInsertedId__c = accAttList[0].Id, Added__c = true, Attribute__c = true));
    	refRefreshUpdateList.add(new Reference_Refresh_Update__c(Reference_Refresh__c = refRefreshList[0].Id, Account__c = accounts[0].Id, Accept_Reject__c = 'Accept', RecordsToBeInsertedId__c = refList[0].Id, Added__c = true, Referenceability__c = true));
    	refRefreshUpdateList.add(new Reference_Refresh_Update__c(Reference_Refresh__c = refRefreshList[0].Id, Contact__c = contacts[0].Id, Accept_Reject__c = 'Accept', RecordsToBeInsertedId__c = conAttList[0].Id, Added__c = true, Attribute__c = true));
    	refRefreshUpdateList.add(new Reference_Refresh_Update__c(Reference_Refresh__c = refRefreshList[0].Id, Contact__c = contacts[0].Id, Accept_Reject__c = 'Accept', RecordsToBeInsertedId__c = refList[refList.size() - 1].Id, Added__c = true, Referenceability__c = true));
    	insert refRefreshUpdateList;
        String saveUpdatesResultQuarantined = ReferenceRefreshControllerSLDS.saveUpdates(refRefreshList[0].Id, true, refRefreshList[0].Reference_Account__c, true, 'Test inactive reason', JSON.serialize(contactWrapperList), accAttWrapperListJSON, accountReferenceability, true);
        system.assertEquals(saveUpdatesResultQuarantined, 'success***100***Profile Update');
        Test.stopTest();
    }
    
    @isTest static void testMakeContactInactive() {
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(contacts);

        Test.startTest();
            String result = ReferenceRefreshControllerSLDS.makeContactInactive(conRBIList[0].Contact__c, 'test');
        Test.stopTest();

        System.assert(result != null);
    }
    
    @isTest static void testGetNonReferenceableContacts() {
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(contacts);

        Test.startTest();
            String result = ReferenceRefreshControllerSLDS.getNonReferenceableContacts(accounts[0].id);
        Test.stopTest();
        
        System.assert(result != null);
    }
}