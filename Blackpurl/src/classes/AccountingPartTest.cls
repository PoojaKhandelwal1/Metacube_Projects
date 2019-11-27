@isTest
public with sharing class AccountingPartTest {
	
    @testsetup
    private static void setup(){
    	Account vendorRec = TestDataFactory.createVendor('Test Vendor');
    	Category__c categoryRec = TestDataFactory.createCategory('Test Category');
    	Part__c partRec = TestDataFactory.createPart(vendorRec.Id, 2, 2, 2, 2, 3, categoryRec.Id);
    }
     
    @isTest
    private static void accountingPartTest() {
    	List<Part__c> partList = [SELECT Id, Part_Number__c, Xero_Accounting_Id__c, Total_Cost__c, 
						    		LastModifiedDate, Category__r.Name, Category__r.Inventory_GL__c, Old_Category__r.Name, 
						    		Old_Category__r.Inventory_GL__c, Accounting_Id_Category__c, Sync_Token_Category__c, 
						    		Accounting_Response_Category__c from Part__c];
    	AccountingPart accountingPartRec = new AccountingPart(partList[0]);
    	system.assertEquals(partList.size(), 1);
    }
    
    @isTest
    private static void fieldsListTest() {
    	system.assertEquals(AccountingPart.fieldsList().size(), 12);
    }
}