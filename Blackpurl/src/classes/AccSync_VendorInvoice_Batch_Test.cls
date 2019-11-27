/**
 * Author: Pooja Khandelwal
 * Since: Jan. 13, 2017
 * Name: AccSync_VendorInvoice_Batch_Test
 * Description: Test class for AccSync_VendorInvoice_Batch
**/
@isTest
private class  AccSync_VendorInvoice_Batch_Test { 
    static PaginationSorting pageSort;
    @testSetup
    private static void setup()  {
      General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
      genConfig.Enable_QB_Accounting__c = true;
      update genConfig;
      
      QuickBooks_Configurations__c QBConfig = new QuickBooks_Configurations__c(Consumer_Key__c = 'qyprdFawAAiD3SLud6d5RvREaVOoAn',
               Consumer_Secret__c = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr', OAuth_Token__c = 'qyprdAVMsASHRkSalO3JwbyPdnzistYmRRfJBFbAxL6AOlDj', 
               OAuth_Token_Secret__c = 'TN3csfs1tTSX77SW5ysYkcVxJo1gIq8Lq3wusQKO', Company_Id__c = '123145730762509', 
               End_Point_URL__c ='https://sandbox-quickbooks.api.intuit.com/v3/company/', Enable_QuickBooks__c = true);
        
        insert QBConfig;
        
        
        // pageSort 
        pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        Category__c categoryObj =  TestUtil.createCategory(true, 'Qb KI KOI BHi Category');
        
        TestUtil.setQBTaxCodesConfigurations(true);
        List<Sales_Tax__c> defaultSalesTax = [Select Id From Sales_Tax__c where Rate__c != 0];
        //Create Vendor
        Account vendorObj = TestUtil.createVendor(false, 'QB Vendor');
        vendorObj.Purchase_Tax__c = defaultSalesTax[0].Id;
        insert vendorObj;
        //Create PriceLevel
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'QB Default Price Level', 'MSRP', 10 , true, true);
        
        //Create SalesTax
        //Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'QB Test Sales Tax', true, true, true);
        
        //Create Customer
        Account customer =  TestUtil.createCustomer(true, 'QB Customer', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        
        //Create COHeader
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        //Create Part
        Part__c partRec =  TestUtil.createPart(true, 'QBPartNumberPo1', vendorObj.Id, 'QB Part', categoryObj.Id);

        //Create COLineItem
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, partRec.Id, 150);
        
        //Create POType
        //PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'QBpurchaseOrderCode', vendorObj.Id, true, 2);
        Fee__c feeRec = TestUtil.createFee(true, true, categoryObj.Id, '8963', null, 'test fee 8963', 20, true);
        //Create VendorOrderHeader
        Vendor_Order_Header__c VOHeader = TestUtil.createVendorOrderHeader(true, vendorObj.Id);
        //voHeader.Purchase_Order_Type__c = POType.Id;
        //insert voHeader;
        
