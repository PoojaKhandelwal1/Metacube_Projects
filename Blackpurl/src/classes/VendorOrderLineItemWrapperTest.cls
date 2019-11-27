@isTest
private class VendorOrderLineItemWrapperTest {
    
    static testmethod void VOLineItemWrapperTest(){
    	VendorOrderCtrl.PaginationSorting paginationSorting = new VendorOrderCtrl.PaginationSorting();
    	paginationSorting.CurrentPage = 5;
    	paginationSorting.PageSize = 10;
    	    	
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
				
		PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
		List<PO_Type__c> POTypeList = SOQLUtil.getPOTypeRecordsById(new List<Id>{POType.Id});
		//system.assert(false,POTypeList);
		
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        Test.startTest();
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        Test.stopTest();
        
        Vendor_Receiving_Header__c vor1 = TestUtil.createVendorOrderReceiveHeader(false, vendor.Id, 'In Progress');
        vor1.Finalized_Date__c =Date.Today();
        insert vor1;
        Vendor_Receiving_Group__c vorg = new Vendor_Receiving_Group__c();
		vorg.Vendor_Receiving_header__c = vor1.Id;
		vorg.Recieved__c = 2;
		vorg.Cost__c = 10;
		insert vorg;
        
		In_Progress_VR__c inProgressVRRec =new In_Progress_VR__c();
		inProgressVRRec.Vendor_Order_Header__c = voHeader.Id;
		inProgressVRRec.Vendor_Receiving_Header__c = vor1.Id;
		insert inProgressVRRec;
		
        Vendor_Order_Line_Item_Group__c voliGroup = TestUtil.createVendorOrderLineItemGroup(true, voHeader.Id, part.Id);
       
        Vendor_Order_Line_Item__c voLineItem1 = TestUtil.createVendorOrderLineItem(false, voHeader.Id, part.Id, 150);
        voLineItem1.CO_Line_Item__c = coLineItem.Id;
        voLineItem1.Qty_Needed__c = 50;
        voLineItem1.Is_required_For_Customer__c = true;
        voLineItem1.Vendor_Order_Line_Item_Group__c = voliGroup.Id;
        voLineItem1.Vendor_Receiving_Group__c = vorg.Id;
        insert voLineItem1;
        
        Vendor_Order_Line_Item__c voLineItem2 = TestUtil.createVendorOrderLineItem(false, null, part.Id, 150);
        voLineItem2.CO_Line_Item__c = coLineItem.Id;
        voLineItem2.Qty_Needed__c = 50;
        voLineItem2.Is_required_For_Customer__c = false;
        voLineItem2.Is_Service__c = false;
        insert voLineItem2;
        
        Map<String, String> listsSortFieldMap = new Map<String, String>{'Items' => '', 'Customers' => '', 'Stocks' => ''};
        VendorOrderHeader vendorOrderHeader = new VendorOrderHeader(voHeader.Id);
        
        List<Vendor_Order_Line_Item__c> voLineItemsRequiredForStock = SOQLUtil.getVOLineItem(vendor.Id, voHeader.Id, false);
       // system.assert(false,voLineItemsRequiredForStock);
        List<Vendor_Order_Line_Item__c> voLineItemsRequiredForCustomer = SOQLUtil.getVOLineItem(vendor.Id, voHeader.Id, true);
       // system.assert(false,voLineItemsRequiredForCustomer);
        List<Vendor_Order_Line_Item_Group__c> voliGroupLists = SOQLUtil.getVOLIGroupsWithItemsInVO('Part__r.Vendor__c', vendor.Id, voHeader.Id);
       // system.assert(false,voliGroupLists);
        
        VendorOrderLineItemWrapper vendorOrderLineItemWrapperObj = new VendorOrderLineItemWrapper(voLineItemsRequiredForStock,
        voLineItemsRequiredForCustomer, voliGroupLists, paginationSorting,
        paginationSorting, paginationSorting,
        listsSortFieldMap, vendorOrderHeader, null, 
        POTypeList, new List<Vendor_Order_Line_Item_Group__c>());
        System.assertEquals(vendorOrderLineItemWrapperObj.TotalLineItemGroups,voliGroupLists.size());
    }
    
