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
 * VF Page: MultiSelectRefSettingFields.page
 * Description: controller for editing the fields displayed on the request page for managed requests
 * Last modified by: Gaurav Saini (13 June, 2017) for #732
 */
public with sharing class MultiSelectRefSettingFieldsController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public SelectOption[] availableFields { get; set; }
    public SelectOption[] selectedFields { get; set; }
    public String isContentSetting { get; set; }
    public Map<String, Schema.SObjectField> fldObjMap;
    private Set<String> rightValuesAPIName = new Set<String>();
    private String customId;
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Field__c',
    										new Set<String>{'Name', UtilityController.appNamespace() + 'Field_API_Name__c',
    											UtilityController.appNamespace() + 'Order__c'});
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        Boolean isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String>{UtilityController.appNamespace() + 'Reference_Request_Field__c'});
        return (isUpsertPermission && isDeletePermission);
    }
    
    /**
     * Constructor
     */
    public MultiSelectRefSettingFieldsController() {
        checkPermissions();
        customId = apexPages.currentPage().getParameters().get('customSettingId');
        isContentSetting = apexPages.currentPage().getParameters().get('isContentSetting');
        availableFields = new List<SelectOption>();
        selectedFields = new List<SelectOption>();
        fldObjMap = schema.SObjectType.Reference_Request_Additional_Info__c.fields.getMap();
        
        for (Reference_Request_Field__c rrf : [SELECT Order__c, Name, Field_API_Name__c
        										FROM Reference_Request_Field__c
        										LIMIT :limits.getLimitQueryRows()]) {
            selectedFields.add(new SelectOption(rrf.Field_API_Name__c, rrf.Name));
            rightValuesAPIName.add(rrf.Field_API_Name__c);
        }
        
        for (String str : fldObjMap.keyset()) {
            
            if (fldObjMap.get(str).getDescribe().isCreateable()
            			&& fldObjMap.get(str).getDescribe().isCustom()
            			&& !rightValuesAPIName.contains(fldObjMap.get(str).getDescribe().getName())) {
                availableFields.add(new SelectOption(fldObjMap.get(str).getDescribe().getName(), fldObjMap.get(str).getDescribe().getLabel()));
            }
        }
    }
    
    /**
     * Method to Save
     */
    public PageReference Save() {
    	
    	if (checkPermissions()) {
	        Savepoint sp = Database.setSavepoint();
	        
	        try {
	            
	            // Delete old Records
	            if (rightValuesAPIName.size() > 0) {
	                List<Reference_Request_Field__c> refReqFieldToDelete
	                		= new List<Reference_Request_Field__c>([SELECT Order__c, Name, Field_API_Name__c
	            													FROM Reference_Request_Field__c
	            													WHERE Field_API_Name__c IN :rightValuesAPIName]);
	                
	                if (refReqFieldToDelete.size() > 0) {
	                    delete refReqFieldToDelete;
	                }
	            }
	            // Create new Records
	            List<Reference_Request_Field__c> refReqFieldToInsert = new List<Reference_Request_Field__c>();
	            Integer i = 1;
	            
	            for (SelectOption so : selectedFields) {
	                // Remove Namespace
	                String removeNamespace = so.getValue().remove(UtilityController.appNamespace());
	                
	                if (fldObjMap.containsKey(removeNamespace)) {
	                    refReqFieldToInsert.add(new Reference_Request_Field__c(Name = fldObjMap.get(removeNamespace).getDescribe().getLabel(),
	                        Field_API_Name__c = fldObjMap.get(removeNamespace).getDescribe().getName(),
	                        Order__c = i));
	                    i = i + 1;
	                }
	            }
	            
	            if (refReqFieldToInsert.size() > 0) {
	                insert refReqFieldToInsert;
	            }
	            return returnPageUrl();
	        } catch (Exception e) {
	            Apexpages.addMessages(e);
	            Database.rollback(sp);
	            return null;
	        }
    	} else {
    		return null;
    	}
    }
    
    /**
     * Method to Cancel
     */
    public PageReference Cancel() {
        return returnPageUrl();
    }
    
    /**
     * Method to create return Page Url Method use in save & Cancel Methods
     */
    public PageReference returnPageUrl() {
        PageReference returnPage = new PageReference(Page.RequestSettingMatrix.geturl()
        												+ '?customSettingId=' + customId
        												+ '&isContentSetting=' + isContentSetting);
        returnPage.setRedirect(true);
        return returnPage;
    }
}