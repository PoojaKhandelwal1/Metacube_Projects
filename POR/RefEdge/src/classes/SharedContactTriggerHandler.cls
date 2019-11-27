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
global with sharing class SharedContactTriggerHandler {
    
    /**
     * Method called on after insert of Shared Contact
     */
    global static void onAfterInsert(list < sObject > newList) {
    	set<string> contactIdset = new set<string>();
    	set<string> accountIdset = new set<string>();
    	map<Id, set<Id>> contactAccountMap = new map<Id, set<Id>>();
    	map<Id, set<Id>> accountContactMap = new map<Id, set<Id>>();
    	map<Id, set<Id>> contactAccountAttMap = new map<Id, set<Id>>();
    	map<Id, set<Id>> accountContactAttMap = new map<Id, set<Id>>();
    	map<Id, list<Referenceability__c>> contactAccountRefMap = new map<Id, list<Referenceability__c>>();
    	map<Id, Reference_Basic_Information__c> contactrbiMap = new map<Id, Reference_Basic_Information__c>();
    	map<Id, Reference_Basic_Information__c> accountrbiMap = new map<Id, Reference_Basic_Information__c>();
    	list < Referenceability__c > newAccountRefs = new list < Referenceability__c > ();
    	list < Account_Attribute__c > newAccountAttrib = new list < Account_Attribute__c > ();
    	list < Contact_Attribute__c > newContctAttrib = new list < Contact_Attribute__c > ();
    	Custom_Settings__c cs = UtilityController.getCustomSettings();
    	boolean addAttributeToAllAccounts = cs.Roll_up_Attributes_to_All_Accounts__c;
    	boolean inheritAttributefromAllAccounts = cs.Inherit_Attributes_from_All_Accounts__c;
    	boolean addRefToAllAccounts = cs.Roll_up_Referenceability_to_All_Accounts__c;
    	if(cs.Shared_Contact_Field__c != null && cs.Shared_Contact_Field__c != '' && cs.Shared_Account_Field__c != null && cs.Shared_Account_Field__c != ''){
	    	for(sObject sharedContact : newList){
	    		string contactId = string.valueOf(sharedContact.get(cs.Shared_Contact_Field__c));
	    		string accountId = string.valueOf(sharedContact.get(cs.Shared_Account_Field__c));
				contactIdset.add(contactId);
				accountIdset.add(accountId);
				if(contactAccountMap != null && !contactAccountMap.containsKey(contactId))
					contactAccountMap.put(contactId , new set<Id>());
				contactAccountMap.get(contactId).add(accountId);
				if(accountContactMap != null && !accountContactMap.containsKey(accountId))
					accountContactMap.put(accountId , new set<Id>());
				accountContactMap.get(accountId).add(contactId);
	    	}
	    	
	    	//get related all contacts with their profile and account attributes
	    	for(Contact con : WithoutSharingHelperController.getCntactRecordsWithAllRelatedRecordsSharedContact(contactIdset)){
	    		if(con.Reference_Basic_Informations__r != null && con.Reference_Basic_Informations__r.size() > 0){
	    			contactrbiMap.put(con.Id, con.Reference_Basic_Informations__r[0]);
	    		}
	    		contactAccountAttMap.put(con.Id, new set<Id>());
	    		for(Contact_Attribute__c conAtt : con.Contact_Attributes__r){
	    			contactAccountAttMap.get(con.Id).add(conAtt.Attribute__c);	
	    		}
	    		contactAccountRefMap.put(con.Id, new list<Referenceability__c>());
	    		for(Referenceability__c ref : con.Referenceabilities__r){
	    			contactAccountRefMap.get(con.Id).add(ref);	
	    		}
	    	}
	    	
	    	//get related all accounts with their profile and account attributes
	    	for(Account acc : WithoutSharingHelperController.getAccountRecordsWithAllRelatedRecordsSharedContact(accountIdset)){
	    		//to exclude generic account
        		if(acc.Reference_Basic_Informations__r.size() == 0 || (acc.Reference_Basic_Informations__r.size() > 0 && !acc.Reference_Basic_Informations__r[0].Generic_Account__c)) {
		    		if(acc.Reference_Basic_Informations__r != null && acc.Reference_Basic_Informations__r.size() > 0){
		    			accountrbiMap.put(acc.Id, acc.Reference_Basic_Informations__r[0]);
		    		}
		    		accountContactAttMap.put(acc.Id, new set<Id>());
		    		for(Account_Attribute__c accAtt : acc.Account_Attributes__r){
		    			accountContactAttMap.get(acc.Id).add(accAtt.Attribute__c);	
		    		}
        		}
	    	}
	    	//iterate all contacts and their related accounts to create account attributes
	    	for(Id contactId : contactAccountMap.keySet()){
	    		if(contactrbiMap != null && contactrbiMap.containsKey(contactId) && contactrbiMap.get(contactId).Is_Referenceable__c && 
					(contactrbiMap.get(contactId).Referenceability_Status__c == ConstantsController.ACTIVE || 
					contactrbiMap.get(contactId).Referenceability_Status__c == ConstantsController.CAUTION)){
					boolean addAttributeToAllAccountsRBI = (contactrbiMap.get(contactId).Roll_up_Attributes_to_All_Accounts__c ? true : (contactrbiMap.get(contactId).Roll_up_Attributes_to_Primary_Account__c ? false : (addAttributeToAllAccounts)));
					boolean addRefToAllAccountsRBI = (contactrbiMap.get(contactId).Roll_up_Referenceability_to_All_Accounts__c ? true : (contactrbiMap.get(contactId).Roll_up_Referenceability_to_Primary_Acc__c ? false : (addRefToAllAccounts)));
		    		for(Id accountId : contactAccountMap.get(contactId)){
		    			if(accountrbiMap != null && accountrbiMap.containsKey(accountId) && accountrbiMap.get(accountId).Is_Referenceable__c && 
		    				(accountrbiMap.get(accountId).Referenceability_Status__c == ConstantsController.ACTIVE || 
		    				accountrbiMap.get(accountId).Referenceability_Status__c == ConstantsController.CAUTION)){
		    				if(addAttributeToAllAccountsRBI && contactAccountAttMap != null && contactAccountAttMap.containsKey(contactId) && contactAccountAttMap.get(contactId).size() > 0){
			    				for(Id attId : contactAccountAttMap.get(contactId)){
				    				newAccountAttrib.add(new Account_Attribute__c(Account__c = accountId,Attribute__c = attId,Contact__c = contactId));
			    				}
		    				}
		    				if(addRefToAllAccountsRBI && contactAccountRefMap != null && contactAccountRefMap.containsKey(contactId) && contactAccountRefMap.get(contactId).size() > 0){
			    				set<Id> duplicaterefIds = new set<Id>();
			    				for(Referenceability__c ref : contactAccountRefMap.get(contactId)){
			    					if(!duplicaterefIds.contains(ref.Referenceability_Type__c)){
				    					if(ref.Account__c == null){
				    						ref.Account__c = accountId;
				    						newAccountRefs.add(ref);
				    						duplicaterefIds.add(ref.Referenceability_Type__c);
				    					}
				    					else{
				    						duplicaterefIds.add(ref.Referenceability_Type__c);
				    						newAccountRefs.add(new Referenceability__c(Account__c = accountId,Contact__c = contactId, Referenceability_Type__c = ref.Referenceability_Type__c, Comment__c = ref.Comment__c, Verified__c = ref.Verified__c, Status__c = ref.Status__c));
				    					}
			    					}
			    				}
		    				}
		    			}
		    		}
	    		}
	    	}
	    	//iterate all contacts and their related accounts to create contact attributes
	    	for(Id accountId : accountContactMap.keySet()){
	    		if(accountrbiMap != null && accountrbiMap.containsKey(accountId) && accountrbiMap.get(accountId).Is_Referenceable__c && 
	    			(accountrbiMap.get(accountId).Referenceability_Status__c == ConstantsController.ACTIVE || 
	    			accountrbiMap.get(accountId).Referenceability_Status__c == ConstantsController.CAUTION)){
		    		for(Id contactId : accountContactMap.get(accountId)){
		    			if(contactrbiMap != null && accountContactAttMap != null && accountContactAttMap.containsKey(accountId) && accountContactAttMap.get(accountId).size() > 0
		    				&& contactrbiMap.containsKey(contactId) && contactrbiMap.get(contactId).Is_Referenceable__c && 
		    				(contactrbiMap.get(contactId).Referenceability_Status__c == ConstantsController.ACTIVE || 
		    				contactrbiMap.get(contactId).Referenceability_Status__c == ConstantsController.CAUTION)){
		    				boolean inheritAttributefromAllAccountsRBI = (contactrbiMap.get(contactId).Inherit_Attributes_from_All_Accounts__c ? true : (contactrbiMap.get(contactId).Inherit_Attributes_from_Primary_Account__c ? false : (inheritAttributefromAllAccounts)));
		    				if(inheritAttributefromAllAccountsRBI){
			    				for(Id attId : accountContactAttMap.get(accountId)){
				    				newContctAttrib.add(new Contact_Attribute__c(From_Account__c = true,Attribute__c = attId,Contact__c = contactId,Account__c = accountId));
			    				}
		    				}
		    			}
		    		}
	    		}
	    	}
	    	if (newAccountAttrib.size() > 0) {
	            ConstantsController.addAttributesToContact = false;
	            ConstantsController.addAttributesToContent = false;
	            WithoutSharingHelperController.upsertAccountAttributes(newAccountAttrib);
	        }
	        if (newContctAttrib.size() > 0) {
                ConstantsController.fromAccount = true;
                WithoutSharingHelperController.upsertContactAttributes(newContctAttrib);
            }
            if (newAccountRefs.size() > 0) {
                WithoutSharingHelperController.upsertReferenceabilities(newAccountRefs);
            }
    	}
    }
    
    
    /**
     * Method called on after delete of Shared Contact
     */
    global static void onAfterDelete(list < sObject > oldList) {
    	
    	set<string> contactIdset = new set<string>();
    	set<string> accountIdset = new set<string>();
    	map<Id, set<Id>> contactAccountMap = new map<Id, set<Id>>();
    	map<Id, set<Id>> accountContactMap = new map<Id, set<Id>>();
    	map<Id, set<Id>> contactAccountAttMap = new map<Id, set<Id>>();
    	map<Id, set<Id>> accountContactAttMap = new map<Id, set<Id>>();
    	map<Id, Reference_Basic_Information__c> contactrbiMap = new map<Id, Reference_Basic_Information__c>();
    	map<Id, Reference_Basic_Information__c> accountrbiMap = new map<Id, Reference_Basic_Information__c>();
    	list < Account_Attribute__c > deleteAccountAttrib = new list < Account_Attribute__c > ();
    	list < Contact_Attribute__c > deleteContctAttrib = new list < Contact_Attribute__c > ();
    	list < Referenceability__c > deleteAccountRefs = new list < Referenceability__c > ();
    	Custom_Settings__c cs = UtilityController.getCustomSettings();
    	if(cs.Shared_Contact_Field__c != null && cs.Shared_Contact_Field__c != '' && cs.Shared_Account_Field__c != null && cs.Shared_Account_Field__c != ''){
	    	for(sObject sharedContact : oldList){
	    		string contactId = string.valueOf(sharedContact.get(cs.Shared_Contact_Field__c));
	    		string accountId = string.valueOf(sharedContact.get(cs.Shared_Account_Field__c));
				contactIdset.add(contactId);
				accountIdset.add(accountId);
				if(contactAccountMap != null && !contactAccountMap.containsKey(contactId))
					contactAccountMap.put(contactId , new set<Id>());
				contactAccountMap.get(contactId).add(accountId);
				if(accountContactMap != null && !accountContactMap.containsKey(accountId))
					accountContactMap.put(accountId , new set<Id>());
				accountContactMap.get(accountId).add(contactId);
	    	}
	    	//get related all accounts with their profile and account attributes
	    	for(Account acc : WithoutSharingHelperController.getAccountRecordsWithAllRelatedRecordsSharedContactonDelete(accountIdset,contactIdset)){
	    		if(accountContactMap != null && accountContactMap.containsKey(acc.Id) && accountContactMap.get(acc.Id).size() > 0){
		    		for(Account_Attribute__c accAtt : acc.Account_Attributes__r){
		    			if(accountContactMap.get(acc.Id).contains(accAtt.Contact__c)){
		    				deleteAccountAttrib.add(accAtt);
		    			}
		    		}
		    		for(Referenceability__c ref : acc.Referenceabilities__r){
		    			if(accountContactMap.get(acc.Id).contains(ref.Contact__c)){
		    				deleteAccountRefs.add(ref);
		    			}
		    		}
	    		}
	    	}
	    	//get related all contacts with their profile and account attributes
	    	for(Contact con : WithoutSharingHelperController.getCntactRecordsWithAllRelatedRecordsSharedContactonDelete(contactIdset)){
	    		if(contactAccountMap != null && contactAccountMap.containsKey(con.Id) && contactAccountMap.get(con.Id).size() > 0){
		    		for(Contact_Attribute__c conAtt : con.Contact_Attributes__r){
		    			if(contactAccountMap.get(con.Id).contains(conAtt.Account__c)){
		    				deleteContctAttrib.add(conAtt);
		    			}
		    		}
	    		}
	    	}
	    	if (deleteAccountAttrib.size() > 0) {
	    		ConstantsController.shouldAccountAttributeDeleteOfContact = true;
	            WithoutSharingHelperController.deleteAccountAttributes(deleteAccountAttrib);
	        }
	        if (deleteContctAttrib.size() > 0) {
	        	ConstantsController.deleteAttributFromContact = true;
	            WithoutSharingHelperController.deleteContactAttributes(deleteContctAttrib);
	        }
	        if (deleteAccountRefs.size() > 0) {
	            WithoutSharingHelperController.deleteReferenceabilities(deleteAccountRefs);
	        }
    	}
    
    }
}