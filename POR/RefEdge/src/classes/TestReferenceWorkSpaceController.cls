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
public with sharing class TestReferenceWorkSpaceController {

    //Data Setup
    private static void createData() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        refReqs = TestDataFactory.createMoreReferenceRequest();
        insert refReqs;
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        refReqAccs[0].Account_Request_Status__c = 'On Hold';
        refReqAccs[1].Account_Request_Status__c = 'On Hold';
        insert refReqAccs;
        List < Unspecified_Request__c > unSpeReqs = TestDataFactory.createUnspecifiedRequest(refReqs, refTypes);
        insert unSpeReqs;
        list<Reference_Request__c> refReqswithOpp = TestDataFactory.createMoreReferenceRequest();
        integer index = 0;
        for(Reference_Request__c rr : refReqswithOpp){
            rr.Opportunity__c = opps[index].Id;
            index++;
            if(index >= opps.size())
                index = 0;
        }
        insert refReqswithOpp;
        refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqswithOpp, refTypes);
        refReqAccs[0].Account_Request_Status__c = 'On Hold';
        refReqAccs[1].Account_Request_Status__c = 'On Hold';
        insert refReqAccs;
        unSpeReqs = TestDataFactory.createUnspecifiedRequest(refReqswithOpp, refTypes);
        insert unSpeReqs;
    }


    //Unit Test Method
    static testMethod void checkRefWorkspace() {
        createData();
        
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            system.assertNotEquals(obj.IsPageAccessible, null);
            obj.getProcess();
            obj.filterGreen();
            obj.filterOnHold();
            obj.filterOrange();

        //Stop test method
        test.stopTest();
    }
    static testMethod void checkRefWorkspace1() {
        createData();
        
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            system.assertNotEquals(obj.IsPageAccessible, null);
            system.assertNotEquals(null, obj.requestWithOppCon.allAccountReq);
            system.assertNotEquals(null, obj.requestWithoutOppCon.allReqWithoutOpp);
            obj.selectedFilter = 'MyRequests';
            obj.requestWithOppCon.selectedFilter = 'MyRequests';
            obj.requestWithoutOppCon.selectedFilter = 'MyRequests';
            obj.getProcess();
            obj.filterGreen();
            obj.filterOnHold();
            obj.filterOrange();

        //Stop test method
        test.stopTest();
    }
    static testMethod void checkRefWorkspace2() {
        createData();
        
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            system.assertNotEquals(obj.IsPageAccessible, null);
            system.assertNotEquals(null, obj.requestWithOppCon.allAccountReq);
            system.assertNotEquals(null, obj.requestWithoutOppCon.allReqWithoutOpp);
            obj.selectedFilter = 'TodayRequests';
            obj.requestWithOppCon.selectedFilter = 'TodayRequests';
            obj.requestWithoutOppCon.selectedFilter = 'TodayRequests';
            obj.getProcess();
            obj.filterGreen();
            obj.filterOnHold();
            obj.filterOrange();

        //Stop test method
        test.stopTest();
    }
    //Unit Test Method
    static testMethod void checkRefWorkspaceRedOpen() {
        createData();
        
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            
            system.assertNotEquals(obj.IsPageAccessible, null);
            system.assertNotEquals(null, obj.requestWithOppCon.allAccountReq);
            system.assertNotEquals(null, obj.requestWithoutOppCon.allReqWithoutOpp);
            obj.filterRed();
            obj.filterAllOpen();
        //Stop test method
        test.stopTest();
    }
    static testMethod void checkRefWorkspaceRedOpen1() {
        createData();
        
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            
            system.assertNotEquals(obj.IsPageAccessible, null);
            system.assertNotEquals(null, obj.requestWithOppCon.allAccountReq);
            system.assertNotEquals(null, obj.requestWithoutOppCon.allReqWithoutOpp);
            obj.selectedFilter = 'MyRequests';
            obj.requestWithOppCon.selectedFilter = 'MyRequests';
            obj.requestWithoutOppCon.selectedFilter = 'MyRequests';
            obj.filterRed();
            obj.filterAllOpen();
        //Stop test method
        test.stopTest();
    }
    static testMethod void checkRefWorkspaceRedOpen2() {
        createData();
        
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            
            system.assertNotEquals(obj.IsPageAccessible, null);
            system.assertNotEquals(null, obj.requestWithOppCon.allAccountReq);
            system.assertNotEquals(null, obj.requestWithoutOppCon.allReqWithoutOpp);
            obj.selectedFilter = 'TodayRequests';
            obj.requestWithOppCon.selectedFilter = 'TodayRequests';
            obj.requestWithoutOppCon.selectedFilter = 'TodayRequests';
            obj.filterRed();
            obj.filterAllOpen();
        //Stop test method
        test.stopTest();
    }
    //Unit Test Method
    static testMethod void checkRefWorkspaceProcessRep() {
        createData();
        
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            
            system.assertNotEquals(obj.IsPageAccessible, null);
            obj.selectedProcess = ConstantsController.REP2REP;
            obj.changeProcess();
        //Stop test method
        test.stopTest();
    }
    
    //Unit Test Method
    static testMethod void checkRefWorkspaceProcessManaged() {
        createData();
        
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            
            system.assertNotEquals(obj.IsPageAccessible, null);
            obj.selectedProcess = ConstantsController.MANAGED;
            obj.changeProcess();
            obj.callShowMoreLink();
            obj.createNewProject();
        //Stop test method
        test.stopTest();
    }
    //Unit Test Method
    static testMethod void checkRefWorkspacewithOPP() {
        createData();
        
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            
            system.assertNotEquals(obj.IsPageAccessible, null);
            obj.requestWithOppCon.next();
            obj.requestWithOppCon.previous();
            obj.requestWithOppCon.pageNumber = 10;
            obj.requestWithOppCon.setPageNumber();
            obj.requestWithOppCon.pageNumber = 0;
            obj.requestWithOppCon.setPageNumber();
        //Stop test method
        test.stopTest();
    }
    
    //Unit Test Method
    static testMethod void checkRefWorkspacewithoutOPP() {
        createData();
        
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            system.assertNotEquals(obj.IsPageAccessible, null);
            obj.requestWithoutOppCon.next();
            obj.requestWithoutOppCon.previous();
            obj.requestWithoutOppCon.pageNumber = 10;
            obj.requestWithoutOppCon.setPageNumber();
            obj.requestWithoutOppCon.pageNumber = 0;
            obj.requestWithoutOppCon.setPageNumber();
        //Stop test method
        test.stopTest();
    }
      
    //Unit Test Method
    static testMethod void checkRefWorkspaceNomination() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List<Nomination__c> nominations = TestDataFactory.createNominations(accounts, contacts);
        insert nominations;
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            system.assertNotEquals(obj.IsPageAccessible, null);
            obj.nominationCon.next();
            obj.nominationCon.previous();
            obj.nominationCon.pageNumber = 10;
            obj.nominationCon.setPageNumber();
            obj.nominationCon.pageNumber = 0;
            obj.nominationCon.setPageNumber();
        //Stop test method
        test.stopTest();
    }
    static testMethod void checkRefWorkspaceNomination1() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List<Nomination__c> nominations = TestDataFactory.createNominations(accounts, contacts);
        insert nominations;
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            system.assertNotEquals(obj.IsPageAccessible, null);
            obj.nominationCon.next();
            obj.nominationCon.previous();
            obj.nominationCon.pageNumber = 10;
            obj.nominationCon.setPageNumber();
            obj.nominationCon.pageNumber = 0;
            obj.nominationCon.setPageNumber();
            obj.selectedMethodNomination = 'nominationAll';
            obj.selectedFilter = 'MyRequests';
            obj.nominationCon.selectedFilter = 'MyRequests';
            obj.setFilter();
            obj.selectedMethodNomination = 'nominationHold';
            obj.nominationCon.selectedFilter = 'MyRequests';
            obj.setFilter();
            
        //Stop test method
        test.stopTest();
        
    }

    static testMethod void checkRefWorkspaceNomination11() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List<Nomination__c> nominations = TestDataFactory.createNominations(accounts, contacts);
        insert nominations;
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            system.assertNotEquals(obj.IsPageAccessible, null);
            obj.nominationCon.next();
            obj.nominationCon.previous();
            obj.nominationCon.pageNumber = 10;
            obj.nominationCon.setPageNumber();
            obj.nominationCon.pageNumber = 0;
            obj.nominationCon.setPageNumber();
            obj.selectedMethodNomination = 'nominationAll';
            obj.selectedFilter = 'MyRequests';
            obj.nominationCon.selectedFilter = 'MyRequests';
            obj.setFilter();
            obj.selectedMethodNomination = 'nominationHold';
            obj.nominationCon.selectedFilter = 'MyRequests';
            obj.setFilter();
            
        //Stop test method
        
    }

    static testMethod void checkRefWorkspaceNomination2() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List<Nomination__c> nominations = TestDataFactory.createNominations(accounts, contacts);
        insert nominations;
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            system.assertNotEquals(obj.IsPageAccessible, null);
            obj.nominationCon.next();
            obj.nominationCon.previous();
            obj.nominationCon.pageNumber = 10;
            obj.nominationCon.setPageNumber();
            obj.nominationCon.pageNumber = 0;
            obj.nominationCon.setPageNumber();
            obj.selectedMethodNomination = 'nominationAll';
            obj.selectedFilter = 'TodayRequests';
            obj.nominationCon.selectedFilter = 'TodayRequests';
            obj.setFilter();
            obj.nominationCon.selectedFilter = 'TodayRequests';
            obj.selectedMethodNomination = 'nominationHold';
            obj.setFilter();
        //Stop test method
        test.stopTest();
        
    }
    static testMethod void checkRefWorkspaceNomination22() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List<Nomination__c> nominations = TestDataFactory.createNominations(accounts, contacts);
        insert nominations;
        PageReference pageRef = Page.ReferenceWorkSpace;
        Test.setCurrentPage(pageRef);
        //Start test method
        test.startTest();
            ReferenceWorkSpaceController obj = new ReferenceWorkSpaceController();
            system.assertNotEquals(obj.IsPageAccessible, null);
            obj.nominationCon.next();
            obj.nominationCon.previous();
            obj.nominationCon.pageNumber = 10;
            obj.nominationCon.setPageNumber();
            obj.nominationCon.pageNumber = 0;
            obj.nominationCon.setPageNumber();
            obj.nominationCon.selectedFilter = 'TodayRequests';
            obj.selectedMethodNomination = 'nominationRed';
            obj.setFilter();
            obj.nominationCon.selectedFilter = 'TodayRequests';
            obj.selectedMethodNomination = 'nominationGreen';
            obj.setFilter();
        //Stop test method
        test.stopTest();
    }
}