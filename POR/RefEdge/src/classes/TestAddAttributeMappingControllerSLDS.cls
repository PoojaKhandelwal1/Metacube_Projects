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
 * Class: AddAttributeMappingController
 * Description : class to test and cover AddAttributeMappingController
 * Modified by: Rekha Jangir @21 August 2017
 */
@isTest(seeAllData = false)
public with sharing class TestAddAttributeMappingControllerSLDS {
	/*
     * Method to cover Account attribute mapping functionality
     * Created By: Rekha Jangir @21 August 2017
     */
    static testMethod void testAccountMapping() {
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//Start test method
        Test.startTest();
        	ApexPages.StandardController controller = new ApexPages.StandardController(new Attribute_Mapping__c());
        	AddAttributeMappingControllerSLDS attMapObj = new AddAttributeMappingControllerSLDS(controller);
        	Map<String, List<AddAttributeMappingControllerSLDS.OptionWrapper>> objects
                = (Map<String, List<AddAttributeMappingControllerSLDS.OptionWrapper>>)JSON.deserialize(AddAttributeMappingControllerSLDS.getObjects(), Map<String, List<AddAttributeMappingControllerSLDS.OptionWrapper>>.class);
        	AddAttributeMappingControllerSLDS.FieldValuesWrapper fieldWrapper = AddAttributeMappingControllerSLDS.getFields('Account');
        	Map<String, String> fieldMap = AddAttributeMappingControllerSLDS.relatedListSelected('Opportunity', false, '');
        	AddAttributeMappingControllerSLDS.InfoWrapper info = new AddAttributeMappingControllerSLDS.InfoWrapper(new Attribute_Mapping__c());
        	info.selectedObject = 'Account';
	        info.filterName = 'Name';
	        info.attName = 'Name';
	        info.isInheritable = true;
	        info.fieldName = 'Name';
	        info.isRelatedMapping = true;
	        info.fieldApiName = 'Name';
	        info.selectedRelatedField = 'Opportunities';
        	String result = AddAttributeMappingControllerSLDS.saveMapping(JSON.serialize(info), JSON.serialize(fieldWrapper), 'default', JSON.serialize(new List<ListViewFiltersController.FilterWrapper>()));
        	
            List<Attribute_Mapping__c> attMappings = [SELECT Id FROM Attribute_Mapping__c WHERE Object__c = :ConstantsController.ACCOUNT];
            system.assertEquals(1, attMappings.size());
        	
        	String permission = AddAttributeMappingControllerSLDS.getPermissionsMessage(true);
        	system.assertNotEquals(null, attMapObj.nameSpace);
            
        //Stop test method
        Test.stopTest();
    }
    
    /*
     * Method to cover Contact attribute mapping functionality
     * Created By: Rekha Jangir @21 August 2017
     */
    static testMethod void testContactMapping() {
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//Start test method
        Test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(new Attribute_Mapping__c());
        	AddAttributeMappingControllerSLDS attMapObj = new AddAttributeMappingControllerSLDS(controller);
        	AddAttributeMappingControllerSLDS.FieldValuesWrapper fieldWrapper = AddAttributeMappingControllerSLDS.getFields('Contact');
        	Map<String, String> fieldMap = AddAttributeMappingControllerSLDS.lookupSelected('User');
        	AddAttributeMappingControllerSLDS.InfoWrapper info = new AddAttributeMappingControllerSLDS.InfoWrapper(new Attribute_Mapping__c());
        	info.selectedObject = 'Contact';
	        info.filterName = 'Email';
	        info.attName = 'Email';
	        info.isInheritable = true;
	        info.fieldName = 'Email';
	        info.isRelatedMapping = true;
	        info.fieldApiName = 'Email';
	        info.selectedLookupField = 'OwnerId';
        	String result = AddAttributeMappingControllerSLDS.saveMapping(JSON.serialize(info), JSON.serialize(fieldWrapper), 'default', JSON.serialize(new List<ListViewFiltersController.FilterWrapper>()));
        	
            List<Attribute_Mapping__c> attMappings = [SELECT Id FROM Attribute_Mapping__c WHERE Object__c = :ConstantsController.CONTACT];
            system.assertEquals(1, attMappings.size());
            
            info = AddAttributeMappingControllerSLDS.getAttributeMappingRecord(attMappings[0].Id);
            result = AddAttributeMappingControllerSLDS.saveMapping(JSON.serialize(info), JSON.serialize(fieldWrapper), 'default', JSON.serialize(new List<ListViewFiltersController.FilterWrapper>()));
        //Stop test method
        Test.stopTest();
    }
    
    /*
     * Method to cover Reference Content attribute mapping functionality
     * Created By: Rekha Jangir @21 August 2017
     */
    static testMethod void testReferenceContentMapping() {
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//Start test method
        Test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(new Attribute_Mapping__c());
        	AddAttributeMappingControllerSLDS attMapObj = new AddAttributeMappingControllerSLDS(controller);
        	AddAttributeMappingControllerSLDS.FieldValuesWrapper fieldWrapper = AddAttributeMappingControllerSLDS.getFields(ConstantsController.REFERENCE_CONTENT);
        	AddAttributeMappingControllerSLDS.InfoWrapper info = new AddAttributeMappingControllerSLDS.InfoWrapper(new Attribute_Mapping__c());
        	info.selectedObject = ConstantsController.REFERENCE_CONTENT;
        	for (String key : fieldWrapper.fieldOptions.keySet()) {        		
		        info.filterName = key;
		        info.attName = key;
		        info.fieldName = key;
		        info.fieldApiName = key;
		        info.selectedField = key;
        	}
        	String result = AddAttributeMappingControllerSLDS.saveMapping(JSON.serialize(info), JSON.serialize(fieldWrapper), 'default', JSON.serialize(new List<ListViewFiltersController.FilterWrapper>()));
        	
            List<Attribute_Mapping__c> attMappings = [SELECT Id FROM Attribute_Mapping__c WHERE Object__c = :ConstantsController.REFERENCE_CONTENT];
            system.assertEquals(1, attMappings.size());
        //Stop test method
        Test.stopTest();
    }
    /*
     * Method to cover Opportunity attribute mapping functionality
     * Created By: Rekha Jangir @21 August 2017
     */
    static testMethod void testOpportunityMapping() {
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//Start test method
        Test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(new Attribute_Mapping__c());
        	AddAttributeMappingControllerSLDS attMapObj = new AddAttributeMappingControllerSLDS(controller);
        	AddAttributeMappingControllerSLDS.FieldValuesWrapper fieldWrapper = AddAttributeMappingControllerSLDS.getFields(ConstantsController.OPPORTUNITY);
        	Map<String, String> fieldMap = AddAttributeMappingControllerSLDS.relatedListSelected('OpportunityLineItem', true, 'OpportunityLineItems');
        	AddAttributeMappingControllerSLDS.InfoWrapper info = new AddAttributeMappingControllerSLDS.InfoWrapper(new Attribute_Mapping__c());
        	info.selectedObject = ConstantsController.OPPORTUNITY;
	        info.filterName = 'test';
	        info.attName = 'test';
	        info.isInheritable = true;
	        info.fieldName = 'test';
	        info.isRelatedMapping = true;
	        info.fieldApiName = 'test';
	        info.selectedRelatedField = 'OpportunityLineItems';
        	String result = AddAttributeMappingControllerSLDS.saveMapping(JSON.serialize(info), JSON.serialize(fieldWrapper), 'default', JSON.serialize(new List<ListViewFiltersController.FilterWrapper>()));
        	
            List<Attribute_Mapping__c> attMappings = [SELECT Id FROM Attribute_Mapping__c WHERE Object__c = :ConstantsController.OPPORTUNITY];
            system.assertEquals(0, attMappings.size());
        	AddAttributeMappingControllerSLDS.getAttributeMappingRecord('');
        //Stop test method
        Test.stopTest();
    }
    
    /*
     * Method to cover Opportunity attribute mapping functionality for product
     * Created By: Rekha Jangir @21 August 2017
     */
    static testMethod void testOpportunityProductMapping() {
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//Start test method
        Test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(new Attribute_Mapping__c());
        	AddAttributeMappingControllerSLDS attMapObj = new AddAttributeMappingControllerSLDS(controller);
        	AddAttributeMappingControllerSLDS.FieldValuesWrapper fieldWrapper = AddAttributeMappingControllerSLDS.getFields(ConstantsController.OPPORTUNITY);
        	Map<String, String> fieldMap = AddAttributeMappingControllerSLDS.relatedListSelected('OpportunityLineItem', true, 'OpportunityLineItems');
        	AddAttributeMappingControllerSLDS.InfoWrapper info = new AddAttributeMappingControllerSLDS.InfoWrapper(new Attribute_Mapping__c());
        	info.selectedObject = ConstantsController.OPPORTUNITY;
	        info.filterName = 'Product';
	        info.attName = 'Product';
	        info.isInheritable = true;
	        info.fieldName = 'Product';
	        info.isRelatedMapping = true;
	        info.fieldApiName = 'Product2';
	        info.selectedRelatedField = 'OpportunityLineItems';
        	String result = AddAttributeMappingControllerSLDS.saveMapping(JSON.serialize(info), JSON.serialize(fieldWrapper), 'default', JSON.serialize(new List<ListViewFiltersController.FilterWrapper>()));
        	
            List<Attribute_Mapping__c> attMappings = [SELECT Id FROM Attribute_Mapping__c WHERE Object__c = :ConstantsController.OPPORTUNITY];
            system.assertEquals(1, attMappings.size());
        //Stop test method
        Test.stopTest();
    }
    
    /*
     * Method to cover Reference Profile attribute mapping functionality
     * Created By: Rekha Jangir @21 August 2017
     */
    static testMethod void testReferenceProfileMapping() {
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//Start test method
        Test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(new Attribute_Mapping__c());
        	AddAttributeMappingControllerSLDS attMapObj = new AddAttributeMappingControllerSLDS(controller);
        	AddAttributeMappingControllerSLDS.FieldValuesWrapper fieldWrapper = AddAttributeMappingControllerSLDS.getFields(ConstantsController.REFERENCE_PROFILE);
        	Map<String, String> fieldMap = AddAttributeMappingControllerSLDS.lookupSelected('User');
        	AddAttributeMappingControllerSLDS.InfoWrapper info = new AddAttributeMappingControllerSLDS.InfoWrapper(new Attribute_Mapping__c());
        	info.selectedObject = ConstantsController.REFERENCE_PROFILE;
	        info.filterName = 'Website';
	        info.attName = 'Website';
	        info.isInheritable = true;
	        info.fieldName = 'Website';
	        info.isRelatedMapping = true;
	        info.fieldApiName = 'Website';
	        info.selectedRelatedField = fieldWrapper.lookUpFieldOptions[0].id;
        	String result = AddAttributeMappingControllerSLDS.saveMapping(JSON.serialize(info), JSON.serialize(fieldWrapper), 'default', JSON.serialize(new List<ListViewFiltersController.FilterWrapper>()));
        	
            List<Attribute_Mapping__c> attMappings = [SELECT Id FROM Attribute_Mapping__c WHERE Object__c = :ConstantsController.REFERENCE_PROFILE];
            system.assertEquals(1, attMappings.size());
        //Stop test method
        Test.stopTest();
    }

    /**
     * Method to test new attribute mapping creation using object records
     * author: Gaurav Saini (16 Mar, 2019)
     */
    static testMethod void testObjectAttMapping() {
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accList = TestDatafactory.createAccounts();
        insert accList;
    	//Start test method
        Test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(new Attribute_Mapping__c());
        	AddAttributeMappingControllerSLDS attMapObj = new AddAttributeMappingControllerSLDS(controller);
        	AddAttributeMappingControllerSLDS.InfoWrapper info = new AddAttributeMappingControllerSLDS.InfoWrapper(new Attribute_Mapping__c());
        	info.selectedObject = 'Account';
	        info.filterName = 'Account Filter';
	        info.attName = 'Account Attribute';
	        info.isInheritable = true;
	        info.autoAdd = true;
	        info.autoUpdate = true;
	        info.autoDelete = true;
	        info.fieldName = 'Name';
	        info.isRelatedMapping = false;
            AddAttributeMappingControllerSLDS.FieldValuesWrapper fieldWrapper = AddAttributeMappingControllerSLDS.getFields('Account');
        	String result = AddAttributeMappingControllerSLDS.saveMapping(JSON.serialize(info), JSON.serialize(fieldWrapper), 'object', JSON.serialize(new List<ListViewFiltersController.FilterWrapper>()));

            // testing automatic attributes update and delete
            accList[0].Name = 'New Account Name';
            update accList[0];
            delete accList[1];
            Database.executeBatch(new Batch_SyncTaxonomyAttributes());
        	
            List<Attribute_Mapping__c> attMappings = [SELECT Id FROM Attribute_Mapping__c WHERE Object__c = 'Account' AND Field_API_Name__c = null];
            system.assertEquals(1, attMappings.size());
        //Stop test method
        Test.stopTest();
    }
}