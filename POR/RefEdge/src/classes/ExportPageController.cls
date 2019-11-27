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
 * VF Page: ExportPage.page
 * Description: Controller for downloading object records from RefedgeDM and Ref Search as a CSV file
 * Last Modified By: Gaurav Saini (2 Jan, 2018) for REF-1266
 */
public with sharing class ExportPageController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public String exportDetailsCSV { get; set; }
    public String accountIdsCSV { get; set; }
    public String contactIdsCSV { get; set; }
    public String contentIdsCSV { get; set; }
    public String exportObjectName { get; set; }
    public String rulPeriodLength { get; set; }
    public String namespace { get; set; }
    public String opportunityId { get; set; }
    public String leadId { get; set; }
    public String forAccount { get; set; }
    public String forContent { get; set; }
    public String fromLead { get; set; }
    public String baseUrl { get; set; }
    public Boolean isSLDS { get; set; }
    
    /**
     * Constructor
     */
    public ExportPageController() {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        rulPeriodLength = cs.RUL_Period__c != null ? String.valueOf(cs.RUL_Period__c) : '';
        accountIdsCSV = '';
        contactIdsCSV = '';
        contentIdsCSV = '';
        exportObjectName = '';
        exportDetailsCSV = '';
        namespace = UtilityController.appNamespace(); 

        opportunityId = ApexPages.currentPage().getParameters().get('opportunityId') != null
                        ? ApexPages.currentPage().getParameters().get('opportunityId') : '';
        leadId = ApexPages.currentPage().getParameters().get('leadId') != null
                        ? ApexPages.currentPage().getParameters().get('leadId') : '';
        forAccount = ApexPages.currentPage().getParameters().get('forAccount') != null
                        ? ApexPages.currentPage().getParameters().get('forAccount') : '';
        forContent = ApexPages.currentPage().getParameters().get('forContent') != null
                        ? ApexPages.currentPage().getParameters().get('forContent') : '';
        isSLDS = ApexPages.currentPage().getParameters().get('isSLDS') == 'true' ? true : false;
        fromLead = cs.Request_from_Leads__c == true ? 'false' : 'true' ;
        
        // Part of code merge
        if (apexPages.currentPage().getParameters().get('eo') != null) {
            exportDetailsCSV = apexPages.currentPage().getParameters().get('eo');
        } else if (ApexPages.currentPage().getParameters().get('allAccountIds') != null) {
            accountIdsCSV = ApexPages.currentPage().getParameters().get('allAccountIds');
            exportObjectName = ApexPages.currentPage().getParameters().get('exportObjectName');
        } else if (ApexPages.currentPage().getParameters().get('allContactIds') != null) {
            contactIdsCSV = ApexPages.currentPage().getParameters().get('allContactIds');
            exportObjectName = ApexPages.currentPage().getParameters().get('exportObjectName');
        } else if (ApexPages.currentPage().getParameters().get('allContentIds') != null) {
            contentIdsCSV = ApexPages.currentPage().getParameters().get('allContentIds');
            exportObjectName = ApexPages.currentPage().getParameters().get('exportObjectName');
        }
    }

    /**
     * method to get headers list for csv file
     * author: Gaurav Saini (11 Jan, 2018)
     */
    @RemoteAction
    public static String getHeadersList(String exportObject, String sortBy, String rulPeriodLength) {
        List<HeadingWrapper> headingWrapperList = new List<HeadingWrapper>();
        /*List to discard field which is already added for existing customers REF-1655*/
        Set<String> setDiscardedHeaders = new Set<String>();
        setDiscardedHeaders.add('Number_of_Download__c');
        setDiscardedHeaders.add('Rating__c');
        setDiscardedHeaders.add('Attribute_Count__c');
        setDiscardedHeaders.add('Is_File_Changed__c');
        setDiscardedHeaders.add('Ref_Content_Open_Clicks__c');
        setDiscardedHeaders.add('Ref_Content_View_Details_Clicks__c');
        setDiscardedHeaders.add('Content_Type__c');
        setDiscardedHeaders.add('Reference_Content_Type_Name__c');

        String query = 'SELECT ';
        
        if (exportObject == 'Reference_Content__c') {
            
            for (Data_Mapping__c field : [SELECT Name, Id, Order__c, Object__c, Required__c, Label__c, Visible__c, Field_API_Name__c
                                            FROM Data_Mapping__c
                                            WHERE (Object__c = :ConstantsController.DMContentVersion
                                            OR Object__c = :ConstantsController.DM_REFERENCE_CONTENT )
                                            AND Visible__c = true 
                                            ORDER BY Order__c ASC NULLS LAST LIMIT :Limits.getLimitQueryRows()]) {
                headingWrapperList.add(new HeadingWrapper(field.Field_API_Name__c, field.Label__c, field.Object__c));
                
                if (field.Object__c == ConstantsController.DM_REFERENCE_CONTENT) {
                    query += field.Field_API_Name__c + ', ';
                }
            }

            if (!query.contains(UtilityController.appNamespace() + 'Content_ID__c')) {
                query += UtilityController.appNamespace() + 'Content_ID__c' + ', ';
            }
            if (!query.contains(UtilityController.appNamespace() + 'Content_URL2__c')) {
                query += UtilityController.appNamespace() + 'Content_URL2__c' + ', ';
            }
            headingWrapperList.add(new HeadingWrapper('Is_Thumbnail_Attached', 'Is Thumbnail Attached', 'DMReference_Content__c'));
            query = query.removeEnd(', ');
            query += ',(SELECT Id from Attachments WHERE Name = \'documentThumbnail.jpg\') FROM Reference_Content__c WHERE Id NOT IN :alreadyFetchedIds'
                    + ' ORDER BY ' + String.escapeSingleQuotes(sortBy) + ' ASC NULLS LAST '
                    + 'LIMIT ';
        } else if (exportObject == 'Template') {
            query += 'Name, Id, Object__c, Order__c, Required__c, Label__c, Visible__c, Field_API_Name__c '
                    + 'FROM Data_Mapping__c WHERE ( Object__c = \'DM' + String.escapeSingleQuotes(sortBy.trim()) + '\' '
                    + (String.escapeSingleQuotes(sortBy.trim()) == 'Reference_Content__c' ? 'OR Object__c = \'DMContentVersion\' ) ' : ') ')
                    + 'AND Visible__c = true AND Field_API_Name__c NOT IN :setDiscardedHeaders '
                    + 'ORDER BY Visible__c DESC, Order__c ASC NULLS LAST LIMIT ' + Limits.getLimitQueryRows();

            for (Data_Mapping__c field : Database.query(query)) {
                headingWrapperList.add(new HeadingWrapper(field.Field_API_Name__c, field.Label__c, field.Object__c));
            }
            query = '';
        } else if (exportObject == 'Attribute__c') {
            
            for (Data_Mapping__c field : [SELECT Name, Id, Order__c, Object__c, Required__c, Label__c, Visible__c, Field_API_Name__c
                                            FROM Data_Mapping__c
                                            WHERE Object__c = 'DMAttribute__c'
                                            AND Visible__c = true
                                            ORDER BY Order__c ASC NULLS LAST LIMIT :Limits.getLimitQueryRows()]) {
                headingWrapperList.add(new HeadingWrapper(field.Field_API_Name__c, field.Label__c, field.Object__c));
                query += field.Field_API_Name__c + ', ';
            }
            query = query.removeEnd(', ');
            query += ' FROM Attribute__c ORDER BY Level__c ASC LIMIT ';
        } else if (exportObject == 'Library__c') {
            headingWrapperList.add(new HeadingWrapper('Id', 'Id'));
            headingWrapperList.add(new HeadingWrapper('Name', 'Name'));
            query = '';
        } else if (exportObject == 'Account') {
            headingWrapperList.add(new HeadingWrapper('Id', 'Id'));
            headingWrapperList.add(new HeadingWrapper('Name', 'Name'));
            query = '';
        } else if (exportObject == 'Contact') {
            headingWrapperList.add(new HeadingWrapper('Id', 'Id'));
            headingWrapperList.add(new HeadingWrapper('Name', 'Name'));
            query = '';
        } else if (exportObject == 'Label__c') {
            
            for (Data_Mapping__c field : [SELECT Name, Id, Order__c, Object__c, Required__c, Label__c, Visible__c, Field_API_Name__c
                                            FROM Data_Mapping__c
                                            WHERE Object__c = 'DMLabel__c'
                                            AND Visible__c = true
                                            ORDER BY Order__c ASC NULLS LAST LIMIT :Limits.getLimitQueryRows()]) {
                headingWrapperList.add(new HeadingWrapper(field.Field_API_Name__c, field.Label__c, field.Object__c));
                query += field.Field_API_Name__c + ', ';
            }
            query = query.removeEnd(', ');
            query += ' FROM Label__c LIMIT ';
        } else if (exportObject == 'Referenceability_Type__c') {
            
            for (Data_Mapping__c field : [SELECT Name, Id, Order__c, Object__c, Required__c, Label__c, Visible__c, Field_API_Name__c
                                            FROM Data_Mapping__c
                                            WHERE Object__c = 'DMReferenceability_Type__c'
                                            AND Visible__c = true
                                            ORDER BY Order__c ASC NULLS LAST LIMIT :Limits.getLimitQueryRows()]) {
                headingWrapperList.add(new HeadingWrapper(field.Field_API_Name__c, field.Label__c, field.Object__c));
                query += field.Field_API_Name__c + ', ';
            }
            query = query.removeEnd(', ');
            query += ' FROM Referenceability_Type__c LIMIT ';
        } else if (exportObject == 'Reference_Content_Type__c') {
            
            for (Data_Mapping__c field : [SELECT Name, Id, Order__c, Object__c, Required__c, Label__c, Visible__c, Field_API_Name__c
                                            FROM Data_Mapping__c
                                            WHERE Object__c = 'DMReference_Content_Type__c'
                                            AND Visible__c = true
                                            ORDER BY Order__c ASC NULLS LAST LIMIT :Limits.getLimitQueryRows()]) {
                headingWrapperList.add(new HeadingWrapper(field.Field_API_Name__c, field.Label__c, field.Object__c));
                query += field.Field_API_Name__c + ', ';
            }
            query = query.removeEnd(', ');
            query += ' FROM Reference_Content_Type__c LIMIT ';
        } else if (exportObject == 'Reference_Basic_Information__c') {

            for (Data_Mapping__c field : [SELECT Name, Id, Order__c, Object__c, Required__c, Label__c, Visible__c, Field_API_Name__c
                                            FROM Data_Mapping__c
                                            WHERE Object__c = 'DMReference_Basic_Information__c'
                                            AND Visible__c = true
                                            ORDER BY Order__c ASC NULLS LAST LIMIT :Limits.getLimitQueryRows()]) {
                headingWrapperList.add(new HeadingWrapper(field.Field_API_Name__c, field.Label__c, field.Object__c));
                query += field.Field_API_Name__c + ', ';
            }
            query = query.removeEnd(', ');
            query += ' FROM Reference_Basic_Information__c ORDER BY ' + String.escapeSingleQuotes(sortBy)
                    + ' ASC NULLS LAST LIMIT ';
        } else if (exportObject == 'Unspecified_Request__c') {

            for (Data_Mapping__c field : [SELECT Name, Id, Order__c, Object__c, Required__c, Label__c, Visible__c, Field_API_Name__c
                                            FROM Data_Mapping__c
                                            WHERE Object__c = 'DMUnspecified_Request__c'
                                            AND Visible__c = true
                                            ORDER BY Order__c ASC NULLS LAST LIMIT :Limits.getLimitQueryRows()]) {
                headingWrapperList.add(new HeadingWrapper(field.Field_API_Name__c, field.Label__c, field.Object__c));
                query += field.Field_API_Name__c + ', ';
            }
            query = query.removeEnd(', ');
            query += ' FROM Unspecified_Request__c ORDER BY ' + String.escapeSingleQuotes(sortBy)
                    + ' ASC NULLS LAST LIMIT ';
        } else if (exportObject == 'Reference_Request_Account__c') {

            for (Data_Mapping__c field : [SELECT Name, Id, Order__c, Object__c, Required__c, Label__c, Visible__c, Field_API_Name__c
                                            FROM Data_Mapping__c
                                            WHERE Object__c = 'DMReference_Request_Account__c'
                                            AND Visible__c = true
                                            ORDER BY Order__c ASC NULLS LAST LIMIT :Limits.getLimitQueryRows()]) {
                headingWrapperList.add(new HeadingWrapper(field.Field_API_Name__c, field.Label__c, field.Object__c));
                query += field.Field_API_Name__c + ', ';
            }
            headingWrapperList.add(new HeadingWrapper('Reference_Request_Account_Contacts__c', 'Contact Requests', 'DMReference_Request_Account__c'));
            query += ' (SELECT Id FROM Reference_Request_Account_Contacts__r) FROM Reference_Request_Account__c ORDER BY ' + String.escapeSingleQuotes(sortBy)
                    + ' ASC NULLS LAST LIMIT ';
        } else if (exportObject == 'Account_with_Attributes__c') {
            headingWrapperList.add(new HeadingWrapper('AccountName', 'Account Name', true));
            headingWrapperList.add(new HeadingWrapper('AccountId', 'Account Id', true));
            headingWrapperList.add(new HeadingWrapper('Name', 'Ref Profile Name', true));
            headingWrapperList.add(new HeadingWrapper('Id', 'Ref Profile ID', true));

            for (Attribute_Mapping__c attMapping : [SELECT Related_Object__c, Attribute_Name__c, Field_Api_Name__c
                                                    FROM Attribute_Mapping__c
                                                    WHERE Is_Related_Mapping__c = true
                                                    AND Object__c = 'Reference Profile'
                                                    AND Mapping_Type__c = 'Parent Object'
                                                    AND Related_Object__c = 'Account'
                                                    LIMIT :Limits.getLimitQueryRows()]) {
                
                if (attMapping.Field_API_Name__c != 'Name') {
                    String fieldApiName = 'Account__r.' + attMapping.Field_Api_Name__c;
                    headingWrapperList.add(new HeadingWrapper(fieldApiName, attMapping.Attribute_Name__c, true));
                    query += fieldApiName + ', ';
                }
            }

            for (Attribute__c att : [SELECT Id, Name, ParentIds__c, Level__c
                                        FROM Attribute__c WHERE Level__c = 0
                                        LIMIT :Limits.getLimitQueryRows()]) {
                headingWrapperList.add(new HeadingWrapper(att.Id, att.Name, false));
            }
            query += 'Id, Name, Account__c, Account__r.Name, Attribute_Ids__c FROM Reference_Basic_Information__c '
                    + 'WHERE Contact__c = null ORDER BY ' + String.escapeSingleQuotes(sortBy) + ' ASC '
                    + 'LIMIT ';
        } else if (exportObject == 'Contact_with_Attributes__c') {
            headingWrapperList.add(new HeadingWrapper('ContactLName', 'Contact Last Name', true));
            headingWrapperList.add(new HeadingWrapper('ContactFName', 'Contact First Name', true));
            headingWrapperList.add(new HeadingWrapper('ContactId', 'Contact ID', true));
            headingWrapperList.add(new HeadingWrapper('Name', 'Ref Profile Name', true));
            headingWrapperList.add(new HeadingWrapper('Id', 'Ref Profile ID', true));

            for (Attribute_Mapping__c attMapping : [SELECT Related_Object__c, Attribute_Name__c, Field_Api_Name__c
                                                    FROM Attribute_Mapping__c
                                                    WHERE Is_Related_Mapping__c = true
                                                    AND Object__c = 'Reference Profile'
                                                    AND Mapping_Type__c = 'Parent Object'
                                                    AND Related_Object__c = 'Contact'
                                                    LIMIT :Limits.getLimitQueryRows()]) {
                if (attMapping.Field_Api_Name__c != 'FirstName' && attMapping.Field_Api_Name__c != 'LastName') {
                    String fieldApiName = 'Contact__r.' + attMapping.Field_Api_Name__c;
                    headingWrapperList.add(new HeadingWrapper(fieldApiName, attMapping.Attribute_Name__c, true));
                    query += fieldApiName + ', ';
                }
            }

            for (Attribute__c att : [SELECT Id, Name, ParentIds__c, Level__c
                                        FROM Attribute__c WHERE Level__c = 0
                                        LIMIT :Limits.getLimitQueryRows()]) {
                headingWrapperList.add(new HeadingWrapper(att.Id, att.Name, false));
            }
            query += 'Id, Name, Contact__c, Contact__r.LastName, Contact__r.FirstName, Attribute_Ids__c '
                    + 'FROM Reference_Basic_Information__c WHERE Contact__c != null '
                    + 'ORDER BY ' + String.escapeSingleQuotes(sortBy) + ' ASC '
                    + 'LIMIT ';
        } else if (exportObject == 'Content_with_Attributes__c') {
            headingWrapperList.add(new HeadingWrapper('ContentName', 'Content Name', true));
            headingWrapperList.add(new HeadingWrapper('ContentTitle', 'Content Title', true));
            headingWrapperList.add(new HeadingWrapper('ContentType', 'Content Type', true));
            headingWrapperList.add(new HeadingWrapper('ContentId', 'Content Id', true));

            for (Attribute_Mapping__c attMapping : [SELECT Related_Object__c, Attribute_Name__c, Field_Api_Name__c
                                                    FROM Attribute_Mapping__c
                                                    WHERE Is_Related_Mapping__c = true
                                                    AND Object__c = 'Reference Content'
                                                    AND Mapping_Type__c = 'Parent Object'
                                                    LIMIT :Limits.getLimitQueryRows()]) {
                String fieldApiName = '';
                
                if (attMapping.Related_Object__c == 'Reference_Content_Type__c') {
                    fieldApiName = 'Reference_Content_Type__r.' + attMapping.Field_Api_Name__c;
                    headingWrapperList.add(new HeadingWrapper(fieldApiName, attMapping.Attribute_Name__c, true));
                    query += fieldApiName + ', ';
                } else if (attMapping.Related_Object__c == 'User') {
                    fieldApiName = 'Owner.' + attMapping.Field_Api_Name__c;
                    headingWrapperList.add(new HeadingWrapper(fieldApiName, attMapping.Attribute_Name__c, true));
                    query += fieldApiName + ', ';
                } 
            }

            for (Attribute__c att : [SELECT Id, Name, ParentIds__c, Level__c
                                        FROM Attribute__c WHERE Level__c = 0
                                        LIMIT :Limits.getLimitQueryRows()]) {
                headingWrapperList.add(new HeadingWrapper(att.Id, att.Name, false));
            }
            query += 'Id, Name, Title__c, Reference_Content_Type_Name__c, Content_ID__c, Attribute_Ids__c ,Content_URL__c, Content_URL2__c '
                    + ',(SELECT Id FROM Attachments WHERE Name = \'documentThumbnail.jpg\') FROM Reference_Content__c ORDER BY ' + String.escapeSingleQuotes(sortBy) + ' ASC '
                    + 'LIMIT ';
        } else if (exportObject == 'SearchedAccounts') {
            headingWrapperList.add(new HeadingWrapper('AccountName', 'Account Name'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Ref_Profile_Summary__c', 'Description'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Attributes__c', 'Attributes'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Referenceability__c', 'Referenceability'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'RUL_Last_Activity_Date__c', 'Last Use date'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Default_Period_Completed_Uses__c', 'Last ' + rulPeriodLength + ' Days'));
            headingWrapperList.add(new HeadingWrapper('OwnerName', 'Owner'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Account__c', 'Account SalesforceID'));
            headingWrapperList.add(new HeadingWrapper('Name', 'Reference Profile Name'));
            headingWrapperList.add(new HeadingWrapper('Id', 'Reference Profile ID'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'RUL_Activities_available__c', 'Available Uses'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'RUL_Activities_used__c', 'Completed Uses'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'RUL_Activities_will_do__c', 'Uses Per Time Period'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'RUL_Period__c', 'Time Period'));
            query = '';
        } else if (exportObject == 'SearchedContacts') {
            headingWrapperList.add(new HeadingWrapper('ContactName', 'Contact Name'));
            headingWrapperList.add(new HeadingWrapper('AccountName', 'Account Name'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Ref_Profile_Summary__c', 'Description'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Attributes__c', 'Attributes'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Referenceability__c', 'Referenceability'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'RUL_Last_Activity_Date__c', 'Last Use date'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Default_Period_Completed_Uses__c', 'Last ' + rulPeriodLength + ' Days'));
            headingWrapperList.add(new HeadingWrapper('OwnerName', 'Owner'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Contact__c', 'Contact SalesforceID'));
            headingWrapperList.add(new HeadingWrapper('Name', 'Reference Profile Name'));
            headingWrapperList.add(new HeadingWrapper('Id', 'Reference Profile ID'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'RUL_Activities_available__c', 'Available Uses'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'RUL_Activities_used__c', 'Completed Uses'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'RUL_Activities_will_do__c', 'Uses Per Time Period'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'RUL_Period__c', 'Time Period'));
            query = '';
        } else if (exportObject == 'SearchedContent') {
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Title__c', 'Content Title'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Reference_Content_Type_Name__c', 'Content Type'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Language__c', 'Content Language'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Internal_Use__c', 'Internal Use'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Featured_Content__c', 'Featured Content'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Associated_Accounts__c', 'Associated Accounts'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Substitute_Account_Name__c', 'Substitute Account Name'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'External_Summary__c', 'External Summary'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Summary__c', 'Summary'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Attributes__c', 'Attributes'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Publish_date__c', 'Publish Date'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Content_URL__c', 'Content URL'));
            headingWrapperList.add(new HeadingWrapper(UtilityController.appNamespace() + 'Is_Thumbnail_Attached', 'Is Thumbnail Attached'));
            query = '';
        }
        return JSON.serialize(headingWrapperList) + '--------' + query;
    }

    /**
     * method to get attributes map for gap analysis export
     * author: Gaurav Saini (11 Jan, 2018)
     */
    @RemoteAction
    public static String getAttributesMapForGapAnalysis() {
        Map<String, AttributeWrapper> attMap = new Map<String, AttributeWrapper>();

        for (Attribute__c att : [SELECT Id, Name, ParentIds__c
                                    FROM Attribute__c WHERE Level__c != 0
                                    LIMIT :Limits.getLimitQueryRows()]) {
            attMap.put(att.Id, new AttributeWrapper(att));
        }
        return JSON.serialize(attMap);
    }

    /**
     * method to get filters map when exporting reference profiles
     * used to convert filter codes to filter ids
     * author: Gaurav Saini (11 Jan, 2018)
     */
    @RemoteAction
    public static String getFiltersMapForRBIExport() {
        Map<String, String> filtersMap = new Map<String, String>();

        for (Label__c lbl : [SELECT Id, Filter_no__c FROM Label__c
                                WHERE Filter_no__c != null LIMIT :Limits.getLimitQueryRows()]) {
            filtersMap.put(String.valueOf(lbl.Filter_no__c), lbl.Id);
        }
        return JSON.serialize(filtersMap);
    }

    /**
     * method to get filters map when exporting reference profiles
     * used to convert filter codes to filter ids
     * author: Gaurav Saini (11 Jan, 2018)
     */
    @RemoteAction
    public static String getRefTypesMapForRBIExport() {
        Map<String, String> refTypesMap = new Map<String, String>();

        for (Referenceability_Type__c ref : [SELECT Id, Referenceability_no__c
                                                FROM Referenceability_Type__c
                                                WHERE Referenceability_no__c != null
                                                AND Sales_Reward__c = false LIMIT :Limits.getLimitQueryRows()]) {
            refTypesMap.put(String.valueOf(ref.Referenceability_no__c), ref.Id);
        }
        return JSON.serialize(refTypesMap);
    }

     /**
     * method to get Associated account Ids with reference Content
     * used to convert filter codes to filter ids
     * author:Rajesh (1 May, 2018), REF-1557
     */
    @RemoteAction
    public static String getAssociatedAccountsToExport(String Id) {
    	String accIds = '';
    	
    	for (Account_Reference_Content__c rc : [SELECT Account__c FROM Account_Reference_Content__c 
	        												WHERE Reference_Content__c = :Id ORDER BY Name LIMIT :limits.getLimitQueryRows()]) { 
             accIds += rc.Account__c + ',';
		}
	    
	    if (!String.isBlank(accIds)) {
	    	accIds = accIds.removeEnd(',');
	    }   
    	return accIds;     
    }

    /**
     * method to get footer information for the export file
     * author: Gaurav Saini (11 Jan, 2018)
     */
    @RemoteAction
    public static String getFooterData() {
        List<String> footerData = new List<String> {'Confidential Information: Do Not Distribute',
                                                'Generated By: ' + UserInfo.getName() + ' ' + DateTime.now().format(),
                                                'Organization: ' + UserInfo.getOrganizationName()};
        return JSON.serialize(footerData);
    }

    /**
     * method to get records for export
     * author: Gaurav Saini (11 Jan, 2018)
     */
    @RemoteAction
    public static String getRecordsToExport(String exportObject, String query, String headingListJson,
                                            String recordIdsJson, String alreadyFetchedIdsJson) {
        List<Object> exportRecordsList;
        List<HeadingWrapper> headingWrapperList = (List<HeadingWrapper>)JSON.deserialize(headingListJson, List<HeadingWrapper>.class);
        List<String> alreadyFetchedIds = (List<String>)JSON.deserialize(alreadyFetchedIdsJson, List<String>.class);

        if (exportObject == 'Reference_Content__c') {
            exportRecordsList = new List<Map<String, String>>();
            String recordId = '';
            //#REF-1592 : Get CV Record Details
            Map<Id,ContentVersion> cvMap = new Map<Id,ContentVersion>();
            Set<Id> cvIdSet = new Set<Id>();
            List<Reference_Content__c> records = Database.query(query);
            String queryCV = 'SELECT ID, ';
            
            for (HeadingWrapper heading : headingWrapperList) {
                
                if (heading.objectName == ConstantsController.DMContentVersion) {
                    queryCV += heading.apiName + ', ';
                }
            }
            
            for (Reference_Content__c rc : records) {
                cvIdSet.add(rc.Content_ID__c);
            }
            queryCV = queryCV.removeEnd(', ');
            queryCV += ' FROM ContentVersion WHERE Id in :cvIdSet';
            cvMap = new Map<Id, ContentVersion> ((List<ContentVersion>)Database.query(queryCV)); 
            
            for (Reference_Content__c rc : records) {
                Map<String, String> tempRefContent = new Map<String, String>();
                
                for (HeadingWrapper heading : headingWrapperList) {
                    // re REF-1557 - Check for Associated Accounts for Ref Content
                    if (heading.objectName == ConstantsController.DM_REFERENCE_CONTENT) {

                        if (exportObject == 'Reference_Content__c' && heading.apiName == 'Id') {
                            recordId = String.valueOf(rc.get(heading.apiName));
                        } 
                        if (exportObject == 'Reference_Content__c' && heading.apiName == UtilityController.appNamespace() + 'Associated_Accounts__c') {
                            tempRefContent.put(heading.apiName, rc.get(heading.apiName) != null ? getAssociatedAccountsToExport(recordId) : '');
                        } else if (exportObject == 'Reference_Content__c' && heading.apiName == UtilityController.appNamespace() + 'Content_URL__c') {
                            tempRefContent.put(heading.apiName, rc.Content_URL__c != null ? rc.Content_URL__c + (rc.Content_URL2__c == null ? '' : rc.Content_URL2__c) : '');
                        } else if (heading.apiName == 'Is_Thumbnail_Attached') {
                            tempRefContent.put(heading.apiName, rc.Attachments.size() == 0 ? 'False' : 'True');
                        } else if (heading.apiName != UtilityController.appNamespace() + 'Content_URL2__c') {
                            tempRefContent.put(heading.apiName, rc.get(heading.apiName) != null ? String.valueOf(rc.get(heading.apiName)) : '');
                        } 
                        
                    } else if (heading.objectName == ConstantsController.DMContentVersion && !tempRefContent.containsKey(heading.apiName)) {
                        //#REF-1592 : Populate fields for CV in Export map
                        if (rc.Content_ID__c!= null && rc.Content_ID__c != '' && cvMap.containsKey(rc.Content_ID__c)) {
                            tempRefContent.put(heading.apiName, cvMap.get(rc.Content_ID__c).get(heading.apiName) != null ? String.valueOf(cvMap.get(rc.Content_ID__c).get(heading.apiName)) : '');
                        } 
                    }
                }
                exportRecordsList.add(tempRefContent);
            }
        } else if (exportObject == 'Attribute__c') {
            exportRecordsList = new List<Map<String, String>>();
            
            for (Attribute__c att : Database.query(query)) {
                Map<String, String> tempAtt = new Map<String, String>();
                
                for (HeadingWrapper heading : headingWrapperList) {
                    tempAtt.put(heading.apiName, att.get(heading.apiName) != null ? String.valueOf(att.get(heading.apiName)) : '');
                }
                exportRecordsList.add(tempAtt);
            }
        } else if (exportObject == 'Label__c') {
            exportRecordsList = new List<Map<String, String>>();
            
            for (Label__c att : Database.query(query)) {
                Map<String, String> tempAtt = new Map<String, String>();
                
                for (HeadingWrapper heading : headingWrapperList) {
                    tempAtt.put(heading.apiName, att.get(heading.apiName) != null ? String.valueOf(att.get(heading.apiName)) : '');
                }
                exportRecordsList.add(tempAtt);
            }
        } else if (exportObject == 'Library__c') {
            exportRecordsList = new List<Object>();
            Integer queryLimit = Integer.valueOf(query);

            for (ContentWorkspace cw : [SELECT Id, Name FROM ContentWorkspace
                                        WHERE Id NOT IN :alreadyFetchedIds
                                        LIMIT :queryLimit]) {
                exportRecordsList.add(cw);
            }
        } else if (exportObject == 'Account') {
            exportRecordsList = new List<Object>();
            Integer queryLimit = Integer.valueOf(query);

            for (Account acc : [SELECT Id, Name FROM Account
                                WHERE Id NOT IN :alreadyFetchedIds
                                LIMIT :queryLimit]) {
                exportRecordsList.add(acc);
            }
        } else if (exportObject == 'Contact') {
            exportRecordsList = new List<Object>();
            Integer queryLimit = Integer.valueOf(query);

            for (Contact con : [SELECT Id, Name FROM Contact
                                WHERE Id NOT IN :alreadyFetchedIds
                                LIMIT :queryLimit]) {
                exportRecordsList.add(con);
            }
        } else if (exportObject == 'Referenceability_Type__c') {
            exportRecordsList = new List<Map<String, String>>();

            for (Referenceability_Type__c refType : Database.query(query)) {
                Map<String, String> tempRefType = new Map<String, String>();
                
                for (HeadingWrapper heading : headingWrapperList) {
                    tempRefType.put(heading.apiName, refType.get(heading.apiName) != null ? String.valueOf(refType.get(heading.apiName)) : '');
                }
                exportRecordsList.add(tempRefType);
            }
        } else if (exportObject == 'Reference_Content_Type__c') {
            exportRecordsList = new List<Map<String, String>>();

            for (Reference_Content_Type__c rct : Database.query(query)) {
                Map<String, String> tempRCT = new Map<String, String>();
                
                for (HeadingWrapper heading : headingWrapperList) {
                    tempRCT.put(heading.apiName, rct.get(heading.apiName) != null ? String.valueOf(rct.get(heading.apiName)) : '');
                }
                exportRecordsList.add(tempRCT);
            }
        } else if (exportObject == 'Reference_Request_Account__c') {
            exportRecordsList = new List<Map<String, String>>();

            for (Reference_Request_Account__c request : Database.query(query)) {
                Map<String, String> tempRBI = new Map<String, String>();
                
                for (HeadingWrapper heading : headingWrapperList) {
                    if (heading.apiName != 'Reference_Request_Account_Contacts__c')
                    tempRBI.put(heading.apiName, request.get(heading.apiName) != null ? String.valueOf(request.get(heading.apiName)) : '');
                }
                if (request.Reference_Request_Account_Contacts__r.size() > 0 ) {
                    String crId = '';
                    for (Reference_Request_Account_Contact__c conReq: request.Reference_Request_Account_Contacts__r) {
                        crId += conReq.Id + ',' ;
                    }
                    crId = crId.removeEnd(',');
                    tempRBI.put('Reference_Request_Account_Contacts__c',crId);
                }
                exportRecordsList.add(tempRBI);
            }
        } else if (exportObject == 'Unspecified_Request__c') {
            exportRecordsList = new List<Map<String, String>>();

            for (Unspecified_Request__c request : Database.query(query)) {
                Map<String, String> tempRBI = new Map<String, String>();
                
                for (HeadingWrapper heading : headingWrapperList) {
                    tempRBI.put(heading.apiName, request.get(heading.apiName) != null ? String.valueOf(request.get(heading.apiName)) : '');
                }
                exportRecordsList.add(tempRBI);
            }
        } else if (exportObject == 'Reference_Basic_Information__c') {
            exportRecordsList = new List<Map<String, String>>();

            for (Reference_Basic_Information__c rbi : Database.query(query)) {
                Map<String, String> tempRBI = new Map<String, String>();
                
                for (HeadingWrapper heading : headingWrapperList) {
                    tempRBI.put(heading.apiName, rbi.get(heading.apiName) != null ? String.valueOf(rbi.get(heading.apiName)) : '');
                }
                exportRecordsList.add(tempRBI);
            }
        } else if (exportObject == 'Account_with_Attributes__c') {
            exportRecordsList = new List<Map<String, String>>();
            headingWrapperList.add(new HeadingWrapper('attributeIdsCSV', ''));

            for (Reference_Basic_Information__c rbi : Database.query(query)) {
                Map<String, String> tempRBI = new Map<String, String>();

                for (HeadingWrapper heading : headingWrapperList) {
                    
                    if (heading.apiName == 'AccountName') {
                        tempRBI.put(heading.apiName, rbi.Account__r.Name);
                    } else if (heading.apiName == 'AccountId') {
                        tempRBI.put(heading.apiName, rbi.Account__c);
                    } else if (heading.apiName == 'Name') {
                        tempRBI.put(heading.apiName, rbi.Name);
                    } else if (heading.apiName == 'Id') {
                        tempRBI.put(heading.apiName, rbi.Id);
                    } else if (heading.apiName.contains('Account__r')) {
                        tempRBI.put(heading.apiName,
                                String.valueOf(rbi.getSobject('Account__r').get(heading.apiName.substringAfter('.'))) != ''
                                    && String.valueOf(rbi.getSobject('Account__r').get(heading.apiName.substringAfter('.'))) != null
                                    ? String.valueOf(rbi.getSobject('Account__r').get(heading.apiName.substringAfter('.'))) : '');
                    } else if (heading.apiName == 'attributeIdsCSV') {
                        tempRBI.put(heading.apiName, rbi.Attribute_Ids__c != null ? String.valueOf(rbi.Attribute_Ids__c) : '');
                    }
                }
                exportRecordsList.add(tempRBI);
            }
        } else if (exportObject == 'Contact_with_Attributes__c') {
            exportRecordsList = new List<Map<String, String>>();
            headingWrapperList.add(new HeadingWrapper('attributeIdsCSV', ''));

            for (Reference_Basic_Information__c rbi : Database.query(query)) {
                Map<String, String> tempRBI = new Map<String, String>();

                for (HeadingWrapper heading : headingWrapperList) {
                    
                    if (heading.apiName == 'ContactFName') {
                        tempRBI.put(heading.apiName, rbi.Contact__r.FirstName != null ? rbi.Contact__r.FirstName : '');
                    } else if (heading.apiName == 'ContactLName') {
                        tempRBI.put(heading.apiName, rbi.Contact__r.LastName);
                    } else if (heading.apiName == 'ContactId') {
                        tempRBI.put(heading.apiName, rbi.Contact__c);
                    } else if (heading.apiName == 'Name') {
                        tempRBI.put(heading.apiName, rbi.Name);
                    } else if (heading.apiName == 'Id') {
                        tempRBI.put(heading.apiName, rbi.Id);
                    } else if (heading.apiName.contains('Contact__r')) {
                         tempRBI.put(heading.apiName,
                                String.valueOf(rbi.getSobject('Contact__r').get(heading.apiName.substringAfter('.'))) != ''
                                    && String.valueOf(rbi.getSobject('Contact__r').get(heading.apiName.substringAfter('.'))) != null
                                    ? String.valueOf(rbi.getSobject('Contact__r').get(heading.apiName.substringAfter('.'))) : '');
                    } else if (heading.apiName == 'attributeIdsCSV') {
                        tempRBI.put(heading.apiName, rbi.Attribute_Ids__c != null ? String.valueOf(rbi.Attribute_Ids__c) : '');
                    }
                }
                exportRecordsList.add(tempRBI);
            }
        } else if (exportObject == 'Content_with_Attributes__c') {
            exportRecordsList = new List<Map<String, String>>();
            headingWrapperList.add(new HeadingWrapper('attributeIdsCSV', ''));

            for (Reference_Content__c rc : Database.query(query)) {
                Map<String, String> tempRC = new Map<String, String>();

                for (HeadingWrapper heading : headingWrapperList) {
                    
                    if (heading.apiName == 'ContentName') {
                        tempRC.put(heading.apiName, rc.Name);
                    } else if (heading.apiName == 'ContentTitle') {
                        tempRC.put(heading.apiName, rc.Title__c);
                    } else if (heading.apiName == 'ContentType') {
                        tempRC.put(heading.apiName, rc.Reference_Content_Type_Name__c);
                    } else if (heading.apiName == 'ContentId') {
                        tempRC.put(heading.apiName, rc.Id);
                    } else if (heading.apiName.contains('Reference_Content_Type__r')) {
                        tempRC.put(heading.apiName,
                                String.valueOf(rc.getSobject('Reference_Content_Type__r').get(heading.apiName.substringAfter('.'))) != ''
                                && String.valueOf(rc.getSobject('Reference_Content_Type__r').get(heading.apiName.substringAfter('.'))) != null
                                ? String.valueOf(rc.getSobject('Reference_Content_Type__r').get(heading.apiName.substringAfter('.'))) : '');
                    } else if (heading.apiName.contains('Owner')) {
                        tempRC.put(heading.apiName,
                                String.valueOf(rc.getSobject('Owner').get(heading.apiName.substringAfter('.'))) != ''
                                && String.valueOf(rc.getSobject('Owner').get(heading.apiName.substringAfter('.'))) != null
                                ? String.valueOf(rc.getSobject('Owner').get(heading.apiName.substringAfter('.'))) : '');
                    } else if (heading.apiName == 'attributeIdsCSV') {
                        tempRC.put(heading.apiName, rc.Attribute_Ids__c != null ? String.valueOf(rc.Attribute_Ids__c) : '');
                    } 
                }
                exportRecordsList.add(tempRC);
            }
        } else if (exportObject == 'SearchedAccounts') {
            exportRecordsList = new List<Map<String, String>>();
            Set<String> accIds = (Set<String>)JSON.deserialize(recordIdsJson, Set<String>.class);

            for (Reference_Basic_Information__c accRBI : [SELECT Name, Account__c, Account__r.Name, Account__r.Owner.Name, Referenceability__c,
                                                            Reference_Owner__r.Name, Reference_Owner__c, Attributes__c, RUL_Activities_used__c,
                                                            RUL_Last_Activity_Date__c, Default_Period_Completed_Uses__c, RUL_Activities_available__c,
                                                            RUL_Activities_will_do__c, RUL_Period__c, Ref_Profile_Summary__c
                                                            FROM Reference_Basic_Information__c
                                                            WHERE Account__c IN :accIds
                                                            AND Account__c != null
                                                            AND Contact__c = null
                                                            AND Is_Referenceable__c = true
                                                            AND (Referenceability_Status__c != :ConstantsController.INACTIVE
                                                                AND Referenceability_Status__c != '')
                                                            ORDER BY Account__r.Name LIMIT :Limits.getLimitQueryRows()]) {
                Map<String, String> tempAccRBI = new Map<String, String>();
                
                for (HeadingWrapper heading : headingWrapperList) {
                    
                    if (heading.apiName == 'AccountName') {
                        tempAccRBI.put(heading.apiName, (accRBI.Account__r.Name).replaceAll('"', '\''));
                    } else if (heading.apiName == 'OwnerName') {
                        tempAccRBI.put(heading.apiName, (accRBI.Reference_Owner__c != null ? accRBI.Reference_Owner__r.Name : accRBI.Account__r.Owner.Name).replaceAll('"', '\''));
                    } else {
                        tempAccRBI.put(heading.apiName, accRBI.get(heading.apiName) != null ? String.valueOf(accRBI.get(heading.apiName)).replaceAll('"', '\'') : '');
                    }
                }
                exportRecordsList.add(tempAccRBI);
            }
        } else if (exportObject == 'SearchedContacts') {
            exportRecordsList = new List<Map<String, String>>();
            Set<String> conIds = (Set<String>)JSON.deserialize(recordIdsJson, Set<String>.class);

            for (Reference_Basic_Information__c conRBI : [SELECT Name, Account__c, Account__r.Name, Contact__r.Owner.Name, Referenceability__c,
                                                            Reference_Owner__r.Name, Reference_Owner__c, Attributes__c, RUL_Activities_used__c,
                                                            RUL_Last_Activity_Date__c, Default_Period_Completed_Uses__c, RUL_Activities_available__c,
                                                            RUL_Activities_will_do__c, RUL_Period__c, Contact__c, Contact__r.Name, Ref_Profile_Summary__c
                                                            FROM Reference_Basic_Information__c
                                                            WHERE Contact__c IN :conIds
                                                            AND Account__c != null
                                                            AND Contact__c != null
                                                            AND Is_Referenceable__c = true
                                                            AND (Referenceability_Status__c != :ConstantsController.INACTIVE
                                                                AND Referenceability_Status__c != '')
                                                            ORDER BY Contact__r.Name LIMIT :Limits.getLimitQueryRows()]) {
                Map<String, String> tempConRBI = new Map<String, String>();
                
                for (HeadingWrapper heading : headingWrapperList) {
                    
                    if (heading.apiName == 'ContactName') {
                        tempConRBI.put(heading.apiName, conRBI.Contact__r.Name.replaceAll('"', '\''));
                    } else if (heading.apiName == 'AccountName') {
                        tempConRBI.put(heading.apiName, conRBI.Account__r.Name.replaceAll('"', '\''));
                    } else if (heading.apiName == 'OwnerName') {
                        tempConRBI.put(heading.apiName, (conRBI.Reference_Owner__c != null ? conRBI.Reference_Owner__r.Name : conRBI.Contact__r.Owner.Name).replaceAll('"', '\''));
                    } else {
                        tempConRBI.put(heading.apiName, conRBI.get(heading.apiName) != null ? String.valueOf(conRBI.get(heading.apiName)).replaceAll('"', '\'') : '');
                    }
                }
                exportRecordsList.add(tempConRBI);
            }
        } else if (exportObject == 'SearchedContent') {
            exportRecordsList = new List<Map<String, String>>();
            Set<String> contentIds = (Set<String>)JSON.deserialize(recordIdsJson, Set<String>.class);

            for (Reference_Content__c rc : [SELECT Id, Title__c, Reference_Content_Type_Name__c, Language__c, Internal_Use__c,
                                            Featured_Content__c, Associated_Accounts__c, Substitute_Account_Name__c, External_Summary__c,
                                            Summary__c, Attributes__c, Publish_date__c, Content_URL__c, Content_URL2__c, (SELECT Id from Attachments WHERE Name = 'documentThumbnail.jpg') 
                                            FROM Reference_Content__c
                                            WHERE Content_Status__c = 'Active'
                                            AND Id IN :contentIds
                                            ORDER BY Title__c LIMIT :Limits.getLimitQueryRows()]) {
                Map<String, String> tempRC = new Map<String, String>();
                
                for (HeadingWrapper heading : headingWrapperList) {
                    if (heading.apiName == 'Content_URL__c') {
                        tempRC.put(heading.apiName, rc.Content_URL__c + (rc.Content_URL2__c != null ? rc.Content_URL2__c : ''));
                    } else if (heading.apiName == UtilityController.appNamespace() + 'Is_Thumbnail_Attached') {
                        tempRC.put(heading.apiName, rc.Attachments.size() == 0 ? 'False' : 'True');
                    } else {
                        tempRC.put(heading.apiName, rc.get(heading.apiName) != null ? String.valueOf(rc.get(heading.apiName)) : '');
                    }
                }
                exportRecordsList.add(tempRC);
            }
        }
        return JSON.serialize(exportRecordsList);
    }
    
    public class HeadingWrapper {
    	public String apiName { get; set; }
    	public String label { get; set; }
        public String objectName { get; set; }
		public Boolean isMappingOrField { get; set; }
    	
    	public HeadingWrapper(String apiName, String label, String objectName) {
    		this.apiName = apiName;
    		this.label = label;
            this.objectName = objectName;
    	}

        public HeadingWrapper(String apiName, String label) {
    		this.apiName = apiName;
    		this.label = label;
    	}

    	public HeadingWrapper(String apiName, String label, Boolean isMappingOrField) {
    		this.apiName = apiName;
    		this.label = label;
			this.isMappingOrField = isMappingOrField;
            this.objectName = objectName;
    	}
    }

    public class AttributeWrapper {
        public String name { get; set; }
        public String parentIds { get; set; }

        public AttributeWrapper(Attribute__c att) {
            this.name = att.Name;
            this.parentIds = att.ParentIds__c;
        }
    }
}