global without sharing class SyncingPartFifoBucketActivityLIBatch extends BaseSyncingBatch {
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getBaseQuery('Part_FIFO_Bucket_Activity_Line_Item__c', AccountingFIFOBucketActivityLineItem.fieldsList(), IntegrationUtility.PART_FIFO_BUCKET_ACTIVITY_LINE_ITEM));
    }

    global void execute(Database.batchableContext bc, List<Part_FIFO_Bucket_Activity_Line_Item__c> partFifoBucketActivityLineItemlist) {
         for(Part_FIFO_Bucket_Activity_Line_Item__c partFIFOBucketLIRec : partFifoBucketActivityLineItemlist){
        	String accId = String.valueOf(partFIFOBucketLIRec.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.PART_FIFO_BUCKET_ACTIVITY_LINE_ITEM).Integration_Id_API_Name__c));
    		Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.JOURNAL_ENTRY => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
        	this.webserviceLogs = integrationInstanceList[0].sync(new List<AccountingFIFOBucketActivityLineItem>{new AccountingFIFOBucketActivityLineItem(partFIFOBucketLIRec)}, (List<SObject>) sobjctListToUpdate, 
                                            IntegrationUtility.PART_FIFO_BUCKET_ACTIVITY_LINE_ITEM, integrationEntityNameToActionMap);
        }
    }
 
    global override void finish(Database.batchableContext bc){
        finishAction();
    }
}