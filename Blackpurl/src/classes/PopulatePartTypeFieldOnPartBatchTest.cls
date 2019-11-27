@isTest
private class PopulatePartTypeFieldOnPartBatchTest {
    @testsetup
    private static void setup(){
    	Account vendor = TestDataFactory.createVendor('Test Vendor');
    	Category__c categoryRec = TestDataFactory.createCategory('category001');
    	Part__c part = TestDataFactory.createPart(vendor.Id,  10, 20, 50, 100, 100, categoryRec.Id);
    	part.Part_Type__c = null;
    	update part;
    }
    
    @isTest
    private static void test(){
    	Test.startTest();
    	Id batchId = Database.executeBatch(new PopulatePartTypeFieldOnPartBatch());
    	Test.stopTest();
    	Account vendor = [SELECT Id, Part_Purchases__c FROM Account WHERE Is_Vendor__c = true LIMIT 1];
		system.assertEquals(vendor.Part_Purchases__c, true);	
    }
}