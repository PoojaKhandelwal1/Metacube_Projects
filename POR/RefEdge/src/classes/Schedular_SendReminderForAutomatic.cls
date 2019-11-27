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
public with sharing class Schedular_SendReminderForAutomatic implements Schedulable{
    private static String REMINDER_SUBJECT = 'REMINDER: ReferenceEdge Profile Update notifications will be sent in *** days.';
    
    /**
     * Execute Method of scheduler
     */
    public void execute(SchedulableContext sc) {
        List < Messaging.SingleEmailMessage > listmail = new List < Messaging.SingleEmailMessage > ();
        List < sObject > postFeedItems = new List < sObject > ();
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        
        if (cs.Send_reminder_for_automatic__c != null) {
            String headerDocId = '';
            String footerDocId = '';
            Data_Mapping__c reminderNotification = new Data_Mapping__c();
            Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Profile_Update_Reminder_Email__c'};

            for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                        FROM Data_Mapping__c
                                        WHERE Object__c = 'Notification'
                                        AND (Field_API_Name__c IN :notificationFieldNames
                                            OR Section_Name__c = 'email header doc'
                                            OR Section_Name__c = 'email footer doc')]) {
                if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Profile_Update_Reminder_Email__c') {
                    reminderNotification = dm;
                } else if (dm.Section_Name__c == 'email header doc') {
                    headerDocId = dm.Field_API_Name__c;
                } else if (dm.Section_Name__c == 'email footer doc') {
                    footerDocId = dm.Field_API_Name__c;
                }
            }
            Map<String, Object> slackReqBody = new Map<String, Object>();
            slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
            slackReqBody.put('orgId', UserInfo.getOrganizationId());
            List<Map<String, String>> messagesList = new List<Map<String, String>>();

	        REMINDER_SUBJECT = reminderNotification.Section_Name__c.replace('[Send Reminder for Automatic]', '' + cs.Send_reminder_for_automatic__c);
	        Datetime dt = (datetime.now()).addDays(Integer.valueOf(cs.Send_reminder_for_automatic__c));
	        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
	        Schema.DescribeSObjectResult r = Reference_Refresh__c.sObjectType.getDescribe();
	        String profileUpdateUrl = baseUrl + '/' + r.getKeyPrefix();
	        String minderSettingUrl = baseUrl + Page.ReferenceRefreshSettingsPage.getURL() + '?customSettingId=' + cs.Id;
	        
            String emailBody = reminderNotification.DC_Message__c != null && reminderNotification.DC_Message__c.trim() != ''
                                        ? reminderNotification.DC_Message__c + '\n\n' + reminderNotification.Default__c : reminderNotification.Default__c;
            emailBody = emailBody.replace('[Next Notification Date]', dt.format('EEE, MMMM d, yyyy'))
                                    .replace('[profile update minder settings]', '<a href="' + minderSettingUrl + '">profile update minder settings</a>')
                                    .replace('[Profile Updates]', '<a href="' + profileUpdateUrl + '">Profile Updates</a>');
            String postBody = reminderNotification.DC_Message__c != null && reminderNotification.DC_Message__c.trim() != ''
                                        ? reminderNotification.DC_Message__c + '\n\n' + reminderNotification.Default__c : reminderNotification.Default__c;
            postBody = postBody.replace('[Next Notification Date]', dt.format('EEE, MMMM d, yyyy'))
                                    .replace('[profile update minder settings]', minderSettingUrl)
                                    .replace('[Profile Updates]', profileUpdateUrl);
	        String slackMsgBody = reminderNotification.DC_Message__c != null && reminderNotification.DC_Message__c.trim() != ''
                                        ? reminderNotification.DC_Message__c + '\n\n' + reminderNotification.Default__c : reminderNotification.Default__c;
            slackMsgBody = slackMsgBody.replace('[Next Notification Date]', dt.format('EEE, MMMM d, yyyy'))
                                    .replace('[profile update minder settings]', '\n<' + minderSettingUrl + '|profile update minder settings>')
                                    .replace('[Profile Updates]', '\n<' + profileUpdateUrl + '|Profile Updates>');

	        //REF-1316- Added check for CRP team member should be active
	        for (User member :  UtilityController.getCustomerReferenceTeam()) {
	            String userId = member.Id;
	            
	            if (userId.startsWith('005')) {
		            
		            if (cs.Profile_Update_Reminder_Email__c) {
		                listmail.add(MailChatterController.prepareEmail(REMINDER_SUBJECT, userId, emailBody, false, headerDocId, footerDocId));
		            }
		            
		            if (cs.Profile_Update_Reminder_Chatter__c) {
		                postFeedItems.add(MailChatterController.preparePost('', userId, postBody, ''));
		            }
		            
		            if (cs.Enable_Slack_Integration__c && cs.Profile_Update_Reminder_Slack__c) {
		                Map<String, String> tempReqBodyMap = new Map<String, String>();
                        tempReqBodyMap.put('text', '*' + REMINDER_SUBJECT + '*\n' + slackMsgBody);
                        messagesList.add(tempReqBodyMap);
		            }
	            }           
	        }   
	        
	        if (postFeedItems.size() > 0) {
	            Database.SaveResult[] postItems = database.insert(postFeedItems, false);
            }
	        
	        if (listmail.size() > 0) {
	            Messaging.sendEmail(listmail);
            }

            if (messagesList != null && messagesList.size() > 0) {
            	slackReqBody.put('messages', messagesList);
            	UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
            }
        }
    }
}