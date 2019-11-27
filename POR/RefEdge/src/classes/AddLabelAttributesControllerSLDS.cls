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
 * Page: AddLabelAttributesSLDS
 * Description : this class used to add attributes on Account, Contact, Filter and Reference Content
 * Modified by: Rekha @1 April 2017
 */
public with sharing class AddLabelAttributesControllerSLDS extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
	public String objId { get; set; }
	public String PUMAccountId { get; set; }
	public String refRefreshId { get; set; }
	public String pageNo { get; set; }
     //REF-2111
    public Boolean isPreventSelectionOfMappedAttributes {get; set;}
	
	/**
     * Constructor
     */
    public AddLabelAttributesControllerSLDS() {
        Custom_Settings__c cs = UtilityController.getCustomSettings(); 
        isPreventSelectionOfMappedAttributes = cs.Prevent_selection_of_mapped_Attributes__c; 
    	objId = Apexpages.currentPage().getParameters().get('Id');
    	PUMAccountId = '';
        refRefreshId = '';
        pageNo = '';
        
        if (Apexpages.currentPage().getParameters().get('PUMAccountId') != null) {
        	PUMAccountId = Apexpages.currentPage().getParameters().get('PUMAccountId');
        }
        refRefreshId = Apexpages.currentPage().getParameters().get('refRefreshId');
        pageNo = Apexpages.currentPage().getParameters().get('pageno');
    }
    
    /**
     * RemoteAction to get all intial information
     */
    @RemoteAction
    public static InfoWrapper fetchInfo(String objId, String PUMAccountId, String refRefreshId) {
    	InfoWrapper infoWp = new InfoWrapper();
    	
    	try {
    		Id tempobjId = objId;
    		
    		if (objId.substring(0, 3) == '001') {
	            infoWp.accountId = objId;
	        } else if (objId.substring(0, 3) == '003') {
	            infoWp.contactId = objId;
	        } else {
	            Schema.SObjectType token = tempobjId.getSObjectType();
	            Schema.DescribeSObjectResult dr = token.getDescribe();
	            
	            if (dr.getName().contains('Label__c')) {
	                infoWp.labelId = objId;
	            } else {
	                infoWp.contentId = objId;
	            }
	        }
	        List<Attribute__c> listRootAtts = new List<Attribute__c> ();
	        Set<String> deleteAttIds = new Set<String>();
	        Custom_Settings__c cs = UtilityController.getCustomSettings();
	        Boolean addRefToAllAccountsRBI = cs.Roll_up_Attributes_to_All_Accounts__c;
	        Reference_Refresh__c refRefresh;
	        
	        if (refRefreshId != null && refRefreshId != '') {
	            List<Reference_Refresh__c> refRefreshs = WithoutSharingHelperController.getReferenceRefreshOnAddAtt(refRefreshId);
	            
	            if (refRefreshs.size() > 0) {
	                refRefresh = refRefreshs[0];
	                infoWp.accConObj = new AccountContactWrapper();
	                infoWp.accConObj.isFromProfileUpdate = true;
	                infoWp.refRefresh = new RefRefreshWrapper();
	                infoWp.refRefresh.quarantined = refRefresh.Quarantined__c;
	                infoWp.refRefresh.id = refRefresh.Id;
	                infoWp.refRefresh.ownerId = refRefresh.Reference_Refresh_Owner__c;
	                infoWp.refRefresh.accountId = refRefresh.Reference_Account__c;
	                
	                if (refRefresh.Quarantined__c) {
	                	
	                    for (Reference_Refresh_Update__c rru : refRefresh.Reference_Refresh_Updates__r) {
	                    	
		                    if (rru.Removed__c) {
		                        deleteAttIds.add(rru.RecordToBeDeletedId__c);
		                    }
		                    infoWp.refRefresh.quarantineUpdates.add( new ProfileUpdateDetailWrapper(rru));
		                    
		                    if (rru.Contact__c != null && rru.Added__c) {
	                			infoWp.refRefresh.alreadyCreatedPUAttforContact.add(rru.RecordsToBeInsertedId__c);
		                	} else if (rru.Account__c != null  && rru.Added__c) {
		                		infoWp.refRefresh.alreadyCreatedPUAttforAccount.add(rru.RecordsToBeInsertedId__c);
		                	}
		                }
	                }
	            }
	        }
	        
	        if (infoWp.labelId != null && infoWp.labelId != '') {
	            Label__c tempLabel = [SELECT Name, (SELECT Attribute__c, Attribute__r.Name FROM Attributes_Labels__r ORDER BY Attribute__r.Parent__r.Name) 
	            					FROM Label__c WHERE Id = :infoWp.labelId LIMIT 1][0];
	            infoWp.labelName = tempLabel.Name;
	            
	            for (Attributes_Labels__c al : tempLabel.Attributes_Labels__r) {
	            	infoWp.existingAtts.add(new ExistingAttributeWrapper(al.Attribute__c, al.Attribute__r.name, '', false, ''));
	            }
	            // added a field regarding #570
	            listRootAtts = [SELECT Id, Name, Level__c, Parent__c, Attribute_Mapping__c, Parent__r.Name, 
	        							(SELECT Id FROM Attributes__r LIMIT 1) FROM Attribute__c WHERE Level__c = 0 ORDER BY Name];
	        }
	        
	        if (infoWp.accountId != null && infoWp.accountId != '') {
	        	List<Account> accountList = new List<Account>();
        	
	            //changed for new object
	            if (refRefresh != null) {
	            	accountList = WithoutSharingHelperController.getAccountOnAddAtt(infoWp.accountId, deleteAttIds);
	            } else {
	            	infoWp.accConObj = new AccountContactWrapper();
	            	accountList = [SELECT Name, (SELECT Attribute__r.Name, Attribute__r.Parent__r.Name, Attribute__r.level__c, Is_fromMapping__c 
	            								FROM Account_Attributes__r WHERE Contact__c = null AND Reference_Content__c = null 
	            								ORDER BY Attribute__r.Parent__r.Name), 
	            								(SELECT Name, Account__c, Reference_Program_Candidate__c, Is_Referenceable__c, Referenceability_Status__c 
	            								FROM Reference_Basic_Informations__r WHERE Contact__c = null) 
	            								FROM Account WHERE Id = :infoWp.accountId LIMIT 1];
	            }
	        
	        	if (accountList.size() > 0) {
	        		Account tempAccount = accountList[0];
	        	
		            if (tempAccount.Reference_Basic_Informations__r.size() > 0) {
		                infoWp.accConObj.isAccountReferenceProgramMember = tempAccount.Reference_Basic_Informations__r[0].Is_Referenceable__c;
		                infoWp.accConObj.isAccountCandidate = tempAccount.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c;
		            }
		            infoWp.accountName = tempAccount.Name;
		            
		            for (Account_Attribute__c al : tempAccount.Account_Attributes__r) {
		            	infoWp.existingAtts.add(new ExistingAttributeWrapper(al.Attribute__c, al.Attribute__r.name, tempAccount.Name, al.Is_fromMapping__c, al.Id));
		            }
	        	}
	        	//added a field regarding #570 
	        	listRootAtts = [SELECT Id, Name, Level__c, Parent__c, Attribute_Mapping__c, Attribute_Mapping__r.Object__c, 
        									Attribute_Mapping__r.Field__c, Parent__r.Name, 
	        								(SELECT Id FROM Attributes__r LIMIT 1) FROM Attribute__c WHERE Level__c = 0 
	        								AND (Ref_Limit_to_Acct_or_Cntct__c = null
        									OR Ref_Limit_to_Acct_or_Cntct__c = '' OR
        									Ref_Limit_to_Acct_or_Cntct__c = 'Account')ORDER BY Name];
	        }
	        
	        if (infoWp.contactId != null && infoWp.contactId != '') {
	        	Set<String> accountIds = new Set<String>();
	        	List<Contact> contacts = new List<Contact>();
	        	
	            //changed for new object
	            if (refRefresh != null) {
	            	contacts = WithoutSharingHelperController.getContactOnAddAtt(infoWp.contactId, deleteAttIds);
	            } else {
	            	infoWp.accConObj = new AccountContactWrapper();
	            	contacts = [SELECT AccountId, Name, Account.Name, (SELECT Attribute__r.Name, Account__r.Name, Attribute__r.Parent__r.Name, From_Account__c, 
	            					Attribute__r.level__c, Is_fromMapping__c FROM Contact_Attributes__r ORDER BY Attribute__r.Parent__r.Name),  
	            					(SELECT Name, Account__c, Contact__r.Name, Contact__c, Is_Referenceable__c, Reference_Program_Candidate__c, 
	            					Referenceability_Status__c, Roll_up_Attributes_to_All_Accounts__c, Roll_up_Attributes_to_Primary_Account__c 
	            					FROM Reference_Basic_Informations__r) FROM Contact WHERE Id = :infoWp.contactId LIMIT 1];
	            }
	            infoWp.accConObj.isSharedContact = cs.Shared_Contacts__c;
	            
	            if (contacts.size() > 0) {
		            Contact tempContact = contacts[0];
		            
		            if (tempContact.Reference_Basic_Informations__r.size() > 0) {
		                infoWp.accConObj.isContactReferenceProgramMember = tempContact.Reference_Basic_Informations__r[0].Is_Referenceable__c;
		                infoWp.accConObj.isContactCandidate = tempContact.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c;
		                addRefToAllAccountsRBI = (tempContact.Reference_Basic_Informations__r[0].Roll_up_Attributes_to_All_Accounts__c 
		                					? true : (tempContact.Reference_Basic_Informations__r[0].Roll_up_Attributes_to_Primary_Account__c 
		            						? false : (cs.Roll_up_Attributes_to_All_Accounts__c)));
		            }
		            
		            infoWp.contactName = tempContact.Name;
		            infoWp.accountId = tempContact.AccountId;
		            infoWp.accountName = tempContact.Account.Name;
		            
		            for (Contact_Attribute__c al : tempContact.Contact_Attributes__r) {
		            	infoWp.existingAtts.add(new ExistingAttributeWrapper(al.Attribute__c, al.Attribute__r.name, al.Account__r.Name, (al.Is_fromMapping__c || al.From_Account__c), al.Id));
		            }
		            
		            //Shared Contact code start
		            if (cs.Shared_Contacts__c) {
		            	Map<String, Set<String>> contactAccountMap = new Map<String, Set<String>>();
		            	
		            	if (refRefresh != null) {
		            		contactAccountMap = WithoutSharingHelperController.getRelatedAccounts(new Set<String> {infoWp.contactId}, cs);
		            	} else {
		            		contactAccountMap = UtilityController.getRelatedAccounts(new Set<String> {infoWp.contactId}, cs);
		            	}
		            	
		            	if (contactAccountMap != null && contactAccountMap.containsKey(tempContact.Id)) {
		                    accountIds.addAll(contactAccountMap.get(tempContact.Id));
		            	}
		            	accountIds.add(tempContact.AccountId);
		            	List<Account> accountList = new List<Account>();
		            	
		            	if (refRefresh != null) {
		            		accountList = WithoutSharingHelperController.getAccountRecordsforLookup(accountIds, 200);
		            	} else {
		            		accountList = [SELECT Name, (SELECT Name, Id, Generic_Account__c, Account__c, Reference_Program_Candidate__c,
		            							Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r WHERE Contact__c = null) 
		            							FROM Account WHERE Id IN :accountIds ORDER BY Name LIMIT 200];
		            	}
		            	
		            	for (Account acc : accountList) {
		            		
		            		//to exclude generic account
		            		if (acc.Reference_Basic_Informations__r.size() == 0 || (acc.Reference_Basic_Informations__r.size() > 0 
		            							&& !acc.Reference_Basic_Informations__r[0].Generic_Account__c)) {
			            		
			            		if (tempContact.AccountId == acc.Id) {
				            		infoWp.accountName = acc.Name;
			            		}
			            		
			            		// added for #366
			            		if (PUMAccountId != '' && PUMAccountId == acc.Id) {
			            			infoWp.accountName = acc.Name;
			            		}
		
			            		if (tempContact.AccountId == acc.Id) {
				            		infoWp.accConObj.isAccountReferenceProgramMember = (acc.Reference_Basic_Informations__r.size() > 0 
			                										? acc.Reference_Basic_Informations__r[0].Is_Referenceable__c : false);
									infoWp.accConObj.isAccountCandidate = (acc.Reference_Basic_Informations__r.size() > 0 
			                										? acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c : false);
				            	}
				                
				                if (addRefToAllAccountsRBI) {
				                	infoWp.accConObj.selectedAccounts.add(new AccountWrapper(acc.Id, acc.Name, 
			                										(acc.Reference_Basic_Informations__r.size() > 0 
			                										? acc.Reference_Basic_Informations__r[0].Is_Referenceable__c : false),
			                										(acc.Reference_Basic_Informations__r.size() > 0 
			                										? acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c : false)));
				                } else {
				                	
				                	if (PUMAccountId != '') {
				                		
				                		if (PUMAccountId == acc.Id) {
				                			infoWp.accConObj.selectedAccounts.add(new AccountWrapper(acc.Id, acc.Name, 
			                										(acc.Reference_Basic_Informations__r.size() > 0 
			                										? acc.Reference_Basic_Informations__r[0].Is_Referenceable__c : false),
			                										(acc.Reference_Basic_Informations__r.size() > 0 
			                										? acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c : false)));
				                		} else {
				                			infoWp.accConObj.accounts.add(new AccountWrapper(acc.Id, acc.Name,
				                									(acc.Reference_Basic_Informations__r.size() > 0 
			                										? acc.Reference_Basic_Informations__r[0].Is_Referenceable__c : false),
			                										(acc.Reference_Basic_Informations__r.size() > 0 
			                										? acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c : false)));
				                		}
				                	} else {
				                		
					                	if (tempContact.AccountId == acc.Id) {
					                		infoWp.accConObj.selectedAccounts.add(new AccountWrapper(acc.Id, acc.Name, 
			                										(acc.Reference_Basic_Informations__r.size() > 0 
			                										? acc.Reference_Basic_Informations__r[0].Is_Referenceable__c : false),
			                										(acc.Reference_Basic_Informations__r.size() > 0 
			                										? acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c : false)));
					                	} else {
					                		infoWp.accConObj.accounts.add(new AccountWrapper(acc.Id, acc.Name,
				                									(acc.Reference_Basic_Informations__r.size() > 0 
			                										? acc.Reference_Basic_Informations__r[0].Is_Referenceable__c : false),
			                										(acc.Reference_Basic_Informations__r.size() > 0 
			                										? acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c : false)));
				                		}
				                	}
				                }
		            		}
		            	}
		            } else {
		            	List<Account> accounts = new List<Account>();
			        	
			            //changed for new object
			            if (refRefresh != null) {
			            	accounts = WithoutSharingHelperController.getContactAccountOnAddAtt(tempContact.AccountId);
			            } else {
			            	accounts = [SELECT Name, (SELECT Attribute__r.Name, Attribute__r.Parent__r.Name, Attribute__r.level__c, Is_fromMapping__c 
			            					FROM Account_Attributes__r WHERE contact__c = null AND Reference_Content__c = null), 
			            					(SELECT Name, Account__c, Reference_Program_Candidate__c, Is_Referenceable__c, Referenceability_Status__c 
			            					FROM Reference_Basic_Informations__r WHERE Contact__c = null) 
			            					FROM Account WHERE Id = :infoWp.accountId LIMIT 1];
			            }
			        
			        	if (accounts.size() > 0) {
			            	Account tempAccount = accounts[0];
				            infoWp.accountName = tempAccount.Name;
				            
				            if (tempAccount.Reference_Basic_Informations__r.size() > 0) {
				                infoWp.accConObj.isAccountReferenceProgramMember = tempAccount.Reference_Basic_Informations__r[0].Is_Referenceable__c;
				                infoWp.accConObj.isAccountCandidate = tempAccount.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c;
				            }
			        	}
		            }
	            }
	            //added a field regarding #570 
	            listRootAtts = [SELECT Id, Name, Level__c, Parent__c, Attribute_Mapping__c, Attribute_Mapping__r.Object__c, 
        									Attribute_Mapping__r.Field__c, Parent__r.Name, 
	        								(SELECT Id FROM Attributes__r LIMIT 1) FROM Attribute__c WHERE Level__c = 0 
	        								AND (Ref_Limit_to_Acct_or_Cntct__c = null
        									OR Ref_Limit_to_Acct_or_Cntct__c = '' OR
        									Ref_Limit_to_Acct_or_Cntct__c = 'Contact') ORDER BY Name];
	        }
	        
	        if (infoWp.contentId != null && infoWp.contentId != '') {
	            Reference_Content__c refContent = [SELECT name, (SELECT Attribute__r.Name, Attribute__c FROM Content_Attributes__r 
	            					ORDER BY Attribute__r.Parent__r.Name) FROM Reference_Content__c WHERE Id = :infoWp.contentId LIMIT 1][0];
	            infoWp.contentName = refContent.Name;
	            
	            for (Content_Attribute__c al : refContent.Content_Attributes__r) {
	            	infoWp.existingAtts.add(new ExistingAttributeWrapper(al.Attribute__c, al.Attribute__r.name, '', false, ''));
	            }
	            //added a field regarding #570 
	            listRootAtts = [SELECT Id, Name, Level__c, Parent__c, Attribute_Mapping__c, Parent__r.Name, 
	        							(SELECT Id FROM Attributes__r LIMIT 1) FROM Attribute__c WHERE Level__c = 0 ORDER BY Name];
	        }
	        
	        for (Attribute__c att : listRootAtts) {
	        	if(infoWp != null && (String.isNotBlank(infoWp.accountId) || String.isNotBlank(infoWp.contactId)) 
					&& (att.Attribute_Mapping__r.Object__c == 'Opportunity' && att.Attribute_Mapping__r.Field__c == 'Stage')) {
	        		continue;
	        	}
	            Boolean hasChild = (att.Attributes__r != null && att.Attributes__r.size() > 0 ? true : false);
	            
	            if (att.Attribute_Mapping__c == null) {
	                infoWp.rootAttributes.add(new AttributeWrapper(att.Id, att.Name, Integer.valueOf(att.Level__c), hasChild, false, true, ''));
	            } else {
	                infoWp.rootAttributes.add(new AttributeWrapper(att.Id, att.Name, Integer.valueOf(att.Level__c), hasChild, true, true, ''));
	            }
	        }
    	} catch(Exception e) {
    		infoWp.error = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
    	}
    	return infoWp;
    }
    
    /**
     * RemoteAction to get child attributes of an attribute
     */
    @RemoteAction
    public static List<AttributeWrapper> getAttributes(String attId, String parent) {
    	List<AttributeWrapper> attributes = new List<AttributeWrapper>();
    	List<Attribute__c> childAttributes = [SELECT Id, Name, Level__c, Parent__r.Attribute_Mapping__c, Parent__r.Attribute_Mapping__r.Object__c, 
    										Parent__c, Parent__r.Name, (SELECT Id FROM Attributes__r LIMIT 1) 
    										FROM Attribute__c WHERE Parent__c = :attId ORDER BY Name];
        Set<String> attAttachedWithFilters = new Set<String>();
        Set<String> attIdsToCheck = new Set<String>();

        for (Attribute__c att : childAttributes) {
            attIdsToCheck.add(att.Id);
        }

        for (String attIdTemp : parent.split(';')) {
            
            if (attIdTemp != '' && !attIdsToCheck.contains(attIdTemp)) {
                attIdsToCheck.add(attIdTemp);
            }
        }

        for (Attributes_Labels__c attLabel : [SELECT Id, Attribute__c FROM Attributes_Labels__c WHERE Attribute__c IN :attIdsToCheck]) {
        	attAttachedWithFilters.add(attLabel.Attribute__c);
        }
        Boolean isfilterExistsForParent = false;
        
        if (childAttributes.size() > 0) {
        	
        	if (childAttributes[0].Level__c == 1) {
	        	isfilterExistsForParent = true;
        	} else {
	        	isfilterExistsForParent = attAttachedWithFilters.contains(childAttributes[0].Parent__c);
            }
        }
        
        for (Attribute__c att : childAttributes) {
        	Boolean hasChild = (att.Attributes__r != null && att.Attributes__r.size() > 0 ? true : false);
        	
            if (att.Parent__r.Attribute_Mapping__c != null && att.Parent__r.Attribute_Mapping__r.Object__c != ConstantsController.OPPORTUNITY) {
                attributes.add(new AttributeWrapper(att.id, att.Name, Integer.valueOf(att.Level__c), hasChild, true, 
                			(attAttachedWithFilters.contains(att.Id) && isfilterExistsForParent ? true : false), parent));
            } else {
                attributes.add(new AttributeWrapper(att.id, att.Name, Integer.valueOf(att.Level__c), hasChild, false, 
                			(attAttachedWithFilters.contains(att.Id) && isfilterExistsForParent ? true : false), parent));
            }
        }
    	return attributes;
    }
    
    /**
     * RemoteAction to save attributes
     */
    @RemoteAction
    public static String saveAttributes(String infoWpJSON) {
    	Savepoint sp = Database.setSavepoint();
        try {
        	InfoWrapper infoWp = (InfoWrapper)JSON.deserialize(infoWpJSON, InfoWrapper.class);
        	
        	if ((infoWp.accConObj != null && infoWp.accConObj.isFromProfileUpdate) || checkPermissions(infoWp)) {
	        	
	            if (infoWp.labelId != '') {
	                addAttributesToLabel(infoWp);
	            }
	            
	            if (infoWp.contactId != '') {
	                addAttributeToContact(infoWp);
	            } else if (infoWp.accountId != '') {
	                addAttributeToAccount(infoWp);
	            }
	            
	            if (infoWp.contentId != '') {
	                addAttributeToContent(infoWp);
	            }
        	} else {
        		return CRUDAndFLSCheckController.getErrorMsg();
        	}
        } catch (Exception e) {
            database.rollback(sp);
            return 'Error: ' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        }
        return '';
    }
    
    /**
     * Method to add Attributes to the Contact
     */
    private static void addAttributeToContact(InfoWrapper infoWp) {
        Set<Id> attribIds = new Set<Id>();
        Set<String> newAttributeIds = new Set<String>();
        Set<Id> accountAttribIds = new Set<Id>();
        
        if (infoWp.accConObj.isSharedContact) {
        	
	        if (infoWp.accConObj.selectedAccounts != null && infoWp.accConObj.selectedAccounts.size() > 0) {
	        	
	        	for (AccountWrapper aw : infoWp.accConObj.selectedAccounts) {
	        		ConstantsController.selectedAccounts.add(aw.id);
	        	}
	        	
	        	if (!ConstantsController.selectedAccounts.contains(infoWp.accountId)) {
	        		infoWp.accountId = '';
	        	}
	        }
        }
        
        if (infoWp.accConObj.makeAccountMember || infoWp.accConObj.makeContactMember || infoWp.accConObj.makeAccountCandidate || infoWp.accConObj.makeContactCandidate) {
        	
        	if (ConstantsController.selectedAccounts != null && ConstantsController.selectedAccounts.size() > 0) {
        		UtilityController.checkRBI(ConstantsController.selectedAccounts, infoWp.contactId, infoWp.accConObj.makeAccountMember, infoWp.accConObj.makeContactMember, 
        																				infoWp.accConObj.makeAccountCandidate, infoWp.accConObj.makeContactCandidate);
        	} else {
        		UtilityController.checkRBI(infoWp.accountId, infoWp.contactId, infoWp.accConObj.makeAccountMember, infoWp.accConObj.makeContactMember, 
        																infoWp.accConObj.makeAccountCandidate, infoWp.accConObj.makeContactCandidate);
        	}
        }
        
        for (Contact_Attribute__c attrib : [SELECT Attribute__r.Id FROM Contact_Attribute__c WHERE Contact__c = :infoWp.contactId]) {
            attribIds.add(attrib.Attribute__r.Id);
        }
        Map<Id, Set<Id>> accAttMap = new map<Id, Set<Id>>();
        
        for (Account_Attribute__c attrib : WithoutSharingHelperController.getAllAccountAttributesOfAccountSharedContact(
        															ConstantsController.selectedAccounts, infoWp.contactId)) {
        	if (!accAttMap.containsKey(attrib.Account__c)) {
        		accAttMap.put(attrib.Account__c, new Set<Id>());
        	}
    		accAttMap.get(attrib.Account__c).add(attrib.Attribute__c);
        }
        Contact_Attribute__c attContact;
        List<Contact_Attribute__c> newattContacts = new List<Contact_Attribute__c>();
        List<Account_Attribute__c> newattAccounts = new List<Account_Attribute__c>();
        
        for (String att : infoWp.currentAtts) {
        	
            if (att != '' && !attribIds.contains(att)) {
                attContact = new Contact_Attribute__c(Contact__c = infoWp.contactId, Attribute__c = att);
                newattContacts.add(attContact);
                newAttributeIds.add(att);
            } else if (att != '' && attribIds.contains(att)) {
            	
            	for (Id accId : accAttMap.keySet()) {
            		
            		if (!accAttMap.get(accId).contains(att)) {
            			Account_Attribute__c tempObj = new Account_Attribute__c();
		                tempObj.Account__c = accId;
		                tempObj.Attribute__c = att;
		                tempObj.Contact__c = infoWp.contactId;
		                newattAccounts.add(tempObj);
            		}
            	}
            }
        }
        Map<String, String> attIdNameMap = new Map<String, String>();
        
        for (Attribute__c att : [SELECT ParentIds__c, Name, Id FROM Attribute__c WHERE Id IN :newAttributeIds]) {
            attIdNameMap.put(att.Id, att.Name);
        }

        if (infoWp.accConObj.makeAccountMember) {
            ConstantsController.addAttributesToAccount = true;
        }
        
        if (infoWp.accConObj.isSharedContact) {
        	ConstantsController.isAccountSelectedfromContact = true; 
        }
        
        if (newattContacts.size() > 0) {
            List<Reference_Refresh_Update__c> refrefreshUpdate = new List<Reference_Refresh_Update__c>();

            if (infoWp.accConObj.isFromProfileUpdate) {
            	
                if (!infoWp.refRefresh.quarantined) {
                    WithoutSharingHelperController.upsertContactAttributes(newattContacts);
                }
                
                for (Contact_Attribute__c accAtt : newattContacts) {
                	
                    if (!infoWp.refRefresh.alreadyCreatedPUAttforContact.contains(accAtt.Attribute__c)) {
                        
                        // Changes for #366 - creating records for each of the selected accounts
                    	if (ConstantsController.selectedAccounts != null && ConstantsController.selectedAccounts.size() > 0) {
                    		
                    		for (String accId : ConstantsController.selectedAccounts) {
	                        	Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
								temp.Account__c = accId;
	                            temp.Contact__c = accAtt.Contact__c;
	                            temp.Added__c = true;
	                            temp.Changed_To__c = infoWp.currentAttName.get(accAtt.Attribute__c);
	                            temp.Attribute__c = true;
	                            temp.RecordsToBeInsertedId__c = accAtt.Attribute__c;
	                            temp.Reference_Refresh__c = infoWp.refRefresh.id;
	                            
	                            if (!infoWp.refRefresh.quarantined) {
	                                temp.Accept_Reject__c = 'Accept';
	                            }
	                            refrefreshUpdate.add(temp);
                    		}
                    	} else if (!infoWp.accConObj.isSharedContact) {
                    		Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
							temp.Account__c = infoWp.accountId;
                            temp.Contact__c = accAtt.Contact__c;
                            temp.Added__c = true;
                            temp.Changed_To__c = infoWp.currentAttName.get(accAtt.Attribute__c);
                            temp.Attribute__c = true;
                            temp.RecordsToBeInsertedId__c = accAtt.Attribute__c;
                            temp.Reference_Refresh__c = infoWp.refRefresh.id;
                            
                            if (!infoWp.refRefresh.quarantined) {
                                temp.Accept_Reject__c = 'Accept';
                            }
                            refrefreshUpdate.add(temp);
                    	}
                    }
            	}
            	
                if (refrefreshUpdate.size() > 0) {
                    WithoutSharingHelperController.upsertRefreshUpdateRecords(refrefreshUpdate);
                }
            } else {
            	
                if (newattAccounts.size() > 0) {
                	insert newattAccounts;
                }
                
                if (newattContacts.size() > 0) {
                	insert newattContacts;
                }
            }
        }
    }
    
	/**
     * Method to add Attributes to the Account
     */
    private static void addAttributeToAccount(InfoWrapper infoWp) {
        Set<Id> attribIds = new Set<Id>();
        Set<Id> contctAttrib = new Set<Id>();
        
        if (infoWp.accConObj.makeAccountMember || infoWp.accConObj.makeContactMember || infoWp.accConObj.makeAccountCandidate || infoWp.accConObj.makeContactCandidate) {
        	UtilityController.checkRBI(infoWp.accountId, null, infoWp.accConObj.makeAccountMember, infoWp.accConObj.makeContactMember, 
        										infoWp.accConObj.makeAccountCandidate, infoWp.accConObj.makeContactCandidate);
        }
        
        for (Account_Attribute__c attrib : WithoutSharingHelperController.getAccountAttributes(infoWp.accountId)) {
            attribIds.add(attrib.Attribute__r.Id);
        }
        Set<String> newAttributeIds = new Set<String>();
        for (String att : infoWp.currentAtts) {
        	newAttributeIds.add(att);
        }
        Map<String, Set<String>> attribParentIdsMap = new Map<String, Set<String>>();
        Map<String, Boolean> attributeInheritable = new Map<String, Boolean>();
        Set<String> parentAttIds = new Set<String>();
        Map<String, String> attIdNameMap = new Map<String, String>();
        Set<String> tempSet = new Set<String>();
        Set<Id> parentToBeAdded = new Set<Id>();
        
        for (Attribute__c att : [SELECT ParentIds__c, Name, Id FROM Attribute__c WHERE Id IN :newAttributeIds]) {
            tempSet = new Set<String>();
            
            if (att.ParentIds__c != null) {
            	tempSet.addAll(att.ParentIds__c.split(','));
            }
            parentAttIds.addAll(tempSet);
            attribParentIdsMap.put(att.Id, tempSet);
            attIdNameMap.put(att.Id, att.Name);
        }
        
        for (Attribute__c att : [SELECT Id, Inheritable__c, Level__c FROM Attribute__c WHERE Id IN :parentAttIds]) {
        	
            if (att.level__c == 0) {
            	
	            for (String attKey : attribParentIdsMap.keySet()) {
	            	
	                if (attribParentIdsMap.get(attKey).contains(att.Id)) {
	                    attributeInheritable.put(attKey, att.Inheritable__c);
	                }
	            }
            } else if (!newAttributeIds.contains(att.Id)) {
            	parentToBeAdded.add(att.Id);
            }
        }
        Account_Attribute__c attAccount;
        List<Account_Attribute__c> newattAccounts = new List<Account_Attribute__c>();
        
        for (String att : infoWp.currentAtts) {
        	
            if (att != '' && !attribIds.contains(att)) {
                attAccount = new Account_Attribute__c(Account__c = infoWp.accountId, Attribute__c = att, Inheritable__c = attributeInheritable.get(att));
                attribIds.add(att);
                newattAccounts.add(attAccount);
                
                if (attribParentIdsMap.get(att) != null) {
                	
        			for (Id attId : attribParentIdsMap.get(att)) {
        				
        				if (parentToBeAdded.contains(attId) && !attribIds.contains(attId)) {
        					attAccount = new Account_Attribute__c(Account__c = infoWp.accountId, Attribute__c = attId, 
        														Inheritable__c = attributeInheritable.get(att));
                			newattAccounts.add(attAccount);
                			attribIds.add(attId);
        				}
        			}
                }
            }
        }
        
        if (newattAccounts.size() > 0) {
        	List<Reference_Refresh_Update__c> refrefreshUpdate = new List<Reference_Refresh_Update__c>();
        	
            if (infoWp.accConObj.isFromProfileUpdate) {
                
                if (!infoWp.refRefresh.quarantined) {
                    WithoutSharingHelperController.upsertAccountAttributes(newattAccounts);
                }
            	
                for (Account_Attribute__c accAtt : newattAccounts) {
                	
                    if (!infoWp.refRefresh.alreadyCreatedPUAttforAccount.contains(accAtt.Attribute__c)) {
                        Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                        temp.Account__c = accAtt.Account__c;
                        temp.Added__c = true;
                        temp.Changed_To__c = infoWp.currentAttName.get(accAtt.Attribute__c);
                        temp.Attribute__c = true;
                        temp.RecordsToBeInsertedId__c = accAtt.Attribute__c;
                        temp.Attribute_Inheritable__c = accAtt.Inheritable__c;
                        
                        if (!infoWp.refRefresh.quarantined) {
                            temp.Accept_Reject__c = 'Accept';
                        }
                        temp.Reference_Refresh__c = infoWp.refRefresh.id;
                        refrefreshUpdate.add(temp);
                    }
                }
                
                if (refrefreshUpdate.size() > 0) {
                    WithoutSharingHelperController.upsertRefreshUpdateRecords(refrefreshUpdate);
                }
            } else {
                insert newattAccounts;
            }
        }
    }
    
    /**
     * Method to add Attributes to the Content
     */
    private static void addAttributeToContent(InfoWrapper infoWp) {
        Set<Id> attribIds = new Set<Id>();
        
        for (ExistingAttributeWrapper attrib : infoWp.existingAtts) {
            attribIds.add(attrib.id);
        }
        Content_Attribute__c attContent;
        List<Content_Attribute__c> newattContent = new List<Content_Attribute__c>();
        
        for (String att : infoWp.currentAtts) {
        	
            if (att != '' && !attribIds.contains(att)) {
                attContent = new Content_Attribute__c(Reference_Content__c = infoWp.contentId, Attribute__c = att);
                newattContent.add(attContent);
            }
        }
        
        if (newattContent.size() > 0) {
            insert newattContent;
        }
    }
    
    /**
     * Method to add Attributes to the Label
     */
    private static void addAttributesToLabel(InfoWrapper infoWp) {
        Set<Id> attribIds = new Set<Id>();
        
        for (ExistingAttributeWrapper attrib : infoWp.existingAtts) {
            attribIds.add(attrib.id);
        }
        Attributes_Labels__c attLabel;
        List<Attributes_Labels__c> newattLabels = new List<Attributes_Labels__c>();
        
        for (String att : infoWp.currentAtts) {
        	
            if (att != '' && !attribIds.contains(att)) {
                attLabel = new Attributes_Labels__c(Label__c = infoWp.labelId, Attribute__c = att);
                newattLabels.add(attLabel);
            }
        }
        
        if (newattLabels.size() > 0) {
            insert newattLabels;
        }
    }
    
    /**
     * RemoteAction to get insufficient permmission message
     */
    @RemoteAction
    public static String getPermissionsMessage(String infoWpJSON) {
    	InfoWrapper infoWp = (InfoWrapper)JSON.deserialize(infoWpJSON, InfoWrapper.class);
		checkPermissions(infoWp);
    	
    	return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    /**
     * RemoteAction to delete the selected attribute
     */
    @RemoteAction
    public static String deleteAttribute(String attId, String accountId, String contactId, Boolean isQuarantined,
    									String profileUpdateId) {
    	List<Reference_Refresh_Update__c> refrefreshUpdate = new List<Reference_Refresh_Update__c>();
        Savepoint sp = Database.setSavepoint();
        Set<String> deleteAttIds = new Set<String>();
        
        try {
        	
        	if (accountId != null && accountId != '') {
        		List<Account_Attribute__c> accAtts = WithoutSharingHelperController.getAccountAttributesOnAddAtt(attId);
                
                for (Account_Attribute__c accAtt : accAtts) {
                    Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                    temp.Account__c = accAtt.Account__c;
                    temp.Removed__c = true;
                    temp.Changed_From__c = accAtt.Attribute__r.Name;
                    temp.Changed_To__c = '';
                    temp.Attribute__c = true;
                    
                    if (!isQuarantined) {
                        temp.Accept_Reject__c = 'Accept';
                    }
                    temp.Reference_Refresh__c = profileUpdateId;
                    temp.RecordToBeDeletedId__c = accAtt.Id;
                    deleteAttIds.add(accAtt.Id);
                    refrefreshUpdate.add(temp);
                }
                
                if (refrefreshUpdate.size() > 0) {
                    WithoutSharingHelperController.upsertRefreshUpdateRecords(refrefreshUpdate);
                }
                
                if (!isQuarantined) {
                    WithoutSharingHelperController.deleteAccountAttributes(accAtts);
                }
        	}
        	
        	if (contactId != null && contactId != '') {
                List<Contact_Attribute__c> accAtts = WithoutSharingHelperController.getContactAttributesOnAddAtt(attId);
                
                for (Contact_Attribute__c accAtt : accAtts) {
                    Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                    temp.Account__c = accAtt.Contact__r.accountId;
                    temp.Contact__c = accAtt.Contact__c;
                    temp.Removed__c = true;
                    temp.Changed_From__c = accAtt.Attribute__r.Name;
                    temp.Changed_To__c = '';
                    temp.Attribute__c = true;
                    
                    if (!isQuarantined) {
                        temp.Accept_Reject__c = 'Accept';
                    }
                    temp.Reference_Refresh__c = profileUpdateId;
                    temp.RecordToBeDeletedId__c = accAtt.Id;
                    deleteAttIds.add(accAtt.Id);
                    refrefreshUpdate.add(temp);
                }
                
                if (refrefreshUpdate.size() > 0) {
                    WithoutSharingHelperController.upsertRefreshUpdateRecords(refrefreshUpdate);
                }
                
                if (!isQuarantined) {
                    WithoutSharingHelperController.deleteContactAttributes(accAtts);
                }
            }
        	return 'success';
        } catch(Exception e) {
        	database.rollback(sp);
        	return CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        }
    }
    
    /**
     * Method to check Permissions
     */
    private static Boolean checkPermissions(InfoWrapper infoWp) {
    	
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();

        if (infoWp.labelId != '') {
	        fieldMap.put(UtilityController.appNamespace() + 'Attributes_Labels__c', new Set<String> {});
        }
        
        if (infoWp.accountId != '') {
            fieldMap.put(UtilityController.appNamespace() + 'Account_Attribute__c', new Set<String> {
	        										UtilityController.appNamespace() + 'Inheritable__c'});
        }
        
        if (infoWp.contactId != '') {
            fieldMap.put(UtilityController.appNamespace() + 'Contact_Attribute__c', new Set<String> {});
			fieldMap.put(UtilityController.appNamespace() + 'Account_Attribute__c', new Set<String> {
	        										UtilityController.appNamespace() + 'Contact__c'});
        }
        
        if (infoWp.contentId != '') {
            fieldMap.put(UtilityController.appNamespace() + 'Content_Attribute__c', new Set<String> {});
        }
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
    }
    /**
     * Wrapper class for all information
     */
 	public class InfoWrapper {
 		public String accountId { get; set; }
 		public String contactId { get; set; }
 		public String accountName { get; set; }
 		public String contactName { get; set; }
 		public String labelId { get; set; }
 		public String labelName { get; set; }
 		public String contentId { get; set; }
 		public String contentName { get; set; }
 		public String error { get; set; }
 		public List<AttributeWrapper> rootAttributes { get; set; }
 		public List<String> currentAtts { get; set; }
 		public Map<String, String> currentAttName { get; set; }
 		public List<ExistingAttributeWrapper> existingAtts { get; set; }
 		public RefRefreshWrapper refRefresh { get; set; }
 		public AccountContactWrapper accConObj { get; set; }
 		
 	    public InfoWrapper() {
	    	accountId = '';
            contactId = '';
            accountName = '';
            contactName = '';
            labelId = '';
            labelName = '';
            contentId = '';
            error = '';
            contentName = '';
            rootAttributes = new List<AttributeWrapper>();
            currentAtts = new List<String>();
            existingAtts = new List<ExistingAttributeWrapper>();
            currentAttName = new Map<String, String>();
	    }
 	}
 	/**
     * Wrapper Class
     */
 	public class OptionWrapper {
 		public String id { get; set; }
 		public String name { get; set; }
 		
 		public OptionWrapper(String id, String name) {
 			this.id = id;
 			this.name = name != null ? name.escapeHtml4() : '';
 		}
 	}
 	/**
     * Wrapper Class
     */
 	public class AttributeWrapper {
 		public Boolean isSelected { get; set; }
 		public Boolean isExpand { get; set; }
 		public Boolean hasChild { get; set; }
 		public Boolean isMapped { get; set; }
 		public Boolean isFilter { get; set; }
 		public String id { get; set; }
 		public String parent { get; set; }
 		public String name { get; set; }
 		public Integer level { get; set; }
 		public List<AttributeWrapper> attributes { get; set; }
 		
 		public AttributeWrapper(String id, String name, Integer level, Boolean hasChild, Boolean isMapped, Boolean isFilter, String parent) {
 			isSelected = false;
 			this.name = name != null ? name.escapeHtml4() : '';
 			this.id = id;
 			this.parent = parent != null ? parent.escapeHtml4() : '';
 			this.level = level;
 			this.hasChild = hasChild;
 			this.isMapped = isMapped;
 			this.isFilter = isFilter;
 			this.isExpand = false;
 			this.attributes = new List<AttributeWrapper>();
 		}
 	}
 	/**
     * Wrapper Class
     */
 	public class ExistingAttributeWrapper {
 		public String id { get; set; }
 		public Boolean isExist { get; set; }
 		public String name { get; set; }
 		public String account { get; set; }
 		public Boolean isFromMapping { get; set; }
 		public String accConAttributeId { get; set; }
 		
 		public ExistingAttributeWrapper(String id, String name, String account, Boolean isFromMapping, String accConAttributeId) {
 			this.id = id;
 			this.name = name != null ? name.escapeHtml4() : '';
 			this.isExist = true;
 			this.account = account;
 			this.isFromMapping = isFromMapping;
 			this.accConAttributeId = accConAttributeId;
 		}
 	}
 	/**
     * Wrapper Class
     */
 	public class AccountContactWrapper {
 		public List<AccountWrapper> accounts { get; set; }
 		public List<AccountWrapper> selectedAccounts { get; set; }
 		public Boolean makeAccountMember { get; set; }
 		public Boolean makeContactMember { get; set; }
 		public Boolean makeAccountCandidate { get; set; }
 		public Boolean makeContactCandidate { get; set; }
 		public Boolean isLimitExceeded { get; set; }
 		public Boolean isSharedContact { get; set; }
 		public Boolean isFromProfileUpdate { get; set; }
 		public Boolean isAccountReferenceProgramMember { get; set; }
 		public Boolean isAccountCandidate { get; set; }
 		public Boolean isContactReferenceProgramMember { get; set; }
 		public Boolean isContactCandidate { get; set; }
 		
 		public AccountContactWrapper() {
 			makeAccountMember = false;
            makeContactMember = false;
			makeAccountCandidate = false;
            makeContactCandidate = false;
            isLimitExceeded = false;
            isFromProfileUpdate = false;
            accounts = new List<AccountWrapper>();
		    selectedAccounts = new List<AccountWrapper>();
 		}
 	}
 	/**
     * Wrapper Class
     */
 	public class AccountWrapper {
 		public String id { get; set; }
 		public Boolean isReference { get; set; }
 		public String name { get; set; }
 		public Boolean isCandidate { get; set; }
 		
 		public AccountWrapper(String id, String name, Boolean isReference, Boolean isCandidate) {
 			this.id = id;
 			this.name = name != null ? name.escapeHtml4() : '';
 			this.isCandidate = isCandidate;
 			this.isReference = isReference;
 		}
 	}
 	/**
     * Wrapper Class
     */
 	public class RefRefreshWrapper {
 		public Set<String> alreadyCreatedPUAttforAccount { get; set; }
 		public Set<String> alreadyCreatedPUAttforContact { get; set; }
 		public Boolean quarantined { get; set; }
 		public String id { get; set; }
 		public String ownerId { get; set; }
 		public String accountId { get; set; }
 		public List<ProfileUpdateDetailWrapper> quarantineUpdates { get; set; }
 		
 		public RefRefreshWrapper() {
 			alreadyCreatedPUAttforAccount = new Set<String>();
            alreadyCreatedPUAttforContact = new Set<String>();
            quarantineUpdates = new List<ProfileUpdateDetailWrapper>();
            id = '';
 		}
 	}
 	/**
     * Wrapper Class
     */
 	public class ProfileUpdateDetailWrapper {
 		public String changeTo { get; set; }
 		public Boolean added { get; set; }
 		public String changeFrom { get; set; }
 		public Boolean removed { get; set; }
 		
 		public ProfileUpdateDetailWrapper(Reference_Refresh_Update__c rru) {
 			this.changeTo = rru.Changed_To__c;
 			this.changeFrom = rru.Changed_From__c;
 			this.added = rru.Added__c;
 			this.removed = rru.Removed__c;
 		}
 	}
}