        // groupAllSimilarVOLineItem
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllSimilarVOLineItem(BPUtility.getEncodedString(vendorObj.Id), BPUtility.getEncodedString(partRec.Id), 
        							 		BPUtility.getEncodedString(VOHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
        											BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        //Finalize VO
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(VOHeader.Id), BPUtility.getEncodedString(vendorObj.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        createVORAndVOIT(); 
        system.assert(true,true);
    }
    
    
    private static testmethod void syncVORAndVOITest()  {
        Test.startTest();  
        List<Vendor_Receiving_Header__c> vrhList2 = [Select Id, Status__c, availForQBJournalEntrySync__c from Vendor_Receiving_Header__c ];
        vrhList2[0].SyncTokenForJournalEntry__c = '1';
        update vrhList2;
        List<Vendor_Receiving_Header__c> vrhList = [Select Id, Status__c, availForQBJournalEntrySync__c from Vendor_Receiving_Header__c ];
		Set<Id> setVendorReceivingIds = new Set<Id>();
        for(Vendor_Receiving_Header__c vendorReceiving : vrhList){ 
	        if(vendorReceiving.Status__c == 'Stocked')  {
	            setVendorReceivingIds.add(vendorReceiving.Id);
	        }
        }
        if(setVendorReceivingIds.size() > 0) {
        	VORJournalEntryService.syncVORs(setVendorReceivingIds);
        }
        
        List<Vendor_Invoicing_Header__c> VIHeaderList2 = [Select Id, Status__c from Vendor_Invoicing_Header__c];
        VIHeaderList2[0].SyncToken__c = '1';
        update VIHeaderList2;
        List<Vendor_Invoicing_Header__c> VIHeaderList = [Select Id, Status__c from Vendor_Invoicing_Header__c];
        Set<Id> setVendorInvoiceIds = new Set<Id>();
        for(Vendor_Invoicing_Header__c vendorInvoice : VIHeaderList){ 
                if(vendorInvoice.Status__c == 'Invoiced')   {
                    setVendorInvoiceIds.add(vendorInvoice.Id);
                }
                
        }
        if(setVendorInvoiceIds.size() > 0) {
            VendorInvoiceService.syncVIHeaders(setVendorInvoiceIds);
        }
        Test.stopTest();  
              	
        String res = '{"Bill":{"DueDate":"2017-01-18","Balance":180.00,"domain":"QBO","sparse":false,"Id":"689","SyncToken":"0","MetaData":{"CreateTime":"2017-01-17T22:30:55-08:00","LastUpdatedTime":"2017-01-17T22:30:55-08:00"},"DocNumber":"VI-0000019","TxnDate":"2017-01-18","CurrencyRef":{"value":"USD","name":"United States Dollar"},"Line":[{"Id":"1","Description":"QB Part1 - QB Part1 1.00@$200.00","Amount":180.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"129","name":"VendorInvoiceLiabilitiesAccount"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"2","Description":"QB Part1 - QB Part1 Receiving Adjustment","Amount":-80.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"129","name":"VendorInvoiceLiabilitiesAccount"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"3","Description":"QB Part1 - QB Part1 Inventory Adjustment","Amount":80.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"81","name":"Inventory Asset"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}}],"VendorRef":{"value":"178","name":"QB Vendor VDR-0014"},"APAccountRef":{"value":"128","name":"A/P Accrual - Inventory"},"TotalAmt":180.00},"time":"2017-01-17T22:30:55.871-08:00"}';
        List<Vendor_Invoicing_Header__c> VIHeaderList1 = [Select Id, Status__c, Total__c, Invoice_Number__c, AccountingResponse__c, AccountingId__c from Vendor_Invoicing_Header__c];
        List<Vendor_Receiving_Header__c> vrhList1 = [Select Id, AccountingIdForJournalEntry__c from Vendor_Receiving_Header__c ];
        
        system.assertEquals('675', vrhList1[0].AccountingIdForJournalEntry__c);
        //system.assertEquals(VIHeaderList1[0].AccountingResponse__c,res); 
        system.assertEquals(VIHeaderList1[0].AccountingId__c,'689');
        
    }
    
    private static testmethod void syncVORAndVOITestWithouTaxCodes()  {
    	TestUtil.setQBTaxCodesConfigurations(false);
        Test.startTest();  
        List<Vendor_Receiving_Header__c> vrhList2 = [Select Id, Status__c, availForQBJournalEntrySync__c from Vendor_Receiving_Header__c ];
        vrhList2[0].SyncTokenForJournalEntry__c = '1';
        update vrhList2;
        List<Vendor_Receiving_Header__c> vrhList = [Select Id, Status__c, availForQBJournalEntrySync__c from Vendor_Receiving_Header__c ];
		Set<Id> setVendorReceivingIds = new Set<Id>();
        for(Vendor_Receiving_Header__c vendorReceiving : vrhList){ 
	        if(vendorReceiving.Status__c == 'Stocked')  {
	            setVendorReceivingIds.add(vendorReceiving.Id);
	        }
        }
        if(setVendorReceivingIds.size() > 0) {
        	VORJournalEntryService.syncVORs(setVendorReceivingIds);
        }
        
        List<Vendor_Invoicing_Header__c> VIHeaderList2 = [Select Id, Status__c from Vendor_Invoicing_Header__c];
        VIHeaderList2[0].SyncToken__c = '1';
        update VIHeaderList2;
        List<Vendor_Invoicing_Header__c> VIHeaderList = [Select Id, Status__c from Vendor_Invoicing_Header__c];
        Set<Id> setVendorInvoiceIds = new Set<Id>();
        for(Vendor_Invoicing_Header__c vendorInvoice : VIHeaderList){ 
                if(vendorInvoice.Status__c == 'Invoiced')   {
                    setVendorInvoiceIds.add(vendorInvoice.Id);
                }
                
        }
        if(setVendorInvoiceIds.size() > 0) {
            VendorInvoiceService.syncVIHeaders(setVendorInvoiceIds);
        }
        Test.stopTest();  
              	
        String res = '{"Bill":{"DueDate":"2017-01-18","Balance":180.00,"domain":"QBO","sparse":false,"Id":"689","SyncToken":"0","MetaData":{"CreateTime":"2017-01-17T22:30:55-08:00","LastUpdatedTime":"2017-01-17T22:30:55-08:00"},"DocNumber":"VI-0000019","TxnDate":"2017-01-18","CurrencyRef":{"value":"USD","name":"United States Dollar"},"Line":[{"Id":"1","Description":"QB Part1 - QB Part1 1.00@$200.00","Amount":180.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"129","name":"VendorInvoiceLiabilitiesAccount"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"2","Description":"QB Part1 - QB Part1 Receiving Adjustment","Amount":-80.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"129","name":"VendorInvoiceLiabilitiesAccount"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"3","Description":"QB Part1 - QB Part1 Inventory Adjustment","Amount":80.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"81","name":"Inventory Asset"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}}],"VendorRef":{"value":"178","name":"QB Vendor VDR-0014"},"APAccountRef":{"value":"128","name":"A/P Accrual - Inventory"},"TotalAmt":180.00},"time":"2017-01-17T22:30:55.871-08:00"}';
        List<Vendor_Invoicing_Header__c> VIHeaderList1 = [Select Id, Status__c, Total__c, Invoice_Number__c, AccountingResponse__c, AccountingId__c from Vendor_Invoicing_Header__c];
        List<Vendor_Receiving_Header__c> vrhList1 = [Select Id, AccountingIdForJournalEntry__c from Vendor_Receiving_Header__c ];
        
        system.assertEquals('675', vrhList1[0].AccountingIdForJournalEntry__c);
        //system.assertEquals(VIHeaderList1[0].AccountingResponse__c,res); 
        system.assertEquals(VIHeaderList1[0].AccountingId__c,'689');
        
    }
      
    @future
    private static void createVORAndVOIT()  {
        // Vendor
        List<Account> vendorRec = [Select Id, Name, AccountingResponse__c, AccountingId__c From Account WHERE Is_Vendor__c = true];
        
        // Part
        List<Part__c> partRec = [Select Id From Part__c];
        
        // VOHeader
        List<Vendor_Order_Header__c> VOHeader = [Select Id, (Select Id, Status__c From Vendor_Order_Line_Item_Groups__r) From Vendor_Order_Header__c Where vendor__r.Id =: vendorRec[0].Id];
        
        // Create VendorOrderReceiveHeader
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorRec[0].Id), BPUtility.getEncodedString(null)));
        
        
        //Fee 
        List<Fee__c> feeRecs = [Select Id From Fee__c];
        
