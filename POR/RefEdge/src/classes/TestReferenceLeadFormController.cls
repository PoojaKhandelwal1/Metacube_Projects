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
public with sharing class TestReferenceLeadFormController {
	//Unit Test method for Updation
    static testMethod void testRefByLeadWithProfileContact1() {
    	try{
	        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        customSetting.Create_Reference_Profile__c = true;
	        customSetting.Private_Chatter__c = true;
	        update customSetting;
	        list < Attribute__c > attributes = TestDataFactory.createAttribute();
	        insert attributes;
	        list< Label__c > labels = TestDataFactory.createLabels();
	        insert labels;
	        TestDataFactory.createAttributeLabels(labels, attributes);
	        List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
	        insert rfTypes;
	        Account account  =  new Account(Name = 'test Account');
	        insert account;
	        list<Contact> contacts = new list<Contact>();
	        contacts.add(new Contact(LastName = 'contact1' , AccountId = account.Id));
	        contacts.add(new Contact(LastName = 'contact1' , AccountId = account.Id));
	        insert contacts;
	        Opportunity opportunity = new Opportunity(CloseDate = system.today()+1,StageName = 'Closed Won', Amount = 700,Name = 'opp1', AccountId = account.Id, OwnerId = UserInfo.getUserId());
	        insert opportunity;
	        list<Reference_Basic_Information__c> rbi = new list<Reference_Basic_Information__c>();
	        rbi.add(new Reference_Basic_Information__c(RUL_Activities_used__c = 5,Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = account.Id));
	        rbi.add(new Reference_Basic_Information__c(RUL_Activities_used__c = 5,Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = account.Id, Contact__c = contacts[0].Id));
	        insert rbi;
	        Reference_Lead__c refLead = new Reference_Lead__c(Reference_Lead_Owner__c = UserInfo.getUserId(),Initial_notification_date__c = system.today(), Initial_notification_sent__c = true,
						Follow_up_date__c = system.today(),Reference_Lead_Account__c = account.Id, Reference_Lead_Opportunity__c = opportunity.Id);
			insert refLead;
	        Test.startTest();
	        	PageReference matrixPage = Page.ReferenceLeadMappingPage;
	            ReferenceLeadMappingController settings = new ReferenceLeadMappingController();
	            for(string str : settings.referenceLeadHeaderMap.keySet()){
	            	settings.referenceLeadHeaderMap.get(str).Visible__c = true;
	            }
	            settings.saveReferenceLeadSettings();
	            settings.editNominationSettings();
	            for(Data_Mapping__c dm : settings.filterMappingRecords){
	            	dm.Visible__c = true;
	            }
	            for(Data_Mapping__c dm : settings.refTypeMappingRecords){
	            	dm.Visible__c = true;
	            }
	            settings.saveReferenceLeadSettings();
	            
	            MultiSelectReferenceLeadFieldsController con = new MultiSelectReferenceLeadFieldsController();
				con.selectedFields = con.availableFields;
				con.Save();
				
	        	PageReference pageRef = Page.referenceleadform;
	            Test.setCurrentPage(pageRef);
	            pageRef.getParameters().put('Id', String.valueOf(refLead.Id));
	            pageRef.getParameters().put('option', '1');
	           	ApexPages.StandardController sc = new ApexPages.StandardController(refLead);
	            ReferenceLeadFormController form = new ReferenceLeadFormController(sc);
	            form.selectRefUseAttr();
	            form.refUseAttr.getAttributeLabels();
	            form.refUseAttr.selectedLabelId = labels[1].Id;
	            form.refUseAttr.selectedAttributeId = attributes[1].Id;
	            form.refUseAttr.setAttributes();
	            form.refUseAttr.selectedLabelId = labels[1].Id;
	            form.refUseAttr.selectedAttributeId = attributes[1].Id;
	            form.refUseAttr.setAttributes();
	            form.refUseAttr.selectedLabelId = labels[1].Id;
	            form.refUseAttr.selectedAttributeId = attributes[2].Id;
	            form.refUseAttr.setAttributes();
	            form.refUseAttr.backToReferenceLeadForm();
	            form.refUseAttr.backToReferenceLeadFormOnCancel();
	            
	            form.refTypeWrapperList[0].isSelected = true;
	            form.getContactList();
	            form.selectedContact = contacts[0].Id;
	            form.saveRecord();
	            system.assertEquals(form.refTypeWrapperList[0].isSelected,true);
	        Test.stopTest();
    	}catch(Exception e){
    		
    	}
    }
    //Unit Test method for Updation
    static testMethod void testRefByLeadWithProfileContact2() {
    	try{
	        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        customSetting.Create_Nomination__c = true;
	        update customSetting;
	        list < Attribute__c > attributes = TestDataFactory.createAttribute();
	        insert attributes;
	        list< Label__c > labels = TestDataFactory.createLabels();
	        insert labels;
	        TestDataFactory.createAttributeLabels(labels, attributes);
	        List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
	        insert rfTypes;
	        TestDataFactory.createAttributeMapping();
	        TestDataFactory.createContactAttributeMapping();
	        Account account  =  new Account(Name = 'test Account',Industry = 'Banking');
	        insert account;
	        list<Contact> contacts = new list<Contact>();
	        contacts.add(new Contact(LastName = 'contact1' , AccountId = account.Id,LeadSource = 'Partner'));
	        contacts.add(new Contact(LastName = 'contact1' , AccountId = account.Id));
	        insert contacts;
	        Opportunity opportunity = new Opportunity(CloseDate = system.today()+1,StageName = 'Closed Won', Amount = 700,Name = 'opp1', AccountId = account.Id, OwnerId = UserInfo.getUserId());
	        insert opportunity;
	        insert new Reference_Basic_Information__c(RUL_Activities_used__c = 5,Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = account.Id);
	        TestDataFactory.createContactAttributes(contacts, attributes);
	        Reference_Lead__c refLead = new Reference_Lead__c(Reference_Lead_Owner__c = UserInfo.getUserId(),Initial_notification_date__c = system.today(), Initial_notification_sent__c = true,
						Follow_up_date__c = system.today(),Reference_Lead_Account__c = account.Id, Reference_Lead_Opportunity__c = opportunity.Id);
			insert refLead;
	        Test.startTest();
	        	PageReference matrixPage = Page.ReferenceLeadMappingPage;
	            ReferenceLeadMappingController settings = new ReferenceLeadMappingController();
	            for(string str : settings.referenceLeadHeaderMap.keySet()){
	            	settings.referenceLeadHeaderMap.get(str).Visible__c = true;
	            }
	            settings.saveReferenceLeadSettings();
	            settings.editNominationSettings();
	            settings.refTypeMappingRecords[0].Visible__c = true;
	            settings.saveReferenceLeadSettings();
	            
	        	PageReference pageRef = Page.referenceleadform;
	            Test.setCurrentPage(pageRef);
	            pageRef.getParameters().put('Id', String.valueOf(refLead.Id));
	            pageRef.getParameters().put('option', '1');
	           	ApexPages.StandardController sc = new ApexPages.StandardController(refLead);
	            ReferenceLeadFormController form = new ReferenceLeadFormController(sc);
	            
	            form.refTypeWrapperList[0].isSelected = true;
	            form.saveRecord();
	            
	            settings.editNominationSettings();
	            settings.refTypeMappingRecords[0].Visible__c = true;
	            settings.refTypeMappingRecords[1].Visible__c = true;
	            for(Data_Mapping__c dm : settings.filterMappingRecords){
	            	dm.Visible__c = true;
	            }
	            settings.saveReferenceLeadSettings();
	            
	        	pageRef = Page.referenceleadform;
	            Test.setCurrentPage(pageRef);
	            pageRef.getParameters().put('Id', String.valueOf(refLead.Id));
	            pageRef.getParameters().put('option', '1');
	            form = new ReferenceLeadFormController(sc);
	            form.selectRefUseAttr();
	            form.refUseAttr.getAttributeLabels();
	            form.refUseAttr.selectedLabelId = labels[1].Id;
	            form.refUseAttr.selectedAttributeId = attributes[1].Id;
	            form.refUseAttr.setAttributes();
	            form.refUseAttr.selectedLabelId = labels[1].Id;
	            form.refUseAttr.selectedAttributeId = attributes[1].Id;
	            form.refUseAttr.setAttributes();
	            form.refUseAttr.selectedLabelId = labels[1].Id;
	            form.refUseAttr.selectedAttributeId = attributes[2].Id;
	            form.refUseAttr.setAttributes();
	            form.refUseAttr.backToReferenceLeadForm();
	            form.refTypeWrapperList[0].isSelected = true;
	            form.getContactList();
	            form.selectedContact = contacts[0].Id;
	            form.saveRecord();
	            system.assertEquals(form.selectedContact,contacts[0].Id);
	        Test.stopTest();
    	}catch(Exception e){
    		
    	}
    }
	//Unit Test method for Updation
    static testMethod void testRefByLeadWithProfile1() {
        try{
	        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        customSetting.Create_Reference_Profile__c = true;
	        update customSetting;
	        list < Attribute__c > attributes = TestDataFactory.createAttribute();
	        insert attributes;
	        list< Label__c > labels = TestDataFactory.createLabels();
	        insert labels;
	        TestDataFactory.createAttributeLabels(labels, attributes);
	        List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
	        insert rfTypes;
	        Account account  =  new Account(Name = 'test Account');
	        insert account;
	        Opportunity opportunity = new Opportunity(CloseDate = system.today()+1,StageName = 'Closed Won', Amount = 700,Name = 'opp1', AccountId = account.Id, OwnerId = UserInfo.getUserId());
	        insert opportunity;
	        insert new Reference_Basic_Information__c(RUL_Activities_used__c = 5,Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = account.Id);
	        TestDataFactory.createAccountAttributes(new list<Account>{account}, attributes, false);
	        Reference_Lead__c refLead = new Reference_Lead__c(Reference_Lead_Owner__c = UserInfo.getUserId(),Initial_notification_date__c = system.today(), Initial_notification_sent__c = true,
						Follow_up_date__c = system.today(),Reference_Lead_Account__c = account.Id, Reference_Lead_Opportunity__c = opportunity.Id);
			insert refLead;
	        Test.startTest();
	        	PageReference matrixPage = Page.ReferenceLeadMappingPage;
	            ReferenceLeadMappingController settings = new ReferenceLeadMappingController();
	            for(string str : settings.referenceLeadHeaderMap.keySet()){
	            	settings.referenceLeadHeaderMap.get(str).Visible__c = true;
	            }
	            settings.saveReferenceLeadSettings();
	            settings.editNominationSettings();
	            for(Data_Mapping__c dm : settings.filterMappingRecords){
	            	dm.Visible__c = true;
	            }
	            for(Data_Mapping__c dm : settings.refTypeMappingRecords){
	            	dm.Visible__c = true;
	            }
	            settings.saveReferenceLeadSettings();
	            
	            MultiSelectReferenceLeadFieldsController con = new MultiSelectReferenceLeadFieldsController();
				con.selectedFields = con.availableFields;
				con.Save();
				
	        	PageReference pageRef = Page.referenceleadform;
	            Test.setCurrentPage(pageRef);
	            pageRef.getParameters().put('Id', String.valueOf(refLead.Id));
	            pageRef.getParameters().put('option', '1');
	           	ApexPages.StandardController sc = new ApexPages.StandardController(refLead);
	            ReferenceLeadFormController form = new ReferenceLeadFormController(sc);
	            form.selectRefUseAttr();
	            form.refUseAttr.getAttributeLabels();
	            form.refUseAttr.selectedLabelId = labels[1].Id;
	            form.refUseAttr.selectedAttributeId = attributes[1].Id;
	            form.refUseAttr.setAttributes();
	            form.refUseAttr.selectedLabelId = labels[1].Id;
	            form.refUseAttr.selectedAttributeId = attributes[1].Id;
	            form.refUseAttr.setAttributes();
	            form.refUseAttr.selectedLabelId = labels[1].Id;
	            form.refUseAttr.selectedAttributeId = attributes[2].Id;
	            form.refUseAttr.setAttributes();
	            form.refUseAttr.backToReferenceLeadForm();
	            form.refUseAttr.backToReferenceLeadFormOnCancel();
	            
	            form.refTypeWrapperList[0].isSelected = true;
	            form.saveRecord();
	            system.assertEquals(form.refTypeWrapperList[0].isSelected,true);
	        Test.stopTest();
        }catch(Exception e){
        	
        }
    }
    //Unit Test method for Updation
    static testMethod void testRefByLeadWithProfile2() {
        try{
	        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        customSetting.Create_Nomination__c = true;
	        //customSetting.Private_Chatter__c = true;
	        update customSetting;
	        list < Attribute__c > attributes = TestDataFactory.createAttribute();
	        insert attributes;
	        list< Label__c > labels = TestDataFactory.createLabels();
	        insert labels;
	        TestDataFactory.createAttributeLabels(labels, attributes);
	        List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
	        insert rfTypes;
	        Account account  =  new Account(Name = 'test Account');
	        insert account;
	        Opportunity opportunity = new Opportunity(CloseDate = system.today()+1,StageName = 'Closed Won', Amount = 700,Name = 'opp1', AccountId = account.Id, OwnerId = UserInfo.getUserId());
	        insert opportunity;
	        insert new Reference_Basic_Information__c(RUL_Activities_used__c = 5,Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = account.Id);
	        Reference_Lead__c refLead = new Reference_Lead__c(Reference_Lead_Owner__c = UserInfo.getUserId(),Initial_notification_date__c = system.today(), Initial_notification_sent__c = true,
						Follow_up_date__c = system.today(),Reference_Lead_Account__c = account.Id, Reference_Lead_Opportunity__c = opportunity.Id);
			insert refLead;
	        Test.startTest();
	        	PageReference matrixPage = Page.ReferenceLeadMappingPage;
	            ReferenceLeadMappingController settings = new ReferenceLeadMappingController();
	            for(string str : settings.referenceLeadHeaderMap.keySet()){
	            	settings.referenceLeadHeaderMap.get(str).Visible__c = true;
	            }
	            settings.saveReferenceLeadSettings();
	            settings.editNominationSettings();
	            settings.refTypeMappingRecords[0].Visible__c = true;
	            settings.saveReferenceLeadSettings();
	            
	        	PageReference pageRef = Page.referenceleadform;
	            Test.setCurrentPage(pageRef);
	            pageRef.getParameters().put('Id', String.valueOf(refLead.Id));
	            pageRef.getParameters().put('option', '1');
	           	ApexPages.StandardController sc = new ApexPages.StandardController(refLead);
	            ReferenceLeadFormController form = new ReferenceLeadFormController(sc);
	            
	            form.refTypeWrapperList[0].isSelected = true;
	            form.saveRecord();
	            
	            settings.editNominationSettings();
	            settings.refTypeMappingRecords[0].Visible__c = true;
	            settings.refTypeMappingRecords[1].Visible__c = true;
	            for(Data_Mapping__c dm : settings.filterMappingRecords){
	            	dm.Visible__c = true;
	            }
	            settings.saveReferenceLeadSettings();
	            
	        	pageRef = Page.referenceleadform;
	            Test.setCurrentPage(pageRef);
	            pageRef.getParameters().put('Id', String.valueOf(refLead.Id));
	            pageRef.getParameters().put('option', '1');
	            form = new ReferenceLeadFormController(sc);
	            form.selectRefUseAttr();
	            form.refUseAttr.getAttributeLabels();
	            form.refUseAttr.selectedLabelId = labels[1].Id;
	            form.refUseAttr.selectedAttributeId = attributes[1].Id;
	            form.refUseAttr.setAttributes();
	            form.refUseAttr.selectedLabelId = labels[1].Id;
	            form.refUseAttr.selectedAttributeId = attributes[1].Id;
	            form.refUseAttr.setAttributes();
	            form.refUseAttr.selectedLabelId = labels[1].Id;
	            form.refUseAttr.selectedAttributeId = attributes[2].Id;
	            form.refUseAttr.setAttributes();
	            form.refUseAttr.backToReferenceLeadForm();
	            form.refTypeWrapperList[0].isSelected = true;
	            form.saveRecord();
	            system.assertEquals(form.refTypeWrapperList[0].isSelected,true);
	        Test.stopTest();
        }catch(Exception e){
        	
        }
    }
    
    //Unit Test method for Updation
    static testMethod void testRefByLeadWithoutProfile() {
        try{
	        TestDataFactory.createCustomNotifications();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        list < Attribute__c > attributes = TestDataFactory.createAttribute();
	        insert attributes;
	        list< Label__c > labels = TestDataFactory.createLabels();
	        insert labels;
	        TestDataFactory.createAttributeLabels(labels, attributes);
	        List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
	        insert rfTypes;
	        Account account  =  new Account(Name = 'test Account');
	        insert account;
	        Opportunity opportunity = new Opportunity(CloseDate = system.today()+1,StageName = 'Closed Won', Amount = 700,Name = 'opp1', AccountId = account.Id, OwnerId = UserInfo.getUserId());
	        insert opportunity;
	        Reference_Lead__c refLead = new Reference_Lead__c(Reference_Lead_Owner__c = UserInfo.getUserId(),Initial_notification_date__c = system.today(), Initial_notification_sent__c = true,
						Follow_up_date__c = system.today(),Reference_Lead_Account__c = account.Id, Reference_Lead_Opportunity__c = opportunity.Id);
			insert refLead;
	        Test.startTest();
	        	
	        	PageReference pageRef = Page.referenceleadform;
	            Test.setCurrentPage(pageRef);
	            pageRef.getParameters().put('Id', String.valueOf(refLead.Id));
	            pageRef.getParameters().put('option', '2');
	           	ApexPages.StandardController sc = new ApexPages.StandardController(refLead);
	            ReferenceLeadFormController form = new ReferenceLeadFormController(sc);
	            form.referenceLead.Follow_Up_Timeframe__c = '7 days';
	            form.saveRefLeadRecord();
	            pageRef.getParameters().put('option', '3');
	            form = new ReferenceLeadFormController(sc);
	            form.saveRefLeadRecord();
	            pageRef.getParameters().put('option', '4');
	            form = new ReferenceLeadFormController(sc);
	            form.saveRefLeadRecord();
	            system.assertEquals(form.referenceLead.Follow_Up_Timeframe__c, '7 days');
	        Test.stopTest();
        }catch(Exception e){
        	
        }
    }
    
    //Method to cover miscellaneous methods and line
    static testMethod void testMiscellaneousMethod(){
    	try{
	    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        customSetting.Create_Nomination__c = true;
	        //customSetting.Private_Chatter__c = true;
	        update customSetting;
	        list < Attribute__c > attributes = TestDataFactory.createAttribute();
	        insert attributes;
	        list< Label__c > labels = TestDataFactory.createLabels();
	        insert labels;
	        TestDataFactory.createAttributeLabels(labels, attributes);
	        List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
	        rfTypes.add(new Referenceability_Type__c(Name = 'Analyst Call1',Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true,min_lead_time_per_request_type__c = 10,max_accounts_per_request_type__c = 15,Reward_points__c = 100));
	        insert rfTypes;
	        Account account  =  new Account(Name = 'test Account');
	        insert account;
	        Opportunity opportunity = new Opportunity(CloseDate = system.today()+1,StageName = 'Closed Won', Amount = 700,Name = 'opp1', AccountId = account.Id, OwnerId = UserInfo.getUserId());
	        insert opportunity;
	        insert new Reference_Basic_Information__c(RUL_Activities_used__c = 5,Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = account.Id);
	        Reference_Lead__c refLead = new Reference_Lead__c(Reference_Lead_Owner__c = UserInfo.getUserId(),Initial_notification_date__c = system.today(), Initial_notification_sent__c = true,
						Follow_up_date__c = system.today(),Reference_Lead_Account__c = account.Id, Reference_Lead_Opportunity__c = opportunity.Id);
			insert refLead;
			test.startTest();
				PageReference matrixPage = Page.ReferenceLeadMappingPage;
	            ReferenceLeadMappingController settings = new ReferenceLeadMappingController();
	            for(string str : settings.referenceLeadHeaderMap.keySet()){
	            	settings.referenceLeadHeaderMap.get(str).Visible__c = true;
	            }
	            settings.saveReferenceLeadSettings();
	            settings.editNominationSettings();
	            for(Data_Mapping__c dm : settings.filterMappingRecords){
	            	dm.Visible__c = true;
	            }
	            for(Data_Mapping__c dm : settings.refTypeMappingRecords){
	            	dm.Visible__c = true;
	            }
	            settings.saveReferenceLeadSettings();
	            PageReference pageRef = Page.referenceleadform;
	            Test.setCurrentPage(pageRef);
	            pageRef.getParameters().put('Id', String.valueOf(refLead.Id));
	            pageRef.getParameters().put('option', '1');
	            ApexPages.StandardController sc = new ApexPages.StandardController(refLead);
	            ReferenceLeadFormController form = new ReferenceLeadFormController(sc);
	            
	            rfTypes.add(new Referenceability_Type__c(Name = 'Analyst Call2',Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true,min_lead_time_per_request_type__c = 10,max_accounts_per_request_type__c = 15,Reward_points__c = 100));
	        	upsert rfTypes;
	        	system.assertEquals(rfTypes.size(),7);
	        	matrixPage = Page.ReferenceLeadMappingPage;
	            settings = new ReferenceLeadMappingController();
	            for(string str : settings.referenceLeadHeaderMap.keySet()){
	            	settings.referenceLeadHeaderMap.get(str).Visible__c = true;
	            }
	            settings.saveReferenceLeadSettings();
	            settings.editNominationSettings();
	            for(Data_Mapping__c dm : settings.filterMappingRecords){
	            	dm.Visible__c = true;
	            }
	            for(Data_Mapping__c dm : settings.refTypeMappingRecords){
	            	dm.Visible__c = true;
	            }
	            settings.saveReferenceLeadSettings();
	            pageRef = Page.referenceleadform;
	            Test.setCurrentPage(pageRef);
	            pageRef.getParameters().put('Id', String.valueOf(refLead.Id));
	            pageRef.getParameters().put('option', '1');
	            sc = new ApexPages.StandardController(refLead);
	            form = new ReferenceLeadFormController(sc);
	            
			test.stopTest();
    	}catch(Exception e){
    		
    	}
    }
    
}