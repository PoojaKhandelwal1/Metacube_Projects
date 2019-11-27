/*
* This class has CRUD methods related to settings & controls section of Acoount Settings module
* Since : May 2018
*/
public without sharing class AccountSettingService {
    
	/*
	* This method returns the shop setting configuration 
	*/
    public static List<ShopSettingWrapper> getShopSettingData() {
    	List<ShopSettingWrapper> shopSettingData;
    	List<Shop_Settings__c> shopSettingList = [Select Name, Day__c, Is_Working__c, From_Time__c, To_Time__c 
    		                                          from Shop_Settings__c where Name != null order by Order_Number__c];
    	if(shopSettingList.size() > 0) {
    		shopSettingData = new List<ShopSettingWrapper>();
    		for(Shop_Settings__c shopSettingInstance : shopSettingList) {
    			shopSettingData.add(new ShopSettingWrapper(shopSettingInstance));
    		}
    	}
    	return shopSettingData;
    }
    
    public static List<ShopSettingWrapper> getShopSettingDataForParticularDay(String day) {
    	List<ShopSettingWrapper> shopSettingData;
    	List<Shop_Settings__c> shopSettingList = [Select Name, Day__c, Is_Working__c, From_Time__c, To_Time__c 
    		                                          from Shop_Settings__c where Name != null And Day__c =: day order by Order_Number__c];
    	if(shopSettingList.size() > 0) {
    		shopSettingData = new List<ShopSettingWrapper>();
    		for(Shop_Settings__c shopSettingInstance : shopSettingList) {
    			shopSettingData.add(new ShopSettingWrapper(shopSettingInstance));
    		}
    	}
    	return shopSettingData;
    }
    
    public static List<String> getShopWorkingDays() {
    	List<String> shopSettingWorkingDays;
    	List<Shop_Settings__c> shopSettingList = [Select Day__c from Shop_Settings__c where Is_Working__c = true order by CreatedDate];
    	if(shopSettingList.size() > 0) {
    		shopSettingWorkingDays = new List<String>();
    		for(Shop_Settings__c shopSettingInstance : shopSettingList) {
    			shopSettingWorkingDays.add(shopSettingInstance.Day__c);
    		}
    	}
    	return shopSettingWorkingDays;
    }
    
    /*
    * Utility method to convert list of wrapper object to list of actual salesforce object
    */
    public static List<Shop_Settings__c> setShopSettingConfigRec(List<ShopSettingWrapper> shopSettingWrapperList) {
        List<Shop_Settings__c> shopSettingList = new List<Shop_Settings__c>();
    	for(ShopSettingWrapper shopSettingInstance : shopSettingWrapperList) {
    		Shop_Settings__c shopSettingObject = new Shop_Settings__c();
	        shopSettingObject.Id = shopSettingInstance.Id;
	        shopSettingObject.Day__c = shopSettingInstance.Day;
	        shopSettingObject.Is_Working__c = shopSettingInstance.IsWorking;
	        shopSettingObject.From_Time__c = shopSettingInstance.FromTime;
	        shopSettingObject.To_Time__c = shopSettingInstance.ToTime;
    		shopSettingList.add(shopSettingObject);
        }
    	return shopSettingList;
    }
    
    public static Boolean isWorkingDayByDate(Date dateToCheck) {
        if(AccessControl.ifObjectFieldIsAccessible('Shop_Settings__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        String day = getDayNameFromDate(dateToCheck);
        List<Shop_Settings__c> shopSettingList = [Select Id from Shop_Settings__c where Day__c =: day AND Is_Working__c = true];
        return (shopSettingList.size() > 0);
    }
    
    public static String getDayNameFromDate(Date dateToCheck) {
        Datetime dt = DateTime.newInstance(dateToCheck, Time.newInstance(0, 0, 0, 0));
        return dt.format('EEEE');
    }
}