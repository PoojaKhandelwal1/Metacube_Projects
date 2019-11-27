@isTest
private class LabourRecordTest {

    static testMethod void LabourRecordTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Labour');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code1', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Test.startTest();
        LabourRecord LabourRecord1 = new LabourRecord(labourCode);
        Test.stopTest();
        //system.assert(false,LabourRecord1);
        Labour_Code__c labourCodeList =[Select Id, Name__c, Code__c From Labour_Code__c where Id= :LabourRecord1.Id Limit 1];
        system.assertEquals(labourCodeList.Code__c , 'Code1');
    }
    
    static testMethod void LabourRecordByIdTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Labour');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code1', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        labourCode.Rate__c = 15;
        update labourCode;
        Test.startTest();
        String similarlabourDetails = BPUtility.getDecodedString(ViewLabourCtrl.getSimilarLabourRecords(BPUtility.getEncodedString('Code1'), BPUtility.getEncodedString('NoDescription')));
        LabourRecord.parse(similarlabourDetails);
        List<LabourRecord> labourCodeDetails = (List<LabourRecord>) System.JSON.deserialize(similarlabourDetails, List<LabourRecord>.class);
        LabourRecord LabourRecord1 = new LabourRecord(labourCode.Id);
        Test.stopTest();
        Labour_Code__c labourCodeList =[Select Id, Name__c, Code__c From Labour_Code__c where Id= :LabourRecord1.Id Limit 1];
        system.assertEquals(labourCodeList.Code__c , 'Code1');
    }
    
    static testMethod void LabourRecordWithPriorityLevelTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Labour');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code1', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Test.startTest();
        LabourRecord LabourRecord1 = new LabourRecord(labourCode, 2);
        Test.stopTest();
        Labour_Code__c labourCodeList =[Select Id, Name__c, Code__c From Labour_Code__c where Id= :LabourRecord1.Id Limit 1];
        system.assertEquals(labourCodeList.Code__c , 'Code1');
    }
}