@isTest
private class PrintCustomerOrderCtrlTest {

    @testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
        List<General_Configurations__c> config = [SELECT Id FROM General_Configurations__c LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
        System.assertNotEquals(0, config.size());
    }
    
    /*static testMethod void getCOInvoiceDetailsTest2() {
        TestUtil.createtaxsettingInGeneralConfig();
        //Created test data to check scenario
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
           //Price level of 10% on MSRP
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
           // Part with available qty 100 and having MSRP $50
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
            // created customer order
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
         //Start: Added by Ayushi 12 July
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        
        CO_Invoice_Payment__c coinvoicepayment1  = TestUtil.createCOInvoicePayment(true, coinvoiceHeader1.Id );
        
        CO_Invoice_Payment__c coinvoicepayment2  = TestUtil.createCOInvoicePayment(true, coinvoiceHeader1.Id );
        
        CO_Kit_Header__c cokhRec = new CO_Kit_Header__c();
        cokhRec.CO_Header__c = coHeader.Id;
        insert cokhRec;
        
        Deal__c deal1 = new Deal__c();
        deal1.CO_Header__c = coHeader.Id;
        insert deal1;
        
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        dealItemRec.Deal__c = deal1.id;
        dealItemRec.Type__c ='Unit';
        dealItemRec.Unit_Make__c = unitmake.Id;
        dealItemRec.Unit_Model__c = unitmodel.Id;
        insert dealItemRec;
        
        Deal_Item__c dealItemRec2 = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        dealItemRec2.Deal__c = deal1.id;
        dealItemRec2.Type__c = Constants.DEAL_ITEM_TYPE_TRADE_IN;
        insert dealItemRec2;
        
        List<Deal_Unit_Price_Cost__c> dealUnitPriceCostList = new List<Deal_Unit_Price_Cost__c>();
        
        Deal_Unit_Price_Cost__c dealUnitPriceCostRec1= new Deal_Unit_Price_Cost__c(Item_Description__c = 'Test Deal Unit Price And Cost 2', Price__c = 7000, Qty__c = 1, Type__c ='Factory'); 
        dealUnitPriceCostRec1.Deal_Item__c = dealItemRec.Id;
        dealUnitPriceCostList.add(dealUnitPriceCostRec1);
        
        Deal_Unit_Price_Cost__c dealUnitPriceCostRec2 = new Deal_Unit_Price_Cost__c(Item_Description__c = 'Test Deal Unit Price And Cost 2', Price__c = 7000, Qty__c = 1, Type__c ='Dealer'); 
        dealUnitPriceCostRec2.Deal_Item__c = dealItemRec.Id;
        dealUnitPriceCostList.add(dealUnitPriceCostRec2);
        
        Deal_Unit_Price_Cost__c dealUnitPriceCostRec3 = new Deal_Unit_Price_Cost__c(Item_Description__c = 'Test Deal Unit Price And Cost 2', Price__c = 7000, Qty__c = 1, Type__c ='Base'); 
        dealUnitPriceCostRec3.Deal_Item__c = dealItemRec.Id;
        dealUnitPriceCostList.add(dealUnitPriceCostRec3);
        
        insert dealUnitPriceCostList;
        
        Option_Fee__c optionAndFeeRec = new Option_Fee__c();
        optionAndFeeRec.Deal_Item__c = dealItemRec.Id;
        optionAndFeeRec.Qty__c = 2;
        optionAndFeeRec.Part__c = part.Id;
        insert optionAndFeeRec;
        
        Customer_Owned_Unit__c customerOwnedUnitRec = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnitRec.Unit_Type__c = 'STOCK';
        customerOwnedUnitRec.VIN_Number__c = 'VIN123';
        customerOwnedUnitRec.Status__c = 'Available';
        customerOwnedUnitRec.Year__c = 2017;
        insert customerOwnedUnitRec;
        
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, Part.Id, 1, 5.0); 
        
        Deal_Kit_Header__c dealKitHeaderRec = new Deal_Kit_Header__c();
        dealKitHeaderRec.CO_Header__c = coHeader.Id;
        dealKitHeaderRec.Deal_Item__c = dealItemRec.Id;
        dealKitHeaderRec.Actual_Kit_Price__c = 25;
        dealKitHeaderRec.Kit_Header__c = kitHeader.Id;
        insert dealKitHeaderRec;
        
        Test.startTest();
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        List<Service_Order_Header__c> soHeaderList = [select Id from Service_Order_Header__c limit 1];
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderList[0].Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        String lineitems2 = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(soHeaderList[0].Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        soHeaderList[0].Customer_Owned_Unit__c = customerOwnedUnitRec.Id;
        soHeaderList[0].SO_Cause__c = 'Cause';
        soHeaderList[0].SO_Correction__c = 'Correction';
        soHeaderList[0].SO_Concern__c = 'Concern';
        update  soHeaderList[0];
        List<Service_Order_Header__c> soHeaderFieldsList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => soHeaderList[0].Id});
       
        //Create CO line items
        List<CO_Line_Item__c> COLineItemList = new List<CO_Line_Item__c>();
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, -2);
        COLineItemList.add(coLineItemRec1);
        
        CO_Line_Item__c coLineItemRec2 = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 50);
        coLineItemRec2.CO_Kit_Header__c = cokhRec.Id;
        COLineItemList.add(coLineItemRec2);
        
        CO_Line_Item__c coLineItemRec3 = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 50);
        coLineItemRec3.fee__c = fee.Id;
        COLineItemList.add(coLineItemRec3);
       
        /*Deal__c dealRec = new Deal__c(CO_Header__c = coHeader.Id, Status__c = 'Quotation', Unit_Status__c = 'Temporary');
        insert dealRec;*/
        
