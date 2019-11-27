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
 * VF Page: NominationSettings.page
 * Description: controller for editing the fields displayed on the nomination form page
 * Last modified by: Gaurav Saini (13 June, 2017) for #732
 */
public with sharing class NominationSettingsController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    private String customSettingId;
    public List<Referenceability_Type__c> refTypes { get; set; }
    public List<Label__c> labels { get; set; }
    public Boolean isEdit { get; set; }
    public Map<String, Data_Mapping__c> nominationHeaderMap { get; set; }
    public List<Data_Mapping__c> nominationFieldList { get; set; }
    private List<Data_Mapping__c> mappingToBeDeleted;
    public Custom_Settings__c cs { get; set; }
    public List<String> HeaderList { get; set; }
    public Map<String, String> HeaderListMap { get; set; }
    public String filterOrder { get; set; }
    public List<Data_Mapping__c> nominationRefTypesMapping { get; set; }
    private Set<String> mappingPresent = new Set<String>();
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Referenceability_Type__c', new Set<String>{});
        fieldMap.put(UtilityController.appNamespace() + 'Label__c',
							new Set<String>{UtilityController.appNamespace() + 'Nomination_Filter_Order__c'});
        Boolean isUpdatePermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        fieldMap.clear();
        fieldMap.put(UtilityController.appNamespace() + 'Data_Mapping__c', new Set<String>{});
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
        Boolean isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String>{UtilityController.appNamespace() + 'Data_Mapping__c'});
        return (isUpdatePermission && isUpsertPermission && isDeletePermission);
    }
    
    /**
     * Constructor
     */
    public NominationSettingsController() {
    	nominationRefTypesMapping = new List<Data_Mapping__c>(); 
        checkPermissions();
        customSettingId = apexPages.currentPage().getParameters().get('customSettingId');
        isEdit = false;
        filterOrder = '';
        nominationFieldList = [SELECT Name, Order__c, Id, Visible__c, Field_API_Name__c, Required__c
        						FROM Data_Mapping__c
        						WHERE Object__c = :ConstantsController.NOMINATION
        						ORDER BY Order__c];
        fetchAllDataForPro();
    }
    
    /**
     * Method to setup Data for PRO Edition
     */
    private void fetchAllDataForPro() { 
    	/* re #1114 - For Nomination setting page, we are getting those referenceability type from data mapping object which visible in Referenceability Type object.
    	   In previous system we were getting referenceabilities from Referenceability Type object	*/
        Set<Id> refIds = new Set<Id>();  
        refTypes = [SELECT Name, Id, Visible__c FROM Referenceability_Type__c 
        							WHERE Visible__c = true AND Sales_Reward__c = false  ORDER BY Name LIMIT :limits.getLimitQueryRows()];
		
		for (Referenceability_Type__c rt : refTypes) {
			refIds.add(rt.Id);
		}
         				
        for (Data_Mapping__c dm : [SELECT Name, Order__c, Referenceability_Type__c, Referenceability_Type__r.Name, Filter__c, Filter__r.Name, Id, 
        							Visible__c, Field_API_Name__c, Required__c FROM Data_Mapping__c WHERE Object__c = :ConstantsController.NOMINATION_REFERENCEABILITY 
        							AND Referenceability_Type__c != null AND Referenceability_Type__c IN :refIds LIMIT :limits.getLimitQueryRows()]) { 
        								 
                nominationRefTypesMapping.add(dm);  
                mappingPresent.add(dm.Referenceability_Type__c);
        }
        
        for (Referenceability_Type__c rt : refTypes) {
           
            if (!mappingPresent.contains(rt.Id)) {
                nominationRefTypesMapping.add(new Data_Mapping__c(Name = rt.Name, Referenceability_Type__c = rt.Id, Visible__c = false, 
                									 Object__c = ConstantsController.NOMINATION_REFERENCEABILITY));
            }
        }
        
        labels = new List<Label__c> ();
        List<Decimal> indexList = new List<Decimal>();
        
        for (Label__c lb : [SELECT Name, Id, Visible__c, Nomination_Filter_Order__c, Required__c,
        					(SELECT Id, Name FROM Attributes_Labels__r LIMIT 1)
        					FROM Label__c
        					ORDER BY Name
        					LIMIT :limits.getLimitQueryRows()]) {
        	
            if (lb.Attributes_Labels__r.size() > 0) {
            	
                if (lb.Nomination_Filter_Order__c != null) {
                    indexList.add(lb.Nomination_Filter_Order__c);
                }
                labels.add(lb);
            }
        }
        indexList.sort();
        Decimal index = indexList.size();
        Map<Decimal, Decimal> indexMap = new Map<Decimal, Decimal>();
        
        for (Integer orderNo = 0; orderNo < indexList.size(); orderNo++) {
            indexMap.put(indexList.get(orderNo), orderNo + 1);
        }
        
        for (Label__c lb : labels) {
        	
            if (indexMap.containsKey(lb.Nomination_Filter_Order__c)) {
                lb.Nomination_Filter_Order__c = indexMap.get(lb.Nomination_Filter_Order__c);
            } else {
                lb.Nomination_Filter_Order__c = ++index;
            }
        }
        HeaderList = new List<String> ();
        HeaderListMap = new Map<String, String> ();
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
        nominationHeaderMap = new Map<String, Data_Mapping__c> ();
        
        for (Integer i = 0; i < HeaderList.size(); i++) {
            nominationHeaderMap.put(HeaderList.get(i), new Data_Mapping__c(Name = HeaderList.get(i), Order__c = i + 1,
            															Object__c = ConstantsController.NOMINATION_HEADER));
        }
        mappingToBeDeleted = new List<Data_Mapping__c> ();
        
        for (Data_Mapping__c field : [SELECT Name, Id, Visible__c, Required__c, Field_API_Name__c, Order__c
        								FROM Data_Mapping__c
        								WHERE Object__c = :ConstantsController.NOMINATION_HEADER
        								ORDER BY lastModifiedDate DESC
        								LIMIT 6]) {
        	
            if (nominationHeaderMap.containsKey(field.Name)) {
                nominationHeaderMap.put(field.Name, field);
			} else {
                mappingToBeDeleted.add(field);
            }
		}
    }
    
    /**
     * Method to edit Nomination Settings
     */
    public pageReference editNominationSettings() {
        isEdit = true;
        return null;
    }
    
    /**
     * Method to save Nomination Settings
     */
    public pageReference saveNominationSettings() {
    	
    	if (checkPermissions()) {
	        Savepoint sp = Database.setSavepoint();
	        
	        try {
	            List<Data_Mapping__c> dataList;
	            List<Data_Mapping__c> upsertDataList = new List<Data_Mapping__c>();
	            List<Data_Mapping__c> deleteDataList = new List<Data_Mapping__c>();
	            
	            ConstantsController.shouldDataMappingProcessed = true;
	            
	            if (mappingToBeDeleted.size() > 0) {
	                delete mappingToBeDeleted;
	                Database.emptyRecycleBin( mappingToBeDeleted );   
	                mappingToBeDeleted.clear();
	            }
	            
	           
             	for (Data_Mapping__c dm : nominationRefTypesMapping) {
	               
	                if (dm.Visible__c) {
	                    upsertDataList.add(dm);
	                } else if (!dm.Visible__c && dm.Id != null) {  
	                    deleteDataList.add(dm);
	                }
	            }
	            
	            if (deleteDataList.size() > 0) {  
	                delete deleteDataList;
	                Database.emptyRecycleBin( deleteDataList );
	            }
	            
	            if (upsertDataList.size() > 0) {
	                upsert upsertDataList;
	            }
	            
	            if (labels.size() > 0) {
	                update labels;
	            }
	            dataList = nominationHeaderMap.values();
	            
	            if (dataList.size() > 0) {
	                upsert dataList;
	            }
	            
	            if (nominationFieldList.size() > 0) {
	                upsert nominationFieldList;
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
     * Method to cancel Nomination setting
     */
    public pageReference cancelNominationSettings() {
        nominationFieldList = [SELECT Name, Order__c, Id, Visible__c, Field_API_Name__c, Required__c
        						FROM Data_Mapping__c
        						WHERE Object__c = :ConstantsController.NOMINATION
        						ORDER BY Order__c];
        fetchAllDataForPro();
        isEdit = false;
        return null;
    }
    
    /**
     * Method to return custom setting
     */
    public pageReference returnCustomSettings() {
        PageReference returnPage = new PageReference('/' + customSettingId);
        returnPage.setRedirect(true);
        return returnPage;
    }
    
    /**
     * Method to redirect to MultiSelectNominationFields
     */
    public pageReference redirectFieldPage() {
        PageReference redirectPage = new PageReference(Page.MultiSelectNominationFields.geturl()
        													+ '?customSettingId=' + customSettingId);
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
    /**
     * Method to save Filter order
     */
    public void saveFilterOrder() {
    	
        if (filterOrder != '') {
            List<String> filterOrders = filterOrder.split(',');
            
            if (filterOrders.size() == 2) {
            	
                for (Label__c label : labels) {
                	
                    if (label.Id == filterOrders[0].split('_')[0]) {
                        label.Nomination_Filter_Order__c = Integer.valueOf(filterOrders[1].split('_')[1]);
                    } else if (label.Id == filterOrders[1].split('_')[0]) {
                        label.Nomination_Filter_Order__c = Integer.valueOf(filterOrders[0].split('_')[1]);
                    }
                }
            }
        }
    }
}