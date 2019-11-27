global with sharing class AccountingExportCtrl {
    
    global AccountingExportCtrl (NewHomePageCtrl controller){}
    public AccountingExportCtrl() {}
    
    @remoteAction 
    global static String getPreviousExportDetails() {
    	if(AccessControl.ifObjectFieldIsAccessible('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Accounting_Data_Migration__c> accountingDataMigrationList = [select Object_Name__c, MYOB_Object_Name__c, 
        																Last_Synched_Date__c, Last_Synched__c, Records_Processed__c, Start_Date__c, End_Date__c
        																from Accounting_Data_Migration__c LIMIT : SOQLUtil.getAvailableQueryRowsLimit()]; // Changed Added by richa 31 march, where Object_Name__c != 'ReceiveMoneyTxn_Payment' Removed by richa 1 april
        																
        Integer totalRecordsForDepositAndPayment = 0;
        for(Accounting_Data_Migration__c ADM : accountingDataMigrationList) {  // Added by richa 1 april
        	if(ADM.Object_Name__c == 'ReceiveMoneyTxn_Deposit' || ADM.Object_Name__c == 'ReceiveMoneyTxn_Payment') {
        		totalRecordsForDepositAndPayment += (ADM.Records_Processed__c == null ? 0 : Integer.valueOf(ADM.Records_Processed__c));
        	}
        }
        
        List<AccountingDataMigrationWrapper> accountingDMWrapperList = new List<AccountingDataMigrationWrapper>();
        for(Accounting_Data_Migration__c ADM : accountingDataMigrationList){
        	accountingDMWrapperList.add(new AccountingDataMigrationWrapper(ADM));
        }
        for(AccountingDataMigrationWrapper ADM : accountingDMWrapperList){ // Added by richa 1 april
        	if(ADM.ObjectName == 'Money Received') {
        		ADM.NoOfRecords = totalRecordsForDepositAndPayment;
        	}
        }
        return BPUtility.getEncodedString(System.JSON.serialize(accountingDMWrapperList));
    }
    
    @remoteAction 
    global static String processExport(String exportDataJSON, String selectedFilter, String fromDate, String toDate) {
    	exportDataJSON = BPUtility.getDecodedString(exportDataJSON);
    	selectedFilter = BPUtility.getDecodedString(selectedFilter);
    	fromDate = BPUtility.getDecodedString(fromDate);
    	toDate = BPUtility.getDecodedString(toDate);
    	
    	List<AccountingDataMigrationWrapper> accountingDataList = new List<AccountingDataMigrationWrapper>();
        accountingDataList = (List<AccountingDataMigrationWrapper>)System.JSON.deserialize(exportDataJSON, List<AccountingDataMigrationWrapper>.class);
    	List<String> objectNames = new List<String>();
    	for(AccountingDataMigrationWrapper accData: accountingDataList) {
			if(accData.isRadioButtonSelected) {
				objectNames.add(objectNameToExportDisplayObjectNameMap.get(accData.ObjectName));
			}  		
    	}
        DataExportService DES = new DataExportService();
        DES.objectName = '';
        DES.exportAccountingData(objectNames, filterNameToDateMap.get(selectedFilter), getDateFromString(fromDate), getDateFromString(toDate));
        return BPUtility.getEncodedString('Export Data scheduled successfully');
    }
    
    @remoteAction 
    global static String getTimePeriodForExport() {
    	if(AccessControl.ifObjectFieldIsAccessible('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Accounting_Data_Migration__c> accountingDataMigrationList = [select Object_Name__c, Last_Synched_Date__c from Accounting_Data_Migration__c LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
    	DateTime CustomerLastExportDate, VendorLastExportDate, MoneyReceivedLastExportDate, CustomerInvoiceLastExportDate;
    	DateTime VendorInvoiceLastExportDate, JournalEntryLastExportDate;
    	
    	for(Accounting_Data_Migration__c adm: accountingDataMigrationList) {
    		if(ADM.Object_Name__c == 'Customers Card'){
    			CustomerLastExportDate = adm.Last_Synched_Date__c;
    		}else if(ADM.Object_Name__c == 'ReceiveMoneyTxn_Deposit'){
    			MoneyReceivedLastExportDate = adm.Last_Synched_Date__c;
    		}else if(ADM.Object_Name__c == 'Customer Order Sales Invoices'){
    			CustomerInvoiceLastExportDate = adm.Last_Synched_Date__c;
    		}else if(ADM.Object_Name__c == 'Supplier Card'){
    			VendorLastExportDate = adm.Last_Synched_Date__c;
    		}else if(ADM.Object_Name__c == 'General Journal Entries'){
    			JournalEntryLastExportDate = adm.Last_Synched_Date__c;
    		}else if(ADM.Object_Name__c == 'Vendor Invoicing'){
    			VendorInvoiceLastExportDate = adm.Last_Synched_Date__c;
    		}
    	}
    	AccountingExportTimePeriodWrapper accExportTimePeriod = new AccountingExportTimePeriodWrapper(CustomerLastExportDate, VendorLastExportDate, 
																								MoneyReceivedLastExportDate, CustomerInvoiceLastExportDate,
																								VendorInvoiceLastExportDate, JournalEntryLastExportDate);
        return BPUtility.getEncodedString(JSON.serialize(accExportTimePeriod));
    }
    
    /**
     * Name: createQuery
     * Desc: Method to create a query string for customer orders
     * @param: 
     * @return: String
    **/
	private static String getDateRange(DateTime lastExportDate, String timePeriodForFilter) {
    	String dateRange = ' ';
    	Date startDate, endDate;
    	Date todayDate = Date.today();
		
    	if(timePeriodForFilter == 'ALL_SINCE_LAST_EXORTED') {
    		if(lastExportDate != null) {
    			DateTime Last_Synched_Date = lastExportDate;
    			startDate =  date.newinstance(Last_Synched_Date.year(), Last_Synched_Date.month(), Last_Synched_Date.day());
    			endDate = todayDate;
    		}
    	} else if(timePeriodForFilter == 'THIS_WEEK') {
    		startDate = todayDate.toStartofWeek();
    		endDate = todayDate;
    	} else if(timePeriodForFilter == 'THIS_MONTH') {
    		startDate = todayDate.toStartOfMonth();
    		endDate = todayDate;
    	} else if(timePeriodForFilter == 'LAST_WEEK') {
    		Date startDateOfWeek = todayDate.toStartofWeek();
    		startDate = startDateOfWeek.addDays(-7);
    		endDate = startDate.addDays(6);
    	} else if(timePeriodForFilter == 'LAST_MONTH') {
    		Integer lastMonthNumber = todayDate.month() - 1;
    		if(lastMonthNumber == 0) {
    			lastMonthNumber = 12;
    			startDate = Date.newInstance(todayDate.year() - 1, lastMonthNumber, 1);
	    		Integer noOfDays = Date.daysInMonth(todayDate.year() - 1, lastMonthNumber);
				endDate = Date.newInstance(todayDate.year() - 1, lastMonthNumber, noOfDays);
    		} else {
    			startDate = Date.newInstance(todayDate.year(), lastMonthNumber, 1);
	    		Integer noOfDays = Date.daysInMonth(todayDate.year(), lastMonthNumber);
				endDate = Date.newInstance(todayDate.year(), lastMonthNumber, noOfDays);
    		}
    	}
    	Datetime start_dt, end_dt;
    	if(startDate != null) {
			start_dt = datetime.newInstance(startDate.year(), startDate.month(), startDate.day());
		}
		if(endDate != null) {
			end_dt = datetime.newInstance(endDate.year(), endDate.month(), endDate.day());
		}
    	return (start_dt != null && end_dt != null) ? BPUtility.getExportFormatedDateTime(start_dt) + ' through ' + BPUtility.getExportFormatedDateTime(end_dt) : '';
	}
	
    /**
     * Name: getDateFromString
     * Desc: Getting Date From Given String 
     * @param:  (1) dtStr - String  - Date String
     * @return: DateTime- DateTime Object
     **/	
	private static DateTime getDateFromString(String dtStr) {
		String dateFormat = BPUtility.getDateFormat();
 		List<String> dateFormatCharacter = dateFormat.split('/');
 		Integer dayIndex, monthIndex, yearIndex;
		for(Integer index = 0; index < dateFormatCharacter.size(); index++ ){
			if(dateFormatCharacter[index].contains('dd')) {
				dayIndex = index;
			} else if(dateFormatCharacter[index].contains('mm')) {
				monthIndex = index;
			} else if(dateFormatCharacter[index].contains('yy')) {
				yearIndex = index;
			}
		}
		Integer day = (dtStr != '') ?Integer.valueOf(dtStr.split('/')[dayIndex]): 0;
		Integer month = (dtStr != '') ?Integer.valueOf(dtStr.split('/')[monthIndex]): 0;
		Integer year = (dtStr != '') ?Integer.valueOf(dtStr.split('/')[yearIndex]): 0;
		return datetime.newInstance(year, month, day, 0, 0 , 0);
	}
    
    public class AccountingDataMigrationWrapper {
    	public String ObjectName;
    	public String LastExport;
    	public String DateRange;
    	public Integer NoOfRecords;
    	public boolean isRadioButtonSelected; 
    	
    	public AccountingDataMigrationWrapper(Accounting_Data_Migration__c ADM){
    		if(ADM.Object_Name__c == 'Customers Card'){
    			this.ObjectName = 'Customers';
    		}else if(ADM.Object_Name__c == 'ReceiveMoneyTxn_Deposit'){
    			this.ObjectName = 'Money Received';
    		}else if(ADM.Object_Name__c == 'Customer Order Sales Invoices'){
    			this.ObjectName = 'Customer Invoices';
    		}else if(ADM.Object_Name__c == 'Supplier Card'){
    			this.ObjectName = 'Vendors';
    		}else if(ADM.Object_Name__c == 'General Journal Entries'){
    			this.ObjectName = 'Journal Entries';
    		}else if(ADM.Object_Name__c == 'Vendor Invoicing'){
    			this.ObjectName = 'Vendor Invoices';
    		}
    		if(ADM.Last_Synched_Date__c != null){
    			this.LastExport = ADM.Last_Synched_Date__c.format('yyyy/MM/dd @ HH:mm a');
    		}
    		Date StartDate = ADM.Start_Date__c; // Added by richa 3 april
    		Date EndDate = ADM.End_Date__c; // Added by richa 3 april
    		Datetime start_dt;
    		Datetime end_dt;
    		if(StartDate != null) {
    			start_dt = datetime.newInstance(StartDate.year(), StartDate.month(), StartDate.day());
    		}
    		if(EndDate != null) {
    			end_dt = datetime.newInstance(EndDate.year(), EndDate.month(), EndDate.day());
    		}
    		
    		this.DateRange = (StartDate != null && EndDate != null) ? StartDate.format() + ' - ' + EndDate.format() : ''; // Added by richa 3 april
    		this.NoOfRecords = ADM.Records_Processed__c == null ? 0 : Integer.valueOf(ADM.Records_Processed__c);
    		this.isRadioButtonSelected = false;
    	}
    }
    
    public class AccountingExportTimePeriodWrapper{
    	public String CustomerAllSinceLastExport;
    	public String VendorAllSinceLastExport;
    	public String MoneyReceivedAllSinceLastExport;
    	public String CustomerInvoiceAllSinceLastExport;
    	public String VendorInvoiceAllSinceLastExport;
    	public String JournalEntryAllSinceLastExport;
    	public String ThisWeek;
    	public String LastWeek;
    	public String ThisMonth;
    	public String LastMonth;
    	
    	public AccountingExportTimePeriodWrapper(DateTime CustomerLastExportDate, DateTime VendorLastExportDate, DateTime MoneyReceivedLastExportDate, 
    												DateTime CustomerInvoiceLastExportDate, DateTime VendorInvoiceLastExportDate, DateTime JournalEntryLastExportDate){
			
			CustomerAllSinceLastExport = getDateRange(CustomerLastExportDate, 'ALL_SINCE_LAST_EXORTED');
			VendorAllSinceLastExport = getDateRange(VendorLastExportDate, 'ALL_SINCE_LAST_EXORTED');
			MoneyReceivedAllSinceLastExport = getDateRange(MoneyReceivedLastExportDate, 'ALL_SINCE_LAST_EXORTED');
			CustomerInvoiceAllSinceLastExport = getDateRange(CustomerInvoiceLastExportDate, 'ALL_SINCE_LAST_EXORTED');
			VendorInvoiceAllSinceLastExport = getDateRange(VendorInvoiceLastExportDate, 'ALL_SINCE_LAST_EXORTED');
			JournalEntryAllSinceLastExport = getDateRange(JournalEntryLastExportDate, 'ALL_SINCE_LAST_EXORTED');
			ThisWeek = getDateRange(null, 'THIS_WEEK');
			LastWeek = getDateRange(null, 'LAST_WEEK');
			ThisMonth = getDateRange(null, 'THIS_MONTH');
			LastMonth = getDateRange(null, 'LAST_MONTH');
    	}
    }
    
    public static Map<String, String> filterNameToDateMap = new Map<String, String>{'All since last exported'	=> 'ALL_SINCE_LAST_EXORTED',
																					'This week'					=> 'THIS_WEEK',
																					'Last week'					=> 'LAST_WEEK',
																					'This month'				=> 'THIS_MONTH',
																					'Last month'				=> 'LAST_MONTH',
																					'Specific date range'		=> 'SPECIFIC_DATE_RANGE'
																				};
																				
	public static Map<String, String> objectNameToExportDisplayObjectNameMap = new Map<String, String>{'Customers'				=> 'Customers Card',
																					'Money Received'		=> 'ReceiveMoneyTxn_Deposit',
																					'Customer Invoices'		=> 'Customer Order Sales Invoices',
																					'Vendors'				=> 'Supplier Card',
																					'Journal Entries'		=> 'General Journal Entries',
																					'Vendor Invoices'		=> 'Vendor Invoicing'
																				};
}