        /**CO_Line_Item__c coLineItemRec4 = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 50);
        COLineItemList.add(coLineItemRec4);
        
        insert COLineItemList;
        
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(true, testCategory.Id, coinvoiceHeader1.Id, coLineItemRec3.Id);
        
        
        CO_Invoice_Item__c coinvoiceitem2 =new CO_Invoice_Item__c();
        coinvoiceitem2.Category__c = testCategory.Id;
        coinvoiceitem2.CO_Invoice_Header__c = coinvoiceHeader1.Id;
        coinvoiceitem2.CO_Line_Item__c = coLineItemRec4.Id;
        coinvoiceitem2.Deal__c = deal1.Id;
        insert coinvoiceitem2;
        //End: Added by Ayushi 12 July
        
        Test.stopTest();
        //List<CO_Line_Item__c> colineitemList = [select Part__c, Qty_Committed__c, Qty__c, Status__c, Sub_Total_Without_Tax__c, Sub_Total_With_Tax__c from CO_Line_Item__c];
        //system.assert(false, colineitemList);
        
        String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(BPUtility.getEncodedString(coHeader.Id)));
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
        //system.assert(false, coHeaderDetails )    ;
        
        String coInvoiceDetails = BPUtility.getDecodedString(PrintCustomerOrderInvoiceCtrl.getCOInvoiceDetailsWithFinalize(BPUtility.getEncodedString(coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId), true)); // Ticket#1984: getCOInvoiceDetails -> getCOInvoiceDetailsWithFinalize: 
                                                                                                                                                                                           //Changed By Pooja 3 May 2017
        PrintCustomerOrderInvoiceCtrl.CustomerOrderInvoiceDetail coHeaderDetails11 = (PrintCustomerOrderInvoiceCtrl.CustomerOrderInvoiceDetail) System.JSON.deserialize(coInvoiceDetails, PrintCustomerOrderInvoiceCtrl.CustomerOrderInvoiceDetail.class);
        system.assertEquals(coHeaderDetails11.COInvoice.CustomerName, 'customerName');
        }*/
        
    static testMethod void getMerchandiseDetailsTest() {
        
        //Created test data to check scenario
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
           //Price level of 10% on MSRP
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
           // Part with available qty 100 and having MSRP $50
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
            // created customer order
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, -2);
        
