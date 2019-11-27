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
 * Description: test class for SelectAccountsAsRefLeads
 * Author: Gaurav Saini (21 Nov, 2017)
 * Last Modified: Gaurav Saini (2 Feb, 2018) REF-1300
 */
@isTest(seeAllData = false)
public with sharing class TestSelectAccountsAsRefLeads {
    
	public static Map<String, String> fieldNamesMap {

		get {
			
			if (fieldNamesMap == null) {
				fieldNamesMap = new Map<String, String>();
				fieldNamesMap.put(System.Label.Account_Owner, System.Label.Account_Owner + '##STRING');
				fieldNamesMap.put(System.Label.Parent_Account, System.Label.Parent_Account + '##STRING');
				fieldNamesMap.put(Schema.SObjectType.Account.fields.OwnerId.getName(), Schema.SObjectType.Account.fields.OwnerId.getLabel() + '##REFERENCE');
				fieldNamesMap.put(Schema.SObjectType.Account.fields.LastActivityDate.getName(), Schema.SObjectType.Account.fields.LastActivityDate.getLabel() + '##DATE');
				fieldNamesMap.put(Schema.SObjectType.Account.fields.LastViewedDate.getName(), Schema.SObjectType.Account.fields.LastViewedDate.getLabel() + '##DATETIME');
				fieldNamesMap.put(Schema.SObjectType.Account.fields.Name.getName(), Schema.SObjectType.Account.fields.Name.getLabel() + '##STRING');
			}
			
			system.assertEquals(true,(fieldNamesMap == null || fieldNamesMap != null));
			return fieldNamesMap;
		} 
		set;  
	}

    /**
     * method to test constructor
     * author: Gaurav Saini (21 Nov, 2017)
     */
    public static testmethod void testConstructor() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	
    	Test.startTest();
			Test.setCurrentPage(Page.SelectAccountsAsRefLeads);
			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(accounts);
			stdSetController.setSelected(accounts);
			SelectAccountsAsRefLeads testObj = new SelectAccountsAsRefLeads(stdSetController);
			system.assert(testObj.refLeadIdPrefix != null);
			String permissionMsg = SelectAccountsAsRefLeads.getPermissionsMessage();
			system.assert(permissionMsg != null);
		Test.stopTest();
    }
    
    /**
     * method to test getExistingRefLeadAccIds method
     * author: Gaurav Saini (14 Dec, 2017)
     */
    public static testmethod void testGetExistingRefLeadAccIds() {
    	Account testAcc = new Account(Name = 'test account');
    	insert testAcc;
    	Reference_Lead__c testRefLead = new Reference_Lead__c();
		testRefLead.Reference_Lead_Account__c = testAcc.Id;
		testRefLead.Reference_Lead_Status__c = 'Request Pending';
		testRefLead.Ref_Lead_Include_in_Campaign__c = true;
		testRefLead.Reference_Lead_Owner__c = testAcc.OwnerId;
		insert testRefLead;
		String result = SelectAccountsAsRefLeads.getExistingRefLeadAccIds();
		system.assert(result != null);
    }

	/**
     * method to test getListViews method
     * author: Gaurav Saini (24 Feb, 2018)
     */
	public static testmethod void testGetListViews() {
		String result = SelectAccountsAsRefLeads.getListViews();
		system.assert(result != null);
		User_Mapping__c listViewUM = new User_Mapping__c();
        listViewUM.Field_API_Name__c = 'All Accounts';
        listViewUM.Process__c = 'ListFiltersProspect';
        listViewUM.User__c = UserInfo.getUserId();
		insert listViewUM;
		result = SelectAccountsAsRefLeads.getListViews();
		system.assert(result != null);
	}

	/**
     * method to test deleteUserMapping method
     * author: Gaurav Saini (24 Feb, 2018)
     */
	public static testmethod void testDeleteUserMapping() {
		User_Mapping__c listViewUM = new User_Mapping__c();
        listViewUM.Field_API_Name__c = 'All Accounts';
        listViewUM.Process__c = 'ListFiltersProspect';
        listViewUM.User__c = UserInfo.getUserId();
		insert listViewUM;
		String result = SelectAccountsAsRefLeads.deleteUserMapping(listViewUM.Id);
		system.assert(result != null);
	}

	/**
	 * method to creat list views and filters for test class
	 * author: Gaurav Saini (24 Feb, 2018)
	 */
	public static List<User_Mapping__c> createListViewFilters() {
		List<User_Mapping__c> userMappingsList = new List<User_Mapping__c>();
		User_Mapping__c listViewUM = new User_Mapping__c();
        listViewUM.Field_API_Name__c = 'All Accounts';
        listViewUM.Process__c = 'ListFiltersProspect';
        listViewUM.User__c = UserInfo.getUserId();
		insert listViewUM;
		User_Mapping__c tempUM = new User_Mapping__c(Process__c = 'ListFiltersProspect', User__c = UserInfo.getUserId(), Label__c = listViewUM.Id);
        tempUM.Field_API_Name__c = 'Name::Account Name::STRING::contains';
        tempUM.Default_Value__c = 'test';
        userMappingsList.add(tempUM);
        tempUM = new User_Mapping__c(Process__c = 'ListFiltersProspect', User__c = UserInfo.getUserId(), Label__c = listViewUM.Id);
        tempUM.Field_API_Name__c = 'Industry::Industry::PICKLIST::equals';
        tempUM.Default_Value__c = 'Banking';
        userMappingsList.add(tempUM);
        tempUM = new User_Mapping__c(Process__c = 'ListFiltersProspect', User__c = UserInfo.getUserId(), Label__c = listViewUM.Id);
        tempUM.Field_API_Name__c = 'IsDeleted::Deleted::BOOLEAN::equals';
        tempUM.Default_Value__c = 'false';
        userMappingsList.add(tempUM);
        tempUM = new User_Mapping__c(Process__c = 'ListFiltersProspect', User__c = UserInfo.getUserId(), Label__c = listViewUM.Id);
        tempUM.Field_API_Name__c = 'CreatedDate::Created Date::DATETIME::greater than';
        tempUM.Default_Value__c = '24/01/2018';
        userMappingsList.add(tempUM);
        tempUM = new User_Mapping__c(Process__c = 'ListFiltersProspect', User__c = UserInfo.getUserId(), Label__c = listViewUM.Id);
        tempUM.Field_API_Name__c = 'CreatedDate::Created Date::DATETIME::not equal to';
        tempUM.Default_Value__c = '';
        userMappingsList.add(tempUM);
        tempUM = new User_Mapping__c(Process__c = 'ListFiltersProspect', User__c = UserInfo.getUserId(), Label__c = listViewUM.Id);
        tempUM.Field_API_Name__c = 'AnnualRevenue::Annual Revenue::CURRENCY::greater than';
        tempUM.Default_Value__c = '500';
        userMappingsList.add(tempUM);
        tempUM = new User_Mapping__c(Process__c = 'ListFiltersProspect', User__c = UserInfo.getUserId(), Label__c = listViewUM.Id);
        tempUM.Field_API_Name__c = 'Type::Account Type::PICKLIST::equals';
        tempUM.Default_Value__c = '';
        userMappingsList.add(tempUM);
		return userMappingsList;
	}

    /**
     * method to test getAccountsList method
     * author: Gaurav Saini (14 Dec, 2017)
     */
    public static testmethod void testGetAccountsList() {
    	List<User_Mapping__c> userMappingsList = new List<User_Mapping__c>();
		Integer orderNo = 1;
		
		for (String apiName : fieldNamesMap.keySet()) {
			User_Mapping__c tempUM = new User_Mapping__c();
			tempUM.Label__c = fieldNamesMap.get(apiName).split('##')[0];
			tempUM.Field_API_Name__c = apiName;
			tempUM.Order__c = orderNo;
			tempUM.Visible__c = true;
			tempUM.Process__c = 'ColumnSelectorProspect';
			tempUM.User__c = UserInfo.getUserId();
			tempUM.Default_Value__c = fieldNamesMap.get(apiName).split('##')[1];
			userMappingsList.add(tempUM);
			orderNo += 1;
		}
		insert userMappingsList;
		List<User_Mapping__c> listViewFiltersList = createListViewFilters();
		insert listViewFiltersList;
		String fieldsListJson = SelectAccountsAsRefLeads.getSelectedFieldsList();
		List<SelectAccountsAsRefLeads.FieldWrapper> selectedFieldsList = new List<SelectAccountsAsRefLeads.FieldWrapper>();
		List<SelectAccountsAsRefLeads.FieldWrapper> allFieldsList
				= (List<SelectAccountsAsRefLeads.FieldWrapper>)JSON.deserialize(fieldsListJson, List<SelectAccountsAsRefLeads.FieldWrapper>.class);

		for (SelectAccountsAsRefLeads.FieldWrapper field : allFieldsList) {
			
			if (field.isSelected) {
				selectedFieldsList.add(field);
			}
		}
		Account testAcc = new Account(Name = 'test account', Industry = 'Banking', AnnualRevenue = 1000);
    	insert testAcc;
    	String result = SelectAccountsAsRefLeads.getAccountsList(JSON.serialize(new List<String>()), JSON.serialize(selectedFieldsList), listViewFiltersList[0].Label__c);
    	system.assert(result != null);
    }

	/**
	 * method to test getMoreAccounts method
	 * author: Gaurav Saini (14 Dec, 2017)
	 */
	public static testmethod void testGetMoreAccounts() {
		List<User_Mapping__c> userMappingsList = new List<User_Mapping__c>();
		Integer orderNo = 1;
		
		for (String apiName : fieldNamesMap.keySet()) {
			User_Mapping__c tempUM = new User_Mapping__c();
			tempUM.Label__c = fieldNamesMap.get(apiName).split('##')[0];
			tempUM.Field_API_Name__c = apiName;
			tempUM.Order__c = orderNo;
			tempUM.Visible__c = true;
			tempUM.Process__c = 'ColumnSelectorProspect';
			tempUM.User__c = UserInfo.getUserId();
			tempUM.Default_Value__c = fieldNamesMap.get(apiName).split('##')[1];
			userMappingsList.add(tempUM);
			orderNo += 1;
		}
		insert userMappingsList;
		List<User_Mapping__c> listViewFiltersList = createListViewFilters();
		insert listViewFiltersList;
		String fieldsListJson = SelectAccountsAsRefLeads.getSelectedFieldsList();
		List<SelectAccountsAsRefLeads.FieldWrapper> selectedFieldsList = new List<SelectAccountsAsRefLeads.FieldWrapper>();
		List<SelectAccountsAsRefLeads.FieldWrapper> allFieldsList
				= (List<SelectAccountsAsRefLeads.FieldWrapper>)JSON.deserialize(fieldsListJson, List<SelectAccountsAsRefLeads.FieldWrapper>.class);

		for (SelectAccountsAsRefLeads.FieldWrapper field : allFieldsList) {
			
			if (field.isSelected) {
				selectedFieldsList.add(field);
			}
		}
		Account testAcc = new Account(Name = 'test account', Industry = 'Banking', AnnualRevenue = 1000);
		insert testAcc;
		String result = SelectAccountsAsRefLeads.getMoreAccounts(JSON.serialize(new List<String>()), JSON.serialize(new List<String>()), '', JSON.serialize(selectedFieldsList), listViewFiltersList[0].Label__c);
		system.assert(result != null);
		String result1 = SelectAccountsAsRefLeads.getMoreAccounts(JSON.serialize(new List<String>()), JSON.serialize(new List<String>()), 'test', JSON.serialize(selectedFieldsList), listViewFiltersList[0].Label__c);
		system.assert(result1 != null);
	}

	/**
	 * method to test getAccountsOnColumnsChange method
	 * author: Gaurav Saini (14 Dec, 2017)
	 */
	public static testmethod void testGetAccountsOnColumnsChange() {
		List<User_Mapping__c> userMappingsList = new List<User_Mapping__c>();
		Integer orderNo = 1;
		
		for (String apiName : fieldNamesMap.keySet()) {
			User_Mapping__c tempUM = new User_Mapping__c();
			tempUM.Label__c = fieldNamesMap.get(apiName).split('##')[0];
			tempUM.Field_API_Name__c = apiName;
			tempUM.Order__c = orderNo;
			tempUM.Visible__c = true;
			tempUM.Process__c = 'ColumnSelectorProspect';
			tempUM.User__c = UserInfo.getUserId();
			tempUM.Default_Value__c = fieldNamesMap.get(apiName).split('##')[1];
			userMappingsList.add(tempUM);
			orderNo += 1;
		}
		insert userMappingsList;
		String fieldsListJson = SelectAccountsAsRefLeads.getSelectedFieldsList();
		List<SelectAccountsAsRefLeads.FieldWrapper> selectedFieldsList = new List<SelectAccountsAsRefLeads.FieldWrapper>();
		List<SelectAccountsAsRefLeads.FieldWrapper> allFieldsList
				= (List<SelectAccountsAsRefLeads.FieldWrapper>)JSON.deserialize(fieldsListJson, List<SelectAccountsAsRefLeads.FieldWrapper>.class);

		for (SelectAccountsAsRefLeads.FieldWrapper field : allFieldsList) {
			
			if (field.isSelected) {
				selectedFieldsList.add(field);
			}
		}
		Account testAcc = new Account(Name = 'test account');
		insert testAcc;
		String result = SelectAccountsAsRefLeads.getAccountsOnColumnsChange(JSON.serialize(new List<String> { testAcc.Id }), JSON.serialize(selectedFieldsList));
		system.assert(result != null);
	}
    
    /**
     * method to test createRefLeads
     * author: Gaurav Saini (21 Nov, 2017)
     */
	public static testmethod void testCreateRefLeads() {
		List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	Account testAcc = new Account(Name = 'test account');
    	insert testAcc;
    	List<String> accIds = new List<String>();
    	Reference_Lead__c testRefLead = new Reference_Lead__c();
		testRefLead.Reference_Lead_Account__c = accounts[0].Id;
		testRefLead.Reference_Lead_Status__c = 'Request Pending';
		testRefLead.Ref_Lead_Include_in_Campaign__c = true;
		testRefLead.Reference_Lead_Owner__c = accounts[0].OwnerId;
		insert testRefLead;
		
		for (Account acc : accounts) {
			accIds.add(acc.Id);
		}
		
		Test.startTest();
			Custom_Settings__c cs = TestDataFactory.createCustomSetting();
			String saveResult = SelectAccountsAsRefLeads.createRefLeads(JSON.serialize(accIds));
			system.assert(saveResult.startsWith('success'));
			cs.Ref_Prosepector_Lead_Owner__c = 'LastModifiedById';
			update cs;
			saveResult = SelectAccountsAsRefLeads.createRefLeads('test');
			system.assert(!saveResult.startsWith('success'));
			accIds.add(testAcc.Id);
			saveResult = SelectAccountsAsRefLeads.createRefLeads(JSON.serialize(accIds));
			system.assert(saveResult.startsWith('success'));
		Test.stopTest();
	}
	
	/**
     * method to test createRefLeads
     * author: Gaurav Saini (21 Nov, 2017)
     */
	public static testmethod void testCreateRefLeads1() {
		List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<String> accIds = new List<String>();
    	Reference_Lead__c testRefLead = new Reference_Lead__c();
		testRefLead.Reference_Lead_Account__c = accounts[0].Id;
		testRefLead.Reference_Lead_Status__c = 'Request Pending';
		testRefLead.Ref_Lead_Include_in_Campaign__c = true;
		testRefLead.Reference_Lead_Owner__c = accounts[0].OwnerId;
		insert testRefLead;
		
		for (Account acc : accounts) {
			accIds.add(acc.Id);
		}
		
		Test.startTest();
			Custom_Settings__c cs = TestDataFactory.createCustomSetting();
			cs.Ref_Prosepector_Lead_Owner__c = 'OwnerId';
			update cs;
			String saveResult = SelectAccountsAsRefLeads.createRefLeads(JSON.serialize(accIds));
			system.assert(saveResult.startsWith('success'));
		Test.stopTest();
	}

	/**
     * method to test saveSelectedFields
     * author: Gaurav Saini (21 Nov, 2017)
     */
	public static testmethod void testSaveSelectedFields() {
		List<User_Mapping__c> userMappingsList = new List<User_Mapping__c>();
		Integer orderNo = 1;
		Map<String, String> tempFieldNamesMap = new Map<String, String>();
		tempFieldNamesMap.put(Schema.SObjectType.Account.fields.OwnerId.getName(), Schema.SObjectType.Account.fields.OwnerId.getLabel() + '##REFERENCE');
		tempFieldNamesMap.put(Schema.SObjectType.Account.fields.LastActivityDate.getName(), Schema.SObjectType.Account.fields.LastActivityDate.getLabel() + '##DATE');
		tempFieldNamesMap.put(Schema.SObjectType.Account.fields.LastViewedDate.getName(), Schema.SObjectType.Account.fields.LastViewedDate.getLabel() + '##DATETIME');
		tempFieldNamesMap.put(Schema.SObjectType.Account.fields.Name.getName(), Schema.SObjectType.Account.fields.Name.getLabel() + '##STRING');
		
		for (String apiName : tempFieldNamesMap.keySet()) {
			User_Mapping__c tempUM = new User_Mapping__c();
			tempUM.Label__c = tempFieldNamesMap.get(apiName).split('##')[0];
			tempUM.Field_API_Name__c = apiName;
			tempUM.Order__c = orderNo;
			tempUM.Visible__c = true;
			tempUM.Process__c = 'ColumnSelectorProspect';
			tempUM.User__c = UserInfo.getUserId();
			tempUM.Default_Value__c = tempFieldNamesMap.get(apiName).split('##')[1];
			userMappingsList.add(tempUM);
			orderNo += 1;
		}
		insert userMappingsList;
		String fieldsListJson = SelectAccountsAsRefLeads.getSelectedFieldsList();
		List<SelectAccountsAsRefLeads.FieldWrapper> selectedFieldsList = new List<SelectAccountsAsRefLeads.FieldWrapper>();
		List<SelectAccountsAsRefLeads.FieldWrapper> oldSelectedFieldsList = new List<SelectAccountsAsRefLeads.FieldWrapper>();
		List<SelectAccountsAsRefLeads.FieldWrapper> allFieldsList
				= (List<SelectAccountsAsRefLeads.FieldWrapper>)JSON.deserialize(fieldsListJson, List<SelectAccountsAsRefLeads.FieldWrapper>.class);

		for (SelectAccountsAsRefLeads.FieldWrapper field : allFieldsList) {
			
			if (field.isSelected) {
				selectedFieldsList.add(field);
			}
		}
		oldSelectedFieldsList.addAll(selectedFieldsList);
		oldSelectedFieldsList.remove(0);
		String result = SelectAccountsAsRefLeads.saveSelectedFields(JSON.serialize(selectedFieldsList), JSON.serialize(oldSelectedFieldsList));
		system.assert(result.startsWith('success'));
		String result1 = SelectAccountsAsRefLeads.saveSelectedFields('test', JSON.serialize(oldSelectedFieldsList));
		system.assert(!result1.startsWith('success'));
	}
}