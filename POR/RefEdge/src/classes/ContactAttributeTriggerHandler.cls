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
public with sharing class ContactAttributeTriggerHandler {
    
    /**
     * Method called on before insert of Contact Attribute
     */
    public static void onBeforeInsert(list < Contact_Attribute__c > newContactAttributes) {
        ConstantsController.fromaccount = false;
        Set < String > ContactIds = new Set < String > ();
        Set < Id > AttribIds = new Set < Id > ();
        //iterate over the trigger.new list to get associated contact Ids
        for (Contact_Attribute__c att: newContactAttributes) {
            if (att.Contact__c != null) {
                ContactIds.add(att.Contact__c);
            }
            if (att.From_Account__c)
                ConstantsController.fromaccount = true;
        }
        //map which store the contactId as the key and the already associated attributes with that contact
        map < Id, Set < Id >> oldContactAttrib = new map < Id, Set < Id >> ();
		
        if (ContactIds.size() != 0) {
            //get the attributes already associated with the contact and store them
            for (Contact_Attribute__c a: [select Contact__c, Attribute__c from Contact_Attribute__c where Contact__c in : ContactIds]) {
                if (oldContactAttrib.get(a.Contact__c) == null) {
                    oldContactAttrib.put(a.Contact__c, new set < Id > ());
                }
                oldContactAttrib.get(a.Contact__c).add(a.Attribute__c);
            }
            //check if the attribute is already associated with the contact then report an error
            for (Contact_Attribute__c a: newContactAttributes) {
                if (oldContactAttrib.get(a.Contact__c) != null && oldContactAttrib.get(a.Contact__c).contains(a.Attribute__c)) {
                    a.addError(System.Label.Contact_Attribute);
                }
            }
        }
        /*
         * for --> ReferenceEdge Attribute, Mapped Attribute Reporting question
         * set Reference_Basic_Information__c in Account Attribute
         * by Rekha
         */
        map<String,String> rbiMap = new map<String,String>();
        for(Reference_Basic_Information__c rbi : [select Id, Contact__c from Reference_Basic_Information__c where Contact__c IN : ContactIds]){
        	rbiMap.put(rbi.Contact__c, rbi.Id);
        }
        for (Contact_Attribute__c a: newContactAttributes) {
        	a.Reference_Basic_Information__c = (rbiMap.containsKey(a.Contact__c) ? rbiMap.get(a.Contact__c) : null);
        }
        //end
    }

    /**
     * Method called on after insert of Contact Attribute
     */
    public static void onAfterInsert(list < Contact_Attribute__c > newContactAttributes,map < Id, Contact_Attribute__c > newContactAttributeMap) {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Set < String > contactIds = new Set < String > ();
        String attributes;
        set < String > attIds = new set < String > ();
        map < String, String > labelIds = new map < String, String > ();
        map < String, set<String> > attLabel = new map < String, set<String> > ();
        map < String, String > attLabelName = new map < String, String > ();
        set < String > attribNames = new set < String > ();
        set < Id > contactsStatusNotToBeUpdated = new set < Id > ();
        list < Reference_Basic_Information__c > updateContacts = new list < Reference_Basic_Information__c > ();
        map < Id, list < Contact_Attribute__c >> ContactAttrib = new Map < Id, list < Contact_Attribute__c >> ();
        map < Id, Reference_Basic_Information__c > rbiContacts = new map < Id, Reference_Basic_Information__c > ();
        set < String > checkForParentAttToBeAdded = new set < String > ();
        //store the contactIds 
        for (Contact_Attribute__c a: newContactAttributes) {
            if (a.Contact__c != null) {
                contactIds.add(a.Contact__c);
            }
            if (a.From_Account__c)
                contactsStatusNotToBeUpdated.add(a.contact__c);
        }
        //map to store the contacts
        for (Contact con: WithoutSharingHelperController.activateContactRecords(contactIds)) {
            if (con.Reference_Basic_Informations__r.size() > 0)
                rbiContacts.put(con.Id, con.Reference_Basic_Informations__r[0]);
            else
                rbiContacts.put(con.Id, new Reference_Basic_Information__c(Contact__c = con.Id, Account__c = con.AccountId));

            if (!ContactAttrib.containsKey(con.Id)) {
                ContactAttrib.put(con.Id, new list < Contact_Attribute__c > ());
            }
            for (Contact_Attribute__c ca: con.Contact_Attributes__r) {
                ContactAttrib.get(con.Id).add(ca);
                if (ca.Attribute__r.Level__c > 1 && newContactAttributeMap.containsKey(ca.Id))
                    checkForParentAttToBeAdded.add(ca.Id);
            }
            for (Contact_Attribute__c ca: con.Contact_Attributes__r) {
                attIds.add(ca.Attribute__c);
            }
        }
        for (Attributes_Labels__c attL: WithoutSharingHelperController.fetchAttributeLabels(attIds)) {
            if(!attLabel.containsKey(attL.Attribute__c))
                	attLabel.put(attL.Attribute__c, new set<string>());
            	attLabel.get(attL.Attribute__c).add('F'+String.valueOf(attL.Label__r.Filter_no__c)+'F');
            attLabelName.put(attL.Attribute__c, (attL.Attribute__r.Root_Parent__c != null ? attL.Attribute__r.Root_Parent__c : ''));
        }
        //iterate over the ContactAttrib map keySet to form a comma separated string of Attributes and add it to the Attributes__c field of the Contact
        for (Id ContactId: ContactAttrib.keySet()) {
        	//if(ConstantsController.isCopyNominationDetailProcess && rbiContacts.containsKey(ContactId) && rbiContacts.get(ContactId).Id != null)
				//ConstantsController.RBIIds.add(rbiContacts.get(ContactId).Id);
        	if (rbiContacts.containsKey(ContactId) && ContactAttrib.get(ContactId) != null && !ConstantsController.isCopyNominationDetailProcess){
            	Reference_Basic_Information__c rbi = UtilityController.setFiltersForContact(rbiContacts.get(ContactId),ContactAttrib.get(ContactId),attLabel,attLabelName);
            	if (rbiContacts.get(ContactId).Reference_Program_Candidate__c == false && rbiContacts.get(ContactId).Is_Referenceable__c == false && !contactsStatusNotToBeUpdated.contains(ContactId)) {
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
            /*
             * for --> ReferenceEdge Attribute, Mapped Attribute Reporting question
             * set Reference_Basic_Information__c in Account Attribute
             * by Rekha
             */
        	ConstantsController.updateRBIInConAttributes = true;//end
            WithoutSharingHelperController.upsertRBI(updateContacts);
        }
        //this method would add the parent attributes of the newly added attribute to the contact...trickle up 
        if (ConstantsController.fromaccount == false) {
            //this method would add the newly added attributes to the account as well
            addAttribToAccount(newContactAttributes, ContactAttrib, newContactAttributeMap, rbiContacts);
        }
        if (ConstantsController.addParentToContact && checkForParentAttToBeAdded.size() > 0)
            addParentAttribToContact(newContactAttributes, newContactAttributeMap, ContactAttrib);
    }

    /**
     * Method to add the newly added attributes to the account as well
     */
    private static void addAttribToAccount(list < Contact_Attribute__c > ContactAttributes, map < id, list < Contact_Attribute__c >> contactAttrib, map < Id, Contact_Attribute__c > newMap, map < Id, Reference_Basic_Information__c > rbiContacts) {
        //map to map the contactId with the accountId
        map < id, Id > contactAccountMap = new map < id, id > ();
        //list to insert the new Account_Attribute__c records
        list < Account_Attribute__c > newAccountAttrib = new list < Account_Attribute__c > ();
        //map which maps the already existing attributes on the account
        map < Id, Set < Id >> accountAttrib = new map < Id, set < Id >> ();
        set < String > accountIds = new set < String > ();
        Account_Attribute__c tempObj;
        map < Id, Reference_Basic_Information__c > accountRBI = new map < Id, Reference_Basic_Information__c > ();
        //loop to get the records of the contact from the database 
        for (Reference_Basic_Information__c rbiContact: rbiContacts.values()) {
            if (rbiContact.Is_Referenceable__c && (rbiContact.Referenceability_Status__c == ConstantsController.ACTIVE || rbiContact.Referenceability_Status__c == ConstantsController.CAUTION)) {
                if(ConstantsController.isAccountSelectedfromContact){
                	contactAccountMap.put(rbiContact.contact__c, rbiContact.contact__r.AccountId);
                	for(string str : ConstantsController.selectedAccounts){
		                accountIds.add(str);
		                accountAttrib.put(str, new set < Id > ());
                	}
                }
                else {
	                contactAccountMap.put(rbiContact.contact__c, rbiContact.contact__r.AccountId);
	                accountIds.add(rbiContact.contact__r.AccountId);
	                accountAttrib.put(rbiContact.contact__r.AccountId, new set < Id > ());
                }
            }
        }
        for (Account acc: WithoutSharingHelperController.getAccountRecords(accountIds)) {
            //Aggregate query Exception
            if (acc.Reference_Basic_Informations__r.size() > 0)
                accountRBI.put(acc.Id, acc.Reference_Basic_Informations__r[0]);

            for (Account_Attribute__c accAtt: acc.Account_Attributes__r) {
                if (contactAccountMap.containsKey(accAtt.Contact__c))
                    accountAttrib.get(accAtt.Account__c).add(accAtt.Attribute__c);
            }
        }
        set<String> oppAttributes = new set<string>();
        for(Attribute__c att : [select Id, (select Id from Attributes__r) from Attribute__c where Attribute_Mapping__r.Object__c = : ConstantsController.OPPORTUNITY and Attribute_Mapping__r.Field_Api_Name__c = 'StageName']){
        	for(Attribute__c att1 : att.Attributes__r){
        		oppAttributes.add(att1.Id);
        	}
        }
        for (Id cntctAttId: newMap.keySet()) {
            if(!oppAttributes.contains(newMap.get(cntctAttId).Attribute__c)){
	            if(ConstantsController.selectedAccounts != null && ConstantsController.selectedAccounts.size() > 0){
	            	for(string accountId : ConstantsController.selectedAccounts){
	            		if (accountRBI.containsKey(accountId) && accountRBI.get(accountId).Is_Referenceable__c && rbiContacts.get(newMap.get(cntctAttId).Contact__c).Referenceability_Status__c != ConstantsController.INACTIVE && contactAccountMap.get(newMap.get(cntctAttId).Contact__c) != null && accountAttrib.get(accountId) != null && !accountAttrib.get(accountId).contains(newMap.get(cntctAttId).Attribute__c)) {
			                tempObj = new Account_Attribute__c();
			                tempObj.Account__c = accountId;
			                tempObj.Attribute__c = newMap.get(cntctAttId).Attribute__c;
			                tempObj.Contact__c = newMap.get(cntctAttId).Contact__c;
			                newAccountAttrib.add(tempObj);
			            } else if (accountRBI.containsKey(accountId) && accountRBI.get(accountId).Is_Referenceable__c && rbiContacts.get(newMap.get(cntctAttId).Contact__c).Referenceability_Status__c != ConstantsController.INACTIVE && accountId != null && accountAttrib.get(accountId) == null) {
			                tempObj = new Account_Attribute__c();
			                tempObj.Account__c = accountId;
			                tempObj.Attribute__c = newMap.get(cntctAttId).Attribute__c;
			                tempObj.Contact__c = newMap.get(cntctAttId).Contact__c;
			                newAccountAttrib.add(tempObj);
			            } else if ((accountAttrib.get(accountId) == null ||
			                    (accountAttrib.get(accountId) != null &&
			                        !accountAttrib.get(accountId).contains(newMap.get(cntctAttId).Attribute__c))) &&
			                constantsController.addAttributesToAccount &&
			                rbiContacts.get(newMap.get(cntctAttId).Contact__c).Referenceability_Status__c != ConstantsController.INACTIVE) {
			                tempObj = new Account_Attribute__c();
			                tempObj.Account__c = accountId;
			                tempObj.Attribute__c = newMap.get(cntctAttId).Attribute__c;
			                tempObj.Contact__c = newMap.get(cntctAttId).Contact__c;
			                newAccountAttrib.add(tempObj);
			            }
	            	}
	            }
	            else{
		            if (accountRBI.containsKey(contactAccountMap.get(newMap.get(cntctAttId).contact__c)) && accountRBI.get(contactAccountMap.get(newMap.get(cntctAttId).contact__c)).Is_Referenceable__c && rbiContacts.get(newMap.get(cntctAttId).Contact__c).Referenceability_Status__c != ConstantsController.INACTIVE && contactAccountMap.get(newMap.get(cntctAttId).Contact__c) != null && accountAttrib.get(contactAccountMap.get(newMap.get(cntctAttId).Contact__c)) != null && !accountAttrib.get(contactAccountMap.get(newMap.get(cntctAttId).Contact__c)).contains(newMap.get(cntctAttId).Attribute__c)) {
		                tempObj = new Account_Attribute__c();
		                tempObj.Account__c = contactAccountMap.get(newMap.get(cntctAttId).Contact__c);
		                tempObj.Attribute__c = newMap.get(cntctAttId).Attribute__c;
		                tempObj.Contact__c = newMap.get(cntctAttId).Contact__c;
		                newAccountAttrib.add(tempObj);
		            } else if (accountRBI.containsKey(contactAccountMap.get(newMap.get(cntctAttId).contact__c)) && accountRBI.get(contactAccountMap.get(newMap.get(cntctAttId).contact__c)).Is_Referenceable__c && rbiContacts.get(newMap.get(cntctAttId).Contact__c).Referenceability_Status__c != ConstantsController.INACTIVE && contactAccountMap.get(newMap.get(cntctAttId).Contact__c) != null && accountAttrib.get(contactAccountMap.get(newMap.get(cntctAttId).Contact__c)) == null) {
		                tempObj = new Account_Attribute__c();
		                tempObj.Account__c = contactAccountMap.get(newMap.get(cntctAttId).Contact__c);
		                tempObj.Attribute__c = newMap.get(cntctAttId).Attribute__c;
		                tempObj.Contact__c = newMap.get(cntctAttId).Contact__c;
		                newAccountAttrib.add(tempObj);
		            } else if ((accountAttrib.get(contactAccountMap.get(newMap.get(cntctAttId).Contact__c)) == null ||
		                    (accountAttrib.get(contactAccountMap.get(newMap.get(cntctAttId).Contact__c)) != null &&
		                        !accountAttrib.get(contactAccountMap.get(newMap.get(cntctAttId).Contact__c)).contains(newMap.get(cntctAttId).Attribute__c))) &&
		                constantsController.addAttributesToAccount &&
		                rbiContacts.get(newMap.get(cntctAttId).Contact__c).Referenceability_Status__c != ConstantsController.INACTIVE) {
		                tempObj = new Account_Attribute__c();
		                tempObj.Account__c = contactAccountMap.get(newMap.get(cntctAttId).Contact__c);
		                tempObj.Attribute__c = newMap.get(cntctAttId).Attribute__c;
		                tempObj.Contact__c = newMap.get(cntctAttId).Contact__c;
		                newAccountAttrib.add(tempObj);
		            }
	            }
            }
        }
        system.debug('%%%%%%%%%%%%%%%%'+ConstantsController.addAttributesToContact);
        if (newAccountAttrib.size() > 0) {
            ConstantsController.addAttributesToContact = false;
            ConstantsController.addAttributesToContent = false;
            WithoutSharingHelperController.upsertAccountAttributes(newAccountAttrib);
        }
    }

    /**
     * Method to add parent Attributes to contact
     */
    private static void addParentAttribToContact(list < Contact_Attribute__c > ContactAttributes, map < Id, Contact_Attribute__c > newMap, map < Id, list < Contact_Attribute__c >> contactAttrib) {
        set < Id > attribIds = new set < Id > ();
        list < Contact_Attribute__c > newContactAttrib = new list < Contact_Attribute__c > ();
        Contact_Attribute__c tempObj;
        map < Id, list < String >> attribParentMap = new map < Id, list < String >> ();
        map < String, set < Id >> ContactAttribMap = new map < String, set < Id >> ();
        set < String > ContactAttribDuplicacy = new set < String > ();
        set < String > parentAttribIds = new set < String > ();
        set < Id > parentToBeAdded = new set < Id > ();
        set < Id > contactIds = new set < Id > ();
        for (Contact_Attribute__c aT: ContactAttributes) {
            attribIds.add(aT.Attribute__c);
            contactIds.add(aT.Contact__c);
            ContactAttribMap.put(aT.Contact__c, new set < Id > ());
        }
        for (Attribute__c a: [select Id, parentIds__c from Attribute__c where Id In: attribIds]) {
            if (a.ParentIds__c != null) {
                if (!attribParentMap.containsKey(a.Id))
                    attribParentMap.put(a.Id, new list < String > ());
                attribParentMap.get(a.Id).addAll(a.ParentIds__c.split(','));
                parentAttribIds.addAll(a.ParentIds__c.split(','));
            }
        }
        if (parentAttribIds.size() > 0) {
            for (Attribute__c a: [select Id, Level__c from Attribute__c where Id In: parentAttribIds]) {
                if (a.level__c != 0)
                    parentToBeAdded.add(a.Id);
            }
        }
        for (Id cntctId: contactAttrib.keySet()) {
            for (Contact_Attribute__c aT: contactAttrib.get(cntctId)) {
                if (ContactAttribMap.containsKey(aT.Contact__c))
                    ContactAttribMap.get(aT.Contact__c).add(aT.Attribute__c);
            }
        }

        for (Id accAttId: newMap.keySet()) {
            if (attribParentMap.get(newMap.get(accAttId).Attribute__c) != null) {
                for (String attId: attribParentMap.get(newMap.get(accAttId).Attribute__c)) {
                    if (parentToBeAdded.contains(attId)) {
                        if (ContactAttribMap.get(newMap.get(accAttId).Contact__c) != null && !ContactAttribMap.get(newMap.get(accAttId).Contact__c).contains(attId) && !ContactAttribDuplicacy.contains(newMap.get(accAttId).Contact__c + ' ' + attId)) {
                            tempObj = new Contact_Attribute__c();
                            tempObj.Contact__c = newMap.get(accAttId).Contact__c;
                            tempObj.Attribute__c = attId;
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
     * Method called on after undelete of Contact Attribute
     */
    public static void onAfterUndelete(list < Contact_Attribute__c > newContactAttributes,map < Id, Contact_Attribute__c > newContactAttributeMap) {
        Set < String > contactIds = new Set < String > ();
        set < String > attIds = new set < String > ();
        map < String, String > labelIds = new map < String, String > ();
        map < String, set<String> > attLabel = new map < String, set<String> > ();
        map < String, String > attLabelName = new map < String, String > ();
        list < Reference_Basic_Information__c > updateContacts = new list < Reference_Basic_Information__c > ();
        for (Contact_Attribute__c a: newContactAttributes) {
            if (a.Is_fromMapping__c) {
                a.addError(system.Label.Contact_Attribute_Undelete_Error);
            } else if (a.Contact__c != null) {
                contactIds.add(a.Contact__c);
            }
        }
        //map to store the contacts
        map < Id, Reference_Basic_Information__c > rbiContacts = new map < Id, Reference_Basic_Information__c > ();
        for (Reference_Basic_Information__c rbiContact: [Select Contact__c, Attribute_Ids__c, Attributes__c, contact__r.AccountId, Referenceability_Status__c, Is_Referenceable__c, Contact__r.OwnerId, Profile_Update_Owner__c, Reference_Owner__c from Reference_Basic_Information__c where Contact__c in : contactIds and Contact__c != null and(Referenceability_Status__c != : ConstantsController.INACTIVE and Referenceability_Status__c != '')]) {
            rbiContacts.put(rbiContact.Contact__c, rbiContact);
        }
        //map to map the contactId with the Contact_Attribute__c record
        map < Id, list < Contact_Attribute__c >> ContactAttrib = new Map < Id, list < Contact_Attribute__c >> ();
        for (Contact_Attribute__c a: WithoutSharingHelperController.getContactAttributesInCopyNomi(contactIds)) {
            if (ContactAttrib.get(a.Contact__c) == null) {
                ContactAttrib.put(a.Contact__c, new list < Contact_Attribute__c > ());
            }
            ContactAttrib.get(a.Contact__c).add(a);
            attIds.add(a.Attribute__c);
        }
        for (Attributes_Labels__c attL: WithoutSharingHelperController.fetchAttributeLabels(attIds)) {
            if(!attLabel.containsKey(attL.Attribute__c))
                	attLabel.put(attL.Attribute__c, new set<string>());
            	attLabel.get(attL.Attribute__c).add('F'+String.valueOf(attL.Label__r.Filter_no__c)+'F');
            attLabelName.put(attL.Attribute__c, (attL.Attribute__r.Root_Parent__c != null ? attL.Attribute__r.Root_Parent__c : ''));
        }
        set < String > attribNames;
        //iterate over the ContactAttrib map keySet to form a comma separated string of Attributes and add it to the Attributes__c field of the Contact
        for (Id ContactId: ContactAttrib.keySet()) {
        	if (ContactAttrib.get(ContactId) != null && ContactAttrib.get(ContactId) != null) {
        		Reference_Basic_Information__c rbi = UtilityController.setFiltersForContact(rbiContacts.get(ContactId),ContactAttrib.get(ContactId),attLabel,attLabelName);
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
    public static void onAfterDelete(list < Contact_Attribute__c > oldContactAttributes) {
        Set < String > ContactIds = new Set < String > ();
        Set < String > attribIds = new Set < String > ();
        set < String > attIds = new set < String > ();
        map < String, String > labelIds = new map < String, String > ();
        map < String, set<String> > attLabel = new map < String, set<String> > ();
        map < String, String > attLabelName = new map < String, String > ();
        map < Id, list < Contact_Attribute__c >> oldContactAttrib = new map < Id, list < Contact_Attribute__c >> ();
        list < Reference_Basic_Information__c > updateContacts = new list < Reference_Basic_Information__c > ();
        for (Contact_Attribute__c a: oldContactAttributes) {
            if (a.Contact__c != null) {
                ContactIds.add(a.Contact__c);
                oldContactAttrib.put(a.Contact__c, new list < Contact_Attribute__c > ());
            }
            attribIds.add(a.Attribute__c);
        }
        map < Id, Reference_Basic_Information__c > rbiContacts = new map < Id, Reference_Basic_Information__c > ();
        for (Contact con: WithoutSharingHelperController.activateContactRecords(contactIds)) {

            if (con.Reference_Basic_Informations__r.size() > 0)
                rbiContacts.put(con.Id, con.Reference_Basic_Informations__r[0]);
            for (Contact_Attribute__c a: con.Contact_Attributes__r) {
                oldContactAttrib.get(a.Contact__c).add(a);
                attIds.add(a.Attribute__c);
            }
        }
        if (ConstantsController.shouldAccountAttributeDeleteOfContactOnNoMerge)
                deleteAttributeFrmAccount(ContactIds, attribIds);
        if (ContactIds.size() != 0) {
            for (Attributes_Labels__c attL: WithoutSharingHelperController.fetchAttributeLabels(attIds)) {
                if(!attLabel.containsKey(attL.Attribute__c))
                	attLabel.put(attL.Attribute__c, new set<string>());
            	attLabel.get(attL.Attribute__c).add('F'+String.valueOf(attL.Label__r.Filter_no__c)+'F');
                attLabelName.put(attL.Attribute__c, (attL.Attribute__r.Root_Parent__c != null ? attL.Attribute__r.Root_Parent__c : ''));
            }
            set < String > attribNames;
            for (Id ContactId: oldContactAttrib.keySet()) {
            	if (oldContactAttrib.get(ContactId) != null && rbiContacts.get(ContactId) != null) {
	        		Reference_Basic_Information__c rbi = UtilityController.setFiltersForContact(rbiContacts.get(ContactId),oldContactAttrib.get(ContactId),attLabel,attLabelName);
	        		updateContacts.add(rbi);
	        	}
            }
            if (updateContacts.size() > 0) {
                WithoutSharingHelperController.upsertRBI(updateContacts);
            }
        }
    }
	/**
     * Method to delete Attribute from Account
     */
    private static void deleteAttributeFrmAccount(Set < String > ContactIds, Set < String > attribIds) {
        ConstantsController.shouldAccountAttributeDeleteOfContact = true;
        list < Account_Attribute__c > accuntAttribDelete = WithoutSharingHelperController.getAccountAttributesWithContact1(ContactIds, attribIds);
        if (accuntAttribDelete.size() > 0)
        	WithoutSharingHelperController.deleteAccountAttributes(accuntAttribDelete);
    }
	/**
     * Method called on before delete of Contact Attribute
     */
    public static void onbeforeDelete(list < Contact_Attribute__c > oldContactAttributes,map < Id, Contact_Attribute__c > oldContactAttributeMap) {
        map < Id, Set < Id >> contactAttribMap = new map < Id, set < Id >> ();
        map < Id, set < Id >> attributeParentChildMap = new map < Id, set < Id >> ();
        set < String > contactIds = new set < String > ();
        set < Id > attribIds = new set < Id > ();
        for (Contact_Attribute__c cA: oldContactAttributes) {
            contactIds.add(cA.Contact__c);
            attribIds.add(cA.Attribute__c);
            contactAttribMap.put(cA.contact__c, new Set < id > ());
            attributeParentChildMap.put(cA.Attribute__c, new set < Id > ());
        }
        for (Attribute__c a: [select Id, Parent__c from Attribute__c where Parent__c In: attribIds]) {
            attributeParentChildMap.get(a.Parent__c).add(a.Id);
        }
        for (Contact_Attribute__c cA: WithoutSharingHelperController.getContactAttributesInCopyNomi(contactIds)) {
            if (!oldContactAttributeMap.containsKey(cA.Id))
                contactAttribMap.get(cA.Contact__c).add(cA.Attribute__c);
        }
        for (Contact_Attribute__c cA: oldContactAttributes) {
            for (Id attribId: attributeParentChildMap.get(cA.Attribute__c)) {
                if (contactAttribMap.get(cA.Contact__c).contains(attribId) && !ConstantsController.deleteAttributFromContact && !ConstantsController.isCallFromBatchRemoveDuplicateRBI) {
                    cA.addError(System.Label.Attribute_removal_to_associated_Contact_with_Child_Attr_Msg);
                }
            }
        }
    }
}