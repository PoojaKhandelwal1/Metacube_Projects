/**
 * Author: Nikhil Kumar Srivastava
 * Since: Oct 18, 2018
 * Name: SyncPartFifoBucketActivityLineBatchTest 
 * Description: Test class for SyncPartFifoBucketActivityLineBatch.
**/
@isTest
public with sharing class SyncPartFifoBucketActivityLineBatchTest {
    @testSetup
    private static void setupTestData() { 
       //Xero IFW_IntegrationConfig__c Record
       IFW_IntegrationConfig__c IFWConfigObj = TestUtil.createIFWConfigForXero();

       //Xero IFW_IntegrationConfigItem__c Record
       IFW_IntegrationConfigItem__c IFWConfigItemObj = new IFW_IntegrationConfigItem__c();
       IFWConfigItemObj.Endpoint_URL__c = 'https://api.xero.com/api.xro/2.0/ManualJournals';
       IFWConfigItemObj.HTTP_Method__c = 'POST';
       IFWConfigItemObj.Timeout__c = 5000;
       IFWConfigItemObj.IFW_IntegrationConfig__c = IFWConfigObj.Id;
       IFWConfigItemObj.Subscriber_Record_Id__c = 'a2G1K000003YyYkUAK';
       IFWConfigItemObj.Entity_Name__c = 'Journal Entry';
       IFWConfigItemObj.Entity_Action__c = 'Create;Update';
       insert IFWConfigItemObj;
 
    }
    static testMethod void SyncPartFifoBucketActivityLineBatchTest() {
        SyncPartFifoBucketActivityLineItemBatch SyncPartFifoBucketActivityLineBatchobj = new SyncPartFifoBucketActivityLineItemBatch();
    }

    static testMethod void SyncPartFifoBucketActivityLineBatch_CreateEntries() {
        Account customer = TestUtil.createCustomer(true, 'testcustomer', 'customer@gmail.com', 'Jaipur', '8058704475');
        Account vendor = TestUtil.createVendor(true, 'testvendor');
        Category__c categoryObject = TestUtil.createCategory(true, 'Test', '    Miscellaneous', 'Test description', true, true);
        Part__c partObject1 = TestUtil.createPart(true, '101', vendor.id, 'test1', categoryObject.id, 200, 200, 100, 20, 20);
        Part__c partObject2 = TestUtil.createPart(true, '102', vendor.id, 'test2', categoryObject.id, 201, 200, 100, 20, 20);
        Part__c partObject3 = TestUtil.createPart(true, '103', vendor.id, 'test3', categoryObject.id, 202, 100, 10, 2, 2);
        List<Part__c> partList = new List<Part__c> ();
        partList.add(partObject1);
        partList.add(partObject2);
        partList.add(partObject3);
        List<String> partidList = new List<String>{partObject1.id,partObject2.id,partObject3.id};
        List<Part_FIFO_Bucket__c> partFIFOBucketList = [Select id,Remaining_Qty__c,CreatedDate,Is_FIFO_Bucket__c,Customer_Return__c,Cost__c,Vendor_Receiving_Header__c,Total__c,Type__c,Part__r.Part_Number__c,Qty_In__c,Qty_Out__c,Vendor_Invoicing_Header__r.Vendor__c,Vendor_Invoicing_Header__r.Vendor__r.Name,Vendor_Invoicing_Header__c,Source_Name__c from Part_FIFO_Bucket__c  where Part__c in :partidList];
        PartFifoBucket fifobucket = new PartFifoBucket(partFIFOBucketList.get(0));
        PartFifoBucket.getPartFIFOBucketList();
        PartFifoBucket.getPartFIFOBucketLineItemList();
        CO_Header__c coheaderobject =  TestUtil.createCOHeader(true, customer.id);
        //CO_Invoice_Header__c  coInvoiceHeaderObject = TestUtil.createCOInvoiceHeader(true, coheaderobject.id, 'Stocked');
        
        Part_FIFO_Bucket_Activity_Line_Item__c partActivityLineitem = new Part_FIFO_Bucket_Activity_Line_Item__c();
        //partActivityLineitem.CO_Invoice_Header__c = coInvoiceHeaderObject.id;
        //CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true,coheaderobject.id,partObject1.id,1);
        partActivityLineitem.Part_Adjustment__c = partFIFOBucketList[0].id;
        partActivityLineitem.Part_FIFO_Bucket__c = partFIFOBucketList[0].id;
        partActivityLineitem.Qty_Out__c = 20;
        insert partActivityLineitem;
        Set<Id> partFifoIdSet =  (new Map<Id,Part_FIFO_Bucket_Activity_Line_Item__c>(new List<Part_FIFO_Bucket_Activity_Line_Item__c>{partActivityLineitem})).keySet();
        //BaseIntegrationService record
        /*BaseIntegrationService integrationRec;
        integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
        IntegrationSyncFlagService.managePartFIFOBucketLISyncFlag(new List<BaseIntegrationService>{integrationRec}, new List<Part_FIFO_Bucket_Activity_Line_Item__c>{partActivityLineitem});
        IntegrationBatchService.initiateBatch(partFifoIdSet, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.PART_FIFO_BUCKET_ACTIVITY_LINE_ITEM);
    	*/
    }
    
    static testMethod void SyncPartFifoBucketActivityLineBatch_UpdateEntries() {
        Account customer = TestUtil.createCustomer(true, 'testcustomer', 'customer@gmail.com', 'Jaipur', '8058704475');
        Account vendor = TestUtil.createVendor(true, 'testvendor');
        Category__c categoryObject = TestUtil.createCategory(true, 'Test', '    Miscellaneous', 'Test description', true, true);
        Part__c partObject1 = TestUtil.createPart(true, '101', vendor.id, 'test1', categoryObject.id, 200, 200, 100, 20, 20);
        Part__c partObject2 = TestUtil.createPart(true, '102', vendor.id, 'test2', categoryObject.id, 201, 200, 100, 20, 20);
        Part__c partObject3 = TestUtil.createPart(true, '103', vendor.id, 'test3', categoryObject.id, 202, 100, 10, 2, 2);
        List<Part__c> partList = new List<Part__c> ();
        partList.add(partObject1);
        partList.add(partObject2);
        partList.add(partObject3);
        List<String> partidList = new List<String>{partObject1.id,partObject2.id,partObject3.id};
        List<Part_FIFO_Bucket__c> partFIFOBucketList = [Select id,Remaining_Qty__c,CreatedDate,Is_FIFO_Bucket__c,Customer_Return__c,Cost__c,Vendor_Receiving_Header__c,Total__c,Type__c,Part__r.Part_Number__c,Qty_In__c,Qty_Out__c,Vendor_Invoicing_Header__r.Vendor__c,Vendor_Invoicing_Header__r.Vendor__r.Name,Vendor_Invoicing_Header__c,Source_Name__c from Part_FIFO_Bucket__c  where Part__c in :partidList];
        PartFifoBucket fifobucket = new PartFifoBucket(partFIFOBucketList.get(0));
        PartFifoBucket.getPartFIFOBucketList();
        PartFifoBucket.getPartFIFOBucketLineItemList();
        CO_Header__c coheaderobject =  TestUtil.createCOHeader(true, customer.id);
        //CO_Invoice_Header__c  coInvoiceHeaderObject = TestUtil.createCOInvoiceHeader(true, coheaderobject.id, 'Stocked');
        
        Part_FIFO_Bucket_Activity_Line_Item__c partActivityLineitem = new Part_FIFO_Bucket_Activity_Line_Item__c();
        //partActivityLineitem.CO_Invoice_Header__c = coInvoiceHeaderObject.id;
        //CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true,coheaderobject.id,partObject1.id,1);
        partActivityLineitem.Part_Adjustment__c = partFIFOBucketList[0].id;
        partActivityLineitem.Part_FIFO_Bucket__c = partFIFOBucketList[0].id;
        partActivityLineitem.Qty_Out__c = 20;
        insert partActivityLineitem;
          
        List<Part_FIFO_Bucket_Activity_Line_Item__c> partActivityLineitemToUpdateList = [Select Id,Xero_Accounting_Id__c from Part_FIFO_Bucket_Activity_Line_Item__c];
        partActivityLineitemToUpdateList[0].Xero_Accounting_Id__c = '100';
        update partActivityLineitemToUpdateList;
        Set<Id> partFifoIdSet =  (new Map<Id,Part_FIFO_Bucket_Activity_Line_Item__c>(new List<Part_FIFO_Bucket_Activity_Line_Item__c>{partActivityLineitemToUpdateList[0]})).keySet();
        //BaseIntegrationService record
        /*
        BaseIntegrationService integrationRec;
        integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
        IntegrationSyncFlagService.managePartFIFOBucketLISyncFlag(new List<BaseIntegrationService>{integrationRec}, new List<Part_FIFO_Bucket_Activity_Line_Item__c>{partActivityLineitemToUpdateList[0]});
        IntegrationBatchService.initiateBatch(partFifoIdSet, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.PART_FIFO_BUCKET_ACTIVITY_LINE_ITEM);
    	*/
    }
    
}