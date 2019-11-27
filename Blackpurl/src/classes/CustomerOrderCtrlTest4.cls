/**
 * Author: Tarun Khandelwal
 * Since: Oct 18, 2018
 * Name: CustomerOrderCtrlTest4 test
 * Description: Controller test Class of Customer order ctrl.
**/
@isTest
private class CustomerOrderCtrlTest4 {
    
    @testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
    }
    
    static testMethod void submitResponseAfterQtyVarianceTest() {
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Claims_for_Service_Work__c = true;
        insert vendor;
        
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
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        
        //system.assert(false, soHeaderDetailsObj2 );
        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString( jsonStr)));
        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
        
        //system.assert(false, soHeaderDetailsObj3);
       String deductible =  BPUtility.getDecodedString(CustomerOrderCtrl.addDeductibleAmount(BPUtility.getEncodedString('{"SoHeaderId":"'+soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id+'","DeductibleStatus":null,"DeductibleId":null,"DeductibleAmount":"10","CoHeaderId":"'+coHeader.Id+'"}')));
       SOHeaderWrapper details12 = (SOHeaderWrapper) System.JSON.deserialize(deductible, SOHeaderWrapper.class);
       //system.assertEquals(details12.SOList[0].DeductibleItem.DeductibleAmount, 10.000);
       String submittedClaim = BPUtility.getDecodedString(CustomerOrderCtrl.submitClaimRecords(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       
       String claimedRecord = BPUtility.getDecodedString(CustomerOrderCtrl.getClaimRecById(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       ClaimWizard claimWizardDetails = (ClaimWizard) System.JSON.deserialize(claimedRecord, ClaimWizard.class);
       claimWizardDetails.NonVarianceLineItemList[0].ApprovedQty = 40 ;
       JsonStr = System.JSON.serialize(claimWizardDetails);
       //system.assert(false, claimWizardDetails );
       String  claimResponse = BPUtility.getDecodedString(CustomerOrderCtrl.saveClaimResponse(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(JsonStr), '2'));
       
       Test.stoptest();
       
       List<Claim_Line_Item__c> claimLineItemList = [select Claimed_Qty__c, Claimed_Price__c, Claimed_Subtotal__c,  Item_Desc__c, Approved_Qty__c, Approved_Price__c, Approved_Subtotal__c, Variance__c from Claim_Line_Item__c];
       //system.assert(false, claimLineItemList);
       system.assertEquals(claimLineItemList[0].Approved_Qty__c, 40);
       system.assertEquals(claimLineItemList[0].Variance__c, -550);
       system.assertEquals(claimLineItemList[0].Approved_Subtotal__c, 2200);
       
         
         }
         
static testMethod void submitResponseAfterPriceVarianceTest() {
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Claims_for_Service_Work__c = true;
        insert vendor;
        
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
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        
        //system.assert(false, soHeaderDetailsObj2 );
        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
        
        //system.assert(false, soHeaderDetailsObj3);
       String deductible =  BPUtility.getDecodedString(CustomerOrderCtrl.addDeductibleAmount(BPUtility.getEncodedString('{"SoHeaderId":"'+soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id+'","DeductibleStatus":null,"DeductibleId":null,"DeductibleAmount":"10","CoHeaderId":"'+coHeader.Id+'"}')));
       SOHeaderWrapper details12 = (SOHeaderWrapper) System.JSON.deserialize(deductible, SOHeaderWrapper.class);
       //system.assertEquals(details12.SOList[0].DeductibleItem.DeductibleAmount, 10.000);
       String submittedClaim = BPUtility.getDecodedString(CustomerOrderCtrl.submitClaimRecords(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       
       String claimedRecord = BPUtility.getDecodedString(CustomerOrderCtrl.getClaimRecById(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       ClaimWizard claimWizardDetails = (ClaimWizard) System.JSON.deserialize(claimedRecord, ClaimWizard.class);
       claimWizardDetails.NonVarianceLineItemList[0].ApprovedPrice = 50 ;
       JsonStr = System.JSON.serialize(claimWizardDetails);
       //system.assert(false, claimWizardDetails );
       String  claimResponse = BPUtility.getDecodedString(CustomerOrderCtrl.saveClaimResponse(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(JsonStr), '2'));
       
       Test.stoptest();
       
       List<Claim_Line_Item__c> claimLineItemList = [select Claimed_Qty__c, Claimed_Price__c, Claimed_Subtotal__c,  Item_Desc__c, Approved_Qty__c, Approved_Price__c, Approved_Subtotal__c, Variance__c from Claim_Line_Item__c];
       //system.assert(false, claimLineItemList);
       system.assertEquals(claimLineItemList[0].Approved_Qty__c, 50);
       system.assertEquals(claimLineItemList[0].Variance__c, -250);
       system.assertEquals(claimLineItemList[0].Approved_Subtotal__c, 2500);
       
         
         }
         
static testMethod void submitResponseonDenialTest() {
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Claims_for_Service_Work__c = true;
        insert vendor;
        
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
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        
        //system.assert(false, soHeaderDetailsObj2 );
        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
        
        //system.assert(false, soHeaderDetailsObj3);
       String deductible =  BPUtility.getDecodedString(CustomerOrderCtrl.addDeductibleAmount(BPUtility.getEncodedString('{"SoHeaderId":"'+soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id+'","DeductibleStatus":null,"DeductibleId":null,"DeductibleAmount":"10","CoHeaderId":"'+coHeader.Id+'"}')));
       SOHeaderWrapper details12 = (SOHeaderWrapper) System.JSON.deserialize(deductible, SOHeaderWrapper.class);
       //system.assertEquals(details12.SOList[0].DeductibleItem.DeductibleAmount, 10.000);
       String submittedClaim = BPUtility.getDecodedString(CustomerOrderCtrl.submitClaimRecords(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       
       String claimedRecord = BPUtility.getDecodedString(CustomerOrderCtrl.getClaimRecById(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       ClaimWizard claimWizardDetails = (ClaimWizard) System.JSON.deserialize(claimedRecord, ClaimWizard.class);
       claimWizardDetails.NonVarianceLineItemList[0].ApprovedQty = 0 ;
       JsonStr = System.JSON.serialize(claimWizardDetails);
       //system.assert(false, claimWizardDetails );
       String  claimResponse = BPUtility.getDecodedString(CustomerOrderCtrl.saveClaimResponse(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(JsonStr), '2'));
       
       Test.stoptest();
       
       List<Claim_Line_Item__c> claimLineItemList = [select Claimed_Qty__c, Claimed_Price__c, Claimed_Subtotal__c,  Item_Desc__c, Approved_Qty__c, Approved_Price__c, Approved_Subtotal__c, Variance__c from Claim_Line_Item__c];
       //system.assert(false, claimLineItemList);
       system.assertEquals(claimLineItemList[0].Approved_Qty__c, 0);
       system.assertEquals(claimLineItemList[0].Variance__c, -2750);
       system.assertEquals(claimLineItemList[0].Approved_Subtotal__c, 0);
       
         
         }
         
static testMethod void submitResponseonAcceptTest() {
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Claims_for_Service_Work__c = true;
        insert vendor;
        
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
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        
        //system.assert(false, soHeaderDetailsObj2 );
        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
        
        //system.assert(false, soHeaderDetailsObj3);
       String deductible =  BPUtility.getDecodedString(CustomerOrderCtrl.addDeductibleAmount(BPUtility.getEncodedString('{"SoHeaderId":"'+soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id+'","DeductibleStatus":null,"DeductibleId":null,"DeductibleAmount":"10","CoHeaderId":"'+coHeader.Id+'"}')));
       SOHeaderWrapper details12 = (SOHeaderWrapper) System.JSON.deserialize(deductible, SOHeaderWrapper.class);
       //system.assertEquals(details12.SOList[0].DeductibleItem.DeductibleAmount, 10.000);
       String submittedClaim = BPUtility.getDecodedString(CustomerOrderCtrl.submitClaimRecords(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       
       String claimedRecord = BPUtility.getDecodedString(CustomerOrderCtrl.getClaimRecById(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       ClaimWizard claimWizardDetails = (ClaimWizard) System.JSON.deserialize(claimedRecord, ClaimWizard.class);
       JsonStr = System.JSON.serialize(claimWizardDetails);
       //system.assert(false, claimWizardDetails );
       String  claimResponse = BPUtility.getDecodedString(CustomerOrderCtrl.saveClaimResponse(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(JsonStr), '1'));
       
       Test.stoptest();
       
       List<Claim_Line_Item__c> claimLineItemList = [select Claimed_Qty__c, Claimed_Price__c, Claimed_Subtotal__c,  Item_Desc__c, Approved_Qty__c, Approved_Price__c, Approved_Subtotal__c, Variance__c from Claim_Line_Item__c];
       //system.assert(false, claimLineItemList);
       system.assertEquals(claimLineItemList[0].Approved_Qty__c, 50);
       system.assertEquals(claimLineItemList[0].Variance__c, 0);
       system.assertEquals(claimLineItemList[0].Approved_Subtotal__c, 2750);
       
         
         }
         
static testMethod void finalizeResponseAfterQtyVarianceTest() {
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Claims_for_Service_Work__c = true;
        insert vendor;
        
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
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        
        //system.assert(false, soHeaderDetailsObj2 );
        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
        
        //system.assert(false, soHeaderDetailsObj3);
       String deductible =  BPUtility.getDecodedString(CustomerOrderCtrl.addDeductibleAmount(BPUtility.getEncodedString('{"SoHeaderId":"'+soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id+'","DeductibleStatus":null,"DeductibleId":null,"DeductibleAmount":"10","CoHeaderId":"'+coHeader.Id+'"}')));
       SOHeaderWrapper details12 = (SOHeaderWrapper) System.JSON.deserialize(deductible, SOHeaderWrapper.class);
       //system.assertEquals(details12.SOList[0].DeductibleItem.DeductibleAmount, 10.000);
       String submittedClaim = BPUtility.getDecodedString(CustomerOrderCtrl.submitClaimRecords(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       
       String claimedRecord = BPUtility.getDecodedString(CustomerOrderCtrl.getClaimRecById(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       ClaimWizard claimWizardDetails = (ClaimWizard) System.JSON.deserialize(claimedRecord, ClaimWizard.class);
       claimWizardDetails.NonVarianceLineItemList[0].ApprovedQty = 40 ;
       JsonStr = System.JSON.serialize(claimWizardDetails);
       //system.assert(false, claimWizardDetails );
       String  claimResponse = BPUtility.getDecodedString(CustomerOrderCtrl.saveClaimResponse(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(JsonStr), '2'));
       ClaimWizard claimWizardDetails1 = (ClaimWizard) System.JSON.deserialize(claimResponse, ClaimWizard.class);
       claimWizardDetails1.VarianceLineItemList[0].BillTo = 'Customer';
       System.JSON.serialize(claimWizardDetails1);
       String  claimResponse1 = BPUtility.getDecodedString(CustomerOrderCtrl.saveClaimResponse(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id),BPUtility.getEncodedString( System.JSON.serialize(claimWizardDetails1)), '3'));
       ClaimWizard claimWizardDetails2 = (ClaimWizard) System.JSON.deserialize(claimResponse1, ClaimWizard.class);
       Test.stoptest();
       
       system.assertEquals(claimWizardDetails2.DeductibleAmount, 10 );
       system.assertEquals(claimWizardDetails2.VarianceLineItemList[0].BillTo, 'Customer' );
       
       
       

       
         
         }
         
static testMethod void getSOPaymentRoleTest() {
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Claims_for_Service_Work__c = true;
        insert vendor;
        
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
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        
        //system.assert(false, soHeaderDetailsObj2 );
        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
        
        //system.assert(false, soHeaderDetailsObj3);
       String deductible =  BPUtility.getDecodedString(CustomerOrderCtrl.addDeductibleAmount(BPUtility.getEncodedString('{"SoHeaderId":"'+soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id+'","DeductibleStatus":null,"DeductibleId":null,"DeductibleAmount":"10","CoHeaderId":"'+coHeader.Id+'"}')));
       SOHeaderWrapper details12 = (SOHeaderWrapper) System.JSON.deserialize(deductible, SOHeaderWrapper.class);
       //system.assertEquals(details12.SOList[0].DeductibleItem.DeductibleAmount, 10.000);
       String submittedClaim = BPUtility.getDecodedString(CustomerOrderCtrl.submitClaimRecords(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       
       String claimedRecord = BPUtility.getDecodedString(CustomerOrderCtrl.getClaimRecById(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       ClaimWizard claimWizardDetails = (ClaimWizard) System.JSON.deserialize(claimedRecord, ClaimWizard.class);
       System.JSON.serialize(claimWizardDetails);
       

       String  claimResponse1 = BPUtility.getDecodedString(CustomerOrderCtrl.saveClaimResponse(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id),BPUtility.getEncodedString( System.JSON.serialize(claimWizardDetails)),'3'));
       ClaimWizard claimWizardDetails2 = (ClaimWizard) System.JSON.deserialize(claimResponse1, ClaimWizard.class);
       claimWizardDetails2.NonVarianceLineItemList[0].PaymentStatus = 'Owing';
       Test.stoptest();
       
       system.assertEquals(claimWizardDetails2.DeductibleAmount, 10 );
       String SOPaymentRole = BPUtility.getDecodedString(CustomerOrderCtrl.getSoPaymentRoleById(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       List<SOPaymentWrapper> paymentRoleDetails = (List<SOPaymentWrapper>) System.JSON.deserialize(SOPaymentRole, List<SOPaymentWrapper>.class);
       
       List<SO_Payment_Role__c> soPaymentList  = [select Claim__c, Deductible_Status__c, Qty__c, Status__c, Tax_Amount__c, Total_Amount__c, Variance__c, recordtype.developername from SO_Payment_Role__c];
       
       system.assertEquals(soPaymentList.size(), 2);
       system.assertEquals(soPaymentList[0].Total_Amount__c, 10);
       
         }
         
static testMethod void getStatusResultTest() {
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Claims_for_Service_Work__c = true;
        insert vendor;
        
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
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
        Test.stoptest();
        
        String SOHeaderDetails12 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper details123 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails12, SOHeaderWrapper.class);
        String statusResult = BPUtility.getDecodedString(CustomerOrderCtrl.getStatusResults(BPUtility.getEncodedString('New'), BPUtility.getEncodedString('Approved')));
        SOWizard.SOInfoWrapper details1234 = (SOWizard.SOInfoWrapper) System.JSON.deserialize(statusResult, SOWizard.SOInfoWrapper.class);
        //system.assertEquals(details1234.AvailableClaimStatusList[0].AvailableStatus, 'View Claim Response');
        //system.assertEquals(details1234.AvailableWorkStatusList[0].AvailableStatus, 'Sign In');
        //system.assertEquals(details1234.AvailableWorkStatusList[1].AvailableStatus, 'Force To Ready');
         }
         
static testMethod void sendOnSignInWizardTest() {
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Claims_for_Service_Work__c = true;
        insert vendor;
        
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
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString( null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        
        //system.assert(false, soHeaderDetailsObj2 );
        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString( jsonStr)));
        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
        
        //system.assert(false, soHeaderDetailsObj3);
        
        String wizardInfo = BPUtility.getDecodedString(CustomerOrderCtrl.getWizardInfo(BPUtility.getEncodedString(soHeaderDetailsObj3.Id), BPUtility.getEncodedString('Sign_In')));
        SOWizard wizardDetails = (SOWizard) System.JSON.deserialize(wizardInfo, SOWizard.class);
        String sendEmail =  BPUtility.getDecodedString(CustomerOrderCtrl.sendOnSignInWizard(BPUtility.getEncodedString('[{"Label":"SEND EMAIL (Home)","Value":"durga.singh@metacube.com","IsSelected":true,"Type":"EMAIL"}]'),BPUtility.getEncodedString( 'OilChange'),BPUtility.getEncodedString( soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString('customerName')));
        Test.stopTest();
        
        system.assertEquals(sendEmail, 'Sent');
         
         }
         
		static testMethod void getPrintingInfoTest() {
	        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
	        vendor.Claims_for_Service_Work__c = true;
	        insert vendor;
	        
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
	        
	        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
	        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
	        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
	        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
	        
	        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
	        
	        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
	        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
	        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 50.00 ;
	        //system.assert(false, soHeaderDetailsObj1 );
	        
	        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
	        COLineItemTriggerHelper.isTriggerExecute = false;
	        COTriggerHelper.isTriggerExecute = false;
	        Test.startTest();
	        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
	        
	        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(updatedSOLI, SOHeaderWrapper.class);
	        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
	        soHeaderDetailsObj2.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
	        
	        //system.assert(false, soHeaderDetailsObj2 );
	        String jsonStr = System.Json.serialize(soHeaderDetailsObj2.SOList[0].SOHeaderInfo);
	        
	        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
	        SOHeaderWrapper.SOHeader soHeaderDetailsObj3 = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(soHeaderInfo, SOHeaderWrapper.SOHeader.class);
	        
	        //system.assert(false, soHeaderDetailsObj3);
	       String deductible =  BPUtility.getDecodedString(CustomerOrderCtrl.addDeductibleAmount(BPUtility.getEncodedString('{"SoHeaderId":"'+soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id+'","DeductibleStatus":null,"DeductibleId":null,"DeductibleAmount":"10","CoHeaderId":"'+coHeader.Id+'"}')));
	       SOHeaderWrapper details12 = (SOHeaderWrapper) System.JSON.deserialize(deductible, SOHeaderWrapper.class);
	       //system.assertEquals(details12.SOList[0].DeductibleItem.DeductibleAmount, 10.000);
	       String submittedClaim = BPUtility.getDecodedString(CustomerOrderCtrl.submitClaimRecords(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
	       
	       String claimedRecord = BPUtility.getDecodedString(CustomerOrderCtrl.getClaimRecById(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
	       ClaimWizard claimWizardDetails = (ClaimWizard) System.JSON.deserialize(claimedRecord, ClaimWizard.class);
	       System.JSON.serialize(claimWizardDetails);
	       
	
	       String  claimResponse1 = BPUtility.getDecodedString(CustomerOrderCtrl.saveClaimResponse(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(System.JSON.serialize(claimWizardDetails)), '3'));
	       ClaimWizard claimWizardDetails2 = (ClaimWizard) System.JSON.deserialize(claimResponse1, ClaimWizard.class);
	       claimWizardDetails2.NonVarianceLineItemList[0].PaymentStatus = 'Owing';
	       
	       
	       system.assertEquals(claimWizardDetails2.DeductibleAmount, 10 );
	       String SOPaymentRole = BPUtility.getDecodedString(CustomerOrderCtrl.getSoPaymentRoleById(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
	       List<SOPaymentWrapper> paymentRoleDetails = (List<SOPaymentWrapper>) System.JSON.deserialize(SOPaymentRole, List<SOPaymentWrapper>.class);
	       Test.stoptest();
	       List<SO_Payment_Role__c> soPaymentList  = [select Claim__c, Deductible_Status__c, Qty__c, Status__c, Tax_Amount__c, Total_Amount__c, Variance__c, recordtype.developername from SO_Payment_Role__c];
	       
	       system.assertEquals(soPaymentList.size(), 2);
	       system.assertEquals(soPaymentList[0].Total_Amount__c, 10);
	       
	       String info = BPUtility.getDecodedString(CustomerOrderCtrl.getPrintingInfo(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
	       system.assertEquals(info.contains('2750'), true);
	       getPrintingInfoAsyncHandle();
       
         }
         
        @future
		private static void getPrintingInfoAsyncHandle() {
			Service_Order_Header__c soh = [select id from Service_Order_Header__c];
	       	//system.assert(false, soh) ;
	       	CustomerOrderCtrl.createClaim(soh);
		}
         
    static testMethod void salesTaxCalculationForAustralianMarket() {
        TestUtil.createtaxsettingInGeneralConfig();
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'Cost', 10 , true, true);
        
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        Applicable_Taxes__c applicabletax1 = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem1.Id);
        
        Part__c part = TestUtil.createPart(false, 'part', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Applicable_Tax__c = salestax.Id;
        insert part;
        
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Tax_Exemption__c taxExemption = Testutil.createCOTaxExemption(true, coHeader.Id, salestaxItem.Id);
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 1);
        
        String coDetailsJSON1 = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetailsByGridName(BPUtility.getEncodedString( coHeader.Id), BPUtility.getEncodedString( null)));
        COHeaderWrapper coDetails1 = (COHeaderWrapper) System.JSON.deserialize(coDetailsJSON1, COHeaderWrapper.class);
        System.assertEquals( coDetails1.allCOLineItemRecs[0].price, 24.20);
        
        String gridTotal = BPUtility.getDecodedString(CustomerOrderCtrl.getGridTotal(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString('merchandise'), true));
        COHeaderWrapper.GridTotal gridTotals = (COHeaderWrapper.GridTotal) System.JSON.deserialize(gridTotal, COHeaderWrapper.GridTotal.class);
        //system.assertEquals(gridTotals.SalesTaxList[0].TaxValue, 2.20);
        system.assertEquals(gridTotals.Total_Part, 24.20);
    }
    
    
    static testMethod void salesTaxCalculationForNonAustralianMarket() {
        
        TestUtil.createtaxsettingInGeneralConfigA();
        
        //Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        Applicable_Taxes__c applicabletax1 = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem1.Id);
        
        
        Part__c part = TestUtil.createPart(false, 'part', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Applicable_Tax__c = salestax.Id;
        insert part;
        
        
        
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        
        Tax_Exemption__c taxExemption = Testutil.createTaxExemption(true, customer.Id, salestaxItem.Id);
        
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 1);
        
        String coDetailsJSON1 = BPUtility.getDecodedString(CustomerOrderCtrl.getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        COHeaderWrapper coDetails1 = (COHeaderWrapper) System.JSON.deserialize(coDetailsJSON1, COHeaderWrapper.class);
        System.assertEquals( coDetails1.allCOLineItemRecs[0].price, 55);
        
        
        
    }
    
     
 	static testMethod void salesTaxCalculationForAustralianMarketForKit() {
        
        TestUtil.createtaxsettingInGeneralConfig();
        
        //Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        Applicable_Taxes__c applicabletax1 = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem1.Id);
        
        
        Part__c part = TestUtil.createPart(false, 'part', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Applicable_Tax__c = salestax.Id;
        insert part;
        
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Tax_Exemption__c taxExemption = Testutil.createCOTaxExemption(true, coHeader.Id, salestaxItem.Id);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, Part.Id, 1, 5.0);
        test.startTest();
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        test.stopTest();
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj2 );
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].KitPrice, 51.27);
    }
    
          /*
    * Name: addLineItemsTest
     * Desc: Test to add part lineitem for SO 
     * @param: 
     * @return: 
    **/
    
        static testMethod void addLineItemsTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
       
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsList);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].IsPart, true);
    }
    
                           /*
    * Name: addLabourLineItemsTest
     * Desc: Test to add labour lineitem for SO 
     * @param: 
     * @return: 
    **/
    
        static testMethod void addLabourLineItemsTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(labourCode.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj1);
        system.assertEquals(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].IsPart, false);
        system.assertEquals(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].IsLabour, true);
    }
    
                               /*
    * Name: addKitLineItemsTest
     * Desc: Test to add Kit as a lineitem for SO 
     * @param: 
     * @return: 
    **/
    
        static testMethod void addKitLineItemsTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, LabourCode.Id, Part.Id, 1, 5.0);
        
        Test.startTest();
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        Test.stopTest();
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj1);
        system.assertEquals(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].IsPart, true);
        system.assertEquals(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].IsLabour, true);
    }
    
                                   /*
    * Name: removeLineItemsTest
     * Desc: Test to remove lineitem for SO 
     * @param: 
     * @return: 
    **/
    
        static testMethod void removeLineItemsTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        
        removeLineItemsTestAsyncHandle(coHeader.Id, customer.Id, part.Id);
        
    }
    
    @future
	private static void removeLineItemsTestAsyncHandle(String coHeaderId, String customerId, String partId) {
		String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeaderId)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsList);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(partId), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(customerId)));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(lineitems, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj2.SOList[0].SOGridItems[0]);
        String lineItemRemove = BPUtility.getDecodedString(CustomerOrderCtrl.removeLineItems(BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].Id), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id)) );
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj1); 
        system.assertEquals(soHeaderDetailsObj1.SOList[0].SOGridItems.size(), 0);
	}
                                   /*
    * Name: removeKitLineItemsTest
     * Desc: Test to remove kit for SO 
     * @param: 
     * @return: 
    **/
    
        static testMethod void removeKitLineItemsTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, UnitMake.Id, UnitModel.Id, null);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, true, true, KitHeader.Id, 5.0, LabourCode.Id, Part.Id, 1, 5.0);
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsList);
        System.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        Test.startTest();
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeader.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(lineitems, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj2);
        String lineItemRemove = BPUtility.getDecodedString(CustomerOrderCtrl.removeLineItems(BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].SOKitHeaderId), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(soHeaderDetailsObj2.SOList[0].SOHeaderInfo.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj1);
        Test.stopTest();
        system.assertEquals(soHeaderDetailsObj1.SOList[0].SOGridItems.size(), 0);
    }
    
    /*
     static testMethod void salesTaxCalculationForAustralianMarketForServiceOrder() {
        
        TestUtil.createtaxsettingInGeneralConfig();
        
        //Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        Applicable_Taxes__c applicabletax1 = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem1.Id);
        
        
        Part__c part = TestUtil.createPart(false, 'part', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Applicable_Tax__c = salestax.Id;
        insert part;
        
        
        
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        
        Tax_Exemption__c taxExemption = Testutil.createTaxExemption(true, customer.Id, salestaxItem.Id);
        
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 1.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        //CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 1);
        Test.stopTest();
        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].KitPrice, 51.27);
        
        String gridTotal = BPUtility.getDecodedString(CustomerOrderCtrl.getGridTotal(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(null), true));
        COHeaderWrapper.GridTotal gridTotals = (COHeaderWrapper.GridTotal) System.JSON.deserialize(gridTotal, COHeaderWrapper.GridTotal.class);
        //system.assertEquals(gridTotals.SalesTaxList[0].TaxValue, 4.66);
        system.assertEquals(gridTotals.Total_Part, 51.27);
        
        
    }*/
    
    
     static testMethod void salesTaxCalculationForAustralianMarketOnLabour() {
        
        TestUtil.createtaxsettingInGeneralConfigA();
        
        //Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
        defaultPriceLevel.Labour_Rate__c = 60 ;
        Insert defaultPriceLevel;
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        Applicable_Taxes__c applicabletax1 = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem1.Id);
        
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Labour_Code__c labourCode = TestUtil.createLabourCode(false, true, testCategory.Id, 'Code', null, 'Description', true, 2, 'LabourCodeName', 50, true);
        labourCode.Applicable_Tax__c = salestax.Id;
        insert labourCode;
        Tax_Exemption__c taxExemption = Testutil.createTaxExemption(true, customer.Id, salestaxItem.Id);
        
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(labourCode.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 2.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        //CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 1);
        Test.stopTest();
        
        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj2);
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].KitPrice, 50);
    }
    
