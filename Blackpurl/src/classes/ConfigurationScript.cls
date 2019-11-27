/**
 * Author: Tarun Khandelwal
 * Since: 
 * Name: ConfigurationScript
 * Description: Apex class to delete all default data in org
**/
global without sharing class ConfigurationScript {
    public static boolean isPostInstallRunning = false;
     global static void runAll() {
        isPostInstallRunning = true;
        //deleteNativeRecords();
        deleteConfigurations();
        createAdminConfigurations();
        createConfigurations();
        createWidgets();
        createGlAccount();
        createAccountingDataMigration();
        createTransactionTypes();
        createUserDependentFeature();
        String sch = '0 0 01 * * ?';
        executeReportScheduler(sch);
     }
     
    /**
     * Name: deleteNativeRecords
     * Desc: Method to delete all default data in salesforce org
     * @param:  
     * @return: 
    **/
    global static void deleteNativeRecords()  {
       /* List<String> objNamesList = new List<String>{'Lead', 'Case', 'Contact', 'Opportunity', 'Account'};
        
        if(AccessControl.ifObjectFieldIsAccessible(objNamesList) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectIsDeletable(objNamesList) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Lead') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Case') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Contact') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Opportunity') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        List<sobject> sobjectList =  new List<sobject>();
        List<sobject> leadList = [select id from Lead LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
        sobjectList.addAll(leadList);
        List<sobject> caseList = [select id from Case LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
        sobjectList.addAll(caseList);
        List<sobject> contactList = [select id from Contact LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
        sobjectList.addAll(contactList);
        List<sobject> opportunityList = [select id from Opportunity LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
        sobjectList.addAll(opportunityList);
        List<sobject> accountList = [Select Id from Account LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
        sobjectList.addAll(accountList);
        
        if(sobjectList.size() > 0) {
            delete sobjectList ;
        }*/
    }  
    
    /**
     * Name: deleteConfigurations
     * Desc: Method to configure custom default settings
     * @param:  
     * @return: 
    **/
    public static Boolean isTechnicianScheduling = false;
    public static Boolean isQBEnabled = false;
    public static Boolean isARIPartSmartEnabled = false;
    public static Boolean isHDDealerEnabled = false;
    public static Boolean isDisplayTaxInvoice = false;
    public static Decimal schedularStartDay = 0;
    public static Boolean isLoadNewHeader = false;
    public static Boolean isUseQBAccountingTaxCodes = false;
    global static void deleteConfigurations() {
        isPostInstallRunning = true;
        List<String> objNamesList = new List<String>{'General_Configurations__c', 'Configurations__c', 'SearchConfigurations__c', 'Australian_Market__c'};
        if(AccessControl.ifObjectFieldIsAccessible(objNamesList) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectIsDeletable(objNamesList) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        
        /*List<Configurations__c> config = [Select Id from Configurations__c where Sent_From_Email_Id__c != null];
        if(config.size() > 0) {
            delete config ;
        }*/
        
        List<General_Configurations__c> genConfig = [Select Technician_Scheduling__c, Enable_QB_Accounting__c, ARI_Partsmart__c, H_D_Dealer__c, Display_Tax_Invoice__c, 
        	Scheduler_Start_Day__c, Load_New_Header__c, Use_QB_accounting_tax_codes__c from General_Configurations__c where Home_Search_Grid_Page_Size__c != null];
        if(genConfig.size() > 0) {
            isTechnicianScheduling = genConfig[0].Technician_Scheduling__c;
            isARIPartSmartEnabled = genConfig[0].ARI_Partsmart__c;
            isLoadNewHeader = genConfig[0].Load_New_Header__c;
            isUseQBAccountingTaxCodes = genConfig[0].Use_QB_accounting_tax_codes__c;
            isQBEnabled = genConfig[0].Enable_QB_Accounting__c;
            isHDDealerEnabled = genConfig[0].H_D_Dealer__c;
            isDisplayTaxInvoice = genConfig[0].Display_Tax_Invoice__c;
            schedularStartDay = genConfig[0].Scheduler_Start_Day__c != null ? genConfig[0].Scheduler_Start_Day__c : schedularStartDay;
            if(AccessControl.ifObjectIsDeletable('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete genConfig ;
        }
        
        List<SearchConfigurations__c> searchConfig = [Select Id from SearchConfigurations__c where Name != null];
        if(searchConfig.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('SearchConfigurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete searchConfig ;
        }
        
        List<Australian_Market__c> ausMarket = [Select Id from Australian_Market__c where Sales_Tax_Rate__c != null];
        if(ausMarket.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('Australian_Market__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete ausMarket ;
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Reporting__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectIsDeletable('Reporting__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        List<Reporting__c> emailReport = [Select Id from Reporting__c where Reporting_Objects__c != null];
        if(emailReport.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('Reporting__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete emailReport ;
        }
        
        List<Filter__c> filters = [Select Id from Filter__c where Common__c = true OR Filter_Label__c = 'Recent Records'];
        if(filters.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('Filter__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete filters ;
        }
    }
    
    /**
     * Name: createAdminConfigurations
     * Desc: Method to configure custom default settings
     * @param:  
     * @return: 
    **/
    global static void createAdminConfigurations(){
        if(AccessControl.ifObjectFieldIsCreateable('Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); } //FLS Create Nikhil 31/01/2017 
        if(AccessControl.ifObjectFieldIsUpdateable('Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); } //FLS Update Nikhil 31/01/2017
        if(AccessControl.ifObjectFieldIsAccessible('Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('BP_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); } //FLS Create Nikhil 31/01/2017 
        if(AccessControl.ifObjectFieldIsUpdateable('BP_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); } //FLS Update Nikhil 31/01/2017
        if(AccessControl.ifObjectFieldIsAccessible('BP_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Configurations__c config = Configurations__c.getOrgDefaults();
        config.SearchMinCharLength__c = 2;
        config.Sent_From_Email_Id__c = 'support@blackpurl.com';
        config.NumberOfCustomersRecordPageSize__c = 20;
        config.Cash_Payment_Rounding_Factor__c = 1;
        upsert config ;
        
        BP_Configurations__c bpConf = BP_Configurations__c.getOrgDefaults();
        bpConf.Community_Link__c = 'https://community.blackpurl.com/s/';
        upsert bpConf;
    }
    
    /**
     * Name: createConfigurations
     * Desc: Method to configure custom default settings
     * @param:  
     * @return: 
    **/
    global static void createConfigurations() {
        isPostInstallRunning = true;
        List<String> objNamesList = new List<String>{'General_Configurations__c', 'Configurations__c', 'SearchConfigurations__c', 'Shop_Settings__c', 'Australian_Market__c','Reporting__c','BP_Configurations__c'};
        if(AccessControl.ifObjectFieldIsCreateable(objNamesList) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable(objNamesList) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        
        General_Configurations__c generalConfig = General_Configurations__c.getOrgDefaults();
        generalConfig.Load_New_Customer_Order__c =  true ;
        generalConfig.Load_New_View_Customer__c = true;
        generalConfig.Load_Financing_Section__c = true;
        generalConfig.Technician_Scheduling__c = isTechnicianScheduling;
        generalConfig.ARI_Partsmart__c = isARIPartSmartEnabled;
        generalConfig.Load_New_Header__c = isLoadNewHeader;
        generalConfig.Use_QB_accounting_tax_codes__c = isUseQBAccountingTaxCodes;
        generalConfig.Enable_QB_Accounting__c = isQBEnabled;
        generalConfig.H_D_Dealer__c = isHDDealerEnabled;
        generalConfig.Display_Tax_Invoice__c= isDisplayTaxInvoice;
        generalConfig.Home_Search_Grid_Page_Size__c = 50;
        generalConfig.Load_New_UI__c = true;
        generalConfig.Related_List_Page_Size__c = 25 ;
        generalConfig.Scheduler_Start_Day__c = schedularStartDay;
        upsert generalConfig ;
        
        String nameSpace = PostInstallClass.NAMESPACE;
        
        List<SearchConfigurations__c> searchConfigList = new List<SearchConfigurations__c>();
        searchConfigList.add(insertSearchConfigurationRecords('Customer', 'Name', '', 'Customer', 1, 'Name'));
        searchConfigList.add(insertSearchConfigurationRecords('Vendor', 'Name', '', 'Vendor', 2, 'Name,Is_Calculate_Part_Retail_Price__c,Retail_Base_Value__c,Retail_Rate__c,Retail_Rounding__c,Retail_Round_To__c'));
        searchConfigList.add(insertSearchConfigurationRecords('User', 'Name', '', 'User', 3, 'Name'));
        searchConfigList.add(insertSearchConfigurationRecords('Part__c', 'Part_Number__c', '{Description__c}', nameSpace + 'Part__c', 4, 'Part_Number__c,Description__c,Part_Id__c,Part_Id_Text__c,Qty_In_Stock__c, Qty_Committed__c, Retail_Price__c, Name, Vendor__c, AvailableParts__c,Non_Inventory_Part__c')); // ,Non_Inventory_Part__c: Added By Pooja 8 Feb. 2017
        searchConfigList.add(insertSearchConfigurationRecords('Category__c', 'Name', '', nameSpace + 'Category__c', 5, 'Name'));
        searchConfigList.add(insertSearchConfigurationRecords('Sales_Tax_Item__c', 'Name__c', '', nameSpace + 'Sales_Tax_Item__c', 6, 'Name__c'));
        searchConfigList.add(insertSearchConfigurationRecords('Labour','Name__c', '', nameSpace + 'Labour_Code__c', 7, 'Name__c, Name, Description__c, Code__c'));
        searchConfigList.add(insertSearchConfigurationRecords('Kit Header', 'Kit_Unique_Name__c', '', nameSpace + 'Kit_Header__c', 8, 'Name, Description__c, Kit_Unique_Name__c, Code__c,Service_Kit__c'));
        searchConfigList.add(insertSearchConfigurationRecords('Fee', 'Fee_Unique_Name__c', '', nameSpace + 'Fee__c', 9, 'Name, Description__c, Fee_Unique_Name__c, Code__c'));
        searchConfigList.add(insertSearchConfigurationRecords('Customer_Owned_Unit__c', 'Unit_Number__c', '{Year__c}, {Make_Name__c}, {Model_Name__c}', nameSpace + 'Customer_Owned_Unit__c', 10, 'Name,Unit_Number__c,Year__c,Unit_Make__r.Name,Unit_Model__r.Name,Make_Name__c,Model_Name__c,VIN_Number_Formula__c,Stock_Id__c,Formatted_Name__c'));
        searchConfigList.add(insertSearchConfigurationRecords('UnitModel', 'Name__c', '', 'UnitModel', 13, 'Name__c'));
        searchConfigList.add(insertSearchConfigurationRecords('Unit_Make__c', 'Name', '', nameSpace + 'Unit_Make__c', 12, 'Name'));
        searchConfigList.add(insertSearchConfigurationRecords('Unit_Model__c', 'Name__c', 'Name__c', nameSpace + 'Unit_Model__c', 14, 'Name__c'));
        searchConfigList.add(insertSearchConfigurationRecords('Unit_SubModel__c', 'sub_model__c', '', nameSpace + 'Unit_Model__c', 13, 'sub_model__c'));
        searchConfigList.add(insertSearchConfigurationRecords('Product__c', 'Product_Unique_Name__c', '', nameSpace + 'Product__c', 11, 'Product_Unique_Name__c, Code__c, Description__c, Type__c'));
        upsert searchConfigList;
        
        List<Shop_Settings__c> shopConfigList = [Select Id from Shop_Settings__c where Name != null];
        if(shopConfigList.size() == 0) {
	        List<Shop_Settings__c> shopSettingConfigList = new List<Shop_Settings__c>();
	        shopSettingConfigList.add(insertShopSettingConfigurationRecords('Monday', true, 1));
	        shopSettingConfigList.add(insertShopSettingConfigurationRecords('Tuesday', true, 2));
	        shopSettingConfigList.add(insertShopSettingConfigurationRecords('Wednesday', true, 3));
	        shopSettingConfigList.add(insertShopSettingConfigurationRecords('Thursday', true, 4));
	        shopSettingConfigList.add(insertShopSettingConfigurationRecords('Friday', true, 5));
	        shopSettingConfigList.add(insertShopSettingConfigurationRecords('Saturday', false, 6));
	        shopSettingConfigList.add(insertShopSettingConfigurationRecords('Sunday', false, 7));
	        upsert shopSettingConfigList;
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Cash_Drawer__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Cash_Drawer__c> cashDrawerList = [Select Id from Cash_Drawer__c LIMIT 1];
        if(cashDrawerList.size() == 0) {
        	Cash_Drawer__c cashDrawerObj = new Cash_Drawer__c();
        	cashDrawerObj.Name = 'Main cash drawer';
        	cashDrawerObj.Active__c = true;
        	if(AccessControl.ifObjectFieldIsCreateable('Cash_Drawer__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        	insert cashDrawerObj;
        }
        
        Australian_Market__c ausMarket = Australian_Market__c.getOrgDefaults();
        ausMarket.Sales_Tax_Rate__c = 10;
        upsert ausMarket;
        
        Reporting__c reportingObj = Reporting__c.getOrgDefaults();
        reportingObj.Is_Reporting__c =  true;
        reportingObj.Receipient_Email__c = 'activity@blackpurl.com;yash.sharma@metacube.com;durga.singh@metacube.com;nikhil.srivastava@metacube.com';
        reportingObj.Reporting_Objects__c = 'Customer;Vendor;CO_Header__c;Part__c;Vendor_Order_Header__c';
        upsert reportingObj;
        
        Configurations__c config = Configurations__c.getOrgDefaults();
        if(config.Cash_Payment_Rounding_Factor__c == null) {
            config.Cash_Payment_Rounding_Factor__c = 1;
            upsert config ;
        }
    } 
    
    /**
     * Name: insertSearchConfigurationRecords
     * Desc: Method to insert search configuration record
     * @param:      (1) name - record name
     *              (2) displayFieldForAutoComplete - Display Field For Auto Complete
     *              (3) displayInfo -  Display Information String
     *              (4) objectName - Object Name
     *              (5) Order - Order Number
     *              (6) searchableFieldForAutoComplete - Search Field For Auto Complete
     * @return: SearchConfigurations__c record
    **/
    private static SearchConfigurations__c insertSearchConfigurationRecords(String name, String displayFieldForAutoComplete, String displayInfo, String objectName, Integer Order, String searchableFieldForAutoComplete ) {
        SearchConfigurations__c searchConfig = new SearchConfigurations__c();
        searchConfig.Name = name;
        searchConfig.Display_Field__c = displayFieldForAutoComplete;
        searchConfig.Display_Info__c = displayInfo;
        searchConfig.Object_Name__c = objectName;
        searchConfig.Order__c = Order;
        searchConfig.Searchable_Field__c = searchableFieldForAutoComplete;    
        return searchConfig;
    } 
    
    private static Shop_Settings__c insertShopSettingConfigurationRecords(String day, Boolean isWorking, Integer orderNumber) {
        Shop_Settings__c shopSettingObject = new Shop_Settings__c();
        shopSettingObject.Name = day;
        shopSettingObject.Day__c = day;
        shopSettingObject.Is_Working__c = isWorking;
        shopSettingObject.From_Time__c = '8:00AM';
        shopSettingObject.To_Time__c = '5:00PM';
        shopSettingObject.Order_Number__c = orderNumber;
		return shopSettingObject;
    }  
    
    /**
     * Name: createWidgets
     * Desc: Method to create widget records
     * @param:  
     * @return: 
    **/
    global static void createWidgets() {
        if(AccessControl.ifObjectFieldIsCreateable('Widget__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        
        List<Widget__c> widgetList  = new List<Widget__c>();
        widgetList.add(insertWidget(1, 'Selling'));
        widgetList.add(insertWidget(2, 'Ordering'));
        widgetList.add(insertWidget(3, 'MyProfile'));
        widgetList.add(insertWidget(4, 'Tasks'));
        widgetList.add(insertWidget(5, 'Actions'));
        widgetList.add(insertWidget(6, 'Chatter'));
        widgetList.add(insertWidget(7, 'News'));
        widgetList.add(insertWidget(8, 'Alerts'));
        insert widgetList;
    }
    
     /**
     * Name: insertWidget
     * Desc: Method to insert widget record
     * @param:      (1) orderNumber - Order Number
     *              (2) widgetName - Widget Name
     * @return: Widget__c record
    **/
    private static Widget__c insertWidget(Integer orderNumber, String widgetName) {
        Widget__c widgetRec = new Widget__c();
        widgetRec.Order_Number__c = orderNumber;
        widgetRec.Widget_Name__c = widgetName;
        return widgetRec;
        
    }
    
    /**
     * Name: createTransactionTypes
     * Desc: Method to create Transaction Type records
     * @param:  
     * @return: 
    **/
    global static void createTransactionTypes() {
        if(AccessControl.ifObjectFieldIsCreateable('Transaction_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        
        List<Transaction_Type__c> ttList  = new List<Transaction_Type__c>();
        ttList.add(new Transaction_Type__c(Code__c = 'Customer Pay', Type__c = 'Customer', Code_Label__c = 'Customer Pay', Default__c = true, Active__c = true));
        ttList.add(new Transaction_Type__c(Code__c = 'Warranty', Type__c = 'Third-Party', Code_Label__c = 'Third-Party', Default__c = true, Active__c = true));
        ttList.add(new Transaction_Type__c(Code__c = 'Internal', Type__c = 'Internal', Code_Label__c = 'Internal Expense', Default__c = true, Active__c = true));
        ttList.add(new Transaction_Type__c(Code__c = 'Deal', Type__c = 'Deal Service', Code_Label__c = 'Deal', Default__c = true, Active__c = true));
        ttList.add(new Transaction_Type__c(Code__c = 'Unit Inventory', Type__c = 'Stock Unit', Code_Label__c = 'Unit Inventory', Default__c = true, Active__c = true));
        ttList.add(new Transaction_Type__c(Code__c = 'Quote', Type__c = 'Quote', Code_Label__c = 'Quote', Default__c = true, Active__c = true));
        insert ttList;
    }
    
    
    global static void createGlAccount(){
        if(AccessControl.ifObjectFieldIsCreateable('GL_Account__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        List<GL_Account__c> GLAccountList =  new List<GL_Account__c>();
        GLAccountList.add(new GL_Account__c(MYOB_Account_Name__c =  'A/P Accrual - Inventory', MYOB_Account_Number__c = '2-1530',  Type__c = 'Received Inventory Accrual'));
        GLAccountList.add(new GL_Account__c(MYOB_Account_Name__c =  'BP Customer Deposits', MYOB_Account_Number__c = '1-1250',  Type__c = 'Deposit Allocation Account'));
        GLAccountList.add( new GL_Account__c(MYOB_Account_Name__c =  'Other Income', MYOB_Account_Number__c = '4-4200',  Type__c = '    Sales Invoice Account'));
        GLAccountList.add( new GL_Account__c(MYOB_Account_Name__c =  'Undeposited Funds Account', MYOB_Account_Number__c = '1-1210',  Type__c = 'Deposit Account'));
            
        insert GLAccountList;
    }
    
    
    global static void createAccountingDataMigration(){
        if(AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        List<Accounting_Data_Migration__c> AccountingDataMigrationList =  new List<Accounting_Data_Migration__c>();
        AccountingDataMigrationList.add( new Accounting_Data_Migration__c(Object_Name__c = 'Customers Card', MYOB_Object_Name__c = 'Customer Cards'));
        AccountingDataMigrationList.add( new Accounting_Data_Migration__c(Object_Name__c = 'ReceiveMoneyTxn_Deposit', MYOB_Object_Name__c = 'Receive Money'));
        AccountingDataMigrationList.add( new Accounting_Data_Migration__c(Object_Name__c = 'ReceiveMoneyTxn_Payment', MYOB_Object_Name__c ='Receive Money'));
        AccountingDataMigrationList.add( new Accounting_Data_Migration__c(Object_Name__c = 'Customer Order Sales Invoices', MYOB_Object_Name__c ='Sales - Miscellaneous Sales, Receive Payments, General Journal Entries'));
        AccountingDataMigrationList.add( new Accounting_Data_Migration__c(Object_Name__c = 'Supplier Card', MYOB_Object_Name__c ='Supplier Cards'));
        AccountingDataMigrationList.add( new Accounting_Data_Migration__c(Object_Name__c = 'General Journal Entries', MYOB_Object_Name__c ='General Journal Entries'));
        AccountingDataMigrationList.add( new Accounting_Data_Migration__c(Object_Name__c = 'Vendor Invoicing', MYOB_Object_Name__c = 'Purchases - Miscellaneous Purchases'));
        
        insert AccountingDataMigrationList;
    }
    
    
    global static void createUserDependentFeature(){
        if(AccessControl.ifObjectFieldIsAccessible('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<User> userRecList =  [SELECT Id From User where IsActive = true AND (Profile.Name = 'Blackpurl' OR Profile.Name = 'System Administrator') limit: SOQLUtil.getAvailableQueryRowsLimit()];
        List<Id> userIdList =  new List<Id>();
        for(User userRec : userRecList) {
            userIdList.add(userRec.Id);
        }
        //UserTriggerHelper.createWidgetJunction(userIdList);  
        UserTriggerHelper.createFilters(userIdList);
    }
    
     global static void executeReportScheduler(String sch){
        ReportScheduler repScheduler = new ReportScheduler();
        system.schedule('Automated Report', sch, repScheduler); 
   }
}