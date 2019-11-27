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
 * Class: CustomSettingTriggerHandler
 * Description : This Batch called from CustomSettingTriggerHandler when "Consider “No longer needed” a use?" 
 * field is updated to include/exclude No longer needed account request
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_ChangeAllNoLongerNeededAR implements Database.Batchable < sObject > , Database.stateful {
    /**
     * Properties and variables
     */
    private String soqlQuery = 'SELECT Id, Activity_Date__c, LastModifiedDate FROM Reference_Request_Account__c where Account_Request_Status__c = \'No Longer Needed\'';
    private Boolean considerNoLongerNeededUse;
    
    /**
     * Constructor
     */
    global Batch_ChangeAllNoLongerNeededAR(Boolean considerNoLongerNeededUse) {
        this.considerNoLongerNeededUse = considerNoLongerNeededUse;
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
    global void execute(Database.BatchableContext BC, List < Reference_Request_Account__c > scope) {
        list < Reference_Request_Account__c > accReqList = new list < Reference_Request_Account__c > ();
        
        if (!considerNoLongerNeededUse) {
        	
            for (Reference_Request_Account__c a: scope) {
                a.Activity_Date__c = null;
                accReqList.add(a);
            }
        } else {
        	
            for (Reference_Request_Account__c a: scope) {
                a.Activity_Date__c = a.LastModifiedDate.date();
                accReqList.add(a);
            }
        }
        
        if (accReqList.size() > 0)
            update accReqList;
    }

    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {}
}