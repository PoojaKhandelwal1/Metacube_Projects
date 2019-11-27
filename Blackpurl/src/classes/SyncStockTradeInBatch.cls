global without sharing class SyncStockTradeInBatch extends BaseSyncingBatch {
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getBaseQuery('Deal_Item__c', AccountingDealItem.fieldsList(), IntegrationUtility.STOCK_TRADE_IN));
    }

    global void execute(Database.batchableContext bc, List<Deal_Item__c> listdealItems) {
        for(Deal_Item__c dealItem : listdealItems) {
            String accId = String.valueOf(dealItem.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.STOCK_TRADE_IN).Integration_Id_API_Name__c));
            Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.JOURNAL_ENTRY => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
            this.webserviceLogs.addAll(integrationInstanceList[0].sync(new List<AccountingDealItem>{new AccountingDealItem(dealItem)}, (List<SObject>) sobjctListToUpdate, 
                                            IntegrationUtility.STOCK_TRADE_IN, integrationEntityNameToActionMap));
        }
    }
 
    global override void finish(Database.batchableContext bc){
        finishAction();
    }
}