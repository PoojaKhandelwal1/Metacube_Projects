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
public with sharing class NominationRefTriggerHandler {
	/**
     * Properties and variables
     */
    public static list < Nomination_Referenceability__c > newNominationReferenceability;
    public static list < Nomination_Referenceability__c > oldNominationReferenceability;
    public static map < Id, Nomination_Referenceability__c > newNominationReferenceabilityMap;
    public static map < Id, Nomination_Referenceability__c > oldNominationReferenceabilityMap;

    /**
     * Method called on after insert of NominationReferenceability
     */
    public static void onAfterInsert() {
        set<string> setNomination = new set<string>();
        for(Nomination_Referenceability__c nr : newNominationReferenceability){
        	setNomination.add(nr.Nomination__c);
        }
        
        updateNominations(setNomination);
    }

    /**
     * Method called on after delete of NominationReferenceability
     */
    public static void onAfterDelete() {
        set<string> setNomination = new set<string>();
        for(Nomination_Referenceability__c nr : oldNominationReferenceability){
        	setNomination.add(nr.Nomination__c);
        }
        
        updateNominations(setNomination);
    }

    /**
     * Method called on after undelete of NominationReferenceability
     */
    public static void onAfterUndelete() {
        set<string> setNomination = new set<string>();
        for(Nomination_Referenceability__c nr : newNominationReferenceability){
        	setNomination.add(nr.Nomination__c);
        }
        
        updateNominations(setNomination);
    }
    
    /**
     * Method to update nomination list
     */
    static void updateNominations(set<string> setNomination) {
    	list<Nomination__c> listNomination = new list<Nomination__c>();
        for(Nomination__c nom : [select (Select Referenceability_Type__r.Name From Nomination_Referenceabilities__r order by Referenceability_Type__r.Name), Referenceability__c from Nomination__c  where Id IN : setNomination]){
        	string refName = '';
        	for(Nomination_Referenceability__c nr : nom.Nomination_Referenceabilities__r){
            	refName += (refName == '' ? nr.Referenceability_Type__r.Name : ', '+ nr.Referenceability_Type__r.Name);
        	}
        	nom.Referenceability__c = refName;
        	listNomination.add(nom);
        }
        
        //Update list of nomination
        if(listNomination.size() > 0)
        	update listNomination;
    }
}