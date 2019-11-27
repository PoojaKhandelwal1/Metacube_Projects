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
 * Class: Batch_UpdateCurrentAvailablePoints
 * Description : Batch is used to update current avilable points for RBI-#808
 * Last Modified by: Rajesh (17 April, 2017)
 */
@isTest
private class TestBatch_UpdateCurrentAvailablePoints {
	/**
     * Test method to check and update RBI current avilable points for Contact
     * Created By: Rajesh @19 April 2017
     */
    static testMethod void testUpdatePointsForContatct() {
       	User u = TestDataFactory.CreateUser();
       	Reference_Basic_Information__c tmpRBI2;
       	Id rbiId;
        //Start test method
		test.startTest();
                
        system.runAs(u) {
        	//Creating Account         
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            
            TestDataFactory.setUpAccountRBI(accounts);
            
            //Creating Contact
            List<Contact> contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            
            Reference_Basic_Information__c newrbi = new Reference_Basic_Information__c(Contact__c = contacts[0].Id, Account__c = contacts[0].AccountId, 
            										Is_Referenceable__c = true, Referenceability_Status__c = ConstantsController.ACTIVE);
            insert newrbi;
            
            rbiId = newrbi.id;
            //Creating Referenceability Type
            Referenceability_Type__c refTye = new Referenceability_Type__c(Name = 'refedge_form', Referenceability_code__c = 'refedge_form', 
            										Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true, 
            										min_lead_time_per_request_type__c = 10, max_accounts_per_request_type__c = 15, Reward_points__c = 100, 
            										Note__c = 'test notes');
        	insert refTye; 
        	
        	//Creating reward
            List<Reward__c> issueRewards = new List<Reward__c>();
            Reward__c issueReward = new Reward__c(Account__c = contacts[0].AccountId, Contact__c = contacts[0].id,
                                                             Transaction__c ='Issue', Amount__c = 1000, 
                                                             Available_Points__c = 1000, Referenceability_Type__c = refTye.Id, Influitive_ID2__c = '', 
                                                             RewardDate__c = Date.newInstance(2017, 01, 9), 
                                                             Expired__c = false, Expiration_Date__c = Date.newInstance(2017, 01, 19)); 
            issueRewards.add(issueReward);
            issueReward = new Reward__c(Account__c = contacts[0].AccountId, Contact__c = contacts[0].id,
                                                             Transaction__c ='Issue', Amount__c = 1000, 
                                                             Available_Points__c = 1000, Referenceability_Type__c = refTye.Id, Influitive_ID2__c = '', 
                                                             RewardDate__c = Date.today()); 
            issueRewards.add(issueReward);
            insert issueRewards;
            
            //Update RBI
            Reference_Basic_Information__c tmpRBI = [SELECT id, Current_Available_Balance_Points__c, Lifetime_Points__c 
            										FROM Reference_Basic_Information__c WHERE Id =:rbiId LIMIT 1];           
        	tmpRBI.Current_Available_Balance_Points__c = 500;
        	update tmpRBI; 
        	 
            DataBase.executeBatch(new Batch_UpdateCurrentAvailablePoints());  
        }
        //Stop test method
        test.stopTest();
         
      	tmpRBI2 = [SELECT id, Current_Available_Balance_Points__c, Lifetime_Points__c 
            										FROM Reference_Basic_Information__c WHERE Id =: rbiId LIMIT 1];  
        system.assertEquals(tmpRBI2.Current_Available_Balance_Points__c, 1000);
    } 
    
    /**
     * Test method to check and update RBI current avilable points for Account
     * Created By: Rajesh @19 April 2017
     */
    static testMethod void testUpdatePointsForAccount() {
       	User u = TestDataFactory.CreateUser();
       	Reference_Basic_Information__c tmpRBI2;
       	Id rbiId;
    	//Start test method
    	test.startTest();
    	
        system.runAs(u) {
        	//Creating Account  
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            
            TestDataFactory.setUpAccountRBI(accounts); 
            
            //Creating RBI  
            Reference_Basic_Information__c newrbi = new Reference_Basic_Information__c(Account__c = accounts[0].Id, 
            							Is_Referenceable__c = true, Referenceability_Status__c = ConstantsController.ACTIVE);
            insert newrbi;
            rbiId = newrbi.Id;
            //Creating Referenceability Type
            Referenceability_Type__c refTye = new Referenceability_Type__c(Name = 'refedge_form',
            							Referenceability_code__c = 'refedge_form', Referenceability_Type__c = true, 
            							Visible__c = true, Project_type__c = true, Request_type__c = true, 
            							min_lead_time_per_request_type__c = 10, max_accounts_per_request_type__c = 15, 
            							Reward_points__c = 100, Note__c = 'test notes');
        	insert refTye;
        	
        	// creating rewards 
            List<Reward__c> issueRewards = new List<Reward__c>();
            Reward__c issueReward = new Reward__c(Account__c = accounts[0].Id, 
                                                             Transaction__c ='Issue', Amount__c = 1000, 
                                                             Available_Points__c = 1000, Referenceability_Type__c = refTye.Id, Influitive_ID2__c = '', 
                                                             RewardDate__c = Date.newInstance(2017, 01, 9), 
                                                             Expired__c = false, Expiration_Date__c = Date.newInstance(2017, 01, 19)); 
            issueRewards.add(issueReward);
            issueReward = new Reward__c(Account__c = accounts[0].Id, 
                                                             Transaction__c ='Issue', Amount__c = 1000, 
                                                             Available_Points__c = 1000, Referenceability_Type__c = refTye.Id, Influitive_ID2__c = '', 
                                                             RewardDate__c = Date.today()); 
            issueRewards.add(issueReward);
            insert issueRewards;
            
            //Update RBI
            Reference_Basic_Information__c tmpRBI = [SELECT id, Current_Available_Balance_Points__c, Lifetime_Points__c 
            										FROM Reference_Basic_Information__c WHERE Id =:newrbi.id LIMIT 1];
           
        	tmpRBI.Current_Available_Balance_Points__c = 500;
        	update tmpRBI; 
        	
        	//excute batch to update current avilable points 
            DataBase.executeBatch(new Batch_UpdateCurrentAvailablePoints()); 
             
        }
        //Stop test method
        test.stopTest();
        tmpRBI2 = [SELECT id, Current_Available_Balance_Points__c, Lifetime_Points__c 
            										FROM Reference_Basic_Information__c WHERE Id =:rbiId LIMIT 1];
          									
        system.assertEquals(tmpRBI2.Current_Available_Balance_Points__c, 1000);
    }
}