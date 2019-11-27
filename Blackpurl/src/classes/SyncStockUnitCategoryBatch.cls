global without sharing class SyncStockUnitCategoryBatch extends BaseSyncingBatch {
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getBaseQuery('Customer_Owned_Unit__c', AccountingUnit.fieldsList(), IntegrationUtility.STOCK_UNIT_CATEGORY));
    }

    global void execute(Database.batchableContext bc, List<Customer_Owned_Unit__c> listStockUnitCategories) {
        for(Customer_Owned_Unit__c stockUnitCategory : listStockUnitCategories) {
            String accId = String.valueOf(stockUnitCategory.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.STOCK_UNIT_CATEGORY).Integration_Id_API_Name__c));
            Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.JOURNAL_ENTRY => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
            this.webserviceLogs.addAll(integrationInstanceList[0].sync(new List<AccountingUnit>{new AccountingUnit(stockUnitCategory)}, (List<SObject>) sobjctListToUpdate, 
                                            IntegrationUtility.STOCK_UNIT_CATEGORY, integrationEntityNameToActionMap));
        }
    }
 
    global override void finish(Database.batchableContext bc){
        finishAction();
    }
}