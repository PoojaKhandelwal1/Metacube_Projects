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
public with sharing class AccountAttributeSharedTriggerHandler {
    
    private static Custom_Settings__c cs = UtilityController.getCustomSettings();
    private static List<Contact_Attribute__c> contactsAttsToBeDel;
    private static List<Content_Attribute__c> contentsAttsToBeDel;
    
    /**
     *	Method called on before insert of Account Attribute
     */
    public static void onBeforeInsert(List<Account_Attribute__c> newAccountAttributes) {
    	Set<String> accountIds = new Set<String>();
        Set<Id> AttribIds = new Set<Id>();
        Set<String> allaccountIds = new Set<String>();
        
        for (Account_Attribute__c att : newAccountAttributes) {
            allaccountIds.add(att.Account__c);
            if (att.Account__c != null && att.Contact__c == null && att.Reference_Content__c == null) {
                accountIds.add(att.Account__c);
            }
        }
        List<Account_Attribute__c> accountAttList = new List<Account_Attribute__c>();
        Map<Id, Set<Id>> oldAccuntAttrib = new Map<Id, Set<Id>>();
        Map<Id, Reference_Basic_Information__c> accountMap = new Map<Id, Reference_Basic_Information__c>();
        Map<String, List<Account_Attribute__c>> accountAttributesMap = new Map<String, List<Account_Attribute__c>>();
        
        for (Account_Attribute__c aa : WithoutSharingHelperController.getAllAccountAttributesOfAccount(accountIds)) {
        	if (!accountAttributesMap.containsKey(aa.Account__c)) {
        		accountAttributesMap.put(aa.Account__c, new List<Account_Attribute__c>());
        	}
    		accountAttributesMap.get(aa.Account__c).add(aa);
        }
        for (Account account : WithoutSharingHelperController.getAccountRecordsWithAllRBIAndAtt(allaccountIds)) {
            for (Reference_Basic_Information__c rbiAccount : account.Reference_Basic_Informations__r) {
                if (rbiAccount.Contact__c == null) {
                	accountMap.put(rbiAccount.Account__c, rbiAccount);
                }
            }
            if (accountIds.contains(account.Id) &&
            	accountAttributesMap.containsKey(account.Id) &&
            	accountAttributesMap.get(account.Id) != null) {
                
                for (Account_Attribute__c a : accountAttributesMap.get(account.Id)) {
                    if (a.Contact__c == null && a.Reference_Content__c == null) {
                        accountAttList.add(a);
                    }
                }
            }
        }
        if (accountIds.size() != 0) {
        	for (Account_Attribute__c a : accountAttList) {
                if (oldAccuntAttrib.get(a.Account__c) == null) {
                    oldAccuntAttrib.put(a.Account__c, new Set<Id>());
                }
                oldAccuntAttrib.get(a.Account__c).add(a.Attribute__c);
            }
            for (Account_Attribute__c a : newAccountAttributes) {
                if (oldAccuntAttrib.get(a.Account__c) != null && oldAccuntAttrib.get(a.Account__c).contains(a.Attribute__c)) {
                    a.addError(System.Label.Account_Attribute);
                }
            }
        }
        for (Account_Attribute__c att : newAccountAttributes) {
            att.Reference_Basic_Information__c = (accountMap.containsKey(att.Account__c) && accountMap.get(att.Account__c) != null ? accountMap.get(att.Account__c).Id : null);
        }
    }
    
    /**
     *	Method called on after insert of Account Attribute
     */
    public static void onAfterInsert(List<Account_Attribute__c> newAccountAttributes,
    									Map<Id, Account_Attribute__c> newAccountAttributeMap) {
        
        Set<String> accountIds = new Set<String>();
        Set<String> attribNames = new Set<String>();
        Set<Id> accountNotToBeUpdated = new Set<Id>();
        List<Reference_Basic_Information__c> updateAccounts = new List<Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> accounts = new Map<Id, Reference_Basic_Information__c>();
        Map<Id, List<Account_Attribute__c>> accountAttrib = new Map<Id, List<Account_Attribute__c>>();
        Set<String> attIds = new Set<String>();
        Map<String, String> labelIds = new Map<String, String>();
        Map<String, Set<String>> attLabel = new Map<String, Set<String>>();
        Map<String, String> attLabelName = new Map<String, String>();
        Set<String> checkForParentAttToBeAdded = new Set<String>();
        List<Account_Reference_Content__c> accountRefContents = new List<Account_Reference_Content__c>();
        Map<String, List<Account_Attribute__c>> accountAttributesMap = new Map<String, List<Account_Attribute__c>>();
        
        for (Account_Attribute__c a : newAccountAttributes) {
            if (a.Account__c != null) {
                accountIds.add(a.Account__c);
            }
            if (a.Contact__c != null || a.Reference_Content__c != null) {
                accountNotToBeUpdated.add(a.Account__c);
            }
        }
        for (Account_Attribute__c aa : WithoutSharingHelperController.getAllAccountAttributesOfAccount(accountIds)) {
        	if (!accountAttributesMap.containsKey(aa.Account__c)) {
        		accountAttributesMap.put(aa.Account__c, new List<Account_Attribute__c>());
        	}
    		accountAttributesMap.get(aa.Account__c).add(aa);
        }
        for (Account acc : WithoutSharingHelperController.getAccountRecordsWithAllRBIAndAtt(accountIds)) {
        	for (Account_Reference_Content__c arc : acc.Account_Reference_Contents__r) {
                accountRefContents.add(arc);
            }
            for (Reference_Basic_Information__c rbi : acc.Reference_Basic_Informations__r) {
                if (rbi.Contact__c == null) {
                    accounts.put(acc.Id, rbi);
                }
            }
            if (!accounts.containsKey(acc.Id)) {
                accounts.put(acc.Id, new Reference_Basic_Information__c(Account__c = acc.Id));
            }
            if (!accountAttrib.containsKey(acc.Id)) {
                accountAttrib.put(acc.Id, new List<Account_Attribute__c>());
            }
        	if (accountAttributesMap.containsKey(acc.Id) && accountAttributesMap.get(acc.Id) != null) {
	            for (Account_Attribute__c aa : accountAttributesMap.get(acc.Id)) {
	                accountAttrib.get(acc.Id).add(aa);
	                if (aa.Attribute__r.Level__c > 1 && newAccountAttributeMap.containsKey(aa.Id)) {
	                    checkForParentAttToBeAdded.add(aa.Id);
	                }
	                attIds.add(aa.Attribute__c);
	            }
	        }
        }
        if (attIds.size() > 0) {
            for (Attributes_Labels__c attL : WithoutSharingHelperController.fetchAttributeLabels(attIds)) {
                if (!attLabel.containsKey(attL.Attribute__c)) {
                	attLabel.put(attL.Attribute__c, new Set<String>());
                }
            	attLabel.get(attL.Attribute__c).add('F' + String.valueOf(attL.Label__r.Filter_no__c) + 'F');
                attLabelName.put(attL.Attribute__c, (attL.Attribute__r.Root_Parent__c != null ? attL.Attribute__r.Root_Parent__c : ''));
            }
        }
		for (Id accuntId : accountAttrib.keySet()) {
			//if(ConstantsController.isCopyNominationDetailProcess && accounts.containsKey(accuntId) && accounts.get(accuntId).Id != null)
				//ConstantsController.RBIIds.add(accounts.get(accuntId).Id);
			if (accounts.containsKey(accuntId) && !ConstantsController.isCopyNominationDetailProcess) {
				Reference_Basic_Information__c rbi = UtilityController.setFiltersForAccount(accounts.get(accuntId),
																							accountAttrib.get(accuntId),
																							attLabel,
																							attLabelName);
				if (rbi.Reference_Program_Candidate__c == false &&
					rbi.Is_Referenceable__c == false &&
					!accountNotToBeUpdated.contains(accuntId)) {
                    
                    rbi.Is_Referenceable__c = true;
                    rbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                } else if (rbi.Reference_Program_Candidate__c == false &&
                			rbi.Is_Referenceable__c == false &&
                			ConstantsController.addAttributesToAccount) {
                    
                    rbi.Is_Referenceable__c = true;
                    rbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                }
                //for copy Nomination Detail Page
                if (ConstantsController.isCopyNominationDetailProcess && !rbi.Is_Referenceable__c) {
                    rbi.Is_Referenceable__c = true;
                    rbi.Reference_Program_Candidate__c = false;
                    rbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                }
				updateAccounts.add(rbi);
			}
		}
		if (updateAccounts.size() > 0) {
			/*
             * for --> ReferenceEdge Attribute, Mapped Attribute Reporting question
             * set Reference_Basic_Information__c in Account Attribute
             * by Rekha
             */
            ConstantsController.updateRBIInAccAttributes = true;
            WithoutSharingHelperController.upsertRBI(updateAccounts);
        }
        if (ConstantsController.addAttributesToContact) {
            addAttributesToContact(newAccountAttributes, accountAttrib);
    	}
    	if (ConstantsController.addAttributesToContent) {
            addAttributesToReferenceContent(newAccountAttributes, accountAttrib, accountRefContents);
    	}
        if (ConstantsController.addParentToAccount && checkForParentAttToBeAdded.size() > 0) {
            addParentAttribToAccount(newAccountAttributes, newAccountAttributeMap, accountAttrib);
        }
    }
    
    /**
     *	Method to add Attributes on Reference Content
     */
    static void addAttributesToReferenceContent(List<Account_Attribute__c> accountAttributes,
    												Map<Id, List<Account_Attribute__c>> accountAttrib,
    												List<Account_Reference_Content__c> accountRefContents) {
    	
    	Map<Id, Set<Id>> contentAttribMap = new Map<Id, Set<Id>>();
        Set<Id> contentIds = new Set<Id>();
        Map<Id, Set<Id>> accountcontentMap = new Map<Id, Set<Id>>();
        List<Content_Attribute__c> newContentAttrib = new List<Content_Attribute__c>();
        Set<Id> accountIds = new Set<Id>();
        Content_Attribute__c tempContentObj;
        if (accountAttributes != null) {
            for (Account_Attribute__c aT : accountAttributes) {
                if (aT.Inheritable__c == true) {
                    accountIds.add(aT.Account__c);
                    accountcontentMap.put(aT.Account__c, new Set<Id>());
                }
            }
        }
        if (accountIds.size() > 0) {
            for (Account_Reference_Content__c tempObj : accountRefContents) {
                if (accountIds.contains(tempObj.Account__c)) {
                    if (!accountcontentMap.containsKey(tempObj.Account__c)) {
                        accountcontentMap.put(tempObj.Account__c, new Set<Id>());
                    } else {
                        accountcontentMap.get(tempObj.Account__c).add(tempObj.Reference_Content__c);
                    }
                    contentAttribMap.put(tempObj.Reference_Content__c, new Set<Id>());
                }
            }
            if (contentAttribMap.size() > 0) {
                for (Content_Attribute__c tempObj : [Select Reference_Content__c, Attribute__c From Content_Attribute__c where Reference_Content__c In :contentAttribMap.keySet()]) {
                    contentAttribMap.get(tempObj.Reference_Content__c).add(tempObj.Attribute__c);
                }
            }
            for (Account_Attribute__c aT : accountAttributes) {
                if (accountcontentMap != null &&
                	accountcontentMap.containsKey(aT.Account__c) &&
                	accountcontentMap.get(aT.Account__c) != null &&
                	aT.Inheritable__c == true) {
                    
                    for (Id cntcId : accountcontentMap.get(aT.Account__c)) {
                        if (contentAttribMap.get(cntcId) != null && !contentAttribMap.get(cntcId).contains(aT.Attribute__c)) {
                            tempContentObj = new Content_Attribute__c();
                            tempContentObj.Reference_Content__c = cntcId;
                            tempContentObj.Attribute__c = aT.Attribute__c;
                            tempContentObj.Account__c = aT.Account__c;
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
    }
    
    /**
     *	Method to add Attributes on Contact
     */
    private static void addAttributesToContact(List<Account_Attribute__c> accountAttributes,
    												Map<Id, List<Account_Attribute__c>> accountAttrib) {
    	
    	Map<String, Set<String>> contactAttribMap = new Map<String, Set<String>>();
        Map<Id, Set<Id>> accountContactMap = new Map<Id, Set<Id>>();
        Set<String> accountIds = new Set<String>();
        Contact_Attribute__c tempObj;
        Map<Id, Reference_Basic_Information__c> contactRBI = new Map<Id, Reference_Basic_Information__c>();
        List<Contact_Attribute__c> newContctAttrib = new List<Contact_Attribute__c>();
        Set<Id> sharedContactIds = new Set<Id>();
        List<Contact> activeContactsList = new List<Contact>();
        
        if (accountAttributes != null) {
            for (Account_Attribute__c aT : accountAttributes) {
                if (aT.Inheritable__c == true) {
                    accountIds.add(aT.Account__c);
                    accountContactMap.put(aT.Account__c, new Set<Id>());
                }
            }
        }
        String objectName = cs.Shared_Contact_Object__c;
        String accountField = cs.Shared_Account_Field__c;
        String contactField = cs.Shared_Contact_Field__c;
        Set<Id> accountIdTempSet = accountContactMap.keySet();
        if(accountField != null && accountField != '' && contactField != null && contactField != ''){
	        String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName
	        						 + ' WHERE ' + accountField + ' IN :accountIdTempSet';
	        List<sObject> objectList = Database.query(query);
	        if (objectList != null && objectList.size() > 0) {
	    		for (sObject obj : objectList) {
	    			if (accountContactMap.containsKey((String)obj.get(accountField))) {
	    				accountContactMap.get((String)obj.get(accountField)).add((String)obj.get(contactField));
	    			}
	    		}
	        }
        }
        if (accountIds.size() > 0) {
        	for (Contact c : WithoutSharingHelperController.getContactWithRelatedRecords(accountIds)) {
        		accountContactMap.get(c.AccountId).add(c.Id);
                contactAttribMap.put(c.Id, new Set<String>());
                
                for (Contact_Attribute__c cA : c.Contact_Attributes__r) {
                    contactAttribMap.get(cA.contact__c).add(string.valueOf(cA.Attribute__c) + ''
                    											+ (cA.Account__c != null ? string.valueOf(cA.Account__c) : ''));
                }
                if (c.Reference_Basic_Informations__r.size() > 0) {
                    contactRBI.put(c.Id, c.Reference_Basic_Informations__r[0]);
                }
        	}
        	if (accountContactMap != null &&
				accountContactMap.keySet().size() > 0) {
				
				for (String accountId : accountContactMap.keySet()) {
	        		for (String contactId : accountContactMap.get(accountId)) {
	        			contactAttribMap.put(contactId, new Set<String>());
	        		}
	        	}
	        	activeContactsList = WithoutSharingHelperController.activateContactRecords(contactAttribMap.keySet());
	        	
	        	if (activeContactsList != null && activeContactsList.size() > 0) {
	        		for (Contact con : activeContactsList) {
	        			for (Contact_Attribute__c cA : con.Contact_Attributes__r) {
		                    contactAttribMap.get(cA.contact__c).add(string.valueOf(cA.Attribute__c) + ''
                    													+ (cA.Account__c != null ? string.valueOf(cA.Account__c) : ''));
		                }
		                if (con.Reference_Basic_Informations__r.size() > 0) {
	                    	contactRBI.put(con.Id, con.Reference_Basic_Informations__r[0]);
		                }
	        		}
	        	}
			}
        	for (Account_Attribute__c aT : accountAttributes) {
        		if (aT.Reference_Content__c == null && aT.Inheritable__c == true) {
        			if (accountContactMap != null &&
        				accountContactMap.containsKey(aT.Account__c) &&
        				accountContactMap.get(aT.Account__c) != null) {
        				for (Id cntcId : accountContactMap.get(aT.Account__c)) {
        					boolean inheritAttFromAllAcc = (contactRBI.containsKey(cntcId) && contactRBI.get(cntcId).Inherit_Attributes_from_All_Accounts__c ? true : (contactRBI.containsKey(cntcId) && contactRBI.get(cntcId).Inherit_Attributes_from_Primary_Account__c ? false : (cs.Inherit_Attributes_from_All_Accounts__c)));
        					if(inheritAttFromAllAcc ? true : (contactRBI.containsKey(cntcId) ? contactRBI.get(cntcId).Account__c == aT.Account__c : false)){
	        					if (contactRBI.containsKey(cntcId) &&
	        						contactRBI.get(cntcId).Is_Referenceable__c &&
	        						contactAttribMap.get(cntcId) != null) {
	        						
	        						if (!contactAttribMap.get(cntcId).contains(string.valueOf(aT.Attribute__c) + ''
	        																		+ (aT.Account__c != null ? string.valueOf(aT.Account__c) : ''))) {
	        							tempObj = new Contact_Attribute__c();
	        							tempObj.Account__c = aT.Account__c;
		                                tempObj.Contact__c = cntcId;
		                                tempObj.Attribute__c = aT.Attribute__c;
		                                tempObj.From_Account__c = true;
	                                	newContctAttrib.add(tempObj);
	        						} 
	        					} else if (contactRBI.containsKey(cntcId) &&
	        								contactRBI.get(cntcId).Is_Referenceable__c &&
	        								contactAttribMap.get(cntcId) == null) {
	                                
	                                tempObj = new Contact_Attribute__c();
	    							tempObj.Account__c = aT.Account__c;
	                                tempObj.Contact__c = cntcId;
	                                tempObj.Attribute__c = aT.Attribute__c;
	                                tempObj.From_Account__c = true;
	                            	newContctAttrib.add(tempObj);
	                            }
        					}
        				}
        			}
        		}
        	}
        	if (newContctAttrib.size() > 0) {
                ConstantsController.fromAccount = true;
                WithoutSharingHelperController.upsertContactAttributes(newContctAttrib);
            }
        }
    }
    
    /**
     *	Method to add Parent Attributes on Account
     */
    private static void addParentAttribToAccount(List<Account_Attribute__c> accountAttributes,
    												Map<Id, Account_Attribute__c> newMap,
    												Map<Id, List<Account_Attribute__c>> accountAttrib) {
    	
    	Set<Id> attribIds = new Set<Id>();
        List<Account_Attribute__c> newAccuntAttrib = new List<Account_Attribute__c>();
        Account_Attribute__c tempObj;
        Map<Id, List<String>> attribParentMap = new Map<Id, List<String>>();
        Map<String, Set<Id>> accountAttribMap = new Map<String, Set<Id>>();
        Set<String> accountAttribDuplicacy = new Set<String>();
        Set<String> parentAttribIds = new Set<String>();
        Set<Id> parentToBeAdded = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        if (accountAttributes != null) {
            for (Account_Attribute__c aT : accountAttributes) {
                attribIds.add(aT.Attribute__c);
                if (aT.Contact__c != null) {
                    accountAttribMap.put(aT.Account__c + ',' + aT.Contact__c, new Set<Id>());
                }
                if (aT.Reference_Content__c != null) {
                    accountAttribMap.put(aT.Account__c + ',' + aT.Reference_Content__c, new Set<Id>());
                }
                if (aT.Contact__c == null && aT.Reference_Content__c == null) {
                    accountAttribMap.put(aT.Account__c, new Set<Id>());
                }
                accountIds.add(aT.Account__c);
            }
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
        if (accountAttrib != null) {
            for (Id accId : accountAttrib.keySet()) {
                for (Account_Attribute__c aT : accountAttrib.get(accId)) {
                    if (aT.Contact__c != null) {
                        if (accountAttribMap.containsKey(aT.Account__c + ',' + aT.Contact__c)) {
                            accountAttribMap.get(aT.Account__c + ',' + aT.Contact__c).add(aT.Attribute__c);
                        }
                    }
                    if (aT.Reference_Content__c != null) {
                        if (accountAttribMap.containsKey(aT.Account__c + ',' + aT.Reference_Content__c)) {
                            accountAttribMap.get(aT.Account__c + ',' + aT.Reference_Content__c).add(aT.Attribute__c);
                        }
                    }
                    if (aT.Contact__c == null && aT.Reference_Content__c == null) {
                        if (accountAttribMap.containsKey(aT.Account__c)) {
                            accountAttribMap.get(aT.Account__c).add(aT.Attribute__c);
                        }
                    }
                }
            }
        }
        if (newMap != null) {
        	for (Id accAttId : newMap.keySet()) {
        		if (attribParentMap.get(newMap.get(accAttId).Attribute__c) != null) {
        			for (Id attId : attribParentMap.get(newMap.get(accAttId).Attribute__c)) {
        				if (parentToBeAdded.contains(attId)) {
        					//natively added to the Account
                            if (newMap.get(accAttId).Contact__c == null && newMap.get(accAttId).Reference_Content__c == null) {
                            	if (accountAttribMap.get(newMap.get(accAttId).Account__c) != null &&
                            		!accountAttribMap.get(newMap.get(accAttId).Account__c).contains(attId) &&
                            		!accountAttribDuplicacy.contains(newMap.get(accAttId).Account__c
                            											+ ' ' + newMap.get(accAttId).Contact__c
                            											+ ' ' + newMap.get(accAttId).Reference_Content__c
                            											+ ' ' + attId)) {
                            		
                            		tempObj = new Account_Attribute__c();
                                    tempObj.Account__c = newMap.get(accAttId).Account__c;
                                    tempObj.Attribute__c = attId;
                                    tempObj.Inheritable__c = newMap.get(accAttId).Inheritable__c;
                                    newAccuntAttrib.add(tempObj);
                                    accountAttribDuplicacy.add(newMap.get(accAttId).Account__c
                                    								+ ' ' + newMap.get(accAttId).Contact__c
                                    								+ ' ' + newMap.get(accAttId).Reference_Content__c
                                    								+ ' ' + attId);
                            	}
                            } else if (newMap.get(accAttId).Contact__c != null) {	//trickle up from contact
                                if (accountAttribMap.get(newMap.get(accAttId).Account__c + ',' + newMap.get(accAttId).Contact__c) != null &&
                                	!accountAttribMap.get(newMap.get(accAttId).Account__c + ',' + newMap.get(accAttId).Contact__c).contains(attId) &&
                                	!accountAttribDuplicacy.contains(newMap.get(accAttId).Account__c
                                										+ ' ' + newMap.get(accAttId).Contact__c
                                										+ ' ' + newMap.get(accAttId).Reference_Content__c
                                										+ ' ' + attId)) {
                                    
                                    tempObj = new Account_Attribute__c();
                                    tempObj.Account__c = newMap.get(accAttId).Account__c;
                                    tempObj.Attribute__c = attId;
                                    tempObj.Contact__c = newMap.get(accAttId).Contact__c;
                                    newAccuntAttrib.add(tempObj);
                                    accountAttribDuplicacy.add(newMap.get(accAttId).Account__c
                                    								+ ' ' + newMap.get(accAttId).Contact__c
                                    								+ ' ' + newMap.get(accAttId).Reference_Content__c
                                    								+ ' ' + attId);
                                }
                            } else if (newMap.get(accAttId).Reference_Content__c != null) {	//trickle up from reference content
                                if (accountAttribMap.get(newMap.get(accAttId).Account__c + ',' + newMap.get(accAttId).Reference_Content__c) != null &&
                                	!accountAttribMap.get(newMap.get(accAttId).Account__c + ',' + newMap.get(accAttId).Reference_Content__c).contains(attId) &&
                                	!accountAttribDuplicacy.contains(newMap.get(accAttId).Account__c
                                										+ ' ' + newMap.get(accAttId).Contact__c
                                										+ ' ' + newMap.get(accAttId).Reference_Content__c
                                										+ ' ' + attId)) {
                                    
                                    tempObj = new Account_Attribute__c();
                                    tempObj.Account__c = newMap.get(accAttId).Account__c;
                                    tempObj.Attribute__c = attId;
                                    tempObj.Reference_Content__c = newMap.get(accAttId).Reference_Content__c;
                                    newAccuntAttrib.add(tempObj);
                                    accountAttribDuplicacy.add(newMap.get(accAttId).Account__c
                                    								+ ' ' + newMap.get(accAttId).Contact__c
                                    								+ ' ' + newMap.get(accAttId).Reference_Content__c
                                    								+ ' ' + attId);
                                }
                            }
        				}
        			}
        		}
        	}
        }
        if (newAccuntAttrib.size() > 0) {
            ConstantsController.addParentToAccount = false;
            WithoutSharingHelperController.upsertAccountAttributes(newAccuntAttrib);
        }
    }
    
    /**
     *	Method called on before delete of Account Attribute
     */
    public static void onBeforeDelete(List<Account_Attribute__c> oldAccountAttributes,
    									Map<Id, Account_Attribute__c> oldAccountAttributeMap) {
    	
    	Set<String> attribIds = new Set<String>();
        Set<String> accuntIds = new Set<String>();
        Map<Id, Set<Id>> accuntContacts = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> accuntContents = new Map<Id, Set<Id>>();
        Map<Id, Set<String>> contactAttribMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> accuntAttribMap = new Map<Id, Set<String>>();
        Map<Id, Set<Id>> attributesOnAccountMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> contentAttributeMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> accountAttribOnContent = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> contactAccountMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> accountAttFromMappForDelete = new Map<Id, Set<Id>>();
        
        contactsAttsToBeDel = new List<Contact_Attribute__c>();
        contentsAttsToBeDel = new List<Content_Attribute__c>();
        
        for (Account_Attribute__c a : oldAccountAttributes) {
        	if (a.Contact__c != null && ConstantsController.shouldAccountAttributeDeleteOfContact == false && !ConstantsController.isCallFromBatchRemoveDuplicateRBI) {
        		a.addError(System.Label.Attribute_removal_to_associated_Contact_Msg);
        	} else if (a.Reference_Content__c != null && ConstantsController.shouldAccountAttributeDeleteOfContent == false && !ConstantsController.isCallFromBatchRemoveDuplicateRBI) {
        		a.addError(System.Label.Attribute_removal_to_associated_RefContent_Msg);
        	} else if (a.Contact__c == null && a.Reference_Content__c == null && a.Is_fromMapping__c == false) {
                attribIds.add(a.Attribute__c);
                accuntIds.add(a.Account__c);
                attributesOnAccountMap.put(a.Account__c, new Set<Id>());
            }
            if (a.Contact__c == null && a.Reference_Content__c == null && a.Is_fromMapping__c && a.Inheritable__c) {
                attribIds.add(a.Attribute__c);
                accuntIds.add(a.Account__c);
                if (!accountAttFromMappForDelete.containsKey(a.Account__c)) {
                    accountAttFromMappForDelete.put(a.Account__c, new Set<Id>());
                }
                accountAttFromMappForDelete.get(a.Account__c).add(a.Attribute__c);
            }
        }
        
        //updated for duplicate attributes by Rekha on 18 june
        for (Account acc : [select Id,(Select Reference_Content__c, Account__c From Account_Reference_Contents__r), 
								(select Contact__r.name, Contact__r.Id, Account__c, Referenceability_Status__c 
								from Reference_Basic_Informations__r where Contact__c != null), 
								(select Account__c, Attribute__c, Attribute__r.Parent__c from Account_Attributes__r 
								where Attribute__r.Parent__c In: attribIds and contact__c = null and Reference_Content__c = null 
								and Id NOt In :oldAccountAttributes) from Account where Id In :accuntIds]) {
			
			for (Reference_Basic_Information__c rbiContact : acc.Reference_Basic_Informations__r) {
                if (!accuntContacts.containsKey(rbiContact.Account__c)) {
                    accuntContacts.put(rbiContact.Account__c, new Set<Id>());
                }
                contactAttribMap.put(rbiContact.Contact__r.Id, new Set<String>());
                accuntContacts.get(rbiContact.Account__c).add(rbiContact.Contact__r.Id);
                if (accountAttFromMappForDelete.containsKey(rbiContact.Account__c)) {
                    if(!contactAccountMap.containsKey(rbiContact.Contact__r.Id))
                    	contactAccountMap.put(rbiContact.Contact__r.Id, new Set<Id>());
                    contactAccountMap.get(rbiContact.Contact__r.Id).add(rbiContact.Account__c);
                }
            }
            for (Account_Attribute__c accatt : acc.Account_Attributes__r) {
                attributesOnAccountMap.get(accatt.Account__c).add(accatt.Attribute__c);
            }
            for (Account_Reference_Content__c acr : acc.Account_Reference_Contents__r) {
                if (!accuntContents.containsKey(acr.Account__c)) {
                    accuntContents.put(acr.Account__c, new Set<Id>());
                }
                accuntContents.get(acr.Account__c).add(acr.Reference_Content__c);
                contentAttributeMap.put(acr.Reference_Content__c, new Set<Id>());
            }
		}
		
        String objectName = cs.Shared_Contact_Object__c;
        String accountField = cs.Shared_Account_Field__c;
        String contactField = cs.Shared_Contact_Field__c;
        if(accountField != null && accountField != '' && contactField != null && contactField != ''){
	        String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName
	        						 + ' WHERE ' + accountField + ' IN :accuntIds';
	        
	        List<sObject> objectList = Database.query(query);
	        if (objectList != null && objectList.size() > 0) {
	        	for (sObject obj : objectList) {
	        		if (contactAccountMap != null &&
	        			!contactAccountMap.containsKey((String)obj.get(contactField))) {
	        			
	        			contactAccountMap.put((String)obj.get(contactField), new Set<Id>());
	        		}
		        	contactAccountMap.get((String)obj.get(contactField)).add((String)obj.get(accountField));
		        	contactAttribMap.put((String)obj.get(contactField), new Set<String>());
		        }
	        }
        }
        for (Contact_Attribute__c ca : [select Contact__c, Attribute__c, Account__c, From_Account__c
        								from Contact_Attribute__c
        								where Contact__c In :contactAttribMap.keySet()
        								and From_Account__c = true]) {
            
            contactAttribMap.get(ca.Contact__c).add(ca.Attribute__c);
            if (contactAccountMap != null &&
            	contactAccountMap.containsKey(ca.Contact__c) &&
            	contactAccountMap.get(ca.Contact__c) != null) {
                
                for (Id accId : contactAccountMap.get(ca.Contact__c)) {
                	if (accountAttFromMappForDelete != null &&
                		accountAttFromMappForDelete.containsKey(accId) &&
                		accountAttFromMappForDelete.get(accId) != null) {
                		
                		for (Id attId : accountAttFromMappForDelete.get(accId)) {
		                    if (ca.Attribute__c == attId &&
		                    	ca.Account__c == accId) {
		                        
		                        contactsAttsToBeDel.add(ca);
		                    }
		                }
                	}
                }
            }
        }
        //gather all the attributes which had trickled down on to the contacts
        for (Id aId : accuntContacts.keySet()) {
            for (Id cId : accuntContacts.get(aId)) {
                if (!accuntAttribMap.containsKey(aId)) {
                    accuntAttribMap.put(aId, new Set<String>());
                }
                if (contactAttribMap.get(cId) != null) {
                    accuntAttribMap.get(aId).addAll(contactAttribMap.get(cId));
                }
            }
        }
        //gather all the attributes which had trickled down on to the contents
        for (Id accId : accuntContents.keySet()) {
            for (Id contentId : accuntContents.get(accId)) {
                if (!accountAttribOnContent.containsKey(accId)) {
                    accountAttribOnContent.put(accId, new Set<Id>());
                }
                if (contentAttributeMap.get(contentId) != null) {
                    accountAttribOnContent.get(accId).addAll(contentAttributeMap.get(contentId));
                }
            }
        }
        for (Id accAttId : oldAccountAttributeMap.keySet()) {
            if (!oldAccountAttributeMap.get(accAttId).Is_fromMapping__c &&
            	accuntAttribMap.containsKey(oldAccountAttributeMap.get(accAttId).Account__c) &&
            	accuntAttribMap.get(oldAccountAttributeMap.get(accAttId).Account__c).contains(oldAccountAttributeMap.get(accAttId).Attribute__c) &&
            	ConstantsController.deleteAttributeFromAccount == true && 
                !ConstantsController.isCallFromBatchRemoveDuplicateRBI) {
                
                oldAccountAttributeMap.get(accAttId).addError(System.Label.Attribute_removal_to_associated_Contact_Msg);
            } else if (!oldAccountAttributeMap.get(accAttId).Is_fromMapping__c &&
            			accountAttribOnContent.containsKey(oldAccountAttributeMap.get(accAttId).Account__c) &&
            			accountAttribOnContent.get(oldAccountAttributeMap.get(accAttId).Account__c).contains(oldAccountAttributeMap.get(accAttId).Attribute__c) &&
            			ConstantsController.deleteAttributeFromAccount == true && 
                        !ConstantsController.isCallFromBatchRemoveDuplicateRBI) {
                
                oldAccountAttributeMap.get(accAttId).addError(System.Label.Attribute_removal_to_associated_Content_Msg);
            } else if (!oldAccountAttributeMap.get(accAttId).Is_fromMapping__c &&
            			attributesOnAccountMap.get(oldAccountAttributeMap.get(accAttId).Account__c) != null &&
            			attributesOnAccountMap.get(oldAccountAttributeMap.get(accAttId).Account__c).size() != 0 &&
            			ConstantsController.deleteAttributeFromAccount == true && 
                        !ConstantsController.isCallFromBatchRemoveDuplicateRBI) {
                
                oldAccountAttributeMap.get(accAttId).addError(System.Label.Attribute_removal_to_associated_Account_Msg);
            }
        }
    }
    
    /**
     *	Method called on after undelete of Account Attribute
     */
    public static void onAfterUndelete(List<Account_Attribute__c> newAccountAttributes) {
    	Set<Id> accountIds = new Set<Id>();
        Set<String> attIds = new Set<String>();
        Map<String, String> labelIds = new Map<String, String>();
        Map<String, Set<String>> attLabel = new Map<String, Set<String>>();
        Map<String, String> attLabelName = new Map<String, String>();
        List<Reference_Basic_Information__c> updateAccounts = new List<Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> accounts = new Map<Id, Reference_Basic_Information__c>();
        Map<Id, List<Account_Attribute__c>> accountAttrib = new Map<Id, List<Account_Attribute__c>>();
        Set<String> associatedAttributes;
        
        for (Account_Attribute__c a : newAccountAttributes) {
            if (a.Is_fromMapping__c) {
                a.addError(SYSTEM.LABEL.Account_Attribute_Undelete_Error);
            } else if (a.Account__c != null) {
                accountIds.add(a.Account__c);
            }
        }
        for (Reference_Basic_Information__c rbiAccount : WithoutSharingHelperController.fetchRBIds(accountIds)) {
            
            accounts.put(rbiAccount.Account__c, rbiAccount);
        }
        for (Account_Attribute__c a : [select Account__c, Attribute__r.Name from Account_Attribute__c where Account__c in :accountIds]) {
            if (!accountAttrib.containsKey(a.Account__c)) {
                accountAttrib.put(a.Account__c, new List<Account_Attribute__c>());
            }
            accountAttrib.get(a.Account__c).add(a);
            attIds.add(a.Attribute__c);
        }
        if (attIds.size() > 0) {
        	for (Attributes_Labels__c attL : WithoutSharingHelperController.fetchAttributeLabels(attIds)) {
	            if(!attLabel.containsKey(attL.Attribute__c)) {
                	attLabel.put(attL.Attribute__c, new Set<String>());
	            }
            	attLabel.get(attL.Attribute__c).add('F' + String.valueOf(attL.Label__r.Filter_no__c) + 'F');
	            attLabelName.put(attL.Attribute__c, (attL.Attribute__r.Root_Parent__c != null ? attL.Attribute__r.Root_Parent__c : ''));
            }
        }
        for (Id accuntId : accountAttrib.keySet()) {
        	Reference_Basic_Information__c rbi = UtilityController.setFiltersForAccount(accounts.get(accuntId),
        																				accountAttrib.get(accuntId),
        																				attLabel,
        																				attLabelName);
        	updateAccounts.add(rbi);
        }
        WithoutSharingHelperController.upsertRBI(updateAccounts);
    }
    
    /**
     *	Method called on after update of Account Attribute
     */
    public static void onAfterUpdate(List<Account_Attribute__c> newAccountAttributes,
    									Map<Id, Account_Attribute__c> newAccountAttributeMap,
    									Map<Id, Account_Attribute__c> oldAccountAttributeMap) {
    	
    	List<Account_Attribute__c> updatedList = new List<Account_Attribute__c>();
        Set<Id> attribIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account_Attribute__c> attribAccAttObj = new Map<Id, Account_Attribute__c>();
        
        if (ConstantsController.shouldAccountUpdate) {
            for (Account_Attribute__c accAtt : newAccountAttributes) {
                if (oldAccountAttributeMap.get(accAtt.Id).Inheritable__c == false &&
                	newAccountAttributeMap.get(accAtt.Id).Inheritable__c == true) {
                    
                    updatedList.add(accAtt);
                    attribAccAttObj.put(accAtt.Attribute__c, accAtt);
                    accountIds.add(accAtt.Account__c);
                }
            }
        }
        List<Account_Reference_Content__c> accountRefContents = [Select Reference_Content__c, Account__c 
        															From Account_Reference_Content__c
        															where Account__c In :accountIds];
        if (updatedList.size() > 0) {
            addAttributesToContact(updatedList, new Map<Id, List<Account_Attribute__c>>());
            addAttributesToReferenceContent(updatedList, new Map<Id, List<Account_Attribute__c>>(), accountRefContents);
            updateParentInheritable(attribAccAttObj, accountIds);
        }
    }
    
    /**
     *	Method to update Inheritable Parent Attribute
     */
    private static void updateParentInheritable(Map<Id, Account_Attribute__c> attribAccAttObj, Set<Id> accountIds) {
    	Map<Id, Set<String>> attribParentMap = new Map<Id, Set<String>>();
        List<Account_Attribute__c> updatedAttAccObj = new List<Account_Attribute__c>();
        
        for (Attribute__c att : [select parentIds__c, Id from Attribute__c where Id In :attribAccAttObj.keySet()]) {
            if (att.parentIds__c != null ) {
	            for (String parentId : att.parentIds__c.split(',')) {
	                if (!attribParentMap.containsKey(att.Id)) {
	                    attribParentMap.put(att.Id, new Set<String>());
	                }
	                attribParentMap.get(att.Id).add(parentId);
	            }
            }
        }
        for (Account_Attribute__c accAtt : [select Attribute__c, Inheritable__c, Account__c
        										from Account_Attribute__c where Account__c In :accountIds
        										and Reference_Content__c = null and Contact__c = null]) {
            
            for (Id attId: attribParentMap.keySet()) {
                for (String parentId: attribParentMap.get(attId)) {
                    if (parentId == accAtt.Attribute__c) {
                        accAtt.Inheritable__c = attribAccAttObj.get(attId).Inheritable__c;
                        updatedAttAccObj.add(accAtt);
                    }
                }
            }
        }
        if (updatedAttAccObj.size() > 0) {
            ConstantsController.shouldAccountUpdate = false;
            WithoutSharingHelperController.upsertAccountAttributes(updatedAttAccObj);
        }
    }
    
    /**
     *	Method called on after delete of Account Attribute
     */
    public static void onAfterDelete(List<Account_Attribute__c> oldAccountAttributes) {
    	Set<Id> accountIds = new Set<Id>();
        Set<String> attIds = new Set<String>();
        Map<String, String> labelIds = new Map<String, String>();
        Map<String, Set<String>> attLabel = new Map<String, Set<String>>();
        Map<String, String> attLabelName = new Map<String, String>();
        Map<Id, List<Account_Attribute__c>> accountAttrib = new Map<Id, List<Account_Attribute__c>>();
        List<Reference_Basic_Information__c> updateAccounts = new List<Reference_Basic_Information__c>();
        Map<Id, Reference_Basic_Information__c> accounts = new Map<Id, Reference_Basic_Information__c>();
        Set<String> associatedAttributes;
        
        for (Account_Attribute__c a : oldAccountAttributes) {
            if (a.Account__c != null) {
                accountIds.add(a.Account__c);
                accountAttrib.put(a.Account__c, new List<Account_Attribute__c>());
            }
        }
        for (Reference_Basic_Information__c rbiAccount : WithoutSharingHelperController.fetchRBIds(accountIds)) {
            
            accounts.put(rbiAccount.Account__c, rbiAccount);
        }
        for (Account_Attribute__c a : [select Account__c, Attribute__r.Name from Account_Attribute__c where Account__c in :accountIds]) {
            accountAttrib.get(a.Account__c).add(a);
            attIds.add(a.Attribute__c);
        }
        if (attIds.size() > 0) {
        	for (Attributes_Labels__c attL : WithoutSharingHelperController.fetchAttributeLabels(attIds)) {
	            if (!attLabel.containsKey(attL.Attribute__c)) {
                	attLabel.put(attL.Attribute__c, new Set<String>());
	            }
            	attLabel.get(attL.Attribute__c).add('F' + String.valueOf(attL.Label__r.Filter_no__c) + 'F');
	            attLabelName.put(attL.Attribute__c, (attL.Attribute__r.Root_Parent__c != null ? attL.Attribute__r.Root_Parent__c : ''));
            }
        }
        for (Id accuntId : accountAttrib.keySet()) {
        	if (accounts.containsKey(accuntId)) {
        		Reference_Basic_Information__c rbi = UtilityController.setFiltersForAccount(accounts.get(accuntId),
        																					accountAttrib.get(accuntId),
        																					attLabel,
        																					attLabelName);
        		updateAccounts.add(rbi);
        	}
        }
        if (updateAccounts.size() > 0) {
            WithoutSharingHelperController.upsertRBI(updateAccounts); 
        }
        List<Content_Attribute__c> deleteContentAtts = [select id from Content_Attribute__c where Id In :contentsAttsToBeDel];
        if (deleteContentAtts.size() > 0) {
            WithoutSharingHelperController.deleteContentAtt(deleteContentAtts);
        }
        List<Contact_Attribute__c> deleteContactAtts = WithoutSharingHelperController.getContactAttributes(contactsAttsToBeDel);
        if (deleteContactAtts.size() > 0) {
            WithoutSharingHelperController.deleteContactAttributes(deleteContactAtts);
        }
    }
}