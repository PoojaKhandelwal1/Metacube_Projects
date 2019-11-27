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
 * VF Page: MultiSelectNominationFields.page
 * Description: controller for editing the fields displayed on the nomination form page
 * Last modified by: Gaurav Saini (13 June, 2017) for #732
 */
public with sharing class MultiSelectNominationFieldsController extends RefEdgeEditionFeatures {
    
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
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Data_Mapping__c',
    										new Set<String>{'Name', UtilityController.appNamespace() + 'Field_API_Name__c',
    											UtilityController.appNamespace() + 'Object__c',
    											UtilityController.appNamespace() + 'Visible__c',
    											UtilityController.appNamespace() + 'Required__c',
    											UtilityController.appNamespace() + 'Order__c'});
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        Boolean isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String>{UtilityController.appNamespace() + 'Data_Mapping__c'});
        return (isUpsertPermission && isDeletePermission);
    }
    
    /**
     * Constructor
     */
    public MultiSelectNominationFieldsController() {
        checkPermissions();
        customId = apexPages.currentPage().getParameters().get('customSettingId');
        availableFields = new List<SelectOption>();
        selectedFields = new List<SelectOption>();
        allFields = new Set<String>();
        Set<String> fieldSet = new Set<String>{'account__c', 'contact__c', 'disposition__c',
        										'email_enabled__c', 'get_current_instance__c', 'new_nomination_URL__c',
        										'referenceability__c', 'note__c', 'status__c', 'other_info__c',
        										'test_area_field__c', 'influitive_id__c', 'sample_field_01_del__c'};
        fldObjMap = schema.SObjectType.Nomination__c.fields.getMap();
        
        for (Data_Mapping__c rrf : [SELECT Name, Order__c, Id, Visible__c, Field_API_Name__c, Required__c
    									FROM Data_Mapping__c
    									WHERE Object__c = :ConstantsController.NOMINATION
    									ORDER BY Order__c]) {
            selectedFields.add(new SelectOption(rrf.Field_API_Name__c, rrf.Name));
            rightValuesAPIName.add(rrf.Field_API_Name__c);
        }
        
        for (String field : fldObjMap.keyset()) {
            allFields.add(fldObjMap.get(field).getDescribe().getName());
            
            if (!fieldSet.contains(field)
            			&& fldObjMap.get(field).getDescribe().isCustom()
            			&& fldObjMap.get(field).getDescribe().isUpdateable()
            			&& !rightValuesAPIName.contains(fldObjMap.get(field).getDescribe().getName())) {
                availableFields.add(new SelectOption(fldObjMap.get(field).getDescribe().getName(), fldObjMap.get(field).getDescribe().getLabel()));
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
	            ConstantsController.shouldDataMappingProcessed = true;
	            Map<String, Data_Mapping__c> mapOfNomiFields = new Map<String, Data_Mapping__c>();
	            List<Data_Mapping__c> NomiFieldToDelete;
	            
	            // Delete old Records
	            if (rightValuesAPIName.size() > 0) {
	                NomiFieldToDelete = [SELECT Name, Order__c, Id, Visible__c, Field_API_Name__c, Required__c
	            							FROM Data_Mapping__c
	            							WHERE Object__c = :ConstantsController.NOMINATION
	            							AND Field_API_Name__c IN :rightValuesAPIName];
	                
	                if (NomiFieldToDelete.size() > 0) {
	                	
	                    for (Data_Mapping__c DM : NomiFieldToDelete) {
	                        mapOfNomiFields.put(DM.Field_API_Name__c, DM);
	                    }
	                }
	            }
	            // Create new Records
	            List<Data_Mapping__c> NomiFieldToInsert = new List<Data_Mapping__c>();
	            Integer i = 1;
	            
	            for (SelectOption so : selectedFields) {
	            	
	                if (allFields.contains(so.getValue())) {
	                    Data_Mapping__c newDM = new Data_Mapping__c(Name = fldObjMap.get(so.getValue()).getDescribe().getLabel(),
														Field_API_Name__c = fldObjMap.get(so.getValue()).getDescribe().getName(),
														Object__c = ConstantsController.NOMINATION,
														Order__c = i);
						
	                    if (mapOfNomiFields.containsKey(fldObjMap.get(so.getValue()).getDescribe().getName())) {
	                        newDM.Visible__c = mapOfNomiFields.get(fldObjMap.get(so.getValue()).getDescribe().getName()).Visible__c;
	                        newDM.Required__c = mapOfNomiFields.get(fldObjMap.get(so.getValue()).getDescribe().getName()).Required__c;
	                    }
	                    NomiFieldToInsert.add(newDM);
	                    i = i + 1;
	                }
	            }
	            
	            if (rightValuesAPIName.size() > 0) {
	            	
	                if (NomiFieldToDelete.size() > 0) {
	                    delete NomiFieldToDelete;
	                	Database.emptyRecycleBin(NomiFieldToDelete);
	                }
	            }
				
	            if (NomiFieldToInsert.size() > 0) {
	                insert NomiFieldToInsert;
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
        PageReference returnPage = new PageReference(Page.NominationSettings.geturl() + '?customSettingId=' + customId);
        returnPage.setRedirect(true);
        return returnPage;
    }
}