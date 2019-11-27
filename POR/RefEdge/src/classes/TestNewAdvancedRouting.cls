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
@isTest
private class TestNewAdvancedRouting {

    static testMethod void myUnitTest() {
    	
    	// setting up test data
    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
    	cs.Adv_Rt_Acct_Team_Object__c = 'Opportunity';
    	cs.Adv_Rt_Acct_Team_Routeby__c = 'StageName';
    	update cs;
    	
    	List<Attribute__c> attributeList = TestDataFactory.createAttribute();
    	insert attributeList;
    	
    	List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attributeList, 1, 2);
        insert childAttList;
    	
    	List<Advanced_Routing__c> advRoutingList = new List<Advanced_Routing__c>();
    	advRoutingList.add(new Advanced_Routing__c());
    	advRoutingList.add(new Advanced_Routing__c(Adv_Routing_Name__c = 'Test AR', Adv_Routing_Attribute__c = childAttList[1].Id));
    	insert advRoutingList;
    	
    	advRoutingList[0].Adv_Routing_Name__c = 'Test AR';
    	advRoutingList[0].Adv_Routing_Attribute__c = childAttList[0].Id;
    	advRoutingList[0].Territory_Name__c = 'test';
    	advRoutingList[0].Territory_Id__c = 'test';
    	update advRoutingList;
    	
    	// start test method
    	Test.startTest();
	        Test.setCurrentPage(Page.NewAdvancedRouting);
	        // calling the constructor
	        NewAdvancedRoutingController testObj
	        			= new NewAdvancedRoutingController(new ApexPages.StandardController(advRoutingList[0]));
        	
        	// calling save method - case 1: both territory Id and name are not blank
        	testObj.selectedTerritoryId = 'test val 1';
        	testObj.selectedTerritoryName = 'test val 2';
        	PageReference saveResult = testObj.Save();
        	system.assertEquals(null, saveResult);
        	
        	// calling save method - case 2: both territory Id and name are blank
        	testObj.selectedTerritoryId = '';
        	testObj.selectedTerritoryName = '';
        	saveResult = testObj.Save();
        	system.assertEquals('/' + testObj.advRouting.Id, saveResult.getUrl());
        	
        	// calling save method - case 3: only territory Id is blank
        	testObj.selectedTerritoryId = '';
        	testObj.selectedTerritoryName = 'test';
        	saveResult = testObj.Save();
        	system.assertEquals(null, saveResult);
        	
        	// calling save method - case 4: only territory name is blank
        	testObj.selectedTerritoryId = 'test';
        	testObj.selectedTerritoryName = '';
        	saveResult = testObj.Save();
        	system.assertEquals(null, saveResult);
        	
        	// calling save method - case 5: advanced routing object is null
        	testObj.advRouting = null;
        	testObj.selectedTerritoryId = 'test';
        	testObj.selectedTerritoryName = 'test';
        	saveResult = testObj.Save();
        	system.assertEquals(null, saveResult);
        	
        // stop test method
        Test.stopTest();
    }
}