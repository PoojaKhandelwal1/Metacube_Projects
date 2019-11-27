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
    * Class : Schedular_ReferenceContentReminder
    * (Nightly Job) Will run everyNight
    * Objective : Send Reminder and escalation
    * Created by : Rajneesh Raj @June/05/2018
*/
global with sharing class Batch_ReferenceContentReminder extends RefEdgeEditionFeatures implements Database.Batchable <sObject>, Database.Stateful {
    
    /**
        * Properties and variables
    */ 
    private Map<String, Map<String, Data_Mapping__c>> dmMap; 
    // Check Chatter Setting 
    private Boolean checkChatterSetting;
    private Boolean checkEscalation;
    private static String LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.DataCollectorPage.getURL() + '?id=';
    // Query for which batch will execute
    private String soqlQuery = 
    'SELECT id, Data_Collector_Name__c, Number_of_Reminders_Sent__c, Opportunity__c, Opportunity__r.ownerId, Opportunity__r.Name, Opportunity__r.Owner.ManagerId, '+
    'Opportunity__r.StageName, Content_Status__c, Data_Collector_Status__c, Reminder_Date__c FROM Reference_Content__c '+
    'WHERE Opportunity__c != null AND Data_Collector_Name__c != null AND Data_Collector_Status__c = \'New\'';
    private Integer freqOfReminder = 0;
    private Integer noOfReminder = 0;
    private Integer recordTillDate = 0;
    private Set<Integer> daysSet = new Set<Integer>();
    private List<String> failedRecordList = new List<String>();
    private Custom_Settings__c cs = UtilityController.getCustomSettings();
    
    /**
        * Method to get the data to be proceesed 
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        checkChatterSetting = UtilityController.isNativeChatterSetting;
        checkEscalation = cs.Escalate_On_Last_Reminder__c;
        dmMap = new Map<String, Map<String, Data_Mapping__c>>();
        
        if(cs.Frequency_Of_Reminders__c != null)
        freqOfReminder = Integer.valueOf(cs.Frequency_Of_Reminders__c);
        
        if(cs.Number_Of_Reminders_To_Be_Sent__c != null)
        noOfReminder = Integer.valueOf(cs.Number_Of_Reminders_To_Be_Sent__c); 
        
        recordTillDate = freqOfReminder * (noOfReminder + 1);
        
        if(freqOfReminder > 0 && noOfReminder > 0) {
            
            for(Integer i = 1; i < noOfReminder + 1; i++) {
                daysSet.add(freqOfReminder * i );
            }
        }
        
        for(Data_Mapping__c dm : [SELECT Field_API_Name__c, DC_Message__c, Label__c, Section_Name__c, Data_Collector_Name__c FROM Data_Mapping__c WHERE Data_Collector_Name__c !='' AND Order__c = null AND Section_Position__c = null]) {
            
            if(!dmMap.containsKey(dm.Data_Collector_Name__c))
            dmMap.put(dm.Data_Collector_Name__c, new Map<String, Data_Mapping__c>());
            dmMap.get(dm.Data_Collector_Name__c).put(dm.Section_Name__c, dm);           
        }
        soqlQuery += ' AND  Reminder_Date__c =' + String.valueOf(system.today());        
        return Database.getQueryLocator(soqlQuery);        
    }
    
    /**
        * Method to execute the batch   
    */
    global void execute(Database.BatchableContext BC, list <Reference_Content__c> scope) {
        try{
            
            RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
            List<sObject> postFeedItems = new List<sObject>();
            List<MailChatterController.EmailMessage> emailstoSentList = new List<MailChatterController.EmailMessage>();
            List<Reference_Content__c> refContentUpdateList = new List<Reference_Content__c>();
            List<Map<String, String>> messagesList = new List<Map<String, String>>();
                         
            // Set userEmailMap for users - whom we want to send 'Slack' notifications
	        Map<Id, String> userEmailMap = UtilityController.getUserEmailMapForSlackNotification(cs, scope, ConstantsController.DC_REMINDER);
        	
            for(Reference_Content__c refCon : scope) {
                if(refCon.Number_of_Reminders_Sent__c == null || (Integer.valueOf(refCon.Number_of_Reminders_Sent__c) + 1) < noOfReminder) {
                    //  Reminder to opportunity owner  
                    DCReminderNotification(refCon, postFeedItems, emailstoSentList, messagesList, userEmailMap, protectedAppConfig);                      
                } else if((Integer.valueOf(refCon.Number_of_Reminders_Sent__c) + 1) == noOfReminder) {
                	//Final reminder(Escalation) opportunity owner as well as to his manager
                	DCEscalationNotification(refCon, postFeedItems, emailstoSentList, messagesList, userEmailMap, protectedAppConfig);
                }
                refContentUpdateList.add(refCon);
            }
            
            //Insert list of postFeedItems
            if (postFeedItems.size() > 0) {
                Database.SaveResult[] postItems = database.insert(postFeedItems, false);
                
                for (database.Saveresult sr: postItems) {
                    
                    if (!sr.isSuccess()) {
                        Database.Error err = sr.getErrors()[0];
                        failedRecordList.add('FeedItem Error:' + err.getMessage());
                    }
                }
            }           
            
            //Update List of Reference Content
            if (refContentUpdateList.size() > 0) {
                Database.SaveResult[] requests = database.update(refContentUpdateList, false);
                
                for (database.Saveresult sr: requests) {
                    
                    if (!sr.isSuccess()) {
                        Database.Error err = sr.getErrors()[0];
                        failedRecordList.add('Reference Content Update Error:' + err.getMessage());
                    }
                }
            }
            
            
            //Send List of emails
            if(emailstoSentList.Size() > 0) {
                        
                List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
                
                for(MailChatterController.EmailMessage mem : emailstoSentList) {
                    listmail.add(MailChatterController.prepareEmail(mem.subject, mem.targetObjectId, mem.body, true));
                }
                
                if(listmail.size() > 0) {
                    Messaging.sendEmail(listmail);
                }
            }
            
            //Send List of slack notifications
            if (messagesList.size() > 0) {
                Map<String, Object> slackReqBody = new Map<String, Object>();
	            slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
	            slackReqBody.put('orgId', UserInfo.getOrganizationId());
	            slackReqBody.put('messages', messagesList);
	            UtilityController.postMsgToSlackSync(JSON.serialize(slackReqBody));
            }
            
        }catch(exception ex){
            system.debug(ex.getLineNumber()+' : '+ex.getMessage());
        }
    }
    
    /**
        * Method to be called after the excute
    */
    global void finish(Database.BatchableContext BC) {
        //Send Error message
        UtilityController.sendEmailNotification(failedRecordList, 'Failed DataCollector Reference Content Reminder batch');
    }
            
    private void DCReminderNotification(Reference_Content__c refCon, List<sObject> postFeedItems, List<MailChatterController.EmailMessage> emailstoSentList,
    										List<Map<String, String>> messagesList, Map<Id, String> userEmailMap, RefEdge_Configuration_Protected__c protectedAppConfig) {
    	// Reminder to opportunity owner - If any DC Reminder notification setting is enabled
    	if(cs.DC_Reminder_Email__c || cs.DC_Reminder_Chatter__c || cs.DC_Reminder_Slack__c) {
    		if(refCon.Number_of_Reminders_Sent__c != null) {
	        	refCon.Number_of_Reminders_Sent__c += 1;
	        } else{
		        refCon.Number_of_Reminders_Sent__c = 1;
		    }
		    
		    if(freqOfReminder > 0 ) {
		        //  REF-1919
		        refCon.Reminder_Date__c = UtilityController.excludeWeekends(Date.Today(), freqOfReminder, cs.Include_Weekends__c, cs.Days_of_Week__c);
		    } 
		    
		    if(dmMap.containsKey(refCon.Data_Collector_Name__c)) {
                String notificationSubject = dmMap.get(refCon.Data_Collector_Name__c).get(ConstantsController.DC_REMINDER).Field_API_Name__c != null ? dmMap.get(refCon.Data_Collector_Name__c).get(ConstantsController.DC_REMINDER).Field_API_Name__c : ConstantsController.DC_REMINDERSUB;
                String targetObjectId = refCon.Opportunity__r.ownerId;
                String notificationBody = (dmMap.get(refCon.Data_Collector_Name__c).get(ConstantsController.DC_REMINDER).DC_Message__c != null ? dmMap.get(refCon.Data_Collector_Name__c).get(ConstantsController.DC_REMINDER).DC_Message__c : ConstantsController.DC_REMINDERMSG)+ 
											MailChatterController.prepareChatterEmailRFContentMessage(refCon.Opportunity__r.Name, refCon.Opportunity__r.StageName);
        
        		// for chatter Notification
                if(checkChatterSetting && cs.DC_Reminder_Chatter__c) {
                    FeedItem post = MailChatterController.preparePostForRefedgeUser(notificationSubject, targetObjectId, notificationBody,
                    					LINK_URL+refCon.Id, protectedAppConfig.User_Id__c);
    				postFeedItems.add(post);
                }
                 
                // for email Notification
                if(cs.DC_Reminder_Email__c) {
                	MailChatterController.EmailMessage email = MailChatterController.prepareEmailMessage(notificationSubject, targetObjectId, notificationBody,
                													'Link : ' + '<a href="' + LINK_URL +refCon.Id+ '">' + LINK_URL +refCon.Id + '</a>'  );
					emailstoSentList.add(email);
                }
                
                // for slack Notification
                if (cs.DC_Reminder_Slack__c && cs.Enable_Slack_Integration__c && cs.Nomination_Slack__c) {
		            Map<String, String> tempReqBodyMap = new Map<String, String>();
			        tempReqBodyMap.put('text', notificationBody + '\n<' + LINK_URL + refCon.Id + '|' + notificationSubject + '>');
			        tempReqBodyMap.put('userEmail', userEmailMap.get(targetObjectId));
			        messagesList.add(tempReqBodyMap);
		        }
            }
    	}
    }
    private void DCEscalationNotification(Reference_Content__c refCon, List<sObject> postFeedItems, List<MailChatterController.EmailMessage> emailstoSentList,
    										List<Map<String, String>> messagesList, Map<Id, String> userEmailMap, RefEdge_Configuration_Protected__c protectedAppConfig) {
    	//Final reminder(Escalation) opportunity owner as well as to his manager - If any DC Escalation to Owner/Manager notification setting is enabled  
    	if(checkEscalation && (cs.DC_Escalation_to_Owner_Email__c || cs.DC_Escalation_to_Manager_Email__c
	    		|| cs.DC_Escalation_to_Owner_Chatter__c || cs.DC_Escalation_to_Manager_Chatter__c 
	    		|| cs.DC_Escalation_to_Owner_Slack__c || cs.DC_Escalation_to_Manager_Slack__c)) {
    		if(refCon.Number_of_Reminders_Sent__c != null) {
            	refCon.Number_of_Reminders_Sent__c += 1;
            } else{
                refCon.Number_of_Reminders_Sent__c = 1; 
            }
            
            // Escalation to opportunity owner
            DCEscalationNotificationToOwner(refCon, postFeedItems, emailstoSentList, messagesList, userEmailMap, protectedAppConfig);
            
            // Escalation to Manager
            DCEscalationNotificationToManager(refCon, postFeedItems, emailstoSentList, messagesList, userEmailMap, protectedAppConfig);
    	}
    }
    
    
    private void DCEscalationNotificationToOwner(Reference_Content__c refCon, List<sObject> postFeedItems, List<MailChatterController.EmailMessage> emailstoSentList,
    												List<Map<String, String>> messagesList, Map<Id, String> userEmailMap, RefEdge_Configuration_Protected__c protectedAppConfig) {
    	String notificationSubject = dmMap.get(refCon.Data_Collector_Name__c).get(ConstantsController.DC_OWNER_ESCALATION).Field_API_Name__c != null ? dmMap.get(refCon.Data_Collector_Name__c).get(ConstantsController.DC_OWNER_ESCALATION).Field_API_Name__c : ConstantsController.DC_OWNER_ESCALATIONSUB;      
        String targetObjectId = refCon.Opportunity__r.ownerId;
        String notificationBody = (dmMap.get(refCon.Data_Collector_Name__c).get(ConstantsController.DC_OWNER_ESCALATION).DC_Message__c != null ? dmMap.get(refCon.Data_Collector_Name__c).get(ConstantsController.DC_OWNER_ESCALATION).DC_Message__c : ConstantsController.DC_OWNER_ESCALATIONMSG)+ 
        								MailChatterController.prepareChatterEmailRFContentMessage(refCon.Opportunity__r.Name, refCon.Opportunity__r.StageName);
        
        // for chatter Notification (Escalation Chatter post to opportunity owner)
    	if(checkChatterSetting && cs.DC_Escalation_to_Owner_Chatter__c) {
    		FeedItem post = MailChatterController.preparePostForRefedgeUser(notificationSubject, targetObjectId, notificationBody, 
    							LINK_URL+refCon.Id, protectedAppConfig.User_Id__c);
            postFeedItems.add(post);
    	} 
    	
        // for email Notification(Escalation Mail to opportunity owner)
        if(cs.DC_Escalation_to_Owner_Email__c) {
        	MailChatterController.EmailMessage email = MailChatterController.prepareEmailMessage(notificationSubject, targetObjectId, notificationBody,
        													'Link : ' + '<a href="' + LINK_URL +refCon.Id+ '">' + LINK_URL +refCon.Id + '</a>'  ); 
            emailstoSentList.add(email);
        }
        
        // for slack Notification(Escalation Mail to opportunity owner)
        if(cs.DC_Escalation_to_Owner_Slack__c && cs.Enable_Slack_Integration__c && cs.Nomination_Slack__c) {
        	Map<String, String> tempReqBodyMap = new Map<String, String>();
			
            tempReqBodyMap.put('text', notificationBody + '\n<' + LINK_URL + refCon.Id + '|' + notificationSubject + '>');
            tempReqBodyMap.put('userEmail', userEmailMap.get(targetObjectId));
            messagesList.add(tempReqBodyMap);
        }
    }
    
    private void DCEscalationNotificationToManager(Reference_Content__c refCon, List<sObject> postFeedItems, List<MailChatterController.EmailMessage> emailstoSentList,
    													List<Map<String, String>> messagesList, Map<Id, String> userEmailMap, RefEdge_Configuration_Protected__c protectedAppConfig) {
    	String notificationSubject = dmMap.get(refCon.Data_Collector_Name__c).get(ConstantsController.DC_MANAGER_ESCALATION).Field_API_Name__c != null ? dmMap.get(refCon.Data_Collector_Name__c).get(ConstantsController.DC_MANAGER_ESCALATION).Field_API_Name__c : ConstantsController.DC_MANAGER_ESCALATIONSUB;      
        String notificationBody = (dmMap.get(refCon.Data_Collector_Name__c).get(ConstantsController.DC_MANAGER_ESCALATION).DC_Message__c != null ? dmMap.get(refCon.Data_Collector_Name__c).get(ConstantsController.DC_MANAGER_ESCALATION).DC_Message__c : ConstantsController.DC_MANAGER_ESCALATIONMSG)+ 
					                MailChatterController.prepareChatterEmailRFContentMessage(refCon.Opportunity__r.Name, refCon.Opportunity__r.StageName);
        
    	//  Modified for REF-1893
        // for chatter Notification (Escalation Chatter post to Manager)
        if(checkChatterSetting && cs.DC_Escalation_to_Manager_Chatter__c) {
        	if(refCon.Opportunity__r.Owner.ManagerId != null && !cs.All_Reviews_to_CRP_Team__c) {
        		FeedItem post = MailChatterController.preparePostForRefedgeUser(notificationSubject, refCon.Opportunity__r.Owner.ManagerId, 
        							notificationBody, LINK_URL+refCon.Id, protectedAppConfig.User_Id__c);
                postFeedItems.add(post);                            
            } else {
                //Post to CRP team member
                for(user usr :  UtilityController.getCustomerReferenceTeam()) {
                	FeedItem post = MailChatterController.preparePostForRefedgeUser(notificationSubject, usr.Id, notificationBody, 
                						LINK_URL+refCon.Id, protectedAppConfig.User_Id__c);
                    postFeedItems.add(post);
                }
            }
        }
        
        // for email Notification(Escalation Mail to Manager) 
        if(cs.DC_Escalation_to_Manager_Email__c) {
        	if(refCon.Opportunity__r.Owner.ManagerId != null && !cs.All_Reviews_to_CRP_Team__c) {
                MailChatterController.EmailMessage email2M = MailChatterController.prepareEmailMessage(notificationSubject, refCon.Opportunity__r.Owner.ManagerId,
                												notificationBody, 'Link : ' + '<a href="' + LINK_URL +refCon.Id+ '">' + LINK_URL +refCon.Id + '</a>'); 
                emailstoSentList.add(email2M);
            } else {
                //Set for CRP team member
                for(user usr :  UtilityController.getCustomerReferenceTeam()) {
                    MailChatterController.EmailMessage email2M = MailChatterController.prepareEmailMessage(notificationSubject, usr.Id,
                    												notificationBody, 'Link : ' + '<a href="' + LINK_URL +refCon.Id+ '">' + LINK_URL +refCon.Id + '</a>'); 
                    emailstoSentList.add(email2M);
                }
            }
        }
        
        // for slack Notification(Escalation Mail to Manager)
        if(cs.DC_Escalation_to_Manager_Slack__c) {
        	Map<String, String> tempReqBodyMap = new Map<String, String>();
            tempReqBodyMap.put('text', notificationBody + '\n<' + LINK_URL + refCon.Id + '|' + notificationSubject + '>');
	            
            if(refCon.Opportunity__r.Owner.ManagerId != null && !cs.All_Reviews_to_CRP_Team__c) { //Notification will be sent to CRP team if Manager id is null
                tempReqBodyMap.put('userEmail', userEmailMap.get(refCon.Opportunity__r.Owner.ManagerId));
            }
            messagesList.add(tempReqBodyMap);
        }
    }
}