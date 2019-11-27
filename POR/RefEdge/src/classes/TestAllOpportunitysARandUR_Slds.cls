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
public with sharing class TestAllOpportunitysARandUR_Slds{  
    //Unit Test Method
    static testMethod void testOpportunitysARandUR() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List<Opportunity> opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        List<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        
        for (Reference_Request__c req : refReqs) {
            req.Opportunity__c = opps[0].Id;
        }
        insert refReqs;
        List<Reference_Request_Account__c> refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        refReqAccs[0].Process__c = 'Managed';
        insert refReqAccs;
        List<Unspecified_Request__c> unSpeReqs = TestDataFactory.createUnspecifiedRequest(refReqs, refTypes);
        insert unSpeReqs;
        
        //Start test method
        test.startTest();
            PageReference pageRef = Page.AllOpportunitysARandURSLDS;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(opps[0]); 
            AllOpportunitysARandURController_Slds obj = new AllOpportunitysARandURController_Slds(sc);
            AllOpportunitysARandURController_Slds.isSalesUser(opps[0].Id); 
           	system.assertEquals(4, (AllOpportunitysARandURController_Slds.getRequestList(opps[0].Id)).size());
        //Stop test method
        test.stopTest();
    }   
}