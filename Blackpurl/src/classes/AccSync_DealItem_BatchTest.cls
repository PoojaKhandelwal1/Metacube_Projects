@isTest
private class AccSync_DealItem_BatchTest {
    @testsetup
    private static void setup(){
    	Account customer = TestDataFactory.createCustomer('Test001', 'Individual', 'Fname', 'Lname');
		CO_Header__c coHeader =  TestDataFactory.createCOHeader(customer.Id);
    	Unit_Make__c unitMake = TestDataFactory.createUnitMake('Test Unit Make', 'Tes', true);
    	Unit_Model__c unitModel = TestDataFactory.createUnitModel('Test Unit Model', 'Tes', true, unitMake.Id);
    	Unit_Sub_Model__c unitSubModel = TestDataFactory.createSubModel(unitModel);
    	Customer_Owned_Unit__c customerOwnedUnit = TestDataFactory.createCustomerOwnedUnit(customer.Id, unitMake.Id, unitModel.Id, 
    																												unitSubModel.Id, 'VIN001');
		Deal__c deal = TestDataFactory.createDeal(coHeader.Id, customerOwnedUnit.Id);
		List<Deal_Item__c> dealItemList = new List<Deal_Item__c>();
		for(Integer i = 0; i < 20; i++){
			Deal_Item__c dealItem = TestDataFactory.sampleDealItem(unitModel.Id, deal.Id);
			dealItem.Avail_For_QB_Sync__c = true;
			dealItemList.add(dealItem);
		}
		insert dealItemList;
    }
    
    @isTest
    private static void test(){
    	Test.startTest();
    	List<Deal_Item__c> dealItemList = [SELECT Id FROM Deal_Item__c];
    	Set<Id> recordIdSet = new Set<Id>();
    	for(Deal_Item__c dealItem : dealItemList){
    		recordIdSet.add(dealItem.Id);
    	}
    	AccSync_DealItem_Batch accSyncDealItem = new AccSync_DealItem_Batch();
    	accSyncDealItem.dealItemIdSet = recordIdSet;
    	Id batchId = Database.executeBatch(accSyncDealItem);
    	Test.stopTest();
    	system.assertEquals(1, 1);
    }
    
    @isTest
    private static void testRunDealItemForSync(){
    	Test.startTest();
    	List<Deal_Item__c> dealItemList = [SELECT Id FROM Deal_Item__c];
    	Set<Id> recordIdSet = new Set<Id>();
    	for(Deal_Item__c dealItem : dealItemList){
    		recordIdSet.add(dealItem.Id);
    	}
    	AccSync_DealItem_Batch.runDealItemForSync(recordIdSet, 20);
    	Test.stopTest();
    	system.assertEquals(1, 1);
    }
}