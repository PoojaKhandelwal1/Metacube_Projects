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
public with sharing class TestAddRequestAccountLookupController {
    
    //Unit Test Method
    static testmethod void myUnitTest01() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
       //Start test method
        test.startTest();
            PageReference pageRef = Page.AddRequestAccountLookup;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('strText', '');
            AddRequestAccountLookupController testObj = new AddRequestAccountLookupController();
            testObj.searchText = 'UCO Bank';
            testObj.search();
            system.assertEquals(testObj.accountList.size(),1);
            testObj.searchText = '';
            testObj.search();
        //Stop test method
        test.stopTest();
        
    }
    //Test Method
    static testMethod void testForCandidateReq() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        Reference_Basic_Information__c rbi = new Reference_Basic_Information__c(Account__c = accounts[0].Id, Reference_Program_Candidate__c = true);
        insert rbi;
        
        //start test method
        test.startTest();
            
            PageReference pageRef = Page.AddRequestAccountLookup;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('strText', '');
            pageRef.getParameters().put('type', 'candidate');
            AddRequestAccountLookupController testObj = new AddRequestAccountLookupController();
            testObj.searchText = 'UCO Bank';
            testObj.search();
            system.assertEquals(testObj.accountList.size(),1);
            testObj.searchText = '';
            testObj.search();
            
        //stop test method       
        test.stopTest();
    }
    //Unit Test Method
    static testmethod void myUnitTest02() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
       //Start test method
        test.startTest();
            PageReference pageRef = Page.AddRequestAccountLookup;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('strText', String.valueOf(accounts[0].Id));
            AddRequestAccountLookupController testObj = new AddRequestAccountLookupController();
            testObj.searchText = 'UCO Bank';
            testObj.search();
            system.assertEquals(testObj.accountList.size(),1);
        //Stop test method
        test.stopTest();
        
    }
}