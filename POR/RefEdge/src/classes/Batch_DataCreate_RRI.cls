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
 * Description : This Batch called FROM RefedgeSetupHomeController to create Reference_Requests_and_Invitations__c records for opportunity
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_DataCreate_RRI implements Database.Batchable<sObject> {
    /**
     * Properties and variables
     */
    private String soqlQuery = '';

    /**
     * Constructor
     */
    global Batch_DataCreate_RRI() {
        soqlQuery = 'SELECT Id, (SELECT Reference_Request__c, Invitation__c FROM Reference_Requests_and_Invitations__r), ' 
        				+ '(SELECT Id, Opportunity__c FROM Reference_Requests__r WHERE Opportunity__c != null), ' 
        				+ '(SELECT Id, Opportunity__c FROM Invitations__r  WHERE Opportunity__c != null) FROM Opportunity ';
    }

    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(soqlQuery);
    }

    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        List<Reference_Requests_and_Invitations__c> listNewRRI = new List<Reference_Requests_and_Invitations__c>();
        Set<String> setRRandInvIds = new Set<String>();
        
        //Iterate Opportunity list 
        for (Opportunity opp : scope) {
        	
            for (Reference_Requests_and_Invitations__c rri : opp.Reference_Requests_and_Invitations__r) {
            	
                if (rri.Reference_Request__c != null) {
                    setRRandInvIds.add(rri.Reference_Request__c);
                }
                    
                if (rri.Invitation__c != null) {
                    setRRandInvIds.add(rri.Invitation__c);
                }
            }
            
            for (Reference_Request__c rr : opp.Reference_Requests__r) {
            	
                if (rr.Opportunity__c != null && !setRRandInvIds.contains(rr.Id)) {
                    listNewRRI.add(new Reference_Requests_and_Invitations__c(Opportunity__c = opp.Id, Reference_Request__c = rr.Id));
                }
            }
            
            for (Invitation__c inv : opp.Invitations__r) {
            	
                if (inv.Opportunity__c != null && !setRRandInvIds.contains(inv.Id)) {
                    listNewRRI.add(new Reference_Requests_and_Invitations__c(Opportunity__c = opp.Id, Invitation__c = inv.Id));
                }
            }
        }
        
        //Insert New RRI
        if (listNewRRI.size() > 0) {
            insert listNewRRI;
        }
    }

    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {}
}