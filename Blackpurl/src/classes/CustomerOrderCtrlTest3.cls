/**
 * Author: Tarun Khandelwal
 * Since: Oct 18, 2018
 * Name: CustomerOrderCtrlTest3 test
 * Description: Controller test Class of Customer order ctrl.
**/
@isTest
private class CustomerOrderCtrlTest3 {
    
    @testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
    }
    
    static testMethod void moveLineItemTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        //Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        //Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        //Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        //Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        //Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        //Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, LabourCode.Id, Part.Id, 1, 5.0);    
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false; 
        
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
        
        //system.assert(false, soHeaderDetailsObj2 );
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded, 50.00);
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        List<Service_Order_Line_Item__c> SOli = [select Id, Qty_Committed__c, Fixed_Price__c, Total__c from Service_Order_Line_Item__c limit 100];
        system.assertEquals(SOli.size(), 1);
        
        String movedLineItem = BPUtility.getDecodedString(CustomerOrderCtrl.moveLineItem(BPUtility.getEncodedString(null), BPUtility.getEncodedString('Merchandise'), BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].Id), BPUtility.getEncodedString(CoHeader.Id))) ;
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(movedLineItem, COHeaderWrapper.class);
        Test.stoptest();
        system.assertEquals(coHeaderDetails.COKHList[0].COLIList[0].AvaliablePartsQty, 50);
        system.assertEquals(coHeaderDetails.COKHList[0].COLIList[0].SubTotal, 2750);
        List<Service_Order_Line_Item__c> SOli1 = [select Id, Qty_Committed__c, Fixed_Price__c, Total__c from Service_Order_Line_Item__c limit 100];
        system.assertEquals(SOli1.size(), 0);
        
        
        
     }
     
       /*static testMethod void moveKitItemFromServiceOrderToMerchandiseTest() {
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        
        insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
        
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, false, KitHeader.Id, 5.0, LabourCode.Id, Part.Id, 2, 5.0);    
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        Test.startTest();
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        //Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
        
        //system.assert(false, soHeaderDetailsObj2 );
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded, 50.00);
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        List<Service_Order_Line_Item__c> SOli = [select Id, Qty_Committed__c, Fixed_Price__c, Total__c from Service_Order_Line_Item__c limit 100];
        system.assertEquals(SOli.size(), 1);
        Test.stoptest();
        String movedLineItem = BPUtility.getDecodedString(CustomerOrderCtrl.moveLineItem(BPUtility.getEncodedString(null), BPUtility.getEncodedString('Merchandise'), BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.Id), BPUtility.getEncodedString(CoHeader.Id))) ;
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(movedLineItem, COHeaderWrapper.class);
        
        //system.assert(false, coHeaderDetails);
        Commented by nidhi
        system.assertEquals(coHeaderDetails.COKHList[0].COLIList[0].AvaliablePartsQty, 98);
        system.assertEquals(coHeaderDetails.COKHList[0].COLIList[0].SubTotal, 200);
        List<Service_Order_Line_Item__c> SOli1 = [select Id, Qty_Committed__c, Fixed_Price__c, Total__c from Service_Order_Line_Item__c limit 100];
        system.assertEquals(SOli1.size(), 0);
        }*/
        
        
     static testMethod void moveLineItemFromMerchToSOTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        //Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        //Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        //Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        //Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        //Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        //Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, LabourCode.Id, Part.Id, 1, 5.0);    
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 40);
        
        List<CO_Line_Item__c> colineitemList = [select Part__c, Qty_Committed__c, Qty__c, Status__c from CO_Line_Item__c];
        //system.assert(false, colineitemList);
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        Test.startTest();
        String movedLineItem = BPUtility.getDecodedString(CustomerOrderCtrl.moveLineItem(BPUtility.getEncodedString('Merchandise'),BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(colineitemList[0].Id), BPUtility.getEncodedString(CoHeader.Id))) ;
        SOHeaderWrapper SOHeaderDetails1 = (SOHeaderWrapper) System.JSON.deserialize(movedLineItem, SOHeaderWrapper.class);
        Test.stoptest();
        
        String SOHeaderDetails12 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj13 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails12, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj13 );
        system.assertEquals(soHeaderDetailsObj13.SOList[0].SOGridItems[0].SOKH.SOLIList[0].StockCommited, 40);
        system.assertEquals(soHeaderDetailsObj13.SOList[0].SOGridItems[0].SOKH.SOLIList[0].KitPrice, 55);
        List<Service_Order_Line_Item__c> SOli1 = [select Id, Qty_Committed__c, Fixed_Price__c, Total__c from Service_Order_Line_Item__c limit 100];
        system.assertEquals(SOli1.size(), 1);
        
        
        
     }
     
 static testMethod void moveKitLineItemFromMerchToSOTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        //Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, false, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, null, Part.Id, 1, 5.0);    
        
        //CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 40);
        
        String insertKitHeaderInMerchGridDetails = BPUtility.getDecodedString(CustomerOrderCtrl.insertKitHeaderInMerchGrid( BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(coHeader.Id)));
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(insertKitHeaderInMerchGridDetails, COHeaderWrapper.class);
        //system.assert(false, coHeaderDetails1 );
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        Test.startTest();
        String movedLineItem = BPUtility.getDecodedString(CustomerOrderCtrl.moveLineItem(BPUtility.getEncodedString('Merchandise'), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id ), BPUtility.getEncodedString(coHeaderDetails1.COKHList[0].Id), BPUtility.getEncodedString(CoHeader.Id))) ;
        SOHeaderWrapper SOHeaderDetails1 = (SOHeaderWrapper) System.JSON.deserialize(movedLineItem, SOHeaderWrapper.class);
        Test.stoptest();
        
        String SOHeaderDetails12 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj13 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails12, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj13 );
        system.assertEquals(soHeaderDetailsObj13.SOList[0].SOGridItems[0].SOKH.SOLIList[0].StockCommited, 1);
        system.assertEquals(soHeaderDetailsObj13.SOList[0].SOGridItems[0].SOKH.SOLIList[0].KitPrice, 55.00);
        List<Service_Order_Line_Item__c> SOli1 = [select Id, Qty_Committed__c, Fixed_Price__c, Total__c from Service_Order_Line_Item__c limit 100];
        system.assertEquals(SOli1.size(), 1);
        }
        
            /*
     * Name: SOCompleteFlowTest
     * Desc: Test to check complete flow for SO.
     * @param: 
     * @return: 
    **/
     static testMethod void partReturnTest() {
        
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
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, -2);
        List<CO_Line_Item__c> colineitemList = [select Part__c, Qty_Committed__c, Qty__c, Status__c, Sub_Total_Without_Tax__c, Sub_Total_With_Tax__c from CO_Line_Item__c];
        //system.assert(false, colineitemList);
        
        String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetails(BPUtility.getEncodedString(coHeader.Id)));
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
            
            
        String savedCOInvoicePayment = BPUtility.getDecodedString(CustomerOrderCtrl.saveCOInvoicePayment(BPUtility.getEncodedString('[{"ReverseLink":null,"PaymentMethod":"Cash","Amount":"-110.000","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'"}]')));
        
            // Closing invoice
            
        String closedInvoiceAction = BPUtility.getDecodedString(CustomerOrderCtrl.closedInvoiceAction(BPUtility.getEncodedString('[{"Total":-110.000,"TaxAmount":null,"Saving":null,"RetailPrice":null,"QtyRequired":null,"Qty":null,"Price":null,"Item":"Service Job 1","IsInvoiceable":true,"IsActive":true,"COLineItemId":null,"COInvoiceItemNumber":null,"COInvoiceItemId":"'+coHeaderDetails.coInvoiceItemRecs[0].COInvoiceItemId+'","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'","$$hashKey":"object:56"}]'), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('Customer')));
            // checking on invoice history details
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(closedInvoiceAction, COHeaderWrapper.class);
        //system.assert(false, coHeaderDetails1);
        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].NumberOfItems, 1);
        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].Total, -110);
        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].Tax, 0);
        system.assertEquals(coHeaderDetails1.COInvoiceItemRecs.size(), 0);
        
       List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c];
            // committed qty should be  500 as same is required for customer for SO.
        system.assertEquals(partList[0].Qty_In_Stock__c, 102.00);
        system.assertEquals(partList[0].Qty_Committed__c, 0.00);
        system.assertEquals(partList[0].Qty_On_Order__c, 0);
        

    }
   
		static testMethod void partReturnFromSOSectionTest() {
		        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
		        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
		        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
		        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
		        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
		        
		        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
		        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
		        Transaction_Type__c transactionType =  TestUtil.createTransactionType(true, 'Customer', 'Customer');
		        Test.StartTest();
		        partReturnFromSOSectionTestAsyncHandling(coHeader.Id, transactionType.Id, part.Id, customer.Id);
		        Test.StopTest();
		}

		@future
		private static void partReturnFromSOSectionTestAsyncHandling(String coHeaderId, String transactionTypeId, String partId, String customerId) {
			String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeaderId)));
	        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader')));
	        
	        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
	        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c(Id = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id);
	        soHeaderRec.Transaction_Type__c = transactionTypeId;
	        update soHeaderRec;
	        
	        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
	        
	        
	        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(partId), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(customerId)));
	        
	        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
	        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
	        
	        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = -50.00 ;
	        
	        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
	        COLineItemTriggerHelper.isTriggerExecute = false;
	        COTriggerHelper.isTriggerExecute = false;
	        
	        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeaderId)));
	        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
	        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
	
	        
	        //soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
	        
	        //system.assert(false, soHeaderDetailsObj2 );
	        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
	        
	        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(jsonStr)));
	        
	        //system.assert(false, soHeaderDetailsObj2 );
	        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded, -50.00);
	        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
	        List<Service_Order_Line_Item__c> SOli = [select Id, Qty_Committed__c, Fixed_Price__c, Total__c from Service_Order_Line_Item__c limit 100];
	        //system.assert(false, SOli);
	        system.assertEquals(SOli.size(), 1);
	
	        //String details = CustomerOrderCtrl.getCOHeaderDetails(coHeader.Id);
	        String details = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
	        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(details, COHeaderWrapper.class);
	
	        String savedCOInvoicePayment = BPUtility.getDecodedString(CustomerOrderCtrl.saveCOInvoicePayment(BPUtility.getEncodedString('[{"ReverseLink":null,"PaymentMethod":"Cash","Amount":"-2750.000","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'"}]')));
	        
	            // Closing invoice
	            
	        String closedInvoiceAction = BPUtility.getDecodedString(CustomerOrderCtrl.closedInvoiceAction(BPUtility.getEncodedString('[{"Total":-2750.000,"TaxAmount":null,"Saving":null,"RetailPrice":null,"QtyRequired":null,"Qty":null,"Price":null,"Item":"Service Job 1","IsInvoiceable":true,"IsActive":true,"COLineItemId":null,"COInvoiceItemNumber":null,"COInvoiceItemId":"'+coHeaderDetails.coInvoiceItemRecs[0].COInvoiceItemId+'","COInvoiceHeaderId":"'+coHeaderDetails.coInvoiceHeaderRec.COInvoiceHeaderId+'","$$hashKey":"object:56"}]'),BPUtility.getEncodedString( coHeaderId), BPUtility.getEncodedString('Customer')));
	            // checking on invoice history details
	        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(closedInvoiceAction, COHeaderWrapper.class);
	        //system.assert(false, coHeaderDetails1);
	        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].NumberOfItems, 1);
	        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].Total, -2750);
	        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].Tax, 0);
	        system.assertEquals(coHeaderDetails1.COInvoiceItemRecs.size(), 0);
	        
	       List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c];
	            // committed qty should be  500 as same is required for customer for SO.
	        system.assertEquals(partList[0].Qty_In_Stock__c, 150.00);
	        system.assertEquals(partList[0].Qty_Committed__c, 0.00);
	        system.assertEquals(partList[0].Qty_On_Order__c, 0);
		}

	static testMethod void deleteSOFromCOSection() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        String customerorder = BPGlobalHeaderCtrl.createCustomerOrder();
        List<CO_Header__c> coHeader = [select Status__c, Customer__c, Order_status__c from CO_Header__c];
        //ListCO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        //Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        //Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        //Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        //Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        //Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        //Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, LabourCode.Id, Part.Id, 1, 5.0);    
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader[0].Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader[0].Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        //CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 2);
        
        List<CO_Header__c> coheaderdetail = [select Status__c, Customer__c, Order_status__c from CO_Header__c];
        //system.assert(false, coheaderdetail);
        
        String deleteSO = BPUtility.getDecodedString(CustomerOrderCtrl.deleteServiceOrder(BPUtility.getEncodedString(coHeader[0].Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader[0].Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj2.SOList.size(), 0);
        
}
/*
 static testMethod void moveKitItemFromOneServiceOrderToAnother() {
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        insert new List<SObject>{vendor, testCategory, defaultPriceLevel, defaultSalesTax, customer};
        
        Part__c part = TestUtil.createPart(false, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        insert new List<SObject>{part,coHeader};
        Labour_Code__c labourCode = TestUtil.createLabourCode(false, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(false, 'unitMakeName', '12A', true);
         insert new List<SObject>{unitmake,labourCode};
        Test.startTest(); 
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, false, KitHeader.Id, 5.0, LabourCode.Id, Part.Id, 2, 5.0);    
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
       
        Test.stoptest();
        VendorOrderReceivingCtrl_PartialTest.moveKitItemFromOneServiceOrderToAnother_partial(coHeader.Id, SOHeaderDetails,kitHeader.Id,customer.Id);//Added by Nikhil - 24-05-17
       
        }*/

        
 static testMethod void moveLineItemFromOneServiceOrderToAnother() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(false, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer = TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        
        insert new List<SObject>{testCategory, defaultPriceLevel, defaultSalesTax, part};
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        //Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, true, unitMake.Id, unitModel.Id);
        //Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, false, KitHeader.Id, 5.0, LabourCode.Id, Part.Id, 2, 5.0);    
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
        
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded, 50.00);
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String soHeader11 = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails11 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj11 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails11, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj11.SOList[1].SOHeaderInfo.Name, 'Service Job 2');
        
        CustomerOrderCtrl_PartialTest.moveLineItemFromOneServiceOrderToAnother(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id, soHeaderDetailsObj11.SOList[1].SOHeaderInfo.Id, soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].Id, CoHeader.Id);
        Test.stoptest();
        String SOHeaderDetails23 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj24 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails23, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj24 );
        system.assertEquals(soHeaderDetailsObj24.SOList[1].SOHeaderInfo.Total, 2750);
        List<Service_Order_Line_Item__c> SOli1 = [select Id, Qty_Committed__c, Fixed_Price__c, Total__c from Service_Order_Line_Item__c limit 100];
        
        system.assertEquals(SOli1.size(), 1);
        }
        
 static testMethod void gridTotalTest() {
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 20);
        
        String gridTotal = BPUtility.getDecodedString(CustomerOrderCtrl.getGridTotal(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString('merchandise'), false));
        COHeaderWrapper.GridTotal gridTotals = (COHeaderWrapper.GridTotal) System.JSON.deserialize(gridTotal, COHeaderWrapper.GridTotal.class);
        system.assertEquals(gridTotals.Total, 1100);
        system.assertEquals(gridTotals.Total_Part, 1100);
     
 }
 
