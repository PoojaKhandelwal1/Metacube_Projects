@isTest
private class AccSync_PartCategory_BatchTest {
    @testsetup
    private static void setup(){
    	Account vendor = TestDataFactory.createVendor('Test Vendor');
    	Category__c categoryRec = TestDataFactory.createCategory('category001');
    	Part__c part = TestDataFactory.createPart(vendor.Id,  10, 20, 50, 100, 100, categoryRec.Id);
    	part.Avail_For_QB_Sync_Category__c = true;
    	update part;
    }
    
    @isTest
    private static void testRunPartForSync(){
		Part__c part = [SELECT Id FROM Part__c LIMIT 1];
		Set<Id> partIdSet = new Set<Id>();
		partIdSet.add(part.Id);
    	Test.startTest();
    	AccSync_PartCategory_Batch.runPartForSync(partIdSet, 1);
    	Test.stopTest();
    	system.assertEquals(1, [SELECT Id FROM Account].size());
    }
    
    @isTest
    private static void test(){
    	Test.startTest();
    	Part__c part = [SELECT Id FROM Part__c LIMIT 1];
		Set<Id> partIdSet = new Set<Id>();
		partIdSet.add(part.Id);
		AccSync_PartCategory_Batch accSyncPartCategory = new AccSync_PartCategory_Batch();
		accSyncPartCategory.partIdSet = partIdSet;
    	Id batchId = Database.executeBatch(accSyncPartCategory);
    	Test.stopTest();
    	system.assertEquals(1, [SELECT Id FROM Account].size());
    }
}