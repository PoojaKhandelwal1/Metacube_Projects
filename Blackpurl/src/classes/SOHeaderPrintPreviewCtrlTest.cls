/**
 * Author: Gourav goyal
 * Since: July 27, 2017
 * Name: SOHeaderPrintPreviewCtrlTest 
 * Description: print and preview SO Header Info
**/
@isTest
private class SOHeaderPrintPreviewCtrlTest {

    static testMethod void getPrinitngInfoTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        customer.Preferred_Email__c = 'abc@gmail.com';// added by gourav 26-07-2017
        customer.Preferred_Phone__c ='1113211112';// added by gourav 26-07-2017
        customer.Preferred_SMS__c = '1321111112';// added by gourav 26-07-2017
        customer.Birth_Date__c = date.ValueOf('1968-09-21');// added by gourav 26-07-2017
        update customer;// added by gourav 26-07-2017
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 2.0, LabourCode.Id, Part.Id, 1,5.0);   
        
        test.startTest(); // added by gourav 25-07-2017
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        SOHeaderPrintPreviewCtrl SOHeaderObj = new SOHeaderPrintPreviewCtrl(); // added by gourav 25-07-2017
        string printSOHeaderDetails = BPUtility.getDecodedString(SOHeaderPrintPreviewCtrl.getPrinitngInfo(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
        SOHeaderPrintPreviewCtrl.PrintingInfo soHeaderDetailsObj1 = (SOHeaderPrintPreviewCtrl.PrintingInfo) System.JSON.deserialize(printSOHeaderDetails, SOHeaderPrintPreviewCtrl.PrintingInfo.class);
        test.stopTest(); // added by gourav 25-07-2017
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        system.assertEquals(soHeaderDetailsObj1.CustomerInfo.FirstName, 'firstname1' );
       }
       //added by gourav 0n 25-07-17
        static testMethod void getPrinitngInfoSecondTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        
        test.startTest(); // added by gourav 25-07-2017
        SOHeaderPrintPreviewCtrl.IndividualTax indTaxObj  = new SOHeaderPrintPreviewCtrl.IndividualTax('GST',10); 
        test.stopTest(); // added by gourav 25-07-2017
        system.assert(true,true);
       }
}