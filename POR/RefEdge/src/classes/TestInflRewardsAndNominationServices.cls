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
/**
* Class : nflRewardsAndNominationServices
* Description : class to test and cover InflRewardsAndNominationServices
* Modified by: Rajesh @17 Sept 2018 
*/ 
@isTest(seeAllData = false)
public with sharing class TestInflRewardsAndNominationServices {
    /**
     * Test method to test API for nomination creation
     * author: Rajesh (17 Sept, 2018) for #1842
     */
    static testmethod void testPostNominationForNomination(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();

        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Is_Influitive_Integration_Enabled__c = true; 
            customSetting.Create_Advocate_Reference_Profile__c = false; 
            update customSetting; 
          
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts; 

            TestDataFactory.setUpAccountRBI(accounts);
            List<Contact> contacts = TestDataFactory.createContacts(accounts);
            insert contacts;  
 
            //Nomination Testing
            String reqBody ='{"nominations":[{"crm_account_Id":null,"crm_contact_id":"' + contacts[0].Id + '","influitive_Id":"INFL-102"},{"crm_account_Id":null,"crm_contact_id":"' + contacts[1].Id + '","influitive_Id":"INFL-101"}]}';   
            RestRequest req = new RestRequest();
            req.requestURI = String.format('{0}/services/apexrest/v1.0/ReferenceEdge?action=nominations', 
                                                new List<String>{URL.getSalesforceBaseURL().toExternalForm()}); 
            req.addParameter('action', 'nominations');
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(reqBody);
            RestContext.request = req;
            RestResponse res = new RestResponse();
            RestContext.response= res;  
            InflRewardsAndNominationServices.createNomintaion(); 
            List<Nomination__c> lstNomination = new List<Nomination__c>();
            lstNomination = [SELECT ID from Nomination__c];  
		    System.assertEquals(2, lstNomination.size());  
        }
         //Stop test method
        test.stopTest();
    }

    /**
     * Test method to test API for Reference Profile creation
     * author: Rajesh (17 Sept, 2018) for #1842
     */
    static testmethod void testPostNominationForRBI(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();

        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Is_Influitive_Integration_Enabled__c = true; 
            customSetting.Create_Advocate_Reference_Profile__c = true; 
            update customSetting;
            
            //issueing rewards
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts; 

            TestDataFactory.setUpAccountRBI(accounts);
            List<Contact> contacts = TestDataFactory.createContacts(accounts);
            insert contacts; 
             
            //Nomination Testing
            String reqBody ='{"nominations":[{"crm_account_Id":null,"crm_contact_id":"' + contacts[0].Id + '","influitive_Id":"INFL-102"},{"crm_account_Id":null,"crm_contact_id":"' + contacts[1].Id + '","influitive_Id":"INFL-101"}]}';   
            RestRequest req = new RestRequest();
            req.requestURI = String.format('{0}/services/apexrest/v1.0/ReferenceEdge?action=nominations', 
                                                new List<String>{URL.getSalesforceBaseURL().toExternalForm()}); 
            req.addParameter('action', 'nominations');
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(reqBody);
            RestContext.request = req;
            RestResponse res = new RestResponse();
            RestContext.response= res;  
            InflRewardsAndNominationServices.createNomintaion(); 
            List<Reference_Basic_Information__c> lstRbi = new List<Reference_Basic_Information__c>();
            lstRbi = [SELECT ID from Reference_Basic_Information__c WHERE influitive_Id__c != null]; 
		    System.assertEquals(2, lstRbi.size()); 
        }
         //Stop test method
        test.stopTest();
    }

    /**
     * Test method to test API for Rewards creation
     * author: Rajesh (17 Sept, 2018) for #1842
     */
    static testmethod void testPostNominationForRewards(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();

        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Is_Influitive_Integration_Enabled__c = true; 
            customSetting.Create_Advocate_Reference_Profile__c = true; 
            update customSetting;
            
            //issueing rewards
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts; 

            TestDataFactory.setUpAccountRBI(accounts);
            List<Contact> contacts = TestDataFactory.createContacts(accounts);
            insert contacts; 
             
            String reqBody ='{"rewards":[{"crm_account_Id":null,"crm_contact_id":"' + contacts[0].Id + '","influitive_Id":"INFL-102","transaction_type":"Issue", "Points":"100","type":"refedge_form"},{"crm_account_Id":null,"crm_contact_id":"' + contacts[0].Id + '","influitive_Id":"INFL-101","transaction_type":"Reedem", "Points":"150"}]}';   
            RestRequest req = new RestRequest();
            req.requestURI = String.format('{0}/services/apexrest/v1.0/ReferenceEdge?action=rewards', 
                                                new List<String>{URL.getSalesforceBaseURL().toExternalForm()}); 
            req.addParameter('action', 'rewards');
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(reqBody);
            RestContext.request = req;
            RestResponse res = new RestResponse();
            RestContext.response= res;  
            InflRewardsAndNominationServices.createNomintaion(); 
            List<Reward__c> lstReward = new List<Reward__c>();
            lstReward = [SELECT ID from Reward__c];  
		    System.assertEquals(2, lstReward.size()); 
        }
         //Stop test method
        test.stopTest();
    }

    /**
     * Test method to test API for validation
     * author: Rajesh (17 Sept, 2018) for #1842
     */
    static testmethod void testVaidationForRequest(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();

        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Is_Influitive_Integration_Enabled__c = true; 
            
            update customSetting;
            
            //issueing rewards
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts; 

            TestDataFactory.setUpAccountRBI(accounts);
            List<Contact> contacts = TestDataFactory.createContacts(accounts);
            insert contacts; 
            
            String reqBody ='{}';   
            RestRequest req = new RestRequest();
            req.requestURI = String.format('{0}/services/apexrest/v1.0/ReferenceEdge?action=rewards', 
                                                new List<String>{URL.getSalesforceBaseURL().toExternalForm()}); 
            req.addParameter('action', 'rewards');
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(reqBody);
            RestContext.request = req;
            RestResponse res = new RestResponse();
            RestContext.response= res;  
            InflRewardsAndNominationServices.createNomintaion(); 
            System.assertEquals(400, RestContext.response.statusCode); 

            reqBody ='{"rewards":[{"crm_account_Id":null,"crm_contact_id":"' + contacts[0].Id + '","influitive_Id":"INFL-102","transaction_type":"Issue", "Points":"100","type":"refedge_form"},{"crm_account_Id":null,"crm_contact_id":"' + contacts[0].Id + '","influitive_Id":"INFL-101","transaction_type":"Reedem", "Points":"150"}]}';      
            req = new RestRequest();
            req.requestURI = String.format('{0}/services/apexrest/v1.0/ReferenceEdge', 
                                                new List<String>{URL.getSalesforceBaseURL().toExternalForm()}); 
            //req.addParameter('action', 'rewards');
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(reqBody);
            RestContext.request = req;
            res = new RestResponse();
            RestContext.response= res;  
            InflRewardsAndNominationServices.createNomintaion(); 
            System.assertEquals(400, RestContext.response.statusCode); 
            
            reqBody ='{}';   
            req = new RestRequest();
            req.requestURI = String.format('{0}/services/apexrest/v1.0/ReferenceEdge?action=xxx', 
                                                new List<String>{URL.getSalesforceBaseURL().toExternalForm()}); 
            req.addParameter('action', 'rewards');
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(reqBody);
            RestContext.request = req;
            res = new RestResponse();
            RestContext.response= res;  
            InflRewardsAndNominationServices.createNomintaion(); 
            System.assertEquals(400, RestContext.response.statusCode);
        }
         //Stop test method
        test.stopTest();
    }

    /**
     * Method to create Referenceability Type
     * author: Rajesh (17 Sept, 2018) for #1842
     */
    private static String createReferenceabilityType(){
        Referenceability_Type__c refTye = new Referenceability_Type__c(Name = 'refedge_form', 
                                                                        Referenceability_code__c = 'refedge_form',
                                                                        Referenceability_Type__c = true, 
                                                                        Visible__c = true, Project_type__c = true, 
                                                                        Request_type__c = true, 
                                                                        min_lead_time_per_request_type__c = 10, 
                                                                        max_accounts_per_request_type__c = 15,Reward_points__c = 100,
                                                                        Note__c = 'test notes');
        insert refTye;
        return refTye.Id;
    } 
}