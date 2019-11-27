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
 * Description : This Batch called FROM RefedgeSetupHomeController to update all Reference Content (associated account names, Content Type, Content Id)
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_DataUpdate_RefContent implements Database.Batchable<sObject>, Database.stateful {
    /**
     * Properties and variables
     */
    private String soqlQuery = '';
    /**
     * Constructor
     */
    global Batch_DataUpdate_RefContent() {
        soqlQuery = 'SELECT Id, Content_ID__c, Reference_Content_Type_Name__c,Reference_Content_Type__r.Name__c, ' 
        				+ '(SELECT Id FROM Content_Attributes__r), '
            			+ '(SELECT Account__r.Name FROM Account_Reference_Contents__r order by Account__r.Name) FROM Reference_Content__c ';
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
    global void execute(Database.BatchableContext BC, List<Reference_Content__c > scope) {
        List<Reference_Content__c> updateList = new List<Reference_Content__c>();
        //Scope for replace content id in refrence content
        Map<String, String> mapContentVersion = new Map<String, String>();
        
        for (Reference_Content__c rc : scope) {
        	
            if (rc.Content_ID__c != null) {
                mapContentVersion.put(rc.Content_ID__c, '');
            }
        }

        for (ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :mapContentVersion.keySet()]) {
            mapContentVersion.put(cv.id, cv.ContentDocumentId);
        }
		Map<String, String> mapLatestContentVersion = new Map<String, String>();
            
        for (ContentVersion lcv : [SELECT Id, ContentDocumentId FROM ContentVersion 
        							WHERE ContentDocumentId IN :mapContentVersion.values() AND IsLatest = true]) {
            mapLatestContentVersion.put(lcv.ContentDocumentId, lcv.id);
        }

        //Iterate for Reference Content
        for (Reference_Content__c rc : scope) {
            //Update associate Account
            String associatedAccount = '';
            
            for (Account_Reference_Content__c aa : rc.Account_Reference_Contents__r) {
                associatedAccount += (associatedAccount == '' ? aa.Account__r.Name : ', ' + aa.Account__r.Name);
            }
            rc.Associated_Accounts__c = associatedAccount;
            //added regarding ticket #623
            rc.Attribute_Count__c = rc.Content_Attributes__r.size();

            //Update Content Type name
            if (rc.Reference_Content_Type_Name__c == null || rc.Reference_Content_Type_Name__c == '') {
                rc.Reference_Content_Type_Name__c = rc.Reference_Content_Type__r.Name__c;
            }

            //Update content id in refrence content 16/10/2015
            if (rc.Content_ID__c != null && mapContentVersion.containsKey(rc.Content_ID__c)) {
            	
                if (mapLatestContentVersion.containsKey(mapContentVersion.get(rc.Content_ID__c))) {
                    rc.Content_ID__c = mapLatestContentVersion.get(mapContentVersion.get(rc.Content_ID__c));
                }
            }
            updateList.add(rc);
        }

        //Update records
        if (updateList.size() > 0) {
            update updateList;
        }
    }
    /**
	 * Method to be called after the excute
	 */
    global void finish(Database.BatchableContext BC) {}
}