global without sharing class SyncUnitPriceAndCostBatch extends BaseSyncingBatch {
    
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getBaseQuery('Unit_Price_Cost__c', AccountingUnitPriceAndCost.fieldsList(), IntegrationUtility.UNIT_PRICE_COST));
    }
    global void execute(Database.batchableContext bc, List<Unit_Price_Cost__c> listUnitPriceAndCost) {
        for(Unit_Price_Cost__c unitPriceAndCost : listUnitPriceAndCost) {
            String accId = String.valueOf(unitPriceAndCost.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.UNIT_PRICE_COST).Integration_Id_API_Name__c));
            Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.JOURNAL_ENTRY => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
            this.webserviceLogs.addAll(integrationInstanceList[0].sync(new List<AccountingUnitPriceAndCost>{new AccountingUnitPriceAndCost(unitPriceAndCost)}, (List<SObject>) sobjctListToUpdate, 
                                            IntegrationUtility.UNIT_PRICE_COST, integrationEntityNameToActionMap));
        }
    }
  
    global override void finish(Database.batchableContext bc) {
        finishAction();
    }
}