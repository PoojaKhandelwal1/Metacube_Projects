@isTest
private class AccSync_LienPayout_Batch_SchedulerTest {
	
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';
	
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
		Deal_Item__c dealItem = TestDataFactory.createDealItem(unitModel.Id, deal.Id);
    }
    
    @isTest
    private static void test(){
    	Test.startTest();
    	Deal_Item__c dealItem = [SELECT Id FROM Deal_Item__c LIMIT 1];
    	Set<Id> recordIdSet = new Set<Id>();
    	recordIdSet.add(dealItem.Id);
    	String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new AccSync_LienPayout_Batch_Scheduler(recordIdSet, 1));
    	Test.stopTest();
    	system.assertEquals(1, [SELECT Id FROM Account].size());
    }
}