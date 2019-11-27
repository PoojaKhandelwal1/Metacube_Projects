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
public with sharing class TestSalesUserProfileExtension {
	
    //Test method
    static testMethod void salesReward_T01() {
        User usr = TestDataFactory.createUser();
        User_Profile__c userProile = new User_Profile__c(Available_Points__c = 100, Lifetime_Points__c = 1200, User__c = usr.Id);
        insert userProile;
        ApexPages.StandardController sc = new ApexPages.standardController(usr);
        
        // Start test Method
        Test.startTest();
        	SalesUserProfileExtension testObject = new SalesUserProfileExtension(sc);
        	POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        	system.assertEquals(0, testObject.rewardList.size());
        // Stop test method
        Test.stopTest();
    }
    
    // Test method
    static testMethod void salesReward_T02() {
        User usr = TestDataFactory.createUser();
        User_Profile__c userProile = new User_Profile__c(Available_Points__c = 100, Lifetime_Points__c = 1200, User__c = usr.Id);
        insert userProile;
        ApexPages.StandardController sc = new ApexPages.standardController(usr);
        
        // Start test Method
        Test.startTest();
	        SalesUserProfileExtension testObject = new SalesUserProfileExtension(sc);
	        PageReference pgRef = testObject.redirectToIssue();
	        system.assert((pgRef.getUrl()).equalsIgnoreCase(Page.IssueReward.getUrl() + '?retUrl=' + testObject.userProfile.Id + '&userId=' + usr.Id));
        // Stop test method
        Test.stopTest();
    }
    
    // Test method
    static testMethod void salesReward_T03() {
        User usr = TestDataFactory.createUser();
        User_Profile__c userProile = new User_Profile__c(Available_Points__c = 100, Lifetime_Points__c = 1200, User__c = usr.Id);
        insert userProile;
        ApexPages.StandardController sc = new ApexPages.standardController(usr);
        
        // Start test method
        Test.startTest();
	        SalesUserProfileExtension testObject = new SalesUserProfileExtension(sc);
	        PageReference pgRef = testObject.redirectToRedeem();
	        system.assert((pgRef.getUrl()).equalsIgnoreCase(Page.RedeemReward.getUrl() + '?retUrl=' + testObject.userProfile.Id + '&userId=' + usr.Id));
	    // Stop test method
        Test.stopTest();
    }
}