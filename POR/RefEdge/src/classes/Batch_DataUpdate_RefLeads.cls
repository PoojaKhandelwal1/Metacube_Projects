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
 * Description: One time batch called from the setup page.
 *				Updates existing Reference Lead records to set the "Created by Reference Lead Finder" to checked.
 * author: Gaaurav Saini (22 Nov, 2017)
 */
global with sharing class Batch_DataUpdate_RefLeads implements Database.Batchable<sObject>, Database.stateful {
    
    private String soqlQuery = '';
    
    global Batch_DataUpdate_RefLeads() {
        soqlQuery = 'SELECT Id, Ref_Lead_From_Opportunity__c '
        			+ 'FROM Reference_Lead__c WHERE Reference_Lead_Opportunity__c != null';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Reference_Lead__c> scope) {
        List<Reference_Lead__c> refLeadsToUpdate = new List<Reference_Lead__c>();
        
        for (Reference_Lead__c refLead : scope) {
            refLead.Ref_Lead_From_Opportunity__c = true;
            refLeadsToUpdate.add(refLead);
        }
        
        if (refLeadsToUpdate.size() > 0) {
            update refLeadsToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
}