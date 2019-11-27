global without sharing class SyncingPartFifoBucketBatch extends BaseSyncingBatch {
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getBaseQuery('Part_FIFO_Bucket__c',  AccountingFIFOBucket.fieldsList(), IntegrationUtility.PART_FIFO));
    }

    global void execute(Database.batchableContext bc, List<Part_FIFO_Bucket__c> listPartFIFOBuckets) {
        for(Part_FIFO_Bucket__c partFIFOBucketRec : listPartFIFOBuckets){
        	String accId = String.valueOf(partFIFOBucketRec.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.PART_FIFO).Integration_Id_API_Name__c));
    		Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.JOURNAL_ENTRY => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
        	this.webserviceLogs.addAll(integrationInstanceList[0].sync(new List<AccountingFIFOBucket>{new AccountingFIFOBucket(partFIFOBucketRec)}, (List<SObject>) sobjctListToUpdate, 
                                            IntegrationUtility.PART_FIFO, integrationEntityNameToActionMap));
        }
    }
 
    global override void finish(Database.batchableContext bc){
        finishAction();
    }
}