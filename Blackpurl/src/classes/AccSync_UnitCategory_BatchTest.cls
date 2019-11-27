@isTest
private class AccSync_UnitCategory_BatchTest {
    
    @testsetup
    private static void setup(){
    	Account customer = TestDataFactory.createCustomer('Test001', 'Individual', 'Fname', 'Lname');
    	Unit_Make__c unitMake = TestDataFactory.createUnitMake('Test Unit Make', 'Tes', true);
    	Unit_Model__c unitModel = TestDataFactory.createUnitModel('Test Unit Model', 'Tes', true, unitMake.Id);
    	Unit_Sub_Model__c unitSubModel = TestDataFactory.createSubModel(unitModel);
    	
    	List<Customer_Owned_Unit__c> customerOwnedUnitList = new List<Customer_Owned_Unit__c>();
    	for(Integer i = 0; i < 20; i++){
    		Customer_Owned_Unit__c customerOwnedUnit = TestDataFactory.sampleCustomerOwnedUnit(customer.Id, unitMake.Id, unitModel.Id, 
    																														unitSubModel.Id, 'VIN001');
    		customerOwnedUnit.Avail_For_QB_Sync_Category__c = true;
    		customerOwnedUnitList.add(customerOwnedUnit);
    	}
    	insert customerOwnedUnitList;
    }
    
    @isTest
    private static void testRunUnitForSync(){
    	Test.startTest();
    	List<Customer_Owned_Unit__c> customerOwnedUnitList = [SELECT Id FROM Customer_Owned_Unit__c];
    	Set<Id> recordIdSet = new Set<Id>();
    	for(Customer_Owned_Unit__c customerOwnedUnit : customerOwnedUnitList){
    		recordIdSet.add(customerOwnedUnit.Id);
    	}
    	AccSync_UnitCategory_Batch.runUnitForSync(recordIdSet, 20);
    	Test.stopTest();
    	system.assertEquals(1, [SELECT Id FROM Account].size());
    }
    
    @isTest
    private static void test(){
    	Test.startTest();
    	List<Customer_Owned_Unit__c> customerOwnedUnitList = [SELECT Id FROM Customer_Owned_Unit__c];
    	Set<Id> recordIdSet = new Set<Id>();
    	for(Customer_Owned_Unit__c customerOwnedUnit : customerOwnedUnitList){
    		recordIdSet.add(customerOwnedUnit.Id);
    	}
    	AccSync_UnitCategory_Batch accSyncUnitCategory = new AccSync_UnitCategory_Batch();
    	accSyncUnitCategory.unitIdSet = recordIdSet;
    	Id batchId = Database.executeBatch(accSyncUnitCategory);
    	Test.stopTest();
    	system.assertEquals(1, [SELECT Id FROM Account].size());
    }
}