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
 * Class: AccountAttributeEditController
 * Description: class to test AND cover AccountAttributeEditController 
 * Modified by: Rekha Jangir @5 May 2017
 */
@isTest(SeeAllData=false)
public with sharing class TestAccountAttributeEditController {
	/*
     * Method to cover Constructor AND removeAttri methods
     * Modified By: Rekha Jangir @05 May 2017
     */
    static testMethod void removeAttribTest() {
    	//insert test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        insert new Attribute_Mapping__c(Object__c ='Opportunity', Filter_Label_Name__c = 'Stage', Field__c = 'StageName', 
        					Field_Api_Name__c = 'StageName', Attribute_Name__c = 'Stage', Is_Related_Mapping__c = false);
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        
        List<Attribute__c> attributes = new List<Attribute__c> {TestDataFactory.createAttribute()[0]};
        attributes[0].Inheritable__c = true;
        attributes[0].Level__c = 0;
        insert attributes;
        
        List<Attribute__c> childAttributesLevel1 = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributesLevel1;
        List<Attribute__c> childAttributesLevel2 = TestDataFactory.createChildAttributes(childAttributesLevel1, 2, 1);
        insert childAttributesLevel2;
        List<Attribute__c> childAttributesLevel3 = TestDataFactory.createChildAttributes(childAttributesLevel2, 3, 1);
        insert childAttributesLevel3;
        list<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
        insert refContents;
        List<Account_Reference_Content__c> accountContents = TestDataFactory.createAccountRefContents(new List<Account> {accounts[0]}, refContents);
        insert accountContents;
        TestDataFactory.createAccountAttributes(new List<Account> {accounts[0]}, childAttributesLevel3, true);
        List<Account_Attribute__c> accAtts = [SELECT Id, Account__c FROM Account_Attribute__c 
        									WHERE Account__c IN :accounts AND Attribute__c IN :childAttributesLevel2];
        
        //Start Test method
        Test.startTest();
	        ApexPages.StandardController controller = new ApexPages.StandardController(accAtts[0]);
	        AccountAttributeEditController tempObj = new AccountAttributeEditController(controller);
	        tempObj.removeAttributes();
	        tempObj.save();
	        PageReference pg = tempObj.cancel();
	    	system.assertEquals(pg.getUrl(), '/' + accAtts.get(0).Account__c);
	    	accAtts = [SELECT Id, Account__c FROM Account_Attribute__c WHERE Account__c IN :accounts AND Attribute__c IN :childAttributesLevel3];
	    	Database.delete(accAtts);
	    	Database.delete(tempObj.attAcc);
	    	tempObj.removeAttributes();
        //End Test method
        Test.stopTest();
    }
    
    /*
     * Method to cover Constructor AND removeAttri methods when shared contact is enabled
     * Created By: Rekha Jangir @05 May 2017
     */
    static testMethod void removeAttribSharedContactTest() {
    	//insert test Data
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
		
		
        Account accountA = new Account( Name = 'test account');
        insert accountA;
        Account accountB = new Account( Name = 'test account new');
        insert accountB;
        Contact contactA = new Contact (lastName = 'test Contact', AccountId = accountA.Id);
        insert contactA;
        Contact contactB = new Contact (lastName = 'test Contact', AccountId = accountB.Id);
        insert contactB;
        obj.put(UtilityController.appNamespace() + 'Account__c', accountA.Id);
		obj.put(UtilityController.appNamespace() + 'Contact__c', contactB.Id);
		insert obj;
		List<Reference_Basic_Information__c> rbis = new List<Reference_Basic_Information__c>();
		rbis.add(new Reference_Basic_Information__c(Account__c = accountA.Id, Referenceability_Status__c = 'Active', Is_Referenceable__c = true));
		rbis.add(new Reference_Basic_Information__c(Account__c = accountA.Id, Contact__c = contactA.Id, Referenceability_Status__c = 'Active', Is_Referenceable__c = true));
		rbis.add(new Reference_Basic_Information__c(Account__c = accountB.Id, Contact__c = contactB.Id,  Referenceability_Status__c = 'Active', Is_Referenceable__c = true));
        insert rbis;
        
        List<Attribute__c> attributes = new List<Attribute__c> {TestDataFactory.createAttribute()[0]};
        attributes[0].Inheritable__c = true;
        attributes[0].Level__c = 0;
        insert attributes;
        
        List<Attribute__c> childAttributesLevel1 = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributesLevel1;
        List<Attribute__c> childAttributesLevel2 = TestDataFactory.createChildAttributes(childAttributesLevel1, 2, 1);
        insert childAttributesLevel2;
        List<Attribute__c> childAttributesLevel3 = TestDataFactory.createChildAttributes(childAttributesLevel2, 3, 1);
        insert childAttributesLevel3;
        
        TestDataFactory.createAccountAttributes(new List<Account> {accountA}, childAttributesLevel3, true);
        List<Account_Attribute__c> accAtts = [SELECT Id, Account__c FROM Account_Attribute__c 
        									WHERE Account__c = :accountA.Id AND Attribute__c IN :childAttributesLevel1];
        List<Contact_Attribute__c> conAtts = [SELECT Id FROM Contact_Attribute__c 
        									WHERE Contact__c = :contactA.Id AND From_Account__c = true];
        //Start Test method
        Test.startTest();
	        ApexPages.StandardController controller = new ApexPages.StandardController(accAtts[0]);
	        system.assertEquals(3, conAtts.size());
	        AccountAttributeEditController tempObj = new AccountAttributeEditController(controller);
	        tempObj.removeAttributes();
	        conAtts = [SELECT Id FROM Contact_Attribute__c 
        									WHERE Contact__c = :contactA.Id AND From_Account__c = true];
			system.assertEquals(0, conAtts.size());
        //End Test method
        Test.stopTest();
    }
}