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
 * Class: AccountAttributeDeleteMsgController
 * Description : class to test and cover AccountAttributeDeleteMsgController 
 * Modified by: Rekha Jangir @4 May 2017
 */
@isTest(SeeAllData=false)
private class TestAccountAttributeDeleteMsgController {	
	
	/*
     * Method to cover Constructor and deleteAtt methods from Classic page
     * Created : Rekha Jangir @04 May 2017
     */
    static testMethod void testClassicMethods() {
    	//insert test Data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        
        list<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
        insert refContents;
        List<Account_Reference_Content__c> accountContents = TestDataFactory.createAccountRefContents(new List<Account>{accounts[0]}, refContents);
        insert accountContents;
        
        TestDataFactory.createAccountAttributes(new List<Account>{accounts[0]}, childAttributes, true);
        
        List<Account_Attribute__c> accAtts = [SELECT Id FROM Account_Attribute__c WHERE Account__c = :accounts[0].Id AND Inheritable__c = true];
        //Start Test method
        Test.startTest();
        
        	ApexPages.StandardController controller = new ApexPages.StandardController(accAtts[0]);
        	AccountAttributeDeleteMsgController tempObj = new AccountAttributeDeleteMsgController(controller);
        	tempObj.deleteAtt();
        	PageReference pg = tempObj.cancel();
        	System.assertEquals(pg.getUrl(), '/' + accounts.get(0).Id);
        	
        	tempObj.deleteAtt();
        //End Test method
        Test.stopTest();
    }
    
    /*
     * Method to cover Constructor and deleteAtts methods from SLDS page
     * Created : Rekha Jangir @04 May 2017
     */
    static testMethod void testSLDSMethods() {
    	//insert test Data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();

        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        
        list<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
        insert refContents;
        List<Account_Reference_Content__c> accountContents = TestDataFactory.createAccountRefContents(new List<Account>{accounts[0]}, refContents);
        insert accountContents;
        
        TestDataFactory.createAccountAttributes(new List<Account>{accounts[0]}, childAttributes, true);
        
        List<Account_Attribute__c> accAtts = [SELECT Id FROM Account_Attribute__c WHERE Account__c = :accounts[0].Id AND Inheritable__c = true];
        //Start Test method
        Test.startTest();
        
        	ApexPages.StandardController controller = new ApexPages.StandardController(accAtts[0]);
        	AccountAttributeDeleteMsgController tempObj = new AccountAttributeDeleteMsgController(controller);
        	String result = AccountAttributeDeleteMsgController.deleteAtts(accAtts[0].Id);
        	System.assertEquals('', result);
        //End Test method
        Test.stopTest();
    }
    
    /*
     * Method to cover Constructor and deleteAtts methods from SLDS page
     * Created : Rekha Jangir @04 May 2017
     */
    static testMethod void testSLDSExceptionMethods() {
    	//insert test Data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	TestDataFactory.createAttributeMapping();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;

        List<Attribute__c> childAttributeslevel2 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
        insert childAttributeslevel2;
        TestDataFactory.createAccountAttributes(new List<Account>{accounts[0]}, childAttributeslevel2, true);
        
        List<Account_Attribute__c> accAtts = [SELECT Id FROM Account_Attribute__c WHERE Account__c = :accounts[0].Id 
        									AND Inheritable__c = true AND Attribute__c IN :childAttributes];
        //Start Test method
        Test.startTest();
        
        	ApexPages.StandardController controller = new ApexPages.StandardController(accAtts[0]);
        	AccountAttributeDeleteMsgController tempObj = new AccountAttributeDeleteMsgController(controller);
        	String result = AccountAttributeDeleteMsgController.deleteAtts(accAtts[0].Id);
        	System.assertNotEquals('', result);
        //End Test method
        Test.stopTest();
    }
}