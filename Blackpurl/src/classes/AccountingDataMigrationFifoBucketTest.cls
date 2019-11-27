@isTest
private class AccountingDataMigrationFifoBucketTest {

    @testSetup
    private static void setupTestData() {
      TestUtil.createNameSpaceInGeneralConfig();
      List < General_Configurations__c > config = [SELECT Id FROM General_Configurations__c LIMIT: SOQLUtil.getAvailableQueryRowsLimit()];
      System.assertNotEquals(0, config.size());
    }

    @isTest
    static void executeDataMigrationBatchForFifoBucketTest() {
      Account customer = TestUtil.createCustomer(true, 'testcustomer', 'customer@gmail.com', 'Jaipur', '8058704475');
      Account vendor = TestUtil.createVendor(true, 'testvendor');
      Category__c categoryObject = TestUtil.createCategory(true, 'Test', '    Miscellaneous', 'Test description', true, true);
      Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
      Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
      Part__c partRec1 = TestUtil.createPart(true, '101', vendor.id, 'test1', categoryObject.id, 200, 200, 100, 20, 20);
      Part__c partRec2 = TestUtil.createPart(true, '102', vendor.id, 'test2', categoryObject.id, 201, 200, 100, 20, 20);
      Part__c partRec3 = TestUtil.createPart(true, '103', vendor.id, 'test3', categoryObject.id, 202, 100, 10, 2, 2);
    
      //system.assert(false,[select Id, Name, CreatedDate, Part__r.Part_Number__c, Part__r.Part_ID__c, Part__r.Category__r.Inventory_GL__c,Is_FIFO_Bucket__c,Reference__c, (Select Name, Part_FIFO_Bucket__c, Qty_Out__c, CO_Line_Item__c, Part_Adjustment__r.Unique_Id__c,Type__c, Part_Adjustment__c, CreatedDate, Reference__c, Unique_Id__c, CO_Invoice_Header__c From Part_FIFO_Bucket_Activity_Line_Items__r) From Part_FIFO_Bucket__c]);
    
      CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
      CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, partRec1.Id, 20);
      list <CO_Invoice_Header__c> coInvoiceHeaderlist = [select Status__c, Total_Payment__c from CO_Invoice_Header__c];
    