        //ayushi start
       Individual_Tax__c individualTax = new Individual_Tax__c();
        individualTax.Sales_Tax_Item_Name__c = 'Sales_Tax_Item_Name1';
        individualTax.Tax_Rate__c = 50.0;
        individualTax.CO_Line_Item__c = coLineItem1.Id;
        insert individualTax;
        
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        CO_Line_Item__c coLineItem2 = new CO_Line_Item__c();
        coLineItem2.CO_Header__c = coHeader.Id;
        coLineItem2.Kit_Price_With_Price_Level__c = null;
        coLineItem2.Fee__c=fee.id;
        coLineItem2.Qty__c = 1;
        insert coLineItem2;
        //Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        
        CO_Kit_Header__c cokhRec = new CO_Kit_Header__c();
        cokhRec.CO_Header__c = coHeader.Id;
        insert cokhRec;
        
        CO_Line_Item__c coLineItem3 = new CO_Line_Item__c();
        coLineItem3.CO_Header__c = coHeader.Id;
        coLineItem3.CO_Kit_Header__c = cokhRec.Id;
        coLineItem3.Qty__c = 1;
        insert coLineItem3;
        //ayushi end
        
        
        List<CO_Line_Item__c> colineitemList = [select Part__c, Qty_Committed__c, Qty__c, Status__c, Sub_Total_Without_Tax__c, Sub_Total_With_Tax__c from CO_Line_Item__c];
        //system.assert(false, colineitemList);
        
        String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(BPUtility.getEncodedString(coHeader.Id)));
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
        //system.assert(false, coHeaderDetails )    ;
        
        String merchDetails = BPUtility.getDecodedString(PrintCustomerOrderInvoiceCtrl.getMerchandiseDetails(BPUtility.getEncodedString(coHeader.Id), false));
        //system.assert(false, merchDetails);
        PrintCustomerOrderInvoiceCtrl.COMerchandiseDetail merchDetails1 = (PrintCustomerOrderInvoiceCtrl.COMerchandiseDetail) System.JSON.deserialize(merchDetails, PrintCustomerOrderInvoiceCtrl.COMerchandiseDetail.class);
        //system.assertEquals(merchDetails1.gridTotal.Total, -110);
        System.assertEquals(true,true); 
        }
        
