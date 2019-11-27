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
 * Page: AddNewReferenceabilitySLDS 
 * Description: Class used to handle add new Referenceability in lightning
 * Modified by: Rajesh @20 Jan 2017
 */
public with sharing class AddNewReferenceabilitySLDS extends RefEdgeEditionFeatures {
	/**
     * Properties and variables
     */
	//to resolve namespace issue on package creation
    public String nameSpace {
		get {
			return UtilityController.appNamespace();
		}
		private set;
	}
	//re #859
	public String contactRBI { get; set; }
    public String accountRBI { get; set; }
    public String PUMAccountId { get; set; }
    public String pageNo { get; set; }
    public String returnId { get; set; }
    public String accRefRefreshId { get; set; }
    public String conRefRefreshId { get; set; }
    // added for #660 - Gaurav Saini (25 Sep, 2017)
     public String dateString { get; set; }
    // added for #1006 - Gaurav Saini (27 Sep, 2017)
    public String existingAccountId { get; set; }
    public String existingContactId { get; set; }
    
	public AddNewReferenceabilitySLDS(ApexPages.StandardController controller) {
		//re #859
        contactRBI = ApexPages.currentPage().getParameters().get('contactRBI');
        accountRBI = ApexPages.currentPage().getParameters().get('accountRBI');
        accRefRefreshId = ApexPages.currentPage().getParameters().get('accRefRefreshId') != null ? ApexPages.currentPage().getParameters().get('accRefRefreshId') : '';
        conRefRefreshId = ApexPages.currentPage().getParameters().get('conRefRefreshId') != null ? ApexPages.currentPage().getParameters().get('conRefRefreshId') : '';
        PUMAccountId = Apexpages.currentPage().getParameters().get('PUMAccountId') != null ? Apexpages.currentPage().getParameters().get('PUMAccountId') : '';
        pageNo = Apexpages.currentPage().getParameters().get('pageno') != null ? Apexpages.currentPage().getParameters().get('pageno') : '';
        returnId = ApexPages.currentPage().getParameters().get('retURL') != null ? ApexPages.currentPage().getParameters().get('retURL') : '';
        // added for #660 - Gaurav Saini (25 Sep, 2017)
        dateString = String.valueOf(Date.today());
        // added for #1006
    	Referenceability__c ref = (Referenceability__c)controller.getRecord();
    	
        if (ref.Id != null) {
            ref = [SELECT Id, Account__c, Contact__c FROM Referenceability__c WHERE Id = :ref.Id];
        }
    	existingAccountId = ref.Account__c != null ? (String)ref.Account__c : '';
        existingContactId = ref.Contact__c != null ? (String)ref.Contact__c : '';
	}
	
	public AddNewReferenceabilitySLDS() {}
	
	/**
     * Method to get Account Wrapper List
     */
	@RemoteAction
	public static String getAccountWrapperList(String refContactId, String refAccountId) {
		List<AccountWrapper> accountWrapList = new List<AccountWrapper>();
		List<String> accIdList = new List<String>();
		
		if ((refContactId != null && refContactId != '' && (refAccountId == null || refAccountId == '')) || (refContactId != null && refContactId != '' && refAccountId != null && refAccountId != '')) {
			Custom_Settings__c cs = UtilityController.getCustomSettings();
			String objectName = cs.Shared_Contact_Object__c;
	        String accountField = cs.Shared_Account_Field__c;
	        String contactField = cs.Shared_Contact_Field__c;
	        String contactId = (refContactId != null ? refContactId : '');
	        
	        Contact tempContact = [SELECT AccountId FROM Contact WHERE Id = :contactId];
	        String primaryAccId = tempContact.AccountId;
	        accIdList.add(primaryAccId);
	        
	        if (accountField != null && accountField != '' && contactField != null && contactField != '') {
				String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName
											+ ' WHERE ' + contactField + ' = :contactId';
	        	
				List<sObject> objectList = Database.query(query);
				
				if (objectList != null && objectList.size() > 0) {
					
					for (sObject obj : objectList) {
						accIdList.add((String)obj.get(accountField));
					}
		        }
	        }
	        
			for (Account acc : [SELECT Id, Name,
								(SELECT Reference_Program_Candidate__c,Generic_Account__c, Is_Referenceable__c FROM Reference_Basic_Informations__r WHERE Contact__c = null)
								FROM Account
								WHERE Id IN :accIdList]) {
				//to exclude generic account
        		if (acc.Reference_Basic_Informations__r.size() == 0 || (acc.Reference_Basic_Informations__r.size() > 0 && !acc.Reference_Basic_Informations__r[0].Generic_Account__c)) {
					
					if (acc.Reference_Basic_Informations__r != null && acc.Reference_Basic_Informations__r.size() > 0) {
						accountWrapList.add(new AccountWrapper(acc.Id,
																acc.Name,
																acc.Reference_Basic_Informations__r[0].Is_Referenceable__c,
																acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c));
					} else {
						accountWrapList.add(new AccountWrapper(acc.Id, acc.Name, false, false));
					}
        		}
			}
		}
        return JSON.serialize(accountWrapList);
	}
	
	/**
     * Method to get ReferenceabilityObj
     */
	@RemoteAction
	public static String getReferenceabilityObj(String refId) {
		
		if (refId != null && refId != '') {
			Referenceability__c refObj = [SELECT Referenceability_Type__c, Verified__c, Id, Contact__r.Name, Contact__c,
											Account__r.Name, Account__c, Comment__c
											FROM Referenceability__c
											WHERE Id = :refId];
			return JSON.serialize(refObj);
		} else {
			return '';
		}
	}
	/**
     * Method to get Date Format #1070 by Dixita 11/2017
     */
    @RemoteAction
    public static String getDateFormat() {   
    		String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
    		return dateFormat; 
    }
    
	/**
     * Method to get Contact Wrapper List
     */
	@RemoteAction
	public static String getContactWrapperList(String refContactId, String refAccountId) {
		List<ContactWrapper> contactWrapList = new List<ContactWrapper>();
		contactWrapList.add(new ContactWrapper('', '--None--', 'false', 'false'));
		
		if (refAccountId != null && (refContactId == null || refContactId == '')) {
			
			for (Contact con : WithoutSharingHelperController.getAccountContacts(refAccountId,null)) {
				
				if (con.Reference_Basic_Informations__r.size() > 0) {
					contactWrapList.add(new ContactWrapper(con.id,
															con.Name,
															String.valueOf(con.Reference_Basic_Informations__r[0].Is_Referenceable__c),
															String.valueOf(con.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)));
				} else {
					contactWrapList.add(new ContactWrapper(con.id, con.Name, 'false', 'false'));
				}
			}
			return JSON.serialize(contactWrapList);
		}
		return '';
	}
	
	/**
     * Method to get RefType Wrapper List
     */
	@RemoteAction
	public static String getRefTypeWrapperList() {
		List<ReferenceabilityTypeWrapper> refTypeWrapList = new List<ReferenceabilityTypeWrapper>();
		
		//field added to query regarding #570 
		for (Referenceability_Type__c refType : [SELECT Id, Name, Ref_Limit_to_Acct_or_Cntct__c FROM Referenceability_Type__c
														WHERE Referenceability_Type__c = true
														AND Visible__c = true AND Sales_Reward__c = false
														ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
			refTypeWrapList.add(new ReferenceabilityTypeWrapper(refType.Id, refType.Name, refType.Ref_Limit_to_Acct_or_Cntct__c));
		}
		return JSON.serialize(refTypeWrapList);
	}
	
	/**
     * Method to get StatusPickList
     */
	@RemoteAction
	public static String getStatusPickList() {
		List<String> options = new List<String>();
		Schema.DescribeFieldResult dfr = Schema.sObjectType.Referenceability__c.fields.getMap().get(UtilityController.appNamespace() + 'Status__c').getDescribe();
		List<Schema.PicklistEntry> ple = dfr.getPicklistValues();
		
		for (Schema.PicklistEntry f : ple) {
            options.add(String.valueOf(f.value));
        }
        return JSON.serialize(options);
	} 
	
	/**
     * Method to get Contact Reference Status
     */
	@RemoteAction
	public static String getContactReferenceStatus(String contactId) {
		List<Contact> conRBIList = [SELECT Name, Id, Account.Name, AccountId,
										(SELECT Reference_Program_Candidate__c, Is_Referenceable__c FROM Reference_Basic_Informations__r)
										FROM Contact c WHERE Id = :contactId];
		String result = 'false,false,,';				
		
		if (conRBIList != null && conRBIList.size() > 0) {
			
			if (conRBIList[0].Reference_Basic_Informations__r != null && conRBIList[0].Reference_Basic_Informations__r.size() > 0) {
				
				if (conRBIList[0].Reference_Basic_Informations__r[0].Is_Referenceable__c && !conRBIList[0].Reference_Basic_Informations__r[0].Reference_Program_Candidate__c) {
					result = 'true,false,' + conRBIList[0].Name + ',' + conRBIList[0].Account.Name;
				} else if (!conRBIList[0].Reference_Basic_Informations__r[0].Is_Referenceable__c && conRBIList[0].Reference_Basic_Informations__r[0].Reference_Program_Candidate__c) {
					result = 'false,true,' + conRBIList[0].Name + ',' + conRBIList[0].Account.Name;
				} else if (!conRBIList[0].Reference_Basic_Informations__r[0].Is_Referenceable__c && !conRBIList[0].Reference_Basic_Informations__r[0].Reference_Program_Candidate__c) {
					result = 'false,false,' + conRBIList[0].Name + ',' + conRBIList[0].Account.Name;
				}
			} else {
				result = 'false,false,' + conRBIList[0].Name + ',' + conRBIList[0].Account.Name;
			}
		}
		return result;
	}
	
	/**
     * Method to get Account Reference Status
     */
	@RemoteAction
	public static String getAccountReferenceStatus(String accId) {
		List<Reference_Basic_Information__c> accRBIList = [SELECT Reference_Program_Candidate__c, Is_Referenceable__c, Account__r.Name, Account__c
															FROM Reference_Basic_Information__c
															WHERE Account__c = :accId
															AND Contact__c = null];
		String result = 'false,false,';				 
		
		if (accRBIList != null && accRBIList.size() > 0) {
			
			if (accRBIList[0].Is_Referenceable__c && !accRBIList[0].Reference_Program_Candidate__c) {
				result = 'true,false,' + accRBIList[0].Account__r.Name;
			} else if (!accRBIList[0].Is_Referenceable__c && accRBIList[0].Reference_Program_Candidate__c) {
				result = 'false,true,' + accRBIList[0].Account__r.Name;
			} else if (!accRBIList[0].Is_Referenceable__c && !accRBIList[0].Reference_Program_Candidate__c) {
				result = 'false,false,' + accRBIList[0].Account__r.Name;
			}
		} else {
			List<Account> accList = [SELECT Id, Name FROM Account WHERE Id = :accId];
			
			if (accList.size() > 0) {
				result = 'false,false,' + accList[0].Name;
			}
		}
		return result;
	}
	
	/**
     * RemoteAction to get insufficient permmission message
     */
    @RemoteAction
    public static String getPermissionsMessage(Boolean isFromProfileUpdate, Boolean isEdit) {
		checkPermissions(isFromProfileUpdate, isEdit);
		return CRUDAndFLSCheckController.getErrorMsg();
    }
	
	/**
     * Method to save Referenceability
     */
	@RemoteAction
	public static String saveReferenceability(String referenceabilityWrapperJSON, Boolean makeAccountMember,
								Boolean makeAccountCandidate, Boolean makeContactMember, Boolean makeContactCandidate,
								String existingRefObjectJSON, String profileUpdateWrapperJSON, String alreadyCreatedPURefJSON,
								Boolean isFromProfileUpdate, Boolean isEdit) {
		
		if (checkPermissions(isFromProfileUpdate, isEdit)) {
			ReferenceabilityWrapper refWrapperObject = (ReferenceabilityWrapper)JSON.deserialize(referenceabilityWrapperJSON, ReferenceabilityWrapper.class);
			ProfileUpdateWrapper profileUpdateWrapperObj = profileUpdateWrapperJSON != '' ? (ProfileUpdateWrapper)JSON.deserialize(profileUpdateWrapperJSON, ProfileUpdateWrapper.class) : null;
			Savepoint sp = Database.setSavepoint();
			String errorMessage = 'Error';
			Referenceability__c existingRefObject = new Referenceability__c();
			Boolean isContactEditable = Schema.sObjectType.Referenceability__c.fields.Contact__c.isCreateable();
			List<Reference_Refresh_Update__c> refRefreshUpdates = new List<Reference_Refresh_Update__c>();
			Set<String> alreadyCreatedPURef = alreadyCreatedPURefJSON != '' ? (Set<String>)JSON.deserialize(alreadyCreatedPURefJSON, Set<String>.class) : new Set<String>();
			
			if (existingRefObjectJSON != '') {
				existingRefObject = (Referenceability__c)JSON.deserialize(existingRefObjectJSON, Referenceability__c.class);
			}
			
			try {
				List<Referenceability__c> refListToUpsert = new List<Referenceability__c>();
				List<String> selectedAccIds = new List<String>();
				Custom_Settings__c cs = UtilityController.getCustomSettings();
				Boolean isSharedContacts = cs.Shared_Contacts__c;
				List<Contact> conList = WithoutSharingHelperController.getContactRecordsforLookup(new Set<String>{((refWrapperObject.selectedContact != null && refWrapperObject.selectedContact != '') ? refWrapperObject.selectedContact : '')}, 1);
				Boolean addRefToAllAccountsRBI = false;
				
				if (conList != null && conList.size() > 0 && conList[0].Reference_Basic_Informations__r.size() > 0) {
					addRefToAllAccountsRBI = (conList[0].Reference_Basic_Informations__r[0].Roll_up_Referenceability_to_All_Accounts__c ? true : (conList[0].Reference_Basic_Informations__r[0].Roll_up_Referenceability_to_Primary_Acc__c ? false : (cs.Roll_up_Referenceability_to_All_Accounts__c)));
				}
				
				if (conList != null && conList.size() > 0) {
					
					if (!isSharedContacts) {
						selectedAccIds.add(conList[0].AccountId);
					} else {
						
						if (addRefToAllAccountsRBI) {
							
							for (AccountWrapper acc : refWrapperObject.selectedAccounts) {
								selectedAccIds.add(acc.id);
							}
						} else {
							selectedAccIds.add(conList[0].AccountId);
						}
					}
				} else {
					selectedAccIds.add(String.valueOf(refWrapperObject.selectedAccounts[0].id));
				} 
            	Set<String> idSetAccount = new Set<String>();
            	idSetAccount.addAll(selectedAccIds);
            	
            	if (profileUpdateWrapperObj == null || (profileUpdateWrapperObj != null && !profileUpdateWrapperObj.isQuarantined)) {
            		UtilityController.checkRBI(idSetAccount, refWrapperObject.selectedContact, makeAccountMember, makeContactMember, makeAccountCandidate, makeContactCandidate);
					
					for (ReferenceabilityTypeWrapper refType : refWrapperObject.selectedRefTypes) {
						
						if (refType.id != '') {
							
							for (String accId : selectedAccIds) {
								
								if (existingRefObjectJSON != '' && existingRefObject != null && existingRefObject.Referenceability_Type__c == refType.id) {
									existingRefObject.Account__c = accId;
			                        
			                        if (isContactEditable) {
				                        existingRefObject.Contact__c = (refWrapperObject.selectedContact != '' ? refWrapperObject.selectedContact : null);
			                        }
			                        existingRefObject.Status__c = refWrapperObject.refStatus;
			                        existingRefObject.Comment__c = refWrapperObject.comments;
			                        existingRefObject.Verified__c = (refWrapperObject.verifiedDate != null ? refWrapperObject.verifiedDate : Date.today());
			                        existingRefObject.Referenceability_Type__c = refType.id;
			                        refListToUpsert.add(existingRefObject);
								} else {
									Referenceability__c tempObj = new Referenceability__c();
									tempObj.Account__c = accId;
			                        
			                        if (isContactEditable) {
				                        tempObj.Contact__c = (refWrapperObject.selectedContact != '' ? refWrapperObject.selectedContact : null);
			                        }
			                        tempObj.Status__c = refWrapperObject.refStatus;
			                        tempObj.Comment__c = refWrapperObject.comments;
			                        tempObj.Verified__c = (refWrapperObject.verifiedDate != null ? refWrapperObject.verifiedDate : Date.today());
			                        tempObj.Referenceability_Type__c = refType.id;
			                        refListToUpsert.add(tempObj);
								}
							}
						}
					}
					
					if (refListToUpsert.size() > 0) { 
						 upsert refListToUpsert;
					}
					
					if (profileUpdateWrapperObj != null) {
	                	
	                    for (Referenceability__c ref : [SELECT Referenceability_Type__r.Name, Id, Account__c, Contact__c
	                    								FROM Referenceability__c
	                            						WHERE Id IN :refListToUpsert]) {
	                        Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
	                        temp.RecordsToBeInsertedId__c = ref.Id;
	                        temp.Account__c = ref.Account__c;
	                        temp.Contact__c = ref.Contact__c;
	                        temp.Changed_To__c = ref.Referenceability_Type__r.Name;
	                        temp.Added__c = true;
	                        temp.Referenceability_Verified_Date__c = (refWrapperObject.verifiedDate != null ? refWrapperObject.verifiedDate : Date.today());
	                        temp.Referenceability_Status__c = refWrapperObject.refStatus;
	                        temp.ReferenceabilityComment__c = refWrapperObject.comments;
	                        temp.Referenceability__c = true;
	                        
	                        if (!profileUpdateWrapperObj.isQuarantined) {
	                            temp.Accept_Reject__c = 'Accept';
	                        }
	                        temp.Reference_Refresh__c = profileUpdateWrapperObj.id;
	                        refRefreshUpdates.add(temp);
	                    }
	                    
	                    if (refRefreshUpdates.size() > 0) {
	                        WithoutSharingHelperController.upsertRefreshUpdateRecords(refRefreshUpdates);
	                    }
	                }
            	} else {
            		
            		for (ReferenceabilityTypeWrapper refType : refWrapperObject.selectedRefTypes) {
            			
            			if (!alreadyCreatedPURef.contains(refType.id)) {
            				
            				for (String accId : selectedAccIds) {
            					Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                                temp.RecordsToBeInsertedId__c = refType.id;
                                temp.Account__c = accId;
                                temp.Contact__c = refWrapperObject.selectedContact != '' ? refWrapperObject.selectedContact : null;
                                temp.Changed_To__c = refType.name;
                                temp.Added__c = true;
                                temp.Referenceability_Verified_Date__c = (refWrapperObject.verifiedDate != null ? refWrapperObject.verifiedDate : Date.today());
                                temp.Referenceability_Status__c = refWrapperObject.refStatus;
                                temp.ReferenceabilityComment__c = refWrapperObject.comments;
                                temp.Referenceability__c = true;
                                temp.Reference_Refresh__c = profileUpdateWrapperObj.id;
                                refRefreshUpdates.add(temp);
            				}
            			}
            		}
	                
	                if (refRefreshUpdates.size() > 0) {
	                    WithoutSharingHelperController.upsertRefreshUpdateRecords(refRefreshUpdates);
	                }
            	}
			} catch (DMLException e) {
				errorMessage += e.getDmlMessage(0);
				Database.rollback(sp);
				return errorMessage;
			} catch (Exception e) {
				errorMessage += e.getMessage();
				Database.rollback(sp);
				return errorMessage;
	        }
			return '';
		} else {
			return 'Error :' + CRUDAndFLSCheckController.getErrorMsg();
		}
	}
	
	/**
     * Method to check Permissions
     */
    public static Boolean checkPermissions(Boolean isFromProfileUpdate, Boolean isEdit) {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>(); 
    	Boolean isUpsertPermission = false; 
       	
       	if (!isFromProfileUpdate) {
       		fieldMap.put(UtilityController.appNamespace() + 'Referenceability__c', new Set<String> {
	   						UtilityController.appNamespace() + 'Account__c',
	   						UtilityController.appNamespace() + 'Contact__c',
	   						UtilityController.appNamespace() + 'Status__c',
	   						UtilityController.appNamespace() + 'Comment__c',
	   						UtilityController.appNamespace() + 'Verified__c',
	   						UtilityController.appNamespace() + 'Referenceability_Type__c'});
       	} else {
       		fieldMap.put(UtilityController.appNamespace() + 'Referenceability__c', new Set<String>());
       	}
       	
       	if (isEdit) {
       		return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
       	} else {
       		return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
       	}
    }
    
    /**
     * Method to get profile update record
     */
	@RemoteAction
	public static String getProfileUpdateRecord(String profileUpdateId) {
		List<ProfileUpdateWrapper> profileUpdateList = new List<ProfileUpdateWrapper>();
		List<Reference_Refresh__c> refRefreshs = WithoutSharingHelperController.getReferenceRefreshOnAddRef(profileUpdateId);
        
        if (refRefreshs.size() > 0) {
        	profileUpdateList.add(new ProfileUpdateWrapper(refRefreshs[0]));
        }
        return JSON.serialize(profileUpdateList);
	}
	
	/**
     * Method to get profile referenceability records
     */
	@RemoteAction
	public static String getProfileUpdateRefData(List<String> refIds, String accId, String conId) {
		List<ProfileUpdateRefWrapper> refWrapperList = new List<ProfileUpdateRefWrapper>();
		
		if (accId != '') {
			
			for (Referenceability__c ref : [SELECT Id, Account__c, Contact__c, Referenceability_Type__c,
											Referenceability_Type__r.Id, Referenceability_Type__r.Name
											FROM Referenceability__c WHERE Account__c = :accId
											AND Contact__c = null
											AND Id NOT IN :refIds]) {
				refWrapperList.add(new ProfileUpdateRefWrapper(ref));
			}
		} else {
			
			for (Referenceability__c ref : [SELECT Id, Account__c, Contact__c, Referenceability_Type__c,
											Referenceability_Type__r.Id, Referenceability_Type__r.Name
											FROM Referenceability__c WHERE Contact__c = :conId
											AND Id NOT IN :refIds]) {
				refWrapperList.add(new ProfileUpdateRefWrapper(ref));
			}
		}
		return JSON.serialize(refWrapperList);
	}
	
	/**
     * Method to delete referenceability
     */
	@RemoteAction
	public static String deleteReferenceability(String refId, String refsPresentJSON, Boolean isQuarantined, String refRefreshId) {
		List<ProfileUpdateRefWrapper> refsPresent = (List<ProfileUpdateRefWrapper>)JSON.deserialize(refsPresentJSON, List<ProfileUpdateRefWrapper>.class);
		List<Reference_Refresh_Update__c> refRefreshUpdates = new List<Reference_Refresh_Update__c>();
		
		for (ProfileUpdateRefWrapper ref : refsPresent) {
			
			if (ref.refId == refId) {
				Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                temp.RecordToBeDeletedId__c = refId;
                temp.Changed_From__c = ref.refTypeName;
                temp.Removed__c = true;
                temp.Account__c = ref.accountId != '' ? ref.accountId : null;
                temp.Contact__c = ref.contactId != '' ? ref.contactId : null;
                
                if (!isQuarantined) {
                    temp.Accept_Reject__c = 'Accept';
                }
                temp.Referenceability__c = true;
                temp.Reference_Refresh__c = refRefreshId;
                refRefreshUpdates.add(temp);
			}
		}
		
        if (refRefreshUpdates != null && refRefreshUpdates.size() > 0) {
            WithoutSharingHelperController.upsertRefreshUpdateRecords(refRefreshUpdates);
        }
        
        if (!isQuarantined) {
            List<Referenceability__c> deleteRef = [SELECT Id FROM Referenceability__c WHERE Id = :refId];
            
            if (deleteRef.size() > 0) {
                WithoutSharingHelperController.deleteReferenceabilities(deleteRef);
            }
        }
        return '';
	}
    
	/**
     * Contact Wrapper
     */
	public class ContactWrapper {
		String id { get; set; }
		String name { get; set; }
		String refProgramMember { get; set; }
		String refProgramCandidate { get; set; }
		
		/**
     	 * Constructor
     	 */
		public ContactWrapper(String id, String name, String refProgramMember, String refProgramCandidate) {
			this.id = id;
			this.name = name;
			this.refProgramMember = refProgramMember;
			this.refProgramCandidate = refProgramCandidate;
		}
	}
	
	/**
     * Account Wrapper
     */
	public class AccountWrapper {
		String id { get; set; }
		String name { get; set; }
		Boolean refProgramMember { get; set; }
		Boolean refProgramCandidate { get; set; }
		
		/**
     	 * Constructor
     	 */
		public AccountWrapper(String id, String name, Boolean refProgramMember, Boolean refProgramCandidate) {
			this.id = id;
			this.name = name;
			this.refProgramMember = refProgramMember;
			this.refProgramCandidate = refProgramCandidate;
		}
	}
	
	/**
     * ReferenceabilityType Wrapper
     */
	public class ReferenceabilityTypeWrapper {
		String id { get; set; }
		String name { get; set; }
		//changes regarding #570 
		Boolean avaliableForAccount { get; set; }
		Boolean avaliableForContact { get; set; }
		
		public ReferenceabilityTypeWrapper(String id, String name, String option) {
			this.id = id;
			this.name = name;
			this.avaliableForAccount = (option == null || option == '' || option == 'Account' ? true : false);
			this.avaliableForContact = (option == null || option == '' || option == 'Contact' ? true : false);
		}
	}
	
	/**
     * Constructor
     */
	public class ReferenceabilityWrapper {
        public String selectedContact { get; set; }
        public List<AccountWrapper> selectedAccounts { get; set; }
        public List<ReferenceabilityTypeWrapper> selectedRefTypes { get; set; }
        public String refStatus { get; set; }
        public String comments { get; set; }
        public Date verifiedDate { get; set; }
        
        public ReferenceabilityWrapper() {}
    }
    
    public class ProfileUpdateWrapper {
    	public String id { get; set; }
    	public Boolean isQuarantined { get; set; }
    	public String ownerId { get; set; }
    	public List<ProfileUpdateDetailWrapper> profileUpdateDetailList { get; set; }
    	
    	public ProfileUpdateWrapper(Reference_Refresh__c rr) {
    		this.id = rr.Id;
    		this.isQuarantined = rr.Quarantined__c;
    		this.ownerId = rr.Reference_Refresh_Owner__c;
    		this.profileUpdateDetailList = new List<ProfileUpdateDetailWrapper>();
    		
    		for (Reference_Refresh_Update__c rru : rr.Reference_Refresh_Updates__r) {
    			this.profileUpdateDetailList.add(new ProfileUpdateDetailWrapper(rru));
    		}
    	}
    }
    
    public class ProfileUpdateDetailWrapper {
    	public String accountId { get; set; }
    	public String contactId { get; set; }
    	public Boolean isAdded { get; set; }
    	public Boolean isRemoved { get; set; }
    	public String recordsToBeInsertedId { get; set; }
    	public String recordToBeDeletedId { get; set; }
    	
    	public ProfileUpdateDetailWrapper(Reference_Refresh_Update__c rru) {
    		this.accountId = rru.Account__c != null ? (String)rru.Account__c : '';
    		this.contactId = rru.Contact__c != null ? (String)rru.Contact__c : '';
    		this.isAdded = rru.Added__c;
    		this.isRemoved = rru.Removed__c;
    		this.recordsToBeInsertedId = rru.RecordsToBeInsertedId__c != null ? rru.RecordsToBeInsertedId__c : '';
    		this.recordToBeDeletedId = rru.RecordToBeDeletedId__c != null ? rru.RecordToBeDeletedId__c : '';
    	}
    }
    
    public class ProfileUpdateRefWrapper {
    	public String refId { get; set; }
    	public String refTypeName { get; set; }
    	public String accountId { get; set; }
    	public String contactId { get; set; }
    	
    	public ProfileUpdateRefWrapper(Referenceability__c ref) {
    		this.refId = ref.Id;
    		this.refTypeName = ref.Referenceability_Type__r.Name;
    		this.accountId = ref.Account__c != null ? (String)ref.Account__c : '';
    		this.contactId = ref.Contact__c != null ? (String)ref.Contact__c : '';
    	}
    }
}