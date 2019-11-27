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
 * Class: AttributeMappingTriggerHandler
 * Description : This Batch called from AttributeMappingTriggerHandler for Content Attribute update
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_AddAttributesToContent implements Database.Batchable < sObject > , Database.stateful {
    /**
     * Properties and variables
     */
    private string soqlQuery = '';
    private list < Attribute_Mapping__c > attMappingAssociatedToContent;
    private Map < String, Schema.SObjectField > fieldMap;
    /**
     * Constructor
     */
    global Batch_AddAttributesToContent() {
        Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Reference_Content__c'); //From the Object Api name retrieving the SObject
        Sobject objectName = targetType.newSObject();
        Schema.sObjectType sobjectType = objectName.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe(); //describe the sobject
        fieldMap = sobjectDescribe.fields.getMap();
        List < Schema.SObjectField > fldObjMapValues = fieldMap.values();
        attMappingAssociatedToContent = new list < Attribute_Mapping__c > ();
        
        for (Attribute_Mapping__c attM: [select Field_Api_Name__c, Inheritable__c, Auto_populate__c from Attribute_Mapping__c
                where Object__c =: ConstantsController.REFERENCE_CONTENT and Auto_populate__c = true and Is_Related_Mapping__c = false
            ]) {
            
            if (fieldMap.containsKey(attM.Field_Api_Name__c.tolowerCase())) {
                attMappingAssociatedToContent.add(attM);
            }
        }
        soqlQuery = 'SELECT ';
        
        for (Schema.SObjectField s: fldObjMapValues) {
            String theName = s.getDescribe().getName();
            // Continue building your dynamic query string
            soqlQuery += theName + ',';
        }
        soqlQuery = soqlQuery.subString(0, soqlQuery.length() - 1);
        soqlQuery += ' FROM Reference_Content__c';
        Decimal recordCount = 0;
        
        if (attMappingAssociatedToContent.size() > 0) {
            soqlQuery += ' where ';
            recordCount = 1;
            
            for (Attribute_Mapping__c attMap: attMappingAssociatedToContent) {
                soqlQuery += attMap.Field_Api_Name__c + ' !=null';
                
                if (recordCount < attMappingAssociatedToContent.size()) {
                    soqlQuery += ' Or ';
                    recordCount++;
                }
            }
        }
    }
    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(soqlQuery);
    }

    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List < Reference_Content__c > scope) {
        list < Content_Attribute__c > contentAttributes = new list < Content_Attribute__c > ();
        set < String > preventDuplicacy = new set < String > ();
        map < Id, map < Id, Content_Attribute__c >> contentAttributesAssociated = new map < Id, map < Id, Content_Attribute__c >> ();
        
        for (Reference_Content__c rc: scope) {
            contentAttributesAssociated.put(rc.Id, new map < Id, Content_Attribute__c > ());
        }
        
        for (Content_Attribute__c accAtt: [select name, Id, attribute__r.Name, Reference_Content__r.Id, Attribute__r.Id, Is_fromMapping__c from Content_Attribute__c where Reference_Content__c In:
                contentAttributesAssociated.keySet()
            ]) {
            contentAttributesAssociated.get(accAtt.Reference_Content__r.Id).put(accAtt.Attribute__r.Id, accAtt);
        }
        //query all the parent along with child attributes of the mapping
        list < Attribute__c > listAttribute = [select Id, name, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Auto_populate__c,
            (Select Id, Name From Attributes__r), Attribute_Mapping__r.Inheritable__c from Attribute__c where Attribute_Mapping__c In:
            attMappingAssociatedToContent and level__c = 0
        ];
        
        for (Attribute__c att: listAttribute) {
            
            for (Reference_Content__c acc: scope) {
                
                for (Attribute__c childAtt: att.Attributes__r) {
                    
                    if (acc.get(att.Attribute_Mapping__r.Field_Api_Name__c) != null) {
                        
                        for (String attStr: string.valueOf(acc.get(att.Attribute_Mapping__r.Field_Api_Name__c)).split(';')) {
                        	
                            if (attStr == childAtt.Name && !preventDuplicacy.contains(acc.Id + '' + childAtt.Id) && contentAttributesAssociated.containsKey(
                                    acc.Id) && !contentAttributesAssociated.get(acc.Id).containsKey(childAtt.Id)) {
                                contentAttributes.add(new Content_Attribute__c(Reference_Content__c = acc.Id, Attribute__c = childAtt.Id,
                                    Is_fromMapping__c = true));
                                preventDuplicacy.add(acc.Id + '' + childAtt.Id);
                            }
                        }
                    }
                }
            }
        }
        
        if (contentAttributes.size() > 0) {
            database.insert(contentAttributes, false);
        }
    }
    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {}
}