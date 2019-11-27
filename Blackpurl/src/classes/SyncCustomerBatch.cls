global without sharing class SyncCustomerBatch extends BaseSyncingBatch {
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getBaseQuery('Account', AccountingCustomer.fieldsList(), IntegrationUtility.CUSTOMER));
    }
    
    global void execute(Database.batchableContext bc, List<Account> listCustomers) {
        List<AccountingCustomer> accountingCustomerList = new List<AccountingCustomer>();
        for(Account customer : listCustomers) {
        	String accId = String.valueOf(customer.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.CUSTOMER).Integration_Id_API_Name__c));
        	accountingCustomerList.add(new AccountingCustomer(customer));
        }
       if(accountingCustomerList.size() > 0) {
       		//Note: We are only performing Update Action for Xero, Since POST works for Create and Update both.
        	Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.CONTACTS => IntegrationUtility.UPDATE_ACTION};
	        this.webserviceLogs.addAll(integrationInstanceList[0].sync(accountingCustomerList, (List<SObject>) sobjctListToUpdate, 
	                                            IntegrationUtility.CUSTOMER, integrationEntityNameToActionMap));
       } 
   	}
        
    global override void finish(Database.batchableContext bc){
    	finishAction();
    	
    }
}