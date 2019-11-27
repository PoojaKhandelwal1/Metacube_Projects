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
 * Class: RefedgeSetupHomeController
 * Description : This Batch called from RefedgeSetupHomeController to delete Rewards which Account Requests are declined 
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_deleteRewardDeclinedRequest extends RefEdgeEditionFeatures implements Database.Batchable<sObject>, Database.stateful {
    /**
     * Properties and variables
     */
    private String soqlQuery = 'SELECT Amount__c, Account__c, Available_Points__c, Expired_Points__c, Expiration_Date__c, Expired__c, Transaction__c ' 
    							+ 'FROM Reward__c WHERE Account_Request__r.Approval_Status__c = \'Declined\'';
    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(soqlQuery);
    }

    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List<Reward__c> scope) {
    	
        if (!isBasic) {
            List<Reward__c> rewards = new List<Reward__c>();
            
            for (Reward__c reward : scope) {
            	
                if (reward.Amount__c == reward.Available_Points__c) {
                    rewards.add(reward);
                }
            }
            
            if (rewards.size() > 0) {
                WithoutSharingHelperController.deleteRewards(rewards);
            }
        }
    }

    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {}
}