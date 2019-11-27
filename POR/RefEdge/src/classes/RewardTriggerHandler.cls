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
 * Trigger: RewardTrigger
 * Description : Handler class for DML operations on rewards including Add, Update AND delete oprations using Refedge, dataloader AND infultive APIs. 
 * Modified by: Rajesh @Jan/01/2018
 */
public with sharing class RewardTriggerHandler {
    
    private static Custom_Settings__c cs = UtilityController.getCustomSettings();
    
    /**
     * Method called on before update of Reward
     */
    public static void onBeforeUpdate(List<Reward__c> newList, Map<Id, Reward__c> newMap, Map<Id, Reward__c> oldMap) {
        Set<String> accountIds = new Set<String>();
        Set<String> userIds = new Set<String>();
        Map<Id, List<Reward__c>> rewardMap = new Map<Id, List<Reward__c>>();
        
        for (Reward__c reward : newList) {
            
            if (reward.User__c == null) {
            
                //Validation for Amount in reward updation -#1164
                if (reward.Transaction__c  == ConstantsController.ISSUE || reward.Transaction__c  == ConstantsController.REDEEM) {
                    
                    if (reward.Amount__c < 0) {
                        reward.addError(System.Label.AMOUNT_0);
                    } 
                } else  {
                    reward.addError(System.Label.Transaction_Details);
                }
            }
            
            if (reward.Account__c != null) {
                accountIds.add(reward.Account__c);
                rewardMap.put(reward.Account__c, new List<Reward__c>());
            }
            
            if (reward.User__c != null) {
                userIds.add(reward.User__c);
            }
        }
        
        if (accountIds != null && accountIds.size()> 0) {
            for (Reward__c re: [SELECT Account__c, Contact__c, Available_Points__c FROM Reward__c WHERE Account__c IN: accountIds 
                                                                        AND Available_Points__c != null AND Transaction__c =: ConstantsController.ISSUE]) {
                rewardMap.get(re.Account__c).add(re);
            }
        }
        // Added for sales user
        Map<Id, User_Profile__c> userIdToProfilesMap = new Map<Id, User_Profile__c>();
        
        for (User_Profile__c profile: [SELECT Id, User__c, Available_Points__c FROM User_Profile__c WHERE User__c =: userIds LIMIT: limits.getLimitQueryRows()]) {
            userIdToProfilesMap.put(profile.User__c, profile);
        }
        
        for (Reward__c reward: newList) {
            
            if (oldMap.get(reward.Id).Amount__c != newMap.get(reward.Id).Amount__c && newMap.get(reward.Id).Expired__c) {
                reward.addError(system.label.Cannot_update_expired_reward);
            }
            
            if (oldMap.get(reward.Id).Expired__c == newMap.get(reward.Id).Expired__c && oldMap.get(reward.Id).Expiration_Date__c != newMap.get(reward.Id).Expiration_Date__c) {
                
                if (reward.Expiration_Date__c <= system.today()) {
                    reward.addError(system.label.Expiration_Date_must_be_a_future_date);
                } else {
                    reward.Expired__c = false;
                }
            }
            
            if (oldMap.get(reward.Id).Expired__c != newMap.get(reward.Id).Expired__c) {
                
                if (newMap.get(reward.Id).Expired__c) {
                    
                    if (reward.Transaction__c == ConstantsController.REDEEM) {
                        reward.addError(system.label.You_cannot_expire_any_Redeem_Reward);
                    } else {
                        reward.Expired_Points__c = reward.Available_Points__c;
                        reward.Available_Points__c = 0;
                        reward.Expiration_Date__c = system.today();
                    }
                } else if (!newMap.get(reward.Id).Expired__c) {
                   
                    if (reward.Expiration_Date__c <= system.today()) {
                        reward.addError(system.label.Expiration_Date_must_be_a_future_date);
                    } else {
                        reward.Available_Points__c = reward.Expired_Points__c;
                        reward.Expired_Points__c = 0;
                    }
                }
            }
            
            //REF-1964 
            if (!ConstantsController.isCallFromInfluitiveAPI) {

                if (oldMap.get(reward.Id).Amount__c != newMap.get(reward.Id).Amount__c) {
                
                    if (reward.Transaction__c == ConstantsController.ISSUE && !reward.Expired__c) {
                        
                        if (reward.Amount__c < 1) {
                            reward.addError(System.Label.AMOUNT_0);
                        }
                        
                        if (reward.Available_Points__c >= oldMap.get(reward.Id).Amount__c - newMap.get(reward.Id).Amount__c) {
                            reward.Available_Points__c = reward.Available_Points__c + newMap.get(reward.Id).Amount__c - oldMap.get(reward.Id).Amount__c;
                        } else {
                            reward.addError(System.Label.MIN_REWARD_AMOUNT + ' ' + (oldMap.get(reward.Id).Amount__c - reward.Available_Points__c));
                        }
                    } else if (reward.Transaction__c == ConstantsController.REDEEM && !reward.Expired__c) {
                        
                        if (reward.Account__c != null && rewardMap != null 
                                                        && rewardMap.get(reward.Account__c) != null) {
                            Decimal amount = 0;
                            
                            if (reward.Contact__c != null) {
                                for (Reward__c re: rewardMap.get(reward.Account__c)) {
                                    if (re.Contact__c == reward.Contact__c) {
                                        amount += re.Available_Points__c;
                                    }
                                }
                            } else {
                                for (Reward__c re: rewardMap.get(reward.Account__c)) {
                                    if (re.Contact__c == null) {
                                        amount += re.Available_Points__c;
                                    }
                                }
                            }
                            
                            if (reward.Amount__c <= 0 || ((newMap.get(reward.Id).Amount__c - oldMap.get(reward.Id).Amount__c)> amount)) {
                                reward.addError(System.Label.MAX_REWARD_AMOUNT + ' ' + (amount + oldMap.get(reward.Id).Amount__c));
                            }
                        } else if (reward.User__c != null && (reward.Amount__c <= 0 || (userIdToProfilesMap != null 
                                    && (newMap.get(reward.Id).Amount__c - oldMap.get(reward.Id).Amount__c) > userIdToProfilesMap.get(reward.User__c).Available_Points__c))) {
                            // Added for sales user
                            reward.addError(System.Label.MAX_REWARD_AMOUNT + ' ' + (userIdToProfilesMap.get(reward.User__c).Available_Points__c + oldMap.get(reward.Id).Amount__c));
                        }
                    }
                }
            }
        }
    }
    /**
     * Method called on before delete of Reward
     */
    public static void onBeforeDelete(List<Reward__c> oldList) {
        
        try {
            
            if (ConstantsController.shouldRewardRecordsValidatedOnDelete) {
                
                for (Reward__c reward: oldList) {
                   
                    if (reward.Transaction__c == ConstantsController.ISSUE && ((!reward.Expired__c && reward.Amount__c > reward.Available_Points__c) 
                                                                    || (reward.Expired__c && reward.Amount__c > reward.Expired_Points__c))) {
                        reward.addError(System.Label.RewardDelete);
                    }
                }
            }
        } catch (exception e) {
            throw e;
        }
    }
    /**
     * Method called on before insert of Reward
     */
    public static void onBeforeInsert(List<Reward__c> newList) {
        try { 
            //for Influitive integration 
            Set<String> setContactId = new Set<String>();
            
            /************Changes starts FROM here for ticket #1164*************/
            if ((!system.isBatch() && !system.isFuture() && cs.Is_Influitive_Integration_Enabled__c 
                                                        && ConstantsController.isInfluitiveNotRunning)) {

                for (Reward__c reward : newList) {
                
                    if (ConstantsController.isCallFromInfluitiveAPI) {
                        
                        if (reward.Contact__c == null) {
                            reward.addError(System.Label.Error_Crm_Contact_Id);
                        }
                            
                        if (reward.Influitive_ID2__c == null) {
                            reward.addError(System.Label.Error_Crm_Influitive_Id);
                        }                    
                    }
                   
                    if (reward.Contact__c != null && reward.Account__c == null) {
                        setContactId.add(reward.Contact__c);
                    }
                }
                Map<Id, Contact> mapContact = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN :setContactId]);
               
                for (Reward__c reward : newList) { 
                   
                     
                    if (reward.Contact__c != null && reward.Account__c == null && mapContact != null && mapContact.size() > 0 
                                                    && mapContact.containsKey(reward.Contact__c)) { 
                        reward.Account__c = mapContact.get(reward.Contact__c).AccountId;
                        
                        // Check for the rewards having transaction details if not we are consider the type of amount #1164
                        if (reward.Transaction__c != null && reward.Transaction__c != '') {
                            
                            if (reward.Transaction__c  == ConstantsController.ISSUE) {  
                                reward.RewardDate__c = Date.Today();
                                reward.Available_Points__c = math.abs(Integer.valueOf(reward.Amount__c));
                                // #REF-1284 - Added Expiration date in case of transation
                                reward.Expiration_Date__c = UtilityController.rewardsExpritationDate(cs);
                                 
                            } else if (reward.Transaction__c  == ConstantsController.REDEEM) { 
                                reward.RewardDate__c = Date.Today();
                                reward.Amount__c = math.abs(Integer.valueOf(reward.Amount__c));  
                            } else {
                                reward.addError(System.Label.Transaction_Details);
                            }               
                        } else {  
                            //Influitive case
                            if (reward.Amount__c  >= 0) {
                                reward.Transaction__c = ConstantsController.ISSUE;
                                reward.Expiration_Date__c = UtilityController.rewardsExpritationDate(cs);
                                reward.RewardDate__c = Date.Today();
                                reward.Available_Points__c = math.abs(Integer.valueOf(reward.Amount__c));
                            } else if (reward.Transaction__c == null || reward.Transaction__c == '') { 
                                reward.Transaction__c = ConstantsController.REDEEM;
                                reward.RewardDate__c = Date.Today();
                                reward.Amount__c = math.abs(Integer.valueOf(reward.Amount__c));
                            }
                        }
                    } else if (reward.User__c == null) {
                         
                        //Validation for Amount in reward updation -#1164
                        if (reward.Transaction__c  == ConstantsController.ISSUE || reward.Transaction__c  == ConstantsController.REDEEM) {
                            
                            if (reward.Amount__c < 0) {
                                reward.addError(System.Label.AMOUNT_0);
                            } 
                        } else  {
                            reward.addError(System.Label.Transaction_Details);
                        }
                    }                     
                }
            } else {
                 
                for (Reward__c reward : newList) { 
                    
                    if (reward.Transaction__c  == ConstantsController.ISSUE) { 
                        
                        if (reward.Amount__c < 0) {
                                    reward.addError(System.Label.AMOUNT_0);
                        } else {
                            reward.RewardDate__c = Date.Today();
                            reward.Available_Points__c = math.abs(Integer.valueOf(reward.Amount__c));
                        }
                    } else if (reward.Transaction__c  == ConstantsController.REDEEM) { 
                                
                        if (reward.Amount__c < 0) {
                                reward.addError(System.Label.AMOUNT_0);
                        } else {
                            reward.Transaction__c = ConstantsController.REDEEM;
                            reward.RewardDate__c = Date.Today();
                            reward.Amount__c = Integer.valueOf(reward.Amount__c);
                        }
                    } else {
                        reward.addError(System.Label.Transaction_Details); 
                    } 
                } 
            }
             /************Changes end here for ticket #1164*************/
            
            for (Reward__c reward: newList) {
                               
                // Added for sales user
                if (reward.User__c != null) {
                    
                    if (reward.Transaction__c != null && reward.Transaction__c != '') { 
                   
                        if (reward.Transaction__c  == ConstantsController.ISSUE) {
                            
                            if (reward.Amount__c < 0) {
                                reward.addError(System.Label.AMOUNT_0);
                            } else {
                                 reward.Available_Points__c = reward.Amount__c;
                                 reward.Expiration_Date__c = UtilityController.salesRewardsExpritationDate(cs);
                            }
                        } else {
                            
                            if (reward.Amount__c < 0) {
                                reward.addError(System.Label.AMOUNT_0);
                            } else { 
                                reward.Transaction__c = ConstantsController.REDEEM;
                                reward.Amount__c = reward.Amount__c;
                            }
                        } 
                    } else {
                        reward.addError(System.Label.Transaction_Details);
                    } 
                } else {  
                        reward.Amount__c = math.abs(Integer.valueOf(reward.Amount__c));
                }
            }
            
        } catch (exception e) {
            throw e;
        }
    }
    /**
     * Method called on after insert of Reward
     */
    public static void afterInsert(List<Reward__c> newList, Map<Id, Reward__c> newMap) {
        Set<Id> issueIds = new Set<Id>();
        Set<Id> accountIssuedIds = new Set<Id>();
        Set<Id> contactIssuedIds = new Set<Id>();
        Set<Id> redeemIds = new Set<Id>();
        Set<Id> accountRedeemIds = new Set<Id>();
        Set<Id> contactRedeemIds = new Set<Id>();
        Set<Id> userRedeemIds = new Set<Id>();
        Set<Id> userIssuedIds = new Set<Id>();
        Set<Id> referenceabilityTypeIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        //for Influitive integration
        Set<String> setContactId = new Set<String>();
        Set<String> setReferenceabilityId = new Set<String>();
        List<Reward__c> salesUserRewardList = new List<Reward__c>();
        List<Reward__c> salesRewardlist = new List<Reward__c>();
        
        for (Reward__c reward: newList) {
            referenceabilityTypeIds.add(reward.Referenceability_Type__c);
            accountIds.add(reward.Account__c);
        }

        List<Reference_Basic_Information__c> rbiList = [SELECT Account__c, Account__r.ownerId, Reference_Owner__c 
                                                                        FROM Reference_Basic_Information__c WHERE Account__c IN: accountIds];
        Map<Id, Reference_Basic_Information__c> accountToRBIMap = new Map<Id, Reference_Basic_Information__c>();
        
        for (Reference_Basic_Information__c rbi : rbiList) {
            accountToRBIMap.put(rbi.Account__c, rbi);
        }
        
        for (Reward__c reward: newList) {
           
            if (reward.Transaction__c == ConstantsController.ISSUE) {
                issueIds.add(reward.Id);
                accountIssuedIds.add(reward.account__c);
               
                if (reward.contact__c != null) {
                    contactIssuedIds.add(reward.contact__c); 
                }
                    
                // Added for sales user
                if (reward.User__c != null) {
                    salesRewardlist.add(reward);
                    userIssuedIds.add(reward.User__c);
                }
            } else if (reward.Transaction__c == ConstantsController.REDEEM) {
                redeemIds.add(reward.Id);
                accountRedeemIds.add(reward.account__c);
                
                if (reward.contact__c != null) {
                    contactRedeemIds.add(reward.contact__c);
                }
                
                // Added for sales user    
                if (reward.User__c != null) {
                    userRedeemIds.add(reward.User__c);
                }
            }
            
            //REF-1618 : For Influitive integration  
            if (reward.Contact__c != null && reward.Influitive_Id__c != ConstantsController.ADJUSTMENT_INFL_ID) {
                setContactId.add(reward.Contact__c);
                setReferenceabilityId.add(reward.Referenceability_Type__c);
            }
        }
        
        if (salesRewardlist.size() > 0) {
            
            try {
                //Set chatter AND Email Message 
                List<sObject> postFeedItems = new List<sObject>();
                List<Referenceability_Type__c> refType = [SELECT Name FROM Referenceability_Type__c
                                                            WHERE Visible__c = true
                                                            AND Id = :salesRewardlist[0].Referenceability_Type__c LIMIT 1];
                String headerDocId = '';
                String footerDocId = '';
                Data_Mapping__c rewardNotification = new Data_Mapping__c();
                Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Sales_Reward_Point_Email__c'};

                for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                            FROM Data_Mapping__c
                                            WHERE Object__c = 'Notification'
                                            AND (Field_API_Name__c IN :notificationFieldNames
                                                OR Section_Name__c = 'email header doc'
                                                OR Section_Name__c = 'email footer doc')]) {

                    if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Sales_Reward_Point_Email__c') {
                        rewardNotification = dm;
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
                User rewaredUser = [SELECT FirstName, LastName, Email, (SELECT Available_Points__c FROM Sales_User_Profiles__r)
                                    FROM User WHERE Id = :salesRewardlist[0].User__c LIMIT 1];
                String notificationBody = rewardNotification.DC_Message__c + '\n\n' + rewardNotification.Default__c;
                notificationBody = notificationBody.replace('[User First Name]', rewaredUser.FirstName)
                                                    .replace('[User Last Name]', rewaredUser.LastName)
                                                    .replace('[Activity Name]', refType[0].Name)
                                                    .replace('[Activity Points]', salesRewardlist[0].Amount__c + '')
                                                    .replace('[Current Balance Points]', rewaredUser.Sales_User_Profiles__r[0].Available_Points__c + '');

                if (refType.size() > 0 && cs.Sales_Reward_Point_Chatter__c) {
                    postFeedItems.add(MailChatterController.preparePost(rewardNotification.Section_Name__c, salesRewardlist[0].User__c, notificationBody, ''));
                    
                    if (postFeedItems.size() > 0) {
                        postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
                    }
                }
                
                if (refType.size() > 0 && cs.Sales_Reward_Point_Email__c) {
                    List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
                    
                    if (rewaredUser != null) {
                        listmail.add(MailChatterController.prepareEmail(rewardNotification.Section_Name__c, salesRewardlist[0].User__c, 
                                                    notificationBody, false, headerDocId, footerDocId));
                    }
                    
                    if (listmail.size() > 0) {
                        Messaging.sendEmail(listmail);
                    }
                }
                
                if (refType.size() > 0 && cs.Enable_Slack_Integration__c && cs.Sales_Reward_Point_Slack__c) {
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('userEmail', rewaredUser.Email);
                    tempReqBodyMap.put('text', '*' + rewardNotification.Section_Name__c + '*\n' + notificationBody);
                    messagesList.add(tempReqBodyMap);
                    slackReqBody.put('messages', messagesList);
            	    UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
                }
            } catch (Exception e) {
                Apexpages.addMessages(e);
            }
        }
        
        if (issueIds.size() > 0) {
            addIssuedPointsOnAccountAndContactAndUser(issueIds, newList, accountIssuedIds, contactIssuedIds, userIssuedIds, new Set<Id >());
        }
        
        if (redeemIds.size() > 0) { 
            removeRedeemPointOnAccountContactAndRewards(redeemIds, newList, accountRedeemIds, contactRedeemIds, userRedeemIds);
        } 
       
        //for Influitive integration 
        if (Test.isRunningTest() || (!system.isBatch() && !system.isFuture() && cs.Is_Influitive_Integration_Enabled__c != null 
                                                        && cs.Is_Influitive_Integration_Enabled__c)) {  
            Map<Id, Contact> mapContact = new Map<Id, Contact> ([SELECT Id, email FROM Contact WHERE Id IN :setContactId]);
            Map<Id, Referenceability_Type__c> mapReferenceabilityType = new Map<Id, Referenceability_Type__c> ([SELECT Id, Name, Referenceability_code__c 
                                                        FROM Referenceability_Type__c WHERE Visible__c = true AND Id IN :setReferenceabilityId]);
                                                        
            String jsonMapContactString = JSON.serialize(mapContact);
            String jsonMapReferenceabilityTypeString = JSON.serialize(mapReferenceabilityType);
            String jsonNewMapString = JSON.serialize(newMap);           
            String jsonOldMapString = JSON.serialize(new Map<Id, Reward__c>());
            String jsonNewListString = JSON.serialize(newList);
            
            if(!Test.isRunningTest()) {
                Infl_Event.influitiveEventsCallout(jsonMapContactString, jsonMapReferenceabilityTypeString, jsonNewMapString, jsonOldMapString, jsonNewListString);
            }           
        }      
    }
    
    /**
     * Method called on after undelete of Reward
     */
    public static void onAfterUnDelete(List<Reward__c> newList) {
        Set<Id> issueIds = new Set<Id>();
        Set<Id> accountIssuedIds = new Set<Id>();
        Set<Id> contactIssuedIds = new Set<Id>();
        Set<Id> redeemIds = new Set<Id>();
        Set<Id> accountRedeemIds = new Set<Id>();
        Set<Id> contactRedeemIds = new Set<Id>();
        Set<Id> accountRequestIds = new Set<Id>();
        Set<Id> userRedeemIds = new Set<Id>();
        Set<Id> userIssuedIds = new Set<Id>();
        Map<String, Reference_Request_Account__c> accReqMap = new Map<String, Reference_Request_Account__c>();
        List<String> issueList = new List<String>();
        
        for (Reward__c reward : newList) {
          
            if (reward.Transaction__c == ConstantsController.ISSUE) {
                issueList.add(reward.Id);
                issueIds.add(reward.Id);
                accountIssuedIds.add(reward.account__c);
                
                if (reward.contact__c != null) {
                    contactIssuedIds.add(reward.contact__c);
                }
                
                // Added for sales user
                if (reward.User__c != null) {
                    userIssuedIds.add(reward.User__c);
                }
            } else {
                redeemIds.add(reward.Id);
                accountRedeemIds.add(reward.account__c);
                
                if (reward.contact__c != null) {
                    contactRedeemIds.add(reward.contact__c);
                }
                
                // Added for sales user
                if (reward.User__c != null) {
                    userRedeemIds.add(reward.User__c);
                }
            }
            
            if (reward.Account_Request__c != null) {
                accountRequestIds.add(reward.Account_Request__c);
            }
            
            if (reward.Account_Request__c == null && reward.Automatically_Assigned__c) {                 
                reward.addError('This Reward is Automatically Assigned by a Request. The Account Request has to be Undeleted first.');
            }
        }
        
        if (accountRequestIds.size() > 0) {
            accReqMap = new Map<String, Reference_Request_Account__c> ([SELECT Id, (SELECT Id FROM Rewards__r) 
                                                                            FROM Reference_Request_Account__c WHERE ID IN :accountRequestIds]);
            
            for (Reward__c reward : newList) {
               
                if (reward.Account_Request__c != null && accReqMap != null && accReqMap.containsKey(reward.Account_Request__c) && accReqMap.get(reward.Account_Request__c).Rewards__r.size() > 1) {
                    reward.addError('This Reward cannot be undeleted because of the Account Request already has a Reward Record');
                }
            }
        }
        
        if (issueIds.size() > 0) {
            addIssuedPointsOnAccountAndContactAndUser(issueIds, newList, accountIssuedIds, contactIssuedIds, userIssuedIds, new Set<Id>());
        }
        
        if (redeemIds.size() > 0) {
            removeRedeemPointOnAccountContactAndRewards(redeemIds, newList, accountRedeemIds, contactRedeemIds, userRedeemIds);
        }
        changePoints(issueList);
    }
    
    /**
     * Method to change points in Issue reward on undelete
     */
    @future
    public static void changePoints(List<String> issueIds) {
        List<Reward__c> issueList = new List<Reward__c>();
        
        for (Reward__c reward : [SELECT Id, Amount__c, Expired__c, Expired_Points__c, Available_Points__c, Account__c FROM Reward__c WHERE Id IN :issueIds AND Transaction__c =:ConstantsController.ISSUE]) {
            
            if (reward.Expired__c) {
                reward.Expired_Points__c = reward.Amount__c;
            } else {
                reward.Available_Points__c = reward.Amount__c;
            }
            issueList.add(reward);
        }
        WithoutSharingHelperController.updateRewards(issueList);
    }
    
    /**
     * Method called on after delete of Reward
     */
    public static void onAfterDelete(List<Reward__c> oldList) {
        Map<Id, Reference_Basic_Information__c> rbiAccounts = new Map<Id, Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> rbiContacts = new Map<Id, Reference_Basic_Information__c>();
        Set<String> accountIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        Set<String> userIds = new Set<String>();
        Set<Id> accountRedeemIds = new Set<Id>();
        Set<Id> userRedeemIds = new Set<Id>();
        Set<Id> redeemIds = new Set<Id>();
        Decimal amount = 0;
        Decimal addAmount = 0;
        List<Reward__c> updateIssuedRewards = new List<Reward__c>();
        Map<Id, List<Reward__c>> issuedRewards = new Map<Id, List<Reward__c>>();
        Map<Id, List<Reward__c>> userToIssuedRewards = new Map<Id, List<Reward__c>>();
        Map<Id, User_Profile__c> userIdToProfilesMap = new Map<Id, User_Profile__c>();
        RewardCalculationWrp rewardCalcWrp;

        for (Reward__c reward : oldList) {
            
            if (reward.Account__c != null) {
                accountIds.add(reward.Account__c);
            }
            
            if (reward.contact__c != null) {
                contactIds.add(reward.contact__c);
            }
            
            // Added for sales user
            if (reward.User__c != null) {
                userIds.add(reward.User__c);
            }
            
            if (reward.Transaction__c == ConstantsController.REDEEM) {
                redeemIds.add(reward.Id);
                
                // Added for sales user
                if (reward.User__c != null) {
                    userRedeemIds.add(reward.User__c);
                }
                
                if (reward.Account__c != null) {
                    accountRedeemIds.add(reward.Account__c);
                }
            }
        }
        
        // Added for sales user
        for (User_Profile__c profile : [SELECT Id, User__c, Available_Points__c, Lifetime_Points__c FROM User_Profile__c WHERE User__c IN :userIds LIMIT :limits.getLimitQueryRows()]) {
            userIdToProfilesMap.put(profile.User__c, profile);
        }

        List<Reference_Basic_Information__c> RBIList = [SELECT Id, Account__c, Contact__c, Contact__r.Name, Name, Is_Referenceable__c, Referenceability_Status__c, Lifetime_Points__c, Current_Available_Balance_Points__c FROM Reference_Basic_Information__c WHERE Account__c != null AND (Contact__c IN :contactIds OR Account__c IN :accountIds) ORDER BY Contact__r.Name LIMIT :limits.getLimitQueryRows()];
        
        for (Reference_Basic_Information__c rbi : RBIList) {
            
            if (rbi.Contact__c == null) {
                rbiAccounts.put(rbi.Account__c, rbi);
            } else {
                rbiContacts.put(rbi.Contact__c, rbi);
            }
        }
        
        if (accountRedeemIds.size()> 0) {
            
            for (Reward__c reward : [SELECT Id, Transaction__c, Expired__c, Amount__c, Contact__c, Expired_Points__c, Available_Points__c, Account__c FROM Reward__c WHERE Account__c IN :accountRedeemIds AND Transaction__c =: ConstantsController.ISSUE ORDER BY Expired__c, CreatedDate]) {
                
                if (!issuedRewards.containsKey(reward.Account__c)) {
                    issuedRewards.put(reward.Account__c, new List<Reward__c>());
                }
                issuedRewards.get(reward.Account__c).add(reward);
            }
        }
        
        // Added for sales user
        if (userRedeemIds.size() > 0) {
            
            for (Reward__c reward : [SELECT Id, Transaction__c, Expired__c, Contact__c, Amount__c, Expired_Points__c, Available_Points__c, User__c 
                                        FROM Reward__c WHERE User__c IN: userRedeemIds AND Transaction__c =: ConstantsController.ISSUE ORDER BY Expired__c, CreatedDate]) {
                
                if (!userToIssuedRewards.containsKey(reward.User__c)) {
                    userToIssuedRewards.put(reward.User__c, new List<Reward__c>());
                }
                userToIssuedRewards.get(reward.User__c).add(reward); 
            }
        }

        for (Reward__c reward : oldList) {
            
            if (reward.Transaction__c == ConstantsController.ISSUE) {
                
                if (reward.Contact__c != null && rbiContacts.containsKey(reward.contact__c)) {
                    //changes for R15.33
                    rbiContacts.get(reward.contact__c).Lifetime_Points__c = ((rbiContacts.get(reward.contact__c).Lifetime_Points__c != null 
                                        && rbiContacts.get(reward.contact__c).Lifetime_Points__c> reward.Amount__c) 
                                        ? rbiContacts.get(reward.contact__c).Lifetime_Points__c - reward.Amount__c : 0);
                    rbiContacts.get(reward.contact__c).Current_Available_Balance_Points__c = 
                                        ((rbiContacts.get(reward.contact__c).Current_Available_Balance_Points__c != null 
                                        && rbiContacts.get(reward.contact__c).Current_Available_Balance_Points__c> reward.Amount__c) 
                                        ? rbiContacts.get(reward.contact__c).Current_Available_Balance_Points__c - reward.Amount__c : 0);
                }
                
                if (reward.Account__c != null && rbiAccounts.containsKey(reward.Account__c)) {
                    rbiAccounts.get(reward.Account__c).Lifetime_Points__c = ((rbiAccounts.get(reward.Account__c).Lifetime_Points__c != null 
                                                && rbiAccounts.get(reward.Account__c).Lifetime_Points__c> reward.Amount__c) 
                                                ? rbiAccounts.get(reward.Account__c).Lifetime_Points__c - reward.Amount__c : 0);
                    rbiAccounts.get(reward.Account__c).Current_Available_Balance_Points__c = 
                                                ((rbiAccounts.get(reward.Account__c).Current_Available_Balance_Points__c != null 
                                                && rbiAccounts.get(reward.Account__c).Current_Available_Balance_Points__c> reward.Available_Points__c) 
                                                ? rbiAccounts.get(reward.Account__c).Current_Available_Balance_Points__c - reward.Available_Points__c : 0);
                }
                
                // Added for sales user
                if (reward.User__c != null && userIdToProfilesMap.containsKey(reward.User__c)) {
                    userIdToProfilesMap.get(reward.User__c).Lifetime_Points__c = ((userIdToProfilesMap.get(reward.User__c).Lifetime_Points__c != null 
                                                    && userIdToProfilesMap.get(reward.User__c).Lifetime_Points__c> reward.Amount__c) 
                                                    ? userIdToProfilesMap.get(reward.User__c).Lifetime_Points__c - reward.Amount__c : 0);
                    if (!reward.Expired__c) {
                        userIdToProfilesMap.get(reward.User__c).Available_Points__c = ((userIdToProfilesMap.get(reward.User__c).Available_Points__c != null 
                                    && userIdToProfilesMap.get(reward.User__c).Available_Points__c > reward.Amount__c) 
                                    ? userIdToProfilesMap.get(reward.User__c).Available_Points__c - reward.Amount__c : 0);
                    }
                }
            } else if (reward.Transaction__c == ConstantsController.REDEEM && !reward.Expired__c) {
                amount = reward.amount__c;
                
                if (issuedRewards != null && issuedRewards.containsKey(reward.Account__c) && reward.Account__c != null) {
                    rewardCalcWrp = calcPointsOnRedeemRewardDelete(issuedRewards.get(reward.Account__c), amount, reward);

                    if (reward.Account__c != null && rbiAccounts.containsKey(reward.Account__c) 
                                                && rbiAccounts.get(reward.Account__c).Lifetime_Points__c >= reward.Amount__c) {
                        rbiAccounts.get(reward.Account__c).Current_Available_Balance_Points__c = 
                                                (rbiAccounts.get(reward.Account__c).Current_Available_Balance_Points__c != null ? 
                                                rbiAccounts.get(reward.Account__c).Current_Available_Balance_Points__c + rewardCalcWrp.addAmount : rewardCalcWrp.addAmount);
                    }
                    if (reward.Contact__c != null && rbiContacts.containsKey(reward.Contact__c) 
                                                        && rbiContacts.get(reward.Contact__c).Lifetime_Points__c >= reward.Amount__c) {
                        rbiContacts.get(reward.Contact__c).Current_Available_Balance_Points__c = 
                                                (rbiContacts.get(reward.Contact__c).Current_Available_Balance_Points__c != null 
                                                ? rbiContacts.get(reward.Contact__c).Current_Available_Balance_Points__c + rewardCalcWrp.addAmount : rewardCalcWrp.addAmount);
                    }
                    updateIssuedRewards.addAll(rewardCalcWrp.rewardsToBeUpdate);
                }
                
                // Added for sales user
                if (userToIssuedRewards != null && userToIssuedRewards.containsKey(reward.User__c) && reward.User__c != null) {
                    rewardCalcWrp = calcPointsOnRedeemRewardDelete(userToIssuedRewards.get(reward.User__c), amount, reward);
                    
                    if (reward.User__c != null && userIdToProfilesMap.containsKey(reward.User__c) 
                                                && userIdToProfilesMap.get(reward.User__c).Lifetime_Points__c >= reward.Amount__c) {
                        userIdToProfilesMap.get(reward.User__c).Available_Points__c = (userIdToProfilesMap.get(reward.User__c).Available_Points__c != null 
                                                ? userIdToProfilesMap.get(reward.User__c).Available_Points__c + rewardCalcWrp.addAmount : rewardCalcWrp.addAmount);
                    }
                    updateIssuedRewards.addAll(rewardCalcWrp.rewardsToBeUpdate);
                }
            }
        }
        
        if (rbiContacts.size() > 0) {
            WithoutSharingHelperController.updateRBI(rbiContacts.values());
        }
        
        if (rbiAccounts.size() > 0) {
            ConstantsController.isNotFromRewardTrigger = false;
            WithoutSharingHelperController.updateRBI(rbiAccounts.values());
        }
        
        if (updateIssuedRewards.size() > 0) {
            WithoutSharingHelperController.updateRewards(updateIssuedRewards);
        }
        
        // Added for sales user
        if (userIdToProfilesMap.size() > 0) {
            WithoutSharingHelperController.updateSalesUserProfiles(userIdToProfilesMap.values());
        }
    }

    /**
     * Method called to calculate redeem reward points
     */
    private static RewardCalculationWrp calcPointsOnRedeemRewardDelete(List<Reward__c> rewardList, Decimal amount, Reward__c reward) {
        Decimal addAmount = 0;
        List<Reward__c> updateIssuedRewards = new List<Reward__c>();
        
        for (Reward__c issuedReward : rewardList) {
            
            if ((reward.Contact__c != null && issuedReward.Contact__c == reward.Contact__c) || (reward.Contact__c == null && issuedReward.Contact__c == null)) {
                 
                if (!issuedReward.Expired__c && issuedReward.Available_Points__c != null && issuedReward.Amount__c != issuedReward.Available_Points__c) {
                    
                    if ((issuedReward.Amount__c - issuedReward.Available_Points__c) <= amount && amount != 0) {
                        amount = amount - (issuedReward.Amount__c - issuedReward.Available_Points__c);
                        addAmount += (issuedReward.Amount__c - issuedReward.Available_Points__c);
                        issuedReward.Available_Points__c = issuedReward.Amount__c;
                        updateIssuedRewards.add(issuedReward);
                    } else if (amount != 0) {
                        issuedReward.Available_Points__c = amount + issuedReward.Available_Points__c;
                        addAmount += amount;
                        updateIssuedRewards.add(issuedReward);
                        amount = 0;
                        break;
                    }
                } else if (issuedReward.Expired__c && issuedReward.Amount__c != issuedReward.Expired_Points__c) {
                   
                    if ((issuedReward.Amount__c - issuedReward.Expired_Points__c) <= amount && amount != 0) {
                        amount = amount - (issuedReward.Amount__c - issuedReward.Expired_Points__c);
                        issuedReward.Expired_Points__c = issuedReward.Amount__c;
                        updateIssuedRewards.add(issuedReward);
                    } else if (amount != 0) {
                        issuedReward.Expired_Points__c = amount + issuedReward.Expired_Points__c;
                        updateIssuedRewards.add(issuedReward);
                        amount = 0;
                        break;
                    }
                }
            }
        }

        return new RewardCalculationWrp(addAmount, updateIssuedRewards);
    }

    /**
     * Method called on after update of Reward
     */
    public static void onAfterUpdate(List<Reward__c> newList, Map<Id, Reward__c> newMap, Map<Id, Reward__c> oldMap) {
        Set<Id> issueIds = new Set<Id>();
        Set<Id> rewardIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        
        Map<Id, Decimal> accountIssuedIds = new Map<Id, Decimal>();
        Map<Id, Decimal> contactIssuedIds = new Map<Id, Decimal>();
        Map<Id, Decimal> accountRedeemIds = new Map<Id, Decimal>();
        Map<Id, Decimal> accountExpiredIds = new Map<Id, Decimal>();
        // Added for sales user
        Map<Id, Decimal> userToRedeemAmount = new Map<Id, Decimal>();
        Map<Id, Decimal> userToExpiredAmount = new Map<Id, Decimal>();
        Map<Id, Decimal> userToIssuedAmount = new Map<Id, Decimal>();
        Set<Id> userIssuedIds = new Set<Id>();
        Map<Id, List<Reward__c>> issuedUserRewards = new Map<Id, List<Reward__c>>();
        //added for R15.33
        Map<Id, Decimal> contactRedeemIds = new Map<Id, Decimal>();
        Map<Id, Decimal> contactExpiredIds = new Map<Id, Decimal>();
        //end
        List<Reward__c> updateIssuedRewards = new List<Reward__c>();
        Map<Id, List<Reward__c>> issuedRewards = new Map<Id, List<Reward__c>>();
        Map<Id, List<Reward__c>> issuedContactRewards = new Map<Id, List<Reward__c>>();
        Decimal amount = 0;
        Set<Id> ChangedContactIds = new Set<Id>();
        Set<String> setContactId = new Set<String>();
        Set<String> setReferenceabilityId = new Set<String>();
                
        for (Reward__c reward : newList) {
            
            // Added for sales
            if (reward.User__c != null) {
                userIssuedIds.add(reward.User__c);
            }
            
            //for Influitive integration
            if (reward.Contact__c != null) {
                setContactId.add(reward.Contact__c);
                setReferenceabilityId.add(reward.Referenceability_Type__c);
            }
            
            if (oldMap.get(reward.Id).Contact__c == null && newMap.get(reward.Id).Contact__c != null && reward.Transaction__c == ConstantsController.ISSUE) {
                issueIds.add(reward.Id);
                contactIds.add(reward.Contact__c);
            }
            
            if (oldMap.get(reward.Id).Contact__c != null && newMap.get(reward.Id).Contact__c == null) {
                ChangedContactIds.add(oldMap.get(reward.Id).Contact__c);
            }
            
            //if any changes in amount of reward
            if (oldMap.get(reward.Id).Amount__c != newMap.get(reward.Id).Amount__c) {
                
                //issue but not expired
                if (reward.Transaction__c == ConstantsController.ISSUE && !reward.Expired__c) {
                    
                    if (reward.account__c != null) {
                        
                        if (!accountIssuedIds.containsKey(reward.account__c)) {
                            accountIssuedIds.put(reward.account__c, 0);
                        }
                        amount = accountIssuedIds.get(reward.account__c) + newMap.get(reward.Id).Amount__c - oldMap.get(reward.Id).Amount__c;
                        accountIssuedIds.put(reward.account__c, amount);
                        
                        if (reward.contact__c != null) { //issue on contact
                            
                            if (!contactIssuedIds.containsKey(reward.contact__c)) {
                                contactIssuedIds.put(reward.contact__c, 0);
                            }
                            amount = contactIssuedIds.get(reward.contact__c) + newMap.get(reward.Id).Amount__c - oldMap.get(reward.Id).Amount__c;
                            contactIssuedIds.put(reward.contact__c, amount);
                        }
                    }
                    
                    // Added for sales user
                    if (reward.User__c != null) {
                        
                        if (!userToIssuedAmount.containsKey(reward.User__c)) {
                            userToIssuedAmount.put(reward.User__c, 0);
                        }
                        amount = userToIssuedAmount.get(reward.User__c) + newMap.get(reward.Id).Amount__c - oldMap.get(reward.Id).Amount__c;
                        userToIssuedAmount.put(reward.User__c, amount);
                    }
                    //redeem but not expired
                } else if (reward.Transaction__c == ConstantsController.REDEEM && !reward.Expired__c) {
                    
                    //redeem FROM account
                    if (reward.Account__c != null) {
                        
                        if (!accountRedeemIds.containsKey(reward.account__c)) {
                            accountRedeemIds.put(reward.account__c, 0);
                        }
                        amount = accountRedeemIds.get(reward.account__c) + newMap.get(reward.Id).Amount__c - oldMap.get(reward.Id).Amount__c;
                        accountRedeemIds.put(reward.account__c, amount);
                    }

                    //redeem FROM contact
                    if (reward.contact__c != null) {
                        
                        if (!contactRedeemIds.containsKey(reward.contact__c)) {
                            contactRedeemIds.put(reward.contact__c, 0);
                        }
                        amount = contactRedeemIds.get(reward.contact__c) + newMap.get(reward.Id).Amount__c - oldMap.get(reward.Id).Amount__c;
                        contactRedeemIds.put(reward.contact__c, amount);
                    }

                    //redeem FROM user
                    if (reward.user__c != null) {
                        
                        if (!userToRedeemAmount.containsKey(reward.user__c)) {
                            userToRedeemAmount.put(reward.user__c, 0);
                        }
                        amount = userToRedeemAmount.get(reward.user__c) + newMap.get(reward.Id).Amount__c - oldMap.get(reward.Id).Amount__c;
                        userToRedeemAmount.put(reward.user__c, amount);
                    }
                }
            }
            
            //if any reward made expired OR expired to available
            if (oldMap.get(reward.Id).Expired__c != newMap.get(reward.Id).Expired__c) {
                
                if (newMap.get(reward.Id).Expired__c) {
                    
                    if (reward.account__c != null) {
                        
                        if (!accountExpiredIds.containsKey(reward.account__c)) {
                            accountExpiredIds.put(reward.account__c, 0);
                        }
                        amount = accountExpiredIds.get(reward.account__c) - reward.Expired_Points__c;
                        accountExpiredIds.put(reward.account__c, amount);
                    }

                    //added for R15.33
                    if (reward.contact__c != null) {
                        
                        if (!contactExpiredIds.containsKey(reward.contact__c)) {
                            contactExpiredIds.put(reward.contact__c, 0);
                        }
                        contactExpiredIds.put(reward.contact__c, amount);
                    }
                    //end

                    //added for sales user
                    if (reward.user__c != null) {
                        
                        if (!userToExpiredAmount.containsKey(reward.user__c)) {
                            userToExpiredAmount.put(reward.user__c, 0);
                        }
                        amount = userToExpiredAmount.get(reward.user__c) - reward.Expired_Points__c;
                        userToExpiredAmount.put(reward.user__c, amount);
                    }
                    //end
                } else if (!newMap.get(reward.Id).Expired__c) {
                    
                    if (!accountExpiredIds.containsKey(reward.account__c)) {
                        accountExpiredIds.put(reward.account__c, 0);
                    }
                    amount = accountExpiredIds.get(reward.account__c) + reward.Available_Points__c;
                    
                    if (accountIssuedIds.containsKey(reward.account__c)) {
                        amount = amount - accountIssuedIds.get(reward.account__c);
                    }
                    accountExpiredIds.put(reward.account__c, amount);

                    //added for R15.33
                    if (reward.contact__c != null) {
                        
                        if (!contactExpiredIds.containsKey(reward.contact__c)) {
                            contactExpiredIds.put(reward.contact__c, 0);
                        }
                        
                        if (contactIssuedIds.containsKey(reward.contact__c)) {
                            amount = amount - contactIssuedIds.get(reward.contact__c);
                        }
                        contactExpiredIds.put(reward.contact__c, amount);
                    }
                    //end

                    //added for sales user
                    if (reward.user__c != null) {
                        
                        if (!userToExpiredAmount.containsKey(reward.user__c)) {
                            userToExpiredAmount.put(reward.user__c, 0);
                        }
                        
                        if (userToIssuedAmount.containsKey(reward.user__c)) {
                            amount = amount - userToIssuedAmount.get(reward.user__c);
                        }
                        userToExpiredAmount.put(reward.user__c, amount);
                    }
                    //end
                }
            }
        }
        // Added for sales user
        Map<Id, User_Profile__c> userIdToProfilesMap = new Map<Id, User_Profile__c>();
        
        for (User_Profile__c profile : [SELECT Id, User__c, Available_Points__c, Lifetime_Points__c FROM User_Profile__c WHERE User__c 
                                            IN :userIssuedIds LIMIT :limits.getLimitQueryRows()]) {
            userIdToProfilesMap.put(profile.User__c, profile);
        }
        //end
        List<Reference_Basic_Information__c> updateExpiredPointsRBI = new List<Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> accounts = new Map<Id, Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> contacts = new Map<Id, Reference_Basic_Information__c>();
        //Changes for R15.33
        List<Reference_Basic_Information__c> RBIList = [SELECT Id, Account__c, Contact__c, Contact__r.Name, Name, Is_Referenceable__c, 
                                                        Referenceability_Status__c, Lifetime_Points__c, Current_Available_Balance_Points__c 
                                                        FROM Reference_Basic_Information__c WHERE Account__c != null AND (Contact__c IN :contactIssuedIds.keySet() 
                                                        OR Contact__c IN :contactExpiredIds.keySet() OR Contact__c IN :contactRedeemIds.keySet() OR Account__c 
                                                        IN :accountIssuedIds.keySet() OR Account__c IN :accountRedeemIds.keySet() OR Account__c 
                                                        IN :accountExpiredIds.keySet()) ORDER BY Contact__r.Name LIMIT :limits.getLimitQueryRows()];
        
        for (Reference_Basic_Information__c rbi : RBIList) {
            
            if (rbi.Contact__c == null) {
                accounts.put(rbi.Account__c, rbi);
            } else {
                contacts.put(rbi.Contact__c, rbi);
            }
        }
        
        if (accountIssuedIds != null && accountIssuedIds.size()> 0) {
            
            for (Id accId : accountIssuedIds.keySet()) {
                accounts.get(accId).Lifetime_Points__c = (accounts.get(accId).Lifetime_Points__c != null ? 
                                                            accounts.get(accId).Lifetime_Points__c + accountIssuedIds.get(accId) : accountIssuedIds.get(accId));
                accounts.get(accId).Current_Available_Balance_Points__c = (accounts.get(accId).Current_Available_Balance_Points__c != null ? 
                                                        accounts.get(accId).Current_Available_Balance_Points__c + accountIssuedIds.get(accId) : accountIssuedIds.get(accId));
            }
        }
        
        if (contactIssuedIds != null && contactIssuedIds.size() > 0) {
            
            for (Id conId : contactIssuedIds.keySet()) {
                contacts.get(conId).Lifetime_Points__c = (contacts.get(conId).Lifetime_Points__c != null ? contacts.get(conId).Lifetime_Points__c 
                                                                + contactIssuedIds.get(conId) : contactIssuedIds.get(conId));
                //changes for issue R15.33
                contacts.get(conId).Current_Available_Balance_Points__c = (contacts.get(conId).Current_Available_Balance_Points__c != null ? 
                                                                contacts.get(conId).Current_Available_Balance_Points__c + contactIssuedIds.get(conId) : contactIssuedIds.get(conId));
            }
        }
        
        // Added for sales user
        if (userToIssuedAmount != null && userToIssuedAmount.size() > 0) {
           
            for (Id userId : userToIssuedAmount.keySet()) {
                
                if (userIdToProfilesMap.containsKey(userId)) {
                    userIdToProfilesMap.get(userId).Lifetime_Points__c = (userIdToProfilesMap.get(userId).Lifetime_Points__c != null ? 
                                                        userIdToProfilesMap.get(userId).Lifetime_Points__c + userToIssuedAmount.get(userId) : userToIssuedAmount.get(userId));
                    //changes for issue R15.33
                    userIdToProfilesMap.get(userId).Available_Points__c = (userIdToProfilesMap.get(userId).Available_Points__c != null ? 
                                                        userIdToProfilesMap.get(userId).Available_Points__c + userToIssuedAmount.get(userId) : userToIssuedAmount.get(userId));

                }
            }
        }
        //end 
        Set<Id> rewardIsSet = new Set<Id>();
        
        if (accountRedeemIds != null && accountRedeemIds.size() > 0 && contactRedeemIds.isEmpty()) {
            
            for (Id accId : accountRedeemIds.keySet()) {
                accounts.get(accId).Current_Available_Balance_Points__c = (accounts.get(accId).Current_Available_Balance_Points__c != null ? 
                                                    accounts.get(accId).Current_Available_Balance_Points__c - accountRedeemIds.get(accId) : accountRedeemIds.get(accId));
            }

            for (Reward__c reward : [SELECT Id, Transaction__c, Expired__c, Amount__c, Available_Points__c, Expired_Points__c, Account__c, Contact__c 
                                                    FROM Reward__c WHERE Account__c IN :accountRedeemIds.keySet() AND Contact__c = null 
                                                    AND Transaction__c =:ConstantsController.ISSUE ORDER BY Expired__c, CreatedDate]) {
                rewardIsSet.add(reward.id);
                
                if (!issuedRewards.containsKey(reward.Account__c)) {
                    issuedRewards.put(reward.Account__c, new List<Reward__c>());
                }
                issuedRewards.get(reward.Account__c).add(reward);
            }
        }
        
        //Added for R15.33 start getting reward which will modified 
        if (contactRedeemIds != null && contactRedeemIds.size() > 0) {
           
            for (Id conId: contactRedeemIds.keySet()) {
                contacts.get(conId).Current_Available_Balance_Points__c = (contacts.get(conId).Current_Available_Balance_Points__c != null ? 
                                                    contacts.get(conId).Current_Available_Balance_Points__c - contactRedeemIds.get(conId) : contactRedeemIds.get(conId));
            }
            List<Reward__c> rList = [SELECT Id, Transaction__c, Expired__c, Amount__c, Available_Points__c, Expired_Points__c, Account__c, Contact__c FROM Reward__c 
                                                        WHERE Contact__c IN :contactRedeemIds.keySet() AND Account__c IN :accountRedeemIds.keySet() 
                                                        AND Transaction__c =:ConstantsController.ISSUE ORDER BY Expired__c, CreatedDate];
            
            for (Reward__c reward : rList) {
               
                if (!rewardIsSet.contains(reward.Id)) {
                   
                    if (!issuedContactRewards.containsKey(reward.Contact__c)) {
                        issuedContactRewards.put(reward.Contact__c, new List<Reward__c>());
                    }
                    issuedContactRewards.get(reward.Contact__c).add(reward);
                }

            }
        }
        
        // Added for sales user
        if (userToRedeemAmount != null && userToRedeemAmount.size() > 0) {
            
            for (Id userId : userToRedeemAmount.keySet()) {
               
                if (userIdToProfilesMap.containsKey(userId)) {
                    userIdToProfilesMap.get(userId).Available_Points__c = (userIdToProfilesMap.get(userId).Available_Points__c != null 
                                            ? userIdToProfilesMap.get(userId).Available_Points__c - userToRedeemAmount.get(userId) : userToRedeemAmount.get(userId));
                }
            }

            for (Reward__c reward : [SELECT Id, Transaction__c, Expired__c, Amount__c, Available_Points__c, Expired_Points__c, User__c FROM Reward__c 
                                            WHERE User__c IN :userToRedeemAmount.keySet() AND Transaction__c =:ConstantsController.ISSUE ORDER BY Expired__c, CreatedDate]) {
                rewardIsSet.add(reward.id);
               
                if (!issuedUserRewards.containsKey(reward.User__c))
                    issuedUserRewards.put(reward.User__c, new List<Reward__c>());
                issuedUserRewards.get(reward.User__c).add(reward);
            }
        }
        // end
          
        if (contactExpiredIds != null && contactExpiredIds.size() > 0) {
            
            for (Id conId : contactExpiredIds.keySet()) {
                contacts.get(conId).Current_Available_Balance_Points__c =
                    (contacts.get(conId).Current_Available_Balance_Points__c != null ? contacts.get(conId).Current_Available_Balance_Points__c 
                                                    + contactExpiredIds.get(conId) : contactExpiredIds.get(conId));
            }
        }
        //Added for R15.33 end
        if (accountExpiredIds != null && accountExpiredIds.size() > 0) {
            
            for (Id accId : accountExpiredIds.keySet()) {
               
                if (accounts.containsKey(accId)) {
                    accounts.get(accId).Current_Available_Balance_Points__c = (accounts.get(accId).Current_Available_Balance_Points__c != null ? 
                                                    accounts.get(accId).Current_Available_Balance_Points__c + accountExpiredIds.get(accId) : accountExpiredIds.get(accId));
                }
            }
        }
       
        //Added for sales user
        if (userToExpiredAmount != null && userToExpiredAmount.size() > 0) {
            
            for (Id userId : userToExpiredAmount.keySet()) {
                
                if (userIdToProfilesMap.containsKey(userId)) {
                    userIdToProfilesMap.get(userId).Available_Points__c = (userIdToProfilesMap.get(userId).Available_Points__c != null ? 
                                                userIdToProfilesMap.get(userId).Available_Points__c + userToExpiredAmount.get(userId) : userToExpiredAmount.get(userId));
                }
            }
        }
        //end
        Decimal redeemPointsAddinExpiredIssue = 0;
        Decimal availpoints = 0;
        
        for (Reward__c reward : newList) {
            availpoints = 0;
            redeemPointsAddinExpiredIssue = 0;
            
            if (reward.Transaction__c == ConstantsController.REDEEM && !reward.Expired__c) {
                amount = newMap.get(reward.Id).Amount__c - oldMap.get(reward.Id).Amount__c;
                
                if (reward.Contact__c == null && reward.User__c == null) {
                    
                    if (issuedRewards != null && issuedRewards.containsKey(reward.Account__c)) {
                        
                        if (amount < 0) {
                            amount = oldMap.get(reward.Id).Amount__c - newMap.get(reward.Id).Amount__c;
                            
                            for (Reward__c issuedReward : issuedRewards.get(reward.Account__c)) {
                                
                                if (!issuedReward.Expired__c) {
                                    
                                    if (issuedReward.Amount__c != issuedReward.Available_Points__c) {
                                        
                                        if ((issuedReward.Amount__c - issuedReward.Available_Points__c) <= amount && amount != 0) {
                                            amount = amount - (issuedReward.Amount__c - issuedReward.Available_Points__c);
                                            issuedReward.Available_Points__c = issuedReward.Amount__c;
                                            updateIssuedRewards.add(issuedReward);
                                        } else if (amount != 0) {
                                            issuedReward.Available_Points__c = amount + issuedReward.Available_Points__c;
                                            updateIssuedRewards.add(issuedReward);
                                            amount = 0;
                                            break;
                                        }
                                    }
                                    
                                    //update contact available points when we made changes in redeem reward
                                    if (issuedReward.Contact__c != null && contacts.containsKey(issuedReward.Contact__c)) {
                                        contacts.get(issuedReward.Contact__c).Current_Available_Balance_Points__c = 
                                                                        ((contacts.get(issuedReward.Contact__c).Current_Available_Balance_Points__c != null 
                                                                        && contacts.get(issuedReward.Contact__c).Current_Available_Balance_Points__c != 0) ? 
                                                                        contacts.get(issuedReward.Contact__c).Current_Available_Balance_Points__c 
                                                                        + issuedReward.Available_Points__c : 0);
                                    }
    
                                } else {
                                    
                                    if (issuedReward.Amount__c != issuedReward.Expired_Points__c) {
                                        
                                        if ((issuedReward.Amount__c - issuedReward.Expired_Points__c) <= amount && amount != 0) {
                                            amount = amount - (issuedReward.Amount__c - issuedReward.Expired_Points__c);
                                            issuedReward.Expired_Points__c = issuedReward.Amount__c;
                                            updateIssuedRewards.add(issuedReward);
                                            redeemPointsAddinExpiredIssue += (issuedReward.Amount__c - issuedReward.Expired_Points__c);
                                        } else if (amount != 0) {
                                            issuedReward.Expired_Points__c = amount + issuedReward.Expired_Points__c;
                                            updateIssuedRewards.add(issuedReward);
                                            redeemPointsAddinExpiredIssue += amount;
                                            amount = 0;
                                            break;
                                        }
                                    }
                                }
                            }
                        } else if (amount > 0) {
                            
                            for (Reward__c issuedReward : issuedRewards.get(reward.Account__c)) {
                                
                                if (!issuedReward.Expired__c) {
                                    
                                    if (issuedReward.Available_Points__c <= amount && amount != 0) {
                                        amount = amount - issuedReward.Available_Points__c;
                                        issuedReward.Available_Points__c = 0;
                                        updateIssuedRewards.add(issuedReward);
                                    } else if (amount != 0) {
                                        issuedReward.Available_Points__c = issuedReward.Available_Points__c - amount;
                                        updateIssuedRewards.add(issuedReward);
                                        amount = 0;
                                        break;
                                    }
                                }
                                
                                //update contact available points when we made changes in redeem reward
                                if (issuedReward.Contact__c != null && contacts.containsKey(issuedReward.Contact__c)) {
                                    contacts.get(issuedReward.Contact__c).Current_Available_Balance_Points__c = 
                                                            ((contacts.get(issuedReward.Contact__c).Current_Available_Balance_Points__c != null 
                                                            && contacts.get(issuedReward.Contact__c).Current_Available_Balance_Points__c != 0) ? 
                                                            contacts.get(issuedReward.Contact__c).Current_Available_Balance_Points__c 
                                                            + issuedReward.Available_Points__c : 0);
                                }
                            }
                        }
                    }
                    
                    if (redeemPointsAddinExpiredIssue > 0) {
                        accounts.get(reward.Account__c).Current_Available_Balance_Points__c = ((accounts.get(reward.Account__c).Current_Available_Balance_Points__c != null 
                                                                                && accounts.get(reward.Account__c).Current_Available_Balance_Points__c != 0) 
                                                                                ? accounts.get(reward.Account__c).Current_Available_Balance_Points__c - redeemPointsAddinExpiredIssue : 0);
                    }
                } else if (reward.Contact__c != null && !ConstantsController.isCallFromInfluitiveAPI) {
                    
                    if (issuedContactRewards != null && issuedContactRewards.containsKey(reward.Contact__c)) {
                        
                        //when amount reduced
                        if (amount < 0) {
                            amount = oldMap.get(reward.Id).Amount__c - newMap.get(reward.Id).Amount__c;
                            
                            for (Reward__c issuedReward : issuedContactRewards.get(reward.Contact__c)) {
                                
                                if (!issuedReward.Expired__c) {
                                    
                                    if (issuedReward.Amount__c != issuedReward.Available_Points__c) {
                                        
                                        if ((issuedReward.Amount__c - issuedReward.Available_Points__c) <= amount && amount != 0) {
                                            amount = amount - (issuedReward.Amount__c - issuedReward.Available_Points__c);
                                            issuedReward.Available_Points__c = issuedReward.Amount__c;
                                            updateIssuedRewards.add(issuedReward);
                                        } else if (amount != 0) {
                                            issuedReward.Available_Points__c = amount + issuedReward.Available_Points__c;
                                            updateIssuedRewards.add(issuedReward);
                                            amount = 0;
                                            break;
                                        }
                                    }
                                } else { //for expired rewards
                                    
                                    if (issuedReward.Amount__c != issuedReward.Expired_Points__c) {
                                        
                                        if ((issuedReward.Amount__c - issuedReward.Expired_Points__c) <= amount && amount != 0) {
                                            amount = amount - (issuedReward.Amount__c - issuedReward.Expired_Points__c);
                                            issuedReward.Expired_Points__c = issuedReward.Amount__c;
                                            updateIssuedRewards.add(issuedReward);
                                            redeemPointsAddinExpiredIssue += (issuedReward.Amount__c - issuedReward.Expired_Points__c);
                                        } else if (amount != 0) {
                                            issuedReward.Expired_Points__c = amount + issuedReward.Expired_Points__c;
                                            updateIssuedRewards.add(issuedReward);
                                            redeemPointsAddinExpiredIssue += amount;
                                            amount = 0;
                                            break;
                                        }
                                    }
                                }
                            }
                        } else if (amount > 0) { //when amount incresed
                           
                            for (Reward__c issuedReward : issuedContactRewards.get(reward.Contact__c)) {
                               
                                if (!issuedReward.Expired__c) {
                                    
                                    if (issuedReward.Available_Points__c <= amount && amount != 0) {
                                        amount = amount - issuedReward.Available_Points__c;
                                        issuedReward.Available_Points__c = 0;
                                        updateIssuedRewards.add(issuedReward);
                                    } else if (amount != 0) {
                                        issuedReward.Available_Points__c = issuedReward.Available_Points__c - amount;
                                        updateIssuedRewards.add(issuedReward);
                                        amount = 0;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    
                    if (redeemPointsAddinExpiredIssue > 0) {
                        contacts.get(reward.Contact__c).Current_Available_Balance_Points__c = ((contacts.get(reward.Contact__c).Current_Available_Balance_Points__c != null 
                                                                                        && contacts.get(reward.Contact__c).Current_Available_Balance_Points__c != 0) ? 
                                                                                        contacts.get(reward.Contact__c).Current_Available_Balance_Points__c - redeemPointsAddinExpiredIssue : 0);
                    }
                                        
                    //update account available points when we made changes in redeem reward
                    if (contactRedeemIds.get(reward.Contact__c) != null) {
                        availpoints = contactRedeemIds.get(reward.Contact__c);
                        availpoints = availpoints * -1;
                        
                        if (reward.Account__c != null && accounts.get(reward.Account__c) != null) {
                            accounts.get(reward.Account__c).Current_Available_Balance_Points__c = ((accounts.get(reward.Account__c).Current_Available_Balance_Points__c != null 
                                                                                            && accounts.get(reward.Account__c).Current_Available_Balance_Points__c != 0) ? 
                                                                                            accounts.get(reward.Account__c).Current_Available_Balance_Points__c + availpoints : 0);
                        }
                    }
                } else if (reward.User__c != null) {
                    
                    //Added for sales user
                    if (issuedUserRewards != null && issuedUserRewards.containsKey(reward.User__c)) {
                        
                        //when amount reduced
                        if (amount < 0) {
                            amount = oldMap.get(reward.Id).Amount__c - newMap.get(reward.Id).Amount__c;
                            
                            for (Reward__c issuedReward : issuedUserRewards.get(reward.User__c)) {
                                
                                if (!issuedReward.Expired__c) {
                                    
                                    if (issuedReward.Amount__c != issuedReward.Available_Points__c) {
                                        
                                        if ((issuedReward.Amount__c - issuedReward.Available_Points__c) <= amount && amount != 0) {
                                            amount = amount - (issuedReward.Amount__c - issuedReward.Available_Points__c);
                                            issuedReward.Available_Points__c = issuedReward.Amount__c;
                                            updateIssuedRewards.add(issuedReward);
                                        } else if (amount != 0) {
                                            issuedReward.Available_Points__c = amount + issuedReward.Available_Points__c;
                                            updateIssuedRewards.add(issuedReward);
                                            amount = 0;
                                            break;
                                        }
                                    }
                                } else { //for expired rewards
                                    
                                    if (issuedReward.Amount__c != issuedReward.Expired_Points__c) {
                                        
                                        if ((issuedReward.Amount__c - issuedReward.Expired_Points__c) <= amount && amount != 0) {
                                            amount = amount - (issuedReward.Amount__c - issuedReward.Expired_Points__c);
                                            issuedReward.Expired_Points__c = issuedReward.Amount__c;
                                            updateIssuedRewards.add(issuedReward);
                                            redeemPointsAddinExpiredIssue += (issuedReward.Amount__c - issuedReward.Expired_Points__c);
                                        } else if (amount != 0) {
                                            issuedReward.Expired_Points__c = amount + issuedReward.Expired_Points__c;
                                            updateIssuedRewards.add(issuedReward);
                                            redeemPointsAddinExpiredIssue += amount;
                                            amount = 0;
                                            break;
                                        }
                                    }
                                }
                            }
                        } else if (amount > 0) { //when amount incresed
                            
                            for (Reward__c issuedReward : issuedUserRewards.get(reward.User__c)) {
                                
                                if (!issuedReward.Expired__c) {
                                   
                                    if (issuedReward.Available_Points__c <= amount && amount != 0) {
                                        amount = amount - issuedReward.Available_Points__c;
                                        issuedReward.Available_Points__c = 0;
                                        updateIssuedRewards.add(issuedReward);
                                    } else if (amount != 0) {
                                        issuedReward.Available_Points__c = issuedReward.Available_Points__c - amount;
                                        updateIssuedRewards.add(issuedReward);
                                        amount = 0;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                   
                    if(redeemPointsAddinExpiredIssue > 0){
                        userIdToProfilesMap.get(reward.User__c).Available_Points__c = ((userIdToProfilesMap.get(reward.User__c).Available_Points__c != null 
                                                                                        && userIdToProfilesMap.get(reward.User__c).Available_Points__c != 0) ? 
                                                                                        userIdToProfilesMap.get(reward.User__c).Available_Points__c - redeemPointsAddinExpiredIssue : 0);
                    }
                }
            }
        }

        updateAccountContact(newList, accounts, contacts);
        
        if (issueIds.size() > 0 || ChangedContactIds.size() > 0) {
            addIssuedPointsOnAccountAndContactAndUser(issueIds, newList, new Set<Id>(), contactIds, userIssuedIds, ChangedContactIds);
        }
        
        if (updateIssuedRewards.size() > 0) {
            WithoutSharingHelperController.updateRewards(updateIssuedRewards);
        }
        
        // Added for sales user
        if (userIdToProfilesMap.size() > 0) {
            WithoutSharingHelperController.updateSalesUserProfiles(userIdToProfilesMap.values());
        }  
        //for Influitive integration 
        if (Test.isRunningTest() || (!system.isBatch() && !system.isFuture() && cs.Is_Influitive_Integration_Enabled__c != null 
                                                        && cs.Is_Influitive_Integration_Enabled__c && ConstantsController.isInfluitiveNotRunning)) { 
            Map<Id, Contact> mapContact = new Map<Id, Contact> ([SELECT Id, email FROM Contact WHERE Id IN :setContactId]);
            Map<Id, Referenceability_Type__c> mapReferenceabilityType = new Map<Id, Referenceability_Type__c> ([SELECT Id, Name, Referenceability_code__c FROM Referenceability_Type__c WHERE Visible__c = true AND Id IN: setReferenceabilityId]);
            
            String jsonMapContactString = JSON.serialize(mapContact);
            String jsonMapReferenceabilityTypeString = JSON.serialize(mapReferenceabilityType);
            String jsonNewMapString = JSON.serialize(newMap);
            String jsonOldMapString = JSON.serialize(oldMap);
            String jsonNewListString = JSON.serialize(newList);
            if (!Test.isRunningTest()) {
                Infl_Event.influitiveEventsCallout(jsonMapContactString, jsonMapReferenceabilityTypeString, jsonNewMapString, jsonOldMapString, jsonNewListString);
            }
        } 
    }

    /**
     * Method to add Issued Points
     */
    static void addIssuedPointsOnAccountAndContactAndUser(Set<Id> issueIds, List<Reward__c> newList, Set<Id> accountIssuedIds, Set<Id> contactIssuedIds, 
                                                            Set<Id> userIssuedIds, Set<Id> ChangedContactIds) {
        Map<Id, Reference_Basic_Information__c> accounts = new Map<Id, Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> contacts = new Map<Id, Reference_Basic_Information__c>();
        list<Reference_Basic_Information__c> RBIList = WithoutSharingHelperController.getRefProfilesInRewardTrigger(accountIssuedIds, contactIssuedIds, ChangedContactIds);
        // Added for sales user
        Map<Id, User_Profile__c> userIdToProfilesMap = new Map<Id, User_Profile__c>();
        
        for (User_Profile__c profile : [SELECT Id, User__c, Available_Points__c, Lifetime_Points__c FROM User_Profile__c WHERE User__c 
                                        IN :userIssuedIds LIMIT :limits.getLimitQueryRows()]) {
            userIdToProfilesMap.put(profile.User__c, profile);
        }
        
        for (Reference_Basic_Information__c rbi : RBIList) {
            
            if (accountIssuedIds.contains(rbi.Account__c) || contactIssuedIds.contains(rbi.Contact__c)) {
              
                if (rbi.Contact__c == null) {
                   
                    if (!rbi.Is_Referenceable__c) {
                        rbi.Is_Referenceable__c = true;
                        rbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                        rbi.Reference_Program_Candidate__c = false;
                    }
                    accounts.put(rbi.Account__c, rbi);
                } else {
                   
                    if (!rbi.Is_Referenceable__c) {
                        rbi.Is_Referenceable__c = true;
                        rbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                        rbi.Reference_Program_Candidate__c = false;
                    }
                    contacts.put(rbi.Contact__c, rbi);
                }
            } else if (ChangedContactIds.contains(rbi.Contact__c)) {
               
                if (rbi.Contact__c != null) {
                    contacts.put(rbi.Contact__c, rbi);
                }
            }
        }
        Set<String> accIds = new Set<String>();
        Set<String> conIds = new Set<String>();
        
        for (Reward__c reward : newList) {
           
            if (accounts != null && accounts.containsKey(reward.account__c) && !accounts.get(reward.account__c).Is_Referenceable__c) {
                accounts.get(reward.account__c).Is_Referenceable__c = true;
                accounts.get(reward.account__c).Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                accounts.get(reward.account__c).Reference_Program_Candidate__c = false;
                accIds.add(reward.account__c);
            } else if (reward.account__c != null && reward.Contact__c == null && accounts != null && !accounts.isEmpty() && !accounts.containsKey(reward.account__c)) {
                Reference_Basic_Information__c newRBI = new Reference_Basic_Information__c(Account__c = reward.account__c, Is_Referenceable__c = true, 
                                                                                            Referenceability_Status__c = cs.Default_Referenceablity_Status__c);
                accounts.put(reward.Account__c, newRBI);
                accIds.add(reward.account__c);
            }
            
            if (contacts != null && contacts.containsKey(reward.Contact__c) && !contacts.get(reward.Contact__c).Is_Referenceable__c) {
                contacts.get(reward.Contact__c).Is_Referenceable__c = true;
                contacts.get(reward.Contact__c).Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                contacts.get(reward.Contact__c).Reference_Program_Candidate__c = false;
                conIds.add(reward.Contact__c);
            } else if (reward.Contact__c != null && contacts != null && !contacts.containsKey(reward.Contact__c)) {
                Reference_Basic_Information__c newRBI = new Reference_Basic_Information__c(Contact__c = reward.Contact__c, Account__c = reward.account__c, 
                                                                                    Is_Referenceable__c = true, Referenceability_Status__c = cs.Default_Referenceablity_Status__c);
                contacts.put(reward.Contact__c, newRBI);
                conIds.add(reward.Contact__c);
            }
        }
        
        for (Reward__c reward : newList) {
          
            if (issueIds != null && issueIds.contains(reward.Id)) {
              
                if (accounts != null && accounts.containsKey(reward.account__c)) {
                    accounts.get(reward.account__c).Lifetime_Points__c = (accounts.get(reward.account__c).Lifetime_Points__c != null ? 
                                                    accounts.get(reward.account__c).Lifetime_Points__c + (reward.Amount__c != null ? reward.Amount__c : 0) : 
                                                    (reward.Amount__c != null ? reward.Amount__c : 0));
                    
                    if (!reward.Expired__c)
                        accounts.get(reward.account__c).Current_Available_Balance_Points__c = (accounts.get(reward.account__c).Current_Available_Balance_Points__c != null ? accounts.get(reward.account__c).Current_Available_Balance_Points__c + (reward.Amount__c != null ? reward.Amount__c : 0) : (reward.Amount__c != null ? reward.Amount__c : 0));
                    accIds.add(reward.account__c);
                }
                if (reward.Contact__c != null && contacts != null && contacts.containsKey(reward.Contact__c)) {
                    contacts.get(reward.Contact__c).Lifetime_Points__c = (contacts.get(reward.Contact__c).Lifetime_Points__c != null ? 
                                                    contacts.get(reward.Contact__c).Lifetime_Points__c + (reward.Amount__c != null ? reward.Amount__c : 0) : 
                                                    (reward.Amount__c != null ? reward.Amount__c : 0));
                    
                    //added to show available points on contact for Issue R15.33
                    if (!reward.Expired__c) {
                        contacts.get(reward.Contact__c).Current_Available_Balance_Points__c = (contacts.get(reward.Contact__c).Current_Available_Balance_Points__c != null 
                                                                            ? contacts.get(reward.Contact__c).Current_Available_Balance_Points__c 
                                                                            + (reward.Amount__c != null ? reward.Amount__c : 0) : 
                                                                            (reward.Amount__c != null ? reward.Amount__c : 0));
                    }
                    conIds.add(reward.Contact__c);
                }
               
                // Added for sales user
                if (reward.User__c != null && userIdToProfilesMap != null && userIdToProfilesMap.containsKey(reward.User__c)) {
                    userIdToProfilesMap.get(reward.User__c).Lifetime_Points__c = (userIdToProfilesMap.get(reward.User__c).Lifetime_Points__c != null ? 
                                                                        userIdToProfilesMap.get(reward.User__c).Lifetime_Points__c + (reward.Amount__c != null ? 
                                                                        reward.Amount__c : 0) : (reward.Amount__c != null ? reward.Amount__c : 0));

                    if (!reward.Expired__c)
                        userIdToProfilesMap.get(reward.User__c).Available_Points__c = (userIdToProfilesMap.get(reward.User__c).Available_Points__c != null ? 
                                                                        userIdToProfilesMap.get(reward.User__c).Available_Points__c + (reward.Amount__c != null ? 
                                                                        reward.Amount__c : 0) : (reward.Amount__c != null ? reward.Amount__c : 0));

                }
            }
        }
       
        for (Id ContactId : ChangedContactIds) {
           
            if (contacts.containsKey(ContactId)) {
                contacts.get(ContactId).Lifetime_Points__c = 0;
                conIds.add(ContactId);
            }
        }
        List<Reference_Basic_Information__c> RBIList2 = new List<Reference_Basic_Information__c>();
       
        if (accounts != null && accounts.size() > 0) {
           
            for (Reference_Basic_Information__c rbi : accounts.values()) {
             
                if (accIds.contains(rbi.Account__c)) {
                    RBIList2.add(rbi);
                }
            }
        }
       
        if (contacts != null && contacts.size() > 0) {
            
            for (Reference_Basic_Information__c rbi : contacts.values()) {
               
                if (conIds.contains(rbi.Contact__c)) {
                    RBIList2.add(rbi);
                }
            }
        }
       
        if (RBIList2.size() > 0) {
            WithoutSharingHelperController.upsertRBI(RBIList2);
        }
        
        // Added for sales user
        if (userIdToProfilesMap.size() > 0) {
            WithoutSharingHelperController.updateSalesUserProfiles(userIdToProfilesMap.values());
        }
    }

    /**
     * Method to Remove Redeem Points
     */
    static void removeRedeemPointOnAccountContactAndRewards(Set<Id> redeemIds, List<Reward__c> newList, Set<Id> accountRedeemIds, Set<Id> contactRedeemIds, 
                                                                                Set<Id> userRedeemIds) {
        Map<Id, List<Reward__c>> issuedRewards = new Map<Id, List<Reward__c>>();
        Map<Id, Reference_Basic_Information__c> accounts = new Map<Id, Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> contacts = new Map<Id, Reference_Basic_Information__c>();
        List<Reward__c> updateIssuedRewards = new List<Reward__c>();
        Decimal amount = 0;
        boolean isError = false;
        Map<Id, Reward__c> rewardMap = new Map<Id, Reward__c>();
        Set<id> ids = new Set<Id>();
       
        if (contactRedeemIds.size() > 0 || accountRedeemIds.size() > 0 || userRedeemIds.size() > 0) {
            rewardMap = new Map<Id, Reward__c > ([SELECT Id, Transaction__c, Expired__c, Available_Points__c, Contact__c, Account__c, User__c 
                                                        FROM Reward__c WHERE (Contact__c IN :contactRedeemIds OR Account__c In: accountRedeemIds OR User__c 
                                                        IN :userRedeemIds) AND Expired__c = false AND Available_Points__c != 0 
                                                        AND Transaction__c =:ConstantsController.ISSUE ORDER BY CreatedDate, Name]);
            
            for (Reward__c reward : rewardMap.values()) {
              
                if (accountRedeemIds.contains(reward.Account__c) || contactRedeemIds.contains(reward.Contact__c)) {
                 
                    if (!issuedRewards.containsKey(reward.Account__c))
                        issuedRewards.put(reward.Account__c, new List<Reward__c>());
                    issuedRewards.get(reward.Account__c).add(reward);
                }
               
                if (userRedeemIds.contains(reward.User__c)) {
                    if (!issuedRewards.containsKey(reward.User__c))
                        issuedRewards.put(reward.User__c, new List<Reward__c>());
                    issuedRewards.get(reward.User__c).add(reward);
                }
            }
        }

        // Added for sales user
        Map<Id, User_Profile__c> userIdToProfilesMap = new Map<Id, User_Profile__c>();
       
        for (User_Profile__c profile : [SELECT Id, User__c, Available_Points__c, Lifetime_Points__c FROM User_Profile__c WHERE User__c 
                                                                IN :userRedeemIds LIMIT :limits.getLimitQueryRows()]) {
            userIdToProfilesMap.put(profile.User__c, profile);
        }

        List<Reference_Basic_Information__c> RBIList = [SELECT Id, Account__c, Contact__c, Contact__r.Name, Name, Is_Referenceable__c,
                                                             Referenceability_Status__c, Lifetime_Points__c, Current_Available_Balance_Points__c 
                                                             FROM Reference_Basic_Information__c WHERE Account__c != null AND 
                                                             (Contact__c IN :contactRedeemIds OR Account__c IN :accountRedeemIds) ORDER BY 
                                                             Contact__r.Name LIMIT :limits.getLimitQueryRows()];
        
        for (Reference_Basic_Information__c rbi : RBIList) {
            
            if (rbi.Contact__c == null) {
                accounts.put(rbi.Account__c, rbi);
            } else {
                contacts.put(rbi.Contact__c, rbi);
            }
        }
        
        for (Reward__c reward : newList) {
            
            if (accounts != null && accounts.containsKey(reward.Account__c) && (accounts.get(reward.Account__c).Current_Available_Balance_Points__c == null 
                                                                        || accounts.get(reward.Account__c).Current_Available_Balance_Points__c < reward.amount__c)) {
                reward.addError(System.label.Amount_Incorrect);
                isError = true;
            }
            
            if (redeemIds.contains(reward.Id) && issuedRewards.containsKey(reward.Account__c) && reward.Account__c != null) {
                amount = reward.amount__c;
                
                for (Reward__c issuedReward : issuedRewards.get(reward.Account__c)) {
                   
                    if (reward.Contact__c != null && issuedReward.Contact__c == reward.Contact__c) {
                       
                        if (rewardMap.get(issuedReward.Id).Available_Points__c != null && rewardMap.get(issuedReward.Id).Available_Points__c <= amount && amount != 0) {
                            amount = amount - rewardMap.get(issuedReward.Id).Available_Points__c;
                            rewardMap.get(issuedReward.Id).Available_Points__c = 0;
                        } else if (amount != 0 && rewardMap.get(issuedReward.Id).Available_Points__c != null) {
                            rewardMap.get(issuedReward.Id).Available_Points__c = rewardMap.get(issuedReward.Id).Available_Points__c - amount;
                            amount = 0;
                            break;
                        }
                    } else if (reward.Contact__c == null && issuedReward.Contact__c == null) {
                       
                        if (rewardMap.get(issuedReward.Id).Available_Points__c != null && rewardMap.get(issuedReward.Id).Available_Points__c <= amount && amount != 0) {
                            amount = amount - rewardMap.get(issuedReward.Id).Available_Points__c;
                            rewardMap.get(issuedReward.Id).Available_Points__c = 0;
                        } else if (amount != 0 && rewardMap.get(issuedReward.Id).Available_Points__c != null) {
                            rewardMap.get(issuedReward.Id).Available_Points__c = rewardMap.get(issuedReward.Id).Available_Points__c - amount;
                            amount = 0;
                            break;
                        }
                    }
                }
                
                if (accounts != null && reward.Account__c != null && accounts.containsKey(reward.Account__c)) {
                    accounts.get(reward.Account__c).Current_Available_Balance_Points__c = (accounts.get(reward.Account__c).Current_Available_Balance_Points__c != null 
                                                                ? accounts.get(reward.Account__c).Current_Available_Balance_Points__c - reward.amount__c : 0);
                }
                
                //added for Issue R15.33
                if (contacts != null && reward.Contact__c != null && contacts.containsKey(reward.Contact__c)) {
                    contacts.get(reward.Contact__c).Current_Available_Balance_Points__c = (contacts.get(reward.Contact__c).Current_Available_Balance_Points__c != null 
                                                                ? contacts.get(reward.Contact__c).Current_Available_Balance_Points__c - reward.amount__c : 0);
                }
            }
            
            if (redeemIds.contains(reward.Id) && issuedRewards.containsKey(reward.User__c) && reward.User__c != null) {
                amount = reward.amount__c;
               
                for (Reward__c issuedReward : issuedRewards.get(reward.User__c)) {
                    
                    if (rewardMap.get(issuedReward.Id).Available_Points__c != null && rewardMap.get(issuedReward.Id).Available_Points__c <= amount && amount != 0) {
                        amount = amount - rewardMap.get(issuedReward.Id).Available_Points__c;
                        rewardMap.get(issuedReward.Id).Available_Points__c = 0;
                    } else if (amount != 0 && rewardMap.get(issuedReward.Id).Available_Points__c != null) {
                        rewardMap.get(issuedReward.Id).Available_Points__c = rewardMap.get(issuedReward.Id).Available_Points__c - amount;
                        amount = 0;
                        break;
                    }
                }
               
                // Added for sales user
                if (userIdToProfilesMap != null && reward.User__c != null && userIdToProfilesMap.containsKey(reward.User__c)) {
                    userIdToProfilesMap.get(reward.User__c).Available_Points__c = (userIdToProfilesMap.get(reward.User__c).Available_Points__c != null 
                                                    ? userIdToProfilesMap.get(reward.User__c).Available_Points__c - reward.amount__c : 0);
                }
            }
        }
        
        if (!isError) {
            updateAccountContact(newList, accounts, contacts);
            
            if (rewardMap.size() > 0) {
                List<Reward__c> updateIssuedRewardsT = rewardMap.values();  
                WithoutSharingHelperController.updateRewards(updateIssuedRewardsT);
            }
            
            // Added for sales user
            if (userIdToProfilesMap.size() > 0) {
                WithoutSharingHelperController.updateSalesUserProfiles(userIdToProfilesMap.values());
            }
        }
    }
    
    /**
     * Method to update Account AND Contact
     */
    public static void updateAccountContact(List<Reward__c> newList,
                                            Map<Id, Reference_Basic_Information__c> accounts,
                                            Map<Id, Reference_Basic_Information__c> contacts) {
        
        List<Reference_Basic_Information__c> RBIList = new List<Reference_Basic_Information__c>();
        
        for (Reward__c reward : newList) {
            
            if (accounts != null && accounts.containsKey(reward.account__c)
                                && !accounts.get(reward.account__c).Is_Referenceable__c) {
                
                accounts.get(reward.account__c).Is_Referenceable__c = true;
                accounts.get(reward.account__c).Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                accounts.get(reward.account__c).Reference_Program_Candidate__c = false;
            }
            
            if (contacts != null && contacts.containsKey(reward.Contact__c)
                                && !contacts.get(reward.Contact__c).Is_Referenceable__c) {
                
                contacts.get(reward.Contact__c).Is_Referenceable__c = true;
                contacts.get(reward.Contact__c).Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                contacts.get(reward.Contact__c).Reference_Program_Candidate__c = false;
            }
        }
        
        if (accounts != null && accounts.size() > 0) {
            RBIList.addAll(accounts.values());
        }
        
        if (contacts != null && contacts.size() > 0) {
            RBIList.addAll(contacts.values());
        }
        
        if (RBIList.size() > 0) {
            ConstantsController.isNotFromRewardTrigger = false;
            WithoutSharingHelperController.updateRBI(RBIList);
        }
    }

    /**
     * Wrapper class
     **/
    public class RewardCalculationWrp {
        public Decimal addAmount;
        public List<Reward__c> rewardsToBeUpdate;

        public RewardCalculationWrp(Decimal addAmount, List<Reward__c> rewardsToBeUpdate) {
            this.addAmount = addAmount;
            this.rewardsToBeUpdate = rewardsToBeUpdate;
        }
    }
}