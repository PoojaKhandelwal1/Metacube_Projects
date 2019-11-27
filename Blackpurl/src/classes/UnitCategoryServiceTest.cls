@isTest 
public class UnitCategoryServiceTest {
	
	@testSetup
    private static void setupTestData() {
    	List<Account> customerList = new List<Account>();
    	List<Customer_Owned_Unit__c> customerOwnedUnitList = new List<Customer_Owned_Unit__c>();
    	for(Integer i = 0; i < 10; i++) {
            customerList.add(TestDataFactory.sampleCustomer('Test Customer' + i, 'Individual', 'Test', 'Customer' + i));
        }
        insert customerList;
        
        Unit_Make__c unitMake = TestDataFactory.createUnitMake('Unit Make', 'Te1', true);
    	Unit_Model__c unitModel = TestDataFactory.createUnitModel('Unit Model', 'Te1', true, unitMake.Id);
    	Unit_Sub_Model__c unitSubModel = TestDataFactory.createSubModel(unitModel);
    	for(Integer i = 0; i< 10; i++) {
    		Customer_Owned_Unit__c customerOwnedUnit = TestDataFactory.sampleCustomerOwnedUnit(customerList[0].Id, unitMake.Id, 
    			                                                                                     unitModel.Id, unitSubModel.Id, 'VIN1');
    		customerOwnedUnit.Avail_For_QB_Sync_Category__c = true;
    		customerOwnedUnitList.add(customerOwnedUnit);
    	}
    	insert customerOwnedUnitList; 
    	
    	General_Configurations__c genConfigRec  = TestDataFactory.sampleGeneralConfig(2);
    	genConfigRec.Enable_QB_Accounting__c = true;
    	insert genConfigRec;
    } 
    
    @isTest
    private static void syncUnitsTest() {
    	Test.startTest();
    	List<Customer_Owned_Unit__c> customerOwnedUnitList = [Select Id from Customer_Owned_Unit__c];
    	Set<Id> unitIdSet = (new Map<Id,SObject>(customerOwnedUnitList)).keySet();
    	UnitCategoryService.syncUnits(unitIdSet);
    	customerOwnedUnitList = [Select Id, Avail_For_QB_Sync_Category__c from Customer_Owned_Unit__c];
    	Test.stopTest();
    	system.assertEquals(customerOwnedUnitList[0].Avail_For_QB_Sync_Category__c, true);
    }
    
    @isTest
    private static void syncUnitsTestQuickBooks() {
    	TestDataFactory.createQBConfig();
    	Test.startTest();
    	List<Customer_Owned_Unit__c> customerOwnedUnitList = [Select Id from Customer_Owned_Unit__c];
    	Set<Id> unitIdSet = (new Map<Id,SObject>(customerOwnedUnitList)).keySet();
    	UnitCategoryService.syncUnits(unitIdSet);
    	Test.stopTest();
    	customerOwnedUnitList = [Select Id, Avail_For_QB_Sync_Category__c from Customer_Owned_Unit__c];
    	system.assertEquals(customerOwnedUnitList[0].Avail_For_QB_Sync_Category__c, false);
    }
    
    @isTest
    private static void syncUnitsTestQuickBooksStatus() {
    	TestDataFactory.createQBConfig();
    	Test.startTest();
    	List<Customer_Owned_Unit__c> customerOwnedUnitList = [Select Id from Customer_Owned_Unit__c];
    	Set<Id> unitIdSet = (new Map<Id,SObject>(customerOwnedUnitList)).keySet();
    	UnitCategoryService.syncUnits(unitIdSet);
    	Test.stopTest();
    	customerOwnedUnitList = [Select Id, Avail_For_QB_Sync_Category__c from Customer_Owned_Unit__c];
    	system.assertEquals(customerOwnedUnitList[0].Avail_For_QB_Sync_Category__c, false);
    }
    
    @isTest
    private static void syncUnitsTestQuickBooksStatusNot200() {
    	QuickBooks_Configurations__c qbConfig = TestDataFactory.sampleQBConfig();
    	qbConfig.End_Point_URL__c = '';
    	insert qbConfig;
    	Test.startTest();
    	List<Customer_Owned_Unit__c> customerOwnedUnitList = [Select Id from Customer_Owned_Unit__c];
    	Set<Id> unitIdSet = (new Map<Id,SObject>(customerOwnedUnitList)).keySet();
    	UnitCategoryService.syncUnits(unitIdSet);
    	Test.stopTest();
    	customerOwnedUnitList = [Select Id, Avail_For_QB_Sync_Category__c from Customer_Owned_Unit__c];
    	system.assertEquals(customerOwnedUnitList[0].Avail_For_QB_Sync_Category__c, true);
    }
}