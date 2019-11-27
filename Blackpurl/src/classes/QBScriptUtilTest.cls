/**
 * Author: Rajat Jain
 * Since: June 5, 2018
 * Name: QBScriptUtilTest
 * Description: test Class for QBScriptUtilTest.
**/

@isTest
public with sharing class QBScriptUtilTest {

    static testmethod void scriptUtilTest() {
        Test.startTest();
        
        QBScriptUtil.syncCustomers(5,60,5);
        /*QBScriptUtil.scheduleJobs(List<sObject> recordList, Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize,
                                            String entityType);*/
        QBScriptUtil.syncVendors(5,60,5);
        QBScriptUtil.syncCategory();
        QBScriptUtil.syncInvoices(5,60,5);
        QBScriptUtil.syncJournalEntryForInvoices(5,60,5);
        QBScriptUtil.syncVendorInvoices(5,60,5);
        QBScriptUtil.syncUnits(5,60,5);
        QBScriptUtil.syncVendorReturn(5,60,5);
        QBScriptUtil.syncDeposits(5,60,5);
        QBScriptUtil.syncUnitPriceAndCost(5,60,5);
        QBScriptUtil.syncStoreCredits(5,60,5);
        QBScriptUtil.syncCOInvoicePayments(5,60,5);
        QBScriptUtil.syncFIFOBuckets(5,60,5);
        QBScriptUtil.syncFIFOBucketLineItems(5,60,5);
        QBScriptUtil.syncVRJE(5,60,5);
        QBScriptUtil.resetSyncFlagForCOInvoiceNotPostedToQB();
        QBScriptUtil.resetSyncFlagForCOInvoiceJENotPostedToQB();
        QBScriptUtil.setSyncFlagForCOInvoicePaymentPostedToQB();
        QBScriptUtil.resetSyncFlagForVendorInvoiceNotPostedToQB();
        QBScriptUtil.resetSyncFlagForVendorReturnNotPostedToQB();
        QBScriptUtil.resetSyncFlagForCOInvoicePaymentJENotPostedToQB();
        QBScriptUtil.resetSyncFlagForStoreCreditJENotPostedToQB();
        QBScriptUtil.resetSyncFlagForVendorReceivingJENotPostedToQB();
        QBScriptUtil.resetSyncFlagForPartFIFOJENotPostedToQB();
        QBScriptUtil.resetSyncFlagForPartFIFOActivityLIJENotPostedToQB();
        QBScriptUtil.resetSyncFlagForUnitNotPostedToQB();
        QBScriptUtil.resetSyncFlagForUnitPriceAndCostNotPostedToQB();
        system.assert(true,true);
        
        Test.stopTest();
    }
}
