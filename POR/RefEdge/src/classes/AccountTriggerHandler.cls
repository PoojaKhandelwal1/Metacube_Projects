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
public with sharing class AccountTriggerHandler { 
    
    /**
     * Method called on before delete of Account
     */
    public static void onBeforeDelete(list < Account > oldAccounts, map < Id, Account > oldAccountMap) {
        set < Id > contactMap = new set < Id > ();
        //save all related record's Id which has to delete
        for (Account accObj: [select Id, (select Id from Contacts), (Select Id From Rewards__r), (Select Id From Reference_Request_Accounts__r), (Select Id, Is_fromMapping__c, Account__c, Attribute__c From Account_Attributes__r), (Select Id From Nominations__r), (Select Id From Hit_Lists__r), (Select Id From Reference_Basic_Informations__r) from Account where Id IN: oldAccountMap.keySet()]) {
            for (Contact con: accObj.Contacts) {
                contactMap.add(con.Id);
            }
            for (Account_Attribute__c con: accObj.Account_Attributes__r) {
                ConstantsController.AccountAttsDelete.add(con);
            }
            for (Reward__c con: accObj.Rewards__r) {
                ConstantsController.RewardList.add(con);
            }
            for (Reference_Basic_Information__c con: accObj.Reference_Basic_Informations__r) {
                ConstantsController.RBIIdSet.add(con);
            }
            for (Nomination__c con: accObj.Nominations__r) {
                ConstantsController.NominationList.add(con);
            }
            for (Hit_List__c con: accObj.Hit_Lists__r) {
                ConstantsController.HitIdSet.add(con);
            }
        }
        ConstantsController.RefIdSet = [select Id, Referenceability_Type__c from Referenceability__c where Account__c IN: oldAccountMap.keySet() Or Contact__c IN: contactMap];
        ConstantsController.rracList = [select Id from Reference_Request_Account_Contact__c where Contact__c IN: contactMap];

    }
    
    /**
     * Method called on after delete of Account
     */
    public static void onAfterDelete(list < Account > oldAccounts, map < Id, Account > oldAccountMap) {
        try {
            string accountId = '';
            decimal lifeTimePoints = 0;
            decimal CurrentPoints = 0;
            boolean iscandidate = false;
            set < String > statusSet = new set < String > ();
            map < String, Reference_Basic_Information__c > deletedRBI = new map < String, Reference_Basic_Information__c > ();
            list < Reference_Basic_Information__c > deleteRBIs = new list < Reference_Basic_Information__c > ();
            list < Reference_Basic_Information__c > allRBIs = WithoutSharingHelperController.getRBIonMergeProcess();
            //fetch the RBI to be deleted and leave RBI which is merged
            for (Reference_Basic_Information__c rbi: allRBIs) {
                if (rbi.Contact__c == null || rbi.Account__c == null) {
                    deleteRBIs.add(rbi);
                }
                if (rbi.Account__c != null && rbi.Contact__c == null) {
                    if (rbi.Reference_Program_Candidate__c)
                        iscandidate = true;
                    lifeTimePoints += (rbi.Lifetime_Points__c != null ? rbi.Lifetime_Points__c : 0);
                    CurrentPoints += (rbi.Current_Available_Balance_Points__c != null ? rbi.Current_Available_Balance_Points__c : 0);
                    accountId = rbi.Account__c;
                    if (rbi.Is_Referenceable__c) {
                        statusSet.add(rbi.Referenceability_Status__c);
                        if (!deletedRBI.containsKey(rbi.Referenceability_Status__c) || (deletedRBI.containsKey(rbi.Referenceability_Status__c) && rbi.Reference_Owner__c != null))
                            deletedRBI.put(rbi.Referenceability_Status__c, rbi);
                    }
                }
            }

            if (deleteRBIs.size() > 0){
                //delete deleteRBIs;
                //Database.emptyRecycleBin( deleteRBIs );
                WithoutSharingHelperController.deleteReferenceProfiles(deleteRBIs);
            }
            list < Reference_Request_Account_Contact__c > deleteRRAC = new list < Reference_Request_Account_Contact__c > ();
            for (Reference_Request_Account_Contact__c rrac: [select Id, Contact__c from Reference_Request_Account_Contact__c where Id IN: ConstantsController.rracList]) {
                if (rrac.Contact__c == null) {
                    deleteRRAC.add(rrac);
                }
            }

            list < Referenceability__c > deleteRefs = new list < Referenceability__c > ();
            list < Referenceability__c > refereList = [select Id, Account__c, Contact__c, Referenceability_Type__c from Referenceability__c where Id IN: ConstantsController.RefIdSet];
            for (Referenceability__c ref: refereList) {
                if (ref.Account__c == null && ref.Contact__c == null) {
                    deleteRefs.add(ref);
                } else {
                    accountId = ref.Account__c;
                }
            }
            list < Nomination__c > deleteNomis = new list < Nomination__c > ();
            for (Nomination__c nomi: [select Id, Account__c from Nomination__c where Id IN: ConstantsController.NominationList]) {
                if (nomi.Account__c == null) {
                    deleteNomis.add(nomi);
                }
            }
            list < Hit_List__c > deleteHits = new list < Hit_List__c > ();
            for (Hit_List__c hit: [select Id, Account__c from Hit_List__c where Id IN: ConstantsController.HitIdSet]) {
                if (hit.Account__c == null) {
                    deleteHits.add(hit);
                }
            }
            list < Reward__c > deleteRewards = new list < Reward__c > ();
            for (Reward__c reward: [select Id, Account__c from Reward__c where Id IN: ConstantsController.RewardList]) {
                if (reward.Account__c == null) {
                    deleteRewards.add(reward);
                }
            }

            if (deleteRRAC.size() > 0){
            	//delete deleteRRAC;
            	WithoutSharingHelperController.deleteContactRequests(deleteRRAC);
            }
                

            if (deleteNomis.size() > 0){
            	//delete deleteNomis;
            	WithoutSharingHelperController.deleteNominations(deleteNomis);
            }

            if (deleteRewards.size() > 0) {
                ConstantsController.shouldRewardRecordsValidatedOnDelete = false;
                //delete deleteRewards;
                WithoutSharingHelperController.deleteRewards(deleteRewards);
            }
            list < Reference_Basic_Information__c > rbiRecord = new list < Reference_Basic_Information__c > ();
            list < Account_Attribute__c > accuntAttribDelete = new list < Account_Attribute__c > ();
            list < Account_Reference_Content__c > deleteAccRefs = new list < Account_Reference_Content__c > ();
            list < Account_Attribute__c > accuntAttributeList = new list < Account_Attribute__c > ();
            //if the Account to be merged in another Account
            if (accountId != '') {
                Boolean isCreateRBI = false;
                list < Account > accList = [select Id, (select Account__c, Activity_Date__c, Id from Reference_Request_Accounts__r where 
                	Account_Request_Status__c = 'Completed'), (select Id, Account__c, Referenceability_Status__c, Is_Referenceable__c, Reference_Program_Candidate__c, 
                	Lifetime_Points__c, Current_Available_Balance_Points__c,Attributes__c,Attribute_Ids__c,Label_Ids1__c,Label_Ids2__c,Parent_Attributes__c,
                    RUL_Limit_Reached__c, RUL_Activities_will_do__c, RUL_Period__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Contact__c, 
                    RUL_Last_Updated_By__c,Account__r.OwnerId,Reference_Owner__c,Profile_Update_Owner__c from Reference_Basic_Informations__r), 
                    (Select Id, Reference_Request__c From Hit_Lists__r where Contact__c = null),
                     (select Id, Reference_Content__c from Account_Reference_Contents__r), (select Id, Account__c, Contact__c, Referenceability_Type__c, 
                     Referenceability_Type__r.Referenceability_no__c, Referenceability_Type__r.Name, Status__c from Referenceabilities__r), 
                     (select Id, Is_fromMapping__c, Account__c, Attribute__c, Attribute__r.Name from Account_Attributes__r) from Account where Id = : accountId];
                if (accList.size() > 0) {
                    Account accountObj = accList.get(0);
                    list < Referenceability__c > refList = new list < Referenceability__c > ();
                    set < Id > attSet = new set < Id > ();
                    set < string > attributeSet = new set < string > ();
                    set < Id > refSet = new set < Id > ();
                    //remove duplicate Hitlist records
                    for (Hit_List__c aa: accountObj.Hit_Lists__r) {
                        if (refSet.contains(aa.Reference_Request__c)) {
                            deleteHits.add(aa);
                        }
                        refSet.add(aa.Reference_Request__c);
                    }
                    refSet = new set < Id > ();
                    //remove duplicate Account Refernce Content records
                    for (Account_Reference_Content__c ar: accountObj.Account_Reference_Contents__r) {
                        if (refSet.contains(ar.Reference_Content__c)) {
                            deleteAccRefs.add(ar);
                        }
                        refSet.add(ar.Reference_Content__c);
                    }
                    refSet = new set < Id > ();
                    Custom_Settings__c cs = UtilityController.getCustomSettings();
                    //remove duplicate Referenceability records
                    for (Referenceability__c aa: accountObj.Referenceabilities__r) {
                        if(aa.Contact__c == null){
                        	isCreateRBI = true;
                        }
                        if (aa.Contact__c == null && refSet.contains(aa.Referenceability_Type__c)) {
                            deleteRefs.add(aa);
                        } else{
                            refList.add(aa);
                        }
                        if(aa.Contact__c == null)
                        	refSet.add(aa.Referenceability_Type__c);
                    }
                    //remove duplicate Account Attribute records
                    for (Account_Attribute__c aa: accountObj.Account_Attributes__r) {
                        isCreateRBI = true;
                        if (!aa.Is_fromMapping__c) {
                            if (attSet.contains(aa.Attribute__c)) {
                                accuntAttribDelete.add(aa);
                            } else {
                                accuntAttributeList.add(aa);
                                attributeSet.add(aa.Attribute__c);
                            }
                            attSet.add(aa.Attribute__c);
                        } else {
                            accuntAttribDelete.add(aa);
                        }
                    }
                    for (Reference_Request_Account__c rra: accountObj.Reference_Request_Accounts__r) {
                        isCreateRBI = true;
                        break;
                    }
                    boolean limitReached = false;
                    for (Reference_Basic_Information__c rbi: accountObj.Reference_Basic_Informations__r) {
                        if (rbi.Contact__c != null)
                            limitReached = true;
                    }
                    for (Reference_Basic_Information__c rbi: accountObj.Reference_Basic_Informations__r) {
                        if (rbi.Contact__c == null) {
                            rbiRecord.add(rbi);
                        } else {
                            if (rbi.RUL_Limit_Reached__c == false)
                                limitReached = false;
                        }
                    }
                    //if the Master Account already has Reference Profile
                    if (rbiRecord != null && rbiRecord.size() > 0) {
                        if (statusSet.contains(ConstantsController.ACTIVE) && rbiRecord[0].Referenceability_Status__c != ConstantsController.ACTIVE) {
                            rbiRecord[0].Referenceability_Status__c = ConstantsController.ACTIVE;
                            rbiRecord[0].Is_Referenceable__c = true;
                            rbiRecord[0].Reference_Program_Candidate__c = false;
                            rbiRecord[0].RUL_Period__c = deletedRBI.get(ConstantsController.ACTIVE).RUL_Period__c;
                            rbiRecord[0].RUL_Activities_will_do__c = deletedRBI.get(ConstantsController.ACTIVE).RUL_Activities_will_do__c;
                            rbiRecord[0].Reference_Owner__c = (deletedRBI.get(ConstantsController.ACTIVE).Reference_Owner__c != null ? deletedRBI.get(ConstantsController.ACTIVE).Reference_Owner__c : rbiRecord[0].Reference_Owner__c);
                            rbiRecord[0].RUL_Last_Updated_By__c = (deletedRBI.get(ConstantsController.ACTIVE).RUL_Last_Updated_By__c != null ? deletedRBI.get(ConstantsController.ACTIVE).RUL_Last_Updated_By__c : rbiRecord[0].RUL_Last_Updated_By__c);
                            rbiRecord[0].Managed_Reference_Account__c = deletedRBI.get(ConstantsController.ACTIVE).Managed_Reference_Account__c;
                            rbiRecord[0].Joined_Reference_Program__c = deletedRBI.get(ConstantsController.ACTIVE).Joined_Reference_Program__c;
                        } else if (statusSet.contains(ConstantsController.CAUTION) && rbiRecord[0].Referenceability_Status__c != ConstantsController.ACTIVE && rbiRecord[0].Referenceability_Status__c != ConstantsController.CAUTION) {
                            rbiRecord[0].Referenceability_Status__c = ConstantsController.CAUTION;
                            rbiRecord[0].Is_Referenceable__c = true;
                            rbiRecord[0].Reference_Program_Candidate__c = false;
                            rbiRecord[0].RUL_Period__c = deletedRBI.get(ConstantsController.CAUTION).RUL_Period__c;
                            rbiRecord[0].RUL_Activities_will_do__c = deletedRBI.get(ConstantsController.CAUTION).RUL_Activities_will_do__c;
                            rbiRecord[0].Reference_Owner__c = (deletedRBI.get(ConstantsController.CAUTION).Reference_Owner__c != null ? deletedRBI.get(ConstantsController.CAUTION).Reference_Owner__c : rbiRecord[0].Reference_Owner__c);
                            rbiRecord[0].RUL_Last_Updated_By__c = (deletedRBI.get(ConstantsController.CAUTION).RUL_Last_Updated_By__c != null ? deletedRBI.get(ConstantsController.CAUTION).RUL_Last_Updated_By__c : rbiRecord[0].RUL_Last_Updated_By__c);
                            rbiRecord[0].Managed_Reference_Account__c = deletedRBI.get(ConstantsController.CAUTION).Managed_Reference_Account__c;
                            rbiRecord[0].Joined_Reference_Program__c = deletedRBI.get(ConstantsController.CAUTION).Joined_Reference_Program__c;
                        } else if (statusSet.contains(ConstantsController.INACTIVE) && (rbiRecord[0].Referenceability_Status__c == null || rbiRecord[0].Referenceability_Status__c == ConstantsController.INACTIVE)) {
                            rbiRecord[0].Referenceability_Status__c = ConstantsController.INACTIVE;
                            rbiRecord[0].Is_Referenceable__c = true;
                            rbiRecord[0].Reference_Program_Candidate__c = false;
                            rbiRecord[0].RUL_Period__c = deletedRBI.get(ConstantsController.INACTIVE).RUL_Period__c;
                            rbiRecord[0].RUL_Activities_will_do__c = deletedRBI.get(ConstantsController.INACTIVE).RUL_Activities_will_do__c;
                            rbiRecord[0].Reference_Owner__c = (deletedRBI.get(ConstantsController.INACTIVE).Reference_Owner__c != null ? deletedRBI.get(ConstantsController.INACTIVE).Reference_Owner__c : rbiRecord[0].Reference_Owner__c);
                            rbiRecord[0].RUL_Last_Updated_By__c = (deletedRBI.get(ConstantsController.INACTIVE).RUL_Last_Updated_By__c != null ? deletedRBI.get(ConstantsController.INACTIVE).RUL_Last_Updated_By__c : rbiRecord[0].RUL_Last_Updated_By__c);
                            rbiRecord[0].Managed_Reference_Account__c = deletedRBI.get(ConstantsController.INACTIVE).Managed_Reference_Account__c;
                            rbiRecord[0].Joined_Reference_Program__c = deletedRBI.get(ConstantsController.INACTIVE).Joined_Reference_Program__c;
                        } else if (iscandidate && !rbiRecord[0].Is_Referenceable__c) {
                            rbiRecord[0].Reference_Program_Candidate__c = true;
                        }
                    //if the Master Account dosen't has Reference Profile then create a new one
                    } else if (statusSet.size() > 0) {
                        Reference_Basic_Information__c newRbi = new Reference_Basic_Information__c();
                        rbiRecord = new list < Reference_Basic_Information__c > ();
                        newRbi.Account__c = accountId;
                        if (statusSet.contains(ConstantsController.ACTIVE)) {
                            newRbi.Referenceability_Status__c = ConstantsController.ACTIVE;
                            newRbi.Is_Referenceable__c = true;
                            newRbi.Reference_Program_Candidate__c = false;
                            newRbi.RUL_Period__c = deletedRBI.get(ConstantsController.ACTIVE).RUL_Period__c;
                            newRbi.RUL_Activities_will_do__c = deletedRBI.get(ConstantsController.ACTIVE).RUL_Activities_will_do__c;
                            newRbi.Reference_Owner__c = (deletedRBI.get(ConstantsController.ACTIVE).Reference_Owner__c != null ? deletedRBI.get(ConstantsController.ACTIVE).Reference_Owner__c : newRbi.Reference_Owner__c);
                            newRbi.RUL_Last_Updated_By__c = (deletedRBI.get(ConstantsController.ACTIVE).RUL_Last_Updated_By__c != null ? deletedRBI.get(ConstantsController.ACTIVE).RUL_Last_Updated_By__c : newRbi.RUL_Last_Updated_By__c);
                            newRbi.Managed_Reference_Account__c = deletedRBI.get(ConstantsController.ACTIVE).Managed_Reference_Account__c;
                            newRbi.Joined_Reference_Program__c = deletedRBI.get(ConstantsController.ACTIVE).Joined_Reference_Program__c;
                        } else if (statusSet.contains(ConstantsController.CAUTION)) {
                            newRbi.Referenceability_Status__c = ConstantsController.CAUTION;
                            newRbi.Is_Referenceable__c = true;
                            newRbi.Reference_Program_Candidate__c = false;
                            newRbi.RUL_Period__c = deletedRBI.get(ConstantsController.CAUTION).RUL_Period__c;
                            newRbi.RUL_Activities_will_do__c = deletedRBI.get(ConstantsController.CAUTION).RUL_Activities_will_do__c;
                            newRbi.Reference_Owner__c = (deletedRBI.get(ConstantsController.CAUTION).Reference_Owner__c != null ? deletedRBI.get(ConstantsController.CAUTION).Reference_Owner__c : newRbi.Reference_Owner__c);
                            newRbi.RUL_Last_Updated_By__c = (deletedRBI.get(ConstantsController.CAUTION).RUL_Last_Updated_By__c != null ? deletedRBI.get(ConstantsController.CAUTION).RUL_Last_Updated_By__c : newRbi.RUL_Last_Updated_By__c);
                            newRbi.Managed_Reference_Account__c = deletedRBI.get(ConstantsController.CAUTION).Managed_Reference_Account__c;
                            newRbi.Joined_Reference_Program__c = deletedRBI.get(ConstantsController.CAUTION).Joined_Reference_Program__c;
                        } else if (statusSet.contains(ConstantsController.INACTIVE)) {
                            newRbi.Referenceability_Status__c = ConstantsController.INACTIVE;
                            newRbi.Is_Referenceable__c = true;
                            newRbi.Reference_Program_Candidate__c = false;
                            newRbi.RUL_Period__c = deletedRBI.get(ConstantsController.INACTIVE).RUL_Period__c;
                            newRbi.RUL_Activities_will_do__c = deletedRBI.get(ConstantsController.INACTIVE).RUL_Activities_will_do__c;
                            newRbi.Reference_Owner__c = (deletedRBI.get(ConstantsController.INACTIVE).Reference_Owner__c != null ? deletedRBI.get(ConstantsController.INACTIVE).Reference_Owner__c : newRbi.Reference_Owner__c);
                            newRbi.RUL_Last_Updated_By__c = (deletedRBI.get(ConstantsController.INACTIVE).RUL_Last_Updated_By__c != null ? deletedRBI.get(ConstantsController.INACTIVE).RUL_Last_Updated_By__c : newRbi.RUL_Last_Updated_By__c);
                            newRbi.Managed_Reference_Account__c = deletedRBI.get(ConstantsController.INACTIVE).Managed_Reference_Account__c;
                            newRbi.Joined_Reference_Program__c = deletedRBI.get(ConstantsController.INACTIVE).Joined_Reference_Program__c;
                        }
                        rbiRecord.add(newRbi);
                    //if the Master Account already has Reference Profile with Candidate check
                    } else if (iscandidate) {
                        Reference_Basic_Information__c newRbi = new Reference_Basic_Information__c();
                        rbiRecord = new list < Reference_Basic_Information__c > ();
                        newRbi.Account__c = accountId;
                        newRbi.Reference_Program_Candidate__c = true;
                        rbiRecord.add(newRbi);
                    }
                    else if(isCreateRBI){
                        Reference_Basic_Information__c newRbi = new Reference_Basic_Information__c();
                        rbiRecord = new list < Reference_Basic_Information__c > ();
                        newRbi.Account__c = accountId;
                        rbiRecord.add(newRbi);
                    }
                    if (rbiRecord != null && rbiRecord.size() > 0 && rbiRecord[0].Is_Referenceable__c) {
                        //set all RUL fields
                        rbiRecord[0].Lifetime_Points__c = (rbiRecord[0].Lifetime_Points__c != null ? rbiRecord[0].Lifetime_Points__c : 0) + lifeTimePoints;
                        rbiRecord[0].Current_Available_Balance_Points__c = (rbiRecord[0].Current_Available_Balance_Points__c != null ? rbiRecord[0].Current_Available_Balance_Points__c : 0) + CurrentPoints;
                        decimal completedUsesCount = 0;
                        decimal defaultcompletedUsesCount = 0;
                        date baseDate = date.today().addDays((rbiRecord[0].RUL_Period__c != null ? -integer.valueOf(rbiRecord[0].RUL_Period__c) : 0));
                        for (Reference_Request_Account__c rra: accountObj.Reference_Request_Accounts__r) {
                            if (rra.Activity_Date__c != null && (rra.Activity_Date__c).daysBetween(date.today()) <= cs.RUL_Period__c) {
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
                        rbiRecord[0].Total_Reference_Use__c = accountObj.Reference_Request_Accounts__r.size();
                        if (limitReached && !rbiRecord[0].Is_Contact_Limit_Reached__c) {
                            rbiRecord[0].Is_Contact_Limit_Reached__c = true;
                        } else if (!limitReached && rbiRecord[0].Is_Contact_Limit_Reached__c) {
                            rbiRecord[0].Is_Contact_Limit_Reached__c = false;
                        }
                        if (rbiRecord[0].Account_Level_RUL__c) {
                            if (rbiRecord[0].RUL_Activities_used__c > = rbiRecord[0].RUL_Activities_will_do__c) {
                                rbiRecord[0].RUL_Limit_Reached__c = true;
                            } else {
                                rbiRecord[0].RUL_Limit_Reached__c = false;
                            }
                        } else {
                            if (rbiRecord[0].Is_Contact_Limit_Reached__c) {
                                rbiRecord[0].RUL_Limit_Reached__c = true;
                            } else {
                                rbiRecord[0].RUL_Limit_Reached__c = false;
                            }
                        }
                    }
                    //set referenceabilities
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
                    //set attributes and labels
                    if (attributeSet.size() > 0) {
                        map < String, set<String> > attLabel = new map < String, set<String> > ();
                        map < String, String > attLabelName = new map < String, String > ();
                        for (Attributes_Labels__c attL: WithoutSharingHelperController.fetchAttributeLabels(attributeSet)) {
                            if(!attLabel.containsKey(attL.Attribute__c))
			                	attLabel.put(attL.Attribute__c, new set<string>());
			            	attLabel.get(attL.Attribute__c).add('F'+String.valueOf(attL.Label__r.Filter_no__c)+'F');
                            attLabelName.put(attL.Attribute__c, (attL.Attribute__r.Root_Parent__c != null ? attL.Attribute__r.Root_Parent__c : ''));
                        }
                        rbiRecord[0] = UtilityController.setFiltersForAccount(rbiRecord[0],accuntAttributeList,attLabel,attLabelName);
                        
                        for (Account_Attribute__c a: accuntAttributeList) {
                            a.Reference_Basic_Information__c = rbiRecord[0].Id;
                        }
                    }
                }
            }
            if (accuntAttribDelete.size() > 0) {
                ConstantsController.deleteAttributeFromAccount = false;
                ConstantsController.shouldAccountAttributeDeleteOfContact = true;
                ConstantsController.shouldAccountAttributeDeleteOfContent = true;
                ConstantsController.attMappingForAccount = false;
                ConstantsController.attMappingForContact = false;
                constantsController.accountDeletePrevious = true;
                ConstantsController.mergeAccountId = accountId;
                //delete accuntAttribDelete;
                WithoutSharingHelperController.deleteAccountAttributes(accuntAttribDelete);
            }
            if (deleteAccRefs.size() > 0){
                ConstantsController.stopTriggerContentAccountOnMerge = true;
                //delete deleteAccRefs;
                WithoutSharingHelperController.deleteAccRefs(deleteAccRefs);
                ConstantsController.stopTriggerContentAccountOnMerge = false;
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
            if(accuntAttributeList.size() > 0){
                ConstantsController.stopAccAttributeTrigger = true;
                WithoutSharingHelperController.upsertAccountAttributes(accuntAttributeList);
                ConstantsController.stopAccAttributeTrigger = false;
            }//end
            //system.assert(false,'************');
        } catch (Exception e) {
            throw e;
        }
    }
    
    /**
     * Method called on before update of Account
     */
    public static void onBeforeUpdate(list < Account > newAccounts, list < Account > oldAccounts, map < Id, Account > oldAccountMap) {
        System.debug('newAccounts.size() ::::'+newAccounts.size()+' constantsController.accountDeletePrevious  ::: '+constantsController.accountDeletePrevious+' newAccounts ::: '+newAccounts);
        if (newAccounts.size() == 1 && constantsController.accountDeletePrevious) {
            set<string> setAcc = new set<string>();
            for(Account acc : newAccounts){
                setAcc.add(acc.id);
            }
            list<Reference_Basic_Information__c> accRBI = [select Id from Reference_Basic_Information__c where Account__c IN : setAcc and Contact__c = null and (Is_Referenceable__c = true or Reference_Program_Candidate__c = true)];
            if(!accRBI.isEmpty())
                checkForMergeAccountsMapping(newAccounts, oldAccounts, oldAccountMap);
        }
    }
    
    /**
     * Method to create mapped Attribute on account merge
     */
    public static void checkForMergeAccountsMapping(list < Account > newAccounts, list < Account > oldAccounts, map < Id, Account > oldAccountMap) {
        Map < String, Schema.SObjectField > fldObjMap = schema.SObjectType.Account.fields.getMap();
        set < String > attributesToDelete = new set < String > ();
        list < Attribute_Mapping__c > attMappings = new list < Attribute_Mapping__c > ();
        set < String > preventDuplicacy = new set < String > ();
        list < Account_Attribute__c > createAccountAtt = new list < Account_Attribute__c > ();
        for (Attribute_Mapping__c attM: [select Field_Api_Name__c, Auto_populate__c, Auto_add__c, Auto_Update__c, Auto_delete__c
                from Attribute_Mapping__c where object__c = : ConstantsController.ACCOUNT
                and Field_Api_Name__c != null and Is_Related_Mapping__c = false
            ]) {
                System.debug('fldObjMap :::: '+fldObjMap.keySet());
            if (fldObjMap.containsKey(attM.Field_Api_Name__c.tolowerCase())) {
                attMappings.add(attM);
            }
        }
        if (!attMappings.isEmpty()) {
            map < String, Account_Attribute__c > accAttAssociated = new map < String, Account_Attribute__c > ();
            set < String > associatedAttributedIds = new set < String > ();
            for (Account_Attribute__c accAtt: [SELECT Id, Attribute__r.Name, Attribute__r.Id, Is_fromMapping__c, Inheritable__c FROM Account_Attribute__c WHERE Account__c IN : newAccounts AND Contact__c = null AND Reference_Content__c = null]) {
                accAttAssociated.put(accAtt.Attribute__r.Id, accAtt);
            }
            for (Attribute__c att: [select Id, name, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Auto_populate__c, (Select Id, Name From Attributes__r), Attribute_Mapping__r.Inheritable__c from Attribute__c where Attribute_Mapping__c In: attMappings and level__c = 0]) {
                if (att.Attribute_Mapping__r.Auto_populate__c) {
                    for (Account acc: newAccounts) {
                        for (Attribute__c childAtt: att.Attributes__r) {
                            if (acc.get(att.Attribute_Mapping__r.Field_Api_Name__c) != null /*&& oldAccountMap.get(acc.Id).get(att.Attribute_Mapping__r.Field_Api_Name__c) != acc.get(att.Attribute_Mapping__r.Field_Api_Name__c)*/ ) {
                                for (String attStr: string.valueOf(acc.get(att.Attribute_Mapping__r.Field_Api_Name__c)).split(';')) {
                                    if (attStr == childAtt.Name && !preventDuplicacy.contains(childAtt.Id) && !accAttAssociated.containsKey(childAtt.Id)) {
                                        createAccountAtt.add(new Account_Attribute__c(Account__c = acc.Id, Attribute__c = childAtt.Id, Is_fromMapping__c = true, Inheritable__c = att.Attribute_Mapping__r.Inheritable__c));
                                        preventDuplicacy.add(childAtt.Id);
                                    } else if (accAttAssociated.containsKey(childAtt.Id) && accAttAssociated.get(childAtt.Id).Inheritable__c != att.Attribute_Mapping__r.Inheritable__c) {
                                        accAttAssociated.get(childAtt.Id).Inheritable__c = att.Attribute_Mapping__r.Inheritable__c;
                                        createAccountAtt.add(accAttAssociated.get(childAtt.Id));
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if (!createAccountAtt.isEmpty()) {
                ConstantsController.attMappingForAccount = false;
                ConstantsController.attMappingForContact = false;
                ConstantsController.attMappingForRefContent = false;
                //upsert createAccountAtt;
                WithoutSharingHelperController.upsertAccountAttributes(createAccountAtt);
            }
        }
    }
    
    /**
     * Method called on after update of Account
     */
    public static void onAfterUpdate(list < Account > newAccounts, list < Account > oldAccounts, map < Id, Account > newAccountMap, map < Id, Account > oldAccountMap) {
        if(!ConstantsController.isCopyNominationDetailProcess){
	        list < Account > refActiveAccounts = new list < Account > ();
	        set < String > accountIdSet = new set < String > ();
	        for (Account acc: newAccounts) {
	            accountIdSet.add(acc.Id);
	        }
	        
	        if(accountIdSet.size() > 0){
	            for (Reference_Basic_Information__c rbi: [select Account__c, Is_Referenceable__c from Reference_Basic_Information__c where Account__c In: accountIdSet and contact__c = null and(Is_Referenceable__c = true Or Reference_Program_Candidate__c = true)]) {
	                refActiveAccounts.add(newAccountMap.get(rbi.Account__c));
	            }
	            if (!refActiveAccounts.isEmpty() && ConstantsController.attMappingForAccount)
	                checkForAttributeMapping(refActiveAccounts, newAccountMap, oldAccountMap);
	        }
        }
    }
    
    /**
     * Method to check and create the mapped Attributes
     */
    private static void checkForAttributeMapping(list < Account > accounts, map < Id, Account > newAccountMap, map < Id, Account > oldAccountMap) {
        try {
            Map < String, Schema.SObjectField > fldObjMap = schema.SObjectType.Account.fields.getMap();
            list < Attribute_Mapping__c > attMappings = new list < Attribute_Mapping__c > ();
            for (Attribute_Mapping__c attM: [select Field_Api_Name__c, Auto_populate__c, Auto_add__c, Auto_Update__c, Auto_delete__c
                    from Attribute_Mapping__c where object__c = : ConstantsController.ACCOUNT
                    and Field_Api_Name__c != null and Is_Related_Mapping__c = false
                ]) {
                if (fldObjMap.containsKey(attM.Field_Api_Name__c.tolowerCase())) {
                    attMappings.add(attM);
                }
            }
            map < String, list < Account >> attMappingAccount = new map < String, list < Account >> ();
            set < Id > mappingCreateAttribute = new set < Id > ();
            map < String, set < String >> accountFieldAttDelete = new map < String, set < String >> ();
            list < Account_Attribute__c > deleteAccountAtt = new list < Account_Attribute__c > ();
            list < Account_Attribute__c > createAccountAtt = new list < Account_Attribute__c > ();
            set < Id > attMappingForUpdateAndDelete = new set < Id > ();
            map < Id, map < Id, Account_Attribute__c >> accountAttributesAssociated = new map < Id, map < Id, Account_Attribute__c >> ();
            set < String > preventDuplicacy = new set < String > ();
            set < Id > accAttDeletedIds = new set < Id > ();
            set < Id > accIds = new set < Id > ();
            set < String > deleteAttMapping = new set < String > ();
            //create a map of attributMapping and accounts in which the field value is not null
            if (!attMappings.isEmpty()) {
                for (Account acc: accounts) {
                    accIds.add(acc.Id);
                    for (Attribute_Mapping__c attMapping: attMappings) {
                        if (((oldAccountMap.get(acc.Id).get(attMapping.Field_Api_Name__c) != null && newAccountMap.get(acc.Id).get(attMapping.Field_Api_Name__c) == null) || (newAccountMap.get(acc.Id).get(attMapping.Field_Api_Name__c) != null)) && attMapping.Auto_populate__c) {
                            if (!attMappingAccount.containsKey(attMapping.Id))
                                attMappingAccount.put(attMapping.Id, new list < Account > ());
                            attMappingAccount.get(attMapping.Id).add(acc);
                        }
                        if (attMapping.Auto_add__c || attMapping.Auto_Update__c || attMapping.Auto_delete__c)
                            attMappingForUpdateAndDelete.add(attMapping.Id);
                    }
                    accountAttributesAssociated.put(acc.Id, new map < Id, Account_Attribute__c > ());
                }
                UtilityController.checkAttributeMappingEdit(attMappingForUpdateAndDelete, 'Account');
                //checkAttributeMappingEdit(attMappingForUpdateAndDelete);
                //if the trigger is an update trigger 
                if (oldAccountMap != null) {
                    for (Attribute_Mapping__c attMapping: attMappings) {
                        if (attMappingAccount.get(attMapping.Id) != null) {
                            for (Account acc: attMappingAccount.get(attMapping.Id)) {
                                //if the value is changed then we have to delete the previous value attribute
                                if (oldAccountMap.get(acc.Id).get(attMapping.Field_Api_Name__c) != null && oldAccountMap.get(acc.Id).get(attMapping.Field_Api_Name__c) != newAccountMap.get(acc.Id).get(attMapping.Field_Api_Name__c)) {
                                    if (!accountFieldAttDelete.containsKey(acc.Id))
                                        accountFieldAttDelete.put(acc.Id, new set < String > ());
                                    //this map consists of the acocunt Id and value 
                                    if (oldAccountMap.get(acc.Id).get(attMapping.Field_Api_Name__c) != null) {
                                        for (String att: String.valueOf(oldAccountMap.get(acc.Id).get(attMapping.Field_Api_Name__c)).split(';')) {
                                            boolean attributePresent = false;
                                            if (newAccountMap.get(acc.Id).get(attMapping.Field_Api_Name__c) != null) {
                                                for (string newAtt: string.valueOf(newAccountMap.get(acc.Id).get(attMapping.Field_Api_Name__c)).split(';')) {
                                                    if (newAtt == att)
                                                        attributePresent = true;
                                                }
                                            }
                                            if (!attributePresent)
                                                accountFieldAttDelete.get(acc.Id).add(att);
                                        }
                                    }
                                }
                            }
                        }
                        if (attMappingAccount.get(attMapping.Id) != null && attMappingAccount.get(attMapping.Id).size() == 0)
                            attMappingAccount.remove(attMapping.Id);
                    }
                    //delete the previous field value attributes
                    for (Account_Attribute__c accAtt: [select name, Id, attribute__r.Name, Account__r.Id, Attribute__r.Id, Is_fromMapping__c, Inheritable__c from Account_Attribute__c where Account__c In: accIds and Contact__c = null and Reference_Content__c = null]) {
                        if (accountFieldAttDelete.containsKey(accAtt.Account__r.Id) && accAtt.Is_fromMapping__c) {
                            if (accountFieldAttDelete.get(accAtt.Account__r.Id).contains(accAtt.attribute__r.Name))
                                deleteAccountAtt.add(accAtt);
                            accAttDeletedIds.add(accAtt.Id);
                        }
                        accountAttributesAssociated.get(accAtt.Account__r.Id).put(accAtt.Attribute__r.Id, accAtt);
                    }
                    if (!deleteAccountAtt.isEmpty()) {
                        ConstantsController.attMappingForAccount = false;
                        ConstantsController.attMappingForContact = false;
                        ConstantsController.attMappingForRefContent = false;
                        //delete deleteAccountAtt;
                        WithoutSharingHelperController.deleteAccountAttributes(deleteAccountAtt);
                    }
                }

                //create new field value accountAttributes
                //query all the parent along with child attributes of the mapping
                for (Attribute__c att: [select Id, name, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Auto_populate__c, (Select Id, Name From Attributes__r), Attribute_Mapping__r.Inheritable__c from Attribute__c where Attribute_Mapping__c In: attMappingAccount.keySet() and level__c = 0]) {
                    if (attMappingAccount.get(att.Attribute_Mapping__r.Id) != null && att.Attribute_Mapping__r.Auto_populate__c) {
                        for (Account acc: attMappingAccount.get(att.Attribute_Mapping__r.Id)) {
                            for (Attribute__c childAtt: att.Attributes__r) {
                                if (acc.get(att.Attribute_Mapping__r.Field_Api_Name__c) != null && oldAccountMap.get(acc.Id).get(att.Attribute_Mapping__r.Field_Api_Name__c) != newAccountMap.get(acc.Id).get(att.Attribute_Mapping__r.Field_Api_Name__c)) {
                                    for (String attStr: string.valueOf(acc.get(att.Attribute_Mapping__r.Field_Api_Name__c)).split(';')) {
                                        if (attStr == childAtt.Name && !preventDuplicacy.contains(acc.Id + '' + childAtt.Id) && !accountAttributesAssociated.get(acc.Id).containsKey(childAtt.Id)) {
                                            createAccountAtt.add(new Account_Attribute__c(Account__c = acc.Id, Attribute__c = childAtt.Id, Is_fromMapping__c = true, Inheritable__c = att.Attribute_Mapping__r.Inheritable__c));
                                            preventDuplicacy.add(acc.Id + '' + childAtt.Id);
                                        }
                                        if (accountAttributesAssociated.containsKey(acc.Id) && accountAttributesAssociated.get(acc.Id).containsKey(childAtt.Id) && !accAttDeletedIds.contains(accountAttributesAssociated.get(acc.Id).get(childAtt.Id).Id) && accountAttributesAssociated.get(acc.Id).get(childAtt.Id).Inheritable__c != att.Attribute_Mapping__r.Inheritable__c) {
                                            if (att.Attribute_Mapping__r.Inheritable__c) {
                                                accountAttributesAssociated.get(acc.Id).get(childAtt.Id).Inheritable__c = att.Attribute_Mapping__r.Inheritable__c;
                                                createAccountAtt.add(accountAttributesAssociated.get(acc.Id).get(childAtt.Id));
                                            }

                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if (createAccountAtt.size() > 0) {
                    ConstantsController.attMappingForAccount = false;
                    ConstantsController.attMappingForContact = false;
                    ConstantsController.attMappingForRefContent = false;
                    //upsert createAccountAtt;
                    WithoutSharingHelperController.upsertAccountAttributes(createAccountAtt);
                }
            }
        } catch (Exception e) {
            throw e;
        }
    }
    
}