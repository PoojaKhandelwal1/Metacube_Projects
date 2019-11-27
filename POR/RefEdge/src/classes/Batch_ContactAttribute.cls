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
 * Class: Schedular_ContactAttribute
 * Description : This Batch called from Schedular_ContactAttribute to update all related Attributes of Contact Attribute mapping
 * if any picklist value is changed/deleted/added and all related Contact attributes are also updated
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_ContactAttribute implements Database.Batchable < sObject > , Database.stateful {
    /**
     * Properties and variables
     */
    private String soqlQuery =
        'select Attribute__r.Parent__r.Attribute_Mapping__r.Auto_populate__c,Attribute__r.Parent__c,Attribute__r.Name,contact__c from Contact_Attribute__c where Is_fromMapping__c = true';
    private Map < String, Schema.SObjectField > fieldMap;
    private Set < String > attDelete;
    private List < String > listOfFailedRecords = new List < String > ();

    /**
     * Constructor
     */
    global Batch_ContactAttribute() {
        Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get('Contact'); //From the Object Api name retrieving the SObject
        //fieldMap = targetType.newSObject().getSObjectType().getDescribe().fields.getMap();
        Sobject objectName = targetType.newSObject();
        Schema.sObjectType sobjectType = objectName.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe(); //describe the sobject
        fieldMap = sobjectDescribe.fields.getMap();
        attDelete = new set < String > ();
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
    global void execute(Database.BatchableContext BC, List < Contact_Attribute__c > scope) {
        set < Id > parentAttIds = new set < Id > ();
        set < Id > delAtts = new set < Id > ();
        ConstantsController.runCheckAttributeMappingEditMethod = false;
        ConstantsController.attMappingForAccount = false;
        ConstantsController.attMappingForContact = false;
        map < String, List < Schema.PicklistEntry >> attMappingPicklistMap = new map < String, List < Schema.PicklistEntry >> ();
        map < Id, list < Attribute__c >> attMappingAttributes = new map < Id, list < Attribute__c >> ();
        string parentAttId;
        boolean attributePresent = false;
        list < Schema.PicklistEntry > picklistValues = new list < Schema.PicklistEntry > ();
        list < Attribute__c > newAttributes = new list < Attribute__c > ();
        set < String > attributesExisting = new set < string > ();
        set < String > contactIds = new set < String > ();
        map < Id, Attribute__c > attMapingParentAttribute = new map < Id, Attribute__c > ();
        map < string, string > mappingAttribute = new map < String, string > ();
        map < string, string > mappingAttFilter = new map < String, string > ();
        set < String > childAttributeToFindLabel = new set < String > ();
        map < String, String > parentLabelMap = new map < String, string > ();
        
        for (Contact_Attribute__c conAtt: scope) {
            parentAttIds.add(conAtt.Attribute__r.parent__c);
            
            if (conAtt.Attribute__r.Parent__r.Attribute_Mapping__r.Auto_populate__c)
                contactIds.add(conAtt.Contact__c);
        }

        //find the attributes present which are mapped from the AttributeMapping
        list < Attribute__c > listAttribute = [select Id, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Inheritable__c,
            Attribute_Mapping__r.Auto_update__c, Attribute_Mapping__r.Auto_delete__c, Attribute_Mapping__r.Auto_populate__c, Attribute_Mapping__r.Auto_add__c,
            (Select Id, Name, Parent__c from Attributes__r) from Attribute__c where Id In: parentAttIds and level__c = 0
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
            }
            
            if (!flag)
                attMappingAttributes.put(att.Attribute_Mapping__r.Id, new list < Attribute__c > ());
            
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
                
                //if the picklist name is not present as attribute den create it
                if (!attributePresent && (attMapingParentAttribute.get(attMapId).Attribute_Mapping__r.Auto_add__c || attMapingParentAttribute.get(
                        attMapId).Attribute_Mapping__r.Auto_update__c)) {
                    newAttributes.add(new Attribute__c(name = a.getValue(), Parent__c = parentAttId));
                }
            }
        }

        for (Attribute__c att: [select Id from Attribute__c where Id Not In: attributesExisting and Parent__r.Attribute_Mapping__c In:
                attMappingPicklistMap.keySet() and(parent__r.Attribute_Mapping__r.Auto_delete__c = true Or parent__r.Attribute_Mapping__r.Auto_update__c =
                    true)
            ]) {
            attDelete.add(att.Id);
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

        list < Attribute__c > listParAttribute = [select Id, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Inheritable__c,
            Attribute_Mapping__r.Auto_update__c, Attribute_Mapping__r.Auto_delete__c, Attribute_Mapping__r.Auto_populate__c, Attribute_Mapping__r.Auto_add__c,
            (Select Id, Name, Parent__c from Attributes__r) from Attribute__c where Id In: parentAttIds and level__c = 0
        ];
        
        for (Attribute__c att: listParAttribute) {
        	
            if (fieldMap.containskey(att.Attribute_Mapping__r.Field_Api_Name__c)) {
                attMapingParentAttribute.put(att.Attribute_Mapping__r.Id, att);
            }
        }
        
        if (contactIds.size() > 0)
            createContactAttributes(contactIds, attMapingParentAttribute);
            
        if (delAtts.size() > 0)
            UtilityController.deleteAttributesInstance(delAtts);
    }

    /**
     * Method to create Contact Attribute
     */
    void createContactAttributes(set < String > contactIds, map < Id, Attribute__c > attMapingParentAttribute) {
        set < String > deleteAttMapping = new set < String > ();
        list < Schema.SObjectField > fldObjMapValues = fieldMap.values();
        set < String > preventDuplicacy = new set < String > ();
        list < Contact_Attribute__c > createContactAtt = new list < Contact_Attribute__c > ();
        string theQuery = 'SELECT Id,Name,';
        map < Id, Reference_Basic_Information__c > contactRBI = new map < Id, Reference_Basic_Information__c > ();
        
        for (Schema.SObjectField s: fldObjMapValues) {
            Schema.DescribeFieldResult fieldDesc = s.getDescribe();
            
            if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                String theName = fieldDesc.getName();
                // Continue building your dynamic query string
                theQuery += theName + ',';
            }
        }
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        theQuery += ' FROM Contact WHERE Id In :contactIds';
        list < Contact > contacts = Database.query(theQuery);
        
        //query all the parent along with child attributes of the mapping
        for (Reference_Basic_Information__c rbi: [select Is_Referenceable__c, Reference_Program_Candidate__c, Contact__c from Reference_Basic_Information__c where Contact__c In:
                contactIds
            ]) {
            contactRBI.put(rbi.Contact__c, rbi);
        }
        map < Id, set < Id >> conAttsAssociated = new map < Id, set < Id >> ();
        
        for (Contact_Attribute__c accAtt: [select Attribute__c, Contact__c from Contact_Attribute__c where Contact__c In: contacts]) {
            
            if (!conAttsAssociated.containsKey(accAtt.Contact__c))
                conAttsAssociated.put(accAtt.Contact__c, new set < Id > ());
            conAttsAssociated.get(accAtt.Contact__c).add(accAtt.Attribute__c);

        }
        
        for (Id attMapId: attMapingParentAttribute.keySet()) {
            
            for (Contact con: contacts) {
                
                for (Attribute__c childAtt: attMapingParentAttribute.get(attMapId).Attributes__r) {
                   
                    if (con.get(attMapingParentAttribute.get(attMapId).Attribute_Mapping__r.Field_Api_Name__c) != null) {
                        
                        for (String attStr: string.valueOf(con.get(attMapingParentAttribute.get(attMapId).Attribute_Mapping__r.Field_Api_Name__c)).split(
                                ';')) {
                            
                            if (contactRBI.containsKey(con.Id) && (contactRBI.get(con.Id).Is_Referenceable__c || contactRBI.get(con.Id).Reference_Program_Candidate__c) &&
                                attStr == childAtt.Name && !preventDuplicacy.contains(con.Id + '' + childAtt.Id) && attMapingParentAttribute.get(
                                    attMapId).Attribute_Mapping__r.Auto_populate__c && (!conAttsAssociated.containsKey(con.Id) || !conAttsAssociated.get(
                                    con.Id).contains(childAtt.Id))) {
                                createContactAtt.add(new Contact_Attribute__c(Contact__c = con.Id, Attribute__c = childAtt.Id, Is_fromMapping__c = true));
                                preventDuplicacy.add(con.Id + '' + childAtt.Id);
                            }
                        }
                    }
                }
            }
        }
        
        //Contact Attribute Creation
        if (createContactAtt.size() > 0) {
            Database.SaveResult[] contactAttribute = database.insert(createContactAtt, false);
            
            for (database.Saveresult sr: contactAttribute) {
            	
                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    listOfFailedRecords.add('Contact Attribute Insert Error : ' + err.getMessage());
                }
            }
        }
    }

    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {
        //Send Error Email to Refedge Team
        UtilityController.sendEmailNotification(listOfFailedRecords, 'Contact Attribute Batch');
        //Delete Attributes
        list < Attribute__c > attToBeDeleted = [select Id from Attribute__c where Id In: attDelete];
        
        if (attToBeDeleted.size() > 0) {
            database.delete(attToBeDeleted, false);
        }
    }
}