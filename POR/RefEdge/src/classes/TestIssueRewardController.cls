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
 * Class: IssueRewardController
 * Description: class to test AND cover IssueRewardController
 * Modified by: Rekha Jangir @11 May 2017
 * Last Modified By: Rajesh @11 Nov 2017 for #1112
 */
@isTest(seeAllData = false)
public class TestIssueRewardController {
    
    /**
     * Method to cover save method with valid amount for Contact
     * Modified By: Rekha Jangir @11 May 2017
     */
    static testMethod void testIssueRewardsFromContact() {
    	//insert test Data
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
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        
        //Start Test method
        test.startTest();
            PageReference pageRef = Page.IssueReward;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('AccountId', accountB.Id);
            pageRef.getParameters().put('ContactId', contactB.Id);
            IssueRewardController irc = new IssueRewardController();
            // get all accounts associated with this contact
            irc.getAccountList();
            irc.selectedAccount = accountA.Id;
            // get status of that account
            irc.getAccountReferenceStatus();
            // get all referenceabilities
            irc.getReferenceabilityTypeList();
            irc.reward.Amount__c = 50;
            irc.reward.Referenceability_Type__c = refTypes[0].Id;
            //save reward
            PageReference pg = irc.save();
            system.assertEquals(pg.getUrl(), '/' + contactB.Id);
            
            List<Reward__c> reward = [SELECT Id, Amount__c FROM Reward__c WHERE Contact__c = :contactB.Id];
            system.assertEquals(50, reward[0].Amount__c);
            
            irc = new IssueRewardController();
            // get all accounts associated with this contact
            irc.getAccountList();
            irc.selectedAccount = accountA.Id;
            // get status of that account
            irc.getAccountReferenceStatus();
            // get all referenceabilities
            irc.getReferenceabilityTypeList();
            irc.reward.Referenceability_Type__c = refTypes[0].Id;
            irc.changeAmount();
            irc.reward.Amount__c = 50;
            
            //save reward
            pg = irc.save();
            system.assertEquals(pg.getUrl(), '/' + contactB.Id); 
        //Stop Test method
        test.stopTest();
    }
    
    /**
     * Method to cover save method with valid amount for Account
     * Modified By: Rekha Jangir @11 May 2017
     */
    static testMethod void testIssueRewardFromAccount() {
    	//insert test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account accountA = new Account( Name = 'test account');
        insert accountA;
        Contact contactA = new Contact (lastName = 'test Contact', AccountId = accountA.Id);
        insert contactA;
        Contact contactB = new Contact (lastName = 'test Contact', AccountId = accountA.Id);
        insert contactB;
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        //Start Test method
        test.startTest();
            PageReference pageRef = Page.IssueReward;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('AccountId', accountA.Id);
            IssueRewardController irc = new IssueRewardController();
            // get all contacts associated with this account
            irc.getContactList();
            irc.selectedContact = contactB.Id;
            // get status of selected contact
            irc.getContactReferenceStatus();
            // get all referenceabilities
            irc.getReferenceabilityTypeList();
            irc.reward.Amount__c = 100;
            irc.reward.Referenceability_Type__c = refTypes[0].Id;
            // save reward
            irc.reward.Contact__c = contactB.Id;
            PageReference pg = irc.save();
            system.assertEquals(pg.getUrl(), '/' + accountA.Id);
            
            List<Reward__c> reward = [SELECT Id, Amount__c FROM Reward__c WHERE Contact__c = :contactB.Id];
            system.assertEquals(100, reward[0].Amount__c);
            
            irc = new IssueRewardController();
            // get all contacts associated with this account
            irc.getContactList();
            irc.selectedContact = contactB.Id;
            // get status of selected contact
            irc.getContactReferenceStatus();
            // get all referenceabilities
            irc.getReferenceabilityTypeList();
            irc.reward.Amount__c = 10;
            irc.reward.Referenceability_Type__c = refTypes[0].Id;
            // save reward
            irc.reward.Contact__c = contactB.Id;
            pg = irc.save();
            system.assertEquals(pg.getUrl(), '/' + accountA.Id);
            
        //Stop Test method
        test.stopTest();
    }
    
    /**
     * Method to cover save method with valid amount for User
     * Modified By: Rekha Jangir @11 May 2017
     */
    static testMethod void testIssueRewardFromUser() {
    	//insert test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        User user = TestDataFactory.createUser();
        insert user;
        
        List<Referenceability_Type__c> refTypes = TestDataFactory.createUserRewardReferenceabilityType();
        insert refTypes;
        //Start Test method
        test.startTest();
            PageReference pageRef = Page.IssueReward;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('userId', user.Id);
            pageRef.getParameters().put('retUrl', user.Id);
            IssueRewardController irc = new IssueRewardController();
            // get all referenceabilities
            irc.getReferenceabilityTypeList();
            irc.reward.Amount__c = 100;
            irc.reward.Referenceability_Type__c = refTypes[5].Id;
            // save reward
            PageReference pg = irc.save();
            
            /*Remove cancel method for ticket #1112*/
            //irc.cancel(); 
            List<Reward__c> reward = [SELECT Id, Amount__c FROM Reward__c WHERE User__c = :user.Id];
            system.assertEquals(100, reward[0].Amount__c);
            
            /*Check value for null in case of Exception*/
            irc.userId = null; 
            System.assertEquals(null, irc.save());
             
        //Stop Test method
        test.stopTest();
    }
    
    /**
     * Method to cover save method and error block with invalid amount
     * Modified By: Rekha Jangir @11 May 2017
     */
    static testMethod void testAllException() {
    	//insert test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        //Start Test method
        test.startTest();
            PageReference pageRef = Page.IssueReward;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('AccountId', accounts[0].Id);
            IssueRewardController irc = new IssueRewardController();
            irc.getContactReferenceStatus();
            irc.getAccountReferenceStatus();
            irc.getReferenceabilityTypeList();
            irc.reward.Amount__c = 0;
            irc.reward.Referenceability_Type__c = refTypes[0].Id;
            // to get amount error
            irc.save();
            // to get referenceability type error
            irc.reward.Referenceability_Type__c = null;
            PageReference pg = irc.save();
            
            //to get exception
            database.delete(accounts[0].Id);           
            System.assertEquals(null, irc.save());
             
        //Stop Test method
        test.stopTest();
    }
}