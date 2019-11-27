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
 * Class: AllAccReqofRefRequestController
 * Description : class to test and cover AllAccReqofRefRequestController
 * Created by: Rekha Jangir @23 August 2017
 */
@isTest(seeAllData = false)
public with sharing class TestAllAccReqofRefRequestController {
  
    /*
     * Method to cover all method and constructor
     * Created By: Rekha Jangir @23 August 2017
     */
    static testMethod void checkAllAccountRequests() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        List<Reference_Request_Account__c> refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        refReqAccs[0].Managed_Request__c = true;
        insert refReqAccs;
        //Start test method
        test.startTest();
            PageReference pageRef = Page.AllAccReqofRefRequest;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(refReqs[0]);
            AllAccReqofRefRequestController obj = new AllAccReqofRefRequestController(sc);
        //Stop test method
        test.stopTest();
        system.assertEquals(6 , obj.requestList.size());
    }
    
    /*
     * Method to cover all method and constructor
     * Created By: Rekha Jangir @23 August 2017
     */
    static testMethod void checkAllAccountRequestsSLDS() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        List<Reference_Request_Account__c> refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        refReqAccs[0].Managed_Request__c = true;
        insert refReqAccs;
        //Start test method
        test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(refReqs[0]);
            AllAccReqofRefRequestControllerSLDS obj = new AllAccReqofRefRequestControllerSLDS(sc);
            List<AllAccReqofRefRequestControllerSLDS.AccountRequestWrapper> requests = AllAccReqofRefRequestControllerSLDS.getRequestList(refReqs[0].Id);
        	system.assertEquals(6, requests.size());
        //Stop test method
        test.stopTest();
    }
}