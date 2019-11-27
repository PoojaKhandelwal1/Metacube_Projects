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
public class TestBatch_ChangeAllNoLongerNeededAR {
    /**
     * Method to call Constructor
     */
    static testmethod void myUnitTest01() {
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
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        for(Reference_Request_Account__c rra : refReqAccs){
            rra.Account_Request_Status__c = 'No Longer Needed';
        }
        insert refReqAccs;
        
        test.startTest();
            Batch_ChangeAllNoLongerNeededAR batchrrf = new Batch_ChangeAllNoLongerNeededAR(false);
            ID batchprocessid = database.executebatch(batchrrf);
        test.stopTest();
        List < Reference_Request_Account__c > testList = [select id from Reference_Request_Account__c];
        system.assertEquals(testList.size() > 0, true);
    }
    
    /**
     * Method to call Constructor
     */
    static testmethod void myUnitTest02() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Consider_No_longer_needed_a_use__c = true;
        update customSetting;
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
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        for(Reference_Request_Account__c rra : refReqAccs){
            rra.Account_Request_Status__c = 'No Longer Needed';
        }
        insert refReqAccs;
        
        test.startTest();
            Batch_ChangeAllNoLongerNeededAR batchrrf = new Batch_ChangeAllNoLongerNeededAR(true);
            ID batchprocessid = database.executebatch(batchrrf);
        test.stopTest();
        List < Reference_Request_Account__c > testList = [select id from Reference_Request_Account__c];
        system.assertEquals(testList.size() > 0, true);
    }
}