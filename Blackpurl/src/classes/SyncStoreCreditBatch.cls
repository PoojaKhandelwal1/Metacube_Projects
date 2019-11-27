global without sharing class SyncStoreCreditBatch extends BaseSyncingBatch {
    
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getBaseQuery('Store_Credit__c', AccountingStoreCredit.fieldsList(), IntegrationUtility.STORE_CREDIT));
    }

    global void execute(Database.batchableContext bc, List<Store_Credit__c> listStoreCredit) {
        for(Store_Credit__c storeCredit : listStoreCredit) {
        	String accId = String.valueOf(storeCredit.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.STORE_CREDIT).Integration_Id_API_Name__c));
    		Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.JOURNAL_ENTRY => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
        	this.webserviceLogs.addAll(integrationInstanceList[0].sync(new List<AccountingStoreCredit>{new AccountingStoreCredit(storeCredit)}, (List<SObject>) sobjctListToUpdate, 
                                            IntegrationUtility.STORE_CREDIT, integrationEntityNameToActionMap));
        }
    }
 
    global override void finish(Database.batchableContext bc) {
        finishAction();
    }
}