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
 * Class: RedeemRewardController
 * Description: class to test AND cover RedeemRewardController
 * Created By: Rekha Jangir @19 May 2017
 */
@isTest(seeAllData = false)
public with sharing class TestRedeemRewardControllerSLDS {
    
    /**
     * Method to cover save method with valid amount for Account
     * Modified By: Rekha Jangir @19 May 2017
     */
    static testMethod void testRedeemRewardsFromAccount() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Limit_Contact_Redeem__c = false;
        update customSetting;
        Account accountA = new Account( Name = 'test account');
        insert accountA;
        Contact contactA = new Contact (lastName = 'test Contact', AccountId = accountA.Id);
        insert contactA;
        Contact contactB = new Contact (lastName = 'test Contact', AccountId = accountA.Id);
        insert contactB;
        List<Reference_Basic_Information__c> rbis = new List<Reference_Basic_Information__c>();
		rbis.add(new Reference_Basic_Information__c(Account__c = accountA.Id, Referenceability_Status__c = 'Active', Is_Referenceable__c = true));
		rbis.add(new Reference_Basic_Information__c(Account__c = accountA.Id, Contact__c = contactB.Id,  Referenceability_Status__c = 'Active', Is_Referenceable__c = true));
        insert rbis;
        List<Reward__c> issues = new List<Reward__c>();
        issues.add(new Reward__c(Available_Points__c = 5, Amount__c = 5, Account__c = accountA.Id, 
        							Transaction__c = ConstantsController.ISSUE));
        issues.add(new Reward__c(Available_Points__c = 15, Amount__c = 15, Account__c = accountA.Id, 
        							Transaction__c = ConstantsController.ISSUE));
        issues.add(new Reward__c(Available_Points__c = 40, Amount__c = 40, Contact__c = contactB.Id, 
        							Account__c = accountA.Id, Transaction__c = ConstantsController.ISSUE));
        issues.add(new Reward__c(Available_Points__c = 250, Amount__c = 250, Account__c = accountA.Id, 
        							Contact__c = contactB.Id, Transaction__c = ConstantsController.ISSUE));
        insert issues;
        
        //Start test method
        test.startTest();
            PageReference pageRef = Page.RedeemRewardSLDS;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('accountId', accountA.id);
            RedeemRewardControllerSLDS rrc = new RedeemRewardControllerSLDS();
            //fetch all required information
            RedeemRewardControllerSLDS.InfoWrapper info = RedeemRewardControllerSLDS.fetchInfo(rrc.accountId, rrc.contactId, rrc.userId);
            
            // set all data 
            info.amount = 200;
            info.comments = 'test reward';
            info.selectedContact = info.contacts[2];
            // save reward
            String result = RedeemRewardControllerSLDS.submit(JSON.serialize(info));
            
            List<Reward__c> reward = [SELECT Id, Amount__c FROM Reward__c WHERE Contact__c = :contactB.Id AND Transaction__c = :ConstantsController.REDEEM];
            system.assertEquals(180, reward[0].Amount__c);
        //Stop test method
        test.stopTest();
    }
    /**
     * Method to cover save method with valid amount for User
     * Modified By: Rekha Jangir @18 May 2017
     */
    static testMethod void testRedeemRewardsFromUser() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        User_Profile__c userProile = new User_Profile__c(Available_Points__c = 0, Lifetime_Points__c = 0, User__c = UserInfo.getUserId());
    	insert userProile;
        List<Reward__c> issues = new List<Reward__c>();
        issues.add(new Reward__c(Available_Points__c = 250, Amount__c = 250, User__c = UserInfo.getUserId(), Transaction__c = ConstantsController.ISSUE));
        insert issues;
        //Start test method
        test.startTest();
            PageReference pageRef = Page.RedeemRewardSLDS;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('userId', UserInfo.getUserId());
            pageRef.getParameters().put('retUrl', UserInfo.getUserId());
            RedeemRewardControllerSLDS rrc = new RedeemRewardControllerSLDS();
            //fetch all required information
            RedeemRewardControllerSLDS.InfoWrapper info = RedeemRewardControllerSLDS.fetchInfo(rrc.accountId, rrc.contactId, rrc.userId);
            
            // set all data 
            info.amount = 250;
            info.comments = 'test reward';
            // save reward
            String result = RedeemRewardControllerSLDS.submit(JSON.serialize(info));
            
            List<User_Profile__c> userList = [SELECT Id, Available_Points__c FROM User_Profile__c WHERE Id = :UserInfo.getUserId()];
        	System.assertEquals(userProile.Available_Points__c, 0);
        	
        //Stop test method
        test.stopTest();
    }
    /**
     * Method to cover save method with valid amount for Contact
     * Modified By: Rekha Jangir @18 May 2017
     */
    static testMethod void testRedeemRewardsFromContact() {
        //insert test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c');
		sObject obj = objectType.newSObject();
		Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
		customSetting.Shared_Contacts__c = true;
		customSetting.Shared_Contact_Object__c = describeResult.getName();
		customSetting.Shared_Account_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe().getName();
		customSetting.Shared_Contact_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Contact__c').getDescribe().getName();
		customSetting.Roll_up_Attributes_to_Primary_Account__c = true;
        customSetting.Roll_up_Referenceability_to_Primary_Acc__c = true;
        customSetting.Inherit_Attributes_from_All_Accounts__c = true;
		update customSetting;
		
		
        Account accountA = new Account( Name = 'test account');
        insert accountA;
        Account accountB = new Account( Name = 'test account new');
        insert accountB;
        Contact contactA = new Contact (lastName = 'test Contact', AccountId = accountA.Id);
        insert contactA;
        Contact contactB = new Contact (lastName = 'test Contact', AccountId = accountB.Id);
        insert contactB;
        obj.put(UtilityController.appNamespace() + 'Account__c', accountA.Id);
		obj.put(UtilityController.appNamespace() + 'Contact__c', contactB.Id);
		insert obj;
		
		List<Reference_Basic_Information__c> rbis = new List<Reference_Basic_Information__c>();
		rbis.add(new Reference_Basic_Information__c(Account__c = accountA.Id, Referenceability_Status__c = 'Active', Is_Referenceable__c = true));
		rbis.add(new Reference_Basic_Information__c(Account__c = accountA.Id, Contact__c = contactA.Id, Referenceability_Status__c = 'Active', Is_Referenceable__c = true));
		rbis.add(new Reference_Basic_Information__c(Account__c = accountB.Id, Contact__c = contactB.Id,  Referenceability_Status__c = 'Active', Is_Referenceable__c = true));
        insert rbis;
        
        List<Reward__c> issues = new List<Reward__c>();
        issues.add(new Reward__c(Available_Points__c = 50, Amount__c = 50, Contact__c = contactA.Id, Account__c = accountA.Id, Transaction__c = ConstantsController.ISSUE));
        issues.add(new Reward__c(Available_Points__c = 50, Amount__c = 50, Contact__c = contactB.Id, Account__c = accountA.Id, Transaction__c = ConstantsController.ISSUE));
        issues.add(new Reward__c(Available_Points__c = 40, Amount__c = 40, Contact__c = contactB.Id, Account__c = accountA.Id, Transaction__c = ConstantsController.ISSUE));
        issues.add(new Reward__c(Available_Points__c = 300, Amount__c = 300, Contact__c = contactB.Id, Account__c = accountA.Id, Transaction__c = ConstantsController.ISSUE));
        issues.add(new Reward__c(Available_Points__c = 150, Amount__c = 150, Contact__c = contactB.Id, Account__c = accountB.Id, Transaction__c = ConstantsController.ISSUE));
        insert issues;
        
        //Start test method
        test.startTest();
            PageReference pageRef = Page.RedeemRewardSLDS;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('accountId', accountB.id);
            pageRef.getParameters().put('ContactId', contactB.id);
            RedeemRewardControllerSLDS rrc = new RedeemRewardControllerSLDS();
            //fetch all required information
            RedeemRewardControllerSLDS.InfoWrapper info = RedeemRewardControllerSLDS.fetchInfo(rrc.accountId, rrc.contactId, rrc.userId);
            
            // set all data 
            info.amount = 200;
            info.comments = 'test reward';
            // save reward
            String result = RedeemRewardControllerSLDS.submit(JSON.serialize(info));
            
            List<Reward__c> reward = [SELECT Id, Amount__c FROM Reward__c WHERE Contact__c = :contactB.Id AND Transaction__c = :ConstantsController.REDEEM];
            system.assertEquals(1, reward.size());
            // set all data 
            info.amount = 200;
            info.comments = 'test reward';
            // save reward
            result = RedeemRewardControllerSLDS.submit(JSON.serialize(info));
        //Stop test method
        test.stopTest();
    }
    
    /**
     * Method to cover save method and error block with invalid amount
     * Modified By: Rekha Jangir @18 May 2017
     */
    static testMethod void testAllException() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account accountA = new Account( Name = 'test account');
        insert accountA;
        Contact contactB = new Contact (lastName = 'test Contact', AccountId = accountA.Id);
        insert contactB;
        List<Reference_Basic_Information__c> rbis = new List<Reference_Basic_Information__c>();
        rbis.add(new Reference_Basic_Information__c(Account__c = accountA.Id, Referenceability_Status__c = 'Active', Is_Referenceable__c = true));
		rbis.add(new Reference_Basic_Information__c(Account__c = accountA.Id, Contact__c = contactB.Id,  Referenceability_Status__c = 'Active', Is_Referenceable__c = true));
        insert rbis;
        List<Reward__c> issues = new List<Reward__c>();
        issues.add(new Reward__c(Available_Points__c = 150, Amount__c = 150, Account__c = accountA.Id, 
        							Transaction__c = ConstantsController.ISSUE));
        
        //Start test method
        test.startTest();
            PageReference pageRef = Page.RedeemRewardSLDS;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('accountId', accountA.id);
            RedeemRewardControllerSLDS rrc = new RedeemRewardControllerSLDS();
            //fetch all required information
            RedeemRewardControllerSLDS.InfoWrapper info = RedeemRewardControllerSLDS.fetchInfo(rrc.accountId, ':' + rrc.contactId, rrc.userId);
            
            // set all data 
            info.amount = 100;
            info.comments = 'test reward';
            // save reward
            String result = RedeemRewardControllerSLDS.submit(JSON.serialize(info) + 'test');
            result = RedeemRewardControllerSLDS.submit(JSON.serialize(info));
            result = RedeemRewardControllerSLDS.getPermissionsMessage(rrc.userId);
            system.assertEquals('', result);
        //Stop test method
        test.stopTest();
    }
}