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
public class TestContactSearchController {
    
    //Contact Search Results
    public static testMethod void RefsAttrsAndTextSearchContactTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
        insert rfTypes;
        List < Referenceability__c > refers = TestDataFactory.createReferenceability(new list<Account>(), contacts, rfTypes);
        insert refers;
        List < Label__c > labels = TestDataFactory.createLabels();
        insert labels;
        List < Attribute__c > attributes = TestDataFactory.createAttribute();
        insert attributes;
        TestDataFactory.createAttributeLabels(labels, attributes);
        
        List < Account_Attribute__c > accAtts = TestDataFactory.createAccountAttributes(accounts, attributes, false);
        List < Contact_Attribute__c > conAtts = TestDataFactory.createContactAttributes(contacts, attributes);
       
        Contact c = [select AccountId from Contact where Id = : contacts.get(0).Id];
        
        RfSearchController rfsearchCon = new RfSearchController();
        rfsearchCon.attributeWrapper.selectedLabelId = labels[0].Id;
        rfsearchCon.attributeWrapper.selectAllAttributeTypes();
        rfsearchCon.referenceabilityWrapper.selectAllReferenceabilityTypes();
        rfsearchCon.inputTextValue = 'con';
        Id[] fixedSearchResults = new Id[contacts.size()];
        for (Integer i = 0; i < contacts.size(); i++) {
            fixedSearchResults[i] = contacts[i].Id;
        }
        Test.setFixedSearchResults(fixedSearchResults);
        rfsearchCon.search();
        system.assertEquals(rfsearchCon.getContacts().size(),5);
    }
    //Candidate Contact Search Results
    public static testMethod void RefsAttrsAndTextSearchInactiveContactTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List<Reference_Basic_Information__c> RBIAccList = [select Referenceability_Status__c,Is_Referenceable__c,Reference_Program_Candidate__c from Reference_Basic_Information__c where Contact__c IN : contacts];
        for(Reference_Basic_Information__c rbi : RBIAccList){
        	rbi.Referenceability_Status__c = 'Inactive';
        }
        update RBIAccList;
        List < Label__c > labels = TestDataFactory.createLabels();
        insert labels;
        List < Attribute__c > attributes = TestDataFactory.createAttribute();
        insert attributes;
        TestDataFactory.createAttributeLabels(labels, attributes);
        
        List < Account_Attribute__c > accAtts = TestDataFactory.createAccountAttributes(accounts, attributes, false);
        List < Contact_Attribute__c > conAtts = TestDataFactory.createContactAttributes(contacts, attributes);
        
        RfSearchController rfsearchCon = new RfSearchController();
        for(String str : rfsearchCon.filterLogics.keySet()){
        	rfsearchCon.filterLogics.get(str).operatorSelected = 'And';
        }
        rfsearchCon.contactSearch.selectedType = 'Inactive';
        system.assertEquals(rfsearchCon.getContacts().size(), 5);
        rfsearchCon.attributeWrapper.selectedLabelId = labels[0].Id;
        rfsearchCon.attributeWrapper.selectAllAttributeTypes();
        rfsearchCon.referenceabilityWrapper.selectAllReferenceabilityTypes();
        rfsearchCon.inputTextValue = 'con';
        Id[] fixedSearchResults = new Id[contacts.size()];
        for (Integer i = 0; i < contacts.size(); i++) {
            fixedSearchResults[i] = contacts[i].Id;
        }
        Test.setFixedSearchResults(fixedSearchResults);
        rfsearchCon.search();
        system.assertEquals(rfsearchCon.getContacts().size(), 5);
    }
	//Candidate Contact Search Results
    public static testMethod void RefsAttrsAndTextSearchCandidateContactTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List<Reference_Basic_Information__c> RBIAccList = [select Referenceability_Status__c,Is_Referenceable__c,Reference_Program_Candidate__c from Reference_Basic_Information__c where Contact__c IN : contacts];
        for(Reference_Basic_Information__c rbi : RBIAccList){
        	rbi.Referenceability_Status__c = '';
        	rbi.Is_Referenceable__c = false;
        	rbi.Reference_Program_Candidate__c = true;
        }
        update RBIAccList;
        List < Label__c > labels = TestDataFactory.createLabels();
        insert labels;
        List < Attribute__c > attributes = TestDataFactory.createAttribute();
        insert attributes;
        TestDataFactory.createAttributeLabels(labels, attributes);
        
        List < Account_Attribute__c > accAtts = TestDataFactory.createAccountAttributes(accounts, attributes, false);
        List < Contact_Attribute__c > conAtts = TestDataFactory.createContactAttributes(contacts, attributes);
        
        RfSearchController rfsearchCon = new RfSearchController();
        rfsearchCon.contactSearch.selectedType = 'Candidate';
        system.assertEquals(rfsearchCon.getContacts().size(), 5);
        rfsearchCon.attributeWrapper.selectedLabelId = labels[0].Id;
        rfsearchCon.attributeWrapper.selectAllAttributeTypes();
        rfsearchCon.referenceabilityWrapper.selectAllReferenceabilityTypes();
        rfsearchCon.inputTextValue = 'con';
        Id[] fixedSearchResults = new Id[contacts.size()];
        for (Integer i = 0; i < contacts.size(); i++) {
            fixedSearchResults[i] = contacts[i].Id;
        }
        Test.setFixedSearchResults(fixedSearchResults);
        rfsearchCon.search();
        system.assertEquals(rfsearchCon.getContacts().size(), 5);
    }
    //Contact Search Results
    public static testMethod void refReqAccountContactsSearchTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
        insert rfTypes;
        
        Reference_Request__c refReq = new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'In Progress');
        insert refReq;
        List < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, new list<Reference_Request__c>{refReq},rfTypes);
        insert refReqAccs;
        List < Reference_Request_Account_Contact__c > refReqAccConts = TestDataFactory.createContactRequests(contacts,refReqAccs,rfTypes);
        insert refReqAccConts;
        Contacts.addAll(TestDataFactory.createContactsMore(accounts[0]));
        upsert Contacts;
        TestDataFactory.setUpMoreContactRBI(Contacts);
        
        ContactSearchController cscon = new ContactSearchController();
        system.assertEquals(true, Contacts.size() > 0);
        cscon.accountId = accounts[0].Id;
        cscon.pageIndex = 1;
        cscon.listAccountContacts();
        cscon.showMoreContactRecords = true;
        cscon.listAccountContacts();
        cscon.next();
        system.assertEquals(2, cscon.pageIndex);
        cscon.listAccountContacts();
        cscon.next();
        system.assertEquals(3, cscon.pageIndex);
        cscon.listAccountContacts();
        cscon.previous();
        system.assertEquals(2, cscon.pageIndex);
        cscon.listAccountContacts();
        system.assertEquals(true, Contacts.size() > 0);
        cscon.getItems();
        
        List<Reference_Basic_Information__c> RBIAccList = [select Referenceability_Status__c,Is_Referenceable__c,Reference_Program_Candidate__c from Reference_Basic_Information__c];
        for(Reference_Basic_Information__c rbi : RBIAccList){
        	rbi.Referenceability_Status__c = 'Inactive';
        }
        update RBIAccList;
        cscon = new ContactSearchController();
        cscon.selectedType = 'Inactive';
        system.assertEquals(true, Contacts.size() > 0);
        cscon.accountId = accounts[0].Id;
        cscon.pageIndex = 1;
        cscon.listAccountContacts();
        cscon.showMoreContactRecords = true;
        cscon.listAccountContacts();
        cscon.next();
        system.assertEquals(2, cscon.pageIndex);
        cscon.listAccountContacts();
        cscon.next();
        system.assertEquals(3, cscon.pageIndex);
        cscon.listAccountContacts();
        cscon.previous();
        system.assertEquals(2, cscon.pageIndex);
        cscon.listAccountContacts();
        system.assertEquals(true, Contacts.size() > 0);
        
        
        //RBIAccList = [select Referenceability_Status__c,Is_Referenceable__c,Reference_Program_Candidate__c from Reference_Basic_Information__c where Contact__c IN : contacts];
        for(Reference_Basic_Information__c rbi : RBIAccList){
        	rbi.Referenceability_Status__c = '';
        	rbi.Is_Referenceable__c = false;
        	rbi.Reference_Program_Candidate__c = true;
        }
        update RBIAccList;
        
        cscon = new ContactSearchController();
        cscon.selectedType = 'Candidate';
        system.assertEquals(true, Contacts.size() > 0);
        cscon.accountId = accounts[0].Id;
        cscon.pageIndex = 1;
        cscon.listAccountContacts();
        cscon.showMoreContactRecords = true;
        cscon.listAccountContacts();
        cscon.next();
        system.assertEquals(2, cscon.pageIndex);
        cscon.listAccountContacts();
        cscon.next();
        system.assertEquals(3, cscon.pageIndex);
        cscon.listAccountContacts();
        cscon.previous();
        system.assertEquals(2, cscon.pageIndex);
        cscon.listAccountContacts();
        system.assertEquals(true, Contacts.size() > 0);
    }
    
    // showMoreContactRecords is true and no. of Contacts are more than twice of SHOWMORE_PAGE_SIZE
    public static testMethod void contactsGetNextAndPrevTestCandidate() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
       	Contacts.addAll(TestDataFactory.createContactsMore(accounts[0]));
        upsert Contacts;
        TestDataFactory.setUpMoreContactRBI(Contacts);
        List<Reference_Basic_Information__c> RBIAccList = [select Referenceability_Status__c,Is_Referenceable__c,Reference_Program_Candidate__c from Reference_Basic_Information__c where Contact__c IN : contacts];
        for(Reference_Basic_Information__c rbi : RBIAccList){
        	rbi.Referenceability_Status__c = '';
        	rbi.Is_Referenceable__c = false;
        	rbi.Reference_Program_Candidate__c = true;
        }
        update RBIAccList;
        ContactSearchController cscon = new ContactSearchController();
        cscon.selectedType = 'Candidate';
        cscon.pageIndex = 1;
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        cscon.showMoreContactRecords = true;
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        system.assertEquals(25, cscon.SHOWMORE_PAGE_SIZE);
        cscon.next();
        system.assertEquals(2, cscon.pageIndex);
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        cscon.next();
        system.assertEquals(3, cscon.pageIndex);
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        cscon.previous();
        system.assertEquals(2, cscon.pageIndex);
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, true);
        system.assertEquals(true, Contacts.size() > 0);
    }
    
    // showMoreContactRecords is true and no. of Contacts are more than twice of SHOWMORE_PAGE_SIZE
    public static testMethod void contactsGetNextAndPrevTestInactive() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
       	Contacts.addAll(TestDataFactory.createContactsMore(accounts[0]));
        upsert Contacts;
        TestDataFactory.setUpMoreContactRBI(Contacts);
        List<Reference_Basic_Information__c> RBIAccList = [select Referenceability_Status__c,Is_Referenceable__c,Reference_Program_Candidate__c from Reference_Basic_Information__c where Contact__c IN : contacts];
        for(Reference_Basic_Information__c rbi : RBIAccList){
        	rbi.Referenceability_Status__c = 'Inactive';
        }
        update RBIAccList;
        ContactSearchController cscon = new ContactSearchController();
        cscon.selectedType = 'Inactive';
        cscon.pageIndex = 1;
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        cscon.showMoreContactRecords = true;
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        system.assertEquals(25, cscon.SHOWMORE_PAGE_SIZE);
        //system.assertEquals(false, cscon.isContactLimitExceed);
        cscon.next();
        system.assertEquals(2, cscon.pageIndex);
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        cscon.next();
        system.assertEquals(3, cscon.pageIndex);
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        cscon.previous();
        system.assertEquals(2, cscon.pageIndex);
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, true);
        system.assertEquals(true, Contacts.size() > 0);
    }
    
    // showMoreContactRecords is true and no. of Contacts are more than twice of SHOWMORE_PAGE_SIZE
    public static testMethod void contactsGetNextAndPrevTestActive() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
       	Contacts.addAll(TestDataFactory.createContactsMore(accounts[0]));
        upsert Contacts;
        TestDataFactory.setUpMoreContactRBI(Contacts);
        ContactSearchController cscon = new ContactSearchController();
        cscon.pageIndex = 1;
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        cscon.showMoreContactRecords = true;
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        system.assertEquals(25, cscon.SHOWMORE_PAGE_SIZE);
        /*
        cscon.mapContact.get(1)[0].isSelected = true;
        cscon.mapContact.get(1)[1].isSelected = true;
        cscon.mapContact.get(1)[2].isSelected = true;
        cscon.mapContact.get(1)[3].isSelected = true;
        */
        //system.assertEquals(false, cscon.isContactLimitExceed);
        cscon.next();
        system.assertEquals(2, cscon.pageIndex);
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        /*
        cscon.mapContact.get(2)[0].isSelected = true;
        cscon.mapContact.get(2)[1].isSelected = true;
        */
        cscon.next();
        system.assertEquals(3, cscon.pageIndex);
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        cscon.previous();
        system.assertEquals(2, cscon.pageIndex);
        cscon.listContacts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, true);
        /*
        cscon.mapContact.get(2)[0].isSelected = true;
        cscon.mapContact.get(2)[1].isSelected = true;
        */
        system.assertEquals(true, Contacts.size() > 0);
        cscon.previous();
    }
}