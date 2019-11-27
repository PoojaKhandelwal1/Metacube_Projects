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
 * Class: AddNewRelatedRefContentsController
 * Description: class to Test AND cover AddNewRelatedRefContentsController
 * Modified by: Rekha Jangir @24 May 2017
 */
@isTest(seeAllData = false)
public with sharing class TestAddNewRelatedRefContentsController {
    
    /**
     * Method to cover save method from Account
     * Modified By: Rekha Jangir @24 May 2017
     */
    static testMethod void testFromAccount() {
    	//insert Test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        TestDataFactory.setUpAccountRBI(accounts);
        List<Reference_Content__c> referObjects = TestDataFactory.createMultipleReferenceContent();
        insert referObjects;
        
        //Start Test Method
        Test.startTest();
            referObjects = [SELECT Name FROM Reference_Content__c WHERE Id IN :referObjects];
            PageReference pageRef = Page.AddNewRelatedRefContents;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('acctId', accounts[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(new Account_Reference_Content__c());
            AddNewRelatedRefContentsController testObject = new AddNewRelatedRefContentsController(controller);
            testObject.isNameChanged = true;
            testObject.refConName = 'RC-0000';
            PageReference pg = testObject.save();
            testObject.refConName = referObjects[0].Name;
            pg = testObject.save();
            system.assertEquals(pg.getUrl(), '/' + accounts[0].Id);
        //Stop Test method
        Test.stopTest();
    }
    
	/**
     * Method to cover save method from Account
     * Modified By: Rekha Jangir @24 May 2017
     */
    static testMethod void testFromAccountNext() {
    	//insert Test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        TestDataFactory.setUpAccountRBI(accounts);
        List<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
        insert referObjects;
        
        //Start Test Method
        Test.startTest();
            referObjects = [SELECT Name FROM Reference_Content__c WHERE Id IN :referObjects];
            PageReference pageRef = Page.AddNewRelatedRefContents;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('acctId', accounts[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(new Account_Reference_Content__c());
            AddNewRelatedRefContentsController testObject = new AddNewRelatedRefContentsController(controller);
            testObject.isNameChanged = true;
            testObject.refConName = 'test';
            PageReference pg = testObject.save();
            testObject.refConName = '';
            pg = testObject.save();
            testObject.refConName = 'RC-00';
            pg = testObject.save();
            system.assertEquals(pg.getUrl(), '/' + accounts[0].Id);
        //Stop Test method
        Test.stopTest();
    }
    
    /**
     * Method to cover save method from Reference Content
     * Modified By: Rekha Jangir @24 May 2017
     */
    static testMethod void testFromReferenceContent() {
    	//insert Test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        accounts[1].Name = 'UCO Bank';
        insert accounts;
        
        TestDataFactory.setUpAccountRBI(accounts);
        List<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
        insert referObjects;
        
        //Start Test Method
        Test.startTest();
            Account_Reference_Content__c accReferObject = new Account_Reference_Content__c(Reference_Content__c = referObjects[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(accReferObject);
            AddNewRelatedRefContentsController testObject = new AddNewRelatedRefContentsController(controller);
            testObject.isNameChanged = true;
            testObject.accName = accounts[0].Name;
            PageReference pg = testObject.save();
            testObject.accName = accounts[2].Name;
            pg = testObject.save();
            accReferObject = [SELECT Id FROM Account_Reference_Content__c WHERE Account__c = :accounts[2].Id];
            system.assertNotEquals(null, accReferObject.Id);
        //Stop Test method
        Test.stopTest();
    }
    
    /**
     * Method to cover save method from Reference Content
     * Modified By: Rekha Jangir @24 May 2017
     */
    static testMethod void testFromReferenceContentNext() {
        //insert Test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        accounts[1].Name = 'UCO Bank New';
        insert accounts;
        
        TestDataFactory.setUpAccountRBI(accounts);
        List<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
        insert referObjects;
        
        //Start Test Method
        Test.startTest();
            Account_Reference_Content__c accReferObject = new Account_Reference_Content__c(Reference_Content__c = referObjects[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(accReferObject);
            AddNewRelatedRefContentsController testObject = new AddNewRelatedRefContentsController(controller);
            testObject.isNameChanged = true;
            testObject.accName = '';
            PageReference pg = testObject.save();
            testObject.accName = 'UCO Branch';
            pg = testObject.save();
            testObject.accName = 'UCO';
            pg = testObject.save();
            testObject.accName = 'UCO Bank N';
            pg = testObject.save();
            accReferObject = [SELECT Id FROM Account_Reference_Content__c WHERE Account__c = :accounts[1].Id];
            system.assertNotEquals(null, accReferObject.Id);
            
            testObject.returnUrl = null;
            testObject.cancel();
        //Stop Test method
        Test.stopTest();
    }
}