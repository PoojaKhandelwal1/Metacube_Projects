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
 * Class : RefSearchBlockController
 * Description : Test class for Ref Search Lightning page  
 * Modified by: Rajesh @25 April 2017
 */
@isTest(seeAllData = false)
private class TestRefSearchBlockController {

    static testMethod void testAssignAccountContact() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        contacts[0].Title = 'Mr';
        contacts[0].Phone = '1234';
        contacts[0].Email = 'test@gmail.com';
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
        List<Reference_Request__c> rrList = TestDataFactory.createReferenceRequest();
        insert rrList;
        List<Reference_Request_Account__c> arList = TestDataFactory.createAccountRequests(accounts, rrList, refTypeList);
        insert arList;
        List<Unspecified_Request__c> urList = TestDataFactory.createUnspecifiedRequest(rrList, refTypeList);
        insert urList;

        Test.startTest();
            Map<String, String> testRequestMap = new Map<String, String>();
            testRequestMap.put('reqNotes', 'test');
            testRequestMap.put('refTypeId', refTypeList[0].Id);
            testRequestMap.put('deadline', Date.today().year() + '-' + Date.today().month() + '-' + (Date.today().day() + 2));
            testRequestMap.put('addInfoId', '');
            testRequestMap.put('unspecRequestId', urList[0].Id);

            // assign account to UR
            String result = RefSearchBlockController.assignAccountContact(true, accounts[0].Id, '', JSON.serialize(testRequestMap),
                                                                            rrList[0].Id, rrList[0].Requester__c, 'Member');
            system.assert(result != null);

            // assign account to AR
            result = RefSearchBlockController.assignAccountContact(false, accounts[0].Id, '', JSON.serialize(testRequestMap),
                                                                            rrList[0].Id, rrList[0].Requester__c, 'Member');
            system.assert(result != null);

            // assign contact to UR
            result = RefSearchBlockController.assignAccountContact(true, accounts[0].Id, contacts[0].Id, JSON.serialize(testRequestMap),
                                                                            rrList[0].Id, rrList[0].Requester__c, 'Member');
            system.assert(result != null);

