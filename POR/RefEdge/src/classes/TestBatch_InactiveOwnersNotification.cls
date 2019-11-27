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
* Class: Batch_InactiveOwnersNotification
* Description : class to test and cover Batch_InactiveOwnersNotification 
* Modified by: Rekha Jangir @Jan/5/2016
*/
@isTest(seeAllData = false)
public with sharing class TestBatch_InactiveOwnersNotification {
	
    static testMethod void myUnitTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        User user = TestDataFactory.createUser();
        insert user;
        //to assign this user as account owner 
        system.runAs(user) {
	        List<Account> accounts = TestDataFactory.createAccounts();
	        insert accounts;
	        List<Reference_Basic_Information__c> rbis = TestDataFactory.setUpAccountRBI(accounts);
	        rbis[0].Reference_Owner__c = user.Id;
	        update rbis;
        }
    	test.startTest();
    		Batch_InactiveOwnersNotification testBatch = new Batch_InactiveOwnersNotification();
    		ID batchprocessid = database.executebatch(testBatch);
    	test.stopTest();
    	system.assert(true);
    }
}