/**
 * Author: Rajat Jain
 * updated: May 25, 2018
 * Name: FusionMappingCtrlTest
 * Description: It includes scenario based test cases for FusionMappingCtrlTest.
**/

@isTest
private with sharing class FusionMappingCtrlTest {
	
	@testSetup
   	static void setup() {
		BPScriptUtility.insertFusionLineItems();
		List<Fusion_Report_Line_Item__c> fusionLineItemList = [Select Id from Fusion_Report_Line_Item__c];
		
		List<General_Account__c> listOfGLAccounts = new List<General_Account__c>();
		listOfGLAccounts.add(new General_Account__c(Accounting_Id__c='176', Account_Name__c='BP Shop Supplies', Account_Number__c='4311', Account_Type__c='Income'));
		listOfGLAccounts.add(new General_Account__c(Accounting_Id__c='166', Account_Name__c='BP Received Inventory Accrual', Account_Number__c='2200', Account_Type__c='Other Current Liability'));
		listOfGLAccounts.add(new General_Account__c(Accounting_Id__c='160', Account_Name__c='BP QA Tax Agency Payable', Account_Type__c='Other Current'));
		insert listOfGLAccounts;
		
		system.assert(fusionLineItemList.size() > 0);
	}
	static testMethod void getFusionLineItemsTest() {
		new FusionMappingCtrl();
		new FusionMappingCtrl(new NewHomePageCtrl());
		Test.startTest();
		String fusionLineIemJson = BPUtility.getDecodedString(FusionMappingCtrl.getFusionLineItems());
		List<FusionLineItemWrapper> fusionLineItemWrapperList =(List<FusionLineItemWrapper>) System.JSON.deserialize(fusionLineIemJson, List<FusionLineItemWrapper>.class);
		system.assert(fusionLineItemWrapperList.size() > 0);
		Test.stopTest(); 
	}
	
	static testMethod void getGeneralAccounts() {
		Test.startTest();
		String generalAccountsJson = BPUtility.getDecodedString(FusionMappingCtrl.getGeneralAccounts());
		List<GeneralAccountWrapper> generalAccountsWrapperList =(List<GeneralAccountWrapper>) System.JSON.deserialize(generalAccountsJson, List<GeneralAccountWrapper>.class);
		system.assert(generalAccountsWrapperList.size() > 0);
		Test.stopTest(); 
	}
	
	static testMethod void saveFusionLineItem() {
		List<Fusion_Report_Line_Item__c> fusionLineItemList = [Select Id from Fusion_Report_Line_Item__c];
		List<General_Account__c> listOfGLAccounts = [Select Id from General_Account__c];
		Test.startTest();
		String Id = BPUtility.getEncodedString(fusionLineItemList[0].Id);
		String jsonStr = BPUtility.getEncodedString(System.Json.serialize(listOfGLAccounts));
		String resultJson = BPUtility.getDecodedString(FusionMappingCtrl.saveFusionLineItem(Id,jsonStr));
		String result =(String) System.JSON.deserialize(resultJson, String.class);
		system.assertEquals('Success',result);
		try {
			String resultJs  = BPUtility.getDecodedString(FusionMappingCtrl.saveFusionLineItem(Id,''));	
		} catch(Exception e) {
			System.debug('error' + e);
		}
		
		Test.stopTest();
	}
	 
}