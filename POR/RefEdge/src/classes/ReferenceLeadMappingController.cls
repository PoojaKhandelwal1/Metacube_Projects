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
 * Page: ReferenceLeadMapping
 * Description: Class used to handle ReferenceLeadMapping  
 * Modified by: Rajesh @20 Jan 2017
 */
public with sharing class ReferenceLeadMappingController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */ 
    private String customSettingId;
    public List<Referenceability_Type__c> refTypes { get; set; }
    public List<Data_Mapping__c> refTypeMappingRecords { get; set; }
    public List<Data_Mapping__c> filterMappingRecords { get; set; }
    public List<Label__c> labels { get; set; }
    public Boolean isEdit { get; set; }
    public Map<String, Data_Mapping__c> referenceLeadHeaderMap { get; set; }
    public List<Data_Mapping__c> referenceLeadFieldList { get; set; } 
    public Custom_Settings__c cs { get; set; }
    public List<String> HeaderList { get; set; }
    public Map<String, String> HeaderListMap { get; set; }
    private Set<String> mappingPresent = new Set<String>();
    
    /**
     * Constructor
     */
    public ReferenceLeadMappingController() {
        refTypeMappingRecords = new List<Data_Mapping__c>();
        filterMappingRecords = new List<Data_Mapping__c>();
        referenceLeadFieldList = new List<Data_Mapping__c>();
        customSettingId = apexPages.currentPage().getParameters().get('customSettingId');
        // Check User Premissions
    	checkPermissions();
        isEdit = false;
        fetchAllDataForPro();
    }
    
    /**
     * Method to fetch All data related to PRO edition
     */
    private void fetchAllDataForPro() {
        List<Referenceability_Type__c> refTypes = new List<Referenceability_Type__c>();
        Set<Id> refIds = new Set<Id>();
        // re #1114 - Getting only those Referenceability from Data Mapping having visible true in Referenceability Type.
        refTypes = [SELECT Name, Id, Visible__c FROM Referenceability_Type__c WHERE Visible__c = true AND Sales_Reward__c = false  
        						ORDER BY Name LIMIT :limits.getLimitQueryRows()];
        							
        for (Referenceability_Type__c rt : refTypes) {
			refIds.add(rt.Id);
		}
		
		// re #1160 - Check for Filter (Those mapping records should be consider having Ref Type Id OR Filter value for Reference Lead) 
        for (Data_Mapping__c dm :  [SELECT Name, Order__c, Referenceability_Type__c, Referenceability_Type__r.Name, Filter__c, Filter__r.Name, Id, 
        							Visible__c, Field_API_Name__c, Required__c FROM Data_Mapping__c WHERE Object__c = :ConstantsController.REFERENCE_LEAD 
        							AND (Referenceability_Type__c IN :refIds OR Filter__c != NULL) ORDER BY Order__c]) {
            
            if (dm.Referenceability_Type__c != null) {
                refTypeMappingRecords.add(dm);
                mappingPresent.add(dm.Referenceability_Type__c);
            } else if (dm.Filter__c != null) {
                filterMappingRecords.add(dm);
                mappingPresent.add(dm.Filter__c);
            } else {
                referenceLeadFieldList.add(dm);
            }
        }
        
        for (Referenceability_Type__c rt : refTypes) {
           
            if (!mappingPresent.contains(rt.Id)) {
                refTypeMappingRecords.add(new Data_Mapping__c(Name = rt.Name, Referenceability_Type__c = rt.Id, Visible__c = false, 
                									Required__c = false, Object__c = ConstantsController.REFERENCE_LEAD));
            }
        }
        
        for (Label__c lb : [SELECT Name, Id, Visible__c, Required__c, (SELECT Id, Name FROM Attributes_Labels__r) 
        						FROM Label__c ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
        							
            if (lb.Attributes_Labels__r.size() > 0 && !mappingPresent.contains(lb.Id)) {
                filterMappingRecords.add(new Data_Mapping__c(Name = lb.Name, Filter__c = lb.Id, Visible__c = false, 
                						Required__c = false, Object__c = ConstantsController.REFERENCE_LEAD));
            }
        }
        HeaderList = new List<String>();
        HeaderListMap = new Map<String, String>();
        HeaderList.add(ConstantsController.HEADER);
        HeaderListMap.put(ConstantsController.HEADER, System.Label.Section_1_Header);
        HeaderList.add(ConstantsController.SUBHEADER);
        HeaderListMap.put(ConstantsController.SUBHEADER, System.Label.Section_2_Sub_Header);
        HeaderList.add(ConstantsController.ATTRIBUTES);
        HeaderListMap.put(ConstantsController.ATTRIBUTES, System.Label.Section_3_Attributes);
        HeaderList.add(ConstantsController.CUSTOMFIELDS);
        HeaderListMap.put(ConstantsController.CUSTOMFIELDS, System.Label.Section_4_Custom_Fields);
        HeaderList.add(ConstantsController.REFTYPES);
        HeaderListMap.put(ConstantsController.REFTYPES, System.Label.Section_5_Reference_Activities);
        HeaderList.add(ConstantsController.FREEFROMTEXT);
        HeaderListMap.put(ConstantsController.FREEFROMTEXT, System.Label.Section_6_Free_Form_Text);
        referenceLeadHeaderMap = new Map<String, Data_Mapping__c>();
        
        for (integer i = 0; i < HeaderList.size(); i++) {
            referenceLeadHeaderMap.put(HeaderList.get(i), new Data_Mapping__c(Name = HeaderList.get(i), Order__c = i + 1, Object__c = ConstantsController.REFERENCE_LEAD_HEADER));
        }
      
        for (Data_Mapping__c field :  [SELECT Name, Id, Visible__c, Required__c, Field_API_Name__c, Order__c FROM Data_Mapping__c 
        								WHERE Object__c = :ConstantsController.REFERENCE_LEAD_HEADER]) {
            
            if (referenceLeadHeaderMap.containsKey(field.Name)) {
                referenceLeadHeaderMap.put(field.Name, field);
            }
		}
    }
    
    /**
     * Method to Edit Reference Lead Settings
     */
    public pageReference editNominationSettings() {
        isEdit = true;
        return null;
    }

    /**
     * Method to save Reference Lead setting
     */
    public pageReference saveReferenceLeadSettings() {
    	// Check User Premissions
    	if (checkPermissions()) {
	        Savepoint sp = Database.setSavepoint();
	       
	        try {
	            List<Data_Mapping__c> UpsertDataList = new List<Data_Mapping__c>();
	            List<Data_Mapping__c> deleteDataList = new List<Data_Mapping__c>();
	            Set<String> refTypeMappingDelete = new Set<String>();
	            Set<String> filterMappingDelete = new Set<String>();
	            ConstantsController.shouldDataMappingProcessed = true;
	            boolean recordPresent;
	
	            for (Data_Mapping__c dm : refTypeMappingRecords) {
	                
	                if (dm.Visible__c || dm.Required__c) {
	                    UpsertDataList.add(dm);
	                } else if (!dm.Visible__c && !dm.Required__c && dm.Id != null) {
	                    deleteDataList.add(dm);
	                }
	            }
	           
	            for (Data_Mapping__c dm : filterMappingRecords) {
	               
	                if (dm.Visible__c || dm.Required__c) {
	                    UpsertDataList.add(dm);
	                } else if (!dm.Visible__c && !dm.Required__c && dm.Id != null) {
	                    deleteDataList.add(dm);
	                }
	            }
	            
	            if (deleteDataList.size() > 0) {
	                delete deleteDataList;
	                Database.emptyRecycleBin( deleteDataList );
	            }
	            
	            for (Data_Mapping__c dm :  referenceLeadHeaderMap.values()) {
	                UpsertDataList.add(dm);
	            }
	            
	            if (UpsertDataList.size() > 0) {
	                upsert UpsertDataList;
	            }
	           
	            if (referenceLeadFieldList.size() > 0) {
	                upsert referenceLeadFieldList;
	            }
	                
	            List<Data_Mapping__c> datatoBeDeleted = [SELECT Name, Order__c, Id, Visible__c, Field_API_Name__c, Required__c FROM Data_Mapping__c 
	            												WHERE Object__c = :ConstantsController.REFERENCE_LEAD AND Referenceability_Type__c = null 
	            												AND Filter__c = null AND Field_API_Name__c = '' ORDER BY Order__c];
	                
	            if (datatoBeDeleted.size() > 0) {
	                delete datatoBeDeleted;
	            }
	            isEdit = false;
	        } catch (Exception e) {
	            Apexpages.addMessages(e);
	            Database.rollback(sp);
	        }
	        return null;
    	} else {
    		return null;
    	}
    }
    
    /**
     * Method to cancel
     */
    public pageReference cancelNominationSettings() {
        referenceLeadFieldList = [SELECT Name, Order__c, Id, Visible__c, Field_API_Name__c, Required__c FROM Data_Mapping__c 
        								WHERE Object__c = :ConstantsController.REFERENCE_LEAD ORDER BY Order__c];
        fetchAllDataForPro();
        isEdit = false;
        return null;
    }
    
    /**
     * Method to return Custom Setting  
     */
    public pageReference returnCustomSettings() {
        PageReference returnPage = new PageReference('/' + customSettingId);
        returnPage.setRedirect(true);
        return returnPage;
    }
    
    /**
     * Method to redirect to MultiSelectReferenceLeadFields
     */
    public pageReference redirectFieldPage() {
        PageReference redirectPage = new PageReference(Page.MultiSelectReferenceLeadFields.geturl() + '?customSettingId=' + customSettingId);
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
  	/**
     * Method to check Permissions
     */
    public static Boolean checkPermissions() { 
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	Boolean isDeletePermission = false;
    	Boolean isUpsertPermission = false; 
    	
    	fieldMap.put(UtilityController.appNamespace() + 'Data_Mapping__c', new Set<String> { 'Name',
            										UtilityController.appNamespace() + 'Referenceability_Type__c',
            										UtilityController.appNamespace() + 'Visible__c',
            										UtilityController.appNamespace() + 'Required__c',
            										UtilityController.appNamespace() + 'Object__c'});  
      
    	isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Data_Mapping__c'}); 
        
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);  
                 
        return (isUpsertPermission && isDeletePermission);  
    }
}