/**
 * Author: Nikhil Kumar Srivastava
 * Since: April 04, 2019
 * Name: XeroScriptUtil
 * Description: Apex class for all scripts related to Xero
**/
global class XeroScriptUtil {
	
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
                QBUtil.abortAlreadyScheduleJobs('Xero Customer Sync ' + i);
                system.schedule('Xero Customer Sync ' + i, cronExp, new AccountingCustomerBatchScheduler(recordIdSet, batchSize));
            } else if(entityType == 'Vendor') {
                QBUtil.abortAlreadyScheduleJobs('Xero Vendor Sync ' + i);
                system.schedule('Xero Vendor Sync ' + i, cronExp, new AccountingVendorBatchScheduler(recordIdSet, batchSize));
            }
        }
   }             
            
     global static void syncCustomers(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<Account> customerList = [Select Id from Account where Is_Customer__c = true AND Available_For_Xero_Customer_Sync__c = true
                                            Order by CreatedDate DESC];
        scheduleJobs(customerList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'Customer');
    }       
    
    global static void syncVendors(Integer maxNumberOfRecord, Integer timeIntervalForJobsInSec, Integer batchSize) {
        List<Account> vendorList = [Select Id from Account where Is_Vendor__c = true AND Available_For_Xero_Vendor_Sync__c = true 
                                            Order by CreatedDate ASC];
        scheduleJobs(vendorList, maxNumberOfRecord, timeIntervalForJobsInSec, batchSize, 'Vendor');
    } 
     
}