static testMethod void gridTotalforKitInMerchandiseSectionTest() 
        {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Transaction_Type__c transactionType = TestUtil.createTransactionType(true, 'code', 'Customer');
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, false, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, Part.Id, 3, 5.0);
        //Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, fee.Id, null, 1, 5.0);
        //Kit_Header_Line_Item__c kitHeaderLineItem2 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, labourCode.Id, null, 1, 5.0);    
        
        String insertKitHeaderInMerchGridDetails = BPUtility.getDecodedString(CustomerOrderCtrl.insertKitHeaderInMerchGrid( BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(coHeader.Id)));
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 20);
        String InsertFeeInMerchDetails = BPUtility.getDecodedString(CustomerOrderCtrl.insertFeeInMerchGrid( BPUtility.getEncodedString(fee.Id), BPUtility.getEncodedString(coHeader.Id)));
        
        /*List<CO_Line_Item__c> colineitems = [select  Qty_Committed__c, Qty__c from CO_Line_Item__c];
        system.assert(false, colineitems);*/
        
        String gridTotal = BPUtility.getDecodedString(CustomerOrderCtrl.getGridTotal(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString('merchandise'), true));
        COHeaderWrapper.GridTotal gridTotals = (COHeaderWrapper.GridTotal) System.JSON.deserialize(gridTotal, COHeaderWrapper.GridTotal.class);
        //system.assert(false, gridTotals);
        system.assertEquals(gridTotals.Total, 1365);
        system.assertEquals(gridTotals.Total_Part, 1265);
        system.assertEquals(gridTotals.Total_Fee, 100);
        //system.assertEquals(gridTotals.PriceOverrides, 0);
        }
  /**nidhi 
  static testMethod void gridTotalforKitInSOSectionTest() 
        {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Transaction_Type__c transactionType = TestUtil.createTransactionType(true, 'code', 'Customer');
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, Part.Id, 3, 5.0);
        //Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, fee.Id, null, 1, 5.0);
        Kit_Header_Line_Item__c kitHeaderLineItem2 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 10.0, labourCode.Id, null, 1, 10.0);    
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsList);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
         
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id))); 
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        Test.startTest();
        String lineitems1 = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        String lineitems2 = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(fee.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        String lineitems3 = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(labourCode.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        
        /*List<CO_Line_Item__c> colineitems = [select  Qty_Committed__c, Qty__c from CO_Line_Item__c];
        system.assert(false, colineitems);
        List<Service_Order_Line_Item__c> SOli1 = [select Id, Qty_Committed__c, Fixed_Price__c, Total__c from Service_Order_Line_Item__c limit 100];
        system.assert(false, SOli1);*/
        /**nidhi
        String gridTotal = BPUtility.getDecodedString(CustomerOrderCtrl.getGridTotal(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(null), true)); 
        COHeaderWrapper.GridTotal gridTotals = (COHeaderWrapper.GridTotal) System.JSON.deserialize(gridTotal, COHeaderWrapper.GridTotal.class);
        Test.StopTest();
        //system.assert(false, gridTotals);
        system.assertEquals(gridTotals.Total, 3200);
        system.assertEquals(gridTotals.Total_Part, 3080.00);
        system.assertEquals(gridTotals.Total_Fee, 100);
        system.assertEquals(gridTotals.Total_Laobur, 20);
        
        //system.assertEquals(gridTotals.PriceOverrides, 0);
        
        }
        nidhi**/
