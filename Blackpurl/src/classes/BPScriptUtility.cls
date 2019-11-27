/**
 * Author: Tarun Khandelwal
 * Since: May 21, 2018
 * Name: BPScriptUtility
 * Description: Apex class for all scripts
**/
global class BPScriptUtility {
    global static void updateStatusAndTotalsForMerchSectionOnCOHeader() {
        disbaleTrigger('COTrigger');
        List<CO_Line_Item__c> coliList = [Select Id, CO_Header__c from CO_Line_Item__c where CO_Header__r.Parts_And_Accessories_Tax_Amount__c = null AND Is_In_Merch_Section__c = true limit: SOQLUtil.getAvailableQueryRowsLimit()];
        Set<Id> coHeaderIdSet = new Set<Id>();
        for(CO_Line_Item__c coliRec : coliList) {
            coHeaderIdSet.add(coliRec.CO_Header__c);
        }
        List<CO_Header__c> coHeaderListToUpdate = COLineItemTriggerHelper.updateStatusAndTotalsForMerchSectionOnCOHeader(coHeaderIdSet);
        if(coHeaderListToUpdate.size() > 0) {
            Database.update(coHeaderListToUpdate, false);
        }
        enableTrigger('COTrigger');
    }
    
    global void populateFieldsOnInvoice() {
        disbaleTrigger('COInvoiceTrigger');
        List<CO_Invoice_Header__c> coInvoiceList = [Select Id from CO_Invoice_Header__c limit: SOQLUtil.getAvailableQueryRowsLimit()];
        for(CO_Invoice_Header__c coInvoiceRec : coInvoiceList) {
            populateFieldsOnInvoiceById(coInvoiceRec.Id);
        }
        enableTrigger('COInvoiceTrigger');
    }
    
    global static void populateTotalFieldsOnDealAndDealItem() {
    	populateTotalFieldsOnDealAndDealItem(null);
    }
    
    global static void populateTotalFieldsOnDealAndDealItem(Integer recLimit) {
    	recLimit = (recLimit != null ? recLimit : SOQLUtil.getAvailableQueryRowsLimit());
    	OptionAndFeeTriggerHelper.isRunningScript = true;
        List<Deal__c> dealList = [Select Id from Deal__c where Sales_Tax_Total__c = null OR Pre_Tax_Unit_Price_And_Cost_Total__c = null limit: recLimit];
        Set<String> dealIdSet = new Set<String>();
        for(Deal__c dealRec : dealList) {
            dealIdSet.add(dealRec.Id);
        }
        BPScriptUtility.disbaleTrigger('DealTrigger');
        OptionAndFeeTriggerHelper.updateDealTotal(dealIdSet);
        BPScriptUtility.enableTrigger('DealTrigger');
    }
    
    global void populateFieldsOnInvoiceById(Id customerInvoiceId) {
        COService.populateFieldsOnInvoice_future(customerInvoiceId);
    }
    
    global static void shopSettingConfigScript() {
        List<Shop_Settings__c> shopSettingConfigList = new List<Shop_Settings__c>();
        
        shopSettingConfigList.add(new Shop_Settings__c(Name = 'Sunday', Day__c = 'Sunday', Is_Working__c = false, From_Time__c = '8:00AM', To_Time__c = '5:00PM'));
        shopSettingConfigList.add(new Shop_Settings__c(Name = 'Monday', Day__c = 'Monday', Is_Working__c = true, From_Time__c = '8:00AM', To_Time__c = '5:00PM'));
        shopSettingConfigList.add(new Shop_Settings__c(Name = 'Tuesday', Day__c = 'Tuesday', Is_Working__c = true, From_Time__c = '8:00AM', To_Time__c = '5:00PM'));
        shopSettingConfigList.add(new Shop_Settings__c(Name = 'Wednesday', Day__c = 'Wednesday', Is_Working__c = true, From_Time__c = '8:00AM', To_Time__c = '5:00PM'));
        shopSettingConfigList.add(new Shop_Settings__c(Name = 'Thursday', Day__c = 'Thursday', Is_Working__c = true, From_Time__c = '8:00AM', To_Time__c = '5:00PM'));
        shopSettingConfigList.add(new Shop_Settings__c(Name = 'Friday', Day__c = 'Friday', Is_Working__c = true, From_Time__c = '8:00AM', To_Time__c = '5:00PM'));
        shopSettingConfigList.add(new Shop_Settings__c(Name = 'Saturday', Day__c = 'Saturday', Is_Working__c = false, From_Time__c = '8:00AM', To_Time__c = '5:00PM'));
        
        upsert shopSettingConfigList;
    }
    
    // Trigger Disable
    global static void disbaleTrigger(String triggerName) {
        if(AccessControl.ifObjectFieldIsCreateable('Trigger_Soft_Disable__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        Trigger_Soft_Disable__c triggerToDisable = new Trigger_Soft_Disable__c();
        triggerToDisable.Name = triggerName;
        triggerToDisable.Disable_Delete__c = triggerToDisable.Disable_Insert__c = triggerToDisable.Disable_Undelete__c = true;
        triggerToDisable.Disable_Update__c = true;
        insert triggerToDisable;
    }
    
    global static void enableTrigger(String triggerName) {
        if(AccessControl.ifObjectIsDeletable('Trigger_Soft_Disable__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        delete [Select Id from Trigger_Soft_Disable__c where Name =: triggerName];
    }
    
    global void populateDealOptionsWIPCostOnUnit() {
        disbaleTrigger('CustomerOwnedUnitTrigger');
        List<Customer_Owned_Unit__c> unitList = [SELECT Id FROM Customer_Owned_Unit__c limit: SOQLUtil.getAvailableQueryRowsLimit()];
        for(Customer_Owned_Unit__c unitRec: unitList) {
            unitRec.Deal_Options_WIP__c = 0;
        }
        if(unitList.size() > 0) {
            update unitList;
        }
        enableTrigger('CustomerOwnedUnitTrigger');
    }
    
    @future
    global static void updateUnitPricesAndCostsForInvoiceDeal() {
        String query = 'Select Id, Customer_Owned_Unit__c, (Select Id,Item_Description__c, Qty__c, '+
                                                            'Price__c, Total_Price__c, Type__c,Tax_Percent__c, '+
                                                            'Sales_Tax_Percentage__c, Unit_Price_Cost__c, '+
                                                            'Price_When_Tax_Included__c from Deal_Unit_Prices_Costs__r) from Deal_Item__c '+
                                                             'where Deal__r.Status__c = \'Invoiced\' AND Type__c = \'Unit\'';
        List<Deal_Item__c> dealItemList = Database.query(query); 
        updateUnitPriceAndCost(dealItemList);
    }
    
    global static void updateUnitPricesAndCostsForInvoiceDeal(Set<String> dealItemIdSet) {
        String query = 'Select Id, Customer_Owned_Unit__c, (Select Id,Item_Description__c, Qty__c, '+
                                                            'Price__c, Total_Price__c, Type__c,Tax_Percent__c, '+
                                                            'Sales_Tax_Percentage__c, Unit_Price_Cost__c, '+
                                                            'Price_When_Tax_Included__c from Deal_Unit_Prices_Costs__r) from Deal_Item__c '+
                                                             'where Deal__r.Status__c = \'Invoiced\' AND Type__c = \'Unit\'';
        query += ((dealItemIdSet != null && dealItemIdSet.size() > 0) ? ' AND Id IN: dealItemIdSet' : '');
        List<Deal_Item__c> dealItemList = Database.query(query);
        updateUnitPriceAndCost(dealItemList);
    }
    
    public static void updateUnitPriceAndCost(List<Deal_Item__c> dealItemList) {
        Map<String, Unit_Price_Cost__c> idTounitPriceAndCostRecMap = new Map<String, Unit_Price_Cost__c>();
        Map<String, Decimal> skuIdToBasePriceMap = new Map<String, Decimal>();
        
        for(Deal_Item__c dealItem : dealItemList) {
            for(Deal_Unit_Price_Cost__c rec : dealItem.Deal_Unit_Prices_Costs__r) {
                if(rec.Type__c == 'Base') {
                    skuIdToBasePriceMap.put(dealItem.Customer_Owned_Unit__c , rec.Price__c);
                    continue;
                }
                Unit_Price_Cost__c unitPriceAndCostRec = new Unit_Price_Cost__c(Id = rec.Unit_Price_Cost__c, Price__c = rec.Price__c);
            
                if(rec.Type__c == 'Base' || rec.Type__c == 'Factory') {
                    unitPriceAndCostRec.Total_Price__c = rec.Price__c;
                } else {
                    rec.Qty__c = (rec.Qty__c != null && rec.Qty__c != 0) ? rec.Qty__c : 1;
                    rec.Price__c = (rec.Price__c != null) ? rec.Price__c : 0;
                    unitPriceAndCostRec.Total_Price__c = (rec.Price__c.setScale(2, RoundingMode.HALF_UP) * rec.Qty__c);
                }
                idTounitPriceAndCostRecMap.put(unitPriceAndCostRec.Id, unitPriceAndCostRec);
            }
        }
        
        List<Customer_Owned_Unit__c> skuList = [Select Id,(Select Id, Total_Price__c, Price__c from Unit_Prices_Costs__r where Type__c = 'Base' Order By CreatedDate ASC) from Customer_Owned_Unit__C where Id IN: skuIdToBasePriceMap.keySet()];
        
        for(Customer_Owned_Unit__C skuRec : skuList) {
            for(Integer i = 0; i < skuRec.Unit_Prices_Costs__r.size(); i++) {
                if(i == 0) {
                    skuRec.Unit_Prices_Costs__r[i].Total_Price__c = skuRec.Unit_Prices_Costs__r[i].Price__c = (skuIdToBasePriceMap.containsKey(skuRec.Id) ? 
                                    skuIdToBasePriceMap.get(skuRec.Id) : 0);
                    idTounitPriceAndCostRecMap.put(skuRec.Unit_Prices_Costs__r[i].Id, skuRec.Unit_Prices_Costs__r[i]);
                } else {
                    skuRec.Unit_Prices_Costs__r[i].Total_Price__c = skuRec.Unit_Prices_Costs__r[i].Price__c = 0;
                    idTounitPriceAndCostRecMap.put(skuRec.Unit_Prices_Costs__r[i].Id, skuRec.Unit_Prices_Costs__r[i]);
                }
            }
        }
        
        update idTounitPriceAndCostRecMap.values(); 
    }
    
    global static void populateRetailPriceOnKitLineItems() {
        disbaleTrigger('KitLineItemtrigger');
        List<Kit_Header_Line_Item__c> khliList = [Select Part__c, Labour_Code__c, Fee__c, Retail_Price__c from Kit_Header_Line_Item__c limit: SOQLUtil.getAvailableQueryRowsLimit()];
        KitLineItemtriggerHelper.setRetailPriceBasedOnDefaultPriceLevel(khliList);
        if(khliList.size() > 0) {
            update khliList;
        }
        enableTrigger('KitLineItemtrigger');
    }
    
    global static void updateUnitInvServiceJobTransactionType() {
        disbaleTrigger('SOTrigger');
        
        List<Co_Header__c> coHeaderList = [Select Id, (Select Id from Service_Order_Headers__r) from Co_Header__c where CO_Type__c = 'Internal Service'];
        List<Transaction_Type__c> ttList = [Select Id from Transaction_Type__c where Type__c = 'Stock Unit'];
        if(ttList.size() != 1) {
            ttList.add(new Transaction_Type__c(Code__c = 'Unit Inventory', Type__c = 'Stock Unit', Code_Label__c = 'Unit Inventory', Default__c = true, Active__c = true));
            insert ttList;
        }
        List<Service_Order_Header__c> soList = new List<Service_Order_Header__c>();
        for(Co_Header__c coRec : coHeaderList) {
            for(Service_Order_Header__c soRec : coRec.Service_Order_Headers__r) {
                soRec.Transaction_Type__c = ttList[0].Id;
                soList.add(soRec);
            }
        }
        update soList;
        enableTrigger('SOTrigger');
    }
    
    global static void upsertTransactionTypes() {
        List<Transaction_Type__c> ttList  = [Select Id, Type__c, Active__c, Default__c from Transaction_Type__c limit :SOQLUtil.getAvailableQueryRowsLimit()];
        Boolean isStockUnitExists = false;
        for(Transaction_Type__c tt : ttList) {
            tt.Active__c = true;
            tt.Default__c = true;
            if(tt.Type__c == 'Stock Unit') {
                isStockUnitExists = true;
                continue;
            }
            if(tt.Type__c == 'Customer') {
                tt.Code_Label__c = 'Customer Pay';
            } else if(tt.Type__c == 'Third-Party') {
                tt.Code_Label__c = 'Third-Party';
            } else if(tt.Type__c == 'Internal') {
                tt.Code_Label__c = 'Internal Expense';
            } else if(tt.Type__c == 'Deal') {
                tt.Code_Label__c = 'Deal';
                tt.Type__c = 'Deal Service';
            }
        }
        if(!isStockUnitExists) {
            ttList.add(new Transaction_Type__c(Code__c = 'Unit Inventory', Type__c = 'Stock Unit', Code_Label__c = 'Unit Inventory', Default__c = true, Active__c = true));
        }
        upsert ttList;
    }
    
    global static void insertFusionLineItems() {
        new FusionBenchMarking().insertLineItems();
    }
    
    global static void updateTradeInActualCashValue() {
        disbaleTrigger('DealItemTrigger');
        List<Deal_Item__c> tradeInList = [SELECT Id, Agreed_Value__c, Actual_Cash_Value__c FROM Deal_Item__c WHERE Type__c = 'Trade In' AND Actual_Cash_Value__c = null];
        for(Deal_Item__c dealItemRec: tradeInList) {
            dealItemRec.Actual_Cash_Value__c = dealItemRec.Agreed_Value__c;
        }
        update tradeInList;
        enableTrigger('DealItemTrigger');
    }
    
    global static void updateTradeInActualCashValueForAusOn() {
        disbaleTrigger('DealItemTrigger');
        List<Deal_Item__c> tradeInList = [SELECT Id, Agreed_Value__c, Actual_Cash_Value__c, Default_Unit_Sales_Tax_Percentage__c FROM Deal_Item__c WHERE Type__c = 'Trade In' AND Actual_Cash_Value__c = null];
        for(Deal_Item__c dealItemRec: tradeInList) {
            Decimal taxPercentage = (dealItemRec.Default_Unit_Sales_Tax_Percentage__c != null) ? dealItemRec.Default_Unit_Sales_Tax_Percentage__c : 0;
            if(dealItemRec.Agreed_Value__c != null) {
                dealItemRec.Actual_Cash_Value__c = (dealItemRec.Agreed_Value__c / (1 + (taxPercentage / 100))).setScale(2, RoundingMode.HALF_UP);
            }
        }
        update tradeInList;
        enableTrigger('DealItemTrigger');
    }
    
    global static void updateSubletSoliAndCreateVoliForOpenCO() {
        disbaleTrigger('ServiceOrderLineItemTrigger');
        disbaleTrigger('VendorOrderLineItemTrigger');
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Line_Item__c> soliList = [SELECT Id, Sublet__c, Service_Order_Header__r.Work_Status__c, CO_Status__c, Qty_Needed__c, Qty_Committed__c, 
                                                        CO_Header_Id__c, Service_Order_Header__r.CO_Header__r.CO_Type__c FROM Service_Order_Line_Item__c 
                                                        WHERE Sublet__c != null AND Sublet__r.Type__c = 'Sublet' AND Service_Order_Header__r.Work_Status__c != 'Complete' 
                                                        AND Service_Order_Header__r.Work_Status__c != 'Invoiced']; 
        for(Service_Order_Line_Item__c soliRec : soliList) {
            soliRec.Status__c = 'Required';
            soliRec.Qty_Committed__c = 0;
        } 
        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Database.update(soliList, false);
        insertVOLIForOpenCO(soliList);
        enableTrigger('ServiceOrderLineItemTrigger');
        enableTrigger('VendorOrderLineItemTrigger');
    }
    
    private static void insertVOLIForOpenCO(List<Service_Order_Line_Item__c> soliList) {
        if(AccessControl.ifObjectFieldIsAccessible('Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Set<Id> subletIdSet = new Set<Id>();
        for(Service_Order_Line_Item__c soLineItemRec : soliList) {
            if(soLineItemRec.Sublet__c != null) {
                subletIdSet.add(soLineItemRec.Sublet__c);
            } 
        }
        
        Map<Id, Product__c> subletIdToSubletRecordMap = new Map<Id, Product__c>([SELECT Id, Code__c, Cost_Method__c, Cost__c, Applicable_Tax__c, 
                                                                        CreatedDate__c, Deductible__c, 
                                                                        Description__c, Price__c, Product_Unique_Name__c, Status__c, Vendor__r.Name
                                                                        from Product__c where Id IN : subletIdSet]);
        
        List<Vendor_Order_Line_Item__c> voLineItemsToUpsert = new List<Vendor_Order_Line_Item__c>();
        Vendor_Order_Line_Item__c voLineItemRec;
        List<Service_Order_Line_Item__c> soLineItemListToUpdate = new List<Service_Order_Line_Item__c>();
        for(Service_Order_Line_Item__c soLineItemRec : soliList) {
            voLineItemRec = new Vendor_Order_Line_Item__c();
            if(soLineItemRec.Sublet__c != null && soLineItemRec.Qty_Needed__c > soLineItemRec.Qty_Committed__c) {
                voLineItemRec.CO_Header__c = soLineItemRec.CO_Header_Id__c;
                voLineItemRec.Service_Order_Line_Item__c = soLineItemRec.Id;
                voLineItemRec.Sublet__c = soLineItemRec.Sublet__c;
                voLineItemRec.Qty_Needed__c = soLineItemRec.Qty_Needed__c - soLineItemRec.Qty_Committed__c;
                voLineItemRec.Is_Service__c = true;
                
                if(subletIdToSubletRecordMap.containsKey(soLineItemRec.Sublet__c)) {
                    if(subletIdToSubletRecordMap.get(voLineItemRec.Sublet__c).Cost_Method__c == 'Fixed Cost' && subletIdToSubletRecordMap.get(voLineItemRec.Sublet__c).Cost__c != null){
                        voLineItemRec.Line_Item_Cost__c = subletIdToSubletRecordMap.get(voLineItemRec.Sublet__c).Cost__c.setScale(2, RoundingMode.HALF_UP);
                    } else if(subletIdToSubletRecordMap.get(voLineItemRec.Sublet__c).Cost_Method__c == 'Percent Retail' && subletIdToSubletRecordMap.get(voLineItemRec.Sublet__c).Cost__c != null) {
                        soLineItemRec.Kit_Price__c = (soLineItemRec.Kit_Price__c != null) ? soLineItemRec.Kit_Price__c : 0;
                        voLineItemRec.Line_Item_Cost__c = ((soLineItemRec.Kit_Price__c *  subletIdToSubletRecordMap.get(voLineItemRec.Sublet__c).Cost__c)/100).setScale(2, RoundingMode.HALF_UP);
                    }
                }
                voLineItemsToUpsert.add(voLineItemRec);
            }
        }
        
        if(voLineItemsToUpsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert voLineItemsToUpsert;
        }
    }
    
    global static void updateTaxAndTotalForDealWithTradeIn() {
        Set<Id> dealIdSet = new Set<Id>();
        List<Deal_Item__c> dealItemList = [SELECT Id, Deal__c FROM Deal_Item__c WHERE Type__c = 'Trade In' AND Deal__r.Status__c = 'Invoiced'];
        for(Deal_Item__c dealItemRec: dealItemList) {
            dealIdSet.add(dealItemRec.Deal__c);
        }
        
        List<CO_Invoice_Header__c> coInvList = [SELECT SalesTax_Total__c, Part_Total__c, Labour_Total__c, Fee_Total__c, Stamp_Duty_Total__c, Unit_Total__c, Shop_Supplies_Total__c, Trade_In_Total__c, Product_Total__c, F_I_Total__c, Deductible_Total__c, Total__c, Name, Total_Payment__c, CO_Header__r.Customer__r.Total_Store_Credit__c, Invoice_Status__c, CO_Header__r.Order_Status__c,
                                                  (SELECT CO_invoice_Header__c,isActive__c, CO_Line_Item__c, Service_Order_Header__c, CO_Kit_Header__c, Deal__c, SO_Payment_Role__c, SO_Payment_Role__r.RecordType.DeveloperName 
                                                    FROM CO_Invoice_Items__r WHERE isActive__c = true AND (Deal__c != null) AND Deal__c IN :dealIdSet) FROM CO_invoice_Header__C where Id IN (SELECT CO_invoice_Header__c 
                                                    FROM CO_Invoice_Item__c where Deal__c != null AND Deal__c IN : dealIdSet)];
        
        Boolean IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Map<Id, Id> dealIdToCOInvIdMap = new Map<Id, Id>();
        for(CO_Invoice_Header__c coInvoice: coInvList) {
            if(coInvoice.CO_Invoice_Items__r.size() > 0) {
                dealIdToCOInvIdMap.put(coInvoice.CO_Invoice_Items__r[0].Deal__c, coInvoice.Id);
            }
        }
        
        Map<Id, List<Individual_Tax__c>> coInvIdToIndividualTaxListMap = new Map<Id, List<Individual_Tax__c>>();
        String query = 'SELECT CO_Line_Item__c, Tax_Rate__c, Form_Label__c, Sales_Tax_Item_Name__c, Tax_Amount__c, Taxable_Amount__c, ' +
                        'Applicable_Tax__c, List_Tax_items_on_forms__c, Option_Fee__c, Option_Fee__r.Deal__c, Deal_Unit_Price_Cost__c, Deal_Unit_Price_Cost__r.Deal_Item__c, ' +
                        'Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c, F_I_Product__c, F_I_Product__r.Deal_Finance__c, F_I_Product__r.Deal_Finance__r.Deal__c, ' +
                        'Deal_Item__c, Deal_Item__r.Deal__c from Individual_Tax__c' + 
                        ' WHERE Option_Fee__r.Deal__c IN: dealIdSet OR ' +
                        'Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c IN: dealIdSet OR F_I_Product__r.Deal_Finance__r.Deal__c IN: dealIdSet '+
                        'OR (Deal_Item__r.Deal__c IN: dealIdSet AND Deal_Item__r.Type__c = \'Trade In\')';
            
        List<Individual_Tax__c> individualTaxItemsList = Database.query(query);
        for(Individual_Tax__c idividualTaxItem: individualTaxItemsList) {
            Id coInvId;
            if(idividualTaxItem.Option_Fee__c != null) {
                coInvId = dealIdToCOInvIdMap.get(idividualTaxItem.Option_Fee__r.Deal__c);
            } else if(idividualTaxItem.Deal_Unit_Price_Cost__c != null && idividualTaxItem.Deal_Unit_Price_Cost__r.Deal_Item__c != null) {
                coInvId = dealIdToCOInvIdMap.get(idividualTaxItem.Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c);
            } else if(idividualTaxItem.F_I_Product__c != null && idividualTaxItem.F_I_Product__r.Deal_Finance__c != null) {
                coInvId = dealIdToCOInvIdMap.get(idividualTaxItem.F_I_Product__r.Deal_Finance__r.Deal__c);
            } else if(idividualTaxItem.Deal_Item__c != null) {
                coInvId = dealIdToCOInvIdMap.get(idividualTaxItem.Deal_Item__r.Deal__c);
            }
            
            if(!coInvIdToIndividualTaxListMap.ContainsKey(coInvId)) {
                coInvIdToIndividualTaxListMap.Put(coInvId,new List<Individual_Tax__c>());
            }
            coInvIdToIndividualTaxListMap.get(coInvId).add(idividualTaxItem);
        }
        for(CO_Invoice_Header__c coInvoice: coInvList) {
            List<Id> dealIds = new List<Id>();
            for(CO_Invoice_Item__c coInvoiceItem : coInvoice.CO_Invoice_Items__r) {
                if(coInvoiceItem.Deal__c != null) {
                    dealIds.add(coInvoiceItem.Deal__c);
                }
            }
            
            Decimal salesTaxTotal = 0;
            Boolean isInvoiced = (coInvoice.Invoice_Status__c == 'Active') ? false : true;
            List<Individual_Tax__c> individualItemsList = coInvIdToIndividualTaxListMap.containsKey(coInvoice.Id) ? coInvIdToIndividualTaxListMap.get(coInvoice.Id) : new List<Individual_Tax__c>();
            Map<String, Decimal> salesTaxNameToTaxValue = TaxCalculation.getTaxAmountWithFormLabel(individualItemsList);    
            for(String taxName : salesTaxNameToTaxValue.keySet()) {
                salesTaxTotal += salesTaxNameToTaxValue.get(taxName); 
            }
            coInvoice.SalesTax_Total__c = salesTaxTotal.setScale(2, RoundingMode.HALF_UP);
            
            if(!isTaxIncludingPricing) {
                coInvoice.Part_Total__c = coInvoice.Part_Total__c != null ? coInvoice.Part_Total__c : 0;
                coInvoice.Labour_Total__c = coInvoice.Labour_Total__c != null ? coInvoice.Labour_Total__c : 0;
                coInvoice.Fee_Total__c = coInvoice.Fee_Total__c != null ? coInvoice.Fee_Total__c : 0;
                coInvoice.Stamp_Duty_Total__c = coInvoice.Stamp_Duty_Total__c != null ? coInvoice.Stamp_Duty_Total__c : 0;
                coInvoice.Unit_Total__c = coInvoice.Unit_Total__c != null ? coInvoice.Unit_Total__c : 0;
                coInvoice.Shop_Supplies_Total__c = coInvoice.Shop_Supplies_Total__c != null ? coInvoice.Shop_Supplies_Total__c : 0;
                
                coInvoice.Trade_In_Total__c = coInvoice.Trade_In_Total__c != null ? coInvoice.Trade_In_Total__c : 0;
                coInvoice.Product_Total__c = coInvoice.Product_Total__c != null ? coInvoice.Product_Total__c : 0;
                
                coInvoice.F_I_Total__c = coInvoice.F_I_Total__c != null ? coInvoice.F_I_Total__c : 0;
                coInvoice.Deductible_Total__c = coInvoice.Deductible_Total__c != null ? coInvoice.Deductible_Total__c : 0;
                
                coInvoice.Total__c = coInvoice.Part_Total__c + coInvoice.Labour_Total__c + coInvoice.Fee_Total__c + coInvoice.Unit_Total__c + coInvoice.Trade_In_Total__c 
                                            + coInvoice.Product_Total__c + coInvoice.Stamp_Duty_Total__c + coInvoice.Shop_Supplies_Total__c + coInvoice.Deductible_Total__c + coInvoice.F_I_Total__c;
                coInvoice.Total__c += coInvoice.SalesTax_Total__c;
            }
        }
        update coInvList;
    }
    
    global static void populateSOHeaderOnExistingAppointments() {
        List<Event> coAssignedEventList = [SELECT Id, CO_Header__c, Service_Order_Header__c FROM Event WHERE CO_Header__c != null];
        Map<String, List<Event>> coHeaderIdToEventListMap = new Map<String, List<Event>>();
        List<Event> eventList;
        for(Event eventRec : coAssignedEventList) {
            if(coHeaderIdToEventListMap.containsKey(eventRec.CO_Header__c)) {
                eventList = coHeaderIdToEventListMap.get(eventRec.CO_Header__c);
                eventList.add(eventRec);
            } else {
                eventList = new List<Event>();
                eventList.add(eventRec);
            }
            coHeaderIdToEventListMap.put(eventRec.CO_Header__c, eventList);
        }
        
        List<CO_Header__c> listOfCOHavingEventList = [SELECT Id, (SELECT Id FROM Service_Order_Headers__r ORDER by CreatedDate ASC LIMIT 1) FROM CO_Header__c WHERE Id IN: coHeaderIdToEventListMap.keySet()];
        List<Event> eventListToUpdate = new List<Event>();
        for(CO_Header__c coRec : listOfCoHavingEventList) {
            if(coHeaderIdToEventListMap.containsKey(coRec.Id) && coRec.Service_Order_Headers__r.size() > 0) {
                for(Event eventRec : coHeaderIdToEventListMap.get(coRec.Id)) {
                    eventRec.Service_Order_Header__c = coRec.Service_Order_Headers__r[0].Id;
                    eventListToUpdate.add(eventRec);
                }
            }
        }
        update eventListToUpdate;
     }
     
     global static void deleteNonDefaultSpecialCategories() {
        List<String> specialCategoryTypeList = new List<String>{'Trade-in', 'Deductible', 'Stamp Duty', 'Lien Payout'};
        if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Category__c> nonDefaultCategoryList = [SELECT Id FROM Category__c WHERE Default__c = false AND Type__c IN :specialCategoryTypeList];
        if(nonDefaultCategoryList.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete nonDefaultCategoryList;
        }
     }
     
     global static void createDefaultSpecialCategories() {
        Map<String, String> categoryNameToTypeMap = new Map<String, String>{'Trade-in' => 'TradeIn Default',
                                                                                'Deductible' => 'Claim Deductible Default',
                                                                                'Stamp Duty' => 'Stamp Duty Default',
                                                                                'Stocked Trade' => 'Stocked Trade Default',
                                                                                'Lien Payout' => 'Lien Payout'
                                                                            };
        if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Category__c> defaultCategoryList = [SELECT Id, Type__c FROM Category__c WHERE Default__c = true AND Active__c = true AND Type__c IN :categoryNameToTypeMap.keySet()];
        
        Set<String> existingSpecialCategorySet = new Set<String>();
        for(Category__c catRec: defaultCategoryList) {
            existingSpecialCategorySet.add(catRec.Type__c);
        }
        
        List<Category__c> categoryListToInsert = new List<Category__c>();
        for(String categoryType: categoryNameToTypeMap.keySet()) {
            if(!existingSpecialCategorySet.contains(categoryType)) {
                categoryListToInsert.add(new Category__c(
                                                    Name=categoryNameToTypeMap.get(categoryType),Description__c=categoryNameToTypeMap.get(categoryType),
                                                    Type__c=categoryType,Default__c=true,Active__c=true
                                                ));
            }
        }
        if(categoryListToInsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert categoryListToInsert;
        }
    }
    
    global static void populatePurchaseTaxOnVendorInvoice() {
        disbaleTrigger('VendorInvoicingHeaderTrigger');
        List<Vendor_Invoicing_Header__c> vendorInvoiceList = [Select Vendor__r.Purchase_Tax__r.Name__c from Vendor_Invoicing_Header__c
                                WHERE Status__c = 'Invoiced'];
        for(Vendor_Invoicing_Header__c vendorInvoiceRec : vendorInvoiceList) {
            vendorInvoiceRec.Applicable_Purchase_Tax_Name__c = vendorInvoiceRec.Vendor__r.Purchase_Tax__r.Name__c;
        }
        if(vendorInvoiceList.size() > 0) {
            update vendorInvoiceList;
        }
        enableTrigger('VendorInvoicingHeaderTrigger');
    }
    
    global static void populateDefaultTTypeOnExistingAppointmentsAndSOUsingJobType() {
        if(AccessControl.ifObjectFieldIsAccessible('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Transaction_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Event> eventList = [SELECT Id, Job_Type__c, Service_Order_Header__c FROM Event limit: SOQLUtil.getAvailableQueryRowsLimit()];
        List<Transaction_Type__c> defaultTTList = [SELECT Id, Type__c, Internal_Category__r.Id, Internal_Category__r.Name, 
                                                    Third_Party_Customer__r.Id, Third_Party_Customer__r.Name 
                                                    FROM Transaction_Type__c WHERE Active__c = true AND Default__c = true];
        Map<String, Transaction_Type__c> ttTypeToTTRecMap = new Map<String, Transaction_Type__c>();
        for(Transaction_Type__c ttRec : defaultTTList) {
            ttTypeToTTRecMap.put(ttRec.Type__c, ttRec);
        }
        List<Category__c> defaultInternalCategory = [SELECT Id, Name, Active__c, Type__c, Default__c FROM Category__c 
                                                    WHERE Type__c =: 'Internal Expense' AND Active__c = true AND Default__c = true];
        List<Service_Order_Header__c> soListToUpdate = new List<Service_Order_Header__c>();
        Set<Id> soIdSet = new Set<Id>();
        Service_Order_Header__c soRec;
        for(Event eventRec : eventList) { 
            soRec = new Service_Order_Header__c(Id = eventRec.Service_Order_Header__c);
            soRec.Provider__c = null;
            soRec.Category__c = null;
            if(eventRec.Job_Type__c == 'Customer Pay') {
                eventRec.Transaction_Type__c = ttTypeToTTRecMap.containsKey('Customer') ? ttTypeToTTRecMap.get('Customer').Id : null;
                soRec.Transaction_Type__c = ttTypeToTTRecMap.containsKey('Customer') ? ttTypeToTTRecMap.get('Customer').Id : null;
            } else if(eventRec.Job_Type__c == 'Internal Expense') {
                eventRec.Transaction_Type__c = ttTypeToTTRecMap.containsKey('Internal') ? ttTypeToTTRecMap.get('Internal').Id : null;
                soRec.Transaction_Type__c = ttTypeToTTRecMap.containsKey('Internal') ? ttTypeToTTRecMap.get('Internal').Id : null;
                soRec.Category__c = ttTypeToTTRecMap.containsKey('Internal') ? ttTypeToTTRecMap.get('Internal').Internal_Category__r.Id : null;
                soRec.Category__c = (soRec.Category__c != null) ? soRec.Category__c : (defaultInternalCategory.size() > 0 ? defaultInternalCategory[0].Id : null);
            } else if(eventRec.Job_Type__c == 'Third-Party') {
                eventRec.Transaction_Type__c = ttTypeToTTRecMap.containsKey('Third-Party') ? ttTypeToTTRecMap.get('Third-Party').Id : null;
                soRec.Transaction_Type__c = ttTypeToTTRecMap.containsKey('Third-Party') ? ttTypeToTTRecMap.get('Third-Party').Id : null;
                soRec.Provider__c = ttTypeToTTRecMap.containsKey('Third-Party') ? ttTypeToTTRecMap.get('Third-Party').Third_Party_Customer__r.Id : null;
            } else if(eventRec.Job_Type__c == 'Deal') {
                eventRec.Transaction_Type__c = ttTypeToTTRecMap.containsKey('Deal Service') ? ttTypeToTTRecMap.get('Deal Service').Id : null;
            } else { 
                eventRec.Transaction_Type__c = ttTypeToTTRecMap.containsKey('Customer') ? ttTypeToTTRecMap.get('Customer').Id : null;
            }
            soListToUpdate.add(soRec);
            soIdSet.add(eventRec.Service_Order_Header__c);
        }
        
        if(eventList.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update eventList;
        }
        
        /**if(soListToUpdate.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update soListToUpdate;
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Line_Item__c> soLineItemListToUpdate = [SELECT Id FROM Service_Order_Line_Item__c WHERE Service_Order_Header__c IN: soIdSet];
        
        if(soLineItemListToUpdate.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update soLineItemListToUpdate;
        }*/
     }
     
     global static void resetVINField() {
        disbaleTrigger('CustomerOwnedUnitTrigger');
        List<Customer_Owned_Unit__c> unitList = [SELECT Id FROM Customer_Owned_Unit__c WHERE VIN_Number__c = 'VIN Unknown'];
        for(Customer_Owned_Unit__c unitRec: unitList) {
            unitRec.VIN_Number__c = null;
        }
        update unitList;
        enableTrigger('CustomerOwnedUnitTrigger');
    }
    
    global static void setCOInvoiceJEFlagForInvoicedDeals() {
        disbaleTrigger('COInvoiceTrigger');
        List<Deal__c> dealList = [SELECT Id, Invoice_Number__c from Deal__c where Status__c = 'Invoiced' AND Invoice_Number__c != null];
        List<CO_Invoice_Header__c> coInvoiceList = new List<CO_Invoice_Header__c>();
        for(Deal__c dealRec: dealList) {
            coInvoiceList.add(new CO_Invoice_Header__c(Id=dealRec.Invoice_Number__c, availForQBJournalEntrySync__c=true));
        }
        update coInvoiceList;
        enableTrigger('COInvoiceTrigger');
    }
    
    global static void executeBatchJobs(List<sObject> recordList, Integer maxNumberOfRecord, String entityType) {
        for(Integer i = 0; i < Math.ceil(recordList.size() / Decimal.valueOf(maxNumberOfRecord)) && i < 100; i++) {
            Set<Id> recordIdSet = new Set<Id>();
            for(Integer j = (i * maxNumberOfRecord); (j < ((i + 1) * maxNumberOfRecord) && j < recordList.size()); j++) {
                recordIdSet.add(recordList[j].Id);
            }
            if(entityType == 'PartRetail') {
                CalculatePartRetailPrice_Batch batchObj = new CalculatePartRetailPrice_Batch(recordIdSet, maxNumberOfRecord);
            }
        }
    }
    
    global static void insertDefaultAccountTypes() {
        List<Account_Type__c> deafultAccountTypesToBeAdded = [Select Id from Account_Type__c];
        if(deafultAccountTypesToBeAdded.size() == 0) {
            deafultAccountTypesToBeAdded.add(new Account_Type__c(Name='Retail Customer',Applies_To__c='Customers', Active__c=true, Default__c=true));
            deafultAccountTypesToBeAdded.add(new Account_Type__c(Name='Supplier',Applies_To__c='Vendors', Active__c=true, Default__c=true));
            insert deafultAccountTypesToBeAdded;
        }
    }
    
    global static void populateTaxFieldsOnDealItem() {
        disbaleTrigger('DealItemTrigger');
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Deal_Item__c> dealItemList = [SELECT Id, Type__c, Applicable_Tax__c, Customer_Owned_Unit__r.Taxable__c, Customer_Owned_Unit__r.Applicable_Tax__c 
                                              FROM Deal_Item__c];
        List<Sales_Tax__c> defaultUnitSalesTaxList = [Select Id from Sales_Tax__c where Id =: Configurations__c.getInstance().Default_Tax_on_Unit__c];
        
        for(Deal_Item__c dealItemRec : dealItemList) {
            if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_UNIT && dealItemRec.Customer_Owned_Unit__c != null && dealItemRec.Applicable_Tax__c == null) {
                dealItemRec.Taxable__c = dealItemRec.Customer_Owned_Unit__r.Taxable__c;
                dealItemRec.Applicable_Tax__c = (dealItemRec.Customer_Owned_Unit__r.Taxable__c) ? dealItemRec.Customer_Owned_Unit__r.Applicable_Tax__c : null;
            } else {
                dealItemRec.Taxable__c = (defaultUnitSalesTaxList.size() > 0);
                dealItemRec.Applicable_Tax__c = (defaultUnitSalesTaxList.size() > 0 != null) ? defaultUnitSalesTaxList[0].Id : null;
            } 
        }
        if(dealItemList.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update dealItemList;
        }
        enableTrigger('DealItemTrigger');
    }
    
    global static void populateIndividualTaxesOnVendorInvoices() {
        Set<Id> invoiceHeaderIdSet = (new Map<Id, Vendor_Invoicing_Header__c>([SELECT Id FROM Vendor_Invoicing_Header__c limit: SOQLUtil.getAvailableQueryRowsLimit()])).keySet();
        if(invoiceHeaderIdSet.size() > 0) {
            populateIndividualTaxesOnVendorInvoices(invoiceHeaderIdSet);
        }
    }
    
    global static void populateIndividualTaxesOnVendorInvoices(Set<Id> vendorInvoicingHeaderIdSet) {
        VendorInvoicingCtrl.populateIndividualTaxesOnVendorInvoices(vendorInvoicingHeaderIdSet);
    }
    global static void executeAccountTypeBatch() {
        Database.executeBatch(new AccountTypeBatch());
    }

    global static void populateTaxExemptions() {
        Database.executeBatch(new TaxExemptionsBatch());
    }
    
    global static void createUniqueMakeModelSubmodel() {
        List<Unit_Make__c> makeList = [Select Id, Name, (Select Id, Name__c, Unit_Make__c from Unit_Models__r), (Select Id, Unit_Make__c from Deal_Items__r), (Select Id, Unit_Make__c from Customer_Owned_Units__r), (Select Id, Make__c from Kit_Headers__r) from Unit_Make__c];
        //To Delete
        List<Unit_Make__c> makeListToDelete = new List<Unit_Make__c>();
        List<Unit_Model__c> modelListToDelete = new List<Unit_Model__c>();
        
        //To Insert
        List<Unit_Model__c> modelListToInsert = new List<Unit_Model__c>();
        
        Map<String, String> makeNameToMakeIdMap = new Map<String, String>();
        Map<String, Map<String, String>> makeNameToModelNameToIdMap = new Map<String, Map<String, String>>();
        
        for(Unit_Make__c makeRec : makeList) {
            Map<String, String> modelNameToIdMap = makeNameToModelNameToIdMap.containsKey((makeRec.Name).toLowerCase()) ? 
                        makeNameToModelNameToIdMap.get((makeRec.Name).toLowerCase()) : new Map<String, String>();
            if(!makeNameToMakeIdMap.containsKey((makeRec.Name).toLowerCase())) {
                makeNameToMakeIdMap.put((makeRec.Name).toLowerCase(), makeRec.Id);
                
                
                for(Unit_Model__c modelRec : makeRec.Unit_Models__r) {
                    if(!modelNameToIdMap.containsKey((modelRec.Name__c).toLowerCase())) {
                        modelNameToIdMap.put((modelRec.Name__c).toLowerCase(), modelRec.Id);
                    } else {
                        modelListToDelete.add(modelRec);
                    }
                }
                
            } else {
                for(Unit_Model__c modelRec : makeRec.Unit_Models__r) {
                    if(!modelNameToIdMap.containsKey((modelRec.Name__c).toLowerCase())) {
                        Unit_Model__c newModelRec = modelRec.clone(false, false, false, false);
                        newModelRec.Unit_Make__c = makeNameToMakeIdMap.get((makeRec.Name).toLowerCase());
                        modelListToInsert.add(newModelRec);
                        
                        modelNameToIdMap.put((modelRec.Name__c).toLowerCase(), null);
                    }
                }
                modelListToDelete.addAll(makeRec.Unit_Models__r);
                makeListToDelete.add(makeRec);
            }
            
            makeNameToModelNameToIdMap.put((makeRec.Name).toLowerCase(), modelNameToIdMap);
        }
        if(modelListToInsert.size() > 0) {
            insert modelListToInsert;
            List<Unit_Model__c> modelList = [Select Id, Name__c, Unit_Make__r.Name from Unit_Model__c where Id IN: modelListToInsert];
            for(Unit_Model__c modelRec : modelList) {
                if(makeNameToModelNameToIdMap.containsKey((modelRec.Unit_Make__r.Name).toLowerCase()) && 
                    makeNameToModelNameToIdMap.get((modelRec.Unit_Make__r.Name).toLowerCase()).containsKey((modelRec.Name__c).toLowerCase()) &&
                    makeNameToModelNameToIdMap.get((modelRec.Unit_Make__r.Name).toLowerCase()).get((modelRec.Name__c).toLowerCase()) == null) {
                    makeNameToModelNameToIdMap.get((modelRec.Unit_Make__r.Name).toLowerCase()).put((modelRec.Name__c).toLowerCase(), modelRec.Id);
                }
            }
        }
        updateAllRelatedRecords(makeNameToMakeIdMap, makeNameToModelNameToIdMap);
        createUniqueSubmodel();
        //At the end
        delete modelListToDelete;
        delete makeListToDelete;
    }
    
    private static void updateAllRelatedRecords(Map<String, String> makeNameToMakeIdMap, Map<String, Map<String, String>> makeNameToModelNameToIdMap) {
        List<Deal_Item__c> dealItemList = [Select Id, Unit_Make__r.Name, Unit_Model__r.Name__c from Deal_Item__c where (Unit_Make__c != null OR Unit_Model__c != null)];
        for(Deal_Item__c dealItemRec : dealItemList) {
            if(dealItemRec.Unit_Make__c != null) {
                dealItemRec.Unit_Make__c = makeNameToMakeIdMap.get((dealItemRec.Unit_Make__r.Name).toLowerCase()); 
                if(dealItemRec.Unit_Model__c != null) {
                    dealItemRec.Unit_Model__c = makeNameToModelNameToIdMap.get((dealItemRec.Unit_Make__r.Name).toLowerCase()).get((dealItemRec.Unit_Model__r.Name__c).toLowerCase());
                }              
            }
        }
        
        List<Customer_Owned_Unit__c> unitList = [Select Id, Unit_Make__r.Name, Unit_Model__r.Name__c from Customer_Owned_Unit__c where (Unit_Make__c != null OR Unit_Model__c != null)];
        for(Customer_Owned_Unit__c unitRec : unitList) {
            if(unitRec.Unit_Make__c != null) {
                unitRec.Unit_Make__c = makeNameToMakeIdMap.get((unitRec.Unit_Make__r.Name).toLowerCase()); 
                if(unitRec.Unit_Model__c != null) {
                    unitRec.Unit_Model__c = makeNameToModelNameToIdMap.get((unitRec.Unit_Make__r.Name).toLowerCase()).get((unitRec.Unit_Model__r.Name__c).toLowerCase());
                }
            }
        }
        
        List<Kit_Header__c> kitHeaderList = [Select Id, Make__r.Name, Model__r.Name__c from Kit_Header__c where (Make__c != null OR Model__c != null)];
        for(Kit_Header__c kitRec : kitHeaderList) {
            if(kitRec.Make__c != null) {
                kitRec.Make__c = makeNameToMakeIdMap.get((kitRec.Make__r.Name).toLowerCase());
                if(kitRec.Model__c != null) {
                    kitRec.Model__c = makeNameToModelNameToIdMap.get((kitRec.Make__r.Name).toLowerCase()).get((kitRec.Model__r.Name__c).toLowerCase());
                }
            }
        }
        
        List<Unit_Sub_Model__c> subModelList = [Select Id, Sub_Model_Name__c, Unit_Model__r.Unit_Make__r.Name, Unit_Model__r.Name__c from Unit_Sub_Model__c];
        for(Unit_Sub_Model__c subModelRec : subModelList) {
            if(subModelRec.Unit_Model__c != null) {
                subModelRec.Unit_Model__c = makeNameToModelNameToIdMap.get((subModelRec.Unit_Model__r.Unit_Make__r.Name).toLowerCase()).get((subModelRec.Unit_Model__r.Name__c).toLowerCase());
            }
        }
    
        update dealItemList;
        update unitList;
        update kitHeaderList;
        update subModelList;
    }
    
    private static void createUniqueSubmodel() {
        List<Unit_Model__c> modelList = [Select Id, Name__c, Unit_Make__r.Name, (Select Id, Sub_Model_Name__c, Unit_Model__c from Unit_Sub_Models__r) from Unit_Model__c];
        Map<String, Unit_Sub_Model__c> subModelIdToRecMap = new Map<String, Unit_Sub_Model__c>([Select Id, Sub_Model_Name__c, Unit_Model__r.Name__c, (Select Id, Unit_Model__c from Deals_Items__r), (Select Id, Unit_Model__c from Customer_Owned_Units__r), (Select Id, Model__c from Kit_Headers__r) from Unit_Sub_Model__c]);
        
        List<Deal_Item__c> dealItemListToUpdate = new List<Deal_Item__c>();
        List<Customer_Owned_Unit__c> unitListToUpdate = new List<Customer_Owned_Unit__c>();
        List<Kit_Header__c> kitHeaderListToUpdate = new List<Kit_Header__c>();
        
        //To Delete
        List<Unit_Sub_Model__c> subModelListToDelete = new List<Unit_Sub_Model__c>();
        
        for(Unit_Model__c modelRec : modelList) {
            Map<String, String> submodelNameToIdMap = new Map<String, String>();
            for(Unit_Sub_Model__c submodelObj : modelRec.Unit_Sub_Models__r) {
                
                if(!submodelNameToIdMap.containsKey((submodelObj.Sub_Model_Name__c).toLowerCase())) {
                    submodelNameToIdMap.put((submodelObj.Sub_Model_Name__c).toLowerCase(), submodelObj.Id);
                } else {
                    Unit_Sub_Model__c submodelRec = subModelIdToRecMap.get(submodelObj.Id);
                    for(Deal_Item__c dealItemRec : submodelRec.Deals_Items__r) {
                        dealItemListToUpdate.add(new Deal_Item__c(Id = dealItemRec.Id, Sub_Model__c = submodelNameToIdMap.get((submodelRec.Sub_Model_Name__c).toLowerCase())));
                    }
                    for(Customer_Owned_Unit__c unitRec : submodelRec.Customer_Owned_Units__r) {
                        unitListToUpdate.add(new Customer_Owned_Unit__c(Id = unitRec.Id, Sub_Model__c = submodelNameToIdMap.get((submodelRec.Sub_Model_Name__c).toLowerCase())));
                    }
                    for(Kit_Header__c kitRec : submodelRec.Kit_Headers__r) {
                        kitHeaderListToUpdate.add(new Kit_Header__c(Id = kitRec.Id, Sub_Model__c = submodelNameToIdMap.get((submodelRec.Sub_Model_Name__c).toLowerCase())));
                    }
                    subModelListToDelete.add(submodelRec);
                }
            }
        }
        
        update dealItemListToUpdate;
        update unitListToUpdate;
        update kitHeaderListToUpdate;
        
        delete subModelListToDelete;
    }
    
    @future
    global static void changesStatusOfInvoicedVRs() {
        Map<Id, Vendor_Invoicing_Header__c> viHeaderMap = new Map<Id, Vendor_Invoicing_Header__c>([Select Id from Vendor_Invoicing_Header__c WHERE Status__c = 'Invoiced']);
        if(viHeaderMap.size() > 0) {
            List<Vendor_Receiving_Header__c> vrHeaderList = [SELECT Id from Vendor_Receiving_Header__c WHERE In_Progress_VI__c IN: viHeaderMap.keyset()];
            for(Vendor_Receiving_Header__c vrHeaderRec : vrHeaderList) {
                vrHeaderRec.Status__c = 'Invoiced';
            }
            update vrHeaderList;
        }
    }
    
    global static void updateTradeInDefaultCategory() {
        List<Category__c> categoryRecs = [SELECT Inventory_GL__c, Type__c from Category__c WHERE (Type__c ='Unit' OR Type__c ='Trade-in') AND Default__c = true];
        Category__c unitDefault;
        Category__c tradeinDefault; 
        for(Category__c categoryRec : categoryRecs) {
            if(categoryRec.Type__c == 'Unit'){
                unitDefault = categoryRec;
            } else if(categoryRec.Type__c == 'Trade-in') {
                tradeinDefault = categoryRec;
            }       
        }
        if(unitDefault!=null) {
            tradeinDefault = tradeinDefault==null? new Category__c(Active__c=true, Type__c='Trade-in', Default__c=true, Name='Trade-in Default', Description__c='Default category for trade ins') : tradeinDefault;
            tradeinDefault.Income_GL__c = unitDefault.Inventory_GL__c;
            update tradeinDefault;
        }
    }
    
    //Added by nidhi
    global static void populateCashDrawerReconciliationForExistingCashReconciliationRec() {
        List<Cash_Reconciliation__c> cashReconRecList = [Select Id, (Select Id from Cash_Reconciliation_Payments__r) 
            from Cash_Reconciliation__c where Id Not In (Select Cash_Reconciliation__c from Cash_Drawer_Reconciliation__c) limit: SOQLUtil.getAvailableQueryRowsLimit()];
        
        Cash_Drawer__c drawer = [Select id from Cash_Drawer__c where Name = 'Main Cash Drawer' AND Active__c = true][0];
        Map<String, Cash_Drawer_Reconciliation__c> cashReconIdToCashDraweReconRecMap = new Map<String, Cash_Drawer_Reconciliation__c>();
        for(Cash_Reconciliation__c cashReconRec : cashReconRecList) {
            Cash_Drawer_Reconciliation__c cashDraweReconRec = new Cash_Drawer_Reconciliation__c(Cash_Reconciliation__c = cashReconRec.Id);
            cashDraweReconRec.Cash_Drawer__c = drawer.Id;
            cashReconIdToCashDraweReconRecMap.put(cashReconRec.Id, cashDraweReconRec);  
        }
        
        insert cashReconIdToCashDraweReconRecMap.values();
        List<Cash_Reconciliation_Payment__c> cashReconPaymentListToUpdate = new List<Cash_Reconciliation_Payment__c>();
        for(Cash_Reconciliation__c cashReconRec : cashReconRecList) {
            for(Cash_Reconciliation_Payment__c payment : cashReconRec.Cash_Reconciliation_Payments__r) {
                payment.Cash_Drawer_Reconciliation__c = cashReconIdToCashDraweReconRecMap.get(cashReconRec.id).Id;      
            }   
            
            cashReconPaymentListToUpdate.addAll(cashReconRec.Cash_Reconciliation_Payments__r);  
        }
        update cashReconPaymentListToUpdate;
    }
    
    //Update Cash Drawer on Payments
    global static void populateCashDrawerOnPayments() {
        List<Co_Invoice_Payment__c>  coInvPaymentList = [Select Id, Cash_Drawer__c from Co_Invoice_Payment__c where Cash_Drawer__c = null limit: SOQLUtil.getAvailableQueryRowsLimit()];
        Cash_Drawer__c drawer = [Select id from Cash_Drawer__c where Name = 'Main Cash Drawer' AND Active__c = true][0];
        
        for(Co_Invoice_Payment__c invPaymentRec : coInvPaymentList) {
            invPaymentRec.Cash_Drawer__c = drawer.Id;
        }
        update coInvPaymentList;
    }
    
    //Update Cash Drawer on Deposits
    global static void populateCashDrawerOnDeposits() {
        List<Co_Deposit__c>  coDepositList = [Select Id, Cash_Drawer__c from Co_Deposit__c where Cash_Drawer__c = null limit: SOQLUtil.getAvailableQueryRowsLimit()];
        Cash_Drawer__c drawer = [Select id from Cash_Drawer__c where Name = 'Main Cash Drawer' AND Active__c = true][0];
        
        for(Co_Deposit__c depositRec : coDepositList) {
            depositRec.Cash_Drawer__c = drawer.Id;
        }
        update coDepositList;
    }
    
    global static void populateMerchandiseTransactionTypeOnHistoricalRecords() {
		List<CO_Header__c> coHeaderRecList = [Select Merchandise_Transaction_Type__c, Merchandise_Commit_Order_controls__c from CO_Header__c where Merchandise_Transaction_Type__c = null OR Merchandise_Commit_Order_controls__c = null limit: SOQLUtil.getAvailableQueryRowsLimit()];
		if(coHeaderRecList.size() > 0) {
			for(CO_Header__c coHeaderRec : coHeaderRecList) {
				coHeaderRec.Merchandise_Transaction_Type__c = 'Part sale';
				coHeaderRec.Merchandise_Commit_Order_controls__c = 'Commit and order';
			}
			update coHeaderRecList;
		}
    }
    
    global static void deleteDuplicateCashReconciliationPaymentRecords() {
        if(AccessControl.ifObjectFieldIsAccessible('Cash_Drawer_Reconciliation__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Cash_Reconciliation_Payment__C') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Cash_Drawer_Reconciliation__c> cashDrawerReconciliationList = [SELECT Id, (SELECT Id, Payment_Method__c  FROM Cash_Reconciliation_Payments__r ORDER 
        																		by CreatedDate DESC) FROM Cash_Drawer_Reconciliation__c ORDER BY Name ASC 
        																		LIMIT: CashDrawerSOQLUtil.getAvailableQueryRowsLimit()]; 
        
        Map<Id, Map<String, List<Cash_Reconciliation_Payment__C>>> cdrIdToPaymentMethodNameToPaymentRecListMap = new Map<Id, Map<String, List<Cash_Reconciliation_Payment__C>>>();
        for(Cash_Drawer_Reconciliation__c cdrRec : cashDrawerReconciliationList) {
        	cdrIdToPaymentMethodNameToPaymentRecListMap.put(cdrRec.Id, new Map<String, List<Cash_Reconciliation_Payment__C>>());
        	
        	for(Cash_Reconciliation_Payment__c cdrpRec : cdrRec.Cash_Reconciliation_Payments__r) {
        		if(!cdrIdToPaymentMethodNameToPaymentRecListMap.get(cdrRec.Id).containsKey(cdrpRec.Payment_Method__c)) {
        			cdrIdToPaymentMethodNameToPaymentRecListMap.get(cdrRec.Id).put(cdrpRec.Payment_Method__c, new List<Cash_Reconciliation_Payment__C>());
        		} 
        		cdrIdToPaymentMethodNameToPaymentRecListMap.get(cdrRec.Id).get(cdrpRec.Payment_Method__c).add(cdrpRec);
        	}
        }
        
        Set<Id> deletablePaymentRecIdSet = new Set<Id>();
        for(Id cdrRecId : cdrIdToPaymentMethodNameToPaymentRecListMap.keySet()) {
        	for(String paymentMethodName : cdrIdToPaymentMethodNameToPaymentRecListMap.get(cdrRecId).keySet()) {
        		for(Integer i=1; i<cdrIdToPaymentMethodNameToPaymentRecListMap.get(cdrRecId).get(paymentMethodName).size(); i++) {
        			deletablePaymentRecIdSet.add(cdrIdToPaymentMethodNameToPaymentRecListMap.get(cdrRecId).get(paymentMethodName)[i].Id);
        		}
        	}
        }
        List<Cash_Reconciliation_Payment__c> deletablePaymentRecordList = new List<Cash_Reconciliation_Payment__c>();
    	for(Id paymentId : deletablePaymentRecIdSet) {
    		deletablePaymentRecordList.add(new Cash_Reconciliation_Payment__c(Id = paymentId));
    	}
   		if(AccessControl.ifObjectIsDeletable('Cash_Reconciliation_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
   		delete deletablePaymentRecordList;
    }
	
	global static void updatePaymentDateOnCODeposit() {
		disbaleTrigger('CODepositTrigger');
		List<CO_Deposit__c> coDepositList = [Select Id, CreatedDate__c, Payment_Date__c from CO_Deposit__c Where Payment_Date__c = null limit: SOQLUtil.getAvailableQueryRowsLimit()];
		
		for(CO_Deposit__c coDepositRec : coDepositList) {
			coDepositRec.Payment_Date__c = coDepositRec.CreatedDate__c;
		}
		update coDepositList;
		enableTrigger('CODepositTrigger');
	}

	global static void updatePaymentDateOnCOInvoicePayment() {
		disbaleTrigger('COInvoicePaymentTrigger');
		List<CO_Invoice_Payment__c> coInvoicePaymentList = [Select Id, CreatedDate__c, Payment_Date__c from CO_Invoice_Payment__c Where Payment_Date__c = null limit: SOQLUtil.getAvailableQueryRowsLimit()];
		
		for(CO_Invoice_Payment__c coInvoicePaymentRec : coInvoicePaymentList) {
			coInvoicePaymentRec.Payment_Date__c = coInvoicePaymentRec.CreatedDate__c;
		}
		update coInvoicePaymentList;
		enableTrigger('COInvoicePaymentTrigger');
	}
	
    global static void setOrderLotsWhenIsOrderLotFlagDisabled() {
	    List<Part__c> partListToUpdate = [Select Id, Order_Lots__c From Part__c Where Is_OrderLot__c = false AND Order_Lots__c != 1];
	    for(Part__c partRec : partListToUpdate) {
	    	partRec.Order_Lots__c = 1;
	    }
	    upsert partListToUpdate;
    }
    global static void finalizeInvoice(List<String> recIdList, String coHeaderId) {
    }

    global static void populateDealOptionClearingControlAccount() {
	    List<Category__c> categories = [Select Id,Income_GL__c FROM Category__c WHERE Type__c = 'Stocked Trade' AND Default__c = true];
	    Accounting_Default_Accounts__c defaultAccounts = Accounting_Default_Accounts__c.getOrgDefaults(); 
	    if(categories.size() > 0) {
	        defaultAccounts.Deal_Option_Clearing__c = categories[0].Income_GL__c;
	        upsert defaultAccounts;
	    }
    }

	global static void populateClosedDateOnInvoice() {
		disbaleTrigger('COInvoiceTrigger');
		List<CO_Invoice_Header__c> coInvoiceHeaderRecList = [select Closed_Invoice_Date__c, Invoice_Date__c from CO_Invoice_Header__c where Closed_Invoice_Date__c = null AND Invoice_Date__c != null Limit 10000];
		
		for(CO_Invoice_Header__c coInvRec : coInvoiceHeaderRecList) {
			coInvRec.Closed_Invoice_Date__c = coInvRec.Invoice_Date__c;
		}
		update coInvoiceHeaderRecList;
		enableTrigger('COInvoiceTrigger');
	}
}