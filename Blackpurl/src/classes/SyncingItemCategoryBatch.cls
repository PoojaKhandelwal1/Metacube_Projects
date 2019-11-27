global without sharing class SyncingItemCategoryBatch extends BaseSyncingBatch {
    
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getBaseQuery('Category__c', AccountingItemCategory.fieldsList(), IntegrationUtility.ITEM_CATEGORY));
    }

    global void execute(Database.batchableContext bc, List<Category__c> listItemCategories) {
        for(Category__c itemCategory : listItemCategories) {
        	String accId = String.valueOf(itemCategory.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.ITEM_CATEGORY).Integration_Id_API_Name__c));
    		Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.ITEM => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
        	this.webserviceLogs.addAll(integrationInstanceList[0].sync(new List<AccountingItemCategory>{new AccountingItemCategory(itemCategory)}, (List<SObject>) sobjctListToUpdate, 
                                            IntegrationUtility.ITEM_CATEGORY, integrationEntityNameToActionMap));
        }
    }
 
    global override void finish(Database.batchableContext bc) {
        finishAction();
    }
}