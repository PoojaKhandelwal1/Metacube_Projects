/**
 * ReferenceEdge
 *
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc.
 * @website : www.point-of-reference.com 
 *
 * Disclaimer : THIS SOFTWARE IS PROVIDED "AS-IS" BY POINT OF REFERENCE ("POR"), 
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
public with sharing class OpportunityProductTriggerHandler {
	 
    /**
     * Method called on after insert of Attribute Mapping
     */
    public static void onAfterInsert(List<OpportunityLineItem> newList) {
    	
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Set<Id> oppIds = new Set<Id>();
        Map<String, sObject> currencyMap = new Map<String, sObject>();
        Boolean isCurrencyEnabled = (UtilityController.isCurrencyEnabled() && UserInfo.isMultiCurrencyOrganization());
        
        if (isCurrencyEnabled) {
            currencyMap = UtilityController.getAllCurrency();
        }
        
        for (OpportunityLineItem oppLineItem : newList) {
            oppIds.add(oppLineItem.OpportunityId);
        }
        Set<String> oppAccounts = new Set<String>();
        
        if (cs != null && cs.Minimum_Opportunity_Size_OP__c != null) {
        	Decimal amount = (isCurrencyEnabled ? (cs.Minimum_Opportunity_Size_OP__c / Decimal.valueOf(String.valueOf(
            									currencyMap.get(String.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate')))) 
            									: cs.Minimum_Opportunity_Size_OP__c);
        	String query = (isCurrencyEnabled ? 'SELECT Id, AccountId, StageName, CurrencyIsoCode, Amount FROM Opportunity WHERE Id IN :oppIds'
            									: 'SELECT Id, AccountId, StageName, Amount FROM Opportunity WHERE Id IN :oppIds');
        	
        	for (Opportunity opp : Database.query(query)) {
            	
                if (opp.StageName == 'Closed Won' && opp.Amount != null) {
                	Decimal oppAmount = (isCurrencyEnabled ?
	            							(opp.Amount / Decimal.valueOf(String.valueOf(
	            							currencyMap.get(String.valueOf(opp.get('CurrencyIsoCode'))).get('ConversionRate')))) : opp.Amount);
	            	
                    if (oppAmount >= amount) {
                        oppAccounts.add(opp.AccountId);
                    }
                }
            }
        }
        
        if (oppAccounts.size() > 0) {
            List<Attribute_Mapping__c> attmappings = [SELECT Field_Api_Name__c, Auto_populate__c, Auto_add__c, Auto_Update__c, Auto_delete__c
                        FROM Attribute_Mapping__c WHERE object__c = :ConstantsController.OPPORTUNITY
                        AND Field_Api_Name__c != null AND Is_Related_Mapping__c = true];//re #741
                        
            if (attmappings.size() > 0 || Test.isRunningTest()) {
                checkAccountAttributes(oppAccounts, attmappings, cs, currencyMap, false);
            }
        }
    }
    
    /**
     * Method called on after update of Attribute Mapping
     */
    public static void onAfterUpdate(List<OpportunityLineItem> newList, List<OpportunityLineItem> oldList, Map<Id, OpportunityLineItem> oldMap) {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Set<Id> oppIds = new Set<Id>();
        Map<String, sObject> currencyMap = new Map<String, sObject>();
        Boolean isCurrencyEnabled = (UtilityController.isCurrencyEnabled() && UserInfo.isMultiCurrencyOrganization());
        
        if (isCurrencyEnabled) {
            currencyMap = UtilityController.getAllCurrency();
        }
        
        for (OpportunityLineItem oppLineItem : newList) {
            oppIds.add(oppLineItem.OpportunityId);
        }
        Set<String> oppAccounts = new Set<String>();
        
        if (cs != null && cs.Minimum_Opportunity_Size_OP__c != null) {
        	Decimal amount = (isCurrencyEnabled ? (cs.Minimum_Opportunity_Size_OP__c / Decimal.valueOf(String.valueOf(
            									currencyMap.get(String.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate')))) 
            									: cs.Minimum_Opportunity_Size_OP__c);
        	String query = (isCurrencyEnabled ? 'SELECT Id, AccountId, StageName, CurrencyIsoCode, Amount FROM Opportunity WHERE Id IN :oppIds'
            									: 'SELECT Id, AccountId, StageName, Amount FROM Opportunity WHERE Id IN :oppIds');
        	
        	for (Opportunity opp : Database.query(query)) {
            	
                if (opp.StageName == 'Closed Won' && opp.Amount != null) {
                    Decimal oppAmount = (isCurrencyEnabled ?
            							(opp.Amount / Decimal.valueOf(String.valueOf(
            							currencyMap.get(String.valueOf(opp.get('CurrencyIsoCode'))).get('ConversionRate')))) : opp.Amount);
            	
                    if (oppAmount >= amount) {
                        oppAccounts.add(opp.AccountId);
                    }
                }
            }
        }
        
        if (oppAccounts.size() > 0) {
            List<Attribute_Mapping__c> attmappings = [SELECT Field_Api_Name__c, Auto_populate__c, Auto_add__c, Auto_Update__c, Auto_delete__c
                        FROM Attribute_Mapping__c WHERE object__c = : ConstantsController.OPPORTUNITY
                        AND Field_Api_Name__c != null AND Field_Api_Name__c != 'Product2' AND Is_Related_Mapping__c = true];
                    
            if (attmappings.size() > 0 || Test.isRunningTest()) {
                checkAccountAttributes(oppAccounts, attmappings, cs, currencyMap, true);
            }
        }
    }
    
    /**
     * Method called on after delete of Attribute Mapping
     */
    public static void onAfterDelete(List<OpportunityLineItem> oldList) {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Boolean isCurrencyEnabled = (UtilityController.isCurrencyEnabled() && UserInfo.isMultiCurrencyOrganization());
        Set<Id> oppIds = new Set<Id>();
        Map<String, sObject> currencyMap = new Map<String, sObject>();
        
        if (isCurrencyEnabled) {
            currencyMap = UtilityController.getAllCurrency();
        }
        
        for (OpportunityLineItem oppLineItem : oldList) {
            oppIds.add(oppLineItem.OpportunityId);
        }
        Set<String> oppAccounts = new Set<String>();
        
        if (cs != null && cs.Minimum_Opportunity_Size_OP__c != null) {
        	
            for (Opportunity opp : [SELECT Id, AccountId, StageName, Amount FROM Opportunity WHERE Id IN :oppIds]) {
                oppAccounts.add(opp.AccountId);
            }
        }
        
        if (oppAccounts.size() > 0) {
            List<Attribute_Mapping__c> attmappings = [SELECT Field_Api_Name__c, Auto_populate__c, Auto_add__c, Auto_Update__c, Auto_delete__c
                        FROM Attribute_Mapping__c WHERE object__c = : ConstantsController.OPPORTUNITY
                        AND Field_Api_Name__c != null AND Is_Related_Mapping__c = true];//re #741
            
            if (attmappings.size() > 0  || Test.isRunningTest()) {
                checkAccountAttributes(oppAccounts, attmappings, cs, currencyMap, false);
            }
        }
    }
    
    
    /**
     * Method to create/delete Account Atrributes
     */
    private static void checkAccountAttributes(Set<String> oppAccounts, List<Attribute_Mapping__c> attributeMappings, 
    													Custom_Settings__c cs, Map<String, sObject> currencyMap, Boolean isUpdate) {
        Set<String> oppIds = new Set<String>();
        Boolean isCurrencyEnabled = (UtilityController.isCurrencyEnabled() && UserInfo.isMultiCurrencyOrganization());
        Map<Id, Set<String>> oppAccountMap = new Map<Id, Set<String>>();
        Map<Id, Map<Id, Account_Attribute__c>> allAccountAttributesAssociated = new Map<Id, Map<Id, Account_Attribute__c>>();
        Map<Id, Map<Id, Account_Attribute__c>> accountAttributesAssociated = new Map<Id, Map<Id, Account_Attribute__c>>();
        Map<String, Map<String, Set<String>>> oppProductsPicklistFieldValues = new Map<String, Map<String, Set<String>>>();
        
        if (cs != null && cs.Minimum_Opportunity_Size_OP__c != null) {
        	Decimal amount = (isCurrencyEnabled ? (cs.Minimum_Opportunity_Size_OP__c / Decimal.valueOf(String.valueOf(
            									currencyMap.get(String.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate')))) 
            									: cs.Minimum_Opportunity_Size_OP__c);
        	String query = '';
        	if (isCurrencyEnabled) {
        		query = 'SELECT Id, (SELECT Id, CurrencyIsoCode, Amount FROM Opportunities WHERE StageName = \'Closed Won\'), ' +
	            						+ '(SELECT Account__c, Is_Referenceable__c, Referenceability_Status__c, Reference_Program_Candidate__c ' +
	            						+ 'FROM Reference_Basic_Informations__r WHERE Is_Referenceable__c = true AND Contact__c = null) ' +
	            						+ 'FROM Account WHERE Id IN :oppAccounts';
        	} else {
        		query = 'SELECT Id, (SELECT Id, Amount FROM Opportunities WHERE StageName = \'Closed Won\' AND Amount >= ' 
        								+ cs.Minimum_Opportunity_Size_OP__c +
	            						+ '), (SELECT Account__c, Is_Referenceable__c, Referenceability_Status__c, Reference_Program_Candidate__c ' +
	            						+ 'FROM Reference_Basic_Informations__r WHERE Is_Referenceable__c = true AND Contact__c = null) ' +
	            						+ 'FROM Account WHERE Id IN :oppAccounts';
        	}
        	
        	for (Account account : Database.query(query)) {
            							
                if (account.Reference_Basic_Informations__r.size() > 0) {
                	
                    for (Opportunity opp : account.Opportunities) {
                    	
                        if (opp.Amount != null) {
                            Decimal oppAmount = (isCurrencyEnabled ?
            							(opp.Amount / Decimal.valueOf(String.valueOf(
            							currencyMap.get(String.valueOf(opp.get('CurrencyIsoCode'))).get('ConversionRate')))) : opp.Amount);

                            if (oppAmount >= amount) {
                                oppIds.add(opp.Id);
                                
                                if (!oppAccountMap.containsKey(account.Id)) {
                                    oppAccountMap.put(account.Id, new Set<String>());
                                }
                                oppAccountMap.get(account.Id).add(opp.Id);
                            }
                        }
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
            Map<String, Set<String>> oppProductMap = new Map<String, Set<String>>();
            List<Account_Attribute__c> accAttToBeDeleted = new List<Account_Attribute__c>();
            List<Account_Attribute__c> createAccountAtt = new List<Account_Attribute__c>();
            Set<String> preventDuplicacy = new Set<String>();
            Set<String> oppProductAttMappingSet = new Set<String>();
            Set<Id> mappingCreateAttribute = new Set<Id>();
            Set<String> fieldAPINames = new Set<String>();
            String theQueryOpp = 'SELECT PricebookEntry.Product2Id, OpportunityId ';
            
            for (String fieldName : oppProductField_map.keyset()) {
                Schema.DescribeFieldResult fieldDesc = oppProductField_map.get(fieldName).getDescribe();
                
                if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    String theName = fieldDesc.getName();
                    // Continue building your dynamic query String
                    theQueryOpp += ', ' + theName;
                    fieldAPINames.add(theName);
                }
            }
            theQueryOpp += ' FROM OpportunityLineItem WHERE OpportunityId IN :oppIds ';
            List<OpportunityLineItem> oppLineItems = Database.query(theQueryOpp);
            List<String> attMappings = new List<String>();
            
            for (Attribute_Mapping__c attM : attributeMappings) {
            	
                if (fieldAPINames.contains(attM.Field_Api_Name__c) && oppProductField_map.containsKey(attM.Field_Api_Name__c.tolowerCase())) {
                    attMappings.add(attM.Id);
                    oppProductAttMappingSet.add(attM.Field_Api_Name__c);
                }
                
                //re #741
                if (attM.Field_Api_Name__c == 'Product2') {
                	attMappings.add(attM.Id);
                }
            }
            
            for (OpportunityLineItem oppLineItem : oppLineItems) {
            	
                if (!opplineItemMap.containsKey(oppLineItem.OpportunityId)) {
                    opplineItemMap.put(oppLineItem.OpportunityId, new List<OpportunityLineItem>());
                    oppProductMap.put(oppLineItem.OpportunityId, new Set<String>());
                }
                opplineItemMap.get(oppLineItem.OpportunityId).add(oppLineItem);
                oppProductMap.get(oppLineItem.OpportunityId).add(oppLineItem.PricebookEntry.Product2Id);
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
            
            for (Attribute__c att : [SELECT Id, name, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Auto_populate__c, 
                                        (SELECT Id, Name, Product_ID__c FROM Attributes__r), Attribute_Mapping__r.Inheritable__c FROM Attribute__c 
                                        WHERE Attribute_Mapping__c IN :attMappings AND level__c = 0 AND Attribute_Mapping__r.Auto_populate__c = true]) {
                
                for (String accountId : oppAccountMap.keySet()) {
                    Map<String, Set<String>> tempMap = oppProductsPicklistFieldValues.get(accountId);
                    
                    //re #741
                    if (tempMap != null && tempMap.containsKey(att.Attribute_Mapping__r.Field_Api_Name__c) && att.Attribute_Mapping__r.Field_Api_Name__c != 'Product2') {
                        Set<String> fieldValues = tempMap.get(att.Attribute_Mapping__r.Field_Api_Name__c);
                        
                        for (Attribute__c childAtt : att.Attributes__r) {
                            
                            if (fieldValues.contains(childAtt.Name) && !preventDuplicacy.contains(accountId + '' + childAtt.Id) && 
                            							!allAccountAttributesAssociated.get(accountId).containsKey(childAtt.Id)) {
                                createAccountAtt.add(new Account_Attribute__c(Account__c = accountId, Attribute__c = childAtt.Id, From_Opportunity__c = true, Inheritable__c = att.Attribute_Mapping__r.Inheritable__c));
                                preventDuplicacy.add(accountId + '' + childAtt.Id);
                            }
                            
                            if (fieldValues.contains(childAtt.Name)) {
                                mappingCreateAttribute.add(childAtt.Id);
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
			                                mappingCreateAttribute.add(childAtt.Id);
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
                	//re #955
                    if (!mappingCreateAttribute.contains(attId) && accountAttributesAssociated.get(accId).containsKey(attId) && 
                    			(!isUpdate || (isUpdate && (accountAttributesAssociated.get(accId).get(attId).Attribute__r.Product_ID__c == null 
                    										|| accountAttributesAssociated.get(accId).get(attId).Attribute__r.Product_ID__c == '')))) {
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
                    
                    if (ca.Attribute__c == accAtt.Attribute__c && ca.Account__c == accAtt.Account__c) {
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
                WithoutSharingHelperController.deleteAccountAttributes(accAttToBeDeleted);
            }
            
            if (createAccountAtt.size() > 0) {
                ConstantsController.addAttributesToContact = true;
                ConstantsController.addAttributesToContent = true;
                WithoutSharingHelperController.upsertAccountAttributes(createAccountAtt);
            }
        }
    }
}