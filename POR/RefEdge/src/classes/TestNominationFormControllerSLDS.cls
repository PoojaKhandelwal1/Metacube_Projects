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
* Class: NominationFormControllerSLDS
* Description : class to test and cover NominationFormControllerSLDS 
* Modified by: Rekha Jangir @29 May 2017
*/
@isTest(seeAllData = false)
public with sharing class TestNominationFormControllerSLDS {
    /*
     * Method to cover methods when nominate any account
     * Modified By: Rekha Jangir @29 May 2017 
     */
    static testMethod void nominateAccount() {
    	RefProspectorResponseController testProspectObj = new RefProspectorResponseController();
    	NominationFormControllerSLDS testNominationObj = new NominationFormControllerSLDS(testProspectObj);
    	//insert test data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Attribute_Mapping__c> attMappingList = TestDataFactory.createAttributeMapping();
        List<Attribute_Mapping__c> attMappingList1 = TestDataFactory.createContactAttributeMapping();
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        List<Label__c> labels = TestDataFactory.createLabels();
        
        //Set visible to true for all filters, they can available in nomination form
        for (Label__c label : labels) {
            label.Visible__c = true;
        }
        insert labels;
        
        TestDataFactory.createAttributeLabels(labels, attributes);
        List<Referenceability_Type__c> rfTypes = TestDataFactory.createReferenceabilityType();
        
        for (Referenceability_Type__c ref : rfTypes) {
            ref.Visible__c = true;
        }
        insert rfTypes;
        Account account = new Account(Name = 'test account', Industry = 'Banking');
        insert account;
        Contact contact = new Contact (lastName = 'test Contact', AccountId = account.Id, LeadSource = 'Partner');
        insert contact;
        POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        insert cs;
        
        //Start test method
        test.startTest();
        	//Set all headers of nomination form
            PageReference matrixPage = Page.NominationSettings;
            NominationSettingsController settings = new NominationSettingsController();
            
            for (String str : settings.nominationHeaderMap.keySet()) {
                settings.nominationHeaderMap.get(str).Visible__c = true;
            }
            settings.saveNominationSettings();
            
            //Create new nomination record for account from related list
            Nomination__c nomi = new Nomination__c(Account__c = account.Id);
            PageReference pageRef = Page.NominationForm;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(nomi);
            NominationFormControllerSLDS form = new NominationFormControllerSLDS(sc);
            
            Set<String> filterIds = new Set<String>();
            
            for (Label__c lb : settings.labels) {
            	lb.Visible__c = true;
            	filterIds.add(lb.Id);
            }
            //change ref type available count to cover code in setupProData
            settings.refTypes[0].Visible__c = false;
            settings.saveNominationSettings();
            
            //Create new nomination record for account from nominate as reference button on detail page
            pageRef.getParameters().put('AccountId', String.valueOf(account.Id));
            sc = new ApexPages.StandardController(new Nomination__c());
            form = new NominationFormControllerSLDS(sc);
            NominationFormControllerSLDS.InfoWrapper info = NominationFormControllerSLDS.fetchInfo(form.accountId, '', '', false);
            Map<String, List<NominationFormControllerSLDS.RefTypeWrapper>> filterMap = NominationFormControllerSLDS.getAllFilterAttributes(JSON.serialize(filterIds));
			
			for (NominationFormControllerSLDS.RefTypeWrapper ref : info.refTypes) {
				ref.isSelected = true;
			}
			
			for (NominationFormControllerSLDS.FilterWrapper filter: info.filters) {
				
	            if (filterMap != null && filterMap.containsKey(filter.id)) {
	            	filter.selectedAttIds.add(filterMap.get(filter.id)[0].id);
	            }
			}
			info.nomiFields.add(new NominationFormControllerSLDS.FieldWrapper(CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Nomination__c').getDescribe().fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe(), new Data_Mapping__c()));
			String result = NominationFormControllerSLDS.submit(JSON.serialize(info), '');
			system.assertNotEquals('', result);
			system.assertNotEquals(NominationFormControllerSLDS.getDateFormat(), '');
			String permission = NominationFormControllerSLDS.getPermissionsMessage(form.refLeadId);
		//Stop test method
        test.stopTest();
    }
    
    /*
     * Method to cover methods when nominate any contact
     * Modified By: Rekha Jangir @29 May 2017 
     */
    static testMethod void nominateContact() {
    	//insert test data
        Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c');
		Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Shared_Contacts__c = true;
        customSetting.Shared_Contact_Object__c = describeResult.getName();
		customSetting.Shared_Account_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe().getName();
		customSetting.Shared_Contact_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Contact__c').getDescribe().getName();
		customSetting.Roll_up_Attributes_to_Primary_Account__c = true;
        customSetting.Roll_up_Referenceability_to_Primary_Acc__c = true;
        customSetting.Enable_Sales_Rewards_Notification__c = true;
        customSetting.Inherit_Attributes_from_All_Accounts__c = true;
		update customSetting;
        List<Referenceability_Type__c> rfTypes = TestDataFactory.createReferenceabilityType();
        rfTypes.add(new Referenceability_Type__c(Name = 'Analyst Call 1', Referenceability_Type__c = true, Visible__c = true));
        rfTypes.add(new Referenceability_Type__c(Name = 'Analyst Call 2', Referenceability_Type__c = true, Visible__c = true));
        rfTypes.add(new Referenceability_Type__c(Name = 'Nomination', Referenceability_Type__c = true, Visible__c = true, Sales_Point__c = 10, Referenceability_code__c = ConstantsController.NOMINATION_SUBMITTED, Sales_Reward__c = true));
        insert rfTypes;
        Account account = new Account( Name = 'test account');
        insert account;
        Contact contact = new Contact (lastName = 'test Contact', AccountId = account.Id);
        insert contact;
        Account acc = new Account(Name = 'new shared');
        insert acc;
        Hit_List__c sharedc = new Hit_List__c(Account__c = acc.Id, Contact__c = contact.Id);
        insert sharedc;
        POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        insert cs;
        //Start test method
        test.startTest();
            Nomination__c nomi = new Nomination__c(Contact__c = contact.Id);
            PageReference pageRef = Page.NominationForm;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(nomi);
            NominationFormControllerSLDS form = new NominationFormControllerSLDS(sc);
            pageRef.getParameters().put('AccountId', String.valueOf(account.Id));
            pageRef.getParameters().put('ContactId', String.valueOf(contact.Id));
            sc = new ApexPages.StandardController(new Nomination__c());
            form = new NominationFormControllerSLDS(sc);
            NominationFormControllerSLDS.InfoWrapper info = NominationFormControllerSLDS.fetchInfo(form.accountId, form.contactId, '', true);
            String result = NominationFormControllerSLDS.submit(JSON.serialize(info), '');
            system.assertNotEquals('', result);
		//Stop test method
        test.stopTest();
    }
    
	/*
     * Method to cover methods when nominate any account from Ref Lead
     * Modified By: Rekha Jangir @29 May 2017 
     */
    static testMethod void nominatefromRefLead() {
    	//insert test data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Enable_Sales_Rewards_Notification__c = true;
        update customSetting;
        List<Referenceability_Type__c> rfTypes = TestDataFactory.createReferenceabilityType();
        rfTypes.add(new Referenceability_Type__c(Name = 'Analyst Call 1', Referenceability_Type__c = true, Visible__c = true));
        rfTypes.add(new Referenceability_Type__c(Name = 'RFL', Referenceability_Type__c = true, Visible__c = true, Sales_Point__c = 5, Referenceability_code__c = ConstantsController.RLF_RESPONSE, Sales_Reward__c = true));
        rfTypes.add(new Referenceability_Type__c(Name = 'Nomination', Referenceability_Type__c = true, Visible__c = true, Sales_Point__c = 10, Referenceability_code__c = ConstantsController.NOMINATION_SUBMITTED, Sales_Reward__c = true));
        insert rfTypes;
        Account account = new Account( Name = 'test account');
        insert account;
        Contact contact = new Contact (lastName = 'test Contact', AccountId = account.Id);
        insert contact;
        Reference_Lead__c refLead = new Reference_Lead__c(Reference_Lead_Account__c = account.Id);
        insert refLead;
        POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        insert cs;
        //Start test method
        test.startTest();
            Nomination__c nomi = new Nomination__c();
            PageReference pageRef = Page.NominationForm;
            pageRef.getParameters().put('refLeadId', String.valueOf(refLead.Id));
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(nomi);
            NominationFormControllerSLDS form = new NominationFormControllerSLDS(sc);
            NominationFormControllerSLDS.InfoWrapper info = NominationFormControllerSLDS.fetchInfo(form.accountId, '', form.refLeadId, false);
            String result = NominationFormControllerSLDS.submit(JSON.serialize(info), form.refLeadId);
            system.assertNotEquals('', result);
		//Stop test method
        test.stopTest();
    }
    
    /*
     * Method to cover methods when nominate any contact from ref laed
     * Modified By: Rekha Jangir @29 May 2017 
     */
    static testMethod void nominatefromRefLeadContact() {
    	//insert test data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account account = new Account( Name = 'test account');
        insert account;
        Contact contact = new Contact (lastName = 'test Contact', AccountId = account.Id);
        insert contact;
        Reference_Lead__c refLead = new Reference_Lead__c(Reference_Lead_Account__c = account.Id, Contact__c = contact.id);
        insert refLead;
        POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        insert cs;
        //Start test method
        test.startTest();
            Nomination__c nomi = new Nomination__c();
            PageReference pageRef = Page.NominationForm;
            pageRef.getParameters().put('refLeadId', String.valueOf(refLead.Id));
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(nomi);
            NominationFormControllerSLDS form = new NominationFormControllerSLDS(sc);
            NominationFormControllerSLDS.InfoWrapper info = NominationFormControllerSLDS.fetchInfo(form.accountId, '', form.refLeadId, false);
            system.assertNotEquals(null, info);
		//Stop test method
        test.stopTest();
    }
}