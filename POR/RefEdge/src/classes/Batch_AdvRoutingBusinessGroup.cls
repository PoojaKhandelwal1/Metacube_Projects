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
 * Batch to update the advanced routing mapping table if any new value is added in the routing picklist.
 * This batch executes daily and notifies the CRP team if any new value is added in the routing picklist.
 * 
 * Modified By : Dixita Jain (Sept, 2018)
 */
global with sharing class Batch_AdvRoutingBusinessGroup implements Database.Batchable<sObject>, Database.stateful {
    
    private String soqlQuery { get; set; }
    
    private Map<String, Schema.SObjectField> fieldMap { get; set; }
    
    // map to store existing advanced routing records mapped to the respective client routing values
    private Map<String, List<Advanced_Routing__c>> existingMappingRecords { get; set; }
    
    private Custom_Settings__c cs { get; set; }
    
    private Set<String> newPicklistValues { get; set; }
    
    private Set<String> oldPicklistValues { get; set; }
    
    // set to store any values which are deleted from the picklist
    private Set<String> deletedPicklistValues { get; set; }
    
    // set to store any values which are added to the picklist
    private Set<String> addedPicklistValues { get; set; }
    
    private List<String> listOfFailedRecords = new List<String>();
    
    /**
     * getting all the values in the Routing Group for comparing if any
     * new value is added in the picklist or not
     * 
     */
    global Batch_AdvRoutingBusinessGroup() {
    	soqlQuery = 'SELECT Id, Adv_Routing_Client_Value__c FROM Advanced_Routing__c';
    	cs = UtilityController.getCustomSettings();
    	existingMappingRecords = new Map<String, List<Advanced_Routing__c>>();
    	String accTeamObject = '';
		String selectedContactField = '';
    	String routingPicklist = '';
    	newPicklistValues = new Set<String>();
    	oldPicklistValues = new Set<String>();
    	addedPicklistValues = new Set<String>();
    	deletedPicklistValues = new Set<String>();
        Set<String> excludedRoutingGroups = new Set<String>();

        if (cs.Routing_Groups_to_Exclude__c != null && cs.Routing_Groups_to_Exclude__c != '') {
            excludedRoutingGroups.addAll(cs.Routing_Groups_to_Exclude__c.split(','));
        }
    	
    	if (cs.Adv_Rt_Acct_Team_Object__c != null && cs.Adv_Rt_Acct_Team_Object__c != '') {
			accTeamObject = cs.Adv_Rt_Acct_Team_Object__c;
		}
		
		if (cs.Adv_Rt_Acct_Team_Routeby__c != null && cs.Adv_Rt_Acct_Team_Routeby__c != '') {
			routingPicklist = cs.Adv_Rt_Acct_Team_Routeby__c;
		}
		selectedContactField = (cs.Adv_Rt_Acct_Team_Contact__c != null ? cs.Adv_Rt_Acct_Team_Contact__c : '');  
		//#REF-1928
		accTeamObject = selectedContactField != null && selectedContactField != '--None--' && selectedContactField != '' ? 'Contact' : accTeamObject;
		
		if (accTeamObject != '') {
			Schema.SObjectType objType = CRUDAndFLSCheckController.sObjectsMap.get(accTeamObject);
			Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
			
			// getting the picklist values and storing in a list
			// these are the new values after user updations in the routing picklist
			if (routingPicklist != '') {
				Schema.SObjectField field = objDescribe.fields.getMap().get(routingPicklist);
				Schema.DescribeFieldResult dfr = field.getDescribe();
				
				for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
					
                    if (!excludedRoutingGroups.contains(ple.getValue())) {
                        newPicklistValues.add(ple.getLabel());
                    }
				}
			}
		}
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // getting all the advanced routing records
        // the client routing values in these records represent the old picklist values
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Advanced_Routing__c> scope) {
    	
    	if (scope != null && scope.size() > 0) {
    		
    		// storing the old picklist values in a list
    		for (Advanced_Routing__c ar : scope) {
	    		oldPicklistValues.add(ar.Adv_Routing_Client_Value__c);
	    		
	    		if (!existingMappingRecords.containsKey(ar.Adv_Routing_Client_Value__c)) {
	    			existingMappingRecords.put(ar.Adv_Routing_Client_Value__c, new List<Advanced_Routing__c>());
	    		}
	    		existingMappingRecords.get(ar.Adv_Routing_Client_Value__c).add(ar);
    		}
    	}
    }
    
    global void finish(Database.BatchableContext BC) {
    	List<Advanced_Routing__c> mappingsToInsert = new List<Advanced_Routing__c>();
    	List<Advanced_Routing__c> mappingsToDelete = new List<Advanced_Routing__c>();
    	
    	// checking if any new values are added in the picklist
    	for (String str : newPicklistValues) {
    		
    		if (!oldPicklistValues.contains(str)) {
    			addedPicklistValues.add(str);
    		}
    	}
    	
    	// checking if any values are deleted from the picklist
    	for (String str : oldPicklistValues) {
    		
    		if (!newPicklistValues.contains(str)) {
    			deletedPicklistValues.add(str);
    		}
    	}
    	
    	if (addedPicklistValues != null && addedPicklistValues.size() > 0) {
    		
    		// creating new mapping records corresponding to newly added values in routing picklist
    		for (String str : addedPicklistValues) {
    			mappingsToInsert.add(new Advanced_Routing__c(Adv_Routing_Client_Value__c = str));
    		}
    		Database.SaveResult[] insertResultList = Database.insert(mappingsToInsert, false);
    		
    		for (Database.SaveResult sr : insertResultList) {
                
                // checking for failed records
                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    listOfFailedRecords.add('Mapping Records Insert Error: ' + err.getMessage());
                }
            }
    	}
    	
    	// code for updating table if any value is deleted from the routing picklist
    	// may be required in future
    	/*
    	if (deletedPicklistValues != null && deletedPicklistValues.size() > 0) {
    		for (String str : deletedPicklistValues) {
	    		mappingsToDelete.addAll(existingMappingRecords.get(str));
    		}
    		Database.DeleteResult[] deleteResultList = Database.delete(mappingsToDelete, false);
    		for (Database.DeleteResult dr : deleteResultList) {
                if (!dr.isSuccess()) {
                    Database.Error err = dr.getErrors()[0];
                    listOfFailedRecords.add('Mapping Records Delete Error: ' + err.getMessage());
                }
            }
    	}
    	*/
    	
    	// sending the email and chatter notifications to the CRP team regarding the changes
    	UtilityController.sendEmailNotification(listOfFailedRecords, 'Advanced Routing: Update Routing Picklist Batch');
    	
    	if ((mappingsToInsert != null && mappingsToInsert.size() > 0)
				    	|| (mappingsToDelete != null && mappingsToDelete.size() > 0)) {
	    	
	    	List<sObject> postFeedItems = new List<sObject>();
	    	List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
	    	String postTitle = 'Advanced Routing Updates.';	    	 
			//REF-1316- Added check for CRP team member should be active														
			List<User> publicGroupMembers = UtilityController.getCustomerReferenceTeam();
	    												
	    	String keyPrefix = '/' + Advanced_Routing__c.SObjectType.getDescribe().getKeyPrefix();
	    	String csId = '/' + cs.Id;
	    	RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
	    	
	    	for (User member : publicGroupMembers) {
	            String userId = member.Id;
	    		
	    		if (userId.startsWith('005')) {
	    			// creating email notification
	    			listmail.add(MailChatterController.prepareEmail(
			                        			'ReferenceEdge Advanced Routing Change Notification',
			                        			 userId,
			                        			'Changes to the "Routing Group" associated ' +
			                        			'with Advanced Routing have resulted in updates to the Advanced Routing records.\n' +
			                        			'Please closely review ' +
			                        			'<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + csId + '">' +
                    									'Custom Settings' + '</a>' +
                    							' and ' +
                    							'<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + keyPrefix + '">' +
                    									'Advanced Routing' + '</a>' +
                    							' to familiarize yourself with these updates.',
			                            		true));
	    			// creating chatter post
	    			//ReferenceEdge user is used as sender regarding #486
	    			postFeedItems.add(MailChatterController.preparePostForRefedgeUser(
			                        			postTitle,
			                        			userId,
			                        			'Changes to the "Routing Group" associated ' +
			                        			'with Advanced Routing have resulted in updates to the Advanced Routing records.\n' +
			                        			'Please closely review "Custom Settings" and "Advanced Routing" to familiarize yourself with these updates.',
			                            		URL.getSalesforceBaseUrl().toExternalForm() + keyPrefix, protectedAppConfig.User_Id__c));
	    		}
	        }
	        
	        if (postFeedItems.size() > 0) {
	            postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
	        }
	        
	        if (listmail.size() > 0) {
	            Messaging.sendEmail(listmail);
	        }
    	}
    }
}