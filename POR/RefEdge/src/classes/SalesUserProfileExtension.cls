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
 * Page : SalesUserProfile
 * Description:  Class used to handle sales sales profile and redirect to reward issue and redeem pages
 * Last Modified By: Rajesh @March 13 2018 for REF-1390 
 */
public with sharing class SalesUserProfileExtension extends RefEdgeEditionFeatures {  
	/**
     * Properties and variables
     */
    public User_Profile__c userProfile { get; set; }
    public List<Reward__c> rewardList { get; set; }
    private Id userId;
    private String nameSpace = '';
    
   /**
    *  Constructor
    */
    public SalesUserProfileExtension(ApexPages.StandardController controller) {  
    	String nameSpace = '';             
        userId = (Id)controller.getRecord().Id;
        userProfile = new User_Profile__c();
        List<User_Profile__c> userProfileList = [SELECT Id, Available_Points__c, Lifetime_Points__c, User__r.name, User__r.email FROM User_Profile__c
        											WHERE User__c = :userId LIMIT :limits.getLimitQueryRows()];                
        
        if (userProfileList.size() > 0) {
            userProfile = userProfileList[0];
        }
        rewardList = [SELECT Id, Name, User__c, Referenceability_Type__c, RewardDate__c, Expiration_Date__c, Transaction__c, Amount__c, Available_Points__c, 
        				Expired_Points__c, Expired__c FROM Reward__c WHERE User__c = :userId ORDER BY Name DESC LIMIT :limits.getLimitQueryRows()];
        // Get namespace
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        
        if (appConfig.Namespace__c != null) {
            nameSpace = appConfig.Namespace__c;
        }
    }
    
   	/**  
     * Method to redirect to rewards issue page 
     */
    public PageReference redirectToIssue() {          
        PageReference reRend = new PageReference('/apex/' + nameSpace + 'IssueReward?userId=' + userId + '&retUrl=' + userProfile.Id);
        return reRend;
    }
    
   /**
    * Method to redirect to rewards redeem page 
    */
    public PageReference redirectToRedeem() {          
        PageReference reRend = new PageReference('/apex/' + nameSpace + 'RedeemReward?userId=' + userId + '&retUrl=' + userProfile.Id);
        return reRend;
    }
    
    /**
    * Method to redirect to user profile list page. 
    */
    public PageReference redirectToListPage() {          
        Schema.DescribeSObjectResult result = User_Profile__c.SObjectType.getDescribe(); 
        PageReference pageRef = new PageReference('/' + result.getKeyPrefix() + '/o'); 
        return pageRef; 
    }
}