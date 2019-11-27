@isTest
private class SOWizardTest {

    static testMethod void SOWizardTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Third-Party', 'Third-Party');
        //transactionType.Third_Party_Customer__c = customer.Id;
        insert transactionType ;
        
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 2;
        insert part;
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', true, 10, 'LabourCodeName', 10, true);
        
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, null, Part.Id, 1, 5.0);
        Kit_Header_Line_Item__c kitHeaderLineItem1 = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, labourCode.Id, null, 1, 5.0);
        
        Test.startTest();
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        List<Service_Order_Header__c> soHeaderList = [select Id from Service_Order_Header__c limit 1];
        
        CustomerApproval__c customerApprovalRec = new CustomerApproval__c();
        customerApprovalRec.Service_Order_Header__c = soHeaderList[0].Id;
        insert customerApprovalRec;
        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c(Id = soHeaderList[0].Id);
        soHeaderRec.Customer_Owned_Unit__c = customerOwnedUnit.Id;
        soHeaderRec.Category__c = testCategory.Id;
        update soHeaderRec;
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(soHeaderList[0].Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        soHeaderList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => soHeaderList[0].Id});
        SOWizard soWizardObj = new SOWizard(soHeaderList[0], 'Sign_In');
        system.assertEquals(soWizardObj.Sign_In.Service_Information.Id, soHeaderList[0].Id);
        
        soWizardObj = new SOWizard(soHeaderList[0], 'Service_Sign_Out');
        soWizardObj = new SOWizard(soHeaderList[0], 'Claim_Submission');
        List<String> fieldList = SOWizard.appLogFieldsList();
        fieldList = SOWizard.getSOHeaderFieldsList();
        SOWizard.SOInfoWrapper soInfo = new SOWizard.SOInfoWrapper('New', 'Ready', new List<String>{'New'}, new List<String>{'Ready'});
        
        App_Log__c appLogRec = new App_Log__c();
        insert appLogRec;
        
        SOWizard.AppLog appLogInfo = new SOWizard.AppLog(appLogRec);
        SOWizard.CustInfo custInfo = new SOWizard.CustInfo();
        Test.stopTest();
        system.assertEquals(1, [select Id from App_Log__c].size());
    }
}