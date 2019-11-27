/**
 * Author: Tarun Khandelwal
 * Since: May 21, 2018
 * Name: QBScriptUtil
 * Description: Apex class for all scripts related to QB
**/
global class QBScriptUtil {
    
    global static void syncCustomers(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<Account> customerList = [Select Id from Account where Is_Customer__c = true AND availForQBSync__c = true
                                            Order by CreatedDate DESC];
                                            
        scheduleJobs(customerList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'Customer');
    }
    
    private static void scheduleJobs(List<sObject> recordList, Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize,
                                            String entityType) {
        for(Integer i = 0; i < Math.ceil(recordList.size() / Decimal.valueOf(maxNumberOfRecord)) && i < 99; i++) {
            String cronExp = QBUtil.getCronExpForGivenTime(10 + (i * timeIntervalForJobsInSec));
            
            Set<Id> recordIdSet = new Set<Id>();
            for(Integer j = (i * maxNumberOfRecord); (j < ((i + 1) * maxNumberOfRecord) && j < recordList.size()); j++) {
                recordIdSet.add(recordList[j].Id);
            }
            system.debug('Record Id Set for Scheduling ' + (i + 1) + '  ' + recordIdSet);
            
            if(entityType == 'Customer') {
                QBUtil.abortAlreadyScheduleJobs('Customer Sync ' + i);
                system.schedule('Customer Sync ' + i, cronExp, new AccSync_Customer_Batch_Scheduler(recordIdSet, batchSize));
            } else if(entityType == 'Vendor') {
                QBUtil.abortAlreadyScheduleJobs('Vendor Sync ' + i);
                system.schedule('Vendor Sync ' + i, cronExp, new AccSync_Vendor_Batch_Scheduler(recordIdSet, batchSize));
            } else if(entityType == 'Customer Invoice') {
                QBUtil.abortAlreadyScheduleJobs('Customer Invoice Sync ' + i);
                system.schedule('Customer Invoice Sync ' + i, cronExp, new AccSync_CustomerInvoice_Batch_Scheduler(recordIdSet, batchSize));
            } else if(entityType == 'Customer Invoice Journal Entry') {
                QBUtil.abortAlreadyScheduleJobs('Customer Invoice Journal Sync ' + i);
                system.schedule('Customer Invoice Journal Sync ' + i, cronExp, new AccSync_COInvoiceJournalEntry_Batch_Sch(recordIdSet, batchSize));    
            } else if(entityType == 'Vendor Invoice') {
                QBUtil.abortAlreadyScheduleJobs('Vendor Invoice Sync ' + i);
                system.schedule('Vendor Invoice Sync ' + i, cronExp, new AccSync_VendorInvoice_Batch_Scheduler(recordIdSet, batchSize));     
            } else if(entityType == 'Unit') {
                QBUtil.abortAlreadyScheduleJobs('Unit Sync ' + i);
                system.schedule('Unit Sync ' + i, cronExp, new AccSync_Unit_Batch_Scheduler(recordIdSet, batchSize));     
            } else if(entityType == 'Customer Deposit') {
                QBUtil.abortAlreadyScheduleJobs('Customer Deposit Sync ' + i);
                system.schedule('Customer Deposit Sync ' + i, cronExp, new AccSync_CODepositJE_Batch_Scheduler(recordIdSet, batchSize));     
            } else if(entityType == 'Unit Price and Cost') {
                QBUtil.abortAlreadyScheduleJobs('Unit Price and Cost Sync ' + i);
                system.schedule('Unit Price and Cost Sync ' + i, cronExp, new AccSync_UnitPriceAndCost_Batch_Scheduler(recordIdSet, batchSize));     
            } else if(entityType == 'Store Credit') {
                QBUtil.abortAlreadyScheduleJobs('Store Credit Sync ' + i);
                system.schedule('Store Credit Sync ' + i, cronExp, new AccSync_StoreCreditJE_Batch_Scheduler(recordIdSet, batchSize));     
            } else if(entityType == 'Vendor Return') {
                QBUtil.abortAlreadyScheduleJobs('Vendor Return Sync ' + i);
                system.schedule('Vendor Return Sync ' + i, cronExp, new AccSync_VendorReturn_Batch_Scheduler(recordIdSet, batchSize));     
            } else if(entityType == 'Payment Journal Entry') {
                QBUtil.abortAlreadyScheduleJobs('Payment Journal Entry Sync ' + i);
                system.schedule('Payment Journal Entry Sync ' + i, cronExp, new AccSync_COInvoicePayment_Batch_Scheduler(recordIdSet, batchSize));     
            } else if(entityType == 'FIFO Buckets') {
                QBUtil.abortAlreadyScheduleJobs('FIFO Buckets Sync ' + i);
                system.schedule('FIFO Buckets Sync ' + i, cronExp, new AccSync_FIFOBucket_Batch_Scheduler(recordIdSet, batchSize));  
            } else if(entityType == 'FIFO Buckets Line Items') {
                QBUtil.abortAlreadyScheduleJobs('FIFO Buckets Line Items Sync ' + i);
                system.schedule('FIFO Buckets Line Items Sync ' + i, cronExp, new AccSync_FIFOBucActivitLI_Batch_Scheduler(recordIdSet, batchSize));  
            } else if(entityType == 'VR JE') {
                QBUtil.abortAlreadyScheduleJobs('VR JE Sync ' + i);
                system.schedule('VR JE Sync ' + i, cronExp, new AccSync_VORJournalEntry_Batch_Scheduler(recordIdSet, batchSize)); 
            }
        }
    }
    
    global static void syncVendors(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<Account> vendorList = [Select Id from Account where Is_Vendor__c = true AND Vendor_AvailForQBSync__c = true 
                                            Order by CreatedDate ASC];
                                            
        scheduleJobs(vendorList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'Vendor');
    }
    
    global static void syncCategory() {
        List<Category__c> categoryList = [Select availForQBSync__c from Category__c limit :SOQLUtil.getAvailableQueryRowsLimit()];
        for(Category__c categoryRec : categoryList) {
            categoryRec.availForQBSync__c = true;
        }
        update categoryList;
    }
    
    global static void syncInvoices(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<CO_Invoice_Header__c> customerInvoiceList = 
                        [Select Id from CO_Invoice_Header__c where availForQBSync__c = true 
                            Order by CreatedDate ASC];
                                            
        scheduleJobs(customerInvoiceList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'Customer Invoice');
    }
    
    global static void syncJournalEntryForInvoices(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<CO_Invoice_Header__c> customerInvoiceList = 
                        [Select Id from CO_Invoice_Header__c where availForQBJournalEntrySync__c = true 
                            Order by CreatedDate ASC];
                                            
        scheduleJobs(customerInvoiceList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'Customer Invoice Journal Entry');
    }
    
    global static void syncVendorInvoices(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<Vendor_Invoicing_Header__c> vendorInvoiceList = 
                        [Select Id from Vendor_Invoicing_Header__c where Status__c = 'Invoiced' AND availForQBSync__c = true 
                            Order by CreatedDate ASC];
                                            
        scheduleJobs(vendorInvoiceList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'Vendor Invoice');
    }
    
    global static void syncUnits(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<Customer_Owned_Unit__c> unitList = [Select Id from Customer_Owned_Unit__c where availForQBSync__c = true AND Unit_Type__c = 'STOCK'
                            AND Referenced_Unit__r.Status__c = 'Received' Order by CreatedDate ASC];
                                            
        scheduleJobs(unitList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'Unit');
    }
    
    global static void syncVendorReturn(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<Return_VO_Header__c> vendorReturnList = [Select Id from Return_VO_Header__c where availForQBSync__c = true AND Status__c = 'Credited'
                                                        Order by CreatedDate ASC];
                                            
        scheduleJobs(vendorReturnList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'Vendor Return');
    }
    
    // JOURNAL ENTRIES
    global static void syncDeposits(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<CO_Deposit__c> depositList = [Select Id from CO_Deposit__c where availForQBJournalEntrySync__c = true 
                                                    Order by CreatedDate ASC];
                                            
        scheduleJobs(depositList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'Customer Deposit');
    }
    
    global static void syncUnitPriceAndCost(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<Unit_Price_Cost__c> unitPriceCostList = 
            [Select Id from Unit_Price_Cost__c where availForQBSync__c = true AND Customer_Owned_Unit__c != null 
                AND Customer_Owned_Unit__r.Unit_Type__c = 'STOCK' AND Ref_No__c Like 'UA-%' AND Total_Cost__c != null AND Total_Cost__c != 0 
                AND Type__c != 'Dealer' Order by CreatedDate ASC];
                                            
        scheduleJobs(unitPriceCostList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'Unit Price and Cost');
    }
    
    global static void syncStoreCredits(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<Store_Credit__c> storeCreditList = [Select Id from Store_Credit__c where availForQBSync__c = true
                                                    Order by CreatedDate ASC];
                                            
        scheduleJobs(storeCreditList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'Store Credit');
    }
    
    global static void syncCOInvoicePayments(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<CO_Invoice_Payment__c> invoicePaymentList = 
                [Select Id from CO_Invoice_Payment__c where availForQBJournalEntrySync__c = true
                               Order by CreatedDate ASC];
                                            
        scheduleJobs(invoicePaymentList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'Payment Journal Entry');
    }
    
    global static void syncFIFOBuckets(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<Part_FIFO_Bucket__c> FIFOBucketsList = 
            [Select Id from Part_FIFO_Bucket__c where availForQBSync__c = true AND Is_FIFO_Bucket__c = true AND Vendor_Receiving_Header__c = null 
                    AND Customer_Return__c = null AND Source_Name__c != 'Part Created' AND Source_Name__c != 'Oversold'
                    Order by CreatedDate ASC];
                                            
        scheduleJobs(FIFOBucketsList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'FIFO Buckets');
    }
    
    global static void syncFIFOBucketLineItems(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<Part_FIFO_Bucket_Activity_Line_Item__c> FIFOBucketLineItemsList = 
            [Select Id from Part_FIFO_Bucket_Activity_Line_Item__c where availForQBSync__c = true AND Part_FIFO_Bucket__r.Is_FIFO_Bucket__c = true 
                    AND CO_Invoice_Header__c = null Order by CreatedDate ASC];
                                            
        scheduleJobs(FIFOBucketLineItemsList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'FIFO Buckets Line Items');
    }
    
    global static void syncVRJE(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<Vendor_Receiving_Header__c> vrhList = 
            [Select Id from Vendor_Receiving_Header__c where availForQBJournalEntrySync__c = true AND (Status__c = 'Stocked' OR Status__c = 'Invoiced')
                    Order by CreatedDate ASC];
                                            
        scheduleJobs(vrhList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'VR JE');
    }
    
    // Start: Reset Older records sync flag
    global static void resetSyncFlagForCOInvoiceNotPostedToQB() {
        disbaleTrigger('COInvoiceTrigger');
        List<CO_Invoice_Header__c> coInvoiceList = 
            [Select Id from CO_Invoice_Header__c where availForQBSync__c = true AND (Invoice_Status__c !=: QBUtil.CLOSED OR (Invoice_Status__c =: QBUtil.CLOSED 
                    AND (Checkout_Type__c =: QBUtil.INTERNAL OR Checkout_Type__c =: QBUtil.DEAL))) Order by CreatedDate ASC];
                    
        for(CO_Invoice_Header__c coInvoiceRec : coInvoiceList) {
            coInvoiceRec.availForQBSync__c = false;
        }
        update coInvoiceList;
        enableTrigger('COInvoiceTrigger');
    }
    
    global static void resetSyncFlagForCOInvoiceJENotPostedToQB() {
        disbaleTrigger('COInvoiceTrigger');
        List<CO_Invoice_Header__c> coInvoiceList = 
            [Select Id from CO_Invoice_Header__c where availForQBJournalEntrySync__c = true AND Invoice_Status__c !=: QBUtil.CLOSED Order by CreatedDate ASC];
                    
        for(CO_Invoice_Header__c coInvoiceRec : coInvoiceList) {
            coInvoiceRec.availForQBJournalEntrySync__c = false;
        }
        update coInvoiceList;
        enableTrigger('COInvoiceTrigger');
    }
    
    global static void setSyncFlagForCOInvoicePaymentPostedToQB() { // as new flag is created
        disbaleTrigger('COInvoiceTrigger');
        List<CO_Invoice_Header__c> coInvoiceList = 
            [Select Id from CO_Invoice_Header__c where availForQBSync__c = true AND Invoice_Status__c =: QBUtil.CLOSED 
                    AND Checkout_Type__c !=: QBUtil.INTERNAL AND Checkout_Type__c !=: QBUtil.DEAL AND Is_Charge_Account_Payment_Exists__c > 0 
                    AND Total_Amount_Except_Charge_Account__c > 0 Order by CreatedDate ASC];
                    
        for(CO_Invoice_Header__c coInvoiceRec : coInvoiceList) {
            coInvoiceRec.availForQBCOInvoicePayment__c = true;
        }
        update coInvoiceList;
        enableTrigger('COInvoiceTrigger');
    }
    
    global static void resetSyncFlagForCOInvoicePaymentJENotPostedToQB() {
        disbaleTrigger('COInvoicePaymentTrigger');
        List<CO_Invoice_Payment__c> coInvoicePaymentList = 
            [Select Id from CO_Invoice_Payment__c where availForQBJournalEntrySync__c = true AND Payment_Method__c = 'Charge Account' Order by CreatedDate ASC];
                    
        for(CO_Invoice_Payment__c coInvoicePaymentRec : coInvoicePaymentList) {
            coInvoicePaymentRec.availForQBJournalEntrySync__c = false;
        }
        update coInvoicePaymentList;
        enableTrigger('COInvoicePaymentTrigger');
    }
    
    global static void resetSyncFlagForVendorInvoiceNotPostedToQB() {
        disbaleTrigger('VendorInvoicingHeaderTrigger');
        List<Vendor_Invoicing_Header__c> vendorInvoiceList = 
            [Select Id from Vendor_Invoicing_Header__c where availForQBSync__c = true AND Status__c != 'Invoiced' Order by CreatedDate ASC];
                    
        for(Vendor_Invoicing_Header__c vendorInvoiceRec : vendorInvoiceList) {
            vendorInvoiceRec.availForQBSync__c = false;
        }
        update vendorInvoiceList;
        enableTrigger('VendorInvoicingHeaderTrigger');
    }
    
    global static void resetSyncFlagForVendorReturnNotPostedToQB() {
        disbaleTrigger('ReturnVOHeaderTrigger');
        List<Return_VO_Header__c> vendorReturnList = 
            [Select Id from Return_VO_Header__c where availForQBSync__c = true AND Status__c != 'Credited' Order by CreatedDate ASC];
                    
        for(Return_VO_Header__c returnVendorRec : vendorReturnList) {
            returnVendorRec.availForQBSync__c = false;
        }
        update vendorReturnList;
        enableTrigger('ReturnVOHeaderTrigger');
    }
    
    global static void resetSyncFlagForStoreCreditJENotPostedToQB() {
        disbaleTrigger('StoreCreditTrigger');
        List<Store_Credit__c> storeCreditList = 
            [Select Id from Store_Credit__c where availForQBSync__c = true AND CO_Invoice_Header__c != null Order by CreatedDate ASC];
                    
        for(Store_Credit__c storeCreditRec : storeCreditList) {
            storeCreditRec.availForQBSync__c = false;
        }
        update storeCreditList;
        enableTrigger('StoreCreditTrigger');
    }
    
    global static void resetSyncFlagForVendorReceivingJENotPostedToQB() {
        disbaleTrigger('VendorReceivingHeaderTrigger');
        List<Vendor_Receiving_Header__c> vendorReceivingList = 
            [Select Id from Vendor_Receiving_Header__c where availForQBJournalEntrySync__c = true AND Status__c != 'Stocked' Order by CreatedDate ASC];
                    
        for(Vendor_Receiving_Header__c vendorReceivingRec : vendorReceivingList) {
            vendorReceivingRec.availForQBJournalEntrySync__c = false;
        }
        update vendorReceivingList;
        enableTrigger('VendorReceivingHeaderTrigger');
    }
    
    global static void resetSyncFlagForPartFIFOJENotPostedToQB() {
        disbaleTrigger('PartFIFOBucketTrigger');
        List<Part_FIFO_Bucket__c> fifoBucketList = 
            [Select Id from Part_FIFO_Bucket__c where availForQBSync__c = true AND (Is_FIFO_Bucket__c = false OR Vendor_Receiving_Header__c != null 
                    OR Customer_Return__c != null OR Source_Name__c = 'Part Created' OR Source_Name__c = 'Oversold')
                    Order by CreatedDate ASC];
                    
        for(Part_FIFO_Bucket__c fifoBucketRec : fifoBucketList) {
            fifoBucketRec.availForQBSync__c = false;
        }
        update fifoBucketList;
        enableTrigger('PartFIFOBucketTrigger');
    }
    
    global static void resetSyncFlagForPartFIFOActivityLIJENotPostedToQB() {
        disbaleTrigger('PartFIFOBucketActivityLineItemTrigger');
        List<Part_FIFO_Bucket_Activity_Line_Item__c> fifoBucketActivityLIList = 
            [Select Id from Part_FIFO_Bucket_Activity_Line_Item__c where availForQBSync__c = true AND (Part_FIFO_Bucket__r.Is_FIFO_Bucket__c = false OR CO_Invoice_Header__c != null)
                    Order by CreatedDate ASC];
                    
        for(Part_FIFO_Bucket_Activity_Line_Item__c fifoBucketActivityLIRec : fifoBucketActivityLIList) {
            fifoBucketActivityLIRec.availForQBSync__c = false;
        }
        update fifoBucketActivityLIList;
        enableTrigger('PartFIFOBucketActivityLineItemTrigger');
    }
    
    global static void resetSyncFlagForUnitNotPostedToQB() {
        disbaleTrigger('CustomerOwnedUnitTrigger');
        List<Customer_Owned_Unit__c> unitList = 
            [Select Id from Customer_Owned_Unit__c where availForQBSync__c = true AND (Unit_Type__c != 'STOCK' OR (Unit_Type__c = 'STOCK' AND (Referenced_Unit__c = null OR (Referenced_Unit__c != null AND (Referenced_Unit__r.Unit_Type__c != 'ORDU' OR Referenced_Unit__r.Status__c != 'Received')))))
                    Order by CreatedDate ASC];
                    
        for(Customer_Owned_Unit__c unitRec : unitList) {
            unitRec.availForQBSync__c = false;
        }
        update unitList;
        enableTrigger('CustomerOwnedUnitTrigger');
    }
    
    global static void resetSyncFlagForUnitPriceAndCostNotPostedToQB() {
        disbaleTrigger('UnitPriceAndCostTrigger');
        List<Unit_Price_Cost__c> unitPriceAndCostList = 
            [Select Id from Unit_Price_Cost__c where availForQBSync__c = true AND (Ref_No__c = null OR (NOT Ref_No__c like 'UA-%') OR Unit_Type__c != 'STOCK' OR Total_Cost__c = null OR Total_Cost__c = 0 OR Type__c = 'Dealer')
                    Order by CreatedDate ASC];
                    
        for(Unit_Price_Cost__c unitRec : unitPriceAndCostList) {
            unitRec.availForQBSync__c = false;
        }
        update unitPriceAndCostList;
        enableTrigger('UnitPriceAndCostTrigger');
    }
    // End: Reset Older records sync flag
    
    // Trigger Disable
    public static void disbaleTrigger(String triggerName) {
        if(AccessControl.ifObjectFieldIsCreateable('Trigger_Soft_Disable__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        Trigger_Soft_Disable__c triggerToDisable = new Trigger_Soft_Disable__c();
        triggerToDisable.Name = triggerName;
        triggerToDisable.Disable_Delete__c = triggerToDisable.Disable_Insert__c = triggerToDisable.Disable_Undelete__c = true;
        triggerToDisable.Disable_Update__c = true;
        insert triggerToDisable;
    }
    
    public static void enableTrigger(String triggerName) {
        if(AccessControl.ifObjectIsDeletable('Trigger_Soft_Disable__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        delete [Select Id from Trigger_Soft_Disable__c where Name =: triggerName];
    }
}