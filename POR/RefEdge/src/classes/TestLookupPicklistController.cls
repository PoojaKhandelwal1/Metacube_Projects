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
* Class: LookupPicklistController
* Description: class to test and cover LookupPicklistController 
* Modified by: Gaurav Saini (21 June, 2017) for #886
*/
@isTest(seeAllData = false)
public with sharing class TestLookupPicklistController {
    
    /*
     * Method to cover fetchData method
     * Created : Rekha Jangir @19 April 2017
     */
    public static testMethod void testFetchData() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//create root attribute
    	Attribute__c root = new Attribute__c(Name = 'Color');
    	insert root;
    	
        //Start test method
        Test.startTest();
            LookupPicklistController testObject = new LookupPicklistController(new ApexPages.standardController(new Attribute__c()));
            
            //get all related record with name color 
            List<LookupPicklistController.RecordWrapper> result = LookupPicklistController.fetchData('Color', 'Attribute__c');
            system.assertEquals(1, result.size());
            
            //get all related record with blank value
            result = LookupPicklistController.fetchData('', 'Attribute__c');
            system.assertEquals(1, result.size());
            
            testObject = new LookupPicklistController();
            //get all related record with name Fruit 
            result = LookupPicklistController.fetchData('Fruit', 'Attribute__c');
            system.assertEquals(0, result.size());
        	
        //Stop Test method
        Test.stopTest();
    }
    
    /*
     * Method to cover fetchData method for Active Accounts
     * Created : Rekha Jangir @19 April 2017
     */
    public static testMethod void testFetchDataActiveAccounts() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//create accounts
    	List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        TestDataFactory.setUpAccountRBI(accounts);
    	
        //Start test method
        Test.startTest();
            LookupPicklistController testObject = new LookupPicklistController(new ApexPages.standardController(new Attribute__c()));
            
            //get all related record with name UCO Bank 
            List<LookupPicklistController.RecordWrapper> result = LookupPicklistController.fetchData('UCO Bank', 'ActiveAccounts');
            system.assertEquals(1, result.size());
            
            //get all related record with blank value
            result = LookupPicklistController.fetchData('', 'ActiveAccounts');
            system.assertEquals(6, result.size());
            
            testObject = new LookupPicklistController();
            //get all related record with name Fruit 
            result = LookupPicklistController.fetchData('Fruit', 'ActiveAccounts');
            system.assertEquals(0, result.size());
        	
        //Stop Test method
        Test.stopTest();
    }
    
    /*
     * Method to cover fetchData method for Active Contacts
     * Created : Rekha Jangir @19 April 2017
     */
    public static testMethod void testFetchDataActiveContacts() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//create accounts
    	List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        //create contacts
    	List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
    	
        //Start test method
        Test.startTest();
            LookupPicklistController testObject = new LookupPicklistController(new ApexPages.standardController(new Attribute__c()));
            
            //get all related record with name Brad Carroll 
            List<LookupPicklistController.RecordWrapper> result = LookupPicklistController.fetchData('Brad Carroll', 'ActiveContacts');
            system.assertEquals(1, result.size());
            
            //get all related record with blank value
            result = LookupPicklistController.fetchData('', 'ActiveContacts');
            system.assertEquals(6, result.size());
            
            testObject = new LookupPicklistController();
            //get all related record with name Fruit 
            result = LookupPicklistController.fetchData('Fruit', 'ActiveContacts');
            system.assertEquals(0, result.size());
        	
        //Stop Test method
        Test.stopTest();
    }
    
    
    /*
     * Method to cover fetchData method for reference content
     * Created : Rekha Jangir @3 June 2017
     */
    public static testMethod void testFetchDataReferenceContent() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//create reference content
    	List<Reference_Content__c> referObjects = TestDataFactory.createMultipleReferenceContent();
        insert referObjects;
        
        //Start test method
        Test.startTest();
            LookupPicklistController testObject = new LookupPicklistController(new ApexPages.standardController(new Reference_Content__c()));
            
            //get all related record with name Ref Content 
            List<LookupPicklistController.RecordWrapper> result = LookupPicklistController.fetchData('Ref Content', 'Reference_Content__c');
            system.assertEquals(2, result.size());
            
            //get all related record with blank value
            result = LookupPicklistController.fetchData('', 'Reference_Content__c');
            system.assertEquals(2, result.size());
            
            testObject = new LookupPicklistController();
            //get all related record with name test data 
            result = LookupPicklistController.fetchData('test New One', 'Reference_Content__c');
            system.assertEquals(0, result.size());
        	
        //Stop Test method
        Test.stopTest();
    }
    
    /*
     * Method to cover fetchData method for active non-community users
     * Created: Gaurav Saini (21 June, 2017) for #886
     */
    public static testMethod void testFetchDataActiveUsers() {
    	User testUser = TestDataFactory.createUser();
    	testUser.IsActive = true;
    	insert testUser;
    	
        // Start test method
        Test.startTest();
            // testing for blank search text
            List<LookupPicklistController.RecordWrapper> result = LookupPicklistController.fetchData('', 'Active_Non_Community_Users');
            system.assert(result.size() > 0);
            
            // testing for some search text
            List<LookupPicklistController.RecordWrapper> result1 = LookupPicklistController.fetchData('Testing', 'Active_Non_Community_Users');
            system.assert(result.size() > 0);
        // Stop Test method
        Test.stopTest();
    }
}