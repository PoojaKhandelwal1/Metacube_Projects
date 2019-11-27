@isTest
private class SyncStockTradeInBatchTest {
    @testsetup
    private static void setup(){
    	IFW_IntegrationConfig__c IFWConfigRec = TestDataFactory.createIFWConfigForXero();
    	IFW_IntegrationConfigItem__c IFWConfigItemRec = TestDataFactory.createIFWConfigItemForXero(IFWConfigRec.Id);
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
    private static void test(){
    	Deal_Item__c dealItemRec = [SELECT Id, Type__c, Is_Stocked_In__c FROM Deal_Item__c LIMIT 1];
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
    	dealItemRec.Type__c = QBUtil.DEAL_ITEM_TYPE_TRADE_IN; 
    	dealItemRec.Is_Stocked_In__c = true;
    	update dealItemRec;
    	Test.stopTest(); 
    	dealItemRec = [SELECT Id, Available_For_Xero_Sync__c, Xero_Accounting_Id__c FROM Deal_Item__c WHERE Id=:dealItemRec.Id];
    	system.assertEquals(false ,dealItemRec.Available_For_Xero_Sync__c);
    	system.assertNotEquals(dealItemRec.Xero_Accounting_Id__c, null);
    }
}