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
	* Class : Schedular_ReferenceRequestAccount
	* Description : This Batch is the result of consolidation of following batches :-
	1. Batch_ReferenceRequestReminder (Functionality :- To send reminder mail or post chatter)					
	2. Batch_ReferenceRequestEscalation (Functionality :- To send Escalation mail or post chatter)				 		 
	3. Batch_ReferenceRequestNoResponse (Functionality :- To update Reference Requests to set No response in status)
	* Created by : Rajneesh Raj @Jan/18/2017
*/
global with sharing class Batch_ReferenceRequestAccount extends RefEdgeEditionFeatures implements Database.Batchable <sObject> , Database.stateful, Database.AllowsCallouts {
    // REF-1223
	/**
	* Constants
	*/
    private static String APPROVE_DECLINE_TITLE = 'Approve/Decline';
    // subject of respective Mail (For Reminder, Escalation, NoResponse)
    private static String REMINDER_TO_OWNER_SUBJECT = 'Reference Request Reminder';
    private static String ESCALATION_TO_MANAGER_SUBJECT = 'Escalation:  Reference Account Request';
    private static String NO_RESPONSE_SUBJECT = 'Alert:  No Response to Reference Account Request';
    // Message of Mail (For Reminder, Escalation, NoResponse)
    private static String REMINDER_TO_OWNER_MESSAGE =
    'This is a friendly reminder that there is an outstanding reference use request for an account for which you are the owner.\n';
    private static String ESCALATION_TO_MANAGER_MESSAGE =
    'One of your team members, @REFOWNER, has a pending reference account request from @REQUESTOR that has not yet been approved or declined. Your assistance is needed to help resolve this unanswered request.\n';
    private static String NO_RESPONSE_MESSAGE =
    'Sorry, @REFOWNER has not responded to your reference account request. Please make alternative plans to meet this need.\n';
    // Link information
    private static String REMINDER_LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.SelectReferenceUseContactsSLDS.getURL() + '?id=';
    private static String ESCALATION_LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.SelectReferenceUseContactsSLDS.getURL() + '?id=';

	// added for REF-1802 - Gaurav Saini (2 Jul, 2018)
    private static String LINK_URL {
		get {
			if (LINK_URL == null) {
				String sfUrl = URL.getSalesforceBaseUrl().getHost().replace('salesforce', 'visual.force');
				String tempNamespace = UtilityController.appNamespace() != null && UtilityController.appNamespace() != ''
										? UtilityController.appNamespace().replace('__', '.') : 'c.';

				if (sfUrl.contains('.my.')) {
					Organization current = [SELECT IsSandbox, InstanceName FROM Organization LIMIT 1];
					String instanceName = current.InstanceName;
					String customDomain = current.IsSandbox ? sfUrl.split('.cs')[0] : sfUrl.split('.my.')[0];
					LINK_URL = 'https://' + customDomain + '--' + tempNamespace + instanceName.toLowerCase()
								+ '.visual.force.com' + Page.SelectReferenceUseContactsSLDS.getURL() + '?id=';
				} else {
					LINK_URL = 'https://' + tempNamespace + sfUrl + Page.SelectReferenceUseContactsSLDS.getURL() + '?id=';
				}
			}
			return LINK_URL;
		}
		set;
	}
    private List<String> listOfFailedRecords = new List<String>();
	private List<String> listOfExceptionInRecords = new List<String>();
	/**
		* Properties and variables
	*/
    // Check Chatter Setting for Reminder, Escalation, NoResponse
    private Boolean checkReminderChatterSetting;
    private Boolean checkEscalationChatterSetting;
    private Boolean checkNoResponseChatterSetting;
    // Check Email Setting for Reminder, Escalation, NoResponse
    private Boolean checkReminderEmailSetting;
    private Boolean checkEscalationEmailSetting;
    private Boolean checkNoResponseEmailSetting;
    private Boolean checkReminderSlackSetting;
    private Boolean checkEscalationSlackSetting;
    private Boolean checkNoResponseSlackSetting;
	
    private Boolean checkIncludeWeekends;
    private Set<String> setOffDays;
    private Integer reminderToOwnerDays;
    private Integer escalationToOwnerManagerDays;
    private Integer noResponseDays;
    private Date todayDate = Date.Today();
    private Map<String, User> mapUsers;
    private List<Map<String, String>> messagesList = new List<Map<String, String>>();
    private Custom_Settings__c cs = UtilityController.getCustomSettings();
    // Query for which batch will execute
    private String soqlQuery =
	'SELECT Id, Name, Requester__c, Request_Notes__c, Reference_Type_Needed__c, Reference_Request__c, Deadline__c, CreatedDate, Account__c, Task_ID__c, Approval_Status__c, '+
	'Approve_Deny_Notes__c, Reference_Owner__c, Reference_Owner__r.Name, Reference_Owner__r.Email, Reference_Owner__r.ManagerId, Account__r.OwnerId, Account__r.Name, Account_f__c, '+
	'Reference_Type_Needed__r.Name, Reference_Type_Needed_f__c, Is_Reminder_to_Owner__c, Is_Escalation_to_Owner_Manager__c, Is_No_Response__c, Requester__r.Name, Requester__r.Email '+
	'From Reference_Request_Account__c ' +
	'Where (Approval_Status__c = null OR Approval_Status__c = \'\') AND Is_No_Response__c = false AND  Reference_Use__c = false AND Process__c = \'Peer2Peer\' AND '+
	'Deadline__c >=: todayDate AND Reference_Owner__c != null';
    /**
		* Constructor
	*/
    global Batch_ReferenceRequestAccount() {
	
        if (!isBasic) {
            soqlQuery += ' ' +
			' AND (Account_Request_Status__c = \'Not Started\' OR Account_Request_Status__c = \'In Progress\' OR Account_Request_Status__c = \'On Hold\') ';
		}
	}
    
    /**
		* Method to get the data to be processed (START Block) 
	*/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        checkReminderChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Reminder_Chatter__c);
        checkEscalationChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Escalation_Chatter__c);
        checkNoResponseChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_No_Response_Chatter__c);
        checkReminderEmailSetting = cs.Request_Reminder_Email__c;
        checkEscalationEmailSetting = cs.Request_Escalation_Email__c;
        checkNoResponseEmailSetting = cs.Request_No_Response_Email__c;
        checkReminderSlackSetting = cs.Enable_Slack_Integration__c && cs.Request_Reminder_Slack__c;
        checkEscalationSlackSetting = cs.Enable_Slack_Integration__c && cs.Request_Escalation_Slack__c;
        checkNoResponseSlackSetting = cs.Enable_Slack_Integration__c && cs.Request_No_Response_Slack__c;
        checkIncludeWeekends = cs.Include_Weekends__c;
        
        if (checkIncludeWeekends) {
            setOffDays = new Set<String>();
            
            for (String str: cs.Days_of_Week__c.split(';')) {
                setOffDays.add(str);
			}
		}
        reminderToOwnerDays = (cs.Reminder_to_Owner__c == null ? 0 : Integer.valueOf(cs.Reminder_to_Owner__c));
        escalationToOwnerManagerDays = (cs.Escalation_to_Owner_Manager__c == null ? 0 : Integer.valueOf(cs.Escalation_to_Owner_Manager__c));
        noResponseDays = (cs.No_Response__c == null ? 0 : Integer.valueOf(cs.No_Response__c));
        return Database.getQueryLocator(soqlQuery);
	}
    
    /**
		* Method to execute the batch (EXECUTE Block)  
	*/
    global void execute(Database.BatchableContext BC, List<Reference_Request_Account__c> scope) {
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        List<sObject> postFeedItems = new List<sObject>();
        List<Reference_Request_Account__c> referReqAccounts = new List<Reference_Request_Account__c>();
        RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
        Set<Id> userIds = new Set<Id>();
        
        for (Reference_Request_Account__c rra: scope) {
        	
            if (rra.Reference_Owner__r.ManagerId != null) {
                userIds.add(rra.Reference_Owner__r.ManagerId);
			}
            
            if (rra.Reference_Owner__c != null) {
                userIds.add(rra.Reference_Owner__c);
            }

            if (rra.Requester__c != null) {
                userIds.add(rra.Requester__c);
            }
		}       
        mapUsers = new Map<String, User> ([SELECT Id, Email, Name, ManagerId FROM User WHERE ID IN: userIds LIMIT: limits.getLimitQueryRows()]);
        String headerDocId = '';
        String footerDocId = '';
        Data_Mapping__c reminderNotification = new Data_Mapping__c();
        Data_Mapping__c noResponseNotification = new Data_Mapping__c();
        Data_Mapping__c escalationNotification = new Data_Mapping__c();
        Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Request_Reminder_Email__c', UtilityController.appNamespace() + 'Request_Escalation_Email__c', UtilityController.appNamespace() + 'Request_No_Response_Email__c'};

        for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                    FROM Data_Mapping__c
                                    WHERE Object__c = 'Notification'
                                    AND (Field_API_Name__c IN :notificationFieldNames
                                        OR Section_Name__c = 'email header doc'
                                        OR Section_Name__c = 'email footer doc')]) {

            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Reminder_Email__c') {
                reminderNotification = dm;
            } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Request_No_Response_Email__c') {
                noResponseNotification = dm;
            } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Escalation_Email__c') {
                escalationNotification = dm;
            } else if (dm.Section_Name__c == 'email header doc') {
                headerDocId = dm.Field_API_Name__c;
            } else if (dm.Section_Name__c == 'email footer doc') {
                footerDocId = dm.Field_API_Name__c;
            }
        }
        
        for (Reference_Request_Account__c rra: scope) {
            DateTime reminderDeadLine = Datetime.NewInstance(rra.Deadline__c, Time.newInstance(0, 0, 0, 0));
            DateTime escalationDeadLine = Datetime.NewInstance(rra.Deadline__c, Time.newInstance(0, 0, 0, 0));
            DateTime noResponseDeadLine = Datetime.NewInstance(rra.Deadline__c, Time.newInstance(0, 0, 0, 0));
            
            //Check Weekend Days
            if (checkIncludeWeekends) {
                Integer totalDaysgoneReminder = 0;
                Integer totalDaysgoneEscalation = 0;
                Integer totalDaysgoneNoResponse = 0;
                
				if (reminderToOwnerDays != 0 && rra.Is_Reminder_to_Owner__c == false && rra.Is_Escalation_to_Owner_Manager__c == false) {
					
					while (true) {
						reminderDeadLine = reminderDeadLine - 1; 
						
						if (!setOffDays.contains(reminderDeadLine.format('EEEE'))) {
							totalDaysgoneReminder++;
							
							if (totalDaysgoneReminder == reminderToOwnerDays) {
								break;
							}
						}
					}
				}					
				
				if (escalationToOwnerManagerDays != 0 && rra.Is_Escalation_to_Owner_Manager__c == false && rra.Reference_Owner__r.ManagerId != null) {
			
					while (true) {
						escalationDeadLine = escalationDeadLine - 1;
						
						if (!setOffDays.contains(escalationDeadLine.format('EEEE'))) {
							totalDaysgoneEscalation++;
							
							if (totalDaysgoneEscalation == escalationToOwnerManagerDays) {
								break;
							}
						}
					}
				} 
				
				while (true) {
				
					if (noResponseDays == 0) {
						break;
					}                        
					noResponseDeadLine = noResponseDeadLine - 1;
					
					if (!setOffDays.contains(noResponseDeadLine.format('EEEE'))) {
						totalDaysgoneNoResponse++;
						
						if (totalDaysgoneNoResponse == noResponseDays) {
							break;
						}
					}
				}
					           
			} else {
            	
                if (reminderToOwnerDays != 0 ) {
                	reminderDeadLine = reminderDeadLine - reminderToOwnerDays;
				}
				
                if (escalationToOwnerManagerDays != 0) {
                	escalationDeadLine = escalationDeadLine - escalationToOwnerManagerDays;
				} 
				noResponseDeadLine = noResponseDeadLine - noResponseDays; 				                              
			}
            
            //  For reminder					
			try {
			
				if (reminderToOwnerDays != 0 && rra.Is_Reminder_to_Owner__c == false && rra.Is_Escalation_to_Owner_Manager__c == false) {
					
					//Reminder to owner						
					if ((todayDate).daysBetween(Date.newInstance(reminderDeadLine.year(), reminderDeadLine.month(), reminderDeadLine.day())) == 0) {
						String notificationBody = reminderNotification.DC_Message__c + '\n\n' + reminderNotification.Default__c;
                        notificationBody = notificationBody.replace('[Request Type]', rra.Reference_Type_Needed_f__c)
                                                            .replace('[Requested Account]', rra.Account_f__c)
                                                            .replace('[Request Notes]', UtilityController.checkValueOfString(rra.Request_Notes__c))
                                                            .replace('[Deadline]', rra.Deadline__c.format());

						if (checkReminderChatterSetting) {
							//ReferenceEdge user is used as sender regarding #486
							postFeedItems.add(MailChatterController.preparePostForRefedgeUser(reminderNotification.Section_Name__c.replace('[Requested Account]', rra.Account_f__c), rra.Reference_Owner__c, notificationBody, LINK_URL + rra.Id, protectedAppConfig.User_Id__c));
						}
						
						if (checkReminderEmailSetting) {
							Messaging.SingleEmailMessage email = MailChatterController.prepareEmail(reminderNotification.Section_Name__c.replace('[Requested Account]', rra.Account_f__c), rra.Reference_Owner__c,
							notificationBody + '\n\n' + reminderNotification.Section_Name__c + ': ' + '<a href="' + LINK_URL + rra.Id + '">' + LINK_URL + rra.Id + '</a>', true, headerDocId, footerDocId);
							listmail.add(email);
						}
						
						if (checkReminderSlackSetting) {
							Map<String, String> tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('userEmail', mapUsers.get(rra.Reference_Owner__c).Email);
                            tempReqBodyMap.put('text', notificationBody
                                    + '\n<' + LINK_URL + rra.Id + '|'
                                    + reminderNotification.Section_Name__c.replace('[Requested Account]', rra.Account_f__c) + '>');
                            messagesList.add(tempReqBodyMap);
						}
						rra.Is_Reminder_to_Owner__c = true;
					}
				}
			} catch (exception ex) {
				listOfExceptionInRecords.add('Exception at Line no. -  '+ ex.getLineNumber() +' : Error - '+ ex.getMessage() + ' : For Record - ' + rra.Id +'\n');
			}			      
			
            //  For escalation
			try {
			
				if (escalationToOwnerManagerDays != 0 && rra.Is_Escalation_to_Owner_Manager__c == false && rra.Reference_Owner__r.ManagerId != null) {
					
					//Escalation to owner Manager
					if ((Date.Today()).daysBetween(Date.newInstance(escalationDeadLine.year(), escalationDeadLine.month(), escalationDeadLine.day())) == 0) {
						String notificationBody = escalationNotification.DC_Message__c + '\n\n' + escalationNotification.Default__c;
                        notificationBody = notificationBody.replace('[Request Type]', rra.Reference_Type_Needed_f__c)
                                                            .replace('[Request Owner]', rra.Reference_Owner__r.Name)
                                                            .replace('[Requested Account]', rra.Account_f__c)
                                                            .replace('[Requester Name]', rra.Requester__r.Name)
                                                            .replace('[Request Notes]', UtilityController.checkValueOfString(rra.Request_Notes__c))
                                                            .replace('[Deadline]', rra.Deadline__c.format());

						if (checkEscalationChatterSetting) {
							//ReferenceEdge user is used as sender regarding #486
							postFeedItems.add(MailChatterController.preparePostForRefedgeUser(escalationNotification.Section_Name__c, rra.Reference_Owner__r.ManagerId, notificationBody,
							LINK_URL + rra.Id, protectedAppConfig.User_Id__c));
							//For Reference Owner also    
							postFeedItems.add(MailChatterController.preparePostForRefedgeUser(escalationNotification.Section_Name__c, rra.Reference_Owner__c, notificationBody,
							LINK_URL + rra.Id, protectedAppConfig.User_Id__c));
						}
						
						if (checkEscalationEmailSetting) {
							Messaging.SingleEmailMessage email = MailChatterController.prepareCCEmail(escalationNotification.Section_Name__c,
							mapUsers.get(rra.Reference_Owner__r.ManagerId).Email, rra.Requester__r.Email, notificationBody + '\n\n'
                                + escalationNotification.Section_Name__c + ': ' + '<a href="' + LINK_URL + rra.Id + '">' + LINK_URL + rra.Id + '</a>');
							listmail.add(email);
						}
						
						if (checkEscalationSlackSetting) {
							Map<String, String> tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('userEmail', mapUsers.get(rra.Reference_Owner__r.ManagerId).Email);
                            tempReqBodyMap.put('text', notificationBody
                                    + '\n<' + LINK_URL + rra.Id + '|'
                                    + escalationNotification.Section_Name__c + '>');
                            messagesList.add(tempReqBodyMap);

                            tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('userEmail', rra.Requester__r.Email);
                            tempReqBodyMap.put('text', notificationBody
                                    + '\n<' + LINK_URL + rra.Id + '|'
                                    + escalationNotification.Section_Name__c + '>');
                            messagesList.add(tempReqBodyMap);
						}
						rra.Is_Escalation_to_Owner_Manager__c = true;
					}
				}
			} catch (exception ex) {
				listOfExceptionInRecords.add('Exception at Line no. -  '+ ex.getLineNumber() +' : Error - '+ ex.getMessage() + ' : For Record - ' + rra.Id +'\n');
			}
			           
            //  For NoResponse
			try {
			
				//Reminder to owner
				if ((todayDate).daysBetween(Date.newInstance(noResponseDeadLine.year(), noResponseDeadLine.month(), noResponseDeadLine.day())) == 0) {
					String notificationBody = noResponseNotification.DC_Message__c + '\n\n' + noResponseNotification.Default__c;
                    notificationBody = notificationBody.replace('[Request Type]', rra.Reference_Type_Needed_f__c)
                                                    .replace('[Request Owner]', rra.Reference_Owner__r.Name)
                                                    .replace('[Requested Account]', rra.Account_f__c)
                                                    .replace('[Requester Name]', rra.Requester__r.Name)
                                                    .replace('[Request Notes]', UtilityController.checkValueOfString(rra.Request_Notes__c))
                                                    .replace('[Deadline]', rra.Deadline__c.format());

					if (checkNoResponseChatterSetting) {
						postFeedItems.add(MailChatterController.preparePostForRefedgeUser('', rra.Requester__c,
						                    notificationBody, '', protectedAppConfig.User_Id__c));
					}
					
					if (checkNoResponseEmailSetting) {
						Messaging.SingleEmailMessage email = MailChatterController.prepareEmail(noResponseNotification.Section_Name__c, rra.Requester__c,
						                notificationBody, true, headerDocId, footerDocId);
						listmail.add(email);
					}
					
					if (checkNoResponseSlackSetting) {
						Map<String, String> tempReqBodyMap = new Map<String, String>();
                        tempReqBodyMap.put('userEmail', mapUsers.get(rra.Requester__c).Email);
                        tempReqBodyMap.put('text', '*' + noResponseNotification.Section_Name__c + '*\n' + notificationBody);
                        messagesList.add(tempReqBodyMap);
					}
					rra.Is_No_Response__c = true;
					rra.Approval_Status__c = 'No Response';
					rra.Account_Request_Status__c = 'No Response';
				}
			} catch (exception ex) {
				listOfExceptionInRecords.add('Exception at Line no. -  '+ ex.getLineNumber() +' : Error - '+ ex.getMessage() + ' : For Record - ' + rra.Id +'\n');
			}			           
            referReqAccounts.add(rra);    
		}
        
        //Insert list of postFeedItems
        if (postFeedItems.size() > 0) {
            Database.SaveResult[] postItems = database.insert(postFeedItems, false);
            
            for (database.Saveresult sr: postItems) {
                
                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    listOfFailedRecords.add('FeedItem Error :' + err.getMessage());
				}
			}
		}
        
        //Update List of Reference request Account
        if (referReqAccounts.size() > 0) {
            Database.SaveResult[] requests = database.update(referReqAccounts, false);
            
            for (database.Saveresult sr: requests) {
                
                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    listOfFailedRecords.add('Account Request Update Error :' + err.getMessage());
				}
			}
		}
        
        if (listmail.size() > 0) {
            Messaging.sendEmail(listmail);
        }
	}
    
    /**
		* Method to be called after the execute (FINISH Block)
	*/
    global void finish(Database.BatchableContext BC) {
        Map<String, Object> slackReqBody = new Map<String, Object>();
        slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
        slackReqBody.put('orgId', UserInfo.getOrganizationId());
        //Send Error message
        UtilityController.sendEmailNotification(listOfFailedRecords, 'Failed Account Request batch');
		
		//Send Exception Email to RefEdge Team
		if (listOfExceptionInRecords.Size() > 0) {
			UtilityController.sendExceptionEmailNotification(listOfExceptionInRecords, 'Batch_ReferenceRequestAccount Having Exception : ' + listOfExceptionInRecords.size());
		}

        if (messagesList != null && messagesList.size() > 0) {
            slackReqBody.put('messages', messagesList);
            UtilityController.postMsgToSlackSync(JSON.serialize(slackReqBody));
        }
	}
}