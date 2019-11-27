@isTest
private class OtherChargesTriggerTest {

    /**
     * Name: addOtherChargesTest 
     * Desc: Test to add Other Charges To VIHeader
     * @param: 
     * @return: 
    **/    
    static testMethod void addOtherChargesTest() {
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        //System.JSON.serialize(pageSort)

        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        
        insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
            
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true;
        Part.Package_Qty__c = 22;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 1;
        //part.Qty_On_Order__c = 0;
        
        Part__c part2 = TestUtil.createPart(false, 'partNumberP03', vendor.Id, 'Test Part03', testCategory.Id, 10, 20, 50, 100, 50);
        Fee__c fee = TestUtil.createFee(true, true, testCategory.Id, 'test1', coHeader.Id, 'Description', 100, true);
        insert new List<SObject>{part, part2};
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 150);
        CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(false, coHeader.Id, part2.Id, 150);
        
        insert new List<SObject>{coLineItem, coLineItem1};

        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        Test.startTest();
        //Vendor_Receiving_Header__c vor = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(voHeader.Id), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        //String groupLineItems = VendorOrderCtrl.groupAllSimilarVOLineItem(vendor.Id, part.Id, voHeader.Id, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        Vendor_Receiving_Header__c vrh = TestUtil.createVendorOrderReceiveHeader(true, vendor.Id, 'In Progress');
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(null)));
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vorId), true));
        
        
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part.id), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 10, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        Test.stopTest();
        String UpdatedItemsSubsection2 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part2.id), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[1].Id), 40, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);

        
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        Vendor_Invoicing_Header__c viHeader = TestUtil.createVendorInvoiceHeader(true, vendor.Id, 'In Progress');
         
        String vendorInvoices = BPUtility.getDecodedString(VendorInvoicingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String otherCharges = BPUtility.getDecodedString(VendorInvoicingCtrl.addOtherCharges(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(fee.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String addedVendorInvoice = BPUtility.getDecodedString(VendorInvoicingCtrl.addToItemsSubsection(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        VendorInvoicingCtrl.VIHeaderWrapper vendorInvoice = (VendorInvoicingCtrl.VIHeaderWrapper)System.JSON.deserialize(addedVendorInvoice, VendorInvoicingCtrl.VIHeaderWrapper.class);
        //VendorInvoicingCtrl.VIGroup vendorInvoice1 = (VendorInvoicingCtrl.VIGroup)System.JSON.deserialize(addedVendorInvoice, VendorInvoicingCtrl.VIGroup.class);
        
        system.assertEquals(vendorInvoice.OtherChargesList[0].Cost, 100.00);
        system.assertEquals(vendorInvoice.OtherChargesList[0].ItemDesc, 'test1 - Description');
    }
    
    /**
     * Name: updateOtherChargesTest 
     * Desc: Test to update Other Charges To VIHeader
     * @param: 
     * @return: 
    **/    
    static testMethod void updateOtherChargesTest() {
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        //System.JSON.serialize(pageSort)
        
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        
        insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
            
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true;
        Part.Package_Qty__c = 22;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 1;
        //part.Qty_On_Order__c = 0;
        Part__c part2 = TestUtil.createPart(false, 'partNumberP03', vendor.Id, 'Test Part03', testCategory.Id, 10, 20, 50, 100, 50);
        Fee__c fee = TestUtil.createFee(false, true, testCategory.Id, 'test1', coHeader.Id, 'Description', 100, true);
        insert new List<SObject>{part, part2, fee};
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 150);
        CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(false, coHeader.Id, part2.Id, 150);
        
        insert new List<SObject>{coLineItem, coLineItem1};

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
        //q-88
        Test.startTest();
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part.id), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 10, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String UpdatedItemsSubsection2 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part2.id), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[1].Id), 40, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        Vendor_Invoicing_Header__c viHeader = TestUtil.createVendorInvoiceHeader(true, vendor.Id, 'In Progress');
        String vendorInvoices = BPUtility.getDecodedString(VendorInvoicingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        Test.stopTest();
        String addedVendorInvoice = BPUtility.getDecodedString(VendorInvoicingCtrl.addToItemsSubsection(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        updateOtherChargesTest_future(viHeader.Id, fee.Id, System.JSON.serialize(pageSort));
        //String otherCharges = BPUtility.getDecodedString(VendorInvoicingCtrl.addOtherCharges(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(fee.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        //q-96
        /*VendorInvoicingCtrl.VIHeaderWrapper viHeaderrObj = (VendorInvoicingCtrl.VIHeaderWrapper) System.JSON.deserialize(otherCharges, VendorInvoicingCtrl.VIHeaderWrapper.class);
        Other_Charges__c otherChargesRec = new Other_Charges__c(Id = viHeaderrObj.OtherChargesList[0].Id);
        otherChargesRec.Cost__c = 200;
        otherChargesRec.Fee__c = fee.Id;
        
        VendorInvoicingCtrl.OtherChargesWrapper otherChargesWrapperRec = new VendorInvoicingCtrl.OtherChargesWrapper(otherChargesRec);
        String OtherChargesmodifyCost = BPUtility.getDecodedString(VendorInvoicingCtrl.updateOtherCharges(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(otherChargesWrapperRec)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        VendorInvoicingCtrl.VIHeaderWrapper vendorInvoice = (VendorInvoicingCtrl.VIHeaderWrapper)System.JSON.deserialize(OtherChargesmodifyCost, VendorInvoicingCtrl.VIHeaderWrapper.class);
        //system.assert(false, vendorInvoice);
        system.assertEquals(vendorInvoice.OtherChargesList[0].Cost, 200.00);*/
    }
    
    @future
     static void updateOtherChargesTest_future(String viHeaderId, String feeId, String pageSort) {   
    String otherCharges = BPUtility.getDecodedString(VendorInvoicingCtrl.addOtherCharges(BPUtility.getEncodedString(viHeaderId), BPUtility.getEncodedString(feeId), BPUtility.getEncodedString(pageSort), BPUtility.getEncodedString(pageSort)));
        
    VendorInvoicingCtrl.VIHeaderWrapper viHeaderrObj = (VendorInvoicingCtrl.VIHeaderWrapper) System.JSON.deserialize(otherCharges, VendorInvoicingCtrl.VIHeaderWrapper.class);
        Other_Charges__c otherChargesRec = new Other_Charges__c(Id = viHeaderrObj.OtherChargesList[0].Id);
        otherChargesRec.Cost__c = 200;
        otherChargesRec.Fee__c = feeId;
        
        VendorInvoicingCtrl.OtherChargesWrapper otherChargesWrapperRec = new VendorInvoicingCtrl.OtherChargesWrapper(otherChargesRec);
        String OtherChargesmodifyCost = BPUtility.getDecodedString(VendorInvoicingCtrl.updateOtherCharges(BPUtility.getEncodedString(viHeaderId), BPUtility.getEncodedString(System.JSON.serialize(otherChargesWrapperRec)), BPUtility.getEncodedString(pageSort), BPUtility.getEncodedString(pageSort)));
        
        VendorInvoicingCtrl.VIHeaderWrapper vendorInvoice = (VendorInvoicingCtrl.VIHeaderWrapper)System.JSON.deserialize(OtherChargesmodifyCost, VendorInvoicingCtrl.VIHeaderWrapper.class);
        system.assertEquals(vendorInvoice.OtherChargesList[0].Cost, 200.00);
    }
    
    /**
     * Name: deleteOtherChargesTest 
     * Desc: Test to delete Other Charges To VIHeader
     * @param: 
     * @return: 
    **/    
    static testMethod void deleteOtherChargesTest() {
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        //System.JSON.serialize(pageSort)

        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        
        insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
            
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true;
        Part.Package_Qty__c = 22;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 1;
        //part.Qty_On_Order__c = 0;
        
        Part__c part2 = TestUtil.createPart(false, 'partNumberP03', vendor.Id, 'Test Part03', testCategory.Id, 10, 20, 50, 100, 50);
        Fee__c fee = TestUtil.createFee(true, true, testCategory.Id, 'test1', coHeader.Id, 'Description', 100, true);
        insert new List<SObject>{part, part2};
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 150);
        CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(false, coHeader.Id, part2.Id, 150);
        
        insert new List<SObject>{coLineItem, coLineItem1};

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
        //q-88
        Test.startTest();
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part.id), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 10, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        String UpdatedItemsSubsection2 = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(part2.id), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[1].Id), 40, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);

        
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        Vendor_Invoicing_Header__c viHeader = TestUtil.createVendorInvoiceHeader(true, vendor.Id, 'In Progress');
         
        String vendorInvoices = BPUtility.getDecodedString(VendorInvoicingCtrl.addVendor(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        Test.stopTest();
        
        String addedVendorInvoice = BPUtility.getDecodedString(VendorInvoicingCtrl.addToItemsSubsection(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        //String otherCharges = BPUtility.getDecodedString(VendorInvoicingCtrl.addOtherCharges(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(fee.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        //q-96
        deleteOtherChargesTest_future(viHeader.Id, fee.Id, System.JSON.serialize(pageSort));
        //BPUtility.getDecodedString(VendorInvoicingCtrl.deleteOtherCharges(BPUtility.getEncodedString(), BPUtility.getEncodedString(), BPUtility.getEncodedString(System.JSON.serialize()), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        system.assertEquals(0,[select count() from other_charges__c]);
    }
    
     @future
     static void deleteOtherChargesTest_future(String viHeaderId, String feeId, String pageSort) {   
        String otherCharges = BPUtility.getDecodedString(VendorInvoicingCtrl.addOtherCharges(BPUtility.getEncodedString(viHeaderId), BPUtility.getEncodedString(feeId), BPUtility.getEncodedString(pageSort), BPUtility.getEncodedString(pageSort)));
        
        VendorInvoicingCtrl.VIHeaderWrapper viHeaderrObj = (VendorInvoicingCtrl.VIHeaderWrapper) System.JSON.deserialize(otherCharges, VendorInvoicingCtrl.VIHeaderWrapper.class);
        BPUtility.getDecodedString(VendorInvoicingCtrl.deleteOtherCharges(BPUtility.getEncodedString(viHeaderId), BPUtility.getEncodedString(viHeaderrObj.OtherChargesList[0].Id), BPUtility.getEncodedString(pageSort), BPUtility.getEncodedString(pageSort)));
        system.assertEquals(0,[select count() from other_charges__c]);
        }
}