static testMethod void salesTaxCalculationForAustralianMarketOnFee() {
        
        TestUtil.createtaxsettingInGeneralConfigA();
        
        //Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        Applicable_Taxes__c applicabletax1 = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem1.Id);
        
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Fee__c fee = TestUtil.createFee(False, True, testCategory.Id, 'FeeCode', null, 'Description', 50, false);
        fee.Applicable_Tax__c = salestax.Id;
        insert fee;
        
        
        
        
        
        Tax_Exemption__c taxExemption = Testutil.createTaxExemption(true, customer.Id, salestaxItem.Id);
        
        
         String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(fee.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        Test.startTest();
        salesTaxCalculationForAustralianMarketOnFeeAsyncHandling(coHeader.Id);
        Test.stopTest();
        
       // String InsertFeeInMerchDetails = CustomerOrderCtrl.insertFeeInMerchGrid( fee.Id, coHeader.Id);
    }
    
    @future
	private static void salesTaxCalculationForAustralianMarketOnFeeAsyncHandling(String coHeaderId) {
		String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 1.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
		String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeaderId)));
        //CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 1);
        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
       // system.assert(false, soHeaderDetailsObj2);
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].KitPrice, 50);
	}
    

static testMethod void salesTaxCalculationForAustralianMarketForServiceOrderThirdParty() {
        
        TestUtil.createtaxsettingInGeneralConfig();
        
        //Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Claims_for_Service_Work__c = true;
        insert vendor;
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        Applicable_Taxes__c applicabletax1 = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem1.Id);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        //Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Third-Party', 'Third-Party');
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Third-Party', 'Third-Party');
        //transactionType.Third_Party_Customer__c = customer.Id;
        insert transactionType ;
        Part__c part = TestUtil.createPart(false, 'part', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Applicable_Tax__c = salestax.Id;
        insert part;
        
        
        
        //Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        
        Tax_Exemption__c taxExemption = Testutil.createTaxExemption(true, customer.Id, salestaxItem.Id);
        
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        soHeaderDetailsObj.SOList[0].SOHeaderInfo.TransactionTypeId = transactionType.Id ;
        soHeaderDetailsObj.SOList[0].SOHeaderInfo.ProviderId = vendor.Id;
        String jsonStr = System.Json.serialize(soHeaderDetailsObj.SOList[0].SOHeaderInfo);
        
        String soHeaderInfo = BPUtility.getDecodedString(CustomerOrderCtrl.saveSOHeaderInfo(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(jsonStr)));
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        Test.startTest();
        salesTaxCalculationForAustralianMarketForServiceOrderThirdPartyAsyncHandling(coHeader.Id);
        Test.stopTest();
        
        
    }
    
    @future
	private static void salesTaxCalculationForAustralianMarketForServiceOrderThirdPartyAsyncHandling(String coHeaderId) {
		String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
		SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 1.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
		String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeaderId)));
        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj3 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj3.SOList[0].SOGridItems[0].SOKH.SOLIList[0].KitPrice, 55);
	}
    
    static testMethod void salesTaxCalculationForAustralianMarketOnLabourNonFixed() {
        
        TestUtil.createtaxsettingInGeneralConfigA();
        
        //Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
        defaultPriceLevel.Labour_Rate__c = 60 ;
        Insert defaultPriceLevel;
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        Applicable_Taxes__c applicabletax1 = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem1.Id);
        
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Labour_Code__c labourCode = TestUtil.createLabourCode(false, true, testCategory.Id, 'Code', null, 'Description', false, 2, 'LabourCodeName', 50, true);
        labourCode.Applicable_Tax__c = salestax.Id;
        insert labourCode;
        Tax_Exemption__c taxExemption = Testutil.createTaxExemption(true, customer.Id, salestaxItem.Id);
        
        
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Name, 'Service Job 1');
        
        String lineitems = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(labourCode.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(customer.Id)));
        
        String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0].QtyNeeded = 2.00 ;
        //system.assert(false, soHeaderDetailsObj1 );
        
        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
        COLineItemTriggerHelper.isTriggerExecute = false;
        COTriggerHelper.isTriggerExecute = false;
        
        Test.startTest();
        String updatedSOLI = BPUtility.getDecodedString(CustomerOrderCtrl.updateSOLineItems(BPUtility.getEncodedString(System.JSON.serialize(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList[0])), BPUtility.getEncodedString(coHeader.Id)));
        //CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 1);
        Test.stopTest();
        
        String SOHeaderDetails2 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj2 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails2, SOHeaderWrapper.class);
        //system.assert(false, soHeaderDetailsObj2);
        system.assertEquals(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].KitPrice, 60);
       //system.assertEquals(soHeaderDetailsObj2.SOList[0].SOGridItems[0].SOKH.SOLIList[0].KitPrice, 50.00);
    
    }
    /* ADDED BY NIDHI */    
    static testMethod void testGetDealDetails() {
        
        TestUtil.createtaxsettingInGeneralConfigA();
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        CO_Header__c co = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c = 'Unit Deal', Customer__c=customer.Id);
        insert co;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(co.Id));
        String dealJson = BPUtility.getDecodedString(CustomerOrderCtrl.getDealDetails(BPUtility.getEncodedString(co.Id), null));
        DealWrapper dealWrapperObj = DealWrapper.parse(dealJson);
        System.assertEquals('Quotation', dealWrapperObj.DealInfo.DealStatus);
    }
    
    static testMethod void saveTemporaryUnitTest() {
        
        TestUtil.createtaxsettingInGeneralConfigA();
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        CO_Header__c co = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert co;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(co.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :co.Id];
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        Test.startTest();
        String dealItemJson = BPUtility.getDecodedString(CustomerOrderCtrl.saveTemporaryUnit(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItemJsonToSave)));
        List<Deal_Item__c> dealItems = [Select Id from Deal_Item__c]; 
        Test.stopTest();
        System.assertEquals(2, dealItems.size());
        dealItemObj = DealItem.parse(dealItemJson);
    }
    
    static testMethod void saveDealInfoDetailsTest() {
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        String statusToUpdate = 'In Progress';
        CO_Header__c co = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert co;
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(co.Id));
        List<Deal__c> dealList = [Select id, Status__c, CO_Header__c from Deal__c where CO_Header__c = :co.Id];
        System.assertEquals('Quotation', dealList[0].Status__c);
        dealList[0].Status__c = statusToUpdate;
        DealWrapper.DealInfoWrapper dealInfoObj = new DealWrapper.DealInfoWrapper(dealList[0]);
        Test.startTest();
        String dealInfoJson = BPUtility.getDecodedString(CustomerOrderCtrl.saveDealInfoDetails(null,BPUtility.getEncodedString(dealList[0].Id), BPUtility.getEncodedString(System.JSON.serialize(dealInfoObj))));
        dealInfoObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(dealInfoJson, DealWrapper.DealInfoWrapper.class);
        Test.stopTest();
        System.assertEquals(statusToUpdate, dealInfoObj.DealStatus);
    }
    
    public class VendorPaginationSorting {
        public Integer ChangesCount;
        public Integer CurrentPage;
        public Integer PageSize;
        public List<SortAttrs> Sorting;
    }
    
    public class SortAttrs {
        public String FieldName;
        public String SortDirection;
        public SortAttrs(String FieldName, String SortDirection){
            this.FieldName = FieldName;
            this.SortDirection = SortDirection;
        }
    }
}