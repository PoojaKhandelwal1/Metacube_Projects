/**
 * Author: Nikhil Kumar Srivastava
 * Since: Apr. 05, 2019
 * Name: AccountingCustomBatchScheduler
 * Description: Scheduler class for AccountingCustomerBatch
**/

global with sharing class AccountingVendorBatchScheduler implements Schedulable {
	
	global Set<Id> recordIdSet;
    global Integer batchSize;
    private static BaseIntegrationService integrationRec;
    
    global AccountingVendorBatchScheduler(Set<Id> recordIdSet, Integer batchSize){
        this.recordIdSet = recordIdSet;
        this.batchSize = batchSize;
    }
    
    global void execute(SchedulableContext sc) {
    	integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
    	if(integrationRec != null) {
    		new IntegrationUtility().getIntegrationEntityMetadata(new List<BaseIntegrationService>{integrationRec}, new List<String>{IntegrationUtility.VENDOR});
	        IntegrationBatchService.initiateBatch(recordIdSet, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.VENDOR);
    	}
	}
}