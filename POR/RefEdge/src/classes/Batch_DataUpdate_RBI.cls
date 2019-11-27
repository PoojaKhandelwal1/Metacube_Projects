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
 * Class: RefedgeSetupHomeController
 * Description : This Batch called FROM RefedgeSetupHomeController to update Reference Profile (Attributes, Referenceability)
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_DataUpdate_RBI implements Database.Batchable<sObject>, Database.stateful {
    /**
     * Properties and variables
     */
    private String soqlQuery = '';
    private Set<Id> rbiIds;
    private Set<String> accountIds;
    private Set<String> attToCreate;
    private Set<String> refToCreate;
    private String accountId;
    private String contactId;
    private boolean isMakeAccountMember;
    private boolean copyExistingAtt;
    /**
     * Constructor
     */
    global Batch_DataUpdate_RBI() {
        rbiIds = new Set<Id>();
        soqlQuery = 'SELECT Account__r.OwnerId, Reference_Owner__c, Profile_Update_Owner__c, Account__c, Account__r.Name, Contact__c, Attribute_Ids__c, ' 
        			+ 'Label_Ids1__c, Label_Ids2__c, ReferenceabilityType_Ids1__c, ReferenceabilityType_Ids2__c, Attributes__c, Parent_Attributes__c ' 
        			+ 'FROM Reference_Basic_Information__c WHERE Generic_Account__c = false ';
    }
    /**
     * Constructor
     */
    public Batch_DataUpdate_RBI(Set<Id> rbiIds, String accountId, String contactId, boolean isMakeAccountMember, Set<String> accIds, 
    										Set<String> atttocreate, Set<String> reftocreate, boolean copyExistingAtt) {
        this.rbiIds = rbiIds;
        this.accountId = accountId;
        this.contactId = contactId;
        this.attToCreate = attToCreate;
        this.refToCreate = refToCreate;
        this.copyExistingAtt = copyExistingAtt;
        this.accountIds = accIds;
        this.isMakeAccountMember = isMakeAccountMember;
        soqlQuery = 'SELECT Account__r.OwnerId, Reference_Owner__c, Profile_Update_Owner__c, Account__c, Account__r.Name, Contact__c, Attribute_Ids__c, ' 
        			+ 'Label_Ids1__c, Label_Ids2__c, ReferenceabilityType_Ids1__c, ReferenceabilityType_Ids2__c, Attributes__c, Parent_Attributes__c ' 
        			+ 'FROM Reference_Basic_Information__c WHERE Generic_Account__c = false AND Id IN :rbiIds';
    }
    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(soqlQuery);
    }

    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List<Reference_Basic_Information__c > scope) {
        Set<Id> rbiSet = new Set<Id>();
        
        if (rbiIds.size() > 0) {
            rbiSet = createData();
        }
        
        for (Reference_Basic_Information__c ref : scope) {
            
            if (rbiSet.contains(ref.Id)) {
                rbiSet.remove(ref.Id);
            }
        }
        
        if (rbiSet.size() > 0) {
            
            for (Reference_Basic_Information__c rbi : [SELECT Account__r.OwnerId, Reference_Owner__c, Profile_Update_Owner__c, Account__c, Account__r.Name,
                    Contact__c, Attribute_Ids__c, Label_Ids1__c, Label_Ids2__c, ReferenceabilityType_Ids1__c, ReferenceabilityType_Ids2__c,
                    Attributes__c, Parent_Attributes__c FROM Reference_Basic_Information__c WHERE Generic_Account__c = false AND Id IN :rbiSet]) {
                scope.add(rbi);
            }
        }
        Set<String> attIds = new Set<String>();
        Map<String, String> labelIds = new Map<String, String>();
        Map<String, Set<String>> attLabel = new Map<String, Set<String >>();
        Map<String, String> attLabelName = new Map<String, String>();
        Map<Id, List<Account_Attribute__c>> accountAttrib = new Map<Id, List<Account_Attribute__c>>();
        Map<Id, Reference_Basic_Information__c> accounts = new Map<Id, Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> contacts = new Map<Id, Reference_Basic_Information__c>();
        Map<Id, List<Referenceability__c>> accountReference = new Map<Id, List<Referenceability__c>>();
        Map<Id, List<Referenceability__c>> contactReference = new Map<Id, List<Referenceability__c>>();
        List<Reference_Basic_Information__c> updateRBI = new List<Reference_Basic_Information__c>();
        
        for (Reference_Basic_Information__c ref : scope) {
            
            if (ref.Account__c != null && ref.Contact__c == null) {
                accounts.put(ref.Account__c, ref);
            } else if (ref.Account__c != null && ref.Contact__c != null) {
                contacts.put(ref.Contact__c, ref);
            }
        }
        Map<String, Reference_Basic_Information__c> mapAccountContacts = new Map<String, Reference_Basic_Information__c>();
        
        for (Reference_Basic_Information__c rbi : [SELECT Contact__c, Referenceability_Status__c FROM Reference_Basic_Information__c 
								        		WHERE Generic_Account__c = false AND Account__c IN :accounts.keySet() AND Contact__c != null]) {
            mapAccountContacts.put(rbi.Contact__c, rbi);
        }

        for (Id accid : accounts.keySet()) {
            accountReference.put(accid, new List<Referenceability__c>());
        }
        
        for (Id accid : contacts.keySet()) {
            contactReference.put(accid, new List<Referenceability__c>());
        }

        for (Referenceability__c ref : [SELECT Id, Account__c, Contact__c, Referenceability_Type__r.Referenceability_no__c, Referenceability_Type__r.Name,
                						Status__c FROM Referenceability__c WHERE Contact__c IN :contacts.keySet()]) {
            
            if (ref.Status__c == ConstantsController.APPROVED) {
                contactReference.get(ref.Contact__c).add(ref);
            }
        }
        
        for (Id conId : contactReference.keySet()) {
            String referenceabilities = '';
            String referenceabilityIds1 = '';
            String referenceabilityIds2 = '';
            Set<String> removeDuplicateReferenceability = new Set<String>();
            
            for (Referenceability__c ref : contactReference.get(conId)) {
                String refNo = (ref.Referenceability_Type__r.Referenceability_no__c != null ? 'R' 
                				+ String.valueOf(ref.Referenceability_Type__r.Referenceability_no__c) + 'R' : '');
                
                if (referenceabilities == '') {
                    referenceabilities = ref.Referenceability_Type__r.Name;
                    referenceabilityIds1 = refNo;
                    removeDuplicateReferenceability.add(refNo);
                } else {
                    
                    if (!removeDuplicateReferenceability.contains(refNo)) {
                        referenceabilities = referenceabilities + ', ' + ref.Referenceability_Type__r.Name;
                        
                        if (referenceabilityIds1.length() < 250 && refNo.length() < 5) {
                            referenceabilityIds1 = referenceabilityIds1 + ',' + refNo;
                        } else {
                            
                            if (referenceabilityIds2 == '') {
                                referenceabilityIds2 = refNo;
                            } else if (referenceabilityIds2.length() < 250 && refNo.length() < 5) {
                                referenceabilityIds2 = referenceabilityIds2 + ',' + refNo;
                            }
                        }
                        removeDuplicateReferenceability.add(refNo);
                    }
                }
            }
            contacts.get(conId).Referenceability__c = referenceabilities;
            contacts.get(conId).ReferenceabilityType_Ids1__c = referenceabilityIds1;
            contacts.get(conId).ReferenceabilityType_Ids2__c = referenceabilityIds2;
            updateRBI.add(contacts.get(conId));
        }

        for (Referenceability__c ref : [SELECT Id, Account__c, Contact__c, Referenceability_Type__r.Referenceability_no__c, Referenceability_Type__r.Name,
                						Status__c FROM Referenceability__c WHERE Account__c IN :accounts.keySet()]) {
            
            if (ref.Status__c == ConstantsController.APPROVED) {
                accountReference.get(ref.Account__c).add(ref);
            }
        }
        
        for (Id accntId : accountReference.keySet()) {
            String referenceabilities = '';
            String referenceabilityIds1 = '';
            String referenceabilityIds2 = '';
            Set<String> removeDuplicateReferenceability = new Set<String>();
            
            for (Referenceability__c ref : accountReference.get(accntId)) {
                String refNo = (ref.Referenceability_Type__r.Referenceability_no__c != null ? 'R' 
                					+ String.valueOf(ref.Referenceability_Type__r.Referenceability_no__c) + 'R' : '');
                
                if (referenceabilities == '') {
                    referenceabilities = ref.Referenceability_Type__r.Name;
                    referenceabilityIds1 = refNo;
                    removeDuplicateReferenceability.add(refNo);
                } else {
                    
                    if (!removeDuplicateReferenceability.contains(refNo)) {
                        referenceabilities = referenceabilities + ', ' + ref.Referenceability_Type__r.Name;
                        
                        if (referenceabilityIds1.length() < 250 && refNo.length() < 5) {
                            referenceabilityIds1 = referenceabilityIds1 + ',' + refNo;
                        } else {
                            
                            if (referenceabilityIds2 == '') {
                                referenceabilityIds2 = refNo;
                            } else if (referenceabilityIds2.length() < 250 && refNo.length() < 5) {
                                referenceabilityIds2 = referenceabilityIds2 + ',' + refNo;
                            }
                        }
                        removeDuplicateReferenceability.add(refNo);
                    }
                }
            }
            accounts.get(accntId).Referenceability__c = referenceabilities;
            accounts.get(accntId).ReferenceabilityType_Ids1__c = referenceabilityIds1;
            accounts.get(accntId).ReferenceabilityType_Ids2__c = referenceabilityIds2;
            updateRBI.add(accounts.get(accntId));
        }
        
        if (updateRBI.size() > 0) {
            upsert updateRBI;
        }
        updateRBI.clear();
        
        for (Account_Attribute__c a : [SELECT Account__c, Reference_Basic_Information__c, Attribute__r.Name FROM Account_Attribute__c 
        										WHERE Account__c IN :accounts.keySet()]) {
            
            if (!accountAttrib.containsKey(a.Account__c)) {
                accountAttrib.put(a.Account__c, new List<Account_Attribute__c>());
            }
            accountAttrib.get(a.Account__c).add(a);
            attIds.add(a.Attribute__c);
        }
        Map<Id, List<Contact_Attribute__c>> ContactAttrib = new Map<Id, List<Contact_Attribute__c>>();
        
        for (Contact_Attribute__c a : [SELECT Contact__c, Reference_Basic_Information__c, Attribute__r.Name FROM Contact_Attribute__c 
        								WHERE Contact__c IN :contacts.keySet()]) {
            
            if (!ContactAttrib.containsKey(a.Contact__c)) {
                ContactAttrib.put(a.Contact__c, new List<Contact_Attribute__c>());
            }
            ContactAttrib.get(a.Contact__c).add(a);
            attIds.add(a.Attribute__c);
        }
        
        for (Attributes_Labels__c attL : [SELECT Attribute__c, Attribute__r.Root_Parent__c, Label__c, Label__r.Filter_no__c, Label__r.Name 
        								FROM Attributes_Labels__c WHERE Attribute__c IN :attIds]) {
            
            if (!attLabel.containsKey(attL.Attribute__c)) {
                attLabel.put(attL.Attribute__c, new Set<String>());
            }
            attLabel.get(attL.Attribute__c).add('F' + String.valueOf(attL.Label__r.Filter_no__c) + 'F');
            attLabelName.put(attL.Attribute__c, (attL.Attribute__r.Root_Parent__c != null ? attL.Attribute__r.Root_Parent__c : ''));
        }
        List<Account_Attribute__c> accountAttributes = new List<Account_Attribute__c>();
        
        for (Id accuntId : accountAttrib.keySet()) {
            
            for (Account_Attribute__c a : accountAttrib.get(accuntId)) {
                
                /*
                 * for --> ReferenceEdge Attribute, Mapped Attribute Reporting question
                 * set Reference_Basic_Information__c in Account Attribute
                 * by Rekha
                 */
                if (a.Reference_Basic_Information__c == null) {
                    a.Reference_Basic_Information__c = accounts.get(accuntId).Id;
                    accountAttributes.add(a);
                }
                //end
            }
            Reference_Basic_Information__c rbi = UtilityController.setFiltersForAccount(accounts.get(accuntId), 
            										accountAttrib.get(accuntId), attLabel, attLabelName);
            updateRBI.add(rbi);

        }
        List<Contact_Attribute__c> contactAttributes = new List<Contact_Attribute__c>();
        
        for (Id ContactId : ContactAttrib.keySet()) {
            
            for (Contact_Attribute__c a : ContactAttrib.get(ContactId)) {
                
                /*
                 * for --> ReferenceEdge Attribute, Mapped Attribute Reporting question
                 * set Reference_Basic_Information__c in Account Attribute
                 * by Rekha
                 */
                if (a.Reference_Basic_Information__c == null) {
                    a.Reference_Basic_Information__c = contacts.get(ContactId).Id;
                    contactAttributes.add(a);
                }
                //end
            }
            Reference_Basic_Information__c rbi = UtilityController.setFiltersForContact(contacts.get(ContactId), 
            										ContactAttrib.get(ContactId), attLabel, attLabelName);
            updateRBI.add(rbi);
        }
        
        if (accountAttributes.size() > 0) {
            ConstantsController.stopAccAttributeTrigger = true;
            update accountAttributes;
            ConstantsController.stopAccAttributeTrigger = false;
        }
        
        if (contactAttributes.size() > 0) {
            ConstantsController.stopConAttributeTrigger = true;
            update contactAttributes;
            ConstantsController.stopConAttributeTrigger = false;
        }
        
        if (updateRBI.size() > 0) {
            upsert updateRBI;
        }
    }
    
    /**
     * Method to create data FROM Copy Nomination page
     */
    private Set<Id> createData() {
        //Shared Contact start
        Set<String> sharedContactIds = new Set<String>();
        Set<String> sharedAccountIds = new Set<String>();
        Contact contact = new Contact();
        Account account = new Account();
        Set<Id> rbiSet = new Set<Id>();
        String parentAccountId = accountId;
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        boolean addAttributeToAllAccounts = cs.Roll_up_Attributes_to_All_Accounts__c;
        boolean inheritAttributefromAllAccounts = cs.Inherit_Attributes_from_All_Accounts__c;
        boolean addRefToAllAccounts = cs.Roll_up_Referenceability_to_All_Accounts__c;
        Map<Id, Reference_Basic_Information__c> contactsMap = new Map<Id, Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> accountsMap = new Map<Id, Reference_Basic_Information__c>();
        
        if (cs.Shared_Contacts__c) {
            String objectName = cs.Shared_Contact_Object__c;
            String accountField = cs.Shared_Account_Field__c;
            String contactField = cs.Shared_Contact_Field__c;
            
            if (accountField != null && accountField != '' && contactField != null && contactField != '') {
                String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName;
                
                if ((contactId == null || contactId == '') && accountId != null && accountId != '') {
                    query += ' WHERE ' + accountField + ' =\'' + accountId + '\'';
                }
                    
                if (query.contains('WHERE')) {
                    List<sObject> objectList = Database.query(query);
                    
                    if (objectList != null && objectList.size() > 0) {
                    	
                        for (sObject obj : objectList) {
                        	
                            if ((Id) obj.get(accountField) == (Id) accountId) {
                                sharedContactIds.add((Id) obj.get(contactField));
                            }
                        }
                    }
                }
            }
            
            if (contactId != null && contactId != '' && accountIds.size() > 0) {
                sharedContactIds.add(contactId);
                
                if (accountIds.size() > 0) {
                    sharedAccountIds = new Set<String>();
                    sharedAccountIds.addAll(accountIds);
                }
                List<Reference_Basic_Information__c> upsertRBI = new List<Reference_Basic_Information__c>();
                Map<Id, Reference_Basic_Information__c> accMap = new Map<Id, Reference_Basic_Information__c>();
                
                for (Reference_Basic_Information__c rbi : [SELECT Id, Account__c, Is_Referenceable__c, Reference_Program_Candidate__c,
                        				Referenceability_Status__c FROM Reference_Basic_Information__c WHERE Generic_Account__c = false 
                        				AND Account__c IN :accountIds and Contact__c = null]) {
                    accMap.put(rbi.Account__c, rbi);
                }
                
                for (String accId : accountIds) {
                	
                    if (accMap.containsKey(accId) && accMap.get(accId) != null) {
                    	
                        if (!accMap.get(accId).Is_Referenceable__c) {
                            accMap.get(accId).Is_Referenceable__c = true;
                            accMap.get(accId).Reference_Program_Candidate__c = false;
                            accMap.get(accId).Referenceability_Status__c = 'Active';
                            upsertRBI.add(accMap.get(accId));
                        } else {
                            upsertRBI.add(accMap.get(accId));
                        }
                    } else {
                        upsertRBI.add(new Reference_Basic_Information__c(Account__c = accId, Referenceability_Status__c = 'Active', Is_Referenceable__c = true));
                    }
                }
                
                if (upsertRBI.size() > 0) {
                    ConstantsController.contactId = contactId;
                    ConstantsController.copyExistingAtt = copyExistingAtt;
                    ConstantsController.attributeIdsinCopyNomi = attToCreate;
                    ConstantsController.refIdsinCopyNomi = refToCreate;
                    upsert upsertRBI;
                    
                    for (Reference_Basic_Information__c rbi : upsertRBI) {
                        rbiSet.add(rbi.Id);
                    }
                }
            }
        }
        
        if ((contactId == null || contactId == '') || !cs.Shared_Contacts__c) {
            sharedAccountIds.add(accountId);
        }
        List<Account> allaccounts = new List<Account>();
        List<Contact> allContacts = new List<Contact>();
        Map<Id, Set<String>> accountAttributeMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> contactAttributMap = new Map<Id, Set<String>>();
        Map<Id, Set<Id>> inheritableaccountAttributeMap = new Map<Id, Set<Id>>();
        
        for (Contact con : WithoutSharingHelperController.getContactInRBI1SharedContactfromBatch(accountId, sharedContactIds)) {
        	
            if (con.Reference_Basic_Informations__r.size() > 0) {
                rbiSet.add(con.Reference_Basic_Informations__r[0].Id);
            }
            contactsMap.put(con.Id, (con.Reference_Basic_Informations__r.size() > 0 ? con.Reference_Basic_Informations__r[0] 
            							: new Reference_Basic_Information__c()));
            
            if (con.Id == (Id) contactId) {
                contact = con;
            } else {
                allContacts.add(con);
            }
            
            for (Contact_Attribute__c cA : con.Contact_Attributes__r) {
                
                if (cA.from_Account__c) {
                    
                    if (!contactAttributMap.containsKey(cA.Contact__c)) {
                        contactAttributMap.put(cA.Contact__c, new Set<String>());
                    }
                    contactAttributMap.get(cA.Contact__c).add(cA.Attribute__c + '+' + cA.Account__c);
                }
            }
        }
        
        for (Account acc : WithoutSharingHelperController.getAccountRecordsWithAllRelatedRecords(sharedAccountIds)) {
            
            if (acc.Reference_Basic_Informations__r.size() > 0) {
                rbiSet.add(acc.Reference_Basic_Informations__r[0].Id);
            }
            accountsMap.put(acc.Id, (acc.Reference_Basic_Informations__r.size() > 0 ? acc.Reference_Basic_Informations__r[0] 
            							: new Reference_Basic_Information__c()));
            
            if (acc.Id == (Id) accountId) {
                account = acc;
            } else {
                allaccounts.add(acc);
            }
            
            for (Account_Attribute__c accAtt : acc.Account_Attributes__r) {
                
                if (accAtt.Contact__c != null) {
                    
                    if (!accountAttributeMap.containsKey(accAtt.Account__c)) {
                        accountAttributeMap.put(accAtt.Account__c, new Set<String>());
                    }
                    accountAttributeMap.get(accAtt.Account__c).add(accAtt.Attribute__c + '+' + accAtt.Contact__c);
                }
                
                if (accAtt.Reference_Content__c == null && accAtt.Contact__c == null && accAtt.Inheritable__c) {
                    
                    if (!inheritableaccountAttributeMap.containsKey(accAtt.Account__c)) {
                        inheritableaccountAttributeMap.put(accAtt.Account__c, new Set<Id>());
                    }
                    inheritableaccountAttributeMap.get(accAtt.Account__c).add(accAtt.Attribute__c);
                }
            }
        }
        Set<String> oppAttributes = new Set<String>();
        
        for (Attribute__c att : [SELECT Id, (SELECT Id FROM Attributes__r) FROM Attribute__c 
				        		WHERE Attribute_Mapping__r.Object__c = :ConstantsController.OPPORTUNITY 
				                AND Attribute_Mapping__r.Field_Api_Name__c = 'StageName']) {
            
            for (Attribute__c childAtt : att.Attributes__r) {
                oppAttributes.add(childAtt.Id);
            }
        }
        List<Referenceability__c> listReferenceability = new List<Referenceability__c>();
        List<Account_Attribute__c> newAccountAttribute = new List<Account_Attribute__c>();
        List<Contact_Attribute__c> newContactAttributes = new List<Contact_Attribute__c>();
        List<Content_Attribute__c> newContentAttrib = new List<Content_Attribute__c>();
        
        if (contactId != null && contactId != '') {
            Reference_Basic_Information__c conRbi = (contact.Reference_Basic_Informations__r.size() > 0 ? contact.Reference_Basic_Informations__r[0] :
                									new Reference_Basic_Information__c());
            boolean addRefToAllAccountsRBI = (conRbi.Roll_up_Referenceability_to_All_Accounts__c ? true : (conRbi.Roll_up_Referenceability_to_Primary_Acc__c ?
                									false : (addRefToAllAccounts)));
            boolean addAttToAllAccountsRBI = (conRbi.Roll_up_Attributes_to_All_Accounts__c ? true : (conRbi.Roll_up_Attributes_to_All_Accounts__c ?
                									false : (addAttributeToAllAccounts)));
            boolean addAttFromAllAccountsRBI = (conRbi.Inherit_Attributes_from_All_Accounts__c ? true : (conRbi.Inherit_Attributes_from_All_Accounts__c ?
                									false : (inheritAttributefromAllAccounts)));
            
            if (conRbi.Is_Referenceable__c) {
                
                if ((conRbi.Referenceability_Status__c == ConstantsController.ACTIVE || conRbi.Referenceability_Status__c == ConstantsController.CAUTION)) {
                    //roll up referenceability to all accounts when contact is updated in nomination
                    Set<String> duplicaterefIds = new Set<String>();
                    
                    for (Referenceability__c ref : contact.Referenceabilities__r) {
                        
                        if (ref.Account__c != null) {
                            duplicaterefIds.add(ref.Referenceability_Type__c + '+' + ref.Account__c);
                        }
                    }
                    
                    for (Id accId : sharedAccountIds) {
                        
                        for (Referenceability__c ref : contact.Referenceabilities__r) {
                            
                            if (copyExistingAtt || (!copyExistingAtt && refToCreate.contains(ref.Referenceability_Type__c))) {
                            
                                if (!duplicaterefIds.contains(ref.Referenceability_Type__c + '+' + accId)) {
                            
                                    if (accountsMap.containsKey(accId) && (accountsMap.get(accId).Is_Referenceable__c 
                                    				|| accountsMap.get(accId).Reference_Program_Candidate__c)) {
                            
                                        if (ref.Account__c == null) {
                                            ref.Account__c = accId;
                                            listReferenceability.add(ref);
                                            duplicaterefIds.add(ref.Referenceability_Type__c + '+' + accId);
                                        } else {
                                            duplicaterefIds.add(ref.Referenceability_Type__c + '+' + accId);
                                            listReferenceability.add(new Referenceability__c(Account__c = accId, Contact__c = ref.Contact__c,
                                                Referenceability_Type__c = ref.Referenceability_Type__c, Comment__c = ref.Comment__c,
                                                Verified__c = ref.Verified__c, Status__c = ref.Status__c));
                                        }
                                    }
                                }
                            }
                        }
                    }
                    //roll up attributes to all accounts when contact is updated in nomination
                    Set<String> preventDuplicacy = new Set<String>();
                    
                    for (Id accId : sharedAccountIds) {

                        for (Contact_Attribute__c cA : contact.Contact_Attributes__r) {

                            if (copyExistingAtt || (!copyExistingAtt && attToCreate.contains(cA.Attribute__c))) {

                                if (!cA.from_Account__c && accountsMap.containsKey(accId) && (accountsMap.get(accId).Is_Referenceable__c)) {

                                    if (!oppAttributes.contains(cA.Attribute__c) && accountAttributeMap.get(accId) != null && !accountAttributeMap.get(
                                            accId).contains(cA.Attribute__c + '+' + cA.Contact__c) && !preventDuplicacy.contains(accId + '' + contactId +
                                            '' + cA.Attribute__c)) {
                                        Account_Attribute__c tempObj = new Account_Attribute__c();
                                        tempObj.Account__c = accId;
                                        tempObj.Attribute__c = cA.Attribute__c;
                                        tempObj.Contact__c = contactId;
                                        newAccountAttribute.add(tempObj);
                                        preventDuplicacy.add(accId + '' + contactId + '' + cA.Attribute__c);
                                    } else if (!oppAttributes.contains(cA.Attribute__c) && accountAttributeMap.get(accId) == null) {
                                        Account_Attribute__c tempObj = new Account_Attribute__c();
                                        tempObj.Account__c = accId;
                                        tempObj.Attribute__c = cA.Attribute__c;
                                        tempObj.Contact__c = contactId;
                                        preventDuplicacy.add(accId + '' + contactId + '' + cA.Attribute__c);
                                        newAccountAttribute.add(tempObj);
                                    }
                                }
                            }
                        }
                    }
                }
                //inherit attributes FROM all account to contact which is updated
                Set<String> duplicateConAttIds = new Set<String>();
       
                for (Id accId : sharedAccountIds) {
       
                    if (addAttFromAllAccountsRBI || accId == parentAccountId) {
       
                        if (inheritableaccountAttributeMap != null && inheritableaccountAttributeMap.containsKey(accId) && accountsMap.containsKey(
                                accId) && accountsMap.get(accId).Is_Referenceable__c) {
       
                            for (Id attId : inheritableaccountAttributeMap.get(accId)) {
       
                                if (!duplicateConAttIds.contains(attId + '+' + accId) && contactAttributMap != null && contactAttributMap.containsKey(
                                        contactId) && !contactAttributMap.get(contactId).contains(attId + '+' + accId)) {
                                    Contact_Attribute__c tempObj = new Contact_Attribute__c();
                                    tempObj.Attribute__c = attId;
                                    tempobj.Contact__c = contactId;
                                    tempObj.From_Account__c = true;
                                    tempobj.Account__c = accId;
                                    duplicateConAttIds.add(attId + '+' + accId);
                                    newContactAttributes.add(tempObj);
                                } else if (!duplicateConAttIds.contains(attId + '+' + accId) && contactAttributMap != null && contactAttributMap.get(
                                        contactId) == null) {
                                    Contact_Attribute__c tempObj = new Contact_Attribute__c();
                                    tempObj.Attribute__c = attId;
                                    tempobj.Contact__c = contactId;
                                    tempObj.From_Account__c = true;
                                    tempobj.Account__c = accId;
                                    duplicateConAttIds.add(attId + '+' + accId);
                                    newContactAttributes.add(tempObj);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if (isMakeAccountMember) {
            Set<String> duplicaterefIds = new Set<String>();
        
            for (Referenceability__c ref : account.Referenceabilities__r) {
        
                if (ref.Contact__c != null) {
                    duplicaterefIds.add(ref.Referenceability_Type__c + '+' + ref.Contact__c);
                }
            }
        
            for (Contact con : allContacts) {
                boolean addRefToAllAccountsRBI = (contactsMap.get(con.Id).Roll_up_Referenceability_to_All_Accounts__c ? true : 
                					(contactsMap.get(con.Id).Roll_up_Referenceability_to_Primary_Acc__c ? false : (addRefToAllAccounts)));
                boolean addAttToAllAccountsRBI = (contactsMap.get(con.Id).Roll_up_Attributes_to_All_Accounts__c ? true : 
                					(contactsMap.get(con.Id).Roll_up_Attributes_to_All_Accounts__c ?
                    				false : (addAttributeToAllAccounts)));
                boolean addAttFromAllAccountsRBI = (contactsMap.get(con.Id).Inherit_Attributes_from_All_Accounts__c ? true : 
				                	(contactsMap.get(con.Id).Inherit_Attributes_from_All_Accounts__c ?
				                    false : (inheritAttributefromAllAccounts)));
                
                //roll up ref types to account FROM all contact(shared & child) which is updated in Nomination
                if ((con.AccountId == accountId || addRefToAllAccountsRBI) && contactsMap.get(con.Id).Is_Referenceable__c 
                		&& (contactsMap.get(con.Id).Referenceability_Status__c == ConstantsController.ACTIVE 
                        || contactsMap.get(con.Id).Referenceability_Status__c == ConstantsController.CAUTION)) {
        
                    for (Referenceability__c ref : con.Referenceabilities__r) {
        
                        if (!duplicaterefIds.contains(ref.Referenceability_Type__c + '+' + con.Id)) {
        
                            if (ref.Account__c == null) {
                                ref.Account__c = accountId;
                                listReferenceability.add(ref);
                                duplicaterefIds.add(ref.Referenceability_Type__c + '+' + con.Id);
                            } else {
                                duplicaterefIds.add(ref.Referenceability_Type__c + '+' + con.Id);
                                listReferenceability.add(new Referenceability__c(Account__c = accountId, Contact__c = con.Id, Referenceability_Type__c =
                                    ref.Referenceability_Type__c, Comment__c = ref.Comment__c, Verified__c = ref.Verified__c, Status__c = ref.Status__c));
                            }
                        }
                    }
                }
                Set<String> preventDuplicacy = new Set<String>();
                
                //roll up attributes to account FROM all contact(shared & child) which is updated in Nomination
                if ((con.AccountId == accountId || addAttToAllAccountsRBI) && contactsMap.get(con.Id).Is_Referenceable__c 
            			&& (contactsMap.get(con.Id).Referenceability_Status__c == ConstantsController.ACTIVE 
                        || contactsMap.get(con.Id).Referenceability_Status__c == ConstantsController.CAUTION)) {
                    
                    for (Contact_Attribute__c cA : con.Contact_Attributes__r) {
                    
                        if (!cA.from_Account__c) {
                    
                            if (!oppAttributes.contains(cA.Attribute__c) && accountAttributeMap.get(accountId) != null && !accountAttributeMap.get(
                                    accountId).contains(cA.Attribute__c + '+' + cA.Contact__c) && !preventDuplicacy.contains(accountId + '' + con.Id +
                                    '' + cA.Attribute__c)) {
                                Account_Attribute__c tempObj = new Account_Attribute__c();
                                tempObj.Account__c = accountId;
                                tempObj.Attribute__c = cA.Attribute__c;
                                tempObj.Contact__c = con.Id;
                                newAccountAttribute.add(tempObj);
                                preventDuplicacy.add(accountId + '' + con.Id + '' + cA.Attribute__c);
                            } else if (!oppAttributes.contains(cA.Attribute__c) && accountAttributeMap.get(accountId) == null) {
                                Account_Attribute__c tempObj = new Account_Attribute__c();
                                tempObj.Account__c = accountId;
                                tempObj.Attribute__c = cA.Attribute__c;
                                tempObj.Contact__c = con.Id;
                                preventDuplicacy.add(accountId + '' + con.Id + '' + cA.Attribute__c);
                                newAccountAttribute.add(tempObj);
                            }
                        }
                    }
                }
                Set<String> duplicateConAttIds = new Set<String>();
                
                //inherit attributes to all contact(shared & child) FROM Account which is updated in Nomination
                if ((con.AccountId == accountId || addAttFromAllAccountsRBI) && contactsMap.get(con.Id).Is_Referenceable__c) {
                
                    if (inheritableaccountAttributeMap != null && inheritableaccountAttributeMap.containsKey(accountId)) {
                
                        for (Id attId : inheritableaccountAttributeMap.get(accountId)) {
                
                            if (!duplicateConAttIds.contains(attId + '+' + accountId) && contactAttributMap != null && contactAttributMap.containsKey(
                                    con.Id) && !contactAttributMap.get(con.Id).contains(attId + '+' + accountId)) {
                                Contact_Attribute__c tempObj = new Contact_Attribute__c();
                                tempObj.Attribute__c = attId;
                                tempobj.Contact__c = con.Id;
                                tempObj.From_Account__c = true;
                                tempobj.Account__c = accountId;
                                duplicateConAttIds.add(attId + '+' + accountId);
                                newContactAttributes.add(tempObj);
                            } else if (!duplicateConAttIds.contains(attId + '+' + accountId) && contactAttributMap != null && contactAttributMap.get(
                                    con.Id) == null) {
                                Contact_Attribute__c tempObj = new Contact_Attribute__c();
                                tempObj.Attribute__c = attId;
                                tempobj.Contact__c = con.Id;
                                tempObj.From_Account__c = true;
                                tempobj.Account__c = accountId;
                                duplicateConAttIds.add(attId + '+' + accountId);
                                newContactAttributes.add(tempObj);
                            }
                        }
                    }
                }
            }
        }
        
        if (listReferenceability.size() > 0) {
            ConstantsController.isCopyNominationDetailProcess = true;
            WithoutSharingHelperController.upsertReferenceabilities(listReferenceability);
            ConstantsController.isCopyNominationDetailProcess = false;
        }
        
        if (newAccountAttribute.size() > 0) {
            ConstantsController.isCopyNominationDetailProcess = true;
            newAccountAttribute = WithoutSharingHelperController.upsertAccountAttributes(newAccountAttribute);
            ConstantsController.isCopyNominationDetailProcess = false;
        }
        
        if (newContactAttributes.size() > 0) {
            ConstantsController.fromaccount = true;
            ConstantsController.isCopyNominationDetailProcess = true;
            WithoutSharingHelperController.upsertContactAttributes(newContactAttributes);
            ConstantsController.isCopyNominationDetailProcess = false;
        }
        return rbiSet;
    }
    /**
 * Method to be called after the excute
 */
    global void finish(Database.BatchableContext BC) {}

}