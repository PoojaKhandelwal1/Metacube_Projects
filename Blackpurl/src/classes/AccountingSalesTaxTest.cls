@isTest
public with sharing class AccountingSalesTaxTest {
	
    @testsetup
    private static void setupData(){
    	QuickBooks_Configurations__c qbConfig = TestDataFactory.createQBConfig();
    	Category__c categoryRec = TestDataFactory.createCategory('Test Category');
    	Sales_Tax_Item__c salesTaxItemRec = TestDataFactory.createSalesTaxItem('Test Sales', 2, 'Forms', categoryRec.Id, true);
    }
    
    @isTest 
    private static void accountingSalesTaxTest() {
    	List<Sales_Tax_Item__c> salesTaxItemList = [SELECT Id, AccountingId__c, Name__c, Rate__c FROM Sales_Tax_Item__c];
    	AccountingSalesTax accountingSalesTaxRec = new AccountingSalesTax(salesTaxItemList);
    	system.assertEquals(salesTaxItemList.size(), 1);
    }
}