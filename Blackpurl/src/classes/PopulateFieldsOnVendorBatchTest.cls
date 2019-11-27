@isTest
private class PopulateFieldsOnVendorBatchTest {
     @testsetup
     private static void setup(){
     	Category__c categoryRec = TestDataFactory.createCategory('category001');
     	categoryRec.Type__c = 'Part';
     	categoryRec.Default__c = true;
     	update categoryRec;
     	
     	List<Account> vendorList = new List<Account>();
     	for(Integer i = 0; i < 20; i++){
     		vendorList.add(TestDataFactory.sampleVendor('vendor001'));
     	}
     	insert vendorList;
     }
     
     @isTest
     private static void test(){
     	Test.startTest();
     	Id batchId = Database.executeBatch(new PopulateFieldsOnVendorBatch());
     	Test.stopTest();
     	
     	Account vendor = [SELECT Id, Part_Category_Default__c FROM Account WHERE Is_vendor__c = true LIMIT 1];
     	Category__c categoryRec = [SELECT Id FROM Category__c LIMIT 1];
     	system.assertEquals(vendor.Part_Category_Default__c, categoryRec.ID);
     }
}