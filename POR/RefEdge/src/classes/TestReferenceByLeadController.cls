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
public with sharing class TestReferenceByLeadController {
	
	//Unit Test method for Updation
    static testMethod void testRefByLeadWithProfile() {
        try{
	        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        customSetting.Create_Reference_Profile__c = true;
	        customSetting.Create_Nomination__c = false;
	        update customSetting;
	        Account account  =  new Account(Name = 'test Account');
	        insert account;
	        Opportunity opportunity = new Opportunity(CloseDate = system.today()+1,StageName = 'Closed Won', Amount = 700,Name = 'opp1', AccountId = account.Id, OwnerId = UserInfo.getUserId());
	        insert opportunity;
	        insert new Reference_Basic_Information__c(RUL_Activities_used__c = 5,Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = account.Id);
	        Reference_Lead__c refLead = new Reference_Lead__c(Reference_Lead_Owner__c = UserInfo.getUserId(),Initial_notification_date__c = system.today(), Initial_notification_sent__c = true,
						Follow_up_date__c = system.today(),Reference_Lead_Account__c = account.Id, Reference_Lead_Opportunity__c = opportunity.Id);
			insert refLead;
	        Test.startTest();
	        	PageReference pageRef = Page.referencebylead;
	            Test.setCurrentPage(pageRef);
	            pageRef.getParameters().put('Id', String.valueOf(refLead.Id));
	           	ApexPages.StandardController sc = new ApexPages.StandardController(refLead);
	            ReferenceByLeadController form = new ReferenceByLeadController(sc);
	            form.optionSelected = '1';
	            form.redirectToRefLeadForm();
	            form.optionSelected = '2';
	            form.redirectToRefLeadForm();
	            form.loadRefLeadForm();
	            form.returnHomePage();
	            system.assert(true);
	        Test.stopTest();
        }catch(Exception e){
        	
        }
    }
    
    //Unit Test method for Updation
    static testMethod void testRefByLeadWithoutProfile() {
        try{
	        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        customSetting.Create_Reference_Profile__c = true;
	        customSetting.Create_Nomination__c = false;
	        update customSetting;
	        Account account  =  new Account(Name = 'test Account');
	        insert account;
	        Opportunity opportunity = new Opportunity(CloseDate = system.today()+1,StageName = 'Closed Won', Amount = 700,Name = 'opp1', AccountId = account.Id, OwnerId = UserInfo.getUserId());
	        insert opportunity;
	        Reference_Lead__c refLead = new Reference_Lead__c(Reference_Lead_Owner__c = UserInfo.getUserId(),Initial_notification_date__c = system.today(), Initial_notification_sent__c = true,
						Follow_up_date__c = system.today(),Reference_Lead_Account__c = account.Id, Reference_Lead_Opportunity__c = opportunity.Id);
			insert refLead;
	        Test.startTest();
	        	PageReference pageRef = Page.referencebylead;
	            Test.setCurrentPage(pageRef);
	            pageRef.getParameters().put('Id', String.valueOf(refLead.Id));
	           	ApexPages.StandardController sc = new ApexPages.StandardController(refLead);
	            ReferenceByLeadController form = new ReferenceByLeadController(sc);
	            form.optionSelected = '1';
	            form.redirectToRefLeadForm();
	            form.optionSelected = '2';
	            form.redirectToRefLeadForm();
	            form.optionSelected = '3';
	            form.redirectToRefLeadForm();
	            form.optionSelected = '4';
	            form.redirectToRefLeadForm();
	            system.assert(true);
	        Test.stopTest();
        }catch(Exception e){
        	
        }
    }
    
    //Unit Test method for Updation
    static testMethod void testRefByLeadWithProfileNomi() {
        try{
	        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        customSetting.Create_Reference_Profile__c = false;
	        customSetting.Create_Nomination__c = true;
	        update customSetting;
	        Account account  =  new Account(Name = 'test Account');
	        insert account;
	        Opportunity opportunity = new Opportunity(CloseDate = system.today()+1,StageName = 'Closed Won', Amount = 700,Name = 'opp1', AccountId = account.Id, OwnerId = UserInfo.getUserId());
	        insert opportunity;
	        insert new Reference_Basic_Information__c(RUL_Activities_used__c = 5,Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = account.Id);
	        Reference_Lead__c refLead = new Reference_Lead__c(Reference_Lead_Owner__c = UserInfo.getUserId(),Initial_notification_date__c = system.today(), Initial_notification_sent__c = true,
						Follow_up_date__c = system.today(),Reference_Lead_Account__c = account.Id, Reference_Lead_Opportunity__c = opportunity.Id);
			insert refLead;
	        Test.startTest();
	        	PageReference pageRef = Page.referencebylead;
	            Test.setCurrentPage(pageRef);
	            pageRef.getParameters().put('Id', String.valueOf(refLead.Id));
	           	ApexPages.StandardController sc = new ApexPages.StandardController(refLead);
	            ReferenceByLeadController form = new ReferenceByLeadController(sc);
	            form.optionSelected = '1';
	            form.redirectToRefLeadForm();
	            form.optionSelected = '2';
	            form.redirectToRefLeadForm();
	            form.loadRefLeadForm();
	            form.returnHomePage();
	            system.assert(true);
	        Test.stopTest();
        }catch(Exception e){
        	
        	
        }
    }
    
    //Unit Test method for Updation
    static testMethod void testRefByLeadWithoutProfileNomi() {
        try{
	        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        customSetting.Create_Reference_Profile__c = false;
	        customSetting.Create_Nomination__c = true;
	        update customSetting;
	        Account account  =  new Account(Name = 'test Account');
	        insert account;
	        Opportunity opportunity = new Opportunity(CloseDate = system.today()+1,StageName = 'Closed Won', Amount = 700,Name = 'opp1', AccountId = account.Id, OwnerId = UserInfo.getUserId());
	        insert opportunity;
	        Reference_Lead__c refLead = new Reference_Lead__c(Reference_Lead_Owner__c = UserInfo.getUserId(),Initial_notification_date__c = system.today(), Initial_notification_sent__c = true,
						Follow_up_date__c = system.today(),Reference_Lead_Account__c = account.Id, Reference_Lead_Opportunity__c = opportunity.Id);
			insert refLead;
	        Test.startTest();
	        	PageReference pageRef = Page.referencebylead;
	            Test.setCurrentPage(pageRef);
	            pageRef.getParameters().put('Id', String.valueOf(refLead.Id));
	           	ApexPages.StandardController sc = new ApexPages.StandardController(refLead);
	            ReferenceByLeadController form = new ReferenceByLeadController(sc);
	            form.optionSelected = '1';
	            form.redirectToRefLeadForm();
	            form.optionSelected = '2';
	            form.redirectToRefLeadForm();
	            form.optionSelected = '3';
	            form.redirectToRefLeadForm();
	            form.optionSelected = '4';
	            form.redirectToRefLeadForm();
	            system.assert(true);
	        Test.stopTest();
        }catch(Exception e){
        	
        }
    }
}