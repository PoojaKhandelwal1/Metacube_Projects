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
 * Page: IssueReward
 * Description: Class used to issue rewards
 * Modified by: Rajesh @June 6 2017
 */
public with sharing class IssueRewardController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    private Map<String, Decimal> mapRewardsPoints = new Map<String, Decimal>();
    private Map<Id, Contact> contactMap;
    private Map<Id, Account> accountMap;
    private String retUrl;
    private String contactAccountId;
    public Reward__c reward { get; set; }
    public String accountId { get; set; }
    public String contactId { get; set; }
    public String userId { get; set; }
    public Boolean accountReferenceability { get; set; }
    public Boolean contactReferenceability { get; set; }
    public String selectedContact { get; set; }
    public Boolean isContactSelected { get; set; }
    public String selectedAccount { get; set; }
    public Boolean isAccountSelected { get; set; }
    public Map<String, Boolean> contactIsReferenceableMap { get; set; }
    public Map<String, Boolean> accountIsReferenceableMap { get; set; }
    public String status { get; set; }	// Resference status msg - displayed if account/contact is not an active member
    public Boolean isSalesUser { get; set; }
    public Boolean isLimitExceeded { get; set; }
    public Boolean isSLDS { get; set; }
    // re #1112 - Added return URL 
    public String returnUrl { get; set; }
    
    /**
     * Constructor
     */ 
    public IssueRewardController() {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
       
        if (!isSLDS) { 
	        accountId = (ApexPages.currentPage().getParameters().get('AccountId') != null) ? ApexPages.currentPage().getParameters().get('AccountId') : '';
	        contactId = (ApexPages.currentPage().getParameters().get('ContactId') != null) ? ApexPages.currentPage().getParameters().get('ContactId') : ''; 
	        userId = (ApexPages.currentPage().getParameters().get('userId') != null) ? ApexPages.currentPage().getParameters().get('userId') : '';  
	        retUrl = (ApexPages.currentPage().getParameters().get('retUrl') != null) ? ApexPages.currentPage().getParameters().get('retUrl') : ''; 
	        isLimitExceeded = false;
	        isContactSelected = false;
	        isAccountSelected = false;
	        contactAccountId = '';
	        isSalesUser = false; 
	        Custom_Settings__c cs = UtilityController.getCustomSettings();
	        status = ConstantsController.REFERENCE_STATUS_MSG.replace('@@@3', cs.Default_Referenceablity_Status__c);
	        status = status.replace('@@@2', System.Label.reward);
	        contactIsReferenceableMap = new Map<String, Boolean>();
	        accountIsReferenceableMap = new Map<String, Boolean>();
	        
	        if (contactId != null && contactId != '') {
	        	Contact contact = new Contact();
	            List<Contact> contacts = [SELECT Id, Name, Account.Name, AccountId,
						            			(SELECT Name, Contact__c, Account__c, Reference_Program_Candidate__c,
						            				Is_Referenceable__c, Referenceability_Status__c
						            				FROM Reference_Basic_Informations__r)
						        				FROM Contact
						        				WHERE Id = :contactId LIMIT :limits.getLimitQueryRows()];
	            
	            if (contacts.size() > 0) {
	            	contact = contacts[0];
	            }
	            
	            if (contact.Reference_Basic_Informations__r != null && contact.Reference_Basic_Informations__r.size() > 0) {
	                contactReferenceability = contact.Reference_Basic_Informations__r[0].Is_Referenceable__c;
	            } else {
	                contactReferenceability = false;
	            }
	            isContactSelected = true;
	            reward = new Reward__c(Contact__c = contactId, Amount__c = 0, Transaction__c = ConstantsController.ISSUE, 
	            						Expiration_Date__c = UtilityController.rewardsExpritationDate(cs), RewardDate__c = Date.Today());
	            accountMap = new Map<Id, Account>();
	            Set<String> tempAccountIds = new Set<String>();
	            tempAccountIds.add(contact.AccountId);
	            selectedAccount = contact.AccountId;
	            contactAccountId = contact.AccountId;
	            Map<String, Set<String>> contactAccountMap = UtilityController.getRelatedAccounts(new Set<String>{contactId}, cs);
	        	
	        	if (contactAccountMap != null && contactAccountMap.containsKey(contact.Id)) {
	        		
		        	for (String accId : contactAccountMap.get(contact.Id)) {
		        		tempAccountIds.add(accId);
		        	}
	        	}
	        	
	        	for (Account acc : [SELECT Id, Name, (SELECT Reference_Program_Candidate__c, Is_Referenceable__c,
	        								Referenceability_Status__c, Generic_Account__c
	        								FROM Reference_Basic_Informations__r WHERE Contact__c = null)
	    								FROM Account WHERE Id IN :tempAccountIds]) {
					
	        		if (acc.Reference_Basic_Informations__r.size() == 0 || (acc.Reference_Basic_Informations__r.size() > 0 
	        				&& !acc.Reference_Basic_Informations__r[0].Generic_Account__c)) {
	        			accountMap.put(acc.Id, acc);
					}
					
					if (acc.Id == selectedAccount && acc.Reference_Basic_Informations__r.size() > 0) {
						accountReferenceability = acc.Reference_Basic_Informations__r[0].Is_Referenceable__c;
					} else {
						accountReferenceability = false;
					}
	        	}
	        	
	        	if (accountMap.size() > 1000) {
	        		isLimitExceeded = true;
	        	}
	        	
	        	//Set return URL for cancel action - re #1112
	        	returnUrl = contactId;
	        } else if (accountId != null && accountId != '') {
	            List<Account> accounts = [SELECT Id, Name, (SELECT Name, Account__c, Contact__r.Name, Contact__c,
	            							Reference_Program_Candidate__c, Is_Referenceable__c, Referenceability_Status__c 
				            				FROM Reference_Basic_Informations__r WHERE Contact__c = null) 
				            				FROM Account WHERE Id = :accountId LIMIT :limits.getLimitQueryRows()];
	            
	            if (accounts.size() > 0) {
	            	
	            	if (accounts[0].Reference_Basic_Informations__r.size() > 0) {
		                accountReferenceability = accounts[0].Reference_Basic_Informations__r[0].Is_Referenceable__c;
		            } else {
		                accountReferenceability = false;
		            }
	            } 
	            
	            // Changes for #366
	            contactMap = new Map<Id, Contact>();
	            
	            for (Contact con : UtilityController.getAccountContacts(accountId, cs)) {
	            	contactMap.put(con.Id, con);
	            }
	            reward = new Reward__c(Amount__c = 0, Transaction__c = ConstantsController.ISSUE, 
	            					Expiration_Date__c = UtilityController.rewardsExpritationDate(cs), RewardDate__c = Date.Today());
				
	        	if (contactMap.size() > 999) {
	        		isLimitExceeded = true;
	        	}
	        	
	        	//Set return URL for cancel action - re #1112
	        	returnUrl = accountId;
	        } else if (userId != null && userId != '') {
	        	reward = new Reward__c(User__c = userId, Amount__c = 0, Transaction__c = ConstantsController.ISSUE, 
	        							Expiration_Date__c = UtilityController.rewardsExpritationDate(cs), RewardDate__c = Date.Today());
	    		isSalesUser = true;
	    		returnUrl = Page.SalesUserProfile.getUrl() + '?Id=' + userId;
	        } 
	        
	        if (accountId != null && accountId != '') {
	            reward.Account__c = accountId;
	        } 
	        checkPermissions();
        }  
    }
    
	/* Method to cancel - Method is deprecated for ticket #1112, mehtod should be remove after ticket verification
     */
    public pageReference cancel() {
    	return null;
    }
    /**
     * Getter for Contact List
     */
    public List<SelectOption> getContactList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        
        if (contactMap != null && contactMap.size() > 0) {
            List<Contact> contactList = contactMap.values();
            contactList.sort();
            
            for (Contact con : contactList) {
            	
                if (options.size() < 1000) {
                	options.add(new SelectOption(con.Id, con.Name));
                }
                
                if (contactMap.get(con.Id).Reference_Basic_Informations__r.size() > 0) {
                    contactIsReferenceableMap.put(con.Id, con.Reference_Basic_Informations__r[0].Is_Referenceable__c);
                } else {
                    contactIsReferenceableMap.put(con.Id, false);
                }
            }
        }
        return options;
    }
    
    /**
     * Getter for Account List
     */
    public List<SelectOption> getAccountList() {
        List<SelectOption> options = new List<SelectOption>();
        
        if (accountMap != null && accountMap.size() > 0) {
            List<Account> accountList = accountMap.values();
            accountList.sort();
            
            for (Account acc : accountList) {
            	
                if (options.size() < 1000) {
                	options.add(new SelectOption(acc.Id, acc.Name));
                }
                
                if (accountMap.get(acc.Id).Reference_Basic_Informations__r.size() > 0) {
                    accountIsReferenceableMap.put(acc.Id, acc.Reference_Basic_Informations__r[0].Is_Referenceable__c);
                } else {
                    accountIsReferenceableMap.put(acc.Id, false);
                }
            }
        }
        return options;
    }
	
    /**
     * Getter for Referenceability Type List
     */
    public List<SelectOption> getReferenceabilityTypeList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        
        if (isSalesUser) {
        	
            for (Referenceability_Type__c rt : [SELECT Name, Id, Sales_Point__c FROM Referenceability_Type__c 
            									WHERE Visible__c = true AND Sales_Reward__c = true AND Sales_Point__c != null  
            									ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
                mapRewardsPoints.put(rt.id, (rt.Sales_Point__c == null ? 0 : rt.Sales_Point__c));
                options.add(new SelectOption(rt.Id, rt.Name));
            }
        } else {
        	
        	for (Referenceability_Type__c rt : [SELECT Name, Id, Reward_points__c FROM Referenceability_Type__c 
        										WHERE Visible__c = true AND Sales_Reward__c = false  
        										ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
                mapRewardsPoints.put(rt.id, (rt.Reward_points__c == null ? 0 : rt.Reward_points__c));
                options.add(new SelectOption(rt.Id, rt.Name));
            }
        }
        return options;
    }
	
    /**
     * Method to change Amount
     */
    public void changeAmount() {
        reward.Amount__c = (reward.Referenceability_Type__c == null ? 0 : mapRewardsPoints.get(reward.Referenceability_Type__c));
    }
	
    /**
     * Method to save Reward
     */
    public Pagereference save() {
        Savepoint sp = Database.setSavepoint();
        
        try {
        	
        	if (checkPermissions()) {
	            
	            //Validation for Referenceability Type
	            if (reward.Referenceability_Type__c == null) {
	                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.SELECT_REFERENCEABILITY);
	                Apexpages.addMessage(message);
	                return null;
	            }
	            
	            //Validation for Amount__c
	            if (reward.Amount__c < 1) {
	                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.AMOUNT_0);
	                Apexpages.addMessage(message);
	                return null;
	            }
	            UtilityController.checkRBI(reward.Account__c, reward.Contact__c, contactAccountId, true);
	            //Insert Rewards
	            reward.Available_Points__c = reward.Amount__c;
	            insert reward;
	            
	            //Redirect Page
	            if (retUrl != null && retUrl != '') {
	            	
	            	if (userId != null && userId != '') {
        	 			return new PageReference(Page.SalesUserProfile.getUrl() + '?Id=' + userId);	//#re 169
					}
	                //re #589 Open Redirect Vulnerability :-Validate URL and if retURL found blank then redirect to previous page.
	                return UtilityController.redirectToSource(retUrl); 
	            }
	            
	            if (contactId != null && contactId != '') {
	                return new PageReference('/' + contactId);
	            }
	            return new PageReference('/' + accountId);
        	} else {
        		return null;
        	}
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
            Database.rollback(sp);
            return null;
        }
        return null;
    }
    
    /**
     * Method to get Reference Status for contact
     */
    public void getContactReferenceStatus() {
    	
        if (contactIsReferenceableMap.get(selectedContact) != null) {
            contactReferenceability = contactIsReferenceableMap.get(selectedContact);
            contactAccountId = contactMap.get(selectedContact).AccountId;
            isContactSelected = true;
        } else {
            isContactSelected = false;
        }
    }
    
    /**
     * Method to get Reference Status for account
     */
    public void getAccountReferenceStatus() {
    	
        if (accountIsReferenceableMap.get(selectedAccount) != null) {
            accountReferenceability = accountIsReferenceableMap.get(selectedAccount);
            isAccountSelected = true;
        } else {
            isAccountSelected = false;
        }
    } 
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
		
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	
    	if (userId == null || userId == '') {
    		fieldMap.put(UtilityController.appNamespace() + 'Reference_Basic_Information__c', new Set<String> { 
    									UtilityController.appNamespace() + 'Referenceability_Status__c',
    									UtilityController.appNamespace() + 'Is_Referenceable__c',
    									UtilityController.appNamespace() + 'Reference_Program_Candidate__c',
    									UtilityController.appNamespace() + 'Contact__c',
    									UtilityController.appNamespace() + 'Account__c' });
		}
		
		fieldMap.put(UtilityController.appNamespace() + 'Reward__c', new Set<String> { 
    									UtilityController.appNamespace() + 'Amount__c',
    									UtilityController.appNamespace() + 'Available_Points__c',
    									UtilityController.appNamespace() + 'Referenceability_Type__c',
    									UtilityController.appNamespace() + 'Expiration_Date__c',
    									UtilityController.appNamespace() + 'RewardDate__c',
    									UtilityController.appNamespace() + 'User__c',
    									UtilityController.appNamespace() + 'Transaction__c',
    									UtilityController.appNamespace() + 'Contact__c',
    									UtilityController.appNamespace() + 'Account__c' });
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
    }
}