/**
 * Author: Tarun Khandelwal
 * Since: Jan 08, 2019
 * Name: PriceLevelService
 * Description: Service class for Price Level
**/
public without sharing class PriceLevelService {
    
    /**
     * Name: getInternalDefaultPriceLevel
     * Desc: Method to get Default Price Level In system
     * @param: 
     * @return:  List<Price_Level__c> - List of default price level. Ideally size of list - 1 
    **/
    public static List<Price_Level__c> getInternalDefaultPriceLevel() {
        String defaultPriceLevelId_Internal = GeneralConfiguration.getDefaultPriceLevelOnInternalService();
        if(String.isNotBlank(defaultPriceLevelId_Internal)) {
            if(AccessControl.ifObjectFieldIsAccessible('Price_Level__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Price_Level__c> priceLevelList = [Select Part_Price_Base__c, Discount_Markup__c, Labour_Rate__c from Price_Level__c 
                                                        where Id =: defaultPriceLevelId_Internal];
            return priceLevelList;
        }
        return null;
    }
    
    public static List<Price_Level__c> getDefaultPriceLevel() {
        if(AccessControl.ifObjectFieldIsAccessible('Price_Level__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Price_Level__c> defaultPriceLevel = [SELECT Part_Price_Base__c, Discount_Markup__c, Labour_Rate__c from Price_Level__c 
                                                    WHERE Default__c = true];
        return defaultPriceLevel;
    }
}