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
 * Class: Schedular_AccountAttribute
 * Description : This Batch called from Schedular_AccountAttribute to update all related Attributes of Account Attribute mapping
 * if any picklist value is changed/deleted/added and all related Account attributes are also updated
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_AccountAttribute implements Database.Batchable < sObject > , Database.stateful {
    /**
     * Properties and variables
     */
    private Set<String> attRibIds = new Set<String>();
    private String soqlQuery;
    private Map<String, Schema.SObjectField> fieldMap;
    private Set<String> deleteAttributes;
    private List<String> listOfFailedRecords = new List<String>();

    /**
     * Constructor
     */
    global Batch_AccountAttribute() {
        soqlQuery = 'SELECT Attribute__r.Parent__r.Attribute_Mapping__r.Auto_populate__c,'
        				+ 'Attribute__r.Parent__c, Attribute__r.Name, Account__c '
        				+ 'FROM Account_Attribute__c WHERE Is_fromMapping__c = true';
        Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get('Account'); //From the Object Api name retrieving the SObject
        //fieldMap = targetType.newSObject().getSObjectType().getDescribe().fields.getMap();
        Sobject objectName = targetType.newSObject();
        Schema.sObjectType sobjectType = objectName.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe(); //describe the sobject
        fieldMap = sobjectDescribe.fields.getMap();
        deleteAttributes = new Set<String>();
    }
    
    /**
     * Method to get the data to be processed
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(soqlQuery);
    }
    
    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List<Account_Attribute__c> scope) {
        Set<Id> parentAttIds = new Set<Id>();
        Set<Id> delAtts = new Set<Id>();
        //so that checkAttributeMappingEdit Method doesnot gets executed again.
        ConstantsController.runCheckAttributeMappingEditMethod = false;
        ConstantsController.attMappingForAccount = false;
        ConstantsController.attMappingForContact = false;
        Map<String, List<Schema.PicklistEntry>> attMappingPicklistMap = new Map<String, List<Schema.PicklistEntry>>();
        Map<Id, List<Attribute__c>> attMappingAttributes = new Map<Id, List<Attribute__c>>();
        String parentAttId;
        Boolean attributePresent = false;
        List<Schema.PicklistEntry> picklistValues = new List<Schema.PicklistEntry>();
        List<Attribute__c> newAttributes = new List<Attribute__c>();
        Set<String> attributesExisting = new Set<String>();
        Set<String> accountIds = new Set<String>();
        map < Id, Attribute__c > attMapingParentAttribute = new map < Id, Attribute__c > ();
        map < string, string > mappingAttribute = new map < String, string>();
        map < string, string > mappingAttFilter = new map < String, string>();
        Set<String> childAttributeToFindLabel = new Set<String>();
        map < String, String > parentLabelMap = new map < String, string > ();
        
        for (Account_Attribute__c accAtt: scope) {
            
            if (accAtt.Attribute__r.Parent__r.Attribute_Mapping__c != null) {
                parentAttIds.add(accAtt.Attribute__r.parent__c);
                
                if (accAtt.Attribute__r.Parent__r.Attribute_Mapping__r.Auto_populate__c)
                    accountIds.add(accAtt.Account__c);
            }
        }

        //find the attributes present which are mapped from the AttributeMapping
        list < Attribute__c > listAttribute = [SELECT Id, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Inheritable__c,
            Attribute_Mapping__r.Auto_update__c, Attribute_Mapping__r.Auto_delete__c, Attribute_Mapping__r.Auto_populate__c, Attribute_Mapping__r.Auto_add__c,
            (SELECT Id, Name, Parent__c FROM Attributes__r) FROM Attribute__c WHERE Id IN: parentAttIds AND level__c = 0
        ];
        
        for (Attribute__c att: listAttribute) {
            boolean flag = false;
            
            //map contains the attribute level 1 associated with that mapping record
            for (Attribute__c aaa: att.Attributes__r) {
            	
                if (!attMappingAttributes.containsKey(att.Attribute_Mapping__r.Id)) {
                    attMappingAttributes.put(att.Attribute_Mapping__r.Id, new list < Attribute__c > ());
                }
                attMappingAttributes.get(att.Attribute_Mapping__r.Id).add(aaa);
                flag = true;
            }

            if (flag) {
                childAttributeToFindLabel.add(att.Attributes__r.get(0).Id);
                mappingAttribute.put(att.Attributes__r.get(0).Id, att.Attribute_Mapping__r.Id);
            } else {
                attMappingAttributes.put(att.Attribute_Mapping__r.Id, new list < Attribute__c > ());
            }

            if (fieldMap.containskey(att.Attribute_Mapping__r.Field_Api_Name__c)) {
                picklistValues = fieldMap.get(att.Attribute_Mapping__r.Field_Api_Name__c).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
                attMappingPicklistMap.put(att.Attribute_Mapping__r.Id, picklistValues);
                attMapingParentAttribute.put(att.Attribute_Mapping__r.Id, att);
            }
        }

        if (childAttributeToFindLabel.size() > 0) {
        	
            for (Attributes_Labels__c attLabel: [select label__c, Attribute__c from Attributes_Labels__c where Attribute__c In:
                    childAttributeToFindLabel
                ]) {
                	
                if (mappingAttribute.containsKey(attLabel.Attribute__c))
                    mappingAttFilter.put(mappingAttribute.get(attLabel.Attribute__c), attLabel.label__c);
            }
        }

        for (String attMapId: attMappingPicklistMap.keySet()) {
        	
            for (Schema.PicklistEntry a: attMappingPicklistMap.get(attMapId)) { //for all values in the picklist list
                attributePresent = false;
                
                if (attMappingAttributes.containsKey(attMapId)) {
                	
                    for (Attribute__c att: attMappingAttributes.get(attMapId)) {
                    	
                        if (mappingAttFilter.containsKey(attMapId)) {
                            parentLabelMap.put(att.parent__c, mappingAttFilter.get(attMapId));
                        }
                        parentAttId = att.parent__c;
                        
                        if (att.Name == a.getValue()) {
                            attributePresent = true;
                            attributesExisting.add(att.Id);
                        }
                    }
                }
                
                //if the picklist name is not present as attribute den create it
                if (!attributePresent && attMapingParentAttribute.containsKey(attMapId) && (attMapingParentAttribute.get(attMapId).Attribute_Mapping__r
                        .Auto_add__c || attMapingParentAttribute.get(attMapId).Attribute_Mapping__r.Auto_update__c)) {
                    newAttributes.add(new Attribute__c(name = a.getValue(), Parent__c = parentAttId));
                }
            }
        }

        for (Attribute__c att: [select Id from Attribute__c where Id Not In: attributesExisting and Parent__r.Attribute_Mapping__c In:
                attMappingPicklistMap.keySet() and(parent__r.Attribute_Mapping__r.Auto_delete__c = true Or parent__r.Attribute_Mapping__r.Auto_update__c =
                    true)
            ]) {
            deleteAttributes.add(att.Id);
            delAtts.add(att.Id);
        }

        if (newAttributes.size() > 0) {
            database.insert(newAttributes, false);
            list < Attributes_Labels__c > attLabels = new list < Attributes_Labels__c > ();
            
            for (Attribute__c att: newAttributes) {
            	
                if (parentLabelMap.containsKey(att.Parent__c))
                    attLabels.add(new Attributes_Labels__c(Attribute__c = att.Id, Label__c = parentLabelMap.get(att.Parent__c)));
            }
            
            if (attLabels.size() > 0)
                database.insert(attLabels, false);
        }
        attMapingParentAttribute = new map < Id, Attribute__c > ();
        
        for (Attribute__c att: [select Id, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Inheritable__c,
                Attribute_Mapping__r.Auto_update__c, Attribute_Mapping__r.Auto_delete__c, Attribute_Mapping__r.Auto_populate__c, Attribute_Mapping__r.Auto_add__c,
                (Select Id, Name, Parent__c from Attributes__r) from Attribute__c where Id In: parentAttIds and level__c = 0
            ]) {
            	
            if (fieldMap.containskey(att.Attribute_Mapping__r.Field_Api_Name__c)) {
                attMapingParentAttribute.put(att.Attribute_Mapping__r.Id, att);
            }
        }
        
        if (accountIds.size() > 0)
            createAccountAttributes(accountIds, attMapingParentAttribute);
            
        if (delAtts.size() > 0)
            UtilityController.deleteAttributesInstance(delAtts);
    }

    /**
     * Create Account Attribute
     */
    void createAccountAttributes(set < string > accountIds, map < Id, Attribute__c > attMapingParentAttribute) {
        List < Schema.SObjectField > fldObjMapValues = fieldMap.values();
        set < String > preventDuplicacy = new set < String > ();
        set < String > deleteAttMapping = new set < String > ();
        list < Account_Attribute__c > createAccountAtt = new list < Account_Attribute__c > ();
        String theQuery = 'SELECT ';
        map < Id, Reference_Basic_Information__c > accountRBI = new map < Id, Reference_Basic_Information__c > ();
        
        for (Schema.SObjectField s: fldObjMapValues) {
            Schema.DescribeFieldResult fieldDesc = s.getDescribe();
            
            if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                String theName = fieldDesc.getName();
                // Continue building your dynamic query string
                theQuery += theName + ',';
            }
        }
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        theQuery += ' FROM Account WHERE Id In :accountIds';
        list < Account > accounts = Database.query(theQuery);
        
        //query all the parent along with child attributes of the mapping
        for (Reference_Basic_Information__c rbi: [select Is_Referenceable__c, Reference_Program_Candidate__c, Account__c from Reference_Basic_Information__c where Account__c In:
                accountIds and contact__c = null
            ]) {
            accountRBI.put(rbi.Account__c, rbi);
        }
        map < Id, set < Id >> accAttsAssociated = new map < Id, set < Id >> ();
        
        for (Account_Attribute__c accAtt: [select Attribute__c, Account__c from Account_Attribute__c where Account__c In: accounts]) {
        	
            if (!accAttsAssociated.containsKey(accAtt.Account__c))
                accAttsAssociated.put(accAtt.Account__c, new set < Id > ());
            accAttsAssociated.get(accAtt.Account__c).add(accAtt.Attribute__c);

        }
        for (Id attMapId: attMapingParentAttribute.keySet()) {
        	
            for (Account acc: accounts) {
            	
                for (Attribute__c childAtt: attMapingParentAttribute.get(attMapId).Attributes__r) {
                	
                    if (acc.get(attMapingParentAttribute.get(attMapId).Attribute_Mapping__r.Field_Api_Name__c) != null) {
                    	
                        for (String attStr: string.valueOf(acc.get(attMapingParentAttribute.get(attMapId).Attribute_Mapping__r.Field_Api_Name__c)).split(
                                ';')) {
                                	
                            if (accountRBI.containsKey(acc.Id) && (accountRBI.get(acc.Id).Is_Referenceable__c || accountRBI.get(acc.Id).Reference_Program_Candidate__c) &&
                                attStr == childAtt.Name && !preventDuplicacy.contains(acc.Id + '' + childAtt.Id) && attMapingParentAttribute.get(
                                    attMapId).Attribute_Mapping__r.Auto_populate__c && (!accAttsAssociated.containsKey(acc.Id) || !accAttsAssociated.get(
                                    acc.Id).contains(childAtt.Id))) {
                                createAccountAtt.add(new Account_Attribute__c(Account__c = acc.Id, Attribute__c = childAtt.Id, Is_fromMapping__c = true,
                                    Inheritable__c = attMapingParentAttribute.get(attMapId).Attribute_Mapping__r.Inheritable__c));
                                preventDuplicacy.add(acc.Id + '' + childAtt.Id);
                            }
                        }
                    }

                }
            }
        }

        //Insert Account Attribute
        if (createAccountAtt.size() > 0) {
            Database.SaveResult[] accountAttribute = database.insert(createAccountAtt, false);
            
            for (database.Saveresult sr: accountAttribute) {
            	
                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    listOfFailedRecords.add('Account Attribute Insert Error : ' + err.getMessage());
                }
            }
        }
    }

    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {
        //Send Error Email to Refedge Team
        UtilityController.sendEmailNotification(listOfFailedRecords, 'Account Attribute Batch');
        list < Attribute__c > attToBeDeleted = [select Id from Attribute__c where Id In: deleteAttributes];
        
        if (attToBeDeleted.size() > 0) {
            database.delete(attToBeDeleted, false);
        }
    }
}