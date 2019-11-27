/**
 * Author: Gourav goyal
 * Since: July 26, 2017
 * Name: ServiceWorkSheetCtrlTest test
 * Description: Controller test Class of ServiceWorkSheetCtrl
**/
@isTest
private class ServiceWorkSheetCtrlTest {
    
    /**
     * Name: getServiceWorkSheetDataTest
     * @param: 
     * @return: 
    */
    static testMethod void getServiceWorkSheetDataTest() {
        Account customer = TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        customer.Email__c = null;
        customer.Work_Email__c = null;
        insert customer;
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, unitmake.Id, unitmodel.Id, null);
        customerOwnedUnit.Unit_Type__c = 'Stock';
        customerOwnedUnit.Status__c = 'Sold';
        insert customerOwnedUnit;
        
        Test.startTest();
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        soHeaderDetailsObj.SOList[0].SOHeaderInfo.COUId = customerOwnedUnit.Id;
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        String jsonStr = System.Json.serialize(soHeaderDetailsObj.SOList[0].SOHeaderInfo);
        String soHeader1Json = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        String serviceWorksheetPrintDetailJson = BPUtility.getDecodedString(CustomerOrderCtrl.getServiceWorksheetPrintDetail(BPUtility.getEncodedString(coHeader.Id)));
        ServiceWorkSheetCtrl serviceObj = new ServiceWorkSheetCtrl(); // Added by gourav for test coverage on 25-07-2017
        CustomerOrderCtrl.saveWorkseetSelectionJson(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(serviceWorksheetPrintDetailJson));
        Test.stopTest();
        
        String serviceWorkSheetJson = ServiceWorkSheetCtrl.getServiceWorkSheetData(BPUtility.getEncodedString(coHeader.Id));
        serviceWorkSheetJson = BPUtility.getDecodedString(serviceWorkSheetJson);
        SOWorkSheetWrapper soWorksheetWrapperRec = (SOWorkSheetWrapper)Json.deserialize(serviceWorkSheetJson,SOWorkSheetWrapper.class);
        List<Business_Profile__c> businessProfileList = SOQLUtil.getBusinessProfileData(new List<Id>());
        if(businessProfileList.size() > 0) {
            SOWorkSheetWrapper.StoreInfoWrapper storeInfoWrapperRec = new SOWorkSheetWrapper.StoreInfoWrapper(businessProfileList[0]);
        } else {
            Business_Profile__c businessProfileObject = new Business_Profile__c();
            businessProfileObject.Business_Street_Address1__c = 'test street1';
            businessProfileObject.Business_Street_Address2__c = 'test street1';
            businessProfileObject.Business_City__c = 'test city'; 
            businessProfileObject.Business_Name__c = 'business 1 ';
            businessProfileObject.Shipping_Postal_Code__c = '302022';
            insert businessProfileObject;
            SOWorkSheetWrapper.StoreInfoWrapper storeInfoWrapperRec = new SOWorkSheetWrapper.StoreInfoWrapper(businessProfileObject);
        }
        System.assertEquals(soWorksheetWrapperRec.UnitList.size(), 1);
    }
    
    /** added by gourav on 25-07-2017
     * Name: getServiceWorkSheetDataSecondTest
     * @param: 
     * @return: 
    */
    static testMethod void getServiceWorkSheetDataSecondTest() {
        Test.startTest();
        String result = ServiceWorkSheetCtrl.getServiceWorkSheetData(null);
        Test.stopTest();
        system.assertEquals(BPUtility.getDecodedString(result), 'null');
    }
}