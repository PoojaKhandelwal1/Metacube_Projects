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
public class TestBatch_ReferenceRequestAccount {
    //Unit Test 01 No response when Include Weekends = false
    static testmethod void myUnitTest01() {
        User u = TestDataFactory.CreateUser();
        insert u;
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Include_Weekends__c = false;
        update customSetting;
        List<Account> accounts = TestDataFactory.createAccounts();
        
        system.runAs(u) {
            insert accounts;
        }
        List<Opportunity> opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        list<Reference_Request__c> refReqs = TestDataFactory.createMoreReferenceRequest();
        integer index = 0;
        
        for (Reference_Request__c rr : refReqs) {
            rr.Opportunity__c = opps[index].Id;
            index++;
            
            if (index >= opps.size()) {
                index = 0;
                }                 
        }
        insert refReqs;
        
        list<Task> tasks = TestDataFactory.createTask();
        insert tasks;        
        List<Reference_Request_Account__c> refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        
        for (Reference_Request_Account__c rra : refReqAccs) {
            rra.Task_ID__c = tasks[0].Id;
            rra.Deadline__c = Date.today();
            rra.Is_Reminder_to_Owner__c = false;
            rra.Reference_Owner__c = u.Id;
            rra.Project_Owner__c = u.Id;
            rra.Is_Escalation_to_Owner_Manager__c = false;
            rra.Requester__c = u.Id;
        }
        insert refReqAccs;
        test.startTest();
            //update Reference_Request_Account
            refReqAccs[0].Deadline__c = (system.today()).addDays(1);
            update refReqAccs[0];
            Batch_ReferenceRequestAccount batchrrr = new Batch_ReferenceRequestAccount();
            ID batchprocessid = database.executebatch(batchrrr);
        test.stopTest();
        List<Reference_Request_Account__c> rraList = [select Id, Is_No_Response__c from Reference_Request_Account__c where Id = : refReqAccs[0].Id];
        system.assertEquals(rraList[0].Is_No_Response__c, true);
    }

    //Unit Test 02 No response when Include Weekends = true
    static testmethod void myUnitTest02() {
        User u = TestDataFactory.CreateUser();
        insert u;
        
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        update customSetting;
        List<Account> accounts = TestDataFactory.createAccounts();
        
        system.runAs(u) {
            insert accounts;
        }
        List<Opportunity> opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Reference_Request__c> refReqs = TestDataFactory.createMoreReferenceRequest();
        integer index = 0;
        
        for (Reference_Request__c rr : refReqs) {
            rr.Opportunity__c = opps[index].Id;
            index++;
            
            if (index >= opps.size()) {
                index = 0;
            }
        }
        insert refReqs;        
        List<Task> tasks = TestDataFactory.createTask();
        insert tasks;
        
        List<Reference_Request_Account__c> refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        
        for (Reference_Request_Account__c rra : refReqAccs) {
            rra.Task_ID__c = tasks[0].Id;
            rra.Deadline__c = Date.today();
            rra.Is_Reminder_to_Owner__c = false;
            rra.Reference_Owner__c = u.Id;
            rra.Project_Owner__c = u.Id;
            rra.Is_Escalation_to_Owner_Manager__c = false;
            rra.Requester__c = u.Id;
        }
        insert refReqAccs;
        test.startTest();
            //update Reference_Request_Account
            refReqAccs[0].Deadline__c = (system.today()).addDays(2);
            update refReqAccs[0];
           Batch_ReferenceRequestAccount batchrrr = new Batch_ReferenceRequestAccount();
            ID batchprocessid = database.executebatch(batchrrr);
        test.stopTest();
        List<Reference_Request_Account__c> rraList = [select Id, Is_No_Response__c from Reference_Request_Account__c where Id = : refReqAccs[0].Id];
        system.assert(rraList.size() > 0);
    }

