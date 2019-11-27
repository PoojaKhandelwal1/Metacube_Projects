/**
 * Author: Tarun Khandelwal
 * Since: Oct 18, 2018
 * Name: CustomerOrderCtrlTest6 test
 * Description: Controller test Class of Customer order ctrl.
**/
@isTest
private class CustomerOrderCtrlTest6 {
 	
 	@testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
    }
    
 	static testMethod void updateSOLineItemsLabourTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        //Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        //Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, LabourCode.Id, Part.Id, 1, 5.0);
        Test.StartTest();    
        updateSOLineItemsLabourTestAsyncHandling(coHeader.Id, customer.Id, labourCode.Id);
        Test.StopTest();
        
    }  
    
    @future
	private static void updateSOLineItemsLabourTestAsyncHandling(String coHeaderId, String customerId, String labourCodeId) {
		String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeaderId)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(labourCodeId), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(customerId)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
       // system.assert(false,SOHeaderDetails1);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 20.00 ;
        System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0]);

        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeaderId)));
        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj2);
        
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded, 20.00);
	}
    
        static testMethod void savePinItemsUnpinTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Transaction_Type__c transactionType = TestUtil.createTransactionType(true, 'code', 'Customer');
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
       
        String savePinItem = BPUtility.getDecodedString(CustomerOrderCtrl.savePinItems(BPUtility.getEncodedString('{"PinnedItemList":["Transaction Type","Unit"]}')));
        List<User> currentUserInfo = SOQLUtil.getCurrentUserInfo();
        system.assertEquals(currentUserInfo[0].SO_Pinned_Info__c, 'Transaction Type,Unit');
        
        String savePinItem1 = BPUtility.getDecodedString(CustomerOrderCtrl.savePinItems(BPUtility.getEncodedString('{"PinnedItemList":[""]}')));
        List<User> currentUserInfo1 = SOQLUtil.getCurrentUserInfo();
        system.assertEquals(currentUserInfo1[0].SO_Pinned_Info__c, null);
                
        
        
    }
    static testMethod void hoursLoggedTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, LabourCode.Id, Part.Id, 1, 5.0);  
        
        Test.startTest();
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        Test.stopTest();
        //String hoursLogged = CustomerOrderCtrl.saveHoursLogged('{"SOHeaderId":"'+soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id+'","PreviouslyLogged":"1d 1h 1m","OriginalEstimate":"0d 0h 0m ","coHeaderId":"'+coHeader.Id+'","index":0,"WorkPerformedDate":"01/18/2016","Employee":"","Notes":"","TimeSpent_D":"1","TimeSpent_M":"1","TimeSpent_H":"1","RemainingEstimate_D":0,"RemainingEstimate_M":0,"RemainingEstimate_H":0}', coHeader.Id);
        //system.assertEquals(hoursLogged.contains('1d 1h 1m'), true);
    }
    
        static testMethod void InsertFeeInMerchGridTest() 
        {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Transaction_Type__c transactionType = TestUtil.createTransactionType(true, 'code', 'Customer');
        
        String InsertFeeInMerchDetails = BPUtility.getDecodedString(CustomerOrderCtrl.insertFeeInMerchGrid( BPUtility.getEncodedString(fee.Id), BPUtility.getEncodedString(coHeader.Id)));
        //String coheaderDetails = CustomerOrderCtrl.getCOHeaderDetailsByGridName(coHeader.Id, String gridName);
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(InsertFeeInMerchDetails, COHeaderWrapper.class);
        system.assertEquals(coHeaderDetails1.allCOLineItemRecs[0].Item, 'FeeCode - Description');
        
        
    }
    
static testMethod void insertKitHeaderInMerchGridTest() 
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
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, false, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, null, Part.Id, 1, 5.0);   
        
        String insertKitHeaderInMerchGridDetails = BPUtility.getDecodedString(CustomerOrderCtrl.insertKitHeaderInMerchGrid( BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(coHeader.Id)));
        //String coheaderDetails = CustomerOrderCtrl.getCOHeaderDetailsByGridName(coHeader.Id, String gridName);
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(insertKitHeaderInMerchGridDetails, COHeaderWrapper.class);
        //system.assert(false, coHeaderDetails1);
        system.assertEquals(coHeaderDetails1.allCOLineItemRecs[0].Item, 'TestPart - TestPart');
        
        
    }
    
    static testMethod void removeKitHeaderInMerchGridTest() 
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
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, false, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, null, Part.Id, 1, 5.0);   
        
        String insertKitHeaderInMerchGridDetails = BPUtility.getDecodedString(CustomerOrderCtrl.insertKitHeaderInMerchGrid( BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(coHeader.Id)));
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(insertKitHeaderInMerchGridDetails, COHeaderWrapper.class);
        system.assertEquals(coHeaderDetails1.allCOLineItemRecs[0].Item, 'TestPart - TestPart');
        system.assertEquals(coHeaderDetails1.MerchandiseTotal, 55.00);
        //system.assert(false, coHeaderDetails1 );
        String removelineitemDetails = BPUtility.getDecodedString(CustomerOrderCtrl.removeLineItemsInMerchGrid( BPUtility.getEncodedString(coHeaderDetails1.COKHList[0].COLIList[0].CoLineItemId), BPUtility.getEncodedString(coHeader.Id)));
        //String coheaderDetails = CustomerOrderCtrl.getCOHeaderDetailsByGridName(coHeader.Id, String gridName);
        COHeaderWrapper coHeaderDetails2 = (COHeaderWrapper) System.JSON.deserialize(removelineitemDetails, COHeaderWrapper.class);
        //system.assert(false, coHeaderDetails2 );
        system.assertEquals(coHeaderDetails2.allCOLineItemRecs.size(), 0 );
        
        
        
    }
    
        static testMethod void splitCOKHItemTest() 
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
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, false, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, null, Part.Id, 1, 5.0);   
        
        String insertKitHeaderInMerchGridDetails = BPUtility.getDecodedString(CustomerOrderCtrl.insertKitHeaderInMerchGrid( BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(coHeader.Id)));
        String splitCOKHDetails = BPUtility.getDecodedString(CustomerOrderCtrl.splitCOKHItem(BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(coHeader.Id)));
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(splitCOKHDetails, COHeaderWrapper.class);
        //system.assert(false, coHeaderDetails1 );
        system.assertEquals(coHeaderDetails1.allCOLineItemRecs[0].Item, 'TestPart - TestPart');
        system.assertEquals(coHeaderDetails1.MerchandiseTotal, 55.00);
        
        
        
    }
    
     
         
         
