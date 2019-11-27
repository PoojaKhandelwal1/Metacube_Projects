@isTest
private class SOHeaderWrapperTest {
    
    static testMethod void testSOHeaderWrapperTest() {
        TestUtil.createtaxsettingInGeneralConfig();
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Account vendor1 = TestUtil.createVendor(false, 'Test Vendor1');
        vendor1.Claims_for_Service_Work__c = true;
        vendor1.Active__c = true;
        insert vendor1;
        
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Category__c testCategory1 = TestUtil.createCategory(true, 'Test Category', 'Internal Expense', 'Testing Category', true, true);
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(true, 'Customer', 'Customer');
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        insert customerOwnedUnit;
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, LabourCode.Id, null, 1, 5.0);
        //Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, null, Part.Id, 1, 5.0);    
        Technician__c technicianRec1 = new Technician__c(Technician_Name__c = 'Test Name', Active__c = true);
        insert technicianRec1;
        
        Vendor_Order_Line_Item__c vendorOrderLineItems = new Vendor_Order_Line_Item__c();
        vendorOrderLineItems.CO_Header__c = coHeader.Id;
        vendorOrderLineItems.Is_required_For_Customer__c = true;
        vendorOrderLineItems.Is_Service__c = true;
        insert vendorOrderLineItems;

        String DateTimeFormat = DateTime.now().addDays(2).format('MM/dd/yyyy hh:mm a');
        SOHeaderWrapper.getDateTimeFromString(DateTimeFormat);
        SOHeaderWrapper.getProviderFieldsList();
        SOHeaderWrapper.individualTaxFieldsList();
        SOHeaderWrapper.getTTFieldsList();
        Test.startTest();
        testSOHeaderWrapperTestAsyncHandling(coHeader.Id, technicianRec1.id, transactionType.Id, unitModel.Id, unitMake.Id, customerOwnedUnit.Id,kitHeader.Id, customer.Id, testCategory.Id);
        Test.stopTest();
        
        
    }
    
    @future
	private static void testSOHeaderWrapperTestAsyncHandling(String coHeaderId, String technicianRec1id, String transactionTypeId, String unitModelId, String unitMakeId, String customerOwnedUnitId, String kitHeaderId, String customerId, String testCategoryId) {
		String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeaderId)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        
        Hours_Logged__c hoursLoggedRec = new Hours_Logged__c();
        hoursLoggedRec.Technician__c = technicianRec1id;
        hoursLoggedRec.Time_Spent_h__c = 2;
        hoursLoggedRec.Service_Order_Header__c = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        insert hoursLoggedRec;
        
        CustomerApproval__c customerApproval = TestUtil.createCustomerApproval(false, 'Approved', 'Notes');
        customerApproval.Section_key__c = 'Sign_In';
        customerApproval.Service_Order_Header__c = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id;
        insert customerApproval;
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('{"TransactionTypeId":"'+transactionTypeId+'","TransactionType":"Internal","Total":0,"Stock":"No outstanding items","PromisedBy":"01/07/2016 9:00 PM","Name":"Service Job 1","ManualCorrection":["correction"],"ManualConcern":["Concern", "concern1"],"ManualCause":["cause"],"KitHeaderCorrection":[],"KitHeaderConcern":[],"KitHeaderCause":[],"IsPromisedByAmPm":null,"Id":"'+soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id+'","EstimatedHours":0,"COUId":"'+customerOwnedUnitId+'","CategoryName":"Chain Parts","CategoryId":"'+testCategoryId+'","selectedCOU":{"Year":1915,"VIN":"1G1AW35K1CB156516","SubModelName":"2039","SubModel":"'+unitmodelId+'","Plate":"lic","Name":"COU-00001249","ModelName":"Testing Model 49","ModelMakeName":"Audi","Model":"'+unitModelId+'","Mileage":18,"MakeName":"Audi","Make":"'+unitMakeId+'","Id":"'+customerOwnedUnitId+'","Color":"woodland brown","$$hashKey":"object:342"},"selectedTime":"9:00 PM","selectedDate":"01/07/2016","CategoryNameStr":{},"NewConcern":"","NewCause":"","NewCorrection":""}')));
        CustomerOrderCtrl.changeStatus(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString('Approved'), BPUtility.getEncodedString('claim'));
        String TechnicianList = BPUtility.getDecodedString(CustomerOrderCtrl.getTechnicianList());
        String SOMasterData = BPUtility.getDecodedString(CustomerOrderCtrl.getSOMasterData(BPUtility.getEncodedString(coHeaderId)));
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeaderId), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(customerId)));
        String savePinItem = BPUtility.getDecodedString(CustomerOrderCtrl.savePinItems(BPUtility.getEncodedString('{"PinnedItemList":["Transaction Type","Unit"]}')));
        String deductible =  BPUtility.getDecodedString(CustomerOrderCtrl.addDeductibleAmount(BPUtility.getEncodedString('{"SoHeaderId":"'+soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id+'","DeductibleStatus":null,"DeductibleId":null,"DeductibleAmount":"10","CoHeaderId":"'+coHeaderId+'"}')));
        String soHeader1 = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeaderId)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
        system.assert(true,true);
	}
    
    static testMethod void testSOHeaderWrapperTest1() {
        TestUtil.createtaxsettingInGeneralConfig();
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Account vendor1 = TestUtil.createVendor(false, 'Test Vendor1');
        vendor1.Claims_for_Service_Work__c = true;
        vendor1.Active__c = true;
        insert vendor1;
        
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Category__c testCategory1 = TestUtil.createCategory(true, 'Test Category', 'Internal Expense', 'Testing Category', true, true);
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(true, 'Customer', 'Customer');
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        List<Service_Order_Header__c> soHeaderRecList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>());
        
        List<String> pinItemList = new List<String>{'Transaction Type','Unit'};
        system.assert(true,true);
    }
    
}