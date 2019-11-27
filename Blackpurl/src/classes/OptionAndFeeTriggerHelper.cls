/**
 * Author: Tarun Khandelwal
 * Since: Oct 21, 2016
 * Name: OptionAndFeeTriggerHelper
 * Description: Trigger executes on after insert event of Option & Fee object
**/
public with sharing class OptionAndFeeTriggerHelper {
    
    public static Boolean isForceStopTrigger = false;
    public static Boolean isRunningScript = false;
    public static List<Option_Fee__c> OptionAndFeeNewList = new List<Option_Fee__c>();
    public static List<Option_Fee__c> OptionAndFeeOldList = new List<Option_Fee__c>();
    public static Map<Id, Option_Fee__c> OptionAndFeeNewMap = new Map<Id, Option_Fee__c>();
    public static Map<Id, Option_Fee__c> OptionAndFeeOldMap = new Map<Id, Option_Fee__c>();
    
    public static Boolean isTriggerExecute = false;
    public static Boolean isCalculatePriceLevel = true;
    public static Boolean isCalculateTotalOnDeal = true;
    public static Boolean isCustomerPLUpdate = false;
    
    public static void beforeInsertCalculation() {
    	if(isTriggerExecute) {
    		return;
    	}
    	priceLevelCalculation();
    }
    
    public static void beforeUpdateCalculation() {
    	if(isCalculatePriceLevel && !isTriggerExecute) {
    		priceLevelCalculation();
    	}
    }
    
    public static void afterInsertCalculation() {
    	salesTaxCalculation();
    	//updateTotalOnDeal(OptionAndFeeNewList);
    	//updateRideawayPricing(OptionAndFeeNewList);
    }
    
    public static void afterUpdateCalculation() {
    	if(isCustomerPLUpdate) {
    		salesTaxCalculation();
    		isCustomerPLUpdate = false;
    	}
    	updateTotalOnDeal(OptionAndFeeNewList);
    	updateRideawayPricing(OptionAndFeeNewList);
    }
    
    public static void afterDeleteCalculation() {
    	updateTotalOnDeal(OptionAndFeeOldList);
    	updateRideawayPricing(OptionAndFeeOldList);
    }
        
    public static void updateTotalOnDeal(List<Option_Fee__c> optionAndFeeList) {
    	Set<String> dealIdSet = new Set<String>();
    	for(Option_Fee__c optionAndFeeRec : optionAndFeeList) {
    		dealIdSet.add(optionAndFeeRec.Deal__c);
    	}
    	updateDealTotal(dealIdSet);
    }
    
    private static void priceLevelCalculation() {
    	Set<Id> partIdSet = new Set<Id>();
        
        Set<Id> dealItemIdSet = new Set<Id>();
        Set<Id> feeIdSet = new Set<Id>();
        Set<Id> labourIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        for(Option_Fee__c optionFeeRec : OptionAndFeeNewList) {
        	/*if(optionFeeRec.Deal_Kit_Header__c != null) {
                continue;
            }*/
            dealItemIdSet.add(optionFeeRec.Deal_Item__c); 
            if(optionFeeRec.Part__c != null) {
            	partIdSet.add(optionFeeRec.Part__c);
            } else if(optionFeeRec.Fee__c != null) {
            	feeIdSet.add(optionFeeRec.Fee__c);
            } else if(optionFeeRec.Labour_Code__c != null) {
            	labourIdSet.add(optionFeeRec.Labour_Code__c);
            } else if(optionFeeRec.Product__c != null) {
            	productIdSet.add(optionFeeRec.Product__c);
            }
        }
        
        partIdSet.remove(null);
        feeIdSet.remove(null);
        dealItemIdSet.remove(null);
        labourIdSet.remove(null);
        productIdSet.remove(null);
        
        Map<Id, Part__c> partIdToPartRecordMap = new Map<Id, Part__c>();
        if(partIdSet.size() > 0) {
        	if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	        partIdToPartRecordMap = new Map<Id, Part__c>([select Id, Average_Cost__c, Last_Cost__c, MSRP__c, Retail_Price__c, 
        																Part_Number__c, Description__c, 
        																AvailableParts__c, Qty_Committed__c, Applicable_Tax__c, Applicable_Tax__r.Rate__c
	        																from Part__c where Id IN : partIdSet]);
        }
    	    	        
        Map<Id, Fee__c> feeIdToFeeRecordMap = new Map<Id, Fee__c>();
        if(feeIdSet.size() > 0) {
        	if(AccessControl.ifObjectFieldIsAccessible('Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        	feeIdToFeeRecordMap = new Map<Id, Fee__c>([select Price__c, Taxable__c, Applicable_Tax__c, Applicable_Tax__r.Rate__c
        																from Fee__c where Id IN: feeIdSet]); 
        }
        
        Map<Id, Labour_Code__c> labourIdToLabourRecordMap = new Map<Id, Labour_Code__c>();
        if(labourIdSet.size() > 0) {
        	if(AccessControl.ifObjectFieldIsAccessible('Labour_Code__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            labourIdToLabourRecordMap = new Map<Id, Labour_Code__c>([select Rate__c, Taxable__c, Applicable_Tax__c, Applicable_Tax__r.Rate__c,
                                                                        Fixed_Rate__c
                                                                        from Labour_Code__c where Id IN: labourIdSet]);
    	}
    
    	Map<Id, Product__c> productIdToProductRecordMap = new Map<Id, Product__c>();
        if(productIdSet.size() > 0) {
        	if(AccessControl.ifObjectFieldIsAccessible('Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            productIdToProductRecordMap = new Map<Id, Product__c>([select Price__c, Taxable__c, Applicable_Tax__c, Applicable_Tax__r.Rate__c
        																from Product__c where Id IN: productIdSet]); 
        }
        
    	Map<Id, Deal_Item__c> dealItemIdTodealItemRecMap = new Map<Id, Deal_Item__c>();
        if(dealItemIdSet.size() > 0) {
        	if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        	dealItemIdTodealItemRecMap = new Map<Id, Deal_Item__c>([select Discount_Markup_From_Prive_Level__c, Part_Price_Base_From_Price_Level__c,
        																					Labour_Rate_From_Price_Level__c
                                                                                            from Deal_Item__c Where Id IN : dealItemIdSet]);
        }
        
        Decimal discount;
        String partPriceBase; 
        Decimal laborRate;                                                                                  
		for(Option_Fee__c optionFeeRec : OptionAndFeeNewList) {
            if(optionFeeRec.Is_Fixed_Price_Kit__c || optionFeeRec.Is_Fixed_Price__c) {
                continue;
            }
        	discount = (dealItemIdTodealItemRecMap.get(optionFeeRec.Deal_Item__c).Discount_Markup_From_Prive_Level__c == null) ? 0 : dealItemIdTodealItemRecMap.get(optionFeeRec.Deal_Item__c).Discount_Markup_From_Prive_Level__c;
        	partPriceBase = dealItemIdTodealItemRecMap.get(optionFeeRec.Deal_Item__c).Part_Price_Base_From_Price_Level__c;
        	laborRate = (dealItemIdTodealItemRecMap.get(optionFeeRec.Deal_Item__c).Labour_Rate_From_Price_Level__c == null) ? 0 : dealItemIdTodealItemRecMap.get(optionFeeRec.Deal_Item__c).Labour_Rate_From_Price_Level__c;
        	
            priceLevelCalculation(partPriceBase, discount, optionFeeRec, partIdToPartRecordMap, feeIdToFeeRecordMap, labourIdToLabourRecordMap, productIdToProductRecordMap, laborRate);
        }                                                                                            	
    }
    
    private static void priceLevelCalculation(String priceLevel_baseValueField, Decimal priceLevel_discountMarkup, Option_Fee__c optionFeeRec, 
    											Map<Id, Part__c> partIdToPartRecordMap, Map<Id, Fee__c> feeIdToFeeRecordMap,
    											Map<Id, Labour_Code__c> labourIdToLabourRecordMap, Map<Id, Product__c> productIdToProductRecordMap, Decimal laborRate) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        if(optionFeeRec.Part__c != null) {
	        String pricingField = TaxCalculation.getPricingFieldByPLBaseValueField(priceLevel_baseValueField);
	        
	        if(partIdToPartRecordMap.get(optionFeeRec.Part__c).get(pricingField) == null) {
	            partIdToPartRecordMap.get(optionFeeRec.Part__c).put(pricingField, 0);
	            optionFeeRec.Retail__c = 0;
	        } else {
	            Decimal baseValue = Decimal.valueOf(String.valueOf(partIdToPartRecordMap.get(optionFeeRec.Part__c).get(pricingField)));
	            
                if(optionFeeRec.Deal_Kit_Header__c != null) {
                    optionFeeRec.Retail__c = baseValue;
                } else {
		            if(isTaxIncludingPricing && !TaxCalculation.COST_FIELDS_SET.contains(pricingField) && partIdToPartRecordMap.get(optionFeeRec.Part__c).Applicable_Tax__c != null) {
		                Decimal appTaxRate = partIdToPartRecordMap.get(optionFeeRec.Part__c).Applicable_Tax__r.Rate__c;
		                if(appTaxRate == -100 || appTaxRate == null) { // To handle divide by zero error
		                    appTaxRate = 0;
		                }
		                Decimal preTaxPricing = baseValue / (1 + (appTaxRate / 100));
	                    optionFeeRec.Retail__c = preTaxPricing + (preTaxPricing * priceLevel_discountMarkup / 100);
		            } else {
                        optionFeeRec.Retail__c = baseValue + (baseValue * priceLevel_discountMarkup / 100);
		            }
	            }
	        }
        
        } else if(optionFeeRec.Fee__c != null) {
        	Decimal feePrice;
        	if(optionFeeRec.Is_Environmental_Fee__c || optionFeeRec.Is_Linked_Fee__c) { 
        		 if(isTaxIncludingPricing) {
        		 	feePrice = optionFeeRec.Price_When_Tax_Included__c;
        		 } else {
        		feePrice = optionFeeRec.Price__c;
        		 }
        	} else {
        		feePrice = feeIdToFeeRecordMap.get(optionFeeRec.Fee__c).Price__c;
        	}
        	
        	if(isTaxIncludingPricing) {
        		Decimal appTaxRate = feeIdToFeeRecordMap.get(optionFeeRec.Fee__c).Applicable_Tax__r.Rate__c;
                if(appTaxRate == -100 || appTaxRate == null) { // To handle divide by zero error
                    appTaxRate = 0;
                }
                Decimal preTaxPricing = feePrice / (1 + (appTaxRate / 100));
                optionFeeRec.Retail__c = preTaxPricing;
        	} else {
        		optionFeeRec.Retail__c = feePrice;
        	}
        } else if(optionFeeRec.Labour_Code__c != null) {
        	if(labourIdToLabourRecordMap.get(optionFeeRec.Labour_Code__c).Fixed_Rate__c) {
                optionFeeRec.Retail__c = labourIdToLabourRecordMap.get(optionFeeRec.Labour_Code__c).Rate__c;
            } else {
            	if(laborRate == null || laborRate == 0) {
            		optionFeeRec.Retail__c = labourIdToLabourRecordMap.get(optionFeeRec.Labour_Code__c).Rate__c;
            	} else {
                	optionFeeRec.Retail__c = laborRate;
            	}
            }
            if(isTaxIncludingPricing) {
            	Decimal appTaxRate = labourIdToLabourRecordMap.get(optionFeeRec.Labour_Code__c).Applicable_Tax__r.Rate__c;
            	if(appTaxRate == -100 || appTaxRate == null) { // To handle divide by zero error
                    appTaxRate = 0;
        	} 
                Decimal preTaxPricing = optionFeeRec.Retail__c / (1 + (appTaxRate / 100));
                optionFeeRec.Retail__c = preTaxPricing;
            }
        } else if(optionFeeRec.Product__c != null) {
        	Decimal productPrice = productIdToProductRecordMap.get(optionFeeRec.Product__c).Price__c;
        	if(isTaxIncludingPricing) {
        		Decimal appTaxRate = productIdToProductRecordMap.get(optionFeeRec.Product__c).Applicable_Tax__r.Rate__c;
                if(appTaxRate == -100 || appTaxRate == null) { // To handle divide by zero error
                    appTaxRate = 0;
                }
                Decimal preTaxPricing = productPrice / (1 + (appTaxRate / 100));
                optionFeeRec.Retail__c = preTaxPricing;
        	} else {
        		optionFeeRec.Retail__c = productPrice;
        	}
        }

		optionFeeRec.Retail__c = (optionFeeRec.Retail__c != null) ? optionFeeRec.Retail__c.setScale(2, RoundingMode.HALF_UP) : 0;
        if((trigger.isInsert || isCustomerPLUpdate) && (optionFeeRec.Fee__c != null || optionFeeRec.Part__c != null || optionFeeRec.Labour_Code__c != null || optionFeeRec.Product__c != null)) {
            optionFeeRec.Price__c = optionFeeRec.Retail__c;
        }
    }
    
    public static void salesTaxCalculation() {
    	if(isTriggerExecute) {
    		return;
    	}
        isTriggerExecute = true;
        
        Set<String> dealIdSet = new Set<String>();
        // Tax Exemption List
        List<Option_Fee__c> optionAndFeeList = [SELECT Part__c, Part__r.Applicable_Tax__c, Part__r.Applicable_Tax__r.Rate__c, Deal_Kit_Header__c,
        												Fee__c, Fee__r.Applicable_Tax__c, Fee__r.Applicable_Tax__r.Rate__c,
        												Labour_Code__c, Labour_Code__r.Applicable_Tax__c, Labour_Code__r.Applicable_Tax__r.Rate__c,
        												Product__c, Product__r.Applicable_Tax__c, Product__r.Applicable_Tax__r.Rate__c, Price_When_Tax_Included__c,
        												Deal_Item__r.Deal__r.CO_Header__c, Deal_Item__r.Deal__r.CO_Header__r.Customer__c, Price__c, Deal_Item__r.Deal__c,
        												(Select Id from Individual_Taxes__r)  
    													FROM Option_Fee__c where Id IN: trigger.new AND Deal_Kit_Header__c = null];
    	
    	Set<Id> customerIdSet = new Set<Id>();
    	Set<Id> coHeaderIds = new Set<Id>();
    	
    	List<Individual_Tax__c> individualTaxList = new List<Individual_Tax__c>();
    	for(Option_Fee__c optionAndFeeRec : optionAndFeeList) {
    		if(optionAndFeeRec.Deal_Item__r.Deal__r.CO_Header__r.Customer__c != null && 
    			!customerIdSet.contains(optionAndFeeRec.Deal_Item__r.Deal__r.CO_Header__r.Customer__c)) {
    			customerIdSet.add(optionAndFeeRec.Deal_Item__r.Deal__r.CO_Header__r.Customer__c);
    			coHeaderIds.add(optionAndFeeRec.Deal_Item__r.Deal__r.CO_Header__c);
    		}
    		individualTaxList.addAll(optionAndFeeRec.Individual_Taxes__r);
    		dealIdSet.add(optionAndFeeRec.Deal_Item__r.Deal__c);
    	}
    	
    	if(isCustomerPLUpdate && individualTaxList.size() > 0) {
        	if(AccessControl.ifObjectIsDeletable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); } 		
    		delete individualTaxList;
    	}
    	
    	// Get list of Tax Exemptions for given coHeader ids
        Map<Id, Set<Id>> coHeaderIdToSalesTaxItemIdsMap = TaxCalculation.getCOHeaderIdToTaxExemptionsIds(coHeaderIds);
        
        // Entity Tax Rate
        List<Id> salesTaxIdList = new List<Id>();
        for(Option_Fee__c optionAndFeeRec : optionAndFeeList) {
            if(optionAndFeeRec.Part__r.Applicable_Tax__c != null) {
                salesTaxIdList.add(optionAndFeeRec.Part__r.Applicable_Tax__c);
            } else if(optionAndFeeRec.Fee__r.Applicable_Tax__c != null) {
                salesTaxIdList.add(optionAndFeeRec.Fee__r.Applicable_Tax__c);
            }             
            else if(optionAndFeeRec.Labour_Code__r.Applicable_Tax__c != null) {
                salesTaxIdList.add(optionAndFeeRec.Labour_Code__r.Applicable_Tax__c);
            } else if(optionAndFeeRec.Product__r.Applicable_Tax__c != null) {
                salesTaxIdList.add(optionAndFeeRec.Product__r.Applicable_Tax__c);
        	}
        }
        List<Option_Fee__c> optionAndFeeListToUpdate = new List<Option_Fee__c>();
        optionAndFeeListToUpdate.addAll(calculateSalesTax(salesTaxIdList, coHeaderIdToSalesTaxItemIdsMap, optionAndFeeList));
        
        if(optionAndFeeListToUpdate.size() > 0) {
        	if(AccessControl.ifObjectFieldIsUpdateable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update optionAndFeeListToUpdate;
        }
    }
    
    private static List<Option_Fee__c> calculateSalesTax(List<Id> salesTaxIdList, Map<Id, Set<Id>> coHeaderIdToSalesTaxItemIdsMap, List<Option_Fee__c> optionAndFeeList) {
        if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
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
        
        List<Sobject> optionAndFeeListToUpdate = new List<Sobject>();
        List<Individual_Tax__c> individualTaxToInsert = new List<Individual_Tax__c>();
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        for(Option_Fee__c optionAndFeeRec : optionAndFeeList) {
            Id salesTaxId;
            if(optionAndFeeRec.Part__r.Applicable_Tax__c != null) {
                salesTaxId = optionAndFeeRec.Part__r.Applicable_Tax__c;
            } else if(optionAndFeeRec.Fee__r.Applicable_Tax__c != null) {
                salesTaxId = optionAndFeeRec.Fee__r.Applicable_Tax__c;
            } else if(optionAndFeeRec.Labour_Code__r.Applicable_Tax__c != null) {
                salesTaxId = optionAndFeeRec.Labour_Code__r.Applicable_Tax__c;
            } else if(optionAndFeeRec.Product__r.Applicable_Tax__c != null) {
                salesTaxId = optionAndFeeRec.Product__r.Applicable_Tax__c;
            } 
            if(salesTaxId == null) {
            	if(isTaxIncludingPricing && optionAndFeeRec.Price__c != null) {
            		optionAndFeeRec.Price_When_Tax_Included__c = optionAndFeeRec.Price__c;
            		optionAndFeeListToUpdate.add(optionAndFeeRec);
            	}
            	continue;
            }  
            optionAndFeeRec.Applicable_Tax__c = salesTaxId;
            
            Decimal exemptionRate = 0;
            if(salesTaxIdToAppTaxRecordsMap.containsKey(salesTaxId)) {
                for(Applicable_Taxes__c appTax : salesTaxIdToAppTaxRecordsMap.get(salesTaxId)) {
                    if(optionAndFeeRec.Deal_Item__r.Deal__r.CO_Header__r.Customer__c != null && 
                    	coHeaderIdToSalesTaxItemIdsMap.get(optionAndFeeRec.Deal_Item__r.Deal__r.CO_Header__c).contains(appTax.Sales_Tax_Item__c)) {
                        exemptionRate += appTax.Sales_Tax_Item__r.Rate__c;
                    
                    } else { 
                    	Individual_Tax__c individualTaxRec = new Individual_Tax__c();
                    	individualTaxRec.Option_Fee__c = optionAndFeeRec.Id;
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
            optionAndFeeRec.Sales_Tax_Percentage__c = rate - exemptionRate;
            Decimal price = OptionAndFeeNewMap.get(optionAndFeeRec.Id).Price__c;
            optionAndFeeRec.Price_When_Tax_Included__c = (price * (1 + optionAndFeeRec.Sales_Tax_Percentage__c/100)).setScale(2, RoundingMode.HALF_UP);
            optionAndFeeListToUpdate.add(optionAndFeeRec);
        }
        if(individualTaxToInsert.size() > 0) {
       		insert individualTaxToInsert;
        }
        return optionAndFeeListToUpdate;
    }
    
    public static void updateDealTotal(Set<String> dealIdSet) {
    	if(dealIdSet.size() == 0) { 
    		return;
    	}
    	Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
    	
    	List<Deal__c> dealList = [Select Total__c, Type__c, Deal_Tax_Total__c, CO_Header__c, CO_Header__r.Deal_Total__c, F_I_Total__c, F_I_Tax_Total__c, Sales_Tax_Total__c, 
    									(Select Price__c, Qty__c, Part__c, Labour_Code__c, Fee__c, Product__c, Product__r.Type__c, Price_When_Tax_Included__c, Sales_Tax_Percentage__c,
    									Deal_Item__c from Options_Fees__r), 
    									(Select Type__c, Agreed_Value__c, Actual_Cash_Value__c, Default_Unit_Sales_Tax_Percentage__c, Stamp_Duty_Total__c, Lien_Payout__c from Deal_Items__r),
    									(select Taxable_Amount_for_Section_Header__c, Sales_Tax_Item_Name__c, Tax_Rate__c from Individual_Taxes__r), 
    									(Select Id, F_I_Product_Tax_Total__c, F_I_Total__c from Deal_Finances__r)
    								from Deal__c where Id IN: dealIdSet];
    	Map<String, List<Deal_Unit_Price_Cost__c>> dealIdToDealUnitPriceCostListMap = getDealIdToDealUnitPriceCostListMap(dealList);							
		populateTotalsOnDeal(dealList, dealIdToDealUnitPriceCostListMap);
    }
    
    private static Map<String, List<Deal_Unit_Price_Cost__c>> getDealIdToDealUnitPriceCostListMap(List<Deal__c> dealList) {
    	Set<String> dealItemIdSet = new Set<String>();
    	for(Deal__c dealRec : dealList) {
    		for(Deal_Item__c dealItemRec : dealRec.Deal_Items__r) {
    			if(dealItemRec.Type__c == 'Unit') {
    				dealItemIdSet.add(dealItemRec.Id);
    			}
			}
    	}
		
		List<Deal_Unit_Price_Cost__c> dealUnitPriceAndCostList = 
				[Select Deal_Item__r.Deal__c, Total_Price__c, Type__c, Deal_Item__c, Tax_Amount__c, Price_When_Tax_Included__c, Qty__c, Price__c, Sales_Tax_Percentage__c,	
				    (select Sales_Tax_Item_Name__c, Taxable_Amount__c, Tax_Rate__c, Form_Label__c
							from Individual_Taxes__r) from Deal_Unit_Price_Cost__c where Deal_Item__c IN: dealItemIdSet];
							
    	Map<String, List<Deal_Unit_Price_Cost__c>> dealIdToDealUnitPriceCostListMap = new Map<String, List<Deal_Unit_Price_Cost__c>>();
		for(Deal_Unit_Price_Cost__c dealUnitPriceCostRec : dealUnitPriceAndCostList) {
			if(dealUnitPriceCostRec.Deal_Item__r.Deal__c != null) {
	    		if(!dealIdToDealUnitPriceCostListMap.containsKey(dealUnitPriceCostRec.Deal_Item__r.Deal__c)) {
	    			dealIdToDealUnitPriceCostListMap.put(dealUnitPriceCostRec.Deal_Item__r.Deal__c, new List<Deal_Unit_Price_Cost__c>());
	    		}
				dealIdToDealUnitPriceCostListMap.get(dealUnitPriceCostRec.Deal_Item__r.Deal__c).add(dealUnitPriceCostRec);
			}
		}
		return dealIdToDealUnitPriceCostListMap;
    }
    
    private static void populateTotalsOnDeal(List<Deal__c> dealList, Map<String, List<Deal_Unit_Price_Cost__c>> dealIdToDealUnitPriceCostListMap) {
    	if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	if(AccessControl.ifObjectFieldIsUpdateable('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	List<Deal__c> dealListToUpdate = new List<Deal__c>();
		Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
		
		Map<String, List<Individual_Tax__c>> dealIdToRelatedIndividualTaxListMap = new Map<String, List<Individual_Tax__c>>();
		if(!isTaxIncludingPricing) {
    		List<Individual_Tax__c> individualTaxList = [select Sales_Tax_Item_Name__c, Taxable_Amount__c, Tax_Rate__c, Option_Fee__r.Deal_Item__c, Option_Fee__r.Deal__c, 
    														Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c, Deal_Unit_Price_Cost__r.Deal_Item__c, Deal_Item__r.Deal__c, 
	    													Form_Label__c, Applicable_Tax__c, List_Tax_items_on_forms__c 
	    												from Individual_Tax__c
	    												where  Option_Fee__r.Deal__c IN: dealList
	    													OR Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c IN: dealList
	    													OR (Deal_Item__r.Deal__c IN: dealList AND Deal_Item__r.Type__c = 'Trade In')];
	    	for(Individual_Tax__c individualTaxRec : individualTaxList) {
	    		String dealId;
	    		if(String.isNotBlank(individualTaxRec.Option_Fee__c)) {
	    			dealId = individualTaxRec.Option_Fee__r.Deal__c;
	    		} else if(String.isNotBlank(individualTaxRec.Deal_Unit_Price_Cost__c)) {
	    			dealId = individualTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c;
	    		} else if(String.isNotBlank(individualTaxRec.Deal_Item__c)) {
	    			dealId = individualTaxRec.Deal_Item__r.Deal__c;
	    		}
	    		if(!dealIdToRelatedIndividualTaxListMap.containsKey(dealId)) {
	    			dealIdToRelatedIndividualTaxListMap.put(dealId, new List<Individual_Tax__c>{individualTaxRec});
	    		} else {
	    			dealIdToRelatedIndividualTaxListMap.get(dealId).add(individualTaxRec);
	    		}
	    		
	    	}
		}
        
        Map<String, Deal_Item__c> dealItemIdToRecMap = new Map<String, Deal_Item__c>();
        for(Deal__c dealRec : dealList) {
    		//Decimal total = 0;
    		dealRec.Sales_Tax_Total__c = 0;
    		Decimal totalSalesTax = 0;
    		Decimal partTotal = 0;
    		Decimal laborTotal = 0;
    		Decimal feeTotal = 0;
    		Decimal warrantyProductTotal = 0;
    		Decimal subletTotal = 0;
    		Decimal otherProductTotal = 0;
    		Decimal productTotal = 0;
    		Decimal unitTotal = 0;
            Decimal fAndITotal = 0;
    		Decimal fAndITaxTotal = 0;
    		Decimal stampDutyTotal = 0;
    		Decimal tradeInTotal = 0;
    		Decimal lienPayoutTotal = 0;
    		
    		//Pre Tax Deal Totals
    		Decimal preTaxUnitTotal = 0; 
    		Decimal preTaxTradeInTotal = 0;
    		Decimal preTaxPartTotal = 0;
    		Decimal preTaxLaborTotal = 0;
    		Decimal preTaxOtherProductTotal = 0;
    		Decimal preTaxFeeTotal = 0;
    		
    		for(Option_Fee__c optionFeeRec : dealRec.Options_Fees__r) {
    			if(optionFeeRec.Deal_Item__c != null && !dealItemIdToRecMap.containsKey(optionFeeRec.Deal_Item__c)) {
    				Deal_Item__c dealItemRec = new Deal_Item__c(Id = optionFeeRec.Deal_Item__c, Part_Total__c = 0, Fee_Total__c = 0, Labour_Total__c = 0, 
    					Warranty_Product_Total__c = 0, Sublet_Total__c = 0, Other_Product_Total__c = 0, Base_Price__c = 0, Factory_Option_Total__c = 0, Dealer_Option_Total__c = 0);
    				dealItemIdToRecMap.put(optionFeeRec.Deal_Item__c, dealItemRec);
    			}
    			optionFeeRec.Price__c = (optionFeeRec.Price__c != null) ? optionFeeRec.Price__c : 0;
    			optionFeeRec.Price_When_Tax_Included__c = (optionFeeRec.Price_When_Tax_Included__c != null) ? optionFeeRec.Price_When_Tax_Included__c : 0;
    			optionFeeRec.Qty__c = (optionFeeRec.Qty__c != null) ? optionFeeRec.Qty__c : 0;
    			optionFeeRec.Sales_Tax_Percentage__c = (optionFeeRec.Sales_Tax_Percentage__c != null) ? optionFeeRec.Sales_Tax_Percentage__c : 0;
    			
    			if(!isTaxIncludingPricing) {
		    		if(optionFeeRec.Part__c != null) {
		    			partTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			preTaxPartTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			dealItemIdToRecMap.get(optionFeeRec.Deal_Item__c).Part_Total__c += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    		} else if(optionFeeRec.Labour_Code__c != null) {
		    			laborTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			preTaxLaborTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			dealItemIdToRecMap.get(optionFeeRec.Deal_Item__c).Labour_Total__c += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    		} else if(optionFeeRec.Fee__c != null) {
		    			feeTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			preTaxFeeTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			dealItemIdToRecMap.get(optionFeeRec.Deal_Item__c).Fee_Total__c += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    		} else if(optionFeeRec.Product__c != null) {
		    			if(optionFeeRec.Product__r.Type__c == Constants.WARRANTY_PLAN) {
		    				warrantyProductTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    				dealItemIdToRecMap.get(optionFeeRec.Deal_Item__c).Warranty_Product_Total__c += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			} else if(optionFeeRec.Product__r.Type__c == Constants.SUBLET) {
		    				subletTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    				dealItemIdToRecMap.get(optionFeeRec.Deal_Item__c).Sublet_Total__c += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			} else {
		    				otherProductTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    				dealItemIdToRecMap.get(optionFeeRec.Deal_Item__c).Other_Product_Total__c += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			}
		    			//It will include all 4 type of products for home search
		    			preTaxOtherProductTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			productTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    		} 
    				totalSalesTax += (optionFeeRec.Qty__c * optionFeeRec.Price__c * optionFeeRec.Sales_Tax_Percentage__c)/100;
    			} else {
    				if(optionFeeRec.Part__c != null) {
		    			partTotal += (optionFeeRec.Qty__c * optionFeeRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
		    			preTaxPartTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			dealItemIdToRecMap.get(optionFeeRec.Deal_Item__c).Part_Total__c += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);

		    		} else if(optionFeeRec.Labour_Code__c != null) {
		    			laborTotal += (optionFeeRec.Qty__c * optionFeeRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
		    			preTaxLaborTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			dealItemIdToRecMap.get(optionFeeRec.Deal_Item__c).Labour_Total__c += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			
		    		} else if(optionFeeRec.Fee__c != null) {
		    			feeTotal += (optionFeeRec.Qty__c * optionFeeRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
		    			preTaxFeeTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			dealItemIdToRecMap.get(optionFeeRec.Deal_Item__c).Fee_Total__c += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			
		    		} else if(optionFeeRec.Product__c != null) {
		    			if(optionFeeRec.Product__r.Type__c == Constants.WARRANTY_PLAN) {
		    				warrantyProductTotal += (optionFeeRec.Qty__c * optionFeeRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
		    				dealItemIdToRecMap.get(optionFeeRec.Deal_Item__c).Warranty_Product_Total__c += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			} else if(optionFeeRec.Product__r.Type__c == Constants.SUBLET) {
		    				subletTotal += (optionFeeRec.Qty__c * optionFeeRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
		    				dealItemIdToRecMap.get(optionFeeRec.Deal_Item__c).Sublet_Total__c += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			}  else {
		    				otherProductTotal += (optionFeeRec.Qty__c * optionFeeRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
		    				dealItemIdToRecMap.get(optionFeeRec.Deal_Item__c).Other_Product_Total__c += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			}
		    			//It will include all 4 type of products for home search
		    			preTaxOtherProductTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
		    			productTotal += (optionFeeRec.Qty__c * optionFeeRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
		    		} 
	    			dealRec.Sales_Tax_Total__c += (optionFeeRec.Qty__c * optionFeeRec.Price__c * optionFeeRec.Sales_Tax_Percentage__c)/100;
    			}
    		}
    		
    		if(dealIdToDealUnitPriceCostListMap.containsKey(dealRec.Id)) {
    			for(Deal_Unit_Price_Cost__c dupcRec : dealIdToDealUnitPriceCostListMap.get(dealRec.Id)) {
    				if(dupcRec.Deal_Item__c != null && !dealItemIdToRecMap.containsKey(dupcRec.Deal_Item__c)) {
	    				Deal_Item__c dealItemRec = new Deal_Item__c(Id = dupcRec.Deal_Item__c, Base_Price__c = 0, Factory_Option_Total__c = 0, 
	    															Dealer_Option_Total__c = 0);
	    				dealItemIdToRecMap.put(dupcRec.Deal_Item__c, dealItemRec);
	    			}
	    			
    				dupcRec.Price__c = (dupcRec.Price__c != null) ? dupcRec.Price__c : 0;
	    			dupcRec.Price_When_Tax_Included__c = (dupcRec.Price_When_Tax_Included__c != null) ? dupcRec.Price_When_Tax_Included__c : 0;
	    			dupcRec.Qty__c = (dupcRec.Qty__c != null) ? dupcRec.Qty__c : 0;
	    			dupcRec.Sales_Tax_Percentage__c = (dupcRec.Sales_Tax_Percentage__c != null) ? dupcRec.Sales_Tax_Percentage__c : 0;
    				
    				Decimal preTaxTotalPrice = (((dupcRec.Price__c != null) ? dupcRec.Price__c : 0) * ((dupcRec.Qty__c != null) ? dupcRec.Qty__c : 0)).setScale(2, RoundingMode.HALF_UP);
	    			
                    if(dupcRec.Type__c == 'Base') {
	    				dealItemIdToRecMap.get(dupcRec.Deal_Item__c).Base_Price__c += preTaxTotalPrice;
	    			} else if(dupcRec.Type__c == 'Factory') {
	    				dealItemIdToRecMap.get(dupcRec.Deal_Item__c).Factory_Option_Total__c += preTaxTotalPrice;
	    			} else if(dupcRec.Type__c == 'Dealer') {
	    				dealItemIdToRecMap.get(dupcRec.Deal_Item__c).Dealer_Option_Total__c += preTaxTotalPrice;
	    			}
	    			
    				if(!isTaxIncludingPricing) {
	    				unitTotal += (((dupcRec.Price__c != null) ? dupcRec.Price__c : 0) * ((dupcRec.Qty__c != null) ? dupcRec.Qty__c : 0)).setScale(2, RoundingMode.HALF_UP);
    					totalSalesTax += (dupcRec.Qty__c * dupcRec.Price__c * dupcRec.Sales_Tax_Percentage__c)/100;
    				} else {
    					unitTotal += (((dupcRec.Price_When_Tax_Included__c != null) ? dupcRec.Price_When_Tax_Included__c : ((dupcRec.Price__c * (1 + dupcRec.Sales_Tax_Percentage__c/100))).setScale(2, RoundingMode.HALF_UP)) * 
	    							((dupcRec.Qty__c != null) ? dupcRec.Qty__c : 0)).setScale(2, RoundingMode.HALF_UP);
		    			dealRec.Sales_Tax_Total__c += (dupcRec.Qty__c * dupcRec.Price__c * dupcRec.Sales_Tax_Percentage__c)/100;
    				}
    				preTaxUnitTotal += (((dupcRec.Price__c != null) ? dupcRec.Price__c : 0) * ((dupcRec.Qty__c != null) ? dupcRec.Qty__c : 0)).setScale(2, RoundingMode.HALF_UP);
    			}
    		}
    		
    		for(Deal_Item__c dealItemRec : dealRec.Deal_Items__r) {
    			if(dealItemRec.Type__c == 'Trade In') {
    				dealItemRec.Agreed_Value__c = (dealItemRec.Agreed_Value__c != null) ? dealItemRec.Agreed_Value__c.setScale(2, RoundingMode.HALF_UP) : 0;
    				dealItemRec.Actual_Cash_Value__c = (dealItemRec.Actual_Cash_Value__c != null) ? dealItemRec.Actual_Cash_Value__c.setScale(2, RoundingMode.HALF_UP) : 0;
    				dealItemRec.Default_Unit_Sales_Tax_Percentage__c = (dealItemRec.Default_Unit_Sales_Tax_Percentage__c != null) ? dealItemRec.Default_Unit_Sales_Tax_Percentage__c : 0;
    				tradeInTotal += dealItemRec.Agreed_Value__c;
    				
                    if(!isTaxIncludingPricing) {
    					preTaxTradeInTotal -= dealItemRec.Agreed_Value__c;
    					totalSalesTax -= ((dealItemRec.Agreed_Value__c * dealItemRec.Default_Unit_Sales_Tax_Percentage__c)/100).setScale(2, RoundingMode.HALF_UP);
    				} else {
    					preTaxTradeInTotal -= (dealItemRec.Agreed_Value__c / (1 + dealItemRec.Default_Unit_Sales_Tax_Percentage__c/100)).setScale(2, RoundingMode.HALF_UP);
    					dealRec.Sales_Tax_Total__c -= (dealItemRec.Agreed_Value__c - (dealItemRec.Agreed_Value__c / (1 + dealItemRec.Default_Unit_Sales_Tax_Percentage__c/100))).setScale(2, RoundingMode.HALF_UP);
    				}
                    
    				lienPayoutTotal += (dealItemRec.Lien_Payout__c != null) ? dealItemRec.Lien_Payout__c : 0;
    			} else {
    				stampDutyTotal += (dealItemRec.Stamp_Duty_Total__c != null) ? dealItemRec.Stamp_Duty_Total__c.setScale(2, RoundingMode.HALF_UP) : 0;
    			}
    		}
    		
    		for(Deal_Finance__c dealFinanceRec : dealRec.Deal_Finances__r) {
				fAndITotal += (dealFinanceRec.F_I_Total__c != null) ? dealFinanceRec.F_I_Total__c.setScale(2, RoundingMode.HALF_UP) : 0;
				fAndITaxTotal += (dealFinanceRec.F_I_Product_Tax_Total__c != null) ? dealFinanceRec.F_I_Product_Tax_Total__c.setScale(2, RoundingMode.HALF_UP) : 0;
    		}
    		
    		if(!isRunningScript && !isTaxIncludingPricing && dealIdToRelatedIndividualTaxListMap.containsKey(dealRec.Id)) {
	    		totalSalesTax = 0;
		    	Map<String, Decimal> salesTaxNameToTaxValue = TaxCalculation.getTaxAmountWithFormLabel(dealIdToRelatedIndividualTaxListMap.get(dealRec.Id));
		    	
		    	for(String taxName : salesTaxNameToTaxValue.keySet()) {
	                totalSalesTax += salesTaxNameToTaxValue.get(taxName); 
	            }
			}
		
    		dealRec.Deal_Tax_Total__c = (isRunningScript ? dealRec.Deal_Tax_Total__c : totalSalesTax);
    		dealRec.Sales_Tax_Total__c = ((isTaxIncludingPricing ? (dealRec.Sales_Tax_Total__c) : dealRec.Deal_Tax_Total__c) + fAndITaxTotal).setScale(2, RoundingMode.HALF_UP);
    		dealRec.Fee_Total__c = feeTotal.setScale(2, RoundingMode.HALF_UP);
    		dealRec.Labour_Total__c = laborTotal.setScale(2, RoundingMode.HALF_UP);
    		dealRec.Part_Total__c = partTotal.setScale(2, RoundingMode.HALF_UP);
    		dealRec.Product_Total__c = productTotal.setScale(2, RoundingMode.HALF_UP);
    		dealRec.Warranty_Product_Total__c = warrantyProductTotal.setScale(2, RoundingMode.HALF_UP);
    		dealRec.Sublet_Total__c = subletTotal.setScale(2, RoundingMode.HALF_UP);
    		dealRec.Other_Product_Total__c = otherProductTotal.setScale(2, RoundingMode.HALF_UP);
    		dealRec.Unit_Price_And_Cost_Total__c = unitTotal.setScale(2, RoundingMode.HALF_UP);
    		dealRec.Trade_In_Total__c = -tradeInTotal.setScale(2, RoundingMode.HALF_UP);
    		dealRec.Stamp_Duty_Total__c = stampDutyTotal.setScale(2, RoundingMode.HALF_UP);
            dealRec.F_I_Total__c = fAndITotal.setScale(2, RoundingMode.HALF_UP);
            dealRec.F_I_Tax_Total__c = fAndITaxTotal.setScale(2, RoundingMode.HALF_UP);
            dealRec.Lien_Payout_Total__c = lienPayoutTotal.setScale(2, RoundingMode.HALF_UP);
            
            // Pre Tax Deal totals
            dealRec.Pre_Tax_Unit_Price_And_Cost_Total__c = preTaxUnitTotal.setScale(2, RoundingMode.HALF_UP);
            dealRec.Pre_Tax_Trade_In_Total__c = preTaxTradeInTotal.setScale(2, RoundingMode.HALF_UP);
            dealRec.Pre_Tax_Part_Total__c = preTaxPartTotal.setScale(2, RoundingMode.HALF_UP);
            dealRec.Pre_Tax_Labour_Total__c = preTaxLaborTotal.setScale(2, RoundingMode.HALF_UP);
            dealRec.Pre_Tax_Other_Product_Total__c = preTaxOtherProductTotal.setScale(2, RoundingMode.HALF_UP);
            dealRec.Pre_Tax_Fee_Total__c = preTaxFeeTotal.setScale(2, RoundingMode.HALF_UP);
            
    		dealListToUpdate.add(dealRec);
    	}
    	if(dealListToUpdate.size() > 0) {
    		update dealListToUpdate;
    		
    		if(dealItemIdToRecMap.size() > 0) {
    			DealItemTriggerHelper.isForceStopTrigger = true;
	    		update dealItemIdToRecMap.values();
	    		DealItemTriggerHelper.isForceStopTrigger = false;
	    	}
    	}
    	if(isRunningScript) return;
    	List<CO_Header__c> coHeaderListToUpdate = new List<CO_Header__c>();
    	Decimal subtotal = 0;
    	for(Deal__c dealRec : dealListToUpdate) {
    		// Update totals on CO Header
    		subtotal = dealRec.Fee_Total__c + dealRec.Labour_Total__c + dealRec.Part_Total__c + dealRec.Product_Total__c 
    									+ dealRec.Unit_Price_And_Cost_Total__c + dealRec.Trade_In_Total__c + dealRec.Stamp_Duty_Total__c + dealRec.Lien_Payout_Total__c;
    									
    		CO_Header__c coHeaderRec = new CO_Header__c(Id = dealRec.CO_Header__c, Deal_Subtotal__c = subTotal);
    		coHeaderRec.Deal_Total__c = subTotal.setScale(2, RoundingMode.HALF_UP);
    		
    		
    		if(!isTaxIncludingPricing) {
				coHeaderRec.Deal_Total__c += dealRec.Deal_Tax_Total__c.setScale(2, RoundingMode.HALF_UP);
    			if(dealRec.Type__c == 'Financed') {
	    			coHeaderRec.Deal_Subtotal__c += (dealRec.F_I_Total__c);
    			 	coHeaderRec.Deal_Total__c += (dealRec.F_I_Total__c + dealRec.F_I_Tax_Total__c);
	    		}
    		} else if(dealRec.Type__c == 'Financed') {
    			coHeaderRec.Deal_Subtotal__c += (dealRec.F_I_Total__c + dealRec.F_I_Tax_Total__c);
    			coHeaderRec.Deal_Total__c += (dealRec.F_I_Total__c + dealRec.F_I_Tax_Total__c);
			 	
    		}
    		
    		//coHeaderRec.Deal_Tax_Amount__c = dealRec.Deal_Tax_Total__c;
    		
    		
    		CO_Header__c tempCOHeaderRec = TaxCalculation.populateOrderTotal(dealRec.CO_Header__c, false);
    		coHeaderRec.Invoiced_Amount__c = tempCOHeaderRec.Invoiced_Amount__c;
	    	coHeaderRec.Uninvoiced_Amount__c = tempCOHeaderRec.Uninvoiced_Amount__c;
    		coHeaderListToUpdate.add(coHeaderRec);
    	}
    	
    	if(coHeaderListToUpdate.size() > 0) {
    		update coHeaderListToUpdate;
    	}
    }
    
    public static void updateRideawayPricing(List<Option_Fee__c> optionFeeList) {
    	Set<String> dealItemIdSet = new Set<String>();
    	for(Option_Fee__c optionFeeRec : optionFeeList) {
    		dealItemIdSet.add(optionFeeRec.Deal_Item__c);
    	}
    	updateRideawayPricingCalculation(dealItemIdSet);
    }
    
    public static void updateRideawayPricingCalculation(Set<String> dealItemIdSet) {
    	if(GeneralConfiguration.getCompanyLocale() == 'Australia') {
	    	if(dealItemIdSet.size() > 0) { 
		    	Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
		    	List<Deal_Item__c> dealItemList = [Select Is_Rideaway_Pricing_Enabled__c, Rideaway_Pricing_Total__c, 
    												(Select Price__c, Price_When_Tax_Included__c, Qty__c, Sales_Tax_Percentage__c, Fee__c, Product__c from Options_Fees__r 
    													WHERE Part__c != null OR Labour_Code__c != null OR Fee__c != null OR (Product__c != null AND Product__r.Type__c = 'Sublet')),
    												(Select Price__c, Price_When_Tax_Included__c, Qty__c, Sales_Tax_Percentage__c, Total_Price__c, Type__c from Deal_Unit_Prices_Costs__r)
    											FROM Deal_Item__c where Id IN: dealItemIdSet];
    											
				List<Sobject> sobjectlistToUpdate = new List<Sobject>();
				for(Deal_Item__c dealItemRec : dealItemList) {
					if(dealItemRec.Is_Rideaway_Pricing_Enabled__c) {
						Decimal partsAndLaborTotal = 0;
						Decimal feeTotal = 0;
                        Decimal subletTotal = 0;
						for(Option_Fee__c optionFeeRec : dealItemRec.Options_Fees__r) {
							if(!isTaxIncludingPricing) {
								if(optionFeeRec.Fee__c != null) {
									feeTotal += (((optionFeeRec.Price__c != null) ? optionFeeRec.Price__c : 0) * ((optionFeeRec.Qty__c != null) ? optionFeeRec.Qty__c : 0)).setScale(2, RoundingMode.HALF_UP);
								} else if(optionFeeRec.Product__c != null) {
                                    subletTotal += (((optionFeeRec.Price__c != null) ? optionFeeRec.Price__c : 0) * ((optionFeeRec.Qty__c != null) ? optionFeeRec.Qty__c : 0)).setScale(2, RoundingMode.HALF_UP);
								} else {
									partsAndLaborTotal += (((optionFeeRec.Price__c != null) ? optionFeeRec.Price__c : 0) * ((optionFeeRec.Qty__c != null) ? optionFeeRec.Qty__c : 0)).setScale(2, RoundingMode.HALF_UP);
								}
							} else {
								if(optionFeeRec.Fee__c != null) {
									feeTotal += (((optionFeeRec.Price_When_Tax_Included__c != null) ? optionFeeRec.Price_When_Tax_Included__c : ((optionFeeRec.Price__c * (1 + optionFeeRec.Sales_Tax_Percentage__c/100))).setScale(2, RoundingMode.HALF_UP)) * 
											((optionFeeRec.Qty__c != null) ? optionFeeRec.Qty__c : 0)).setScale(2, RoundingMode.HALF_UP);
								} else if(optionFeeRec.Product__c != null) {
                                    subletTotal += (((optionFeeRec.Price_When_Tax_Included__c != null) ? optionFeeRec.Price_When_Tax_Included__c : ((optionFeeRec.Price__c * (1 + optionFeeRec.Sales_Tax_Percentage__c/100))).setScale(2, RoundingMode.HALF_UP)) *
                                            ((optionFeeRec.Qty__c != null) ? optionFeeRec.Qty__c : 0)).setScale(2, RoundingMode.HALF_UP);
                                } else {
									partsAndLaborTotal += (((optionFeeRec.Price_When_Tax_Included__c != null) ? optionFeeRec.Price_When_Tax_Included__c : ((optionFeeRec.Price__c * (1 + optionFeeRec.Sales_Tax_Percentage__c/100))).setScale(2, RoundingMode.HALF_UP)) * 
											((optionFeeRec.Qty__c != null) ? optionFeeRec.Qty__c : 0)).setScale(2, RoundingMode.HALF_UP);
								}
							}
						}
						sobjectlistToUpdate.add(dealItemRec);
						Deal_Unit_Price_Cost__c basePriceRec = updateBasePriceAndStampDuty(dealItemRec, partsAndLaborTotal, feeTotal, subletTotal, isTaxIncludingPricing);
						if(basePriceRec.Id != null) {
							sobjectlistToUpdate.add(basePriceRec);
						}
					}
				}
				
				if(sobjectlistToUpdate.size() > 0) {
					sobjectlistToUpdate.sort();
					update sobjectlistToUpdate;
				}
	    	}
    	}
    }
    
    private static Deal_Unit_Price_Cost__c updateBasePriceAndStampDuty(Deal_Item__c dealItemRec, Decimal partsAndLaborTotal, Decimal feeTotal, Decimal subletTotal, Boolean isTaxIncludingPricing) {
    	Decimal stampDutyRate = GeneralConfiguration.getStampDutyRate();
		Decimal totalFactoryOption = 0;
		Decimal totalDealerInstalledOption = 0;
		Deal_Unit_Price_Cost__c basePriceRec = new Deal_Unit_Price_Cost__c();
		
		for(Deal_Unit_Price_Cost__c dealUnitPriceCostRec : dealItemRec.Deal_Unit_Prices_Costs__r) {
			if(dealUnitPriceCostRec.Type__c == 'Factory'){
				totalFactoryOption += (dealUnitPriceCostRec.Total_Price__c != null) ? dealUnitPriceCostRec.Total_Price__c : 0;
			} else if(dealUnitPriceCostRec.Type__c == 'Dealer') {
				totalDealerInstalledOption += (dealUnitPriceCostRec.Total_Price__c != null) ? dealUnitPriceCostRec.Total_Price__c : 0;
			} else if(dealUnitPriceCostRec.Type__c == 'Base') {
				basePriceRec = dealUnitPriceCostRec;
			}
		}
		Decimal minStampDuty = 0;
		if((totalFactoryOption + totalDealerInstalledOption) > 100) {
			minStampDuty = ((Math.ceil((totalFactoryOption + totalDealerInstalledOption) / 100) * 100) * (stampDutyRate / 100));
		}
		
    	Decimal minRideawayPricingTotal = totalFactoryOption + totalDealerInstalledOption + partsAndLaborTotal + feeTotal + subletTotal + minStampDuty;
    	dealItemRec.Rideaway_Pricing_Total__c = (dealItemRec.Rideaway_Pricing_Total__c != null) ? dealItemRec.Rideaway_Pricing_Total__c : 0;
    	if(minRideawayPricingTotal > dealItemRec.Rideaway_Pricing_Total__c) {
    		dealItemRec.Rideaway_Pricing_Total__c = minRideawayPricingTotal;
    		dealItemRec.Stamp_Duty_Total__c = minStampDuty;
    	} else {
			Decimal subTotal = dealItemRec.Rideaway_Pricing_Total__c - feeTotal - subletTotal;
			subTotal = (subTotal / ( 1 + (stampDutyRate/100))).setScale(2, RoundingMode.HALF_UP);
			if(subTotal < 100) {
				dealItemRec.Stamp_Duty_Total__c = 0;
			} else {
				Decimal roundedUpAmount = (Math.ceil(subTotal/100) * 100);
				Decimal stampDutyTotal = (roundedUpAmount * (stampDutyRate/100)).setScale(2, RoundingMode.HALF_UP);
				dealItemRec.Stamp_Duty_Total__c = stampDutyTotal;
			}
    	}
		
   		Decimal totalBasePrice = dealItemRec.Rideaway_Pricing_Total__c - (dealItemRec.Stamp_Duty_Total__c + totalFactoryOption + totalDealerInstalledOption + partsAndLaborTotal + feeTotal + subletTotal);
   		if(isTaxIncludingPricing) {
			basePriceRec.Price_When_Tax_Included__c = (totalBasePrice/((basePriceRec.Qty__c != null || basePriceRec.Qty__c == 0) ? basePriceRec.Qty__c : 1));
			basePriceRec.Price__c = (basePriceRec.Price_When_Tax_Included__c/(1 + (basePriceRec.Sales_Tax_Percentage__c/100)));
		} else {
			basePriceRec.Price__c = (totalBasePrice/((basePriceRec.Qty__c != null || basePriceRec.Qty__c == 0) ? basePriceRec.Qty__c : 1));
		}
		return basePriceRec;
    }
}
