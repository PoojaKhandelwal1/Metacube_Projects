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
 * Class: AddNewRelatedConRefContentControllerSLDS
 * Description: class to Test AND cover AddNewRelatedConRefContentControllerSLDS
 * Modified by: Rekha Jangir @25 May 2017
 */
@isTest(seeAllData = false)
public with sharing class TestAddNewRelatedConRefContentsSLDS {
    
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
        
        //Start Test Method
        Test.startTest();
            referObjects = [SELECT Name FROM Reference_Content__c WHERE Id IN :referObjects];
            PageReference pageRef = Page.AddNewRelatedConRefContents;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('conId', contacts[0].Id);
            pageRef.getParameters().put('retURL', contacts[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(new Contact_Reference_Content__c());
            AddNewRelatedConRefContentControllerSLDS testObject = new AddNewRelatedConRefContentControllerSLDS(controller);
            
            //fetch all required information
            AddNewRelatedConRefContentControllerSLDS.InfoWrapper info = AddNewRelatedConRefContentControllerSLDS.fetchInfo(testObject.contactId, testObject.returnUrl);
            
            // set all data 
            info.refConId = referObjects[0].Id;
            // save
            String result = AddNewRelatedConRefContentControllerSLDS.submit(JSON.serialize(info));
            List<Contact_Reference_Content__c> accReferObjects = [SELECT Id FROM Contact_Reference_Content__c WHERE Contact__c = :contacts[0].Id];
            system.assertEquals(1, accReferObjects.size());
            
            //for exception
            result = AddNewRelatedConRefContentControllerSLDS.submit(JSON.serialize(info));
        //Stop Test method
        Test.stopTest();
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
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
        insert referObjects;
        
        //Start Test Method
        Test.startTest();
            Contact_Reference_Content__c accReferObject = new Contact_Reference_Content__c(Reference_Content__c = referObjects[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(accReferObject);
            AddNewRelatedConRefContentControllerSLDS testObject = new AddNewRelatedConRefContentControllerSLDS(controller);
            
            //fetch all required information
            AddNewRelatedConRefContentControllerSLDS.InfoWrapper info = AddNewRelatedConRefContentControllerSLDS.fetchInfo(testObject.contactId, testObject.returnUrl);
            
            // set all data 
            info.contactId = contacts[0].Id;
            // save
            String result = AddNewRelatedConRefContentControllerSLDS.submit(JSON.serialize(info));
            List<Contact_Reference_Content__c> accReferObjects = [SELECT Id FROM Contact_Reference_Content__c WHERE Reference_Content__c = :referObjects[0].Id];
            system.assertEquals(1, accReferObjects.size());
        //Stop Test method
        Test.stopTest();
    }
}