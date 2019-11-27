global without sharing class SyncingPartCategoryBatch extends BaseSyncingBatch {
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getBaseQuery('Part__c', AccountingPart.fieldsList(), IntegrationUtility.PART_CATEGORY));
    }

    global void execute(Database.batchableContext bc, List<Part__c> listPartCategories) {
        for(Part__c partCategory : listPartCategories) {
        	String accId = String.valueOf(partCategory.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.PART_CATEGORY).Integration_Id_API_Name__c));
    		Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.JOURNAL_ENTRY => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
        	this.webserviceLogs.addAll(integrationInstanceList[0].sync(new List<AccountingPart>{new AccountingPart(partCategory)}, (List<SObject>) sobjctListToUpdate, 
                                            IntegrationUtility.PART_CATEGORY, integrationEntityNameToActionMap));
        }
    }
 
    global override void finish(Database.batchableContext bc){
        finishAction();
    }
}