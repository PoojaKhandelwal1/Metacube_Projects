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
 * Page: IssueRewardSLDS
 * Description: Class used to issue rewards
 * Created by: Rekha @9 May 2017
 */
public with sharing class IssueRewardControllerSLDS extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public String accountId { get; set; }
	public String contactId { get; set; }
    public String userId { get; set; }
    
    /**
     * Constructor
     */
    public IssueRewardControllerSLDS() {
        accountId = apexPages.currentPage().getParameters().get('AccountId');
        contactId = apexPages.currentPage().getParameters().get('ContactId');
        userId = apexPages.currentPage().getParameters().get('userId');
    }
    
    /**
     * RemoteAction to get insufficient permmission message
     */
    @RemoteAction
    public static String getPermissionsMessage(String userId) {
		checkPermissions(userId);
    	
    	return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    
    /**
     * Method to check Permissions
     */
    private static Boolean checkPermissions(String userId) {
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
    
    /**
     * RemoteAction to get all intial information
     */
    @RemoteAction
    public static InfoWrapper fetchInfo(String accountId, String contactId, String userId) {
    	InfoWrapper infoWp = new InfoWrapper();
    	 
    	try {
    		Custom_Settings__c cs = UtilityController.getCustomSettings();
    		infoWp.status = ConstantsController.REFERENCE_STATUS_MSG.replace('@@@3', cs.Default_Referenceablity_Status__c);
    		infoWp.status = infoWp.status.replace('@@@2', System.Label.reward);
    		Date exDate = UtilityController.rewardsExpritationDate(cs);
    		infoWp.exDate = (exDate != null ? exDate.format() : '');
    		infoWp.currentDate = Date.Today().format();
    		infoWp.userId = userId;
    		
    		// re #976 - Check for User Id 
    		if (!String.isBlank(userId)) { 
    			infoWp.userName = [SELECT Name FROM User WHERE Id =:infoWp.userId].Name;
    		} 
    		
    		// if reward will issue from contact
    		if (contactId != null && contactId != '') {  
	        	Contact contact = new Contact();
	        	
	            List<Contact> contacts = [SELECT Id, Name, Account.Name, AccountId,
						            			(SELECT Is_Referenceable__c, Referenceability_Status__c
						            				FROM Reference_Basic_Informations__r)
						        				FROM Contact
						        				WHERE Id = :contactId LIMIT :limits.getLimitQueryRows()];
	            
	            if (contacts.size() > 0) {
	            	contact = contacts[0];
		            
		            if (contact.Reference_Basic_Informations__r != null && contact.Reference_Basic_Informations__r.size() > 0) {
		                infoWp.selectedContact = new OptionWrapper(contact.Id, contact.Name, contact.Reference_Basic_Informations__r[0].Is_Referenceable__c);
		            } else {
		                infoWp.selectedContact = new OptionWrapper(contact.Id, contact.Name, false);
		            }
		            
		            infoWp.selectedContact.contactAccountId = contacts[0].AccountId;
		            Set<String> tempAccountIds = new Set<String>();
		            tempAccountIds.add(contact.AccountId);
		            infoWp.selectedAccount = new OptionWrapper(contact.AccountId, contact.Account.Name, false);
		            
		            Map<String, Set<String>> contactAccountMap = UtilityController.getRelatedAccounts(new Set<String>{contactId}, cs);
		        	
		        	if (contactAccountMap != null && contactAccountMap.containsKey(contact.Id)) {
		        		
			        	for (String accId : contactAccountMap.get(contact.Id)) {
			        		tempAccountIds.add(accId);
			        	}
		        	}
		        	
		        	for (Account acc : [SELECT Id, Name, (SELECT Reference_Program_Candidate__c, Is_Referenceable__c,
		        								Referenceability_Status__c, Generic_Account__c
		        								FROM Reference_Basic_Informations__r WHERE Contact__c = null)
		    								FROM Account WHERE Id IN :tempAccountIds ORDER BY Name]) {
						
		        		if (acc.Reference_Basic_Informations__r.size() == 0 || (acc.Reference_Basic_Informations__r.size() > 0 
		        				&& !acc.Reference_Basic_Informations__r[0].Generic_Account__c)) {
		        			
							if (acc.Reference_Basic_Informations__r.size() > 0) {
								infoWp.accounts.add(new OptionWrapper(acc.Id, acc.Name, acc.Reference_Basic_Informations__r[0].Is_Referenceable__c));
							} else {
								infoWp.accounts.add(new OptionWrapper(acc.Id, acc.Name, false));
							}
							
							if (acc.Id == contact.AccountId && acc.Reference_Basic_Informations__r.size() > 0) {
								infoWp.selectedAccount.isReferenceable = acc.Reference_Basic_Informations__r[0].Is_Referenceable__c;
							}
						}
		        	}
		        	
		        	if (infoWp.accounts.size() > 1000) {
		        		infoWp.isLimitExceeded = true;
		        	}
	    		}
        	// if reward will issue from account
	        } else if (accountId != null && accountId != '') { 
	            List<Account> accounts = [SELECT Id, Name, (SELECT Name, Account__c, Contact__r.Name, Contact__c,
	            							Reference_Program_Candidate__c, Is_Referenceable__c, Referenceability_Status__c 
				            				FROM Reference_Basic_Informations__r WHERE Contact__c = null) 
				            				FROM Account WHERE Id = :accountId LIMIT :limits.getLimitQueryRows()];
	            
	            if (accounts.size() > 0) {
	            	
	            	if (accounts[0].Reference_Basic_Informations__r.size() > 0) {
		                infoWp.selectedAccount = new OptionWrapper(accounts[0].Id, accounts[0].Name, 
		                					accounts[0].Reference_Basic_Informations__r[0].Is_Referenceable__c);
		            } else {
		                infoWp.selectedAccount = new OptionWrapper(accounts[0].Id, accounts[0].Name, false);
		            }
	            } 
	            infoWp.contacts.add(new OptionWrapper(null, '--None--', false));
	            
	            for (Contact con : UtilityController.getAccountContacts(accountId, cs)) {
	            	OptionWrapper ow;
	            	
	            	if (con.Reference_Basic_Informations__r.size() > 0) {
						ow = new OptionWrapper(con.Id, con.Name, con.Reference_Basic_Informations__r[0].Is_Referenceable__c);
					} else {
						ow = new OptionWrapper(con.Id, con.Name, false);
					}
					ow.contactAccountId = con.AccountId;
					infoWp.contacts.add(ow);
	            }
				
	        	if (infoWp.contacts.size() > 999) {
	        		infoWp.isLimitExceeded = true;
	        	}
	        }
	        
	        // get all referenceabilities
	        infoWp.referenceabilities.add(new OptionWrapper('', '--None--', false));
	        
	        if (userId != null && userId != '') {
            	
            	// get all sales ref types
	            for (Referenceability_Type__c rt : [SELECT Name, Id, Sales_Point__c FROM Referenceability_Type__c 
	            									WHERE Visible__c = true AND Sales_Reward__c = true AND Sales_Point__c != null  
	            									ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
	                OptionWrapper ow = new OptionWrapper(rt.Id, rt.Name, false);
	                ow.points = (Integer)(rt.Sales_Point__c == null ? 0 : rt.Sales_Point__c);
	                infoWp.referenceabilities.add(ow);
	            }
            } else {
            	
            	//get all non-sales ref types
            	for (Referenceability_Type__c rt : [SELECT Name, Id, Reward_points__c FROM Referenceability_Type__c 
            										WHERE Visible__c = true AND Sales_Reward__c = false 
            										ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
	                OptionWrapper ow = new OptionWrapper(rt.Id, rt.Name, false);
	                ow.points = (Integer)(rt.Reward_points__c == null ? 0 : rt.Reward_points__c);
	                infoWp.referenceabilities.add(ow);
	            }
	        }
	        
    	} catch(Exception e) {
    		infoWp.error = e.getMessage();
    	}
    	return infoWp;
    }
    
    /**
     * RemoteAction to submit the reward
     */
    @RemoteAction
    public static String submit(String infoJson) {
    	Savepoint sp = Database.setSavepoint();
        
        try {
        	InfoWrapper infoWp = (InfoWrapper)JSON.deserialize(infoJson, InfoWrapper.class);
        	Custom_Settings__c cs = UtilityController.getCustomSettings();
        	
        	if (checkPermissions(infoWp.userId)) {
        		Reward__c reward = new Reward__c(Amount__c = infoWp.amount, Transaction__c = ConstantsController.ISSUE, 
            					Expiration_Date__c = UtilityController.rewardsExpritationDate(cs), RewardDate__c = Date.Today(),
            					Comments__c = infoWp.comments, Referenceability_Type__c = infoWp.selectedRef);
				
				if (infoWp.userId != null && infoWp.userId != '') {
					reward.User__c = infoWp.userId;
				} else {
					reward.Account__c = infoWp.selectedAccount.id;
					String contactAccountId = infoWp.selectedAccount.id;
					
					if (infoWp.selectedContact != null && infoWp.selectedContact.id != null && infoWp.selectedContact.id != '') {
						reward.Contact__c = infoWp.selectedContact.id;
						contactAccountId = infoWp.selectedContact.contactAccountId;
					}
					UtilityController.checkRBI(reward.Account__c, reward.Contact__c, contactAccountId, true);
				}	
				
	            //Insert Rewards
	            reward.Available_Points__c = reward.Amount__c;
	            insert reward;
        	} else {
        		return CRUDAndFLSCheckController.getErrorMsg();
        	}
        	return '';
        } catch(Exception e) {
        	Database.rollback(sp);
        	return CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        }
    }
    
    /**
     * Wrapper class for request and Account request information
     */
 	public class InfoWrapper {
 		public OptionWrapper selectedAccount { get; set; }
 		public OptionWrapper selectedContact { get; set; }
 		public List<OptionWrapper> accounts { get; set; }
 		public List<OptionWrapper> contacts { get; set; }
 		public List<OptionWrapper> referenceabilities { get; set; }
 		public String selectedRef { get; set; }
 		public Boolean isLimitExceeded { get; set; }
 		public String comments { get; set; }
 		public String error { get; set; }
 		public String currentDate { get; set; }
 		public String exDate { get; set; }
 		public Integer amount { get; set; }
 		public String status { get; set; }
 		public String userId { get; set; }
 		public String userName { get; set; }
	    
	    public InfoWrapper() {
            accounts = new List<OptionWrapper>();
            contacts = new List<OptionWrapper>();
            referenceabilities = new List<OptionWrapper>();
            comments = '';
            isLimitExceeded = false;
            currentDate = '';
            selectedRef = '';
            exDate = '';
            error = '';
            amount = 0;
            status = '';
	    }
 	}
 	
 	/**
     * Wrapper Class
     */
 	public class OptionWrapper {
 		public String id { get; set; }
 		public String name { get; set; }
 		public Boolean isReferenceable { get; set; }
 		public Integer points { get; set; }
 		public String contactAccountId { get; set; }
 		
 		public OptionWrapper(String id, String name, Boolean isReferenceable) {
 			this.id = id;
 			this.name = name;
 			this.isReferenceable = isReferenceable;
 		}
 	}
}