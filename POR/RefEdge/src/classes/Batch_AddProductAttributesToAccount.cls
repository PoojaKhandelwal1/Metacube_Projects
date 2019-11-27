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
 * Class: NewOpportunityAttributeController
 * Description : This Batch called from NewOpportunityAttributeController to add all new product Attributes 
 * to Account if they are added already re #946
 * Created by: Rajneesh Raj @Jan 03, 2019
 */
public with sharing class Batch_AddProductAttributesToAccount implements Database.Batchable<sObject>, Database.stateful {
    /**
     * Properties and variables
     */
    private String soqlQuery = '';
    private Custom_Settings__c cs;
    private Map<String, sObject> currencyMap;
    private boolean isCurrencyEnabled;
    private Set<String> productIds;

    /**
     * Constructor
     */
    public Batch_AddProductAttributesToAccount(Set<String> productIdsNew) {
    	cs = UtilityController.getCustomSettings();
        isCurrencyEnabled = (UtilityController.isCurrencyEnabled() && UserInfo.isMultiCurrencyOrganization());
        currencyMap = new Map<String, sObject>();
        productIds = new Set<String>();
        productIds.addAll(productIdsNew);
        
        if (isCurrencyEnabled) {
            currencyMap = UtilityController.getAllCurrency();
        }
    }

    /**
     * Method to get the data to be proceesed   
     * Get all active Reference Profile
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
    	soqlQuery = 'SELECT Account__c FROM Reference_Basic_Information__c '
        			+ ' WHERE Is_Referenceable__c = true AND Contact__c = null AND Account__c != null';
        return Database.getQueryLocator(soqlQuery);
    }

    /**
     * Method to execute the batch
     */
    public void execute(Database.BatchableContext BC, List<Reference_Basic_Information__c> scope) {
        Set<String> oppAccounts = new Set<String>();
        
        //get all account Ids
        for (Reference_Basic_Information__c rbi : scope) {
            oppAccounts.add(rbi.Account__c);
        }
        Set<String> oppIds = new Set<String>();
        Set<String> oppMappingIds = new Set<String>();
        Map<String, Set<String>> oppProductMap = new Map<String, Set<String>>();
        Map<Id, Set<String>> oppAccountMap = new Map<Id, Set<String>>();
        Map<Id, Map<Id, Account_Attribute__c>> allAccountAttributesAssociated = new Map<Id, Map<Id, Account_Attribute__c>>();
        Map<Id, Map<Id, Account_Attribute__c>> accountAttributesAssociated = new Map<Id, Map<Id, Account_Attribute__c>>();
        
        if (cs != null && cs.Minimum_Opportunity_Size_OP__c != null && oppAccounts.size() > 0) {
            	
            for (String account : oppAccounts) {
                oppAccountMap.put(account, new Set<String>());
                accountAttributesAssociated.put(account, new Map<Id, Account_Attribute__c>());
                allAccountAttributesAssociated.put(account, new Map<Id, Account_Attribute__c>());
            }
            List<Account_Attribute__c> createAccountAtt = new List<Account_Attribute__c>();
            Set<String> preventDuplicacy = new Set<String>();
            Set<String> oppProductAttMappingSet = new Set<String>();
            String theQueryOpp = '';
            
            if (isCurrencyEnabled) {
                theQueryOpp =
                    'SELECT PricebookEntry.Product2Id, OpportunityId , Opportunity.AccountId, Opportunity.CurrencyIsoCode, Opportunity.Amount';
            } else {
                theQueryOpp = 'SELECT PricebookEntry.Product2Id, OpportunityId , Opportunity.AccountId, Opportunity.Amount';
            }
            Decimal amount = (isCurrencyEnabled ? (cs.Minimum_Opportunity_Size_OP__c / Decimal.valueOf(String.valueOf(
    									currencyMap.get(String.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate')))) 
    									: cs.Minimum_Opportunity_Size_OP__c);
            
            if (isCurrencyEnabled) {
                theQueryOpp += ' FROM OpportunityLineItem WHERE Opportunity.AccountId IN : oppAccounts AND Opportunity.StageName = \'Closed Won\' AND PricebookEntry.Product2Id IN :productIds ';
            } else {
                theQueryOpp +=
                    ' FROM OpportunityLineItem WHERE Opportunity.AccountId IN : oppAccounts AND Opportunity.StageName = \'Closed Won\' AND Opportunity.Amount >= :amount AND PricebookEntry.Product2Id IN :productIds ';
            }
            //get all opportunity line item which have selected account ids and given product ids with closed opportunity
            List<OpportunityLineItem> oppLineItems = Database.query(theQueryOpp);
            List<String> attMappings = new List<String>();
    						
    		//process all line items and collect all opportunities which have greater amount than standard opportunity size			
            for (OpportunityLineItem oppLineItem : oppLineItems) {
                
                if (oppLineItem.Opportunity.Amount != null) {
                    Decimal oppAmount = (isCurrencyEnabled ?
    							(oppLineItem.Opportunity.Amount / Decimal.valueOf(String.valueOf(
    							currencyMap.get(String.valueOf(oppLineItem.Opportunity.get('CurrencyIsoCode'))).get('ConversionRate')))) : oppLineItem.Opportunity.Amount);
    	
                    if (oppAmount >= amount) {
                        
                        if (!oppProductMap.containsKey(oppLineItem.OpportunityId)) {
                            oppProductMap.put(oppLineItem.OpportunityId, new Set<String>());
                        }
                        oppAccountMap.get(oppLineItem.Opportunity.AccountId).add(oppLineItem.OpportunityId);
                        oppProductMap.get(oppLineItem.OpportunityId).add(oppLineItem.PricebookEntry.Product2Id);
                    }
                }
            }
            
            //get all account attributes which are associated to selected accounts
            for (Account_Attribute__c accAtt : WithoutSharingHelperController.getAccountAttributeinRBI1(oppAccountMap.keySet())) {
            	
                if (accAtt.From_Opportunity__c) {
                    accountAttributesAssociated.get(accAtt.Account__r.Id).put(accAtt.Attribute__r.Id, accAtt);
                }
                allAccountAttributesAssociated.get(accAtt.Account__r.Id).put(accAtt.Attribute__r.Id, accAtt);
            }
            
            //get all attributes associated to product attribute mapping
            for (Attribute__c att : [SELECT Id, Name, (SELECT Id, Name, Product_ID__c FROM Attributes__r where Product_ID__c IN :productIds)
									, Attribute_Mapping__r.Inheritable__c FROM Attribute__c
									WHERE Attribute_Mapping__r.Field_Api_Name__c = 'Product2' 
									AND Attribute_Mapping__r.object__c = :ConstantsController.OPPORTUNITY
									AND Level__c = 0 AND Attribute_Mapping__r.Auto_populate__c = true]) {
                	
                for (String accountId : oppAccountMap.keySet()) {
                	
                	for (Attribute__c childAtt : att.Attributes__r) {
                		
                		for (String oppId : oppAccountMap.get(accountId)) {
                    		
                    		if (oppProductMap != null && oppProductMap.containsKey(oppId)) {
                    			
                    			for (String productId : oppProductMap.get(oppId)) {
                    				
                    				//if any product related attribute is found which is not associated to accounts then add them
                    				if (childAtt.Product_ID__c == productId && !preventDuplicacy.contains(accountId + '' + childAtt.Id) 
                    									&& !allAccountAttributesAssociated.get(accountId).containsKey(childAtt.Id)) {
                    					createAccountAtt.add(new Account_Attribute__c(Account__c = accountId, Attribute__c = childAtt.Id, From_Opportunity__c = true, Inheritable__c = att.Attribute_Mapping__r.Inheritable__c));
                            			preventDuplicacy.add(accountId + '' + childAtt.Id);
                    				}
                    			}
                    		}
                		}
                	}
                }
            }
            ConstantsController.attMappingForAccount = false;
            
            //insert account attribute
            if (createAccountAtt.size() > 0) {
                ConstantsController.addAttributesToContact = true;
                ConstantsController.addAttributesToContent = true;
                database.upsert(createAccountAtt, false);
            }
        }
    }

    /**
     * Method to be called after the excute
     */
    public void finish(Database.BatchableContext BC) {}
}