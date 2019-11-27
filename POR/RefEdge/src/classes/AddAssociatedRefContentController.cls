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
 * Page: AddAssociatedaccountsandcontacts
 * Description: Class used to associate Account and Contact with reference content.
 * Modified by: Rajesh @18 July 2017
 */
public with sharing class AddAssociatedRefContentController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */ 
    public String returnUrl { get; set; }  
    public String conName { get; set; } 
    public String accName { get; set; }
    public Boolean isSLDS { get; set; }
    public String accountIds { get; set; } 
    public String contactIds { get; set; }
    public Boolean isSaveAndNew { get; set; } 
    public List<AccountWrapper> accountList { get; set; }
    public List<ContactWrapper> contactList { get; set; } 
    public String contentId;
    public String selectedAccountId { get; set; } 
    public Boolean isNewAccount { get; set; }
    public String selectedContactId { get; set; } 
    public Boolean isNewContact { get; set; }
    Set<String> setAcc = new Set<String>();
    Set<String> setCon = new Set<String>();
    Set<String> setAccIds = new Set<String>();
    Set<String> setConIds = new Set<String>();
    /**
     * Constructor
     */
    public AddAssociatedRefContentController() {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        } 
        
        if (!isSLDS) { 
	        accountList = new  List<AccountWrapper>();
	        contactList = new  List<ContactWrapper>(); 
	        conName = '';
	        accName = '';
	         
	        if (Apexpages.currentPage().getParameters().get('refConId') != null) {
                contentId = Apexpages.currentPage().getParameters().get('refConId');
            }  else {
            	redirectBack();
            }
	         
	        for (Account_Reference_Content__c rc : [SELECT Account__c, Account__r.Name FROM Account_Reference_Content__c 
	        												WHERE Reference_Content__c = :contentId ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
	            accountList.add(new accountWrapper(rc.Account__c, rc.Account__r.Name, false));
	            setAcc.add(rc.Account__c);
	        } 
	        
	        for (Contact_Reference_Content__c rc : [SELECT Contact__c, Contact__r.Name, Contact__r.Account.Name FROM Contact_Reference_Content__c 
	        												WHERE Reference_Content__c = :contentId ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
	            contactList.add(new contactWrapper(rc.Contact__c, rc.Contact__r.Name, false, rc.Contact__r.Account.Name));
	            setCon.add(rc.Contact__c);
	        }	       
        }
    }
    
	/**
     * Method to rebind Contact 
     */
	public void reBindContact() { 
		List<String> lstCon = contactIds.split(',');
		contactList = new  List<ContactWrapper>();
		setConIds = new Set<String>();
		
		for (Contact_Reference_Content__c rc : [SELECT Contact__c, Contact__r.Name, Contact__r.Account.Name FROM Contact_Reference_Content__c 
	        												WHERE Reference_Content__c = :contentId 
	        												ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
            contactList.add(new contactWrapper(rc.Contact__c, rc.Contact__r.Name, false, rc.Contact__r.Account.Name));
            setConIds.add(String.valueOf(rc.Contact__c));
        }
		
		for (Contact rc : [SELECT Id, Name, Account.Name FROM Contact WHERE Id IN :lstCon AND Id NOT IN :setConIds ORDER BY Name LIMIT :lstCon.size()]) {
			contactList.add(new contactWrapper(rc.Id, rc.Name, true, rc.Account.Name));
        }  
	}
	
	/**
     * Method to rebind Accounts 
     */
	public void reBindAccount() {  
		List<String> lstAcc = accountIds.split(',');
		accountList = new  List<AccountWrapper>();
		setAccIds = new Set<String>();
		
	 	for (Account_Reference_Content__c rc : [SELECT Account__c, Account__r.Name FROM Account_Reference_Content__c 
	        												WHERE Reference_Content__c = :contentId 
	        												ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
            accountList.add(new accountWrapper(rc.Account__c, rc.Account__r.Name, false));
            setAccIds.add(String.valueOf(rc.Account__c));
        } 
        
	 	for (Account rc : [SELECT Id, Name FROM Account WHERE Id IN :lstAcc AND Id NOT IN :setAccIds ORDER BY Name LIMIT :lstAcc.size()]) {
	 		accountList.add(new accountWrapper(rc.Id, rc.Name, true));
        }  
	}
    
    /**
     * Method to Remove Accounts 
     */
	public void removeAssociatedAccount() {   
		accountList = new  List<AccountWrapper>();
		List<String> lstAcc = new List<String>();
		
		if (!isNewAccount && checkPermissionsForDeletion(true)) {
			List<Account_Reference_Content__c> deleteAcc = new List<Account_Reference_Content__c>();
	            
            for (Account_Reference_Content__c rrac: [SELECT Id, Account__c FROM Account_Reference_Content__c WHERE Account__c =:selectedAccountId]) {
            	deleteAcc.add(rrac);	                
            }
		
			if (deleteAcc.size() > 0) {
            	delete deleteAcc;
			}
		} 
		
		for (Account_Reference_Content__c rc : [SELECT Account__c, Account__r.Name FROM Account_Reference_Content__c 
        												WHERE Reference_Content__c = :contentId ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
            accountList.add(new accountWrapper(rc.Account__c, rc.Account__r.Name, false));
         	setAccIds.add(String.valueOf(rc.Account__c));
        } 
        
		if (accountIds != null) {
			lstAcc =  accountIds.split(',');
			accountIds = ''; 
			
			if (lstAcc.size() > 0) {
			
				for (Integer i = 0; i < lstAcc.size(); i++) {
					
					if (lstAcc.get(i) == selectedAccountId) {
						lstAcc.remove(i);
					} 					
				}
				
				for (Account rc : [SELECT Id, Name FROM Account WHERE Id IN :lstAcc AND Id NOT IN :setAccIds ORDER BY Name LIMIT :lstAcc.size()]) {
		            accountList.add(new accountWrapper(rc.Id, rc.Name, true));
		            
		            if (accountIds == '') {
		            	accountIds += rc.Id;
		            } else {
		            	accountIds += ',' + rc.Id;
		            }
		    	}  
			}
		}  
	}
	
	/**
     * Method to Remove Contact 
     */
	public void removeAssociatedContact() {
		contactList = new  List<ContactWrapper>();
		List<String> lstCon =  new List<String>();
		
		if (!isNewContact && checkPermissionsForDeletion(false)) {
			List<Contact_Reference_Content__c> deleteCon = new List<Contact_Reference_Content__c>();
	        
	        for (Contact_Reference_Content__c rrac : [SELECT Id, Contact__c FROM Contact_Reference_Content__c WHERE Contact__c =:selectedContactId]) {
	        	deleteCon.add(rrac);	                
	        }
		
			if (deleteCon.size() > 0) {
	        	delete deleteCon;
			}
		}
		
		for (Contact_Reference_Content__c rc : [SELECT Contact__c, Contact__r.Name, Contact__r.Account.Name FROM Contact_Reference_Content__c 
	    												WHERE Reference_Content__c = :contentId ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
	        contactList.add(new contactWrapper(rc.Contact__c, rc.Contact__r.Name, false, rc.Contact__r.Account.Name));
	        setConIds.add(String.valueOf(rc.Contact__c));
	    }
	      
		if (contactIds != null) {
			lstCon =  contactIds.split(',');
			contactIds = '';
			
			if (lstCon.size() > 0) {
			
				for (Integer i = 0; i < lstCon.size(); i++) {
					
					if (lstCon.get(i) == selectedContactId) {
						lstCon.remove(i);
					} 
					
				}
				
				for (Contact con : [SELECT Id, Name, Account.Name FROM Contact WHERE Id IN :lstCon AND Id NOT IN :setConIds ORDER BY Name LIMIT :lstCon.size()]) {
		            contactList.add(new contactWrapper(con.Id, con.Name, true, con.Account.Name)); 
		            
		            if (contactIds == '') {
		            	contactIds += con.Id;
		            } else {
		            	contactIds += ',' + con.Id;
		            }
		    	}
			}
		}	  
	}
	
    /**
     * Method to save the Assocted Account and Contact
     */
    public PageReference save() {   	
        savePoint sp = Database.setSavepoint();
        List<Account_Reference_Content__c> associateAccount = new List<Account_Reference_Content__c>(); 
        List<Contact_Reference_Content__c> associateContact = new List<Contact_Reference_Content__c>(); 
	        		      
        try {
        	
        	if (String.isEmpty(accountIds) && String.isEmpty(contactIds) && String.isEmpty(accName) && String.isEmpty(conName)) {
        		ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, System.Label.Add_Account_and_Contact));
        		return null; 
        	}
        	
        	// Add Accounts with premissions
        	if (!String.isEmpty(accountIds)) {
	        	List<String> lstAcc = accountIds.split(',');
	        	    
	        	if (lstAcc.size() > 0 && checkPermissions(true)) { 
	        		
	        		for (String ids : lstAcc) {
	        			
	        			if (!setAcc.contains(ids)) {
	        				associateAccount.add(new Account_Reference_Content__c(Account__c = Id.valueOf(ids), Reference_Content__c = Id.valueOf(contentId)));
	        			}
	        		}  
	        	}
        	}
        	
			if (accName.trim().length() > 0) {
				String searchValue = String.escapeSingleQuotes(accName);
				searchValue = '\'' + searchValue + '\'';
				String soqlQuery = 'SELECT Reference_Owner__c, Account__c FROM Reference_Basic_Information__c '
        						+ 'WHERE Contact__c = null AND Account__c != null AND Account__r.Name = ' + searchValue 
        						+ ' AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
        						+ '\' AND Referenceability_Status__c != \'\') LIMIT 10';
        		List<Reference_Basic_Information__c> rbi = WithoutSharingHelperController.getRBI(soqlQuery);
        		
		        if (rbi.size() > 1) {
		        	ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
		            return null;
		        } else if (rbi.size() == 1) { 
		        	associateAccount.add(new Account_Reference_Content__c(Account__c = rbi[0].Account__c, Reference_Content__c = Id.valueOf(contentId)));
		        } else {
		            searchValue = accName.replace('*', '%') + '%';
			        searchValue = String.escapeSingleQuotes(searchValue);
			        searchValue = '\'' + searchValue + '\'';
			        soqlQuery = 'SELECT Reference_Owner__c, Account__c FROM Reference_Basic_Information__c '
	        				+ ' WHERE Contact__c = null AND Account__c != null AND Account__r.Name LIKE ' + searchValue 
	        				+ ' AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
	        				+ '\' AND Referenceability_Status__c != \'\') LIMIT 10';
            		rbi = WithoutSharingHelperController.getRBI(soqlQuery);
            
		            if (rbi.size() > 1) {
		            	ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
		                return null;
		            } else if (rbi.size() == 0) {
		                ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Account_No_matches_found));
		                return null;
		            } else {
		               associateAccount.add(new Account_Reference_Content__c(Account__c = rbi[0].Account__c, Reference_Content__c = Id.valueOf(contentId)));
		            }
        		}
    		}
           
            if (associateAccount.size() > 0) {  
            	insert  associateAccount;  
            }    
        	 
        	// Add Contact  with premissions
        	if (!String.isEmpty(contactIds)) {
	        	List<String> lstCon = contactIds.split(',');
	        	 
	        	if (lstCon.size() > 0 && checkPermissions(false)) {
	        		
	        		for (String ids : lstCon) { 
	        			
	        			if (!setCon.contains(ids)) { 
	        				associateContact.add(new Contact_Reference_Content__c(Contact__c = Id.valueOf(ids), Reference_Content__c = Id.valueOf(contentId)));
	        			}
	        		} 
	        	}
        	} 
        
        	if (conName.trim().length() > 0) {
                String searchValue = String.escapeSingleQuotes(conName);
                searchValue = '\'' + searchValue + '\'';
                String soqlQuery = 'SELECT Reference_Owner__c, Contact__c FROM Reference_Basic_Information__c ' 
                    					+ ' WHERE Account__c != null AND Contact__c != null AND Contact__r.Name = ' + searchValue 
                    					+ ' AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
                    					+ '\' AND Referenceability_Status__c != \'\') LIMIT 10';
                List<Reference_Basic_Information__c> rbi = WithoutSharingHelperController.getRBI(soqlQuery);
               
                if (rbi.size() > 1) {
                	ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
                    return null;
                } else if (rbi.size() == 1) {
                	associateContact.add(new Contact_Reference_Content__c(Contact__c = rbi[0].Contact__c, Reference_Content__c = Id.valueOf(contentId))); 
                } else {
                    searchValue = conName.replace('*', '%') + '%';
			        searchValue = String.escapeSingleQuotes(searchValue);
			        searchValue = '\'' + searchValue + '\'';
			        soqlQuery = 'SELECT Reference_Owner__c, Contact__c FROM Reference_Basic_Information__c ' 
			        			+ ' WHERE Account__c != null AND Contact__c != null AND Contact__r.Name LIKE ' + searchValue 
			        			+ ' AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
			        			+ '\' AND Referenceability_Status__c != \'\') LIMIT 10';
                    rbi = WithoutSharingHelperController.getRBI(soqlQuery);
                    
                    if (rbi.size() > 1) {
                    	ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
                        return null;
                    } else if (rbi.size() == 0) {
                        ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Contact_No_matches_found));
                        return null;
                    } else { 
                    	associateContact.add(new Contact_Reference_Content__c(Contact__c = rbi[0].Contact__c, Reference_Content__c = Id.valueOf(contentId))); 
                    }
                }
            }  
 			
 			if (associateContact.size() > 0) {
 				insert associateContact;    
 			}
 			
 			if (!isSaveAndNew) {
            	return redirectBack();
 			} else {
 			
 				if (contentId != null) {
	 				PageReference returnPage = new Pagereference(Page.AddAssociatedAccountsAndContacts.getUrl() + '?refConId=' + contentId);
		    		returnPage.setRedirect(true);
		        	return returnPage;
 				} else {
 					return redirectBack();
 				}
 			}
        } catch (Exception e) {   
            Apexpages.addMessages(e);
            Database.rollback(sp);
        }
        return null;
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions(Boolean isAccountUpsert) { 
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();  
    	
		if (isAccountUpsert) {
			fieldMap.put(UtilityController.appNamespace() + 'Account_Reference_Content__c', new Set<String> { 
        										UtilityController.appNamespace() + 'Reference_Content__c',
        										UtilityController.appNamespace() + 'Account__c'});
       		return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
		} else {
			fieldMap.put(UtilityController.appNamespace() + 'Contact_Reference_Content__c', new Set<String> { 
        										UtilityController.appNamespace() + 'Reference_Content__c',
        										UtilityController.appNamespace() + 'Contact__c'});
        	return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false); 
			
		} 
    }
    
    /**
     * Method to check Permissions for deletion
     */
    public static Boolean checkPermissionsForDeletion(Boolean isAccountDeletion) {  
    	
        if (isAccountDeletion) {										
    		return CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Account_Reference_Content__c'});
        } else {
    	 	return CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Contact_Reference_Content__c'});
        } 
    } 
	
    /**
     * Method to cancel the process
     */
    public PageReference redirectBack() {  
        PageReference pageRef = new PageReference('/' + contentId);
   		pageRef.setRedirect(true);
   		return pageRef;
    }
    
    /**
     * Wrapper class
     */
    public class AccountWrapper {
    	public Id id { get; set; }
    	public String name { get; set; }
        public Boolean isNewAdded { get; set; }
        
        public AccountWrapper(Id id, String name, Boolean isNewAdded){
        	this.id = id;
    		this.name = name;
    		this.isNewAdded = isNewAdded;
        }
    }
    
    public class ContactWrapper {
    	public Id id { get; set; }
    	public String name { get; set; }
        public Boolean isNewAdded { get; set; }
        public String contactAccount { get; set; }
        
        public ContactWrapper(Id id, String name, Boolean isNewAdded, String accountName){
        	this.id = id;
    		this.name = name;
    		this.isNewAdded = isNewAdded;
    		this.contactAccount = accountName;
        }
    } 
}