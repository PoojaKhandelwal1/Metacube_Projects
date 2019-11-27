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
public with sharing class TestRRAccountTriggerHandler {
    //Test method for Insertion
    public static testMethod void RRAccountTestForInsert() {
        TestDataFactory.createCustomNotifications();
        //Start test method
        Test.StartTest();
            POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
            insert cs;
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
            refReqs[0].Project_Type__c = 'Member';
            insert refReqs;
            List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
            insert refTypes;
            list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
            refReqAccs[0].Activity_Date__c = system.today().addDays(5);
            refReqAccs[0].Managed_Request__c = true;
            refReqAccs[0].Reference_Use__c = true;
            refReqAccs[1].Managed_Request__c = true;
            refReqAccs[1].Process__c = 'Managed';
            try{
                insert refReqAccs;
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            refReqAccs[0].Activity_Date__c = system.today().addDays(-2);
            refReqAccs[0].Account_Request_Status__c = 'Completed';
            refReqAccs[1].Account_Request_Status__c = 'Completed';
            insert refReqAccs;
            list<Reference_Request_Account_Contact__c> conReqs = TestDataFactory.createContactRequests(contacts, refReqAccs, refTypes);
            insert conReqs;
            refReqAccs[0].Activity_Date__c = system.today().addDays(5);
            try{
                update refReqAccs;
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            Reference_Request_Account__c rra = [select Account_Request_Status__c from Reference_Request_Account__c where Id = :refReqAccs[0].Id limit 1];
            system.assertEquals(rra.Account_Request_Status__c, 'Completed');
            delete refReqAccs;
        //Stop test method       
        Test.stopTest();
    }
    //Test method for Updation
    public static testMethod void RRAccountTestForUpdate() {
        TestDataFactory.createCustomNotifications();
        //Start test method
        Test.StartTest();
            POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
            insert cs;
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            list<Reference_Request__c> refReqs = new list<Reference_Request__c>{TestDataFactory.createReferenceRequest()[0]};
            refReqs[0].Project_Type__c = 'Member';
            insert refReqs;
            List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
            insert refTypes;
            list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
            refReqAccs[1].Managed_Request__c = true;
            refReqAccs[1].Process__c = 'Managed';
            insert refReqAccs;
            list<Reference_Request_Account_Contact__c> conReqs = TestDataFactory.createContactRequests(contacts, refReqAccs, refTypes);
            insert conReqs;
            refReqAccs[0].Account_Request_Status__c = 'Completed';
            refReqAccs[1].Managed_Request__c = false;
            refReqAccs[1].Process__c = ConstantsController.REP2REP;
            update refReqAccs;
            refReqAccs[0].Project_Owner__c = UserInfo.getUserId();
            update refReqAccs;
            system.assertEquals(6,refReqAccs.size());
            
            delete refReqAccs;
            undelete refReqAccs;
        //Stop test method    
        Test.stopTest();
    }
}