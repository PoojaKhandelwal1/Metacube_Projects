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
 * Batch : Batch_UpdateCurrentAvailablePoints  
 * Description : Batch used to update current available points -re #808   
 * Last Modified by : Rajesh (15 June 2017)-#881
 */ 
global with sharing class Batch_UpdateCurrentAvailablePoints implements Database.Batchable<sObject>, Database.stateful {
    //Variable declaration
    private String soqlQuery = '';  
	private String emailBody = '';
	
	/**
     * Batch_UpdateCurrentAvailablePoints Constructor
     */
    global Batch_UpdateCurrentAvailablePoints() {
    	
    	soqlQuery = 'SELECT Id, Account__c, Account__r.Name, Contact__c, Name, Contact__r.Name, Is_Referenceable__c, Current_Available_Balance_Points__c FROM Reference_Basic_Information__c WHERE Lifetime_Points__c != null AND Current_Available_Balance_Points__c != null';
    	
    	emailBody = '<p style="font-family: Arial, Helvetica, sans-serif"> Account/Contact Current Available Points Update Report :' 
    								+ '<table style="width: 90%">'
    								+ '<tr>'
    								+ '<th style="text-align: left; width: 25%; font-family: Arial, Helvetica, sans-serif">Account</th>'
    								+ '<th style="text-align: left; width: 25%; font-family: Arial, Helvetica, sans-serif">Contact</th>'
    								+ '<th style="text-align: left; width: 25%; font-family: Arial, Helvetica, sans-serif">Last Value</th>'
    								+ '<th style="text-align: left; width: 25%; font-family: Arial, Helvetica, sans-serif">Updated Value</th>'
    								+ '</tr>'; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        return Database.getQueryLocator(soqlQuery);
    }
    
    /**
     * execute batch
     */
    global void execute(Database.BatchableContext BC, List<Reference_Basic_Information__c> scope) {    	 
    	Set<String> setAccount = new Set<String>();
		Set<String> setContact = new Set<String>();
		List<Reward__c> rewards = new List<Reward__c>();
		List<Reference_Basic_Information__c> lstRBI = new List<Reference_Basic_Information__c>(); 
	    lstRBI = scope.deepClone(); 
		Map<Id, Reference_Basic_Information__c> rbiMap = new Map<Id, Reference_Basic_Information__c>();
    	//Iterate RBI list for get RBI Map and Accounts
		for (Reference_Basic_Information__c rbi : scope) {
			
			if (rbi.Contact__c != null) {
				rbiMap.put(rbi.Contact__c, rbi);
				setContact.add(rbi.Contact__c); 
		   } else if (rbi.Account__c != null) {
				rbiMap.put(rbi.Account__c, rbi);
				setAccount.add(rbi.Account__c);
		   }
		} 
		
		//Getting rewards which are not expired even records cross their expiration dates
		List<Reward__c> lstRewards = [SELECT Id, Expired__c,Account__c, Available_Points__c, Expiration_Date__c 
		                                          FROM Reward__c WHERE (Account__c IN :setAccount OR Contact__c IN :setContact)
		                                          AND Expired__c = FALSE
		                                          AND Transaction__c = 'Issue'
		                                          AND Expiration_Date__c != null         
                                      			  AND Expiration_Date__c <= YESTERDAY   
		                                          ORDER BY Account__c];
		
		for (Reward__c reward : lstRewards) {
		    reward.Expired__c = true; 
		    rewards.add(reward);
		}
		
		//Update expired rewards.
		if (rewards.size() > 0) {
		     update rewards;
		}
		
		//Now finally get accurate available points for RBI
		List<Reward__c> lstUpdatedRewards = [SELECT Id, Expired__c, Account__c, Account__r.Name, Contact__c, Available_Points__c, Expiration_Date__c 
		                                          FROM Reward__c WHERE (Account__c IN :setAccount OR Contact__c IN :setContact) 
		                                          AND Transaction__c = 'Issue'
		                               	          AND Available_Points__c != Null
		                                          ORDER BY Account__c];
		
		Map<Id, decimal> mapPoints = new Map<Id, decimal>();
		
		for (Reward__c reward : lstUpdatedRewards) {
		
		    if (reward.Account__c != null) { 
			
				if (!mapPoints.containsKey(reward.Account__c)) {
				  	mapPoints.put(reward.Account__c, reward.Available_Points__c); 
				} else { 
					mapPoints.put(reward.Account__c, mapPoints.get(reward.Account__c) + reward.Available_Points__c);
				}
			} 
			
			if (reward.Contact__c != null) { 
			
				if (!mapPoints.containsKey(reward.Contact__c)) {
					mapPoints.put(reward.Contact__c, reward.Available_Points__c);
				} else {
					mapPoints.put(reward.Contact__c, mapPoints.get(reward.Contact__c) + reward.Available_Points__c);
				} 
			}
		}
		
		for (Reference_Basic_Information__c rbi : scope) {
		
			if (rbi.Contact__c == null) {
			
				if (mapPoints.containsKey(rbi.Account__c)) {
					rbiMap.get(rbi.Account__c).Current_Available_Balance_Points__c = mapPoints.get(rbi.Account__c);
				} 
			} else if (rbi.Contact__c != null) {
			
				if (mapPoints.containsKey(rbi.Contact__c)) {
					rbiMap.get(rbi.Contact__c).Current_Available_Balance_Points__c = mapPoints.get(rbi.Contact__c);
				} 
			}
		} 
	  
		for (Reference_Basic_Information__c rbi : lstRBI) {
		 
			if (rbi.Contact__c == null && rbi.Account__c != null && rbiMap.get(rbi.Account__c) != null) { 
				
				if (rbi.Current_Available_Balance_Points__c != rbiMap.get(rbi.Account__c).Current_Available_Balance_Points__c) { 
					 
					emailBody = emailBody + '<tr>'
									+ '<td style="font-family: Arial, Helvetica, sans-serif">' + rbi.Account__r.Name  + '</td>' 
									+ '<td style="font-family: Arial, Helvetica, sans-serif">' + 'NIL' + '</td>'
									+ '<td style="font-family: Arial, Helvetica, sans-serif">' + String.valueOf(rbi.Current_Available_Balance_Points__c) + '</td>'
									+ '<td style="font-family: Arial, Helvetica, sans-serif">' +  String.valueOf(rbiMap.get(rbi.Account__c).Current_Available_Balance_Points__c) + '</td>' 
									+ '</tr>';
					 				
				}
			} else if (rbi.Contact__c != null  && rbiMap.get(rbi.Contact__c) != null) {  
				
				if (rbi.Current_Available_Balance_Points__c != rbiMap.get(rbi.Contact__c).Current_Available_Balance_Points__c) {
					 
					emailBody = emailBody + '<tr>'
									+ '<td style="font-family: Arial, Helvetica, sans-serif">' +  rbi.Account__r.Name + '</td>'
									+ '<td style="font-family: Arial, Helvetica, sans-serif">' + rbi.Contact__r.Name  + '</td>'
									+ '<td style="font-family: Arial, Helvetica, sans-serif">' + String.valueOf(rbi.Current_Available_Balance_Points__c) + '</td>'
									+ '<td style="font-family: Arial, Helvetica, sans-serif">' + String.valueOf(rbiMap.get(rbi.Contact__c).Current_Available_Balance_Points__c) + '</td>' 
									+ '</tr>';
				}
			}  		 
		} 
		
		//Update RBI records
		if (rbiMap != null && rbiMap.size() > 0) {
		    update rbiMap.values();
		}	 
    }
    
    global void finish(Database.BatchableContext BC) {
    	emailBody = emailBody + '</table></br> Please do not reply to this mail.</p>';
    	List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {UserInfo.getUserEmail()};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Account/Contact Current Available Points Update Report');
        mail.setHtmlBody(emailBody);
       	mail.setToAddresses(toAddresses);
        listmail.add(mail);
            
        if (listmail.size() > 0) {  
            Messaging.sendEmail(listmail);  
        }
    }
}