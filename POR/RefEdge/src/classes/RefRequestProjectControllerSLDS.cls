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
 * VF Page: RefRequestProjectSLDS.page
 * Description: controller for request detail page in lightning workspace
 * author: Gaurav Saini (28 Feb, 2018)
 */
public with sharing class RefRequestProjectControllerSLDS extends RefEdgeEditionFeatures {

    private static String SPECIFIED_REQUEST_MESSAGE = 'I would like to use an account as a reference for which you are the owner.  ';
    private static String APPROVE_DECLINE_LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.SelectReferenceUseContacts.getURL() + '?id=';
    private static String APPROVE_DECLINE_TITLE = 'Approve/Decline';
    private static String REFERENCE_REQUEST_TASK_SUBJECT = 'Reference Use Approval Request';
    public String refRequestId { get; set; }
    public String accRequestId { get; set; }
    public String unspecRequestId { get; set; }
    public Decimal contactRULPeriod { get; set; }
    public Decimal accountRULPeriod { get; set; }
    public Boolean isInfluitiveEnabled { get; set; }
    public Boolean checkPeer2PeerEmailSetting { get; set; }
    public Boolean checkPeer2PeerChatterSetting { get; set; }
    public Boolean checkManagedChatterSetting { get; set; }
    public Boolean checkManagedEmailSetting { get; set; }
    public Boolean isAdvRoutingEnabled { get; set; }
    public String routingGroupsFieldLabel { get; set; }
    public String dateFormat { get; set; }
    public String todayDate { get; set; }
    public Decimal minDifferenceForProcessChange { get; set; }
    public String timePicklistJson { get; set; }
    public String selection { get; set; }
    public String baseUrl { get; set; }
    //REF-2132
    public String firstPublishLocationIdForCV { get;set; }
    public Boolean attachSupportingDocuments { get;set; }

    public RefRequestProjectControllerSLDS() {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        contactRULPeriod = cs.RUL_Period_Contact__c != null ? cs.RUL_Period_Contact__c : -1;
        accountRULPeriod = cs.RUL_Period__c != null ? cs.RUL_Period__c : -1;
        isInfluitiveEnabled = cs.Is_Influitive_Integration_Enabled__c != null ? cs.Is_Influitive_Integration_Enabled__c : false;
        checkPeer2PeerEmailSetting = cs.Request_Peer2Peer_Email__c;
        checkPeer2PeerChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Peer2Peer_Chatter__c);
        checkManagedChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Managed_Chatter__c);
        checkManagedEmailSetting = cs.Request_Managed_Email__c;
        isAdvRoutingEnabled = cs.Adv_Request_Routing__c;
        minDifferenceForProcessChange = cs.Managed_to_P2P_Min__c != null ? cs.Managed_to_P2P_Min__c : -1;
        routingGroupsFieldLabel = (cs.Adv_Routing_Group_Lbl__c == null || cs.Adv_Routing_Group_Lbl__c == '')
                                    ? System.Label.Advanced_Routing_Group : cs.Adv_Routing_Group_Lbl__c;
        refRequestId = ApexPages.currentPage().getParameters().get('rrId') != null
                    ? ApexPages.currentPage().getParameters().get('rrId')
                    : (ApexPages.currentPage().getParameters().get('id') != null
                        ? ApexPages.currentPage().getParameters().get('id') : '');
        //REF-2132
        firstPublishLocationIdForCV = String.valueOf(UserInfo.getUserId());
		attachSupportingDocuments = cs.Attach_Supporting_Documents_To_Requests__c;
        accRequestId = ApexPages.currentPage().getParameters().get('arId') != null
                    ? ApexPages.currentPage().getParameters().get('arId') : '';
        unspecRequestId = ApexPages.currentPage().getParameters().get('urId') != null
                    ? ApexPages.currentPage().getParameters().get('urId') : '';
        selection = ApexPages.currentPage().getParameters().get('selection') != null
                    ? ApexPages.currentPage().getParameters().get('selection') : '';
        dateFormat = ConstantsController.localeDateFormatMap.containsKey(UserInfo.getLocale())
                    ? ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0) : 'yyyy-MM-dd';
        todayDate = Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
        List<String> timePicklistValues = new List<String>();
        timePicklistValues.add('00:00--12:00 AM');
        timePicklistValues.add('00:30--12:30 AM');
        Decimal value = 1.00;
        String timeString = '';
        
        while (value < 12.00) {
            timeString = String.valueOf(value) + ' AM';
            String timeValue = value + '';
            
            if (timeString.contains('.50')) {
                timeString = timeString.replace('.50', ':30');
                timeValue = timeValue.replace('.50', ':30');
            }
            
            if (timeString.contains('.00')) {
                timeString = timeString.replace('.00', ':00');
                timeValue = timeValue.replace('.00', ':00');
            }
            timePicklistValues.add(timeValue + '--' + timeString);
            value += 00.50; 
        }
        timePicklistValues.add('12:00--12:00 PM');
        timePicklistValues.add('12:30--12:30 PM');
        value = 1.00;
        
        while (value < 12.00) {
            timeString = String.valueOf(value) + ' PM';
            String timeValue = 12 + value + '';
            
            if (timeString.contains('.50')) {
                timeString = timeString.replace('.50', ':30');
                timeValue = timeValue.replace('.50', ':30');
            }
            
            if (timeString.contains('.00')) {
                timeString = timeString.replace('.00', ':00');
                timeValue = timeValue.replace('.00', ':00');
            }
            timePicklistValues.add(timeValue + '--' + timeString);
            value += 00.50; 
        }
        timePicklistJson = JSON.serialize(timePicklistValues);
    }

    /**
     * method to check permissions
     * author: Gaurav Saini (10 Mar, 2018)
     */
    private static Boolean checkPermissions(String process, Boolean isProCom, List<String> refTypeIds) {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        Boolean result = true;

        if (process == 'edit request') {
            result = result && CRUDAndFLSCheckController.isDeletable(new List<String>{UtilityController.appNamespace() + 'Reference_Type_Mapping__c'});
            Set<String> addInfoFieldNames = new Set<String>();
            fieldMap = new Map<String, Set<String>>();

            for (Reference_Type_Mapping__c tempObj : [SELECT Name FROM Reference_Type_Mapping__c
                                                        WHERE Referenceability_Type__c IN :refTypeIds
                                                        AND (Visible__c = true OR Required__c = true)
                                                        AND Label__c = null]) {

                if (!addInfoFieldNames.contains(tempObj.Name)) {
                    addInfoFieldNames.add(tempObj.Name);
                }
            }
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Additional_Info__c', addInfoFieldNames);
            result = result && CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
        } else if (process == 'edit filters') {
            result = result && CRUDAndFLSCheckController.isDeletable(new List<String>{UtilityController.appNamespace() + 'Reference_Request_Label_Attribute__c'});
            fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Label__c',
                            new Set<String>{UtilityController.appNamespace() + 'Reference_Request__c',
                                            UtilityController.appNamespace() + 'Label__c'});
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Label_Attribute__c',
                            new Set<String>{UtilityController.appNamespace() + 'Reference_Request_Label__c',
                                            UtilityController.appNamespace() + 'Attribute__c'});
            result = result && CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        } else if (process == 'delete cic' && isProCom) {
            result = result && CRUDAndFLSCheckController.isDeletable(new List<String>{UtilityController.appNamespace() + 'Community_Invite_Contact__c'});
        } else if (process == 'post to community' && isProCom) {
            fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Community_Invite_Attribute__c',
                            new Set<String>{UtilityController.appNamespace() + 'Community_Invite__c',
                                            UtilityController.appNamespace() + 'Filter__c',
                                            UtilityController.appNamespace() + 'Attribute__c'});
            fieldMap.put(UtilityController.appNamespace() + 'Community_Invite__c', new Set<String>());
            result = result && CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        }
        return result;
    }

    /**
     * method to check permissions
     * author: Gaurav Saini (10 Mar, 2018)
     */
    @RemoteAction
    public static String getPermissionsMessage(String processName, Boolean isProCom, String refTypeIdsJson) {
        List<String> refTypeIds = (List<String>)JSON.deserialize(refTypeIdsJson, List<String>.class);
    	Boolean isPermissionGranted = checkPermissions(processName, isProCom, refTypeIds);
    	return CRUDAndFLSCheckController.getErrorMsg();
    }

    /**
     * method to create reminder for hit list record
     * author: Gaurav Saini (10 Mar, 2018)
     */
    @RemoteAction
    public static String createReminder(String reminderMapJson, Boolean sendMail) {
        Savepoint sp = Database.setSavepoint();
        String result = '';

        try {
            Task taskObject = new Task();
            Map<String, String> reminderMap = (Map<String, String>)JSON.deserialize(reminderMapJson, Map<String, String>.class);
            taskObject.IsReminderSet = true;
            Time reminderTime = Time.newInstance(Integer.valueOf(reminderMap.get('time').split(':')[0]),
	        											Integer.valueOf(reminderMap.get('time').split(':')[1]), 0, 0);
            taskObject.ReminderDateTime = DateTime.newInstance(Date.valueOf(reminderMap.get('date')), reminderTime);
            taskObject.WhatId = reminderMap.get('hitListId');
            taskObject.Subject = reminderMap.get('subject');
            taskObject.Description = reminderMap.get('notes');
            taskObject.Priority = 'Normal';
            taskObject.Status = 'Not Started';
            taskObject.OwnerId = Userinfo.getUserId();

            if (taskObject.ReminderDateTime < System.now()) {
                result = System.Label.INVALID_TIME;
                return result;
            }

            if (sendMail) {
                Database.DMLOptions dmlo = new Database.DMLOptions();
                dmlo.EmailHeader.triggerUserEmail = true;
                database.insert(taskObject, dmlo);
            } else {
                insert taskObject;
            }
            result = 'success' + taskObject.Id;
        } catch(Exception e) {
            Database.rollback(sp);
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to get email template for community invitation
     * author: Gaurav Saini (1 Mar, 2018)
     */
    @RemoteAction
    public static String createNote(String noteMapJson, Boolean isUr) {
        Savepoint sp = Database.setSavepoint();
        String result = '';

        try {
            Map<String, String> noteMap = (Map<String, String>)JSON.deserialize(noteMapJson, Map<String, String>.class);
            Reference_Note__c refNote = new Reference_Note__c();

            if (noteMap.containsKey('refNoteId') && noteMap.get('refNoteId') != '') {
                refNote.Id = noteMap.get('refNoteId');
            }
            refNote.Note_Date__c = Date.valueOf(noteMap.get('noteDate'));
            refNote.Note__c = noteMap.get('noteValue');

            if (noteMap.containsKey('refRequestId') && noteMap.get('refRequestId') != '') {
                refNote.Reference_Request__c = noteMap.get('refRequestId');
            }

            if (isUr) {
                refNote.Unspecified_Request__c = noteMap.get('relatedRecordId');
            } else {
                refNote.Account_Request__c = noteMap.get('relatedRecordId');
            }
            WithoutSharingHelperController.upsertNotes(new List<Reference_Note__c> { refNote });
            result = 'success';
        } catch(Exception e) {
            Database.rollback(sp);
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to get community users' contact Ids
     * author: Gaurav Saini (1 Mar, 2018)
     */
    @RemoteAction
    public static String createCommunityInvite(String emailMapJson, String refRequestId, String communityUserMapJson,
                                                String filterAttMapJson, Boolean isSendClicked) {
        Savepoint sp = Database.setSavepoint();
        String result = '';

        try {
            Map<String, String> emailMap = (Map<String, String>)JSON.deserialize(emailMapJson, Map<String, String>.class);
            Map<String, Set<String>> filterAttMap = (Map<String, Set<String>>)JSON.deserialize(filterAttMapJson, Map<String, Set<String>>.class);
            Map<String, CommunityUserWrapper> communityUserMap = (Map<String, CommunityUserWrapper>)JSON.deserialize(communityUserMapJson, Map<String, CommunityUserWrapper>.class);
            List<Community_Invite_Contact__c> newCICrecords = new List<Community_Invite_Contact__c>();
            List<Reference_Request_Account__c> updateRRA = new List<Reference_Request_Account__c>();
            List<Unspecified_Request__c> updateUR = new List<Unspecified_Request__c>();
            List<Hit_List__c> updateHitList = new List<Hit_List__c>();

            Community_Invite__c comInvite = new Community_Invite__c();
            comInvite.Referenceability_Type__c = emailMap.get('refTypeId') != '' ? emailMap.get('refTypeId') : null;
            comInvite.Community_Participate_Deadline__c = Date.valueOf(emailMap.get('deadline'));
            comInvite.Community_Participate_Details__c = emailMap.get('details');
            comInvite.Community_Participate_With__c = emailMap.get('withValue');
            comInvite.Org_Instance_URl__c = URl.getSalesforceBaseUrl().toExternalForm();
            comInvite.Account__c = emailMap.get('accountId');
            comInvite.Reference_Request__c = refRequestId;
            comInvite = WithoutSharingHelperController.insertCommunityInvite(comInvite);

            for (String conId : communityUserMap.keySet()) {
                newCICrecords.add(new Community_Invite_Contact__c(Community_Invite__c = comInvite.Id, Contact__c = conId));
            }

            if (newCICrecords.size() > 0) {
                WithoutSharingHelperController.upsertContactInvites(newCICrecords);
            }

            for (Reference_Request_Account__c rra : [SELECT Id, Community_Participate__c, Community_Invite__c
                                                        FROM Reference_Request_Account__c
                                                        WHERE Reference_Request__c = :refRequestId
                                                        AND Reference_Type_Needed__c = :emailMap.get('refTypeId')
                                                        AND Account_Request_Status__c != 'No Response'
                                                        AND Account_Request_Status__c != 'Unavailable'
                                                        AND Account_Request_Status__c != 'Completed'
                                                        AND Account_Request_Status__c != 'Give Up - Contact Unresponsive'
                                                        AND Account_Request_Status__c != 'Give Up - Contact Left Company'
                                                        AND Account_Request_Status__c != 'Give Up - Service Issues'
                                                        AND Account_Request_Status__c != 'Give Up - Legal Won\'t Approve']) {
                rra.Community_Participate__c = true;
                rra.Community_Invite__c = comInvite.Id;
                updateRRA.add(rra);
            }

            for (Unspecified_Request__c ur : [SELECT Id, Community_Participate__c, Community_Invite__c
                                                FROM Unspecified_Request__c
                                                WHERE Reference_Request__c = :refRequestId
                                                AND Reference_Type_Needed__c = :emailMap.get('refTypeId')
                                                AND Unspecified_Request_Status__c != 'No Longer Needed'
                                                AND Unspecified_Request_Status__c != 'Account Specified']) {
                ur.Community_Participate__c = true;
                ur.Community_Invite__c = comInvite.Id;
                updateUR.add(ur);
            }

            if (updateRRA.size() > 0) {
                WithoutSharingHelperController.upsertRRAList(updateRRA);
            }

            if (updateUR.size() > 0) {
                WithoutSharingHelperController.updateUnspecified(updateUR);
            }
            List<Community_Invite_Attribute__c> comInviteAttribute = new List<Community_Invite_Attribute__c>();
            
            for (String labelId : filterAttMap.keySet()) {
                
                for (String attId : filterAttMap.get(labelId)) {
                    comInviteAttribute.add(new Community_Invite_Attribute__c(Filter__c = labelId, Attribute__c = attId, 
                    						Community_Invite__c = comInvite.Id));
                }
            }
            insert comInviteAttribute;

            if (isSendClicked) {
                List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
                String body = '';

                for (String conId : communityUserMap.keySet()) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    //Email subject
                    mail.setSubject(emailMap.get('subject'));
                    
                    //Prepare body for email
                    body = emailMap.get('body');
                    body = body.replace('refedge__', '');
                    body = body.replace('{!Contact.FirstName},', (communityUserMap.get(conId).contactFName != ''
                                        ? communityUserMap.get(conId).contactFName + ',' : ''));
                    body = body.replace('{!Community_Invite__c.Referenceability_Type_f__c}', (emailMap.get('refTypeName') != '' ? emailMap.get('refTypeName') : 'n/a'));
                    body = body.replace('{!Community_Invite__c.Community_Participate_With__c}', comInvite.Community_Participate_With__c);
                    body = body.replace('{!Community_Invite__c.Community_Participate_Deadline__c}', String.valueOf(comInvite.Community_Participate_Deadline__c));
                    body = body.replace('{!Community_Invite__c.Community_Participate_Details__c}', comInvite.Community_Participate_Details__c);

                    if (body.contains('{!Community_Invite__c.Community_Yes_Im_In_Link__c}')) {
                        body = body.replace('{!Community_Invite__c.Community_Yes_Im_In_Link__c}', '<a href="' + UtilityController.getCommunityUrl() + '/apex/' 
                                            + UtilityController.appNamespace() + 'RefedgeCommunityHome?Id=' + comInvite.Id + '&response=yes">Yes, I\'m in!</a> ');
                    } else {
                        body += '\n\n<a href="' + UtilityController.getCommunityUrl() + '/apex/' + UtilityController.appNamespace() + 'RefedgeCommunityHome?Id=' 
                                            + comInvite.Id + '&response=yes">Yes, I\'m in!</a> ';
                    }
                    
                    if (body.contains('{!Community_Invite__c.Community_No_Thanks_Link__c}')) {
                        body = body.replace('{!Community_Invite__c.Community_No_Thanks_Link__c}', '<a href="' + UtilityController.getCommunityUrl() + '/apex/' 
                                            + UtilityController.appNamespace() + 'RefedgeCommunityHome?Id=' + comInvite.Id + '&response=no">No Thanks</a> ');
                    } else {
                        body += '\n\n<a href="' + UtilityController.getCommunityUrl() + '/apex/' + UtilityController.appNamespace() + 'RefedgeCommunityHome?Id=' 
                                            + comInvite.Id + '&response=no">No Thanks</a> ';
                    }
                    
                    if (body.contains('{!Community_Invite__c.Community_Participate_Link__c}')) {
                        body = body.replace('{!Community_Invite__c.Community_Participate_Link__c}', '<a href="' + UtilityController.getCommunityUrl() + '/apex/' 
                                            + UtilityController.appNamespace() + 'RefedgeCommunityHome">Go to the Customer Reference Community</a> ');
                    } else { 
                        body += '\n\n<a href="' + UtilityController.getCommunityUrl() + '/apex/' + UtilityController.appNamespace() 
                                                + 'RefedgeCommunityHome">Go to the Customer Reference Community</a> ';
                    }
                    body = body.replace('{', '');
                    body = body.replace('}', '');
                    mail.setHtmlBody(MailChatterController.setEmailTemplateBody(body));
                    
                    //Email Id's for selected contacts
                    String[] toAddresses = new String[] {
                        (communityUserMap.get(conId).contactEmail != '' ? communityUserMap.get(conId).contactEmail : communityUserMap.get(conId).userEmail)
                    };
                    mail.setToAddresses(toAddresses);
                    listmail.add(mail);
                }

                if (listmail.size() > 0) {
                    Messaging.sendEmail(listmail);
                }
            }
            result = 'success';
        } catch(Exception e) {
            Database.rollback(sp);
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to get email template for community invitation
     * author: Gaurav Saini (1 Mar, 2018)
     */
    @RemoteAction
    public static String getEmailTemplate() {
        String result = '';
        List<EmailTemplate> templateList = [SELECT Id, Subject, Body, HTMLValue FROM EmailTemplate
                                            WHERE DeveloperName = 'Community_Reference_Opportunity_Invitation'];
        
        if (templateList.size() > 0) {
            result = String.valueOf(templateList[0].Body).replaceAll('refedge__', '');
        }
        return result;
    }

    /**
     * method to delete community invite record
     * author: Gaurav Saini (1 Mar, 2018)
     */
    @RemoteAction
    public static String deleteCommunityInvite(String cicId) {
        String result = '';
        Savepoint sp = Database.setSavepoint();

        try {

            if (cicId != '') {
                Community_Invite_Contact__c commInvite = new Community_Invite_Contact__c(Id = cicId);
                delete commInvite;
                result = 'success';
            }
        } catch(Exception e) {
            Database.rollback(sp);
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to get community invite records for the reference request
     * author: Gaurav Saini (1 Mar, 2018)
     */
    @RemoteAction
    public static String getCommunityInviteList(String refRequestId) {
        List<CommunityInviteWrapper> communityInviteList = new List<CommunityInviteWrapper>();
        Set<Id> contactIds = new Set<Id>();
        //REF-1964
        List<Community_Invite_Contact__c> cicList = [SELECT Response__c, Referenceability_Type__c, Contact__c, Contact__r.Name, Challenge_Id__c,
                                                        Contact__r.AccountId, Contact__r.Phone, Contact__r.Email, Contact__r.Account.Name
                                                        FROM Community_Invite_Contact__c
                                                        WHERE Community_Invite__r.Reference_Request__c = :refRequestId
                                                        AND Challenge_Id__c = null
                                                        ORDER BY Response__c, Referenceability_Type__c, Contact__r.Account.Name, Contact__r.LastName];

        for (Community_Invite_Contact__c cic : cicList) {
            contactIds.add(cic.Contact__c);
        }
        Map<Id, Contact> contactMap = WithoutSharingHelperController.getContactsinContactSearch(contactIds);

        for (Community_Invite_Contact__c cic : cicList) {
            CommunityInviteWrapper tempCIC = new CommunityInviteWrapper(cic);
            Integer hitCount = 0;

            if (contactMap.get(cic.Contact__c).Reference_Basic_Informations__r != null
                    && contactMap.get(cic.Contact__c).Reference_Basic_Informations__r.size() > 0) {
                tempCIC.lastUsed = contactMap.get(cic.Contact__c).Reference_Basic_Informations__r[0].RUL_Last_Activity_Date__c != null
                                ? contactMap.get(cic.Contact__c).Reference_Basic_Informations__r[0].RUL_Last_Activity_Date__c.format() : '';
                tempCIC.lastNDays = contactMap.get(cic.Contact__c).Reference_Basic_Informations__r[0].Default_Period_Completed_Uses__c != null
                                ? String.valueOf(contactMap.get(cic.Contact__c).Reference_Basic_Informations__r[0].Default_Period_Completed_Uses__c) : '';
            }

            for (Hit_List__c hl : contactMap.get(cic.Contact__c).Hit_Lists__r) {
                
                if (!hl.Released__c) {
                    hitCount += 1;
                }
            }
            tempCIC.hitCount = String.valueOf(hitCount);
            tempCIC.assignCount = String.valueOf(contactMap.get(cic.Contact__c).Reference_Request_Account_Contacts__r.size());
            communityInviteList.add(tempCIC);
        }
        return JSON.serialize(communityInviteList);
    }

    /**
     * method to assign community invite record to the selected request item
     * author: Gaurav Saini (1 Mar, 2018)
     */
    @RemoteAction
    public static String assignCicToRequest(String communityInviteJson, String refRequestId, String requesterId,
                                                Boolean isUr, String requestMapJson, String projectType) {
        Savepoint sp = Database.setSavepoint();
        String result = '';
        String newRecordId = '';

        try {
            CommunityInviteWrapper communityInvite = (CommunityInviteWrapper)JSON.deserialize(communityInviteJson, CommunityInviteWrapper.class);
            Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestMapJson, Map<String, String>.class);
            Reference_Request_Account__c newRRA;
            List<Reference_Basic_Information__c> rbiAccList = [SELECT Account__c, Contact__c, Reference_Owner__c, Is_Referenceable__c,
                                                                Reference_Program_Candidate__c,  Referenceability_Status__c
                                                                FROM Reference_Basic_Information__c
                                                                WHERE (Contact__c = null AND Account__c != null AND Account__c = :communityInvite.accountId)
                                                                OR (Contact__c = :communityInvite.contactId)];
            Reference_Basic_Information__c con;
            Reference_Basic_Information__c acc;
            
            for (Reference_Basic_Information__c rbi : rbiAccList) {
                
                if (rbi.Contact__c == null) {
                    acc = rbi;
                }
                
                if (rbi.Contact__c != null && rbi.Contact__c == communityInvite.contactId) {
                    con = rbi;
                }
            }
            
            if (projectType == 'Candidate') {

                if (!con.Reference_Program_Candidate__c || !acc.Reference_Program_Candidate__c) {
                    result = System.Label.CANDIDATE_NOT_CHECKED_CONTACT_ACCOUNT;
                    return result;
                }
            } else {

                if (con.Reference_Program_Candidate__c) {
                    result = System.Label.CANDIDATE_NOT_CHECKED_CONTACT_ACCOUNT;
                    return result;
                }
                
                if (acc.Reference_Program_Candidate__c) {
                    result = System.Label.MEMBER_NOT_CHECKED_CONTACT_ACCOUNT;
                    return result;
                }
            }

            if (isUr) {
                newRRA = new Reference_Request_Account__c();
                newRRA.Account__c = communityInvite.accountId;
                newRRA.Account_Request_Status__c = ConstantsController.IN_PROGRESS;
                newRRA.Deadline__c = Date.valueOf(requestMap.get('deadline'));
                newRRA.Process__c = ConstantsController.MANAGED;
                newRRA.Reference_Request__c = refRequestId;
                newRRA.Request_Notes__c = requestMap.get('reqNotes');
                newRRA.Requester__c = requesterId;
                newRRA.Reference_Type_Needed__c = requestMap.get('refTypeId');
                newRRA.Reference_Request_Additional_Info__c = requestMap.get('addInfoId') != '' ? requestMap.get('addInfoId') : null;
                newRRA.Managed_Request__c = true;
                newRRA.Project_Owner__c = acc.Reference_Owner__c;
                WithoutSharingHelperController.upsertRRA(newRRA);
                newRecordId = newRRA.Id;
                Unspecified_Request__c oldUR = new Unspecified_Request__c(Id = requestMap.get('unspecRequestId'));
                oldUR.Specified_Account__c = newRRA.Id;
                oldUR.Unspecified_Request_Status__c = ConstantsController.ACCOUNT_SPECIFIED;
                ConstantsController.shouldUnspecifiedStatusChange = true;
                WithoutSharingHelperController.updateUnspecified(new List<Unspecified_Request__c> {oldUR});
            } else {
                newRRA = new Reference_Request_Account__c();
                newRRA.Account__c = communityInvite.accountId;
                newRRA.Account_Request_Status__c = requestMap.get('requestStatus');
                newRRA.Deadline__c = Date.valueOf(requestMap.get('deadline'));
                newRRA.Process__c = ConstantsController.MANAGED;
                newRRA.Reference_Request__c = refRequestId;
                newRRA.Request_Notes__c = requestMap.get('reqNotes');
                newRRA.Requester__c = requesterId;
                newRRA.Reference_Type_Needed__c = requestMap.get('refTypeId');
                newRRA.Reference_Request_Additional_Info__c = requestMap.get('addInfoId') != '' ? requestMap.get('addInfoId') : null;
                newRRA.Managed_Request__c = true;
                newRRA.Project_Owner__c = acc.Reference_Owner__c;
                WithoutSharingHelperController.upsertRRA(newRRA);
                newRecordId = newRRA.Id;
                Reference_Request_Account__c oldRRA = new Reference_Request_Account__c(Id = requestMap.get('accRequestId'));
                oldRRA.Account_Request_Status__c = ConstantsController.UNAVAILABLE;
                WithoutSharingHelperController.upsertRRA(oldRRA);
            }

            if (communityInvite.contactId != null && communityInvite.contactId != '') {
                Reference_Request_Account_Contact__c contactRequest = new Reference_Request_Account_Contact__c();
                contactRequest.Contact__c = communityInvite.contactId;
                contactRequest.Contact_Email__c = communityInvite.email;
                contactRequest.Contact_Phone__c = communityInvite.phone;
                contactRequest.Deadline__c = newRRA.Deadline__c;
                contactRequest.Project_Owner__c = newRRA.Project_Owner__c;
                contactRequest.Contact_Request_Status__c = newRRA.Account_Request_Status__c;
                contactRequest.Reference_Request_Account__c = newRRA.Id;
                contactRequest.Referenceability_Type__c = newRRA.Reference_Type_Needed__c;
                contactRequest.Request_notes__c = newRRA.Request_Notes__c;
                WithoutSharingHelperController.upsertRRAC(contactRequest);
            }
            result = 'success##' + newRecordId;
        } catch(Exception e) {
            Database.rollback(sp);
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to get hit list records
     * author: Gaurav Saini (5 Mar, 2018)
     */
    @RemoteAction
    public static String dispositionHitList(String hitListWrapperJson, Boolean isUr, String requestMapJson,
                                                String refRequestId, String requesterId) {
        Savepoint sp = Database.setSavepoint();
        String result = '';

        try {
            List<Hit_List__c> updatedHitList = new List<Hit_List__c>();
            Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestMapJson, Map<String, String>.class);
            HitListWrapper hlWrapper = (HitListWrapper)JSON.deserialize(hitListWrapperJson, HitListWrapper.class);

            if (hlWrapper.disposition == 'Released: Contact Declined') {
                updatedHitList.add(new Hit_List__c(Id = hlWrapper.hitListId, Disposition__c = hlWrapper.disposition, Released__c = true));
                Task taskObject = new Task();
                taskObject.Subject = 'declined reference activity';
                taskObject.WhatId = hlWrapper.accountId;
                taskObject.OwnerId = Userinfo.getUserId();
                taskObject.Priority = ConstantsController.NORMAL;
                taskObject.Status = ConstantsController.COMPLETED;
                WithoutSharingHelperController.insertTask(new List<Task> { taskObject });
                result = 'success';
            } else if (hlWrapper.disposition == 'Released: Contact Unresponsive' || hlWrapper.disposition == 'Released: No Longer Needed' || hlWrapper.disposition == 'Contacted') {
                updatedHitList.add(new Hit_List__c(Id = hlWrapper.hitListId, Disposition__c = hlWrapper.disposition, Released__c = true));
                result = 'success';
            } else if (hlWrapper.disposition == 'Agreed') {
                result = assignHitRecordToRequest(hitListWrapperJson, isUr, requestMapJson, true, refRequestId, requesterId);
            }

            if (updatedHitList.size() > 0) {
                WithoutSharingHelperController.updateHitList(updatedHitList);
            }
        } catch(Exception e) {
            Database.rollback(sp);
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to get hit list records
     * author: Gaurav Saini (5 Mar, 2018)
     */
    @RemoteAction
    public static String updateHitListNote(String hitListWrapperJson) {
        Savepoint sp = Database.setSavepoint();
        String result = '';
        
        try {
            List<Hit_List__c> updatedHitList = new List<Hit_List__c>();
            HitListWrapper hlWrapper = (HitListWrapper)JSON.deserialize(hitListWrapperJson, HitListWrapper.class);
            updatedHitList.add(new Hit_List__c(Id = hlWrapper.hitListId, Note__c = hlWrapper.notes));
            WithoutSharingHelperController.updateHitList(updatedHitList);
            result = 'success';
        } catch(Exception e) {
            Database.rollback(sp);
            result = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to get hit list records
     * author: Gaurav Saini (5 Mar, 2018)
     */
    @RemoteAction
    public static String assignHitRecordToRequest(String hitListWrapperJson, Boolean isUr, String requestMapJson,
                                                Boolean isDispositionSet, String refRequestId, String requesterId) {
        Savepoint sp = Database.setSavepoint();
        String result = '';
        String newRecordId = '';

        try {
            Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestMapJson, Map<String, String>.class);
            HitListWrapper hlWrapper = (HitListWrapper)JSON.deserialize(hitListWrapperJson, HitListWrapper.class);
            Reference_Request_Account__c newRRA;
            List<Reference_Basic_Information__c> rbiAccList = [SELECT Reference_Owner__c FROM Reference_Basic_Information__c
                                                                WHERE Account__c != null AND Account__c = :hlWrapper.accountId
                                                                AND Contact__c = null LIMIT 1];

            if (isUr) {
                newRRA = new Reference_Request_Account__c();
                newRRA.Account__c = hlWrapper.accountId;
                newRRA.Account_Request_Status__c = ConstantsController.IN_PROGRESS;
                newRRA.Deadline__c = Date.valueOf(requestMap.get('deadline'));
                newRRA.Reference_Request__c = refRequestId;
                newRRA.Request_Notes__c = requestMap.get('reqNotes');
                newRRA.Requester__c = requesterId;
                newRRA.Reference_Type_Needed__c = requestMap.get('refTypeId');
                newRRA.Reference_Request_Additional_Info__c = requestMap.get('addInfoId') != '' ? requestMap.get('addInfoId') : null;
                newRRA.Managed_Request__c = true;
                newRRA.Process__c = ConstantsController.MANAGED;
                newRRA.Project_Owner__c = rbiAccList[0].Reference_Owner__c;
                WithoutSharingHelperController.upsertRRA(newRRA);
                newRecordId = newRRA.Id;
                Unspecified_Request__c oldUr = new Unspecified_Request__c(Id = requestMap.get('unspecRequestId'));
                oldUr.Specified_Account__c = newRRA.Id;
                oldUr.Unspecified_Request_Status__c = ConstantsController.ACCOUNT_SPECIFIED;
                ConstantsController.shouldUnspecifiedStatusChange = true;
                WithoutSharingHelperController.updateUnspecified(new List<Unspecified_Request__c> {oldUr});
            } else {
                newRRA = new Reference_Request_Account__c();
                newRRA.Account__c = hlWrapper.accountId;
                newRRA.Account_Request_Status__c = requestMap.get('requestStatus');
                newRRA.Deadline__c = Date.valueOf(requestMap.get('deadline'));
                newRRA.Process__c = ConstantsController.MANAGED;
                newRRA.Reference_Request__c = refRequestId;
                newRRA.Request_Notes__c = requestMap.get('reqNotes');
                newRRA.Requester__c = requesterId;
                newRRA.Reference_Type_Needed__c = requestMap.get('refTypeId');
                newRRA.Reference_Request_Additional_Info__c = requestMap.get('addInfoId') != '' ? requestMap.get('addInfoId') : null;
                newRRA.Managed_Request__c = true;
                newRRA.Project_Owner__c = rbiAccList[0].Reference_Owner__c;
                WithoutSharingHelperController.upsertRRA(newRRA);
                newRecordId = newRRA.Id;
                Reference_Request_Account__c oldRRA = new Reference_Request_Account__c(Id = requestMap.get('accRequestId'));
                oldRRA.Account_Request_Status__c = ConstantsController.UNAVAILABLE;
                WithoutSharingHelperController.upsertRRA(oldRRA);
            }

            if (hlWrapper.contactId != null && hlWrapper.contactId != '') {
                Reference_Request_Account_Contact__c contactRequest = new Reference_Request_Account_Contact__c();
                contactRequest.Contact__c = hlWrapper.contactId;
                contactRequest.Contact_Email__c = hlWrapper.email;
                contactRequest.Contact_Phone__c = hlWrapper.phone;
                contactRequest.Deadline__c = newRRA.Deadline__c;
                contactRequest.Project_Owner__c = newRRA.Project_Owner__c;
                contactRequest.Contact_Request_Status__c = newRRA.Account_Request_Status__c;
                contactRequest.Reference_Request_Account__c = newRRA.Id;
                contactRequest.Referenceability_Type__c = newRRA.Reference_Type_Needed__c;
                contactRequest.Request_notes__c = newRRA.Request_Notes__c;
                WithoutSharingHelperController.upsertRRAC(contactRequest);
            }

            if (isDispositionSet) {
                Hit_List__c hlToUpdate = new Hit_List__c(Id = hlWrapper.hitListId);
                hlToUpdate.Released__c = true;
                hlToUpdate.Disposition__c = 'Agreed';
                update hlToUpdate;
                WithoutSharingHelperController.updateHitList(new List<Hit_List__c> {hlToUpdate});
            }
            result = 'success##' + newRecordId;
        } catch(Exception e) {
            Database.rollback(sp);
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to get hit list records
     * author: Gaurav Saini (5 Mar, 2018)
     */
    @RemoteAction
    public static String releaseAllHitLists(String hitListIdsJson) {
        Savepoint sp = Database.setSavepoint();
        String result = '';

        try {
            List<String> hitListIds = (List<String>)JSON.deserialize(hitListIdsJson, List<String>.class);
            List<Hit_List__c> updateHitList = new List<Hit_List__c>();

            for (String hlId : hitListIds) {
                updateHitList.add(new Hit_List__c(Id = hlId, Disposition__c = 'Released: No Longer Needed', Released__c = true));
            }

            if (updateHitList.size() > 0) {
                WithoutSharingHelperController.updateHitList(updateHitList);
            }
            result = 'success';
        } catch(Exception e) {
            Database.rollback(sp);
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to get hit list records
     * author: Gaurav Saini (5 Mar, 2018)
     */
    @RemoteAction
    public static String getHitListRecords(String requestId) {
        List<HitListWrapper> hitListWrapperList = new List<HitListWrapper>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Integer hitCount = 0;
        List<Hit_List__c> hitListRecords = WithoutSharingHelperController.getRequestHitListInRefProject(requestId);
        Map<String, Hit_List__c> hitListMap = new Map<String, Hit_List__c>();
        
        if (hitListRecords != null && hitListRecords.size() > 0) {

            for (Hit_List__c hl : hitListRecords) {
                
                if (hl.Contact__c == null) {
                    accountIds.add(hl.Account__c);
                } else {
                    contactIds.add(hl.Contact__c);
                }
                hitListMap.put(hl.Id, hl);
            }
            Map<Id, Account> accountsMap = new Map<Id, Account>(WithoutSharingHelperController.getAccountsForRefSearch(accountIds));
            Map<Id, Contact> contactMap = WithoutSharingHelperController.getContactsinContactSearch(contactIds);

            for (Id accId : accountsMap.keySet()) {
                Hit_List__c tempHitList;
                hitCount = 0;
                String lastUseDate = '';
                String lastNDays = '';

                if (accountsMap.get(accId).Reference_Basic_Informations__r != null
                        && accountsMap.get(accId).Reference_Basic_Informations__r.size() > 0) {
                    lastUseDate = accountsMap.get(accId).Reference_Basic_Informations__r[0].RUL_Last_Activity_Date__c != null
                                    ? accountsMap.get(accId).Reference_Basic_Informations__r[0].RUL_Last_Activity_Date__c.format() : '';
                    lastNDays = accountsMap.get(accId).Reference_Basic_Informations__r[0].Default_Period_Completed_Uses__c != null
                                    ? String.valueOf(accountsMap.get(accId).Reference_Basic_Informations__r[0].Default_Period_Completed_Uses__c) : '';
                }

                for (Hit_List__c hl : accountsMap.get(accId).Hit_Lists__r) {

                    if (!hl.Released__c) {
                        hitCount += 1;
                    }

                    if (hl.Reference_Request__c == requestId && hitListMap.containsKey(hl.Id)) {
                        tempHitList = hitListMap.get(hl.Id);
                    }
                }

                if (tempHitList != null) {
                    hitListWrapperList.add(new HitListWrapper(tempHitList, String.valueOf(hitCount), String.valueOf(accountsMap.get(accId).Reference_Request_Accounts__r.size()), lastUseDate, lastNDays));
                }
            }

            for (Id conId : contactMap.keySet()) {
                Hit_List__c tempHitList;
                hitCount = 0;
                String lastUseDate = '';
                String lastNDays = '';

                if (contactMap.get(conId).Reference_Basic_Informations__r != null
                        && contactMap.get(conId).Reference_Basic_Informations__r.size() > 0) {
                    lastUseDate = contactMap.get(conId).Reference_Basic_Informations__r[0].RUL_Last_Activity_Date__c != null
                                    ? contactMap.get(conId).Reference_Basic_Informations__r[0].RUL_Last_Activity_Date__c.format() : '';
                    lastNDays = contactMap.get(conId).Reference_Basic_Informations__r[0].Default_Period_Completed_Uses__c != null
                                    ? String.valueOf(contactMap.get(conId).Reference_Basic_Informations__r[0].Default_Period_Completed_Uses__c) : '';
                }

                for (Hit_List__c hl : contactMap.get(conId).Hit_Lists__r) {

                    if (!hl.Released__c) {
                        hitCount += 1;
                    }

                    if (hl.Reference_Request__c == requestId && hitListMap.containsKey(hl.Id)) {
                        tempHitList = hitListMap.get(hl.Id);
                    }
                }

                if (tempHitList != null) {
                    hitListWrapperList.add(new HitListWrapper(tempHitList, String.valueOf(hitCount), String.valueOf(contactMap.get(conId).Reference_Request_Account_Contacts__r.size()), lastUseDate, lastNDays));
                }
            }
        }
        return JSON.serialize(hitListWrapperList);
    }

    /**
     * method to get hit list records
     * author: Gaurav Saini (5 Mar, 2018)
     */
    @RemoteAction
    public static String getRelatedNotes(String requestIdsJson) {
        List<RefNoteWrapper> refNotes = new List<RefNoteWrapper>();
        List<String> requestIds = (List<String>)JSON.deserialize(requestIdsJson, List<String>.class);

        for (Reference_Note__c note : [SELECT Id, Note__c, CreatedBy.Name, Note_Date__c, LastModifiedDate,
                                        CreatedDate, LastModifiedById, LastModifiedBy.Name
                                        FROM Reference_Note__c
                                        WHERE (Account_Request__c IN :requestIds
                                            OR Unspecified_Request__c IN :requestIds
                                            OR Reference_Request__c IN :requestIds)]) {
            refNotes.add(new RefNoteWrapper(note));
        }
        return JSON.serialize(refNotes);
    }

    /**
     * method to get hit list records
     * author: Gaurav Saini (5 Mar, 2018)
     */
    @RemoteAction
    public static String deleteRefNote(String noteId) {
        Savepoint sp = Database.setSavepoint();
        String result = '';
        
        try {
            Reference_Note__c refNoteToDelete = new Reference_Note__c(Id = noteId);
            WithoutSharingHelperController.deleteRefNotesForUpdateRBI(new List<Reference_Note__c> { refNoteToDelete });
            result = 'success';
        } catch(Exception e) {
            Database.rollback(sp);
            result = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to get reference request record
     * author: Gaurav Saini (1 Mar, 2018)
     */
    @RemoteAction
    public static String getRefRequestObject(String requestId) {
        List<Reference_Request__c> refRequestList = WithoutSharingHelperController.getRefRequestForProjectDetail(requestId);
        List<RefRequestWrapper> refRequestWrapperList = new List<RefRequestWrapper>();
        
        if (refRequestList != null && refRequestList.size() > 0) {
            refRequestWrapperList.add(new RefRequestWrapper(refRequestList[0]));
        }
        return JSON.serialize(refRequestWrapperList);
    }

    /**
     * method to get reference type mappings
     * author: Gaurav Saini (16 Mar, 2018)
     */
    @RemoteAction
    public static String getAdditionalFieldsInfo(String refTypeId, String additionalInfoId) {
        Map<String, RefTypeMappingWrapper> refTypeMappings = new Map<String, RefTypeMappingWrapper>();
        Map<String, Schema.SObjectField> additionalFieldsMap = Schema.SObjectType.Reference_Request_Additional_Info__c.fields.getMap();
        List<Reference_Type_Mapping__c> refTypeMappingsToDelete = new List<Reference_Type_Mapping__c>();
        String additionalInfoQuery = 'SELECT Id';

        for (Reference_Type_Mapping__c rtm : [SELECT Label__c, Visible__c, Required__c, Referenceability_Type__c, Name
                                                FROM Reference_Type_Mapping__c
                                                WHERE Referenceability_Type__c = :refTypeId
                                                AND (Visible__c = true OR Required__c = true)
                                                AND Label__c = null]) {
            
            if (additionalFieldsMap.containsKey((rtm.Name).toLowerCase())) {
                additionalInfoQuery = additionalInfoQuery + ', ' + rtm.Name;
                Schema.DescribeFieldResult dfr = additionalFieldsMap.get((rtm.Name).toLowerCase()).getDescribe();
                refTypeMappings.put(rtm.Name, new RefTypeMappingWrapper(rtm, dfr));
            } else {
                refTypeMappingsToDelete.add(rtm);
            }
        }
        additionalInfoQuery = additionalInfoQuery + ' FROM Reference_Request_Additional_Info__c WHERE Id = :additionalInfoId';
        List<Reference_Request_Additional_Info__c> additionalInfoList = Database.query(additionalInfoQuery);

        if (additionalInfoList != null && additionalInfoList.size() > 0) {

            for (String apiName : refTypeMappings.keySet()) {
                RefTypeMappingWrapper tempRTM = refTypeMappings.get(apiName);

                if (tempRTM.fieldType == 'BOOLEAN') {
                    tempRTM.booleanValue = Boolean.valueOf(additionalInfoList[0].get(apiName));
                } else if (tempRTM.fieldType == 'PICKLIST') {
                    tempRTM.fieldValue = String.valueOf(additionalInfoList[0].get(apiName));
                } else if (tempRTM.fieldType == 'MULTIPICKLIST') {
                    tempRTM.fieldValue = String.valueOf(additionalInfoList[0].get(apiName));

                    for (PicklistOptionWrapper ple : tempRTM.availableOptions) {

                        if (tempRTM.fieldValue.contains(ple.name)) {
                            tempRTM.selectedOptions.add(ple);
                        }
                    }
                } else if (tempRTM.fieldType == 'DATE') {
                    tempRTM.fieldValue = (additionalInfoList[0].get(apiName) != null ? ((Date)additionalInfoList[0].get(apiName)).format() : '');
                } else if (tempRTM.fieldType == 'DATETIME') {
                    tempRTM.fieldValue = (additionalInfoList[0].get(apiName) != null ? ((Datetime)additionalInfoList[0].get(apiName)).format() : '');
                } else {
                    tempRTM.fieldValue = String.valueOf(additionalInfoList[0].get(apiName));
                }
                refTypeMappings.put(apiName, tempRTM);
            }
        }

        if (refTypeMappingsToDelete.size() > 0) {
            delete refTypeMappingsToDelete;
        }
        return JSON.serialize(refTypeMappings);
    }

    /**
     * method to get all ref types map
     * author: Gaurav Saini (1 Mar, 2018)
     */
    @RemoteAction
    public static String getStatusPicklist() {
        Map<String, List<String>> picklistValues = new Map<String, List<String>>();
        picklistValues.put('arStatus', new List<String>());
        picklistValues.put('urStatus', new List<String>());
        picklistValues.put('disposition', new List<String>());
        //REF-1964
        picklistValues.put('urChallengeStatus', new List<String>());
        Schema.DescribeFieldResult dfr3
            = Schema.sObjectType.Unspecified_Request__c.fields.getMap().get(UtilityController.appNamespace() + 'Influitive_Challenge_Status__c').getDescribe();
        
        for (Schema.PicklistEntry ple : dfr3.getPicklistValues()) {
            picklistValues.get('urChallengeStatus').add(ple.getValue());
        }
        Schema.DescribeFieldResult dfr
            = Schema.sObjectType.Reference_Request_Account__c.fields.getMap().get(UtilityController.appNamespace() + 'Account_Request_Status__c').getDescribe();
        Schema.DescribeFieldResult dfr1
            = Schema.sObjectType.Unspecified_Request__c.fields.getMap().get(UtilityController.appNamespace() + 'Unspecified_Request_Status__c').getDescribe();
        Schema.DescribeFieldResult dfr2
            = Schema.sObjectType.Hit_List__c.fields.getMap().get(UtilityController.appNamespace() + 'Disposition__c').getDescribe();

        for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
            picklistValues.get('arStatus').add(ple.getValue());
        }

        for (Schema.PicklistEntry ple : dfr1.getPicklistValues()) {
            picklistValues.get('urStatus').add(ple.getValue());
        }

        for (Schema.PicklistEntry ple : dfr2.getPicklistValues()) {
            picklistValues.get('disposition').add(ple.getValue());
        }
        return JSON.serialize(picklistValues);
    }

    /**
     * method to get all ref types map
     * author: Gaurav Saini (1 Mar, 2018)
     */
    @RemoteAction
    public static String getAlreadyPostedRefTypes(String refRequestId) {
        List<String> alreadyPostedRefTypeIds = new List<String>();

        for (Community_Invite__c commInvite : [SELECT Referenceability_Type__c, Reference_Request__c
                                                FROM Community_Invite__c
                                                WHERE Reference_Request__c = :refRequestId]) {
            alreadyPostedRefTypeIds.add(commInvite.Referenceability_Type__c);
        }
        return JSON.serialize(alreadyPostedRefTypeIds);
    }

    /**
     * method to get all ref types map
     * author: Gaurav Saini (1 Mar, 2018)
     */
    @RemoteAction
    public static String getRefTypesMap() {
        Map<String, RefTypeWrapper> refTypesMap = new Map<String, RefTypeWrapper>();
        String fixedFileName = 'communityPic.jpg';

        for (Referenceability_Type__c refType : [SELECT Id, Name, Sales_Point__c, Note__c, Max_accounts_per_request_type__c,
                                                    Min_lead_time_per_request_type__c, Project_type__c, Request_type__c,
                                                    Referenceability_no__c, Icon__c FROM Referenceability_Type__c
                                                    WHERE Visible__c = true
                                                    ORDER BY Name LIMIT :Limits.getLimitQueryRows()]) {
            refTypesMap.put(refType.Id, new RefTypeWrapper(refType));
        }

        for (Attachment att : [SELECT Id, ParentId FROM Attachment WHERE
                                ParentId IN :refTypesMap.keySet() AND Name = :fixedFileName]) {
            
            if (refTypesMap.containsKey(att.ParentId)) {
                RefTypeWrapper tempRefTypeWrap = refTypesMap.get(att.ParentId);
                tempRefTypeWrap.imageId = att.Id;
                refTypesMap.put(tempRefTypeWrap.refTypeId, tempRefTypeWrap);
            }
        }
        return JSON.serialize(refTypesMap);
    }

    /**
     * method to get account request record
     * author: Gaurav Saini (1 Mar, 2018)
     */
    @RemoteAction
    public static String saveRequestSubject(String requestSubject, String refRequestId) {
        Savepoint sp = Database.setSavepoint();
        String result = '';
        
        try {
            Reference_Request__c refRequest = new Reference_Request__c(Id = refRequestId);
            refRequest.Title__c = requestSubject;
            WithoutSharingHelperController.updateRefRequests(new List<Reference_Request__c> { refRequest });
            result = 'success';
        } catch(Exception e) {
            Database.rollback(sp);
            result = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to get account request record
     * author: Gaurav Saini (1 Mar, 2018)
     */
    @RemoteAction
    public static String getCommunityMatchingMembers(String refTypesClause, String filtersClause, String filterAttMapJson) {
        Set<String> matchingMemberContactIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        Map<String, CommunityUserWrapper> communityUserMap = new Map<String, CommunityUserWrapper>();
        Map<String, Boolean> labelLogicMap = new Map<String, Boolean>();
        Map<String, Set<String>> filterAttMap = (Map<String, Set<String>>)JSON.deserialize(filterAttMapJson, Map<String, Set<String>>.class);

        for (User u : [SELECT Name, Email, Id, AccountId, ContactId, Contact.FirstName, Contact.Name, Contact.Email
                        FROM User WHERE Profile.UserLicense.Name = 'Customer Community' AND IsActive = true]) {
            contactIds.add(u.ContactId);
            communityUserMap.put(u.ContactId, new CommunityUserWrapper(u));
        }
        String dynamicSOQL = 'SELECT Contact__c, Attribute_Ids__c FROM Reference_Basic_Information__c '
                            + 'WHERE Contact__c != null AND Account__c != null '
                            + filtersClause + ' ' + refTypesClause
                            + ' AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE + '\' '
                            + 'AND Referenceability_Status__c != null AND Contact__c IN :contactIds '
                            + 'ORDER BY Contact__r.Name';

        for (Reference_Basic_Information__c rbi : Database.query(dynamicSOQL)) {

            if (filterAttMap.size() > 0) {

                if (rbi.Attribute_Ids__c != null && rbi.Attribute_Ids__c != '') {
                    Set<String> setAttribute = new Set<String>();
                    setAttribute.addAll(rbi.Attribute_Ids__c.split(','));
                    Integer selectedlabelCount = 0;

                    for (String labelId : filterAttMap.keySet()) {
                        labelLogicMap.put(labelId, false);
                        selectedlabelCount++;

                        for (String attId : filterAttMap.get(labelId)) {

                            if (setAttribute.contains(attId)) {
                                labelLogicMap.put(labelId, true);
                                break;
                            }
                        }
                    }

                    if (selectedlabelCount != 0) {
                        Boolean checkResult = true;

                        for (Boolean flag: labelLogicMap.values()) {
                            checkResult = (checkResult && flag);
                        }

                        if (checkResult) {
                            matchingMemberContactIds.add(rbi.Contact__c);
                        }
                    }
                }
            } else {
                matchingMemberContactIds.add(rbi.Contact__c);
            }
        }
        Integer matchingMemberCount = matchingMemberContactIds.size();

        for (String conId : communityUserMap.keySet()) {

            if (!matchingMemberContactIds.contains(conId)) {
                communityUserMap.remove(conId);
            }
        }
        return matchingMemberCount + '@@@' + JSON.serialize(communityUserMap);
    }

    /**
     * method to get account request record
     * author: Gaurav Saini (1 Mar, 2018)
     */
    @RemoteAction
    public static String getFiltersInfo(String rrLabelIdsJson, String refTypeIdsJson, String advRoutingGroupsJson,
                                        Boolean isP2PRequest, Boolean isAdvRouting) {
        List<String> rrLabelIds = (List<String>)JSON.deserialize(rrLabelIdsJson, List<String>.class);
        List<String> refTypeIds = (List<String>)JSON.deserialize(refTypeIdsJson, List<String>.class);
        List<String> advRoutingGroups = (List<String>)JSON.deserialize(advRoutingGroupsJson, List<String>.class);
        Set<String> selectedAttributeIds = new Set<String>();
        Map<String, Boolean> requiredFiltersMap = new Map<String, Boolean>();
        Map<String, List<AttributeLabelWrapper>> filterAttributesMap = new Map<String, List<AttributeLabelWrapper>>();
        Map<String, String> filterNumbersMap = new Map<String, String>();
        String result = '';
        Set<String> labelIds = new Set<String>();
        for (Reference_Request_Label_Attribute__c tempObj : [SELECT Reference_Request_Label__c, Attribute__r.Name, Attribute__c,
                                                                Reference_Request_Label__r.Label__r.Name, Reference_Request_Label__r.Label__c
                                                                FROM Reference_Request_Label_Attribute__c
                                                                WHERE Reference_Request_Label__c IN :rrLabelIds]) {
            selectedAttributeIds.add(tempObj.Attribute__c);
            labelIds.add(tempObj.Reference_Request_Label__r.Label__c);
        }

        for (Reference_Type_Mapping__c rtm : [SELECT Id, Name, Referenceability_Type__c, Label__c, Visible__c, Required__c
                                                FROM Reference_Type_Mapping__c
                                                WHERE (Visible__c = true OR Required__c = true)
                                                AND Label__c != null
                                                AND Referenceability_Type__c IN :refTypeIds]) {
            
            if (!requiredFiltersMap.containsKey(rtm.Label__c)) {
                requiredFiltersMap.put(rtm.Label__c, false);
            }
            
            if (!requiredFiltersMap.get(rtm.Label__c) && rtm.Visible__c && rtm.Required__c) {
                requiredFiltersMap.put(rtm.Label__c, true);
            }
        }
        for (Id labelId : labelIds) {
            if (!requiredFiltersMap.containsKey(labelId)) {
                requiredFiltersMap.put(labelId, false);
            }
        }

        if (advRoutingGroups != null && advRoutingGroups.size() > 0 && isAdvRouting) {
            
            for (Label__c lbl : [SELECT Id, Name, Show_in_P2P__c, Required_in_P2P__c, Adv_Routing_Group__c
                                    FROM Label__c
                                    WHERE Show_in_P2P__c = true
                                    AND (Adv_Routing_Group__c IN :advRoutingGroups
                                        OR Adv_Routing_Group__c = null)]) {
        
                if (!requiredFiltersMap.containsKey(lbl.Id)) {
                    requiredFiltersMap.put(lbl.Id, false);
                }

                if (!requiredFiltersMap.get(lbl.Id) && lbl.Show_in_P2P__c && lbl.Required_in_P2P__c) {
                    requiredFiltersMap.put(lbl.Id, true);
                }
            }
        } else if ((advRoutingGroups == null || advRoutingGroups.size() == 0) && isAdvRouting && isP2PRequest) {
            
            for (Label__c lbl : [SELECT Id, Name, Show_in_P2P__c, Required_in_P2P__c, Adv_Routing_Group__c
                                    FROM Label__c
                                    WHERE Adv_Routing_Group__c = null
                                    AND Show_in_P2P__c = true]) {
        
                if (!requiredFiltersMap.containsKey(lbl.Id)) {
                    requiredFiltersMap.put(lbl.Id, false);
                }

                if (!requiredFiltersMap.get(lbl.Id) && lbl.Show_in_P2P__c && lbl.Required_in_P2P__c) {
                    requiredFiltersMap.put(lbl.Id, true);
                }
            }
        }

        for (Attributes_Labels__c al : [SELECT Name, Label__c, Id, Attribute__c, Label__r.Name, Attribute__r.Name, Label__r.Filter_no__c
                                        FROM Attributes_Labels__c
                                        WHERE Label__c IN :requiredFiltersMap.keyset()
                                        AND Attribute__c != null
                                        ORDER BY Attribute__r.Name
                                        LIMIT :limits.getLimitQueryRows()]) {
          
            if (selectedAttributeIds.contains(al.Attribute__c)) {

                if (!filterAttributesMap.containsKey(al.Label__c)) {
                    filterAttributesMap.put(al.Label__c, new List<AttributeLabelWrapper>());
                }
                filterAttributesMap.get(al.Label__c).add(new AttributeLabelWrapper(al, true));
                filterNumbersMap.put(al.Label__c, al.Label__r.Filter_no__c != null ? String.valueOf(al.Label__r.Filter_no__c) : '');
            } else {

                if (!filterAttributesMap.containsKey(al.Label__c)) {
                    filterAttributesMap.put(al.Label__c, new List<AttributeLabelWrapper>());
                }
                filterAttributesMap.get(al.Label__c).add(new AttributeLabelWrapper(al, false));
                filterNumbersMap.put(al.Label__c, al.Label__r.Filter_no__c != null ? String.valueOf(al.Label__r.Filter_no__c) : '');
            }
        }
        return (JSON.serialize(filterAttributesMap) + '@@@' + JSON.serialize(requiredFiltersMap) + '@@@' + JSON.serialize(filterNumbersMap));
    }

    /**
     * method to get account request record
     * author: Gaurav Saini (1 Mar, 2018)
     */
    @RemoteAction
    public static String saveFiltersInfo(String oldFilterAttMapJson, String newFilterAttMapJson, String refRequestId, String rrLabelMapJson) {
        Savepoint sp = Database.setSavepoint();
        String result = '';

        try {
            List<Reference_Request_Label__c> rrLabelsToInsert = new List<Reference_Request_Label__c>();
            List<Reference_Request_Label_Attribute__c> rrLabelAttsToInsert = new List<Reference_Request_Label_Attribute__c>();
            List<Reference_Request_Label_Attribute__c> rrLabelAttsToDelete = new List<Reference_Request_Label_Attribute__c>();
            Map<String, Set<String>> oldFilterAttributesMap = (Map<String, Set<String>>)JSON.deserialize(oldFilterAttMapJson, Map<String, Set<String>>.class);
            Map<String, Set<String>> newFilterAttributesMap = (Map<String, Set<String>>)JSON.deserialize(newFilterAttMapJson, Map<String, Set<String>>.class);
            Map<String, String> rrLabelMap = (Map<String, String>)JSON.deserialize(rrLabelMapJson, Map<String, String>.class);
            Map<String, List<Reference_Request_Label_Attribute__c>> rrLabelAttr = new Map<String, List<Reference_Request_Label_Attribute__c>>();

            if (rrLabelMap != null && rrLabelMap.size() > 0) {

                for (String newFilterId : newFilterAttributesMap.keySet()) {

                    if (!rrLabelMap.containsKey(newFilterId)) {
                        rrLabelsToInsert.add(new Reference_Request_Label__c(Reference_Request__c = refRequestId, Label__c = newFilterId));
                    }

                    if (!oldFilterAttributesMap.containsKey(newFilterId) && rrLabelMap.containsKey(newFilterId)) {
                        rrLabelsToInsert.add(new Reference_Request_Label__c(Reference_Request__c = refRequestId, Label__c = newFilterId));
                    }
                }

                if (rrLabelsToInsert.size() > 0) {
                    insert rrLabelsToInsert;
                }

                for (Reference_Request_Label__c rrLabel : rrLabelsToInsert) {
                    rrLabelMap.put(rrLabel.Label__c, rrLabel.Id);
                }

                for (String newFilterId : newFilterAttributesMap.keySet()) {

                    if (oldFilterAttributesMap.containsKey(newFilterId)) {

                        for (String newAttId : newFilterAttributesMap.get(newFilterId)) {
                            
                            if (!oldFilterAttributesMap.get(newFilterId).contains(newAttId)) {
                                rrLabelAttsToInsert.add(new Reference_Request_Label_Attribute__c(Attribute__c = newAttId, Reference_Request_Label__c = rrLabelMap.get(newFilterId)));
                            }
                        }
                    }
                }

                for (Reference_Request_Label__c rrLabel : rrLabelsToInsert) {

                    if (!oldFilterAttributesMap.containsKey(rrLabel.Label__c)) {

                        for (String newAttId : newFilterAttributesMap.get(rrLabel.Label__c)) {
                            rrLabelAttsToInsert.add(new Reference_Request_Label_Attribute__c(Attribute__c = newAttId, Reference_Request_Label__c = rrLabel.Id));
                        }
                    }
                }
            } else {

                for (String newFilterId : newFilterAttributesMap.keySet()) {
                    rrLabelsToInsert.add(new Reference_Request_Label__c(Reference_Request__c = refRequestId, Label__c = newFilterId));
                }

                if (rrLabelsToInsert.size() > 0) {
                    insert rrLabelsToInsert;
                }

                for (Reference_Request_Label__c rrLabel : rrLabelsToInsert) {

                    for (String newAttId : newFilterAttributesMap.get(rrLabel.Label__c)) {
                        rrLabelAttsToInsert.add(new Reference_Request_Label_Attribute__c(Attribute__c = newAttId, Reference_Request_Label__c = rrLabel.Id));
                    }
                }
            }

            if (rrLabelAttsToInsert.size() > 0) {
                upsert rrLabelAttsToInsert;
            }

            for (Reference_Request_Label_Attribute__c rrla : [SELECT Reference_Request_Label__c, Attribute__c, Reference_Request_Label__r.Label__c
                                                                    FROM Reference_Request_Label_Attribute__c
                                                                    WHERE Reference_Request_Label__c IN :rrLabelMap.values()]) {
                
                if (!rrLabelAttr.containsKey(rrla.Reference_Request_Label__r.Label__c)) {
                    rrLabelAttr.put(rrla.Reference_Request_Label__r.Label__c, new List<Reference_Request_Label_Attribute__c>());
                }
                rrLabelAttr.get(rrla.Reference_Request_Label__r.Label__c).add(rrla);
            }

            for (String filterId : newFilterAttributesMap.keySet()) {
                
                if (rrLabelAttr.containsKey(filterId)) {

                    for (Reference_Request_Label_Attribute__c rrla : rrLabelAttr.get(filterId)) {

                        if (!newFilterAttributesMap.get(filterId).contains(rrla.Attribute__c)) {
                            rrLabelAttsToDelete.add(rrla);
                        }
                    }
                }
            }

            if (rrLabelAttsToDelete.size() > 0) {
                delete rrLabelAttsToDelete;
            }
            result = 'success';
        } catch(Exception e) {
            Database.rollback(sp);
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to add new request item
     * author: Gaurav Saini (5 Mar, 2018)
     */
    @RemoteAction
    public static String addNewRequest(String requestMapJson) {
        Savepoint sp = Database.setSavepoint();
        String result = '';

        try {
            Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestMapJson, Map<String, String>.class);

            if (requestMap.containsKey('accountId') && requestMap.get('accountId') != null && requestMap.get('accountId') != '') {
                String soqlQuery = 'SELECT Reference_Owner__c, Account__c FROM Reference_Basic_Information__c ' 
                                    + ' WHERE Contact__c = null AND Account__c = \'' + requestMap.get('accountId') + '\' LIMIT 1';
                List<Reference_Basic_Information__c> rbi = WithoutSharingHelperController.getRBI(soqlQuery);
                Reference_Basic_Information__c rbiAccount = rbi[0];
                List<Community_Invite__c> commInviteList = [SELECT Referenceability_Type__c, Reference_Request__c
                                                                FROM Community_Invite__c
                                                                WHERE Referenceability_Type__c = :requestMap.get('refTypeId')
                                                                AND Reference_Request__c = :requestMap.get('refRequestId')];
                String comInviteId;
                
                if (commInviteList.size() > 0) {
                    comInviteId = commInviteList[0].Id;
                }
                Reference_Request_Account__c newRRA = new Reference_Request_Account__c(Account__c = requestMap.get('accountId'),
                                                        Community_Invite__c = comInviteId, Reference_Request__c = requestMap.get('refRequestId'),
                                                        Reference_Type_Needed__c = requestMap.get('refTypeId'), Deadline__c = Date.valueOf(requestMap.get('deadline')),
                                                        Community_Participate__c = true, Requester__c = requestMap.get('requesterId'),
                                                        Managed_Request__c = true, Process__c = ConstantsController.MANAGED,
                                                        Account_Request_Status__c = (rbiAccount.Reference_Owner__c == null
                                                            ? ConstantsController.NOT_STARTED : ConstantsController.IN_PROGRESS));
                WithoutSharingHelperController.upsertRRA(newRRA);
            } else if (!requestMap.containsKey('accountId') || requestMap.get('accountId') == null || requestMap.get('accountId') == '') {
                List<Community_Invite__c> commInviteList = [SELECT Referenceability_Type__c, Reference_Request__c
                                                                FROM Community_Invite__c
                                                                WHERE Referenceability_Type__c = :requestMap.get('refTypeId')
                                                                AND Reference_Request__c = :requestMap.get('refRequestId')];
                String comInviteId;
                
                if (commInviteList.size() > 0) {
                    comInviteId = commInviteList[0].Id;
                }
                Unspecified_Request__c newUR = new Unspecified_Request__c(Unspecified_Request_Status__c = ConstantsController.NOT_STARTED,
                                                    Reference_Request__c = requestMap.get('refRequestId'), Reference_Type_Needed__c = requestMap.get('refTypeId'),
                                                    Deadline__c = Date.valueOf(requestMap.get('deadline')), Requester__c = requestMap.get('requesterId'),
                                                    Community_Invite__c = comInviteId, Community_Participate__c = true);
                insert newUR;
            }
            result = 'success';
        } catch(Exception e) {
            Database.rollback(sp);
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to update additional request information
     * author: Gaurav Saini (29 Mar, 2018)
     */
    public static String updateAddInfo(Map<String, RefTypeMappingWrapper> additionalInfoMap, String addInfoId) {
        Savepoint sp = Database.setSavepoint();
        String result = '';

        try {
            Reference_Request_Additional_Info__c addInfoRecord = new Reference_Request_Additional_Info__c();

            if (addInfoId != '') {
                addInfoRecord.Id = addInfoId;
            }

            for (RefTypeMappingWrapper field : additionalInfoMap.values()) {

                if (field.fieldType == 'BOOLEAN') {
                    addInfoRecord.put(field.fieldApiName, field.booleanValue);
                } else if (field.fieldType == 'DATE' || field.fieldType == 'DATETIME') {
                    addInfoRecord.put(field.fieldApiName, field.fieldValue != '' && field.fieldValue != null ? Date.valueOf(field.fieldValue) : null);
                } else if (field.fieldType == 'DOUBLE') {
                    addInfoRecord.put(field.fieldApiName, field.fieldValue != '' && field.fieldValue != null ? Decimal.valueOf(field.fieldValue) : null);
                } else {
                    addInfoRecord.put(field.fieldApiName, field.fieldValue);
                }
            }
            upsert addInfoRecord;
            result = 'success--' + addInfoRecord.Id;
        } catch(Exception e) {
            Database.rollback(sp);
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to save cahnges to a request item
     * author: Gaurav Saini (20 Mar, 2018)
     */
    @RemoteAction
    public static String saveRequest(String requestMapJson, String oldRequestmapJson, String emailMapJson, Boolean isUr,
                                        String refRequestId, String refTypesMapJson, String projectType, String requesterId,
                                        Boolean isAddInfoUnchanged, String addInfoMapJson, String requestItemToUpdateIdsJson,
                                        Boolean activeRequestsPresent) {
        Savepoint sp = Database.setSavepoint();
        String result = '';
        String newRecordId = '';

        try {
            Custom_Settings__c cs = UtilityController.getCustomSettings();
            Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestMapJson, Map<String, String>.class);
            Map<String, String> oldRequestMap = (Map<String, String>)JSON.deserialize(oldRequestmapJson, Map<String, String>.class);
            Map<String, Object> emailMap = (Map<String, String>)JSON.deserialize(emailMapJson, Map<String, String>.class);
            Map<String, List<String>> requestItemToUpdateIds = (Map<String, List<String>>)JSON.deserialize(requestItemToUpdateIdsJson, Map<String, List<String>>.class);
            List<Task> listTask = new List<Task>();
            List<Reference_Note__c> refNoteList = new List<Reference_Note__c>();
            Map<String, Reference_Basic_Information__c> accountRBImap = new Map<String, Reference_Basic_Information__c>();
            Map<String, Community_Invite__c> communityInviteMap = new Map<String, Community_Invite__c>();
            List<Unspecified_Request__c> urToUpdate = new List<Unspecified_Request__c>();
            List<Reference_Request_Account__c> rraToUpdate = new List<Reference_Request_Account__c>();
            Map<String, String> refTypeUserMapForRewards = new Map<String, String>();
            Map<String, RefTypeWrapper> refTypesMap = (Map<String, RefTypeWrapper>)JSON.deserialize(refTypesMapJson, Map<String, RefTypeWrapper>.class);
            Map<String, RefTypeMappingWrapper> additionalInfoMap = (Map<String, RefTypeMappingWrapper>)JSON.deserialize(addInfoMapJson, Map<String, RefTypeMappingWrapper>.class);

            if (!activeRequestsPresent) {
                Reference_Request__c tempRR = new Reference_Request__c(Id = refRequestId);
                tempRR.Reference_Request_Status__c = 'Completed';
                WithoutSharingHelperController.updateRefRequests(new List<Reference_Request__c> { tempRR });
            }

            for (Community_Invite__c commInvite : [SELECT Referenceability_Type__c, Reference_Request__c
                                                    FROM Community_Invite__c
                                                    WHERE Reference_Request__c = :refRequestId]) {
                communityInviteMap.put(commInvite.Referenceability_Type__c, commInvite);
            }

            if (oldRequestMap.containsKey('accountId') && oldRequestMap.get('accountId') != null && oldRequestMap.get('accountId') != '') {

                for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getAccountsRBI(new List<String> {oldRequestMap.get('accountId')})) {
                    accountRBImap.put(rbi.Account__r.Id, rbi);
                }
            }

            if (isUr) {

                if (requestMap.containsKey('accountId') && requestMap.get('accountId') == oldRequestMap.get('accountId')) {
                    Unspecified_Request__c tempUR = new Unspecified_Request__c(Id = requestMap.get('unspecRequestId'));

                    if (requestMap.containsKey('unspecRequestId') && requestMap.get('unspecRequestId') != null
                            && requestMap.get('unspecRequestId') != '' && requestMap.get('refTypeId') != oldRequestMap.get('refTypeId')) {
                        
                        if (communityInviteMap.containsKey(requestMap.get('refTypeId'))) {
                            tempUR.Community_Participate__c = true;
                            tempUR.Community_Invite__c = communityInviteMap.get(requestMap.get('refTypeId')).Id;
                        }
                    }
                    tempUR.Unspecified_Request_Status__c = requestMap.get('requestStatus');
                    tempUR.Reference_Type_Needed__c = requestMap.get('refTypeId');
                    tempUR.Deadline__c = Date.valueOf(requestMap.get('deadline'));
                    tempUR.Notes__c = emailMap.containsKey('notes') && emailMap.get('notes') != null ? String.valueOf(emailMap.get('notes')) : '';
                    tempUR.Project_Owner__c = requestMap.get('ownerId') != '' ? requestMap.get('ownerId') : null;

                    if (!isAddInfoUnchanged) {
                        String updateAddInfoResult = updateAddInfo(additionalInfoMap, requestMap.get('addInfoId'));

                        if (!updateAddInfoResult.startsWith('success')) {
                            return updateAddInfoResult;
                        } else if (updateAddInfoResult.startsWith('success') && requestMap.get('addInfoId') == '') {
                            tempUR.Reference_Request_Additional_Info__c = updateAddInfoResult.substringAfter('--');

                            for (String arId : requestItemToUpdateIds.get('arIds')) {
                                Reference_Request_Account__c tempRRA = new Reference_Request_Account__c(Id = arId);
                                tempRRA.Reference_Request_Additional_Info__c = updateAddInfoResult.substringAfter('--');
                                rraToUpdate.add(tempRRA);
                            }

                            for (String urId : requestItemToUpdateIds.get('urIds')) {
                                Unspecified_Request__c tempUR1 = new Unspecified_Request__c(Id = urId);
                                tempUR1.Reference_Request_Additional_Info__c = updateAddInfoResult.substringAfter('--');
                                urToUpdate.add(tempUR1);
                            }
                        }
                    }
                    urToUpdate.add(tempUR);
                } else if (requestMap.containsKey('accountId') && requestMap.get('accountId') != oldRequestMap.get('accountId')) {
                    String accId = requestMap.get('accountId');
                    List<Reference_Basic_Information__c> rbiAccList
                        = [SELECT Reference_Owner__c FROM Reference_Basic_Information__c
                            WHERE Account__c != null AND Account__c = :accId AND Contact__c = null LIMIT 1];
                    Reference_Request_Account__c newRRA = new Reference_Request_Account__c();
                    newRRA.Account__c = requestMap.get('accountId');
                    newRRA.Account_Request_Status__c = ConstantsController.IN_PROGRESS;
                    newRRA.Deadline__c = Date.valueOf(requestMap.get('deadline'));
                    newRRA.Process__c = ConstantsController.MANAGED;
                    newRRA.Reference_Request__c = refRequestId;
                    newRRA.Request_Notes__c = requestMap.get('reqNotes');
                    newRRA.Requester__c = requesterId;
                    newRRA.Reference_Type_Needed__c = requestMap.get('refTypeId');
                    newRRA.Reference_Request_Additional_Info__c = requestMap.get('addInfoId') != '' ? requestMap.get('addInfoId') : null;
                    newRRA.Managed_Request__c = true;
                    newRRA.Project_Owner__c = rbiAccList[0].Reference_Owner__c;
                    
                    if (!isAddInfoUnchanged) {
                        String updateAddInfoResult = updateAddInfo(additionalInfoMap, requestMap.get('addInfoId'));

                        if (!updateAddInfoResult.startsWith('success')) {
                            return updateAddInfoResult;
                        } else if (updateAddInfoResult.startsWith('success') && requestMap.get('addInfoId') == '') {
                            newRRA.Reference_Request_Additional_Info__c = updateAddInfoResult.substringAfter('--');
                            
                            for (String arId : requestItemToUpdateIds.get('arIds')) {
                                Reference_Request_Account__c tempRRA = new Reference_Request_Account__c(Id = arId);
                                tempRRA.Reference_Request_Additional_Info__c = updateAddInfoResult.substringAfter('--');
                                rraToUpdate.add(tempRRA);
                            }

                            for (String urId : requestItemToUpdateIds.get('urIds')) {
                                Unspecified_Request__c tempUR = new Unspecified_Request__c(Id = urId);
                                tempUR.Reference_Request_Additional_Info__c = updateAddInfoResult.substringAfter('--');
                                urToUpdate.add(tempUR);
                            }
                        }
                    }
                    WithoutSharingHelperController.upsertRRA(newRRA);
                    newRecordId = newRRA.Id;
                    Unspecified_Request__c oldUR = new Unspecified_Request__c(Id = requestMap.get('unspecRequestId'));
                    oldUR.Specified_Account__c = newRRA.Id;
                    oldUR.Reference_Request_Additional_Info__c = newRRA.Reference_Request_Additional_Info__c;
                    oldUR.Unspecified_Request_Status__c = ConstantsController.ACCOUNT_SPECIFIED;
                    ConstantsController.shouldUnspecifiedStatusChange = true;
                    WithoutSharingHelperController.updateUnspecified(new List<Unspecified_Request__c> {oldUR});
                }
            } else {

                if (requestMap.containsKey('accountId') && requestMap.get('accountId') == oldRequestMap.get('accountId')) {

                    if (requestMap.containsKey('accRequestId') && requestMap.get('accRequestId') != null
                            && requestMap.get('accRequestId') != '') {
                        Reference_Request_Account__c tempRRA = new Reference_Request_Account__c(Id = requestMap.get('accRequestId'));
                        tempRRA.Account_Request_Status__c = requestMap.get('requestStatus');
                        tempRRA.Deadline__c = Date.valueOf(requestMap.get('deadline'));
                        tempRRA.Reference_Type_Needed__c = requestMap.get('refTypeId');
                        tempRRA.Process__c = requestMap.get('process');
                        
                        if (emailMap.containsKey('notes') && emailMap.get('notes') != null) {
                            tempRRA.Approve_Deny_Notes__c = String.valueOf(emailMap.get('notes'));
                        }
                        tempRRA.Project_Owner__c = requestMap.get('ownerId') != '' ? requestMap.get('ownerId') : null;

                        if (requestMap.get('process') != oldRequestMap.get('process') && requestMap.get('process') == ConstantsController.REP2REP) {
                            tempRRA.Managed_Request__c = false;

                            if (accountRBImap.containsKey(requestMap.get('accountId'))) {
                                listTask.add(MailChatterController.prepareTask((accountRBImap.get(requestMap.get('accountId')).Reference_Owner__c == null
                                                    ? accountRBImap.get(requestMap.get('accountId')).Account__r.OwnerId
                                                    : accountRBImap.get(requestMap.get('accountId')).Reference_Owner__c),
                                                requestMap.get('accountId'), Date.valueOf(requestMap.get('deadline')),
                                                REFERENCE_REQUEST_TASK_SUBJECT, SPECIFIED_REQUEST_MESSAGE
                                                    + MailChatterController.prepareChatterEmailMessage(Date.valueOf(requestMap.get('deadline')),
                                                        requestMap.get('accountName'), requestMap.get('refTypeName'),
                                                        UtilityController.checkValueOfString(emailMap.containsKey('notes') && emailMap.get('notes') != null ? String.valueOf(emailMap.get('notes')) : ''))
                                                    + APPROVE_DECLINE_TITLE + ': ' + (APPROVE_DECLINE_LINK_URL + requestMap.get('accRequestId')), ''));
                            }
                        } else if (requestMap.get('requestStatus') != oldRequestMap.get('requestStatus')
                                || requestMap.get('deadline') != oldRequestMap.get('deadline')
                                || requestMap.get('process') != oldRequestMap.get('process')
                                || requestMap.get('refTypeId') != oldRequestMap.get('refTypeId')
                                || requestMap.get('ownerId') != oldRequestMap.get('ownerId')
                                || (emailMap.get('notes') != oldRequestMap.get('emailNotes')
                                    && emailMap.get('notes') != null && String.valueOf(emailMap.get('notes')) != ''
                                    && oldRequestMap.get('emailNotes') != null && oldRequestMap.get('emailNotes') != '')) {
                            tempRRA.Process__c = ConstantsController.MANAGED;
                            tempRRA.Managed_Request__c = true;
                        }

                        if (requestMap.get('process') != oldRequestMap.get('process') && requestMap.get('process') == ConstantsController.MANAGED
                                && requestMap.get('ownerId') == oldRequestMap.get('ownerId')) {
                            tempRRA.Project_Owner__c = UserInfo.getUserId();
                        } else if (requestMap.get('process') != oldRequestMap.get('process') && requestMap.get('process') == ConstantsController.MANAGED
                                && requestMap.get('ownerId') != oldRequestMap.get('ownerId')) {
                            tempRRA.Project_Owner__c = requestMap.get('ownerId');
                        } else if (requestMap.get('process') != oldRequestMap.get('process') && requestMap.get('process') == ConstantsController.REP2REP) {
                            tempRRA.Project_Owner__c = accountRBImap.get(requestMap.get('accountId')).Reference_Owner__c == null
                                            ? accountRBImap.get(requestMap.get('accountId')).Account__r.OwnerId
                                                        : accountRBImap.get(requestMap.get('accountId')).Reference_Owner__c;
                        }

                        if (requestMap.get('refTypeId') != oldRequestMap.get('refTypeId')
                                && communityInviteMap.containsKey(requestMap.get('refTypeId'))) {
                            tempRRA.Community_Participate__c = true;
                            tempRRA.Community_Invite__c = communityInviteMap.get(requestMap.get('refTypeId')).Id;
                        }

                        if (requestMap.get('requestStatus') == ConstantsController.COMPLETED) {
                            refTypeUserMapForRewards.put(requestMap.get('refTypeId'), requestMap.get('ownerId') != null && requestMap.get('ownerId') != ''
                                                                                        ? requestMap.get('ownerId')
                                                                                        : (requestMap.get('refOwnerId') != null && requestMap.get('refOwnerId') != ''
                                                                                            ? requestMap.get('refOwnerId') : accountRBImap.get(requestMap.get('accountId')).Account__r.OwnerId));
                        }

                        if (!isAddInfoUnchanged) {
                            String updateAddInfoResult = updateAddInfo(additionalInfoMap, requestMap.get('addInfoId'));

                            if (!updateAddInfoResult.startsWith('success')) {
                                return updateAddInfoResult;
                            } else if (updateAddInfoResult.startsWith('success') && requestMap.get('addInfoId') == '') {
                                tempRRA.Reference_Request_Additional_Info__c = updateAddInfoResult.substringAfter('--');
                                
                                for (String arId : requestItemToUpdateIds.get('arIds')) {
                                    Reference_Request_Account__c tempRRA1 = new Reference_Request_Account__c(Id = arId);
                                    tempRRA1.Reference_Request_Additional_Info__c = updateAddInfoResult.substringAfter('--');
                                    rraToUpdate.add(tempRRA1);
                                }

                                for (String urId : requestItemToUpdateIds.get('urIds')) {
                                    Unspecified_Request__c tempUR = new Unspecified_Request__c(Id = urId);
                                    tempUR.Reference_Request_Additional_Info__c = updateAddInfoResult.substringAfter('--');
                                    urToUpdate.add(tempUR);
                                }
                            }
                        }
                        rraToUpdate.add(tempRRA);
                    }
                } else if (requestMap.containsKey('accountId') && requestMap.get('accountId') != oldRequestMap.get('accountId')) {
                    String accId = requestMap.get('accountId');
                    List<Reference_Basic_Information__c> rbiAccList
                        = [SELECT Reference_Owner__c FROM Reference_Basic_Information__c
                            WHERE Account__c != null AND Account__c = :accId AND Contact__c = null LIMIT 1];
                    Reference_Request_Account__c newRRA = new Reference_Request_Account__c();
                    newRRA.Account__c = requestMap.get('accountId');
                    newRRA.Account_Request_Status__c = requestMap.get('requestStatus');
                    newRRA.Deadline__c = Date.valueOf(requestMap.get('deadline'));
                    newRRA.Process__c = ConstantsController.MANAGED;
                    newRRA.Reference_Request__c = refRequestId;
                    newRRA.Request_Notes__c = requestMap.get('reqNotes');
                    newRRA.Requester__c = requesterId;
                    newRRA.Reference_Type_Needed__c = requestMap.get('refTypeId');
                    newRRA.Reference_Request_Additional_Info__c = requestMap.get('addInfoId') != '' ? requestMap.get('addInfoId') : null;
                    newRRA.Managed_Request__c = true;
                    newRRA.Project_Owner__c = rbiAccList[0].Reference_Owner__c;
                    
                    if (!isAddInfoUnchanged) {
                        String updateAddInfoResult = updateAddInfo(additionalInfoMap, requestMap.get('addInfoId'));

                        if (!updateAddInfoResult.startsWith('success')) {
                            return updateAddInfoResult;
                        } else if (updateAddInfoResult.startsWith('success') && requestMap.get('addInfoId') == '') {
                            newRRA.Reference_Request_Additional_Info__c = updateAddInfoResult.substringAfter('--');
                            
                            for (String arId : requestItemToUpdateIds.get('arIds')) {
                                Reference_Request_Account__c tempRRA = new Reference_Request_Account__c(Id = arId);
                                tempRRA.Reference_Request_Additional_Info__c = updateAddInfoResult.substringAfter('--');
                                rraToUpdate.add(tempRRA);
                            }

                            for (String urId : requestItemToUpdateIds.get('urIds')) {
                                Unspecified_Request__c tempUR = new Unspecified_Request__c(Id = urId);
                                tempUR.Reference_Request_Additional_Info__c = updateAddInfoResult.substringAfter('--');
                                urToUpdate.add(tempUR);
                            }
                        }
                    }
                    WithoutSharingHelperController.upsertRRA(newRRA);
                    newRecordId = newRRA.Id;
                    Reference_Request_Account__c oldRRA = new Reference_Request_Account__c(Id = requestMap.get('accRequestId'));
                    oldRRA.Reference_Request_Additional_Info__c = newRRA.Reference_Request_Additional_Info__c;
                    oldRRA.Account_Request_Status__c = ConstantsController.UNAVAILABLE;
                    WithoutSharingHelperController.upsertRRA(oldRRA);
                }
            }

            if (requestMap.containsKey('contactId') && requestMap.get('contactId') != oldRequestMap.get('contactId')) {
                Contact con = WithoutSharingHelperController.activateContactRecords(new Set<String> { requestMap.get('contactId') })[0];
                List<Account> accList = WithoutSharingHelperController.getAccountRecords(new Set<String> { requestMap.get('accountId') });

                if (projectType == 'Candidate') {

                    for (Account acc : accList) {
                        
                        if (acc.Reference_Basic_Informations__r == null || acc.Reference_Basic_Informations__r.size() == 0
                                || (acc.Reference_Basic_Informations__r.size() > 0 && !acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)) {
                            result = System.Label.CANDIDATE_NOT_CHECKED_CONTACT_ACCOUNT;
                            return result;
                        }
                    }
                } else if (projectType == 'Member') {

                    for (Account acc : accList) {

                        if (acc.Reference_Basic_Informations__r == null || acc.Reference_Basic_Informations__r.size() == 0
                                || (acc.Reference_Basic_Informations__r.size() > 0 && acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)) {
                            result = System.Label.MEMBER_NOT_CHECKED_CONTACT_ACCOUNT;
                            return result;
                        }
                    }
                }
                Reference_Request_Account_Contact__c newContactRequest
                    = new Reference_Request_Account_Contact__c(Reference_Request_Account__c = requestMap.containsKey('accRequestId') && newRecordId == '' ? requestMap.get('accRequestId') : newRecordId,
                        Contact__c = requestMap.get('contactId'), Contact_Request_Status__c = ConstantsController.IN_PROGRESS,
                        Referenceability_Type__c = requestMap.get('refTypeId'), Deadline__c = Date.valueOf(requestMap.get('deadline')),
                        Contact_Title__c = con.Title, Contact_Phone__c = con.Phone, Contact_Email__c = con.Email);
                WithoutSharingHelperController.upsertRRAC(newContactRequest);
                // TODO : update old request
            }

            if (emailMap.containsKey('writeToNote') && Boolean.valueOf(emailMap.get('writeToNote'))
                    && emailMap.get('notes') != null && String.valueOf(emailMap.get('notes')) != '') {

                if (requestMap.containsKey('unspecRequestId') && requestMap.get('unspecRequestId') != null && 
                    requestMap.get('unspecRequestId') != '') {
					refNoteList.add(new Reference_Note__c(Unspecified_Request__c = requestMap.get('unspecRequestId'),Note_Date__c = Date.today(), 
                                                          Note__c = String.valueOf(emailMap.get('notes')),Reference_Request__c = refRequestId));

                } else if (requestMap.containsKey('accRequestId') && requestMap.get('accRequestId') != null && 
                           requestMap.get('accRequestId') != '') {
					refNoteList.add(new Reference_Note__c(Account_Request__c = requestMap.get('accRequestId'),Note_Date__c = Date.today(), 
                                                          Note__c = String.valueOf(emailMap.get('notes')), Reference_Request__c = refRequestId));
                }
            }

            if (listTask.size() > 0) {
                listTask = WithoutSharingHelperController.insertTask(listTask);
            }

            for (Reference_Request_Account__c rra : rraToUpdate) {

                for (Task lstTask : listTask) {
                    
                    if (rra.Account__c == lstTask.WhatId) {
                        rra.Task_ID__c = lstTask.Id;
                    }
                }
            }

            if (urToUpdate.size() > 0) {
                WithoutSharingHelperController.updateUnspecified(urToUpdate);
            }

            if (rraToUpdate.size() > 0) {
                rraToUpdate = WithoutSharingHelperController.updateRRA(rraToUpdate);
            }

            if (refNoteList.size() > 0) {
                refNoteList = WithoutSharingHelperController.upsertNotes(refNoteList);
            }
            result = 'success##' + newRecordId;

            if (refTypeUserMapForRewards.size() > 0 && !RefEdgeEditionFeatures.isBasic && cs.Auto_Assign_Sales_Rewards__c
                    && cs.Enable_Sales_Rewards_Notification__c) {
                List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
                Set<Id> ownerIds = new Set<Id>();

                for (String refTypeId : refTypeUserMapForRewards.keySet()) {

                    if (refTypesMap != null && refTypesMap.containsKey(refTypeId)) {
                        rewardsToBeInsert.add(new Reward__c(Amount__c = refTypesMap.get(refTypeId).salesPoints,
                                                Referenceability_Type__c = refTypeId, Transaction__c = ConstantsController.ISSUE,
                                                RewardDate__c = Date.Today(), User__c = refTypeUserMapForRewards.get(refTypeId)));
                        ownerIds.add(refTypeUserMapForRewards.get(refTypeId));
                    }
                }

                if (rewardsToBeInsert.size() > 0) {
                    UtilityController.isUserProfileExist(ownerIds);
                    WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
                }
            }
        } catch(Exception e) {
            Database.rollback(sp);
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    public class HitListWrapper {
        public String hitListId { get; set; }
        public String accountId { get; set; }
        public String accountName { get; set; }
        public String contactId { get; set; }
        public String contactName { get; set; }
        public String disposition { get; set; }
        public String phone { get; set; }
        public String email { get; set; }
        public String accRequestId { get; set; }
        public String unspecRequestId { get; set; }
        public String lastUsed { get; set; }
        public String lastNDays { get; set; }
        public String hitCount { get; set; }
        public String assignCount { get; set; }
        public String notes { get; set; }
        public Boolean showPopover { get; set; }

        public HitListWrapper(Hit_List__c hl, String hitCount, String assignCount, String lastUseDate, String lastNDays) {
            this.hitListId = hl.Id;
            this.accountId = hl.Account__c != null ? String.valueOf(hl.Account__c) : '';
            this.accountName = hl.Account__c != null ? hl.Account__r.Name : '';
            this.contactId = hl.Contact__c != null ? String.valueOf(hl.Contact__c) : '';
            this.contactName = hl.Contact__c != null ? hl.Contact__r.Name : '';
            this.disposition = hl.Disposition__c != null ? hl.Disposition__c : '';
            this.phone = hl.Email__c != null ? hl.Phone__c : '';
            this.email = hl.Email__c != null ? hl.Email__c : '';
            this.notes = hl.Note__c != null ? hl.Note__c : '';
            this.accRequestId = hl.Account_Request__c != null ? String.valueOf(hl.Account_Request__c) : '';
            this.unspecRequestId = hl.Unspecified_Request__c != null ? String.valueOf(hl.Unspecified_Request__c) : '';
            this.lastUsed = lastUseDate;
            this.lastNDays = lastNDays;
            this.hitCount = hitCount;
            this.assignCount = assignCount;
            this.showPopover = false;
        }
    }

    public class AttributeLabelWrapper {
        public String attId { get; set; }
        public String attName { get; set; }
        public String filterId { get; set; }
        public String filterName { get; set; }
        public Boolean isSelected { get; set; }

        public AttributeLabelWrapper(Attributes_Labels__c al, Boolean isSelected) {
            this.attId = al.Attribute__c;
            this.attName = al.Attribute__r.Name;
            this.filterId = al.Label__c;
            this.filterName = al.Label__r.Name;
            this.isSelected = isSelected;
        }
    }

    public class RefTypeMappingWrapper {
        public String fieldApiName { get; set; }
        public String fieldLabel { get; set; }
        public Boolean visible { get; set; }
        public Boolean required { get; set; }
        public String fieldType { get; set; }
        public String inlineHelpText { get; set; }
        public List<PicklistOptionWrapper> availableOptions { get; set; }
        public List<PicklistOptionWrapper> selectedOptions { get; set; }
        public String fieldValue { get; set; }
        public Boolean booleanValue { get; set; }

        public RefTypeMappingWrapper(Reference_Type_Mapping__c rtm, Schema.DescribeFieldResult dfr) {
            this.fieldApiName = rtm.Name;
            this.fieldLabel = String.valueOf(dfr.getLabel());
            this.visible = rtm.Visible__c;
            this.required = rtm.Required__c;
            this.fieldType = String.valueOf(dfr.getType());
            this.availableOptions = new List<PicklistOptionWrapper>();
            this.selectedOptions = new List<PicklistOptionWrapper>();
            this.fieldValue = '';
            this.booleanValue = false;
            this.inlineHelpText = dfr.getInlineHelpText();
            if (String.valueOf(dfr.getType()) == 'PICKLIST' || String.valueOf(dfr.getType()) == 'MULTIPICKLIST') {
                
                for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
                    this.availableOptions.add(new PicklistOptionWrapper(ple.getValue(), ple.getLabel()));
                }
            }
        }
    }

    public class PicklistOptionWrapper {
        public String name { get; set; }
        public String label { get; set; }
        public Boolean isSelected { get; set; }

        public PicklistOptionWrapper(String name, String label) {
            this.name = name;
            this.label = label;
            this.isSelected = false;
        }
    }

    public class RefTypeWrapper {
        public String refTypeId { get; set; }
        public String refTypeName { get; set; }
        public Decimal salesPoints { get; set; }
        public String notes { get; set; }
        public String refNo { get; set; }
        public String icon { get; set; }
        public String imageId { get; set; }
        public Boolean isForProject { get; set; }
        public Boolean isForRequest { get; set; }
        public Decimal maxAccPerRequest { get; set; }
        public Decimal minLeadTimePerRequest { get; set; }

        public RefTypeWrapper(Referenceability_Type__c refType) {
            this.refTypeId = refType.Id;
            this.refTypeName = refType.Name;
            this.isForProject = refType.Project_type__c;
            this.isForRequest = refType.Request_type__c;
            this.salesPoints = refType.Sales_Point__c != null ? refType.Sales_Point__c : 0;
            this.icon = refType.Icon__c != null ? refType.Icon__c : '';
            this.imageId = '';
            this.notes = refType.Note__c != null ? refType.Note__c : '';
            this.refNo = refType.Referenceability_no__c != null ? String.valueOf(refType.Referenceability_no__c) : '';
            this.maxAccPerRequest = refType.Max_accounts_per_request_type__c != null ? refType.Max_accounts_per_request_type__c : 0;
            this.minLeadTimePerRequest = refType.Min_lead_time_per_request_type__c != null ? refType.Min_lead_time_per_request_type__c : 0;
        }
    }

    public class RefNoteWrapper {
        public String refNoteId { get; set; }
        public String noteValue { get; set; }
        public String noteDate { get; set; }
        public String createdBy { get; set; }
        public String lastModDate { get; set; }
        public String createdDate { get; set; }
        public String lastModBy { get; set; }
        public String lastModById { get; set; }

        public RefNoteWrapper(Reference_Note__c note) {
            this.refNoteId = note.Id;
            this.noteValue = note.Note__c != null ? note.Note__c : '';
            this.noteDate = note.Note_Date__c != null ? note.Note_Date__c.format() : '';
            this.createdBy = note.CreatedBy.Name;
            this.lastModDate = note.LastModifiedDate != null ? note.LastModifiedDate.format() : '';
            this.createdDate = note.CreatedDate != null ? note.CreatedDate.format() : '';
            this.lastModBy = note.LastModifiedBy.Name;
            this.lastModById = String.valueOf(note.LastModifiedById);
        }
    }

    public class CommunityInviteWrapper {
        public String cicId { get; set; }
        public String response { get; set; }
        public String refTypeId { get; set; }
        public String refTypeName { get; set; }
        public String contactId { get; set; }
        public String contactName { get; set; }
        public String phone { get; set; }
        public String email { get; set; }
        public String accountId { get; set; }
        public String accountName { get; set; }
        public String lastUsed { get; set; }
        public String lastNDays { get; set; }
        public String hitCount { get; set; }
        public String assignCount { get; set; }
        public Boolean showPopover { get; set; }

        public CommunityInviteWrapper(Community_Invite_Contact__c cic) {
            this.cicId = cic.Id;
            this.response = cic.Response__c != null ? cic.Response__c : '';
            this.refTypeName = cic.Referenceability_Type__c != null ? cic.Referenceability_Type__c : '';
            this.contactId = cic.Contact__c != null ? String.valueOf(cic.Contact__c) : '';
            this.contactName = cic.Contact__c != null ? cic.Contact__r.Name : '';
            this.phone = cic.Contact__c != null && cic.Contact__r.Phone != null ? cic.Contact__r.Phone : '';
            this.email = cic.Contact__c != null && cic.Contact__r.Email != null ? cic.Contact__r.Email : '';
            this.accountId = cic.Contact__c != null ? String.valueOf(cic.Contact__r.AccountId) : '';
            this.accountName = cic.Contact__c != null ? cic.Contact__r.Account.Name : '';
            this.showPopover = false;
            this.lastUsed = '';
            this.lastNDays = '';
            this.hitCount = '';
            this.assignCount = '';
        }
    }

    public class CommunityUserWrapper{
        public String userId { get; set; }
        public String userEmail { get; set; }
        public String accountId { get; set; }
        public String contactId { get; set; }
        public String contactFName { get; set; }
        public String contactName { get; set; }
        public String contactEmail { get; set; }

        public CommunityUserWrapper(User u) {
            this.userId = u.Id;
            this.userEmail = u.Email;
            this.accountId = u.AccountId != null ? String.valueOf(u.AccountId) : '';
            this.contactId = u.ContactId != null ? String.valueOf(u.ContactId) : '';
            this.contactFName = u.ContactId != null ? u.Contact.FirstName : '';
            this.contactName = u.ContactId != null ? u.Contact.Name : '';
            this.contactEmail = u.ContactId != null && u.Contact.Email != null ? u.Contact.Email : '';
        }
    }
    
    //REF-1964
    public class InfluitiveWrapper {
        public String accountName {get;set;}
        public List<String> advocatesId {get;set;} 
        public String templateCode {get;set;}
        public String reftypeId {get;set;}
        public String participantLimit {get;set;}
        public String notes {get;set;}
        public String unspecifiedRequestId {get;set;}
        public List<Community_Invite_Contact__c> listOfCIC {get;set;}
        public String challengeId {get;set;}
        public String startAt {get;set;}
        public String endAt {get;set;}
        public String error {get;set;}
        
        public InfluitiveWrapper() {
            this.accountName = '';
            this.templateCode = '';
            this.reftypeId = '';
            this.participantLimit = '';
            this.notes = '';
            this.unspecifiedRequestId = '';
            this.advocatesId = new List<String>();
            this.listOfCIC = new List<Community_Invite_Contact__c>();
            this.challengeId = '';
            this.startAt = '';
            this.endAt = '';
            this.error = '';
        }
    }
    
    /**
     * method to post challenge in influitive
     * REF-1964
    */
    @RemoteAction
    public static String postChallengeInInfluitive(String influWrapper) {
        InfluitiveWrapper influtiveWrap = (InfluitiveWrapper)JSON.deserialize(influWrapper, InfluitiveWrapper.class);
        Set<String> contactIds = new Set<String>();
        contactIds.addAll(influtiveWrap.advocatesId);
        List<Contact> listOfContacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id IN : contactIds];
        List<Referenceability_Type__c> listOfRefType = [SELECT Id,Referenceability_code__c,Name
                                                        FROM Referenceability_Type__c 
                                                        WHERE Id =: influtiveWrap.reftypeId];
        
       if (listOfRefType.size() > 0) {
            
            if (listOfRefType[0].Referenceability_code__c != null && !String.isEmpty(listOfRefType[0].Referenceability_code__c)) {
                influtiveWrap.templateCode = listOfRefType[0].Referenceability_code__c;
            } else {
                //REF-2301
                influtiveWrap.error = String.format(Label.Error_No_Referenceability_Code_On_Referenceability_Type, new List<String> {listOfRefType[0].Name});
                return JSON.serialize(influtiveWrap);
            }
        }
        //influtiveWrap.templateCode = 'reference';
        Date temp = Date.today();
        String startAt = temp.year() + '-' + temp.month() + '-' + temp.day();
        influtiveWrap.startAt = startAt;
        
		Infl_CreateReferenceResponse response = Infl_Reference.createReferenceChallenge(influtiveWrap, listOfContacts);
        
        if (response != null) {
            
            if (response.errors != null) {
                
                if (response.errors.template_code != null) {
                    //REF-2301
                    influtiveWrap.error = String.format(Label.Error_Challenge_Template_Not_Available, new List<String> {influtiveWrap.templateCode});
                    return JSON.serialize(influtiveWrap);
                } else {
                    influtiveWrap.error = 'Error';
                    return JSON.serialize(influtiveWrap);
                }
                
            } else {
                
                if (response.uuid != null && response.uuid != '') {
                    influtiveWrap.challengeId = response.uuid;
                    influtiveWrap.listOfCIC = createCommunityInviteContactRecords(influtiveWrap,contactIds);
                    return JSON.serialize(influtiveWrap);
                    
                } else if (response.uuid != null && response.uuid == '') {
                    influtiveWrap.error = 'Empty uuid recieved!';
                    return JSON.serialize(influtiveWrap);
                } else {
                    influtiveWrap.error = 'No uuid in response from Hub!';
                    return JSON.serialize(influtiveWrap);
                }
            }
        }
        influtiveWrap.error = 'Error';
        return JSON.serialize(influtiveWrap);
    }
    
    /**
     * method to create CIC records after challenge is posted
     * REF-1964
    */
    public static List<Community_Invite_Contact__c> createCommunityInviteContactRecords(InfluitiveWrapper influtiveWrap, Set<String> contactIds) {
        ConstantsController.isCallToInfluitiveAPI = true;
        Savepoint sp = Database.setSavepoint();
        List<Community_Invite_Contact__c> listOfCIC = new List<Community_Invite_Contact__c>();
        String result = '';
        List<String> tempList = influtiveWrap.endAt.split('-');
        Date dateInstance = Date.newinstance(Integer.valueOf(tempList[0]),Integer.valueOf(tempList[1]),Integer.valueOf(tempList[2]));
        
        try {
            
            Unspecified_Request__c ur = [SELECT Id, Name, Reference_Request__c, Reference_Type_Needed__c, Reference_Type_Needed_f__c, 
                                         Unspecified_Request_Status__c, Community_Invite__c, Influitive_Challenge_Id__c, Influitive_Challenge_Status__c, Notes__c, Deadline__c 
                                         FROM Unspecified_Request__c
                                         WHERE Id =: influtiveWrap.unspecifiedRequestId];
            
            Community_Invite__c comInvite = new Community_Invite__c();
            comInvite.Referenceability_Type__c = influtiveWrap.reftypeId;
            comInvite.Reference_Request__c = ur.Reference_Request__c;
            comInvite.Unspecified_Request__c = ur.Id;
            comInvite = WithoutSharingHelperController.insertCommunityInvite(comInvite);
            
            for (String conId : contactIds) {
                Community_Invite_Contact__c newCIC = new Community_Invite_Contact__c();
                newCIC.Community_Invite__c = comInvite.Id;
                newCIC.Contact__c = conId;
                //newCIC.Response__c = 'No Response';
                newCIC.Challenge_Id__c = influtiveWrap.challengeId;
                listOfCIC.add(newCIC);
            }
            Set<String> CICIds = new Set<String>();
            
            if (listOfCIC.size() > 0) {
                WithoutSharingHelperController.upsertContactInvites(listOfCIC);
                
                for (Community_Invite_Contact__c cic : listOfCIC) {
                    CICIds.add(cic.Id);
                }
            }
            
            if (CICIds.size() > 0) {
                listOfCIC  = [SELECT Id,Account_f__c,Challenge_Id__c,Contact_Name__c,Referenceability_Type__c,
                              Response__c,Community_Invite__c,Contact__c
                              FROM Community_Invite_Contact__c
                              WHERE Id IN: CICIds]; 
            }
            
            ur.Community_Invite__c = comInvite.Id;
            ur.Influitive_Challenge_Id__c = influtiveWrap.challengeId;
            ur.Reference_Type_Needed__c = influtiveWrap.reftypeId;
            ur.Deadline__c = dateInstance;
            ur.Unspecified_Request_Status__c = 'In Progress';
            ur.Influitive_Challenge_Status__c = 'Unpublish';
            WithoutSharingHelperController.updateUnspecified(new List<Unspecified_Request__c>{ur});
        } catch(Exception e) {
            Database.rollback(sp);
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return listOfCIC;
    }
    
    /**
     * method to get CICs of an UR with challenge id
     * REF-1964
    */
    @RemoteAction
    public static Map<String,List<Community_Invite_Contact__c>> getRelatedCICByChallengeId(String challengeIds) {
        List<String> listChallengeIds = (List<String>)JSON.deserialize(challengeIds, List<String>.class);
        Map<String,List<Community_Invite_Contact__c>> mapChallengeIdCICList = new Map<String,List<Community_Invite_Contact__c>>();
        List<Community_Invite_Contact__c> listCIC = [SELECT Id, Account_f__c, Challenge_Id__c, Contact_Name__c, Referenceability_Type__c,
                              						 Response__c, Community_Invite__c, Contact__c 
                                                     FROM Community_Invite_Contact__c 
                                                     WHERE Challenge_Id__c IN: listChallengeIds];
        
        if (listCIC.size() > 0) {
            
            for (Community_Invite_Contact__c cic : listCIC) {
                
                if (mapChallengeIdCICList.containsKey(cic.Challenge_Id__c)) {
                    mapChallengeIdCICList.get(cic.Challenge_Id__c).add(cic);
                } else {
                    mapChallengeIdCICList.put(cic.Challenge_Id__c, new List<Community_Invite_Contact__c> {cic});
                }
            }
            return mapChallengeIdCICList;
        }
        return null;
    }
    
    /**
     * method to assign contact to a challenge request
     * REF-1964
    */
    @RemoteAction
    public static String assignAdvocateToChallenge(String assignedContactId, String unspecifiedId) {
        Savepoint sp = Database.setSavepoint();
        String result = '';
        Reference_Request_Account__c accReq = new Reference_Request_Account__c();
        Reference_Request_Account_Contact__c conReq = new Reference_Request_Account_Contact__c();
        List<Unspecified_Request__c> urToUpdate = [SELECT Id, Name, Reference_Request__c, Reference_Type_Needed__c, Reference_Type_Needed_f__c, 
                                                   Unspecified_Request_Status__c, Community_Invite__c, Influitive_Challenge_Id__c,
                                                   Influitive_Challenge_Status__c, Notes__c, Deadline__c
                                                   FROM Unspecified_Request__c
                                                   WHERE Id =: unspecifiedId];
        List<Contact> conInstance = [SELECT Id, FirstName, LastName, Email, AccountId 
                                     FROM Contact 
                                     WHERE Id =: assignedContactId];
        
        if (conInstance.size() > 0 && urToUpdate.size() > 0) {
            List<Referenceability_Type__c> refType = [SELECT Id,Reward_points__c,Referenceability_code__c 
                                                      FROM Referenceability_Type__c 
                                                      WHERE Id =: urToUpdate[0].Reference_Type_Needed__c];
            
            if (refType.size() > 0) {
                try {
                    ConstantsController.isCallToInfluitiveAPI = true;
                    accReq.Account__c = conInstance[0].AccountId;
                    accReq.Reference_Request__c = urToUpdate[0].Reference_Request__c;
                    accReq.Reference_Type_Needed__c = urToUpdate[0].Reference_Type_Needed__c;
                    accReq.Influitive_Challenge_Id__c = urToUpdate[0].Influitive_Challenge_Id__c;
                    accReq.Influitive_Challenge_Status__c = urToUpdate[0].Influitive_Challenge_Status__c;
                    accReq.Account_Request_Status__c = 'In Progress';
                    accReq.Reference_Use__c = true;
                    accReq.Process__c = ConstantsController.MANAGED;
                    accReq.Deadline__c = system.today();
                    WithoutSharingHelperController.upsertRRA(accReq);
                    conReq.influitiveId__c = accReq.Influitive_Challenge_Id__c;
                    conReq.Referenceability_Type__c = accReq.Reference_Type_Needed__c;
                    conReq.Reference_Request_Account__c = accReq.Id;
                    conReq.Activity_Date__c = system.today();
                    conReq.Reference_Use__c = true;
                    conReq.Deadline__c = system.today();
                    conReq.Contact__c = conInstance[0].Id;
                    conReq.Contact_Request_Status__c = 'In Progress';
                    WithoutSharingHelperController.upsertReqAccountContact(conReq);
                    urToUpdate[0].Specified_Account__c = accReq.Id;
                    urToUpdate[0].Unspecified_Request_Status__c = 'Account Specified';
                    ConstantsController.shouldUnspecifiedStatusChange = true;
                    WithoutSharingHelperController.updateUnspecified(urToUpdate);
                    //Issue Reward
                    Reward__c reward = new Reward__c();
                    reward.Account__c = accReq.Account__c;
                    reward.Contact__c = conReq.Contact__c;
                    reward.Referenceability_Type__c = accReq.Reference_Type_Needed__c;
                    reward.Transaction__c = ConstantsController.ISSUE;
                    reward.RewardDate__c = Date.today();
                    reward.Automatically_Assigned__c = true;
                    reward.Account_Request__c = accReq.Id;
                    reward.Contact_Request__c = conReq.Id;
                    reward.Amount__c = refType[0].Reward_points__c == null ? 0 : refType[0].Reward_points__c;
                    String typeCode = refType[0].Referenceability_code__c == null ? 'Non Reference Activity' : refType[0].Referenceability_code__c;
                    WithoutSharingHelperController.upsertRewards(new List<Reward__c> {reward});
                    //syncRewards(reward.Id,typeCode);
                } catch(Exception e) {
                    result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, result));
                    Database.rollback(sp);
                } 
            }
        }
        return result;
    }
    
    /**
     * method to sync rewards with influitive
     * REF-1964
    */
    @future(callout=true)
    public static void syncRewards(String rewardId, String typeCode) {
        List<Reward__c> listOfRewards = [SELECT Id, Influitive_ID2__c,Contact__c, Contact__r.Email, Amount__c
                                        FROM Reward__c
                                        WHERE Id =: rewardId];
        
        if (listOfRewards.size() > 0) {
            String rewardHubId = Infl_Event.syncRewardAtHub(listOfRewards[0],typeCode);
            
            if (!String.isBlank(rewardHubId)) {
                listOfRewards[0].Influitive_ID2__c = rewardHubId;
                WithoutSharingHelperController.upsertRewards(listOfRewards);
            }
        }
    }
    
    /**
     * method to sync status of the challenge with influitive
     * REF-1964
    */
    @RemoteAction
    public static String updateChallengeStatus(String status, String urId) {
        String result = '';
        Infl_CreateReferenceResponse response = null;
        
        if (!String.isEmpty(status)) {
            
            if(!String.isEmpty(urId)) {
                List<Unspecified_Request__c> urToUpdate = [SELECT Id, Influitive_Challenge_Id__c, Influitive_Challenge_Status__c
                                                           FROM Unspecified_Request__c
                                                           WHERE Id =: urId];
                
                if (urToUpdate.size() > 0) {
                    
                    if (status == urToUpdate[0].Influitive_Challenge_Status__c) {
                        return null;
                    }
                    urToUpdate[0].Influitive_Challenge_Status__c = status;
                    response = Infl_Reference.changeReferenceChallengeStatus(status, urToUpdate[0].Influitive_Challenge_Id__c, null);
                    
                    if (response != null && response.status != null && response.status != '') {
                        Savepoint sp = Database.setSavepoint();
                        try {
                            WithoutSharingHelperController.updateUnspecified(urToUpdate);
                        } catch (Exception e) {
                            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, result));
                            Database.rollback(sp);
                        }
                    }
                }
            }
        }
        return result;
     } 
    
    //REF-2132
    @RemoteAction
    public static String getFilesAssociatedWithReferenceRequest(String requestId) {
        List<ContentDocumentLink> listOfCDL = new List<ContentDocumentLink>();
        List<ContentDocument> listOfFile = new List<ContentDocument>();
        List<String> listOfDocumentId = new List<String>();
        
        if (!String.isBlank(requestId)) {
            listOfCDL = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: requestId];
            
            if (listOfCDL.size() > 0) {
                
                for (ContentDocumentLink cdl : listOfCDL) {
                    
                    if (!String.isBlank(String.valueOf(cdl.ContentDocumentId))) {
                        listOfDocumentId.add(cdl.ContentDocumentId);
                    }
                }
                
                if (listOfDocumentId.size() > 0) {
                    listOfFile = [SELECT Id, Title, PublishStatus, LatestPublishedVersionId, ParentId, ContentSize, FileExtension, FileType 
                                   FROM ContentDocument 
                                   WHERE Id IN: listOfDocumentId];
                }
                
            }
        }
        
        if (listOfFile.size() > 0) {
            return JSON.serialize(listOfFile);
        }
        return null;
    }
}