      String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaderlist[0].Id)));
      String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedorderAction(BPUtility.getEncodedString(COInvoiceItemJSON), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('Customer')));
    
      String FIFOHistory = BPUtility.getDecodedString(ViewPartCtrl.getHistoryRecords(BPUtility.getEncodedString(partRec1.Id), true ));
      List<PartFIFOBucket> partObjRec2 = (List<PartFIFOBucket>) System.JSON.deserialize(FIFOHistory, List<PartFIFOBucket>.class);
      Test.startTest();
      String adjustedcost = BPUtility.getDecodedString(ViewPartCtrl.saveAdjustedCostDetails(BPUtility.getEncodedString('{"VendorRecievingVendorName":null,"vendorInvoicingVendorName":null,"UniqueId":"VI-0001862","Type":null,"Total":800,"SourceName":"Vendor Invoice","RemainingQty":100,"Reference":"HyperMotar","QtyOut":0,"QtyIn":100,"PartName":"testfifoautomation","PartId":"'+partObjRec2[0].PartId+'","PartFIFOActivityLineItemList":[],"IsFiFoBucket":true,"FIFOBucketId":"'+partObjRec2[0].FIFOBucketId+'","CreatedDate":"Jun 20, 2016","Cost":40,"isEdit":true}'), 50, true));
    //system.assert(false,[select Id, Name, CreatedDate, Part__r.Part_Number__c, Part__r.Part_ID__c, Part__r.Category__r.Inventory_GL__c,Is_FIFO_Bucket__c,Reference__c, (Select Name, Part_FIFO_Bucket__c, Qty_Out__c, CO_Line_Item__c, Part_Adjustment__r.Unique_Id__c,Type__c, Part_Adjustment__c, CreatedDate, Reference__c, Unique_Id__c, CO_Invoice_Header__c From Part_FIFO_Bucket_Activity_Line_Items__r) From Part_FIFO_Bucket__c]);
      Integer batchSize = 500;
      List <Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'General Journal Entries', 'General Journal Entries');
      
      AccDataMigrationFIFOBkt accountingDataMigrationFifoBucketObj1 = new AccDataMigrationFIFOBkt();
      AccDataMigrationFIFOBkt accountingDataMigrationFifoBucketObj2 = new AccDataMigrationFIFOBkt(null, true);
      AccDataMigrationFIFOBkt accountingDataMigrationFifoBucketObj3 = new AccDataMigrationFIFOBkt(null, true, null, null, null);
      Id batchId = AccDataMigrationFIFOBkt.executeDataMigrationBatch(batchSize, null, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2), 'General Journal Entries');
      Test.stopTest();
    
      List <Accounting_Data_Migration__c> accountMigrateId = [SELECT Id FROM Accounting_Data_Migration__c WHERE Object_Name__c = 'General Journal Entries'];
      List <Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId in : accountMigrateId];
      system.assertEquals(1, attachmentList.Size());
    }
    
    @isTest
    static void executeDataMigrationBatchForFifoBucketCountAdjustmentTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        String increasedStock = BPUtility.getDecodedString(ViewPartCtrl.increaseAdjustInStock(BPUtility.getEncodedString(part.Id), 20, 200));
        //PartDetailWrapper partObjRec = (PartDetailWrapper) System.JSON.deserialize(increasedStock, PartDetailWrapper.class);
        //system.assert(false,[select Id, Name, CreatedDate, Part__r.Part_Number__c, Part__r.Part_ID__c, Part__r.Category__r.Inventory_GL__c,Is_FIFO_Bucket__c,Reference__c, (Select Name, Part_FIFO_Bucket__c, Qty_Out__c, CO_Line_Item__c, Part_Adjustment__r.Unique_Id__c,Type__c, Part_Adjustment__c, CreatedDate, Reference__c, Unique_Id__c, CO_Invoice_Header__c From Part_FIFO_Bucket_Activity_Line_Items__r) From Part_FIFO_Bucket__c]);
        
         List<Part_FIFO_Bucket__c> partFifoBucketList = [Select id, Name, Remaining_Qty__c, CreatedDate, Part__r.Part_Number__c, Reference__c From Part_FIFO_Bucket__c where Is_FIFO_Bucket__c = true AND (Reference__c = 'Count Adjustment' OR Reference__c Like 're%' OR Reference__c = 'Cost Adjustment')];
        // system.assert(false,partFifoBucketList);
        Part_FIFO_Bucket_Activity_Line_Item__c partActivityLineItemRec = new Part_FIFO_Bucket_Activity_Line_Item__c();
        partActivityLineItemRec.Part_Adjustment__c = partFifoBucketList[0].Id;
        partActivityLineItemRec.Part_FIFO_Bucket__c = partFifoBucketList[0].Id;
        partActivityLineItemRec.Reference__c = 'Count Adjustment';
        partActivityLineItemRec.Qty_Out__c = partFifoBucketList[0].Remaining_Qty__c;
        insert partActivityLineItemRec;
        //system.assert(false,[select Id, Name, CreatedDate, Part__r.Part_Number__c, Part__r.Part_ID__c, Part__r.Category__r.Inventory_GL__c,Is_FIFO_Bucket__c,Reference__c, (Select Name, Part_FIFO_Bucket__c, Qty_Out__c, CO_Line_Item__c, Part_Adjustment__r.Unique_Id__c,Type__c, Part_Adjustment__c, CreatedDate, Reference__c, Unique_Id__c, CO_Invoice_Header__c From Part_FIFO_Bucket_Activity_Line_Items__r) From Part_FIFO_Bucket__c]);
        
        Integer batchSize = 500;
        List <Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'General Journal Entries', 'General Journal Entries');
        Test.startTest();
        AccDataMigrationFIFOBkt accountingDataMigrationFifoBucketObj1 = new AccDataMigrationFIFOBkt();
        AccDataMigrationFIFOBkt accountingDataMigrationFifoBucketObj2 = new AccDataMigrationFIFOBkt(null, true);
        AccDataMigrationFIFOBkt accountingDataMigrationFifoBucketObj3 = new AccDataMigrationFIFOBkt(null, true, null, null, null);
        Id batchId = AccDataMigrationFIFOBkt.executeDataMigrationBatch(batchSize, null, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2), 'General Journal Entries');
        Test.stopTest();
        
        List <Accounting_Data_Migration__c> accountMigrateId = [SELECT Id FROM Accounting_Data_Migration__c WHERE Object_Name__c = 'General Journal Entries'];
        List <Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId in : accountMigrateId];
        system.assertEquals(1, attachmentList.Size());
    }
    
    @isTest
    static void executeDataMigrationBatchForFifoBucketCostAdjustmentTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        String partsJSONString = BPUtility.getDecodedString(ViewPartCtrl.getPartInfo(BPUtility.getEncodedString(part.Id)));
        PartDetailWrapper partObjRec = (PartDetailWrapper) System.JSON.deserialize(partsJSONString, PartDetailWrapper.class);
       
        String modifyCost = BPUtility.getDecodedString(ViewPartCtrl.modifyCostSummary(BPUtility.getEncodedString(System.JSON.serialize(partObjRec.PartFIFOBucketList)), 50));
        PartDetailWrapper partObjRec1 = (PartDetailWrapper) System.JSON.deserialize(modifyCost, PartDetailWrapper.class);
        
        List<Part_FIFO_Bucket__c> partFifoBucketList = [Select id, Name, Remaining_Qty__c, CreatedDate, Part__r.Part_Number__c, Reference__c From Part_FIFO_Bucket__c where Is_FIFO_Bucket__c = true AND (Reference__c = 'Count Adjustment' OR Reference__c Like 're%' OR Reference__c = 'Cost Adjustment')];
        // system.assert(false,partFifoBucketList);
        Part_FIFO_Bucket_Activity_Line_Item__c partActivityLineItemRec = new Part_FIFO_Bucket_Activity_Line_Item__c();
        partActivityLineItemRec.Part_Adjustment__c = partFifoBucketList[0].Id;
        partActivityLineItemRec.Part_FIFO_Bucket__c = partFifoBucketList[0].Id;
        partActivityLineItemRec.Reference__c = 'Cost Adjustment';
        partActivityLineItemRec.Qty_Out__c = partFifoBucketList[0].Remaining_Qty__c;
        insert partActivityLineItemRec;
        //system.assert(false,[select Id, Name, CreatedDate, Part__r.Part_Number__c, Part__r.Part_ID__c, Part__r.Category__r.Inventory_GL__c,Is_FIFO_Bucket__c,Reference__c, (Select Name, Part_FIFO_Bucket__c, Qty_Out__c, CO_Line_Item__c, Part_Adjustment__r.Unique_Id__c,Type__c, Part_Adjustment__c, CreatedDate, Reference__c, Unique_Id__c, CO_Invoice_Header__c From Part_FIFO_Bucket_Activity_Line_Items__r) From Part_FIFO_Bucket__c]);
        
        Integer batchSize = 500; 
        List <Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'General Journal Entries', 'General Journal Entries');
        Test.startTest();
        AccDataMigrationFIFOBkt accountingDataMigrationFifoBucketObj1 = new AccDataMigrationFIFOBkt();
        AccDataMigrationFIFOBkt accountingDataMigrationFifoBucketObj2 = new AccDataMigrationFIFOBkt(null, true);
        AccDataMigrationFIFOBkt accountingDataMigrationFifoBucketObj3 = new AccDataMigrationFIFOBkt(null, true, null, null, null);
        Id batchId = AccDataMigrationFIFOBkt.executeDataMigrationBatch(batchSize, null, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2), 'General Journal Entries');
        Test.stopTest();
        
        List <Accounting_Data_Migration__c> accountMigrateId = [SELECT Id FROM Accounting_Data_Migration__c WHERE Object_Name__c = 'General Journal Entries'];
        List <Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId in : accountMigrateId];
        system.assertEquals(1, attachmentList.Size());
    }
    
    @isTest
    static void executeDataMigrationBatchForFifoBucketCostAdjustmentTestA() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        String partsJSONString = BPUtility.getDecodedString(ViewPartCtrl.getPartInfo(BPUtility.getEncodedString(part.Id)));
        PartDetailWrapper partObjRec = (PartDetailWrapper) System.JSON.deserialize(partsJSONString, PartDetailWrapper.class);
       
        String modifyCost = BPUtility.getDecodedString(ViewPartCtrl.modifyCostSummary(BPUtility.getEncodedString(System.JSON.serialize(partObjRec.PartFIFOBucketList)), 50));
        PartDetailWrapper partObjRec1 = (PartDetailWrapper) System.JSON.deserialize(modifyCost, PartDetailWrapper.class);
        
        List<Part_FIFO_Bucket__c> partFifoBucketList = [Select id, Name, Remaining_Qty__c, CreatedDate, Part__r.Part_Number__c, Reference__c From Part_FIFO_Bucket__c where Is_FIFO_Bucket__c = true AND (Reference__c = 'Count Adjustment' OR Reference__c Like 're%' OR Reference__c = 'Cost Adjustment')];
        // system.assert(false,partFifoBucketList);
        Part_FIFO_Bucket_Activity_Line_Item__c partActivityLineItemRec = new Part_FIFO_Bucket_Activity_Line_Item__c();
        partActivityLineItemRec.Part_Adjustment__c = partFifoBucketList[0].Id;
        partActivityLineItemRec.Part_FIFO_Bucket__c = partFifoBucketList[0].Id;
        partActivityLineItemRec.Reference__c = 'Count Adjustment';
        partActivityLineItemRec.Qty_Out__c = partFifoBucketList[0].Remaining_Qty__c;
        insert partActivityLineItemRec;
        //system.assert(false,[select Id, Name, CreatedDate, Part__r.Part_Number__c, Part__r.Part_ID__c, Part__r.Category__r.Inventory_GL__c,Is_FIFO_Bucket__c,Reference__c, (Select Name, Part_FIFO_Bucket__c, Qty_Out__c, CO_Line_Item__c, Part_Adjustment__r.Unique_Id__c,Type__c, Part_Adjustment__c, CreatedDate, Reference__c, Unique_Id__c, CO_Invoice_Header__c From Part_FIFO_Bucket_Activity_Line_Items__r) From Part_FIFO_Bucket__c]);
        
        Integer batchSize = 500;
        List <Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'General Journal Entries', 'General Journal Entries');
        Test.startTest();
        AccDataMigrationFIFOBkt accountingDataMigrationFifoBucketObj1 = new AccDataMigrationFIFOBkt();
        AccDataMigrationFIFOBkt accountingDataMigrationFifoBucketObj2 = new AccDataMigrationFIFOBkt(null, true);
        AccDataMigrationFIFOBkt accountingDataMigrationFifoBucketObj3 = new AccDataMigrationFIFOBkt(null, true, null, null, null);
        Id batchId = AccDataMigrationFIFOBkt.executeDataMigrationBatch(batchSize, null, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2), 'General Journal Entries');
        Test.stopTest();
        
        List <Accounting_Data_Migration__c> accountMigrateId = [SELECT Id FROM Accounting_Data_Migration__c WHERE Object_Name__c = 'General Journal Entries'];
        List <Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId in : accountMigrateId];
        system.assertEquals(1, attachmentList.Size());
    }
}