/**
 * Author: Nikhil Kumar Srivastava
 * Since: Oct 18, 2018
 * Name: SyncItemCategoryBatchTest 
 * Description: Test class for SyncItemCategoryBatch.
**/
@isTest
public with sharing class SyncItemCategoryBatchTest {
    
     @testSetup
    private static void setupTestData() {
       //Xero IFW_IntegrationConfig__c Record
       IFW_IntegrationConfig__c IFWConfigObj = TestUtil.createIFWConfigForXero();

       //Xero IFW_IntegrationConfigItem__c Record
       IFW_IntegrationConfigItem__c IFWConfigItemObj = new IFW_IntegrationConfigItem__c();
       IFWConfigItemObj.Endpoint_URL__c = 'https://api.xero.com/api.xro/2.0/Items';
       IFWConfigItemObj.HTTP_Method__c = 'POST';
       IFWConfigItemObj.Timeout__c = 5000;
       IFWConfigItemObj.IFW_IntegrationConfig__c = IFWConfigObj.Id;
       IFWConfigItemObj.Subscriber_Record_Id__c = 'a2G1K000003YyYkUAK';
       IFWConfigItemObj.Entity_Name__c = 'Item';
       IFWConfigItemObj.Entity_Action__c = 'Create;Update';
       insert IFWConfigItemObj;

    }
    static testMethod void SyncItemCategoryBatchTest(){
        SyncItemCategoryBatch SyncItemBatchObj = new SyncItemCategoryBatch();
    }
    static testMethod void SyncItemCategoryBatchTest_CreateNewCategory(){
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory_I = TestUtil.createCategory(false, 'Test Category');
        testCategory_I.Income_GL__c = '33';
        Category__c testCategory_II = TestUtil.createCategory(false, 'Test Category II');
        testCategory_II.Income_GL__c = '34';
        Category__c testCategory_III = TestUtil.createCategory(false, 'Test Category III');
        testCategory_III.Income_GL__c = '35';
        insert new List<SObject>{vendor,testCategory_I,testCategory_II,testCategory_III};
        List<Category__c> categoryNewList = new List<Category__c>{testCategory_I,testCategory_II,testCategory_III};
        Set<Id> categoryIdSet = new Set<Id>{testCategory_I.Id,testCategory_II.Id,testCategory_III.Id};
        //BaseIntegrationService record
        BaseIntegrationService integrationRec;
        integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
    }
    static testMethod void SyncItemCategoryBatchTest_UpdateCategory(){
       //BaseIntegrationService record
        BaseIntegrationService integrationRec;
        integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
       
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        Category__c testCategory_III = TestUtil.createCategory(false, 'Test Category III');
        testCategory_III.Income_GL__c = '35';
        insert new List<SObject>{vendor,testCategory_III};
        testCategory_III.Xero_Accounting_Id__c = '1';
        testCategory_III.Description__c = 'Test Category';
        Update testCategory_III;
    }  
 
}