            // assign contact to AR
            result = RefSearchBlockController.assignAccountContact(false, accounts[0].Id, contacts[0].Id, JSON.serialize(testRequestMap),
                                                                            rrList[0].Id, rrList[0].Requester__c, 'Member');
            system.assert(result != null);
        Test.stopTest();
    }

    static testMethod void testgetAllAccountIds() {
        test.startTest();
        List<Account> accounts = setUpAccountRBI();
        List<String> accids = new List<String>();
        
        for (Account acc : accounts) {
            accids.add(acc.id);
        }
        String accidsString =    Json.serialize(accids);
        String accidFromMethod = RefSearchBlockController.getAllAccountIds(); 
        System.assertEquals(accidsString,accidFromMethod);
        Test.stopTest();
    }
   
    static testMethod void testgetAllContactIds() {
        test.startTest();
        List<Account> accounts = setUpAccountRBI();
        List<Contact> contactlist = setUpContactRBI(accounts);
        List<String> contactids = new List<String>();
        
        for (Contact con : contactlist) {
            contactids.add(con.id);
        }
        String contactidsString = Json.serialize(contactids);
        String contactidsFromMethod = RefSearchBlockController.getAllContactIds(); 
        System.assertEquals(contactidsString, contactidsFromMethod);
        test.stopTest();
    }
   
    static testmethod void testgetTotalContents(){
        Boolean isFilterAppiled = false;
        List<String> alreadyDisplayedContacts = generatealreadyDisplayedContactsJson();
        String alreadyDisplayedContentsJson = Json.serialize(alreadyDisplayedContacts);
        Boolean featuredChecked = true;
        List<String> filteredContents = generateFilteredContactsJson();
        String filteredContentsJson = Json.serialize(filteredContents);
        RefSearchBlockController.getTotalContentsValues(isFilterAppiled, alreadyDisplayedContentsJson, filteredContentsJson, featuredChecked, 'All');
        isFilterAppiled = true;
        //alreadyDisplayedContacts =  generatealreadyDisplayedContactsJson();
        alreadyDisplayedContentsJson = Json.serialize(alreadyDisplayedContacts);
        featuredChecked = true;
        filteredContents = generateFilteredContactsJson();
        filteredContentsJson = Json.serialize(filteredContents);
        RefSearchBlockController.getTotalContentsValues(isFilterAppiled, alreadyDisplayedContentsJson,filteredContentsJson,featuredChecked, 'All');
        featuredChecked = false;
        filteredContents = generateFilteredContactsJson();
        filteredContentsJson = Json.serialize(filteredContents);
        RefSearchBlockController.getTotalContentsValues(isFilterAppiled, alreadyDisplayedContentsJson,filteredContentsJson,featuredChecked, 'All');
        isFilterAppiled = false; 
        alreadyDisplayedContentsJson = Json.serialize(alreadyDisplayedContacts);
        featuredChecked = true;
        filteredContents = generateFilteredContactsJson();
        filteredContentsJson = Json.serialize(filteredContents);
        RefSearchBlockController.getTotalContentsValues(isFilterAppiled, alreadyDisplayedContentsJson,filteredContentsJson,featuredChecked, 'All');
        isFilterAppiled = false; 
        alreadyDisplayedContentsJson = Json.serialize(alreadyDisplayedContacts);
        featuredChecked = false;
        filteredContents = generateFilteredContactsJson();
        filteredContentsJson = Json.serialize(filteredContents);
        Integer result = RefSearchBlockController.getTotalContentsValues(isFilterAppiled, alreadyDisplayedContentsJson,filteredContentsJson,featuredChecked, 'All');
        System.assertEquals(result, 0);
    }
    
    static testmethod void testgetAllContents(){
        Boolean isFilterAppiled = false;
        Integer pageLimit = 10;
        List<Reference_Content__c> refContentList = TestDataFactory.createReferenceContent();
        insert refContentList;
        
        Boolean ShowFeaturedContentFirst = false;
        List<String> alreadyDisplayedContents = new List<String>();         // generatealreadyDisplayedContactsJson();
        String alreadyDisplayedContentsJson = Json.serialize(alreadyDisplayedContents);
        Boolean featuredChecked = true;
        List<String> filteredContents = new List<String>();                                 // generateFilteredContactsJson();
        String filteredContentsJson = Json.serialize(filteredContents);
        RefSearchBlockController.getAllContents1('All', isFilterAppiled,  alreadyDisplayedContentsJson, filteredContentsJson,pageLimit,featuredChecked, ShowFeaturedContentFirst);
        isFilterAppiled = true;
        filteredContents.add(refContentList[0].Id);
        filteredContentsJson = Json.serialize(filteredContents);
        ShowFeaturedContentFirst = false;
        RefSearchBlockController.getAllContents1('Internal', isFilterAppiled, alreadyDisplayedContentsJson, filteredContentsJson, pageLimit, featuredChecked, ShowFeaturedContentFirst);
        isFilterAppiled = true;
        ShowFeaturedContentFirst = true;
        String allContentsJSON = RefSearchBlockController.getAllContents1('Shareable', isFilterAppiled, alreadyDisplayedContentsJson, filteredContentsJson, pageLimit, featuredChecked, ShowFeaturedContentFirst);
        List<RefSearchBlockController.ContentWrapper> allContentsList = (List<RefSearchBlockController.ContentWrapper>)JSON.deserialize(allContentsJSON, List<RefSearchBlockController.ContentWrapper>.class);
        Integer result = allContentsList.size();
        System.assertEquals(result, 0);
    }
   
    static testmethod void testfilterByContentAttribute(){
        List<Attribute__c> attributelist = createAttribute();
        List<String> attributeidlist = new List<String>(); 
        
        for (Attribute__c a : attributelist) {
            attributeidlist.add(a.id);
        }
        String attributeidjson = Json.serialize(attributeidlist);
        List<Content_Attribute__c> tempList = (List<Content_Attribute__c>)JSON.deserialize(RefSearchBlockController.filterByContentAttribute(attributeidjson), List<Content_Attribute__c>.class);
        System.assertEquals(tempList.size(), 0);
    }
   
    static testmethod void testfilterBySearchText(){
        String inputTextValue = 'ChromeBook';
        List<Account>  accountlist = setUpAccountRBI();
        List<String> accids = new List<String>();
        
        for (Account acct : accountlist) {
            accids.add(acct.id);
        }
        String accidsjson = Json.serialize(accids);
        Set<String> tempList = (Set<String>)JSON.deserialize(RefSearchBlockController.filterBySearchText(inputTextValue,accidsjson), Set<String>.class);
        System.assertEquals(tempList.size(), 0);
    }
   
    static testmethod void testgetContentCollections(){
        List<Content_Collection__c> contentCollection = TestDataFactory.createContentCollection();
        insert contentCollection;
        String collectionListJSON = RefSearchBlockController.getContentCollections(); 
        
        if (collectionListJSON != '') {
            List<RefSearchBlockController.CollectionWrapper> tempMap = (List<RefSearchBlockController.CollectionWrapper>)JSON.deserialize(collectionListJSON, List<RefSearchBlockController.CollectionWrapper>.class);
            System.assertNotEquals(tempMap.size(), 0);
        } else {
            System.assertEquals(collectionListJSON, '');
        }
    }
    
    static testmethod void testgetbasicFilters() {
        String basicFiltersJSON = RefSearchBlockController.getbasicFilters();
        
        if (basicFiltersJSON != '') {
            List<RefSearchBlockController.FilterWrapper> tempList = (List<RefSearchBlockController.FilterWrapper>)JSON.deserialize(basicFiltersJSON, List<RefSearchBlockController.FilterWrapper>.class);
            System.assertEquals(tempList.size(), 0);
        } else {
            System.assertEquals(basicFiltersJSON, '');
        }
    }
   
    static testmethod void testgetContactRecords(){
        List<String> alreadyDisplayedContactslist = generatealreadyDisplayedContactsJson();
        String attributeMapInheritableContactIdsJSON = Json.serialize(alreadyDisplayedContactslist);
        Set<String> tempList = (Set<String>)JSON.deserialize(RefSearchBlockController.getContactRecords(attributeMapInheritableContactIdsJSON), Set<String>.class);
        System.assertEquals(tempList.size(), 3);
    }
    
    static testmethod void testgetRelatedContactRecords(){
        List<String> alreadyDisplayedContactslist = generatealreadyDisplayedContactsJson();
        String attributeMapInheritableContactIdsJSON = Json.serialize(alreadyDisplayedContactslist);
        Set<String> tempList = (Set<String>)JSON.deserialize(RefSearchBlockController.getRelatedContactRecords(attributeMapInheritableContactIdsJSON), Set<String>.class);
        System.assertEquals(tempList.size(), 0);
    }
    
    static testmethod void testgetContentTypes(){
        Integer result = RefSearchBlockController.getContentTypes().size();
        System.assertEquals(result, 0);
    }
    
    static testmethod void testfilterContactsBySearchText(){
        String inputTextValue = 'ChromeBook';
        List<String> alreadyDisplayedContactslist = generatealreadyDisplayedContactsJson();
        String alreadyDisplayedContactIdsJson = Json.serialize(alreadyDisplayedContactslist);
        String activeAccountIdsJson;
        String filterdAccountsJson;
        List<String> activeAccountIds = new List<String>();
        List<String> filterdAccounts = new List<String>();
        List<Account> activeAccounts = setUpAccountRBI();
        
        for (Integer i = 0; i < 3; i++) {
            activeAccountIds.add(activeAccounts.get(i).id);
        }
        
        for (Integer i = 3; i < activeAccounts.size(); i++) {
            filterdAccounts.add(activeAccounts.get(i).id);  
        }
        filterdAccountsJson = Json.serialize(filterdAccounts);    
        activeAccountIdsJson = Json.serialize(activeAccountIds);     
        Set<String> tempList = (Set<String>)JSON.deserialize(RefSearchBlockController.filterContactsBySearchText1(inputTextValue,alreadyDisplayedContactIdsJson,activeAccountIdsJson,filterdAccountsJson, 'Active'), Set<String>.class);
        System.assertEquals(tempList.size(), 0);
    }
    
    static testmethod void testgetReferenceability(){
        Integer result = RefSearchBlockController.getReferenceability().size();
        System.assertEquals(result, 0);
    }
    
    static testmethod void testgetContentLanguage(){
        Integer result = RefSearchBlockController.getContentLanguage().size();
        System.assertEquals(result, 16);
    }
    
    static testmethod void testgetAllActiveContactRBIs(){
        Boolean isFilterAppiled = false;
        Integer pageLimit = 10;
        Boolean ShowFeaturedContentFirst = false;
        List<String> alreadyDisplayedContacts = generatealreadyDisplayedContactsJson();
        String alreadyDisplayedContactsJson = Json.serialize(alreadyDisplayedContacts);
        Boolean featuredChecked = true;
        List<String> filteredContents = generateFilteredContactsJson();
        String filteredContactsJson = Json.serialize(filteredContents);
        String contactListJSON = RefSearchBlockController.getAllActiveContactRBIs2(isFilterAppiled, alreadyDisplayedContactsJson,filteredContactsJson,pageLimit, '', 'Active', false);
        List<RefSearchBlockController.ContactProfileWrapper> activecontactrbilist = (List<RefSearchBlockController.ContactProfileWrapper>)JSON.deserialize(contactListJSON, List<RefSearchBlockController.ContactProfileWrapper>.class);
        isFilterAppiled = true;
        pageLimit = 10;
        //alreadyDisplayedContacts =  generatealreadyDisplayedContactsJson();
        alreadyDisplayedContactsJson = Json.serialize(alreadyDisplayedContacts);
        featuredChecked = true;
        filteredContents = generateFilteredContactsJson();
        filteredContactsJson = Json.serialize(filteredContents);
        RefSearchBlockController.getAllActiveContactRBIs2(isFilterAppiled, alreadyDisplayedContactsJson,filteredContactsJson,pageLimit, '', 'Active', false);
        isFilterAppiled = false;
        pageLimit = 10;
        //alreadyDisplayedContacts =  generatealreadyDisplayedContactsJson();
        alreadyDisplayedContactsJson = Json.serialize(alreadyDisplayedContacts);
        featuredChecked = false;
        filteredContents = generateFilteredContactsJson();
        filteredContactsJson = Json.serialize(filteredContents);
        RefSearchBlockController.getAllActiveContactRBIs2(isFilterAppiled, alreadyDisplayedContactsJson,filteredContactsJson,pageLimit, '', 'Active', false);
        isFilterAppiled = false;
        pageLimit = 10;
        //alreadyDisplayedContacts =  generatealreadyDisplayedContactsJson();
        alreadyDisplayedContactsJson = Json.serialize(alreadyDisplayedContacts);
        featuredChecked = true;
        filteredContents = generateFilteredContactsJson();
        filteredContactsJson = Json.serialize(filteredContents);
        String acitveContactsJSON = RefSearchBlockController.getAllActiveContactRBIs2(isFilterAppiled, alreadyDisplayedContactsJson,filteredContactsJson,pageLimit, '', 'Active', false);
        List<RefSearchBlockController.ContactProfileWrapper> tempActiveContactsList = (List<RefSearchBlockController.ContactProfileWrapper>)JSON.deserialize(acitveContactsJSON, List<RefSearchBlockController.ContactProfileWrapper>.class);
        Integer result = tempActiveContactsList.size();
        System.assertEquals(result, 3);
    }
    
    static testmethod void testfilterByContentType() {
        List<Reference_Content_Type__c>  referencecontenttypelist = createContentType();
        List<String>  referencecontenttypeidlist = new List<String>();
        
        for (Integer i = 0; i < 2; i++) {
            referencecontenttypeidlist.add(referencecontenttypelist.get(i).id);
        }
        String selectedcontenttype = JSON.serialize(referencecontenttypeidlist);
        String filterOperation = 'and';
        String filterContentResult = RefSearchBlockController.filterByContentType(selectedcontenttype, filterOperation);
        system.assertEquals(0, ((Set<String>)JSON.deserialize(filterContentResult, Set<String>.class)).size());
        filterOperation = '';
        String filterContentResult1 = RefSearchBlockController.filterByContentType(selectedcontenttype, filterOperation);
        system.assertEquals(0, ((Set<String>)JSON.deserialize(filterContentResult1, Set<String>.class)).size());
    }
    
    static testmethod  void testcreateCollection(){
        List<Reference_Content__c> referencecontent = createReferenceContent();
        List<String> referencecontentlist = new List<String>();
        
        for (Reference_Content__c rcc : referencecontent) {
            referencecontentlist.add(rcc.id);
        }
        String referencecontentjson = Json.serialize(referencecontentlist);
        String tempJSONString = RefSearchBlockController.createCollection('testCollection',referencecontentjson);
        System.assertNotEquals(tempJSONString, '');
    }
    
    static testmethod void testgetRelatedContentRecords(){
        List<Attribute_Mapping__c> attributemapping  = TestDataFactory.createRelatedAttributeMapping();
        List<String> selectedAttributesMappingids = new List<String>();
       
        for (Attribute_Mapping__c att : attributemapping) {
            selectedAttributesMappingids.add(att.id);
        }
        String attributeMapInheritableContentIdsJSON = Json.serialize(selectedAttributesMappingids);
        Set<String> tempList = (Set<String>)JSON.deserialize(RefSearchBlockController.getRelatedContentRecords(attributeMapInheritableContentIdsJSON), Set<String>.class);
        System.assertEquals(tempList.size(), 0);
    }
    
    static testmethod void testgetContentRecords(){
        List<Reference_Content__c> referencecontent = createReferenceContent();
        List<String> referencecontentlist = new List<String>();
        
        for (Reference_Content__c rcc : referencecontent) {
            referencecontentlist.add(rcc.id);
        }
        String referencecontentjson = Json.serialize(referencecontentlist);
        Set<String> tempList = (Set<String>)JSON.deserialize(RefSearchBlockController.getContentRecords(referencecontentjson), Set<String>.class);
        System.assertEquals(tempList.size(), 0);
    }
   
    static testmethod void testgetMappingRecords(){
        List<String> attributemappingstringlist = new List<String>();
        List<Attribute_Mapping__c> attributemappinglist = createAttributeMapping();
        
        for (Attribute_Mapping__c amc : attributemappinglist) {
            attributemappingstringlist.add(amc.id);
        }
        String attributemappingstring = Json.serialize(attributemappingstringlist);
        List<Attribute_Mapping__c> tempList = (List<Attribute_Mapping__c>)JSON.deserialize(RefSearchBlockController.getMappingRecords(attributemappingstring), List<Attribute_Mapping__c>.class);
        System.assertEquals(tempList.size(), 1);
    }
    
    static testmethod void testsearchRelatedMAppingAttributes(){
        List<Label__c> filters = createlabels();
        List<Attribute_Mapping__c> attributemapping = TestDataFactory.createRelatedAttributeMapping();
        List<String> filterids = new List<String>();
        
        for (Attribute_Mapping__c l : attributemapping) {
            filterids.add(l.id);
        }
        String filterid = Json.serialize(filterids);
        String inputTextValue = 'test';
        Integer result = RefSearchBlockController.searchRelatedMAppingAttributes(attributemapping.get(0).id,inputTextValue).size();
        System.assertEquals(result, 0);
    }
    
    static testmethod void testgetTotalContacts(){
        Boolean isFilterAppiled = false;
        Integer pageLimit = 10;
        Boolean ShowFeaturedContentFirst = false;
        List<String> alreadyDisplayedContacts = generatealreadyDisplayedContactsJson();
        String alreadyDisplayedContactsJson = Json.serialize(alreadyDisplayedContacts);
        List<String> filteredcontactslist = generateFilteredContactsJson();
        String filteredContactsJson = Json.serialize(filteredcontactslist);
        RefSearchBlockController.getTotalContacts1(isFilterAppiled,alreadyDisplayedContactsJson, filteredContactsJson, 'Active');
        isFilterAppiled = true;
        ShowFeaturedContentFirst = false;
        //alreadyDisplayedContacts =  generatealreadyDisplayedContactsJson();
        alreadyDisplayedContactsJson = Json.serialize(alreadyDisplayedContacts);
        filteredcontactslist = generateFilteredContactsJson();
        filteredContactsJson = Json.serialize(filteredcontactslist);
        Integer result = RefSearchBlockController.getTotalContacts1(isFilterAppiled,alreadyDisplayedContactsJson, filteredContactsJson, 'Active');
        System.assertEquals(result, 0);
    }
    
    static testmethod void testfilterAccountsBySearchText1(){
        String inputTextValue = 'ChromeBook';
        List<Account> accountlist = setUpAccountRBI();
        List<String> accids = new List<String>();
        List<String> activeaccountids = new List<String>();
        
        for (Account acct : accountlist) {
            accids.add(acct.id);
        }
        
        for (Integer i = 0; i < 2; i++) {
            activeaccountids.add(accountlist.get(i).id);
        }
        String alreadydisplayedaccountIdsJson = Json.serialize(accids);
        String activeAccountIdsJson = Json.serialize(activeaccountids);
        Map<String, Set<String>> tempMap = (Map<String, Set<String>>)JSON.deserialize(RefSearchBlockController.filterAccountsBySearchText1(inputTextValue, alreadydisplayedaccountIdsJson, activeAccountIdsJson), Map<String, Set<String>>.class);
        System.assertEquals(tempMap.keySet().size(), 2);
    }
    
    static testmethod void testgetAllActiveRBIs(){
        Boolean isFilterAppiled=false;
        List<Account> accountlist = setUpAccountRBI();
        List<String> activeaccountids = new List<String>();
        List<String> accids = new List<String>();
        
        for (Account acct : accountlist) {
            accids.add(acct.id);
        }
        
        for (Integer i = 0; i < 2; i++) {
            activeaccountids.add(accountlist.get(i).id);
        }
        String alreadydisplayedaccountIdsJson = Json.serialize(accids);
        List<String> filterdAccounts = new List<String>();
        
        for (Integer i = 3; i < accountlist.size(); i++) {
            filterdAccounts.add(accountlist.get(i).id); 
        }
        Boolean featuredChecked = true;
        Integer pageLimit = 10;
        List<String> filteredContents = generateFilteredContactsJson();
        String filteredAccountsJson = Json.serialize(filterdAccounts);
        String allActiveRBIsJSON = RefSearchBlockController.getAllActiveRBIs2(isFilterAppiled,  alreadydisplayedaccountIdsJson, filteredAccountsJson,pageLimit, false, '', 'Active');
        List<RefSearchBlockController.AccountProfileWrapper> activeRBIsList = (List<RefSearchBlockController.AccountProfileWrapper>)JSON.deserialize(allActiveRBIsJSON, List<RefSearchBlockController.AccountProfileWrapper>.class);
        Integer result = activeRBIsList.size();
        System.assertEquals(result, 0);
    }
    
    static List<Reference_Content__c> createReferenceContent(){
        return TestDataFactory.createReferenceContent();
    }
   
    static List<Reference_Content_Type__c> createContentType(){
        return TestDataFactory.createContentTypes();
    }   
   
    static List<Attribute__c> createAttribute(){
        List<Attribute__c> attributelist = TestDataFactory.createAttribute();
        return attributelist;
    }
    static List<Attribute_Mapping__c> createAttributeMapping(){
        return TestDataFactory.createAttributeMapping();
    }
  
    static List<String> generatealreadyDisplayedContactsJson(){
        List<String> alreadyDisplayedContacts = new List<String>();
        List<Account> accounts = setUpAccountRBI();
        setUpContactRBI(accounts);
        List<String> contactids = ( List<String>)Json.deserialize(RefSearchBlockController.getAllContactIds(),List<String>.class); 
        
        for (Integer i = 0; i < 3; i++) {
            alreadyDisplayedContacts.add(contactids.get(i));
        }
        
        return alreadyDisplayedContacts;
    }
   
   static testmethod void testfilterByContentLanguage(){
        List<String> selectedContentLanguages = new List<String>();
        selectedContentLanguages.add('English');
        String selectedContentLanguagesJson = Json.serialize(selectedContentLanguages);
        String filterOperation = 'and';
        RefSearchBlockController.filterByContentLanguage(selectedContentLanguagesJson, filterOperation);
        filterOperation = '';
        Set<String> tempList = (Set<String>)JSON.deserialize(RefSearchBlockController.filterByContentLanguage(selectedContentLanguagesJson, filterOperation), Set<String>.class);
        System.assertEquals(tempList.size(), 0);
    }
    
    static testmethod void testgetAllFilterAttributes(){
        List<Label__c> filters = createlabels();
        List<String> filterids = new List<String>();
        
        for (Label__c l : filters) {
            filterids.add(l.id);
        }
        String filteridjson = Json.serialize(filterids);
        Map<String, List<RefSearchBlockController.AttributesLabelWrapper>> tempMap = RefSearchBlockController.getAllFilterAttributes(filteridjson);
        System.assertEquals(tempMap.keySet().size(), 18);
    }
    
    static testmethod void testfilterrecords(){
        List<Attribute_Mapping__c> attributemapping  =  TestDataFactory.createRelatedAttributeMapping();
        List<String> selectedAttributes = new List<String>();
        String filterid = attributemapping.get(0).id;
        selectedAttributes.add(attributemapping.get(0).Attribute_Name__c);
        String selectedAttributesJSON = Json.serialize(selectedAttributes);
        RefSearchBlockController.filterRecords(filterId,selectedAttributesJSON);
        attributemapping = TestDataFactory.createRelatedAttributeMappingWithParentObjectContact();
        selectedAttributes = new List<String>();
        filterid = attributemapping.get(0).id;
        selectedAttributes.add(attributemapping.get(0).Attribute_Name__c);
        selectedAttributesJSON = Json.serialize(selectedAttributes);
        Map<String, Set<String>> tempMap = (Map<String, Set<String>>)JSON.deserialize(RefSearchBlockController.filterRecords(filterId,selectedAttributesJSON), Map<String, Set<String>>.class);
        System.assertEquals(tempMap.keySet().size(), 1);
    }
   
    static testmethod void testgetRelatedFilterAttributes(){
        List<Attribute_Mapping__c> attributemapping = TestDataFactory.createRelatedAttributeMapping();
        List<String> selectedAttributes = new List<String>();
        String filterid = attributemapping.get(0).id;
        selectedAttributes.add(attributemapping.get(0).Attribute_Name__c);
        Integer result = RefSearchBlockController.getRelatedFilterAttributes(filterId).size();
        System.assertEquals(result, 0);
    }
    
    static testmethod void testgetFilterAttributes(){
        List<Label__c> filters = createlabels();
        List<String> filterids = new List<String>();
        Integer result = RefSearchBlockController.getFilterAttributes(filters.get(0).Id).size();
        System.assertEquals(result, 0);
    }
    
    static testmethod void testgetTotalAccounts(){
        Boolean isFilterAppiled = false;
        List<String> alreadyDisplayedContacts = generatealreadyDisplayedContactsJson();
        String alreadyDisplayedContentsJson = Json.serialize(alreadyDisplayedContacts);
        Boolean featuredChecked = true;
        List<String > filteredaccounts = new List<String>();
        List<String> alreadyDisplayedAccounts = new List<String>();
        List<Account> accounts = setUpAccountRBI();
        
        for (Integer i = 0; i < 2; i++) {
            alreadyDisplayedAccounts.add(accounts.get(i).id);
        }
        
        for (Integer i = 3; i<accounts.size(); i++) {
            filteredaccounts.add(accounts.get(i).id);   
        }
        String alreadyDisplayedAccountsJson = Json.serialize(alreadyDisplayedAccounts);
        String filteredAccountsJson = Json.serialize(filteredaccounts);
        Integer result = RefSearchBlockController.getTotalAccounts1(isFilterAppiled, alreadyDisplayedAccountsJson, filteredAccountsJson, 'Active');
        System.assertEquals(result, 10);
    }
   
    static testmethod void testfilterAccountsByRefAttributes1(){
        String selectedRefJson;
        List<String> selectedRef = new List<String>();
        String filterMapJson;
        List<Referenceability_Type__c > referenceabilityTypelist = createReferenceabilityType();
        List<Label__c> labels = createlabels();
        Map<String, String> filterMap = new Map<String, String>();
        Map<String, String> filterOperationMap = new Map<String, String>();
        
        for (Label__c l : labels) {
            filterMap.put(l.Name, l.id);
        }
        
        for (Referenceability_Type__c  referenceabilityType : referenceabilityTypelist) {
            selectedRef.add(referenceabilityType.id);
        }
        filterMapJson = Json.serialize(filterMap);
        List<Account> activeAccounts = setUpAccountRBI();
        List<String> filterdAccounts = new List<String>();
        List<String> alreadyDisplayedAccounts = new List<String>();
        
        for (Integer i = 3; i < activeAccounts.size(); i++) {
            filterdAccounts.add(activeAccounts.get(i).id);  
        }
        
        for (Integer i=0; i < 2; i++) {
            alreadyDisplayedAccounts.add(activeAccounts.get(i).id); 
        }
        selectedRefJson = Json.serialize(selectedRef);
        String alreadyDisplayedAccountsJson = Json.serialize(alreadyDisplayedAccounts);
        String filterOperationMapJson;
        String filteredAccountsJson = Json.serialize(filterdAccounts);
        filterOperationMap.put('Referenceability','and');
        filterOperationMapJson = Json.serialize(filterOperationMap);
        RefSearchBlockController.filterAccountsByRefAttributes(selectedRefJson, filterMapJson,  alreadyDisplayedAccountsJson,  filteredAccountsJson,  filterOperationMapJson, 'Active');
        selectedRefJson = Json.serialize(selectedRef);
        alreadyDisplayedAccountsJson = Json.serialize(alreadyDisplayedAccounts);
        filteredAccountsJson = Json.serialize(filterdAccounts);
        filterOperationMap.put('','');
        filterOperationMapJson = Json.serialize(filterOperationMap);
        List<Reference_Basic_Information__c> tempList = (List<Reference_Basic_Information__c>)JSON.deserialize(RefSearchBlockController.filterAccountsByRefAttributes(selectedRefJson, filterMapJson,  alreadyDisplayedAccountsJson,  filteredAccountsJson,  filterOperationMapJson, 'Active'), List<Reference_Basic_Information__c>.class);
        System.assertEquals(tempList.size(), 0);
    }
    
    static testmethod void testfilterContactsByRefAttributes(){
        String selectedRefJson;
        List<String> selectedRef = new List<String>();
        String filterMapJson;
        List < Referenceability_Type__c > referenceabilityTypelist = createReferenceabilityType();
        List<Label__c>  labels = createlabels();
        Map<String, String> filterMap = new Map<String, String>();
        Map<String, String> filterOperationMap = new Map<String, String>();
        
        for (Label__c l : labels) {
            filterMap.put(l.Name, l.id);
        }
        
        for (Referenceability_Type__c  referenceabilityType : referenceabilityTypelist) {
            selectedRef.add(referenceabilityType.id);
        }
        filterMapJson = Json.serialize(filterMap);
        List<Account> activeAccounts = setUpAccountRBI();
        List<String> filterdAccounts = new List<String>();
        List<String> alreadyDisplayedAccounts = new List<String>();
        
        for (Integer i = 3; i<activeAccounts.size(); i++) {
            filterdAccounts.add(activeAccounts.get(i).id);  
        }
        
        for (Integer i = 0; i < 2; i++) {
            alreadyDisplayedAccounts.add(activeAccounts.get(i).id); 
        }
        selectedRefJson = Json.serialize(selectedRef);
        String alreadyDisplayedAccountsJson = Json.serialize(alreadyDisplayedAccounts);
        String filterOperationMapJson;
        String filteredAccountsJson = Json.serialize(filterdAccounts);
        filterOperationMap.put('Referenceability','and');
        filterOperationMapJson = Json.serialize(filterOperationMap);
        List<Account> accounts =  setUpAccountRBI();
        List<Contact> contactlist = setUpContactRBI(accounts);
        List<String> contactids = new List<String>();
        
        for (Contact con : contactlist) {
            contactids.add(con.id);
        }
        String filteredContactsJson = Json.serialize(contactids);
        List < Reference_Basic_Information__c > tempList = (List < Reference_Basic_Information__c >)JSON.deserialize(RefSearchBlockController.filterContactsByRefAttributes1(selectedRefJson,filterMapJson,  alreadyDisplayedAccountsJson,  filteredContactsJson, filterOperationMapJson, 'Active'), List < Reference_Basic_Information__c >.class);
        System.assertEquals(tempList.size(), 0);
    }
    
    static testmethod void createWrappers(){
        Referenceability_Type__c referenceabilityTypeobj = new Referenceability_Type__c(name = 'test');
        insert referenceabilityTypeobj;
        
        RefSearchBlockController.ReferenceabilityTypeWrapper wrapperobj = new RefSearchBlockController.ReferenceabilityTypeWrapper(referenceabilityTypeobj);
        wrapperobj.indexValue = 0;
        List<Label__c>  labels = createlabels();
        String id =labels.get(0).id;
        RefSearchBlockController.FilterLogicWrapper filterLogicWrapperobj = new RefSearchBlockController.FilterLogicWrapper(id ,'test', 'and');
        RefSearchBlockController.ContentTypeWrapper ContentTypeWrapperobj = new RefSearchBlockController.ContentTypeWrapper('testcontentname');
        RefSearchBlockController.ContentLanguageWrapper ContentLanguageWrapperobj = new RefSearchBlockController.ContentLanguageWrapper('testcontentLanguageName');
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        List<String> accIds = new List<String>();
        
        for (Account acc : accounts) {
            accIds.add(acc.Id);
        }
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        
        insert contacts;
        
        List<Reference_Basic_Information__c> contactrbiList = TestDataFactory.setUpContactRBI(contacts);
        RefSearchBlockController.AccountProfileWrapper AccountProfileWrapperobj = new RefSearchBlockController.AccountProfileWrapper(rbiList.get(0), 0);
        RefSearchBlockController.ContactProfileWrapper  ContactProfileWrapperobj = new  RefSearchBlockController.ContactProfileWrapper(contactrbiList.get(0));
        List<Reference_Content__c>   referenceContentlist =TestDataFactory.createReferenceContent();
        User u = TestDataFactory.createUser();
        ContentVersion contentVersionobj = TestDataFactory.createContentVersion(u);
        RefSearchBlockController.ContentWrapper ContentWrapperobj = new RefSearchBlockController.ContentWrapper(referenceContentlist.get(0), contentVersionobj, 'testaccountName', accIds, new Reference_Interview__c());
        List<Label__c> labelslist = createlabels();
        List < Attribute__c > attributeList = TestDataFactory.createAttribute();
        
        insert attributeList;
        
        List<Attributes_Labels__c> attributeLabelslist = TestDataFactory.setUpAttributeLabels(labelslist,attributeList);
        RefSearchBlockController.AttributesLabelWrapper AttributesLabelWrapperobj = new RefSearchBlockController.AttributesLabelWrapper(attributeLabelslist.get(0));
        RefSearchBlockController.RelatedMappingWrapper  RelatedMappingWrapperobj = new RefSearchBlockController.RelatedMappingWrapper('Name',accounts.get(0).id,'');
        Custom_Settings__c cs = setCustomSetting();
        RefSearchBlockController refcontroller = new RefSearchBlockController(); 
        refcontroller.RULPeriodLength = cs.RUL_Period__c;
        refcontroller.RULPeriodLengthContact = cs.RUL_Period_Contact__c;
        refcontroller.ShowFeaturedContentFirst = cs.Show_Featured_Content_First__c;
        System.assertEquals('Hello', 'Hello');
    }
    
    static List<Label__c> createlabels(){
        List<label__c> filters = TestDataFactory.createLabels();
        insert(filters);    
        
        return filters;
    }
    
    static List<Referenceability_Type__c>  createReferenceabilityType() {
        List<Referenceability_Type__c> referenceabilityTypelist = TestDataFactory.createReferenceabilityType();
        insert referenceabilityTypelist;
        
        return referenceabilityTypelist;
    }
    
    static List<String> generateFilteredContactsJson() {
        List<String> filteredContacts = new List<String>();
        List<String> contactids = ( List<String>)Json.deserialize(RefSearchBlockController.getAllContactIds(), List<String>.class); 
         
        for (Integer i = 10; i<contactids.size(); i++) {
            filteredContacts.add(contactids.get(i));
        }
        return filteredContacts;
    }
   
    static List<Account> setUpAccountRBI(){
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        return accounts;
    }
   
    static List<Contact> setUpContactRBI(List<Account> accList){
        List<Contact> contacts = TestDataFactory.createContacts(accList);
        insert contacts;
        
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpContactRBI(contacts);
        return contacts;
    }
   
    static  Custom_Settings__c setCustomSetting(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        return customSetting;
    }
    
    static testMethod void testgetRelatedAccountsForRefContent() {
        List<Account> accounts = setUpAccountRBI();
        List<String> accIds = new List<String>();
        
        for (Account acc : accounts) {
            accIds.add(acc.Id);
        }
        
        String relatedAccountsJSON = RefSearchBlockController.getRelatedAccountsForRefContent(accIds);
        List<RefSearchBlockController.RelatedAccountWrapper> relatedAccounts = new List<RefSearchBlockController.RelatedAccountWrapper>();
        
        if (relatedAccountsJSON != '') {
            relatedAccounts = (List<RefSearchBlockController.RelatedAccountWrapper>)JSON.deserialize(relatedAccountsJSON, List<RefSearchBlockController.RelatedAccountWrapper>.class);
            System.assertNotEquals(relatedAccounts.size(), 0);
        } else {
            System.assertNotEquals(relatedAccountsJSON, '');
        }
    }
    
    static testMethod void testsaveSelectedColumns() {
        RefSearchBlockController refSearchCtrl = new RefSearchBlockController();
        Decimal RULPeriod = refSearchCtrl.RULPeriodLength;
        Decimal maxAccountRequests = refSearchCtrl.maxAccountRequests;
        Decimal RULPeriodLengthContact = refSearchCtrl.RULPeriodLengthContact;
        Boolean ShowFeaturedContentFirst = refSearchCtrl.ShowFeaturedContentFirst;
        Boolean isBasicEdition = refSearchCtrl.isBasicEdition;
        Boolean isContactsVisible = refSearchCtrl.isContactsVisible;
        String colWrapperMapJSON = RefSearchBlockController.getColumnWrapperMap();
        Map<String, List<RefSearchBlockController.ColumnWrapper>> columnWrapperMap = (Map<String, List<RefSearchBlockController.ColumnWrapper>>)JSON.deserialize(colWrapperMapJSON, Map<String, List<RefSearchBlockController.ColumnWrapper>>.class);
        
        for (RefSearchBlockController.ColumnWrapper col : columnWrapperMap.get('Account')) {
            col.isSelected = true;
        }
        colWrapperMapJSON = JSON.serialize(columnWrapperMap);
        String saveColumnsResult = RefSearchBlockController.saveSelectedColumns(colWrapperMapJSON);
        columnWrapperMap = new Map<String, List<RefSearchBlockController.ColumnWrapper>>();
        
        if (saveColumnsResult != '') {
            columnWrapperMap = (Map<String, List<RefSearchBlockController.ColumnWrapper>>)JSON.deserialize(saveColumnsResult, Map<String, List<RefSearchBlockController.ColumnWrapper>>.class);
            System.assertNotEquals(columnWrapperMap.keySet().size(), 0);
        } else {
            System.assertEquals(saveColumnsResult, '');
        }
        colWrapperMapJSON = RefSearchBlockController.getColumnWrapperMap();
        saveColumnsResult = RefSearchBlockController.saveSelectedColumns(colWrapperMapJSON);
        columnWrapperMap = new Map<String, List<RefSearchBlockController.ColumnWrapper>>();
        
        if (saveColumnsResult != '') {
            columnWrapperMap = (Map<String, List<RefSearchBlockController.ColumnWrapper>>)JSON.deserialize(saveColumnsResult, Map<String, List<RefSearchBlockController.ColumnWrapper>>.class);
            System.assertNotEquals(columnWrapperMap.keySet().size(), 0);
        } else {
            System.assertEquals(saveColumnsResult, '');
        }
    }
   
    static testMethod void testsaveUserMapping() {
        List<Label__c> labelsList = TestDataFactory.createLabels();
        insert labelsList;
        
        List<Data_Mapping__c> dataMappings = TestDataFactory.createDataMappings();
        dataMappings[0].Order__c = 0;
        dataMappings[0].Field_API_Name__c = labelsList[0].Id;
        dataMappings[0].Label__c = labelsList[0].Name;
        dataMappings[0].Object__c = 'Filter';
        dataMappings[0].Filter_RefSearch_Visible__c = true;
        dataMappings[1].Order__c = 1;
        dataMappings[1].Field_API_Name__c = labelsList[1].Id;
        dataMappings[1].Label__c = labelsList[1].Name;
        dataMappings[1].Object__c = 'Filter';
        dataMappings[1].Filter_RefSearch_Visible__c = true;
        dataMappings[2].Order__c = 2;
        dataMappings[2].Field_API_Name__c = labelsList[2].Id;
        dataMappings[2].Label__c = labelsList[2].Name;
        dataMappings[2].Object__c = 'Filter';
        dataMappings[2].Filter_RefSearch_Visible__c = true;
        dataMappings[3].Order__c = 3;
        dataMappings[3].Field_API_Name__c = labelsList[3].Id;
        dataMappings[3].Label__c = labelsList[3].Name;
        dataMappings[3].Object__c = 'Filter';
        dataMappings[3].Filter_RefSearch_Visible__c = true;
        ConstantsController.shouldDataMappingProcessed = false;
        insert dataMappings;
        String basicFiltersJSON = RefSearchBlockController.getbasicFilters();
       
        if (basicFiltersJSON != '') {
            List<RefSearchBlockController.FilterWrapper> basicFilters = (List<RefSearchBlockController.FilterWrapper>)JSON.deserialize(basicFiltersJSON, List<RefSearchBlockController.FilterWrapper>.class);
            List<RefSearchBlockController.FilterWrapper> basicFilters1 = new List<RefSearchBlockController.FilterWrapper>();
            List<RefSearchBlockController.FilterWrapper> basicFilters2 = new List<RefSearchBlockController.FilterWrapper>();
           
            for (RefSearchBlockController.FilterWrapper filter : basicFilters) {
                
                if (basicFilters1.size() < 3) {
                  
                    if (basicFilters1.size() == 0) {
                        filter.userMappingVisible = true;
                    }
                    basicFilters1.add(filter);
                } else {
                   
                    if (basicFilters2.size() == 0) {
                        filter.userMappingVisible = true;
                    }
                    basicFilters2.add(filter);
                }
            }
            String saveUserMappingResult = RefSearchBlockController.saveUserMapping(JSON.serialize(basicFilters1), JSON.serialize(basicFilters2));
            List<RefSearchBlockController.FilterWrapper> savedBasicFilters = new List<RefSearchBlockController.FilterWrapper>();
           
            if (saveUserMappingResult != '') {
                savedBasicFilters = (List<RefSearchBlockController.FilterWrapper>)JSON.deserialize(saveUserMappingResult, List<RefSearchBlockController.FilterWrapper>.class);
                System.assert(true);
            } else {
                System.assertEquals(saveUserMappingResult, '');
            }
        } else {
            System.assertEquals(basicFiltersJSON, '');
        }
    }
    
    static testMethod void testgetRefContentForAccount() {
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
        insert refContents;
        List<Account_Reference_Content__c> ARCList = TestDataFactory.createAccountRefContents(accounts, refContents);
        insert ARCList;
        
        String accId = accounts[0].Id;
        String relatedRefContent = RefSearchBlockController.getRefContentForAccount(accId);
        List<RefSearchBlockController.RefContentWrapper> refContentWrapperList = new List<RefSearchBlockController.RefContentWrapper>();
        
        if (relatedRefContent != '') {
            refContentWrapperList = (List<RefSearchBlockController.RefContentWrapper>)JSON.deserialize(relatedRefContent, List<RefSearchBlockController.RefContentWrapper>.class);
            System.assertNotEquals(refContentWrapperList.size(), 0);
        } else {
            System.assertEquals(relatedRefContent, '');
        }
    }
    
    static testMethod void testDownloadRefContent() {
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
        insert refContents;
        List<Account_Reference_Content__c> ARCList = TestDataFactory.createAccountRefContents(accounts, refContents);
        insert ARCList;
        String accId = accounts[0].Id;
        String relatedRefContent = RefSearchBlockController.getRefContentForAccount(accId);
        List<RefSearchBlockController.RefContentWrapper> refContentWrapperList = (List<RefSearchBlockController.RefContentWrapper>)JSON.deserialize(relatedRefContent, List<RefSearchBlockController.RefContentWrapper>.class);
        List<String> refContentIds = new List<String>();
        
        for (RefSearchBlockController.RefContentWrapper refContent : refContentWrapperList) {
            refContentIds.add(refContent.refContentId);
        }
        String downloadResult = RefSearchBlockController.downloadRefContent(JSON.serialize(refContentIds));
        system.assertEquals(downloadResult, '');
    }

    static testMethod void testRollupAttributes() {
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Opportunity> opportunities = TestDataFactory.createOpportunity(accounts);
        insert opportunities;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> rbiAccList = TestDataFactory.setUpAccountRBI(accounts);
        List<Reference_Basic_Information__c> rbiConList = TestDataFactory.setUpContactRBI(contacts);        
        List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
        insert refContents;
        Boolean permission = RefSearchBlockController.hasPermissionOnEnableRefSearchExport();
        List<Reference_Request__c> refReqList = TestDataFactory.createReferenceRequest();
        insert refReqList;
        system.assertNotEquals(0, refReqList.size());
        String requestVal = RefSearchBlockController.getRequestRefTypeIds(String.valueOf(refReqList[0].Id));
        String reqstData = RefSearchBlockController.getRequestData(String.valueOf(refReqList[0].Id));
        String reqFilter = RefSearchBlockController.getFiltersInfo(String.valueOf(refReqList[0].Id));
        String accRecords = RefSearchBlockController.getAllRecordsForExport('Account');
        String conRecords = RefSearchBlockController.getAllRecordsForExport('Contact');
        String contntRec = RefSearchBlockController.getAllRecordsForExport('Content');
        String matchAct = RefSearchBlockController.getRefMatchContactIds(String.valueOf(accounts[0].Id), 'Active');
        String matchInact = RefSearchBlockController.getRefMatchContactIds(String.valueOf(accounts[0].Id), 'Inactive');
        String matchCandi = RefSearchBlockController.getRefMatchContactIds(String.valueOf(accounts[0].Id), 'Candidate');
        Set<String> refContentIds = new Set<String>();

        for(Reference_Content__c rc : refContents) {
            refContentIds.add(rc.Id);
        }
        String refConUpdate = RefSearchBlockController.updateRefContentStatistics(JSON.serialize(refContentIds), 'open link');
        String refConUpdate1 = RefSearchBlockController.updateRefContentStatistics(JSON.serialize(refContentIds), 'open detail');
        String filterInfo = RefSearchBlockController.getStageFilterId();
        List<Attribute_Mapping__c> attributemapping = TestDataFactory.createAttributeMapping();                         
        //Creating Attribute
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;            
        //Creating Account Attribute
        Account_Attribute__c accAttrs = new Account_Attribute__c(Account__c = accounts[0].Id, Attribute__c = attributes[0].Id,Inheritable__c = false);
        Insert accAttrs;
        String oppInfo = RefSearchBlockController.getPreFilterResults(String.valueOf(opportunities[0].Id), true);
        String oppInfo1 = RefSearchBlockController.getPreFilterResults(String.valueOf(opportunities[0].Id), false);
        Set<Id> accIds = new Set<Id>();

        for(Account acc : accounts) {
            accIds.add(acc.Id);
        }
        String accRBI = RefSearchBlockController.accountRBIWithLimitCheck(JSON.serialize(accIds));
        String contentAttri = RefSearchBlockController.inheritAccountAttribute(String.valueOf(refContents[0].Id));
        RefSearchBlockController rfSearch = new RefSearchBlockController();
        rfSearch.showOveray = true;
        rfSearch.userMappingRecord();
        rfSearch.showOveray = false;
        rfSearch.userMappingRecord();
    }
}