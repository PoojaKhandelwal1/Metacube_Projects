global without sharing class SyncVendorBatch extends BaseSyncingBatch {
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getBaseQuery('Account', AccountingVendor.fieldsList(), IntegrationUtility.VENDOR));
    }

    global void execute(Database.batchableContext bc, List<Account> listVendors) {
        List<AccountingVendor> accountingVendorList = new List<AccountingVendor>();
        for(Account vendor : listVendors) {
        	String accId = String.valueOf(vendor.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.VENDOR).Integration_Id_API_Name__c));
        		accountingVendorList.add(new AccountingVendor(vendor));
        	}	
        	if(accountingVendorList.size() > 0) {
        		//Note: We are only performing Update Action for Xero, Since POST works for Create and Update both. 
        		Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.CONTACTS => IntegrationUtility.UPDATE_ACTION};
        		this.webserviceLogs.addAll(integrationInstanceList[0].sync(accountingVendorList, (List<SObject>) sobjctListToUpdate, 
                                            IntegrationUtility.VENDOR, integrationEntityNameToActionMap));
        	}
    	}
 
    global override void finish(Database.batchableContext bc) {
        finishAction();   
    }
}