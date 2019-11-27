@isTest
private with sharing class VOLIUpdateOnUpdatingCOLITest {
	
													/************* Non-Pakaged part (VO Unsubmitted)   **************/
	/** Pass **/
    static testMethod void coliRemovedWhenVOUnsubmitted() {
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};

        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
		 
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	
    	insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 10);
        
        insert new List<SObject>{coHeader, part};
        List<Part__c> partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c where Id =: part.Id]; 
        
        system.assertEquals(1, partList.size());
        system.assertEquals(0, partList[0].Qty_On_Order__c);
        system.assertEquals(0, partList[0].Vendor_Order_Line_Items__r.size());
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 15);
        
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, Vendor.Id);
        voHeader.Status__c = 'Open';
        insert new List<SObject>{coLineItem, voHeader};
        
        List<Vendor_Order_Line_Item__c> voliList = [Select Id, Qty_Needed__c, Received__c, Qty_Ordered__c , Is_required_For_Customer__c, CO_Line_Item__c, CO_Header__c, Needed_For__c, Part__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Item__c];
        system.assertEquals(1, voliList.size());
        system.assertEquals(part.Id, voliList[0].Part__c);
        //system.assertEquals(5, voliList[0].Part__r.Qty_On_Order__c);
        system.assertEquals(5, voliList[0].Qty_Needed__c);
        system.assertEquals(true, (voliList[0].Received__c == null) && (voliList[0].Qty_Ordered__c == null) && voliList[0].Is_required_For_Customer__c);
        system.assertEquals(true, (voliList[0].CO_Line_Item__c == coLineItem.Id) && (voliList[0].CO_Header__c == coHeader.Id));
        
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(5, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(100, voLineItems.VendorOrderLineItemGroupList[0].Total);
        
        system.assertEquals('Open', voLineItems.VendorOrderHeader.Status);
        
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
        system.assertEquals(5, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Need);
        system.assertEquals(100, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Total);
        system.assertEquals(true, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].IsRequiredForCustomer);
        system.assertEquals(voliList[0].Id, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Id);
        
        delete coLineItem;
        partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(0, partList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(0, partList[0].Qty_On_Order__c);
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(0, voligList.size());
	 }
	 
	 /** Pass **/
	 static testMethod void twoColiRemovedWhenVOUnsubmitted() {
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};

        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
		 
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	
    	insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 10);
        
        insert new List<SObject>{coHeader, part};
        List<Part__c> partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c where Id =: part.Id]; 
        
        system.assertEquals(1, partList.size());
        system.assertEquals(0, partList[0].Qty_On_Order__c);
        system.assertEquals(0, partList[0].Vendor_Order_Line_Items__r.size());
        
        CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 15);
        CO_Line_Item__c coLineItem2 = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 15);
        
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, Vendor.Id);
        voHeader.Status__c = 'Open';
        insert new List<SObject>{coLineItem2, voHeader};
        
        List<Vendor_Order_Line_Item__c> voliList = [Select Id, Qty_Needed__c, Received__c, Qty_Ordered__c , Is_required_For_Customer__c, CO_Line_Item__c, CO_Header__c, Needed_For__c, Part__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Item__c Order By CreatedDate];
        /*system.assertEquals(1, voliList.size());
        system.assertEquals(part.Id, voliList[0].Part__c);
        //system.assertEquals(5, voliList[0].Part__r.Qty_On_Order__c);
        system.assertEquals(5, voliList[0].Qty_Needed__c);
        system.assertEquals(true, (voliList[0].Received__c == null) && (voliList[0].Qty_Ordered__c == null) && voliList[0].Is_required_For_Customer__c);
        system.assertEquals(true, (voliList[0].CO_Line_Item__c == coLineItem.Id) && (voliList[0].CO_Header__c == coHeader.Id));*/
        
        system.assertEquals(2, voliList.size());
        system.assertEquals(part.Id, voliList[0].Part__c);
        //system.assertEquals(20, voliList[0].Part__r.Qty_On_Order__c);
        system.assertEquals(5, voliList[0].Qty_Needed__c);
        system.assertEquals(15, voliList[1].Qty_Needed__c);
        system.assertEquals(true, (voliList[0].CO_Line_Item__c == coLineItem1.Id) && (voliList[0].CO_Header__c == coHeader.Id) &&
        			(voliList[1].CO_Line_Item__c == coLineItem2.Id) && (voliList[1].CO_Header__c == coHeader.Id));
        Test.startTest();
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id, voliList[1].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        Test.stopTest();
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(20, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(400, voLineItems.VendorOrderLineItemGroupList[0].Total);
        
        system.assertEquals('Open', voLineItems.VendorOrderHeader.Status);
        
        system.assertEquals(2, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
        system.assertEquals(5, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Need);
        system.assertEquals(15, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[1].Need);
        system.assertEquals(100, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Total);
        system.assertEquals(300, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[1].Total);
        system.assertEquals(true, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].IsRequiredForCustomer 
        							&& voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[1].IsRequiredForCustomer);
        
        delete coLineItem1;
        partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(1, partList[0].Vendor_Order_Line_Items__r.size());
        //system.assertEquals(15, partList[0].Qty_On_Order__c);
        
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Header__r.Total__c, (Select Id, CO_Line_Item__c, CO_Line_Item__r.Qty__c, Qty_Needed__c, Is_required_For_Customer__c from Vendor_Order_Line_Items__r) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(15, voligList[0].Need__c);
        system.assertEquals(300, voligList[0].Total__c);
        
        system.assertEquals('Open', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(300, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(1, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(voliList[1].Id, voligList[0].Vendor_Order_Line_Items__r[0].Id);
        system.assertEquals(15, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__r.Qty__c);
        system.assertEquals(coLineItem2.Id, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c);
        system.assertEquals(15, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(true, voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c);
        
        delete coLineItem2;
        partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(0, partList[0].Vendor_Order_Line_Items__r.size());
        //system.assertEquals(0, partList[0].Qty_On_Order__c);
        
        voligList = [Select Id from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(0, voligList.size());
	 }
	 
	 /** Pass **/
	 static testMethod void coliQtyDecreasedToDeleteVOLIWhenVOUnsubmitted() {
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};

        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
		 
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	
    	insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part 1', testCategory.Id, 10, 20, 50, 100, 10);
        
        insert new List<SObject>{coHeader, part};
        List<Vendor_Order_Line_Item__c> voliList = [Select Id from Vendor_Order_Line_Item__c LIMIT 1];
        
        system.assertEquals(0, voliList.size());
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 15);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, Vendor.Id);
        voHeader.Status__c = 'Open';
        insert new List<SObject>{coLineItem, voHeader};
        
        voliList = [Select Id, Qty_Needed__c, Received__c, Qty_Ordered__c , Is_required_For_Customer__c, CO_Line_Item__c, CO_Header__c, Needed_For__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Item__c];
        system.assertEquals(1, voliList.size());
        system.assertEquals(5, voliList[0].Qty_Needed__c);
        //system.assertEquals(5, voliList[0].Part__r.Qty_On_Order__c);
        system.assertEquals(true, (voliList[0].Received__c == null) && (voliList[0].Qty_Ordered__c == null) && voliList[0].Is_required_For_Customer__c);
        system.assertEquals(true, (voliList[0].CO_Line_Item__c == coLineItem.Id) && (voliList[0].CO_Header__c == coHeader.Id));
        
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(5, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(100, voLineItems.VendorOrderLineItemGroupList[0].Total);
        
        system.assertEquals('Open', voLineItems.VendorOrderHeader.Status);
        
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
        system.assertEquals(5, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Need);
        system.assertEquals(100, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Total);
        system.assertEquals(true, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].IsRequiredForCustomer);
        
        update new CO_Line_Item__c(Id = coLineItem.Id, Qty__c = 9);
        
        List<Part__c> partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(0, partList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(0, partList[0].Qty_On_Order__c);
        
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, (Select Id from Vendor_Order_Line_Items__r) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(0, voligList.size());
	 }
	 
	 /** Pass **/
	 static testMethod void coliQtyDecreasedIncreasedAndDeleteWhenVOUnsubmitted() {
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};

        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
		 
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	
    	insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part 1', testCategory.Id, 10, 20, 50, 100, 10);
        
        insert new List<SObject>{coHeader, part};
        List<Vendor_Order_Line_Item__c> voliList = [Select Id from Vendor_Order_Line_Item__c LIMIT 1];
        
        system.assertEquals(0, voliList.size());
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 15);
        
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, Vendor.Id);
        voHeader.Status__c = 'Open';
        insert new List<SObject>{coLineItem, voHeader};
        
        voliList = [Select Id, Qty_Needed__c, Received__c, Qty_Ordered__c , Is_required_For_Customer__c, CO_Line_Item__c, CO_Header__c, Needed_For__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Item__c];
        system.assertEquals(1, voliList.size());
        system.assertEquals(5, voliList[0].Qty_Needed__c);
        //system.assertEquals(5, voliList[0].Part__r.Qty_On_Order__c);
        system.assertEquals(true, (voliList[0].Received__c == null) && (voliList[0].Qty_Ordered__c == null) && voliList[0].Is_required_For_Customer__c);
        system.assertEquals(true, (voliList[0].CO_Line_Item__c == coLineItem.Id) && (voliList[0].CO_Header__c == coHeader.Id));
        
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(5, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(100, voLineItems.VendorOrderLineItemGroupList[0].Total);
        
        system.assertEquals('Open', voLineItems.VendorOrderHeader.Status);
        
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
        system.assertEquals(5, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Need);
        system.assertEquals(100, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Total);
        system.assertEquals(true, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].IsRequiredForCustomer);
        
        //COLineItemTriggerHelper.isAssertShown = true;
        update new CO_Line_Item__c(Id = coLineItem.Id, Qty__c = 12);
        
        List<Part__c> partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(1, partList[0].Vendor_Order_Line_Items__r.size());
        //system.assertEquals(2, partList[0].Qty_On_Order__c);
        
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Header__r.Total__c, (Select Id, CO_Line_Item__c, CO_Line_Item__r.Qty__c, Qty_Needed__c, Is_required_For_Customer__c from Vendor_Order_Line_Items__r) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(2, voligList[0].Need__c);
        system.assertEquals(40, voligList[0].Total__c);
        
        system.assertEquals('Open', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(40, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(1, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(voliList[0].Id, voligList[0].Vendor_Order_Line_Items__r[0].Id);
        system.assertEquals(12, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__r.Qty__c);
        system.assertEquals(coLineItem.Id, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c);
        system.assertEquals(2, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(true, voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c);
        
        Test.startTest();
        //COLineItemTriggerHelper.isAssertShown = true;
        update new CO_Line_Item__c(Id = coLineItem.Id, Qty__c = 14);
        
        partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(1, partList[0].Vendor_Order_Line_Items__r.size());
        //system.assertEquals(4, partList[0].Qty_On_Order__c);
        
        voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Header__r.Total__c, (Select Id, CO_Line_Item__c, CO_Line_Item__r.Qty__c, Qty_Needed__c, Is_required_For_Customer__c from Vendor_Order_Line_Items__r) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(4, voligList[0].Need__c);
        system.assertEquals(80, voligList[0].Total__c);
        
        system.assertEquals('Open', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(80, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(1, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(voliList[0].Id, voligList[0].Vendor_Order_Line_Items__r[0].Id);
        system.assertEquals(14, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__r.Qty__c);
        system.assertEquals(coLineItem.Id, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c);
        system.assertEquals(4, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(true, voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c);
        
        delete coLineItem; 
        partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(0, partList[0].Vendor_Order_Line_Items__r.size());
        //system.assertEquals(0, partList[0].Qty_On_Order__c);
        voligList = [Select Id from Vendor_Order_Line_Item_Group__c];
        Test.stopTest();
        system.assertEquals(0, voligList.size());
	 }
	 												/************* Non-Pakaged part (VO Submitted)   **************/
	 /** Pass **/
	 static testMethod void coliRemovedWhenVOSubmitted() {
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};
 
        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
		 
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	
    	insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 10);
        
        insert new List<SObject>{coHeader, part};
        List<Vendor_Order_Line_Item__c> voliList = [Select Id from Vendor_Order_Line_Item__c LIMIT 1];
        system.assertEquals(0, voliList.size());
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 15);
        
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, Vendor.Id);
        voHeader.Status__c = 'Open';
        insert new List<SObject>{coLineItem, voHeader};
        
        voliList = [Select Id, Qty_Needed__c, Received__c, Total_Cost__c, Qty_Ordered__c , Is_required_For_Customer__c, CO_Line_Item__c, CO_Header__c, Needed_For__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Item__c];
        system.assertEquals(1, voliList.size());
        system.assertEquals(5, voliList[0].Qty_Needed__c);
        system.assertEquals(100, voliList[0].Total_Cost__c);
        system.assertEquals(true, (voliList[0].Received__c == null) && (voliList[0].Qty_Ordered__c == null) && voliList[0].Is_required_For_Customer__c);
        system.assertEquals(true, (voliList[0].CO_Line_Item__c == coLineItem.Id) && (voliList[0].CO_Header__c == coHeader.Id));
        
        //system.assertEquals(5, voliList[0].Part__r.Qty_On_Order__c);
        
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
       	VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(5, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(100, voLineItems.VendorOrderLineItemGroupList[0].Total);
        
        system.assertEquals('On Order', voLineItems.VendorOrderHeader.Status);
        
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
        system.assertEquals(5, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Need);
        system.assertEquals(voliList[0].Id, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Id);
        
        
        delete coLineItem;
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Total__c, Vendor_Order_Header__r.Status__c, (Select Id, CO_Line_Item__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Items__r) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(5, voligList[0].Need__c);
        system.assertEquals(100, voligList[0].Total__c);
        
		system.assertEquals('On Order', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(100, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(1, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(null, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c);
        system.assertEquals(5, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(true, !voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && (voligList[0].Vendor_Order_Line_Items__r[0].Needed_For__c == 'STOCK'));
	 	
	 	//system.assertEquals(5, voligList[0].Part__r.Qty_On_Order__c);
	 }
	 
	 static testMethod void coliQtyDecreasedVOLIWhenVOSubmitted() {
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};

        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
		 
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	
    	insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 10);
        
        insert new List<SObject>{coHeader, part};
        List<Vendor_Order_Line_Item__c> voliList = [Select Id from Vendor_Order_Line_Item__c];
        
        system.assertEquals(0, voliList.size());
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 15);
        
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, Vendor.Id);
        voHeader.Status__c = 'Open';
        insert new List<SObject>{coLineItem, voHeader};
        
        voliList = [Select Id, Qty_Needed__c, Received__c, Qty_Ordered__c, Total_Cost__c, Is_required_For_Customer__c, CO_Line_Item__c, CO_Header__c, Needed_For__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Item__c];
        system.assertEquals(1, voliList.size());
        system.assertEquals(5, voliList[0].Qty_Needed__c);
        system.assertEquals(100, voliList[0].Total_Cost__c);
        system.assertEquals(true, (voliList[0].Received__c == null) && (voliList[0].Qty_Ordered__c == null) && voliList[0].Is_required_For_Customer__c);
        system.assertEquals(true, (voliList[0].CO_Line_Item__c == coLineItem.Id) && (voliList[0].CO_Header__c == coHeader.Id));

        //system.assertEquals(5, voliList[0].Part__r.Qty_On_Order__c);
        
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
       	VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(5, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(100, voLineItems.VendorOrderLineItemGroupList[0].Total);
        
        system.assertEquals('On Order', voLineItems.VendorOrderHeader.Status);
        
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
        system.assertEquals(5, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Need);
        system.assertEquals(voliList[0].Id, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Id);
        
        update new CO_Line_Item__c(Id = coLineItem.Id, Qty__c = 14);
        Test.startTest();
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Total__c, Vendor_Order_Header__r.Status__c, (Select Id, CO_Line_Item__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Items__r Order By CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(5, voligList[0].Need__c);
        system.assertEquals(100, voligList[0].Total__c);
        
		system.assertEquals('On Order', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(100, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(2, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(coLineItem.Id, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c);
        system.assertEquals(null, voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c);
        system.assertEquals(4, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(1, voligList[0].Vendor_Order_Line_Items__r[1].Qty_Needed__c);
        system.assertEquals(true, voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c
        		&&  (voligList[0].Vendor_Order_Line_Items__r[1].Needed_For__c == 'STOCK'));
        		
	 	//system.assertEquals(5, voligList[0].Part__r.Qty_On_Order__c);
        
        update new CO_Line_Item__c(Id = coLineItem.Id, Qty__c = 12);
        
        voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Total__c, Vendor_Order_Header__r.Status__c, (Select Id, CO_Line_Item__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Items__r Order By CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(5, voligList[0].Need__c);
        system.assertEquals(100, voligList[0].Total__c);
        
		system.assertEquals('On Order', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(100, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(2, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(coLineItem.Id, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c);
        system.assertEquals(null, voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c);
        system.assertEquals(2, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(3, voligList[0].Vendor_Order_Line_Items__r[1].Qty_Needed__c);
        system.assertEquals(true, voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c
        		&&  (voligList[0].Vendor_Order_Line_Items__r[1].Needed_For__c == 'STOCK'));
        		
	 	//system.assertEquals(5, voligList[0].Part__r.Qty_On_Order__c);
	 	
	 	update new CO_Line_Item__c(Id = coLineItem.Id, Qty__c = 9);
	 	
	 	voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Total__c, Vendor_Order_Header__r.Status__c, (Select Id, CO_Line_Item__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Items__r Order By CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(5, voligList[0].Need__c);
        system.assertEquals(100, voligList[0].Total__c);
        
		system.assertEquals('On Order', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(100, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(2, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(null, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c);
        system.assertEquals(null, voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c);
        system.assertEquals(2, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(3, voligList[0].Vendor_Order_Line_Items__r[1].Qty_Needed__c);
        system.assertEquals(true, !voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c
        		&& (voligList[0].Vendor_Order_Line_Items__r[0].Needed_For__c == 'STOCK') && (voligList[0].Vendor_Order_Line_Items__r[1].Needed_For__c == 'STOCK'));
        		
	 	//system.assertEquals(5, voligList[0].Part__r.Qty_On_Order__c);
	 	Test.stopTest();
	 }
	 
	 /** Pass **/
	 static testMethod void coliQtyDecreasedTORemoveSpecialOrderVOLIWhenVOSubmitted() {
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};

        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
		 
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	
    	insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 10);
        
        insert new List<SObject>{coHeader, part};
        List<Vendor_Order_Line_Item__c> voliList = [Select Id from Vendor_Order_Line_Item__c];
        
        system.assertEquals(0, voliList.size());
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 15);
        
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, Vendor.Id);
        voHeader.Status__c = 'Open';
        insert new List<SObject>{coLineItem, voHeader};
        
        voliList = [Select Id, Qty_Needed__c, Received__c, Qty_Ordered__c, Total_Cost__c, Is_required_For_Customer__c, CO_Line_Item__c, CO_Header__c, Needed_For__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Item__c];
        system.assertEquals(1, voliList.size());
        system.assertEquals(5, voliList[0].Qty_Needed__c);
        system.assertEquals(100, voliList[0].Total_Cost__c);
        system.assertEquals(true, (voliList[0].Received__c == null) && (voliList[0].Qty_Ordered__c == null) && voliList[0].Is_required_For_Customer__c);
        system.assertEquals(true, (voliList[0].CO_Line_Item__c == coLineItem.Id) && (voliList[0].CO_Header__c == coHeader.Id));

        //system.assertEquals(5, voliList[0].Part__r.Qty_On_Order__c);
        
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
       	VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(5, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(100, voLineItems.VendorOrderLineItemGroupList[0].Total);
        
        system.assertEquals('On Order', voLineItems.VendorOrderHeader.Status);
        
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
        system.assertEquals(5, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Need);
        system.assertEquals(voliList[0].Id, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Id);
        
        update new CO_Line_Item__c(Id = coLineItem.Id, Qty__c = 9);
        
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Total__c, Vendor_Order_Header__r.Status__c, (Select Id, CO_Line_Item__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Items__r) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(5, voligList[0].Need__c);
        system.assertEquals(100, voligList[0].Total__c);
        
		system.assertEquals('On Order', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(100, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(1, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(null, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c);
        system.assertEquals(5, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(true, !voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && (voligList[0].Vendor_Order_Line_Items__r[0].Needed_For__c == 'STOCK'));
        
	 	//system.assertEquals(5, voligList[0].Part__r.Qty_On_Order__c);
	 }
	 													/************* Pakaged part (VO Unsubmitted) **************/
	 /** Pass **/
	 static testMethod void coliRemovedWhenVOUnsubmitted_PkgPart() {
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};

        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
		 
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	
    	insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = true ;
        part.Package_Qty__c = 10;
        part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 50;
        part.Order_Lots__c = 2;
        //part.Qty_On_Order__c = 0;
        
        insert new List<SObject>{coHeader, part};
        List<Part__c> partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c where Id =: part.Id]; 
        
        system.assertEquals(1, partList.size());
        system.assertEquals(0, partList[0].Qty_On_Order__c);
        system.assertEquals(0, partList[0].Vendor_Order_Line_Items__r.size());
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
        String voWrapperJSON = BPUtility.getDecodedString(VendorOrderCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voWrapper = (VendorOrderLineItemWrapper) System.JSON.deserialize(voWrapperJSON, VendorOrderLineItemWrapper.class);
        
        List<Vendor_Order_Line_Item__c> voliList = [Select Id, Qty_Needed__c, Received__c, Qty_Ordered__c , Is_required_For_Customer__c, CO_Line_Item__c, CO_Header__c, Needed_For__c, Part__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Item__c Order By Is_required_For_Customer__c];
        system.assertEquals(2, voliList.size());
        system.assertEquals(part.Id, voliList[0].Part__c);
        system.assertEquals(part.Id, voliList[1].Part__c);
        //system.assertEquals(100, voliList[0].Part__r.Qty_On_Order__c);
		system.assertEquals(50, voliList[0].Qty_Needed__c);
		system.assertEquals(50, voliList[0].Qty_Needed__c);
		system.assertEquals(true, (voliList[0].CO_Line_Item__c == null) && (voliList[0].CO_Header__c == null));
		system.assertEquals(true, (voliList[1].CO_Line_Item__c == coLineItem.Id) && (voliList[1].CO_Header__c == coHeader.Id));
        Test.startTest();
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id, voliList[1].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voWrapper.VendorOrderHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(100, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(2000, voLineItems.VendorOrderLineItemGroupList[0].Total);
        
        system.assertEquals('Open', voLineItems.VendorOrderHeader.Status); 
        
        system.assertEquals(2, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
        system.assertEquals(50, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Need);
        system.assertEquals(50, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[1].Need);
        /*
        update new Part__c(Auto_reorder_Max__c = 100, Id = part.Id);
        
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Header__r.Total__c, Part__r.Auto_reorder_Max__c, (Select Id, CO_Line_Item__c, CO_Line_Item__r.Qty__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c from Vendor_Order_Line_Items__r Order By Needed_For__c, CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(160, voligList[0].Need__c);
        system.assertEquals(3200, voligList[0].Total__c);
        
        //system.assertEquals(150, voligList[0].Vendor_Order_Line_Items__r[0].Part__r.Qty_On_Order__c);
        
        system.assertEquals('Open', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(3200, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(2, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(150, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
		system.assertEquals(10, voligList[0].Vendor_Order_Line_Items__r[1].Qty_Needed__c);
        system.assertEquals(150, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__r.Qty__c);
        system.assertEquals(true, voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c
        				&& !voligList[0].Vendor_Order_Line_Items__r[0].Is_Excess__c && voligList[0].Vendor_Order_Line_Items__r[1].Is_Excess__c);
		system.assertEquals(true, (voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c == null) && (voligList[0].Vendor_Order_Line_Items__r[1].CO_Header__c == null));
		system.assertEquals(true, (voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c == coLineItem.Id) && (voligList[0].Vendor_Order_Line_Items__r[0].CO_Header__c == coHeader.Id));
		*/
        delete coLineItem;
        partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(2, partList[0].Vendor_Order_Line_Items__r.size());
        //system.assertEquals(60, partList[0].Qty_On_Order__c);
        
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Header__r.Total__c, 
        				Part__r.Auto_reorder_Max__c, (Select Id, CO_Line_Item__c, CO_Line_Item__r.Qty__c, Qty_Needed__c, Is_required_For_Customer__c, Is_Excess__c, CO_Header__c,
        				Needed_For__c from Vendor_Order_Line_Items__r Order By Needed_For__c, CreatedDate) from Vendor_Order_Line_Item_Group__c];
        Test.stopTest();
        system.assertEquals(1, voligList.size());
        system.assertEquals(60, voligList[0].Need__c);
        system.assertEquals(1200, voligList[0].Total__c);
        
        //system.assertEquals(60, voligList[0].Vendor_Order_Line_Items__r[0].Part__r.Qty_On_Order__c);
        
        system.assertEquals('Open', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(1200, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(2, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(50, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
		system.assertEquals(10, voligList[0].Vendor_Order_Line_Items__r[1].Qty_Needed__c);
        system.assertEquals(true, !voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c
        				&& !voligList[0].Vendor_Order_Line_Items__r[0].Is_Excess__c && voligList[0].Vendor_Order_Line_Items__r[1].Is_Excess__c);
		system.assertEquals(true, (voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c == null) && (voligList[0].Vendor_Order_Line_Items__r[1].CO_Header__c == null));
		system.assertEquals(true, (voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c == null) && (voligList[0].Vendor_Order_Line_Items__r[0].CO_Header__c == null));
	 }
	 
	 static testMethod void twoColiRemovedWhenVOUnsubmitted_PkgPart() {
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};

        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
		 
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	
    	insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
    	
    	Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = true ;
        part.Package_Qty__c = 10;
        part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 2;
        //part.Qty_On_Order__c = 0;
        
        insert new List<SObject>{coHeader, part};
        List<Part__c> partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c where Id =: part.Id]; 
        
        system.assertEquals(1, partList.size());
        system.assertEquals(0, partList[0].Qty_On_Order__c);
        system.assertEquals(0, partList[0].Vendor_Order_Line_Items__r.size());
        
        CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        CO_Line_Item__c coLineItem2 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
        String voWrapperJSON = BPUtility.getDecodedString(VendorOrderCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voWrapper = (VendorOrderLineItemWrapper) System.JSON.deserialize(voWrapperJSON, VendorOrderLineItemWrapper.class);
        /*
        List<Vendor_Order_Line_Item__c> voliList = [Select Id, Qty_Needed__c, Received__c, Qty_Ordered__c , Is_required_For_Customer__c, CO_Line_Item__c, CO_Header__c, Needed_For__c, Part__c, Part__r.Qty_On_Order__c, CreatedDate from Vendor_Order_Line_Item__c Order By Needed_For__c, CreatedDate];
        system.assertEquals(3, voliList.size());
        system.assertEquals(true, (voliList[0].Part__c == part.Id) && (voliList[1].Part__c == part.Id) && (voliList[2].Part__c == part.Id));
        system.assertEquals(true, (voliList[0].Qty_Needed__c == 50) && (voliList[1].Qty_Needed__c == 150) && (voliList[2].Qty_Needed__c == 200));
        //system.assertEquals(400, voliList[0].Part__r.Qty_On_Order__c);
        system.assertEquals(true, (voliList[0].CO_Line_Item__c == coLineItem1.Id) && (voliList[0].CO_Header__c == coHeader.Id));
        system.assertEquals(true, (voliList[1].CO_Line_Item__c == coLineItem2.Id) && (voliList[1].CO_Header__c == coHeader.Id));
		system.assertEquals(true, (voliList[2].CO_Line_Item__c == null) && (voliList[2].CO_Header__c == null));
    	
    	Test.startTest();
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[2].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voWrapper.VendorOrderHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(200, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(4000, voLineItems.VendorOrderLineItemGroupList[0].Total);
         
        system.assertEquals('Open', voLineItems.VendorOrderHeader.Status);
        
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
		system.assertEquals(200, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Need);
		system.assertEquals(4000, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList[0].Total);
        
        similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id, voliList[1].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voWrapper.VendorOrderHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(400, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(8000, voLineItems.VendorOrderLineItemGroupList[0].Total);
        
        system.assertEquals('Open', voLineItems.VendorOrderHeader.Status);
        
        system.assertEquals(3, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
        for(VendorOrderLineItem voliObj : voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList) {
        	if(!voliObj.IsRequiredForCustomer && !voliObj.IsExcess) {
        		system.assertEquals(200, voliObj.Need);
        		system.assertEquals(4000, voliObj.Total);
        	}
        }
        
        delete coLineItem1;*/
        /*
        partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(3, partList[0].Vendor_Order_Line_Items__r.size());
        //system.assertEquals(350, partList[0].Qty_On_Order__c);
        
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Header__r.Total__c, (Select Id, CO_Line_Item__c, CO_Line_Item__r.Qty__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c from Vendor_Order_Line_Items__r Order By Needed_For__c, CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(360, voligList[0].Need__c);
        system.assertEquals(7200, voligList[0].Total__c);
        
        system.assertEquals('Open', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(7200, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(3, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(150, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__r.Qty__c);
        system.assertEquals(coLineItem2.Id, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c);
        system.assertEquals(true, (voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c == null) && (voligList[0].Vendor_Order_Line_Items__r[2].CO_Line_Item__c== null));
        system.assertEquals(150, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(200, voligList[0].Vendor_Order_Line_Items__r[1].Qty_Needed__c);
        system.assertEquals(10, voligList[0].Vendor_Order_Line_Items__r[2].Qty_Needed__c);
        system.assertEquals(true, voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c
        				&& !voligList[0].Vendor_Order_Line_Items__r[2].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[0].Is_Excess__c
        				&& !voligList[0].Vendor_Order_Line_Items__r[1].Is_Excess__c && voligList[0].Vendor_Order_Line_Items__r[2].Is_Excess__c);
        */
        
        /*partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(3, partList[0].Vendor_Order_Line_Items__r.size());
        //system.assertEquals(360, partList[0].Qty_On_Order__c);
        
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Header__r.Total__c, (Select Id, CO_Line_Item__c, CO_Line_Item__r.Qty__c, Qty_Needed__c, Is_required_For_Customer__c, Is_Excess__c, Needed_For__c from Vendor_Order_Line_Items__r Order By Needed_For__c, CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(360, voligList[0].Need__c);
        system.assertEquals(7200, voligList[0].Total__c);
        
        system.assertEquals('Open', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(7200, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(3, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(150, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__r.Qty__c);
        system.assertEquals(150, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(200, voligList[0].Vendor_Order_Line_Items__r[1].Qty_Needed__c);
        system.assertEquals(10, voligList[0].Vendor_Order_Line_Items__r[2].Qty_Needed__c);
        system.assertEquals(coLineItem2.Id, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c);
        system.assertEquals(true, (voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c == null) && (voligList[0].Vendor_Order_Line_Items__r[2].CO_Line_Item__c == null));
        system.assertEquals(true, voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c
        				&& !voligList[0].Vendor_Order_Line_Items__r[2].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[0].Is_Excess__c
        				&& !voligList[0].Vendor_Order_Line_Items__r[1].Is_Excess__c && voligList[0].Vendor_Order_Line_Items__r[2].Is_Excess__c);
        
        delete coLineItem2; 
        partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(1, partList[0].Vendor_Order_Line_Items__r.size());
        //system.assertEquals(200, partList[0].Qty_On_Order__c);
        
        voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Header__r.Total__c, (Select Id, CO_Line_Item__c, Is_Excess__c, CO_Line_Item__r.Qty__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c from Vendor_Order_Line_Items__r Order By Needed_For__c, CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(200, voligList[0].Need__c);
        system.assertEquals(4000, voligList[0].Total__c);
        
        system.assertEquals('Open', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(4000, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(1, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(200, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(null, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c);
        system.assertEquals(true, !voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[0].Is_Excess__c);
        
        Test.stopTest();*/
	 }
	 
	 static testMethod void coliQtyDecreasedToDeleteVOLIWhenVOUnsubmitted_PkgPart() {
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};

        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
		 
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	
    	insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = true ;
        part.Package_Qty__c = 10;
        part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 2;
        //part.Qty_On_Order__c = 0;
        
        insert new List<SObject>{coHeader, part};
        List<Part__c> partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c where Id =: part.Id]; 
        
        system.assertEquals(1, partList.size());
        system.assertEquals(0, partList[0].Qty_On_Order__c);
        system.assertEquals(0, partList[0].Vendor_Order_Line_Items__r.size());
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
        String voWrapperJSON = BPUtility.getDecodedString(VendorOrderCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voWrapper = (VendorOrderLineItemWrapper) System.JSON.deserialize(voWrapperJSON, VendorOrderLineItemWrapper.class);
        
        List<Vendor_Order_Line_Item__c> voliList = [Select Id, Qty_Needed__c, Received__c, Qty_Ordered__c , Is_required_For_Customer__c, CO_Line_Item__c, CO_Header__c, Needed_For__c, Part__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Item__c Order By Needed_For__c, CreatedDate];
        system.assertEquals(2, voliList.size());
        system.assertEquals(true, (voliList[0].Part__c == part.Id) && (voliList[1].Part__c == part.Id));
        system.assertEquals(true, (voliList[0].Qty_Needed__c == 50) && (voliList[1].Qty_Needed__c == 200));
        //system.assertEquals(250, voliList[0].Part__r.Qty_On_Order__c);
        system.assertEquals(true, (voliList[0].CO_Line_Item__c == coLineItem.Id) && (voliList[0].CO_Header__c == coHeader.Id));
        system.assertEquals(true, (voliList[1].CO_Line_Item__c == null) && (voliList[1].CO_Header__c == null));
        system.assertEquals(true, voliList[0].Is_required_For_Customer__c && !voliList[1].Is_required_For_Customer__c);
        
        Test.startTest();
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id, voliList[1].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voWrapper.VendorOrderHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(260, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(5200, voLineItems.VendorOrderLineItemGroupList[0].Total);
        
        system.assertEquals('Open', voLineItems.VendorOrderHeader.Status);
        
        system.assertEquals(3, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
        for(VendorOrderLineItem voliObj : voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList) {
        	if(voliObj.IsRequiredForCustomer) {
        		system.assertEquals(50, voliObj.Need);
        		system.assertEquals(1000, voliObj.Total);
        	} else if(!voliObj.IsExcess) {
        		system.assertEquals(200, voliObj.Need);
        		system.assertEquals(4000, voliObj.Total);
        	} else {
        		system.assertEquals(10, voliObj.Need);
        	}
        }
        
        update new CO_Line_Item__c(Id = coLineItem.Id, Qty__c = 90);
        
        partList = [Select Id, Qty_On_Order__c, (Select Id, Qty_Needed__c from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(1, partList[0].Vendor_Order_Line_Items__r.size());
        //system.assertEquals(200, partList[0].Qty_On_Order__c);
        
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Header__r.Total__c, (Select Id, Is_Excess__c, CO_Line_Item__c, CO_Line_Item__r.Qty__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c from Vendor_Order_Line_Items__r Order By Needed_For__c, CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(200, voligList[0].Need__c);
        system.assertEquals(4000, voligList[0].Total__c);
        
        system.assertEquals('Open', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(4000, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(1, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(true, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c == null);
        system.assertEquals(200, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(true, !voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[0].Is_Excess__c);
        
        Test.stopTest();
	 }
	 
	 static testMethod void coliQtyDecreasedIncreasedAndDeleteWhenVOUnsubmitted_PKGPart() {
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};

        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
		 
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	
    	insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = true ;
        part.Package_Qty__c = 10;
        part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 2;
        //part.Qty_On_Order__c = 0;
        
        insert new List<SObject>{coHeader, part};
        List<Part__c> partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c where Id =: part.Id]; 
        
        system.assertEquals(1, partList.size());
        system.assertEquals(0, partList[0].Qty_On_Order__c);
        system.assertEquals(0, partList[0].Vendor_Order_Line_Items__r.size());
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
        String voWrapperJSON = BPUtility.getDecodedString(VendorOrderCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voWrapper = (VendorOrderLineItemWrapper) System.JSON.deserialize(voWrapperJSON, VendorOrderLineItemWrapper.class);
        
        List<Vendor_Order_Line_Item__c> voliList = [Select Id, Qty_Needed__c, Received__c, Qty_Ordered__c , Is_required_For_Customer__c, CO_Line_Item__c, CO_Header__c, Needed_For__c, Part__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Item__c Order By Needed_For__c, CreatedDate];
        system.assertEquals(2, voliList.size());
        system.assertEquals(true, (voliList[0].Part__c == part.Id) && (voliList[1].Part__c == part.Id));
        system.assertEquals(true, (voliList[0].Qty_Needed__c == 50) && (voliList[1].Qty_Needed__c == 200));
        //system.assertEquals(250, voliList[0].Part__r.Qty_On_Order__c);
        system.assertEquals(true, (voliList[0].CO_Line_Item__c == coLineItem.Id) && (voliList[0].CO_Header__c == coHeader.Id));
        system.assertEquals(true, (voliList[1].CO_Line_Item__c == null) && (voliList[1].CO_Header__c == null));
        system.assertEquals(true, voliList[0].Is_required_For_Customer__c && !voliList[1].Is_required_For_Customer__c);
        
        Test.startTest();
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id, voliList[1].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voWrapper.VendorOrderHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(260, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(5200, voLineItems.VendorOrderLineItemGroupList[0].Total);
        
        system.assertEquals('Open', voLineItems.VendorOrderHeader.Status);
        
        system.assertEquals(3, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
        for(VendorOrderLineItem voliObj : voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList) {
        	if(voliObj.IsRequiredForCustomer) {
        		system.assertEquals(50, voliObj.Need);
        		system.assertEquals(1000, voliObj.Total);
        	} else if(!voliObj.IsExcess) {
        		system.assertEquals(200, voliObj.Need);
        		system.assertEquals(4000, voliObj.Total);
        	} else {
        		system.assertEquals(10, voliObj.Need);
        	}
        }
        
        //COLineItemTriggerHelper.isAssertShown = true;
        update new CO_Line_Item__c(Id = coLineItem.Id, Qty__c = 120);
        
        partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(2, partList[0].Vendor_Order_Line_Items__r.size());
        //system.assertEquals(320, partList[0].Qty_On_Order__c);
        
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Header__r.Total__c, (Select Id, CO_Line_Item__c, CO_Line_Item__r.Qty__c, Qty_Needed__c, Is_required_For_Customer__c, Is_Excess__c from Vendor_Order_Line_Items__r Order BY Needed_For__c, CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(220, voligList[0].Need__c);
        system.assertEquals(4400, voligList[0].Total__c);
        
        system.assertEquals('Open', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(4400, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(2, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(voliList[0].Id, voligList[0].Vendor_Order_Line_Items__r[0].Id);
        system.assertEquals(120, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__r.Qty__c);
        system.assertEquals(coLineItem.Id, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c);
        system.assertEquals(20, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(true, voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c);
        
        system.assertEquals(null, voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c);
        system.assertEquals(200, voligList[0].Vendor_Order_Line_Items__r[1].Qty_Needed__c);
        system.assertEquals(true, !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[1].Is_Excess__c);
        
        //COLineItemTriggerHelper.isAssertShown = true;
        update new CO_Line_Item__c(Id = coLineItem.Id, Qty__c = 140);
        
        partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(2, partList[0].Vendor_Order_Line_Items__r.size());
        //system.assertEquals(340, partList[0].Qty_On_Order__c);
        
        voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Header__r.Total__c, (Select Id, CO_Line_Item__c, CO_Line_Item__r.Qty__c, Qty_Needed__c, Is_required_For_Customer__c,Is_Excess__c from Vendor_Order_Line_Items__r Order By Needed_For__c, CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(240, voligList[0].Need__c);
        system.assertEquals(4800, voligList[0].Total__c);
        
        system.assertEquals('Open', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(4800, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(2, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(140, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__r.Qty__c);
        system.assertEquals(coLineItem.Id, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c);
        system.assertEquals(40, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(true, voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c);
        
        system.assertEquals(null, voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c);
        system.assertEquals(200, voligList[0].Vendor_Order_Line_Items__r[1].Qty_Needed__c);
        system.assertEquals(true, !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[1].Is_Excess__c);
        
        /**
        delete coLineItem; 
        partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c];
        system.assertEquals(1, partList[0].Vendor_Order_Line_Items__r.size());
        //system.assertEquals(200, partList[0].Qty_On_Order__c);
        voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Header__r.Total__c, (Select Id, CO_Line_Item__c, CO_Line_Item__r.Qty__c, Qty_Needed__c, Is_required_For_Customer__c,Is_Excess__c from Vendor_Order_Line_Items__r) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(200, voligList[0].Need__c);
        system.assertEquals(4000, voligList[0].Total__c);
        
        system.assertEquals('Open', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(4000, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(1, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(null, voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c);
        system.assertEquals(200, voligList[0].Vendor_Order_Line_Items__r[1].Qty_Needed__c);
        system.assertEquals(true, !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[1].Is_Excess__c);
        Test.stopTest();**/
	 }
	 											/************* Pakaged part (VO Submitted) **************/
	 											
	 static testMethod void coliRemovedWhenVOSubmitted_PKGPart() {
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};
 
        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
		 
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	
    	insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = true ;
        part.Package_Qty__c = 10;
        part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 2;
        //part.Qty_On_Order__c = 0;
        
        insert new List<SObject>{coHeader, part};
        List<Part__c> partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c where Id =: part.Id]; 
        
        system.assertEquals(1, partList.size());
        system.assertEquals(0, partList[0].Qty_On_Order__c);
        system.assertEquals(0, partList[0].Vendor_Order_Line_Items__r.size());
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
        String voWrapperJSON = BPUtility.getDecodedString(VendorOrderCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voWrapper = (VendorOrderLineItemWrapper) System.JSON.deserialize(voWrapperJSON, VendorOrderLineItemWrapper.class);
        
        List<Vendor_Order_Line_Item__c> voliList = [Select Id, Qty_Needed__c, Received__c, Qty_Ordered__c , Is_required_For_Customer__c, CO_Line_Item__c, CO_Header__c, Needed_For__c, Part__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Item__c Order By Needed_For__c, CreatedDate];
        system.assertEquals(2, voliList.size());
        system.assertEquals(true, (voliList[0].Part__c == part.Id) && (voliList[1].Part__c == part.Id));
        system.assertEquals(true, (voliList[0].Qty_Needed__c == 50) && (voliList[1].Qty_Needed__c == 200));
        //system.assertEquals(250, voliList[0].Part__r.Qty_On_Order__c);
        system.assertEquals(true, (voliList[0].CO_Line_Item__c == coLineItem.Id) && (voliList[0].CO_Header__c == coHeader.Id));
        system.assertEquals(true, (voliList[1].CO_Line_Item__c == null) && (voliList[1].CO_Header__c == null));
        system.assertEquals(true, voliList[0].Is_required_For_Customer__c && !voliList[1].Is_required_For_Customer__c);
        
        Test.startTest();
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id, voliList[1].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voWrapper.VendorOrderHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);				
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voWrapper.VendorOrderHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
       	voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(260, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(5200, voLineItems.VendorOrderLineItemGroupList[0].Total);
        
        system.assertEquals('On Order', voLineItems.VendorOrderHeader.Status);
        
        system.assertEquals(3, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
        for(VendorOrderLineItem voliObj : voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList) {
        	if(voliObj.IsRequiredForCustomer) {
        		system.assertEquals(50, voliObj.Need);
        		system.assertEquals(1000, voliObj.Total);
        	} else if(!voliObj.IsExcess) {
        		system.assertEquals(200, voliObj.Need);
        		system.assertEquals(4000, voliObj.Total);
        	} else {
        		system.assertEquals(10, voliObj.Need);
        	}
        }
        
        delete coLineItem;
        
        partList = [Select Id, Qty_On_Order__c, (Select Id, Needed_For__c, Qty_Needed__c, Is_Excess__c, Is_Required_For_Customer__c from Vendor_Order_Line_Items__r) from Part__c];
        //system.assertEquals(3, partList[0].Vendor_Order_Line_Items__r.size());
        //system.assertEquals(260, partList[0].Qty_On_Order__c);
        
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Total__c, Vendor_Order_Header__r.Status__c, (Select Id, CO_Line_Item__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c, Part__r.Qty_On_Order__c, Is_Excess__c from Vendor_Order_Line_Items__r Order By Needed_For__c, CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(260, voligList[0].Need__c);
        system.assertEquals(5200, voligList[0].Total__c);
        
		system.assertEquals('On Order', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(5200, voligList[0].Vendor_Order_Header__r.Total__c);
        /*
        system.assertEquals(2, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(true, (voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c == null) && (voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c == null));
        system.assertEquals(200, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(60, voligList[0].Vendor_Order_Line_Items__r[1].Qty_Needed__c);
        system.assertEquals(true, !voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c 
        					&& !voligList[0].Vendor_Order_Line_Items__r[0].Is_Excess__c && voligList[0].Vendor_Order_Line_Items__r[1].Is_Excess__c);
	 	*/
	 	//system.assertEquals(5, voligList[0].Part__r.Qty_On_Order__c);
	 	Test.stopTest();
	 }
	 
	 /**static testMethod void coliQtyDecreasedVOLIWhenVOSubmitted_PKGPart() {
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};

        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
		 
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	
    	insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = true ;
        part.Package_Qty__c = 10;
        part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 2;
        //part.Qty_On_Order__c = 0;
        
        insert new List<SObject>{coHeader, part};
        List<Part__c> partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c where Id =: part.Id]; 
        
        system.assertEquals(1, partList.size());
        system.assertEquals(0, partList[0].Qty_On_Order__c);
        system.assertEquals(0, partList[0].Vendor_Order_Line_Items__r.size());
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
        String voWrapperJSON = BPUtility.getDecodedString(VendorOrderCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voWrapper = (VendorOrderLineItemWrapper) System.JSON.deserialize(voWrapperJSON, VendorOrderLineItemWrapper.class);
        
        List<Vendor_Order_Line_Item__c> voliList = [Select Id, Qty_Needed__c, Received__c, Qty_Ordered__c , Is_required_For_Customer__c, CO_Line_Item__c, CO_Header__c, Needed_For__c, Part__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Item__c Order By Needed_For__c, CreatedDate];
        system.assertEquals(2, voliList.size());
        system.assertEquals(true, (voliList[0].Part__c == part.Id) && (voliList[1].Part__c == part.Id));
        system.assertEquals(true, (voliList[0].Qty_Needed__c == 50) && (voliList[1].Qty_Needed__c == 200));
        //system.assertEquals(250, voliList[0].Part__r.Qty_On_Order__c);
        system.assertEquals(true, (voliList[0].CO_Line_Item__c == coLineItem.Id) && (voliList[0].CO_Header__c == coHeader.Id));
        system.assertEquals(true, (voliList[1].CO_Line_Item__c == null) && (voliList[1].CO_Header__c == null));
        system.assertEquals(true, voliList[0].Is_required_For_Customer__c && !voliList[1].Is_required_For_Customer__c);
        
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id, voliList[1].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voWrapper.VendorOrderHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);				
        Test.startTest();
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voWrapper.VendorOrderHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
       	voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(260, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(5200, voLineItems.VendorOrderLineItemGroupList[0].Total);
        
        system.assertEquals('On Order', voLineItems.VendorOrderHeader.Status);
        
        system.assertEquals(3, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
        for(VendorOrderLineItem voliObj : voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList) {
        	if(voliObj.IsRequiredForCustomer) {
        		system.assertEquals(50, voliObj.Need);
        		system.assertEquals(1000, voliObj.Total);
        	} else if(!voliObj.IsExcess) {
        		system.assertEquals(200, voliObj.Need);
        		system.assertEquals(4000, voliObj.Total);
        	} else {
        		system.assertEquals(10, voliObj.Need);
        	}
        }

        update new CO_Line_Item__c(Id = coLineItem.Id, Qty__c = 140);
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Total__c, Vendor_Order_Header__r.Status__c, (Select Id, CO_Line_Item__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c, Part__r.Qty_On_Order__c, Is_Excess__c from Vendor_Order_Line_Items__r Order By Needed_For__c, Is_Excess__c ASC, CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(260, voligList[0].Need__c);
        system.assertEquals(5200, voligList[0].Total__c);
        
		system.assertEquals('On Order', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(5200, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(3, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(true, (voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c == coLineItem.Id) && (voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c == null) && (voligList[0].Vendor_Order_Line_Items__r[2].CO_Line_Item__c == null));
        system.assertEquals(40, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(200, voligList[0].Vendor_Order_Line_Items__r[1].Qty_Needed__c);
        system.assertEquals(20, voligList[0].Vendor_Order_Line_Items__r[2].Qty_Needed__c);
        system.assertEquals(true, voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c
        		&& !voligList[0].Vendor_Order_Line_Items__r[2].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[0].Is_Excess__c
        		&& !voligList[0].Vendor_Order_Line_Items__r[1].Is_Excess__c && voligList[0].Vendor_Order_Line_Items__r[2].Is_Excess__c);
        		
	 	//system.assertEquals(5, voligList[0].Part__r.Qty_On_Order__c);
        
        update new CO_Line_Item__c(Id = coLineItem.Id, Qty__c = 120);
        
        voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Total__c, Vendor_Order_Header__r.Status__c, (Select Id, Is_Excess__c, CO_Line_Item__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Items__r Order By Needed_For__c, CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(260, voligList[0].Need__c);
        system.assertEquals(5200, voligList[0].Total__c);
        
		system.assertEquals('On Order', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(5200, voligList[0].Vendor_Order_Header__r.Total__c);
        
        system.assertEquals(3, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(true, (voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c == coLineItem.Id) && (voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c == null) && (voligList[0].Vendor_Order_Line_Items__r[2].CO_Line_Item__c == null));
        system.assertEquals(20, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(200, voligList[0].Vendor_Order_Line_Items__r[1].Qty_Needed__c);
        system.assertEquals(40, voligList[0].Vendor_Order_Line_Items__r[2].Qty_Needed__c);
        system.assertEquals(true, voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c
        		&& !voligList[0].Vendor_Order_Line_Items__r[2].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[0].Is_Excess__c 
        		&& !voligList[0].Vendor_Order_Line_Items__r[1].Is_Excess__c && voligList[0].Vendor_Order_Line_Items__r[2].Is_Excess__c);
        		
	 	//system.assertEquals(5, voligList[0].Part__r.Qty_On_Order__c);
	 	
	 	update new CO_Line_Item__c(Id = coLineItem.Id, Qty__c = 90);
	 	Test.stopTest();
	 	voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Total__c, Vendor_Order_Header__r.Status__c, (Select Id, CO_Line_Item__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c, Part__r.Qty_On_Order__c, Is_Excess__c from Vendor_Order_Line_Items__r Order By Needed_For__c, CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(260, voligList[0].Need__c);
        system.assertEquals(5200, voligList[0].Total__c);
        
		system.assertEquals('On Order', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(5200, voligList[0].Vendor_Order_Header__r.Total__c);
        
        //system.assertEquals(2, voligList[0].Vendor_Order_Line_Items__r.size());
       // system.assertEquals(true, (voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c == null) && (voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c == null));
       // system.assertEquals(200, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        //system.assertEquals(60, voligList[0].Vendor_Order_Line_Items__r[1].Qty_Needed__c);
        //system.assertEquals(true, !voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[0].Is_Excess__c 
       // 					&& !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c && voligList[0].Vendor_Order_Line_Items__r[1].Is_Excess__c);
        
	 	//system.assertEquals(5, voligList[0].Part__r.Qty_On_Order__c);
	 	
	 }*/
	 
	 static testMethod void coliQtyDecreasedTORemoveSpecialOrderVOLIWhenVOSubmitted_PKGPart() {
     	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};

        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
		 
		Account vendor = TestUtil.createVendor(false, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	
    	insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
    	
    	CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = true ;
        part.Package_Qty__c = 10;
        part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 2;
        //part.Qty_On_Order__c = 0;
        
        insert new List<SObject>{coHeader, part};
        List<Part__c> partList = [Select Id, Qty_On_Order__c, (Select Id from Vendor_Order_Line_Items__r) from Part__c where Id =: part.Id]; 
        
        system.assertEquals(1, partList.size());
        system.assertEquals(0, partList[0].Qty_On_Order__c);
        system.assertEquals(0, partList[0].Vendor_Order_Line_Items__r.size());
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
        String voWrapperJSON = BPUtility.getDecodedString(VendorOrderCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voWrapper = (VendorOrderLineItemWrapper) System.JSON.deserialize(voWrapperJSON, VendorOrderLineItemWrapper.class);
        
        List<Vendor_Order_Line_Item__c> voliList = [Select Id, Qty_Needed__c, Received__c, Qty_Ordered__c , Is_required_For_Customer__c, CO_Line_Item__c, CO_Header__c, Needed_For__c, Part__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Item__c Order By Needed_For__c, CreatedDate];
        system.assertEquals(2, voliList.size());
        system.assertEquals(true, (voliList[0].Part__c == part.Id) && (voliList[1].Part__c == part.Id));
        system.assertEquals(true, (voliList[0].Qty_Needed__c == 50) && (voliList[1].Qty_Needed__c == 200));
        //system.assertEquals(250, voliList[0].Part__r.Qty_On_Order__c);
        system.assertEquals(true, (voliList[0].CO_Line_Item__c == coLineItem.Id) && (voliList[0].CO_Header__c == coHeader.Id));
        system.assertEquals(true, (voliList[1].CO_Line_Item__c == null) && (voliList[1].CO_Header__c == null));
        system.assertEquals(true, voliList[0].Is_required_For_Customer__c && !voliList[1].Is_required_For_Customer__c);
        
        Test.startTest();
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(System.JSON.serialize(new List<String>{voliList[0].Id, voliList[1].Id})), BPUtility.getEncodedString(vendor.Id), 
        							 				BPUtility.getEncodedString(voWrapper.VendorOrderHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));											
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);				
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voWrapper.VendorOrderHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
       	voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        
        system.assertEquals(1, voLineItems.VendorOrderLineItemGroupList.size());
        system.assertEquals(260, voLineItems.VendorOrderLineItemGroupList[0].Need);
        system.assertEquals(5200, voLineItems.VendorOrderLineItemGroupList[0].Total);
        
        system.assertEquals('On Order', voLineItems.VendorOrderHeader.Status);
        
        system.assertEquals(3, voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList.size());
        for(VendorOrderLineItem voliObj : voLineItems.VendorOrderLineItemGroupList[0].VendorOrderLineItemList) {
        	if(voliObj.IsRequiredForCustomer) {
        		system.assertEquals(50, voliObj.Need);
        		system.assertEquals(1000, voliObj.Total);
        	} else if(!voliObj.IsExcess) {
        		system.assertEquals(200, voliObj.Need);
        		system.assertEquals(4000, voliObj.Total);
        	} else {
        		system.assertEquals(10, voliObj.Need);
        	}
        }
        
        update new CO_Line_Item__c(Id = coLineItem.Id, Qty__c = 90);
        
        List<Vendor_Order_Line_Item_Group__c> voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Total__c, Vendor_Order_Header__r.Status__c, (Select Id, CO_Line_Item__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Items__r) from Vendor_Order_Line_Item_Group__c];
        voligList = [Select Id, Need__c, Total__c, Vendor_Order_Header__r.Total__c, Vendor_Order_Header__r.Status__c, (Select Id, CO_Line_Item__c, Qty_Needed__c, Is_required_For_Customer__c, Needed_For__c, Part__r.Qty_On_Order__c, Is_Excess__c from Vendor_Order_Line_Items__r Order By CreatedDate) from Vendor_Order_Line_Item_Group__c];
        system.assertEquals(1, voligList.size());
        system.assertEquals(260, voligList[0].Need__c);
        system.assertEquals(5200, voligList[0].Total__c);
        
		system.assertEquals('On Order', voligList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(5200, voligList[0].Vendor_Order_Header__r.Total__c);
        /*
        system.assertEquals(2, voligList[0].Vendor_Order_Line_Items__r.size());
        system.assertEquals(null, voligList[0].Vendor_Order_Line_Items__r[0].CO_Line_Item__c);
        system.assertEquals(null, voligList[0].Vendor_Order_Line_Items__r[1].CO_Line_Item__c);
        system.assertEquals(200, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(60, voligList[0].Vendor_Order_Line_Items__r[0].Qty_Needed__c);
        system.assertEquals(true, !voligList[0].Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c && !voligList[0].Vendor_Order_Line_Items__r[0].Is_Excess__c
        				&& !voligList[0].Vendor_Order_Line_Items__r[1].Is_required_For_Customer__c && voligList[0].Vendor_Order_Line_Items__r[1].Is_Excess__c);
        		
	 	//system.assertEquals(5, voligList[0].Part__r.Qty_On_Order__c);*/
	 	Test.stopTest();
	 }
	 
	 public class VendorPaginationSorting {
    	public Integer ChangesCount;
    	public Integer CurrentPage;
    	public Integer PageSize;
    	public List<SortAttrs> Sorting;
    }
    
    public class SortAttrs {
    	public String FieldName;
    	public String SortDirection;
    	
    	public SortAttrs(String FieldName, String SortDirection){
    		this.FieldName = FieldName;
    		this.SortDirection = SortDirection;
    	}
    }																							
}