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
 * Test class for list view filter directive controller
 * author: Gaurav Saini (15 Feb, 2018)
 */
@isTest(seeAllData = false)
public with sharing class TestListViewFiltersController {

    /**
     * method to test getDateFormat method
     * author: Gaurav Saini (24 Feb, 2018)
     */
    public static testmethod void getDateFormat() {
    	List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
        Test.setCurrentPage(Page.SelectAccountsAsRefLeads);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(accounts);
        stdSetController.setSelected(accounts);
        ListViewFiltersController ext = new ListViewFiltersController(stdSetController);
        String dateFormat = ListViewFiltersController.getDateFormat();
        system.assert(dateFormat != null);
    }

    public static List<User_Mapping__c> createUserMappings() {
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
        insert userMappingsList;
        userMappingsList.add(listViewUM);
        return userMappingsList;
    }

    /**
     * method to test getListViewFilters method
     * author: Gaurav Saini (24 Feb, 2018)
     */
    public static testmethod void testGetListViewFilters() {
    	List<User_Mapping__c> userMappingsList = createUserMappings();
        String result = ListViewFiltersController.getListViewFilters(userMappingsList[3].Id, 'ListFiltersProspect');
        system.assert(result != null);
    }

    /**
     * method to test getFieldsList method
     * author: Gaurav Saini (24 Feb, 2018)
     */
    public static testmethod void testGetFieldsList() {
        String result = ListViewFiltersController.getFieldsList(JSON.serialize(new Map<String,String> {'Account'=>'Account'}));
        system.assert(result != null);
    }

    /**
     * method to test saveUserMappings method for updating existing list view
     * author: Gaurav Saini (24 Feb, 2018)
     */
    public static testmethod void testSaveUserMappings() {
        List<User_Mapping__c> userMappingsList = createUserMappings();
        String filtersListJson = ListViewFiltersController.getListViewFilters(userMappingsList[3].Id, 'ListFiltersProspect');
        String result = ListViewFiltersController.saveUserMappings(false, filtersListJson, '', String.valueOf(userMappingsList[3].Id), 'ListFiltersProspect','');
        system.assert(result != null);
    }

    /**
     * method to test saveUserMappings method for creating new list view
     * author: Gaurav Saini (24 Feb, 2018)
     */
    public static testmethod void testSaveUserMappings1() {
        List<User_Mapping__c> userMappingsList = createUserMappings();
        String filtersListJson = ListViewFiltersController.getListViewFilters(userMappingsList[3].Id, 'ListFiltersProspect');
        String result = ListViewFiltersController.saveUserMappings(true, filtersListJson, 'Test List View', String.valueOf(userMappingsList[3].Id), 'ListFiltersProspect','');
        system.assert(result != null);
        result = ListViewFiltersController.saveUserMappings(true, 'test invalid json', 'Test List View', String.valueOf(userMappingsList[3].Id), 'ListFiltersProspect','');
        system.assert(result != null);
        result = ListViewFiltersController.getListViewRecord(userMappingsList[3].Id,'ListFiltersProspect');
        system.assert(result != null);
        System.assert(true,ListViewFiltersController.isNameUnique('AllAccounts','ListFiltersProspect'));
    }
}