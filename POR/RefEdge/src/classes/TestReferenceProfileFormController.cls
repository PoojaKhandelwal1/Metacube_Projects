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
 * Description: test class for ReferenceProfileFormController
 * Author: Gaurav Saini (16 Oct, 2017)
 */
@isTest(seeAllData = false)
public with sharing class TestReferenceProfileFormController {
    
    /**
	 * method to test constructor
	 * author: Gaurav Saini (16 Oct, 2017)
	 */
    public static testMethod void testConstructor() {
    	Apexpages.currentPage().getParameters().put('PUMAccId', 'testUserId');
    	Apexpages.currentPage().getParameters().put('PUMConId', 'testAccId');
    	Apexpages.currentPage().getParameters().put('pageNo', '2');
    	Apexpages.currentPage().getParameters().put('showMore', 'true');
    	Apexpages.currentPage().getParameters().put('userId', 'test');
		ReferenceProfileFormController testObj = new ReferenceProfileFormController();
		system.assertNotEquals(testObj.userId, '');
    }
    
    /**
	 * method to test getAccountContactDetails method
	 * author: Gaurav Saini (16 Oct, 2017)
	 */
    public static testMethod void testGetAccountContactDetails() {
    	Account testAcc = new Account(Name = 'test account');
    	insert testAcc;
    	Contact testCon = new Contact(AccountId = testAcc.Id, LastName = 'test contact');
    	insert testCon;
    	String result = ReferenceProfileFormController.getAccountContactDetails(testAcc.Id, testCon.Id);
    	system.assert(result == 'test account@@@test contact');
    }
    
    /**
	 * method to test getDataMappingsList method
	 * author: Gaurav Saini (16 Oct, 2017)
	 */
    public static testMethod void testGetDataMappingsList() {
    	List<Data_Mapping__c> dataMappings = new List<Data_Mapping__c>();
    	dataMappings.add(new Data_Mapping__c(Name = 'test dm 1', Visible__c = true, Object__c = ConstantsController.REFERENCE_PROFILE_FORM));
    	insert dataMappings;
    	String result = ReferenceProfileFormController.getDataMappingsList();
    	system.assert(result != '');
    }
    
    /**
	 * method to test getFilterAttributesMap method
	 * author: Gaurav Saini (16 Oct, 2017)
	 */
    public static testMethod void testGetFilterAttributesMap() {
    	List<Label__c> filterList = TestDataFactory.createLabels();
    	insert filterList;
    	List<Attribute__c> attributeList = TestDataFactory.createAttribute();
    	insert attributeList;
    	attributeList[0].Ref_Limit_to_Acct_or_Cntct__c = 'Account';
    	update attributeList;
    	List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attributeList, 1, 2);
    	insert childAttList;
    	TestDataFactory.createAttributeLabels(filterList, childAttList);
    	List<String> filterIds = new List<String>();
    	
    	for (Label__c lb : filterList) {
    		filterIds.add(lb.Id);
    	}
    	String result = ReferenceProfileFormController.getFilterAttributesMap(JSON.serialize(filterIds));
    	system.assert(result != '');
    }
    
    /**
	 * method to test getRefTypesList method
	 * author: Gaurav Saini (16 Oct, 2017)
	 */
    public static testMethod void testGetRefTypesList() {
    	List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
    	List<String> refTypeIds = new List<String>();
    	
    	for (Referenceability_Type__c rt : refTypeList) {
	    	refTypeIds.add(rt.Id);
    	}
    	String result = ReferenceProfileFormController.getRefTypesList(JSON.serialize(refTypeIds));
    	system.assert(result != '');
    }
    
    /**
	 * method to test saveRefProfile method
	 * author: Gaurav Saini (16 Oct, 2017)
	 */
    public static testMethod void testSaveRefProfile() {
        TestDataFactory.createCustomNotifications();
    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
    	Account testAcc = new Account(Name = 'test account');
    	insert testAcc;
    	Reference_Basic_Information__c accRBI = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = testAcc.Id);
    	insert accRBI;
    	Contact testCon = new Contact(AccountId = testAcc.Id, LastName = 'test contact');
    	insert testCon;
    	Reference_Basic_Information__c conRBI = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = testAcc.Id, Contact__c = testCon.Id);
    	insert conRBI;
    	
    	List<Label__c> filterList = TestDataFactory.createLabels();
    	insert filterList;
    	List<Attribute__c> attributeList = TestDataFactory.createAttribute();
    	insert attributeList;
    	attributeList[0].Ref_Limit_to_Acct_or_Cntct__c = 'Account';
    	update attributeList;
    	List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attributeList, 1, 2);
    	insert childAttList;
    	TestDataFactory.createAttributeLabels(filterList, childAttList);
    	Map<String, List<String>> filtersMap = new Map<String, List<String>>();
    	
    	for (Attributes_Labels__c al : [SELECT Id, Attribute__c, Attribute__r.Name, Attribute__r.ParentIds__c,
										Label__c, Label__r.Name, Label__r.Ref_Limit_to_Acct_or_Cntct__c
										FROM Attributes_Labels__c
										WHERE Label__c != null
										AND Attribute__c != null
										ORDER BY Attribute__r.Name
										LIMIT :limits.getLimitQueryRows()]) {
			
			if (!filtersMap.containsKey(al.Label__r.Name)) {
	    		filtersMap.put(al.Label__r.Name, new List<String>());
			}
			filtersMap.get(al.Label__r.Name).add(al.Attribute__c);
    	}
    	
    	List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
    	List<String> refTypeIds = new List<String>();
    	
    	for (Referenceability_Type__c rt : refTypeList) {
	    	refTypeIds.add(rt.Id);
    	}
    	Test.startTest();
    	String result = ReferenceProfileFormController.saveRefProfile(testAcc.Id, testCon.Id, testAcc.Name, testCon.Name, JSON.serialize(filtersMap), JSON.serialize(refTypeIds), 'test comments');
    	system.assertEquals(result, 'success');
    	Test.stopTest();
    }
}