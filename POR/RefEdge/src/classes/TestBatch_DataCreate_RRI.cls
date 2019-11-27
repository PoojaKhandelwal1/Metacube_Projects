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
public with sharing class TestBatch_DataCreate_RRI {
    //Unit Test 01 Escalation To Owner Manager when Include Weekends = false
    static testmethod void myUnitTest01() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        integer index = 0;
        for(Reference_Request__c rr : refReqs){
            rr.Opportunity__c = opps[index].Id;
            index++;
            if(index >= opps.size())
                index = 0;
        }
        insert refReqs;
        List < Invitation__c > invitations = TestDataFactory.createInvitation(opps);
        insert invitations;
        delete [select Id from Reference_Requests_and_Invitations__c where Opportunity__c IN : opps];
        list<Reference_Requests_and_Invitations__c> listNewRRI = new list<Reference_Requests_and_Invitations__c> ();
        listNewRRI.add(new Reference_Requests_and_Invitations__c(Opportunity__c = opps[0].Id,  Reference_Request__c = refReqs[0].Id));
        listNewRRI.add(new Reference_Requests_and_Invitations__c(Opportunity__c = opps[1].Id,  Invitation__c = invitations[0].Id));
        insert listNewRRI;
        test.startTest();
            Batch_DataCreate_RRI batchrrr = new Batch_DataCreate_RRI();
            ID batchprocessid = database.executebatch(batchrrr);
        test.stopTest();
        List <Reference_Requests_and_Invitations__c> rraiList = [select Id from Reference_Requests_and_Invitations__c];
        system.assert(rraiList.size() > 0);
    }
}