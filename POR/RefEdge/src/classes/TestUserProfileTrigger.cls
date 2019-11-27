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
public with sharing class TestUserProfileTrigger {
	static testMethod void unitTest01(){
		test.startTest();
        	User u = TestDataFactory.CreateUser();
        	User_Profile__c userProile=new User_Profile__c(Available_Points__c=0,Lifetime_Points__c=0,User__c=u.Id);
        	insert userProile;
        	Reward__c issue = new Reward__c(Amount__c = 100, Transaction__c = ConstantsController.ISSUE, RewardDate__c = Date.Today(), User__c = u.Id);
        	insert issue;
        	Reward__c reward = new Reward__c(Amount__c = 90, Transaction__c = ConstantsController.REDEEM, RewardDate__c = Date.Today(), User__c = u.Id);
        	insert reward;
        	delete userProile;
        	list<User_Profile__c> userList = [select Id from User_Profile__c where Id = :userProile.Id];
        	system.assertEquals(0,userList.size());
        test.stopTest();
	}
}