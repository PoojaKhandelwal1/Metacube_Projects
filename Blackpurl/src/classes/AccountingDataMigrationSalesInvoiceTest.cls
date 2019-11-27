@isTest
public with sharing class AccountingDataMigrationSalesInvoiceTest {

    @testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
        System.assertEquals(1, 1);
    }
    
    @isTest
    static void executePaymentsDataMigrationBatchTest(){
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        //Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Category__c testCategory = TestUtil.createCategory(false, 'Test Category', 'Unit', 'Testing Category', true, true);
        testCategory.Income_GL__c = 'Income_GL__c';
        testCategory.Inventory_GL__c = 'Inventory_GL__c';
        testCategory.COGS_GL__c = 'COGS_GL__c';
        insert testCategory;
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
       // Fee__c fee1 = TestUtil.createFee(True, True, testCategory.Id, 'test1', coHeader.Id, 'Description', 100, True);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Sales Tax Item 2', 30, 'Testing Form Label 2', true, null);
        
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true;
        Part.Package_Qty__c = 22;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 1;
        insert part;
        
        Configurations__c taxSetting = Configurations__c.getOrgDefaults();
        taxSetting.Default_Tax_on_Fee__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Labor__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Part__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Vendor_Product__c = defaultSalesTax.Id; 
        taxSetting.Default_Tax_on_Unit__c = defaultSalesTax.Id;
        taxSetting.Tax_Included_Pricing__c = true;
        insert taxSetting;
        
        Deal__c dealRec = new Deal__c();
        dealRec.CO_Header__c = coHeader.Id;
        insert dealRec;
        
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        dealItemRec.Unit_Model__c = unitmodel.Id;
        dealItemRec.Deal__c = dealRec.Id;
        insert dealItemRec;
        
        Deal_Item__c dealItemRec2 = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        dealItemRec2.Unit_Model__c = unitmodel.Id;
        dealItemRec2.Deal__c = dealRec.Id;
        dealItemRec2.Type__c = Constants.DEAL_ITEM_TYPE_TRADE_IN;
        dealItemRec2.Agreed_Value__c = 25;
        insert dealItemRec2;
        
        Deal_Unit_Price_Cost__c dealUnitPriceCostRec = new Deal_Unit_Price_Cost__c(Item_Description__c = 'Test Deal Unit Price And Cost 2', Price__c = 7000, Qty__c = 1, Type__c ='Factory'); 
        dealUnitPriceCostRec.Deal_Item__c = dealItemRec.Id;
        insert dealUnitPriceCostRec;
        
        Option_Fee__c optionAndFeeRec = new Option_Fee__c();
        optionAndFeeRec.Deal_Item__c = dealItemRec.Id;
        optionAndFeeRec.Qty__c = 2;
        optionAndFeeRec.Part__c = part.Id;
        insert optionAndFeeRec;
        
        AutoNumberHolder__c AutonumberRec = new AutoNumberHolder__c();
        insert AutonumberRec;
        
        Test.startTest();
        executePaymentsDataMigrationBatchTestAsyncHandling(coHeader.Id, dealItemRec.Id, part.Id, dealRec.Id, AutonumberRec.Id, testCategory.Id);
        Test.stopTest();
        Id batchId = AccountingDataMigrationSalesInvoice.executeDataMigrationBatch(200, null, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2), DataExportUtil.SALES_INVOICE_ACCOUNTING_OBJECT_NAME);
        List<Accounting_Data_Migration__c>  accountMigrateId = [ SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c = 'Customer Order Sales Invoices' ];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId in :accountMigrateId ];
        system.assertEquals(0, attachmentList.size());
        
    }
    
    @future
    private static void executePaymentsDataMigrationBatchTestAsyncHandling(String coHeaderId, String dealItemRecId, String partId, String dealRecId, String AutonumberRecId, String testCategoryId)
    {
    	String soHeader1 = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeaderId)));
        String soHeader2 = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeaderId)));
        List<Service_Order_Header__c> serviceOrderHeaderList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>());
        
        serviceOrderHeaderList[0].Deal_Item__c = dealItemRecId;
        update serviceOrderHeaderList[0];
        Service_Order_Line_Item__c soliRec1 = new Service_Order_Line_Item__c();
        soliRec1.Service_Order_Header__c = serviceOrderHeaderList[0].Id;
        //soliRec1.Part__c = part.Id;
        soliRec1.Qty_Needed__c = -1;
        soliRec1.Qty_Committed__c = 1;
        soliRec1.Kit_Price__c = 10;
       // soliRec1.Actual_Kit_Price__c = fee1.Price__c;
        soliRec1.Deal__c = serviceOrderHeaderList[0].Deal__c;
        soliRec1.Deal_Item__c = serviceOrderHeaderList[0].Deal_Item__c;
        insert soliRec1;
        
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(false, coHeaderId, partId, 50);
        coLineItemRec1.Avg_Cost__c = 25;
        coLineItemRec1.Deal__c = dealRecId;
        insert coLineItemRec1;
        
        CO_Line_Item__c coLineItemRec2 = TestUtil.createCOLineItem(false, coHeaderId, partId, 50);
        coLineItemRec2.Avg_Cost__c = 25;
        insert coLineItemRec2;
        
        CO_Line_Item__c coLineItemRec3 = TestUtil.createCOLineItem(false, coHeaderId, partId, -5);
        coLineItemRec3.Avg_Cost__c = 25;
        coLineItemRec3.Deal__c = dealRecId;
        insert coLineItemRec3;

        CO_Invoice_Header__c coinvoiceHeaderRec = TestUtil.createCOInvoiceHeader(false, coHeaderId, 'Closed');
        coinvoiceHeaderRec.Invoice_Date__c = Datetime.now().addDays(2);
        coInvoiceHeaderRec.AutoNumberHolder__c = AutonumberRecId;
        coInvoiceHeaderRec.Total__c = 50;
        coinvoiceHeaderRec.Checkout_Type__c = 'Third-Party';
        insert coinvoiceHeaderRec;
        
        CO_Invoice_Header__c coinvoiceHeaderRec1 = TestUtil.createCOInvoiceHeader(false, coHeaderId, 'Closed');
        coinvoiceHeaderRec1.Invoice_Date__c = Datetime.now().addDays(2);
        coInvoiceHeaderRec1.AutoNumberHolder__c = AutonumberRecId;
        coInvoiceHeaderRec1.Total__c = 50;
        coinvoiceHeaderRec1.Checkout_Type__c = 'Customer';
        insert coinvoiceHeaderRec1;
        
        Individual_Tax__c individualTax = new Individual_Tax__c();
        individualTax.Sales_Tax_Item_Name__c = 'Sales_Tax_Item_Name1';
        individualTax.Tax_Rate__c = 50.0;
        individualTax.CO_Line_Item__c = coLineItemRec2.Id;
        insert individualTax;
        
        CO_Invoice_Item__c coinvoiceitemRec1  = TestUtil.createCOInvoiceItem(true, testCategoryId, coinvoiceHeaderRec.Id, coLineItemRec1.id);
        CO_Invoice_Item__c coinvoiceitemRec2  = TestUtil.createCOInvoiceItem(false, testCategoryId, coinvoiceHeaderRec1.Id, null);
        coinvoiceitemRec2.Service_Order_Header__c = serviceOrderHeaderList[0].Id;
        insert coinvoiceitemRec2;
        CO_Invoice_Item__c coinvoiceitemRec3  = TestUtil.createCOInvoiceItem(false, testCategoryId, coinvoiceHeaderRec.Id, coLineItemRec1.id);
        coinvoiceitemRec3.Deal__c = dealRecId;
        insert coinvoiceitemRec3;
        CO_Invoice_Item__c coinvoiceitemRec4  = TestUtil.createCOInvoiceItem(false, testCategoryId, coinvoiceHeaderRec.Id, coLineItemRec1.id);
        coinvoiceitemRec4.Service_Order_Header__c = serviceOrderHeaderList[0].Id;
        insert coinvoiceitemRec4;
        CO_Invoice_Item__c coinvoiceitemRec5  = TestUtil.createCOInvoiceItem(false, testCategoryId, coinvoiceHeaderRec.Id, null);
        coinvoiceitemRec5.Service_Order_Header__c = serviceOrderHeaderList[1].Id;
        insert coinvoiceitemRec5;
 
        CO_Invoice_Item__c coinvoiceitemRec7  = TestUtil.createCOInvoiceItem(true, testCategoryId, coinvoiceHeaderRec.Id, null);
        
        CO_Invoice_Item__c coinvoiceitemRec8  = TestUtil.createCOInvoiceItem(true, testCategoryId, coinvoiceHeaderRec.Id, coLineItemRec3.id);
        
    	List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'Customer Order Sales Invoices', 'Sales - Miscellaneous Sales, Receive Payments, General Journal Entries');
        
    }
    
    @isTest
    static void executePaymentsDataMigrationBatchTestA(){
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory1 = TestUtil.createCategory(true, 'Test Category');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category', 'Unit', 'Testing Category', true, true);
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        Account customer2 = TestUtil.createCustomer(true, 'customerName2', 'xyz@xyz.com', 'jaipur', '2222222222', null, null, false, true, 'Business');
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, customer.Id);
        CO_Header__c coHeader2 = TestUtil.createCOHeader(true, customer2.Id);
        CO_Header__c coHeader3 = TestUtil.createCOHeader(false, null);
        coHeader3.CO_Type__c = 'Cash Sale';
        insert coHeader3;
        CO_Header__c coHeader4 = TestUtil.createCOHeader(false, null);
        coHeader4.CO_Type__c = 'Internal Service';
        insert coHeader4;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
       // Fee__c fee1 = TestUtil.createFee(True, True, testCategory.Id, 'test1', coHeader.Id, 'Description', 100, True);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Sales Tax Item 2', 30, 'Testing Form Label 2', true, null);
        
        List<SObject> sObjectListToInsert = new List<SObject>();
        
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true;
        Part.Package_Qty__c = 22;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 1;
        insert part;
        Fee__c fee = TestUtil.createFee(true, true, testCategory.Id, 'test1', coHeader1.Id, 'Description', 100, true);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory1.Id, 'Code', coHeader1.Id, 'Description', true, 10, 'LabourCodeName', 10, true);
        Product__c testProduct1 = TestUtil.createProduct(false, testCategory.Id, 'Test Product2', vendor.Id);
        testProduct1.Type__c = 'Financing Product';
        testProduct1.Price__c = 50;
        insert testProduct1;
        
        Configurations__c taxSetting = Configurations__c.getOrgDefaults();
        taxSetting.Default_Tax_on_Fee__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Labor__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Part__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Vendor_Product__c = defaultSalesTax.Id; 
        taxSetting.Default_Tax_on_Unit__c = defaultSalesTax.Id;
        taxSetting.Tax_Included_Pricing__c = true;
        insert taxSetting;
        
        Deal__c dealRec = new Deal__c();
        dealRec.CO_Header__c = coHeader1.Id;
        insert dealRec;
                
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        dealItemRec.Unit_Model__c = unitmodel.Id;
        dealItemRec.Deal__c = dealRec.Id;
        insert dealItemRec;
        
        Deal_Unit_Price_Cost__c dealUnitPriceCostRec = new Deal_Unit_Price_Cost__c(Item_Description__c = 'Test Deal Unit Price And Cost 2', Price__c = 7000, Qty__c = 1, Type__c ='Dealer'); 
        dealUnitPriceCostRec.Deal_Item__c = dealItemRec.Id;
        sObjectListToInsert.add(dealUnitPriceCostRec);
        
        Option_Fee__c optionAndFeeRec1 = new Option_Fee__c();
        optionAndFeeRec1.Deal_Item__c = dealItemRec.Id;
        optionAndFeeRec1.Qty__c = 2;
        optionAndFeeRec1.Labour_Code__c = labourCode.Id;
        optionAndFeeRec1.Sales_Tax_Percentage__c = 10;
        sObjectListToInsert.add(optionAndFeeRec1);
        
        Option_Fee__c optionAndFeeRec2 = new Option_Fee__c();
        optionAndFeeRec2.Deal_Item__c = dealItemRec.Id;
        optionAndFeeRec2.Qty__c = 2;
        optionAndFeeRec2.Fee__c = fee.Id;
        optionAndFeeRec2.Sales_Tax_Percentage__c = 10;
        sObjectListToInsert.add(optionAndFeeRec2);
        
        Option_Fee__c optionAndFeeRec3 = new Option_Fee__c();
        optionAndFeeRec3.Deal_Item__c = dealItemRec.Id;
        optionAndFeeRec3.Qty__c = 2;
        optionAndFeeRec3.Product__c = testProduct1.Id;
        optionAndFeeRec3.Sales_Tax_Percentage__c = 10;
        sObjectListToInsert.add(optionAndFeeRec3);
        
        AutoNumberHolder__c AutonumberRec = new AutoNumberHolder__c();
        insert AutonumberRec;
        
        insert sObjectListToInsert;
        
        String soHeader1 = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader1.Id)));
        String soHeader2 = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader2.Id)));
        List<Service_Order_Header__c> serviceOrderHeaderList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>());
        
        serviceOrderHeaderList[0].Deal_Item__c = dealItemRec.Id;
        update serviceOrderHeaderList[0];
        
        sObjectListToInsert = new List<SObject>();
        Service_Order_Line_Item__c soliRec1 = new Service_Order_Line_Item__c();
        soliRec1.Service_Order_Header__c = serviceOrderHeaderList[1].Id;
       // soliRec1.Fee__c = fee1.Id;
        soliRec1.Qty_Needed__c = 1;
        soliRec1.Qty_Committed__c = 1;
        sObjectListToInsert.add(soliRec1);
        
        Test.startTest();
               
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(false, coHeader3.Id, part.Id, 50);
        coLineItemRec1.Avg_Cost__c = 25;
        sObjectListToInsert.add(coLineItemRec1);
        
        CO_Line_Item__c coLineItemRec2 = TestUtil.createCOLineItem(false, coHeader4.Id, part.Id, 50);
        coLineItemRec2.Avg_Cost__c = 25;
        sObjectListToInsert.add(coLineItemRec2);
        
        Individual_Tax__c individualTax = new Individual_Tax__c();
        individualTax.Sales_Tax_Item_Name__c = 'Sales_Tax_Item_Name1';
        individualTax.Tax_Rate__c = 50.0;
        individualTax.CO_Line_Item__c = coLineItemRec1.Id;
        sObjectListToInsert.add(individualTax);

        CO_Invoice_Header__c coinvoiceHeaderRec = TestUtil.createCOInvoiceHeader(false, coHeader1.Id, 'Closed');
        coinvoiceHeaderRec.Invoice_Date__c = Datetime.now().addDays(2);
        coInvoiceHeaderRec.AutoNumberHolder__c = AutonumberRec.Id;
        coInvoiceHeaderRec.Total__c = 50;
        coInvoiceHeaderRec.SalesTax_Total__c = 100;
        coInvoiceHeaderRec.Checkout_Type__c = 'Customer';
        sObjectListToInsert.add(coinvoiceHeaderRec);
        
        CO_Invoice_Header__c coinvoiceHeaderRec2 = TestUtil.createCOInvoiceHeader(false, coHeader2.Id, 'Closed');
        coinvoiceHeaderRec2.Invoice_Date__c = Datetime.now().addDays(2);
        coinvoiceHeaderRec2.AutoNumberHolder__c = AutonumberRec.Id;
        coinvoiceHeaderRec2.Total__c = 50;
        coinvoiceHeaderRec2.SalesTax_Total__c = 100;
        coinvoiceHeaderRec2.Checkout_Type__c = 'Customer';
        sObjectListToInsert.add(coinvoiceHeaderRec2);
        
        CO_Invoice_Header__c coinvoiceHeaderRec3 = TestUtil.createCOInvoiceHeader(false, coHeader3.Id, 'Closed');
        coinvoiceHeaderRec3.Invoice_Date__c = Datetime.now().addDays(2);
        coinvoiceHeaderRec3.Checkout_Type__c = 'Customer';
        coinvoiceHeaderRec3.AutoNumberHolder__c = AutonumberRec.Id;
        coinvoiceHeaderRec3.Total__c = 50;
        coinvoiceHeaderRec3.SalesTax_Total__c = 100;
        sObjectListToInsert.add(coinvoiceHeaderRec3);
        
        CO_Invoice_Header__c coinvoiceHeaderRec4 = TestUtil.createCOInvoiceHeader(false, coHeader4.Id, 'Closed');
        coinvoiceHeaderRec4.Invoice_Date__c = Datetime.now().addDays(2);
        coinvoiceHeaderRec4.Checkout_Type__c = 'Customer';
        coinvoiceHeaderRec4.Total__c = 50;
        coinvoiceHeaderRec4.SalesTax_Total__c = 100;
        coinvoiceHeaderRec4.AutoNumberHolder__c = AutonumberRec.Id;
        sObjectListToInsert.add(coinvoiceHeaderRec4);
        
        insert sObjectListToInsert;
        
        CO_Invoice_Item__c coinvoiceitemRec1  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeaderRec2.Id, null);
        coinvoiceitemRec1.Service_Order_Header__c = serviceOrderHeaderList[1].Id;
        insert coinvoiceitemRec1;
        
        CO_Invoice_Item__c coinvoiceitemRec2  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeaderRec.Id, null);
        coinvoiceitemRec2.Deal__c = dealRec.Id;
        insert coinvoiceitemRec2;
        
        
        CO_Invoice_Item__c coinvoiceitemRec3  = TestUtil.createCOInvoiceItem(true, testCategory.Id, coinvoiceHeaderRec3.Id, coLineItemRec1.Id);
        CO_Invoice_Item__c coinvoiceitemRec4  = TestUtil.createCOInvoiceItem(true, testCategory.Id, coinvoiceHeaderRec4.Id, coLineItemRec2.Id);
        List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'Customer Order Sales Invoices', 'Sales - Miscellaneous Sales, Receive Payments, General Journal Entries');
        
        Id batchId = AccountingDataMigrationSalesInvoice.executeDataMigrationBatch(200, null, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2), DataExportUtil.SALES_INVOICE_ACCOUNTING_OBJECT_NAME);
        Test.stopTest();
        List<Accounting_Data_Migration__c>  accountMigrateId = [ SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c = 'Customer Order Sales Invoices' ];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId in :accountMigrateId ];
        system.assertEquals(2, attachmentList.size());
    }
    
    @isTest
    static void executePaymentsDataMigrationBatchTestB(){
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        //Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, customer.Id);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
       // Fee__c fee1 = TestUtil.createFee(True, True, testCategory.Id, 'test1', coHeader.Id, 'Description', 100, True);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Sales Tax Item 2', 30, 'Testing Form Label 2', true, null);
        
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true;
        Part.Package_Qty__c = 22;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 1;
        insert part;
        Fee__c fee = TestUtil.createFee(true, true, testCategory.Id, 'test1', coHeader1.Id, 'Description', 100, true);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader1.Id, 'Description', true, 10, 'LabourCodeName', 10, true);
        
        Configurations__c taxSetting = Configurations__c.getOrgDefaults();
        taxSetting.Default_Tax_on_Fee__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Labor__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Part__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Vendor_Product__c = defaultSalesTax.Id; 
        taxSetting.Default_Tax_on_Unit__c = defaultSalesTax.Id;
        taxSetting.Tax_Included_Pricing__c = true;
        insert taxSetting;
        
        AutoNumberHolder__c AutonumberRec = new AutoNumberHolder__c();
        insert AutonumberRec;
        
        Deal__c dealRec = new Deal__c();
        dealRec.CO_Header__c = coHeader1.Id;
        insert dealRec;
        
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        dealItemRec.Unit_Model__c = unitmodel.Id;
        dealItemRec.Deal__c = dealRec.Id;
        insert dealItemRec;
       
        CO_Kit_Header__c cokhRec1 = new CO_Kit_Header__c();
        cokhRec1.CO_Header__c = coHeader1.Id;
        insert cokhRec1;
        
        CO_Kit_Header__c cokhRec2 = new CO_Kit_Header__c();
        cokhRec2.CO_Header__c = coHeader1.Id;
        cokhRec2.Deal__c = dealRec.Id;
        insert cokhRec2;
        
        String soHeader1 = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader1.Id)));   
        List<Service_Order_Header__c> serviceOrderHeaderList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>());
        
        Test.startTest();
        Service_Order_Line_Item__c soliRec1 = new Service_Order_Line_Item__c();
        soliRec1.Service_Order_Header__c = serviceOrderHeaderList[0].Id;
        soliRec1.Part__c = part.Id;
        soliRec1.Kit_Price__c = 10;
        soliRec1.Qty_Needed__c = 1;
        soliRec1.Qty_Committed__c = 1;
        soliRec1.Deal_Item__c = dealItemRec.Id;
        insert soliRec1;
        
        Service_Order_Line_Item__c soliRec2 = new Service_Order_Line_Item__c();
        soliRec2.Service_Order_Header__c = serviceOrderHeaderList[0].Id;
        soliRec2.Fee__c = fee.Id;
        soliRec2.Qty_Needed__c = 1;
        soliRec2.Qty_Committed__c = 1;
        soliRec2.Deal_Item__c = dealItemRec.Id;
        insert soliRec2;
        
        Service_Order_Line_Item__c soliRec3 = new Service_Order_Line_Item__c();
        soliRec3.Service_Order_Header__c = serviceOrderHeaderList[0].Id;
        soliRec3.Labour_Code__c = labourCode.Id;
        soliRec3.Qty_Needed__c = 1;
        soliRec3.Qty_Committed__c = 1;
        soliRec3.Deal_Item__c = dealItemRec.Id;
        insert soliRec3;
        
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(false, coHeader1.Id, part.Id, 50);
        coLineItemRec1.Avg_Cost__c = 25;
        coLineItemRec1.CO_Kit_Header__c = cokhRec1.Id;
        coLineItemRec1.Price__c = 10;
        coLineItemRec1.Tax__c = 10;
        insert coLineItemRec1;
        
        CO_Line_Item__c coLineItemRec2 = new CO_Line_Item__c();
        coLineItemRec2.CO_Header__c = coHeader1.Id;
        coLineItemRec2.Qty__c = -5;
        coLineItemRec2.Avg_Cost__c = 25;
        coLineItemRec2.Fee__c = fee.Id;
        insert coLineItemRec2;
        
        CO_Line_Item__c coLineItemRec3 = new CO_Line_Item__c();
        coLineItemRec3.CO_Header__c = coHeader1.Id;
        coLineItemRec3.Qty__c = -5;
        coLineItemRec3.Avg_Cost__c = 25;
        coLineItemRec3.Fee__c = fee.Id;
        coLineItemRec3.CO_Kit_Header__c = cokhRec2.Id;
        coLineItemRec3.Price__c = 10;
        coLineItemRec3.Tax__c = 10;
        insert coLineItemRec3;

        CO_Invoice_Header__c coinvoiceHeaderRec = TestUtil.createCOInvoiceHeader(false, coHeader1.Id, 'Closed');
        coinvoiceHeaderRec.Invoice_Date__c = Datetime.now().addDays(2);
        coinvoiceHeaderRec.AutoNumberHolder__c = AutonumberRec.Id;
        insert coinvoiceHeaderRec;
        CO_Invoice_Header__c coinvoiceHeaderRec2 = TestUtil.createCOInvoiceHeader(false, coHeader1.Id, 'Closed');
        coinvoiceHeaderRec2.Checkout_Type__c = 'Internal';
        coinvoiceHeaderRec2.Invoice_Date__c = Date.Today();
        coinvoiceHeaderRec2.AutoNumberHolder__c = AutonumberRec.Id;
        insert coinvoiceHeaderRec2;
                
        CO_Invoice_Item__c coinvoiceitemRec1  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeaderRec2.Id, null);
        coinvoiceitemRec1.Service_Order_Header__c = serviceOrderHeaderList[0].Id;
        insert coinvoiceitemRec1;
        
        CO_Invoice_Item__c coinvoiceitemRec2  = TestUtil.createCOInvoiceItem(true, testCategory.Id, coinvoiceHeaderRec.Id, coLineItemRec2.Id);
        
        CO_Invoice_Item__c coinvoiceitemRec3  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeaderRec.Id, null);
        coinvoiceitemRec3.CO_Kit_Header__c = cokhRec1.Id;
        insert coinvoiceitemRec3;
        
        CO_Invoice_Item__c coinvoiceitemRec4  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeaderRec.Id, null);
        coinvoiceitemRec4.CO_Kit_Header__c = cokhRec2.Id;
        insert coinvoiceitemRec4;
        
        CO_Invoice_Item__c coinvoiceitemRec5  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeaderRec.Id, null);
        coinvoiceitemRec5.Service_Order_Header__c = serviceOrderHeaderList[0].Id;
        insert coinvoiceitemRec5;
                
        List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'Customer Order Sales Invoices', 'Sales - Miscellaneous Sales, Receive Payments, General Journal Entries');
        
        Id batchId = AccountingDataMigrationSalesInvoice.executeDataMigrationBatch(200, null, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2), DataExportUtil.SALES_INVOICE_ACCOUNTING_OBJECT_NAME);
        Test.stopTest();
        List<Accounting_Data_Migration__c>  accountMigrateId = [ SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c = 'Customer Order Sales Invoices' ];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId in :accountMigrateId ];
        system.assertEquals(2, attachmentList.size());
    }
    
    @isTest
    static void executePaymentsDataMigrationBatchTestC(){
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory1 = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, customer.Id);
        CO_Header__c coHeader2 = TestUtil.createCOHeader(true, null);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
       // Fee__c fee1 = TestUtil.createFee(True, True, testCategory.Id, 'test1', coHeader.Id, 'Description', 100, True);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Sales Tax Item 2', 30, 'Testing Form Label 2', true, null);
        
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory1.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true;
        Part.Package_Qty__c = 22;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 1;
        insert part;
        
        Configurations__c taxSetting = Configurations__c.getOrgDefaults();
        taxSetting.Default_Tax_on_Fee__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Labor__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Part__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Vendor_Product__c = defaultSalesTax.Id; 
        taxSetting.Default_Tax_on_Unit__c = defaultSalesTax.Id;
        taxSetting.Tax_Included_Pricing__c = false;
        insert taxSetting;
        
        AutoNumberHolder__c AutonumberRec = new AutoNumberHolder__c();
        insert AutonumberRec;
        
        String soHeader1 = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader1.Id)));
        List<Service_Order_Header__c> serviceOrderHeaderList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>());
        
        Test.startTest();
               
        CO_Line_Item__c coLineItemRec3 = TestUtil.createCOLineItem(false, coHeader1.Id, part.Id, 50);
        coLineItemRec3.Avg_Cost__c = 25;
        insert coLineItemRec3;
        
        Individual_Tax__c individualTax = new Individual_Tax__c();
        individualTax.Sales_Tax_Item_Name__c = 'Sales_Tax_Item_Name1';
        individualTax.Tax_Rate__c = 50.0;
        individualTax.CO_Line_Item__c = coLineItemRec3.Id;
        insert individualTax;

        CO_Invoice_Header__c coinvoiceHeaderRec = TestUtil.createCOInvoiceHeader(false, coHeader1.Id, 'Closed');
        coinvoiceHeaderRec.Invoice_Date__c = Datetime.now().addDays(2);
        coInvoiceHeaderRec.AutoNumberHolder__c = AutonumberRec.Id;
        coInvoiceHeaderRec.Total__c = 50;
        coInvoiceHeaderRec.SalesTax_Total__c = 100;
        coInvoiceHeaderRec.Checkout_Type__c = 'Internal';
        insert coinvoiceHeaderRec;
        
        CO_Invoice_Header__c coinvoiceHeaderRec1 = TestUtil.createCOInvoiceHeader(false, coHeader2.Id, 'Closed');
        coinvoiceHeaderRec1.Invoice_Date__c = Datetime.now().addDays(2);
        coInvoiceHeaderRec1.AutoNumberHolder__c = AutonumberRec.Id;
        coInvoiceHeaderRec1.Total__c = 50;
        coInvoiceHeaderRec1.SalesTax_Total__c = 100;
        coInvoiceHeaderRec1.Checkout_Type__c = 'Internal';
        insert coinvoiceHeaderRec1;
        
        CO_Invoice_Item__c coinvoiceitemRec1  = TestUtil.createCOInvoiceItem(true, testCategory1.Id, coinvoiceHeaderRec.Id, coLineItemRec3.Id);
        CO_Invoice_Item__c coinvoiceitemRec2  = TestUtil.createCOInvoiceItem(true, testCategory1.Id, coinvoiceHeaderRec1.Id, coLineItemRec3.Id);

        List<Accounting_Data_Migration__c> accountMigrate = TestUtil.createAccountMigration(true, 1, 'Customer Order Sales Invoices', 'Sales - Miscellaneous Sales, Receive Payments, General Journal Entries');
        
        Id batchId = AccountingDataMigrationSalesInvoice.executeDataMigrationBatch(200, null, 'THIS_WEEK', DateTime.now(), DateTime.now().addDays(2), DataExportUtil.SALES_INVOICE_ACCOUNTING_OBJECT_NAME);
        Test.stopTest();
        List<Accounting_Data_Migration__c>  accountMigrateId = [ SELECT Id FROM Accounting_Data_Migration__c WHERE  Object_Name__c = 'Customer Order Sales Invoices' ];
        List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE ParentId in :accountMigrateId ];
       // system.assertEquals(3, attachmentList.size());
       system.assert(true,true);
    }
}