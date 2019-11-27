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
 * VF Page: SelectObjectPageSLDS
 * Description: controller for changing the settings for shared contacts
 * Created by: Rekha Jangir @24 August 2017
 */
public with sharing class ObjectSelectControllerSLDS extends RefEdgeEditionFeatures {
    
    /**
     * Constructor
     */
    public ObjectSelectControllerSLDS(ApexPages.StandardController controller) {}
    
    /**
     * Method to check Permissions
     */
    private static Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	
    	fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c',
    										new Set<String>{UtilityController.appNamespace() + 'Shared_Contact_Object__c',
    											UtilityController.appNamespace() + 'Shared_Contact_Field__c',
    											UtilityController.appNamespace() + 'Shared_Account_Field__c',
    											UtilityController.appNamespace() + 'Shared_Contacts__c',
    											UtilityController.appNamespace() + 'Inherit_Attributes_from_All_Accounts__c',
    											UtilityController.appNamespace() + 'Inherit_Attributes_from_Primary_Account__c',
    											UtilityController.appNamespace() + 'Roll_up_Attributes_to_All_Accounts__c',
    											UtilityController.appNamespace() + 'Roll_up_Attributes_to_Primary_Account__c',
    											UtilityController.appNamespace() + 'Roll_up_Referenceability_to_All_Accounts__c',
    											UtilityController.appNamespace() + 'Roll_up_Referenceability_to_Primary_Acc__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
    
    
    /**
     * Remote Action Method to get Objects names
     */
    @RemoteAction
    public static List<OptionWrapper> getObjects() {
        List<OptionWrapper> options = new List<OptionWrapper>();
        List<Schema.SObjectType> gd = CRUDAndFLSCheckController.sObjectsMap.Values();
        
        for (Schema.SObjectType f : gd) {
        	
            if (f.getDescribe().getName().endsWith('__c')) {
                options.add(new OptionWrapper(f.getDescribe().getName(), f.getDescribe().getLabel()));
            }
        }
        return options;
    }
    /**
     * Remote Action Method to get fields for an object
     */
    @RemoteAction
    public static List<OptionWrapper> getFields(String selectedObject) {
    	List<OptionWrapper> returnFields = new List<OptionWrapper>();
    	
        if (selectedObject != null && selectedObject != '') {
            Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(selectedObject);
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            
            for (String field : fieldMap.keySet()) {
                Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
                
                if (dfr.getName().endsWith('__c') && String.valueOf(dfr.getType()) == 'REFERENCE') {
                    returnFields.add(new OptionWrapper(dfr.getName(), dfr.getLabel()));
                }
            }
        }
        return returnFields;
    }
    
    /**
     * Method to get Custom Setting field ConsiderNoLongerNeeded
     * Created By: Rekha Jangir @24 August 2017
     */
    @RemoteAction
    public static String saveCSRUL(String cswJSON) { 
    	
    	try {
    		
    		if (checkPermissions()) {
	    		CustomSettingWrapper csw = (CustomSettingWrapper)JSON.deserialize(cswJSON, CustomSettingWrapper.class);
		    	Custom_Settings__c cs = UtilityController.getCustomSettings();
		    	cs.Shared_Contacts__c = csw.isShared;
		    	cs.Shared_Contact_Object__c = csw.selectedObject;
		    	cs.Shared_Account_Field__c = csw.selectedAccField;
		    	cs.Shared_Contact_Field__c = csw.selectedConField;
		    	cs.Inherit_Attributes_from_All_Accounts__c = csw.inheritAttFromAll;
		    	cs.Inherit_Attributes_from_Primary_Account__c = csw.inheritAttFromPrimary;
		    	cs.Roll_up_Attributes_to_All_Accounts__c = csw.rollupAttToAll;
		    	cs.Roll_up_Attributes_to_Primary_Account__c = csw.rollupAttToPrimary;
		    	cs.Roll_up_Referenceability_to_All_Accounts__c = csw.rollupRefToAll;
		    	cs.Roll_up_Referenceability_to_Primary_Acc__c = csw.rollupRefToPrimary;
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
    public static CustomSettingWrapper getCustomSetting() { 
        CustomSettingWrapper csw = new CustomSettingWrapper();
    	Custom_Settings__c cs = UtilityController.getCustomSettings();
    	csw.isShared = cs.Shared_Contacts__c;
    	csw.selectedObject = cs.Shared_Contact_Object__c;
    	csw.selectedAccField = cs.Shared_Account_Field__c;
    	csw.selectedConField = cs.Shared_Contact_Field__c;
    	csw.inheritAttFromAll = cs.Inherit_Attributes_from_All_Accounts__c;
    	csw.inheritAttFromPrimary = cs.Inherit_Attributes_from_Primary_Account__c;
    	csw.rollupAttToAll = cs.Roll_up_Attributes_to_All_Accounts__c;
    	csw.rollupAttToPrimary = cs.Roll_up_Attributes_to_Primary_Account__c;
    	csw.rollupRefToAll = cs.Roll_up_Referenceability_to_All_Accounts__c;
    	csw.rollupRefToPrimary = cs.Roll_up_Referenceability_to_Primary_Acc__c;
        return csw;
    }
    
    /**
     * Wrapper class for Custom Setting
     * Created By: Rekha Jangir @25 August 2017
     */
    public class CustomSettingWrapper {
    	public Boolean isShared { get; set; }
    	public String selectedObject { get; set; }
    	public String selectedAccField { get; set; }
    	public String selectedConField { get; set; }
    	public Boolean inheritAttFromAll { get; set; }
        public Boolean inheritAttFromPrimary { get; set; }
        public Boolean rollupAttToAll { get; set; }
        public Boolean rollupAttToPrimary { get; set; }
        public Boolean rollupRefToAll { get; set; }
        public Boolean rollupRefToPrimary { get; set; }
    }
    
    /**
     * Wrapper class
     */
 	public class OptionWrapper {
 		public String name { get; set; }
 		public String id { get; set; }
 		
 	    public OptionWrapper(String id, String name) {
            this.name = name;
            this.id = id;
	    }
 	}
}