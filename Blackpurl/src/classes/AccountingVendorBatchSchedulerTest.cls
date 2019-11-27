/**
 * Author: Nikhil Kumar Srivastava
 * Since: April 16, 2019
 * Name: AccountingVendorBatchSchedulerTest
 * Description: test Class for AccountingVendorBatchScheduler.
**/

@isTest
public with sharing  class AccountingVendorBatchSchedulerTest {

	@testSetup
    private static void setupTestData() { 
       	TestUtil.createIFWConfigForXero();
       	Account vendorObj = TestUtil.createVendor(true, 'Xero Vendor');
    	system.assertEquals(true, String.isNotBlank(vendorObj.Id));
    }
    
	static testmethod void AccountingCustomerBatchSchedulerTest() { 
		List<IFW_IntegrationConfig__c> IFWConfigObj = [Select Id from IFW_IntegrationConfig__c];
		IFW_IntegrationConfigItem__c IFWConfigItemObj = TestUtil.createIFWConfigItemForXero('Contacts' , IFWConfigObj[0].Id);
		List<Account> accList = [Select Id,Is_Vendor__c from Account where Is_Vendor__c = true Limit 1];
		system.assertEquals(1,accList.size());
		system.assertEquals(true,accList[0].Is_Vendor__c);
		test.startTest();
		XeroScriptUtil.syncVendors(25,60,25);
		test.stopTest();
	 }
}