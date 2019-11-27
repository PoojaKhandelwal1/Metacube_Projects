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
 * Trigger: RBITrigger
 * Description : Handler class for DML operations on RBI of account/contact
 * Modified by: Gaurav Saini @Nov/22/2016
 */
public with sharing class RBITriggerHandler {
    
    private static Custom_Settings__c cs = UtilityController.getCustomSettings();
    
    /**
     * Method called on before insert of Reference Profile
     */
    public static void onBeforeInsert(List<Reference_Basic_Information__c> newRBIList) {
        //Assigns the default initial # of Uses per # of Days values as defined from Custom Settings 
        
        Set<Id> accIds = new Set<Id>();
        Set<Id> conIds = new Set<Id>();
        Set<Id> contactAccountIds = new Set<Id>();
        Boolean isLifetimePointsNull = false;
        
        if (cs != null) {
            //for Influitive integration 
            Set<Id> accountIds = new Set<Id>();
            
            for (Reference_Basic_Information__c rbi : newRBIList) {
                
                //validation for shared contact settings
                if (!cs.Shared_Contacts__c) {
                    
                    if (rbi.Roll_up_Attributes_to_All_Accounts__c
                                || rbi.Roll_up_Attributes_to_Primary_Account__c
                                || rbi.Roll_up_Referenceability_to_All_Accounts__c
                                || rbi.Roll_up_Referenceability_to_Primary_Acc__c
                                || rbi.Inherit_Attributes_from_All_Accounts__c
                                || rbi.Inherit_Attributes_from_Primary_Account__c) {
                        
                        rbi.addError(system.Label.Shared_Contact_check_setting_RBI);
                    }
                } else {
                    
                    if ((rbi.Roll_up_Attributes_to_All_Accounts__c
                                    && rbi.Roll_up_Attributes_to_Primary_Account__c)
                                || (rbi.Roll_up_Referenceability_to_All_Accounts__c
                                    && rbi.Roll_up_Referenceability_to_Primary_Acc__c)
                                || (rbi.Inherit_Attributes_from_All_Accounts__c
                                    && rbi.Inherit_Attributes_from_Primary_Account__c)) {
                        
                        rbi.addError(system.Label.Roll_up_Inherit_check);
                    } else if (rbi.Contact__c != null) {
                        rbi.Roll_up_Attributes_to_All_Accounts__c = cs.Roll_up_Attributes_to_All_Accounts__c;
                        rbi.Roll_up_Attributes_to_Primary_Account__c = cs.Roll_up_Attributes_to_Primary_Account__c;
                        rbi.Roll_up_Referenceability_to_All_Accounts__c = cs.Roll_up_Referenceability_to_All_Accounts__c;
                        rbi.Roll_up_Referenceability_to_Primary_Acc__c = cs.Roll_up_Referenceability_to_Primary_Acc__c;
                        rbi.Inherit_Attributes_from_All_Accounts__c = cs.Inherit_Attributes_from_All_Accounts__c;
                        rbi.Inherit_Attributes_from_Primary_Account__c = cs.Inherit_Attributes_from_Primary_Account__c;
                    }
                }
                
                //validation for generic account on Contact Reference Profile ticket #578
                if (rbi.Generic_Account__c && rbi.Contact__c != null) {
                    rbi.addError(system.Label.Check_for_Generic_account_on_Contact);
                }
                
                //validation for generic account ticket #578
                if (rbi.Generic_Account__c && (rbi.Is_Referenceable__c || rbi.Reference_Program_Candidate__c)) {
                    rbi.addError(system.Label.Check_for_Generic_account);
                }
                
                if (rbi.Is_Referenceable__c) {
                    
                    if (rbi.Referenceability_Status__c == ConstantsController.ACTIVE
                                || rbi.Referenceability_Status__c == ConstantsController.CAUTION) {
                        
                        //for Influitive integration 
                        if (rbi.Contact__c == null) {
                            accountIds.add(rbi.Account__c);
                        } else {
                            contactAccountIds.add(rbi.Account__c);
                        }
                    }
                    
                    if (rbi.Joined_Reference_Program__c == null
                                && (rbi.Referenceability_Status__c == ConstantsController.ACTIVE
                                    || rbi.Referenceability_Status__c == ConstantsController.CAUTION)) {
                        rbi.Joined_Reference_Program__c = system.today();
                        rbi.Last_Refresh_Date__c = Datetime.now(); // Updated code for R13.69, Date : 09/09/2015, Tejpal
                    }
                    
                    if (rbi.RUL_Period__c == null) {
                        rbi.RUL_Period__c = (rbi.Contact__c != null ? cs.RUL_Period_Contact__c : cs.RUL_Period__c);
                    }
                    
                    if (rbi.RUL_Activities_will_do__c == null) {
                        rbi.RUL_Activities_will_do__c = (rbi.Contact__c != null ? cs.RUL_Activities_Contact__c : cs.RUL_Activities__c);
                    }
                } else {
                    rbi.RUL_Period__c = null;
                    rbi.RUL_Activities_will_do__c = null;
                }
                
                if (cs.Default_Reference_Accounts_Managed__c != null
                            && rbi.Contact__c == null
                            && ConstantsController.defaultManagedReferenceAccount
                            && (rbi.Reference_Program_Candidate__c
                                || rbi.Referenceability_Status__c == ConstantsController.ACTIVE
                                || rbi.Referenceability_Status__c == ConstantsController.CAUTION)) {
                    
                    // Updated code for R11.29, Date : 21/10/2015, Tejpal
                    rbi.Managed_Reference_Account__c = cs.Default_Reference_Accounts_Managed__c;
                }
                
                // re #890- Added invative reason in case of status Inactive
                if (rbi.Referenceability_Status__c == 'Inactive' && String.isBlank(rbi.inactive_reason__c)) {
                    rbi.inactive_reason__c = 'Reference Profile Set to Inactive when initially created.';
                }   
                
                // create set of account and contact
                if (rbi.Contact__c == null) { 
                    accIds.add(rbi.Account__c);  
                } else { 
                    conIds.add(rbi.Contact__c);
                } 
            }
            
            //re #994 - Account Description should be copied in RBI Summary             
            if (cs.Populate_Summary_frm_Account_Description__c) {  
                String summary = '';
                Map<ID, Account> mapAccount = new Map<ID, Account>([SELECT Id, Description FROM Account WHERE Id 
                                                                        IN :accIds LIMIT :limits.getLimitQueryRows()]);
                Map<ID, Contact> mapContact = new Map<ID, Contact>([SELECT Id, Description FROM Contact WHERE Id 
                                                                        IN :conIds LIMIT :limits.getLimitQueryRows()]);  
                
                for (Reference_Basic_Information__c rbi : newRBIList) {
                    summary = '';
                     
                    if (rbi.Contact__c == null && mapAccount.keyset().contains(rbi.Account__c)) { 
                        summary = mapAccount.get(rbi.Account__c).Description;
                    } else if(mapContact.keyset().contains(rbi.Contact__c)) {
                        summary = mapContact.get(rbi.Contact__c).Description;  
                    } 
                     
                    if (!String.isBlank(summary)) { 
                        rbi.Ref_Profile_Summary__c = summary;
                    } 
                }   
            }
            
            //for Influitive integration 
            if (ConstantsController.isNotFromRewardTrigger) {
                List<Reward__c> rewardList= WithoutSharingHelperController.getRewards(accountIds, contactAccountIds);
                Map<String, Decimal> lifeTimePointsMap = new Map<String, Decimal>();
                Map<String, Decimal> availableTimePointsMap = new Map<String, Decimal>();
                Map<String, Decimal> lifeTimePointsContactMap = new Map<String, Decimal>();
                
                for (Reward__c reward : rewardList) {
                    
                    if (accountIds.contains(reward.Account__c)) {
                        
                        if (!lifeTimePointsMap.containsKey(reward.Account__c)) {
                            lifeTimePointsMap.put(reward.Account__c, 0);
                            availableTimePointsMap.put(reward.Account__c, 0);
                        }
                        Decimal totalAccountPoints = lifeTimePointsMap.get(reward.Account__c)
                                                            + reward.Amount__c;
                        Decimal totalAvailablePoints = availableTimePointsMap.get(reward.Account__c)
                                                            + reward.Available_Points__c;
                        lifeTimePointsMap.put(reward.Account__c, totalAccountPoints);
                        availableTimePointsMap.put(reward.Account__c, totalAvailablePoints);
                    }
                    
                    if (contactAccountIds.contains(reward.Account__c) && reward.Contact__c != null) {
                        
                        if (!lifeTimePointsContactMap.containsKey(reward.Contact__c)) {
                            lifeTimePointsContactMap.put(reward.Contact__c, 0);
                        }
                        Decimal totalContactPoints = lifeTimePointsContactMap.get(reward.Contact__c) + reward.Amount__c;
                        lifeTimePointsContactMap.put(reward.Contact__c, totalContactPoints);
                    }
                }
                
                for (Reference_Basic_Information__c rbi : newRBIList) { 
                  
                    if (rbi.Contact__c == null
                                && rbi.Account__c != null
                                && lifeTimePointsMap != null
                                && lifeTimePointsMap.containsKey(rbi.Account__c )) {
                        
                        rbi.Lifetime_Points__c = lifeTimePointsMap.get(rbi.Account__c);
                        rbi.Current_Available_Balance_Points__c = availableTimePointsMap.get(rbi.Account__c);
                    } else if (rbi.Contact__c != null
                                && rbi.Account__c != null
                                && lifeTimePointsContactMap != null
                                && lifeTimePointsContactMap.containsKey(rbi.Contact__c)) {
                        
                        rbi.Lifetime_Points__c = lifeTimePointsContactMap.get(rbi.Contact__c);
                    }
                }
            }
        }
        checkDuplicateRBI(newRBIList, null, null);
    }

    /**
     * Method to check that there is no duplicate Reference Profile for any account/contact.
     */
    private static void checkDuplicateRBI(List<Reference_Basic_Information__c> RBIList,
                                            Map<Id, Reference_Basic_Information__c> newMap,
                                            Map<Id, Reference_Basic_Information__c> oldMap) {
        
        if (ConstantsController.runDuplicateRBICheck) {
            ConstantsController.runDuplicateRBICheck = false;
            Set<Id> contactIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            Set<Id> duplicateAccountIds = new Set<Id>();
            Set<Id> mapAccounts = new Set<Id>();
            Map<Id, Reference_Basic_Information__c> mapContacts = new Map<Id, Reference_Basic_Information__c>();
            
            for (Reference_Basic_Information__c rbi : RBIList) {

                if (rbi.Account__c == null) {
                    rbi.addError(System.Label.FILL_ACCOUNT_FIELD);
                } else {
                    accountIds.add(rbi.Account__c);
                    
                    if (rbi.Contact__c == null) {
                        
                        if (duplicateAccountIds.contains(rbi.Account__c)) {
                            rbi.addError(ConstantsController.DUPLICATE_RBI_CHECK_ACCOUNT);
                        } else {
                            duplicateAccountIds.add(rbi.Account__c);
                        }
                    }
                    
                    if (rbi.Contact__c != null) {
                        
                        if (contactIds.contains(rbi.Contact__c)) {
                            rbi.addError(ConstantsController.DUPLICATE_RBI_CHECK_CONTACT);
                        } else {
                            contactIds.add(rbi.Contact__c);
                        }
                    }
                }
            }
            
            for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getRBIsForUpdateRBI(contactIds, accountIds)) {
                
                if (rbi.Contact__c != null && contactIds.contains(rbi.Contact__c)) {
                    mapContacts.put(rbi.Contact__c, rbi);
                } else if (rbi.Contact__c == null && accountIds.contains(rbi.Account__c)) {
                    mapAccounts.add(rbi.Account__c);
                }
            }
            
            for (Reference_Basic_Information__c rbi : RBIList) {
                
                if (rbi.Reference_Program_Candidate__c && rbi.Is_Referenceable__c) {
                    rbi.addError(ConstantsController.CANDIDATE_MEMBER_CHECK);
                }
                
                if (mapContacts.size() > 0 && !ConstantsController.updateRBIOnAccountChange) {
                    
                    if (newMap != null && oldMap != null) {
                        
                        if (rbi.contact__c != null && mapContacts.containsKey(rbi.Contact__c)) {
                            
                            if (newMap.get(rbi.Id).Account__c != oldMap.get(rbi.Id).Account__c) {
                                rbi.addError(System.Label.CANNOT_CHANGE_ACCOUNT);
                            } else if (newMap.get(rbi.Id).Contact__c != oldMap.get(rbi.Id).Contact__c) {
                                rbi.addError(ConstantsController.DUPLICATE_RBI_CHECK_CONTACT);
                            }
                        }
                    } else {
                        
                        if (rbi.contact__c != null && mapContacts.containsKey(rbi.Contact__c)) {
                            rbi.addError(ConstantsController.DUPLICATE_RBI_CHECK_CONTACT);
                        }
                    }
                }
                
                if (rbi.Contact__c == null && mapAccounts.contains(rbi.Account__c)) {
                    rbi.addError(ConstantsController.DUPLICATE_RBI_CHECK_ACCOUNT);
                }
            }
        }
    }
    
    /**
     * Method called on after delete of Reference Profile
     */
    public static void onAfterDelete(List<Reference_Basic_Information__c> oldRBIList) {
        List<Reference_Basic_Information__c> accountTypeRBIList= new List<Reference_Basic_Information__c>();
        List<Reference_Basic_Information__c> contactTypeRBIList= new List<Reference_Basic_Information__c>();
        
        for (Reference_Basic_Information__c rbi : oldRBIList) {
            
            if (rbi.Contact__c == null) {
                accountTypeRBIList.add(rbi);
            } else {
                contactTypeRBIList.add(rbi);
            }
        }
        
        if (contactTypeRBIList.size() > 0 && !ConstantsController.isCallFromBatchRemoveDuplicateRBI) {
            Set<Id> contactIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            
            for (Reference_Basic_Information__c rbi : contactTypeRBIList) {
                contactIds.add(rbi.Contact__c);
                accountIds.add(rbi.Account__c);
            }
            deleteAttributeFromAccount(contactIds, accountIds);
            updateAccountRulSettings(contactTypeRBIList);
        }
    }


    /**
     * Method called on after insert of Reference Profile
     */
    public static void onAfterInsert(List<Reference_Basic_Information__c> newRBIList) {
        List<Reference_Basic_Information__c> accountTypeRBIList= new List<Reference_Basic_Information__c>();
        List<Reference_Basic_Information__c> contactTypeRBIList= new List<Reference_Basic_Information__c>();
        List<Reference_Note__c> notes = new List<Reference_Note__c>();
        Map<Id,List<Account_Attribute__c>> accToAtt = new Map<Id,List<Account_Attribute__c>>();
        for (Reference_Basic_Information__c rbi : newRBIList) {
            
            if (rbi.Contact__c == null) {
                accountTypeRBIList.add(rbi);
            } else {
                contactTypeRBIList.add(rbi);
            }
        }
        
        if (accountTypeRBIList.size() > 0) {
            Set<String> accountIds = new Set<String>();
            Set<String> accountForAttMapping = new Set<String>();
            List<Reference_Basic_Information__c> contactRBIList= new List<Reference_Basic_Information__c>();
            List<Contact_Attribute__c> contactAttributes = new List<Contact_Attribute__c>();
            List<Contact_Attribute__c> allContactAttributes = new List<Contact_Attribute__c>();
            List<Reference_Basic_Information__c> allcontactRBIList= new List<Reference_Basic_Information__c>();
            //Shared Contact code start
            Set<String> sharedContactIds = new Set<String>();
            Set<String> sharedContactAccountIds = new Set<String>();
            Map<Id, Set<Id>> accountContactMap = new Map<Id, Set<Id>>(); 
            Map<Id, Set<Id>> contactAccountMap = new Map<Id, Set<Id>>();
            Map<Id, List<Contact>> AccountRelatedContacts = new Map<Id, List<Contact>>();
            //end  
           
            for (Reference_Basic_Information__c rbi : accountTypeRBIList) {
                
                 //#890 -Creating notes if RBI created incative using custom setting.
                if (rbi.Referenceability_Status__c != null && rbi.Referenceability_Status__c == 'Inactive' 
                            && rbi.inactive_reason__c != null && rbi.inactive_reason__c.contains('Reference Profile Set to Inactive when initially created')) {  
                    notes.add(new Reference_Note__c(Account__c = rbi.Account__c, 
                                                    Note__c = System.Label.Reason_For_Inactive + ' ' + 'Reference Profile Set to Inactive when initially created.')); 
                }
                
                if (rbi.Is_Referenceable__c) {
                    accountIds.add(rbi.account__c);
                    //Shared Contact
                    accountContactMap.put(rbi.account__c, new Set<Id>());
                    AccountRelatedContacts.put(rbi.Account__c, new List<Contact>());
                }
                
                if (rbi.Is_Referenceable__c || rbi.Reference_Program_Candidate__c) {
                    accountForAttMapping.add(rbi.account__c);
                }
            }
            
            //Shared Contact start
            if (cs.Shared_Contacts__c) {
                String objectName = cs.Shared_Contact_Object__c;
                String accountField = cs.Shared_Account_Field__c;
                String contactField = cs.Shared_Contact_Field__c;
                
                if (accountField != null && accountField != '' && contactField != null && contactField != '') {
                    String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName
                                     + ' WHERE ' + accountField + ' IN :accountIds';
                    List<sObject> objectList= Database.query(query);
                    
                    if (objectList!= null && objectList.size() > 0) {
                        
                        for (sObject obj : objectList) {
                            
                            if (accountContactMap.containsKey((String)obj.get(accountField))) {
                                sharedContactIds.add((String)obj.get(contactField));
                                accountContactMap.get((String)obj.get(accountField)).add((String)obj.get(contactField));
                            }
                            
                            if (contactAccountMap != null
                                        && !contactAccountMap.containsKey((String)obj.get(contactField))) {
                                
                                contactAccountMap.put((String)obj.get(contactField), new Set<Id>());
                            }
                            contactAccountMap.get((String)obj.get(contactField)).add((String)obj.get(accountField));
                        }
                    }
                }
            }
            //Shared Contact end
            
            if (accountIds.size() > 0) {
                
                //Shared Contact start
                if (cs.Shared_Contacts__c && sharedContactIds.size() > 0) {
                    
                    for (Contact contact : WithoutSharingHelperController.getContactInRBI1SharedContact(accountIds, sharedContactIds)) {
                        
                        if (contact.Reference_Basic_Informations__r.size() > 0) {
                            
                            if (contact.Reference_Basic_Informations__r[0].Referenceability_Status__c == 'Active'
                                        || contact.Reference_Basic_Informations__r[0].Referenceability_Status__c == 'Caution') {
                                
                                contactRBIList.add(contact.Reference_Basic_Informations__r[0]);
                            }
                            allcontactRBIList.add(contact.Reference_Basic_Informations__r[0]);
                        } else {
                            contactAccountMap.remove(contact.Id);
                        }
                        
                        if (contactAccountMap.containsKey(contact.Id)) {
                            
                            for (String accountId : contactAccountMap.get(contact.Id)) {
                                
                                if (AccountRelatedContacts != null && AccountRelatedContacts.containsKey(accountId)) {
                                    AccountRelatedContacts.get(accountId).add(contact);
                                }
                            }
                        }
                        
                        if (!sharedContactIds.contains(contact.Id)) {
                            sharedContactAccountIds.add(contact.AccountId);
                        }
                        
                        for (Contact_Attribute__c conAtt : contact.Contact_Attributes__r) {
                            contactAttributes.add(conAtt);
                        }
                    }
                } else {    // Shared Contact end
                    
                    for (Contact contact : WithoutSharingHelperController.getContactInRBI1(accountIds)) {
                        
                        for (Contact_Attribute__c conAtt : contact.Contact_Attributes__r) {
                            contactAttributes.add(conAtt);
                        }
                        
                        if (contact.Reference_Basic_Informations__r.size() > 0) {
                            
                            if (contact.Reference_Basic_Informations__r[0].Referenceability_Status__c == 'Active'
                                        || contact.Reference_Basic_Informations__r[0].Referenceability_Status__c == 'Caution') {
                                contactRBIList.add(contact.Reference_Basic_Informations__r[0]);
                            }
                            allcontactRBIList.add(contact.Reference_Basic_Informations__r[0]);
                        }
                    }
                }
                
                List<Account> allaccountsWithRelatedRecords = new List<Account>();
                List<Account> accountsWithRelatedRecords = new List<Account>();
                
                //Shared Contact start
                if (cs.Shared_Contacts__c && sharedContactIds.size() > 0) {
                    sharedContactAccountIds.addAll(accountIds);
                    allaccountsWithRelatedRecords =
                        WithoutSharingHelperController.getAccountRecordsWithAllRelatedRecords(sharedContactAccountIds);
                    Set<String> accForAtt = new Set<String>();
                    for (Account acc : allaccountsWithRelatedRecords) {
                        
                        if (accountIds.contains(acc.Id)) {
                            accountsWithRelatedRecords.add(acc);
                            accForAtt.add(acc.Id);
                        }
                    }
                    for (Account_Attribute__c accAtr : WithoutSharingHelperController.getAccountAttributesForAccount(accForAtt)) {
                        if (!accToAtt.containsKey(accAtr.Account__c)) {
                            accToAtt.put(accAtr.Account__c, new List<Account_Attribute__c>());
                        }
                        accToAtt.get(accAtr.Account__c).add(accAtr);
                    }
                    updateAttributeOnAccountSharedContact(contactRBIList, contactAttributes, allaccountsWithRelatedRecords, contactAccountMap, sharedContactIds);
                    AddAttributesFromRefContentToAccount(accountIDs, accountsWithRelatedRecords,accToAtt);
                    addAttributesOnContactSharedContact(contactRBIList, allaccountsWithRelatedRecords, accountContactMap);
                    addAttributesOnContent(accountIDs, accountsWithRelatedRecords,accToAtt); 
                    updateReferenceabilitiesonAccount(accountIDs, accountsWithRelatedRecords, AccountRelatedContacts);
                } else {    // Shared Contact end
                    accountsWithRelatedRecords = WithoutSharingHelperController.getAccountRecordsWithAllRelatedRecords(accountIds);
                    for (Account_Attribute__c accAtr : WithoutSharingHelperController.getAccountAttributesForAccount(accountIds)){
                        if (!accToAtt.containsKey(accAtr.Account__c)) {
                            accToAtt.put(accAtr.Account__c, new List<Account_Attribute__c>());
                        }
                        accToAtt.get(accAtr.Account__c).add(accAtr);
                    }
                    updateAttributeOnAccount(contactRBIList, contactAttributes, accountsWithRelatedRecords,accToAtt);
                    AddAttributesFromRefContentToAccount(accountIDs, accountsWithRelatedRecords,accToAtt);
                    addAttributesOnContact(allcontactRBIList, accountsWithRelatedRecords,accToAtt);
                    addAttributesOnContent(accountIDs, accountsWithRelatedRecords,accToAtt);
                    updateReferenceabilitiesonAccount(accountIDs, accountsWithRelatedRecords, new Map<Id, List<Contact>>());
                }
                
                /*
                 * for --> ReferenceEdge Attribute, Mapped Attribute Reporting question
                 * Set Reference_Basic_Information__c in Account Attribute
                 * by Rekha
                 */
                List<Account_Attribute__c> accountAttributes = new List<Account_Attribute__c>();
                
                for (Account acc : accountsWithRelatedRecords) {
                    String rbiId = acc.Reference_Basic_Informations__r[0].Id;
                    
                    if (accToAtt.containsKey(acc.Id)) {
                        for (Account_Attribute__c att : accToAtt.get(acc.Id)) {    
                            if (att.Reference_Basic_Information__c == null) {
                                att.Reference_Basic_Information__c = rbiId;
                                accountAttributes.add(att);
                            }
                        }
                    }
                }
                
                if (accountAttributes.size() > 0) {
                    ConstantsController.stopAccAttributeTrigger = true;
                    WithoutSharingHelperController.upsertAccountAttributes(accountAttributes);
                    ConstantsController.stopAccAttributeTrigger = false;
                }
                //end
            }
            
            if (ConstantsController.attMappingForAccount && accountForAttMapping.size() > 0) {
                
                if (Test.isRunningTest() || System.isBatch() || System.isFuture()) {
                    checkForAttributeMapping(accountForAttMapping, accountIds);
                    
                    if(accountIds.size() > 0) {                
                        checkForOpportunityAttributeMapping(accountIds);
                    }
                } else {
                    ConstantsController.attMappingForAccount = false;
                    checkForAttributeMappingFuture(accountForAttMapping, accountIds);
                    
                    if(accountIds.size() > 0) {                
                        checkForOpportunityAttributeMapping(accountIds);
                    }
                }
            }
        }
        
        if (contactTypeRBIList.size() > 0) {
            List<Reference_Basic_Information__c> referenceableContacts = new List<Reference_Basic_Information__c>();
            Set<Id> contactIds = new Set<Id>();
            Set<String> contactAccountIds = new Set<String>();
            Set<String> rbicontactIds = new Set<String>();
            List<Contact> contacts = new List<Contact>(); 
            List<Reference_Basic_Information__c> rulContacts = new List<Reference_Basic_Information__c>();
            
            //Shared Contact code start
            Set<String> sharedAccountIds = new Set<String>();
            Map<Id, Set<Id>> accountContactMap = new Map<Id, Set<Id>>(); 
            Map<Id, Set<Id>> contactAccountMap = new Map<Id, Set<Id>>();
            //end
            
            //for Influitive integration 
            Set<String> setContactId = new Set<String>();
            
            for (Reference_Basic_Information__c rbi : contactTypeRBIList) {
                
                 if (rbi.Referenceability_Status__c != null && rbi.Referenceability_Status__c == 'Inactive' 
                        && rbi.inactive_reason__c != null && rbi.inactive_reason__c.contains('Reference Profile Set to Inactive when initially created')) {  
                    notes.add(new Reference_Note__c(Contact__c = rbi.Contact__c, 
                                                    Note__c = System.Label.Reason_For_Inactive + ' ' + 'Reference Profile Set to Inactive when initially created.')); 
                }
                
                if (rbi.Is_Referenceable__c) {
                    rbicontactIds.add(rbi.Contact__c);
                    referenceableContacts.add(rbi);
                    contactAccountIds.add(rbi.Account__c);
                    
                    if (rbi.Referenceability_Status__c == ConstantsController.ACTIVE
                                || rbi.Referenceability_Status__c == ConstantsController.CAUTION) {
                        
                        rulContacts.add(rbi);
                        
                        //Shared Contact
                        contactAccountMap.put(rbi.Contact__c, new Set<Id>());
                        
                        //for Influitive integration 
                        if (rbi.Contact__c != null) {
                            setContactId.add(rbi.Contact__c);
                        }
                    }
                }
                
                if (rbi.Is_Referenceable__c || rbi.Reference_Program_Candidate__c) {
                    contactIds.add(rbi.contact__c);
                }
            }
            
            //Shared Contact start
            if (cs.Shared_Contacts__c) {
                String objectName = cs.Shared_Contact_Object__c;
                String accountField = cs.Shared_Account_Field__c;
                String contactField = cs.Shared_Contact_Field__c;
                
                if (accountField != null && accountField != '' && contactField != null && contactField != '') {
                    String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName
                                     + ' WHERE ' + contactField + ' IN :setContactId';
                    List<sObject> objectList= Database.query(query);
                    
                    if (objectList!= null && objectList.size() > 0) {
                        
                        for (sObject obj : objectList) {
                            
                            if (contactAccountMap.containsKey((String)obj.get(contactField))) {
                                sharedAccountIds.add((String)obj.get(accountField));
                                contactAccountMap.get((String)obj.get(contactField)).add((String)obj.get(accountField));
                            }
                            
                            if (accountContactMap != null
                                        && !accountContactMap.containsKey((String)obj.get(accountField))) {
                                accountContactMap.put((String)obj.get(accountField), new Set<Id>());
                            }
                            accountContactMap.get((String)obj.get(accountField)).add((String)obj.get(contactField));
                        }
                    }
                }
            }
            //Shared Contact end
            
            
            if (rulContacts.size() > 0) {
                updateAccountRulSettings(rulContacts);
            }
            
            if (referenceableContacts.size() > 0) {
                
                //Shared Contact start
                if (cs.Shared_Contacts__c && sharedAccountIds.size() > 0) {
                    contactAccountIds.addAll(sharedAccountIds);
                    List<Account> accountsWithRelatedRecords
                            = WithoutSharingHelperController.getAccountRecordsWithAllRelatedRecordsAndOnlyAccRBI(contactAccountIds);
                    addAttributesOnContactSharedContact(referenceableContacts, accountsWithRelatedRecords, accountContactMap);
                    accountsWithRelatedRecords
                            = WithoutSharingHelperController.getAccountRecordsWithAllRelatedRecordsAndOnlyAccRBI(sharedAccountIds);
                    updateAttributeOnAccountSharedContact(referenceableContacts, new List<Contact_Attribute__c>(), accountsWithRelatedRecords, contactAccountMap, new Set<String>());
                } else {    //Shared Contact end
                    List<Account> accountsWithRelatedRecords
                            = WithoutSharingHelperController.getAccountRecordsWithAllRelatedRecordsAndOnlyAccRBI(contactAccountIds);
                    for (Account_Attribute__c accAtr : WithoutSharingHelperController.getAccountAttributesForAccount(contactAccountIds)) {
                        if (!accToAtt.containsKey(accAtr.Account__c)) {
                            accToAtt.put(accAtr.Account__c, new List<Account_Attribute__c>());
                        }
                        accToAtt.get(accAtr.Account__c).add(accAtr);
                    }
                    addAttributesOnContact(referenceableContacts, accountsWithRelatedRecords,accToAtt);
                    accountsWithRelatedRecords
                            = WithoutSharingHelperController.getAccountRecordsWithAllRelatedRecordsAndOnlyAccRBI(contactAccountIds);
                    updateAttributeOnAccount(referenceableContacts, new List<Contact_Attribute__c>(), accountsWithRelatedRecords,accToAtt);
                }
                
                /*
                 * for --> ReferenceEdge Attribute, Mapped Attribute Reporting question
                 * Set Reference_Basic_Information__c in Account Attribute
                 * by Rekha
                 */
                List<Contact_Attribute__c> contactAttributes = new List<Contact_Attribute__c>();
                contacts = WithoutSharingHelperController.activateContactRecords(rbicontactIds);
                
                for (Contact con : contacts) {
                    String rbiId = con.Reference_Basic_Informations__r[0].Id;
                    
                    for (Contact_Attribute__c att : con.Contact_Attributes__r) {
                        
                        if (att.Reference_Basic_Information__c == null) {
                            att.Reference_Basic_Information__c = rbiId;
                            contactAttributes.add(att);
                        }
                    }
                }
                
                if (contactAttributes.size() > 0) {
                    ConstantsController.stopConAttributeTrigger = true;
                    WithoutSharingHelperController.upsertContactAttributes(contactAttributes);
                    ConstantsController.stopConAttributeTrigger = false;
                }
                //end
            }
            
            if (ConstantsController.attMappingForContact && contactIds.size() > 0) {
                
                if (Test.isRunningTest() || System.isBatch() || System.isFuture()) {
                    checkForAttributeMappingContact(contactIds);
                } else {
                    ConstantsController.attMappingForContact = false;
                    checkForAttributeMappingContactFuture(contactIds);
                }
            }
            //for Influitive integration 
             
            if (!system.isBatch()
                        && !system.isFuture()
                        && cs.Is_Influitive_Integration_Enabled__c != null
                        && cs.Is_Influitive_Integration_Enabled__c
                        && ConstantsController.isInfluitiveNotRunning
                        && !Test.isRunningTest()) {
                            String jsonString = JSON.serialize(contacts);
                            Infl_Member.influitiveMembersCallout(jsonString); 
            }
        }
        
        // Insert Notes:
        if (notes.size() > 0) {
            WithoutSharingHelperController.insertReferenceNotes(notes);
        }
    }
    
    /**
     * Method to add Attribute on Content
     */
    static void addAttributesOnContent(Set<String> accountIDs, List<Account> accounts,Map<Id,List<Account_Attribute__c>> accToAtt) {
        List<Content_Attribute__c> newContentAttrib = new List<Content_Attribute__c>();
        Map<Id, Set<Id>> accountContentMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> contentAttribMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> attAssociatedToAccount = new Map<Id, Set<Id>>();
        Set<String> preventDuplicacy = new Set<String>();
        Set<Id> refContentIds = new Set<Id>();
        Content_Attribute__c tempContentObj;
        
        if (accountIDs.size() > 0) {
            
            /* FOR SOQL 101 */
            for (Account acc : accounts) {
                
                if (accountIDs.contains(acc.Id)) {
                    
                    if (accToAtt.containsKey(acc.Id)) {
                        for (Account_Attribute__c accAtt : accToAtt.get(acc.Id)) {    
                            if (accAtt.Reference_Content__c == null && accAtt.Contact__c == null && accAtt.Inheritable__c) {
                                
                                if (!attAssociatedToAccount.containsKey(accAtt.Account__c)) {
                                    attAssociatedToAccount.put(accAtt.Account__c, new Set<Id>());
                                }
                                attAssociatedToAccount.get(accAtt.Account__c).add(accAtt.Attribute__c);
                            }
                        }
                    }
                    
                    for (Account_Reference_Content__c accRef : acc.Account_Reference_Contents__r) {
                        refContentIds.add(accRef.Reference_Content__c);
                        
                        if (!accountContentMap.containskey(accRef.Account__c)) {
                            accountContentMap.put(accRef.Account__c, new Set<Id>());
                        }
                        accountContentMap.get(accRef.Account__c).add(accRef.Reference_Content__c);
                        contentAttribMap.put(accRef.Reference_Content__c, new Set<Id>());
                    }
                }
            }
        }
        
        if (refContentIds.size() > 0) {
            
            for (Content_Attribute__c tempObj : WithoutSharingHelperController.getContentAttributesForUpdateRBI2(refContentIds)) {
                contentAttribMap.get(tempObj.Reference_Content__c).add(tempObj.Attribute__c);
            }
        }
        
        if (attAssociatedToAccount != null && attAssociatedToAccount.size() > 0) {
            
            for (Id accId : attAssociatedToAccount.keySet()) {
                
                for (Id attId : attAssociatedToAccount.get(accId)) {
                    
                    if (accountContentMap.get(accId) != null) {
                        
                        for (Id contentId : accountContentMap.get(accId)) {
                            
                            if (contentAttribMap.get(contentId) != null
                                        && !contentAttribMap.get(contentId).contains(attId)
                                        && !preventDuplicacy.contains(contentId + ',' + accId + ',' + attId)) {
                                
                                tempContentObj = new Content_Attribute__c();
                                tempContentObj.Reference_Content__c = contentId;
                                tempContentObj.Attribute__c = attId;
                                tempContentObj.Account__c = accId;
                                preventDuplicacy.add(contentId + ',' + accId + ',' + attId);
                                newContentAttrib.add(tempContentObj);
                            }
                        }
                    }
                }
            }
        }
        
        if (newContentAttrib.size() > 0) {
            ConstantsController.fromAccountToContent = true;
            WithoutSharingHelperController.upsertContentAtt(newContentAttrib);
        }
    }
    
    /**
     * Method to add Attribute on Contact
     */
    static void addAttributesOnContact(List<Reference_Basic_Information__c> newcontactTypeRBIList,
                                            List<Account> accounts,Map<Id,List<Account_Attribute__c>> accToAtt) {
        
        Map<Id, Set<Id>> activeAccountContacts = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> accountAttributes = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> contactAttribsAssociated = new Map<Id, Set<Id>>();
        Map<Id, Reference_Basic_Information__c> accountRBI = new Map<Id, Reference_Basic_Information__c>();
        List<Contact_Attribute__c> newContactAttributes = new List<Contact_Attribute__c>();
        Contact_Attribute__c tempObj;
        
        for (Reference_Basic_Information__c rbi : newcontactTypeRBIList) {
            
            if (!activeAccountContacts.containsKey(rbi.Account__c)) {
                activeAccountContacts.put(rbi.Account__c, new Set<Id>());
            }
            activeAccountContacts.get(rbi.Account__c).add(rbi.Contact__c);
            accountAttributes.put(rbi.Account__c, new Set<Id>());
            contactAttribsAssociated.put(rbi.Contact__c, new Set<Id>());
        }
        
        if (contactAttribsAssociated != null && contactAttribsAssociated.size() > 0) {
            
            for (Contact_Attribute__c conAtt : WithoutSharingHelperController.getContactAttribute3(contactAttribsAssociated.keySet())) {
                contactAttribsAssociated.get(conAtt.Contact__c).add(conAtt.Attribute__c);
            }
        }
        
        if (activeAccountContacts != null && activeAccountContacts.size() > 0) {
            
            /* FOR SOQL 101 */
            for (Account acc : accounts) {
                
                if (activeAccountContacts.containsKey(acc.Id)) {
                    
                    for (Reference_Basic_Information__c rbi : acc.Reference_Basic_Informations__r) {
                        
                        if (rbi.Contact__c == null) {
                            accountRBI.put(acc.Id, rbi);
                        }
                    }
                    
                    if (accToAtt.containsKey(acc.Id)) {
                        for (Account_Attribute__c accAtt : accToAtt.get(acc.Id)) {    
                            if (accAtt.Reference_Content__c == null && accAtt.Contact__c == null && accAtt.Inheritable__c) {
                                
                                if (!accountAttributes.containsKey(accAtt.Account__c)) {
                                    accountAttributes.put(accAtt.Account__c, new Set<Id>());
                                }
                                accountAttributes.get(accAtt.Account__c).add(accAtt.Attribute__c);
                            }
                        }
                    }
                }
            }
            
            for (Id accId : activeAccountContacts.keySet()) {
                
                if (accountRBI.containsKey(accId) && accountRBI.get(accId).Is_Referenceable__c) {
                    
                    for (Id contactId : activeAccountContacts.get(accId)) {
                        
                        for (Id attId : accountAttributes.get(accId)) {
                            
                            if (!contactAttribsAssociated.get(contactId).contains(attId)) {
                                tempObj = new Contact_Attribute__c();
                                tempObj.Attribute__c = attId;
                                tempobj.Contact__c = contactId;
                                tempObj.From_Account__c = true;
                                tempObj.Account__c = accId;
                                newContactAttributes.add(tempObj);
                            }
                        }
                    }
                }
            }
        }
        
        if (newContactAttributes.size() > 0) {
            ConstantsController.fromaccount = true;
            WithoutSharingHelperController.upsertContactAttributes(newContactAttributes);
        }
    }
    
    /**
     * Method to add Attribute on Contact when shared contact is enabled
     */
    static void addAttributesOnContactSharedContact(List<Reference_Basic_Information__c> newcontactTypeRBIList,
                                                        List<Account > accounts,
                                                        Map<Id, Set<Id>> accountContactMap) {
        
        Map<Id, Set<Id>> accountAttributes = new Map<Id, Set<Id>>();
        Map<Id, Set<String >> contactAttribsAssociated = new Map<Id, Set<String>>();
        Map<Id, Reference_Basic_Information__c > accountRBI = new Map<Id, Reference_Basic_Information__c>();
        List<Contact_Attribute__c> newContactAttributes = new List<Contact_Attribute__c>();
        Contact_Attribute__c tempObj;
        Map<Id, Reference_Basic_Information__c> contactRBIMap = new Map<Id, Reference_Basic_Information__c>();
        
        for (Reference_Basic_Information__c rbi : newcontactTypeRBIList) {
            contactRBIMap.put(rbi.Contact__c, rbi);
            
            if (!accountContactMap.containsKey(rbi.Account__c)) {
                accountContactMap.put(rbi.Account__c, new Set<Id>());
            }
            
            if (accountContactMap.containsKey(rbi.Account__c)
                        && !accountContactMap.get(rbi.Account__c).contains(rbi.Contact__c)) {
                accountContactMap.get(rbi.Account__c).add(rbi.Contact__c);
            }
            accountAttributes.put(rbi.Account__c, new Set<Id>());
            contactAttribsAssociated.put(rbi.Contact__c, new Set<String>());
        }
        
        if (contactAttribsAssociated != null && contactAttribsAssociated.size() > 0) {
            
            for (Contact_Attribute__c conAtt : WithoutSharingHelperController.getContactAttribute3(contactAttribsAssociated.keySet())) {
                
                if (conAtt.from_Account__c) {
                    contactAttribsAssociated.get(conAtt.Contact__c).add(String.valueOf(conAtt.Attribute__c) + '' +
                                                                            (conAtt.Account__c != null
                                                                                    ? String.valueOf(conAtt.Account__c) : ''));
                }
            }
        }
        
        if (accountContactMap != null && accountContactMap.size() > 0) {
            
            /* FOR SOQL 101 */
            for (Account acc : accounts) {
                
                if (accountContactMap.containsKey(acc.Id)) {
                    
                    for (Reference_Basic_Information__c rbi : acc.Reference_Basic_Informations__r) {
                        
                        if (rbi.Contact__c == null) {
                            accountRBI.put(acc.Id, rbi);
                        }
                    }
                    
                    for (Account_Attribute__c accAtt : acc.Account_Attributes__r) {
                        
                        if (accAtt.Reference_Content__c == null && accAtt.Contact__c == null && accAtt.Inheritable__c) {
                            
                            if (!accountAttributes.containsKey(accAtt.Account__c)) {
                                accountAttributes.put(accAtt.Account__c, new Set<Id>());
                            }
                            accountAttributes.get(accAtt.Account__c).add(accAtt.Attribute__c);
                        }
                    }
                }
            }
            
            for (Id accId : accountContactMap.keySet()) {
                
                if (accountRBI.containsKey(accId) && accountRBI.get(accId).Is_Referenceable__c) {
                    
                    for (Id contactId : accountContactMap.get(accId)) {
                        boolean inheritAttFromAllAcc = (contactRBIMap.containsKey(contactId)
                                                            && contactRBIMap.get(contactId).Inherit_Attributes_from_All_Accounts__c
                                                                ? true
                                                                : (contactRBIMap.containsKey(contactId) && contactRBIMap.get(contactId).Inherit_Attributes_from_Primary_Account__c
                                                                        ? false : (cs.Inherit_Attributes_from_All_Accounts__c)));
                        
                        if (accountAttributes != null
                                && accountAttributes.containsKey(accId)
                                && (inheritAttFromAllAcc
                                        ? true : (contactRBIMap.containsKey(contactId) ? contactRBIMap.get(contactId).Account__c == accId : false))) {
                            
                            for (Id attId : accountAttributes.get(accId)) {
                                
                                if (contactAttribsAssociated != null
                                            && contactAttribsAssociated.containsKey(contactId)
                                            && !contactAttribsAssociated.get(contactId).contains(attId + '' + (accId != null ? accId : ''))) {
                                    
                                    tempObj = new Contact_Attribute__c();
                                    tempObj.Attribute__c = attId;
                                    tempobj.Contact__c = contactId;
                                    tempObj.From_Account__c = true;
                                    tempobj.Account__c = accId;
                                    newContactAttributes.add(tempObj);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if (newContactAttributes.size() > 0) {
            ConstantsController.fromaccount = true;
            WithoutSharingHelperController.upsertContactAttributes(newContactAttributes);
        }
    }
    
    /**
     * Method called on before delete of Reference Profile
     */
    public static void onBeforeDelete(List<Reference_Basic_Information__c> oldRBIList) {
        List<Reference_Basic_Information__c> accountTypeRBIList= new List<Reference_Basic_Information__c>();
        List<Reference_Basic_Information__c> contactTypeRBIList= new List<Reference_Basic_Information__c>();
        
        for (Reference_Basic_Information__c rbi : oldRBIList) {
            
            if (rbi.Contact__c == null) {
                accountTypeRBIList.add(rbi);
            } else {
                contactTypeRBIList.add(rbi);
            }
        }
        
        if (contactTypeRBIList.size() > 0 && !ConstantsController.isCallFromBatchRemoveDuplicateRBI) {
            Set<Id> contactIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            
            for (Reference_Basic_Information__c rbi : contactTypeRBIList) {
                contactIds.add(rbi.Contact__c);
                accountIds.add(rbi.Account__c);
            }
            removeReferenceability(contactIds);
            deleteAttributeFromAccount(contactIds, accountIds);
        }
    }
    
    /**
     * Method to remove Referenceability
     */
    static void removeReferenceability(Set<Id> contactIds) {
        try {
            List<Referenceability__c> deleteReferenceability = new List<Referenceability__c>([SELECT Id FROM Referenceability__c
                                                                                            WHERE Contact__c IN :contactIds]);
            
            if (deleteReferenceability.size() > 0) {
                delete deleteReferenceability;
            }
        } catch (Exception e) {
            throw e;
        }
    }
    
    /**
     * Method called on before update of Reference Profile
     */
    public static void onBeforeUpdate(List<Reference_Basic_Information__c> newRBIList,
                                        Map<Id, Reference_Basic_Information__c> oldRBIMap,
                                        Map<Id, Reference_Basic_Information__c> newRBIMap) {
        
        List<Reference_Basic_Information__c> accountTypeRBIList= new List<Reference_Basic_Information__c>();
        List<Reference_Basic_Information__c> contactTypeRBIList= new List<Reference_Basic_Information__c>();
        List<Reference_Basic_Information__c> RBIList= new List<Reference_Basic_Information__c>();
        Set<Id> contactAccountIds = new Set<Id>();
        Boolean isLifetimePointsNull = false;
        //for Influitive integration 
        Set<Id> accountIds = new Set<Id>();
        
        for (Reference_Basic_Information__c rbi : newRBIList) {
        
            // REF-1290 Validation not to Add/remove Contact in RBI
            if (!ConstantsController.isRbiUpdatedFromConTrigger && (oldRBIMap.get(rbi.Id).Contact__c != newRBIMap.get(rbi.Id).Contact__c || oldRBIMap.get(rbi.Id).Account__c != newRBIMap.get(rbi.Id).Account__c)) {
            ConstantsController.isRbiUpdatedFromConTrigger = false;
                rbi.addError(system.Label.Restrict_Account_Contact_Update_on_RBI);
              } 
              
            //validation for generic account on Contact Reference Profile ticket #578
            if (rbi.Generic_Account__c && rbi.Contact__c != null) {
                rbi.addError(system.Label.Check_for_Generic_account_on_Contact);
            }
            
            //validation for generic account ticket #578
            if (rbi.Generic_Account__c && (rbi.Is_Referenceable__c || rbi.Reference_Program_Candidate__c)) {
                rbi.addError(system.Label.Check_for_Generic_account);
            }
                
            //validation for shared contact settings
            if (!cs.Shared_Contacts__c) {
                
                if (rbi.Roll_up_Attributes_to_All_Accounts__c != oldRBIMap.get(rbi.Id).Roll_up_Attributes_to_All_Accounts__c
                            || rbi.Roll_up_Attributes_to_Primary_Account__c != oldRBIMap.get(rbi.Id).Roll_up_Attributes_to_Primary_Account__c
                            || rbi.Roll_up_Referenceability_to_All_Accounts__c != oldRBIMap.get(rbi.Id).Roll_up_Referenceability_to_All_Accounts__c
                            || rbi.Roll_up_Referenceability_to_Primary_Acc__c != oldRBIMap.get(rbi.Id).Roll_up_Referenceability_to_Primary_Acc__c
                            || rbi.Inherit_Attributes_from_All_Accounts__c != oldRBIMap.get(rbi.Id).Inherit_Attributes_from_All_Accounts__c
                            || rbi.Inherit_Attributes_from_Primary_Account__c != oldRBIMap.get(rbi.Id).Inherit_Attributes_from_Primary_Account__c) {
                    
                    rbi.addError(system.Label.Shared_Contact_check_setting_RBI);
                }
            } else {
                
                if ((rbi.Roll_up_Attributes_to_All_Accounts__c
                                && rbi.Roll_up_Attributes_to_Primary_Account__c)
                            || (rbi.Roll_up_Referenceability_to_All_Accounts__c
                                && rbi.Roll_up_Referenceability_to_Primary_Acc__c)
                            || (rbi.Inherit_Attributes_from_All_Accounts__c
                                && rbi.Inherit_Attributes_from_Primary_Account__c)) {
                    
                    rbi.addError(system.Label.Roll_up_Inherit_check);
                }
            }
            // re #890- Added invative reason in case of status Inactive
            if (oldRBIMap.get(rbi.Id).Referenceability_Status__c != newRBIMap.get(rbi.Id).Referenceability_Status__c 
                                && rbi.Referenceability_Status__c == 'Inactive' && String.isBlank(rbi.inactive_reason__c)) {
                rbi.inactive_reason__c = 'Reference Profile Set to Inactive when initially created.';
            } 
            
            if (rbi.Contact__c == null) {
                accountTypeRBIList.add(rbi);
            } else {
                contactTypeRBIList.add(rbi);
            }
            
            if (oldRBIMap.get(rbi.Id).Account__c != newRBIMap.get(rbi.Id).Account__c
                        || oldRBIMap.get(rbi.Id).Contact__c != newRBIMap.get(rbi.Id).Contact__c) {
                RBIList.add(rbi);
            }
            
            if (rbi.Is_Referenceable__c) {
                
                if (rbi.Joined_Reference_Program__c == null
                            && (rbi.Referenceability_Status__c == ConstantsController.ACTIVE
                                || rbi.Referenceability_Status__c == ConstantsController.CAUTION)) {
                    
                    rbi.Joined_Reference_Program__c = system.today();
                }
                
                if (rbi.Referenceability_Status__c == ConstantsController.ACTIVE
                            || rbi.Referenceability_Status__c == ConstantsController.CAUTION) {
                    
                    if (rbi.Lifetime_Points__c == null || rbi.Lifetime_Points__c == 0) {
                        isLifetimePointsNull = true;
                    }
                    
                    //for Influitive integration 
                    if (rbi.Contact__c == null) {
                        accountIds.add(rbi.Account__c);
                    } else {
                        contactAccountIds.add(rbi.Account__c);
                    }
                }
                
                // Updated code for R13.69, Date : 09/09/2015, Tejpal
                if (rbi.Last_Refresh_Date__c == null
                            && (rbi.Referenceability_Status__c == ConstantsController.ACTIVE
                                || rbi.Referenceability_Status__c == ConstantsController.CAUTION)) {
                    rbi.Last_Refresh_Date__c = Datetime.now();
                }
            } else {
                rbi.RUL_Period__c = null;
                rbi.RUL_Activities_will_do__c = null;
            }
        }
        
        //for Influitive integration 
        if (cs != null && ConstantsController.isNotFromRewardTrigger) {
            
            if ((cs.Is_Influitive_Integration_Enabled__c != null
                            && cs.Is_Influitive_Integration_Enabled__c)
                        || isLifetimePointsNull) {
                
                List<Reward__c> rewardList= WithoutSharingHelperController.getRewards(accountIds, contactAccountIds);
                Map<String, Decimal> lifeTimePointsMap = new Map<String, Decimal>();
                Map<String, Decimal> availableTimePointsMap = new Map<String, Decimal>();
                Map<String, Decimal> lifeTimePointsContactMap = new Map<String, Decimal>();
                
                for (Reward__c reward : rewardList) {
                    
                    if (accountIds.contains(reward.Account__c)) {
                        
                        if (!lifeTimePointsMap.containsKey(reward.Account__c)) {
                            lifeTimePointsMap.put(reward.Account__c, 0);
                            availableTimePointsMap.put(reward.Account__c, 0);
                        }
                        Decimal totalAccountPoints = lifeTimePointsMap.get(reward.Account__c) + reward.Amount__c;
                        Decimal totalAvailablePoints = availableTimePointsMap.get(reward.Account__c) + reward.Available_Points__c;
                        lifeTimePointsMap.put(reward.Account__c, totalAccountPoints);
                        availableTimePointsMap.put(reward.Account__c, totalAvailablePoints);
                    }
                    
                    if (contactAccountIds.contains(reward.Account__c) && reward.Contact__c != null) {
                        
                        if (!lifeTimePointsContactMap.containsKey(reward.Contact__c)) {
                            lifeTimePointsContactMap.put(reward.Contact__c, 0);
                        }
                        Decimal totalContactPoints = lifeTimePointsContactMap.get(reward.Contact__c) + reward.Amount__c;
                        lifeTimePointsContactMap.put(reward.Contact__c, totalContactPoints);
                    }
                }
                
                for (Reference_Basic_Information__c rbi : newRBIList) {
                    
                    if (rbi.Contact__c == null
                                && rbi.Account__c != null
                                && lifeTimePointsMap != null
                                && lifeTimePointsMap.containsKey(rbi.Account__c )) {
                        
                        rbi.Lifetime_Points__c = lifeTimePointsMap.get(rbi.Account__c);
                        rbi.Current_Available_Balance_Points__c = availableTimePointsMap.get(rbi.Account__c);
                    } else if ((rbi.Lifetime_Points__c == null
                                        || rbi.Lifetime_Points__c == 0)
                                    && rbi.Contact__c != null
                                    && rbi.Account__c != null
                                    && lifeTimePointsContactMap != null
                                    && lifeTimePointsContactMap.containsKey(rbi.Contact__c)) {
                        
                        rbi.Lifetime_Points__c = lifeTimePointsContactMap.get(rbi.Contact__c);
                    }
                }
            }
        }
        checkDuplicateRBI(RBIList, newRBIMap, oldRBIMap);
        updateAccountRBIRulSettings(accountTypeRBIList, oldRBIMap, newRBIMap);
        updateContactRulSettings(contactTypeRBIList, oldRBIMap, newRBIMap);
    }
    
    static Set<Id> prevRulAccountIds;
    
    /**
     * Method to update Account RUL setting
     */
    private static void updateAccountRBIRulSettings(List<Reference_Basic_Information__c> accountTypeRBIList,
                                                        Map<Id, Reference_Basic_Information__c> oldMAp,
                                                        Map<Id, Reference_Basic_Information__c> newMap) {
        
        Set<Id > accountIds = new Set<Id>();
        Set<String> rulAccountIds = new Set<String>();
        List<Reference_Request_Account__c> rrasList= new List<Reference_Request_Account__c>();
        Map<Id, Reference_Basic_Information__c> accountMap = new Map<Id, Reference_Basic_Information__c>();
        
        for (Reference_Basic_Information__c acc : accountTypeRBIList) {
            
            if (newMap.get(acc.Id).Reference_Program_Candidate__c && newMap.get(acc.Id).Is_Referenceable__c) {
                newMap.get(acc.Id).addError(ConstantsController.CANDIDATE_MEMBER_CHECK);
            }
            accountMap.put(acc.Account__C, acc);
            rulAccountIds.add(acc.Account__c);
        }
        Map<Id, List<Reference_Request_Account__c>> accountRRAMap = new Map<Id, List<Reference_Request_Account__c>>();
        boolean noRecordsChanged = true;
        
        if (ConstantsController.accountIdsInRBI.size() == 0) {
            noRecordsChanged = false;
        } else {
            
            for (String accountId : ConstantsController.accountIdsInRBI) {
                
                if (!rulAccountIds.contains(accountId)) {
                    noRecordsChanged = false;
                    break;
                }
            }
        }
        
        if (rulAccountIds.size() > 0) {
            
            if (noRecordsChanged) {
                
                for (Reference_Request_Account__c tempObj : ConstantsController.RRAInRBI) {
                    
                    if (accountMap.containsKey(tempObj.Account__c) && tempObj.Activity_Date__c != null && (tempObj.Activity_Date__c).daysBetween(date.today()) <= cs.RUL_Period__c) {
                        
                        if (!accountRRAMap.containsKey(tempObj.Account__c)) {
                            accountRRAMap.put(tempObj.Account__c, new List<Reference_Request_Account__c>());
                        }
                        accountRRAMap.get(tempObj.Account__c).add(tempObj);
                    }
                    rraslist.add(tempObj);
                }
            } else {
                ConstantsController.accountIdsInRBI = new Set<String>();
                ConstantsController.RRAInRBI = new List<Reference_Request_Account__c>();
                ConstantsController.accountIdsInRBI.addAll(rulAccountIds);
                
                for (Reference_Request_Account__c tempObj : WithoutSharingHelperController.getRRAccountRequestsOfAccount(rulAccountIds)) {
                    ConstantsController.RRAInRBI.add(tempObj);
                    
                    if (accountMap.containsKey(tempObj.Account__c)
                            && tempObj.Activity_Date__c != null
                            && (tempObj.Activity_Date__c).daysBetween(date.today()) <= cs.RUL_Period__c) {
                        
                        if (!accountRRAMap.containsKey(tempObj.Account__c)) {
                            accountRRAMap.put(tempObj.Account__c, new List<Reference_Request_Account__c>());
                        }
                        accountRRAMap.get(tempObj.Account__c).add(tempObj);
                    }
                    rraslist.add(tempObj);
                }
            }
        }
        
        if (cs != null) {
            
            for (Reference_Basic_Information__c acc : accountTypeRBIList) {
                
                if (newMap.get(acc.Id).Is_Referenceable__c == true
                        && oldMap.get(acc.Id).Is_Referenceable__c != newMap.get(acc.Id).Is_Referenceable__c) {
                    
                    if (newMap.get(acc.Id).RUL_Period__c == null) {
                        newMap.get(acc.Id).RUL_Period__c = cs.RUL_Period__c;
                    }
                    
                    if (newMap.get(acc.Id).RUL_Activities_will_do__c == null) {
                        newMap.get(acc.Id).RUL_Activities_will_do__c = cs.RUL_Activities__c;
                    }
                }
            }
        }
        
        for (Reference_Basic_Information__c acc : accountTypeRBIList) {
            
            if (oldMap.get(acc.Id).RUL_Period__c != newMap.get(acc.Id).RUL_Period__c
                    && newMap.get(acc.Id).RUL_Period__c != null) {
                
                if (!newMap.get(acc.Id).Is_Referenceable__c && !newMap.get(acc.Id).Reference_Program_Candidate__c) {
                    newMap.get(acc.Id).Is_Referenceable__c = true;
                    newMap.get(acc.Id).Referenceability_Status__c = ConstantsController.INACTIVE;
                }
                accountIds.add(newMap.get(acc.Id).Account__c);
            }
            
            if (oldMap.get(acc.Id).RUL_Activities_will_do__c != newMap.get(acc.Id).RUL_Activities_will_do__c
                        && newMap.get(acc.Id).RUL_Activities_will_do__c != null) {
                
                if (!newMap.get(acc.Id).Is_Referenceable__c && !newMap.get(acc.Id).Reference_Program_Candidate__c) {
                    newMap.get(acc.Id).Is_Referenceable__c = true;
                    newMap.get(acc.Id).Referenceability_Status__c = ConstantsController.INACTIVE;
                }
                
                if (newMap.get(acc.Id).RUL_Activities_will_do__c != null
                            && newMap.get(acc.Id).RUL_Activities_used__c >= newMap.get(acc.Id).RUL_Activities_will_do__c
                            && newMap.get(acc.Id).RUL_Limit_Reached__c == false
                            && newMap.get(acc.Id).Account_Level_RUL__c) {
                    
                    newMap.get(acc.Id).RUL_Limit_Reached__c = true;
                    
                    if (newMap.get(acc.Id).RUL_Period__c != null
                                && newMap.get(acc.Id).RUL_Last_Activity_Date__c != null) {
                        newMap.get(acc.Id).RUL_Date_Available__c = date.valueOf(newMap.get(acc.Id).RUL_Last_Activity_Date__c.addDays(integer.valueOf(newMap.get(acc.Id).RUL_Period__c)));
                    }
                }
                
                if ((newMap.get(acc.Id).RUL_Activities_will_do__c == null
                                || newMap.get(acc.Id).RUL_Activities_will_do__c == 0)
                            && newMap.get(acc.Id).RUL_Limit_Reached__c == true
                            && newMap.get(acc.Id).Account_Level_RUL__c) {
                    
                    newMap.get(acc.Id).RUL_Limit_Reached__c = false;
                    newMap.get(acc.Id).RUL_Date_Available__c = null;
                }
                
                if (newMap.get(acc.Id).RUL_Activities_will_do__c != null
                            && newMap.get(acc.Id).RUL_Activities_used__c < newMap.get(acc.Id).RUL_Activities_will_do__c
                            && newMap.get(acc.Id).Account_Level_RUL__c) {
                    
                    newMap.get(acc.Id).RUL_Limit_Reached__c = false;
                    newMap.get(acc.Id).RUL_Date_Available__c = null;
                }
                
                if (newMap.get(acc.Id).RUL_Limit_Reached__c == true) {
                    
                    if (newMap.get(acc.Id).RUL_Period__c != null
                                && newMap.get(acc.Id).RUL_Last_Activity_Date__c != null) {
                        
                        newMap.get(acc.Id).RUL_Date_Available__c = date.valueOf(newMap.get(acc.Id).RUL_Last_Activity_Date__c.addDays(integer.valueOf(newMap.get(acc.Id).RUL_Period__c)));
                    }
                }
            }
            
            if (oldMap.get(acc.Id).Account_Level_RUL__c != newMap.get(acc.Id).Account_Level_RUL__c) {
                
                if (!newMap.get(acc.Id).Is_Referenceable__c) {
                    newMap.get(acc.Id).Is_Referenceable__c = true;
                    newMap.get(acc.Id).Referenceability_Status__c = ConstantsController.INACTIVE;
                }
                
                if (newMap.get(acc.Id).Account_Level_RUL__c == true) {
                    
                    if (newMap.get(acc.Id).RUL_Period__c == null) {
                        newMap.get(acc.Id).RUL_Period__c = cs.RUL_Period__c;
                        newMap.get(acc.Id).RUL_Activities_will_do__c = cs.RUL_Activities__c;
                    }
                    
                    if (accountRRAMap.containsKey(acc.Account__C)) {
                        newMap.get(acc.Id).RUL_Activities_used__c = accountRRAMap.get(acc.Account__C).size();
                    } else {
                        newMap.get(acc.Id).RUL_Activities_used__c = 0;
                    }

                    if (newMap.get(acc.Id).RUL_Activities_used__c >= newMap.get(acc.Id).RUL_Activities_will_do__c) {
                        newMap.get(acc.Id).RUL_Limit_Reached__c = true;
                        
                        if (newMap.get(acc.Id).RUL_Last_Activity_Date__c != null
                                    && newMap.get(acc.Id).RUL_Period__c != null) {
                            
                            newMap.get(acc.Id).RUL_Date_Available__c = date.valueOf(newMap.get(acc.Id).RUL_Last_Activity_Date__c.addDays(integer.valueOf(newMap.get(acc.Id).RUL_Period__c)));
                        }
                    } else {
                        newMap.get(acc.Id).RUL_Limit_Reached__c = false;
                        newMap.get(acc.Id).RUL_Date_Available__c = null;
                    }

                }
                if (newMap.get(acc.Id).Account_Level_RUL__c == false) {
                    
                    if (newMap.get(acc.Id).Is_Contact_Limit_Reached__c == true) {
                        newMap.get(acc.Id).RUL_Limit_Reached__c = true;
                        
                        if (newMap.get(acc.Id).RUL_Last_Activity_Date__c != null
                                    && newMap.get(acc.Id).RUL_Period__c != null) {
                            
                            newMap.get(acc.Id).RUL_Date_Available__c = date.valueOf(newMap.get(acc.Id).RUL_Last_Activity_Date__c.addDays(integer.valueOf(newMap.get(acc.Id).RUL_Period__c)));
                        }
                    } else {
                        newMap.get(acc.Id).RUL_Limit_Reached__c = false;
                        newMap.get(acc.Id).RUL_Date_Available__c = null;
                    }
                }
            } else if (oldMap.get(acc.Id).RUL_Activities_used__c != newMap.get(acc.Id).RUL_Activities_used__c && newMap.get(acc.Id).Account_Level_RUL__c == true) {
                
                if (newMap.get(acc.Id).RUL_Activities_used__c >= newMap.get(acc.Id).RUL_Activities_will_do__c) {
                    newMap.get(acc.Id).RUL_Limit_Reached__c = true;
                    
                    if (newMap.get(acc.Id).RUL_Last_Activity_Date__c != null
                                && newMap.get(acc.Id).RUL_Period__c != null) {
                        
                        newMap.get(acc.Id).RUL_Date_Available__c = date.valueOf(newMap.get(acc.Id).RUL_Last_Activity_Date__c.addDays(integer.valueOf(newMap.get(acc.Id).RUL_Period__c)));
                    }
                } else {
                    newMap.get(acc.Id).RUL_Limit_Reached__c = false;
                    newMap.get(acc.Id).RUL_Date_Available__c = null;
                }
            } else if (newMap.get(acc.Id).Account_Level_RUL__c == false && newMap.get(acc.Id).Is_Contact_Limit_Reached__c != oldMap.get(acc.Id).Is_Contact_Limit_Reached__c) {
                
                if (newMap.get(acc.Id).Is_Contact_Limit_Reached__c == true) {
                    newMap.get(acc.Id).RUL_Limit_Reached__c = true;
                    
                    if (newMap.get(acc.Id).RUL_Last_Activity_Date__c != null
                                && newMap.get(acc.Id).RUL_Period__c != null) {
                        
                        newMap.get(acc.Id).RUL_Date_Available__c = date.valueOf(newMap.get(acc.Id).RUL_Last_Activity_Date__c.addDays(integer.valueOf(newMap.get(acc.Id).RUL_Period__c)));
                    }
                } else {
                    newMap.get(acc.Id).RUL_Limit_Reached__c = false;
                    newMap.get(acc.Id).RUL_Date_Available__c = null;
                }
            }
        }
        
        if (accountIds.size() > 0) {
            updateAccountOnRULPeriodChange(accountIds, accountTypeRBIList, rraslist);
        }
    }
    
    /**
     * Method to update Account on change of RUL Period
     */
    static void updateAccountOnRULPeriodChange(Set<Id> accountIds,
                                                List<Reference_Basic_Information__c> accountTypeRBIList,
                                                List<Reference_Request_Account__c> rraslist) {
        
        Date lastActivityDate;
        Map<Id, Reference_Basic_Information__c> accountMap = new Map<Id, Reference_Basic_Information__c>();
        
        for (Reference_Basic_Information__c acc : accountTypeRBIList) {
            
            if (accountIds.contains(acc.Account__C) && acc.RUL_Period__c != null) {
                lastActivityDate = date.today() - integer.valueOf(acc.RUL_Period__c);
            }
            accountMap.put(acc.Account__c, acc);
        }
        Map<Id, List<Reference_Request_Account__c>> accountRRAMap = new Map<Id, List<Reference_Request_Account__c>>();
        
        for (Reference_Request_Account__c tempObj : rraslist) {
            
            if (accountMap.containsKey(tempObj.Account__c)
                        && tempObj.Activity_Date__c != null
                        && tempObj.Activity_Date__c.daysBetween(date.today()) <= accountMap.get(tempObj.Account__c).RUL_Period__c) {
                
                if (!accountRRAMap.containsKey(tempObj.Account__c)) {
                    accountRRAMap.put(tempObj.Account__c, new List<Reference_Request_Account__c>());
                }
                accountRRAMap.get(tempObj.Account__c).add(tempObj);
            }
        }
        
        for (Reference_Basic_Information__c acc : accountTypeRBIList) {
            
            if (accountIds.contains(acc.Account__C)) {
                
                if (accountRRAMap.get(acc.Account__C) != null
                            && (acc.RUL_Period__c != null
                            && acc.RUL_Period__c != 0)) {
                    acc.RUL_Activities_used__c = accountRRAMap.get(acc.Account__C).size();
                } else {
                    acc.RUL_Activities_used__c = 0;
                }
                
                if (acc.RUL_Activities_used__c != 0 && acc.RUL_Activities_used__c >= acc.RUL_Activities_will_do__c) {
                    
                    if (acc.Account_Level_RUL__c) {
                        acc.RUL_Limit_Reached__c = true;
                    }
                    
                    if (acc.RUL_Last_Activity_Date__c != null && acc.RUL_Period__c != null) {
                        acc.RUL_Date_Available__c = date.valueOf(acc.RUL_Last_Activity_Date__c.addDays(integer.valueOf(acc.RUL_Period__c)));
                    }
                }
                
                if (acc.RUL_Activities_used__c != 0
                                && acc.RUL_Activities_used__c < acc.RUL_Activities_will_do__c
                                && acc.Account_Level_RUL__c) {
                    acc.RUL_Limit_Reached__c = false;
                    acc.RUL_Date_Available__c = null;
                }
                
                if (acc.RUL_Activities_used__c == 0 && acc.Account_Level_RUL__c) {
                    acc.RUL_Limit_Reached__c = false;
                    acc.RUL_Date_Available__c = null;
                }
            }
        }
    }
    
    /**
     * Method to update Contact RUL Settings
     */
    private static void updateContactRulSettings(List<Reference_Basic_Information__c> contactTypeRBIList,
                                                Map<Id, Reference_Basic_Information__c> oldMap,
                                                Map<Id, Reference_Basic_Information__c> newMap) {
        
        try {
            Set<Id> contactIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            
            for (Reference_Basic_Information__c rbi : contactTypeRBIList) {
                accountIds.add(rbi.Account__c);
            }
            
            for (Reference_Basic_Information__c rbi : contactTypeRBIList) {
                
                if (newMap.get(rbi.Id).Reference_Program_Candidate__c && newMap.get(rbi.Id).Is_Referenceable__c) {
                    rbi.addError(ConstantsController.CANDIDATE_MEMBER_CHECK);
                }
            }
            
            if (cs != null) {
                
                for (Reference_Basic_Information__c rbi : contactTypeRBIList) {
                    
                    if (newMap.get(rbi.Id).Is_Referenceable__c
                                && oldMap.get(rbi.Id).Is_Referenceable__c != newMap.get(rbi.Id).Is_Referenceable__c) {
                        
                        if (newMap.get(rbi.Id).RUL_Period__c == null) {
                            newMap.get(rbi.Id).RUL_Period__c = cs.RUL_Period_Contact__c;
                        }
                        
                        if (newMap.get(rbi.Id).RUL_Activities_will_do__c == null) {
                            newMap.get(rbi.Id).RUL_Activities_will_do__c = cs.RUL_Activities_Contact__c;
                        }
                    }
                }
            }
            
            for (Reference_Basic_Information__c rbi : contactTypeRBIList) {
                
                if (oldMap.get(rbi.Id).RUL_Period__c != newMap.get(rbi.Id).RUL_Period__c
                            && newMap.get(rbi.Id).RUL_Period__c != null) {
                    
                    if (!newMap.get(rbi.Id).Is_Referenceable__c && !newMap.get(rbi.Id).Reference_Program_Candidate__c) {
                        newMap.get(rbi.Id).Is_Referenceable__c = true;
                        newMap.get(rbi.Id).Referenceability_Status__c = ConstantsController.INACTIVE;
                    }
                    contactIds.add(newMap.get(rbi.Id).Contact__c);
                }
                
                if (oldMap.get(rbi.Id).RUL_Activities_will_do__c != newMap.get(rbi.Id).RUL_Activities_will_do__c && newMap.get(rbi.Id).RUL_Activities_will_do__c != null) {
                    
                    if (!newMap.get(rbi.Id).Is_Referenceable__c && !newMap.get(rbi.Id).Reference_Program_Candidate__c) {
                        newMap.get(rbi.Id).Is_Referenceable__c = true;
                        newMap.get(rbi.Id).Referenceability_Status__c = ConstantsController.INACTIVE;
                    }
                    
                    if (newMap.get(rbi.Id).RUL_Activities_will_do__c != null
                                && newMap.get(rbi.Id).RUL_Activities_used__c >= newMap.get(rbi.Id).RUL_Activities_will_do__c
                                && newMap.get(rbi.Id).RUL_Limit_Reached__c == false) {
                        
                        newMap.get(rbi.Id).RUL_Limit_Reached__c = true;
                        
                        if (newMap.get(rbi.Id).RUL_Last_Activity_Date__c != null
                                && newMap.get(rbi.Id).RUL_Period__c != null) {
                            newMap.get(rbi.Id).RUL_Date_Available__c = date.valueOf(newMap.get(rbi.Id).RUL_Last_Activity_Date__c.addDays(integer.valueOf(newMap.get(rbi.Id).RUL_Period__c)));
                        }
                    }
                    
                    if ((newMap.get(rbi.Id).RUL_Activities_will_do__c == null
                                    || newMap.get(rbi.Id).RUL_Activities_will_do__c == 0)
                                && newMap.get(rbi.Id).RUL_Limit_Reached__c == true) {
                        
                        newMap.get(rbi.Id).RUL_Limit_Reached__c = false;
                        newMap.get(rbi.Id).RUL_Date_Available__c = null;
                    }
                    
                    if (newMap.get(rbi.Id).RUL_Activities_will_do__c != null
                                && newMap.get(rbi.Id).RUL_Activities_used__c < newMap.get(rbi.Id).RUL_Activities_will_do__c) {
                        
                        newMap.get(rbi.Id).RUL_Limit_Reached__c = false;
                        newMap.get(rbi.Id).RUL_Date_Available__c = null;
                    }
                    
                    if (newMap.get(rbi.Id).RUL_Limit_Reached__c == true) {
                        
                        if (newMap.get(rbi.Id).RUL_Last_Activity_Date__c != null
                                    && newMap.get(rbi.Id).RUL_Period__c != null) {
                            newMap.get(rbi.Id).RUL_Date_Available__c = date.valueOf(newMap.get(rbi.Id).RUL_Last_Activity_Date__c.addDays(integer.valueOf(newMap.get(rbi.Id).RUL_Period__c)));
                        }
                    }
                }
                
                if (oldMap.get(rbi.Id).RUL_Activities_used__c != newMap.get(rbi.Id).RUL_Activities_used__c
                            && newMap.get(rbi.Id).RUL_Activities_used__c < newMap.get(rbi.Id).RUL_Activities_will_do__c) {
                    newMap.get(rbi.Id).RUL_Limit_Reached__c = false;
                    newMap.get(rbi.Id).RUL_Date_Available__c = null;
                }
                
                if (newMap.get(rbi.Id).RUL_Activities_will_do__c != null
                                && newMap.get(rbi.Id).RUL_Activities_used__c >= newMap.get(rbi.Id).RUL_Activities_will_do__c
                                && newMap.get(rbi.Id).RUL_Limit_Reached__c == false) {
                    newMap.get(rbi.Id).RUL_Limit_Reached__c = true;
                }
            }
            
            if (contactIds.size() > 0) {
                updateContactOnRULPeriodChange(contactIds, contactTypeRBIList);
            }
        } catch (exception e) {
            throw e;
        }
    }
    
    /**
     * Method to update Contact on change of RUL Period 
     */
    static void updateContactOnRULPeriodChange(Set<Id> contactIds,
                                                List<Reference_Basic_Information__c> contactTypeRBIList) {
        
        Date lastActivityDate;
        Map<Id, Reference_Basic_Information__c> contactMap = new Map<Id, Reference_Basic_Information__c>();
        Map<Id, List<Reference_Request_Account_Contact__c>> contactRRACMap
                        = new Map<Id, List<Reference_Request_Account_Contact__c>>();
        
        for (Reference_Basic_Information__c rbi : contactTypeRBIList) {
            
            if (contactIds.contains(rbi.Contact__c) && rbi.RUL_Period__c != null) {
                lastActivityDate = date.today() - integer.valueOf(rbi.RUL_Period__c);
            }
            contactMap.put(rbi.Contact__c, rbi);
        }
        
        for (Reference_Request_Account_Contact__c tempObj : WithoutSharingHelperController.getRRACRecords(contactIds)) {
            
            if (contactMap.containsKey(tempObj.Contact__c)
                        && tempObj.Activity_Date__c != null
                        && (tempObj.Activity_Date__c).daysBetween(date.today()) <= contactMap.get(tempObj.Contact__c).RUL_Period__c) {
                
                if (!contactRRACMap.containsKey(tempObj.Contact__c)) {
                    contactRRACMap.put(tempObj.Contact__c, new List<Reference_Request_Account_Contact__c>());
                }
                contactRRACMap.get(tempObj.Contact__c).add(tempObj);
            }
        }
        
        for (Reference_Basic_Information__c rbi : contactTypeRBIList) {
            
            if (contactIds.contains(rbi.Contact__c)) {
                
                if (contactRRACMap.get(rbi.Contact__c) != null) {
                    rbi.RUL_Activities_used__c = contactRRACMap.get(rbi.Contact__c).size();
                } else {
                    rbi.RUL_Activities_used__c = 0;
                }
                
                if (rbi.RUL_Activities_used__c != 0
                            && rbi.RUL_Activities_used__c >= rbi.RUL_Activities_will_do__c) {
                    rbi.RUL_Limit_Reached__c = true;
                    
                    if (rbi.RUL_Last_Activity_Date__c != null && rbi.RUL_Period__c != null) {
                        rbi.RUL_Date_Available__c = date.valueOf(rbi.RUL_Last_Activity_Date__c.addDays(integer.valueOf(rbi.RUL_Period__c)));
                    }
                }
                
                if (rbi.RUL_Activities_used__c != 0 && rbi.RUL_Activities_used__c < rbi.RUL_Activities_will_do__c) {
                    rbi.RUL_Limit_Reached__c = false;
                    rbi.RUL_Date_Available__c = null;
                }
                
                if (rbi.RUL_Activities_used__c == 0) {
                    rbi.RUL_Limit_Reached__c = false;
                    rbi.RUL_Date_Available__c = null;
                }
            }
        }
    }
    
    /**
     * Method called on after update of Reference Profile
     */
    public static void onAfterUpdate(List<Reference_Basic_Information__c> newRBIList,
                                        Map<Id, Reference_Basic_Information__c> oldRBIMap,
                                        Map<Id, Reference_Basic_Information__c> newRBIMap) {
        
        List<Reference_Basic_Information__c> accountTypeRBIList = new List<Reference_Basic_Information__c>();
        List<Reference_Basic_Information__c> contactTypeRBIList = new List<Reference_Basic_Information__c>();
        
        for (Reference_Basic_Information__c rbi : newRBIList) {
            
            if (rbi.Contact__c == null) {
                accountTypeRBIList.add(rbi);
            } else {
                contactTypeRBIList.add(rbi);
            }
        }
        if (accountTypeRBIList.size() > 0) {
            onUpdateAccountTypeRBI(accountTypeRBIList, oldRBIMap, newRBIMap, new Map<Id,List<Account_Attribute__c>>());
        }
        
        if (contactTypeRBIList.size() > 0) {
            onUpdateContactTypeRBI(contactTypeRBIList, oldRBIMap, newRBIMap);
        }
    }
    
    /**
     * Method called on update Account type Reference Profile
     */
    static void onUpdateAccountTypeRBI(List<Reference_Basic_Information__c> accountTypeRBIList,
                                            Map<Id, Reference_Basic_Information__c> oldMap,
                                            Map<Id, Reference_Basic_Information__c> newMap,
                                            Map<Id,List<Account_Attribute__c>> accToAtt) {
        
        Set<String> accountIDs = new Set<String>();
        Set<String> oppAccountIDs = new Set<String>();
        Map<String,String> candidateAccountIDs = new Map<String,String>();
        Set<String> accountForAttMapping = new Set<String>();
        List<Reference_Basic_Information__c> contactRBIList = new List<Reference_Basic_Information__c>();
        List<Contact_Attribute__c> contactAttributes = new List<Contact_Attribute__c>();
        List<Contact_Attribute__c> allContactAttributes = new List<Contact_Attribute__c>();
        List<Reference_Basic_Information__c> allcontactRBIList = new List<Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> updateAccountFieldMapForRul = new Map<Id, Reference_Basic_Information__c>();
        List<Reference_Note__c> notes = new List<Reference_Note__c>();
        //Shared Contact start
        Set<String> sharedContactIds = new Set<String>();
        Set<String> sharedContactAccountIds = new Set<String>();
        Map<Id, Set<Id>> accountContactMap = new Map<Id, Set<Id>>(); 
        Map<Id, Set<Id>> contactAccountMap = new Map<Id, Set<Id>>();
        Map<Id, List<Contact>> AccountRelatedContacts = new Map<Id, List<Contact>>();
        //end
        //  REF-1969
        Set<String> accountIdSet = new Set<String>();
        
        for (Reference_Basic_Information__c rbi : accountTypeRBIList) {
            
            if (oldMap.get(rbi.Id).Reference_Program_Candidate__c != newMap.get(rbi.Id).Reference_Program_Candidate__c || oldMap.get(rbi.Id).Is_Referenceable__c != newMap.get(rbi.Id).Is_Referenceable__c) {
                String oldType = oldMap.get(rbi.Id).Is_Referenceable__c ? 'Member' : oldMap.get(rbi.Id).Reference_Program_Candidate__c ? 'Candidate' : '';
                String newType = newMap.get(rbi.Id).Is_Referenceable__c ? 'Member' : newMap.get(rbi.Id).Reference_Program_Candidate__c ? 'Candidate' : '';
                Boolean isSetToNone = !newMap.get(rbi.Id).Reference_Program_Candidate__c && !newMap.get(rbi.Id).Is_Referenceable__c;
                candidateAccountIDs.put(newMap.get(rbi.Id).Account__c,oldType + '@@' + newType + '@@' + isSetToNone);
            }
        
            if (newMap.get(rbi.Id).Is_Referenceable__c
                        && oldMap.get(rbi.Id).Account_Level_RUL__c != newMap.get(rbi.Id).Account_Level_RUL__c) {
                updateAccountFieldMapForRul.put(rbi.Id, newMap.get(rbi.Id));
            }
            
            if (newMap.get(rbi.Id).Is_Referenceable__c && !oldMap.get(rbi.Id).Is_Referenceable__c) {
                accountIDs.add(newMap.get(rbi.Id).account__c);
                //Shared Contact
                accountContactMap.put(rbi.account__c, new Set<Id>());
                AccountRelatedContacts.put(rbi.Account__c, new List<Contact>());

                //  Check if Is_Referenceable__c field is changed and its value is true
                if(newMap.get(rbi.Id).Is_Referenceable__c) {
                    accountIdSet.add(newMap.get(rbi.Id).account__c);
                }
            }
            
            if (rbi.Is_Referenceable__c || rbi.Reference_Program_Candidate__c) {
                accountForAttMapping.add(rbi.Account__c);
            }
            
            if (rbi.Is_Referenceable__c) {
                oppAccountIDs.add(rbi.Account__c);
            }
            
            //#890 -Creating notes if RBI created incative using custom setting.
            if (oldMap.get(rbi.Id).Referenceability_Status__c != newMap.get(rbi.Id).Referenceability_Status__c 
                            && rbi.Referenceability_Status__c != null && rbi.Referenceability_Status__c == 'Inactive' 
                            && rbi.inactive_reason__c != null && rbi.inactive_reason__c.contains('Reference Profile Set to Inactive when initially created')) {  
                notes.add(new Reference_Note__c(Account__c = rbi.Account__c, 
                                                Note__c = System.Label.Reason_For_Inactive + ' ' + 'Reference Profile Set to Inactive when initially created.')); 
            }  
        }
        //REF-1954
        if (candidateAccountIDs.size() > 0 && ConstantsController.shouldCandidateRequestDelete) {
            List<Reference_Note__c> notesAR = updateAccRequest(candidateAccountIDs);
            notes.addAll(notesAR); 
        }
        
        if (updateAccountFieldMapForRul.size() > 0) {
            updateContactRul(updateAccountFieldMapForRul);
        }
        
        //Shared Contact start
        if (cs.Shared_Contacts__c) {
            String objectName = cs.Shared_Contact_Object__c;
            String accountField = cs.Shared_Account_Field__c;
            String contactField = cs.Shared_Contact_Field__c;
            
            if (accountField != null && accountField != '' && contactField != null && contactField != '') {
                
                String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName
                                 + ' WHERE ' + accountField + ' IN :accountIDs';
                List<sObject> objectList = WithoutSharingHelperController.getSharedContactsForUpdateRBI(accountIDs, query);
                
                if (objectList != null && objectList.size() > 0) {
                    
                    for (sObject obj : objectList) {
                        
                        if (accountContactMap.containsKey((String)obj.get(accountField))) {
                            sharedContactIds.add((String)obj.get(contactField));
                            accountContactMap.get((String)obj.get(accountField)).add((String)obj.get(contactField));
                        }
                        
                        if (contactAccountMap != null && !contactAccountMap.containsKey((String)obj.get(contactField))) {
                            contactAccountMap.put((String)obj.get(contactField), new Set<Id>());
                        }
                        contactAccountMap.get((String)obj.get(contactField)).add((String)obj.get(accountField));
                    }
                }
            }
        }
        //Shared Contact end
        
        if (accountIDs.size() > 0) {
            
            //Shared Contact start
            if (cs.Shared_Contacts__c && sharedContactIds.size() > 0) {
                
                for (Contact contact : WithoutSharingHelperController.getContactRBITriggerHandler3SharedContact(accountIds, sharedContactIds)) {
                    
                    if (contact.Reference_Basic_Informations__r.size() > 0) {
                        
                        if (contact.Reference_Basic_Informations__r[0].Referenceability_Status__c == 'Active'
                                    || contact.Reference_Basic_Informations__r[0].Referenceability_Status__c == 'Caution') {
                            contactRBIList.add(contact.Reference_Basic_Informations__r[0]);
                        } else {
                            contactAccountMap.remove(contact.Id);
                        }
                        allcontactRBIList.add(contact.Reference_Basic_Informations__r[0]);
                    } else {
                        contactAccountMap.remove(contact.Id);
                    }
                    
                    if (contactAccountMap.containsKey(contact.Id)) {
                        
                        for (String accountId : contactAccountMap.get(contact.Id)) {
                            
                            if (AccountRelatedContacts != null && AccountRelatedContacts.containsKey(accountId)) {
                                AccountRelatedContacts.get(accountId).add(contact);
                            }
                        }
                    }
                    
                    if (!sharedContactIds.contains(contact.Id)) {
                        sharedContactAccountIds.add(contact.AccountId);
                    }
                    
                    for (Contact_Attribute__c conAtt : contact.Contact_Attributes__r) {
                        contactAttributes.add(conAtt);
                    }
                }
            } else {    //Shared Contact end
                
                for (Contact contact : WithoutSharingHelperController.getContactRBITriggerHandler3(accountIds)) {
                    
                    for (Contact_Attribute__c conAtt : contact.Contact_Attributes__r) {
                        contactAttributes.add(conAtt);
                    }
                    
                    if (contact.Reference_Basic_Informations__r.size() > 0) {
                        
                        if (contact.Reference_Basic_Informations__r[0].Referenceability_Status__c == 'Active'
                                    || contact.Reference_Basic_Informations__r[0].Referenceability_Status__c == 'Caution') {
                            contactRBIList.add(contact.Reference_Basic_Informations__r[0]);
                        }
                        allcontactRBIList.add(contact.Reference_Basic_Informations__r[0]);
                    }
                }
            }
            List<Account> allaccountsWithRelatedRecords = new List<Account>();
            List<Account> accountsWithRelatedRecords = new List<Account>();
            
            //Shared Contact code start
            if (cs.Shared_Contacts__c && sharedContactIds.size() > 0) {
                sharedContactAccountIds.addAll(accountIds);
                allaccountsWithRelatedRecords = WithoutSharingHelperController.getAccountRecordsWithAllRelatedRecords(sharedContactAccountIds);
                Set<String> accForAtt = new Set<String>();
                for (Account acc : allaccountsWithRelatedRecords) {
                    
                    if (accountIds.contains(acc.Id)) {
                        accountsWithRelatedRecords.add(acc);
                        accForAtt.add(acc.Id);
                    }
                }
                for (Account_Attribute__c accAtr : WithoutSharingHelperController.getAccountAttributesForAccount(accForAtt)) {
                    if (!accToAtt.containsKey(accAtr.Account__c)) {
                        accToAtt.put(accAtr.Account__c, new List<Account_Attribute__c>());
                    }
                    accToAtt.get(accAtr.Account__c).add(accAtr);
                }
                updateAttributeOnAccountSharedContact(contactRBIList, contactAttributes, allaccountsWithRelatedRecords, contactAccountMap, sharedContactIds);
                AddAttributesFromRefContentToAccount(accountIDs, accountsWithRelatedRecords,accToAtt);
                addAttributesOnContactSharedContact(contactRBIList, allaccountsWithRelatedRecords, accountContactMap);
                addAttributesOnContent(accountIDs, accountsWithRelatedRecords,accToAtt);
                updateReferenceabilitiesonAccount(accountIDs, accountsWithRelatedRecords, AccountRelatedContacts);
            } else {    //Shared Contact end
                accountsWithRelatedRecords = WithoutSharingHelperController.getAccountRecordsWithAllRelatedRecords(accountIds);
                for (Account_Attribute__c accAtr : WithoutSharingHelperController.getAccountAttributesForAccount(accountIds)) {
                    if (!accToAtt.containsKey(accAtr.Account__c)) {
                        accToAtt.put(accAtr.Account__c, new List<Account_Attribute__c>());
                    }
                    accToAtt.get(accAtr.Account__c).add(accAtr);
                }
                updateReferenceabilitiesonAccount(accountIDs, accountsWithRelatedRecords, new Map<Id, List<Contact>>());
                updateAttributeOnAccount(contactRBIList, contactAttributes, accountsWithRelatedRecords, accToAtt);
                AddAttributesFromRefContentToAccount(accountIDs, accountsWithRelatedRecords,accToAtt);
                addAttributesOnContact(allcontactRBIList, accountsWithRelatedRecords,accToAtt);
                addAttributesOnContent(accountIDs, accountsWithRelatedRecords,accToAtt);
            }
            
            /*
             * for --> ReferenceEdge Attribute, Mapped Attribute Reporting question
             * Set Reference_Basic_Information__c in Account Attribute
             * by Rekha
             */
            if (ConstantsController.updateRBIInAccAttributes) {
                List<Account_Attribute__c> accountAttributes = new List<Account_Attribute__c>();
                
                for (Account acc : accountsWithRelatedRecords) {
                    String rbiId = acc.Reference_Basic_Informations__r[0].Id;
                    
                    if (accToAtt.containsKey(acc.Id)) {
                        for (Account_Attribute__c accAtt : accToAtt.get(acc.Id)) {
                            if (accAtt.Reference_Basic_Information__c == null) {
                                accAtt.Reference_Basic_Information__c = rbiId;
                                accountAttributes.add(accAtt);
                            }
                        }
                    }
                }
                
                if (accountAttributes.size() > 0) {
                    ConstantsController.stopAccAttributeTrigger = true;
                    WithoutSharingHelperController.upsertAccountAttributes(accountAttributes);
                    ConstantsController.stopAccAttributeTrigger = false;
                }
                ConstantsController.updateRBIInAccAttributes = false;
            }
            //end
        }
        
        if (ConstantsController.attMappingForAccount && accountForAttMapping.size() > 0) {
            
            if (Test.isRunningTest() || System.isBatch() || System.isFuture()) {
                checkForAttributeMapping(accountForAttMapping, oppAccountIDs);

                if(accountIdSet.size() > 0) {
                    checkForOpportunityAttributeMapping(accountIdSet);
                }
            } else {
                ConstantsController.attMappingForAccount = false;
                checkForAttributeMappingFuture(accountForAttMapping, oppAccountIDs);

                if(accountIdSet.size() > 0) {
                    checkForOpportunityAttributeMapping(accountIdSet);
                }
            }
        }
        
        // Insert Notes:
        if (notes.size() > 0) {
            WithoutSharingHelperController.insertReferenceNotes(notes);
        }
    }
    
    /**
     * Method to delete Candidate account request
        REF-1954
    */ 
    private static List<Reference_Note__c> updateAccRequest(Map<String,String> candidateAccountIDs) {
        List<Reference_Note__c> referenceNotesToInsert = new List<Reference_Note__c>();
        List<Reference_Request_Account__c> accRequestList
                            = WithoutSharingHelperController.getRRAccountRequestsOfAccount(candidateAccountIDs.keySet());
        Map<Id,Id> requestToAccountIds = new Map<Id,Id>();
        
        List<Hit_List__c> hitList = WithoutSharingHelperController.getHitListsForUpdateRBI(candidateAccountIDs.keySet());
        List<Hit_List__c> hitListToUpdate = new List<Hit_List__c>();
        List<Reference_Request__c> rrUpdateList = new List<Reference_Request__c>();
        String noneSUBJECT = '@@ is no longer referenceable';
        String noneMSG_BODY = 'Sorry, your request to use @@ cannot be completed because they are no longer referenceable. Please make alternative plans to meet this need or submit a request for another account.';
        List<Reference_Request_Account__c> requests = new List<Reference_Request_Account__c>();
        String noneNote = 'Request Completed because the Account was removed from the Reference Program.';
        String memberNote = 'Request Completed because the Account was promoted to a member of the Reference Program.';
        Map<Id,Map<Id,ChatterWrapper>> chatterMailsMap = new Map<Id,Map<Id,ChatterWrapper>>();
        Set<Id> rrtoARClosed = new Set<Id>();
        
        for (Reference_Request_Account__c rra : accRequestList) {
            List<String> params = candidateAccountIDs.get(rra.Account__c).split('@@');
            Boolean paramIsSetToNone = params[2] == 'true';
            Boolean paramIsFromNone = params[0] == '';

            if (rra.Reference_Request__r.Project_Type__c == params[0] || (rra.Reference_Request__r.Project_Type__c == '' && params[0] == 'Member') || paramIsSetToNone || paramIsFromNone) {
                       
                if (rra.Account_Request_Status__c == ConstantsController.NOT_STARTED || rra.Account_Request_Status__c == ConstantsController.IN_PROGRESS
                    || rra.Account_Request_Status__c == ConstantsController.ONHOLD) {
                    rra.Account_Request_Status__c = ConstantsController.COMPLETED;
                    
                    if (!chatterMailsMap.containsKey(rra.Account__c)) {
                        chatterMailsMap.put(rra.Account__c, new Map<Id,ChatterWrapper>());
                    } 
                    
                    if (params[1] == 'Member') {
                        referenceNotesToInsert.add(new Reference_Note__c(Account_Request__c = rra.Id, Note__c = memberNote));
                    } else {
                        chatterMailsMap.get(rra.Account__c).put(rra.Requester__c,new ChatterWrapper(noneSUBJECT.replace('@@', rra.Account_f__c), noneMSG_BODY.replace('@@' ,rra.Account_f__c), rra.Requester__c));
                        referenceNotesToInsert.add(new Reference_Note__c(Account_Request__c = rra.Id, Note__c = noneNote));
                    }
                    rrtoARClosed.add(rra.Reference_Request__c);

                }  
                requests.add(rra);
            }
        }

        for (Reference_Request__c ref : WithoutSharingHelperController.getRefRequestsForUpdateRBI(rrtoARClosed)) {
            
            if (((ref.Unspecified_Requests__r.size() + ref.Reference_Request_Accounts__r.size()) <= 1) && (ref.Reference_Request_Status__c == ConstantsController.NOT_STARTED || ref.Reference_Request_Status__c == ConstantsController.IN_PROGRESS
                    || ref.Reference_Request_Status__c == ConstantsController.ONHOLD)) {
                ref.Reference_Request_Status__c = ConstantsController.COMPLETED;
                rrUpdateList.add(ref);
            }
        }
        
        for (Hit_List__c hitItem : hitList) {
            
            if (!hitItem.Released__c) {
                hitItem.Released__c = true ;
                hitListToUpdate.add(hitItem);
            }
        }

        if (chatterMailsMap.size() > 0) {
            prepareChatterTaskItem(chatterMailsMap);
        }
        
        if (requests.size() > 0) {
            ConstantsController.shouldRewardRecordsCreated = false;
            ConstantsController.forcecompleted = true;
            WithoutSharingHelperController.updateRRA(requests);
        }

        if (rrUpdateList.size() > 0) {
            WithoutSharingHelperController.updateRefRequests(rrUpdateList);
        }

        if (hitListToUpdate.size() > 0) {  
            WithoutSharingHelperController.updateHitList(hitList);
        }
        return referenceNotesToInsert;
    }
    
    /**
     * Method to delete candidate Contact request
     */
    private static List<Reference_Note__c> updateCandidateConRequest(Map<Id,String> contactIds) { // do not delete contact requests and update hitlist items
        List<Reference_Request_Account_Contact__c> conRequestList = WithoutSharingHelperController.getContactRequestsForUpdateRBI(contactIds.keySet());
        List<Reference_Request_Account_Contact__c> rracToUpdate = new List<Reference_Request_Account_Contact__c>();
        List<Reference_Request__c> rrUpdateList = new List<Reference_Request__c>();
        List<Hit_List__c> hitList =  new List<Hit_List__c>();
        String noneSUBJECT = '@@ is no longer referenceable';
        String noneMSG_BODY = 'Sorry, your request to use @@ cannot be completed because they are no longer referenceable. Please make alternative plans to meet this need or submit a request for another account.';
        Map<Id,Map<Id,ChatterWrapper>> chatterMailsMap = new Map<Id,Map<Id,ChatterWrapper>>();
        Set<Id> rrtoARClosed = new Set<Id>();
        List<Reference_Note__c> referenceNotesToInsert = new List<Reference_Note__c>();
        String noneNote = 'Request Completed because the Contact was removed from the Reference Program.';
        String memberNote = 'Request Completed because the Contact was promoted to a member of the Reference Program.';
        

        for (Hit_List__c hitItem : WithoutSharingHelperController.getHitListsForUpdateRBI1(contactIds.keySet())) {
            if (!hitItem.Released__c) { 
                hitItem.Released__c = true ;
                hitList.add(hitItem);
            }
        }

        for (Reference_Request_Account_Contact__c rrca : conRequestList) {
            List<String> params = contactIds.get(rrca.Contact__c).split('@@');
            Boolean paramIsSetToNone = params[2] == 'true';
            Boolean paramIsFromNone = params[0] == '';

            if (rrca.Reference_Request_Account__r.Reference_Request__r.Project_Type__c == params[0] || (rrca.Reference_Request_Account__r.Reference_Request__r.Project_Type__c == '' && params[0] == 'Member') || paramIsSetToNone || paramIsFromNone) {
            
                if (rrca.Contact_Request_Status__c == ConstantsController.NOT_STARTED || rrca.Contact_Request_Status__c == ConstantsController.IN_PROGRESS
                    || rrca.Contact_Request_Status__c == ConstantsController.ONHOLD) {
                    rrca.Contact_Request_Status__c = ConstantsController.COMPLETED;
                    rrca.Reference_Request_Account__r.Account_Request_Status__c = ConstantsController.COMPLETED;
                    rrtoARClosed.add(rrca.Reference_Request_Account__r.Reference_Request__c);
                    rracToUpdate.add(rrca);

                    if (!chatterMailsMap.containsKey(rrca.Contact__c)) {
                        chatterMailsMap.put(rrca.Contact__c, new Map<Id,ChatterWrapper>());
                    }

                    if (params[1] == 'Member') {
                        referenceNotesToInsert.add(new Reference_Note__c(Account_Request__c = rrca.Reference_Request_Account__c, Note__c = memberNote));
                    } else {
                        referenceNotesToInsert.add(new Reference_Note__c(Account_Request__c = rrca.Reference_Request_Account__c, Note__c = noneNote));
                        chatterMailsMap.get(rrca.Contact__c).put(rrca.Reference_Request_Account__r.Requester__c,new ChatterWrapper(noneSUBJECT.replace('@@', rrca.Contact__r.Name), noneMSG_BODY.replace('@@' ,rrca.Contact__r.Name), rrca.Reference_Request_Account__r.Requester__c));
                    }
                    
                }
            }
        }

        for (Reference_Request__c ref : WithoutSharingHelperController.getRefRequestsForUpdateRBI(rrtoARClosed)) {
            
            if (((ref.Unspecified_Requests__r.size() + ref.Reference_Request_Accounts__r.size()) <= 1) && (ref.Reference_Request_Status__c == ConstantsController.NOT_STARTED || ref.Reference_Request_Status__c == ConstantsController.IN_PROGRESS
                    || ref.Reference_Request_Status__c == ConstantsController.ONHOLD)) {
                ref.Reference_Request_Status__c = ConstantsController.COMPLETED;
                rrUpdateList.add(ref);
            }
        }
        
        if (hitList.size() > 0) {
            WithoutSharingHelperController.updateHitList(hitList);
        }

        if (rracToUpdate.size() > 0) {
            ConstantsController.shouldRewardRecordsCreated = false;
            ConstantsController.forcecompleted = true;
            WithoutSharingHelperController.upsertRRACList(rracToUpdate);
        }

        if (rrUpdateList.size() > 0) {
            WithoutSharingHelperController.updateRefRequests(rrUpdateList);
        }

        if (chatterMailsMap.size() > 0) {
            prepareChatterTaskItem(chatterMailsMap);
        }
        return referenceNotesToInsert;
    }
    /**
     * Method to update Referenceabilities on Account
     */
    private static void updateReferenceabilitiesonAccount(Set<String> accountIds,
                                                            List<Account> relatedAccounts,
                                                            Map<Id, List<Contact>> AccountRelatedContacts) {
        
        List<Reference_Basic_Information__c> conRBIList = new List<Reference_Basic_Information__c>();
        List<Reference_Basic_Information__c> updateRBIs = new List<Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> Accounts = new Map<Id, Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> contacts = new Map<Id, Reference_Basic_Information__c>();
        List<Referenceability__c> listReferenceability = new List<Referenceability__c>();
        List<Referenceability__c> listaccountReferenceability = new List<Referenceability__c>();
        Map<Id, Set<String>> accountRefMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> AccountReference = new Map<Id, Set<String>>();
        Map<Id, Set<Id>> accConRefMap = new Map<Id, Set<Id>>();
        Set<Id> addedRefIds = new Set<Id>();
        
        if (accountIds.size() > 0) {
            
            for (Account acc : relatedAccounts) {
                
                if (accountIds.contains(acc.Id)) {
                    accountRefMap.put(acc.Id, new Set<String>());
                    accConRefMap.put(acc.Id, new Set<Id>());
                    
                    for (Reference_Basic_Information__c rbi : acc.Reference_Basic_Informations__r) {
                        
                        if (rbi.Contact__c == null) {
                            Accounts.put(rbi.Account__c, rbi);
                        } else if (rbi.Contact__c != null
                                        && (rbi.Referenceability_Status__c != null
                                            && rbi.Referenceability_Status__c != ConstantsController.INACTIVE)) {
                            
                            contacts.put(rbi.Contact__c, rbi);
                        }
                    }
                    
                    for (Referenceability__c ref : acc.Referenceabilities__r) {
                        accountRefMap.get(acc.Id).add(ref.Referenceability_Type__c + '+' + ref.Contact__c);
                    }
                }
            }
            
            //references are stored in the Set and mapped according to the associated contact
            for (Id accountId : Accounts.keySet()) {
                AccountReference.put(accountId, new Set<String>());
            }
        }
        
        if (accountIds.size() > 0 || (contacts != null && contacts.size() > 0)) {
            
            for (Referenceability__c ref : WithoutSharingHelperController.getReferenceabilitiesForUpdateRBI(accountIds, contacts)) {
                
                if (accountRefMap.containsKey(ref.Account__c)) {
                    accountRefMap.get(ref.Account__c).add(ref.Referenceability_Type__c + '+' + ref.Contact__c);
                }
                
                //for child contacts
                if ((ConstantsController.copyExistingAtt
                            || (!ConstantsController.copyExistingAtt
                                && ConstantsController.contactId != ref.Contact__c)
                            || (!ConstantsController.copyExistingAtt
                                && ConstantsController.contactId == ref.Contact__c
                                && ConstantsController.refIdsinCopyNomi.contains(ref.Referenceability_Type__c)))
                        && contacts.containsKey(ref.Contact__c)
                        && ref.Account__c != ref.Contact__r.AccountId
                        && !accConRefMap.get(ref.Contact__r.AccountId).contains(ref.Referenceability_Type__c)) {
                    
                    if (ref.Account__c == null && !addedRefIds.contains(ref.Id)) {
                        ref.Account__c = ref.Contact__r.AccountId;
                        listReferenceability.add(ref);
                        addedRefIds.add(ref.Id);
                        accConRefMap.get(ref.Contact__r.AccountId).add(ref.Referenceability_Type__c);
                        
                        if (AccountReference.containsKey(ref.Contact__r.AccountId)) {
                            
                            if (ref.Status__c == ConstantsController.APPROVED) {
                                AccountReference.get(ref.Contact__r.AccountId).add(ref.Referenceability_Type__r != null
                                                                                    ? ref.Referenceability_Type__r.Name : '');
                            } else {
                                AccountReference.get(ref.Contact__r.AccountId).add('');
                            }
                        }
                    } else if (ref.Account__c != ref.Contact__r.AccountId
                                    && !accConRefMap.get(ref.Contact__r.AccountId).contains(ref.Referenceability_Type__c)
                                    && (accountRefMap == null
                                        || (accountRefMap != null
                                            && !accountRefMap.containsKey(ref.Contact__r.AccountId))
                                        || (accountRefMap != null
                                            && accountRefMap.containsKey(ref.Contact__r.AccountId)
                                            && !accountRefMap.get(ref.Contact__r.AccountId).contains(ref.Referenceability_Type__c + '+' + ref.Contact__c)))) {
                        
                        Referenceability__c newRefer = new Referenceability__c();
                        newRefer.Account__c = ref.Contact__r.AccountId;
                        newRefer.Contact__c = ref.Contact__c;
                        newRefer.Status__c = ref.Status__c;
                        newRefer.Comment__c = ref.Comment__c;
                        newRefer.Verified__c = ref.Verified__c;
                        newRefer.Referenceability_Type__c = ref.Referenceability_Type__c;
                        listReferenceability.add(newRefer);
                        accConRefMap.get(ref.Contact__r.AccountId).add(ref.Referenceability_Type__c);
                        
                        if (AccountReference.containsKey(ref.Contact__r.AccountId)) {
                            
                            if (ref.Status__c == ConstantsController.APPROVED) {
                                AccountReference.get(ref.Contact__r.AccountId).add(ref.Referenceability_Type__r != null
                                                                                    ? ref.Referenceability_Type__r.Name
                                                                                    : '');
                            } else {
                                AccountReference.get(ref.Contact__r.AccountId).add('');
                            }
                        }
                    }
                }
                
                if (accountIds.contains(ref.Account__c)) {
                    listaccountReferenceability.add(ref);
                }
            }
        }
        
        //for shared contacts
        for (Id accId : AccountRelatedContacts.keySet()) {
            
            for (Contact con : AccountRelatedContacts.get(accId)) {
                Set<Id> refIdSet = new Set<Id>();
                
                for (Referenceability__c ref : con.Referenceabilities__r) {
                    
                    if ((ConstantsController.copyExistingAtt
                                || (!ConstantsController.copyExistingAtt
                                    && ConstantsController.contactId != ref.Contact__c)
                                || (!ConstantsController.copyExistingAtt
                                    && ConstantsController.contactId == ref.Contact__c
                                    && ConstantsController.refIdsinCopyNomi.contains(ref.Referenceability_Type__c)))
                            && !refIdSet.contains(ref.Referenceability_Type__c)) {
                        
                        if (ref.Account__c == null
                                    && !addedRefIds.contains(ref.Id)
                                    && (accountRefMap == null
                                        || (accountRefMap != null
                                            && !accountRefMap.containsKey(accId))
                                        || (accountRefMap != null
                                            && accountRefMap.containsKey(accId)
                                            && !accountRefMap.get(accId).contains(ref.Referenceability_Type__c + '+' + ref.Contact__c)))) {
                            
                            ref.Account__c = accId;
                            listReferenceability.add(ref);
                            addedRefIds.add(ref.Id);
                            
                            if (AccountReference.containsKey(ref.Account__c)) {
                                
                                if (ref.Status__c == ConstantsController.APPROVED) {
                                    AccountReference.get(ref.Account__c).add(ref.Referenceability_Type__r != null
                                                                                ? ref.Referenceability_Type__r.Name
                                                                                : '');
                                } else {
                                    AccountReference.get(ref.Account__c).add('');
                                }
                            }
                        } else if (accountRefMap == null
                                        || (accountRefMap != null
                                            && !accountRefMap.containsKey(accId))
                                        || (accountRefMap != null
                                            && accountRefMap.containsKey(accId)
                                            && !accountRefMap.get(accId).contains(ref.Referenceability_Type__c + '+' + ref.Contact__c))) {
                            
                            Referenceability__c newRefer = new Referenceability__c();
                            newRefer.Account__c = accId;
                            newRefer.Contact__c = ref.Contact__c;
                            newRefer.Status__c = ref.Status__c;
                            newRefer.Comment__c = ref.Comment__c;
                            newRefer.Verified__c = ref.Verified__c;
                            newRefer.Referenceability_Type__c = ref.Referenceability_Type__c;
                            listReferenceability.add(newRefer);
                            
                            if (AccountReference.containsKey(ref.Account__c)) {
                                
                                if (ref.Status__c == ConstantsController.APPROVED) {
                                    AccountReference.get(ref.Account__c).add(ref.Referenceability_Type__r != null
                                                                                ? ref.Referenceability_Type__r.Name
                                                                                : '');
                                } else {
                                    AccountReference.get(ref.Account__c).add('');
                                }
                            }
                        }
                    }
                    refIdSet.add(ref.Referenceability_Type__c);
                }
            }
        }
        
        if (listReferenceability.size() > 0) {
            listReferenceability = WithoutSharingHelperController.upsertReferenceabilities(listReferenceability);
        }
        
        if (accountIds.size() > 0) {
            
            //loop which forms the comma separated String which is added to contacts Map....which is upserted later 
            for (Id accntId : AccountReference.keySet()) {
                String referenceabilities = '';
                String refAlreadyExist = '';
                
                if (accounts.get(accntId).Referenceability__c != null) {
                    refAlreadyExist = accounts.get(accntId).Referenceability__c;
                }
                
                for (String str : AccountReference.get(accntId)) {
                    
                    if (str != '' && !refAlreadyExist.contains(str)) {
                        
                        if (referenceabilities == '') {
                            referenceabilities = str;
                        } else {
                            referenceabilities = referenceabilities + ', ' + str;
                        }
                    }
                }
                
                if (refAlreadyExist != referenceabilities && referenceabilities != '') {
                    accounts.get(accntId).Referenceability__c = refAlreadyExist + ', ' + referenceabilities;
                    updateRBIs.add(accounts.get(accntId));
                }
            }
            
            if (updateRBIs.size() > 0) {
                updateRBIs = WithoutSharingHelperController.upsertRBI(updateRBIs);
            }
        }
    }
    
    /**
     * Method to add Attibute from Reference Content to Account
     */
    private static void AddAttributesFromRefContentToAccount(Set<String> accounts, List<Account> relatedAccounts,Map<Id,List<Account_Attribute__c>> accToAtt) {
        Map<Id, Set<Id>> attAssociatedToAccount = new Map<Id, Set<Id>>();
        List<Account_Attribute__c> newAccAtt = new List<Account_Attribute__c>();
        Set<Id> refContentIds = new Set<Id>();
        Set<String> preventDuplicacy = new Set<String>();
        Map<Id, Set<Id>> referAccIds = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> referAttribIds = new Map<Id, Set<Id>>();
        Account_Attribute__c tempObj;
        
        // For SOQL 101
        for (Account acc : relatedAccounts) {
            
            if (accounts.contains(acc.id)) {
                if (accToAtt.containsKey(acc.Id)) {
                    for (Account_Attribute__c accAtt : accToAtt.get(acc.Id)) {
                    
                        if (accAtt.Reference_Content__c != null) {
                            
                            if (!attAssociatedToAccount.containsKey(accAtt.Account__c)) {
                                attAssociatedToAccount.put(accAtt.Account__c, new Set<Id>());
                            }
                            attAssociatedToAccount.get(accAtt.Account__c).add(accAtt.Attribute__c);
                        }
                    }
                }
                
                for (Account_Reference_Content__c accRef : acc.Account_Reference_Contents__r) {
                    refContentIds.add(accRef.Reference_Content__c);
                    
                    if (!referAccIds.containsKey(accRef.Reference_Content__c)) {
                        referAccIds.put(accRef.Reference_Content__c, new Set<Id>());
                    }
                    referAccIds.get(accRef.Reference_Content__c).add(accRef.Account__c);
                    referAttribIds.put(accRef.Reference_Content__c, new Set<Id>());
                }
            }
        }
        
        if (refContentIds.size() > 0) {
            
            for (Content_Attribute__c cA : WithoutSharingHelperController.getContentAttributesForUpdateRBI(refContentIds)) {
                referAttribIds.get(cA.Reference_Content__c).add(cA.Attribute__c);
            }
        }
        
        for (Id referId : referAttribIds.keySet()) {
            
            if (referAttribIds.get(referId) != null) {
                
                for (Id AttId : referAttribIds.get(referId)) {
                    
                    for (Id accId : referAccIds.get(referId)) {
                        
                        if (attAssociatedToAccount.get(accId) != null
                                    && !attAssociatedToAccount.get(accId).contains(AttId)
                                    && !preventDuplicacy.contains(referId + ',' + accId + ',' + attId)) {
                            
                            tempObj = new Account_Attribute__c();
                            tempObj.Account__c = accId;
                            tempObj.Attribute__c = AttId;
                            tempObj.Reference_Content__c = referId;
                            preventDuplicacy.add(referId + ',' + accId + ',' + attId);
                            newAccAtt.add(tempObj);
                        } else if (attAssociatedToAccount.get(accId) == null
                                    && !preventDuplicacy.contains(referId + ',' + accId + ',' + attId)) {
                            
                            tempObj = new Account_Attribute__c();
                            tempObj.Account__c = accId;
                            tempObj.Attribute__c = AttId;
                            tempObj.Reference_Content__c = referId;
                            preventDuplicacy.add(referId + ',' + accId + ',' + attId);
                            newAccAtt.add(tempObj);
                        }
                    }
                }
            }
        }
        
        if (newAccAtt.size() > 0) {
            ConstantsController.addAttributesToContact = false;
            ConstantsController.addAttributesToContent = false;
            WithoutSharingHelperController.upsertAccountAttributes(newAccAtt);
        }
    }
    
    @future
    private static void checkForAttributeMappingFuture(Set<String> accountIds, Set<String> referenceAccountIds) {
        checkForAttributeMapping(accountIds, referenceAccountIds);
    }
    
    /**
     * Method to check for Account Attribute Mapping
     */
    private static void checkForAttributeMapping(Set<String> accountIds, Set<String> referenceAccountIds) {
        
        ConstantsController.attMappingForAccount = false;
        Map<String, Schema.SObjectType> schemaMap = CRUDAndFLSCheckController.sObjectsMap;
        Map<String, Schema.SObjectField> fldObjMap = schemaMap.get('Account').getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> oppProductField_map = new Map<String, Schema.SObjectField>();
        Map<String, Schema.SObjectField> oppField_map = schemaMap.get('Opportunity').getDescribe().fields.getMap();
        List<Attribute_Mapping__c> attMappings = new List<Attribute_Mapping__c>();
        
        if (schemaMap.containsKey('OpportunityLineItem')) {
            oppProductField_map = schemaMap.get('OpportunityLineItem').getDescribe().fields.getMap();
        }
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        Set<String> fieldAPINames = new Set<String>();
        
        try {
            String theQuery = 'SELECT Id, Name, ';
            
            for (Schema.SObjectField s : fldObjMapValues) {
                Schema.DescribeFieldResult fieldDesc = s.getDescribe();
                
                if (fieldDesc.getType() == Schema.DisplayType.PICKList|| fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    String theName = fieldDesc.getName();
                    // Continue building your dynamic query String
                    theQuery += theName + ',';
                    fieldAPINames.add(theName);
                }
            }
            theQuery = theQuery.subString(0, theQuery.length() - 1);
            theQuery += ' FROM Account WHERE Id In :accountIds';
            List<Account> accounts = WithoutSharingHelperController.getAccountUsingDynamicSOQL1(theQuery, accountIds);
            
            for (Attribute_Mapping__c attM : WithoutSharingHelperController.getAttributeMappingsForUpdateRBI(fieldAPINames)) {
                attMappings.add(attM);
            }
            Map<String, List<Account>> attMappingAccount = new Map<String, List<Account>>();
            Map<Id, Set<Id>> mappingCreateAttribute = new Map<Id, Set<Id>>();
            Map<String, Set<String>> accountFieldAttDelete = new Map<String, Set<String>>();
            List<Account_Attribute__c> deleteAccountAtt = new List<Account_Attribute__c>();
            List<Account_Attribute__c> createAccountAtt = new List<Account_Attribute__c>();
            Map<Id, Map<Id, Account_Attribute__c>> allAccountAttributesAssociated = new Map<Id, Map<Id, Account_Attribute__c>>();
            Map<Id, Map<Id, Account_Attribute__c>> accountAttributesAssociated = new Map<Id, Map<Id, Account_Attribute__c>>();
            Map<Id, Map<Id, Account_Attribute__c>> accountAttributesAssociatedOpp = new Map<Id, Map<Id, Account_Attribute__c>>();
            Set<String> preventDuplicacy = new Set<String>();
            Set<Id> attMappingForUpdateAndDelete = new Set<Id>();
            Set<String> deleteAttMappings = new Set<String>();
            Set<String> oppProductAttMappingSet = new Set<String>();
            Set<String> oppAttMappingSet = new Set<String>();
            List<Account_Attribute__c > accAttToBeDeleted = new List<Account_Attribute__c>();
            
            //create a Map of attributMapping and accounts in which the field value is not null
            if (attMappings.size() > 0) {
                Set<String> oppMappingIds = new Set<String>();
                Map<Id, Set<String>> oppAccountMap = new Map<Id, Set<String>>();
                Map<String, Map<String, Set<String>>> oppProductsPicklistFieldValues = new Map<String, Map<String, Set<String>>>();
                Map<String, List<OpportunityLineItem>> opplineItemMap = new Map<String, List<OpportunityLineItem>>();
                Map<String, Set<String>> oppProductMap = new Map<String, Set<String>>();
                
                for (Account acc : accounts) {
                    
                    for (Attribute_Mapping__c attMapping : attMappings) {
                        
                        if (fldObjMap.containsKey(attMapping.Field_Api_Name__c.tolowerCase())
                                    && attMapping.object__c == ConstantsController.ACCOUNT) {
                            
                            if (acc.get(attMapping.Field_Api_Name__c) != null && attMapping.Auto_populate__c) {
                                
                                if (!attMappingAccount.containsKey(attMapping.Id)) {
                                    attMappingAccount.put(attMapping.Id, new List<Account>());
                                }
                                attMappingAccount.get(attMapping.Id).add(acc);
                            }
                            
                            if (attMapping.Auto_add__c || attMapping.Auto_Update__c || attMapping.Auto_delete__c) {
                                attMappingForUpdateAndDelete.add(attMapping.Id);
                            }
                        }
                        
                        //re #741
                        if (attMapping.Field_Api_Name__c == 'Product2' && attMapping.object__c == ConstantsController.OPPORTUNITY) {
                            oppMappingIds.add(attMapping.Id);
                        } else if (oppField_map.containsKey(attMapping.Field_Api_Name__c.tolowerCase())
                                    && attMapping.object__c == ConstantsController.OPPORTUNITY) {
                            oppMappingIds.add(attMapping.Id);
                            oppAttMappingSet.add(attMapping.Field_Api_Name__c);
                        }
                        
                        if (oppProductField_map.containsKey(attMapping.Field_Api_Name__c.tolowerCase())
                                    && attMapping.object__c == ConstantsController.OPPORTUNITY) {
                            oppMappingIds.add(attMapping.Id);
                            oppProductAttMappingSet.add(attMapping.Field_Api_Name__c);
                        }
                    }
                    accountAttributesAssociated.put(acc.Id, new Map<Id, Account_Attribute__c>());
                    allAccountAttributesAssociated.put(acc.Id, new Map<Id, Account_Attribute__c>());
                    
                    if (referenceAccountIds.contains(acc.Id)) {
                        accountAttributesAssociatedOpp.put(acc.Id, new Map<Id, Account_Attribute__c>());
                        oppAccountMap.put(acc.Id, new Set<String>());
                        oppProductsPicklistFieldValues.put(acc.Id, new Map<String, Set<String>>());
                    }
                }
                UtilityController.checkAttributeMappingEdit(attMappingForUpdateAndDelete, 'Account');
                
                //find the attributes already associated with those accounts
                for (Account_Attribute__c accAtt : WithoutSharingHelperController.getAccountAttributeinRBI1(allAccountAttributesAssociated.keySet())) {
                    
                    if (accAtt.Is_fromMapping__c) {
                        accountAttributesAssociated.get(accAtt.Account__r.Id).put(accAtt.Attribute__r.Id, accAtt);
                    }
                    
                    if (accAtt.From_Opportunity__c && referenceAccountIds.contains(accAtt.Account__r.Id)) {
                        accountAttributesAssociatedOpp.get(accAtt.Account__r.Id).put(accAtt.Attribute__r.Id, accAtt);
                    }
                    allAccountAttributesAssociated.get(accAtt.Account__r.Id).put(accAtt.Attribute__r.Id, accAtt);
                }
                
                if ((oppMappingIds.size() > 0 && cs != null && cs.Minimum_Opportunity_Size_OP__c != null) || Test.isRunningTest()) {
                    String theQueryOpp = '';
                    Boolean isCurrencyEnabled = (UtilityController.isCurrencyEnabled() && UserInfo.isMultiCurrencyOrganization());
                    
                    if (isCurrencyEnabled) {
                        theQueryOpp = 'SELECT PricebookEntry.Product2Id, OpportunityId, Opportunity.AccountId, Opportunity.CurrencyIsoCode, Opportunity.Amount';
                    } else {
                        theQueryOpp = 'SELECT PricebookEntry.Product2Id, OpportunityId, Opportunity.AccountId, Opportunity.Amount';
                    }
                    
                    for (String fieldName : oppProductField_map.keyset()) {
                        Schema.DescribeFieldResult fieldDesc = oppProductField_map.get(fieldName).getDescribe();
                        
                        if (fieldDesc.getType() == Schema.DisplayType.PICKList|| fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                            String theName = fieldDesc.getName();
                            // Continue building your dynamic query String
                            theQueryOpp += ', ' + theName;
                            fieldAPINames.add(theName);
                        }
                    }
                    Map<String, sObject> currencyMap = new Map<String, sObject>();
                    
                    if (isCurrencyEnabled) {
                        currencyMap = UtilityController.getAllCurrency();
                    }
                    Decimal amount = (isCurrencyEnabled ? (cs.Minimum_Opportunity_Size_OP__c / Decimal.valueOf(String.valueOf(
                                                currencyMap.get(String.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate')))) 
                                                : cs.Minimum_Opportunity_Size_OP__c);
                    
                    if (UserInfo.isMultiCurrencyOrganization() && isCurrencyEnabled) {
                        theQueryOpp += ' FROM OpportunityLineItem WHERE Opportunity.AccountId IN :referenceAccountIds AND Opportunity.StageName = \'Closed Won\' ';
                    } else {
                        theQueryOpp += ' FROM OpportunityLineItem WHERE Opportunity.AccountId IN :referenceAccountIds AND Opportunity.StageName = \'Closed Won\' AND Opportunity.Amount >= :amount';
                    }
                    List<OpportunityLineItem> oppLineItems = WithoutSharingHelperController.getOppLineItemsForUpdateRBI(theQueryOpp, referenceAccountIds, amount);
                                                
                    for (OpportunityLineItem oppLineItem : oppLineItems) {
                        
                        if (oppLineItem.Opportunity.Amount != null) {
                            Decimal oppAmount = (isCurrencyEnabled ?
                                        (oppLineItem.Opportunity.Amount / Decimal.valueOf(String.valueOf(
                                        currencyMap.get(String.valueOf(oppLineItem.Opportunity.get('CurrencyIsoCode'))).get('ConversionRate')))) : oppLineItem.Opportunity.Amount);
                
                            if (oppAmount >= amount) {
                                
                                if (!opplineItemMap.containsKey(oppLineItem.OpportunityId)) {
                                    opplineItemMap.put(oppLineItem.OpportunityId, new List<OpportunityLineItem>());
                                    oppProductMap.put(oppLineItem.OpportunityId, new Set<String>());
                                }
                                oppAccountMap.get(oppLineItem.Opportunity.AccountId).add(oppLineItem.OpportunityId);
                                opplineItemMap.get(oppLineItem.OpportunityId).add(oppLineItem);
                                oppProductMap.get(oppLineItem.OpportunityId).add(oppLineItem.PricebookEntry.Product2Id);
                            }
                        }
                    }
                    
                    for (Id accountId : oppAccountMap.keySet()) {
                        Map<String, Set<String>> tempMap = new Map<String, Set<String>>();
                        tempMap.putAll(oppProductsPicklistFieldValues.get(accountId));
                        
                        for (String field : oppProductAttMappingSet) {
                            tempMap.put(field, new Set<String>());
                        }
                        
                        for (String oppId : oppAccountMap.get(accountId)) {
                            
                            if (opplineItemMap.containsKey(oppId)) {
                                
                                for (OpportunityLineItem oppLineItem : opplineItemMap.get(oppId)) {
                                    
                                    for (String field : oppProductAttMappingSet) {
                                        
                                        if (oppLineItem.get(field) != null) {
                                            
                                            if (String.valueOf(oppLineItem.get(field)).contains(';')) {
                                                
                                                for (String value : String.valueOf(oppLineItem.get(field)).split(';')) {
                                                    tempMap.get(field).add(value.trim());
                                                }
                                            } else {
                                                tempMap.get(field).add(String.valueOf(oppLineItem.get(field)));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        oppProductsPicklistFieldValues.get(accountId).putAll(tempMap);
                    }
                }
                // REF-2186
                
                if (oppMappingIds.size() > 0 || Test.isRunningTest()) {
                    String oppQuery = 'SELECT Id,AccountId, Name, ';
            
                    for(String fieldName : oppField_map.keyset()) {
                        Schema.DescribeFieldResult fieldDesc = oppField_map.get(fieldName).getDescribe();
                        
                        if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                            String theName = fieldDesc.getName();
                            
                            //  Exclude Stage field from opportunity object
                            if(theName != 'StageName') {
                            fieldAPINames.add(theName);
                            }
                            // Continue building your dynamic query String
                            oppQuery += theName + ',';
                        }
                    } 
                    oppQuery = oppQuery.removeEnd(',');
                    String stageCS = cs.Opportunity_Closed_Won_Stage__c;
                    oppQuery += ' FROM Opportunity WHERE AccountId IN : accountIds AND StageName = :stageCS LIMIT ' + (Limits.getLimitQueryRows() - Limits.getQueryRows());	
                    Map<Id,Opportunity> oppoMap = new Map<Id,Opportunity>();
                    
                    
                    for (Opportunity oppItem : WithoutSharingHelperController.getOpp(oppQuery,accountIds,stageCS)) {
                        
                        if (oppAccountMap.containsKey(oppItem.AccountId)) {
                            oppAccountMap.get(oppItem.AccountId).add(oppItem.Id);
                            oppoMap.put(oppItem.Id,oppItem);
                        }
                    }
                    for (Id accountId : oppAccountMap.keySet()) {
                        Map<String, Set<String>> tempMap = new Map<String, Set<String>>();
                        tempMap.putAll(oppProductsPicklistFieldValues.get(accountId));
                        
                        for (String field : oppAttMappingSet) {
                            tempMap.put(field, new Set<String>());
                        }

                        for (String oppId : oppAccountMap.get(accountId)) {
                            
                            if (oppoMap.containsKey(oppId)) {
                                    
                                for (String field : oppAttMappingSet) {
                                        
                                    if (oppoMap.get(oppId).get(field) != null) {
                                        
                                        if (String.valueOf(oppoMap.get(oppId).get(field)).contains(';')) {
                                            
                                            for (String value : String.valueOf(oppoMap.get(oppId).get(field)).split(';')) {
                                                tempMap.get(field).add(value.trim());
                                            }
                                        } else {
                                            tempMap.get(field).add(String.valueOf(oppoMap.get(oppId).get(field)));
                                        }
                                    }
                                }
                            }
                        }
                        oppProductsPicklistFieldValues.get(accountId).putAll(tempMap);
                    }
                
                }
                
                //create new field value accountAttributes
                //query all the parent along with child attributes of the mapping
                for (Attribute__c att : WithoutSharingHelperController.getAttributesForUpdateRBI1(oppMappingIds, attMappingAccount)) {
                    
                    if (attMappingAccount.containsKey(att.Attribute_Mapping__r.Id)
                                && attMappingAccount.get(att.Attribute_Mapping__r.Id) != null
                                && att.Attribute_Mapping__r.Auto_populate__c) {
                        
                        for (Account acc : attMappingAccount.get(att.Attribute_Mapping__r.Id)) {
                            
                            if (!mappingCreateAttribute.containsKey(acc.Id)) {
                                mappingCreateAttribute.put(acc.Id, new Set<Id>());
                            }
                            
                            for (Attribute__c childAtt : att.Attributes__r) {
                                
                                for (String strAtt : String.valueOf(acc.get(att.Attribute_Mapping__r.Field_Api_Name__c)).split(';')) {
                                    
                                    if (strAtt == childAtt.Name
                                                && !preventDuplicacy.contains(acc.Id + '' + childAtt.Id)
                                                && !allAccountAttributesAssociated.get(acc.Id).containsKey(childAtt.Id)) {
                                        
                                        createAccountAtt.add(new Account_Attribute__c(Account__c = acc.Id, Attribute__c = childAtt.Id, Is_fromMapping__c = true, Inheritable__c = att.Attribute_Mapping__r.Inheritable__c));
                                        preventDuplicacy.add(acc.Id + '' + childAtt.Id);

                                    }
                                }
                                
                                //if the accountattribute is not Set to inheritable but it needs to be
                                if (allAccountAttributesAssociated.containsKey(acc.Id)
                                            && allAccountAttributesAssociated.get(acc.Id).containsKey(childAtt.Id)
                                            && allAccountAttributesAssociated.get(acc.Id).get(childAtt.Id).Inheritable__c != att.Attribute_Mapping__r.Inheritable__c) {
                                    
                                    if (att.Attribute_Mapping__r.Inheritable__c) {
                                        allAccountAttributesAssociated.get(acc.Id).get(childAtt.Id).Inheritable__c = att.Attribute_Mapping__r.Inheritable__c;
                                        createAccountAtt.add(allAccountAttributesAssociated.get(acc.Id).get(childAtt.Id));
                                    }
                                }
                                
                                for (String strAtt : String.valueOf(acc.get(att.Attribute_Mapping__r.Field_Api_Name__c)).split(';')) {
                                    
                                    if (strAtt == childAtt.Name) {
                                        mappingCreateAttribute.get(acc.Id).add(childAtt.Id);
                                    }
                                }
                            }
                        }
                    } else if (oppMappingIds.contains(att.Attribute_Mapping__r.Id)) {
                        
                        for (String accountId : oppAccountMap.keySet()) {
                            
                            if (!mappingCreateAttribute.containsKey(accountId)) {
                                mappingCreateAttribute.put(accountId, new Set<Id>());
                            }
                            //re #741
                            Map<String, Set<String>> tempMap = (oppProductsPicklistFieldValues.containsKey(accountId) ? 
                                                                        oppProductsPicklistFieldValues.get(accountId) :
                                                                        new Map<String, Set<String>>());
                            
                            if (tempMap != null && tempMap.containsKey(att.Attribute_Mapping__r.Field_Api_Name__c) 
                                                        && att.Attribute_Mapping__r.Field_Api_Name__c != 'Product2') {
                                Set<String> fieldValues = tempMap.get(att.Attribute_Mapping__r.Field_Api_Name__c);
                                
                                for (Attribute__c childAtt : att.Attributes__r) {
                                    
                                    if (fieldValues.contains(childAtt.Name)
                                                && !preventDuplicacy.contains(accountId + '' + childAtt.Id)
                                                && !allAccountAttributesAssociated.get(accountId).containsKey(childAtt.Id)) {
                                        
                                        createAccountAtt.add(new Account_Attribute__c(Account__c = accountId,
                                                                                        Attribute__c = childAtt.Id,
                                                                                        From_Opportunity__c = true, Inheritable__c = att.Attribute_Mapping__r.Inheritable__c));
                                        preventDuplicacy.add(accountId + '' + childAtt.Id);
                                    }
                                    
                                    if (fieldValues.contains(childAtt.Name)) {
                                        mappingCreateAttribute.get(accountId).add(childAtt.Id);
                                    }
                                }
                            //re #741
                            } else if (att.Attribute_Mapping__r.Field_Api_Name__c == 'Product2') {
                                
                                for (Attribute__c childAtt : att.Attributes__r) {
                                    
                                    for (String oppId : oppAccountMap.get(accountId)) {
                                        
                                        if (oppProductMap != null && oppProductMap.containsKey(oppId)) {
                                            
                                            for (String productId : oppProductMap.get(oppId)) {
                                                
                                                if (childAtt.Product_ID__c == productId && !preventDuplicacy.contains(accountId + '' + childAtt.Id) 
                                                                    && !allAccountAttributesAssociated.get(accountId).containsKey(childAtt.Id)) {
                                                    createAccountAtt.add(new Account_Attribute__c(Account__c = accountId, Attribute__c = childAtt.Id, From_Opportunity__c = true, Inheritable__c = att.Attribute_Mapping__r.Inheritable__c));
                                                    preventDuplicacy.add(accountId + '' + childAtt.Id);
                                                }
                                                
                                                if (childAtt.Product_ID__c == productId) {
                                                    mappingCreateAttribute.get(accountId).add(childAtt.Id);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                for (String accId : accountAttributesAssociated.keySet()) {
                    
                    for (Id attId : accountAttributesAssociated.get(accId).keySet()) {
                        
                        if (mappingCreateAttribute != null
                                    && mappingCreateAttribute.containsKey(accId)
                                    && !mappingCreateAttribute.get(accId).contains(attId)
                                    && accountAttributesAssociated != null
                                    && accountAttributesAssociated.containsKey(accId)
                                    && accountAttributesAssociated.get(accId).containsKey(attId)) {
                            
                            accAttToBeDeleted.add(accountAttributesAssociated.get(accId).get(attId));
                        }
                    }
                }
                
                for (String accId : accountAttributesAssociatedOpp.keySet()) {
                    
                    for (Id attId : accountAttributesAssociatedOpp.get(accId).keySet()) {
                        
                        if (mappingCreateAttribute != null
                                    && mappingCreateAttribute.containsKey(accId)
                                    && !mappingCreateAttribute.get(accId).contains(attId)
                                    && accountAttributesAssociatedOpp != null
                                    && accountAttributesAssociatedOpp.containsKey(accId)
                                    && accountAttributesAssociatedOpp.get(accId).containsKey(attId)) {
                            
                            accAttToBeDeleted.add(accountAttributesAssociatedOpp.get(accId).get(attId));
                        }
                    }
                }
                
                /*
                *   REF-2070 (Rajneesh Raj, Jan 03,2019)
                *   Delete Contact Attribute if that attribute is inheritable and inherited from Account
                */
                List<Contact_Attribute__c> contactsAttsToBeDel = new List<Contact_Attribute__c>();

                for (Contact_Attribute__c ca : [SELECT Id, Attribute__c, Account__c FROM Contact_Attribute__c
                                                WHERE Account__c IN :accountAttributesAssociatedOpp.keySet()
                                                AND From_Account__c = true]) {
                    
                    for (Account_Attribute__c accAtt : accAttToBeDeleted) {
                        
                        if (ca.Account__c == accAtt.Account__c && ca.Attribute__c == accAtt.Attribute__c) {
                            contactsAttsToBeDel.add(ca); 
                        }                
                    }
                }
                
                ConstantsController.attMappingForAccount = false;
                ConstantsController.attMappingForContact = false;
                
                if (contactsAttsToBeDel.size() > 0) {
                    WithoutSharingHelperController.deleteContactAttributes(contactsAttsToBeDel);
                    Database.emptyRecycleBin(contactsAttsToBeDel);
                }

                if (accAttToBeDeleted.size() > 0) {
                    //re #741
                    accAttToBeDeleted = WithoutSharingHelperController.deleteAccountAttributes(accAttToBeDeleted);
                    Database.emptyRecycleBin( accAttToBeDeleted );
                }
                
                if (createAccountAtt.size() > 0) {
                    ConstantsController.addAttributesToContact = true;
                    ConstantsController.addAttributesToContent = true;
                    WithoutSharingHelperController.upsertAccountAttributes(createAccountAtt);
                }
            }
        } catch (exception e) {
            throw e;
        }
    }
    
    /**
     * Method to update Contact RUL setting
     */
    static void updateContactRul(Map<Id, Reference_Basic_Information__c> updateAccountFieldMapForRul) {
        Map<Id, List<Reference_Basic_Information__c>> accountContactMap = new Map<Id, List<Reference_Basic_Information__c>>();
        List<Reference_Basic_Information__c> updatedContacts = new List<Reference_Basic_Information__c>();
        
        for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getRBIsForUpdateRBI1(updateAccountFieldMapForRul)) {
            
            if (!accountContactMap.containsKey(rbi.Account__c)) {
                accountContactMap.put(rbi.Account__c, new List<Reference_Basic_Information__c>());
            }
            accountContactMap.get(rbi.Account__c).add(rbi);
        }
        
        for (Id accId : accountContactMap.keySet()) {
            
            if (updateAccountFieldMapForRul.get(accId).Account_Level_RUL__c == true) {
                
                for (Reference_Basic_Information__c rbi : accountContactMap.get(accId)) {
                    rbi.RUL_Period__c = null;
                    rbi.RUL_Activities_will_do__c = null;
                    updatedContacts.add(rbi);
                }
            } else if (updateAccountFieldMapForRul.get(accId).Account_Level_RUL__c == false) {
                
                for (Reference_Basic_Information__c rbi : accountContactMap.get(accId)) {
                    rbi.RUL_Period__c = cs.RUL_Period_Contact__c;
                    rbi.RUL_Activities_will_do__c = cs.RUL_Activities_Contact__c;
                    updatedContacts.add(rbi);
                }
            }
        }
        
        if (updatedContacts.size() > 0) {
            WithoutSharingHelperController.upsertRBI(updatedContacts);
        }
    }
    
    /**
     * Method called on update Contact type Reference Profile
     */
    static void onUpdateContactTypeRBI(List<Reference_Basic_Information__c> contactTypeRBIList,
                                        Map<Id, Reference_Basic_Information__c> oldMap,
                                        Map<Id, Reference_Basic_Information__c> newMap) {
        
        Set<Id> referenceabilityCheckforUpdation = new Set<Id>();
        Set<Id> referenceabilityCheckforDeletion = new Set<Id>();
        List<Reference_Basic_Information__c> contactsForRulHandling = new List<Reference_Basic_Information__c>();
        Set<Id> inactiveContacts = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<String> relatedAccountIds = new Set<String>();
        Map<Id,String> candidateContactIDs = new Map<Id,String>();
        Set<Id> contactIdsForAttMapping = new Set<Id>();
        Set<String> rbicontactIds = new Set<String>();
        //Shared Contact code start
        Set<String> sharedAccountIds = new Set<String>();
        Set<String> sharedContactIds = new Set<String>();
        Map<Id, Set<Id>> accountContactMap = new Map<Id, Set<Id>>(); 
        Map<Id, Set<Id>> contactAccountMap = new Map<Id, Set<Id>>();
        List<Reference_Note__c> notes = new List<Reference_Note__c>();
        Map<Id,List<Account_Attribute__c>> accToAtt = new Map<Id,List<Account_Attribute__c>>();
        //end
        //for Influitive integration 
        Set<String> setContactId = new Set<String>();
        
        for (Reference_Basic_Information__c rbi : contactTypeRBIList) {
            relatedAccountIds.add(rbi.Account__c);
            rbicontactIds.add(rbi.Contact__c);
            
            if (oldMap.get(rbi.Id).Reference_Program_Candidate__c != newMap.get(rbi.Id).Reference_Program_Candidate__c || oldMap.get(rbi.Id).Is_Referenceable__c != newMap.get(rbi.Id).Is_Referenceable__c) {
                String oldType = oldMap.get(rbi.Id).Is_Referenceable__c ? 'Member' : oldMap.get(rbi.Id).Reference_Program_Candidate__c ? 'Candidate' : '';
                String newType = newMap.get(rbi.Id).Is_Referenceable__c ? 'Member' : newMap.get(rbi.Id).Reference_Program_Candidate__c ? 'Candidate' : '';
                Boolean isSetToNone = !newMap.get(rbi.Id).Reference_Program_Candidate__c && !newMap.get(rbi.Id).Is_Referenceable__c;
                candidateContactIDs.put(newMap.get(rbi.Id).Contact__c,oldType + '@@' + newType + '@@' + isSetToNone);
            }
            
            if ((oldMap.get(rbi.Id).Referenceability_Status__c == null
                            || oldMap.get(rbi.Id).Referenceability_Status__c == ConstantsController.INACTIVE)
                        && (newMap.get(rbi.Id).Referenceability_Status__c == ConstantsController.ACTIVE
                            || newMap.get(rbi.Id).Referenceability_Status__c == ConstantsController.CAUTION)) {
                
                contactsForRulHandling.add(newMap.get(rbi.Id));
                referenceabilityCheckforUpdation.add(rbi.Id);
                
                //Shared Contact
                sharedAccountIds.add(rbi.Account__c);
                sharedContactIds.add(rbi.Contact__c);
                contactAccountMap.put(rbi.Contact__c, new Set<Id>());
                
                //for Influitive integration 
                if (rbi.Is_Referenceable__c && rbi.Contact__c != null && rbi.Influitive_Id__c == null) {
                    setContactId.add(rbi.Contact__c);
                }
            } else if ((oldMap.get(rbi.Id).Referenceability_Status__c == ConstantsController.ACTIVE
                                || oldMap.get(rbi.Id).Referenceability_Status__c == ConstantsController.CAUTION)
                            && (newMap.get(rbi.Id).Referenceability_Status__c == ConstantsController.INACTIVE
                                || newMap.get(rbi.Id).Referenceability_Status__c == null)) {
                
                referenceabilityCheckforDeletion.add(rbi.Id);
                inactiveContacts.add(rbi.Contact__c);
                contactsForRulHandling.add(newMap.get(rbi.Id));
                accountIds.add(newMap.get(rbi.Id).Account__c);
            }
            
            if ((oldMap.get(rbi.Id).RUL_Period__c != newMap.get(rbi.Id).RUL_Period__c
                            || oldMap.get(rbi.Id).RUL_Activities_will_do__c != newMap.get(rbi.Id).RUL_Activities_will_do__c)
                        && (newMap.get(rbi.Id).Referenceability_Status__c == ConstantsController.ACTIVE
                            || newMap.get(rbi.Id).Referenceability_Status__c == ConstantsController.CAUTION)) {
                
                contactsForRulHandling.add(newMap.get(rbi.Id));
            } else if (oldMap.get(rbi.Id).RUL_Limit_Reached__c != newMap.get(rbi.Id).RUL_Limit_Reached__c) {
                contactsForRulHandling.add(newMap.get(rbi.Id));
            }
            
            if (rbi.Reference_Program_Candidate__c || rbi.Is_Referenceable__c) {
                contactIdsForAttMapping.add(newMap.get(rbi.Id).contact__c);
            }
            
             //#890 -Creating notes if RBI created incative using custom setting.
            if (oldMap.get(rbi.Id).Referenceability_Status__c != newMap.get(rbi.Id).Referenceability_Status__c 
                        && rbi.Referenceability_Status__c != null && rbi.Referenceability_Status__c == 'Inactive' 
                        && rbi.inactive_reason__c != null && rbi.inactive_reason__c.contains('Reference Profile Set to Inactive when initially created')) {  
                notes.add(new Reference_Note__c(Contact__c = rbi.Contact__c, 
                                                Note__c = System.Label.Reason_For_Inactive + ' '+ 'Reference Profile Set to Inactive when initially created.')); 
            } 
        }
        
        if (candidateContactIDs.size() > 0 && ConstantsController.shouldCandidateRequestDelete) {
            List<Reference_Note__c> notesAR = updateCandidateConRequest(candidateContactIDs);
            notes.addAll(notesAR); 
        }
        
        //Shared Contact start
        if (cs.Shared_Contacts__c) {
            String objectName = cs.Shared_Contact_Object__c;
            String accountField = cs.Shared_Account_Field__c;
            String contactField = cs.Shared_Contact_Field__c;
            
            if (accountField != null && accountField != '' && contactField != null && contactField != '') {
                
                String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName
                                 + ' WHERE ' + contactField + ' IN :sharedContactIds';
                List<sObject> objectList = WithoutSharingHelperController.getSharedContactsForUpdateRBI1(sharedContactIds, query);
                
                if (objectList != null && objectList.size() > 0) {
                    
                    for (sObject obj : objectList) {
                        
                        if (contactAccountMap.containsKey((String)obj.get(contactField))) {
                            sharedAccountIds.add((String)obj.get(accountField));
                            contactAccountMap.get((String)obj.get(contactField)).add((String)obj.get(accountField));
                        }
                        
                        if (accountContactMap != null && !accountContactMap.containsKey((String)obj.get(accountField))) {
                            accountContactMap.put((String)obj.get(accountField), new Set<Id>());
                        }
                        accountContactMap.get((String)obj.get(accountField)).add((String)obj.get(contactField));
                    }
                }
            }
        }
        //Shared Contact end
        
        if (referenceabilityCheckforUpdation.size() > 0) {
            
            //Shared Contact start
            if (cs.Shared_Contacts__c && sharedAccountIds.size() > 0) {
                List<Account> accountsWithRelatedRecords = WithoutSharingHelperController.getAccountRecordsWithAllRelatedRecordsAndOnlyAccRBI(sharedAccountIds);
                List<Account> accountsWithRelatedRecordsforRef = new List<Account>();
                
                for (Account acc : accountsWithRelatedRecords) {
                    
                    if (contactAccountMap != null && !contactAccountMap.containsKey(acc.Id)) {
                        accountsWithRelatedRecordsforRef.add(acc);
                    }
                }
                updateAttributeOnAccountSharedContact(contactsForRulHandling, new List<Contact_Attribute__c>(), accountsWithRelatedRecords, contactAccountMap, new Set<String>());
                updateReferenceabilityAccount(contactTypeRBIList, accountsWithRelatedRecords, contactAccountMap);
                addAttributesOnContactSharedContact(contactsForRulHandling, accountsWithRelatedRecords, accountContactMap);
            } else {    //Shared Contact end
                List<Account> accountsWithRelatedRecords = WithoutSharingHelperController.getAccountRecordsWithAllRelatedRecordsAndOnlyAccRBI(relatedAccountIds);
                for (Account_Attribute__c accAtr : WithoutSharingHelperController.getAccountAttributesForAccount(relatedAccountIds)){
                    if (!accToAtt.containsKey(accAtr.Account__c)) {
                        accToAtt.put(accAtr.Account__c, new List<Account_Attribute__c>());
                    }
                    accToAtt.get(accAtr.Account__c).add(accAtr);
                }
                updateAttributeOnAccount(contactsForRulHandling, new List<Contact_Attribute__c>(), accountsWithRelatedRecords,accToAtt);
                updateReferenceabilityAccount(contactTypeRBIList, accountsWithRelatedRecords, new Map<Id, Set<Id>>());
                addAttributesOnContact(contactsForRulHandling, accountsWithRelatedRecords,accToAtt);
            }
        } else if (referenceabilityCheckforDeletion.size() > 0) {
            List<Account> accountsWithRelatedRecords = WithoutSharingHelperController.getAccountRecordsWithAllRelatedRecordsAndOnlyAccRBI(relatedAccountIds);
            deleteAttributeFromAccount(inactiveContacts, accountIds);
            updateReferenceabilityAccount(contactTypeRBIList, accountsWithRelatedRecords, new Map<Id, Set<Id>>());
        }
        
        if (contactsForRulHandling.size() > 0) {
            updateAccountRulSettings(contactsForRulHandling);
        }
        
        if (ConstantsController.attMappingForContact && contactIdsForAttMapping.size() > 0) {
            
            if (Test.isRunningTest() || System.isBatch() || System.isFuture()) {
                checkForAttributeMappingContact(contactIdsForAttMapping);
            } else {
                ConstantsController.attMappingForContact = false;
                checkForAttributeMappingContactFuture(contactIdsForAttMapping);
            }
        }
        
        /*
         * for --> ReferenceEdge Attribute, Mapped Attribute Reporting question
         * Set Reference_Basic_Information__c in Account Attribute
         * by Rekha
         */
        if (ConstantsController.updateRBIInConAttributes && rbicontactIds.size() > 0) {
            List<Contact_Attribute__c> contactAttributes = new List<Contact_Attribute__c>();
            
            for (Contact con : WithoutSharingHelperController.activateContactRecords(rbicontactIds)) {
                String rbiId = con.Reference_Basic_Informations__r[0].Id;
                
                for (Contact_Attribute__c att : con.Contact_Attributes__r) {
                    
                    if (att.Reference_Basic_Information__c == null) {
                        att.Reference_Basic_Information__c = rbiId;
                        contactAttributes.add(att);
                    }
                }
            }
            
            if (contactAttributes.size() > 0) {
                ConstantsController.stopConAttributeTrigger = true;
                WithoutSharingHelperController.upsertContactAttributes(contactAttributes);
                ConstantsController.stopConAttributeTrigger = false;
            }
            ConstantsController.updateRBIInConAttributes = false;
        }   //end
         
        //for Influitive integration 
        if (!Test.isRunningTest()
                    && !system.isBatch()
                    && !system.isFuture()
                    && cs.Is_Influitive_Integration_Enabled__c != null
                    && cs.Is_Influitive_Integration_Enabled__c
                    && ConstantsController.isInfluitiveNotRunning) {
            
            Map<Id, Contact> contactMap = WithoutSharingHelperController.getContacts(setContactId);
            List<Contact> contactList = new List<Contact>();

            for (Reference_Basic_Information__c rbi : contactTypeRBIList) {
                
                if (rbi.Influitive_Id__c == null && contactMap != null && contactMap.containsKey(rbi.Contact__c)) {
                   contactList.add(contactMap.get(rbi.Contact__c));
                }
            }
            if (contactList.Size() > 0) {
                String jsonString = JSON.serialize(contactList);
                Infl_Member.influitiveMembersCallout(jsonString);
            } 
        }
        
        // Insert Notes:
        if (notes.size() > 0) {
            WithoutSharingHelperController.insertReferenceNotes(notes);
        }
    }
    
    @future
    private static void checkForAttributeMappingContactFuture(Set<Id> contactIdsForAttMapping) {
        checkForAttributeMappingContact(contactIdsForAttMapping);
    }
    
    /**
     * Method to check for Contact Attribute Mapping 
     */
    static void checkForAttributeMappingContact(Set<Id> contactIdsForAttMapping) {
        ConstantsController.attMappingForContact = false;
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Contact.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        Set<String > fieldAPINames = new Set<String>();
        
        try {
            String theQuery = 'SELECT Id, Name, ';
            
            for (Schema.SObjectField s : fldObjMapValues) {
                Schema.DescribeFieldResult fieldDesc = s.getDescribe();
                
                if (fieldDesc.getType() == Schema.DisplayType.PICKList|| fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    String theName = fieldDesc.getName();
                    // Continue building your dynamic query String
                    theQuery += theName + ',';
                    fieldAPINames.add(theName);
                }
            }
            theQuery = theQuery.subString(0, theQuery.length() - 1);
            theQuery += ' FROM Contact WHERE Id IN :contactIdsForAttMapping';
            List<Contact> contacts = WithoutSharingHelperController.getContactsUsingDynamicSOQL(theQuery, contactIdsForAttMapping);
            List<Attribute_Mapping__c> attMappings = new List<Attribute_Mapping__c>();
            
            for (Attribute_Mapping__c attM : WithoutSharingHelperController.getAttMappingsForUpdateRBI(fieldAPINames)) {
                
                if (fldObjMap.containsKey(attM.Field_Api_Name__c.tolowerCase())) {
                    attMappings.add(attM);
                }
            }
            Map<String, List<Contact >> attMappingContact = new Map<String, List<Contact>>();
            Set<Id> mappingCreateAttribute = new Set<Id>();
            Map<String, Set<String>> ContactFieldAttDelete = new Map<String, Set<String>>();
            List<Contact_Attribute__c> deleteContactAtt = new List<Contact_Attribute__c>();
            List<Contact_Attribute__c> createContactAtt = new List<Contact_Attribute__c>();
            Map<Id, Map<Id, Contact_Attribute__c>> contactAttributesAssociated = new Map<Id, Map<Id, Contact_Attribute__c>>();
            Map<Id, Map<Id, Contact_Attribute__c>> allContactAttributesAssociated = new Map<Id, Map<Id, Contact_Attribute__c>>();
            List<Contact_Attribute__c> conAttToBeDeleted = new List<Contact_Attribute__c>();
            Set<String> preventDuplicacy = new Set<String>();
            Set<String> deleteAttMapping = new Set<String>();
            Set<Id> attMappingUpdateAndDelete = new Set<Id>();
            
            //create a Map of attributMapping and accounts in which the field value is not null
            if (attMappings.size() > 0) {
                
                for (Contact con : Contacts) {
                    
                    for (Attribute_Mapping__c attMapping : attMappings) {
                        
                        if (con.get(attMapping.Field_Api_Name__c) != null && attMapping.Auto_populate__c) {
                            
                            if (!attMappingContact.containsKey(attMapping.Id)) {
                                attMappingContact.put(attMapping.Id, new List<Contact>());
                            }
                            attMappingContact.get(attMapping.Id).add(con);
                        }
                        
                        if (attMapping.Auto_add__c || attMapping.Auto_Update__c || attMapping.Auto_delete__c) {
                            attMappingUpdateAndDelete.add(attMapping.Id);
                        }
                    }
                    contactAttributesAssociated.put(con.Id, new Map<Id, Contact_Attribute__c>());
                    allContactAttributesAssociated.put(con.Id, new Map<Id, Contact_Attribute__c>());
                }
                UtilityController.checkAttributeMappingEdit(attMappingUpdateAndDelete, 'Contact');
                
                //delete the previous field value attributes
                for (Contact_Attribute__c conAtt : WithoutSharingHelperController.getContactAttributesInRBI3(Contacts)) {
                    
                    if (conAtt.Is_fromMapping__c) {
                        contactAttributesAssociated.get(conAtt.Contact__r.Id).put(conAtt.Attribute__r.Id, conAtt);
                    }
                    allContactAttributesAssociated.get(conAtt.Contact__r.Id).put(conAtt.Attribute__r.Id, conAtt);
                }
                
                //create new field value accountAttributes
                //query all the parent along with child attributes of the mapping
                for (Attribute__c att : WithoutSharingHelperController.getAttributesForUpdateRBI1(attMappingContact)) {
                    
                    if (attMappingContact.get(att.Attribute_Mapping__r.Id) != null
                                && att.Attribute_Mapping__r.Auto_populate__c) {
                        
                        for (Contact con : attMappingContact.get(att.Attribute_Mapping__r.Id)) {
                            
                            for (Attribute__c childAtt : att.Attributes__r) {
                                
                                for (String strAtt : String.valueOf(con.get(att.Attribute_Mapping__r.Field_Api_Name__c)).split(';')) {
                                    
                                    if (strAtt == childAtt.Name
                                                && !preventDuplicacy.contains(con.Id + '' + childAtt.Id)
                                                && !allContactAttributesAssociated.get(con.Id).containsKey(childAtt.Id)) {
                                        
                                        createContactAtt.add(new Contact_Attribute__c(Contact__c = con.Id, Attribute__c = childAtt.Id, Is_fromMapping__c = true));
                                        preventDuplicacy.add(con.Id + '' + childAtt.Id);
                                    }
                                    
                                    if (strAtt == childAtt.Name) {
                                        mappingCreateAttribute.add(childAtt.Id);
                                    }
                                }
                            }
                        }
                    }
                }
                
                for (String conId : contactAttributesAssociated.keySet()) {
                    
                    for (Id attId : contactAttributesAssociated.get(conId).keySet()) {
                        
                        if (!mappingCreateAttribute.contains(attId)
                                    && contactAttributesAssociated.get(conId).containsKey(attId)) {
                            conAttToBeDeleted.add(contactAttributesAssociated.get(conId).get(attId));
                        }
                    }
                }
                
                if (conAttToBeDeleted.size() > 0) {
                    WithoutSharingHelperController.deleteContactAttributes(conAttToBeDeleted);
                }
                
                if (createContactAtt.size() > 0) {
                    ConstantsController.fromaccount = false;
                    WithoutSharingHelperController.upsertContactAttributes(createContactAtt);
                }
            }
        } catch (Exception e) {
            throw e;
        }
    }
    
    /**
     * Method to update Attribute on Account
     */
    private static void updateAttributeOnAccount(List<Reference_Basic_Information__c> newcontactTypeRBIList,
                                                    List<Contact_Attribute__c> contactAttributes,
                                                    List<Account> accounts, Map<Id,List<Account_Attribute__c>> accToAtt) {
        
        Set<Id > accountIds = new Set<Id>();
        Map<Id, Set<Id>> accountAttributeMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> contactAttributMap = new Map<Id, Set<Id>>();
        Map<Id, Id> contactAccountMap = new Map<Id, Id>();
        Set<String> modifiedContactIDs = new Set<String>();
        Set<String> preventDuplicacy = new Set<String>();
        Account_Attribute__c tempObj;
        Map<Id, Reference_Basic_Information__c> accountRBI = new Map<Id, Reference_Basic_Information__c>();
        List<Account_Attribute__c> newAccountAttribute = new List<Account_Attribute__c>();
        
        for (Reference_Basic_Information__c rbi : newcontactTypeRBIList) {
            
            if (rbi.Is_Referenceable__c) {
                modifiedContactIDs.add(rbi.Contact__c);
                contactAccountMap.put(rbi.Contact__c, rbi.Account__c);
                accountAttributeMap.put(rbi.Account__c, new Set<Id>());
            }
        }
        
        if (!(contactAttributes.size() > 0) && modifiedContactIDs.size() > 0) {
            contactAttributes = WithoutSharingHelperController.getContactAttributesInRBI4(modifiedContactIDs);
        }
        
        for (Contact_Attribute__c cA : contactAttributes) {
            
            if (!contactAttributMap.containsKey(cA.Contact__c)) {
                contactAttributMap.put(cA.Contact__c, new Set<Id>());
            }
            contactAttributMap.get(cA.Contact__c).add(cA.Attribute__c);
        }
        
        for (Account acc : accounts) {
            
            for (Reference_Basic_Information__c rbi : acc.Reference_Basic_Informations__r) {
                
                if (rbi.Contact__c == null) {
                    accountRBI.put(acc.Id, rbi);
                }
            }
            if (accToAtt.containsKey(acc.Id)) {
                for (Account_Attribute__c accAtt : accToAtt.get(acc.Id)) {
                    if (accAtt.Contact__c != null && contactAttributMap.containsKey(accAtt.Contact__c)) {
                        
                        if (!accountAttributeMap.containsKey(accAtt.Account__c)) {
                            accountAttributeMap.put(accAtt.Account__c, new Set<Id>());
                        }
                        accountAttributeMap.get(accAtt.Account__c).add(accAtt.Attribute__c);
                    }
                }
            }
        }
        Set<String> oppAttributes = new Set<String>();
        
        for (Attribute__c att : WithoutSharingHelperController.getAttributesForUpdateRBI()) {
            
            for (Attribute__c att1 : att.Attributes__r) {
                oppAttributes.add(att1.Id);
            }
        }
        
        for (Id contactId : contactAccountMap.keySet()) {
            
            if (contactAttributMap.get(contactId) != null) {
                
                for (Id attId : contactAttributMap.get(contactId)) {
                    
                    if (!oppAttributes.contains(attId)
                                && accountRBI.containsKey(contactAccountMap.get(contactId))
                                && accountRBI.get(contactAccountMap.get(contactId)).Is_Referenceable__c
                                && accountAttributeMap.get(contactAccountMap.get(contactId)) != null
                                && !accountAttributeMap.get(contactAccountMap.get(contactId)).contains(attId)
                                && !preventDuplicacy.contains(contactId + '' + attId)) {
                        
                        tempObj = new Account_Attribute__c();
                        tempObj.Account__c = contactAccountMap.get(contactId);
                        tempObj.Attribute__c = attId;
                        tempObj.Contact__c = contactId;
                        newAccountAttribute.add(tempObj);
                        preventDuplicacy.add(contactAccountMap.get(contactId) + '' + attId);
                    } else if (!oppAttributes.contains(attId)
                                    && accountRBI.containsKey(contactAccountMap.get(contactId))
                                    && accountRBI.get(contactAccountMap.get(contactId)).Is_Referenceable__c
                                    && accountAttributeMap.get(contactAccountMap.get(contactId)) == null) {
                        
                        tempObj = new Account_Attribute__c();
                        tempObj.Account__c = contactAccountMap.get(contactId);
                        tempObj.Attribute__c = attId;
                        tempObj.Contact__c = contactId;
                        preventDuplicacy.add(contactId + '' + attId);
                        newAccountAttribute.add(tempObj);
                    }
                }
            }
        }
        
        if (newAccountAttribute.size() > 0) {
            ConstantsController.addAttributesToContact = false;
            ConstantsController.addAttributesToContent = false;
            ConstantsController.addParentToAccount = false;
            WithoutSharingHelperController.upsertAccountAttributes(newAccountAttribute);
        }
    }
    
    /**
     * Method to update Attribute on Account when shared contact is enabled
     */
    private static void updateAttributeOnAccountSharedContact(List<Reference_Basic_Information__c> newcontactTypeRBIList,
                                                                List<Contact_Attribute__c> contactAttributes,
                                                                List<Account> accounts,
                                                                Map<Id, Set<Id>> contactAccountMap,
                                                                Set<String> sharedContactIds) {
        
        Set<Id > accountIds = new Set<Id>();
        Map<Id, Set<Id >> accountAttributeMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id >> contactAttributMap = new Map<Id, Set<Id>>();
        Set<String > modifiedContactIDs = new Set<String>();
        Set<String> preventDuplicacy = new Set<String>();
        Account_Attribute__c tempObj;
        Map<Id, Reference_Basic_Information__c> accountRBI = new Map<Id, Reference_Basic_Information__c>();
        List<Account_Attribute__c> newAccountAttribute = new List<Account_Attribute__c>();
        
        for (Reference_Basic_Information__c rbi : newcontactTypeRBIList) {
            
            if (rbi.Is_Referenceable__c) {
                boolean addRefToAllAccountsRBI = (rbi.Roll_up_Attributes_to_All_Accounts__c ? true : (rbi.Roll_up_Attributes_to_Primary_Account__c ? false : (cs.Roll_up_Attributes_to_All_Accounts__c)));
                modifiedContactIDs.add(rbi.Contact__c);
                
                if (!contactAccountMap.containsKey(rbi.Contact__c)) {
                    contactAccountMap.put(rbi.Contact__c, new Set<Id>{rbi.Account__c});
                } else if (contactAccountMap.containsKey(rbi.Contact__c)
                                && !contactAccountMap.get(rbi.Contact__c).contains(rbi.Account__c)
                                && !sharedContactIds.contains(rbi.Account__c)) {
                    
                    if (addRefToAllAccountsRBI) {
                        contactAccountMap.get(rbi.Contact__c).add(rbi.Account__c);
                    } else {
                        contactAccountMap.get(rbi.Contact__c).clear();
                        contactAccountMap.get(rbi.Contact__c).add(rbi.Account__c);
                    }
                }
                accountAttributeMap.put(rbi.Account__c, new Set<Id>());
            }
        }
        
        if (!(contactAttributes.size() > 0) && modifiedContactIDs.size() > 0) {
            contactAttributes = WithoutSharingHelperController.getContactAttributesInRBI4(modifiedContactIDs);
        }
        
        for (Contact_Attribute__c cA : contactAttributes) {
            
            if (!contactAttributMap.containsKey(cA.Contact__c)) {
                contactAttributMap.put(cA.Contact__c, new Set<Id>());
            }
            contactAttributMap.get(cA.Contact__c).add(cA.Attribute__c);
        }
        
        for (Account acc : accounts) {
            
            for (Reference_Basic_Information__c rbi : acc.Reference_Basic_Informations__r) {
                
                if (rbi.Contact__c == null) {
                    accountRBI.put(acc.Id, rbi);
                }
            }
            
            for (Account_Attribute__c accAtt : acc.Account_Attributes__r) {
                
                if (accAtt.Contact__c != null && contactAttributMap.containsKey(accAtt.Contact__c)) {
                    
                    if (!accountAttributeMap.containsKey(accAtt.Account__c)) {
                        accountAttributeMap.put(accAtt.Account__c, new Set<Id>());
                    }
                    accountAttributeMap.get(accAtt.Account__c).add(accAtt.Attribute__c);
                }
            }
        }
        Set<String> oppAttributes = new Set<String>();
        
        for (Attribute__c att : WithoutSharingHelperController.getAttributesForUpdateRBI()) {
            
            for (Attribute__c att1 : att.Attributes__r) {
                oppAttributes.add(att1.Id);
            }
        }
        
        for (Id contactId : contactAccountMap.keySet()) {
            
            if (contactAttributMap.get(contactId) != null
                        && contactAttributMap.get(contactId).size() > 0
                        && contactAccountMap.get(contactId).size() > 0) {
                
                for (Id attId : contactAttributMap.get(contactId)) {
                    
                    for (Id accountId : contactAccountMap.get(contactId)) {
                        
                        if ((ConstantsController.copyExistingAtt
                                    || (!ConstantsController.copyExistingAtt
                                        && ConstantsController.contactId != contactId)
                                    || (!ConstantsController.copyExistingAtt
                                        && ConstantsController.contactId == contactId
                                        && ConstantsController.attributeIdsinCopyNomi.contains(attId)))) {
                            
                            if (!oppAttributes.contains(attId)
                                        && accountRBI.containsKey(accountId)
                                        && accountRBI.get(accountId).Is_Referenceable__c
                                        && accountAttributeMap.get(accountId) != null
                                        && !accountAttributeMap.get(accountId).contains(attId)
                                        && !preventDuplicacy.contains(accountId + '' + contactId + ''  + attId)) {
                                
                                tempObj = new Account_Attribute__c();
                                tempObj.Account__c = accountId;
                                tempObj.Attribute__c = attId;
                                tempObj.Contact__c = contactId;
                                newAccountAttribute.add(tempObj);
                                preventDuplicacy.add(accountId + '' + contactId + '' + attId);
                            } else if (!oppAttributes.contains(attId)
                                        && accountRBI.containsKey(accountId)
                                        && accountRBI.get(accountId).Is_Referenceable__c
                                        && accountAttributeMap.get(accountId) == null) {
                                
                                tempObj = new Account_Attribute__c();
                                tempObj.Account__c = accountId;
                                tempObj.Attribute__c = attId;
                                tempObj.Contact__c = contactId;
                                preventDuplicacy.add(accountId + '' + contactId + '' + attId);
                                newAccountAttribute.add(tempObj);
                            }
                        }
                    }
                }
            }
        }
        
        if (newAccountAttribute.size() > 0) {
            ConstantsController.addAttributesToContact = false;
            ConstantsController.addAttributesToContent = false;
            ConstantsController.addParentToAccount = false;
            WithoutSharingHelperController.upsertAccountAttributes(newAccountAttribute);
        }
    }
    
    /**
     * Method to update Referenceability 
     */
    private static void updateReferenceabilityAccount(List<Reference_Basic_Information__c> newcontactTypeRBIList,
                                                        List<Account> accounts,
                                                        Map<Id, Set<Id>> contactAccountMap) {
        
        List<Referenceability__c> listReferenceability = new List<Referenceability__c>();
        List<Referenceability__c> deletelistReferenceability = new List<Referenceability__c>();
        Set<String> refIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        Set<String> accountIds = new Set<String>();
        List<Reference_Basic_Information__c> updateRBIs = new List<Reference_Basic_Information__c>();
        //Update Referenceability
        Map<Id, Reference_Basic_Information__c> contactsMap = new Map<Id, Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> accountsMap = new Map<Id, Reference_Basic_Information__c>();
        
        for (Reference_Basic_Information__c rbiId : newcontactTypeRBIList) {
            
            if (rbiId.Account__c != null && rbiId.Contact__c != null) {
                contactIds.add(rbiId.Contact__c);
                //for invalid query locater 
                contactsMap.put(rbiId.Contact__c, rbiId);
            }
            
            if (rbiId.Account__c != null) {
                accountIds.add(rbiId.Account__c);
            }
        }
        
        //commented for 101 Exception
        for (Account acc : accounts) {
            
            for (Reference_Basic_Information__c rbi : acc.Reference_Basic_Informations__r) {
                
                if (rbi.Contact__c != null) {
                    contactsMap.put(rbi.Contact__c, rbi);
                } else if (rbi.Contact__c == null) {
                    accountsMap.put(rbi.Account__c, rbi);
                }
            }
        }

        for (Referenceability__c ref : WithoutSharingHelperController.getReferenceabilitiesForUpdateRBI(accountIds, contactIds)) {

            if (contactIds.contains(ref.Contact__c)) {

                if (contactsMap.containsKey(ref.Contact__c)
                            && (contactsMap.get(ref.Contact__c).Referenceability_Status__c == ConstantsController.ACTIVE
                                || contactsMap.get(ref.Contact__c).Referenceability_Status__c == ConstantsController.CAUTION)) {
                    
                    if (accountsMap.containsKey(ref.Contact__r.AccountId)
                                && (accountsMap.get(ref.Contact__r.AccountId).Is_Referenceable__c
                                    || accountsMap.get(ref.Contact__r.AccountId).Reference_Program_Candidate__c)) {
                        ref.Account__c = ref.Contact__r.AccountId;
                        listReferenceability.add(ref);
                    }
                    
                    //shared contact code start
                    if (contactAccountMap != null && contactAccountMap.containsKey(ref.Contact__c)) {
                        
                        for (Id accountId : contactAccountMap.get(ref.Contact__c)) {
                            
                            if (ref.Contact__r.AccountId != accountId
                                        && accountsMap.containsKey(accountId)
                                        && (accountsMap.get(accountId).Is_Referenceable__c
                                            || accountsMap.get(accountId).Reference_Program_Candidate__c)) {
                                
                                Referenceability__c newRefer = new Referenceability__c();
                                newRefer.Contact__c = ref.Contact__c;
                                newRefer.Account__c = accountId;
                                newRefer.Status__c = ref.Status__c;
                                newRefer.Comment__c = ref.Comment__c;
                                newRefer.Verified__c = ref.Verified__c;
                                newRefer.Referenceability_Type__c = ref.Referenceability_Type__c;
                                listReferenceability.add(newRefer);
                            }
                        }
                    }
                } else {
                    
                    // shared contact code start
                    if (refIds.contains(ref.Referenceability_Type__c)) {
                        deletelistReferenceability.add(ref);
                    } else {    // end
                        ref.Account__c = null;
                        listReferenceability.add(ref);
                    }
                }
                
                if (ref.Account__c == null) {
                    refIds.add(ref.Referenceability_Type__c);
                }
            }
        }
        
        if (deletelistReferenceability.size() > 0) {
            WithoutSharingHelperController.deleteReferenceabilities(deletelistReferenceability);
        }
        
        if (listReferenceability.size() > 0) {
            WithoutSharingHelperController.upsertReferenceabilities(listReferenceability);
        }
    }
    
    /**
     * Method to delete Attribute from Account
     */
    private static void deleteAttributeFromAccount(Set<Id> contactIds, Set<Id> accountIds) {
        ConstantsController.deleteAttributeFromAccount = false;
        List<Account_Attribute__c> accountAttributesDelete = new List<Account_Attribute__c>();
        
        for (Account_Attribute__c aT : WithoutSharingHelperController.getAccountAttributesForUpdateRBI(contactIds)) {
            accountAttributesDelete.add(aT);
        }
        
        if (accountAttributesDelete.size() > 0) {
            ConstantsController.shouldAccountAttributeDeleteOfContact = true;
            WithoutSharingHelperController.deleteAccountAttributes(accountAttributesDelete);
        }
    }
    
    /**
     * Method to update Account RUL settings
     */
    static void updateAccountRulSettings(List<Reference_Basic_Information__c> contacts) {
        Set<Id> accountIds = new Set<Id>();
        List<Reference_Basic_Information__c> updateRBIs = new List<Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> accountMap = new Map<Id, Reference_Basic_Information__c>();
        Map<Id, List<Reference_Basic_Information__c>> accountContactsMap = new Map<Id, List<Reference_Basic_Information__c>>();
        boolean limitReached;
        
        for (Reference_Basic_Information__c rbi : contacts) {
            accountIds.add(rbi.Account__c);
        }
        
        for (Reference_Basic_Information__c rbi : [SELECT Id, RUL_Limit_Reached__c, Is_Referenceable__c, Account__c, Contact__r.LastName, Referenceability_Status__c, Is_Contact_Limit_Reached__c FROM Reference_Basic_Information__c WHERE Generic_Account__c = false AND Account__c != null AND Account__c IN :accountIds]) {
            
            if (rbi.Contact__c == null) {
                accountMap.put(rbi.Account__c, rbi);
            }
            
            if (rbi.Contact__c != null) {
                
                if ((rbi.Referenceability_Status__c != ConstantsController.INACTIVE && rbi.Referenceability_Status__c != null)) {
                    
                    if (!accountContactsMap.containsKey(rbi.Account__c))
                        accountContactsMap.put(rbi.Account__c, new List<Reference_Basic_Information__c>());
                    accountContactsMap.get(rbi.Account__c).add(rbi);
                } else {
                    
                    if (!accountContactsMap.containsKey(rbi.Account__c)) {
                        accountContactsMap.put(rbi.Account__c, new List<Reference_Basic_Information__c>());
                    }
                }
            }
        }
        
        for (Id accId : accountMap.keySet()) {
            
            if (accountMap.get(accId).Is_Referenceable__c) {
                limitReached = true;
                
                if (accountContactsMap != null && accountContactsMap.containsKey(accId) && accountContactsMap.get(accId) != null) {
                    
                    for (Reference_Basic_Information__c c : accountContactsMap.get(accId)) {
                        
                        if (c.RUL_Limit_Reached__c == false)
                            limitReached = false;
                    }
                    
                    if (accountContactsMap.get(accId).size() == 0) {
                        limitReached = false;
                    }
                }
                
                if (limitReached && !accountMap.get(accId).Is_Contact_Limit_Reached__c) {
                    accountMap.get(accId).Is_Contact_Limit_Reached__c = true;
                    updateRBIs.add(accountMap.get(accId));
                } else if (accountMap.get(accId).Is_Contact_Limit_Reached__c) {
                    accountMap.get(accId).Is_Contact_Limit_Reached__c = false;
                    updateRBIs.add(accountMap.get(accId));
                }
            }
        }
        
        if (updateRBIs.size() > 0) {
            WithoutSharingHelperController.upsertRBI(updateRBIs);
        }
    }

    /**
     * Method to prepare chatter email task Item
     */
    private static void prepareChatterTaskItem(Map<Id,Map<Id,ChatterWrapper>> chatterList) {
        List<Sobject> postFeedItems = new List<Sobject>();
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();

        for (Id accKey : chatterList.keySet()) {
            
            for (Id userKey : chatterList.get(accKey).keySet()) { 
                ChatterWrapper CW = chatterList.get(accKey).get(userKey);
                postFeedItems.add(MailChatterController.preparePost(CW.SUBJECT, CW.targetId, CW.MSG_BODY, ''));
                listmail.add(MailChatterController.prepareEmail(CW.SUBJECT, CW.targetId, CW.MSG_BODY, false));
            }
        }
        //Insert list of postFeedItems
        if (postFeedItems.size() > 0) {
            postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
        }

        if (listmail.size() > 0) {
            Messaging.sendEmail(listmail);
        }
    }
    
    /**
     * Wrapper Class
     */
    public class ChatterWrapper {
        public String SUBJECT;
        public String MSG_BODY;
        public String targetId;
        public chatterWrapper(String SUBJECT, String MSG_BODY, String targetId) {
            this.SUBJECT = SUBJECT;
            this.MSG_BODY = MSG_BODY;
            this.targetId = targetId;
        }
    }
    
    /*
        REF-1969 (Rajneesh 24 nov 2018)
        To get all picklist and multiselect picklist of opportunity and according to their value create Account Attribute.
        Condition :- If RBI is Reference Program Member and opportunity stage is equal to custom setting Value.
    */
    private static void checkForOpportunityAttributeMapping(Set<String> accountIds) {
        Map<String, Schema.SObjectType> schemaMap = CRUDAndFLSCheckController.sObjectsMap;
        Map<String, Schema.SObjectField> fldObjMap = schemaMap.get('Opportunity').getDescribe().fields.getMap();
        String oppQuery = 'SELECT Id, Name, AccountId ';
        Set<String> fieldAPINaneSet = new Set<String>();
        
        for(String fieldName : fldObjMap.keyset()) {
            Schema.DescribeFieldResult fieldDesc = fldObjMap.get(fieldName).getDescribe();
            
            if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                String theName = fieldDesc.getName();
                
                //  Exclude Stage field from opportunity object
                if(theName != 'StageName') {
                    fieldAPINaneSet.add(theName);
                }
                // Continue building your dynamic query String
                oppQuery += ', ' + theName;                
            }
        }
        String stageCS = cs.Opportunity_Closed_Won_Stage__c;
        oppQuery += ' FROM Opportunity WHERE AccountId IN : accountIds AND StageName = :stageCS LIMIT ' + (Limits.getLimitQueryRows() - Limits.getQueryRows());	
        List<Opportunity> oppoList = WithoutSharingHelperController.getOpp(oppQuery,accountIds,stageCS);
        List<Account_Attribute__c> createAccountAttList = new List<Account_Attribute__c>();
        
        if(oppoList.size() > 0) {
            
            //	Map contains AccountId as Key and map of AttributeId and Account Attribute as value
            Map<Id, Map<Id, Account_Attribute__c>> accIdAccAttriListMap = new Map<Id, Map<id, Account_Attribute__c>>();
            
            for(Account_Attribute__c accAttr : [SELECT Id, Account__c, Attribute__c FROM Account_Attribute__c WHERE Account__c IN : accountIds LIMIT : (Limits.getLimitQueryRows() - Limits.getQueryRows())]) {
                
                if(!accIdAccAttriListMap.containsKey(accAttr.Account__c)) 
                    accIdAccAttriListMap.put(accAttr.Account__c, new Map<id, Account_Attribute__c>());
                accIdAccAttriListMap.get(accAttr.Account__c).put(accAttr.Attribute__c, accAttr);
            }
            
            //	Map of fieldAPIName as key and map of Attribute Name and Attribute Id as Value
            Map<String, Map<String, String>> fieldAttributeMap = new Map<String, Map<String, String>>();
            
            // 	All attributes which are created by opportunity picklist and Multiselect picklist
            for(Attribute__c att : [SELECT Id, Name, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c,
                                (SELECT Id, Name, Parent__r.Inheritable__c FROM Attributes__r) FROM Attribute__c WHERE
                                    Attribute_Mapping__r.Field_Api_Name__c IN : fieldAPINaneSet AND Attribute_Mapping__r.Related_Object__c = '' AND 
                                    Attribute_Mapping__r.Object__c = 'Opportunity' AND Attribute_Mapping__r.Auto_populate__c = true LIMIT : (Limits.getLimitQueryRows() - Limits.getQueryRows())]) {
                                        
                if(!fieldAttributeMap.containsKey(att.Attribute_Mapping__r.Field_Api_Name__c))
                    fieldAttributeMap.put(att.Attribute_Mapping__r.Field_Api_Name__c, new Map<String, String>());
                
                for(Attribute__c chldAtt : att.Attributes__r) {
                    fieldAttributeMap.get(att.Attribute_Mapping__r.Field_Api_Name__c).put(chldAtt.Name, chldAtt.Id+'#'+chldAtt.Parent__r.Inheritable__c); 
                }			
            }
            
            //  REF-2232
            //  Restrict duplicate Account Attribute Creation
            Map<Id, Set<Id>> accountWithAttriSetMap = new Map<Id, Set<Id>>();

            if(fieldAttributeMap.size() > 0) {
                
                for(String fildApiName : fieldAttributeMap.keySet()) {		//	Returns APIname of picklist and Multiselect Picklist of Opportunity
                  
                    for(Opportunity oppRec : oppoList) {                       

                        Set<String> fieldValue = new Set<String>();
                        if(oppRec.get(fildApiName) != null && oppRec.get(fildApiName) != '') {
                            
                            if(String.valueOf(oppRec.get(fildApiName)).contains(';')) {
                                
                                for(String fldVal : String.valueOf(oppRec.get(fildApiName)).split(';')) {
                                    fieldValue.add(fldVal.trim());
                                }
                            } else {
                                fieldValue.add(String.valueOf(oppRec.get(fildApiName)).trim());
                            }
                            
                            for(String oppFldValue : fieldValue) {
                                
                                if(fieldAttributeMap.get(String.valueOf(fildApiName)).containsKey(oppFldValue) && !accIdAccAttriListMap.containsKey(oppRec.AccountId)) {
                                    
                                    
                                    if((accountWithAttriSetMap.containsKey(oppRec.AccountId) && !accountWithAttriSetMap.get(oppRec.AccountId).contains(fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[0])) || (!accountWithAttriSetMap.containsKey(oppRec.AccountId))){
                                        createAccountAttList.add(new Account_Attribute__c(Account__c = oppRec.AccountId, Attribute__c = fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[0], Inheritable__c = Boolean.valueOf(fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[1]), From_Opportunity__c = true));
                                        
                                        if(!accountWithAttriSetMap.containsKey(oppRec.AccountId))
                                            accountWithAttriSetMap.put(oppRec.AccountId, new Set<Id>());
                                        accountWithAttriSetMap.get(oppRec.AccountId).add(fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[0]);
                                    }
                                } else if(fieldAttributeMap.get(String.valueOf(fildApiName)).containsKey(oppFldValue) && accIdAccAttriListMap.containsKey(oppRec.AccountId) && !accIdAccAttriListMap.get(oppRec.AccountId).containsKey(fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[0])) {
                                    
                                    if((accountWithAttriSetMap.containsKey(oppRec.AccountId) && !accountWithAttriSetMap.get(oppRec.AccountId).contains(fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[0])) || (!accountWithAttriSetMap.containsKey(oppRec.AccountId))){
                                        createAccountAttList.add(new Account_Attribute__c(Account__c = oppRec.AccountId, Attribute__c = fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[0], Inheritable__c = Boolean.valueOf(fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[1]), From_Opportunity__c = true));
                                        
                                        if(!accountWithAttriSetMap.containsKey(oppRec.AccountId))
                                            accountWithAttriSetMap.put(oppRec.AccountId, new Set<Id>());
                                        accountWithAttriSetMap.get(oppRec.AccountId).add(fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[0]);
                                    }
                                }
                            }
                        }
                    }			
                }
            }

            if(createAccountAttList.size() > 0) {
                WithoutSharingHelperController.upsertAccountAttributes(createAccountAttList);
            }
            
        }
    }
}