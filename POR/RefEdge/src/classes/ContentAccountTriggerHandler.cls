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
public with sharing class ContentAccountTriggerHandler {
	/**
     * Properties and variables
     */
    public static list < Account_Reference_Content__c > newRefContents;
    public static list < Account_Reference_Content__c > oldRefContents;
    public static map < Id, Account_Reference_Content__c > newRefContentMap;
    public static map < Id, Account_Reference_Content__c > oldRefContentMap;
	/**
     * Method called on before insert of Account Reference Content
     */
    public static void onBeforeInsert() {
        map < String, decimal > accountContentCountMap = new Map < String, Decimal > ();
        for (Account_Reference_Content__c tempObj: [select Account__c, Reference_Content__c from Account_Reference_Content__c LIMIT: limits.getLimitQueryRows()]) {
            accountContentCountMap.put(tempObj.Account__c + '' + tempObj.Reference_Content__c, 0);
        }
        for (Account_Reference_Content__c tempObj: newRefContents) {
            if (accountContentCountMap.containsKey(tempObj.Account__c + '' + tempObj.Reference_Content__c)) {
                tempObj.addError(System.Label.Junction_already_exists);
            }
        }
    }
	/**
     * Method called on after insert of Account Reference Content
     */
    public static void onAfterInsert() {
        set < Id > accountIds = new set < Id > ();
        set < Id > refContentIds = new set < Id > ();
        map < Id, set < Id >> accountContentMap = new map < Id, set < Id >> ();
        map < Id, set < Id >> referAccIds = new map < Id, set < Id >> ();
        for (Account_Reference_Content__c tempObj: newRefContents) {
            accountIds.add(tempObj.Account__c);
            refContentIds.add(tempObj.Reference_Content__c);
            if (!accountContentMap.containskey(tempObj.Account__c))
                accountContentMap.put(tempObj.Account__c, new set < Id > ());
            accountContentMap.get(tempObj.Account__c).add(tempObj.Reference_Content__c);
            if (!referAccIds.containsKey(tempObj.Reference_Content__c))
                referAccIds.put(tempObj.Reference_Content__c, new set < Id > ());
            referAccIds.get(tempObj.Reference_Content__c).add(tempObj.Account__c);
        }
        addAttributesFromAccount(accountContentMap);
        addAttributesToAccount(accountIds, refContentIds, referAccIds);
        updateReferenceContents(refContentIds);
    }
	/**
     * Method called on after delete of Account Reference Content
     */
    public static void onAfterDelete() {
        set < Id > accountIds = new set < Id > ();
        set < Id > refContentIds = new set < Id > ();
        for (Account_Reference_Content__c tempObj: oldRefContents) {
            accountIds.add(tempObj.Account__c);
            refContentIds.add(tempObj.Reference_Content__c);
        }
        removeAttributesOfAccount(accountIds, refContentIds);
        removeAttributesFromAccount(accountIds, refContentIds);
        updateReferenceContents(refContentIds);
    }
	/**
     * Method called on after undelete of Account Reference Content
     */
    public static void onAfterUndelete() {
        set < Id > refContentIds = new set < Id > ();
        map < String, decimal > accountContentCountMap = new Map < String, Decimal > ();
        for (Account_Reference_Content__c tempObj: [select Account__c, Reference_Content__c from Account_Reference_Content__c where Id not In: newRefContents]) {
            accountContentCountMap.put(tempObj.Account__c + '' + tempObj.Reference_Content__c, 0);
        }
        for (Account_Reference_Content__c tempObj: newRefContents) {
            if (accountContentCountMap.containsKey(tempObj.Account__c + '' + tempObj.Reference_Content__c)) {
                tempObj.addError(System.Label.Junction_already_exists);
            }
            refContentIds.add(tempObj.Reference_Content__c);
        }
        updateReferenceContents(refContentIds);
    }
	/**
     * Method to add Attributes from Account
     */
    static void addAttributesFromAccount(map < Id, set < Id >> accountContentMap) {

        list < Content_Attribute__c > newContentAttrib = new list < Content_Attribute__c > ();
        map < Id, set < Id >> contentAttribMap = new map < Id, set < Id >> ();
        Content_Attribute__c tempContentObj;
        for (Id accId: accountContentMap.keySet()) {
            for (Id RefId: accountContentMap.get(accId)) {
                contentAttribMap.put(RefId, new Set < Id > ());
            }
        }
        for (Content_Attribute__c tempObj: [Select Reference_Content__c, Attribute__c From Content_Attribute__c where Reference_Content__c In: contentAttribMap.keySet()]) {
            contentAttribMap.get(tempObj.Reference_Content__c).add(tempObj.Attribute__c);
        }
        for (Account_Attribute__c tempObj: WithoutSharingHelperController.getAccountAttributesInRefCon(accountContentMap.keySet())) {
            if (accountContentMap.get(tempObj.Account__c) != null) {
                for (Id contentId: accountContentMap.get(tempObj.Account__c)) {
                    if (contentAttribMap.get(contentId) != null && !contentAttribMap.get(contentId).contains(tempObj.Attribute__c)) {
                        tempContentObj = new Content_Attribute__c();
                        tempContentObj.Reference_Content__c = contentId;
                        tempContentObj.Attribute__c = tempObj.Attribute__c;
                        tempContentObj.Account__c = tempObj.Account__c;
                        newContentAttrib.add(tempContentObj);
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
     * Method to add Attribute to Account
     */
    static void addAttributesToAccount(set < Id > accIds, set < Id > referIds, map < Id, set < Id >> referAccIds) {
        map < Id, set < Id >> accAttribIds = new map < Id, set < Id >> ();
        map < Id, Set < Id >> referAttribIds = new map < Id, Set < Id >> ();
        set < String > preventDuplicacy = new set < String > ();
        list < Account_Attribute__c > newAccAtt = new list < Account_Attribute__c > ();
        Account_Attribute__c tempObj;
        map < Id, Reference_Basic_Information__c > accountRBI = new map < Id, Reference_Basic_Information__c > ();
        for (Id accId: accIds) {
            if (!accAttribIds.containsKey(accId))
                accAttribIds.put(accId, new set < Id > ());
        }
        for (Reference_Content__c refObj: [select Id from Reference_Content__c where Id In: referIds and(Content_Status__c = : ConstantsController.ACTIVE or Content_Status__c = : ConstantsController.CAUTION)]) {
            if (!referAttribIds.containsKey(refObj.Id)) {
                referAttribIds.put(refObj.Id, new set < Id > ());
            }
        }
        for (Content_Attribute__c cA: [select Reference_Content__c, Attribute__c from Content_Attribute__c where Reference_Content__c In: referAttribIds.keySet() and Account__c = null]) {
            referAttribIds.get(cA.Reference_Content__c).add(cA.Attribute__c);
        }
        for (Account acc: WithoutSharingHelperController.getAccountInRefCon(accIds, referAttribIds.keySet())) {
            for (Account_Attribute__c tempObj1: acc.Account_Attributes__r) {
                accAttribIds.get(tempObj1.Account__c).add(tempObj1.Attribute__c);
            }
            if (acc.Reference_Basic_Informations__r.size() > 0)
                accountRBI.put(acc.Id, acc.Reference_Basic_Informations__r[0]);
        }
        for (Id referId: referAttribIds.keySet()) {
            if (referAttribIds.get(referId) != null) {
                for (Id AttId: referAttribIds.get(referId)) {
                    for (Id accId: referAccIds.get(referId)) {
                        if (accountRBI.containsKey(accId) && accountRBI.get(accId).Is_Referenceable__c && accAttribIds.get(accId) != null && !accAttribIds.get(accId).contains(AttId) && !preventDuplicacy.contains(referId + ',' + accId + ',' + attId)) {
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

    /**
     * Method to remove the attributes which were added from this Account on the corresponding ref content
     */
    static void removeAttributesOfAccount(set < Id > accountIds, set < Id > referContentIds) {
        map < Id, set < Id >> accountAttribMap = new map < Id, set < Id >> ();
        list < Content_Attribute__c > contentsToBeDelete = new list < Content_Attribute__c > ();
        map < Id, list < Content_Attribute__c >> referContentAttributeMap = new map < Id, list < Content_Attribute__c >> ();
        for (Id accId: accountIds) {
            accountAttribMap.put(accId, new set < Id > ());
        }
        for (Content_Attribute__c tempObj: [select Reference_Content__c, Attribute__c from Content_Attribute__c where Reference_Content__c In: referContentIds and Account__c in : accountIds]) {
            contentsToBeDelete.add(tempObj);
        }
        if (contentsToBeDelete.size() > 0) {
            ConstantsController.shouldAttributesOfContentDelete = true;
            WithoutSharingHelperController.deleteContentAtt(contentsToBeDelete);
        }
    }
	/**
     * Method to remove Attributes from Account
     */
    static void removeAttributesFromAccount(set < Id > accountIds, set < Id > refContentIds) {
        
        if (!ConstantsController.isCallFromBatchRemoveDuplicateRBI) {
            list < Account_Attribute__c > deleteAccAttrib = new list < Account_Attribute__c > ();
            for (Account_Attribute__c tempObj: WithoutSharingHelperController.getAccountAttributesInRefConTodelete(accountIds, refContentIds)) {
                deleteAccAttrib.add(tempObj);
            }
            if (deleteAccAttrib.size() > 0) {
                ConstantsController.shouldAccountAttributeDeleteOfContent = true;
                WithoutSharingHelperController.deleteAccountAttributes(deleteAccAttrib);
            }
        } 
    }


    /**
     * Update on : 25 March 2015
     * Method to Update reference content
     * R11.118 - MOD - Reference Content - Add Associated Accounts text field 
     */
    static void updateReferenceContents(set < Id > refContentIds) {
        list < Reference_Content__c > updateReferenceContent = new list < Reference_Content__c > ();
        for (Reference_Content__c rc: WithoutSharingHelperController.getReferenceContent(refContentIds)) {
            string associatedAccount = '';
            for (Account_Reference_Content__c aa: rc.Account_Reference_Contents__r) {
                associatedAccount += (associatedAccount == '' ? aa.Account__r.Name : ', ' + aa.Account__r.Name);
            }
            rc.Associated_Accounts__c = associatedAccount;
            updateReferenceContent.add(rc);
        }
        if (updateReferenceContent.size() > 0)
            update updateReferenceContent;
    }
}