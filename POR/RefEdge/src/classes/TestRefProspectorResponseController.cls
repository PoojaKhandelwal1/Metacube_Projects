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
 * Description: test class for RefProspectorResponseController
 * Author: Gaurav Saini (21 Nov, 2017)
 */
@isTest(seeAllData = false)
public with sharing class TestRefProspectorResponseController {
    
    /**
     * method to test getCustomSettings method
     * author: Gaurav Saini (21 Nov, 2017)
     */
    public static testmethod void testGetCustomSettings() {
    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
    	String result = RefProspectorResponseController.getCustomSettings();
    	system.assert(result != null);
    }
    
    /**
     * method to test getRefLeads method
     * author: Gaurav Saini (21 Nov, 2017)
     */
    public static testmethod void testGetRefLeads() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Lead__c> refLeads = new List<Reference_Lead__c>();
    	
    	for (Account acc : accounts) {
	    	Reference_Lead__c tempRefLead = new Reference_Lead__c();
			tempRefLead.Reference_Lead_Account__c = acc.Id;
			tempRefLead.Reference_Lead_Status__c = 'Initial Notification Sent';
			tempRefLead.Initial_Notification_Sent__c = true;
			tempRefLead.Ref_Lead_Include_in_Campaign__c = true;
			acc.OwnerId = UserInfo.getUserId();
			tempRefLead.Reference_Lead_Owner__c = UserInfo.getUserId();
			refLeads.add(tempRefLead);
    	}
    	insert refLeads;
    	
    	Test.startTest();
	    	String refLeadWrapperListJSON = RefProspectorResponseController.getRefLeads();
	    	List<RefProspectorResponseController.RefLeadWrapper> refLeadWrapperList = (List<RefProspectorResponseController.RefLeadWrapper>)JSON.deserialize(refLeadWrapperListJSON, List<RefProspectorResponseController.RefLeadWrapper>.class);
	    	system.assert(refLeadWrapperList.size() == 4);
	    	// testing with account RBIs created
	    	TestDataFactory.setUpAccountRBI(accounts);
	    	String refLeadWrapperListJSON1 = RefProspectorResponseController.getRefLeads();
	    	List<RefProspectorResponseController.RefLeadWrapper> refLeadWrapperList1 = (List<RefProspectorResponseController.RefLeadWrapper>)JSON.deserialize(refLeadWrapperListJSON1, List<RefProspectorResponseController.RefLeadWrapper>.class);
	    	system.assert(refLeadWrapperList1.size() == 4);
    	Test.stopTest();
    }
    
    /**
     * method to test getRefLeadsForPageNo method
     * author: Gaurav Saini (21 Nov, 2017)
     */
    public static testmethod void testGetRefLeadsForPageNo() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Lead__c> refLeads = new List<Reference_Lead__c>();
    	
    	for (Account acc : accounts) {
	    	Reference_Lead__c tempRefLead = new Reference_Lead__c();
			tempRefLead.Reference_Lead_Account__c = acc.Id;
			tempRefLead.Reference_Lead_Status__c = 'Initial Notification Sent';
			tempRefLead.Initial_Notification_Sent__c = true;
			tempRefLead.Ref_Lead_Include_in_Campaign__c = true;
			acc.OwnerId = UserInfo.getUserId();
			tempRefLead.Reference_Lead_Owner__c = UserInfo.getUserId();
			refLeads.add(tempRefLead);
    	}
    	insert refLeads;
    	
    	Test.startTest();
	    	String refLeadWrapperListJSON = RefProspectorResponseController.getRefLeadsForPageNo(0);
	    	List<RefProspectorResponseController.RefLeadWrapper> refLeadWrapperList = (List<RefProspectorResponseController.RefLeadWrapper>)JSON.deserialize(refLeadWrapperListJSON, List<RefProspectorResponseController.RefLeadWrapper>.class);
	    	system.assert(refLeadWrapperList.size() == 6);
	    	// testing with account RBIs created
	    	TestDataFactory.setUpAccountRBI(accounts);
	    	String refLeadWrapperListJSON1 = RefProspectorResponseController.getRefLeadsForPageNo(0);
	    	List<RefProspectorResponseController.RefLeadWrapper> refLeadWrapperList1 = (List<RefProspectorResponseController.RefLeadWrapper>)JSON.deserialize(refLeadWrapperListJSON1, List<RefProspectorResponseController.RefLeadWrapper>.class);
	    	system.assert(refLeadWrapperList1.size() == 6);
    	Test.stopTest();
    }
    
    /**
     * method to test getAlreadyPresentRefLeads method
     * author: Gaurav Saini (21 Nov, 2017)
     */
    public static testmethod void testGetAlreadyPresentRefLeads() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Lead__c> refLeads = new List<Reference_Lead__c>();
    	List<String> refLeadIds = new List<String>();
    	
    	for (Account acc : accounts) {
	    	Reference_Lead__c tempRefLead = new Reference_Lead__c();
			tempRefLead.Reference_Lead_Account__c = acc.Id;
			tempRefLead.Reference_Lead_Status__c = 'Initial Notification Sent';
			tempRefLead.Initial_Notification_Sent__c = true;
			tempRefLead.Ref_Lead_Include_in_Campaign__c = true;
			acc.OwnerId = UserInfo.getUserId();
			tempRefLead.Reference_Lead_Owner__c = UserInfo.getUserId();
			refLeads.add(tempRefLead);
    	}
    	insert refLeads;
    	
    	for (Reference_Lead__c rl : refLeads) {
    		refLeadIds.add(rl.Id);
    	}
    	
    	Test.startTest();
	    	String refLeadWrapperListJSON = RefProspectorResponseController.getAlreadyPresentRefLeads(JSON.serialize(refLeadIds));
	    	List<RefProspectorResponseController.RefLeadWrapper> refLeadWrapperList = (List<RefProspectorResponseController.RefLeadWrapper>)JSON.deserialize(refLeadWrapperListJSON, List<RefProspectorResponseController.RefLeadWrapper>.class);
	    	system.assert(refLeadWrapperList.size() == 6);
	    	// testing with account RBIs created
	    	TestDataFactory.setUpAccountRBI(accounts);
	    	String refLeadWrapperListJSON1 = RefProspectorResponseController.getAlreadyPresentRefLeads(JSON.serialize(refLeadIds));
	    	List<RefProspectorResponseController.RefLeadWrapper> refLeadWrapperList1 = (List<RefProspectorResponseController.RefLeadWrapper>)JSON.deserialize(refLeadWrapperListJSON1, List<RefProspectorResponseController.RefLeadWrapper>.class);
	    	system.assert(refLeadWrapperList1.size() == 6);
    	Test.stopTest();
    }
    
    /**
     * method to test getAlreadyNotPresentRefLeads method
     * author: Gaurav Saini (21 Nov, 2017)
     */
    public static testmethod void testGetAlreadyNotPresentRefLeads() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Lead__c> refLeads = new List<Reference_Lead__c>();
    	List<String> refLeadIds = new List<String>();
    	
    	for (Account acc : accounts) {
	    	Reference_Lead__c tempRefLead = new Reference_Lead__c();
			tempRefLead.Reference_Lead_Account__c = acc.Id;
			tempRefLead.Reference_Lead_Status__c = 'Initial Notification Sent';
			tempRefLead.Initial_Notification_Sent__c = true;
			tempRefLead.Ref_Lead_Include_in_Campaign__c = true;
			acc.OwnerId = UserInfo.getUserId();
			tempRefLead.Reference_Lead_Owner__c = UserInfo.getUserId();
			refLeads.add(tempRefLead);
    	}
    	insert refLeads;
    	
    	Test.startTest();
	    	String refLeadWrapperListJSON = RefProspectorResponseController.getAlreadyNotPresentRefLeads(JSON.serialize(refLeadIds));
	    	List<RefProspectorResponseController.RefLeadWrapper> refLeadWrapperList = (List<RefProspectorResponseController.RefLeadWrapper>)JSON.deserialize(refLeadWrapperListJSON, List<RefProspectorResponseController.RefLeadWrapper>.class);
	    	system.assert(refLeadWrapperList.size() == 6);
	    	// testing with account RBIs created
	    	TestDataFactory.setUpAccountRBI(accounts);
	    	String refLeadWrapperListJSON1 = RefProspectorResponseController.getAlreadyNotPresentRefLeads(JSON.serialize(refLeadIds));
	    	List<RefProspectorResponseController.RefLeadWrapper> refLeadWrapperList1 = (List<RefProspectorResponseController.RefLeadWrapper>)JSON.deserialize(refLeadWrapperListJSON1, List<RefProspectorResponseController.RefLeadWrapper>.class);
	    	system.assert(refLeadWrapperList1.size() == 6);
    	Test.stopTest();
    }
    
    /**
     * method to test getRefLead method
     * author: Gaurav Saini (21 Nov, 2017)
     */
    public static testmethod void testGetRefLead() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Reference_Lead__c> refLeads = new List<Reference_Lead__c>();
    	
    	for (Account acc : accounts) {
	    	Reference_Lead__c tempRefLead = new Reference_Lead__c();
			tempRefLead.Reference_Lead_Account__c = acc.Id;
			tempRefLead.Reference_Lead_Status__c = 'Initial Notification Sent';
			tempRefLead.Initial_Notification_Sent__c = true;
			tempRefLead.Ref_Lead_Include_in_Campaign__c = true;
			acc.OwnerId = UserInfo.getUserId();
			tempRefLead.Reference_Lead_Owner__c = UserInfo.getUserId();
			refLeads.add(tempRefLead);
    	}
    	insert refLeads;
    	String refLeadJSON = RefProspectorResponseController.getRefLead(refLeads[0].Id);
    	system.assert(refLeadJSON != null);
    }
    
    /**
     * method to test getDateFormat method
     * author: Gaurav Saini (21 Nov, 2017)
     */
    public static testmethod void testGetDateFormat() {
    	String dateFormat = RefProspectorResponseController.getDateFormat();
    	system.assert(dateFormat != null);
    }
    
    /**
     * method to test getFollowUpDaysList method
     * author: Gaurav Saini (21 Nov, 2017)
     */
    public static testmethod void testGetFollowUpDaysList() {
    	String followUpDaysListJSON = RefProspectorResponseController.getFollowUpDaysList();
    	system.assert(followUpDaysListJSON != null);
    }
}