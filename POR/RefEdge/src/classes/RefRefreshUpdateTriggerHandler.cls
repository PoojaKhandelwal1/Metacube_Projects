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
public with sharing class RefRefreshUpdateTriggerHandler {
    /**
     * Method called on after insert of Reference Refresh Update
     */
    public static void onAfterInsert(List<Reference_Refresh_Update__c> refRefreshUpdates) {
        List<Reference_Refresh__c > updateRefRefresh = new List<Reference_Refresh__c>();
        Set<String > parentRefreshIds = new Set<String>();
        
        for (Reference_Refresh_Update__c rru : refRefreshUpdates) {
            parentRefreshIds.add(rru.Reference_Refresh__c);
        }
        
        for (Reference_Refresh__c rr : WithoutSharingHelperController.getReferenceRefreshOnrefRefreshTrigger(parentRefreshIds)) {
            
            if (rr.Reference_Refresh_Updates__r.size() > 0 && rr.Reference_Refresh_Status__c != 'Profile Updated') {
                rr.Reference_Refresh_Status__c = 'Profile Updated';
                updateRefRefresh.add(rr);
            }
        }
        
        if (updateRefRefresh.size() > 0) {
            WithoutSharingHelperController.updateReferenceRefresh(updateRefRefresh);
        }
    }
    /**
     * Method called on before update of Reference Refresh Update
     */
    public static void onBeforeUpdate(Map<Id, Reference_Refresh_Update__c > newMap, Map<Id, Reference_Refresh_Update__c > oldMap) {
        
        for (Reference_Refresh_Update__c rru : newMap.values()) {
        	
            if ((oldMap.get(rru.Id).Accept_Reject__c != null && oldMap.get(rru.Id).Accept_Reject__c != '') 
            		&& (newMap.get(rru.Id).Accept_Reject__c != oldMap.get(rru.Id).Accept_Reject__c)) {
                rru.addError(System.Label.Profile_Update_Validation);
            }
        }
    }
    /**
     * Method called on after update of Reference Refresh Update
     */
    public static void onAfterUpdate(List<Reference_Refresh_Update__c> newList, List<Reference_Refresh_Update__c> oldList, 
    									Map<Id, Reference_Refresh_Update__c> newMap, Map<Id, Reference_Refresh_Update__c> oldMap) {
        List<Referenceability__c> referenceabilityInserted = new List<Referenceability__c>();
        List<Account_Attribute__c> accountAttributesInserted = new List<Account_Attribute__c>();
        List<Contact_Attribute__c> contactAttributesInserted = new List<Contact_Attribute__c>();
        List<Reference_Basic_Information__c> updateRBI = new List<Reference_Basic_Information__c>();
        Set<String> referenceabilityDeleted = new Set<String>();
        Set<String> accountAttributesDeleted = new Set<String>();
        Set<String> contactAttributesDeleted = new Set<String>();
        Map<String, String> contactAccountMap = new Map<String, String>();
        List<Sobject> fieldUpdated = new List<Sobject>();
        Set<Id> profileUpdateIds = new Set<Id>();
        List<Reference_Refresh__c> PUList = new List<Reference_Refresh__c>();
        Map<String, Reference_Basic_Information__c> contactRBIMap = new Map<String,Reference_Basic_Information__c>();
        
        for (Reference_Refresh_Update__c rru : newList) {
        	profileUpdateIds.add(rru.Reference_Refresh__c);
        	
            if (rru.Contact__c != null) {
                contactAccountMap.put(rru.contact__c, '');
            }
        }
        
        for (Contact con : WithoutSharingHelperController.getContactsInProfileUpdateTrigger(contactAccountMap.keySet())) {
            contactAccountMap.put(con.Id, con.AccountId);
            contactRBIMap.put(con.Id, (con.Reference_Basic_Informations__r.size() > 0 
            							? con.Reference_Basic_Informations__r[0] : new Reference_Basic_Information__c()));
        }
        
        for (Reference_Refresh__c ref : WithoutSharingHelperController.getProfileUpdatesinProfileUpdateTrigger(profileUpdateIds)) {
        	boolean isNochange = true;
        	boolean isCompleted = true;
        	
        	for (Reference_Refresh_Update__c rru : ref.Reference_Refresh_Updates__r) {
        		
        		if (!rru.No_Change__c) {
        			isNochange = false;
        		}
        			
    			if (!rru.No_Change__c && (rru.Accept_Reject__c ==  null || rru.Accept_Reject__c == '')) {
        			isCompleted = false;
    			}
        	}
        	
        	if (isNochange || isCompleted) {
        		ref.Reference_Refresh_Status__c = 'Profile Update Completed';
        		ref.Is_Active__c = false;
        		ref.Quarantined__c = false;
        		PUList.add(ref);
        	}
        }
        //shared contact code start
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        boolean addRefToAllAccounts = cs.Roll_up_Referenceability_to_All_Accounts__c;
        Map<String, Set<String>> sharedcontactAccountMap = new Map<String, Set<String>>();
        
        if (contactAccountMap != null && contactAccountMap.size() > 0 && cs.Shared_Contacts__c) {
            sharedcontactAccountMap = WithoutSharingHelperController.getRelatedAccounts(contactAccountMap.keySet(), cs);
        }
        //end
        
        for (Reference_Refresh_Update__c rru : newList) {
            
            if (rru.Accept_Reject__c == 'Accept' && oldMap.get(rru.Id).Accept_Reject__c != 'Accept') {
                
                if (rru.Referenceability__c) {
                    
                    if (rru.Added__c) {
                        Referenceability__c tempRef = new Referenceability__c();
                        
                        if (contactAccountMap != null && contactAccountMap.size() > 0 &&contactAccountMap.containsKey(rru.Contact__c)) {
                            tempRef.Account__c = contactAccountMap.get(rru.Contact__c);
                            tempRef.Contact__c = rru.Contact__c;
                        } else {
                            tempRef.Account__c = rru.Account__c;
                        }
                        tempRef.Referenceability_Type__c = rru.RecordsToBeInsertedId__c;
                        tempRef.Status__c = rru.Referenceability_Status__c;
                        tempRef.Verified__c = rru.Referenceability_Verified_Date__c;
                        referenceabilityInserted.add(tempRef);
                        //shared contact code start
                        boolean addRefToAllAccountsRBI = (contactRBIMap != null && contactRBIMap.containsKey(rru.Contact__c) ? (contactRBIMap.get(rru.Contact__c).Roll_up_Referenceability_to_All_Accounts__c ? true : (contactRBIMap.get(rru.Contact__c).Roll_up_Referenceability_to_Primary_Acc__c ? false : (addRefToAllAccounts))):addRefToAllAccounts);
                        
                        if (contactAccountMap != null && contactAccountMap.size() > 0 && contactAccountMap.containsKey(rru.Contact__c) && 
                        	sharedcontactAccountMap != null && sharedcontactAccountMap.size() > 0 && sharedcontactAccountMap.containsKey(rru.Contact__c)) {
                    		
                    		for (String accId : sharedcontactAccountMap.get(rru.Contact__c)) {
	                        	tempRef = new Referenceability__c();
	                            tempRef.Contact__c = rru.Contact__c;
	                            tempRef.Account__c = accId;
		                        tempRef.Referenceability_Type__c = rru.RecordsToBeInsertedId__c;
		                        tempRef.Status__c = rru.Referenceability_Status__c;
		                        tempRef.Verified__c = rru.Referenceability_Verified_Date__c;
		                        referenceabilityInserted.add(tempRef);
                    		}
                        }
                        //end
                    } else if (rru.Removed__c) {
                        referenceabilityDeleted.add(rru.RecordToBeDeletedId__c);
                    }
                } else if (rru.Attribute__c) {
                    
                    if (rru.Added__c) {
                        
                        if (rru.Contact__c != null) {
                            Contact_Attribute__c temp = new Contact_Attribute__c();
                            temp.Attribute__c = rru.RecordsToBeInsertedId__c;
                            temp.Contact__c = rru.Contact__c;
                            contactAttributesInserted.add(temp);
                        } else if (rru.Account__c != null) {
                            Account_Attribute__c temp = new Account_Attribute__c();
                            temp.Attribute__c = rru.RecordsToBeInsertedId__c;
                            temp.Account__c = rru.Account__c;
                            temp.Inheritable__c = rru.Attribute_Inheritable__c;
                            accountAttributesInserted.add(temp);
                        }
                    } else if (rru.Removed__c) {
                        
                        if (rru.Contact__c != null) {
                            contactAttributesDeleted.add(rru.RecordToBeDeletedId__c);
                        } else if (rru.Account__c != null) {
                            accountAttributesDeleted.add(rru.RecordToBeDeletedId__c);
                        }
                    }
                } else if (rru.No_Longer_a_Program_Member__c) {
                    
                    if (rru.contact__c != null) {
                        
                        for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getContactReferenceProfileInProfileUpdateTrigger(rru.contact__c)) {
                            rbi.Is_Referenceable__c = false;
                            rbi.Referenceability_Status__c = '';
                            updateRBI.add(rbi);
                        }
                    } else if (rru.Account__c != null) {
                        
                        for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getAccountReferenceProfileInProfileUpdateTrigger(rru.Account__c)) {
                            rbi.Is_Referenceable__c = false;
                            rbi.Referenceability_Status__c = '';
                            updateRBI.add(rbi);
                        }
                    }
                } else if (rru.Program_Member_Activated__c) {	// added for #919 - activating a program member
                	
                    if (rru.Contact__c != null) {
                        
                        for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getContactReferenceProfileInProfileUpdateTrigger(rru.contact__c)) {
                            rbi.Is_Referenceable__c = true;
                            rbi.Referenceability_Status__c = 'Active';
                            updateRBI.add(rbi);
                        }
                    } else if (rru.Account__c != null) {
                        
                        for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getAccountReferenceProfileInProfileUpdateTrigger(rru.Account__c)) {
                            rbi.Is_Referenceable__c = true;
                            rbi.Referenceability_Status__c = 'Active';
                            updateRBI.add(rbi);
                        }
                    }
                }
            }
        }
        
        if (updateRBI.size() > 0) {
            WithoutSharingHelperController.upsertRBI(updateRBI);
        }
        
        if (referenceabilityInserted.size() > 0) {
            WithoutSharingHelperController.insertReferenceabilityInProfileUpdateTrigger(referenceabilityInserted);
        }
        
        if (referenceabilityDeleted.size() > 0) {
            WithoutSharingHelperController.deleteReferenceabilityInProfileUpdateTrigger(referenceabilityDeleted);
        }
        
        if (contactAttributesInserted.size() > 0) {
            WithoutSharingHelperController.upsertContactAttributes(contactAttributesInserted);
        }
        
        if (accountAttributesInserted.size() > 0) {
            WithoutSharingHelperController.upsertAccountAttributes(accountAttributesInserted);
		}
            
        if (accountAttributesDeleted.size() > 0) {
            WithoutSharingHelperController.deleteAccountAttributesOnRefRefreshTrigger(accountAttributesDeleted);
        }
        
        if (contactAttributesDeleted.size() > 0) {
            WithoutSharingHelperController.deleteContactAttributesOnRefRefreshTrigger(contactAttributesDeleted);
        }
        
        if (fieldUpdated.size() > 0) {
            fieldUpdated = WithoutSharingHelperController.updateSobjectFields(fieldUpdated);
        }
        
        if (PUList.size() > 0) {
        	WithoutSharingHelperController.updateReferenceRefresh(PUList);
        }
    }
}