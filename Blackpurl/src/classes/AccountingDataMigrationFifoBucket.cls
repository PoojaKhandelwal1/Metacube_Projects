global with sharing class AccountingDataMigrationFifoBucket implements Database.batchable<sObject>,Database.Stateful {
	
	global AccountingDataMigrationFifoBucket() {}
	global AccountingDataMigrationFifoBucket(List<Id> recordIds, boolean exportAllData) {}
	global AccountingDataMigrationFifoBucket(List<Id> recordIds, boolean exportAllData, String timePeriod, DateTime fromDate, DateTime toDate) {}
	/*
	private String objName = 'Part_FIFO_Bucket__c';
	private String value = '';
	private Integer totalRecords = 0; 
	private String query;
	private DateTime Last_Synched_Date;
	private String timePeriodForFilter;
	private DateTime fromDate;
	private DateTime toDate;
	private Accounting_Data_Migration__c dataMigration;
	
	/**
     * Name: executeDataMigrationBatch
     * Desc: method to start the batch for data export
    **
	public static Id executeDataMigrationBatch(Integer batchSize, List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
		Id batchId = Database.executeBatch(new AccountingDataMigrationFifoBucket(recordIds, timePeriod, fromDate, toDate, objNameToExport), batchSize);
		return batchId;
	}
	
	/**
     * Name: AccountingDataMigrationFifoBucket
     * Desc: Constructor to start the batch for data export
    **/
	global AccountingDataMigrationFifoBucket(List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
		/*if(AccessControl.ifObjectFieldIsAccessible('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		if(AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
		if(AccessControl.ifObjectFieldIsUpdateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
		
		this.timePeriodForFilter = timePeriod;
		this.fromDate = fromDate;
		this.toDate = toDate;
		dataMigration = DataExportUtil.getAccountingDataMigrationRec(objNameToExport);
		Last_Synched_Date = dataMigration.Last_Synched_Date__c;
		dataMigration = DataExportUtil.getDateRange(timePeriod, Last_Synched_Date, fromDate, toDate, dataMigration);
		dataMigration.Last_Synched_Date__c = Datetime.now();
    	upsert dataMigration;
    	
    	if(AccessControl.ifObjectFieldIsAccessible('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('Part_FIFO_Bucket_Activity_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	query = DataExportUtil.createQuery(recordIds, 'Id', this.timePeriodForFilter, Last_Synched_Date, fromDate, toDate, this.objName);*/
	}
	
	/**
     * Name: start
     * Desc: Batch start method - Create query and execute query locator
     * @param: 
     * @return: Database.QueryLocator
    **/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = '';
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
		/*value = '{}\n';
		for(String fieldNameStr : DataExportUtil.objNameToOrderedCardFieldMap.get(this.objName)) {
			value += DataExportUtil.objNameToCardSFFieldToAccountingFieldsMap.get(this.objName).get(fieldNameStr) + DataExportUtil.fileSeparator;
		}
		value = value.subString(0, value.length()-1);
		value += '\n';
		List<Part_FIFO_Bucket__c> partFifoRecords = (List<Part_FIFO_Bucket__c>)scope;
		
		if(partFifoRecords.size() > 0) {
		    for(Part_FIFO_Bucket__c partFIFOBucketItem : partFifoRecords) {
		    	if(String.isBlank(partFIFOBucketItem.Reference__c) && String.isNotBlank(partFIFOBucketItem.Source_Name__c) &&
		    									partFIFOBucketItem.Source_Name__c.toLowerCase() == 'oversold') {
		    		totalRecords++;
		    		value += AccountingPartFIFOWrapper.AccountingPartFIFOWrapperRec(partFIFOBucketItem) + '\n\n';	
		    	
		    	} else if(partFIFOBucketItem.Is_FIFO_Bucket__c && partFIFOBucketItem.Reference__c.toLowerCase().indexOf('Count Adjustment'.toLowerCase()) != -1) {
		    		totalRecords++;
		        	value += AccountingPartFIFOWrapper.AccountingPartFIFOWrapperRec(partFIFOBucketItem) + '\n\n';
		        	for(Part_FIFO_Bucket_Activity_Line_Item__c fifoActivityRec : partFIFOBucketItem.Part_FIFO_Bucket_Activity_Line_Items__r ){
		        		if(String.isNotBlank(fifoActivityRec.Reference__c) && fifoActivityRec.Reference__c.toLowerCase().indexOf('Count Adjustment'.toLowerCase()) != -1){
		        			totalRecords++;
			        		value += AccountingPartFIFOWrapper.PartFIFOActivityLineItemRec(fifoActivityRec, partFIFOBucketItem) + '\n\n';
		        		}
		        	}
		    	} else if(partFIFOBucketItem.Is_FIFO_Bucket__c && (partFIFOBucketItem.Reference__c.toLowerCase().indexOf('re'.toLowerCase()) != -1) || (partFIFOBucketItem.Reference__c.toLowerCase().indexOf('Cost Adjustment'.toLowerCase()) != -1)){
		    		totalRecords++;
		    		value += AccountingPartFIFOWrapper.AccountingPartFIFOWrapperCostRec(partFIFOBucketItem) + '\n\n';
		        	for(Part_FIFO_Bucket_Activity_Line_Item__c  activityRec : partFIFOBucketItem.Part_FIFO_Bucket_Activity_Line_Items__r ){
		        		if(String.isNotBlank(activityRec.Reference__c)&& ((activityRec.Reference__c.toLowerCase().indexOf('Cost Adjustment'.toLowerCase()) != -1) || (activityRec.Reference__c.toLowerCase().indexOf('Pre'.toLowerCase()) != -1))){
		        			totalRecords++;
			        		value += AccountingPartFIFOWrapper.PartFIFOActivityCostLineItemRec(activityRec,partFIFOBucketItem) + '\n\n';
		        		}
		        	}
		    	}  
	    	}
		}
		String query = DataExportUtil.createQuery(null, null, this.timePeriodForFilter, Last_Synched_Date, fromDate, toDate, 'Part_FIFO_Bucket_Activity_Line_Item__c');
    	List<Part_FIFO_Bucket_Activity_Line_Item__c> adjustRec = Database.query(query);
	    
	    if(adjustRec.size() > 0) {
	    	for(Part_FIFO_Bucket_Activity_Line_Item__c activityRec : adjustRec) {
	    		if(activityRec.Reference__c == 'Cost Adjustment') {
	    			totalRecords++;
	        		value += AccountingPartFIFOWrapper.PartFIFOActivityCostAdjustItemRec(activityRec) + '\n\n';
	    		} else if(activityRec.Reference__c == 'Count Adjustment' || activityRec.CO_Invoice_Header__c != null || activityRec.Return_VO_Header__c != null) {
	    			totalRecords++;
	        		value += AccountingPartFIFOWrapper.PartFIFOActivityCountAdjustItemRec(activityRec) + '\n\n';
	    		}
	    	}
		}*/
	}
	
	/**
     * Name: finish 
     * Desc: Batch finish method to insert a attachment for exported data in text file
     * @param:	1. Database.BatchableContext BC
     * @return:
    **/
	global void finish(Database.BatchableContext BC) {
    	/*dataMigration.Records_Processed__c = totalRecords;
    	upsert dataMigration;
    	
    	if(dataMigration.Records_Processed__c > 0) {
	    	if(AccessControl.ifObjectFieldIsCreateable('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	    	insert DataExportUtil.createAttachment(value, 'GENERAL_JOURNAL_COUNT_COST_ADJUSTMENT_', dataMigration, totalRecords);
    	}*/
	}
}