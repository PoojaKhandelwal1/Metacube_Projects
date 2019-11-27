@isTest
private class CashReconciliationCtrlTest {

    /*static testMethod void getReconciliationListTest() {
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader1.Id, 'Active');
        CO_Invoice_Payment__c coinvoicepayment1  = TestUtil.createCOInvoicePayment(true, coinvoiceHeader1.Id );
        coinvoicepayment1.Payment_Method__c = 'Cash';
        coinvoicepayment1.Amount__c = 100;
        update coinvoicepayment1;
        
        CO_Invoice_Payment__c coinvoicepayment2  = TestUtil.createCOInvoicePayment(true, coinvoiceHeader1.Id );
        coinvoicepayment2.Payment_Method__c = 'Store Credit';
        coinvoicepayment2.Amount__c = -100;
        update coinvoicepayment2;
        
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(true, coHeader1.Id, 'Debit', 500);
        
        Date todayDate = system.today();
        String reconciledDateStr =  todayDate.format() ;
        reconciledDateStr = BPUtility.getEncodedString(reconciledDateStr);
        String reconciliationList = CashReconciliationCtrl.getReconciliationList(reconciledDateStr, null);
        //reconciliationList = BPUtility.getDecodedString(reconciliationList);
        String reconciliationListAfterSave = CashReconciliationCtrl.saveReconciliation(reconciliationList);
        reconciliationListAfterSave = BPUtility.getDecodedString(reconciliationListAfterSave);
        ReconciliationWrapper reconciliationWrapperObj = (ReconciliationWrapper) json.deserialize(reconciliationListAfterSave, ReconciliationWrapper.class);
        
        ReconciliationWrapper.ReconciliationPayment debitReconciliationPaymentRec;
        for(ReconciliationWrapper.ReconciliationPayment reconciliationPaymentRec : reconciliationWrapperObj.CashReconciliationPaymentList) {
            if(reconciliationPaymentRec.PaymentMethod == 'Debit')
            {
                debitReconciliationPaymentRec = reconciliationPaymentRec;
            }
        }
        System.assertEquals(coDeposit.Amount__c,debitReconciliationPaymentRec.PaymentDetailList[0].Amount);
        
        String StartDateStr = system.today().format();
        String EndDateStr = system.today().addDays(30).format();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('StartDate', StartDateStr);
        gen.writeStringField('EndDate', EndDateStr);
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        
        String getMinicalenderDataStr = BPUtility.getDecodedString(CashReconciliationCtrl.getMiniCalenderDataByDrawerId(BPUtility.getEncodedString(jsonString), BPUtility.getEncodedString(null)));
        List<ReconciliationWrapper.ReconciliationInfo> ReconciliationInfoObj = (List<ReconciliationWrapper.ReconciliationInfo>) json.deserialize(getMinicalenderDataStr, List<ReconciliationWrapper.ReconciliationInfo>.class);
        //System.assert(false,ReconciliationInfoObj);
        system.assertEquals(StartDateStr,ReconciliationInfoObj[0].ReconciliationDate);
        
    }*/
    
    static testMethod void getReconciliationDrawerDetailViewTest() {
        List<Cash_Drawer__c> cashDrawerList = TestUtil.createCashDrawer(1, true);
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader1.Id, 'Active');
        
        CO_Invoice_Payment__c coinvoicepayment1  = TestUtil.createCOInvoicePayment(true, coinvoiceHeader1.Id );
        coinvoicepayment1.Payment_Method__c = 'Cash';
        coinvoicepayment1.Amount__c = 100;
        coinvoicepayment1.Cash_Drawer__c = cashDrawerList[0].Id;
        update coinvoicepayment1;
                
        String reconciledDateStr =  '1/12/2018';
        String reconciliationRecJson = CashReconciliationCtrl.getCashDrawerReconciliationByDrawerId(BPUtility.getEncodedString(reconciledDateStr), BPUtility.getEncodedString(cashDrawerList[0].Id));
        reconciliationRecJson = BPUtility.getDecodedString(reconciliationRecJson);
        ReconciliationWrapper reconciliationObj = (ReconciliationWrapper) json.deserialize(reconciliationRecJson, ReconciliationWrapper.class);
        system.assert(reconciliationObj.CashDrawerReconcilationObjList[0].DrawerId != null);
        
        reconciliationObj.CashDrawerReconcilationObjList[0].Status = 'Submitted';
        CashReconciliationCtrl.saveReconciliation(BPUtility.getEncodedString(system.JSON.serialize(reconciliationObj)), null);
        
        String reconciliationRecJson1 = CashReconciliationCtrl.getCashDrawerReconciliationByDrawerId(BPUtility.getEncodedString(reconciledDateStr), BPUtility.getEncodedString(cashDrawerList[0].Id));
        reconciliationRecJson1 = BPUtility.getDecodedString(reconciliationRecJson1);
        ReconciliationWrapper reconciliationObj1 = (ReconciliationWrapper) json.deserialize(reconciliationRecJson1, ReconciliationWrapper.class);
        system.assertEquals(reconciliationObj1.CashDrawerReconcilationObjList[0].Status, 'Submitted');
        
