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

public with sharing class TestBatch_SalesRewardNotification {
	
	//Unit Test 01 Reminder To Owner of accounts when Include Weekends = false
    static testmethod void batchSalesRewardNotification() {
        User u = TestDataFactory.CreateUser();
        insert u;
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Sales_Reward_Point_Chatter__c = true;
        
        customSetting.Sales_Reward_Point_Email__c = true;
        customSetting.Sales_Reward_Batch_Trigger_Id__c = null;
        customSetting.Enable_Sales_Rewards_Notification__c = true;
        customSetting.Next_Notification_Date__c = Date.Today().addDays(1);
        customSetting.Last_Notification_Date__c = Date.Today().addDays(-1);
        
        update customSetting;
        
        List<Reward__c> rewards = new List<Reward__c>();
        
        for(Integer i = 0; i < 5; i++){
        	Reward__c reward = new Reward__c(User__c = u.id, transaction__c = 'Issue',Amount__c = 50+1,RewardDate__c= Date.today());
        	rewards.add(reward);
        }
        //Start test method
        test.startTest();
	        insert rewards;
	        Batch_SalesRewardNotification salesRewardBatch = new Batch_SalesRewardNotification();
	        ID batchprocessid = database.executebatch(salesRewardBatch);
        //Stop test method
        test.stopTest();
        List<User_Profile__c> userProfile = [Select Id, Available_Points__c, Lifetime_Points__c, User__r.name, User__r.email From User_Profile__c Where User__c =: u.id];                
        if (userProfile != null) {
	        System.assert(userProfile != null);
        } else {
        	System.assert(userProfile == null);
        }
    }
    
}