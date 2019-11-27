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
 * Description: This is a nightly batch to notify the CRP team of inactive Reference Owners and Account Owners
 * Created by: Narandra Sahu (4 Apr, 2017) 
 */
global with sharing class Batch_InactiveOwnersNotification implements Database.Batchable<sObject>, Database.stateful {
    
    // map containing RBIs of accounts which have inactive account owner (Id in the map is Account Id)
    private Map<Id, Reference_Basic_Information__c> inactiveAccOwnerAccounts { get; set; }
    // map containing RBIs of accounts which have inactive reference owner (Id in the map is Account Id)
    private Map<Id, Reference_Basic_Information__c> inactiveRefOwnerAccounts { get; set; }
    // map containing all the users who are eitherAccount Owners or Reference Owners
    private Map<Id, User> userMap { get; set; }
    
    /**
     * Constructor
     */
    global Batch_InactiveOwnersNotification() {
        inactiveAccOwnerAccounts = new Map<Id, Reference_Basic_Information__c>();
        inactiveRefOwnerAccounts = new Map<Id, Reference_Basic_Information__c>();
        userMap = new Map<Id, User>();
    }
    
    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Reference_Owner__c, Account__r.OwnerId, Account__c, Account__r.Name
        									FROM Reference_Basic_Information__c
        									WHERE Generic_Account__c = false
        									AND Account__c != null
        									AND Contact__c = null
											AND Is_Referenceable__c = true
											AND (Referenceability_Status__c = :ConstantsController.ACTIVE
												OR Referenceability_Status__c = :ConstantsController.CAUTION)]);
    }
    
    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List<Reference_Basic_Information__c> scope) {
    	Set<Id> userIds = new Set<Id>();
    	
    	for (Reference_Basic_Information__c rbi : scope) {
    		
    		if (!userIds.contains(rbi.Reference_Owner__c)) {
    			userIds.add(rbi.Reference_Owner__c);
    		}
    		
    		if (!userIds.contains(rbi.Account__r.OwnerId)) {
    			userIds.add(rbi.Account__r.OwnerId);
    		}
    	}
    	
    	for (User usr : [SELECT Id, IsActive, Name FROM User WHERE Id IN :userIds]) {
    		
    		if (!userMap.containsKey(usr.Id)) {
    			userMap.put(usr.Id, usr);
    		}
    	}
    	
    	for (Reference_Basic_Information__c rbi : scope) {
    		
    		if (rbi.Reference_Owner__c != null
    				&& userMap.containsKey(rbi.Reference_Owner__c)
    				&& (!userMap.get(rbi.Reference_Owner__c).IsActive || Test.isRunningTest())) {
    			
    			if (!inactiveRefOwnerAccounts.containsKey(rbi.Account__c)) {
    				inactiveRefOwnerAccounts.put(rbi.Account__c, rbi);
    			}
    		} else if (rbi.Reference_Owner__c == null) {
    			
    			if (rbi.Account__r.OwnerId != null
    					&& userMap.containsKey(rbi.Account__r.OwnerId)
    					&& (!userMap.get(rbi.Account__r.OwnerId).IsActive || Test.isRunningTest())) {
    				
    				if (!inactiveAccOwnerAccounts.containsKey(rbi.Account__c)) {
	    				inactiveAccOwnerAccounts.put(rbi.Account__c, rbi);
	    			}
    			}
    		}
    	}
    }
    
    /**
	 * Method called after execute
	 */
    global void finish(Database.BatchableContext BC) {
    	
    	if (inactiveRefOwnerAccounts.size() > 0 || inactiveAccOwnerAccounts.size() > 0) {
	    	List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
	    	 
			//REF-1316- Added check for CRP team member should be active
            List<User> publicGroupMembers = UtilityController.getCustomerReferenceTeam();
    		String emailBody = '';
    		
    		if (inactiveRefOwnerAccounts.size() > 0) {
	    		emailBody = emailBody + '<p style="font-family: Arial, Helvetica, sans-serif">The Reference Owners for the following Reference Program Accounts'
    								+ ' are no longer active users in salesforce and should be updated:</p>\n\n'
    								+ '<table style="width: 90%">'
    								+ '<tr>'
    								+ '<th style="text-align: left; width: 50%; font-family: Arial, Helvetica, sans-serif">Account</th>'
    								+ '<th style="text-align: left; width: 25%; font-family: Arial, Helvetica, sans-serif">Reference Owner</th>'
    								+ '<th style="text-align: left; width: 25%; font-family: Arial, Helvetica, sans-serif">Account Record</th>'
    								+ '</tr>';
				
				for (Id accId : inactiveRefOwnerAccounts.keySet()) {
					emailBody = emailBody + '<tr>'
									+ '<td style="font-family: Arial, Helvetica, sans-serif">' + inactiveRefOwnerAccounts.get(accId).Account__r.Name + '</td>'
									+ '<td style="font-family: Arial, Helvetica, sans-serif">' + (inactiveRefOwnerAccounts.containsKey(accId) && inactiveRefOwnerAccounts.get(accId).Reference_Owner__c != null ?
									userMap.get(inactiveRefOwnerAccounts.get(accId).Reference_Owner__c).Name :
									'')
									+ '</td>'
									+ '<td style="font-family: Arial, Helvetica, sans-serif"><a href="' + System.URL.getSalesforceBaseURL().toExternalForm()
													+ '/' + accId + '">' + inactiveRefOwnerAccounts.get(accId).Account__r.Name
													+ '</a></td>'
									+ '</tr>';
				}
				emailBody += '</table>';
    		}
    		
    		if (inactiveAccOwnerAccounts.size() > 0) {
    			emailBody = emailBody + '<p style="font-family: Arial, Helvetica, sans-serif">The Owners for the following Reference Program Accounts'
    								+ ' are no longer active users in salesforce and should be updated:</p>\n\n'
    								+ '<table style="width: 90%">'
    								+ '<tr>'
    								+ '<th style="text-align: left; width: 50%; font-family: Arial, Helvetica, sans-serif">Account</th>'
    								+ '<th style="text-align: left; width: 25%; font-family: Arial, Helvetica, sans-serif">Owner</th>'
    								+ '<th style="text-align: left; width: 25%; font-family: Arial, Helvetica, sans-serif">Account Record</th>'
    								+ '</tr>';
    			
    			for (Id accId : inactiveAccOwnerAccounts.keySet()) {
					emailBody = emailBody + '<tr>'
									+ '<td style="font-family: Arial, Helvetica, sans-serif">' + inactiveAccOwnerAccounts.get(accId).Account__r.Name + '</td>'
									+ '<td style="font-family: Arial, Helvetica, sans-serif">' + userMap.get(inactiveAccOwnerAccounts.get(accId).Account__r.OwnerId).Name + '</td>'
									+ '<td style="font-family: Arial, Helvetica, sans-serif"><a href="' + System.URL.getSalesforceBaseURL().toExternalForm()
													+ '/' + accId + '">' + inactiveAccOwnerAccounts.get(accId).Account__r.Name
													+ '</a></td>'
									+ '</tr>';
				}
				emailBody += '</table>';
    		}
    		List<String> sendToIds = new List<String>();
    		
    		for (User gm : publicGroupMembers) {
                String userId = gm.Id;
        		
        		if (userId.startsWith('005')) {
		    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        			mail.setTargetObjectId(userId);
        			mail.setSenderDisplayName('ReferenceEdge');
        			mail.setSaveAsActivity(false);
					mail.setSubject('Inactive Owners for Reference Program Members');
					mail.setHtmlBody(emailBody);
		    		mailsList.add(mail);
        		}
    		}
    		
    		if (mailsList != null && mailsList.size() > 0) {
    			Messaging.sendEmail(mailsList);
    		}
    	}
    }
}