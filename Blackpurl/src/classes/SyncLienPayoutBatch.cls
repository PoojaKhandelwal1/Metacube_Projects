global without sharing class SyncLienPayoutBatch extends BaseSyncingBatch {
    
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getBaseQuery('Deal_Item__c', AccountingLienPayout.fieldsList(), IntegrationUtility.LIEN_PAYOUT));
    }
    
    global void execute(Database.batchableContext bc, List<Deal_Item__c> listdealItems) {
        for(Deal_Item__c dealItem : listdealItems){
        	String accId = String.valueOf(dealItem.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.LIEN_PAYOUT).Integration_Id_API_Name__c));
        	Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.Invoice => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
	        	this.webserviceLogs = integrationInstanceList[0].sync(new List<AccountingLienPayout>{new AccountingLienPayout(dealItem)}, (List<SObject>) sobjctListToUpdate, 
	                                    IntegrationUtility.LIEN_PAYOUT, integrationEntityNameToActionMap);
        }
    }
    
    global override void finish(Database.batchableContext bc){
    	finishAction();
    	
    }
}