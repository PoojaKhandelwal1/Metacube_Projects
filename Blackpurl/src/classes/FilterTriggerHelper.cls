/**
 * Author: Hitesh Gupta
 * Since: March 30, 2016
 * Name: FilterTriggerHelper
 * Description: Helper class for FilterTrigger
**/
public with sharing class FilterTriggerHelper {
	
	public static List<Filter__c> FilterNewList = new List<Filter__c>();
    public static List<Filter__c> FilterOldList = new List<Filter__c>();
    public static Map<Id, Filter__c> FilterNewMap = new Map<Id, Filter__c>();
    public static Map<Id, Filter__c> FilterOldMap = new Map<Id, Filter__c>();
    
    public static Boolean runTrigger = true;
    
    
    /**
     * Name: hashCodeCalculation
     * Desc: Method calculate the hash code based on filter JSON
     * @param: 
     * @return: 
    **/  
    public static void hashCodeCalculation() {
    	for(Filter__c filterObj : FilterNewList){
			String hashCodeString = ((filterObj.Field_Filter_Json__c == null) ? '' : filterObj.Field_Filter_Json__c);
			/*
									+ ((filterObj.Summary_Field_Json__c == null) ? '' : filterObj.Summary_Field_Json__c) 
									+ ((filterObj.Export_Field_Json__c == null) ? '' : filterObj.Export_Field_Json__c) 
									+ ((filterObj.Export_File_Format__c == null) ? '' : filterObj.Export_File_Format__c)
									+ ((filterObj.Export_GroupBy_Field__c == null) ? '' : filterObj.Export_GroupBy_Field__c);
			*/
			if(hashCodeString != null && hashCodeString.trim().length() != 0) {
				//hashCodeString += filterObj.Show_All_Records__c;
				
				filterObj.Field_Filter_JSON_Hash_Code__c = hashCodeString.hashCode();
			} else {
				filterObj.Field_Filter_JSON_Hash_Code__c = null;
			}
    	}
    }

	/* Start: Added by Ashish Garg #152 28/09/2016 */
    /**
     * Name: ProcessIfPreviewReport
     * Desc: Method to process Preview Report filters with matching filter label in actual
     * @param: 
     * @return: 
    **/  
    public static void ProcessIfPreviewReport() {
    	List<decimal> validHashCodes = new List<decimal>();
    	for(Filter__c filterObj : FilterNewList){
    		if(filterObj.Filter_Label__c == 'Preview Report') {
				validHashCodes.add(filterObj.Field_Filter_JSON_Hash_Code__c);
    		}
    	}

    	if(validHashCodes.size() > 0) {
    		List<Filter__c> existingFilters = [SELECT Id, 
    												  Filter_Label__c,
    												  Field_Filter_JSON_Hash_Code__c
    												  FROM Filter__c 
    												  WHERE Field_Filter_JSON_Hash_Code__c IN: validHashCodes
    												  AND Filter_Label__c != 'Preview Report'
    												];
    		if(existingFilters.size() > 0) {
    			Map<decimal, String> hashCodeToLabelMap = new Map<decimal, String>();
    			for(Filter__c existingFilter : existingFilters) {
    				hashCodeToLabelMap.put(existingFilter.Field_Filter_JSON_Hash_Code__c, existingFilter.Filter_Label__c);
    			}

    			for(Filter__c newFilterRec : FilterNewList) {
    				if(hashCodeToLabelMap.containsKey(newFilterRec.Field_Filter_JSON_Hash_Code__c)) {
    					newFilterRec.Filter_Label__c = hashCodeToLabelMap.get(newFilterRec.Field_Filter_JSON_Hash_Code__c);
    				}
    			} 
    		}
    	}
    }
    /* End: Added by Ashish Garg #152 28/09/2016 */
}