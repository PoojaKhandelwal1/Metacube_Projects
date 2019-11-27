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
 * VF Page: AdvRoutingSettingsSLDS
 * Description: Class used to handle Advance Routing fields.  
 * Created by: Rekha Jangir @25 August 2017
 */
public with sharing class AdvRoutingExtensionsSLDS extends RefEdgeEditionFeatures {
    
    /**
     * Constructor
     */
    public AdvRoutingExtensionsSLDS(ApexPages.StandardController controller) {}
    
    /**
     * Method to check Permissions
     */
    private static Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	
    	fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c',
    										new Set<String>{
                                                UtilityController.appNamespace() + 'Adv_Rt_Acct_Team_Roles_to_Include__c',
                                                UtilityController.appNamespace() + 'Adv_Rt_Acct_Team_Role_Picklist__c',
    											UtilityController.appNamespace() + 'Adv_Request_Routing__c',
    											UtilityController.appNamespace() + 'Adv_Routing_Default__c',
    											UtilityController.appNamespace() + 'Adv_Routing_Group_Lbl__c',
    											UtilityController.appNamespace() + 'Adv_Routing_Group_Mandatory__c',
	        									UtilityController.appNamespace() + 'Adv_Rt_Acct_Team_Object__c',
	        									UtilityController.appNamespace() + 'Adv_Rt_Acct_Team_Routeby__c',
                                                UtilityController.appNamespace() + 'Adv_Rt_Acct_Team_Contact__c',
                                                UtilityController.appNamespace() + 'Routing_Groups_to_Exclude__c',
	        									UtilityController.appNamespace() + 'Adv_Rt_Acct_Team_User__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
    
    /**
     * Remote Action Method to get Objects names
     */
    @RemoteAction
    public static List<OptionWrapper> getObjects() {
        List<OptionWrapper> options = new List<OptionWrapper>();
        Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
 
		List<Schema.ChildRelationship> C = R.getChildRelationships();
        
        for (Schema.ChildRelationship cr : C) { 
            options.add(new OptionWrapper(cr.getChildSobject().getDescribe().getName(), cr.getChildSobject().getDescribe().getLabel()));
        }
        return options;
    }
    /**
     * Remote Action Method to get fields for an object
     */
    @RemoteAction
    public static List<String> getFieldValues() {
    	List<String> options = new List<String>();
        Schema.DescribeFieldResult dfr = Schema.sObjectType.Custom_Settings__c.fields.getMap().get(UtilityController.appNamespace() 
                                                                                                               + 'Adv_Routing_Default__c').getDescribe();
        List<Schema.PicklistEntry> ple = dfr.getPicklistValues();
        
        for (Schema.PicklistEntry f : ple) {
            options.add(String.valueOf(f.value));
        }
        return options;
    }
    /**
     * Remote Action Method to get User fields for an object
     */
    @RemoteAction
    public static String getReferenceFields(String selectedObject, String selectedContactField) {
    	List<OptionWrapper> returnFields = new List<OptionWrapper>();
    	
        if (selectedContactField != null && selectedContactField != '') { 
            selectedObject = 'Contact';
        }
        if (selectedObject != null && selectedObject != '') {
            
            Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(selectedObject);
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            
            for (String field : fieldMap.keySet()) {
                Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
                
                if (string.valueOf(dfr.getType()) =='REFERENCE' && string.valueOf(dfr.getReferenceTo()) == '(User)') {
					returnFields.add(new OptionWrapper(dfr.getName(), dfr.getLabel()));
				} 
            }
        }
        return JSON.serialize(returnFields);
    }

    /**
     * Remote Action Method to get Contact fields for an object
     */
    @RemoteAction
    public static String getReferenceFieldsContacts(String selectedObject) {
    	List<OptionWrapper> returnFields = new List<OptionWrapper>();
    	
        if (selectedObject != null && selectedObject != '') {
            Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(selectedObject);
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            
            for (String field : fieldMap.keySet()) {
                Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
                
                if (string.valueOf(dfr.getType()) =='REFERENCE' && string.valueOf(dfr.getReferenceTo()) == '(Contact)') {
					returnFields.add(new OptionWrapper(dfr.getName(), dfr.getLabel()));
				} 
            }
        }
        return JSON.serialize(returnFields);
    }

    /**
     * Remote Action Method to get Role Picklist fields for an object
     */
    @RemoteAction
    public static String getPicklistFieldsRole(String selectedObject) {
    	List<OptionWrapper> returnFields = new List<OptionWrapper>();
    	
        if (selectedObject != null && selectedObject != '') {
            Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(selectedObject);
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            
            for (String field : fieldMap.keySet()) {
                Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
                
                if (string.valueOf(dfr.getType()) =='PICKLIST' || string.valueOf(dfr.getType()) =='MULTIPICKLIST') {
					returnFields.add(new OptionWrapper(dfr.getName(), dfr.getLabel()));
				} 
            }
        }
        return JSON.serialize(returnFields);
    }

    /**
     * Remote Action Method to get Role Picklist fields for an object
     */
    @RemoteAction
    public static String getRoleEntries(String selectedRole, String selectedObject, String selectedValues) {
    	List<OptionWrapper> returnFields = new List<OptionWrapper>();
    
        if (selectedObject != null && selectedObject != '' && selectedRole != null && selectedRole != '') {
            Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(selectedObject);
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            Schema.DescribeFieldResult dfr = fieldMap.get(selectedRole).getDescribe();
            List<Schema.PicklistEntry> entries = dfr.getPicklistValues();
            Set<String> rolesSelectedSaved = new Set<String>(selectedValues.split(','));
            
            for( Schema.PicklistEntry pickListVal : entries) {
                OptionWrapper entry = new OptionWrapper(pickListVal.getValue(), pickListVal.getLabel());
                
                if (rolesSelectedSaved.contains(pickListVal.getValue())) {
                    entry.isSelected = true;
                } 
                returnFields.add(entry);
            } 
        }
        return JSON.serialize(returnFields);
    }
    
    /**
     * Remote Action Method to get fields for an object
     */
    @RemoteAction
    public static String getPicklistFields(String selectedObject, String selectedContactField) {
    	List<OptionWrapper> returnFields = new List<OptionWrapper>();
    	
        if (selectedContactField != null && selectedContactField != '') { 
            selectedObject = 'Contact';
        }
        
        if (selectedObject != null && selectedObject != '') {
            Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(selectedObject);
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            
            for (String field : fieldMap.keySet()) {
                Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
                
                if (string.valueOf(dfr.getType()) =='PICKLIST' || string.valueOf(dfr.getType()) =='MULTIPICKLIST') {
					returnFields.add(new OptionWrapper(dfr.getName(), dfr.getLabel()));
				} 
            }
        }
        return JSON.serialize(returnFields);
    }
    
    @RemoteAction
    public static String saveCSRUL(String cswJSON) { 
    	
    	try {
    		
    		if (checkPermissions()) {
	    		CustomSettingWrapper csw = (CustomSettingWrapper)JSON.deserialize(cswJSON, CustomSettingWrapper.class);
		    	Custom_Settings__c cs = UtilityController.getCustomSettings();
		    	cs.Adv_Request_Routing__c = csw.adReqRouting;
		    	cs.Adv_Routing_Default__c = csw.adRoutingDefault;
		    	cs.Adv_Routing_Group_Lbl__c = csw.adRoutingGroup;
		    	cs.Adv_Routing_Group_Mandatory__c = csw.adRoutingGroupMandatory;
		    	cs.Adv_Rt_Acct_Team_Object__c = csw.teamObject;
		    	cs.Adv_Rt_Acct_Team_Routeby__c = csw.teamRouteBy;
		    	cs.Adv_Rt_Acct_Team_User__c = csw.teamUser;
                cs.Adv_Rt_Acct_Team_Contact__c = csw.teamContact;
                cs.Adv_Rt_Acct_Team_Role_Picklist__c = csw.teamRole; 
                cs.Adv_Rt_Acct_Team_Roles_to_Include__c = csw.teamRolesToInclude;
                cs.Routing_Groups_to_Exclude__c = csw.groupsToExclude;
		    	update cs;
    		} else {
        		return CRUDAndFLSCheckController.getErrorMsg();
        	}
    	} catch(Exception e) {
    		return CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
    	}
        return '';
    }
    
    /**
     * Method to get Custom Setting
     * Created By: Rekha Jangir @25 August 2017
     */
    @RemoteAction
    public static String getCustomSetting() { 
        CustomSettingWrapper csw = new CustomSettingWrapper();
    	Custom_Settings__c cs = UtilityController.getCustomSettings();
    	csw.adReqRouting = cs.Adv_Request_Routing__c;
    	csw.adRoutingDefault = cs.Adv_Routing_Default__c;
    	csw.adRoutingGroup = cs.Adv_Routing_Group_Lbl__c;
    	csw.adRoutingGroupMandatory = cs.Adv_Routing_Group_Mandatory__c;
    	csw.teamObject = cs.Adv_Rt_Acct_Team_Object__c;
    	csw.teamRouteBy = cs.Adv_Rt_Acct_Team_Routeby__c;
    	csw.teamUser = cs.Adv_Rt_Acct_Team_User__c;
        csw.teamContact = cs.Adv_Rt_Acct_Team_Contact__c == null ? '' : cs.Adv_Rt_Acct_Team_Contact__c;
        csw.teamRole = cs.Adv_Rt_Acct_Team_Role_Picklist__c == null ? '' : cs.Adv_Rt_Acct_Team_Role_Picklist__c;
        csw.teamRolesToInclude = cs.Adv_Rt_Acct_Team_Roles_to_Include__c == null ? '' : cs.Adv_Rt_Acct_Team_Roles_to_Include__c;
        csw.groupsToExclude = cs.Routing_Groups_to_Exclude__c == null ? '' : cs.Routing_Groups_to_Exclude__c;
        return JSON.serialize(csw);
    }
    
    /**
     * Wrapper class for Custom Setting
     * Created By: Rekha Jangir @25 August 2017
     */
    public class CustomSettingWrapper {
    	public Boolean adReqRouting { get; set; }
    	public String adRoutingDefault { get; set; }
    	public String adRoutingGroup { get; set; }
    	public Boolean adRoutingGroupMandatory { get; set; }
        public String teamObject { get; set; }
        public String teamRouteBy { get; set; }
        public String teamUser { get; set; }
        public String teamContact { get; set; }
        public String teamRole { get; set; }
        public String teamRolesToInclude { get; set; }
        public String groupsToExclude { get; set; }
    }
    
    /**
     * Wrapper class
     */
 	public class OptionWrapper {
 		public String name { get; set; }
 		public String id { get; set; }
        public Boolean isSelected { get; set; }
 		
 	    public OptionWrapper(String id, String name) {
            this.name = name;
            this.id = id;
            this.isSelected = false;
	    }
 	}
}