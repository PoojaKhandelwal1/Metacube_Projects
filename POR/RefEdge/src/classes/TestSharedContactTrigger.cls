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
public with sharing class TestSharedContactTrigger {
    
    static testMethod void testAfterInsert() {
    	//try {
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
			List<Account> accounts = TestDataFactory.createAccounts();
			insert accounts;
			List<Contact> contacts = TestDataFactory.createContacts(accounts);
			insert contacts;
			TestDataFactory.setUpAccountRBI(accounts);
			TestDataFactory.setUpContactRBI(contacts);
			List<Attribute__c> attributes = new List<Attribute__c>{TestDataFactory.createAttribute()[0]};
			insert attributes;
			List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 6);
			insert childAttributes;
			List<Label__c> labels = new List<Label__c>{TestDataFactory.createLabels()[0]};
			insert labels;
			TestDataFactory.createAttributeLabels(labels, childAttributes);
			TestDataFactory.createAccountAttributes(new List<Account>{accounts[0]}, childAttributes, true);
			//TestDataFactory.createContactAttributes(new List<Contact>{contacts[0]}, childAttributes);
			
			
			Test.startTest();
				
				obj.put(UtilityController.appNamespace() + 'Account__c', accounts[0].Id);
				obj.put(UtilityController.appNamespace() + 'Contact__c', contacts[1].Id);
				List<sObject> objectList = new List<sObject>();
				objectList.add(obj);
				insert obj;
				SharedContactTriggerHandler.onAfterInsert(objectList);
				String query = 'SELECT Id FROM ' + UtilityController.appNamespace() + 'Hit_List__c';
				List<sObject> objectList1 = Database.query(query);
				system.debug(objectList1);
				system.assertEquals(objectList1.size(), 1);
			Test.stopTest();
    	
    }
    
    static testMethod void testAfterDelete() {
    	//try {
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
			List<Account> accounts = TestDataFactory.createAccounts();
			insert accounts;
			List<Contact> contacts = TestDataFactory.createContacts(accounts);
			insert contacts;
			TestDataFactory.setUpAccountRBI(accounts);
			TestDataFactory.setUpContactRBI(contacts);
			List<Attribute__c> attributes = new List<Attribute__c>{TestDataFactory.createAttribute()[0]};
			insert attributes;
			List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 6);
			insert childAttributes;
			List<Label__c> labels = new List<Label__c>{TestDataFactory.createLabels()[0]};
			insert labels;
			TestDataFactory.createAttributeLabels(labels, childAttributes);
			TestDataFactory.createAccountAttributes(new List<Account>{accounts[0]}, childAttributes, true);
			//TestDataFactory.createContactAttributes(new List<Contact>{contacts[0]}, childAttributes);
			
			Test.startTest();
				obj.put(UtilityController.appNamespace() + 'Account__c', accounts[0].Id);
				obj.put(UtilityController.appNamespace() + 'Contact__c', contacts[1].Id);
				List<sObject> objectList = new List<sObject>();
				objectList.add(obj);
				insert obj;
				SharedContactTriggerHandler.onAfterDelete(objectList);
				delete obj;
				String query = 'SELECT Id FROM ' + UtilityController.appNamespace() + 'Hit_List__c';
				List<sObject> objectList1 = Database.query(query);
				system.assertEquals(objectList1.size(), 0);
			Test.stopTest();
    	
    }
}