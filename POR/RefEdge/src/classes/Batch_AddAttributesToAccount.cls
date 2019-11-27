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
* Description : This Batch called from AttributeMappingTriggerHandler for Account Attribute update
* Modified by: Rekha Jangir @Nov/16/2016
*/
global with sharing class Batch_AddAttributesToAccount implements Database.Batchable < sObject > , Database.stateful {
    /**
     * Properties and variables
     */
    private string soqlQuery = '';
    private list < Attribute_Mapping__c > attMappingAssociatedToContent;
    private Map < String, Schema.SObjectField > fieldMap;
    /**
     * Constructor
     */
    global Batch_AddAttributesToAccount() {
        fieldMap = schema.SObjectType.Account.fields.getMap();
        List < Schema.SObjectField > fldObjMapValues = fieldMap.values();
        attMappingAssociatedToContent = new list < Attribute_Mapping__c > ();
        
        for (Attribute_Mapping__c attM: [select Field_Api_Name__c, Inheritable__c, Auto_populate__c from Attribute_Mapping__c
                where Object__c =: ConstantsController.ACCOUNT and Auto_populate__c = true and Is_Related_Mapping__c = false
            ]) {
            	
            if (fieldMap.containsKey(attM.Field_Api_Name__c.tolowerCase())) {
                attMappingAssociatedToContent.add(attM);
            }
        }
        soqlQuery = 'SELECT ';

        for (Schema.SObjectField s: fldObjMapValues) {
            Schema.DescribeFieldResult fieldDesc = s.getDescribe();
            
            if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                String theName = fieldDesc.getName();
                // Continue building your dynamic query string
                soqlQuery += theName + ',';
            }

        }
        soqlQuery = soqlQuery.subString(0, soqlQuery.length() - 1);
        soqlQuery += ',(select Id,Is_Referenceable__c,Reference_Program_Candidate__c from Reference_Basic_Informations__r where Generic_Account__c = false AND contact__c = null ) FROM Account';
        Decimal recordCount = 0;
        
        if (attMappingAssociatedToContent.size() > 0) {
            soqlQuery += ' where ';
            recordCount = 1;
            
            for (Attribute_Mapping__c attMap: attMappingAssociatedToContent) {
                soqlQuery += attMap.Field_Api_Name__c + ' != null';
                
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
    global void execute(Database.BatchableContext BC, List < Account > scope) {
        list < Account_Attribute__c > accountAttributes = new list < Account_Attribute__c > ();
        set < String > preventDuplicacy = new set < String > ();
        map < Id, map < Id, Account_Attribute__c >> accountAttributesAssociated = new map < Id, map < Id, Account_Attribute__c >> ();
        
        for (Account acc: scope) {
            accountAttributesAssociated.put(acc.Id, new map < Id, Account_Attribute__c > ());
        }
        
        for (Account_Attribute__c conAtt: [select name, Id, attribute__r.Name, account__r.Id, Attribute__r.Id, Is_fromMapping__c, Inheritable__c from Account_Attribute__c where account__c In:
                accountAttributesAssociated.keySet() and Contact__c = null and Reference_Content__c = null
            ]) {
            accountAttributesAssociated.get(conAtt.account__r.Id).put(conAtt.Attribute__r.Id, conAtt);
        }
        //query all the parent along with child attributes of the mapping
        list < Attribute__c > listAttribute = [select Id, name, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Auto_populate__c,
            (Select Id, Name From Attributes__r), Attribute_Mapping__r.Inheritable__c from Attribute__c where Attribute_Mapping__c In:
            attMappingAssociatedToContent and level__c = 0
        ];
        
        for (Attribute__c att: listAttribute) {
            
            for (Account acc: scope) {
                
                if (acc.Reference_Basic_Informations__r.size() > 0 && (acc.Reference_Basic_Informations__r[0].Is_Referenceable__c || acc.Reference_Basic_Informations__r[
                        0].Reference_Program_Candidate__c)) {
                    
                    for (Attribute__c childAtt: att.Attributes__r) {
                        
                        if (acc.get(att.Attribute_Mapping__r.Field_Api_Name__c) != null) {
                            
                            for (String attStr: string.valueOf(acc.get(att.Attribute_Mapping__r.Field_Api_Name__c)).split(';')) {
                                
                                if (attStr == childAtt.Name && !preventDuplicacy.contains(acc.Id + '' + childAtt.Id) && accountAttributesAssociated.containsKey(
                                        acc.Id) && !accountAttributesAssociated.get(acc.Id).containsKey(childAtt.Id)) {
                                    accountAttributes.add(new Account_Attribute__c(Account__c = acc.Id, Attribute__c = childAtt.Id, Is_fromMapping__c =
                                        true, Inheritable__c = att.Attribute_Mapping__r.Inheritable__c));
                                    preventDuplicacy.add(acc.Id + '' + childAtt.Id);
                                }
                            }
                            
                            if (accountAttributesAssociated.containsKey(acc.Id) && accountAttributesAssociated.get(acc.Id).containsKey(childAtt.Id) &&
                                accountAttributesAssociated.get(acc.Id).get(childAtt.Id).Inheritable__c != att.Attribute_Mapping__r.Inheritable__c) {
                                
                                if (att.Attribute_Mapping__r.Inheritable__c) {
                                    accountAttributesAssociated.get(acc.Id).get(childAtt.Id).Inheritable__c = att.Attribute_Mapping__r.Inheritable__c;
                                    accountAttributes.add(accountAttributesAssociated.get(acc.Id).get(childAtt.Id));
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if (!accountAttributes.isEmpty())
            Database.upsert(accountAttributes, false);
    }
    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {}
}