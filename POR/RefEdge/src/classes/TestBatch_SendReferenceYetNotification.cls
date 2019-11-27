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
public with sharing class TestBatch_SendReferenceYetNotification {
	
	//Unit Test method for Updation
    static testMethod void testAppendingRFTypesOnUpdate() {
        TestDataFactory.createCustomNotifications();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        Reference_Basic_Information__c rbi = [select Account__c,Referenceability_Status__c,Is_Referenceable__c from Reference_Basic_Information__c where Account__c = : accounts[0].Id];
        rbi.Referenceability_Status__c = '';
        rbi.Is_Referenceable__c = false;
        update rbi;
        List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        List<Reference_Lead__c> refLeadList = TestDataFactory.createLeads();
        refLeadList[0].Reference_Lead_Account__c = accounts[0].Id;
        refLeadList[0].Reference_Lead_Opportunity__c = opps[0].Id;
        refLeadList[1].Reference_Lead_Account__c = accounts[1].Id;
        refLeadList[1].Reference_Lead_Opportunity__c = opps[1].Id;
        refLeadList[1].No_Response_date__c = system.today();
        insert refLeadList;
        Test.startTest();
            Batch_SendReferenceableYetNotification batchRBIUpdate = new Batch_SendReferenceableYetNotification();
          	ID batchprocessid = database.executebatch(batchRBIUpdate);
            system.assert(true);
        Test.stopTest();
    }
}