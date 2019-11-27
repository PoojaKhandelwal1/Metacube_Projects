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
public class TestInflEvent{
    
    /* Issue and Redeem reward to contact
     * This method is use to test post an event to influitive.
     *
     */ 
    static testmethod void postEventToInfluitive(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();
        system.runAs(u) {
        	
        	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        	List<Reference_Basic_Information__c>  rbiList = new List<Reference_Basic_Information__c>();
            
            customSetting.Is_Influitive_Integration_Enabled__c = true;
            customSetting.Infl_Event_Fetch_DateTime__c = '2015-12-22T10:56:49Z';
            update customSetting;
            
            //issueing rewards
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            
            TestDataFactory.setUpAccountRBI(accounts);
            
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            
            //if contact is exist with below email id
            contacts.get(0).email = 'metacube.narendra@gmail.com';
            update contacts;
            
            rbiList.add(new Reference_Basic_Information__c(Contact__c = contacts[0].Id, Account__c = contacts[0].AccountId, Is_Referenceable__c = true, Referenceability_Status__c = ConstantsController.ACTIVE));
            rbiList.add(new Reference_Basic_Information__c(Contact__c = contacts[1].Id, Account__c = contacts[1].AccountId, Is_Referenceable__c = true, Referenceability_Status__c = ConstantsController.ACTIVE));
            insert rbiList;
            
            Integer points = 1000;
            Date createdAt = Date.today();
            
            String defaultRefType = createReferenceabilityType();
            
            List<Reward__c> issueRewards = new List<Reward__c>();
            Reward__c issueReward = new Reward__c(Account__c = contacts[0].AccountId,Contact__c = contacts[0].id,
                                                             Transaction__c ='Issue',Amount__c = points, 
                                                             Available_Points__c = points,Referenceability_Type__c = defaultRefType,Influitive_ID2__c = '' ,RewardDate__c = createdAt);
			Reward__c redeemReward = new Reward__c(Account__c = contacts[0].AccountId, Contact__c = contacts[0].id,transaction__c = 'Redeem',Amount__c = 50,Influitive_ID2__c = '',RewardDate__c= createdAt);
            issueRewards.add(issueReward);
            issueRewards.add(redeemReward);
            insert issueRewards;
          
            System.assertNotEquals(issueRewards[0].id, null);
        }
         //Stop test method
        test.stopTest();
    }
 
    private static String createReferenceabilityType(){
        Referenceability_Type__c refTye = new Referenceability_Type__c(Name = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT,Referenceability_code__c = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT,Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true,min_lead_time_per_request_type__c = 10,max_accounts_per_request_type__c = 15,Reward_points__c = 100,Note__c = 'test notes');
        insert refTye;
        return refTye.Id;
    }
    
    @isTest static void testSyncRewardAtHub() {
        User u = TestDataFactory.CreateUser();
        
        test.startTest();
        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List<Reference_Basic_Information__c>  rbiList = new List<Reference_Basic_Information__c>();
            
            customSetting.Is_Influitive_Integration_Enabled__c = true;
            customSetting.Infl_Event_Fetch_DateTime__c = '2015-12-22T10:56:49Z';
            update customSetting;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            rbiList.add(new Reference_Basic_Information__c(Contact__c = contacts[0].Id, Account__c = contacts[0].AccountId, Is_Referenceable__c = true, Referenceability_Status__c = ConstantsController.ACTIVE));
            rbiList.add(new Reference_Basic_Information__c(Contact__c = contacts[1].Id, Account__c = contacts[1].AccountId, Is_Referenceable__c = true, Referenceability_Status__c = ConstantsController.ACTIVE));
            insert rbiList;
            Integer points = 1000;
            Date createdAt = Date.today();
            String defaultRefType = createReferenceabilityType();
            List<Reward__c> issueRewards = new List<Reward__c>();
            Reward__c issueReward = new Reward__c(Account__c = contacts[0].AccountId,Contact__c = contacts[0].id,
                                                  Transaction__c ='Issue',Amount__c = points, 
                                                  Available_Points__c = points,Referenceability_Type__c = defaultRefType,Influitive_ID2__c = '' ,RewardDate__c = createdAt);
            
            issueRewards.add(issueReward);
            insert issueRewards;
            String result = Infl_Event.syncRewardAtHub(issueRewards[0],'ref');
            test.stopTest();
            
            System.assertNotEquals(issueRewards, null);
        }
    }   
}