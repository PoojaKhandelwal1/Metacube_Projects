@isTest
private class VendorOrderReceivingTest {
 
 
    @testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
        
        List<General_Configurations__c> config = [SELECT Id FROM General_Configurations__c LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
        System.assertNotEquals(0, config.size());
    }

    static testMethod void vendorReceivingScenarioTest () {
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
        
        Part__c partRec = TestUtil.createPart(true, 'partNumberP03', vendor.Id, 'Test Part03', testCategory.Id, 10, 10, 50, 100, 100);
        CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(true, coHeader.Id, partRec.Id, 120);

        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id; 
        insert voHeader;
		String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendor.Id),BPUtility.getEncodedString(voHeader.Id), true,BPUtility.getEncodedString( System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String finalizedLineItems = VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id),BPUtility.getEncodedString(vendor.Id),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
       	Test.StartTest();
       	List<Vendor_Order_Header__c> vendorOrderList = [Select Id,Name,Purchase_Order_Type__c,Status__c,Total_Recieved__c,Total__c from Vendor_Order_Header__c limit 10];
        system.assertEquals(vendorOrderList[0].Status__c,'On Order'); 
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        //system.assert(false, voLineItems);
        system.assertEquals(voLineItems.VendorOrderLineItemGroupList[0].Status, 'On Order');
        
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(false, vendor.Id, 'In Progress');
        Id vorId = Id.valueOf(BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id),BPUtility.getEncodedString(null))));
        String VendorOrderReceiveItems = VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id),BPUtility.getEncodedString(vorId), true);
         
        //1st order 
        Test.StopTest();
        VendorOrderReceivingCtrl_PartialTest.vendorRecevingStatus_Partial(vorId,partRec.Id,voHeader.Id,similarlineitem, voLineItems.VendorOrderLineItemGroupList[0].Id, vendor.Id); 
        
        //List<Vendor_Order_Header__c> vendorOrderUpdatedList = [Select Id,Name,Purchase_Order_Type__c,Status__c,Total_Recieved__c,Total__c from Vendor_Order_Header__c limit 10];  
         
    }
    
    static testMethod void vendorReceivingScenarioTest2 () {
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
        
        Part__c partRec = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 100, 50, 100, 100);
        partRec.Packaged_Part__c = true ;
        partRec.Package_Qty__c = 10;
        partRec.Auto_reorder_Min__c = 0;
        partRec.Auto_reorder_Max__c = 20;
        partRec.Order_Lots__c = 1;
        partRec.Qty_On_Order__c = 0;
        insert partRec;
        
        CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(true, coHeader.Id, partRec.Id, 120);

        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id; 
        insert voHeader;
        
        List<Vendor_Order_Line_Item__c> voliList = [Select Id from Vendor_Order_Line_Item__c];
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id, voliList[1].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        
        
		//String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendor.Id),BPUtility.getEncodedString(voHeader.Id), true,BPUtility.getEncodedString( System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String finalizedLineItems = VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id),BPUtility.getEncodedString(vendor.Id),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
       	Test.StartTest();
       	List<Vendor_Order_Header__c> vendorOrderList = [Select Id,Name,Purchase_Order_Type__c,Status__c,Total_Recieved__c,Total__c from Vendor_Order_Header__c limit 10];
        system.assertEquals(vendorOrderList[0].Status__c,'On Order'); 
        system.assertEquals(voLineItems.VendorOrderLineItemGroupList[0].Status, 'On Order');
        
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(false, vendor.Id, 'In Progress');
        Id vorId = Id.valueOf(BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id),BPUtility.getEncodedString(null))));
        String VendorOrderReceiveItems = VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id),BPUtility.getEncodedString(vorId), true);
         
        //1st order 
        Test.StopTest();
        VendorOrderReceivingCtrl_PartialTest.vendorRecevingStatus_Partial2(vorId,partRec.Id,voHeader.Id,similarlineitem, voLineItems.VendorOrderLineItemGroupList[0].Id, vendor.Id); 
        
        //List<Vendor_Order_Header__c> vendorOrderUpdatedList = [Select Id,Name,Purchase_Order_Type__c,Status__c,Total_Recieved__c,Total__c from Vendor_Order_Header__c limit 10];  
         
    }
    
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