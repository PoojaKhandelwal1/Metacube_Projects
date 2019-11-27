/**
 * Author: Richa Mittal
 * Since: Jan. 16, 2017
 * Name: CODepositTriggerHelper
 * Description: Helper class for triggers on CO Deposit object
**/
public with sharing class CODepositTriggerHelper {
    // List to store trigger new list
    public static List<CO_Deposit__c> CODepositNewList = new List<CO_Deposit__c>();
    
    // List to store trigger old list
    public static List<CO_Deposit__c> CODepositOldList = new List<CO_Deposit__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, CO_Deposit__c> CODepositNewMap = new Map<Id, CO_Deposit__c>();

    // Map to store Old Trigger Map
    public static Map<Id, CO_Deposit__c> CODepositOldMap = new Map<Id, CO_Deposit__c>();
     
    // Trigger run boolean
    public static Boolean isTriggerRun;
    
    // Trigger run boolean
    public static Boolean preventOnAccountingSync = false;
    
    private static BaseIntegrationService integrationRec;
    
    public static void populatesAccountingSyncFields(){
    	if(QBUtil.isQBEnabled()) {
			CODepositNewList = QBSyncFlagService.manageCODepositJESyncFlag(CODepositNewList);
		} else {
        	integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
        	if(integrationRec != null) {
                IntegrationSyncFlagService.manageCODepositSyncFlag(new List<BaseIntegrationService>{integrationRec}, CODepositNewList);
        	}
        }
    }
    
    public static void setCODepositDataForAccountSync(){
    	Set<Id> setCODepositIds = new Set<Id>();
    	for(CO_Deposit__c CODeposit : CODepositNewList){ 
    		if(QBUtil.isQBEnabled()) {
    			if(CODeposit.availForQBJournalEntrySync__c) {
    				setCODepositIds.add(CODeposit.Id);
    			}
    		} else if(integrationRec != null) {
    	    	if(CODeposit.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.CO_DEPOSIT).Sync_Flag_API_Name__c) != null && 
	    			Boolean.valueOf(CODeposit.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.CO_DEPOSIT).Sync_Flag_API_Name__c))) {
    	        	setCODepositIds.add(CODeposit.Id);
    	    	}
        	}
    	}

    	if(setCODepositIds.size() > 0) {
    		if(QBUtil.isQBEnabled()) {
    			CODepositJournalEntryService.syncCODeposits(setCODepositIds);
    		} else {
    			IntegrationBatchService.initiateBatch(setCODepositIds, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.CO_DEPOSIT);
    		}
    	}
    }
}
