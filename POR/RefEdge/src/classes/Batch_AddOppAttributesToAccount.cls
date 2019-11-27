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
 * Description : This Batch called FROM AttributeMappingTriggerHandler for opportunity Attribute update
 * Modified by: Rajneesh Raj @Jan/01/2019
 */
global with sharing class Batch_AddOppAttributesToAccount implements Database.Batchable<sObject>, Database.stateful {
    /**
     * Properties AND variables
     */
    private String soqlQuery = '';
    private List<Attribute_Mapping__c> attributeMappings;
    private List<Attribute_Mapping__c> oppPicklistMappings;
    private Map<String, Schema.SObjectField> oppProductFieldMap;
    private Map<String, Schema.SObjectField> oppFieldMap;
    private Custom_Settings__c cs;
    private Map<String, sObject> currencyMap;
    private boolean isCurrencyEnabled;
    private Set<String> mappedOppFields;
    private Set<String> mappedOppLineItemFields;
    private Set<String> attMappingIds;

    global Batch_AddOppAttributesToAccount() {
        oppProductFieldMap = schema.SObjectType.OpportunityLineItem.fields.getMap();
        oppFieldMap = schema.SObjectType.Opportunity.fields.getMap();
        cs = UtilityController.getCustomSettings();
        isCurrencyEnabled = (UtilityController.isCurrencyEnabled() && UserInfo.isMultiCurrencyOrganization());
        attributeMappings = new List<Attribute_Mapping__c>();
        oppPicklistMappings = new List<Attribute_Mapping__c>();
        mappedOppFields = new Set<String>();
        mappedOppLineItemFields = new Set<String>();
        attMappingIds = new Set<String>();

        for (Attribute_Mapping__c attM : [SELECT Field_Api_Name__c, Auto_populate__c, Auto_add__c, Auto_Update__c, Auto_delete__c,
                                            Is_Related_Mapping__c FROM Attribute_Mapping__c
                                            WHERE Object__c = :ConstantsController.OPPORTUNITY
                                            AND Auto_populate__c = true
                                            AND Field_Api_Name__c != null
                                            AND Field_Api_Name__c != 'Product2']) {

            if (attM.Is_Related_Mapping__c && oppProductFieldMap.containsKey(attM.Field_Api_Name__c.tolowerCase())) {
                attributeMappings.add(attM);
                mappedOppLineItemFields.add(attM.Field_Api_Name__c);
                attMappingIds.add(attM.Id);
            } else if (!attM.Is_Related_Mapping__c && oppFieldMap.containsKey(attM.Field_Api_Name__c.tolowerCase())) {
                oppPicklistMappings.add(attM);
                mappedOppFields.add(attM.Field_Api_Name__c);
                attMappingIds.add(attM.Id);
            }
        }
        currencyMap = new Map<String, sObject>();

        if (isCurrencyEnabled) {
            currencyMap = UtilityController.getAllCurrency();
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        soqlQuery = 'SELECT Account__c, Is_Referenceable__c, Referenceability_Status__c, Reference_Program_Candidate__c '
                    + 'FROM Reference_Basic_Information__c '
        			+ 'WHERE Is_Referenceable__c = true AND Contact__c = null AND Account__c != null';
        return Database.getQueryLocator(soqlQuery);
    }

    global void execute(Database.BatchableContext BC, List<Reference_Basic_Information__c> scope) {
        Set<Id> oppAccounts = new Set<Id>();

        for (Reference_Basic_Information__c rbi : scope) {
            oppAccounts.add(rbi.Account__c);
        }
        Map<Id, Map<Id, Account_Attribute__c>> allAccountAttributesAssociated = new Map<Id, Map<Id, Account_Attribute__c>>();
        Map<Id, Map<Id, Account_Attribute__c>> accountAttributesAssociated = new Map<Id, Map<Id, Account_Attribute__c>>();

        if (cs != null && cs.Minimum_Opportunity_Size_OP__c != null && oppAccounts.size() > 0) {

            if (attributeMappings.size() > 0 || oppPicklistMappings.size() > 0 || Test.isRunningTest()) {

                for (Id account : oppAccounts) {
                    accountAttributesAssociated.put(account, new Map<Id, Account_Attribute__c>());
                    allAccountAttributesAssociated.put(account, new Map<Id, Account_Attribute__c>());
                }
                List<Account_Attribute__c> createAccountAtt = new List<Account_Attribute__c>();
                Set<String> preventDuplicacy = new Set<String>();
                String oppQuery = '';

                if (isCurrencyEnabled) {
                    oppQuery = 'SELECT Id, AccountId, Amount, CurrencyIsoCode, StageName';
                } else {
                    oppQuery = 'SELECT Id, AccountId, Amount, StageName';
                }

                for (String fieldName : mappedOppFields) {
                    Schema.DescribeFieldResult fieldDesc = oppFieldMap.get(fieldName).getDescribe();

                    if ((fieldDesc.getType() == Schema.DisplayType.PICKLIST
                            || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST)
                            && fieldDesc.getName() != 'StageName') {
                        String theName = fieldDesc.getName();
                        oppQuery += ', ' + theName;
                    }
                }
                oppQuery += ', (SELECT Id, PricebookEntry.Product2Id';

                for (String fieldName : mappedOppLineItemFields) {
                    Schema.DescribeFieldResult fieldDesc = oppProductFieldMap.get(fieldName).getDescribe();

                    if (fieldDesc.getType() == Schema.DisplayType.PICKLIST
                            || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                        String theName = fieldDesc.getName();
                        oppQuery += ', ' + theName;
                    }
                }
                oppQuery += ' FROM OpportunityLineItems) FROM Opportunity WHERE AccountId IN :oppAccounts';
                List<Opportunity> opportunities = Database.query(oppQuery);
                Map<String, Map<String, Set<String>>> accountOppAttsMap = new Map<String, Map<String, Set<String>>>();
                Map<String, Map<String, Set<String>>> accountOppLineItemAttsMap = new Map<String, Map<String, Set<String>>>();
                Decimal thresholdAmount = isCurrencyEnabled
                    ? cs.Minimum_Opportunity_Size_OP__c / Decimal.valueOf(String.valueOf(currencyMap.get(String.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate')))
                    : cs.Minimum_Opportunity_Size_OP__c;

                for (Opportunity opp : opportunities) {

                    // for opportunity picklist mappings
                    if (opp.StageName == cs.Opportunity_Closed_Won_Stage__c) {

                        if (!accountOppAttsMap.containsKey(opp.AccountId)) {
                            accountOppAttsMap.put(opp.AccountId, new Map<String, Set<String>>());
                        }

                        for (String fieldName : mappedOppFields) {

                            if (opp.get(fieldName) != null) {

                                if (!accountOppAttsMap.get(opp.AccountId).containsKey(fieldName)) {
                                    accountOppAttsMap.get(opp.AccountId).put(fieldName, new Set<String>());
                                }

                                if (String.valueOf(opp.get(fieldName)).contains(';')) {

                                    for (String value : String.valueOf(opp.get(fieldName)).split(';')) {
                                        accountOppAttsMap.get(opp.AccountId).get(fieldName).add(value.trim());
                                    }
                                } else {
                                    accountOppAttsMap.get(opp.AccountId).get(fieldName).add(String.valueOf(opp.get(fieldName)));
                                }
                            }
                        }
                    }

                    // for opportunity product picklist mappings
                    if (opp.Amount != null) {
                        Decimal oppAmount = isCurrencyEnabled
                                ? opp.Amount / Decimal.valueOf(String.valueOf(currencyMap.get(String.valueOf(opp.get('CurrencyIsoCode'))).get('ConversionRate')))
                                : opp.Amount;

                        if (oppAmount >= thresholdAmount) {

                            if (opp.OpportunityLineItems != null && opp.OpportunityLineItems.size() > 0) {

                                if (!accountOppLineItemAttsMap.containsKey(opp.AccountId)) {
                                    accountOppLineItemAttsMap.put(opp.AccountId, new Map<String, Set<String>>());
                                }

                                for (OpportunityLineItem oli : opp.OpportunityLineItems) {

                                    for (String fieldName : mappedOppLineItemFields) {

                                        if (oli.get(fieldName) != null) {

                                            if (!accountOppLineItemAttsMap.get(opp.AccountId).containsKey(fieldName)) {
                                                accountOppLineItemAttsMap.get(opp.AccountId).put(fieldName, new Set<String>());
                                            }

                                            if (String.valueOf(oli.get(fieldName)).contains(';')) {

                                                for (String value : String.valueOf(oli.get(fieldName)).split(';')) {
                                                    accountOppLineItemAttsMap.get(opp.AccountId).get(fieldName).add(value.trim());
                                                }
                                            } else {
                                                accountOppLineItemAttsMap.get(opp.AccountId).get(fieldName).add(String.valueOf(oli.get(fieldName)));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                for (Account_Attribute__c accAtt : WithoutSharingHelperController.getAccountAttributeinRBI1(oppAccounts)) {

                    if (accAtt.From_Opportunity__c) {
                        accountAttributesAssociated.get(accAtt.Account__r.Id).put(accAtt.Attribute__r.Id, accAtt);
                    }
                    allAccountAttributesAssociated.get(accAtt.Account__r.Id).put(accAtt.Attribute__r.Id, accAtt);
                }

                for (Attribute__c att : [SELECT Id, Name, Attribute_Mapping__c, Attribute_Mapping__r.Field_Api_Name__c,
                                            Attribute_Mapping__r.Auto_populate__c, Attribute_Mapping__r.Inheritable__c,
                                            (SELECT Id, Name FROM Attributes__r) FROM Attribute__c
                                            WHERE Attribute_Mapping__c IN :attMappingIds
                                            AND Level__c = 0 AND Attribute_Mapping__r.Auto_populate__c = true]) {

                    for (String accId : accountOppAttsMap.keySet()) {

                        if (accountOppAttsMap.get(accId).containsKey(att.Attribute_Mapping__r.Field_Api_Name__c)) {
                            Set<String> fieldValues = accountOppAttsMap.get(accId).get(att.Attribute_Mapping__r.Field_Api_Name__c);

                            for (Attribute__c childAtt : att.Attributes__r) {

                                if (fieldValues.contains(childAtt.Name)
                                        && !preventDuplicacy.contains(accId + '' + childAtt.Id)
                                        && !allAccountAttributesAssociated.get(accId).containsKey(childAtt.Id)) {
                                    createAccountAtt.add(new Account_Attribute__c(Account__c = accId,
                                        Attribute__c = childAtt.Id,
                                        From_Opportunity__c = true,
                                        Inheritable__c = att.Attribute_Mapping__r.Inheritable__c
                                    ));
                                    preventDuplicacy.add(accId + '' + childAtt.Id);
                                }
                            }
                        }
                    }

                    for (String accId : accountOppLineItemAttsMap.keySet()) {

                        if (accountOppLineItemAttsMap.get(accId).containsKey(att.Attribute_Mapping__r.Field_Api_Name__c)) {
                            Set<String> fieldValues = accountOppLineItemAttsMap.get(accId).get(att.Attribute_Mapping__r.Field_Api_Name__c);

                            for (Attribute__c childAtt : att.Attributes__r) {

                                if (fieldValues.contains(childAtt.Name)
                                        && !preventDuplicacy.contains(accId + '' + childAtt.Id)
                                        && !allAccountAttributesAssociated.get(accId).containsKey(childAtt.Id)) {
                                    createAccountAtt.add(new Account_Attribute__c(Account__c = accId,
                                        Attribute__c = childAtt.Id,
                                        From_Opportunity__c = true,
                                        Inheritable__c = att.Attribute_Mapping__r.Inheritable__c
                                    ));
                                    preventDuplicacy.add(accId + '' + childAtt.Id);
                                }
                            }
                        }
                    }
                }
                ConstantsController.attMappingForAccount = false;

                if (createAccountAtt.size() > 0) {
                    ConstantsController.addAttributesToContact = true;
                    ConstantsController.addAttributesToContent = true;
                    database.upsert(createAccountAtt, false);
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {}
}