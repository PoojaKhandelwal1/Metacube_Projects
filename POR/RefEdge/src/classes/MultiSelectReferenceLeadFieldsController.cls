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
 * Page: MultiSelectReferenceLeadFields
 * Description: Class to show available fields to SELECT on reference lead setting page
 * Modified by: Rekha @Feb 6 2017
 */
public with sharing class MultiSelectReferenceLeadFieldsController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public SelectOption[] availableFields { get; set; }
    public SelectOption[] selectedFields { get; set; }
    public Map<String, Schema.SObjectField> fldObjMap;
    private Set<String> rightValuesAPIName = new Set<String>();
    private String customId;
    private Set<String> allFields;
    
    /**
     * Constructor
     */
    public MultiSelectReferenceLeadFieldsController() {
        customId = apexPages.currentPage().getParameters().get('customSettingId');
        availableFields = new List<SelectOption>();
        selectedFields = new List<SelectOption>();
        allFields = new Set<String>();
        
        Set<String> fieldSet = new Set<String> {
            'contact__c', 'follow_up_date__c', 'follow_up_timeframe__c',
            'initial_notification_date__c', 'initial_notification_sent__c',
            'nomination__c', 'nomination_record__c', 'no_response_date__c', 'notification_response__c',
            'opportunity_owner__c', 'reference_lead_account__c', 'reference_lead_opportunity__c',
            'reference_lead_owner__c', 'reference_lead_status__c', 'reference_profile__c',
            'reference_program_member__c', 'response_received__c', 'other_info__c', 'nominated__c', 'ReferenceLeadLink__c'
        };
        fldObjMap = schema.SObjectType.Reference_Lead__c.fields.getMap();
        
        for (Data_Mapping__c rrf : [SELECT Name, Order__c, Id, Visible__c, Field_API_Name__c, Required__c 
        							FROM Data_Mapping__c WHERE Object__c = :ConstantsController.REFERENCE_LEAD 
        							AND Referenceability_Type__c = null AND Filter__c = null ORDER BY Order__c]) {
            
            if (rrf.Field_API_Name__c != null) {
                selectedFields.add(new SelectOption(rrf.Field_API_Name__c, rrf.Name));
                rightValuesAPIName.add(rrf.Field_API_Name__c);
            }
        }

        for (String field : fldObjMap.keyset()) {
            allFields.add(fldObjMap.get(field).getDescribe().getName());
            
            if (!fieldSet.contains(field) && fldObjMap.get(field).getDescribe().isCustom() 
            		&& fldObjMap.get(field).getDescribe().isUpdateable() && !rightValuesAPIName.contains(fldObjMap.get(field).getDescribe().getName())) {
                availableFields.add(new SelectOption(fldObjMap.get(field).getDescribe().getName(), fldObjMap.get(field).getDescribe().getLabel()));
            }
        }
        checkPermissions();
    }
    
    /**
     * Method to Save
     */
    public PageReference Save() {
    	
    	if (checkPermissions()) {
	        Savepoint sp = Database.setSavepoint();
	        
	        try {
	            ConstantsController.shouldDataMappingProcessed = true;
	            Map<String, Data_Mapping__c> mapOfRefLeadFields = new Map<String, Data_Mapping__c>();
	            List<Data_Mapping__c> refLeadFieldToDelete;
	            
	            //Delete old Records
	            if (rightValuesAPIName.size() > 0) {
	                refLeadFieldToDelete = [SELECT Name, Order__c, Id, Visible__c, Field_API_Name__c, Required__c FROM Data_Mapping__c 
	                					WHERE Object__c = :ConstantsController.REFERENCE_LEAD AND Referenceability_Type__c = null 
	                					AND Filter__c = null AND Field_API_Name__c IN :rightValuesAPIName];
	                					
	                if (refLeadFieldToDelete.size() > 0) {
	                	
	                    for (Data_Mapping__c DM : refLeadFieldToDelete) {
	                        mapOfRefLeadFields.put(DM.Field_API_Name__c, DM);
	                    }
	                }
	            }
	            //Create new Records
	            List<Data_Mapping__c> refLeadFieldToInsert = new List<Data_Mapping__c>();
	            Integer i = 1;
	            
	            for (SelectOption so : selectedFields) {
	            	
	                if (allFields.contains(so.getValue())) {
	                    Data_Mapping__c newDM = new Data_Mapping__c(Name = fldObjMap.get(so.getValue()).getDescribe().getLabel(),
	                        Field_API_Name__c = fldObjMap.get(so.getValue()).getDescribe().getName(),
	                        Object__c = ConstantsController.REFERENCE_LEAD,
	                        Order__c = i);
	                        
	                    if (mapOfRefLeadFields.containsKey(fldObjMap.get(so.getValue()).getDescribe().getName())) {
	                        newDM.Visible__c = mapOfRefLeadFields.get(fldObjMap.get(so.getValue()).getDescribe().getName()).Visible__c;
	                        newDM.Required__c = mapOfRefLeadFields.get(fldObjMap.get(so.getValue()).getDescribe().getName()).Required__c;
	                    }
	                    refLeadFieldToInsert.add(newDM);
	                    i = i + 1;
	                }
	            }
	            
	            if (rightValuesAPIName.size() > 0) {
	            	
	                if (refLeadFieldToDelete.size() > 0) {
	                    delete refLeadFieldToDelete;
	                 	Database.emptyRecycleBin(refLeadFieldToDelete);   
	                }
	            }
	            
	            if (refLeadFieldToInsert.size() > 0) {
	                insert refLeadFieldToInsert;
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
        PageReference returnPage = new PageReference(Page.referenceLeadMappingPage.geturl() + '?customSettingId=' + customId);
        returnPage.setRedirect(true);
        return returnPage;
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
	
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Data_Mapping__c', new Set<String> { 'Name',
        										UtilityController.appNamespace() + 'Field_API_Name__c',
        										UtilityController.appNamespace() + 'Object__c',
        										UtilityController.appNamespace() + 'Order__c',
        										UtilityController.appNamespace() + 'Visible__c',
        										UtilityController.appNamespace() + 'Required__c'});
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
		Boolean isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Data_Mapping__c'});
        return (isUpsertPermission && isDeletePermission);
    }
}