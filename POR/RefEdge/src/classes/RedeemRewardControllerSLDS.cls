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
 * Page: RedeemRewardSLDS
 * Description: Class used to redeem rewards
 * Modified by: Rekha @16 May 2017
 */
public with sharing class RedeemRewardControllerSLDS extends RefEdgeEditionFeatures {
    
    /**
     * Properties AND variables
     */
    public String accountId { get; set; }
    public String contactId { get; set; }
    public String userId { get; set; }
    
    /**
     * Constructor
     */
    public RedeemRewardControllerSLDS() {
    	accountId = ApexPages.currentPage().getParameters().get('accountId');
        contactId = apexPages.currentPage().getParameters().get('ContactId');
        userId = apexPages.currentPage().getParameters().get('userId');
        //retUrl = apexPages.currentPage().getParameters().get('retUrl');
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
    		infoWp.isAccountRedeem = false;
    		infoWp.limitContactRedeem = cs.Limit_Contact_Redeem__c;
        	infoWp.isSharedContact = cs.Shared_Contacts__c;
    		infoWp.status = ConstantsController.REFERENCE_STATUS_MSG.replace('@@@3', cs.Default_Referenceablity_Status__c);
    		infoWp.status = infoWp.status.replace('@@@2', System.Label.reward);
    		
    		infoWp.currentDate = Date.Today().format();
    		
    		// if reward will issue from account
    		if (accountId != null && accountId != '') {
	            List<Account> accounts = [SELECT Id, Name, (SELECT Name, Account__c, Contact__r.Name, Contact__c, 
								            Current_Available_Balance_Points__c, Reference_Program_Candidate__c, 
								            Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r 
								            WHERE Contact__c = null) FROM Account 
							            WHERE Id = :accountId LIMIT :limits.getLimitQueryRows()];
	            
	            if (accounts.size() > 0) {
	            	
	            	if (accounts[0].Reference_Basic_Informations__r.size() > 0) {
		                infoWp.selectedAccount = new OptionWrapper(accounts[0].Id, accounts[0].Name, 
		                					accounts[0].Reference_Basic_Informations__r[0].Is_Referenceable__c, 
		                					(Integer)accounts[0].Reference_Basic_Informations__r[0].Current_Available_Balance_Points__c);
		            } else {
		                infoWp.selectedAccount = new OptionWrapper(accounts[0].Id, accounts[0].Name, false, 0);
		            }
	            } 
	            
	            infoWp.contacts.add(new OptionWrapper(null, '--None--', false, 0));
	            List<Contact> contactList = new List<Contact>();
	            
	            // if reward will issue from contact
	            if (contactId != null && contactId !='') {
	                contactList = [SELECT Id, Name, AccountId, (SELECT Name, Current_Available_Balance_Points__c, Account__c, Contact__r.Name, 
	                									Contact__c, Reference_Program_Candidate__c, Is_Referenceable__c, Referenceability_Status__c 
	            										FROM Reference_Basic_Informations__r), (SELECT Available_Points__c FROM Rewards__r 
	            										WHERE Available_Points__c != null) FROM Contact WHERE Id = :contactId 
	            										ORDER BY LastName LIMIT :limits.getLimitQueryRows()];
	            } else {
	                contactList = [SELECT Id, Name, AccountId, (SELECT Name,Current_Available_Balance_Points__c, Account__c, Contact__r.Name, 
	                									Contact__c, Reference_Program_Candidate__c, Is_Referenceable__c, Referenceability_Status__c 
	                									FROM Reference_Basic_Informations__r), (SELECT Available_Points__c FROM Rewards__r 
	                									WHERE Account__c = :accountId AND Available_Points__c != null) FROM Contact 
	                									WHERE AccountId = :accountId ORDER BY LastName LIMIT :limits.getLimitQueryRows()];
	                infoWp.isAccountRedeem = true;
	            }
	            
	            if (contactList != null && contactList.size() > 0) {
	                Integer size = 1;
	                
	                if (contactList.size() > 999) {
	    				infoWp.isLimitExceeded = true;
	                }
	                
	                for (Contact con : contactList) {
	                	
	                    if (size < 1000) {
		                    Integer amount = 0;
		                    
		                    if (con.Rewards__r.size() > 0) {
		                    	
		                        for (Reward__c rew : con.Rewards__r) {
		                        	amount += (Integer)rew.Available_Points__c;
		                        }
		                    }
		                    
		                    OptionWrapper ow;
			            	
			            	if (con.Reference_Basic_Informations__r.size() > 0) {
								ow = new OptionWrapper(con.Id, con.Name, con.Reference_Basic_Informations__r[0].Is_Referenceable__c, amount);
							} else {
								ow = new OptionWrapper(con.Id, con.Name, false, 0);
							}
							ow.contactAccountId = con.AccountId;
							infoWp.contacts.add(ow);
							
		                    
		                    if (contactId != null && contactId != '' && contactId == con.Id) {
		                    	infoWp.selectedContact = new OptionWrapper(con.Id, con.Name, (con.Reference_Basic_Informations__r.size() > 0 ? 
		                        							con.Reference_Basic_Informations__r[0].Is_Referenceable__c : false), amount);
		                    }
	                    }
	                    size++;
	                }
	            }
	        }
	        
	        // from user profile
	        if (userId != null && userId != '') {

	            List<User_Profile__c> userProfileList = [SELECT Id, Available_Points__c, User__r.name 
	            						FROM User_Profile__c WHERE User__c = :userId LIMIT :limits.getLimitQueryRows()];                
	            						
	            if (userProfileList.size() > 0) {
	                infoWp.userId = userId;
	                infoWp.user = new OptionWrapper(userProfileList[0].User__c, userProfileList[0].User__r.Name, false, (Integer)userProfileList[0].Available_Points__c);
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
        	
        	if (checkPermissions(infoWp.userId)) {
        		Reward__c reward = new Reward__c(Amount__c = infoWp.amount, Transaction__c = ConstantsController.REDEEM, 
            					RewardDate__c = Date.Today(), Comments__c = infoWp.comments);
				
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
	            
	            if ((infoWp.userId != null && infoWp.userId != '') || 
	            			(!infoWp.isSharedContact && infoWp.selectedContact != null 
	            			&& infoWp.selectedContact.id != null && infoWp.selectedContact.id != '' 
	            			&& (infoWp.LimitContactRedeem || !infoWp.isAccountRedeem))) {
	                //Insert Rewards 
	                insert reward;
	            } else if (infoWp.selectedContact != null 
	            			&& infoWp.selectedContact.id != null && infoWp.selectedContact.id != '' 
	            			//changed for #861
	            			&& (!infoWp.LimitContactRedeem && infoWp.isAccountRedeem)) {
	            	List<Reward__c> rewards = getRedeemRewards(reward, infoWp); 
	                insert rewards; 
	            } else if (infoWp.isSharedContact && infoWp.selectedContact != null 
	            			&& infoWp.selectedContact.id != null && infoWp.selectedContact.id != '') {
	            	List<Reward__c> rewards = getSharedRedeemRewards(reward); 
	                insert rewards; 
	            } else if (infoWp.selectedContact == null 
	            			|| infoWp.selectedContact.id == null || infoWp.selectedContact.id == '') {
	                List<Reward__c> rewards = getRedeemRewards(reward, infoWp); 
	                insert rewards; 
	            }
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
     * Added for R15.33 changes end
     * This function will get all reward which we have to redeem.
     * For case when we do redeem reward FROM account AND no contact selected.
     * Then redeem reward based on issued date FROM contat AND account or account AND contact.
     * Instead create single reward record on account ,create reward record on contact AND account seperatly if any reward exitst for redeem.
     */
    private static List<Reward__c> getRedeemRewards(Reward__c reward, InfoWrapper infoWp) {
        Decimal amount = reward.amount__c;
        String comment = '';
        Map<Id, Reward__c> redeemRewards = new Map<Id,Reward__c>();
        
        if (reward.Account__c != null) {
        	
        	if (reward.Contact__c != null && !infoWp.LimitContactRedeem && infoWp.isAccountRedeem) {
        		String name = '';
        		
        		for (OptionWrapper con : infoWp.contacts) {
        			
        			if (con.id != '' && con.id == reward.Contact__c) {
        				name = con.name;
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
    private static List<Reward__c> getSharedRedeemRewards(Reward__c reward) {
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
     * Wrapper class for request and Account request information
     */
 	public class InfoWrapper {
 		public OptionWrapper selectedAccount { get; set; }
 		public OptionWrapper selectedContact { get; set; }
 		public OptionWrapper user { get; set; }
 		public List<OptionWrapper> contacts { get; set; }
 		public Boolean isLimitExceeded { get; set; }
 		public String comments { get; set; }
 		public String error { get; set; }
 		public String currentDate { get; set; }
 		public String status { get; set; }
 		public Boolean limitContactRedeem { get; set; }
 		public Boolean isSharedContact { get; set; }
 		public Boolean isAccountRedeem { get; set; }
 		public Integer amount { get; set; }
 		public String userId { get; set; }
	    
	    public InfoWrapper() {
            contacts = new List<OptionWrapper>();
            comments = '';
            isLimitExceeded = false;
            currentDate = '';
            error = '';
            amount = 0;
            status = '';
            userId = '';
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
 		
 		public OptionWrapper(String id, String name, Boolean isReferenceable, Integer points) {
 			this.id = id;
 			this.name = name;
 			this.isReferenceable = isReferenceable;
 			this.points = points;
 		}
 	}
}