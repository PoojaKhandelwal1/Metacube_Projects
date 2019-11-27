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
public with sharing class RefContentTypeTriggerHandler {
    /**
     * Properties and variables
     */
    public static list < Reference_Content_Type__c > newRefContType = new list < Reference_Content_Type__c > ();
    public static list < Reference_Content_Type__c > oldRefContType = new list < Reference_Content_Type__c > ();
    public static map < Id, Reference_Content_Type__c > newRefContTypeMap = new map < Id, Reference_Content_Type__c > ();
    public static map < Id, Reference_Content_Type__c > oldRefContTypeMap = new map < Id, Reference_Content_Type__c > ();
    /**
     * Method called on before delete of Reference Content Type
     */
    public static void onBeforeDelete() {

        for(Reference_Content_Type__c rct : oldRefContType) {

            if(rct.Name__c == ConstantsController.REFERENCE_CONTENT_TYPE) {
                rct.addError(System.label.DC_Reference_Content_Type);
                break;
            }   
        }

        for (Reference_Content_Type__c rct: [select Id, (Select Id from Reference_Content__r) from Reference_Content_Type__c where Id In: oldRefContType]) {
            for (Reference_Content__c rc: rct.Reference_Content__r) {
                oldRefContTypeMap.get(rct.Id).addError(System.Label.CANNOT_DELETE_CONTENT_TYPE);
                break;
            }
        }
    }

    // onAfterInsert    REF-1308
    public static void onBeforeInsert() {
        List<Reference_Content_Type__c> rcTypeList = New List<Reference_Content_Type__c>([SELECT Id, Name__c FROM Reference_Content_Type__c WHERE Name__c =: ConstantsController.REFERENCE_CONTENT_TYPE]);
        
        if(rcTypeList.size() > 0) {

            for(Reference_Content_Type__c rct : newRefContType) {

                if(rct.Name__c == ConstantsController.REFERENCE_CONTENT_TYPE) {
                    rct.addError(System.label.DC_Reference_Content_Type);
                    break;
                }   
            }
        }
        
    }

    // onAfterUpdate    REF-1308
    public static void onBeforeUpdate() {
        List<Reference_Content_Type__c> rcTypeList = New List<Reference_Content_Type__c>([SELECT Id, Name__c FROM Reference_Content_Type__c WHERE Name__c =: ConstantsController.REFERENCE_CONTENT_TYPE]);
        
        for(Reference_Content_Type__c rct : newRefContType) {

            if((rct.Name__c == ConstantsController.REFERENCE_CONTENT_TYPE || oldRefContTypeMap.get(rct.Id).Name__c == ConstantsController.REFERENCE_CONTENT_TYPE) && oldRefContTypeMap.get(rct.Id).Name__c != rct.Name__c) {
                rct.addError(System.label.DC_Reference_Content_Type);
                break;
            }   
        }
    }

}