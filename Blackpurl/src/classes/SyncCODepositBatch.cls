global without sharing class SyncCODepositBatch extends BaseSyncingBatch {
    
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getBaseQuery('CO_Deposit__c', AccountingCODeposit.fieldsList(), IntegrationUtility.CO_DEPOSIT));
    }
    
    global void execute(Database.batchableContext bc, List<CO_Deposit__c> listCODeposit) {
    	for(CO_Deposit__c coDepositRec : listCODeposit) {
        	String accId = String.valueOf(coDepositRec.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.CO_DEPOSIT).Integration_Id_API_Name__c));
    		Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.JOURNAL_ENTRY => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
        	this.webserviceLogs.addAll(integrationInstanceList[0].sync(new List<AccountingCODeposit>{new AccountingCODeposit(coDepositRec)}, (List<SObject>) sobjctListToUpdate, 
                                            IntegrationUtility.CO_DEPOSIT, integrationEntityNameToActionMap));
        }
    }
    
    global override void finish(Database.batchableContext bc){
        finishAction();
    }
}