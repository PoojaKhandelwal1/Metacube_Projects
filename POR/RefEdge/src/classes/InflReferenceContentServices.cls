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
 * Description:  
 * Author:- Rajesh Sharma
 * Created By: Rajesh @Aug 20 2018
 * Last Modified By: Rajesh @Aug 20 2018  
 */
@RestResource(urlMapping='/v1.0/ReferenceEdge/Content/*')
global with sharing class InflReferenceContentServices {
    public static String INTEGRATION_OFF = 'Content integration is disabled in Reference Edge.';
    public static String CONTENT_DEFAULTS_NOT_SET = 'Default library and Default Reference Content Type is not set in Reference Edge.';
    public static String  MISSING_REQUEST_BODY_PARAM = 'Missing contents parameter in the request body';
    private static Integer SUCCESS_CODE = 200;
    private static Integer FAILURE_CODE = 500;
    private static Integer BAD_REQUEST_CODE = 400;
    private static Integer FORBIDDEN_CODE = 403;
    private static Custom_Settings__c cs = UtilityController.getCustomSettings();

    /**
​ ​ ​ ​ ​*​ ​  @description​ ​:​ Http Get ​method​ ​used to get reference content. 
​ ​ ​ ​ ​*​ ​ ​ @return :​ returning http response 
    *   @Created By: Rajesh @Sept 2018
​ ​ ​ ​ ​**/
    
    @HttpGet
    global static void getReferenceContentDetails() {
        /*RestResponse res = RestContext.response;
        String emailMsg = 'Reference Content REST API facing Error/Exception during getting Content.<br/><br/>Here are the details : <br/>';
        
        try {  
            RestContext.response.addHeader('Content-Type', 'application/json');
            List<ReferenceContentWrapper> lstContnet = new List<ReferenceContentWrapper>();  
            Custom_Settings__c cs = UtilityController.getCustomSettings(); 
            String query = 'SELECT Id, ';  
            Set<String> setCustomFields = new Set<String>(); 
            Map<Id, ContentVersion> mapContentVersion = new Map<Id, ContentVersion>();   
            
            if (cs.Enabled_Content_Integration__c) {
                //Getting Contnet version custum fields on the basis of custom settings
                if (cs.Manage_ContentVersion_Custom_Fields__c != null) {
                    
                    for (String str : cs.Manage_ContentVersion_Custom_Fields__c.split(',')) {
                        setCustomFields.add(str);
                        query += str +', ';
                    }
                    
                    query = query.removeEnd(', ');
                    query += ' FROM ContentVersion';
                    
                    for (ContentVersion cv : Database.query(query)) {
                        mapContentVersion.put(cv.id, cv);
                    }
                }
                RestRequest req = RestContext.request;
                String contentId = RestContext.request.params.get('contentId');

                if (!String.isBlank(contentId)) {
                    contentId = RestContext.request.params.get('contentId');
                     
                    
                    String soqlQuery = 'SELECT Id, Content_URL__c, Content_URL2__c, Title__c, Content_Status__c, Language__c,Reference_Content_Type_Name__c, Internal_Use__c, Allow_Social_Sharing__c,';
                    soqlQuery += 'Featured_Content__c, Substitute_Account_Name__c, Publish_date__c, Review_Date__c, Expiration_Date__c,Author__c,';
                    soqlQuery += ' Publication_name__c ,Article_publication_date__c ,Search_Terms_keywords__c , Summary__c,External_Summary__c, Content_ID__c,';
                    soqlQuery += 'External_Source_Id__c FROM Reference_Content__c WHERE Content_URL__c != null AND External_Source_Id__c != null ';
                    soqlQuery += 'AND Id =: contentId';
                    
                    List<Reference_Content__c> lstRefContent = Database.query(soqlQuery);
                    
                    if (lstRefContent != null) {
                        
                        for (Reference_Content__c obj : lstRefContent) {
                            
                            lstContnet.add(new ReferenceContentWrapper(String.valueof(obj.Id), obj.Content_URL__c + (obj.Content_URL2__c == null ? '' : obj.Content_URL2__c), obj.Title__c,
                                                                       obj.Content_Status__c, obj.Language__c, obj.Reference_Content_Type_Name__c, obj.Internal_Use__c, obj.Allow_Social_Sharing__c,
                                                                       obj.Featured_Content__c,obj.Substitute_Account_Name__c, String.valueof(obj.Publish_date__c), 
                                                                       String.valueof(obj.Review_Date__c), String.valueof(obj.Expiration_Date__c), obj.Author__c ,
                                                                       obj.Publication_name__c , String.valueof(obj.Article_publication_date__c), 
                                                                       obj.Search_Terms_keywords__c, obj.Summary__c, obj.External_Summary__c, obj.Content_ID__c,
                                                                       obj.External_Source_Id__c, 
                                                                       (mapContentVersion.get(obj.Content_ID__c) != null) 
                                                                       ? getCustomField(mapContentVersion.get(obj.Content_ID__c), setCustomFields) : null,
                                                                       true, 'Reference content fetched'));
                            
                        }
                    } 
                    
                    res.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper(lstContnet)));
                    res.statusCode = SUCCESS_CODE;                     
                } else {
                    res.responseBody = Blob.valueOf('Please provide contentId in the uri request');
                    res.statusCode = BAD_REQUEST_CODE;
                }
            } else {
                res.responseBody = Blob.valueOf(INTEGRATION_OFF);  
                res.statusCode = FORBIDDEN_CODE;
            } 
        } catch (Exception ex) {
            res.responseBody = Blob.valueOf(ex.getMessage());
            res.statusCode = FAILURE_CODE;
            emailMsg = emailMsg + '<br/>Error Message : ' + ex.getMessage() + '<br/>Error Line Number : ' + ex.getLineNumber() 
                + '<br/><p> Please do not reply to this mail.</p>'; 
            
            InflAPIAbstractHandler.sendInflExceptionEmail('RefEdge REST API failed for Reference Content.', new List<String>{emailMsg});
        } */
    }
    
    /**
​ ​ ​ ​ ​*​ ​  @description​ ​:​ Http Patch ​method​ ​used to get reference contents. 
​ ​ ​ ​ ​*​ ​ ​ @return :​ returning http response 
    *   @Created By: Rajesh @Sept 2018
​ ​ ​ ​ ​**/

    @HttpPatch 
    global static void getAllReferenceContentDetails() {  
        /*RestResponse res = RestContext.response;
        String emailMsg = 'Reference Content REST API facing Error/Exception during getting Content.<br/><br/>Here are the details : <br/>';
        
        try {  
            RestContext.response.addHeader('Content-Type', 'application/json');
            List<ReferenceContentWrapper> lstContnet = new List<ReferenceContentWrapper>();  
            Custom_Settings__c cs = UtilityController.getCustomSettings(); 
            Boolean requestFieldsUnavailable  = false;
            String query = 'SELECT Id, ';  
            Set<String> setCustomFields = new Set<String>(); 
            Map<Id, ContentVersion> mapContentVersion = new Map<Id, ContentVersion>();   
            
            if (cs.Enabled_Content_Integration__c) {
                //Getting Contnet version custum fields on the basis of custom settings
                if (cs.Manage_ContentVersion_Custom_Fields__c != null) {
                    
                    for (String str : cs.Manage_ContentVersion_Custom_Fields__c.split(',')) {
                        setCustomFields.add(str);
                        query += str +', ';
                    }
                    query = query.removeEnd(', ');
                    query += ' FROM ContentVersion';
                    
                    for (ContentVersion cv : Database.query(query)) {
                        mapContentVersion.put(cv.id, cv);
                    }
                }
                RestRequest req = RestContext.request;
                String records = req.requestBody.toString();
                
                GetContentWrapper resultWp = (GetContentWrapper) 
                    JSON.deserialize(records, GetContentWrapper.class);
                String soqlQuery = 'SELECT Id, Content_URL__c, Content_URL2__c, Title__c, Content_Status__c, Language__c,Reference_Content_Type_Name__c, Internal_Use__c, Allow_Social_Sharing__c,';
                soqlQuery += 'Featured_Content__c, Substitute_Account_Name__c, Publish_date__c, Review_Date__c, Expiration_Date__c,Author__c,';
                soqlQuery += ' Publication_name__c ,Article_publication_date__c ,Search_Terms_keywords__c , Summary__c,External_Summary__c, Content_ID__c,';
                soqlQuery += 'External_Source_Id__c FROM Reference_Content__c WHERE Content_URL__c != null AND External_Source_Id__c != null ';
                
                if (resultWp.startAt != null && resultWP.endAt != null) {
                    Date sDate = Date.valueOf(String.valueOf(resultWp.startAt));
                    Datetime sdt = datetime.newInstance(sDate.year(), sDate.month(),sDate.day());
                    String startTimeFormat = sdt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                    
                    Date eDate = Date.valueOf(String.valueOf(resultWp.endAt));
                    Datetime edt = datetime.newInstance(eDate.year(), eDate.month(),eDate.day());
                    String endTimeFormat = edt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                    
                    soqlQuery += ' AND CreatedDate >= ' + startTimeFormat + ' AND CreatedDate =< ' + endTimeFormat + ' LIMIT 500'; 
                } 
                else if (resultWp.contentIds != null) {
                    List<String> lstContent = new List<String>();
                    lstContent = resultWp.contentIds;
                    soqlQuery += ' AND (Id IN : lstContent OR External_Source_Id__c IN : lstContent ) LIMIT 500';
                } 
                else {
                    requestFieldsUnavailable = true;
                    res.responseBody = Blob.valueOf('Provide either startAt and endAt or list of contentids');
                    res.statusCode = BAD_REQUEST_CODE;
                }
                
                if (!requestFieldsUnavailable) {
                    List<Reference_Content__c> lstRefContent = Database.query(soqlQuery);
                    
                    
                    for (Reference_Content__c obj : lstRefContent) {
                        lstContnet.add(new ReferenceContentWrapper(String.valueof(obj.Id), obj.Content_URL__c + (obj.Content_URL2__c == null ? '' : obj.Content_URL2__c), obj.Title__c,
                                                                   obj.Content_Status__c, obj.Language__c, obj.Reference_Content_Type_Name__c, obj.Internal_Use__c, obj.Allow_Social_Sharing__c,
                                                                   obj.Featured_Content__c,obj.Substitute_Account_Name__c, String.valueof(obj.Publish_date__c), 
                                                                   String.valueof(obj.Review_Date__c), String.valueof(obj.Expiration_Date__c), obj.Author__c ,
                                                                   obj.Publication_name__c , String.valueof(obj.Article_publication_date__c), 
                                                                   obj.Search_Terms_keywords__c, obj.Summary__c, obj.External_Summary__c, obj.Content_ID__c,
                                                                   obj.External_Source_Id__c, 
                                                                   (mapContentVersion.get(obj.Content_ID__c) != null) 
                                                                   ? getCustomField(mapContentVersion.get(obj.Content_ID__c), setCustomFields) : null,
                                                                   true, 'Reference content fetched'));
                        
                    }                   
                    res.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper(lstContnet)));
                    res.statusCode = SUCCESS_CODE; 
                }
            } else {
                res.responseBody = Blob.valueOf(INTEGRATION_OFF);  
                res.statusCode = FORBIDDEN_CODE;
            } 
        } catch (Exception ex) {
            res.responseBody = Blob.valueOf(ex.getMessage());
            res.statusCode = FAILURE_CODE;
            emailMsg = emailMsg + '<br/>Error Message : ' + ex.getMessage() + '<br/>Error Line Number : ' + ex.getLineNumber() 
                + '<br/><p> Please do not reply to this mail.</p>'; 
            
            InflAPIAbstractHandler.sendInflExceptionEmail('RefEdge REST API failed for Reference Content.', new List<String>{emailMsg});
        } */
    }          

   /**
​ ​ ​ ​ ​*​ ​  @description​ ​:​ Http delete ​method​ ​used to delete reference content. 
​ ​ ​ ​ ​*​ ​ ​ @return :​ returning http response 
    *   @Created By: Rajesh @Sept 2018
​ ​ ​ ​ ​**/
    @HttpDelete
    global static void deleteReferenceContnets() { 
        /*Savepoint sp = Database.setSavepoint(); 
        String emailMsg = 'Reference Content REST API facing Error/Exception during Content deletion.<br/><br/>Here are the details : <br/>';
        RestResponse res = RestContext.response;
        
        try {    
            Custom_Settings__c cs = UtilityController.getCustomSettings();
            
            if (cs.Enabled_Content_Integration__c) { 
                
                ConstantsController.isCallFromInfluitiveAPI = true;
                List<Database.DeleteResult> deleteResults;
                List<ReferenceContentWrapper> lstResponse = new List<ReferenceContentWrapper>();
                String contentIds = RestContext.request.params.get('contentId');

                if (!String.isBlank(contentIds)) {
                    contentIds = RestContext.request.params.get('contentId');
                    List<String> lstIds = contentIds.trim().split(','); 
                    List<Reference_Content__c> lstRefContent = [SELECT Id FROM Reference_Content__c WHERE Id IN :lstIds];                 
                    deleteResults = Database.delete(lstRefContent, false); 

                    for (Database.DeleteResult result : deleteResults) { 
                        lstResponse.add(new ReferenceContentWrapper(String.ValueOf(result.getId()), result.isSuccess(), 
                                                                        (!result.isSuccess()) ? getErrorDetails(result) 
                                                                        : 'Reference Content deleted successfully.'));
                    } 
                    res.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper(lstResponse, true)));
                    res.statusCode = SUCCESS_CODE;  
                } else {
                    res.responseBody = Blob.valueOf('Provide comma seprated salesforce content Ids.');
                    res.statusCode = BAD_REQUEST_CODE;
                }
            } else {
                res.responseBody = Blob.valueOf(INTEGRATION_OFF); 
                res.statusCode = FORBIDDEN_CODE;
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            res.responseBody = Blob.valueOf(ex.getMessage());
            res.statusCode = FAILURE_CODE;
            emailMsg = emailMsg + '<br/>Error Message : ' + ex.getMessage() + '<br/>Error Line Number : ' + ex.getLineNumber() 
                                                + '<br/><p> Please do not reply to this mail.</p>'; 
            
            InflAPIAbstractHandler.sendInflExceptionEmail('RefEdge REST API failed for Reference Content.', new List<String>{emailMsg});
        }*/
    }
    
    /**
    ​​ *​ @description​ ​:​ Http Post ​method​ ​used to create reference content.
    ​ *​ @return :​ returning http response
     * @Created By: Rajesh @Sept 2018
     */
    @HttpPost
    global static void createReferenceContent() {
        String emailMsg = 'Reference Content REST API facing Error/Exception during Content Creation.<br/><br/>Here are the details : <br/>';
        Savepoint sp = Database.setSavepoint();
        RestResponse res = RestContext.response;
        List<String> failedRecords = new List<String>();
        List<String> missingAttributes = new List<String>();
        Map<String, Object> resBody = new Map<String, Object>();

        try {
            List<Reference_Content__c> lstRefContent = new List<Reference_Content__c>();
            Boolean isError = false;
            String errorMessage = '';
            Map<String, ContentVersion> upsertCV = new Map<String, ContentVersion>();
            Integer counter = 0;
            List<Database.UpsertResult> updateResults;
            List<Database.UpsertResult> updateCVResults;
            List<Database.UpsertResult> updateAttsResults;
            List<Object> successRecordsResponse = new List<Object>();
            List<Object> failedRecordsResponse = new List<Object>();
            List<Account_Reference_Content__c> relatedAccounts = new List<Account_Reference_Content__c>();

            if (!cs.Enabled_Content_Integration__c) {
                resBody.put('status_code', FORBIDDEN_CODE);
                resBody.put('message', INTEGRATION_OFF);
                res.responseBody = Blob.valueOf(JSON.serialize(resBody));
                res.statusCode = FORBIDDEN_CODE;
                return;
            }

            if (cs.Default_Library__c == null || cs.Default_Library__c == '' ||
                    cs.Default_Reference_Content_Type__c == null || cs.Default_Reference_Content_Type__c == '') {
                resBody.put('status_code', FORBIDDEN_CODE);
                resBody.put('message', CONTENT_DEFAULTS_NOT_SET);
                res.responseBody = Blob.valueOf(JSON.serialize(resBody));
                res.statusCode = FORBIDDEN_CODE;
                return;
            }
            ConstantsController.isCallFromInfluitiveAPI = true;
            RestRequest req = RestContext.request;
            String records = req.requestBody.toString();
            ResponseWrapper resultWp = (ResponseWrapper)JSON.deserialize(records, ResponseWrapper.class);

            if (resultWp.contents == null) {
                resBody.put('status_code', BAD_REQUEST_CODE);
                resBody.put('message', MISSING_REQUEST_BODY_PARAM);
                res.responseBody = Blob.valueOf(JSON.serialize(resBody));
                res.statusCode = BAD_REQUEST_CODE;
                return;
            }
            List<ReferenceContentWrapper> infoWp = resultWp.contents;
            Schema.SObjectType targetTypes = CRUDAndFLSCheckController.sObjectsMap.get('ContentVersion');
            Schema.DescribeSObjectResult sobject_describes = targetTypes.getDescribe();
            Map<String, String> mapCustomField = new Map<String, String>();
            Map<String, String> mapCustomFieldLabel = new Map<String, String>();

            for (String str : sobject_describes.fields.getMap().keyset()) {
                Schema.DescribeFieldResult sField = sobject_describes.fields.getMap().get(str).getDescribe();

                if (sField.isCustom()) {
                    mapCustomField.put(sField.getLabel(), String.Valueof(sField.getType()));
                    mapCustomFieldLabel.put(sField.getLabel(), sField.getName());
                }
            }
            Map<String, ReferenceContentWrapper> refContentWrapperMap = new Map<String, ReferenceContentWrapper>();
            Map<String, ID> mapContentType = new Map<String, ID>();
            Map<ID, String> mapContentTypeIdToName = new Map<ID, String>();
            Set<String> accNames = new Set<String>();
            List<Reference_Content_Type__c> mapContent = [SELECT Id, Name__c FROM Reference_Content_Type__c
                                                            WHERE Active__c = true ORDER BY Name__c
                                                            LIMIT :Limits.getLimitQueryRows()];
            
            for (Reference_Content_Type__c mp : mapContent) {
                mapContentType.put(mp.Name__c, mp.Id);
                mapContentTypeIdToName.put(mp.Id, mp.Name__c);
            }

            for (ReferenceContentWrapper rcw : infoWp) {

                if (!String.isBlank(rcw.external_source_id)) {
                    refContentWrapperMap.put(rcw.external_source_id, rcw);
                }

                if (!String.isBlank(rcw.account_name) && String.isBlank(rcw.opportunity_id)) {
                    accNames.add(rcw.account_name);
                }
            }
            Map<String, Reference_Content__c> existingRefContentMap = new Map<String, Reference_Content__c>();
            Map<String, String> existingContentIds = new Map<String, String>();
            Map<String, Set<String>> refContentOldAttsMap = new Map<String, Set<String>>();
            String accQuery = 'SELECT Id, Name FROM Account WHERE Name IN :accNames ORDER BY Id';
            Map<String, Account> accMap = new Map<String, Account>();
            List<Content_Attribute__c> oldContentAtts = new List<Content_Attribute__c>();

            for (Account acc : Database.query(accQuery)) {

                if (!accMap.containsKey(acc.Name)) {
                    accMap.put(acc.Name, acc);
                }
            }

            for (Reference_Content__c rc : [SELECT Id, External_Source_Id__c, Reference_Content_Type_Name__c, Library_ID__c, Content_Status__c,
                                                Internal_Use__c, Allow_Social_Sharing__c, Featured_Content__c, Substitute_Account_Name__c,
                                                Publish_date__c, Review_Date__c, Expiration_Date__c, Author__c, Publication_name__c,
                                                Article_publication_date__c, Search_Terms_keywords__c, Summary__c, External_Summary__c,
                                                Content_ID__c, Opportunity__c, Title__c, Content_URL__c, Reference_Content_Type__c, Account__c,
                                                Language__c, (SELECT Id, Attribute__c, Attribute__r.Product_ID__c FROM Content_Attributes__r)
                                                FROM Reference_Content__c
                                                WHERE External_Source_Id__c IN :refContentWrapperMap.keySet()
                                                AND External_Source_Id__c != null]) {
                existingRefContentMap.put(rc.External_Source_Id__c, rc);
                existingContentIds.put(rc.External_Source_Id__c, rc.Content_ID__c);

                if (rc.Content_Attributes__r != null && rc.Content_Attributes__r.size() > 0) {
                    oldContentAtts.addAll(rc.Content_Attributes__r);
                }
            }

            Set<String> oppInternalIds = new Set<String>();
            Map<String, ContentVersion> mapContentVersion
                = new Map<String, ContentVersion>([SELECT Id, TagCsv, Description, Language, Content_Status__c, Title,
                                                    ContentDocumentId, Reference_Content_Type__c, PathOnClient, FirstPublishLocationId
                                                    FROM ContentVersion WHERE Id IN :existingContentIds.values()
                                                    AND IsLatest = true]);
            List<String> externalIds = new List<String>();

            for (ReferenceContentWrapper rcw : infoWp) {

                if (rcw.opportunity_id != null && rcw.opportunity_id.trim() != '') {
                    oppInternalIds.add(rcw.opportunity_id);
                }

                if (!existingContentIds.containsKey(rcw.external_source_id)
                        && (rcw.content_url == null || rcw.content_url.trim() == '')) {
                    Map<String, String> tempMap = new Map<String, String>();
                    tempMap.put('external_id', rcw.external_source_id);
                    tempMap.put('salesforce_id', null);
                    tempMap.put('message', 'content_url is required for new content records.');
                    failedRecordsResponse.add(tempMap);
                }

                if (rcw.content_url != null && rcw.content_url != '') {
                    ContentVersion cv;
                    externalIds.add(rcw.external_source_id);

                    // update
                    if (existingContentIds.containsKey(rcw.external_source_id)) {
                        cv = mapContentVersion.get(existingContentIds.get(rcw.external_source_id));
                    } else {    // insert
                        cv = new ContentVersion();
                        cv.FirstPublishLocationId = cs.Default_Library__c;
                    }
                    cv.Title = rcw.title != null ? rcw.title : cv.Title;
                    cv.ContentUrl = rcw.content_url;
                    cv.TagCsv = rcw.search_terms_keywords != null ? rcw.search_terms_keywords.replaceAll(';', ',') : cv.TagCsv;
                    cv.Description = rcw.summary != null ? rcw.summary.substring(0, Math.min(rcw.summary.length(), 1000)) : cv.Description;
                    cv.Content_Status__c = rcw.content_status != null ? rcw.content_status : cv.Content_Status__c;

                    if (mapContentType != null && rcw.reference_content_type != null && mapContentType.containsKey(rcw.reference_content_type)) {
                        cv.Reference_Content_Type__c = mapContentType.get(rcw.reference_content_type);
                    } else {
                        cv.Reference_Content_Type__c = cs.Default_Reference_Content_Type__c;
                    }

                    if (rcw.language != null) {

                        for (String langKey : UtilityController.mapContentLanguage.keySet()) {

                            if (UtilityController.mapContentLanguage.get(langKey) == rcw.language) {
                                cv.Language = langKey;
                                break;
                            }
                        }
                    }

                    if (rcw.content_version_custom_fields != null) {

                        for (ContentVerionFieldWrapper field : rcw.content_version_custom_fields) {

                            if (mapCustomField.containsKey(field.field_name)) {

                                if (mapCustomField.get(field.field_name) == 'BOOLEAN') {
                                    Boolean flag = false;

                                    if (!String.isBlank(field.field_value)) {
                                        flag = Boolean.valueof(field.field_value);
                                    }
                                    cv.put(mapCustomFieldLabel.get(field.field_name), flag);
                                } else if (mapCustomField.get(field.field_name) == 'DATE' || mapCustomField.get(field.field_name) == 'DATETIME') {

                                    if (!String.isBlank(field.field_value)) {
                                        cv.put(mapCustomFieldLabel.get(field.field_name), Date.valueof(field.field_value));
                                    }
                                } else {
                                    cv.put(mapCustomFieldLabel.get(field.field_name), String.valueof(field.field_value));
                                }
                            }
                        }
                    }
                    upsertCV.put(rcw.external_source_id, cv);
                }
            }
            Set<String> newRecordIds = new Set<String>();

            if (upsertCV.size() > 0) {
                updateCVResults = Database.upsert(upsertCV.values(), false);

                for (Integer i = 0; i < updateCVResults.size(); i++) {
                    Database.UpsertResult ur = updateCVResults[i];

                    if (ur.isSuccess()) {
                        newRecordIds.add(ur.getId());
                    } else if (!ur.isSuccess()) {
                        Map<String, String> tempMap = new Map<String, String>();
                        tempMap.put('external_id', externalIds.get(i));
                        tempMap.put('salesforce_id', upsertCV.values().get(i).Id);
                        tempMap.put('message', String.valueOf(ur.getErrors()[0].getMessage()));
                        failedRecordsResponse.add(tempMap);
                    }
                }
            }
            Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();

            if (CRUDAndFLSCheckController.sObjectsMap.get('Opportunity').getDescribe().fields.getMap().containsKey('InternalID__c')) {
                String oppQuery = 'SELECT Id, InternalID__c, AccountId FROM Opportunity WHERE InternalID__c IN :oppInternalIds';

                for (Opportunity opp : Database.query(oppQuery)) {
                    opportunityMap.put(String.valueOf(opp.get('InternalID__c')), opp);
                }
            }

            for (ReferenceContentWrapper rcw : infoWp) {

                if (!existingContentIds.containsKey(rcw.external_source_id)
                        && (rcw.content_url == null || rcw.content_url.trim() == '')) {
                    continue;
                }

                if ((upsertCV.containsKey(rcw.external_source_id)
                        && upsertCV.get(rcw.external_source_id).Id != null
                        && newRecordIds.contains(upsertCV.get(rcw.external_source_id).Id))
                        || !upsertCV.containsKey(rcw.external_source_id)) {
                    Reference_Content__c tempRC;

                    // update
                    if (existingRefContentMap.containsKey(rcw.external_source_id)) {
                        tempRC = existingRefContentMap.get(rcw.external_source_id);
                    } else {    // insert
                        tempRC = new Reference_Content__c();
                        tempRC.External_Source_Id__c = rcw.external_source_id;
                        tempRC.Library_ID__c = cs.Default_Library__c;
                    }

                    if (mapContentType != null && rcw.reference_content_type != null && mapContentType.containsKey(rcw.reference_content_type)) {
                        tempRC.Reference_Content_Type__c = mapContentType.get(rcw.reference_content_type);
                        tempRC.Reference_Content_Type_Name__c = rcw.reference_content_type;
                    } else {
                        tempRC.Reference_Content_Type__c = cs.Default_Reference_Content_Type__c; 
                        tempRC.Reference_Content_Type_Name__c = mapContentTypeIdToName.get(cs.Default_Reference_Content_Type__c); 
                    }

                    if (rcw.content_url != null) {
                        tempRC.Content_ID__c = upsertCV.get(rcw.external_source_id).Id;
                        tempRC.Content_URL__c = rcw.content_url.length() > 255 ? rcw.content_url.substring(0, 254) : rcw.content_url;
                        tempRC.Content_URL2__c = rcw.content_url.length() > 255 ? rcw.content_url.substring(254) : '';
                    }
                    tempRC.Title__c = rcw.title != null ? rcw.title : tempRC.Title__c;
                    tempRC.Content_Status__c = rcw.content_status != null ? rcw.content_status : tempRC.Content_Status__c;
                    tempRC.Language__c = rcw.language != null ? rcw.language : tempRC.Language__c;
                    tempRC.Internal_Use__c = rcw.internal_use != null ? Boolean.valueof(rcw.internal_use) : tempRC.Internal_Use__c;
                    tempRC.Allow_Social_Sharing__c = rcw.allow_social_sharing != null ? Boolean.valueof(rcw.allow_social_sharing) : tempRC.Allow_Social_Sharing__c;
                    tempRC.Featured_Content__c = rcw.featured_content != null ? Boolean.valueof(rcw.featured_content) : tempRC.Featured_Content__c;
                    tempRC.Substitute_Account_Name__c = rcw.substitute_account_name != null ? rcw.substitute_account_name : tempRC.Substitute_Account_Name__c; 
                    tempRC.Publish_date__c = rcw.publish_date != null ? Date.valueof(rcw.publish_date) : tempRC.Publish_date__c; 
                    tempRC.Review_Date__c = rcw.review_date != null ? Date.valueof(rcw.review_date) : tempRC.Review_Date__c;
                    tempRC.Expiration_Date__c = rcw.expiration_date != null ? Date.valueof(rcw.expiration_date) : tempRC.Expiration_Date__c;
                    tempRC.Author__c = rcw.author != null ? rcw.author : tempRC.Author__c;
                    tempRC.Publication_name__c = rcw.publication_name != null ? rcw.publication_name : tempRC.Publication_name__c;
                    tempRC.Article_publication_date__c = rcw.article_publication_date != null ? Date.valueof(rcw.article_publication_date) : tempRC.Article_publication_date__c;
                    tempRC.Search_Terms_keywords__c = rcw.search_terms_keywords != null ? rcw.search_terms_keywords.replaceAll(';', ',') : tempRC.Search_Terms_keywords__c;
                    tempRC.Summary__c = rcw.summary != null ? rcw.summary : tempRC.Summary__c;
                    tempRC.External_Summary__c = rcw.external_summary != null ? rcw.external_summary : tempRC.External_Summary__c;
                    tempRC.Opportunity__c = rcw.opportunity_id != null && opportunityMap.containsKey(rcw.opportunity_id) ? opportunityMap.get(rcw.opportunity_id).Id : tempRC.Opportunity__c;
                    tempRC.Account__c = rcw.opportunity_id != null && opportunityMap.containsKey(rcw.opportunity_id)
                            ? opportunityMap.get(rcw.opportunity_id).AccountId
                            : ((rcw.opportunity_id == null || rcw.opportunity_id.trim() == '') && rcw.account_name != null && accMap.containsKey(rcw.account_name)
                                ? accMap.get(rcw.account_name).Id : tempRC.Account__c);
                    lstRefContent.add(tempRC);
                }
            }
            Set<String> failedRecordIds = new Set<String>();
            Map<String, Set<Id>> refContentAccountsMap = new Map<String, Set<Id>>();
            Map<String, String> upsertedRefContentIds = new Map<String, String>();

            if (lstRefContent.size() > 0) {
                updateResults = Database.upsert(lstRefContent, false);

                for (Integer i = 0; i < updateResults.size(); i++) {
                    Database.UpsertResult ur = updateResults[i];

                    if (ur.isSuccess()) {
                        Map<String, String> tempMap = new Map<String, String>();
                        tempMap.put('external_id', lstRefContent[i].External_Source_Id__c);
                        tempMap.put('salesforce_id', lstRefContent[i].Id);
                        successRecordsResponse.add(tempMap);

                        if (!refContentAccountsMap.containsKey(lstRefContent[i].Id)) {
                            refContentAccountsMap.put(lstRefContent[i].Id, new Set<Id>());
                        }
                        upsertedRefContentIds.put(lstRefContent[i].Id, lstRefContent[i].External_Source_Id__c);
                    }

                    if (!ur.isSuccess()) {
                        failedRecordIds.add(ur.getId());
                        Map<String, String> tempMap = new Map<String, String>();
                        tempMap.put('external_id', lstRefContent.get(i).External_Source_Id__c);
                        tempMap.put('salesforce_id', lstRefContent.get(i).Id);
                        tempMap.put('message', String.valueOf(ur.getErrors()[0].getMessage()));
                        failedRecordsResponse.add(tempMap);
                    }
                }

                for (Account_Reference_Content__c arc : WithoutSharingHelperController.getARCForAccounts2(refContentAccountsMap.keySet())) {
                    refContentAccountsMap.get(arc.Reference_Content__c).add(arc.Account__c);
                }
            }
            List<Id> cvIdsToDelete = new List<Id>();
            Set<String> allRootAttNames = new Set<String>();
            Map<String, Map<String, String>> refContentNewAttsMap = new Map<String, Map<String, String>>();
            Map<String, Map<String, Attribute__c>> rootAttsMap = new Map<String, Map<String, Attribute__c>>();
            List<Content_Attribute__c> newContentAttributes = new List<Content_Attribute__c>();
            Map<String, String> refContentOppIdsMap = new Map<String, String>();

            for (Reference_Content__c rc : lstRefContent) {

                if (refContentAccountsMap.containsKey(rc.Id)
                        && rc.Account__c != null
                        && !refContentAccountsMap.get(rc.Id).contains(rc.Account__c)) {
                    relatedAccounts.add(new Account_Reference_Content__c(Account__c = rc.Account__c, Reference_Content__c = rc.Id));
                }

                if (rc.Id == null || (rc.Id != null && failedRecordIds.contains(rc.Id))) {
                    cvIdsToDelete.add(rc.Content_ID__c);
                } else if (refContentWrapperMap.containsKey(rc.External_Source_Id__c)
                        && refContentWrapperMap.get(rc.External_Source_Id__c).attributes_map != null
                        && refContentWrapperMap.get(rc.External_Source_Id__c).attributes_map.size() > 0
                        && (refContentWrapperMap.get(rc.External_Source_Id__c).opportunity_id == null
                        || refContentWrapperMap.get(rc.External_Source_Id__c).opportunity_id.trim() == '')) {
                    allRootAttNames.addAll(refContentWrapperMap.get(rc.External_Source_Id__c).attributes_map.keySet());
                    refContentNewAttsMap.put(rc.Id, refContentWrapperMap.get(rc.External_Source_Id__c).attributes_map);
                } else if (refContentWrapperMap.get(rc.External_Source_Id__c).opportunity_id != null
                        && refContentWrapperMap.get(rc.External_Source_Id__c).opportunity_id.trim() != '') {
                    refContentOppIdsMap.put(rc.Id, rc.Opportunity__c);

                    if (refContentWrapperMap.get(rc.External_Source_Id__c).attributes_map.containsKey('AM IM Flag')
                            && refContentWrapperMap.get(rc.External_Source_Id__c).attributes_map.get('AM IM Flag') != null) {

                        if (!refContentNewAttsMap.containsKey(rc.Id)) {
                            refContentNewAttsMap.put(rc.Id, new Map<String, String>());
                        }
                        refContentNewAttsMap.get(rc.Id).put('AM IM Flag', refContentWrapperMap.get(rc.External_Source_Id__c).attributes_map.get('AM IM Flag'));
                    }

                    if (refContentWrapperMap.get(rc.External_Source_Id__c).attributes_map.containsKey('Country Delivered To')
                            && refContentWrapperMap.get(rc.External_Source_Id__c).attributes_map.get('Country Delivered To') != null) {

                        if (!refContentNewAttsMap.containsKey(rc.Id)) {
                            refContentNewAttsMap.put(rc.Id, new Map<String, String>());
                        }
                        refContentNewAttsMap.get(rc.Id).put('Country Delivered To', refContentWrapperMap.get(rc.External_Source_Id__c).attributes_map.get('Country Delivered To'));
                    }

                    if (refContentWrapperMap.get(rc.External_Source_Id__c).attributes_map.containsKey('Country That Delivered')
                            && refContentWrapperMap.get(rc.External_Source_Id__c).attributes_map.get('Country That Delivered') != null) {

                        if (!refContentNewAttsMap.containsKey(rc.Id)) {
                            refContentNewAttsMap.put(rc.Id, new Map<String, String>());
                        }
                        refContentNewAttsMap.get(rc.Id).put('Country That Delivered', refContentWrapperMap.get(rc.External_Source_Id__c).attributes_map.get('Country That Delivered'));
                    }
                }
            }

            if (relatedAccounts != null && relatedAccounts.size() > 0) {
                WithoutSharingHelperController.insertAccountReferenceContent(relatedAccounts);
            }

            if (refContentOppIdsMap != null && refContentOppIdsMap.size() > 0) {
                Map<String, Map<String, String>> tempAttsMap = new Map<String, Map<String, String>>();
                tempAttsMap.putAll(getOppAttDetails(refContentOppIdsMap));

                for (String rcId : tempAttsMap.keySet()) {

                    if (refContentNewAttsMap.containsKey(rcId)) {
                        refContentNewAttsMap.get(rcId).putAll(tempAttsMap.get(rcId));
                    } else {
                        refContentNewAttsMap.put(rcId, tempAttsMap.get(rcId));
                    }
                }

                for (String rcId : refContentNewAttsMap.keySet()) {
                    allRootAttNames.addAll(refContentNewAttsMap.get(rcId).keySet());
                }
            }
            List<Attribute__c> rootAtts = [SELECT Id, Name, (SELECT Id, Name, Product_ID__c FROM Attributes__r)
                                            FROM Attribute__c WHERE Name IN :allRootAttNames AND Level__c = 0];

            if (rootAtts != null && rootAtts.size() > 0) {

                for (Attribute__c root : rootAtts) {
                    
                    if (root.Attributes__r != null && root.Attributes__r.size() > 0) {
                        rootAttsMap.put(root.Name, new Map<String, Attribute__c>());

                        for (Attribute__c att : root.Attributes__r) {
                            rootAttsMap.get(root.Name).put(att.Name, att);
                        }
                    }
                }
            }
            Map<String, Set<String>> missingAttNames = new Map<String, Set<String>>();

            for (String rcId : refContentNewAttsMap.keySet()) {

                for (String rootName : refContentNewAttsMap.get(rcId).keySet()) {

                    if (refContentNewAttsMap.get(rcId).get(rootName) != null && rootAttsMap.containsKey(rootName.trim())) {

                        for (String newAttName : refContentNewAttsMap.get(rcId).get(rootName).split(';')) {

                            if (rootAttsMap.get(rootName.trim()).containsKey(newAttName.trim())) {
                                newContentAttributes.add(new Content_Attribute__c(Reference_Content__c = rcId, Attribute__c = rootAttsMap.get(rootName.trim()).get(newAttName.trim()).Id));
                            } else if (newAttName.trim() != '') {
                                
                                if (!missingAttNames.containsKey(newAttName.trim())) {
                                    missingAttNames.put(newAttName.trim(), new Set<String>());
                                }

                                if (upsertedRefContentIds.containsKey(rcId)) {
                                    missingAttNames.get(newAttName.trim()).add(upsertedRefContentIds.get(rcId));
                                }
                            }
                        }
                    }
                }
            }

            if (oldContentAtts.size() > 0) {
                delete oldContentAtts;
            }

            if (newContentAttributes.size() > 0) {
                updateAttsResults = Database.upsert(newContentAttributes, false);
            }

            if (cvIdsToDelete.size() > 0) {
                deleteContentDocument(cvIdsToDelete);
            }

            if (missingAttNames.size() > 0) {
                sendFailureReport(JSON.serialize(missingAttNames));
            }
            resBody.put('success_records', successRecordsResponse);
            resBody.put('failed_records', failedRecordsResponse);
            res.responseBody = Blob.valueOf(JSON.serialize(resBody));
            res.statusCode = 200;
        } catch(Exception ex) {
            Database.rollback(sp);
            resBody = new Map<String, Object>();
            resBody.put('status_code', 500);
            resBody.put('message', ex.getMessage());
            resBody.put('line_number', ex.getLineNumber());
            res.responseBody = Blob.valueOf(JSON.serialize(resBody));
            res.statusCode = 500;
            emailMsg = emailMsg + '<br/>Exception : ' + ex + '<br/>Error Message : ' + ex.getMessage()
                        + '<br/>Error Line Number : ' + ex.getLineNumber() + '<br/><p> Please do not reply to this mail.</p>';
            InflAPIAbstractHandler.sendInflExceptionEmail('RefEdge REST API failed for Reference Content.', new List<String>{ emailMsg });
        }
    }

    @future
    public static void sendFailureReport(String failedRecordsMapJson) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { 'referenceedge@point-of-reference.com' };
        Map<String, Set<String>> failedRecordsMap
            = (Map<String, Set<String>>)JSON.deserialize(failedRecordsMapJson, Map<String, Set<String>>.class);

        if (cs.Content_import_API_reporting_email__c != null && cs.Content_import_API_reporting_email__c != '') {
            toAddresses.add(cs.Content_import_API_reporting_email__c);
        }
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('RefEdge Support');
        mail.setSubject('Reference Content import API');
        String mailBody = 'The following values couldn\'t be associated to Reference Content because they don\'t have a matching Attribute:\n\n';

        for (String attName : failedRecordsMap.keySet()) {
            mailBody += 'Attribute Name: ' + attName + ', Record Ids: ';
            String recordIds = '';

            for (String contentId : failedRecordsMap.get(attName)) {
                recordIds = recordIds == '' ? contentId : recordIds + ', ' + contentId;
            }
            mailBody += recordIds + '\n';
        }
        mailBody = mailBody + '\n Organization Name: ' + Userinfo.getOrganizationName() + '\n Organization Id: ' 
                                    + Userinfo.getOrganizationId() + '\n\n Please do not reply to this mail.';
        mail.setPlainTextBody(mailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    /**
     * method to get related taxonomy values for the opportunity
     * (only for Capgemeni)
     * author: Gaurav Saini (13 Mar, 2019)
     */
    public static Map<String, Map<String, String>> getOppAttDetails(Map<String, String> refContentOppMap) {
        Map<String, Map<String, String>> oppTaxonomyValuesMap = new Map<String, Map<String, String>>();
        Boolean isTechnologyPresent = CRUDAndFLSCheckController.sObjectsMap.containsKey('SAM_Technology__c');
        Boolean isTechnologyFieldPresent = false;
        Boolean isPartnerFieldPresent = false;
        Map<String, Schema.RecordTypeInfo> recTypeInfos = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Boolean isPartnerRecordTypePresent = recTypeInfos.containsKey('Partner');
        Map<String, Schema.SObjectField> oppProductFieldMap = CRUDAndFLSCheckController.sObjectsMap.get('OpportunityLineItem').getDescribe().fields.getMap();
        String partnerRelName = '';
        String technologyRelName = '';

        if (isTechnologyPresent || Test.isRunningTest()) {

            for (Schema.SObjectField field : oppProductFieldMap.values()) {
                Schema.DescribeFieldResult dfr = field.getDescribe();

                if (dfr.getType() == Schema.DisplayType.REFERENCE) {
                    String relatedObjName = dfr.getReferenceTo()[0].getDescribe().getName();

                    if (relatedObjName == 'SAM_Technology__c') {
                        isTechnologyFieldPresent = true;
                        technologyRelName = dfr.getRelationShipName();
                        break;
                    }
                }
            }
            Map<String, Schema.SObjectField> techFieldMap = CRUDAndFLSCheckController.sObjectsMap.get('SAM_Technology__c').getDescribe().fields.getMap();

            for (Schema.SObjectField field : techFieldMap.values()) {
                Schema.DescribeFieldResult dfr = field.getDescribe();

                if (dfr.getType() == Schema.DisplayType.REFERENCE) {
                    String relatedObjName = dfr.getReferenceTo()[0].getDescribe().getName();

                    if (relatedObjName == 'Account' && dfr.getName() == 'Partner__c') {
                        isPartnerFieldPresent = true;
                        partnerRelName = dfr.getRelationShipName();
                        break;
                    }
                }
            }
        }

        if ((isTechnologyFieldPresent && isPartnerFieldPresent) || Test.isRunningTest()) {
            Map<String, String> attMappingObjectMap = new Map<String, String>();
            List<String> objList = new List<String> { 'Account', 'Product2', 'SAM_Technology__c' };
            List<String> oppIds = new List<String>();
            oppIds.addAll(refContentOppMap.values());
            String oppQuery = 'SELECT Id, InternalID__c, Account.Name, AccountId, '
                            + '(SELECT Technology__c, Technology__r.Name, Entry_PortfolioFormula__c, '
                                + 'Technology__r.Partner__r.Name, Technology__r.Partner__c, '
                                + 'PricebookEntry.Product2.Name, PricebookEntry.Product2Id FROM OpportunityLineItems)'
                            + ' FROM Opportunity WHERE Id IN :oppIds';
            List<Attribute_Mapping__c> attMappings = [SELECT Id, Attribute_Name__c, Object__c FROM Attribute_Mapping__c
                                                        WHERE Object__c IN :objList
                                                        AND Field_API_Name__c = null];

            for (String rcId : refContentOppMap.keySet()) {
                oppTaxonomyValuesMap.put(rcId, new Map<String, String>());
            }

            for (Attribute_Mapping__c am : attMappings) {
                attMappingObjectMap.put(am.Object__c, am.Attribute_Name__c);
            }

            if (!Test.isRunningTest()) {

                for (Opportunity opp : Database.query(oppQuery)) {

                    if (opp.OpportunityLineItems != null && opp.OpportunityLineItems.size() > 0) {
                        String prodNames = '';
                        String techNames = '';
                        String partnerNames = '';
                        String portfolioNames = '';

                        for (OpportunityLineItem oppProduct : opp.OpportunityLineItems) {
                            prodNames = prodNames == ''
                                ? oppProduct.PricebookEntry.Product2.Name
                                : prodNames.contains(oppProduct.PricebookEntry.Product2.Name)
                                    ? prodNames : prodNames + ';' + oppProduct.PricebookEntry.Product2.Name;

                            if (oppProduct.get('Technology__c') != null) {
                                techNames = techNames == ''
                                    ? String.valueOf(oppProduct.getSObject(technologyRelName).get('Name'))
                                    : techNames.contains(String.valueOf(oppProduct.getSObject(technologyRelName).get('Name')))
                                        ? techNames : techNames + ';' + String.valueOf(oppProduct.getSObject(technologyRelName).get('Name'));

                                if (oppProduct.getSObject(technologyRelName).get('Partner__c') != null) {
                                    partnerNames = partnerNames == ''
                                        ? String.valueOf(oppProduct.getSObject(technologyRelName).getSObject(partnerRelName).get('Name'))
                                        : partnerNames.contains(String.valueOf(oppProduct.getSObject(technologyRelName).getSObject(partnerRelName).get('Name')))
                                            ? partnerNames : partnerNames + ';' + String.valueOf(oppProduct.getSObject(technologyRelName).getSObject(partnerRelName).get('Name'));
                                }
                            }

                            if (oppProduct.get('Entry_PortfolioFormula__c') != null) {
                                portfolioNames = portfolioNames == ''
                                    ? String.valueOf(oppProduct.get('Entry_PortfolioFormula__c'))
                                    : portfolioNames.contains(String.valueOf(oppProduct.get('Entry_PortfolioFormula__c')))
                                        ? portfolioNames : portfolioNames + ';' + String.valueOf(oppProduct.get('Entry_PortfolioFormula__c'));
                            }
                        }

                        for (String rcId : refContentOppMap.keySet()) {

                            if (refContentOppMap.get(rcId) == String.valueOf(opp.Id)) {

                                if (attMappingObjectMap.containsKey('Product2') && prodNames != '') {
                                    oppTaxonomyValuesMap.get(rcId).put(attMappingObjectMap.get('Product2'), prodNames);
                                }

                                if (attMappingObjectMap.containsKey('Account') && partnerNames != '') {
                                    oppTaxonomyValuesMap.get(rcId).put(attMappingObjectMap.get('Account'), partnerNames);
                                }

                                if (attMappingObjectMap.containsKey('SAM_Technology__c') && techNames != '') {
                                    oppTaxonomyValuesMap.get(rcId).put(attMappingObjectMap.get('SAM_Technology__c'), techNames);
                                }

                                if (portfolioNames != '') {
                                    oppTaxonomyValuesMap.get(rcId).put('Entry Portfolio', portfolioNames);
                                }
                            }
                        }
                    }
                }
            }
        }
        return oppTaxonomyValuesMap;
    }
    
    private class PostResponseWrapper {
        private String result;
        private Boolean isSuccess;
        
        private PostResponseWrapper(Boolean isSuccess, String result) {
            this.result = result;
            this.isSuccess = isSuccess;
        }
    }

    /*
     * Response Warrper for Content Request
     */
    private class ReferenceContentWrapper {
        private String content_url;
        private String account_name;
        private String title;
        private String content_status;
        private String language;
        private String reference_content_type;
        private Boolean internal_use;
        private Boolean allow_social_sharing;
        private Boolean featured_content;
        private String substitute_account_name;
        private String publish_date;
        private String review_date;
        private String expiration_date;
        private String author;
        private String publication_name;
        private String article_publication_date;
        private String search_terms_keywords;
        private String summary;
        private String external_summary;
        private String external_source_id;
        private List<ContentVerionFieldWrapper> content_version_custom_fields;
        private String result;
        private Boolean isSuccess;
        public Map<String, String> attributes_map { get; private set; }
        public String opportunity_id { get; private set; }

        private ReferenceContentWrapper(String content_url, String title, String content_status, String language, String reference_content_type,
                                        Boolean internal_use, Boolean allow_social_sharing, Boolean featured_content, String substitute_account_name,
                                        String publish_date, String review_date, String expiration_date, String author, String publication_name,
                                        String article_publication_date, String search_terms_keywords, String summary, String external_summary, String external_id, 
                                        List<ContentVerionFieldWrapper> customFields, Boolean isSuccess, String result, Map<String, String> attsMap, String oppId) {
            this.content_url = content_url;
            this.title = title;
            this.content_status = content_status;
            this.language = language;
            this.reference_content_type = reference_content_type;
            this.internal_use = internal_use;
            this.allow_social_sharing = allow_social_sharing;
            this.featured_content = featured_content;
            this.substitute_account_name = substitute_account_name;
            this.publish_date = publish_date;
            this.review_date = review_date;
            this.expiration_date = expiration_date;
            this.author = author;
            this.publication_name = publication_name;
            this.article_publication_date = article_publication_date;
            this.search_terms_keywords = search_terms_keywords;
            this.summary = summary;
            this.external_summary = external_summary;
            this.external_source_id = external_id;
            this.content_version_custom_fields = customFields;
            this.result = result;
            this.isSuccess = isSuccess;
            this.attributes_map = attsMap;
            this.opportunity_id = oppId;
        }
        
        /*Response Warrper for Delete Content Request
        private ReferenceContentWrapper(String crm_content_Id, Boolean isSuccess, String result) {
            this.crm_content_Id = crm_content_Id; 
            this.result = result;
            this.isSuccess = isSuccess;
        }*/
    }     

    /**
     * Wrapper constructor for Content version custom field
     ​*/
    private class ContentVerionFieldWrapper {
        private String field_name;
        private String field_value;

        private ContentVerionFieldWrapper(String field_key, String field_value) {
            this.field_name = field_key;
            this.field_value = field_value;
        }
    } 

   /** 
    * Wrapper constructor for Content wrapper 
​ ​ ​ ​ ​**/
    /*private class GetContentWrapper {
        private String startAt;
        private String endAt; 
        private List<String> contentIds;

        private GetContentWrapper(String startAt, String endAt, List<String> contentIds) {
            this.startAt = startAt;
            this.endAt = endAt;
            this.contentIds = contentIds;
        }
    }*/
    
   /** 
    * Wrapper constructor for Response
​ ​ ​ ​ ​**/
    private class ResponseWrapper {
        private List<ReferenceContentWrapper> contents; 
        //private List<ReferenceContentWrapper> deletedContent;
        private List<PostResponseWrapper> contentsResult; 

        private ResponseWrapper(List<ReferenceContentWrapper> content) {
            this.contents = content;
        } 

       /* private ResponseWrapper(List<ReferenceContentWrapper> deletedIds, Boolean isDelete) {
            this.deletedContent = deletedIds;
        }*/
       
        private ResponseWrapper(List<PostResponseWrapper> contentsResult) {
            this.contentsResult = contentsResult;
        }
    }
 
    /**
​ ​ ​ ​ ​*​ ​  @description​ ​:​ ​This​ ​method​ ​used to insert records (uploaded using csv) in specific objects.
​ ​ ​ ​ ​*​ ​  @args​  :​ Database.UpsertResult take Database upsert result.
​ ​ ​ ​ ​*​ ​ ​ @return :​ returning String type contining error message 
    *   @Created By: Rajesh @Sept 2018
​ ​ ​ ​ ​**/
    public static String getErrorDetails(Database.DeleteResult error) {
        String errorMsg = '';
         
        for (Database.Error err : error.getErrors()) { 
            errorMsg += 'Error Details : ' + err.getMessage() + ' , Error fields '+ err.getFields(); 
        }
        return errorMsg;
    }

     public static String getErrorDetails(Database.UpsertResult error) {
        String errorMsg = '';
         
        for (Database.Error err : error.getErrors()) { 
            errorMsg += 'Error Details : ' + err.getMessage() + ' , Error fields '+ err.getFields(); 
        }
        return errorMsg;
    }

     /**
​ ​ ​ ​ ​*​ ​  @description​ ​:​ ​This​ ​method​ ​used to get content version custom field lists.
​ ​ ​ ​ ​*​ ​  @args​  :​ ContentVersion obj and set of strings
​ ​ ​ ​ ​*​ ​ ​ @return :​ returning List of type ContentVerionFieldWrapper
    *   @Created By: Rajesh @Sept 2018
​ ​ ​ ​ ​**/
    public static List<ContentVerionFieldWrapper> getCustomField(ContentVersion cv, Set<String> setCustomFields) {
        List<ContentVerionFieldWrapper> lstCf = new List<ContentVerionFieldWrapper>(); 
        
        String type='ContentVersion';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        for (String str : setCustomFields) {
            lstCf.add(new ContentVerionFieldWrapper(fieldMap.get(str).getDescribe().getLabel(), String.valueof(cv.get(str))));
        }      
        return lstCf; 
    }
    
    /**
​ ​ ​ ​ ​*​ ​  @description​ ​:​ ​This​ ​method​ ​used to delete content versions
​ ​ ​ ​ ​*​ ​  @args​  :​ List of ContentVersion Ids
​ ​ ​ ​ ​**/
    @future
    public static void deleteContentDocument(List<Id> listOfContentIds) {
        List <ContentDocument> contentDocuments = new List <ContentDocument>();
        List <ContentDocument> contentDocuments2 = new List <ContentDocument>();
        
        for (ContentDocument conDoc: [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN: listOfContentIds]) {
            contentDocuments.add(conDoc);
        }
        
        if (contentDocuments.size() > 0) {
           DELETE contentDocuments;
        }
    }
}