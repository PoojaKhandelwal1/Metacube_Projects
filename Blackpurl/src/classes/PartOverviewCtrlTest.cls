/**
 * Author: Durga Singh
 * Since: September 8, 2015
 * Name: VendorOrderReceivingCtrlTest
 * Description: test Class for complete part overview functionality .
 **/
@isTest
private class PartOverviewCtrlTest {

    static testMethod void getPartDetailTest() {
       	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 2;
        insert part;
        
        String partDetails = BPUtility.getDecodedString(PartOverviewCtrl.getPartDetail(BPUtility.getEncodedString(part.Id)));
        List<PartDetail> partinformations = (List<PartDetail>) System.JSON.deserialize(partDetails, List<PartDetail>.class); 
        system.assertEquals(partinformations[0].PartNumber, 'partNumberP01');
    }
    
    static testMethod void getDefaultCategoryTest() {
       	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category', 'Part', 'categoryDescription', true, true);
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 2;
        insert part;
        
        String categoryDetails = BPUtility.getDecodedString(PartOverviewCtrl.getDefaultCategory(BPUtility.getEncodedString(vendor.Id)));
        PartOverviewCtrlTest.Category categoryinformations = (PartOverviewCtrlTest.Category) System.JSON.deserialize(categoryDetails, PartOverviewCtrlTest.Category.class); 
        system.assertEquals (categoryinformations.DefaultPartCategoryName, 'Test Category' );
    }
    
    static testMethod void getDefaultCategoryTestA() {
       	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
       	Account vendor1 = TestUtil.createVendor(true, 'Test Vendor1');
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	Category__c testCategory1 = TestUtil.createCategory(true, 'Test Category1');	
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 2;
        insert part;
        
        String categoryDetails = BPUtility.getDecodedString(PartOverviewCtrl.getDefaultCategory(BPUtility.getEncodedString(vendor.Id)));
        //
        PartOverviewCtrlTest.Category categoryinformations = (PartOverviewCtrlTest.Category) System.JSON.deserialize(categoryDetails, PartOverviewCtrlTest.Category.class); 
        system.assertEquals (categoryinformations.DefaultCategoryName, null);
    }
    
    static testMethod void savePartTest() {
       	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true); 
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        /*Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 2;
        insert part;*/
        
        String partDetails = BPUtility.getDecodedString(PartOverviewCtrl.savePart(BPUtility.getEncodedString('[{"IsTaxable":true,"IsPackagedPart":true,"OrderLots":1,"InStockQty":"100.00","PackagedUnit":"PKG","Cost":50,"PackagedCost":"100.000","MSRP":0,"Retail":0,"EnviroFee":0,"PackagedQty":2,"AutoReorderAt":0,"AutoReorderTo":1,"CategoryId":"'+testCategory.Id+'","CategoryName":"Part_B1_Category","PartNumber":"testpart","Description":"test","VendorId":"'+vendor.Id+'","VendorName":"Tsst","ReplacedById":null,"ReplacedByName":"","Location":"houston","AssignedTags":[]}]')));
        //String updatedPartDetails = BPUtility.getDecodedString(PartOverviewCtrl.savePart(BPUtility.getEncodedString('[{"Id":"'+partDetails+'","IsTaxable":false,"IsPackagedPart":true,"OrderLots":1,"InStockQty":"100.00","PackagedUnit":"PKG","Cost":50,"PackagedCost":"100.000","MSRP":0,"Retail":0,"EnviroFee":0,"PackagedQty":2,"AutoReorderAt":0,"AutoReorderTo":1,"CategoryId":"'+testCategory.Id+'","CategoryName":"Part_B1_Category","PartNumber":"testpart","Description":"test","VendorId":"'+vendor.Id+'","VendorName":"Tsst","ReplacedById":null,"ReplacedByName":"","Location":"houston"}]')));
		
