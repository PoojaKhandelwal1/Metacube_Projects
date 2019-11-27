@isTest
global with sharing class VendorOrderReceivingCtrl_PartialTest {
	
	
	/**
     * Name: BlackPurlHeaderCtrl
     * Desc: Constructor
    **/
    @future
	global static void createExcessTestData(Id vendorId, Id vorId, Id voHeaderId, Id partId){
		PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 2, 8000,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
		
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
     	
       	//system.assert(false, partList);
        //system.assertEquals(colineitem12[0].Qty_Committed__c, 150.00);
         
       	List<Vendor_Order_Line_Item__c> voliList = [select Qty_Needed__c, Received__c from Vendor_Order_Line_Item__c limit 100];
       	//system.assert(false, voliList);
       	
        system.assertEquals(partList[0].Qty_In_Stock__c, 144.00);
        system.assertEquals(partList[0].Qty_Committed__c, 144.00);
        system.assertEquals(partList[0].Qty_On_Order__c, 16);
        
        List<CO_Line_Item__c> colineitem12 = [select Part__c, Qty_Committed__c, Qty__c, Status__c from CO_Line_Item__c limit 100];
        //system.assert(false, colineitem12);
        system.assertEquals(colineitem12[0].Qty__c, 150.00);
        system.assertEquals(colineitem12[0].Qty_Committed__c, 144.00);
        
        List<Vendor_Order_Header__c> voHeader12 = [select Status__c, 	Vendor__c from Vendor_Order_Header__c limit 100];
        system.assertEquals(voHeader12[0].Status__c, 'Partially Received');
        
        ActiveOrder.RelatedListPaginationSorting pageSort1 = new ActiveOrder.RelatedListPaginationSorting();
        pageSort1.activeOrdersCurrentPage = 1;
        pageSort1.activeOrdersPageSize = 10;
       List<ActiveOrder> activeOrders = ActiveOrder.getAllActiveOrdersForPart(partId, System.JSON.serialize(pageSort1));
       //system.assert(false, activeOrders);
       system.assertEquals(activeOrders[0].Status, 'Partially Received' );
       

       List<ActiveOrder> activeOrders1 = ActiveOrder.getAllActiveOrdersForVendor(vendorId, System.JSON.serialize(pageSort1));
       system.assertEquals(activeOrders1[0].Status, 'Partially Received');
       
       
        
        Vendor_Receiving_Header__c vrh1 = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        String vor1Id = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(vor1Id), true));
        
        String allLineItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems11 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems1, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        
        String UpdatedItemsSubsection1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems11.VORGroupList[0].Id), 1, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		String commitLineItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vor1Id)));
		
		List<Vendor_Order_Header__c> voHeaderList = [select Status__c from Vendor_Order_Header__c Limit 100];
        //system.assert(false, voHeaderList);
        
        List<Part__c> partList1 = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c Limit 100];
        //system.assert(false, partList1);
        system.assertEquals(partList1[0].Qty_In_Stock__c, 166.00);
        system.assertEquals(partList1[0].Qty_Committed__c, 150.00);
        system.assertEquals(partList1[0].Qty_On_Order__c, 0);
        

	}	
		@future
	/**
     * Name: BlackPurlHeaderCtrl
     * Desc: Constructor
    **/
	global static void createExcessTestDataforStock(Id vendorId, Id vorId, Id voHeaderId, Id partId){
		PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 8, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
		
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        
       List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
     
       	
       	//system.assert(false, partList);
        //system.assertEquals(colineitem12[0].Qty_Committed__c, 150.00);
        
       	
        system.assertEquals(partList[0].Qty_In_Stock__c, 276.00);
        system.assertEquals(partList[0].Qty_Committed__c, 100.00);
        system.assertEquals(partList[0].Qty_On_Order__c, 44);

        
        Vendor_Receiving_Header__c vrh1 = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        
        String vor1Id = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(vor1Id), true));
        String allLineItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems11 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems1, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems11.VORGroupList[0].Id), 2, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		String commitLineItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vor1Id)));
		
		List<Part__c> partList1 = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c Limit 100];
        //system.assert(false, partList1);
        system.assertEquals(partList1[0].Qty_In_Stock__c, 320.00);
        system.assertEquals(partList1[0].Qty_Committed__c, 100.00);
        system.assertEquals(partList1[0].Qty_On_Order__c, 0);
	}
	
			
	/**
     * Name: BlackPurlHeaderCtrl
     * Desc: Constructor
    **/  
    @future
	global static void createExcessTestDataforBothStockAndCustomer(Id vendorId, Id vorId, Id voHeaderId, Id partId){
		PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        //system.assert(false, voLineReceiveItems1);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 8, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
		
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        
       List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
     
       	
       	//system.assert(false, partList);
        //system.assertEquals(colineitem12[0].Qty_Committed__c, 150.00);
        
       	
        system.assertEquals(partList[0].Qty_In_Stock__c, 276.00);
        system.assertEquals(partList[0].Qty_Committed__c, 150.00);
         // assertion change by subhrant  for voli stokcing function changes
        system.assertEquals(partList[0].Qty_On_Order__c, 88);
		
        Vendor_Receiving_Header__c vrh1 = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
       	String vor1Id = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(vor1Id), true));
        
        //VendorOrderReceivingCtrl.isAssertShown = true;
        String allLineItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vor1Id), 
        													BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), 
        													BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        													BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        													BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems11 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems1, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems11.VORGroupList[0].Id), 5, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		String commitLineItems1 =  BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vor1Id)));
		
		
		List<Part__c> partList1 = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c Limit 100];
        //system.assert(false, partList1);
        system.assertEquals(partList1[0].Qty_In_Stock__c, 386.00);
        system.assertEquals(partList1[0].Qty_Committed__c, 150.00);
        system.assertEquals(partList1[0].Qty_On_Order__c, 0);
	}
	
				@future
	/**
     * Name: BlackPurlHeaderCtrl
     * Desc: Constructor
    **/
	global static void createExcessTestDataforBothStockAndCustomerforMultipleCO(Id vendorId, Id vorId, Id voHeaderId, Id partId){
		PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        //system.assert(false, voLineReceiveItems1);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 8, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
		
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
        String commitLineItems =  BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        
       	List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
     
       	
       	//system.assert(false, partList);
        //system.assertEquals(colineitem12[0].Qty_Committed__c, 150.00);
        
       	
        system.assertEquals(partList[0].Qty_In_Stock__c, 276.00);
        system.assertEquals(partList[0].Qty_Committed__c, 250.00);
         // assertion change by subhrant  for voli stokcing function changes
        system.assertEquals(partList[0].Qty_On_Order__c, 176);

        
        Vendor_Receiving_Header__c vrh1 = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        String vor1Id = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(vor1Id), true));
        String allLineItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems11 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems1, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems11.VORGroupList[0].Id), 9, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;  
		String commitLineItems1 =  BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vor1Id)));
		
		List<Part__c> partList1 = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c Limit 100];
        //system.assert(false, partList1);
        system.assertEquals(partList1[0].Qty_In_Stock__c, 474.00);
        system.assertEquals(partList1[0].Qty_Committed__c, 250.00);
        system.assertEquals(partList1[0].Qty_On_Order__c, 0);
	}
	
	    @future
	global static void createExcessTestDataMultiParts(Id vendorId, Id vorId, Id voHeaderId, Id partId, Id part2Id){
		PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 2, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
		VendorReceivingGroupTriggerHelper.isProcessed = false;
		String UpdatedItemsSubsection1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[1].Id), 50, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
        String commitLineItems =  BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        
        List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
     	
       	//system.assert(false, partList);
        //system.assertEquals(colineitem12[0].Qty_Committed__c, 150.00);
         
       	List<Vendor_Order_Line_Item__c> voliList = [select Qty_Needed__c, Received__c from Vendor_Order_Line_Item__c limit 100];
       	//system.assert(false, voliList);
       	
        system.assertEquals(partList[0].Qty_In_Stock__c, 144.00);
        system.assertEquals(partList[0].Qty_Committed__c, 144.00);
        system.assertEquals(partList[0].Qty_On_Order__c, 16);
        
        system.assertEquals(partList[1].Qty_In_Stock__c, 100.00);
        system.assertEquals(partList[1].Qty_Committed__c, 100.00);
        system.assertEquals(partList[1].Qty_On_Order__c, 0);

        List<Vendor_Order_Header__c> voHeader12 = [select Status__c, 	Vendor__c from Vendor_Order_Header__c limit 100];
        system.assertEquals(voHeader12[0].Status__c, 'Partially Received');
        
        Vendor_Receiving_Header__c vrh1 = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
       	String vor1Id = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(vor1Id), true));
        
        String allLineItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems11 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems1, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection2 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems11.VORGroupList[0].Id), 1, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection3 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(part2Id), BPUtility.getEncodedString(voLineReceiveItems11.VORGroupList[1].Id), 16, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
		
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		//String commitLineItems1 = VendorOrderReceivingCtrl.commitRecevingAction(vor1Id); 
		
		List<Vendor_Order_Header__c> voHeaderList = [select Status__c from Vendor_Order_Header__c Limit 100];
        system.assertEquals(voHeaderList[0].Status__c, 'Partially Received');
        
        /*List<Part__c> partList1 = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c];
        //system.assert(false, partList1);
        system.assertEquals(partList1[0].Qty_In_Stock__c, 166.00);
        system.assertEquals(partList1[0].Qty_Committed__c, 150.00);
        system.assertEquals(partList1[0].Qty_On_Order__c, 0);
        system.assertEquals(partList1[1].Qty_In_Stock__c, 116.00);
        system.assertEquals(partList1[1].Qty_Committed__c, 116.00);
        system.assertEquals(partList1[1].Qty_On_Order__c, 0);
        
        List<Vendor_Order_Line_Item_Group__c> volig = [select Need__c, Received_Qty__c, Part__c from Vendor_Order_Line_Item_Group__c];
        //system.assert(false, volig);
        system.assertEquals(volig[0].Need__c, 66.000);
        system.assertEquals(volig[0].Received_Qty__c, 66.000);
        system.assertEquals(volig[1].Need__c, 66.000);
        system.assertEquals(volig[1].Received_Qty__c, 66.000);*/ 
	}
	
	@future
	global static void createExcessTestDataforVOGDetails(Id vendorId, Id vorId, Id voHeaderId, Id partId){
		PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        //system.assert(false, voLineReceiveItems1);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 8, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
		
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
        String commitLineItems =  BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        
       	List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
        system.assertEquals(partList[0].Qty_In_Stock__c, 276.00);
        system.assertEquals(partList[0].Qty_Committed__c, 150.00);
         // assertion change by subhrant  for voli stokcing function changes
        system.assertEquals(partList[0].Qty_On_Order__c, 88);


        Vendor_Receiving_Header__c vrh1 = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
       String vor1Id = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(null)));
       
       	String VendorOrderReceiveItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(vor1Id), true));
        
        String allLineItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems11 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems1, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems11.VORGroupList[0].Id), 5, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
       	VendorReceivingGroupTriggerHelper.isProcessed = false;
        String removedItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.removeAllItemsFromItemSubSection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItemsfordetails = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(removedItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
       	List<Vendor_Order_Line_Item_Group__c> volig = [select Need__c, Received_Qty__c, Part__c from Vendor_Order_Line_Item_Group__c limit 100];
       	 // assertion change by subhrant  for voli stokcing function changes
        system.assertEquals(volig[0].Need__c, 264);
		system.assertEquals(volig[0].Received_Qty__c, 176);
		
		List<Vendor_Order_Line_Item__c> voliPartial = [select Qty_Needed__c, Received__c, Part__c from Vendor_Order_Line_Item__c limit 100];
		system.assertEquals(voliPartial[0].Qty_Needed__c, 126);
		system.assertEquals(voliPartial[0].Received__c, 126);
		system.assertEquals(voliPartial[1].Qty_Needed__c, 50);
		system.assertEquals(voliPartial[1].Received__c, 50);
		 // assertion change by subhrant  for voli stokcing function changes
		system.assertEquals(voliPartial[2].Qty_Needed__c, 14);
		system.assertEquals(voliPartial[2].Received__c, 0);
		 // assertion change by subhrant  for voli stokcing function changes
		system.assertEquals(voliPartial[3].Qty_Needed__c, 74);
		system.assertEquals(voliPartial[3].Received__c, 0);


        String allLineItems2 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems12 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems2, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
		
		VendorReceivingGroupTriggerHelper.isProcessed = false;
		String UpdatedItemsSubsection2 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems12.VORGroupList[0].Id), 5, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		
		String commitLineItems1 =  BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vor1Id)));
		
		List<Vendor_Order_Line_Item__c> voliPartial1 = [select Qty_Needed__c, Received__c, Part__c from Vendor_Order_Line_Item__c limit 100];
		system.assertEquals(voliPartial1[0].Qty_Needed__c, 126);
		system.assertEquals(voliPartial1[0].Received__c, 126);
		system.assertEquals(voliPartial1[1].Qty_Needed__c, 50);
		system.assertEquals(voliPartial1[1].Received__c, 50);
		system.assertEquals(voliPartial1[2].Qty_Needed__c, 14);
		system.assertEquals(voliPartial1[2].Received__c, 14);
		system.assertEquals(voliPartial1[3].Qty_Needed__c, 74);
		system.assertEquals(voliPartial1[3].Received__c, 74);
		
		List<Part__c> partList1 = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c Limit 100];
        //system.assert(false, partList1);
        system.assertEquals(partList1[0].Qty_In_Stock__c, 386.00);
        system.assertEquals(partList1[0].Qty_Committed__c, 150.00);
        system.assertEquals(partList1[0].Qty_On_Order__c, 0);
        
        List<Vendor_Order_Line_Item_Group__c> voligroupList = [select Need__c, Received_Qty__c, Part__c from Vendor_Order_Line_Item_Group__c Limit 100];
        system.assertEquals(voligroupList[0].Need__c, 264);
        system.assertEquals(voligroupList[0].Received_Qty__c, 264);
        
	}
	
	@future
	global static void createExcessTestDataA(Id vendorId, Id vorId, Id voHeaderId, Id partId, Id coHeaderId){
		PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 200, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
	}
	
	/*@future
	global static void createExcessTestDataABCD(Id vendorId, Id vorId, Id voHeaderId, Id partId, Id coHeaderId){
		PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
        String commitLineItems = VendorOrderReceivingCtrl.commitRecevingAction(vorId);
        
        List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
     	
       	//system.assert(false, partList);
        //system.assertEquals(colineitem12[0].Qty_Committed__c, 150.00);
         
       	List<Vendor_Order_Line_Item__c> voliList = [select Qty_Needed__c, Received__c from Vendor_Order_Line_Item__c limit 100];
       	//system.assert(false, voliList);
       	
        system.assertEquals(partList[0].Qty_In_Stock__c, 300.00);
        system.assertEquals(partList[0].Qty_Committed__c, 300.00);
        system.assertEquals(partList[0].Qty_On_Order__c, 0);
        
        List<CO_Line_Item__c> colineitem12 = [select Part__c, Qty_Committed__c, Qty__c, Status__c from CO_Line_Item__c limit 100];
        //system.assert(false, colineitem12);
        system.assertEquals(colineitem12[0].Qty_Committed__c, 300.00);
        system.assertEquals(colineitem12[0].Qty_Committed__c, 300);
        
        List<Service_Order_Line_Item__c> SOli1 = [select Id, Qty_Committed__c, Fixed_Price__c, Total__c from Service_Order_Line_Item__c limit 100];
        //system.assert(false, SOli1);
        system.assertEquals(SOli1[0].Qty_Committed__c, 300.00);
        system.assertEquals(SOli1[0].Total__c, 27500.00);
        
        List<Vendor_Order_Header__c> voHeader12 = [select Status__c, 	Vendor__c from Vendor_Order_Header__c limit 100];
        system.assertEquals(voHeader12[0].Status__c, 'Partially Received');
        
        Vendor_Receiving_Header__c vrh1 = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        Id vor1Id = VendorOrderReceivingCtrl.addVendor(vendorId, null);
        String VendorOrderReceiveItems1 = VendorOrderReceivingCtrl.receiveVendorOrderItems(voHeaderId, vor1Id, true);
        
        String allLineItems1 = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(vor1Id, voHeaderId, null, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems11 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems1, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection1 = VendorOrderReceivingCtrl.updateItemsSection(vor1Id, partId, voLineReceiveItems11.VORGroupList[0].Id, 200, 8000, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		String commitLineItems1 = VendorOrderReceivingCtrl.commitRecevingAction(vor1Id);
		
		List<Vendor_Order_Header__c> voHeader13 = [select Status__c, 	Vendor__c from Vendor_Order_Header__c limit 100];
        system.assertEquals(voHeader13[0].Status__c, 'Received');
        
        List<Part__c> partList1 = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
        system.assertEquals(partList1[0].Qty_In_Stock__c, 500.00);
        system.assertEquals(partList1[0].Qty_Committed__c, 500.00);
        system.assertEquals(partList1[0].Qty_On_Order__c, 0);
        
        List<CO_Line_Item__c> colineitem13 = [select Part__c, Qty_Committed__c, Qty__c, Status__c from CO_Line_Item__c limit 100];
        //system.assert(false, colineitem12);
        system.assertEquals(colineitem13[0].Qty_Committed__c, 500.00);
        system.assertEquals(colineitem13[0].Qty_Committed__c, 500);
        
        String details = CustomerOrderCtrl.getCOHeaderDetails(coHeaderId);
   		COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
   		//system.assert(false, coHeaderDetails);
   		system.assertEquals(coHeaderDetails.COInvoiceItemRecs[0].Total, 27500.000);
   		
   		String savedCOInvoicePayment = CustomerOrderCtrl.saveCOInvoicePayment('[{"ReverseLink":null,"PaymentMethod":"Cash","Amount":"27500.000","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'"}]');
   		//system.assert(false, savedCOInvoicePayment);
   		   
   		//String closedInvoiceAction = CustomerOrderCtrl.closedInvoiceAction('[{"Total":27500.000,"TaxAmount":null,"Saving":null,"RetailPrice":null,"QtyRequired":null,"Qty":null,"Price":null,"Item":"Service Job 1","IsInvoiceable":true,"IsActive":true,"COLineItemId":null,"COInvoiceItemNumber":null,"COInvoiceItemId":"'+coHeaderDetails.coInvoiceItemRecs[0].COInvoiceItemId+'","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'","$$hashKey":"object:56"}]', coHeaderId, 'Customer');
   		String closedInvoiceAction = CustomerOrderCtrl.closedInvoiceAction(System.JSON.serialize(coHeaderDetails.COInvoiceItemRecs), coHeaderId, 'Customer');
	}*/

	/*@future
	global static void createExcessTestDataTK(){
		Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(false, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
    	Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 100;
        insert part;
        
    	Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        //Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
 		Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        //Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
    	//Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, LabourCode.Id, Part.Id, 1, 5.0);	
    	
    	String soHeader = CustomerOrderCtrl.createSOHeader(coHeader.Id);
        String SOHeaderDetails = CustomerOrderCtrl.getSOHeaderDetails(coHeader.Id, 'soHeader');
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        
        String lineitems = CustomerOrderCtrl.addLineItems(part.Id, soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id, coHeader.Id, customer.Id);
        
    	String SOHeaderDetails1 = CustomerOrderCtrl.getSOHeaderDetails(coHeader.Id, null);
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 500.00 ;
		
		ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		
        String updatedSOLI = CustomerOrderCtrl.updateSOLineItems(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0]), coHeader.Id);

   		
   		
   		

   		PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        
        String similarlineitem = VendorOrderCtrl.groupAllVOLineItem(vendor.Id, voHeader.Id, true,  System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        String finalizedLineItems = VendorOrderCtrl.finalizeVendorOrder(voHeader.Id, vendor.Id, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));

        
       	Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
        Id vorId = VendorOrderReceivingCtrl.addVendor(vendor.Id, null);
        String VendorOrderReceiveItems = VendorOrderReceivingCtrl.receiveVendorOrderItems(voHeader.Id, vorId, true);
        
	

	 	String allLineItems = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(vorId, voHeader.Id, null, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);

		
		String commitLineItems = VendorOrderReceivingCtrl.commitRecevingAction(vorId);

         
        List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
        system.assertEquals(partList[0].Qty_In_Stock__c, 500.00);
        system.assertEquals(partList[0].Qty_Committed__c, 500.00);
        system.assertEquals(partList[0].Qty_On_Order__c, 0);
        
        String details = CustomerOrderCtrl.getCOHeaderDetails(coHeader.Id);
   		COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
   		//system.assert(false, coHeaderDetails);
   		system.assertEquals(coHeaderDetails.COInvoiceItemRecs[0].Total, 27500.000);
   		
   		String savedCOInvoicePayment = CustomerOrderCtrl.saveCOInvoicePayment('[{"ReverseLink":null,"PaymentMethod":"Cash","Amount":"27500.000","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'"}]');
   		//system.assert(false, savedCOInvoicePayment);
       
   		
   		
   		String closedInvoiceAction = CustomerOrderCtrl.closedInvoiceAction('[{"Total":27500.000,"TaxAmount":null,"Saving":null,"RetailPrice":null,"QtyRequired":null,"Qty":null,"Price":null,"Item":"Service Job 1","IsInvoiceable":true,"IsActive":true,"COLineItemId":null,"COInvoiceItemNumber":null,"COInvoiceItemId":"'+coHeaderDetails.coInvoiceItemRecs[0].COInvoiceItemId+'","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'","$$hashKey":"object:56"}]', coHeader.Id, 'Customer');
   		
   		COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(closedInvoiceAction, COHeaderWrapper.class);
   		//system.assert(false, coHeaderDetails1);
   		system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].NumberOfItems, 1);
   		system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].Total, 27500);
   		system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].Tax, 0);
   		system.assertEquals(coHeaderDetails1.COInvoiceItemRecs.size(), 0);
   		
   		 List<Part__c> partList1 = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
        system.assertEquals(partList1[0].Qty_In_Stock__c, 0.00);
        system.assertEquals(partList1[0].Qty_Committed__c, 0.00);
        system.assertEquals(partList1[0].Qty_On_Order__c, 0);
   		
   		
        
	}*/
	
	 @future
	global static void SamePartInMultipleSO_partialReceive(Id vendorId, Id partId, Id coHeaderId){

   		
   		//CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 200);
   		
   		//list<Service_Order_Header__c> solist = [select id, name__c from Service_Order_Header__c ];
   		//system.assert(false, solist );
   		//List<Vendor_Order_Line_Item__c> volis = [select Qty_Needed__c, Is_Service__c, Is_required_For_Customer__c, Received__c, Vendor_Order_Line_Item_Group__c, Vendor_Receiving_Group__c, CO_Line_Item__c from Vendor_Order_Line_Item__c];
       	//system.assert(false, volis);
   		
   		if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); } //FLS Create Nikhil 31/01/2017 
   		PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendorId, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendorId);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        
        //String similarlineitem = VendorOrderCtrl.groupAllVOLineItem(vendorId, voHeader.Id, true,  System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        String groupLineItems = BPUtility.getDecodedString(VendorOrderCtrl.groupAllSimilarVOLineItem(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        //VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        /*List<Part__c> partList1 = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c];
        system.assertEquals(partList1[0].Qty_On_Order__c, 0);*/
        
       	Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
       String vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems1 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vorId), true));
        
	
		String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        //String UpdatedItemsSubsection = VendorOrderReceivingCtrl.updateItemsSection(vorId, partId, voLineReceiveItems.VORGroupList[0].Id, 200, 8000, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));

       	
        String commitLineItems =  BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
       	
       	
       	List<CO_Invoice_Item__c>  coinvoice = [select isActive__c, 	Is_Invoiceable__c, Qty__c,	SO_Payment_Role__c, Service_Order_Header__c, CO_Line_Item__c, CO_Kit_Header__c  from CO_Invoice_Item__c limit 100];
 		//system.assert(false, coinvoice);
        
        String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
        //system.assert(false, coHeaderDetails);
        
        
        
        system.assertEquals(coHeaderDetails.COInvoiceItemRecs[0].Total, 27500.000);
        system.assertEquals(coHeaderDetails.COInvoiceItemRecs[1].Total, 11000.000);
        system.assertEquals(coHeaderDetails.COInvoiceItemRecs[2].Total, 16500.000);
        
                
        String savedCOInvoicePayment = BPUtility.getDecodedString(CustomerOrderCtrl.saveCOInvoicePayment(BPUtility.getEncodedString('[{"ReverseLink":null,"PaymentMethod":"Cash","Amount":"27500.000","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'"}]')));
        //system.assert(false, savedCOInvoicePayment);
       //String updatedCOInvoicePayment = CustomerOrderCtrl.updateCOInvoiceItem(true, '{"COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'","COInvoiceItemId":"'+coHeaderDetails.coInvoiceItemRecs[1].COInvoiceItemId+'","COLineItemId":"'+coHeaderDetails.allcoLineItemRecs[0].CoLineItemId+'"}', 'b');
        /*for(COInvoiceItem coInvoiceItemObj : coHeaderDetails.COInvoiceItemRecs) {
        	CustomerOrderCtrl.updateCOInvoiceItem(System.JSON.Serialize(coInvoiceItemObj), coHeaderId );
        }*/
        
        String closedInvoiceAction = BPUtility.getDecodedString(CustomerOrderCtrl.closedInvoiceAction(BPUtility.getEncodedString(System.JSON.Serialize(coHeaderDetails.COInvoiceItemRecs)), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('Customer')));
        //String closedInvoiceAction = CustomerOrderCtrl.closedInvoiceAction('[{"Total":27500.000,"TaxAmount":null,"Saving":null,"RetailPrice":null,"QtyRequired":null,"Qty":null,"Price":null,"Item":"Service Job 1","IsInvoiceable":true,"IsActive":true,"COLineItemId":null,"COInvoiceItemNumber":null,"COInvoiceItemId":"'+coHeaderDetails.coInvoiceItemRecs[0].COInvoiceItemId+'","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'","$$hashKey":"object:56"}]', coHeader.Id);
        
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(closedInvoiceAction, COHeaderWrapper.class);
        //system.assert(false, coHeaderDetails1);
        /*system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].NumberOfItems, 2);
        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].Total, 55000);
        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].Tax, 0);
        system.assertEquals(coHeaderDetails1.COInvoiceItemRecs.size(), 0);*/

   		
   		
        
	}
	
	/* @future
	global static void SamePartInMultipleSO_partialReceiveA(Id vendorId, Id partId, Id coHeaderId){

   		
   		//CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 200);
   		
   		//list<Service_Order_Header__c> solist = [select id, name__c from Service_Order_Header__c ];
   		//system.assert(false, solist );
   		//List<Vendor_Order_Line_Item__c> volis = [select Qty_Needed__c, Is_Service__c, Is_required_For_Customer__c, Received__c, Vendor_Order_Line_Item_Group__c, Vendor_Receiving_Group__c, CO_Line_Item__c from Vendor_Order_Line_Item__c];
       	//system.assert(false, volis);
   		
   		
   		PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendorId, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendorId);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        
        //String similarlineitem = VendorOrderCtrl.groupAllVOLineItem(vendorId, voHeader.Id, true,  System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        String groupLineItems = VendorOrderCtrl.groupAllSimilarVOLineItem(vendorId, partId, voHeader.Id, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        //VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        String finalizedLineItems = VendorOrderCtrl.finalizeVendorOrder(voHeader.Id, vendorId, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        
        //List<Part__c> partList1 = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c];
        //system.assertEquals(partList1[0].Qty_On_Order__c, 0);
        
       	Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        Id vorId = VendorOrderReceivingCtrl.addVendor(vendorId, null);
        String VendorOrderReceiveItems = VendorOrderReceivingCtrl.receiveVendorOrderItems(voHeader.Id, vorId, true);
        
	

	 	String allLineItems = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(vorId, voHeader.Id, null, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = VendorOrderReceivingCtrl.updateItemsSection(vorId, partId, voLineReceiveItems.VORGroupList[0].Id, 200, 8000, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));

       	
        String commitLineItems = VendorOrderReceivingCtrl.commitRecevingAction(vorId);
       	
       List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];

        system.assertEquals(partList[0].Qty_On_Order__c, 100);
        
        List<Vendor_Order_Line_Item__c> volis = [select Qty_Needed__c, Is_Service__c, Is_required_For_Customer__c, Received__c, Vendor_Order_Line_Item_Group__c, Vendor_Receiving_Group__c, CO_Line_Item__c from Vendor_Order_Line_Item__c limit 100];
       	//system.assert(false, volis);
        system.assertequals(volis.size(), 5);
        
        List<Vendor_Order_Header__c> voHeader12 = [select Status__c, 	Vendor__c from Vendor_Order_Header__c limit 100];
        system.assertEquals(voHeader12[0].Status__c, 'Partially Received');
        
        Vendor_Receiving_Header__c vrh1 = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        Id vor1Id = VendorOrderReceivingCtrl.addVendor(vendorId, null);
        String VendorOrderReceiveItems1 = VendorOrderReceivingCtrl.receiveVendorOrderItems(voHeader.Id, vor1Id, true);
        
        String allLineItems1 = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(vor1Id, voHeader.Id, null, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems11 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems1, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection1 = VendorOrderReceivingCtrl.updateItemsSection(vor1Id, partId, voLineReceiveItems11.VORGroupList[0].Id, 800, 8000, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
		
		//List<CO_Line_Item__c> colis12 = [select Name, Qty__c, Qty_Committed__c, Service_Order_Line_Item__c from CO_Line_Item__c];
   		//system.assert(false, colis12);
	
   		//VendorOrderReceivingCtrl.isAssertShown = true;
		String commitLineItems1 = VendorOrderReceivingCtrl.commitRecevingAction(vor1Id); 
		
		//List<Service_Order_Header__c> soh123 = [select Name, (select Id from CO_Invoice_Items__r) from Service_Order_Header__c];
   		//system.assert(false, soh123[0].CO_Invoice_Items__r + '\n\n\n\n' + soh123[1].CO_Invoice_Items__r);
		
		List<Vendor_Order_Line_Item__c> volis123 = [select Qty_Needed__c, Is_Service__c, Is_required_For_Customer__c, Received__c, Vendor_Order_Line_Item_Group__c, Vendor_Receiving_Group__c, CO_Line_Item__c from Vendor_Order_Line_Item__c limit 100];
       	system.assertequals(volis123.size(), 5);
       	
       	
		List<Vendor_Order_Header__c> voHeader13 = [select Status__c, 	Vendor__c from Vendor_Order_Header__c limit 100];
        system.assertEquals(voHeader13[0].Status__c, 'Received');
        
        List<Part__c> partList1 = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
        system.assertEquals(partList1[0].Qty_In_Stock__c, 1100.00);
        system.assertEquals(partList1[0].Qty_Committed__c, 1000.00);
        system.assertEquals(partList1[0].Qty_On_Order__c, 0);
        



   		
   		
        
	}*/
	
		@future
	global static void ScenarioForMecrhsection_partialReceive(Id vendorId, Id partId, Id coHeaderId){

		if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); } //FLS Create Nikhil 31/01/2017
   		PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendorId, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendorId);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        String groupLineItems = BPUtility.getDecodedString(VendorOrderCtrl.groupAllSimilarVOLineItem(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
       	Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        String vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vorId), true));
        
	
		String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems.VORGroupList[0].Id), 200, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
		
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
       	
        String commitLineItems =  BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
       	
       	/*List<Vendor_Order_Line_Item__c> volis1 = [select Qty_Needed__c, Is_Service__c, Is_required_For_Customer__c, Received__c, Vendor_Order_Line_Item_Group__c, Vendor_Receiving_Group__c, CO_Line_Item__c from Vendor_Order_Line_Item__c limit 100];
       	system.assert(false, volis1);*/
       	
       	
       	/*
        List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];

        system.assertEquals(partList[0].Qty_On_Order__c, 0);
        List<Vendor_Order_Line_Item__c> volis = [select Qty_Needed__c, Is_Service__c, Is_required_For_Customer__c, Received__c, Vendor_Order_Line_Item_Group__c, Vendor_Receiving_Group__c, CO_Line_Item__c from Vendor_Order_Line_Item__c limit 100];
       	//system.assert(false, volis);
        
        system.assertequals(volis.size(), 3);
        
        List<Vendor_Order_Header__c> voHeader12 = [select Status__c, Vendor__c from Vendor_Order_Header__c limit 100];
        system.assertEquals(voHeader12[0].Status__c, 'Partially Received');
        
        Vendor_Receiving_Header__c vrh1 = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        Id vor1Id = VendorOrderReceivingCtrl.addVendor(vendorId, null);
        String VendorOrderReceiveItems1 = VendorOrderReceivingCtrl.receiveVendorOrderItems(voHeader.Id, vor1Id, true);
        
        String allLineItems1 = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(vor1Id, voHeader.Id, null, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems11 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems1, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection1 = VendorOrderReceivingCtrl.updateItemsSection(vor1Id, partId, voLineReceiveItems11.VORGroupList[0].Id, 500, 8000, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
		
   		
		String commitLineItems1 = VendorOrderReceivingCtrl.commitRecevingAction(vor1Id); 
		

		
		List<Vendor_Order_Line_Item__c> volis123 = [select Qty_Needed__c, Is_Service__c, Is_required_For_Customer__c, Received__c, Vendor_Order_Line_Item_Group__c, Vendor_Receiving_Group__c, CO_Line_Item__c from Vendor_Order_Line_Item__c limit 100];
       	system.assertequals(volis123.size(), 3);
       	
       	
		List<Vendor_Order_Header__c> voHeader13 = [select Status__c, 	Vendor__c from Vendor_Order_Header__c limit 100];
        system.assertEquals(voHeader13[0].Status__c, 'Received');
        
        List<Part__c> partList1 = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
        system.assertEquals(partList1[0].Qty_In_Stock__c, 800.00);
        system.assertEquals(partList1[0].Qty_Committed__c, 800.00);
        system.assertEquals(partList1[0].Qty_On_Order__c, 0);
        */

   		
   		  
        
	}
	
	/*		@future
	global static void ScenarioForMecrhsection_partialReceiveA(Id vendorId, Id partId, Id coHeaderId){


   		PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendorId, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendorId);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        
        String groupLineItems = VendorOrderCtrl.groupAllSimilarVOLineItem(vendorId, partId, voHeader.Id, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        String finalizedLineItems = VendorOrderCtrl.finalizeVendorOrder(voHeader.Id, vendorId, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        
       	Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        Id vorId = VendorOrderReceivingCtrl.addVendor(vendorId, null);
        String VendorOrderReceiveItems = VendorOrderReceivingCtrl.receiveVendorOrderItems(voHeader.Id, vorId, true);
        
	

	 	String allLineItems = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(vorId, voHeader.Id, null, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = VendorOrderReceivingCtrl.updateItemsSection(vorId, partId, voLineReceiveItems.VORGroupList[0].Id, 200, 8000, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
		
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
       	
        String commitLineItems = VendorOrderReceivingCtrl.commitRecevingAction(vorId);
       	
       	/*List<Vendor_Order_Line_Item__c> volis1 = [select Qty_Needed__c, Is_Service__c, Is_required_For_Customer__c, Received__c, Vendor_Order_Line_Item_Group__c, Vendor_Receiving_Group__c, CO_Line_Item__c from Vendor_Order_Line_Item__c limit 100];
       	system.assert(false, volis1);*/
       	
       	
       	/*
        List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];

        system.assertEquals(partList[0].Qty_On_Order__c, 0);
        List<Vendor_Order_Line_Item__c> volis = [select Qty_Needed__c, Is_Service__c, Is_required_For_Customer__c, Received__c, Vendor_Order_Line_Item_Group__c, Vendor_Receiving_Group__c, CO_Line_Item__c from Vendor_Order_Line_Item__c limit 100];
       	//system.assert(false, volis);
        
        system.assertequals(volis.size(), 4);
        
        List<Vendor_Order_Header__c> voHeader12 = [select Status__c, 	Vendor__c from Vendor_Order_Header__c limit 100];
        system.assertEquals(voHeader12[0].Status__c, 'Partially Received');
        
        Vendor_Receiving_Header__c vrh1 = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        Id vor1Id = VendorOrderReceivingCtrl.addVendor(vendorId, null);
        String VendorOrderReceiveItems1 = VendorOrderReceivingCtrl.receiveVendorOrderItems(voHeader.Id, vor1Id, true);
        
        String allLineItems1 = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(vor1Id, voHeader.Id, null, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems11 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems1, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection1 = VendorOrderReceivingCtrl.updateItemsSection(vor1Id, partId, voLineReceiveItems11.VORGroupList[0].Id, 1000, 8000, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;*/
		/*
   		
		String commitLineItems1 = VendorOrderReceivingCtrl.commitRecevingAction(vor1Id); 
		

		
		List<Vendor_Order_Line_Item__c> volis123 = [select Qty_Needed__c, Is_Service__c, Is_required_For_Customer__c, Received__c, Vendor_Order_Line_Item_Group__c, Vendor_Receiving_Group__c, CO_Line_Item__c from Vendor_Order_Line_Item__c limit 100];
       	//system.assert(false, volis123);
       	system.assertequals(volis123.size(), 4);
       	
       	
		List<Vendor_Order_Header__c> voHeader13 = [select Status__c, 	Vendor__c from Vendor_Order_Header__c limit 100];
        system.assertEquals(voHeader13[0].Status__c, 'Received');
        

        
        List<Part__c> partList1 = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
        system.assertEquals(partList1[0].Qty_In_Stock__c, 1300.00);
        system.assertEquals(partList1[0].Qty_Committed__c, 1300.00);
        system.assertEquals(partList1[0].Qty_On_Order__c, 0);
        
        List<CO_Invoice_Item__c> COII = [select Is_Invoiceable__c from CO_Invoice_Item__c  where CO_Kit_Header__c != null limit 100];
        system.assertEquals(COII[0].Is_Invoiceable__c, true);
        */

   		
   		
     /*   
	}*/
	
	 /*@future
	 
	global static void createExcessTestDataSpecialOrder(Id vendorId, Id vorId, Id voHeaderId, Id partId, Id coHeaderId){
		PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        String allLineItems = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(vorId, voHeaderId, null, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = VendorOrderReceivingCtrl.updateItemsSection(vorId, partId, voLineReceiveItems1.VORGroupList[0].Id, 200, 8000, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
		
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
        String commitLineItems = VendorOrderReceivingCtrl.commitRecevingAction(vorId);
        
        List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
        system.assertEquals(partList[0].Qty_In_Stock__c, 300.00);
        system.assertEquals(partList[0].Qty_Committed__c, 300.00);
        system.assertEquals(partList[0].Qty_On_Order__c, 0);
        
         
       	List<Vendor_Order_Line_Item__c> voliList = [select Qty_Needed__c, Received__c, Status__c, Vendor_Order_Line_Item_Group__c, Vendor_Receiving_Group__c, Qty_Ordered__c, 	Is_Service__c, Is_Received__c from Vendor_Order_Line_Item__c limit 100];
       	//system.assert(false, voliList);
       	system.assertEquals(voliList[0].Received__c, 200.00);
       	system.assertEquals(voliList[1].Received__c, 0);
       	system.assertEquals(voliList[0].Is_Service__c, true);
       	system.assertEquals(voliList[1].Is_Service__c, true);
       	system.assertEquals(voliList[0].Is_Received__c, true);
       	system.assertEquals(voliList[1].Is_Received__c, false);
       	system.assertEquals(voliList[1].Qty_Needed__c, 200);

        List<CO_Line_Item__c> colineitem12 = [select Part__c, Qty_Committed__c, Qty__c, Status__c from CO_Line_Item__c limit 100];
        //system.assert(false, colineitem12);
        system.assertEquals(colineitem12[0].Qty_Committed__c, 300.00);
        system.assertEquals(colineitem12[0].Qty__c, 500);
        
        List<Service_Order_Line_Item__c> SOli1 = [select Id, Qty_Committed__c, Qty_Needed__c, Qty_To_Order__c,Fixed_Price__c, Total__c from Service_Order_Line_Item__c limit 100];
        //system.assert(false, SOli1);
        system.assertEquals(SOli1[0].Qty_Committed__c, 300.00);
        system.assertEquals(SOli1[0].Qty_Needed__c, 500.00);
        system.assertEquals(SOli1[0].Qty_To_Order__c, 200.00);
        system.assertEquals(SOli1[0].Total__c, 27500.00);
        
        List<Vendor_Order_Header__c> voHeader12 = [select Status__c, 	Vendor__c from Vendor_Order_Header__c limit 100];
        system.assertEquals(voHeader12[0].Status__c, 'Partially Received');
        
        Vendor_Receiving_Header__c vrh1 = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        Id vor1Id = VendorOrderReceivingCtrl.addVendor(vendorId, null);
        String VendorOrderReceiveItems1 = VendorOrderReceivingCtrl.receiveVendorOrderItems(voHeaderId, vor1Id, true);
        
        String allLineItems1 = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(vor1Id, voHeaderId, null, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems11 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems1, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection1 = VendorOrderReceivingCtrl.updateItemsSection(vor1Id, partId, voLineReceiveItems11.VORGroupList[0].Id, 100, 8000, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		String commitLineItems1 = VendorOrderReceivingCtrl.commitRecevingAction(vor1Id);
		
		List<Vendor_Order_Line_Item__c> voliList1 = [select Qty_Needed__c, Received__c, Status__c, Vendor_Order_Line_Item_Group__c, Vendor_Receiving_Group__c, Qty_Ordered__c, 	Is_Service__c, Is_Received__c from Vendor_Order_Line_Item__c limit 100];
       	system.assertEquals(voliList1.size(), 3);
       	system.assertEquals(voliList1[2].Qty_Needed__c, 100 );
       	system.assertEquals(voliList1[2].Received__c, 0 );
       	system.assertEquals(voliList1[2].Status__c, 'Ordered' );
		
		List<Vendor_Order_Header__c> voHeader13 = [select Status__c, 	Vendor__c from Vendor_Order_Header__c limit 100];
        system.assertEquals(voHeader13[0].Status__c, 'Partially Received');
        
	}*/
	
	/**
     * Added by Nikhil 14/03/17
     * Name : vendorOrderStatus_Partial  
     **/
    
	@future
    global static void vendorOrderStatus_Partial(Id vorId,Id part2Id, Id voHeaderId,String similarlineitem, Id VendorOrderLineItemGroupListId, Id Vendor){
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        String allLineItems = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId),BPUtility.getEncodedString(voHeaderId),BPUtility.getEncodedString(null),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(BPUtility.getDecodedString(allLineItems), VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        //1st order
         VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part2Id),BPUtility.getEncodedString(voLineReceiveItems.VORGroupList[0].Id), 10, 30, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
        String commitLineItems = VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId));
        
        List<Vendor_Receiving_Header__c> vendorOrderPartialList1 = [Select Id,Name,Status__c,Vendor__c,Receiving_Total__c from Vendor_Receiving_Header__c];
        system.assertEquals(vendorOrderPartialList1[0].Status__c,'Stocked'); 
        
		List<Vendor_Order_Line_Item__c> voliList1 = [select Qty_Needed__c, Received__c, Status__c from Vendor_Order_Line_Item__c Limit 100];
        system.assertEquals(voliList1[0].Status__c, 'Received');
        system.assertEquals(voliList1[1].Status__c, 'Ordered');
        List<Vendor_Order_Header__c> vendorOrderUpdatedList = [Select Id,Name,Purchase_Order_Type__c,Status__c,Total_Recieved__c,Total__c from Vendor_Order_Header__c limit 10];  
        system.assertEquals(vendorOrderUpdatedList[0].Status__c,'Partially Received');
        
        //2nd Order
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(false, vendor, 'In Progress');
        Id vor1Id = Id.valueOf(BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor),BPUtility.getEncodedString(null))));
        String VendorOrderReceiveItems1 = VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeaderId),BPUtility.getEncodedString(vor1Id), true);
        
        
         String allLineItems1 = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vor1Id),BPUtility.getEncodedString(voHeaderId),BPUtility.getEncodedString(null),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems11 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(BPUtility.getDecodedString(allLineItems1), VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection1 = VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(part2Id),BPUtility.getEncodedString(voLineReceiveItems11.VORGroupList[0].Id), 10, 30, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
		String commitLineItems1 = VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vor1Id));
		List<Vendor_Order_Header__c> vendorOrderUpdatedList1 = [Select Id,Name,Purchase_Order_Type__c,Status__c,Total_Recieved__c,Total__c from Vendor_Order_Header__c limit 10];  
        system.assertEquals(vendorOrderUpdatedList1[0].Status__c,'Received');
        system.assertEquals(vendorOrderUpdatedList1[0].Total__c,600);
        
        List<Vendor_Order_Line_Item__c> voliList2 = [select Qty_Needed__c, Received__c, Status__c from Vendor_Order_Line_Item__c Limit 100];
        system.assertEquals(voliList2[0].Status__c, 'Received');
        system.assertEquals(voliList2[1].Status__c, 'Received');
        system.assertEquals(voliList2[0].Received__c, 10);
        system.assertEquals(voliList2[1].Received__c, 10);
        
       
    }
	
	@future
    global static void GetFilterrecordsforVendorInvoice(String vendorId, String partId, String part2Id) {
    	
    	PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
    	PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendorId, true, 2);
    	Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendorId);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        
		String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeader.Id), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vorId), true));
        

        
        
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 10, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String UpdatedItemsSubsection2 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part2Id), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[1].Id), 40, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        Vendor_Invoicing_Header__c viHeader = TestUtil.createVendorInvoiceHeader(true, vendorId, 'In Progress');
         
        String vendorInvoices = BPUtility.getDecodedString(VendorInvoicingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String addedVendorInvoice = BPUtility.getDecodedString(VendorInvoicingCtrl.addToItemsSubsection(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));

        String finalaizedInvoice =  BPUtility.getDecodedString(VendorInvoicingCtrl.finalizeInvoiceAction(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)))); //Added by Nikhil - 02/03/2017
        VendorInvoicingCtrl.VIHeaderWrapper vendorInvoice = (VendorInvoicingCtrl.VIHeaderWrapper)System.JSON.deserialize(finalaizedInvoice, VendorInvoicingCtrl.VIHeaderWrapper.class);
        

        List<Vendor_Invoicing_Header__c> vendorInvoicingList = [select Vendor__c, Status__c, Invoice_Number__c, Invoice_Date__c from Vendor_Invoicing_Header__c];
        //system.assert(false, vendorInvoicingList );
        
        List<Id> fixedSearchResults = new List<Id>{vendorInvoicingList[0].Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Vendor Invoices'};
        filterWrapper.Status = 'Invoiced';
        //filterWrapper.SearchText = 'co';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        filterWrapper.Vendor_Ordering_Vendor = 'Test Vendor';
        //filterWrapper.Vendor_Ordering_Total = new HomeSearchFilterWrapper.BetweenFilter('1', '8250', null);
  
        String jsonStr = System.Json.serialize(filterWrapper);
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}'))); //Added by Nikhil - 02/03/2017
        HomeSearchResultWrapper.ResultWrapper details1 = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        
        //system.assert(false, details1);
        system.assertEquals(details1.VendorInvoiceRecords[0].Vendor, 'Test Vendor');
         System.assertEquals(true,true);
	}
	
	
	@future
    global static void getFilterRecordsforCustomerInvoices(Id vendorId, Id voHeaderId, Id coHeaderId){
    	   
    	
    	PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        
            //  group all required parts for vendor
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
            // vendor order submitted
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
            // created vendorOrderReceive header
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(vorId), true));
            // Add all lineitem for receiving
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(voLineItems.VendorOrderLineItemGroupList[0].Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
            //  receiving all parts from vendor
            
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        
            // Getting customer order details again
        String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(BPUtility.getEncodedString(coHeaderId)));
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
        system.assertEquals(coHeaderDetails.COInvoiceItemRecs[0].Total, 8250.000);
         
            // adding payments on CO
        String savedCOInvoicePayment = BPUtility.getDecodedString(CustomerOrderCtrl.saveCOInvoicePayment(BPUtility.getEncodedString('[{"ReverseLink":null,"PaymentMethod":"Cash","Amount":"8250.000","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'"}]')));
        
            // Closing invoice
        
        //system.assert(false, coInvoiceList );               //Commented by Nikhil - 02/03/17
        
        List<CO_Header__c> coHeaderList = [select name from CO_Header__c];
        //system.assertEquals(false, coHeaderList );
        
        
        String closedInvoiceAction = CustomerOrderCtrl.closedInvoiceAction(BPUtility.getEncodedString('[{"Total":8250.000,"TaxAmount":null,"Saving":null,"RetailPrice":null,"QtyRequired":null,"Qty":null,"Price":null,"Item":"Service Job 1","IsInvoiceable":true,"IsActive":true,"COLineItemId":null,"COInvoiceItemNumber":null,"COInvoiceItemId":"'+coHeaderDetails.coInvoiceItemRecs[0].COInvoiceItemId+'","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'","$$hashKey":"object:56"}]'), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('Customer'));
        
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Customer Invoices'};
        //filterWrapper.SearchText = 'co';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now().addDays(1)).format('MM/dd/yyyy')));
        filterWrapper.Customer_Sales_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '3000', '15000');
        filterWrapper.Customer_Sales_Customer = 'customerName';
        filterWrapper.Customer_Sales_Total = new HomeSearchFilterWrapper.BetweenFilter('1', '8250', null);
        //filterWrapper.CO_Invoice_Header_Customer_Order = coHeaderList[0].Name ;
        /*filterWrapper.Customer_Order_Payments = new HomeSearchFilterWrapper.BetweenFilter('5', '-55', '15');
        filterWrapper.Customer_Order_Deposits = new HomeSearchFilterWrapper.BetweenFilter('5', '-5', '15');*/
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        List<CO_Invoice_Header__c> coInvoiceList = [select Total_Payment__c, Search_Tag__c, Invoice_Status__c, CO_Header__c from CO_Invoice_Header__c];
        //system.assert(false, coInvoiceList);
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details1 = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details1);
        system.assertEquals(details1.CustomerInvoiceRecords[0].Total, 8250);
        //System.assertEquals(true,true);
    
    
    
    }
    
    @future
    global static void getFilterRecordsforVendorOrders(Id vendorId, Id voHeaderId, Id coHeaderId){
    	
    	PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
            //  group all required parts for vendor
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
            // vendor order submitted
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));

            // created vendorOrderReceive header
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(vorId), true));
            // Add all lineitem for receiving
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(voLineItems.VendorOrderLineItemGroupList[0].Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
            //  receiving all parts from vendor
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        
       
        // Getting customer order details again  - Added by Nikhil 02/03/2017
        String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(BPUtility.getEncodedString(coHeaderId)));
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
       // system.assertEquals(coHeaderDetails.COInvoiceItemRecs[0].Total, 8250.000);
        
        String closedInvoiceAction = CustomerOrderCtrl.closedInvoiceAction(BPUtility.getEncodedString('[{"Total":8250.000,"TaxAmount":null,"Saving":null,"RetailPrice":null,"QtyRequired":null,"Qty":null,"Price":null,"Item":"Service Job 1","IsInvoiceable":true,"IsActive":true,"COLineItemId":null,"COInvoiceItemNumber":null,"COInvoiceItemId":"'+coHeaderDetails.coInvoiceItemRecs[0].COInvoiceItemId+'","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'","$$hashKey":"object:56"}]'), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('Customer')); // - Updated by Nikhil 02/03/2017
        
        
        /*List<Id> fixedSearchResults = new List<Id>{vendorOrderList[0].Id};
        Test.setFixedSearchResults(fixedSearchResults); */     // - NIkhil 02/03/2107
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Vendor Orders'};
        filterWrapper.Status = 'Received';
        //filterWrapper.SearchText = 'co';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        //filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        //filterWrapper.Product_Description = 'details';
        //filterWrapper.Customer_Sales_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '3000', '15000');
        /*filterWrapper.Customer_Sales_Balance_Due = new HomeSearchFilterWrapper.BetweenFilter('1', '0', null);
        filterWrapper.Customer_Order_Payments = new HomeSearchFilterWrapper.BetweenFilter('5', '-55', '15');
        filterWrapper.Customer_Order_Deposits = new HomeSearchFilterWrapper.BetweenFilter('5', '-5', '15');*/
        filterWrapper.Customer_Sales_Customer = 'customerName';
        filterWrapper.Vendor_Ordering_Vendor = 'Test Vendor';
        filterWrapper.Vendor_Ordering_Total = new HomeSearchFilterWrapper.BetweenFilter('1', '1000', null);
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        List<Vendor_Order_Header__c> vendorOrderList = [select In_Progress_VR__c, Status__c, Vendor__c, Total_Recieved__c, Total__c from Vendor_Order_Header__c];
        //system.assert(false, vendorOrderList );
        
        String customerdetails = BPUtility.getDecodedString(HomeSearchCtrl.getFilteredRecords(BPUtility.getEncodedString(jsonStr), BPUtility.getEncodedString('{"ChangesCount":1,"CurrentPage":1,"PageSize":50,"Sorting":[{"FieldName":"LastModifiedDate","SortDirection":"DESC"}]}')));
        HomeSearchResultWrapper.ResultWrapper details1 = (HomeSearchResultWrapper.ResultWrapper) System.JSON.deserialize(customerdetails, HomeSearchResultWrapper.ResultWrapper.class);
        //system.assert(false, details1);
        system.assertEquals(details1.VendorOrderRecords[0].Total, 1000);
         System.assertEquals(true,true);
    }
   
   
	@future
    global static void getSummaryTotalforVendorInvoiceTest(Id vendorId, Id voHeaderId, Id coHeaderId, Id partId, Id part2Id ){
    	
    	PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(vorId), true));

        
        
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 10, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String UpdatedItemsSubsection2 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part2Id), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[1].Id), 40, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);

        
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        Vendor_Invoicing_Header__c viHeader = TestUtil.createVendorInvoiceHeader(true, vendorId, 'In Progress');
         
        String vendorInvoices = BPUtility.getDecodedString(VendorInvoicingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String addedVendorInvoice = BPUtility.getDecodedString(VendorInvoicingCtrl.addToItemsSubsection(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        String finalaizedInvoice = BPUtility.getDecodedString(VendorInvoicingCtrl.finalizeInvoiceAction(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        //VendorInvoicingCtrl.VIHeaderWrapper vendorInvoice = (VendorInvoicingCtrl.VIHeaderWrapper)System.JSON.deserialize(finalaizedInvoice, VendorInvoicingCtrl.VIHeaderWrapper.class);
        
        List<Vendor_Invoicing_Header__c> vendorInvoicingList = [select Vendor__c, Status__c, Invoice_Number__c, Invoice_Date__c, Total__c from Vendor_Invoicing_Header__c];
        //system.assert(false, vendorInvoicingList );
        
        List<Vendor_Order_Line_Item__c> voliList = [select Qty_Needed__c, Received__c, Cost__c from Vendor_Order_Line_Item__c];
        //system.assert(false, voliList);
        
        List<Id> fixedSearchResults = new List<Id>{vendorInvoicingList[0].Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Vendor Invoices'};
        filterWrapper.Status = 'Invoiced';
        //filterWrapper.SearchText = 'co';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/yyyy')), ((DateTime.now()).format('MM/dd/yyyy')));
        filterWrapper.Vendor_Ordering_Vendor = 'Test Vendor';
        //filterWrapper.Vendor_Ordering_Total = new HomeSearchFilterWrapper.BetweenFilter('1', '8250', null);
  
        String jsonStr = System.Json.serialize(filterWrapper);
        
        String reportData = BPUtility.getDecodedString(HomeSearchCtrl.getReportingRecords(BPUtility.getEncodedString(System.Json.serialize(filterWrapper)))); //Added by Nikhil - 02/03/2017
        List<HomeSearchReportResultWrapper> details1 = (List<HomeSearchReportResultWrapper>) System.JSON.deserialize(reportData, List<HomeSearchReportResultWrapper>.class);
        //system.assert(false, details1 );
        system.assertEquals(details1[1].TotalValue, 400000.0);
         System.assertEquals(true,true);
        
    }
        
    @future
    global static void cancelOrderOfItemTestB(Id vendorId, Id voHeaderId, Id coHeaderId, Id partId, Id part2Id ){
        
    	VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
       	VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        //system.assert(false, voLineItems);
       
       String cancelItem = BPUtility.getDecodedString(VendorOrderCtrl.cancelOrderOfItem(BPUtility.getEncodedString(voLineItems.VendorOrderLineItemGroupList[0].Id), BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voLineItems.VendorOrderHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));       
   	   Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendorId, 'In Progress');
       Id vorId = Id.valueOf(BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorId),BPUtility.getEncodedString(null))));
       String VendorOrderReceiveItems = VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeaderId),BPUtility.getEncodedString(vorId), true);
       String allLineItems = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId),BPUtility.getEncodedString(voHeaderId),BPUtility.getEncodedString(null),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
       String commitLineItems = VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId));
   	
		List<Part__c> partList4 = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
       	system.assertEquals(partList4[0].Qty_On_Order__c, 0);
       
       List<Vendor_Order_Header__c> voHeader1 = [select Status__c from Vendor_Order_Header__c limit 100];
       system.assertEquals(voHeader1[0].Status__c, 'Received');
    }
    
    
     //Added by Nikhil 27-04-2017   
    @future
    global static void deleteVendorOrderInvoicingTest_partial(Id vorId,Id vendorId,Id partId,Id vrhId){
    	
    	PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
    	
    	String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        Vendor_Invoicing_Header__c viHeader = TestUtil.createVendorInvoiceHeader(true, vendorId, 'In Progress');
         
        String vendorInvoices = BPUtility.getDecodedString(VendorInvoicingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String updatedVIHeader = BPUtility.getDecodedString(VendorInvoicingCtrl.updateVIHeader(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString('123456'), BPUtility.getEncodedString('09/19/2015'), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String partInfo = BPUtility.getDecodedString(VendorInvoicingCtrl.getPartByPartId(BPUtility.getEncodedString(partId)));
        String popupDetails = BPUtility.getDecodedString(VendorInvoicingCtrl.getVRDetailForPopUp(BPUtility.getEncodedString(vrhId)));
        VendorInvoicingCtrl.VRInPopUp popupDetails1 = (VendorInvoicingCtrl.VRInPopUp) System.JSON.deserialize(popupDetails, VendorInvoicingCtrl.VRInPopUp.class);
        system.assertEquals(popupDetails1.status , 'In Progress');
        String videtails = BPUtility.getDecodedString(VendorInvoicingCtrl.deleteVendorOrderInvoicing(BPUtility.getEncodedString(viHeader.id)));
        List<Vendor_Invoicing_Header__c> VIHDetails = [select Id from Vendor_Invoicing_Header__c limit 100];
        system.assertEquals(VIHDetails.size(), 0);
    
    
    }
        
     //Added by Nikhil 27-04-2017   
    @future
    global static void finalizeInvoiceActionTest_partial(Id vorId,Id vendorId,Id partId, Id part2Id,Id voHeaderId){
    	
    	PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
    
    	String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 10, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String UpdatedItemsSubsection2 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part2Id), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[1].Id), 40, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);

        
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        Vendor_Invoicing_Header__c viHeader = TestUtil.createVendorInvoiceHeader(true, vendorId, 'In Progress');
         
        String vendorInvoices = BPUtility.getDecodedString(VendorInvoicingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String addedVendorInvoice = BPUtility.getDecodedString(VendorInvoicingCtrl.addToItemsSubsection(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
       
        String finalaizedInvoice = BPUtility.getDecodedString(VendorInvoicingCtrl.finalizeInvoiceAction(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        //system.assert(false,finalaizedInvoice);
       
        //String finalaizedInvoice = VendorInvoicingCtrl.finalizeInvoiceAction(viHeader.Id, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        VendorInvoicingCtrl.VIHeaderWrapper vendorInvoice = (VendorInvoicingCtrl.VIHeaderWrapper)System.JSON.deserialize(finalaizedInvoice, VendorInvoicingCtrl.VIHeaderWrapper.class);
       	VendorInvoicingCtrl.VIGroup vendorInvoice1 = (VendorInvoicingCtrl.VIGroup)System.JSON.deserialize(finalaizedInvoice, VendorInvoicingCtrl.VIGroup.class);
       	
        //system.assert(false, vendorInvoice);
        system.assertEquals(vendorInvoice.VIGroupList[0].ReceivingQty, 10.000);
        system.assertEquals(vendorInvoice.VIHeaderRec[0].Status, 'Invoiced');
        
        /*system.assertEquals(vendorInvoice.VRHeaderList[0].TotalCost, 2080000.000000);
        system.assertEquals(vendorInvoice.VRHeaderList[0].TotalNumberOfLineItems, 2);
        system.assertEquals(vendorInvoice.totalVendorOrderInvoicing, 1);
        system.assertEquals(vendorInvoice.VIGroupList[0].ReceivingQty, 10.000);
        system.assertEquals(vendorInvoice.VIGroupList[1].ReceivingQty, 40.000);
        system.assertEquals(vendorInvoice.VIHeaderRec[0].Status, 'Invoiced');
        */
        List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c,Last_Cost__c, Qty_On_Order__c from Part__c limit 100];
    	system.assertEquals((partList[0].Last_Cost__c).setScale(2), 363.64);
    
    
    
    }
      //Added by Nikhil 27-04-2017   
    @future
    global static void removeFromItemSubSectionTest_partial(Id vorId,Id vendorId,Id partId, Id part2Id,Id voHeaderId){
    	
    	 PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
    
    	String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 10, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String UpdatedItemsSubsection2 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part2Id), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[1].Id), 40, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        Vendor_Invoicing_Header__c viHeader = TestUtil.createVendorInvoiceHeader(true, vendorId, 'In Progress');
        
        String vendorInvoices = BPUtility.getDecodedString(VendorInvoicingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String addedVendorInvoice = BPUtility.getDecodedString(VendorInvoicingCtrl.addToItemsSubsection(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String removeVendorInvoices = BPUtility.getDecodedString(VendorInvoicingCtrl.removeFromItemSubSection(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        //String finalaizedInvoice = VendorInvoicingCtrl.finalizeInvoiceAction(viHeader.Id, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        VendorInvoicingCtrl.VIHeaderWrapper vendorInvoice = (VendorInvoicingCtrl.VIHeaderWrapper)System.JSON.deserialize(removeVendorInvoices, VendorInvoicingCtrl.VIHeaderWrapper.class);
       	//VendorInvoicingCtrl.VIGroup vendorInvoice1 = (VendorInvoicingCtrl.VIGroup)System.JSON.deserialize(finalaizedInvoice, VendorInvoicingCtrl.VIGroup.class);
        //system.assert(false, vendorInvoice);
        system.assertEquals(vendorInvoice.ItemsTotal, 0);
    
    
    }
    
    //Added by Nikhil - 09/05/2017
    @future
    global static void resolvedFulfillmentForNewAddInMerchTest_partial(Id coHeaderId,Id customerOwnedUnitId, Id testPart1Id, Id testPart2Id){
    	
    	CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeaderId));
    	 List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeaderId];
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnitId),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 2;
        optionAndFeeRec1.PartId = testPart1Id;
        optionAndFeeRec1.IsInstall = false; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeaderId)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
         //Test.startTest();
        system.assertEquals(1, DealFulfillmentSectionObj.DealMerchandiseList.size()); 
        CO_Line_Item__c coliRec = new CO_Line_Item__c(Part__c = testPart2Id, Qty__c = 10, Price__c = 100);
        COLineItem coli = new COLineItem(coliRec);
        coli.DealId = dealList[0].Id;
        coli.Price = 100;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveCOLineItem(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(System.JSON.serialize(new List<COLineItem>{coli}))));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);  
        
        system.assertEquals(1, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        system.assertEquals(testPart2Id, dealWrapperObj.DealUnresolvedFulfillmentList[0].partId);
        system.assertEquals('Add to Deal', dealWrapperObj.DealUnresolvedFulfillmentList[0].ActionRequired);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.resolveFulfillment(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealWrapperObj.DealUnresolvedFulfillmentList[0])),BPUtility.getEncodedString('Do Not Invoice'), BPUtility.getEncodedString(customerOwnedUnitId)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        //Test.stopTest();
        
        system.assertEquals(0, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        system.assertEquals(2, dealWrapperObj.UnitList[0].OptionAndFeeList.size());
    
    
    }
    
    //Added by Nikhil - 09/05/2017
    @future
    global static void resolvedFulfillmentForUpdateInMerchTest_partial(Id coHeaderId, Id customerOwnedUnitId, Id testPart1Id){
    	
    	CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeaderId));
        
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeaderId];
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnitId),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 1;
        optionAndFeeRec1.PartId = testPart1Id;
        optionAndFeeRec1.IsInstall = false; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0; 
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);

        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeaderId)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        
        system.assertEquals(1, DealFulfillmentSectionObj.DealMerchandiseList.size()); 
        system.assertEquals(1, DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList[0].Qty); 
        DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList[0].Qty = 4;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveCOLineItem(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(System.JSON.serialize(DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList))));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        system.assertEquals(1, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        system.assertEquals(testPart1Id, dealWrapperObj.DealUnresolvedFulfillmentList[0].partId);
        system.assertEquals(4, dealWrapperObj.DealUnresolvedFulfillmentList[0].UpdatedQty);
        system.assertEquals('Update Deal', dealWrapperObj.DealUnresolvedFulfillmentList[0].ActionRequired);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.resolveFulfillment(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealWrapperObj.DealUnresolvedFulfillmentList[0])),BPUtility.getEncodedString('Invoice'), BPUtility.getEncodedString(customerOwnedUnitId)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        system.assertEquals(0, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        system.assertEquals(1, dealWrapperObj.UnitList[0].DealKitHeaderList[0].OptionAndFeeList.size());
        system.assertEquals(4, dealWrapperObj.UnitList[0].OptionAndFeeList[0].Qty);    	    	    	    	    	    	
    }
       
    @future
    global static void vendorRecevingStatus_Partial(Id vorId,Id part2Id, Id voHeaderId,String similarlineitem, Id VendorOrderLineItemGroupListId, Id Vendor){
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        List<Vendor_Order_Line_Item__c> voliList = [select Qty_Needed__c from Vendor_Order_Line_Item__c];
        system.assertEquals(1, voliList.size());
        system.assertEquals(20, voliList[0].Qty_Needed__c);
        
        String allLineItems = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId),BPUtility.getEncodedString(voHeaderId),BPUtility.getEncodedString(null),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(BPUtility.getDecodedString(allLineItems), VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part2Id),BPUtility.getEncodedString(voLineReceiveItems.VORGroupList[0].Id), 10, 30, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
        String commitLineItems = VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId));
        
        List<Vendor_Receiving_Header__c> vendorReceivingList = [Select Id,Name,Status__c,Vendor__c,Receiving_Total__c, Finalized_Date__c from Vendor_Receiving_Header__c];
        system.assertEquals(vendorReceivingList[0].Status__c,'Stocked'); 
        system.assertEquals(vendorReceivingList[0].Finalized_Date__c,system.today()); 
        
        voliList = [select Qty_Needed__c, Line_Item_Cost__c, Vendor_Order_Header__c, Vendor_Order_Header__r.Status__c, Is_Received__c, Vendor_Order_Line_Item_Group__c, Vendor_Order_Line_Item_Group__r.Cost__c, Received__c, Status__c, CO_Line_Item__r.Qty__c, CO_Line_Item__r.Qty_Committed__c, CO_Line_Item__r.Status__c, Part__r.Last_Cost__c, Part__r.Qty_On_Order__c, Part__r.Qty_In_Stock__c, Part__r.Last_Stocked__c from Vendor_Order_Line_Item__c Order By CreatedDate ASC];
        system.assertEquals(2, voliList.size());
        system.assertEquals(30, voliList[0].Part__r.Last_Cost__c);	//not updating
        system.assertEquals(110, voliList[0].Part__r.Qty_In_Stock__c);	//not updating
        system.assertEquals(0, voliList[0].Part__r.Qty_On_Order__c);
        system.assertEquals(110, voliList[0].CO_Line_Item__r.Qty_Committed__c);
        system.assertEquals('Ordered', voliList[0].CO_Line_Item__r.Status__c);
        
        system.assertEquals(20, voliList[0].Vendor_Order_Line_Item_Group__r.Cost__c);
        
        system.assertEquals(10, voliList[0].Qty_Needed__c);
        system.assertEquals(10, voliList[1].Qty_Needed__c);
        
        system.assertEquals(10, voliList[0].Received__c);
        system.assertEquals(0, voliList[1].Received__c);
        
        system.assertEquals(true, voliList[0].Is_Received__c && !voliList[1].Is_Received__c);
        
        system.assertEquals('Received', voliList[0].Status__c);
        system.assertEquals('Ordered', voliList[1].Status__c);
        
        system.assertEquals(30, voliList[0].Line_Item_Cost__c);
        system.assertEquals(10, voliList[1].Line_Item_Cost__c);
        
        system.assertEquals(voliList[0].Vendor_Order_Header__c, voliList[1].Vendor_Order_Header__c);
        system.assertEquals(voliList[0].Vendor_Order_Line_Item_Group__c, voliList[1].Vendor_Order_Line_Item_Group__c);
        
        DateTime lastStocked = voliList[0].Part__r.Last_Stocked__c;
		Date actual = date.newinstance(lastStocked.year(), lastStocked.month(), lastStocked.day());
		
		DateTime stockedDate = System.now();
		Date expected = date.newinstance(stockedDate.year(), stockedDate.month(), stockedDate.day());
		system.assertEquals(expected, actual);
		
		system.assertEquals('Partially Received', voliList[0].Vendor_Order_Header__r.Status__c);
        List<Vendor_Order_Header__c> vendorOrderUpdatedList = [Select Id,Name,Purchase_Order_Type__c,Status__c,Total_Recieved__c,Total__c from Vendor_Order_Header__c limit 10];  
        system.assertEquals(vendorOrderUpdatedList[0].Status__c,'Partially Received');
        
        //2nd Order
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(false, vendor, 'In Progress');
        Id vor1Id = Id.valueOf(BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor),BPUtility.getEncodedString(null))));
        String VendorOrderReceiveItems1 = VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeaderId),BPUtility.getEncodedString(vor1Id), true);
        
        String allLineItems1 = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vor1Id),BPUtility.getEncodedString(voHeaderId),BPUtility.getEncodedString(null),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems11 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(BPUtility.getDecodedString(allLineItems1), VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection1 = VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(part2Id),BPUtility.getEncodedString(voLineReceiveItems11.VORGroupList[0].Id), 10, 50, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
		String commitLineItems1 = VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vor1Id));
		List<Vendor_Order_Header__c> vendorOrderUpdatedList1 = [Select Id,Name,Purchase_Order_Type__c,Status__c,Total_Recieved__c,Total__c from Vendor_Order_Header__c limit 10];  
        system.assertEquals(vendorOrderUpdatedList1[0].Status__c,'Received');
        system.assertEquals(vendorOrderUpdatedList1[0].Total__c,800);
        
        voliList = [select Qty_Needed__c, Received__c, Status__c, CO_Line_Item__r.Qty__c, Vendor_Order_Line_Item_Group__r.Cost__c, Vendor_Order_Header__r.Status__c,  CO_Line_Item__r.Qty_Committed__c, CO_Line_Item__r.Status__c, Part__r.Last_Cost__c, Part__r.Qty_On_Order__c, Part__r.Qty_In_Stock__c, Part__r.Last_Stocked__c from Vendor_Order_Line_Item__c];
        system.assertEquals(2, voliList.size());
        system.assertEquals(50, voliList[0].Part__r.Last_Cost__c);
        system.assertEquals(120, voliList[0].Part__r.Qty_In_Stock__c);
        system.assertEquals(0, voliList[0].Part__r.Qty_On_Order__c);
        system.assertEquals('Received', voliList[0].Status__c);
        system.assertEquals(10, voliList[0].Received__c);
        system.assertEquals(120, voliList[0].CO_Line_Item__r.Qty_Committed__c);
        system.assertEquals('In Stock', voliList[0].CO_Line_Item__r.Status__c);
        
        system.assertEquals('Received', voliList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(40, voliList[0].Vendor_Order_Line_Item_Group__r.Cost__c);
        
        lastStocked = voliList[0].Part__r.Last_Stocked__c;
		actual = date.newinstance(lastStocked.year(), lastStocked.month(), lastStocked.day());
		
        system.assertEquals(actual, expected);
        
        system.assertEquals(50, voliList[1].Part__r.Last_Cost__c);
        system.assertEquals(120, voliList[1].Part__r.Qty_In_Stock__c);
        system.assertEquals(0, voliList[1].Part__r.Qty_On_Order__c);
        system.assertEquals('Received', voliList[1].Status__c);
        system.assertEquals(10, voliList[1].Received__c);
        
        lastStocked = voliList[1].Part__r.Last_Stocked__c;
		actual = date.newinstance(lastStocked.year(), lastStocked.month(), lastStocked.day());
		
        system.assertEquals(actual, expected);
        
        List<Part_FIFO_Bucket__c> fifoBucketList = [select Is_FIFO_Bucket__c, Remaining_Qty__c, Total__c, Part__r.Qty_In_Stock__c, Part__r.Average_Cost__c from Part_FIFO_Bucket__c Order By CreatedDate ASC];
        system.assertEquals(3, fifoBucketList.size());
        system.assertEquals(true, fifoBucketList[0].Is_FIFO_Bucket__c && fifoBucketList[1].Is_FIFO_Bucket__c && fifoBucketList[2].Is_FIFO_Bucket__c);
        system.assertEquals(fifoBucketList[0].Part__r.Qty_In_Stock__c, fifoBucketList[0].Remaining_Qty__c + fifoBucketList[1].Remaining_Qty__c + fifoBucketList[2].Remaining_Qty__c);
        system.assertEquals(100, fifoBucketList[0].Remaining_Qty__c);
        system.assertEquals(10, fifoBucketList[1].Remaining_Qty__c);
        system.assertEquals(10, fifoBucketList[2].Remaining_Qty__c);
        
        Decimal expectedTotal = (100 * 10) + (10 * 30) + (10 * 50);
        system.assertEquals(expectedTotal, fifoBucketList[0].Total__c + fifoBucketList[1].Total__c + fifoBucketList[2].Total__c);
        system.assertEquals(fifoBucketList[0].Part__r.Average_Cost__c, expectedTotal / fifoBucketList[0].Part__r.Qty_In_Stock__c);
        
    }
    
    @future
    global static void vendorRecevingStatus_Partial2(Id vorId,Id partId, Id voHeaderId,String similarlineitem, Id VendorOrderLineItemGroupListId, Id Vendor){
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        List<Vendor_Order_Line_Item__c> voliList = [select Qty_Needed__c from Vendor_Order_Line_Item__c Order By Is_required_For_Customer__c];
        system.assertEquals(2, voliList.size());
        system.assertEquals(20, voliList[0].Qty_Needed__c);
        system.assertEquals(20, voliList[1].Qty_Needed__c);
        
        String allLineItems = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId),BPUtility.getEncodedString(voHeaderId),BPUtility.getEncodedString(null),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(BPUtility.getDecodedString(allLineItems), VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId),BPUtility.getEncodedString(voLineReceiveItems.VORGroupList[0].Id), 3, 10, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
        String commitLineItems = VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId));
        
        List<Vendor_Receiving_Header__c> vendorReceivingList = [Select Id,Name,Status__c,Vendor__c,Receiving_Total__c, Finalized_Date__c from Vendor_Receiving_Header__c];
        system.assertEquals(vendorReceivingList[0].Status__c,'Stocked'); 
        system.assertEquals(vendorReceivingList[0].Finalized_Date__c,system.today()); 
        
        voliList = [select Qty_Needed__c, Line_Item_Cost__c, Vendor_Order_Header__c, Is_required_For_Customer__c, Vendor_Order_Header__r.Status__c, Is_Received__c, Vendor_Order_Line_Item_Group__c, Vendor_Order_Line_Item_Group__r.Cost__c, Received__c, Status__c, CO_Line_Item__r.Qty__c, CO_Line_Item__r.Qty_Committed__c, CO_Line_Item__r.Status__c, Part__r.Last_Cost__c, Part__r.Package_Cost__c, Part__r.Qty_On_Order__c, Part__r.Qty_In_Stock__c, Part__r.Last_Stocked__c from Vendor_Order_Line_Item__c Order By Is_required_For_Customer__c, CreatedDate ASC];
        system.assertEquals(3, voliList.size());
        system.assertEquals(10, voliList[0].Part__r.Package_Cost__c);	
        system.assertEquals(1, voliList[0].Part__r.Last_Cost__c);	
        system.assertEquals(130, voliList[0].Part__r.Qty_In_Stock__c);	
        system.assertEquals(10, voliList[0].Part__r.Qty_On_Order__c);
        system.assertEquals(120, voliList[2].CO_Line_Item__r.Qty_Committed__c); 
        
        system.assertEquals(false, voliList[0].Is_required_For_Customer__c);
        system.assertEquals(false, voliList[1].Is_required_For_Customer__c);
        system.assertEquals(true, voliList[2].Is_required_For_Customer__c);
        
        system.assertEquals(25.75, voliList[0].Vendor_Order_Line_Item_Group__r.Cost__c);
        
        system.assertEquals(10, voliList[0].Qty_Needed__c);
        system.assertEquals(10, voliList[1].Qty_Needed__c);
        system.assertEquals(20, voliList[2].Qty_Needed__c);
        
        system.assertEquals(10, voliList[0].Received__c);
        system.assertEquals(0, voliList[1].Received__c);
        system.assertEquals(20, voliList[2].Received__c);
        
        system.assertEquals(true, voliList[0].Is_Received__c && !voliList[1].Is_Received__c && voliList[2].Is_Received__c);
        
        system.assertEquals('Received', voliList[0].Status__c);
        system.assertEquals('Ordered', voliList[1].Status__c);
        system.assertEquals('Received', voliList[2].Status__c);
        
        system.assertEquals(1, voliList[0].Line_Item_Cost__c);
        system.assertEquals(100, voliList[1].Line_Item_Cost__c);
        system.assertEquals(1, voliList[2].Line_Item_Cost__c);
        
        system.assertEquals(voliList[0].Vendor_Order_Header__c, voliList[1].Vendor_Order_Header__c);
        system.assertEquals(voliList[0].Vendor_Order_Line_Item_Group__c, voliList[1].Vendor_Order_Line_Item_Group__c);
        
        DateTime lastStocked = voliList[0].Part__r.Last_Stocked__c;
		Date actual = date.newinstance(lastStocked.year(), lastStocked.month(), lastStocked.day());
		
		DateTime stockedDate = System.now();
		Date expected = date.newinstance(stockedDate.year(), stockedDate.month(), stockedDate.day());
		
		system.assertEquals(expected, actual);
		
		lastStocked = voliList[2].Part__r.Last_Stocked__c;
		actual = date.newinstance(lastStocked.year(), lastStocked.month(), lastStocked.day());
		system.assertEquals(expected, actual);
		
		system.assertEquals('Partially Received', voliList[0].Vendor_Order_Header__r.Status__c);
        
        //2nd Order
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(false, vendor, 'In Progress');
        Id vor1Id = Id.valueOf(BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor),BPUtility.getEncodedString(null))));
        String VendorOrderReceiveItems1 = VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeaderId),BPUtility.getEncodedString(vor1Id), true);
        
        String allLineItems1 = VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vor1Id),BPUtility.getEncodedString(voHeaderId),BPUtility.getEncodedString(null),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)),BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems11 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(BPUtility.getDecodedString(allLineItems1), VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection1 = VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vor1Id), BPUtility.getEncodedString(partId),BPUtility.getEncodedString(voLineReceiveItems11.VORGroupList[0].Id), 1, 2, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
		ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
		String commitLineItems1 = VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vor1Id));
		List<Vendor_Order_Header__c> vendorOrderUpdatedList1 = [Select Id,Name,Purchase_Order_Type__c,Status__c,Total_Recieved__c,Total__c from Vendor_Order_Header__c limit 10];  
        system.assertEquals(vendorOrderUpdatedList1[0].Status__c, 'Received');
        system.assertEquals(vendorOrderUpdatedList1[0].Total__c, 32);
        
        voliList = [select Qty_Needed__c, Received__c, Status__c, CO_Line_Item__r.Qty__c, Vendor_Order_Line_Item_Group__r.Cost__c, Vendor_Order_Header__r.Status__c,  CO_Line_Item__r.Qty_Committed__c, CO_Line_Item__r.Status__c, Part__r.Last_Cost__c, Part__r.Package_Cost__c, Part__r.Qty_On_Order__c, Part__r.Qty_In_Stock__c, Part__r.Last_Stocked__c from Vendor_Order_Line_Item__c Order By Is_required_For_Customer__c, CreatedDate ASC];
        system.assertEquals(3, voliList.size());
        system.assertEquals(2, voliList[0].Part__r.Package_Cost__c);
        system.assertEquals(0.2, voliList[0].Part__r.Last_Cost__c);
        system.assertEquals(140, voliList[0].Part__r.Qty_In_Stock__c);
        system.assertEquals(0, voliList[0].Part__r.Qty_On_Order__c);
        
        system.assertEquals('Received', voliList[0].Status__c);
        system.assertEquals('Received', voliList[1].Status__c);
        system.assertEquals('Received', voliList[2].Status__c);
        
        system.assertEquals(10, voliList[0].Received__c);
        system.assertEquals(10, voliList[1].Received__c);
        system.assertEquals(20, voliList[2].Received__c);
        
        system.assertEquals(120, voliList[2].CO_Line_Item__r.Qty_Committed__c);
        system.assertEquals('In Stock', voliList[2].CO_Line_Item__r.Status__c);
        
        system.assertEquals('Received', voliList[0].Vendor_Order_Header__r.Status__c);
        system.assertEquals(0.8, voliList[0].Vendor_Order_Line_Item_Group__r.Cost__c);
        
        stockedDate = voliList[1].Part__r.Last_Stocked__c;
		actual = date.newinstance(stockedDate.year(), stockedDate.month(), stockedDate.day());
		
        system.assertEquals(expected, actual);
        
        List<Part_FIFO_Bucket__c> fifoBucketList = [select Is_FIFO_Bucket__c, Remaining_Qty__c, Total__c, Part__r.Qty_In_Stock__c, Part__r.Average_Cost__c from Part_FIFO_Bucket__c Order By CreatedDate ASC];
        system.assertEquals(3, fifoBucketList.size());
        system.assertEquals(true, fifoBucketList[0].Is_FIFO_Bucket__c && fifoBucketList[1].Is_FIFO_Bucket__c && fifoBucketList[2].Is_FIFO_Bucket__c);
        system.assertEquals(fifoBucketList[0].Part__r.Qty_In_Stock__c, fifoBucketList[0].Remaining_Qty__c + fifoBucketList[1].Remaining_Qty__c + fifoBucketList[2].Remaining_Qty__c);
        system.assertEquals(100, fifoBucketList[0].Remaining_Qty__c);
        system.assertEquals(30, fifoBucketList[1].Remaining_Qty__c);
        system.assertEquals(10, fifoBucketList[2].Remaining_Qty__c);
        
        Decimal expectedTotal = (100 * 100) + (30 * 1) + (10 * 0.2);
        system.assertEquals(expectedTotal, fifoBucketList[0].Total__c + fifoBucketList[1].Total__c + fifoBucketList[2].Total__c);
        system.assertEquals(fifoBucketList[0].Part__r.Average_Cost__c, expectedTotal / fifoBucketList[0].Part__r.Qty_In_Stock__c);
    }
       
    //Added by Nikhil - 23/05/2017
    @future
    global static void RecalculationLogicOnAddingFixedKitlineitemToSOTest_partial(Id coHeaderId, Id kitHeaderId,Id customerId){
    	
    	 String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeaderId)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeaderId), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(customerId)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.FixedPrice, 124.000);
        System.assertEquals(SOHeaderDetails1.contains('100'), true);
        System.assertEquals(SOHeaderDetails1.contains('120'), false);
        
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].KitPrice = 130;

        String updatedSOKH = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeaderId)));
        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
        
        //System.assertEquals(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.FixedPrice, 230);
        //system.assert(false, soHeaderDetailsObj2 );
        system.assertEquals(SOHeaderDetails2.contains('130'), true);
        //system.assertEquals(SOHeaderDetails2.contains('100'), true);
    	
    }
    
      //Added by Nikhil - 24/05/2017
    @future
    global static void moveKitItemFromOneServiceOrderToAnother_partial(Id coHeaderId,string SOHeaderDetails,Id kitHeaderId,Id customerId ){
    	
    	 SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeaderId), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(customerId)));
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeaderId)));
        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
         
        //system.assert(false, soHeaderDetailsObj2 );
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded, 50.00);
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
    	
    	List<Service_Order_Line_Item__c> SOli = [select Id, Qty_Committed__c, Fixed_Price__c, Total__c from Service_Order_Line_Item__c limit 100];
        system.assertEquals(SOli.size(), 1);
        
        String soHeader11 = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeaderId)));
        String SOHeaderDetails11 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj11 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails11, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj11.SOList[1].SOHeaderInfo.Name, 'Service Job 2');
        
        
        String movedLineItem = BPUtility.getDecodedString(CustomerOrderCtrl.moveLineItem(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(soHeaderDetailsObj11.SOList[1].SOHeaderInfo.Id), BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.Id), BPUtility.getEncodedString(coHeaderId)));
        SOHeaderWrapper SOHeaderDetails22 = (SOHeaderWrapper) System.JSON.deserialize(movedLineItem, SOHeaderWrapper.class);
        
       
        String SOHeaderDetails23 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj24 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails23, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj24 );
        system.assertEquals(soHeaderDetailsObj24.SOList[1].SOHeaderInfo.Total, 5000);
        List<Service_Order_Line_Item__c> SOli1 = [select Id, Qty_Committed__c, Fixed_Price__c, Total__c from Service_Order_Line_Item__c limit 100];
        system.assertEquals(SOli1.size(), 1);      
    }
    
    @future
    global static void serviceJobSearchFutureTest(Id coHeaderId){
    	//SOHeaderWrapper.SOHeader soHeaderObj = new SOHeaderWrapper.SOHeader();
        List<CO_Invoice_Item__c> COInvoiceItems = [select Category__c, CO_Line_Item__c, isActive__c, Item_Category_Code__c, Item_ID__c, Item_Type__c, Price__c, Qty__c from CO_Invoice_Item__c];
        List<CO_Invoice_Header__c> coInvoiceHeaders = new List<CO_Invoice_Header__c>();
        coInvoiceHeaders = SOQLUtil.getCOInvoiceHeaderByCOHeaderId(coHeaderId);
        String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaders[0].Id)));
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedorderAction(BPUtility.getEncodedString(COInvoiceItemJSON), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('Internal')));
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(closedOrder, COHeaderWrapper.class);
        
        List<Service_Order_Header__c> serviceOrderHeaderList = [select Status__c, Total_Parts__c, Work_Status__c  from Service_Order_Header__c];
        //system.assert(false, serviceOrderHeaderList );
        List<Id> fixedSearchResults = new List<Id>{serviceOrderHeaderList[0].Id};
        Test.setFixedSearchResults(fixedSearchResults);
        
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        filterWrapper.Type.objects = new Set<String>{'Service Jobs'};
        //filterWrapper.Status = 'In Progress';
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
  
        String jsonStr = System.Json.serialize(filterWrapper);
        String reportData = BPUtility.getDecodedString(HomeSearchCtrl.getReportingRecords(BPUtility.getEncodedString(System.Json.serialize(filterWrapper))));
        List<HomeSearchReportResultWrapper> details1 = (List<HomeSearchReportResultWrapper>) System.JSON.deserialize(reportData, List<HomeSearchReportResultWrapper>.class);
        //system.assert(false, details1);
        system.assertEquals(details1[0].TotalValue, 1);
        system.assertEquals(details1[1].TotalValue, 255);
    }
    
    @future
    global static void DealLineItemStatusAfterCloseOrderTest_Partial(Id dealList1Id){
    	String dealdeposite = BPUtility.getDecodedString(CustomerOrderCtrl.getDealCoDeposits(BPUtility.getEncodedString(dealList1Id)));
        System.assertEquals(dealdeposite.contains(''), true);
    }
    
     @future
	global static void createExcessTestDataAB(Id vendorId, Id vorId, Id voHeaderId, Id partId){
		PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1; 
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        VendorReceivingGroupTriggerHelper.isProcessed = false;
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 2, 8000,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
		
        
		COLineItemTriggerHelper.isTriggerExecute = false;
		COTriggerHelper.isTriggerExecute = false;
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c limit 100];
         
       	List<Vendor_Order_Line_Item__c> voliList = [select Qty_Needed__c, Received__c from Vendor_Order_Line_Item__c limit 100];
       	//system.assert(false, voliList);
       	
        system.assertEquals(partList[0].Qty_In_Stock__c, 144.00);
        system.assertEquals(partList[0].Qty_Committed__c, 144.00);
        system.assertEquals(partList[0].Qty_On_Order__c, 16);
        
        List<CO_Line_Item__c> colineitem12 = [select Part__c, Qty_Committed__c, Qty__c, Status__c from CO_Line_Item__c limit 100];
        //system.assert(false, colineitem12);
        system.assertEquals(colineitem12[0].Qty__c, 150.00);
        system.assertEquals(colineitem12[0].Qty_Committed__c, 144.00);
        
        List<Vendor_Order_Header__c> voHeader12 = [select Status__c, 	Vendor__c from Vendor_Order_Header__c limit 100];
        system.assertEquals(voHeader12[0].Status__c, 'Partially Received');
        
        ActiveOrder.RelatedListPaginationSorting pageSort1 = new ActiveOrder.RelatedListPaginationSorting();
        pageSort1.activeOrdersCurrentPage = 1;
        pageSort1.activeOrdersPageSize = 10;
       	List<ActiveOrder> activeOrders = ActiveOrder.getAllActiveOrdersForPart(partId, System.JSON.serialize(pageSort1));
       //system.assert(false, activeOrders);
       	system.assertEquals(activeOrders[0].Status, 'Partially Received' );
       
       List<Vendor_Order_Line_Item_Group__c> volineItemGroup = [select Status__c, Need__c, Total__c, Unreceived_Qty__c from Vendor_Order_Line_Item_Group__c limit 100];
       system.assertEquals(volineItemGroup[0].Need__c,  66);
       system.assertEquals(volineItemGroup[0].Total__c,  16440.006);
       system.assertEquals(volineItemGroup[0].Unreceived_Qty__c,  22);
       
       
       String cancelItem = BPUtility.getDecodedString(VendorOrderCtrl.cancelOrderOfItem(BPUtility.getEncodedString(volineItemGroup[0].Id), BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeader12[0].Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));

     
		List<Vendor_Order_Header__c> voHeaderList = [select Status__c from Vendor_Order_Header__c Limit 100];
        system.assertEquals(voHeaderList[0].Status__c, 'Received');
        
        List<Vendor_Order_Line_Item__c> voliList1 = [select Qty_Needed__c, Received__c, Status__c, Total_Cost__c, Receiving_Status__c from Vendor_Order_Line_Item__c limit 100];
       	system.assertEquals(voliList1[0].Qty_Needed__c, 44);
       	System.assertEquals(voliList1[0].Received__c, 44);
       	System.assertEquals(voliList1[0].Status__c, 'Received');
       	System.assertEquals(voliList1[0].Receiving_Status__c, 'Stocked');
       	system.assertEquals(voliList1[1].Qty_Needed__c, 6);
       	System.assertEquals(voliList1[1].Received__c, 0);
       	system.assertEquals(voliList1[2].Qty_Needed__c, 200);
       	
	}	
    
          @future 
    global static void deleteOtherChargesTest_Partial(Id vorId,Id partId, Id part2Id,Id VORGroupList0Id,Id VORGroupList1Id,Id vendorId,Id feeId){
    	PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
    	String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(VORGroupList0Id), 10, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
    	String UpdatedItemsSubsection2 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part2Id), BPUtility.getEncodedString(VORGroupList1Id), 40, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
    
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        Vendor_Invoicing_Header__c viHeader = TestUtil.createVendorInvoiceHeader(true, vendorId, 'In Progress');
         
        String vendorInvoices = BPUtility.getDecodedString(VendorInvoicingCtrl.addVendor(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String addedVendorInvoice = BPUtility.getDecodedString(VendorInvoicingCtrl.addToItemsSubsection(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String otherCharges = BPUtility.getDecodedString(VendorInvoicingCtrl.addOtherCharges(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(feeId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        VendorInvoicingCtrl.VIHeaderWrapper viHeaderrObj = (VendorInvoicingCtrl.VIHeaderWrapper) System.JSON.deserialize(otherCharges, VendorInvoicingCtrl.VIHeaderWrapper.class);
        
        system.assertEquals(1,[select count() from other_charges__c Limit 1]);
        
        BPUtility.getDecodedString(VendorInvoicingCtrl.deleteOtherCharges(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(viHeaderrObj.OtherChargesList[0].Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        system.assertEquals(0,[select count() from other_charges__c Limit 1]);
    
    }
    @future 
    global static void getCOInvoiceDetailsTest2_Partial(Id coHeaderId,Id partId,Id feeId,Id cokhRecId,Id testCategoryId,Id coinvoiceHeader1Id,Id deal1Id,Id customerId,Id customerOwnedUnitRecId,Id kitHeaderId){
    	
    	String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeaderId)));
        List<Service_Order_Header__c> soHeaderList = [select Id from Service_Order_Header__c limit 1];
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(partId), BPUtility.getEncodedString(soHeaderList[0].Id), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(customerId)));
        String lineitems2 = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeaderId), BPUtility.getEncodedString(soHeaderList[0].Id), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(customerId)));
        
        soHeaderList[0].Customer_Owned_Unit__c = customerOwnedUnitRecId;  
        soHeaderList[0].SO_Cause__c = 'Cause';
        soHeaderList[0].SO_Correction__c = 'Correction';
        soHeaderList[0].SO_Concern__c = 'Concern';
        update  soHeaderList[0];
        List<Service_Order_Header__c> soHeaderFieldsList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => soHeaderList[0].Id});
       
    	//Create CO line items
        List<CO_Line_Item__c> COLineItemList = new List<CO_Line_Item__c>();
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(false, coHeaderId, partId, -2);
        COLineItemList.add(coLineItemRec1);
        
        CO_Line_Item__c coLineItemRec2 = TestUtil.createCOLineItem(false, coHeaderId, partId, 50);
        coLineItemRec2.CO_Kit_Header__c = cokhRecId;
        COLineItemList.add(coLineItemRec2);
    
        CO_Line_Item__c coLineItemRec3 = TestUtil.createCOLineItem(false, coHeaderId, partId, 50);
        coLineItemRec3.fee__c = feeId;
        COLineItemList.add(coLineItemRec3);
       
        /*Deal__c dealRec = new Deal__c(CO_Header__c = coHeader.Id, Status__c = 'Quotation', Unit_Status__c = 'Temporary');
        insert dealRec;*/
        
        CO_Line_Item__c coLineItemRec4 = TestUtil.createCOLineItem(false, coHeaderId, partId, 50);
        COLineItemList.add(coLineItemRec4);
        
        insert COLineItemList;
    
    	 CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(true, testCategoryId, coinvoiceHeader1Id, coLineItemRec3.Id);
        
        
        CO_Invoice_Item__c coinvoiceitem2 =new CO_Invoice_Item__c();
        coinvoiceitem2.Category__c = testCategoryId;
        coinvoiceitem2.CO_Invoice_Header__c = coinvoiceHeader1Id;
        coinvoiceitem2.CO_Line_Item__c = coLineItemRec4.Id;
        coinvoiceitem2.Deal__c = deal1Id;
        insert coinvoiceitem2;
        //End: Added by Ayushi 12 July
        
        
        //List<CO_Line_Item__c> colineitemList = [select Part__c, Qty_Committed__c, Qty__c, Status__c, Sub_Total_Without_Tax__c, Sub_Total_With_Tax__c from CO_Line_Item__c];
        //system.assert(false, colineitemList);
        
        String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(BPUtility.getEncodedString(coHeaderId)));
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
        //system.assert(false, coHeaderDetails )    ;
        
        String coInvoiceDetails = BPUtility.getDecodedString(PrintCustomerOrderInvoiceCtrl.getCOInvoiceDetailsWithFinalize(BPUtility.getEncodedString(coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId), true)); // Ticket#1984: getCOInvoiceDetails -> getCOInvoiceDetailsWithFinalize: 
                                                                                                                                                                                         //Changed By Pooja 3 May 2017
        PrintCustomerOrderInvoiceCtrl.CustomerOrderInvoiceDetail coHeaderDetails11 = (PrintCustomerOrderInvoiceCtrl.CustomerOrderInvoiceDetail) System.JSON.deserialize(coInvoiceDetails, PrintCustomerOrderInvoiceCtrl.CustomerOrderInvoiceDetail.class);
        system.assertEquals(coHeaderDetails11.COInvoice.CustomerName, 'customerName');
    
    
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