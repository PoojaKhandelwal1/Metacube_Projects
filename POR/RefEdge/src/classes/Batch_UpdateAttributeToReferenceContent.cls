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
* Description : This Batch called from 'RefedgeSetupHomeController' for Reference Content objects "Attributes"  and "Attribute Ids" field update update
* Modified by: Rajneesh Raj @Dec/07/2017
*/
global with sharing class Batch_UpdateAttributeToReferenceContent implements Database.Batchable<sObject>, Database.stateful {
	
	/**
     * Properties and variables
     */
    private String soqlQuery = '';
	
	/**
     * Constructor
     */
    global Batch_UpdateAttributeToReferenceContent() {
		soqlQuery = 'SELECT Id, Name, Attributes__c, Attribute_Ids__c, (SELECT Id, Name, Attribute__c, Attribute__r.Name '
					+ 'FROM Content_Attributes__r) FROM Reference_Content__c';
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
    global void execute(Database.BatchableContext BC, List<Reference_Content__c> scope) {
		// List of reference content which will be updated
		List<Reference_Content__c> updateList = new List<Reference_Content__c>();
		
		for (Reference_Content__c refCon : scope) {
			
			if (refCon.Content_Attributes__r.size() > 0) {
				String attributeNames = '';
				String attributeIds = '';
				Boolean checkVal = true;
				
				for (Content_Attribute__c conAtt : refCon.Content_Attributes__r) {
					
					if (!attributeIds.contains(conAtt.Attribute__c)) {
						
						if (checkVal) {
							attributeNames = conAtt.Attribute__r.Name;
							attributeIds = conAtt.Attribute__c;
							checkVal = false;
						} else {
							attributeNames += ',' + conAtt.Attribute__r.Name;
							attributeIds += ',' + conAtt.Attribute__c;
						}
					}
				}
				refCon.Attributes__c = attributeNames;
				refCon.Attribute_Ids__c = attributeIds;
				updateList.add(refCon);
			}
		}
		
		if (updateList.size() > 0) {
			update updateList;
		}
	}
	
	/**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {}
}