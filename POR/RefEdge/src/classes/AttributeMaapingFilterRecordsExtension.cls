/**
 * ReferenceEdge
 *
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc. - test commit
 * @website : www.point-of-reference.com
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED "AS-----IS" BY POINT OF REFERENCE ("POR"),
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
 * VF Page: AttributeMaapingFilterRecords 
 * Description: controller for inline page on Attribute Mapping detail page to display
 *              all the Filter records for Acctribute Maaping
 * Last modified by: Pooja Khandelwal (31 May, 2019) 
 */
public with sharing class AttributeMaapingFilterRecordsExtension extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public List<FilterCriteriaWrapper> FilterCriterianList { get; set; }
    
    /**
     * Constructor
     */
    public AttributeMaapingFilterRecordsExtension(ApexPages.standardController attributeMappingController) {
    	Id attributeMappingId = attributeMappingController.getId(); //Attribute Mapping Detail page Id
        
        this.FilterCriterianList = new List<FilterCriteriaWrapper>();
        
        for (User_Mapping__c userMapping : [SELECT Id, Field_API_Name__c, Default_Value__c, From_Mapping__c FROM User_Mapping__c WHERE 
        							Process__c = 'AttMappingFilters' AND Label__c =: attributeMappingId ORDER BY Order__c Asc]) {
            FilterCriterianList.add(new FilterCriteriaWrapper(userMapping));
        }
    }
    
    public class FilterCriteriaWrapper {
    	public String FieldValue { get; set; }
        public String FieldApiName { get; set; }
        public String FieldLabel { get; set; }
        public String FieldDataType { get; set; }
        public String Operator { get; set; }
        
        public FilterCriteriaWrapper(User_Mapping__c userMapping) {
        	this.FieldValue = userMapping.Default_Value__c != null ? userMapping.Default_Value__c : '';
        	this.FieldApiName = userMapping.Field_API_Name__c.split('::')[0];
        	this.FieldLabel = userMapping.Field_API_Name__c.split('::')[1];
        	this.FieldDataType = userMapping.Field_API_Name__c.split('::')[2];
        	this.Operator = userMapping.Field_API_Name__c.split('::')[3];
        }
    }
}