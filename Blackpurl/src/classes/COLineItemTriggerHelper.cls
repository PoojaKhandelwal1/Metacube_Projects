/**
 * Author: Tarun Khandelwal
 * Since: March 27, 2014
 * Name: COLineItemTriggerHelper
 * Description: Trigger executes on after insert event of CO Line Item object
**/
public with sharing class COLineItemTriggerHelper {
    
    public static Boolean isForceStopTrigger = false;
    public static List<CO_Line_Item__c> COLineItemNewList = new List<CO_Line_Item__c>();
    public static List<CO_Line_Item__c> COLineItemOldList = new List<CO_Line_Item__c>();
    public static Map<Id, CO_Line_Item__c> COLineItemNewMap = new Map<Id, CO_Line_Item__c>();
    public static Map<Id, CO_Line_Item__c> COLineItemOldMap = new Map<Id, CO_Line_Item__c>();
    
    public static Map<Id, List<Applicable_Taxes__c>> salesTaxIdToAppTaxRecordsMap = new Map<Id, List<Applicable_Taxes__c>>();
    public static Map<Id, Set<Id>> coHeaderIdToSalesTaxItemIdsMap = new Map<Id, Set<Id>>();
    public static Map<Id, Set<Id>> soHeaderIdToSalesTaxItemIdsMap = new Map<Id, Set<Id>>();
    public static Map<Id, Part__c> partIdToPartRecordMap = new Map<Id, Part__c>();
    public static Map<Id, Fee__c> feeIdToFeeRecordMap = new Map<Id, Fee__c>();
    public static Map<Id, Service_Order_Line_Item__c> soliMap = new Map<Id, Service_Order_Line_Item__c>();
    public static Map<Id, CO_Header__c> coHeaderIdToCoHeaderRecMap = new Map<Id, CO_Header__c>();
    
    public static Map<Id, Boolean> partIdToNonInventoryFlagMap = new Map<Id, Boolean>();
    
    // Variable to stop nested looping
    public static Boolean isTriggerExecute = false;
    
    public static Boolean isVOLIRecToInsert = false;
     
    public static Boolean isVOLIRecToChange = true;
    public static Boolean isVOLIInsertFromVRPage = true;
    public static Boolean isTotalCalculated = false;
    public static Boolean isActivateQuoteCO = false;
    public static Boolean isMoveLineItem = false;
    
    // List to store default sales tax level. 
    public static List<Sales_Tax__c> defaultSalesTax;
    
    /**
     * Name: checkEnteryCondition
     * Desc: check entry condition for method
     * @param: 
     * @return: Boolean - true if entry condition is true
    **/
    public static Boolean checkEnteryCondition() {
        if(isTriggerExecute) {
            return false;
        }
        return true;
    }
    
    public static String getMerchandiseCommitOrderControlSetting(CO_Line_Item__c coliRec) {
        if(Test.isRunningTest() || !coliRec.Is_In_Merch_Section__c || String.isBlank(coliRec.Merchandise_Commit_Order_controls__c)) {
            return Constants.COMMIT_AND_ORDER;
        } else {
            return coliRec.Merchandise_Commit_Order_controls__c;
        }
    }
    
    private static Boolean isCommitOrderControlSettingChanged(CO_Line_Item__c coliRec) {
        String oldCommitOrderControlSettingValue = (String.isNotBlank(COLineItemOldMap.get(coliRec.Id).Merchandise_Commit_Order_controls__c) ? 
                COLineItemOldMap.get(coliRec.Id).Merchandise_Commit_Order_controls__c : Constants.COMMIT_AND_ORDER);
        if(getMerchandiseCommitOrderControlSetting(coliRec) != oldCommitOrderControlSettingValue) {
            return true;
        }
        return false;
    }
    
    public static Boolean entryConditionForQtyCommitLogic(CO_Line_Item__c coliRec) {
        if(coliRec.CO_Status__c != Constants.CO_STATUS_QUOTE && (getMerchandiseCommitOrderControlSetting(coliRec) == null || 
            getMerchandiseCommitOrderControlSetting(coliRec) != Constants.UNCOMIITTED) &&
                coliRec.Qty__c >= 0) {
            return true;
        }
        return false;
    }
    
    public static Boolean entryConditionForQtyCommitToZero(CO_Line_Item__c coliRec) {
        if(coliRec.CO_Status__c == Constants.CO_STATUS_QUOTE || PartTriggerHelper.isCoToQuoteAction || getMerchandiseCommitOrderControlSetting(coliRec) == Constants.UNCOMIITTED) {
            return true;
        }
        return false;
    }
    
    public static List<CO_Line_Item__c> getValidListForBeforeUpdateCommittedLogic() {
        List<CO_Line_Item__c> validCOLIList = new List<CO_Line_Item__c>();
        for(CO_Line_Item__c coliRec : COLineItemNewList) {
            if(coliRec.CO_Status__c != Constants.CO_STATUS_QUOTE && (coliRec.Part__c != null) && 
                    (partIdToNonInventoryFlagMap.containsKey(coliRec.Part__c)) && !(partIdToNonInventoryFlagMap.get(coliRec.Part__c)) && 
                    (((COLineItemNewMap.get(coliRec.Id).Qty__c != COLineItemOldMap.get(coliRec.Id).Qty__c ||
                      COLineItemNewMap.get(coliRec.Id).Qty_Committed__c != COLineItemOldMap.get(coliRec.Id).Qty_Committed__c) && 
                      getMerchandiseCommitOrderControlSetting(coliRec) != Constants.UNCOMIITTED) || 
                      isCommitOrderControlSettingChanged(coliRec))) {
                
                validCOLIList.add(coliRec);
            }
        }
        return validCOLIList;
    }
    
    public static void beforeInsertCalculation_Updated() {
        Set<Id> partIdSet = new Set<Id>();
        Set<Id> feeIdSet = new Set<Id>();
        Set<Id> soliIdSet = new Set<Id>();
        
        Boolean isDealItemExists = false;
        
        for(CO_Line_Item__c coLineItemRec : COLineItemNewList) {
            if(coLineItemRec.part__c != null) {
                partIdSet.add(coLineItemRec.part__c);
            } else if(coLineItemRec.Fee__c != null) {
                feeIdSet.add(coLineItemRec.Fee__c);
            }
            if(coLineItemRec.Service_Order_Line_Item__c != null) {
                soliIdSet.add(coLineItemRec.Service_Order_Line_Item__c);
            }
            if(String.isNotBlank(coLineItemRec.Deal__c)) {
                isDealItemExists = true;
            }
            if(String.isNotBlank(coLineItemRec.CO_Header__c)) {
                coHeaderIdToSalesTaxItemIdsMap.put(coLineItemRec.CO_Header__c, new Set<Id>());
            }
        }
        
        List<Price_Level__c> defaultPriceLevel;
        if(isDealItemExists) {
            defaultPriceLevel = SOTriggerHelper.getInternalDefaultPriceLevel();
            if(defaultPriceLevel == null || defaultPriceLevel.size() == 0) {
                defaultPriceLevel = SOTriggerHelper.getDefaultPriceLevel();
            }
        }
        
        if(coHeaderIdToSalesTaxItemIdsMap.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            coHeaderIdToCoHeaderRecMap = new Map<Id, CO_Header__c>([select Customer__c, Discount_Markup_From_Prive_Level__c, Part_Price_Base_From_Price_Level__c
                                                                                                from CO_Header__c Where Id IN : coHeaderIdToSalesTaxItemIdsMap.keySet()]);
        }
        if(partIdSet.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            partIdToPartRecordMap = new Map<Id, Part__c>([select Id, Average_Cost__c, Last_Cost__c, MSRP__c, Retail_Price__c, 
                                                        Part_Number__c, Description__c, AvailableParts__c, Qty_Committed__c, Applicable_Tax__c, Applicable_Tax__r.Rate__c, 
                                                        Non_Inventory_Part__c from Part__c where Id IN : partIdSet]);   
        }
        
        if(feeIdSet.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            feeIdToFeeRecordMap = new Map<Id, Fee__c>([select Code__c, Description__c, Price__c, Taxable__c, Applicable_Tax__c, Applicable_Tax__r.Rate__c
                                                                        from Fee__c where Id IN: feeIdSet]); 
        }
        
        if(soliIdSet.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            soliMap = new Map<Id, Service_Order_Line_Item__c>([select Service_Order_Kit_Header__c, Service_Order_Header__c, Service_Order_Header__r.Provider__c, Service_Order_Header__r.Job_Type__c, 
                                                                        Service_Order_Header__r.Provider_Part_Price_Base__c, Service_Order_Header__r.Provider_Discount_Markup__c, Service_Order_Header__r.CO_Header__r.CO_Type__c
                                                                        from Service_Order_Line_Item__c where Id IN: soliIdSet]);
        }
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Map<String, Part__c> partIdToRecMapToUpdate = new Map<String, Part__c>();
        List<Id> salesTaxIdList = new List<Id>();
        for(CO_Line_Item__c coLineItemRec : COLineItemNewList) {
            //Populate Desc
            populateDesc(coLineItemRec, partIdToPartRecordMap, feeIdToFeeRecordMap);
            
            //Qty Committed logic
            if(coLineItemRec.Part__c != null && !partIdToPartRecordMap.get(coLineItemRec.Part__c).Non_Inventory_Part__c && entryConditionForQtyCommitLogic(coLineItemRec)) {
                Part__c partRec = updateQtyCommitted(coLineItemRec, partIdToPartRecordMap.get(coLineItemRec.Part__c));
                partIdToPartRecordMap.get(coLineItemRec.Part__c).put('Qty_Committed__c', partRec.Qty_Committed__c);
                partIdToRecMapToUpdate.put(partRec.Id, partRec);
            }
            if(coLineItemRec.Kit_Header_Line_Item__c != null) {
                continue;
            }
            //Apply Price Level
            Price_Level__c appliedPriceLevel = getAppliedPriceLevel(coLineItemRec, soliMap, defaultPriceLevel, coHeaderIdToCoHeaderRecMap.get(coLineItemRec.CO_Header__c));
            TaxCalculation.partPriceCalculation1(appliedPriceLevel.Part_Price_Base__c, appliedPriceLevel.Discount_Markup__c, coLineItemRec, partIdToPartRecordMap, feeIdToFeeRecordMap);
        
            //Get Applied sales tax id
            if(String.isBlank(coLineItemRec.Deal__c)) {
                String appliedSalesTaxId = getAppliedSalesTaxId(coLineItemRec, partIdToPartRecordMap, feeIdToFeeRecordMap, soliMap);
                if(String.isNotBlank(appliedSalesTaxId)) {
                    salesTaxIdList.add(appliedSalesTaxId);
                } else if(isTaxIncludingPricing && coLineItemRec.Price__c != null) {
                    coLineItemRec.Price_When_Tax_Included__c = coLineItemRec.Price__c;
                }
            }
            if(String.isNotBlank(coLineItemRec.Service_Order_Line_Item__c) && soliMap.containsKey(coLineItemRec.Service_Order_Line_Item__c)) {
                soHeaderIdToSalesTaxItemIdsMap.put(soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__c, new Set<Id>());
            }
        }
                
        if(AccessControl.ifObjectFieldIsAccessible('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Tax_Exemption__c> taxExemptionsList = [SELECT CO_Header__r.Customer__c, Service_Order_Header__r.Provider__c, Sales_Tax_Item__c, Sales_Tax_Item__r.Rate__c from Tax_Exemption__c 
                                    where (CO_Header__c IN: coHeaderIdToSalesTaxItemIdsMap.keySet() OR Service_Order_Header__c IN: soHeaderIdToSalesTaxItemIdsMap.keySet())];
        
        for(Tax_Exemption__c taxExemptionRec : taxExemptionsList) {
            if(String.isNotBlank(taxExemptionRec.Service_Order_Header__c)) {
                soHeaderIdToSalesTaxItemIdsMap.get(taxExemptionRec.Service_Order_Header__c).add(taxExemptionRec.Sales_Tax_Item__c);
            }
            if(String.isNotBlank(taxExemptionRec.CO_Header__c)) {
                coHeaderIdToSalesTaxItemIdsMap.get(taxExemptionRec.CO_Header__c).add(taxExemptionRec.Sales_Tax_Item__c);
            }
        }
        //Apply Sales tax
        if(salesTaxIdList.size() > 0) {
            calculateSalesTax(salesTaxIdList, coHeaderIdToSalesTaxItemIdsMap, soHeaderIdToSalesTaxItemIdsMap, soliMap);
        }
        //Analysis: Can be moved to future
        if(partIdToRecMapToUpdate.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update partIdToRecMapToUpdate.values();
        }
    } 
    
    private static Price_Level__c getAppliedPriceLevel(CO_Line_Item__c coLineItemRec, Map<Id, Service_Order_Line_Item__c> soliMap, List<Price_Level__c> defaultPriceLevel, 
                        CO_Header__c coHeaderRec) {
        Price_Level__c appliedPriceLevel = new Price_Level__c();
        if(coLineItemRec.Service_Order_Line_Item__c != null && 
                soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__r.Provider_Part_Price_Base__c != null) {
            if(soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__r.Provider_Discount_Markup__c != null) {
                appliedPriceLevel.Discount_Markup__c = soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__r.Provider_Discount_Markup__c;
            } else {
                appliedPriceLevel.Discount_Markup__c = 0;       
            }
            appliedPriceLevel.Part_Price_Base__c = soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__r.Provider_Part_Price_Base__c;
        } else if(String.isNotBlank(coLineItemRec.Deal__c)) {
            if(defaultPriceLevel != null && defaultPriceLevel.size() > 0) {
                appliedPriceLevel.Discount_Markup__c = defaultPriceLevel[0].Discount_Markup__c; 
                appliedPriceLevel.Part_Price_Base__c = defaultPriceLevel[0].Part_Price_Base__c; 
            }
        } else {
            appliedPriceLevel.Discount_Markup__c = (coHeaderRec.Discount_Markup_From_Prive_Level__c == null) ? 0 : coHeaderRec.Discount_Markup_From_Prive_Level__c;
            appliedPriceLevel.Part_Price_Base__c = coHeaderRec.Part_Price_Base_From_Price_Level__c;
        }
        
        return appliedPriceLevel;
    }
    
    private static String getAppliedSalesTaxId(CO_Line_Item__c coLineItemRec, Map<Id, Part__c> partIdToPartRecordMap, Map<Id, Fee__c> feeIdToFeeRecordMap, 
                                                Map<Id, Service_Order_Line_Item__c> soliMap) {
        String appliedSalesTaxId;
        if((coLineItemRec.Service_Order_Line_Item__c != null && soliMap.containskey(coLineItemRec.Service_Order_Line_Item__c) && 
                        soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__r.Job_Type__c == 'Internal')) {
            appliedSalesTaxId = GeneralConfiguration.getDefaultSalesTaxOnInternalService();
            if(String.isNotBlank(appliedSalesTaxId)) return appliedSalesTaxId;
        }
        
        if(coLineItemRec.Part__c != null && partIdToPartRecordMap.get(coLineItemRec.Part__c).Applicable_Tax__c != null) {
            appliedSalesTaxId = partIdToPartRecordMap.get(coLineItemRec.Part__c).Applicable_Tax__c;
        } else if(coLineItemRec.Fee__c != null && feeIdToFeeRecordMap.get(coLineItemRec.Fee__c).Applicable_Tax__c != null) {
            appliedSalesTaxId = feeIdToFeeRecordMap.get(coLineItemRec.Fee__c).Applicable_Tax__c;
        }
        return appliedSalesTaxId;
    }
    
    private static Part__c updateQtyCommitted(CO_Line_Item__c coLineItemRec, Part__c partRec) {
        Decimal committedPartQty = partRec.Qty_Committed__c;
        Decimal qtyAvailable = partRec.AvailableParts__c;
        Decimal qtyRequried = coLineItemRec.Qty__c;
        if(qtyRequried <= qtyAvailable) {
            coLineItemRec.Qty_Committed__c = qtyRequried;
        } else {
            if(qtyAvailable > 0 ){
                coLineItemRec.Qty_Committed__c = qtyAvailable;
            }else{
                coLineItemRec.Qty_Committed__c = 0;
            }
        }
        partRec.Qty_Committed__c = committedPartQty + coLineItemRec.Qty_Committed__c;
        return partRec;
    }
    
    private static void populateDesc(CO_Line_Item__c coLineItemRec, Map<Id, Part__c> partIdToPartRecordMap, Map<Id, Fee__c> feeIdToFeeRecordMap) {
        if(coLineItemRec.Part__c != null && partIdToPartRecordMap.containsKey(coLineItemRec.Part__c)) {
            coLineItemRec.Item_Code__c = partIdToPartRecordMap.get(coLineItemRec.Part__c).Part_Number__c;
            coLineItemRec.Item_Description__c = partIdToPartRecordMap.get(coLineItemRec.Part__c).Description__c;
            coLineItemRec.Applicable_Tax__c = partIdToPartRecordMap.get(coLineItemRec.Part__c).Applicable_Tax__c;
        
        } else if(coLineItemRec.Fee__c != null && feeIdToFeeRecordMap.containsKey(coLineItemRec.Fee__c)) {
            if(coLineItemRec.Item_Code__c == null) {
                coLineItemRec.Item_Code__c = feeIdToFeeRecordMap.get(coLineItemRec.Fee__c).Code__c;
            }
            if(coLineItemRec.Item_Description__c == null){
                coLineItemRec.Item_Description__c = feeIdToFeeRecordMap.get(coLineItemRec.Fee__c).Description__c;   
            }
            coLineItemRec.Applicable_Tax__c = feeIdToFeeRecordMap.get(coLineItemRec.Fee__c).Applicable_Tax__c;
        }
    }
    
    public static void afterInsertCalculation_Updated() {
        insertCOInvoiceLineItem();
        insertIndividualTaxes();
        if(Test.isRunningTest() || system.isFuture()) {
            updateCOInvoiceItemOfKitHeader(COLineItemNewList);
        } else {
            updateCOInvoiceItemOfKitHeader_Future(new List<Id>(COLineItemNewMap.keySet()));
        }
        
        if(!isMoveLineItem) {
        	insertVOLineItem_Updated();
        }
    }
        
    private static void insertIndividualTaxes() {
        List<Individual_Tax__c> individualTaxToInsert = new List<Individual_Tax__c>();
        for(CO_Line_Item__c coLineItemRec : COLineItemNewList) {
            if(String.isNotBlank(coLineItemRec.Deal__c) || String.isNotBlank(coLineItemRec.Kit_Header_Line_Item__c)) {
                continue;
            }
    
            Id salesTaxId;
            if(coLineItemRec.Service_Order_Line_Item__c != null && soliMap.containsKey(coLineItemRec.Service_Order_Line_Item__c) && 
                soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__r.Job_Type__c == 'Internal') {
                salesTaxId = GeneralConfiguration.getDefaultSalesTaxOnInternalService();
            }
            
            if(String.isBlank(salesTaxId)) {
                if(coLineItemRec.Part__c != null && partIdToPartRecordMap.get(coLineItemRec.Part__c).Applicable_Tax__c != null) {
                    salesTaxId = partIdToPartRecordMap.get(coLineItemRec.Part__c).Applicable_Tax__c;
                } else if(coLineItemRec.Fee__c != null && feeIdToFeeRecordMap.get(coLineItemRec.Fee__c).Applicable_Tax__c != null) {
                    salesTaxId = feeIdToFeeRecordMap.get(coLineItemRec.Fee__c).Applicable_Tax__c;
                } 
            }
            if(salesTaxId == null) {
                continue;
            }
            
            Decimal exemptionRate = 0;
            if(salesTaxIdToAppTaxRecordsMap.containsKey(salesTaxId)) {
                for(Applicable_Taxes__c appTax : salesTaxIdToAppTaxRecordsMap.get(salesTaxId)) {
                    if(coLineItemRec.Service_Order_Line_Item__c != null && soliMap.containsKey(coLineItemRec.Service_Order_Line_Item__c) 
                        && soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__r.Provider__c != null
                        && soHeaderIdToSalesTaxItemIdsMap.containsKey(soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__c) &&
                        soHeaderIdToSalesTaxItemIdsMap.get(soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__c).contains(appTax.Sales_Tax_Item__c)) {
                    
                    } else if((coLineItemRec.Service_Order_Line_Item__c == null || 
                                (soliMap.containsKey(coLineItemRec.Service_Order_Line_Item__c) 
                                && soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__r.Job_Type__c != 'Internal' 
                                && soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__r.Provider__c == null))
                            && coHeaderIdToCoHeaderRecMap.containsKey(coLineItemRec.CO_Header__c) 
                            && coHeaderIdToCoHeaderRecMap.get(coLineItemRec.CO_Header__c).Customer__c != null 
                            && coHeaderIdToSalesTaxItemIdsMap.containsKey(coLineItemRec.CO_Header__c) 
                            && coHeaderIdToSalesTaxItemIdsMap.get(coLineItemRec.CO_Header__c).contains(appTax.Sales_Tax_Item__c)) {
                        
                    } else { // Individual sales Taxes
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
        if(individualTaxToInsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); } //FLS Create Nikhil 31/01/2017 
            insert individualTaxToInsert;
        }
    }
    
    public static void calculateSalesTax(List<Id> salesTaxIdList, Map<Id, Set<Id>> coHeaderIdToSalesTaxItemIdsMap, 
                                            Map<Id, Set<Id>> soHeaderIdToSalesTaxItemIdsMap, Map<Id, Service_Order_Line_Item__c> soliMap) {
        if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Applicable_Taxes__c> applicableTaxList = [SELECT Sales_Tax_Item__c, Sales_Tax__c, Sales_Tax_Item__r.Name__c, 
                                                            Sales_Tax_Item__r.Rate__c from Applicable_Taxes__c where Sales_Tax__c IN : salesTaxIdList];
        
        Map<Id, Decimal> salesTaxIdToTaxRateMap = new Map<Id, Decimal>();
        
        for(Applicable_Taxes__c appTax : applicableTaxList) {
            List<Applicable_Taxes__c> appTaxRecordList = new List<Applicable_Taxes__c>();
            if(salesTaxIdToAppTaxRecordsMap.containsKey(appTax.Sales_Tax__c)) {
                appTaxRecordList = salesTaxIdToAppTaxRecordsMap.get(appTax.Sales_Tax__c);
            } 
            appTaxRecordList.add(appTax);
            salesTaxIdToAppTaxRecordsMap.put(appTax.Sales_Tax__c, appTaxRecordList);
            if(!salesTaxIdToTaxRateMap.containsKey(appTax.Sales_Tax__c)) {
                salesTaxIdToTaxRateMap.put(appTax.Sales_Tax__c, 0);
            }
            appTax.Sales_Tax_Item__r.Rate__c = appTax.Sales_Tax_Item__r.Rate__c != null ? appTax.Sales_Tax_Item__r.Rate__c : 0;
            salesTaxIdToTaxRateMap.put(appTax.Sales_Tax__c, salesTaxIdToTaxRateMap.get(appTax.Sales_Tax__c) + appTax.Sales_Tax_Item__r.Rate__c);
        }
        
        List<Individual_Tax__c> individualTaxToInsert = new List<Individual_Tax__c>();
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        for(CO_Line_Item__c coLineItemRec : COLineItemNewList) {
            if(coLineItemRec.Kit_Header_Line_Item__c != null) {
                continue;
            }
            if(String.isNotBlank(coLineItemRec.Deal__c)) {
                if(isTaxIncludingPricing && coLineItemRec.Price__c != null) {
                    coLineItemRec.Price_When_Tax_Included__c = coLineItemRec.Price__c;
                }
                continue;
            }
            
            Id salesTaxId;
            Boolean isInternalTaxLI = false;
            if(coLineItemRec.Service_Order_Line_Item__c != null && soliMap.containsKey(coLineItemRec.Service_Order_Line_Item__c) && 
                        soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__r.Job_Type__c == 'Internal') {
                salesTaxId = GeneralConfiguration.getDefaultSalesTaxOnInternalService();
                isInternalTaxLI = true;
            }
            
            if(String.isBlank(salesTaxId)) {
                if(coLineItemRec.Part__c != null && partIdToPartRecordMap.get(coLineItemRec.Part__c).Applicable_Tax__c != null) {
                    salesTaxId = partIdToPartRecordMap.get(coLineItemRec.Part__c).Applicable_Tax__c;
                } else if(coLineItemRec.Fee__c != null && feeIdToFeeRecordMap.get(coLineItemRec.Fee__c).Applicable_Tax__c != null) {
                    salesTaxId = feeIdToFeeRecordMap.get(coLineItemRec.Fee__c).Applicable_Tax__c;
                } 
            }
            if(salesTaxId == null) {
                if(isTaxIncludingPricing && coLineItemRec.Price__c != null) {
                    coLineItemRec.Price_When_Tax_Included__c = coLineItemRec.Price__c;
                }
                continue;
            }
            Decimal exemptionRate = 0;
            if(salesTaxIdToAppTaxRecordsMap.containsKey(salesTaxId)) {
                for(Applicable_Taxes__c appTax : salesTaxIdToAppTaxRecordsMap.get(salesTaxId)) {

                    if(coLineItemRec.Service_Order_Line_Item__c != null && soliMap.containsKey(coLineItemRec.Service_Order_Line_Item__c) 
                        && soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__r.Provider__c != null
                        && soHeaderIdToSalesTaxItemIdsMap.containsKey(soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__c) &&
                        soHeaderIdToSalesTaxItemIdsMap.get(soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__c).contains(appTax.Sales_Tax_Item__c)) {
                        exemptionRate += appTax.Sales_Tax_Item__r.Rate__c;
                        
                    } else if((coLineItemRec.Service_Order_Line_Item__c == null || 
                                (soliMap.containsKey(coLineItemRec.Service_Order_Line_Item__c) 
                                && soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__r.Job_Type__c != 'Internal' 
                                && soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Header__r.Provider__c == null))
                            && coHeaderIdToCoHeaderRecMap.containsKey(coLineItemRec.CO_Header__c) 
                            && coHeaderIdToCoHeaderRecMap.get(coLineItemRec.CO_Header__c).Customer__c != null 
                            && coHeaderIdToSalesTaxItemIdsMap.containsKey(coLineItemRec.CO_Header__c) 
                            && coHeaderIdToSalesTaxItemIdsMap.get(coLineItemRec.CO_Header__c).contains(appTax.Sales_Tax_Item__c)) {
                            exemptionRate += appTax.Sales_Tax_Item__r.Rate__c;
                    }
                }
            }
            Decimal rate = 0;
            if(salesTaxIdToTaxRateMap.containsKey(salesTaxId)) {
                rate = salesTaxIdToTaxRateMap.get(salesTaxId);
            }
            
            coLineItemRec.Tax__c = (coLineItemRec.Deal__c == null) ? (rate - exemptionRate) : 0;
            
            if(isTaxIncludingPricing) {
                if(coLineItemRec.Type__c == Constants.SHOP_SUPPLY) {
                    coLineItemRec.Price_When_Tax_Included__c = (coLineItemRec.Price__c + (coLineItemRec.Price__c * rate / 100).setScale(2, RoundingMode.HALF_UP));
                    coLineItemRec.Price__c = (coLineItemRec.Price_When_Tax_Included__c / (1 + coLineItemRec.Tax__c / 100).setScale(2, RoundingMode.HALF_UP));
                } else if(coLineItemRec.Price__c != null && (isInternalTaxLI || coLineItemRec.Price_When_Tax_Included__c == null || exemptionRate != 0)) {
                    coLineItemRec.Price_When_Tax_Included__c = (coLineItemRec.Price__c + (coLineItemRec.Price__c * coLineItemRec.Tax__c / 100).setScale(2, RoundingMode.HALF_UP));
                }
            }
        }
    }
    
    public static void beforeUpdateCalculation() {
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Part_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<CO_Line_Item__c> coLineItemList = [select part__c, part__r.Qty_Committed__c, part__r.AvailableParts__c, Qty__c, Retail__c, Price__c, CO_Status__c,
                                                    CO_Header__c, CO_Header__r.Customer__r.Sales_Tax__c, CO_Header__r.Customer__r.Price_Level__r.Part_Price_Base__c, 
                                                    Merchandise_Commit_Order_controls__c, CO_Header__r.Customer__r.Price_Level__r.Discount_Markup__c, 
                                                    Is_In_Merch_Section__c, Service_Order_Line_Item__c,
                                                    Service_Order_Line_Item__r.Fixed_Price__c, Service_Order_Line_Item__r.Service_Order_Kit_Header__c, Part__r.Non_Inventory_Part__c
                                                    from CO_Line_Item__c where Id IN: trigger.new];        
        Set<Id> partIdSet = new Set<Id>();
        partIdToNonInventoryFlagMap.clear();
        for(CO_Line_Item__c coLineItemRec : coLineItemList) {
            if(coLineItemRec.Part__c != null) {
                if(! partIdToNonInventoryFlagMap.containsKey(coLineItemRec.Part__c)) {
                    partIdToNonInventoryFlagMap.put(coLineItemRec.Part__c, coLineItemRec.Part__r.Non_Inventory_Part__c);
                }
            }
            if(coLineItemRec.part__c != null) {
                partIdSet.add(coLineItemRec.part__c);
            }
        }
        partIdToPartRecordMap = new Map<Id, Part__c>([select Id, Average_Cost__c, Applicable_Tax__c, Applicable_Tax__r.Rate__c, 
                                                                        Last_Cost__c, MSRP__c, Retail_Price__c, AvailableParts__c,Qty_In_Stock__c, 
                                                                        Qty_Committed__c, (select Sales_Tax_Item__c from Part_Taxes__r) 
                                                                        from Part__c where Id IN : partIdSet]);
        Map<Id, Sobject> colineItemIdToPartRecordMap = new Map<Id, Sobject>();
        
        for(CO_Line_Item__c coliRec : COLineItemNewList) {
            colineItemIdToPartRecordMap.put(coliRec.Id, partIdToPartRecordMap.get(coliRec.part__c));
            if(coliRec.Part__c != null && entryConditionForQtyCommitToZero(coliRec)) {
                coliRec.Qty_Committed__c = 0;
            }
        }
        
        // Entry Condition of Qty Committed Logic.
        List<CO_Line_Item__c> validCOLIList = getValidListForBeforeUpdateCommittedLogic();
        if(isActivateQuoteCO) {
            validCOLIList = COLineItemNewList;
        }
        if(validCOLIList.size() > 0) {
            qytComittedLogic(partIdToPartRecordMap, validCOLIList);
        }
        if(isVOLIRecToChange) {
            insertVOLineItem();
            isActivateQuoteCO = false;
        }
        priceLevelCalculation(partIdToPartRecordMap);
        //system.assert(false, coLineItemList);
    }
    
    /**
     * Name: beforeDeleteOperation
     * Desc: Returned Committed quantity to the part record before deleting to any CO Line Item
     * @param: 
     * @return: 
    **/
    public static void beforeDeleteOperation() {
        
        returnPartCommittedQty();
        deleteOtherRelatedRecords();
    }
    
    
    public static void afterUpdateCalculation() {
        if(!isTriggerExecute) {
            if(Test.isRunningTest() || system.isFuture()) {
                updateCOInvoiceItemOfKitHeader(COLineItemNewList);
            } else {
                updateCOInvoiceItemOfKitHeader_Future(new List<Id>(COLineItemNewMap.keySet()));
            }
            //updateCOInvoiceItemOfKitHeader();
            UpdateCOInvoiceItems();
            isTriggerExecute = true;
        }
    }
    
    //Added by SUbhrant singh ticket no 149
   public static void UpdateCOInvoiceItems() {
        List<CO_Invoice_Item__c> coInvItemListToUpdate = new List<CO_Invoice_Item__c>();
        Set<Id> coHeaderIdSet = new Set<Id>();
        for(CO_Line_Item__c coLineItemRec : COLineItemNewList) {
            coHeaderIdSet.add(coLineItemRec.CO_Header__c);
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        List<CO_Line_Item__c> coliList = [Select Qty_Committed__c, Qty__c, CO_Header__c, Part__c, Part__r.Non_Inventory_Part__c, 
                                                    (Select IsActive__c from CO_Invoice_Items__r) 
                                                FROM CO_Line_Item__c where Id IN: COLineItemNewList AND CO_Status__c != 'Closed'];
        
        List<CO_Invoice_Header__c> coInvoiceHeaderList = 
                    [select Invoice_Status__c, CO_Header__c, (select Id from CO_Invoice_Payments__r) 
                            from CO_Invoice_Header__c where CO_Header__c IN :coHeaderIdSet AND Invoice_Status__c = 'Active'];
                            
        Map<Id, CO_Invoice_Header__c> coHeaderIdToCOInvoiceHeaderRecMap = new Map<Id, CO_Invoice_Header__c>();
        for(CO_Invoice_Header__c coInvoiceHeaderRec : coInvoiceHeaderList) {
            coHeaderIdToCOInvoiceHeaderRecMap.put(coInvoiceHeaderRec.CO_Header__c, coInvoiceHeaderRec);
        }
        
        CO_Invoice_Item__c coInvoiceItemRec;
        for(CO_Line_Item__c coLineItemRec : coliList) {
            if((coLineItemRec.Qty_Committed__c <= 0 && coLineItemRec.Qty__c > 0) || 
                (coHeaderIdToCOInvoiceHeaderRecMap.containsKey(coLineItemRec.CO_Header__c) && 
                    coHeaderIdToCOInvoiceHeaderRecMap.get(coLineItemRec.CO_Header__c).CO_Invoice_Payments__r.size() > 0)) {
               if(coLineItemRec.CO_Invoice_Items__r.size() > 0) {
                    coInvoiceItemRec = new CO_Invoice_Item__c(Id = coLineItemRec.CO_Invoice_Items__r[0].Id);
                    if(coLineItemRec.Part__c != null && coLineItemRec.Part__r.Non_Inventory_Part__c) {
                        coInvoiceItemRec.isActive__c = true;
                    }
                    coInvItemListToUpdate.add(coInvoiceItemRec);
               }
            } else {
                if(coLineItemRec.CO_Invoice_Items__r.size() > 0) {
                    coInvoiceItemRec = new CO_Invoice_Item__c(Id = coLineItemRec.CO_Invoice_Items__r[0].Id);
                    coInvoiceItemRec.isActive__c = true;
                    coInvItemListToUpdate.add(coInvoiceItemRec);
                }   
            }
        }
        if(coInvItemListToUpdate.size() >  0){
            if(AccessControl.ifObjectIsUpdateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update coInvItemListToUpdate;
        }
   }

    public static void priceLevelCalculation(Map<Id, Part__c> partIdToPartRecordMap) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Id> coHeaderIdList = new List<Id>();
        List<Id> soliIdList = new List<Id>();
        Set<Id> feeIdSet = new Set<Id>();
        Boolean isDealItemExists = false;
        
        for(CO_Line_Item__c coliRec : COLineItemNewList) {
            coHeaderIdList.add(coliRec.CO_Header__c); 
            if(coliRec.Service_Order_Line_Item__c != null) {
                soliIdList.add(coliRec.Service_Order_Line_Item__c);
            }
            if(coliRec.Fee__c != null) {
                feeIdSet.add(coliRec.Fee__c);
            }
            if(String.isNotBlank(coliRec.Deal__c)) {
                isDealItemExists = true;
            }
        }
        
        List<Price_Level__c> defaultPriceLevel;
        if(isDealItemExists) {
            defaultPriceLevel = SOTriggerHelper.getInternalDefaultPriceLevel();
            if(defaultPriceLevel == null || defaultPriceLevel.size() == 0) {
                defaultPriceLevel = SOTriggerHelper.getDefaultPriceLevel();
            }
        }
        
        coHeaderIdToCoHeaderRecMap = new Map<Id, CO_Header__c>([select Discount_Markup_From_Prive_Level__c, Part_Price_Base_From_Price_Level__c
                                                                                            from CO_Header__c Where Id IN : coHeaderIdList]);
        if(feeIdSet.size() > 0) {
            feeIdToFeeRecordMap = new Map<Id, Fee__c>([select Price__c, Taxable__c, Applicable_Tax__c, Applicable_Tax__r.Rate__c
                                                                        from Fee__c where Id IN: feeIdSet]); 
        }
        if(soliIdList.size() > 0) {
            soliMap = new Map<Id, Service_Order_Line_Item__c>([select Service_Order_Kit_Header__c, Service_Order_Header__c, Service_Order_Header__r.Provider__c, 
                Service_Order_Header__r.Job_Type__c, Service_Order_Header__r.Provider_Part_Price_Base__c, Service_Order_Header__r.Provider_Discount_Markup__c, 
                Service_Order_Header__r.CO_Header__r.CO_Type__c from Service_Order_Line_Item__c where Id IN: soliIdList]);
        }
        
        for(CO_Line_Item__c coLineItemRec : COLineItemNewList) {
            if(coLineItemRec.Kit_Header_Line_Item__c != null || 
            	(coLineItemRec.Service_Order_Line_Item__c != null && soliMap.get(coLineItemRec.Service_Order_Line_Item__c).Service_Order_Kit_Header__c != null)) {
                continue;
            }
            Price_Level__c appliedPriceLevel = getAppliedPriceLevel(coLineItemRec, soliMap, defaultPriceLevel, coHeaderIdToCoHeaderRecMap.get(coLineItemRec.CO_Header__c));
            TaxCalculation.partPriceCalculation1(appliedPriceLevel.Part_Price_Base__c, appliedPriceLevel.Discount_Markup__c, coLineItemRec, partIdToPartRecordMap, feeIdToFeeRecordMap);
        }
    }
    
    // change for handling Oversold records
    public static void qytComittedLogic(Map<Id, Part__c> partIdToPartRecordMap, List<CO_Line_Item__c> validCOLIList) {
        if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        for(CO_Line_Item__c coLineItem : validCOLIList) {
            if(coLineItem.Part__c == null || (isActivateQuoteCO && getMerchandiseCommitOrderControlSetting(coLineItem) == Constants.UNCOMIITTED)) {
                 continue;
            }
            if(partIdToPartRecordMap.get(coLineItem.Part__c).Qty_Committed__c == null) {
                partIdToPartRecordMap.get(coLineItem.Part__c).Qty_Committed__c = 0;
            }
            
            Decimal committedPartQty = partIdToPartRecordMap.get(coLineItem.Part__c).Qty_Committed__c;
            
            if(coLineItem.Qty__c < 0) {
                if(coLineItem.Qty_Committed__c != null && coLineItem.Qty_Committed__c > 0) {
                	coLineItem.Oversold_Qty__c = coLineItem.Oversold_Qty__c != null ? coLineItem.Oversold_Qty__c : 0;
                    partIdToPartRecordMap.get(coLineItem.Part__c).put('Qty_Committed__c', committedPartQty - (coLineItem.Qty_Committed__c - coLineItem.Oversold_Qty__c));
                    coLineItem.Qty_Committed__c = coLineItem.Oversold_Qty__c = 0;
                }
                continue;
            } 
            
            Decimal qtyAvailable =  partIdToPartRecordMap.get(coLineItem.Part__c).Qty_In_Stock__c -  partIdToPartRecordMap.get(coLineItem.Part__c).Qty_Committed__c;
            
            coLineItem.Qty_Committed__c = (coLineItem.Qty_Committed__c == null) ? 0 : coLineItem.Qty_Committed__c;
            
            Decimal qtyRequried = coLineItem.Qty__c - coLineItem.Qty_Committed__c;
            if(COLineItemNewMap.get(coLineItem.Id).Qty_Committed__c != COLineItemOldMap.get(coLineItem.Id).Qty_Committed__c) {
                coLineItem.Oversold_Qty__c = (coLineItem.Oversold_Qty__c == null) ? 0 : coLineItem.Oversold_Qty__c;
                
                Decimal CommitedQtyDifference =  COLineItemNewMap.get(coLineItem.Id).Qty_Committed__c - (COLineItemOldMap.get(coLineItem.Id).Qty_Committed__c  - coLineItem.Oversold_Qty__c)  ;
                decimal estimatedQtyWithoutOverSold  = (qtyAvailable + (COLineItemOldMap.get(coLineItem.Id).Qty_Committed__c - coLineItem.Oversold_Qty__c) - (COLineItemNewMap.get(coLineItem.Id).Qty_Committed__c));
                if(estimatedQtyWithoutOverSold >= 0){
                    partIdToPartRecordMap.get(coLineItem.Part__c).put('Qty_Committed__c', committedPartQty + CommitedQtyDifference);
                    coLineItem.Oversold_Qty__c = 0;
                }else{
                    Decimal estimatedOversold = COLineItemNewMap.get(coLineItem.Id).Qty_Committed__c -(qtyAvailable + (COLineItemOldMap.get(coLineItem.Id).Qty_Committed__c  - coLineItem.Oversold_Qty__c));  
                    partIdToPartRecordMap.get(coLineItem.Part__c).put('Qty_Committed__c', committedPartQty + qtyAvailable);
                    coLineItem.Oversold_Qty__c = estimatedOversold;
                }
            }else{
                if(qtyRequried <= qtyAvailable) {
                    coLineItem.Qty_Committed__c = coLineItem.Qty__c;
                    partIdToPartRecordMap.get(coLineItem.Part__c).put('Qty_Committed__c', committedPartQty + qtyRequried);
                } else {
                    coLineItem.Qty_Committed__c = COLineItemOldMap.get(coLineItem.Id).Qty_Committed__c + qtyAvailable;
                    partIdToPartRecordMap.get(coLineItem.Part__c).put('Qty_Committed__c', committedPartQty + qtyAvailable);
                }
            }
        }
        
        if(partIdToPartRecordMap.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update partIdToPartRecordMap.values();
        }
    }
    
    /**
     * Name: getDefaultSalesTax
     * Desc: Popualte List of default sales tax by querying from database.
     * @param: 
     * @return: 
    **/
    private static List<Sales_Tax__c> getDefaultSalesTax() {
        if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return [select Rate__c from Sales_Tax__c where default__c = true];
    }
    
    
    private static void returnPartCommittedQty() {
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        Set<Id> partIdSet = new Set<Id>();
        for(CO_Line_Item__c coLineItem : COLineItemOldList) {
            if(coLineItem.Part__c != null) {
                partIdSet.add(coLineItem.Part__c);
            }
        }
        Map<Id, Part__c> partIdToPartRecordMap = new Map<Id, Part__c>([select Id, Qty_Committed__c, Non_Inventory_Part__c from Part__c where Id IN : partIdSet]);
        
        partIdToNonInventoryFlagMap.clear();
        for(Part__c partRec : partIdToPartRecordMap.values()) {
            if(!partIdToNonInventoryFlagMap.containsKey(partRec.Id)) {
                partIdToNonInventoryFlagMap.put(partRec.Id, partRec.Non_Inventory_Part__c);
            }
        }
        for(CO_Line_Item__c coLineItem : COLineItemOldList) {
            if(coLineItem.Part__c == null || coLineItem.Qty__c < 0) {
                continue;
            } else if((coLineItem.Part__c != null) && (partIdToNonInventoryFlagMap.containsKey(coLineItem.Part__c)) && (partIdToNonInventoryFlagMap.get(coLineItem.Part__c))) {
                continue;
            }
            if(partIdToPartRecordMap.get(coLineItem.Part__c).Qty_Committed__c == null) {
                partIdToPartRecordMap.get(coLineItem.Part__c).Qty_Committed__c = 0;
            } 
            if(coLineItem.Qty_Committed__c == null) {
                coLineItem.Qty_Committed__c = 0;
            }
           
            partIdToPartRecordMap.get(coLineItem.Part__c).Qty_Committed__c -= (coLineItem.Qty_Committed__c - (coLineItem.Oversold_Qty__c != null ? coLineItem.Oversold_Qty__c : 0) );
        }
        if(partIdToPartRecordMap.size() > 0) {
            update partIdToPartRecordMap.values();
        }
    }
    
    
    private static void deleteOtherRelatedRecords() {
        if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        List<CO_Line_Item__c> coLineItemList = [select Id, 
                                                    (Select Vendor_Order_Header__c, Vendor_Order_Header__r.Status__c from Vendor_Order_Line_Items__r ),
                                                    (Select Id from CO_Invoice_Items__r ) from CO_Line_Item__c where Id IN :COLineItemOldList];
        
        List<Vendor_Order_Line_Item__c> voliListToDel = new List<Vendor_Order_Line_Item__c>();
        List<Vendor_Order_Line_Item__c> voliListToUpdate = new List<Vendor_Order_Line_Item__c>();
        List<CO_Invoice_Item__c> coInvoiceItemListToDel = new List<CO_Invoice_Item__c>();
         
        for(CO_Line_Item__c coliRec : coLineItemList) {
            if(coliRec.Vendor_Order_Line_Items__r.size() > 0) {
                Vendor_Order_Line_Item__c voLineItemRec = coliRec.Vendor_Order_Line_Items__r[0];
                if(voLineItemRec.Vendor_Order_Header__c == null || voLineItemRec.Vendor_Order_Header__r.Status__c == 'Open' 
                    || voLineItemRec.Vendor_Order_Header__r.Status__c == 'Locked') {
                        voliListToDel.addAll(coliRec.Vendor_Order_Line_Items__r);       
                } else {
                    voLineItemRec = convertIntoReuiqredForStock(voLineItemRec);
                    voliListToUpdate.add(voLineItemRec);
                }
            }
            
            if(coliRec.CO_Invoice_Items__r.size() > 0) {
                coInvoiceItemListToDel.addAll(coliRec.CO_Invoice_Items__r);
            }
        }
        
        if(voliListToUpdate.size() > 0 && !isMoveLineItem) {
            //VendorOrderLineItemTriggerHelper.isUpdateQtyOnSubmittedGroup = true;
            update voliListToUpdate;    
        }
        
        if(voliListToDel.size() > 0 && !isMoveLineItem) {
            if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            VendorOrderLineItemTriggerHelper.shouldTriggerRun = true;
            delete voliListToDel;
        }
        if(coInvoiceItemListToDel.size() > 0){
            if(AccessControl.ifObjectIsDeletable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete coInvoiceItemListToDel;
        }
    }
    
    /**
     * Name: insertCOInvoiceLineItem
     * Desc: Insert CO Invoice Item when CO Line Item is inserted
     * @param: 
     * @return: 
    **/
    public static void insertCOInvoiceLineItem() {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        List<Id> coHeaderIdList = new List<Id>();
        for(CO_Line_Item__c coLineItemRec : COLineItemNewList) {
            if(coLineItemRec.Service_Order_Line_Item__c == null && coLineItemRec.CO_Kit_Header__c == null) {
                coHeaderIdList.add(coLineItemRec.CO_Header__c);
            }
        }
        if(coHeaderIdList.size() == 0) {
            return;
        }
        
        List<CO_Invoice_Header__c> coInvoiceHeaderList = [select Id, Invoice_Status__c, CO_Header__c, (select Id from CO_Invoice_Payments__r), (select Id, isActive__c, Is_Invoiceable__c from CO_Invoice_Items__r where Deal__c != null) from CO_Invoice_Header__c where CO_Header__c IN :coHeaderIdList AND Invoice_Status__c = 'Active'];
        Map<Id, CO_Invoice_Header__c> coHeaderIdToCOInvoiceHeaderRecMap = new Map<Id, CO_Invoice_Header__c>();
        for(CO_Invoice_Header__c coInvoiceHeaderRec : coInvoiceHeaderList) {
            coHeaderIdToCOInvoiceHeaderRecMap.put(coInvoiceHeaderRec.CO_Header__c, coInvoiceHeaderRec);
        }

        List<CO_Invoice_Item__c> coInvoiceItemToInsert = new List<CO_Invoice_Item__c>();
        for(CO_Line_Item__c coLineItemRec : COLineItemNewList) {
            CO_Invoice_Item__c coInvoiceItemRec = new CO_Invoice_Item__c();
            if(coHeaderIdToCOInvoiceHeaderRecMap.containsKey(coLineItemRec.CO_Header__c)) {
                coInvoiceItemRec.CO_Invoice_Header__c = coHeaderIdToCOInvoiceHeaderRecMap.get(coLineItemRec.CO_Header__c).Id;
                
                if(String.isNotBlank(coLineItemRec.Deal__c) && coHeaderIdToCOInvoiceHeaderRecMap.get(coLineItemRec.CO_Header__c).CO_Invoice_Items__r.size() > 0) {
                    if(coHeaderIdToCOInvoiceHeaderRecMap.get(coLineItemRec.CO_Header__c).CO_Invoice_Items__r[0].Is_Invoiceable__c) {
                        /*CO_Invoice_Item__c coInvoiceItemRecToUpdate = new CO_Invoice_Item__c(Id = coHeaderIdToCOInvoiceHeaderRecMap.get(coLineItemRec.CO_Header__c).CO_Invoice_Items__r[0].Id);
                        coInvoiceItemRecToUpdate.Is_Invoiceable__c = false;
                        coInvoiceItemRecToUpdate.isActive__c = false;
                        coInvoiceItemToInsert.add(coInvoiceItemRecToUpdate);*/
                    }
                }
            } else {
                CO_Invoice_Header__c coInvoiceHeaderRec = insertCOInvoiceHeader(coLineItemRec.CO_Header__c);
                coInvoiceItemRec.CO_Invoice_Header__c = coInvoiceHeaderRec.Id;
                coHeaderIdToCOInvoiceHeaderRecMap.put(coInvoiceHeaderRec.CO_Header__c, coInvoiceHeaderRec);
            }
            coInvoiceItemRec.CO_Line_Item__c = coLineItemRec.Id;
            // Change by subhrant singh ticket 149
            if((coLineItemRec.Qty_Committed__c  <= 0 && coLineItemRec.Qty__c > 0) || coHeaderIdToCOInvoiceHeaderRecMap.get(coLineItemRec.CO_Header__c).CO_Invoice_Payments__r.size() > 0) {
                coInvoiceItemRec.isActive__c = false;
            } else {
                coInvoiceItemRec.isActive__c = true;
            }
            
            if(coLineItemRec.Part__c != null && partIdToNonInventoryFlagMap.containsKey(coLineItemRec.Part__c) && partIdToNonInventoryFlagMap.get(coLineItemRec.Part__c)) {
                coInvoiceItemRec.isActive__c = true;
            } else if(coLineItemRec.Fee__c != null && coLineItemRec.Is_Environmental_Fee__c){
                coInvoiceItemRec.isActive__c = coInvoiceItemRec.Is_Invoiceable__c = true;
            }
            
            coInvoiceItemToInsert.add(coInvoiceItemRec);
        }       
        if(coInvoiceItemToInsert.size() > 0) {
            //insert coInvoiceItemToInsert;
            upsert coInvoiceItemToInsert;
        }
    }
    
    /**
     * Name: updateCOInvoiceItemOfKitHeader
     * Desc: Insert CO Invoice Item when CO Line Item is inserted
     * @param: 
     * @return: 
    **/
    @future
    public static void updateCOInvoiceItemOfKitHeader_Future(List<Id> coliIdList) {
        List<Id> cokhIdList = new List<Id>();
        List<CO_Line_Item__c> colineItemList = [Select Id, CO_Kit_Header__c from CO_Line_Item__c where Id IN: coliIdList];
        updateCOInvoiceItemOfKitHeader(colineItemList);
    }
    
    private static void updateCOInvoiceItemOfKitHeader(List<CO_Line_Item__c> coLineItemList) {
        List<Id> cokhIdList = new List<Id>();
        for(CO_Line_Item__c coLineItemRec : coLineItemList) {
            if(coLineItemRec.CO_Kit_Header__c != null) {
                cokhIdList.add(coLineItemRec.CO_Kit_Header__c);
            }
        }
        if(cokhIdList.size() == 0) {
            return;
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Kit_Header__c> cokitHeaderList = [select Id, (select Id, Part__c, Part__r.Non_Inventory_Part__c, Qty_To_Order__c from CO_Line_Items__r 
                                                where Part__c != null AND Part__r.Non_Inventory_Part__c = false AND Qty_To_Order__c > 0), 
                                                        (select Is_Invoiceable__c from CO_Invoice_Items__r) 
                                                        from CO_Kit_Header__c where Id IN: cokhIdList];
                                                        
        List<CO_Invoice_Item__c> coInvoiceItemListToUpdate = new List<CO_Invoice_Item__c>();
        
        for(CO_Kit_Header__c cokhRec : cokitHeaderList) {
            Boolean isInvoiceable = true;
            for(CO_Line_Item__c coliRec : cokhRec.CO_Line_Items__r) {
                if(coliRec.Part__c != null && !coliRec.Part__r.Non_Inventory_Part__c && coliRec.Qty_To_Order__c > 0) {
                    isInvoiceable = false;
                    break;
                }
            }
            if(cokhRec.CO_Invoice_Items__r.size() > 0) {
                cokhRec.CO_Invoice_Items__r[0].Is_Invoiceable__c = isInvoiceable;
                coInvoiceItemListToUpdate.add(cokhRec.CO_Invoice_Items__r[0]);
            }
        }
        
        if(coInvoiceItemListToUpdate.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update coInvoiceItemListToUpdate;
        }
    }
    
    
    /**
     * Name: insertCOInvoiceHeader
     * Desc: Insert CO Invoice Header rec
     * @param: (1) coHeaderId - Id - CO Header Id 
     * @return: CO_Invoice_Header__c - inserted record of CO Invoice Header
    **/
    public static CO_Invoice_Header__c insertCOInvoiceHeader(Id coHeaderId) {
        if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        
        CO_Invoice_Header__c coInvoiceHeaderRec = new CO_Invoice_Header__c();
        coInvoiceHeaderRec.CO_Header__c = coHeaderId;
        coInvoiceHeaderRec.Invoice_Status__c = 'Active';
        insert coInvoiceHeaderRec;
        return coInvoiceHeaderRec;
    }
    
    private static Boolean entryConditionForChangingVOLI() {
        Boolean isValidEntry = false;
        for(CO_Line_Item__c coLineItemRec : COLineItemNewList) {
            if(coLineItemRec.CO_Status__c == Constants.CO_STATUS_QUOTE) {
                isValidEntry = false;
            } else if(isActivateQuoteCO || (Trigger.isInsert && coLineItemRec.Part__c != null && 
                                                coLineItemRec.Qty__c > coLineItemRec.Qty_Committed__c)) {
                isValidEntry = true;
            } else if(Trigger.isUpdate 
                && COLineItemNewMap.get(coLineItemRec.Id).Part__c != null 
                && (COLineItemNewMap.get(coLineItemRec.Id).Qty__c != COLineItemOldMap.get(coLineItemRec.Id).Qty__c ||
                    COLineItemNewMap.get(coLineItemRec.Id).Qty_Committed__c != COLineItemOldMap.get(coLineItemRec.Id).Qty_Committed__c || 
                    isCommitOrderControlSettingChanged(coLineItemRec))
                ) {
                    isValidEntry = true;
                    if(!isVOLIInsertFromVRPage) {
                        isValidEntry = false;
                    }
            }
        }
        return isValidEntry;
    }
    
    public static void insertVOLineItem_Updated() {
        
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        // Entry Condition
        if(!entryConditionForChangingVOLI()) {
            return;
        }
        
        List<Vendor_Order_Line_Item__c> voLineItemsToUpsert = new List<Vendor_Order_Line_Item__c>();
        List<Vendor_Order_Line_Item__c> submittedVOLineItemsToUpsert = new List<Vendor_Order_Line_Item__c>();
        List<Vendor_Order_Line_Item__c> voLineItemsToDelete = new List<Vendor_Order_Line_Item__c>();
        Map<Id, Vendor_Order_Line_Item__c> existingVOLineItemMap = new Map<Id, Vendor_Order_Line_Item__c>(
                                                                        [select Id, Vendor_Order_Header__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Line_Item_Group__c, CO_Line_Item__c, Is_Received__c
                                                                         from Vendor_Order_Line_Item__c where CO_Line_Item__c IN : COLineItemNewList 
                                                                            AND Is_Received__c = false]);
        
        Map<Id, Id> coLineItemIdToOpenVOLineItemIdMap = new Map<Id, Id>();
        Map<Id, Id> coLineItemIdToSubmittedVOLineItemIdMap = new Map<Id, Id>();
        for(Vendor_Order_Line_Item__c voLineItemRec : existingVOLineItemMap.values()) {
            if(voLineItemRec.Vendor_Order_Header__c == null || voLineItemRec.Vendor_Order_Header__r.Status__c == 'Open' 
                        || voLineItemRec.Vendor_Order_Header__r.Status__c == 'Locked') {
                if(!coLineItemIdToOpenVOLineItemIdMap.containsKey(voLineItemRec.CO_Line_Item__c)) {
                    coLineItemIdToOpenVOLineItemIdMap.put(voLineItemRec.CO_Line_Item__c, voLineItemRec.Id);
                }
            } else {
                if(!coLineItemIdToSubmittedVOLineItemIdMap.containsKey(voLineItemRec.CO_Line_Item__c)) {
                    coLineItemIdToSubmittedVOLineItemIdMap.put(voLineItemRec.CO_Line_Item__c, voLineItemRec.Id);
                }
            }
        }

        Vendor_Order_Line_Item__c voLineItemRec;
        List<CO_Line_Item__c> coLineItemListToUpdate = new List<CO_line_Item__c>();
        for(CO_Line_Item__c coLineItemRec : COLineItemNewList) {
            voLineItemRec = new Vendor_Order_Line_Item__c();
            if(coLineItemRec.Part__c != null && getMerchandiseCommitOrderControlSetting(coLineItemRec) == Constants.COMMIT_AND_ORDER
                    && (partIdToPartRecordMap.containsKey(coLineItemRec.Part__c) && !partIdToPartRecordMap.get(coLineItemRec.Part__c).Non_Inventory_Part__c) 
                    && coLineItemRec.Qty__c > coLineItemRec.Qty_Committed__c ) {
                voLineItemRec.CO_Header__c = coLineItemRec.CO_Header__c;
                voLineItemRec.CO_Line_Item__c = coLineItemRec.Id;
                voLineItemRec.Part__c = coLineItemRec.Part__c;
                voLineItemRec.Qty_Needed__c = coLineItemRec.Qty__c - coLineItemRec.Qty_Committed__c;
                
                if(partIdToPartRecordMap.containsKey(voLineItemRec.Part__c)) {
                    voLineItemRec.Line_Item_Cost__c = partIdToPartRecordMap.get(voLineItemRec.Part__c).Last_Cost__c;
                }
                
                if(coLineItemRec.Service_Order_Line_Item__c != null){
                    voLineItemRec.Is_Service__c = true;
                } else {
                    voLineItemRec.Is_required_For_Customer__c = true;
                }
                
                if(coLineItemIdToSubmittedVOLineItemIdMap.containsKey(coLineItemRec.Id)) {
                    voLineItemRec.Id = coLineItemIdToSubmittedVOLineItemIdMap.get(coLineItemRec.Id);
                    if(trigger.isUpdate) {
                        coLineItemRec.Status__c = (existingVOLineItemMap.get(voLineItemRec.Id).Vendor_Order_Line_Item_Group__c == null) ?
                                                'Required' : 'Ordered';
                    } else if(trigger.isInsert) {
                        CO_Line_Item__c coliRec = new CO_Line_Item__c(Id = coLineItemRec.Id);
                        coliRec.Status__c = (existingVOLineItemMap.get(voLineItemRec.Id).Vendor_Order_Line_Item_Group__c == null) ?
                                                'Required' : 'Ordered';
                        coLineItemListToUpdate.add(coliRec);
                    }
                    submittedVOLineItemsToUpsert.add(voLineItemRec);
                
                } else if(coLineItemIdToOpenVOLineItemIdMap.containsKey(coLineItemRec.Id)) {
                    voLineItemRec.Id = coLineItemIdToOpenVOLineItemIdMap.get(coLineItemRec.Id);
                    if(trigger.isUpdate) {
                        coLineItemRec.Status__c = (existingVOLineItemMap.get(voLineItemRec.Id).Vendor_Order_Line_Item_Group__c == null) ?
                                                'Required' : 'Ordered';
                    } else if(trigger.isInsert) {
                        CO_Line_Item__c coliRec = new CO_Line_Item__c(Id = coLineItemRec.Id);
                        coliRec.Status__c = (existingVOLineItemMap.get(voLineItemRec.Id).Vendor_Order_Line_Item_Group__c == null) ?
                                                'Required' : 'Ordered';
                        coLineItemListToUpdate.add(coliRec);
                    }
                    voLineItemsToUpsert.add(voLineItemRec);
                }  else {
                    if(trigger.isUpdate) {
                        coLineItemRec.Status__c = 'Required';
                    } else if(trigger.isInsert) {
                        CO_Line_Item__c coliRec = new CO_Line_Item__c(Id = coLineItemRec.Id);
                        coliRec.Status__c = 'Required';
                        coLineItemListToUpdate.add(coliRec);
                    }
                    voLineItemsToUpsert.add(voLineItemRec);
                }
            } else {
                if(coLineItemIdToOpenVOLineItemIdMap.containsKey(coLineItemRec.Id)) {
                    voLineItemRec.Id = coLineItemIdToOpenVOLineItemIdMap.get(coLineItemRec.Id);
                    if(trigger.isUpdate) {
                        coLineItemRec.Status__c = 'In Stock';
                    } else if(trigger.isInsert) {
                        CO_Line_Item__c coliRec = new CO_Line_Item__c(Id = coLineItemRec.Id);
                        coliRec.Status__c = 'In Stock';
                        coLineItemListToUpdate.add(coliRec);
                    }
                    voLineItemsToDelete.add(voLineItemRec);
                } else if(coLineItemIdToSubmittedVOLineItemIdMap.containsKey(coLineItemRec.Id)) {
                    voLineItemRec.Id = coLineItemIdToSubmittedVOLineItemIdMap.get(coLineItemRec.Id);
                    if(trigger.isUpdate) {
                        coLineItemRec.Status__c = 'In Stock';
                    } else if(trigger.isInsert) {
                        CO_Line_Item__c coliRec = new CO_Line_Item__c(Id = coLineItemRec.Id);
                        coliRec.Status__c = 'In Stock';
                        coLineItemListToUpdate.add(coliRec);
                    }
                    voLineItemRec = convertIntoReuiqredForStock(voLineItemRec);
                    voLineItemsToUpsert.add(voLineItemRec);
                }
            }
        }
        if(voLineItemsToUpsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            VendorOrderLineItemTriggerHelper.isUpdateQtyOnGroup = true;
            upsert voLineItemsToUpsert;
        }
        
        if(submittedVOLineItemsToUpsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            VendorOrderLineItemTriggerHelper.isUpdateQtyOnSubmittedGroup = true;
            upsert submittedVOLineItemsToUpsert;
        }
        
        if(voLineItemsToDelete.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            VendorOrderLineItemTriggerHelper.shouldTriggerRun = true;
            delete voLineItemsToDelete;
        }
        
        if(coLineItemListToUpdate.size() > 0) {
            COLineItemTriggerHelper.isForceStopTrigger = true;
            update coLineItemListToUpdate;
            COLineItemTriggerHelper.isForceStopTrigger = false;
        }
    }
    
    /**
     * Name: insertVOLineItem
     * Desc: Insert VO Line Item if Status is required
     * @param: 
     * @return: 
    **/
    public static void insertVOLineItem() {
        
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        // Entry Condition
        if(!entryConditionForChangingVOLI()) {
            return;
        }
        
        Set<Id> partIdSet = new Set<Id>();
        for(CO_Line_Item__c coLineItemRec : COLineItemNewList) {
            if(coLineItemRec.part__c != null) {
                partIdSet.add(coLineItemRec.part__c);
            } 
        }
        Map<Id, Part__c> partIdToPartRecordMap = new Map<Id, Part__c>([select Id, Average_Cost__c, Last_Cost__c, MSRP__c, Retail_Price__c, 
                                                                        Part_Number__c, Description__c, 
                                                                        AvailableParts__c, Qty_Committed__c, Applicable_Tax__c, Applicable_Tax__r.Rate__c, Non_Inventory_Part__c
                                                                        from Part__c where Id IN : partIdSet]);
        
        
        List<Vendor_Order_Line_Item__c> voLineItemsToUpsert = new List<Vendor_Order_Line_Item__c>();
        List<Vendor_Order_Line_Item__c> submittedVOLineItemsToUpsert = new List<Vendor_Order_Line_Item__c>();
        List<Vendor_Order_Line_Item__c> voLineItemsToDelete = new List<Vendor_Order_Line_Item__c>();
        Map<Id, Vendor_Order_Line_Item__c> existingVOLineItemMap = new Map<Id, Vendor_Order_Line_Item__c>(
                                                                        [select Id, Vendor_Order_Header__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Line_Item_Group__c, CO_Line_Item__c, Is_Received__c
                                                                         from Vendor_Order_Line_Item__c where CO_Line_Item__c IN : COLineItemNewList 
                                                                            AND Is_Received__c = false]);
        
        Map<Id, Id> coLineItemIdToOpenVOLineItemIdMap = new Map<Id, Id>();
        Map<Id, Id> coLineItemIdToSubmittedVOLineItemIdMap = new Map<Id, Id>();
        for(Vendor_Order_Line_Item__c voLineItemRec : existingVOLineItemMap.values()) {
            if(voLineItemRec.Vendor_Order_Header__c == null || voLineItemRec.Vendor_Order_Header__r.Status__c == 'Open' 
                        || voLineItemRec.Vendor_Order_Header__r.Status__c == 'Locked') {
                if(!coLineItemIdToOpenVOLineItemIdMap.containsKey(voLineItemRec.CO_Line_Item__c)) {
                    coLineItemIdToOpenVOLineItemIdMap.put(voLineItemRec.CO_Line_Item__c, voLineItemRec.Id);
                }
            } else {
                if(!coLineItemIdToSubmittedVOLineItemIdMap.containsKey(voLineItemRec.CO_Line_Item__c)) {
                    coLineItemIdToSubmittedVOLineItemIdMap.put(voLineItemRec.CO_Line_Item__c, voLineItemRec.Id);
                }
            }
        }
        Vendor_Order_Line_Item__c voLineItemRec;
        List<CO_Line_Item__c> coLineItemListToUpdate = new List<CO_line_Item__c>();
        for(CO_Line_Item__c coLineItemRec : COLineItemNewList) {
            voLineItemRec = new Vendor_Order_Line_Item__c();
            if(coLineItemRec.Part__c != null && getMerchandiseCommitOrderControlSetting(coLineItemRec) == Constants.COMMIT_AND_ORDER && 
                        (partIdToNonInventoryFlagMap.containsKey(coLineItemRec.Part__c) && 
                        !partIdToNonInventoryFlagMap.get(coLineItemRec.Part__c)) && coLineItemRec.Qty__c > coLineItemRec.Qty_Committed__c ) {
                voLineItemRec.CO_Header__c = coLineItemRec.CO_Header__c;
                voLineItemRec.CO_Line_Item__c = coLineItemRec.Id;
                voLineItemRec.Part__c = coLineItemRec.Part__c;
                voLineItemRec.Qty_Needed__c = coLineItemRec.Qty__c - coLineItemRec.Qty_Committed__c;
                
                if(partIdToPartRecordMap.containsKey(voLineItemRec.Part__c)) {
                    voLineItemRec.Line_Item_Cost__c = partIdToPartRecordMap.get(voLineItemRec.Part__c).Last_Cost__c;
                }
                
                if(coLineItemRec.Service_Order_Line_Item__c != null){
                    voLineItemRec.Is_Service__c = true;
                } else {
                    voLineItemRec.Is_required_For_Customer__c = true;
                }
                
                if(coLineItemIdToSubmittedVOLineItemIdMap.containsKey(coLineItemRec.Id)) {
                    voLineItemRec.Id = coLineItemIdToSubmittedVOLineItemIdMap.get(coLineItemRec.Id);
                    if(trigger.isUpdate) {
                        coLineItemRec.Status__c = (existingVOLineItemMap.get(voLineItemRec.Id).Vendor_Order_Line_Item_Group__c == null) ?
                                                'Required' : 'Ordered';
                    } else if(trigger.isInsert) {
                        CO_Line_Item__c coliRec = new CO_Line_Item__c(Id = coLineItemRec.Id);
                        coliRec.Status__c = (existingVOLineItemMap.get(voLineItemRec.Id).Vendor_Order_Line_Item_Group__c == null) ?
                                                'Required' : 'Ordered';
                        coLineItemListToUpdate.add(coliRec);
                    }
                    submittedVOLineItemsToUpsert.add(voLineItemRec);
                
                } else if(coLineItemIdToOpenVOLineItemIdMap.containsKey(coLineItemRec.Id)) {
                    voLineItemRec.Id = coLineItemIdToOpenVOLineItemIdMap.get(coLineItemRec.Id);
                    if(trigger.isUpdate) {
                        coLineItemRec.Status__c = (existingVOLineItemMap.get(voLineItemRec.Id).Vendor_Order_Line_Item_Group__c == null) ?
                                                'Required' : 'Ordered';
                    } else if(trigger.isInsert) {
                        CO_Line_Item__c coliRec = new CO_Line_Item__c(Id = coLineItemRec.Id);
                        coliRec.Status__c = (existingVOLineItemMap.get(voLineItemRec.Id).Vendor_Order_Line_Item_Group__c == null) ?
                                                'Required' : 'Ordered';
                        coLineItemListToUpdate.add(coliRec);
                    }
                    voLineItemsToUpsert.add(voLineItemRec);
                }  else {
                    if(trigger.isUpdate) {
                        coLineItemRec.Status__c = 'Required';
                    } else if(trigger.isInsert) {
                        CO_Line_Item__c coliRec = new CO_Line_Item__c(Id = coLineItemRec.Id);
                        coliRec.Status__c = 'Required';
                        coLineItemListToUpdate.add(coliRec);
                    }
                    voLineItemsToUpsert.add(voLineItemRec);
                }
            } else {
                if(coLineItemIdToOpenVOLineItemIdMap.containsKey(coLineItemRec.Id)) {
                    voLineItemRec.Id = coLineItemIdToOpenVOLineItemIdMap.get(coLineItemRec.Id);
                    if(trigger.isUpdate) {
                        coLineItemRec.Status__c = 'In Stock';
                    } else if(trigger.isInsert) {
                        CO_Line_Item__c coliRec = new CO_Line_Item__c(Id = coLineItemRec.Id);
                        coliRec.Status__c = 'In Stock';
                        coLineItemListToUpdate.add(coliRec);
                    }
                    voLineItemsToDelete.add(voLineItemRec);
                } else if(coLineItemIdToSubmittedVOLineItemIdMap.containsKey(coLineItemRec.Id)) {
                    voLineItemRec.Id = coLineItemIdToSubmittedVOLineItemIdMap.get(coLineItemRec.Id);
                    if(trigger.isUpdate) {
                        coLineItemRec.Status__c = 'In Stock';
                    } else if(trigger.isInsert) {
                        CO_Line_Item__c coliRec = new CO_Line_Item__c(Id = coLineItemRec.Id);
                        coliRec.Status__c = 'In Stock';
                        coLineItemListToUpdate.add(coliRec);
                    }
                    voLineItemRec = convertIntoReuiqredForStock(voLineItemRec);
                    voLineItemsToUpsert.add(voLineItemRec);
                }
            }
        }
        if(voLineItemsToUpsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            VendorOrderLineItemTriggerHelper.isUpdateQtyOnGroup = true;
            upsert voLineItemsToUpsert;
        }
        
        if(submittedVOLineItemsToUpsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            VendorOrderLineItemTriggerHelper.isUpdateQtyOnSubmittedGroup = true;
            upsert submittedVOLineItemsToUpsert;
        }
        if(voLineItemsToDelete.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            VendorOrderLineItemTriggerHelper.shouldTriggerRun = true;
            delete voLineItemsToDelete;
        }
        
        if(coLineItemListToUpdate.size() > 0) {
            update coLineItemListToUpdate;
        }
    }
    
    private static Vendor_Order_Line_Item__c convertIntoReuiqredForStock(Vendor_Order_Line_Item__c voLineItemRec) {
        voLineItemRec.Is_Service__c = false;
        voLineItemRec.Is_required_For_Customer__c = false;
        voLineItemRec.CO_Line_Item__c = null;
        voLineItemRec.CO_Header__c = null;
        voLineItemRec.Is_Excess__c = true;
        return voLineItemRec;
    }
    
    /* START: Added By Tarun - #170 - 09/23/2016 */
    private static void populateDescription(Map<Id, Part__c> partIdToPartRecordMap) {
        Set<Id> feeIdSet = new Set<Id>();
        for(CO_Line_Item__c coLineItemRec : COLineItemNewList) {
            if(coLineItemRec.Fee__c != null) {
                feeIdSet.add(coLineItemRec.Fee__c);
            }
        }
        Map<Id, Fee__c> feeIdToFeeRecordMap = new Map<Id, Fee__c>();
        if(feeIdSet.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            feeIdToFeeRecordMap = new Map<Id, Fee__c>([select Code__c, Description__c, Applicable_Tax__c from Fee__c where Id IN: feeIdSet]); 
        }
        
        for(CO_Line_Item__c coLineItemRec : COLineItemNewList) {
            if(coLineItemRec.Part__c != null && partIdToPartRecordMap.containsKey(coLineItemRec.Part__c)) {
                coLineItemRec.Item_Code__c = partIdToPartRecordMap.get(coLineItemRec.Part__c).Part_Number__c;
                coLineItemRec.Item_Description__c = partIdToPartRecordMap.get(coLineItemRec.Part__c).Description__c;
                coLineItemRec.Applicable_Tax__c = partIdToPartRecordMap.get(coLineItemRec.Part__c).Applicable_Tax__c;
            
            } else if(coLineItemRec.Fee__c != null && feeIdToFeeRecordMap.containsKey(coLineItemRec.Fee__c)) {
                if(coLineItemRec.Item_Code__c == null){
                    coLineItemRec.Item_Code__c = feeIdToFeeRecordMap.get(coLineItemRec.Fee__c).Code__c;
                }
                if(coLineItemRec.Item_Description__c == null){
                    coLineItemRec.Item_Description__c = feeIdToFeeRecordMap.get(coLineItemRec.Fee__c).Description__c;   
                }
                coLineItemRec.Applicable_Tax__c = feeIdToFeeRecordMap.get(coLineItemRec.Fee__c).Applicable_Tax__c;
            }
        }
    }
    
    
    public static void populateOrderTotal() {
        List<CO_Line_Item__c> coliListToProcess = Trigger.isDelete ? COLineItemOldList : COLineItemNewList;
        List<String> coHeaderIdList = new List<String>(); 
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        if(isTotalCalculated) {
            return;
        }
        isTotalCalculated = true;
        for(CO_Line_Item__c coLineItemRec : coliListToProcess) { 
            if(coLineItemRec.CO_Header__c != null) {
                coHeaderIdList.add(coLineItemRec.CO_Header__c);
            }
        }
        if(isTaxIncludingPricing) {
            populateTaxAmountWhenTaxIncluded(coliListToProcess, coHeaderIdList[0]);
        } else {
            if(coHeaderIdList.size() > 0) {
                TaxCalculation.setTotalForMerchSection(coHeaderIdList[0]);
            }
        }
    }
    
    private static void populateTaxAmountWhenTaxIncluded(List<CO_Line_Item__c> coliListToProcess, String coHeaderId) {
        populateTotals(coHeaderId);
    }
    
    private static void populateTotals(String coHeaderId) {
        CO_Header__c coHeaderRec = TaxCalculation.populateOrderTotal(coHeaderId, true);
    }
    
    public static void populateStatusAndTotalsForMerchSection() {
        List<CO_Line_Item__c> coliListToProcess = Trigger.isDelete ? COLineItemOldList : COLineItemNewList;
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Set<Id> coHeaderIdList = new Set<Id>();
        for(CO_Line_Item__c coLineItemRec : coliListToProcess) { 
            if(coLineItemRec.Is_In_Merch_Section__c) {
                coHeaderIdList.add(coLineItemRec.CO_Header__c);
            }
        }
        if(coHeaderIdList.size() > 0) {
            if(System.isFuture()) {
                List<CO_Header__c> coHeaderListToUpdate = updateStatusAndTotalsForMerchSectionOnCOHeader(coHeaderIdList);
                if(coHeaderListToUpdate.size() > 0) {
                    COTriggerHelper.isForceStopTrigger = true;
                    update coHeaderListToUpdate;
                    COTriggerHelper.isForceStopTrigger = false;
                }
            } else {
                updateStatusAndTotalsForMerchSectionOnCOHeader_Future(coHeaderIdList);
            }
        }
    }
    
    @future
    public static void updateStatusAndTotalsForMerchSectionOnCOHeader_Future(Set<Id> coHeaderIdList) {
        List<CO_Header__c> coHeaderListToUpdate = updateStatusAndTotalsForMerchSectionOnCOHeader(coHeaderIdList);
        if(coHeaderListToUpdate.size() > 0) {
            COTriggerHelper.isForceStopTrigger = true;
            update coHeaderListToUpdate;
            COTriggerHelper.isForceStopTrigger = false;
        }
    }
    
    public static List<CO_Header__c> updateStatusAndTotalsForMerchSectionOnCOHeader(Set<Id> coHeaderIdList) {
        List<CO_Line_Item__c> coliList = [SELECT Id, CO_Header__c, Part__c, Fee__c, Qty__c , Price__c, Closed_CO_Invoice_link__c,
                                            Adjusted_Cost_Coli__c, Part__r.Average_Cost__c, Fee__r.Cost_Method__c,
                                            Fee__r.Cost_Rate__c, Fee_Cost__c, Sub_Total_With_Tax__c FROM CO_Line_Item__c WHERE CO_Header__c IN :coHeaderIdList AND Is_In_Merch_Section__c = true];
                                            
        Map<Id, List<CO_Line_Item__c>> coHeaderIdToCOLIList = new Map<Id, List<CO_Line_Item__c>>();
        Set<Id> coliSet = new Set<Id>();
        for(CO_Line_Item__c coliRec: coliList) {
            if(!coHeaderIdToCOLIList.containsKey(coliRec.CO_Header__c)) {
                coHeaderIdToCOLIList.put(coliRec.CO_Header__c, new List<CO_Line_Item__c>());
            }
            coHeaderIdToCOLIList.get(coliRec.CO_Header__c).add(coliRec);
            if((coliRec.Part__c != null || coliRec.Fee__c != null)) {
                coliSet.add(coliRec.Id);
            }
        }
        
        List<Individual_Tax__c> individualTaxRecords = new List<Individual_Tax__c>();
        if(coliSet.size() > 0) {
            individualTaxRecords = getIndividualTaxRecords(coliSet);
        }
        
        Map<Id, List<Individual_Tax__c>> coHeaderIdToAllIndividualTaxListMap = getIndividualTaxMap(individualTaxRecords, false);
        Map<Id, List<Individual_Tax__c>> coHeaderIdToInvoicedIndividualTaxListMap = getIndividualTaxMap(individualTaxRecords, true);
        
        List<Sales_Tax_Item__c> salesTaxItemList = [select Forms_Label__c, Name__c from Sales_Tax_Item__c limit: SOQLUtil.getAvailableQueryRowsLimit()];
        List<CO_Header__c> coHeaderListToUpdate = new List<CO_Header__c>();
        for(Id coHeaderId: coHeaderIdToCOLIList.keySet()) {
            Decimal preTaxPartTotal = 0;
            Decimal preTaxFeeTotal = 0;
            Decimal totalPartCost = 0;
            Integer invoicedCOLICount = 0;
            Decimal preTaxPartInvoicedTotal = 0;
            Decimal preTaxFeeInvoicedTotal = 0;
            for(CO_Line_Item__c coliRec: coHeaderIdToCOLIList.get(coHeaderId)) {
                coliRec.Price__c = (coliRec.Price__c != null) ? coliRec.Price__c : 0;
                coliRec.Qty__c = (coliRec.Qty__c != null) ? coliRec.Qty__c : 0;
                if(coliRec.Part__c != null) {
                    preTaxPartTotal += (coliRec.Qty__c*coliRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                    totalPartCost += (coliRec.Closed_CO_Invoice_link__c != null ? (coliRec.Adjusted_Cost_Coli__c != null ? coliRec.Adjusted_Cost_Coli__c : 0) :
                                (coliRec.Part__r.Average_Cost__c != null ? (coliRec.Part__r.Average_Cost__c * coliRec.Qty__c) : 0));
                    if(coliRec.Closed_CO_Invoice_link__c != null) {
                        preTaxPartInvoicedTotal += (coliRec.Qty__c*coliRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                        invoicedCOLICount++;
                    }
                } else if(coliRec.Fee__c != null) {
                    preTaxFeeTotal += (coliRec.Qty__c*coliRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                    if(coliRec.Closed_CO_Invoice_link__c != null) {
                        preTaxFeeInvoicedTotal += (coliRec.Qty__c*coliRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                        invoicedCOLICount++;
                    }
                }
            }
            String merchandiseStatus = Constants.ACTIVE;
            if(invoicedCOLICount > 0 && invoicedCOLICount < coHeaderIdToCOLIList.get(coHeaderId).size()) {
                merchandiseStatus = Constants.PARTIALLY_INVOICED;
            } else if(invoicedCOLICount == coHeaderIdToCOLIList.get(coHeaderId).size()) {
                merchandiseStatus = Constants.INVOICED;
            }
            Decimal taxAmount = 0;
            if(coHeaderIdToAllIndividualTaxListMap.size() > 0 && coHeaderIdToAllIndividualTaxListMap.containsKey(coHeaderId)) {
                taxAmount = getMerchandiseInvoicedTaxAmount(coHeaderIdToAllIndividualTaxListMap.get(coHeaderId), salesTaxItemList);
            }
            
            Decimal invoicedTaxAmount = 0;
            if(coHeaderIdToInvoicedIndividualTaxListMap.size() > 0 && coHeaderIdToInvoicedIndividualTaxListMap.containsKey(coHeaderId)) {
                invoicedTaxAmount = getMerchandiseInvoicedTaxAmount(coHeaderIdToInvoicedIndividualTaxListMap.get(coHeaderId), salesTaxItemList);
            }
            Decimal invoicedTotal = preTaxPartInvoicedTotal + preTaxFeeInvoicedTotal + invoicedTaxAmount;
            coHeaderListToUpdate.add(new CO_Header__c(Id = coHeaderId, Merchandise_Pre_Tax_Part_Total__c = preTaxPartTotal, 
                                                        Merchandise_Pre_Tax_Fee_Total__c = preTaxFeeTotal, Merchandise_Total_Part_Cost__c = totalPartCost,
                                                        Merchandise_Status__c = merchandiseStatus, Parts_And_Accessories_Invoiced_Total__c = invoicedTotal,
                                                        Parts_And_Accessories_Tax_Amount__c = taxAmount));
        }
        return coHeaderListToUpdate;
    }
    
    private static List<Individual_Tax__c> getIndividualTaxRecords(Set<Id> coliIds) {
        String query = 'SELECT CO_Line_Item__c, CO_Line_Item__r.Closed_CO_Invoice_link__c, CO_Line_Item__r.CO_Header__c, Tax_Rate__c, Form_Label__c, Sales_Tax_Item_Name__c, ';
        if(GeneralConfiguration.getTaxIncludingPricing()) {
            query += 'Tax_Amount__c, ';
        } else {
            query += 'Taxable_Amount__c, ';
        }
        query += 'Applicable_Tax__c, List_Tax_items_on_forms__c from Individual_Tax__c' + 
                 ' WHERE CO_Line_Item__c IN : coliIds';
        return Database.query(query);
    }
                 
    private static Map<Id, List<Individual_Tax__c>> getIndividualTaxMap(List<Individual_Tax__c> individualTaxRecords, Boolean isInvoiced) {
        Map<Id, List<Individual_Tax__c>> coHeaderIdToIndividualTaxListMap = new Map<Id, List<Individual_Tax__c>>();
        for(Individual_Tax__c individualTaxRec: individualTaxRecords) {
            if(isInvoiced) {
                if(individualTaxRec.CO_Line_Item__r.Closed_CO_Invoice_link__c != null) {
                    if(!coHeaderIdToIndividualTaxListMap.containsKey(individualTaxRec.CO_Line_Item__r.CO_Header__c)) {
                        coHeaderIdToIndividualTaxListMap.put(individualTaxRec.CO_Line_Item__r.CO_Header__c, new List<Individual_Tax__c>());
                    }
                    coHeaderIdToIndividualTaxListMap.get(individualTaxRec.CO_Line_Item__r.CO_Header__c).add(individualTaxRec);
                }
            } else {
                if(!coHeaderIdToIndividualTaxListMap.containsKey(individualTaxRec.CO_Line_Item__r.CO_Header__c)) {
                    coHeaderIdToIndividualTaxListMap.put(individualTaxRec.CO_Line_Item__r.CO_Header__c, new List<Individual_Tax__c>());
                }
                coHeaderIdToIndividualTaxListMap.get(individualTaxRec.CO_Line_Item__r.CO_Header__c).add(individualTaxRec);
            }
        }
        return coHeaderIdToIndividualTaxListMap;
    }
    
    private static Decimal getMerchandiseInvoicedTaxAmount(List<Individual_Tax__c> individualTaxList, List<Sales_Tax_Item__c> salesTaxItemList) {
        Decimal invoicedTaxAmount = 0;
        Map<String, Decimal> salesTaxNameToTaxValue = TaxCalculation.getTaxAmountWithFormLabel(individualTaxList, salesTaxItemList);
        for(String taxName : salesTaxNameToTaxValue.keySet()) {
            invoicedTaxAmount += salesTaxNameToTaxValue.get(taxName); 
        }
        return invoicedTaxAmount;
    }
}