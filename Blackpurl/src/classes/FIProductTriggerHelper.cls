public with sharing class FIProductTriggerHelper {
    
    public static List<F_I_Product__c> FIProductNewList = new List<F_I_Product__c>();
    public static List<F_I_Product__c> FIProductOldList = new List<F_I_Product__c>();
    public static Map<Id, F_I_Product__c> FIProductNewMap = new Map<Id, F_I_Product__c>();
    public static Map<Id, F_I_Product__c> FIProductOldMap = new Map<Id, F_I_Product__c>();
    
    public static Set<String> dealIdSet = new Set<String>();
    
    public static Boolean isTriggerExecute = false;
    
    public static void beforeInsertCalculation() {
    	priceLevelCalculation();
    }
    
    public static void beforeUpdateCalculation() {
    	priceLevelCalculation();
    }
    
    public static void afterInsertCalculation() {
    	salesTaxCalculation();
    }
    public static void afterUpdateCalculation() {
    	Set<String> dealFinanceIdSet = new Set<String>();
    	for(F_I_Product__c fAndIProductRec : FIProductNewList) {
    		dealFinanceIdSet.add(fAndIProductRec.Deal_Finance__c);
    	}
    	updateDealFinanceTotal(dealFinanceIdSet);
    }
    public static void afterDeleteCalculation() {
    	Set<String> dealFinanceIdSet = new Set<String>();
    	for(F_I_Product__c fAndIProductRec : FIProductOldList) {
    		dealFinanceIdSet.add(fAndIProductRec.Deal_Finance__c);
    	}
    	updateDealFinanceTotal(dealFinanceIdSet);
    }
    
    
    private static void updateDealFinanceTotal(Set<String> dealFinanceObjIdSet) {
    	if(AccessControl.ifObjectFieldIsAccessible('F_I_Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Finance__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal_Finance__c> dealFinanceList = [Select Id, Deal__c, (Select Price__c, Sales_Tax_Percentage__c from F_I_Products__r) from Deal_Finance__c where Id =: dealFinanceObjIdSet];
        Decimal totalTax;
        Decimal totalPrice;
        Set<String> dealIdSet = new Set<String>();
        for(Deal_Finance__c dealFinanceRec : dealFinanceList) {
        	dealIdSet.add(dealFinanceRec.Deal__c);
            totalTax = 0.00;
            totalPrice = 0.00;
            for(F_I_Product__c fAndIProductRec : dealFinanceList[0].F_I_Products__r) {
                fAndIProductRec.Price__c = (fAndIProductRec.Price__c == null) ? 0 : fAndIProductRec.Price__c;
                fAndIProductRec.Sales_Tax_Percentage__c = (fAndIProductRec.Sales_Tax_Percentage__c == null) ? 0 : fAndIProductRec.Sales_Tax_Percentage__c;
                
                totalTax += (fAndIProductRec.Price__c * fAndIProductRec.Sales_Tax_Percentage__c / 100).setScale(2, RoundingMode.HALF_UP);
                totalPrice += (fAndIProductRec.Price__c != null) ? fAndIProductRec.Price__c : 0;
            }
            dealFinanceRec.F_I_Product_Tax_Total__c = totalTax;
            dealFinanceRec.F_I_Total__c = totalPrice;
        }
        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Finance__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	update dealFinanceList;
    	
    	OptionAndFeeTriggerHelper.updateDealTotal(dealIdSet);
    }
    
    private static void priceLevelCalculation() {
        if(AccessControl.ifObjectFieldIsAccessible('Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	 
        Set<Id> productIdSet = new Set<Id>();
        for(F_I_Product__c fAndIProductRec : FIProductNewList) {
        	dealIdSet.add(fAndIProductRec.Deal__c);
            if(fAndIProductRec.Vendor_Product__c != null) {
            	productIdSet.add(fAndIProductRec.Vendor_Product__c);
            }
        }
        
        productIdSet.remove(null);
        
    	Map<Id, Product__c> productIdToProductRecordMap = new Map<Id, Product__c>();
        if(AccessControl.ifObjectFieldIsAccessible('Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(productIdSet.size() > 0) {
        	productIdToProductRecordMap = new Map<Id, Product__c>([select Price__c, Taxable__c, Applicable_Tax__c, Applicable_Tax__r.Rate__c
        																from Product__c where Id IN: productIdSet]); 
        }
    	
    	if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Map<Id, Deal__c> dealItemIdTodealItemRecMap = new Map<Id, Deal__c>([select CO_Header__r.Discount_Markup_From_Prive_Level__c, CO_Header__r.Part_Price_Base_From_Price_Level__c
                                                                                            from Deal__c Where Id IN : dealIdSet]);
                                                                                            
        Decimal discount;
        String partPriceBase; 
		for(F_I_Product__c fAndIproductRec : FIProductNewList) {
        	discount = (dealItemIdTodealItemRecMap.get(fAndIproductRec.Deal__c).CO_Header__r.Discount_Markup_From_Prive_Level__c == null) ? 0 : dealItemIdTodealItemRecMap.get(fAndIproductRec.Deal__c).CO_Header__r.Discount_Markup_From_Prive_Level__c;
        	partPriceBase = dealItemIdTodealItemRecMap.get(fAndIproductRec.Deal__c).CO_Header__r.Part_Price_Base_From_Price_Level__c;
        	
            priceLevelCalculation(partPriceBase, discount, fAndIproductRec, productIdToProductRecordMap);
        }                                                                                  	
    }
    
    
    private static void priceLevelCalculation(String priceLevel_baseValueField, Decimal priceLevel_discountMarkup, F_I_Product__c fAndIproductRec, 
    											Map<Id, Product__c> productIdToProductRecordMap) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Decimal price = 0;
        if(fAndIproductRec.Vendor_Product__c != null) {
        	Decimal productPrice = productIdToProductRecordMap.get(fAndIproductRec.Vendor_Product__c).Price__c;
        	if(isTaxIncludingPricing) {
        		Decimal appTaxRate = productIdToProductRecordMap.get(fAndIproductRec.Vendor_Product__c).Applicable_Tax__r.Rate__c;
                if(appTaxRate == -100 || appTaxRate == null) { // To handle divide by zero error
                    appTaxRate = 0;
                }
                Decimal preTaxPricing = productPrice / (1 + (appTaxRate / 100));
                price = preTaxPricing;
        	} else {
        		price = productPrice;
        	}
        }
        
        if(trigger.isInsert && fAndIproductRec.Vendor_Product__c != null) {
            fAndIproductRec.Price__c = price ;
        }
    }
    
    public static void salesTaxCalculation() {
        isTriggerExecute = true;
        
        // Tax Exemption List
        List<F_I_Product__c> fAndIProductList = [SELECT Vendor_Product__c, Vendor_Product__r.Applicable_Tax__c, Vendor_Product__r.Applicable_Tax__r.Rate__c,
        												Deal__r.CO_Header__c, Deal__r.CO_Header__r.Customer__c, Price__c, Price_When_Tax_Included__c 
    												FROM F_I_Product__c where Id IN: trigger.new];
    	
    	Set<Id> customerIdSet = new Set<Id>();
    	Set<Id> coHeaderIds = new Set<Id>();
    	for(F_I_Product__c fAndIproductRec : fAndIProductList) {
    		if(fAndIproductRec.Deal__r.CO_Header__r.Customer__c != null && 
    			!customerIdSet.contains(fAndIproductRec.Deal__r.CO_Header__r.Customer__c)) {
    			customerIdSet.add(fAndIproductRec.Deal__r.CO_Header__r.Customer__c);
    			coHeaderIds.add(fAndIproductRec.Deal__r.CO_Header__c);
    		}
    	}

        // Get list of Tax Exemptions for given coHeader ids
        Map<Id, Set<Id>> coHeaderIdToSalesTaxItemIdsMap = TaxCalculation.getCOHeaderIdToTaxExemptionsIds(coHeaderIds);
        
        // Entity Tax Rate
        List<Id> salesTaxIdList = new List<Id>();
        for(F_I_Product__c fAndIproductRec : fAndIProductList) {
            if(fAndIproductRec.Vendor_Product__r.Applicable_Tax__c != null) {
                salesTaxIdList.add(fAndIproductRec.Vendor_Product__r.Applicable_Tax__c);
        	}
        }
        List<F_I_Product__c> fAndIProductListToUpdate = new List<F_I_Product__c>();
        fAndIProductListToUpdate.addAll(calculateSalesTax(salesTaxIdList, coHeaderIdToSalesTaxItemIdsMap, fAndIProductList));
        
        if(fAndIProductListToUpdate.size() > 0) {
        	if(AccessControl.ifObjectFieldIsUpdateable('F_I_Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update fAndIProductListToUpdate;
        }
    }
    
    private static List<F_I_Product__c> calculateSalesTax(List<Id> salesTaxIdList, Map<Id, Set<Id>> coHeaderIdToSalesTaxItemIdsMap, List<F_I_Product__c> fAndIProductList) {
        if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Applicable_Taxes__c> applicableTaxList = [SELECT Sales_Tax_Item__c, Sales_Tax__c, Sales_Tax_Item__r.Name__c, 
                                                            Sales_Tax_Item__r.Rate__c from Applicable_Taxes__c where Sales_Tax__c IN : salesTaxIdList];
        
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
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
        
        List<Sobject> fAndIProductListToUpdate = new List<Sobject>();
        List<Individual_Tax__c> individualTaxToInsert = new List<Individual_Tax__c>();
        for(F_I_Product__c fAndIproductRec : fAndIProductList) {
            Id salesTaxId;
            if(fAndIproductRec.Vendor_Product__r.Applicable_Tax__c != null) {
                salesTaxId = fAndIproductRec.Vendor_Product__r.Applicable_Tax__c;
            } 
            if(salesTaxId == null) {
            	if(isTaxIncludingPricing && fAndIproductRec.Price__c != null) {
            		fAndIproductRec.Price_When_Tax_Included__c = fAndIproductRec.Price__c;
            		fAndIProductListToUpdate.add(fAndIproductRec);
            	}
            	continue;
            }  
            
            fAndIproductRec.Applicable_Tax__c = salesTaxId;
            
            Decimal exemptionRate = 0;
            if(salesTaxIdToAppTaxRecordsMap.containsKey(salesTaxId)) { 
                for(Applicable_Taxes__c appTax : salesTaxIdToAppTaxRecordsMap.get(salesTaxId)) {
                    if(fAndIproductRec.Deal__r.CO_Header__r.Customer__c != null && 
                    	coHeaderIdToSalesTaxItemIdsMap.get(fAndIproductRec.Deal__r.CO_Header__c).contains(appTax.Sales_Tax_Item__c)) {
                        exemptionRate += appTax.Sales_Tax_Item__r.Rate__c;
                    } else {
                    	Individual_Tax__c individualTaxRec = new Individual_Tax__c();
                    	individualTaxRec.F_I_Product__c = fAndIproductRec.Id;
                    	individualTaxRec.Sales_Tax_Item_Name__c = appTax.Sales_Tax_Item__r.Name__c;
                    	individualTaxRec.Tax_Rate__c = appTax.Sales_Tax_Item__r.Rate__c;
                    	individualTaxToInsert.add(individualTaxRec);
                    }
                } 
            }
            Decimal rate = 0;
            if(salesTaxIdToTaxRateMap.containsKey(salesTaxId)) {
                rate = salesTaxIdToTaxRateMap.get(salesTaxId);
            }
            fAndIproductRec.Sales_Tax_Percentage__c = rate - exemptionRate;
            Decimal price = FIProductNewMap.get(fAndIproductRec.Id).Price__c;
            
            fAndIproductRec.Price_When_Tax_Included__c = (price * (1 + fAndIproductRec.Sales_Tax_Percentage__c/100)).setScale(2, RoundingMode.HALF_UP);
            fAndIProductListToUpdate.add(fAndIproductRec);
        }
        
        if(individualTaxToInsert.size() > 0) {
       		insert individualTaxToInsert;
        }
        
        return fAndIProductListToUpdate;
    }
}