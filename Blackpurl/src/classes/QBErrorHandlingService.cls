public class QBErrorHandlingService {
    public Set<Id> recordsToProcess;
    public String syncEntity;
    public Integer retrialAttemptNumber;
    public String errorType;
    public QBErrorHandlingService(String errorType, Set<Id> recordsToProcess, String syncEntity ) {
        this.recordsToProcess = recordsToProcess;
        this.syncEntity = syncEntity;
        this.errorType = errorType;
    }
    
    public static void addDelayToBatch() {
        if(AccessControl.ifObjectFieldIsAccessible('QuickBooks_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Integer delayInMilliseconds = Integer.valueOf((QuickBooks_Configurations__c.getOrgDefaults().BatchDelayInterval__c != null ? QuickBooks_Configurations__c.getOrgDefaults().BatchDelayInterval__c : 0)*1000);
        BPUtility.sleepSystem(delayInMilliseconds);
    }
    
    public void executeRetry(Integer retrialAttemptNumber) {
        this.retrialAttemptNumber = retrialAttemptNumber;
        if(this.syncEntity == 'Customer') {
            if(errorType == Constants.READ_TIMED_OUT_ERROR_MESSAGE) {
                executeCustomerRetry(retrialAttemptNumber);
            }
        } else if(this.syncEntity == 'Vendor') {
            if(errorType == Constants.READ_TIMED_OUT_ERROR_MESSAGE) {
                executeVendorRetry(retrialAttemptNumber);
            }
        }
    }
    
    private void executeVendorRetry(Integer retrialAttemptNumber) {
        AccSync_Vendor_Batch.runVendorsForSync(this.recordsToProcess, 10, this.retrialAttemptNumber + 1, true);
    }
    private void executeCustomerRetry(Integer retrialAttemptNumber) {
        AccSync_Customer_Batch.runCustomersForSync(this.recordsToProcess, 10, this.retrialAttemptNumber + 1, true);
    }
    
}