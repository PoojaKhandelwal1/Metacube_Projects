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
 * Page : AdvRoutingSettings (Advance routing section in custom settings)
 * Description : Class used handle Advance Routing fields.  
 * Last Modified By: Rajesh @Feb 8 2017
 */
public with sharing class AdvRoutingExtensions extends RefEdgeEditionFeatures {
	/**
     * Properties and variables
     */
    public List<SelectOption> AccountTeam { get; set; }
    public List<SelectOption> RoutByList { get; set; }
    public List<SelectOption> RolesFieldList { get; set; }
    public List<SelectOption> UserFieldList { get; set; }
    public List<SelectOption> ContactFieldList { get; set; }
    public String selectedAccountTeam { get; set; }
    public String selectedRoutBy { get; set; }
    public String selectedRoleField { get; set; }
    public String selectedUserField { get; set; }
    public String selectedContactField { get; set; }
    public String rolesIncluded { get; set; }
    public Boolean isEdit { get; set; }
    public Custom_Settings__c cs { get; set; }
    public String AccountTeamName { get; set; }
    public String PickListRouteBy { get; set; }
    public String PickListRoles { get; set; }
  	public String UserFieldName { get; set; }
    public String ContactFieldName { get; set; }
    public String RolesIncludedNames { get; set; }
    public String currentAllRoleValues { get; set; }
    public String currentSelectedRoleValues { get; set; }
    public List<SelectOption> allRoleValues { get; set; }
    public List<SelectOption> selectedRoleValues { get; set; }
    private Map<String, String> mapAccountTeam;
    public Map<String, String> mapRoutByList;
    public Map<String, String> mapRoleList;
    public Map<String, String> mapUserField;
    public Map<String, String> mapContactField;
    public Map<String, String> maproleValuesList;
    public boolean isSLDS { get; set; }

    public String excludedGroups { get; set; }
    public String excludedGroupNames { get; set; }
    public String currentAllGroups { get; set; }
    public String currentSelectedGroups { get; set; }
    public List<SelectOption> allGroups { get; set; }
    public List<SelectOption> selectedGroups { get; set; }
    public Map<String, String> mapGroups;
    
    /**
     * Constructor
     */
    public AdvRoutingExtensions(ApexPages.StandardController controller) {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
	        cs = UtilityController.getCustomSettings();
	        //Check user premission         
	        checkPermissions();
	        isEdit = false;
	        AccountTeam = new List<SelectOption>();
	        AccountTeam.add(new SelectOption('', '--None--'));
	        RoutByList = new List<SelectOption>();
	        RoutByList.add(new SelectOption('', '--None--'));
	        UserFieldList = new List<SelectOption>();
	        UserFieldList.add(new SelectOption('', '--None--'));
            RolesFieldList = new List<SelectOption>();
	        RolesFieldList.add(new SelectOption('', '--None--'));
            ContactFieldList = new List<SelectOption>();
	        ContactFieldList.add(new SelectOption('', '--None--'));
            selectedRoleValues = new List<SelectOption>();
            allRoleValues = new List<SelectOption>();
	        mapAccountTeam = new Map<String, String>();
	        mapRoutByList = new Map<String, String>();
            mapRoleList = new Map<String, String>();
	        mapUserField = new Map<String, String>();
            mapContactField = new Map<String, String>();
            maproleValuesList = new Map<String, String>();
            rolesIncluded = '';
            excludedGroups = '';
            excludedGroupNames = '';
            currentAllGroups = '';
            currentSelectedGroups = '';
            allGroups = new List<SelectOption>();
            selectedGroups = new List<SelectOption>();
            mapGroups = new Map<String, String>();
	        
	        Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
	 
			List<Schema.ChildRelationship> C = R.getChildRelationships();
	        
	        for (Schema.ChildRelationship cr : C) {
	    		AccountTeam.add(new SelectOption(cr.getChildSobject().getDescribe().getName(), cr.getChildSobject().getDescribe().getLabel()));
	    		mapAccountTeam.put(cr.getChildSobject().getDescribe().getName(), cr.getChildSobject().getDescribe().getLabel());
	        }
	        selectedAccountTeam = (cs.Adv_Rt_Acct_Team_Object__c != null ? cs.Adv_Rt_Acct_Team_Object__c : '');
	        populateFieldList();
            selectedContactField = (cs.Adv_Rt_Acct_Team_Contact__c != null ? cs.Adv_Rt_Acct_Team_Contact__c : '');   
            populateContactUserFieldList();
	        selectedRoutBy = (cs.Adv_Rt_Acct_Team_Routeby__c != null ? cs.Adv_Rt_Acct_Team_Routeby__c : '');
            excludedGroups = cs.Routing_Groups_to_Exclude__c != null ? cs.Routing_Groups_to_Exclude__c : '';
            excludedGroupNames = '';
            populateGroups();
	        selectedUserField = (cs.Adv_Rt_Acct_Team_User__c != null ? cs.Adv_Rt_Acct_Team_User__c : '');  
	        rolesIncluded = (cs.Adv_Rt_Acct_Team_Roles_to_Include__c != null ? cs.Adv_Rt_Acct_Team_Roles_to_Include__c : '');  
            selectedRoleField = (cs.Adv_Rt_Acct_Team_Role_Picklist__c != null ? cs.Adv_Rt_Acct_Team_Role_Picklist__c : '');
            populateRolesToInclude();

	        AccountTeamName = (selectedAccountTeam != '' ? mapAccountTeam.get(selectedAccountTeam) : '');
	      	PickListRouteBy = (selectedRoutBy != '' ? mapRoutByList.get(selectedRoutBy) : '');
            PickListRoles = (selectedRoleField != '' ? mapRoleList.get(selectedRoleField) : '');
            ContactFieldName = (selectedContactField != '' ? mapContactField.get(selectedContactField) : '');
	      	UserFieldName = (selectedUserField !='' ? mapUserField.get(selectedUserField) : '');
            RolesIncludedNames = '';
            
            if (rolesIncluded != null && rolesIncluded != '') {

                for (String values: rolesIncluded.split(',')) {
                    RolesIncludedNames += maproleValuesList.get(values) + ',';
                }
                RolesIncludedNames = RolesIncludedNames.removeEndIgnoreCase(',');
            }
            
            if (excludedGroups != null && excludedGroups != '') {

                for (String values : excludedGroups.split(',')) {
                    excludedGroupNames += mapGroups.get(values) + ',';
                }
                excludedGroupNames = excludedGroupNames.removeEndIgnoreCase(',');
            }
        }
    }
    
    /**
     * Method used to load list for fields
     */
    public void populateFieldList() {
        RoutByList = new List<SelectOption>();
        RoutByList.add(new SelectOption('', '--None--'));
        ContactFieldList = new List<SelectOption>();
        ContactFieldList.add(new SelectOption('', '--None--'));
        UserFieldList = new List<SelectOption>();
        UserFieldList.add(new SelectOption('', '--None--'));
        RolesFieldList = new List<SelectOption>();
        RolesFieldList.add(new SelectOption('', '--None--'));
        selectedUserField = '';
        selectedContactField = '';
        selectedRoutBy = '';
        selectedRoleField = '';
        rolesIncluded = '';
        excludedGroups = '';
        
        if (selectedAccountTeam != null && selectedAccountTeam != '') { 
            Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(selectedAccountTeam);
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
           
            for (String field : fieldMap.keySet()) {
                Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe(); 
				
                if (string.valueOf(dfr.getType()) == 'REFERENCE') {
                    
                    if (string.valueOf(dfr.getReferenceTo()) == '(Contact)') {
                        ContactFieldList.add(new SelectOption(dfr.getName(), dfr.getLabel()));
                        mapContactField.put(dfr.getName(), dfr.getLabel());
                    }
                } 

                if (string.valueOf(dfr.getType()) =='PICKLIST' || string.valueOf(dfr.getType()) =='MULTIPICKLIST') {
                    RolesFieldList.add(new SelectOption(dfr.getName(), dfr.getLabel()));
                    mapRoleList.put(dfr.getName(), dfr.getLabel());
                }       	  
            }  
            populateRolesToInclude();
            populateGroups();
            populateContactUserFieldList();
        }
    }


    /**
     * Method used to load list for fields
     */
    public void populateContactUserFieldList() {
        if (selectedAccountTeam != null && selectedAccountTeam != '') { 
        
            UserFieldList = new List<SelectOption>();
            UserFieldList.add(new SelectOption('', '--None--'));
            selectedUserField = '';
            selectedRoutBy = '';
            populateGroups();
            RoutByList = new List<SelectOption>();
            RoutByList.add(new SelectOption('', '--None--'));
            
            String objectToDescribe = selectedContactField != null && selectedContactField != '--None--' && selectedContactField != '' ? 'Contact' : selectedAccountTeam;
            Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(objectToDescribe);
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            
            for (String field : fieldMap.keySet()) {
                Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();

                if (string.valueOf(dfr.getType()) == 'REFERENCE' && string.valueOf(dfr.getReferenceTo()) == '(User)') {
                    UserFieldList.add(new SelectOption(dfr.getName(), dfr.getLabel()));
                    mapUserField.put(dfr.getName(), dfr.getLabel());
                } 

                if (string.valueOf(dfr.getType()) =='PICKLIST' || string.valueOf(dfr.getType()) =='MULTIPICKLIST') {
                    RoutByList.add(new SelectOption(dfr.getName(), dfr.getLabel()));
                    mapRoutByList.put(dfr.getName(), dfr.getLabel());
                }       
            }
        }
    }

    /**
     * Method used to load list for Roles
     */
    public void populateRolesToInclude() {
        selectedRoleValues = new List<SelectOption>();
        allRoleValues = new List<SelectOption>();
        maproleValuesList = new Map<String,String>();

        if (selectedAccountTeam != null && selectedAccountTeam != '' && selectedRoleField != null && selectedRoleField != '') { 
            Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(selectedAccountTeam);
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            Schema.DescribeFieldResult dfr = fieldMap.get(selectedRoleField).getDescribe();
            List<Schema.PicklistEntry> entries = dfr.getPicklistValues();
            Set<String> rolesSelectedSaved = new Set<String>(rolesIncluded.split(','));
            
            for( Schema.PicklistEntry pickListVal : entries) {
                maproleValuesList.put(pickListVal.getValue(),pickListVal.getLabel());
                
                if (rolesSelectedSaved.contains(pickListVal.getValue())) {
                    selectedRoleValues.add(new SelectOption(pickListVal.getValue(),pickListVal.getLabel()));
                } else {
                    allRoleValues.add(new SelectOption(pickListVal.getValue(),pickListVal.getLabel()));
                }
            }  
        }
    }

    public void populateGroups() {
        selectedGroups = new List<SelectOption>();
        allGroups = new List<SelectOption>();
        mapGroups = new Map<String,String>();

        if (selectedAccountTeam != null && selectedAccountTeam != '' && selectedRoutBy != null && selectedRoutBy != '') { 
            Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(selectedContactField == null || selectedContactField == '' ? selectedAccountTeam : 'Contact');
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            Schema.DescribeFieldResult dfr = fieldMap.get(selectedRoutBy).getDescribe();
            List<Schema.PicklistEntry> entries = dfr.getPicklistValues();
            Set<String> savedGroups = new Set<String>(excludedGroups.split(','));
            
            for (Schema.PicklistEntry pickListVal : entries) {
                mapGroups.put(pickListVal.getValue(), pickListVal.getLabel());
                
                if (savedGroups.contains(pickListVal.getValue())) {
                    selectedGroups.add(new SelectOption(pickListVal.getValue(), pickListVal.getLabel()));
                } else {
                    allGroups.add(new SelectOption(pickListVal.getValue(), pickListVal.getLabel()));
                }
            }  
        }
    }
    
    /**
     * Method used to update the object Lists : DMInline
     */
    public void addToList() {
        if (currentAllRoleValues != null && currentAllRoleValues != '') {
            currentAllRoleValues = currentAllRoleValues.replace('[',  '').replace(']',  '');
            List<String> listofGroups = currentAllRoleValues.split(',');   
        
            if (listofGroups.size() > 0 && currentAllRoleValues != '') {
                
                for (Integer i = 0; i < listofGroups.size(); i++) {
                    selectedRoleValues.add(new SelectOption(listofGroups[i].trim(),listofGroups[i].trim()));
                    
                    for (integer j = 0; j < allRoleValues.size(); j++) {
                        
                        if (allRoleValues[j].getValue().trim() == listofGroups[i].trim()) {
                            allRoleValues.remove(j);
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Method used to update the object Lists : DMInline
     */
    public void removeFromList() {
    	
        if (currentSelectedRoleValues != null && currentSelectedRoleValues != '') {
            currentSelectedRoleValues = currentSelectedRoleValues.replace('[',  '').replace(']',  '');
            List<String> listofGroups = currentSelectedRoleValues.split(',');   
        
            if (listofGroups.size() > 0 && currentSelectedRoleValues != '') {
                
                for (Integer i = 0; i < listofGroups.size(); i++) {
                    allRoleValues.add(new SelectOption(listofGroups[i].trim(), listofGroups[i].trim()));
                    
                    for (integer j = 0; j < selectedRoleValues.size(); j++) {
                        
                        if (selectedRoleValues[j].getValue().trim() == listofGroups[i].trim()) {
                            selectedRoleValues.remove(j);
                        }
                    }
                }
            }
        }
    }
    
    public void addGroup() {
        
        if (currentAllGroups != null && currentAllGroups != '') {
            currentAllGroups = currentAllGroups.replace('[',  '').replace(']',  '');
            List<String> listofGroups = currentAllGroups.split(',');   
        
            if (listofGroups.size() > 0 && currentAllGroups != '') {
                
                for (Integer i = 0; i < listofGroups.size(); i++) {
                    selectedGroups.add(new SelectOption(listofGroups[i].trim(), listofGroups[i].trim()));
                    
                    for (integer j = 0; j < allGroups.size(); j++) {
                        
                        if (allGroups[j].getValue().trim() == listofGroups[i].trim()) {
                            allGroups.remove(j);
                        }
                    }
                }
            }
        }
    }
    
    public void removeGroup() {
    	
        if (currentSelectedGroups != null && currentSelectedGroups != '') {
            currentSelectedGroups = currentSelectedGroups.replace('[',  '').replace(']',  '');
            List<String> listofGroups = currentSelectedGroups.split(',');   
        
            if (listofGroups.size() > 0 && currentSelectedGroups != '') {
                
                for (Integer i = 0; i < listofGroups.size(); i++) {
                    allGroups.add(new SelectOption(listofGroups[i].trim(), listofGroups[i].trim()));
                    
                    for (integer j = 0; j < selectedGroups.size(); j++) {
                        
                        if (selectedGroups[j].getValue().trim() == listofGroups[i].trim()) {
                            selectedGroups.remove(j);
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Method used to edit fields on the form.
     */
    public PageReference editForm() {
        isEdit = true; 
        cs.Adv_Routing_Default__c = (cs.Adv_Routing_Default__c != null ? cs.Adv_Routing_Default__c : 'Send to CRP Team'); //re #457
        selectedAccountTeam = (cs.Adv_Rt_Acct_Team_Object__c != null ? cs.Adv_Rt_Acct_Team_Object__c : '');
        selectedRoutBy = (cs.Adv_Rt_Acct_Team_Routeby__c != null ? cs.Adv_Rt_Acct_Team_Routeby__c : '');
        selectedRoleField = (cs.Adv_Rt_Acct_Team_Role_Picklist__c != null ? cs.Adv_Rt_Acct_Team_Role_Picklist__c : '');
        selectedUserField = (cs.Adv_Rt_Acct_Team_User__c != null ? cs.Adv_Rt_Acct_Team_User__c : ''); 
        selectedContactField = (cs.Adv_Rt_Acct_Team_Contact__c != null ? cs.Adv_Rt_Acct_Team_Contact__c : ''); 
        rolesIncluded = (cs.Adv_Rt_Acct_Team_Roles_to_Include__c != null ? cs.Adv_Rt_Acct_Team_Roles_to_Include__c : '');  
        populateRolesToInclude();
        excludedGroups = cs.Routing_Groups_to_Exclude__c != null ? cs.Routing_Groups_to_Exclude__c : '';
        populateGroups();
        return null;
    }
    
    /**
     * Method used to save fields on the form.
     */
    public PageReference saveForm() {
        Savepoint sp = Database.setSavepoint();
        try { 
        	 
        	if (checkPermissions() && validate()) {
	        	cs.Adv_Rt_Acct_Team_Object__c = selectedAccountTeam;
	        	cs.Adv_Rt_Acct_Team_Routeby__c = selectedRoutBy;
                cs.Adv_Rt_Acct_Team_Role_Picklist__c = selectedRoleField;
	        	cs.Adv_Rt_Acct_Team_User__c = selectedUserField;
                cs.Adv_Rt_Acct_Team_Contact__c = selectedContactField;	
                cs.Adv_Rt_Acct_Team_Roles_to_Include__c = rolesIncluded;
                cs.Routing_Groups_to_Exclude__c = excludedGroups;
	                	
	        	AccountTeamName = (selectedAccountTeam != '' ? mapAccountTeam.get(selectedAccountTeam) : '');
      			PickListRouteBy = (selectedRoutBy != '' ? mapRoutByList.get(selectedRoutBy) : '');
                PickListRoles = (selectedRoleField != '' ? mapRoleList.get(selectedRoleField) : '');
      			UserFieldName = (selectedUserField != '' ? mapUserField.get(selectedUserField) : '');
      			ContactFieldName = (selectedContactField != '' ? mapContactField.get(selectedContactField) : '');
                RolesIncludedNames = '';
                if (rolesIncluded != null && rolesIncluded != '') {
                    
                    for (String values: rolesIncluded.split(',')) {
                        RolesIncludedNames += maproleValuesList.get(values) + ',';
                    }
                    RolesIncludedNames = RolesIncludedNames.removeEndIgnoreCase(',');
                }
                populateRolesToInclude();
                excludedGroupNames = '';

                if (excludedGroups != null && excludedGroups != '') {

                    for (String grp : excludedGroups.split(',')) {
                        excludedGroupNames = excludedGroupNames == '' ? grp : excludedGroupNames + ',' + grp;
                    }
                }
                populateGroups();
                upsert cs;
            	isEdit = false;
        	}
        	
        } catch(Exception e) {
            Apexpages.addMessages(e);
            Database.rollback(sp);
        }
        return null;
    }
    
    /**
     * Method used validate the fields value.
     */
    private boolean validate() {
    	boolean result = true; 
    	
    	if (cs.Adv_Request_Routing__c && cs.Adv_Routing_Default__c == null) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,System.Label.Select_Routing));
    		result=false;
    	} 
    	// re #472
    	if (selectedAccountTeam != null && (selectedRoutBy == null || selectedUserField == null)) {
    		
    		if (selectedRoutBy == null) {
    		 	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,System.Label.Select_Route_By));
    		} else {
    		 	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,System.Label.Select_User_Field));
    		}
    		result=false;
    	}  

        if (selectedAccountTeam != null && selectedAccountTeam != '' && selectedRoleField!= null && selectedRoleField != '' && selectedRoleValues.size() <= 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,System.Label.Select_Role));
            result = false;
        } else if (result) {
            rolesIncluded = '';
            
            for (SelectOption values : selectedRoleValues) {
                rolesIncluded += values.getValue() + ',';
            }
            rolesIncluded = rolesIncluded.removeEndIgnoreCase(',');
            excludedGroups = '';
            
            for (SelectOption values : selectedGroups) {
                excludedGroups = excludedGroups == '' ? values.getValue() : excludedGroups + ',' + values.getValue();
            }
        }
    	
        return result;
    }
    
    /**
     * Method used cancel.
     */
    public PageReference cancelForm() {
    	cs = UtilityController.getCustomSettings();
        isEdit = false;
        return null;
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();     	
    	fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c', new Set<String> { 
        									UtilityController.appNamespace() + 'Adv_Routing_Default__c',
                                            UtilityController.appNamespace() + 'Adv_Rt_Acct_Team_Roles_to_Include__c',
                                            UtilityController.appNamespace() + 'Adv_Rt_Acct_Team_Role_Picklist__c',
        									UtilityController.appNamespace() + 'Adv_Rt_Acct_Team_Object__c',
        									UtilityController.appNamespace() + 'Adv_Rt_Acct_Team_Routeby__c',
                                            UtilityController.appNamespace() + 'Adv_Rt_Acct_Team_Contact__c',
                                            UtilityController.appNamespace() + 'Routing_Groups_to_Exclude__c',
        									UtilityController.appNamespace() + 'Adv_Rt_Acct_Team_User__c' });
        									     
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
}