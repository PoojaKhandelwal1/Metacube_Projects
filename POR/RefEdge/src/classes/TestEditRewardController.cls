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
 * Class: EditRewardController
 * Description: class to test AND cover EditRewardController
 * Modified by: Rekha Jangir @1 June 2017
 */
@isTest(seeAllData = false)
public with sharing class TestEditRewardController {
	/**
     * Method to cover save method and Constructor from Account
     * Modified By: Rekha Jangir @1 June 2017
     */
    static testMethod void testIssueEditAccount() {
    	//insert test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account account = TestDataFactory.createAccounts()[0];
        insert account;
        insert new Reference_Basic_Information__c(Account__c = account.Id, Is_Referenceable__c = true, Referenceability_Status__c= 'Active');
        Referenceability_Type__c refType = TestDataFactory.createReferenceabilityType()[0];
        insert refType;
        Reward__c reward = new Reward__c(Account__c = account.Id, Referenceability_Type__c = refType.Id, Amount__c = 100, 
        								Available_Points__c = 100, Transaction__c = ConstantsController.ISSUE, Expiration_Date__c = system.today().addDays(5), 
        								RewardDate__c = Date.Today());
        insert reward;
        
        //Start Test method
        test.startTest();
            PageReference pageRef = Page.EditReward;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(reward);
            EditRewardController erc = new EditRewardController(sc);
            erc.reward.Expired__c = true;
            PageReference pg = erc.save();
            List<Reward__c> rewards = [SELECT Id, Expired__c FROM Reward__c WHERE Id = :reward.Id];
            system.assertEquals(true, rewards[0].Expired__c);
        //Stop Test method
        test.stopTest();
    }
    
    /**
     * Method to cover save method and Constructor from Contact
     * Modified By: Rekha Jangir @1 June 2017
     */
    static testMethod void testIssueEditAccountContact() {
    	//insert test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        Referenceability_Type__c refType = TestDataFactory.createReferenceabilityType()[0];
        insert refType;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        Reward__c reward = new Reward__c(Available_Points__c = 500, Amount__c = 500, Contact__c = contacts[0].Id, Account__c = accounts[0].Id, 
        									Transaction__c = ConstantsController.ISSUE);
        insert reward;
        //Start Test method
        test.startTest();
            PageReference pageRef = Page.EditReward;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(reward);
            EditRewardController erc = new EditRewardController(sc);
            erc.reward.Expired__c = true;
            PageReference pg = erc.save();
            List<Reward__c> rewards = [SELECT Id, Expired__c FROM Reward__c WHERE Id = :reward.Id];
            system.assertEquals(true, rewards[0].Expired__c);
            erc.reward.Expired__c = false;
            erc.reward.Amount__c = 200;
            erc.save();
            erc.cancel();
            system.assertNotEquals(erc.todayDate,'');
        //Stop Test method
        test.stopTest();
    }
    
    /**
     * Method to cover save method and Constructor from User
     * Modified By: Rekha Jangir @1 June 2017
     */
    static testMethod void testIssueEditUser() {
    	// insert test data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        User_Profile__c userProile=new User_Profile__c(Available_Points__c = 0, Lifetime_Points__c = 0, User__c = UserInfo.getUserId());
    	insert userProile;
        Reward__c reward = new Reward__c(Available_Points__c = 250, Amount__c = 250, User__c = UserInfo.getUserId(), Transaction__c = ConstantsController.ISSUE);
        insert reward;
        //Start test method
        test.startTest();
            PageReference pageRef = Page.EditReward;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(reward);
            EditRewardController erc = new EditRewardController(sc);
            erc.reward.Expired__c = true;
            PageReference pg = erc.save();
            List<Reward__c> rewards = [SELECT Id, Expired__c FROM Reward__c WHERE Id = :reward.Id];
            system.assertEquals(true, rewards[0].Expired__c);
        //Stop test method
        test.stopTest();
    }
    
    /**
     * Method to cover cancel method
     * Modified By: Rekha Jangir @1 June 2017
     */
    static testMethod void testIssueEditWithURLs() {
    	//insert test data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account account = TestDataFactory.createAccounts()[0];
        insert account;
        insert new Reference_Basic_Information__c(Account__c = account.Id, Is_Referenceable__c = true, Referenceability_Status__c= 'Active');
        Referenceability_Type__c refType = TestDataFactory.createReferenceabilityType()[0];
        insert refType;
        Reward__c reward = new Reward__c(Account__c = account.Id, Referenceability_Type__c = refType.Id, Amount__c = 100, 
        								Available_Points__c = 100, Transaction__c = ConstantsController.ISSUE, 
        								Expiration_Date__c = system.today().addDays(5), RewardDate__c = Date.Today());
        insert reward;
        //Start Test method
        test.startTest();
	        PageReference pageRef = Page.EditReward;
	        Test.setCurrentPage(pageRef);
	        
	        pageRef.getParameters().put('retURL', null);
	        ApexPages.StandardController sc = new ApexPages.standardController(reward); 
	        EditRewardController erc = new EditRewardController(sc);
	        PageReference pg;  
		    pg = erc.cancel();
		    system.assertEquals(pg.getUrl(), '/' + reward.Id);
	      
	        
	        pageRef.getParameters().put('retURL', reward.Id);
	        sc = new ApexPages.standardController(reward); 
	        erc = new EditRewardController(sc); 
	        pg = erc.cancel();
		    system.assertEquals(pg.getUrl(), '/' + reward.Id);
	        
	        pageRef.getParameters().put('retURL', System.URL.getSalesforceBaseURL().toExternalForm());
	        sc = new ApexPages.standardController(reward); 
	        erc = new EditRewardController(sc); 
		    pg = erc.cancel();
		    system.assertEquals(pg.getUrl(), System.URL.getSalesforceBaseURL().toExternalForm());
	        
	        pageRef.getParameters().put('retURL', '/' + 'www.xyz.com');
	        sc = new ApexPages.standardController(reward); 
	        erc = new EditRewardController(sc); 
		    pg = erc.cancel();
		    system.assertNotEquals(pg.getUrl(), 'www.xyz.com');
		    
		    pageRef.getParameters().put('retURL', '/' + 'www.xyz.com');
	        sc = new ApexPages.standardController(reward); 
	        erc = new EditRewardController(sc); 
		    pg = erc.cancel();
		    system.assertEquals(pg.getUrl(), '//www.xyz.com');
		    
		    pageRef.getParameters().put('retURL', null);
	        sc = new ApexPages.standardController(new Reward__c()); 
	        erc = new EditRewardController(sc); 
		    pg = erc.cancel();
		    system.assertEquals(System.URL.getSalesforceBaseURL().toExternalForm(), pg.getUrl());
		    
        //Stop Test method
        test.stopTest(); 
    }
}