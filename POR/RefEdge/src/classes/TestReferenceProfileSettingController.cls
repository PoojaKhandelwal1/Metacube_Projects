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
 * Description: test class for ReferenceProfileSettingController
 * Author: Gaurav Saini (16 Oct, 2017)
 */
@isTest(seeAllData = false)
public with sharing class TestReferenceProfileSettingController {
    
    /**
	 * method to test getDataMappings method
	 * author: Gaurav Saini (16 Oct, 2017)
	 */
    public static testMethod void testGetDataMappings() {
    	ReferenceProfileSettingController testObj = new ReferenceProfileSettingController();
    	List<Data_Mapping__c> dataMappings = new List<Data_Mapping__c>();
    	dataMappings.add(new Data_Mapping__c(Name = 'test dm 1', Visible__c = true, Object__c = ConstantsController.REFERENCE_PROFILE_FORM));
    	insert dataMappings;
    	String result = ReferenceProfileSettingController.getDataMappings();
    	system.assert(result != '');
    }
    
    /**
	 * method to test getRefTypeMappings method
	 * author: Gaurav Saini (16 Oct, 2017)
	 */
    public static testMethod void testGetRefTypeMappings() {
    	List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	insert refTypeList;
    	String result = ReferenceProfileSettingController.getRefTypeMappings(JSON.serialize(new List<String>()));
    	system.assert(result != '');
    }
    
    /**
	 * method to test getFilterMappings method
	 * author: Gaurav Saini (16 Oct, 2017)
	 */
    public static testMethod void testGetFilterMappings() {
    	List<Label__c> filterList = TestDataFactory.createLabels();
    	insert filterList;
    	List<Attribute__c> attributeList = TestDataFactory.createAttribute();
    	insert attributeList;
    	attributeList[0].Ref_Limit_to_Acct_or_Cntct__c = 'Account';
    	update attributeList;
    	List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attributeList, 1, 2);
    	insert childAttList;
    	TestDataFactory.createAttributeLabels(filterList, childAttList);
    	String result = ReferenceProfileSettingController.getFilterMappings(JSON.serialize(new List<String>()));
    	system.assert(result != '');
    }
    
    /**
	 * method to test getFormHeaders method
	 * author: Gaurav Saini (16 Oct, 2017)
	 */
    public static testMethod void testGetFormHeaders() {
    	List<Data_Mapping__c> dataMappings = new List<Data_Mapping__c>();
    	dataMappings.add(new Data_Mapping__c(Name = 'test dm 1', Visible__c = true, Object__c = ConstantsController.REFERENCE_PROFILE_FORM));
    	insert dataMappings;
    	String result = ReferenceProfileSettingController.getFormHeaders();
    	system.assert(result != '');
    }
    
    
    
    
    
}