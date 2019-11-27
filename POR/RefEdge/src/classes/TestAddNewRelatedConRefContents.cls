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
 * Class: AddNewRelatedConRefContentsController
 * Description: class to Test AND cover AddNewRelatedConRefContentsController
 * Modified by: Rekha Jangir @25 May 2017
 */
@isTest(seeAllData = false)
public with sharing class TestAddNewRelatedConRefContents {
    
    /**
     * Method to cover save method from Contact
     * Modified By: Rekha Jangir @25 May 2017
     */
    static testMethod void testFromContact() {
    	//insert Test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List<Reference_Content__c> referObjects = TestDataFactory.createMultipleReferenceContent();
        insert referObjects;
        
        //Start test Method
        test.startTest();
        	referObjects = [SELECT Name FROM Reference_Content__c WHERE Id IN : referObjects];
            PageReference pageRef = Page.AddNewRelatedConRefContents;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('conId', contacts[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(new Contact_Reference_Content__c());
            AddNewRelatedConRefContentsController testObject = new AddNewRelatedConRefContentsController(controller);
            testObject.isNameChanged = true;
            testObject.refConName = 'RC-0000';
            PageReference pg = testObject.save();
            testObject.refConName = referObjects[0].Name;
	        pg = testObject.save();
	        system.assertEquals(pg.getUrl(), '/' + contacts[0].Id);
        //Stop test method
        test.stopTest();
    }
    
    /**
     * Method to cover save method from Contact
     * Modified By: Rekha Jangir @25 May 2017
     */
    static testMethod void testFromContactNext() {
    	//insert Test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
    	List<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
    	insert referObjects;
        //Start test Method
        test.startTest();
        	referObjects = [SELECT Name FROM Reference_Content__c WHERE Id IN : referObjects];
	        PageReference pageRef = Page.AddNewRelatedConRefContents;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('conId', contacts[0].Id);
            pageRef.getParameters().put('retURL', contacts[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(new Contact_Reference_Content__c());
            AddNewRelatedConRefContentsController testObject = new AddNewRelatedConRefContentsController(controller);
            testObject.isNameChanged = true;
            testObject.refConName = 'test';
            PageReference pg = testObject.save();
            testObject.refConName = '';
            pg = testObject.save();
            testObject.refConName = 'RC-00';
	        pg = testObject.save();
	        system.assertEquals(pg.getUrl(), '/' + contacts[0].Id);
	        
	        testObject.recordId = null;
            testObject.cancel();
        //Stop test method
        test.stopTest();
    }
    
    /**
     * Method to cover save method from Reference Content
     * Modified By: Rekha Jangir @25 May 2017
     */
    static testMethod void testFromReferenceContent() {
    	//insert Test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Contact> contacts = TestDataFactory.createContacts(accounts);
    	contacts[1].FirstName = 'Alon';
    	contacts[1].LastName = 'Raz';
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
    	List<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
    	insert referObjects;
    	//Start test Method
        test.startTest();
	        Contact_Reference_Content__c conReferObject = new Contact_Reference_Content__c(Reference_Content__c = referObjects[0].Id);
	        ApexPages.StandardController controller = new ApexPages.StandardController(conReferObject);
            AddNewRelatedConRefContentsController testObject = new AddNewRelatedConRefContentsController(controller);
            testObject.isNameChanged = true;
	        testObject.conName = 'Alon Raz';
	        PageReference pg = testObject.save();
	        testObject.conName = 'Brad Carroll';
	        pg = testObject.save();
	        conReferObject = [SELECT Id FROM Contact_Reference_Content__c WHERE Contact__c = :contacts[2].Id];
	        system.assertNotEquals(null, conReferObject.Id);
        //Stop test method
        test.stopTest();
    }
    
    /**
     * Method to cover save method from Reference Content
     * Modified By: Rekha Jangir @25 May 2017
     */
    static testMethod void testFromReferenceContentNext() {
    	//insert Test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Contact> contacts = TestDataFactory.createContacts(accounts);
    	contacts[1].FirstName = 'Alon';
    	contacts[1].LastName = 'Raz Smith';
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
    	List<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
    	insert referObjects;
    	//Start test Method
        test.startTest();
	        Contact_Reference_Content__c conReferObject = new Contact_Reference_Content__c(Reference_Content__c = referObjects[0].Id);
	        ApexPages.StandardController controller = new ApexPages.StandardController(conReferObject);
            AddNewRelatedConRefContentsController testObject = new AddNewRelatedConRefContentsController(controller);
            testObject.isNameChanged = true;
            testObject.conName = '';
	        PageReference pg = testObject.save();
	        testObject.conName = 'Alon Smith';
	        pg = testObject.save();
	        testObject.conName = 'Alon';
	        pg = testObject.save();
	        testObject.conName = 'Alon Raz S';
	        pg = testObject.save();
	        conReferObject = [SELECT Id FROM Contact_Reference_Content__c WHERE Contact__c = :contacts[1].Id];
	        system.assertNotEquals(null, conReferObject.Id);
        //Stop test method
        test.stopTest();
    }
}