static testMethod void closedorderActionTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 20);
        
        list<CO_Invoice_Header__c> coInvoiceHeaderlist = [select  Status__c, Total_Payment__c from CO_Invoice_Header__c];
        //system.assert(false, coInvoiceHeaderlist );
       
         List<CO_Invoice_Item__c> COInvoiceItems = [select Category__c, CO_Line_Item__c, isActive__c, Item_Category_Code__c, Item_ID__c, Item_Type__c, Price__c, Qty__c from CO_Invoice_Item__c];
        //system.assert(false, COInvoiceItems );
        
        Test.startTest();
        String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaderlist[0].Id)));
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedorderAction(BPUtility.getEncodedString(COInvoiceItemJSON), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('Customer')));
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(closedOrder, COHeaderWrapper.class);
        Test.stopTest();
        
       
        //system.assert(false, coHeaderDetails1);
        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].NumberOfItems, 1);
        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].Total, 1100);
        system.assertEquals(coHeaderDetails1.coHeaderRec.OrderStatus, 'Closed');
        
        List<Part__c> parts = [select AvailableParts__c from Part__c where Id = :part.id ];
        system.assertEquals(parts[0].AvailableParts__c, 80);
        
        }
    /*    
static testMethod void closedorderActionforMultipleInvoiceItemsTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(true, 'Customer', 'Customer');
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 20);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, false, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, Part.Id, 3, 5.0);
        //Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, fee.Id, null, 1, 5.0);
        //Kit_Header_Line_Item__c kitHeaderLineItem2 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, labourCode.Id, null, 1, 5.0);    
        
        String insertKitHeaderInMerchGridDetails = BPUtility.getDecodedString(CustomerOrderCtrl.insertKitHeaderInMerchGrid( BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(coHeader.Id)));
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        //SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsList);
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c(Id = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id);
        soHeaderRec.Transaction_Type__c = transactionType.Id;
        update soHeaderRec;
        
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id))); 
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        Test.startTest();
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        list<CO_Invoice_Header__c> coInvoiceHeaderlist = [select  Status__c, Total_Payment__c from CO_Invoice_Header__c];
        //system.assert(false, coInvoiceHeaderlist );
       
        //List<CO_Invoice_Item__c> COInvoiceItems = [select Category__c, CO_Line_Item__c, isActive__c, Item_Category_Code__c, Item_ID__c, Item_Type__c, Price__c, Qty__c from CO_Invoice_Item__c];
        //system.assert(false, COInvoiceItems );
        
        
        String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaderlist[0].Id)));
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedorderAction(BPUtility.getEncodedString(COInvoiceItemJSON), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('Customer')) );
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(closedOrder, COHeaderWrapper.class);
        Test.stopTest();
       
        //system.assert(false, coHeaderDetails1);
        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].NumberOfItems, 3);
        system.assertEquals(coHeaderDetails1.COInvoiceHistoryRecs[0].Total, 4180);
        system.assertEquals(coHeaderDetails1.coHeaderRec.OrderStatus, 'Closed');
        
        List<Part__c> parts = [select AvailableParts__c from Part__c where Id = :part.id ];
        system.assertEquals(parts[0].AvailableParts__c, 27);
        
        }*/
        

