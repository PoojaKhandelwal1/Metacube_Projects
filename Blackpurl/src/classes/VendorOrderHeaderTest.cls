@isTest
private class VendorOrderHeaderTest {

    static testMethod void VendorOrderHeaderTestSortAscending() {
		Account vendor1 = TestUtil.createVendor(true, 'Test Vendor1');
	   	Account vendor2 = TestUtil.createVendor(true, 'Test Vendor2');
	   	VendorOrderHeader vendorOrderHeaderRecord1 = new VendorOrderHeader(TestUtil.createVendorOrderHeader(true, vendor1.Id).id);
	   	VendorOrderHeader vendorOrderHeaderRecord2 = new VendorOrderHeader(TestUtil.createVendorOrderHeader(true, vendor2.Id).id);
	   	List<VendorOrderHeader> vendororderHeaderList = new List<VendorOrderHeader>{vendorOrderHeaderRecord1,vendorOrderHeaderRecord2};
	   	VendorOrderReceivingCtrl.VO_Sort_Order = 'ASC';
	   	Test.startTest();
	   	vendororderHeaderList.sort();
	    Test.stopTest();
	    List<Contact> accList = [select Id, Name from Contact limit 100];
		system.assertEquals(accList.size(), 0);
    }
    
    static testMethod void VendorOrderHeaderTestSortDescending() {
		Account vendor1 = TestUtil.createVendor(true, 'Test Vendor1');
	   	Account vendor2 = TestUtil.createVendor(true, 'Test Vendor2');
	   	VendorOrderHeader vendorOrderHeaderRecord1 = new VendorOrderHeader(TestUtil.createVendorOrderHeader(true, vendor1.Id).id);
	   	VendorOrderHeader vendorOrderHeaderRecord2 = new VendorOrderHeader(TestUtil.createVendorOrderHeader(true, vendor2.Id).id);
	   	List<VendorOrderHeader> vendororderHeaderList = new List<VendorOrderHeader>{vendorOrderHeaderRecord1,vendorOrderHeaderRecord2};
	   	VendorOrderReceivingCtrl.VO_Sort_Order = 'DESC';
	   	Test.startTest();
	   	vendororderHeaderList.sort();
	    Test.stopTest();
	    List<Contact> accList = [select Id, Name from Contact limit 100];
		system.assertEquals(accList.size(), 0);
    }
    
    static testMethod void VendorOrderHeaderTestSort(){
	    Account vendor1 = TestUtil.createVendor(true, 'Test Vendor1');
	   	Account vendor2 = TestUtil.createVendor(true, 'Test Vendor2');
	   	VendorOrderHeader vendorOrderHeaderRecord1 = new VendorOrderHeader(TestUtil.createVendorOrderHeader(true, vendor1.Id).id);
	   	vendorOrderHeaderRecord1.VOName='testVO';
	   	VendorOrderHeader vendorOrderHeaderRecord2 = new VendorOrderHeader(TestUtil.createVendorOrderHeader(true, vendor2.Id).id);
	   	List<VendorOrderHeader> vendororderHeaderList = new List<VendorOrderHeader>{vendorOrderHeaderRecord1,vendorOrderHeaderRecord2};
	   	VendorOrderReceivingCtrl.VO_Sort_Order  = 'DESC';
	   	Test.startTest();
	   	vendororderHeaderList.sort();
	    Test.stopTest();

		system.assertEquals(vendorOrderHeaderRecord1.VendorName, 'Test Vendor1');
    }
    
    static testMethod void VendorOrderHeaderConstructorTest(){
	    Account vendor = TestUtil.createVendor(true, 'Test Vendor1');
	   	PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
	   	Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
	   	voHeader.Ordered_Date__c = Date.Today();
	   	voHeader.Expected_Date__c = Date.Today().addDays(3);
	   	voHeader.Received_Date__c = Date.Today().addDays(4);
	   	insert voHeader;
	   		   		   		   	
	   	List<Vendor_Order_Header__c> voHeaderRec = SOQLUtil.getVendorOrderHeaderRecords('Id', voHeader.Id, null, false);
	   	VendorOrderHeader vendorOrderHeaderRecord1 = new VendorOrderHeader(voHeaderRec[0]);
	   	
	   	String JSONString = JSON.serialize(vendorOrderHeaderRecord1);
	   	VendorOrderHeader vendorOrderHeaderObj = VendorOrderHeader.parse(JSONString);
	   	
		system.assertEquals(vendorOrderHeaderObj.VendorName,'Test Vendor1');
    }
    
