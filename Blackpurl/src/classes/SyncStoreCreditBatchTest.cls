/**
 * Author: Nikhil Kumar Srivastava
 * Name: SyncStoreCreditBatchTest 
 * Description: Test class for SyncStoreCreditBatch.
**/
@isTest
public with sharing class SyncStoreCreditBatchTest {
     @testSetup
    private static void setupTestData() { 
       	TestUtil.createIFWConfigForXero();
	   	List<IFW_IntegrationConfig__c> IFWConfigObj = [Select Id from IFW_IntegrationConfig__c];
		IFW_IntegrationConfigItem__c IFWConfigItemObj = TestUtil.createIFWConfigItemForXero('Journal Entry' , IFWConfigObj[0].Id);
		
    }
    
     static testMethod void SyncStoreCreditBatchIncreaseTest(){
    	Test.startTest();
    	List<IFW_IntegrationConfig__c> IFWConfigObj = [Select Id from IFW_IntegrationConfig__c];
		IFW_IntegrationConfigItem__c IFWConfigItemObj = TestUtil.createIFWConfigItemForXero('Journal Entry' , IFWConfigObj[0].Id);
    	Account testCustomer = TestUtil.createCustomer(false, 'Test Customer', 'a.b@gmail.com', 'Jaipur', '987456123');
    	testCustomer.Is_Customer__c = true;
    	insert testCustomer;
    	Store_Credit__c storeCreditObj = new Store_Credit__c();
		storeCreditObj.Customer__c = testCustomer.Id;
		storeCreditObj.Amount__c = 100;
		storeCreditObj.Reference__c = 'Ref1';
        insert storeCreditObj; 
        Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());  
        Test.stopTest();
        List<Store_Credit__c> storeCreditList = [select Id,Xero_Accounting_Id__c,Available_For_Xero_Sync__c, Amount__c From Store_Credit__c];
        system.assertEquals(storeCreditList[0].Amount__c, 100);
        system.assertEquals(storeCreditList[0].Xero_Accounting_Id__c, '6d037ca7-113b-4919-b4dd-22432503e76a');
        system.assertEquals(storeCreditList[0].Available_For_Xero_Sync__c, false);
    }
    
    static testMethod void SyncStoreCreditBatchDecreaseTest(){
    	Test.startTest();
    	List<IFW_IntegrationConfig__c> IFWConfigObj = [Select Id from IFW_IntegrationConfig__c];
		IFW_IntegrationConfigItem__c IFWConfigItemObj = TestUtil.createIFWConfigItemForXero('Journal Entry' , IFWConfigObj[0].Id);
    	Account testCustomer = TestUtil.createCustomer(false, 'Test Customer', 'a.b@gmail.com', 'Jaipur', '987456123');
    	testCustomer.Is_Customer__c = true;
    	insert testCustomer;
    	Store_Credit__c storeCreditObj = new Store_Credit__c();
		storeCreditObj.Customer__c = testCustomer.Id;
		storeCreditObj.Amount__c = 100;
		storeCreditObj.Reference__c = 'Ref1';
        insert storeCreditObj; 
    	Store_Credit__c storeCreditObj1 = new Store_Credit__c();
		storeCreditObj1.Customer__c = testCustomer.Id;
		storeCreditObj1.Amount__c = -90;
		storeCreditObj1.Reference__c = 'Ref1';
        insert storeCreditObj1; 
        Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());  
        Test.stopTest();
        List<Store_Credit__c> storeCreditList = [select Id,Xero_Accounting_Id__c,Amount__c,Available_For_Xero_Sync__c From Store_Credit__c where Amount__c = -90];
        system.assertEquals(storeCreditList[0].Amount__c, -90);
        system.assertEquals(storeCreditList[0].Xero_Accounting_Id__c, '6d037ca7-113b-4919-b4dd-22432503e76a');
        system.assertEquals(storeCreditList[0].Available_For_Xero_Sync__c, false);
    }
}