        String StartDateStr = '1/12/2018';
        String EndDateStr = '31/12/2018';
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('StartDate', StartDateStr);
        gen.writeStringField('EndDate', EndDateStr);
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        String response = CashReconciliationCtrl.getMiniCalenderDataByDrawerId(BPUtility.getEncodedString(jsonString), BPUtility.getEncodedString(null));
        String getMinicalenderDataStr = BPUtility.getDecodedString(response);
        List<ReconciliationWrapper.ReconciliationInfo> ReconciliationInfoObj = (List<ReconciliationWrapper.ReconciliationInfo>) json.deserialize(getMinicalenderDataStr, List<ReconciliationWrapper.ReconciliationInfo>.class);
        //system.assertEquals(StartDateStr, ReconciliationInfoObj[0].ReconciliationDate);
    }
    
    static testMethod void getReconciliationMultiDrawerViewTest() {
        List<Cash_Drawer__c> cashDrawerList = TestUtil.createCashDrawer(2, true);
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader1.Id, 'Active');
        
        CO_Invoice_Payment__c coinvoicepayment1  = TestUtil.createCOInvoicePayment(true, coinvoiceHeader1.Id );
        coinvoicepayment1.Payment_Method__c = 'Cash';
        coinvoicepayment1.Amount__c = 100;
        coinvoicepayment1.Cash_Drawer__c = cashDrawerList[0].Id;
        update coinvoicepayment1;
                
        CO_Invoice_Payment__c coinvoicepayment2  = TestUtil.createCOInvoicePayment(true, coinvoiceHeader1.Id );
        coinvoicepayment2.Payment_Method__c = 'Store Credit';
        coinvoicepayment2.Amount__c = -100;
        coinvoicepayment1.Cash_Drawer__c = cashDrawerList[1].Id;
        update coinvoicepayment2;
            
        Date todayDate = system.today();
        String reconciledDateStr =  todayDate.format();
        String reconciliationRecJson = CashReconciliationCtrl.getReconciliationList(BPUtility.getEncodedString(reconciledDateStr), BPUtility.getEncodedString('Drawer'));
        reconciliationRecJson = BPUtility.getDecodedString(reconciliationRecJson);
        ReconciliationWrapper reconciliationObj = (ReconciliationWrapper) json.deserialize(reconciliationRecJson, ReconciliationWrapper.class);
        system.assertEquals(reconciliationObj.ReconciliationInfo.Status,'Unreconciled');
        
        /*reconciliationObj.ReconciliationInfo.Status = 'Reconciled';
        CashReconciliationCtrl.saveReconciliation(BPUtility.getEncodedString(system.JSON.serialize(reconciliationObj)), null);
        
        String reconciliationRecJson1 = CashReconciliationCtrl.getReconciliationList(BPUtility.getEncodedString(reconciledDateStr), BPUtility.getEncodedString('Drawer'));
        reconciliationRecJson1 = BPUtility.getDecodedString(reconciliationRecJson1);
        ReconciliationWrapper reconciliationObj1 = (ReconciliationWrapper) json.deserialize(reconciliationRecJson1, ReconciliationWrapper.class);
        system.assert(false, reconciliationObj1);
        system.assertEquals(reconciliationObj1.ReconciliationInfo.Status, 'Reconciled');
        system.assertEquals(reconciliationObj1.CashDrawerReconcilationObjList[0].Status, 'Reconciled');*/
        //system.assert(false, reconciliationObj1);
        
    }
    
    static testmethod void getTransactionTypeDetailsTest() {
        List<Cash_Drawer__c> cashDrawerList = TestUtil.createCashDrawer(2, true);
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader1.Id, 'Active');
        CO_Invoice_Payment__c coinvoicepayment1  = TestUtil.createCOInvoicePayment(true, coinvoiceHeader1.Id );
        coinvoicepayment1.Payment_Method__c = 'Cash';
        coinvoicepayment1.Amount__c = 100;
        coinvoicepayment1.Cash_Drawer__c = cashDrawerList[0].Id;
        update coinvoicepayment1;
        
        CO_Invoice_Payment__c coinvoicepayment2  = TestUtil.createCOInvoicePayment(true, coinvoiceHeader1.Id );
        coinvoicepayment2.Payment_Method__c = 'Store Credit';
        coinvoicepayment2.Amount__c = -100;
        coinvoicepayment2.Cash_Drawer__c = cashDrawerList[1].Id;
        update coinvoicepayment2;
            
        CO_Deposit__c coDeposit = TestUtil.createCODeposit(false, coHeader1.Id, 'Debit', 500);
        coDeposit.Cash_Drawer__c = cashDrawerList[0].Id;
        insert coDeposit;
        
        Date todayDate = system.today();
        String reconciledDateStr =  todayDate.format();
        reconciledDateStr = BPUtility.getEncodedString(reconciledDateStr);
        String viewName = BPUtility.getEncodedString('Transaction Type');
        String transactionTypeListJson = BPUtility.getDecodedString(CashReconciliationCtrl.getReconciliationList(reconciledDateStr, viewName));
        List<CashReconciliationTTWrapper> transactionTypeList = (List<CashReconciliationTTWrapper>)System.JSON.deserialize(transactionTypeListJson, List<CashReconciliationTTWrapper>.class);
        system.assertEquals(transactionTypeList.size(), 13);
        
        for(CashReconciliationTTWrapper ttRec: transactionTypeList) {
            system.assertEquals(ttRec.CashDrawerDetailObjList.size(), 2);
            if(ttRec.PaymentMethod == 'Cash') {
                system.assertEquals(ttRec.TotalProcessedAmount, 100);
            }
            if(ttRec.PaymentMethod == 'Debit') {
                system.assertEquals(ttRec.TotalProcessedAmount, 500);
            }
        }
    }
}