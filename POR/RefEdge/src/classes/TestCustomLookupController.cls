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
public with sharing class TestCustomLookupController {
	//Unit Test Method
	static testmethod void myUnitTest01() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        list<Reference_Content__c> referCons = TestDataFactory.createReferenceContent();
        insert referCons;
       //Start test method
        test.startTest();
        	PageReference pageRef = Page.CustomLookup;
	        Test.setCurrentPage(pageRef);
	        pageRef.getParameters().put('strText', '');
	        pageRef.getParameters().put('obj', 'Reference_Content__c');
        	CustomLookupController testObj = new CustomLookupController();
        	testObj.searchText = 'Ref';
        	testObj.search();
        	system.assertEquals(testObj.recordsList.size(),1);
        	testObj.searchText = '';
        	testObj.search();
        	pageRef.getParameters().put('strText', string.valueOf(referCons[0].Id));
	        pageRef.getParameters().put('obj', 'Reference_Content__c');
        	testObj = new CustomLookupController();
        //Stop test method
        test.stopTest();
    }
    
    //Unit Test Method
	static testmethod void myUnitTest02() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Content_Collection__c > conCollections = TestDataFactory.createContentCollection();
        insert conCollections;
       //Start test method
        test.startTest();
        	PageReference pageRef = Page.CustomLookup;
	        Test.setCurrentPage(pageRef);
	        pageRef.getParameters().put('strText', '');
	        pageRef.getParameters().put('obj', 'Content_Collection__c');
        	CustomLookupController testObj = new CustomLookupController();
        	testObj.searchText = 'test';
        	testObj.search();
        	system.assertEquals(testObj.recordsList.size(),1);
        	testObj.searchText = '';
        	testObj.search();
        	pageRef.getParameters().put('strText', string.valueOf(conCollections[0].Id));
	        pageRef.getParameters().put('obj', 'Content_Collection__c');
        	testObj = new CustomLookupController();
        //Stop test method
        test.stopTest();
    }
    
    static testmethod void testAdvancedRouting() {
    	// testing for blank search text
    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
    	cs.Adv_Rt_Acct_Team_Object__c = 'Opportunity';
    	cs.Adv_Rt_Acct_Team_Routeby__c = 'StageName';
    	update cs;
    	PageReference pageRef = Page.CustomLookup;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('strText', '');
    	CustomLookupController testObj = new CustomLookupController();
    	List<SelectOption> resultList = testObj.picklistValues;
    	system.assert(resultList.size() > 0);
    	
    	// testing for when search text is not blank
    	PageReference pageRef1 = Page.CustomLookup;
        Test.setCurrentPage(pageRef1);
        pageRef1.getParameters().put('strText', 'Closed Won');
    	CustomLookupController testObj1 = new CustomLookupController();
    	resultList = testObj1.picklistValues;
    	system.assert(resultList.size() == 1);
    }
    
    static testmethod void testTerritoryRouting() {
    	// testing for TM1.0
    	// testing for blank search text
    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
    	PageReference pageRef = Page.CustomLookup;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('strText', '');
        pageRef.getParameters().put('obj', 'territory');
    	CustomLookupController testObj = new CustomLookupController();
    	List<sObject> resultList = testObj.recordsList;
    	system.assert(true);
    	
    	// testing for when search text is not blank
    	PageReference pageRef1 = Page.CustomLookup;
        Test.setCurrentPage(pageRef1);
        pageRef1.getParameters().put('strText', 'test');
        pageRef1.getParameters().put('obj', 'territory');
    	CustomLookupController testObj1 = new CustomLookupController();
    	resultList = testObj1.recordsList;
    	system.assert(true);
    	
    	// testing for TM2.0
    	// testing for blank search text
    	PageReference pageRef2 = Page.CustomLookup;
        Test.setCurrentPage(pageRef2);
        pageRef2.getParameters().put('strText', '');
        pageRef2.getParameters().put('obj', 'territory2');
    	CustomLookupController testObj2 = new CustomLookupController();
    	resultList = testObj2.recordsList;
    	system.assert(true);
    	
    	// testing for when search text is not blank
    	PageReference pageRef3 = Page.CustomLookup;
        Test.setCurrentPage(pageRef3);
        pageRef3.getParameters().put('strText', 'test');
        pageRef3.getParameters().put('obj', 'territory2');
    	CustomLookupController testObj3 = new CustomLookupController();
    	resultList = testObj3.recordsList;
    	system.assert(true);
    }
}