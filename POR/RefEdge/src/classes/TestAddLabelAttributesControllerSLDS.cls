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
* Class: AddLabelAttributesControllerSLDS
* Description : class to test and cover AddLabelAttributesControllerSLDS 
* Modified by: Rekha Jangir @3 April 2017
*/
@isTest(seeAllData = false)
public with sharing class TestAddLabelAttributesControllerSLDS {
    /*
     * Method to cover fetchInfo method for label
     * Created : Rekha Jangir @3 April 2017
     */
    public static testMethod void testFetchInfoForLabel() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        TestDataFactory.createAttributeMapping();
        //Start test method
        Test.startTest();
            Apexpages.currentPage().getParameters().put('Id', labels[0].Id);
            AddLabelAttributesControllerSLDS testObject = new AddLabelAttributesControllerSLDS();
            //get all related informations 
            AddLabelAttributesControllerSLDS.InfoWrapper info = AddLabelAttributesControllerSLDS.fetchInfo(labels[0].Id, '', '');
            system.assertEquals(labels[0].Id, info.labelId);
            
            //get child attributes of an attribute
            List<AddLabelAttributesControllerSLDS.AttributeWrapper> attributeWrappers 
            											= AddLabelAttributesControllerSLDS.getAttributes(attributes[0].Id, '');
        	system.assertEquals(true, attributeWrappers.size() > 0);
        	
        	for (AddLabelAttributesControllerSLDS.AttributeWrapper att : info.rootAttributes) {
        		
        		if (att.isMapped) {
        			//get child attributes of a mapped attribute
            		List<AddLabelAttributesControllerSLDS.AttributeWrapper> mappedattributeWrappers 
            											= AddLabelAttributesControllerSLDS.getAttributes(attributes[0].Id, '');
        			break;
        		}
        	}
        	
        	info.currentAtts.add(attributes[0].Id);
        	String result = AddLabelAttributesControllerSLDS.saveAttributes(JSON.serialize(info));
        	system.assertEquals('', result);
        //Stop Test method
        Test.stopTest();
    }
    
    private static void addDefaultAttrbuteMappingForOpportunity() {
    	//Start: Create 'Default' type Attr Mapping Record
    	AddAttributeMappingControllerSLDS.InfoWrapper info = new AddAttributeMappingControllerSLDS.InfoWrapper(new Attribute_Mapping__c());
    	info.attName = 'Stage1';
    	//info.autoAdd = false;
    	info.fieldName = 'Stage';
    	info.filterName = 'Stage1';
    	info.selectedMapField = 'StageName';
    	info.selectedObject = 'Opportunity';
        
       // [attName=Stage1, autoAdd=false, autoDelete=false, autoPopulate=false, autoUpdate=false, fieldApiName=null, fieldName=Stage, filterName=Stage1, id=a0c1Y00000b2z4wQAA, isInheritable=false, isRelatedMapping=false, name=AM-13825, selectedField=null, selectedLookupField=null, selectedMapField=StageName, selectedObject=Opportunity, selectedRelatedField=null] f
        
        AddAttributeMappingControllerSLDS.FieldValuesWrapper fieldWrapper = new AddAttributeMappingControllerSLDS.FieldValuesWrapper();
        List<ListViewFiltersController.FilterWrapper> filters = new List<ListViewFiltersController.FilterWrapper>();
        
    	AddAttributeMappingControllerSLDS.saveMapping(JSON.serialize(info), JSON.serialize(fieldWrapper), 'default', JSON.serialize(filters));
        //End: Create 'Default' type Attr Mapping Record
    }
    
    /*
     * Method to cover fetchInfo method for account
     * Created : Rekha Jangir @3 April 2017
     */
    public static testMethod void testFetchInfoForAccount() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	addDefaultAttrbuteMappingForOpportunity();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        
        //Start test method
        Test.startTest();
            Apexpages.currentPage().getParameters().put('Id', accounts[0].Id);
            AddLabelAttributesControllerSLDS testObject = new AddLabelAttributesControllerSLDS();
            //get all related informations 
            AddLabelAttributesControllerSLDS.InfoWrapper info = AddLabelAttributesControllerSLDS.fetchInfo(accounts[0].Id, '', '');
            system.assertEquals(accounts[0].Id, info.accountId);

        	info.currentAtts.add(childAttributes[0].Id);
        	info.accConObj.makeAccountMember = true;
        	String result = AddLabelAttributesControllerSLDS.saveAttributes(JSON.serialize(info));
        	system.assertEquals('', result);
        //Stop Test method
        Test.stopTest();
    }
    /*
     * Method to cover fetchInfo method for contact
     * Created : Rekha Jangir @3 April 2017
     */
    public static testMethod void testFetchInfoForContact() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	addDefaultAttrbuteMappingForOpportunity();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        //Start test method
        Test.startTest();
            Apexpages.currentPage().getParameters().put('Id', contacts[0].Id);
            AddLabelAttributesControllerSLDS testObject = new AddLabelAttributesControllerSLDS();
            //get all related informations 
            AddLabelAttributesControllerSLDS.InfoWrapper info = AddLabelAttributesControllerSLDS.fetchInfo(contacts[0].Id, '', '');
            system.assertEquals(contacts[0].Id, info.contactId);

        	info.currentAtts.add(childAttributes[0].Id);
        	info.accConObj.makeContactMember = true;
        	info.accConObj.makeAccountMember = true;
        	String result = AddLabelAttributesControllerSLDS.saveAttributes(JSON.serialize(info));
        	system.assertEquals('', result);
        //Stop Test method
        Test.stopTest();
    }
    /*
     * Method to cover fetchInfo method for contact when shared contact is on
     * Created : Rekha Jangir @3 April 2017
     */
    public static testMethod void testFetchInfoForSharedContact() {
    	//create test data
    	Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c');
		Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Shared_Contacts__c = true;
        customSetting.Shared_Contact_Object__c = describeResult.getName();
		customSetting.Shared_Account_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe().getName();
		customSetting.Shared_Contact_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Contact__c').getDescribe().getName();
		customSetting.Roll_up_Attributes_to_All_Accounts__c = true;
        customSetting.Roll_up_Referenceability_to_Primary_Acc__c = true;
        customSetting.Inherit_Attributes_from_All_Accounts__c = true;
		update customSetting;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        List<Reference_Basic_Information__c> accountRbis = TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.setUpContactRBI(contacts);
        list<Hit_List__c> hitList = new list<Hit_List__c>();
        hitList.add(new Hit_List__c(note__c = 'test1', Account__c = accounts[1].Id, Contact__c = contacts[0].Id));
        hitList.add(new Hit_List__c(note__c = 'test2', Account__c = accounts[2].Id, Contact__c = contacts[0].Id));
        hitList.add(new Hit_List__c(note__c = 'test3', Account__c = accounts[3].Id, Contact__c = contacts[0].Id));
        insert hitList;
        TestDataFactory.createContactAttributes(contacts, new List<Attribute__c> {childAttributes[0]});
        TestDataFactory.createAccountAttributes(accounts, new List<Attribute__c> {childAttributes[3]}, false);
        //Start test method
        Test.startTest();
            Apexpages.currentPage().getParameters().put('Id', contacts[0].Id);
            AddLabelAttributesControllerSLDS testObject = new AddLabelAttributesControllerSLDS();
            //get all related informations 
            AddLabelAttributesControllerSLDS.InfoWrapper info = AddLabelAttributesControllerSLDS.fetchInfo(contacts[0].Id, '', '');
            system.assertEquals(contacts[0].Id, info.contactId);
            
            List<Reference_Basic_Information__c> contactRBI = [SELECT Roll_up_Attributes_to_All_Accounts__c, Roll_up_Attributes_to_Primary_Account__c 
            										FROM Reference_Basic_Information__c WHERE Contact__c = :contacts[0].Id];
            contactRBI[0].Roll_up_Attributes_to_All_Accounts__c = false;
	        contactRBI[0].Roll_up_Attributes_to_Primary_Account__c = true;
			update contactRBI;
            
            //get all related informations 
            info = AddLabelAttributesControllerSLDS.fetchInfo(contacts[0].Id, '', '');
            system.assertEquals(contacts[0].Id, info.contactId);
			
			
        	info.currentAtts.add(childAttributes[1].Id);
        	info.currentAtts.add(childAttributes[2].Id);
        	info.currentAtts.add(childAttributes[0].Id);
        	info.accConObj.makeContactMember = true;
        	info.accConObj.makeAccountMember = true;
        	String result = AddLabelAttributesControllerSLDS.saveAttributes(JSON.serialize(info));
        	system.assertEquals('', result);
        //Stop Test method
        Test.stopTest();
    }
    /*
     * Method to cover fetchInfo method for account from Profile update
     * Created : Rekha Jangir @3 April 2017
     */
    public static testMethod void testFetchInfoForAccountProfileUpdate() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        List<Attribute__c> nextChildAttributes = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
        insert nextChildAttributes;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        List<Reference_Basic_Information__c> accountRbis = TestDataFactory.setUpAccountRBI(accounts);
        List<Reference_Refresh__c> refRefreshList = TestDataFactory.createRefRefreshRecords(accounts, accountRbis);
        TestDataFactory.createAccountAttributes(accounts, new List<Attribute__c> {childAttributes[0], nextChildAttributes[0]}, false);
        //Start test method
        Test.startTest();
            Apexpages.currentPage().getParameters().put('Id', accounts[1].Id);
            Apexpages.currentPage().getParameters().put('refRefreshId', refRefreshList[1].Id);
            AddLabelAttributesControllerSLDS testObject = new AddLabelAttributesControllerSLDS();
            //get all related informations 
            AddLabelAttributesControllerSLDS.InfoWrapper info = AddLabelAttributesControllerSLDS.fetchInfo(accounts[1].Id, '', refRefreshList[1].Id);
            system.assertEquals(accounts[1].Id, info.accountId);
            system.assertNotEquals(null, info.refRefresh);
			
			info.currentAtts.add(nextChildAttributes[1].Id);
        	info.currentAtts.add(childAttributes[2].Id);
        	String result = AddLabelAttributesControllerSLDS.saveAttributes(JSON.serialize(info));
        	system.assertEquals('', result);
        //Stop Test method
        Test.stopTest();
    }
    /*
     * Method to cover fetchInfo method for contact from Profile update
     * Created : Rekha Jangir @3 April 2017
     */
    public static testMethod void testFetchInfoForContactProfileUpdate() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        List<Attribute__c> nextChildAttributes = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
        insert nextChildAttributes;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        List<Reference_Basic_Information__c> accountRbis = TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.setUpContactRBI(contacts);
        List<Reference_Refresh__c> refRefreshList = TestDataFactory.createRefRefreshRecords(accounts, accountRbis);
        TestDataFactory.createContactAttributes(contacts, new List<Attribute__c> {childAttributes[0], nextChildAttributes[0]});
        //Start test method
        Test.startTest();
            Apexpages.currentPage().getParameters().put('Id', contacts[0].Id);
            Apexpages.currentPage().getParameters().put('refRefreshId', refRefreshList[0].Id);
            AddLabelAttributesControllerSLDS testObject = new AddLabelAttributesControllerSLDS();
            //get all related informations 
            AddLabelAttributesControllerSLDS.InfoWrapper info = AddLabelAttributesControllerSLDS.fetchInfo(contacts[0].Id, '', refRefreshList[0].Id);
            system.assertEquals(contacts[0].Id, info.contactId);
            system.assertNotEquals(null, info.refRefresh);

			info.currentAtts.add(nextChildAttributes[1].Id);
        	info.currentAtts.add(childAttributes[2].Id);
        	info.currentAtts.add(childAttributes[0].Id);
        	String result = AddLabelAttributesControllerSLDS.saveAttributes(JSON.serialize(info));
        	system.assertEquals('', result);
        //Stop Test method
        Test.stopTest();
    }
    /*
     * Method to cover fetchInfo method for contact from Profile update when shared contact is on
     * Created : Rekha Jangir @3 April 2017
     */
    public static testMethod void testFetchInfoForSharedContactProfileUpdate() {
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
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        List<Attribute__c> nextChildAttributes = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
        insert nextChildAttributes;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        List<Reference_Basic_Information__c> accountRbis = TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.setUpContactRBI(contacts);
        List<Reference_Refresh__c> refRefreshList = TestDataFactory.createRefRefreshRecords(accounts, accountRbis);
        TestDataFactory.createContactAttributes(contacts, new List<Attribute__c> {childAttributes[0], nextChildAttributes[0]});
        list<Hit_List__c> hitList = new list<Hit_List__c>();
        hitList.add(new Hit_List__c(note__c = 'test1', Account__c = accounts[1].Id, Contact__c = contacts[0].Id));
        hitList.add(new Hit_List__c(note__c = 'test2', Account__c = accounts[2].Id, Contact__c = contacts[0].Id));
        hitList.add(new Hit_List__c(note__c = 'test3', Account__c = accounts[3].Id, Contact__c = contacts[0].Id));
        insert hitList;
        //Start test method
        Test.startTest();
            Apexpages.currentPage().getParameters().put('Id', contacts[0].Id);
            Apexpages.currentPage().getParameters().put('refRefreshId', refRefreshList[0].Id);
            Apexpages.currentPage().getParameters().put('PUMAccountId', accounts[0].Id);
            AddLabelAttributesControllerSLDS testObject = new AddLabelAttributesControllerSLDS();
            //get all related informations 
            AddLabelAttributesControllerSLDS.InfoWrapper info = AddLabelAttributesControllerSLDS.fetchInfo(contacts[0].Id, accounts[0].Id, refRefreshList[0].Id);
            system.assertEquals(contacts[0].Id, info.contactId);
            system.assertNotEquals(null, info.refRefresh);

			info.currentAtts.add(nextChildAttributes[1].Id);
        	info.currentAtts.add(childAttributes[2].Id);
        	info.currentAtts.add(childAttributes[0].Id);
        	String result = AddLabelAttributesControllerSLDS.saveAttributes(JSON.serialize(info));
        	system.assertEquals('', result);
        //Stop Test method
        Test.stopTest();
    }
    /*
     * Method to cover fetchInfo method for content
     * Created : Rekha Jangir @3 April 2017
     */
    public static testMethod void testFetchInfoForContent() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
        insert refContents;
        List<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        
        TestDataFactory.createContentAttributes(refContents, new List<Attribute__c> {childAttributes[1]});
        //Start test method
        Test.startTest();
            Apexpages.currentPage().getParameters().put('Id', refContents[0].Id);
            AddLabelAttributesControllerSLDS testObject = new AddLabelAttributesControllerSLDS();
            //get all related informations 
            AddLabelAttributesControllerSLDS.InfoWrapper info = AddLabelAttributesControllerSLDS.fetchInfo(refContents[0].Id, '', '');
            system.assertEquals(refContents[0].Id, info.contentId);

        	info.currentAtts.add(childAttributes[0].Id);
        	String result = AddLabelAttributesControllerSLDS.saveAttributes(JSON.serialize(info));
        	system.assertEquals('', result);
        	
        	Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'test error msg.'));
        	String error = AddLabelAttributesControllerSLDS.getPermissionsMessage(JSON.serialize(info));
        	system.assertEquals('test error msg.', error);
        	
        //Stop Test method
        Test.stopTest();
    }
}