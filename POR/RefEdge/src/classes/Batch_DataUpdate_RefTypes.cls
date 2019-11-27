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
 * Description : This Batch called from RefedgeSetupHomeController to update Referenceability no in all Ref Types
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_DataUpdate_RefTypes implements Database.Batchable<sObject>, Database.stateful {
    /**
     * Properties and variables
     */
    private String soqlQuery = '';
    private Integer refCount;
    /**
     * Constructor
     */
    global Batch_DataUpdate_RefTypes() {
        refCount = 01;
        soqlQuery =
            'SELECT Id, Referenceability_no__c, CreatedDate, Referenceability_Type__c, Request_type__c, Project_type__c, Sales_Reward__c ' 
            			+ ' FROM Referenceability_Type__c ORDER BY CreatedDate';
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
    global void execute(Database.BatchableContext BC, List<Referenceability_Type__c> scope) {
        List<Referenceability_Type__c> updateRef = new List<Referenceability_Type__c>();
        
        for (Referenceability_Type__c ref : scope) {
            ref.Referenceability_no__c = refCount;
            
            if (!ref.Sales_Reward__c) {
	            ref.Referenceability_Type__c = true;
	            ref.Request_type__c = true;
	            ref.Project_type__c = true;
            }
            updateRef.add(ref);
            refCount++;
        }
        
        if (updateRef.size() > 0) {
            update updateRef;
        }
    }
    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {}
}