/**
 * Author: Gourav goyal
 * Since: July 25, 2017
 * Name: SoPaymentRoleTriggerHelper test
 * Description: Controller test Class of SOPayment trigger.
**/
@isTest
private class SOPaymentRoleTriggerHelperTest {
    /**
     * Name: createSOPaymentRoleTest
     * Desc: Test to create SO PaymentRole
     * @param: 
     * @return: 
    **/
    static testMethod void createSOPaymentRoleTest() {
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
        String deductible =  BPUtility.getDecodedString(CustomerOrderCtrl.addDeductibleAmount(BPUtility.getEncodedString('{"SoHeaderId":"'+soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id+'","DeductibleStatus":null,"DeductibleId":null,"DeductibleAmount":"10","CoHeaderId":"'+coHeader.Id+'"}')));
        SOHeaderWrapper details12 = (SOHeaderWrapper) System.JSON.deserialize(deductible, SOHeaderWrapper.class);
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
    
     /**
     * Name: deleteSOPaymentRoleTest
     * Desc: Test to create SO PaymentRole
     * @param: 
     * @return: 
    **/
    static testMethod void deleteSOPaymentRoleTest() {
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
        String deductible =  BPUtility.getDecodedString(CustomerOrderCtrl.addDeductibleAmount(BPUtility.getEncodedString('{"SoHeaderId":"'+soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id+'","DeductibleStatus":null,"DeductibleId":null,"DeductibleAmount":"10","CoHeaderId":"'+coHeader.Id+'"}')));
        SOHeaderWrapper details12 = (SOHeaderWrapper) System.JSON.deserialize(deductible, SOHeaderWrapper.class);
        String submittedClaim = BPUtility.getDecodedString(CustomerOrderCtrl.submitClaimRecords(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
        String claimedRecord = BPUtility.getDecodedString(CustomerOrderCtrl.getClaimRecById(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
        ClaimWizard claimWizardDetails = (ClaimWizard) System.JSON.deserialize(claimedRecord, ClaimWizard.class);
        System.JSON.serialize(claimWizardDetails);
        String  claimResponse1 = BPUtility.getDecodedString(CustomerOrderCtrl.saveClaimResponse(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id),BPUtility.getEncodedString( System.JSON.serialize(claimWizardDetails)),'3'));
        ClaimWizard claimWizardDetails2 = (ClaimWizard) System.JSON.deserialize(claimResponse1, ClaimWizard.class);
        claimWizardDetails2.NonVarianceLineItemList[0].PaymentStatus = 'Owing';
        
       	String SOPaymentRole = BPUtility.getDecodedString(CustomerOrderCtrl.getSoPaymentRoleById(BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id)));
       	List<SOPaymentWrapper> paymentRoleDetails = (List<SOPaymentWrapper>) System.JSON.deserialize(SOPaymentRole, List<SOPaymentWrapper>.class);
       	List<SO_Payment_Role__c> soPaymentList  = [select Claim__c, Deductible_Status__c, Qty__c, Status__c, Tax_Amount__c, Total_Amount__c, Variance__c, recordtype.developername from SO_Payment_Role__c];
       	delete soPaymentList;
       	Test.stoptest();
       	List<SO_Payment_Role__c> soPaymentListDeleted  = [select Claim__c, Deductible_Status__c, Qty__c, Status__c, Tax_Amount__c, Total_Amount__c, Variance__c, recordtype.developername from SO_Payment_Role__c];
       
       	system.assertEquals(soPaymentList[0].Total_Amount__c, 10);
       	system.assertEquals(claimWizardDetails2.DeductibleAmount, 10 );
       	system.assertEquals(soPaymentListDeleted.size(), 0);
    }
    
    /**
     * Name: deleteSOPaymentRolewithInvoiceTest
     * Desc: Test to create SO PaymentRole
     * @param: 
     * @return: 
    **/
    static testMethod void populateCOHeaderIdToActiveCOInvoiceHeaderIdMapTest() {
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
        CO_Invoice_Header__c coObj = [select id,Invoice_Status__c from CO_Invoice_Header__c where Invoice_Status__c='Active' and CO_Header__c =: coHeader.id ];
        coObj.Invoice_Status__c = 'Closed';
        update coObj;
        List<ID>coHeaderId = new List<ID>();
        coHeaderId.add(coHeader.id);  
        
        Test.startTest();
       	SOPaymentRoleTriggerHelper.populateCOHeaderIdToActiveCOInvoiceHeaderIdMap(coHeaderId);
        Test.stoptest();
        system.assert(true,true);
    }
}