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
public with sharing class RelatedReferenceContentTriggerHandler {
    /**
     * Method called on before insert of Related Reference Content
     */
    public static void onBeforeInsert(list<Related_Reference_Content__c> newRefContents) {
        set<string> conCollections = new set<string>();
        for (Related_Reference_Content__c tempObj: newRefContents) {
            conCollections.add(tempObj.Content_Collection__c);
        }
        map < String, set<string> > collectionContentCountMap = new Map < String, set<string> > ();
        for (Related_Reference_Content__c tempObj: [select Content_Collection__c, Reference_Content__c from Related_Reference_Content__c where Content_Collection__c IN : conCollections LIMIT: limits.getLimitQueryRows()]) {
            if(!collectionContentCountMap.containsKey(tempObj.Content_Collection__c))
                collectionContentCountMap.put(tempObj.Content_Collection__c, new set<string>());
            collectionContentCountMap.get(tempObj.Content_Collection__c).add(tempObj.Reference_Content__c);
        }
        for (Related_Reference_Content__c tempObj: newRefContents) {
            if (collectionContentCountMap != null && collectionContentCountMap.containsKey(tempObj.Content_Collection__c) && collectionContentCountMap.get(tempObj.Content_Collection__c).contains(tempObj.Reference_Content__c)) {
                tempObj.addError(System.Label.Preventing_duplicates_in_Content_Collections);
            }
        }
    }
    
}