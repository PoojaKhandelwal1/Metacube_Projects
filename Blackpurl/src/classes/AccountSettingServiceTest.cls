@isTest
public with sharing class AccountSettingServiceTest {
	
	@testSetup
   	private static void setup() {
   		Shop_Settings__c shopSettingDay2Rec = TestDataFactory.createShopSettings('2');
   		Shop_Settings__c shopSettingDay3Rec = TestDataFactory.createShopSettings('3');
   	}
   	
   	@isTest
   	private static void getShopSettingDataTest() {
   		system.assertEquals(AccountSettingService.getShopSettingData().size(), 2);
   	}
   	
   	@isTest
   	private static void getShopSettingDataForParticularDayTest() {
   		system.assertEquals(AccountSettingService.getShopSettingDataForParticularDay('2').size(), 1);
   	}
   	
   	@isTest
   	private static void getShopWorkingDaysTest() {
   		system.assertEquals(AccountSettingService.getShopWorkingDays().size(), 2);
   	}
   	
   	@isTest
   	private static void setShopSettingConfigRecTest() {
   		List<Shop_Settings__c> shopSettingsList = [SELECT Id, Day__c, Is_Working__c, From_Time__c, To_Time__c FROM Shop_Settings__c];
   		List<ShopSettingWrapper> shopSettingWrapperList = new List<ShopSettingWrapper>();
   		shopSettingWrapperList.add(new ShopSettingWrapper(shopSettingsList[0]));
   		shopSettingWrapperList.add(new ShopSettingWrapper(shopSettingsList[1]));
   		system.assertEquals(AccountSettingService.setShopSettingConfigRec(shopSettingWrapperList).size(), 2);
   	}
   	
   	@isTest
   	private static void isWorkingDayByDateTest() {
   		system.assertEquals(AccountSettingService.isWorkingDayByDate(Date.newInstance(2019,3,3)), false);
   	}
}