static testMethod void addVOHeaderToCOLITestA() {
     
        VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};
        //System.JSON.serialize(pageSort)
        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;

         
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 2;
        insert part;
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(true, Vendor.Id);
        Vendor_Order_Header__c voHeader1 = TestUtil.createVendorOrderHeader(true, Vendor.Id);
        
        List<CO_Line_Item__c> colineitem12 = [select Part__c, Qty_Committed__c, Qty__c, Status__c from CO_Line_Item__c];
        
        Test.startTest();
        String assignVOHeader = BPUtility.getDecodedString(CustomerOrderCtrl.addVOHeaderToCOLI(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(colineitem12[0].Id), BPUtility.getEncodedString(voHeader1.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllSimilarVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(voHeader1.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        Test.stopTest();
        system.assertEquals(voLineItems.TotalLineItemGroups, 1);
        system.assertEquals(voLineItems.VendorOrderLineItemGroupList[0].Need, 50);
         }  
         
	static testMethod void addVOHeaderToCOLIServiceOrderTest() {
     
        VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};
        //System.JSON.serialize(pageSort)
        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 2;
        insert part;
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        Test.startTest();
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 150.00 ;
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(true, Vendor.Id);
        Vendor_Order_Header__c voHeader1 = TestUtil.createVendorOrderHeader(true, Vendor.Id);
        
        List<CO_Line_Item__c> colineitem12 = [select Part__c, Qty_Committed__c, Qty__c, Status__c from CO_Line_Item__c];
        
        String assignVOHeader = BPUtility.getDecodedString(CustomerOrderCtrl.addVOHeaderToCOLIServiceOrder(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(colineitem12[0].Id), BPUtility.getEncodedString(voHeader1.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllSimilarVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(voHeader1.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        Test.stopTest();
        system.assertEquals(voLineItems.TotalLineItemGroups, 1);
        system.assertEquals(voLineItems.VendorOrderLineItemGroupList[0].Need, 50);
	}

	static testMethod void changeSOHeaderStatusToCompleteTest() {
     
        VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;    
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};
        //System.JSON.serialize(pageSort)
        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;

         
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 2;
        insert part;
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 150.00 ;
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
       
        String soHeaderStatus = BPUtility.getDecodedString(CustomerOrderCtrl.changeSOHeaderStatusToComplete(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id)));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(soHeaderStatus, SOHeaderWrapper.class);
        Test.stopTest();
        
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Status, 'Complete');
         
         }
         
static testMethod void getVendorOrderByVendorIdTest() {
     
        VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        pageSort.Sorting = new List<SortAttrs>{new SortAttrs('Item', 'ASC')};
        //System.JSON.serialize(pageSort)
        boolean user = new VendorOrderCtrl().isPermittedToEditVOHeader ;

         
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 2;
        insert part;
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        Test.startTest();
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 150.00 ;
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(true, vendor.Id);
        //Vendor_Order_Header__c voHeader1 = TestUtil.createVendorOrderHeader(true, vendor.Id);
        List<CO_Line_Item__c> colineitem12 = [select Part__c, Qty_Committed__c, Qty__c, Status__c from CO_Line_Item__c];
        
        //String assignVOHeader = CustomerOrderCtrl.addVOHeaderToCOLI(part.Id, colineitem12[0].Id, voHeader1.Id, coHeader.Id, System.JSON.serialize(pageSort), System.JSON.serialize(pageSort), System.JSON.serialize(pageSort));
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllSimilarVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(similarlineitem, VendorOrderLineItemWrapper.class);
        
        String vendorOrder = BPUtility.getDecodedString(CustomerOrderCtrl.getVendorOrderByVendorId(BPUtility.getEncodedString(vendor.Id)));
        Test.stopTest();
        //system.assert(false, vendorOrder);
         }
         


    static testMethod void getWizardInfoTest() {
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
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        
        //system.assert(false, soHeaderDetailsObj2 );
        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
        
        //system.assert(false, soHeaderDetailsObj3);
        
        String wizardInfo = BPUtility.getDecodedString(CustomerOrderCtrl.getWizardInfo(BPUtility.getEncodedString(soHeaderDetailsObj3.Id), BPUtility.getEncodedString('Sign_In')));
        SOWizard wizardDetails = (SOWizard) System.JSON.deserialize(wizardInfo, SOWizard.class);
        Test.stopTest();
        
        system.assertEquals(wizardDetails.Sign_In.Service_Information.Status, 'In Progress' );
         
         }
         
static testMethod void saveWizardDetailsTest() {
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
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        
        //system.assert(false, soHeaderDetailsObj2 );
        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
        
        //system.assert(false, soHeaderDetailsObj3);
        
        String wizardInfo = BPUtility.getDecodedString(CustomerOrderCtrl.getWizardInfo(BPUtility.getEncodedString(soHeaderDetailsObj3.Id), BPUtility.getEncodedString('Sign_In')));
        SOWizard wizardDetails = (SOWizard) System.JSON.deserialize(wizardInfo, SOWizard.class);
        system.assertEquals(wizardDetails.Sign_In.Service_Information.Status, 'In Progress' );
        
        CustomerApproval__c customerApproval = TestUtil.createCustomerApproval(false, 'Approved', 'Notes');
        customerApproval.Section_key__c = 'Sign_In';
        customerApproval.Service_Order_Header__c = soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id;
        insert customerApproval;
        
        String customerApprovalStr = BPUtility.getDecodedString(CustomerOrderCtrl.getCustomerApprovalInfo(BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString('Sign_In'), null));
        List<CustomerApproval> customerApprovals = (List<CustomerApproval>) System.JSON.deserialize(customerApprovalStr, List<CustomerApproval>.class);
        
        wizardDetails.Sign_In.Approval_Method = customerApprovals;
        String jsonStr1 = System.Json.serialize(wizardDetails.Sign_In);
        
        String savedWizard = BPUtility.getDecodedString(CustomerOrderCtrl.saveWizardDetails(BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString('Sign_In'), BPUtility.getEncodedString(jsonStr1), BPUtility.getEncodedString(null)));
        SOWizard wizardDetails1 = (SOWizard) System.JSON.deserialize(savedWizard, SOWizard.class);
        Test.stopTest();
        
        system.assertEquals(wizardDetails1.Sign_In.Service_Information.Status, 'In Progress' );
        system.assertEquals(wizardDetails1.Sign_In.Approval_Method[0].Status, 'Approved' );
        //system.assert(false, wizardDetails1);
        
         
         }
         
static testMethod void saveApprovalInfoTest() {
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
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        
        //system.assert(false, soHeaderDetailsObj2 );
        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
        
        //system.assert(false, soHeaderDetailsObj3);
        
        String wizardInfo = BPUtility.getDecodedString(CustomerOrderCtrl.getWizardInfo(BPUtility.getEncodedString(soHeaderDetailsObj3.Id), BPUtility.getEncodedString('Sign_In')));
        SOWizard wizardDetails = (SOWizard) System.JSON.deserialize(wizardInfo, SOWizard.class);
        system.assertEquals(wizardDetails.Sign_In.Service_Information.Status, 'In Progress' );
        
        CustomerApproval__c customerApproval = TestUtil.createCustomerApproval(false, 'Approved', 'Notes');
        customerApproval.Section_key__c = 'Sign_In';
        customerApproval.Service_Order_Header__c = soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id;
        insert customerApproval;
        
        String customerApprovalStr = BPUtility.getDecodedString(CustomerOrderCtrl.getCustomerApprovalInfo(BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString('Sign_In'), null));
        List<CustomerApproval> customerApprovals = (List<CustomerApproval>) System.JSON.deserialize(customerApprovalStr, List<CustomerApproval>.class);
        
        //wizardDetails.Sign_In.Approval_Method = customerApprovals;
        String jsonStr1 = System.Json.serialize(customerApprovals);
        
        String approvalInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveCustomerApprovalInfo(BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(jsonStr1)));
        List<CustomerApproval> customerApprovals1 = (List<CustomerApproval>) System.JSON.deserialize(approvalInfo, List<CustomerApproval>.class);
        system.assertEquals(customerApprovals1[0].IsApprovalObtained, true);
        system.assertEquals(customerApprovals1[0].ApprovalCount, 1);
         }
         
static testMethod void changeStatusTest() {
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
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;   
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        
        //system.assert(false, soHeaderDetailsObj2 );
        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
        
        //system.assert(false, soHeaderDetailsObj3);
        
        String wizardInfo = BPUtility.getDecodedString(CustomerOrderCtrl.getWizardInfo(BPUtility.getEncodedString(soHeaderDetailsObj3.Id), BPUtility.getEncodedString('Sign_In')));
        SOWizard wizardDetails = (SOWizard) System.JSON.deserialize(wizardInfo, SOWizard.class);
        system.assertEquals(wizardDetails.Sign_In.Service_Information.Status, 'In Progress' );
        
        CustomerApproval__c customerApproval = TestUtil.createCustomerApproval(false, 'Approved', 'Notes');
        customerApproval.Section_key__c = 'Sign_In';
        customerApproval.Service_Order_Header__c = soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id;
        insert customerApproval;
        
        String customerApprovalStr = BPUtility.getDecodedString(CustomerOrderCtrl.getCustomerApprovalInfo(BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString('Sign_In'), null));
        List<CustomerApproval> customerApprovals = (List<CustomerApproval>) System.JSON.deserialize(customerApprovalStr, List<CustomerApproval>.class);
        
        wizardDetails.Sign_In.Approval_Method = customerApprovals;
        String jsonStr1 = System.Json.serialize(wizardDetails.Sign_In);
        
        String savedWizard = BPUtility.getDecodedString(CustomerOrderCtrl.saveWizardDetails(BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString('Sign_In'), BPUtility.getEncodedString(jsonStr1), BPUtility.getEncodedString(null)));
        SOWizard wizardDetails1 = (SOWizard) System.JSON.deserialize(savedWizard, SOWizard.class);
        CustomerOrderCtrl.changeStatus(BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString('Complete'), BPUtility.getEncodedString('work'));
        
        String SOHeaderDetails12 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj12 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails12, SOHeaderWrapper.class);

        //system.assert(false, soHeaderDetailsObj12);
        
        Test.stopTest();
        
        System.assertEquals(soHeaderDetailsObj12.SOList[0].SOHeaderInfo.WorkStatus, 'Complete');
        
         
         }
         
static testMethod void changeStatusForclaimTest() {
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
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id),BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        
        //system.assert(false, soHeaderDetailsObj2 );
        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
        
        //system.assert(false, soHeaderDetailsObj3);
        
        String wizardInfo = BPUtility.getDecodedString(CustomerOrderCtrl.getWizardInfo(BPUtility.getEncodedString(soHeaderDetailsObj3.Id), BPUtility.getEncodedString('Sign_In')));
        SOWizard wizardDetails = (SOWizard) System.JSON.deserialize(wizardInfo, SOWizard.class);
        system.assertEquals(wizardDetails.Sign_In.Service_Information.Status, 'In Progress' );
        
        CustomerApproval__c customerApproval = TestUtil.createCustomerApproval(false, 'Approved', 'Notes');
        customerApproval.Section_key__c = 'Sign_In';
        customerApproval.Service_Order_Header__c = soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id;
        insert customerApproval;
        
        String customerApprovalStr = BPUtility.getDecodedString(CustomerOrderCtrl.getCustomerApprovalInfo(BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString('Sign_In'), null));
        List<CustomerApproval> customerApprovals = (List<CustomerApproval>) System.JSON.deserialize(customerApprovalStr, List<CustomerApproval>.class);
        
        wizardDetails.Sign_In.Approval_Method = customerApprovals;
        String jsonStr1 = System.Json.serialize(wizardDetails.Sign_In);
        
        String savedWizard = BPUtility.getDecodedString(CustomerOrderCtrl.saveWizardDetails(BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString('Sign_In'), BPUtility.getEncodedString(jsonStr1), BPUtility.getEncodedString(null)));
        SOWizard wizardDetails1 = (SOWizard) System.JSON.deserialize(savedWizard, SOWizard.class);
        CustomerOrderCtrl.changeStatus(BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString('Submitted'), BPUtility.getEncodedString('Claim'));
        
        String SOHeaderDetails12 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj12 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails12, SOHeaderWrapper.class);

        //system.assert(false, soHeaderDetailsObj12);
        
        Test.stopTest();
        
        System.assertEquals(soHeaderDetailsObj12.SOList[0].SOHeaderInfo.ClaimStatus, 'Submitted');
        
         
         }
         
static testMethod void addDeductibleTest() {
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Claims_for_Service_Work__c = true;
        insert vendor;
        
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Customer', 'Customer');
        //transactionType.Third_Party_Customer__c = customer.Id;
        insert transactionType ;
        
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 2;
        insert part;
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;  
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        //soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        
        //system.assert(false, soHeaderDetailsObj2 );
        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
        
        //system.assert(false, soHeaderDetailsObj3);
       String deductible =  BPUtility.getDecodedString(CustomerOrderCtrl.addDeductibleAmount(BPUtility.getEncodedString('{"SoHeaderId":"'+soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id+'","DeductibleStatus":null,"DeductibleId":null,"DeductibleAmount":"10","CoHeaderId":"'+coHeader.Id+'"}')));
       
       String SOHeaderDetails12 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
       SOHeaderWrapper soHeaderDetailsObj123 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails12, SOHeaderWrapper.class);
        
       Test.stoptest();
       //system.assert(false, soHeaderDetailsObj123);
       system.assertEquals(soHeaderDetailsObj123.SOList[0].DeductibleItem.DeductibleAmount, 10.000);
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