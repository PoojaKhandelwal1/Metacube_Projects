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
 * Trigger: ReferenceRequestAccountTrigger
 * Description: Class used to handle the DML operations on Account Requests
 * Last modified by: Rekha @20 March 2017
 */
public with sharing class RRAccountTriggerHandler extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public static List<Reference_Request_Account__c> newList;
    public static List<Reference_Request_Account__c> oldList;
    public static Map<Id, Reference_Request_Account__c> newMap;
    public static Map<Id, Reference_Request_Account__c> oldMap;
    
    /**
     * Constants
     */
    private static String APPROVE_DECLINE_TITLE = 'Approve/Decline';
    private static String OWNER_UPDATE_SUBJECT = '@@@ is now managing your ***  Request';
    private static String STATUS_UPDATE_SUBJECT = '@@@ Reference Request Update.';
    private static String PROCESS_UPDATE_SUBJECT_REQUESTER = 'Account match found for Reference Request';
    private static String PROCESS_UPDATE_SUBJECT_REQUESTER_PEER = 'Request for @@@ is managed by the Reference Team';
    private static String PROCESS_UPDATE_BODY_REQUESTER_PEER = 'The reference request for @@@ is now being managed by the Customer Reference Team.';
    private static String PROCESS_CHATTER_UPDATE_SUBJECT_REQUESTER = 'We received your reference request and found a matching account. A request has been' 
    																	+ ' sent to the owner for a response, which will be sent to you directly.';
    private static String PROCESS_CHATTER_UPDATE_SUBJECT_OWNER = 'We received a reference request from one of your peers and found a matching account of ' 
    													+ 'which you are the owner. Please use the Approve/Decline link below to respond to the requester.';
    private static String PROCESS_UPDATE_SUBJECT_OWNER = 'Reference Request for @@@';
    private static String APPROVE_DECLINE_LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.SelectReferenceUseContacts.getURL() + '?id=';
    private static String LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
    
    /**
     * Method called on before insert of Account Request
     */
    public static void onBeforeInsert() {
        Set<Id> assignedUserIds = new Set<Id>();
        Set<String> accountIds = new Set<String>();
        
        for (Reference_Request_Account__c rra : newList) {
            
            //Check Past Date
            if (rra.Activity_Date__c != null) {
                
                if (rra.Activity_Date__c > Date.today()) {
                    rra.addError(System.Label.ACTIVITY_DATE);
                }
            }
            
            if (rra.Managed_Request__c || rra.Process__c == ConstantsController.MANAGED) {
                rra.Process__c = ConstantsController.MANAGED;
                rra.Managed_Request__c = true;
            }
            assignedUserIds.add(rra.Reference_owner__c);
            accountIds.add(rra.Account__c);
        }
        Map<String, Account> mapAccount = new Map<String, Account>();
        
        for (Account acc : WithoutSharingHelperController.getAccountRecords(accountIds)) {
            mapAccount.put(acc.Id, acc);
            assignedUserIds.add(acc.OwnerId);
            
            if (acc.Reference_Basic_Informations__r != null
            		&& acc.Reference_Basic_Informations__r.size() > 0
            		&& acc.Reference_Basic_Informations__r[0].Reference_Owner__c != null) {
            	assignedUserIds.add(acc.Reference_Basic_Informations__r[0].Reference_Owner__c);
            }
        }
        Map<Id, User> userMap = WithoutSharingHelperController.getUserMap(assignedUserIds);
        Custom_Settings__c cs = UtilityController.getCustomSettings();
		Set<String> failedAccNames = new Set<String>();
        
        for (Reference_Request_Account__c rra : newList) {
        	
        	if (!rra.Managed_Request__c) {
        		
        		// processing the request any further only if the assigned user is inactive
        		if (userMap != null
        					&& userMap.containsKey(rra.Reference_owner__c)
        					&& !userMap.get(rra.Reference_owner__c).isActive) {
        			
        			// sending the request to CRP team if adv routing default is set to "Send to CRP team"
        			if (cs.Adv_Request_Routing__c && cs.Adv_Routing_Default__c == 'Send to CRP Team') {
        				rra.Managed_Request__c = true;
        				rra.Reference_Owner__c = null;
        				rra.Project_Owner__c = null;
        				rra.Account_Request_Status__c = ConstantsController.NOT_STARTED;
        			} else if ((cs.Adv_Request_Routing__c && cs.Adv_Routing_Default__c == 'Send to Owner')
        							|| !cs.Adv_Request_Routing__c || RefEdgeEditionFeatures.isBasic) {
	        			
	        			// sending the request to reference owner for the account if he is active
	        			if (mapAccount != null
	        						&& mapAccount.containsKey(rra.Account__c)
	        						&& mapAccount.get(rra.Account__c).Reference_Basic_Informations__r.size() > 0
	        						&& mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c != null
	        						&& userMap.containsKey(mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c)
	        						&& userMap.get(mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c).isActive) {
	        				rra.Reference_Owner__c = mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c;
	        				rra.Project_Owner__c = mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c;
	        			} else if (mapAccount != null
	        						&& mapAccount.containsKey(rra.Account__c)
	        						&& userMap.containsKey(mapAccount.get(rra.Account__c).OwnerId)
	        						&& userMap.get(mapAccount.get(rra.Account__c).OwnerId).isActive) {	// sending the request to account owner if he is active
	        				rra.Reference_Owner__c = mapAccount.get(rra.Account__c).OwnerId;
	        				rra.Project_Owner__c = mapAccount.get(rra.Account__c).OwnerId;
	        			} else {
	        				
	        				// changes for #603 - Gaurav Saini (30 Dec, 2016)
	        				// if adv routing is disabled then showing error message
	        				if (RefEdgeEditionFeatures.isBasic) {
	        					
	        					if (mapAccount != null
			        						&& mapAccount.containsKey(rra.Account__c)) {
	        						
	        						if (!failedAccNames.contains(mapAccount.get(rra.Account__c).Name)) {
		        						failedAccNames.add(mapAccount.get(rra.Account__c).Name);
	        						}
	        					}
	        				} else {	// else sending the request to CRP team
		        				
		        				if (mapAccount != null
			        						&& mapAccount.containsKey(rra.Account__c)) {
			        				ConstantsController.failedRRAAccountNames.add(mapAccount.get(rra.Account__c).Name);
        						}
		        				rra.Managed_Request__c = true;
		        				rra.Reference_Owner__c = null;
		        				rra.Project_Owner__c = null;
                                rra.Process__c = ConstantsController.MANAGED;
		        				rra.Account_Request_Status__c = ConstantsController.NOT_STARTED;
	        				}
	        			}
        			}
        		}
        	}
        }
        
        if (failedAccNames != null && failedAccNames.size() > 0 && newList.size() > 0) {
        	String joinedAccNames = '';
        	
        	for (String accName : failedAccNames) {
        		joinedAccNames = joinedAccNames == '' ? accName : joinedAccNames + ', ' + accName;
        	}
        	newList[0].addError('The Account ' + joinedAccNames
							+ ' does not have an active Owner so a request cannot be sent. Please select another Account');
        }
    }
    
    /**
     * Method called on before update of Account Request
     */
    public static void onBeforeUpdate() {
        Set<String> accountIds = new Set<String>();
        
        for (Reference_Request_Account__c rra : newList) {
        	
            if (newMap.get(rra.Id).Process__c != oldMap.get(rra.Id).Process__c
            			&& newMap.get(rra.Id).Process__c == ConstantsController.REP2REP) {
                accountIds.add(rra.Account__c);
            }
        }
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Map<String, Account> mapAccount = new Map<String, Account>();
        
        for (Account acc : WithoutSharingHelperController.getAccountRecords(accountIds)) {
            mapAccount.put(acc.Id, acc);
        }
        
        for (Reference_Request_Account__c rra : newList) {
        	
            //Check Past Date
            if (rra.Activity_Date__c != null) {
            	
                if (rra.Activity_Date__c > Date.today()) {
                    rra.addError(System.Label.ACTIVITY_DATE);
                }
            }
            
            if ((rra.Account_Request_Status__c == null
            				|| rra.Account_Request_Status__c == ''
            				|| rra.Account_Request_Status__c == ConstantsController.NOT_STARTED)
        				&& (newMap.get(rra.Id).Account_Request_Status__c != oldMap.get(rra.Id).Account_Request_Status__c)) {
                rra.addError(System.Label.Status_cannot_be_reset);
            }
            
            if ((oldMap.get(rra.Id).Account_Request_Status__c != null
		        				&& ((oldMap.get(rra.Id).Account_Request_Status__c).contains('Give Up')
		        					|| oldMap.get(rra.Id).Account_Request_Status__c == ConstantsController.COMPLETED
		        					|| oldMap.get(rra.Id).Account_Request_Status__c == ConstantsController.UNAVAILABLE
		        					|| oldMap.get(rra.Id).Account_Request_Status__c == ConstantsController.NO_LONGER_NEEDED
		        					|| oldMap.get(rra.Id).Account_Request_Status__c == ConstantsController.NO_RESPONSE))
        					&& newMap.get(rra.Id).Account_Request_Status__c != oldMap.get(rra.Id).Account_Request_Status__c
        					&& !ConstantsController.shouldCompleteStatusChange) {
                rra.addError(system.Label.Status_cannot_be_changed);
            }
            
            if (newMap.get(rra.Id).Process__c != oldMap.get(rra.Id).Process__c
            		&& newMap.get(rra.Id).Process__c == ConstantsController.REP2REP) {
                rra.Account_Request_Status__c = ConstantsController.IN_PROGRESS;
                
                if (mapAccount.containsKey(rra.Account__c)) {
                	
                    if (mapAccount.get(rra.Account__c).Reference_Basic_Informations__r.size() > 0
                    		&& mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c != null) {
                        rra.Project_Owner__c = mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c;
                    } else {
                        rra.Project_Owner__c = mapAccount.get(rra.Account__c).OwnerId;
                    }
                }
            }
            
            if (rra.Managed_Request__c || rra.Process__c == ConstantsController.MANAGED) {
                rra.Process__c = ConstantsController.MANAGED;
                rra.Managed_Request__c = true;
            }
            
            //Assign Current User Id as "Project Owner" when Request "Managed" & "Give Up OR Completed OR No Longer Needed"
            if (oldMap.get(rra.Id).Account_Request_Status__c != newMap.get(rra.Id).Account_Request_Status__c
            			&& rra.Account_Request_Status__c != null
            			&& (rra.Account_Request_Status__c.contains('Give Up')
            				|| rra.Account_Request_Status__c == ConstantsController.COMPLETED
            				|| rra.Account_Request_Status__c == ConstantsController.NO_LONGER_NEEDED)) {
            	
                if (rra.Managed_Request__c) {
                    rra.Project_Owner__c = (rra.Project_Owner__c == null ? Userinfo.getUserId() : rra.Project_Owner__c);
                }
                
                if (rra.Account_Request_Status__c == ConstantsController.COMPLETED && rra.Activity_Date__c == null) {
                    rra.Activity_Date__c = date.today();
                }
                
                if (cs.Consider_No_longer_needed_a_use__c
                			&& rra.Account_Request_Status__c == ConstantsController.NO_LONGER_NEEDED
                			&& rra.Activity_Date__c == null) {
                    rra.Activity_Date__c = date.today();
                }
            }
            
            if (rra.Approval_Status__c != null
            			&& oldMap.get(rra.Id).Approval_Status__c != newMap.get(rra.Id).Approval_Status__c
            			&& (rra.Approval_Status__c == ConstantsController.APPROVED
            				|| rra.Approval_Status__c == ConstantsController.DECLINED)) {
                rra.Account_Request_Status__c = ConstantsController.COMPLETED;
                rra.Activity_Date__c = date.today();
            }
        }
    }
    
    /**
     * Method called on before delete of Account Request
     */
    public static void onBeforeDelete() {
        
        for (Reference_Request_Account__c rra : WithoutSharingHelperController.getRefRequestList(oldMap)) {
            
            for (Reward__c reward : rra.Rewards__r) {
                ConstantsController.RewardIds.add(reward.Id);
            }
            
            for (Reference_Request_Account_Contact__c rrac : rra.Reference_Request_Account_Contacts__r) {
                ConstantsController.rracIds.add(rrac.Id);
            }
        }
    }
    
    /**
     * Method called on after delete of Account Request
     */
    public static void onAfterDelete() {
        
        if (ConstantsController.RewardIds != null && ConstantsController.RewardIds.size() > 0) {
            List<Reward__c> deleteRewardList = WithoutSharingHelperController.getRewardList(ConstantsController.RewardIds);
            
            if (deleteRewardList != null && deleteRewardList.size() > 0) {
                WithoutSharingHelperController.deleteRewards(deleteRewardList);
            }
        }
        List<Reference_Request_Account__c> newRRAList = new List<Reference_Request_Account__c>();
        
        for (Reference_Request_Account__c rra : oldList) {
            
            if (rra.Account_Request_Status__c == ConstantsController.COMPLETED) {
                newRRAList.add(rra);
            }
        }
        
        if (newRRAList.size() > 0) {
            updateAccountDetails(newRRAList);
        }

        if (ConstantsController.rracIds.size() > 0) {
            List<Reference_Request_Account_Contact__c> rrac = WithoutSharingHelperController.getContactRequestList(ConstantsController.rracIds);
            
            if (rrac.size() > 0) {
                WithoutSharingHelperController.deleteContactRequestList(rrac);
            }
        }
    }
    
    /**
     * Method called on after undelete of Account Request
     */
    public static void onAfterUnDelete() {
        List<Reference_Request_Account__c> newRRAList = new List<Reference_Request_Account__c>();
        Set<Id> refIds = new Set<Id>();
        
        for (Reference_Request_Account__c rra : newList) {
        	
            if (rra.Account_Request_Status__c == ConstantsController.COMPLETED) {
                newRRAList.add(rra);
                refIds.add(rra.Reference_Type_Needed__c);
            }
        }
        
        if (newRRAList.size() > 0) {
            updateAccountDetails(newRRAList);
        }
        
        if (newRRAList.size() > 0 && ConstantsController.shouldRewardRecordsCreated
        			&& RefEdgeEditionFeatures.isBasic == false) {
            issueRewardPoints(newRRAList, refIds);
        }
    }
    
    /**
     * Method called on after insert of Account Request
     */
    public static void onAfterInsert() {
        Set<Id> refIds = new Set<Id>();
        Set<String> RRIds = new Set<String>();
        Set<String> RRAIds = new Set<String>();
        List<Reference_Request_Account__c> rewardsRraList = new List<Reference_Request_Account__c>();
        
        for (Reference_Request_Account__c ar : newList) {
        	
            if (ar.Reference_Use__c) {
                refIds.add(ar.Reference_Type_Needed__c);
                rewardsRraList.add(ar);
            }
            
            if (ar.Account_Request_Status__c == ConstantsController.IN_PROGRESS) {
                RRIds.add(ar.Reference_Request__c);
            }
        }
        //Update RR and RRA
        updateRrAndRraDetails(RRIds, RRAIds);
        
        if (refIds.size() > 0) {
            updateAccountDetails(rewardsRraList);
            
            //REF-1964
            if (RefEdgeEditionFeatures.isBasic == false && ConstantsController.isCallToInfluitiveAPI == false) {
                issueRewardPoints(rewardsRraList, refIds);
            }
        }
    }
    
    /**
     * Method called on after update of Account Request
     */
    public static void onAfterUpdate() {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Set<String> RRIds = new Set<String>();
        Set<String> RRAIds = new Set<String>();
        Boolean checkProjectOwnerEmailSetting = cs.Project_Owner_Update_Email__c;
        Boolean checkProjectOwnerChatterSetting = (cs.Project_Owner_Update_Chatter__c && UtilityController.isNativeChatterSetting);
        Boolean checkProjectOwnerSlackSetting = cs.Enable_Slack_Integration__c && cs.Project_Owner_Update_Slack__c;
        Boolean checkStatusUpdateEmailSetting = cs.Status_Update_Email__c;
        Boolean checkStatusUpdateChatterSetting = (cs.Status_Update_Chatter__c && UtilityController.isNativeChatterSetting);
        Boolean checkStatusUpdateSlackSetting = cs.Enable_Slack_Integration__c && cs.Status_Update_Slack__c;
        Boolean checkP2pToManagedEmailSetting = cs.P2P_to_Managed_Email__c;
        Boolean checkP2pToManagedChatterSetting = (cs.P2P_to_Managed_Chatter__c && UtilityController.isNativeChatterSetting);
        Boolean checkP2pToManagedSlackSetting = cs.Enable_Slack_Integration__c && cs.P2P_to_Managed_Slack__c;
        Boolean checkManagedToP2pOwnerEmailSetting = cs.Managed_to_P2P_Owner_Email__c;
        Boolean checkManagedToP2pOwnerChatterSetting = (cs.Managed_to_P2P_Owner_Chatter__c && UtilityController.isNativeChatterSetting);
        Boolean checkManagedToP2pOwnerSlackSetting = cs.Enable_Slack_Integration__c && cs.Managed_to_P2P_Owner_Slack__c;
        Boolean checkManagedToP2pRequesterEmailSetting = cs.Managed_to_P2P_Requester_Email__c;
        Boolean checkManagedToP2pRequesterChatterSetting = (cs.Managed_to_P2P_Requester_Chatter__c && UtilityController.isNativeChatterSetting);
        Boolean checkManagedToP2pRequesterSlackSetting = cs.Enable_Slack_Integration__c && cs.Managed_to_P2P_Requester_Slack__c;
        List<Reference_Request_Account__c> rewardsRraList = new List<Reference_Request_Account__c>();
        List<Reference_Request_Account__c> newRRAList = new List<Reference_Request_Account__c>();
        Set<String> accountIdSet = new Set<String>();
        Map<Id, String> oppAccName = new Map<Id, String>();
        //Set of Reference_Request__c ids
        Set<String> reqIds = new Set<String>();
        Set<String> allreqIds = new Set<String>();
        String headerDocId = '';
        String footerDocId = '';
        Data_Mapping__c ownerUpdateNotification = new Data_Mapping__c();
        Data_Mapping__c statusUpdateNotification = new Data_Mapping__c();
        Data_Mapping__c p2pToManagedNotification = new Data_Mapping__c();
        Data_Mapping__c managedToP2pOwnerNotification = new Data_Mapping__c();
        Data_Mapping__c managedToP2pRequesterNotification = new Data_Mapping__c();
        Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Project_Owner_Update_Email__c', UtilityController.appNamespace() + 'Status_Update_Email__c', UtilityController.appNamespace() + 'P2P_to_Managed_Email__c', UtilityController.appNamespace() + 'Managed_to_P2P_Requester_Email__c', UtilityController.appNamespace() + 'Managed_to_P2P_Owner_Email__c'};
        String REF_PROJECT_LINK = URL.getSalesforceBaseUrl().toExternalForm() + Page.RefRequestProject.getURL() + '?id=';

        Map<String, Object> slackReqBody = new Map<String, Object>();
        slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
        slackReqBody.put('orgId', UserInfo.getOrganizationId());
        List<Map<String, String>> messagesList = new List<Map<String, String>>();
        Map<Id, String> userEmailMap = new Map<Id, String>();

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
            } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'P2P_to_Managed_Email__c') {
                p2pToManagedNotification = dm;
            } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Managed_to_P2P_Requester_Email__c') {
                managedToP2pRequesterNotification = dm;
            } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Managed_to_P2P_Owner_Email__c') {
                managedToP2pOwnerNotification = dm;
            } else if (dm.Section_Name__c == 'email header doc') {
                headerDocId = dm.Field_API_Name__c;
            } else if (dm.Section_Name__c == 'email footer doc') {
                footerDocId = dm.Field_API_Name__c;
            }
        }
        
        for (Reference_Request_Account__c rra : newList) {
            allreqIds.add(rra.Reference_Request__c);
            
            if (rra.Account_Request_Status__c == ConstantsController.COMPLETED
            			|| rra.Account_Request_Status__c == ConstantsController.NO_LONGER_NEEDED
            			|| rra.Account_Request_Status__c == ConstantsController.NO_RESPONSE
            			|| rra.Account_Request_Status__c == ConstantsController.UNAVAILABLE) {
                reqIds.add(rra.Reference_Request__c);
			}
        }
        // Reference_Request__c map
        Map<Id, Reference_Request__c> requestMap = WithoutSharingHelperController.getRefRequestMap(allreqIds);
		
        for (Reference_Request_Account__c rra : newList) {
            accountIdSet.add(rra.Account__c);
            
            if (rra.Approval_Status__c != ConstantsController.DECLINED
            			&& rra.Account_Request_Status__c == ConstantsController.COMPLETED
            			&& requestMap.get(rra.Reference_Request__c).Project_Type__c != 'Candidate') {
                newRRAList.add(rra);
            }
            
            if (rra.Account_Request_Status__c == ConstantsController.NO_LONGER_NEEDED
            			&& requestMap.get(rra.Reference_Request__c).Project_Type__c != 'Candidate') {
                newRRAList.add(rra);
            }
            oppAccName.put(rra.Id, (requestMap.get(rra.Reference_Request__c).Opportunity__c != null ? 
            						requestMap.get(rra.Reference_Request__c).Opportunity__r.Account.Name : ''));
        }
        
        if (newRRAList.size() > 0) {
            updateAccountDetails(newRRAList);
        }

        Set<Id> refIds = new Set<Id>();
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        
        for (Account acc : WithoutSharingHelperController.getAccountRecords(accountIdSet)) {
            mapAccount.put(acc.Id, acc);
        }
        
        if (ConstantsController.UPDATED_SUBJECT_FOR_REF_REQUEST != null
        			&& ConstantsController.UPDATED_SUBJECT_FOR_REF_REQUEST != '') {
            OWNER_UPDATE_SUBJECT = ConstantsController.UPDATED_SUBJECT_FOR_REF_REQUEST;
            STATUS_UPDATE_SUBJECT = ConstantsController.UPDATED_SUBJECT_FOR_REF_REQUEST;
        }
        List<sObject> postFeedItems = new List<sObject>();
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        //related to #867
        List<Reference_Request_Account__c> noResponseRRAs = new List<Reference_Request_Account__c>();
        List<Reference_Request_Account__c> giveupRRAs = new List<Reference_Request_Account__c>();

        for (Reference_Request_Account__c rra : newList) {

            if (rra.Project_Owner__c != null) {
                userEmailMap.put(rra.Project_Owner__c, '');
            }

            if (rra.Requester__c != null) {
                userEmailMap.put(rra.Requester__c, '');
            }

            if (mapAccount.get(rra.Account__c).Reference_Basic_Informations__r.size() > 0
                        && mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c != null) {
                userEmailMap.put(mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c, '');
            } else if (mapAccount.get(rra.Account__c).OwnerId != null) {
                userEmailMap.put(mapAccount.get(rra.Account__c).OwnerId, '');
            }
        }

        for (User u : WithoutSharingHelperController.getUserMap(userEmailMap.keySet()).values()) {

            if (u.IsActive) {
                userEmailMap.put(u.Id, u.Email);
            }
        }
        
        for (Reference_Request_Account__c rra : newList) {
        	
            if (newMap.get(rra.Id).Process__c != oldMap.get(rra.Id).Process__c) {
            	
                // if Process changes from Managed to Rep2Rep
                if (newMap.get(rra.Id).Process__c == ConstantsController.REP2REP) {
                	String ownerNotificationBody = managedToP2pOwnerNotification.DC_Message__c + '\n\n' + managedToP2pOwnerNotification.Default__c;
                    ownerNotificationBody = ownerNotificationBody.replace('[Request Type]', rra.Reference_Type_Needed_f__c)
                                                        .replace('[Opportunity Account]', oppAccName.containsKey(rra.Id) != null ? oppAccName.get(rra.Id) : '')
                                                        .replace('[Requested Account]', rra.Account_f__c)
                                                        .replace('[Request Owner]', rra.Project_Owner_f__c)
                                            			.replace('Request From: [User Name]\n', '')
                                                        .replace('[Deadline]', rra.Deadline__c.format())
                                                        .replace('[Request Notes]', rra.Request_Notes__c != null ? rra.Request_Notes__c : '');
                    String ownerNotificationBodySlack = managedToP2pOwnerNotification.DC_Message__c + '\n\n' + managedToP2pOwnerNotification.Default__c;
                    ownerNotificationBodySlack = ownerNotificationBodySlack.replace('[Request Type]', rra.Reference_Type_Needed_f__c)
                                                        .replace('[Opportunity Account]', oppAccName.containsKey(rra.Id) != null ? oppAccName.get(rra.Id) : '')
                                                        .replace('[Requested Account]', rra.Account_f__c)
                                                        .replace('[Request Owner]', rra.Project_Owner_f__c)
                                            			.replace('[User Name]\n', UserInfo.getName())
                                                        .replace('[Deadline]', rra.Deadline__c.format())
                                                        .replace('[Request Notes]', rra.Request_Notes__c != null ? rra.Request_Notes__c : '');
                	String requesterNotificationBody = managedToP2pRequesterNotification.DC_Message__c + '\n\n' + managedToP2pRequesterNotification.Default__c;
                    requesterNotificationBody = requesterNotificationBody.replace('[Request Type]', rra.Reference_Type_Needed_f__c)
                                                        .replace('[Opportunity Account]', oppAccName.containsKey(rra.Id) != null ? oppAccName.get(rra.Id) : '')
                                                        .replace('[Requested Account]', rra.Account_f__c)
                                                        .replace('[Request Owner]', rra.Project_Owner_f__c)
                                                        .replace('[Deadline]', rra.Deadline__c.format())
                                                        .replace('[Request Notes]', rra.Request_Notes__c != null ? rra.Request_Notes__c : '');
                    
                    if (rra.Project_Owner__c != null && checkManagedToP2pOwnerEmailSetting) {
                        listmail.add(MailChatterController.prepareEmail(managedToP2pOwnerNotification.Section_Name__c.replace('[Requested Account]', rra.Account_f__c),
                            	rra.Project_Owner__c, ownerNotificationBody + '\n\n'
                            			+ managedToP2pOwnerNotification.Section_Name__c.replace('[Requested Account]', rra.Account_f__c) + ': ' + '<a href="' + APPROVE_DECLINE_LINK_URL + rra.Id + '">' 
                            			+ APPROVE_DECLINE_LINK_URL + rra.Id + '</a>', false, headerDocId, footerDocId));
                    }

                    if (rra.Project_Owner__c != null && checkManagedToP2pOwnerChatterSetting) {
                        postFeedItems.add(MailChatterController.preparePost(managedToP2pOwnerNotification.Section_Name__c.replace('[Requested Account]', rra.Account_f__c), rra.Project_Owner__c, 
                            		ownerNotificationBody, APPROVE_DECLINE_LINK_URL + rra.Id));
                    }

                    if (rra.Project_Owner__c != null && checkManagedToP2pOwnerSlackSetting) {
                        Map<String, String> tempReqBodyMap = new Map<String, String>();
                        tempReqBodyMap.put('userEmail', userEmailMap.get(rra.Project_Owner__c));
                        tempReqBodyMap.put('text', ownerNotificationBodySlack
                                + '\n<' + APPROVE_DECLINE_LINK_URL + rra.Id + '|'
                                + managedToP2pOwnerNotification.Section_Name__c.replace('[Requested Account]', rra.Account_f__c) + '>');
                        messagesList.add(tempReqBodyMap);
                    }
                    
                    if (rra.Requester__c != null && checkManagedToP2pRequesterEmailSetting) {
                        listmail.add(MailChatterController.prepareEmail(managedToP2pRequesterNotification.Section_Name__c, rra.Requester__c, 
                            requesterNotificationBody, false, headerDocId, footerDocId));
                    }

                    if (rra.Requester__c != null && checkManagedToP2pRequesterChatterSetting) {
                        postFeedItems.add(MailChatterController.preparePost('', rra.Requester__c, requesterNotificationBody, ''));
                    }

                    if (rra.Requester__c != null && checkManagedToP2pRequesterSlackSetting) {
                        Map<String, String> tempReqBodyMap = new Map<String, String>();
                        tempReqBodyMap.put('userEmail', userEmailMap.get(rra.Requester__c));
                        tempReqBodyMap.put('text', '*' + managedToP2pRequesterNotification.Section_Name__c + '*\n' + requesterNotificationBody);
                        messagesList.add(tempReqBodyMap);
                    }
                }
                
                // if Process changes from P2P to Managed
                if (newMap.get(rra.Id).Process__c == ConstantsController.MANAGED && rra.Requester__c != null) {
                	String notificationBody = p2pToManagedNotification.DC_Message__c + '\n\n' + p2pToManagedNotification.Default__c;
                    notificationBody = notificationBody.replace('[Request Type]', rra.Reference_Type_Needed_f__c)
                                                        .replace('[Opportunity Account]', oppAccName.get(rra.Id))
                                                        .replace('[Requested Account]', rra.Account_f__c)
                                                        .replace('[Request Owner]', rra.Project_Owner_f__c)
                                                        .replace('[Deadline]', rra.Deadline__c.format());

                    if (checkP2pToManagedEmailSetting) {
                        listmail.add(MailChatterController.prepareEmail(p2pToManagedNotification.Section_Name__c, 
                        				rra.Requester__c, notificationBody, false, headerDocId, footerDocId));
                    }
                    
                    if (checkP2pToManagedChatterSetting) {
                        postFeedItems.add(MailChatterController.preparePost('', rra.Requester__c, notificationBody, ''));
                    }
                    
                    if (checkP2pToManagedSlackSetting) {
                        Map<String, String> tempReqBodyMap = new Map<String, String>();
                        tempReqBodyMap.put('userEmail', userEmailMap.get(rra.Requester__c));
                        tempReqBodyMap.put('text', '*' + p2pToManagedNotification.Section_Name__c + '*\n' + notificationBody);
                        messagesList.add(tempReqBodyMap);
                    }
                }
            } else {
                // any update except Process
                String additionalNotes = oldMap.get(rra.Id).Approve_Deny_Notes__c != newMap.get(rra.Id).Approve_Deny_Notes__c
                							? UtilityController.checkValueOfString(rra.Approve_Deny_Notes__c) : '';
                
                // If only Project Owner Update
                if (oldMap.get(rra.Id).Account_Request_Status__c == newMap.get(rra.Id).Account_Request_Status__c
                			&& (oldMap.get(rra.Id).Project_Owner__c != newMap.get(rra.Id).Project_Owner__c)) {
                	
                    if (rra.Managed_Request__c) {
                    	
                        if (additionalNotes == null || additionalNotes == '') {
                            additionalNotes = UtilityController.checkValueOfString(rra.Request_Notes__c);
                        }
                        String notificationBody = ownerUpdateNotification.DC_Message__c + '\n\n' + ownerUpdateNotification.Default__c;
                        notificationBody = notificationBody.replace('[Request Type]', rra.Reference_Type_Needed_f__c)
                                                            .replace('[Approve Deny Notes]', additionalNotes)
                                                            .replace('[Requested Account]', rra.Account_f__c)
                                                            .replace('[Account Request Status]', rra.Account_Request_Status__c)
                                                            .replace('[Project Owner]', rra.Project_Owner_f__c)
                                                            .replace('[Deadline]', rra.Deadline__c.format());
                        
                        if (checkProjectOwnerEmailSetting && rra.Requester__c != null) {
                            
                            listmail.add(MailChatterController.prepareEmail(ownerUpdateNotification.Section_Name__c.replace('[Project Owner]', rra.Project_Owner_f__c), rra.Requester__c, 
                            			notificationBody, false, headerDocId, footerDocId));
                        }
                        
                        if (checkProjectOwnerChatterSetting && rra.Requester__c != null) {
                            postFeedItems.add(MailChatterController.preparePost(ownerUpdateNotification.Section_Name__c.replace('[Project Owner]', rra.Project_Owner_f__c),
                                                rra.Requester__c, notificationBody, ''));
                        }
                        
                        if (checkProjectOwnerSlackSetting && rra.Requester__c != null) {
                            Map<String, String> tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('userEmail', userEmailMap.get(rra.Requester__c));
                            tempReqBodyMap.put('text', '*' + ownerUpdateNotification.Section_Name__c.replace('[Project Owner]', rra.Project_Owner_f__c) + '*\n' + notificationBody);
                            messagesList.add(tempReqBodyMap);
                        }
                    }
                }
                
                // If Status or Project Owner Update
                if (oldMap.get(rra.Id).Account_Request_Status__c != newMap.get(rra.Id).Account_Request_Status__c) {
                    
                    // for RRAC Updation
                    if (rra.Account_Request_Status__c != null
                				&& (rra.Account_Request_Status__c.contains('Give Up')
                					|| rra.Account_Request_Status__c == ConstantsController.COMPLETED
                					|| rra.Account_Request_Status__c == ConstantsController.NO_LONGER_NEEDED
                					|| rra.Account_Request_Status__c == ConstantsController.NO_RESPONSE
                					|| rra.Account_Request_Status__c == ConstantsController.UNAVAILABLE)) {
                        RRAIds.add(rra.Id);
                        
                        if (rra.Account_Request_Status__c == ConstantsController.COMPLETED
                        			&& rra.Approval_Status__c != ConstantsController.DECLINED
                        			&& requestMap.get(rra.Reference_Request__c).Project_Type__c != 'Candidate') {
                            refIds.add(rra.Reference_Type_Needed__c);
                            rewardsRraList.add(rra);
                        }
                    }
                    
                    // for RR Updation
                    if (rra.Account_Request_Status__c != null
                    			&& rra.Account_Request_Status__c.contains('Give Up')
                    			|| rra.Account_Request_Status__c == ConstantsController.COMPLETED
                    			|| rra.Account_Request_Status__c == ConstantsController.NO_LONGER_NEEDED
                    			|| rra.Account_Request_Status__c == ConstantsController.NO_RESPONSE
                    			|| rra.Account_Request_Status__c == ConstantsController.UNAVAILABLE
                    			|| rra.Account_Request_Status__c == ConstantsController.IN_PROGRESS) {
                        RRIds.add(rra.Reference_Request__c);
                    }
                    
                    //If only Status Update
                    if (rra.Managed_Request__c
                    			&& oldMap.get(rra.Id).Project_Owner__c == newMap.get(rra.Id).Project_Owner__c
                    			&& rra.Account_Request_Status__c != ConstantsController.NO_LONGER_NEEDED
                    			&& rra.Account_Request_Status__c != ConstantsController.UNAVAILABLE) {
        				
                        String notificationBody = statusUpdateNotification.DC_Message__c + '\n\n' + statusUpdateNotification.Default__c;
                        notificationBody = notificationBody.replace('[Request Type]', rra.Reference_Type_Needed_f__c)
                                                            .replace('[Opportunity Account]', oppAccName.get(rra.Id))
                                                            .replace('[Requested Account]', rra.Account_f__c)
                                                            .replace('[Account Request Status]', rra.Account_Request_Status__c)
                                                            .replace('[Deadline]', rra.Deadline__c.format());

                        if (checkStatusUpdateEmailSetting) {
                        	
                            if (rra.Deadline__c != null && rra.Requester__c != null) {
                                listmail.add(MailChatterController.prepareEmail(statusUpdateNotification.Section_Name__c, 
                                			rra.Requester__c, notificationBody, false, headerDocId, footerDocId));
                            }
                        }
                        
                        if (checkStatusUpdateChatterSetting) {
                        	
                            if (rra.Deadline__c != null && rra.Requester__c != null) {
                                postFeedItems.add(MailChatterController.preparePost(statusUpdateNotification.Section_Name__c, 
                                			rra.Requester__c, notificationBody, ''));
                            }
                        }
                        
                        if (checkStatusUpdateSlackSetting) {
                        	
                            if (rra.Deadline__c != null && rra.Requester__c != null) {
                                Map<String, String> tempReqBodyMap = new Map<String, String>();
                                tempReqBodyMap.put('userEmail', userEmailMap.get(rra.Requester__c));
                                tempReqBodyMap.put('text', '*' + statusUpdateNotification.Section_Name__c + '*\n' + notificationBody);
                                messagesList.add(tempReqBodyMap);
                            }
                        }
                    }
                    
                    // If Both Status & Project Owner Update
                    if (rra.Managed_Request__c && (oldMap.get(rra.Id).Project_Owner__c != newMap.get(rra.Id).Project_Owner__c) && rra.Requester__c != null) {
                    	
                        String notificationBody = ownerUpdateNotification.DC_Message__c + '\n\n' + ownerUpdateNotification.Default__c;
                        notificationBody = notificationBody.replace('[Request Type]', rra.Reference_Type_Needed_f__c)
                                                            .replace('[Approve Deny Notes]', additionalNotes)
                                                            .replace('[Requested Account]', rra.Account_f__c)
                                                            .replace('[Account Request Status]', rra.Account_Request_Status__c)
                                                            .replace('[Project Owner]', rra.Project_Owner_f__c)
                                                            .replace('[Deadline]', rra.Deadline__c.format());
                        
                        if (checkStatusUpdateEmailSetting || checkProjectOwnerEmailSetting) {
                            listmail.add(MailChatterController.prepareEmail(ownerUpdateNotification.Section_Name__c.replace('[Project Owner]', rra.Project_Owner_f__c), rra.Requester__c, 
                            		notificationBody, false, headerDocId, footerDocId));
                        }
                        
                        if (checkStatusUpdateChatterSetting || checkProjectOwnerChatterSetting) {
                            postFeedItems.add(MailChatterController.preparePost(ownerUpdateNotification.Section_Name__c.replace('[Project Owner]', rra.Project_Owner_f__c), rra.Requester__c, 
                            		notificationBody, ''));
                        }
                        
                        if (checkStatusUpdateSlackSetting || checkProjectOwnerSlackSetting) {
                            Map<String, String> tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('userEmail', userEmailMap.get(rra.Requester__c));
                            tempReqBodyMap.put('text', '*' + ownerUpdateNotification.Section_Name__c.replace('[Project Owner]', rra.Project_Owner_f__c) + '*\n' + notificationBody);
                            messagesList.add(tempReqBodyMap);
                        }
                    }
                }
            }
            
            if (oldMap.get(rra.Id).Account_Request_Status__c != newMap.get(rra.Id).Account_Request_Status__c
            			&& rra.Account_Request_Status__c == ConstantsController.UNAVAILABLE) {
                RRAIds.add(rra.Id);
            }
            
            //related to #867
            if (oldMap.get(rra.Id).Account_Request_Status__c != newMap.get(rra.Id).Account_Request_Status__c && rra.Account_Request_Status__c != null) {
            	
            	if (rra.Account_Request_Status__c == ConstantsController.NO_RESPONSE) {
            		noResponseRRAs.add(rra);
            	}
            	
            	if (rra.Account_Request_Status__c.contains('Give Up') ||  rra.Account_Request_Status__c == ConstantsController.NO_LONGER_NEEDED) {
            		giveupRRAs.add(rra);
            	}
            }
            
            // Mail when request UNAVAILABLE 
            // if Request made Managed request and made UnManaged request
            if (rra.Managed_Request__c && !oldMap.get(rra.Id).Managed_Request__c) {
            	String notificationBody = p2pToManagedNotification.DC_Message__c + '\n\n' + p2pToManagedNotification.Default__c;
                notificationBody = notificationBody.replace('[Request Type]', rra.Reference_Type_Needed_f__c)
                                                    .replace('[Opportunity Account]', oppAccName.get(rra.Id))
                                                    .replace('[Requested Account]', rra.Account_f__c)
                                                    .replace('[Request Owner]', rra.Project_Owner_f__c)
                                                    .replace('[Deadline]', rra.Deadline__c.format());

                if (checkP2pToManagedEmailSetting) {
                	
                    //Prepare Mail List
                    if (mapAccount.get(rra.Account__c).Reference_Basic_Informations__r.size() > 0
                    			&& mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c != null) {
                        listmail.add(MailChatterController.prepareEmail(p2pToManagedNotification.Section_Name__c, 
                        					mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c, 
                        					notificationBody, false, headerDocId, footerDocId));
                    } else if (mapAccount.get(rra.Account__c).OwnerId != null) {
                        listmail.add(MailChatterController.prepareEmail(p2pToManagedNotification.Section_Name__c, mapAccount.get(rra.Account__c).OwnerId, 
                        					notificationBody, false, headerDocId, footerDocId));
                    }
                }
                
                if (checkP2pToManagedChatterSetting) {
                	
                    //Prepare Mail List
                    if (mapAccount.get(rra.Account__c).Reference_Basic_Informations__r.size() > 0
                    			&& mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c != null) {
                        postFeedItems.add(MailChatterController.preparePost(p2pToManagedNotification.Section_Name__c, 
                        					mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c, 
                        					notificationBody, ''));
                    } else if (mapAccount.get(rra.Account__c).OwnerId != null) {
                        postFeedItems.add(MailChatterController.preparePost(p2pToManagedNotification.Section_Name__c, mapAccount.get(rra.Account__c).OwnerId, 
                        					notificationBody, ''));
                    }
                }
                
                if (checkP2pToManagedSlackSetting) {
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('text', '*' + p2pToManagedNotification.Section_Name__c + '*\n' + notificationBody);
                	
                    if (mapAccount.get(rra.Account__c).Reference_Basic_Informations__r.size() > 0
                    			&& mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c != null) {
                        tempReqBodyMap.put('userEmail', userEmailMap.get(mapAccount.get(rra.Account__c).Reference_Basic_Informations__r[0].Reference_Owner__c));
                    } else if (mapAccount.get(rra.Account__c).OwnerId != null) {
                        tempReqBodyMap.put('userEmail', userEmailMap.get(mapAccount.get(rra.Account__c).OwnerId));
                    }
                    messagesList.add(tempReqBodyMap);
                }
            }
        }
        
        if (rewardsRraList.size() > 0 && ConstantsController.shouldRewardRecordsCreated && RefEdgeEditionFeatures.isBasic == false) {
            issueRewardPoints(rewardsRraList, refIds);
        }
        
        // Update RR and RRA
        updateRrAndRraDetails(RRIds, RRAIds);
        //related to #867
        updateTaskAndComments(noResponseRRAs, giveupRRAs);
    	
        if (ConstantsController.isNotificationSend != null && ConstantsController.isNotificationSend) {
        	
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
     * Method to update task and comment on chatter post
     * Created By: Rekha @10 July 2017 related to #866
     */
    private static void updateTaskAndComments(List<Reference_Request_Account__c> noResponseRRAs, List<Reference_Request_Account__c> giveupRRAs) {
    	List<sObject> feedCommentList = new List<sObject>();
    	Set<Id> rraIds = new Set<Id>();
    	List<Task> tasks = new List<Task>();
    	
        if (giveupRRAs.size() > 0 || noResponseRRAs.size() > 0) {
    		RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
    		
    		for (Reference_Request_Account__c rra : giveupRRAs) {
    			rraIds.add(rra.Task_ID__c);
    			
    			if (rra.Related_Feed_Item_Ids__c != null && rra.Related_Feed_Item_Ids__c != '') {
    				
    				for (String feedItemId : rra.Related_Feed_Item_Ids__c.split(',')) {
    					FeedComment fc = new FeedComment();
    					fc.CommentBody = 'This Request has been marked as ' + rra.Account_Request_Status__c +'.';
    					fc.FeedItemId = feedItemId;
    					
    					if (protectedAppConfig.User_Id__c != null && protectedAppConfig.User_Id__c != '') {
				        	fc.put('CreatedById', protectedAppConfig.User_Id__c);
				        }
    					feedCommentList.add(fc);
    				}
    			}
    		}
    		
    		for (Reference_Request_Account__c rra : noResponseRRAs) {
    			rraIds.add(rra.Task_ID__c);
    			
    			if (rra.Related_Feed_Item_Ids__c != null && rra.Related_Feed_Item_Ids__c != '') {
    				
    				for (String feedItemId : rra.Related_Feed_Item_Ids__c.split(',')) {
    					FeedComment fc = new FeedComment();
    					fc.CommentBody = 'This Request has been automatically closed as no response was received.';
    					fc.FeedItemId = feedItemId;
    					
    					if (protectedAppConfig.User_Id__c != null && protectedAppConfig.User_Id__c != '') {
				        	fc.put('CreatedById', protectedAppConfig.User_Id__c);
				        }
    					feedCommentList.add(fc);
    				}
    			}
    		}
    		
    		tasks = WithoutSharingHelperController.fetchTask(rraIds);
    		
    		for (Reference_Request_Account__c rra : noResponseRRAs) {
    			
    			if (rra.Task_ID__c != null && rra.Task_ID__c != '') {
    				
    				for (Task task : tasks) {
    					
    					if (rra.Task_ID__c == task.Id) {
    						task.Status = ConstantsController.COMPLETED;
    						task.Description = task.Description + '\n\n No Response received. Task automatically completed.';
    					}
    				}
    			}
    		}
    		
    		for (Reference_Request_Account__c rra : giveupRRAs) {
    			
				if (rra.Task_ID__c != null && rra.Task_ID__c != '') {
    				
    				for (Task task : tasks) {
    					
    					if (rra.Task_ID__c == task.Id) {
    						task.Status = ConstantsController.COMPLETED;
    						task.Description = task.Description + '\n\n Request marked as ' + rra.Account_Request_Status__c + '. Task automatically completed.';
    					}
    				}
    			}
    		}
    	}
    	
    	// Update list of tasks
        if (tasks.size() > 0) {
            tasks = WithoutSharingHelperController.updateTask(tasks);
        }
    	
    	if (feedCommentList != null && feedCommentList.size() > 0) {
    		WithoutSharingHelperController.insertFeedComments(feedCommentList);
    	}
    }
    
    /**
     * Method to create Reward records
     */
    static void issueRewardPoints(List<Reference_Request_Account__c> rewardsRraList, Set<Id> refIds) {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        
        if (cs.Automatically_Assign_Rewards__c) {
            List<Reward__c> rewards = new List<Reward__c>();
            Map<Id, List<Reference_Request_Account_Contact__c>> accountRRAC = new Map<Id, List<Reference_Request_Account_Contact__c>>();
            Reward__c reward;
            Map<Id, Decimal> refTypePoints = new Map<Id, Decimal>();
            Set<String> rraIds = new Set<String>();
            
            for (Reference_Request_Account__c rra : rewardsRraList) {
                rraIds.add(rra.Id);
            }
            
            for (Referenceability_Type__c ref : [SELECT Reward_points__c FROM Referenceability_Type__c 
            									WHERE Visible__c = true AND Id IN: refIds ORDER BY Name LIMIT: limits.getLimitQueryRows()]) {
                refTypePoints.put(ref.Id, (ref.Reward_points__c == null ? 0 : ref.Reward_points__c));
            }
            
            for (Reference_Request_Account_Contact__c rrac : [SELECT Contact__c, Reference_Request_Account__c 
            							FROM Reference_Request_Account_Contact__c WHERE Reference_Request_Account__c In: rraIds]) {
            								
                if (!accountRRAC.containsKey(rrac.Reference_Request_Account__c)) {
                    accountRRAC.put(rrac.Reference_Request_Account__c, new List<Reference_Request_Account_Contact__c>());
                }
                accountRRAC.get(rrac.Reference_Request_Account__c).add(rrac);
            }
            
            for (Reference_Request_Account__c rra : rewardsRraList) {
            	
                if (accountRRAC.containsKey(rra.Id)) {
                	
                	//1 line code removed to resolve ticket #810
                    for (Reference_Request_Account_Contact__c rrac : accountRRAC.get(rra.Id)) {
                        reward = new Reward__c();
                        reward.Account__c = rra.Account__c;
                        reward.Contact__c = rrac.Contact__c;
                        reward.Referenceability_Type__c = rra.Reference_Type_Needed__c;
                        reward.Transaction__c = ConstantsController.ISSUE;
                        reward.RewardDate__c = Date.today();
                        reward.Automatically_Assigned__c = true;
                        reward.Account_Request__c = rra.Id;
                        reward.Contact_Request__c = rrac.Id;
                        
                        if (ConstantsController.isfromInfluitiveBatch) {
                            String influitiveChallengeData = rrac.Influitive_Challenge_Data__c;
                            String iEventId = '';
                            Integer iPoints = 0;
                            
                            if (influitiveChallengeData != null) {
                                iEventId = influitiveChallengeData.split('::')[0];
                                iPoints = Integer.valueof(influitiveChallengeData.split('::')[1]);
                            }
                            reward.Available_Points__c = iPoints;
                            reward.Amount__c = iPoints;
                            reward.Influitive_ID2__c = iEventId;
                        } else {
                            reward.Available_Points__c = refTypePoints.get(rra.Reference_Type_Needed__c);
                            reward.Amount__c = refTypePoints.get(rra.Reference_Type_Needed__c);
                        }
                        
                        if (cs.Expire_Rewards__c) {
                            reward.Expiration_Date__c = UtilityController.rewardsExpritationDate(cs);
                        }
                        rewards.add(reward);
                    }
                } else {
                    reward = new Reward__c();
                    reward.Account__c = rra.Account__c;
                    reward.Referenceability_Type__c = rra.Reference_Type_Needed__c;
                    reward.Transaction__c = ConstantsController.ISSUE;
                    reward.RewardDate__c = Date.today();
                    reward.Automatically_Assigned__c = true;
                    reward.Account_Request__c = rra.Id;
                    
                    if (ConstantsController.isfromInfluitiveBatch) {
                        String influitiveChallengeData = rra.Influitive_Challenge_Data__c;
                        String iEventId = '';
                        Integer iPoints = 0;
                        
                        if (influitiveChallengeData != null) {
                            iEventId = influitiveChallengeData.split('::')[0];
                            iPoints = Integer.valueof(influitiveChallengeData.split('::')[1]);
                        }
                        reward.Available_Points__c = iPoints;
                        reward.Amount__c = iPoints;
                        reward.Influitive_ID2__c = iEventId;
                    } else {
                        reward.Available_Points__c = refTypePoints.get(rra.Reference_Type_Needed__c);
                        reward.Amount__c = refTypePoints.get(rra.Reference_Type_Needed__c);
                    }
                    
                    if (cs.Expire_Rewards__c) {
                        reward.Expiration_Date__c = UtilityController.rewardsExpritationDate(cs);
                    }
                    rewards.add(reward);
                }
            }
            
            if (rewards.size() > 0) {
                ConstantsController.shouldRewardRecordsCreated = false;
                rewards = WithoutSharingHelperController.upsertRewards(rewards);
            }
        }
    }


    /**
     * Method to update Reference Request and Contact request
     */
    static void updateRrAndRraDetails(Set<String> RRIds, Set<String> RRAIds) {
        List<Reference_Request_Account_Contact__c> listRRAC = new List<Reference_Request_Account_Contact__c>();
        
        if (RRAIds.size() > 0) {
        	
            for (Reference_Request_Account_Contact__c rrac : [SELECT Name, Id, Reference_Request_Account__c, 
            				Reference_Request_Account__r.Account_Request_Status__c, Contact_Request_Status__c 
            				FROM Reference_Request_Account_Contact__c WHERE Reference_Request_Account__c IN: RRAIds 
            				AND (Contact_Request_Status__c = : ConstantsController.NOT_STARTED 
            				OR Contact_Request_Status__c = : ConstantsController.IN_PROGRESS 
            				OR Contact_Request_Status__c = : ConstantsController.ONHOLD)]) {
                rrac.Contact_Request_Status__c = rrac.Reference_Request_Account__r.Account_Request_Status__c;
                rrac.Project_Owner__c = (rrac.Project_Owner__c == null ? Userinfo.getUserId() : rrac.Project_Owner__c);
                listRRAC.add(rrac);
            }
            
            if (listRRAC.size() > 0) {
                update listRRAC;
            }
        }
        
        if (RRIds.size() > 0) {
            List<Reference_Request__c> listRR = new List<Reference_Request__c>();
            
            for (Reference_Request__c rr : WithoutSharingHelperController.getRefRequestRecords(RRIds)) {
            	
                if (rr.Unspecified_Requests__r.size() == 0 && rr.Reference_Request_Accounts__r.size() == 0) {
                    rr.Reference_Request_Status__c = ConstantsController.COMPLETED;
                    listRR.add(rr);
                } else {
                	
                    if (rr.Reference_Request_Status__c == ConstantsController.NOT_STARTED) {
                        rr.Reference_Request_Status__c = ConstantsController.IN_PROGRESS;
                        listRR.add(rr);
                    }
                }
            }
            
            if (listRR.size() > 0) {
                ConstantsController.shouldArAndUrUpdate = false;
                //changes regarding #795
                WithoutSharingHelperController.updateRefRequests(listRR);
            }
        }
    }

    /**
     * Method to update the account details related to RUL
     */
    static void updateAccountDetails(List<Reference_Request_Account__c> newRRAList) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> processedAccountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        List<Reference_Basic_Information__c> updateAccount = new List<Reference_Basic_Information__c>();
        
        for (Reference_Request_Account__c tempObj : newRRAList) {
            accountIds.add(tempObj.Account__c);
            userIds.add(tempObj.CreatedById);
        }
        //map to get the user Name 
        Map<Id, User> userMap = WithoutSharingHelperController.getUserMap(userIds);
        Map<Id, Reference_Basic_Information__c> accountMap = new Map<Id, Reference_Basic_Information__c>();
        
        for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getAccountReferenceProfiles(accountIds)) {
            accountMap.put(rbi.Account__C, rbi);
        }
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Map<String, List<Reference_Request_Account__c>> rrAccMapForDefaultCompleteUse = new Map<String, List<Reference_Request_Account__c>>();
        Map<String, List<Reference_Request_Account__c>> rrAccMapForCompleteUse = new Map<String, List<Reference_Request_Account__c>>();
        Map<Id, List<Reference_Request_Account__c>> rrAccMap = new Map<Id, List<Reference_Request_Account__c>>();
        
        for (Reference_Request_Account__c tempObj : WithoutSharingHelperController.getAccountRequests1(accountIds)) {
            
            if (tempObj.Account_Request_Status__c == ConstantsController.COMPLETED) {
                
                if (!rrAccMap.containsKey(tempObj.Account__c)) {
                    rrAccMap.put(tempObj.Account__c, new list<Reference_Request_Account__c>());
                }
                rrAccMap.get(tempObj.Account__c).add(tempObj);
                
                if (accountMap.containsKey(tempObj.Account__c)
                			&& tempObj.Activity_Date__c != null
                			&& (tempObj.Activity_Date__c).daysBetween(date.today()) <= accountMap.get(tempObj.Account__c).RUL_Period__c) {
                    
                    if (!rrAccMapForCompleteUse.containsKey(tempObj.Account__c)) {
                        rrAccMapForCompleteUse.put(tempObj.Account__c, new list<Reference_Request_Account__c>());
                    }
                    rrAccMapForCompleteUse.get(tempObj.Account__c).add(tempObj);
                }
                
                if (tempObj.Activity_Date__c != null && (tempObj.Activity_Date__c).daysBetween(date.today()) <= cs.RUL_Period__c) {
                    
                    if (!rrAccMapForDefaultCompleteUse.containsKey(tempObj.Account__c)) {
                        rrAccMapForDefaultCompleteUse.put(tempObj.Account__c, new list<Reference_Request_Account__c>());
                    }
                    rrAccMapForDefaultCompleteUse.get(tempObj.Account__c).add(tempObj);
                }
            } else if (tempObj.Account_Request_Status__c == ConstantsController.NO_LONGER_NEEDED && cs.Consider_No_longer_needed_a_use__c) {
                
                if (!rrAccMap.containsKey(tempObj.Account__c)) {
                    rrAccMap.put(tempObj.Account__c, new list<Reference_Request_Account__c>());
                }
                rrAccMap.get(tempObj.Account__c).add(tempObj);
                
                if (accountMap.containsKey(tempObj.Account__c)
                			&& tempObj.Activity_Date__c != null
                			&& (tempObj.Activity_Date__c).daysBetween(date.today()) <= accountMap.get(tempObj.Account__c).RUL_Period__c) {
                    
                    if (!rrAccMapForCompleteUse.containsKey(tempObj.Account__c)) {
                        rrAccMapForCompleteUse.put(tempObj.Account__c, new list<Reference_Request_Account__c>());
                    }
                    rrAccMapForCompleteUse.get(tempObj.Account__c).add(tempObj);
                }
            }
        }
        accountIds.clear();
        
        for (Reference_Request_Account__c tempObj : newRRAList) {
            
            if (accountMap.containsKey(tempObj.Account__c)) {
                Reference_Basic_Information__c acc = accountMap.get(tempObj.Account__c);
                
                if (!acc.Is_Referenceable__c && !acc.Reference_Program_Candidate__c && !ConstantsController.forcecompleted) {
                    acc.Is_Referenceable__c = true;
                    acc.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                }
                
                if (rrAccMapForCompleteUse.containsKey(tempObj.Account__c)) {
                    acc.RUL_Activities_used__c = rrAccMapForCompleteUse.get(tempObj.Account__c).size();
                } else {
                    acc.RUL_Activities_used__c = 0;
                }
                
                if (tempObj.Account_Request_Status__c == ConstantsController.COMPLETED && !ConstantsController.forcecompleted) {
                    
                    if (acc.RUL_Last_Activity_Date__c != null
                    			&& acc.RUL_Last_Activity_Date__c < tempObj.Activity_Date__c) {
                        acc.RUL_Last_Activity_Date__c = date.valueOf(tempObj.Activity_Date__c);
        			} else if (acc.RUL_Last_Activity_Date__c == null) {
                        acc.RUL_Last_Activity_Date__c = date.valueOf(tempObj.Activity_Date__c);
        			}

                    if (rrAccMapForDefaultCompleteUse.containsKey(tempObj.Account__c)) {
                        acc.Default_Period_Completed_Uses__c = rrAccMapForDefaultCompleteUse.get(tempObj.Account__c).size();
                    } else {
                        acc.Default_Period_Completed_Uses__c = 0;
                    }
                }
                
                if (tempObj.Activity_Date__c != null
                			&& (tempObj.Activity_Date__c).daysBetween(date.today()) <= acc.RUL_Period__c) {
                    
                    if (userMap != null && userMap.containsKey(tempObj.CreatedById)) {
                        acc.RUL_Last_Updated_By__c = userMap.get(tempObj.CreatedById).Name
                        									+ ',' + tempObj.CreatedDate.format();
                    }
                    
                    if (acc.Account_Level_RUL__c
                    			&& acc.RUL_Activities_will_do__c != null
                    			&& acc.RUL_Activities_used__c >= acc.RUL_Activities_will_do__c
                    			&& acc.RUL_Limit_Reached__c == false) {
                        acc.RUL_Limit_Reached__c = true;
                        acc.RUL_Date_Available__c = date.valueOf(acc.RUL_Last_Activity_Date__c.addDays(integer.valueOf(acc.RUL_Period__c)));
                    }

                }
                
                if (rrAccMap.get(tempObj.Account__c) != null) {
                    acc.Total_Reference_Use__c = rrAccMap.get(tempObj.Account__c).size();
                } else {
                    acc.Total_Reference_Use__c = 0;
                }
                
                if (acc.Account_Level_RUL__c
                			&& (acc.RUL_Activities_used__c == 0
                				|| acc.RUL_Activities_used__c < acc.RUL_Activities_will_do__c)) {
                    acc.RUL_Limit_Reached__c = false;
                }
                accountMap.put(tempObj.Account__c, acc);
                accountIds.add(tempObj.Account__c);
            }
        }
        
        for (String AID : accountIds) {
            updateAccount.add(accountMap.get(AID));
        }
        
        if (updateAccount.size() > 0) {
            WithoutSharingHelperController.updateRBI(updateAccount);
        }
    }
}