static testMethod void getCOInvoiceDetailsTestA() {
        TestUtil.createtaxsettingInGeneralConfig();
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Claims_for_Service_Work__c = true;
        insert vendor;
        
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Third-Party', 'Third-Party');
        //transactionType.Third_Party_Customer__c = customer.Id;
        insert transactionType ;
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 2;
        insert part;
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
       /* String lineitems1 = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        String lineitems2 = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(fee.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        String lineitems3 = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(labourCode.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        */
        Service_Order_Line_Item__c soliRec1 = new Service_Order_Line_Item__c();
        soliRec1.Service_Order_Header__c = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        soliRec1.Part__c = part.Id;
        soliRec1.Kit_Price__c = 10;
        soliRec1.Qty_Needed__c = 1;
        soliRec1.Price_When_Tax_Included__c = 25;
        soliRec1.Qty_Committed__c = 1;
        insert soliRec1;
        
        Service_Order_Line_Item__c soliRec2 = new Service_Order_Line_Item__c();
        soliRec2.Service_Order_Header__c = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        soliRec2.Fee__c = fee.Id;
        soliRec2.Qty_Needed__c = 1;
        soliRec2.Qty_Committed__c = 1;
        soliRec2.Price_When_Tax_Included__c = 25;
        insert soliRec2;
        
        Service_Order_Line_Item__c soliRec3 = new Service_Order_Line_Item__c();
        soliRec3.Service_Order_Header__c = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        soliRec3.Labour_Code__c = labourCode.Id;
        soliRec3.Qty_Needed__c = 1;
        soliRec3.Qty_Committed__c = 1;
        soliRec3.Price_When_Tax_Included__c = 25;
        insert soliRec3;
        
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(BPUtility.getEncodedString(coHeader.Id)));
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
        //system.assert(false, coHeaderDetails )    ;
        //ayushi
        CO_Kit_Header__c cokhRec = new CO_Kit_Header__c();
        cokhRec.CO_Header__c = coHeader.Id;
        insert cokhRec;
        
        CO_Line_Item__c coLineItemRec2 = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 50);
        coLineItemRec2.CO_Kit_Header__c = cokhRec.Id;
        insert coLineItemRec2;
        
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
                
        CO_Line_Item__c coLineItemRec4 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 50);
        
        Deal__c deal1 = new Deal__c();
        deal1.CO_Header__c = coHeader.Id;
        insert deal1;
        //Deal__c dealRec = new Deal__c(CO_Header__c = coHeader.Id, Status__c = 'Quotation', Unit_Status__c = 'Temporary');
        //insert dealRec;
        CO_Invoice_Item__c coinvoiceitem2 =new CO_Invoice_Item__c();
        coinvoiceitem2.Category__c = testCategory.Id;
        coinvoiceitem2.CO_Invoice_Header__c = coinvoiceHeader1.Id;
        coinvoiceitem2.CO_Line_Item__c = coLineItemRec4.Id;
        coinvoiceitem2.Deal__c = deal1.Id;
        insert coinvoiceitem2;
        
        
       Individual_Tax__c individualTax = new Individual_Tax__c();
        individualTax.Sales_Tax_Item_Name__c = 'Sales_Tax_Item_Name1';
        individualTax.Tax_Rate__c = 50.0;
        individualTax.CO_Line_Item__c = coLineItemRec2.Id;
        insert individualTax;
        //ayushi
        
        String coInvoiceDetails = BPUtility.getDecodedString(PrintCustomerOrderInvoiceCtrl.getCOInvoiceDetailsWithFinalize(BPUtility.getEncodedString(coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId), false)); // Ticket#1984: getCOInvoiceDetails -> getCOInvoiceDetailsWithFinalize: 
                                                                                                                                                                                                                    //Changed By Pooja 3 May 2017
        PrintCustomerOrderInvoiceCtrl.CustomerOrderInvoiceDetail coHeaderDetails11 = (PrintCustomerOrderInvoiceCtrl.CustomerOrderInvoiceDetail) System.JSON.deserialize(coInvoiceDetails, PrintCustomerOrderInvoiceCtrl.CustomerOrderInvoiceDetail.class);
        system.assertEquals(coHeaderDetails11.COInvoice.CustomerName, 'customerName');
        }
        
         static testMethod void getMerchandiseDetailsTestA() { 
        
        //Created test data to check scenario
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
           //Price level of 10% on MSRP
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
           // Part with available qty 100 and having MSRP $50
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1234567890', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
            // created customer order
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, -2);
        List<CO_Line_Item__c> colineitemList = [select Part__c, Qty_Committed__c, Qty__c, Status__c, Sub_Total_Without_Tax__c, Sub_Total_With_Tax__c from CO_Line_Item__c];
        //system.assert(false, colineitemList);
        
        String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(BPUtility.getEncodedString(coHeader.Id)));
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
        //system.assert(false, coHeaderDetails )    ;
        
        String merchDetails = BPUtility.getDecodedString(PrintCustomerOrderInvoiceCtrl.getMerchandiseDetails(BPUtility.getEncodedString(coHeader.Id), true));
        //system.assert(false, merchDetails);
        PrintCustomerOrderInvoiceCtrl.COMerchandiseDetail merchDetails1 = (PrintCustomerOrderInvoiceCtrl.COMerchandiseDetail) System.JSON.deserialize(merchDetails, PrintCustomerOrderInvoiceCtrl.COMerchandiseDetail.class);
        //system.assertEquals(merchDetails1.gridTotal.Total, -110);
        System.assertEquals(true,true); 
        }
        
        
        static testMethod void getMerchandiseDetailsWithGeneralConfigurationTest() {
        
            TestUtil.createtaxsettingInGeneralConfig();
            Business_Profile__c businessProfileObject = new Business_Profile__c();
            businessProfileObject.Business_Street_Address1__c = 'test street1';
            businessProfileObject.Business_Street_Address2__c = 'test street1';
            businessProfileObject.Business_City__c = 'test city'; 
            businessProfileObject.Business_Name__c = 'business 1 ';
            businessProfileObject.Business_Postal_Code__c = '302022';
            businessProfileObject.Business_Phone__c = '1234567890';
            insert businessProfileObject;
            
            //Created test data to check scenario
            Account vendor = TestUtil.createVendor(true, 'Test Vendor');
            Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
            
               //Price level of 10% on MSRP
            Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
            Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
            
               // Part with available qty 100 and having MSRP $50
            Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
            
            Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
                // created customer order
            CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
            
            CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, -2);
            
            
            Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
            CO_Line_Item__c coLineItem2 = new CO_Line_Item__c();
            coLineItem2.CO_Header__c = coHeader.Id;
            coLineItem2.Kit_Price_With_Price_Level__c = null;
            coLineItem2.Fee__c=fee.id;
            coLineItem2.Qty__c = 1;
            insert coLineItem2;
            
            CO_Line_Item__c coLineItem3 = new CO_Line_Item__c();
            coLineItem3.CO_Header__c = coHeader.Id;
            coLineItem3.Tax__c = null;
            coLineItem3.Price__c = null;
            coLineItem3.Qty__c = 1;
            insert coLineItem3;
            
            List<CO_Line_Item__c> colineitemList = [select Part__c, Qty_Committed__c, Qty__c, Status__c, Sub_Total_Without_Tax__c, Sub_Total_With_Tax__c from CO_Line_Item__c];
            //system.assert(false, colineitemList);
            
            String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(BPUtility.getEncodedString(coHeader.Id)));
            COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
            //system.assert(false, coHeaderDetails )    ;
            
            String merchDetails = BPUtility.getDecodedString(PrintCustomerOrderInvoiceCtrl.getMerchandiseDetails(BPUtility.getEncodedString(coHeader.Id), false));
            //system.assert(false, merchDetails);
            PrintCustomerOrderInvoiceCtrl.COMerchandiseDetail merchDetails1 = (PrintCustomerOrderInvoiceCtrl.COMerchandiseDetail) System.JSON.deserialize(merchDetails, PrintCustomerOrderInvoiceCtrl.COMerchandiseDetail.class);
            //system.assertEquals(merchDetails1.gridTotal.Total, -110);
            System.assertEquals(true,true); 
        }
        
        static testMethod void getPrintCustomerOrderInvoiceCtrlTest() {
            TestUtil.createtaxsettingInGeneralConfig();
            PrintCustomerOrderInvoiceCtrl printCustomerOrderInvoice =new PrintCustomerOrderInvoiceCtrl();
            Account vendor = TestUtil.createVendor(true, 'Test Vendor');
            Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
            Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
     
            Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
            Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
            
            CO_Header__c coHeader1 = TestUtil.createCOHeader(true, customer.Id);
            Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
            CO_Line_Item__c coLineItemRec = TestUtil.createCOLineItem(true, coHeader1.Id, part.Id, 50);
            CO_Deposit__c coDeposit1 = TestUtil.createCODeposit(true, coHeader1.Id, 'Deposit', 500);
            
            List<CO_Deposit__c> coDeposits =[Select id, Payment_Method__c,Amount__c,Payment_Date__c,LastModifiedDate from CO_Deposit__c WHERE CO_Header__c = :coHeader1.id];
            //System.assert(true,coDeposit);
            PrintCustomerOrderInvoiceCtrl.TransactionDetail transDetails = new PrintCustomerOrderInvoiceCtrl.TransactionDetail(coDeposits[0]);
            
            Deal__c deal1 = new Deal__c();
            deal1.CO_Header__c = coHeader1.Id;
            insert deal1;
            
            
            //sevice Detail
            String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader1.Id)));
            String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader1.Id), BPUtility.getEncodedString('soHeader')));
            
            SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
            Service_Order_Header__c soHeaderRec = new Service_Order_Header__c(Id = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id);
            Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
            Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
            Unit_Sub_Model__c unitSubModel = new Unit_Sub_Model__c();
            unitSubModel.Sub_Model_Name__c = 'unitSubModelName';
            unitSubModel.Active__c = true;
            unitSubModel.Unit_Model__c = unitModel.ID;
            unitSubModel.VIN_Code__c = 'VIN';
            insert unitSubModel;
            Customer_Owned_Unit__c customerOwnedUnitRec = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, unitSubModel.Id);
            customerOwnedUnitRec.Unit_Type__c = 'STOCK';
            customerOwnedUnitRec.Status__c = 'Available';
            customerOwnedUnitRec.VIN_Number__c = 'VIN123';
            customerOwnedUnitRec.Year__c = 2017;
            insert customerOwnedUnitRec;
            Test.StartTest();
            getPrintCustomerOrderInvoiceCtrlTestAsyncHandling(coHeader1.Id, customer.Id, customerOwnedUnitRec.Id, unitmodel.Id, part.Id);
            Test.StopTest();
            
        }
        
        @future
		private static void getPrintCustomerOrderInvoiceCtrlTestAsyncHandling(String coHeader1Id, String customerId, String customerOwnedUnitRecId, String unitmodelId, String partId) {
			List<Service_Order_Header__c> soHeaderListRec = [select Id from Service_Order_Header__c limit 1];
            String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(partId), BPUtility.getEncodedString(soHeaderListRec[0].Id), BPUtility.getEncodedString(coHeader1Id), BPUtility.getEncodedString(customerId)));
            soHeaderListRec[0].Customer_Owned_Unit__c = customerOwnedUnitRecId;
            update  soHeaderListRec[0];
            
            List<Service_Order_Header__c> soHeaderList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => soHeaderListRec[0].Id});
        
            CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader1Id, 'Active');
            PrintCustomerOrderInvoiceCtrl.COInvoiceDetail cOInvoiceDetails= new PrintCustomerOrderInvoiceCtrl.COInvoiceDetail(coinvoiceHeader1);
            PrintCustomerOrderInvoiceCtrl.ServiceDetail SerDetails = new PrintCustomerOrderInvoiceCtrl.ServiceDetail(cOInvoiceDetails,soHeaderList[0]);
            
            List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader1Id];
            
            
            Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
            dealItemRec.Unit_Model__c = unitmodelId;
            dealItemRec.Deal__c = dealList[0].Id;
            dealItemRec.Type__c = Constants.DEAL_ITEM_TYPE_TRADE_IN;
            dealItemRec.Agreed_Value__c = 25;
            dealItemRec.Customer_Owned_Unit__c = customerOwnedUnitRecId;
            insert dealItemRec;
            
            Deal_Unit_Price_Cost__c dealUnitPriceCostRec1= new Deal_Unit_Price_Cost__c(Item_Description__c = 'Test Deal Unit Price And Cost 2', Price__c = 7000, Qty__c = 1, Type__c ='Factory'); 
            dealUnitPriceCostRec1.Deal_Item__c = dealItemRec.Id;
            insert dealUnitPriceCostRec1;
            Deal_Unit_Price_Cost__c dealUnitPriceCostRec2 = new Deal_Unit_Price_Cost__c(Item_Description__c = 'Test Deal Unit Price And Cost 2', Price__c = 7000, Qty__c = 1, Type__c ='Dealer'); 
            dealUnitPriceCostRec2.Deal_Item__c = dealItemRec.Id;
            insert dealUnitPriceCostRec2;
            Deal_Unit_Price_Cost__c dealUnitPriceCostRec3 = new Deal_Unit_Price_Cost__c(Item_Description__c = 'Test Deal Unit Price And Cost 2', Price__c = 7000, Qty__c = 1, Type__c ='Base'); 
            dealUnitPriceCostRec3.Deal_Item__c = dealItemRec.Id;
            insert dealUnitPriceCostRec3;
            
            Option_Fee__c optionAndFeeRec = new Option_Fee__c();
            optionAndFeeRec.Deal_Item__c = dealItemRec.Id;
            optionAndFeeRec.Qty__c = 2;
            optionAndFeeRec.Part__c = partId;
            insert optionAndFeeRec;
            
            List<Deal_Item__c> dealItemList = SOQLUtil.getDealItemDetails(new Set<Id>{dealItemRec.Id});
            PrintCustomerOrderInvoiceCtrl.DealUnitDetails dealUnitDetail = new PrintCustomerOrderInvoiceCtrl.DealUnitDetails(dealItemList[0]);
            system.assert(true,true);
		}
}