/**
 * Author: Tarun Khandelwal
 * Since: March 27, 2014
 * Name: TaxCalculation
 * Description: Used for Calculation of all type of taxes.
**/
public with sharing class TaxCalculation {
    
    public static Map<String, String> partPriceFieldLabelToFieldAPINameMap = new Map<String, String>{'Price' => 'Retail_Price__c', 'MSRP' => 'MSRP__c', 
                                                                                                    'Cost' => 'Last_Cost__c', 'Average Cost' => 'Average_Cost__c'};
    public static String PART_PRICE_FIELD_API_NAME = 'Retail_Price__c';
    
        public static String COLI_TAX_FIELD_API_NAME = 'Tax__c'; 
    public static Set<String> COST_FIELDS_SET = new Set<String>{'Last_Cost__c', 'Average_Cost__c'};
    
    public static String getPricingFieldByPLBaseValueField(String priceLevel_baseValueField) {
        String pricingField = partPriceFieldLabelToFieldAPINameMap.containsKey(priceLevel_baseValueField) ? 
                            partPriceFieldLabelToFieldAPINameMap.get(priceLevel_baseValueField) : '';
        return pricingField;
    }
    
    /**
     * Name: partPriceCalculation
     * Desc: Calculate Tax accroding to Tax logic
     * @param:  (1) priceLevel_baseValueField - String - Picklist Value of Part Price Base field of Price Level
                (2) priceLevel_discountMarkup - Decimal - Discount Markup field value of Price Level
                (3) COLineItemRecords - List<CO_Line_Item__c> - List of CO Line Items records.
                (4) partIdToPartRecordMap -  Map<Id, Part__c> - Map of Id and Part Object
     * @return: List<CO_Line_Item__c>
    **/
    public static List<CO_Line_Item__c> partPriceCalculation(String priceLevel_baseValueField, Decimal priceLevel_discountMarkup, List<CO_Line_Item__c> COLineItemRecords, Map<Id, Part__c> partIdToPartRecordMap) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        String pricingField = getPricingFieldByPLBaseValueField(priceLevel_baseValueField);
        
        for(CO_Line_Item__c COlineItem : COLineItemRecords) {
            if(COlineItem.Part__c == null) {
                continue;
            }
            
            if(partIdToPartRecordMap.get(COlineItem.Part__c).get(pricingField) == null) {
                partIdToPartRecordMap.get(COlineItem.Part__c).put(pricingField, 0);
                COlineItem.Retail__c = 0;
            } else {
                Decimal baseValue = Decimal.valueOf(String.valueOf(partIdToPartRecordMap.get(coLineItem.Part__c).get(pricingField)));
                if(COlineItem.CO_Kit_Header__c != null || COlineItem.Kit_Header_Line_Item__c != null) {
                    COlineItem.Retail__c = baseValue;
                } else {
                    if(isTaxIncludingPricing && !COST_FIELDS_SET.contains(pricingField) && partIdToPartRecordMap.get(coLineItem.Part__c).Applicable_Tax__c != null) {
                        Decimal appTaxRate = partIdToPartRecordMap.get(coLineItem.Part__c).Applicable_Tax__r.Rate__c;
                        if(appTaxRate == -100 || appTaxRate == null) { // To handle divide by zero error
                            appTaxRate = 0;
                        }
                        baseValue = baseValue / (1 + (appTaxRate / 100));
                    }
                    COlineItem.Retail__c = (baseValue + (baseValue * priceLevel_discountMarkup / 100)).setScale(2, RoundingMode.HALF_UP);
                }
            }
            COlineItem.Price__c = (COlineItem.Retail__c != null) ? COlineItem.Retail__c.setScale(2, RoundingMode.HALF_UP) : 0;
        }
        return COLineItemRecords;
    }
    
    /**
     * Name: partPriceCalculation1
     * Desc: Calculate Tax accroding to Tax logic
     * @param:  (1) priceLevel_baseValueField - String - Picklist Value of Part Price Base field of Price Level
                (2) priceLevel_discountMarkup - Decimal - Discount Markup field value of Price Level
                (3) COlineItem - CO_Line_Item__c - CO Line Items record.
                (4) partIdToPartRecordMap -  Map<Id, Part__c> - Map of Id and Part Object
     * @return: void
    **/
    public static void partPriceCalculation1(String priceLevel_baseValueField, Decimal priceLevel_discountMarkup, CO_Line_Item__c COlineItem, 
                                                Map<Id, Part__c> partIdToPartRecordMap, Map<Id, Fee__c> feeIdToFeeRecordMap) {
        
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        String pricingField = getPricingFieldByPLBaseValueField(priceLevel_baseValueField);
        
        if(coLineItem.Part__c != null) {
            if(partIdToPartRecordMap.get(coLineItem.Part__c).get(pricingField) == null) {
                partIdToPartRecordMap.get(coLineItem.Part__c).put(pricingField, 0);
                COlineItem.Retail__c = 0;
            } else {
                Decimal baseValue = Decimal.valueOf(String.valueOf(partIdToPartRecordMap.get(coLineItem.Part__c).get(pricingField)));
                if(trigger.isInsert && isTaxIncludingPricing) {
                    if(priceLevel_discountMarkup == 0 && !COST_FIELDS_SET.contains(pricingField)) {
                        COlineItem.Price_When_Tax_Included__c = baseValue;
                    } else {
                        COlineItem.Price_When_Tax_Included__c = null;
                    }
                }
                
                if(COlineItem.CO_Kit_Header__c != null || COlineItem.Kit_Header_Line_Item__c != null) {
                    COlineItem.Retail__c = baseValue;
                } else {
                    if(isTaxIncludingPricing && !COST_FIELDS_SET.contains(pricingField) && partIdToPartRecordMap.get(coLineItem.Part__c).Applicable_Tax__c != null) {
                        Decimal appTaxRate = partIdToPartRecordMap.get(coLineItem.Part__c).Applicable_Tax__r.Rate__c;
                        if(appTaxRate == -100 || appTaxRate == null) { // To handle divide by zero error
                            appTaxRate = 0;
                        }
                        baseValue = baseValue / (1 + (appTaxRate / 100));
                    }
                    COlineItem.Retail__c = (baseValue + (baseValue * priceLevel_discountMarkup / 100)).setScale(2, RoundingMode.HALF_UP);
                }
            }        
            if(trigger.isInsert && partIdToPartRecordMap.get(coLineItem.Part__c).get(PART_PRICE_FIELD_API_NAME) != null) {
                COlineItem.Actual_Retail_Price__c = Decimal.valueOf(String.valueOf(partIdToPartRecordMap.get(coLineItem.Part__c).get(PART_PRICE_FIELD_API_NAME)));
            }
            
        } else if(COlineItem.Fee__c != null) {
            Decimal feePrice;
            if(COlineItem.Is_Environmental_Fee__c || COlineItem.Is_Linked_Fee__c || COlineItem.Type__c == Constants.SHOP_SUPPLY) {
                if(isTaxIncludingPricing) {
                    feePrice = (coLineItem.Price_When_Tax_Included__c != null) ? coLineItem.Price_When_Tax_Included__c : 0;
                } else {
                    feePrice = (coLineItem.Price__c != null) ? coLineItem.Price__c : 0;
                }
            } else {
                feePrice = feeIdToFeeRecordMap.get(coLineItem.Fee__c).Price__c;
            }
            if(isTaxIncludingPricing) {
                Decimal appTaxRate = feeIdToFeeRecordMap.get(coLineItem.Fee__c).Applicable_Tax__r.Rate__c;
                if(appTaxRate == -100 || appTaxRate == null) { // To handle divide by zero error
                    appTaxRate = 0;
                }
                feePrice = feePrice / (1 + (appTaxRate / 100));
            }
            COlineItem.Retail__c = feePrice.setScale(2, RoundingMode.HALF_UP);
        }         
        if(trigger.isInsert) {
            COlineItem.Price__c = (COlineItem.Retail__c != null) ? COlineItem.Retail__c.setScale(2, RoundingMode.HALF_UP) : 0;
            COlineItem.Actual_Kit_Price__c = COlineItem.Price__c.setScale(2, RoundingMode.HALF_UP);
        }
    }
    /**
     * Name: salesTaxCalculation
     * Desc: Calculate Sales Tax accroding to logic
     * @param:  (1) salesTaxIdList - List<Id> - List of sales tax records Ids
                (2) partIdToSalesTaxItemIdsMap - Map<Id, Set<Id>> - Map of part Id and sales tax item records
                                                     Key -          Part Record Id
                                                     Value -        Set of sales tax item ids
                (3) COHeaderList - List<CO_Header__c> - List of CO Header records.
                (4) COHeaderIdToCOLineItemRecordsMap - Map<Id, List<Sobject>> - Map of Id and Sobject
                                                               Key - Id - CO Header Id
                                                               Value - SObject - Corresponding CO line item records
                (5) defaultSalesTax - List<Sales_Tax__c> - Default sales tax                                               
     * @return: List<CO_Line_Item__c>
    **/
    public static List<CO_Line_Item__c> salesTaxCalculation(List<Id> salesTaxIdList, Map<Id, Set<Id>> partIdToSalesTaxItemIdsMap, List<CO_Header__c> COHeaderList, Map<Id, List<Sobject>> COHeaderIdToCOLineItemRecordsMap, List<Sales_Tax__c> defaultSalesTax ) {
        if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Applicable_Taxes__c> applicableTaxList = [select Sales_Tax_Item__c, Sales_Tax__c, Sales_Tax_Item__r.Tax_Parts__c, Sales_Tax_Item__r.Rate__c from Applicable_Taxes__c where Sales_Tax__c IN : salesTaxIdList];
        Map<Id, List<Applicable_Taxes__c>> salesTaxIdToAppTaxRecordsMap = new Map<Id, List<Applicable_Taxes__c>>();
        
        for(Applicable_Taxes__c appTax : applicableTaxList) {
            List<Applicable_Taxes__c> appTaxRecordList = new List<Applicable_Taxes__c>();
            if(!appTax.Sales_Tax_Item__r.Tax_Parts__c) {
                continue;
            }
            if(salesTaxIdToAppTaxRecordsMap.containsKey(appTax.Sales_Tax__c)) {
                appTaxRecordList = salesTaxIdToAppTaxRecordsMap.get(appTax.Sales_Tax__c);
            } 
            appTaxRecordList.add(appTax);
            salesTaxIdToAppTaxRecordsMap.put(appTax.Sales_Tax__c, appTaxRecordList);
        }
        
        Map<Id, Decimal> salesTaxIdToTaxRateMap = new Map<Id, Decimal>();
        for(Id salesTaxId : salesTaxIdToAppTaxRecordsMap.keyset()) {
            Decimal salesTaxRate = 0;
            for(Applicable_Taxes__c appTax : salesTaxIdToAppTaxRecordsMap.get(salesTaxId)) {
                salesTaxRate += appTax.Sales_Tax_Item__r.Rate__c;
            }
            salesTaxIdToTaxRateMap.put(salesTaxId, salesTaxRate);
        }
        
        List<Sobject> coLineItemToUpdate = new List<Sobject>();
        for(CO_Header__c COHeaderRec : COHeaderList) {
            Id salesTaxId;
            if(COHeaderRec.Customer__r.Sales_Tax__c == null) {
                salesTaxId = defaultSalesTax[0].Id;
            } else {
                salesTaxId = COHeaderRec.Customer__r.Sales_Tax__c;
            }
            if(COHeaderIdToCOLineItemRecordsMap.containsKey(COHeaderRec.Id)) {
                for(Sobject coLineItem : COHeaderIdToCOLineItemRecordsMap.get(COHeaderRec.Id)) {
                    if(coLineItem.get('Part__c') == null) {
                        continue;
                    }
                    Id partId = Id.valueOf(String.valueOf(coLineItem.get('Part__c')));
                    Decimal exemptionRate = 0;
                    if(salesTaxIdToAppTaxRecordsMap.containsKey(salesTaxId)) {
                        for(Applicable_Taxes__c appTax : salesTaxIdToAppTaxRecordsMap.get(salesTaxId)) {
                            if(partIdToSalesTaxItemIdsMap.get(partId).contains(appTax.Sales_Tax_Item__c)) {
                                exemptionRate += appTax.Sales_Tax_Item__r.Rate__c;
                            }
                        } 
                    }
                    Decimal rate = 0;
                    if(salesTaxIdToTaxRateMap.containsKey(salesTaxId)) {
                        rate = salesTaxIdToTaxRateMap.get(salesTaxId);
                    }
                    coLineItem.put(COLI_TAX_FIELD_API_NAME, rate - exemptionRate);
                    coLineItemToUpdate.add(coLineItem);
                }
            }
        }
        //system.assert(false, coLineItemToUpdate);
        return coLineItemToUpdate;
    }
    
    public static List<CO_Line_Item__c> salesTaxCalculation2(List<Id> salesTaxIdList, Map<Id, Set<Id>> coHeaderIdToSalesTaxItemIdsMap, List<CO_Line_Item__c> coLineItemList) {
        return salesTaxCalculation2(salesTaxIdList, coHeaderIdToSalesTaxItemIdsMap, coLineItemList, new Map<Id, Set<Id>>());
    }

    public static List<CO_Line_Item__c> salesTaxCalculation2(List<Id> salesTaxIdList, Map<Id, Set<Id>> coHeaderIdToSalesTaxItemIdsMap, 
                                            List<CO_Line_Item__c> coLineItemList, Map<Id, Set<Id>> soHeaderIdToSalesTaxItemIdsMap) {
        if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Applicable_Taxes__c> applicableTaxList = [SELECT Sales_Tax_Item__c, Sales_Tax__c, Sales_Tax_Item__r.Name__c, 
                                                            Sales_Tax_Item__r.Rate__c from Applicable_Taxes__c where Sales_Tax__c IN : salesTaxIdList];
        
        Map<Id, List<Applicable_Taxes__c>> salesTaxIdToAppTaxRecordsMap = new Map<Id, List<Applicable_Taxes__c>>();
        
        for(Applicable_Taxes__c appTax : applicableTaxList) {
            List<Applicable_Taxes__c> appTaxRecordList = new List<Applicable_Taxes__c>();
            if(salesTaxIdToAppTaxRecordsMap.containsKey(appTax.Sales_Tax__c)) {
                appTaxRecordList = salesTaxIdToAppTaxRecordsMap.get(appTax.Sales_Tax__c);
            } 
            appTaxRecordList.add(appTax);
            salesTaxIdToAppTaxRecordsMap.put(appTax.Sales_Tax__c, appTaxRecordList);
        }
        
        Map<Id, Decimal> salesTaxIdToTaxRateMap = new Map<Id, Decimal>();
        for(Id salesTaxId : salesTaxIdToAppTaxRecordsMap.keyset()) {
            Decimal salesTaxRate = 0;
            for(Applicable_Taxes__c appTax : salesTaxIdToAppTaxRecordsMap.get(salesTaxId)) {
                salesTaxRate += appTax.Sales_Tax_Item__r.Rate__c;
            }
            salesTaxIdToTaxRateMap.put(salesTaxId, salesTaxRate);
        }
        
        List<Sobject> coLineItemToUpdate = new List<Sobject>();
        List<Individual_Tax__c> individualTaxToInsert = new List<Individual_Tax__c>();
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        for(CO_Line_Item__c coLineItemRec : coLineItemList) {
            Id salesTaxId;
            Boolean isInternalTaxLI = false;
            if((coLineItemRec.Deal__c != null) || (coLineItemRec.Service_Order_Line_Item__c != null && coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__r.Job_Type__c == 'Internal')) {
                salesTaxId = GeneralConfiguration.getDefaultSalesTaxOnInternalService();
                isInternalTaxLI = true;
            }
            
            if(String.isBlank(salesTaxId)) {
                if(coLineItemRec.Part__r.Applicable_Tax__c != null) {
                    salesTaxId = coLineItemRec.Part__r.Applicable_Tax__c;
                } else if(coLineItemRec.Fee__r.Applicable_Tax__c != null) {
                    salesTaxId = coLineItemRec.Fee__r.Applicable_Tax__c;
                } 
            }
            if(salesTaxId == null || String.isNotBlank(coLineItemRec.Deal__c)) {
                if(isTaxIncludingPricing && coLineItemRec.Price__c != null) {
                    coLineItemRec.Price_When_Tax_Included__c = coLineItemRec.Price__c;
                    coLineItemToUpdate.add(coLineItemRec);
                }
                continue;
            }
            
            Decimal exemptionRate = 0;
            if(salesTaxIdToAppTaxRecordsMap.containsKey(salesTaxId)) {
                for(Applicable_Taxes__c appTax : salesTaxIdToAppTaxRecordsMap.get(salesTaxId)) {
                    if(coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__r.Provider__c != null && 
                            soHeaderIdToSalesTaxItemIdsMap.containsKey(coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__c) &&
                            soHeaderIdToSalesTaxItemIdsMap.get(coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__c).contains(appTax.Sales_Tax_Item__c)) {
                        exemptionRate += appTax.Sales_Tax_Item__r.Rate__c;
                    
                    } else if((coLineItemRec.Service_Order_Line_Item__c == null || 
                        (coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__r.Job_Type__c != 'Internal' && coLineItemRec.Service_Order_Line_Item__r.Service_Order_Header__r.Provider__c == null)) 
                        && coLineItemRec.CO_Header__r.Customer__c != null 
                        && coHeaderIdToSalesTaxItemIdsMap.containsKey(coLineItemRec.CO_Header__c) 
                        && coHeaderIdToSalesTaxItemIdsMap.get(coLineItemRec.CO_Header__c).contains(appTax.Sales_Tax_Item__c)) {
                        exemptionRate += appTax.Sales_Tax_Item__r.Rate__c;
                    }  
                    else { // Individual sales Taxes
                        if(coLineItemRec.Deal__c == null) {
                            Individual_Tax__c individualTaxRec = new Individual_Tax__c();
                            individualTaxRec.CO_Line_Item__c = coLineItemRec.Id;
                            if(coLineItemRec.Service_Order_Line_Item__c != null) {
                                individualTaxRec.Service_Order_Line_Item__c = coLineItemRec.Service_Order_Line_Item__c;
                            }
                            individualTaxRec.Sales_Tax_Item_Name__c = appTax.Sales_Tax_Item__r.Name__c;
                            individualTaxRec.Tax_Rate__c = appTax.Sales_Tax_Item__r.Rate__c;
                            individualTaxToInsert.add(individualTaxRec);
                        }
                    } 
                }
            }
            Decimal rate = 0;
            if(salesTaxIdToTaxRateMap.containsKey(salesTaxId)) {
                rate = salesTaxIdToTaxRateMap.get(salesTaxId);
            }
            if(coLineItemRec.Deal__c == null) {
                coLineItemRec.Tax__c = (rate - exemptionRate);
            } else {
                coLineItemRec.Tax__c = 0;
            }
            if(isTaxIncludingPricing) {
                if(coLineItemRec.Type__c == Constants.SHOP_SUPPLY) {
                    coLineItemRec.Price_When_Tax_Included__c = (coLineItemRec.Price__c + (coLineItemRec.Price__c * rate / 100).setScale(2, RoundingMode.HALF_UP));
                    coLineItemRec.Price__c = (coLineItemRec.Price_When_Tax_Included__c / (1 + coLineItemRec.Tax__c / 100).setScale(2, RoundingMode.HALF_UP));
                } else if(coLineItemRec.Price__c != null && (isInternalTaxLI || coLineItemRec.Price_When_Tax_Included__c == null || exemptionRate != 0)) {
                    coLineItemRec.Price_When_Tax_Included__c = (coLineItemRec.Price__c + (coLineItemRec.Price__c * coLineItemRec.Tax__c / 100).setScale(2, RoundingMode.HALF_UP));
                }
            }
            coLineItemToUpdate.add(coLineItemRec);
        }
        if(individualTaxToInsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); } //FLS Create Nikhil 31/01/2017 
            insert individualTaxToInsert;
        }
        return coLineItemToUpdate;
    }
    
    public static void setTotalForMerchSection(String coHeaderId) {
        CO_Header__c coHeaderRec = populateOrderTotal(coHeaderId, true);
    }
    
    public static void populateOrderTotal(String coHeaderId) {
        populateOrderTotal(coHeaderId, true);
    }
    
    public static CO_Header__c populateOrderTotal(String coHeaderId, Boolean isUpdate) {
        // Sum of Invoiced Amount and Uninvoiced Amount
        List<CO_Invoice_Header__c> coInvoiceHeaderList = [select Total__c, SalesTax_Total__c, Deductible_Total__c 
                                                            from CO_Invoice_Header__c 
                                                            where CO_Header__c = :coHeaderId
                                                                AND Invoice_Status__c = 'Closed'
                                                                AND (Checkout_Type__c = 'Customer' OR Checkout_Type__c = 'Third-Party' OR Checkout_Type__c = 'Internal')];
        
        Decimal invoicedTotal = 0;
        Decimal deductibleTotal = 0;
        for(CO_Invoice_Header__c COIH : coInvoiceHeaderList){
            deductibleTotal += (COIH.Deductible_Total__c != null ? COIH.Deductible_Total__c : 0);
            invoicedTotal += (COIH.Total__c != null ? COIH.Total__c : 0);
        }
        
        Decimal nonInvoicedTotal = getNonInvoicedAmount(coHeaderId) - deductibleTotal;
        
        CO_Header__c coHeaderRec = new CO_Header__c(Id = coHeaderId, Invoiced_Amount__c = invoicedTotal, Uninvoiced_Amount__c = nonInvoicedTotal);
        if(isUpdate) {
            update coHeaderRec;
        }
        return coHeaderRec;
    }
    
    private static Decimal getNonInvoicedAmount(String coHeaderId) {
        List<CO_Header__c> coHeaderList = [select Id,
                                            (select Qty__c, Price__c, Price_When_Tax_Included__c, Tax_Amount__c from CO_Line_Items__r where Is_In_Merch_Section__c = true AND Closed_CO_Invoice_link__c = null),
                                            (select Total__c from Service_Order_Headers__r where Work_Status__c != 'Invoiced' AND Deal__c = null),
                                            (select F_I_Total__c, F_I_Tax_Total__c, Type__c, Subtotal__c from Deals__r where Status__c != 'Invoiced')
                                         from CO_Header__c
                                         where Id = :coHeaderId];
        Decimal subTotal = 0;
        Decimal nonInvoicedTotalTax = 0;
        Set<Id> coLineItemIds = new Set<Id>();
        Set<Id> serviceOrderHeaderIds = new Set<Id>();
        Set<Id> dealIds = new Set<Id>();
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Decimal nonInvoicedTotal = 0;
        
        if(!isTaxIncludingPricing) {
            for(CO_Header__c coHeader : coHeaderList) {
                for(CO_Line_Item__c coli : coHeader.CO_Line_Items__r){
                    coLineItemIds.add(coli.Id);
                    subTotal += (coli.Qty__c != null ? coli.Qty__c : 0) * (coli.Price__c != null ? coli.Price__c : 0);
                }
                for(Service_Order_Header__c soHeader : coHeader.Service_Order_Headers__r){
                    serviceOrderHeaderIds.add(soHeader.Id);
                    subTotal += (soHeader.Total__c != null ? soHeader.Total__c : 0);
                }
                for(Deal__c dealRec : coHeader.Deals__r) {
                    dealIds.add(dealRec.Id);
                    subTotal += (dealRec.Subtotal__c != null ? dealRec.Subtotal__c : 0);
                    if(dealRec.Type__c == 'Financed') {
                        subTotal += (dealRec.F_I_Total__c != null ? dealRec.F_I_Total__c : 0);
                    }
                }
            }
        
            List<Individual_Tax__c> individualTaxList = [select Sales_Tax_Item_Name__c, Taxable_Amount__c, Tax_Rate__c, 
                                                            Form_Label__c, Applicable_Tax__c, List_Tax_items_on_forms__c 
                                                        from Individual_Tax__c
                                                        where CO_Line_Item__c IN :coLineItemIds
                                                            OR Service_Order_Line_Item__r.Service_Order_Header__c IN :serviceOrderHeaderIds
                                                            OR Option_Fee__r.Deal__c IN: dealIds
                                                            OR Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c IN: dealIds
                                                            OR F_I_Product__r.Deal_Finance__r.Deal__c IN: dealIds
                                                            OR (Deal_Item__r.Deal__c IN: dealIds AND Deal_Item__r.Type__c = 'Trade In')];
            
            Map<String, Decimal> salesTaxNameToTaxValue = getTaxAmountWithFormLabel(individualTaxList);
            
            for(String taxName : salesTaxNameToTaxValue.keySet()) {
                nonInvoicedTotalTax += salesTaxNameToTaxValue.get(taxName); 
            }
            nonInvoicedTotal = subTotal + nonInvoicedTotalTax;
        } else {
            for(CO_Header__c coHeader : coHeaderList) {
                for(CO_Line_Item__c coli : coHeader.CO_Line_Items__r){
                    coli.Qty__c = (coli.Qty__c != null) ? coli.Qty__c : 0;
                    Decimal price = (coli.Price_When_Tax_Included__c != null) ? coli.Price_When_Tax_Included__c : (coli.Price__c + coli.Tax_Amount__c);
                    subTotal += (coli.Qty__c * price);
                }
                for(Service_Order_Header__c soHeaderRec : coHeader.Service_Order_Headers__r) {
                    subTotal += (soHeaderRec.Total__c != null) ? soHeaderRec.Total__c : 0;
                }
                for(Deal__c dealRec : coHeader.Deals__r) {
                    subTotal += (dealRec.Subtotal__c != null) ? dealRec.Subtotal__c : 0;
                    if(dealRec.Type__c == 'Financed') {
                        subTotal += (dealRec.F_I_Total__c != null ? dealRec.F_I_Total__c : 0);
                        subTotal += (dealRec.F_I_Tax_Total__c != null ? dealRec.F_I_Tax_Total__c : 0);
                    }
                }
            }
            nonInvoicedTotal = subTotal;
        }
        
        return nonInvoicedTotal.setScale(2, RoundingMode.HALF_UP);
    } 
    
    private static Decimal getCOLISubTotal(List<CO_Line_Item__c> coLineItemList) {
        Decimal subTotal = 0;
        for(CO_Line_Item__c coLineItemRec : coLineItemList) {
            subTotal += ((coLineItemRec.Qty__c != null ? coLineItemRec.Qty__c : 0) * (coLineItemRec.Price__c != null ? coLineItemRec.Price__c : 0));
        }
        return subTotal.setScale(2, RoundingMode.HALF_UP);
    }
    
    private static Decimal getSOLISubTotal(List<Service_Order_Line_Item__c> serviceOrderLineItems) {
        Decimal subTotal = 0;
        for(Service_Order_Line_Item__c soli : serviceOrderLineItems) {
            subTotal += ((soli.Qty_Needed__c != null ? soli.Qty_Needed__c : 0) * (soli.Kit_Price__c != null ? soli.Kit_Price__c : 0));
        }
        return subTotal.setScale(2, RoundingMode.HALF_UP);
    }
    
    
    public static void calculateCOHeaderTax(String coHeaderId){
        // Query COLI Merchsection
        // List<Individual Tax>
        //Map taxNameTotaxRate = calculateIndividualtaxRate();
        //Map taxNameToTaxableAmount = calculateTaxableAmount();
    }
    
    public static Decimal getTaxAmountFromCOLIList(List<CO_Line_Item__c> coLineItemList){
        List<Individual_Tax__c> individualItemsList = getApplicableTaxListFromCOLIList(coLineItemList);
        Map<String, Decimal> taxItemToTaxRateMap = getIndividualtaxRateMap(individualItemsList);
        Map<String, Decimal> taxItemToTaxAmountMap = getTaxableAmountMap(individualItemsList);
        return calculateTaxableAmount(taxItemToTaxRateMap, taxItemToTaxAmountMap);
    }
    
    private static Decimal getTaxAmountFromSOLIList(List<Service_Order_Line_Item__c> serviceOrderLineItems){
        List<Individual_Tax__c> individualItemsList = getApplicableTaxListFromSOLIList(serviceOrderLineItems);
        Map<String, Decimal> taxItemToTaxRateMap = getIndividualtaxRateMap(individualItemsList);
        Map<String, Decimal> taxItemToTaxAmountMap = getTaxableAmountMap(individualItemsList);
        return calculateTaxableAmount(taxItemToTaxRateMap, taxItemToTaxAmountMap);
    }
    
    
    public static List<Individual_Tax__c> getApplicableTaxListFromCOLIList(List<CO_Line_Item__c> coLineItemList) {
        return getApplicableTaxList(coLineItemList);
    }
    
    
    public static List<Individual_Tax__c> getApplicableTaxListFromSOLIList(List<Service_Order_Line_Item__c> serviceOrderLineItems) {
        return getApplicableTaxList(serviceOrderLineItems);
    }
    
    public static List<Individual_Tax__c> getApplicableTaxList(List<Sobject> sobjectList) {
        List<Individual_Tax__c> individualItemsList = new List<Individual_Tax__c>();
        for(sObject sobjRec : sobjectList){
            for(sObject taxItem : sobjRec.getSobjects('Individual_Taxes__r')){
                individualItemsList.add((Individual_Tax__c)taxItem);
            }
        }
        return individualItemsList;
    }
    
    
    
    public static Map<String, Decimal> getIndividualtaxRateMap(List<Individual_Tax__c> individualTaxList){
        Map<String, Set<Decimal>> taxItemToTaxRateSetMap = new Map<String, Set<Decimal>>();
        for(Individual_Tax__c taxItem : individualTaxList) {
            if(!taxItemToTaxRateSetMap.containsKey(taxItem.Sales_Tax_Item_Name__c)) {
                taxItemToTaxRateSetMap.put(taxItem.Sales_Tax_Item_Name__c, new Set<Decimal>());
            }
            if(taxItem.Tax_Rate__c != null) {
                taxItemToTaxRateSetMap.get(taxItem.Sales_Tax_Item_Name__c).add(taxItem.Tax_Rate__c);
            }
        }
        
        Map<String, Decimal> taxItemToTaxRateMap = new Map<String, Decimal>();
        for(String taxItemName : taxItemToTaxRateSetMap.keySet()) {
            Decimal totalTaxRate = 0;
            for(Decimal taxRate : taxItemToTaxRateSetMap.get(taxItemName)) {
                totalTaxRate += taxRate;
            }
            taxItemToTaxRateMap.put(taxItemName, totalTaxRate);
        }
        return taxItemToTaxRateMap;
    }
    
    // Added by RM(Discussed with TK): Copy created for this function in AccountingCustomerInvoice for trade in taxable amount. If any changes required here please add those in copy as well.
    public static Map<String, Decimal> getTaxableAmountMap(List<Individual_Tax__c> individualTaxList) {
        Map<String, Decimal> taxItemToTaxAmountMap = new Map<String, Decimal>();
        for(Individual_Tax__c taxItem : individualTaxList){
            if(!taxItemToTaxAmountMap.containsKey(taxItem.Sales_Tax_Item_Name__c)){
                taxItemToTaxAmountMap.put(taxItem.Sales_Tax_Item_Name__c, 0);
            }
            taxItemToTaxAmountMap.put(taxItem.Sales_Tax_Item_Name__c, taxItemToTaxAmountMap.get(taxItem.Sales_Tax_Item_Name__c) + taxItem.Taxable_Amount__c);
        }
        return taxItemToTaxAmountMap;
    }
    
    private static Decimal calculateTaxableAmount(Map<String, Decimal> taxItemToTaxRateMap, Map<String, Decimal> taxItemToTaxAmountMap){
        Decimal taxAmount = 0;
        for(String taxName : taxItemToTaxRateMap.keySet()){
            taxAmount += (((taxItemToTaxRateMap.get(taxName) * taxItemToTaxAmountMap.get(taxName)) / 100).setScale(2, RoundingMode.HALF_UP));
        }
        return taxAmount;
    }
    
    public static Boolean isInvoiced = true;
    // Added by TK --- To get TaxAmount when needed to show with form Label.
    public static Map<String, Decimal> getTaxAmountWithFormLabel(List<Individual_Tax__c> individualTaxList) {
        Map<String, Decimal> taxItemToTaxRateMap = getIndividualtaxRateMap(individualTaxList);
        Map<String, Map<String, Decimal>> appTaxNameToTaxItemNameToTaxableAmountMap = new Map<String, Map<String, Decimal>>();
        Map<String, Decimal> salesTaxNameToTaxValue = new Map<String, Decimal>();  // The Map which is to be return after calculation.
        Map<String, Boolean> appTaxNameToListFormFlagMap = new Map<String, Boolean>();
        Map<String, String> appTaxNameToAppTaxFormLabelMap = new Map<String, String>();
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        for(Individual_Tax__c taxItem : individualTaxList) {
            if(String.isNotBlank(taxItem.Applicable_Tax__c)) {
                if(!appTaxNameToTaxItemNameToTaxableAmountMap.containsKey(taxItem.Applicable_Tax__c)) {
                    appTaxNameToTaxItemNameToTaxableAmountMap.put(taxItem.Applicable_Tax__c, new Map<String, Decimal>());
                }
                Map<String, Decimal> taxNameToAmountMap = appTaxNameToTaxItemNameToTaxableAmountMap.get(taxItem.Applicable_Tax__c);
                if(!taxNameToAmountMap.containsKey(taxItem.Sales_Tax_Item_Name__c)){
                    taxNameToAmountMap.put(taxItem.Sales_Tax_Item_Name__c, 0);
                }
                Decimal taxableAmount = 0;
                if(!isTaxIncludingPricing) {
                    taxableAmount = (isInvoiced ? taxItem.Taxable_Amount__c : taxItem.Taxable_Amount_To_Invoice__c);   //Tax amount before invoice - when coli is in multiple status
                } else {
                    taxableAmount = (isInvoiced ? taxItem.Tax_Amount__c : taxItem.Tax_Amount_To_Invoice__c);   //Tax amount before invoice - when coli is in multiple status
                }
                taxNameToAmountMap.put(taxItem.Sales_Tax_Item_Name__c, taxNameToAmountMap.get(taxItem.Sales_Tax_Item_Name__c) + taxableAmount);
            }  
            appTaxNameToListFormFlagMap.put(taxItem.Applicable_Tax__c, taxItem.List_Tax_items_on_forms__c);
            appTaxNameToAppTaxFormLabelMap.put(taxItem.Applicable_Tax__c, taxItem.Form_Label__c);
        }
        
        // Iteration for Form label type Individual Items.
        Map<String, Map<String, Decimal>> appTaxNameToTaxItemNameToTaxAmountMap = new Map<String, Map<String, Decimal>>();
        Decimal taxAmount = 0;
        for(String appTaxName : appTaxNameToTaxItemNameToTaxableAmountMap.keySet()) {
            Map<String, Decimal> taxNameToTaxAmountMap = new Map<String, Decimal>();
            for(String taxItemName : appTaxNameToTaxItemNameToTaxableAmountMap.get(appTaxName).keyset()) {
                taxAmount = 0;
                if(taxItemToTaxRateMap.containsKey(taxItemName)) {
                    if(!isTaxIncludingPricing) {
                        taxAmount += (taxItemToTaxRateMap.get(taxItemName) * appTaxNameToTaxItemNameToTaxableAmountMap.get(appTaxName).get(taxItemName) / 100).setScale(2, RoundingMode.HALF_UP);
                    } else {
                        taxAmount += appTaxNameToTaxItemNameToTaxableAmountMap.get(appTaxName).get(taxItemName).setScale(2, RoundingMode.HALF_UP);
                    }
                }
                taxNameToTaxAmountMap.put(taxItemName, taxAmount);
            }
            appTaxNameToTaxItemNameToTaxAmountMap.put(appTaxName, taxNameToTaxAmountMap);
        }
        //system.assert(false, appTaxNameToTaxItemNameToTaxAmountMap);
        
        List<Sales_Tax_Item__c> salesTaxItemList = [select Forms_Label__c, Name__c from Sales_Tax_Item__c where Name__c IN: taxItemToTaxRateMap.keySet()];
        Map<String, String> salesTaxNameToSalesTaxFormLabelMap = new Map<String, String>();
        for(Sales_Tax_Item__c salesTaxRec: salesTaxItemList) {
            if(!salesTaxNameToSalesTaxFormLabelMap.containsKey(salesTaxRec.Name__c)) {
                salesTaxNameToSalesTaxFormLabelMap.put(salesTaxRec.Name__c, salesTaxRec.Forms_Label__c);
            }
        }
        
        // for creating taxable Map
        Decimal appTaxAmount = 0;
        for(String appTaxName : appTaxNameToTaxItemNameToTaxAmountMap.keySet()) {
            if(appTaxNameToListFormFlagMap.containsKey(appTaxName) && !appTaxNameToListFormFlagMap.get(appTaxName)) {
                appTaxAmount = 0;
                for(String taxItemName : appTaxNameToTaxItemNameToTaxAmountMap.get(appTaxName).keySet()) {
                    appTaxAmount += appTaxNameToTaxItemNameToTaxAmountMap.get(appTaxName).get(taxItemName);
                }
                // Logic to replace sales Tax Item name with Form Label.
                if(appTaxNameToAppTaxFormLabelMap.containsKey(appTaxName)) {
                    appTaxName = appTaxNameToAppTaxFormLabelMap.get(appTaxName);
                }
                if(!salesTaxNameToTaxValue.containsKey(appTaxName)) {
                    salesTaxNameToTaxValue.put(appTaxName, 0);
                }
                salesTaxNameToTaxValue.put(appTaxName, (salesTaxNameToTaxValue.get(appTaxName) + appTaxAmount));
            } else {
                for(String taxItemName : appTaxNameToTaxItemNameToTaxAmountMap.get(appTaxName).keySet()) {
                    appTaxAmount = appTaxNameToTaxItemNameToTaxAmountMap.get(appTaxName).get(taxItemName);
                    
                    // Logic to replace sales Tax Item name with Form Label.
                    if(salesTaxNameToSalesTaxFormLabelMap.containsKey(taxItemName)) {
                        taxItemName = salesTaxNameToSalesTaxFormLabelMap.get(taxItemName);
                    }
                    if(!salesTaxNameToTaxValue.containsKey(taxItemName)) {
                        salesTaxNameToTaxValue.put(taxItemName, 0);
                    }
                    salesTaxNameToTaxValue.put(taxItemName, (salesTaxNameToTaxValue.get(taxItemName) + appTaxAmount));
                }
            }
        }
        
        return salesTaxNameToTaxValue;
    }
    
    // Overrided getTaxAmountWithFormLabel for avoiding querying of salesTaxItemList in for loop when this function is called for bulk records
    public static Map<String, Decimal> getTaxAmountWithFormLabel(List<Individual_Tax__c> individualTaxList, List<Sales_Tax_Item__c> salesTaxItemList) {
        Map<String, Decimal> taxItemToTaxRateMap = getIndividualtaxRateMap(individualTaxList);
        Map<String, Map<String, Decimal>> appTaxNameToTaxItemNameToTaxableAmountMap = new Map<String, Map<String, Decimal>>();
        Map<String, Decimal> salesTaxNameToTaxValue = new Map<String, Decimal>();  // The Map which is to be return after calculation.
        Map<String, Boolean> appTaxNameToListFormFlagMap = new Map<String, Boolean>();
        Map<String, String> appTaxNameToAppTaxFormLabelMap = new Map<String, String>();
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        for(Individual_Tax__c taxItem : individualTaxList) {
            if(String.isNotBlank(taxItem.Applicable_Tax__c)) {
                if(!appTaxNameToTaxItemNameToTaxableAmountMap.containsKey(taxItem.Applicable_Tax__c)) {
                    appTaxNameToTaxItemNameToTaxableAmountMap.put(taxItem.Applicable_Tax__c, new Map<String, Decimal>());
                }
                Map<String, Decimal> taxNameToAmountMap = appTaxNameToTaxItemNameToTaxableAmountMap.get(taxItem.Applicable_Tax__c);
                if(!taxNameToAmountMap.containsKey(taxItem.Sales_Tax_Item_Name__c)){
                    taxNameToAmountMap.put(taxItem.Sales_Tax_Item_Name__c, 0);
                }
                Decimal taxableAmount = 0;
                /*if(taxItem.CO_Line_Item__c != null) {
                    if(taxItem.CO_Line_Item__r.Closed_CO_Invoice_link__c != null) {
                        isInvoiced = true;
                    } else {
                        isInvoiced = false;
                    }
                }
                if(!isTaxIncludingPricing) {
                    taxableAmount = (isInvoiced ? taxItem.Taxable_Amount__c : taxItem.Taxable_Amount_To_Invoice__c);   //Tax amount before invoice - when coli is in multiple status
                } else {
                    taxableAmount = (isInvoiced ? taxItem.Tax_Amount__c : taxItem.Tax_Amount_To_Invoice__c);   //Tax amount before invoice - when coli is in multiple status
                }*/
                if(!isTaxIncludingPricing) {
                    taxableAmount = taxItem.Taxable_Amount__c;
                } else {
                    taxableAmount = taxItem.Tax_Amount__c;
                }
                taxNameToAmountMap.put(taxItem.Sales_Tax_Item_Name__c, taxNameToAmountMap.get(taxItem.Sales_Tax_Item_Name__c) + taxableAmount);
            }  
            appTaxNameToListFormFlagMap.put(taxItem.Applicable_Tax__c, taxItem.List_Tax_items_on_forms__c);
            appTaxNameToAppTaxFormLabelMap.put(taxItem.Applicable_Tax__c, taxItem.Form_Label__c);
        }
        
        // Iteration for Form label type Individual Items.
        Map<String, Map<String, Decimal>> appTaxNameToTaxItemNameToTaxAmountMap = new Map<String, Map<String, Decimal>>();
        Decimal taxAmount = 0;
        for(String appTaxName : appTaxNameToTaxItemNameToTaxableAmountMap.keySet()) {
            Map<String, Decimal> taxNameToTaxAmountMap = new Map<String, Decimal>();
            for(String taxItemName : appTaxNameToTaxItemNameToTaxableAmountMap.get(appTaxName).keyset()) {
                taxAmount = 0;
                if(taxItemToTaxRateMap.containsKey(taxItemName)) {
                    if(!isTaxIncludingPricing) {
                        taxAmount += (taxItemToTaxRateMap.get(taxItemName) * appTaxNameToTaxItemNameToTaxableAmountMap.get(appTaxName).get(taxItemName) / 100).setScale(2, RoundingMode.HALF_UP);
                    } else {
                        taxAmount += appTaxNameToTaxItemNameToTaxableAmountMap.get(appTaxName).get(taxItemName).setScale(2, RoundingMode.HALF_UP);
                    }
                }
                taxNameToTaxAmountMap.put(taxItemName, taxAmount);
            }
            appTaxNameToTaxItemNameToTaxAmountMap.put(appTaxName, taxNameToTaxAmountMap);
        }
        //system.assert(false, appTaxNameToTaxItemNameToTaxAmountMap);
        
        Map<String, String> salesTaxNameToSalesTaxFormLabelMap = new Map<String, String>();
        for(Sales_Tax_Item__c salesTaxRec: salesTaxItemList) {
            if(!salesTaxNameToSalesTaxFormLabelMap.containsKey(salesTaxRec.Name__c)) {
                salesTaxNameToSalesTaxFormLabelMap.put(salesTaxRec.Name__c, salesTaxRec.Forms_Label__c);
            }
        }
        
        // for creating taxable Map
        Decimal appTaxAmount = 0;
        for(String appTaxName : appTaxNameToTaxItemNameToTaxAmountMap.keySet()) {
            if(appTaxNameToListFormFlagMap.containsKey(appTaxName) && !appTaxNameToListFormFlagMap.get(appTaxName)) {
                appTaxAmount = 0;
                for(String taxItemName : appTaxNameToTaxItemNameToTaxAmountMap.get(appTaxName).keySet()) {
                    appTaxAmount += appTaxNameToTaxItemNameToTaxAmountMap.get(appTaxName).get(taxItemName);
                }
                // Logic to replace sales Tax Item name with Form Label.
                if(appTaxNameToAppTaxFormLabelMap.containsKey(appTaxName)) {
                    appTaxName = appTaxNameToAppTaxFormLabelMap.get(appTaxName);
                }
                if(!salesTaxNameToTaxValue.containsKey(appTaxName)) {
                    salesTaxNameToTaxValue.put(appTaxName, 0);
                }
                salesTaxNameToTaxValue.put(appTaxName, (salesTaxNameToTaxValue.get(appTaxName) + appTaxAmount));
            } else {
                for(String taxItemName : appTaxNameToTaxItemNameToTaxAmountMap.get(appTaxName).keySet()) {
                    appTaxAmount = appTaxNameToTaxItemNameToTaxAmountMap.get(appTaxName).get(taxItemName);
                    
                    // Logic to replace sales Tax Item name with Form Label.
                    if(salesTaxNameToSalesTaxFormLabelMap.containsKey(taxItemName)) {
                        taxItemName = salesTaxNameToSalesTaxFormLabelMap.get(taxItemName);
                    }
                    if(!salesTaxNameToTaxValue.containsKey(taxItemName)) {
                        salesTaxNameToTaxValue.put(taxItemName, 0);
                    }
                    salesTaxNameToTaxValue.put(taxItemName, (salesTaxNameToTaxValue.get(taxItemName) + appTaxAmount));
                }
            }
        }
        
        return salesTaxNameToTaxValue;
    }
    
    public static Map<String, Decimal> getTaxAmount(List<Individual_Tax__c> individualTaxList) {
        Map<String, Decimal> taxItemToTaxRateMap = getIndividualtaxRateMap(individualTaxList);
        Map<String, Map<String, Decimal>> appTaxNameToTaxItemNameToTaxableAmountMap = new Map<String, Map<String, Decimal>>();
        Map<String, Decimal> salesTaxNameToTaxValue = new Map<String, Decimal>();  // The Map which is to be return after calculation.
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        for(Individual_Tax__c taxItem : individualTaxList) {
            if(String.isNotBlank(taxItem.Applicable_Tax__c)) {
                if(!appTaxNameToTaxItemNameToTaxableAmountMap.containsKey(taxItem.Applicable_Tax__c)) {
                    appTaxNameToTaxItemNameToTaxableAmountMap.put(taxItem.Applicable_Tax__c, new Map<String, Decimal>());
                }
                Map<String, Decimal> taxNameToAmountMap = appTaxNameToTaxItemNameToTaxableAmountMap.get(taxItem.Applicable_Tax__c);
                if(!taxNameToAmountMap.containsKey(taxItem.Sales_Tax_Item_Name__c)){
                    taxNameToAmountMap.put(taxItem.Sales_Tax_Item_Name__c, 0);
                }
                if(!isTaxIncludingPricing) {
                    taxNameToAmountMap.put(taxItem.Sales_Tax_Item_Name__c, taxNameToAmountMap.get(taxItem.Sales_Tax_Item_Name__c) + taxItem.Taxable_Amount__c);
                } else {
                    taxNameToAmountMap.put(taxItem.Sales_Tax_Item_Name__c, taxNameToAmountMap.get(taxItem.Sales_Tax_Item_Name__c) + taxItem.Tax_Amount__c);
                }
            } 
        }
        
        // Iteration for Form label type Individual Items.
        Map<String, Map<String, Decimal>> appTaxNameToTaxItemNameToTaxAmountMap = new Map<String, Map<String, Decimal>>();
        Decimal taxAmount = 0;
        for(String appTaxName : appTaxNameToTaxItemNameToTaxableAmountMap.keySet()) {
            Map<String, Decimal> taxNameToTaxAmountMap = new Map<String, Decimal>();
            for(String taxItemName : appTaxNameToTaxItemNameToTaxableAmountMap.get(appTaxName).keyset()) {
                taxAmount = 0;
                if(taxItemToTaxRateMap.containsKey(taxItemName)) {
                    if(!isTaxIncludingPricing) {
                        taxAmount += (taxItemToTaxRateMap.get(taxItemName) * appTaxNameToTaxItemNameToTaxableAmountMap.get(appTaxName).get(taxItemName) / 100).setScale(2, RoundingMode.HALF_UP);
                    } else {
                        taxAmount += appTaxNameToTaxItemNameToTaxableAmountMap.get(appTaxName).get(taxItemName).setScale(2, RoundingMode.HALF_UP);
                    }
                }
                taxNameToTaxAmountMap.put(taxItemName, taxAmount);
            }
            appTaxNameToTaxItemNameToTaxAmountMap.put(appTaxName, taxNameToTaxAmountMap);
        }
        
        // for creating taxable Map
        Decimal appTaxAmount = 0;
        for(String appTaxName : appTaxNameToTaxItemNameToTaxAmountMap.keySet()) {
            for(String taxItemName : appTaxNameToTaxItemNameToTaxAmountMap.get(appTaxName).keySet()) {
                appTaxAmount = appTaxNameToTaxItemNameToTaxAmountMap.get(appTaxName).get(taxItemName);
                
                if(!salesTaxNameToTaxValue.containsKey(taxItemName)) {
                    salesTaxNameToTaxValue.put(taxItemName, 0);
                }
                salesTaxNameToTaxValue.put(taxItemName, (salesTaxNameToTaxValue.get(taxItemName) + appTaxAmount));
            }
        }
        return salesTaxNameToTaxValue;
    }
    
    public class TaxDetail{
        public String TaxName;
        public Decimal TaxAmount;
        
        public TaxDetail(String taxName, Decimal taxableAmount, Decimal taxRate){
            if(taxableAmount == null){
                taxableAmount = 0;
            }
            if(taxRate == null){
                taxRate = 0;
            }
            this.TaxName = taxName;
            this.TaxAmount = (taxableAmount * taxRate).setScale(2, RoundingMode.HALF_UP);
        }
        
    }
    
    public static Map<Id, Set<Id>> getCOHeaderIdToTaxExemptionsIds(Set<Id> coHeaderIds) {
        if(AccessControl.ifObjectFieldIsAccessible('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Tax_Exemption__c> taxExemptionsList = [SELECT CO_Header__r.Customer__c, Sales_Tax_Item__r.Rate__c from Tax_Exemption__c where CO_Header__c IN: coHeaderIds];
        Map<Id, Set<Id>> coHeaderIdToSalesTaxItemIdsMap = new Map<Id, Set<Id>>();
        for(Id coHeaderId : coHeaderIds) {
            Set<Id> salesTaxItemIdSet = new Set<Id>();
            for(Tax_Exemption__c taxExemptionRec : taxExemptionsList) {
                if(taxExemptionRec.CO_Header__c == coHeaderId) {
                    salesTaxItemIdSet.add(taxExemptionRec.Sales_Tax_Item__c);
                }
            }
            coHeaderIdToSalesTaxItemIdsMap.put(coHeaderId, salesTaxItemIdSet);
        }
        return coHeaderIdToSalesTaxItemIdsMap;
    }
}