/** 
* Author: Tarun Khandelwal
* Since: Dec 28, 2017 
* Name: ShopSuppliesService
* Description: Apex class which contains all the method related to Shop Supplies calculation.
**/
public with sharing class ShopSuppliesService {
    
    public static void calculateShopSupplies(Labour_Code__c laborRec, String serviceJobId) {
        if(checkForValidLineItem(laborRec)) {
            shopSuppliesCalculation(serviceJobId);
        }
    }
    
    private static Boolean checkForServiceJobType(List<Service_Order_Header__c> soHeaderList) {
        Boolean isValid = true;
        if(soHeaderList.size() > 0) {
            if(soHeaderList[0].SO_Type__c == 'Internal Service' || soHeaderList[0].SO_Type__c == 'Deal' || soHeaderList[0].Deal__c != null ||
                   (soHeaderList[0].Transaction_Type__c != null && (soHeaderList[0].Transaction_Type__r.Type__c == 'Internal' || 
                   soHeaderList[0].Transaction_Type__r.Type__c == 'Stock Unit'))) {
                isValid = false;
            }
            /*if(soHeaderList[0].Service_Order_Line_Items__r.size() == 0) {
            	isValid = false;
            }*/
        }
        return isValid;
    }
    
    public static void shopSuppliesCalculation(String serviceJobId) {
        List<Service_Order_Header__c> soHeaderList = 
                [SELECT Deal__c, SO_Type__c, Transaction_Type__c, Transaction_Type__r.Type__c, 
                       (SELECT Labour_Code__c, Type__c, Qty_Needed__c, Kit_Price__c, Price_When_Tax_Included__c, CO_Line_Item__c, Tax__c FROM Service_Order_Line_Items__r 
                         WHERE Labour_Code__r.Calculate_Supplies__c = true OR Type__c =: Constants.SHOP_SUPPLY) 
                 FROM Service_Order_Header__c WHERE Id =: serviceJobId];
        //system.assert(false, soHeaderList);
        
        // Custom setting value.
        ShopSuppliesCustomSetting shopSuppliesObj = GeneralConfiguration.getShopSuppliesCalculationMethod();
        if(shopSuppliesObj != null) {
            if(String.isBlank(shopSuppliesObj.CalculationMethod) && shopSuppliesObj.CalculationMethod == Constants.NOT_CALCULATED) {
                return;
            }
        }
        
        if(!soHeaderList.isEmpty()) {
            if(!checkForServiceJobType(soHeaderList)) {
                return;
            }
            Decimal shopSupplyAmount = 0;
            Service_Order_Line_Item__c shopSupplyRec;
            for(Service_Order_Line_Item__c soliRec : soHeaderList[0].Service_Order_Line_Items__r) {
                if(soliRec.Labour_Code__c != null) {
                    shopSupplyAmount += getShopSupplyAmountPerLineItem(soliRec, shopSuppliesObj);
                } else if(soliRec.Type__c == Constants.SHOP_SUPPLY) {
                    shopSupplyRec = soliRec;
                }
            }
            if(shopSupplyAmount > shopSuppliesObj.MaximumPerInvoice) {
                shopSupplyAmount = shopSuppliesObj.MaximumPerInvoice;
            }
            
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            
            if(shopSupplyRec == null) {
                shopSupplyRec = new Service_Order_Line_Item__c();
                shopSupplyRec.Fee__c = shopSuppliesObj.ApplicableFee;
                shopSupplyRec.Service_Order_Header__c = serviceJobId;
                shopSupplyRec.Qty_Needed__c = 1;
                shopSupplyRec.Qty_Committed__c = 1;
                shopSupplyRec.Kit_Price__c = shopSupplyAmount;
                shopSupplyRec.Item_Code__c = shopSupplyRec.Item_Description__c = Constants.SHOP_SUPPLY;
                shopSupplyRec.Type__c = Constants.SHOP_SUPPLY;
                shopSupplyRec.Is_Hidden__c = true;
            }
            if(!isTaxIncludingPricing) {
                shopSupplyRec.Kit_Price__c = shopSupplyAmount;
            } else {
                shopSupplyRec.Price_When_Tax_Included__c = shopSupplyAmount;
                if(shopSupplyRec.Tax__c != null) {
                	shopSupplyRec.Kit_Price__c = (shopSupplyAmount / (1 + shopSupplyRec.Tax__c/100));
                }
            }
            
            Boolean isPopulateTotalOnServiceJob = ServiceOrderLineItemTriggerHelper.isTriggerExecuted;

            List<Sobject> sobjectListToDelete = new List<Sobject>();
            if(((!isTaxIncludingPricing && shopSupplyRec.Kit_Price__c == 0) || 
            	(isTaxIncludingPricing && shopSupplyRec.Price_When_Tax_Included__c == 0))) {
        		if(shopSupplyRec.Id != null) {
        		    sobjectListToDelete.add(shopSupplyRec);
        		    if(ServiceOrderLineItemTriggerHelper.isTriggerExecuted) {
        		        sobjectListToDelete.add(new CO_Line_Item__c(Id = shopSupplyRec.CO_Line_Item__c));
        		    }
        			delete sobjectListToDelete;
        		}
            } else {
                //ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
                upsert shopSupplyRec;
                //ServiceOrderLineItemTriggerHelper.isTriggerExecuted = true;
            }
            //system.assert(false, shopSupplyRec);
            
            if(isPopulateTotalOnServiceJob && !Test.isRunningTest()) {
                ServiceOrderLineItemTriggerHelper.populateIndividualTax(serviceJobId);
            }
        }
    }
    
    private static Decimal getShopSupplyAmountPerLineItem(Service_Order_Line_Item__c soliRec, ShopSuppliesCustomSetting shopSuppliesObj) {
        Decimal shopSupplyAmount = 0;
        if(shopSuppliesObj.CalculationMethod == Constants.FIXED_AMOUNT_PER_HOUR) {
            shopSupplyAmount = (soliRec.Qty_Needed__c * shopSuppliesObj.SuppliesRate);
        } else if(shopSuppliesObj.CalculationMethod == Constants.PERCENTAGE_OF_LABOR_TOTAL) {
            shopSupplyAmount = ((soliRec.Qty_Needed__c * soliRec.Kit_Price__c * shopSuppliesObj.SuppliesRate) / 100);
        	if(GeneralConfiguration.getTaxIncludingPricing()) {
        		soliRec.Price_When_Tax_Included__c = (soliRec.Price_When_Tax_Included__c != null) ? soliRec.Price_When_Tax_Included__c : 0;
        		shopSupplyAmount = ((soliRec.Qty_Needed__c * soliRec.Price_When_Tax_Included__c * shopSuppliesObj.SuppliesRate) / 100);
        	}
        }
        return shopSupplyAmount;
    }
    
    public static Boolean checkForValidLineItem(Labour_Code__c laborRec) {
        return laborRec.Calculate_Supplies__c;
    }
}