		system.assertEquals(true, true);
    }
    
    
     static testMethod void inactivePartTest() {

        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Part__c part2 = TestUtil.createPart(true, 'partNumberP03', vendor.Id, 'Test Part03', testCategory.Id, 10, 20, 50, 100, 0);
        CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(true, coHeader.Id, part2.Id, 150);

		String partDetails = BPUtility.getDecodedString(PartOverviewCtrl.isNonInventoryFieldEditable(BPUtility.getEncodedString(part2.Id)));
		system.assertEquals(partDetails.contains('false'), true);
     }
 
 static testMethod void  inactivePartTestA () {
     
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        //System.JSON.serialize(pageSort)
		 
		
		Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 0);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 1;
        insert part;
        
        Part__c part1 = TestUtil.createPart(false, 'partNumberP012', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part1.Packaged_Part__c = false;
        part1.Qty_On_Order__c = 0;
        part1.Order_Lots__c = 1;
        insert part1;

        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(true, Vendor.Id);
		      
        String LineItemFromAddToSearch = BPUtility.getDecodedString(VendorOrderCtrl.addVOLineItemFromSearchToAdd(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(voHeader.Id), 60, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(null), true));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(LineItemFromAddToSearch, VendorOrderLineItemWrapper.class);
   		String partDetails = BPUtility.getDecodedString(PartOverviewCtrl.isNonInventoryFieldEditable(BPUtility.getEncodedString(part.Id)));
		system.assertEquals(partDetails.contains('false'), true);
 }
 
 /*static testMethod void InactivePartTestB() {

        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        //System.JSON.serialize(pageSort)

        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 0);
        Part.Packaged_Part__c = true;
        Part.Package_Qty__c = 22;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 100;
        part.Order_Lots__c = 1;
        //part.Qty_On_Order__c = 0;
        insert part;

        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);

        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;

        Vendor_Receiving_Header__c vor = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');

        String groupLineItems = BPUtility.getDecodedString(VendorOrderCtrl.groupAllSimilarVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(part.Id), 
        							BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        							BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        							BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), 
        								BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        								BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        								BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vorId), true));
        String addItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addToItemSubsection(BPUtility.getEncodedString(vor.id), BPUtility.getEncodedString(part.Id), 
        											BPUtility.getEncodedString(vendor.Id), false, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
 		String partDetails = BPUtility.getDecodedString(PartOverviewCtrl.isNonInventoryFieldEditable(BPUtility.getEncodedString(part.Id)));
		system.assertEquals(partDetails.contains('false'), true);
 }*/
 
static testMethod void InnactivePartTestC() {
			
		PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<PaginationSorting.SortAttrs>{new PaginationSorting.SortAttrs('Item', 'ASC')};
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Labour');
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        coHeader.Order_status__c = 'Open';
        insert coHeader;
    	Unit_Make__c unitMake = TestUtil.createUnitMake(true, 'unitMakeName', 'VIN', true);
    	Unit_Model__c unitModel = TestUtil.createUnitModel(true, 'unitModelName', 'VIN', true, unitMake.Id);
    	
    	Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 5, 5, 5, 5, 0);
    	Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
    	Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, false, unitMake.Id, unitModel.Id);
    	Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, Part.Id, 1, 5.0);
    	Transaction_Type__c transactionType = TestUtil.createTransactionType(true, 'Code', 'Customer');
    	String partDetails = BPUtility.getDecodedString(PartOverviewCtrl.isNonInventoryFieldEditable(BPUtility.getEncodedString(part.Id)));
		system.assertEquals(partDetails.contains('false'), true);
}