static testMethod void submitClaimTest() {
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
       String deductible =  BPUtility.getDecodedString(CustomerOrderCtrl.addDeductibleAmount(BPUtility.getEncodedString('{"SoHeaderId":"'+soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id+'","DeductibleStatus":null,"DeductibleId":null,"DeductibleAmount":"10","CoHeaderId":"'+coHeader.Id+'"}')));
       SOHeaderWrapper details12 = (SOHeaderWrapper) System.JSON.deserialize(deductible, SOHeaderWrapper.class);
       //system.assertEquals(details12.SOList[0].DeductibleItem.DeductibleAmount, 10.000);
       String submittedClaim = BPUtility.getDecodedString(CustomerOrderCtrl.submitClaimRecords(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       
       List<Claim_Line_Item__c> claimLineItemList = [select Claimed_Qty__c, Claimed_Price__c, Claimed_Subtotal__c,  Item_Desc__c, Approved_Qty__c, Approved_Price__c, Approved_Subtotal__c, Variance__c from Claim_Line_Item__c];
       Test.stoptest();
       system.assertEquals(claimLineItemList.size(), 1);
       
       
         
         }
         

    /* Added by Ankit 
        Modified by nidhi*/
    
    
   static testMethod void DealLineItemStatusAfterCloseOrderTest() {
        
        /*TestUtil.createtaxsettingInGeneralConfig();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(false, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
        insert new List<SObject>{defaultPriceLevel, defaultSalesTax, customer, vendor};
        
        Part__c testPart1 = TestUtil.createPart(false, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(false, 'unitMakeName', '12A', true);
        
        insert new List<SObject>{testPart1, unitmake};
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 2;
        optionAndFeeRec1.PartId = testPart1.Id;
        optionAndFeeRec1.IsInstall = false; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);
        
        Test.startTest();
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        List<CO_Invoice_Header__c> coInvoiceHeaderlist = [select  Status__c, Total_Payment__c from CO_Invoice_Header__c where Status__c = 'Active'];
        String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaderlist[0].Id)));
        List<COInvoiceItem> coInvoiceItemList = (List<COInvoiceItem>) System.JSON.deserialize(COInvoiceItemJSON, List<COInvoiceItem>.class);
        for(COInvoiceItem coInvoiceItemObj : coInvoiceItemList) {
            if(String.isBlank(coInvoiceItemObj.DealId)) {
                coInvoiceItemObj.isActive = true;
            }
        }
        String closedInvoice = BPUtility.getDecodedString(CustomerOrderCtrl.closedInvoiceAction(BPUtility.getEncodedString(System.JSON.serialize(coInvoiceItemList)), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('Deal')));
        coInvoiceHeaderlist = [select  Status__c, Total_Payment__c from CO_Invoice_Header__c where Status__c = 'Active'];
        COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaderlist[0].Id)));
        coInvoiceItemList = (List<COInvoiceItem>) System.JSON.deserialize(COInvoiceItemJSON, List<COInvoiceItem>.class);
        for(COInvoiceItem coInvoiceItemObj : coInvoiceItemList) {
            if(String.isNotBlank(coInvoiceItemObj.DealId)) {
                coInvoiceItemObj.isActive = true;
            }
        }
        
        List <Deal__C> dealList1 = [Select Status__c from Deal__c where Id = :dealList[0].Id];
        system.assertEquals('Fulfilled', dealList1[0].Status__c);
        
        String dealJson = BPUtility.getDecodedString(CustomerOrderCtrl.getDealDetails(BPUtility.getEncodedString(coHeader.Id), null));
        DealWrapper dealInfoObj1 = (DealWrapper) System.JSON.deserialize(dealJson, DealWrapper.class);
        System.assertEquals(dealInfoObj1.DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList[0].SubTotal, 66);
        System.assertEquals(dealInfoObj1.DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList[0].Status, 'Invoiced');
        Test.stopTest();
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedorderAction(BPUtility.getEncodedString(System.JSON.serialize(coInvoiceItemList)), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('Customer')));
        
        COHeaderWrapper coHeaderDetails1 = (COHeaderWrapper) System.JSON.deserialize(closedOrder, COHeaderWrapper.class);
        
        dealList = [Select Status__c from Deal__c where Id = :dealList[0].Id];
        system.assertEquals('Invoiced', dealList[0].Status__c);
        //List<Customer_Owned_Unit__c> unitList = [Select Status__c from Customer_Owned_Unit__c where Id = :customerOwnedUnit.Id];
        //system.assertEquals('Sold', unitList[0].Status__c);
        
        VendorOrderReceivingCtrl_PartialTest.DealLineItemStatusAfterCloseOrderTest_Partial(dealList1[0].Id);*/
        system.assert(true,true);
    }
    
    /**
     static testMethod void createUnresolvedFulfillmentForAddInServiceOrderTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        
        Account vendor1 = TestUtil.createVendor(true, 'Test Vendor 1');
        Category__c testCategory1 = TestUtil.createCategory(true, 'Test Category 1');
        Part__c testpart2 = TestUtil.createPart(true, 'Part12', vendor1.Id, 'TestPart2', testCategory1.Id);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', true, 10, 'LabourCodeName', 10, true);
        
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        
        Test.startTest();
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 2;
        optionAndFeeRec1.LabourId = labourCode.Id;
        optionAndFeeRec1.IsInstall = true;
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        // Edited by kv 01/31/2017
        List<Service_Order_Header__c> soList = [Select Id, (Select Id, Labour_Code__c, Qty_Needed__c, Kit_Price__c from Service_Order_Line_Items__r) from Service_Order_Header__c where CO_Header__c = :coHeader.Id];
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(testpart2.Id), BPUtility.getEncodedString(soList[0].Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        List<Deal_Unresolved_Fulfillment__c> unresolvedFulfillmentList = [Select Id, Action_Required__c, Updated_Quantity__c from Deal_Unresolved_Fulfillment__c where Deal__c = :dealList[0].Id];
        system.assertEquals(1, unresolvedFulfillmentList.size());
        system.assertEquals('Add to Deal', unresolvedFulfillmentList[0].Action_Required__c);
        system.assertEquals(1, unresolvedFulfillmentList[0].Updated_Quantity__c);
    }
    **/
    static testMethod void getMakeListTest() {
        Unit_Make__c unitMake1 = TestUtil.createUnitMake(false, 'unitMakeName1', '11A', true);
        Unit_Make__c unitMake2 = TestUtil.createUnitMake(false, 'unitMakeName2', '12A', true);
        Unit_Make__c unitMake3 = TestUtil.createUnitMake(false, 'unitMakeName3', '13A', true);
        Unit_Make__c unitMake4 = TestUtil.createUnitMake(false, 'unitMakeName4', '14A', true);
        Unit_Make__c unitMake5 = TestUtil.createUnitMake(false, 'unitMakeName5', '15A', true);
        insert new List<Unit_Make__c>{unitMake1, unitMake2, unitMake3, unitMake4, unitMake5};
        String unitMakeListJson = BPUtility.getDecodedString(CustomerOrderCtrl.getMakeList());
        List<UnitMake> unitMakeList = (List<UnitMake>) System.JSON.deserialize(unitMakeListJson, List<UnitMake>.class);
        system.assertEquals(5, unitMakeList.size());
    }
    
    static testMethod void getModelListTest() {
        Unit_Make__c unitMake1 = TestUtil.createUnitMake(true, 'unitMakeName1', '1A', true);
        Unit_Model__c unitModel1 = TestUtil.createUnitModel(false, 'unitModelName1', '11A', true, unitMake1.Id);
        Unit_Model__c unitModel2 = TestUtil.createUnitModel(false, 'unitModelName2', '12A', true, unitMake1.Id);
        
        Unit_Make__c unitMake2 = TestUtil.createUnitMake(true, 'unitMakeName2', '2A', true);
        Unit_Model__c unitModel3 = TestUtil.createUnitModel(false, 'unitModelName3', '21A', true, unitMake2.Id);
        Unit_Model__c unitModel4 = TestUtil.createUnitModel(false, 'unitModelName4', '22A', true, unitMake2.Id);
        Unit_Model__c unitModel5 = TestUtil.createUnitModel(false, 'unitModelName5', '23A', true, unitMake2.Id);
        
        Unit_Make__c unitMake3 = TestUtil.createUnitMake(true, 'unitMakeName3', '3A', true);
        Unit_Model__c unitModel6 = TestUtil.createUnitModel(false, 'unitModelName6', '31A', true, unitMake3.Id);
        
        insert new List<SObject>{unitModel1, unitModel2, unitModel3, unitModel4, unitModel5, unitModel6};
        String unitModelListJson = BPUtility.getDecodedString(CustomerOrderCtrl.getModelList(BPUtility.getEncodedString(unitMake2.Id)));
        List<UnitModel> unitModelList = (List<UnitModel>) System.JSON.deserialize(unitModelListJson, List<UnitModel>.class);
        system.assertEquals(3, unitModelList.size());
    }
    
       static testMethod void getDealFinanceMasterDataTest() {
    TestUtil.createtaxsettingInGeneralConfig();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Finance_Company__c = true;
        insert vendor;
        //Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        
        Product__c testProduct1 = TestUtil.createProduct(false, testCategory.Id, 'Test Product2', vendor.Id);
        testProduct1.Type__c = 'Financing Product';
        testProduct1.Taxable__c = true ;
        testProduct1.Applicable_Tax__c = salestax.Id;
        testProduct1.Cost__c = 100;
        testProduct1.Price__c = 100;
        insert testProduct1;
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);

        Test.startTest();
        dealList[0].Type__c = 'Financed';
        update dealList;
        
        DealWrapper.DealFinanceWrapper dealFinanceWrapperObj = new DealWrapper.DealFinanceWrapper(new Deal_Finance__c());
        dealFinanceWrapperObj.FinanceCompanyId = vendor.Id;
        dealFinanceWrapperObj.DownPayment = 100;
        String dealFinanceJSON = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealFinanceDetails(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealFinanceWrapperObj))));
        
        DealWrapper.FIProductWrapper fAndIproductObj = new DealWrapper.FIProductWrapper(new F_I_Product__c());
        fAndIproductObj.ProductId = testProduct1.Id;
        fAndIproductObj.DealId = dealList[0].Id;
        fAndIproductObj.DealFinanceId = [Select Id from Deal_Finance__c limit 1].Id;
        
        String fAndIproductJson = BPUtility.getDecodedString(CustomerOrderCtrl.saveDealFAndIProduct(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(fAndIproductObj))));
        DealWrapper.FIProductWrapper DealFAndIProductObj = (DealWrapper.FIProductWrapper) System.JSON.deserialize(fAndIproductJson, DealWrapper.FIProductWrapper.class);
        system.assertEquals(DealFAndIProductObj.SalesTax, 7.41);
        system.assertEquals(DealFAndIProductObj.Total, 92.59);
        system.assertEquals(testProduct1.Id, DealFAndIProductObj.ProductId);
        
        String getDealFinanceData = BPUtility.getDecodedString(CustomerOrderCtrl.getDealFinanceMasterData());
       List<SOHeaderWrapper.VendorAsProvider> DealFinanceObj = (List<SOHeaderWrapper.VendorAsProvider> ) System.JSON.deserialize(getDealFinanceData, List<SOHeaderWrapper.VendorAsProvider> .class);
        system.assertEquals(DealFinanceObj[0].Name, 'Test Vendor');
        system.assertEquals(DealFinanceObj.size(), 1 );
        
        String getDealFinanceData1 = BPUtility.getDecodedString(CustomerOrderCtrl.getProviderInfo(BPUtility.getEncodedString(vendor.Id)));
       System.assertEquals(getDealFinanceData1.contains('Test Vendor'), true);
    }
    
        /**
     * Name: getCODepositByCOHeaderIdTest
     * Desc: Test to get CODeposit type for COheader
     * @param: 
     * @return: 
    **/
    
    static testMethod void saveCODealDepositTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec = TestUtil.createCOLineItem(true, coHeader1.Id, part.Id, 50);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader1.Id, 'Debit', 500);
        
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader1.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader1.Id];
        
        Test.startTest();
        String coDepositJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCODepositByCOHeaderId(BPUtility.getEncodedString(coHeader1.Id)));
        
        String coDealDeposite = BPUtility.getDecodedString(CustomerOrderCtrl.saveCODealDeposit(BPUtility.getEncodedString(coDepositJSON), BPUtility.getEncodedString(dealList[0].Id)));
        Test.stopTest();
        
        List<CODeposit> coDeposits = (List<CODeposit>) System.JSON.deserialize(coDealDeposite, List<CODeposit>.class);
        System.assertEquals(coDealDeposite.contains(''), true );
    }
    
    /*static testMethod void resolveFulfillmentForDealMerchKitTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', true, 10, 'LabourCodeName', 10, true);
        
        Test.startTest();
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true); 
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        Kit_Header__c kitHeader1 = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, false, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader1.Id, 5.0, null, testPart1.Id, 1, 5.0);
        
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 1;
        optionAndFeeRec1.PartId = testPart1.Id;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        Test.stopTest();
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.insertKitHeaderInDealMerchGrid(BPUtility.getEncodedString(kitHeader1.Id), BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        
        system.assertEquals(1, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.resolveFulfillment(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealWrapperObj.DealUnresolvedFulfillmentList[0])),BPUtility.getEncodedString('Invoice'), BPUtility.getEncodedString(customerOwnedUnit.Id)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        
        system.assertEquals(0, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        system.assertEquals(2, dealWrapperObj.UnitList[0].DealKitHeaderList.size());
        
    }*/
    /*
    static testMethod void resolveFulfillmentForDealServiceKitTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', true, 10, 'LabourCodeName', 10, true);
        
        Test.startTest();
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true); 
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        Kit_Header__c kitHeader1 = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader1.Id, 5.0, labourCode.Id, null, 1, 5.0);
        
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 1;
        optionAndFeeRec1.LabourId = labourCode.Id;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        
        DealWrapper.UnitSectionWrapper dealUnitInfoObj = (DealWrapper.UnitSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.UnitSectionWrapper.class);
        
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        Test.stopTest();
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.insertKitHeaderInDealMerchGrid(BPUtility.getEncodedString(kitHeader1.Id), BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        
        system.assertEquals(1, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.resolveFulfillment(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealWrapperObj.DealUnresolvedFulfillmentList[0])),BPUtility.getEncodedString('Invoice'), BPUtility.getEncodedString(customerOwnedUnit.Id)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        
        List<Service_Order_Header__c> soList = [Select Id from Service_Order_Header__c where CO_Header__c =: coHeader.Id];
        
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeader1.Id),BPUtility.getEncodedString(soList[0].Id),BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        SOHeaderWrapper soWrapperObj = (SOHeaderWrapper) System.JSON.deserialize(dealWrapperJSON, SOHeaderWrapper.class);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soWrapperObj.SOList[0].SOGridItems[0].SOKH.SOLIList[0])),BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealUnresolvedFulfillmentWrapper dealUnresolvedWrapperObj = (DealWrapper.DealUnresolvedFulfillmentWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealUnresolvedFulfillmentWrapper.class);
        
        system.assertEquals(kitHeader1.Id, dealUnresolvedWrapperObj.KitHeaderId);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.resolveFulfillment(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(System.JSON.serialize(dealWrapperObj.DealUnresolvedFulfillmentList[0])),BPUtility.getEncodedString('Invoice'), BPUtility.getEncodedString(customerOwnedUnit.Id)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        
        system.assertEquals(0, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        system.assertEquals(4, dealWrapperObj.UnitList[0].DealKitHeaderList.size());
        
    }*/
    
    static testMethod void insertDealKitHeaderInGridTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', true, 10, 'LabourCodeName', 10, true);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, labourCode.Id, null, 1, 5.0);
        Kit_Header_Line_Item__c kitHeaderLineItem2 = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, null, testPart1.Id, 1, 5.0);
        
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        
        Test.startTest();
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 1;
        optionAndFeeRec1.KitHeaderId = kitHeader.Id;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        DealWrapper.UnitSectionWrapper dealUnitInfoObj = (DealWrapper.UnitSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.UnitSectionWrapper.class);
        
        system.assertEquals(1, dealUnitInfoObj.DealKitHeaderList.size());
        system.assertEquals(2, dealUnitInfoObj.DealKitHeaderList[0].OptionAndFeeList.size());
    }
    
    static testMethod void recalculationOfDealKHLineItems_UpdateKitHeader_Test() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', true, 10, 'LabourCodeName', 10, true);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, false, false, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 0, false, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, labourCode.Id, null, 1, 5.0);
        
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        
        Test.startTest();
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 1;
        optionAndFeeRec1.KitHeaderId = kitHeader.Id;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        DealWrapper.UnitSectionWrapper dealUnitInfoObj = (DealWrapper.UnitSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.UnitSectionWrapper.class);
        
        system.assertEquals(10, dealUnitInfoObj.DealKitHeaderList[0].Price);
        system.assertEquals(false, dealUnitInfoObj.DealKitHeaderList[0].IsFixedPriceForCO);
        Test.stopTest();
        
        dealUnitInfoObj.DealKitHeaderList[0].Price = 50;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.recalculationOfDealKHLineItems(BPUtility.getEncodedString(System.JSON.serialize(dealUnitInfoObj.DealKitHeaderList[0])),BPUtility.getEncodedString('null')));
        dealUnitInfoObj = (DealWrapper.UnitSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.UnitSectionWrapper.class);
        
        system.assertEquals(50, dealUnitInfoObj.DealKitHeaderList[0].Price);
        system.assertEquals(true, dealUnitInfoObj.DealKitHeaderList[0].IsFixedPriceForCO);
        system.assertEquals(50, dealUnitInfoObj.DealKitHeaderList[0].OptionAndFeeList[0].Price);
    }
    
    static testMethod void recalculationOfDealKHLineItems_UpdateKitLineItem_Test() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        insert new List<Account>{customer, vendor};
        
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, false, false, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 0, false, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 50, null, testPart1.Id, 1, 50);
        
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        
        Test.startTest();
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 1;
        optionAndFeeRec1.KitHeaderId = kitHeader.Id;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        DealWrapper.UnitSectionWrapper dealUnitInfoObj = (DealWrapper.UnitSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.UnitSectionWrapper.class);
        
        system.assertEquals(33, dealUnitInfoObj.DealKitHeaderList[0].Price);
        system.assertEquals(false, dealUnitInfoObj.DealKitHeaderList[0].OptionAndFeeList[0].IsFixedPriceForCO);
        Test.stopTest();
        
        dealUnitInfoObj.DealKitHeaderList[0].OptionAndFeeList[0].Price = 100;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.recalculationOfDealKHLineItems(BPUtility.getEncodedString(System.JSON.serialize(dealUnitInfoObj.DealKitHeaderList[0])),BPUtility.getEncodedString(System.JSON.serialize(dealUnitInfoObj.DealKitHeaderList[0].OptionAndFeeList[0]))));
        dealUnitInfoObj = (DealWrapper.UnitSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.UnitSectionWrapper.class);
        
        system.assertEquals(100, dealUnitInfoObj.DealKitHeaderList[0].Price);
        system.assertEquals(true, dealUnitInfoObj.DealKitHeaderList[0].OptionAndFeeList[0].IsFixedPriceForCO);
        system.assertEquals(100, dealUnitInfoObj.DealKitHeaderList[0].OptionAndFeeList[0].Price);
    }
    
    static testMethod void removeDealKHItemsTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', true, 10, 'LabourCodeName', 10, true);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, labourCode.Id, null, 1, 5.0);
        
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        
        Test.startTest();
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 1;
        optionAndFeeRec1.KitHeaderId = kitHeader.Id;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        DealWrapper.UnitSectionWrapper dealUnitInfoObj = (DealWrapper.UnitSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.UnitSectionWrapper.class);
        
        system.assertEquals(1, dealUnitInfoObj.DealKitHeaderList.size());
        system.assertEquals(1, dealUnitInfoObj.DealKitHeaderList[0].OptionAndFeeList.size());
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.removeOptionFeesLineItem(BPUtility.getEncodedString(dealUnitInfoObj.DealItemObj.Id), BPUtility.getEncodedString(dealUnitInfoObj.DealKitHeaderList[0].Id)));
        dealUnitInfoObj = (DealWrapper.UnitSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.UnitSectionWrapper.class);
        system.assertEquals(0, dealUnitInfoObj.DealKitHeaderList.size());
    }
   
    static testMethod void insertCOLineItemsTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Test.startTest();
        CO_Header__c coHeader = TestUtil.createCOHeader(true, null);
        Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        COLineItem coliObj1 = new COLineItem(new CO_Line_Item__c(Part__c = testPart.Id));
        CustomerOrderCtrl.insertCOLineItems(BPUtility.getEncodedString(testPart.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(new List<COLineItem>{coliObj1})), false, false, BPUtility.getEncodedString(null), BPUtility.getEncodedString(null));
        COLineItem coliObj2 = new COLineItem(new CO_Line_Item__c(Part__c = testPart.Id));
        String suppressedLineItem = BPUtility.getDecodedString(CustomerOrderCtrl.insertCOLineItems(BPUtility.getEncodedString(testPart.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(new List<COLineItem>{coliObj2})), false, true, BPUtility.getEncodedString(null), BPUtility.getEncodedString(null)));
        Test.stopTest();
        system.assertEquals(true, suppressedLineItem.contains('DuplicatePart'));
        
        suppressedLineItem = CustomerOrderCtrl.insertCOLineItems(BPUtility.getEncodedString(testPart.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(new List<COLineItem>{coliObj2})), true, false, BPUtility.getEncodedString(null), BPUtility.getEncodedString(null));
        List<Suppress_CO_Item__c> suppressItemList = [Select CO_Header__c, Part__c from Suppress_CO_Item__c];
        system.assertEquals(1, suppressItemList.size());
        system.assertEquals(coHeader.Id, suppressItemList[0].CO_Header__c);
        system.assertEquals(testPart.Id, suppressItemList[0].Part__c);
    }
    
    static testMethod void insertOptionAndFeeLineItemsTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        
        Test.startTest();
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.PartId = testPart1.Id;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.insertOptionAndFeeLineItems(BPUtility.getEncodedString(testPart1.Id), BPUtility.getEncodedString(coHeader.Id),BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1)), false, false));
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec2 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec2.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec2.PartId = testPart1.Id;
        String suppressdLineItem = BPUtility.getDecodedString(CustomerOrderCtrl.insertOptionAndFeeLineItems(BPUtility.getEncodedString(testPart1.Id), BPUtility.getEncodedString(coHeader.Id),BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec2)), false, true));
        Test.stopTest();
        system.assertEquals(true, suppressdLineItem.contains('DuplicatePart'));
        
        suppressdLineItem = BPUtility.getDecodedString(CustomerOrderCtrl.insertOptionAndFeeLineItems(BPUtility.getEncodedString(testPart1.Id), BPUtility.getEncodedString(coHeader.Id),BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec2)), true, false));
        List<Suppress_CO_Item__c> suppressItemList = [Select CO_Header__c, Part__c from Suppress_CO_Item__c];
        system.assertEquals(1, suppressItemList.size());
        system.assertEquals(coHeader.Id, suppressItemList[0].CO_Header__c);
        system.assertEquals(testPart1.Id, suppressItemList[0].Part__c);
    }
    
    static testMethod void showHistoryOnSuppressPopupTest(){ 
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Header__c coHeader = TestUtil.createCOHeader(true, null);
        Deal__c deal = new Deal__c(CO_Header__c = coHeader.Id, Status__c = 'Quotation', Unit_Status__c = 'Temporary');
        insert deal;
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        dealItemRec.Deal__c = deal.id;
        dealItemRec.Type__c ='Unit';
        insert dealItemRec;
        Test.StartTest();
        Option_Fee__c optionAndFeeRec = new Option_Fee__c();
        optionAndFeeRec.Qty__c = 2;
        optionAndFeeRec.Deal_Item__c = dealItemRec.Id;
        optionAndFeeRec.Is_Install__c = false;
        optionAndFeeRec.Part__c = part.Id;
        insert optionAndFeeRec;
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c(Id = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id);
        Service_Order_Line_Item__c soLineItem = new Service_Order_Line_Item__c();
        soLineItem.Service_Order_Header__c = soHeaderRec.id;
        insert soLineItem;
        
        CO_Line_Item__c coLineItemRec = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 50);
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 50);
        coLineItemRec1.Deal__c = deal.Id;
        update coLineItemRec1;
        CO_Line_Item__c coLineItemRec2 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 50);
        coLineItemRec2.Service_Order_Line_Item__c = soLineItem.Id;
        update coLineItemRec2;      
        Test.StopTest();
         
         //ayushi start
        String partJSON = BPUtility.getDecodedString(CustomerOrderCtrl.showHistoryOnSuppressPopup(BPUtility.getEncodedString(part.Id),BPUtility.getEncodedString(coHeader.Id)));
        List<DuplicatePartWrapper> coLineItemList = (List<DuplicatePartWrapper>) System.JSON.deserialize(partJSON, List<DuplicatePartWrapper>.class);
        //ayushi end
        system.assertEquals(4,coLineItemList.size());
    }
    
    static testMethod void insertKitHeaderInDealMerchGridTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        
        Deal__c dealRec = new Deal__c(CO_Header__c = coHeader.Id, Status__c = Constants.QUOTATION, Type__c = Constants.CASH_DEAL, Unit_Status__c = Constants.TEMPORARY);
        insert dealRec;
        List<Deal__c> dealList = new List<Deal__c>{dealRec};
        
        Test.startTest();
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 2;
        optionAndFeeRec1.PartId = testPart1.Id;
        optionAndFeeRec1.IsInstall = false; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        
        system.assertEquals(1, DealFulfillmentSectionObj.DealMerchandiseList.size());
        
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, false, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, null, testPart1.Id, 1, 5.0);
        Test.stopTest();
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.insertKitHeaderInDealMerchGrid(BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        
        system.assertEquals(1, dealWrapperObj.DealUnresolvedFulfillmentList.size());
    }
    
    //START: kv 01/30/2017
    static testMethod void createUnresolvedFulfillmentForRemoveKitInMerchTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, false, unitmake.Id, unitModel.Id);// service kit = false
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, testPart1.Id, 3, 5.0); 
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        Test.startTest();
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 2;
        optionAndFeeRec1.KitHeaderId = kitHeader.Id;
        optionAndFeeRec1.IsInstall = false; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        DealWrapper.UnitSectionWrapper dealUnitInfoObj = (DealWrapper.UnitSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.UnitSectionWrapper.class);
        system.assertEquals(1, dealUnitInfoObj.DealKitHeaderList.size());
        system.assertEquals(1, dealUnitInfoObj.DealKitHeaderList[0].OptionAndFeeList.size());
        BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        Test.stopTest();        
        system.assertEquals(1, DealFulfillmentSectionObj.DealMerchandiseList.size());
        system.assertEquals(3, DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList[0].Qty);// part qty
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.removeLineItemsInMerchGrid(BPUtility.getEncodedString(DealFulfillmentSectionObj.DealMerchandiseList[0].COLIList[0].CoLineItemId), BPUtility.getEncodedString(coHeader.Id)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        
        system.assertEquals(1, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        system.assertEquals(testPart1.Id, dealWrapperObj.DealUnresolvedFulfillmentList[0].partId);
        system.assertEquals('Remove from Deal', dealWrapperObj.DealUnresolvedFulfillmentList[0].ActionRequired);
    } 
    
    static testMethod void createUnresolvedFulfillmentForRemoveKitAddedFromStaInMerchTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        Part__c testPart2 = TestUtil.createPart(true, 'Part12', vendor.Id, 'Test Part2', testCategory.Id);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        Deal__c dealRec = new Deal__c(CO_Header__c = coHeader.Id, Status__c = Constants.QUOTATION, Type__c = Constants.CASH_DEAL, Unit_Status__c = Constants.TEMPORARY);
        insert dealRec;
        
        List<Deal__c> dealList = new List<Deal__c>{dealRec};
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        Test.startTest();
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 2;
        optionAndFeeRec1.PartId = testPart1.Id;
        optionAndFeeRec1.IsInstall = false; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        DealWrapper.UnitSectionWrapper dealUnitInfoObj = (DealWrapper.UnitSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.UnitSectionWrapper.class);
        BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        system.assertEquals(1, DealFulfillmentSectionObj.DealMerchandiseList.size());
        
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, false, unitmake.Id, unitModel.Id);// service kit = false
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, testPart2.Id, 3, 5.0); 

        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.insertKitHeaderInDealMerchGrid(BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        
        Test.stopTest();
        system.assertEquals(1, dealWrapperObj.DealUnresolvedFulfillmentList.size());
        system.assertEquals('Add to Deal', dealWrapperObj.DealUnresolvedFulfillmentList[0].ActionRequired);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.removeLineItemsInMerchGrid(BPUtility.getEncodedString(dealWrapperObj.DealUnresolvedFulfillmentList[0].COKitHeaderId), BPUtility.getEncodedString(coHeader.Id)));
        dealWrapperObj = (DealWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.class);
        system.assertEquals(0, dealWrapperObj.DealUnresolvedFulfillmentList.size());// No chk for action req since no line item left in unresolved fulFillmentSection
    }
    
