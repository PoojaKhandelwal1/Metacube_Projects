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
 * Class: AllCasesARandURControllerSLDS
 * Description : class to test and cover AllCasesARandURControllerSLDS
 * Created by: Rekha Jangir @22 August 2017
 */
@isTest(seeAllData = false)
public with sharing class TestAllCasesARandURControllerSLDS {
	
    /*
     * Method to cover all method and constructor
     * Created By: Rekha Jangir @22 August 2017
     */
    public static testMethod void checkAllCasesARandUR() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
       	List<Case> caseList = TestDataFactory.createCases(new list<Account> {accounts[0]});
        insert caseList;
        List<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        
        for (Reference_Request__c req : refReqs){
        	req.Case__c = caseList[0].Id;
        }
        insert refReqs;
        List<Reference_Request_Account__c> refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        refReqAccs[0].Managed_Request__c = true;
        insert refReqAccs;
        List<Unspecified_Request__c> unSpeReqs = TestDataFactory.createUnspecifiedRequest(refReqs, refTypes);
        insert unSpeReqs;
        
        //Start test method
        Test.startTest();
        	PageReference pageRef = Page.AllCasesARandUR;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(caseList[0]);
        	AllCasesARandURControllerSLDS obj = new AllCasesARandURControllerSLDS(sc);
        	List<AllCasesARandURControllerSLDS.RequestWrapper> requests = AllCasesARandURControllerSLDS.getRequestList(caseList[0].Id);
        	system.assertEquals(4, requests.size());
        	
        	Boolean isSalesUser = AllCasesARandURControllerSLDS.isSalesUser();
        //Stop test method
        Test.stopTest();
    }
}