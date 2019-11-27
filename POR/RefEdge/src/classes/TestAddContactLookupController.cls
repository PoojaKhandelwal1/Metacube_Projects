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
public with sharing class TestAddContactLookupController {
    //Unit Test Method
    static testmethod void myUnitTest01() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
       //Start test method
        test.startTest();
            PageReference pageRef = Page.AddContactLookup;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('strText', '');
            AddContactLookupController testObj = new AddContactLookupController();
            testObj.searchText = 'Alon';
            testObj.search();
            system.assertEquals(testObj.contactList.size(),1);
        //Stop test method
        test.stopTest();
    }
    
    //Unit Test Method
    static testmethod void myUnitTest02() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
       //Start test method
        test.startTest();
            PageReference pageRef = Page.AddContactLookup;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('strText', String.valueOf(contacts[0].Id));
            AddContactLookupController testObj = new AddContactLookupController();
            testObj.searchText = 'Alon';
            testObj.search();
            system.assertEquals(testObj.contactList.size(),1);
            testObj.searchText = '';
            testObj.search();
            system.assertEquals(testObj.contactList.size(),6);
        //Stop test method
        test.stopTest();
    }
}