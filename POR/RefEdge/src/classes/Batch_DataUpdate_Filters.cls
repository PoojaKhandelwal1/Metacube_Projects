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
 * Description : This Batch called from RefedgeSetupHomeController to set Filter no in all Filetrs
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_DataUpdate_Filters implements Database.Batchable<sObject>, Database.stateful {
    /**
     * Properties and variables
     */
    private String soqlQuery = '';
    private Integer filterCount;
    /**
     * Constructor
     */
    global Batch_DataUpdate_Filters() {
        filterCount = 01;
        soqlQuery = 'SELECT Id, Filter_no__c, CreatedDate  FROM Label__c ORDER BY CreatedDate';
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
    global void execute(Database.BatchableContext BC, List<Label__c> scope) {
        List<Label__c> updatefilters = new List<Label__c>();
        
        for (Label__c filter : scope) {
            filter.Filter_no__c = filterCount;
            updatefilters.add(filter);
            filterCount++;
        }
        
        if (updatefilters.size() > 0) {
            update updatefilters;
        }
    }
    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {}
}