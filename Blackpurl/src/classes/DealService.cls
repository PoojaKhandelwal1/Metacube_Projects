/** 
* Author: Gourav Goyal
* Since: Feb 20, 2018
* Name: DealService 
* Description: Apex class which contains deal related methods.
**/
public with sharing class DealService {
    
    /**
    * Name: getSalesTaxForDeal 
    * Desc: Method to get deal sales tax
    * @param:   (1)dealId - String - deal id
    * @return: Decimal - Sales Tax Total 
    **/
    public static String getSalesTaxForDeal(String dealId) {
        List<Individual_Tax__c> individualItemList = [select CO_Line_Item__c, Tax_Rate__c, Form_Label__c, Sales_Tax_Item_Name__c,
            Taxable_Amount__c, Tax_Amount__c, Applicable_Tax__c, List_Tax_items_on_forms__c
            from Individual_Tax__c where Option_Fee__r.Deal__c =: dealId
            OR Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c =: dealId
            OR F_I_Product__r.Deal_Finance__r.Deal__c =: dealId
            OR (Deal_Item__r.Deal__c =: dealId AND Deal_Item__r.Type__c = 'Trade In')];
        Map<String, Decimal> salesTaxNameToTaxValue = TaxCalculation.getTaxAmountWithFormLabel(individualItemList);
        Decimal salesTax = 0;    
        for(String taxName : salesTaxNameToTaxValue.keySet()){
            salesTax += salesTaxNameToTaxValue.get(taxName);
        } 
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeNumberField('SalesTax', salesTax); 
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        return jsonString;
    }
      
    /**
    * Name: updateFinanceStatus 
    * Desc: Method to set deal finance status and update related checkout item
    * @param:   (1)coHeaderId - String - co header id
    * @param:   (1)dealId - String - deal id
    * @param:   (1)dealFinanceObj - DealWrapper.DealFinanceWrapper - deal finance wrapper obj
    * @param:   (1)financeStatus - String - Deal finance status
    * @return: void
    **/
    public static void updateFinanceStatus(String coHeaderId, String dealId, DealWrapper.DealFinanceWrapper dealFinanceObj, String financeStatus) {
        List<SObject> sObjectListToUpdate = new List<SObject>();
        Deal_Finance__c dealFinanceRec = CustomerOrderCtrl.setDealFinanceField(dealFinanceObj);
        dealFinanceRec.Status__c = financeStatus;
        sObjectListToUpdate.add(dealFinanceRec);
        if(!GeneralConfiguration.isLoadNewCustomerOrder()) {
            if(financeStatus == 'Submitted') {
                List<CO_Invoice_Item__c> coInvoiceItemListToInsert = new List<CO_Invoice_Item__c>();
                if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<CO_Invoice_Header__c> coInvoiceHeaderList = [Select Id from CO_Invoice_Header__c where CO_Header__c = :coHeaderId AND Invoice_Status__c = 'Active'];
                if(coInvoiceHeaderList.size() == 0) {
                    coInvoiceHeaderList.add(new CO_Invoice_Header__c(CO_Header__c = coHeaderId, Invoice_Status__c = 'Active'));
                    if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                    insert coInvoiceHeaderList;
                }
                CO_Invoice_Item__c coInvoiceItem = new CO_Invoice_Item__c(CO_Invoice_Header__c = coInvoiceHeaderList[0].Id, isActive__c = false, Is_Invoiceable__c = false, Deal__c = dealId, Deal_Finance__c = dealFinanceObj.Id);
                coInvoiceItemListToInsert.add(coInvoiceItem);
                if(coInvoiceItemListToInsert.size() > 0){
                    if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                    insert coInvoiceItemListToInsert;
                }
            } else if(financeStatus == 'Approved') {
                if(AccessControl.ifObjectFieldIsAccessible('Co_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Co_Invoice_Item__c> coInvoiceItemList = [Select Is_Invoiceable__c from Co_Invoice_Item__c where Deal_Finance__c = :dealFinanceObj.Id AND Deal__c = :dealId];
                if(coInvoiceItemList.size() > 0) {
                    coInvoiceItemList[0].Is_Invoiceable__c = true;
                    if(AccessControl.ifObjectFieldIsUpdateable('Co_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    sObjectListToUpdate.add(coInvoiceItemList[0]);
                }
            }
        }
        
        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Finance__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        update sObjectListToUpdate;
        
        if(GeneralConfiguration.isLoadNewCustomerOrder() && financeStatus == 'Approved') {
            Map<String, Boolean> optionNameToOptionValueMap = CustomerOrderCtrl.isDealInvoiceable(dealId);
            if(optionNameToOptionValueMap.get('Invoiceable')) {
                List<Co_Invoice_Item__c> coInvoiceItemList = [Select Is_Invoiceable__c, IsActive__c from Co_Invoice_Item__c where Deal__c = :dealId AND (IsActive__c = false OR Is_Invoiceable__c = false)];
                if(coInvoiceItemList.size() > 0) {
                    coInvoiceItemList[0].Is_Invoiceable__c = optionNameToOptionValueMap.get('Invoiceable');
                    coInvoiceItemList[0].IsActive__c = optionNameToOptionValueMap.get('Active');
                    if(AccessControl.ifObjectFieldIsUpdateable('Co_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update coInvoiceItemList[0];
                }
            }
        }
    }
    
    public static void updateDealFinanceDetails(String dealId, String dealFinanceJSON) { 
        DealWrapper.DealFinanceWrapper dealFinanceObj = (DealWrapper.DealFinanceWrapper) System.JSON.deserialize(dealFinanceJSON, DealWrapper.DealFinanceWrapper.class);
        
        Deal_Finance__c dealFinanceRec = CustomerOrderCtrl.setDealFinanceField(dealFinanceObj);
        List<SObject> sObjectListToUpdate = new List<SObject>{new Deal__c(Id = dealId, Down_Payment__c = dealFinanceRec.Down_Payment__c)};
        if(String.isNotBlank(dealFinanceRec.Id)) {
            if(AccessControl.ifObjectFieldIsUpdateable('Deal_Finance__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            sObjectListToUpdate.add(dealFinanceRec);
        } else {
            if(AccessControl.ifObjectFieldIsCreateable('Deal_Finance__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(String.isBlank(dealFinanceRec.Status__c)) {
                dealFinanceRec.Status__c = Constants.QUOTATION;
            }
            dealFinanceRec.Deal__c = dealId;
            insert dealFinanceRec;
            
            if(GeneralConfiguration.isLoadNewCustomerOrder()) {
                List<CO_Invoice_Item__c> invItemList = [Select Id, isActive__c, Is_Invoiceable__c from CO_Invoice_Item__c where Deal__c =: dealId AND isActive__c = true AND Is_Invoiceable__c = true];
                if(invItemList.size() > 0) {
                    for(CO_Invoice_Item__c invItemRec : invItemList) {
                        invItemRec.isActive__c = false;
                        invItemRec.Is_Invoiceable__c = false;
                    }
                    sObjectListToUpdate.addAll((List<SObject>) invItemList);
                }
            }
        }
        if(AccessControl.ifObjectFieldIsUpdateable('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        update sObjectListToUpdate;
    }
        
    public static void addMultiplePartsInDeal(List<COService.SearchPartDetailWrapper> partToInsertList, String dealItemId) {
        Map<String, Decimal> partIdTQtyToInsertMap = new Map<String, Decimal>();
        for(COService.SearchPartDetailWrapper partInfoObj : partToInsertList) {
            partIdTQtyToInsertMap.put(partInfoObj.PartId, partInfoObj.Qty);
        }
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Map<Id, Part__c> partIdToPartRecMap = new Map<Id, Part__c>([select Part_Number__c, Description__c, Retail_Price__c, Enviro_Fee__c, 
                                                                    Enviro_Fee_Code__c, 
                                                                    Enviro_Fee_Code__r.Code__c, 
                                                                    Enviro_Fee_Code__r.Description__c 
                                                                    from Part__c 
                                                                    where Id =: partIdTQtyToInsertMap.keySet()]);
        if(partIdToPartRecMap.keySet().size() == 0) {
            return;
        }
            
        List<Option_Fee__c> optionsListToInsert = new List<Option_Fee__c>();
        Option_Fee__c relatedEnvFeeRec;
        Option_Fee__c optionAndeFeeRec;
        
        for(COService.SearchPartDetailWrapper partInfoObj : partToInsertList) {
            optionAndeFeeRec = new Option_Fee__c();
            optionAndeFeeRec.Deal__c = partInfoObj.DealId;
            optionAndeFeeRec.Deal_Item__c = dealItemId;  
            optionAndeFeeRec.Qty__c = (partInfoObj.Qty != null && partInfoObj.Qty != 0) ? partInfoObj.Qty : 1;
            optionAndeFeeRec.Price__c = optionAndeFeeRec.Price_When_Tax_Included__c = partIdToPartRecMap.get(partInfoObj.PartId).Retail_Price__c;
            optionAndeFeeRec.Part__c = partInfoObj.PartId;
            optionAndeFeeRec.Item_Code__c = partIdToPartRecMap.get(partInfoObj.PartId).Part_Number__c;
            optionAndeFeeRec.Item_Description__c = partIdToPartRecMap.get(partInfoObj.PartId).Description__c;
            optionAndeFeeRec.Is_Install__c = false;
            optionsListToInsert.add(optionAndeFeeRec);
            // Create one Extra line for Env Fee
            if(partIdToPartRecMap.get(partInfoObj.PartId).Enviro_Fee__c != null && partIdToPartRecMap.get(partInfoObj.PartId).Enviro_Fee_Code__c != null) {
                relatedEnvFeeRec = new Option_Fee__c(Deal__c = partInfoObj.DealId, Deal_Item__c = dealItemId, Qty__c = 1, Is_Environmental_Fee__c = true);
                relatedEnvFeeRec.Fee__c = partIdToPartRecMap.get(partInfoObj.PartId).Enviro_Fee_Code__c;
                relatedEnvFeeRec.Price__c = relatedEnvFeeRec.Price_When_Tax_Included__c = partIdToPartRecMap.get(partInfoObj.PartId).Enviro_Fee__c;
                relatedEnvFeeRec.Item_Code__c = partIdToPartRecMap.get(partInfoObj.PartId).Enviro_Fee_Code__r.Code__c;
                relatedEnvFeeRec.Item_Description__c = partIdToPartRecMap.get(partInfoObj.PartId).Part_Number__c + ' ' + partIdToPartRecMap.get(partInfoObj.PartId).Enviro_Fee_Code__r.Description__c;
                relatedEnvFeeRec.Price__c = partIdToPartRecMap.get(partInfoObj.PartId).Enviro_Fee__c;
                optionsListToInsert.add(relatedEnvFeeRec);
            }
        }
        insert optionsListToInsert;
    }
    
    public static void stockInCOU(String tradeInId, String unitId) {
        List<Customer_Owned_Unit__c> couList = new List<Customer_Owned_Unit__c>();
        String query = 'Select ';
        for(String fieldName : CustomerOwnedUnit.fieldsList()) {
            query += fieldName + ', ';
        }
        query += '(Select Agreed_Value__c, Deal__r.CO_Header__r.Name, Default_Unit_Sales_Tax_Percentage__c, Actual_Cash_Value__c from Deals_Units_Junction__r where Id =:tradeInId)';
        query += ' from Customer_Owned_Unit__c where Id =:unitId';
        
        couList = Database.query(query);
        if(couList.size() == 0) {
            return;
        }
        Customer_Owned_Unit__c stockUnitToInsert = couList[0].clone(false, false, false, false);
        couList[0].Status__c = 'Transferred';
        
        stockUnitToInsert.put('Id',null);
        stockUnitToInsert.put('Unit_Type__c', 'STOCK');
        stockUnitToInsert.put('Status__c','Available');
        stockUnitToInsert.put('New_Unit__c',false);
        stockUnitToInsert.put('Account__c', null);
        stockUnitToInsert.put('Taxable__c',true);
        stockUnitToInsert.put('Applicable_Tax__c', Configurations__c.getInstance().Default_Tax_on_Unit__c);
        stockUnitToInsert.put('Stock_Id__c',null);
        stockUnitToInsert.put('Unit_Id__c',null);
        stockUnitToInsert.put('Date_Stocked_In__c', Date.today());
        if(GeneralConfiguration.getAccrueTradeTaxUntilUnitSold()) {
            populateTradeInAndSalesTaxOnSku(couList[0].Deals_Units_Junction__r[0], stockUnitToInsert);
        }
        
        couList.add(stockUnitToInsert);
        if(AccessControl.ifObjectFieldIsCreateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        upsert couList;
        
        if(couList.size() > 1 && couList[0].Deals_Units_Junction__r.size() > 0) {
            Unit_Price_Cost__c untPriceCostRec = new Unit_Price_Cost__c(Customer_Owned_Unit__c = couList[1].Id);
            untPriceCostRec.Type__c = 'Base';
            untPriceCostRec.Item_Description__c = 'Customer Trade-In';
            untPriceCostRec.Ref_No__c = couList[0].Deals_Units_Junction__r[0].Deal__r.CO_Header__r.Name;
            untPriceCostRec.Total_Price__c = couList[0].Deals_Units_Junction__r[0].Agreed_Value__c;
            untPriceCostRec.Total_Cost__c = couList[0].Deals_Units_Junction__r[0].Actual_Cash_Value__c;
            if(AccessControl.ifObjectFieldIsCreateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert untPriceCostRec;
        }
        
        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        update new Deal_Item__c(Id = tradeInId, Is_Stocked_In__c = true, Stocked_In_Unit__c = stockUnitToInsert.Id);
    }
    
    public static List<ProfitabilityWrapper.SectionProfitabilityWrapper> getDealProfitability(String coId) {
        List<ProfitabilityWrapper.SectionProfitabilityWrapper> profitabilityWrapperList = new List<ProfitabilityWrapper.SectionProfitabilityWrapper>();
        
        List<Deal__c> dealList = [Select Total_Unit_Cost__c, Total_TradeIn_Cost__c, Total_Part_Cost__c, Total_Merch_Cost__c, Ttoal_Labour_Cost__c, Total_Sublet_Cost__c, 
				Invoice_Number__c, Total_Fee_Cost__c, Total_Warranty_Product_Cost__c, Total_Deal_Product_Cost__c, Total_Financing_Product_Cost__c, Total_Third_Party_Product_Cost__c, 
				Total_Commission_Cost__c, Deal_Commission__c, Type__c, F_I_Total__c, (Select Id, Finance_Commission__c from Deal_Finances__r),
                (Select Qty__c, Fee__r.Cost_Method__c, Fee__r.Cost_Rate__c, Fee__r.Is_Include_In_Profit_Calculation__c,  Product__r.Cost__c, Product__r.Cost_Method__c, 
                    Deal_Kit_Header__c, Status__c, Part__c, Part__r.Part_Type__c, Labour_Code__c, Price__c, Per_Item_Cost__c, Product__r.Type__c, 
                    Deal_Item__r.Option_And_Fee_Status__c, Part__r.Average_Cost__c, Labour_Code__r.Cost_Method__c, Labour_Code__r.Cost_Rate__c from Options_Fees__r), 
				(Select Type__c, Agreed_Value__c, Actual_Cash_Value__c, Default_Unit_Sales_Tax_Percentage__c, Stamp_Duty_Total__c, Customer_Owned_Unit__c from Deal_Items__r),
                (Select Id, Price__c, Vendor_Product__c, Vendor_Product__r.Cost__c, Vendor_Product__r.Cost_Method__c from F_I_Products__r) 
                from Deal__c where CO_Header__c =: coId];
                                        
        List<Deal_Unit_Price_Cost__c> dupcList = [Select Qty__c, Price__c, Deal_Item__r.Customer_Owned_Unit__c, Unit_Price_Cost__r.Total_Cost__c from Deal_Unit_Price_Cost__c where Deal_Item__r.Deal__r.CO_Header__c =: coId];                  
        
        if(dealList.size() > 0) {
            Decimal unitSales, tradeInSales, partSales, merchSales, labourSales, feeSales, subletSales, warrantyProductSales, thirdPartyProductSales, dealProductSales, financingProductSales, commissionSales;
            Decimal unitCost, tradeInCost, partCost, merchCost, labourCost, feeCost, subletCost, warrantyProductCost, dealProductCost, financingProductCost, thirdPartyProductCost, commissionCost;
            unitCost = tradeInCost = partCost = merchCost = labourCost = feeCost = subletCost = warrantyProductCost = dealProductCost = financingProductCost = thirdPartyProductCost = commissionCost = 0;
            
            commissionCost = (dealList[0].Deal_Commission__c != null) ? dealList[0].Deal_Commission__c.setScale(2, RoundingMode.HALF_UP) : 0;
            commissionSales = (dealList[0].Type__c == Constants.FINANCED && dealList[0].Deal_Finances__r.size() > 0 && dealList[0].Deal_Finances__r[0].Finance_Commission__c != null) ?
                                dealList[0].Deal_Finances__r[0].Finance_Commission__c : 0;
            if(dealList[0].Type__c == Constants.FINANCED && dealList[0].F_I_Products__r.size() > 0) {
                financingProductSales = (financingProductSales != null) ? financingProductSales : (dealList[0].F_I_Total__c != null ? dealList[0].F_I_Total__c.setScale(2, RoundingMode.HALF_UP) : 0);
                for(F_I_Product__c fAndIProductRec : dealList[0].F_I_Products__r) {
                    if(fAndIProductRec.Vendor_Product__r.Cost_Method__c == 'Fixed Cost' && fAndIProductRec.Vendor_Product__r.Cost__c != null) {
                        financingProductCost += (fAndIProductRec.Vendor_Product__r.Cost__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(fAndIProductRec.Vendor_Product__r.Cost_Method__c == 'Percent Retail'  && fAndIProductRec.Vendor_Product__r.Cost__c != null) {
                        financingProductCost += ((fAndIProductRec.Price__c * fAndIProductRec.Vendor_Product__r.Cost__c)/100).setScale(2, RoundingMode.HALF_UP);
                    }
                }
            }
			
			Set<Id> skuIdSet = new Set<Id>();
			for(Deal_Item__c dealItemRec : dealList[0].Deal_Items__r) {
				if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_TRADE_IN) {
					tradeInSales = (tradeInSales != null) ? tradeInSales.setScale(2, RoundingMode.HALF_UP) : 0;
					dealItemRec.Agreed_Value__c = (dealItemRec.Agreed_Value__c != null) ? dealItemRec.Agreed_Value__c : 0;
					dealItemRec.Actual_Cash_Value__c = (dealItemRec.Actual_Cash_Value__c != null) ? dealItemRec.Actual_Cash_Value__c : 0;
					if(GeneralConfiguration.getTaxIncludingPricing()) {
					dealItemRec.Default_Unit_Sales_Tax_Percentage__c = (dealItemRec.Default_Unit_Sales_Tax_Percentage__c != null) ? dealItemRec.Default_Unit_Sales_Tax_Percentage__c : 0;
						dealItemRec.Agreed_Value__c = (dealItemRec.Agreed_Value__c / (1 + dealItemRec.Default_Unit_Sales_Tax_Percentage__c/100));
					}
					tradeInCost += (dealItemRec.Agreed_Value__c - dealItemRec.Actual_Cash_Value__c).setScale(2, RoundingMode.HALF_UP);
				} else {
					skuIdSet.add(dealItemRec.Customer_Owned_Unit__c);
				}
			}
			
			//Set<String> unitToIncludeAdjustedBaseCostIdSet = new Set<String>();
			//Set<String> upcToExcludeAdjustedBaseCostIdSet = new Set<String>();
            for(Deal_Unit_Price_Cost__c dupcRec : dupcList) {
                unitSales = (unitSales != null) ? unitSales.setScale(2, RoundingMode.HALF_UP) : 0;
                dupcRec.Qty__c = (dupcRec.Qty__c != null) ? dupcRec.Qty__c : 1;
                dupcRec.Price__c = dupcRec.Price__c != null ? dupcRec.Price__c : 0;
                unitSales += (dupcRec.Price__c * dupcRec.Qty__c).setScale(2, RoundingMode.HALF_UP);
				/*unitCost += (dupcRec.Unit_Price_Cost__r.Total_Cost__c != null) ? dupcRec.Unit_Price_Cost__r.Total_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0;
                upcToExcludeAdjustedBaseCostIdSet.add(dupcRec.Unit_Price_Cost__c);
				unitToIncludeAdjustedBaseCostIdSet.add(dupcRec.Deal_Item__r.Customer_Owned_Unit__c);*/
            }
	        unitCost = getUnitCost(skuIdSet);
	        /*
            List<Unit_Price_Cost__c> upcList = [Select Id, Total_Cost__c from Unit_Price_Cost__c where Customer_Owned_Unit__c IN: unitToIncludeAdjustedBaseCostIdSet AND Type__c = 'Base' 
                AND Id NOT IN: upcToExcludeAdjustedBaseCostIdSet];
            for(Unit_Price_Cost__c upcRec : upcList) {
                unitCost += (upcRec.Total_Cost__c != null) ? upcRec.Total_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0;
	        }*/
            
            for(Option_Fee__c optionFeeRec : dealList[0].Options_Fees__r) {
                optionFeeRec.Price__c = (optionFeeRec.Price__c != null) ? optionFeeRec.Price__c : 0;
                optionFeeRec.Per_Item_Cost__c = (optionFeeRec.Per_Item_Cost__c != null) ? optionFeeRec.Per_Item_Cost__c : 0;
                optionFeeRec.Qty__c = (optionFeeRec.Qty__c != null) ? optionFeeRec.Qty__c : 1;
                
                if(optionFeeRec.Fee__c != null && optionFeeRec.Fee__r.Is_Include_In_Profit_Calculation__c) {
                    feeSales = (feeSales != null) ? feeSales : 0;
                    feeSales += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                    if(optionFeeRec.Deal_Kit_Header__c != null && optionFeeRec.Status__c == Constants.Fulfilled) {
                        feeCost += (optionFeeRec.Qty__c * optionFeeRec.Per_Item_Cost__c).setScale(2, RoundingMode.HALF_UP);
                    } else {
                        if(optionFeeRec.Fee__r.Cost_Method__c == 'Fixed Cost' && optionFeeRec.Fee__r.Cost_Rate__c != null) {
                            feeCost += (optionFeeRec.Qty__c * optionFeeRec.Fee__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
                        } else if(optionFeeRec.Fee__r.Cost_Method__c == 'Percent Retail' && optionFeeRec.Fee__r.Cost_Rate__c != null) {
                            feeCost += (optionFeeRec.Qty__c * ((optionFeeRec.Price__c * optionFeeRec.Fee__r.Cost_Rate__c)/100)).setScale(2, RoundingMode.HALF_UP);
                        }
                    }
                } else if(optionFeeRec.Product__c != null ) {
                    if(optionFeeRec.Product__r.Type__c == Constants.SUBLET) {
                        subletSales = (subletSales != null) ? subletSales : 0;
                        subletSales += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                        if(optionFeeRec.Deal_Item__c != null && optionFeeRec.Deal_Item__r.Option_And_Fee_Status__c == Constants.UNCOMIITTED) {
                        	if(optionFeeRec.Product__r.Cost_Method__c == 'Fixed Cost' && optionFeeRec.Product__r.Cost__c != null) {
	                            subletCost += (optionFeeRec.Qty__c * optionFeeRec.Product__r.Cost__c).setScale(2, RoundingMode.HALF_UP);
	                        } else if(optionFeeRec.Product__r.Cost_Method__c == 'Percent Retail' && optionFeeRec.Product__r.Cost__c != null) {
	                            subletCost += (optionFeeRec.Qty__c * ((optionFeeRec.Price__c * optionFeeRec.Product__r.Cost__c)/100)).setScale(2, RoundingMode.HALF_UP);
	                        }
                        } else if(optionFeeRec.Status__c == Constants.Fulfilled) {
                            subletCost += (optionFeeRec.Qty__c * optionFeeRec.Per_Item_Cost__c).setScale(2, RoundingMode.HALF_UP);
                        } else {
                            subletCost += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                        }
                    } else {
                        Decimal cost = 0;
                        if(optionFeeRec.Product__r.Cost_Method__c == 'Fixed Cost' && optionFeeRec.Product__r.Cost__c != null) {
                            cost = (optionFeeRec.Qty__c * optionFeeRec.Product__r.Cost__c).setScale(2, RoundingMode.HALF_UP);
                        } else if(optionFeeRec.Product__r.Cost_Method__c == 'Percent Retail' && optionFeeRec.Product__r.Cost__c != null) {
                            cost = (optionFeeRec.Qty__c * ((optionFeeRec.Price__c * optionFeeRec.Product__r.Cost__c)/100)).setScale(2, RoundingMode.HALF_UP);
                        }
                        if(optionFeeRec.Product__r.Type__c == 'Deal Product') {
                            dealProductSales = (dealProductSales != null) ? dealProductSales : 0;
                            dealProductSales += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                            dealProductCost += cost;
                        } else if(optionFeeRec.Product__r.Type__c == 'Warranty Plan') {
                            warrantyProductSales = (warrantyProductSales != null) ? warrantyProductSales : 0;
                            warrantyProductSales += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                            warrantyProductCost += cost;
                        } else if(optionFeeRec.Product__r.Type__c == 'Financing Product') {
                            financingProductSales = (financingProductSales != null) ? financingProductSales : 0;
                            financingProductSales += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                            financingProductCost += cost;
                        } else if(optionFeeRec.Product__r.Type__c == 'Third Party') {
                            thirdPartyProductSales = (thirdPartyProductSales != null) ? thirdPartyProductSales : 0;
                            thirdPartyProductSales += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                            thirdPartyProductCost += cost;
                        }
                        cost = null;
                    }
                } else if(optionFeeRec.Labour_Code__c != null) {
                    labourSales = (labourSales != null) ? labourSales : 0;
                    labourSales += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                    if(optionFeeRec.Deal_Item__c != null && optionFeeRec.Deal_Item__r.Option_And_Fee_Status__c == Constants.UNCOMIITTED) {
                    	if(optionFeeRec.Labour_Code__r.Cost_Method__c == 'Fixed Cost' && optionFeeRec.Labour_Code__r.Cost_Rate__c != null) {
                            labourCost += (optionFeeRec.Qty__c * optionFeeRec.Labour_Code__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
                        } else if(optionFeeRec.Labour_Code__r.Cost_Method__c == 'Percent Retail' && optionFeeRec.Labour_Code__r.Cost_Rate__c != null) {
                            labourCost += (optionFeeRec.Qty__c * ((optionFeeRec.Price__c * optionFeeRec.Labour_Code__r.Cost_Rate__c)/100)).setScale(2, RoundingMode.HALF_UP);
                        }
                    } else if(optionFeeRec.Status__c == Constants.Fulfilled) {
                        labourCost += (optionFeeRec.Qty__c * optionFeeRec.Per_Item_Cost__c).setScale(2, RoundingMode.HALF_UP);
                    } else {
                        labourCost += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                    }
                } else if(optionFeeRec.Part__c != null) {
                    if(String.isNotBlank(optionFeeRec.Part__r.Part_Type__c) && optionFeeRec.Part__r.Part_Type__c == 'Merchandise') {
                        merchSales = (merchSales != null) ? merchSales : 0;
                        merchSales += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                        if(optionFeeRec.Deal_Item__c != null && optionFeeRec.Deal_Item__r.Option_And_Fee_Status__c == Constants.UNCOMIITTED && optionFeeRec.Part__r.Average_Cost__c != null) {
	                    	merchCost += (optionFeeRec.Qty__c * optionFeeRec.Part__r.Average_Cost__c).setScale(2, RoundingMode.HALF_UP);
	                    } else if(optionFeeRec.Status__c == Constants.Fulfilled) {
                            merchCost += (optionFeeRec.Qty__c * optionFeeRec.Per_Item_Cost__c).setScale(2, RoundingMode.HALF_UP);
                        } else {
                            merchCost += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                        }
                    } else {
                        partSales = (partSales != null) ? partSales : 0;
                        partSales += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                        if(optionFeeRec.Deal_Item__c != null && optionFeeRec.Deal_Item__r.Option_And_Fee_Status__c == Constants.UNCOMIITTED && optionFeeRec.Part__r.Average_Cost__c != null) {
	                    	partCost += (optionFeeRec.Qty__c * optionFeeRec.Part__r.Average_Cost__c).setScale(2, RoundingMode.HALF_UP);
	                    } else if(optionFeeRec.Status__c == Constants.Fulfilled) {
                            partCost += (optionFeeRec.Qty__c * optionFeeRec.Per_Item_Cost__c).setScale(2, RoundingMode.HALF_UP);
                        } else {
                            partCost += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                        }
                    }
                }
            }			
			
			if(dealList[0].Invoice_Number__c != null) {
				unitCost = dealList[0].Total_Unit_Cost__c;
				tradeInCost = dealList[0].Total_TradeIn_Cost__c;
				partCost = dealList[0].Total_Part_Cost__c;
				merchCost = dealList[0].Total_Merch_Cost__c;
				labourCost = dealList[0].Ttoal_Labour_Cost__c;
				subletCost = dealList[0].Total_Sublet_Cost__c;
				feeCost = dealList[0].Total_Fee_Cost__c;
				warrantyProductCost = dealList[0].Total_Warranty_Product_Cost__c;
				dealProductCost = dealList[0].Total_Deal_Product_Cost__c;
				financingProductCost = dealList[0].Total_Financing_Product_Cost__c;
				thirdPartyProductCost = dealList[0].Total_Third_Party_Product_Cost__c;
				commissionCost = dealList[0].Total_Commission_Cost__c;
			}                       
            List<ProfitabilityWrapper.ProductProfitabilityWrapper> dealProfitabilityObjList = new List<ProfitabilityWrapper.ProductProfitabilityWrapper>();
                
            if(unitSales != null) {
                dealProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Units', unitSales, unitCost));
            }
            if(tradeInSales != null) {
                dealProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Trade Ins', tradeInSales, tradeInCost));
            }
            if(partSales != null) {
                dealProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Parts', partSales, partCost));
            }
            if(merchSales != null) {
                dealProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Merchandise', merchSales, merchCost));
            }
            if(labourSales != null) {
                dealProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Labor', labourSales, labourCost));
            }
            if(subletSales != null) {
                dealProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Sublet', subletSales, subletCost));
            }
            if(feeSales != null) {
                dealProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Fees', feeSales, feeCost));
            }
            if(warrantyProductSales != null) {
                dealProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Warranty Plans', warrantyProductSales, warrantyProductCost));
            }
            if(dealProductSales != null) {
                dealProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Deal Products', dealProductSales, dealProductCost));
            }
            if(financingProductSales != null) {
                dealProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Finance Products', financingProductSales, financingProductCost));
            }
            if(thirdPartyProductSales != null) {
                dealProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Third-Party Products', thirdPartyProductSales, thirdPartyProductCost));
            }
            if((commissionSales != null && commissionSales != 0) || (commissionCost != null && commissionCost != 0)) {
                dealProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Commissions', commissionSales, commissionCost));
            }
            if(dealProfitabilityObjList.size() > 0) {
                profitabilityWrapperList.add(new ProfitabilityWrapper.SectionProfitabilityWrapper('Deal Section', dealProfitabilityObjList));
            }
        }
        return profitabilityWrapperList;
    }
    
    public static void saveDealItemTaxInfo(String dealItemTaxInfoJSON) {
        DealItem.DealItemTaxDetailWrapper dealItemTaxDetailObj = 
                (DealItem.DealItemTaxDetailWrapper) system.JSON.deserialize(dealItemTaxInfoJSON, DealItem.DealItemTaxDetailWrapper.class);
        
        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        List<Deal_Item__c> dealItemList = [SELECT Type__c, Deal__c FROM Deal_Item__c WHERE Id =: dealItemTaxDetailObj.Id];
        if(dealItemList.size() == 0) {
            return;
        }
        
        Deal_Item__c dealItemRec = dealItemList[0];
        dealItemRec.Taxable__c = dealItemTaxDetailObj.IsTaxable;
        if(dealItemRec.Taxable__c) {
            dealItemRec.Applicable_Tax__c = dealItemTaxDetailObj.ApplicableTaxId;
        } else {
            dealItemRec.Applicable_Tax__c = null;
        }
        update dealItemRec; 
        if(!GeneralConfiguration.getTaxIncludingPricing() && GeneralConfiguration.isTradeTaxCreditCanNotExceedUnitTax()) {
            limitDealItemSalesTax(dealItemRec.Deal__c);
        }
        
        if(GeneralConfiguration.getAccrueTradeTaxUntilUnitSold()) {
            dealItemList = [SELECT Stocked_In_Unit__c, Agreed_Value__c, Default_Unit_Sales_Tax_Percentage__c FROM Deal_Item__c 
                                                    WHERE Id =: dealItemTaxDetailObj.Id AND Type__c =: Constants.DEAL_ITEM_TYPE_TRADE_IN
                                                        AND Stocked_In_Unit__c != null];
            if(dealItemList.size() > 0) {
                Customer_Owned_Unit__c skuRecToUpdate = new Customer_Owned_Unit__c(Id = dealItemList[0].Stocked_In_Unit__c);
                populateTradeInAndSalesTaxOnSku(dealItemList[0], skuRecToUpdate);
                update skuRecToUpdate;
            }
        }
    }
    
    /**
    * Name: limitDealItemSalesTax
    * Desc: Method to ensure that the sales tax credit for the trades does not exceed the sales tax calculated on the units
    * @param: dealId - String - Id of Deal Record
    **/
    public static void limitDealItemSalesTax(String dealId) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal_Item__c> dealItemList = [SELECT Id, Type__c, Agreed_Value__c, Default_Unit_Sales_Tax_Percentage__c, Deal__c FROM Deal_Item__c 
                                            WHERE Deal__c =: dealId AND Type__c =: Constants.DEAL_ITEM_TYPE_TRADE_IN AND Taxable__c = true ORDER by CreatedDate DESC];
        if(dealItemList.size() == 0) {
            return;
        }
        
        if(GeneralConfiguration.getTaxIncludingPricing() || !GeneralConfiguration.isTradeTaxCreditCanNotExceedUnitTax()) {
            for(Deal_Item__c tradeInRec : dealItemList) {
                tradeInRec.Agreed_Value_Taxable_Amount__c = tradeInRec.Agreed_Value__c;
            }    
        } else {
            Decimal tradeInSalesTaxTotal = 0, unitSalesTaxTotal = 0;
          
            for(Deal_Item__c tradeInRec : dealItemList) {
                tradeInSalesTaxTotal += calculateTradeInSalesTaxTotal(tradeInRec);
            }    
            
            List<Individual_Tax__c> individualTaxList = [SELECT Deal_Unit_Price_Cost__r.Deal_Item__c, Tax_Rate__c, Taxable_Amount__c FROM Individual_Tax__c WHERE 
                                                            Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c =: dealId];   
            
            for(Individual_Tax__c indvTaxRec : individualTaxList) {
                if(indvTaxRec.Tax_Rate__c != null) { // Aus off
                    unitSalesTaxTotal += ((indvTaxRec.Tax_Rate__c * indvTaxRec.Taxable_Amount__c)/100).setScale(2, RoundingMode.HALF_UP) ;
                }
            }    
              
            Decimal exceededTradeInSalesTaxAmount = (tradeInSalesTaxTotal - unitSalesTaxTotal).setScale(2, RoundingMode.HALF_UP);
            Decimal tradeInSalesTax = 0;
            Decimal salesTaxPercentageOnAgreedValue = 0;
            
            if(exceededTradeInSalesTaxAmount > 0) {
                for(Deal_Item__c tradeInRec : dealItemList) {
                    tradeInSalesTax = calculateTradeInSalesTaxTotal(tradeInRec);
                    salesTaxPercentageOnAgreedValue = (tradeInRec.Default_Unit_Sales_Tax_Percentage__c != null) ? tradeInRec.Default_Unit_Sales_Tax_Percentage__c : 0;
                    if(tradeInSalesTax >= exceededTradeInSalesTaxAmount && exceededTradeInSalesTaxAmount > 0 && salesTaxPercentageOnAgreedValue > 0) {
                        tradeInRec.Agreed_Value_Taxable_Amount__c = ((tradeInSalesTax - exceededTradeInSalesTaxAmount) / salesTaxPercentageOnAgreedValue) * 100;
                        exceededTradeInSalesTaxAmount = 0;
                    } else if(exceededTradeInSalesTaxAmount <= 0) {
                        tradeInRec.Agreed_Value_Taxable_Amount__c = tradeInRec.Agreed_Value__c;
                    } else {
                        tradeInRec.Agreed_Value_Taxable_Amount__c = 0.00;
                        exceededTradeInSalesTaxAmount = exceededTradeInSalesTaxAmount - tradeInSalesTax;
                    }                   
                }  
            } else {
                for(Deal_Item__c tradeInRec : dealItemList) {
                    tradeInRec.Agreed_Value_Taxable_Amount__c = tradeInRec.Agreed_Value__c;
                }  
            }
        }
        
        if(dealItemList.size() > 0) {
            update dealItemList;
            DealItemTriggerHelper.updateTotalOnDeal(dealItemList);
        }
    }
    
    private static Decimal calculateTradeInSalesTaxTotal(Deal_Item__c dealItemRec) {
        Decimal agreedValue = (dealItemRec.Agreed_Value__c != null) ? dealItemRec.Agreed_Value__c.setScale(2, RoundingMode.HALF_UP) : 0;
        Decimal salesTaxPercentageOnAgreedValue = (dealItemRec.Default_Unit_Sales_Tax_Percentage__c != null) ? dealItemRec.Default_Unit_Sales_Tax_Percentage__c : 0;
        Decimal tradeInSalesTaxTotal = (agreedValue * (salesTaxPercentageOnAgreedValue / 100)).setScale(2, RoundingMode.HALF_UP); // Aus Off
        return tradeInSalesTaxTotal;
    }
    
    /**
    * Name: populateTradeInAndSalesTaxOnSku
    * Desc: Method to populate trade in value and sales tax credit amount on stock in unit
    * @param: dealItemRec - Deal_Item__c - Deal Trade In rec
    * @param: unitRec - SObject - stock In unit
    **/
    public static void populateTradeInAndSalesTaxOnSku(Deal_Item__c dealItemRec, SObject unitRec) {
        Decimal agreedValue = (dealItemRec.Agreed_Value__c != null) ? dealItemRec.Agreed_Value__c : 0;
        Decimal salesTaxPercentageOnAgreedValue = (dealItemRec.Default_Unit_Sales_Tax_Percentage__c != null) ? dealItemRec.Default_Unit_Sales_Tax_Percentage__c : 0;
        if(GeneralConfiguration.getTaxIncludingPricing()) {
            unitRec.put('Trade_In_Value__c', (agreedValue / (1 + salesTaxPercentageOnAgreedValue/100)).setScale(2, RoundingMode.HALF_UP));
            unitRec.put('Sales_Tax_Credit__c', (agreedValue - (agreedValue / (1 + salesTaxPercentageOnAgreedValue/100))).setScale(2, RoundingMode.HALF_UP));
        } else {
            unitRec.put('Trade_In_Value__c', agreedValue.setScale(2, RoundingMode.HALF_UP));
            unitRec.put('Sales_Tax_Credit__c', (agreedValue * (salesTaxPercentageOnAgreedValue / 100)).setScale(2, RoundingMode.HALF_UP));
        }
    }
    
    public static List<Deal_Unit_Price_Cost__c> addDealUnitCostPrice(Set<Id> unitIdSet, String dealItemId) {
        return addDealUnitCostPrice(unitIdSet, dealItemId, true);
    }
    
    public static List<Deal_Unit_Price_Cost__c> addDealUnitCostPrice(Set<Id> unitIdSet, String dealItemId, Boolean isBaseOptionNeedsToAdd) {
        Map<String, List<Deal_Unit_Price_Cost__c>> optionTypeToDealUnitPriceCostListMap = new Map<String, List<Deal_Unit_Price_Cost__c>>();
        List<Customer_Owned_Unit__c> unitList = SOQLUtil.getUnitDetails(unitIdSet);
        for(Customer_Owned_Unit__c unitRec : unitList) {
            for(Unit_Price_Cost__c unitPriceCostRec : unitRec.Unit_Prices_Costs__r) {
                if(unitPriceCostRec.Type__c != 'Base' || (isBaseOptionNeedsToAdd && !optionTypeToDealUnitPriceCostListMap.containsKey('Base'))) {
                    Deal_Unit_Price_Cost__c dealUnitPriceCostRec = setFieldsToDealUnitPriceCost(unitPriceCostRec, dealItemId);
                    if(!optionTypeToDealUnitPriceCostListMap.containsKey(dealUnitPriceCostRec.Type__c)) {
                        optionTypeToDealUnitPriceCostListMap.put(dealUnitPriceCostRec.Type__c, new List<Deal_Unit_Price_Cost__c>{});
                    }
                    optionTypeToDealUnitPriceCostListMap.get(dealUnitPriceCostRec.Type__c).add(dealUnitPriceCostRec);
                } else if(isBaseOptionNeedsToAdd) {
                    optionTypeToDealUnitPriceCostListMap.get('Base')[0].Price__c += (unitPriceCostRec.Total_Price__c != null ? unitPriceCostRec.Total_Price__c : 0);
                }
            }
         }
         List<Deal_Unit_Price_Cost__c> dealUnitPriceCostList = new List<Deal_Unit_Price_Cost__c>();
         for(String optionType : optionTypeToDealUnitPriceCostListMap.keySet()) {
            dealUnitPriceCostList.addAll(optionTypeToDealUnitPriceCostListMap.get(optionType));
         }
         return dealUnitPriceCostList; 
    }
    
    public static Deal_Unit_Price_Cost__c setFieldsToDealUnitPriceCost(Unit_Price_Cost__c unitPriceCostRec, String dealItemId) {
        Deal_Unit_Price_Cost__c dealUnitPriceCostRec = new Deal_Unit_Price_Cost__c();
        dealUnitPriceCostRec.Name = unitPriceCostRec.Item_Description__c;
        dealUnitPriceCostRec.Item_Description__c = (unitPriceCostRec.Type__c == 'Base' && unitPriceCostRec.Item_Description__c.equalsIgnoreCase(Constants.CUSTOMER_TRADE_IN)) ? 
                        Constants.BASE_UNIT : unitPriceCostRec.Item_Description__c;
        dealUnitPriceCostRec.Price__c = unitPriceCostRec.Price__c;
        if(GeneralConfiguration.getTaxIncludingPricing()) {
            dealUnitPriceCostRec.Price_When_Tax_Included__c = unitPriceCostRec.Price__c;
        }
        dealUnitPriceCostRec.Type__c = unitPriceCostRec.Type__c;
        if(dealUnitPriceCostRec.Type__c == 'Dealer') {
            dealUnitPriceCostRec.Qty__c = unitPriceCostRec.Qty__c;
        } else {
            dealUnitPriceCostRec.Qty__c = 1;
        }
        
        if(dealUnitPriceCostRec.Type__c == 'Factory' || dealUnitPriceCostRec.Type__c == 'Base') {
            dealUnitPriceCostRec.Price__c = (unitPriceCostRec.Total_Price__c != null ? unitPriceCostRec.Total_Price__c : 0);
        }
        dealUnitPriceCostRec.Deal_Item__c =  dealItemId;
        dealUnitPriceCostRec.Unit_Price_Cost__c = unitPriceCostRec.Id;
        return dealUnitPriceCostRec;
    }
    
    public static Boolean checkForRefreshLinkOnDealUnitPriceCost(String dealItemId, String unitId) {
        Boolean isNeedToRefresh = false;
        if(!AccessControl.ifObjectFieldIsAccessible('Unit_Price_Cost__c')) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Unit_Price_Cost__c> unitPriceAndCostList = 
                [Select Id, (SELECT Id FROM Deal_Unit_Prices_Costs__r WHERE Deal_Item__c =: dealItemId) 
                        FROM Unit_Price_Cost__c 
                        WHERE Customer_Owned_Unit__c =: unitId AND (Type__c = 'Factory' OR Type__c = 'Dealer')];
        for(Unit_Price_Cost__c unitPriceAndCostRec : unitPriceAndCostList) {
            if(unitPriceAndCostRec.Deal_Unit_Prices_Costs__r.size() == 0) {
                isNeedToRefresh = true;
                break;
            }
        }
        return isNeedToRefresh;
    }
    
    public static void refreshDealUnitPriceCost(String dealItemId, String unitId) {
        if(!AccessControl.ifObjectFieldIsAccessible('Deal_Unit_Price_Cost__c')) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(!AccessControl.ifObjectIsDeletable('Deal_Unit_Price_Cost__c')) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(!AccessControl.ifObjectFieldIsCreateable('Deal_Unit_Price_Cost__c')) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(!AccessControl.ifObjectFieldIsAccessible('Deal_Item__c')) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Deal_Unit_Price_Cost__c> existingDealUnitPriceList = [SELECT Id FROM Deal_Unit_Price_Cost__c WHERE Deal_Item__c =: dealItemId AND Type__c != 'Base'];
        if(existingDealUnitPriceList.size() > 0) {
            delete existingDealUnitPriceList;
        }
        
        // Disable Rideaway If ON - To reset pricing
        List<Deal_Item__c> dealItemList = [SELECT Is_Rideaway_Pricing_Enabled__c from Deal_Item__c where Id =: dealItemId];
        if(dealItemList.size() > 0 && dealItemList[0].Is_Rideaway_Pricing_Enabled__c) {
            dealItemList[0].Is_Rideaway_Pricing_Enabled__c = false;
            if(!AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c')) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update dealItemList[0];
        }
        
        List<Deal_Unit_Price_Cost__c> dealUnitPriceListToInsert = addDealUnitCostPrice(new Set<Id>{unitId}, dealItemId, false);
        if(dealUnitPriceListToInsert.size() > 0) {
            insert dealUnitPriceListToInsert;
        }
    }
    
    public static String createDealMerchSection(String dealId, String coHeaderId) {
        List<Deal_Item__c> dealItemList = SOQLUtil.getDealItemDetailsByFieldName(new Map<String, String>{'Deal__c' => dealId,
                                                                                                        'Type__c' => Constants.DEAL_ITEM_TYPE_UNIT});
        Map<Id, Deal_Item__c> dealIdToOptionFeeMap = new Map<Id, Deal_Item__c>();
        for(Deal_Item__c dealItemRec : dealItemList) {
            dealIdToOptionFeeMap.put(dealItemRec.Id, dealItemRec);
        }
        
        List<Deal_Kit_Header__c> dealKHList = SOQLUtil.getDealKitHeaderDetailsByDealItemId(new Set<Id>(dealIdToOptionFeeMap.keySet()));
        Map<Id, Deal_Kit_Header__c> dealKHIdToDKHMap = new Map<Id, Deal_Kit_Header__c>(dealKHList);
        
        List<Option_Fee__c> merchOptionAndFeeList = new List<Option_Fee__c>();
        List<Deal_Kit_Header__c> dealKitHeaderToAddInMerchList = new List<Deal_Kit_Header__c>();

        for(Deal_Item__c dealItemRec : dealItemList) {
            for(Option_Fee__c optionAndFeeRec : dealItemRec.Options_Fees__r) {
                if(optionAndFeeRec.Part__c != null && !optionAndFeeRec.Is_Install__c) {
                    merchOptionAndFeeList.add(optionAndFeeRec);
                }
            }
            
            List<Deal_Kit_Header__c> dkhList = new List<Deal_Kit_Header__c>();
            for(Deal_Kit_Header__c dealKitHeaderRec : dealItemRec.Deal_Kit_Headers__r) {
                if(!dealKitHeaderRec.Is_Install__c && dealKHIdToDKHMap.containsKey(dealKitHeaderRec.Id)) {
                    dealKitHeaderToAddInMerchList.add(dealKHIdToDKHMap.get(dealKitHeaderRec.Id));
                }
            }
        }
        
        List<CO_Line_Item__c> coLineItemListToInsert = new List<CO_Line_Item__c>();
        
        // Non-kit part
        for(Option_Fee__c optionAndFeeRec : merchOptionAndFeeList) {
            CO_Line_Item__c coliRec = CustomerOrderCtrl.setColiFields(optionAndFeeRec, coHeaderId, null, dealId);
            coLineItemListToInsert.add(coliRec);
        }
        
        if(coLineItemListToInsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert coLineItemListToInsert;
        }
        
        // Insert Kit in Merch grid
        List<CO_Kit_Header__c> cokhList = new List<CO_Kit_Header__c>();
        for(Deal_Kit_Header__c dealKitHeaderRec : dealKitHeaderToAddInMerchList) {
            cokhList.add(CustomerOrderCtrl.setCOKitHeaderFields(dealKitHeaderRec, coHeaderId, dealId));
        }
        if(cokhList.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert cokhList;
        }
        
        // Merch grid kit line item
        List<Co_Line_Item__c> coliList = new List<CO_Line_Item__c>();
        for(CO_Kit_Header__c coKitHeaderRec : cokhList) {
            if(dealKHIdToDKHMap.containsKey(coKitHeaderRec.Deal_Kit_Header__c)) {
                for(Option_Fee__c optionAndFeeRec : dealKHIdToDKHMap.get(coKitHeaderRec.Deal_Kit_Header__c).Options_Fees__r) {
                    coliList.add(CustomerOrderCtrl.setColiFields(optionAndFeeRec, coHeaderId, coKitHeaderRec.Id, dealId));
                }
            }
        }
        if(coliList.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Co_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert coliList;
        }
        
        if(GeneralConfiguration.getTaxIncludingPricing()) {
            Map<Id, CO_Kit_Header__c> cokhIdToCokhListMap = new Map<Id, CO_Kit_Header__c>();
            for(CO_Line_Item__c coLineItemRec : coliList) {
                
                Decimal price = 0;
                if(cokhIdToCokhListMap.containsKey(coLineItemRec.CO_Kit_Header__c)) {
                    price = (cokhIdToCokhListMap.get(coLineItemRec.CO_Kit_Header__c).Price__c != null) ? cokhIdToCokhListMap.get(coLineItemRec.CO_Kit_Header__c).Price__c : 0;
                }
                coLineItemRec.Price_When_Tax_Included__c = (coLineItemRec.Price_When_Tax_Included__c != null) ? coLineItemRec.Price_When_Tax_Included__c : 0;
                coLineItemRec.Qty__c = (coLineItemRec.Qty__c != null) ? coLineItemRec.Qty__c : 0;
                price += (coLineItemRec.Price_When_Tax_Included__c * coLineItemRec.Qty__c);
                cokhIdToCokhListMap.put(coLineItemRec.CO_Kit_Header__c, new CO_Kit_Header__c(Id = coLineItemRec.CO_Kit_Header__c, Price__c = price));
            }
            
            if(cokhIdToCokhListMap.keySet().size() > 0) {
                update cokhIdToCokhListMap.values();
            }
        }
        
        List<Option_Fee__c> optionFeeUpdateList = new List<Option_Fee__c>();
        for(CO_Line_Item__c coliRec: coLineItemListToInsert) {
            optionFeeUpdateList.add(new Option_Fee__c(Id = coliRec.Option_Fee__c, CO_Line_Item__c = coliRec.Id));
        }
        
        if(optionFeeUpdateList.size() > 0) {
            BPScriptUtility.disbaleTrigger('OptionAndFeeTrigger');
            update optionFeeUpdateList;
            BPScriptUtility.enableTrigger('OptionAndFeeTrigger');
        }
        return CustomerOrderCtrl.getDealDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('dealMerchandise'));
    }
    
    public static String createDealServiceSection(String dealId, String coHeaderId) {
        List<Deal_Item__c> dealItemList = SOQLUtil.getDealItemDetailsByFieldName(new Map<String, String>{'Deal__c' => dealId,
                                                                                                        'Type__c' => Constants.DEAL_ITEM_TYPE_UNIT});
        Map<Id, Deal_Item__c> dealIdToOptionFeeMap = new Map<Id, Deal_Item__c>();
        Set<Option_Fee__c> optionFeeList = new Set<Option_Fee__c>();
        for(Deal_Item__c dealItemRec : dealItemList) {
            dealIdToOptionFeeMap.put(dealItemRec.Id, dealItemRec);
            optionFeeList.addAll(dealItemRec.Options_Fees__r);
        }
        
        List<Deal_Kit_Header__c> dealKHList = SOQLUtil.getDealKitHeaderDetailsByDealItemId(new Set<Id>(dealIdToOptionFeeMap.keySet()));
        Map<Id, Deal_Kit_Header__c> dealKHIdToDKHMap = new Map<Id, Deal_Kit_Header__c>(dealKHList);
        Map<Id, List<Option_Fee__c>> dealItemIdToDealServiceOptionAndFeeListMap = new Map<Id, List<Option_Fee__c>>();
        Map<Id, List<Deal_Kit_Header__c>> dealItemIdToServiceDKHListMap = new Map<Id, List<Deal_Kit_Header__c>>();

        Set<String> dealItemIdToInsertDealServiceSet = new Set<String>();
        for(Deal_Item__c dealItemRec : dealItemList) {
            List<Option_Fee__c> installedOptionAndFeeRecList = new List<Option_Fee__c>();
            for(Option_Fee__c optionAndFeeRec : dealItemRec.Options_Fees__r) {
                if(optionAndFeeRec.Part__c != null || optionAndFeeRec.Labour_Code__c != null || (optionAndFeeRec.Product__c != null && optionAndFeeRec.Product__r.Type__c == 'Sublet')) {
                    if(optionAndFeeRec.Is_Install__c) { // Deal Service Section
                        installedOptionAndFeeRecList.add(optionAndFeeRec);
                        dealItemIdToDealServiceOptionAndFeeListMap.put(dealItemRec.Id, installedOptionAndFeeRecList);
                        dealItemIdToInsertDealServiceSet.add(dealItemRec.Id);
                    }
                }
            }
            
            List<Deal_Kit_Header__c> dkhList = new List<Deal_Kit_Header__c>();
            for(Deal_Kit_Header__c dealKitHeaderRec : dealItemRec.Deal_Kit_Headers__r) {
                if(dealKitHeaderRec.Is_Install__c && dealKHIdToDKHMap.containsKey(dealKitHeaderRec.Id)) {
                    dkhList.add(dealKHIdToDKHMap.get(dealKitHeaderRec.Id));
                    dealItemIdToServiceDKHListMap.put(dealItemRec.Id, dkhList);
                    dealItemIdToInsertDealServiceSet.add(dealItemRec.Id);
                }
            }
        }
        
        // Insert Line Items q-4
        List<Service_Order_Header__c> soHeaderListToInsert = new List<Service_Order_Header__c>();
        List<Service_Order_Line_Item__c> soliListToInsert = new List<Service_Order_Line_Item__c>();
        
        Integer counter = 1;
        // SOHeader for all required deal items
        for(String dealItemRecId : dealItemIdToInsertDealServiceSet) {
            soHeaderListToInsert.add(CustomerOrderCtrl.setSOHeaderFields(dealItemRecId, coHeaderId, counter, dealId, dealIdToOptionFeeMap.get(dealItemRecId).Customer_Owned_Unit__c));
            counter++;
        }
        if(soHeaderListToInsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert soHeaderListToInsert;
        }       
        
        //Invoice item
        
        //Map to contain DealItem id to so Header id map
        Map<String, String> dealItemIdToSOHeaderIdMap = new Map<String, String>();
        for(Service_Order_Header__c soHeaderRec : soHeaderListToInsert) {
            dealItemIdToSOHeaderIdMap.put(soHeaderRec.Deal_Item__c, soHeaderRec.Id);
        }
        
        //Insert invoice item for so and deal
        List<CO_Invoice_Item__c> coInvoiceItemListToInsert = new List<CO_Invoice_Item__c>();
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Header__c> coInvoiceHeaderList = [Select Id, (Select Id from CO_Invoice_Items__r where Deal__c =: dealId) from CO_Invoice_Header__c where CO_Header__c = :coHeaderId AND Invoice_Status__c = 'Active'];
        if(coInvoiceHeaderList.size() == 0) {
            coInvoiceHeaderList.add(new CO_Invoice_Header__c(CO_Header__c = coHeaderId, Invoice_Status__c = 'Active'));
            if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert coInvoiceHeaderList;
        }
        
        for(Service_Order_Header__c soHeaderRec :  soHeaderListToInsert){
             CO_Invoice_Item__c coInvoiceItemRec = new CO_Invoice_Item__c(CO_Invoice_Header__c = coInvoiceHeaderList[0].Id, isActive__c = true, Is_Invoiceable__c = false, Service_Order_Header__c = soHeaderRec.Id);
             coInvoiceItemListToInsert.add(coInvoiceItemRec);
        }
        if(coInvoiceItemListToInsert.size() > 0){
            if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            upsert coInvoiceItemListToInsert;
        }
        
        List<Service_Order_Kit_Header__c> sokhList = new List<Service_Order_Kit_Header__c>();
        // Non-kit soli and sokit header formation
        for(String dealItemRecId : dealItemIdToInsertDealServiceSet) {
            // Non kit soli
            if(dealItemIdToDealServiceOptionAndFeeListMap.containsKey(dealItemRecId)) {
                for(Option_Fee__c optionFeeRec : dealItemIdToDealServiceOptionAndFeeListMap.get(dealItemRecId)) {
                    if(dealItemIdToSOHeaderIdMap.containsKey(dealItemRecId)) {
                        soliListToInsert.add(CustomerOrderCtrl.setSoliFields(optionFeeRec, dealItemIdToSOHeaderIdMap.get(dealItemRecId), null));
                    }
                }
            }
            // so kit header
            if(dealItemIdToServiceDKHListMap.containsKey(dealItemRecId)) {
                for(Deal_Kit_Header__c dealKitHeaderRec : dealItemIdToServiceDKHListMap.get(dealItemRecId)) {
                    if(dealItemIdToSOHeaderIdMap.containsKey(dealItemRecId)) {
                        sokhList.add(CustomerOrderCtrl.setSOKitHeaderFields(dealKitHeaderRec, dealItemIdToSOHeaderIdMap.get(dealItemRecId), dealId)); 
                    }
                }
            }
        }
        if(sokhList.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert sokhList;
        }
        // so kit line item 
        for(Service_Order_Kit_Header__c soKitHeaderRec : sokhList) {
            if(dealKHIdToDKHMap.containsKey(soKitHeaderRec.Deal_Kit_Header__c)) {
                for(Option_Fee__c optionAndFeeRec : dealKHIdToDKHMap.get(soKitHeaderRec.Deal_Kit_Header__c).Options_Fees__r) {
                    soliListToInsert.add(CustomerOrderCtrl.setSoliFields(optionAndFeeRec, soKitHeaderRec.Service_Order_Header__c, soKitHeaderRec.Id));
                }
            }
        }
        
        if(soliListToInsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert soliListToInsert;
        }
        
        List<Option_Fee__c> optionFeeUpdateList = new List<Option_Fee__c>();
        for(Service_Order_Line_Item__c soliRec: soliListToInsert) {
            optionFeeUpdateList.add(new Option_Fee__c(Id = soliRec.Option_Fee__c, Service_Order_Line_Item__c = soliRec.Id));
        }
        
        if(optionFeeUpdateList.size() > 0) {
            BPScriptUtility.disbaleTrigger('OptionAndFeeTrigger');
            update optionFeeUpdateList;
            BPScriptUtility.enableTrigger('OptionAndFeeTrigger');
        }
        
        if(GeneralConfiguration.getTaxIncludingPricing()) {
            Map<Id, Service_Order_Kit_Header__c> sokhIdToSokhListMap = new Map<Id, Service_Order_Kit_Header__c>();
            for(Service_Order_Line_Item__c soLineItemRec : soliListToInsert) {
                if(String.isNotBlank(soLineItemRec.Service_Order_Kit_Header__c)) {
                    Decimal price = 0;
                    if(sokhIdToSokhListMap.containsKey(soLineItemRec.Service_Order_Kit_Header__c)) {
                        price = (sokhIdToSokhListMap.get(soLineItemRec.Service_Order_Kit_Header__c).Fixed_Price__c != null) ? sokhIdToSokhListMap.get(soLineItemRec.Service_Order_Kit_Header__c).Fixed_Price__c : 0;
                    }
                    soLineItemRec.Price_When_Tax_Included__c = (soLineItemRec.Price_When_Tax_Included__c != null) ? soLineItemRec.Price_When_Tax_Included__c : 0;
                    soLineItemRec.Qty_Needed__c = (soLineItemRec.Qty_Needed__c != null) ? soLineItemRec.Qty_Needed__c : 0;
                    price += (soLineItemRec.Price_When_Tax_Included__c * soLineItemRec.Qty_Needed__c);
                    
                    sokhIdToSokhListMap.put(soLineItemRec.Service_Order_Kit_Header__c, new Service_Order_Kit_Header__c(Id = soLineItemRec.Service_Order_Kit_Header__c, Fixed_Price__c = price));
                }
                
            }
            
            if(sokhIdToSokhListMap.keySet().size() > 0) {
                update sokhIdToSokhListMap.values();
            }
        }
        
        return System.JSON.serialize(new ResponseWrapper('success', 'success'));
    }
    
    public static String setStatusForCommitAndInstallAction(String dealId, String coHeaderId) {
        List<Deal_Item__c> dealItemList = SOQLUtil.getDealItemDetailsByFieldName(new Map<String, String>{'Deal__c' => dealId,
                                                                                                        'Type__c' => Constants.DEAL_ITEM_TYPE_UNIT});
        Set<String> couIdSet = new Set<String>();
        List<Option_Fee__c> optionFeeWithoutKitList = new List<Option_Fee__c>();
        List<Deal_Kit_Header__c> dealKitHeaderList = new List<Deal_Kit_Header__c>();
        for(Deal_Item__c dealItemRec: dealItemList) {
            dealItemRec.Option_And_Fee_Status__c = Constants.COMMITTED;
            couIdSet.add(dealItemRec.Customer_Owned_Unit__c);
            optionFeeWithoutKitList.addAll(dealItemRec.Options_Fees__r);
            dealKitHeaderList.addAll(dealItemRec.Deal_Kit_Headers__r);
        }
        
        if(dealItemList.size() > 0) {
    	    update dealItemList;
    	}
        
        //Insert invoice item for so and deal
        List<CO_Invoice_Item__c> coInvoiceItemListToInsert = new List<CO_Invoice_Item__c>();
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Header__c> coInvoiceHeaderList = [Select Id, (Select Id from CO_Invoice_Items__r where Deal__c =: dealId) from CO_Invoice_Header__c where CO_Header__c = :coHeaderId AND Invoice_Status__c = 'Active'];
        if(coInvoiceHeaderList.size() == 0) {
            coInvoiceHeaderList.add(new CO_Invoice_Header__c(CO_Header__c = coHeaderId, Invoice_Status__c = 'Active'));
            if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert coInvoiceHeaderList;
        }
        
        CO_Invoice_Item__c coInvoiceItem;
        if(coInvoiceHeaderList[0].CO_Invoice_Items__r.size() > 0) {
            coInvoiceItem = coInvoiceHeaderList[0].CO_Invoice_Items__r[0];
        } else {
            coInvoiceItem = new CO_Invoice_Item__c(CO_Invoice_Header__c = coInvoiceHeaderList[0].Id, isActive__c = true, Is_Invoiceable__c = false, Deal__c = dealId);
        }
        
        // Changed according to Ticket #6543 - TK
        Map<String, Boolean> optionNameToOptionValueMap = CustomerOrderCtrl.isDealInvoiceable(dealId);
        coInvoiceItem.Is_Invoiceable__c = optionNameToOptionValueMap.get('Invoiceable');
        coInvoiceItem.isActive__c = optionNameToOptionValueMap.get('Active');
        
        
        String dealStatus = Constants.IN_PROGRESS;
        if(optionFeeWithoutKitList.size() == 0 && dealKitHeaderList.size() == 0) {
            dealStatus = Constants.FULFILLED;
            /*if(!GeneralConfiguration.isLoadNewCustomerOrder() || dealItemList[0].Deal__r.Status__c == 'Approved') {
                coInvoiceItem.isActive__c = true;
                coInvoiceItem.Is_Invoiceable__c = true;
            }*/
        }
        
        coInvoiceItemListToInsert.add(coInvoiceItem);
        if(coInvoiceItemListToInsert.size() > 0){
            if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            upsert coInvoiceItemListToInsert;
        }
        if(AccessControl.ifObjectFieldIsUpdateable('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        //List<SObject> sObjectListToUpdate = new List<SObject>((List<SObject>)dealItemList);
        List<SObject> sObjectListToUpdate = new List<SObject>();
        
        Deal__c dealRec = new Deal__c(Id = dealId, Unit_Status__c = Constants.COMMITTED);
        if(GeneralConfiguration.isLoadNewCustomerOrder()) {
            dealRec.Is_Deal_Fulfilled__c = (dealStatus == Constants.FULFILLED) ? true : false;
        } else {
            dealRec.Status__c = dealStatus;
        }
        sObjectListToUpdate.addAll((List<SObject>)(new List<Deal__c>{dealRec}));
        
        List<Customer_Owned_Unit__c> couList = [SELECT Status__c FROM Customer_Owned_Unit__c WHERE Id IN :couIdSet];
        for(Customer_Owned_Unit__c couRec : couList) {
            if(couRec.Status__c != Constants.ON_ORDER_STATUS) {
                couRec.Status__c = Constants.UNIT_STATUS_RESERVED;
            }
        }
        sObjectListToUpdate.addAll((List<SObject>)couList);
        update sObjectListToUpdate;
        return System.JSON.serialize(new ResponseWrapper('success', 'success'));
    }
    
    public static void populateDealIndividualsCostTotalsAfterFinalize(String coInvoiceId) {
    	List<Deal__c> dealList = [Select Deal_Commission__c, Type__c,
			(Select Qty__c, Fee__r.Cost_Method__c, Fee__r.Cost_Rate__c, Fee__r.Is_Include_In_Profit_Calculation__c,  Product__r.Cost__c, Product__r.Cost_Method__c, 
				Deal_Kit_Header__c, Status__c, Part__c, Part__r.Part_Type__c, Labour_Code__c, Price__c, Per_Item_Cost__c, Product__r.Type__c from Options_Fees__r), 
			(Select Agreed_Value__c, Actual_Cash_Value__c, Default_Unit_Sales_Tax_Percentage__c, Customer_Owned_Unit__c, Type__c from Deal_Items__r),
			(Select Id, Price__c, Vendor_Product__c, Vendor_Product__r.Cost__c, Vendor_Product__r.Cost_Method__c from F_I_Products__r) 
			from Deal__c where Invoice_Number__c =: coInvoiceId];
		
	 	
	 	if(dealList.size() > 0) {
    		Decimal unitCost, tradeInCost, partCost, merchCost, labourCost, subletCost, feeCost, warrantyProductCost, dealProductCost, financingProductCost, thirdPartyProductCost, commissionCost;
    		unitCost = tradeInCost = partCost = merchCost = labourCost = subletCost = feeCost = warrantyProductCost = dealProductCost = financingProductCost = thirdPartyProductCost = commissionCost = 0;
    		
    		Set<Id> skuIdSet = new Set<Id>();
	        for(Deal_Item__c dealItemRec : dealList[0].Deal_Items__r) {
	        	if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_TRADE_IN) {
					dealItemRec.Agreed_Value__c = (dealItemRec.Agreed_Value__c != null) ? dealItemRec.Agreed_Value__c : 0;
					dealItemRec.Actual_Cash_Value__c = (dealItemRec.Actual_Cash_Value__c != null) ? dealItemRec.Actual_Cash_Value__c : 0;
					if(GeneralConfiguration.getTaxIncludingPricing()) {
						dealItemRec.Default_Unit_Sales_Tax_Percentage__c = (dealItemRec.Default_Unit_Sales_Tax_Percentage__c != null) ? dealItemRec.Default_Unit_Sales_Tax_Percentage__c : 0;
						dealItemRec.Agreed_Value__c = (dealItemRec.Agreed_Value__c / (1 + dealItemRec.Default_Unit_Sales_Tax_Percentage__c/100));
					}
					tradeInCost += (dealItemRec.Agreed_Value__c - dealItemRec.Actual_Cash_Value__c).setScale(2, RoundingMode.HALF_UP);
				} else {
					skuIdSet.add(dealItemRec.Customer_Owned_Unit__c);
				}
			}
			
	        unitCost = getUnitCost(skuIdSet);
			//FINANCING PRODUCT COST
			if(dealList[0].Type__c == Constants.FINANCED && dealList[0].F_I_Products__r.size() > 0) {
				for(F_I_Product__c fAndIProductRec : dealList[0].F_I_Products__r) {
					if(fAndIProductRec.Vendor_Product__r.Cost_Method__c == 'Fixed Cost' && fAndIProductRec.Vendor_Product__r.Cost__c != null) {
                        financingProductCost += (fAndIProductRec.Vendor_Product__r.Cost__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(fAndIProductRec.Vendor_Product__r.Cost_Method__c == 'Percent Retail'  && fAndIProductRec.Vendor_Product__r.Cost__c != null) {
                        financingProductCost += ((fAndIProductRec.Price__c * fAndIProductRec.Vendor_Product__r.Cost__c)/100).setScale(2, RoundingMode.HALF_UP);
                    }
				}
			}
			
			//PART COST, 
			for(Option_Fee__c optionFeeRec : dealList[0].Options_Fees__r) {
				optionFeeRec.Price__c = (optionFeeRec.Price__c != null) ? optionFeeRec.Price__c : 0;
    			optionFeeRec.Per_Item_Cost__c = (optionFeeRec.Per_Item_Cost__c != null) ? optionFeeRec.Per_Item_Cost__c : 0;
    			optionFeeRec.Qty__c = (optionFeeRec.Qty__c != null) ? optionFeeRec.Qty__c : 1;
    			
	            if(optionFeeRec.Fee__c != null && optionFeeRec.Fee__r.Is_Include_In_Profit_Calculation__c) {
	                //FEE COST
	                if(optionFeeRec.Deal_Kit_Header__c != null && optionFeeRec.Status__c == Constants.Fulfilled) {
	                    feeCost += (optionFeeRec.Qty__c * optionFeeRec.Per_Item_Cost__c).setScale(2, RoundingMode.HALF_UP);
	                } else {
	                    if(optionFeeRec.Fee__r.Cost_Method__c == 'Fixed Cost' && optionFeeRec.Fee__r.Cost_Rate__c != null) {
	                        feeCost += (optionFeeRec.Qty__c * optionFeeRec.Fee__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
	                    } else if(optionFeeRec.Fee__r.Cost_Method__c == 'Percent Retail' && optionFeeRec.Fee__r.Cost_Rate__c != null) {
	                        feeCost += (optionFeeRec.Qty__c * ((optionFeeRec.Price__c * optionFeeRec.Fee__r.Cost_Rate__c)/100)).setScale(2, RoundingMode.HALF_UP);
	                    }
	                }
	            } else if(optionFeeRec.Product__c != null ) {
	                if(optionFeeRec.Product__r.Type__c == Constants.SUBLET) {
	                	//SUBLET COST
	                	if(optionFeeRec.Status__c == Constants.Fulfilled) {
	            			subletCost += (optionFeeRec.Qty__c * optionFeeRec.Per_Item_Cost__c).setScale(2, RoundingMode.HALF_UP);
	            		} else {
	            			subletCost += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
	            		}
	                } else {
	                	//PRODUCT COST
	                	Decimal cost = 0;
	                    if(optionFeeRec.Product__r.Cost_Method__c == 'Fixed Cost' && optionFeeRec.Product__r.Cost__c != null) {
	                        cost = (optionFeeRec.Qty__c * optionFeeRec.Product__r.Cost__c).setScale(2, RoundingMode.HALF_UP);
	                    } else if(optionFeeRec.Product__r.Cost_Method__c == 'Percent Retail' && optionFeeRec.Product__r.Cost__c != null) {
	                        cost = (optionFeeRec.Qty__c * ((optionFeeRec.Price__c * optionFeeRec.Product__r.Cost__c)/100)).setScale(2, RoundingMode.HALF_UP);
	                    }
	                    if(optionFeeRec.Product__r.Type__c == 'Deal Product') {
	                    	//DEAL PRODUCT COST
	                    	dealProductCost += cost;
	                    } else if(optionFeeRec.Product__r.Type__c == 'Warranty Plan') {
	                    	//WARRANTY PRODUCT COST
	                    	warrantyProductCost += cost;
	                    } else if(optionFeeRec.Product__r.Type__c == 'Financing Product') {
	                    	//FINANCING PRODUCT COST
	                    	financingProductCost += cost;
	                    } else if(optionFeeRec.Product__r.Type__c == 'Third Party') {
	                    	//THIRD PARTY PRODUCT COST
	                    	thirdPartyProductCost += cost;
	                    }
	                    cost = null;
	                }
	            } else if(optionFeeRec.Labour_Code__c != null) {
	            	//LABOUR COST
	            	if(optionFeeRec.Status__c == Constants.Fulfilled) {
            			labourCost += (optionFeeRec.Qty__c * optionFeeRec.Per_Item_Cost__c).setScale(2, RoundingMode.HALF_UP);
            		} else {
            			labourCost += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
            		}
	            } else if(optionFeeRec.Part__c != null) {
	            	if(String.isNotBlank(optionFeeRec.Part__r.Part_Type__c) && optionFeeRec.Part__r.Part_Type__c == 'Merchandise') {
	            		//MERCH COST
	            		if(optionFeeRec.Status__c == Constants.Fulfilled) {
	            			merchCost += (optionFeeRec.Qty__c * optionFeeRec.Per_Item_Cost__c).setScale(2, RoundingMode.HALF_UP);
	            		} else {
	            			merchCost += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
	            		}
	            	} else {
	            		//PART COST
	            		if(optionFeeRec.Status__c == Constants.Fulfilled) {
	            			partCost += (optionFeeRec.Qty__c * optionFeeRec.Per_Item_Cost__c).setScale(2, RoundingMode.HALF_UP);
	            		} else {
	            			partCost += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
	            		}
	            	}
	            }
	        }
	        
	        //COMMISSION COST
	        commissionCost = (dealList[0].Deal_Commission__c != null) ? dealList[0].Deal_Commission__c.setScale(2, RoundingMode.HALF_UP) : 0;
	        
	        dealList[0].Total_Unit_Cost__c = unitCost.setScale(2, RoundingMode.HALF_UP);
	        dealList[0].Total_TradeIn_Cost__c = tradeInCost.setScale(2, RoundingMode.HALF_UP);
	        dealList[0].Total_Part_Cost__c = partCost.setScale(2, RoundingMode.HALF_UP);
	        dealList[0].Total_Merch_Cost__c = merchCost.setScale(2, RoundingMode.HALF_UP);
	        dealList[0].Ttoal_Labour_Cost__c = labourCost.setScale(2, RoundingMode.HALF_UP);
	        dealList[0].Total_Sublet_Cost__c = subletCost.setScale(2, RoundingMode.HALF_UP);
	        dealList[0].Total_Fee_Cost__c = feeCost.setScale(2, RoundingMode.HALF_UP);
	        dealList[0].Total_Warranty_Product_Cost__c = warrantyProductCost.setScale(2, RoundingMode.HALF_UP);
	        dealList[0].Total_Deal_Product_Cost__c = dealProductCost.setScale(2, RoundingMode.HALF_UP);
	        dealList[0].Total_Financing_Product_Cost__c = financingProductCost.setScale(2, RoundingMode.HALF_UP);
	        dealList[0].Total_Third_Party_Product_Cost__c = thirdPartyProductCost.setScale(2, RoundingMode.HALF_UP);
	        dealList[0].Total_Commission_Cost__c = commissionCost.setScale(2, RoundingMode.HALF_UP);
	        
	        update dealList;
    	}
    }
    
    public static List<COHeader> getDealItemInternalServiceStatus(String dealId) {
    	List<Deal_Item__c> dealItemList = [SELECT Customer_Owned_Unit__c FROM Deal_Item__c WHERE Deal__r.Id =: dealId AND Type__c = 'Unit'];
    	set<Id> customerOwnedUnitIds = new set<Id>();
    	for(Deal_Item__c dealItemRec : dealItemList) {
    		customerOwnedUnitIds.add(dealItemRec.Customer_Owned_Unit__c);
    	}
    	List<Service_Order_Header__c> serviceOrderHeaderList = [SELECT Work_Status__c, Invoice_Number__c, CO_Header__r.Id,CO_Header__r.Name FROM Service_Order_Header__c where Customer_Owned_Unit__r.Id IN: customerOwnedUnitIds AND CO_Header__r.CO_Type__c = 'Internal Service'];
    	List<COHeader> cOHeaderList = new List<COHeader>();
    	for(Service_Order_Header__c serviceOrderHeaderRec : serviceOrderHeaderList) {
    		if(serviceOrderHeaderRec.Invoice_Number__c == null && serviceOrderHeaderRec.Work_Status__c != 'Invoiced') {
    			cOHeaderList.add(new COHeader(serviceOrderHeaderRec.CO_Header__r.Id,serviceOrderHeaderRec.CO_Header__r.Name));
    		}
    	}
    	return cOHeaderList;
    }
    
    private static Decimal getUnitCost(Set<Id> skuIdSet) {
    	List<Unit_Price_Cost__c> upcList = [Select Id, Total_Cost__c from Unit_Price_Cost__c where Customer_Owned_Unit__c IN: skuIdSet];
    	Decimal unitCost = 0;
		for(Unit_Price_Cost__c upcRec : upcList) {
			unitCost += (upcRec.Total_Cost__c != null) ? upcRec.Total_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0;
        }
        
        List<Service_Order_Line_Item__c> soliList = [Select Qty_Needed__c, Kit_Price__c from Service_Order_Line_Item__c 
        							where Service_Order_Header__r.Customer_Owned_Unit__c IN: skuIdSet 
				        			AND Service_Order_Header__r.Work_Status__c != 'Invoiced' AND Service_Order_Header__r.Invoice_Number__c = null 
				        			AND Service_Order_Header__r.Transaction_Type__r.Type__c = 'Stock Unit'];
		for(Service_Order_Line_Item__c soliRec : soliList) {
			unitCost += (soliRec.Qty_Needed__c != null && soliRec.Kit_Price__c != null) ? (soliRec.Qty_Needed__c * soliRec.Kit_Price__c) : 0;
		}
        return unitCost;
    }
    
    public static void saveTemporaryUnit(String dealId, String jSONString) {
    	if(AccessControl.ifObjectFieldIsCreateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        DealItem dealItemObj = DealItem.parse(jSONString);
        dealItemObj.Type = Constants.DEAL_ITEM_TYPE_UNIT;
        
        Deal_Item__c dealItemRec = CustomerOrderCtrl.setDealItemValues(dealItemObj, dealId);
        if(dealItemObj.Make == null && String.isNotBlank(dealItemObj.MakeName)) {
            Unit_Make__c makeRec = new Unit_Make__c(Name = dealItemObj.MakeName);
            insert makeRec;
            dealItemRec.Unit_Make__c = makeRec.Id;
        }
        if(dealItemObj.Model == null && String.isNotBlank(dealItemObj.ModelName)) { 
            Unit_Model__c modelRec = new Unit_Model__c(Name__c = dealItemObj.ModelName, Unit_Make__c = dealItemRec.Unit_Make__c);
            insert modelRec;
            dealItemRec.Unit_Model__c = modelRec.Id;
        }
        
        if(dealItemObj.SubModel == null && String.isNotBlank(dealItemObj.SubModelName)) { 
            Unit_Sub_Model__c subModelRec = new Unit_Sub_Model__c(Sub_Model_Name__c = dealItemObj.SubModelName, Unit_Model__c = dealItemRec.Unit_Model__c);
            insert subModelRec;
            dealItemRec.Sub_Model__c = subModelRec.Id;
        }
        
        Boolean isAddLinkedFees = true;
        if(String.isNotBlank(dealItemRec.Id)) {
            List<Deal_Item__c> dealItemRecList = [Select Id, Customer_Owned_Unit__c, Unit_Make__c from Deal_Item__c where Id =: dealItemRec.Id];
            if(dealItemRecList.size() > 0 && (String.isNotBlank(dealItemRecList[0].Unit_Make__c) || String.isNotBlank(dealItemRecList[0].Customer_Owned_Unit__c))) {
                isAddLinkedFees = false;
            }
        }
        
        dealItemRec.Option_And_Fee_Status__c = Constants.UNCOMIITTED;
        upsert dealItemRec;
        if(isAddLinkedFees && String.isNotBlank(dealItemRec.Unit_Make__c)) {
            List<SObject> sObjectListToInsert = CustomerOrderCtrl.addLinkedFee(dealItemRec.Id, dealId, 'Deal');
            if(sObjectListToInsert != null) {
                insert sObjectListToInsert;
            }
        }
        
        CustomerOrderCtrl.updateStatusForDeal(dealId);
    }
}