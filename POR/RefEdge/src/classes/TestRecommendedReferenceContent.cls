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
 * Class : RecommendedReferenceContent
 * Description : Controller used for Recommended Reference Content.  
 * Last modified by : Rajesh @23 June 2017
 */ 
@isTest(seeAllData = false)
public with sharing class TestRecommendedReferenceContent {
	/**
     * Test Method with Account as related object
     */
	static testMethod void testWithAccountAsRelatedObject(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        List<ContentVersion> nativeContents = TestDataFactory.setUpNativeContents();
        insert nativeContents;
        
        List<Reference_Content__c> contents = TestDataFactory.setUpContents(nativeContents);
        insert contents;
        
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        
        List<Attribute__c> childAttributes = TestDataFactory.createStageChildAttributes(attributes, 1, 1);
        insert childAttributes;
        
        List<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        
        Reference_Content_Type__c createContentType = TestDataFactory.createContentType();
        insert createContentType;
        
        TestDataFactory.createAttributeLabels(labels, childAttributes);
	    List<Content_Attribute__c> conAtts = TestDataFactory.createContentAttributes(contents,childAttributes);
        List < Opportunity > opportunities = TestDataFactory.createOpportunity(accounts);
        insert opportunities;
        
        List<Attribute_Mapping__c> attrMaps = TestDataFactory.createRelatedAttributeMapping();
        List<Attribute_Mapping__c> attrMapTmp = new List<Attribute_Mapping__c>();
        
        for (Attribute_Mapping__c attrMap : attrMaps) {
            attrMap.Is_Related_Mapping__c = false;
            attrMap.Object__c = ConstantsController.ACCOUNT; 
            attrMapTmp.add(attrMap);
        }
        
        update attrMapTmp;        
		test.startTest();
			ApexPages.StandardController sc = new ApexPages.standardController(opportunities[0]);
        	RecommendedReferenceContent rrcObj = new RecommendedReferenceContent(sc);
        	system.assert(opportunities.size() > 0);
		test.stopTest();
	} 
	
	/**
     * Test Method with OPPORTUNITY as related object
     */
    static testMethod void testWithOppAsRelatedObject(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        List<ContentVersion> nativeContents = TestDataFactory.setUpNativeContents();
        insert nativeContents;
        
        List<Reference_Content__c> contents = TestDataFactory.setUpContents(nativeContents);
        insert contents;
        
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        
        List<Attribute__c> childAttributes = TestDataFactory.createStageChildAttributes(attributes, 1, 1);
        insert childAttributes;
        
        List<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        
        Reference_Content_Type__c createContentType = TestDataFactory.createContentType();
        insert createContentType;
        
        TestDataFactory.createAttributeLabels(labels, childAttributes);
	    List<Content_Attribute__c> conAtts = TestDataFactory.createContentAttributes(contents,childAttributes);
        List < Opportunity > opportunities = TestDataFactory.createOpportunity(accounts);
        insert opportunities;
               
        List<Attribute_Mapping__c> attrMaps = TestDataFactory.createRelatedAttributeMapping();
        List<Attribute_Mapping__c> attrMapTmp = new List<Attribute_Mapping__c>();
       
        for (Attribute_Mapping__c attrMap : attrMaps) {
            attrMap.Is_Related_Mapping__c = false;
            attrMap.Object__c = ConstantsController.OPPORTUNITY; 
            attrMapTmp.add(attrMap);
        }
        
        update attrMapTmp;
        
		test.startTest();
			ApexPages.StandardController sc = new ApexPages.standardController(opportunities[0]);
        	RecommendedReferenceContent rrcObj = new RecommendedReferenceContent(sc);
        	system.assert(opportunities.size() > 0);
		test.stopTest();
	}
	
	/**
     * Test Method to check at attribute level one
     */
	static testMethod void testWithAttributeLevelOne(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        List<ContentVersion> nativeContents = TestDataFactory.setUpNativeContents();
        insert nativeContents;
        
        List<Reference_Content__c> contents = TestDataFactory.setUpContents(nativeContents);
        insert contents;
        
        List<Attribute__c> attributes = new List < Attribute__c >();
        
        for (Attribute__c attr : TestDataFactory.createAttribute()) {
            attr.Level__c = 1;
            attributes.add(attr);
        }
        
        insert attributes;
        
        List<Attribute__c> childAttributes = TestDataFactory.createStageChildAttributes(attributes, 0, 1);
        insert childAttributes;
        
        List<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        
        Reference_Content_Type__c createContentType = TestDataFactory.createContentType();
        insert createContentType;
        
        TestDataFactory.createAttributeLabels(labels, childAttributes);
	    List<Content_Attribute__c> conAtts = TestDataFactory.createContentAttributes(contents,childAttributes);
        List<Opportunity> opportunities = TestDataFactory.createOpportunity(accounts);
        insert opportunities;
        
        List<Attribute_Mapping__c> attrMaps = TestDataFactory.createRelatedAttributeMapping();
        List<Attribute_Mapping__c> attrMapTmp = new List<Attribute_Mapping__c>();
        
        for(Attribute_Mapping__c attrMap : attrMaps) {
            attrMap.Is_Related_Mapping__c = true;
            attrMap.Object__c = ConstantsController.OPPORTUNITY;
           	attrMap.Related_Object__c = 'OpportunityLineItem';
            attrMapTmp.add(attrMap);
        }
        update attrMapTmp;
        
		test.startTest();
			ApexPages.StandardController sc = new ApexPages.standardController(opportunities[0]);
        	RecommendedReferenceContent rrcObj = new RecommendedReferenceContent(sc);
        	system.assert(opportunities.size() > 0);
		test.stopTest();
	}
	
	/**
     * Test Method to check With OpportunityLineItem
     */
	static testMethod void testWithOpportunityLineItem(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        List < ContentVersion > nativeContents = TestDataFactory.setUpNativeContents();
        insert nativeContents;
        
        List<Reference_Content__c> contents = TestDataFactory.setUpContents(nativeContents);
        insert contents;
        
        List<Attribute__c> attributes = TestDataFactory.createAttribute(); 
        insert attributes;
        
        List<Attribute__c> childAttributes = TestDataFactory.createStageChildAttributes(attributes, 1, 1);
        insert childAttributes;
        
        List<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        
        Reference_Content_Type__c createContentType = TestDataFactory.createContentType();
        insert createContentType;
        
        TestDataFactory.createAttributeLabels(labels, attributes);
        
	    List<Content_Attribute__c> conAtts = TestDataFactory.createContentAttributes(contents,childAttributes);
        List<Opportunity> opportunities = TestDataFactory.createOpportunity(accounts);
        insert opportunities;
        
       	Id pricebookId = Test.getStandardPricebookId();
		Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X', isActive = true);
		insert prod;
		PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 100.00, IsActive = true);
		insert pbEntry;
		
		for (Opportunity opp : opportunities) {
			opp.Amount = customSetting.Minimum_Opportunity_Size_OP__c + 500;
		}
		update opportunities;
		
		List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
		
		for (Opportunity opp : opportunities) {
			oppLineItemList.add(new OpportunityLineItem(OpportunityId = opp.Id, Quantity = 5, PricebookEntryId = pbEntry.Id, TotalPrice = 5 * pbEntry.UnitPrice));
		}
		insert oppLineItemList;
        //adding attribute mapping
        //List<Attribute_Mapping__c> attrMaps=TestDataFactory.createRelatedAttributeMapping();
        List<Attribute_Mapping__c> attMapping=new list<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Account',Field__c = 'Industry', Attribute_Name__c = 'Test 1', Filter_Label_Name__c='Test 1',Field_Api_Name__c='Industry',Is_Related_Mapping__c = false,Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true,Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c = ConstantsController.OPPORTUNITY, Field__c = 'Industry1', Attribute_Name__c = 'Test 2', Filter_Label_Name__c='Test 2',Field_Api_Name__c='StageName',Is_Related_Mapping__c = false,Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true,Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c = ConstantsController.OPPORTUNITY, Field__c = 'Industry1', Attribute_Name__c = 'Test 2', Filter_Label_Name__c='Test 2',Field_Api_Name__c='Industry1',Is_Related_Mapping__c = true,Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true,Inheritable__c = true));
        insert attMapping;
        
        List<Attribute_Mapping__c> attrMapTmp=new List<Attribute_Mapping__c>();
        List<Data_Mapping__c> dataMappings = TestDataFactory.createDataMappings();
        dataMappings[0].Order__c = 0;
        dataMappings[0].Field_API_Name__c = labels[0].Id;
        dataMappings[0].Label__c = labels[0].Name;
        dataMappings[0].Object__c = 'SmartSearchFilter';
        dataMappings[0].Filter_RefSearch_Visible__c = true; 
        dataMappings[0].Visible__c = true;						
        
        dataMappings[1].Order__c = 0;
        dataMappings[1].Field_API_Name__c = labels[1].Id;
        dataMappings[1].Label__c = labels[0].Name;
        dataMappings[1].Object__c = ConstantsController.ACCOUNT;
        dataMappings[1].Filter_RefSearch_Visible__c = true; 
        dataMappings[1].Visible__c = true;
        
        dataMappings[2].Order__c = 0;
        dataMappings[2].Field_API_Name__c = labels[2].Id;
        dataMappings[2].Label__c = labels[0].Name;
        dataMappings[2].Object__c = ConstantsController.OPPORTUNITY;
        dataMappings[2].Filter_RefSearch_Visible__c = true; 
        dataMappings[2].Visible__c = true;
        
        dataMappings[3].Order__c = 0;
        dataMappings[3].Field_API_Name__c = labels[3].Id;
        dataMappings[3].Label__c = labels[3].Name;
        dataMappings[3].Object__c = 'SmartSearchFilter';
        dataMappings[3].Filter_RefSearch_Visible__c = true; 
        dataMappings[3].Visible__c = true;						
        
        dataMappings[4].Order__c = 0;
        dataMappings[4].Field_API_Name__c = labels[4].Id;
        dataMappings[4].Label__c = labels[4].Name;
        dataMappings[4].Object__c = 'SmartSearchFilter';
        dataMappings[4].Filter_RefSearch_Visible__c = true; 
        dataMappings[4].Visible__c = true;						
        
        dataMappings[5].Order__c = 0;
        dataMappings[5].Field_API_Name__c = labels[5].Id;
        dataMappings[5].Label__c = labels[5].Name;
        dataMappings[5].Object__c = 'SmartSearchFilter';
        dataMappings[5].Filter_RefSearch_Visible__c = true; 
        dataMappings[5].Visible__c = true;						
        
        dataMappings[6].Order__c = 0;
        dataMappings[6].Field_API_Name__c = labels[6].Id;
        dataMappings[6].Label__c = labels[6].Name;
        dataMappings[6].Object__c = 'SmartSearchFilter';
        dataMappings[6].Filter_RefSearch_Visible__c = true; 
        dataMappings[6].Visible__c = true;						
        
        dataMappings[7].Order__c = 0;
        dataMappings[7].Field_API_Name__c = labels[7].Id;
        dataMappings[7].Label__c = labels[7].Name;
        dataMappings[7].Object__c = 'SmartSearchFilter';
        dataMappings[7].Filter_RefSearch_Visible__c = true; 
        dataMappings[7].Visible__c = true;						
        
        insert dataMappings; 
      
		test.startTest(); 
			ApexPages.StandardController sc = new ApexPages.standardController(opportunities[0]);
        	RecommendedReferenceContent rrcObj = new RecommendedReferenceContent(sc);
        	system.assert(opportunities.size() > 0);
		test.stopTest();
	}
}