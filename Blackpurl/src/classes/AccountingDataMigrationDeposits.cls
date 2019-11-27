/**
 * Author: Ashish Garg
 * Since: Dec. 18, 2015
 * Name: AccountingDataMigrationDeposits
 * Description: Class is used for migration of Deposit records to  Accounting Software
**/
global with sharing class AccountingDataMigrationDeposits implements Database.batchable<sObject>, Database.Stateful {
	
	global AccountingDataMigrationDeposits() {}
	global AccountingDataMigrationDeposits(List<Id> recordIds, boolean exportAllData) {}
	global AccountingDataMigrationDeposits(List<Id> recordIds, boolean exportAllData, String timePeriod, DateTime fromDate, DateTime toDate) {}
	 
	private String objName = 'CO_Deposit__c';
	private String depositsTextData = '';
	private integer indexVal = 1;
	private integer recordCount = 0;
	
	private string query;  
	private DateTime Last_Synched_Date;
	private String timePeriodForFilter;
	private DateTime fromDate;
	private DateTime toDate;
	private	Accounting_Data_Migration__c dataMigration;
	private static String undepositedFundsGLCode = AccountingUtil.getChartofAccount('Undeposited Funds');
	private static String customerDepositGLCode = AccountingUtil.getChartofAccount('Customer Deposits');
	private static String cashCustomerId = AccountingUtil.getChartofAccount('Cash Sale Customer');
	private static String internalServiceCustomerId = AccountingUtil.getChartofAccount('Internal Service Customer');
	private static String storeCreditAccrualGLCode = AccountingUtil.getChartofAccount('Store Credit Accrual');
	private static String undepositedDirectDepositGLCode = AccountingUtil.getChartofAccount('Undeposited Direct Deposit');
	private static String undepositedFinancingGLCode = AccountingUtil.getChartofAccount('Undeposited Financing');
	
	/**
     * Name: executeDepositsDataMigrationBatch
     * Desc: Method to initiate the deposits export
     * @param: 
     * @return: Id
    **/
	public static Id executeDepositsDataMigrationBatch(Integer batchSize, List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
		Id batchId = Database.executeBatch(new AccountingDataMigrationDeposits(recordIds, timePeriod, fromDate, toDate, objNameToExport), batchSize);
		return batchId;
	}
	
	/**
     * Name: AccountingDataMigrationDeposits
     * Desc: Constructor to start the batch for data export
    **/
	global AccountingDataMigrationDeposits(List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
		if(AccessControl.ifObjectFieldIsAccessible('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		if(AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
		if(AccessControl.ifObjectFieldIsUpdateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
		
		this.timePeriodForFilter = timePeriod;
		this.fromDate = fromDate;
		this.toDate = toDate; 
		dataMigration = DataExportUtil.getAccountingDataMigrationRec(objNameToExport);
		Last_Synched_Date = dataMigration.Last_Synched_Date__c;
		dataMigration = DataExportUtil.getDateRange(timePeriod, Last_Synched_Date, fromDate, toDate, new List<Accounting_Data_Migration__c>{dataMigration});
    	dataMigration.Last_Synched_Date__c = Datetime.now();
    	//upsert dataMigration;
    	
		if(AccessControl.ifObjectFieldIsAccessible('CO_Deposit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	query = DataExportUtil.createQuery(recordIds, 'Id', this.timePeriodForFilter, Last_Synched_Date, fromDate, toDate, 'CO_Deposit__c');
	}
	
	/**
     * Name: start
     * Desc: Batch start method - Create query and execute query locator
     * @param: 
     * @return: Database.QueryLocator
    **/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}
	
	/**
     * Name: execute
     * Desc: Batch execute method to process the exported data records
     * @param:	1. Database.BatchableContext BC
     * 			2. List<sObject> scope
     * @return:
    **/
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<CO_Deposit__c> coDeposits = (List<CO_Deposit__c>) scope;
		if(coDeposits.size() > 0) {
	    	Map<Integer, Map<String,String>> coDepositRecords = new Map<Integer, Map<String, String>>();
	    	
	    	// For each co deposit account, create a ReceiveMoneyTxn entry:
	    	for(CO_Deposit__c coDeposit : coDeposits){
	    		recordCount++;
	    		coDepositRecords.put(indexVal++, createReceiveMoneyTxnRecordFromDeposit(coDeposit, false));
	    		coDepositRecords.put(indexVal++, createReceiveMoneyTxnRecordFromDeposit(coDeposit, true));
	    		coDepositRecords.put(indexVal++, new Map<String,String>());
	    	}
	    	
	    	// Now create a string for list of ReceiveMoneyTxn records so as to convert in format of importable text file for accounting software
    		depositsTextData += DataExportUtil.createImportableText(coDepositRecords, this.objName);
    		depositsTextData = (depositsTextData.indexOf('{') != -1) ? depositsTextData.subString(depositsTextData.indexOf('{')) : depositsTextData;
    	}
	}
	
	/**
     * Name: finish
     * Desc: Batch finish method to insert a attachment for exported data in text file
     * @param:	1. Database.BatchableContext BC
     * @return:
    **/
	global void finish(Database.BatchableContext BC) {
		if(AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
		if(AccessControl.ifObjectFieldIsUpdateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
		
    	dataMigration.Records_Processed__c = recordCount;
		upsert dataMigration;
		
		if(dataMigration.Records_Processed__c > 0) {
			if(AccessControl.ifObjectFieldIsCreateable('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	    	insert DataExportUtil.createAttachment(depositsTextData, 'RECEIVEMONEY_DEPOSIT_', dataMigration, recordCount);
    	}
	}
	
    /**
     * Name: createReceiveMoneyTxnRecordFromDeposit
     * Desc: Method to create a ReceiveMoneyTxn record by codeposit record. ReceiveMoneyTxn record is a map of field name to equivalent value for field
     * @param: CO_Deposit__c coDeposit, Map<String, String> depositToGLAccountMap
     * @return: Map<String, String>
    **/
    private static Map<String, String> createReceiveMoneyTxnRecordFromDeposit(CO_Deposit__c coDeposit, Boolean isReverseEntry) {
    	Map<String, String> receiveMoneyTxn = new Map<String, String>();
    	receiveMoneyTxn.put('Amount__c', ((coDeposit.Amount__c < 0) ? '-$': '$') + ((coDeposit.Amount__c < 0) ? (coDeposit.Amount__c * -1) : coDeposit.Amount__c));
    	receiveMoneyTxn.put('Date__c', DateTimeUtility.getDateTimeFromDate(coDeposit.Payment_Date__c).format(DataExportService.dateFormat));
    	receiveMoneyTxn.put('Memo__c', coDeposit.Name + ' - ' + coDeposit.CO_Header__r.Name + ' - ' + coDeposit.CO_Header__r.Customer_Name__c);
    	receiveMoneyTxn.put('Payment_Method__c', coDeposit.Payment_Method__c);
    	receiveMoneyTxn.put('Name_On_Card__c', '');
    	if(coDeposit.CO_Header__r.Customer__c != null) {
    		if(coDeposit.CO_Header__r.Customer__r.Type__c == 'Individual') {
    			receiveMoneyTxn.put('First_Name__c', coDeposit.CO_Header__r.Customer__r.FirstName__c);
    			receiveMoneyTxn.put('Last_Name__c', coDeposit.CO_Header__r.Customer__r.LastName__c);
    		} else {
    			receiveMoneyTxn.put('Last_Name__c', coDeposit.CO_Header__r.Customer__r.Name);
    		}
    		receiveMoneyTxn.put('Card_ID__c', coDeposit.CO_Header__r.Customer__r.Customer_Number__c);
    	} else {
    		if(coDeposit.CO_Header__r.CO_Type__c == 'Cash Sale') {
    			receiveMoneyTxn.put('Last_Name__c', 'CASH SALE');
	    		receiveMoneyTxn.put('Card_ID__c', cashCustomerId);
    		} else if(coDeposit.CO_Header__r.CO_Type__c == 'Internal Service') {
    			receiveMoneyTxn.put('Last_Name__c', 'UNIT INVENTORY');
	    		receiveMoneyTxn.put('Card_ID__c', internalServiceCustomerId);
    		}
    	}
        
    	if(!isReverseEntry) {
    		if(coDeposit.Payment_Method__c == 'Store Credit') {
    			receiveMoneyTxn.put('Deposit_Account__c', storeCreditAccrualGLCode);
    		}else if(coDeposit.Payment_Method__c == 'Direct Deposit') {
    			receiveMoneyTxn.put('Deposit_Account__c', undepositedDirectDepositGLCode);
    		} else if(coDeposit.Payment_Method__c == 'Financing' || coDeposit.Payment_Method__c == 'Financed') {
    			receiveMoneyTxn.put('Deposit_Account__c', undepositedFinancingGLCode);
    		} else {
    			receiveMoneyTxn.put('Deposit_Account__c', undepositedFundsGLCode);
    		}
    		receiveMoneyTxn.put('Allocation_Account_No__c', '');
    	} else {
    		receiveMoneyTxn.put('Deposit_Account__c', '');
    		receiveMoneyTxn.put('Allocation_Account_No__c', customerDepositGLCode);
    	}
    	return receiveMoneyTxn;
    }
}