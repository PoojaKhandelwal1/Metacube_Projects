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
 * Page: EditReward
 * Description: Class used to edit rewards.  
 * Modified By: Rekha @30 May 2017
 */
public with sharing class EditRewardController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Reward__c reward { get; set; }
    public Boolean isIssue { get; set; }
    public Decimal availableBalance { get; set; }
    public String returnUrl { get; set; }
    public String expiredDate { get; set; }
    public String updatedExpiredDate { get; set; }
    public Boolean isSLDS { get; set; }
    public String todayDate {
        get {
            return system.today().format();
        }
        set;
    }
    
    /**
     * Constructor
     */
    public EditRewardController(ApexPages.StandardController stdController) {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
	        reward = (Reward__c) stdController.getRecord();
	        //Check User premission.
	        checkPermissions();
	        Custom_Settings__c cs = UtilityController.getCustomSettings();
	        updatedExpiredDate = (UtilityController.rewardsExpritationDate(cs) != null ? UtilityController.rewardsExpritationDate(cs).format() : '');
	        returnUrl = ApexPages.currentPage().getParameters().get('retURL');
	        isIssue = false;
	        availableBalance = 0;
	        List<Reward__c> tempList = [SELECT Id, Account__c, Contact__c, User__c, Transaction__c, Expired__c, Amount__c, Available_Points__c, Expired_Points__c, 
	        								Expiration_Date__c, Referenceability_Type__c, Comments__c FROM Reward__c WHERE Id = :reward.Id LIMIT 1];
	        
	        if (tempList.size() > 0) {
	            reward = tempList[0];
	            expiredDate = (reward.Expiration_Date__c != null ? reward.Expiration_Date__c.format() : '');
	            isIssue = (reward.Transaction__c == ConstantsController.ISSUE ? true : false);
	            
	            if (reward.Contact__c != null && reward.Account__c != null) {
	            	List<Contact> accList = [SELECT Id, (SELECT Available_Points__c FROM Rewards__r 
	            								WHERE Account__c = :reward.Account__c AND Available_Points__c != null) 
	            								FROM Contact WHERE Id = :reward.Contact__c LIMIT :limits.getLimitQueryRows()];
		            
		            if (accList.size() > 0) {
		                
		                if (accList[0].Rewards__r.size() > 0) {
	                        
	                        for (Reward__c rew : accList[0].Rewards__r) {
	                        	availableBalance += rew.Available_Points__c;
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
	                        	availableBalance += rew.Available_Points__c;
	                        }
	                    }
		            }
	            } else if (reward.User__c != null) {
			        List<User_Profile__c> userProfiles = [SELECT Id, Available_Points__c FROM User_Profile__c WHERE User__c = :reward.User__c LIMIT 1];
		            availableBalance = (userProfiles.size() > 0 ? userProfiles[0].Available_Points__c : 0);          
	            }
	        }
        }
    }

    /**
     * Method to save the Reward
     */
    public Pagereference save() {
        
        if (checkPermissions()) {
            Database.SaveResult updateResult = Database.update(reward, false);
            
            if (!updateResult.isSuccess()) {
                return null;
            }
        }
        return cancel();
    }

    /**
     * Method to cancel the process
     */
    public PageReference cancel() {
    	
    	//re #589/656 Open Redirect Vulnerability :-Validate URL and if retURL found blank then redirect to previous/home page. 
        if (returnUrl != null) {
        	return UtilityController.redirectToSource(returnUrl);
        } else if (reward.Id != null) {
        	return new Pagereference('/' + reward.Id);
        } else {
        	return new PageReference(System.URL.getSalesforceBaseURL().toExternalForm());
        } 	
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions() { 
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>(); 
    	       		
        fieldMap.put(UtilityController.appNamespace() + 'Reward__c', new Set<String> {}); 
        										
        
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);           
    }
}