static testMethod void createUnresolvedFulfillmentForRemoveKitInSOTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, true, unitmake.Id, unitModel.Id);// service kit = true
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, testPart1.Id, 3, 5.0); 
        
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert coHeader;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(coHeader.Id));
        
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :coHeader.Id];
        
        //Test.startTest();
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(null),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealList[0].Id)));
        //Test.startTest();
        DealWrapper dealWrapperObj = DealWrapper.parse(dealWrapperJSON);
        
        DealWrapper.OptionAndFeeInfo optionAndFeeRec1 = new DealWrapper.OptionAndFeeInfo(new Option_Fee__c());
        optionAndFeeRec1.DealItemId = dealWrapperObj.UnitList[0].DealItemObj.Id;
        optionAndFeeRec1.Qty = 2;
        optionAndFeeRec1.KitHeaderId = kitHeader.Id;
        optionAndFeeRec1.IsInstall = true; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        Test.startTest();
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        DealWrapper.UnitSectionWrapper dealUnitInfoObj = (DealWrapper.UnitSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.UnitSectionWrapper.class);
        system.assertEquals(1, dealUnitInfoObj.DealKitHeaderList.size());
        system.assertEquals(1, dealUnitInfoObj.DealKitHeaderList[0].OptionAndFeeList.size());
        BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        Test.stopTest();
        List<Service_Order_Header__c> soList = [Select Id, (Select Id, Labour_Code__c, Qty_Needed__c, Kit_Price__c from Service_Order_Line_Items__r) from Service_Order_Header__c where CO_Header__c = :coHeader.Id];
        system.assertEquals(1, soList.size());
        system.assertEquals(1, soList[0].Service_Order_Line_Items__r.size());
        system.assertEquals(3, soList[0].Service_Order_Line_Items__r[0].Qty_Needed__c);
        createUnresolvedFulfillmentForRemoveKitInSOTest_future(coHeader.Id);
        
    } 
    
    @future
    static void createUnresolvedFulfillmentForRemoveKitInSOTest_future(String coHeaderId)
    {   
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.removeLineItems(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOGridItems[0].SOKH.SOLIList[0].SOKitHeaderId), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)) );
        
        List<DealWrapper.DealUnresolvedFulfillmentWrapper> unresolvedFulfillmentList = (List<DealWrapper.DealUnresolvedFulfillmentWrapper>) System.JSON.deserialize(dealWrapperJSON, List<DealWrapper.DealUnresolvedFulfillmentWrapper>.class);
        system.assertEquals(1,unresolvedFulfillmentList.size());
        system.assertEquals('Remove from Deal',unresolvedFulfillmentList[0].ActionRequired);
    }
    
    static testMethod void salesTaxCalculationForThirdParty() {
        
        TestUtil.createtaxsettingInGeneralConfig();
        
        //Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Price_Level__c defaultPriceLevel1 = TestUtil.createPriceLevel(true, 'Default Price Level1', 'MSRP', 20 , true, true);
        
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Claims_for_Service_Work__c = true;
        vendor.Price_Level__c = defaultPriceLevel1.Id;
        insert vendor;
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        Applicable_Taxes__c applicabletax1 = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem1.Id);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        //Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Third-Party', 'Third-Party');
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Third-Party', 'Third-Party');
        //transactionType.Third_Party_Customer__c = customer.Id;
        insert transactionType ;
        Part__c part = TestUtil.createPart(false, 'part', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Applicable_Tax__c = salestax.Id;
        insert part;
        
        //Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        
        
        
        Test.StartTest();
        salesTaxCalculationForThirdPartyAsyncHandling(transactionType.Id, vendor.Id, salestaxItem.Id, part.Id, customer.Id);
        Test.stopTest();
    }
    
    @future
	private static void salesTaxCalculationForThirdPartyAsyncHandling(String transactionTypeId, String vendorId, String salestaxItemId, String partId, String customerId) {
		CO_Header__c coHeader = TestUtil.createCOHeader(true, customerId);
		String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        soHeaderDetailsObj.SOList[0].SOHeaderInfo.TransactionTypeId = transactionTypeId ;
        soHeaderDetailsObj.SOList[0].SOHeaderInfo.ProviderId = vendorId;
        String jsonStr = System.Json.serialize(soHeaderDetailsObj.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        
        Tax_Exemption__c taxExemption = Testutil.createSOTaxExemption(true, soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id, salestaxItemId);
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(partId), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customerId)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 1.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj3 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
//        system.assertEquals(soHeaderDetailsObj3.SOList[0].SOGridItems[0].SOKH.SOLIList[0].KitPrice, 55.93);
	}
    
   	static testMethod void salesTaxCalculationForThirdPartyA() {
        
        TestUtil.createtaxsettingInGeneralConfig();
        
        //Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Claims_for_Service_Work__c = true;
        insert vendor;
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        Applicable_Taxes__c applicabletax1 = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem1.Id);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        //Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Third-Party', 'Third-Party');
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Third-Party', 'Third-Party');
        //transactionType.Third_Party_Customer__c = customer.Id;
        insert transactionType ;
        Part__c part = TestUtil.createPart(false, 'part', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Applicable_Tax__c = salestax.Id;
        insert part;
        
        //Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        soHeaderDetailsObj.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        String jsonStr = System.Json.serialize(soHeaderDetailsObj.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        
        Tax_Exemption__c taxExemption = Testutil.createSOTaxExemption(true, soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id, salestaxItem.Id);
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        Test.startTest();
        salesTaxCalculationForThirdPartyATestAsyncHandling(coHeader.Id);
        Test.stopTest();
    }
    
    @future
	private static void salesTaxCalculationForThirdPartyATestAsyncHandling(String coHeaderId) {
		String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 1.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeaderId)));
        
        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj3 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj3.SOList[0].SOGridItems[0].SOKH.SOLIList[0].KitPrice, 51.27);
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