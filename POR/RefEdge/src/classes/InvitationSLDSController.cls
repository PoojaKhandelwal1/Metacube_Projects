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
 * VF Page: Invitation
 * Description: Class used to send invitaion emails along with contents.
 * Last modified date:3 june 2016
 * Modified by: Rajesh for ticket #673  
 */
global with sharing class InvitationSLDSController {
    public String selectedRefContents { get; set; }
    public String opportunity { get; set; }
    public String caseId { get; set; }
    public Boolean forContent { get; set; }
    public Boolean forAccount { get; set; }
    public String leadId { get; set; }
    public static String helpOverlayInvitation { get; set; }
    public Boolean isContentUpdateable {
        get {
            return Reference_Content__c.SObjectType.getDescribe().isUpdateable();
        }
        set;
    }
    // flag used to identify that page  returned from slect content page or not
    public Boolean isReturned { get; set; }
    public String contactEmailIds { get; set; }
    public String userEmailIds { get; set; }
    public String recipientsEmailIds { get; set; }
    public String emailSubject { get; set; }
    public String emailContent { get; set; }
    public String invitaionName { get; set; }
    public String notes { get; set; }
    public String selectedMictosite { get; set; }
    public String expDate { get; set; }
    public Boolean isCcAllowed { get; set; }
    public String emailTo { get; set; }
    public String emailBcc { get; set; }
    public String emailCc { get; set; }
    public String opportunityAccount { get; set; }
    public String opportunityName { get; set; }
    public Boolean fromLead { get; set; }
    public boolean showOveray { get; set; }
    public String helpAssistant { get; set; } 
    private List<User_Mapping__c> userMappingList;
    private Custom_Settings__c cs;
    private String labelValue = '';
    private Date lastActivity;

    /**
     * Constructor
     */
    public InvitationSLDSController() {
        emailContent = '';
        
        if (ApexPages.currentPage().getParameters().get('refContentIds') != null) {
            selectedRefContents = ApexPages.currentPage().getParameters().get('refContentIds');
        }
        
        if (ApexPages.currentPage().getParameters().get('opportunityId') != null) {
            opportunity = ApexPages.currentPage().getParameters().get('opportunityId');
        }
        
        if (ApexPages.currentPage().getParameters().get('caseId') != null) {
            caseId = ApexPages.currentPage().getParameters().get('caseId');
        }
        
        if (ApexPages.currentPage().getParameters().get('forContent') != null) {
            forContent = Boolean.valueOf(ApexPages.currentPage().getParameters().get('forContent'));
        }
        
        if (ApexPages.currentPage().getParameters().get('forAccount') != null) {
            forAccount = Boolean.valueOf(ApexPages.currentPage().getParameters().get('forAccount'));
        }
        
        if (ApexPages.currentPage().getParameters().get('leadId') != null) {
            leadId = ApexPages.currentPage().getParameters().get('leadId');
        }
        
        if (ApexPages.currentPage().getParameters().get('isReturned') != null) {
            isReturned = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isReturned'));
        }
        
        if (ApexPages.currentPage().getParameters().get('contactIds') != null) {
            contactEmailIds = ApexPages.currentPage().getParameters().get('contactIds');
        }
        
        if (ApexPages.currentPage().getParameters().get('userIds') != null) {
            userEmailIds = ApexPages.currentPage().getParameters().get('userIds');
        }
        
        if (ApexPages.currentPage().getParameters().get('recipientsIds') != null) {
            recipientsEmailIds = ApexPages.currentPage().getParameters().get('recipientsIds');
        }
        
        if (ApexPages.currentPage().getParameters().get('emailSubject') != null) {
            emailSubject = ApexPages.currentPage().getParameters().get('emailSubject');
        }
        
        if (ApexPages.currentPage().getParameters().get('emailContent') != null) {
            emailContent = ApexPages.currentPage().getParameters().get('emailContent');
        }
        
        if (ApexPages.currentPage().getParameters().get('invitaionName') != null) {
            invitaionName = ApexPages.currentPage().getParameters().get('invitaionName');
        }
        
        if (ApexPages.currentPage().getParameters().get('note') != null) {
            notes = ApexPages.currentPage().getParameters().get('note');
        }
        
        if (ApexPages.currentPage().getParameters().get('selectedMictosite') != null) {
            selectedMictosite = ApexPages.currentPage().getParameters().get('selectedMictosite');
        }
        
        if (ApexPages.currentPage().getParameters().get('expDate') != null) {
            expDate = ApexPages.currentPage().getParameters().get('expDate');
        }
        
        if (ApexPages.currentPage().getParameters().get('isCcAllowed') != null) {
            isCcAllowed = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isCcAllowed'));
        }
        
        if (ApexPages.currentPage().getParameters().get('emailTo') != null) {
            emailTo = ApexPages.currentPage().getParameters().get('emailTo');
        }
        
        if (ApexPages.currentPage().getParameters().get('emailBcc') != null) {
            emailBcc = ApexPages.currentPage().getParameters().get('emailBcc');
        }
        
        if (ApexPages.currentPage().getParameters().get('emailCc') != null) {
            emailCc = ApexPages.currentPage().getParameters().get('emailCc');
        }
        
        if (ApexPages.currentPage().getParameters().get('opportunityName') != null) {
            opportunityName = ApexPages.currentPage().getParameters().get('opportunityName');
        }
        
        if (ApexPages.currentPage().getParameters().get('opportunityAccount') != null) {
            opportunityAccount = ApexPages.currentPage().getParameters().get('opportunityAccount');
        }
        
        if (ApexPages.currentPage().getParameters().get('fromLead') != null) {
            fromLead = ApexPages.currentPage().getParameters().get('fromLead') == 'true' ? true : false;
        } 
        cs = UtilityController.getCustomSettings(); 
         
        userMappingList = new List<User_Mapping__c>(); 
        lastActivity = date.today();
        showOveray = false;   
        Map<Decimal,DMNameValueWrapper> tempMapDM = new Map<Decimal,DMNameValueWrapper>();
        tempMapDM = new Map<Decimal,DMNameValueWrapper>();

        for (Data_Mapping__c dm : WithoutSharingHelperController.getDMHelpOverlay(new List<String>{UtilityController.appNamespace() + 'Invitation_NewSLDS'})) {
            tempMapDM.put(dm.Order__c, new DMNameValueWrapper(dm.Label__c,dm.DC_Message__c));
        }
        helpOverlayInvitation = JSON.serialize(tempMapDM); 

        if (cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0 && isReturned != true) {
            helpAssistant = '';
            checkForHelpOverlay();
        }
    }
    
    /**
    *   Method to check whether to show help overlay on page or not
    *   Author : Rajesh (27 May,2018) for REF-1572
    **/
    public void checkForHelpOverlay() {  
        showOveray = true; 
        labelValue = ConstantsController.INVITATION_HELP_OVERLAY;     
        userMappingList = [SELECT Id, Label__c, Count__c, User__c, Last_Used_Lightning_Page__c FROM User_Mapping__c 
                                WHERE User__c =:UserInfo.getUserId() AND Label__c =:labelValue LIMIT 1];

        if (userMappingList.Size() > 0 && userMappingList[0].Count__c !=null && userMappingList[0].Count__c >= cs.Help_Overlay_Count__c) {
            showOveray = false;
        }
        
        if (cs.Reset_Help_Assistant_Days__c != null && cs.Reset_Help_Assistant_Days__c > 0 && userMappingList.size() > 0 && userMappingList[0].Last_Used_Lightning_Page__c != null) {
             lastActivity = UtilityController.parseLastVisitDate(userMappingList[0].Last_Used_Lightning_Page__c);
        }
                 
    }
    /**
     *   Method to check whether to show help overlay on page or not
     *   Author : Rajesh (27 May,2018) for REF-1572
     **/
    public void userMappingRecord() {       
        //  check user mapping count and custom setting count
        DateTime todayDate = system.today();
        if (showOveray) { 

            if (userMappingList.Size() > 0) {                   
                    
                if (userMappingList[0].Count__c != null) {

                    if (cs.Reset_Help_Assistant_Days__c != null && lastActivity.daysBetween(Date.today()) > cs.Reset_Help_Assistant_Days__c) {
                        helpAssistant = ConstantsController.HELP_ASSISTANT;
                        userMappingList[0].Count__c = 1; 
                    } else {
                        userMappingList[0].Count__c += 1;
                    }  
                } else {
                    userMappingList[0].Count__c = 1;
                }
                userMappingList[0].Last_Used_Lightning_Page__c = todayDate.format('yyyy-MM-dd');                              
            } else {
                User_Mapping__c umr = new User_Mapping__c();
                umr.Label__c = labelValue;
                umr.Count__c = 1;
                umr.User__c = UserInfo.getUserId();
                umr.Last_Used_Lightning_Page__c = todayDate.format('yyyy-MM-dd');
                userMappingList.add(umr);
            }   
        } else if (cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0 
                    && (cs.Reset_Help_Assistant_Days__c != null && cs.Reset_Help_Assistant_Days__c > 0) 
                    && (lastActivity.daysBetween(Date.today()) > cs.Reset_Help_Assistant_Days__c)) {
            helpAssistant = ConstantsController.HELP_ASSISTANT;
            userMappingList[0].Count__c = 1;
            userMappingList[0].Last_Used_Lightning_Page__c = todayDate.format('yyyy-MM-dd');
            showOveray = true;
        } 

        if (userMappingList.Size() > 0 && cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0) { 
            upsert userMappingList;  
        }                 
    }

    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions(Boolean isOnPageLoad, String action, String oppId, String caseId) {
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        Boolean isUpsertPermissionOnTemplate = true;
        Boolean isInsertPermissionOnCreation = true;
        Boolean isUpsertOnDownload = true;
        String leadId = '';
        
        // regarding ticket #809
        if (caseId != null && caseId != '' && caseId.substring(0, 3) == '00Q') {
            leadId = caseId;
            caseId = '';
        }
        
        if (isOnPageLoad || action == 'setDefaultTemplate') {
            fieldMap.put(UtilityController.appNamespace() + 'User_Mapping__c',
                            new Set<String> {UtilityController.appNamespace() + 'Default_Value__c',
                                UtilityController.appNamespace() + 'Process__c',
                                UtilityController.appNamespace() + 'User__c'});
            isUpsertPermissionOnTemplate = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);                           
        }
        fieldMap.clear();
        
        if (isOnPageLoad || action == 'createInvitation') {
            fieldMap.put(UtilityController.appNamespace() + 'Invitation__c',
                            new Set<String> {'Name', UtilityController.appNamespace() + 'Invitation_Expiration__c',
                                UtilityController.appNamespace() + 'Start_Date__c',
                                UtilityController.appNamespace() + 'Message__c',
                                UtilityController.appNamespace() + 'Notes__c',
                                UtilityController.appNamespace() + 'Microsite__c',
                                UtilityController.appNamespace() + 'Subject__c'});
            
            if (oppId != '') {
                fieldMap.get(UtilityController.appNamespace() + 'Invitation__c').add(UtilityController.appNamespace() + 'Opportunity__c');
            }
            
            if (caseId != '') {
                fieldMap.get(UtilityController.appNamespace() + 'Invitation__c').add(UtilityController.appNamespace() + 'Case__c');
            }
            
            if (leadId != '') {
                fieldMap.get(UtilityController.appNamespace() + 'Invitation__c').add(UtilityController.appNamespace() + 'Lead__c');
            }
            fieldMap.put(UtilityController.appNamespace() + 'Invitee__c',
                            new Set<String> {UtilityController.appNamespace() + 'Contact__c',
                                UtilityController.appNamespace() + 'URL__c',
                                UtilityController.appNamespace() + 'Block_Workflow_Email__c',
                                UtilityController.appNamespace() + 'User__c',
                                UtilityController.appNamespace() + 'Other_Recipient__c'});
            isInsertPermissionOnCreation = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);                   
        }
        fieldMap.clear();
        
        if (isOnPageLoad || action == 'contentDownload') {
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Content__c',
                            new Set<String> {UtilityController.appNamespace() + 'Number_of_Download__c'});
            isUpsertOnDownload = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
        }
        return (isInsertPermissionOnCreation && isUpsertPermissionOnTemplate && isUpsertOnDownload);
    }
    
    
    /**
     * Remote action methods
     */
    @RemoteAction
    global static List<RefContentWrapper> loadReferenceContent(String selectedRefContents) {
        
        try {
            List<RefContentWrapper> refContent = new List<RefContentWrapper>();
            Set<String> contentIds = new Set<String>();
            
            if (selectedRefContents != null && selectedRefContents != '') {
                
                for (String refId : selectedRefContents.split(',')) {
                    contentIds.add(refId);
                }
            }
            List<Reference_Content__c> refContentList = WithoutSharingHelperController.getRefContentsForInvitation(contentIds);
            Set<String> tempContentIds = new Set<String>();
            Set<String> customContentIds = new Set<String>();
            Map<String, Schema.DescribeFieldResult> customContentFieldsMap = new Map<String, Schema.DescribeFieldResult>();
            Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Reference_Content_Type_Field__c');
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            Set<String> queryFieldsSet = new Set<String>();
            Map<Id, Reference_Content_Type_Field__c> customContentMap;
            queryFieldsSet.add(UtilityController.appNamespace() + 'Reference_Content__c');
            Map<Id,Set<String>> availableFields = new Map<Id,Set<String>>();
            
            for (String field : fieldMap.keySet()) {
                Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
                
                if (dfr.isCustom()) {
                    customContentFieldsMap.put(dfr.getName(), dfr);
                    queryFieldsSet.add(dfr.getName());
                    
                    if (String.valueOf(dfr.getType()) == 'REFERENCE') {
                        queryFieldsSet.add(dfr.getName().replace('__c','__r') + '.Name');
                    }
                }
            }
            for (Reference_Content__c rc : refContentList) {
                
                if (rc.Custom_Reference_Content__c) {
                    customContentIds.add(rc.Id);
                    availableFields.put(rc.Reference_Content_Type__c, new Set<String>());
                } else {
                    tempContentIds.add(rc.Content_ID__c);
                } 
            }
            Set<Id> availableFieldsKeys  = availableFields.keySet();
            
            if (customContentIds.size() > 0) {
                for (Reference_Type_Mapping__c rtm : WithoutSharingHelperController.getRefTypeMapping(availableFieldsKeys)) {
                    availableFields.get(rtm.Reference_Content_Type__c).add(rtm.name);                                                   
                }
                customContentMap = WithoutSharingHelperController.getRefContentTypeFields(new List<String>(customContentIds),queryFieldsSet);
            }
            
            Map<Id, Reference_Interview__c> refInterviewMap = new Map<Id, Reference_Interview__c>();
            List<Reference_Interview__c> tempRefInterviewList = new List<Reference_Interview__c>();
            
            tempRefInterviewList = WithoutSharingHelperController.getRefInterviewListForInvitation();
            
            for (Reference_Interview__c ri : tempRefInterviewList) {
                refInterviewMap.put(ri.Reference_Content__c, ri);
            }
            Map<Id, ContentVersion> mapContentVersion
                        = WithoutSharingHelperController.getContentVersionMapForInvitation(tempContentIds);
            
            for (Reference_Content__c rc : refContentList) {
                String AccountName = '';
                String AccountId = '';
                
                if (rc.Account_Reference_Contents__r.size() == 0) {
                    AccountName = '';
                    AccountId = '';
                } else if (rc.Account_Reference_Contents__r.size() == 1) {
                    AccountName = rc.Account_Reference_Contents__r[0].Account__r.Name;
                    AccountId = '/' + rc.Account_Reference_Contents__r[0].Account__r.Id;
                } else {
                    AccountName = System.Label.Multiple_Accounts;
                    AccountId = Page.AssociatedRefContAccounts.geturl() + '?refContentId=' + rc.Id;
                }
                
                if (mapContentVersion.containsKey(rc.Content_ID__c)) {
                    
                    if (refInterviewMap != null && refInterviewMap.containsKey(rc.Id) && refInterviewMap.get(rc.Id) != null) {
                        refContent.add(new RefContentWrapper(rc.Reference_Content_Type_Name__c, rc.Id, rc.Content_ID__c,
                                        rc.Title__c, rc.Summary__c,
                                        mapContentVersion.get(rc.Content_ID__c).FileType,
                                        String.valueof(mapContentVersion.get(rc.Content_ID__c).ContentSize),
                                        (UtilityController.mapContentTypeImagePath.containsKey(mapContentVersion.get(rc.Content_ID__c).FileType)
                                            ? UtilityController.mapContentTypeImagePath.get(mapContentVersion.get(rc.Content_ID__c).FileType)
                                            : '/doctype_unknown_16.png'),
                                        AccountId, AccountName, refInterviewMap.get(rc.Id),
                                        'Reference Interview', rc.Custom_Reference_Content__c));
                    } else {
                        refContent.add(new RefContentWrapper(rc.Reference_Content_Type_Name__c, rc.Id, rc.Content_ID__c,
                                        rc.Title__c, rc.Summary__c,
                                        mapContentVersion.get(rc.Content_ID__c).FileType,
                                        String.valueof(mapContentVersion.get(rc.Content_ID__c).ContentSize),
                                        (UtilityController.mapContentTypeImagePath.containsKey(mapContentVersion.get(rc.Content_ID__c).FileType)
                                            ? UtilityController.mapContentTypeImagePath.get(mapContentVersion.get(rc.Content_ID__c).FileType)
                                            : '/doctype_unknown_16.png'),
                                        AccountId, AccountName, rc.Custom_Reference_Content__c));
                    }
                } else if (rc.Custom_Reference_Content__c && customContentMap != null && customContentMap.containsKey(rc.Id) && customContentMap.get(rc.Id) != null) {
                    List<CustomContentTypeWrapper> customContentTypeWrapperList = new List<CustomContentTypeWrapper>();
                
                    for (String field : availableFields.get(rc.Reference_Content_Type__c)) {
                    
                        if (availableFields.get(rc.Reference_Content_Type__c).contains(field)) {
                            
                            if ((String.valueOf(customContentFieldsMap.get(field).getType()) == 'DATE' || String.valueOf(customContentFieldsMap.get(field).getType()) == 'DATETIME') && customContentMap.get(rc.Id).get(field) != null && String.valueOf(customContentMap.get(rc.Id).get(field)).trim() != '') {
                                String data = String.valueOf(customContentMap.get(rc.Id).get(field));
                                Date dateValue = date.valueOf(data);
                                Integer d = dateValue.day();
                                Integer mo = dateValue.month();
                                Integer yr = dateValue.year();
                                DateTime dateTimeValue = DateTime.newInstance(yr, mo, d);
                                data = dateTimeValue.format('MMM dd yyyy');//Format date
                                customContentTypeWrapperList.add(new CustomContentTypeWrapper(field, customContentFieldsMap.get(field).getLabel(), data, String.valueOf(customContentFieldsMap.get(field).getType())));
                            } else if (String.valueOf(customContentFieldsMap.get(field).getType()) == 'REFERENCE' && !field.contains('Reference_Content__c')) {
                                String fieldName = field.replace('__c','__r');
                                sObject data = customContentMap.get(rc.Id).getSObject(fieldName);
                                customContentTypeWrapperList.add(new CustomContentTypeWrapper(field, customContentFieldsMap.get(field).getLabel(), String.valueOf(data.get('Name')), String.valueOf(customContentFieldsMap.get(field).getType())));
                            } else if (!field.contains('Reference_Content__c')) {
                                customContentTypeWrapperList.add(new CustomContentTypeWrapper(field, customContentFieldsMap.get(field).getLabel(), customContentMap.get(rc.Id).get(field), String.valueOf(customContentFieldsMap.get(field).getType())));
                            }
                        }
                    }
                    refContent.add(new RefContentWrapper(rc.Reference_Content_Type_Name__c, rc.Id, rc.Content_ID__c,
                                        rc.Title__c, rc.Summary__c, '', '', '', AccountId, AccountName, rc.Custom_Reference_Content__c, customContentTypeWrapperList));
                } else {
                    
                    if (refInterviewMap != null && refInterviewMap.containsKey(rc.Id) && refInterviewMap.get(rc.Id) != null) {
                        refContent.add(new RefContentWrapper(rc.Reference_Content_Type_Name__c, rc.Id, rc.Content_ID__c,
                                        rc.Title__c, rc.Summary__c, rc.Reference_Content_Type__r.Name__c, '', '',
                                        AccountId, AccountName, refInterviewMap.get(rc.Id), 'Reference Interview', rc.Custom_Reference_Content__c));
                    } else {
                        refContent.add(new RefContentWrapper(rc.Reference_Content_Type_Name__c, rc.Id, rc.Content_ID__c,
                                        rc.Title__c, rc.Summary__c, '', '', '', AccountId, AccountName, rc.Custom_Reference_Content__c));
                    }
                }
            }
            return refContent;
        } catch (Exception e) {
            Apexpages.addMessages(e);
            return null;
        }
    }
    
    @RemoteAction
    global static List<MicrositesTemplate> getMicrositesList() {
        List<MicrositesTemplate> microsites;
        
        try {
            String micrositeId;
            micrositeId = UtilityController.getMicrositeTemplete();
            microsites = new List<MicrositesTemplate>();
            microsites.add(new MicrositesTemplate('', 'None', false));
            
            for (Microsite__c ms : [SELECT Id, Name FROM Microsite__c WHERE Available_for_Use__c = true
                                        ORDER BY Name LIMIT: limits.getLimitQueryRows()]) {
                
                if (micrositeId != null && micrositeId != '') {
                    microsites.add(new MicrositesTemplate(ms.Id, ms.Name, (ms.Id == micrositeId) ? true : false));
                } else {
                    microsites.add(new MicrositesTemplate(ms.Id, ms.Name, false));
                }
            }
        } catch (Exception e) {
            ApexPages.addmessages(e);
        }
        return microsites;
    }
    
    @RemoteAction
    global static List<EmailRequestWrapper> getEmailList() {
        
        try {
            List<EmailRequestWrapper> emailReqs = new List<EmailRequestWrapper>();
            String QueryString = 'SELECT Id, Name, Email FROM Contact WHERE Email != null '
                                + 'AND Email != \'\' ORDER BY Name LIMIT 20';
            
            // moved query to with sharing to enforce CRUD and FLS permissions - Gaurav Saini (13 Feb, 2017)
            for (Contact con : Database.query(QueryString)) {
                emailReqs.add(new EmailRequestWrapper(con.Id, con.Name, con.email, 'Contact', '/assets/icons/standard/contact_120.png'));
            }
            
            Set<Id> communityUsers;
            communityUsers = WithoutSharingHelperController.getCommunityUsersForCoWorkers();
            QueryString = 'SELECT Id, Name, Email FROM User WHERE IsActive = true '
                            + 'AND (NOT Name LIKE \'%Guest%\') AND ProfileId NOT IN :communityUsers ORDER BY Name LIMIT 20';
            
            for (User user : WithoutSharingHelperController.getSearchedUsersForCoWorkers(QueryString, communityUsers)) {
                emailReqs.add(new EmailRequestWrapper(user.Id, user.Name, user.email, 'User', '/assets/icons/standard/user_60.png'));
            }
            return emailReqs;
        } catch (Exception e) {
            Apexpages.addMessages(e);
            return null;
        }
    }
    
    /**
     * Method to get Date Format
     */
    @RemoteAction
    global static String getDateFormat() {   
            String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
            return dateFormat;
    }
    
    @RemoteAction
    global static List<EmailRequestWrapper> getEmailSearchList(String searchKeyword) {  
        
        try {
            List<EmailRequestWrapper> emailReqs = new List<EmailRequestWrapper>();
            String QueryString = '';
            QueryString = 'SELECT Id, Name, Email FROM Contact WHERE Email != null '
                            + 'AND Email != \'\' AND (Email LIKE  \'%' + searchKeyword + '%\' OR Name LIKE \'%' + searchKeyword + '%\' ' 
                            + 'OR FirstName LIKE \'%' + searchKeyword + '%\' OR LastName LIKE \'%' + searchKeyword + '%\') ORDER BY Name LIMIT 20';
       
            // moved query to with sharing to enforce CRUD and FLS permissions - Gaurav Saini (13 Feb, 2017)
            for (Contact con : Database.query(QueryString)) {
                emailReqs.add(new EmailRequestWrapper(con.Id, con.Name, con.email, 'Contact', '/assets/icons/standard/contact_120.png'));
            }
            
            Set<Id> communityUsers;
            communityUsers = WithoutSharingHelperController.getCommunityUsersForCoWorkers();
            QueryString = 'SELECT Id, Name, Email FROM User WHERE IsActive = true AND ProfileId NOT IN :communityUsers '
                            + 'AND (NOT Name LIKE \'%Guest%\') AND Email != null AND Email != \'\'  AND (Email LIKE  \'%' + searchKeyword + '%\' OR Name LIKE \'%' + searchKeyword + '%\' '
                            + ' OR FirstName LIKE \'%' + searchKeyword + '%\' OR LastName LIKE \'%' + searchKeyword + '%\') order by Name LIMIT 20';
            
            for (User user : WithoutSharingHelperController.getSearchedUsersForCoWorkers(QueryString, communityUsers)) {
                emailReqs.add(new EmailRequestWrapper(user.Id, user.Name, user.email, 'User', '/assets/icons/standard/user_60.png'));
            }
            
            return emailReqs;
        } catch (Exception e) {
            Apexpages.addMessages(e);
            return null;
        }
    }
    
    @RemoteAction
    global static Boolean setDefaultTemplate(String templateId) { 
        return true;
    }
    
    /**Method is used to save default template*/
    @RemoteAction
    global static String saveDefaultTemplate(String templateId) {
        
        if (checkPermissions(false, 'setDefaultTemplate', '', '')) {
            
            try {
                
                if (templateId != null && templateId != '') {
                    List<User_Mapping__c> userMappings = UtilityController.getUserMappings('Invitation');
                    
                    if (userMappings != null && userMappings.size() > 0) {
                        userMappings[0].Default_Value__c = templateId;
                    } else {
                        userMappings = new List<User_Mapping__c>();
                        userMappings.add(new User_Mapping__c(Default_Value__c = templateId, User__c = Userinfo.getUserId(), Process__c = 'Invitation'));
                    }
                    upsert userMappings;
                }
                return null;
            } catch (Exception e) {
                Apexpages.addMessages(e); 
                return CRUDAndFLSCheckController.getErrorMsg();
            }
        } else {  
            return CRUDAndFLSCheckController.getErrorMsg();
        }
    }
    
    @RemoteAction
    global static List<PageInputWrapper> getPageInputs(String opportunity, String caseId) {
        
        try {
            String accountId = '';
            String accountName = '';
            String opportunityId = opportunity;
            String opportunityName = '';
            String emailMessage = '';
            Date expDate;
            List<PageInputWrapper> lstInput = new List<PageInputWrapper>();
            Custom_Settings__c cs = UtilityController.getCustomSettings();
            Decimal defaultExpirationDays = (cs.Default_Expiration_Days__c != null ? cs.Default_Expiration_Days__c : 0);
            Decimal maximumExpirationDays = (cs.Maximum_Expiration_Days__c != null ? cs.Maximum_Expiration_Days__c : 0);
            
            if (opportunity != '') {
                List<opportunity> lstOpp = [SELECT o.AccountId, a.name, o.id, o.Name
                                                FROM Opportunity o, o.Account a
                                                WHERE o.Id = :opportunityId];
                accountId = lstOpp[0].AccountId;
                accountName = lstOpp[0].Account.Name;
                opportunityId = lstOpp[0].Id;
                opportunityName = lstOpp[0].Name;
            }
            User activeUser = [SELECT NAME, Email, PHONE, TITLE, mobilePhone, companyName
                                FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
            String phone = '';
            String mobile = '';
            String companyName = '';
            String profileName = '';
            
            if (activeUser.Phone != null && activeUser.Phone != '') {
                phone = '\n' + activeUser.Phone + ' Main';
            }
            
            if (activeUser.mobilePhone != null && activeUser.mobilePhone != '') {
                mobile = '\n' + activeUser.mobilePhone + ' Mobile';
            }
            
            if (activeUser.companyName != null && activeUser.companyName != '') {
                companyName = '\n' + activeUser.companyName;
            }
            
            if (activeUser.Title != null && activeUser.Title != '') {
                profileName = '\n' + activeUser.Title;
            }
            emailMessage = '\n\n\n\n' + activeuser.Name + profileName + companyName + phone + mobile;
            Date dateExp = date.today().addDays(Integer.valueOf(defaultExpirationDays));
            String defaultExpDate = DateTime.newInstance(dateExp.year(), dateExp.month(), dateExp.day()).format('yyyy-MM-dd');
            lstInput.add(new PageInputWrapper('Invitation ' + System.now(), defaultExpDate,
                            String.valueOf(maximumExpirationDays), '', accountName, accountId, opportunityName,
                            opportunityId, emailMessage, getEmailTemplate('Content@@@', 'date@@@')));
            return lstInput;
        } catch (Exception e) {
            Apexpages.addMessages(e);
            return null;
        }
    }
    
    @RemoteAction
    global static String createInvitation(String contactIds, String EmailIds, String userIds, String otherEmailIds,
                                            String subject, String emailcontent, String invitationName, String oppId,
                                            String caseIds, String expDate, String microSiteId, String notes,
                                            String listReferenceContent) {
        
        if (checkPermissions(false, 'createInvitation', oppId != null ? oppId : '', caseIds != null ? caseIds : '')) {
            Savepoint sp = Database.setSavepoint();
            Decimal rewardPoints = 0;
            String actionMessage = '';
            Map<String,Id> inviteeIds = new Map<String,Id>();
            String result = '';
            List<sObject> postFeedItems = new List<sObject>();
            String errMsg = 'Error' + ' ';
            String leadId = '';
            
            // regarding ticket #809
            if (caseIds != null && caseIds != '' && caseIds.substring(0, 3) == '00Q') {
                leadId = caseIds;
                caseIds = '';
            }
            try {
                Map<String, List<String>> mpEmail = (Map<String, List<String>>)JSON.deserialize(EmailIds, Map<String, List<String>>.class);
                List<String> toContacts = mpEmail.get('toContacts');
                List<String> toUser = mpEmail.get('toUser');
                List<String> toOther = mpEmail.get('toOther');
                List<String> bccContacts = mpEmail.get('bccContacts');
                List<String> bccUser = mpEmail.get('bccUser');
                List<String> bccOther = mpEmail.get('bccOther');
                List<String> ccContacts = mpEmail.get('ccContacts');
                List<String> ccUser = mpEmail.get('ccUser');
                List<String> ccOther = mpEmail.get('ccOther');
                List<String> allToEmail = new List<String>();
                List<String> allBccEmail = new List<String>();
                List<String> allCcEmail = new List<String>();
                
                if (toContacts.size() > 0) {
                    allToEmail.addAll(toContacts);
                }
                
                if (toUser.size() > 0) {
                    allToEmail.addAll(toUser);
                }
                
                if (toOther.size() > 0) {
                    allToEmail.addAll(toOther);
                }
                
                if (bccContacts.size() > 0) {
                    allBccEmail.addAll(bccContacts);
                }
                
                if (bccUser.size() > 0) {
                    allBccEmail.addAll(bccUser);
                }
                
                if (bccOther.size() > 0) {
                    allBccEmail.addAll(bccOther);
                }
                
                if (ccContacts.size() > 0) {
                    allCcEmail.addAll(ccContacts);
                }
                
                if (ccUser.size() > 0) {
                    allCcEmail.addAll(ccUser);
                }
                
                if (ccOther.size() > 0) {
                    allCcEmail.addAll(ccOther);
                }
                Custom_Settings__c cs = UtilityController.getCustomSettings();
                List<Invitee__c> invitees = new List<Invitee__c>();
                List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
                
                // Check Recipent Details
                if ((contactIds == null || contactIds == '')
                            && (userIds == null || userIds == '')
                            && (otherEmailIds == null || otherEmailIds == '')) {
                    return errMsg += System.Label.SELECT_RECIPIENT;
                }
                
                // Check Subject value
                if (subject == null || subject == '') {
                    return errMsg += System.Label.ENTER_SUBJECT;
                }
                
                // Check Invitation Expiration value
                if (expDate == null || expDate == '') {
                    return errMsg += System.Label.ENTER_INVITATION_EXPIRATION;
                }
                
                // Check Microsite Templete value
                if (microSiteId == null) {
                    return System.Label.SELECT_MICROSITE;
                }
                Date todayDate = Date.Today();
                Decimal maximumExpirationDays = (cs.Maximum_Expiration_Days__c != null ? cs.Maximum_Expiration_Days__c : 0);
                Date expirationDate = Date.valueOf(expDate);
                
                // Validation for Invitation Expiration date
                if (expirationDate <= Date.Today()) {
                    return errMsg += System.Label.INVITATION_EXPIRATION_TODAY;
                }
                // Validation for Invitation Expiration date
                Date maximumExpirationDate = todayDate.addDays(Integer.valueOf(maximumExpirationDays));
                
                if (expirationDate > maximumExpirationDate) {
                    return errMsg += (System.Label.Invitation_Expiration_Error).replace('@@@', String.valueOf(maximumExpirationDays));
                }
                Invitation__c invitation = new Invitation__c(Name = invitationName, Invitation_Expiration__c = expirationDate, Start_Date__c = todayDate);
                invitation.Subject__c = subject;
                invitation.Message__c = emailcontent.replace('<p>', '').replace('</p>', '').replace('<br />', '').replace('&nbsp;', '');
                invitation.Notes__c = notes;
                invitation.Microsite__c = microSiteId;
                
                if (oppId != null && oppId != '') {
                    invitation.Opportunity__c = oppId;
                }
                
                if (caseIds != null && caseIds != '') {
                    invitation.Case__c = caseIds;
                }
                
                // regarding ticket #809
                if (leadId != null && leadId != '') {
                    invitation.Lead__c = leadId;
                }
                
                // Insert invitation
                if (invitation.Id == null) {
                    insert invitation;
                }
                // Recepient as Contact 
                List<String> listContactIds = new List<String>();
                
                if (contactIds != null && contactIds != '') {
                    listContactIds = contactIds.split(',');
                }
                List<Id> contactList = new List<Id>((List<Id>)listContactIds);
                Set<Id> idSetC = new Set<Id>();
                idSetC.addAll(contactList);
                Map<Id, Contact> mapContact = new Map<Id, Contact>([SELECT Id, FirstName, Name, Email
                                                                    FROM Contact WHERE Id IN :contactList]);
                
                for (String contactId : contactList) {
                    String uniqueUrl = UtilityController.getSiteUrl() + Page.PreviewMicrositeNew.geturl()
                                        + '?key=' + getEncryptedUniqueKey(invitation.id, contactId);
                    Invitee__c tempObj = new Invitee__c();
                    tempObj.Invitation__c = invitation.Id;
                    tempObj.Contact__c = contactId;
                    tempObj.URL__c = uniqueUrl;
                    tempObj.Block_Workflow_Email__c = true;
                    invitees.add(tempObj);
                }
                // Recepient as user 
                List<String> listUserIds = new List<String>();
                
                if (userIds != null && userIds != '') {
                    listUserIds = userIds.split(',');
                }
                List<Id> userList = new List<Id>((List<Id>)listUserIds);
                Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, FirstName, Name, Email
                                                                FROM User WHERE Id IN :userList]);
                
                for (String userId : userList) {
                    String uniqueUrl = UtilityController.getSiteUrl() + Page.PreviewMicrositeNew.geturl()
                                        + '?key=' + getEncryptedUniqueKey(invitation.id, userId);
                    Invitee__c tempObj = new Invitee__c();
                    tempObj.Invitation__c = invitation.Id;
                    tempObj.User__c = userId;
                    tempObj.URL__c = uniqueUrl;
                    tempObj.Block_Workflow_Email__c = true;
                    invitees.add(tempObj);
                }
                
                // Recepient as other user
                List<String> listOtherIds = new List<String>();
                if (otherEmailIds != null && otherEmailIds != '') {
                    otherEmailIds = otherEmailIds.replace('"', '').replace('[', '').replace(']', '');
                    
                    if (otherEmailIds != '') {
                        listOtherIds = otherEmailIds.split(',');
                    }
                } 
                    
                for (String emailId : listOtherIds) {
                    
                    if (emailId.replace('"', '').replace('[', '').replace(']', '') != '') { // re #245
                        String recipentId = emailId.replaceAll('[^a-zA-Z0-9]', '');
                        String uniqueUrl = UtilityController.getSiteUrl() + Page.PreviewMicrositeNew.geturl()
                                            + '?key=' + getEncryptedUniqueKey(invitation.id, recipentId);
                        Invitee__c tempObj = new Invitee__c();
                        tempObj.Invitation__c = invitation.Id;
                        tempObj.URL__c = uniqueUrl;
                        tempObj.Other_Recipient__c = emailId.replace('"', '').replace('[', '').replace(']', '');
                        invitees.add(tempObj);
                    }
                }
                
                // Insert Recepient
                if (invitees.size() > 0) {
                    invitees = WithoutSharingHelperController.insertInvitees(invitees);
                }
                
                // Insert Reference Content invitation 
                if (listReferenceContent != null && listReferenceContent != '') {
                    String[] refCon = listReferenceContent.split(',');
                    List<Invitation_ReferenceContent__c> IRCList = new List<Invitation_ReferenceContent__c>();
                    List<Invitee__c> updateList = new List<Invitee__c>();
                    for (Invitee__c invitee : invitees) {
                        
                        for (Integer i = 0; i < refCon.size(); i++) {
                            Invitation_ReferenceContent__c ircObj = new Invitation_ReferenceContent__c();
                            ircObj.Invitation__c = invitation.Id;
                            ircObj.Reference_Content__c = (Id) refCon[i];
                            ircObj.Recipient__c = invitee.id;
                            IRCList.add(ircObj);
                        }

                        if (invitee.Other_Recipient__c != null && invitee.Other_Recipient__c != '') {
                            inviteeIds.put(invitee.Other_Recipient__c , invitee.id);
                            String uniqueUrl = UtilityController.getSiteUrl() + Page.PreviewMicrositeNew.geturl()
                                            + '?key=' + getEncryptedUniqueKey(invitation.id, invitee.id);
                            invitee.URL__c = uniqueUrl;
                            updateList.add(invitee);
                        }
                    }
                    if (updateList.size() > 0) {
                        WithoutSharingHelperController.updateInvitees(updateList);
                    }
                    if (IRCList.size() > 0) {
                        WithoutSharingHelperController.insertIRCList(IRCList);
                    }
                }
                
                // Below condtion added for Sales Reward Implementation RE #145 Issue Sales Reward Invitation
                //          - to Contact and Invitation ? to Co Worker
                if (RefEdgeEditionFeatures.isBasic == false && cs.Enable_Sales_Rewards_Notification__c == true) {
                    List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
                    List<Referenceability_Type__c> refType = new List<Referenceability_Type__c>();
                    List<String> lstUserAction = new List<String>();
                    
                    if (contactIds != null && contactIds != '') {
                        lstUserAction.add(ConstantsController.INVITATION_TO_CONTACT);                       
                    } else if (userIds != null && userIds != '') {
                        lstUserAction.add(ConstantsController.INVITATION_TO_CO_WORKER);                      
                    }
                    refType = WithoutSharingHelperController.getReferenceabilityRewardDetails(lstUserAction);  
                    
                    // re #583 -Null check for User reward points.
                    if (refType.size() > 0 && refType[0].Sales_Point__c != null) {
                        rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c,
                                                    Referenceability_Type__c = refType[0].Id,
                                                    Transaction__c = ConstantsController.ISSUE,
                                                    RewardDate__c = Date.Today(),
                                                    User__c = Userinfo.getUserId()));
                        UtilityController.isUserProfileExist(Userinfo.getUserId());
                        
                        // re #591 NEW field  Onscreen Notification allow for on/off for onscreen notification.
                        if (cs.User_Reward_Onscreen_Notification__c) {
                            actionMessage = refType[0].Name;
                            rewardPoints = refType[0].Sales_Point__c;
                            result = actionMessage + ',' + rewardPoints;
                        }
                    }
                    
                    if (rewardsToBeInsert.size() > 0) {
                        WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
                    }
                }
                String emailContant = getEmailTemplate(emailcontent, invitation.Invitation_Expiration__c.format());
                String emailtxt = '';
                
                if (contactList.size() > 0) {
                    emailtxt = emailContant;
                    
                    for (Integer i = 0; i < contactList.size(); i++) {
                        emailtxt = emailContant;
                        emailtxt = emailtxt.replace('href="#"', 'href="' + UtilityController.getSiteUrl()
                                                                            + Page.PreviewMicrositeNew.geturl() + '?key='
                                                                            + getEncryptedUniqueKey(invitation.Id, contactList[i]) + '"');
                        SendEmailTemplate(contactList[i], subject, emailtxt, null);
                    }
                }
                
                if (userList.size() > 0) {
                    emailtxt = emailContant;
                    
                    for (Integer i = 0; i < userList.size(); i++) {
                        emailtxt = emailContant;
                        emailtxt = emailtxt.replace('href="#"', 'href="' + UtilityController.getSiteUrl()
                                                                            + Page.PreviewMicrositeNew.geturl() + '?key='
                                                                            + getEncryptedUniqueKey(invitation.Id, userList[i]) + '"');
                        SendEmailTemplate(userList[i], subject, emailtxt, null);
                    }
                }
                 
                if (listOtherIds.size() > 0) {
                    emailtxt = emailContant;
                    String recipentId;
                    
                    for (Integer i = 0; i < listOtherIds.size(); i++) {
                        emailtxt = emailContant;
                        recipentId = listOtherIds[i].replace('"', '').replace('[', '').replace(']', '');
                        recipentId = inviteeIds.containsKey(recipentId) ? inviteeIds.get(recipentId) : listOtherIds[i].replaceAll('[^a-zA-Z0-9]', '');
                        emailtxt = emailtxt.replace('href="#"', 'href="' + UtilityController.getSiteUrl()
                                                                            + Page.PreviewMicrositeNew.geturl() + '?key='
                                                                            + getEncryptedUniqueKey(invitation.id, recipentId) + '"');
                        SendEmailTemplate(null, subject, emailtxt, listOtherIds[i].replace('"', '').replace('[', '').replace(']', ''));
                    }
                }
            } catch (Exception e) {
                Apexpages.addMessages(e);
                errMsg += e.getMessage();
                Database.rollback(sp);
                return errMsg;
            }
            return String.valueOf(result);
        } else { 
            return 'Error' + ' ' + CRUDAndFLSCheckController.getErrorMsg();
        }
    }
    
    /**
     * Method to single download
     */
    @RemoteAction
    global static String contentDownload(String hoverRefContentId) {
        
        if (checkPermissions(false, 'contentDownload', '', '')) {
            
            try {
                
                if (hoverRefContentId != '') {
                    List<Reference_Content__c> updateDownloads = new List<Reference_Content__c>();
                    List<Reference_Content__c> tempList = [SELECT Id, Number_of_Download__c, Content_ID__c
                                                            FROM Reference_Content__c WHERE Id =: hoverRefContentId];
                    
                    for (Reference_Content__c refContent : tempList) {
                        Reference_Content__c temp = refContent;
                        Decimal downloadNo = (temp.Number_of_Download__c != null ? temp.Number_of_Download__c : 0);
                        temp.Number_of_Download__c = downloadNo + 1;
                        updateDownloads.add(temp);
                    }
                    
                    if (updateDownloads.size() > 0) {
                        //update updateDownloads;
                        WithoutSharingHelperController.upsertRefContentList(updateDownloads);
                    }
                }
                String ContentUrl = '';
                ContentVersion hoverContentVersion = new ContentVersion();
                List<ContentVersion> lstCV = [SELECT Id, Title, FileType, ContentUrl, VersionNumber, PositiveRatingCount,
                                                ContentDocumentId, FirstPublishLocationId, CreatedDate, CreatedById,
                                                Description, ContentSize
                                                FROM ContentVersion
                                                WHERE Id = :hoverRefContentId];
                
                if (lstCV.size() > 0) {
                    hoverContentVersion = lstCV[0];
                }
                
                if (hoverContentVersion.FileType == 'LINK') {
                    ContentUrl = hoverContentVersion.ContentUrl;
                } else {
                    ContentUrl = 'sfc/servlet.shepherd/document/download/' + hoverContentVersion.ContentDocumentId;
                }
                return ContentUrl;
            } catch (Exception e) {
                Apexpages.addMessages(e);
                return null;
            }
        } else {
            return null;
        }
    }
    
    public static String getEncryptedUniqueKey(String invitationId, String recepientId) {
        // Changes made for #614 by Gaurav Saini (29 Nov, 2016)
        //String specialChar = 'KzcBgAgfds';
        String dataString = 'invitationId' + invitationId + 'recepientId' + recepientId;
        String encodedKey = UtilityController.getEncodedKey();
        blob blobdata = EncodingUtil.base64Decode(dataString);
        blob key = EncodingUtil.base64Decode(encodedKey);
        blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, blobdata);
        String encryptedString = EncodingUtil.base64Encode(encryptedData);
        //encryptedString = encryptedString + specialChar + EncodingUtil.base64Encode(key);
        return encryptedString;
    }
    
    public static String getEmailTemplate(String content, String expdate) {
        String templateBody = '';
        String plainTxtBody = '';
        String hbody = '';
        List<EmailTemplate> templist = [SELECT Id, Subject, body, HTMLValue, BrandTemplateId
                                            FROM EmailTemplate
                                            WHERE DeveloperName = 'Invitation_Email_Template'];
        
        if (templist.size() > 0) {
            EmailTemplate temp = templist[0];
            List<BrandTemplate> letterHeads = [SELECT Value FROM BrandTemplate WHERE Id = :temp.BrandTemplateId LIMIT 1];
            
            if (letterHeads.size() > 0) {
                String textValue = letterHeads[0].Value;
                String header = textValue.substringBetween('<![CDATA[', ']]>');
                textValue = textValue.replace('<![CDATA[' + header + ']]>', '');
                String footer = '';
                
                while (textValue.contains('<![CDATA[') && footer == '') {
                    footer = textValue.substringBetween('<![CDATA[', ']]>');
                    
                    if (footer == '') {
                        textValue = textValue.replace('<![CDATA[]]>', '');
                    }
                }
                header = URL.getSalesforceBaseUrl().toExternalForm() + header; // #430 by rekha
                footer = URL.getSalesforceBaseUrl().toExternalForm() + footer; // #430 by rekha
                String tempStr = '';
                String bar1 = '';
                String bar2 = '';
                String bar3 = '';
                String height1 = '';
                String height2 = '';
                String height3 = '';
                String valignheader = '';
                String valignfooter = '';
                String textalignheader = '';
                String textalignfooter = '';
                String headerHeight = '';
                String footerHeight = '';
                String headercolor = '';
                String footercolor = '';
                
                while (textValue.contains('<style')) {
                    tempStr = textValue.substringBetween('<style', '</style>');
                    
                    if (tempStr.contains('bLabel="header"')) {
                        headercolor = tempStr.substringBetween('background-color="', '"');
                        headerHeight = tempStr.substringBetween('height="', '"');
                        valignheader = tempStr.substringBetween('vertical-align="', '"');
                        textalignheader = tempStr.substringBetween('text-align="', '"');
                    }
                    
                    if (tempStr.contains('bLabel="footer"')) {
                        footercolor = tempStr.substringBetween('background-color="', '"');
                        footerHeight = tempStr.substringBetween('height="', '"');
                        valignfooter = tempStr.substringBetween('vertical-align="', '"');
                        textalignfooter = tempStr.substringBetween('text-align="', '"');
                    }
                    
                    if (tempStr.contains('bLabel="accent1"')) {
                        bar1 = tempStr.substringBetween('background-color="', '"');
                        height1 = tempStr.substringBetween('height="', '"');
                    }
                    
                    if (tempStr.contains('bLabel="accent2"')) {
                        bar2 = tempStr.substringBetween('background-color="', '"');
                        height2 = tempStr.substringBetween('height="', '"');
                    }
                    
                    if (tempStr.contains('bLabel="accent3"')) {
                        bar3 = tempStr.substringBetween('background-color="', '"');
                        height3 = tempStr.substringBetween('height="', '"');
                    }
                    textValue = textValue.replace('<style' + tempStr + '</style>', '');
                }
                templateBody =
                    '<div style="background-color:#ffffff"><center><table height="500px" width="550px" cellpadding="0" cellspacing="0"><tbody><tr valign="top"><td style="vertical-align:' +
                    valignheader + ';height:' + headerHeight + 'px;text-align:' + textalignheader + ';background-color:' + headercolor +
                    ';padding-left: 5px;"><img src="' + header + '"alt="Company Header Logo"/></td></tr><tr valign="top"><td style="height:' + height1 +
                    'px;background-color:' + ((bar1 != null && bar1 != '') ? bar1 : '#ffcc99') +
                    '"></td></tr><tr valign="top"><td height="350px" style="color:#000000;font-size:12pt;background-color:#FFFFFF;font-family:arial"><div style="text-align:left;font-family: arial;font-size: 12pt;padding: 10px;">' +
                    temp.HTMLValue + '</div></td></tr><tr valign="top"><td style="height:' + height2 + 'px;background-color:' + ((bar2 != null && bar2 !=
                        '') ? bar2 : '#ffcc99') + '"></td></tr><tr valign="top"><td style="vertical-align:' + valignfooter + ';height:' + footerHeight +
                    'px;text-align:' + textalignfooter + ';background-color:' + footercolor + '"><img src="' + footer +
                    '"alt="Company Footer Logo"/></td></tr><tr valign="top"><td style="height:' + height3 + 'px;background-color:' + ((bar3 != null && bar3 !=
                        '') ? bar3 : '#ffcc99') + '"></td></tr></tbody></table></center><br><br></div>';
                
                templateBody = templateBody.replace('<![CDATA[', '');
                templateBody = templateBody.replace(']]>', '');
                templateBody = templateBody.replace('{!' + UtilityController.appNamespace() + 'Invitation__c.' + UtilityController.appNamespace() +
                    'Message__c}', content);
                templateBody = templateBody.replace('{!' + UtilityController.appNamespace() + 'Invitation__c.' + UtilityController.appNamespace() +
                    'Invitation_Expiration__c}', expdate);
                templateBody = templateBody.replace('{!' + UtilityController.appNamespace() + 'Invitee__c.' + UtilityController.appNamespace() +
                    'View_Microsite__c}', '<a href="#" onclick="previewMicrosite(); return false;"> ' + SYSTEM.LABEL.Preview_Microsite + '</a>');
            }
        }
        return templateBody;
    }
    public static String SendEmailTemplate(Id responseEmailToIds, String subject, String templateBody, String otherEmailIds) {
        
        try {
            Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
            List<String> emailsIds = new List<String>();
            
            if (otherEmailIds != null && otherEmailIds != '') {
                emailsIds = otherEmailIds.split(',');
            }
            
            if (responseEmailToIds != null) {
                mail.setTargetObjectId(responseEmailToIds);
            } else if (emailsIds != null && emailsIds.size() > 0) {
                mail.setToAddresses(emailsIds);
            }
            mail.setSaveAsActivity(false);
            mail.setSubject(subject);
            mail.setHtmlBody(templateBody);
            Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail });
            return null;
        } catch (Exception e) {
            Apexpages.addMessages(e);
        }
        return null;
    }
    
    /**
     * Wrapper class
     */
    global class EmailRequestWrapper {
        public String Id { get; set; }
        public String Name { get; set; }
        public String Email { get; set; }
        public String Type { get; set; }
        public String Imgurl { get; set; }
        
        public EmailRequestWrapper(String id, String name, String email, String type, String imgUrl) {
            this.Id = id;
            this.Name = name;
            this.Email = email;
            this.Type = type;
            this.Imgurl = imgUrl;
        }
    }
    
    global class VideoWrapper {
        public String videoURL { get; set; }
        public String questionTitle { get; set; }
        
        global VideoWrapper(Interview_Topic__c interviewTopic) {
            this.videoURL = (interviewTopic.Video_Url_Embed__c != null && interviewTopic.Video_Url_Embed__c != '' ? interviewTopic.Video_Url_Embed__c : '');
            this.questionTitle = (interviewTopic.Question__c != null ? interviewTopic.Question__c : '');
        }
    }
    
    global class RefContentWrapper {
        public String RefContentId { get; set; }
        public String ContentId { get; set; }
        public String Title { get; set; }
        public String Summary { get; set; }
        public String AccountId { get; set; }
        public String Account { get; set; }
        public String FileType { get; set; }
        public String RefContentTypeName { get; set; }
        public String FileSize { get; set; }
        public String FileTypeImagePath { get; set; }
        public String SpeakerInfo { get; set; }
        public String OrgWebsite { get; set; }
        public String OrgDescription { get; set; }
        public String SpeakerPhoto { get; set; }
        public Boolean IsAccessible { get; set; }
        public Boolean isCustomContent { get; set; }
        public String InterviewType { get; set; }
        public List<VideoWrapper> videoWrapList { get; set; }
        List<CustomContentTypeWrapper> customContentFieldsList { get; set; }

        public RefContentWrapper(String RefContentTypeName, String refId, String contentId, String title,
                                    String summary, String fileType, String filSize, String imgPath, String accountId,
                                    String accountName, Reference_Interview__c refInterview, String isInterviewType, Boolean isCustomContent) {
            this.RefContentId = refId;
            this.ContentId = contentId;
            this.Title = title;
            this.Summary = summary;
            this.FileType = (fileType != null ? (fileType != '' ? fileType : 'UNKNOWN') : 'UNKNOWN');
            this.FileSize = filSize;
            this.FileTypeImagePath = imgPath;
            this.AccountId = accountId;
            this.Account = accountName;
            this.RefContentTypeName = RefContentTypeName;
            this.InterviewType = isInterviewType;
            this.SpeakerInfo = refInterview.Speaker_info__c;
            this.OrgWebsite = refInterview.Org_website__c;
            this.OrgDescription = refInterview.Org_description__c;
            this.SpeakerPhoto = refInterview.Photograph__c;
            this.isCustomContent = isCustomContent;
            
            if (SpeakerPhoto != '' && SpeakerPhoto != null) {
                this.SpeakerPhoto = this.SpeakerPhoto.substringAfter('src=');
                this.SpeakerPhoto = this.SpeakerPhoto.substringBefore('>');
                this.SpeakerPhoto = this.SpeakerPhoto.replace('"', '');
                this.SpeakerPhoto = this.SpeakerPhoto.replace('amp;', '');
            }
            this.IsAccessible = Schema.sObjectType.Reference_Content__c.isAccessible();
            this.VideoWrapList = new List<VideoWrapper>();
            
            if (refInterview.Interview_Topics__r != null && refInterview.Interview_Topics__r.size() > 0) {
                
                for (Interview_Topic__c it: refInterview.Interview_Topics__r) {
                    this.videoWrapList.add(new VideoWrapper(it));
                }
            }
        }
        
        public RefContentWrapper(String RefContentTypeName, String refId, String contentId, String title,
                                    String summary, String fileType, String filSize, String imgPath, String accountId,
                                    String accountName, Reference_Interview__c refInterview, String isInterviewType) {
            this.RefContentId = refId;
            this.ContentId = contentId;
            this.Title = title;
            this.Summary = summary;
            this.FileType = (fileType != null ? (fileType != '' ? fileType : 'UNKNOWN') : 'UNKNOWN');
            this.FileSize = filSize;
            this.FileTypeImagePath = imgPath;
            this.AccountId = accountId;
            this.Account = accountName;
            this.RefContentTypeName = RefContentTypeName;
            this.InterviewType = isInterviewType;
            this.SpeakerInfo = refInterview.Speaker_info__c;
            this.OrgWebsite = refInterview.Org_website__c;
            this.OrgDescription = refInterview.Org_description__c;
            this.SpeakerPhoto = refInterview.Photograph__c;
            
            if (SpeakerPhoto != '' && SpeakerPhoto != null) {
                this.SpeakerPhoto = this.SpeakerPhoto.substringAfter('src=');
                this.SpeakerPhoto = this.SpeakerPhoto.substringBefore('>');
                this.SpeakerPhoto = this.SpeakerPhoto.replace('"', '');
                this.SpeakerPhoto = this.SpeakerPhoto.replace('amp;', '');
            }
            this.IsAccessible = Schema.sObjectType.Reference_Content__c.isAccessible();
            this.VideoWrapList = new List<VideoWrapper>();
            
            if (refInterview.Interview_Topics__r != null && refInterview.Interview_Topics__r.size() > 0) {
                
                for (Interview_Topic__c it: refInterview.Interview_Topics__r) {
                    this.videoWrapList.add(new VideoWrapper(it));
                }
            }
        }
        
        public RefContentWrapper(String RefContentTypeName, String refId, String contentId, String title, String summary,
                                String fileType, String filSize, String imgPath, String accountId, String accountName) {
            this.RefContentId = refId;
            this.ContentId = contentId;
            this.Title = title;
            this.RefContentTypeName = RefContentTypeName;
            this.Summary = summary;
            this.FileType = (fileType != null ? (fileType != '' ? fileType : 'UNKNOWN') : 'UNKNOWN');
            this.FileSize = filSize;
            this.FileTypeImagePath = imgPath;
            this.AccountId = accountId;
            this.Account = accountName;
            this.InterviewType = 'Other';
            this.IsAccessible = Reference_Content__c.SObjectType.getDescribe().isUpdateable();
        }

        public RefContentWrapper(String RefContentTypeName, String refId, String contentId, String title, String summary,
                                String fileType, String filSize, String imgPath, String accountId, String accountName, Boolean isCustomContent) {
            this.RefContentId = refId;
            this.ContentId = contentId;
            this.Title = title;
            this.RefContentTypeName = RefContentTypeName;
            this.Summary = summary;
            this.FileType = (fileType != null ? (fileType != '' ? fileType : 'UNKNOWN') : 'UNKNOWN');
            this.FileSize = filSize;
            this.FileTypeImagePath = imgPath;
            this.AccountId = accountId;
            this.Account = accountName;
            this.InterviewType = 'Other';
            this.isCustomContent = isCustomContent;
            this.IsAccessible = Reference_Content__c.SObjectType.getDescribe().isUpdateable();
        }
        //Custom Content
        public RefContentWrapper(String RefContentTypeName, String refId, String contentId, String title, String summary,
                                String fileType, String filSize, String imgPath, String accountId, String accountName, Boolean isCustomContent, List<CustomContentTypeWrapper> customContentFieldsList) {
            this.RefContentId = refId;
            this.ContentId = contentId;
            this.Title = title;
            this.RefContentTypeName = RefContentTypeName;
            this.Summary = summary;
            this.FileType = (fileType != null ? (fileType != '' ? fileType : 'UNKNOWN') : 'UNKNOWN');
            this.FileSize = filSize;
            this.FileTypeImagePath = imgPath;
            this.AccountId = accountId;
            this.Account = accountName;
            this.InterviewType = 'Other';
            this.isCustomContent = isCustomContent;
            this.customContentFieldsList = customContentFieldsList;
            this.IsAccessible = Reference_Content__c.SObjectType.getDescribe().isUpdateable();
        }
    }
    
    global class MicrositesTemplate {
        public String Id { get; set; }
        public String Name { get; set; }
        public Boolean IsSelected { get; set; }
        
        public MicrositesTemplate(String id, String name, Boolean isSelected) {
            this.Id = id;
            this.Name = name;
            this.IsSelected = isSelected;
        }
    }
    
    global class PageInputWrapper {
        public String InvitaionName { get; set; }
        public String DefaultExpirationDays { get; set; }
        public String MaximumExpirationDays { get; set; }
        public String Notes { get; set; }
        public String OpportunityAccount { get; set; }
        public String OpportunityAccountId { get; set; }
        public String OpportunityName { get; set; }
        public String OpportunityId { get; set; }
        public String EmailContent { get; set; }
        public String EmailTemplate { get; set; }
        
        public PageInputWrapper(String invitationName, String defaultExpire, String maxExpire, String notes,
                                    String oppAccount, String oppAccountId, String oppName, String oppId,
                                    String emailContent, String template) {
            this.InvitaionName = invitationName;
            this.DefaultExpirationDays = defaultExpire;
            this.MaximumExpirationDays = maxExpire;
            this.Notes = notes;
            this.OpportunityAccount = oppAccount;
            this.OpportunityAccountId = oppAccountId;
            this.OpportunityName = oppName;
            this.OpportunityId = oppId;
            this.EmailContent = emailContent;
            this.EmailTemplate = template;
        }
    }

    /**
     * Wrapper class
    */
    public class DMNameValueWrapper {
        public String header {get;set;}
        public Object value {get;set;}
        public DMNameValueWrapper(String header, Object value) {
            this.value = value;
            this.header = header;
        }
    }
    
    /**
     * Wrapper Classes
     */
    global class CustomContentTypeWrapper {
        String label { get; set; }
        String apiName { get; set; }
        String value { get; set; }
        String type { get; set; }

        global CustomContentTypeWrapper (String apiName, String label, Object value, String type) {
            this.apiName = apiName;
            this.label = label;
            this.type = type;
            this.value = String.valueOf(value);
        }
    }
}