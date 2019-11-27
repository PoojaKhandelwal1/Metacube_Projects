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
 * Class: Schedular_ResetRBIRewardsPoint
 * Description : This Batch called from Schedular_ResetRBIRewardsPoint to expire the points of rewards after the expiration date 
 * Modified by: Rekha Jangir @Nov/18/2016
 */
global with sharing class Batch_ResetRBIRewardsPoint extends RefEdgeEditionFeatures
												implements Database.Batchable<sObject>, Database.stateful {
	
    /**
     * Properties and variables
     */
    private Date oneDayBeforeToday = Date.Today() - 1;
    private Map<Id, Reference_Basic_Information__c> rbiMap;
    private Map<Id, User_Profile__c> profileMap;
    private String soqlQuery = 'SELECT Amount__c, Account__c, Available_Points__c, Expired_Points__c,' +
    								'Expiration_Date__c, Expired__c, User__c, Transaction__c ' +
    								'FROM Reward__c';
	private List<String> listOfFailedRecords = new List<String>();
	//REF-2086
	public List<Reward__c> failedRewards = new List<Reward__c>();
	public List<Reference_Basic_Information__c> failedAccountRBIs = new List<Reference_Basic_Information__c>();
	public Map<String,Reference_Basic_Information__c> mapFailedAccountIdToRBI = new Map<String,Reference_Basic_Information__c>();
	public List<User_Profile__c> failedUserProfiles = new List<User_Profile__c>();
	public Map<String,User_Profile__c> mapFailedUserIdToUserProfile = new Map<String,User_Profile__c>();
	public Map<String,List<Reward__c>> mapAccUserIdToListOfRewards = new Map<String,List<Reward__c>>();

    /**
     * Constructor
     */
    global Batch_ResetRBIRewardsPoint() {}

    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        rbiMap = new Map<Id, Reference_Basic_Information__c>();
        Set<String> setAccount = new Set<String>();
        
        // fetch all account RBIs REF-2086
        for (Reference_Basic_Information__c rbi : [SELECT Id, Account__c, Name, Is_Referenceable__c,
    												Current_Available_Balance_Points__c
    												FROM Reference_Basic_Information__c
    												WHERE Contact__c = null
    												AND Account__c != null
                                                    AND (Referenceability_Status__c =:ConstantsController.ACTIVE
                                                    OR Referenceability_Status__c =:ConstantsController.CAUTION)
    												LIMIT :limits.getLimitQueryRows()]) {
            rbiMap.put(rbi.Account__c, rbi);
            setAccount.add(rbi.Account__c);
        }
		profileMap = new Map<Id, User_Profile__c>();
        Set<String> setUser = new Set<String>();
        
        // fetch all user profiles
        for (User_Profile__c rbi : [SELECT Id, User__c, Name, Available_Points__c
        								FROM User_Profile__c
        								WHERE User__c != null
        								LIMIT :limits.getLimitQueryRows()]) {
            profileMap.put(rbi.User__c, rbi);
            setUser.add(rbi.User__c);
        }
        
        if (!setAccount.isEmpty()) {
            soqlQuery = soqlQuery + ' WHERE (Account__c IN :setAccount OR User__c In :setUser) AND Expired__c = false';
        }
        return Database.getQueryLocator(soqlQuery);
    }
    
    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List < Reward__c > scope) {
        
        //check for basic edition because reward is not a basic edition feature
        if (!isBasic) {
            Decimal availableBalancePoints;
            List<Reward__c> rewards = new List<Reward__c>();
            Map<Id, Reference_Basic_Information__c> listUpdateRBI = new Map<Id, Reference_Basic_Information__c>();
            Map<Id, User_Profile__c> listUpdateProfile = new Map<Id, User_Profile__c>();
            
            for (Reward__c reward : scope) {
            	
                if (reward.Account__c != null) {
	                availableBalancePoints = rbiMap.get(reward.Account__c).Current_Available_Balance_Points__c;
	                
	                if (reward.Expiration_Date__c != null
	                		&& oneDayBeforeToday.daysBetween(reward.Expiration_Date__c) <= 0
	                		&& !reward.Expired__c
	                		&& reward.Transaction__c == ConstantsController.ISSUE) {
	                    
                        //REF-2086
	                    if (reward.Available_Points__c != null) {
		                    reward.Expired__c = true;
		                    rbiMap.get(reward.Account__c).Current_Available_Balance_Points__c
		                    					= availableBalancePoints - (reward.Available_Points__c);
		                    listUpdateRBI.put(rbiMap.get(reward.Account__c).Id, rbiMap.get(reward.Account__c));
                            
                            if (mapAccUserIdToListOfRewards.containsKey(reward.Account__c)) {
                                 mapAccUserIdToListOfRewards.get(reward.Account__c).add(reward);
                            } else {
                                mapAccUserIdToListOfRewards.put(reward.Account__c, new List<Reward__c> {reward});
                            }
		                    rewards.add(reward);
	                    }
	                }
                } else if (reward.User__c != null) {
                	availableBalancePoints = profileMap.get(reward.User__c).Available_Points__c;
	                
	                if (reward.Expiration_Date__c != null
	                		&& oneDayBeforeToday.daysBetween(reward.Expiration_Date__c) <= 0
	                		&& !reward.Expired__c
	                		&& reward.Transaction__c == ConstantsController.ISSUE) {
	                    
	                    if (reward.Available_Points__c != null) {
		                    reward.Expired__c = true;
		                    profileMap.get(reward.User__c).Available_Points__c
		                    					= availableBalancePoints - (reward.Available_Points__c);
		                    listUpdateProfile.put(profileMap.get(reward.User__c).Id, profileMap.get(reward.User__c));
                            
                            if (mapAccUserIdToListOfRewards.containsKey(reward.User__c)) {
                                 mapAccUserIdToListOfRewards.get(reward.User__c).add(reward);
                            } else {
                                mapAccUserIdToListOfRewards.put(reward.User__c, new List<Reward__c> {reward});
                            }
		                    rewards.add(reward);
	                    }
	                }
                }
            }
            
            //List of Failed Records
            //REF-2086
            Integer count = 0;
            //Update rewards
            if (rewards.size() > 0) {
                Database.SaveResult[] updateRewards = database.update(rewards, false);
                
                for (database.Saveresult sr : updateRewards) {
                    
                    if (!sr.isSuccess()) {
                        listOfFailedRecords.add('Rewards Update Error : ' + sr.getErrors()[0].getMessage());
						failedRewards.add(rewards[count]);                      
                    }
                    count++;
                }
            }
            
            count = 0;
            List<Reference_Basic_Information__c> listofRBIsToUpdate = listUpdateRBI.values();
            //Update RBI
            if (listUpdateRBI != null && listUpdateRBI.size() > 0) {
                Database.SaveResult[] updateAccounts = database.update(listUpdateRBI.values(), false);
                
                for (database.Saveresult sr : updateAccounts) {
                    
                    if (!sr.isSuccess()) {
                        listOfFailedRecords.add('Account RBI update Error : ' + sr.getErrors()[0].getMessage());
						failedAccountRBIs.add(listofRBIsToUpdate[count]);
                        mapFailedAccountIdToRBI.put(listofRBIsToUpdate[count].Account__c, listofRBIsToUpdate[count]);
                    }
                    count++;
                }
                
                for (Reference_Basic_Information__c rbi : [SELECT Id, Account__c, Name, Is_Referenceable__c,
                												Current_Available_Balance_Points__c
                												FROM Reference_Basic_Information__c
                												WHERE Contact__c = null
                												AND Account__c != null
                												AND Id IN :listUpdateRBI.keySet()]) {
                    rbiMap.put(rbi.Account__c, rbi);
                }
            }
            
            count = 0;
            List<User_Profile__c> listUserProfilesToUpdate = listUpdateProfile.values();
            //Update Profile
            if (listUpdateProfile != null && listUpdateProfile.size() > 0) {
                Database.SaveResult[] updateAccounts = database.update(listUpdateProfile.values(), false);
                
                for (database.Saveresult sr : updateAccounts) {
                    
                    if (!sr.isSuccess()) {
                        listOfFailedRecords.add('Account RBI update Error : ' + sr.getErrors()[0].getMessage());
						failedUserProfiles.add(listUserProfilesToUpdate[count]);
                        mapFailedUserIdToUserProfile.put(listUserProfilesToUpdate[count].User__c, listUserProfilesToUpdate[count]);
                    }
                    count++;
                }
                
                for (User_Profile__c rbi : [SELECT Id, User__c, Name, Available_Points__c
                								FROM User_Profile__c
                								WHERE User__c != null
                								AND Id IN :listUpdateProfile.keySet()]) {
                    profileMap.put(rbi.User__c, rbi);
                }
            }
        }
    }
    
    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {
        //Send Error Email to Refedge Team
        UtilityController.sendEmailNotification(listOfFailedRecords, 'Reset RBIReward Batch');
        
        //REF-2086
        List<Reference_Basic_Information__c> updatedRBIs = new List<Reference_Basic_Information__c>();
        List<User_Profile__c> updatedUserProfiles = new List<User_Profile__c>();
        List<Reward__c> updatedRewards = new List<Reward__c>();
        
        if (failedRewards.size() > 0) {
            
            for (Reward__c failedReward : failedRewards) {
                
                if (rbiMap.containsKey(failedReward.Account__c) && !mapFailedAccountIdToRBI.containsKey(failedReward.Account__c)) {
                    rbiMap.get(failedReward.Account__c).Current_Available_Balance_Points__c += failedReward.Available_Points__c;
                    updatedRBIs.add(rbiMap.get(failedReward.Account__c));
                    
                } else if (profileMap.containsKey(failedReward.User__c) && !mapFailedUserIdToUserProfile.containsKey(failedReward.User__c)) {
                    profileMap.get(failedReward.User__c).Available_Points__c += failedReward.Available_Points__c;
                    updatedUserProfiles.add(profileMap.get(failedReward.User__c));
                }
            }
        }
        
        if (failedAccountRBIs.size() > 0) {
            
            for (Reference_Basic_Information__c rbi : failedAccountRBIs) {
                
                if (mapAccUserIdToListOfRewards.containsKey(rbi.Account__c)) {
                    updatedRewards.addAll(mapAccUserIdToListOfRewards.get(rbi.Account__c));
                }
            }  
        }
        
        if (failedUserProfiles.size() > 0) {
            
            for (User_Profile__c up : failedUserProfiles) {
                
                if (mapAccUserIdToListOfRewards.containsKey(up.User__c)) {
                    updatedRewards.addAll(mapAccUserIdToListOfRewards.get(up.User__c));
                }
            }  
        }
        
        if (updatedRewards.size() > 0) {
            
            for (Reward__c rewardInstance : updatedRewards) {
                rewardInstance.Expired__c = false;
            }
            WithoutSharingHelperController.updateRewards(updatedRewards);
        }
        
        if (updatedRBIs.size() > 0) {
            WithoutSharingHelperController.updateRBI(updatedRBIs);
        }
        
        if (updatedUserProfiles.size() > 0) {
            WithoutSharingHelperController.updateSalesUserProfiles(updatedUserProfiles);
        }
    }
}