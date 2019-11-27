/**
 * ReferenceEdge
 * 
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc.
 * @website : www.point-of-reference.com
 *;
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
 * Description: Batch process to keep the Attributes in sync with Capgemeni taxonomy values
 * author: Gaurav Saini (20 Dec, 2018)
 */
global with sharing class Batch_SyncTaxonomyAttributes implements Database.Batchable<sObject>, Database.stateful {

    private Set<String> rootAttIds = new Set<String>();
    private Map<String, Map<String, String>> sObjectsMap = new Map<String, Map<String, String>>();
    private String soqlQuery = 'SELECT Id, Name, Product_ID__c, Parent__c, Root_Parent__c, Parent__r.Attribute_Mapping__r.Object__c, '
                                + 'Parent__r.Attribute_Mapping__c '
                                + 'FROM Attribute__c WHERE Parent__c IN :rootAttIds';
    private List<Attributes_Labels__c> attLabelsToInsert = new List<Attributes_Labels__c>();
    private List<Attribute__c> attsToInsert = new List<Attribute__c>();
    private List<Attribute__c> attsToUpdate = new List<Attribute__c>();
    private List<Attribute__c> attsToDelete = new List<Attribute__c>();
    private Map<String, Attribute__c> rootAttsMap = new Map<String, Attribute__c>();
    private Map<String, Label__c> filtersMap = new Map<String, Label__c>();
    private List<String> listOfFailedRecords = new List<String>();
    private Map<String, List<User_Mapping__c>> attMappingFiltersMap = new Map<String, List<User_Mapping__c>>();
    private Map<String, Attribute_Mapping__c> attMappingsMap = new Map<String, Attribute_Mapping__c>();

    global Batch_SyncTaxonomyAttributes() {
        Set<String> rootAttNames = new Set<String>();
        Set<String> filterNames = new Set<String>();

        for (Attribute_Mapping__c am : [SELECT Id, Attribute_Name__c, Auto_add__c, Auto_delete__c, Auto_update__c,
                                        Object__c, Inheritable__c, Filter_Label_Name__c
                                        FROM Attribute_Mapping__c WHERE Field_API_Name__c = null]) {
            rootAttNames.add(am.Attribute_Name__c);
            filterNames.add(am.Filter_Label_Name__c);
            attMappingsMap.put(am.Id, am);
        }

        for (Attribute__c att : [SELECT Id, Name, Product_ID__c, Attribute_Mapping__r.Object__c,
                                    Attribute_Mapping__r.Filter_Label_Name__c, Attribute_Mapping__c
                                    FROM Attribute__c WHERE Level__c = 0 AND Name IN :rootAttNames]) {
            rootAttsMap.put(att.Name, att);
            rootAttIds.add(att.Id);
        }

        for (Label__c lbl : [SELECT Id, Name FROM Label__c WHERE Name IN :filterNames]) {
            filtersMap.put(lbl.Name, lbl);
        }

        for (User_Mapping__c um : [SELECT Id, Label__c, Visible__c, Field_API_Name__c, Default_Value__c, Order__c, From_Mapping__c
                                    FROM User_Mapping__c
                                    WHERE Process__c = 'AttMappingFilters'
                                    ORDER BY Order__c]) {

            // user mapping Label__c to store att mapping id
            // rest all fields remain same
            if (!attMappingFiltersMap.containsKey(um.Label__c)) {
                attMappingFiltersMap.put(um.Label__c, new List<User_Mapping__c>());
            }
            attMappingFiltersMap.get(um.Label__c).add(um);
        }

        for (Attribute_Mapping__c am : attMappingsMap.values()) {
            String mappingObjectQuery = 'SELECT Id, Name FROM ' + am.Object__c + ' WHERE Name != null ';
            sObjectsMap.put(am.Object__c + ';;' + am.Id, new Map<String, String>());

            if (attMappingFiltersMap.containsKey(am.Id) && attMappingFiltersMap.get(am.Id).size() > 0) {
                String whereClause = UtilityController.createDynamicQuery(attMappingFiltersMap.get(am.Id));
                mappingObjectQuery += whereClause;
            }
            mappingObjectQuery += ' ORDER BY Name LIMIT 1000';

            for (SObject obj : Database.query(mappingObjectQuery)) {
                sObjectsMap.get(am.Object__c + ';;' + am.Id).put((String)obj.get('Id'), (String)obj.get('Name'));
            }
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(soqlQuery);
    }

    global void execute(Database.BatchableContext BC, List<Attribute__c> scope) {

        for (Attribute__c att : scope) {

            if (rootAttsMap.containsKey(att.Root_Parent__c) && att.Parent__c == rootAttsMap.get(att.Root_Parent__c).Id) {

                if (sObjectsMap.get(att.Parent__r.Attribute_Mapping__r.Object__c + ';;' + att.Parent__r.Attribute_Mapping__c).containsKey(att.Product_ID__c)
                        && att.Name != sObjectsMap.get(att.Parent__r.Attribute_Mapping__r.Object__c + ';;' + att.Parent__r.Attribute_Mapping__c).get(att.Product_ID__c)) {

                    if (attMappingsMap.get(att.Parent__r.Attribute_Mapping__c).Auto_update__c) {
                        att.Name = sObjectsMap.get(att.Parent__r.Attribute_Mapping__r.Object__c + ';;' + att.Parent__r.Attribute_Mapping__c).get(att.Product_ID__c);
                        attsToUpdate.add(att);
                    }
                    sObjectsMap.get(att.Parent__r.Attribute_Mapping__r.Object__c + ';;' + att.Parent__r.Attribute_Mapping__c).remove(att.Product_ID__c);
                } else if (sObjectsMap.get(att.Parent__r.Attribute_Mapping__r.Object__c + ';;' + att.Parent__r.Attribute_Mapping__c).containsKey(att.Product_ID__c)
                        && att.Name == sObjectsMap.get(att.Parent__r.Attribute_Mapping__r.Object__c + ';;' + att.Parent__r.Attribute_Mapping__c).get(att.Product_ID__c)) {
                    sObjectsMap.get(att.Parent__r.Attribute_Mapping__r.Object__c + ';;' + att.Parent__r.Attribute_Mapping__c).remove(att.Product_ID__c);
                } else if (!sObjectsMap.get(att.Parent__r.Attribute_Mapping__r.Object__c + ';;' + att.Parent__r.Attribute_Mapping__c).containsKey(att.Product_ID__c)
                        && attMappingsMap.get(att.Parent__r.Attribute_Mapping__c).Auto_delete__c) {
                    attsToDelete.add(att);
                }
            }
        }

        if (attsToUpdate != null && attsToUpdate.size() > 0) {
            Database.SaveResult[] updateResult = Database.update(attsToUpdate, false);

            for (Database.SaveResult sr : updateResult) {

                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    listOfFailedRecords.add('\nTaxonomy Attribute Update Error : ' + err.getMessage());
                }
            }
        }

        if (attsToDelete != null && attsToDelete.size() > 0) {
            Database.DeleteResult[] deleteResult = Database.delete(attsToDelete, false);

            for (Database.DeleteResult sr : deleteResult) {

                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    listOfFailedRecords.add('\nTaxonomy Attribute Delete Error : ' + err.getMessage());
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

        for (Attribute__c rootAtt : rootAttsMap.values()) {

            if (sObjectsMap.get(rootAtt.Attribute_Mapping__r.Object__c + ';;' + rootAtt.Attribute_Mapping__c) != null
                    && sObjectsMap.get(rootAtt.Attribute_Mapping__r.Object__c + ';;' + rootAtt.Attribute_Mapping__c).size() > 0
                    && attMappingsMap.get(rootAtt.Attribute_Mapping__c).Auto_add__c) {

                for (String objId : sObjectsMap.get(rootAtt.Attribute_Mapping__r.Object__c + ';;' + rootAtt.Attribute_Mapping__c).keySet()) {
                    attsToInsert.add(new Attribute__c(
                        Name = sObjectsMap.get(rootAtt.Attribute_Mapping__r.Object__c + ';;' + rootAtt.Attribute_Mapping__c).get(objId),
                        Product_ID__c = objId,
                        Parent__c = rootAtt.Id,
                        Root_Parent__c = rootAtt.Name
                    ));
                }
            }
        }

        if (attsToInsert != null && attsToInsert.size() > 0) {
            Database.SaveResult[] insertResult = Database.insert(attsToInsert, false);

            for (Database.SaveResult sr : insertResult) {

                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    listOfFailedRecords.add('\nTaxonomy Attribute Insert Error : ' + err.getMessage());
                }
            }

            for (Attribute__c att : attsToInsert) {

                if (rootAttsMap.containsKey(att.Root_Parent__c)
                        && filtersMap.containsKey(rootAttsMap.get(att.Root_Parent__c).Attribute_Mapping__r.Filter_Label_Name__c)) {
                    attLabelsToInsert.add(new Attributes_Labels__c(Attribute__c = att.Id, Label__c = filtersMap.get(rootAttsMap.get(att.Root_Parent__c).Attribute_Mapping__r.Filter_Label_Name__c).Id));
                }
            }
            insertResult = Database.insert(attLabelsToInsert, false);

            for (Database.SaveResult sr : insertResult) {

                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    listOfFailedRecords.add('\nTaxonomy Attribute Insert Error : ' + err.getMessage());
                }
            }
        }

        if ((listOfFailedRecords != NULL && listOfFailedRecords.size() > 0)) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] { 'referenceedge@point-of-reference.com' };
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('RefEdge Support');
            mail.setSubject('Sync Taxonomy Attributes Batch');
            String mailBody = 'Exception in records are: \n' + listOfFailedRecords;
            mailBody = mailBody + '\n Organization Name: ' + Userinfo.getOrganizationName() + '\n Organization Id: '
            							+ Userinfo.getOrganizationId() + '\n\n Please do not reply to this mail.';
            mail.setPlainTextBody(mailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}