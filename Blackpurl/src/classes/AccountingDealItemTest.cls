@isTest
public with sharing class AccountingDealItemTest {
	
    @testsetup
    public static void setup(){
    	Unit_Make__c unitMakeRec = TestDataFactory.createUnitMake('Test make', 'TES', true);
    	Unit_Model__c unitModelRec = TestDataFactory.createUnitModel('Test Model', 'TES', true, unitMakeRec.Id);
    	Account customerRec = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test', 'Customer');
    	CO_Header__c coHeaderRec = TestDataFactory.createCoHeader(customerRec.Id);
    	Unit_Sub_Model__c unitSubModelRec = TestDataFactory.createSubModel(unitModelRec);
    	Customer_Owned_Unit__c unitRec = TestDataFactory.createStockUnit(unitMakeRec.Id, unitModelRec.Id, unitSubModelRec.Id, 'TES');
    	Deal__c dealRec = TestDataFactory.createDeal(coHeaderRec.Id, unitRec.Id);
    	Deal_Item__c dealItemRec = TestDataFactory.createDealItem(unitModelRec.Id, dealRec.Id);
    }
    
    @isTest
    private static void accountingDealItemTest() {
    	Test.startTest();
    	List<Deal_Item__c> dealItemList = [SELECT Id, Stocked_In_Unit__r.Unit_Make__r.Name, Stocked_In_Unit__r.Unit_Model__r.Name__c, 
    	       Stocked_In_Unit__r.Sub_Model__r.Sub_Model_Name__c, Actual_Cash_Value__c, CreatedDate, Stocked_In_Unit__r.Category__r.Inventory_GL__c, 
    	       Accounting_Id__c, Sync_Token__c, Accounting_Response__c, Deal__r.id, Deal__r.CO_Header__r.Name FROM Deal_Item__c];
    	AccountingDealItem accountingDealItemRec = new AccountingDealItem(dealItemList[1]);
    	Test.stopTest();
    	system.assertEquals([SELECT Id FROM Deal_Item__c].size(), 2);
    }
    
    @isTest
    private static void fieldsListTest() {
    	Test.startTest();
    	system.assertEquals(true, AccountingDealItem.fieldsList().size() > 0);
    	Test.stopTest();
    }
}