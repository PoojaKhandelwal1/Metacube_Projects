/**
 * Author: Ashish Garg
 * Since: Dec. 23, 2015
 * Name: AccountingDataMigrationPayment
 * Description: Class is used for migration of Payment records to  Accounting Software
**/
global with sharing class AccountingDataMigrationPayment implements Database.batchable<sObject>,Database.Stateful {
	
	global AccountingDataMigrationPayment() {}
	global AccountingDataMigrationPayment(List<Id> recordIds, boolean exportAllData) {}
	global AccountingDataMigrationPayment(List<Id> recordIds, boolean exportAllData, String timePeriod, DateTime fromDate, DateTime toDate) {}
	
	private String objName = 'CO_Invoice_Payment__c';
	private String paymentsTextData = '';
	private integer indexVal = 1;
	private integer recordCount = 0;
	private string query;  
	private DateTime Last_Synched_Date;
	private String timePeriodForFilter;
	private DateTime fromDate;
	private DateTime toDate;
	private Boolean isFirstTimeRun;
	private	Accounting_Data_Migration__c dataMigration;
	private static String undepositedFundsGLCode = AccountingUtil.getChartofAccount('Undeposited Funds');
	private static String customerDepositGLCode = AccountingUtil.getChartofAccount('Customer Deposits');
	private static String storeCreditAccrualGLCode = AccountingUtil.getChartofAccount('Store Credit Accrual');
	private static String storeCreditExpenseGLCode = AccountingUtil.getChartofAccount('Store Credit Expense');
	private static String cashRoundingGLCode = AccountingUtil.getChartofAccount('Cash Rounding');
	private static String cashCustomerId = AccountingUtil.getChartofAccount('Cash Sale Customer');
	private static String internalServiceCustomerId = AccountingUtil.getChartofAccount('Internal Service Customer');
	private static String undepositedDirectDepositGLCode = AccountingUtil.getChartofAccount('Undeposited Direct Deposit');
	private static String undepositedFinancingGLCode = AccountingUtil.getChartofAccount('Undeposited Financing');
	
	
	/**
     * Name: executePaymentsDataMigrationBatch
     * Desc: Method to initiate the payments export
     * @param: 
     * @return: Id
    **/
	public static Id executePaymentsDataMigrationBatch(Integer batchSize, List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
		Id batchId = Database.executeBatch(new AccountingDataMigrationPayment(recordIds, timePeriod, fromDate, toDate, objNameToExport), batchSize);
		return batchId;
	}
	
	/**
     * Name: AccountingDataMigrationPayment
     * Desc: Constructor to start the batch for data export
    **/
	global AccountingDataMigrationPayment(List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
		if(AccessControl.ifObjectFieldIsAccessible('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		if(AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
		if(AccessControl.ifObjectFieldIsUpdateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
		
		this.timePeriodForFilter = timePeriod;
		this.fromDate = fromDate;
		this.toDate = toDate; 
    	dataMigration = DataExportUtil.getAccountingDataMigrationRec(objNameToExport); 
		Last_Synched_Date = dataMigration.Last_Synched_Date__c;
    	dataMigration.Last_Synched_Date__c = Datetime.now();
    	dataMigration = DataExportUtil.getDateRange(timePeriod, Last_Synched_Date, fromDate, toDate,new List<Accounting_Data_Migration__c>{dataMigration});
    	upsert dataMigration;
    	isFirstTimeRun = true;
		if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	query = DataExportUtil.createQuery(recordIds, 'Id', this.timePeriodForFilter, Last_Synched_Date, fromDate, toDate, 'CO_Invoice_Payment__c');
	}
	
	/**
     * Name: start
     * Desc: Batch start method - Create query and execute query locator
     * @param: 
     * @return: Database.QueryLocator
    **/
	global Iterable<Sobject> start(Database.BatchableContext BC) {
		String storeCreditQuery = DataExportUtil.createQuery(null, null, this.timePeriodForFilter, Last_Synched_Date, fromDate, toDate, 'Store_Credit__c');
		return getRecords(query, storeCreditQuery);
	}
	
	private List<Sobject> getRecords(String query, String query1) {
		List<SObject> sObjectList = new List<SObject>();
		List<sObject> resultList = Database.query(query);
		if(resultList.size() > 0) {
			sObjectList.addAll(resultList);
		}
		resultList = Database.query(query1);
		if(resultList.size() > 0) {
			sObjectList.addAll(resultList);
		}
		return sObjectList;
	}
	 
	/**
     * Name: execute
     * Desc: Batch execute method to process the exported data records
     * @param:	1. Database.BatchableContext BC
     * 			2. List<sObject> scope
     * @return:
    **/
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		//List<CO_Invoice_Payment__c> coPayments = (List<CO_Invoice_Payment__c>) scope;
		Map<Integer, Map<String,String>> coPaymentRecords = new Map<Integer, Map<String, String>>();
		if(scope.size() > 0) {
			for(Sobject sobj : scope) {
				Id recordId = String.valueOf(sobj.get('Id'));
				recordCount++;
				if(recordId.getSObjectType().getDescribe().getName() == Constants.Namespace + 'CO_Invoice_Payment__c') {
					CO_Invoice_Payment__c coInvoicePayment = (CO_Invoice_Payment__c)sobj;
		    		coPaymentRecords.put(indexVal++, createReceiveMoneyTxnRecordFromPayment(coInvoicePayment, false));
		    		coPaymentRecords.put(indexVal++, createReceiveMoneyTxnRecordFromPayment(coInvoicePayment, true));
		    		coPaymentRecords.put(indexVal++, new Map<String,String>());
		    		
				} else if(recordId.getSObjectType().getDescribe().getName() == Constants.Namespace + 'Store_Credit__c'){
					Store_Credit__c storeCreditRec = (Store_Credit__c)sobj;
					coPaymentRecords.put(indexVal++, createReceiveMoneyTxnRecordFromStoreCredit(storeCreditRec, false));
		    		coPaymentRecords.put(indexVal++, createReceiveMoneyTxnRecordFromStoreCredit(storeCreditRec, true));
		    		coPaymentRecords.put(indexVal++, new Map<String,String>());
				}
			}
			paymentsTextData += DataExportUtil.createImportableText(coPaymentRecords, this.objName);
    		paymentsTextData = (paymentsTextData.indexOf('{') != -1) ? paymentsTextData.subString(paymentsTextData.indexOf('{')) : paymentsTextData;
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
	    	insert DataExportUtil.createAttachment(paymentsTextData, 'RECEIVEMONEY_PAYMENT_', dataMigration, recordCount);
    	}
	}
    
    /**
     * Name: createReceiveMoneyTxnRecordFromPayment
     * Desc: Method to create a ReceiveMoneyTxn record by copayment record. ReceiveMoneyTxn record is a map of field name to equivalent value for field
     * @param: CO_Invoice_Payment__c coInvoicePayment
     * @return: Map<String, String>
    **/
    private Map<String, String> createReceiveMoneyTxnRecordFromPayment(CO_Invoice_Payment__c coInvoicePayment, Boolean isReverseEntry) {
    	Map<String, String> receiveMoneyTxn = new Map<String, String>();
    	receiveMoneyTxn.put('Amount__c', ((coInvoicePayment.Amount__c < 0) ? '-$': '$') + ((coInvoicePayment.Amount__c < 0) ? (coInvoicePayment.Amount__c * -1) : coInvoicePayment.Amount__c));
    	receiveMoneyTxn.put('Date__c', DateTimeUtility.getDateTimeFromDate(coInvoicePayment.Payment_Date__c).format(DataExportService.dateFormat));
    	receiveMoneyTxn.put('Memo__c', coInvoicePayment.Name + ' - ' + coInvoicePayment.CO_Invoice_Header__r.CO_Header__r.Name + ' - ' + coInvoicePayment.CO_Invoice_Header__r.CO_Header__r.Customer_Name__c);
    	receiveMoneyTxn.put('Payment_Method__c', coInvoicePayment.Payment_Method__c);
    	receiveMoneyTxn.put('Name_On_Card__c', '');
    	if(coInvoicePayment.CO_Invoice_Header__r.CO_Header__r.Customer__c != null) {
    		if(coInvoicePayment.CO_Invoice_Header__r.CO_Header__r.Customer__r.Type__c == 'Individual') {
    			receiveMoneyTxn.put('First_Name__c', coInvoicePayment.CO_Invoice_Header__r.CO_Header__r.Customer__r.FirstName__c);
    			receiveMoneyTxn.put('Last_Name__c', coInvoicePayment.CO_Invoice_Header__r.CO_Header__r.Customer__r.LastName__c);
    		} else {
    			receiveMoneyTxn.put('Last_Name__c', coInvoicePayment.CO_Invoice_Header__r.CO_Header__r.Customer__r.Name);
    		}
    		receiveMoneyTxn.put('Card_ID__c', coInvoicePayment.CO_Invoice_Header__r.CO_Header__r.Customer__r.Customer_Number__c);
    	} else {
    		if(coInvoicePayment.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Cash Sale') {
    			receiveMoneyTxn.put('Last_Name__c', 'CASH SALE');
	    		receiveMoneyTxn.put('Card_ID__c', cashCustomerId);
    		} else if(coInvoicePayment.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Internal Service') {
    			receiveMoneyTxn.put('Last_Name__c', 'UNIT INVENTORY');
	    		receiveMoneyTxn.put('Card_ID__c', internalServiceCustomerId);
    		}
    	}
    	if(!isReverseEntry) {
    		if(coInvoicePayment.Payment_Method__c == 'Cash Rounding') {
    			receiveMoneyTxn.put('Deposit_Account__c', cashRoundingGLCode);
    		} else if(coInvoicePayment.Payment_Method__c == 'Store Credit') {
    			receiveMoneyTxn.put('Deposit_Account__c', storeCreditAccrualGLCode);
    		} else if(coInvoicePayment.Payment_Method__c == 'Direct Deposit') {
    			receiveMoneyTxn.put('Deposit_Account__c', undepositedDirectDepositGLCode);
    		} else if(coInvoicePayment.Payment_Method__c == 'Financing' || coInvoicePayment.Payment_Method__c == 'Financed') {
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
    
    private Map<String, String> createReceiveMoneyTxnRecordFromStoreCredit(Store_Credit__c storeCreditRec, Boolean isReverseEntry) {
    	Map<String, String> receiveMoneyTxn = new Map<String, String>();
    	receiveMoneyTxn.put('Amount__c', ((storeCreditRec.Amount__c < 0) ? '-$': '$') + ((storeCreditRec.Amount__c < 0) ? (storeCreditRec.Amount__c * -1) : storeCreditRec.Amount__c));
    	receiveMoneyTxn.put('Date__c', storeCreditRec.CreatedDate.format(DataExportService.dateFormat));
    	receiveMoneyTxn.put('Memo__c', storeCreditRec.Name + ' - ' + storeCreditRec.Customer__r.Name);
    	receiveMoneyTxn.put('Payment_Method__c', '');
    	receiveMoneyTxn.put('Name_On_Card__c', '');
		if(storeCreditRec.Customer__r.Type__c == 'Individual') {
			receiveMoneyTxn.put('First_Name__c', storeCreditRec.Customer__r.FirstName__c);
			receiveMoneyTxn.put('Last_Name__c', storeCreditRec.Customer__r.LastName__c);
		} else {
			receiveMoneyTxn.put('Last_Name__c', storeCreditRec.Customer__r.Name);
		}
		receiveMoneyTxn.put('Card_ID__c', storeCreditRec.Customer__r.Customer_Number__c);
		
    	if(!isReverseEntry) {
    		receiveMoneyTxn.put('Deposit_Account__c', storeCreditExpenseGLCode);
    		receiveMoneyTxn.put('Allocation_Account_No__c', '');
    	} else {
    		receiveMoneyTxn.put('Deposit_Account__c', '');
    		receiveMoneyTxn.put('Allocation_Account_No__c', storeCreditAccrualGLCode);
    	}
    	return receiveMoneyTxn;
    }
}