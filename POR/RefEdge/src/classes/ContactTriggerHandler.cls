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
public with sharing class ContactTriggerHandler {
    /**
     * Method called on before update of Contact
     */
    public static void onBeforeUpdate(list < Contact > newContacts, list < Contact > oldContacts, map < Id, Contact > oldContactMap) {
        ConstantsController.isRbiUpdatedFromConTrigger = true;
        
        if (newContacts.size() == 1 && constantsController.contactDeletePrevious) {
            list < Reference_Basic_Information__c > conRBI = [select Id from Reference_Basic_Information__c where Contact__c In: newContacts and(Is_Referenceable__c = true Or Reference_Program_Candidate__c = true)];
            if (conRBI.size() > 0)
                checkForMergeContactsMapping(newContacts, oldContacts, oldContactMap);
        }
    }
    /**
     * Method called on before delete of Contact
     */
    public static void onBeforeDelete(list < Contact > oldContacts, map < Id, Contact > oldContactMap) {
        for (Contact accObj: [select Id, (Select Id From Rewards__r),(select Id, Is_fromMapping__c, Contact__c, Attribute__c, Attribute__r.Name from Contact_Attributes__r), (Select Id From Reference_Request_Account_Contacts__r), (Select Id From Referenceabilities__r), (Select Id From Nominations__r), (Select Id From Account_Attributes__r), (Select Id From Hit_Lists__r), (Select Id From Reference_Basic_Informations__r) from Contact where Id IN: oldContactMap.keySet()]) {
            for (Account_Attribute__c con: accObj.Account_Attributes__r) {
                ConstantsController.AccountAttsDelete.add(con);
            }
            for (Contact_Attribute__c con: accObj.Contact_Attributes__r) {
                ConstantsController.ContactAttsDelete.add(con);
            }
            for (Referenceability__c con: accObj.Referenceabilities__r) {
                ConstantsController.RefIdSet.add(con);
            }
            for (Reference_Basic_Information__c con: accObj.Reference_Basic_Informations__r) {
                ConstantsController.RBIIdSet.add(con);
            }
            for (Nomination__c con: accObj.Nominations__r) {
                ConstantsController.NominationList.add(con);
            }
            for (Reference_Request_Account_Contact__c con: accObj.Reference_Request_Account_Contacts__r) {
                ConstantsController.rracList.add(con);
            }
            for (Hit_List__c con: accObj.Hit_Lists__r) {
                ConstantsController.HitIdSet.add(con);
            }
            for (Reward__c con: accObj.Rewards__r) {
                ConstantsController.RewardContactMap.put(con.Id,accObj.Id);
            }
        }
    }
    
    /**
     * Method called on after update of Contact
     */
    public static void onAfterUpdate(list < Contact > newContacts, map < Id, Contact > newContactMap, map < Id, Contact > oldContactMap) {
        if(!ConstantsController.isCopyNominationDetailProcess){
            map < Id, Reference_Basic_Information__c > RBIMap = new map < Id, Reference_Basic_Information__c > ();
            list < Contact > refActiveContacts = new list < Contact > ();
            list < Contact > updateContact = new list < Contact > ();
            map < Id, Reference_Basic_Information__c > accRBIMap = new map < Id, Reference_Basic_Information__c > ();
            set < String > accountIds = new set < String > ();
            for (Contact con: newContactMap.values()) {
                accountIds.add(con.AccountId);
            }
            set < String > duplicateRbi = new set < String > ();
            for (Reference_Basic_Information__c rbi: [select Id, Account__c, Referenceability_Status__c, Contact__c, Is_Referenceable__c, Reference_Program_Candidate__c from Reference_Basic_Information__c where (Account__c In: accountIds Or Contact__c IN: newContactMap.keySet())]) {
                if (rbi.Contact__c != null && !duplicateRbi.contains(rbi.Id)) {
                    duplicateRbi.add(rbi.Id);
                    RBIMap.put(rbi.Contact__c, rbi);
                    if ((rbi.Is_Referenceable__c || rbi.Reference_Program_Candidate__c) && newContactMap.containsKey(rbi.Contact__c))
                        refActiveContacts.add(newContactMap.get(rbi.Contact__c));
                } else if (!duplicateRbi.contains(rbi.Id)) {
                    duplicateRbi.add(rbi.Id);
                    accRBIMap.put(rbi.Account__c, rbi);
                }
            }
            set < String > setContactId = new set < String > ();
            for (Contact con: newContacts) {
                if (con.AccountId != oldContactMap.get(con.Id).AccountId) {
                    updateContact.add(con);
                    if(RBIMap != null && RBIMap.containsKey(con.Id)){
                        RBIMap.get(con.Id).Account__c = con.AccountId;
                        //R15.33
                        RBIMap.get(con.Id).Current_Available_Balance_Points__c = 0;
                        RBIMap.get(con.Id).Lifetime_Points__c = 0;
                    }
                }
                //for Hitlist
                if (oldContactMap.get(con.Id).Email != newContactMap.get(con.Id).Email || oldContactMap.get(con.Id).Phone != newContactMap.get(con.Id).Phone) {
                    setContactId.add(con.Id);
                }
            }
            System.debug('RBIMap :::: '+RBIMap);
            System.debug('accRBIMap :::: '+accRBIMap);
            if (updateContact.size() > 0)
                reassignAccount(updateContact, RBIMap, accRBIMap);
            if (refActiveContacts.size() > 0 && ConstantsController.attMappingForContact)
                checkForAttributeMapping(refActiveContacts, newContactMap, oldContactMap);
    
            //Update HitLists
            if (setContactId.size() > 0)
                updateHitlist(setContactId, newContactMap);
        }
    }
    
    /**
     * Method called on after delete of Contact
     */
    public static void onAfterDelete(map < Id, Contact > oldContactMap) {
        try {
            String contactId = '';
            decimal lifeTimePoints = 0;
            decimal availablePoints = 0;
            boolean iscandidate = false;
            set < String > statusSet = new set < String > ();
            list < Reference_Basic_Information__c > deleteRBIs = new list < Reference_Basic_Information__c > ();
            map < String, Reference_Basic_Information__c > deletedRBI = new map < String, Reference_Basic_Information__c > ();
            //list < Reference_Basic_Information__c > allRBIs = [select Id, Account__c, Contact__c, Lifetime_Points__c, RUL_Last_Updated_By__c, RUL_Period__c, RUL_Activities_will_do__c, Joined_Reference_Program__c, Referenceability_Status__c, Is_Referenceable__c, Reference_Program_Candidate__c from Reference_Basic_Information__c where Id IN: ConstantsController.RBIIdSet];
            list < Reference_Basic_Information__c > allRBIs = WithoutSharingHelperController.getRBIonMergeProcess();
            for (Reference_Basic_Information__c rbi: allRBIs) {
                deleteRBIs.add(rbi);
                if (rbi.Contact__c != null) {
                    if (rbi.Reference_Program_Candidate__c)
                        iscandidate = true;
                    lifeTimePoints += (rbi.Lifetime_Points__c != null ? rbi.Lifetime_Points__c : 0);
                    availablePoints += (rbi.Current_Available_Balance_Points__c != null ? rbi.Current_Available_Balance_Points__c : 0);
                    contactId = rbi.Contact__c;
                    if (rbi.Is_Referenceable__c) {
                        statusSet.add(rbi.Referenceability_Status__c);
                        if (!deletedRBI.containsKey(rbi.Referenceability_Status__c) || (deletedRBI.containsKey(rbi.Referenceability_Status__c) && rbi.RUL_Last_Updated_By__c != null))
                            deletedRBI.put(rbi.Referenceability_Status__c, rbi);
                    }
                }
            }
            if (contactId == '' && deleteRBIs.size() > 0)
                updateAccountRulSettings(deleteRBIs, true);
            if (deleteRBIs.size() > 0) {
                /*if (contactId != '')
                    ConstantsController.stopTriggerRbiOnMerge = true;
                delete deleteRBIs;
                ConstantsController.stopTriggerRbiOnMerge = false;
                Database.emptyRecycleBin( deleteRBIs );*/
                if (contactId != '')
                    ConstantsController.stopTriggerContentAccountOnMerge = true;
                //delete deleteRBIs;
                WithoutSharingHelperController.deleteReferenceProfiles(deleteRBIs);
                ConstantsController.stopTriggerContentAccountOnMerge = false;
                    //Database.emptyRecycleBin( deleteRBIs );
            }
            list < Account_Attribute__c > accuntAttribDelete = new list < Account_Attribute__c > ();
            for (Account_Attribute__c aa: [select Id, Contact__c from Account_Attribute__c where Id IN: ConstantsController.AccountAttsDelete]) {
                if (aa.Contact__c == null) {
                    accuntAttribDelete.add(aa);
                }
            }
            list<Reward__c> rewardList = new list<Reward__c>();
            for(Reward__c reward : [Select Id, Name, Account__c,Contact__r.Name, Comments__c, Contact__c From Reward__c where Id IN : ConstantsController.RewardContactMap.keySet()]){
                if (reward.Contact__c == null) {
                    reward.Contact__c = null;
                    reward.Comments__c = 'Originally rewarded to the Contact, '+oldContactMap.get(ConstantsController.RewardContactMap.get(reward.Id)).FirstName+' '+oldContactMap.get(ConstantsController.RewardContactMap.get(reward.Id)).LastName+'.';
                    rewardList.add(reward);
                }
            }
            if(rewardList.size() > 0){
                //update rewardList;
                WithoutSharingHelperController.upsertRewards(rewardList);
            }
            list < Reference_Request_Account_Contact__c > deleteRRAC = new list < Reference_Request_Account_Contact__c > ();
            for (Reference_Request_Account_Contact__c rrac: [select Id, Contact__c from Reference_Request_Account_Contact__c where Id IN: ConstantsController.rracList]) {
                if (rrac.Contact__c == null) {
                    deleteRRAC.add(rrac);
                }
            }
            if (deleteRRAC.size() > 0){
                //delete deleteRRAC;
                WithoutSharingHelperController.deleteContactRequests(deleteRRAC);
            }
            list < Referenceability__c > deleteRefs = new list < Referenceability__c > ();
            for (Referenceability__c ref: [select Id, Contact__c, Referenceability_Type__c from Referenceability__c where Id IN: ConstantsController.RefIdSet]) {
                if (ref.Contact__c == null) {
                    deleteRefs.add(ref);
                }
            }
            list < Nomination__c > deleteNomis = new list < Nomination__c > ();
            for (Nomination__c nomi: [select Id, Contact__c from Nomination__c where Id IN: ConstantsController.NominationList]) {
                if (nomi.Contact__c == null) {
                    deleteNomis.add(nomi);
                }
            }
            if (deleteNomis.size() > 0){
                //delete deleteNomis;
                WithoutSharingHelperController.deleteNominations(deleteNomis);
            }
            list < Hit_List__c > deleteHits = new list < Hit_List__c > ();
            for (Hit_List__c hit: [select Id, Contact__c from Hit_List__c where Id IN: ConstantsController.HitIdSet]) {
                if (hit.Contact__c == null) {
                    deleteHits.add(hit);
                }
            }
            list < Reference_Basic_Information__c > rbiRecord = new list < Reference_Basic_Information__c > ();
            list < Contact_Attribute__c > contactAttribDelete = new list < Contact_Attribute__c > ();
            list < Contact_Reference_Content__c > deleteAccRefs = new list < Contact_Reference_Content__c > ();
            list < Contact_Attribute__c > contactAttributeList = new list < Contact_Attribute__c > ();
            for (Contact_Attribute__c aa: [select Id, Contact__c from Contact_Attribute__c where Id IN: ConstantsController.ContactAttsDelete]) {
                if (aa.Contact__c == null) {
                    contactAttribDelete.add(aa);
                }
            }
            if (contactId != '') {
                Boolean isCreateRBI = false;
                list < Contact > conList = [select Id, AccountId, (Select Id, Activity_Date__c From Reference_Request_Account_Contacts__r where Contact_Request_Status__c = 'Completed'), 
                    (select Id, Contact__c, Referenceability_Status__c, Is_Referenceable__c, Reference_Program_Candidate__c, Lifetime_Points__c, Current_Available_Balance_Points__c,
                    RUL_Limit_Reached__c, RUL_Activities_will_do__c, RUL_Period__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Account__c, RUL_Last_Updated_By__c,
                    Attributes__c,Attribute_Ids__c,Label_Ids1__c,Label_Ids2__c,Parent_Attributes__c, Contact__r.OwnerId, Reference_Owner__c, Profile_Update_Owner__c from Reference_Basic_Informations__r), 
                    (select Id, Is_fromMapping__c, From_Account__c, Contact__c, Attribute__c, Attribute__r.Name from Contact_Attributes__r), (Select Id, Reference_Request__c From Hit_Lists__r), 
                    (select Id, Reference_Content__c from Contact_Reference_Contents__r), (select Id, Account__c, Contact__c, Referenceability_Type__c, Referenceability_Type__r.Referenceability_no__c, 
                    Referenceability_Type__r.Name, Status__c from Referenceabilities__r), (select Id, Contact__c, Is_fromMapping__c, Account__c, Attribute__c, Attribute__r.Name from Account_Attributes__r) from 
                    Contact where Id = : contactId];
                if (conList.size() > 0) {
                    Contact conObj = conList[0];
                    list < Referenceability__c > refList = new list < Referenceability__c > ();
                    set < Id > attSet = new set < Id > ();
                    set < Id > attAccountSet = new set < Id > ();
                    set < string > attributeSet = new set < string > ();
                    set < Id > refSet = new set < Id > ();
                    for (Hit_List__c aa: conObj.Hit_Lists__r) {
                        if (refSet.contains(aa.Reference_Request__c)) {
                            deleteHits.add(aa);
                        }
                        refSet.add(aa.Reference_Request__c);
                    }
                    refSet = new set < Id > ();
                    for (Contact_Reference_Content__c ar: conObj.Contact_Reference_Contents__r) {
                        if (refSet.contains(ar.Reference_Content__c)) {
                            deleteAccRefs.add(ar);
                        }
                        refSet.add(ar.Reference_Content__c);
                    }
                    for (Reference_Request_Account_Contact__c rra: conObj.Reference_Request_Account_Contacts__r) {
                        isCreateRBI = true;
                        break;
                    }
                    Custom_Settings__c cs = UtilityController.getCustomSettings();
                    refSet = new set < Id > ();
                    for (Referenceability__c aa: conObj.Referenceabilities__r) {
                        isCreateRBI = true;
                        if (refSet.contains(aa.Referenceability_Type__c)) {
                            deleteRefs.add(aa);
                        } else if (aa.Status__c == ConstantsController.APPROVED) {
                            refList.add(aa);
                        }
                        refSet.add(aa.Referenceability_Type__c);
                    }
                    set<Id> mappingAttributeIds = new set<Id>();
                    for (Contact_Attribute__c aa: conObj.Contact_Attributes__r) {
                        isCreateRBI = true;
                        if (aa.Is_fromMapping__c) {
                            contactAttribDelete.add(aa);
                            mappingAttributeIds.add(aa.Attribute__c);
                        } else if (!aa.Is_fromMapping__c) {
                            if (attSet.contains(aa.Attribute__c)) {
                                contactAttribDelete.add(aa);
                                mappingAttributeIds.add(aa.Attribute__c);
                            } else {
                                contactAttributeList.add(aa);
                                attributeSet.add(aa.Attribute__c);
                            }
                            attSet.add(aa.Attribute__c);
                        } else if (aa.From_Account__c) {
                            if (attAccountSet.contains(aa.Attribute__c)) {
                                contactAttribDelete.add(aa);
                            } else {
                                contactAttributeList.add(aa);
                                attributeSet.add(aa.Attribute__c);
                            }
                            attAccountSet.add(aa.Attribute__c);
                        }
                    }
                    attSet.clear();
                    for (Account_Attribute__c aa: conObj.Account_Attributes__r) {
                        if (attSet.contains(aa.Attribute__c) || mappingAttributeIds.contains(aa.Attribute__c)) {
                            accuntAttribDelete.add(aa);
                        }
                        attSet.add(aa.Attribute__c);
                    }
                    if (conObj.Reference_Basic_Informations__r.size() > 0) {
                        rbiRecord.add(conObj.Reference_Basic_Informations__r[0]);
                    }
                    if (rbiRecord != null && rbiRecord.size() > 0) {
                        if (statusSet.contains(ConstantsController.ACTIVE) && rbiRecord[0].Referenceability_Status__c != ConstantsController.ACTIVE) {
                            rbiRecord[0].Referenceability_Status__c = ConstantsController.ACTIVE;
                            rbiRecord[0].Is_Referenceable__c = true;
                            rbiRecord[0].Reference_Program_Candidate__c = false;
                            rbiRecord[0].RUL_Period__c = deletedRBI.get(ConstantsController.ACTIVE).RUL_Period__c;
                            rbiRecord[0].RUL_Activities_will_do__c = deletedRBI.get(ConstantsController.ACTIVE).RUL_Activities_will_do__c;
                            rbiRecord[0].RUL_Last_Updated_By__c = (deletedRBI.get(ConstantsController.ACTIVE).RUL_Last_Updated_By__c != null ? deletedRBI.get(ConstantsController.ACTIVE).RUL_Last_Updated_By__c : rbiRecord[0].RUL_Last_Updated_By__c);
                            rbiRecord[0].Joined_Reference_Program__c = deletedRBI.get(ConstantsController.ACTIVE).Joined_Reference_Program__c;
                        } else if (statusSet.contains(ConstantsController.CAUTION) && rbiRecord[0].Referenceability_Status__c != ConstantsController.ACTIVE && rbiRecord[0].Referenceability_Status__c != ConstantsController.CAUTION) {
                            rbiRecord[0].Referenceability_Status__c = ConstantsController.CAUTION;
                            rbiRecord[0].Is_Referenceable__c = true;
                            rbiRecord[0].Reference_Program_Candidate__c = false;
                            rbiRecord[0].RUL_Period__c = deletedRBI.get(ConstantsController.CAUTION).RUL_Period__c;
                            rbiRecord[0].RUL_Activities_will_do__c = deletedRBI.get(ConstantsController.CAUTION).RUL_Activities_will_do__c;
                            rbiRecord[0].RUL_Last_Updated_By__c = (deletedRBI.get(ConstantsController.CAUTION).RUL_Last_Updated_By__c != null ? deletedRBI.get(ConstantsController.CAUTION).RUL_Last_Updated_By__c : rbiRecord[0].RUL_Last_Updated_By__c);
                            rbiRecord[0].Joined_Reference_Program__c = deletedRBI.get(ConstantsController.CAUTION).Joined_Reference_Program__c;
                        } else if (statusSet.contains(ConstantsController.INACTIVE) && (rbiRecord[0].Referenceability_Status__c == null || rbiRecord[0].Referenceability_Status__c == ConstantsController.INACTIVE)) {
                            rbiRecord[0].Referenceability_Status__c = ConstantsController.INACTIVE;
                            rbiRecord[0].Is_Referenceable__c = true;
                            rbiRecord[0].Reference_Program_Candidate__c = false;
                            rbiRecord[0].RUL_Period__c = deletedRBI.get(ConstantsController.INACTIVE).RUL_Period__c;
                            rbiRecord[0].RUL_Activities_will_do__c = deletedRBI.get(ConstantsController.INACTIVE).RUL_Activities_will_do__c;
                            rbiRecord[0].RUL_Last_Updated_By__c = (deletedRBI.get(ConstantsController.INACTIVE).RUL_Last_Updated_By__c != null ? deletedRBI.get(ConstantsController.INACTIVE).RUL_Last_Updated_By__c : rbiRecord[0].RUL_Last_Updated_By__c);
                            rbiRecord[0].Joined_Reference_Program__c = deletedRBI.get(ConstantsController.INACTIVE).Joined_Reference_Program__c;
                        } else if (iscandidate && !rbiRecord[0].Is_Referenceable__c) {
                            rbiRecord[0].Reference_Program_Candidate__c = true;
                        }
                    } else if (statusSet.size() > 0) {
                        Reference_Basic_Information__c newRbi = new Reference_Basic_Information__c();
                        rbiRecord = new list < Reference_Basic_Information__c > ();
                        newRbi.Account__c = conObj.AccountId;
                        newRbi.Contact__c = conObj.Id;
                        if (statusSet.contains(ConstantsController.ACTIVE)) {
                            newRbi.Referenceability_Status__c = ConstantsController.ACTIVE;
                            newRbi.Is_Referenceable__c = true;
                            newRbi.Reference_Program_Candidate__c = false;
                            newRbi.RUL_Period__c = deletedRBI.get(ConstantsController.ACTIVE).RUL_Period__c;
                            newRbi.RUL_Activities_will_do__c = deletedRBI.get(ConstantsController.ACTIVE).RUL_Activities_will_do__c;
                            newRbi.RUL_Last_Updated_By__c = (deletedRBI.get(ConstantsController.ACTIVE).RUL_Last_Updated_By__c != null ? deletedRBI.get(ConstantsController.ACTIVE).RUL_Last_Updated_By__c : newRbi.RUL_Last_Updated_By__c);
                            newRbi.Joined_Reference_Program__c = deletedRBI.get(ConstantsController.ACTIVE).Joined_Reference_Program__c;
                        } else if (statusSet.contains(ConstantsController.CAUTION)) {
                            newRbi.Referenceability_Status__c = ConstantsController.CAUTION;
                            newRbi.Is_Referenceable__c = true;
                            newRbi.Reference_Program_Candidate__c = false;
                            newRbi.RUL_Period__c = deletedRBI.get(ConstantsController.CAUTION).RUL_Period__c;
                            newRbi.RUL_Activities_will_do__c = deletedRBI.get(ConstantsController.CAUTION).RUL_Activities_will_do__c;
                            newRbi.RUL_Last_Updated_By__c = (deletedRBI.get(ConstantsController.CAUTION).RUL_Last_Updated_By__c != null ? deletedRBI.get(ConstantsController.CAUTION).RUL_Last_Updated_By__c : newRbi.RUL_Last_Updated_By__c);
                            newRbi.Joined_Reference_Program__c = deletedRBI.get(ConstantsController.CAUTION).Joined_Reference_Program__c;
                        } else if (statusSet.contains(ConstantsController.INACTIVE)) {
                            newRbi.Referenceability_Status__c = ConstantsController.INACTIVE;
                            newRbi.Is_Referenceable__c = true;
                            newRbi.Reference_Program_Candidate__c = false;
                            newRbi.RUL_Period__c = deletedRBI.get(ConstantsController.INACTIVE).RUL_Period__c;
                            newRbi.RUL_Activities_will_do__c = deletedRBI.get(ConstantsController.INACTIVE).RUL_Activities_will_do__c;
                            newRbi.RUL_Last_Updated_By__c = (deletedRBI.get(ConstantsController.INACTIVE).RUL_Last_Updated_By__c != null ? deletedRBI.get(ConstantsController.INACTIVE).RUL_Last_Updated_By__c : newRbi.RUL_Last_Updated_By__c);
                            newRbi.Joined_Reference_Program__c = deletedRBI.get(ConstantsController.INACTIVE).Joined_Reference_Program__c;
                        }
                        rbiRecord.add(newRbi);
                    } else if (iscandidate) {
                        Reference_Basic_Information__c newRbi = new Reference_Basic_Information__c();
                        rbiRecord = new list < Reference_Basic_Information__c > ();
                        newRbi.Account__c = conObj.AccountId;
                        newRbi.Contact__c = conObj.Id;
                        newRbi.Reference_Program_Candidate__c = true;
                        rbiRecord.add(newRbi);
                    } else if (isCreateRBI) {
                        Reference_Basic_Information__c newRbi = new Reference_Basic_Information__c();
                        rbiRecord = new list < Reference_Basic_Information__c > ();
                        newRbi.Account__c = conObj.AccountId;
                        newRbi.Contact__c = conObj.Id;
                        rbiRecord.add(newRbi);
                    }
                    if (rbiRecord != null && rbiRecord.size() > 0 && rbiRecord[0].Is_Referenceable__c) {
                        System.debug('Lifetime  ::::::: '+rbiRecord[0].Lifetime_Points__c+' lifeTimePoints '+lifeTimePoints);
                        rbiRecord[0].Lifetime_Points__c = (rbiRecord[0].Lifetime_Points__c != null ? rbiRecord[0].Lifetime_Points__c : 0) + lifeTimePoints;
                        //R15.33
                        rbiRecord[0].Current_Available_Balance_Points__c = (rbiRecord[0].Current_Available_Balance_Points__c != null ? rbiRecord[0].Current_Available_Balance_Points__c : 0) + availablePoints;
                        decimal completedUsesCount = 0;
                        decimal defaultcompletedUsesCount = 0;
                        date baseDate = date.today().addDays((rbiRecord[0].RUL_Period__c != null ? -integer.valueOf(rbiRecord[0].RUL_Period__c) : 0));
                        for (Reference_Request_Account_Contact__c rra: conObj.Reference_Request_Account_Contacts__r) {
                            if (rra.Activity_Date__c != null && (rra.Activity_Date__c).daysBetween(date.today()) <= cs.RUL_Period_Contact__c) {
                                defaultcompletedUsesCount += 1;
                            }
                            if (rra.Activity_Date__c != null && rra.Activity_Date__c > baseDate) {
                                completedUsesCount += 1;
                                if (rbiRecord[0].RUL_Last_Activity_Date__c != null && rra.Activity_Date__c > rbiRecord[0].RUL_Last_Activity_Date__c) {
                                    rbiRecord[0].RUL_Last_Activity_Date__c = rra.Activity_Date__c;
                                }
                                if (rbiRecord[0].RUL_Last_Activity_Date__c == null)
                                    rbiRecord[0].RUL_Last_Activity_Date__c = rra.Activity_Date__c;
                            }
                        }
                        rbiRecord[0].RUL_Activities_used__c = completedUsesCount;
                        rbiRecord[0].Default_Period_Completed_Uses__c = defaultcompletedUsesCount;
                        rbiRecord[0].Total_Reference_Use__c = conObj.Reference_Request_Account_Contacts__r.size();
                        if (rbiRecord[0].RUL_Activities_used__c >= rbiRecord[0].RUL_Activities_will_do__c) {
                            rbiRecord[0].RUL_Limit_Reached__c = true;
                        } else {
                            rbiRecord[0].RUL_Limit_Reached__c = false;
                        }
                    }
                    if (refList.size() > 0) {
                        String referenceabilities = '';
                        String referenceabilityIds1 = '';
                        String referenceabilityIds2 = '';
                        set < string > removeDuplicateReferenceability = new set < string > ();
                        for (Referenceability__c ref: refList) {
                            if (!removeDuplicateReferenceability.contains(ref.Referenceability_Type__r.Name.trim())) {
                                removeDuplicateReferenceability.add(ref.Referenceability_Type__r.Name.trim());
                                string refNo = (ref.Referenceability_Type__r.Referenceability_no__c != null ? 'R' + String.valueOf(ref.Referenceability_Type__r.Referenceability_no__c) + 'R' : '');
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
                        rbiRecord[0].Referenceability__c = referenceabilities;
                        rbiRecord[0].ReferenceabilityType_Ids1__c = referenceabilityIds1;
                        rbiRecord[0].ReferenceabilityType_Ids2__c = referenceabilityIds2;
                    }
                    if (attributeSet.size() > 0) {
                        map < String, String > labelIds = new map < String, String > ();
                        map < String, set<String> > attLabel = new map < String, set<String> > ();
                        map < String, String > attLabelName = new map < String, String > ();
                        for (Attributes_Labels__c attL: WithoutSharingHelperController.fetchAttributeLabels(attributeSet)) {
                            if(!attLabel.containsKey(attL.Attribute__c))
                                attLabel.put(attL.Attribute__c, new set<string>());
                            attLabel.get(attL.Attribute__c).add('F'+String.valueOf(attL.Label__r.Filter_no__c)+'F');
                            attLabelName.put(attL.Attribute__c, (attL.Attribute__r.Root_Parent__c != null ? attL.Attribute__r.Root_Parent__c : ''));
                        }
                        rbiRecord[0] = UtilityController.setFiltersForContact(rbiRecord[0],contactAttributeList,attLabel,attLabelName);
                        for (Contact_Attribute__c a: contactAttributeList) {
                            a.Reference_Basic_Information__c = rbiRecord[0].Id;
                        }
                    }
                }
            }
            if (contactAttribDelete.size() > 0) {
                ConstantsController.deleteAttributFromContact = true;
                ConstantsController.shouldAccountAttributeDeleteOfContactOnNoMerge = false;
                ConstantsController.attMappingForAccount = false;
                ConstantsController.attMappingForContact = false;
                constantsController.contactDeletePrevious = true;
                //delete contactAttribDelete;
                WithoutSharingHelperController.deleteContactAttributes(contactAttribDelete);
            }
            if (accuntAttribDelete.size() > 0) {
                ConstantsController.shouldAccountAttributeDeleteOfContact = true;
                ConstantsController.deleteAttributeFromAccount = false;
                ConstantsController.attMappingForAccount = false;
                ConstantsController.attMappingForContact = false;
                //delete accuntAttribDelete;
                WithoutSharingHelperController.deleteAccountAttributes(accuntAttribDelete);
            }
            if (deleteAccRefs.size() > 0){
                //delete deleteAccRefs;
                WithoutSharingHelperController.deleteConRefs(deleteAccRefs);
            }
            if (deleteHits.size() > 0){
                //delete deleteHits;
                WithoutSharingHelperController.deleteHitlists(deleteHits);   
            }
            if (deleteRefs.size() > 0){
                //delete deleteRefs;
                WithoutSharingHelperController.deleteReferenceabilities(deleteRefs);   
            }
            if (rbiRecord != null && rbiRecord.size() > 0) {
                ConstantsController.shouldCandidateRequestDelete = false;
                //upsert rbiRecord;
                WithoutSharingHelperController.upsertRBI(rbiRecord); 
            }
            /*
             * for --> ReferenceEdge Attribute, Mapped Attribute Reporting question
             * set Reference_Basic_Information__c in Account Attribute
             * by Rekha
             */
            if(contactAttributeList.size() > 0){
                ConstantsController.stopConAttributeTrigger = true;
                WithoutSharingHelperController.upsertContactAttributes(contactAttributeList);
                ConstantsController.stopConAttributeTrigger = false;
            }//end
        } catch (Exception e) {
            throw e;
        }
    }
    
    /**
     * Method to add Attributes on contact from Account
     */
    private static void addAttributesOnContactFromAccount(list < Contact > contactList) {
        map < Id, set < Id >> activeAccountContacts = new map < Id, set < Id >> ();
        map < Id, set < Id >> accountAttributes = new map < Id, set < Id >> ();
        map < Id, set < Id >> contactAttribsAssociated = new map < Id, set < Id >> ();
        list < Contact_Attribute__c > newContactAttributes = new list < Contact_Attribute__c > ();
        map < Id, Reference_Basic_Information__c > accountRBI = new map < Id, Reference_Basic_Information__c > ();
        Contact_Attribute__c tempObj;
        for (Contact rbi: contactList) {
            if (!activeAccountContacts.containsKey(rbi.AccountId)) {
                activeAccountContacts.put(rbi.AccountId, new set < Id > ());
            }
            activeAccountContacts.get(rbi.AccountId).add(rbi.Id);
            accountAttributes.put(rbi.AccountId, new set < Id > ());
            contactAttribsAssociated.put(rbi.Id, new set < Id > ());
        }
        for (Contact_Attribute__c conAtt: [select Attribute__c, Contact__c from Contact_Attribute__c where Contact__c In: contactAttribsAssociated.keySet()]) {
            contactAttribsAssociated.get(conAtt.Contact__c).add(conAtt.Attribute__c);
        }
        for (Account acc: [select Id, (select Account__c, Attribute__c from Account_Attributes__r where Reference_Content__c = null and Contact__c = null and Inheritable__c = true), (select account__c, Referenceability_Status__c, Is_Referenceable__c from Reference_Basic_Informations__r where Generic_Account__c = false AND contact__c = null) from Account where Id In: activeAccountContacts.keySet()]) {
            if (acc.Reference_Basic_Informations__r.size() > 0)
                accountRBI.put(acc.Id, acc.Reference_Basic_Informations__r[0]);
            for (Account_Attribute__c accAtt: acc.Account_Attributes__r)
                accountAttributes.get(accAtt.Account__c).add(accAtt.Attribute__c);
        }
        for (Id accId: activeAccountContacts.keySet()) {
            if (accountRBI.containsKey(accId) && accountRBI.get(accId).Is_Referenceable__c) {
                for (Id contactId: activeAccountContacts.get(accId)) {
                    for (Id attId: accountAttributes.get(accId)) {
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
        if (newContactAttributes.size() > 0) {
            ConstantsController.fromaccount = true;
            //insert newContactAttributes;
            WithoutSharingHelperController.upsertContactAttributes(newContactAttributes);
        }
    }
    
    /**
     * Method to check for merge contact mapping
     */
    private Static void checkForMergeContactsMapping(list < Contact > newContacts, list < Contact > oldContacts, map < Id, Contact > oldContactMap) {
        Map < String, Schema.SObjectField > fldObjMap = schema.SObjectType.Contact.fields.getMap();
        list < Attribute_Mapping__c > attMappings = new list < Attribute_Mapping__c > ();
        set < String > preventDuplicacy = new set < String > ();
        list < Contact_Attribute__c > createContactAtt = new list < Contact_Attribute__c > ();
        for (Attribute_Mapping__c attM: [select Field_Api_Name__c, Auto_populate__c, Auto_add__c, Auto_Update__c, Auto_delete__c
                from Attribute_Mapping__c where object__c = : ConstantsController.CONTACT
                and Field_Api_Name__c != null and Is_Related_Mapping__c = false
            ]) {
            if (fldObjMap.containsKey(attM.Field_Api_Name__c.tolowerCase())) {
                attMappings.add(attM);
            }
        }
        if (attMappings.size() > 0) {
            for (Attribute__c att: [select Id, name, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Auto_populate__c, (Select Id, Name From Attributes__r), Attribute_Mapping__r.Inheritable__c from Attribute__c where Attribute_Mapping__c In: attMappings and level__c = 0]) {
                if (att.Attribute_Mapping__r.Auto_populate__c) {
                    for (Contact con: newContacts) {
                        for (Attribute__c childAtt: att.Attributes__r) {
                            if (con.get(att.Attribute_Mapping__r.Field_Api_Name__c) != null) {
                                for (String attStr: string.valueOf(con.get(att.Attribute_Mapping__r.Field_Api_Name__c)).split(';')) {
                                    if (attStr == childAtt.Name && !preventDuplicacy.contains(con.Id + '' + childAtt.Id)) {
                                        createContactAtt.add(new Contact_Attribute__c(Contact__c = con.Id, Attribute__c = childAtt.Id, Is_fromMapping__c = true));
                                        preventDuplicacy.add(con.Id + '' + childAtt.Id);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if (createContactAtt.size() > 0) {
                ConstantsController.attMappingForAccount = false;
                ConstantsController.attMappingForContact = false;
                ConstantsController.attMappingForRefContent = false;
                //insert createContactAtt;
                WithoutSharingHelperController.upsertContactAttributes(createContactAtt);
            }
        }
    }
    
    /**
     * Method to update Account RUL setting
     */
    static void updateAccountRulSettings(list < Reference_Basic_Information__c > contacts, boolean isContactDelete) {
        set < Id > accountIds = new set < Id > ();
        list < Reference_Basic_Information__c > updateRBIs = new list < Reference_Basic_Information__c > ();
        map < Id, Reference_Basic_Information__c > accountMap = new map < Id, Reference_Basic_Information__c > ();
        map < Id, list < Reference_Basic_Information__c >> accountContactsMap = new map < Id, list < Reference_Basic_Information__c >> ();
        boolean limitReached;
        set < string > conIdSet = new set < String > ();
        for (Reference_Basic_Information__c rbi: contacts) {
            accountIds.add(rbi.Account__c);
            if (isContactDelete)
                conIdSet.add(rbi.Id);
        }
        for (Reference_Basic_Information__c rbi: [select Id, RUL_Limit_Reached__c, Account__c, Contact__r.LastName, Referenceability_Status__c, Is_Referenceable__c, Is_Contact_Limit_Reached__c from Reference_Basic_Information__c where Generic_Account__c = false AND Account__c != null and Account__c In: accountIds and Id Not In: conIdSet]) {
            if (rbi.Contact__c == null) {
                accountMap.put(rbi.Account__c, rbi);
            }
            if (rbi.Contact__c != null) {
                if ((rbi.Referenceability_Status__c != ConstantsController.INACTIVE && rbi.Referenceability_Status__c != null)) {
                    if (!accountContactsMap.containsKey(rbi.Account__c))
                        accountContactsMap.put(rbi.Account__c, new list < Reference_Basic_Information__c > ());
                    accountContactsMap.get(rbi.Account__c).add(rbi);
                } else {
                    if (!accountContactsMap.containsKey(rbi.Account__c)) {
                        accountContactsMap.put(rbi.Account__c, new list < Reference_Basic_Information__c > ());
                    }
                }
            }
        }
        for (Id accId: accountMap.keySet()) {
            if (accountMap.get(accId).Is_Referenceable__c) {
                limitReached = true;
                if (accountContactsMap.containsKey(accId)) {
                    for (Reference_Basic_Information__c c: accountContactsMap.get(accId)) {
                        if (c.RUL_Limit_Reached__c == false)
                            limitReached = false;
                    }
                    if (accountContactsMap.get(accId).size() == 0) {
                        limitReached = false;
                    }
                } else {
                    limitReached = false;
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
        if (updateRBIs.size() > 0){
            //update updateRBIs;
            WithoutSharingHelperController.upsertRBI(updateRBIs); 
        }
    }

    /**
     * Method to check for Attribute Mapping
     */
    private static void checkForAttributeMapping(list < Contact > contacts, map < Id, Contact > newContactMap, map < Id, Contact > oldContactMap) {
        ConstantsController.attMappingForContact = false;
        Savepoint sp = database.setSavepoint();
        try {
            Map < String, Schema.SObjectField > fldObjMap = schema.SObjectType.Contact.fields.getMap();
            list < Attribute_Mapping__c > attMappings = new list < Attribute_Mapping__c > ();
            for (Attribute_Mapping__c attM: [select Field_Api_Name__c, Auto_populate__c, Auto_add__c, Auto_Update__c, Auto_delete__c
                    from Attribute_Mapping__c where object__c = : ConstantsController.CONTACT
                    and Field_Api_Name__c != null and Is_Related_Mapping__c = false
                ]) {
                if (fldObjMap.containsKey(attM.Field_Api_Name__c.tolowerCase())) {
                    attMappings.add(attM);
                }
            }
            map < String, list < Contact >> attMappingContact = new map < String, list < Contact >> ();
            set < Id > mappingCreateAttribute = new set < Id > ();
            map < String, set < String >> ContactFieldAttDelete = new map < String, set < String >> ();
            list < Contact_Attribute__c > deleteContactAtt = new list < Contact_Attribute__c > ();
            list < Contact_Attribute__c > createContactAtt = new list < Contact_Attribute__c > ();
            map < Id, set < Id >> contactAttributesAssociated = new map < Id, set < Id >> ();
            set < String > preventDuplicacy = new set < String > ();
            set < Id > attMappingUpdateAndDelete = new set < Id > ();
            set < Id > conIds = new set < Id > ();
            //create a map of attributMapping and accounts in which the field value is not null
            if (attMappings.size() > 0) {
                for (Contact con: Contacts) {
                    conIds.add(con.Id);
                    for (Attribute_Mapping__c attMapping: attMappings) {
                        if (((oldContactMap.get(con.Id).get(attMapping.Field_Api_Name__c) != null && newContactMap.get(con.Id).get(attMapping.Field_Api_Name__c) == null) || (newContactMap.get(con.Id).get(attMapping.Field_Api_Name__c) != null)) && attMapping.Auto_populate__c) {
                            if (!attMappingContact.containsKey(attMapping.Id))
                                attMappingContact.put(attMapping.Id, new list < Contact > ());
                            attMappingContact.get(attMapping.Id).add(con);
                        }
                        if (attMapping.Auto_add__c || attMapping.Auto_Update__c || attMapping.Auto_delete__c)
                            attMappingUpdateAndDelete.add(attMapping.Id);
                    }
                    contactAttributesAssociated.put(con.Id, new set < Id > ());
                }
                UtilityController.checkAttributeMappingEdit(attMappingUpdateAndDelete, 'Contact');
                //checkAttributeMappingEdit(attMappingUpdateAndDelete);
                //if the trigger is an update trigger 
                if (oldContactMap != null) {
                    for (Attribute_Mapping__c attMapping: attMappings) {
                        if (attMappingContact.get(attMapping.Id) != null) {
                            for (Contact con: attMappingContact.get(attMapping.Id)) {
                                //if the value is changed then we have to delete the previous value attribute
                                if (oldContactMap.get(con.Id).get(attMapping.Field_Api_Name__c) != null && oldContactMap.get(con.Id).get(attMapping.Field_Api_Name__c) != newContactMap.get(con.Id).get(attMapping.Field_Api_Name__c)) {
                                    if (!ContactFieldAttDelete.containsKey(con.Id))
                                        ContactFieldAttDelete.put(con.Id, new set < String > ());
                                    //this map consists of the acocunt Id and value 
                                    if (oldContactMap.get(con.Id).get(attMapping.Field_Api_Name__c) != null) {
                                        for (String att: String.valueOf(oldContactMap.get(con.Id).get(attMapping.Field_Api_Name__c)).split(';')) {
                                            boolean attributePresent = false;
                                            if (newContactMap.get(con.Id).get(attMapping.Field_Api_Name__c) != null) {
                                                for (string newAtt: string.valueOf(newContactMap.get(con.Id).get(attMapping.Field_Api_Name__c)).split(';')) {
                                                    if (newAtt == att)
                                                        attributePresent = true;
                                                }
                                            }
                                            if (!attributePresent)
                                                ContactFieldAttDelete.get(con.Id).add(att);
                                        }
                                    }
                                }
                            }
                        }
                        if (attMappingContact.get(attMapping.Id) != null && attMappingContact.get(attMapping.Id).size() == 0)
                            attMappingContact.remove(attMapping.Id);
                    }
                    //delete the previous field value attributes
                    for (Contact_Attribute__c conAtt: [select name, Id, attribute__r.Name, Contact__r.Id, Attribute__r.Id, Is_fromMapping__c from Contact_Attribute__c where Contact__c In: conIds]) {
                        if (ContactFieldAttDelete.containsKey(conAtt.Contact__r.Id) && conAtt.Is_fromMapping__c) {
                            if (ContactFieldAttDelete.get(conAtt.Contact__r.Id).contains(conAtt.attribute__r.Name))
                                deleteContactAtt.add(conAtt);
                        }
                        contactAttributesAssociated.get(conAtt.Contact__r.Id).add(conAtt.Attribute__r.Id);
                    }
                    if (deleteContactAtt.size() > 0) {
                        ConstantsController.attMappingForAccount = false;
                        ConstantsController.attMappingForContact = false;
                        ConstantsController.attMappingForRefContent = false;
                        //delete deleteContactAtt;
                        WithoutSharingHelperController.deleteContactAttributes(deleteContactAtt);
                    }
                }
                //create new field value accountAttributes
                //query all the parent along with child attributes of the mapping
                for (Attribute__c att: [select Id, name, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Auto_populate__c, (Select Id, Name From Attributes__r), Attribute_Mapping__r.Inheritable__c from Attribute__c where Attribute_Mapping__c In: attMappingContact.keySet() and level__c = 0]) {
                    if (attMappingContact.get(att.Attribute_Mapping__r.Id) != null && att.Attribute_Mapping__r.Auto_populate__c) {
                        for (Contact con: attMappingContact.get(att.Attribute_Mapping__r.Id)) {
                            for (Attribute__c childAtt: att.Attributes__r) {
                                if (con.get(att.Attribute_Mapping__r.Field_Api_Name__c) != null) {
                                    for (String attStr: string.valueOf(con.get(att.Attribute_Mapping__r.Field_Api_Name__c)).split(';')) {
                                        if (attStr == childAtt.Name && !preventDuplicacy.contains(con.Id + '' + childAtt.Id) && !contactAttributesAssociated.get(con.Id).contains(childAtt.Id)) {
                                            createContactAtt.add(new Contact_Attribute__c(Contact__c = con.Id, Attribute__c = childAtt.Id, Is_fromMapping__c = true));
                                            preventDuplicacy.add(con.Id + '' + childAtt.Id);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if (createContactAtt.size() > 0) {
                    ConstantsController.attMappingForAccount = false;
                    ConstantsController.attMappingForContact = false;
                    ConstantsController.attMappingForRefContent = false;
                    //insert createContactAtt;
                    WithoutSharingHelperController.upsertContactAttributes(createContactAtt);
                }
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw e;
        }
    }
    /**
     * Method to Update Hitlist Records
     */
    private static void updateHitlist(set < String > setContactId, map < Id, Contact > newContactMap) {
        List < Hit_List__c > hitList = new List < Hit_List__c > ();
        for (Hit_List__c hl: [select Contact__c, Email__c, Phone__c from Hit_List__c where Contact__c IN: setContactId]) {
            hl.Email__c = newContactMap.get(hl.Contact__c).Email;
            hl.Phone__c = newContactMap.get(hl.Contact__c).Phone;
            hitList.add(hl);
        }
        if (hitList.size() > 0)
            update hitList;
    }
    /**
     * Method to move data on chnage of account
     */
    private static void reassignAccount(list < Contact > contactList, map < Id, Reference_Basic_Information__c > RBIMap, map < Id, Reference_Basic_Information__c > accRBI) {
        list < Reference_Basic_Information__c > updateRBIs = new list < Reference_Basic_Information__c > ();
        list < Reward__c > updateRewards = new list < Reward__c > ();
        list < Hit_List__c > updateHitLists = new list < Hit_List__c > ();
        list < Referenceability__c > updateRefs = new list < Referenceability__c > ();
        list < Nomination__c > updateNominations = new list < Nomination__c > ();
        list < Account_Attribute__c > deleteAccAtts = new list < Account_Attribute__c > ();
        list < Account_Attribute__c > insertAccAtts = new list < Account_Attribute__c > ();
        list < Contact_Attribute__c > deleteConAtts = new list < Contact_Attribute__c > ();
        set < Id > accountIds = new set < Id > ();
        list < Reference_Request_Account_Contact__c > deleteRRACs = new list < Reference_Request_Account_Contact__c > ();
        set < string > conIdSet = new set < String > ();
        for (Contact con: contactList) {
            accountIds.add(con.AccountId);
            if(RBIMap != null && RBIMap.containsKey(con.Id))
                updateRBIs.add(RBIMap.get(con.Id));
            conIdSet.add(con.Id);
        }
        map < Id, Account > accounts = new map < Id, Account > ([select Id, Name, (select Id, Account__c, Referenceability_Status__c, Contact__c, Is_Referenceable__c from Reference_Basic_Informations__r where Generic_Account__c = false AND Contact__c = null and Account__c != null) from Account where Id IN: accountIds]);
        if (updateRBIs.size() > 0) {
            ConstantsController.updateRBIOnAccountChange = true;
            update updateRBIs;
        }
        List < Contact > contacts = [Select AccountId, (Select Id, Name, Activity_Date__c, Approval_Status__c, Approve_Deny_Notes__c, Contact_Email__c, Contact_Phone__c, Contact_Request_Status__c, Contact_Request__c, Contact_Title__c, Contact__c, Deadline__c, Feedback_Response__c, Feedback_Status__c, Is_Escalation_to_Owner_Manager__c, Is_Feedback_Notification_Send__c, Is_Feedback_Received__c, Is_No_Response__c, Is_Reminder_to_Owner__c, Project_Owner__c, Reference_Request_Account__c, Reference_Use__c, Referenceability_Type__c, Request_notes__c, Task_ID__c, Contact_Name__c From Reference_Request_Account_Contacts__r), (Select Id, Name, Account__c, Contact__c, Disposition__c, Email_Enabled__c, New_Nomination_URL__c, Note__c, Other_Info__c, Status__c From Nominations__r), (Select Id, Name, Account_Request__c, Account__c, ActionAccount_f__c, ActionContact_f__c, Contact__c, Deadline__c, Disposition__c, Email__c, Field1__c, Note__c, Opportunity__c, Phone__c, Reference_Request__c, Referenceability_Type__c, Released__c, Unspecified_Request__c From Hit_Lists__r), (Select Id, Name, Contact__c, Attribute__c, From_Account__c, Is_fromMapping__c From Contact_Attributes__r where From_Account__c = true)
            From Contact where Id IN: conIdSet
        ];
        list < Contact > addContactsChild = [Select AccountId,Name, (Select Id, Name, Account__c, Comments__c, Contact__c From Rewards__r), (Select Id, Name, Account__c, Comment__c, Contact__c, Referenceability_Type__c, Referenceability_Type_f__c, Status__c, Verified__c From Referenceabilities__r), (Select Id, Name, Account__c, Attribute__c, Contact__c, Inheritable__c, Reference_Content__c, Is_fromMapping__c From Account_Attributes__r)
            From Contact where Id IN: conIdSet
        ];
        for (Contact con: addContactsChild) {
            for (Reward__c reward: con.Rewards__r) {
                reward.Contact__c = null;
                reward.Comments__c = 'Originally rewarded to the Contact, '+con.Name+'.';
                updateRewards.add(reward);
            }
            for (Referenceability__c ref: con.Referenceabilities__r) {
                if (RBIMap != null && RBIMap.containsKey(con.Id) && (RBIMap.get(con.Id).Referenceability_Status__c == ConstantsController.CAUTION || RBIMap.get(con.Id).Referenceability_Status__c == ConstantsController.ACTIVE) && (accounts.get(con.AccountId).Reference_Basic_Informations__r.size() > 0 && accounts.get(con.AccountId).Reference_Basic_Informations__r[0].Is_Referenceable__c)) {
                    ref.Account__c = con.AccountId;
                } else {
                    ref.Account__c = null;
                }
                updateRefs.add(ref);
            }
            if (RBIMap != null && RBIMap.containsKey(con.Id) && (RBIMap.get(con.Id).Referenceability_Status__c == ConstantsController.CAUTION || RBIMap.get(con.Id).Referenceability_Status__c == ConstantsController.ACTIVE) && (accounts.get(con.AccountId).Reference_Basic_Informations__r.size() > 0 && accounts.get(con.AccountId).Reference_Basic_Informations__r[0].Is_Referenceable__c)) {
                for (Account_Attribute__c accatt: con.Account_Attributes__r) {
                    Account_Attribute__c newAtt = accatt.clone(false, true);
                    newAtt.Account__c = con.AccountId;
                    insertAccAtts.add(newAtt);
                }
            }
            for (Account_Attribute__c accatt: con.Account_Attributes__r) {
                deleteAccAtts.add(accatt);
            }
        }
        for (Contact con: contacts) {

            for (Contact_Attribute__c conatt: con.Contact_Attributes__r) {
                deleteConAtts.add(conatt);
            }
            for (Reference_Request_Account_Contact__c rrac: con.Reference_Request_Account_Contacts__r) {
                deleteRRACs.add(rrac);
            }
            for (Nomination__c nom: con.Nominations__r) {
                nom.Account__c = con.AccountId;
                updateNominations.add(nom);
            }

            for (Hit_List__c hit: con.Hit_Lists__r) {
                hit.Account__c = con.AccountId;
                if (accRBI.containsKey(hit.Account__c))
                    hit.Reference_Profile__c = accRBI.get(hit.Account__c).Id;
                else
                    hit.Reference_Profile__c = null;
                updateHitLists.add(hit);
            }

        }
        if (updateRefs.size() > 0) {
            ConstantsController.updateReferenceabilityOnAccountChange = true;
            update updateRefs;
        }
        if (updateNominations.size() > 0)
            update updateNominations;
        if (updateHitLists.size() > 0)
            delete updateHitLists;
        if (insertAccAtts.size() > 0)
            insert insertAccAtts;
        if (updateRewards.size() > 0)
            update updateRewards;
        if (deleteRRACs.size() > 0)
            delete deleteRRACs;
        if (deleteConAtts.size() > 0)
            delete deleteConAtts;
        if (deleteAccAtts.size() > 0) {
            ConstantsController.shouldAccountAttributeDeleteOfContact = true;
            delete deleteAccAtts;
        }
        addAttributesOnContactFromAccount(contacts);
    }
}