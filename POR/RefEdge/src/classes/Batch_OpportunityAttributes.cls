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
 * Class: Schedular_OpportunityAttribute
 * Description : This Batch called from Schedular_OpportunityAttribute to update all related Attributes of Contact Attribute mapping
 * if any picklist value is changed/deleted/added and all related Contact attributes are also updated
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_OpportunityAttributes implements Database.Batchable <sObject> , Database.stateful {
    /**
     * Properties and variables
     */
    private Map<Id, Attribute_Mapping__c> attmappings;
    private String soqlQuery;
    private Map<String, Set<String>> oppFieldValuesMap;
    private Map<String, Set<String>> oppProductFieldValuesMap;
    private Set<Id> deleteAttributes;
    private List<Attribute__c> newAttributes;

    /**
     * Constructor
     */
    global Batch_OpportunityAttributes() {
        Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get('Opportunity');
        Sobject objectName = targetType.newSObject();
        Schema.sObjectType sobjectType = objectName.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();

        Schema.SObjectType targetType1 = CRUDAndFLSCheckController.sObjectsMap.get('OpportunityLineItem');
        Sobject objectName1 = targetType1.newSObject();
        Schema.sObjectType sobjectType1 = objectName1.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobjectDescribe1 = sobjectType1.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> fieldMap2 = sobjectDescribe1.fields.getMap();
        
        oppFieldValuesMap = new Map<String, Set<String>>();
        oppProductFieldValuesMap = new Map<String, Set<String>>();
        Set<string> picklistValues = new Set<string>();
        
        //get all picklist values of opportunity object
        for (String fieldName: fieldMap.keyset()) {
            Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
            
            if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                picklistValues = new Set<string>();
                
                for (Schema.PicklistEntry value : fieldDesc.getPickListValues()) {
                    picklistValues.add(value.getValue());
                }
                oppFieldValuesMap.put(fieldDesc.getName(), picklistValues);
            }
        }
        
        //get all picklist values of opportunity line item object
        for (String fieldName : fieldMap2.keyset()) {
            Schema.DescribeFieldResult fieldDesc = fieldMap2.get(fieldName).getDescribe();
            
            if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                picklistValues = new Set<string>();
                
                for (Schema.PicklistEntry value : fieldDesc.getPickListValues()) {
                    picklistValues.add(value.getValue());
                }
                oppProductFieldValuesMap.put(fieldDesc.getName(), picklistValues);
            }
        }
        deleteAttributes = new Set<Id>();
        newAttributes = new List<Attribute__c>();
    }

    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        attmappings = new Map<Id, Attribute_Mapping__c>([select Is_Related_Mapping__c, Field_Api_Name__c, Auto_populate__c, Auto_add__c,
            Auto_Update__c, Auto_delete__c
            from Attribute_Mapping__c where object__c =: ConstantsController.OPPORTUNITY
            and Field_Api_Name__c != null and Field_Api_Name__c != 'Product2'
        ]);
        Set<Id> attMapIds = new Set<Id>();
        attMapIds.addAll(attmappings.keySet());
        soqlQuery =
            'select Id, name, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Auto_populate__c, (Select Id, Name From Attributes__r), Attribute_Mapping__r.Inheritable__c from Attribute__c where Attribute_Mapping__c In: attMapIds and level__c = 0';
        return Database.getQueryLocator(soqlQuery);
    }

    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List<Attribute__c> scope) {
        Map<String, Attribute__c> attributeMap = new Map<String, Attribute__c>();
        Set<String> childAttributeToFindLabel = new Set<String>();
        Map<string, string> mappingAttribute = new Map<String, string>();
        Map<string, string> mappingAttFilter = new Map<String, string>();
        
        for (Attribute__c Att : scope) {
            attributeMap.put(Att.Attribute_Mapping__r.Id, Att);
            
            if (att.Attributes__r.size() > 0) {
                childAttributeToFindLabel.add(att.Attributes__r.get(0).Id);
                mappingAttribute.put(att.Attributes__r.get(0).Id, att.Id);
            }
        }
        
        for (string attMapId : attributeMap.keySet()) {
            Attribute__c attObj = attributeMap.get(attMapId);
            Attribute_Mapping__c attMap = attmappings.get(attMapId);
            
            //if there is any related mapping 
            if (attMap.Is_Related_Mapping__c) {
                Set<string> pickListValues = new Set<string>();
                
                if (oppProductFieldValuesMap.containsKey(attMap.Field_Api_Name__c))
                    pickListValues.addAll(oppProductFieldValuesMap.get(attMap.Field_Api_Name__c));

                Set<string> attributes = new Set<string>();
                
                for (Attribute__c att : attObj.Attributes__r) {
                    
                    if (!pickListValues.contains(att.Name) && attMap.Auto_delete__c) {
                        deleteAttributes.add(att.Id);
                    }
                    attributes.add(att.Name);
                }
                
                for (string label : pickListValues) {
                    
                    if (!attributes.contains(label) && attMap.Auto_add__c) {
                        newAttributes.add(new Attribute__c(name = label, Parent__c = attObj.Id));
                    }
                }
            } else {
                Set<string> pickListValues = new Set<string>();
                
                if (oppFieldValuesMap.containsKey(attMap.Field_Api_Name__c))
                    pickListValues.addAll(oppFieldValuesMap.get(attMap.Field_Api_Name__c));
                Set<string> attributes = new Set<string>();
                
                for (Attribute__c att : attObj.Attributes__r) {
                    
                    if (!pickListValues.contains(att.Name) && attMap.Auto_delete__c) {
                        deleteAttributes.add(att.Id);
                    }
                    attributes.add(att.Name);
                }
                
                for (string label : pickListValues) {
                    
                    if (!attributes.contains(label) && attMap.Auto_add__c) {
                        newAttributes.add(new Attribute__c(name = label, Parent__c = attObj.Id));
                    }
                }
            }
        }
        
        if (childAttributeToFindLabel.size()> 0) {
            
            for (Attributes_Labels__c attLabel : [select label__c, Attribute__c from Attributes_Labels__c where Attribute__c In:
                    childAttributeToFindLabel
                ]) {
                
                if (mappingAttribute.containsKey(attLabel.Attribute__c))
                    mappingAttFilter.put(mappingAttribute.get(attLabel.Attribute__c), attLabel.label__c);
            }
        }
        List<Attribute__c> attToBeDeleted = [select Id from Attribute__c where Id In: deleteAttributes];
        
        //delete attributes which are removed from opportunity attribute mapping fields
        if (attToBeDeleted.size() > 0) {
            UtilityController.deleteAttributesInstance(deleteAttributes);
            database.delete(attToBeDeleted, false);
        }
        
        //insert new attributes for opportunity attribute mapping fields
        if (newAttributes.size()> 0) {
            database.insert(newAttributes, false);
            List<Attributes_Labels__c> attLabels = new List<Attributes_Labels__c>();
            
            for (Attribute__c att: newAttributes) {
                
                if (mappingAttFilter.containsKey(att.Parent__c))
                    attLabels.add(new Attributes_Labels__c(Attribute__c = att.Id, Label__c = mappingAttFilter.get(att.Parent__c)));
            }
            
            if (attLabels.size() > 0)
                database.insert(attLabels, false);
        }
    }

    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {}
}