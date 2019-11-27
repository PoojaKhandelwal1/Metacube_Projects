/**
 * Author: Nidhi Sharma
 * Since: Sep 17, 2015
 * Name: ViewUnitCtrl test
 * Description: Controller test Class of View Unit
**/
@isTest
private class ViewUnitCtrlTest {
    
    @testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
    }
    
    /**
     * Name: getUnitDetailsTest
     * Desc: Test to get customer owned unit by ID
     * @param: 
     * @return: 
    **/
    static testMethod void getUnitDetailsTest() {
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, false,'Individual');
        customer.Is_Customer__c = true;
        customer.Preferred_Email__c = 'test@abc.com';
        customer.Other_Email__c = 'test@abc.com';
        customer.Preferred_Phone__c = '1234567890';
        customer.Mobile__c = '1234567890';
        customer.Preferred_SMS__c = '1234567890';
        insert customer;
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        
        //Test method with valid cou id
        Test.startTest();
        String couJSON = BPUtility.getDecodedString(ViewUnitCtrl.getUnitDetails(BPUtility.getEncodedString(customerOwnedUnit.Id)));
        Test.stopTest();
        system.assertEquals(couJSON.length() > 0, true);
        
        //Test method with invalid cou id
        couJSON = BPUtility.getDecodedString(ViewUnitCtrl.getUnitDetails(BPUtility.getEncodedString(customer.Id)));
        String expectedString = '{}';
        system.assertEquals(true, couJSON.length() == 2);
        system.assertEquals(expectedString, couJSON);
        
        //Test method with cou id as blank
        couJSON = BPUtility.getDecodedString(ViewUnitCtrl.getUnitDetails(BPUtility.getEncodedString('')));
        system.assertEquals(true, couJSON.length() == 2);
        system.assertEquals(expectedString, couJSON);
    }
    
    /*
     * Name: saveUnitTest
     * Desc: Test to save customer owned unit
     * @param: 
     * @return: 
    **/
    
    static testMethod void saveCustomerTest() {
        Decimal expected;
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, false,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnitObj1 = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnitObj1.Unit_Type__c = 'COU';
        customerOwnedUnitObj1.Status__c = 'Active';
        customerOwnedUnitObj1.Year__c = 2000;
        insert customerOwnedUnitObj1;
        
        expected = 2000;
        customerOwnedUnitObj1 = [Select Year__c from Customer_Owned_Unit__c where id = :customerOwnedUnitObj1.Id];
        System.assertEquals(expected, customerOwnedUnitObj1.Year__c);
        
        String couJSON = BPUtility.getDecodedString(ViewUnitCtrl.getUnitDetails(BPUtility.getEncodedString(customerOwnedUnitObj1.Id)));
        UnitWrapper unitObj = (UnitWrapper) System.JSON.deserialize(couJSON, UnitWrapper.class);
        unitObj.UnitInfo.Year = 2016;
        
        couJSON = System.JSON.serialize(unitObj);
        
        Test.startTest();
        String customerResults = BPUtility.getDecodedString(ViewUnitCtrl.saveUnit(BPUtility.getEncodedString(couJSON)));
        Test.stopTest();
        
        expected = 2016;
        customerOwnedUnitObj1 = [Select Year__c from Customer_Owned_Unit__c where id = :customerOwnedUnitObj1.Id];
        System.assertEquals(expected, customerOwnedUnitObj1.Year__c);
        
        Customer_Owned_Unit__c customerOwnedUnitObj2 = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnitObj2.Unit_Type__c = 'COU';
        customerOwnedUnitObj2.Status__c = 'Inactive';
        insert customerOwnedUnitObj2;
        couJSON = BPUtility.getDecodedString(ViewUnitCtrl.getUnitDetails(BPUtility.getEncodedString(customerOwnedUnitObj2.Id)));
        unitObj = (UnitWrapper) System.JSON.deserialize(couJSON, UnitWrapper.class);
        
        Customer_Owned_Unit__c customerOwnedUnitObj3 = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnitObj3.Unit_Type__c = 'COU';
        customerOwnedUnitObj3.Status__c = 'Transferred';
        insert customerOwnedUnitObj3;
        couJSON = BPUtility.getDecodedString(ViewUnitCtrl.getUnitDetails(BPUtility.getEncodedString(customerOwnedUnitObj3.Id)));
        unitObj = (UnitWrapper) System.JSON.deserialize(couJSON, UnitWrapper.class);
        
        Customer_Owned_Unit__c customerOwnedUnitObj4 = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnitObj4.Unit_Type__c = 'Stock';
        customerOwnedUnitObj4.Status__c = 'Available';
        insert customerOwnedUnitObj4;
        couJSON = BPUtility.getDecodedString(ViewUnitCtrl.getUnitDetails(BPUtility.getEncodedString(customerOwnedUnitObj4.Id)));
        unitObj = (UnitWrapper) System.JSON.deserialize(couJSON, UnitWrapper.class);
        
        Customer_Owned_Unit__c customerOwnedUnitObj5 = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnitObj5.Unit_Type__c = 'Stock';
        customerOwnedUnitObj5.Status__c = 'Delivered';
        insert customerOwnedUnitObj5;
        couJSON = BPUtility.getDecodedString(ViewUnitCtrl.getUnitDetails(BPUtility.getEncodedString(customerOwnedUnitObj5.Id)));
        unitObj = (UnitWrapper) System.JSON.deserialize(couJSON, UnitWrapper.class);
        
        Customer_Owned_Unit__c customerOwnedUnitObj6 = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnitObj6.Unit_Type__c = 'Stock';
        customerOwnedUnitObj6.Status__c = 'Sold';
        customerOwnedUnitObj6.Year__c = 2000;
        insert customerOwnedUnitObj6;
        couJSON = BPUtility.getDecodedString(ViewUnitCtrl.getUnitDetails(BPUtility.getEncodedString(customerOwnedUnitObj6.Id)));
        unitObj = (UnitWrapper) System.JSON.deserialize(couJSON, UnitWrapper.class);
        
        Customer_Owned_Unit__c customerOwnedUnitObj7 = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnitObj7.Unit_Type__c = 'ORDU';
        customerOwnedUnitObj7.Status__c = 'On Order';
        customerOwnedUnitObj7.Year__c = 2000;
        insert customerOwnedUnitObj7;
        couJSON = BPUtility.getDecodedString(ViewUnitCtrl.getUnitDetails(BPUtility.getEncodedString(customerOwnedUnitObj7.Id)));
        unitObj = (UnitWrapper) System.JSON.deserialize(couJSON, UnitWrapper.class);
        
        Customer_Owned_Unit__c customerOwnedUnitObj8 = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnitObj8.Unit_Type__c = 'ORDU';
        customerOwnedUnitObj8.Status__c = 'Traded';
        customerOwnedUnitObj8.Year__c = 2000;
        insert customerOwnedUnitObj8;
        couJSON = BPUtility.getDecodedString(ViewUnitCtrl.getUnitDetails(BPUtility.getEncodedString(customerOwnedUnitObj8.Id)));
        unitObj = (UnitWrapper) System.JSON.deserialize(couJSON, UnitWrapper.class);
    }
    
    /**
     * Name: saveNotesForUnitTest
     * Desc: Test to update notes for customer unit
     * @param: 
     * @return: 
    **/
    static testMethod void saveNotesForUnitTest() {
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, false,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        
        String unitNotes = 'This is a sample unit.';
        
        Test.startTest();
        ViewUnitCtrl.saveNotesForUnit(BPUtility.getEncodedString(customerOwnedUnit.Id), BPUtility.getEncodedString(unitNotes));
        Test.stopTest();

        customerOwnedUnit = [Select Notes__c from Customer_Owned_Unit__c where Id = :customerOwnedUnit.Id];
        
        system.assertEquals(unitNotes, customerOwnedUnit.Notes__c);
    }
    
    /**
     * Name: parseUnitTest
     * Desc: Test to parse customer unit
     * @param: 
     * @return: 
    **/
    static testMethod void parseUnitTest() {
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, false,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        
        Test.startTest();
        String couJSON = BPUtility.getDecodedString(ViewUnitCtrl.getUnitDetails(BPUtility.getEncodedString(customerOwnedUnit.Id)));
        UnitWrapper unitObj = UnitWrapper.parse(couJSON);
        Test.stopTest();

        system.assertEquals(customer.Id, unitObj.UnitInfo.Customer);
    }
    
    static testMethod void saveUnitTest() {
        Decimal expected;
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, false,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnitObj1 = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnitObj1.Unit_Type__c = 'COU';
        customerOwnedUnitObj1.Status__c = 'Active';
        customerOwnedUnitObj1.Year__c = 2000;
        insert customerOwnedUnitObj1;
        
        expected = 2000;
        customerOwnedUnitObj1 = [Select Year__c from Customer_Owned_Unit__c where id = :customerOwnedUnitObj1.Id];
        System.assertEquals(expected, customerOwnedUnitObj1.Year__c);
        
        String couJSON = BPUtility.getDecodedString(ViewUnitCtrl.getUnitDetails(BPUtility.getEncodedString(customerOwnedUnitObj1.Id)));
        UnitWrapper unitObj = (UnitWrapper) System.JSON.deserialize(couJSON, UnitWrapper.class);
        //system.assert(false, unitObj );
        unitObj.UnitInfo.Year = 2016;
        unitObj.UnitInfo.VIN = 'JM3KE2DY2E03240711';
        
        couJSON = System.JSON.serialize(unitObj);
        
        Test.startTest();
        String customerResults = BPUtility.getDecodedString(ViewUnitCtrl.saveUnit(BPUtility.getEncodedString(couJSON)));
        UnitWrapper unitObj1 = (UnitWrapper) System.JSON.deserialize(customerResults, UnitWrapper.class);
        //system.assert(false, unitObj1);
        Test.stopTest();
        System.assertEquals(unitObj1.UnitInfo.VIN, 'JM3KE2DY2E03240711');
}

    //Start: Added By Pooja 30 Jan 2017
    /**
     * Name: getCustomerInfoTest 
     * Desc: Test to fetch customer information on customerId.
     * @param: 
     * @return: 
    **/
    static testMethod void getCustomerInfoTest() {
        
        Account testCustomer = TestUtil.createCustomer(true, 'Test Customer', 'a.b@gmail.com', 'Jaipur', '987456123');
        Test.startTest();
        String customerJSON = BPUtility.getDecodedString(ViewUnitCtrl.getCustomerInfo(BPUtility.getEncodedString(testCustomer.Id)));
        Test.stopTest();
        system.assertEquals(customerJSON.length() > 0, true);
    }
    
    /**
     * Name: savePriceAndCostTest 
     * Desc: Test to save Price And Cost Tracking values for Unit.
     * @param: 
     * @return: 
    **/
    static testMethod void savePriceAndCostTest() {
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Customer_Owned_Unit__c  customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, Customer.Id, null, null, null, 'VIN123');
        Unit_Price_Cost__c unitPriceAndCostRec = new Unit_Price_Cost__c();
        unitPriceAndCostRec.Customer_Owned_Unit__c = customerOwnedUnit.Id;
        unitPriceAndCostRec.Type__c = 'Base';
        unitPriceAndCostRec.Total_Price__c = 100;
        unitPriceAndCostRec.Total_Cost__c = 100;
        unitPriceAndCostRec.Item_Description__c = 'ItemDesc';
        insert unitPriceAndCostRec;
        
        UnitWrapper.PriceAndCostTrackingWrapper unitPriceAndCostObj = new UnitWrapper.PriceAndCostTrackingWrapper(unitPriceAndCostRec);
        String unitPriceAndCostJson = BPUtility.getEncodedString(System.JSON.serialize(unitPriceAndCostObj));
        Test.startTest();
        String PriceAndCostTrackingWrapperListJson = BPUtility.getDecodedString(ViewUnitCtrl.savePriceAndCost(BPUtility.getEncodedString(customerOwnedUnit.Id), unitPriceAndCostJson));
        Test.stopTest(); 
        
        
        List<Customer_Owned_Unit__c> unitList = SOQLUtil.getUnitByFieldName(new Map<String, String>{'Id' => customerOwnedUnit.Id});
        UnitWrapper unitWrapperObj = new UnitWrapper(unitList[0], new List<Customer_Owned_Unit__c>(), new List<Sales_Tax__c>(), new List<Service_Order_Header__c>());
        system.assertEquals(unitWrapperObj.PriceAndCostTrackingWrapperList.size(), 1);
        system.assertEquals(unitWrapperObj.PriceAndCostTrackingWrapperList[0].Type, 'Base');
        system.assertEquals(unitWrapperObj.PriceAndCostTrackingWrapperList[0].ItemDescription, 'ItemDesc');
        system.assertEquals(unitWrapperObj.PriceAndCostTrackingWrapperList[0].TotalCost, 100);
        system.assertEquals(unitWrapperObj.PriceAndCostTrackingWrapperList[0].TotalPrice, 100);
    }
    //End: Added By Pooja 30 Jan 2017
    
    /**
     * Name: uploadImageTest 
     * Desc: Test to upload image for Unit.
     * @param: 
     * @return: 
    **/
    static testMethod void uploadImageTest() {
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, false,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        
        Test.startTest();
        String imageJson = BPUtility.getDecodedString(ViewUnitCtrl.uploadImage(BPUtility.getEncodedString('bike.jpg'), BPUtility.getEncodedString('Unit Test Attachment Body'), BPUtility.getEncodedString(customerOwnedUnit.Id)));
        List<UnitWrapper.Documents> imageObjList = (List<UnitWrapper.Documents>) System.JSON.deserialize(imageJson, List<UnitWrapper.Documents>.class);
        Test.stopTest();
        system.assertEquals(1, imageObjList.size());
        system.assertEquals(true, imageObjList[0].IsPrimary);
    }
    
    /**
     * Name: pinImageTest 
     * Desc: Test to pin image for Unit.
     * @param: 
     * @return: 
    **/
    static testMethod void pinImageTest() {
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, false,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        String imageJson1 = BPUtility.getDecodedString(ViewUnitCtrl.uploadImage(BPUtility.getEncodedString('bike1.jpg'), BPUtility.getEncodedString('Unit Test Attachment Body1'), BPUtility.getEncodedString(customerOwnedUnit.Id)));
        String imageJson2 = BPUtility.getDecodedString(ViewUnitCtrl.uploadImage(BPUtility.getEncodedString('bike2.jpg'), BPUtility.getEncodedString('Unit Test Attachment Body2'), BPUtility.getEncodedString(customerOwnedUnit.Id)));
        List<UnitWrapper.Documents> imageObjList = (List<UnitWrapper.Documents>) System.JSON.deserialize(imageJson2, List<UnitWrapper.Documents>.class);
        if(imageObjList.size() == 2) {
            Test.startTest();
            String result = BPUtility.getDecodedString(ViewUnitCtrl.pinImage(BPUtility.getEncodedString(imageObjList[1].DocId), true, BPUtility.getEncodedString(customerOwnedUnit.Id)));
            Test.stopTest();
            System.assertEquals('Success', result);
        }
    }
    
    /**
     * Name: deleteImageTest 
     * Desc: Test to delete image for Unit.
     * @param: 
     * @return: 
    **/
    static testMethod void deleteImageTest() {
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, false,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        String imageJson = BPUtility.getDecodedString(ViewUnitCtrl.uploadImage(BPUtility.getEncodedString('bike1.jpg'), BPUtility.getEncodedString('Unit Test Attachment Body1'), BPUtility.getEncodedString(customerOwnedUnit.Id)));
        List<UnitWrapper.Documents> imageObjList = (List<UnitWrapper.Documents>) System.JSON.deserialize(imageJson, List<UnitWrapper.Documents>.class);
        if(imageObjList.size() > 0) {
            Test.startTest();
            String imageJsonAfterDel = BPUtility.getDecodedString(ViewUnitCtrl.deleteImage(BPUtility.getEncodedString(imageObjList[0].DocId), BPUtility.getEncodedString(customerOwnedUnit.Id)));
            List<UnitWrapper.Documents> imageObjListAfterDel = (List<UnitWrapper.Documents>) System.JSON.deserialize(imageJsonAfterDel, List<UnitWrapper.Documents>.class);
            Test.stopTest();
            System.assertEquals(0, imageObjListAfterDel.size());
        }
    }
}