    static testMethod void populateVendorOrderGroupsTest(){
	    Account vendor = TestUtil.createVendor(true, 'Test Vendor1');
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
	   	Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
	   	voHeader.Ordered_Date__c = Date.Today();
	   	voHeader.Expected_Date__c = Date.Today().addDays(3);
	   	voHeader.Received_Date__c = Date.Today().addDays(4);
	   	insert voHeader;
	   	
	   	Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(false, vendor.Id, 'In Progress');
        Id vorId = Id.valueOf(BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id),BPUtility.getEncodedString(null))));
        String VendorOrderReceiveItems = VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id),BPUtility.getEncodedString(vorId), true);
	      
	   	Vendor_Order_Line_Item_Group__c voliGroup1 = TestUtil.createVendorOrderLineItemGroup(false, voHeader.Id, part.Id);
	   	voliGroup1.Need__c = 3;
	   	voliGroup1.Received_Qty__c = 2;
	   	insert voliGroup1;
	   	 	
	   	List<Vendor_Order_Header__c> voHeaderRec = SOQLUtil.getVendorOrderHeaderRecords('Vendor__c', voHeader.Vendor__c, null, false);
	   	VendorOrderHeader vendorOrderHeaderRecord1 = new VendorOrderHeader(voHeaderRec[0]);
	   	vendorOrderHeaderRecord1.populateVendorOrderGroups(voHeaderRec[0]);
	   	
		system.assertEquals(vendorOrderHeaderRecord1.VendorName, 'Test Vendor1');
    }
    
     static testMethod void populateVendorOrderGroupsTestA(){
	    Account vendor = TestUtil.createVendor(true, 'Test Vendor1');
	    Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
	   	PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
	   	Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
	   	voHeader.Ordered_Date__c = Date.Today();
	   	insert voHeader;
	    Part__c part = TestUtil.createPart(true, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
	   	Vendor_Order_Line_Item_Group__c voliGroup1 = TestUtil.createVendorOrderLineItemGroup(false, voHeader.Id, part.Id);
	   	voliGroup1.Need__c = 3;
	   	voliGroup1.Received_Qty__c = 0;
	   	insert voliGroup1;
	   	 	
	   	List<Vendor_Order_Header__c> voHeaderRec = SOQLUtil.getVendorOrderHeaderRecords('Vendor__c', voHeader.Vendor__c, null, false);
	   	VendorOrderHeader vendorOrderHeaderRecord1 = new VendorOrderHeader(voHeaderRec[0]);
	   	vendorOrderHeaderRecord1.populateVendorOrderGroups(voHeaderRec[0]);
	   	
	    system.assertEquals(vendorOrderHeaderRecord1.VendorName,'Test Vendor1');
    }
    
    static testMethod void populateVendorOrderGroupsTestB(){
	    Account vendor = TestUtil.createVendor(true, 'Test Vendor1');
	    Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = 	TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
    	CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
	   	PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
	   	Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
	   	voHeader.Ordered_Date__c = Date.Today();
	   	insert voHeader;
	   
	   	Part__c part = TestUtil.createPart(true, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
	   	Vendor_Order_Line_Item_Group__c voliGroup1 = TestUtil.createVendorOrderLineItemGroup(false, voHeader.Id, part.Id);
	   	voliGroup1.Need__c = 3;
	   	voliGroup1.Received_Qty__c = 4;
	   	insert voliGroup1;
	   	 	
	   	List<Vendor_Order_Header__c> voHeaderRec = SOQLUtil.getVendorOrderHeaderRecords('Vendor__c', voHeader.Vendor__c, null, false);
	   	VendorOrderHeader vendorOrderHeaderRecord1 = new VendorOrderHeader(voHeaderRec[0]);
	   	vendorOrderHeaderRecord1.populateVendorOrderGroups(voHeaderRec[0]);
	   	
	    system.assertEquals(vendorOrderHeaderRecord1.VendorName, 'Test Vendor1');
    }
    
    static testMethod void getPaginatedRecordsTest(){
    	General_Configurations__c genConfig = new General_Configurations__c();
        genConfig.Home_Search_Grid_Page_Size__c = 10;
        genConfig.Related_List_Page_Size__c = 10;
        genConfig.Is_Widget_Removeable__c = true;
        genConfig.Load_New_Customer_Order__c = false;
        genConfig.Load_New_UI__c = true;
        genConfig.Load_New_View_Customer__c = false;
        insert genConfig;
        
	    Account vendor1 = TestUtil.createVendor(true, 'Test Vendor1');
	   	Account vendor2 = TestUtil.createVendor(true, 'Test Vendor2');
	   	VendorOrderHeader vendorOrderHeaderRecord1 = new VendorOrderHeader(TestUtil.createVendorOrderHeader(true, vendor1.Id).id);
	   	vendorOrderHeaderRecord1.VOName='testVO';
	   	VendorOrderHeader vendorOrderHeaderRecord2 = new VendorOrderHeader(TestUtil.createVendorOrderHeader(true, vendor2.Id).id);
	   	List<VendorOrderHeader> vendororderHeaderList = new List<VendorOrderHeader>{vendorOrderHeaderRecord1,vendorOrderHeaderRecord2};
	   	
	   	Test.startTest();
	   	VendorOrderHeader.getPaginatedRecords(vendororderHeaderList,0,0);
	    Test.stopTest();
	    
	    system.assertEquals(vendorOrderHeaderRecord1.VendorName, 'Test Vendor1');
    }
    
    static testMethod void VendorOrderHeaderTestCompare() {
		Account vendor1 = TestUtil.createVendor(true, 'Test Vendor1');
	   	Account vendor2 = TestUtil.createVendor(true, 'Test Vendor2');
	   	
	   	Vendor_Order_Header__c voHeader1 = TestUtil.createVendorOrderHeader(true, vendor1.Id);
	   	Vendor_Receiving_Header__c vrh1 = TestUtil.createVendorOrderReceiveHeader(false, vendor1.Id, 'In Progress');
        Id vorId1 = Id.valueOf(BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor1.Id),BPUtility.getEncodedString(null))));
        String VendorOrderReceiveItems1 = VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader1.Id),BPUtility.getEncodedString(vorId1), true);
        
	   	Vendor_Order_Header__c voHeader2 = TestUtil.createVendorOrderHeader(true, vendor2.Id);
	   	Vendor_Receiving_Header__c vrh2 = TestUtil.createVendorOrderReceiveHeader(false, vendor2.Id, 'In Progress');
        Id vorId2 = Id.valueOf(BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor2.Id),BPUtility.getEncodedString(null))));
        String VendorOrderReceiveItems2 = VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader2.Id),BPUtility.getEncodedString(vorId2), true);
	   	
	   	List<Vendor_Order_Header__c> voHeaderRec = SOQLUtil.getVendorOrderHeaderRecords('Vendor__c',new Set<Id>{voHeader1.Vendor__c,voHeader2.Vendor__c} , null, false);
	   	
	   	VendorOrderHeader vendorOrderHeaderRecord1 = new VendorOrderHeader(voHeaderRec[0]);
	   	VendorOrderHeader vendorOrderHeaderRecord2 = new VendorOrderHeader(voHeaderRec[1]);
	   	
	   	List<VendorOrderHeader> vendororderHeaderList = new List<VendorOrderHeader>{vendorOrderHeaderRecord1,vendorOrderHeaderRecord2};
	   	VendorOrderReceivingCtrl.VO_Sort_Order = 'DESCS';
	   	vendororderHeaderList.sort();
	   	
	   	Test.startTest();
	   	VendorOrderReceivingCtrl.VO_Sort_Order = 'ASC';
	   	vendororderHeaderList.sort();
	   	Test.stopTest();
	   	
	   	VendorOrderReceivingCtrl.VO_Sort_Order = 'DESC';
	   	vendororderHeaderList.sort();
	    
	   system.assertEquals(vendorOrderHeaderRecord1.VendorName, 'Test Vendor1');
    }
    
    static testMethod void VendorOrderHeaderTestCompareA() {
		Account vendor1 = TestUtil.createVendor(true, 'Test Vendor1');
	   	Account vendor2 = TestUtil.createVendor(true, 'Test Vendor2');
	   	
	   	Vendor_Order_Header__c voHeader1 = TestUtil.createVendorOrderHeader(true, vendor1.Id);
	   	Vendor_Receiving_Header__c vrh1 = TestUtil.createVendorOrderReceiveHeader(false, vendor1.Id, 'In Progress');
        Id vorId1 = Id.valueOf(BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor1.Id),BPUtility.getEncodedString(null))));
        String VendorOrderReceiveItems1 = VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader1.Id),BPUtility.getEncodedString(vorId1), true);
        
	   	Vendor_Order_Header__c voHeader2 = TestUtil.createVendorOrderHeader(true, vendor2.Id);
	   	
	   	List<Vendor_Order_Header__c> voHeaderRec = SOQLUtil.getVendorOrderHeaderRecords('Vendor__c',new Set<Id>{voHeader1.Vendor__c,voHeader2.Vendor__c} , null, false);
	   	
	   	VendorOrderHeader vendorOrderHeaderRecord1 = new VendorOrderHeader(voHeaderRec[0]);
	   	VendorOrderHeader vendorOrderHeaderRecord2 = new VendorOrderHeader(voHeaderRec[1]);
	   	
	   	List<VendorOrderHeader> vendororderHeaderList = new List<VendorOrderHeader>{vendorOrderHeaderRecord1,vendorOrderHeaderRecord2};
	   	Test.startTest();
	   	VendorOrderReceivingCtrl.VO_Sort_Order = 'ASC';
	   	vendororderHeaderList.sort();
	   	Test.stopTest();
	    system.assertEquals(vendorOrderHeaderRecord1.VendorName, 'Test Vendor1');
    }
    
    static testMethod void VendorOrderHeaderTestCompareB() {
		Account vendor1 = TestUtil.createVendor(true, 'Test Vendor1');
	   	Account vendor2 = TestUtil.createVendor(true, 'Test Vendor2');
	   	
	   	Vendor_Order_Header__c voHeader1 = TestUtil.createVendorOrderHeader(true, vendor1.Id);
        
	   	Vendor_Order_Header__c voHeader2 = TestUtil.createVendorOrderHeader(true, vendor2.Id);
	   	Vendor_Receiving_Header__c vrh2 = TestUtil.createVendorOrderReceiveHeader(false, vendor2.Id, 'In Progress');
        Id vorId2 = Id.valueOf(BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor2.Id),BPUtility.getEncodedString(null))));
        String VendorOrderReceiveItems2 = VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader2.Id),BPUtility.getEncodedString(vorId2), true);
	   	
	   	List<Vendor_Order_Header__c> voHeaderRec = SOQLUtil.getVendorOrderHeaderRecords('Vendor__c',new Set<Id>{voHeader1.Vendor__c,voHeader2.Vendor__c} , null, false);
	   	
	   	VendorOrderHeader vendorOrderHeaderRecord1 = new VendorOrderHeader(voHeaderRec[0]);
	   	VendorOrderHeader vendorOrderHeaderRecord2 = new VendorOrderHeader(voHeaderRec[1]);
	   	
	   	List<VendorOrderHeader> vendororderHeaderList = new List<VendorOrderHeader>{vendorOrderHeaderRecord1,vendorOrderHeaderRecord2};
	   	Test.startTest();
	   	VendorOrderReceivingCtrl.VO_Sort_Order = 'ASC';
	   	vendororderHeaderList.sort();
	   	Test.stopTest();
	    system.assertEquals(vendorOrderHeaderRecord1.VendorName, 'Test Vendor1');
    }
}