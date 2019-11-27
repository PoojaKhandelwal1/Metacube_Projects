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
 * Class: Schedular_AttributeMapping
 * Description : This Batch called from Schedular_AttributeMapping to update all related Attributes of Reference Content attribute mapping
 * if any picklist value is changed/deleted/added and all related Content attributes are also updated
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_ContentAttribute implements Database.Batchable < sObject > , Database.stateful {
    /**
     * Properties and variables
     */
    private String soqlQuery =
        'select Attribute__r.Parent__r.Attribute_Mapping__r.Auto_populate__c,Attribute__r.Parent__c,Attribute__r.Name,Reference_Content__c from Content_Attribute__c where Is_fromMapping__c = true';
    private Map < String, Schema.SObjectField > fieldMap;
    private Set < String > attDelete;
    private List < String > listOfFailedRecords = new List < String > ();

    /**
     * Constructor
     */
    global Batch_ContentAttribute() {
        Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Reference_Content__c'); //From the Object Api name retrieving the SObject
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
    global void execute(Database.BatchableContext BC, List < Content_Attribute__c > scope) {
        set < Id > parentAttIds = new set < Id > ();
        set < Id > delAtts = new set < Id > ();
        ConstantsController.runCheckAttributeMappingEditMethod = false;
        map < String, List < Schema.PicklistEntry >> attMappingPicklistMap = new map < String, List < Schema.PicklistEntry >> ();
        map < Id, list < Attribute__c >> attMappingAttributes = new map < Id, list < Attribute__c >> ();
        string parentAttId;
        boolean attributePresent = false;
        list < Schema.PicklistEntry > picklistValues = new list < Schema.PicklistEntry > ();
        list < Attribute__c > newAttributes = new list < Attribute__c > ();
        set < String > attributesExisting = new set < string > ();
        set < String > contentIds = new set < String > ();
        map < Id, Attribute__c > attMapingParentAttribute = new map < Id, Attribute__c > ();
        map < string, string > mappingAttribute = new map < String, string > ();
        map < string, string > mappingAttFilter = new map < String, string > ();
        set < String > childAttributeToFindLabel = new set < String > ();
        map < String, String > parentLabelMap = new map < String, string > ();
        
        for (Content_Attribute__c conAtt: scope) {
            parentAttIds.add(conAtt.Attribute__r.parent__c);
            
            if (conAtt.Attribute__r.Parent__r.Attribute_Mapping__r.Auto_populate__c)
                contentIds.add(conAtt.Reference_Content__c);
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
        
        if (contentIds.size() > 0)
            createContentAttributes(contentIds, attMapingParentAttribute);
            
        if (delAtts.size() > 0)
            UtilityController.deleteAttributesInstance(delAtts);
    }

    /**
     * Method to create Content Attribute
     */
    void createContentAttributes(set < String > contentIds, map < Id, Attribute__c > attMapingParentAttribute) {
        List < Schema.SObjectField > fldObjMapValues = fieldMap.values();
        set < String > deleteAttMapping = new set < String > ();
        set < String > preventDuplicacy = new set < String > ();
        list < Content_Attribute__c > createContentAtt = new list < Content_Attribute__c > ();
        String theQuery = 'SELECT ';

        for (Schema.SObjectField s: fldObjMapValues) {
            String theName = s.getDescribe().getName();
            // Continue building your dynamic query string
            theQuery += theName + ',';
        }
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        theQuery += ' FROM Reference_Content__c WHERE Id In :contentIds';
        list < Reference_Content__c > contents = Database.query(theQuery);
        map < Id, set < Id >> conAttsAssociated = new map < Id, set < Id >> ();

        for (Content_Attribute__c accAtt: [select Attribute__c, Reference_Content__c from Content_Attribute__c where Reference_Content__c In: contents]) {

            if (!conAttsAssociated.containsKey(accAtt.Reference_Content__c))
                conAttsAssociated.put(accAtt.Reference_Content__c, new set < Id > ());
            conAttsAssociated.get(accAtt.Reference_Content__c).add(accAtt.Attribute__c);
        }

        for (Id attMapId: attMapingParentAttribute.keySet()) {

            for (Reference_Content__c con: contents) {

                for (Attribute__c childAtt: attMapingParentAttribute.get(attMapId).Attributes__r) {

                    if (con.get(attMapingParentAttribute.get(attMapId).Attribute_Mapping__r.Field_Api_Name__c) != null) {

                        for (string attStr: string.ValueOf(con.get(attMapingParentAttribute.get(attMapId).Attribute_Mapping__r.Field_Api_Name__c)).split(
                                ';')) {

                            if (attStr == childAtt.Name && !preventDuplicacy.contains(con.Id + '' + childAtt.Id) && attMapingParentAttribute.get(
                                    attMapId).Attribute_Mapping__r.Auto_populate__c && (!conAttsAssociated.containsKey(con.Id) || !conAttsAssociated.get(
                                    con.Id).contains(childAtt.Id))) {
                                createContentAtt.add(new Content_Attribute__c(Reference_Content__c = con.Id, Attribute__c = childAtt.Id,
                                    Is_fromMapping__c = true));
                                preventDuplicacy.add(con.Id + '' + childAtt.Id);
                            }
                        }
                    }
                }
            }
        }

        //Content Attribute Creation
        if (createContentAtt.size() > 0) {
            Database.SaveResult[] contentAttribute = database.insert(createContentAtt, false);

            for (database.Saveresult sr: contentAttribute) {

                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    listOfFailedRecords.add('Content Attribute Insert Error : ' + err.getMessage());
                }
            }
        }
    }

    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {
        //Send Error Email to Refedge Team
        UtilityController.sendEmailNotification(listOfFailedRecords, 'Content Attribute Batch');
        list < Attribute__c > attToBeDeleted = [select Id from Attribute__c where Id In: attDelete];

        if (attToBeDeleted.size() > 0) {
            database.delete(attToBeDeleted, false);
        }
    }
}