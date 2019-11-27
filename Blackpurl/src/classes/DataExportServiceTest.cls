@isTest
private class DataExportServiceTest{

    @testSetup
    private static void setupTestData(){
        TestUtil.createNameSpaceInGeneralConfig();
    }
    
     static testMethod void testexportAccountingDataEmptyObjectName(){
        List<Account> CustAccount = TestUtil.createCustomerAccount(true, 2);
		List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'Customers Card', 'Customers Cards');
        
        DataExportService serviceObj = new DataExportService();
        serviceObj.objectName = '';
        
        Test.startTest();
        PageReference page = serviceObj.exportAccountingData();
        Test.stopTest();
        
        List<Accounting_Data_Migration__c>  accountMigrateList = [SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c = 'Customers Card'];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId IN: accountMigrateList];
        system.assertEquals(1, attachmentList.size());
     }
    
    static testMethod void testExportAccountingData_Account(){
        List<Account> vendorAccount = TestUtil.createVendorAccount(true, 2);
        List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'Supplier Card', 'Supplier Cards');
        
        DataExportService serviceObj = new DataExportService();
        serviceObj.objectName = DataExportUtil.VENDORS_ACCOUNTING_OBJECT_NAME;
        
        Integer batchSize = 500;
        Test.startTest();
        PageReference page = serviceObj.exportAccountingData(new List<String>{DataExportUtil.VENDORS_ACCOUNTING_OBJECT_NAME}, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2));
        Test.stopTest();
        
        List<Accounting_Data_Migration__c>  accountMigrateList = [SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c = 'Supplier Card'];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId IN: accountMigrateList];
        system.assertEquals(1, attachmentList.size());
    }
    
    static testMethod void testExportAccountingData_depositAccount(){
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec = TestUtil.createCOLineItem(true, coHeader1.Id, part.Id, 50);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader1.Id, 'Debit', 500);
        
        String coDepositJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCODepositByCOHeaderId(BPUtility.getEncodedString(coHeader1.Id)));
        
        coDepositJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveCODeposit(BPUtility.getEncodedString(coDepositJSON)));
        
        List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, DataExportUtil.DEPOSITS_ACCOUNTING_OBJECT_NAME, 'Receive Money');
        
        Test.startTest();
        
        DataExportService serviceObj = new DataExportService();
        serviceObj.objectName = DataExportUtil.DEPOSITS_ACCOUNTING_OBJECT_NAME;
        
        PageReference page = serviceObj.exportAccountingData(new List<String>{DataExportUtil.DEPOSITS_ACCOUNTING_OBJECT_NAME}, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2));
        Test.stopTest();
        List<Accounting_Data_Migration__c>  accountMigrateList = [SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c = :DataExportUtil.DEPOSITS_ACCOUNTING_OBJECT_NAME];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId IN: accountMigrateList];
        system.assertEquals(1, attachmentList.size());
    }
      
    /* //static testMethod void testExportAccountingData_customerAccount(){
        
        DataExportService serviceObj = new DataExportService();
        serviceObj.objectName = DataExportUtil.CUSTOMERS_ACCOUNTING_OBJECT_NAME;
        
        List<Account> CustAccount = TestUtil.createCustomerAccount(true, 2);
        List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'Customers Card', 'Customers Cards');
        Test.startTest();
        PageReference page = serviceObj.exportAccountingData();
        Test.stopTest();
        List<Accounting_Data_Migration__c>  accountMigrateList = [SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c = 'Customers Card'];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId IN: accountMigrateList];
        system.assertEquals(1, attachmentList.Size());
  //  }*/
    
   /* static testMethod void testExportAccountingData_blankObjectName(){
        
        DataExportService serviceObj = new DataExportService();
        serviceObj.objectName = '';
        
        List<Account> CustAccount = TestUtil.createCustomerAccount(true, 2);
        List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'Default', 'Customers Cards');
        Test.startTest();
        try{
            //PageReference page = serviceObj.exportAccountingData();
        }
        catch(Exception e){
        }
        
        Test.stopTest();
        List<Accounting_Data_Migration__c>  accountMigrateList = [SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c = 'Customers Card'];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId IN: accountMigrateList];
        system.assertEquals(0, attachmentList.Size());
    }*/
    
    static testMethod void testGetExportedDataList(){
        
        List<Account> vendorAccount = TestUtil.createVendorAccount(true, 2);
        List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'Supplier Card', 'Supplier Cards');
        
        DataExportService serviceObj = new DataExportService();
        serviceObj.objectName = DataExportUtil.VENDORS_ACCOUNTING_OBJECT_NAME;
        
        Integer batchSize = 500;
        Test.startTest();
        PageReference page = serviceObj.exportAccountingData(new List<String>{DataExportUtil.VENDORS_ACCOUNTING_OBJECT_NAME}, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2));
        Test.stopTest();
        DataExportService.ExportedData exportData = new DataExportService.ExportedData(accountMigrate[0]);
       
        List<DataExportService.ExportedData> exportedDataList = serviceObj.getExportedDataList();
        system.assertEquals(1, exportedDataList.Size());
    }
    
   static testMethod void testExportAccountingData_SalesInovice(){
        List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, DataExportUtil.SALES_INVOICE_ACCOUNTING_OBJECT_NAME, 'Sales - Miscellaneous Sales, Receive Payments, General Journal Entries');
		
        DataExportService serviceObj = new DataExportService();
        serviceObj.objectName = DataExportUtil.SALES_INVOICE_ACCOUNTING_OBJECT_NAME;

        Test.startTest();
        PageReference page = serviceObj.exportAccountingData(new List<String>{DataExportUtil.SALES_INVOICE_ACCOUNTING_OBJECT_NAME}, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2));
        Test.stopTest();
        List<Accounting_Data_Migration__c>  accountMigrateList = [SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c =: DataExportUtil.SALES_INVOICE_ACCOUNTING_OBJECT_NAME];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId IN: accountMigrateList];
        system.assertEquals(0, attachmentList.size());
    }
    
    static testMethod void testExportAccountingData_GeneralJournalEntries(){
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true;
        Part.Package_Qty__c = 22;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 1;
        insert part;
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);

        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List<PaginationSorting.SortAttrs>{
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllSimilarVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(voHeader.Id), 
                                                    BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
                                                    BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
                                                    BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
        String vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vorId), true));
        //VendorOrderReceivingCtrl_PartialTest.createExcessTestDataforBothStockAndCustomer(vendor.Id, vorId, voHeader.Id, part.Id);
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        //Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Test.startTest();
        String partsJSONString = BPUtility.getDecodedString(ViewPartCtrl.getPartInfo(BPUtility.getEncodedString(part.Id)));
        PartDetailWrapper partObjRec = (PartDetailWrapper) System.JSON.deserialize(partsJSONString, PartDetailWrapper.class);
        String decreasedStock = BPUtility.getDecodedString(ViewPartCtrl.decreaseAdjustInStock(BPUtility.getEncodedString(part.Id), 20, BPUtility.getEncodedString(System.JSON.serialize(partObjRec.PartFIFOBucketList))));
        PartDetailWrapper partObjRec1 = (PartDetailWrapper) System.JSON.deserialize(decreasedStock, PartDetailWrapper.class);
        
        String modifyCost = BPUtility.getDecodedString(ViewPartCtrl.modifyCostSummary(BPUtility.getEncodedString(System.JSON.serialize(partObjRec.PartFIFOBucketList)), 50));
        PartDetailWrapper partObjRec2 = (PartDetailWrapper) System.JSON.deserialize(modifyCost, PartDetailWrapper.class); 
                 
        List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'General Journal Entries', 'General Journal Entries');
        
        DataExportService serviceObj = new DataExportService();
        serviceObj.objectName = DataExportUtil.VENDOR_RECEIVING_ACCOUNTING_OBJECT_NAME;
        
        PageReference page = serviceObj.exportAccountingData(new List<String>{DataExportUtil.VENDOR_RECEIVING_ACCOUNTING_OBJECT_NAME}, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2));
        Test.stopTest();
        List<Accounting_Data_Migration__c>  accountMigrateList = [SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c = 'General Journal Entries'];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId IN: accountMigrateList];
        system.assertEquals(1, attachmentList.size());
    }
    
     static testMethod void testExportAccountingData_VendorInvoicing(){
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List<PaginationSorting.SortAttrs>{
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        //System.JSON.serialize(pageSort)

        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true;
        Part.Package_Qty__c = 22;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 1;
        //part.Qty_On_Order__c = 0;
        insert part;
        
        //Part__c part2 = TestUtil.createPart(true, 'partNumberP03', vendor.Id, 'Test Part03', testCategory.Id, 10, 20, 50, 100, 50);
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        //CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(true, coHeader.Id, part2.Id, 150);
		
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
		
        //Vendor_Receiving_Header__c vor = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
		String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(voHeader.Id), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        //String groupLineItems = VendorOrderCtrl.groupAllSimilarVOLineItem(vendor.Id, part.Id, voHeader.Id, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vorId), true));
        
       	Test.StartTest();
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part.id), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 10, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);

        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        Vendor_Invoicing_Header__c viHeader = TestUtil.createVendorInvoiceHeader(true, vendor.Id, 'In Progress');
         
        String vendorInvoices = BPUtility.getDecodedString(VendorInvoicingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
       	
        VendorInvoicingCtrl.VIHeaderWrapper vendorInvoice = (VendorInvoicingCtrl.VIHeaderWrapper)System.JSON.deserialize(vendorInvoices, VendorInvoicingCtrl.VIHeaderWrapper.class);
        //system.assert(false, vendorInvoice);
        
        List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'Vendor Invoicing', 'Purchases - Miscellaneous Purchases');
        
        DataExportService serviceObj = new DataExportService();
        serviceObj.objectName = DataExportUtil.VENDOR_INVOICING_ACCOUNTING_OBJECT_NAME;
        
        PageReference page = serviceObj.exportAccountingData(new List<String>{DataExportUtil.VENDOR_INVOICING_ACCOUNTING_OBJECT_NAME}, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2));
        Test.stopTest();
        List<Accounting_Data_Migration__c>  accountMigrateList = [SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c =: DataExportUtil.VENDOR_INVOICING_ACCOUNTING_OBJECT_NAME];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId IN: accountMigrateList];
        system.assertNotEquals(null, attachmentList);
    }
        
}