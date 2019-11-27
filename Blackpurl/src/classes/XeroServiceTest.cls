/**
 * Author: Nikhil Kumar Srivastava
 * Since: Feb 25, 2019
 * Name: XeroServiceTest 
 * Description: Test class for XeroService
**/
@isTest
global class XeroServiceTest {
	@testSetup
    private static void setupTestData() {
       //Xero IFW_IntegrationConfig__c Record
      	IFW_IntegrationConfig__c IFWConfigObj = TestUtil.createIFWConfigForXero();
		//Header
		List<customHttpHeaderWrapper> headerList = new List<customHttpHeaderWrapper>();
		customHttpHeaderWrapper header = new customHttpHeaderWrapper('Content-Type', 'applications/json');
		headerList.add(header);
    }
	
	static testMethod void ItemCategoryPayLoad() {
		//Integration Metadata
		Test.startTest();
		List<IFW_IntegrationConfig__c> IFWConfigObj = [Select Id from IFW_IntegrationConfig__c];
		IFW_IntegrationConfigItem__c IFWConfigItemObj = TestUtil.createIFWConfigItemForXero('Item' , IFWConfigObj[0].Id);
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        Category__c testCategory_III = TestUtil.createCategory(false, 'Test Category III');
        testCategory_III.Income_GL__c = '35';
        insert new List<SObject>{vendor,testCategory_III};
       	Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
       	Test.stopTest();
       	List<Category__c> itemRes = [Select Id,Name,Xero_Accounting_Id__c,Available_For_Xero_Sync__c from Category__c Limit 1];
       	system.assertEquals(itemRes[0].Name,'Test Category III');
       	//system.assertEquals(itemRes[0].Xero_Accounting_Id__c,'xxxItemID101xxx');
       	testCategory_III.Description__c = 'Test Category III for Testing';
        update testCategory_III;
       	
	}
	
	static testMethod void createCODepositPayLoad() {
		//Integration Metadata
       	Test.startTest();
       	List<IFW_IntegrationConfig__c> IFWConfigObj = [Select Id from IFW_IntegrationConfig__c];
		IFW_IntegrationConfigItem__c IFWConfigItemObj = TestUtil.createIFWConfigItemForXero('Journal Entry' , IFWConfigObj[0].Id);
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        
        List<Part__c> partList = new List<Part__c> ();
        Part__c partObject1 = TestUtil.createPart(true, '101', vendor.id, 'test1', testCategory.id, 200, 200, 100, 20, 20);
        partList.add(partObject1);
        List<String> partidList = new List<String>{partObject1.id};
        
        CO_Line_Item__c coLineItemRec = TestUtil.createCOLineItem(true, coHeader1.Id, partObject1.Id, 50);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader1.Id, 'Debit', 500);
        Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
   		Test.stopTest();
   		
   		List<CO_Deposit__c> coDepositRes = [Select Id,Name,Xero_Accounting_Id__c,Available_For_Xero_Sync__c from CO_Deposit__c Limit 1];
       	system.assertEquals(coDepositRes[0].Available_For_Xero_Sync__c,false);
       	system.assertEquals(coDepositRes[0].Xero_Accounting_Id__c,'6d037ca7-113b-4919-b4dd-22432503e76a');
	}
	
	static testMethod void ItemCategoryPayLoadfailureRecordsTest () {
		List<IFW_IntegrationConfig__c> IFWConfigObj = [Select Id from IFW_IntegrationConfig__c];
		IFW_IntegrationConfigItem__c IFWConfigItemObj = TestUtil.createIFWConfigItemForXero('Item' , IFWConfigObj[0].Id);
		IFWConfigItemObj.Endpoint_URL__c = 'https://api.xero.com/api.xro/2.0/Item';
		update IFWConfigItemObj;
		Test.startTest();
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        Category__c testCategory_III = TestUtil.createCategory(false, 'Test Category III');
        testCategory_III.Income_GL__c = '35';
        //testCategory_III.Available_For_Xero_Sync__c = true;
        insert new List<SObject>{vendor,testCategory_III};
        Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
		Test.stopTest();
		
	
	}
	
}