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
 * VF Page: S 
 * Description: 
 * Last modified by: Rajesh (29 Aug, 2018) for #REF-1915
 */
public with sharing class ContentIntegrationController {
    public Boolean isEdit { get; set; }
    public Boolean isSLDS { get; set; }
    public List<SelectOption> libraryList { get; set; }
    public List<SelectOption> contnetTypeList { get; set; }
    public Custom_Settings__c cs { get; set; }
    public String selectedLibrary { get; set; }
    public String selectedRefContnetType { get; set; }
    public String selectedLibraryName { get; set; }
    public String selectedRefContnetTypeName { get; set; } 
    private List<ContentWorkspace> lstLibrary;
    private List<Reference_Content_Type__c> lstRefContnet;

    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c',
    										new Set<String>{UtilityController.appNamespace() + 'Enabled_Content_Integration__c',
    											UtilityController.appNamespace() + 'Default_Library__c',
    											UtilityController.appNamespace() + 'Default_Reference_Content_Type__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }

    public ContentIntegrationController (ApexPages.StandardController controller) {
        cs = UtilityController.getCustomSettings();
        isEdit = false;
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        libraryList = new List<SelectOption>();
        libraryList.add(new SelectOption('', '--None--'));
        contnetTypeList = new List<SelectOption>();
        contnetTypeList.add(new SelectOption('', '--None--'));
        lstLibrary = new List<ContentWorkspace>(); 
        lstRefContnet = new List<Reference_Content_Type__c>(); 
        selectedLibrary = (cs.Default_Library__c != null ? cs.Default_Library__c : '');
        selectedRefContnetType = (cs.Default_Reference_Content_Type__c != null ? cs.Default_Reference_Content_Type__c : ''); 

        getRecords();
        populateFieldList();
    }
    
    /**
     * method to show the edit mode view of the form
     */
    public PageReference editForm() { 
        isEdit = true; 
        populateFieldList();
        return null;
    }
    
    /**
     * method to get recoreds 
     */
    public void getRecords() { 
        lstLibrary = [SELECT Id, Name FROM ContentWorkspace LIMIT :limits.getLimitQueryRows()];
        lstRefContnet = [SELECT Id, Name__c, Active__c, Recorded_Reference_Type__c FROM Reference_Content_Type__c
            										WHERE Active__c = true ORDER BY Name__c LIMIT :limits.getLimitQueryRows()];

        for (Reference_Content_Type__c rc : lstRefContnet) { 
            contnetTypeList.add(new SelectOption(rc.Id, rc.Name__c));

            if (selectedRefContnetType.trim() == String.valueOf(rc.Id)) {
                selectedRefContnetTypeName = rc.Name__c;
            }
        }

        for (ContentWorkspace cw : lstLibrary) {
            libraryList.add(new SelectOption(cw.Id, cw.Name));

            if (selectedLibrary.trim() == String.valueOf(cw.Id)) {
                selectedLibraryName = cw.Name;
            }
        } 
    }

    /**
     * method to get the list of lookup fields for the selected object
     */
    public void populateFieldList() { 
        
        for (Reference_Content_Type__c rc : lstRefContnet) { 
             
            if (selectedRefContnetType.trim() == String.valueOf(rc.Id)) {
                selectedRefContnetTypeName = rc.Name__c;
            }
        } 

        for (ContentWorkspace cw : lstLibrary) { 

            if (selectedLibrary.trim() == String.valueOf(cw.Id)) {
                selectedLibraryName = cw.Name;
            }
        } 
    }

    /**
     * method to save the settings for shared contacts
     */
    public PageReference saveForm() {
        
        if (checkPermissions()) {
	        Savepoint sp = Database.setSavepoint();
	        
	        try {
                
                if (validate()) {
                    cs.Default_Library__c = selectedLibrary;
                    cs.Default_Reference_Content_Type__c = selectedRefContnetType;
                    
                    upsert cs;
                    populateFieldList();
                    isEdit = false;
                }
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
    public Boolean validate() {
        Boolean result = true;
       
        if (String.isBlank(selectedLibrary) || String.isBlank(selectedRefContnetType)) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, 'Please select the required values.');
            Apexpages.addMessage(message);
            result = false;
        }
        return result;
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