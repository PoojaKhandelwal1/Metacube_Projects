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
 * Class : RefedgeSetupHomeController
 * Description : This Batch called from RefedgeSetupHomeController to update Account Name in inherited Contact Attributes after shared contact concept
 * Modified by : Rekha Jangir @Nov/18/2016
 */
global with sharing class Batch_UpdateAccountNameConAtt implements Database.Batchable <sObject> , Database.stateful {
    /**
     * Properties and variables
     */
    private String soqlQuery = 'SELECT Contact__c, Contact__r.AccountId FROM Contact_Attribute__c WHERE From_Account__c = true AND Account__c = null';
    private List<String> listOfFailedRecords = new List<String>();
    /**
     * Constructor
     */
    global Batch_UpdateAccountNameConAtt() {}
    
    /**
	 * Method to get the data to be proceesed   
	 */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(soqlQuery);
    }

    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List <Contact_Attribute__c> scope) {
        List<Contact_Attribute__c> updateContactAtt = new List<Contact_Attribute__c>();
        
        for (Contact_Attribute__c conAtt : scope) {
            conAtt.Account__c = conAtt.Contact__r.AccountId;
            updateContactAtt.add(conAtt);
        }
        
        //Contact Attribute Creation
        if (updateContactAtt.size() > 0) {
            Database.SaveResult[] contactAttribute = database.update(updateContactAtt, false);
            
            for (database.Saveresult sr : contactAttribute) {
            	
                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    listOfFailedRecords.add('Contact Attribute Update Error : ' + err.getMessage());
                }
            }
        }
    }

    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {
        //Send Error Email to Refedge Team
        UtilityController.sendEmailNotification(listOfFailedRecords, 'Update Account Name in Contact Attribute Batch');
    }
}