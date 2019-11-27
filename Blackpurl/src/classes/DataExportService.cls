/**
 * Author: Ashish Garg
 * Since: Dec. 18, 2015
 * Name: DataExportService
 * Description: Service class used to export salesforce data 
**/
global with sharing class DataExportService {
	// Date Format for data in file
	public static String dateFormat = 'dd/MM/yyyy';
	public String objectName {get; set;}
	
	/**
     * Name: exportAccountingData
     * Desc: Method to export salesforce object data to appropriate "Accounting Data Migration" attachment
     * @param: String objectName - depending on object name, exported data file will be attachned in "Accounting Data Migration" record
     * @return:
    **/
    public PageReference exportAccountingData() {
    	Id batchId;
    	objectName = String.escapeSingleQuotes(objectName);
    	if(objectName == '') {
    		batchId = AccountingDataMigrationCustomers.executeCardsDataMigrationBatch(200, null, null, null, null, DataExportUtil.CUSTOMERS_ACCOUNTING_OBJECT_NAME);
    	}
    	return null;
    }
    
    /**
     * Name: exportAccountingData
     * Desc: Method to export salesforce object data to appropriate "Accounting Data Migration" attachment
     * @param: String objectName - depending on object name, exported data file will be attachned in "Accounting Data Migration" record
     * @return:
    **/
    public PageReference exportAccountingData(List<String> objectNames, String timePeriod, DateTime fromDate, DateTime toDate) {
    	Id batchId, batchId1;
    	objectName = String.escapeSingleQuotes(objectName);
    	for(String objName: objectNames) {
	    	if(objName == DataExportUtil.CUSTOMERS_ACCOUNTING_OBJECT_NAME || objName == DataExportUtil.VENDORS_ACCOUNTING_OBJECT_NAME){
	    		batchId = AccountingDataMigrationCustomers.executeCardsDataMigrationBatch(200, null, timePeriod, fromDate, toDate, objName); 
	    	} else if(objName == DataExportUtil.DEPOSITS_ACCOUNTING_OBJECT_NAME){
	    		batchId = AccountingDataMigrationDeposits.executeDepositsDataMigrationBatch(200, null, timePeriod, fromDate, toDate, objName); 
	    		batchId1 = AccountingDataMigrationPayment.executePaymentsDataMigrationBatch(200, null, timePeriod, fromDate, toDate, objName);
	    	} else if(objName == DataExportUtil.SALES_INVOICE_ACCOUNTING_OBJECT_NAME){
	    		batchId = MYOBSalesInvoice.executeDataMigrationBatch(200, null, timePeriod, fromDate, toDate, objName);
	    	} else if(objName == DataExportUtil.VENDOR_RECEIVING_ACCOUNTING_OBJECT_NAME){
	    		batchId = AccDataMigrationvendorReceiving.executeDataMigrationBatch(200, null, timePeriod, fromDate, toDate, objName);
	    	} else if(objName == DataExportUtil.VENDOR_INVOICING_ACCOUNTING_OBJECT_NAME){
	    		batchId = AccountingDataMigrationVI.executeDataMigrationBatch(200, null, timePeriod, fromDate, toDate, objName);
	    	}
    	}
    	return null;
    }
    
    /**
     * Name: getExportedDataList
     * Desc: Method to get the exported data list for all accounting records 
     * @param:
     * @return:
    **/
    public List<ExportedData> getExportedDataList(){
    	if(AccessControl.ifObjectFieldIsAccessible('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<ExportedData> exportedFiles = new List<ExportedData>();
    	for(Accounting_Data_Migration__c adm : [Select Id, Object_Name__c, Last_Synched__c, (Select Id, Name, CreatedDate From Attachments) from Accounting_Data_Migration__c LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]){
    		exportedFiles.add(new ExportedData(adm) );
    	}
    	return exportedFiles;
    }
    
    // Wrapper class to hold the type of record and list of exported files attachment
    public class ExportedData {
    	public String objectName;
    	public List<Attachment> exportedFiles;
    	
    	/**
	     * Name: ExportedData
	     * Desc: Constructor which takes a Accounting Data Export record and populate values
	    **/
    	public ExportedData(Accounting_Data_Migration__c adm) {
    		objectName		= adm.Object_Name__c;
    		exportedFiles	= new List<Attachment>();
    		for(Attachment att : adm.Attachments){
    			if(att.CreatedDate >= adm.Last_Synched__c){
    				exportedFiles.add(att);
    			}
    		}
    	}
    }
}