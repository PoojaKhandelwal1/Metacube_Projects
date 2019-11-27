/*
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
 * Class: Schedular_SalesRewardNotification
 * Description : This Batch called from Schedular_SalesRewardNotification to send email notification to user who have sales reward, so user can track who many reward user have.
 * Notification will send to user based on setting provided in Custom Setting  //Added this for #117  Sales reward minder setting
 * @Author Narender Singh
 * Modified by: Rekha Jangir @Nov/18/2016
 */
global with sharing class Batch_SalesRewardNotification implements Database.Batchable < sObject > , Database.stateful, Database.AllowsCallouts {
    /**
     * Properties and variables
     */
    private Custom_Settings__c cs = null;
    private Map < Id, Decimal > userLifeTimePoints;
    private Map < Id, Decimal > userAvailablePoints;
    private Map < Id, Integer > userAcitivity;
    private List<Map<String, String>> messagesList = new List<Map<String, String>>();
    /**
     * Constructor
     */
    global Batch_SalesRewardNotification() {
        cs = UtilityController.getCustomSettings();
    }

    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set < Id > userIds = new Set < Id > ();

        if (cs.Enable_Sales_Rewards_Notification__c == true) {
            Date startDate = cs.Last_Notification_Date__c;

            if (startDate == null) {
                startDate = Date.Today();
            }
            Date endDate = cs.Next_Notification_Date__c;
            userLifeTimePoints = new Map < Id, Decimal > ();
            userAvailablePoints = new Map < Id, Decimal > ();
            userAcitivity = new Map < Id, Integer > ();

            //Constructing LifeTime Points and Available Points 
            for (Reward__c reward: [SELECT Amount__c, User__c, Available_Points__c, Expired_Points__c, Expiration_Date__c, Expired__c,
                    Transaction__c FROM Reward__c where User__c != null and CreatedDate >: startDate and CreatedDate <: endDate
                ]) {
                	
                // Mapping Contact LifeTime Points 
                if (!userLifeTimePoints.containsKey(reward.User__c)) {
                    userLifeTimePoints.put(reward.User__c, 0);
                }
                Decimal points = userLifeTimePoints.get(reward.User__c);
                
                if (reward.Amount__c != null && reward.Transaction__c == ConstantsController.ISSUE) {
                    points += reward.Amount__c;
                }
                userLifeTimePoints.put(reward.User__c, points);

                // Mapping Current Available Points 
                if (!userAvailablePoints.containsKey(reward.User__c)) {
                    userAvailablePoints.put(reward.User__c, 0);
                }
                Decimal aPoints = userAvailablePoints.get(reward.User__c);
                
                if (reward.Available_Points__c != null) {
                    aPoints += reward.Available_Points__c;
                }
                userAvailablePoints.put(reward.User__c, aPoints);
                userIds.add(reward.User__c);

                if (!userAcitivity.containsKey(reward.User__c))
                    userAcitivity.put(reward.User__c, 1);
                else {
                    Integer count = userAcitivity.get(reward.User__c);
                    userAcitivity.put(reward.User__c, count + 1);
                }
            }
        }
        String soqlQuery = 'SELECT Id, FirstName, LastName, Email FROM User where id IN : userIds';
        return Database.getQueryLocator(soqlQuery);
    }

    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List < User > scope) {
        List < sObject > postFeedItems = new List < sObject > ();
        List < Messaging.SingleEmailMessage > listmail = new List < Messaging.SingleEmailMessage > ();
        EmailTemplate emailTmplt;
        String headerDocId = '';
        String footerDocId = '';
        Data_Mapping__c summaryNotification = new Data_Mapping__c();
        Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'User_Reward_Email_Summary__c'};

        for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                    FROM Data_Mapping__c
                                    WHERE Object__c = 'Notification'
                                    AND (Field_API_Name__c IN :notificationFieldNames
                                        OR Section_Name__c = 'email header doc'
                                        OR Section_Name__c = 'email footer doc')]) {

            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'User_Reward_Email_Summary__c') {
                summaryNotification = dm;
            } else if (dm.Section_Name__c == 'email header doc') {
                headerDocId = dm.Field_API_Name__c;
            } else if (dm.Section_Name__c == 'email footer doc') {
                footerDocId = dm.Field_API_Name__c;
            }
        }
        
        for (User user : scope) {
            //Replace Place holder with values
            String mailBody = summaryNotification.DC_Message__c + '\n\n' + summaryNotification.Default__c;
            mailBody = mailBody.replace('[User First Name]', user.FirstName)
                                .replace('[Total Points for Month]', String.valueOf(userAvailablePoints.get(user.id)))
                                .replace('[Sales Activity Performed]', String.valueOf(userAcitivity.get(user.id)))
                                .replace('[Lifetime Points]', String.valueOf(userLifeTimePoints.get(user.id)))
                                .replace('[Available Points]', String.valueOf(userAvailablePoints.get(user.id)));

            //Prepare Chatter List
            if (cs.User_Reward_Chatter_Summary__c) {
                postFeedItems.add(MailChatterController.preparePost('', user.id, mailBody, ''));
            }

            //Prepare Email List
            if (cs.User_Reward_Email_Summary__c) { //checkEmailSetting
                //Setting logo id empty for issue R15.96 - MOD
                //ReferenceEdge user is used as sender regarding #486
                listmail.add(MailChatterController.prepareEmail(summaryNotification.Section_Name__c, user.id, mailBody, false, headerDocId, footerDocId));
            }

            if (cs.Enable_Slack_Integration__c && cs.User_Reward_Slack_Summary__c) {
                Map<String, String> tempReqBodyMap = new Map<String, String>();
                tempReqBodyMap.put('userEmail', user.Email);
                tempReqBodyMap.put('text', '*' + summaryNotification.Section_Name__c + '*\n' + mailBody);
                messagesList.add(tempReqBodyMap);
            }
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

    /**
     * Finish Method for batch  will be called  
     */
    global void finish(Database.BatchableContext BC) {
        Map<String, Object> slackReqBody = new Map<String, Object>();
        slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
        slackReqBody.put('orgId', UserInfo.getOrganizationId());

        if (messagesList != null && messagesList.size() > 0) {
            slackReqBody.put('messages', messagesList);
            UtilityController.postMsgToSlackSync(JSON.serialize(slackReqBody));
        }
        //Setting next and last notification date for Next schedule job
        List < CronTrigger > listCronTrigger = [Select NextFireTime From CronTrigger where id =: cs.Sales_Reward_Batch_Trigger_Id__c LIMIT: limits.getLimitQueryRows()];
        cs.Next_Notification_Date__c = (listCronTrigger.size() > 0 ? Date.valueOf(listCronTrigger.get(0).NextFireTime) : null);
        cs.Last_Notification_Date__c = Date.today();
        update cs;
    }
}