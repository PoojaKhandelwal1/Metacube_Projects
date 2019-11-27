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
 * Page: RedeemReward
 * Description: Class used to redeem rewards
 * Modified by: Rekha @Feb 8 2017
 */
public with sharing class RedeemRewardController extends RefEdgeEditionFeatures {
    /**
     * Properties AND variables
     */
    public Reward__c reward { get; set; }
    public String contactId { get; set; }
    public String userId { get; set; }
    public Decimal availableBalance { get; set; }
    public List<SelectOption> contacts { get; set; }
    public Boolean accountReferenceability { get; set; }
    public Boolean contactReferenceability { get; set; }
    public String selectedContact { get; set; }
    public Boolean isContactSelected { get; set; }
    public Map<String, Boolean> contactIsReferenceableMap { get; set; }
    public Map<String, Decimal> contactpointsMap { get; set; }
    public String status { get; set; }
    public Boolean isAccountRedeem { get; set; }
    private Custom_Settings__c cs;
    public Boolean isSharedContact { get; set; }
    public Boolean isLimitExceeded { get; set; }
    private Boolean Limit_Contact_Redeem;
    private Decimal accountPoints;
    private Map<Id, Contact> contactMap;
    private String retUrl;
    private String accountId;
    private String contactAccountId;
    public Boolean isSLDS { get; set; }
    // re #1112 - Added return URL 
    public String returnUrl { get; set; }
    
    /**
     * Constructor
     */
    public RedeemRewardController() {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
	        accountId = (ApexPages.currentPage().getParameters().get('accountId') != null) ? ApexPages.currentPage().getParameters().get('accountId') : '';
	        contactId = (ApexPages.currentPage().getParameters().get('ContactId') != null) ? ApexPages.currentPage().getParameters().get('ContactId') : ''; 
	        userId = (ApexPages.currentPage().getParameters().get('userId') != null) ? ApexPages.currentPage().getParameters().get('userId') : '';  
	        retUrl = (ApexPages.currentPage().getParameters().get('retUrl') != null) ? ApexPages.currentPage().getParameters().get('retUrl') : ''; 
	        accountReferenceability = false;
	        contactReferenceability = false;
	        isAccountRedeem = false;
	        contactIsReferenceableMap = new Map<String, Boolean>();
	        contactpointsMap = new Map<String, Decimal>();
	        isContactSelected = false;
	        isSharedContact = false;
	        isLimitExceeded = false;
	        availableBalance = 0;
	        contactAccountId = '';
	        cs = UtilityController.getCustomSettings();
	        Limit_Contact_Redeem = cs.Limit_Contact_Redeem__c;
	        isSharedContact = cs.Shared_Contacts__c;
	        status = ConstantsController.REFERENCE_STATUS_MSG.replace('@@@3', cs.Default_Referenceablity_Status__c);
	        status = status.replace('@@@2', System.Label.reward);
	        reward = new Reward__c(transaction__c = ConstantsController.REDEEM, RewardDate__c = Date.Today());
	        
	        if (userId != null && userId != '') {
	            User_Profile__c userProfile = new User_Profile__c();
	            List<User_Profile__c> userProfileList = [SELECT Id, Available_Points__c, Lifetime_Points__c, User__r.name, User__r.email 
	            						FROM User_Profile__c WHERE User__c = :userId LIMIT :limits.getLimitQueryRows()];                
	            						
	            if (userProfileList.size() > 0) {
	                userProfile = userProfileList[0];
	            }
	            reward.User__c = userId;
	            availableBalance = userProfile.Available_Points__c;
	            // Added User profile Id in return URL -#1112
	            returnUrl = Page.SalesUserProfile.getUrl() + '?Id=' + userId; 
	        } else  if (accountId != null) {
	            List<Account> accounts = [SELECT Id, Name, (SELECT Name, Account__c, Contact__r.Name, Contact__c, 
									            Current_Available_Balance_Points__c, Reference_Program_Candidate__c, 
									            Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r 
									            WHERE Contact__c = null) FROM Account 
								            WHERE Id = :accountId LIMIT :limits.getLimitQueryRows()];
	            
	            if (accounts.size() > 0) {
		            
		            if (accounts[0].Reference_Basic_Informations__r.size() > 0) {
		                accountReferenceability = accounts[0].Reference_Basic_Informations__r[0].Is_Referenceable__c;
		                
		                if (accounts[0].Reference_Basic_Informations__r[0].Current_Available_Balance_Points__c != null) {
		                    availableBalance = accounts[0].Reference_Basic_Informations__r[0].Current_Available_Balance_Points__c;
		                    //changes for ISSUe R15.33
		                    accountPoints = availableBalance;
		                } else {
		                    availableBalance = 0;
		                    accountPoints = availableBalance;
		                }
		            } 
		        }
	            reward.Account__c = accountId;
	            contacts = new List<SelectOption>();
	            contacts.add(new SelectOption('', '--None--'));
	            
	            if (contactId != null && contactId !='') {
	                contactMap = new Map<Id, Contact> ([SELECT Id, Name, AccountId, (SELECT Name,Current_Available_Balance_Points__c, Account__c, Contact__r.Name, 
	                									Contact__c, Reference_Program_Candidate__c, Is_Referenceable__c, Referenceability_Status__c 
	            										FROM Reference_Basic_Informations__r),(SELECT Available_Points__c FROM Rewards__r 
	            										WHERE Available_Points__c != null) FROM Contact WHERE Id = :contactId LIMIT :limits.getLimitQueryRows()]);
	            	contactAccountId = contactMap.values()[0].AccountId;
	            	// Added Contact in return URL -#1112
	            	returnUrl = contactId;
	            } else {
	                contactMap = new Map<Id, Contact> ([SELECT Id, Name, AccountId, (SELECT Name,Current_Available_Balance_Points__c, Account__c, Contact__r.Name, 
	                									Contact__c, Reference_Program_Candidate__c, Is_Referenceable__c, Referenceability_Status__c 
	                									FROM Reference_Basic_Informations__r),(SELECT Available_Points__c FROM Rewards__r 
	                									WHERE Account__c = :reward.Account__c AND Available_Points__c != null) FROM Contact 
	                									WHERE AccountId = :accountId LIMIT :limits.getLimitQueryRows()]);
	                isAccountRedeem = true;
	                // Added Account in return URL -#1112
	                returnUrl = accountId;
	            }
	            
	            if (contactMap != null && contactMap.size() > 0) {
	                Integer size = 1;
	                List<Contact> contactList = contactMap.values();
	                contactList.sort();
	                
	                if (contactList.size() > 999) {
	    				isLimitExceeded = true;
	                }
	                
	                for (Contact con : contactList) {
	                	
	                    if (size < 1000) {
	                    	contacts.add(new SelectOption(con.Id, con.Name));
	                    }
	                    size++;
	                    Decimal amount = 0;
	                    
	                    if (contactMap.get(con.Id).Rewards__r.size() > 0) {
	                    	
	                        for (Reward__c rew : contactMap.get(con.Id).Rewards__r) {
	                        	amount += rew.Available_Points__c;
	                        }
	                    }
	                    
	                    if (contactMap.get(con.Id).Reference_Basic_Informations__r.size() > 0) {
	                        contactIsReferenceableMap.put(con.Id, con.Reference_Basic_Informations__r[0].Is_Referenceable__c);
	                        contactpointsMap.put(con.Id, amount);
	                    } else {
	                        contactpointsMap.put(con.Id, 0); 
	                        contactIsReferenceableMap.put(con.Id, false);
	                    }
	                    
	                    if (contactId != null && contactId != '' && contactId == con.Id) {
	                        contactReferenceability = (con.Reference_Basic_Informations__r.size() > 0 ? 
	                        							con.Reference_Basic_Informations__r[0].Is_Referenceable__c : false);
	                        reward.Contact__c = con.Id;
	                        
	                        if (Limit_Contact_Redeem || !isAccountRedeem) {
	                        	availableBalance = amount;
	                        }
	                    }
	                }
	            }
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
     * Method to save Reward
     */
    public pageReference Save() {
        Savepoint sp = Database.setSavepoint();
        
        try {           
        	
        	if (checkPermissions()) {
	            //Validation for availableBalance
	            if (reward.Amount__c > availableBalance) {
	                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.label.Amount_Incorrect);
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
	            
	            if (reward.User__c != null || (!cs.Shared_Contacts__c && reward.Contact__c != null && (Limit_Contact_Redeem || !isAccountRedeem))) {
	                //Insert Rewards 
	                insert reward;
	            } else if (reward.Contact__c != null && (!Limit_Contact_Redeem && isAccountRedeem)) {
	            	List<Reward__c> rewards = getRedeemRewards(reward); 
	                insert rewards; 
	            } else if (reward.Contact__c != null && cs.Shared_Contacts__c) {
	            	List<Reward__c> rewards = getSharedRedeemRewards(reward); 
	                insert rewards; 
	            } else if (reward.Contact__c == null) {
	                List<Reward__c> rewards = getRedeemRewards(reward); 
	                insert rewards; 
	            }
	            
	            if (retUrl != null && retUrl != '') {
	            	
	            	//#re 169
	            	if (userId != null && userId != '') {
	        	 		return new PageReference(Page.SalesUserProfile.getUrl() + '?Id=' + userId);	//#re 169
	       			}
	                //re #589 Open Redirect Vulnerability :-Validate URL AND if retURL found blank then redirect to previous page.
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
    }
    
    /**
     * Method to get Reference status
     */
    public void getReferenceStatus() {

        if (contactIsReferenceableMap.get(selectedContact) != null) {
            contactReferenceability = contactIsReferenceableMap.get(selectedContact);
            isContactSelected = true;
            contactAccountId = contactMap.get(selectedContact).AccountId;
            
            if (Limit_Contact_Redeem) {
            	availableBalance = contactpointsMap.get(selectedContact);
            }
        } else {
            isContactSelected = false;
            
            if (Limit_Contact_Redeem) {
            	availableBalance = accountPoints;
            }
        }
    } 
    
    /**
     * Added for R15.33 changes end
     * This function will get all reward which we have to redeem.
     * For case when we do redeem reward FROM account AND no contact selected.
     * Then redeem reward based on issued date FROM contat AND account or account AND contact.
     * Instead create single reward record on account ,create reward record on contact AND account seperatly if any reward exitst for redeem.
     */
    private List<Reward__c> getRedeemRewards(Reward__c reward) {
        Decimal amount = reward.amount__c;
        String comment = '';
        Map<Id, Reward__c> redeemRewards = new Map<Id,Reward__c>();
        
        if (reward.Account__c != null) {
        	
        	if (reward.Contact__c != null && !Limit_Contact_Redeem && isAccountRedeem) {
        		String name = '';
        		
        		for (SelectOption so : Contacts) {
        			
        			if (so.getValue() != '' && so.getValue() == reward.Contact__c) {
        				name = so.getLabel();
        			}
        		}
        		comment = system.Label.Contact_Redeem_Comment_MSG.replace('@@@', name);
        	}
        	
            for (Reward__c rewardTmp : WithoutSharingHelperController.getRewardOfAccount(reward.Account__c)) {
            	
            	if (rewardTmp.Available_Points__c != null && rewardTmp.Available_Points__c <= amount && amount != 0) {
            		
                    if (redeemRewards.containsKey(rewardTmp.Contact__c)) {
                    	Decimal tempAmount = redeemRewards.get(rewardTmp.Contact__c).Amount__c;
                    	redeemRewards.get(rewardTmp.Contact__c).Amount__c = tempAmount + rewardTmp.Available_Points__c;
                    } else {
	                    Reward__c tmpReward = new Reward__c(Account__c = rewardTmp.Account__c, Contact__c = rewardTmp.Contact__c,
	                    Transaction__c = ConstantsController.REDEEM, Amount__c = rewardTmp.Available_Points__c,
	                    RewardDate__c = System.today(), Comments__c = (comment != '' ? comment : reward.Comments__c));
	                    redeemRewards.put(rewardTmp.Contact__c, tmpReward);
                    }
                    amount = amount - rewardTmp.Available_Points__c;
                    rewardTmp.Available_Points__c = 0;
                } else if (amount != 0 && rewardTmp.Available_Points__c != null) {
                    
                    if (redeemRewards.containsKey(rewardTmp.Contact__c)) {
                    	Decimal tempAmount = redeemRewards.get(rewardTmp.Contact__c).Amount__c;
                    	redeemRewards.get(rewardTmp.Contact__c).Amount__c = tempAmount + amount;
                    } else {
                    	Reward__c tmpReward = new Reward__c(Account__c = rewardTmp.Account__c, Contact__c = rewardTmp.Contact__c,
	                    Transaction__c = ConstantsController.REDEEM, Amount__c = amount,
	                    RewardDate__c = System.today(), Comments__c = (comment != '' ? comment : reward.Comments__c));
	                    redeemRewards.put(rewardTmp.Contact__c, tmpReward);
                    }
                    rewardTmp.Available_Points__c = rewardTmp.Available_Points__c - amount;
                    amount = 0;
                    break;
                }
            }
        }
        return redeemRewards.values();
    }
    
	/**
     * Added for Shared contact redeem reward
     * This function will get all reward which we have to redeem.
     * For case when we do redeem reward FROM Contact AND points have to redeemed FROM shared accounts. 
     * Then redeem reward based on issued date FROM contact AND account or account AND contact.
     * Instead create single reward record on account ,create reward record on contact AND account seperatly if any reward exitst for redeem.
     */
    private List<Reward__c> getSharedRedeemRewards(Reward__c reward) {
        Decimal amount = reward.amount__c;
        Map<Id, Reward__c> redeemRewards = new Map<Id,Reward__c>();
        
        if (reward.Contact__c != null) {
        	
            for (Reward__c rewardTmp : WithoutSharingHelperController.getRewardOfContact(reward.Contact__c)) {
            								
            	if (rewardTmp.Available_Points__c != null && rewardTmp.Available_Points__c <= amount && amount != 0) {
            		
                    if (redeemRewards.containsKey(rewardTmp.Account__c)) {
                    	Decimal tempAmount = redeemRewards.get(rewardTmp.Account__c).Amount__c;
                    	redeemRewards.get(rewardTmp.Account__c).Amount__c = tempAmount + rewardTmp.Available_Points__c;
                    } else {
	                    Reward__c tmpReward = new Reward__c(Account__c = rewardTmp.Account__c, Contact__c = rewardTmp.Contact__c,
	                    Transaction__c = ConstantsController.REDEEM, Amount__c = rewardTmp.Available_Points__c,
	                    RewardDate__c = System.today(), Comments__c = reward.Comments__c);
	                    redeemRewards.put(rewardTmp.Account__c, tmpReward);
                    }
                    amount = amount - rewardTmp.Available_Points__c;
                    rewardTmp.Available_Points__c = 0;
                } else if (amount != 0 && rewardTmp.Available_Points__c != null) {
                	
                    if (redeemRewards.containsKey(rewardTmp.Account__c)) {
                    	Decimal tempAmount = redeemRewards.get(rewardTmp.Account__c).Amount__c;
                    	redeemRewards.get(rewardTmp.Account__c).Amount__c = tempAmount + amount;
                    } else {
                    	Reward__c tmpReward = new Reward__c(Account__c = rewardTmp.Account__c, Contact__c = rewardTmp.Contact__c,
	                    Transaction__c = ConstantsController.REDEEM, Amount__c = amount,
	                    RewardDate__c = System.today(), Comments__c = reward.Comments__c);
	                    redeemRewards.put(rewardTmp.Account__c, tmpReward);
                    }
                    rewardTmp.Available_Points__c = rewardTmp.Available_Points__c - amount;
                    amount = 0;
                    break;
                }
            }
        }
        return redeemRewards.values();
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
    									UtilityController.appNamespace() + 'Comments__c',
    									UtilityController.appNamespace() + 'RewardDate__c',
    									UtilityController.appNamespace() + 'User__c',
    									UtilityController.appNamespace() + 'Transaction__c',
    									UtilityController.appNamespace() + 'Contact__c',
    									UtilityController.appNamespace() + 'Account__c' });
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
    }
}