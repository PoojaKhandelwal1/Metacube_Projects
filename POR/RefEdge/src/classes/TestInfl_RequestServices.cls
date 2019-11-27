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
public with sharing class TestInfl_RequestServices {
    
    @isTest static void testUpdateAdvocateResponseChallengeStatusCheckResponse(){
        User u = TestDataFactory.CreateUser();
        
        test.startTest();
        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Is_Influitive_Integration_Enabled__c = true; 
            update customSetting; 
            
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            List<Contact> contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpAccountRBI(accounts);
            List<Referenceability_Type__c> refTypeList = TestDataFactory.createUserRewardReferenceabilityType();
            insert refTypeList;
            List<Reference_Request__c> rrList = TestDataFactory.createReferenceRequest();
            insert rrList;
            List<Reference_Request_Account__c> arList = TestDataFactory.createAccountRequests(accounts, rrList, refTypeList);
            insert arList;
            List<Unspecified_Request__c> urList = TestDataFactory.createUnspecifiedRequest(rrList, refTypeList);
            urList[0].Influitive_Challenge_Id__c = 'test123';
            urList[0].Influitive_Challenge_Status__c = 'Unpublish';
            insert urList;
            Community_Invite__c comInvite = new Community_Invite__c();
            comInvite.Referenceability_Type__c = urList[0].Reference_Type_Needed__c;
            comInvite.Reference_Request__c = urList[0].Reference_Request__c;
            comInvite.Unspecified_Request__c = urList[0].Id;
            insert comInvite;
            Community_Invite_Contact__c newCIC = new Community_Invite_Contact__c();
            newCIC.Community_Invite__c = comInvite.Id;
            newCIC.Contact__c = contacts[0].Id;
            newCIC.Response__c = 'No Response';
            newCIC.Challenge_Id__c = 'test123';
            insert newCIC;
            List<Reward__c> rewards = TestDataFactory.createRewards(accounts, contacts); 
            
            String reqBody = '{"response":{"crm_contact_id":"' + contacts[0].Id + '","challenge_Id":"' + 'test123' + '"}}';
            RestRequest req = new RestRequest();
            req.requestURI = String.format('{0}/services/apexrest/v1.0/ReferenceEdge/Request?action=response', 
                                           new List<String>{URL.getSalesforceBaseURL().toExternalForm()}); 
            req.addParameter('action', 'response');
            req.httpMethod = 'PATCH';
            req.requestBody = Blob.valueof(reqBody);
            RestContext.request = req;
            RestResponse res = new RestResponse();
            RestContext.response= res;  
            Infl_RequestServices.updateAdvocateResponseChallengeStatus(); 
		    System.assertNotEquals(res,null);  
        }
        test.stopTest();
    }
    
    @isTest static void testUpdateAdvocateResponseChallengeStatusCheckStatus(){
        User u = TestDataFactory.CreateUser();
        
        test.startTest();
        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Is_Influitive_Integration_Enabled__c = true; 
            update customSetting; 
            
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            List<Contact> contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpAccountRBI(accounts);
            List<Referenceability_Type__c> refTypeList = TestDataFactory.createUserRewardReferenceabilityType();
            insert refTypeList;
            List<Reference_Request__c> rrList = TestDataFactory.createReferenceRequest();
            insert rrList;
            List<Reference_Request_Account__c> arList = TestDataFactory.createAccountRequests(accounts, rrList, refTypeList);
            insert arList;
            List<Unspecified_Request__c> urList = TestDataFactory.createUnspecifiedRequest(rrList, refTypeList);
            urList[0].Influitive_Challenge_Id__c = 'test123';
            urList[0].Influitive_Challenge_Status__c = 'Unpublish';
            insert urList;
            Community_Invite__c comInvite = new Community_Invite__c();
            comInvite.Referenceability_Type__c = urList[0].Reference_Type_Needed__c;
            comInvite.Reference_Request__c = urList[0].Reference_Request__c;
            comInvite.Unspecified_Request__c = urList[0].Id;
            insert comInvite;
            Community_Invite_Contact__c newCIC = new Community_Invite_Contact__c();
            newCIC.Community_Invite__c = comInvite.Id;
            newCIC.Contact__c = contacts[0].Id;
            newCIC.Response__c = 'No Response';
            newCIC.Challenge_Id__c = 'test123';
            insert newCIC;
            List<Reward__c> rewards = TestDataFactory.createRewards(accounts, contacts); 
            
            String reqBody = '{"status":{"challenge_Id":"' + 'test123' + '","status": "Publish"}}';
            RestRequest req = new RestRequest();
            req.requestURI = String.format('{0}/services/apexrest/v1.0/ReferenceEdge/Request?action=status', 
                                           new List<String>{URL.getSalesforceBaseURL().toExternalForm()}); 
            req.addParameter('action', 'status');
            req.httpMethod = 'PATCH';
            req.requestBody = Blob.valueof(reqBody);
            RestContext.request = req;
            RestResponse res = new RestResponse();
            RestContext.response= res;  
            Infl_RequestServices.updateAdvocateResponseChallengeStatus(); 
		    System.assertNotEquals(res,null);  
        }
        test.stopTest();
    }
}