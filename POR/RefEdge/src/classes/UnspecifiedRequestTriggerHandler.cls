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
 * Handler class for trigger on Unspecified Request Object
 * Related Trigger: UnspecifiedRequestTrigger
 * 
 * Last Modified: Gaurav Saini (17 Nov, 2016)
 */
public with sharing class UnspecifiedRequestTriggerHandler extends RefEdgeEditionFeatures {
    
    /**
     * Constants
     */
    private static String STATUS_UPDATE_SUBJECT = 'Reference Request Update.';
    private static String OWNER_UPDATE_SUBJECT = '@@@ is now managing your Request”';
    private static String LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
    private static Map<Id, Referenceability_Type__c> mapReferenceType;
    private static Set<String> setRefTypeIds = new Set<String>();
    
    /**
     * Method called on after update of Unspecified Request
     */
    public static void onAfterUpdate(List<Unspecified_Request__c> oldList,
    									Map<Id, Unspecified_Request__c> oldMap,
    									List<Unspecified_Request__c> newList,
    									Map<Id, Unspecified_Request__c> newMap) {
        List<sObject> feedCommentList = new List<sObject>();
        List<Unspecified_Request__c> URtoUpdateComment = new List<Unspecified_Request__c>();
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Boolean checkProjectOwnerEmailSetting = cs.Project_Owner_Update_Email__c;
        Boolean checkProjectOwnerChatterSetting = (cs.Project_Owner_Update_Chatter__c && UtilityController.isNativeChatterSetting);
        Boolean checkProjectOwnerSlackSetting = cs.Enable_Slack_Integration__c && cs.Project_Owner_Update_Slack__c;
        Boolean checkStatusUpdateEmailSetting = cs.Status_Update_Email__c;
        Boolean checkStatusUpdateChatterSetting = (cs.Status_Update_Chatter__c && UtilityController.isNativeChatterSetting);
        Boolean checkStatusUpdateSlackSetting = cs.Enable_Slack_Integration__c && cs.Status_Update_Slack__c;
        List<sObject> postFeedItems = new List<sObject>();
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        Set<Id> rrIds = new Set<Id>();
        List<Reference_Request__c> updatedRefRequests = new List<Reference_Request__c>();
        List<Unspecified_Request__c> urEmailList = new List<Unspecified_Request__c>();
        Map<Id, string> oppAccName = new Map<Id, String>();
        Set<string> allreqIds = new Set<String>();
        mapReferenceType = WithoutSharingHelperController.getRefTypesMap(setRefTypeIds);
        String headerDocId = '';
        String footerDocId = '';
        Data_Mapping__c ownerUpdateNotification = new Data_Mapping__c();
        Data_Mapping__c statusUpdateNotification = new Data_Mapping__c();
        Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Project_Owner_Update_Email__c', UtilityController.appNamespace() + 'Status_Update_Email__c'};

        for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                    FROM Data_Mapping__c
                                    WHERE Object__c = 'Notification'
                                    AND (Field_API_Name__c IN :notificationFieldNames
                                        OR Section_Name__c = 'email header doc'
                                        OR Section_Name__c = 'email footer doc')]) {

            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Project_Owner_Update_Email__c') {
                ownerUpdateNotification = dm;
            } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Status_Update_Email__c') {
                statusUpdateNotification = dm;
            } else if (dm.Section_Name__c == 'email header doc') {
                headerDocId = dm.Field_API_Name__c;
            } else if (dm.Section_Name__c == 'email footer doc') {
                footerDocId = dm.Field_API_Name__c;
            }
        }
        Map<String, Object> slackReqBody = new Map<String, Object>();
        slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
        slackReqBody.put('orgId', UserInfo.getOrganizationId());
        Map<Id, String> userEmailMap = new Map<Id, String>();
        List<Map<String, String>> messagesList = new List<Map<String, String>>();
        
        if (ConstantsController.UPDATED_SUBJECT_FOR_REF_REQUEST != null
        			&& ConstantsController.UPDATED_SUBJECT_FOR_REF_REQUEST != '') {
            OWNER_UPDATE_SUBJECT = ConstantsController.UPDATED_SUBJECT_FOR_REF_REQUEST;
            STATUS_UPDATE_SUBJECT = ConstantsController.UPDATED_SUBJECT_FOR_REF_REQUEST;
        }
        
        for (Unspecified_Request__c ur : newList) {
            userEmailMap.put(ur.Requester__c, '');
        	allreqIds.add(ur.Reference_Request__c);
        }
        Map<Id, Reference_Request__c> requestMap = WithoutSharingHelperController.getRefRequestMap(allreqIds);
        
        for (Unspecified_Request__c ur : newList) {
        	oppAccName.put(ur.Id, (requestMap.get(ur.Reference_Request__c).Opportunity__c != null
        								? requestMap.get(ur.Reference_Request__c).Opportunity__r.Account.Name : ''));
        }

        for (User u : WithoutSharingHelperController.getUserMap(userEmailMap.keySet()).values()) {
            
            if (u.IsActive) {
                userEmailMap.put(u.Id, u.Email);
            }
        }
        
        for (Unspecified_Request__c ur : newList) {
            
            /* If only Project Owner Update */
            if (oldMap.get(ur.Id).Unspecified_Request_Status__c == newMap.get(ur.Id).Unspecified_Request_Status__c
            			&& (oldMap.get(ur.Id).Project_Owner__c != newMap.get(ur.Id).Project_Owner__c)) {
                String notificationBody = ownerUpdateNotification.DC_Message__c + '\n\n' + ownerUpdateNotification.Default__c;
                notificationBody = notificationBody.replace('[Request Type]', ur.Reference_Type_Needed_f__c)
                                                    .replace('[Approve Deny Notes]', UtilityController.checkValueOfString(ur.Notes__c))
                                                    .replace('[Requested Account]', ConstantsController.UNSPECIFIED)
                                                    .replace('[Account Request Status]', ur.Unspecified_Request_Status__c)
                                                    .replace('[Project Owner]', ur.Project_Owner_f__c)
                                                    .replace('[Deadline]', ur.Deadline__c.format());
                
                if (checkProjectOwnerEmailSetting) {
                    listmail.add(MailChatterController.prepareEmail(ownerUpdateNotification.Section_Name__c.replace('[Project Owner]', ur.Project_Owner_f__c), ur.Requester__c,
                                            notificationBody, false, headerDocId, footerDocId));
                }
                
                if (checkProjectOwnerChatterSetting) {
                    postFeedItems.add(MailChatterController.preparePost(ownerUpdateNotification.Section_Name__c.replace('[Project Owner]', ur.Project_Owner_f__c), ur.Requester__c,
                                            notificationBody, ''));
                }
                
                if (checkProjectOwnerSlackSetting) {
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('userEmail', userEmailMap.get(ur.Requester__c));
                    tempReqBodyMap.put('text', '*' + ownerUpdateNotification.Section_Name__c.replace('[Project Owner]', ur.Project_Owner_f__c) + '*\n' + notificationBody);
                    messagesList.add(tempReqBodyMap);
                }
            }
            
            /* If Status or Project Owner Update */
            if ((oldMap.get(ur.Id).Unspecified_Request_Status__c != newMap.get(ur.Id).Unspecified_Request_Status__c)) {
                
                /* If only Status Update */
                if (oldMap.get(ur.Id).Project_Owner__c == newMap.get(ur.Id).Project_Owner__c
                			&& newMap.get(ur.Id).Unspecified_Request_Status__c != ConstantsController.ACCOUNT_SPECIFIED
                			&& (newMap.get(ur.Id).Unspecified_Request_Status__c != ConstantsController.NO_LONGER_NEEDED
                				|| newMap.get(ur.Id).Unspecified_Request_Status__c != ConstantsController.NO_REFERENCE_MATCH)) {
                    String notificationBody = statusUpdateNotification.DC_Message__c + '\n\n' + statusUpdateNotification.Default__c;
                    notificationBody = notificationBody.replace('[Request Type]', ur.Reference_Type_Needed_f__c)
                                                        .replace('[Opportunity Account]', oppAccName.get(ur.Id))
                                                        .replace('[Requested Account]', ConstantsController.UNSPECIFIED)
                                                        .replace('[Account Request Status]', ur.Unspecified_Request_Status__c)
                                                        .replace('[Deadline]', ur.Deadline__c.format());
                    
                    if (checkStatusUpdateEmailSetting) {
                        listmail.add(MailChatterController.prepareEmail(statusUpdateNotification.Section_Name__c, ur.Requester__c,
                                                notificationBody, false, headerDocId, footerDocId));
                    }
                    
                    if (checkStatusUpdateChatterSetting) {
                        postFeedItems.add(MailChatterController.preparePost(statusUpdateNotification.Section_Name__c, ur.Requester__c, notificationBody, ''));
                    }
                    
                    if (checkStatusUpdateSlackSetting) {
                        Map<String, String> tempReqBodyMap = new Map<String, String>();
                        tempReqBodyMap.put('userEmail', userEmailMap.get(ur.Requester__c));
                        tempReqBodyMap.put('text', '*' + statusUpdateNotification.Section_Name__c + '*\n' + notificationBody);
                        messagesList.add(tempReqBodyMap);
                    }
                }
                
                /* If Both Status & Project Owner Update */
                if (oldMap.get(ur.Id).Project_Owner__c != newMap.get(ur.Id).Project_Owner__c) {
                    
                    if (newMap.get(ur.Id).Unspecified_Request_Status__c == ConstantsController.NO_REFERENCE_MATCH) {
                        String notificationBody = statusUpdateNotification.DC_Message__c + '\n\n' + statusUpdateNotification.Default__c;
                        notificationBody = notificationBody.replace('[Request Type]', ur.Reference_Type_Needed_f__c)
                                                            .replace('[Opportunity Account]', oppAccName.get(ur.Id))
                                                            .replace('[Requested Account]', ConstantsController.UNSPECIFIED)
                                                            .replace('[Account Request Status]', ur.Unspecified_Request_Status__c)
                                                            .replace('[Deadline]', ur.Deadline__c.format());
                        
                        if (checkStatusUpdateEmailSetting || checkProjectOwnerEmailSetting) {
                            listmail.add(MailChatterController.prepareEmail(statusUpdateNotification.Section_Name__c, ur.Requester__c, notificationBody, false, headerDocId, footerDocId));
                        }
                        
                        if (checkStatusUpdateChatterSetting || checkProjectOwnerChatterSetting) {
                            postFeedItems.add(MailChatterController.preparePost(statusUpdateNotification.Section_Name__c, ur.Requester__c, notificationBody, ''));
                        }
                        
                        if (checkStatusUpdateSlackSetting || checkProjectOwnerSlackSetting) {
                            Map<String, String> tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('userEmail', userEmailMap.get(ur.Requester__c));
                            tempReqBodyMap.put('text', '*' + statusUpdateNotification.Section_Name__c + '*\n' + notificationBody);
                            messagesList.add(tempReqBodyMap);
                        }
                    } else {
                        String notificationBody = ownerUpdateNotification.DC_Message__c + '\n\n' + ownerUpdateNotification.Default__c;
                        notificationBody = notificationBody.replace('[Request Type]', ur.Reference_Type_Needed_f__c)
                                                            .replace('[Approve Deny Notes]', UtilityController.checkValueOfString(ur.Notes__c))
                                                            .replace('[Requested Account]', ConstantsController.UNSPECIFIED)
                                                            .replace('[Account Request Status]', ur.Unspecified_Request_Status__c)
                                                            .replace('[Project Owner]', ur.Project_Owner_f__c)
                                                            .replace('[Deadline]', ur.Deadline__c.format());
                        
                        if (checkStatusUpdateEmailSetting || checkProjectOwnerEmailSetting) {
                            listmail.add(MailChatterController.prepareEmail(ownerUpdateNotification.Section_Name__c.replace('[Project Owner]', ur.Project_Owner_f__c), ur.Requester__c,
                                            notificationBody, false, headerDocID, footerDocId));
                        }
                        
                        if (checkStatusUpdateChatterSetting || checkProjectOwnerChatterSetting) {
                            postFeedItems.add(MailChatterController.preparePost(ownerUpdateNotification.Section_Name__c.replace('[Project Owner]', ur.Project_Owner_f__c), ur.Requester__c, notificationBody, ''));
                        }
                        
                        if (checkStatusUpdateSlackSetting || checkProjectOwnerSlackSetting) {
                            Map<String, String> tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('userEmail', userEmailMap.get(ur.Requester__c));
                            tempReqBodyMap.put('text', '*' + ownerUpdateNotification.Section_Name__c.replace('[Project Owner]', ur.Project_Owner_f__c) + '*\n' + notificationBody);
                            messagesList.add(tempReqBodyMap);
                        }
                    }
                }
                setRefTypeIds.add(ur.Reference_Type_Needed__c);
                
                if (ur.Unspecified_Request_Status__c == ConstantsController.IN_PROGRESS
                			|| ur.Unspecified_Request_Status__c == ConstantsController.NO_LONGER_NEEDED
                			|| ur.Unspecified_Request_Status__c == ConstantsController.NO_REFERENCE_MATCH
                			|| ur.Unspecified_Request_Status__c == ConstantsController.ACCOUNT_SPECIFIED) {
                    
                    rrIds.add(ur.Reference_Request__c);
    			}
    			
    			//related to #867
    			if (ur.Unspecified_Request_Status__c == ConstantsController.NO_LONGER_NEEDED) {
                    URtoUpdateComment.add(ur);
    			}
            }
        }
        
        for (Reference_Request__c rrObj : WithoutSharingHelperController.getRefRequestList(rrIds)) {
        	
            for (Unspecified_Request__c urObj: rrObj.Unspecified_Requests__r) {
            	
                if (newMap.containsKey(urObj.Id)) {
                    
                    if (urObj.Unspecified_Request_Status__c == ConstantsController.IN_PROGRESS) {
                        
                        if (rrObj.Reference_Request_Status__c == null
                        			|| rrObj.Reference_Request_Status__c == ConstantsController.NOT_STARTED) {
                            rrObj.Reference_Request_Status__c = ConstantsController.IN_PROGRESS;
                            updatedRefRequests.add(rrObj);
                        }
                    } else if (urObj.Unspecified_Request_Status__c == ConstantsController.NO_LONGER_NEEDED
                    			|| urObj.Unspecified_Request_Status__c == ConstantsController.NO_REFERENCE_MATCH
                    			|| urObj.Unspecified_Request_Status__c == ConstantsController.ACCOUNT_SPECIFIED) {
                        boolean isUrComplete = true;
                        
                        for (Unspecified_Request__c tempObj : rrObj.Unspecified_Requests__r) {
                            
                            if (tempObj.Unspecified_Request_Status__c != ConstantsController.NO_LONGER_NEEDED
                            			&& tempObj.Unspecified_Request_Status__c != ConstantsController.NO_REFERENCE_MATCH
                            			&& tempObj.Unspecified_Request_Status__c != ConstantsController.ACCOUNT_SPECIFIED) {
                                isUrComplete = false;
                            }
                        }
                        
                        if (rrObj.Reference_Request_Accounts__r.size() == 0 && isUrComplete) {
                            
                            if (rrObj.Reference_Request_Status__c != ConstantsController.COMPLETED) {
                                rrObj.Reference_Request_Status__c = ConstantsController.COMPLETED;
                                updatedRefRequests.add(rrObj);
                            }
                        }
                    }
                }
            }
        }
        
        if (updatedRefRequests.size() > 0) {
            ConstantsController.shouldArAndUrUpdate = false;
            update updatedRefRequests;
        }
        
        //related to #867
        if (URtoUpdateComment != null && URtoUpdateComment.size() > 0) {
    		RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
    		
    		for (Unspecified_Request__c ur : URtoUpdateComment) {
    			
    			if (ur.Related_Feed_Item_Ids__c != null && ur.Related_Feed_Item_Ids__c != '') {
    				
    				for (String feedItemId : ur.Related_Feed_Item_Ids__c.split(',')) {
    					FeedComment fc = new FeedComment();
    					fc.CommentBody = 'This Request has been marked as ' + ur.Unspecified_Request_Status__c +'.';
    					fc.FeedItemId = feedItemId;
    					
    					if (protectedAppConfig.User_Id__c != null && protectedAppConfig.User_Id__c != '') {
				        	fc.put('CreatedById', protectedAppConfig.User_Id__c);
				        }
    					feedCommentList.add(fc);
    				}
    			}
    		}
    	}
    	
    	if (feedCommentList != null && feedCommentList.size() > 0) {
    		WithoutSharingHelperController.insertFeedComments(feedCommentList);
    	}
    	
        if (ConstantsController.isNotificationSend) {
            
            //Send List of emails
            if (listmail.size() > 0) {
                Messaging.sendEmail(listmail);
            }
            
            //Post List of feed    
            if (postFeedItems.size() > 0) {
                postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
            }

            if (messagesList != null && messagesList.size() > 0) {
            	slackReqBody.put('messages', messagesList);
            	UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
            }
        }
    }
    
    /**
     * Method called on before update of Unspecified Request
     */
    public static void onBeforeUpdate(List<Unspecified_Request__c> oldList,
    									Map<Id, Unspecified_Request__c> oldMap,
    									List<Unspecified_Request__c> newList,
    									Map<Id, Unspecified_Request__c> newMap) {
        
        for (Unspecified_Request__c urObj : newList) {
            
            if (oldMap.get(urObj.Id).Unspecified_Request_Status__c != newMap.get(urObj.Id).Unspecified_Request_Status__c
            			&& (newMap.get(urObj.Id).Unspecified_Request_Status__c == ConstantsController.NO_LONGER_NEEDED
            				|| newMap.get(urObj.Id).Unspecified_Request_Status__c == ConstantsController.NO_REFERENCE_MATCH)) {
                
                urObj.Project_Owner__c = (urObj.Project_Owner__c == null
                								? Userinfo.getUserId() : urObj.Project_Owner__c);
            }
            
            if (oldMap.get(urObj.Id).Unspecified_Request_Status__c == ConstantsController.ACCOUNT_SPECIFIED
            			&& oldMap.get(urObj.Id).Unspecified_Request_Status__c != newMap.get(urObj.Id).Unspecified_Request_Status__c) {
                
                newMap.get(urObj.Id).addError(System.Label.Account_Specified_Error2);
            } else if (!ConstantsController.shouldUnspecifiedStatusChange
            			&& newMap.get(urObj.Id).Unspecified_Request_Status__c == ConstantsController.ACCOUNT_SPECIFIED
            			&& oldMap.get(urObj.Id).Unspecified_Request_Status__c != newMap.get(urObj.Id).Unspecified_Request_Status__c) {
                
                newMap.get(urObj.Id).addError(System.Label.Account_Specified_Error1);
            }
            
            if ((urObj.Unspecified_Request_Status__c == null
            				|| urObj.Unspecified_Request_Status__c == ''
            				|| urObj.Unspecified_Request_Status__c == ConstantsController.NOT_STARTED)
        				&& (newMap.get(urObj.Id).Unspecified_Request_Status__c != oldMap.get(urObj.Id).Unspecified_Request_Status__c)) {
                
                urObj.addError(System.Label.Status_cannot_be_reset);
                return;
            }
        }
    }
}