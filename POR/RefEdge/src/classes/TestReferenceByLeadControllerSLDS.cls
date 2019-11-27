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
 * Description: test class for reference by lead page
 * Author: Gaurav Saini (8 June, 2017)
 * Last modified by: Gaurav Saini (8 June, 2017)
 */
@isTest
private class TestReferenceByLeadControllerSLDS {
	
	/**
	 * method to test constructor
	 * author: Gaurav Saini (8 June, 2017)
	 */
    public static testMethod void testConstructor() {
    	RefProspectorResponseController testProspectObj = new RefProspectorResponseController();
    	ReferenceByLeadControllerSLDS testRefByLeadObj = new ReferenceByLeadControllerSLDS(testProspectObj);
    	Account testAcc = new Account(Name = 'Test account 123');
    	insert testAcc;
    	Opportunity testOpp = new Opportunity(AccountId = testAcc.Id, Name = 'Test opportunity 123',
    											Amount = 1000, StageName = 'Prospecting', CloseDate = Date.today() + 2);
    	insert testOpp;
    	testOpp.StageName = 'Closed Won';
    	update testOpp;
    	String refLeadId = '';
    	String result;
    	List<Reference_Lead__c> testRefLead = TestDataFactory.createLeads();
    	testRefLead[0].Reference_Lead_Opportunity__c = testOpp.Id;
    	testRefLead[0].Reference_Lead_Account__c = testAcc.Id;
    	insert testRefLead;
    	Apexpages.currentPage().getParameters().put('Id', testRefLead[0].Id);
		ReferenceByLeadControllerSLDS testObj = new ReferenceByLeadControllerSLDS(new ApexPages.StandardController(testRefLead[0]));
		system.assertNotEquals(testObj.refLeadId, '');
    }
    
    /**
	 * method to test get reference lead wrapper method
	 * author: Gaurav Saini (8 June, 2017)
	 */
    public static testMethod void testGetRefLead() {
    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
    	String refLeadId = '';
    	String result;
    	List<Reference_Lead__c> testRefLead = TestDataFactory.createLeads();
    	insert testRefLead;
    	
    	if (testRefLead != null && testRefLead.size() > 0) {
    		refLeadId = testRefLead[0].Id;
    		result = ReferenceByLeadControllerSLDS.getRefLead(refLeadId);
    		List<ReferenceByLeadControllerSLDS.RefLeadWrapper> resultList
				= (List<ReferenceByLeadControllerSLDS.RefLeadWrapper>)JSON.deserialize(result, List<ReferenceByLeadControllerSLDS.RefLeadWrapper>.class);
    		system.assertEquals(resultList.size(), 1);
    	}
		result = ReferenceByLeadControllerSLDS.getRefLead('');
		system.assertEquals(result, '');
    }
    
    /**
	 * method to test method for checking account referenceability status
	 * author: Gaurav Saini (8 June, 2017)
	 */
    public static testMethod void testIsAccountReferenceable() {
    	Account testAcc = new Account(Name = 'Test account 123');
    	insert testAcc;
    	List<Account> accList = TestDataFactory.createAccounts();
    	insert accList;
    	List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accList);
    	Boolean result1 = ReferenceByLeadControllerSLDS.isAccountReferenceable(accList[0].Id);
    	system.assertEquals(result1, true);
    	Boolean result2 = ReferenceByLeadControllerSLDS.isAccountReferenceable(testAcc.Id);
    	system.assertEquals(result2, false);
    }
    
    /**
	 * method to test save ref lead method
	 * author: Gaurav Saini (8 June, 2017)
	 */
    public static testMethod void testSaveRefLead() {
    	TestDataFactory.createCustomNotifications();
        Custom_Settings__c cs = TestDataFactory.createCustomSetting();
    	cs.RLF_Reminder_Days__c = 2;
    	cs.No_Response_days__c = 3;
    	cs.Enable_Sales_Rewards_Notification__c = true;
    	update cs;
    	UtilityController.isNativeChatterSetting = true;
    	Account testAcc = new Account(Name = 'Test account 123');
    	insert testAcc;
    	Opportunity testOpp = new Opportunity(AccountId = testAcc.Id, Name = 'Test opportunity 123',
    											Amount = 1000, StageName = 'Prospecting', CloseDate = Date.today() + 2);
    	insert testOpp;
    	testOpp.StageName = 'Closed Won';
    	update testOpp;
    	String refLeadId = '';
    	String result;
    	List<Reference_Lead__c> testRefLead = TestDataFactory.createLeads();
    	testRefLead[0].Reference_Lead_Opportunity__c = testOpp.Id;
    	testRefLead[0].Reference_Lead_Account__c = testAcc.Id;
    	insert testRefLead;
    	Referenceability_Type__c refType = new Referenceability_Type__c(Name = 'test ref type', Sales_Reward__c = true, Sales_Point__c = 100, Referenceability_code__c = ConstantsController.RLF_REFERRED);
    	insert refType;
    	
    	if (testRefLead != null && testRefLead.size() > 0) {
    		refLeadId = testRefLead[0].Id;
    		String refLeadJson = ReferenceByLeadControllerSLDS.getRefLead(refLeadId);
    		List<ReferenceByLeadControllerSLDS.RefLeadWrapper> refLeadWrapperList
				= (List<ReferenceByLeadControllerSLDS.RefLeadWrapper>)JSON.deserialize(refLeadJson, List<ReferenceByLeadControllerSLDS.RefLeadWrapper>.class);
    		
    		if (refLeadWrapperList != null && refLeadWrapperList.size() > 0) {
    			// testing for "Check back with me later" option
    			Schema.DescribeFieldResult dfr
						= Schema.sObjectType.Reference_Lead__c.fields.getMap().get(UtilityController.appNamespace() + 'Follow_Up_Timeframe__c').getDescribe();
			    
			    for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
			        refLeadWrapperList[0].followUpTimeFrame = ple.getValue();
			    }
    			result = ReferenceByLeadControllerSLDS.saveRefLead(JSON.serialize(refLeadWrapperList[0]), false);
    			system.assert(result.startsWith('success'));
    			
    			// testing for "I'm not the right person to ask option" option
    			User testUser = TestDataFactory.createUser();
				insert testUser;
				system.debug('testUser-->' + testUser);
				system.debug('refLeadWrapperList-->' + refLeadWrapperList);
		        refLeadWrapperList[0].refLeadOwnerId = testUser.Id;
		        refLeadWrapperList[0].followUpTimeFrame = '';
		        system.debug('json-->' + JSON.serialize(refLeadWrapperList[0]));
    			result = ReferenceByLeadControllerSLDS.saveRefLead(JSON.serialize(refLeadWrapperList[0]), false);
    			system.assert(result.startsWith('success'));
    			String saveProspectResult = ReferenceByLeadControllerSLDS.saveRefLead(JSON.serialize(refLeadWrapperList[0]), true);
    			system.assert(saveProspectResult.startsWith('success'));
    		}
    	} else {
    		system.assert(true);
    	}
    }
}