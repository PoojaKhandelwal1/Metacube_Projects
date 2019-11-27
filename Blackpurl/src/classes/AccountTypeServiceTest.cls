/**
 * Author: Rajat Jain
 * updated: Oct 20, 2018
 * Name: AccountTypeServiceTest
 * Description: It includes scenario based test cases for AccountTypeServiceTest.
**/

@isTest
private with sharing class AccountTypeServiceTest {
	
	@testSetup
   	static void setup() {
		BPScriptUtility.insertDefaultAccountTypes();
		List<Account_Type__c> accountTypeInserted = [Select Id from Account_Type__c];
		system.assert(accountTypeInserted.size() > 0);
	}
	
	static testMethod void getAllAccountTypeDataTest() {
		Test.startTest();
		String accountType = BPUtility.getDecodedString(UserSettingCtrl.getAllAccountTypeData());
		List<AccountTypeWrapper> accountTypeList =(List<AccountTypeWrapper>) System.JSON.deserialize(accountType, List<AccountTypeWrapper>.class);
		system.assert(accountTypeList.size() > 0);
		
		List<AccountTypeWrapper> customerAccountTypeList = AccountTypeService.getAllAccountTypeForCustomer();
		system.assert(customerAccountTypeList.size() > 0);
		
		List<AccountTypeWrapper> vendorAccountTypeList = AccountTypeService.getAllAccountTypeForVendor();
		system.assert(vendorAccountTypeList.size() > 0);
		Test.stopTest(); 
	} 
	
	static testMethod void addEditAccountTypeTest() {
		Account customer = testUtil.createCustomer(true,'test customer','abc@abc.com','jaipur','1111122222');
        Category__c categoryObj = testUtil.createCategory(true,'category one');
        Sales_Tax__c salesTax2 = TestUtil.createSalesTax(true, 'Testing Sales Tax 2', true, false, true);
       	Test.startTest();
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Sales Tax Item 1', 20, 'Testing Form Label 1', true, categoryObj.id);
        Sales_Tax_Item__c salesTaxItem2 = TestUtil.createSalesTaxItem(true, 'Test Sales Tax Item 2', 20, 'Testing Form Label 2', true, categoryObj.id);
        Sales_Tax_Item__c salesTaxItem3 = TestUtil.createSalesTaxItem(true, 'Test Sales Tax Item 3', 20, 'Testing Form Label 3', true, categoryObj.id);
        
        String accountTypeId;
        AccountTypeWrapper accTypeWrapperRec ;
        List<String> appliesToList = new List<String>();
        appliesToList.add('test data');
        appliesToList.add('test data second');
        TaxExemptions taxExemptionsObj = new TaxExemptions(salesTaxItem1,appliesToList, 'Account Type');
        taxExemptionsObj.isSelected = true;
        TaxExemptions taxExemptionsObj1 = new TaxExemptions(salesTaxItem2,appliesToList, 'Account Type');
        taxExemptionsObj1.isSelected = true;
        TaxExemptions taxExemptionsObj2 = new TaxExemptions(salesTaxItem3,appliesToList, 'Account Type');
        taxExemptionsObj2.isSelected = true;
        
        Account_Type__c accTypeRec = new Account_Type__c(Name = 'Rajat Testing', Applies_To__c = 'Customers', Default__c = true, Active__c = true);
		accTypeWrapperRec = new AccountTypeWrapper(accTypeRec);
		accTypeWrapperRec.TaxExemptionsList = new List<TaxExemptions>{taxExemptionsObj, taxExemptionsObj1};
		accountTypeId = BPUtility.getDecodedString(UserSettingCtrl.saveAccountType(BPUtility.getEncodedString(system.JSON.serialize(accTypeWrapperRec))));
		system.assert(accountTypeId != null);
		
        List<Account_Type__c> accTypeList = [Select Id from Account_Type__c where Name = 'Rajat Testing' Limit 1];
        
        Tax_Exemption__c taxExemptionObj = new Tax_Exemption__c(Account_Type__c = accTypeList[0].Id, Sales_Tax_Item__c = salesTaxItem1.Id);
        Tax_Exemption__c taxExemptionObj1 = new Tax_Exemption__c(Account_Type__c = accTypeList[0].Id, Sales_Tax_Item__c = salesTaxItem2.Id);
		accTypeList[0].Name = 'Testing';
		accTypeWrapperRec = new AccountTypeWrapper(accTypeList[0]);
		accTypeWrapperRec.TaxExemptionsList =  new List<TaxExemptions>{taxExemptionsObj1, taxExemptionsObj2};
		
		accountTypeId = BPUtility.getDecodedString(UserSettingCtrl.saveAccountType(BPUtility.getEncodedString(system.JSON.serialize(accTypeWrapperRec))));
		
		String taxExemption = BPUtility.getDecodedString(UserSettingCtrl.getAllActiveSalesTax());
		List<TaxExemptions> taxExemptionList =(List<TaxExemptions>) System.JSON.deserialize(taxExemption, List<TaxExemptions>.class);
		system.assert(taxExemptionList.size() > 0);
		
		AccountTypeWrapper accTypeWrapperRecord = AccountTypeService.getRecForAccountType(accTypeList[0].Id);
		system.assertEquals(accTypeWrapperRecord.AccountType, 'Testing');
		
		Test.stopTest();
	}
}