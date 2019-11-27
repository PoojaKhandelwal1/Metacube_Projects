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
 * Trigger: Reference Request Account
 * Description: Trigger used to handel Reference Request Account
 * Last Modified by: Rajesh @23 March 2018
 */
public with sharing class RRAccountContactTriggerHandler extends RefEdgeEditionFeatures {
    /**
     * Method called on before insert of Contact Request
     */
    public static void onBeforeInsert(List<Reference_Request_Account_Contact__c> newList) {
        Set<Id> RRAIds = new Set<Id>();
        
        for (Reference_Request_Account_Contact__c rrac : newList) {
            RRAIds.add(rrac.Reference_Request_Account__c);
            //Check Past Date
            if (rrac.Activity_Date__c != null) {
                if (rrac.Activity_Date__c> Date.today()) {
                    rrac.addError(System.Label.ACTIVITY_DATE);
                    return;
                }
            }
        }
        Map<Id, Reference_Request_Account__c> rrAmap = new Map<Id, Reference_Request_Account__c>();
        
        for (Reference_Request_Account__c rra : WithoutSharingHelperController.getAccountRequests(RRAIds)) {
            rrAmap.put(rra.Id, rra);
        }
        
        for (Reference_Request_Account_Contact__c rrac : newList) {
            rrac.Approval_Status__c = rrAmap.get(rrac.Reference_Request_Account__c).Approval_Status__c;
            rrac.Deadline__c = rrAmap.get(rrac.Reference_Request_Account__c).Deadline__c;
        }
    }
    /**
     * Method called on before update of Contact Request
     */
    public static void onBeforeUpdate(List<Reference_Request_Account_Contact__c> newList, Map<Id, Reference_Request_Account_Contact__c> oldMap, Map<Id, Reference_Request_Account_Contact__c> newMap) {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        
        for (Reference_Request_Account_Contact__c rrac : newList) {
            //Check Past Date
            if (rrac.Activity_Date__c != null) {
                
                if (rrac.Activity_Date__c> Date.today()) {
                    rrac.addError(System.Label.ACTIVITY_DATE);
                    return;
                }
            }
           
            if ((rrac.Contact_Request_Status__c == null || rrac.Contact_Request_Status__c == '' || rrac.Contact_Request_Status__c == ConstantsController.NOT_STARTED) && (newMap.get(rrac.Id).Contact_Request_Status__c != oldMap.get(rrac.Id).Contact_Request_Status__c)) {
                rrac.addError(System.Label.Status_cannot_be_reset);
                return;
            }
            
            if (((oldMap.get(rrac.Id).Contact_Request_Status__c) != null && ((oldMap.get(rrac.Id).Contact_Request_Status__c).contains('Give Up') || oldMap.get(rrac.Id).Contact_Request_Status__c == ConstantsController.COMPLETED || oldMap.get(rrac.Id).Contact_Request_Status__c == ConstantsController.UNAVAILABLE || oldMap.get(rrac.Id).Contact_Request_Status__c == ConstantsController.NO_LONGER_NEEDED)) && (newMap.get(rrac.Id).Contact_Request_Status__c != oldMap.get(rrac.Id).Contact_Request_Status__c) && !ConstantsController.shouldCompleteStatusChange) {
                rrac.addError(system.Label.Status_cannot_be_changed);
            }
            
            //Assign User Id
            if (rrac.Contact_Request_Status__c != null && oldMap.get(rrac.Id).Contact_Request_Status__c != newMap.get(rrac.Id).Contact_Request_Status__c && ((rrac.Contact_Request_Status__c).contains('Give Up') || rrac.Contact_Request_Status__c == ConstantsController.COMPLETED || rrac.Contact_Request_Status__c == ConstantsController.NO_LONGER_NEEDED)) {
                rrac.Project_Owner__c = (rrac.Project_Owner__c == null ? Userinfo.getUserId() : rrac.Project_Owner__c);
                
                if (rrac.Contact_Request_Status__c == ConstantsController.COMPLETED && rrac.Activity_Date__c == null) {
                    rrac.Activity_Date__c = date.today();
                }
               
                if (cs.Consider_No_longer_needed_a_use__c && rrac.Contact_Request_Status__c == ConstantsController.NO_LONGER_NEEDED && rrac.Activity_Date__c == null) {
                    rrac.Activity_Date__c = date.today();
                }
            }
        }
    }
    /**
     * Method called on before delete of Contact Request
     */
    public static void onBeforeDelete(Set<Id> oldMapSet) {
        Decimal amount = 0;
        
        for (Reference_Request_Account_Contact__c rrac : [SELECT Id, Contact__c, (SELECT Id, Amount__c FROM Rewards__r) 
        							FROM Reference_Request_Account_Contact__c WHERE Id IN :oldMapSet AND Contact__c != null]) {
           
            if (rrac.Rewards__r.size() > 0) {
                amount = 0;
               
                for (Reward__c reward : rrac.Rewards__r) {
                    ConstantsController.RewardIds.add(reward.Id);
                    amount += reward.Amount__c;
                }
            }
            
            if (!ConstantsController.RBIIdMap.containsKey(rrac.contact__c)) {
                ConstantsController.RBIIdMap.put(rrac.contact__c, 0);
            }
            amount = ConstantsController.RBIIdMap.get(rrac.contact__c) + amount;
            ConstantsController.RBIIdMap.put(rrac.contact__c, amount);
        }
    }
    /**
     * Method called on after delete of Contact Request
     */
    public static void onAfterDelete(List<Reference_Request_Account_Contact__c> oldList) {
        
        if (ConstantsController.RewardIds != null && ConstantsController.RewardIds.size() > 0) {
            List<Reward__c> updateRewardList = [SELECT Id FROM Reward__c WHERE Id IN :ConstantsController.RewardIds];
           
            for (Reward__c reward : updateRewardList) {
                reward.Contact_Request__c = null;
                reward.Contact__c = null;
            }
            
            if (updateRewardList != null && updateRewardList.size() > 0) {
                update updateRewardList;
            }
        }
        
        if (ConstantsController.RBIIdMap != null && ConstantsController.RBIIdMap.size() > 0) {
            List<Reference_Basic_Information__c> updateRBIList = new List<Reference_Basic_Information__c>();
            
            for (Reference_Basic_Information__c rbi : [SELECT Account__c, Lifetime_Points__c, Contact__c FROM Reference_Basic_Information__c WHERE Contact__c != null AND Contact__c IN :ConstantsController.RBIIdMap.keySet()]) {
                
                if (rbi.Lifetime_Points__c != null) {
                    rbi.Lifetime_Points__c = rbi.Lifetime_Points__c - ConstantsController.RBIIdMap.get(rbi.Contact__c);
                    
                    if (rbi.Lifetime_Points__c < 0) {
                        rbi.Lifetime_Points__c = 0;
                    }
                    updateRBIList.add(rbi);
                }
            }
            
            if (updateRBIList != null && updateRBIList.size() > 0) {
                update updateRBIList;
            }
        }
        List<Reference_Request_Account_Contact__c> newRRACList = new List<Reference_Request_Account_Contact__c>();
        
        for (Reference_Request_Account_Contact__c rrac : oldList) {
            
            if (rrac.Contact_Request_Status__c == ConstantsController.COMPLETED) {
                newRRACList.add(rrac);
            }
        }
        
        if (newRRACList.size() > 0) {
            updateContactDetails(newRRACList);
        }
    }
    /**
     * Method called on after undelete of Contact Request
     */
    public static void onAfterUnDelete(List<Reference_Request_Account_Contact__c> newList) {
        List<Reference_Request_Account_Contact__c> newRRACList = new List<Reference_Request_Account_Contact__c>();
        Set<Id> RRAIds = new Set<Id>();
        Map<Id, Reference_Request_Account__c> rrAmap = new Map<Id, Reference_Request_Account__c>();
        Set<Id> refIds = new Set<Id>();
        
        for (Reference_Request_Account_Contact__c rrac : newList) {
            
            if (rrac.Contact_Request_Status__c == ConstantsController.COMPLETED) {
                newRRACList.add(rrac);
                RRAIds.add(rrac.Reference_Request_Account__c);
                refIds.add(rrac.Referenceability_Type__c);
                rrAmap.put(rrac.Reference_Request_Account__c, new Reference_Request_Account__c());
            }
        }
        
        if (newRRACList.size() > 0) {
            updateContactDetails(newRRACList);
        }
    }

    /**
     * Method called on after insert of Contact Request
     */
    public static void onAfterInsert(List<Reference_Request_Account_Contact__c> newList) {
        Set<Id> RRAIds = new Set<Id>();
        Map<Id, Reference_Request_Account__c> rrAmap = new Map<Id, Reference_Request_Account__c>();
        Set<Id> refIds = new Set<Id>();
        Set<Id> RRAIdsforFeedback = new Set<Id>();
        List<Reference_Request_Account_Contact__c> newRRAC = new List<Reference_Request_Account_Contact__c>();
        List<Reference_Request_Account_Contact__c> rewardRRAC = new List<Reference_Request_Account_Contact__c>();
        
        for (Reference_Request_Account_Contact__c tempObj : newList) {
            
            if (tempObj.Reference_Use__c) {
                RRAIds.add(tempObj.Reference_Request_Account__c);
                refIds.add(tempObj.Referenceability_Type__c);
                rewardRRAC.add(tempObj);
                rrAmap.put(tempObj.Reference_Request_Account__c, new Reference_Request_Account__c());
            }
            
            if (tempObj.Contact_Request_Status__c == ConstantsController.COMPLETED || tempObj.Approval_Status__c == ConstantsController.APPROVED) {
                newRRAC.add(tempObj);
            }
            
            if (tempObj.Reference_Use__c && tempObj.Is_Feedback_Received__c && tempObj.Feedback_Status__c != ConstantsController.FEEDBACK_YET_NOT_COMPLETED) {
                RRAIdsforFeedback.add(tempObj.Reference_Request_Account__c);
            }
        }

        if (newRRAC.size() > 0) {
            updateContactDetails(newRRAC);
        }
        
        //REF-1964
        if (refIds.size() > 0 && RefEdgeEditionFeatures.isBasic == false && ConstantsController.isCallToInfluitiveAPI == false) {
            issueRewardPoints(RRAIds, rrAmap, rewardRRAC, refIds);
        }
        
        if (RRAIdsforFeedback.size() > 0 && RefEdgeEditionFeatures.isBasic == false) {
            issueRewardPointsOnFeedback(RRAIdsforFeedback, newList);
        }  
    }

    /**
     * Method called on after update of Contact Request
     */
    public static void onAfterUpdate(List<Reference_Request_Account_Contact__c> newList, Map<Id, Reference_Request_Account_Contact__c> oldMap, Map<Id, Reference_Request_Account_Contact__c> newMap) {
        Set<Id> RRAIds = new Set<Id>();
        Set<Id> RRAIdsforFeedback = new Set<Id>();
        Set<Id> RRAIdstoRemoveRewards = new Set<Id>();
        Set<Id> refIds = new Set<Id>();
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        List<Reference_Request_Account_Contact__c> RULContacts = new List<Reference_Request_Account_Contact__c>();
        Map<Id, Reference_Request_Account__c> rrAmap = new Map<Id, Reference_Request_Account__c>();
        Set<Id> reqIds = new Set<Id>();
        
        for (Reference_Request_Account_Contact__c rrac : newList) {
            reqIds.add(rrac.Reference_Request_Account__c);
        }
        Map<Id, Reference_Request_Account__c> requestMap = new Map<Id, Reference_Request_Account__c>();
        
        for (Reference_Request_Account__c rra : WithoutSharingHelperController.getAccountRequests(reqIds)) {
            requestMap.put(rra.Id, rra);
        }
        
        for (Reference_Request_Account_Contact__c rrac: newList) {
            //Assign User Id
            if (rrac.Contact_Request_Status__c != null && oldMap.get(rrac.Id).Contact_Request_Status__c != newMap.get(rrac.Id).Contact_Request_Status__c && rrac.Contact_Request_Status__c == ConstantsController.COMPLETED && requestMap.get(rrac.Reference_Request_Account__c).Reference_Request__r.Project_Type__c == 'Member') {
                RRAIds.add(rrac.Reference_Request_Account__c);
            }
            
            if (rrac.Is_Feedback_Received__c && rrac.Feedback_Status__c != ConstantsController.FEEDBACK_YET_NOT_COMPLETED && requestMap.get(rrac.Reference_Request_Account__c).Reference_Request__r.Project_Type__c == 'Member') {
                
                if (cs.Remove_Points_if_Use_will_not_occur__c && rrac.Feedback_Status__c == 'Use will not occur'){
                    RRAIdstoRemoveRewards.add(rrac.Reference_Request_Account__c);
                } else {
                    RRAIdsforFeedback.add(rrac.Reference_Request_Account__c);
                }
            }
           
            if (rrac.Contact_Request_Status__c == ConstantsController.COMPLETED && requestMap.get(rrac.Reference_Request_Account__c).Reference_Request__r.Project_Type__c == 'Member') {
                RULContacts.add(rrac);
            }
            
            if (rrac.Contact_Request_Status__c == ConstantsController.NO_LONGER_NEEDED && requestMap.get(rrac.Reference_Request_Account__c).Reference_Request__r.Project_Type__c == 'Member') {
                RULContacts.add(rrac);
            }
        }
        
        if (RULContacts.size() > 0) {
            updateContactDetails(RULContacts);
        }
        List<Reference_Request_Account__c> listRRA = new List<Reference_Request_Account__c>();
        
        for (Reference_Request_Account__c rra : requestMap.values()) {
           
            if (RRAIds.contains(rra.Id)) {
                rra.Account_Request_Status__c = ConstantsController.COMPLETED;
                rra.Project_Owner__c = (rra.Project_Owner__c == null ? Userinfo.getUserId() : rra.Project_Owner__c);
                listRRA.add(rra);
                
                if (requestMap.get(rra.Id).Reference_Request__r.Project_Type__c == 'Member') {
                    rrAmap.put(rra.Id, rra);
                    refIds.add(rra.Reference_Type_Needed__c);
                    RRAIds.remove(rra.Id);
                }
            }
        }
        
        if (listRRA.size() > 0) {
            WithoutSharingHelperController.updateRRA(listRRA);
        }
        
        if (RRAIds.size() > 0 && ConstantsController.shouldRewardRecordsCreated && RefEdgeEditionFeatures.isBasic == false) {
            issueRewardPoints(RRAIds, rrAmap, newList, refIds);
        }
        
        if (RRAIdsforFeedback.size() > 0 && ConstantsController.shouldRewardRecordsCreated && RefEdgeEditionFeatures.isBasic == false) {
            issueRewardPointsOnFeedback(RRAIdsforFeedback, newList);
        }
            
        if (RRAIdstoRemoveRewards.size() > 0 && RefEdgeEditionFeatures.isBasic == false){
            deleteRewards(RRAIdstoRemoveRewards);
        }
    }

    /**
     * Method to Issue reward points on the Account and contact
     */
    static void issueRewardPoints(Set<Id> RRAIds, Map<Id, Reference_Request_Account__c> rrAmap, List<Reference_Request_Account_Contact__c> newList, Set<Id> refIds) {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
       
        if (cs.Automatically_Assign_Rewards__c) {
            List<Reward__c> rewards = new List<Reward__c>();
            Map<Id, Reward__c> existingRewards = new Map<Id, Reward__c>();
            Reward__c reward;
            Map<Id, Decimal> refTypePoints = new Map<Id, Decimal>();
            
            for (Referenceability_Type__c ref : [SELECT Reward_points__c FROM Referenceability_Type__c WHERE Visible__c = true AND Id IN :refIds ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
                refTypePoints.put(ref.Id, (ref.Reward_points__c == null ? 0 : ref.Reward_points__c));
            }
            
            for (Reward__c tempObj : [SELECT Account_Request__c, Transaction__c, Contact__c, Contact_Request__c FROM Reward__c 
            										WHERE Account_Request__c IN :rrAmap.keySet() AND Contact_Request__c = null AND Transaction__c =:ConstantsController.ISSUE]) {
                existingRewards.put(tempObj.Account_Request__c, tempObj);
            }
            
            for (Reference_Request_Account_Contact__c rrAc : newList) {
               
                if (existingRewards.containsKey(rrAc.Reference_Request_Account__c) && rrAc.Reference_Use__c) {
                    existingRewards.get(rrAc.Reference_Request_Account__c).Contact_Request__c = rrAc.Id;
                    existingRewards.get(rrAc.Reference_Request_Account__c).Contact__c = rrAc.Contact__c;
                    rewards.add(existingRewards.get(rrAc.Reference_Request_Account__c));
                } else {
                	
                    if (RRAIds.contains(rrAc.Reference_Request_Account__c)) {
                        reward = new Reward__c();
                        reward.Account__c = rrAmap.get(rrAc.Reference_Request_Account__c).Account__c;
                        reward.Contact__c = rrAc.Contact__c;
                        reward.Referenceability_Type__c = rrAc.Referenceability_Type__c;
                        reward.Amount__c = refTypePoints.get(rrAmap.get(rrAc.Reference_Request_Account__c).Reference_Type_Needed__c);
                        reward.Transaction__c = ConstantsController.ISSUE;
                        reward.RewardDate__c = Date.today();
                        reward.Automatically_Assigned__c = true;
                        reward.Account_Request__c = rrAc.Reference_Request_Account__c;
                        reward.Contact_Request__c = rrAc.Id;
                        reward.Available_Points__c = refTypePoints.get(rrAmap.get(rrAc.Reference_Request_Account__c).Reference_Type_Needed__c);
                        
                        if (cs.Expire_Rewards__c) {
                            reward.Expiration_Date__c = UtilityController.rewardsExpritationDate(cs);
                        }
                        rewards.add(reward);
                    }
                }
            }
            
            if (rewards.size() > 0) {
                ConstantsController.shouldRewardRecordsCreated = false;
                upsert rewards;
            }
        }
    }
    /**
     * Method to Issue reward points on the Account and contact on feedback
     */
    static void issueRewardPointsOnFeedback(Set<Id> RRAIds, List<Reference_Request_Account_Contact__c> newList) {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
       
        if (cs.Automatically_Assign_Reward_on_Feedback__c) {
            List<Reward__c> rewards = new List<Reward__c>();
            Map<Id, Reward__c> existingRewards = new Map<Id, Reward__c>();
            Set<Id> refIds = new Set<Id>();
            Map<Id, Reference_Request_Account__c> rrAmap = new Map<Id, Reference_Request_Account__c>();
            Reward__c reward;
            Map<Id, Decimal> refTypePoints = new Map<Id, Decimal>();
            
            for (Reference_Request_Account__c rra : WithoutSharingHelperController.getAccountRequests(RRAIds)) {
                rrAmap.put(rra.Id, rra);
                refIds.add(rra.Reference_Type_Needed__c);
            }
           
            for (Referenceability_Type__c ref : [SELECT Reward_points__c FROM Referenceability_Type__c WHERE Visible__c = true 
            								AND Id IN :refIds ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
                refTypePoints.put(ref.Id, (ref.Reward_points__c == null ? 0 : ref.Reward_points__c));
            }
            
            for (Reward__c tempObj : [SELECT Account_Request__c, Transaction__c, Contact__c, Contact_Request__c FROM Reward__c 
            							WHERE Account_Request__c IN :rrAmap.keySet() AND Automatically_Assigned__c = true]) {
                existingRewards.put(tempObj.Account_Request__c, tempObj);
            }
            
            for (Reference_Request_Account_Contact__c rrAc : newList) {
               
                if (!existingRewards.containsKey(rrAc.Reference_Request_Account__c)) {
                   
                    if (RRAIds.contains(rrAc.Reference_Request_Account__c)) {
                        reward = new Reward__c();
                        reward.Account__c = rrAmap.get(rrAc.Reference_Request_Account__c).Account__c;
                        reward.Contact__c = rrAc.Contact__c;
                        reward.Referenceability_Type__c = rrAc.Referenceability_Type__c;
                        reward.Amount__c = refTypePoints.get(rrAmap.get(rrAc.Reference_Request_Account__c).Reference_Type_Needed__c);
                        reward.Transaction__c = ConstantsController.ISSUE;
                        reward.RewardDate__c = Date.today();
                        reward.Automatically_Assigned__c = true;
                        reward.Account_Request__c = rrAc.Reference_Request_Account__c;
                        reward.Contact_Request__c = rrAc.Id;
                        reward.Available_Points__c = refTypePoints.get(rrAmap.get(rrAc.Reference_Request_Account__c).Reference_Type_Needed__c);
                       
                        if (cs.Expire_Rewards__c) {
                            reward.Expiration_Date__c = UtilityController.rewardsExpritationDate(cs);
                        }
                        rewards.add(reward);
                    }
                }
            }
            
            if (rewards.size() > 0) {
                ConstantsController.shouldRewardRecordsCreated = false;
                WithoutSharingHelperController.insertRewards(rewards); 
            }
        }
    }
    /**
     * Method to delete Rewards for "Use will not occur" feedback status
     */
    static void deleteRewards(Set<Id> RRAIds) {
        List<Reward__c> rewardList = new List<Reward__c>();
        List<Reward__c> updateRewardList = new List<Reward__c>();
        List<sObject> postFeedItems = new List<sObject>();
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
         
        //REF-1316- Added check for CRP team member should be active
        List<User> publicGroupMembers = UtilityController.getCustomerReferenceTeam(); 
        
        String subject = 'Unable to delete points for ?No Longer Needed? Request';
        String emailBody = '';
        String chatterBody = '';
        
        for (Reward__c reward : [SELECT Transaction__c, Referenceability_Type__r.Name,Account__r.Name, Account_Request__c, Contact_Request__c, 
        					Account_Request__r.Name, Contact_Request__r.Name, Account_Request__r.Reference_Request__r.Name, Account_Request__r.Reference_Request__c, Account_Request__r.Deadline__c, Expired__c,Amount__c,
        						Available_Points__c,Expired_Points__c FROM Reward__c WHERE Account_Request__c != null and Contact_Request__c != null AND Account_Request__c In : RRAIds and Automatically_Assigned__c = true AND Transaction__c =:ConstantsController.ISSUE]) {
           
            if ((!reward.Expired__c && reward.Amount__c> reward.Available_Points__c) || (reward.Expired__c && reward.Amount__c > reward.Expired_Points__c)) {
               
                if (!reward.Expired__c && reward.Available_Points__c > 0) {
                    reward.Amount__c = reward.Amount__c - reward.Available_Points__c;
                    updateRewardList.add(reward);
                }
                emailBody = 'The feedback for the <strong>'+reward.Referenceability_Type__r.Name+'</strong> reference use for <strong>'+reward.Account__r.Name+'</strong> that was scheduled for <strong>'+reward.Account_Request__r.Deadline__c.format()+'</strong> was that it was ?No Longer Needed?.\n\n';
                emailBody += 'Some or all of the points that were originally awarded for this activity could not be deleted because the points:\n';
                emailBody += '?         have already been redeemed and cannot be deleted.\n';
                emailBody += '?         have been partially redeemed. The remaining points have been deleted.\n';
                emailBody += '?         have already been deleted.\n\n';
                emailBody += 'Contact Request: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() +'/'+ reward.Contact_Request__c + '" style="font-size :13px;">'+reward.Contact_Request__r.Name+'</a>\n';
                emailBody += 'Account Request: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() +'/'+ reward.Account_Request__c + '" style="font-size :13px;">'+reward.Account_Request__r.Name+'</a>\n';
                emailBody += 'Reference Request: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() +'/'+ reward.Account_Request__r.Reference_Request__c + '" style="font-size :13px;">'+reward.Account_Request__r.Reference_Request__r.Name+'</a>';
                chatterBody = 'The feedback for the '+reward.Referenceability_Type__r.Name+' reference use for '+reward.Account__r.Name+' that was scheduled for '+reward.Account_Request__r.Deadline__c.format()+' was that it was ?No Longer Needed?.\n\n';
                chatterBody += 'Some or all of the points that were originally awarded for this activity could not be deleted because the points:\n';
                chatterBody += '?         have already been redeemed and cannot be deleted.\n';
                chatterBody += '?         have been partially redeemed. The remaining points have been deleted.\n';
                chatterBody += '?         have already been deleted.\n\n';
                chatterBody += 'Contact Request: ' + URL.getSalesforceBaseUrl().toExternalForm() +'/'+ reward.Contact_Request__c + '\n';
                chatterBody += 'Account Request: ' + URL.getSalesforceBaseUrl().toExternalForm() +'/'+ reward.Account_Request__c + '\n';
                chatterBody += 'Reference Request: ' + URL.getSalesforceBaseUrl().toExternalForm() +'/'+ reward.Account_Request__r.Reference_Request__c;
                
                for (User gm : publicGroupMembers) {
                    String userId = gm.Id;
	            	
	            	if (userId.startsWith('005')) {
	                    postFeedItems.add(MailChatterController.preparePost(subject, userId,chatterBody, ''));
	                    listmail.add(MailChatterController.prepareEmail(subject, userId,emailBody, false));
	            	}
                }
            } else {
                rewardList.add(reward);
            }
        }
        //Insert list of postFeedItems
        if (postFeedItems.size() > 0) {
            postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
        }
        //Send List of emails
        if (listmail.size() > 0) {
            Messaging.sendEmail(listmail);
        }
            
        if (rewardList.size() > 0) {
            //delete rewardList;
            WithoutSharingHelperController.deleteRewards(rewardList);
        }
        
        if (updateRewardList.size() > 0) {
            update updateRewardList;
        }
    }
    /**
     * Method to Update Contact Details
     */
    static void updateContactDetails(List<Reference_Request_Account_Contact__c> newList) {
        Set<Id> contactIds = new Set<Id>();
        List<Contact> updatedContacts = new List<Contact>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> processedContactIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        List<Reference_Basic_Information__c> updateContact = new List<Reference_Basic_Information__c>();
       
        for (Reference_Request_Account_Contact__c tempObj : newList) {
            contactIds.add(tempObj.Contact__c);
            userIds.add(tempObj.CreatedById);
        }
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Map<Id, User> userMap = new Map<Id, User> ([SELECT Id, Name FROM User WHERE Id IN :userIds]);
        Map<Id, Reference_Basic_Information__c> contactMap = new Map<Id, Reference_Basic_Information__c>();
        
        for (Reference_Basic_Information__c rbi : [SELECT Account__c, RUL_Period__c, Default_Period_Completed_Uses__c, RUL_Limit_Reached__c, Reference_Program_Candidate__c,
        									RUL_Last_Updated_By__c, RUL_Last_Activity_Date__c, RUL_Date_Available__c, RUL_Activities_will_do__c, RUL_Activities_used__c, 
        									Referenceability_Status__c, Is_Referenceable__c, Contact__c FROM Reference_Basic_Information__c 
        									WHERE Reference_Program_Candidate__c = false AND Contact__c != null AND Contact__c IN :ContactIds]) {
            contactMap.put(rbi.Contact__c, rbi);
            accountIds.add(rbi.Account__c);
        }
        Map<Id, Reference_Basic_Information__c> accountMap = new Map<Id, Reference_Basic_Information__c>();
       
        for (Reference_Basic_Information__c rbi : [SELECT Id, Name, Account__c, Is_Referenceable__c, Referenceability_Status__c, RUL_Period__c, Reference_Program_Candidate__c,
        											Default_Period_Completed_Uses__c, RUL_Limit_Reached__c, RUL_Last_Updated_By__c, RUL_Last_Activity_Date__c,
        											RUL_Date_Available__c, RUL_Activities_will_do__c, RUL_Activities_used__c, Account_Level_RUL__c FROM 
        											Reference_Basic_Information__c WHERE Reference_Program_Candidate__c = false AND Account__c != null AND 
        											Contact__c = null and Account__c IN :accountIds AND Generic_Account__c = false]) {
            accountMap.put(rbi.Account__C, rbi);
        }
        Map<String, List<Reference_Request_Account_Contact__c>> rrAccConMapForDefaultCompleteUse = new Map<String, List<Reference_Request_Account_Contact__c>> ();
        Map<String, List<Reference_Request_Account_Contact__c>> rrAccConMapForCompleteUse = new Map<String, List<Reference_Request_Account_Contact__c>> ();
        Map<Id, List<Reference_Request_Account_Contact__c>> rrCntMap = new Map<Id, List<Reference_Request_Account_Contact__c>> ();
       
        for (Reference_Request_Account_Contact__c tempObj : [SELECT Contact__c, Activity_Date__c, Contact_Request_Status__c, Id 
        							FROM Reference_Request_Account_Contact__c WHERE Contact__c In : contactMap.keySet() and (Contact_Request_Status__c = 'Completed'
							                OR Approval_Status__c = 'Approved' OR Contact_Request_Status__c = :ConstantsController.NO_LONGER_NEEDED)]) {
            
            if (tempObj.Contact_Request_Status__c == ConstantsController.COMPLETED) {
                
                if (!rrCntMap.containsKey(tempObj.Contact__c)) {
                    rrCntMap.put(tempObj.Contact__c, new List<Reference_Request_Account_Contact__c>());
                }
                rrCntMap.get(tempObj.Contact__c).add(tempObj);
                
                if (contactMap.containsKey(tempObj.Contact__c) && tempObj.Activity_Date__c != null && (tempObj.Activity_Date__c).daysBetween(date.today()) <= contactMap.get(tempObj.Contact__c).RUL_Period__c) {
                   
                    if (!rrAccConMapForCompleteUse.containsKey(tempObj.Contact__c))
                        rrAccConMapForCompleteUse.put(tempObj.Contact__c, new List<Reference_Request_Account_Contact__c>());
                    rrAccConMapForCompleteUse.get(tempObj.Contact__c).add(tempObj);
                }
                
                if (tempObj.Activity_Date__c != null && (tempObj.Activity_Date__c).daysBetween(date.today()) <= cs.RUL_Period_Contact__c) {
                    
                    if (!rrAccConMapForDefaultCompleteUse.containsKey(tempObj.Contact__c))
                        rrAccConMapForDefaultCompleteUse.put(tempObj.Contact__c, new List<Reference_Request_Account_Contact__c>());
                    rrAccConMapForDefaultCompleteUse.get(tempObj.Contact__c).add(tempObj);
                }
            } else if (tempObj.Contact_Request_Status__c == ConstantsController.NO_LONGER_NEEDED && cs.Consider_No_longer_needed_a_use__c) {
                
                if (!rrCntMap.containsKey(tempObj.Contact__c)) {
                    rrCntMap.put(tempObj.Contact__c, new List<Reference_Request_Account_Contact__c>());
                }
                rrCntMap.get(tempObj.Contact__c).add(tempObj);
                
                if (contactMap.containsKey(tempObj.Contact__c) && tempObj.Activity_Date__c != null && (tempObj.Activity_Date__c).daysBetween(date.today()) <= contactMap.get(tempObj.Contact__c).RUL_Period__c) {
                    
                    if (!rrAccConMapForCompleteUse.containsKey(tempObj.Contact__c)) {
                        rrAccConMapForCompleteUse.put(tempObj.Contact__c, new List<Reference_Request_Account_Contact__c>());
                    }
                    rrAccConMapForCompleteUse.get(tempObj.Contact__c).add(tempObj);
                }
            }
        }
        ContactIds.clear();
        
        for (Reference_Request_Account_Contact__c tempObj : newlist) {
            
            if (ContactMap.containsKey(tempObj.Contact__c)) {
                Reference_Basic_Information__c c = ContactMap.get(tempObj.Contact__c);
               
                if (!c.Is_Referenceable__c && !c.Reference_Program_Candidate__c && !ConstantsController.forcecompleted) {
                    c.Is_Referenceable__c = true;
                    c.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                }
                
                if (rrAccConMapForCompleteUse.containsKey(tempObj.Contact__c)) {
                    c.RUL_Activities_used__c = rrAccConMapForCompleteUse.get(tempObj.Contact__c).size();
                } else {
                    c.RUL_Activities_used__c = 0;
                }
               
                if (tempObj.Contact_Request_Status__c == ConstantsController.COMPLETED && !ConstantsController.forcecompleted) {
                   
                    if (c.RUL_Last_Activity_Date__c != null && c.RUL_Last_Activity_Date__c < tempObj.Activity_Date__c) {
                        c.RUL_Last_Activity_Date__c = date.valueOf(tempObj.Activity_Date__c);
                    } else if (c.RUL_Last_Activity_Date__c == null) {
                        c.RUL_Last_Activity_Date__c = date.valueOf(tempObj.Activity_Date__c);
                    }

                    if (rrAccConMapForDefaultCompleteUse.containsKey(tempObj.Contact__c)) {
                        c.Default_Period_Completed_Uses__c = rrAccConMapForDefaultCompleteUse.get(tempObj.Contact__c).size();
                    } else {
                        c.Default_Period_Completed_Uses__c = 0;
                    }
                }
               
                if (tempObj.Activity_Date__c != null && (tempObj.Activity_Date__c).daysBetween(date.today()) <= c.RUL_Period__c) {
                    c.RUL_Last_Updated_By__c = userMap.get(tempObj.CreatedById).Name + ',' + tempObj.CreatedDate.format();
                    //contact RUL settings being used
                   
                    if (accountMap.containsKey(c.Account__c)) {
                       
                        if (accountMap.get(c.Account__c).Account_Level_RUL__c != null && accountMap.get(c.Account__c).Account_Level_RUL__c == false) {
                           
                            if (c.RUL_Activities_will_do__c != null && c.RUL_Activities_used__c >= c.RUL_Activities_will_do__c && c.RUL_Limit_Reached__c == false) {
                                c.RUL_Limit_Reached__c = true;
                                c.RUL_Date_Available__c = date.valueOf(tempObj.CreatedDate.addDays(integer.valueOf(c.RUL_Period__c)));
                            } else if (c.RUL_Activities_will_do__c != null && c.RUL_Activities_used__c < c.RUL_Activities_will_do__c && c.RUL_Limit_Reached__c == true) {
                                c.RUL_Limit_Reached__c = false;
                            }
                        } else if (accountMap.get(c.Account__c).Account_Level_RUL__c != null && accountMap.get(c.Account__c).Account_Level_RUL__c == true) {
                            
                            if (accountMap.get(c.Account__c).RUL_Activities_will_do__c != null && c.RUL_Activities_used__c >= accountMap.get(c.Account__c).RUL_Activities_will_do__c && c.RUL_Limit_Reached__c == false) {
                                c.RUL_Activities_will_do__c = accountMap.get(c.Account__c).RUL_Activities_will_do__c;
                                c.RUL_Period__c = accountMap.get(c.Account__c).RUL_Period__c;
                                c.RUL_Limit_Reached__c = true;
                                c.RUL_Date_Available__c = date.valueOf(tempObj.CreatedDate.addDays(integer.valueOf(accountMap.get(c.Account__c).RUL_Period__c)));
                            }
                        }
                    }
                }
                
                if (rrCntMap.get(tempObj.Contact__c) != null) {
                    c.Total_Reference_Use__c = rrCntMap.get(tempObj.Contact__c).size();
                } else {
                    c.Total_Reference_Use__c = 0;
                }
                ContactMap.put(tempObj.Contact__c, c);
                ContactIds.add(tempObj.Contact__c);
            }
        }
        
        for (String CID : ContactIds) {
            updateContact.add(ContactMap.get(CID));
        }
       
        if (updateContact.size() > 0) {
            update updateContact;
        }
    }
}