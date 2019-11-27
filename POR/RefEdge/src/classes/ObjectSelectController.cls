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
 * VF Page: SelectObjectPage.page
 * Description: controller for changing the settings for shared contacts
 * Last modified by: Gaurav Saini (20 Feb, 2017) for #732
 */
public with sharing class ObjectSelectController {
    
    public List<Schema.SObjectType> gd { get; set; }
    public List<SelectOption> sObjectList { get; set; }
    public List<SelectOption> fieldList { get; set; }
    public String selectedObject { get; set; }
    public String selectedAccount { get; set; }
    public String selectedContact { get; set; }
    public Boolean isEdit { get; set; }
    public Custom_Settings__c cs { get; set; }
    public boolean isSLDS { get; set; }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c',
    										new Set<String>{UtilityController.appNamespace() + 'Shared_Contact_Object__c',
    											UtilityController.appNamespace() + 'Shared_Contact_Field__c',
    											UtilityController.appNamespace() + 'Shared_Account_Field__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
    
    /**
     * constructor
     */
    public ObjectSelectController(ApexPages.StandardController controller) {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
	        //isUpsertPermission = checkPermissions();
	        cs = UtilityController.getCustomSettings();
	        isEdit = false;
	        sObjectList = new List<SelectOption>();
	        sObjectList.add(new SelectOption('', '--None--'));
	        fieldList = new List<SelectOption>();
	        fieldList.add(new SelectOption('', '--None--'));
	        gd = CRUDAndFLSCheckController.sObjectsMap.Values();
	        
	        for (Schema.SObjectType f : gd) {
	        	
	            if (f.getDescribe().getName().endsWith('__c')) {
	                sObjectList.add(new SelectOption(f.getDescribe().getName(), f.getDescribe().getLabel()));
	            }
	        }
	        selectedObject = (cs.Shared_Contact_Object__c != null ? cs.Shared_Contact_Object__c : '');
	        populateFieldList();
	        selectedAccount = (cs.Shared_Account_Field__c != null ? cs.Shared_Account_Field__c : '');
	        selectedContact = (cs.Shared_Contact_Field__c != null ? cs.Shared_Contact_Field__c : '');
        }
    }
    
    /**
     * method to get the list of lookup fields for the selected object
     */
    public void populateFieldList() {
        fieldList = new List<SelectOption>();
        fieldList.add(new SelectOption('', '--None--'));
        
        if (selectedObject != null && selectedObject != '') {
            Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(selectedObject);
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            
            for (String field : fieldMap.keySet()) {
                Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
                
                if (dfr.getName().endsWith('__c') && String.valueOf(dfr.getType()) == 'REFERENCE') {
                    fieldList.add(new SelectOption(dfr.getName(), dfr.getLabel()));
                }
            }
        }
    }
    
    /**
     * method to show the edit mode view of the form
     */
    public PageReference editForm() {
        isEdit = true;
        selectedObject = (cs.Shared_Contact_Object__c != null ? cs.Shared_Contact_Object__c : '');
        selectedAccount = (cs.Shared_Account_Field__c != null ? cs.Shared_Account_Field__c : '');
        selectedContact = (cs.Shared_Contact_Field__c != null ? cs.Shared_Contact_Field__c : '');
        return null;
    }
    
    /**
     * method to save the settings for shared contacts
     */
    public PageReference saveForm() {
        
        if (checkPermissions()) {
	        Savepoint sp = Database.setSavepoint();
	        
	        try {
	            cs.Shared_Contact_Object__c = selectedObject;
	            cs.Shared_Account_Field__c = selectedAccount;
	            cs.Shared_Contact_Field__c = selectedContact;
	            upsert cs;
	            isEdit = false;
	        } catch(Exception e) {
	            Apexpages.addMessages(e);
	            Database.rollback(sp);
	        }
        }
        return null;
    }
    
    /**
     * method to discard the changes
     */
    public PageReference cancelForm() {
    	cs = UtilityController.getCustomSettings();
        isEdit = false;
        return null;
    }
}