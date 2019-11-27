@isTest
private class PopulateDefaultFieldOnPartBatchTest {
    @testsetup
    private static void setup(){
    	Account vendor = TestDataFactory.createVendor('Test Vendor');
    	vendor.Vendor_Code__c = 'vcode';
    	update vendor;
    	Category__c categoryRec = TestDataFactory.createCategory('category001');
    	Part__c part = TestDataFactory.createPart(vendor.Id,  10, 20, 50, 100, 100, categoryRec.Id);
    	part.Part_Number__c = 'pcode';
    	update part;
    }
    
    @isTest
    private static void test(){
    	Test.startTest();
    	Id batchId = Database.executeBatch(new PopulateDefaultFieldOnPartBatch());
    	Test.stopTest();
    	Part__c part = [SELECT Part_Id_Text__c FROM Part__c];
    	system.assertEquals('pcodevcode', part.Part_Id_Text__c);
    }
}