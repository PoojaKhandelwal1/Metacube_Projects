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
 * VF Page: Nomination Approval
 * Description : Trigger used to handle Nomination Approval.
 * Last modified date:1 June 2017
 * Modified by: Rajesh for ticket #841
 */ 
public with sharing class NominationTriggerHandler {
    /**
     * Properties and variables
     */
    public static List<Nomination__c> newNominations;
    public static List<Nomination__c> oldNominations;
    public static Map<Id, Nomination__c> newMap;
    public static Map<Id, Nomination__c> oldMap;
    private static Boolean checkChatterSetting;
    private static Boolean checkEmailSetting;
    private static Boolean checkSlackSetting;
    private static Boolean checkAcceptedEmailSetting;
    private static Boolean checkAcceptedChatterSetting;
    private static Boolean checkAcceptedSlackSetting;
    private static Boolean checkRejectedEmailSetting;
    private static Boolean checkRejectedChatterSetting;
    private static Boolean checkRejectedSlackSetting;
    
    /**
     * Method called on before insert of Nomination
     */
    public static void onBeforeInsert() {
        
        try {
            //for Influitive integration 
            Set<String> setContactId = new Set<String>();
            Custom_Settings__c cs = UtilityController.getCustomSettings(); 
            
            if (cs.Is_Influitive_Integration_Enabled__c != null && cs.Is_Influitive_Integration_Enabled__c) {
                
                for (Nomination__c nomi : newNominations) {
                    
                    if (ConstantsController.isCallFromInfluitiveAPI) {
                    
                        if (nomi.Contact__c == null) {
                            nomi.addError(System.Label.Error_Crm_Contact_Id);
                        }
                        
                        if (nomi.Influitive_Id__c == null) {
                            nomi.addError(System.Label.Error_Crm_Influitive_Id);
                        }                    
                    }
                    if (nomi.Contact__c != null && nomi.Account__c == null) {
                        setContactId.add(nomi.Contact__c);
                    }
                }
                Map<Id, Contact> mapContact = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN :setContactId LIMIT : limits.getLimitQueryRows()]);
                
                for (Nomination__c nomi : newNominations) {
                    
                    if (nomi.Contact__c != null && nomi.Account__c == null && mapContact != null && mapContact.size() > 0 && 
                            mapContact.containsKey(nomi.Contact__c)) {
                        nomi.Account__c = mapContact.get(nomi.Contact__c).AccountId;
                    }
                }
            }
        } catch (exception e) {
            throw e;
        }
    }
    
    /**
     * Method called on before update of Nomination
     */
    public static void onBeforeUpdate() {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        checkChatterSetting = (UtilityController.isNativeChatterSetting && cs.Nomination_Chatter__c);
        checkEmailSetting = cs.Nomination_Email__c;
        checkSlackSetting = cs.Enable_Slack_Integration__c && cs.Nomination_Slack__c;
        checkAcceptedEmailSetting = cs.Nomination_Accepted_Email__c;
        checkAcceptedChatterSetting = (UtilityController.isNativeChatterSetting && cs.Nomination_Accepted_Chatter__c);
        checkAcceptedSlackSetting = cs.Enable_Slack_Integration__c && cs.Nomination_Accepted_Slack__c;
        checkRejectedEmailSetting = cs.Nomination_Rejected_Email__c;
        checkRejectedChatterSetting = (UtilityController.isNativeChatterSetting && cs.Nomination_Rejected_Chatter__c);
        checkRejectedSlackSetting = cs.Enable_Slack_Integration__c && cs.Nomination_Rejected_Slack__c;
        
        for (Nomination__c nomi : newNominations) {
            
            if (oldMap.get(nomi.Id).Disposition__c != null && oldMap.get(nomi.Id).Disposition__c != newMap.get(nomi.Id).Disposition__c) {
                nomi.addError(ConstantsController.ERROR_NOMINATION_COMPLETED);
                return;
            }
            
            if (nomi.Disposition__c == ConstantsController.DECLINED && (nomi.Note__c == null || nomi.Note__c == '')) {
                nomi.addError(ConstantsController.ERROR_NOMINATION_REJECTION_NOTE);
                return;
            }
            
            if (nomi.Status__c == ConstantsController.COMPLETED && nomi.Disposition__c == null) {
                nomi.addError(ConstantsController.ERROR_NOMINATION_COMPLETED_DISPOSITION);
                return;
            }
            
            if (nomi.Disposition__c == ConstantsController.APPROVED || nomi.Disposition__c == ConstantsController.DECLINED) {
                nomi.Status__c = ConstantsController.COMPLETED;
                nomi.Email_Enabled__c = checkEmailSetting;
            }

        }
    }
    
    /**
     * Method called on after insert of Nomination
     */
    public static void onAfterInsert() {}
    
    /**
     * Method called on after update of Nomination
     */
    public static void onAfterUpdate() {  
        
        // Get custom setting
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        //Referenceability_Type__c refType;
        List<Referenceability_Type__c> refType;
        
        // Get Sales reward Referenceability
        if (cs.Auto_Assign_Sales_Rewards__c) {
            List<String> lstRefType = new List<String>();
            lstRefType.add(ConstantsController.NOMINATION_APPROVED);  
            refType = WithoutSharingHelperController.getReferenceabilityRewardDetails(lstRefType);
        } 
        // Insert sales reward on nomination approved
        List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
        Set<Id> approvedNominations = new Set<Id>();
        Set<Id> declinedNominations = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>(); 
        
        for (Nomination__c nomi : newNominations) {
            
            // re #627 -Check if nomination already approved then this step will skip
            if (nomi.Disposition__c == ConstantsController.APPROVED && oldMap.get(nomi.Id).Disposition__c == null && 
                        nomi.Disposition__c != oldMap.get(nomi.Id).Disposition__c) {
                approvedNominations.add(nomi.Id);
                
                // re #632- Check Sales point before insert reward.                
                if (cs.Auto_Assign_Sales_Rewards__c && refType.size() > 0  && refType[0].Sales_Point__c != null) {
                                                            
                    rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c, Referenceability_Type__c = refType[0].Id,
                                                    Transaction__c = ConstantsController.ISSUE, 
                                                    RewardDate__c = Date.Today(), User__c = nomi.ownerId));
                        
                    ownerIds.add(nomi.ownerId);
                         
                }
            } else if (nomi.Disposition__c == ConstantsController.DECLINED && oldMap.get(nomi.Id).Disposition__c == null 
                        && nomi.Disposition__c != oldMap.get(nomi.Id).Disposition__c) {
                declinedNominations.add(nomi.Id);
            } 
        }
        
        if (approvedNominations.size() > 0) {
            completeAllNomination(approvedNominations, ConstantsController.APPROVED, cs);
        }
        
        if (declinedNominations.size() > 0) {
            completeAllNomination(declinedNominations, ConstantsController.DECLINED, cs);
        }
        
        if (rewardsToBeInsert.size() > 0 &&  RefEdgeEditionFeatures.isBasic == false && cs.Enable_Sales_Rewards_Notification__c ==  true ) {
            UtilityController.isUserProfileExist(ownerIds);           
            WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
        }
    }
    
    /**
     * Method to notify users of Completed Nomination
     */
    public static void completeAllNomination(Set<Id> nominations, String status, Custom_Settings__c cs) { 
        String SUBJECT = '';
        String MSG_BODY = '';
        Set<String> accSet = new Set<String>();
        Set<String> conSet = new Set<String>();
        List<ChatterWrapper> chatterList = new List<ChatterWrapper>();
        List<Nomination__c> nomiList = WithoutSharingHelperController.getNominations(nominations);
        String headerDocId = '';
        String footerDocId = '';
        Data_Mapping__c acceptedNotification = new Data_Mapping__c();
        Data_Mapping__c rejectedNotification = new Data_Mapping__c();
        Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Nomination_Accepted_Email__c', UtilityController.appNamespace() + 'Nomination_Rejected_Email__c'};
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();

        for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                    FROM Data_Mapping__c
                                    WHERE Object__c = 'Notification'
                                    AND (Field_API_Name__c IN :notificationFieldNames
                                        OR Section_Name__c = 'email header doc'
                                        OR Section_Name__c = 'email footer doc')]) {

            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Nomination_Accepted_Email__c') {
                acceptedNotification = dm;
            } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Nomination_Rejected_Email__c') {
                rejectedNotification = dm;
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

        for (Nomination__c nomi : nomiList) {
            userEmailMap.put(nomi.CreatedById, '');
        }

        for (User u : WithoutSharingHelperController.getUserMap(userEmailMap.keySet()).values()) {
            
            if (u.IsActive) {
                userEmailMap.put(u.Id, u.Email);
            }
        }
        
        if (status == ConstantsController.DECLINED) {
            SUBJECT = rejectedNotification.Section_Name__c;
            MSG_BODY = rejectedNotification.DC_Message__c + '\n\n' + rejectedNotification.Default__c;
            
            for (Nomination__c nomi : nomiList) {
                
                if (nomi.Contact__c != null && checkRejectedChatterSetting) {
                    MSG_BODY = MSG_BODY.replace('[Account/Contact Name]', nomi.Contact__r.Name != null ? nomi.Contact__r.Name : '')
                                        .replace('[Contact Name]', nomi.Contact__r.Name != null ? nomi.Contact__r.Name : '')
                                        .replace('[Account Name]', nomi.Account__r.Name != null ? nomi.Account__r.Name : '')
                                        .replace('[Nomination Note]', nomi.Note__c == null ? '' : nomi.Note__c);
                    chatterList.add(new ChatterWrapper(SUBJECT, MSG_BODY, nomi.CreatedById));
                } else if (checkRejectedChatterSetting) {
                    MSG_BODY = MSG_BODY.replace('[Account/Contact Name]', nomi.Account__r.Name != null ? nomi.Account__r.Name : '')
                                        .replace('Contact: [Contact Name]\n', '')
                                        .replace('[Account Name]', nomi.Account__r.Name != null ? nomi.Account__r.Name : '')
                                        .replace('[Nomination Note]', nomi.Note__c == null ? '' : nomi.Note__c);
                    chatterList.add(new ChatterWrapper(SUBJECT, MSG_BODY, nomi.CreatedById));
                }

                if (checkRejectedSlackSetting) {
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('userEmail', userEmailMap.get(nomi.CreatedById));
                    
                    if (nomi.Contact__c != null) {
                        MSG_BODY = MSG_BODY.replace('[Account/Contact Name]', nomi.Contact__r.Name != null ? nomi.Contact__r.Name : '')
                                        .replace('[Contact Name]', nomi.Contact__r.Name != null ? nomi.Contact__r.Name : '')
                                        .replace('[Account Name]', nomi.Account__r.Name != null ? nomi.Account__r.Name : '')
                                        .replace('[Nomination Note]', nomi.Note__c == null ? '' : nomi.Note__c);
                    } else {
                        MSG_BODY = MSG_BODY.replace('[Account/Contact Name]', nomi.Account__r.Name != null ? nomi.Account__r.Name : '')
                                        .replace('Contact: [Contact Name]\n', '')
                                        .replace('[Account Name]', nomi.Account__r.Name != null ? nomi.Account__r.Name : '')
                                        .replace('[Nomination Note]', nomi.Note__c == null ? '' : nomi.Note__c);
                    }
                    tempReqBodyMap.put('text', '*' + SUBJECT + '*\n' + MSG_BODY);
                    messagesList.add(tempReqBodyMap);
                }
                
                if (nomi.Contact__c != null && checkRejectedEmailSetting) {
                    MSG_BODY = MSG_BODY.replace('[Account/Contact Name]', nomi.Contact__r.Name != null ? nomi.Contact__r.Name : '')
                                        .replace('[Contact Name]', nomi.Contact__r.Name != null ? nomi.Contact__r.Name : '')
                                        .replace('[Account Name]', nomi.Account__r.Name != null ? nomi.Account__r.Name : '')
                                        .replace('[Nomination Note]', nomi.Note__c == null ? '' : nomi.Note__c);
                    listmail.add(MailChatterController.prepareEmail(SUBJECT, nomi.CreatedById, MSG_BODY, false, headerDocId, footerDocId));
                } else if (checkRejectedEmailSetting) {
                    MSG_BODY = MSG_BODY.replace('[Account/Contact Name]', nomi.Account__r.Name != null ? nomi.Account__r.Name : '')
                                        .replace('Contact: [Contact Name]\n', '')
                                        .replace('[Account Name]', nomi.Account__r.Name != null ? nomi.Account__r.Name : '')
                                        .replace('[Nomination Note]', nomi.Note__c == null ? '' : nomi.Note__c);
                    listmail.add(MailChatterController.prepareEmail(SUBJECT, nomi.CreatedById, MSG_BODY, false, headerDocId, footerDocId));
                }
            }
        }
        
        if (status == ConstantsController.APPROVED) {
            SUBJECT = acceptedNotification.Section_Name__c;
            MSG_BODY = acceptedNotification.DC_Message__c + '\n\n' + acceptedNotification.Default__c;
            
            for (Nomination__c nomi : nomiList) {
                
                if (nomi.Contact__c != null && checkAcceptedChatterSetting) {
                    MSG_BODY = MSG_BODY.replace('[Account/Contact Name]', (nomi.Contact__r.Name != null ? nomi.Contact__r.Name : ''))
                                        .replace('[Nomination Note]', nomi.Note__c == null ? '' : nomi.Note__c);
                    chatterList.add(new ChatterWrapper(SUBJECT.replace('[Account/Contact Name]', (nomi.Contact__r.Name != null ? nomi.Contact__r.Name : '') + ' with ' + nomi.Contact__r.Account.Name), MSG_BODY, nomi.CreatedById));
                } else if (checkAcceptedChatterSetting) {
                    MSG_BODY = MSG_BODY.replace('[Account/Contact Name]', (nomi.Account__r.Name != null ? nomi.Account__r.Name : ''))
                                        .replace('[Nomination Note]', nomi.Note__c == null ? '' : nomi.Note__c);
                    chatterList.add(new ChatterWrapper(SUBJECT.replace('[Account/Contact Name]', (nomi.Account__r.Name != null ? nomi.Account__r.Name : '')), MSG_BODY, nomi.CreatedById));
                }

                if (checkAcceptedSlackSetting) {
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('userEmail', userEmailMap.get(nomi.CreatedById));
                    String tempSubject;

                    if (nomi.Contact__c != null) {
                        tempSubject = SUBJECT.replace('[Account/Contact Name]', (nomi.Contact__r.Name != null ? nomi.Contact__r.Name : '') + ' with ' + nomi.Contact__r.Account.Name);
                        MSG_BODY.replace('[Account/Contact Name]', (nomi.Contact__r.Name != null ? nomi.Contact__r.Name : ''))
                                        .replace('[Nomination Note]', nomi.Note__c == null ? '' : nomi.Note__c);
                    } else {
                        tempSubject = SUBJECT.replace('[Account/Contact Name]', (nomi.Account__r.Name != null ? nomi.Account__r.Name : ''));
                        MSG_BODY = MSG_BODY.replace('[Account/Contact Name]', (nomi.Account__r.Name != null ? nomi.Account__r.Name : ''))
                                        .replace('[Nomination Note]', nomi.Note__c == null ? '' : nomi.Note__c);
                    }
                    tempReqBodyMap.put('text', '*' + tempSubject + '*\n' + MSG_BODY);
                    messagesList.add(tempReqBodyMap);
                }
                
                if (nomi.Contact__c != null && checkAcceptedEmailSetting) {
                    MSG_BODY = MSG_BODY.replace('[Account/Contact Name]', (nomi.Contact__r.Name != null ? nomi.Contact__r.Name : ''))
                                        .replace('[Nomination Note]', nomi.Note__c == null ? '' : nomi.Note__c);
                    listmail.add(MailChatterController.prepareEmail(SUBJECT.replace('[Account/Contact Name]', (nomi.Contact__r.Name != null ? nomi.Contact__r.Name : '') + ' with ' + nomi.Contact__r.Account.Name), nomi.CreatedById,
                                    MSG_BODY, false, headerDocId, footerDocId));
                } else if (checkAcceptedEmailSetting) {
                    MSG_BODY = MSG_BODY.replace('[Account/Contact Name]', (nomi.Account__r.Name != null ? nomi.Account__r.Name : ''))
                                        .replace('[Nomination Note]', nomi.Note__c == null ? '' : nomi.Note__c);
                    listmail.add(MailChatterController.prepareEmail(SUBJECT.replace('[Account/Contact Name]', (nomi.Account__r.Name != null ? nomi.Account__r.Name : '')), nomi.CreatedById,
                                    MSG_BODY, false, headerDocId, footerDocId));
                }
            }
        }
        prepareChatterTaskItem(chatterList);
        
        if (listmail.size() > 0) {
            Messaging.sendEmail(listmail);
        }

        if (messagesList != null && messagesList.size() > 0) {
            slackReqBody.put('messages', messagesList);
            UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
        }
    }
    
    /**
     * Method to prepare chatter email task Item
     */
    private static void prepareChatterTaskItem(List<ChatterWrapper> chatterList) {
        List<Sobject> postFeedItems = new List<Sobject>();
        
        if (checkChatterSetting) {
            
            //Prepare FeedItem List
            for (ChatterWrapper CW : chatterList) {
                postFeedItems.add(MailChatterController.preparePost(CW.SUBJECT, CW.targetId, CW.MSG_BODY, ''));
            }
        }
        
        //Insert list of postFeedItems
        if (postFeedItems.size() > 0) {
            postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
        }
    }
    
    /**
     * Wrapper Class
     */
    public class ChatterWrapper {
        public String SUBJECT;
        public String MSG_BODY;
        public String targetId;
        public chatterWrapper(String SUBJECT, String MSG_BODY, String targetId) {
            this.SUBJECT = SUBJECT;
            this.MSG_BODY = MSG_BODY;
            this.targetId = targetId;
        }
    }
}