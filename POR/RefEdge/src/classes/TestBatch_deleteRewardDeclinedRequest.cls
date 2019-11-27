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
public with sharing class TestBatch_deleteRewardDeclinedRequest {
	
	//Unit Test 01 Include Weekends = false
    static testmethod void myUnitTest01() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = new List < Account > {TestDataFactory.createAccounts()[0]};
        insert accounts;
        list<Reference_Request__c> refReqs = new list<Reference_Request__c> {TestDataFactory.createReferenceRequest()[0]};
        insert refReqs;
        List < Referenceability_Type__c > refTypes = new List < Referenceability_Type__c > {TestDataFactory.createReferenceabilityType()[0]};
        insert refTypes;
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        refReqAccs[0].Approval_Status__c = 'Declined';
        refReqAccs[0].Approve_Deny_Notes__c = 'denied';
        insert refReqAccs;
        Reward__c reward = new Reward__c(Account__c = accounts[0].Id, Referenceability_Type__c = refTypes[0].Id, Amount__c = 50, Transaction__c = ConstantsController.ISSUE, Expiration_Date__c = Date.today() - 1, Available_Points__c = 50,Account_Request__c = refReqAccs[0].Id);
        insert reward;
        test.startTest();
            Batch_deleteRewardDeclinedRequest batchPoints = new Batch_deleteRewardDeclinedRequest();
            ID batchprocessid = database.executebatch(batchPoints);
        test.stopTest();
        List < Reward__c > accList = [select Id from Reward__c where Account_Request__c = :refReqAccs[0].Id];
        system.assertEquals(accList.size(), 0);
    }
}