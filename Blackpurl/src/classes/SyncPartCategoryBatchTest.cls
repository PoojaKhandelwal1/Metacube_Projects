/**
 * Author: Dhirendra Singh Sisodia
 * Name: SyncItemCategoryBatchTest 
 * Description: Test class for SyncPartCategoryBatch.
**/
@isTest
public with sharing class SyncPartCategoryBatchTest {
	
    @testSetup
    private static void setupTestData() {
    	IFW_IntegrationConfig__c IFWConfigObj = TestUtil.createIFWConfigForXero();
    }
    
    static testMethod void syncPartCategoryBatchTest() {
        new SyncPartCategoryBatch();
    }
    
    static testMethod void partCategoryUpdateTest() {
    	Test.startTest();
    	List<IFW_IntegrationConfig__c> IFWConfigObj = [Select Id from IFW_IntegrationConfig__c];
		IFW_IntegrationConfigItem__c IFWConfigItemObj = TestUtil.createIFWConfigItemForXero('Journal Entry' , IFWConfigObj[0].Id);
    	Map<Id, Part__c> PartOldMap = new Map<Id, Part__c>();
        List<Category__c> categoryList = new List<Category__c>();
        List<Part__c> partList = new List<Part__c> ();
        Account vendor = TestUtil.createVendor(true, 'testvendor');
        
        Category__c oldCategoryObj = TestUtil.createCategory(false, 'Test category1', 'Tax', 'Test description1', true, true);
        oldCategoryObj.Income_GL__c = '260';
        oldCategoryObj.COGS_GL__c = '300';
        oldCategoryObj.Inventory_GL__c = '260';
        oldCategoryObj.Xero_Accounting_Id__c = '100';
        insert oldCategoryObj;
        
        Part__c partObject = TestUtil.createPart(true, '103', vendor.id, 'test3', oldCategoryObj.Id, 202, 100, 10, 2, 2);
        
        Category__c newCategoryObj = TestUtil.createCategory(false, 'Test category2', 'Tax', 'Test description2', true, true);
        newCategoryObj.Income_GL__c = '260';
        newCategoryObj.COGS_GL__c = '300';
        newCategoryObj.Inventory_GL__c = '720';
        newCategoryObj.Xero_Accounting_Id__c = '100';
        insert newCategoryObj;
        
        partObject.Category__c = newCategoryObj.Id;
        partObject.Xero_Accounting_Id__c = '100';
        
        PartTriggerHelper.preventOnAccountingSync = false;
        update partObject;
        Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
        Test.stopTest();
        
        List<Part__c> partRes = [Select Id,Xero_Accounting_Id__c,Available_For_Xero_Sync__c from Part__c Limit 1];
       	system.assertEquals(partRes[0].Available_For_Xero_Sync__c,false);
       	system.assertEquals(partRes[0].Xero_Accounting_Id__c,'6d037ca7-113b-4919-b4dd-22432503e76a');
    }
}