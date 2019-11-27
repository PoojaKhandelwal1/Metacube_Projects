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
 * Description: test class for LaunchRefProspectorCampaignController
 * Author: Gaurav Saini (21 Nov, 2017)
 */
@isTest(seeAllData = false)
public with sharing class TestLaunchRefProspectorCampaignCtrl {
    
    /**
     * method to test constructor
     * author: Gaurav Saini (21 Nov, 2017)
     */
    public static testmethod void testConstructor() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Lead__c> refLeads = new List<Reference_Lead__c>();
    	
    	for (Account acc : accounts) {
	    	Reference_Lead__c tempRefLead = new Reference_Lead__c();
			tempRefLead.Reference_Lead_Account__c = acc.Id;
			tempRefLead.Reference_Lead_Status__c = 'Request Pending';
			tempRefLead.Ref_Lead_Include_in_Campaign__c = true;
			tempRefLead.Reference_Lead_Owner__c = acc.OwnerId;
			refLeads.add(tempRefLead);
    	}
    	insert refLeads;
    	
    	Test.startTest();
			Test.setCurrentPage(Page.LaunchRefProspectorCampaignPage);
			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(refLeads);
			stdSetController.setSelected(refLeads);
			LaunchRefProspectorCampaignController testObj = new LaunchRefProspectorCampaignController(stdSetController);
			system.assert(testObj.refLeadListViewId != null);
			String permissionMsg = LaunchRefProspectorCampaignController.getPermissionsMessage();
		Test.stopTest();
    }
    
    /**
     * method to test getCustomSettings
     * author: Gaurav Saini (21 Nov, 2017)
     */
	public static testmethod void testGetCustomSettings() {
		Custom_Settings__c cs = TestDataFactory.createCustomSetting();
		
		Test.startTest();
			String csWrapperJSON = LaunchRefProspectorCampaignController.getCustomSettings();
			system.assert(csWrapperJSON != null);
		Test.stopTest();
	}
	
	/**
     * method to test launchCampaign
     * author: Gaurav Saini (21 Nov, 2017)
     */
	public static testmethod void testLaunchCampaign() {
		List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Lead__c> refLeads = new List<Reference_Lead__c>();
    	
    	for (Account acc : accounts) {
	    	Reference_Lead__c tempRefLead = new Reference_Lead__c();
			tempRefLead.Reference_Lead_Account__c = acc.Id;
			tempRefLead.Reference_Lead_Status__c = 'Request Pending';
			tempRefLead.Ref_Lead_Include_in_Campaign__c = true;
			acc.OwnerId = UserInfo.getUserId();
			tempRefLead.Reference_Lead_Owner__c = UserInfo.getUserId();
			refLeads.add(tempRefLead);
    	}
    	insert refLeads;
    	update accounts;
		
		Test.startTest();
	    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
			String csWrapperJSON = LaunchRefProspectorCampaignController.getCustomSettings();
			String launchResult = LaunchRefProspectorCampaignController.launchCampaign(csWrapperJSON);
			system.assert(launchResult.startsWith('success'), launchResult);
			launchResult = LaunchRefProspectorCampaignController.launchCampaign('test');
			system.assert(!launchResult.startsWith('success'), launchResult);
		Test.stopTest();
	}
	
	/**
     * method to test launchCampaign
     * author: Gaurav Saini (21 Nov, 2017)
     */
	public static testmethod void testLaunchCampaign1() {
		List<Account> accounts = new List<Account>();
		accounts.add(new Account(Name = 'Test account'));
    	insert accounts;
    	List<Reference_Lead__c> refLeads = new List<Reference_Lead__c>();
    	
    	for (Account acc : accounts) {
	    	Reference_Lead__c tempRefLead = new Reference_Lead__c();
			tempRefLead.Reference_Lead_Account__c = acc.Id;
			tempRefLead.Reference_Lead_Status__c = 'Request Pending';
			tempRefLead.Ref_Lead_Include_in_Campaign__c = true;
			acc.OwnerId = UserInfo.getUserId();
			tempRefLead.Reference_Lead_Owner__c = UserInfo.getUserId();
			refLeads.add(tempRefLead);
    	}
    	insert refLeads;
    	update accounts;
		
		Test.startTest();
	    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
			String csWrapperJSON = LaunchRefProspectorCampaignController.getCustomSettings();
			String launchResult = LaunchRefProspectorCampaignController.launchCampaign(csWrapperJSON);
			system.assert(launchResult.startsWith('success'), launchResult);
			launchResult = LaunchRefProspectorCampaignController.launchCampaign('test');
			system.assert(!launchResult.startsWith('success'), launchResult);
		Test.stopTest();
	}
}