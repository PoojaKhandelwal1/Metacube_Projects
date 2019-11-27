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
 * Page :  Custom Setting->Filter Order and Basic Search
 * Description: Class handle Filter Order and Basic Search 
 * Last Modified By: Rajesh @Feb 7 2017
 */
public with sharing class FilterSettingController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    private String customSettingId;
    public Boolean isEdit { get; set; }
    public List<Data_Mapping__c> filterList { get; set; }
    public Custom_Settings__c cs { get; set; }
    private List<Data_Mapping__c> tempList;
    private Map<String, Label__c> labelMap;
    
    /**
     * Constructor
     */
    public FilterSettingController() {
        customSettingId = apexPages.currentPage().getParameters().get('customSettingId');
        /*Check permission for objects*/
        checkPermissions();
        isEdit = false;
        fetchData();
    }
    
    /**
     * Method to fetch data
     */
    private void fetchData() {
        
        if (checkPermissions()) {
            filterList = new List<Data_Mapping__c>();
            filterList.add(new Data_Mapping__c(Required__c = false, Label__c = 'Referenceability', Field_API_Name__c = 'Referenceability', Object__c = 'Filter'));
            filterList.add(new Data_Mapping__c(Required__c = false, Label__c = 'Content Language', Field_API_Name__c = 'Content Language', Object__c = 'Filter'));
            filterList.add(new Data_Mapping__c(Required__c = false, Label__c = 'Content Types', Field_API_Name__c = 'Content Types', Object__c = 'Filter'));
            labelMap = new Map <String, Label__c>();
            List<Label__c> labelList = [SELECT id, name, BasicSearchView__c, Filter_RefSearch_Visible__c FROM Label__c ORDER BY Name LIMIT :limits.getLimitQueryRows()];
            
            for (Label__c label : labelList) {
                labelMap.put(label.Id, label);
                filterList.add(new Data_Mapping__c(Filter_RefSearch_Visible__c = label.Filter_RefSearch_Visible__c, Label__c = label.Name, 
                                                    Field_API_Name__c = label.Id, Object__c = 'Filter', Visible__c = label.BasicSearchView__c));
            }
            
            for (Attribute_Mapping__c attM : [SELECT Id, field__c, Field_Api_Name__c, Filter_Label_Name__c FROM Attribute_Mapping__c WHERE Is_Related_Mapping__c = true 
                                            AND Object__c != 'Opportunity' and Related_Object__c != 'OpportunityLineItem']) {
                filterList.add(new Data_Mapping__c(Required__c = false, Label__c = attM.Filter_Label_Name__c, Field_API_Name__c = attM.Id, Object__c = 'Filter', 
                                From_Mapping__c = true));
            }
            tempList = new List<Data_Mapping__c>();
            tempList = [SELECT Name, Order__c, Id, Required__c, Filter_RefSearch_Visible__c, Label__c, Visible__c, Field_API_Name__c FROM Data_Mapping__c WHERE Object__c = 'Filter'
                            ORDER BY Order__c, Label__c];
            
            for (Data_Mapping__c dm : tempList) {
            
                for (integer index = 0; index < filterList.size(); index++) {
                    
                    if (filterList[index].Field_API_Name__c == dm.Field_API_Name__c) {
                        filterList[index].Order__c = dm.Order__c;
                        
                        if (filterList[index].From_Mapping__c || (filterList[index].Field_API_Name__c == 'Referenceability' 
                                                                || filterList[index].Field_API_Name__c == 'Content Language' 
                                                                || filterList[index].Field_API_Name__c == 'Content Types')) {
                            filterList[index].Visible__c = dm.Visible__c;
                            filterList[index].Filter_RefSearch_Visible__c = dm.Filter_RefSearch_Visible__c;
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Method to save the filter setting
     */
    public pageReference saveSettings() {
        try {
        	
            if (checkPermissions()) {
            	
	            if (tempList.size() > 0) {
	                ConstantsController.shouldDataMappingProcessed = true;
	                delete tempList;
	                Database.emptyRecycleBin(tempList);
	                tempList.clear();
	            }
	            
	            if (filterList.size() > 0) {
	                ConstantsController.shouldDataMappingProcessed = true;
	                upsert filterList;
	                
	                for (Data_Mapping__c dm : filterList) {
	                    
	                    if (labelMap != null && labelMap.containsKey(dm.Field_API_Name__c)) {
	                        labelMap.get(dm.Field_API_Name__c).BasicSearchView__c = dm.Visible__c;
	                        labelMap.get(dm.Field_API_Name__c).Filter_RefSearch_Visible__c = dm.Filter_RefSearch_Visible__c;
	                    }
	                }
	                
	                if (labelMap.size() > 0) {
	                    update labelMap.values();
	                }
	            }
	            fetchData();
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        isEdit = false;
        return null;
    }
    
    /**
     * Method to edit the filter setting
     */
    public pageReference editSettings() {
        isEdit = true;
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
     * Method to return Setting 
     */
    public pageReference returnSettings() {
        fetchData();
        isEdit = false;
        return null;
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions() { 
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	Boolean isDeletePermission = false;
    	Boolean isUpsertPermission = false; 
    	       		
        fieldMap.put(UtilityController.appNamespace() + 'Data_Mapping__c', new Set<String> { 
        										UtilityController.appNamespace() + 'Required__c',
        										UtilityController.appNamespace() + 'Label__c',
        										UtilityController.appNamespace() + 'Field_API_Name__c',
        										UtilityController.appNamespace() + 'Object__c',
        										UtilityController.appNamespace() + 'Filter_RefSearch_Visible__c',
        										UtilityController.appNamespace() + 'Visible__c',
        										UtilityController.appNamespace() + 'From_Mapping__c'}); 
        										
        fieldMap.put(UtilityController.appNamespace() + 'Label__c', new Set<String> { 
        										UtilityController.appNamespace() + 'BasicSearchView__c',
        										UtilityController.appNamespace() + 'Filter_RefSearch_Visible__c'}); 
        
    	isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Data_Mapping__c'}); 
        
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);           
        return (isUpsertPermission && isDeletePermission); 
    }
}