    //Unit Test 03 No response when NO_RESPONSE = 0
    static testmethod void myUnitTest03() {
        User u = TestDataFactory.CreateUser();
        insert u;
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Include_Weekends__c = false;
        update customSetting;
        List<Account> accounts = TestDataFactory.createAccounts();
        
        system.runAs(u) {
            insert accounts;
        }
        List<Opportunity> opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Reference_Request__c> refReqs = TestDataFactory.createMoreReferenceRequest();
        integer index = 0;
        
        for (Reference_Request__c rr : refReqs) {
            rr.Opportunity__c = opps[index].Id;
            index++;
            
            if (index >= opps.size()) {
                index = 0;
            }
        }
        insert refReqs;
        List<Task> tasks = TestDataFactory.createTask();
        insert tasks;        
        List<Reference_Request_Account__c> refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        
        for (Reference_Request_Account__c rra : refReqAccs) {
            rra.Task_ID__c = tasks[0].Id;
            rra.Deadline__c = Date.today();
            rra.Is_Reminder_to_Owner__c = true;
            rra.Reference_Owner__c = u.Id;
            rra.Project_Owner__c = u.Id;
            rra.Is_Escalation_to_Owner_Manager__c = true;
            rra.Requester__c = u.Id;
        }
        insert refReqAccs;
        test.startTest();
            refReqAccs[0].Deadline__c = (system.today()).addDays(0);
            update refReqAccs[0];
            Batch_ReferenceRequestAccount batchrrr = new Batch_ReferenceRequestAccount();
            ID batchprocessid = database.executebatch(batchrrr);
        test.stopTest();
        List<Reference_Request_Account__c> rraList = [select Id, Is_No_Response__c from Reference_Request_Account__c where Id = : refReqAccs[0].Id];
        system.assert(rraList.size() > 0);
    }
    
    //Unit Test 04 Escalation
    static testmethod void myUnitTest04() {
        User u = TestDataFactory.CreateUser();
        insert u;
        User u2 = TestDataFactory.CreateUser();
        u2.firstname = 'testportest2';
        u2.lastname = 'testportest2';
        u2.Alias = 'portest2';
        u2.email = 'testportest@testportest2.com';
        u2.username = 'testportest@testportest2.com';
        u2.ManagerId = u.Id;
        insert u2;
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        
        system.runAs(u2) {
            insert accounts;
        }
        List<Opportunity> opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Reference_Request__c> refReqs = TestDataFactory.createMoreReferenceRequest();
        integer index = 0;
        
        for (Reference_Request__c rr : refReqs) {
            rr.Opportunity__c = opps[index].Id;
            index++;
            
            if (index >= opps.size()) {
                index = 0;
            }
        }
        insert refReqs;        
        List<Task> tasks = TestDataFactory.createTask();
        insert tasks;        
        List<Reference_Request_Account__c> refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        
        for (Reference_Request_Account__c rra : refReqAccs) {
            rra.Task_ID__c = tasks[0].Id;
            rra.Deadline__c = Date.today();
            rra.Is_Reminder_to_Owner__c = true;
            rra.Reference_Owner__c = u2.Id;
            rra.Project_Owner__c = u2.Id;
        }
        insert refReqAccs;
        test.startTest();
            //update Reference_Request_Account
            refReqAccs[0].Deadline__c = (system.today()).addDays(2);
            update refReqAccs[0];
            Batch_ReferenceRequestAccount batchrrr = new Batch_ReferenceRequestAccount();
            ID batchprocessid = database.executebatch(batchrrr);
        //Stop test method
        test.stopTest();
        List<Reference_Request_Account__c> rraList = [select Id, Is_Escalation_to_Owner_Manager__c from Reference_Request_Account__c where Id = : refReqAccs[0].Id];
        system.assert(rraList.size() > 0);
    }
    
    //Unit Test 05 Reminder
    static testmethod void myUnitTest05() {
        User u = TestDataFactory.CreateUser();
        insert u;
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Include_Weekends__c = false;
        update customSetting;
        List<Account> accounts = TestDataFactory.createAccounts();
        
        system.runAs(u) {
          insert accounts;
        }
        List<Opportunity> opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Reference_Request__c> refReqs = TestDataFactory.createMoreReferenceRequest();
        integer index = 0;
        
        for (Reference_Request__c rr : refReqs) {
          rr.Opportunity__c = opps[index].Id;
          index++;
          
           if (index >= opps.size()) {
             index = 0;
           }
        }
        insert refReqs;        
        List<Task> tasks = TestDataFactory.createTask();
        insert tasks;        
        List < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        
        for (Reference_Request_Account__c rra : refReqAccs) {
          rra.Task_ID__c = tasks[0].Id;
          rra.Deadline__c = Date.today();
          rra.Reference_Owner__c = u.Id;
          rra.Project_Owner__c = u.Id;
          rra.Is_Reminder_to_Owner__c = false;
          rra.Requester__c = u.Id;
        }
        insert refReqAccs;
        //Start test method
        test.startTest();
          //update Reference_Request_Account
          refReqAccs[0].Deadline__c = (system.today()).addDays(3);
          update refReqAccs[0];
          Batch_ReferenceRequestAccount batchrrr = new Batch_ReferenceRequestAccount();
          ID batchprocessid = database.executebatch(batchrrr);
        //Stop test method
        test.stopTest();
        List<Reference_Request_Account__c> rraList = [select Id, Is_Reminder_to_Owner__c from Reference_Request_Account__c where Id = : refReqAccs[0].Id];
        system.assert(rraList.size() > 0);         
    }    
    
}