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
 * Class: Schedular_SendRefYetNotification
 * Description : This Batch called from Schedular_SendRefYetNotification to send initial notification for reference lead
 * Last Modified by: Gaurav Saini (21 Nov, 2017) for #959
 */
global with sharing class Batch_SendReferenceableYetNotification implements Database.Batchable<sObject>, Database.stateful, Database.AllowsCallouts {
    /**
     * Constants
     */
    private static String NO_RESPONSE_SUBJECT = 'Alert:  No Response to Reference Lead';
    private static String NO_RESPONSE_MESSAGE = 'Sorry, @REFOWNER has not responded to the request of update reference status. So it has been closed.\n';
    /**
     * Properties and variables
     */
    private String soqlQuery = '';
    private Date todayDate = Date.Today();
    private Custom_Settings__c cs;
    private static String LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.ReferenceByLead.getURL() + '?id=';
    private static String LINK_URL2 = URL.getSalesforceBaseUrl().toExternalForm() + '/';
    private List<Map<String, String>> messagesList = new List<Map<String, String>>();
	
    /**
     * Constructor
     */
    global Batch_SendReferenceableYetNotification() {
        soqlQuery = 'SELECT Id, Reference_Lead_Owner__c, Reference_Lead_Status__c, Initial_notification_date__c, '
        			+ 'No_Response_Date__c, Initial_notification_sent__c, Follow_up_date__c, Reference_Lead_Account__c, '
        			+ 'Reference_Lead_Account__r.Name, Reference_Lead_Opportunity__c, Reference_Lead_Opportunity__r.Name, '
        			+ 'Reference_Lead_Owner__r.Name, Reminder_Date__c, Reference_Lead_Owner__r.Email '
        			+ 'FROM Reference_Lead__c '
        			+ 'WHERE (Follow_up_date__c = :todayDate '
        				+ 'OR No_Response_Date__c = :todayDate '
        				+ 'OR Reminder_Date__c = :todayDate) '
    				+ 'AND Nomination__c = null '
    				+ 'AND Reference_Profile__c = null';
        cs = UtilityController.getCustomSettings();
    }
	
    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(soqlQuery);
    }
	
    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List<Reference_Lead__c> scope) {
        Set<String> referenceableAccounts = new Set<String>();
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        Set<String> nonReferenceableAccount = new Set<String>();
        List<sObject> postFeedItems = new List<sObject>();
        Set<String> accountIds = new Set<String>();
        List<Reference_Lead__c> updateRefLeads = new List<Reference_Lead__c>();
        // added for #959
        String prospectPageURL = URL.getSalesforceBaseUrl().toExternalForm() + Page.RefProspectorResponsePage.getURL();
        String headerDocId = '';
        String footerDocId = '';
        Data_Mapping__c initialNotification = new Data_Mapping__c();
        Data_Mapping__c initialMemberNotification = new Data_Mapping__c();
        Data_Mapping__c reminderNotification = new Data_Mapping__c();
        Data_Mapping__c reminderMemberNotification = new Data_Mapping__c();
        Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Initial_Notification_Email__c', UtilityController.appNamespace() + 'Initial_Notification_member_Email__c', UtilityController.appNamespace() + 'Ref_Lead_Reminder_Email__c', UtilityController.appNamespace() + 'Ref_Lead_Reminder_member_Email__c'};

        for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                    FROM Data_Mapping__c
                                    WHERE Object__c = 'Notification'
                                    AND (Field_API_Name__c IN :notificationFieldNames
                                        OR Section_Name__c = 'email header doc'
                                        OR Section_Name__c = 'email footer doc')]) {

            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Initial_Notification_Email__c') {
                initialNotification = dm;
            } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Initial_Notification_member_Email__c') {
                initialMemberNotification = dm;
            } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Ref_Lead_Reminder_Email__c') {
                reminderNotification = dm;
            } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Ref_Lead_Reminder_member_Email__c') {
                reminderMemberNotification = dm;
            } else if (dm.Section_Name__c == 'email header doc') {
                headerDocId = dm.Field_API_Name__c;
            } else if (dm.Section_Name__c == 'email footer doc') {
                footerDocId = dm.Field_API_Name__c;
            }
        }
        
        for (Reference_Lead__c rl : scope) {
        	accountIds.add(rl.Reference_Lead_Account__c);
        }
		
        for (Reference_Basic_Information__c rbi : [SELECT Account__c, Is_Referenceable__c
    												FROM Reference_Basic_Information__c
    												WHERE Account__c IN :accountIds
    												AND Contact__c = null]) {
        	
            if (rbi.Is_Referenceable__c) {
                referenceableAccounts.add(rbi.Account__c);
            }
        }
		
        for (String str : accountIds) {
        	
            if (!referenceableAccounts.contains(str)) {
                nonReferenceableAccount.add(str);
            }
        }  																
        RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
		Map<Id,String> userToMail = new Map<Id,String>();
        Map<Id, String> userEmailMap = new Map<Id, String>();
        
        for (Reference_Lead__c rl : scope) {
        	
        	// existing process - for Reference Leads created from the reference lead finder functionality
        	if (rl.Reference_Lead_Opportunity__c != null) {
        		
	            // if follow up/reminder date is today's date then the intitial/reminder notification is sent
	            if ((rl.Follow_up_date__c == todayDate || rl.Reminder_Date__c == todayDate)
	            		&& rl.No_Response_date__c != todayDate && rl.Reference_Lead_Status__c != 'No response') {
                    String body = '';
                    String subject = '';
	                
                    if (rl.Reminder_Date__c == todayDate && referenceableAccounts.contains(rl.Reference_Lead_Account__c)) {
                        subject = reminderMemberNotification.Section_Name__c.replace('[Opportunity Account]', rl.Reference_Lead_Account__r.Name);
                        body = reminderMemberNotification.DC_Message__c;
                    } else if (rl.Reminder_Date__c == todayDate && !referenceableAccounts.contains(rl.Reference_Lead_Account__c)) {
                        subject = reminderNotification.Section_Name__c.replace('[Opportunity Account]', rl.Reference_Lead_Account__r.Name);
                        body = reminderNotification.DC_Message__c;
                    } else if (rl.Reminder_Date__c != todayDate && referenceableAccounts.contains(rl.Reference_Lead_Account__c)) {
                        subject = initialMemberNotification.Section_Name__c.replace('[Opportunity Account]', rl.Reference_Lead_Account__r.Name);
                        body = initialMemberNotification.DC_Message__c;
                    } else if (rl.Reminder_Date__c != todayDate && !referenceableAccounts.contains(rl.Reference_Lead_Account__c)) {
                        subject = initialNotification.Section_Name__c.replace('[Opportunity Account]', rl.Reference_Lead_Account__r.Name);
                        body = initialNotification.DC_Message__c;
                    }
                    body = body.replace('[Opportunity Account]', rl.Reference_Lead_Account__r.Name)
                                .replace('[Opportunity Name]', rl.Reference_Lead_Opportunity__c != null ? rl.Reference_Lead_Opportunity__r.Name : '');
	                
	                if ((cs.Initial_Notification_Chatter__c && rl.Reminder_Date__c != todayDate && !referenceableAccounts.contains(rl.Reference_Lead_Account__c))
                            || (cs.Initial_Notification_member_Chatter__c && rl.Reminder_Date__c != todayDate && referenceableAccounts.contains(rl.Reference_Lead_Account__c))
                            || (cs.Ref_Lead_Reminder_Chatter__c && rl.Reminder_Date__c == todayDate && !referenceableAccounts.contains(rl.Reference_Lead_Account__c))
                            || (cs.Ref_Lead_Reminder_member_Chatter__c && rl.Reminder_Date__c == todayDate && referenceableAccounts.contains(rl.Reference_Lead_Account__c))) {
	                	// ReferenceEdge user is used as sender regarding #486
	                    postFeedItems.add(MailChatterController.preparePostForRefedgeUser(subject, rl.Reference_Lead_Owner__c,
	                    																	body, LINK_URL + rl.Id,
	                    																	protectedAppConfig.User_Id__c));
	                }
	                
	                if ((cs.Initial_Notification_Email__c && rl.Reminder_Date__c != todayDate && !referenceableAccounts.contains(rl.Reference_Lead_Account__c))
                            || (cs.Initial_Notification_member_Email__c && rl.Reminder_Date__c != todayDate && referenceableAccounts.contains(rl.Reference_Lead_Account__c))
                            || (cs.Ref_Lead_Reminder_Email__c && rl.Reminder_Date__c == todayDate && !referenceableAccounts.contains(rl.Reference_Lead_Account__c))
                            || (cs.Ref_Lead_Reminder_member_Email__c && rl.Reminder_Date__c == todayDate && referenceableAccounts.contains(rl.Reference_Lead_Account__c))) {
	                	// ReferenceEdge user is used as sender regarding #486
	                    listmail.add(MailChatterController.prepareEmail(subject, rl.Reference_Lead_Owner__c, body + '\n\n' + subject
                                + ': <a href="' + LINK_URL + rl.Id + '">' + LINK_URL + rl.Id + '</a>', true, headerDocId, footerDocId));
	                }
	                
	                if (cs.Enable_Slack_Integration__c && ((cs.Initial_Notification_Slack__c && rl.Reminder_Date__c != todayDate && !referenceableAccounts.contains(rl.Reference_Lead_Account__c))
                            || (cs.Initial_Notification_member_Slack__c && rl.Reminder_Date__c != todayDate && referenceableAccounts.contains(rl.Reference_Lead_Account__c))
                            || (cs.Ref_Lead_Reminder_Slack__c && rl.Reminder_Date__c == todayDate && !referenceableAccounts.contains(rl.Reference_Lead_Account__c))
                            || (cs.Ref_Lead_Reminder_member_Slack__c && rl.Reminder_Date__c == todayDate && referenceableAccounts.contains(rl.Reference_Lead_Account__c)))) {
	                	Map<String, String> tempReqBodyMap = new Map<String, String>();
                        tempReqBodyMap.put('userEmail', rl.Reference_Lead_Owner__r.Email);
                        tempReqBodyMap.put('text', body + '\n<' + LINK_URL + rl.Id + '|' + subject + '>');
                        messagesList.add(tempReqBodyMap);
	                }
	                
	                if (rl.Reminder_Date__c == todayDate) {
	                    rl.Reference_Lead_Status__c = 'Reminder Sent';
	                } else {
	                    rl.Initial_notification_date__c = date.today();
	                    rl.Initial_notification_sent__c = true;
	                    rl.Reference_Lead_Status__c = 'Initial notification sent';
	                    rl.Ref_Lead_From_Opportunity__c = true;
	                }
	                updateRefLeads.add(rl);
	            }
	            // no response notification removed - Gaurav Saini (14 Dec, 2017) for #959
        	} else {	// new process - for Reference Leads created from the reference prospector functionality
        		
        		// if follow up/reminder date is today's date then the intitial/reminder notification is sent
	            if ((rl.Follow_up_date__c == todayDate || rl.Reminder_Date__c == todayDate)
	            		&& rl.No_Response_date__c != todayDate && rl.Reference_Lead_Status__c != 'No response') {
        			
	                if (rl.Reminder_Date__c == todayDate) {
	                    rl.Reference_Lead_Status__c = 'Reminder Sent';
	                } else {
	                    rl.Initial_Notification_date__c = date.today();
	                    rl.Initial_Notification_sent__c = true;
	                    rl.Reference_Lead_Status__c = 'Initial notification sent';
	                }
	                updateRefLeads.add(rl);
					
					if (!userToMail.containsKey(rl.Reference_Lead_Owner__c)) {
						String mailBody = rl.Reference_Lead_Owner__r.Name + ',\n\n'
        								+ (cs.Ref_Prospector_Body__c != null
        									? cs.Ref_Prospector_Body__c
        									: 'The customer reference team is always seeking new ways to showcase client success. Accounts including the ones below have been identified as owned by you and potential candidates for the customer reference program. Do you think they would act as a reference at this time?')
    									+ '\n\n' + 'Accounts requiring your review include:\n';
						userToMail.put(rl.Reference_Lead_Owner__c,mailBody);
					}
        			String mailBody = userToMail.get(rl.Reference_Lead_Owner__c) + '\n' + rl.Reference_Lead_Account__r.Name;
					userToMail.put(rl.Reference_Lead_Owner__c, mailBody);
                    userEmailMap.put(rl.Reference_Lead_Owner__c, rl.Reference_Lead_Owner__r.Email);
        		}
        	} 
        }

		for (Id userId : userToMail.keySet()) {
			String mailBody = userToMail.get(userId);
			postFeedItems.add(MailChatterController.preparePostForRefedgeUser((cs.Ref_Prospector_Subject__c != null
																					? cs.Ref_Prospector_Subject__c
																					: 'Potential Reference Accounts'),
																				userId,
																				mailBody,
																				prospectPageURL,
																				protectedAppConfig.User_Id__c));
			listmail.add(MailChatterController.prepareEmail((cs.Ref_Prospector_Subject__c != null
																? cs.Ref_Prospector_Subject__c
																: 'Potential Reference Accounts'),
															userId,
															mailBody + '\n\n' + prospectPageURL,
															true));
            Map<String, String> tempReqBodyMap = new Map<String, String>();
            tempReqBodyMap.put('userEmail', userEmailMap.get(userId));
            tempReqBodyMap.put('text', mailBody + '\n<' + prospectPageURL + '|'
                    + (cs.Ref_Prospector_Subject__c != null ? cs.Ref_Prospector_Subject__c : 'Potential Reference Accounts') + '>');
            messagesList.add(tempReqBodyMap);
		}
        
        if (updateRefLeads.size() > 0) {
            update updateRefLeads;
        }
        
        if (listmail.size() > 0) {
            Messaging.sendEmail(listmail);
        }
        
        if (postFeedItems.size() > 0) {
            Database.SaveResult[] postItems = database.insert(postFeedItems, false);
        }
    }
	
    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {
        Map<String, Object> slackReqBody = new Map<String, Object>();
        slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
        slackReqBody.put('orgId', UserInfo.getOrganizationId());

        if (messagesList != null && messagesList.size() > 0) {
            slackReqBody.put('messages', messagesList);
            UtilityController.postMsgToSlackSync(JSON.serialize(slackReqBody));
        }
    }
}