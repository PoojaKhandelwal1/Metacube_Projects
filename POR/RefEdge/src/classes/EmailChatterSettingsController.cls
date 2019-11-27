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
 * VF Page: EmailChatterSettings.page
 * Description: Class to manage settings for notifications sent out for different processes
 * Modified by: Rekha @Feb 3 2017
 */
public with sharing class EmailChatterSettingsController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Custom_Settings__c cs { get; set; }
    public Boolean isEdit { get; set; }
    private String customSettingId;

    public List<Data_Mapping__c> customNotificationsList { get; set; }
    public Data_Mapping__c selectedNotification { get; set; }
    public Data_Mapping__c emailHeaderDoc { get; set; }
    public Data_Mapping__c emailFooterDoc { get; set; }
    public String selectedFieldApiName { get; set; }
    public Boolean isPreview { get; set; }
    public Boolean isChatter { get; set; }
    public Boolean isSlack { get; set; }
    public String modalTitle { get; set; }
    private Map<String, List<String>> mergeFieldsMap { get; set; }
    public List<String> selectedNotificationMergeFields { get; set; }
    
    /**
     * Constructor
     */
    public EmailChatterSettingsController() {
        selectedNotificationMergeFields = new List<String>();
        mergeFieldsMap = new Map<String, List<String>>();
        mergeFieldsMap.put('Request_Peer2Peer_Email__c', new List<String>{'[Requested Account]'});
        mergeFieldsMap.put('Request_Peer2Peer_Chatter__c', new List<String>{'[Requested Account]'});
        mergeFieldsMap.put('Request_Peer2Peer_Slack__c', new List<String>{'[Requested Account]'});
        mergeFieldsMap.put('Request_Managed_Email__c', new List<String>{'[Requested Account]'});
        mergeFieldsMap.put('Request_Managed_Chatter__c', new List<String>{'[Requested Account]'});
        mergeFieldsMap.put('Request_Managed_Slack__c', new List<String>{'[Requested Account]'});
        mergeFieldsMap.put('Request_Approval_Decline_Email__c', new List<String>{'[Disposition]', '[Request Type]'});
        mergeFieldsMap.put('Request_Approval_Decline_Chatter__c', new List<String>{'[Disposition]', '[Request Type]'});
        mergeFieldsMap.put('Request_Approval_Decline_Slack__c', new List<String>{'[Disposition]', '[Request Type]'});
        mergeFieldsMap.put('Request_No_Response_Email__c', new List<String>{'[Request Owner]'});
        mergeFieldsMap.put('Request_No_Response_Chatter__c', new List<String>{'[Request Owner]'});
        mergeFieldsMap.put('Request_No_Response_Slack__c', new List<String>{'[Request Owner]'});
        mergeFieldsMap.put('Approve_Decline_Confirmation_Email__c', new List<String>{'[Disposition]', '[You/Approver Name]', '[Requested Account]', '[Disposition Date]'});
        mergeFieldsMap.put('Approve_Decline_Confirmation_Chatter__c', new List<String>{'[Disposition]', '[You/Approver Name]', '[Requested Account]', '[Disposition Date]'});
        mergeFieldsMap.put('Approve_Decline_Confirmation_Slack__c', new List<String>{'[Disposition]', '[You/Approver Name]', '[Requested Account]', '[Disposition Date]'});
        mergeFieldsMap.put('Project_Owner_Update_Email__c', new List<String>{'[Project Owner]', '[Approve Deny Notes]'});
        mergeFieldsMap.put('Project_Owner_Update_Chatter__c', new List<String>{'[Project Owner]', '[Approve Deny Notes]'});
        mergeFieldsMap.put('Project_Owner_Update_Slack__c', new List<String>{'[Project Owner]', '[Approve Deny Notes]'});
        mergeFieldsMap.put('Managed_to_P2P_Owner_Email__c', new List<String>{'[Requested Account]'});
        mergeFieldsMap.put('Managed_to_P2P_Owner_Chatter__c', new List<String>{'[Requested Account]'});
        mergeFieldsMap.put('Managed_to_P2P_Owner_Slack__c', new List<String>{'[Requested Account]'});
        mergeFieldsMap.put('Large_Opportunity_Email__c', new List<String>{'[Opportunity Threshold Amount]'});
        mergeFieldsMap.put('Large_Opportunity_Chatter__c', new List<String>{'[Opportunity Threshold Amount]'});
        mergeFieldsMap.put('Large_Opportunity_Slack__c', new List<String>{'[Opportunity Threshold Amount]'});
        mergeFieldsMap.put('Nomination_Accepted_Email__c', new List<String>{'[Account/Contact Name]'});
        mergeFieldsMap.put('Nomination_Accepted_Chatter__c', new List<String>{'[Account/Contact Name]'});
        mergeFieldsMap.put('Nomination_Accepted_Slack__c', new List<String>{'[Account/Contact Name]'});
        mergeFieldsMap.put('Nomination_Rejected_Email__c', new List<String>{'[Account/Contact Name]'});
        mergeFieldsMap.put('Nomination_Rejected_Chatter__c', new List<String>{'[Account/Contact Name]'});
        mergeFieldsMap.put('Nomination_Rejected_Slack__c', new List<String>{'[Account/Contact Name]'});
        mergeFieldsMap.put('Initial_Notification_Email__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]'});
        mergeFieldsMap.put('Initial_Notification_Chatter__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]'});
        mergeFieldsMap.put('Initial_Notification_Slack__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]'});
        mergeFieldsMap.put('Initial_Notification_member_Email__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]'});
        mergeFieldsMap.put('Initial_Notification_member_Chatter__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]'});
        mergeFieldsMap.put('Initial_Notification_member_Slack__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]'});
        mergeFieldsMap.put('Ref_Lead_Reminder_Email__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]'});
        mergeFieldsMap.put('Ref_Lead_Reminder_Chatter__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]'});
        mergeFieldsMap.put('Ref_Lead_Reminder_Slack__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]'});
        mergeFieldsMap.put('Ref_Lead_Reminder_member_Email__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]'});
        mergeFieldsMap.put('Ref_Lead_Reminder_member_Chatter__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]'});
        mergeFieldsMap.put('Ref_Lead_Reminder_member_Slack__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]'});
        mergeFieldsMap.put('Check_back_in_Email__c', new List<String>{'[Opportunity Account]', '[Specified Timeframe]'});
        mergeFieldsMap.put('Check_back_in_Chatter__c', new List<String>{'[Opportunity Account]', '[Specified Timeframe]'});
        mergeFieldsMap.put('Check_back_in_Slack__c', new List<String>{'[Opportunity Account]', '[Specified Timeframe]'});
        mergeFieldsMap.put('Ref_Lead_Owner_Update_Email__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]', '[Opportunity Owner]'});
        mergeFieldsMap.put('Ref_Lead_Owner_Update_Chatter__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]', '[Opportunity Owner]'});
        mergeFieldsMap.put('Ref_Lead_Owner_Update_Slack__c', new List<String>{'[Opportunity Account]', '[Opportunity Name]', '[Opportunity Owner]'});
        mergeFieldsMap.put('Profile_Update_Reminder_Email__c', new List<String>{'[Send Reminder for Automatic]'});
        mergeFieldsMap.put('Profile_Update_Reminder_Chatter__c', new List<String>{'[Send Reminder for Automatic]'});
        mergeFieldsMap.put('Profile_Update_Reminder_Slack__c', new List<String>{'[Send Reminder for Automatic]'});
        mergeFieldsMap.put('User_Reward_Email_Summary__c', new List<String>{'[User First Name]'});
        mergeFieldsMap.put('User_Reward_Chatter_Summary__c', new List<String>{'[User First Name]'});
        mergeFieldsMap.put('User_Reward_Slack_Summary__c', new List<String>{'[User First Name]'});
        mergeFieldsMap.put('Sales_Reward_Point_Email__c', new List<String>{'[User First Name]', '[User Last Name]'});
        mergeFieldsMap.put('Sales_Reward_Point_Chatter__c', new List<String>{'[User First Name]', '[User Last Name]'});
        mergeFieldsMap.put('Sales_Reward_Point_Slack__c', new List<String>{'[User First Name]', '[User Last Name]'});
        customSettingId = apexPages.currentPage().getParameters().get('customSettingId');
        cs = UtilityController.getCustomSettings();
        isEdit = false;
        checkPermissions();
        getDataMappings();
    }

    public void getDataMappings() {
        customNotificationsList = [SELECT Id, Name, Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c,
                                    Default__c, Visible__c, Data_Collector_Name__c
                                    FROM Data_Mapping__c WHERE Object__c = 'Notification'
                                    LIMIT :Limits.getLimitQueryRows()];

        for (Data_Mapping__c dm : customNotificationsList) {

            if (dm.Section_Name__c == 'email header doc') {
                emailHeaderDoc = dm;
            } else if (dm.Section_Name__c == 'email footer doc') {
                emailFooterDoc = dm;
            }
        }
    }

    public PageReference setSelctedNotification() {

        for (Data_Mapping__c dm : customNotificationsList) {

            if (dm.Field_API_Name__c == UtilityController.appNamespace() + selectedFieldApiName
                    || dm.Label__c == UtilityController.appNamespace() + selectedFieldApiName
                    || dm.Data_Collector_Name__c == UtilityController.appNamespace() + selectedFieldApiName) {
                selectedNotification = dm;
            }
        }
        modalTitle = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Custom_Settings__c').getDescribe().fields.getMap().get(selectedFieldApiName).getDescribe().getLabel();
        modalTitle += isPreview ? ' Preview' : ' Manage';
        selectedNotificationMergeFields = mergeFieldsMap.containsKey(selectedFieldApiName) ? mergeFieldsMap.get(selectedFieldApiName) : new List<String>();
        return null;
    }

    public PageReference saveNotification() {
        
        if (checkPermissions()) {
            ConstantsController.shouldDataMappingProcessed = true;
            update selectedNotification;
        }
        PageReference returnPage = new PageReference(Page.EmailChatterSettings.getUrl() + '?customSettingId=' + cs.Id);
        returnPage.setRedirect(true);
        return returnPage;
    }
    
    public PageReference navigateToDCManagePage() {
        PageReference returnPage = new PageReference(Page.DataCollectorManagePage.getUrl() + '?customSettingId=' + cs.Id);
        returnPage.setRedirect(true);
        return returnPage;
    }

    public PageReference resetNotification() {
        
        if (checkPermissions()) {
            ConstantsController.shouldDataMappingProcessed = true;

            if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Peer2Peer_Email__c') {
                selectedNotification.Section_Name__c = 'Reference Request for [Requested Account]';
                selectedNotification.DC_Message__c = 'I would like to use an account as a reference for which you are the owner.\n'
                                                        + 'Here are the details:';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Managed_Email__c') {
                selectedNotification.Section_Name__c = 'Reference Request for [Requested Account]';
                selectedNotification.DC_Message__c = 'I need assistance from the Reference Program in securing a reference.\n'
                                                        + 'Here are the details:';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Large_Opportunity_Email__c') {
                selectedNotification.Section_Name__c = 'Reference Request, Large Opportunity';
                selectedNotification.DC_Message__c = 'A new request has been submitted. The opportunity associated to this request is greater than [Opportunity Threshold Amount] so this request has been switched from Peer2Peer to Managed.\nHere are the details:';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Approval_Decline_Email__c') {
                selectedNotification.Section_Name__c = 'Reference Use Request [Disposition]';
                selectedNotification.DC_Message__c = 'I have [Disposition] your reference use request for a [Request Type].\n'
                                                        + 'Here are the details:';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Reminder_Email__c') {
                selectedNotification.Section_Name__c = 'Reference Request Reminder';
                selectedNotification.DC_Message__c = 'This is a friendly reminder that there is an outstanding reference use request for an account for which you are the owner.\n'
                                                        + 'Here are the details:';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Escalation_Email__c') {
                selectedNotification.Section_Name__c = 'Escalation: Reference Account Request';
                selectedNotification.DC_Message__c = 'One of your team members has a pending reference account request that has not yet been approved or declined. Your assistance is needed to help resolve this unanswered request.\n'
                                                        + 'Here are the details:';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Request_No_Response_Email__c') {
                selectedNotification.Section_Name__c = 'ALERT: No Response to Reference Account Request';
                selectedNotification.DC_Message__c = 'Sorry, [Request Owner] has not responded to your reference account request. Please make alternative plans to meet this need.\n'
                                                        + 'Here are the details:';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Approve_Decline_Confirmation_Email__c') {
                selectedNotification.Section_Name__c = 'Confirmation of Reference [Disposition]';
                selectedNotification.DC_Message__c = 'You [Disposition] the request to use [Requested Account] as a reference on [Disposition Date].';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Project_Owner_Update_Email__c') {
                selectedNotification.Section_Name__c = '[Project Owner] is now managing your Request';
                selectedNotification.DC_Message__c = '[Approve Deny Notes]';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Status_Update_Email__c') {
                selectedNotification.Section_Name__c = 'Reference Request Update';
                selectedNotification.DC_Message__c = 'The status of your request has changed.';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Managed_to_P2P_Owner_Email__c') {
                selectedNotification.Section_Name__c = 'Reference Request for [Requested Account]';
                selectedNotification.DC_Message__c = 'I would like to use an account as a reference for which you are the owner.\nHere are the details:';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Managed_to_P2P_Requester_Email__c') {
                selectedNotification.Section_Name__c = 'Account match found for Reference Request';
                selectedNotification.DC_Message__c = 'We received your reference request and found a matching account. A request has been sent to the owner for a response, which will be sent to you directly.';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'P2P_to_Managed_Email__c') {
                selectedNotification.Section_Name__c = 'ALERT: Request now managed by the Reference Team';
                selectedNotification.DC_Message__c = 'The following reference request is now being managed by the Customer Reference Team.';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Feedback_Email__c') {
                selectedNotification.Section_Name__c = 'Provide Reference Use Feedback';
                selectedNotification.DC_Message__c = 'Could you please provide feedback on your recent reference use:';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Microsite_Visit_Email__c') {
                selectedNotification.Section_Name__c = 'You have new Microsite visits';
                selectedNotification.DC_Message__c = 'Microsite visits in the last 24 hours:';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Nomination_Email__c') {
                selectedNotification.Section_Name__c = 'New [Account/Contact] Nomination';
                selectedNotification.DC_Message__c = 'A new [Account/Contact] has been nominated to the Reference Program';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Nomination_Accepted_Email__c') {
                selectedNotification.Section_Name__c = '[Account/Contact Name] accepted into the Reference Program';
                selectedNotification.DC_Message__c = '[Account/Contact Name] has been accepted into the Reference Program. Thanks again for nominating them.';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Nomination_Rejected_Email__c') {
                selectedNotification.Section_Name__c = 'Nomination declined';
                selectedNotification.DC_Message__c = 'Thanks for nominating [Account/Contact Name] to the Reference Program.\nUnfortunately, at this time we’re unable to add them to the program.';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Initial_Notification_Email__c') {
                selectedNotification.Section_Name__c = '[Opportunity Account] referenceability';
                selectedNotification.DC_Message__c = 'The Opportunity [Opportunity Name] with [Opportunity Account] was a recent win for you. Congratulations! The customer reference team is always seeking new ways to showcase client success. Do you think [Opportunity Account] would act as a reference at this time?';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Initial_Notification_member_Email__c') {
                selectedNotification.Section_Name__c = '[Opportunity Account] referenceability';
                selectedNotification.DC_Message__c = 'The Opportunity [Opportunity Name] with [Opportunity Account] was a recent win for you. Congratulations! [Opportunity Account] is already a member of the reference program. As a result of this win, are there any new Contacts that should be added to the program?';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Ref_Lead_Reminder_Email__c') {
                selectedNotification.Section_Name__c = 'REMINDER: [Opportunity Account] referenceability';
                selectedNotification.DC_Message__c = 'REMINDER: The Opportunity [Opportunity Name] with [Opportunity Account] was a recent win for you. Congratulations! The customer reference team is always seeking new ways to showcase client success. Do you think [Opportunity Account] would act as a reference at this time?';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Ref_Lead_Reminder_member_Email__c') {
                selectedNotification.Section_Name__c = 'REMINDER: [Opportunity Account] referenceability';
                selectedNotification.DC_Message__c = 'REMINDER: The Opportunity [Opportunity Name] with [Opportunity Account] was a recent win for you. Congratulations! [Opportunity Account] is already a member of the reference program. As a result of this win, are there any new Contacts that should be added to the program?';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Check_back_in_Email__c') {
                selectedNotification.Section_Name__c = '[Opportunity Account] referenceability';
                selectedNotification.DC_Message__c = 'We\'ve noted that [Opportunity Account] may be willing to be a Reference and you\'re going to check with them. We\'ll check back with you in [Specified Timeframe]. Thanks again!';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Ref_Lead_Owner_Update_Email__c') {
                selectedNotification.Section_Name__c = '[Opportunity Account] referenceability';
                selectedNotification.DC_Message__c = 'The Opportunity [Opportunity Name] with [Opportunity Account] was a recent win for your colleague [Opportunity Owner]. [Opportunity Owner] indicated that you are responsible for the ongoing relationship with [Opportunity Account]. The customer reference team is always seeking new ways to showcase client success. Do you think [Opportunity Account] would act as a reference at this time?';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Profile_Creation_from_Ref_Lead_Email__c') {
                selectedNotification.Section_Name__c = 'Reference Profile Created';
                selectedNotification.DC_Message__c = 'A new Reference Profile has been created from a Reference Lead.';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Reference_Refresh_Update_Email__c') {
                selectedNotification.Section_Name__c = 'Review Profile Update(s)';
                selectedNotification.DC_Message__c = 'Updates have been made to the following Reference Profiles and are quarantined awaiting your review:';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Reference_Update_Email__c') {
                selectedNotification.Section_Name__c = 'Update Request: Reference Accounts';
                selectedNotification.DC_Message__c = 'It\'s that time again. Time to review the customer reference information related to your Accounts. Your knowledge of the Account is essential to accurate reference search results. Thank you for your attention!\n\nAccounts requiring your review include:';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Profile_Update_Reminder_Email__c') {
                selectedNotification.Section_Name__c = 'REMINDER: ReferenceEdge Profile Update notifications will be sent in [Send Reminder for Automatic] days.';
                selectedNotification.DC_Message__c = '';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Profile_Created_Email__c') {
                selectedNotification.Section_Name__c = 'Reference Profile Created';
                selectedNotification.DC_Message__c = 'A new Reference Profile has been created.';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'User_Reward_Email_Summary__c') {
                selectedNotification.Section_Name__c = 'Customer Reference activities that have earned you rewards';
                selectedNotification.DC_Message__c = '[User First Name],\n\nBelow is a summary of your customer reference activities that have earned you points.';
            } else if (selectedNotification.Field_API_Name__c == UtilityController.appNamespace() + 'Sales_Reward_Point_Email__c') {
                selectedNotification.Section_Name__c = 'You\'ve earned new points';
                selectedNotification.DC_Message__c = 'Hi [User First Name] [User Last Name],\n\nCongratulations, you just earned reward points:';
            }
            update selectedNotification;
        }
        PageReference returnPage = new PageReference(Page.EmailChatterSettings.getUrl() + '?customSettingId=' + cs.Id);
        returnPage.setRedirect(true);
        return returnPage;
    }

    public PageReference closeEditNotificationModal() {
        return null;
    }

    /**
     * Method to edit the notification setting
     */
    public PageReference editSettings() {
        isEdit = true;
        return null;
    }
    
    /**
     * Method to save the notification setting
     */
    public PageReference saveSettings() {
        
        if (checkPermissions()) {
	        
	        try {
	            //REF2349
   				ConstantsController.isFromEmailChatterSettings = true;
	            
	            if (cs.Chatter_Enabled__c) {
	                ConstantsController.enableAllChatter = false;
	            }
	            
	            if (cs.Email_Enabled__c) {
	            	ConstantsController.enableAllEmail = false;
	            }
	            
	            if (cs.Slack_Enabled__c) {
	            	ConstantsController.enableAllSlack = false;
	            }
	            update cs;
	            cs = UtilityController.getCustomSettings();
                ConstantsController.shouldDataMappingProcessed = true;
                List<Data_Mapping__c> templateImages = new List<Data_Mapping__c>();

                if (emailHeaderDoc.Label__c == null || String.valueOf(emailHeaderDoc.Label__c).trim() == '') {
                    emailHeaderDoc.Field_API_Name__c = null;
                }

                if (emailFooterDoc.Label__c == null || String.valueOf(emailFooterDoc.Label__c).trim() == '') {
                    emailFooterDoc.Field_API_Name__c = null;
                }
                templateImages.add(emailHeaderDoc);
                templateImages.add(emailFooterDoc);
                update templateImages;
                getDataMappings();
	        } catch (Exception e) {
	            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
	            Apexpages.addMessage(message);
	            return null;
	        }
        }
        isEdit = false;
        return null;
    }
    
    /**
     * Method to return Custom Setting 
     */
    public pageReference returnCustomSettings() {
        PageReference returnPage = new PageReference('/' + customSettingId);
        returnPage.setRedirect(true);
        return returnPage;
    }
    
    /**
     * Method to return Custom Setting 
     */
    public pageReference returnSettings() {
        cs = UtilityController.getCustomSettings();
        getDataMappings();
        isEdit = false;
        return null;
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
	
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
		fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c', new Set<String> { 
    									UtilityController.appNamespace() + 'Email_Enabled__c',
    									UtilityController.appNamespace() + 'Slack_Enabled__c',
    									UtilityController.appNamespace() + 'Chatter_Enabled__c' });
		fieldMap.put(UtilityController.appNamespace() + 'Data_Mapping__c', new Set<String> { 
    									UtilityController.appNamespace() + 'Section_Name__c',
    									UtilityController.appNamespace() + 'Field_API_Name__c',
    									UtilityController.appNamespace() + 'DC_Message__c' });
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
    
}