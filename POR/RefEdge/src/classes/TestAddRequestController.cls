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
public with sharing class TestAddRequestController {
    
    //Test Method
    static testMethod void testAddRequestControllerForUr() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        
        test.startTest();
            Apexpages.currentPage().getParameters().put('id', refReqs[0].Id);
            addRequestController controllerObj = new addRequestController();
            controllerObj.selRefType = refTypes.get(0).Id;
            controllerObj.rrA.Deadline__c = date.today() + 6;
            controllerObj.saveRequest();
            system.assertEquals(false, controllerObj.isMessageRender);
        test.stopTest();
    }
    //Test Method
    static testMethod void testAddRequestControllerForAr() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        //start test method
        test.startTest();
            Apexpages.currentPage().getParameters().put('id', refReqs[0].Id);
            addRequestController controllerObj = new addRequestController();
            controllerObj.selRefType = refTypes.get(0).Id;
            controllerObj.rrA.Account__c = accounts.get(0).Id;
            controllerObj.accName = 'UCO Bank';
            controllerObj.rrA.Deadline__c = date.today() + 6;
            controllerObj.saveRequest();
            system.assertEquals(false, controllerObj.isMessageRender);
        //stop test method       
        test.stopTest();
    }
    //Test Method
    static testMethod void testAddRequestControllerForCandidateReq() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        Reference_Basic_Information__c rbi = new Reference_Basic_Information__c(Account__c = accounts[0].Id, Reference_Program_Candidate__c = true);
        insert rbi;
        
        //start test method
        test.startTest();
            Apexpages.currentPage().getParameters().put('id', refReqs[0].Id);
            Apexpages.currentPage().getParameters().put('candidateproject', 'true');
            addRequestController controllerObj = new addRequestController();
            controllerObj.searchText = 'UCO Bank';
            controllerObj.search();
            controllerObj.searchText = '';
            controllerObj.search();
            controllerObj.accName = '';
            controllerObj.fetchAccounts();
            controllerObj.accName = 'UCO Bank';
            controllerObj.rrA.Account__c = accounts.get(2).Id;
            controllerObj.fetchAccounts();
            controllerObj.selRefType = refTypes.get(0).Id;
            controllerObj.rrA.Account__c = accounts.get(0).Id;
            controllerObj.accName = 'UCO Bank';
            controllerObj.rrA.Deadline__c = date.today() + 6;
            controllerObj.saveRequest();
            system.assertEquals(false, controllerObj.isMessageRender);
        //stop test method       
        test.stopTest();
    }
    //Test Method
    static testMethod void testAddRequestControllerForExceptions() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        //Start Test method
        test.startTest();
            try {
                Apexpages.currentPage().getParameters().put('id', refReqs[0].Id);
                addRequestController controllerObj = new addRequestController();
                controllerObj.rrA.Account__c = accounts.get(0).Id;
                controllerObj.rrA.Deadline__c = date.today() + 6;
                controllerObj.saveRequest();
            } catch (Exception e) {
                system.assertEquals(System.Label.Edit_popup_all_fields_must_filled, e.getMessage());
            }
            try {
                Apexpages.currentPage().getParameters().put('id', refReqs[0].Id);
                addRequestController controllerObj = new addRequestController();
                controllerObj.selRefType = refTypes.get(0).Id;
                controllerObj.rrA.Account__c = accounts.get(0).Id;
                controllerObj.rrA.Deadline__c = date.today() - 6;
                controllerObj.saveRequest();
            } catch (Exception e) {
                system.assertEquals(System.Label.ReferenceUse_invalid_past_Deadline_date, e.getMessage());
            }
            try {
                Apexpages.currentPage().getParameters().put('id', refReqs[0].Id);
                addRequestController controllerObj = new addRequestController();
                controllerObj.selRefType = '00023e2gv2d23drff3e';
                controllerObj.rrA.Account__c = accounts.get(1).Id;
                controllerObj.rrA.Deadline__c = date.today() + 6;
                controllerObj.saveRequest();
                system.assertEquals(false, controllerObj.isMessageRender);
            } catch (Exception e) {
                
            }
            try {
                Apexpages.currentPage().getParameters().put('id', refReqs[0].Id);
                addRequestController controllerObj = new addRequestController();
                controllerObj.selRefType = refTypes.get(0).Id;
                controllerObj.accName = 'test';
                controllerObj.rrA.Deadline__c = date.today() + 6;
                controllerObj.saveRequest();
            } catch (Exception e) {
                system.assertEquals(System.Label.Account_No_matches_found, e.getMessage());
            }
        //Stop Test Method
        test.stopTest();
    }
    //Test Method
    static testMethod void testAddRequestControllerForLookup() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        //start test method
        test.startTest();
            Apexpages.currentPage().getParameters().put('id', refReqs[0].Id);
            addRequestController controllerObj = new addRequestController();
            controllerObj.selRefType = refTypes.get(0).Id;
            controllerObj.fetchAccounts();
            controllerObj.searchText = 'UCO Bank';
            controllerObj.search();
            controllerObj.searchText = '';
            controllerObj.search();
            controllerObj.rrA.Account__c = accounts.get(2).Id;
            controllerObj.setAccount();
            controllerObj.fetchAccounts();
            controllerObj.accName = 'Dover Corporation';
            controllerObj.rrA.Account__c = accounts.get(2).Id;
            controllerObj.fetchAccounts();
            controllerObj.rrA.Deadline__c = date.today() + 6;
            controllerObj.saveRequest();
            system.assertEquals(false, controllerObj.isMessageRender);
        //stop test method       
        test.stopTest();
    }
}