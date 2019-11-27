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
public with sharing class ContactAttributeSharedTriggerHandler {
    private static Custom_Settings__c cs = UtilityController.getCustomSettings();
    /**
     *	Method called on before insert of Contact Attribute
     */
    public static void onBeforeInsert(List<Contact_Attribute__c> newContactAttributes) {
    	ConstantsController.fromaccount = false;
    	Set<String> ContactIds = new Set<String>();
        Set<Id> AttribIds = new Set<Id>();
        //iterate over the trigger.new list to get associated contact Ids
        for (Contact_Attribute__c att : newContactAttributes) {
            if (att.Contact__c != null) {
                ContactIds.add(att.Contact__c);
            }
            if (att.From_Account__c) {
            	ConstantsController.fromaccount = true;
            }
        }
        //map which store the contactId as the key and the already associated attributes with that contact
        Map<Id, Set<String>> oldContactAttrib = new Map<Id, Set<String>>();
        
        if (ContactIds.size() != 0) {
            //get the attributes already associated with the contact and store them
            for (Contact_Attribute__c a : [select Contact__c, Attribute__c, Account__c from Contact_Attribute__c where Contact__c in :ContactIds]) {
                if (oldContactAttrib.get(a.Contact__c) == null) {
                    oldContactAttrib.put(a.Contact__c, new Set<String>());
                }
                oldContactAttrib.get(a.Contact__c).add(string.valueOf(a.Attribute__c) + ''
                											+ (a.Account__c != null ? string.valueOf(a.Account__c) : ''));
            }
            //check if the attribute is already associated with the contact then report an error
            for (Contact_Attribute__c a : newContactAttributes) {
                if (oldContactAttrib.get(a.Contact__c) != null &&
                	oldContactAttrib.get(a.Contact__c).contains(string.valueOf(a.Attribute__c) + '' + (a.Account__c != null ? string.valueOf(a.Account__c) : ''))) {
                    
                    a.addError(System.Label.Contact_Attribute);
                }
            }
        }
        Map<String, String> rbiMap = new Map<String, String>();
        for(Reference_Basic_Information__c rbi : [select Id, Contact__c from Reference_Basic_Information__c where Contact__c IN :ContactIds]) {
        	rbiMap.put(rbi.Contact__c, rbi.Id);
        }
        for (Contact_Attribute__c a : newContactAttributes) {
        	a.Reference_Basic_Information__c = (rbiMap.containsKey(a.Contact__c) ? rbiMap.get(a.Contact__c) : null);
        }
    }
    
    /**
     *	Method called on after insert of Contact Attribute
     */
    public static void onAfterInsert(List<Contact_Attribute__c> newContactAttributes, Map<Id, Contact_Attribute__c> newContactAttributeMap) {
        Set<String> contactIds = new Set<String>();
        String attributes;
        Set<String> attIds = new Set<String>();
        Map<String, String> labelIds = new Map<String, String>();
        Map<String, Set<String>> attLabel = new Map<String, Set<String>>();
        Map<String, String> attLabelName = new Map<String, String>();
        Set<String> attribNames = new Set<String>();
        Set<Id> contactsStatusNotToBeUpdated = new Set<Id>();
        List<Reference_Basic_Information__c> updateContacts = new List<Reference_Basic_Information__c>();
        Map<Id, List<Contact_Attribute__c>> ContactAttrib = new Map<Id, List<Contact_Attribute__c>>();
        Map<Id, Reference_Basic_Information__c> rbiContacts = new Map<Id, Reference_Basic_Information__c> ();
        Set<String> checkForParentAttToBeAdded = new Set<String>();
        //store the contactIds 
        for (Contact_Attribute__c a : newContactAttributes) {
            if (a.Contact__c != null) {
                contactIds.add(a.Contact__c);
            }
            if (a.From_Account__c) {
            	contactsStatusNotToBeUpdated.add(a.contact__c);
            }
        }
        //map to store the contacts
        for (Contact con : WithoutSharingHelperController.activateContactRecords(contactIds)) {
            if (con.Reference_Basic_Informations__r.size() > 0) {
                rbiContacts.put(con.Id, con.Reference_Basic_Informations__r[0]);
            } else {
                rbiContacts.put(con.Id, new Reference_Basic_Information__c(Contact__c = con.Id, Account__c = con.AccountId));
            }

            if (!ContactAttrib.containsKey(con.Id)) {
                ContactAttrib.put(con.Id, new List<Contact_Attribute__c>());
            }
            for (Contact_Attribute__c ca : con.Contact_Attributes__r) {
                ContactAttrib.get(con.Id).add(ca);
                if (ca.Attribute__r.Level__c > 1 && newContactAttributeMap.containsKey(ca.Id)) {
                    checkForParentAttToBeAdded.add(ca.Id);
                }
                attIds.add(ca.Attribute__c);
            }
            /*
            for (Contact_Attribute__c ca : con.Contact_Attributes__r) {
                attIds.add(ca.Attribute__c);
            }
            */
        }
        for (Attributes_Labels__c attL : WithoutSharingHelperController.fetchAttributeLabels(attIds)) {
            if (!attLabel.containsKey(attL.Attribute__c)) {
            	attLabel.put(attL.Attribute__c, new Set<string>());
            }
        	attLabel.get(attL.Attribute__c).add('F' + String.valueOf(attL.Label__r.Filter_no__c) + 'F');
            attLabelName.put(attL.Attribute__c, (attL.Attribute__r.Root_Parent__c != null ? attL.Attribute__r.Root_Parent__c : ''));
        }
        //iterate over the ContactAttrib map keySet to form a comma separated string of Attributes and add it to the Attributes__c field of the Contact
        for (Id ContactId : ContactAttrib.keySet()) {
        	//if(ConstantsController.isCopyNominationDetailProcess && rbiContacts.containsKey(ContactId) && rbiContacts.get(ContactId).Id != null)
				//ConstantsController.RBIIds.add(rbiContacts.get(ContactId).Id);
        	if (rbiContacts.containsKey(ContactId) && ContactAttrib.get(ContactId) != null && !ConstantsController.isCopyNominationDetailProcess) {
            	Reference_Basic_Information__c rbi = UtilityController.setFiltersForContact(rbiContacts.get(ContactId), ContactAttrib.get(ContactId), attLabel, attLabelName);
            	if (!(rbiContacts.get(ContactId).Reference_Program_Candidate__c) && !(rbiContacts.get(ContactId).Is_Referenceable__c) && !contactsStatusNotToBeUpdated.contains(ContactId)) {
                    rbi.Is_Referenceable__c = true;
                    rbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                }
                //for copy Nomination Detail Page
                if (ConstantsController.isCopyNominationDetailProcess && !rbiContacts.get(ContactId).Is_Referenceable__c) {
                    rbi.Reference_Program_Candidate__c = false;
                    rbi.Is_Referenceable__c = true;
                    rbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                }
                rbiContacts.put(ContactId, rbi);
                updateContacts.add(rbi);
            }
        }
        if (updateContacts.size() > 0) {
        	ConstantsController.updateRBIInConAttributes = true;
            WithoutSharingHelperController.upsertRBI(updateContacts);
        }
        //this method would add the parent attributes of the newly added attribute to the contact...trickle up 
        if (ConstantsController.fromaccount == false && !ConstantsController.isCopyNominationDetailProcess) {
            //this method would add the newly added attributes to the account as well
            addAttribToAccount(newContactAttributes, ContactAttrib, newContactAttributeMap, rbiContacts);
        }
        if (ConstantsController.addParentToContact && checkForParentAttToBeAdded.size() > 0) {
            addParentAttribToContact(newContactAttributes, newContactAttributeMap, ContactAttrib);
        }
    }
    
    /**
     *	Method to add the newly added attributes to the account as well
     */
    private static void addAttribToAccount(List<Contact_Attribute__c> ContactAttributes, Map<Id, List<Contact_Attribute__c>> contactAttrib,
    											Map<Id, Contact_Attribute__c> newMap, Map<Id, Reference_Basic_Information__c> rbiContacts) {
    	
    	//map to store the contactId and respective accountIds
    	Map<Id, Set<Id>> contactAccountMap = new Map<Id, Set<Id>>();
    	//list to insert the new Account_Attribute__c records
        List<Account_Attribute__c> newAccountAttrib = new List<Account_Attribute__c>();
        //map which maps the already existing attributes on the account
        Map<Id, Set<Id>> accountAttrib = new Map<Id, Set<Id>>();
        Set<String> accountIds = new Set<String>();
        Account_Attribute__c tempObj;
        Map<Id, Reference_Basic_Information__c> accountRBI = new Map<Id, Reference_Basic_Information__c>();
        //loop to get the records of the contact from the database
        for (Reference_Basic_Information__c rbiContact : rbiContacts.values()) {
            if (rbiContact.Is_Referenceable__c && (rbiContact.Referenceability_Status__c == ConstantsController.ACTIVE || rbiContact.Referenceability_Status__c == ConstantsController.CAUTION)) {
                contactAccountMap.put(rbiContact.contact__c, new Set<Id>());
                if(!contactAccountMap.containsKey(rbiContact.contact__c))
                	contactAccountMap.put(rbiContact.contact__c, new Set<Id>());
                contactAccountMap.get(rbiContact.contact__c).add(rbiContact.Account__c);
	        	accountIds.add(rbiContact.Account__c);
	        	accountAttrib.put(rbiContact.Account__c, new Set<Id>());
            }
        }
        String objectName = cs.Shared_Contact_Object__c;
        String accountField = cs.Shared_Account_Field__c;
        String contactField = cs.Shared_Contact_Field__c;
        Set<Id> contactIdTempSet = rbiContacts.keySet();
        if(accountField != null && accountField != '' && contactField != null && contactField != ''){
	        String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName
	        						 + ' WHERE ' + contactField + ' IN :contactIdTempSet';
	        
	        List<sObject> objectList = Database.query(query);
	        for (sObject obj : objectList) {
	        	if(rbiContacts != null && rbiContacts.containsKey((String)obj.get(contactField))){
		        	Reference_Basic_Information__c rbiContact = rbiContacts.get((String)obj.get(contactField));
		        	boolean addRefToAllAccountsRBI = (rbiContact.Roll_up_Attributes_to_All_Accounts__c ? true : (rbiContact.Roll_up_Attributes_to_Primary_Account__c ? false : (cs.Roll_up_Attributes_to_All_Accounts__c)));
		        	if (addRefToAllAccountsRBI && rbiContact.Is_Referenceable__c && (rbiContact.Referenceability_Status__c == ConstantsController.ACTIVE || rbiContact.Referenceability_Status__c == ConstantsController.CAUTION)) {
		                if(!contactAccountMap.containsKey(rbiContact.contact__c))
		                	contactAccountMap.put(rbiContact.contact__c, new Set<Id>());
		                contactAccountMap.get(rbiContact.contact__c).add((String)obj.get(accountField));
		                accountIds.add((String)obj.get(accountField));
		            }
	        	}
	        }
        }
        
        for (Account acc : WithoutSharingHelperController.getAccountRecords(accountIds)) {
            //Aggregate query Exception
            if (acc.Reference_Basic_Informations__r.size() > 0) {
                accountRBI.put(acc.Id, acc.Reference_Basic_Informations__r[0]);
            }
            for (Account_Attribute__c accAtt : acc.Account_Attributes__r) {
                if (contactAccountMap.containsKey(accAtt.Contact__c) && accountAttrib.containsKey(accAtt.Account__c)) {
                    accountAttrib.get(accAtt.Account__c).add(accAtt.Attribute__c);
                }
            }
        }
        Set<String> oppAttributes = new Set<String>();
        for (Attribute__c att : [select Id, (select Id from Attributes__r) from Attribute__c where Attribute_Mapping__r.Object__c = :ConstantsController.OPPORTUNITY and Attribute_Mapping__r.Field_Api_Name__c = 'StageName']) {
        	for (Attribute__c att1 : att.Attributes__r) {
        		oppAttributes.add(att1.Id);
        	}
        }
        for (Id cntctAttId : newMap.keySet()) {
        	if (newMap.get(cntctAttId) != null &&
        		!oppAttributes.contains(newMap.get(cntctAttId).Attribute__c) &&
        		!newMap.get(cntctAttId).From_Account__c && contactAccountMap != null &&
        		contactAccountMap.containsKey(newMap.get(cntctAttId).Contact__c) &&
        		contactAccountMap.get(newMap.get(cntctAttId).Contact__c) != null) {
        		
        		for (String accId : contactAccountMap.get(newMap.get(cntctAttId).contact__c)) {
        			if (accId != null &&
        				accountRBI.containsKey(accId) &&
        				accountRBI.get(accId).Is_Referenceable__c &&
        				rbiContacts.get(newMap.get(cntctAttId).Contact__c).Referenceability_Status__c != ConstantsController.INACTIVE &&
        				accountAttrib.get(accId) != null &&
        				!accountAttrib.get(accId).contains(newMap.get(cntctAttId).Attribute__c)) {
        				
        				tempObj = new Account_Attribute__c();
        				tempObj.Account__c = accId;
		                tempObj.Attribute__c = newMap.get(cntctAttId).Attribute__c;
		                tempObj.Contact__c = newMap.get(cntctAttId).Contact__c;
		                newAccountAttrib.add(tempObj);
		                
        			} else if (accountRBI.containsKey(accId) &&
        						accountRBI.get(accId).Is_Referenceable__c &&
        						rbiContacts.get(newMap.get(cntctAttId).Contact__c).Referenceability_Status__c != ConstantsController.INACTIVE &&
        						accId != null &&
        						accountAttrib.get(accId) == null) {
		                
		                tempObj = new Account_Attribute__c();
		                tempObj.Account__c = accId;
		                tempObj.Attribute__c = newMap.get(cntctAttId).Attribute__c;
		                tempObj.Contact__c = newMap.get(cntctAttId).Contact__c;
		                newAccountAttrib.add(tempObj);
		                
		            } else if ((accountAttrib.get(accId) == null ||
	                    		(accountAttrib.get(accId) != null &&
	                    		!accountAttrib.get(accId).contains(newMap.get(cntctAttId).Attribute__c))) &&
	                    		constantsController.addAttributesToAccount &&
	                    		rbiContacts.get(newMap.get(cntctAttId).Contact__c).Referenceability_Status__c != ConstantsController.INACTIVE) {
		                
		                tempObj = new Account_Attribute__c();
		                tempObj.Account__c = accId;
		                tempObj.Attribute__c = newMap.get(cntctAttId).Attribute__c;
		                tempObj.Contact__c = newMap.get(cntctAttId).Contact__c;
		                newAccountAttrib.add(tempObj);
		            }
        		}
        	}
        }
        if (newAccountAttrib.size() > 0) {
            ConstantsController.addAttributesToContact = false;
            ConstantsController.addAttributesToContent = false;
            WithoutSharingHelperController.upsertAccountAttributes(newAccountAttrib);
        }
    }
    
    /**
     *	Method to add parent Attributes to contact
     */
    private static void addParentAttribToContact(List<Contact_Attribute__c> ContactAttributes,
    												Map<Id, Contact_Attribute__c> newMap,
    												Map<Id, List<Contact_Attribute__c>> contactAttrib) {
    	
    	Set<Id> attribIds = new Set<Id>();
    	List<Contact_Attribute__c> newContactAttrib = new List<Contact_Attribute__c>();
    	Contact_Attribute__c tempObj = new Contact_Attribute__c();
    	Map<Id, List<String>> attribParentMap = new Map<Id, List<String>>();
    	Map<String, Set<Id>> ContactAttribMap = new Map<String, Set<Id>>();
    	Set<String> ContactAttribDuplicacy = new Set<String>();
    	Set<String> parentAttribIds = new Set<String>();
    	Set<Id> parentToBeAdded = new Set<Id>();
    	Set<Id> contactIds = new Set<Id>();
    	
    	for (Contact_Attribute__c aT : ContactAttributes) {
            attribIds.add(aT.Attribute__c);
            contactIds.add(aT.Contact__c);
            ContactAttribMap.put(aT.Contact__c, new Set<Id>());
        }
        for (Attribute__c a : [select Id, parentIds__c from Attribute__c where Id In :attribIds]) {
            if (a.ParentIds__c != null) {
                if (!attribParentMap.containsKey(a.Id)) {
                    attribParentMap.put(a.Id, new List<String>());
                }
                attribParentMap.get(a.Id).addAll(a.ParentIds__c.split(','));
                parentAttribIds.addAll(a.ParentIds__c.split(','));
            }
        }
        if (parentAttribIds.size() > 0) {
            for (Attribute__c a : [select Id, Level__c from Attribute__c where Id In :parentAttribIds]) {
                if (a.level__c != 0) {
                    parentToBeAdded.add(a.Id);
                }
            }
        }
        for (Id cntctId : contactAttrib.keySet()) {
            for (Contact_Attribute__c aT: contactAttrib.get(cntctId)) {
                if (ContactAttribMap.containsKey(aT.Contact__c)) {
                    ContactAttribMap.get(aT.Contact__c).add(aT.Attribute__c);
                }
            }
        }
        for (Id accAttId : newMap.keySet()) {
            if (attribParentMap.get(newMap.get(accAttId).Attribute__c) != null) {
                for (String attId : attribParentMap.get(newMap.get(accAttId).Attribute__c)) {
                    if (parentToBeAdded.contains(attId)) {
                        if (ContactAttribMap.get(newMap.get(accAttId).Contact__c) != null &&
                        	!ContactAttribMap.get(newMap.get(accAttId).Contact__c).contains(attId) &&
                        	!ContactAttribDuplicacy.contains(newMap.get(accAttId).Contact__c + ' ' + attId)) {
	                        tempObj = new Contact_Attribute__c();
                            tempObj.Contact__c = newMap.get(accAttId).Contact__c;
                            tempObj.Attribute__c = attId;
                            tempObj.Account__c = newMap.get(accAttId).Account__c;
                            tempObj.From_Account__c = newMap.get(accAttId).from_Account__c;
                            newContactAttrib.add(tempObj);
                            ContactAttribDuplicacy.add(newMap.get(accAttId).Contact__c + ' ' + attId);
                        }
                    }
                }
            }
        }
        if (newContactAttrib.size() > 0) {
            ConstantsController.addParentToContact = false;
            WithoutSharingHelperController.upsertContactAttributes(newContactAttrib);
        }
    }
    
    /**
     *	Method called on after undelete of Contact Attribute
     */
    public static void onAfterUndelete(List<Contact_Attribute__c> newContactAttributes,
    									Map<Id, Contact_Attribute__c> newContactAttributeMap) {
    	
    	Set<String> contactIds = new Set<String>();
        Set<String> attIds = new Set<String>();
        Map<String, String> labelIds = new Map<String, String>();
        Map<String, Set<String>> attLabel = new Map<String, Set<String>>();
        Map<String, String> attLabelName = new Map<String, String>();
        List<Reference_Basic_Information__c> updateContacts = new List<Reference_Basic_Information__c>();
        
        for (Contact_Attribute__c a : newContactAttributes) {
            if (a.Is_fromMapping__c) {
                a.addError(system.Label.Contact_Attribute_Undelete_Error);
            } else if (a.Contact__c != null) {
                contactIds.add(a.Contact__c);
            }
        }
        //map to store the contacts and respective RBIs
        Map<Id, Reference_Basic_Information__c> rbiContacts = new Map<Id, Reference_Basic_Information__c>();
        for (Reference_Basic_Information__c rbiContact : [Select Contact__c, Attribute_Ids__c, Attributes__c,
                                                            contact__r.AccountId, Referenceability_Status__c, Is_Referenceable__c,
                                                            Contact__r.OwnerId, Reference_Owner__c, Profile_Update_Owner__c
                                                            from Reference_Basic_Information__c
                                                            where Contact__c in :contactIds
                                                            and Contact__c != null
                                                            and (Referenceability_Status__c != :ConstantsController.INACTIVE
                                                            and Referenceability_Status__c !='')]) {
            rbiContacts.put(rbiContact.Contact__c, rbiContact);
        }
        //map to store the contactId with the Contact_Attribute__c record
        Map<Id, List<Contact_Attribute__c>> ContactAttrib = new Map<Id, List<Contact_Attribute__c>>();
        for (Contact_Attribute__c a : WithoutSharingHelperController.getContactAttributesInCopyNomi(contactIds)) {
            if (ContactAttrib.get(a.Contact__c) == null) {
                ContactAttrib.put(a.Contact__c, new List<Contact_Attribute__c>());
            }
            ContactAttrib.get(a.Contact__c).add(a);
            attIds.add(a.Attribute__c);
        }
        for (Attributes_Labels__c attL : WithoutSharingHelperController.fetchAttributeLabels(attIds)) {
            if (!attLabel.containsKey(attL.Attribute__c)) {
        		attLabel.put(attL.Attribute__c, new Set<String>());
            }
        	attLabel.get(attL.Attribute__c).add('F'+String.valueOf(attL.Label__r.Filter_no__c)+'F');
            attLabelName.put(attL.Attribute__c, (attL.Attribute__r.Root_Parent__c != null ? attL.Attribute__r.Root_Parent__c : ''));
        }
        Set<String> attribNames;
        //iterate over the ContactAttrib map keySet to form a comma separated string of Attributes and add it to the Attributes__c field of the Contact
        for (Id ContactId : ContactAttrib.keySet()) {
        	if (ContactAttrib.get(ContactId) != null) {
        		Reference_Basic_Information__c rbi = UtilityController.setFiltersForContact(rbiContacts.get(ContactId), ContactAttrib.get(ContactId), attLabel, attLabelName);
        		updateContacts.add(rbi);
        	}
        }
        if (updateContacts.size() > 0) {
            WithoutSharingHelperController.upsertRBI(updateContacts);
        }
        //this method would add the newly added attributes to the account as well
        addAttribToAccount(newContactAttributes, ContactAttrib, newContactAttributeMap, rbiContacts);
    }
    
    /**
     * Method called on after delete of Contact Attribute
     */
    public static void onAfterDelete(List<Contact_Attribute__c> oldContactAttributes) {
    	Set<String> ContactIds = new Set<String>();
        Set<String> attribIds = new Set<String>();
        Set<String> attIds = new Set<String>();
        Map<String, String> labelIds = new Map<String, String>();
        Map<String, Set<String>> attLabel = new Map<String, Set<String>>();
        Map<String, String> attLabelName = new Map<String, String>();
        Map<Id, List<Contact_Attribute__c>> oldContactAttrib = new Map<Id, List<Contact_Attribute__c>>();
        List<Reference_Basic_Information__c> updateContacts = new List<Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> rbiContacts = new Map<Id, Reference_Basic_Information__c>();
        
        for (Contact_Attribute__c a : oldContactAttributes) {
            if (a.Contact__c != null) {
                ContactIds.add(a.Contact__c);
                oldContactAttrib.put(a.Contact__c, new List<Contact_Attribute__c>());
            }
            attribIds.add(a.Attribute__c);
        }
        for (Contact con : WithoutSharingHelperController.activateContactRecords(contactIds)) {
            if (con.Reference_Basic_Informations__r.size() > 0) {
                rbiContacts.put(con.Id, con.Reference_Basic_Informations__r[0]);
            }
            for (Contact_Attribute__c a : con.Contact_Attributes__r) {
                oldContactAttrib.get(a.Contact__c).add(a);
                attIds.add(a.Attribute__c);
            }
        }
        if (ConstantsController.shouldAccountAttributeDeleteOfContactOnNoMerge) {
			deleteAttributeFrmAccount(ContactIds, attribIds);
        }
        if (ContactIds.size() != 0) {
        	for (Attributes_Labels__c attL : WithoutSharingHelperController.fetchAttributeLabels(attIds)) {
                if (!attLabel.containsKey(attL.Attribute__c)) {
                	attLabel.put(attL.Attribute__c, new Set<String>());
                }
            	attLabel.get(attL.Attribute__c).add('F'+String.valueOf(attL.Label__r.Filter_no__c)+'F');
                attLabelName.put(attL.Attribute__c, (attL.Attribute__r.Root_Parent__c != null ? attL.Attribute__r.Root_Parent__c : ''));
            }
            Set<String> attribNames;
            for (Id ContactId : oldContactAttrib.keySet()) {
            	if (oldContactAttrib.containsKey(ContactId)
            			&& oldContactAttrib.get(ContactId) != null
            			&& rbiContacts.containsKey(ContactId)
            			&& rbiContacts.get(ContactId) != null) {
	        		
	        		Reference_Basic_Information__c rbi = UtilityController.setFiltersForContact(rbiContacts.get(ContactId), oldContactAttrib.get(ContactId), attLabel, attLabelName);
	        		updateContacts.add(rbi);
	        	}
            }
            if (updateContacts.size() > 0) {
                WithoutSharingHelperController.upsertRBI(updateContacts);
            }
        }
    }
    
	/**
     *	Method to delete Attribute from Account
     */
    private static void deleteAttributeFrmAccount(Set<String> ContactIds, Set<String> attribIds) {
        ConstantsController.shouldAccountAttributeDeleteOfContact = true;
        List<Account_Attribute__c> accuntAttribDelete = WithoutSharingHelperController.getAccountAttributesWithContact1(ContactIds, attribIds);
        if (accuntAttribDelete.size() > 0) {
            // changes made for #438 - delete DML moved from this class to without sharing class
            WithoutSharingHelperController.deleteAttributeFrmAccount(accuntAttribDelete);
            //delete accuntAttribDelete;
        }
    }
    
    /**
     *	Method called on before delete of Contact Attribute
     */
    public static void onbeforeDelete(List<Contact_Attribute__c> oldContactAttributes, Map<Id, Contact_Attribute__c> oldContactAttributeMap) {
        Map<Id, Set<Id>> contactAttribMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> attributeParentChildMap = new Map<Id, Set<Id>>();
        Set<String> contactIds = new Set<String>();
        Set<Id> attribIds = new Set<Id>();
        
        for (Contact_Attribute__c cA : oldContactAttributes) {
            contactIds.add(cA.Contact__c);
            attribIds.add(cA.Attribute__c);
            contactAttribMap.put(cA.contact__c, new Set<Id>());
            attributeParentChildMap.put(cA.Attribute__c, new Set<Id>());
        }
        for (Attribute__c a : [select Id, Parent__c from Attribute__c where Parent__c In :attribIds]) {
            attributeParentChildMap.get(a.Parent__c).add(a.Id);
        }
        for (Contact_Attribute__c cA : WithoutSharingHelperController.getContactAttributesInCopyNomi(contactIds)) {
            if (!oldContactAttributeMap.containsKey(cA.Id)) {
                contactAttribMap.get(cA.Contact__c).add(cA.Attribute__c);
            }
        }
        for (Contact_Attribute__c cA : oldContactAttributes) {
            for (Id attribId: attributeParentChildMap.get(cA.Attribute__c)) {
                if (contactAttribMap.containsKey(cA.Contact__c)
                		&& contactAttribMap.get(cA.Contact__c) != null
                		&& contactAttribMap.get(cA.Contact__c).contains(attribId)
                		&& !ConstantsController.deleteAttributFromContact && 
                    !ConstantsController.isCallFromBatchRemoveDuplicateRBI) {
                    cA.addError(System.Label.Attribute_removal_to_associated_Contact_with_Child_Attr_Msg);
                }
            }
        }
    }
}