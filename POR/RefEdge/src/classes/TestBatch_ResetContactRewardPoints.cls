/*
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
 * This is test class for Batch_ResetContactRewardPoints
 * @Author Narender Singh
 * @version 1.0
 * @see
 * @since 12-APR-2016
 */
 @isTest(seeAllData = false)
 public with sharing class TestBatch_ResetContactRewardPoints {
	static TestMethod void testContactResetBatch(){
		User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();
        system.runAs(u) {
        	//issueing rewards
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            
            TestDataFactory.setUpAccountRBI(accounts);
            
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            
            Reference_Basic_Information__c newrbi = new Reference_Basic_Information__c(Contact__c = contacts[0].Id, Account__c = contacts[0].AccountId, Is_Referenceable__c = true, Referenceability_Status__c = ConstantsController.ACTIVE);
            insert newrbi;
            
            Referenceability_Type__c refTye = new Referenceability_Type__c(Name = 'refedge_form',Referenceability_code__c = 'refedge_form',Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true,min_lead_time_per_request_type__c = 10,max_accounts_per_request_type__c = 15,Reward_points__c = 100,Note__c = 'test notes');
        	insert refTye;
        	
            System.debug('newrbi :::::: '+newrbi);            
        	
            List<Reward__c> issueRewards = new List<Reward__c>();
            Reward__c issueReward = new Reward__c(Account__c = contacts[0].AccountId,Contact__c = contacts[0].id,
                                                             Transaction__c ='Issue',Amount__c = 1000, 
                                                             Available_Points__c = 1000,Referenceability_Type__c = refTye.Id,Influitive_ID2__c = '' ,RewardDate__c = Date.today()); 
            issueRewards.add(issueReward);
            insert issueRewards;
            
            Reference_Basic_Information__c tmpRBI = [select id,Current_Available_Balance_Points__c,Lifetime_Points__c from Reference_Basic_Information__c where Id =: newrbi.id limit 1];
            System.debug('tmpRBI ::: '+tmpRBI);
        	tmpRBI.Current_Available_Balance_Points__c = null;
        	update tmpRBI;
        	Reference_Basic_Information__c tmpRBI1 = [select id,Current_Available_Balance_Points__c,Lifetime_Points__c from Reference_Basic_Information__c where Id =: newrbi.id limit 1];
            System.debug('tmpRBI1 update ::: '+tmpRBI1);
            DataBase.executeBatch(new Batch_ResetContactRewardPoints());
        	
            Reference_Basic_Information__c tmpRBI2 = [select id,Current_Available_Balance_Points__c,Lifetime_Points__c from Reference_Basic_Information__c where Id =: newrbi.id limit 1];
            System.debug('tmpRBI1 ::: '+tmpRBI2);
            System.assert(true);
        }
         //Stop test method
        test.stopTest();
		
	}
}