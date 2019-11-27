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
 * Trigger: filters 
 * Description:TriggerHandler for filters
 * Modified by: Rajesh @13 Dec 2017
 */
public with sharing class FilterTriggerHandler {
    /**
     * Properties and variables
     */
    public static List<Label__c> newLabels = new List<Label__c>();
    public static List<Label__c> oldLabels = new List<Label__c>();
    public static Map<Id, Label__c> newLabelMap = new Map<Id, Label__c>();
    public static Map<Id, Label__c> oldLabelMap = new Map<Id, Label__c>();
    
    /**
     * Method called on before insert of Filter
     */
    public static void onBeforeInsert() { 
        List<Label__c> filters = [SELECT Filter_no__c, Adv_Routing_Group__c FROM Label__c WHERE Filter_no__c != null 
        														ORDER BY Filter_no__c DESC];
        Integer count;
        
        if (filters.size() > 0) {
        	
            if (filters[0].Filter_no__c != null) {
                count = Integer.valueOf(filters[0].Filter_no__c) + 1;
            } else {
                count = 1;
            }
        } else {
            count = 1;
        }
        
        //re #436
        for (Label__c filter : newLabels) {
            filter.Filter_no__c = count; 
            
         	for (Label__c lst : filters) { 
    			
			 	if (lst.Adv_Routing_Group__c != null && lst.Adv_Routing_Group__c == filter.Adv_Routing_Group__c) {
			 	 	Trigger.new[0].addError(System.Label.Associated_to_Filter);
			 	}
			} 
            count++;
        }
    }
    /**
     * Method called on before update of Filter
     */
    public static void onBeforeUpdate() {
    	List<Label__c> filters = [SELECT Filter_no__c, Adv_Routing_Group__c FROM Label__c WHERE Filter_no__c != null 
    									 ORDER BY Filter_no__c DESC];
    	
    	for (Label__c label : newLabels) {
    		
    		if (!oldLabelMap.get(label.Id).BasicSearchView__c && label.BasicSearchView__c) {
    			label.Filter_RefSearch_Visible__c = true;
    		}
    		
    		if (oldLabelMap.get(label.Id).Filter_RefSearch_Visible__c && label.BasicSearchView__c && !label.Filter_RefSearch_Visible__c) {
    			label.BasicSearchView__c = false;
    		}
    		
    		//re #436
			for (Label__c lst : filters) { 
    			 
		 		if (label.Adv_Routing_Group__c != null && label.Adv_Routing_Group__c == lst.Adv_Routing_Group__c && label.Id!=lst.Id) {
			 		Trigger.new[0].addError(System.Label.Associated_to_Filter);
    			}
			} 
    	}
    }
    
    /**
     * Method called on after update of Filter
     */
    public static void onAfterUpdate() {
    	Set<String> labelIds = new Set<String>();
    	Set<String> labelNames = new Set<String>();
    	 
    	for (Label__c label : newLabels) {
    		
    		if (newLabelMap.get(label.Id).BasicSearchView__c != oldLabelMap.get(label.Id).BasicSearchView__c 
    								|| newLabelMap.get(label.Id).Filter_RefSearch_Visible__c != oldLabelMap.get(label.Id).Filter_RefSearch_Visible__c ) {    								 
    			labelIds.add(label.Id);
    		}
    		
    		if (newLabelMap.get(label.Id).Name != oldLabelMap.get(label.Id).Name) {
    			labelNames.add(label.Id);
    		}
    	}
    	 //re #731 ISSUE - R20.26 - GE – changing filter names does not change the name in RefSearch        
    	List<Data_Mapping__c> tempList = [SELECT Name, Order__c, Id, Required__c, Filter_RefSearch_Visible__c, Label__c, Visible__c, Field_API_Name__c, Filter__c
    								FROM Data_Mapping__c WHERE (Object__c = 'Filter' OR Object__c = 'Reference Lead') 
    								AND (Field_API_Name__c IN :labelIds OR Field_API_Name__c IN :labelNames  OR Filter__c IN :labelNames) 
    								ORDER BY Order__c, Label__c ];
       
        for (Data_Mapping__c dm : tempList) {  
        	
        	if (dm.Field_API_Name__c != null && dm.Field_API_Name__c != '') { 
        		
	        	if (labelIds.Contains(dm.Field_API_Name__c)) {
		        	dm.Visible__c = newLabelMap.get(dm.Field_API_Name__c).BasicSearchView__c;
		        	dm.Filter_RefSearch_Visible__c = newLabelMap.get(dm.Field_API_Name__c).Filter_RefSearch_Visible__c; 
	        	}
	        	
	        	if (labelNames.Contains(dm.Field_API_Name__c)) {
	    			dm.Label__c = newLabelMap.get(dm.Field_API_Name__c).Name;  
	        	}
        	} else if (dm.Filter__c != null && labelNames.Contains(dm.Filter__c)){
        		dm.Name = newLabelMap.get(dm.Filter__c).Name;
        	}
        }
        
        if (tempList.size() > 0) {
        	ConstantsController.shouldDataMappingProcessed = true;
        	update tempList;
        } 
    }
    
    /**
     * Method called on before delete of Filter
     */
    public static void onBeforeDelete() {
        
        for (Label__c label: [SELECT(SELECT Id FROM Reference_Type_Mappings__r), (SELECT Id FROM Reference_Request_Labels__r), 
        												(SELECT Id FROM Nomination_Labels__r) 
        												FROM Label__c l WHERE ID IN: oldLabelMap.keySet()]) {
           
            for (Reference_Type_Mapping__c rtm: label.Reference_Type_Mappings__r) {
                ConstantsController.rtMIds.add(rtm.Id);
            }
            
            for (Reference_Request_Label__c rtm: label.Reference_Request_Labels__r) {
                ConstantsController.RRLIds.add(rtm.Id);
            }
            
            for (Nomination_Label__c rtm: label.Nomination_Labels__r) {
                ConstantsController.NMLIds.add(rtm.Id);
            }
        }
        Map<Id, Data_Mapping__c> dataMappings = new Map<Id, Data_Mapping__c> ([SELECT Id, Field_API_Name__c FROM Data_Mapping__c WHERE ((Object__c = 'Filter'
            OR Object__c = 'SmartSearchFilter' OR (Object__c = :ConstantsController.REFERENCE_LEAD AND Filter__c IN :oldLabelMap.keySet())) 
            AND Field_API_Name__c IN: oldLabelMap.keySet()) OR (Object__c = :ConstantsController.DEPENDENT_FILTERS AND (Label__c IN :oldLabelMap.keySet() OR Field_API_Name__c IN :oldLabelMap.keySet()))]);
        
        if (dataMappings.size() > 0) {
            ConstantsController.labelIds = dataMappings.keySet();
        }
    }
    /**
     * Method called on after delete of Filter
     */
    public static void onAfterDelete() {
        
        if (ConstantsController.rtMIds != null && ConstantsController.rtMIds.size() > 0) {
            List<Reference_Type_Mapping__c> deleteMappingList = [SELECT Id FROM Reference_Type_Mapping__c WHERE Id In: ConstantsController.rtMIds];
            
            if (deleteMappingList != null && deleteMappingList.size() > 0) {
                delete deleteMappingList;
            }
        }
        
        if (ConstantsController.RRLIds != null && ConstantsController.RRLIds.size() > 0) {
            List<Reference_Request_Label__c> deleteMappingList = [SELECT Id FROM Reference_Request_Label__c WHERE Id In: ConstantsController.RRLIds];
            
            if (deleteMappingList != null && deleteMappingList.size() > 0) {
                delete deleteMappingList;
            }
        }
        
        if (ConstantsController.NMLIds != null && ConstantsController.NMLIds.size() > 0) {
            List<Nomination_Label__c> deleteMappingList = [SELECT Id FROM Nomination_Label__c WHERE Id In: ConstantsController.NMLIds];
            
            if (deleteMappingList != null && deleteMappingList.size() > 0) {
                delete deleteMappingList;
            }
        }
        
        if (ConstantsController.labelIds != null && ConstantsController.labelIds.size() > 0) {
            List<Data_Mapping__c> deleteMappingList = [SELECT Id FROM Data_Mapping__c WHERE Id In: ConstantsController.labelIds];
            
            if (deleteMappingList != null && deleteMappingList.size() > 0) {
                ConstantsController.shouldDataMappingProcessed = true;
                delete deleteMappingList;
                Database.emptyRecycleBin( deleteMappingList );
            }
        }
    }

}