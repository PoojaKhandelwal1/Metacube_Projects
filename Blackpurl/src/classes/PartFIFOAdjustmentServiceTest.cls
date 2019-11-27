@isTest
private class PartFIFOAdjustmentServiceTest {
    @testsetup
    private static void setup(){
    	Account vendor = TestDataFactory.createVendor('Test Vendor');
    	Category__c categoryRec = TestDataFactory.createCategory('category001');
    	Part__c part = TestDataFactory.createPart(vendor.Id,  10, 20, 50, 100, 5, categoryRec.Id);
    }
    
    @isTest
    private static void testAdjustPartQty(){
    	Test.startTest();
    	Part__c partRec = [SELECT Id FROM Part__c LIMIT 1];
    	PartFIFOAdjustmentService.PartCountAjustmentWrapper partCountAjustmentWrapper = new PartFIFOAdjustmentService.PartCountAjustmentWrapper(partRec.Id, 10, 100);
    	Map<Id, PartFIFOAdjustmentService.PartCountAjustmentWrapper> partIdToCountAjustmentWrapperMap = new Map<Id, PartFIFOAdjustmentService.PartCountAjustmentWrapper>();
    	partIdToCountAjustmentWrapperMap.put(partRec.Id, partCountAjustmentWrapper);
    	List<Part_FIFO_Bucket__c> result = PartFIFOAdjustmentService.adjustPartQty(partIdToCountAjustmentWrapperMap);
    	system.assertEquals(result.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testAdjustLessPartQty(){
    	Test.startTest();
    	Part__c partRec = [SELECT Id FROM Part__c LIMIT 1];
    	PartFIFOAdjustmentService.PartCountAjustmentWrapper partCountAjustmentWrapper = new PartFIFOAdjustmentService.PartCountAjustmentWrapper(partRec.Id, 1, 100);
    	Map<Id, PartFIFOAdjustmentService.PartCountAjustmentWrapper> partIdToCountAjustmentWrapperMap = new Map<Id, PartFIFOAdjustmentService.PartCountAjustmentWrapper>();
    	partIdToCountAjustmentWrapperMap.put(partRec.Id, partCountAjustmentWrapper);
    	List<Part_FIFO_Bucket__c> result = PartFIFOAdjustmentService.adjustPartQty(partIdToCountAjustmentWrapperMap);
    	system.assertEquals(result.size(), 1);
    	Test.stopTest();
    }
}