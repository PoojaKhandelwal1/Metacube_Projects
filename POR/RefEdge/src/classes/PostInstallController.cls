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
 * Description: The mehods in this class are executed whenever the package is installed on an org.
 * Last Modified By: Dixita (Sept, 2018)
 */
global class PostInstallController implements InstallHandler {
    
    /**
     * On Installation Method
     */
    global void onInstall(InstallContext context) {
        
        if (context.previousVersion() == null) {
            insert insertCustomSetting();
            insert insertContentTypeMapping();
            insert insertReferenceContentType();
            insertApp_Configuration(true);
            setupHelpOverlay();
            scheduleClasses();
            createCustomNotifications();
        } else {
            
            if (context.isUpgrade()) {
                List<Reference_Content_Type__c> rcTypeList = New List<Reference_Content_Type__c>([SELECT Id, Name__c FROM Reference_Content_Type__c WHERE Name__c =: ConstantsController.REFERENCE_CONTENT_TYPE]);
                List<Data_Mapping__c> customNotifications = [SELECT Id, Field_API_Name__c FROM Data_Mapping__c WHERE Object__c = 'Notification'];
                List<Data_Mapping__c> dmsToUpdate = new List<Data_Mapping__c>();

                if (customNotifications == null || customNotifications.size() == 0) {
                    createCustomNotifications();
                } else {

                    for (Data_Mapping__c dm : customNotifications) {
                        
                        if (dm.Field_API_Name__c != null) {

                            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Profile_Creation_from_Ref_Lead_Email__c') {
                                dm.Default__c = 'Contact: [Contact Name]\n'
                                                + 'Account: [Account Name]\n'
                                                + 'Created by: [Creator Name]';
                            }
                            
                            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Peer2Peer_Email__c') {
                                dm.Default__c = 'Reference Account: [Requested Account]\n'
                                                + 'Use Requested: [Request Type]\n'
                                                + 'Need By: [Deadline]\n'
                                                + 'Request From: [User Name]\n\n'
                                                + 'Details:\n'
                                                + '[Selected Filter Attributes]\n'
                                                + 'Request Note: [Request Notes]';
                            }
                            
                            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Managed_Email__c') {
                                dm.Default__c = 'Reference Account: [Requested Account]\n'
                                                + 'Use Requested: [Request Type]\n'
                                                + 'Need By: [Deadline]\n'
                                                + 'Request From: [User Name]\n\n'
                                                + 'Request Note: [Request Notes]\n\n';
                            }

                            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Approve_Decline_Confirmation_Email__c') {
                                dm.Visible__c = false;
                            }

                            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Approval_Decline_Email__c') {
                                dm.Visible__c = false;
                                dm.Default__c = 'Opportunity Account: [Opportunity Account]\n'
                                                + 'Reference Account: [Requested Account]\n'
                                                + 'Contact: [Contact Name]\n'
                                                + 'Title: [Contact Title]\n'
                                                + 'Email: [Contact Email]\n'
                                                + 'Phone: [Contact Phone]\n'
                                                + 'Dispositioned By: [User Name]\n\n'
                                                + 'Note: [Approve/Decline Notes]';
                            }

                            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Managed_to_P2P_Owner_Email__c') {
                                dm.Default__c = 'Opportunity Account: [Opportunity Account]\n'
                                                + 'Reference Account: [Requested Account]\n'
                                                + 'Use Requested: [Request Type]\n'
                                                + 'Deadline: [Deadline]\n'
                                                + 'Owner: [Request Owner]\n'
                                                + 'Request From: [User Name]\n'
                                                + 'Request Note: [Request Notes]';
                            }
                            String notificationNameSlack = dm.Field_API_Name__c.replace('Email', 'Slack');
                            dm.Data_Collector_Name__c = notificationNameSlack;
                            dmsToUpdate.add(dm);
                        }
                    }
                    
                    if (dmsToUpdate != null && dmsToUpdate.size() > 0) {
                        ConstantsController.shouldDataMappingProcessed = true;
                        update dmsToUpdate;
                    }
                }

                if (rcTypeList.size() == 0) {
                    insert insertReferenceContentType();
                }                
                insertApp_Configuration(false);
                setupHelpOverlay();
                scheduleClasses();
            }
        }
    }

    /**
     * method to create data mapping records for user customizable notification
     * author: Gaurav Saini (22 Oct, 2018) for REF-1862
     */
    private static void createCustomNotifications() {
        List<Data_Mapping__c> customNotificationsList = new List<Data_Mapping__c>();
        ConstantsController.shouldDataMappingProcessed = true;

        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Section_Name__c = 'email header doc',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Section_Name__c = 'email footer doc',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Request_Peer2Peer_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Request_Peer2Peer_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Request_Peer2Peer_Slack__c',
                                                        DC_Message__c = 'I would like to use an account as a reference for which you are the owner.\n'
                                                            + 'Here are the details:',
                                                        Default__c = 'Reference Account: [Requested Account]\n'
                                                            + 'Use Requested: [Request Type]\n'
                                                            + 'Need By: [Deadline]\n'
                                                            + 'Request From: [User Name]\n\n'
                                                            + 'Details:\n'
                                                            + '[Selected Filter Attributes]\n'
                                                            + 'Request Note: [Request Notes]',
                                                        Section_Name__c = 'Reference Request for [Requested Account]',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Request_Managed_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Request_Managed_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Request_Managed_Slack__c',
                                                        DC_Message__c = 'I need assistance from the Reference Program in securing a reference.\n'
                                                            + 'Here are the details:',
                                                        Default__c = 'Reference Account: [Requested Account]\n'
                                                            + 'Use Requested: [Request Type]\n'
                                                            + 'Need By: [Deadline]\n'
                                                            + 'Request From: [User Name]\n\n'
                                                            + 'Request Note: [Request Notes]\n\n',
                                                        Section_Name__c = 'Reference Request for [Requested Account]',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Request_Approval_Decline_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Request_Approval_Decline_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Request_Approval_Decline_Slack__c',
                                                        DC_Message__c = 'I have [Disposition] your reference use request for a [Request Type].\n'
                                                            + 'Here are the details:',
                                                        Default__c = 'Opportunity Account: [Opportunity Account]\n'
                                                            + 'Reference Account: [Requested Account]\n'
                                                            + 'Contact: [Contact Name]\n'
                                                            + 'Title: [Contact Title]\n'
                                                            + 'Email: [Contact Email]\n'
                                                            + 'Phone: [Contact Phone]\n'
                                                            + 'Dispositioned By: [User Name]\n\n'
                                                            + 'Note: [Approve/Decline Notes]',
                                                        Section_Name__c = 'Reference Use Request [Disposition]',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Request_Reminder_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Request_Reminder_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Request_Reminder_Slack__c',
                                                        DC_Message__c = 'This is a friendly reminder that there is an outstanding reference use request for an account for which you are the owner.\n'
                                                            + 'Here are the details:',
                                                        Default__c = 'Reference Account: [Requested Account]\n'
                                                            + 'Use Requested: [Request Type]\n'
                                                            + 'Need By: [Deadline]\n\n'
                                                            + 'Note: [Request Notes]',
                                                        Section_Name__c = 'Reference Request Reminder',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Request_Escalation_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Request_Escalation_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Request_Escalation_Slack__c',
                                                        DC_Message__c = 'One of your team members has a pending reference account request that has not yet been approved or declined. Your assistance is needed to help resolve this unanswered request.\n'
                                                            + 'Here are the details:',
                                                        Default__c = 'Team Member: [Request Owner]\n'
                                                            + 'Reference Account: [Requested Account]\n'
                                                            + 'Use Requested: [Request Type]\n'
                                                            + 'Requester: [Requester Name]\n'
                                                            + 'Need By: [Deadline]\n\n'
                                                            + 'Note: [Request Notes]',
                                                        Section_Name__c = 'Escalation: Reference Account Request',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Request_No_Response_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Request_No_Response_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Request_No_Response_Slack__c',
                                                        DC_Message__c = 'Sorry, [Request Owner] has not responded to your reference account request. Please make alternative plans to meet this need.\n'
                                                            + 'Here are the details:',
                                                        Default__c = 'Reference Account: [Requested Account]\n'
                                                            + 'Use Requested: [Request Type]\n'
                                                            + 'Need By: [Deadline]\n\n'
                                                            + 'Note: [Request Notes]',
                                                        Section_Name__c = 'ALERT: No Response to Reference Account Request',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Approve_Decline_Confirmation_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Approve_Decline_Confirmation_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Approve_Decline_Confirmation_Slack__c',
                                                        DC_Message__c = '[You/Approver Name] [Disposition] the request to use [Requested Account] as a reference on [Disposition Date].',
                                                        Section_Name__c = 'Confirmation of Reference [Disposition]',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Large_Opportunity_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Large_Opportunity_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Large_Opportunity_Slack__c',
                                                        DC_Message__c = 'A new request has been submitted. The opportunity associated to this request is greater than [Opportunity Threshold Amount] so this request has been switched from Peer2Peer to Managed.\n'
                                                            + 'Here are the details:',
                                                        Default__c = 'Requester: [Requester Name]\n'
                                                            + 'Account Requested: [Requested Account]\n'
                                                            + 'Request type: [Request Type]\n'
                                                            + 'Account Request Deadline: [Deadline]\n\n'
                                                            + 'Account Request Note: [Request Notes]',
                                                        Section_Name__c = 'Reference Request, Large Opportunity',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Managed_to_P2P_Owner_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Managed_to_P2P_Owner_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Managed_to_P2P_Owner_Slack__c',
                                                        DC_Message__c = 'I would like to use an account as a reference for which you are the owner.\n'
                                                            + 'Here are the details:',
                                                        Default__c = 'Opportunity Account: [Opportunity Account]\n'
                                                            + 'Reference Account: [Requested Account]\n'
                                                            + 'Use Requested: [Request Type]\n'
                                                            + 'Deadline: [Deadline]\n'
                                                            + 'Owner: [Request Owner]\n'
                                                            + 'Request From: [User Name]\n'
                                                            + 'Request Note: [Request Notes]',
                                                        Section_Name__c = 'Reference Request for [Requested Account]',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Managed_to_P2P_Requester_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Managed_to_P2P_Requester_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Managed_to_P2P_Requester_Slack__c',
                                                        DC_Message__c = 'We received your reference request and found a matching account. A request has been sent to the owner for a response, which will be sent to you directly.',
                                                        Default__c = 'Opportunity Account: [Opportunity Account]\n'
                                                            + 'Reference Account: [Requested Account]\n'
                                                            + 'Use Requested: [Request Type]\n'
                                                            + 'Deadline: [Deadline]\n'
                                                            + 'Owner: [Request Owner]\n'
                                                            + 'Request Note: [Request Notes]',
                                                        Section_Name__c = 'Account match found for Reference Request',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'P2P_to_Managed_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'P2P_to_Managed_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'P2P_to_Managed_Slack__c',
                                                        DC_Message__c = 'The following reference request is now being managed by the Customer Reference Team.',
                                                        Default__c = 'Opportunity Account: [Opportunity Account]\n'
                                                            + 'Reference Account: [Requested Account]\n'
                                                            + 'Use Requested: [Request Type]\n'
                                                            + 'Deadline: [Deadline]\n'
                                                            + 'Owner: [Request Owner]',
                                                        Section_Name__c = 'ALERT: Request now managed by the Reference Team',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Project_Owner_Update_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Project_Owner_Update_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Project_Owner_Update_Slack__c',
                                                        DC_Message__c = '[Approve Deny Notes]',
                                                        Default__c = 'Use Requested: [Request Type]\n'
                                                            + 'Reference Account: [Requested Account]\n'
                                                            + 'Status: [Account Request Status]\n'
                                                            + 'Need by: [Deadline]\n\n'
                                                            + '[Project Owner] is now managing your Request',
                                                        Section_Name__c = '[Project Owner] is now managing your Request',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Status_Update_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Status_Update_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Status_Update_Slack__c',
                                                        DC_Message__c = 'The status of your request has changed.',
                                                        Default__c = 'Opportunity Account: [Opportunity Account]\n'
                                                            + 'Reference Account: [Requested Account]\n'
                                                            + 'Use Requested: [Request Type]\n'
                                                            + '-------------------------\n'
                                                            + 'Status changed to: [Account Request Status]\n'
                                                            + '-------------------------\n'
                                                            + 'Need By: [Deadline]',
                                                        Section_Name__c = 'Reference Request Update',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Request_Feedback_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Request_Feedback_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Request_Feedback_Slack__c',
                                                        DC_Message__c = 'Could you please provide feedback on your recent reference use:',
                                                        Default__c = 'Opportunity Account: [Opportunity Account]\n'
                                                            + 'Reference Account: [Requested Account]\n'
                                                            + 'Use Requested: [Request Type]\n'
                                                            + 'Use Date: [Deadline]',
                                                        Section_Name__c = 'Provide Reference Use Feedback',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Microsite_Visit_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Microsite_Visit_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Microsite_Visit_Slack__c',
                                                        DC_Message__c = 'Microsite visits in the last 24 hours:',
                                                        Default__c = 'Invitation: [Invitation Name]\n'
                                                            + 'Link: [Invitation Record link]\n\n'
                                                            + 'Visitors:\n'
                                                            + '- [Visitor Name] with [Account Name]',
                                                        Section_Name__c = 'You have new Microsite visits',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Nomination_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Nomination_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Nomination_Slack__c',
                                                        DC_Message__c = 'A new [Account/Contact] has been nominated to the Reference Program',
                                                        Default__c = 'Contact: [Contact Name]\n'
                                                            + 'Account: [Account Name]\n'
                                                            + 'Nominated By: [Nominator]',
                                                        Section_Name__c = 'New [Account/Contact] Nomination',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Nomination_Accepted_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Nomination_Accepted_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Nomination_Accepted_Slack__c',
                                                        DC_Message__c = '[Account/Contact Name] has been accepted into the Reference Program. Thanks again for nominating them.',
                                                        Default__c = '[Nomination Note]',
                                                        Section_Name__c = '[Account/Contact Name] accepted into the Reference Program',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Nomination_Rejected_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Nomination_Rejected_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Nomination_Rejected_Slack__c',
                                                        DC_Message__c = 'Thanks for nominating [Account/Contact Name] to the Reference Program.\nUnfortunately, at this time we’re unable to add them to the program.',
                                                        Default__c = 'Contact: [Contact Name]\n'
                                                            + 'Account: [Account Name]\n'
                                                            + 'Note: [Nomination Note]',
                                                        Section_Name__c = 'Nomination declined',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Initial_Notification_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Initial_Notification_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Initial_Notification_Slack__c',
                                                        DC_Message__c = 'The Opportunity [Opportunity Name] with [Opportunity Account] was a recent win for you. Congratulations! The customer reference team is always seeking new ways to showcase client success. Do you think [Opportunity Account] would act as a reference at this time?',
                                                        Section_Name__c = '[Opportunity Account] referenceability',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Initial_Notification_member_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Initial_Notification_member_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Initial_Notification_member_Slack__c',
                                                        DC_Message__c = 'The Opportunity [Opportunity Name] with [Opportunity Account] was a recent win for you. Congratulations! [Opportunity Account] is already a member of the reference program. As a result of this win, are there any new Contacts that should be added to the program?',
                                                        Section_Name__c = '[Opportunity Account] referenceability',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Ref_Lead_Reminder_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Ref_Lead_Reminder_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Ref_Lead_Reminder_Slack__c',
                                                        DC_Message__c = 'REMINDER: The Opportunity [Opportunity Name] with [Opportunity Account] was a recent win for you. Congratulations! The customer reference team is always seeking new ways to showcase client success. Do you think [Opportunity Account] would act as a reference at this time?',
                                                        Section_Name__c = 'REMINDER: [Opportunity Account] referenceability',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Ref_Lead_Reminder_member_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Ref_Lead_Reminder_member_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Ref_Lead_Reminder_member_Slack__c',
                                                        DC_Message__c = 'REMINDER: The Opportunity [Opportunity Name] with [Opportunity Account] was a recent win for you. Congratulations! [Opportunity Account] is already a member of the reference program. As a result of this win, are there any new Contacts that should be added to the program?',
                                                        Section_Name__c = 'REMINDER: [Opportunity Account] referenceability',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Check_back_in_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Check_back_in_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Check_back_in_Slack__c',
                                                        DC_Message__c = 'We\'ve noted that [Opportunity Account] may be willing to be a Reference and you\'re going to check with them. We\'ll check back with you in [Specified Timeframe]. Thanks again!',
                                                        Section_Name__c = '[Opportunity Account] referenceability',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Ref_Lead_Owner_Update_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Ref_Lead_Owner_Update_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Ref_Lead_Owner_Update_Slack__c',
                                                        DC_Message__c = 'The Opportunity [Opportunity Name] with [Opportunity Account] was a recent win for your colleague [Opportunity Owner]. [Opportunity Owner] indicated that you are responsible for the ongoing relationship with [Opportunity Account]. The customer reference team is always seeking new ways to showcase client success. Do you think [Opportunity Account] would act as a reference at this time?',
                                                        Section_Name__c = '[Opportunity Account] referenceability',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Profile_Creation_from_Ref_Lead_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Profile_Creation_from_Ref_Lead_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Profile_Creation_from_Ref_Lead_Slack__c',
                                                        DC_Message__c = 'A new Reference Profile has been created from a Reference Lead.',
                                                        Default__c = 'Contact: [Contact Name]\n'
                                                            + 'Account: [Account Name]\n'
                                                            + 'Created by: [Creator Name]',
                                                        Section_Name__c = 'Reference Profile Created',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Reference_Refresh_Update_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Reference_Refresh_Update_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Reference_Refresh_Update_Slack__c',
                                                        DC_Message__c = 'Updates have been made to the following Reference Profiles and are quarantined awaiting your review:',
                                                        Default__c = '[Account/Contact Name]',
                                                        Section_Name__c = 'Review Profile Update(s)',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Reference_Update_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Reference_Update_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Reference_Update_Slack__c',
                                                        DC_Message__c = 'It\'s that time again. Time to review the customer reference information related to your Accounts. Your knowledge of the Account is essential to accurate reference search results. Thank you for your attention!\n\nAccounts requiring your review include:',
                                                        Default__c = '[Account Name 1]\n[Account Name 2]\n[Account Name 3]',
                                                        Section_Name__c = 'Update Request: Reference Accounts',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Profile_Update_Reminder_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Profile_Update_Reminder_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Profile_Update_Reminder_Slack__c',
                                                        DC_Message__c = '',
                                                        Default__c = 'Your ReferenceEdge Profile Update Minder is set to \'Automatic\'. The next set of notifications is due to be sent [Next Notification Date].\n'
                                                            + 'If you do NOT want these notifications to be sent you can modify the [profile update minder settings].\nTo review updates that have been sent go to [Profile Updates]',
                                                        Section_Name__c = 'REMINDER: ReferenceEdge Profile Update notifications will be sent in [Send Reminder for Automatic] days.',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Profile_Created_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Profile_Created_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Profile_Created_Slack__c',
                                                        DC_Message__c = 'A new Reference Profile has been created.',
                                                        Default__c = 'Contact: [Contact Name]\n'
                                                            + 'Account: [Account Name]\n'
                                                            + 'Created by: [Creator Name]',
                                                        Section_Name__c = 'Reference Profile Created',
                                                        Visible__c = true));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'User_Reward_Email_Summary__c',
                                                        Label__c = UtilityController.appNamespace() + 'User_Reward_Chatter_Summary__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'User_Reward_Slack_Summary__c',
                                                        DC_Message__c = '[User First Name],\n\nBelow is a summary of your customer reference activities that have earned you points.',
                                                        Default__c = 'Total points earned for the month: [Total Points for Month]\n'
                                                            + 'Activities performed: [Sales Activity Performed]\n'
                                                            + 'Lifetime Points: [Lifetime Points]\n'
                                                            + 'Available Points: [Available Points]',
                                                        Section_Name__c = 'Customer Reference activities that have earned you rewards',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Sales_Reward_Point_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Sales_Reward_Point_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Sales_Reward_Point_Slack__c',
                                                        DC_Message__c = 'Hi [User First Name] [User Last Name],\n\nCongratulations, you just earned reward points:',
                                                        Default__c = 'Activity: [Activity Name]\n'
                                                            + 'New points earned: [Activity Points]\n'
                                                            + 'Current balance: [Current Balance Points]',
                                                        Section_Name__c = 'You\'ve earned new points',
                                                        Visible__c = false));
        insert customNotificationsList;
    }

    /**
     * Method to create new Reference Content Type Record   (REF-1308)
     * Functionality Data Collector
     */
    private static Reference_Content_Type__c insertReferenceContentType() {
        return new Reference_Content_Type__c(
        Name__c = ConstantsController.REFERENCE_CONTENT_TYPE,
        Custom_Content_Type__c = true,
        Active__c = true
        );
    }
    
    /**
     * method to setup Data for HelpOverlay
     * author: Dixita (Sept, 2018) for #1861
     */
    private static void setupHelpOverlay() {
        
        try {
            Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Data_Mapping__c', new Set<String>{
                            UtilityController.appNamespace() + 'Label__c',
                            UtilityController.appNamespace() + 'Default__c',
                            UtilityController.appNamespace() + 'DC_Message__c',
                            UtilityController.appNamespace() + 'Visible__c',
                            UtilityController.appNamespace() + 'Order__c',
                            UtilityController.appNamespace() + 'Field_API_Name__c'});
            
            if (CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true)) {
                List<String> pageName = new List<String>();
                pageName.add(UtilityController.appNamespace() + 'RfSearchPage');
                pageName.add(UtilityController.appNamespace() + 'RfSearchLightning');
                pageName.add(UtilityController.appNamespace() + 'Invitation_New');
                pageName.add(UtilityController.appNamespace() + 'Invitation_NewSLDS');
                pageName.add(UtilityController.appNamespace() + 'ReferenceUseRequest');
                pageName.add(UtilityController.appNamespace() + 'ReferenceUseRequestSLDS');
                pageName.add(UtilityController.appNamespace() + 'ReferenceRefreshPageSLDS');
                List<Data_Mapping__c> entries = WithoutSharingHelperController.getDMHelpOverlay(pageName);
                
                if (entries.size() == 0 ) {
                    ConstantsController.shouldDataMappingProcessed = true;
                    UtilityController.helpAssistant(pageName);
                }
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Method to create new custom setting data
     */
    private static Custom_Settings__c insertCustomSetting() {
        return new Custom_Settings__c(
            Name = 'Active Custom Setting',
            Number_of_request_accounts__c = 5,
            Minimum_Deadline__c = 5,
            Reminder_to_Owner__c = 3,
            Escalation_to_Owner_Manager__c = 2,
            No_Response__c = 1,
            Feedback_Message_Delay__c = 2,
            Email_Enabled__c = true,
            Chatter_Enabled__c = true,
            Include_Weekends__c = true,
            Days_of_Week__c = 'Saturday;Sunday',
            Active_Version__c = true,
            Auto_create_delete_Reference_Content__c = true,
            RUL_Activities__c = 1,
            RUL_Activities_Contact__c = 1,
            RUL_Period__c = 30,
            RUL_Period_Contact__c = 30,
            Current_Version__c = '1.78.2',
            Caution_deadline_window__c = 7,
            Critical_Deadline_window__c = 4,
            Nomination_disposition_window__c = 10,
            Default_Expiration_Days__c = 7,
            Maximum_Expiration_Days__c = 14,
            Organization_FiscalYearStartMonth__c = getOrganization(),
            Default_Referenceablity_Status__c = ConstantsController.ACTIVE,
            Microsite_Visit_Chatter__c = true,
            Microsite_Visit_Email__c = true,
            Nomination_Chatter__c = true,
            Nomination_Email__c = true,
            Request_Managed_Chatter__c = true,
            Request_Managed_Email__c = true,
            Request_Peer2Peer_Chatter__c = true,
            Request_Peer2Peer_Email__c = true,
            Request_Escalation_Chatter__c = true,
            Request_Escalation_Email__c = true,
            Request_Feedback_Chatter__c = true,
            Request_Feedback_Email__c = true,
            Request_No_Response_Chatter__c = true,
            Request_No_Response_Email__c = true,
            Request_Reminder_Chatter__c = true,
            Request_Reminder_Email__c = true,
            Request_Approval_Decline_Email__c = true,
            Request_Approval_Decline_Chatter__c = true,
            Project_Owner_Update_Chatter__c = true,
            Project_Owner_Update_Email__c = true,
            Status_Update_Chatter__c = true,
            Status_Update_Email__c = true,
            Reference_Lead_No_Response_Email__c = true,
            Reference_Lead_No_Response_Chatter__c = true,
            Reference_Refresh_Update_Chatter__c = true,
            Reference_Refresh_Update_Email__c = true,
            Reference_Update_Chatter__c = true,
            Reference_Update_Email__c = true,
            Check_back_in_Email__c = true,
            Check_back_in_Chatter__c = true,
            Initial_Notification_Email__c = true,
            Initial_Notification_Chatter__c = true,
            Profile_Update_Reminder_Email__c = true,
            Profile_Update_Reminder_Chatter__c = true,
            Client_Referenceability_check_days__c = 60,
            Create_Nomination__c = true,
            Minimum_Opportunity_Size__c = 50000000,
            Prevent_selection_of_mapped_Attributes__c = true,
            No_Response_days__c = 62,
            Opportunity_Closed_Won_Stage__c = 'Closed Won',
            Consider_No_longer_needed_a_use__c = true,
            Limit_Contact_Redeem__c = true,
            Approve_Decline_Confirmation_Chatter__c = true,
            Approve_Decline_Confirmation_Email__c = true,
            Sales_Reward_Point_Chatter__c = true,
            Sales_Reward_Point_Email__c = true,
            User_Reward_Email_Summary__c = true,
            User_Reward_Chatter_Summary__c = true
        );
    }

    /**
     * Method to create content type mappings
     */
    public static List<Content_Type_Mapping__c> insertContentTypeMapping() {
        List<Content_Type_Mapping__c> listContentTypeMapping = new List<Content_Type_Mapping__c>();
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'UNKNOWN', Static_Resource_Image__c = '/doctype_unknown_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'TEXT', Static_Resource_Image__c = '/doctype_txt_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'MP4', Static_Resource_Image__c = '/doctype_mp4_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'CSV', Static_Resource_Image__c = '/doctype_csv_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'EXCEL', Static_Resource_Image__c = '/doctype_excel_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'JPG', Static_Resource_Image__c = '/doctype_image_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'BMP', Static_Resource_Image__c = '/doctype_image_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'PNG', Static_Resource_Image__c = '/doctype_image_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'GIF', Static_Resource_Image__c = '/doctype_image_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'LINK', Static_Resource_Image__c = '/doctype_link_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'PDF', Static_Resource_Image__c = '/doctype_pdf_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'POWER_POINT', Static_Resource_Image__c = '/doctype_ppt_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'RTF', Static_Resource_Image__c = '/doctype_rtf_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'WAV', Static_Resource_Image__c = '/doctype_audio_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'MOV', Static_Resource_Image__c = '/doctype_video_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'WORD', Static_Resource_Image__c = '/doctype_word_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'WORD_X', Static_Resource_Image__c = '/doctype_word_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'EXCEL_X', Static_Resource_Image__c = '/doctype_excel_16.png'));
        listContentTypeMapping.add(new Content_Type_Mapping__c(Content_Type_Extension__c = 'POWER_POINT_X', Static_Resource_Image__c = '/doctype_ppt_16.png'));
        return listContentTypeMapping;
    }
    
    /**
     * Method to create new App_Configuration Custom setting data
     */
    private static void insertApp_Configuration(boolean isNewPackage) {
        //Get Header & footer document Id
        String headerId = '';
        String footerId = '';
        
        for (Document doc : [SELECT Id, DeveloperName FROM Document
                                WHERE DeveloperName = 'POR_Template_Logo'
                                OR DeveloperName = 'Footer_Logo']) {
            
            if (doc.DeveloperName == 'POR_Template_Logo') {
                headerId = doc.Id;
            }
            
            if (doc.DeveloperName == 'Footer_Logo') {
                footerId = doc.Id;
            }
        }
        
        // Protected custom settings for storing microsite encryption/decryption key
        // added for #588 by Gaurav Saini (23 Nov, 2016)
        RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
        
        if (protectedAppConfig.Microsite_Key__c == null || protectedAppConfig.Microsite_Key__c == '') {
            
            if (protectedAppConfig.Current_Package_Date__c == null) {
                protectedAppConfig.Current_Package_Date__c = Datetime.now();
            }
            protectedAppConfig.Microsite_Key__c = EncodingUtil.base64Encode(Crypto.generateAesKey(256));
        }
        //ReferenceEdge userId is stored regarding #486
        protectedAppConfig.User_Id__c = UserInfo.getUserId();
        upsert protectedAppConfig;
        //Update app config custom setting
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        appConfig.Namespace__c = 'refedge__';
        appConfig.Company_logo_document_id__c = headerId;
        appConfig.Footer_logo_document_id__c = footerId;
        
        if (isNewPackage) {
            appConfig.Is_Update_Referenceability_Types__c = true;
            appConfig.Is_Update_Reference_Profiles__c = true;
            appConfig.Is_Update_Reference_Content__c = true;
            appConfig.Is_Create_Request_Invitation_Records__c = true;
            appConfig.Is_Update_Reward_Declined_Request_Record__c = true;
            appConfig.Is_Update_Custom_Setting__c = true;
            appConfig.Update_Account_and_Contact_Request_NLN__c = true;
            appConfig.AccountTrigger__c = true;
            appConfig.ContactTrigger__c = true;
            appConfig.ContentTrigger__c = true;
            appConfig.OpportunityTrigger__c = true;
            appConfig.OpportunityProductTrigger__c = true;
            appConfig.ProductTrigger__c = true;
            appConfig.LeadTrigger__c = true;
        } else {
            appConfig.Is_Update_Reference_Content__c = false;
            appConfig.Is_Update_Custom_Setting__c = false;
            appConfig.AccountTrigger__c = true;
            appConfig.ContactTrigger__c = true;
            appConfig.ContentTrigger__c = true;
            appConfig.OpportunityTrigger__c = true; 
            appConfig.OpportunityProductTrigger__c = true;
            appConfig.ProductTrigger__c = true;
            appConfig.LeadTrigger__c = true;
        }
        upsert appConfig;
    }

    /**
     * Method to get Organization Details
     */
    private static Integer getOrganization() {
        List<Organization> organization = [SELECT FiscalYearStartMonth, UsesStartDateAsFiscalYearName
                                                FROM Organization LIMIT 1];
        return (organization.size() > 0 ? organization[0].FiscalYearStartMonth : 1);
    }
    
    /**
     * Method to Schedule classes
     */
    private void scheduleClasses() {
        Set<String> setApexClassId = new Set<String>();
        
        for (AsyncApexJob aaj : [SELECT Status, ApexClassId FROM AsyncApexJob
                                    WHERE JobType = 'ScheduledApex'
                                    AND Status NOT IN ('Aborted', 'Completed', 'Failed')
                                    LIMIT :limits.getLimitQueryRows()]) {
            setApexClassId.add(aaj.ApexClassId);
        }
        
        Set<String> apexClasses = new Set<String>();
        
        for (ApexClass ac : [SELECT Name, Id FROM ApexClass WHERE Id IN :setApexClassId
                                LIMIT :limits.getLimitQueryRows()]) {
            apexClasses.add(ac.Name.toLowerCase().trim());
        }
        
        //AccountAttribute Schedular
        Schedular_AccountAttribute aaSchedularClass = new Schedular_AccountAttribute();
        String aasch = '0 0 1 * * ?';
        
        if (!apexClasses.contains('schedular_accountattribute')) {
            try {
                Id aaSchedularId = System.Schedule('RefEdge_AccountAttribute Schedular', aasch, aaSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_AccountAttribute Schedular" is already scheduled for execution.')) {
                    Id aaSchedularId = System.Schedule('RefEdge_AccountAttribute Schedular', aasch, aaSchedularClass);
                }
            }
        }
        
        //ContactAttribute Schedular
        Schedular_ContactAttribute caSchedularClass = new Schedular_ContactAttribute();
        String casch = '0 20 1 * * ?';
        
        if (!apexClasses.contains('schedular_contactattribute')) {
            try {
                Id caSchedularId = System.Schedule('RefEdge_ContactAttribute Schedular', casch, caSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_ContactAttribute Schedular" is already scheduled for execution.')) {
                    Id caSchedularId = System.Schedule('RefEdge_ContactAttribute Schedular', casch, caSchedularClass);
                }
            }
        }
        
        //ContentAttribute Schedular
        Schedular_AttributeMapping coaSchedularClass = new Schedular_AttributeMapping();
        String coasch = '0 40 1 * * ?';
        
        if (!apexClasses.contains('schedular_attributemapping')) {
            try {
                Id coaSchedularId = System.Schedule('RefEdge_ContentAttribute Schedular', coasch, coaSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_ContentAttribute Schedular" is already scheduled for execution.')) {
                    Id coaSchedularId = System.Schedule('RefEdge_ContentAttribute Schedular', coasch, coaSchedularClass);
                }
            }
        }
        
        //  REF - 1223
        //ReferenceRequestAccount Schedular
        Schedular_ReferenceRequestAccount rraSchedularClass = new Schedular_ReferenceRequestAccount();
        String rrasch = '0 0 2 * * ?';
        
        if (!apexClasses.contains('schedular_referencerequestaccount')) {
        
            try {
                Id rraSchedularId = System.Schedule('RefEdge_ReferenceRequestAccount Schedular', rrasch, rraSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_ReferenceRequestAccount Schedular" is already scheduled for execution.')) {
                    Id rraSchedularId = System.Schedule('RefEdge_ReferenceRequestAccount Schedular', rrasch, rraSchedularClass);
                }
            }
        }
        
        //  REF - 1223
        //ResetAccountRULAndSmartSearch Schedular
        Schedular_ResetAccountRULAndSmartSearch rarSchedularClass = new Schedular_ResetAccountRULAndSmartSearch();
        String rarsch = '0 20 2 * * ?';
        
        if (!apexClasses.contains('schedular_resetaccountrulandsmartsearch')) {
        
            try {
                Id rarSchedularId = System.Schedule('RefEdge_ResetAccountRULAndSmartSearch Schedular', rarsch, rarSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_ResetAccountRULAndSmartSearch Schedular" is already scheduled for execution.')) {
                    Id rarSchedularId = System.Schedule('RefEdge_ResetAccountRULAndSmartSearch Schedular', rarsch, rarSchedularClass);
                }
            }
        }
        
        //  REF - 1308
        //ReferenceContentReminder Schedular
        Schedular_ReferenceContentReminder refcrSchedularClass = new Schedular_ReferenceContentReminder();
        String refcrSch = '0 40 2 * * ?';
        
        if (!apexClasses.contains('Schedular_referencecontentreminder')) {
        
            try {
                Id refcrSchedularId = System.Schedule('RefEdge_ReferenceContentReminder Schedular', refcrSch, refcrSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_ReferenceContentReminder Schedular" is already scheduled for execution.')) {
                    Id refcrSchedularId = System.Schedule('RefEdge_ReferenceContentReminder Schedular', refcrSch, refcrSchedularClass);
                }
            }
        }
        
        //ResetRBIRewardsPoint Schedular
        Schedular_ResetRBIRewardsPoint rrrSchedularClass = new Schedular_ResetRBIRewardsPoint();
        String rrrsch = '0 0 3 * * ?';
        
        if (!apexClasses.contains('schedular_resetrbirewardspoint')) {
            try {
                Id rrrSchedularId = System.Schedule('RefEdge_ResetRBIRewardsPoint Schedular', rrrsch, rrrSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_ResetRBIRewardsPoint Schedular" is already scheduled for execution.')) {
                    Id rrrSchedularId = System.Schedule('RefEdge_ResetRBIRewardsPoint Schedular', rrrsch, rrrSchedularClass);
                }
            }
        }
        
        //SendRefYetNotification Schedular
        Schedular_SendRefYetNotification srynSchedularClass = new Schedular_SendRefYetNotification();
        String srynsch = '0 20 3 * * ?';
        
        if (!apexClasses.contains('schedular_sendrefyetnotification')) {
            try {
                Id srynSchedularId = System.Schedule('RefEdge_SendRefYetNotification Schedular', srynsch, srynSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_SendRefYetNotification Schedular" is already scheduled for execution.')) {
                    Id srynSchedularId = System.Schedule('RefEdge_SendRefYetNotification Schedular', srynsch, srynSchedularClass);
                }
            }
        }
        
        //MicrositeVisits Schedular
        Schedular_ResetRULSetting rrsSchedularClass = new Schedular_ResetRULSetting();
        String rrssch = '0 40 3 * * ?';
        
        if (!apexClasses.contains('schedular_resetrulsetting')) {
            try {
                Id rrsSchedularId = System.Schedule('RefEdge_MicrositeVisits Schedular', rrssch, rrsSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_MicrositeVisits Schedular" is already scheduled for execution.')) {
                    Id rrsSchedularId = System.Schedule('RefEdge_MicrositeVisits Schedular', rrssch, rrsSchedularClass);
                }
            }
        }
        
        //ReferenceRequestFeedback Schedular
        Scheduler_RefReqReminderAndFeedback srrfSchedularClass = new Scheduler_RefReqReminderAndFeedback();
        String srrfsch = '0 0 4 * * ?';
        
        if (!apexClasses.contains('scheduler_refreqreminderandfeedback')) {
            try {
                Id srrfSchedularId = System.Schedule('RefEdge_ReferenceRequestFeedback Schedular', srrfsch, srrfSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_ReferenceRequestFeedback Schedular" is already scheduled for execution.')) {
                    Id srrfSchedularId = System.Schedule('RefEdge_ReferenceRequestFeedback Schedular', srrfsch, srrfSchedularClass);
                }
            }
        }
        
        //ResetContactRUL Schedular
        Schedular_ResetContactRUL rcrSchedularClass = new Schedular_ResetContactRUL();
        String rcrsch = '0 20 4 * * ?';
        
        if (!apexClasses.contains('schedular_resetcontactrul')) {
            try {
                Id rcrSchedularId = System.Schedule('RefEdge_ResetContactRUL Schedular', rcrsch, rcrSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_ResetContactRUL Schedular" is already scheduled for execution.')) {
                    Id rcrSchedularId = System.Schedule('RefEdge_ResetContactRUL Schedular', rcrsch, rcrSchedularClass);
                }
            }
        }
        
        //OpportunityAttribute Schedular
        Schedular_OpportunityAttribute oppAttSchedularClass = new Schedular_OpportunityAttribute();
        String oppAttrsch = '0 40 4 * * ?';
        
        if (!apexClasses.contains('schedular_opportunityattribute')) {
            try {
                Id oppAttSchedularId = System.Schedule('RefEdge_OpportunityAttribute Schedular', oppAttrsch, oppAttSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_OpportunityAttribute Schedular" is already scheduled for execution.')) {
                    Id oppAttSchedularId = System.Schedule('RefEdge_OpportunityAttribute Schedular', oppAttrsch, oppAttSchedularClass);
                }
            }
        }
        
        //Advanced routing schedular
        Schedular_AdvRoutingBusinessGroup advRoutingSchedularClass = new Schedular_AdvRoutingBusinessGroup();
        String advRoutingrsch = '0 0 5 * * ?';
        
        if (!apexClasses.contains('schedular_advroutingbusinessgroup')) {
            try {
                Id advRoutingSchedularId = System.Schedule('RefEdge_AdvancedRouting Schedular', advRoutingrsch, advRoutingSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_AdvancedRouting Schedular" is already scheduled for execution.')) {
                    Id advRoutingSchedularId = System.Schedule('RefEdge_AdvancedRouting Schedular', advRoutingrsch, advRoutingSchedularClass);
                }
            }
        }
        
        //Advanced routing schedular
        Schedular_InactiveOwnersNotification inactiveOwnerNotiSchedularClass = new Schedular_InactiveOwnersNotification();
        String inactiveOwnerNotirsch = '0 20 5 ? * MON';
        
        if (!apexClasses.contains('schedular_inactiveownersnotification')) {
            try {
                Id inactiveOwnerNotiSchedularId = System.Schedule('RefEdge_InactiveOwnersNotification Schedular', inactiveOwnerNotirsch, inactiveOwnerNotiSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_InactiveOwnersNotification Schedular" is already scheduled for execution.')) {
                    Id inactiveOwnerNotiSchedularId = System.Schedule('RefEdge_InactiveOwnersNotification Schedular', inactiveOwnerNotirsch, inactiveOwnerNotiSchedularClass);
                }
            }
        }
        
        // Sync attributes for sObject Attribute Mappings
        Schedular_SyncTaxonomyAttributes syncTaxonomyAttsSchedularClass = new Schedular_SyncTaxonomyAttributes();
        String syncTaxonomyAttsSch = '0 40 5 * * ?';
        
        if (!apexClasses.contains('schedular_synctaxonomyattributes')) {
            try {
                Id syncTaxonomyAttsSchedularId = System.Schedule('RefEdge_SyncObjectMappingAttributes Schedular', syncTaxonomyAttsSch, syncTaxonomyAttsSchedularClass);
            } catch (Exception e) {
                
                if (!e.getMessage().contains('The Apex job named "RefEdge_SyncObjectMappingAttributes Schedular" is already scheduled for execution.')) {
                    Id syncTaxonomyAttsSchedularId = System.Schedule('RefEdge_SyncObjectMappingAttributes Schedular', syncTaxonomyAttsSch, syncTaxonomyAttsSchedularClass);
                }
            }
        }
    }
}