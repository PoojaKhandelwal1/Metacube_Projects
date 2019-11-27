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
 * Class: RefedgeSetupHomeController
 * Description: This Batch called from RefedgeSetupHomeController to update all existing contact RBI which earlier doesn't have 
 *				CurrentAvailablePoints and LifetimePoints.
 * @Author Narender Singh
 * Modified by: Rekha Jangir @Nov/18/2016
 */
global with sharing class Batch_ResetContactRewardPoints extends RefEdgeEditionFeatures implements Database.Batchable<sObject>, Database.stateful {
    
    /**
     * Properties and variables
     */
    private Map<Id, Decimal> contactLifeTimePoints;
    private Map<Id, Decimal> contactAvailablePoints;
    private Map<Id, Reference_Basic_Information__c> rbiMap;
    private List<String> listOfFailedRecords = new List<String>();
    private String soqlQuery = 'SELECT Id FROM Contact';
    
    global Batch_ResetContactRewardPoints() {}
    
    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        contactLifeTimePoints = new Map<Id, Decimal>();
        contactAvailablePoints = new Map<Id, Decimal>();
        rbiMap = new Map<Id, Reference_Basic_Information__c>();
        Set<String> setContact = new Set<String>();
        
        // Setting redeem rewards' Available_Points__c = null which were created as part of influitive integration 
        List<Reward__c> rewards = WithoutSharingHelperController.getRedeemedRewardsForResetContactPointsBatch();
        
        for (Reward__c reward : rewards) {
            reward.Available_Points__c = null;
        }
        update rewards;
        
        // Mapping RBI with contact and creating contactId set
        for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getRBIsForResetContactPointsBatch()) {
            rbiMap.put(rbi.Contact__c, rbi);
            setContact.add(rbi.Contact__c);
        }
        
        // Mapping Points with Contact
        for (Reward__c reward : WithoutSharingHelperController.getRewardsForResetContactPointsBatch()) {
        	
            // Mapping Contact LifeTime Points 
            if (!contactLifeTimePoints.containsKey(reward.Contact__c)) {
                contactLifeTimePoints.put(reward.Contact__c, 0);
            }
            Decimal points = contactLifeTimePoints.get(reward.Contact__c);
            
            if (reward.Amount__c != null && reward.Transaction__c == ConstantsController.ISSUE) {
                points += reward.Amount__c;
            }
            contactLifeTimePoints.put(reward.Contact__c, points);

            // Mapping Current Available Points 
            if (!contactAvailablePoints.containsKey(reward.Contact__c)) {
                contactAvailablePoints.put(reward.Contact__c, 0);
            }
            Decimal aPoints = contactAvailablePoints.get(reward.Contact__c);
            
            if (reward.Available_Points__c != null) {
                aPoints += reward.Available_Points__c;
            }
            contactAvailablePoints.put(reward.Contact__c, aPoints);
        }
        
        if (!setContact.isEmpty()) {
            soqlQuery = soqlQuery + ' WHERE Id IN :setContact';
        }
        return Database.getQueryLocator(soqlQuery);
    }
    
    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Reference_Basic_Information__c> RBIs = new List<Reference_Basic_Information__c>();
        
        // Adding Lifetime_Points__c and Current_Available_Balance_Points__c to RBI
        for (Contact contact : scope) {
            Reference_Basic_Information__c updatedRBI = rbiMap.get(contact.id);
            updatedRBI.Lifetime_Points__c = contactLifeTimePoints.get(contact.id);
            updatedRBI.Current_Available_Balance_Points__c = contactAvailablePoints.get(contact.id);
            RBIs.add(updatedRBI);
        }
        
        // Update RBI
        if (RBIs != null && !RBIs.isEmpty()) {
            Database.SaveResult[] updateRBI = database.update(RBIs, false);
            
            for (database.Saveresult sr : updateRBI) {
                
                if (!sr.isSuccess()) {
                    listOfFailedRecords.add('Batch_ResetContactRewardPoints RBI update Error : '
                    							+ sr.getErrors()[0].getMessage());
                }
            }
        }
    }
    
    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {
        //Send Error Email to Refedge Team
        UtilityController.sendEmailNotification(listOfFailedRecords, 'Batch_ResetContactRewardPoints Batch');
    }
}