static testMethod void InactivePartTestD() {
			
		PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<PaginationSorting.SortAttrs>{new PaginationSorting.SortAttrs('Item', 'ASC')};
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Labour');
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        coHeader.Order_status__c = 'Open';
        insert coHeader;
    	Unit_Make__c unitMake = TestUtil.createUnitMake(true, 'unitMakeName', 'VIN', true);
    	Unit_Model__c unitModel = TestUtil.createUnitModel(true, 'unitModelName', 'VIN', true, unitMake.Id);
    	
    	Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 5, 5, 5, 5, 0);
    	Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
    	Kit_Header__c kitHeader = TestUtil.createKitHeader(true, false, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, false, unitMake.Id, unitModel.Id);
    	Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, Part.Id, 1, 5.0);
    	Transaction_Type__c transactionType = TestUtil.createTransactionType(true, 'Code', 'Customer');
    	
    	String partDetails = BPUtility.getDecodedString(PartOverviewCtrl.isNonInventoryFieldEditable(BPUtility.getEncodedString(part.Id)));
		system.assertEquals(partDetails.contains('true'), true);
}

   static testMethod void InactivePartTestE() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 120);
        CO_Line_Item__c coLineItemRec = TestUtil.createCOLineItem(true, coHeader1.Id, part.Id, 120);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader1.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(true, testCategory.Id, coinvoiceHeader1.Id, coLineItemRec.Id, true );
       
        Test.startTest();
        String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeader1.Id)));
        CustomerOrderCtrl.closedInvoiceAction(BPUtility.getEncodedString(COInvoiceItemJSON), BPUtility.getEncodedString(coHeader1.Id), BPUtility.getEncodedString('Customer'));
        Test.stopTest();
        
        /*List<CO_Invoice_Item__c> COInvoiceItems = [select Category__c, CO_Line_Item__c, isActive__c, Item_Category_Code__c, Item_ID__c, Item_Type__c, Price__c, Qty__c from CO_Invoice_Item__c];
        //system.assertEquals(COInvoiceItems.size(), 2);
        List<CO_Invoice_Header__c> COInvoiceHeaders = [select Invoice_Status__c from CO_Invoice_Header__c];
        //system.assert(false,COInvoiceHeaders);
        system.assertEquals(COInvoiceHeaders[0].Invoice_Status__c, 'Active');
        system.assertEquals(COInvoiceHeaders[1].Invoice_Status__c, 'Closed');
        system.assertEquals(COInvoiceHeaders[2].Invoice_Status__c, 'Active');*/
        
        
        List<Part__c> parts = [select AvailableParts__c from Part__c where Id = :part.id ];
        system.assertEquals(parts[0].AvailableParts__c, 0);
        String partDetails = BPUtility.getDecodedString(PartOverviewCtrl.isNonInventoryFieldEditable(BPUtility.getEncodedString(part.Id)));
		system.assertEquals(partDetails.contains('true'), true);
        
        }
        
 static testMethod void inactivePartTestF() {

        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Part__c part2 = TestUtil.createPart(true, 'partNumberP03', vendor.Id, 'Test Part03', testCategory.Id, 10, 20, 50, 100, 1);

		String partDetails = BPUtility.getDecodedString(PartOverviewCtrl.isNonInventoryFieldEditable(BPUtility.getEncodedString(part2.Id)));
		system.assertEquals(partDetails.contains('false'), true);
     }
    public class Category {
    	
    	public String DefaultCategoryId;
    	public String DefaultCategoryName;
    	public String DefaultPartCategoryName;
    	public String DefaultPartCategoryId;
    }
    
    // Wrapper class for related list pagination and sorting combination
    public class VendorPaginationSorting {
    	
    	// Change count
    	public Integer ChangesCount;
    	
    	// Current page number
    	public Integer CurrentPage;
    	
    	// page size
    	public Integer PageSize;
    	
    	// Sorting Attrs
    	public List<SortAttrs> Sorting;
    }
    
    // SortAttrs for sorting attributes
    public class SortAttrs {
    	
    	// Field name
    	public String FieldName;
    	
    	// Sort direction
    	public String SortDirection;
    	
    	public SortAttrs(String FieldName, String SortDirection){
    		this.FieldName = FieldName;
    		this.SortDirection = SortDirection;
    	}
    }
    
}