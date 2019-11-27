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
 * Page : ReferenceabilityType
 * Description : Trigger handler for ReferenceabilityType
 * Modified by: Rekha @March 3 2017 regarding #740
 * Last Modified by : Rajesh @Oct 31 2017 regarding #1077
 */
public with sharing class ReferenceabilityTypeTriggerHandler {
    /**
     * Properties and variables
     */
    public static List<Referenceability_Type__c> newReferenciablities;
    public static List<Referenceability_Type__c> oldReferenciablities;
    public static Map<Id, Referenceability_Type__c> newReferenciablityMap;
    public static Map<Id, Referenceability_Type__c> oldReferenciablityMap;

    /**
     * Method called on before insert of Referenceability Type
     */
    public static void onBeforeInsert() { 
        List<Referenceability_Type__c> refTypes = [SELECT Name, Referenceability_no__c, Referenceability_code__c FROM Referenceability_Type__c 
        											WHERE Referenceability_no__c != NULL ORDER BY Referenceability_no__c DESC];
        Integer countNew;
        Set<String> refCodeSet = new Set<String>();
        Set<String> refNameSet = new Set<String>();
     	
     	countNew = (refTypes.size() > 0) ? ((refTypes[0].Referenceability_no__c != null) ? Integer.valueOf(refTypes[0].Referenceability_no__c) + 1 : 1) : 1; 
        
        // re #647 Creating set for Referenceability Type  
        for (Referenceability_Type__c reftype : refTypes) {
        	
        	if (reftype.Referenceability_code__c != null) {
            	refCodeSet.add(reftype.Referenceability_code__c);
        	}        	
        	refNameSet.add(reftype.Name);
        } 
            
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        
        for (Referenceability_Type__c ref : newReferenciablities) {
            ref.Referenceability_no__c = countNew;
            
            if (ref.min_lead_time_per_request_type__c < cs.Minimum_Deadline__c) {
                ref.addError(System.Label.LEAD_TIME_OF_REFERENCEABILITY);
            }
            countNew++;
                        
            //re #647-Check for Referenceability code is already Exist exist or not. 
            if (refNameSet.contains(ref.Name)) {
            	ref.addError(System.Label.Referenceability_Exist); 
            } else 
            
            if (refCodeSet.contains(ref.Referenceability_code__c)) {
            	ref.addError(System.Label.Referenceability_Code_Exists); 
            }  
            	  
            if (ref.Sales_Reward__c) {  
            	ref.Project_type__c = false;
            	ref.Referenceability_Type__c = false;
            	ref.Request_type__c = false;
            }
        }
    }

    /**
     * Method called on before update of Referenceability Type
     */
    public static void onBeforeUpdate() {  
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Set<String> refNameSet = new Set<String>(); 
        List<Referenceability_Type__c> refTypes = getExistingRefType();
        
        // re #647 Creating set for Referenceability Type  
        for (Referenceability_Type__c reftype : refTypes) { 
            refNameSet.add(reftype.Name);
        } 
        
        for (Referenceability_Type__c ref : newReferenciablities) {
        	        	
            if (ref.min_lead_time_per_request_type__c < cs.Minimum_Deadline__c) {
                ref.addError(System.Label.LEAD_TIME_OF_REFERENCEABILITY);
            }
             
            //re #647-Check for Referenceability code is already Exist exist or not. 
            if (oldReferenciablityMap.get(ref.Id).Name != ref.Name && refNameSet.contains(ref.Name)) {
            	ref.addError(System.Label.Referenceability_Exist); 
            } 
            
            //re #1203-User able to update Referenceability code if User Reward is Unchecked on Referenceability type
            if (oldReferenciablityMap.get(ref.Id).Referenceability_code__c != newReferenciablityMap.get(ref.Id).Referenceability_code__c 
            							&& oldReferenciablityMap.get(ref.Id).Sales_Reward__c == true) {
            	ref.addError(System.Label.Referenceability_Code_validation);
            } 
            
            // re #694: Issue: Sales Rewards Referenceability should not visible on Refsearch page
            if (ref.Sales_Reward__c != oldReferenciablityMap.get(ref.Id).Sales_Reward__c) {
            	ref.addError(System.Label.Reward_Not_Changed);
            }
            
            if (ref.Sales_Reward__c) {  
            	ref.Project_type__c = false;
            	ref.Referenceability_Type__c = false;
            	ref.Request_type__c = false;
            } 
        }
    }

    /**
     * Method called on before delete of Referenceability Type
     */
    public static void onBeforeDelete() {
        Set<String> setRefTyprId = new Set<String>(); 
                
        for (Referenceability_Type__c rt: oldReferenciablities) {
            setRefTyprId.add(rt.id);
        }
       
        if (setRefTyprId.size() > 0) {
            Map<Id, Referenceability_Type__c> mapRefType = new Map<Id, Referenceability_Type__c> ([SELECT Id, Name,Sales_Reward__c, 
            											(SELECT Referenceability_Type__c FROM Referenceabilities__r), 
            											(SELECT Reference_Type_Needed__c FROM Reference_Request_Accounts__r), 
            											(SELECT Referenceability_Type__c FROM Contact_Requests__r),
            											(SELECT Id FROM Rewards__r) FROM Referenceability_Type__c 
            											WHERE Id IN: setRefTyprId LIMIT: limits.getLimitQueryRows()]);
            
            for (String refId: oldReferenciablityMap.KeySet()) {
              	// re #287
              	if (mapRefType.get(refId).Sales_Reward__c) {
              		oldReferenciablityMap.get(refId).addError('User points Referenceability Types/User Activities cannot be deleted.');
            	} else if (mapRefType.get(refId).Rewards__r.size() > 0 || mapRefType.get(refId).Referenceabilities__r.size() > 0 
            				|| mapRefType.get(refId).Reference_Request_Accounts__r.size() > 0 || mapRefType.get(refId).Contact_Requests__r.size() > 0) {
                    oldReferenciablityMap.get(refId).addError(System.Label.RefTypeDelete_Msg);
                }
            }
        }
    }
    /**
     * Method called on after update of Referenceability Type
     */
    public static void onAfterUpdate() {
        Set<Id> nameChangeRef = new Set<Id>();
        Map<Id, String> oldRefNameMap = new Map<Id, String>(); 
        Map<Id, String> newRefNameMap = new Map<Id, String>();
        
        for (Referenceability_Type__c ref: newReferenciablities) {
           	oldRefNameMap.put(ref.Id, oldReferenciablityMap.get(ref.Id).Name);
           	newRefNameMap.put(ref.Id, ref.Name);
           	
            if (oldReferenciablityMap.get(ref.Id).Name != newReferenciablityMap.get(ref.Id).Name) {
                nameChangeRef.add(ref.Id);
            }
        }
        
        //changes regarding #740
        if (nameChangeRef.size() > 0 && !(Test.isRunningTest() || System.isBatch() || System.isFuture())) {
            changeNamesInReferenceProfiles(nameChangeRef, oldRefNameMap, newRefNameMap);
            changeNamesInNominations(nameChangeRef, oldRefNameMap, newRefNameMap);
        }
    }
    /**
     * Method to change Name in Nominations
     * Modified By: Rekha @March 3 2017 regarding #740
     */
    @future
    private static void changeNamesInNominations(Set<Id> nameChangeRef, Map<Id, String> oldMap, Map<Id, String> newMap) {
    	//Purpose:  Update Nomination__c when Referenceability_Type__r.Name updated 
        //Date   :  07/09/2015  
        Set<String> setNomination = new Set<String>();
        
        for (Nomination_Referenceability__c nr : [SELECT Nomination__c FROM Nomination_Referenceability__c WHERE Referenceability_Type__c IN : nameChangeRef]) {
            setNomination.add(nr.Nomination__c);
        }
        
        List<Nomination__c> listNomination = new List<Nomination__c>();
        
        for (Nomination__c nom : [SELECT (SELECT Referenceability_Type__r.Name FROM Nomination_Referenceabilities__r ORDER BY Referenceability_Type__r.Name), 
        								Referenceability__c FROM Nomination__c  WHERE Id IN : setNomination]) {
            String refName = '';
            
            for (Nomination_Referenceability__c nr : nom.Nomination_Referenceabilities__r) {
                refName += (refName == '' ? nr.Referenceability_Type__r.Name : ', '+ nr.Referenceability_Type__r.Name);
            }
            nom.Referenceability__c = refName;
            listNomination.add(nom);
        }
        
        //Update list of nomination
        if (listNomination.size() > 0) {
            update listNomination;
        }
    }
    /**
     * Method to change Name in Account/Contacts
     * Modified By: Rekha @March 3 2017 regarding #740
     */
    @future
    private static void changeNamesInReferenceProfiles(Set<Id> nameChangeRef, Map<Id, String> oldMap, Map<Id, String> newMap) {
        Set<Id> accIds = new Set<Id>();
        Set<Id> cntctIds = new Set<Id>();
        List<Reference_Basic_Information__c> updateRBIs = new List<Reference_Basic_Information__c>(); 
        String referenceability;
       
        for (Referenceability__c ref : [SELECT Account__c, Contact__c FROM Referenceability__c WHERE Referenceability_Type__c IN : nameChangeRef 
        									AND Status__c = : ConstantsController.APPROVED]) {
           
            if (ref.Contact__c == null && ref.Account__c != null) {
                accIds.add(ref.Account__c);
            }
            
            if (ref.Contact__c != null) {
                cntctIds.add(ref.Contact__c);
            }
        }
        
        if (accIds.size() > 0) {
           
            for (Reference_Basic_Information__c acc : [SELECT Referenceability__c FROM Reference_Basic_Information__c WHERE Contact__c = null 
            											AND Account__c IN : accIds]) {
                referenceability = '';
                
                if (acc.Referenceability__c != null) {
	                
	                for (String refName : acc.Referenceability__c.split(',')) {
	                    
	                    for (Id refId : nameChangeRef) {
	                       
	                        if (refName.trim() == oldMap.get(refId)) {
	                            referenceability += (referenceability == '') ? newMap.get(refId) : ', ' + newMap.get(refId);	                             
	                        } else {
	                           	referenceability += (referenceability == '') ? refName : ', ' + refName; 
	                        }
	                    }
	                }
                }
                
                if (referenceability != '') {
                    acc.Referenceability__c = referenceability;
                    updateRBIs.add(acc);
                }
            }
        }
        
        if (cntctIds.size() > 0) {
            
            for (Reference_Basic_Information__c c: [SELECT Referenceability__c FROM Reference_Basic_Information__c WHERE Contact__c != null 
            											AND Contact__c IN: cntctIds]) {
                referenceability = '';
               
                if (c.Referenceability__c != null) {
	                
	                for (String refName : c.Referenceability__c.split(',')) {
	                    
	                    for (Id refId : nameChangeRef) {
	                       
	                        if (refName.trim() == oldMap.get(refId)) {
	                           	referenceability += (referenceability == '') ? newMap.get(refId) : ', ' + newMap.get(refId);	                             
	                        } else {
	                        	 referenceability += (referenceability == '') ? refName.trim() : ', ' + refName.trim(); 
	                        }
	                    }
	                }
                }
                
                if (referenceability != '') {
                    c.Referenceability__c = referenceability;
                    updateRBIs.add(c);
                }
            }
        }
        
        if (updateRBIs.size() > 0) {
            WithoutSharingHelperController.upsertRBI(updateRBIs);
        }
    }
    
    /**
     * Method used to check duplicate referenceability Names
     * Modified By: Rajesh @March 23 2017 
     */
     private static List<Referenceability_Type__c> getExistingRefType() {
    	Set<String> refNameSet = new Set<String>();
    	 // re #647 Creating set for Referenceability Type  
        for (Referenceability_Type__c ref : newReferenciablities) { 
            refNameSet.add(ref.Name);
        } 
    	List<Referenceability_Type__c> refTypes = [SELECT Name, Referenceability_code__c FROM Referenceability_Type__c WHERE Name IN : refNameSet
        											ORDER BY Referenceability_code__c DESC]; 
        
        return refTypes;
    }
}