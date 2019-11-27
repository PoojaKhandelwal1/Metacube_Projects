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
 * Page: EditRewardSLDS
 * Description: Class used to edit rewards.  
 * Created By: Rekha @30 May 2017
 */
public with sharing class EditRewardControllerSLDS extends RefEdgeEditionFeatures {
    
    /**
     * Properties AND variables
     */
    public String retUrl { get; set; }
    public String rewardId { get; set; }
    // added for #660 - Gaurav Saini (25 Sep, 2017)
    public String dateString { get; set; }
    
    /**
     * Constructor
     */
    public EditRewardControllerSLDS(ApexPages.StandardController stdController) {
        retUrl = apexPages.currentPage().getParameters().get('retUrl');
        Reward__c reward = (Reward__c)stdController.getRecord();
        rewardId = reward.Id;
        dateString = String.valueOf(Date.today());
    }
    
    /**
     * RemoteAction to get insufficient permmission message
     */
    @RemoteAction
    public static String getPermissionsMessage() {
		checkPermissions();
    	
    	return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    /**
     * Method to get Date Format
     */
    @RemoteAction
    public static String getDateFormat() {   
    		String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
    		return dateFormat;
    }
    
    /**
     * Method to check Permissions
     */
    private static Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	
		fieldMap.put(UtilityController.appNamespace() + 'Reward__c', new Set<String> { 
        										UtilityController.appNamespace() + 'Amount__c',
        										UtilityController.appNamespace() + 'Comments__c',
        										UtilityController.appNamespace() + 'Expired__c',
        										UtilityController.appNamespace() + 'Expiration_Date__c'}); 
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
    
    /**
     * RemoteAction to get all intial information
     */
    @RemoteAction
    public static InfoWrapper fetchInfo(String rewardId) {
    	InfoWrapper infoWp = new InfoWrapper();
    	
    	try {
    		Custom_Settings__c cs = UtilityController.getCustomSettings();
    		
	        infoWp.updatedExpiredDate = (UtilityController.rewardsExpritationDate(cs) != null ? JSON.serialize(UtilityController.rewardsExpritationDate(cs)) : '');
	        Reward__c reward = new Reward__c();
	        List<Reward__c> tempList = [SELECT Id, Account__c, Account__r.Name, Contact__c, Contact__r.Name, User__c, User__r.Name, Transaction__c, 
	        								Expired__c, Amount__c, Available_Points__c, Expired_Points__c, 
	        								Expiration_Date__c, Referenceability_Type__c, Referenceability_Type__r.Name, 
	        								Comments__c FROM Reward__c WHERE Id = :rewardId LIMIT 1];
	        
	        if (tempList.size() > 0) {
	            reward = tempList[0];
	            infoWp.id = reward.Id;
	            infoWp.selectedAccount = new OptionWrapper(reward.Account__c, reward.Account__r.Name);
	            infoWp.selectedContact = new OptionWrapper(reward.Contact__c, reward.Contact__r.Name);
	            infoWp.user = new OptionWrapper(reward.User__c, reward.User__r.Name);
	            infoWp.refType = new OptionWrapper(reward.Referenceability_Type__c, reward.Referenceability_Type__r.Name);
	            infoWp.expiredDate = (reward.Expiration_Date__c != null ? reward.Expiration_Date__c.format() : '');
	            infoWp.expiredDateNew = (reward.Expiration_Date__c != null ? reward.Expiration_Date__c.format() : '');
	            infoWp.isIssue = (reward.Transaction__c == ConstantsController.ISSUE ? true : false);
	            infoWp.amount = (Integer)reward.Amount__c;
	            infoWp.comments = reward.Comments__c;
	            infoWp.isExpired = reward.Expired__c;
	            infoWp.availableBalance = 0;
	            
	            if (reward.Contact__c != null && reward.Account__c != null) {
	            	List<Contact> accList = [SELECT Id, (SELECT Available_Points__c FROM Rewards__r 
	            								WHERE Account__c = :reward.Account__c AND Available_Points__c != null) 
	            								FROM Contact WHERE Id = :reward.Contact__c LIMIT :limits.getLimitQueryRows()];
		            
		            if (accList.size() > 0) {
		                
		                if (accList[0].Rewards__r.size() > 0) {
	                        
	                        for (Reward__c rew : accList[0].Rewards__r) {
	                        	infoWp.availableBalance += (Integer)rew.Available_Points__c;
	                        }
	                    }
		            }
	            } else if (reward.Account__c != null) {
		            List<Account> accList = [SELECT Id, (SELECT Available_Points__c FROM Rewards__r 
		            							WHERE Account__c = :reward.Account__c AND Available_Points__c != null 
		            							AND Contact__c = null) FROM Account WHERE Id = :reward.Account__c LIMIT 1];
		            
		            if (accList.size() > 0) {
		                
		                if (accList[0].Rewards__r.size() > 0) {
	                       
	                        for (Reward__c rew : accList[0].Rewards__r) {
	                        	infoWp.availableBalance += (Integer)rew.Available_Points__c;
	                        }
	                    }
		            }
	            } else if (reward.User__c != null) {
			        List<User_Profile__c> userProfiles = [SELECT Id, Available_Points__c FROM User_Profile__c WHERE User__c = :reward.User__c LIMIT 1];
		            infoWp.availableBalance = (Integer)(userProfiles.size() > 0 ? userProfiles[0].Available_Points__c : 0);          
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
        
        try {
	        	InfoWrapper infoWp = (InfoWrapper)JSON.deserialize(infoJson, InfoWrapper.class);
	        	Reward__c reward ;
	        	
	        	if (checkPermissions()) {
	        		//#1120 : Allow empty expiration date
					
	        		if (infoWp.expiredDateNew == null || infoWp.expiredDateNew.trim() == '') {
	        			reward = new Reward__c(Id = infoWp.id, Amount__c = infoWp.amount, Expiration_Date__c = null,
	            					Expired__c = infoWp.isExpired, Comments__c = infoWp.comments);
				} else { 
					reward = new Reward__c(Id = infoWp.id, Amount__c = infoWp.amount, Expiration_Date__c = date.valueOf(infoWp.expiredDateNew),
	            					Expired__c = infoWp.isExpired, Comments__c = infoWp.comments);
				}
				update reward;
	        	} else {
	        		return CRUDAndFLSCheckController.getErrorMsg();
	        	}
	        	return '';
        } catch(Exception e) {
        		return CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        }
    }
    
    /**
     * Wrapper class for request and Account request information
     */
 	public class InfoWrapper {
 		public OptionWrapper selectedAccount { get; set; }
 		public OptionWrapper selectedContact { get; set; }
 		public OptionWrapper user { get; set; }
 		public OptionWrapper refType { get; set; }
 		public String id { get; set; }
 		public Integer amount { get; set; }
 		public Integer availableBalance { get; set; }
 		public String comments { get; set; }
 		public Boolean isExpired { get; set; }
 		public String error { get; set; }
 		public String expiredDate { get; set; }
 		public String oldExpiredDate { get; set; }
 		public String updatedExpiredDate { get; set; }
 		public Boolean isIssue { get; set; }
 		public String expiredDateNew { get; set; }
	    
	    public InfoWrapper() {
		    comments = '';
            expiredDate = '';
            updatedExpiredDate = '';
            error = '';
            expiredDateNew = '';
            amount = 0;
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
 			this.name = name;
 		}
 	}
}