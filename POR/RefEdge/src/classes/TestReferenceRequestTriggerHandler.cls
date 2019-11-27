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
public with sharing class TestReferenceRequestTriggerHandler {

    public static Reference_Request__c refReq;

    //Test method for Insert Event
    public static testMethod void testInsertEvent() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Expire_Rewards__c = true;
            List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
            insert refTypes;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
            insert opps;
            refReq = new Reference_Request__c(Reference_Request_Status__c = 'In Progress',Opportunity__c = opps[0].Id);
            insert refReq;
            list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, new list<Reference_Request__c>{refReq}, refTypes);
            refReqAccs[0].Managed_Request__c = true;
            refReqAccs[1].Reference_Use__c = true;
            insert refReqAccs;
            
            refReqAccs[0].Process__c = ConstantsController.REP2REP;
            refReqAccs[0].Influitive_Challenge_Data__c = '123::333';
            update refReqAccs[0];
            
            refReqAccs[0].Managed_Request__c = false;
            update refReqAccs[0];
            
            refReqAccs[0].Managed_Request__c = true;
            update refReqAccs[0];
            
            refReqAccs[0].Activity_Date__c = Date.today()+1;
            update refReqAccs[0];
            
            refReqAccs[0].Account_Request_Status__c = null;
            update refReqAccs[0];
            
            ConstantsController.UPDATED_SUBJECT_FOR_REF_REQUEST ='Maneged';
            refReqAccs[0].Process__c = ConstantsController.MANAGED;
            update refReqAccs[0];
            
            customSetting.Consider_No_longer_needed_a_use__c = true;
            update customSetting;
            refReqAccs[0].Account_Request_Status__c = ConstantsController.NO_LONGER_NEEDED;
            update refReqAccs[0];
            customSetting.Consider_No_longer_needed_a_use__c = false;
            update customSetting;
            
            List < Unspecified_Request__c > unSpeReqs = TestDataFactory.createUnspecifiedRequest(new list<Reference_Request__c>{refReq}, refTypes);
            insert unSpeReqs;
            
            unSpeReqs[0].Unspecified_Request_Status__c = ConstantsController.NO_REFERENCE_MATCH;
            update unSpeReqs;
            
            unSpeReqs[0].Project_Owner__c = UserInfo.getUserId();
            update unSpeReqs;
            
            list<Reference_Request__c> refReqList = [select Id, Name from Reference_Request__c LIMIT: limits.getLimitQueryRows()];
            system.assertEquals(1, refReqList.size());
            refReq.Opportunity__c = opps[1].Id;
            update refReq;
            ConstantsController.shouldArAndUrUpdate = true;
            refReq.Reference_Request_Status__c = 'Give Up - Service Issues';
            update refReq;
        }catch(Exception e){
            
        }
    }
    
    //Test method for Update Event
    public static testMethod void testUpdateEvent() {
        try{
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        ConstantsController.isfromInfluitiveBatch = true;
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        refReq = new Reference_Request__c(Requester__c = UserInfo.getUserId());
        insert refReq;
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, new list<Reference_Request__c>{refReq}, refTypes);
        refReqAccs[0].Managed_Request__c = true;
        refReqAccs[0].Account_Request_Status__c = ConstantsController.NOT_STARTED;
        refReqAccs[1].Account_Request_Status__c = ConstantsController.ONHOLD;
        insert refReqAccs;
        List < Unspecified_Request__c > unSpeReqs = TestDataFactory.createUnspecifiedRequest(new list<Reference_Request__c>{refReq}, refTypes);
        unSpeReqs[0].Unspecified_Request_Status__c = ConstantsController.NOT_STARTED;
        insert unSpeReqs;
        
        list<Reference_Request__c> refReqList = [select Id, Name from Reference_Request__c LIMIT: limits.getLimitQueryRows()];
        system.assertEquals(1, refReqList.size());
        
        ConstantsController.shouldArAndUrUpdate = true;
        refReq.Reference_Request_Status__c = 'In Progress';
        update refReq;
        
        ConstantsController.shouldArAndUrUpdate = true;
        refReq.Reference_Request_Status__c = 'On Hold';
        update refReq;
        test.startTest();
            ConstantsController.shouldArAndUrUpdate = true;
            refReq.Reference_Request_Status__c = 'Completed';
            update refReq;
        test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    //Test method for Update Event
    public static testMethod void testUpdateEvent1() {
        try{
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        ConstantsController.isfromInfluitiveBatch = true;
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        refReq = new Reference_Request__c(Requester__c = UserInfo.getUserId(),Opportunity__c = opps[0].Id);
        insert refReq;
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, new list<Reference_Request__c>{refReq}, refTypes);
        refReqAccs[0].Managed_Request__c = true;
        insert refReqAccs;
        List < Unspecified_Request__c > unSpeReqs = TestDataFactory.createUnspecifiedRequest(new list<Reference_Request__c>{refReq}, refTypes);
        insert unSpeReqs;
        list<Reference_Request__c> refReqList = [select Id, Name from Reference_Request__c LIMIT: limits.getLimitQueryRows()];
        system.assertEquals(1, refReqList.size());
        
        list<Reward__c> rw = new list<Reward__c>();
        rw.add(new Reward__c(Account__c = accounts[0].Id,Account_Request__c = refReqAccs[0].Id, Transaction__c = ConstantsController.ISSUE, Amount__c = 100,Available_Points__c =100));
        rw.add(new Reward__c(Account__c = accounts[1].Id,Account_Request__c = refReqAccs[1].Id,Transaction__c = ConstantsController.ISSUE, Amount__c = 100,Available_Points__c =100));
        insert rw;
        list<Hit_List__c> hits = new list<Hit_List__c>();
        hits.add(new Hit_List__c(Account__c = accounts[0].Id,Account_Request__c = refReqAccs[0].Id));
        hits.add(new Hit_List__c(Account__c = accounts[1].Id,Account_Request__c = refReqAccs[1].Id));
        insert hits;
        refReq.Opportunity__c = opps[1].Id;
        update refReq;
        delete refReqList;
        undelete refReqList;
        ConstantsController.shouldArAndUrUpdate = true;
        refReq.Reference_Request_Status__c = ConstantsController.NO_LONGER_NEEDED;
        update refReq;
        delete refReqAccs;
        }catch(Exception e){
            
        }
    }
}