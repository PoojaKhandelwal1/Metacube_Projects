@isTest 
public class SalesTaxServiceTest {
	
	@testSetup
    private static void setupTestData() {
    	List<Category__c> categoryList = new List<Category__c>();
    	List<Sales_Tax_Item__c> salesTexItemList = new List<Sales_Tax_Item__c>();
    	for(Integer i = 0; i < 10; i++) {
    		categoryList.add(TestDataFactory.sampleCategory('Test Category' + i));
    	}
    	insert categoryList;
    	for(Integer i = 0; i < 10; i++) {
    		salesTexItemList.add(TestDataFactory.sampleSalesTaxItem('Test tax' + i, 1, 'Test form' + i, categoryList[i].Id, true));
    	}
    	insert salesTexItemList;
    	
    	QuickBooks_Configurations__c qbConfig = TestDataFactory.sampleQBConfig();
    	qbConfig.Tax_Agency_Name__c = 'Test Agency';
    	qbConfig.Tax_Agency_Id__c = '123456';
    	qbConfig.TaxCode_Name__c = 'Test code';
    	qbConfig.TaxCode_Id__c = '1234';
    	insert qbConfig;  
    }
    
    @isTest
    private static void syncAccountingServerTest() {
    	Test.startTest();
    	SalesTaxService.syncAccountingServer();
    	Test.stopTest();
    	system.assertEquals([SELECT Id From Sales_Tax_Item__c].size(), 10);
    }
    
    @isTest
    private static void syncTaxAgencyFutureTest() {
    	Test.startTest();
    	SalesTaxService.syncTaxAgencyFuture();
    	Test.stopTest();
    	system.assertEquals([SELECT Id From Sales_Tax_Item__c].size(), 10);
    }
}