@isTest
private class COInvoiceItemTest {
   
    static testMethod void coInvoiceItemWithPartTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, false, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
       
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Part__c part = TestUtil.createPart(false, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Non_Inventory_Part__c = true;
        insert part;
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, -1);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader.Id, 'Debit', 500);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(true, testCategory.Id, coinvoiceHeader1.Id, coLineItemRec1.Id);
        List<CO_Invoice_Item__c> cOInvoiceItemList = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coinvoiceHeader1.Id);
        Test.startTest();
        COInvoiceItem coInvoiceItemObj = new COInvoiceItem(cOInvoiceItemList[0]);
        Test.stopTest();
        System.assertEquals(coInvoiceItemObj.COInvoiceItemId,cOInvoiceItemList[0].Id);
    }
    
    static testMethod void coInvoiceItemWithTaxablePartTest() {
        TestUtil.createtaxsettingInGeneralConfig();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, false, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
       
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Deal__c dealRec = new Deal__c(CO_Header__c = coHeader.Id, Status__c = Constants.QUOTATION, Type__c = Constants.CASH_DEAL, Unit_Status__c = Constants.TEMPORARY);
        insert dealRec; 
        
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(false, coHeader.Id, part.Id, 5);
        coLineItemRec1.Qty_Committed__c = 5;
        coLineItemRec1.Deal__c = dealRec.Id;
        insert coLineItemRec1;
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader.Id, 'Debit', 500);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(true, testCategory.Id, coinvoiceHeader1.Id, coLineItemRec1.Id);
        List<CO_Invoice_Item__c> cOInvoiceItemList = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coinvoiceHeader1.Id);
        Test.startTest();
        COInvoiceItem coInvoiceItemObj = new COInvoiceItem(cOInvoiceItemList[0]);
        Test.stopTest();
        System.assertEquals(coInvoiceItemObj.COInvoiceItemId,cOInvoiceItemList[0].Id);
    }
    
    static testMethod void coInvoiceItemWithFeeTest() {
        TestUtil.createtaxsettingInGeneralConfig();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, false, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
       
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        CO_Line_Item__c coLineItemRec1 = new CO_Line_Item__c();
        coLineItemRec1.CO_Header__c = coHeader.Id;
        coLineItemRec1.Fee__c = fee.Id;
        insert coLineItemRec1;
        
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader.Id, 'Debit', 500);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(true, testCategory.Id, coinvoiceHeader1.Id, coLineItemRec1.Id);
        List<CO_Invoice_Item__c> cOInvoiceItemList = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coinvoiceHeader1.Id);
        Test.startTest();
        COInvoiceItem coInvoiceItemObj = new COInvoiceItem(cOInvoiceItemList[0]);
        Test.stopTest();
        System.assertEquals(coInvoiceItemObj.COInvoiceItemId,cOInvoiceItemList[0].Id);
    }
    
    static testMethod void coInvoiceItemWithServiceOrderHeaderTest() {
        TestUtil.createtaxsettingInGeneralConfig();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, false, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
       
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Third-Party', 'Third-Party');
        //transactionType.Third_Party_Customer__c = customer.Id;
        insert transactionType ;
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c(Id = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id);
        soHeaderRec.Transaction_Type__c = transactionType.Id;
        update soHeaderRec;
        
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 100);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader.Id, 'Debit', 500);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeader1.Id,null);
        coinvoiceitem1.Service_Order_Header__c = soHeaderRec.Id;
        insert coinvoiceitem1;
        List<CO_Invoice_Item__c> cOInvoiceItemList = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coinvoiceHeader1.Id);
        Test.startTest();
        COInvoiceItem coInvoiceItemObj = new COInvoiceItem(cOInvoiceItemList[0]);
        Test.stopTest();
        System.assertEquals(coInvoiceItemObj.COInvoiceItemId,cOInvoiceItemList[0].Id);
    }
    
     static testMethod void coInvoiceItemWithServiceOrderHeaderInternalTest() {
        TestUtil.createtaxsettingInGeneralConfig();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, false, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
       
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(true, 'Internal', 'Internal');
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c(Id = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id);
        soHeaderRec.Transaction_Type__c = transactionType.Id;
        soHeaderRec.Work_Status__c = Constants.SERVICE_ORDER_STATUS_TO_CHECKOUT;
        update soHeaderRec;
        
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 100);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader.Id, 'Debit', 500);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeader1.Id,null);
        coinvoiceitem1.Service_Order_Header__c = soHeaderRec.Id;
        insert coinvoiceitem1;
        List<CO_Invoice_Item__c> cOInvoiceItemList = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coinvoiceHeader1.Id);
        Test.startTest();
        COInvoiceItem coInvoiceItemObj = new COInvoiceItem(cOInvoiceItemList[0]);
        Test.stopTest();
        System.assertEquals(coInvoiceItemObj.COInvoiceItemId,cOInvoiceItemList[0].Id);
    }
    
    static testMethod void coInvoiceItemWithSoPaymentRoleInternalTest() {
        //Map <String,Schema.RecordTypeInfo> recordTypesadjustment = SO_Payment_Role__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        //System.assert(false,recordTypesadjustment.get('Internal'));
        
        TestUtil.createtaxsettingInGeneralConfig();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, false, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
       
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Third-Party', 'Third-Party');
        //transactionType.Third_Party_Customer__c = customer.Id;
        insert transactionType ;
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c(Id = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id);
        soHeaderRec.Transaction_Type__c = transactionType.Id;
        update soHeaderRec;
        //claim
        Claim__c claimRec = new Claim__c();
        claimRec.Service_Order_Header__c = soHeaderRec.Id;
        insert claimRec;
        
        //SoPaymentRole
        Map <String,Schema.RecordTypeInfo> recordTypes = SO_Payment_Role__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        SO_Payment_Role__c soPaymentRoleRec = new SO_Payment_Role__c();
        soPaymentRoleRec.Service_Order_Header__c = soHeaderRec.Id;
        soPaymentRoleRec.Claim__c = claimRec.Id;
        soPaymentRoleRec.RecordTypeId = recordTypes.get('Internal').getRecordTypeId();
        insert soPaymentRoleRec;
        
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 100);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader.Id, 'Debit', 500);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeader1.Id,null);
        coinvoiceitem1.Service_Order_Header__c = soHeaderRec.Id;
        coinvoiceitem1.SO_Payment_Role__c = soPaymentRoleRec.Id;
        insert coinvoiceitem1;
        List<CO_Invoice_Item__c> cOInvoiceItemList = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coinvoiceHeader1.Id);
        Test.startTest();
        COInvoiceItem coInvoiceItemObj = new COInvoiceItem(cOInvoiceItemList[0]);
        Test.stopTest();
        System.assertEquals(coInvoiceItemObj.COInvoiceItemId,cOInvoiceItemList[0].Id);
    }
    
    static testMethod void coInvoiceItemWithSoPaymentRoleCustomerTest() {
        //Map <String,Schema.RecordTypeInfo> recordTypesadjustment = SO_Payment_Role__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        //System.assert(false,recordTypesadjustment.get('Internal'));
        
        TestUtil.createtaxsettingInGeneralConfig();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, false, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
       
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Third-Party', 'Third-Party');
        //transactionType.Third_Party_Customer__c = customer.Id;
        insert transactionType ;
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c(Id = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id);
        soHeaderRec.Transaction_Type__c = transactionType.Id;
        update soHeaderRec;
        //claim
        Claim__c claimRec = new Claim__c();
        claimRec.Service_Order_Header__c = soHeaderRec.Id;
        insert claimRec;
        
        //SoPaymentRole
        Map <String,Schema.RecordTypeInfo> recordTypes = SO_Payment_Role__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        SO_Payment_Role__c soPaymentRoleRec = new SO_Payment_Role__c();
        soPaymentRoleRec.Service_Order_Header__c = soHeaderRec.Id;
        soPaymentRoleRec.Claim__c = claimRec.Id;
        soPaymentRoleRec.RecordTypeId = recordTypes.get('Customer').getRecordTypeId();
        insert soPaymentRoleRec;
        
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 100);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader.Id, 'Debit', 500);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeader1.Id,null);
        coinvoiceitem1.Service_Order_Header__c = soHeaderRec.Id;
        coinvoiceitem1.SO_Payment_Role__c = soPaymentRoleRec.Id;
        insert coinvoiceitem1;
        List<CO_Invoice_Item__c> cOInvoiceItemList = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coinvoiceHeader1.Id);
        Test.startTest();
        COInvoiceItem coInvoiceItemObj = new COInvoiceItem(cOInvoiceItemList[0]);
        Test.stopTest();
        System.assertEquals(coInvoiceItemObj.COInvoiceItemId,cOInvoiceItemList[0].Id);
    }
    
    static testMethod void coInvoiceItemWithSoPaymentRoleThirdPartyTest() {
        //Map <String,Schema.RecordTypeInfo> recordTypesadjustment = SO_Payment_Role__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        //System.assert(false,recordTypesadjustment.get('Internal'));
        
        TestUtil.createtaxsettingInGeneralConfig();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, false, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
       
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Third-Party', 'Third-Party');
        //transactionType.Third_Party_Customer__c = customer.Id;
        insert transactionType ;
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c(Id = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id);
        soHeaderRec.Transaction_Type__c = transactionType.Id;
        update soHeaderRec;
        //claim
        Claim__c claimRec = new Claim__c();
        claimRec.Service_Order_Header__c = soHeaderRec.Id;
        insert claimRec;
        
        //SoPaymentRole
        Map <String,Schema.RecordTypeInfo> recordTypes = SO_Payment_Role__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        SO_Payment_Role__c soPaymentRoleRec = new SO_Payment_Role__c();
        soPaymentRoleRec.Service_Order_Header__c = soHeaderRec.Id;
        soPaymentRoleRec.Claim__c = claimRec.Id;
        soPaymentRoleRec.RecordTypeId = recordTypes.get('Third Party').getRecordTypeId();
        insert soPaymentRoleRec;
        
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 100);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader.Id, 'Debit', 500);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeader1.Id,null);
        coinvoiceitem1.Service_Order_Header__c = soHeaderRec.Id;
        coinvoiceitem1.SO_Payment_Role__c = soPaymentRoleRec.Id;
        insert coinvoiceitem1;
        List<CO_Invoice_Item__c> cOInvoiceItemList = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coinvoiceHeader1.Id);
        Test.startTest();
        COInvoiceItem coInvoiceItemObj = new COInvoiceItem(cOInvoiceItemList[0]);
        Test.stopTest();
        System.assertEquals(coInvoiceItemObj.COInvoiceItemId,cOInvoiceItemList[0].Id);
    }
    
     static testMethod void coInvoiceItemWithSoPaymentRoleDeductibleTest() {
        //Map <String,Schema.RecordTypeInfo> recordTypesadjustment = SO_Payment_Role__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        //System.assert(false,recordTypesadjustment.get('Internal'));
        
        TestUtil.createtaxsettingInGeneralConfig();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, false, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
       
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Third-Party', 'Third-Party');
        //transactionType.Third_Party_Customer__c = customer.Id;
        insert transactionType ;
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c(Id = soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id);
        soHeaderRec.Transaction_Type__c = transactionType.Id;
        update soHeaderRec;
        //claim
        Claim__c claimRec = new Claim__c();
        claimRec.Service_Order_Header__c = soHeaderRec.Id;
        insert claimRec;
        
        //SoPaymentRole
        Map <String,Schema.RecordTypeInfo> recordTypes = SO_Payment_Role__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        SO_Payment_Role__c soPaymentRoleRec = new SO_Payment_Role__c();
        soPaymentRoleRec.Service_Order_Header__c = soHeaderRec.Id;
        soPaymentRoleRec.Claim__c = claimRec.Id;
        soPaymentRoleRec.Total_Amount__c = 10;
        soPaymentRoleRec.RecordTypeId = recordTypes.get('Deductible').getRecordTypeId();
        insert soPaymentRoleRec;
        
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 100);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader.Id, 'Debit', 500);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeader1.Id,null);
        coinvoiceitem1.Service_Order_Header__c = soHeaderRec.Id;
        coinvoiceitem1.SO_Payment_Role__c = soPaymentRoleRec.Id;
        insert coinvoiceitem1;
        List<CO_Invoice_Item__c> cOInvoiceItemList = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coinvoiceHeader1.Id);
        Test.startTest();
        COInvoiceItem coInvoiceItemObj = new COInvoiceItem(cOInvoiceItemList[0]);
        Test.stopTest();
        System.assertEquals(coInvoiceItemObj.COInvoiceItemId,cOInvoiceItemList[0].Id);
    }
    
    
        
    static testMethod void coInvoiceItemWithCOKitHeaderTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, false, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        CO_Kit_Header__c cokhRec = new CO_Kit_Header__c();
        cokhRec.CO_Header__c = coHeader.Id;
        cokhRec.Kit_Header__c = kitHeader.Id;
        insert cokhRec;
       
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 100);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader.Id, 'Debit', 500);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeader1.Id,null);
        coinvoiceitem1.CO_Kit_Header__c = cokhRec.Id;
        insert coinvoiceitem1;
        List<CO_Invoice_Item__c> cOInvoiceItemList = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coinvoiceHeader1.Id);
        Test.startTest();
        COInvoiceItem coInvoiceItemObj = new COInvoiceItem(cOInvoiceItemList[0]);
        Test.stopTest();
        System.assertEquals(coInvoiceItemObj.COInvoiceItemId,cOInvoiceItemList[0].Id);
    }
    
    static testMethod void coInvoiceItemWithCOKitHeaderCaseTest() {
        TestUtil.createtaxsettingInGeneralConfig();
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, false, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        //Deal
        Deal__c deal1 = new Deal__c();
        deal1.CO_Header__c = coHeader.Id;
        deal1.Type__c = Constants.CASH_DEAL;
        insert deal1; 
        
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        CO_Kit_Header__c cokhRec = new CO_Kit_Header__c();
        cokhRec.CO_Header__c = coHeader.Id;
        cokhRec.Kit_Header__c = kitHeader.Id;
        cokhRec.Deal__c = deal1.Id;
        insert cokhRec;
       
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 100);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader.Id, 'Debit', 500);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeader1.Id,null);
        coinvoiceitem1.CO_Kit_Header__c = cokhRec.Id;
        coinvoiceitem1.Is_Invoiceable__c = true;
        coinvoiceitem1.isActive__c = true;
        insert coinvoiceitem1;
        List<CO_Invoice_Item__c> cOInvoiceItemList = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coinvoiceHeader1.Id);
        Test.startTest();
        COInvoiceItem coInvoiceItemObj = new COInvoiceItem(cOInvoiceItemList[0]);
        Test.stopTest();
        System.assertEquals(coInvoiceItemObj.COInvoiceItemId,cOInvoiceItemList[0].Id);
    }
    
    static testMethod void coInvoiceItemWithDealTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, false, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Deal__c deal1 = new Deal__c();
        deal1.CO_Header__c = coHeader.Id;
        deal1.Type__c = Constants.CASH_DEAL;
        insert deal1; 
       
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 100);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader.Id, 'Debit', 500);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeader1.Id,null);
        coinvoiceitem1.Deal__c = deal1.Id;
        insert coinvoiceitem1;
        //Deal Finance
        DealWrapper.DealFinanceWrapper dealFinanceWrapperObj = new DealWrapper.DealFinanceWrapper(new Deal_Finance__c());
        dealFinanceWrapperObj.FinanceCompanyId = vendor.Id;
        dealFinanceWrapperObj.DownPayment = 100;
        dealFinanceWrapperObj.DealId = deal1.Id;
        String dealFinanceJSON = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealFinanceDetails(BPUtility.getEncodedString(deal1.Id),BPUtility.getEncodedString(System.JSON.serialize(dealFinanceWrapperObj))));
        String dealWrapperJSON = BPUtility.getDecodedString(CustomerOrderCtrl.createDealMerchAndServiceSetion(BPUtility.getEncodedString(deal1.Id), BPUtility.getEncodedString(coHeader.Id)));
        dealFinanceJSON = BPUtility.getDecodedString(CustomerOrderCtrl.updateDealFinanceStatus(BPUtility.getEncodedString(coHeader.Id),BPUtility.getEncodedString(deal1.Id),BPUtility.getEncodedString(dealFinanceJSON), BPUtility.getEncodedString('Submitted')));
        List<Deal_Finance__c> dealFinanceList = [Select Id, Status__c from Deal_Finance__c where Deal__c = :deal1.Id];
        
        List<CO_Invoice_Item__c> cOInvoiceItemList = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coinvoiceHeader1.Id);
        Test.startTest();
        COInvoiceItem coInvoiceItemObj = new COInvoiceItem(cOInvoiceItemList[0]);
        Test.stopTest();
        System.assertEquals(coInvoiceItemObj.COInvoiceItemId,cOInvoiceItemList[0].Id);
    }
    
    static testMethod void coInvoiceItemWithDealTestA() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c salesTax = TestUtil.createSalesTax(true, 'Test Sales Tax2', true, false, true);
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Deal__c deal1 = new Deal__c();
        deal1.CO_Header__c = coHeader.Id;
        deal1.Type__c = Constants.FINANCED;
        insert deal1; 
       
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 100);
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader.Id, 'Debit', 500);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader.Id, 'Active');
        CO_Invoice_Item__c coinvoiceitem1  = TestUtil.createCOInvoiceItem(false, testCategory.Id, coinvoiceHeader1.Id,null);
        coinvoiceitem1.Deal__c = deal1.Id;
        insert coinvoiceitem1;
        
        List<CO_Invoice_Item__c> cOInvoiceItemList = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coinvoiceHeader1.Id);
        Test.startTest();
        COInvoiceItem coInvoiceItemObj = new COInvoiceItem(cOInvoiceItemList[0]);
        Test.stopTest();
        System.assertEquals(coInvoiceItemObj.COInvoiceItemId,cOInvoiceItemList[0].Id);
    }
}