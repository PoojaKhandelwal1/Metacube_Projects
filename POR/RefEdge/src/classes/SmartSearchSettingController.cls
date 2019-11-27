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
 * Page : Custom Setting->Smart Search Settings 
 * Description : Class used handle Smart search settings 
 * Last Modified By: Rajesh @Feb 9 2017
 */
public with sharing class SmartSearchSettingController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    private String customSettingId;
    public Boolean isEdit { get; set; }
    public Boolean isBatchCompleted { get; set; }
    public List<Data_Mapping__c> filterList { get; set; }
    public Custom_Settings__c cs { get; set; }
    private List<Data_Mapping__c> tempList;
    public Boolean isAttMapping { get; set; }
    private List<Attribute__c> rootLevelAttributes;
    
    /**
     * Constructor
     */
    public SmartSearchSettingController() {
        customSettingId = apexPages.currentPage().getParameters().get('customSettingId');
        //check premissions for objects
        checkPermissions();
        isEdit = false;
        isAttMapping = false;
        isBatchCompleted = false;
        rootLevelAttributes = new List<Attribute__c>();
        cs = UtilityController.getCustomSettings();
        makeFilterList();
    }
    
    /**
     * Method to get all data
     */
    private void makeFilterList() {
        if (checkPermissions()) {

            filterList = new List<Data_Mapping__c>();
            filterList.add(new Data_Mapping__c(Label__c = 'Referenceability', Field_API_Name__c = 'Referenceability', Object__c = 'SmartSearchFilter'));
            filterList.add(new Data_Mapping__c(Label__c = 'Content Language', Field_API_Name__c = 'Content Language', Object__c = 'SmartSearchFilter'));
            filterList.add(new Data_Mapping__c(Label__c = 'Content Types', Field_API_Name__c = 'Content Types', Object__c = 'SmartSearchFilter'));
    
            for (Label__c label : [SELECT id, name FROM Label__c ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
                filterList.add(new Data_Mapping__c(Label__c = label.Name, Field_API_Name__c = label.Id, Object__c = 'SmartSearchFilter'));
            }
            tempList = [SELECT Name, Order__c, Id, Required__c, Visible__c, Label__c, Program_Coverage__c, Ref_Search_Coverage__c, Field_API_Name__c FROM Data_Mapping__c 
                                    WHERE Object__c = 'SmartSearchFilter' ORDER BY Order__c, Label__c LIMIT :limits.getLimitQueryRows()
            ];
            
            for (Data_Mapping__c dm : tempList) {
                
                for (integer index = 0; index < filterList.size(); index++) {
                    
                    if (filterList[index].Field_API_Name__c == dm.Field_API_Name__c) {
                        filterList[index].Order__c = dm.Order__c;
                        filterList[index].Program_Coverage__c = dm.Program_Coverage__c;
                        filterList[index].Ref_Search_Coverage__c = dm.Ref_Search_Coverage__c;
                        filterList[index].Visible__c = dm.Visible__c;
                    }
                }
            }
            Set<String> attMappingsAccount = new Set<String>();
            Set<Id> labelIDset = new Set<Id>();
            
            for (Attribute_Mapping__c attMapping : [SELECT Object__c, Related_Object__c,Is_Related_Mapping__c, Id, Filter_Label_Name__c, Field_Api_Name__c, Field__c, 
                                                    Attribute_Name__c FROM Attribute_Mapping__c WHERE (Object__c = :ConstantsController.ACCOUNT OR Object__c = :ConstantsController.CONTACT 
                                                    OR Object__c = :ConstantsController.OPPORTUNITY) LIMIT :limits.getLimitQueryRows()]) {
                
                if (cs.Apply_Opportunity_Stage_Filter__c && attMapping.Object__c == ConstantsController.OPPORTUNITY && attMapping.Is_Related_Mapping__c == false) {
                    attMappingsAccount.add(attMapping.Id);
                } else if (cs.Include_Opp_Attributes_in_RefSearch__c && attMapping.Object__c == ConstantsController.OPPORTUNITY && attMapping.Is_Related_Mapping__c == false) {
                    attMappingsAccount.add(attMapping.Id);
                } else if (attMapping.Object__c == ConstantsController.OPPORTUNITY && attMapping.Is_Related_Mapping__c == true && attMapping.Related_Object__c == 'OpportunityLineItem') {
                    attMappingsAccount.add(attMapping.Id);
                } else if (attMapping.Object__c == ConstantsController.ACCOUNT && attMapping.Is_Related_Mapping__c == false){
                    attMappingsAccount.add(attMapping.Id);
                } else if (attMapping.Object__c == ConstantsController.CONTACT && attMapping.Is_Related_Mapping__c == false){
                    attMappingsAccount.add(attMapping.Id);
                }
            }
            Map<String, String> attLabelMap = new Map<String, String>();
            rootLevelAttributes = new List<Attribute__c>();
            
            if (attMappingsAccount != null && attMappingsAccount.size() > 0) {
                isAttMapping = true;
                rootLevelAttributes = [SELECT Level__c, Name, Attribute_Mapping__c, (SELECT Id, Name, Level__c FROM Attributes__r WHERE Level__c = 1) 
                                        FROM Attribute__c WHERE Level__c = 0 AND Attribute_Mapping__c IN :attMappingsAccount LIMIT :limits.getLimitQueryRows()];
                
                for (Attribute__c att : rootLevelAttributes) {
                    
                    for (Attribute__c att1 : att.Attributes__r) {
                        labelIDset.add(att1.Id);
                        break;
                    }
                }
            }
            
            for (Attributes_Labels__c attLabel : [SELECT Id, Attribute__c, Attribute__r.Parent__c, Label__c FROM Attributes_Labels__c WHERE Attribute__c IN :labelIDset]) {
                attLabelMap.put(attLabel.Attribute__r.Parent__c, attLabel.Label__c);
            }
            
            for (Attribute__c root : rootLevelAttributes) {
                
                for (Data_Mapping__c dm : filterList) {
                    
                    if (dm.Field_API_Name__c == attLabelMap.get(root.Id)) {
                        dm.Required__c = true;
                    }
                }
            }
        }
    }
    
    /**
     * Method to save the setting
     */
    public pageReference saveSettings() {
        Savepoint sp = Database.setSavepoint();
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
	            }
            } else {
            	return null;
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
            return null;
        }
        isEdit = false;
        return null;
    }
    
    /**
     * Method to edit the setting
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
     * Method to cancel the process
     */
    public pageReference returnSettings() {
        makeFilterList();
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
        										UtilityController.appNamespace() + 'Order__c',
        										UtilityController.appNamespace() + 'Program_Coverage__c',
        										UtilityController.appNamespace() + 'Ref_Search_Coverage__c',
        										UtilityController.appNamespace() + 'Visible__c'});  
        
    	isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Data_Mapping__c'}); 
        
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);           
        return (isUpsertPermission && isDeletePermission); 
    }
}