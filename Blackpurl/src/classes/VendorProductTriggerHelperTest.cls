/**
 * Author: Nidhi Sharma
 * updated: June 16, 2017
 * Name: VendorProductTriggerHelperTest
**/
@isTest
private class VendorProductTriggerHelperTest {
	 
    static testMethod void updateProductTest() {
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
        
        insert new List<SObject>{customer, vendor, testCategory};
        
        Product__c testProduct = TestUtil.createProduct(false, testCategory.Id, 'Test Product Code', vendor.Id);
        testProduct.Description__c = 'Test Desc';
        insert testProduct;
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'STOCK';
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
        optionAndFeeRec1.Qty = 1;
        optionAndFeeRec1.ProductId = testProduct.Id;
        optionAndFeeRec1.IsInstall = false; 
        optionAndFeeRec1.SalesTaxPercentage = 0;
        optionAndFeeRec1.Price = 0;
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.saveOptionFeesLineItem(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(System.JSON.serialize(optionAndFeeRec1))));
        Test.startTest();
        String dealInfoObjJson = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealStatus(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString('In Progress')));
        
        DealWrapper.DealInfoWrapper dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoObjJson, DealWrapper.DealInfoWrapper.class);
        
        dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(coHeader.Id)));
        DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = (DealWrapper.DealFulfillmentSectionWrapper) System.JSON.deserialize(dealWrapperJSON, DealWrapper.DealFulfillmentSectionWrapper.class);
        
        testProduct.Code__c = 'Updated Code';
        testProduct.Description__c = 'Updated Desc';
        update testProduct;
        
        List<Option_Fee__c> optionAndFeeList = [Select Id, Item_Code__c, Item_Description__c from Option_Fee__c where Deal_Item__c =: dealWrapperObj.UnitList[0].DealItemObj.Id];
        system.assertEquals(testProduct.Code__c, optionAndFeeList[0].Item_Code__c);
        system.assertEquals(testProduct.Description__c, optionAndFeeList[0].Item_Description__c);
        
        List<CO_Invoice_Header__c> coInvoiceHeaderlist = [select  Status__c, Total_Payment__c from CO_Invoice_Header__c where Status__c = 'Active'];
        String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaderlist[0].Id)));
        List<COInvoiceItem> coInvoiceItemList = (List<COInvoiceItem>) System.JSON.deserialize(COInvoiceItemJSON, List<COInvoiceItem>.class);
        
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedorderAction(BPUtility.getEncodedString(System.JSON.serialize(coInvoiceItemList)), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('Customer')));
        
        COHeaderWrapper coHeaderDetails = (COHeaderWrapper) System.JSON.deserialize(closedOrder, COHeaderWrapper.class);
        System.assertEquals('Closed', coHeaderDetails.coHeaderRec.OrderStatus);
        
        testProduct.Code__c = 'Updated Code 2';
        testProduct.Description__c = 'Updated Desc 2';
        update testProduct;
        
        optionAndFeeList = [Select Id, Item_Code__c, Item_Description__c from Option_Fee__c where Deal_Item__c =: dealWrapperObj.UnitList[0].DealItemObj.Id];
        Test.stopTest();
        system.assertEquals('Updated Code', optionAndFeeList[0].Item_Code__c);
        system.assertEquals('Updated Desc', optionAndFeeList[0].Item_Description__c);
    }
}