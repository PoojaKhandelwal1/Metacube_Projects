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
 * Class: Schedular_ResetRULSetting
 * Description : This Batch called from Schedular_ResetRULSetting 
 * Modified by: Rekha Jangir @Nov/18/2016
 */
global with sharing class Batch_MicrositeVisits implements Database.Batchable < sObject > , Database.stateful, Database.AllowsCallouts {
    private static String FEEDBACK_TO_INVITEER = 'You have new Microsite visits';
    private static String BODY_HEADER = 'Microsite visits in the last 24 hours :';
    private static String LINK_URL = URL.getSalesforceBaseUrl().toExternalForm();

    /**
     * Properties and variables
     */
    private datetime nowDateTime = System.now() - 1;
    private String soqlQuery =
        'SELECT Id, User__c, User__r.Name, User__r.CompanyName, Contact__c, Contact__r.Name, Contact__r.Account.Name, Invitation__r.Id, Invitation__r.Name, URL__c, Invitation__r.CreatedById FROM Invitee__c WHERE Visits_clicks__c != null AND LastModifiedDate >: nowDateTime AND Invitation__r.Is_Invitation_Expired__c = false ORDER BY Invitation__r.CreatedDate DESC';
    private Boolean checkChatterSetting;
    private Boolean checkEmailSetting;
    private Boolean checkSlackSetting;
    private Map < String, MailChatterController.EmailMessage > mapEmailstoSent = new Map < String, MailChatterController.EmailMessage > ();
    private map < String, String > invitationMailBody = new map < String, String > ();
    private map < Id, String > mapInvitationParticularUser = new map < Id, String > ();
    private Data_Mapping__c micrositeNotification = new Data_Mapping__c();
    private String headerDocId = '';
    private String footerDocId = '';
    private Custom_Settings__c cs = UtilityController.getCustomSettings();

    /**
     * Constructor
     */
    global Batch_MicrositeVisits() {}

    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        checkChatterSetting = (UtilityController.isNativeChatterSetting && cs.Microsite_Visit_Chatter__c);
        checkEmailSetting = cs.Microsite_Visit_Email__c;
        checkSlackSetting = cs.Enable_Slack_Integration__c && cs.Microsite_Visit_Slack__c;
        return Database.getQueryLocator(soqlQuery);
    }

    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List < Invitee__c > scope) {
        Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Microsite_Visit_Email__c'};

        for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                    FROM Data_Mapping__c
                                    WHERE Object__c = 'Notification'
                                    AND (Field_API_Name__c IN :notificationFieldNames
                                        OR Section_Name__c = 'email header doc'
                                        OR Section_Name__c = 'email footer doc')]) {

            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Microsite_Visit_Email__c') {
                micrositeNotification = dm;
            } else if (dm.Section_Name__c == 'email header doc') {
                headerDocId = dm.Field_API_Name__c;
            } else if (dm.Section_Name__c == 'email footer doc') {
                footerDocId = dm.Field_API_Name__c;
            }
        }

        for (Invitee__c invitee : scope) {
            //Prepare Body for mail & Post
            String notificationBody = '';
            
            if (!invitationMailBody.containsKey(invitee.Invitation__r.Name + ',' + invitee.Invitation__r.CreatedById)) {
                notificationBody = micrositeNotification.DC_Message__c + '\n\n' + micrositeNotification.Default__c;
                notificationBody = notificationBody.replace('[Invitation Name]', invitee.Invitation__r.Name)
                                                    .replace('[Invitation Record link]', LINK_URL + '/' + invitee.Invitation__r.Id)
                                                    .replace('- [Visitor Name] with [Account Name]', '');
                invitationMailBody.put(invitee.Invitation__r.Name + ',' + invitee.Invitation__r.CreatedById, notificationBody);
            }

            if (invitee.Contact__c != null) {
                notificationBody = invitationMailBody.get(invitee.Invitation__r.Name + ',' + invitee.Invitation__r.CreatedById) + '- ' + invitee.Contact__r.Name +
                    ' with ' + (invitee.Contact__r.Account.Name == null ? '' : invitee.Contact__r.Account.Name) + '\n';
            } else if (invitee.User__c != null) {
                notificationBody = invitationMailBody.get(invitee.Invitation__r.Name + ',' + invitee.Invitation__r.CreatedById) + '- ' + invitee.User__r.Name +
                    ' with ' + (invitee.User__r.CompanyName == null ? '' : invitee.User__r.CompanyName) + '\n';
            }

            if (notificationBody != '') {
                invitationMailBody.put(invitee.Invitation__r.Name + ',' + invitee.Invitation__r.CreatedById, notificationBody);
            }
        }

        for (String invitationKey : invitationMailBody.keySet()) {
            string invitationCreatedBy = invitationKey.split(',')[1];
            
            if (!mapInvitationParticularUser.containsKey(invitationCreatedBy)) {
                mapInvitationParticularUser.put(invitationCreatedBy, invitationMailBody.get(invitationKey));
            } else {
                String combinedMail = mapInvitationParticularUser.get(invitationCreatedBy) + '\n\n' + invitationMailBody.get(invitationKey);
                mapInvitationParticularUser.put(invitationCreatedBy, combinedMail);
            }
        }
    }

    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {
        List < sObject > postFeedItems = new List < sObject > ();
        List < Messaging.SingleEmailMessage > listmail = new List < Messaging.SingleEmailMessage > ();
		RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
        Map<String, Object> slackReqBody = new Map<String, Object>();
        slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
        slackReqBody.put('orgId', UserInfo.getOrganizationId());
        List<Map<String, String>> messagesList = new List<Map<String, String>>();
        Map<Id, String> userEmailMap = new Map<Id, String>();

        for (User u : WithoutSharingHelperController.getUserMap(mapInvitationParticularUser.keySet()).values()) {
            
            if (u.IsActive) {
                userEmailMap.put(u.Id, u.Email);
            }
        }
		
        for (String userId : mapInvitationParticularUser.keySet()) {
            String mailBody = mapInvitationParticularUser.get(userId);
            
            //Prepare Chatter List
            if (checkChatterSetting) {
                //ReferenceEdge user is used as sender regarding #486
                postFeedItems.add(MailChatterController.preparePostForRefedgeUser('', userId, mailBody, '', protectedAppConfig.User_Id__c));
            }
            
            //Prepare Email List
            if (checkEmailSetting) {
            	//Setting logo id empty for issue R15.96 - MOD
            	//ReferenceEdge user is used as sender regarding #486
                listmail.add(MailChatterController.prepareEmail(micrositeNotification.Section_Name__c, userId, mailBody, true, headerDocId, footerDocId));
            }
            
            if (checkSlackSetting) {
                Map<String, String> tempReqBodyMap = new Map<String, String>();
                tempReqBodyMap.put('userEmail', userEmailMap.get(userId));
                tempReqBodyMap.put('text', '*' + micrositeNotification.Section_Name__c + '*\n' + mailBody);
                messagesList.add(tempReqBodyMap);
            }
        }

        if (messagesList != null && messagesList.size() > 0) {
            slackReqBody.put('messages', messagesList);
            UtilityController.postMsgToSlackSync(JSON.serialize(slackReqBody));
        }

        //Insert list of postFeedItems
        if (postFeedItems.size() > 0) {
            Database.SaveResult[] postItems = database.insert(postFeedItems, false);
        }

        //Send List of emails
        if (listmail.size() > 0) {
            Messaging.sendEmail(listmail);
        }
    }
}