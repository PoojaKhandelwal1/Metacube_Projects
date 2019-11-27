@isTest 
private class SetQtyAndAvgCostOnFIFOBktAndLIBatchTest {
    
    @testSetup
    private static void setupTestData() {
    	IFW_IntegrationConfig__c ifwIntegration = TestUtil.createIFWConfigForXero(); 
		IFW_IntegrationConfigItem__c ifwConfigItem = TestUtil.createIFWConfigItemForXero('Journal Entry', ifwIntegration.Id);
        List<Account> vendorList = new List<Account>();
        for(Integer i = 0; i < 10; i++) {
        	vendorList.add(TestDataFactory.sampleVendor('Test Vendor' + i));
        }
        insert vendorList;
        
        List<Category__c> categoryList = new List<Category__c>();
        for(Integer i = 0; i < 10; i++) {
        	categoryList.add(TestDataFactory.sampleCategory('Test category' + i));
        }
        insert categoryList;
        
        List<Part__c> partList = new List<Part__c>();
        for(Integer i = 0; i < 1; i++) {
        	Part__c partRec = TestDataFactory.samplePart(vendorList[i].Id, i, i, i, i, i, categoryList[i].Id);
        	partRec.Part_Id_Text__c = 'Test' + i;
        	partList.add(partRec);
        }
        insert partList;
    }
    
    @isTest
    private static void setQtyAndAvgCostOnFIFOBktAndLIBatchTest() {
    	Test.startTest();
        DataBase.executeBatch(new SetQtyAndAvgCostOnFIFOBktAndLIBatch());
        Test.stopTest();
        system.assertEquals([SELECT Id from Part__c].size(), 1);
    }
    
    @isTest
    private static void setQtyAndAvgCostOnFIFOBktAndLIBatchWithRecordIdsTest() {
    	List<Part__c> partList = [SELECT Id from Part__c];
		Set<String> resultIdSet = (new Map<String,Part__c>(partList)).keySet();
    	Test.startTest();
        DataBase.executeBatch(new SetQtyAndAvgCostOnFIFOBktAndLIBatch(resultIdSet));
        Test.stopTest();
        system.assertEquals([SELECT Id from Part__c].size(), 1);
    }
}