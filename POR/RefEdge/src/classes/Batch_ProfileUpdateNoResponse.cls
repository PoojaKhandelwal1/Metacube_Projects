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
 * Class: Schedular_ProfileUpdateNoResponse, RefedgeSetupHomeController
 * Description : This Batch called FROM Schedular_ProfileUpdateNoResponse and RefedgeSetupHomeController to update Profile updates to set No response in status
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_ProfileUpdateNoResponse implements Database.Batchable<sObject>, Database.stateful {
    /**
     * Properties and variables
     */
    private String soqlQuery = '';
    private Date todayDate;
    private Date todayEndDate;
    private Custom_Settings__c cs;

    /**
     * Constructor
     */
    global Batch_ProfileUpdateNoResponse() {
        cs = UtilityController.getCustomSettings();
        
        if ((cs.PUM_No_Response_Days__c != null && cs.PUM_No_Response_Days__c > 0) || Test.isRunningTest()) {
            
            if (Test.isRunningTest()) {
                todayDate = Date.Today();
            } else {
                todayDate = Date.Today().addDays(-Integer.valueof(cs.PUM_No_Response_Days__c));
            }
            todayEndDate = todayDate.addDays(1);
            soqlQuery = 'SELECT Id,Reference_Refresh_Status__c FROM Reference_Refresh__c WHERE CreatedDate >= :todayDate ' 
                			+ ' AND CreatedDate < :todayEndDate AND Reference_Refresh_Status__c = \'Request Sent\' ';
        } else {
            todayDate = Date.Today().addDays(2);
            soqlQuery = 'SELECT Id,Reference_Refresh_Status__c FROM Reference_Refresh__c WHERE CreatedDate = :todayDate';
        }
    }
    
    /**
     * Constructor 2
     */
    global Batch_ProfileUpdateNoResponse(boolean isAllset) {
        cs = UtilityController.getCustomSettings();
        
        if ((cs.PUM_No_Response_Days__c != null && cs.PUM_No_Response_Days__c > 0) || Test.isRunningTest()) {
            todayDate = Date.Today().addDays(-Integer.valueof(cs.PUM_No_Response_Days__c));
            todayEndDate = todayDate.addDays(1);
            soqlQuery = 'SELECT Id,Reference_Refresh_Status__c FROM Reference_Refresh__c WHERE CreatedDate < :todayEndDate AND ' 
                		+ ' Reference_Refresh_Status__c = \'Request Sent\' ';
        } else {
            todayDate = Date.Today().addDays(2);
            soqlQuery = 'SELECT Id,Reference_Refresh_Status__c FROM Reference_Refresh__c WHERE CreatedDate = :todayDate';
        }
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
    global void execute(Database.BatchableContext BC, List<Reference_Refresh__c> scope) {
        List<Reference_Refresh__c> refRefreshList = new List<Reference_Refresh__c>();
        
        for (Reference_Refresh__c refRefresh : scope) {
            refRefresh.Reference_Refresh_Status__c = 'No Response';
            refRefreshList.add(refRefresh);
        }
        
        if (refRefreshList.size() > 0) {
            update refRefreshList;
        }
    }

    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {}
}