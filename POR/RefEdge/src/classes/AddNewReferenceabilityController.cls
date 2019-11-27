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
 * Page: AddNewReferenceability
 * Description: this class is called FROM AddNewReferenceability page to provide functionality to add/edit referenceability
 * Modified by: Rekha Jangir @Feb 16 2017
 */
public with sharing class AddNewReferenceabilityController extends RefEdgeEditionFeatures {
	
    /**
     * Properties and variables
     */
    public Referenceability__c refer { get; set; }
    public List<SelectOption> contacts { get; set; }
    public Map<String, Reference_Basic_Information__c> contactIsReferenceableMap { get; set; }
    public Boolean isContactSelected { get; set; }
    public Boolean isContactsRendered { get; set; }
    public String selectedContact { get; set; }
    // Added for #366 - Id of the account for which the profile is being updated.
    public String PUMAccountId { get; set; }
    public Boolean isContactCandidate { get; set; }
    public Boolean isAccountCandidate { get; set; }
    public Boolean isAccountReferenceableStatus { get; set; }
    public Boolean isContactReferenceableStatus { get; set; }
    public SelectOption[] selectedFields { get; set; }
    public Boolean makeAccountMember { get; set; }
    public Boolean makeContactMember { get; set; }
    public Boolean makeAccountCandidate { get; set; }
    public Boolean makeContactCandidate { get; set; }
    public List<Referenceability__c> multipleRefers;
    public String returnId = '';
    private String contactId;
    private String currentRequestURL;
    //changes regarding #832
    private String existingRefType;
    public Boolean isOnlySave { get; set; }
    public Boolean hasError { get; set; }
    public Boolean showReferenceabilityForAccount { get; set; }
    public Boolean showReferenceabilityForContact { get; set; }
    public List<Referenceability__c> referenceabilityPresent { get; set; }
    public String selectedReferenceability { get; set; }
    private List<Reference_Refresh_Update__c> refRefreshUpdates;
    private Reference_Refresh__c refRefresh;
    private Custom_Settings__c cs;
    private Set<String> alreadyCreatedPURef;
    private String pageNo = '';
    //Shared Contact code start
    public Boolean isSharedContact { get; set; }
    public List<SelectOption> accounts { get; set; }
    public List<SelectOption> selectedAccounts { get; set; }
    private Boolean addRefToAllAccountsRBI;
    public Map<String, Reference_Basic_Information__c> accountIsReferenceableMap { get; set; }
    private String accountFlags;
    private Boolean isFromAccount;
    //end
    public Boolean isSLDS { get; set; }
    public Boolean isLimitExceeded { get; set; }
    private Boolean isContactInactive;
    private Map<Id, Referenceability_Type__c> refTypeMap;
    public List<SelectOption> referenceabilityTypes { get; set; }
    //changes for #870
    private Boolean isContactEditable;
    //re #859
    public String contactRBI { get; set; }
    public String accountRBI { get; set; }
    
    //Re #1116
    public list<Referenceability__c> referencibilityList {get; set;}
    
    /**
     * Constructor
     */
    public AddNewReferenceabilityController(ApexPages.StandardController controller) {
    	
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
        	referencibilityList = new list<Referenceability__c>();
            refer = new Referenceability__c();
            makeAccountMember = false;
            makeAccountCandidate = false;
            makeContactCandidate = false;
            makeContactMember = false;
            isOnlySave = false;
            isLimitExceeded = false;
            hasError = false;
            isSharedContact = false;
            isContactInactive = false;
            addRefToAllAccountsRBI = false;
            isFromAccount = false;
            isContactSelected = false;
            //changes for #870
            isContactEditable = Schema.sObjectType.Referenceability__c.fields.Contact__c.isCreateable();
            showReferenceabilityForAccount = showReferenceabilityForContact = false;
            selectedFields = new List<SelectOption>();
            refer = (Referenceability__c) controller.getRecord();
            multipleRefers = new List<Referenceability__c>();
            currentRequestURL = URL.getCurrentRequestUrl().toExternalForm();
            cs = UtilityController.getCustomSettings();
            refTypeMap = new Map<Id, Referenceability_Type__c>();
            //Shared Contact code
            isSharedContact = cs.Shared_Contacts__c;
            
            if (isSharedContact) {
                addRefToAllAccountsRBI = cs.Roll_up_Referenceability_to_All_Accounts__c;
            }
            accounts = new List<SelectOption>();
            selectedAccounts = new List<SelectOption>();
            isAccountReferenceableStatus = false;
            isContactReferenceableStatus = false;
            isAccountCandidate = false;
            isContactCandidate = false;
            accountIsReferenceableMap = new Map<String, Reference_Basic_Information__c>();
            alreadyCreatedPURef = new Set<String>();
            
            if (refer.id != null) {
                refer = [SELECT Id, Account__c, contact__c, Comment__c, Referenceability_Type__c, Referenceability_Type__r.Name, Status__c, Verified__c 
                			FROM Referenceability__c WHERE Id = :controller.getId()];
                selectedFields.add(new selectOption(refer.Referenceability_Type__c, refer.Referenceability_Type__r.Name));
                existingRefType = refer.Referenceability_Type__c;
            }
            
            if (refer.Account__c != null && refer.Contact__c == null) {
            	referencibilityList = [SELECT Id, Account__c, Contact__c, Referenceability_Type__c, Referenceability_Type__r.Id, Referenceability_Type__r.Name 
        							FROM Referenceability__c WHERE Account__c = :refer.Account__c AND Contact__c = null];        		
            } else if (refer.Contact__c != null) {
            	referencibilityList = [SELECT Id, Account__c, Contact__c, Referenceability_Type__c, Referenceability_Type__r.Id, Referenceability_Type__r.Name 
        							FROM Referenceability__c WHERE Contact__c = :refer.Contact__c];        						
            }
            // Added for #366
            PUMAccountId = '';
            
            if (Apexpages.currentPage().getParameters().get('PUMAccountId') != null) {
                PUMAccountId = Apexpages.currentPage().getParameters().get('PUMAccountId');
            }
            pageNo = Apexpages.currentPage().getParameters().get('pageno');
            returnId = (ApexPages.currentPage().getParameters().get('retURL') != null ? ApexPages.currentPage().getParameters().get('retURL') : '');
            //re #859
            contactRBI = ApexPages.currentPage().getParameters().get('contactRBI');
            accountRBI = ApexPages.currentPage().getParameters().get('accountRBI');
            
            if (contactRBI != null && contactRBI != '') {
            	refer.Contact__c = contactRBI;
            }
            
            if (accountRBI != null && accountRBI != '') {
            	refer.Account__c = accountRBI;
            }
            
            if (ApexPages.currentPage().getParameters().get('conRefRefreshId') != null &&
                ApexPages.currentPage().getParameters().get('conRefRefreshId') != '') {
                List<Reference_Refresh__c> refRefreshs = WithoutSharingHelperController.getReferenceRefreshOnAddRef(
                												ApexPages.currentPage().getParameters().get('conRefRefreshId'));
                
                if (refRefreshs.size() > 0) {
                    refRefresh = refRefreshs[0];
                    showReferenceabilityForContact = true;
                    
                    if (refRefresh.Quarantined__c) {
                    	
                        for (Reference_Refresh_Update__c rru : refRefresh.Reference_Refresh_Updates__r) {
                            
                            if (rru.Contact__c != null && rru.Added__c) {
                                alreadyCreatedPURef.add(rru.RecordsToBeInsertedId__c);
                            }
                        }
                    }
                }
            }
            
            if (ApexPages.currentPage().getParameters().get('accRefRefreshId') != null &&
                ApexPages.currentPage().getParameters().get('accRefRefreshId') != '') {
                List<Reference_Refresh__c> refRefreshs = WithoutSharingHelperController.getReferenceRefreshOnAddRef(
                												ApexPages.currentPage().getParameters().get('accRefRefreshId'));
                
                if (refRefreshs.size() > 0) {
                    refRefresh = refRefreshs[0];
                    showReferenceabilityForAccount = true;
                    
                    if (refRefresh.Quarantined__c) {
                    	
                        for (Reference_Refresh_Update__c rru : refRefresh.Reference_Refresh_Updates__r) {
                        	
                            if (rru.Contact__c == null && rru.Account__c != null && rru.Added__c) {
                                alreadyCreatedPURef.add(rru.RecordsToBeInsertedId__c);
                            }
                        }
                    }
                }
            }
            contactIsReferenceableMap = new Map<String, Reference_Basic_Information__c>();
            
        	//re #646-Referenceability type of Sales Rewards should not be visible on Account Referenceability page 
        	//added a field regarding #570 
            for (Referenceability_Type__c refType : [SELECT Name, Id, Ref_Limit_to_Acct_or_Cntct__c FROM Referenceability_Type__c 
            								WHERE  Visible__c = true AND Referenceability_Type__c = true 
            								AND Sales_Reward__c = false ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
                refTypeMap.put(refType.Id, refType);
            }
            //}
            
            Set<String> accountIds = new Set<String>();
            
            if ((refer.account__c == null) && (refer.contact__c != null || returnId.substring(1, 4) == '003')) {
                isContactSelected = true;
                List<Contact> contactList = new List<Contact>();
	        	String tempcontactId = (refer.contact__c != null ? refer.Contact__c : (returnId != null ? returnId.substringAfter('/').substringBefore('?') : ''));
	        	
	            //changed for new object
	            if (refRefresh != null) {
	            	contactList = WithoutSharingHelperController.getContactRecordsforLookup(new Set<String>{tempcontactId}, 1);
	            } else {
	            	contactList = [SELECT Name, AccountId, (SELECT Id, Account__c, Contact__c, Referenceability_Status__c, Is_Referenceable__c, 
	            					Reference_Program_Candidate__c, Roll_up_Referenceability_to_Primary_Acc__c, Roll_up_Referenceability_to_All_Accounts__c 
	            					FROM Reference_Basic_Informations__r) FROM Contact WHERE Id = :tempcontactId ORDER BY Name LIMIT 1];
	            }
	            
	            if (contactList.size() > 0) {
	                Contact con = contactList[0];
	                refer.Contact__c = con.Id;
	                
	                if (refer.Id == null) {
	                    refer.Account__c = con.accountId;
	                }
	                
	                if (con.Reference_Basic_Informations__r.size() > 0) {
	                    contactIsReferenceableMap.put(con.Id, con.Reference_Basic_Informations__r[0]);
	                    isContactInactive = (con.Reference_Basic_Informations__r[0].Referenceability_Status__c == 'Inactive' ? true : false);
	                    isContactReferenceableStatus = con.Reference_Basic_Informations__r[0].Is_Referenceable__c;
	                    isContactCandidate = con.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c;
	                    addRefToAllAccountsRBI = (con.Reference_Basic_Informations__r[0].Roll_up_Referenceability_to_All_Accounts__c ? true : 
						                    		(con.Reference_Basic_Informations__r[0].Roll_up_Referenceability_to_Primary_Acc__c ? false 
						                    		: (cs.Roll_up_Referenceability_to_All_Accounts__c)));
	                } else {
	                    contactIsReferenceableMap.put(con.Id, new Reference_Basic_Information__c());
	                }
	                
	                //Shared Contact code start
	                if (isSharedContact) {
	                    Map<String, Set<String>> contactAccountMap = new Map<String, Set<String>>();
		            	
		            	if (refRefresh != null) {
		            		contactAccountMap = WithoutSharingHelperController.getRelatedAccounts(new Set<String> { con.Id }, cs);
		            	} else {
		            		contactAccountMap = UtilityController.getRelatedAccounts(new Set<String> { con.Id }, cs);
		            	}
		            	
	                    if (contactAccountMap != null && contactAccountMap.containsKey(con.Id)) {
	                        accountIds.addAll(contactAccountMap.get(con.Id));
	                    }
	                }
	            }
            }
            contacts = new List<SelectOption>();
            contacts.add(new SelectOption('', '--None--'));
            
            if (refer.account__c != null || returnId.substring(1, 4) == '001') {
            	
                if (returnId != '' && returnId.substring(1, 4) == '001') {
                    isFromAccount = true;
                }
                String tempaccountId = refer.account__c != null ? refer.account__c : (returnId != null ? returnId.substringAfter('/').substringBefore('?') : '');
                accountIds.add(tempaccountId);
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
                    if (acc.Reference_Basic_Informations__r.size() == 0 || (acc.Reference_Basic_Informations__r.size() > 0 && 
                    		!acc.Reference_Basic_Informations__r[0].Generic_Account__c)) {
                        
                        if (refer.Account__c == null) {
                            refer.Account__c = acc.Id;
                        }
                        
                        if (acc.Reference_Basic_Informations__r.size() > 0) {
                            accountIsReferenceableMap.put(acc.Id, acc.Reference_Basic_Informations__r[0]);
                            
                            if (tempaccountId == acc.Id) {
                                isAccountReferenceableStatus = acc.Reference_Basic_Informations__r[0].Is_Referenceable__c;
                                isAccountCandidate = acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c;
                            }
                        } else {
                            accountIsReferenceableMap.put(acc.Id, new Reference_Basic_Information__c());
                        }
                        
                        if (addRefToAllAccountsRBI) {
                            selectedAccounts.add(new SelectOption(acc.Id, acc.Name));
                        } else {
                            // Changes for #366 - Setting the pum account as selected account 
                            //in the multipicklist in case of profile update
                            if (PUMAccountId != '') {
                            	
                                if (PUMAccountId == acc.Id) {
                                    selectedAccounts.add(new SelectOption(acc.Id, acc.Name));
                                } else {
                                    accounts.add(new SelectOption(acc.Id, acc.Name));
                                }
                            } else {
                            	
		                		if (tempaccountId == acc.Id) {
		                			selectedAccounts.add(new SelectOption(acc.Id, acc.Name));
			                	} else {
			                		accounts.add(new SelectOption(acc.Id, acc.Name));
			                	}
		                	}
                        }
                    }
                }
                
                if (refer.contact__c == null) {
                    Integer size = 1;
                    List<Contact> contactList = new List<Contact>();
		        	
		            //changed for new object
		            if (refRefresh != null) {
		            	contactList = WithoutSharingHelperController.getAccountContacts(refer.Account__c, cs);
		            } else {
		            	contactList = UtilityController.getAccountContacts(refer.Account__c, cs);
		            }
                    for (Contact con : contactList) {
                        
                        if (size < 1000) {
                            contacts.add(new SelectOption(con.Id, con.Name));
                        } else {
                            isLimitExceeded = true;
                        }
                        size++;
                        
                        if (con.Reference_Basic_Informations__r.size() > 0) {
                            contactIsReferenceableMap.put(con.Id, con.Reference_Basic_Informations__r[0]);
                        } else {
                            contactIsReferenceableMap.put(con.Id, new Reference_Basic_Information__c());
                        }
                    }
                }
            }
           	
           	// contact's pick list is rendered if referenceability is created FROM Account related list
            if ((refer.account__c != null) && (refer.contact__c == null) && (refer.id == null)) {
                isContactsRendered = true;
                isFromAccount = true;
            } else {
                isContactsRendered = false;
            }
            
            if (showReferenceabilityForContact) {
                getTheDataForReferenceabilityContact();
            }
            
            if (showReferenceabilityForAccount) {
                getTheDataForReferenceabilityAccount();
            }
            
            if (referenceabilityPresent != null && referenceabilityPresent.size() > 0) {
                
                for (Referenceability__c ref : referenceabilityPresent) {
                    alreadyCreatedPURef.add(ref.Referenceability_Type__c);
                }
            }
            
            if (refer.Id != null && refer.Account__c == null) {
                isAccountReferenceableStatus = true;
            }
            
            if (refer.Status__c == null || refer.Status__c == '') {
                refer.Status__c = 'Approved';
            }
        	setRefTypes(false);
        	checkPermissions();
        } 
    }
	
	/**
     * Method to set Ref Types according to account and contact
     * Created By: Rekha @21 April 2017 regarding #570 
     */
	private void setRefTypes(Boolean isContactSelected) {
    	referenceabilityTypes = new List<SelectOption>();
		Set<String> selectedIds = new Set<String>();
		
		//store selected values
		for (SelectOption so : selectedFields) {
			selectedIds.add(so.getValue());
		}
		
		//reset selectoption also
		selectedFields = new List<SelectOption>();
		
		if (refer != null) {
     		
     		for (Referenceability_Type__c ref : refTypeMap.values()) {
    			
    			//if reftype available for both
    			if (ref.Ref_Limit_to_Acct_or_Cntct__c == null || ref.Ref_Limit_to_Acct_or_Cntct__c == '') {
    				
    				//changes regarding #832
    				if (!selectedIds.contains(ref.Id) && existingRefType != ref.Id) {
    					referenceabilityTypes.add(new SelectOption(ref.Id, ref.Name));
    				} else {
    					selectedFields.add(new SelectOption(ref.Id, ref.Name));
    				}
				//if reftype available only for account
    			} else if (refer.Account__c != null && (refer.Contact__c == null && !isContactSelected) && ref.Ref_Limit_to_Acct_or_Cntct__c == 'Account') {
	    			
	    			if (!selectedIds.contains(ref.Id) && existingRefType != ref.Id) {
    					referenceabilityTypes.add(new SelectOption(ref.Id, ref.Name));
    				} else {
    					selectedFields.add(new SelectOption(ref.Id, ref.Name));
    				}
				//if reftype available for contact only
    			} else if ((refer.Contact__c != null || isContactSelected) && ref.Ref_Limit_to_Acct_or_Cntct__c == 'Contact') {
    				
					if (!selectedIds.contains(ref.Id) && existingRefType != ref.Id) {
    					referenceabilityTypes.add(new SelectOption(ref.Id, ref.Name));
    				} else {
    					selectedFields.add(new SelectOption(ref.Id, ref.Name));
    				}
    			}
    		}
		}
    }
    
    /**
     * Method to get data for referenceability Account
     */
    private void getTheDataForReferenceabilityAccount() {
        Set<String> refIds = new Set<String>();
        
        for (Reference_Refresh_Update__c rru : refRefresh.Reference_Refresh_Updates__r) {
            
            if (rru.Removed__c) {
                refIds.add(rru.RecordToBeDeletedId__c);
            }
        }
        
        referenceabilityPresent = [SELECT Id, Account__c, Contact__c, Referenceability_Type__c, Referenceability_Type__r.Id, Referenceability_Type__r.Name 
        							FROM Referenceability__c WHERE Account__c = :refer.Account__c AND Contact__c = null AND Id Not IN :refIds];
    }

    /**
     * Method to get data for referenceability Contact
     */
    private void getTheDataForReferenceabilityContact() {
        Set<String> refIds = new Set<String>();
        
        for (Reference_Refresh_Update__c rru : refRefresh.Reference_Refresh_Updates__r) {
            if (rru.Removed__c) {
                refIds.add(rru.RecordToBeDeletedId__c);
            }
        }
        referenceabilityPresent = [SELECT Id, Account__c, Contact__c, Referenceability_Type__c, Referenceability_Type__r.Id, Referenceability_Type__r.Name 
        							FROM Referenceability__c WHERE Contact__c = :refer.Contact__c AND Id Not IN :refIds];
    }

    /**
     * Method to delete referenceabilities
     */
    public void deleteReferenceability() {
    	
        if (selectedReferenceability != null && selectedReferenceability != '') {
            List<Referenceability__c> tempList = new List<Referenceability__c>();
            
            for (Referenceability__c ref : referenceabilityPresent) {
            	
                if (ref.Id == selectedReferenceability) {
                    Savepoint sp = Database.setSavepoint();
                    refRefreshUpdates = new List<Reference_Refresh_Update__c>();
                    Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                    temp.RecordToBeDeletedId__c = selectedReferenceability;
                    temp.Changed_From__c = ref.Referenceability_Type__r.Name;
                    temp.Removed__c = true;
                    temp.Account__c = ref.Account__c;
                    temp.Contact__c = ref.Contact__c;
                    
                    if (!refRefresh.Quarantined__c) {
                        temp.Accept_Reject__c = 'Accept';
                    }
                    temp.Referenceability__c = true;
                    temp.Reference_Refresh__c = refRefresh.Id;
                    refRefreshUpdates.add(temp);
                } else {
                    tempList.add(ref);
                }
            }
            referenceabilityPresent = new List<Referenceability__c>();
            
            if (tempList.size() > 0) {
                referenceabilityPresent.addAll(tempList);
            } 
            
            if (refRefreshUpdates != null && refRefreshUpdates.size() > 0) {
                WithoutSharingHelperController.upsertRefreshUpdateRecords(refRefreshUpdates);
            }
            
            if (!refRefresh.Quarantined__c) {
                List<Referenceability__c> deleteRef = [SELECT Id FROM Referenceability__c WHERE Id = :selectedReferenceability];
                
                if (deleteRef.size() > 0) {
                    WithoutSharingHelperController.deleteReferenceabilities(deleteRef);
                }
            }
        }
    }
    
    /**
     * Method to get Reference Status
     */
    public void getAccountReferenceStatus() {
        //Shared Contact code start
        String accountFlags = '';
        
        if (selectedAccounts != null && selectedAccounts.size() > 0) {
        	
            for (SelectOption so : selectedAccounts) {
                Reference_Basic_Information__c accRbi = accountIsReferenceableMap.get(so.getValue());
                
                if (!accRbi.Reference_Program_Candidate__c && !accRbi.Is_Referenceable__c) {
                    accountFlags += 'b';
                } else if (accRbi.Reference_Program_Candidate__c) {
                    accountFlags += 'c';
                }
            }
        }
        
        if (accountFlags == '') {
            isAccountReferenceableStatus = true;
            isAccountCandidate = false;
        } else if (accountFlags.contains('b')) {
            isAccountReferenceableStatus = false;
            isAccountCandidate = false;
        } else if (accountFlags.contains('c')) {
            isAccountReferenceableStatus = false;
            isAccountCandidate = true;
        }
    }
    /**
     * Method to save referenceabilities
     */
    public Pagereference save() {
        Savepoint sp = Database.setSavepoint();
        hasError = false;
        refRefreshUpdates = new List<Reference_Refresh_Update__c>();
        try {
        	
            if (selectedFields.size() == 0) {
                hasError = true;
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, ConstantsController.SELECT_REFERENCEABILITY);
                Apexpages.addMessage(message);
                return null;
            }
            //shared contact code start
            Set<String> accountIds = new Set<String>();
            
            if (isSharedContact || !isContactInactive) {
            	
                // Changes for #366
                if (!isFromAccount &&  (refRefresh == null || (refRefresh != null && !refRefresh.Quarantined__c)) &&
                    	selectedAccounts != null && selectedAccounts.size() > 0) {
                    
                    for (SelectOption so : selectedAccounts) {
                        accountIds.add(so.getValue());
                    }
                } else if (isFromAccount && addRefToAllAccountsRBI) {
                	
                    for (SelectOption so : accounts) {
                        accountIds.add(so.getValue());
                    }
                    
                    for (SelectOption so : selectedAccounts) {
                        accountIds.add(so.getValue());
                    }
                } else if (!isFromAccount && refRefresh == null && accounts != null && accounts.size() == 1) {
                    accountIds.add(refer.Account__c);
                }
            }
            //end
            
            if (refRefresh == null || (refRefresh != null && !refRefresh.Quarantined__c)) {
                multipleRefers = new List<Referenceability__c>();
                Set<String> currentReferenceability = new Set<String>();
                
                if (makeAccountMember || makeContactMember || makeAccountCandidate || makeContactCandidate) {
                	
                    if (!isFromAccount && refRefresh == null && selectedAccounts != null && selectedAccounts.size() > 0) {
                        UtilityController.checkRBI(accountIds, refer.Contact__c, makeAccountMember, makeContactMember, 
                        									makeAccountCandidate, makeContactCandidate);
                    } else {
                        UtilityController.checkRBI(refer.Account__c, refer.Contact__c, makeAccountMember, makeContactMember, 
                        									makeAccountCandidate, makeContactCandidate);
                    }
                } else {
                	//changes regarding #645 by rekha
                	accountIds.clear();
                }
                
                for (SelectOption so : selectedFields) {
                	
                    if (refer.Referenceability_Type__c != so.getValue()) {
                        
                        if (isContactInactive || !isContactSelected || !isSharedContact ||
                            (refRefresh != null && !addRefToAllAccountsRBI) || (isFromAccount && accountIds.size() == 0)) {

                            // Changes for #366 - adding referenceabilities to all the selected accounts
                            if (accountIds.size() > 0) {
                            	
                                for (String accId : accountIds) {
                                    Referenceability__c newRefer = new Referenceability__c();
                                    newRefer.Account__c = accId;
                                    
                                    //changes for #870
                                    if (isContactEditable) {
                                    	newRefer.Contact__c = refer.Contact__c;
                                    }
                                    newRefer.Status__c = refer.Status__c;
                                    newRefer.Comment__c = refer.Comment__c;
                                    newRefer.Verified__c = (refer.Verified__c != null ? refer.Verified__c : Date.today());
                                    newRefer.Referenceability_Type__c = so.getValue();
                                    multipleRefers.add(newRefer);
                                }
                            } else {
                                Referenceability__c newRefer = new Referenceability__c();
                                newRefer.Account__c = refer.Account__c;
                                
                                //changes for #870
                                if (isContactEditable) {
                                	newRefer.Contact__c = refer.Contact__c;
                                }
                                newRefer.Status__c = refer.Status__c;
                                newRefer.Comment__c = refer.Comment__c;
                                newRefer.Verified__c = (refer.Verified__c != null ? refer.Verified__c : Date.today());
                                newRefer.Referenceability_Type__c = so.getValue();
                                multipleRefers.add(newRefer);
                            }
                        } else if (isContactSelected && isSharedContact && !isContactInactive) {
                            	
                            if (accountIds.size() > 0) {
                            	
                                for (String accountId : accountIds) {
                                    Referenceability__c newRefer = new Referenceability__c();
                                    newRefer.Account__c = accountId;
                                    
                                    //changes for #870
                                    if (isContactEditable) {
                                    	newRefer.Contact__c = refer.Contact__c;
                                    }
                                    newRefer.Status__c = refer.Status__c;
                                    newRefer.Comment__c = refer.Comment__c;
                                    newRefer.Verified__c = (refer.Verified__c != null ? refer.Verified__c : Date.today());
                                    newRefer.Referenceability_Type__c = so.getValue();
                                    multipleRefers.add(newRefer);
                                    
                                    if (makeContactCandidate) {
                                        break;
                                    }
                                }
                            } else {
                                Referenceability__c newRefer = new Referenceability__c();
                                
                                //changes for #870
                                if (isContactEditable) {
                                	newRefer.Contact__c = refer.Contact__c;
                                }
                                newRefer.Status__c = refer.Status__c;
                                newRefer.Comment__c = refer.Comment__c;
                                newRefer.Verified__c = (refer.Verified__c != null ? refer.Verified__c : Date.today());
                                newRefer.Referenceability_Type__c = so.getValue();
                                multipleRefers.add(newRefer);
                            }
                        }
                    }
                    
                    if (refer.Id != null && refer.Referenceability_Type__c == so.getValue()) {
                        currentReferenceability.add(refer.Id);
                    }
                }
                    
                if (refRefresh != null) {
	
	                if (refer.Id != null && currentReferenceability.contains(refer.Id)) {
	                    multipleRefers.add(refer);
	                } else if (refer.Id != null) {
	                    WithoutSharingHelperController.deleteReferenceabilities(new List<Referenceability__c> { refer });
	                }
	                
	                if (multipleRefers.size() > 0) {
	                    WithoutSharingHelperController.upsertReferenceabilities(multipleRefers);
	                }
                	
                    for (Referenceability__c ref : [SELECT Referenceability_Type__r.Name, Id, Account__c, Contact__c FROM Referenceability__c
                            						WHERE Id IN :multipleRefers ]) {
                        Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                        temp.RecordsToBeInsertedId__c = ref.Id;
                        temp.Account__c = ref.Account__c;
                        temp.Contact__c = ref.Contact__c;
                        temp.Changed_To__c = ref.Referenceability_Type__r.Name;
                        temp.Added__c = true;
                        temp.Referenceability_Verified_Date__c = (refer.Verified__c != null ? refer.Verified__c : Date.today());
                        temp.Referenceability_Status__c = refer.Status__c;
                        temp.ReferenceabilityComment__c = refer.Comment__c;
                        temp.Referenceability__c = true;
                        
                        if (!refRefresh.Quarantined__c) {
                            temp.Accept_Reject__c = 'Accept';
                        }
                        temp.Reference_Refresh__c = refRefresh.Id;
                        refRefreshUpdates.add(temp);
                    }
                    
                    if (refRefreshUpdates.size() > 0) {
                        WithoutSharingHelperController.upsertRefreshUpdateRecords(refRefreshUpdates);
                    }
                } else {
                	
                	if (checkPermissions()) {
	                	
	                	if (refer.Id != null && currentReferenceability.contains(refer.Id)) {
		                    multipleRefers.add(refer);
		                } else if (refer.Id != null) {
		                    delete refer;
		                }
		                
		                if (multipleRefers.size() > 0) {
		                    upsert multipleRefers;
		                }
                	} else {
                		hasError = true;
			            database.rollback(sp);
                	}
                }
            } else {
                	
                for (SelectOption so : selectedFields) {
                	
                    if (!alreadyCreatedPURef.contains(so.getValue())) {
                        // Changes for #366 - Looping over hte account ids set and creating
                        // RRU records for all the selected accounts
                        if (accountIds != null && accountIds.size() > 0) {
                        	
                            for (String accId : accountIds) {
                                Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                                temp.RecordsToBeInsertedId__c = so.getValue();
                                temp.Account__c = accId;
                                temp.Contact__c = refer.Contact__c;
                                temp.Changed_To__c = so.getLabel();
                                temp.Added__c = true;
                                temp.Referenceability_Verified_Date__c = (refer.Verified__c != null ? refer.Verified__c : Date.today());
                                temp.Referenceability_Status__c = refer.Status__c;
                                temp.ReferenceabilityComment__c = refer.Comment__c;
                                temp.Referenceability__c = true;
                                temp.Reference_Refresh__c = refRefresh.Id;
                                refRefreshUpdates.add(temp);
                            }
                        } else {
                            Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                            temp.RecordsToBeInsertedId__c = so.getValue();
                            temp.Account__c = refer.Account__c;
                            temp.Contact__c = refer.Contact__c;
                            temp.Changed_To__c = so.getLabel();
                            temp.Added__c = true;
                            temp.Referenceability_Verified_Date__c = (refer.Verified__c != null ? refer.Verified__c : Date.today());
                            temp.Referenceability_Status__c = refer.Status__c;
                            temp.ReferenceabilityComment__c = refer.Comment__c;
                            temp.Referenceability__c = true;
                            temp.Reference_Refresh__c = refRefresh.Id;
                            refRefreshUpdates.add(temp);
                        }
                    }
                }
                
                if (refRefreshUpdates.size() > 0) {
                    WithoutSharingHelperController.upsertRefreshUpdateRecords(refRefreshUpdates);
                }
            }
            return null;
        } catch (exception e) {
            hasError = true;
            database.rollback(sp);
            return null;
        }
    }
     
    /**
     * Method to cancel page
     */
    public PageReference cancel() {
        isOnlySave = true;
        return redirectToPage();
    }
    
    /**
     * Method to redirect page
     */
    public PageReference redirectToPage() {
        PageReference returnPage;
        
        if (refRefresh == null) {
        	
            if (isOnlySave) {
                returnPage = UtilityController.redirectToSource(returnId);
            } else {
                returnPage = new Pagereference(Page.AddNewReferenceability.getUrl() + '?returl=' + returnId);
            }
        } else {
            returnPage = new Pagereference(Page.ReferenceRefreshPageSLDS.getUrl() +
                '?userId=' + refRefresh.Reference_Refresh_Owner__c +
                '&accountId=' + refRefresh.Reference_Account__c +
                '&helpoverlay=false' +
                '&pageno=' + pageNo);
        }
        returnPage.setRedirect(true);
        return returnPage;
    }

    /**
     * Method to get Reference Status
     */
    public void getReferenceStatus() {
        Set<String> accountIds = new Set<String>();
        
        if (contactIsReferenceableMap.get(selectedContact) != null) {
            Reference_Basic_Information__c conRbi = contactIsReferenceableMap.get(selectedContact);
            isContactReferenceableStatus = conRbi.Is_Referenceable__c;
            isContactCandidate = conRbi.Reference_Program_Candidate__c;
            isContactInactive = (conRbi.Referenceability_Status__c == 'Inactive' ? true : false);
            isContactSelected = true;
            
            //Shared Contact code start
            if (isSharedContact && !isContactInactive) {
                addRefToAllAccountsRBI = (conRbi.Roll_up_Referenceability_to_All_Accounts__c ? true : (conRbi.Roll_up_Referenceability_to_Primary_Acc__c ?
                    false : (cs.Roll_up_Referenceability_to_All_Accounts__c)));
                    
                if (addRefToAllAccountsRBI) {
                    accountIds.add(refer.Account__c);
                    Map<String, Set<String>> contactAccountMap = WithoutSharingHelperController.getRelatedAccounts(new Set<String> { selectedContact }, cs);
                    
                    if (contactAccountMap.containsKey(selectedContact)) {
                        accountIds.addAll(contactAccountMap.get(selectedContact));
                    }
                    
                    for (String accId : accountIds) {
                        accounts.add(new SelectOption(accId, accId));
                    }
                }
            }
            setRefTypes(true);
        } else {
            isContactSelected = false;
        }
        
        if (selectedContact == '') {
            refer.Contact__c = null;
            setRefTypes(false);
        }
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	
    	if (refRefresh == null) {
	    	fieldMap.put(UtilityController.appNamespace() + 'Referenceability__c', new Set<String> {
		        									UtilityController.appNamespace() + 'Account__c',
		        									//UtilityController.appNamespace() + 'Contact__c',
		        									UtilityController.appNamespace() + 'Comment__c',
		        									UtilityController.appNamespace() + 'Status__c',
		        									UtilityController.appNamespace() + 'Verified__c',
		        									UtilityController.appNamespace() + 'Referenceability_Type__c' });
    		//changes for #870
    		if (refer.Contact__c != null) {
    			fieldMap.get(UtilityController.appNamespace() + 'Referenceability__c').add(UtilityController.appNamespace() + 'Contact__c');
    		}
    	} else {
    		fieldMap.put(UtilityController.appNamespace() + 'Referenceability__c', new Set<String> {});
    	}
    	//re #902									
        if (refer.Id != null) {
	        /*Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
			Boolean isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> { 
														UtilityController.appNamespace() + 'Referenceability__c'});
	        return (isUpsertPermission && isDeletePermission);*/
	      	return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);  
        } else {
        	return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        }        
    }
}