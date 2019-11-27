/**
 * Author: Rajat Jain
 * updated: Oct 20, 2018
 * Name: AccountTypeBatchTest
 * Description: It includes scenario based test cases for AccountTypeBatchTest.
**/

@isTest
private with sharing class AccountTypeBatchTest {
	
	@testSetup
   	static void setup() {
		BPScriptUtility.insertDefaultAccountTypes();
		List<Account_Type__c> accountTypeInserted = [Select Id from Account_Type__c];
		system.assert(accountTypeInserted.size() > 0);
	}
	
	static testMethod void accountTypeBatchTest() {
		List<Account> accountsList = new List<Account>();
		accountsList.add(testUtil.createCustomer(false,'test customer','abc@abc.com','jaipur','1111122222'));
		accountsList.add(testUtil.createCustomer(false,'test customer1','abc@abc.com','jaipur','1111122222'));
		accountsList.add(testUtil.createVendor(false,'test vendor'));
		accountsList.add(testUtil.createVendor(false,'test vendor1'));
		
		insert accountsList;
		
		Category__c categoryObj = testUtil.createCategory(true,'category one');
        Sales_Tax__c salesTax2 = TestUtil.createSalesTax(true, 'Testing Sales Tax 2', true, false, true);
      
		Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Sales Tax Item 1', 20, 'Testing Form Label 1', true, categoryObj.id);
        Sales_Tax_Item__c salesTaxItem2 = TestUtil.createSalesTaxItem(true, 'Test Sales Tax Item 2', 20, 'Testing Form Label 2', true, categoryObj.id);
        Sales_Tax_Item__c salesTaxItem3 = TestUtil.createSalesTaxItem(true, 'Test Sales Tax Item 3', 20, 'Testing Form Label 3', true, categoryObj.id);
    	
    	List<Tax_Exemption__c> taxExemptionToInsert = new List<Tax_Exemption__c>();
    	Tax_Exemption__c taxExemptionObj ;
    	Tax_Exemption__c taxExemptionObj1;
		for(Account accRec : accountsList) {
			taxExemptionObj = new Tax_Exemption__c(Customer__c = accRec.Id, Sales_Tax_Item__c = salesTaxItem1.Id);
        	taxExemptionObj1 = new Tax_Exemption__c(Customer__c = accRec.Id, Sales_Tax_Item__c = salesTaxItem2.Id);
        	taxExemptionToInsert.add(taxExemptionObj);
        	taxExemptionToInsert.add(taxExemptionObj1);
		}
		
		Account accObj = testUtil.createCustomer(true,'test customer 2','abc@abc.com','jaipur','1111122222');
		taxExemptionObj = new Tax_Exemption__c(Customer__c = accObj.Id, Sales_Tax_Item__c = salesTaxItem1.Id);
		taxExemptionObj1 = new Tax_Exemption__c(Customer__c = accObj.Id, Sales_Tax_Item__c = salesTaxItem2.Id);
		Tax_Exemption__c taxExemptionObj2 = new Tax_Exemption__c(Customer__c = accObj.Id, Sales_Tax_Item__c = salesTaxItem3.Id);
		taxExemptionToInsert.add(taxExemptionObj);
    	taxExemptionToInsert.add(taxExemptionObj1);
    	taxExemptionToInsert.add(taxExemptionObj2);
    	
    	insert taxExemptionToInsert;
     	Test.startTest();
        
        Account accCustomerObj = testUtil.createCustomer(true,'test customer 3','abc@abc.com','jaipur','1111122222');
        accCustomerObj.Is_Customer__c = true;
        
        update accCustomerObj;
        Account accVendorObj = testUtil.createVendor(true,'test vendor 3','abc@abc.com','jaipur','1111122222');

		Database.executeBatch(new AccountTypeBatch());
		List<Account_Type__c> noOfAccountTypeCreated = [SELECT Id FROM Account_Type__c];
		system.assert(noOfAccountTypeCreated.size() > 0);
		Test.stopTest();
	}
}