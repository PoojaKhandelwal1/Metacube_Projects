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
public with sharing class TestBatch_ProfileUpdateNoResponse {
    /**
     * Method to test Constructor 1
     */
    static testMethod void testProfileUpdateBatch() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        list<Reference_Basic_Information__c> RBIAccList = TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.createRefRefreshRecords(accounts,RBIAccList);
        Test.startTest();
            Batch_ProfileUpdateNoResponse batchRBIUpdate = new Batch_ProfileUpdateNoResponse();
            ID batchprocessid = database.executebatch(batchRBIUpdate);
            system.assert(true);
        Test.stopTest();
    }
    
    /**
     * Method to test Constructor 2
     */
    static testMethod void testProfileUpdateBatch1() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        list<Reference_Basic_Information__c> RBIAccList = TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.createRefRefreshRecords(accounts,RBIAccList);
        Test.startTest();
            Batch_ProfileUpdateNoResponse batchRBIUpdate = new Batch_ProfileUpdateNoResponse(true);
            ID batchprocessid = database.executebatch(batchRBIUpdate);
            system.assert(true);
        Test.stopTest();
    }
}