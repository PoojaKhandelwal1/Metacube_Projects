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
 * Tigger: ReferenceabilityTrigger
 * Description : this class is called from ReferenceabilityTrigger to update account/contact when Referenceability added
 * Modified by: Rekha Jangir @Dec/13/2016
 */
public with sharing class ReferenceabilityTriggerHandler {
	
    /**
     * Properties and variables
     */
    public static List<Referenceability__c> newReferenciablities;
    public static List<Referenceability__c> oldReferenciablities;
    public static Map<Id, Referenceability__c> newReferenciablityMap;
    public static Map<Id, Referenceability__c> oldReferenciablityMap;
    
    /**
     * Method called on before insert of Referenceability
     */
    public static void onBeforeInsert() {
        try {
            //sets to store the accountIds and contactIds of the current Referenceability record
            Set<String> accountIds = new Set<String>();
            Set<String> contactIds = new Set<String>();
            Set<String> duplicateReferenceabilityCheck = new Set<String>();
            List<Referenceability__c> accReferenceability = new List<Referenceability__c>();
            List<Referenceability__c> conReferenceability = new List<Referenceability__c>();
            
            for (Referenceability__c ref : newReferenciablities) {
            	
                if (ref.Status__c == null || ref.Status__c == '')
                    ref.Status__c = 'Approved';
                    
                if (ref.Account__c != null)
                    accountIds.add(ref.Account__c);
                    
                if (ref.Contact__c != null)
                    contactIds.add(ref.Contact__c);
            }
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            Map<Id, Account> accountMap = new Map<Id, Account>();
            
            for (Contact con : WithoutSharingHelperController.getContactOnRefTrigger(contactIds)) {
                contactMap.put(con.Id, con);
                
                for (Referenceability__c ref : con.Referenceabilities__r) {
                    conReferenceability.add(ref);
                }
            }
            for (Account acc : WithoutSharingHelperController.getAccountOnRefTrigger(accountIds)) {
                accountMap.put(acc.Id, acc);
                
                for (Referenceability__c ref : acc.Referenceabilities__r) {
                    accReferenceability.add(ref);
                }
            }
            
            if (accountIds.size() > 0) {
                //map to store the set of referenceabilities corresponding to an account
                //the set is a collection of referenceability and its contact 
                Map<Id, Set<String>> oldAccountReferenciabilities = new Map<Id, Set<String>> ();
                
                for (Referenceability__c ref : accReferenceability) {
                	
                    if (oldAccountReferenciabilities.get(ref.Account__c) == null) {
                        oldAccountReferenciabilities.put(ref.Account__c, new Set<String>());
                    }
                    duplicateReferenceabilityCheck.add(ref.Account__c + '' + ref.Referenceability_Type__c + '' + ref.Contact__c);
                }
                
                //loop to check for the duplicacy of referenceability
                for (Referenceability__c ref : newReferenciablities) {
                	
                    //if the duplicate record is found then add an error
                    if (duplicateReferenceabilityCheck.contains(ref.Account__c + '' + ref.Referenceability_Type__c + '' + ref.Contact__c)) {
                        ref.addError(System.Label.Account_Referenciablity);
                    } else if (contactMap != null && contactMap.containsKey(ref.Contact__c)) {
                    	
                        if (contactMap.get(ref.Contact__c).Reference_Basic_Informations__r.size() <= 0 || 
                        		contactMap.get(ref.Contact__c).Reference_Basic_Informations__r[0].Referenceability_Status__c == ConstantsController.INACTIVE || 
                        		contactMap.get(ref.Contact__c).Reference_Basic_Informations__r[0].Referenceability_Status__c == null) {
                            ref.Account__c = null;
                        } else if (accountMap != null && accountMap.containsKey(ref.Account__c) && 
                				(accountMap.get(ref.Account__c).Reference_Basic_Informations__r.size() <= 0 || 
                				(!accountMap.get(ref.Account__c).Reference_Basic_Informations__r[0].Is_Referenceable__c && 
                				!accountMap.get(ref.Account__c).Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)))
                            ref.Account__c = null;
                    }
                    duplicateReferenceabilityCheck.add(ref.Account__c + '' + ref.Referenceability_Type__c + '' + ref.Contact__c);
                }
            }
            
            if (contactIds.size() != 0) {
                duplicateReferenceabilityCheck = new Set<String> ();
                //map to store the set of referenceabilities corresponding to an account...
                Map<Id, Set<String>> oldContactReferenciabilities = new Map<Id, Set<String>>();
                for (Referenceability__c ref : conReferenceability) {
                	
                    if (oldContactReferenciabilities.get(ref.Contact__c) == null) {
                        oldContactReferenciabilities.put(ref.Contact__c, new Set<String>());
                    }
                    duplicateReferenceabilityCheck.add(ref.Referenceability_Type__c + '' + ref.Contact__c + '' + ref.Account__c);
                }
                
                //loop to check for the duplicacy of referenceability
                for (Referenceability__c ref : newReferenciablities) {
                	
                    //if the duplicate record is found then add an error
                    if (duplicateReferenceabilityCheck.contains(ref.Referenceability_Type__c + '' + ref.Contact__c + '' + ref.Account__c)) {
                        ref.addError(System.Label.Contact_Referenceabiltity);
                    } else if (contactMap != null && contactMap.containsKey(ref.Contact__c) && 
                    			contactMap.get(ref.Contact__c).Reference_Basic_Informations__r.size() > 0) {
                    				
                        if (contactMap.get(ref.Contact__c).Reference_Basic_Informations__r[0].Referenceability_Status__c == ConstantsController.INACTIVE || 
                        		contactMap.get(ref.Contact__c).Reference_Basic_Informations__r[0].Referenceability_Status__c == null) {
                            ref.Account__c = null;
                        }
                    }
                    duplicateReferenceabilityCheck.add(ref.Referenceability_Type__c + '' + ref.Contact__c + '' + ref.Account__c);
                }
            }
        } catch (exception e) {
            throw e;
        }
    }

    /**
     * Method called on before update of Referenceability
     */
    public static void onBeforeUpdate() {
        try {
            //sets to store the accountIds and contactIds of the  Referenceability record updated
            Set<String> accountIds = new Set<String>();
            Set<String> contactIds = new Set<String>();
            List<Referenceability__c> accReferenceability = new List<Referenceability__c>();
            List<Referenceability__c> conReferenceability = new List<Referenceability__c>();
            Set<String> duplicateReferenceabilityCheck = new Set<String>();
            
            for (Referenceability__c ref : oldReferenciablities) {
            	
                if (ref.Account__c != null)
                    accountIds.add(ref.Account__c);
                    
                if (ref.Contact__c != null)
                    contactIds.add(ref.Contact__c);
            }
            Map<Id, Contact> contactMap = new Map<Id, Contact> ();
            Map<Id, Account> accountMap = new Map<Id, Account> ();
            
            for (Contact con : WithoutSharingHelperController.getContactOnRefTrigger2(contactIds, oldReferenciablities)) {
                contactMap.put(con.Id, con);
                
                for (Referenceability__c ref : con.Referenceabilities__r) {
                    conReferenceability.add(ref);
                }
            }
            
            for (Account acc : WithoutSharingHelperController.getAccountOnRefTrigger2(accountIds, oldReferenciablities)) {
                accountMap.put(acc.Id, acc);
                
                for (Referenceability__c ref : acc.Referenceabilities__r) {
                    accReferenceability.add(ref);
                }
            }
            
            if (accountIds.size() > 0) {
                //map to store the set of referenceabilities corresponding to an account...
                //the set is a collection of referenceability associated to that account
                Map<Id, Set<String>> oldAccountReferenciabilities = new Map<Id, Set<String>> ();
                
                for (Referenceability__c ref : accReferenceability) {
                	
                    if (oldAccountReferenciabilities.get(ref.Account__c) == null) {
                        oldAccountReferenciabilities.put(ref.Account__c, new Set<String> ());
                    }
                    duplicateReferenceabilityCheck.add(ref.Account__c + '' + ref.Referenceability_Type__c + '' + ref.Contact__c);
                }
                
                //loop on trigger.new list to check for whether updated referenceability already exists or not
                for (Referenceability__c ref : newReferenciablities) {
                	
                    //if the referenceability already exists then add an error
                    if (duplicateReferenceabilityCheck.contains(ref.Account__c + '' + ref.Referenceability_Type__c + '' + ref.Contact__c)) {
                        ref.addError(System.Label.Account_Referenciablity);
                    }
                    
                    if (ref.Contact__c != null && contactMap.containsKey(ref.Contact__c) && 
                    		(contactMap.get(ref.Contact__c).Reference_Basic_Informations__r.size() <= 0 || 
                    		contactMap.get(ref.Contact__c).Reference_Basic_Informations__r[0].Referenceability_Status__c == ConstantsController.INACTIVE || 
                    		contactMap.get(ref.Contact__c).Reference_Basic_Informations__r[0].Referenceability_Status__c == null)) {
                        ref.Account__c = null;
                    }
                    
                    if (ref.Contact__c != null && accountMap.containsKey(ref.Account__c) && 
                    		accountMap.get(ref.Account__c).Reference_Basic_Informations__r.size() == 0)
                        ref.Account__c = null;
                    duplicateReferenceabilityCheck.add(ref.Account__c + '' + ref.Referenceability_Type__c + '' + ref.Contact__c);
                }
            }
            
            if (contactIds.size() != 0) {
                //map to store the set of referenceabilities corresponding to an account...
                //the set is a collection of referenceability associated to that account
                duplicateReferenceabilityCheck = new Set<String> ();
                Map<Id, Set<String>> oldContactReferenciabilities = new Map<Id, Set<String>>();
                
                for (Referenceability__c ref : conReferenceability) {
                	
                    if (oldContactReferenciabilities.get(ref.Contact__c) == null) {
                        oldContactReferenciabilities.put(ref.Contact__c, new Set<String>());
                    }
                    duplicateReferenceabilityCheck.add(ref.Referenceability_Type__c + '' + ref.Contact__c + '' + ref.Account__c);
                }

                //loop on trigger.new list to check for whether updated referenceability already exists or not
                for (Referenceability__c ref : newReferenciablities) {
                	
                    //if the referenceability already exists then add an error
                    if (duplicateReferenceabilityCheck.contains(ref.Referenceability_Type__c + '' + ref.Contact__c + '' + ref.Account__c)) {
                        ref.addError(System.Label.Contact_Referenceabiltity);
                    }
                    
                    if (contactMap.containsKey(ref.Contact__c) && 
                    		(contactMap.get(ref.Contact__c).Reference_Basic_Informations__r[0].Referenceability_Status__c == ConstantsController.INACTIVE || 
                    		contactMap.get(ref.Contact__c).Reference_Basic_Informations__r[0].Referenceability_Status__c == null))
                        ref.Account__c = null;
                    duplicateReferenceabilityCheck.add(ref.Referenceability_Type__c + '' + ref.Contact__c + '' + ref.Account__c);
                }
            }
        } catch (exception e) {
            throw e;
        }
    }

    /**
     * Method called on after insert of Referenceability
     */
    public static void onAfterInsert() {
    	List<Referenceability__c> approvedReferenceabilities = new List<Referenceability__c>();
    	
    	for (Referenceability__c ref : newReferenciablities) {
            
            if (!ref.Status__c.contains('Declined'))
                approvedReferenceabilities.add(ref);
        }
        updateAccountContacts(approvedReferenceabilities, false);
    }

    /**
     * Method called on after update of Referenceability
     */
    public static void onAfterUpdate() {   
        List<Referenceability__c> listReferenciablities = new List<Referenceability__c>();
        List<Referenceability__c> updateRefs = new List<Referenceability__c>();
        
        for (Referenceability__c ref : newReferenciablities) {
        	
            if ((!ref.Status__c.contains('Declined') || !oldReferenciablityMap.get(ref.Id).Status__c.contains('Declined')) && 
            		(oldReferenciablityMap.get(ref.Id).Status__c != newReferenciablityMap.get(ref.Id).Status__c || 
            		oldReferenciablityMap.get(ref.Id).Referenceability_Type__c != newReferenciablityMap.get(ref.Id).Referenceability_Type__c || 
            		oldReferenciablityMap.get(ref.Id).Comment__c != newReferenciablityMap.get(ref.Id).Comment__c || 
            		oldReferenciablityMap.get(ref.Id).Verified__c != newReferenciablityMap.get(ref.Id).Verified__c)) {
                listReferenciablities.add(ref);
            }
            
            if (oldReferenciablityMap.get(ref.Id).Account__c != newReferenciablityMap.get(ref.Id).Account__c) {
                ConstantsController.updateReferenceabilityOnAccountChange = true;
                updateRefs.add(ref);
            }
        }
        
        if (updateRefs.size() > 0 && ConstantsController.updateReferenceabilityOnAccountChange) {
            updateAccounts(updateRefs, newReferenciablityMap, oldReferenciablityMap);
        }
        
        if (listReferenciablities.size() > 0)
            updateAccountContacts(listReferenciablities, false);
    }

    /**
     * Method called on after delete of Referenceability
     */
    public static void onAfterdelete() {
        updateAccountContacts(oldReferenciablities, true);
    }

    /**
     * Method called on after delete of Referenceability
     */
    public static void onAfterUndelete() {
        updateAccountContacts(newReferenciablities, false);
    }

    /**
     * Method to Update Account & Contact Profile
     */
    public static void updateAccountContacts(List<Referenceability__c> referenciablities, Boolean isDelete) {
        //sets to store the accountIds and contactIds of the  Referenceability record updated
        Set<String> accountIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        List<Referenceability__c> accReferenceability = new List<Referenceability__c>();
        List<Referenceability__c> conReferenceability = new List<Referenceability__c>();
        
        for (Referenceability__c ref : referenciablities) {
        	
            if (ref.Account__c != null) {
                accountIds.add(ref.Account__c);
            }
            
            if (ref.Contact__c != null) {
                contactIds.add(ref.Contact__c);
            }
        }

        Custom_Settings__c cs = UtilityController.getCustomSettings();
        
        //Update Contacts
        if (contactIds.size() > 0) {
            //map to store the contacts
            Map<Id, Reference_Basic_Information__c> contacts = new Map<Id, Reference_Basic_Information__c>();
            
            for (Contact con : WithoutSharingHelperController.getContactOnRefTrigger(contactIds)) {
            	
                if (con.Reference_Basic_Informations__r.size() > 0)
                    contacts.put(con.Id, con.Reference_Basic_Informations__r[0]);
                else
                    contacts.put(con.Id, new Reference_Basic_Information__c(contact__c = con.Id, Account__c = con.AccountId));
                    
                for (Referenceability__c ref : con.Referenceabilities__r) {
                    conReferenceability.add(ref);
                }
            }
            
            if (contacts != null && contacts.size() > 0) {
                //references are stored in the set and mapped according to the associated contact
                Map<Id, List<Referenceability__c>> ContactReference = new Map<Id, List<Referenceability__c>>();
                
                for (Id contactId : contacts.keySet()) {
                    ContactReference.put(contactId, new List<Referenceability__c>());
                }
                
                for (Referenceability__c ref : conReferenceability) {
                	
                    if (ref.Status__c == ConstantsController.APPROVED)
                        ContactReference.get(ref.contact__c).add(ref);
                }
                Set<String> forduplicateRef = new Set<String> ();
                
                //loop which forms the comma separated string which is added to contacts map....which is upserted later 
                for (Id cntctId : ContactReference.keySet()) {
                    String referenceabilities = '';
                    String referenceabilityIds1 = '';
                    String referenceabilityIds2 = '';
                    
                    for (Referenceability__c ref : ContactReference.get(cntctId)) {
                        String refNo = (ref.Referenceability_Type__r.Referenceability_no__c != null ? 'R' + 
                        				String.valueOf(ref.Referenceability_Type__r.Referenceability_no__c) + 'R' : '');
                        				
                        if (!forduplicateRef.contains(refNo)) {
                            forduplicateRef.add(refNo);
                            
                            if (referenceabilities == '') {
                                referenceabilities = ref.Referenceability_Type__r.Name;
                                referenceabilityIds1 = refNo;
                            } else {
                                referenceabilities = referenceabilities + ', ' + ref.Referenceability_Type__r.Name;
                                
                                if (referenceabilityIds1 != null && referenceabilityIds1.length() < 250 && refNo.length() < 5)
                                    referenceabilityIds1 = referenceabilityIds1 + ',' + refNo;
                                else {
                                	
                                    if (referenceabilityIds2 == '')
                                        referenceabilityIds2 = refNo;
                                    else if (referenceabilityIds2.length() < 250 && refNo.length() < 5)
                                        referenceabilityIds2 = referenceabilityIds2 + ',' + refNo;
                                }
                            }
                        }
                    }
                    forduplicateRef.clear();
                    contacts.get(cntctId).Referenceability__c = referenceabilities;
                    contacts.get(cntctId).ReferenceabilityType_Ids1__c = referenceabilityIds1;
                    contacts.get(cntctId).ReferenceabilityType_Ids2__c = referenceabilityIds2;
                    contacts.get(cntctId).Last_Att_Ref_Update__c = DateTime.now();
		            contacts.get(cntctId).Att_Ref_Last_Update_By__c = Userinfo.getUserId();

                    if (UserInfo.getUserId() == contacts.get(cntctId).Profile_Update_Owner__c || UserInfo.getUserId() == contacts.get(cntctId).Reference_Owner__c 
                    		|| UserInfo.getUserId() == contacts.get(cntctId).Contact__r.OwnerId) {
		            	contacts.get(cntctId).Last_Refresh_Date__c = DateTime.now();
		            }
                    
                    //To make the Contact a reference program member, with a status of Inactive.
                    if (!contacts.get(cntctId).Is_Referenceable__c && !isDelete && !contacts.get(cntctId).Reference_Program_Candidate__c) {
                        contacts.get(cntctId).Is_Referenceable__c = true;
                        contacts.get(cntctId).Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                    }
                }
                WithoutSharingHelperController.upsertRBI(contacts.values());
            }
        }
        
        //Update Accounts
        if (accountIds.size() != 0) {
            //map to store the accounts
            //references are stored in the set and mapped according to the associated contact
            Map<Id, Reference_Basic_Information__c> Accounts = new Map<Id, Reference_Basic_Information__c>();
            //Map<Id, Reference_Basic_Information__c> contacts = new Map<Id, Reference_Basic_Information__c>();
            
            for (Account acc : WithoutSharingHelperController.getAccountRecordsWithAllRBIAndRef(accountIds)) {
            	
                for (Reference_Basic_Information__c rbi : acc.Reference_Basic_Informations__r) {
                	
                    if (!Accounts.containsKey(rbi.Account__c) && rbi.Account__c != null && rbi.Contact__c == null) {
                        Accounts.put(rbi.Account__c, rbi);
                    }
                    //for invalid query locater #662
                    /*
                    if (rbi.Contact__c != null && !contacts.containsKey(rbi.Contact__c))
                        contacts.put(rbi.Contact__c, rbi);*/
                }
                
                if (!accounts.containsKey(acc.Id))
                    Accounts.put(acc.Id, new Reference_Basic_Information__c(Account__c = acc.Id));
                    
                for (Referenceability__c ref : acc.Referenceabilities__r) {
                    accReferenceability.add(ref);
                }
            }

            if (Accounts != null && Accounts.size() > 0) {
                Map<Id, List<Referenceability__c>> AccountReference = new Map<Id, List<Referenceability__c>>();
                
                for (Id accountId : Accounts.keySet()) {
                    AccountReference.put(accountId, new List<Referenceability__c>());
                }
                
                for (Referenceability__c ref : accReferenceability) {
                	
                    if (ref.Status__c == ConstantsController.APPROVED)
                        AccountReference.get(ref.account__c).add(ref);
                }
                Set<String> forduplicateRef = new Set<String>();
                
                //loop which forms the comma separated string which is added to contacts map....which is upserted later 
                for (Id accntId : AccountReference.keySet()) {
                    String referenceabilities = '';
                    String referenceabilityIds1 = '';
                    String referenceabilityIds2 = '';
                    
                    for (Referenceability__c ref : AccountReference.get(accntId)) {
                        String refNo = (ref.Referenceability_Type__r.Referenceability_no__c != null ? 'R' + 
                        				String.valueOf(ref.Referenceability_Type__r.Referenceability_no__c) + 'R' : '');
                        				
                        if (!forduplicateRef.contains(refNo)) {
                            forduplicateRef.add(refNo);
                            
                            if (referenceabilities == '') {
                                referenceabilities = ref.Referenceability_Type__r.Name;
                                referenceabilityIds1 = refNo;
                            } else {
                                referenceabilities = referenceabilities + ', ' + ref.Referenceability_Type__r.Name;
                                
                                if (referenceabilityIds1.length() < 250 && refNo.length() < 5)
                                    referenceabilityIds1 = referenceabilityIds1 + ',' + refNo;
                                else {
                                	
                                    if (referenceabilityIds2 == '')
                                        referenceabilityIds2 = refNo;
                                    else if (referenceabilityIds2.length() < 250 && refNo.length() < 5)
                                        referenceabilityIds2 = referenceabilityIds2 + ',' + refNo;
                                }
                            }
                        }
                    }
                    forduplicateRef.clear();
                    accounts.get(accntId).Referenceability__c = referenceabilities;
                    accounts.get(accntId).ReferenceabilityType_Ids1__c = referenceabilityIds1;
                    accounts.get(accntId).ReferenceabilityType_Ids2__c = referenceabilityIds2;
                    accounts.get(accntId).Last_Att_Ref_Update__c = dateTime.now();
		            accounts.get(accntId).Att_Ref_Last_Update_By__c = Userinfo.getUserId();
		            
                    if (UserInfo.getUserId() == accounts.get(accntId).Profile_Update_Owner__c || UserInfo.getUserId() == accounts.get(accntId).Reference_Owner__c 
                    		|| UserInfo.getUserId() == accounts.get(accntId).Account__r.OwnerId) {
		            	accounts.get(accntId).Last_Refresh_Date__c = DateTime.now();
		            }
		            
                    if (accounts.get(accntId).Is_Referenceable__c == false && !isDelete && !accounts.get(accntId).Reference_Program_Candidate__c) {
                        accounts.get(accntId).Is_Referenceable__c = true;
                        accounts.get(accntId).Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                    }
                }
                WithoutSharingHelperController.upsertRBI(accounts.values());
            }
        }
    }
    /**
     * Method to Update Account
     */
    private static void updateAccounts(List<Referenceability__c> referenciablities, Map<Id, Referenceability__c> newMap, Map<Id, Referenceability__c> oldMap) {
        Set<String> newAccountIds = new Set<String>();
        Set<String> oldAccountIds = new Set<String>();
        Set<String> allAccountIds = new Set<String>();
        
        for (Referenceability__c ref : referenciablities) {
        	
            if (newMap.get(ref.Id).Account__c != null) {
                newAccountIds.add(newMap.get(ref.Id).Account__c);
                allAccountIds.add(newMap.get(ref.Id).Account__c);
            }
            oldAccountIds.add(oldMap.get(ref.Id).Account__c);
            allAccountIds.add(oldMap.get(ref.Id).Account__c);
        }
        List<Referenceability__c> accReferenceability = new List<Referenceability__c>();
        Map<Id, Reference_Basic_Information__c> Accounts = new Map<Id, Reference_Basic_Information__c>();
        //Map<Id, Reference_Basic_Information__c> contacts = new Map<Id, Reference_Basic_Information__c>();
        
        for (Account acc : WithoutSharingHelperController.getAccountRecordsWithAllRBIAndRef(allAccountIds)) {
        	
            for (Reference_Basic_Information__c rbi : acc.Reference_Basic_Informations__r) {
            	
                if (!Accounts.containsKey(rbi.Account__c) && rbi.Contact__c == null) {
                    Accounts.put(rbi.Account__c, rbi);
                }
                //for invalid query locater #662
                /*if (rbi.Contact__c != null && !contacts.containsKey(rbi.Contact__c))
                    contacts.put(rbi.Contact__c, rbi);*/
            }
            
            for (Referenceability__c ref : acc.Referenceabilities__r) {
                accReferenceability.add(ref);
            }
        }

        Custom_Settings__c cs = UtilityController.getCustomSettings();
        
        if (Accounts != null && Accounts.size() > 0) {
            Map<Id, List<Referenceability__c>> AccountReference = new Map<Id, List<Referenceability__c>>();
            
            for (Id accountId : Accounts.keySet()) {
                AccountReference.put(accountId, new List<Referenceability__c> ());
            }
            
            for (Referenceability__c ref : accReferenceability) {
            	//for invalid query locater #662
                /*if (ref.Contact__c == null || (ref.contact__c != null && contacts != null && contacts.size() > 0 && 
                		contacts.get(ref.Contact__c) != null && (contacts.get(ref.Contact__c).Referenceability_Status__c == ConstantsController.ACTIVE || 
                		contacts.get(ref.Contact__c).Referenceability_Status__c == ConstantsController.CAUTION))) {
                			*/
                    if (ref.Status__c == ConstantsController.APPROVED)
                        AccountReference.get(ref.account__c).add(ref);
                //}
            }
            Set<String> forduplicateRef = new Set<String>();
            
            //loop which forms the comma separated string which is added to contacts map....which is upserted later 
            for (Id accntId : AccountReference.keySet()) {
                String referenceabilities = '';
                String referenceabilityIds1 = '';
                String referenceabilityIds2 = '';
                forduplicateRef = new Set<String>();
                
                for (Referenceability__c ref : AccountReference.get(accntId)) {
                    String refNo = (ref.Referenceability_Type__r.Referenceability_no__c != null ? 'R' + 
                    				String.valueOf(ref.Referenceability_Type__r.Referenceability_no__c) + 'R' : '');
                    
                    if (!forduplicateRef.contains(refNo)) {
                        forduplicateRef.add(refNo);
                        
                        if (referenceabilities == '') {
                            referenceabilities = ref.Referenceability_Type__r.Name;
                            referenceabilityIds1 = refNo;
                        } else {
                            referenceabilities = referenceabilities + ', ' + ref.Referenceability_Type__r.Name;
                            
                            if (referenceabilityIds1.length() < 250 && refNo.length() < 5)
                                referenceabilityIds1 = referenceabilityIds1 + ',' + refNo;
                            else {
                                
                                if (referenceabilityIds2 == '')
                                    referenceabilityIds2 = refNo;
                                else if (referenceabilityIds2.length() < 250 && refNo.length() < 5)
                                    referenceabilityIds2 = referenceabilityIds2 + ',' + refNo;
                            }
                        }
                    }
                }
                forduplicateRef.clear();
                accounts.get(accntId).Referenceability__c = referenceabilities;
                accounts.get(accntId).ReferenceabilityType_Ids1__c = referenceabilityIds1;
                accounts.get(accntId).ReferenceabilityType_Ids2__c = referenceabilityIds2;
	            accounts.get(accntId).Last_Att_Ref_Update__c = dateTime.now();
	            accounts.get(accntId).Att_Ref_Last_Update_By__c = Userinfo.getUserId();
            }
            WithoutSharingHelperController.upsertRBI(accounts.values());
        }
    }
}