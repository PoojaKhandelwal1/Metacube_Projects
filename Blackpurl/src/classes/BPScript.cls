/**
 * Author: Nidhi Sharma
 * Since: July 27, 2018
 * Name: BPScript
 * Description: Apex class to run script required for particular sprint
**/
global class BPScript {
    
    global static void runScript_Sprint69() {
        BPScriptUtility.updateUnitPricesAndCostsForInvoiceDeal();
    }
    
    global static void runScript_Sprint70() {
        BPScriptUtility.populateRetailPriceOnKitLineItems();
    }
    
    global static void runScript_Sprint71() {
        BPScriptUtility.upsertTransactionTypes();
        BPScriptUtility.updateUnitInvServiceJobTransactionType();
    }
    
    global static void runScript_Sprint72() {
        SetQtyAndAvgCostOnFIFOBktAndLIBatch updateFIFOBatchObj = new SetQtyAndAvgCostOnFIFOBktAndLIBatch();
        Database.executeBatch(updateFIFOBatchObj, 200);
        if(GeneralConfiguration.getTaxIncludingPricing()) {
            BPScriptUtility.updateTradeInActualCashValueForAusOn();
        } else {
            BPScriptUtility.updateTradeInActualCashValue();
        }
        BPScriptUtility.updateSubletSoliAndCreateVoliForOpenCO();
        BPScriptUtility.updateTaxAndTotalForDealWithTradeIn();
        BPScriptUtility.deleteNonDefaultSpecialCategories();
        BPScriptUtility.createDefaultSpecialCategories();
    }
    
    global static void runScript_Sprint73() {
        BPScriptUtility.populateSOHeaderOnExistingAppointments();
        BPScriptUtility.populateDefaultTTypeOnExistingAppointmentsAndSOUsingJobType();
        BPScriptUtility.populatePurchaseTaxOnVendorInvoice();
        BPScriptUtility.resetVINField();
        BPScriptUtility.setCOInvoiceJEFlagForInvoicedDeals();
        QBScriptUtil.syncJournalEntryForInvoices(25, 60, 25);
    }
    
    global static void runScript_Sprint75() {
    	BPScriptUtility.insertDefaultAccountTypes();
    	BPScriptUtility.populateTaxFieldsOnDealItem();
    	BPScriptUtility.populateIndividualTaxesOnVendorInvoices();
    	BPScriptUtility.executeAccountTypeBatch();
    	BPScriptUtility.createUniqueMakeModelSubmodel();
    	BPScriptUtility.populateTaxExemptions();
    }
    
    global static void runScript_Sprint76() {
        BPScriptUtility.changesStatusOfInvoicedVRs();
    }
    
    global static void runScript_Sprint79() {
        BPScriptUtility.populateCashDrawerReconciliationForExistingCashReconciliationRec();
    }
    
    global static void runScript_Sprint82() {
        BPScriptUtility.deleteDuplicateCashReconciliationPaymentRecords();//Pooja 
    }
    
    global static void runScript_Sprint85() {
        BPScriptUtility.setOrderLotsWhenIsOrderLotFlagDisabled();
    }
    
    global static void populateClosedDateOnInvoice() {
        BPScriptUtility.populateClosedDateOnInvoice();
    }
}