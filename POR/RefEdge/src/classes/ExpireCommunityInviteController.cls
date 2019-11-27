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
 * Page: ExpireCommunityInvite
 * Description : Class used to expire Community Invite.
 * Modified by: Rekha @Feb 3 2017
 */
public with sharing class ExpireCommunityInviteController extends RefEdgeEditionFeatures {
	/**
     * Properties and variables
     */
    private Community_Invite__c communityInvite;
    
	/**
     * Constructor
     */
    public ExpireCommunityInviteController(ApexPages.StandardController controller) {
        communityInvite = (Community_Invite__c) controller.getRecord();
    }
    
    /**
     * Method to expire the community invite
     */
    public pageReference expire() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	fieldMap.put(UtilityController.appNamespace() + 'Community_Invite__c', new Set<String> { 
        										UtilityController.appNamespace() + 'Community_Participate_Deadline__c' });
        fieldMap.put(UtilityController.appNamespace() + 'Community_Invite_Contact__c', new Set<String> { 
        										UtilityController.appNamespace() + 'Response__c' });
    	
    	if (CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true)) {
	    	Savepoint sp = Database.setSavepoint();
	    	
	        try {
		    	List<Community_Invite_Contact__c> comList = [SELECT Id, Response__c FROM Community_Invite_Contact__c 
		    									WHERE Community_Invite__c = : communityInvite.Id and Response__c = null];
		    	List<Community_Invite_Contact__c> comListToUpdate = new List<Community_Invite_Contact__c>();
		    	
		    	if (comList != null && comList.size() > 0) {
		    		
		    		for (Community_Invite_Contact__c cic : comList) {
		    			cic.Response__c = 'No Response';
		    			comListToUpdate.add(cic);
		    		}
		    	}
		    	
		    	if (comListToUpdate.size() > 0) {
		    		update comListToUpdate;
		    	}
				communityInvite.Community_Participate_Deadline__c = date.today() - 1;
				update communityInvite;
		    	return new pageReference('/' + communityInvite.Id);
		    } catch (Exception e) {
	            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
		        Apexpages.addMessage(message);
	            Database.rollback(sp);
	            return null;
	        }
    	} else {
    		return null;
    	}
    }
}