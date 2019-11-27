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
public with sharing class CheckEditionInTriggerHandler extends RefEdgeEditionFeatures {
    /**
     * Method to validate Object in Basic edition 
     */
    public static void validateObjectAccess(List<sObject> sobjects) {
    	
        if (RefEdgeEditionFeatures.isBasic && !Test.isRunningTest()) {
            
            for (Sobject s : sobjects) {
                
                if (s.getsObjectType() == Reference_Type_Mapping__c.sObjectType) {
                    
                    if (s.get('Reference_Content_Type__c') == null
                    			&& (s.get('Referenceability_Type__c') != null || s.get('Label__c') != null)) {
                        s.addError(System.Label.Insufficient_Privileges);
                        return;
                    }
                } else {
                    sobjects[0].addError(System.Label.Insufficient_Privileges);
                    return;
                }
            }
        }
    }
    
    /**
     * Method to validate Object in Pro edition 
     */
    public static void validateObjectAccessOnPRO(List < Sobject > sobjects) {
        
        if ((RefEdgeEditionFeatures.isBasic
        				|| RefEdgeEditionFeatures.isPro
        				|| RefEdgeEditionFeatures.isEnterprise)
    				&& !Test.isRunningTest() 
           			&& !ConstantsController.isCallToInfluitiveAPI) {
            
            for (Sobject s : sobjects) {
                sobjects[0].addError(System.Label.Insufficient_Privileges);
                return;
            }
        }
    }
    /**
     * Method to validate access on fields in Basic edition 
     */
    public static void validateFieldAccess(List < Sobject > sobjects, map < Id, Sobject > sobjectsMap) {
        //deprecated
        if ((RefEdgeEditionFeatures.isPro || RefEdgeEditionFeatures.isEnterprise) && !Test.isRunningTest()) {
            
            for (Sobject s: sobjects) {
                
                if (s.getsObjectType() == Custom_Settings__c.sObjectType) {
                    
                    if (s.get('Community_Home_Text__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Community_Home_Text__c') ||
                    				s.get('Community_Ref_Activities_Message__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Community_Ref_Activities_Message__c')) {
                        s.addError(System.Label.Insufficient_Privileges);
                        return;
                    }
                }
            }
        }
        
        if (RefEdgeEditionFeatures.isBasic && !Test.isRunningTest()) {
            
            for (Sobject s : sobjects) {
                
                if (s.getsObjectType() == Reference_Basic_Information__c.sObjectType) {
                    
                    if (sobjectsMap != null && sobjectsMap.size() > 0
                    			&& sobjectsMap.containsKey(String.valueOf(s.get('Id')))) {
                        
                        if (s.get('Managed_Reference_Account__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Managed_Reference_Account__c')) {
                            s.addError(System.Label.Insufficient_Privileges);
                            return;
                        }
                    } else {
                        
                        if (s.get('Managed_Reference_Account__c') == true) {
                            s.addError(System.Label.Insufficient_Privileges);
                            return;
                        }
                    }
                } else if (s.getsObjectType() == Reference_Request_Account__c.sObjectType) {
                    
                    if (sobjectsMap != null && sobjectsMap.size() > 0 && sobjectsMap.containsKey(String.valueOf(s.get('Id')))) {
                        
                        if (s.get('Managed_Request__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Managed_Request__c')
                        			|| s.get('Reference_Request_Additional_Info__c') != null) {
                            s.addError(System.Label.Insufficient_Privileges);
                            return;
                        }
                    } else {
                        
                        if (s.get('Managed_Request__c') == true || s.get('Reference_Request_Additional_Info__c') != null) {
                            s.addError(System.Label.Insufficient_Privileges);
                            return;
                        }
                    }
                } else if (s.getsObjectType() == Reference_Note__c.sObjectType) {
                    
                    if (s.get('Unspecified_Request__c') != null) {
                        s.addError(System.Label.Insufficient_Privileges);
                        return;
                    }
                } else if (s.getsObjectType() == Custom_Settings__c.sObjectType) {
                    
                    if (s.get('Caution_deadline_window__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Caution_deadline_window__c')
		                        || s.get('Critical_Deadline_window__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Critical_Deadline_window__c')
		                        || s.get('Nomination_disposition_window__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Nomination_disposition_window__c')
		                        || s.get('General_Notes__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('General_Notes__c')
		                        || s.get('Mixed_manage_request_settings__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Mixed_manage_request_settings__c')
		                        || s.get('Reward_Settings__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Reward_Settings__c')
		                        || s.get('Expire_Rewards__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Expire_Rewards__c')
		                        || s.get('Automatically_Assign_Rewards__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Automatically_Assign_Rewards__c')
		                        || s.get('Expiration_Timeframe__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Expiration_Timeframe__c')
		                        || s.get('Community_Home_Text__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Community_Home_Text__c')
		                        || s.get('Community_Ref_Activities_Message__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Community_Ref_Activities_Message__c')
		                        || s.get('Default_Reference_Accounts_Managed__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Default_Reference_Accounts_Managed__c')
		                        || s.get('Remove_Points_if_Use_will_not_occur__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Remove_Points_if_Use_will_not_occur__c')
		                        || s.get('Managed_Request_Opportunity_Threshold__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Managed_Request_Opportunity_Threshold__c')
		                        || s.get('Adv_Request_Routing__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Adv_Request_Routing__c')
		                        || s.get('Expiration_Days__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Expiration_Days__c')) {
                        		//s.get('Private_Chatter__c') != sobjectsMap.get(String.valueOf(s.get('Id'))).get('Private_Chatter__c')) {
                        
                        s.addError(System.Label.Insufficient_Privileges);
                        return;
                    }
                } else if (s.getsObjectType() == Reference_Content_Type__c.sObjectType) {
                    
                    if (s.get('Recorded_Reference_Type__c') == true) {
                        s.addError(System.Label.Insufficient_Privileges);
                        return;
                    }
                }
            }
        }
    }
}