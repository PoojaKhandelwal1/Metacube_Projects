/**
 * Author: Tarun Khandelwal
 * Since: March 27, 2014
 * Name: COTriggerHelper
 * Description: Helper class for triggers on CO Header object
**/
public with sharing class COTriggerHelper {
    
    public static Boolean isForceStopTrigger = false;
    // List to store trigger new list
    public static List<CO_Header__c> COHeaderNewList = new List<CO_Header__c>();
    
    // List to store trigger old list
    public static List<CO_Header__c> COHeaderOldList = new List<CO_Header__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, CO_Header__c> COHeaderNewMap = new Map<Id, CO_Header__c>();
    
    // Map to store Old Trigger Map
    public static Map<Id, CO_Header__c> COHeaderOldMap = new Map<Id, CO_Header__c>();
    
    // Variable to stop nested looping
    public static Boolean isTriggerExecute = false;
    
    // List to store Default sales tax
    public static List<Sales_Tax__c> defaultSalesTax;
    
    public static List<Price_Level__c> defaultPriceLevel;
    
    public static Boolean isCOInvoiceHeaderUpdated = false;
    public static Boolean isCalculatePLandTax = false;
    
     /**
     * Name: beforeInsertOperation
     * Desc: Before Insert Method
     * @param: 
     * @return: 
    **/
    public static void beforeInsertOperation() {
        populatePriceLevelRelatedField();
    }
    
     /**
     * Name: beforeUpdateOperation
     * Desc: Before Update Method
     * @param: 
     * @return: 
    **/
    public static void beforeUpdateOperation() {
        
        Boolean isValidEntry = entryConditionForBeforeUpdate();
        
        if(COTriggerHelper.isCalculatePLandTax) {
            refreshTaxExemptions();
        } else if(isValidEntry) {
            populateTaxExemptions(COHeaderNewList, false);
        }
        
        if(isValidEntry || isCalculatePLandTax) {
            populatePriceLevelRelatedField();
            SOTriggerHelper.isTriggerRun = true;
        }
    }
    
     /**
     * Name: entryConditionForBeforeUpdate
     * Desc: Before Update Condition
     * @param: 
     * @return: Boolean is ValidEntry or not
    **/
    private static Boolean entryConditionForBeforeUpdate() {
        Boolean isValidEntry = false;
        for(CO_Header__c coHeaderRec : COHeaderNewList) {
            if((COHeaderNewMap.get(coHeaderRec.Id).Customer__c != COHeaderOldMap.get(coHeaderRec.Id).Customer__c)) {
                isValidEntry = true;
            }
        }
        return isValidEntry;
    }
    
    // Search Tag Format - Customer Name, 
    private static void populateSearchTag() {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        List<CO_Header__c> coHeaderList = [select Customer__r.Name, Search_Tag__c, 
                                                (select Search_Tag__c from CO_Invoice_Headers__r),
                                                (select Search_Tag__c from Service_Order_Headers__r)
                                            from CO_Header__c 
                                            where Id IN: COHeaderNewList];
        Set<Id> accountIdSet = new Set<Id>();
        for(CO_Header__c coHeaderRec : COHeaderNewList) {
            if(coHeaderRec.Customer__c != null ) {
                accountIdSet.add(coHeaderRec.Customer__c);
            }
        }
        
        Map<Id, Account> customerMap = new Map<Id, Account>([select Id, Name from Account where Id IN: accountIdSet]);
                                                
        List<CO_Invoice_Header__c> coInvoiceHeaderList = new List<CO_Invoice_Header__c>();
        List<Service_Order_Header__c> soHeaderList = new List<Service_Order_Header__c>();
        for(CO_Header__c coHeaderRec : coHeaderList) {
            String newCustomerName = '';
            if(customerMap.get(COHeaderNewMap.get(coHeaderRec.Id).Customer__c) != null) {
                newCustomerName = customerMap.get(COHeaderNewMap.get(coHeaderRec.Id).Customer__c).Name;
            }
            coHeaderRec.Search_Tag__c = (newCustomerName != '') ? newCustomerName + ',' : '';
            for(CO_Invoice_Header__c coInvoiceHeaderRec : coHeaderRec.CO_Invoice_Headers__r) {
                coInvoiceHeaderRec.Search_Tag__c = coHeaderRec.Search_Tag__c;
                coInvoiceHeaderList.add(coInvoiceHeaderRec);
            }
            for(Service_Order_Header__c soHeaderRec : coHeaderRec.Service_Order_Headers__r) {
                soHeaderRec.Search_Tag__c = coHeaderRec.Search_Tag__c;
                soHeaderList.add(soHeaderRec);
            }
        }
        if(isCOInvoiceHeaderUpdated) {
            return;
        }
        if(coInvoiceHeaderList.size() > 0) {
            isCOInvoiceHeaderUpdated = true;
            update coInvoiceHeaderList;
        }
        
        if(soHeaderList.size() > 0) {
            update soHeaderList;
        }
        
        if(coHeaderList.size() > 0) {
            update coHeaderList;
        }
    }
    
     /**
     * Name: setPriceLevelForRelatedCOLIs
     * Desc: Setting Price Level for Related Line Items
     * @param: 
     * @return: 
    **/
    public static void setPriceLevelForRelatedCOLIs() {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> coHeaderList = [select Customer__c, Discount_Markup_From_Prive_Level__c, Part_Price_Base_From_Price_Level__c,
                                                (select Part__c, CO_Kit_Header__c, Kit_Header_Line_Item__c, Id, Deal__c, Service_Order_Line_Item__r.Service_Order_Header__r.Job_Type__c, 
                                                Service_Order_Line_Item__r.Service_Order_Header__r.Provider__c, Service_Order_Line_Item__r.Service_Order_Header__r.Provider__r.Price_Level__r.Discount_Markup__c, 
                                                Service_Order_Line_Item__r.Service_Order_Header__r.Provider__r.Price_Level__r.Part_Price_Base__c from CO_Line_Items__r where 
                                                Invoice_Number__c = null AND CO_Kit_Header__c = null) 
                                                from CO_Header__c where Id IN : COHeaderNewList];
                                               // AND (Service_Order_Line_Item__r.Service_Order_Header__r.Job_Type__c != 'Internal' OR Service_Order_Line_Item__r.Service_Order_Header__r.CO_Header__r.CO_Type__c = 'Internal Service')
        setPLForCOLIs(coHeaderList);
    }
    
    public static void setPLforCOLIs(List<CO_Header__c> coHeaderList) {
        List<Id> partIdList = new List<Id>();
        
        List<CO_Line_Item__c> merchLIList = new List<CO_Line_Item__c>();
        List<CO_Line_Item__c> dealMerchLIList = new List<CO_Line_Item__c>();
        
        Map<String, List<CO_Line_Item__c>> providerIdToCOLIListMap = new Map<String, List<CO_Line_Item__c>>();
        Map<String, Price_Level__c> providerIdToPriceLevelRecMap = new Map<String, Price_Level__c>();
        
        for(CO_Header__c COHeaderRec : coHeaderList) {
            for(CO_Line_Item__c coLineItemRec : COHeaderRec.CO_Line_Items__r) {
                if(coLineItemRec.CO_Kit_Header__c != null) {
                    continue;
                }
                if(String.isNotBlank(coLineItemRec.Deal__c) || coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__r.Job_Type__c == 'Internal') {
                    dealMerchLIList.add(coLineItemRec);
                } else if(coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__r.Provider__c != null) {
                    if(!providerIdToCOLIListMap.containsKey(coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__r.Provider__c)){
                        providerIdToCOLIListMap.put(coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__r.Provider__c, new List<CO_Line_Item__c>());
                        
                        Price_Level__c plRec = new Price_Level__c(Id = coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__r.Provider__r.Price_Level__c);
                        plRec.Part_Price_Base__c = coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__r.Provider__r.Price_Level__r.Part_Price_Base__c;
                        plRec.Discount_Markup__c = coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__r.Provider__r.Price_Level__r.Discount_Markup__c;
                        providerIdToPriceLevelRecMap.put(coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__r.Provider__c, plRec);
                    }
                    providerIdToCOLIListMap.get(coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__r.Provider__c).add(coLineItemRec);
                } else {
                    merchLIList.add(coLineItemRec); 
                }
                partIdList.add(coLineItemRec.part__c);
            }
        }
                
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Map<Id, Part__c> partIdToPartRecordMap = new Map<Id, Part__c>([select Id, Applicable_Tax__c, Average_Cost__c, Last_Cost__c, 
                                                                            Applicable_Tax__r.Rate__c, MSRP__c, Retail_Price__c from Part__c where Id IN : partIdList]);
        List<CO_Line_Item__c> coLineItemListToUpdate = new List<CO_Line_Item__c>();
        
        for(CO_Header__c coHeaderRec : coHeaderList) {
            coLineItemListToUpdate.addAll(TaxCalculation.partPriceCalculation(coHeaderRec.Part_Price_Base_From_Price_Level__c, coHeaderRec.Discount_Markup_From_Prive_Level__c, 
                                                        merchLIList, partIdToPartRecordMap));
            if(dealMerchLIList.size() > 0) {
                List<Price_Level__c> defaultPriceLevel = SOTriggerHelper.getInternalDefaultPriceLevel();
                if(defaultPriceLevel == null || defaultPriceLevel.size() == 0) {
                    defaultPriceLevel = SOTriggerHelper.getDefaultPriceLevel();
                }
                coLineItemListToUpdate.addAll(TaxCalculation.partPriceCalculation(defaultPriceLevel[0].Part_Price_Base__c, defaultPriceLevel[0].Discount_Markup__c, 
                                                        dealMerchLIList, partIdToPartRecordMap));
            }
            
            if(providerIdToCOLIListMap.size() > 0) {
                for(String providerId : providerIdToCOLIListMap.keySet()) { 
                    coLineItemListToUpdate.addAll(TaxCalculation.partPriceCalculation(providerIdToPriceLevelRecMap.get(providerId).Part_Price_Base__c, providerIdToPriceLevelRecMap.get(providerId).Discount_Markup__c, 
                                                        providerIdToCOLIListMap.get(providerId), partIdToPartRecordMap));
                }
            }
        }           
        system.debug('setPriceLevelForRelatedCOLIs \n\n\n coLineItemListToUpdate\n --> ' + coLineItemListToUpdate);        
        if(coLineItemListToUpdate.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update coLineItemListToUpdate;
        }
    }
    
    /**
     * Name: populatePriceLevelRelatedField
     * Desc: Populating Price Level Releted Field
     * @param: 
     * @return: 
    **/
    private static void populatePriceLevelRelatedField() {
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Id> customerIdList = new List<Id>();
        for(CO_Header__c coHeaderRec : COHeaderNewList) {
            if(coHeaderRec.Customer__c != null) {
                customerIdList.add(coHeaderRec.Customer__c);
            }
        }
        
        Map<Id, Account> customerMap = new Map<Id, Account>();
        if(customerIdList.size() > 0) {
            customerMap = new Map<Id, Account>([select Price_Level__c, Price_Level__r.Discount_Markup__c, Price_Level__r.Part_Price_Base__c, 
                                                    Price_Level__r.Labour_Rate__c from Account where Id IN : customerIdList]);
        }
        
        for(CO_Header__c coHeaderRec : COHeaderNewList) {
            if(coHeaderRec.Customer__c != null && customerMap.containsKey(coHeaderRec.Customer__c) && customerMap.get(coHeaderRec.Customer__c).Price_Level__c != null) {
                coHeaderRec.Discount_Markup_From_Prive_Level__c = customerMap.get(coHeaderRec.Customer__c).Price_Level__r.Discount_Markup__c;
                coHeaderRec.Part_Price_Base_From_Price_Level__c = customerMap.get(coHeaderRec.Customer__c).Price_Level__r.Part_Price_Base__c;
                coHeaderRec.Labour_Rate_From_Price_Level__c = customerMap.get(coHeaderRec.Customer__c).Price_Level__r.Labour_Rate__c;
            } else {
                if(coHeaderRec.CO_Type__c == Constants.INTERNAL_SERVICE) {
                    String defaultPriceLevelId = GeneralConfiguration.getDefaultPriceLevelOnInternalService();
                    if(defaultPriceLevel == null) {
                        defaultPriceLevel = getDefaultPriceLevel(defaultPriceLevelId);
                    }
                }
                if(defaultPriceLevel == null) {
                    defaultPriceLevel = getDefaultPriceLevel();
                } 
                coHeaderRec.Discount_Markup_From_Prive_Level__c = (defaultPriceLevel.size() > 0) ? defaultPriceLevel[0].Discount_Markup__c : 0;
                coHeaderRec.Part_Price_Base_From_Price_Level__c = (defaultPriceLevel.size() > 0) ? defaultPriceLevel[0].Part_Price_Base__c : null;
                coHeaderRec.Labour_Rate_From_Price_Level__c = (defaultPriceLevel.size() > 0) ? defaultPriceLevel[0].Labour_Rate__c : 0;
            }
        }
    }
    
    /** 
     * Name: afterUpdateCalculation
     * Desc: Method to Calculate Part Price tax when co header record is updated
     * @param: 
     * @return: 
    **/
    public static void afterUpdateCalculation() {
        if(isTriggerExecute || !(entryConditionForBeforeUpdate() || isCalculatePLandTax)) {
            return;
        }
        isTriggerExecute = true;
        isCalculatePLandTax = false;
        setPriceLevelForRelatedCOLIs();
        salesTaxCalculation(null);
        // For SOLIs
        setPriceLevelAndSalesTaxForLabourInServiceOrder(null);
        if(!isCalculatePLandTax) {
            populateSearchTag();
        }
        // Update option and fees when click on refreshing customer information or changing customer
        updateDeal();
    }
    
    private static void updateDeal() {
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal_Item__c> dealItemList = [Select Id, (Select Id from Options_Fees__r), (Select Id from Deal_Unit_Prices_Costs__r) from Deal_Item__c where Deal__r.CO_Header__c IN: COHeaderNewList And Deal__r.Invoice_Number__c = null];
        if(dealItemList.size() > 0) {
            List<SObject> sObjectListToUpdate = new List<SObject>();
            for(Deal_Item__c dealItemRec : dealItemList) {
                sObjectListToUpdate.addAll((List<SObject>) dealItemRec.Options_Fees__r);
                sObjectListToUpdate.addAll((List<SObject>) dealItemRec.Deal_Unit_Prices_Costs__r);
            }
            OptionAndFeeTriggerHelper.isCustomerPLUpdate = true;
            DealUnitPriceAndCostTriggerHelper.isCustomerPLUpdate = true;
            if(AccessControl.ifObjectFieldIsUpdateable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Deal_Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update sObjectListToUpdate;
        } 
    }
    
    public static void salesTaxCalculation(String soId) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Part_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectIsDeletable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
                
        List<CO_Header__c> coHeaderList;
        if(String.isNotBlank(soId)) {
            coHeaderList = [Select Id, (SELECT Part__c, Part__r.Applicable_Tax__c, Part__r.Applicable_Tax__r.Rate__c, Price__c,
                                                        Fee__c, Fee__r.Applicable_Tax__c, Fee__r.Applicable_Tax__r.Rate__c, Deal__c,
                                                        Service_Order_Line_Item__r.Service_Order_Header__r.Provider__c, Service_Order_Line_Item__r.Service_Order_Header__r.Job_Type__c, 
                    CO_Header__c, CO_Header__r.CO_Type__c, CO_Header__r.Customer__c, Service_Order_Line_Item__c from CO_Line_Items__r where 
                    Invoice_Number__c = null AND CO_Kit_Header__c = null AND Service_Order_Line_Item__r.Service_Order_Kit_Header__c = null 
                    AND Service_Order_Line_Item__r.Service_Order_Header__c =: soId)
                    FROM CO_Header__c where Id IN: COHeaderNewList];
        } else {
            coHeaderList = [Select Id, (SELECT Part__c, Part__r.Applicable_Tax__c, Part__r.Applicable_Tax__r.Rate__c, Price__c,
                    Fee__c, Fee__r.Applicable_Tax__c, Fee__r.Applicable_Tax__r.Rate__c, Deal__c,
                    Service_Order_Line_Item__r.Service_Order_Header__r.Provider__c, Service_Order_Line_Item__r.Service_Order_Header__r.Job_Type__c, 
                    CO_Header__c, CO_Header__r.CO_Type__c, CO_Header__r.Customer__c, Service_Order_Line_Item__c from CO_Line_Items__r where 
                                                        Invoice_Number__c = null AND CO_Kit_Header__c = null)
                                                        FROM CO_Header__c where Id IN: COHeaderNewList];
        }
        Map<Id, Set<Id>> coHeaderIdToSalesTaxItemIdsMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> soHeaderIdToSalesTaxItemIdsMap = new Map<Id, Set<Id>>();
        for(CO_Header__c coHeaderRec : coHeaderList) {
            for(CO_Line_Item__c coLineItemRec : coHeaderRec.CO_Line_Items__r) {
                if(coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__c != null) {
                    soHeaderIdToSalesTaxItemIdsMap.put(coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__c, null);                
                } 
                if(coLineItemRec.CO_Header__c != null) {
                    coHeaderIdToSalesTaxItemIdsMap.put(coLineItemRec.CO_Header__c, null);
                }
            }
        }
        List<Tax_Exemption__c> taxExemptionsList = new List<Tax_Exemption__c>();
        if(coHeaderIdToSalesTaxItemIdsMap.size() > 0 || soHeaderIdToSalesTaxItemIdsMap.size() > 0) {
        // Get list of Tax Exemptions for given customer/provider ids
            taxExemptionsList = [SELECT CO_Header__r.Customer__c, Service_Order_Header__r.Provider__c, Sales_Tax_Item__r.Rate__c from Tax_Exemption__c 
                                where (CO_Header__c IN: coHeaderIdToSalesTaxItemIdsMap.keySet() OR Service_Order_Header__c IN: soHeaderIdToSalesTaxItemIdsMap.keySet())];

            for(Id coHeaderId : coHeaderIdToSalesTaxItemIdsMap.keySet()) {
                Set<Id> salesTaxItemIdSet = new Set<Id>();
                for(Tax_Exemption__c taxExemptionRec : taxExemptionsList) {
                    if(taxExemptionRec.CO_Header__c == coHeaderId) {
                        salesTaxItemIdSet.add(taxExemptionRec.Sales_Tax_Item__c);
                    }
                }
                coHeaderIdToSalesTaxItemIdsMap.put(coHeaderId, salesTaxItemIdSet);
            }
            for(Id soHeaderId : soHeaderIdToSalesTaxItemIdsMap.keySet()) {
                Set<Id> salesTaxItemIdSet = new Set<Id>();
                for(Tax_Exemption__c taxExemptionRec : taxExemptionsList) {
                    if(taxExemptionRec.Service_Order_Header__c == soHeaderId) {
                        salesTaxItemIdSet.add(taxExemptionRec.Sales_Tax_Item__c);
                    }
                }
                soHeaderIdToSalesTaxItemIdsMap.put(soHeaderId, salesTaxItemIdSet);
            }
        }
        
        // Entity Tax Rate
        Set<Id> coLineItemSet = new Set<Id>();
        List<Id> salesTaxIdList = new List<Id>();
        for(CO_Header__c coHeaderRec : coHeaderList) {
            for(CO_Line_Item__c coLineItemRec : coHeaderRec.CO_Line_Items__r) {
                coLineItemSet.add(coLineItemRec.Id);
                
                if(String.isNotBlank(coLineItemRec.Deal__c) || coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__r.Job_Type__c == 'Internal') {
                	coLineItemRec.Applicable_Tax__c = GeneralConfiguration.getDefaultSalesTaxOnInternalService();
                    salesTaxIdList.add(GeneralConfiguration.getDefaultSalesTaxOnInternalService());
                } else if(coLineItemRec.Part__r.Applicable_Tax__c != null) {
                	coLineItemRec.Applicable_Tax__c = coLineItemRec.Part__r.Applicable_Tax__c;
                    salesTaxIdList.add(coLineItemRec.Part__r.Applicable_Tax__c);
                } else if(coLineItemRec.Fee__r.Applicable_Tax__c != null) {
                	coLineItemRec.Applicable_Tax__c = coLineItemRec.Fee__r.Applicable_Tax__c;
                    salesTaxIdList.add(coLineItemRec.Fee__r.Applicable_Tax__c);
                } 
            }
        }
        
        List<Individual_Tax__c> individualTaxList = [select Id from Individual_Tax__c where CO_Line_Item__c IN: coLineItemSet];
        if(individualTaxList.size() > 0) {
            delete individualTaxList;
        }
        
        List<CO_Line_Item__c> coLineItemToUpdate = new List<CO_Line_Item__c>();
        for(CO_Header__c coHeaderRec : coHeaderList) {
            if(coHeaderRec.CO_Line_Items__r.size() == 0) continue;
            coLineItemToUpdate.addAll(TaxCalculation.salesTaxCalculation2(salesTaxIdList, coHeaderIdToSalesTaxItemIdsMap, coHeaderRec.CO_Line_Items__r, soHeaderIdToSalesTaxItemIdsMap));
        }
        if(coLineItemToUpdate.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            COLineItemTriggerHelper.isTotalCalculated = false;
            update coLineItemToUpdate;
            
            updatePriceOnRelatedSOLIs(coLineItemToUpdate);
        }
    }

    private static void updatePriceOnRelatedSOLIs(List<CO_Line_Item__c> coLineItemToUpdate) {
        List<Service_Order_Line_Item__c> relatedSOLIs = [select Kit_Price__c, Actual_Kit_Price__c, Tax_Percent__c, CO_Line_Item__r.Price__c, Price_When_Tax_Included__c, Service_Order_Kit_Header__c,
                                                                 CO_Line_Item__r.Tax__c, CO_Line_Item__r.Price_When_Tax_Included__c from Service_Order_Line_Item__c
                                                            where CO_Line_Item__c IN: coLineItemToUpdate];
             
        for(Service_Order_Line_Item__c soliRec : relatedSOLIs) {
            soliRec.Actual_Kit_Price__c = soliRec.Kit_Price__c = soliRec.CO_Line_Item__r.Price__c;
            if(GeneralConfiguration.getTaxIncludingPricing()) {
                soliRec.Price_When_Tax_Included__c = soliRec.CO_Line_Item__r.Price_When_Tax_Included__c;
            }
            soliRec.Tax_Percent__c = soliRec.CO_Line_Item__r.Tax__c;
        }
        
        if(relatedSOLIs.size() > 0) {
            ServiceOrderLineItemTriggerHelper.isTriggerExecuted = true;
            update relatedSOLIs;
        }
    }
        
    public static void setPriceLevelAndSalesTaxForLabourInServiceOrder(String soHeaderId) {
        List<Service_Order_Line_Item__c> soliList;
        if(String.isNotBlank(soHeaderId)) {
            soliList = [select Service_Order_Header__c, Fee__c, Labour_Code__c, Sublet__c, Kit_Price__c, Actual_Kit_Price__c, Service_Order_Header__r.Job_Type__c, 
                                                                Tax_Percent__c, CO_Line_Item__r.Price__c, CO_Line_Item__r.Tax__c, Service_Order_Kit_Header__c, Deal__c, 
                                                Deal_Item__c, (Select Id from Individual_Taxes__r)  from Service_Order_Line_Item__c
                                                where (Labour_Code__c != null OR Sublet__c != null) AND (Service_Order_Kit_Header__c = null) AND 
                                                Service_Order_Header__c =: soHeaderId AND Service_Order_Header__r.Invoice_Number__c = null];
        } else {
            soliList = [select Service_Order_Header__c, Fee__c, Labour_Code__c, Sublet__c, Kit_Price__c, Actual_Kit_Price__c, Service_Order_Header__r.Job_Type__c, 
                                                Tax_Percent__c, CO_Line_Item__r.Price__c, CO_Line_Item__r.Tax__c, Service_Order_Kit_Header__c, Deal__c, 
                                                Deal_Item__c, (Select Id from Individual_Taxes__r)  from Service_Order_Line_Item__c
                                                where (Labour_Code__c != null OR Sublet__c != null) AND (Service_Order_Kit_Header__c = null) AND 
                                                Service_Order_Header__r.CO_Header__c IN: COHeaderNewList AND Service_Order_Header__r.Invoice_Number__c = null];
        }
        //Q-39
        soliList = ServiceOrderLineItemTriggerHelper.applyPriceLevel(soliList);
        //Q-41
        if(soliList.size() > 0) {
            ServiceOrderLineItemTriggerHelper.isTriggerExecuted = true;
            update soliList; 
        }
        List<Service_Order_Line_Item__c> nonKitSOLIList = new List<Service_Order_Line_Item__c>();
        //START: Added to delete labor individual taxes when 
        List<Individual_Tax__c> individualTaxList = new List<Individual_Tax__c>();
        for(Service_Order_Line_Item__c soliRec : soliList) {
            if(String.isBlank(soliRec.Service_Order_Kit_Header__c)) {
                individualTaxList.addAll(soliRec.Individual_Taxes__r);
                nonKitSOLIList.add(soliRec);
            }
        }
        if(individualTaxList.size() > 0) {
            delete individualTaxList;
        }
        //END: Added to delete labor individual taxes when customer's price level has been updated
        //Q-47 
        ServiceOrderLineItemTriggerHelper.applySalesTax(nonKitSOLIList);
        //Q-56
    }
    
    
    /**
     * Name: getDefaultPriceLevel
     * Desc: Method to get Default Price Level In system
     * @param: 
     * @return:  List<Price_Level__c> - List of default price level. Ideally size of list - 1 
    **/
    private static List<Price_Level__c> getDefaultPriceLevel() {
        return getDefaultPriceLevel(null);
    }
    
    private static List<Price_Level__c> getDefaultPriceLevel(Id priceLevelId) {
        String query = 'SELECT Part_Price_Base__c, Discount_Markup__c, Labour_Rate__c FROM Price_Level__c ';
        if(String.isBlank(priceLevelId)) {
            query += 'WHERE Default__c = true';
        } else {
            query += 'WHERE Id =: priceLevelId';
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Price_Level__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        defaultPriceLevel = Database.query(query);
        return defaultPriceLevel;
    }
    
    /**
     * Name: getDefaultSalesTax
     * Desc: Method to populate Default Sales Tax In system
     * @param: 
     * @return:   
    **/
    private static void getDefaultSalesTax() {
        if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        defaultSalesTax = [select Rate__c from Sales_Tax__c where default__c = true];
    }
    
    
    /**
     * Name: updateAccountFields
     * Desc: Method to update account fields when CO header is updated.
     * @param: 
     * @return: 
    **/
    public static void updateAccountFields() {
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        Boolean isValidEntry = false;
        for(CO_Header__c coHeaderRec : COHeaderNewList)  {
            if(COHeaderNewMap.get(coHeaderRec.Id).Customer__c != COHeaderOldMap.get(coHeaderRec.Id).Customer__c) {
                isValidEntry = true;
            }   
        }
        if(!isValidEntry && !isCalculatePLandTax) {
            return;
        }
        
        List<Id> customersIdList = new List<Id>();
        for(CO_Header__c coHeaderRec : COHeaderNewList) {
            if(coHeaderRec.Customer__c != null) {
                customersIdList.add(coHeaderRec.Customer__c);
            }
        }
        List<User> currentUserList = SOQLUtil.getCurrentUserInfo();
        Boolean isAustralianMarket = false;
        if(currentUserList[0].LocaleSidKey == 'en_AU') {
            isAustralianMarket = true;
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Account> customerList = [select Name, Orders_Lifetime__c, Open_Orders__c, Average_Spend_per_Order__c, (select Id, Order_status__c, Order_Total__c,
                                        Total_Order_Value__c, Total_Order_Tax__c from CO_Headers__r) from Account Where Id IN : customersIdList];
        for(Account customerRec : customerList) {
            customerRec.Orders_Lifetime__c =  customerRec.CO_Headers__r.size();
            Integer openOrdersCount = 0;
            Decimal totalSpendOrder = 0;
            for(CO_Header__c coHeaderRec : customerRec.CO_Headers__r) {
                if(coHeaderRec.Order_status__c == 'Open') {
                    openOrdersCount++;
                }
                if(!isAustralianMarket) {
                    totalSpendOrder += coHeaderRec.Order_Total__c + coHeaderRec.Total_Order_Tax__c; 
                } else {
                    totalSpendOrder += coHeaderRec.Order_Total__c;
                }
            }
            customerRec.Average_Spend_per_Order__c = totalSpendOrder / customerRec.Orders_Lifetime__c;
            customerRec.Open_Orders__c = openOrdersCount;
        }
        if(customerList.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update customerList;
        }
    }
    
    /**
     * Name: refreshTaxExemptions
     * Desc: Refresh TaxExemptions
     * @param: 
     * @return: 
    **/
    private static void refreshTaxExemptions() {
        deleteTaxExemptions();
        populateTaxExemptions(COHeaderNewList, false);
    }
    
    /**
     * Name: deleteTaxExemptions
     * Desc: Delete TaxExemptions
     * @param: 
     * @return: 
    **/
    private static void deleteTaxExemptions() {
        if(AccessControl.ifObjectFieldIsUpdateable('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        
        List<Tax_Exemption__c> taxExemptionsList = [select Id from Tax_Exemption__c where CO_Header__c IN: COHeaderNewList];
        if(taxExemptionsList.size() > 0) {
            delete taxExemptionsList;
        }
    }
    
    /**
     * Name: populateTaxExemptions
     * Desc: Populate TaxExemptions from Customer Object's AccountType lookup
     * @param: COHeaderNewList, isUpdate
     * @return: 
    **/
    public static void populateTaxExemptions(List<CO_Header__c> COHeaderNewList, Boolean isUpdate) {
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        
        // Step 1 - Get Map customerId to Account_Type__c based on customerIds.
        Set<Id> customersIdList = new Set<Id>();
        for(CO_Header__c coHeaderRec : COHeaderNewList) {
            if(coHeaderRec.Customer__c != null) {
                customersIdList.add(coHeaderRec.Customer__c);
            }
        }
        Map<Id, Account> customerIdToAccountTypeMap = new Map<ID, Account>([select Id, Account_Type__c from Account Where Id IN : customersIdList]);
        
        // Step 2 - Get list of Tax_Exemption__c based on Account_Type__c ids.
        Set<Id> accountTypeIds = new Set<Id>();
        for (Account account : customerIdToAccountTypeMap.values()) {
            accountTypeIds.add(account.Account_Type__c);
        }
        accountTypeIds.remove(null);
        List<Tax_Exemption__c> taxExemptionsList = [SELECT Id, Account_Type__c, Sales_Tax_Item__r.Rate__c, Sales_Tax_Item__c FROM Tax_Exemption__c WHERE Account_Type__c IN :accountTypeIds];

        // Step 3 - Create new Tax_Exemption records and set CO_Header__c on them
        List<Tax_Exemption__c> coHeaderTaxExemptionsList = new List<Tax_Exemption__c>();
        for(CO_Header__c coHeaderRec : COHeaderNewList) {
            if(String.isNotBlank(coHeaderRec.Order_Status__c) && coHeaderRec.Order_Status__c == 'Open') {
                List<Tax_Exemption__c> taxExemptions = new List<Tax_Exemption__c>();
                for(Tax_Exemption__c taxExemption : taxExemptionsList) {
                    if(coHeaderRec.Customer__c != null && customerIdToAccountTypeMap.get(coHeaderRec.Customer__c) != null && customerIdToAccountTypeMap.get(coHeaderRec.Customer__c).Account_Type__c == taxExemption.Account_Type__c) {
                        Tax_Exemption__c newTaxExemption = taxExemption.clone(false, false, false, false);
                        newTaxExemption.CO_Header__c = coHeaderRec.Id;
                        newTaxExemption.Account_Type__c = null;
                        coHeaderTaxExemptionsList.add(newTaxExemption);
                    }
                }
            }
            coHeaderRec.Account_Type__c = customerIdToAccountTypeMap.get(coHeaderRec.Customer__c) != null ? customerIdToAccountTypeMap.get(coHeaderRec.Customer__c).Account_Type__c: null;
        }
        
        if(isUpdate) {
            update COHeaderNewList;
        }
        
        // Step 4 - Save Tax_Exemption__c records
        if(!coHeaderTaxExemptionsList.isEmpty()) {
            insert coHeaderTaxExemptionsList;
        }
    }
}