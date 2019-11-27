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
 * Page : Custom Setting->Filtered Content Tab
 * Description: Page is used to manage Reference Content Types under custom setting.
 * Last Modified By: Rajesh @Feb 6 2017
 */
public with sharing class FilteredContentTab extends RefEdgeEditionFeatures {
	/**
     * Properties and variables
     */
    private String customId;
    private Custom_Settings__c  cs; 
    public List<SelectOption> contentTypes { get; set; }
    public SelectOption[] selectedFields { get; set; }
    
    /**
     * Constructor
     */
    public FilteredContentTab() {
        customId = apexPages.currentPage().getParameters().get('customSettingId');
        // Check object premision re #728 
        checkPermissions();
        cs = UtilityController.getCustomSettings();
        contentTypes = new List<SelectOption>();
        selectedFields = new List<SelectOption>(); 
        Set<String> setReferenceContentTypes = new Set<String>();
        
        if (cs.Filtered_Content_Ids__c != null) {
            
            for (String refenceContentId : cs.Filtered_Content_Ids__c.split(',')) {
                setReferenceContentTypes.add(refenceContentId);
            }
        } 
        
        for (Reference_Content_Type__c rct : [SELECT Id, Name__c FROM Reference_Content_Type__c  ORDER BY Name__c LIMIT :Limits.getLimitQueryRows()]) {
            
            if (setReferenceContentTypes.contains(rct.Id)) {
                selectedFields.add(new SelectOption(rct.Id, rct.Name__c));
            } else {
                contentTypes.add(new SelectOption(rct.Id, rct.Name__c));
            }
        }
    }
    
    /**
     * Method to Save filtered contents
     */ 
    public Pagereference save() {
        try {
        	
        	if (checkPermissions()) {
	            String filteredContentIds = '';
	            
	            for (SelectOption so: selectedFields) {
	                filteredContentIds += (filteredContentIds == '' ? so.getValue() : ',' + so.getValue());
	            }
	            cs.Filtered_Content_Ids__c = filteredContentIds;
	            update cs;
	            return new PageReference('/' + customId);
        	} else {
        		return null;
        	}
        } catch (DmlException e) {
        	ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
	        Apexpages.addMessage(message); 
            return null;
        }
        
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions() {  
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>(); 
    	Boolean isUpsertPermission = false; 
        fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c', new Set<String> { 
        										UtilityController.appNamespace() + 'Filtered_Content_Ids__c' });    
    
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);   
        return isUpsertPermission; 
    }
    
    /**
     * Method to Cancel
     */ 
    public Pagereference cancel() {
        return new PageReference('/'+customId);
    }
}