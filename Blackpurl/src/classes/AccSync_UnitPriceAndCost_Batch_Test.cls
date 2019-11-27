/**
 * Author: Pooja Khandelwal
 * Since: Jun 8, 2018
 * Name: AccSync_UnitPriceAndCost_Batch_Test
 * Description: batch test Class of Unit Price & Cost Journal Entry sync to QuickBooks.
**/
@isTest
public class AccSync_UnitPriceAndCost_Batch_Test {
    static PaginationSorting pageSort;
    @testSetup
    static void setup() {
        TestUtil.setQuickBooksConfigurations(false);
        
        Category__c categoryObj =  TestUtil.createCategory(false, 'Qb Category');
        categoryObj.Type__c = 'Unit';
        categoryObj.Active__c = true;
        categoryObj.Default__c = true;
        insert categoryObj;
        
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'QB Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'QB Customer', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        Account vendorObj = TestUtil.createVendor(true, 'QB Vendor');
        Unit_Make__c unitMake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitModel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        createAndReceiveUnitForVendor(customer, vendorObj, unitMake, unitModel, defaultSalesTax);
        system.assert(true, true);
    }
    
    private static void createAndReceiveUnitForVendor(Account customer, Account vendorObj, Unit_Make__c unitMake, Unit_Model__c unitModel, Sales_Tax__c defaultSalesTax) {
        // Set unit purchase flag for vendor
        String vendorList = BPUtility.getDecodedString(UnitOrderingCtrl.SetUnitPurchaseFlagForVendor(BPUtility.getEncodedString(vendorObj.Id)));
        
        // Order a Unit for vendor
        Customer_Owned_Unit__c couRec = TestUtil.createCustomerOwnedUnit(false, customer.Id, unitMake.Id, unitModel.Id, null, 'vin-1234');
        couRec.Applicable_Tax__c = defaultSalesTax.Id;
        couRec.Taxable__c = true;
        couRec.Mileage_Type__c = 'km';
        couRec.Status__c = 'On Order';
        couRec.Unit_Type__c = 'ORDU';
        couRec.Vendor__c = vendorObj.Id;
        couRec.Year__c = 2000;
        couRec.Total_Cost__c = 100;
        insert couRec;
        UnitOrderingWrapper.UnitDetailsWrapper unitDetailRec = new UnitOrderingWrapper.UnitDetailsWrapper(couRec);
        String unitDetailRecJsonString = System.JSON.serialize(unitDetailRec);
        String orderedUnitDetails = BPUtility.getDecodedString(UnitOrderingCtrl.saveUnitDetails(BPUtility.getEncodedString(unitDetailRecJsonString)));
    	
        // Get Active Orders List
        String activeOrderList = BPUtility.getDecodedString(UnitOrderingCtrl.getActiveOrderList(BPUtility.getEncodedString(vendorObj.Id)));
    	
        // Receive Ordered Unit
        List<UnitOrderingWrapper.UnitOrderWrapper> orderedUnitRec = (List<UnitOrderingWrapper.UnitOrderWrapper>)System.JSON.deserialize(activeOrderList, List<UnitOrderingWrapper.UnitOrderWrapper>.class);
        orderedUnitRec[0].InvoiceNumber = 'Inv-1234';
        String orderedUnitRecJsonString = System.JSON.serialize(orderedUnitRec);
        String receivedUnitStatus = UnitOrderingCtrl.receiveUnit(BPUtility.getEncodedString(orderedUnitRecJsonString));
    }
    
    private static void createUnitPriceAndCostRecsForSKU() {
    	List<Customer_Owned_Unit__c> unitList = [Select Id, Status__c from Customer_Owned_Unit__c WHERE Status__c = 'Available'];
    	Unit_Price_Cost__c unitPriceAndCostRec = new Unit_Price_Cost__c();
    	unitPriceAndCostRec.Item_Description__c = 'unitPriceAndCostRec-1234';
    	unitPriceAndCostRec.Total_Cost__c = 23245.00;
    	unitPriceAndCostRec.Total_Price__c = 12345.00;
    	unitPriceAndCostRec.Type__c = 'Base';
    	unitPriceAndCostRec.Customer_Owned_Unit__c = unitList[0].Id;
    	UnitWrapper.PriceAndCostTrackingWrapper unitPriceAndCostRecord = new UnitWrapper.PriceAndCostTrackingWrapper(unitPriceAndCostRec);
    	String unitPriceAndCostRecordJsonString = System.JSON.serialize(unitPriceAndCostRecord);
    	String unitPriceAndCostDetails = BPUtility.getDecodedString(ViewUnitCtrl.savePriceAndCost(BPUtility.getEncodedString(unitList[0].Id), BPUtility.getEncodedString(unitPriceAndCostRecordJsonString)));
    }
    
    private static testmethod void syncUnitPriceAndCostRecsTest() {
        Test.startTest();
        createUnitPriceAndCostRecsForSKU();
        Test.stopTest();
        
        List<Unit_Price_Cost__c> unitPriceAndCostRecList = [Select Id, AccountingResponse__c, AccountingId__c, availForQBSync__c from Unit_Price_Cost__c];
        system.assertEquals('675', unitPriceAndCostRecList[0].AccountingId__c); 
    }
}