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
 * Description: Handler class for DML operations on opportunities
 * Last modified by: Rajneesh Raj (03 Jan, 2019)
 */
public with sharing class OpportunityTriggerHandler {
    /**
     * Properties and variables
     */
    public static List<Opportunity> newOpportunities;
    public static List<Opportunity> oldOpportunities;
    public static Map<Id, Opportunity> newOpportunityMap;
    public static Map<Id, Opportunity> oldOpportunityMap;
    public static Custom_Settings__c cs = UtilityController.getCustomSettings();
    private Static List<Data_Mapping__c> dmRecordList = [SELECT Id, Name, Label__c FROM Data_Mapping__c WHERE Name =: ConstantsController.OPP_ATTRIBUTE AND Label__c =: ConstantsController.OPP_ATTRIBUTE];
            
    /**
     * Method called on after insert of Opportunity
     */
    public static void onAfterInsert() {
        List<Reference_Lead__c> listReferenceLead = new List<Reference_Lead__c>();
        Map<String, sObject> currencyMap = new Map<String, sObject>();
        Boolean isCurrencyEnabled = (UtilityController.isCurrencyEnabled() && UserInfo.isMultiCurrencyOrganization());
        //  REF-1969
        List<Opportunity> oppList = new List<Opportunity>();
        Set<String> accountIdSet = new Set<String>();
        
        if (isCurrencyEnabled) {
            currencyMap = UtilityController.getAllCurrency();
        }
        
        Decimal amount = 0;
        
        if(cs.Minimum_Opportunity_Size__c != null)  {
            amount = (isCurrencyEnabled ? (cs.Minimum_Opportunity_Size__c / Decimal.valueOf(String.valueOf(
                                            currencyMap.get(String.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate')))) : cs.Minimum_Opportunity_Size__c);
        }
        
        //  REF-1308
        Decimal dcAmount = 0;
        List<String> oppIdFormNameCombineList = new List<String>(); 
        
        if(cs.Minimum_Opportunity_Size_DC__c != null)   {
            dcAmount = (isCurrencyEnabled ? (cs.Minimum_Opportunity_Size_DC__c / Decimal.valueOf(String.valueOf(
                                            currencyMap.get(String.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate')))) : cs.Minimum_Opportunity_Size_DC__c);
        }
        
        for (Opportunity opp : newOpportunities) {
            
            if(opp.Amount != null) {
                Decimal oppAmount = (isCurrencyEnabled ?
                                            (opp.Amount / Decimal.valueOf(String.valueOf(
                                            currencyMap.get(String.valueOf(opp.get('CurrencyIsoCode'))).get('ConversionRate')))) : opp.Amount);
                
                if (cs != null && cs.Opportunity_Closed_Won_Stage__c != null && cs.Minimum_Opportunity_Size__c != null
                    && cs.Client_Referenceability_check_days__c != null && cs.No_Response_days__c != null) {
                
                    //re #966
                    Date closeDate = opp.CloseDate.addDays(Integer.Valueof(cs.Client_Referenceability_check_days__c));
                    
                    if (opp.StageName == cs.Opportunity_Closed_Won_Stage__c && oppAmount >= amount && closeDate > date.today()) {
                        listReferenceLead.add(
                            new Reference_Lead__c(Reference_Lead_Account__c = opp.AccountId,
                                        Reference_Lead_Owner__c = opp.OwnerId,
                                        Reference_Lead_Opportunity__c = opp.Id,
                                        Opportunity_Owner__c = opp.OwnerId,
                                        Follow_up_date__c = closeDate,
                                        Reminder_Date__c = (cs.RLF_Reminder_Days__c != null
                                            ? opp.CloseDate.addDays(Integer.Valueof(cs.Client_Referenceability_check_days__c) + Integer.Valueof(cs.RLF_Reminder_Days__c))
                                            : null),
                                        No_Response_date__c = opp.CloseDate.addDays(Integer.Valueof(cs.Client_Referenceability_check_days__c
                                            + cs.No_Response_days__c)),
                                        Ref_Lead_From_Opportunity__c = true)); 
                    }                               
                }            

                //  For Data Collector  Ticket:- REF-1308
                if(cs != null && cs.Opportunity_Closed_Stages__c != null && cs.Minimum_Opportunity_Size_DC__c != null && cs.Enable_Data_Collector__c
                    && cs.Data_Collector_Name__c != null) {
                    
                    if(opp.StageName == cs.Opportunity_Closed_Stages__c && oppAmount >= dcAmount && opp.CloseDate >= System.today()) {
                        
                        String StrVal = opp.Id+'@@'+cs.Data_Collector_Name__c;
                        oppIdFormNameCombineList.add(StrVal);
                    }
                }           
            }

            if(opp.StageName != null && opp.StageName != '' && opp.StageName == cs.Opportunity_Closed_Won_Stage__c && opp.AccountId != null) {
                oppList.add(opp);
                accountIdSet.add(opp.AccountId);
            }    
        }
        
        // Call invocable Method
        if(oppIdFormNameCombineList.size() > 0) {
            DataCollectorInvocableClass.dataCollectorInvocableMethod(oppIdFormNameCombineList);
        }
        
        if (listReferenceLead.size() > 0) {
            insert listReferenceLead;
        }

        if(oppList.size() > 0 && !(dmRecordList.size() > 0)) {
            updateAccountAttributes(oppList, accountIdSet, false, true);
        }
    }
    
    /**
     * Method called on after update of Opportunity
     */
    public static void onAfterUpdate() {
        List<Reference_Lead__c> listReferenceLead = new List<Reference_Lead__c>();
        Map<String, sObject> currencyMap = new Map<String, sObject>();
        Boolean isCurrencyEnabled = (UtilityController.isCurrencyEnabled() && UserInfo.isMultiCurrencyOrganization());
        //  REF-1969
        Set<String> accountIdSet = new Set<String>();
        List<Opportunity> oppList = new List<Opportunity>();

        if (isCurrencyEnabled) {
            currencyMap = UtilityController.getAllCurrency();
        }
        
        if (cs != null && cs.Opportunity_Closed_Won_Stage__c != null
                    && cs.Minimum_Opportunity_Size__c != null && cs.Client_Referenceability_check_days__c != null
                    && cs.No_Response_days__c != null) {
            Set<String> removeDuplicacy = new Set<String>();
            
            for (Reference_Lead__c rl : [SELECT Reference_Lead_Opportunity__c FROM Reference_Lead__c
                                            WHERE Reference_Lead_Opportunity__c IN :newOpportunityMap.keySet()]) {
                removeDuplicacy.add(rl.Reference_Lead_Opportunity__c);
            }
            Decimal amount = (isCurrencyEnabled ? (cs.Minimum_Opportunity_Size__c / Decimal.valueOf(String.valueOf(
                                                currencyMap.get(String.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate')))) : cs.Minimum_Opportunity_Size__c);
            
            for (Opportunity opp : newOpportunities) {
                
                if (!removeDuplicacy.contains(opp.Id) && opp.Amount != null) {
                    Decimal oppAmount = (isCurrencyEnabled ?
                                            (opp.Amount / Decimal.valueOf(String.valueOf(
                                            currencyMap.get(String.valueOf(opp.get('CurrencyIsoCode'))).get('ConversionRate')))) : opp.Amount);
                    //re #966
                    Date closeDate = opp.CloseDate.addDays(Integer.Valueof(cs.Client_Referenceability_check_days__c));
                    
                    if (opp.StageName == cs.Opportunity_Closed_Won_Stage__c && oppAmount >= amount && closeDate > date.today()) {
                        listReferenceLead.add(
                            new Reference_Lead__c(Reference_Lead_Account__c = opp.AccountId,
                                        Reference_Lead_Owner__c = opp.OwnerId,
                                        Reference_Lead_Opportunity__c = opp.Id,
                                        Opportunity_Owner__c = opp.OwnerId,
                                        Follow_up_date__c = opp.CloseDate.addDays(Integer.Valueof(cs.Client_Referenceability_check_days__c)),
                                        Reminder_Date__c = (cs.RLF_Reminder_Days__c != null
                                            ? opp.CloseDate.addDays(Integer.Valueof(cs.Client_Referenceability_check_days__c)
                                                + Integer.Valueof(cs.RLF_Reminder_Days__c))
                                            : null),
                                        No_Response_date__c = opp.CloseDate.addDays(Integer.Valueof(cs.Client_Referenceability_check_days__c
                                            + cs.No_Response_days__c)),
                                        Ref_Lead_From_Opportunity__c = true));
                    }
                }
            }
        }
        Set<String> oppAccounts = new Set<String>();
        //  REF - 1302 
        List<Data_Mapping__c> dataMappingList = new List<Data_Mapping__c>();
        Decimal amount = 0;

        if (cs != null && cs.Minimum_Opportunity_Size_OP__c != null) {
            amount = (isCurrencyEnabled ? (cs.Minimum_Opportunity_Size_OP__c / Decimal.valueOf(String.valueOf(
                                                currencyMap.get(String.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate')))) : cs.Minimum_Opportunity_Size_OP__c);
        }
        
        //  REF-1308
        Decimal dcAmount = 0;
        List<String> oppIdFormNameCombineList = new List<String>(); 
        Set<Id> oppIdSet = new Set<Id>();
        
        for(Reference_Content__c rfc : [SELECT id, Opportunity__c FROM Reference_Content__c WHERE Opportunity__c  IN :newOpportunityMap.keySet()]) {
            oppIdSet.add(rfc.Opportunity__c);
        }
        
        if(cs.Minimum_Opportunity_Size_DC__c != null)   {
            dcAmount = (isCurrencyEnabled ? (cs.Minimum_Opportunity_Size_DC__c / Decimal.valueOf(String.valueOf(
                                            currencyMap.get(String.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate')))) : cs.Minimum_Opportunity_Size_DC__c);
        }

        for (Opportunity opp : newOpportunities) {
               
            //re #986
            if (opp.Amount != null) {
                Decimal oppAmount = (isCurrencyEnabled ?
                                            (opp.Amount / Decimal.valueOf(String.valueOf(
                                            currencyMap.get(String.valueOf(opp.get('CurrencyIsoCode'))).get('ConversionRate')))) : opp.Amount);
                
                if (cs != null && cs.Minimum_Opportunity_Size_OP__c != null) { 
                    
                    if (opp.StageName == 'Closed Won' && oppAmount >= amount) {
                        oppAccounts.add(opp.AccountId);   
                    }
                    
                    //  REF-2028
                    if (oppAmount >= amount && opp.AccountId != oldOpportunityMap.get(opp.Id).AccountId) {
                        oppAccounts.add(oldOpportunityMap.get(opp.Id).AccountId);
                    }
                }
                
                //  For Data Collector  Ticket:- REF-1308
                if(!oppIdSet.contains(opp.Id) && cs != null && cs.Opportunity_Closed_Stages__c != null && cs.Minimum_Opportunity_Size_DC__c != null && cs.Enable_Data_Collector__c
                    && cs.Data_Collector_Name__c != null) {
                    
                    if(opp.StageName == cs.Opportunity_Closed_Stages__c && oppAmount >= dcAmount && opp.CloseDate >= System.today()) {
                        
                        String StrVal = opp.Id+'@@'+cs.Data_Collector_Name__c;
                        oppIdFormNameCombineList.add(StrVal);
                    }
                }
            }

            if (cs != null && cs.Enable_Reference_Prompt__c && !System.isBatch() && !System.isFuture()) {

                if (opp.StageName != oldOpportunityMap.get(opp.Id).StageName) {
                    Data_Mapping__c dmRecord = new Data_Mapping__c();
                    dmRecord.Name = 'Adoption ' + opp.Name.mid(0, 60); // re REF-1850
                    dmRecord.Field_API_Name__c = opp.Id;
                    dmRecord.Label__c =  '"' + oldOpportunityMap.get(opp.Id).StageName +'" to "'+opp.StageName+'"';
                    dataMappingList.add(dmRecord);
                } 
            }

            if (opp.StageName != null && opp.StageName != '' && opp.StageName == cs.Opportunity_Closed_Won_Stage__c && opp.AccountId != null) {
                oppList.add(opp);
                accountIdSet.add(opp.AccountId);
            }

            if (opp.AccountId != oldOpportunityMap.get(opp.Id).AccountId && oldOpportunityMap.get(opp.Id).AccountId != null) {
                accountIdSet.add(oldOpportunityMap.get(opp.Id).AccountId);
            }       
        }
        
        if (listReferenceLead.size() > 0) {
            insert listReferenceLead;
        }
        
        if (oppAccounts.size() > 0) {
            List<Attribute_Mapping__c> attmappings = [SELECT Field_Api_Name__c, Auto_populate__c, Auto_add__c,
                                                        Auto_Update__c, Auto_delete__c
                                                        FROM Attribute_Mapping__c
                                                        WHERE Object__c = :ConstantsController.OPPORTUNITY
                                                        AND Field_Api_Name__c != null
                                                        //AND Field_Api_Name__c != 'Product2'
                                                        AND Is_Related_Mapping__c = true];
            
            if (attmappings.size() > 0) {
                checkAccountAttributes(oppAccounts, attmappings, currencyMap);
            }
        }

        if (dataMappingList.Size() > 0) {
            ConstantsController.shouldDataMappingProcessed = true;
            insert dataMappingList;
        }
        
        // Call invocable Method
        if(oppIdFormNameCombineList.size() > 0) {
            DataCollectorInvocableClass.dataCollectorInvocableMethod(oppIdFormNameCombineList);
        }

        if (accountIdSet.size() > 0 && !(dmRecordList.size() > 0) && !Test.isRunningTest()) {
            updateAccountAttributes(oppList, accountIdSet, false, false);
        }
    }
    
    /**
     * Method called on after delete of Opportunity
     */
    public static void onAfterDelete() {
        Map<String, sObject> currencyMap = new Map<String, sObject>();
        Boolean isCurrencyEnabled = (UtilityController.isCurrencyEnabled() && UserInfo.isMultiCurrencyOrganization());
        //	REF-1969
        Set<String> accountIdSet = new Set<String>();
        List<Opportunity> oppList = new List<Opportunity>();

        if (isCurrencyEnabled) {
            currencyMap = UtilityController.getAllCurrency();
        }
        // Delete old Reference Lead
        List<Reference_Lead__c> listOldRl = [SELECT Reference_Lead_Opportunity__c
                                                FROM Reference_Lead__c
                                                WHERE Reference_Lead_Opportunity__c = null];
        Set<String> oppAccounts = new Set<String>();
        
        for(Opportunity opp : oldOpportunities) {

            if (cs != null && cs.Minimum_Opportunity_Size_OP__c != null) {
                oppAccounts.add(opp.AccountId);
            }

            if (opp.StageName != null && opp.StageName != '' && opp.StageName == cs.Opportunity_Closed_Won_Stage__c && opp.AccountId != null) {
                oppList.add(opp);
                accountIdSet.add(opp.AccountId);
            }

            if (opp.AccountId != null) {
                accountIdSet.add(opp.AccountId);
            }
        }
        
        if (listOldRl.size() > 0) {
            delete listOldRl;
        }
        
        if (oppAccounts.size() > 0) {
            List<Attribute_Mapping__c> attmappings = [SELECT Field_Api_Name__c, Auto_populate__c, Auto_add__c,
                                                        Auto_Update__c, Auto_delete__c
                                                        FROM Attribute_Mapping__c
                                                        WHERE Object__c = :ConstantsController.OPPORTUNITY
                                                        AND Field_Api_Name__c != null
                                                        //AND Field_Api_Name__c != 'Product2'
                                                        AND Is_Related_Mapping__c = true];
            
            if (attmappings.size() > 0) {
                checkAccountAttributes(oppAccounts, attmappings, currencyMap);
            }
        }

        if (accountIdSet.size() > 0 && !(dmRecordList.size() > 0) && !Test.isRunningTest()) {
            updateAccountAttributes(oppList, accountIdSet, true, false);
        }
    }

    /**
     * Method called on after undelete of Opportunity
     */
    public static void onAfterUndelete() {
        List<Reference_Lead__c> listNewRL = new List<Reference_Lead__c>();
        List<Reference_Lead__c> listDeleteRL = new List<Reference_Lead__c>();
        Map<String, sObject> currencyMap = new Map<String, sObject>();
        Boolean isCurrencyEnabled = (UtilityController.isCurrencyEnabled() && UserInfo.isMultiCurrencyOrganization());
        //  REF-1969
        List<Opportunity> oppList = new List<Opportunity>();
        Set<String> accountIdSet = new Set<String>();

        if (isCurrencyEnabled) {
            currencyMap = UtilityController.getAllCurrency();
        }
        Set<Id> opportunityIds = new Set<Id>();
        
        if (cs != null && cs.Opportunity_Closed_Won_Stage__c != null && cs.Minimum_Opportunity_Size__c != null
                    && cs.Client_Referenceability_check_days__c != null && cs.No_Response_days__c != null) {
            Decimal amount = (isCurrencyEnabled ? (cs.Minimum_Opportunity_Size__c / Decimal.valueOf(String.valueOf(
                                                currencyMap.get(String.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate')))) : cs.Minimum_Opportunity_Size__c);
            
            for (Opportunity opp : newOpportunities) {
                
                if (opp.Amount != null) {
                    Decimal oppAmount = (isCurrencyEnabled ?
                                            (opp.Amount / Decimal.valueOf(String.valueOf(
                                            currencyMap.get(String.valueOf(opp.get('CurrencyIsoCode'))).get('ConversionRate')))) : opp.Amount);
                    //re #966
                    Date closeDate = opp.CloseDate.addDays(Integer.Valueof(cs.Client_Referenceability_check_days__c));
                    
                    if (opp.StageName == cs.Opportunity_Closed_Won_Stage__c && oppAmount >= amount && closeDate > date.today()) {
                        opportunityIds.add(opp.Id);
                    }
                }
            }
            
            for (Opportunity opp : [SELECT Id, AccountId, OwnerId, CloseDate,
                                    (SELECT Id FROM Reference_Leads__r ORDER BY CreatedDate ASC)
                                    FROM Opportunity WHERE Id IN :opportunityIds]) {
                Integer countRl = 0;
                
                for (Reference_Lead__c rl : opp.Reference_Leads__r) {
                    countRl++;
                    
                    if (countRl != 1) {
                        listDeleteRL.add(rl);
                    }
                }
                
                if (countRl == 0) {
                    listNewRL.add(
                        new Reference_Lead__c(Reference_Lead_Account__c = opp.AccountId,
                                    Reference_Lead_Owner__c = opp.OwnerId,
                                    Reference_Lead_Opportunity__c = opp.Id,
                                    Opportunity_Owner__c = opp.OwnerId,
                                    Follow_up_date__c = opp.CloseDate.addDays(Integer.Valueof(cs.Client_Referenceability_check_days__c)),
                                    Reminder_Date__c = (cs.RLF_Reminder_Days__c != null
                                        ? opp.CloseDate.addDays(Integer.Valueof(cs.Client_Referenceability_check_days__c)
                                            + Integer.Valueof(cs.RLF_Reminder_Days__c))
                                        : null),
                                    No_Response_date__c = opp.CloseDate.addDays(Integer.Valueof(cs.Client_Referenceability_check_days__c
                                        + cs.No_Response_days__c))));
                }
            }
            
            // Insert New RL
            if (listNewRL.size() > 0) {
                insert listNewRL;
            }
            
            // Delete RL
            if (listDeleteRL.size() > 0) {
                delete listDeleteRL;
            }
        }
        Set<String> oppAccounts = new Set<String>();

        Decimal csAmount = 0;
        if (cs != null && cs.Minimum_Opportunity_Size_OP__c != null) {
            csAmount = (isCurrencyEnabled ? (cs.Minimum_Opportunity_Size_OP__c / Decimal.valueOf(String.valueOf(
                                                currencyMap.get(String.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate')))) : cs.Minimum_Opportunity_Size_OP__c);
        } 

        for (Opportunity opp : newOpportunities) {
            
            if (opp.Amount != null) {
                Decimal oppAmount = (isCurrencyEnabled ?
                                        (opp.Amount / Decimal.valueOf(String.valueOf(
                                        currencyMap.get(String.valueOf(opp.get('CurrencyIsoCode'))).get('ConversionRate')))) : opp.Amount);
                
                if (opp.StageName == 'Closed Won' && oppAmount >= csAmount) {
                    oppAccounts.add(opp.AccountId);
                }
            }

            if(opp.StageName != null && opp.StageName != '' && opp.StageName == cs.Opportunity_Closed_Won_Stage__c && opp.AccountId != null) {
                oppList.add(opp);
                accountIdSet.add(opp.AccountId);
            }
        }        
        
        if (oppAccounts.size() > 0) {
            List<Attribute_Mapping__c> attmappings = [SELECT Field_Api_Name__c, Auto_populate__c, Auto_add__c,
                                                        Auto_Update__c, Auto_delete__c
                                                        FROM Attribute_Mapping__c
                                                        WHERE Object__c = :ConstantsController.OPPORTUNITY
                                                        AND Field_Api_Name__c != null
                                                        AND Is_Related_Mapping__c = true];
            
            if (attmappings.size() > 0) {
                checkAccountAttributes(oppAccounts, attmappings, currencyMap);
            }
        }

        if (oppList.size() > 0 && !(dmRecordList.size() > 0)) {
            updateAccountAttributes(oppList, accountIdSet, false, true);
        }
    }
    
    /**
     * Method to create/delete Account Atrributes
     */
    private static void checkAccountAttributes(Set<String> oppAccounts, List<Attribute_Mapping__c> attributeMappings,
                                                Map<String, sObject> currencyMap) {
        Set<String> oppIds = new Set<String>();
        Map<Id, Set<String>> oppAccountMap = new Map<Id, Set<String>>();
        Boolean isCurrencyEnabled = (UtilityController.isCurrencyEnabled() && UserInfo.isMultiCurrencyOrganization());
        Map<String, Reference_Basic_Information__c> accountMap = new Map<String, Reference_Basic_Information__c>();
        Map<Id, Map<Id, Account_Attribute__c>> allAccountAttributesAssociated = new Map<Id, Map<Id, Account_Attribute__c>>();
        Map<Id, Map<Id, Account_Attribute__c>> accountAttributesAssociated = new Map<Id, Map<Id, Account_Attribute__c>>();
        Map<String, Map<String, Set<String>>> oppProductsPicklistFieldValues = new Map<String, Map<String, Set<String>>>();
        
        if (cs != null && cs.Minimum_Opportunity_Size_OP__c != null) {
            
            for (Account account : [SELECT Id, (SELECT Account__c, Is_Referenceable__c, Referenceability_Status__c,
                                        Reference_Program_Candidate__c
                                        FROM Reference_Basic_Informations__r
                                        WHERE Is_Referenceable__c = true
                                        AND Contact__c = null)
                                    FROM Account WHERE Id IN :oppAccounts]) {
                
                if (account.Reference_Basic_Informations__r.size() > 0) {
                    
                    if (!oppAccountMap.containsKey(account.Id)) {
                        oppAccountMap.put(account.Id, new Set<String>());
                    }
                    accountAttributesAssociated.put(account.Id, new Map<Id, Account_Attribute__c>());
                    allAccountAttributesAssociated.put(account.Id, new Map<Id, Account_Attribute__c>());
                    oppProductsPicklistFieldValues.put(account.Id, new Map<String, Set<String>>());
                }
            }
        }
        
        if (oppAccountMap != null && oppAccountMap.size() > 0) {
            Map<String, Schema.SObjectField> oppProductField_map = schema.SObjectType.OpportunityLineItem.fields.getMap();
            Map<String, List<OpportunityLineItem>> opplineItemMap = new Map<String, List<OpportunityLineItem>>();
            List<Account_Attribute__c> accAttToBeDeleted = new List<Account_Attribute__c>();
            List<Account_Attribute__c> createAccountAtt = new List<Account_Attribute__c>();
            Set<String> preventDuplicacy = new Set<String>();
            Set<String> oppProductAttMappingSet = new Set<String>();
            Map<Id, Set<Id>> mappingCreateAttribute = new Map<Id, Set<Id>>();
            Set<String> fieldAPINames = new Set<String>();
            Map<String, Set<String>> oppProductMap = new Map<String, Set<String>>();
            String theQueryOpp = '';
            
            if (isCurrencyEnabled) {
                theQueryOpp = 'SELECT PricebookEntry.Product2Id, OpportunityId, Opportunity.AccountId, '
                                + 'Opportunity.CurrencyIsoCode, Opportunity.Amount';
            } else {
                theQueryOpp = 'SELECT PricebookEntry.Product2Id, OpportunityId, Opportunity.AccountId, Opportunity.Amount';
            }
            
            for (String fieldName : oppProductField_map.keyset()) {
                Schema.DescribeFieldResult fieldDesc = oppProductField_map.get(fieldName).getDescribe();
                
                if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    String theName = fieldDesc.getName();
                    // Continue building your dynamic query String
                    theQueryOpp += ', ' + theName;
                    fieldAPINames.add(theName);
                }
            }
            Decimal amount = (isCurrencyEnabled ? (cs.Minimum_Opportunity_Size_OP__c / Decimal.valueOf(String.valueOf(
                                                currencyMap.get(String.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate')))) : cs.Minimum_Opportunity_Size_OP__c);
            
            
            if (isCurrencyEnabled) {
                theQueryOpp += ' FROM OpportunityLineItem WHERE Opportunity.AccountId IN :oppAccounts '
                                + 'AND Opportunity.StageName = \'Closed Won\' ';
            } else {
                theQueryOpp += ' FROM OpportunityLineItem WHERE Opportunity.AccountId IN :oppAccounts '
                                + 'AND Opportunity.StageName = \'Closed Won\' AND Opportunity.Amount >= :amount';
            }
            List<OpportunityLineItem> oppLineItems = Database.query(theQueryOpp);
            List<String> attMappings = new List<String>();
            
            for (Attribute_Mapping__c attM : attributeMappings) {
                
                if (fieldAPINames.contains(attM.Field_Api_Name__c)
                            && oppProductField_map.containsKey(attM.Field_Api_Name__c.tolowerCase())) {
                    attMappings.add(attM.Id);
                    oppProductAttMappingSet.add(attM.Field_Api_Name__c);
                }
                
                //re #741
                if (attM.Field_Api_Name__c == 'Product2') {
                    attMappings.add(attM.Id);
                }
            }
            
            for (OpportunityLineItem oppLineItem : oppLineItems) {
                
                if (oppLineItem.Opportunity.Amount != null) {
                    Decimal oppAmount = (isCurrencyEnabled ?
                                            (oppLineItem.Opportunity.Amount / Decimal.valueOf(String.valueOf(
                                            currencyMap.get(String.valueOf(oppLineItem.Opportunity.get('CurrencyIsoCode'))).get('ConversionRate')))) 
                                            : oppLineItem.Opportunity.Amount);
                    
                    if (oppAmount >= amount) {
                        
                        if (!opplineItemMap.containsKey(oppLineItem.OpportunityId)) {
                            opplineItemMap.put(oppLineItem.OpportunityId, new List<OpportunityLineItem>());
                            oppProductMap.put(oppLineItem.OpportunityId, new Set<String>());
                        }
                        opplineItemMap.get(oppLineItem.OpportunityId).add(oppLineItem);
                        oppProductMap.get(oppLineItem.OpportunityId).add(oppLineItem.PricebookEntry.Product2Id);
                        
                        if (oppAccountMap.containsKey(oppLineItem.Opportunity.AccountId)) {
                            oppAccountMap.get(oppLineItem.Opportunity.AccountId).add(oppLineItem.OpportunityId);
                        }
                    }
                }
            }
            
            for (Id accountId : oppAccountMap.keySet()) {
                Map<String, Set<String>> tempMap = new Map<String, Set<String>>();
                tempMap.putAll(oppProductsPicklistFieldValues.get(accountId));
                
                for (String field : oppProductAttMappingSet) {
                    tempMap.put(field, new Set<String>());
                }
                
                for (String oppId : oppAccountMap.get(accountId)) {
                    
                    if (opplineItemMap.containsKey(oppId)) {
                        
                        for (OpportunityLineItem oppLineItem : opplineItemMap.get(oppId)) {
                            
                            for (String field : oppProductAttMappingSet) {
                                
                                if (oppLineItem.get(field) != null) {
                                    
                                    if (String.valueOf(oppLineItem.get(field)).contains(';')) {
                                        
                                        for (String value : String.valueOf(oppLineItem.get(field)).split(';')) {
                                            tempMap.get(field).add(value.trim());
                                        }
                                    } else {
                                        tempMap.get(field).add(String.valueOf(oppLineItem.get(field)));
                                    }
                                }
                            }
                        }
                    }
                }
                oppProductsPicklistFieldValues.get(accountId).putAll(tempMap);
            }
            
            for (Account_Attribute__c accAtt : WithoutSharingHelperController.getAccountAttributeinRBI1(oppAccountMap.keySet())) {
                
                if (accAtt.From_Opportunity__c) {
                    accountAttributesAssociated.get(accAtt.Account__r.Id).put(accAtt.Attribute__r.Id, accAtt);
                }
                allAccountAttributesAssociated.get(accAtt.Account__r.Id).put(accAtt.Attribute__r.Id, accAtt);
            }
            
            for (Attribute__c att : [SELECT Id, Name, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c,
                                        Attribute_Mapping__r.Auto_populate__c, Attribute_Mapping__r.Inheritable__c,
                                        (SELECT Id, Name, Product_ID__c FROM Attributes__r)
                                        FROM Attribute__c
                                        WHERE Attribute_Mapping__c IN :attMappings
                                        AND Level__c = 0 AND Attribute_Mapping__r.Auto_populate__c = true]) {
                
                for (String accountId : oppAccountMap.keySet()) {
                    
                    if (!mappingCreateAttribute.containsKey(accountId)) {
                        mappingCreateAttribute.put(accountId, new Set<Id>());
                    }
                    Map<String, Set<String>> tempMap = (oppProductsPicklistFieldValues.containsKey(accountId) ? 
                                                                        oppProductsPicklistFieldValues.get(accountId) :
                                                                        new Map<String, Set<String>>());
                    
                    //re #741
                    if (tempMap != null && tempMap.containsKey(att.Attribute_Mapping__r.Field_Api_Name__c) 
                                                        && att.Attribute_Mapping__r.Field_Api_Name__c != 'Product2') {
                        Set<String> fieldValues = tempMap.get(att.Attribute_Mapping__r.Field_Api_Name__c);
                        
                        for (Attribute__c childAtt : att.Attributes__r) {
                            
                            if (fieldValues.contains(childAtt.Name)
                                        && !preventDuplicacy.contains(accountId + '' + childAtt.Id)
                                        && !allAccountAttributesAssociated.get(accountId).containsKey(childAtt.Id)) {
                                createAccountAtt.add(new Account_Attribute__c(Account__c = accountId,
                                                                                Attribute__c = childAtt.Id,
                                                                                From_Opportunity__c = true, Inheritable__c = att.Attribute_Mapping__r.Inheritable__c));
                                preventDuplicacy.add(accountId + '' + childAtt.Id);
                            }
                            
                            if (fieldValues.contains(childAtt.Name)) {
                                mappingCreateAttribute.get(accountId).add(childAtt.Id);
                            }
                        }
                    //re #741
                    } else if (att.Attribute_Mapping__r.Field_Api_Name__c == 'Product2') {
                        
                        for (Attribute__c childAtt : att.Attributes__r) {
                            
                            for (String oppId : oppAccountMap.get(accountId)) {
                                
                                if (oppProductMap != null && oppProductMap.containsKey(oppId)) {
                                    
                                    for (String productId : oppProductMap.get(oppId)) {
                                        
                                        if (childAtt.Product_ID__c == productId && !preventDuplicacy.contains(accountId + '' + childAtt.Id) 
                                                            && !allAccountAttributesAssociated.get(accountId).containsKey(childAtt.Id)) {
                                            createAccountAtt.add(new Account_Attribute__c(Account__c = accountId, Attribute__c = childAtt.Id, From_Opportunity__c = true, Inheritable__c = att.Attribute_Mapping__r.Inheritable__c));
                                            preventDuplicacy.add(accountId + '' + childAtt.Id);
                                        }
                                        
                                        if (childAtt.Product_ID__c == productId) {
                                            mappingCreateAttribute.get(accountId).add(childAtt.Id);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            for (String accId : accountAttributesAssociated.keySet()) {
                
                for (Id attId : accountAttributesAssociated.get(accId).keySet()) {
                    
                    if (mappingCreateAttribute.containsKey(accId) && !mappingCreateAttribute.get(accId).contains(attId)
                                && accountAttributesAssociated.get(accId).containsKey(attId)) {
                        accAttToBeDeleted.add(accountAttributesAssociated.get(accId).get(attId));
                    }
                }
            }
            
            /*
            *   REF-2070 (Rajneesh Raj, Jan 03,2019)
            *   Delete Contact Attribute if that attribute is inheritable and inherited from Account
            */
            List<Contact_Attribute__c> contactsAttsToBeDel = new List<Contact_Attribute__c>();

            for (Contact_Attribute__c ca : [SELECT Id, Attribute__c, Account__c FROM Contact_Attribute__c
                                            WHERE Account__c IN :accountAttributesAssociated.keySet()
                                            AND From_Account__c = true]) {
                
                for (Account_Attribute__c accAtt : accAttToBeDeleted) {
                    
                    if (ca.Account__c == accAtt.Account__c && ca.Attribute__c == accAtt.Attribute__c) {
                        contactsAttsToBeDel.add(ca); 
                    }                
                }
            }
            
            ConstantsController.attMappingForAccount = false;
            ConstantsController.attMappingForContact = false;
            
            if (contactsAttsToBeDel.size() > 0) {
                WithoutSharingHelperController.deleteContactAttributes(contactsAttsToBeDel);
                Database.emptyRecycleBin(contactsAttsToBeDel);
            }

            if (accAttToBeDeleted.size() > 0) {
                //re #741
                accAttToBeDeleted = WithoutSharingHelperController.deleteAccountAttributes(accAttToBeDeleted);
                Database.emptyRecycleBin( accAttToBeDeleted );
            }
            
            if (createAccountAtt.size() > 0) {
                ConstantsController.addAttributesToContact = true;
                ConstantsController.addAttributesToContent = true;
                WithoutSharingHelperController.upsertAccountAttributes(createAccountAtt);
            }
        }
    }

    /**
     * method to creatae Account Attributes from opportunity picklist values for which Attribute Mappings are created
     * author: Gaurav Saini (REF-2346)
     */
    private static void updateAccountAttributes(List<Opportunity> oppList, Set<String> oppAccountIds, Boolean isDelete, Boolean isInsert) {
        Map<String, Schema.SObjectType> schemaMap = CRUDAndFLSCheckController.sObjectsMap;
        Map<String, Schema.SObjectField> oppFieldsMap = schemaMap.get('Opportunity').getDescribe().fields.getMap();
        Set<String> fieldAPINameSet = new Set<String>();
        Set<String> accIdsWithRbi = new Set<String>();
        String rbiQuery = 'SELECT Id, Account__c FROM Reference_Basic_Information__c WHERE Account__c IN :oppAccountIds '
                            + 'AND Contact__c = null AND Is_Referenceable__c = true LIMIT '
                            + (Limits.getLimitQueryRows() - Limits.getQueryRows());

        for (Reference_Basic_Information__c rbi : Database.query(rbiQuery)) {
			accIdsWithRbi.add(rbi.Account__c);
		}

        for (String fieldName : oppFieldsMap.keyset()) {
            Schema.DescribeFieldResult fieldDesc = oppFieldsMap.get(fieldName).getDescribe();

            if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                String theName = fieldDesc.getName();

                if (theName != 'StageName') {
                    fieldAPINameSet.add(theName);
                }
            }
        }
        List<Account_Attribute__c> createAccountAttList = new List<Account_Attribute__c>();
		List<Account_Attribute__c> deleteAccountAttList = new List<Account_Attribute__c>();
        Map<Id, Map<Id, Account_Attribute__c>> accIdAccAttriListMap = new Map<Id, Map<id, Account_Attribute__c>>();
        Map<Id, Set<Id>> newlyAddedAccAttriListMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> oldValueoppRefAttributeMap = new Map<Id, Set<Id>>();            

        for (Account_Attribute__c accAttr : [SELECT Id, Account__c, Attribute__c FROM Account_Attribute__c
                                                WHERE Account__c IN :oppAccountIds
                                                LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]) {

            if (!accIdAccAttriListMap.containsKey(accAttr.Account__c)) {
                accIdAccAttriListMap.put(accAttr.Account__c, new Map<Id, Account_Attribute__c>());
            }
            accIdAccAttriListMap.get(accAttr.Account__c).put(accAttr.Attribute__c, accAttr);
        }
        Map<String, Map<String, String>> fieldAttributeMap = new Map<String, Map<String, String>>();

        for (Attribute__c att : [SELECT Id, Name, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c,
                                    (SELECT Id, Name, Parent__r.Inheritable__c FROM Attributes__r)
                                    FROM Attribute__c
                                    WHERE Attribute_Mapping__r.Field_Api_Name__c IN :fieldAPINameSet
                                    AND Attribute_Mapping__r.Related_Object__c = ''
                                    AND Attribute_Mapping__r.Object__c = 'Opportunity'
                                    AND Attribute_Mapping__r.Auto_populate__c = true
                                    LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]) {

            if (!fieldAttributeMap.containsKey(att.Attribute_Mapping__r.Field_Api_Name__c)) {
                fieldAttributeMap.put(att.Attribute_Mapping__r.Field_Api_Name__c, new Map<String, String>());
            }

            for (Attribute__c chldAtt : att.Attributes__r) {
                fieldAttributeMap.get(att.Attribute_Mapping__r.Field_Api_Name__c).put(chldAtt.Name, chldAtt.Id + '#' + chldAtt.Parent__r.Inheritable__c);
            }
        }

        if (fieldAttributeMap.size() > 0) {

            for (String fildApiName : fieldAttributeMap.keySet()) {

                for (Opportunity oppRec : oppList) {
                    Set<String> fieldValue = new Set<String>();
                    Set<String> oldFieldValue = new Set<String>();

                    if (oppRec.get(fildApiName) != null && oppRec.get(fildApiName) != '') {

                        if (String.valueOf(oppRec.get(fildApiName)).contains(';')) {

                            for (String fldVal : String.valueOf(oppRec.get(fildApiName)).split(';')) {
                                fieldValue.add(fldVal.trim());
                            }
                        } else {
                            fieldValue.add(String.valueOf(oppRec.get(fildApiName)).trim());
                        }

                        for (String oppFldValue : fieldValue) {

                            if (newlyAddedAccAttriListMap.containsKey(oppRec.AccountId)
                                    && !newlyAddedAccAttriListMap.get(oppRec.AccountId).contains(fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[0])) {

                                if (fieldAttributeMap.get(String.valueOf(fildApiName)).containsKey(oppFldValue)
                                        && !accIdAccAttriListMap.containsKey(oppRec.AccountId)
                                        && accIdsWithRbi.contains(oppRec.AccountId)) {
                                    createAccountAttList.add(new Account_Attribute__c(Account__c = oppRec.AccountId,
                                        Attribute__c = fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[0],
                                        Inheritable__c = Boolean.valueOf(fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[1]),
                                        From_Opportunity__c = true
                                    ));
                                } else if (fieldAttributeMap.get(String.valueOf(fildApiName)).containsKey(oppFldValue)
                                        && accIdAccAttriListMap.containsKey(oppRec.AccountId)
                                        && !accIdAccAttriListMap.get(oppRec.AccountId).containsKey(fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[0])
                                        && accIdsWithRbi.contains(oppRec.AccountId)) {
                                    createAccountAttList.add(new Account_Attribute__c(Account__c = oppRec.AccountId,
                                        Attribute__c = fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[0],
                                        Inheritable__c = Boolean.valueOf(fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[1]),
                                        From_Opportunity__c = true
                                    ));	
                                }

                                if (fieldAttributeMap.get(String.valueOf(fildApiName)).containsKey(oppFldValue)) {

                                    if (!newlyAddedAccAttriListMap.containsKey(oppRec.AccountId)) {
                                        newlyAddedAccAttriListMap.put(oppRec.AccountId, new Set<Id>());
                                    }
                                    newlyAddedAccAttriListMap.get(oppRec.AccountId).add(fieldAttributeMap.get(fildApiName).get(oppFldValue).split('#')[0]);
                                }
                            }
                        }
                    }

                    if (!isInsert && oldOpportunityMap.containsKey(oppRec.Id)
                            && oldOpportunityMap.get(oppRec.Id).get(fildApiName) != null
                            && oldOpportunityMap.get(oppRec.Id).get(fildApiName) != ''
                            && (oldOpportunityMap.get(oppRec.Id).get('AccountId') != oppRec.get('AccountId')
                                || oldOpportunityMap.get(oppRec.Id).get(fildApiName) != oppRec.get(fildApiName))) {

                        if (String.valueOf(oldOpportunityMap.get(oppRec.Id).get(fildApiName)).contains(';')) {

                            for (String fldVal : String.valueOf(oldOpportunityMap.get(oppRec.Id).get(fildApiName)).split(';')) {
                                oldFieldValue.add(fldVal.trim());
                            }
                        } else {
                            oldFieldValue.add(String.valueOf(oldOpportunityMap.get(oppRec.Id).get(fildApiName)).trim());
                        }

                        for (String fldValue : oldFieldValue) {

                            if (fieldAttributeMap.get(String.valueOf(fildApiName)).containsKey(fldValue)) {

                                if (!oldValueoppRefAttributeMap.containsKey(oldOpportunityMap.get(oppRec.Id).AccountId)) {
                                    oldValueoppRefAttributeMap.put(oldOpportunityMap.get(oppRec.Id).AccountId, new Set<Id>());
                                }
                                oldValueoppRefAttributeMap.get(oldOpportunityMap.get(oppRec.Id).AccountId).add(fieldAttributeMap.get(fildApiName).get(fldValue).split('#')[0]);
                            }
                        }
                    }
                }
            }

            if (oldValueoppRefAttributeMap.size() > 0) {

                for (String accountId : oldValueoppRefAttributeMap.keySet()) {

                    if (accIdAccAttriListMap.containsKey(accountId)) {

                        if (newlyAddedAccAttriListMap.containsKey(accountId)) {

                            for (Id attributeId : oldValueoppRefAttributeMap.get(accountId)) {

                                if (!newlyAddedAccAttriListMap.get(accountId).contains(attributeId)) {

                                    if (accIdAccAttriListMap.get(accountId).containsKey(attributeId)) {
                                        deleteAccountAttList.add(accIdAccAttriListMap.get(accountId).get(attributeId));
                                    }
                                }                                    
                            }
                        } else {

                            for (Id attributeId : oldValueoppRefAttributeMap.get(accountId)) {

                                if (accIdAccAttriListMap.get(accountId).containsKey(attributeId)) {
                                    deleteAccountAttList.add(accIdAccAttriListMap.get(accountId).get(attributeId));
                                }
                            }
                        }
                    }
                }
            }
        }
        ConstantsController.attMappingForAccount = false;
        ConstantsController.attMappingForContact = false;

        if (deleteAccountAttList.size() > 0) {
            deleteAccountAttList = WithoutSharingHelperController.deleteAccountAttributes(deleteAccountAttList);
            Database.emptyRecycleBin(deleteAccountAttList);
        }

        if (createAccountAttList.size() > 0) {
            WithoutSharingHelperController.upsertAccountAttributes(createAccountAttList);
        }
    }
}