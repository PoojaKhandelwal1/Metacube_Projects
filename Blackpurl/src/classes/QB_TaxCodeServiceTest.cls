@isTest
private class QB_TaxCodeServiceTest {
    @testsetup
    private static void setup(){
    	Account customer = TestDataFactory.createCustomer('Test001', 'Individual', 'Fname', 'Lname');
    	QuickBooks_Configurations__c qbConfig = TestDataFactory.createQBConfig();
    	qbConfig.Company_Country__c = 'US';
    	update qbConfig;
    	
    	Category__c categoryRec = TestDataFactory.createCategory('cat001');
    	Sales_Tax_Item__c salesTaxItem = TestDataFactory.createSalesTaxItem('TaxCode', 10, 'Test Form Label', categoryRec.ID, true);
    	QB_TaxCode__c qbSalesTaxCode = TestDataFactory.createQBTaxCode();
    	qbSalesTaxCode.Accounting_Id__c = '20';
    	update qbSalesTaxCode;
    }
    
    @isTest
    private static void testGetTaxCodeCombinationForUS(){
    	Test.startTest();
    	List<QB_TaxCodeService.TaxCodeWrapper> result= new List<QB_TaxCodeService.TaxCodeWrapper>(QB_TaxCodeService.getTaxCodeCombination());
    	system.assertEquals(result.size(), 2);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetTaxCodeCombinationForNotUS(){
    	Test.startTest();
    	QuickBooks_Configurations__c qbConfig = [SELECT Company_Country__c FROM QuickBooks_Configurations__c LIMIT 1];
    	qbConfig.Company_Country__c = 'AUS';
    	update qbConfig;
    	List<QB_TaxCodeService.TaxCodeWrapper> result= new List<QB_TaxCodeService.TaxCodeWrapper>(QB_TaxCodeService.getTaxCodeCombination());
    	system.assertEquals(result.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetTaxCodeId(){
    	Test.startTest();
    	Account customer = [SELECT Id FROM Account WHERE Is_Customer__c = true LIMIT 1];
    	String result = QB_TaxCodeService.getTaxCodeId(customer.Id);
    	system.assertEquals('20', result);
    	Test.stopTest();
    }
}