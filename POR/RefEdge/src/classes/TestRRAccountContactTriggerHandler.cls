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
public with sharing class TestRRAccountContactTriggerHandler {
    
    //Test method for Insertion
    public static testMethod void RRAccountContactTestForInsert() {
        TestDataFactory.createCustomNotifications();
        //Start test method
        Test.StartTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Automatically_Assign_Reward_on_Feedback__c = false;
            customSetting.Automatically_Assign_Rewards__c = true;
            update customSetting;
            POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
            insert cs;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
            insert rfTypes;
            Reference_Request__c refReq = new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'In Progress',Project_Type__c = 'Member');
            insert refReq;
            List < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, new list<Reference_Request__c>{refReq},rfTypes);
            refReqAccs[0].Reference_Use__c = true;
            refReqAccs[0].Managed_Request__c = true;
            refReqAccs[1].Managed_Request__c = true;
            insert refReqAccs;
            List < Reference_Request_Account_Contact__c > refReqAccContact = TestDataFactory.createContactRequests(contacts,refReqAccs,rfTypes);
            refReqAccContact[0].Reference_Use__c = true;
            refReqAccContact[0].Activity_Date__c = system.today().addDays(5);
            try{
                insert refReqAccContact;
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            refReqAccContact[0].Activity_Date__c = system.today().addDays(-2);
            refReqAccContact[1].Activity_Date__c = system.today().addDays(-3);
            refReqAccContact[0].Contact_Request_Status__c = 'Completed';
            refReqAccContact[1].Contact_Request_Status__c = 'Completed';
            insert refReqAccContact;
            refReqAccContact[0].Activity_Date__c = system.today().addDays(5);
            try{
                update refReqAccContact;
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            refReqAccContact[0].Activity_Date__c = system.today().addDays(-2);
            refReqAccs[0].Account_Request_Status__c = 'Completed';
            update refReqAccs;
            Reference_Request_Account__c rra = [select Account_Request_Status__c from Reference_Request_Account__c where Id = :refReqAccs[0].Id limit 1];
            system.assertEquals(rra.Account_Request_Status__c, 'Completed');
            //update refReqAccs;
        //Stop test method       
        Test.stopTest();
    }
    //Test method for Updation
    public static testMethod void RRAccountContactTestForUpdate() {
        TestDataFactory.createCustomNotifications();
        //Start test method
        Test.StartTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Automatically_Assign_Reward_on_Feedback__c = true;
            customSetting.Automatically_Assign_Rewards__c = false;
            update customSetting;
            POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
            insert cs;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
            insert rfTypes;
            Reference_Request__c refReq = new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'In Progress',Project_Type__c = 'Member');
            insert refReq;
            List < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, new list<Reference_Request__c>{refReq},rfTypes);
            refReqAccs[0].Reference_Use__c = true;
            refReqAccs[0].Managed_Request__c = true;
            refReqAccs[1].Managed_Request__c = true;
            insert refReqAccs;
            List < Reference_Request_Account_Contact__c > refReqAccContact = TestDataFactory.createContactRequests(contacts,refReqAccs,rfTypes);
            refReqAccContact[0].Reference_Use__c = true;
            refReqAccContact[0].Contact_Request_Status__c = 'Completed';
            insert refReqAccContact;
            
            refReqAccContact[1].Contact_Request_Status__c = 'Completed';
            update refReqAccContact;
            //Reference_Request_Account_Contact__c rrac = [select Project_Owner__c from Reference_Request_Account_Contact__c where Id =:refReqAccContact[0].Id limit 1];
            system.assertEquals(6,refReqAccContact.size());
            
            refReqAccContact[0].Is_Feedback_Received__c = true;
            refReqAccContact[0].Feedback_Status__c = ConstantsController.FEEDBACK_SUCCESSFUL;
            refReqAccContact[1].Is_Feedback_Received__c = true;
            refReqAccContact[1].Feedback_Status__c = ConstantsController.FEEDBACK_SUCCESSFUL;
            ConstantsController.shouldRewardRecordsCreated = true;
            
        //Stop test method    
        Test.stopTest();
        update refReqAccContact;
        delete refReqAccContact;
        undelete refReqAccContact;
    }
}