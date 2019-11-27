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
public with sharing class TestDataFactory {
    public static List < Date > dates;
    
    public static List<Data_Mapping__c> createCustomNotifications() {
        List<Data_Mapping__c> customNotificationsList = new List<Data_Mapping__c>();

        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Section_Name__c = 'email header doc',
                                                        Field_API_Name__c = 'test',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Section_Name__c = 'email footer doc',
                                                        Field_API_Name__c = 'test',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Request_Peer2Peer_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Request_Peer2Peer_Chatter__c',
                                                        Data_Collector_Name__c = UtilityController.appNamespace() + 'Request_Peer2Peer_Slack__c',
                                                        DC_Message__c = 'I would like to use an account as a reference for which you are the owner.\n'
                                                            + 'Here are the details:',
                                                        Default__c = 'Reference Account: [Requested Account]\n'
                                                            + 'Use Requested: [Request Type]\n'
                                                            + 'Need By: [Deadline]\n\n'
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
                                                            + 'Need By: [Deadline]\n\n'
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
                                                            + 'Phone: [Contact Phone]\n\n'
                                                            + 'Note: [Approve/Decline Notes]',
                                                        Section_Name__c = 'Reference Use Request [Disposition]',
                                                        Visible__c = true));
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
                                                        Visible__c = true));
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
                                                            + 'Owner: [Request Owner]',
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
                                                            + 'Owner: [Request Owner]',
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
                                                            + 'Need by: [Deadline]',
                                                        Section_Name__c = '[Project Owner] is now managing your Request',
                                                        Visible__c = true));
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
                                                        Visible__c = true));
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
                                                        DC_Message__c = 'The Opportunity [Opportunity Name] with [Opportunity Account] was a recent win for you. Congratulations! The customer reference team is always seeking new ways to showcase client success. Do you think [Opportunity Account] would act as a reference at this time?',
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
                                                        Default__c = 'Contact: [Contact Name\n]'
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
        ConstantsController.shouldDataMappingProcessed = true;
        insert customNotificationsList;
        return customNotificationsList;
    }

    /**
     * Method to create Accounts
     */
    public static List < Account > createAccounts(){
        list< Account> accountList = new list<Account>();
        accountList.add(new Account(Name='UCO Bank', Industry = 'Agricultures', AccountSource = 'Web'));
        accountList.add(new Account(Name='Polkomtel S.A.'));
        accountList.add(new Account(Name='Dover Corporation'));
        accountList.add(new Account(Name='Active Endpoints'));
        accountList.add(new Account(Name='Workday', AccountSource = 'Other'));
        accountList.add(new Account(Name='Oracle Corporation', Industry = 'Agricultures'));
        return accountList;
    }   
    /**
     * Method to create More Accounts
     */
    public static List < Account > createAccountsMore(){
        list< Account> accounts = new list<Account>();
        accounts.add(new Account(Name = 'Acc7'));
        accounts.add(new Account(Name = 'Acc8'));
        accounts.add(new Account(Name = 'Acc9'));
        accounts.add(new Account(Name = 'Acc10'));
        accounts.add(new Account(Name = 'Acc11'));
        accounts.add(new Account(Name = 'Acc12'));
        accounts.add(new Account(Name = 'Acc13'));
        accounts.add(new Account(Name = 'Acc14'));
        accounts.add(new Account(Name = 'Acc15'));
        accounts.add(new Account(Name = 'Acc16'));
        accounts.add(new Account(Name = 'Acc17'));
        accounts.add(new Account(Name = 'Acc18'));
        accounts.add(new Account(Name = 'Acc19'));
        accounts.add(new Account(Name = 'Acc20'));
        accounts.add(new Account(Name = 'Acc21'));
        accounts.add(new Account(Name = 'Acc22'));
        accounts.add(new Account(Name = 'Acc23'));
        accounts.add(new Account(Name = 'Acc24'));
        accounts.add(new Account(Name = 'Acc25'));
        accounts.add(new Account(Name = 'Acc26'));
        accounts.add(new Account(Name = 'Acc27'));
        accounts.add(new Account(Name = 'Acc28'));
        accounts.add(new Account(Name = 'Acc29'));
        accounts.add(new Account(Name = 'Acc30'));
        accounts.add(new Account(Name = 'Acc31'));
        accounts.add(new Account(Name = 'Acc32'));
        accounts.add(new Account(Name = 'Acc33'));
        accounts.add(new Account(Name = 'Acc27'));
        accounts.add(new Account(Name = 'Acc28'));
        accounts.add(new Account(Name = 'Acc29'));
        accounts.add(new Account(Name = 'Acc30'));
        accounts.add(new Account(Name = 'Acc31'));
        accounts.add(new Account(Name = 'Acc32'));
        accounts.add(new Account(Name = 'Acc33'));
        accounts.add(new Account(Name = 'Acc34'));
        accounts.add(new Account(Name = 'Acc35'));
        accounts.add(new Account(Name = 'Acc36'));
        accounts.add(new Account(Name = 'Acc37'));
        accounts.add(new Account(Name = 'Acc38'));
        accounts.add(new Account(Name = 'Acc39'));
        accounts.add(new Account(Name = 'Acc40'));
        accounts.add(new Account(Name = 'Acc41'));
        accounts.add(new Account(Name = 'Acc42'));
        accounts.add(new Account(Name = 'Acc43'));
        accounts.add(new Account(Name = 'Acc44'));
        accounts.add(new Account(Name = 'Acc45'));
        accounts.add(new Account(Name = 'Acc46'));
        accounts.add(new Account(Name = 'Acc47'));
        accounts.add(new Account(Name = 'Acc48'));
        accounts.add(new Account(Name = 'Acc49'));
        accounts.add(new Account(Name = 'Acc50'));
        accounts.add(new Account(Name = 'Acc51'));
        return accounts;
    }   
    /**
     * Method to create Account's Reference Profile
     */
    public static list<Reference_Basic_Information__c> setUpAccountRBI(list< Account> accountList){
        List<Reference_Basic_Information__c> RBIAccList = new list<Reference_Basic_Information__c>();
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accountList[0].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accountList[1].Id, Account_Level_RUL__c = true));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accountList[2].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accountList[3].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accountList[4].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accountList[5].Id));
        insert RBIAccList;
        return RBIAccList;
    }
    
    /**
     * Method to create Account's Reference Profile
     */
    public static list<Reference_Basic_Information__c> setUpAccountRBINew(list< Account> accountList){
        List<Reference_Basic_Information__c> RBIAccList = new list<Reference_Basic_Information__c>();
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accountList[0].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accountList[1].Id, Account_Level_RUL__c = true));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accountList[2].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accountList[3].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accountList[4].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = '', Is_Referenceable__c = false, Reference_Program_Candidate__c = true, Account__c = accountList[5].Id));
        insert RBIAccList;
        return RBIAccList;
    }
    /**
     * Method to create Account's Reference Profile
     */
    public static void setUpMoreAccountRBI(list< Account> accounts){
        List<Reference_Basic_Information__c> RBIAccList = new list<Reference_Basic_Information__c>();
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[6].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[7].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[8].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[9].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[10].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[11].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[12].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[13].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[14].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[15].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[16].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[17].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[18].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[19].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[20].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[21].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[22].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[23].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[24].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[25].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[26].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[27].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[28].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[29].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[30].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[31].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[32].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[33].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[34].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[35].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[36].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[37].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[38].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[39].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[40].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[41].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[42].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[43].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[44].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[45].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[46].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[47].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[48].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[49].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[50].Id));
        insert RBIAccList;
    }
    /**
     * Method to create Contacts
     */
    public static List < Contact > createContacts(list< Account> accountList) {
        list< Contact> contactList = new list<Contact>();
        contactList.add(new Contact(LeadSource = 'Partner',FirstName = 'Alon', LastName = 'Raz',AccountId = accountList[0].Id, Email = 'alon@test.test'));
        contactList.add(new Contact(LeadSource = 'Partner',FirstName = 'Alim', LastName = 'Khan',AccountId = accountList[1].Id, Email = 'alim@test.test'));
        contactList.add(new Contact(LeadSource = 'Partner',FirstName = 'Brad', LastName = 'Carroll',AccountId = accountList[2].Id, Email = 'brad@test.test'));
        contactList.add(new Contact(LeadSource = 'Partner',FirstName = 'Candace', LastName = 'Flynn',AccountId = accountList[3].Id, Email = 'candace@test.test'));
        contactList.add(new Contact(LeadSource = 'Partner',FirstName = 'Daniel', LastName = 'Freeman',AccountId = accountList[4].Id, Email = 'daniel@test.test'));
        contactList.add(new Contact(LeadSource = 'Partner',FirstName = 'David', LastName = 'DeRosa',AccountId = accountList[5].Id, Email = 'david@test.test'));
        return contactList;
    }
    /**
     * Method to create More Contacts
     */
    public static List < Contact > createContactsMore(Account account) {
        list< Contact> contacts = new list<Contact>();
        contacts.add(new Contact(FirstName = 'con6', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con7', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con8', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con9', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con10', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con11', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con12', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con13', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con14', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con15', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con16', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con17', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con18', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con19', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con20', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con21', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con22', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con23', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con24', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con25', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con26', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con27', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con28', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con29', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con30', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con31', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con32', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con33', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con34', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con35', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con36', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con37', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con38', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con39', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con40', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con41', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con42', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con43', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con44', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con45', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con46', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con47', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con48', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con49', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con50', LastName = 'test', AccountID = account.Id));
        contacts.add(new Contact(FirstName = 'con51', LastName = 'test', AccountID = account.Id));
        return contacts;
    }
    /**
     * Method to create Contact's Reference Profile
     */
    public static list<Reference_Basic_Information__c>  setUpContactRBI(list< Contact> contacts){
        List<Reference_Basic_Information__c> RBIAccList = new list<Reference_Basic_Information__c>();
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[0].AccountId, Contact__c =  contacts[0].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Caution', Is_Referenceable__c = true, Account__c = contacts[1].AccountId, Contact__c =  contacts[1].Id, RUL_Activities_will_do__c = 3, RUL_Period__c = 10));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[2].AccountId, Contact__c =  contacts[2].Id, RUL_Activities_will_do__c = 3, RUL_Period__c = 10));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[3].AccountId, Contact__c =  contacts[3].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[4].AccountId, Contact__c =  contacts[4].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[5].AccountId, Contact__c =  contacts[5].Id ));
        insert RBIAccList;
        return RBIAccList; 
    }
    
    /**
     * Method to create Contact's Reference Profile
     */
    public static void setUpMoreContactRBI(list< Contact> contacts){
        List<Reference_Basic_Information__c> RBIAccList = new list<Reference_Basic_Information__c>();
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[6].AccountId, Contact__c =  contacts[6].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[7].AccountId, Contact__c =  contacts[7].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[8].AccountId, Contact__c =  contacts[8].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[9].AccountId, Contact__c =  contacts[9].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[10].AccountId, Contact__c =  contacts[10].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[11].AccountId, Contact__c =  contacts[11].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[12].AccountId, Contact__c =  contacts[12].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[13].AccountId, Contact__c =  contacts[13].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[14].AccountId, Contact__c =  contacts[14].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[15].AccountId, Contact__c =  contacts[15].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[16].AccountId, Contact__c =  contacts[16].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[17].AccountId, Contact__c =  contacts[17].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[18].AccountId, Contact__c =  contacts[18].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[19].AccountId, Contact__c =  contacts[19].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[20].AccountId, Contact__c =  contacts[20].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[21].AccountId, Contact__c =  contacts[21].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[22].AccountId, Contact__c =  contacts[22].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[23].AccountId, Contact__c =  contacts[23].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[24].AccountId, Contact__c =  contacts[24].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[25].AccountId, Contact__c =  contacts[25].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[26].AccountId, Contact__c =  contacts[26].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[27].AccountId, Contact__c =  contacts[27].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[28].AccountId, Contact__c =  contacts[28].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[29].AccountId, Contact__c =  contacts[29].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[30].AccountId, Contact__c =  contacts[30].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[31].AccountId, Contact__c =  contacts[31].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[32].AccountId, Contact__c =  contacts[32].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[33].AccountId, Contact__c =  contacts[33].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[34].AccountId, Contact__c =  contacts[34].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[35].AccountId, Contact__c =  contacts[35].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[36].AccountId, Contact__c =  contacts[36].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[37].AccountId, Contact__c =  contacts[37].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[38].AccountId, Contact__c =  contacts[38].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[39].AccountId, Contact__c =  contacts[39].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[40].AccountId, Contact__c =  contacts[40].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[41].AccountId, Contact__c =  contacts[41].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[42].AccountId, Contact__c =  contacts[42].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[43].AccountId, Contact__c =  contacts[43].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[44].AccountId, Contact__c =  contacts[44].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[45].AccountId, Contact__c =  contacts[45].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[46].AccountId, Contact__c =  contacts[46].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[47].AccountId, Contact__c =  contacts[47].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[48].AccountId, Contact__c =  contacts[48].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[49].AccountId, Contact__c =  contacts[49].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[50].AccountId, Contact__c =  contacts[50].Id ));
        insert RBIAccList;
    }
    
    /**
     * Method to create Case
     */
    public static List < Case > createCases(list< Account> accounts) {
        List < Case > caseList = new List < Case > ();
        for(Account acc : accounts){
            caseList.add(new Case(Status = 'New',Origin = 'Email',Account = acc));
        }
        return caseList;
    }
    /**
     * Method to create Referenceability Type
     */
    public static List<Referenceability_Type__c> createReferenceabilityType() {
        list<Referenceability_Type__c> RFTypeList = new list<Referenceability_Type__c>();
        RFTypeList.add(new Referenceability_Type__c(Name = 'Analyst Call',Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true,min_lead_time_per_request_type__c = 10,max_accounts_per_request_type__c = 15,Reward_points__c = 100,Note__c = 'test notes', Sales_Point__c = 500 ));
        RFTypeList.add(new Referenceability_Type__c(Name = 'Logo Use',Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true,min_lead_time_per_request_type__c = 10,max_accounts_per_request_type__c = 15,Reward_points__c = 500));
        RFTypeList.add(new Referenceability_Type__c(Name = 'Reference Call',Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true,min_lead_time_per_request_type__c = 10,max_accounts_per_request_type__c = 15,Reward_points__c = 700));
        RFTypeList.add(new Referenceability_Type__c(Name = 'Case Study',Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true,min_lead_time_per_request_type__c = 10,max_accounts_per_request_type__c = 15,Reward_points__c = 800));
        RFTypeList.add(new Referenceability_Type__c(Name = 'Reference Interview',Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true,min_lead_time_per_request_type__c = 10,max_accounts_per_request_type__c = 15,Reward_points__c = 900));
         
        return RFTypeList;
    }
    
    /**
     * Method to create User reward Referenceability Type
     */
    public static List<Referenceability_Type__c> createUserRewardReferenceabilityType() {
        List<Referenceability_Type__c> RFTypeList = new List<Referenceability_Type__c>();
        RFTypeList.add(new Referenceability_Type__c(Name = 'Invitation to Co-Worker', Referenceability_code__c = ConstantsController.INVITATION_TO_CO_WORKER, Sales_Reward__c = true, Sales_Point__c = 2, Visible__c  = true));
        RFTypeList.add(new Referenceability_Type__c(Name = 'Invitation to Contact', Referenceability_code__c = ConstantsController.INVITATION_TO_CONTACT, Sales_Reward__c = true, Sales_Point__c = 20, Visible__c  = true));
        RFTypeList.add(new Referenceability_Type__c(Name = 'Nomination - Approved', Referenceability_code__c = ConstantsController.NOMINATION_APPROVED, Sales_Reward__c = true, Sales_Point__c = 50, Visible__c  = true));
        RFTypeList.add(new Referenceability_Type__c(Name = 'Nomination - Submitted', Referenceability_code__c = ConstantsController.NOMINATION_SUBMITTED,  Sales_Reward__c = true, Sales_Point__c = 5, Visible__c  = true));
        RFTypeList.add(new Referenceability_Type__c(Name = 'Profile Update', Referenceability_code__c = ConstantsController.PROFILE_UPDATE, Sales_Reward__c = true, Sales_Point__c = 100, Visible__c  = true));
        RFTypeList.add(new Referenceability_Type__c(Name = 'Reference Use Feedback', Referenceability_code__c = ConstantsController.Reference_Use_Feedback,  Sales_Reward__c = true, Sales_Point__c = 15, Visible__c  = true));
        RFTypeList.add(new Referenceability_Type__c(Name = 'Request', Referenceability_code__c = ConstantsController.REQUEST_SALES, Sales_Reward__c = true,  Sales_Point__c = 40, Visible__c  = true));
        RFTypeList.add(new Referenceability_Type__c(Name = 'RLF - Referred to New Owner', Referenceability_code__c = ConstantsController.RLF_REFERRED, Sales_Reward__c = true, Sales_Point__c = 8, Visible__c  = true));
        RFTypeList.add(new Referenceability_Type__c(Name = 'RLF - Response', Referenceability_code__c = ConstantsController.RLF_RESPONSE, Sales_Reward__c = true, Sales_Point__c = 80, Visible__c  = true));
        RFTypeList.add(new Referenceability_Type__c(Name = 'Record Reference Use', Referenceability_code__c = ConstantsController.REFERANCE_USE, Sales_Reward__c = true, Sales_Point__c = 50, Visible__c  = true));
        
        return RFTypeList;
    }
    
    /**
     * Method to create Labels
     */
    public static List < Label__c > createLabels(){
        list<Label__c> labels = new list<Label__c>();
        labels.add(new Label__c(Name = 'Operating System'));
        labels.add(new Label__c(Name = 'Coffee'));
        labels.add(new Label__c(Name = 'Color'));
        labels.add(new Label__c(Name = 'Operating System1'));
        labels.add(new Label__c(Name = 'Coffee1'));
        labels.add(new Label__c(Name = 'Color1'));
        labels.add(new Label__c(Name = 'Operating System2'));
        labels.add(new Label__c(Name = 'Coffee2'));
        labels.add(new Label__c(Name = 'Color2'));
        labels.add(new Label__c(Name = 'Operating System3'));
        labels.add(new Label__c(Name = 'Coffee3'));
        labels.add(new Label__c(Name = 'Color3'));
        labels.add(new Label__c(Name = 'Operating System4'));
        labels.add(new Label__c(Name = 'Coffee4'));
        labels.add(new Label__c(Name = 'Color4'));
        labels.add(new Label__c(Name = 'Operating System5'));
        labels.add(new Label__c(Name = 'Coffee5'));
        labels.add(new Label__c(Name = 'Color5'));
        return labels;
    }
    
    /**
     * Method to create User
     */
    public static User createUser() {
        Profile p = [select id from profile where name like '%System Admin%'];
        User u = new User(alias = 'jpusr', email = 'japnalocal@newtest.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles', FirstName = 'testing123', username = 'japnalocal@newtest.com');
        return u;
    }
    
    /**
     * Method to create User role
     */
    public static UserRole createUserRole() {
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        return r;
    }
    
    /**
     * Method to create User with role
     */
    public static User createUserWithRole(UserRole r) {
        Profile p = [select id from profile where name like '%System Admin%'];
        User u = new User(alias = 'roleusr', email = 'japnalocal@newtest.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing.role', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles', username = 'japnalocal@newtest.com.withrole',
            userroleid = r.id);
        return u;
    }
    
    /**
     * Method to create Community User Contact
     */
    public static User createCommunityUser(Contact c) {
        Profile p = [select id from profile where name like '%Customer Community User%'];
        User u = new User(alias = 'commusr', email = 'japnalocal@newtest.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing.community', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles', username = 'japnalocal@newtest.com.community',
            ContactId = c.Id);
        return u;
    }
    
    /**
     * Method to create Custom Setting
     */
    public static Custom_Settings__c createCustomSetting() {
        Custom_Settings__c testSettings = new Custom_Settings__c(
            Name = 'Test Setting', Current_Version__c = '1.50', Active_Version__c = true, Email_Enabled__c = true,
            Chatter_Enabled__c = true, Include_Weekends__c = true, Days_of_Week__c = 'Saturday;Sunday',Feedback_Message_Delay__c = 2,
            Minimum_Deadline__c = 4, Reminder_to_Owner__c = 3,Escalation_to_Owner_Manager__c = 2, No_Response__c = 1,
            RUL_Activities__c = 3, RUL_Period__c = 99, RUL_Period_Contact__c = 10,RUL_Activities_Contact__c = 1,Maximum_Expiration_Days__c = 14,
            Default_Expiration_Days__c = 7,Microsite_Visit_Email__c = true,Microsite_Visit_Chatter__c = true,
            Caution_deadline_window__c = 10, Critical_Deadline_window__c = 5, Default_Referenceablity_Status__c = 'Active',
            Number_of_request_accounts__c = 5,Nomination_disposition_window__c = 7,Automatically_Assign_Rewards__c = true,
            Enable_Reference_Refresh__c = true,Refresh_Wait_Days__c = 1,Reference_Update_Email__c = true,Reference_Update_Chatter__c = true,
            Request_Approval_Decline_Chatter__c = true, Request_Approval_Decline_Email__c = true,Request_Escalation_Chatter__c = true,
            Request_Escalation_Email__c = true,Request_Feedback_Email__c = true, Request_Feedback_Chatter__c = true,Request_No_Response_Chatter__c = true,
            Request_No_Response_Email__c = true,Request_Reminder_Chatter__c = true, Request_Reminder_Email__c = true,Check_back_in_Email__c = true,
            Check_back_in_Chatter__c = true,Opportunity_Closed_Won_Stage__c = 'Closed Won',Nomination_Chatter__c = true,Nomination_Email__c=true,
            Minimum_Opportunity_Size__c = 500,Client_Referenceability_check_days__c = 1,No_Response_days__c = 2,Reference_Lead_No_Response_Chatter__c = true,
            Reference_Lead_No_Response_Email__c = true,Minimum_Sales_Stage__c = 'Value Proposition',Auto_create_delete_Reference_Content__c = true,
            Process_Update_Email__c = true,Process_Update_Chatter__c= true,Status_Update_Chatter__c = true,Status_Update_Email__c = true,Project_Owner_Update_Chatter__c=true,
            Project_Owner_Update_Email__c = true,Request_Peer2Peer_Email__c = true,Request_Peer2Peer_Chatter__c = true,Request_Managed_Chatter__c = true,
            Request_Managed_Email__c = true,General_Notes__c = 'test general notes',Managed_Request_Opportunity_Threshold__c=500,Minimum_Opportunity_Size_OP__c = 500,
            Send_reminder_for_automatic__c = 5, Profile_Update_Reminder_Email__c = true, Profile_Update_Reminder_Chatter__c = true,PUM_No_Response_Days__c = 0,Adv_Rt_Acct_Team_Object__c='',
            Consider_No_longer_needed_a_use__c = false, Create_Reference_Profile__c = true,
            Import_Objects__c = 'Reference_Content__c',Enable_Custom_Data_Loader__c = true, Account_Stages__c = 'Needs Analysis,Qualification', Prompt_Message__c = 'Our Message',Content_Stages__c = 'Prospecting,Proposal/Price Quote,Value Proposition',
            Show_Matching_Reference_Accounts_link__c  = true, Show_Matching_Reference_Content_link__c = true, Enable_Reference_Prompt__c = true,
            Enable_Data_Collector__c = true, Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE, Escalate_On_Last_Reminder__c = true,
            Frequency_Of_Reminders__c = 2, Minimum_Opportunity_Size_DC__c = 500, Number_Of_Reminders_To_Be_Sent__c = 3, Opportunity_Closed_Stages__c = 'Closed Won',
            Slack_Team_Ids__c = 'test team id 1', Enable_Slack_Integration__c = true, Slack_Enabled__c = true, Request_Peer2Peer_Slack__c = true, Request_Managed_Slack__c = true,
            Large_Opportunity_Slack__c = true, Request_Approval_Decline_Slack__c = true, Approve_Decline_Confirmation_Slack__c = true, Project_Owner_Update_Slack__c = true,
            Status_Update_Slack__c = true, Managed_to_P2P_Owner_Slack__c = true, Managed_to_P2P_Requester_Slack__c = true, P2P_to_Managed_Slack__c = true, Nomination_Slack__c = true,
            Nomination_Accepted_Slack__c = true, Nomination_Rejected_Slack__c = true, Check_back_in_Slack__c = true, Ref_Lead_Owner_Update_Slack__c = true, Profile_Creation_from_Ref_Lead_Slack__c = true,
            Reference_Refresh_Update_Slack__c = true, Reference_Update_Slack__c = true, Profile_Update_Reminder_Slack__c = true, Profile_Created_Slack__c = true, Sales_Reward_Point_Slack__c = true
        );
        insert testSettings;
        return testSettings;
    }
    
    /**
    *   Method to create Form
    **/
    public static List<Data_Mapping__c> createDataCollectorForm() {
        List<Data_Mapping__c> dmList = new List<Data_Mapping__c>();
        dmList.add(new Data_Mapping__c(Field_API_Name__c = 'Header', Label__c = 'Sub Header', Section_Name__c = ConstantsController.DC_FORM_IDENTIFY, Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE));
        dmList.add(new Data_Mapping__c(Section_Name__c = ConstantsController.DC_MANAGER_ESCALATION, Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE));
        dmList.add(new Data_Mapping__c(Section_Name__c = ConstantsController.DC_INITIAL_NOTIFICATION, Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE));
        dmList.add(new Data_Mapping__c(Section_Name__c = ConstantsController.DC_REMINDER, Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE));
        dmList.add(new Data_Mapping__c(Section_Name__c = ConstantsController.DC_OWNER_ESCALATION, Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE));
        dmList.add(new Data_Mapping__c(Field_API_Name__c = 'Section', Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE, Section_Position__c = 0));
        dmList.add(new Data_Mapping__c(Field_API_Name__c = 'Name', Label__c = 'Name', Section_Name__c = 'TEXT', Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE, Order__c = 0, Section_Position__c = 0));
        dmList.add(new Data_Mapping__c(Section_Name__c = ConstantsController.DC_MANAGER_REVIEW, Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE));
        
        dmList.add(new Data_Mapping__c(Field_API_Name__c = 'Header', Label__c = 'Sub Header', Section_Name__c = ConstantsController.DC_FORM_IDENTIFY, Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE+'@#'));
        dmList.add(new Data_Mapping__c(Section_Name__c = ConstantsController.DC_MANAGER_ESCALATION, Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE+'@#'));
        dmList.add(new Data_Mapping__c(Section_Name__c = ConstantsController.DC_INITIAL_NOTIFICATION, Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE+'@#'));
        dmList.add(new Data_Mapping__c(Section_Name__c = ConstantsController.DC_REMINDER, Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE+'@#'));
        dmList.add(new Data_Mapping__c(Section_Name__c = ConstantsController.DC_OWNER_ESCALATION, Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE+'@#'));
        dmList.add(new Data_Mapping__c(Section_Name__c = ConstantsController.DC_CRP_TEAM_REVIEW, Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE+'@#'));
        dmList.add(new Data_Mapping__c(Field_API_Name__c = 'Section', Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE+'@#', Section_Position__c = 0));
        dmList.add(new Data_Mapping__c(Field_API_Name__c = 'Name', Label__c = 'Name', Section_Name__c = 'TEXT', Data_Collector_Name__c = ConstantsController.REFERENCE_CONTENT_TYPE+'@#', Order__c = 0, Section_Position__c = 0));
        
        ConstantsController.shouldDataMappingProcessed = true;
        insert dmList;
        return dmList;
    }
    
    /**
     * Method to create Attributes
     */
    public static List < Attribute__c > createAttribute(){
        List < Attribute__c > attributeList = new List < Attribute__c >();
        attributeList.add(new Attribute__c(Name = 'Root Attribute', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'ChromeBook', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'Windows 7', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'Root Attribute1', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'ChromeBook1', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'Windows 71', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'Root Attribute2', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'ChromeBook2', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'Windows 72', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'Root Attribute3', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'ChromeBook3', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'Windows 73', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'Root Attribute4', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'ChromeBook4', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'Windows 74', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'Root Attribute5', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'ChromeBook5', Parent__c = null, ParentIds__c = null));
        attributeList.add(new Attribute__c(Name = 'Windows 75', Parent__c = null, ParentIds__c = null));
        return attributeList;
    }
    
    /**
     * Method to create Attributes
     */
    public static List < Attribute__c > createChildAttributes(List < Attribute__c > attributes, Integer level, Integer noOfAttributes){
        List < Attribute__c > attributeList = new List < Attribute__c >();
        for(Attribute__c attribute : attributes){
            for(integer no = 1;no <= noOfAttributes;no++)
                attributeList.add(new Attribute__c(Name = attribute.Name+ ' child'+string.valueOF(level)+string.valueOF(no), Parent__c = attribute.id, ParentIds__c = null,Level__c = level));
        }
        return attributeList;
    }

    /**
     * Method to create Attributes
     */
    public static List<Reference_Note__c> createReferenceNoteReq(List<Unspecified_Request__c> unspecifiedReq, List<Reference_Request_Account__c> accountReq){
        List<Reference_Note__c> refNotes = new List<Reference_Note__c>();
        
        for(Unspecified_Request__c request : unspecifiedReq) {
            Reference_Note__c note = new Reference_Note__c(Unspecified_Request__c = request.Id, Note__c = 'Test Data', Reference_Request__c = request.Reference_Request__c);
            refNotes.add(note);
        }
        for(Reference_Request_Account__c request : accountReq) {
            Reference_Note__c note = new Reference_Note__c(Account_Request__c = request.Id, Note__c = 'Test Data', Reference_Request__c = request.Reference_Request__c);
            refNotes.add(note);
        }
        insert refNotes;
        return refNotes;
    }
    
    /**
     * Method to create Attributes
     */
    public static List < Attribute__c > createStageChildAttributes(List < Attribute__c > attributes, Integer level, Integer noOfAttributes){
        List < Attribute__c > attributeList = new List < Attribute__c >();
        for(Attribute__c attribute : attributes){
            for(integer no = 1;no <= noOfAttributes;no++)
                attributeList.add(new Attribute__c(Name = 'Closed Won', Parent__c = attribute.id, ParentIds__c = null,Level__c = level));
        }
        return attributeList;
    }
    
    /**
     * Method to create Account Attributes
     */
    public static list<Account_Attribute__c> createAccountAttributes(list< Account> accountList, List < Attribute__c > attributeList, Boolean Inheritable) {
        List < Account_Attribute__c > accAttLst = new List < Account_Attribute__c >();
        for(Account acc : accountList){
            for(Attribute__c att : attributeList){
                accAttLst.add(new Account_Attribute__c(Account__c = acc.Id, Attribute__c = att.Id,Inheritable__c = Inheritable));
            }
        }
        //accAttLst[0].Inheritable__c = Inheritable;
        insert accAttLst;
        return accAttLst;
    }
    
    /**
     * Method to create Reference Content
     */
    public static list<Reference_Content__c> createReferenceContent() {
        list<Reference_Content__c> referObjs = new list<Reference_Content__c>();
        referObjs.add(new Reference_Content__c(Language__c = 'English',title__c = 'Ref Content',  Content_Status__c = 'Active'));
        return  referObjs;
    }
    
    /**
     * Method to create Reference Content
     */
    public static list<Reference_Content__c> createMultipleReferenceContent() {
        list<Reference_Content__c> referObjs = new list<Reference_Content__c>();
        referObjs.add(new Reference_Content__c(Language__c = 'English',title__c = 'Ref Content',  Content_Status__c = 'Active'));
        referObjs.add(new Reference_Content__c(Language__c = 'English',title__c = 'Ref Content',  Content_Status__c = 'Active'));
        return  referObjs;
    }
    /**
     * Method to create Reference Contents list
     */
    public static List < Reference_Content__c > setUpContents(list<ContentVersion> nativeContents) {
        List < Reference_Content__c > ContentLst = new List < Reference_Content__c > ();
        ContentLst.add(new Reference_Content__c(Title__c = 'cont1', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = nativeContents[0].Id));
        ContentLst.add(new Reference_Content__c(Title__c = 'cont2', Content_Status__c = 'Active',  Language__c = 'English',Custom_Reference_Content__c = true, Content_ID__c = nativeContents[1].Id));
        ContentLst.add(new Reference_Content__c(Title__c = 'cont3', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = nativeContents[2].Id));
        ContentLst.add(new Reference_Content__c(Title__c = 'cont4', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = nativeContents[3].Id));
        ContentLst.add(new Reference_Content__c(Title__c = 'cont5', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = nativeContents[4].Id));
        ContentLst.add(new Reference_Content__c(Title__c = 'cont6', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = nativeContents[5].Id));
        return ContentLst;
    }
    /**
     * Method to create Account Reference Content
     */
    public static list < Account_Reference_Content__c > createAccountRefContents(list< Account> accounts, list<Reference_Content__c> refContents) {
        list < Account_Reference_Content__c > tempObj = new list < Account_Reference_Content__c > ();
        for(Account acc : accounts){
            for(Reference_Content__c refCon : refContents){
                tempObj.add(new Account_Reference_Content__c(Account__c = acc.Id, Reference_Content__c = refCon.Id));
            }
        }
        return tempObj;
    }
    
    /**
     * Method to create Contact Attributes
     */
    public static list<Contact_Attribute__c> createContactAttributes(list< Contact> contacts, List < Attribute__c > attributeList) {
        List < Contact_Attribute__c > conAttLst = new List < Contact_Attribute__c >();
        for(Contact con : contacts){
            for(Attribute__c att : attributeList){
                conAttLst.add(new Contact_Attribute__c(Contact__c = con.Id, Attribute__c = att.Id));
            }
        }
        insert conAttLst;
        return conAttLst;
    }
    
    /**
     * Method to create Content Attributes
     */
    public static List < Content_Attribute__c > createContentAttributes(list< Reference_Content__c> refContents, List < Attribute__c > attributeList) {
        List < Content_Attribute__c > conAttLst = new List < Content_Attribute__c >();
        for(Reference_Content__c refcon : refContents){
            for(Attribute__c att : attributeList){
                conAttLst.add(new Content_Attribute__c(Reference_Content__c = refcon.Id, Attribute__c = att.Id));
            }
        }
        insert conAttLst;
        return conAttLst;
    }
    
    /**
     * Method to create Attribute Label
     */
    public static void createAttributeLabels(list< Label__c> labels, List < Attribute__c > attributeList) {
        List < Attributes_Labels__c > attLabels = new List < Attributes_Labels__c >();
        integer index = 0;
        if(attributeList.size() > 0)
        for(Label__c label : labels){
            attLabels.add(new Attributes_Labels__c(Label__c = label.Id, Attribute__c = attributeList[index].Id));
            index++;
            if(index >= attributeList.size()){
                break;
            }
        }
        insert attLabels;
    } 
    
    /**
     * Method to create Attribute Mapping
     */
    public static list<Attribute_Mapping__c> createAttributeMapping(){
        list<Attribute_Mapping__c> attMapping=new list<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Account',Field__c = 'Industry', Attribute_Name__c = 'Test 1', Filter_Label_Name__c='Test 1',Field_Api_Name__c='Industry',Is_Related_Mapping__c = false,Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true,Inheritable__c = true));
        insert attMapping;
        return attMapping;
    }
    /**
     * Method to create Related Attribute Mapping
     */
    /*public static list<Attribute_Mapping__c> createRelatedAttributeMapping1(){ 
        list<Attribute_Mapping__c> attMapping=new list<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Account',Is_Related_Mapping__c = true,Attribute_Name__c = 'Mobile Phone',Field__c = 'Mobile Phone',Related_Object__c = 'Contact', Filter_Label_Name__c='Mobile Phone',Mapping_Type__c = 'Child Object',Child_RelationShipName__c = 'Contacts',RelationShip_Name__c = 'AccountId',Field_Api_Name__c='MobilePhone',Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Account',Is_Related_Mapping__c = true,Attribute_Name__c = 'Lead Source',Field__c = 'Lead Source',Related_Object__c = 'Contact', Filter_Label_Name__c='Lead Source',Mapping_Type__c = 'Child Object',Child_RelationShipName__c = 'Contacts',RelationShip_Name__c = 'AccountId',Field_Api_Name__c='LeadSource',Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Account',Is_Related_Mapping__c = true,Attribute_Name__c = 'Account Source',Field__c = 'Account Source',Related_Object__c = 'Contact', Filter_Label_Name__c='Account Source',Mapping_Type__c = 'Child Object',Child_RelationShipName__c = 'Contacts',RelationShip_Name__c = 'AccountId',Field_Api_Name__c='AccountSource',Inheritable__c = true));
        insert attMapping;
        return attMapping;
    }*/
    /**
     * Method to create Related Attribute Mapping for Account
     */
    /*public static list<Attribute_Mapping__c> createRelatedAttributeMappingAccount1(){ 
        list<Attribute_Mapping__c> attMapping=new list<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Account',Is_Related_Mapping__c = true,Attribute_Name__c = 'Mobile Phone',Field__c = 'Mobile Phone',Related_Object__c = 'Contact', Filter_Label_Name__c='Mobile Phone',Mapping_Type__c = 'Child Object',Child_RelationShipName__c = 'Contacts',RelationShip_Name__c = 'AccountId',Field_Api_Name__c='MobilePhone',Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Contact',Is_Related_Mapping__c = true,Attribute_Name__c = 'Account Source',Field__c = 'Account Source',Related_Object__c = 'Account', Filter_Label_Name__c='Account Source',Mapping_Type__c = 'Parent Object',RelationShip_Name__c = 'AccountId',Field_Api_Name__c='AccountSource',Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Reference Content',Is_Related_Mapping__c = true,Attribute_Name__c = 'Last Name',Field__c = 'Last Name',Related_Object__c = 'User', Filter_Label_Name__c='Last Name',Mapping_Type__c = 'Parent Object',RelationShip_Name__c = 'OwnerId',Field_Api_Name__c='LastName',Inheritable__c = true));
        insert attMapping;
        return attMapping;
    }*/
    /**
     * Method to create Related Attribute Mapping
     */
    public static list<Attribute_Mapping__c> createRelatedAttributeMapping(){ 
        List<Attribute_Mapping__c> attMapping = new List<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Reference Profile', Is_Related_Mapping__c = true, Attribute_Name__c = 'Mobile Phone', Field__c = 'Mobile Phone', Related_Object__c = 'Contact', Filter_Label_Name__c='Mobile Phone', Mapping_Type__c = 'Parent Object', RelationShip_Name__c = UtilityController.appNamespace() + 'Contact__c', Field_Api_Name__c='MobilePhone', Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Reference Profile', Is_Related_Mapping__c = true, Attribute_Name__c = 'Lead Source', Field__c = 'Lead Source', Related_Object__c = 'Contact', Filter_Label_Name__c='Lead Source', Mapping_Type__c = 'Parent Object', RelationShip_Name__c = UtilityController.appNamespace() + 'Contact__c', Field_Api_Name__c='LeadSource', Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Reference Profile', Is_Related_Mapping__c = true, Attribute_Name__c = 'Account Source', Field__c = 'Account Source', Related_Object__c = 'Contact', Filter_Label_Name__c='Account Source', Mapping_Type__c = 'Parent Object', RelationShip_Name__c = UtilityController.appNamespace() + 'Contact__c', Field_Api_Name__c='AccountSource', Inheritable__c = true));
        insert attMapping;
        return attMapping;
    }
    /**
     * Method to create Related Attribute Mapping for Account
     */
    public static list<Attribute_Mapping__c> createRelatedAttributeMappingAccount(){ 
        List<Attribute_Mapping__c> attMapping = new List<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Reference Profile', Is_Related_Mapping__c = true, Attribute_Name__c = 'Mobile Phone', Field__c = 'Mobile Phone', Related_Object__c = 'Contact', Filter_Label_Name__c='Mobile Phone', Mapping_Type__c = 'Parent Object', RelationShip_Name__c = UtilityController.appNamespace() + 'Contact__c', Field_Api_Name__c='MobilePhone', Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Reference Profile', Is_Related_Mapping__c = true, Attribute_Name__c = 'Account Source', Field__c = 'Account Source', Related_Object__c = 'Account', Filter_Label_Name__c='Account Source', Mapping_Type__c = 'Parent Object', RelationShip_Name__c = UtilityController.appNamespace() + 'Account__c', Field_Api_Name__c='AccountSource', Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Reference Content', Is_Related_Mapping__c = true, Attribute_Name__c = 'Last Name', Field__c = 'Last Name', Related_Object__c = 'User', Filter_Label_Name__c='Last Name', Mapping_Type__c = 'Parent Object', RelationShip_Name__c = 'OwnerId', Field_Api_Name__c = 'LastName', Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Contact', Is_Related_Mapping__c = true, Attribute_Name__c = 'Email', Field__c = 'Email', Related_Object__c = 'User', Filter_Label_Name__c = 'Email', Mapping_Type__c = 'Parent Object', RelationShip_Name__c = 'OwnerId', Field_Api_Name__c = 'Email', Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Account', Is_Related_Mapping__c = true, Attribute_Name__c = 'Email', Field__c = 'Email', Related_Object__c = 'User', Filter_Label_Name__c = 'Email', Mapping_Type__c = 'Parent Object', RelationShip_Name__c = 'OwnerId', Field_Api_Name__c = 'Email', Inheritable__c = true));
        insert attMapping;
        return attMapping;
    }
    /**
     * Method to create Attribute Mapping
     */
    public static void createAccountRatingAttributeMapping(){
        list<Attribute_Mapping__c> attMapping=new list<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c ='Account', Inheritable__c = true, Filter_Label_Name__c = 'Rating', Field__c = 'Rating', Field_Api_Name__c = 'Rating', Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Attribute_Name__c = 'Rating',Is_Related_Mapping__c = false));
        insert attMapping;
    }
    
    /**
     * Method to create Contcat Attribute Mapping
     */
    public static list<Attribute_Mapping__c> createContactAttributeMapping(){
        list<Attribute_Mapping__c> attMapping=new list<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c ='Contact', Inheritable__c = true, Filter_Label_Name__c = 'LeadSource', Field__c = 'LeadSource', Field_Api_Name__c = 'LeadSource', Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Attribute_Name__c = 'LeadSource',Is_Related_Mapping__c = false));
        insert attMapping;
        return attMapping;
    }
    
    /**
     * Method to create Reference Content Attribute Mapping
     */
    public static list<Attribute_Mapping__c> createRefconAttributeMapping(){
        list<Attribute_Mapping__c> attMapping=new list<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c ='Reference Content', Inheritable__c = true, Filter_Label_Name__c = 'Language__c', Field__c = 'Language__c', Field_Api_Name__c = 'Language__c', Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Attribute_Name__c = 'Language__c',Is_Related_Mapping__c = false));
        insert attMapping;
        return attMapping;
    }
    
    /**
     * Method to create Opportunity Attribute Mapping
     */
    public static void createOpportunityAttributeMapping(){
        list<Attribute_Mapping__c> attMapping=new list<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c ='Opportunity', Filter_Label_Name__c = 'Stage', Field__c = 'StageName', Field_Api_Name__c = 'StageName', Attribute_Name__c = 'Stage', Auto_populate__c = true, Is_Related_Mapping__c = false));
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Opportunity',Field__c = 'Type', Attribute_Name__c = 'Type 1', Filter_Label_Name__c='Type 1',Field_Api_Name__c='Type', Is_Related_Mapping__c = false,Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true,Inheritable__c = false));
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Opportunity',Field__c = 'Product', Attribute_Name__c = 'Product', Filter_Label_Name__c='Product',Field_Api_Name__c='Product2', Is_Related_Mapping__c = true, Auto_populate__c = true, Child_RelationShipName__c = 'OpportunityLineItems', RelationShip_Name__c = 'OpportunityId', Mapping_Type__c = 'Child Object', Related_Object__c = 'OpportunityLineItem'));
        insert attMapping;
    }
    
    /**
     * Method to create Reference Requests
     */
    public static List < Reference_Request__c > createReferenceRequest() {
        List < Reference_Request__c > refReqList = new List < Reference_Request__c > ();
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'In Progress'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'Not Started'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'Not Started'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'Not Started'));
        return refReqList;
    }
    
    /**
     * Method to create Account Requests
     */
    public static List < Reference_Request_Account__c > createAccountRequests(list< Account> accountList, List < Reference_Request__c > refReqList, List < Referenceability_Type__c > refTypes) {
        dates = setUpDates();
        List < Reference_Request_Account__c > rrAccs = new List < Reference_Request_Account__c > ();
        integer index = 0;
        for(Reference_Request__c refReq : refReqList){
            for(Account acc : accountList){
                rrAccs.add(new Reference_Request_Account__c(Requester__c = UserInfo.getUserId(), Reference_Type_Needed__c = refTypes[index].Id, Activity_Date__c = system.today(), Reference_Request__c = refReq.Id, Deadline__c = dates[(index > 2 ? 1 : index)], Reference_Use__c = false, Account__c = acc.Id, Account_Request_Status__c = 'In Progress'));
                index++;
                if(index >= refTypes.size())
                index = 0;
            }
        }
        return rrAccs;
    }
    
    /**
     * Method to create Contact Requests
     */
    public static List < Reference_Request_Account_Contact__c > createContactRequests(list< Contact> contacts, List < Reference_Request_Account__c > accRequests, List < Referenceability_Type__c > refTypes) {
        dates = setUpDates();
        List < Reference_Request_Account_Contact__c > rrAccConts = new List < Reference_Request_Account_Contact__c > ();
        integer index = 0;
        for(Reference_Request_Account__c refReq : accRequests){
            for(Contact con : contacts){
                if(con.AccountId == refReq.Account__c){
                    rrAccConts.add(new Reference_Request_Account_Contact__c(Referenceability_Type__c = refTypes[index].Id, Reference_Request_Account__c = refReq.Id, Activity_Date__c = system.today(), Deadline__c = dates[(index > 2 ? 1 : index)], Contact__c = con.Id, Contact_Request_Status__c = 'In Progress'));
                    index++;
                    if(index >= refTypes.size())
                    index = 0;
                }
            }
        }
        return rrAccConts;
    }
    
    /**
     * Method to create Opportunity
     */
    public static List < Opportunity > createOpportunity(list< Account> accountList) {
        List < Opportunity > oppList = new List < Opportunity > ();
        for(Account acc : accountList){
            oppList.add(new Opportunity(Name = acc.Name+' Opportunity', AccountId = acc.Id, CloseDate = system.today(), StageName = 'Closed Won'));
        }
        return oppList;
    }
    
    /**
     * Method to create date
     */
    public static List < Date > setUpDates() {
        Date todayDate = system.today();
        List < Date > dateList = new List < Date > ();
        dateList.add(todayDate.addDays(3));
        dateList.add(todayDate.addDays(6));
        dateList.add(todayDate.addDays(13));
        return dateList;
    }
    
    /**
     * Method to create task
     */
    public static List < Task > createTask() {
        List < Task > taskList = new List < Task > ();
        taskList.add(new Task(Description = 'approve the referenceability request', Priority = ConstantsController.NORMAL, Status = 'In Progress'));
        return taskList;
    }
     /**
    * Method to Create Reference Refresh Records
    */
    public static list<Reference_Refresh__c> createRefRefreshRecords(list<Account> accounts,list<Reference_Basic_Information__c> RBIAccList){
        list<Reference_Refresh__c> tempList = new list<Reference_Refresh__c>();
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[0].Id,Reference_Profile__c = RBIAccList[0].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId()));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[1].Id,Reference_Profile__c = RBIAccList[1].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[2].Id,Reference_Profile__c = RBIAccList[2].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[3].Id,Reference_Profile__c = RBIAccList[3].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId()));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[4].Id,Reference_Profile__c = RBIAccList[4].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[5].Id,Reference_Profile__c = RBIAccList[5].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        insert tempList;
        return tempList;
    }
    /**
     * Method to create Reference Requests
     */
    public static List < Reference_Request__c > createMoreReferenceRequest() {
        List < Reference_Request__c > refReqList = new List < Reference_Request__c > ();
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'In Progress'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'In Progress'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'Not Started'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'Not Started'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'Not Started'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'Not Started'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'Not Started'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'Not Started'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'Not Started'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'Not Started'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'Not Started'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'Not Started'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'On Hold'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'Not Started'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'Not Started'));
        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Use__c = false, Reference_Request_Status__c = 'Not Started'));
        return refReqList;
    }
    
    /**
     * Method to create Unspecified Requests
     */
    public static List < Unspecified_Request__c > createUnspecifiedRequest(List < Reference_Request__c > refReqList, List < Referenceability_Type__c > refTypes) {
        dates = setUpDates();
        List < Unspecified_Request__c > unSepReq = new List < Unspecified_Request__c > ();
        integer index = 0;
        for(Reference_Request__c refReq : refReqList){
            unSepReq.add(new Unspecified_Request__c(Requester__c = UserInfo.getUserId(), Reference_Type_Needed__c = refTypes[index].Id, Reference_Request__c = refReq.Id, Deadline__c = dates[(index > 2 ? 1 : index)], Unspecified_Request_Status__c = 'In Progress'));
            index++;
            if(index >= refTypes.size())
            index = 0;
        }
        return unSepReq;
    }
    
    /**
     * Method to create Nomination
     */
    public static List < Nomination__c > createNominations(list< Account> accounts, list< Contact> contacts) {
        List < Nomination__c > nomis = new List < Nomination__c > ();
        for(Account acc : accounts){
            nomis.add(new Nomination__c(Account__c = acc.Id, Other_Info__c = 'test', Status__c = 'In Progress'));
        }
        for(Contact con : contacts){
            nomis.add(new Nomination__c(Account__c = con.AccountId, Contact__c = con.Id, Other_Info__c = 'test', Status__c = 'On Hold'));
        }
        for(Account acc : accounts){
            nomis.add(new Nomination__c(Account__c = acc.Id, Other_Info__c = 'test', Status__c = 'On Hold'));
        }
        for(Contact con : contacts){
            nomis.add(new Nomination__c(Account__c = con.AccountId, Contact__c = con.Id, Other_Info__c = 'test', Status__c = 'In Progress'));
        }
        return nomis;
    }
    
    /**
     * Method to create Hit List
     */
    public static list<Hit_List__c> createHitLists(){
        list<Hit_List__c> tempList = new list<Hit_List__c>();
        tempList.add(new Hit_List__c(note__c = 'test1'));
        tempList.add(new Hit_List__c(note__c = 'test2'));
        tempList.add(new Hit_List__c(note__c = 'test3'));
        return  tempList;
    }
    
    /**
     * Method to create Invitation
     */
    public static list<Invitation__c> createInvitation(List < Opportunity > opps){
        List < Invitation__c > invitation = new list<Invitation__c>();
        for(Opportunity  opp : opps){
            invitation.add(new Invitation__c(Opportunity__c = opp.Id,Name = 'Invitation '+System.now(), Invitation_Expiration__c = Date.Today().addDays(20), Start_Date__c = Date.Today()));
        }
        return invitation;
    }
    
    /**
     * Method to create Referenceability
     */
    public static List < Referenceability__c > createReferenceability(list< Account> accounts, list< Contact> contacts,List < Referenceability_Type__c > refTypes) {
        List < Referenceability__c > rftypesLst = new List < Referenceability__c > ();
        for(Account acc : accounts){
            for(Referenceability_Type__c refType : refTypes){
                rftypesLst.add(new Referenceability__c(Account__c = acc.Id, Referenceability_Type__c = refType.Id,Status__c = 'Approved', Verified__c = System.today()));
            }
        }
        for(Contact con : contacts){
            for(Referenceability_Type__c refType : refTypes){
                rftypesLst.add(new Referenceability__c(Contact__c = con.Id,Account__c = con.AccountId, Referenceability_Type__c = refType.Id,Status__c = 'Approved', Verified__c = System.today()));
            }
        }
        return rftypesLst;
    }
    
    /**
     * Method to create Rewards
     */
    public static List < Reward__c > createRewards(list< Account> accounts, list< Contact> contacts) {
        List < Reward__c > rewards = new List < Reward__c > ();
        for(Account acc : accounts){
            rewards.add(new Reward__c(Account__c = acc.Id, Transaction__c = ConstantsController.ISSUE, Amount__c = 100, Available_Points__c = 100));
        }
        for(Contact con : contacts){
            rewards.add(new Reward__c(Contact__c = con.Id, Account__c = con.AccountId, Transaction__c = ConstantsController.ISSUE, Amount__c = 100, Available_Points__c = 100));
        }
        return rewards;
    }
    
    /**
     * Method to create ContentVersion
     */
    public static ContentVersion createContentVersion(User u) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = createFile();
        cv.PathOnClient = 'text';
        cv.FirstPublishLocationId = u.Id;
        cv.Title = 'First Content Version';
        return cv;
    }
    
    /**
     * Method to create ContentVersion
     */
    public static ContentVersion createContentVersion1(User u) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = createFile();
        cv.PathOnClient = 'text';
        cv.Title = 'First Content Version';
        return cv;
    }
    
    /**
    * Method to create ContentVersions
    */
    public static List < ContentVersion > setUpNativeContents() {
        List < ContentVersion > ContentVersionLst = new List < ContentVersion > ();
        ContentVersionLst.add(new ContentVersion(Title = 'Content Version1', PathOnClient = 'text', VersionData = createFile()));
        ContentVersionLst.add(new ContentVersion(Title = 'Content Version2', PathOnClient = 'text', VersionData = createFile()));
        ContentVersionLst.add(new ContentVersion(Title = 'Content Version3', PathOnClient = 'text', VersionData = createFile()));
        ContentVersionLst.add(new ContentVersion(Title = 'Content Version4', PathOnClient = 'text', VersionData = createFile()));
        ContentVersionLst.add(new ContentVersion(Title = 'Content Version5', PathOnClient = 'text', VersionData = createFile()));
        ContentVersionLst.add(new ContentVersion(Title = 'Content Version6', PathOnClient = 'text', VersionData = createFile()));
        return ContentVersionLst;
    }
    /**
     * Method to create File
     */
    public static Blob createFile() {
        string file = 'Testing base 64 encode';
        Blob blobfile1 = Blob.valueOf(file);
        return blobfile1;
    }
    
    /**
     * Method to create Reference_Content_Type__c
     */
    public static Reference_Content_Type__c createContentType() {
        Reference_Content_Type__c crc= new Reference_Content_Type__c(Name__c = 'test', Active__c = true, Custom_Content_Type__c= true);
        return crc;
    }
    
    /**
     * Method to create Reference_Lead__c
     */
    public static List<Reference_Lead__c> createLeads(){
        List<Reference_Lead__c> refLeads = new List<Reference_Lead__c>();
        refLeads.add(new Reference_Lead__c(Reference_Lead_Owner__c = UserInfo.getUserId(),Initial_notification_date__c = system.today(), Initial_notification_sent__c = false,
                    Follow_up_date__c = system.today()));
        refLeads.add(new Reference_Lead__c(Reference_Lead_Owner__c = UserInfo.getUserId(),Initial_notification_date__c = system.today(), Initial_notification_sent__c = false,
                    Follow_up_date__c = system.today()));
        return refLeads;
    }
    
    /**
     * Method to create Reference_Content_Type__c
     */
    public Static list<Reference_Content_Type__c> createContentTypes(){
        list<Reference_Content_Type__c> tempList = new list<Reference_Content_Type__c>();
        tempList.add(new Reference_Content_Type__c(name__c = 'Test1', Active__c = true));
        tempList.add(new Reference_Content_Type__c(name__c = 'Test2', Active__c = true));
        tempList.add(new Reference_Content_Type__c(name__c = 'Test3', Active__c = true));
        insert tempList;
        return tempList;
    }
    
    /**
     * Method to create Interview_Question__c
     */
    public static List < Interview_Question__c > createInterviewQuestions() {
        List < Interview_Question__c > intrQueList = new List < Interview_Question__c >();
        intrQueList.add( new Interview_Question__c(Question__c = 'Test que1',Order__c = 1));
        insert intrQueList;
        return intrQueList;
    } 
    
    /**
     * Method to create Nomination Referenceability
     */
    public static List < Nomination_Referenceability__c > createNominationReferenceability(list< Referenceability_Type__c> refTypes, list < Nomination__c > nominations) {
        List < Nomination_Referenceability__c > nomirftypesLst = new List < Nomination_Referenceability__c > ();
        for(Nomination__c nomi : nominations){
            for(Referenceability_Type__c ref : refTypes){
                nomirftypesLst.add(new Nomination_Referenceability__c(Referenceability_Type__c = ref.Id, Nomination__c = nomi.Id));
            }
        }
        insert nomirftypesLst;
        return nomirftypesLst;
    }
    
    /**
     * Method to create Nomination Label
     */
    public static List < Nomination_Label__c > createNominationLabel(list< Label__c> labels, list < Nomination__c > nominations) {
        List < Nomination_Label__c > nomilabls = new List < Nomination_Label__c > ();
        for(Nomination__c nomi : nominations){
            for(Label__c label : labels){
                nomilabls.add(new Nomination_Label__c(Label__c = label.Id, Nomination__c = nomi.Id));
            }
        }
        insert nomilabls;
        return nomilabls;
    }
    
    /**
     * Method to create Nomination Label Attributes
     */
    public static List < Nomination_Label_Attribute__c > createNominationLabelAttributes(list< Attribute__c> attributes, list < Nomination_Label__c > nominationLabels) {
        List < Nomination_Label_Attribute__c > nomilablAtts = new List < Nomination_Label_Attribute__c > ();
        for(Nomination_Label__c nomi : nominationLabels){
            for(Attribute__c attribute : attributes){
                nomilablAtts.add(new Nomination_Label_Attribute__c(Attribute__c = attribute.Id, Nomination_Label__c = nomi.Id));
            }
        }
        insert nomilablAtts;
        return nomilablAtts;
    }
    
    /**
     * Method to create Content Collection
     */
    public static list < Content_Collection__c > createContentCollection() {
        List < Content_Collection__c > conCollections = new List < Content_Collection__c >();
        conCollections.add( new Content_Collection__c(Active__c = true,Collection__c = 'test Collection'));
        return conCollections;
    } 
    
    /**
     * Method to create Community Invite
     */
    public static list < Community_Invite__c > createCommunityInvite(list < Reference_Request_Account__c > rrAccList) {
        List < Community_Invite__c > communityInvite = new List < Community_Invite__c >();
        for(Reference_Request_Account__c rra : rrAccList){
            communityInvite.add( new Community_Invite__c(Referenceability_Type__c = rra.Reference_Type_Needed__c, 
                                                            Community_Participate_Deadline__c = date.today() + 2,
                                                            Community_Participate_Details__c = 'Test Details', 
                                                            Community_Participate_With__c = 'Test with',
                                                            Reference_Request__c = rra.Reference_Request__c,
                                                            Account__c = rra.Account__c
                                                            ));
        }
        return communityInvite;
    }
    
    /**
     * Method to create Reference_Interview__c
     */
    public static List < Reference_Interview__c > createReferenceInterview(list<Reference_Content__c> referObjects) {
        List < Reference_Interview__c > rrAIntList = new List < Reference_Interview__c > ();
        for(Reference_Content__c referObject : referObjects){
            rrAIntList.add(new Reference_Interview__c(Speaker_info__c  =  'Speaker '+referObject.title__c,Reference_Content__c = referObject.Id));
        }
        return rrAIntList;
    }
    public static list<Data_Mapping__c> createDataMappings(){
        List < Data_Mapping__c > dataMappings = new List < Data_Mapping__c > ();
        dataMappings.add(new Data_Mapping__c(Visible__c = true));
        dataMappings.add(new Data_Mapping__c(Visible__c = true));
        dataMappings.add(new Data_Mapping__c(Visible__c = true));
        dataMappings.add(new Data_Mapping__c(Visible__c = true));
        dataMappings.add(new Data_Mapping__c(Visible__c = true));
        dataMappings.add(new Data_Mapping__c(Visible__c = true));
        dataMappings.add(new Data_Mapping__c(Visible__c = true));
        dataMappings.add(new Data_Mapping__c(Visible__c = true));
        return dataMappings;
    }
    /**
     * Method to create Reference_Request_Field records
     */
    public static List < Reference_Request_Field__c > createRefReqFields() {
        List < Reference_Request_Field__c > refReqFieldList = new List < Reference_Request_Field__c > ();
        refReqFieldList.add(new Reference_Request_Field__c(Name = 'refField1', Field_API_Name__c = 'ref_Field1'));
        refReqFieldList.add(new Reference_Request_Field__c(Name = 'refField2', Field_API_Name__c = 'ref_Field2'));
        return refReqFieldList;
    }
    /**
     * Method to create Related Attribute Mapping with Parent object Mapping type and  Contact type
     */
    public static list<Attribute_Mapping__c> createRelatedAttributeMappingWithParentObjectContact(){ 
        list<Attribute_Mapping__c> attMapping=new list<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Contact',Is_Related_Mapping__c = true,Attribute_Name__c = 'Account Name',Field__c = 'Account Name',Related_Object__c = 'Account', Filter_Label_Name__c='Account Name',Mapping_Type__c = 'Parent Object',RelationShip_Name__c = 'AccountId',Field_Api_Name__c='Name',Inheritable__c = true));
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Contact',Is_Related_Mapping__c = true,Attribute_Name__c = 'Account Site',Field__c = 'Account Site',Related_Object__c = 'Account', Filter_Label_Name__c='Account Site',Mapping_Type__c = 'Parent Object',RelationShip_Name__c = 'AccountId',Field_Api_Name__c='Site',Inheritable__c = true));
        insert attMapping;
        return attMapping;
    }
     /**
     * Method to create Contcat Attribute Mapping
     */
    public static list<Attribute_Mapping__c> createRelatedContactAttributeMapping(){
        list<Attribute_Mapping__c> attMapping=new list<Attribute_Mapping__c>();
        attMapping.add(new Attribute_Mapping__c(Object__c ='Contact', Inheritable__c = true, Filter_Label_Name__c = 'LeadSource', Field__c = 'LeadSource', Field_Api_Name__c = 'LeadSource', Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Attribute_Name__c = 'LeadSource',Is_Related_Mapping__c = true));
        insert attMapping;
        return attMapping;
    }
    /**
     * Method to create Attribute Label
     */
    public static List < Attributes_Labels__c > setUpAttributeLabels(list< Label__c> labels, List < Attribute__c > attributeList) {
        List < Attributes_Labels__c > attLabels = new List < Attributes_Labels__c >();
        integer index = 0;
        if(attributeList.size() > 0)
        for(Label__c label : labels){
            attLabels.add(new Attributes_Labels__c(Label__c = label.Id, Attribute__c = attributeList[index].Id));
            index++;
            if(index >= attributeList.size()){
                break;
            }
        }
        insert attLabels;
        return attLabels;
    }

    /**
     * Method to create RefType Mapping
     */
    public static List<Reference_Type_Mapping__c> getReferenceTypeMapping(list< Label__c> labels, Referenceability_Type__c refType) {
        List<Reference_Type_Mapping__c> refTypeMapping = new List<Reference_Type_Mapping__c>();
        integer index = 0;
        for(Label__c label : labels){
            refTypeMapping.add(new Reference_Type_Mapping__c(Label__c = label.Id, Referenceability_Type__c = refType.Id, Visible__c = true,Order__c = index++));
        }
        return refTypeMapping;
    }
}