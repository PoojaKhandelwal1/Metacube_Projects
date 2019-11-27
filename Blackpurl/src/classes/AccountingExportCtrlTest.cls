@isTest
private class AccountingExportCtrlTest {
    @testSetup
    private static void setupTestData() {
        List<Accounting_Data_Migration__c> accountMigrateCust = TestUtil.createAccountMigration(false, 1, 'Customers Card', 'Customers Cards');
        accountMigrateCust[0].Start_Date__c = date.today() - 5;
        accountMigrateCust[0].End_Date__c = date.today() + 2;
        insert accountMigrateCust;
    	
    	List<Accounting_Data_Migration__c> accountMigrateDep = TestUtil.createAccountMigration(true, 1, 'ReceiveMoneyTxn_Deposit', 'Receive Money');
    	List<Accounting_Data_Migration__c> accountMigrateVendInv = TestUtil.createAccountMigration(true, 1, 'Vendor Invoicing', 'Purchases - Miscellaneous Purchases');
    	List<Accounting_Data_Migration__c> accountMigratePay = TestUtil.createAccountMigration(true, 1, 'ReceiveMoneyTxn_Payment', 'Receive Money');
    	List<Accounting_Data_Migration__c> accountMigrateCustInv = TestUtil.createAccountMigration(true, 1, 'Customer Order Sales Invoices', 'Sales - Miscellaneous Sales, Receive Payments, General Journal Entries');
    	List<Accounting_Data_Migration__c> accountMigrateVend = TestUtil.createAccountMigration(true, 1, 'Supplier Card', 'Supplier Cards');
    	List<Accounting_Data_Migration__c> accountMigrateJE = TestUtil.createAccountMigration(true, 1, 'General Journal Entries', 'General Journal Entries');
    	system.assertEquals(7, [select Id from Accounting_Data_Migration__c].size());
    }
    
    /**
     * Name: getPreviousExportDetailsTest
     * Desc: 
     * @param: 
     * @return:  
    **/
    static testMethod void getPreviousExportDetailsTest() {
    	AccountingExportCtrl ctrlObj = new AccountingExportCtrl();
    	ctrlObj = new AccountingExportCtrl(new NewHomePageCtrl());
        Test.startTest();
        String responseJSON = BPUtility.getDecodedString(AccountingExportCtrl.getPreviousExportDetails());
        Test.stopTest();
        system.assertEquals(responseJSON.length() > 0 , true);
    }
    
    /**
     * Name: processExportTest
     * Desc: 
     * @param: 
     * @return:  
    **/
    static testMethod void processExportTest() {
		String exportDataJSON = '[{"ObjectName":"Customers","NoOfRecords":0,"LastExport":"2017/04/25 @ 16:15 PM","isRadioButtonSelected":true,"DateRange":"4/23/2017 - 4/25/2017","isRightPanelActive":false,"priorityValue":1,"$$hashKey":"object:60","TimePeriod":"Apr 23/2017 through Apr 25/2017"},{"ObjectName":"Money Received","NoOfRecords":6,"LastExport":"2017/04/25 @ 16:15 PM","isRadioButtonSelected":true,"DateRange":"4/23/2017 - 4/25/2017","isRightPanelActive":false,"priorityValue":3,"$$hashKey":"object:61","TimePeriod":"Apr 23/2017 through Apr 25/2017"},{"ObjectName":"Customer Invoices","NoOfRecords":4,"LastExport":"2017/04/25 @ 16:15 PM","isRadioButtonSelected":true,"DateRange":"4/23/2017 - 4/25/2017","isRightPanelActive":false,"priorityValue":4,"$$hashKey":"object:62","TimePeriod":"Apr 23/2017 through Apr 25/2017"},{"ObjectName":"Vendors","NoOfRecords":0,"LastExport":"2017/04/25 @ 16:15 PM","isRadioButtonSelected":true,"DateRange":"4/23/2017 - 4/25/2017","isRightPanelActive":false,"priorityValue":2,"$$hashKey":"object:63","TimePeriod":"Apr 23/2017 through Apr 25/2017"},{"ObjectName":"Journal Entries","NoOfRecords":0,"LastExport":"2017/04/25 @ 16:15 PM","isRadioButtonSelected":true,"DateRange":"4/23/2017 - 4/25/2017","isRightPanelActive":false,"priorityValue":6,"$$hashKey":"object:64","TimePeriod":"Apr 23/2017 through Apr 25/2017"},{"ObjectName":"Vendor Invoices","NoOfRecords":0,"LastExport":"2017/04/25 @ 16:15 PM","isRadioButtonSelected":true,"DateRange":"4/23/2017 - 4/25/2017","isRightPanelActive":false,"priorityValue":5,"$$hashKey":"object:65","TimePeriod":"Apr 23/2017 through Apr 25/2017"}]';
		String selectedFilter = 'This week';
		String fromDate = '';
		String toDate = '';
        Test.startTest();
        String response = BPUtility.getDecodedString(AccountingExportCtrl.processExport(BPUtility.getEncodedString(exportDataJSON), BPUtility.getEncodedString(selectedFilter), 
        																					BPUtility.getEncodedString(fromDate), BPUtility.getEncodedString(toDate)));
        Test.stopTest();
        system.assertEquals(response, 'Export Data scheduled successfully');
    }
    
    /**
     * Name: getTimePeriodForExportTest
     * Desc: 
     * @param: 
     * @return:  
    **/
    static testMethod void getTimePeriodForExportTest() {
    	Date TodaysDate = Date.today();
    	Date StartDate = TodaysDate.toStartofWeek();
    	Date EndDate = TodaysDate;
    	Datetime start_dt;
    	Datetime end_dt;
    	if(StartDate != null) {
			start_dt = datetime.newInstance(StartDate.year(), StartDate.month(), StartDate.day());
		}
		if(EndDate != null) {
			end_dt = datetime.newInstance(EndDate.year(), EndDate.month(), EndDate.day());
		}
    	String timePeriod = (start_dt != null && end_dt != null) ? start_dt.format('MMM d/yyyy') + ' through ' + end_dt.format('MMM d/yyyy') : '';
        Test.startTest();
        String timePeriodJSON = BPUtility.getDecodedString(AccountingExportCtrl.getTimePeriodForExport());
        Test.stopTest();
        AccountingExportCtrl.AccountingExportTimePeriodWrapper testTimePeriodJSON = (AccountingExportCtrl.AccountingExportTimePeriodWrapper) System.JSON.deserialize(timePeriodJSON, AccountingExportCtrl.AccountingExportTimePeriodWrapper.class);
        system.assertEquals(testTimePeriodJSON.ThisWeek, timePeriod);
    }
}