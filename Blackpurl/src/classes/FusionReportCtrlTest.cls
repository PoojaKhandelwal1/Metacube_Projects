/**
 * Author: Rajat Jain
 * updated: September 9, 2018
 * Name: FusionReportCtrlTest
 * Description: It includes scenario based test cases for FusionReportCtrlTest.
**/

@isTest
private with sharing class FusionReportCtrlTest {
	
	@testSetup
   	static void setup() {
   		TestUtil.setQuickBooksConfigurations(false); 
   		BPScriptUtility.insertFusionLineItems();
   		List<Fusion_Report_Line_Item__c> fusionLineItemList = [Select Id from Fusion_Report_Line_Item__c Limit 100];
   		system.assert(fusionLineItemList.size() > 0);
   		
		List<Fusion_Benchmarking__c> fusionBenchmarkingListToBeInserted = new List<Fusion_Benchmarking__c>();
		fusionBenchmarkingListToBeInserted.add(new Fusion_Benchmarking__c(Average_Technician_Prime_Labor_Cost__c=18.00, Employee_No_Administration_Other__c=16.00, Employee_No_Parts__c=15.00, Employee_No_Sales__c=12.00, Employee_No_Service_Non_Technical__c=14.00, Employee_No_Service_Technical__c=13.00, No_Sales_People__c=17.00,Working_days_in_Period__c = 12.00,No_Insurance_Contracts_Written__c = 10.00,No_of_Working_Days__c = 12.00));
		insert fusionBenchmarkingListToBeInserted;
		List<Fusion_Benchmarking__c> fusionBenchmarkingList = [Select Id from Fusion_Benchmarking__c];
		system.assert(fusionBenchmarkingList.size() > 0);
		
		List<General_Account__c> listOfGLAccounts = new List<General_Account__c>();
		listOfGLAccounts.add(new General_Account__c(Accounting_Id__c='176', Account_Name__c='BP Shop Supplies', Account_Number__c='4311', Account_Type__c='Income'));
		listOfGLAccounts.add(new General_Account__c(Accounting_Id__c='166', Account_Name__c='BP Received Inventory Accrual', Account_Number__c='2200', Account_Type__c='Other Current Liability'));
		listOfGLAccounts.add(new General_Account__c(Accounting_Id__c='160', Account_Name__c='BP QA Tax Agency Payable', Account_Type__c='Other Current'));
		insert listOfGLAccounts;
		
		Fusion_Line_Item_To_GL_Account_Junction__c fusionLineItemToGlAccountJunctionObj = new Fusion_Line_Item_To_GL_Account_Junction__c(Fusion_Report_Line_Item__c = fusionLineItemList[0].Id, General_Account__c = listOfGLAccounts[0].Id);
   		insert fusionLineItemToGlAccountJunctionObj;
        
   	}
   	
   	static testMethod void fusionReportTest() {
   		new FusionReportCtrl();
   	}
   	static testMethod void getBalanceSheetFromQB() {
   		String result = BPUtility.getDecodedString(FusionBenchmarkingCtrl.getBalanceSheetFromQB(BPUtility.getEncodedString('August'), BPUtility.getEncodedString('2018')));
		system.assertEquals('Success',result);
   	}
   	static testMethod void getProfitAndLossFromQB() {
   		String result = BPUtility.getDecodedString(FusionBenchmarkingCtrl.getProfitAndLossFromQB(BPUtility.getEncodedString('August'), BPUtility.getEncodedString('2018')));
		system.assertEquals('Success',result);
   	}
   	static testMethod void getOtherAccountInfoFromQB() {
   		String result = BPUtility.getDecodedString(FusionBenchmarkingCtrl.getOtherAccountInfoFromQB(BPUtility.getEncodedString('August'), BPUtility.getEncodedString('2018')));
		system.assertEquals('Success',result);
   	}
   	static testMethod void getOtherAccountInfoFromQB_Yearly() {
   		String result = BPUtility.getDecodedString(FusionBenchmarkingCtrl.getOtherAccountInfoFromQB_Yearly(BPUtility.getEncodedString('August'), BPUtility.getEncodedString('2018')));
		system.assertEquals('Success',result);
   	}
   	static testMethod void populateBlackpurlData() {
   		Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
   		Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        List<General_Account__c> gLAccountList = [Select Id, Accounting_Id__c from General_Account__c Limit 10];
        Account vendor = TestUtil.createVendor(false , 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
        testCategory.Inventory_GL__c = gLAccountList[0].Accounting_Id__c;
        insert new List<SObject>{customer, vendor, testCategory};
        Part__c testPart1 = TestUtil.createPart(false, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        Unit_Make__c unitmake = TestUtil.createUnitMake(false, 'unitMakeName', '12A', true);
        insert new List<SObject>{testPart1, unitmake};
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Available';
        customerOwnedUnit.Category__c = testCategory.Id;
        CO_Header__c coHeader = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert new List<SObject>{customerOwnedUnit, coHeader};
        Deal__c dealRec = new Deal__c(CO_Header__c = coHeader.Id, Status__c = Constants.QUOTATION, Type__c = Constants.CASH_DEAL, Unit_Status__c = Constants.TEMPORARY);
        insert dealRec;
        List<Deal__c> dealList = new List<Deal__c>{dealRec};
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
        //q-96
        Test.startTest();
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        List<CO_Invoice_Header__c> coInvoiceHeaderlist = [select  Status__c, Total_Payment__c from CO_Invoice_Header__c where Status__c = 'Active'];
        String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaderlist[0].Id)));
        List<COInvoiceItem> coInvoiceItemList = (List<COInvoiceItem>) System.JSON.deserialize(COInvoiceItemJSON, List<COInvoiceItem>.class);
   		//q-98
   		populateBlackpurlData_future(coHeader.Id);
		Test.stopTest();
   	}
   	
   	@future
   	static void populateBlackpurlData_future(String coHeaderId) {
   		List<CO_Invoice_Header__c> coInvoiceHeaderlist = [select  Status__c, Total_Payment__c from CO_Invoice_Header__c where Status__c = 'Active'];
        String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaderlist[0].Id)));
        List<COInvoiceItem> coInvoiceItemList = (List<COInvoiceItem>) System.JSON.deserialize(COInvoiceItemJSON, List<COInvoiceItem>.class);
        for(COInvoiceItem coInvoiceItemObj : coInvoiceItemList) {
            if(String.isNotBlank(coInvoiceItemObj.DealId)) {
                coInvoiceItemObj.isActive = true;
            }
        }
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedInvoiceAction(BPUtility.getEncodedString(System.JSON.serialize(coInvoiceItemList)), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('Customer')));
   		String result = FusionBenchmarkingCtrl.populateBlackpurlValues(BPUtility.getEncodedString('August'), BPUtility.getEncodedString('2018'));
   		String result1 = BPUtility.getDecodedString(FusionBenchmarkingCtrl.saveFusionLineItemValues(result));
   		system.assertEquals('Success',result1);
   	}
   	
   	static testMethod void populateCalculatedData() {
   		List<Fusion_Report_Line_Item__c> fusionLineItemList = [Select Id from Fusion_Report_Line_Item__c Limit 100];
   		for(Fusion_Report_Line_Item__c fusionLineItemRec : fusionLineItemList) {
   			fusionLineItemRec.Monthly_Value__c = 100.00;
   			fusionLineItemRec.Yearly_Value__c = 1200.00;
   		}
   		update fusionLineItemList;
   		String result = BPUtility.getDecodedString(FusionBenchmarkingCtrl.populateCalculatedData());
		system.assertEquals('Success',result);
   	}
}