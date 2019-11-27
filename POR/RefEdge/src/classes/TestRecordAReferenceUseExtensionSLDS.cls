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
 * Class: RecordAReferenceUseExtensionSLDS
 * Description : class to test and cover RecordAReferenceUseExtensionSLDS
 * Created by: Rekha Jangir @5 September 2017
 */
@isTest(seeAllData = false)
public with sharing class TestRecordAReferenceUseExtensionSLDS {
    
	/*
     * Method to cover all method and constructor for account
     * Created By: Rekha Jangir @5 September 2017
     */
    static testmethod void testRecordReferenceOnAccount() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	customSetting.Enable_Sales_Rewards_Notification__c = true;
        update customSetting;
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        refTypes.add(new Referenceability_Type__c(Name = 'REFERANCE USE', Referenceability_Type__c = true, Visible__c = true, 
        						Sales_Point__c = 50, Referenceability_code__c = ConstantsController.REFERANCE_USE, Sales_Reward__c = true));
        insert refTypes;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        
    	//Start test method
        test.startTest();
            Apexpages.currentPage().getParameters().put('Id', accounts[0].Id);
            RecordAReferenceUseExtensionSLDS obj = new RecordAReferenceUseExtensionSLDS();
            RecordAReferenceUseExtensionSLDS.InfoWrapper info = RecordAReferenceUseExtensionSLDS.fetchInfo('');
            info = RecordAReferenceUseExtensionSLDS.fetchInfo(obj.recordId);
            info.selectedRefType = info.refTypes[0].id;
            info.activityDate = date.today();
            info.notes = 'test account request';
            String result = RecordAReferenceUseExtensionSLDS.submit(JSON.serialize(info));
            system.assertEquals('success:50:REFERANCE USE', result);
            system.assertNotEquals(RecordAReferenceUseExtensionSLDS.getDateFormat(), '');
    	//Stop test method
        test.stopTest();
    }
    
    /*
     * Method to cover all method and constructor for contact
     * Created By: Rekha Jangir @5 September 2017
     */
    static testmethod void testRecordReferenceOnContact() {
    	//create test data
    	Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c');
		Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	customSetting.Shared_Contacts__c = true;
        customSetting.Shared_Contact_Object__c = describeResult.getName();
		customSetting.Shared_Account_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe().getName();
		customSetting.Shared_Contact_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Contact__c').getDescribe().getName();
		customSetting.Roll_up_Attributes_to_Primary_Account__c = true;
        customSetting.Roll_up_Referenceability_to_Primary_Acc__c = true;
        customSetting.Inherit_Attributes_from_All_Accounts__c = true;
		update customSetting;
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        Account account = new Account( Name = 'test account');
        insert account;
        Contact contact = new Contact (lastName = 'test Contact', AccountId = account.Id);
        insert contact;
        Account acc = new Account(Name = 'new shared');
        insert acc;
        Hit_List__c sharedc = new Hit_List__c(Account__c = acc.Id, Contact__c = contact.Id);
        insert sharedc;
        
    	//Start test method
        test.startTest();
            Apexpages.currentPage().getParameters().put('Id', contact.Id);
            RecordAReferenceUseExtensionSLDS obj = new RecordAReferenceUseExtensionSLDS();
            RecordAReferenceUseExtensionSLDS.InfoWrapper info = RecordAReferenceUseExtensionSLDS.fetchInfo(obj.recordId);
            info.selectedRefType = info.refTypes[0].id;
            info.activityDate = date.today();
            info.notes = 'test contac request';
            info.useFeedback = info.feedbackOptions[0].id;
            info.feedbackReason = 'good';
            String result = RecordAReferenceUseExtensionSLDS.submit(JSON.serialize(info));
            system.assertEquals('', result);
    	//Stop test method
        test.stopTest();
    }
    
    
    /*
     * Method to cover all method and constructor for opportunity
     * Created By: Rekha Jangir @5 September 2017
     */
    static testmethod void testRecordReferenceOnOpportunity() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        Opportunity opp = new Opportunity(Name = accounts[0].Name + ' Opportunity', AccountId = accounts[0].Id, 
        												CloseDate = system.today(), StageName = 'Closed Won');
        insert opp;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        
    	//Start test method
        test.startTest();
            Apexpages.currentPage().getParameters().put('Id', opp.Id);
            RecordAReferenceUseExtensionSLDS obj = new RecordAReferenceUseExtensionSLDS();
            RecordAReferenceUseExtensionSLDS.InfoWrapper info = RecordAReferenceUseExtensionSLDS.fetchInfo(obj.recordId);
            info.selectedRefType = info.refTypes[0].id;
            info.activityDate = date.today() + 3;
            info.notes = 'test opp request';
            String result = RecordAReferenceUseExtensionSLDS.submit(JSON.serialize(info));
            system.assertNotEquals('', result);
            info.activityDate = date.today();
            result = RecordAReferenceUseExtensionSLDS.submit(JSON.serialize(info));
            system.assertEquals('', result);
            
            String permission = RecordAReferenceUseExtensionSLDS.getPermissionsMessage(true);
    	//Stop test method
        test.stopTest();
    }
}