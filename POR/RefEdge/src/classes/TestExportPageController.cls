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
 * test class for export page controller
 * author: Gaurav Saini (19 Jan, 2018) for REF-1266
 */
@isTest(seeAllData = false)
public with sharing class TestExportPageController {

    /**
     * method to test constructor in case of RefedgeDM export
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testConstructorForDataLoader() {
        Custom_Settings__c cs = TestDataFactory.createCustomSetting();
        Apexpages.currentPage().getParameters().put('eo', 'test');
        ExportPageController testObj = new ExportPageController();
        system.assertEquals(testObj.exportDetailsCSV, 'test');
    }

    /**
     * method to test constructor in case of accounts export from Ref search page
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testConstructorForFilteredAccounts() {
        Custom_Settings__c cs = TestDataFactory.createCustomSetting();
        Apexpages.currentPage().getParameters().put('allAccountIds', 'test');
        ExportPageController testObj = new ExportPageController();
        system.assertEquals(testObj.accountIdsCSV, 'test');
    }

    /**
     * method to test constructor in case of contacts export from Ref search page
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testConstructorForFilteredContacts() {
        Custom_Settings__c cs = TestDataFactory.createCustomSetting();
        Apexpages.currentPage().getParameters().put('allContactIds', 'test');
        ExportPageController testObj = new ExportPageController();
        system.assertEquals(testObj.contactIdsCSV, 'test');
    }

    /**
     * method to test constructor in case of content export from Ref search page
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testConstructorForFilteredContent() {
        Custom_Settings__c cs = TestDataFactory.createCustomSetting();
        Apexpages.currentPage().getParameters().put('allContentIds', 'test');
        ExportPageController testObj = new ExportPageController();
        system.assertEquals(testObj.contentIdsCSV, 'test');
    }

    /**
     * method to create data mapping records for the specified object and fields
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static List<Data_Mapping__c> getDataMappings(String objectName, Map<String, String> fieldsMap) {
        List<Data_Mapping__c> dataMappings = new List<Data_Mapping__c>();

        for (String apiName : fieldsMap.keySet()) {
            Data_Mapping__c tempDM = new Data_Mapping__c();
            tempDM.Object__c = objectName;
            tempDM.Label__c = fieldsMap.get(apiName);
            tempDM.Field_API_Name__c = apiName;
            tempDM.Visible__c = true;
            dataMappings.add(tempDM);
        }
        return dataMappings;
    }

    /**
     * method to test getAttributesMapForGapAnalysis method
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testGetAttributesMapForGapAnalysis() {
        List<Attribute__c> attributeList = TestDataFactory.createAttribute();
    	insert attributeList;
    	List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attributeList, 1, 2);
    	insert childAttList;
        String attMapJson = ExportPageController.getAttributesMapForGapAnalysis();
        system.assert(attMapJson != null);
    }

    /**
     * method to test getFiltersMapForRBIExport method
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testGetFiltersMapForRBIExport() {
        List<Label__c> filterList = TestDataFactory.createLabels();
    	Integer lblNo = 1;

        for (Label__c lbl : filterList) {
            lbl.Filter_no__c = lblNo;
            lblNo += 1;
        }
        insert filterList;
        String filtersMapJson = ExportPageController.getFiltersMapForRBIExport();
        system.assert(filtersMapJson != null);
    }

    /**
     * method to test getRefTypesMapForRBIExport method
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testGetRefTypesMapForRBIExport() {
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
    	Integer refNo = 1;

        for (Referenceability_Type__c refType : refTypeList) {
            refType.Referenceability_no__c = refNo;
            refNo += 1;
        }
        insert refTypeList;
        String refTypesMapJson = ExportPageController.getRefTypesMapForRBIExport();
        system.assert(refTypesMapJson != null);
    }

    /**
     * method to test getFooterData method
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testGetFooterData() {
        String footerListJson = ExportPageController.getFooterData();
        system.assert(footerListJson != null);
    }

    /**
     * method to test export functionality for Reference content export from RefedgeDM
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForReferenceContent() {
        Map<String, String> fieldsMap = new Map<String, String>();
        fieldsMap.put('Id', 'Record Id');
        fieldsMap.put('Content_URL__c', 'Content URL');
        fieldsMap.put('Language__c', 'Language');
        List<Data_Mapping__c> dataMappings = getDataMappings('DMReference_Content__c', fieldsMap);
        insert dataMappings;
        
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('Reference_Content__c', 'Id', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() == 4);

        // testing get export records method
        List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
		insert refContents;
        String result = ExportPageController.getRecordsToExport('Reference_Content__c', headersListJson.split('--------')[1] + '50',
                                                                headersListJson.split('--------')[0], '', JSON.serialize(new List<String>()));
        system.assert(result != null);
    }

    /**
     * method to test export functionality for Account Request export from RefedgeDM
     * author: Dixita (March, 2019) for REF-2102
     */
    public static testmethod void testExportForReferenceRequest() {
        Map<String, String> fieldsMap = new Map<String, String>();
        fieldsMap.put('Id', 'Record Id');
        fieldsMap.put('Account__c', 'Account');
        fieldsMap.put('Reference_Request__c', 'Reference Request');
        List<Data_Mapping__c> dataMappings = getDataMappings('DMReference_Request_Account__c', fieldsMap);
        insert dataMappings;
        
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('Reference_Request_Account__c', 'Id', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        List <Reference_Request__c> request = TestDataFactory.createReferenceRequest();
        insert request;
        List<Account> accounts = TestDataFactory.createAccounts();
		insert accounts;
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Reference_Request_Account__c> ars = TestDataFactory.createAccountRequests(accounts,request,refTypes);
		insert ars;
        
        String result = ExportPageController.getRecordsToExport('Reference_Request_Account__c', headersListJson.split('--------')[1] + '50',
                                                                headersListJson.split('--------')[0], '', JSON.serialize(new List<String>()));
        system.assert(result != null);

        fieldsMap = new Map<String, String>();
        fieldsMap.put('Id', 'Record Id');
        fieldsMap.put('Reference_Request__c', 'Reference Request');
        dataMappings = getDataMappings('DMUnspecified_Request__c', fieldsMap);
        insert dataMappings;
        
        // testing get headers method
        headersListJson = ExportPageController.getHeadersList('Unspecified_Request__c', 'Id', '');
        headingWrapperList = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() == 2);
        List <Unspecified_Request__c> URs = TestDataFactory.createUnspecifiedRequest(request,refTypes);
        result = ExportPageController.getRecordsToExport('Unspecified_Request__c', headersListJson.split('--------')[1] + '50',
                                                                headersListJson.split('--------')[0], '', JSON.serialize(new List<String>()));
        system.assert(result != null);
    }
    /**
     * method to test export functionality for Label export from RefedgeDM
     * author: Dixita (March, 2019) for REF-2102
     */
    public static testmethod void testExportForLabel() {
        // testing get headers method
        Map<String, String> fieldsMap = new Map<String, String>();
        fieldsMap.put('Id', 'Record Id');
        List<Data_Mapping__c> dataMappings = getDataMappings('DMLabel__c', fieldsMap);
        insert dataMappings;
        String headersListJson = ExportPageController.getHeadersList('Label__c', '', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        
        // testing get export records method
        List<Label__c> labels = TestDataFactory.createLabels();
		insert labels;
        String result = ExportPageController.getRecordsToExport('Label__c', headersListJson.split('--------')[1] + ' 50', headersListJson.split('--------')[0], '', JSON.serialize(new List<String>()));
        system.assert(result != null);
    }

    /**
     * method to test export functionality for Account export from RefedgeDM
     * author: Dixita (March, 2019) for REF-2102
     */
    public static testmethod void testExportAccountContact() {
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('Account', '', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() == 2);
        List<Account> accounts = TestDataFactory.createAccounts();
		insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
		insert contacts;
        
        // testing get export records method
        String result = ExportPageController.getRecordsToExport('Account', '50', JSON.serialize(new List<ExportPageController.HeadingWrapper>()), '', JSON.serialize(new List<String>()));
        system.assert(result != null);
        
        headersListJson = ExportPageController.getHeadersList('Contact', '', '');
        headingWrapperList = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() == 2);
        // testing get export records method
        result = ExportPageController.getRecordsToExport('Contact', '50', JSON.serialize(new List<ExportPageController.HeadingWrapper>()), '', JSON.serialize(new List<String>()));
        system.assert(result != null);
    }

    /**
     * method to test export functionality for template export from RefedgeDM
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForTemplate() {
        Map<String, String> fieldsMap = new Map<String, String>();
        fieldsMap.put('Id', 'Record Id');
        fieldsMap.put('Content_URL__c', 'Content URL');
        fieldsMap.put('Language__c', 'Language');
        List<Data_Mapping__c> dataMappings = getDataMappings('DMReference_Content__c', fieldsMap);
        insert dataMappings;
        
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('Template', 'Reference_Content__c', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() == 3);
    }

    /**
     * method to test export functionality for attributes export from RefedgeDM
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForAttribute() {
        Map<String, String> fieldsMap = new Map<String, String>();
        fieldsMap.put('Id', 'Record Id');
        fieldsMap.put('Name', 'Attribute Name');
        fieldsMap.put('Level__c', 'Level');
        List<Data_Mapping__c> dataMappings = getDataMappings('DMAttribute__c', fieldsMap);
        insert dataMappings;
        
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('Attribute__c', '', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() > 0);

        // testing get export records method
        List<Attribute__c> attributeList = TestDataFactory.createAttribute();
    	insert attributeList;
    	List<Attribute__c> childAttList = TestDataFactory.createChildAttributes(attributeList, 1, 2);
    	insert childAttList;
        String result = ExportPageController.getRecordsToExport('Attribute__c', headersListJson.split('--------')[1] + '50',
                                                                headersListJson.split('--------')[0], '', JSON.serialize(new List<String>()));
        system.assert(result != null);
    }

    /**
     * method to test export functionality for library export from RefedgeDM
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForLibrary() {
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('Library__c', '', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() == 2);

        // testing get export records method
        String result = ExportPageController.getRecordsToExport('Library__c', '50', headersListJson.split('--------')[0], '', JSON.serialize(new List<String>()));
    }
    
    /**
     * method to test export functionality for accounts export from RefedgeDM
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForAccount() {
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('Account__c', '', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        // testing get export records method
        Account acc = new Account(Name = 'test account');
        insert acc;
        
        String result = ExportPageController.getRecordsToExport('Account__c', '50', headersListJson.split('--------')[0], '', JSON.serialize(new List<String>()));
        system.assert(result != null);
    }
    
    /**
     * method to test export functionality for contacts export from RefedgeDM
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForContact() {
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('Contact__c', '', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        
        // testing get export records method
        Account acc = new Account(Name = 'test account');
        insert acc;
        Contact con = new Contact(LastName = 'test contact', AccountId = acc.Id);
        insert con;
        String result = ExportPageController.getRecordsToExport('Contact__c', '50', headersListJson.split('--------')[0], '', JSON.serialize(new List<String>()));
        system.assert(result != null);
    }

    /**
     * method to test export functionality for ref types export from RefedgeDM
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForRefTypes() {
        Map<String, String> fieldsMap = new Map<String, String>();
        fieldsMap.put('Id', 'Record Id');
        fieldsMap.put('Visible__c', 'Visible');
        fieldsMap.put('Referenceability_Type__c', 'Referenceability Type');
        List<Data_Mapping__c> dataMappings = getDataMappings('DMReferenceability_Type__c', fieldsMap);
        insert dataMappings;
        
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('Referenceability_Type__c', '', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() > 0);

        // testing get export records method
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
        insert refTypeList;
        String result = ExportPageController.getRecordsToExport('Referenceability_Type__c', headersListJson.split('--------')[1] + '50',
                                                                headersListJson.split('--------')[0], '', JSON.serialize(new List<String>()));
        system.assert(result != null);
    }
    
    /**
     * method to test export functionality for ref content types export from RefedgeDM
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForRefContentTypes() {
        Map<String, String> fieldsMap = new Map<String, String>();
        fieldsMap.put('Id', 'Record Id');
        fieldsMap.put('Active__c', 'Active');
        fieldsMap.put('Name__c', 'Name');
        List<Data_Mapping__c> dataMappings = getDataMappings('DMReference_Content_Type__c', fieldsMap);
        insert dataMappings;
        
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('Reference_Content_Type__c', '', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() > 0);

        // testing get export records method
        Reference_Content_Type__c refContentType = TestDataFactory.createContentType();
        insert refContentType;
        String result = ExportPageController.getRecordsToExport('Reference_Content_Type__c', headersListJson.split('--------')[1] + '50',
                                                                headersListJson.split('--------')[0], '', JSON.serialize(new List<String>()));
        system.assert(result != null);
    }
    
    /**
     * method to test export functionality for reference profile export from RefedgeDM
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForRefProfile() {
        Map<String, String> fieldsMap = new Map<String, String>();
        fieldsMap.put('Id', 'Record Id');
        fieldsMap.put('Account__c', 'Account');
        fieldsMap.put('Contact__c', 'Contact');
        List<Data_Mapping__c> dataMappings = getDataMappings('DMReference_Basic_Information__c', fieldsMap);
        insert dataMappings;
        
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('Reference_Basic_Information__c', 'Id', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() > 0);

        // testing get export records method
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        String result = ExportPageController.getRecordsToExport('Reference_Basic_Information__c', headersListJson.split('--------')[1] + '50',
                                                                headersListJson.split('--------')[0], '', JSON.serialize(new List<String>()));
        system.assert(result != null);
    }
    
    /**
     * method to test export functionality for account with attributes export from RefedgeDM
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForAccountWithAtts() {
        List<Attribute_Mapping__c> attMappings = TestDataFactory.createRelatedAttributeMappingAccount();
        List<Attribute__c> rootAttributes = TestDataFactory.createAttribute();
        insert rootAttributes;
        
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('Account_with_Attributes__c', 'Id', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() > 3);

        // testing get export records method
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        String result = ExportPageController.getRecordsToExport('Account_with_Attributes__c', headersListJson.split('--------')[1] + '50',
                                                                headersListJson.split('--------')[0], '', JSON.serialize(new List<String>()));
        system.assert(result != null);
    }
    
    /**
     * method to test export functionality for contact with attributes export from RefedgeDM
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForContactWithAtts() {
        List<Attribute_Mapping__c> attMappings = new List<Attribute_Mapping__c>();
        attMappings.add(new Attribute_Mapping__c(Object__c = 'Reference Profile',
                                                    Is_Related_Mapping__c = true,
                                                    Attribute_Name__c = 'Lead Source',
                                                    Field__c = 'Lead Source',
                                                    Related_Object__c = 'Contact',
                                                    Filter_Label_Name__c='Lead Source',
                                                    Mapping_Type__c = 'Parent Object',
                                                    RelationShip_Name__c = UtilityController.appNamespace() + 'Contact__c',
                                                    Field_Api_Name__c = 'LeadSource',
                                                    Inheritable__c = true));
        insert attMappings;
        List<Attribute__c> rootAttributes = TestDataFactory.createAttribute();
        insert rootAttributes;
        
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('Contact_with_Attributes__c', 'Id', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() > 3);

        // testing get export records method
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.setUpContactRBI(contacts);
        String result = ExportPageController.getRecordsToExport('Contact_with_Attributes__c', headersListJson.split('--------')[1] + '50',
                                                                headersListJson.split('--------')[0], '', JSON.serialize(new List<String>()));
        system.assert(result != null);
    }
    
    /**
     * method to test export functionality for account with attributes export from RefedgeDM
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForContentWithAtts() {
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Admin%'];
        User u = new User(alias = 'jpusr', email = 'japnalocal@newtest.com',
                            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                            localesidkey = 'en_US', profileid = p.Id,
                            timezonesidkey = 'America/Los_Angeles', username = 'japnalocal@newtest.com');
        
        system.runAs(u) {
            List<Attribute_Mapping__c> attMappings = new List<Attribute_Mapping__c>();
            attMappings.add(new Attribute_Mapping__c(Object__c = 'Reference Content',
                                                        Is_Related_Mapping__c = true,
                                                        Attribute_Name__c = 'Last Name',
                                                        Field__c = 'Last Name',
                                                        Related_Object__c = 'User',
                                                        Filter_Label_Name__c='Last Name',
                                                        Mapping_Type__c = 'Parent Object',
                                                        RelationShip_Name__c = 'OwnerId',
                                                        Field_Api_Name__c = 'LastName',
                                                        Inheritable__c = true));
            attMappings.add(new Attribute_Mapping__c(Object__c = 'Reference Content',
                                                        Is_Related_Mapping__c = true,
                                                        Attribute_Name__c = 'Name',
                                                        Field__c = 'Name',
                                                        Related_Object__c = 'Reference_Content_Type__c',
                                                        Filter_Label_Name__c='Name',
                                                        Mapping_Type__c = 'Parent Object',
                                                        RelationShip_Name__c = 'Reference_Content_Type__c',
                                                        Field_Api_Name__c = UtilityController.appNamespace() + 'Name__c',
                                                        Inheritable__c = true));
            insert attMappings;
            List<Attribute__c> rootAttributes = TestDataFactory.createAttribute();
            insert rootAttributes;
            
            // testing get headers method
            String headersListJson = ExportPageController.getHeadersList('Content_with_Attributes__c', 'Id', '');
            List<ExportPageController.HeadingWrapper> headingWrapperList
                = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
            system.assert(headingWrapperList.size() > 3);

            // testing get export records method
            List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
            Reference_Content_Type__c refContentType = TestDataFactory.createContentType();
            insert refContentType;
            ExportPageController.getAssociatedAccountsToExport(refContents[0].Id);
            for (Reference_Content__c refCon : refContents) {
                refCon.OwnerId = UserInfo.getUserId();
                refCon.Reference_Content_Type__c = refContentType.Id;
            }
            insert refContents;
            String result = ExportPageController.getRecordsToExport('Content_with_Attributes__c', headersListJson.split('--------')[1] + '50',
                                                                    headersListJson.split('--------')[0], '', JSON.serialize(new List<String>()));
            system.assert(result != null);
        }
    }

    /**
     * method to test export functionality for accounts export from ref search
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForFilteredAccounts() {
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('SearchedAccounts', '', '10');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() == 14);

        // testing get export records method
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List<String> accIds = new List<String>();

        for (Account acc : accounts) {
            accIds.add(acc.Id);
        }
        String result = ExportPageController.getRecordsToExport('SearchedAccounts', '', headersListJson.split('--------')[0],
                                                                    JSON.serialize(accIds), JSON.serialize(new List<String>()));
        system.assert(result != null);
    }

    /**
     * method to test export functionality for contacts export from ref search
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForFilteredContacts() {
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('SearchedContacts', '', '10');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() == 15);

        // testing get export records method
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.setUpContactRBI(contacts);
        List<String> conIds = new List<String>();

        for (Contact con : contacts) {
            conIds.add(con.Id);
        }
        String result = ExportPageController.getRecordsToExport('SearchedContacts', '', headersListJson.split('--------')[0],
                                                                    JSON.serialize(conIds), JSON.serialize(new List<String>()));
        system.assert(result != null);
    }

    /**
     * method to test export functionality for content export from ref search
     * author: Gaurav Saini (19 Jan, 2018) for REF-1266
     */
    public static testmethod void testExportForFilteredContent() {
        // testing get headers method
        String headersListJson = ExportPageController.getHeadersList('SearchedContent', '', '');
        List<ExportPageController.HeadingWrapper> headingWrapperList
            = (List<ExportPageController.HeadingWrapper>)JSON.deserialize(headersListJson.split('--------')[0], List<ExportPageController.HeadingWrapper>.class);
        system.assert(headingWrapperList.size() == 13);

        // testing get export records method
        List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
		insert refContents;
        List<String> conIds = new List<String>();

        for (Reference_Content__c con : refContents) {
            conIds.add(con.Id);
        }
        String result = ExportPageController.getRecordsToExport('SearchedContent', '', headersListJson.split('--------')[0],
                                                                    JSON.serialize(conIds), JSON.serialize(new List<String>()));
        system.assert(result != null);
    }
}