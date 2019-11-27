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
 * VF Page: Customsettings -> Manage Content Version Custom Fields  
 * Description: Class used to manage Content Version Custom Fields.
 * Last modified by: Rajesh @Feb 10 2017
 */
public with sharing class ManageContentVersionFields extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    private String customId;
    private List<Custom_Settings__c> customSetting;
    public List<ContentFieldsWrapper> listContentFields { get; set; }
    public Boolean isEdit { get; set; }
    
    /**
     *Constructor
     */
    public ManageContentVersionFields() {
        //Check already selected content fields
        customId = apexPages.currentPage().getParameters().get('customSettingId');
        //Check user premission.
        checkPermissions();
        refresh();
    }
    
    /**
    * Method to refresh 
    */
    public void refresh(){
        customSetting = [SELECT Manage_ContentVersion_Custom_Fields__c FROM Custom_Settings__c WHERE Id = :customId];
        isEdit = false;
        Set<String> setContentFields = new Set<String>();
        
        if (customSetting.get(0).Manage_ContentVersion_Custom_Fields__c != null) {
            
            for (String str : customSetting.get(0).Manage_ContentVersion_Custom_Fields__c.split(',')) {
                setContentFields.add(str);
            }
        } 
        //Describe ContentVersion Object & its fields
        Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get('ContentVersion');
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        
        //Populate fields in list
        List<String> listFields = new List<String>();
        Map<String, String> mapLabelName = new Map<String, String>();
        Set<String> setRequiredContentFields = new Set<String>();
        
        for (String str : sobject_describe.fields.getMap().keyset()) {
            
            if (sobject_describe.fields.getMap().get(str).getDescribe().isCreateable() &&
                sobject_describe.fields.getMap().get(str).getDescribe().isCustom() &&
                sobject_describe.fields.getMap().get(str).getDescribe().getName() != UtilityController.appNamespace() + 'Reference_Content_Type__c' &&
                sobject_describe.fields.getMap().get(str).getDescribe().getName() != UtilityController.appNamespace() + 'Content_Status__c') {
                listFields.add(sobject_describe.fields.getMap().get(str).getDescribe().getName());
                mapLabelName.put(sobject_describe.fields.getMap().get(str).getDescribe().getName(), sobject_describe.fields.getMap().get(str).getDescribe().getLabel());
                
                if (sobject_describe.fields.getMap().get(str).getDescribe().isCreateable() && !sobject_describe.fields.getMap().get(str).getDescribe().isNillable() && !sobject_describe.fields.getMap().get(str).getDescribe().isDefaultedOnCreate()) {
                    setRequiredContentFields.add(sobject_describe.fields.getMap().get(str).getDescribe().getName());
                }
            }
        }
        listFields.sort();
        
        //Create wrapper
        listContentFields = new List<ContentFieldsWrapper>();
        
        for (String str : listFields) {
            listContentFields.add(new ContentFieldsWrapper((setContentFields.contains(str) || setRequiredContentFields.contains(str)), 
            												mapLabelName.get(str), str, setRequiredContentFields.contains(str)));
        }
    }
    
    /**
    * Method to Edit 
    */
    public pageReference edit() {
        isEdit = true;
        return null;
    }
    
    /**
     * Method to return Custom Setting
     */
    public pageReference returnCustomSettings() {
        PageReference returnPage = new PageReference('/' + customId);
        returnPage.setRedirect(true);
        return returnPage;
    }
    
    /**
     *Method to Save
     */
    public Pagereference save(){
        try {
        	 
        	if (checkPermissions()) {
	            String fieldsName = '';
	            
	            for (ContentFieldsWrapper cfw : listContentFields) {
	                
	                if (cfw.isSelected) {
	                    fieldsName += (fieldsName == '' ? cfw.fieldName : ',' + cfw.fieldName);
	                }
	            } 
	            customSetting.get(0).Manage_ContentVersion_Custom_Fields__c = fieldsName;
	            update customSetting;
	            refresh();
	            return null;
        	} else {
    		return null;
        	} 
        } catch (DmlException e) {
            isEdit = true;
            Apexpages.addMessages(e);
            return null;
        }
    }
    
    /**
     *Method to Cancel
     */
    public Pagereference cancel(){
        refresh();
        return null;
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions() { 
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>(); 
    	Boolean isUpsertPermission = false; 
        fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c', new Set<String> {
        															UtilityController.appNamespace() + 'Manage_ContentVersion_Custom_Fields__c'});  
        										
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true); 
        return isUpsertPermission; 
    }
    
    /**
     * Content Fields Wrapper Class
     */
     public class ContentFieldsWrapper {
        public Boolean isSelected { get; set; }
        public String fieldName { get; set; }
        public String fieldLabel { get; set; }
        public Boolean isRequired { get; set; }
        
        public ContentFieldsWrapper(Boolean isSelected, String fieldLabel, String fieldName, Boolean isRequired) {
            this.isSelected = isSelected;
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
            this.isRequired = isRequired;
        }
    }
}