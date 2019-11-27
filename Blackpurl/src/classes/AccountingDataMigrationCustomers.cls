/**
 * Author: Ashish Garg
 * Since: Dec. 18, 2015
 * Name: AccountingDataMigrationCustomers
 * Description: Class is used for migration of Customer object records to  Accounting Software
**/
global with sharing class AccountingDataMigrationCustomers implements Database.batchable<sObject>,Database.Stateful {
	
	global AccountingDataMigrationCustomers() {}
	global AccountingDataMigrationCustomers(List<Id> recordIds, boolean exportAllData) {}
	global AccountingDataMigrationCustomers(List<Id> recordIds, boolean exportAllData, String timePeriod, DateTime fromDate, DateTime toDate) {}
	
	private static final Integer BATCH_SIZE = 1000;
	private String objName = 'Customers';	//Obj Name to Export by default set to export type 'Customer'
	
	private String cardsData = '';
	private Integer indexVal = 1; 
	
	private string query; 
	private DateTime Last_Synched_Date;
    private String timePeriodForFilter;
	private DateTime From_Date; 
	private DateTime To_Date; 
    private Accounting_Data_Migration__c dataMigration; 
    
    public static Id executeCardsDataMigrationBatch(Integer batchSize, List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
		Id batchId = Database.executeBatch(new AccountingDataMigrationCustomers(recordIds, timePeriod, fromDate, toDate, objNameToExport), batchSize);
		return batchId;
	}
	
	global AccountingDataMigrationCustomers(List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
		if(AccessControl.ifObjectFieldIsAccessible('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		if(AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
		if(AccessControl.ifObjectFieldIsUpdateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
		
		this.objName = (Constants.exportDisplayObjectNameToObjectNameMap.containsKey(objNameToExport)) ? 
														Constants.exportDisplayObjectNameToObjectNameMap.get(objNameToExport) : objName;
		this.timePeriodForFilter = timePeriod;
		this.From_Date = fromDate;
		this.To_Date = toDate; 
		 
		dataMigration = DataExportUtil.getAccountingDataMigrationRec(objNameToExport);
		Last_Synched_Date = dataMigration.Last_Synched_Date__c;
		dataMigration = DataExportUtil.getDateRange(timePeriod, Last_Synched_Date, fromDate, toDate,new List<Accounting_Data_Migration__c>{dataMigration});
    	dataMigration.Last_Synched_Date__c = Datetime.now(); 
    	upsert dataMigration; 

    	if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	query = DataExportUtil.createQuery(recordIds, 'Id', this.timePeriodForFilter, Last_Synched_Date, fromDate, toDate, this.objName);
	}
	 
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	} 
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Account> accounts = (List<Account>) scope;
		system.debug('indexValindexVal => ' + indexVal);
		if(accounts.size() > 0){
	    	// Map of card records for all applicable saleforce account records
	    	Map<Integer, Map<String,String>> cardRecords = new Map<Integer, Map<String, String>>();
	    	
	    	// For each customer account, create a customer card entry:
	    	for(Account accRec : accounts){
	    		cardRecords.put(indexVal, createCardRecordFromAccount(accRec, this.objName));
	    		indexVal++;
	    	}
	    	 
	    	// Now create a string for list of customer card records so as to convert in format of importable text file for accounting software
    		cardsData += DataExportUtil.createImportableText(cardRecords, this.objName);
    		cardsData = (cardsData.indexOf('{') != -1) ? cardsData.subString(cardsData.indexOf('{')) : cardsData;
    	}
	}
	
	global void finish(Database.BatchableContext BC) {
		if(AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
		if(AccessControl.ifObjectFieldIsUpdateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
		
    	dataMigration.Records_Processed__c = indexVal - 1;
    	upsert dataMigration;
    	
    	if(dataMigration.Records_Processed__c > 0) {
	    	String attchPrefix = (this.objName == 'Customers') ? 'CUSTOMER_' : 'SUPPLIER_';
	    	if(AccessControl.ifObjectFieldIsCreateable('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	    	insert DataExportUtil.createAttachment(cardsData, attchPrefix, dataMigration, indexVal - 1);
    	}
	}
	
	public static Map<String, String> createCardRecordFromAccount(Account accRec, String objectName) {
    	Map<String, String> card = new Map<String, String>{ 'WWW__c'			=>	accRec.Website,
															'Fax_No__c'			=>	accRec.Fax,
															'SP_Layout__c'		=>	'M',
															'Use_Supp_Tax__c'	=>	'Y'
														};
    															
    	if(objectName == 'Customers') {
    		card.put('Card_Id__c', accRec.Customer_Number__c);
    		card.put('Card_Status__c', (accRec.Active__c) ? 'N' : 'Y');
    		card.put('Notes__c', (accRec.Description != null) ? accRec.Description.mid(0, 255) : '');
	    	card.put('Use_Cust_Tax__c', 'Y');
	    	card.put('Last_Name__c', accRec.Name);
	    	
	    	if(accRec.Type__c == 'Individual'){
	    		card.put('First_Name__c', accRec.FirstName__c);
    			card.put('Last_Name__c', accRec.LastName__c);
	    		card.put('Email__c', (accRec.Email__c != null) ? accRec.Email__c : ((accRec.Other_Email__c != null) ? accRec.Other_Email__c : ''));
	    		card.put('Phone_No_1__c', (accRec.Home_Number__c != null) ? accRec.Home_Number__c : '');
	    	} else {
	    		card.put('Email__c', (accRec.Work_Email__c != null) ? accRec.Work_Email__c : ((accRec.Other_Email__c != null) ? accRec.Other_Email__c : ''));
	    		card.put('Phone_No_1__c', (accRec.Work_Number__c != null) ? accRec.Work_Number__c : '');
	    	}
	    	
    	} else if(objectName == 'Vendors') {
    		card.put('Card_Id__c', accRec.Vendor_Code__c);
    		card.put('Email__c', (accRec.Work_Email__c != null) ? accRec.Work_Email__c : ((accRec.Other_Email__c != null) ? accRec.Other_Email__c : ''));
    		card.put('Phone_No_1__c', (accRec.Work_Number__c != null) ? accRec.Work_Number__c : '');
	    	card.put('Tax_Code__c', (accRec.Purchase_Tax__r.Name__c != null) ? accRec.Purchase_Tax__r.Name__c : '');
	    	card.put('Use_Supp_Tax__c', 'Y');
	    	card.put('Name', accRec.Name);
    	}
    	
    	card.put('Phone_No_2__c', (accRec.Mobile__c != null) ? accRec.Mobile__c : '');
    	
    	if(accRec.BillingStreet != null) {
    		List<String> billingStreetList = accRec.BillingStreet.split('\n');
    		card.put('Addr1_Line_1__c', billingStreetList[0]);
    		if(billingStreetList.size() > 1){
    			card.put('Addr1_Line_2__c', billingStreetList[1]);
    		}
    	}
    	
    	card.put('Addr1_City__c', accRec.BillingCity);
    	card.put('Addr1_State__c', accRec.BillingState);
    	card.put('Addr1_Postcode__c', accRec.BillingPostalCode);
    	card.put('Addr1_Country__c', accRec.BillingCountry);
    	
    	// Assign shipping address
    	if(!accRec.SA_same_as_BA__c) {
    		if(accRec.ShippingStreet != null) {
    			List<String> shippingStreetList = accRec.ShippingStreet.split('\n');
	    		card.put('Addr2_Line_1__c', shippingStreetList[0]);
	    		if(shippingStreetList.size() > 1){
	    			card.put('Addr2_Line_2__c', shippingStreetList[1]);
	    		}
    		}
    		card.put('Addr2_City__c', accRec.ShippingCity);
	    	card.put('Addr2_State__c', accRec.ShippingState);
	    	card.put('Addr2_Postcode__c', accRec.ShippingPostalCode);
	    	card.put('Addr2_Country__c', accRec.ShippingCountry);
    	}
    	
    	return card;
    }
}