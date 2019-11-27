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
public with sharing class CustomSettingTriggerHandler {

    /**
     * Method called on before insert of Custom Setting
     */
    public static void onBeforeInsert(List<Custom_Settings__c > customSettings) {
        List<Custom_Settings__c> existCustomSettings = new List<Custom_Settings__c>([SELECT Id FROM Custom_Settings__c LIMIT: limits.getLimitQueryRows()]);
        
        if (existCustomSettings.size() > 0) {
        	
            for (Custom_Settings__c cs : customSettings) {
                cs.addError(System.Label.NEW_CUSTOM_SETTING);
                return;
            }
        }
        
        for (Custom_Settings__c cs : customSettings) {
        	
        	//validation for shared contact settings
            if (!cs.Shared_Contacts__c) {
            	
            	if (cs.Roll_up_Attributes_to_All_Accounts__c || cs.Roll_up_Attributes_to_Primary_Account__c || cs.Roll_up_Referenceability_to_All_Accounts__c ||
            		cs.Roll_up_Referenceability_to_Primary_Acc__c || cs.Inherit_Attributes_from_All_Accounts__c || cs.Inherit_Attributes_from_Primary_Account__c ||
            		cs.Shared_Account_Field__c != null || cs.Shared_Contact_Field__c != null || cs.Shared_Contact_Object__c != null) {
            		cs.addError(system.Label.Shared_Contact_check_setting);
                	return;
            	}
            }
        }
        validateCustomSetting(customSettings);
    }

    /**
     * Method called on before update of Custom Setting
     */
    public static void onBeforeUpdate(List<Custom_Settings__c> customSettings, Map<Id, Custom_Settings__c> oldMap, Map<Id, Custom_Settings__c> newMap) {
        // added for #625 - showing validation if user unchecks the "New Contact Creates Nomination" field
        //					without configuring the reference profile form
        // Gaurav Saini (18 Oct, 2017)
        List<Data_Mapping__c> dataMappingsList = [SELECT Visible__c, Required__c, Referenceability_Type__c, Order__c,
			            							Object__c, Name, Label__c, Id, Filter__c, Field_API_Name__c
			            							FROM Data_Mapping__c
			            							WHERE Object__c = :ConstantsController.REFERENCE_PROFILE_FORM
			            							AND Visible__c = true
			            							AND Referenceability_Type__c = null
			            							AND Label__c = null
			            							AND Field_API_Name__c != null
			            							AND Order__c > 2
			            							ORDER BY Order__c];
    	
        for (Custom_Settings__c custom : customSettings) {
	        
	    	if (oldMap.get(custom.Id).PUM_New_Contact__c && !newMap.get(custom.Id).PUM_New_Contact__c && (dataMappingsList == null || dataMappingsList.size() == 0)) {
	    		newMap.get(custom.Id).PUM_New_Contact__c.addError('Reference Profile form for Profile Update Minder must be configured before this setting can be changed.');
	    	}
        	
        	if (!custom.P2P_Select_Inactive_Contacts__c && oldMap.get(custom.Id).P2P_Select_Inactive_Contacts__c) {
            	custom.P2P_Approve_Without_Contact__c = false;
            }
            
            //validation for shared contact settings
            if (!custom.Shared_Contacts__c) {
            	
            	if ((oldMap.get(custom.Id).Roll_up_Attributes_to_All_Accounts__c != newMap.get(custom.Id).Roll_up_Attributes_to_All_Accounts__c 
            			&& newMap.get(custom.Id).Roll_up_Attributes_to_All_Accounts__c) || 
            		(oldMap.get(custom.Id).Roll_up_Attributes_to_Primary_Account__c != newMap.get(custom.Id).Roll_up_Attributes_to_Primary_Account__c 
            			&& newMap.get(custom.Id).Roll_up_Attributes_to_Primary_Account__c) || 
            		(oldMap.get(custom.Id).Roll_up_Referenceability_to_All_Accounts__c != newMap.get(custom.Id).Roll_up_Referenceability_to_All_Accounts__c 
            			&& newMap.get(custom.Id).Roll_up_Referenceability_to_All_Accounts__c) ||
            		(oldMap.get(custom.Id).Roll_up_Referenceability_to_Primary_Acc__c != newMap.get(custom.Id).Roll_up_Referenceability_to_Primary_Acc__c 
            			&& newMap.get(custom.Id).Roll_up_Referenceability_to_Primary_Acc__c) || 
            		(oldMap.get(custom.Id).Inherit_Attributes_from_All_Accounts__c != newMap.get(custom.Id).Inherit_Attributes_from_All_Accounts__c 
            			&& newMap.get(custom.Id).Inherit_Attributes_from_All_Accounts__c) || 
            		(oldMap.get(custom.Id).Inherit_Attributes_from_Primary_Account__c != newMap.get(custom.Id).Inherit_Attributes_from_Primary_Account__c 
            			&& newMap.get(custom.Id).Inherit_Attributes_from_Primary_Account__c) ||
            		(oldMap.get(custom.Id).Shared_Account_Field__c != newMap.get(custom.Id).Shared_Account_Field__c 
            			&& newMap.get(custom.Id).Shared_Account_Field__c != null && newMap.get(custom.Id).Shared_Account_Field__c != '') || 
            		(oldMap.get(custom.Id).Shared_Contact_Field__c != newMap.get(custom.Id).Shared_Contact_Field__c 
            			&& newMap.get(custom.Id).Shared_Contact_Field__c != null && newMap.get(custom.Id).Shared_Contact_Field__c != '') || 
            		(oldMap.get(custom.Id).Shared_Contact_Object__c != newMap.get(custom.Id).Shared_Contact_Object__c 
            			&& newMap.get(custom.Id).Shared_Contact_Object__c != null && newMap.get(custom.Id).Shared_Contact_Object__c != '')) {
            		custom.addError(system.Label.Shared_Contact_check_setting);
                	return;
            	}
            }
        }
        validateCustomSetting(customSettings);
        validateWorkspaceSetting(customSettings, newMap, oldMap);
        List<Attribute_Mapping__c> attMappings = [SELECT Field_Api_Name__c FROM Attribute_Mapping__c 
        										WHERE Object__c = :ConstantsController.OPPORTUNITY AND Field_Api_Name__c != 'StageName' 
        										AND Is_Related_Mapping__c = false];
        
        for (Custom_Settings__c custom: customSettings) {
        	
            if (custom.Opportunity_Product_Field_API_Name__c != null 
            		&& oldMap.get(custom.Id).Opportunity_Product_Field_API_Name__c != newMap.get(custom.Id).Opportunity_Product_Field_API_Name__c) {
            	
            	if (attMappings != null && attMappings.size() > 0) {
            		custom.addError(System.Label.Opportunity_Error_Msg);
            	}
            }
            
            if (!custom.Chatter_Enabled__c && oldMap.get(custom.Id).Chatter_Enabled__c != newMap.get(custom.Id).Chatter_Enabled__c) {
                custom.Microsite_Visit_Chatter__c = false;
                custom.Nomination_Chatter__c = false;
                custom.Project_Owner_Update_Chatter__c = false;
                custom.Request_Managed_Chatter__c = false;
                custom.Request_Peer2Peer_Chatter__c = false;
                custom.Request_Approval_Decline_Chatter__c = false;
                custom.Request_Escalation_Chatter__c = false;
                custom.Request_Feedback_Chatter__c = false;
                custom.Request_No_Response_Chatter__c = false;
                custom.Request_Reminder_Chatter__c = false;
                custom.Status_Update_Chatter__c = false;
                custom.Check_back_in_Chatter__c = false;
                custom.Initial_Notification_Chatter__c = false;
                custom.Process_Update_Chatter__c = false;
                custom.Reference_Lead_No_Response_Chatter__c = false;
                custom.Reference_Update_Chatter__c = false;
                custom.Reference_Refresh_Update_Chatter__c = false;
                custom.Profile_Update_Reminder_Chatter__c = false;
            } else if (ConstantsController.enableAllChatter && custom.Chatter_Enabled__c 
            			&& oldMap.get(custom.Id).Chatter_Enabled__c != newMap.get(custom.Id).Chatter_Enabled__c) {
                custom.Microsite_Visit_Chatter__c = true;
                custom.Nomination_Chatter__c = true;
                custom.Project_Owner_Update_Chatter__c = true;
                custom.Request_Managed_Chatter__c = true;
                custom.Request_Peer2Peer_Chatter__c = true;
                custom.Request_Approval_Decline_Chatter__c = true;
                custom.Request_Escalation_Chatter__c = true;
                custom.Request_Feedback_Chatter__c = true;
                custom.Request_No_Response_Chatter__c = true;
                custom.Request_Reminder_Chatter__c = true;
                custom.Status_Update_Chatter__c = true;
                custom.Check_back_in_Chatter__c = true;
                custom.Initial_Notification_Chatter__c = true;
                custom.Process_Update_Chatter__c = true;
                custom.Reference_Lead_No_Response_Chatter__c = true;
                custom.Reference_Update_Chatter__c = true;
                custom.Reference_Refresh_Update_Chatter__c = true;
                custom.Profile_Update_Reminder_Chatter__c = true;
            }
            
            if (!custom.Email_Enabled__c && oldMap.get(custom.Id).Email_Enabled__c != newMap.get(custom.Id).Email_Enabled__c) {
                custom.Microsite_Visit_Email__c = false;
                custom.Nomination_Email__c = false;
                custom.Project_Owner_Update_Email__c = false;
                custom.Request_Managed_Email__c = false;
                custom.Request_Peer2Peer_Email__c = false;
                custom.Request_Approval_Decline_Email__c = false;
                custom.Request_Escalation_Email__c = false;
                custom.Request_Feedback_Email__c = false;
                custom.Request_No_Response_Email__c = false;
                custom.Request_Reminder_Email__c = false;
                custom.Status_Update_Email__c = false;
                custom.Check_back_in_Email__c = false;
                custom.Initial_Notification_Email__c = false;
                custom.Process_Update_Email__c = false;
                custom.Reference_Lead_No_Response_Email__c = false;
                custom.Reference_Update_Email__c = false;
                custom.Reference_Refresh_Update_Email__c = false;
                custom.Profile_Update_Reminder_Email__c = false;
            } else if (ConstantsController.enableAllEmail && custom.Email_Enabled__c 
            			&& oldMap.get(custom.Id).Email_Enabled__c != newMap.get(custom.Id).Email_Enabled__c) {
                custom.Microsite_Visit_Email__c = true;
                custom.Nomination_Email__c = true;
                custom.Project_Owner_Update_Email__c = true;
                custom.Request_Managed_Email__c = true;
                custom.Request_Peer2Peer_Email__c = true;
                custom.Request_Approval_Decline_Email__c = true;
                custom.Request_Escalation_Email__c = true;
                custom.Request_Feedback_Email__c = true;
                custom.Request_No_Response_Email__c = true;
                custom.Request_Reminder_Email__c = true;
                custom.Status_Update_Email__c = true;
                custom.Check_back_in_Email__c = true;
                custom.Initial_Notification_Email__c = true;
                custom.Process_Update_Email__c = true;
                custom.Reference_Lead_No_Response_Email__c = true;
                custom.Reference_Update_Email__c = true;
                custom.Reference_Refresh_Update_Email__c = true;
                custom.Profile_Update_Reminder_Email__c = true;
            }
        }
        
        schedularSendReminderForAutomatic(customSettings, oldMap, newMap);
    }

    /**
     * Method called on before delete of Custom Setting
     */
    public static void onBeforeDelete(List<Custom_Settings__c> customSettings) {
        validateCustomSetting(customSettings);
        validateActiveCustomSetting(customSettings);
    }

    /**
     * Method called on after update of Custom Setting
     */
    public static void onAfterUpdate(List<Custom_Settings__c> newCustomSettings, Map<Id, Custom_Settings__c> oldMap, Map<Id, Custom_Settings__c> newMap) {
        updateAccounts(newCustomSettings, oldMap, newMap);
        updateReferenceablities(newCustomSettings, oldMap, newMap);
        
        // added for #382 - Advanced request routing
        if (newCustomSettings != null && newCustomSettings.size() > 0) {
        	
        	if (newCustomSettings[0].Adv_Rt_Acct_Team_Routeby__c != oldMap.get(newCustomSettings[0].Id).Adv_Rt_Acct_Team_Routeby__c 
                || newCustomSettings[0].Adv_Rt_Acct_Team_Contact__c != oldMap.get(newCustomSettings[0].Id).Adv_Rt_Acct_Team_Contact__c 
                || newCustomSettings[0].Routing_Groups_to_Exclude__c != oldMap.get(newCustomSettings[0].Id).Routing_Groups_to_Exclude__c 
                || newCustomSettings[0].Adv_Rt_Acct_Team_Object__c != oldMap.get(newCustomSettings[0].Id).Adv_Rt_Acct_Team_Object__c) {
		        updateRoutingMappingTable(newCustomSettings,oldMap);
        	}
        }
        
        //REF-2349
        if (ConstantsController.isFromEmailChatterSettings) {
          	getUpdatedFieldsFromEmailChatterSettings(newCustomSettings,oldMap,newMap);
        }
    }
    
    //REF-2349
    static void getUpdatedFieldsFromEmailChatterSettings(List<Custom_Settings__c> newCustomSettings, Map<Id, Custom_Settings__c> oldMap, Map<Id, Custom_Settings__c> newMap) {
        Custom_Settings__c newCS = newMap.get(newCustomSettings[0].Id);
        Custom_Settings__c oldCS = oldMap.get(newCustomSettings[0].Id);
        Custom_Settings__c csInstance = new Custom_Settings__c();
        List<String> listChangedFields = new List<String>();
        Boolean isChatterUpdated = false;
        Boolean isEmailUpdated = false;
        Boolean isSlackUpdated = false;
        Map<String,String> mapChangedFieldsToLabel = new Map<String,String>();
        Map<String,Boolean> mapGlobalSettingUpdatedValue = new Map<String,Boolean>();
        Map<String,String> mapGlobalSettingFieldToLabel = new Map<String,String>();
        
        Schema.SObjectType objType = csInstance.getSObjectType(); 
        Map<String, Schema.SObjectField> M = Schema.SObjectType.Custom_Settings__c.fields.getMap();
        
        for (String str : M.keyset()) { 
            try { 
                
                if ((newCS.get(str) != oldCS.get(str)) && M.get(str).getDescribe().isCustom()) {
                    str = str.toLowerCase();
                    Boolean globalValue = newCS.get(str) == false ? false : true;
                    String fieldLabel = M.get(str).getDescribe().getLabel();
                    
                    if (str.contains('chatter_enabled__c')) {
                        isChatterUpdated = true;
                        mapGlobalSettingUpdatedValue.put(str, globalValue);
                        mapGlobalSettingFieldToLabel.put(str, 'Chatter');
                        listChangedFields.add(str);
                        mapChangedFieldsToLabel.put(str,fieldLabel);
                        
                    } else if (str.contains('email_enabled__c')) {
                        isEmailUpdated = true;
                        mapGlobalSettingUpdatedValue.put(str, globalValue);
                        mapGlobalSettingFieldToLabel.put(str, 'Email');
                        listChangedFields.add(str);
                        mapChangedFieldsToLabel.put(str,fieldLabel);
                        
                    } else if (str.contains('slack_enabled__c')) {
                        isSlackUpdated = true;
                        mapGlobalSettingUpdatedValue.put(str, globalValue);
                        mapGlobalSettingFieldToLabel.put(str, 'Slack');
                        listChangedFields.add(str);
                        mapChangedFieldsToLabel.put(str,fieldLabel);
                        
                    } else if (!globalValue) {
                        listChangedFields.add(str);
                        mapChangedFieldsToLabel.put(str,fieldLabel);
                    }
                } 
            } catch (Exception e) { 
                throw e; 
            } 
        } 
        
        if (listChangedFields.size() > 0) {
            List<String> tempFields;
            
            if (isChatterUpdated) {
                listChangedFields = removeFieldsIfGlobalFieldIsSetToFalse('_chatter__c',listChangedFields);
            }
            
            if (isEmailUpdated) {
                listChangedFields = removeFieldsIfGlobalFieldIsSetToFalse('_email__c',listChangedFields);
            }
            
            if (isSlackUpdated) {
                listChangedFields = removeFieldsIfGlobalFieldIsSetToFalse('_slack__c',listChangedFields);
            }
            sendUpdateDetailsToCRMTeam(listChangedFields,mapGlobalSettingUpdatedValue,mapGlobalSettingFieldToLabel,mapChangedFieldsToLabel);
        }
    }
    
    public static List<String> removeFieldsIfGlobalFieldIsSetToFalse(String globalFieldName, List<String> listChangedFields) {
        //global field names = _email__c, _chatter__c, _slack__c
        List<String> listOfRemainingFields = new List<String>();
        
        if (listChangedFields.size() > 0) {
            
            for (String fields : listChangedFields) {
                 
                if (!fields.contains(globalFieldName)) {
                    
                    if (!fields.contains('user_reward_')) {
                        listOfRemainingFields.add(fields);
                    } 
                }
            } 
        }
        return listOfRemainingFields;
    }
    
    static void sendUpdateDetailsToCRMTeam(List<String> listChangedFields, Map<String,Boolean> mapGlobalSettingUpdatedValue, Map<String,String> mapGlobalSettingFieldToLabel, Map<String,String> mapChangedFieldsToLabel) {
        List<sObject> postFeedItems = new List<sObject>();
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        List<User> publicGroupMembers = UtilityController.getCustomerReferenceTeam();
        String emailSubject = 'ReferenceEdge Notification Settings Change';
        String emailBody = '';
        listChangedFields.sort();
        
        for (String field : listChangedFields) {
			
            if (mapGlobalSettingUpdatedValue.containsKey(field) && mapGlobalSettingFieldToLabel.containsKey(field)) {
                emailBody += 'All ReferenceEdge ' + mapGlobalSettingFieldToLabel.get(field) + ' notifications have been ';
                emailBody += (mapGlobalSettingUpdatedValue.get(field) ? 'enabled' : 'disabled') + '.';
            } else {
                emailBody += 'The ' + mapChangedFieldsToLabel.get(field) + ' notification has been disabled.';
            }
            emailBody += '\n\n';
        }
        emailBody += 'To see the status of all ReferenceEdge notifications go to RefEdge Custom Settings > Notification Settings > Manage.';
        
        for (User member : publicGroupMembers) {
            String userId = member.Id;
            
            if (userId.startsWith('005')) {
                listmail.add(MailChatterController.prepareEmail(emailSubject, userId, emailBody, false));
                postFeedItems.add(MailChatterController.preparePost(emailSubject, userId, emailBody, ''));
            }
        }
        
        if (postFeedItems.size() > 0) {
            postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
        }

        if (listmail.size() > 0) {
            Messaging.sendEmail(listmail);
        }
    }
    
    /**
     * Method to create mapping table for advanced routing
     * added for #382 - Advanced Request Routing
     * This method deletes all the current records in the advanced routing object
     * and creates new records if the picklist to route by field is changed
     */
	static void updateRoutingMappingTable(List<Custom_Settings__c> newCustomSettings, Map<Id, Custom_Settings__c> oldMap) {
		String[] listofMapping = new List<String>();
		List<Advanced_routing__c> oldAdvRoutingList =new List<Advanced_routing__c>();
		List<Advanced_routing__c> newAdvRoutingList = new List<Advanced_routing__c>();
		
		if (oldMap != null && oldMap.get(newCustomSettings[0].Id).Adv_Rt_Acct_Team_Object__c != null) { 
            String accTeamObject = oldMap.get(newCustomSettings[0].Id).Adv_Rt_Acct_Team_Object__c;
            
            if (oldMap.get(newCustomSettings[0].Id).Adv_Rt_Acct_Team_Contact__c != null && oldMap.get(newCustomSettings[0].Id).Adv_Rt_Acct_Team_Contact__c != '') {
                accTeamObject = 'Contact';
            }
            
			Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(accTeamObject);
            
        	if (objectType != null) {
            	Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap(); 
                
	            for (String field : fieldMap.keySet()) {
                    
                    if (oldMap.get(newCustomSettings[0].Id).Adv_Rt_Acct_Team_Routeby__c!=null) {
                        
            			if (field.equalsIgnoreCase(oldMap.get(newCustomSettings[0].Id).Adv_Rt_Acct_Team_Routeby__c)) {
			                Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe(); 
			                List<Schema.PicklistEntry> ple = dfr.getPicklistValues(); 
			                
						   	for (Schema.PicklistEntry f : ple) {
					   		  	listofMapping.add(f.getValue().trim()); 
						   	}
			            } 
		           	}
	          	}
       	 	}  
                
	    	if (listofMapping!=null && listofMapping.size() > 0) {
		 		oldAdvRoutingList = [SELECT Id, Name, Adv_Routing_Name__c, Adv_Routing_Client_Value__c, Adv_Routing_Attribute__c 
		 								FROM Advanced_Routing__c WHERE Adv_Routing_Client_Value__c IN : listofMapping];
				   
                if (oldAdvRoutingList != null && oldAdvRoutingList.size() > 0) {
					delete oldAdvRoutingList;
				}
		    }
		}	
		String accTeamObject = '';
        String routingPicklist = '';
    	
    	if (newCustomSettings[0].Adv_Rt_Acct_Team_Object__c != null && newCustomSettings[0].Adv_Rt_Acct_Team_Object__c != '') {
			accTeamObject = newCustomSettings[0].Adv_Rt_Acct_Team_Object__c;
		}
		
        if (newCustomSettings[0].Adv_Rt_Acct_Team_Contact__c != null && newCustomSettings[0].Adv_Rt_Acct_Team_Contact__c != '') {
			accTeamObject = 'Contact';
		}

		if (newCustomSettings[0].Adv_Rt_Acct_Team_Routeby__c != null && newCustomSettings[0].Adv_Rt_Acct_Team_Routeby__c != '') {
			routingPicklist = newCustomSettings[0].Adv_Rt_Acct_Team_Routeby__c;
		}
		
		if (accTeamObject != '') {
			Schema.SObjectType objType = CRUDAndFLSCheckController.sObjectsMap.get(accTeamObject);
			Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            Set<String> excludedRoutingGroups = new Set<String>();

            if (newCustomSettings[0].Routing_Groups_to_Exclude__c != null && newCustomSettings[0].Routing_Groups_to_Exclude__c != '') {
                excludedRoutingGroups.addAll(newCustomSettings[0].Routing_Groups_to_Exclude__c.split(','));
            }
			
			if (routingPicklist != '') {
				Schema.SObjectField field = objDescribe.fields.getMap().get(routingPicklist);
				Schema.DescribeFieldResult dfr = field.getDescribe();
				
				for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
					
                    if (!excludedRoutingGroups.contains(ple.getValue())) {
                        newAdvRoutingList.add(new Advanced_routing__c(Adv_Routing_Client_Value__c = ple.getValue()));
                    }
				}
			}
		}
		
		if (newAdvRoutingList != null && newAdvRoutingList.size() > 0) {
			upsert newAdvRoutingList;
		}
		List<Label__c> filterListToUpdate = [SELECT Name, Id, Adv_Routing_Group__c
												FROM Label__c
												WHERE Adv_Routing_Group__c != null
												AND Adv_Routing_Group__c != ''];
		
		if (filterListToUpdate != null && filterListToUpdate.size() > 0) {
			
			for (Label__c filter : filterListToUpdate) {
				filter.Adv_Routing_Group__c = '';
				filter.Show_in_P2P__c = false;
				filter.Required_in_P2P__c = false;
			}
			update filterListToUpdate;
		}
		
	}

    /**
     * Method to validate custom setting
     */
    static void validateCustomSetting(List<Custom_Settings__c> customSettings) {
    	
        for (Custom_Settings__c cs : customSettings) {
        	
        	//validation for shared contact settings
        	if (cs.Shared_Contacts__c) {
        		
	        	if ((cs.Roll_up_Attributes_to_All_Accounts__c && cs.Roll_up_Attributes_to_Primary_Account__c) 
					        		|| (cs.Roll_up_Referenceability_to_All_Accounts__c &&
					        		cs.Roll_up_Referenceability_to_Primary_Acc__c) || (cs.Inherit_Attributes_from_All_Accounts__c 
					        		&& cs.Inherit_Attributes_from_Primary_Account__c)) {
	        		cs.addError(system.Label.Roll_up_Inherit_check);
	            	return;
	        	}
	        	
	        	if (cs.Shared_Contact_Object__c == null) {
	        		cs.addError(system.Label.Please_select_Shared_Contact_Object);
	            	return;
	        	}
	        	
	        	if (cs.Shared_Account_Field__c == null) {
	        		cs.addError(system.Label.Please_select_Shared_Account_Field);
	            	return;
	        	}
	        	
	        	if (cs.Shared_Contact_Field__c == null) {
	        		cs.addError(system.Label.Please_select_Shared_Contact_Field);
	            	return;
	        	}
	        	
	        	if (!cs.Roll_up_Attributes_to_All_Accounts__c && !cs.Roll_up_Attributes_to_Primary_Account__c) {
	        		cs.addError(system.Label.Roll_up_Attribute_Msg);
	            	return;
	        	}
	        	
	        	if (!cs.Inherit_Attributes_from_All_Accounts__c && !cs.Inherit_Attributes_from_Primary_Account__c) {
	        		cs.addError(system.Label.Inherit_Attribute_Msg);
	            	return;
	        	}
	        	
	        	if (!cs.Roll_up_Referenceability_to_All_Accounts__c && !cs.Roll_up_Referenceability_to_Primary_Acc__c) {
	        		cs.addError(system.Label.Roll_up_Ref_Msg);
	            	return;
	        	}
        	}
        	
        	if (cs.Is_Influitive_Integration_Enabled__c && !cs.Limit_Contact_Redeem__c) {
        		cs.addError(system.Label.Contact_Redeem_uncheck_validation);
            	return;
        	}
        	
            // Validation postive number 
            if (cs.Number_of_request_accounts__c == null || cs.Number_of_request_accounts__c <= 0) {
                cs.addError(System.Label.REQUEST_ACCOUNT_COUNT);
                return;
            }
            
            if (cs.Manual_Automatic_Launch__c == 'Automatic' && (cs.Launch_Frequency__c == null || cs.Launch_Frequency__c == '')) {
                cs.addError(System.Label.Automatic_Validation_Error);
                return;
            }
            
            if (cs.Minimum_Deadline__c <= 0) {
                cs.addError(System.Label.MIN_DEADLINE);
                return;
            }
            
            if (cs.Reminder_to_Owner__c < 0) {
                cs.addError(System.Label.OWNER_REMINDER);
                return;
            }
            
            if (cs.Escalation_to_Owner_Manager__c < 0) {
                cs.addError(System.Label.ESCALATION_TO_OWNER);
                return;
            }
            
            if (cs.No_Response__c < 0) {
                cs.addError(System.Label.NO_RESPONSE);
                return;
            }
            
            if (cs.Feedback_Message_Delay__c <= 0) {
                cs.addError(System.Label.FEEDBACK_MESSAGE_DELAY);
                return;
            }
            
            // Validation for Reminder to Owner zero
            if (cs.Reminder_to_Owner__c == 0 && cs.Escalation_to_Owner_Manager__c != 0) {
                cs.addError(System.Label.ESCALATION_TO_OWNER_0);
                return;
            }
            
            //Validation for Reminder to Owner greater than zero
            if (cs.Reminder_to_Owner__c != 0) {
            	
                if (cs.Reminder_to_Owner__c >= cs.Minimum_Deadline__c) {
                    cs.addError(System.Label.REMINDER_MIN_DEADLINE);
                    return;
                }
                
                if (cs.Escalation_to_Owner_Manager__c != 0) {
                	
                    if (cs.Escalation_to_Owner_Manager__c >= cs.Reminder_to_Owner__c) {
                        cs.addError(System.Label.ESCALATION_REMINDER);
                        return;
                    }
                }
                
                if (cs.No_Response__c != 0 && cs.Escalation_to_Owner_Manager__c != 0) {
                	
                    if (cs.No_Response__c >= cs.Escalation_to_Owner_Manager__c) {
                        cs.addError(System.Label.NO_RESPONSE_ESCALATION);
                        return;
                    }
                }
            }
            
            //Validation for No response greater than zero
            if (cs.No_Response__c != 0) {
            	
                if (cs.No_Response__c >= cs.Minimum_Deadline__c) {
                    cs.addError(System.Label.NO_RESPONSE_MIN_DEADLINE);
                    return;
                }
            }
            
            //Validation for Include Weekends
            if (cs.Include_Weekends__c) {
            	
                if (cs.Days_of_Week__c == null) {
                    cs.addError(System.Label.WEEKEND_CHECK);
                    return;
                }
                
                if (cs.Days_of_Week__c != null) {
                    List<string > listOffDays = cs.Days_of_Week__c.split(';');
                    
                    if (listOffDays.size() > 6) {
                        cs.addError(System.Label.ONE_DAY_WORKING);
                        return;
                    }
                }
            }
            
            if (cs.Critical_Deadline_window__c < 1 || cs.Caution_deadline_window__c <= cs.Critical_Deadline_window__c) {
                cs.addError(System.Label.X0_CRITICAL_CAUTION);
                return;
            }

            if (cs.Nomination_disposition_window__c < 1) {
                cs.addError(System.Label.Nomination_disposition_window_0);
                return;
            }

            //Validation Rewards setteings
            if (cs.Expire_Rewards__c && cs.Expiration_Timeframe__c == null) {
                cs.addError(System.Label.SELECT_EXPIRATION_TIME_FRAME);
                return;
            }

            if (!cs.Expire_Rewards__c && cs.Expiration_Timeframe__c != null) {
                cs.addError(System.Label.CHECK_EXPIRE_REWARDS);
                return;
            }

            if (cs.Expire_Rewards__c && cs.Expiration_Timeframe__c == ConstantsController.X_DAYS_FROM_AWARDDATE && cs.Expiration_Days__c == null) {
                cs.addError(System.Label.Expiration_Days_must_be_populated.replace('@@@', ConstantsController.X_DAYS_FROM_AWARDDATE));
                return;
            }
            
            if (cs.Expiration_Timeframe__c != ConstantsController.X_DAYS_FROM_AWARDDATE && cs.Expiration_Days__c != null) {
                cs.addError(System.Label.Expiration_Days_available.replace('@@@', ConstantsController.X_DAYS_FROM_AWARDDATE));
                return;
            }
            
            if (cs.Expiration_Timeframe__c == ConstantsController.X_DAYS_FROM_AWARDDATE && cs.Expiration_Days__c < 1) {
                cs.addError(System.Label.EXPIRATION_DAYS_0);
                return;
            }
            
            //validation Default Referenceablity Status
            if (cs.Default_Referenceablity_Status__c == null || cs.Default_Referenceablity_Status__c == '') {
                cs.addError(System.Label.CHECK_DEFAULT_REFERENCEABILITY_STATUS);
                return;
            }
            
            if (cs.Automatically_Assign_Reward_on_Feedback__c && cs.Automatically_Assign_Rewards__c) {
                cs.addError(System.Label.BOTH_REWARD_CANNOT_SET_SAME_TIME);
                return;
            }
            
			if (!cs.P2P_Select_Inactive_Contacts__c && cs.P2P_Approve_Without_Contact__c) {
                cs.addError(System.Label.Approve_Without_Contacts);
                return;
            } 
           	
           	if (cs.Auto_Assign_Sales_Rewards__c && cs.Auto_Assign_Sales_Reward_on_Feedback__c) {
                cs.addError(System.Label.BOTH_SALES_REWARD_CANNOT_SET_SAME_TIME);
                return;
            }
           	
           	if (cs.Expire_Sales_Rewards__c && cs.Sales_Expiration_Timeframe__c == null) {
                cs.addError(System.Label.SELECTSALES_EXPIRATION_TIME_FRAME);
                return;
            }
			
            // Validation for reference lead finder settings
            if (cs.Client_Referenceability_check_days__c <= 0) {
                cs.addError(System.Label.CheckDaysMustGreaterThanZero);
                return;
            }
			
            if (cs.No_Response_days__c <= 0) {
                cs.addError(System.Label.NoResponseDaysMustGreaterZero);
                return;
            }
            
            // commented out for #896 - Gaurav Saini (10 July, 2017)
            /*
            if (cs.RLF_Reminder_Days__c <= cs.Client_Referenceability_check_days__c) {
            	cs.addError(System.Label.Reminder_Days_must_be_greater_than_Referenceability_Check_Days);
            	return;
            }
            */
            
            if (cs.RLF_Reminder_Days__c >= cs.No_Response_days__c) {
            	cs.addError(System.Label.Reminder_Days_must_be_less_than_No_Response_Days);
            	return;
            }
            // end
            
          	if (cs.Expire_Sales_Rewards__c && cs.Sales_Expiration_Timeframe__c == ConstantsController.X_DAYS_FROM_AWARDDATE 
          						&& cs.Sales_Expiration_Days__c == null) {
                cs.addError(System.Label.Expiration_Days_must_be_populated.replace('@@@', ConstantsController.X_DAYS_FROM_AWARDDATE));
                return;
            }
            
            if (cs.Adv_Request_Routing__c && cs.Adv_Routing_Default__c==null) {
            	cs.addError(System.Label.Select_Routing); 
    		 	return;
    		}  
            
        }
    }

    /**
     * Method to prevent to delete the Active custom setting
     */
    static void validateActiveCustomSetting(List<Custom_Settings__c> customSettings) {
    	
        for (Custom_Settings__c cs : customSettings) {
        	
            if (cs.Active_Version__c) {
                cs.addError(System.Label.ACTIVE_VERSION);
                return;
            }
        }
    }

    /**
     * Method to Update Accounts and Contacts 'Time Period' on custom setting 'Time Period'
     */
    static void updateAccounts(List<Custom_Settings__c> newCustomSettings, Map<Id, Custom_Settings__c> oldMap, Map<Id, Custom_Settings__c> newMap) {
        Boolean isRULPeriodChanged = false;
        Boolean isRULPeriodChangedContact = false;
        Decimal oldRULPeriod, oldRULPeriodContact;
        Decimal newRULPeriod, newRULPeriodContact;
        Decimal newRULActivitiesUpdate, newRULActivitiesUpdateContact;
        Boolean isNoLongerNeededIncludedChanged = false;
        
        //Check if custom setting 'Time Period' changed or not
        for (Custom_Settings__c cs : newCustomSettings) {
        	
            if (oldMap.get(cs.Id).RUL_Period__c != newMap.get(cs.Id).RUL_Period__c) {
                isRULPeriodChanged = true;
                oldRULPeriod = oldMap.get(cs.Id).RUL_Period__c;
                newRULPeriod = newMap.get(cs.Id).RUL_Period__c;
                newRULActivitiesUpdate = newMap.get(cs.Id).RUL_Activities__c;
            }
            
            if (oldMap.get(cs.Id).RUL_Period_Contact__c != newMap.get(cs.Id).RUL_Period_Contact__c) {
                isRULPeriodChangedContact = true;
                oldRULPeriodContact = oldMap.get(cs.Id).RUL_Period_Contact__c;
                newRULPeriodContact = newMap.get(cs.Id).RUL_Period_Contact__c;
                newRULActivitiesUpdateContact = newMap.get(cs.Id).RUL_Activities_Contact__c;
            }
            
            if (oldMap.get(cs.Id).Consider_No_longer_needed_a_use__c != newMap.get(cs.Id).Consider_No_longer_needed_a_use__c) {
                isNoLongerNeededIncludedChanged = true;
            }
        }
        List<Reference_Basic_Information__c> RBIList = new List<Reference_Basic_Information__c>();
        List<Reference_Basic_Information__c> listRBI = new List<Reference_Basic_Information__c>();
        Date lastActivityDate, lastActivityDateContact;
        
        if (isRULPeriodChanged || isRULPeriodChangedContact) {
        	
            if (newRULPeriod != null) {
                lastActivityDate = Date.Today() - Integer.valueOf(newRULPeriod);
            }
            
            if (newRULPeriodContact != null) {
                lastActivityDateContact = Date.Today() - Integer.valueOf(newRULPeriodContact);
            }
            
            if (isRULPeriodChanged && isRULPeriodChangedContact && ConstantsController.updateExistingAccounts && ConstantsController.updateExistingContacts) {
                RBIList = [SELECT RUL_Period__c, Account__c, Contact__c, RUL_Activities_will_do__c, Default_Period_Completed_Uses__c 
                				FROM Reference_Basic_Information__c WHERE Account__c != null AND (RUL_Period__c = : oldRULPeriod 
                				OR RUL_Period__c = : oldRULPeriodContact) AND Is_Referenceable__c = true 
                				AND (Referenceability_Status__c = : ConstantsController.ACTIVE 
                				OR Referenceability_Status__c = : ConstantsController.CAUTION) LIMIT: limits.getLimitQueryRows()];
            } else if (isRULPeriodChanged && ConstantsController.updateExistingAccounts) {
                RBIList = [SELECT RUL_Period__c, Account__c, Contact__c, RUL_Activities_will_do__c, Default_Period_Completed_Uses__c 
                				FROM Reference_Basic_Information__c WHERE Account__c != null AND Contact__c = null AND RUL_Period__c = : oldRULPeriod 
                				AND Is_Referenceable__c = true AND (Referenceability_Status__c = : ConstantsController.ACTIVE 
                				OR Referenceability_Status__c = : ConstantsController.CAUTION) LIMIT: limits.getLimitQueryRows()];
            } else if (isRULPeriodChangedContact && ConstantsController.updateExistingContacts) {
                RBIList = [SELECT RUL_Period__c, Account__c, Contact__c, RUL_Activities_will_do__c, Default_Period_Completed_Uses__c 
                				FROM Reference_Basic_Information__c WHERE Account__c != null AND Contact__c != null 
                				AND RUL_Period__c = : oldRULPeriodContact AND Is_Referenceable__c = true 
                				AND (Referenceability_Status__c = : ConstantsController.ACTIVE 
                				OR Referenceability_Status__c = : ConstantsController.CAUTION) LIMIT: limits.getLimitQueryRows()];
            }
            
            if (RBIList.size() < 9500 && RBIList.size() > 0) {
                Set<String> contactIds = new Set<String>();
                Set<String> accountIds = new Set<String>();
                
                for (Reference_Basic_Information__c rbiId : RBIList) {
                	
                    if (rbiId.Account__c != null && rbiId.Contact__c != null) {
                        contactIds.add(rbiId.Contact__c);
                    }
                    
                    if (rbiId.Account__c != null && rbiId.Contact__c == null) {
                        accountIds.add(rbiId.Account__c);
                    }
                }

                Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, (SELECT Id, Activity_Date__c 
            														FROM Reference_Request_Accounts__r WHERE CreatedDate > : lastActivityDate) 
            														FROM Account WHERE Id IN: accountIds LIMIT: limits.getLimitQueryRows()]);
                Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, (SELECT Id, Activity_Date__c FROM Reference_Request_Account_Contacts__r 
                													WHERE CreatedDate > : lastActivityDateContact) FROM Contact 
                													WHERE Id IN: contactIds LIMIT: limits.getLimitQueryRows()]);
                Map<String, List<Reference_Request_Account__c>> rrAccMapForDefaultCompleteUse = new Map<String, List<Reference_Request_Account__c>>();
                Map<String, List<Reference_Request_Account_Contact__c>> rrAccConMapForDefaultCompleteUse = 
                									new Map<String, List<Reference_Request_Account_Contact__c>>();
                
                for (Id accId : accountMap.keySet()) {
                	
                    for (Reference_Request_Account__c tempObj : accountMap.get(accId).Reference_Request_Accounts__r) {
                    	
                        if (tempObj.Activity_Date__c != null && (tempObj.Activity_Date__c).daysBetween(date.today()) <= newRULPeriod) {
                        	
                            if (!rrAccMapForDefaultCompleteUse.containsKey(accId)) {
                                rrAccMapForDefaultCompleteUse.put(accId, new List<Reference_Request_Account__c>());
                            }
                            rrAccMapForDefaultCompleteUse.get(accId).add(tempObj);
                        }
                    }
                }
                
                for (Id conId : contactMap.keySet()) {
                	
                    for (Reference_Request_Account_Contact__c tempObj : contactMap.get(conId).Reference_Request_Account_Contacts__r) {
                    	
                        if (tempObj.Activity_Date__c != null && (tempObj.Activity_Date__c).daysBetween(date.today()) <= newRULPeriodContact) {
                        	
                            if (!rrAccConMapForDefaultCompleteUse.containsKey(conId)) {
                                rrAccConMapForDefaultCompleteUse.put(conId, new List<Reference_Request_Account_Contact__c>());
                            }
                            rrAccConMapForDefaultCompleteUse.get(conId).add(tempObj);
                        }
                    }
                }
                
                for (Reference_Basic_Information__c rbiId : RBIList) {
                	
                    if (rbiId.Account__c != null && rbiId.Contact__c != null && newRULPeriodContact != null) {
                        rbiId.RUL_Period__c = newRULPeriodContact;
                        rbiId.RUL_Activities_will_do__c = newRULActivitiesUpdateContact;
                        
                        if (rrAccConMapForDefaultCompleteUse.containsKey(rbiId.Contact__c)) {
                            rbiId.Default_Period_Completed_Uses__c = rrAccConMapForDefaultCompleteUse.get(rbiId.Contact__c).size();
                        } else {
                            rbiId.Default_Period_Completed_Uses__c = 0;
                        }
                        listRBI.add(rbiId);
                    } else if (rbiId.Account__c != null && rbiId.Contact__c == null && newRULPeriod != null) {
                        rbiId.RUL_Period__c = newRULPeriod;
                        rbiId.RUL_Activities_will_do__c = newRULActivitiesUpdate;
                        
                        if (rrAccMapForDefaultCompleteUse.containsKey(rbiId.Account__c)) {
                            rbiId.Default_Period_Completed_Uses__c = rrAccMapForDefaultCompleteUse.get(rbiId.Account__c).size();
                        } else {
                            rbiId.Default_Period_Completed_Uses__c = 0;
                        }
                        listRBI.add(rbiId);
                    }
                }
                if (listRBI.size() > 0) {
                    update listRBI;
                }
            } else if (RBIList.size() > 0) {
                Batch_AccConUpdateOnCustomSetting newBatch = new Batch_AccConUpdateOnCustomSetting(oldRULPeriod, newRULPeriod, 
                													oldRULPeriodContact, newRULPeriodContact, isRULPeriodChanged, 
                													isRULPeriodChangedContact, newRULActivitiesUpdate, newRULActivitiesUpdateContact);
                DataBase.executeBatch(newBatch);
            }

        } 
        
        if (isNoLongerNeededIncludedChanged) {
            Batch_ChangeAllNoLongerNeededAR newBatchAR = new Batch_ChangeAllNoLongerNeededAR(newCustomSettings[0].Consider_No_longer_needed_a_use__c);
            DataBase.executeBatch(newBatchAR);
            Batch_ChangeAllNoLongerNeededCR newBatchCR = new Batch_ChangeAllNoLongerNeededCR(newCustomSettings[0].Consider_No_longer_needed_a_use__c);
            DataBase.executeBatch(newBatchCR);
        }
    }
	/**
     * Method to validate workspace setting
     */
    static void validateWorkspaceSetting(List<Custom_Settings__c> customSettings, Map<Id, Custom_Settings__c> newMap, Map<Id, Custom_Settings__c> oldMap) {
    	
        for (Custom_Settings__c cs : customSettings) {
        	
            if ((newMap.get(cs.Id).Critical_Deadline_window__c == null && oldMap.get(cs.Id).Critical_Deadline_window__c != null) 
            		|| (newMap.get(cs.Id).Caution_deadline_window__c == null && oldMap.get(cs.Id).Caution_deadline_window__c != null) 
            		|| (newMap.get(cs.Id).Nomination_disposition_window__c == null && oldMap.get(cs.Id).Nomination_disposition_window__c != null)) {
                cs.addError(System.Label.NULL_CHECK_DEADLINE_WINDOW);
                return;
            }
        }
    }
	/**
     * Method to update Minimum deadline on Referenceablities
     */
    static void updateReferenceablities(List<Custom_Settings__c> newCustomSettings, Map<Id, Custom_Settings__c> oldMap, Map<Id, Custom_Settings__c> newMap) {
        Decimal minLeadTime = 0;
        
        for (Custom_Settings__c cs: newCustomSettings) {
        	
            if (oldMap.get(cs.Id).Minimum_Deadline__c != newMap.get(cs.Id).Minimum_Deadline__c 
            			&& oldMap.get(cs.Id).Minimum_Deadline__c < newMap.get(cs.Id).Minimum_Deadline__c) {
                minLeadTime = cs.Minimum_Deadline__c;
			}
        }
        
        if (minLeadTime > 0) {
            List<Referenceability_Type__c> refType = new List<Referenceability_Type__c>();
            
            for (Referenceability_Type__c refTy : [SELECT Id, min_lead_time_per_request_type__c FROM Referenceability_Type__c 
            							WHERE min_lead_time_per_request_type__c <= : minLeadTime LIMIT: limits.getLimitQueryRows()]) {
                refTy.min_lead_time_per_request_type__c = minLeadTime + 1;
                refType.add(refTy);
            }
            update refType;
        }
    }
    
    /**
     * Method to Schedular Send Reminder For Automatic
     */
    static void schedularSendReminderForAutomatic(List<Custom_Settings__c> newCustomSettings, Map<Id, Custom_Settings__c> oldMap, 
    																							Map<Id, Custom_Settings__c> newMap) {
        List<CronTrigger> listCronTrigger = [SELECT Id FROM CronTrigger WHERE id = : newCustomSettings.get(0).Send_reminder_for_automatic_cti__c 
        									LIMIT: limits.getLimitQueryRows()];
        
        for (Custom_Settings__c cs : newCustomSettings) {
        	
            if (oldMap.get(cs.Id).Send_reminder_for_automatic__c != newMap.get(cs.Id).Send_reminder_for_automatic__c 
            		|| oldMap.get(cs.Id).Manual_Automatic_Launch__c != newMap.get(cs.Id).Manual_Automatic_Launch__c 
            		|| oldMap.get(cs.Id).Launch_Frequency__c != newMap.get(cs.Id).Launch_Frequency__c 
            		|| oldMap.get(cs.Id).Next_Refresh_launch_Date__c != newMap.get(cs.Id).Next_Refresh_launch_Date__c) {
            	
            	if (listCronTrigger.size() > 0) {
                	System.abortJob(cs.Send_reminder_for_automatic_cti__c);	
                	cs.Send_reminder_for_automatic_cti__c = null;
            	}
                
                if (cs.Manual_Automatic_Launch__c == 'Automatic' && cs.Send_reminder_for_automatic__c != null) {
	                Schedular_SendReminderForAutomatic tempSchedule = new Schedular_SendReminderForAutomatic();
	                Datetime dt = (cs.Next_Refresh_launch_Date__c).addDays(-Integer.valueOf(cs.Send_reminder_for_automatic__c));
	                String timeForScheduler = '0 30 0 ' + dt.day() + ' ' + returnMonth(dt.month(), cs.Launch_Frequency__c) + ' ?';
	                Id scheduleId = system.schedule('RefEdge_ProfileUpdateReminder', timeForScheduler, tempSchedule);
	                cs.Send_reminder_for_automatic_cti__c = scheduleId;
                }
            }
        }
    }
    
    /**
     * Method to calculate months 
     */
    static string returnMonth(Integer month, String launchFreq) {
        string scheduledMonth;
        
        if (launchFreq == 'Monthly') {
            scheduledMonth = '*';
        } else if (launchFreq == 'Quarterly') {
            scheduledMonth = addMonths(month, 3);
        } else if (launchFreq == 'Semi-Annually') {
            scheduledMonth = addMonths(month, 6);
        } else if (launchFreq == 'Annually') {
            scheduledMonth = ' ' + month;
        }
        return scheduledMonth;
    }

    /**
     * Method to addMonths
     */
    static string addMonths(Integer month, Integer monthVal) {
        string finalExp = '';
        Integer tempMonth = month;
        
        for (Integer i = 0; i < 12 / monthVal; i++) {
            finalExp += (finalExp == '' ? '' + tempMonth : ',' + tempMonth);
            tempMonth = (tempMonth + monthVal > 12 ? tempMonth + monthVal - 12 : tempMonth + monthVal);
        }
        return finalExp;
    }
}