        // Create VOR Line Items
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(VOHeader[0].Id), BPUtility.getEncodedString(vorId), true));
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(VOHeader[0].Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems1 = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partRec[0].id), BPUtility.getEncodedString(voLineReceiveItems1.VORGroupList[0].Id), 10, 8500, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
        
        // VendorOrderReceiveHeader
        List<Vendor_Receiving_Header__c> VORHeader = [Select Id, Vendor__r.Name From Vendor_Receiving_Header__c Where vendor__r.Id =: vendorRec[0].Id];
        
        // VendorOrderInvoicing
        Vendor_Invoicing_Header__c VIHeader = TestUtil.createVendorInvoiceHeader(true, vendorRec[0].Id, 'In Progress');
        String vendorInvoices = BPUtility.getDecodedString(VendorInvoicingCtrl.addVendor(BPUtility.getEncodedString(vendorRec[0].Id), BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String addedVendorInvoice = BPUtility.getDecodedString(VendorInvoicingCtrl.addToItemsSubsection(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(VORHeader[0].Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        Other_Charges__c otherCharge = new Other_Charges__c(Cost__c=15.0, Fee__c=feeRecs[0].Id, Tax_Percent__c=10.0, Vendor_Invoicing_Header__c=VIHeader.Id);
        insert otherCharge;
        List<Vendor_Invoicing_Group__c> VIGList = [select Id, VI_Cost__c from Vendor_Invoicing_Group__c where Vendor_Invoicing_Header__c =: VIHeader.Id];
        //System.assert(false, VIGList);
        VIGList[0].VI_Cost__c = 10000;
        update VIGList;
        String finalaizedInvoice = VendorInvoicingCtrl.finalizeInvoiceAction(BPUtility.getEncodedString(viHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
    }
}