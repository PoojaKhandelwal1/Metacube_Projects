/**
 * Author: Nidhi Sharma
 * updated: Oct 24, 2016
 * Name: FIProductTriggerTest
 * Description: Test class for f and i product trigger
**/
@isTest
private class FIProductTriggerTest {

    static testMethod void fAndIProductTriggerTest() {
    	
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Finance_Company__c = true;
        insert vendor;
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        Part__c testPart2 = TestUtil.createPart(true, 'Part12', vendor.Id, 'Test Part2', testCategory.Id);
        
        Product__c testProduct1 = TestUtil.createProduct(false, testCategory.Id, 'Test Product2', vendor.Id);
        testProduct1.Type__c = 'Financing Product';
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
        system.assertEquals(testProduct1.Id, DealFAndIProductObj.ProductId);
    }
}