    static testmethod void VOLineItemWrapperTestA(){
    	
    	VendorOrderCtrl.SortAttrs sortAttrs =new VendorOrderCtrl.SortAttrs();
        sortAttrs.FieldName = 'Items';
        sortAttrs.SortDirection = 'ASC';
        
    	VendorOrderCtrl.PaginationSorting paginationSorting = new VendorOrderCtrl.PaginationSorting();
    	paginationSorting.CurrentPage = 5;
    	paginationSorting.PageSize = 10;
        paginationSorting.Sorting = new List<VendorOrderCtrl.SortAttrs>{sortAttrs};
            	    	
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true;
        Part.Package_Qty__c = 22;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 2;
        //part.Qty_On_Order__c = 0;
        insert part;
				
		PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
		List<PO_Type__c> POTypeList = SOQLUtil.getPOTypeRecordsById(new List<Id>{POType.Id});
		//system.assert(false,POTypeList);
		
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        Test.startTest();
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        Test.stopTest();
        
        Vendor_Receiving_Header__c vor1 = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
        Vendor_Receiving_Group__c vorg = new Vendor_Receiving_Group__c();
		vorg.Vendor_Receiving_header__c = vor1.Id;
		vorg.Recieved__c = 2;
		vorg.Cost__c = 10;
		insert vorg;
        
		In_Progress_VR__c inProgressVRRec =new In_Progress_VR__c();
		inProgressVRRec.Vendor_Order_Header__c = voHeader.Id;
		inProgressVRRec.Vendor_Receiving_Header__c = vor1.Id;
		insert inProgressVRRec;
		
        Vendor_Order_Line_Item_Group__c voliGroup = TestUtil.createVendorOrderLineItemGroup(false, voHeader.Id, part.Id);
        voliGroup.Status__c = 'On Order';
        insert voliGroup;
        Vendor_Order_Line_Item_Group__c voliGroup1 = TestUtil.createVendorOrderLineItemGroup(false, voHeader.Id, part.Id);
        voliGroup1.Status__c = 'On Order';
        insert voliGroup1;
       
        Vendor_Order_Line_Item__c voLineItem1 = TestUtil.createVendorOrderLineItem(false, null, part.Id, 150);
        voLineItem1.CO_Line_Item__c = coLineItem.Id;
        voLineItem1.Qty_Needed__c = 50;
        voLineItem1.Is_required_For_Customer__c = true;
        voLineItem1.Vendor_Order_Line_Item_Group__c = voliGroup.Id;
        voLineItem1.Vendor_Receiving_Group__c = vorg.Id;
        voLineItem1.Is_Excess__c = true;
        insert voLineItem1;
        
        Vendor_Order_Line_Item__c voLineItem2 = TestUtil.createVendorOrderLineItem(false, null, part.Id, 150);
        voLineItem2.CO_Line_Item__c = coLineItem.Id;
        voLineItem2.Qty_Needed__c = 50;
        voLineItem2.Is_required_For_Customer__c = true;
        voLineItem2.Vendor_Order_Line_Item_Group__c = voliGroup.Id;
        voLineItem2.Vendor_Receiving_Group__c = vorg.Id;
        voLineItem2.Is_Excess__c = true;
        insert voLineItem2;
        
        Vendor_Order_Line_Item__c voLineItem3 = TestUtil.createVendorOrderLineItem(false, null, part.Id, 150);
        voLineItem3.CO_Line_Item__c = coLineItem.Id;
        voLineItem3.Qty_Needed__c = 50;
        voLineItem3.Is_required_For_Customer__c = false;
        voLineItem3.Is_Service__c = false;
        voLineItem3.Is_Excess__c = true;
        insert voLineItem3;
        
        Vendor_Order_Line_Item__c voLineItem4 = TestUtil.createVendorOrderLineItem(false, null, part.Id, 150);
        voLineItem4.CO_Line_Item__c = coLineItem.Id;
        voLineItem4.Qty_Needed__c = 50;
        voLineItem4.Is_required_For_Customer__c = true;
        voLineItem4.Vendor_Order_Line_Item_Group__c = voliGroup1.Id;
        voLineItem4.Vendor_Receiving_Group__c = vorg.Id;
        voLineItem4.Is_Excess__c = true;
        insert voLineItem4;
        
        Map<String, String> listsSortFieldMap = new Map<String, String>{'Items' => '', 'Customers' => '', 'Stocks' => ''};
        listsSortFieldMap.put('Items', 'ASC');
        listsSortFieldMap.put('Customers', 'ASC');
        listsSortFieldMap.put('Stocks', 'ASC');
        
        VendorOrderHeader vendorOrderHeader = new VendorOrderHeader(voHeader.Id);
        
        List<Vendor_Order_Line_Item__c> voLineItemsRequiredForStock = SOQLUtil.getVOLineItem(vendor.Id, voHeader.Id, false);
       // system.assert(false,voLineItemsRequiredForStock);
        List<Vendor_Order_Line_Item__c> voLineItemsRequiredForCustomer = SOQLUtil.getVOLineItem(vendor.Id, voHeader.Id, true);
        //system.assert(false,voLineItemsRequiredForCustomer);
        List<Vendor_Order_Line_Item_Group__c> voliGroupLists = SOQLUtil.getVOLIGroupsWithItemsInVO('Part__r.Vendor__c', vendor.Id, voHeader.Id);
       // system.assert(false,voliGroupLists);
        
        VendorOrderLineItemWrapper vendorOrderLineItemWrapperObj = new VendorOrderLineItemWrapper(voLineItemsRequiredForStock,
        voLineItemsRequiredForCustomer, voliGroupLists, paginationSorting,
        paginationSorting, paginationSorting,
        listsSortFieldMap, vendorOrderHeader, null, 
        POTypeList, voliGroupLists);
        System.assertEquals(vendorOrderLineItemWrapperObj.TotalLineItemGroups,voliGroupLists.size());
    }
}