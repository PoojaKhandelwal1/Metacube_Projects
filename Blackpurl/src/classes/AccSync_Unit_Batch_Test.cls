/**
 * Author: Pooja Khandelwal
 * Since: Jun 7, 2018
 * Name: AccSync_Unit_Batch_Test
 * Description: batch test Class of Unit(Bill) sync to QuickBooks.
**/
@isTest
public class AccSync_Unit_Batch_Test {
    static PaginationSorting pageSort;
    @testSetup
    static void setup() {
        TestUtil.setQuickBooksConfigurations(false);
        
        Category__c categoryObj =  TestUtil.createCategory(false, 'Qb Category');
        categoryObj.Type__c = 'Unit';
        categoryObj.Active__c = true;
        categoryObj.Default__c = true;
        insert categoryObj;
        TestUtil.setQBTaxCodesConfigurations(true);
        List<Sales_Tax__c> defaultSalesTaxList = [Select Id From Sales_Tax__c where Rate__c != 0];
        //Create Vendor
       
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'QB Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'QB Customer', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        Account vendorObj = TestUtil.createVendor(false, 'QB Vendor');
        vendorObj.Purchase_Tax__c = defaultSalesTaxList[0].Id;
        insert vendorObj;
        Unit_Make__c unitMake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitModel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        system.assert(true, true);
    }
    
    private static void createAndReceiveUnitForVendor() {
    	Account customer = [Select Id from Account WHERE Is_Customer__C = true];
    	Account vendorObj = [Select Id from Account WHERE Is_Vendor__C = true];
    	Unit_Make__c unitMake = [Select Id from Unit_Make__c];
    	Unit_Model__c unitModel = [Select Id from Unit_Model__c];
    	List<Sales_Tax__c> defaultSalesTax = [Select Id from Sales_Tax__c];
    	
        // Set unit purchase flag for vendor
        String vendorList = BPUtility.getDecodedString(UnitOrderingCtrl.SetUnitPurchaseFlagForVendor(BPUtility.getEncodedString(vendorObj.Id)));
        
        // Order a Unit for vendor
        Customer_Owned_Unit__c couRec = TestUtil.createCustomerOwnedUnit(false, customer.Id, unitMake.Id, unitModel.Id, null, 'vin-1234');
        couRec.Applicable_Tax__c = defaultSalesTax[0].Id;
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
    
    private static testmethod void syncUnitsTest() {
        Test.startTest();
        createAndReceiveUnitForVendor();
        Test.stopTest();
        
        List<Customer_Owned_Unit__c> unitList = [Select Id, Status__c, AccountingResponse__c, AccountingId__c, availForQBSync__c, vendor__r.Vendor_AccountingId__c, vendor__r.Vendor_availForQBSync__c from Customer_Owned_Unit__c WHERE Status__c = 'Available'];
        system.assertEquals('Available', unitList[0].Status__c); 
    }
    private static testmethod void syncUnitsTestWithoutTaxCodes() {
    	TestUtil.setQBTaxCodesConfigurations(false);
        Test.startTest();
        createAndReceiveUnitForVendor();
        Test.stopTest();
        
        List<Customer_Owned_Unit__c> unitList = [Select Id, Status__c, AccountingResponse__c, AccountingId__c, availForQBSync__c, vendor__r.Vendor_AccountingId__c, vendor__r.Vendor_availForQBSync__c from Customer_Owned_Unit__c WHERE Status__c = 'Available'];
        system.assertEquals('Available', unitList[0].Status__c); 
    }
}
