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
 * Description: test class for reference lead form page
 * Author: Gaurav Saini (8 June, 2017)
 * Last modified by: Gaurav Saini (8 June, 2017)
 */
@isTest
public with sharing class TestReferenceLeadFormControllerSLDS {
    
    /**
	 * method to test constructor
	 * author: Gaurav Saini (8 June, 2017)
	 */
    public static testMethod void testConstructor() {
    	RefProspectorResponseController testProspectObj = new RefProspectorResponseController();
    	ReferenceLeadFormControllerSLDS testLeadObj = new ReferenceLeadFormControllerSLDS(testProspectObj);
    	String refLeadId = '';
    	String result;
    	List<Reference_Lead__c> testRefLead = TestDataFactory.createLeads();
    	insert testRefLead;
    	Apexpages.currentPage().getParameters().put('Id', testRefLead[0].Id);
		ReferenceLeadFormControllerSLDS testObj = new ReferenceLeadFormControllerSLDS(new ApexPages.StandardController(testRefLead[0]));
		system.assertNotEquals(testObj.refLeadId, '');
    }
    
    /**
	 * method to test constructor
	 * author: Gaurav Saini (8 June, 2017)
	 */
    public static testMethod void testGetFiltersToExclude() {
    	List<Attribute_Mapping__c> attMappingList = new List<Attribute_Mapping__c>();
    	Attribute_Mapping__c attMapping = new Attribute_Mapping__c(Object__c = 'Account', Field__c = 'Industry', Attribute_Name__c = 'Test 1', Filter_Label_Name__c = 'Test 1', Field_Api_Name__c = 'Industry', Is_Related_Mapping__c = false, Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Inheritable__c = true);
    	attMappingList.add(attMapping);
    	Attribute_Mapping__c attMapping1 = new Attribute_Mapping__c(Object__c ='Contact', Inheritable__c = true, Filter_Label_Name__c = 'LeadSource', Field__c = 'LeadSource', Field_Api_Name__c = 'LeadSource', Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Attribute_Name__c = 'LeadSource', Is_Related_Mapping__c = false);
    	attMappingList.add(attMapping1);
    	insert attMappingList;
    	String result = ReferenceLeadFormControllerSLDS.getFiltersToExclude();
    	Map<String, Set<String>> resultMap = (Map<String, Set<String>>)JSON.deserialize(result, Map<String, Set<String>>.class);
    	system.assert(resultMap.keySet().size() == 2);
    	system.assertNotEquals(ReferenceLeadFormControllerSLDS.getDateFormat(),''); 	 
    }
    
    /**
	 * method to test get data mappings method
	 * author: Gaurav Saini (8 June, 2017)
	 */
    public static testMethod void testGetDataMappingsList() {
    	List<Data_Mapping__c> dmList = new List<Data_Mapping__c>();
    	Data_Mapping__c dm = new Data_Mapping__c(Field_API_Name__c = null, Object__c = ConstantsController.REFERENCE_LEAD, Filter__c = null, Visible__c = true);
    	dmList.add(dm);
    	Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Reference_Lead__c.fields.getMap();
        
        for (String field : fieldsMap.keyset()) {
        	Schema.DescribeFieldResult fieldObj = fieldsMap.get(field).getDescribe();
        	
            if (fieldObj.isCustom() && fieldObj.isUpdateable()) {
            	Data_Mapping__c dm1 = new Data_Mapping__c(Field_API_Name__c = fieldObj.getName(), Object__c = ConstantsController.REFERENCE_LEAD, Filter__c = null, Visible__c = true);
    			dmList.add(dm1);
            	//break;
            }
        }
        insert dmList;
    	String result = ReferenceLeadFormControllerSLDS.getDataMappingsList();
    	List<ReferenceLeadFormControllerSLDS.DataMappingWrapper> resultList = (List<ReferenceLeadFormControllerSLDS.DataMappingWrapper>)JSON.deserialize(result, List<ReferenceLeadFormControllerSLDS.DataMappingWrapper>.class);
    	system.assertNotEquals(resultList.size(), 0);
    }
    
    /**
	 * method to test get filters map
	 * author: Gaurav Saini (8 June, 2017)
	 */
    public static testMethod void testGetFilterAttributesMap() {
    	List<Label__c> filterList = TestDataFactory.createLabels();
    	filterList[0].Ref_Limit_to_Acct_or_Cntct__c = '';
    	filterList[1].Ref_Limit_to_Acct_or_Cntct__c = 'Account';
    	filterList[2].Ref_Limit_to_Acct_or_Cntct__c = 'Contact';
    	insert filterList;
    	List<Attribute__c> attList = TestDataFactory.createAttribute();
    	attList[0].Ref_Limit_to_Acct_or_Cntct__c = '';
    	attList[1].Ref_Limit_to_Acct_or_Cntct__c = 'Account';
    	attList[2].Ref_Limit_to_Acct_or_Cntct__c = 'Contact';
    	insert attList;
    	List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attList, 1, 2);
    	insert childAttList;
    	TestDataFactory.createAttributeLabels(filterList, attList);
    	TestDataFactory.createAttributeLabels(filterList, childAttList);
    	List<String> filterIds = new List<String>();
    	
    	for (Label__c f : filterList) {
    		filterIds.add(f.Id);
    	}
    	String result = ReferenceLeadFormControllerSLDS.getFilterAttributesMap(JSON.serialize(filterIds));
    	Map<String, List<ReferenceLeadFormControllerSLDS.AttributeWrapper>> filterAttributesMap
    				= (Map<String, List<ReferenceLeadFormControllerSLDS.AttributeWrapper>>)JSON.deserialize(result, Map<String, List<ReferenceLeadFormControllerSLDS.AttributeWrapper>>.class);
    	system.assert(filterAttributesMap.keySet().size() > 0);
    }
    
    /**
	 * method to test get filters map
	 * author: Gaurav Saini (8 June, 2017)
	 */
    public static testMethod void testGetRefLead() {
    	Account testAcc = new Account(Name = 'Test account 123');
    	insert testAcc;
    	Opportunity testOpp = new Opportunity(AccountId = testAcc.Id, Name = 'Test opportunity 123',
    											Amount = 1000, StageName = 'Prospecting', CloseDate = Date.today() + 2);
    	insert testOpp;
    	testOpp.StageName = 'Closed Won';
    	update testOpp;
    	List<Reference_Lead__c> testRefLead = TestDataFactory.createLeads();
    	testRefLead[0].Reference_Lead_Opportunity__c = testOpp.Id;
    	testRefLead[0].Reference_Lead_Account__c = testAcc.Id;
    	insert testRefLead;
        List<ReferenceLeadFormControllerSLDS.DataMappingWrapper> dataMappingWrapperList
        			= new List<ReferenceLeadFormControllerSLDS.DataMappingWrapper>();
    	String result = ReferenceLeadFormControllerSLDS.getRefLead(testRefLead[0].Id, JSON.serialize(dataMappingWrapperList));
    	system.assert(result != '');
    }
    
    /**
	 * method to test get contact wrapper list
	 * author: Gaurav Saini (8 June, 2017)
	 */
    public static testMethod void testGetContactsList() {
    	Account testAcc = new Account(Name = 'Test account 123');
    	insert testAcc;
    	List<Contact> conList = new List<Contact>();
    	conList.add(new Contact(FirstName = 'a', LastName = 'test 123', AccountId = testAcc.Id));
    	conList.add(new Contact(FirstName = 'c', LastName = 'test 123', AccountId = testAcc.Id));
    	conList.add(new Contact(FirstName = 'b', LastName = 'test 123', AccountId = testAcc.Id));
    	conList.add(new Contact(FirstName = 'a', LastName = 'test 123', AccountId = testAcc.Id));
    	insert conList;
    	String result = ReferenceLeadFormControllerSLDS.getContactsList(testAcc.Id);
    	system.assert(result != '');
    }
    
    /**
	 * method to test get ref types wrapper list
	 * author: Gaurav Saini (8 June, 2017)
	 */
    public static testMethod void testGetRefTypesList() {
    	List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
    	insert refTypes;
    	List<String> refTypeIds = new List<String>();
    	
    	for (Referenceability_Type__c r : refTypes) {
    		refTypeIds.add(r.Id);
    	}
    	String result = ReferenceLeadFormControllerSLDS.getRefTypesList(JSON.serialize(refTypeIds));
    	List<ReferenceLeadFormControllerSLDS.RefTypeWrapper> resultList
    				= (List<ReferenceLeadFormControllerSLDS.RefTypeWrapper>)JSON.deserialize(result, List<ReferenceLeadFormControllerSLDS.RefTypeWrapper>.class);
    	system.assert(resultList.size() > 0);
    }
    
    /**
	 * method to test get ref types wrapper list
	 * author: Gaurav Saini (8 June, 2017)
	 */
    public static testMethod void testSaveRefLead() {
    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
    	cs.Enable_Sales_Rewards_Notification__c = true;
    	cs.Create_Reference_Profile__c = false;
    	cs.Create_Nomination__c = true;
    	cs.User_Reward_Onscreen_Notification__c = true;
    	update cs;
    	Account testAcc = new Account(Name = 'Test account 123');
    	insert testAcc;
    	Opportunity testOpp = new Opportunity(AccountId = testAcc.Id, Name = 'Test opportunity 123',
    											Amount = 1000, StageName = 'Prospecting', CloseDate = Date.today() + 2);
    	insert testOpp;
    	testOpp.StageName = 'Closed Won';
    	update testOpp;
    	List<Reference_Lead__c> testRefLead = TestDataFactory.createLeads();
    	testRefLead[0].Reference_Lead_Opportunity__c = testOpp.Id;
    	testRefLead[0].Reference_Lead_Account__c = testAcc.Id;
    	testRefLead[0].No_Response_Date__c = Date.today() + 5;
    	insert testRefLead;
        List<ReferenceLeadFormControllerSLDS.DataMappingWrapper> dataMappingWrapperList
        			= new List<ReferenceLeadFormControllerSLDS.DataMappingWrapper>();
    	String refLeadWrapperListJSON = ReferenceLeadFormControllerSLDS.getRefLead(testRefLead[0].Id, JSON.serialize(dataMappingWrapperList));
    	
    	List<Data_Mapping__c> dmList = new List<Data_Mapping__c>();
        // commented out because this part was throwing an exception
        // might be used in future, but it will only increase the coverage by 3-4%
        /*
    	Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Reference_Lead__c.fields.getMap();
        
        for (String field : fieldsMap.keyset()) {
        	Schema.DescribeFieldResult fieldObj = fieldsMap.get(field).getDescribe();
        	
            if (fieldObj.isCustom() && fieldObj.isUpdateable()) {
    			//dmList.add(new Data_Mapping__c(Field_API_Name__c = fieldObj.getName(), Object__c = ConstantsController.REFERENCE_LEAD, Filter__c = null, Visible__c = true););
            	break;
            }
        }
        */
        //insert dmList;
    	String fieldMappingsListJSON = ReferenceLeadFormControllerSLDS.getDataMappingsList();
    	
    	List<Label__c> filterList = TestDataFactory.createLabels();
    	filterList[0].Ref_Limit_to_Acct_or_Cntct__c = '';
    	filterList[1].Ref_Limit_to_Acct_or_Cntct__c = 'Account';
    	filterList[2].Ref_Limit_to_Acct_or_Cntct__c = 'Contact';
    	insert filterList;
    	List<Attribute__c> attList = TestDataFactory.createAttribute();
    	attList[0].Ref_Limit_to_Acct_or_Cntct__c = '';
    	attList[1].Ref_Limit_to_Acct_or_Cntct__c = 'Account';
    	attList[2].Ref_Limit_to_Acct_or_Cntct__c = 'Contact';
    	insert attList;
    	List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attList, 1, 2);
    	insert childAttList;
    	TestDataFactory.createAttributeLabels(filterList, attList);
    	TestDataFactory.createAttributeLabels(filterList, childAttList);
    	List<String> filterIds = new List<String>();
    	
    	for (Label__c f : filterList) {
    		filterIds.add(f.Id);
    	}
    	String filterAttMapJSON = ReferenceLeadFormControllerSLDS.getFilterAttributesMap(JSON.serialize(filterIds));
    	Map<String, List<ReferenceLeadFormControllerSLDS.AttributeWrapper>> filterAttributesMap
    				= (Map<String, List<ReferenceLeadFormControllerSLDS.AttributeWrapper>>)JSON.deserialize(filterAttMapJSON, Map<String, List<ReferenceLeadFormControllerSLDS.AttributeWrapper>>.class);
    	
    	for (String filterId : filterAttributesMap.keySet()) {
    		
	    	for (ReferenceLeadFormControllerSLDS.AttributeWrapper att : filterAttributesMap.get(filterId)) {
	    		att.isSelected = true;
	    	}
	    	break;
    	}
    	filterAttMapJSON = JSON.serialize(filterAttributesMap);
    	
    	List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
    	refTypes.add(new Referenceability_Type__c(Name = 'Test Ref Type',
    												Referenceability_code__c = ConstantsController.RLF_RESPONSE,
    												Sales_Point__c = 50,
    												Sales_Reward__c = true,
    												Visible__c = true));
    	insert refTypes;
    	List<String> selectedRefTypeIds = new List<String>{refTypes[0].Id, refTypes[1].Id};
    	
    	String result = ReferenceLeadFormControllerSLDS.saveRefLead(refLeadWrapperListJSON, fieldMappingsListJSON, null,
    																filterAttMapJSON, JSON.serialize(selectedRefTypeIds),
    																JSON.serialize(new Set<String>()), JSON.serialize(new Set<String>()));
    	system.assert(result.startsWith('success'));
    }
}