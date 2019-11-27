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
    * Page: DataCollectorCustomPage
    * Description : Class used to provide functionality to create DataCollectorForm.
    * Created by: Rajneesh Raj @May 07 2018
*/
global with sharing class DataCollectorInvocableClass {
    
    private static String LINK_URL {
		get {

			if (LINK_URL == null) {
				String sfUrl = URL.getSalesforceBaseUrl().getHost().replace('salesforce', 'visual.force');
				String tempNamespace = UtilityController.appNamespace() != null && UtilityController.appNamespace() != ''
										? UtilityController.appNamespace().replace('__', '.') : 'c.';

				if (sfUrl.contains('.my.')) {
					String instanceName = [SELECT InstanceName FROM Organization LIMIT 1].InstanceName;
					String customDomain = sfUrl.split('.my.')[0];
					LINK_URL = 'https://' + customDomain + '--' + tempNamespace + instanceName.toLowerCase()
								+ '.visual.force.com' + Page.DataCollectorPage.getURL() + '?id=';
				} else {
					LINK_URL = 'https://' + tempNamespace + sfUrl + Page.DataCollectorPage.getURL() + '?id=';
				}
			}
			return LINK_URL;
		}
		set;
	}

    @InvocableMethod
    global static void dataCollectorInvocableMethod(List<String> opportunityDataCollectorList) {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        
        //  Check wether Data Collector Functionality is enable or not And has Refedgelicence 
        if((cs.Enable_Data_Collector__c && UtilityController.isRefedgeUserLicense()) || Test.isRunningTest()) {
            Set<id> oppIdsSet = new Set<id>();
            Map<id, string> oppFormMap = new Map<id, String>();
            List<reference_content__c> rcList = new List<reference_content__c>();
            
            for(String str : opportunityDataCollectorList) {
                
                if(str.contains('@@')) {
                    oppIdsSet.add(str.split('@@')[0]);
                    oppFormMap.put(str.split('@@')[0], str.split('@@')[1]);
                }           
            }
            Map<id, Opportunity> oppMap = new Map<id, Opportunity>([SELECT id, Name, AccountId, StageName, ownerId FROM Opportunity WHERE CloseDate >= Today AND Id =: oppIdsSet
            														AND Id NOT IN (SELECT Opportunity__c FROM Reference_Content__c)]);
            List<Reference_Content_Type__c> refConTentType = new List<Reference_Content_Type__c>();
            refConTentType = [SELECT id, Name__c FROM Reference_Content_Type__c WHERE Name__c =: ConstantsController.REFERENCE_CONTENT_TYPE];
            
            //  To get FormName wise message
            Map<String, Data_Mapping__c> dmMap = new Map<String, Data_Mapping__c>();
            
            for(Data_Mapping__c dm : [SELECT Field_API_Name__c, DC_Message__c, Label__c, Section_Name__c, Data_Collector_Name__c FROM Data_Mapping__c WHERE Data_Collector_Name__c !='' AND Section_Name__c =: ConstantsController.DC_INITIAL_NOTIFICATION ]) {
                dmMap.put(dm.Data_Collector_Name__c, dm);
            }
            
            if(oppMap.size() > 0) {
                
                for(opportunity opp : oppMap.values()) {
                    Reference_Content__c ref = new Reference_Content__c();
                    ref.Title__c = oppFormMap.get(opp.Id) +'  - '+ opp.Name+ ' - '+String.valueOf(system.Today());
                    ref.Opportunity__c = opp.id;
                    if(opp.AccountId != null)
                    ref.Account__c = opp.AccountId;
                    ref.Data_Collector_Name__c = oppFormMap.get(opp.Id);
                    ref.Data_Collector_Status__c = 'New';
                    ref.Internal_Use__c = true;
                    ref.Custom_Reference_Content__c = true;
                    
                    if(refConTentType.size() > 0) {
                        ref.Reference_Content_Type__c = refConTentType[0].Id;
                        ref.Reference_Content_Type_Name__c = refConTentType[0].Name__c;
                    }
                    
                    if(cs.Frequency_Of_Reminders__c != null && cs.Number_Of_Reminders_To_Be_Sent__c != null && Integer.valueOf(cs.Frequency_Of_Reminders__c) != 0 && Integer.valueOf(cs.Number_Of_Reminders_To_Be_Sent__c) != 0) {
                        ref.Reminder_Date__c = UtilityController.excludeWeekends(Date.Today(), Integer.valueOf(cs.Frequency_Of_Reminders__c), cs.Include_Weekends__c, cs.Days_of_Week__c);                       
                    }

                    if(dmMap.containsKey(ref.Data_Collector_Name__c)) {
                        rcList.add(ref);
                    }                    
                }
            }
            
            if(rcList.Size() > 0) {            
                insert rcList;
            }
            
            //If any DC initial notification setting is enabled
            if(rcList.size() > 0 && (cs.DC_Initial_Notification_Email__c || cs.DC_Initial_Notification_Chatter__c || cs.DC_Initial_Notification_Slack__c)) {
            	RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
                List<sObject> postFeedItems = new List<sObject>();
                List<MailChatterController.EmailMessage> emailstoSentList = new List<MailChatterController.EmailMessage>();
	            List<Map<String, String>> messagesList = new List<Map<String, String>>();
                
                // Set userEmailMap for users - whom we want to send 'Slack' notifications
	            Map<Id, String> userEmailMap = new Map<Id, String>();
        		if (cs.DC_Initial_Notification_Slack__c && cs.Enable_Slack_Integration__c && cs.Nomination_Slack__c) {
        			for(reference_content__c refCon : rcList) {
        				userEmailMap.put(oppMap.get(refCon.Opportunity__c).ownerId, '');
        			}
        			
        			for (User u : WithoutSharingHelperController.getUserMap(userEmailMap.keySet()).values()) {
			            if (u.IsActive) {
			                userEmailMap.put(u.Id, u.Email);
			            }
			        }
        		}
                
                for(reference_content__c refCon : rcList) {
                    if(dmMap.containsKey(refCon.Data_Collector_Name__c)) {
                        String notificationSubject = dmMap.get(refCon.Data_Collector_Name__c).Field_API_Name__c != null ? dmMap.get(refCon.Data_Collector_Name__c).Field_API_Name__c : ConstantsController.DC_INITIAL_NOTIFICATIONSUB;
		                String targetObjectId = oppMap.get(refCon.Opportunity__c).ownerId;
		                String notificationBody = (dmMap.get(refCon.Data_Collector_Name__c).DC_Message__c != null ? dmMap.get(refCon.Data_Collector_Name__c).DC_Message__c : ConstantsController.DC_INITIAL_NOTIFICATIONMSG)+ 
                            							MailChatterController.prepareChatterEmailRFContentMessage(oppMap.get(refCon.Opportunity__c).Name, oppMap.get(refCon.Opportunity__c).StageName);
		        
                        // for chatter Notification
                        if(UtilityController.isNativeChatterSetting && cs.DC_Initial_Notification_Chatter__c) {
                            postFeedItems.add(MailChatterController.preparePostForRefedgeUser(notificationSubject, targetObjectId, notificationBody,
                            						LINK_URL+refCon.Id, protectedAppConfig.User_Id__c));
                        }                        
                        
                        // for email Notification
                        if(cs.DC_Initial_Notification_Email__c) {
	                        MailChatterController.EmailMessage email = MailChatterController.prepareEmailMessage(notificationSubject, targetObjectId, notificationBody, 
	                        												'Link : ' + '<a href="' + LINK_URL +refCon.Id+ '">' + LINK_URL +refCon.Id + '</a>'  ); 
	                        emailstoSentList.add(email);
                        }
                        
                        // for slack Notification
                        if (cs.DC_Initial_Notification_Slack__c && cs.Enable_Slack_Integration__c && cs.Nomination_Slack__c) {
				            Map<String, String> tempReqBodyMap = new Map<String, String>();
			                tempReqBodyMap.put('text', notificationBody + '\n<' + LINK_URL + refCon.Id + '|' + notificationSubject + '>');
				            tempReqBodyMap.put('userEmail', userEmailMap.get(targetObjectId));
				            messagesList.add(tempReqBodyMap);
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
                
                //Insert list of postFeedItems
                if (postFeedItems.size() > 0) {
                    insert postFeedItems;
                }
                
                //Send List of slack notifications
                if (messagesList.size() > 0) {
                    Map<String, Object> slackReqBody = new Map<String, Object>();
		            slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
		            slackReqBody.put('orgId', UserInfo.getOrganizationId());
		            slackReqBody.put('messages', messagesList);
		            UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
                }
            }
        }    
    } 
}