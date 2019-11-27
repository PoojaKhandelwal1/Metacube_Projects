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
public with sharing class ContentContactTriggerHandler {
	/**
     * Properties and variables
     */
    public static list < Contact_Reference_Content__c > newContRefContents;
	/**
     * Method called on before insert of Contact Reference Content
     */
    public static void onBeforeInsert() {
        map < String, decimal > contactContentCountMap = new Map < String, Decimal > ();
        for (Contact_Reference_Content__c tempObj: [select Contact__c, Reference_Content__c from Contact_Reference_Content__c LIMIT: limits.getLimitQueryRows()]) {
            contactContentCountMap.put(tempObj.Contact__c + '' + tempObj.Reference_Content__c, 0);
        }
        for (Contact_Reference_Content__c tempObj: newContRefContents) {
            if (ContactContentCountMap.containsKey(tempObj.Contact__c + '' + tempObj.Reference_Content__c)) {
                tempObj.addError(System.Label.Junction_already_exists);
            }
        }
    }
	/**
     * Method called on after undelete of Contact Reference Content
     */
    public static void onAfterUndelete() {
        map < String, decimal > ContactContentCountMap = new Map < String, Decimal > ();
        for (Contact_Reference_Content__c tempObj: [select Contact__c, Reference_Content__c from Contact_Reference_Content__c where Id not In: newContRefContents]) {
            ContactContentCountMap.put(tempObj.Contact__c + '' + tempObj.Reference_Content__c, 0);
        }
        for (Contact_Reference_Content__c tempObj: newContRefContents) {
            if (ContactContentCountMap.containsKey(tempObj.Contact__c + '' + tempObj.Reference_Content__c)) {
                tempObj.addError(System.Label.Junction_already_exists);
            }
        }
    }
}