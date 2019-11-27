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
 * Class: Scheduler_RefReqReminderAndFeedback
 * Description : This Batch called from Scheduler_RefReqReminderAndFeedback to send feedback mail or post chatter
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_ReferenceRequestFeedback implements Database.Batchable < sObject > , Database.stateful, Database.AllowsCallouts {
    /**
     * Constants
     */
    private static String PROVIDE_REFERENCE_FEEDBACK = 'Provide Reference Use Feedback';
    private static String LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.ReferenceUseFeedback.getURL() + '?id=';

    /**
     * Properties and variables
     */
    private List < Reference_Request_Account_Contact__c > referReqAccContacts;
    private set < String > setReferenceIds = new set < String > ();
    private Boolean checkChatterSetting;
    private Boolean checkEmailSetting;
    private Boolean checkSlackSetting;
    private Boolean checkIncludeWeekends;
    private set < String > setOffDays;
    private Integer feedbackMessageDelay;
    private Date todayDate = Date.Today();
    private Map<String, MailChatterController.EmailMessage> mapEmailstoSent;
    private List < Reference_Request_Account_Contact__c > updateRefReqAccContacts = new List < Reference_Request_Account_Contact__c > ();
    private Map < Id, Reference_Request__c > mapRefReqAcc;
    private List < sobject > postFeedItems = new List < sobject > ();
    private List < Task > listTask = new List < Task > ();
    private String soqlQuery =
        'SELECT Id, Name, Reference_Request_Account__r.Deadline__c, Reference_Request_Account__r.Requester__c, Is_Feedback_Notification_Send__c, ' +
        'Reference_Request_Account__r.Reference_Type_Needed__r.Name,Reference_Request_Account__r.Account__r.Name,Reference_Request_Account__r.Reference_Type_Needed_f__c,Reference_Request_Account__r.Account_f__c, Is_Feedback_Received__c, ' +
        'Reference_Request_Account__r.Reference_Request__c ' +
        'FROM Reference_Request_Account_Contact__c ' +
        'WHERE ((Reference_Request_Account__r.Account_Request_Status__c = \'Completed\' and Reference_Request_Account__r.Managed_Request__c = true)' +
        ' or Reference_Request_Account__r.Approval_Status__c = \'Approved\') and Reference_Use__c = false AND Is_Feedback_Notification_Send__c = false ' +
        'AND Reference_Request_Account__r.Deadline__c <: todayDate ';
    private String headerDocId = '';
    private String footerDocId = '';
    private List<Map<String, String>> messagesList = new List<Map<String, String>>();
    private Custom_Settings__c cs = UtilityController.getCustomSettings();

    /**
     * Constructor
     */
    global Batch_ReferenceRequestFeedback() {}

    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        mapEmailstoSent = new Map<String, MailChatterController.EmailMessage>();
        checkChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Feedback_Chatter__c);
        checkEmailSetting = cs.Request_Feedback_Email__c;
        checkSlackSetting = cs.Enable_Slack_Integration__c && cs.Request_Feedback_Slack__c;
        checkIncludeWeekends = cs.Include_Weekends__c;
        
        if (checkIncludeWeekends) {
            setOffDays = new set < String > ();
            
            for (String str: cs.Days_of_Week__c.split(';')) {
                setOffDays.add(str);
            }
        }
        feedbackMessageDelay = (cs.Feedback_Message_Delay__c == null ? 0 : Integer.valueOf(cs.Feedback_Message_Delay__c));
        return Database.getQueryLocator(soqlQuery);
    }

    /**
     * Method to execute the batch   
     */
    global void execute(Database.BatchableContext BC, List < Reference_Request_Account_Contact__c > scope) {
        
        if (feedbackMessageDelay != 0) {
            referReqAccContacts = new List < Reference_Request_Account_Contact__c > ();
            Data_Mapping__c feedbackNotification = new Data_Mapping__c();
            Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Request_Feedback_Email__c'};

            for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                        FROM Data_Mapping__c
                                        WHERE Object__c = 'Notification'
                                        AND (Field_API_Name__c IN :notificationFieldNames
                                            OR Section_Name__c = 'email header doc'
                                            OR Section_Name__c = 'email footer doc')]) {

                if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Feedback_Email__c') {
                    feedbackNotification = dm;
                } else if (dm.Section_Name__c == 'email header doc') {
                    headerDocId = dm.Field_API_Name__c;
                } else if (dm.Section_Name__c == 'email footer doc') {
                    footerDocId = dm.Field_API_Name__c;
                }
            }
            
            for (Reference_Request_Account_Contact__c rrac: scope) {
                DateTime deadline = Datetime.NewInstance(rrac.Reference_Request_Account__r.Deadline__c, Time.newInstance(0, 0, 0, 0));
                
                //Check Weekend Days
                if (checkIncludeWeekends) {
                    Integer totalDayscome = 0;
                    
                    while (true) {
                        deadline = deadline + 1;
                        
                        if (!setOffDays.contains(deadline.format('EEEE'))) {
                            totalDayscome++;
                            
                            if (totalDayscome == feedbackMessageDelay) {
                                break;
                            }
                        }
                    }
                } else {
                    deadline = deadline + feedbackMessageDelay;
                }
                
                //get the Reference Request Accounts contacts those feedback will be provided
                if ((Date.newInstance(deadline.year(), deadline.month(), deadline.day())).daysBetween(todayDate) == 0) {
                    referReqAccContacts.add(rrac);
                    setReferenceIds.add(rrac.Reference_Request_Account__r.Reference_Request__c);
                }
            }
            mapRefReqAcc = new Map < Id, Reference_Request__c > ([SELECT Opportunity__c, Name, Id, Opportunity__r.AccountId, Opportunity__r.Account.Name FROM Reference_Request__c WHERE Id IN:
                setReferenceIds
            ]);
            RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
            Map<Id, String> userEmailMap = new Map<Id, String>();
            
            for (Reference_Request_Account_Contact__c rrac: referReqAccContacts) {
                userEmailMap.put(rrac.Reference_Request_Account__r.Requester__c, '');
            }

            for (User u : WithoutSharingHelperController.getUserMap(userEmailMap.keySet()).values()) {
                
                if (u.IsActive) {
                    userEmailMap.put(u.Id, u.Email);
                }
            }

            for (Reference_Request_Account_Contact__c rrac: referReqAccContacts) {
                String notificationBody = feedbackNotification.DC_Message__c + '\n\n' + feedbackNotification.Default__c;
                notificationBody = notificationBody.replace('[Request Type]', rrac.Reference_Request_Account__r.Reference_Type_Needed_f__c)
                                                    .replace('[Opportunity Account]', mapRefReqAcc.get(rrac.Reference_Request_Account__r.Reference_Request__c).Opportunity__c != null ? mapRefReqAcc.get(rrac.Reference_Request_Account__r.Reference_Request__c).Opportunity__r.Account.Name : '')
                                                    .replace('[Requested Account]', rrac.Reference_Request_Account__r.Account_f__c)
                                                    .replace('[Deadline]', rrac.Reference_Request_Account__r.Deadline__c.format());
            	
                //Prepare Chatter List
                if (checkChatterSetting) {
                	//ReferenceEdge user is used as sender regarding #486
                    postFeedItems.add(MailChatterController.preparePostForRefedgeUser(feedbackNotification.Section_Name__c, rrac.Reference_Request_Account__r.Requester__c,
                        notificationBody, LINK_URL + 'feedbackId' + rrac.Id, protectedAppConfig.User_Id__c));
                }
                
                //Prepare Email List
                if (checkEmailSetting) {
                    MailChatterController.EmailMessage email = MailChatterController.prepareEmailMessage(feedbackNotification.Section_Name__c, 
                        rrac.Reference_Request_Account__r.Requester__c,
                        notificationBody + '\n\n', feedbackNotification.Section_Name__c + ': ' + '<a href="' + LINK_URL + rrac.Id +
                        '">' + LINK_URL + rrac.Id + '</a>');
                    mapEmailstoSent.put(rrac.id, email);
                }
                
                //Prepare Email List
                if (checkSlackSetting) {
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('userEmail', userEmailMap.get(rrac.Reference_Request_Account__r.Requester__c));
                    tempReqBodyMap.put('text', notificationBody
                            + '\n<' + LINK_URL + rrac.Id + '|'
                            + feedbackNotification.Section_Name__c + '>');
                    messagesList.add(tempReqBodyMap);
                }
                //Prepare Task List
                listTask.add(MailChatterController.prepareTask(rrac.Reference_Request_Account__r.Requester__c,
                    mapRefReqAcc.get(rrac.Reference_Request_Account__r.Reference_Request__c).Opportunity__c, rrac.Reference_Request_Account__r.Deadline__c,
                    feedbackNotification.Section_Name__c, notificationBody + '\n\n' + feedbackNotification.Section_Name__c + ': ' +
                    LINK_URL + rrac.Id, rrac.Id));
            }
        }
    }

    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {
        List < String > listOfFailedRecords = new List < String > ();
        Integer successPostItemsCount = 0;
        Map<String, Object> slackReqBody = new Map<String, Object>();
        slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
        slackReqBody.put('orgId', UserInfo.getOrganizationId());

        if (messagesList != null && messagesList.size() > 0) {
            slackReqBody.put('messages', messagesList);
            UtilityController.postMsgToSlackSync(JSON.serialize(slackReqBody));
        }

        //Insert list of postFeedItems
        if (postFeedItems.size() > 0) {
            Database.SaveResult[] postItems = database.insert(postFeedItems, false);
            
            // for (database.Saveresult sr: postItems) {
            for (Integer i = 0; i < postItems.size(); i++) {
                
                if (!postItems[i].isSuccess()) {
                    Database.Error err = postItems[i].getErrors()[0];
                    listOfFailedRecords.add('FeedItem Error:' + err.getMessage());
                } else {
                    successPostItemsCount += 1;
                }
            }
        }

        //Send List of emails
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        
        for (String str: mapEmailstoSent.keyset()) {
        	//ReferenceEdge user is used as sender regarding #486
            listmail.add(MailChatterController.prepareEmail(mapEmailstoSent.get(str).subject, mapEmailstoSent.get(str).targetObjectId, mapEmailstoSent.get(
                str).body, true, headerDocId, footerDocId));
        }

        if (listmail.size() > 0) {
            Messaging.sendEmail(listmail);
        }

        //Insert list of tasks
        if (listTask.size() > 0) {
            Database.SaveResult[] tasks = database.insert(listTask, false);
            
            for (database.Saveresult sr: tasks) {
                
                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    listOfFailedRecords.add('Task Error:' + err.getMessage());
                }
            }
        }
        //Send Error message
        UtilityController.sendEmailNotification(listOfFailedRecords, 'Request Feedback batch');

        //Call Method update taskId in Reference_Request_Account_Contact__c Object
        updateRefReqAccContactsTaskId(successPostItemsCount);
    }

    /**
     * Method to insert taskId in Reference_Request_Account__c Object
     */
    private void updateRefReqAccContactsTaskId(Integer successPostItemsCount) {
        
        if (referReqAccContacts != null && referReqAccContacts.size() > 0) {
            
            for (Reference_Request_Account_Contact__c rrac: referReqAccContacts) {
                
                if ((checkChatterSetting && successPostItemsCount > 0) || checkEmailSetting || checkSlackSetting) {
                    rrac.Is_Feedback_Notification_Send__c = true;
                    rrac.Is_Feedback_Received__c = false;
                }
                
                for (Task lstTask: listTask) {
                    
                    if (rrac.Id == lstTask.Reference_Request_Account_Contact_Id__c) {
                        rrac.Task_ID__c = lstTask.Id;
                    }
                }
                updateRefReqAccContacts.add(rrac);
            }
            
            if (updateRefReqAccContacts.size() > 0)
                update updateRefReqAccContacts;
        }
    }
}