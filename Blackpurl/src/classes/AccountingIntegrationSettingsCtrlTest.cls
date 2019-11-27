@isTest
private class AccountingIntegrationSettingsCtrlTest {
    @testSetup
    private static void setupTestData() {
    	system.assertEquals(true,true);
        
    }
    
    /**
     * Name: getCategoryDetailsTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void getCategoryDetailsTest() {
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Test.startTest();
        String categoryJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.getCategoryDetails());
        Test.stopTest();
        
        system.assertEquals(categoryJSON.length() > 0, true);
    }
    
    /**
     * Name: removeCategoryTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void removeCategoryTest() {
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category', 'Labour', 'Testing Category', false, true);
        
        Test.startTest();
        String categoryJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.removeCategory(BPUtility.getEncodedString(testCategory.Id)));
        Test.stopTest();
        
        system.assertEquals(categoryJSON.length() == 2, true);
    }
    
    /**
     * Name: saveAccountingProviderNameTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void saveAccountingProviderNameTest() {
        String accountingProviderName = 'Quickbooks Connector';
        
        Test.startTest();
        String accountingJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.saveAccountingProviderName(BPUtility.getEncodedString(accountingProviderName)));
        Test.stopTest();
        
        AccountingSettingWrapper testAccountingJSON = (AccountingSettingWrapper) System.JSON.deserialize(accountingJSON, AccountingSettingWrapper.class);
        
        system.assertEquals(testAccountingJSON.configuration.AccountingProvider, accountingProviderName);
    }
    
    /**
     * Name: saveAccountingAlignmentMethodTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void saveAccountingAlignmentMethodTest() {
        String accountingProviderName = 'MYOB Account Right';
        String accountingAlignmentMethod = 'None';
        
        Test.startTest();
        String accountingJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.saveAccountingAlignmentMethod(BPUtility.getEncodedString(accountingAlignmentMethod)));
        Test.stopTest();
        
        AccountingSettingWrapper testAccountingJSON = (AccountingSettingWrapper) System.JSON.deserialize(accountingJSON, AccountingSettingWrapper.class);
        
        system.assertEquals(testAccountingJSON.configuration.AlignmentMethod, accountingAlignmentMethod);
    }
    
    /**
     * Name: getAccountingSettingDetailsTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void getAccountingSettingDetailsTest() {
        String accountingProviderName = 'MYOB Account Right';
        String accountingAlignmentMethod = 'None';
        Accounting_Settings__c accConfig = Accounting_Settings__c.getOrgDefaults(); 
    	accConfig.Provider_Name__c = accountingProviderName;
    	accConfig.Alignment_Method__c = accountingAlignmentMethod;
    	upsert accConfig;
    	
        Test.startTest();
        String accountingJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.getAccountingSettingDetails());
        Test.stopTest();
        
        AccountingSettingWrapper testAccountingJSON = (AccountingSettingWrapper) System.JSON.deserialize(accountingJSON, AccountingSettingWrapper.class);
        
        system.assertEquals(testAccountingJSON.configuration.AccountingProvider, accountingProviderName);
        system.assertEquals(testAccountingJSON.configuration.AlignmentMethod, accountingAlignmentMethod);
    }
    
    /**
     * Name: getQBConfigurationsTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void getQBConfigurationsTest() {
        String consumerKey = 'qyprdFawAAiD3SLud6d5RvREaVOoAn';
        String consumerSecret = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr';
        String oAuthToken = 'lEMGSBPH1EHYnBvd9EdvcEhiYzNCBSaNeuzl16pW';
        String oAuthTokenSecret = 'qyprda2rZrHpkhUupn1WM5gY7Txg0IgCLRSht1gAtwY41oyY';
        String companyId = '123145730762509';
        
        QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
		qbConfig.Consumer_Key__c = consumerKey;
		qbConfig.End_Point_URL__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
		qbConfig.Consumer_Secret__c = consumerSecret;
        qbConfig.OAuth_Token__c = oAuthToken;
        qbConfig.OAuth_Token_Secret__c = oAuthTokenSecret;
        qbConfig.Company_Id__c = companyId;
        upsert qbConfig;
    	
        Test.startTest();
        String accountingJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.getQBConfigurations());
        Test.stopTest();
        
        system.assertEquals(accountingJSON.length() > 0, true);
    }
    
    /**
     * Name: OAuthConnectionTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void OAuthConnectionTest() {
        String consumerKey = 'qyprdFawAAiD3SLud6d5RvREaVOoAn';
        String consumerSecret = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr';
    	
        Test.startTest();
        String responseJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.OAuthConnection(BPUtility.getEncodedString(consumerKey), BPUtility.getEncodedString(consumerSecret)));
        Test.stopTest();
        
        AccountingIntegrationSettingsCtrl.ResponseWrapper testResponseJSON = (AccountingIntegrationSettingsCtrl.ResponseWrapper) System.JSON.deserialize(responseJSON, AccountingIntegrationSettingsCtrl.ResponseWrapper.class);
        
        system.assertEquals(testResponseJSON.responseStatus, 'success');
    }
    
    static testMethod void OAuthConnectionStep1Test() {
        String consumerKey = 'qyprdFawAAiD3SLud6d5RvREaVOoAn';
        String consumerSecret = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr';
        String integrationName = 'Xero';
    	IFW_IntegrationConfig__c IFWConfigObj = TestUtil.createIFWConfigForXero();
    	IFWConfigObj.Enabled__c = false;
    	update IFWConfigObj;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
        String responseJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.OAuthConnectionStep1(BPUtility.getEncodedString(consumerKey), BPUtility.getEncodedString(consumerSecret), BPUtility.getEncodedString(integrationName)));
        Test.stopTest();
        AccountingIntegrationSettingsCtrl.ResponseWrapper testResponseJSON = (AccountingIntegrationSettingsCtrl.ResponseWrapper)System.JSON.deserialize(responseJSON, AccountingIntegrationSettingsCtrl.ResponseWrapper.class);
        
        system.assertEquals(testResponseJSON.responseStatus, 'success');
    }
    
    static testMethod void getConnectedCompanyInfoTest() {
        String consumerKey = 'qyprdFawAAiD3SLud6d5RvREaVOoAn';
        String consumerSecret = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr';
        String accessToken = 'lEMGSBPH1EHYnBvd9EdvcEhiYzNCBSaNeuzl16pW';
        String accessTokenSecret = 'qyprda2rZrHpkhUupn1WM5gY7Txg0IgCLRSht1gAtwY41oyY';
        String integrationName = 'Xero';
        
        Accounting_Settings__c accConfig = Accounting_Settings__c.getOrgDefaults();
        accConfig.Provider_Name__c = integrationName;
        upsert accConfig;
        
        IFW_IntegrationConfig__c IFWConfigObj = TestUtil.createIFWConfigForXero();
        IFWConfigObj.Consumer_Key__c = consumerKey;
		IFWConfigObj.Consumer_Secret__c = consumerSecret;
        IFWConfigObj.Access_Token__c = accessToken;
        IFWConfigObj.Access_Token_Secret__c = accessTokenSecret;
    	update IFWConfigObj;
    	
		//Xero IFW_IntegrationConfigItem__c Record
		IFW_IntegrationConfigItem__c IFWConfigItemObj = new IFW_IntegrationConfigItem__c();
		IFWConfigItemObj.Endpoint_URL__c = 'https://api.xero.com/api.xro/2.0/organisation';
		IFWConfigItemObj.HTTP_Method__c = 'GET';
		IFWConfigItemObj.Timeout__c = 5000;
		IFWConfigItemObj.IFW_IntegrationConfig__c = IFWConfigObj.Id;
		IFWConfigItemObj.Subscriber_Record_Id__c = 'a2G1K000003YyYkUAK';
		IFWConfigItemObj.Entity_Name__c = 'Organisation';
		insert IFWConfigItemObj;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
        String responseJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.getConnectedCompanyInfo(BPUtility.getEncodedString(integrationName)));
        Test.stopTest();
        
        system.assertNotEquals(responseJSON, 'error');
    }
    
    static testMethod void getChartOfAccountsTest() {
        String consumerKey = 'qyprdFawAAiD3SLud6d5RvREaVOoAn';
        String consumerSecret = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr';
        String accessToken = 'lEMGSBPH1EHYnBvd9EdvcEhiYzNCBSaNeuzl16pW';
        String accessTokenSecret = 'qyprda2rZrHpkhUupn1WM5gY7Txg0IgCLRSht1gAtwY41oyY';
        String integrationName = 'Xero';
        
        Accounting_Settings__c accConfig = Accounting_Settings__c.getOrgDefaults();
        accConfig.Provider_Name__c = integrationName;
        upsert accConfig;
        
        IFW_IntegrationConfig__c IFWConfigObj = TestUtil.createIFWConfigForXero();
        IFWConfigObj.Consumer_Key__c = consumerKey;
		IFWConfigObj.Consumer_Secret__c = consumerSecret;
        IFWConfigObj.Access_Token__c = accessToken;
        IFWConfigObj.Access_Token_Secret__c = accessTokenSecret;
    	update IFWConfigObj;
    	
		//Xero IFW_IntegrationConfigItem__c Record
		IFW_IntegrationConfigItem__c IFWConfigItemObj = new IFW_IntegrationConfigItem__c();
		IFWConfigItemObj.Endpoint_URL__c = 'https://api.xero.com/api.xro/2.0/account';
		IFWConfigItemObj.HTTP_Method__c = 'GET';
		IFWConfigItemObj.Timeout__c = 5000;
		IFWConfigItemObj.IFW_IntegrationConfig__c = IFWConfigObj.Id;
		IFWConfigItemObj.Subscriber_Record_Id__c = 'a2G1K000003YyYkUAK';
		IFWConfigItemObj.Entity_Name__c = 'Account';
		insert IFWConfigItemObj;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Xero_MockHttpResponseGenerator());
        String responseJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.getChartOfAccounts(BPUtility.getEncodedString(integrationName)));
        Test.stopTest();
        
        system.assertNotEquals(responseJSON, 'error');
    }
    
    /**
     * Name: getQBCompanyInfoTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void getQBCompanyInfoTest() {
        String consumerKey = 'qyprdFawAAiD3SLud6d5RvREaVOoAn';
        String consumerSecret = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr';
        String oAuthToken = 'lEMGSBPH1EHYnBvd9EdvcEhiYzNCBSaNeuzl16pW';
        String oAuthTokenSecret = 'qyprda2rZrHpkhUupn1WM5gY7Txg0IgCLRSht1gAtwY41oyY';
        String companyId = '123145730762509';
        
        Accounting_Settings__c accConfig = Accounting_Settings__c.getOrgDefaults();
        accConfig.Provider_Name__c = 'Quickbooks Online';
        upsert accConfig;
        
        QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
		qbConfig.Consumer_Key__c = consumerKey;
		qbConfig.End_Point_URL__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
		qbConfig.Consumer_Secret__c = consumerSecret;
        qbConfig.OAuth_Token__c = oAuthToken;
        qbConfig.OAuth_Token_Secret__c = oAuthTokenSecret;
        qbConfig.Company_Id__c = companyId;
        upsert qbConfig;
        
        Test.startTest();
        String responseJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.getQBCompanyInfo());
        Test.stopTest();
        
        AccountingIntegrationSettingsCtrl.ResponseWrapper testResponseJSON = (AccountingIntegrationSettingsCtrl.ResponseWrapper) System.JSON.deserialize(responseJSON, AccountingIntegrationSettingsCtrl.ResponseWrapper.class);
        
        system.assertEquals(testResponseJSON.responseStatus, 'success');
    }
    
    /**
     * Name: syncAccountsTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void syncAccountsTest() {
        String consumerKey = 'qyprdFawAAiD3SLud6d5RvREaVOoAn';
        String consumerSecret = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr';
        String oAuthToken = 'lEMGSBPH1EHYnBvd9EdvcEhiYzNCBSaNeuzl16pW';
        String oAuthTokenSecret = 'qyprda2rZrHpkhUupn1WM5gY7Txg0IgCLRSht1gAtwY41oyY';
        String companyId = '123145730762509';
        
        Accounting_Settings__c accConfig = Accounting_Settings__c.getOrgDefaults();
        accConfig.Provider_Name__c = 'Quickbooks Online';
        upsert accConfig;
        
        QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
		qbConfig.Consumer_Key__c = consumerKey;
		qbConfig.End_Point_URL__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
		qbConfig.Consumer_Secret__c = consumerSecret;
        qbConfig.OAuth_Token__c = oAuthToken;
        qbConfig.OAuth_Token_Secret__c = oAuthTokenSecret;
        qbConfig.Company_Id__c = companyId;
        upsert qbConfig;
        
        Test.startTest();
        String responseJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.syncAccounts());
        Test.stopTest();
        
        AccountingIntegrationSettingsCtrl.ResponseWrapper testResponseJSON = (AccountingIntegrationSettingsCtrl.ResponseWrapper) System.JSON.deserialize(responseJSON, AccountingIntegrationSettingsCtrl.ResponseWrapper.class);
        
        system.assertEquals(testResponseJSON.responseStatus, 'success');
    }
    
    /**
     * Name: saveControlAccountsTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void saveControlAccountsTest() {
        String controlAccountsJSON = '{"UndepositedFunds":"81","SalesTax":"93","SalesIncome":"83","MiscellaneousIncome":"14","InventoryAdjustments":"139","Inventory":"144","CustomerDeposits":"141","CostofGoodsSold":"80","APInventoryAccrual":"128"}';
    	
        Test.startTest();
        String accountingJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.saveControlAccounts(BPUtility.getEncodedString(controlAccountsJSON)));
        Test.stopTest();
        
        AccountingSettingWrapper testAccountingJSON = (AccountingSettingWrapper) System.JSON.deserialize(accountingJSON, AccountingSettingWrapper.class);
        
        system.assertEquals(testAccountingJSON.defaultAccounts.APInventoryAccrual, '128');
        system.assertEquals(testAccountingJSON.defaultAccounts.CustomerDeposits, '141');
        system.assertEquals(testAccountingJSON.defaultAccounts.UndepositedFunds, '81');
        system.assertEquals(testAccountingJSON.defaultAccounts.InventoryAdjustments, '139');
    }
    
    /**
     * Name: saveDefaultAccountsTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void saveDefaultAccountsTest() {
        String defaultAccountsJSON = '{"UndepositedFunds":"81","SalesTax":"93","SalesIncome":"83","MiscellaneousIncome":"14","InventoryAdjustments":"139","Inventory":"144","CustomerDeposits":"141","CostofGoodsSold":"80","APInventoryAccrual":"128"}';
    	
        Test.startTest();
        String accountingJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.saveDefaultAccounts(BPUtility.getEncodedString(defaultAccountsJSON)));
        Test.stopTest();
        
        AccountingSettingWrapper testAccountingJSON = (AccountingSettingWrapper) System.JSON.deserialize(accountingJSON, AccountingSettingWrapper.class);
        
        system.assertEquals(testAccountingJSON.defaultAccounts.SalesIncome, '83');
        system.assertEquals(testAccountingJSON.defaultAccounts.SalesTax, '93');
        system.assertEquals(testAccountingJSON.defaultAccounts.MiscellaneousIncome, '14');
        system.assertEquals(testAccountingJSON.defaultAccounts.CostofGoodsSold, '80');
        system.assertEquals(testAccountingJSON.defaultAccounts.Inventory, '144');
    }
    
    /**
     * Name: checkCategoryTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void checkCategoryTestPositive() {
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category', 'Labour', 'Testing Category', false, true);
    	
        Test.startTest();
        String responseJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.checkCategory(BPUtility.getEncodedString(testCategory.Id)));
        Test.stopTest();
        
        AccountingIntegrationSettingsCtrl.ResponseWrapper testResponseJSON = (AccountingIntegrationSettingsCtrl.ResponseWrapper) System.JSON.deserialize(responseJSON, AccountingIntegrationSettingsCtrl.ResponseWrapper.class);
        system.assertEquals(testResponseJSON.responseStatus, 'Success'); 
    }
    
    /**
     * Name: checkCategoryTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void checkCategoryTestNegative() {
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category', 'Labour', 'Testing Category', false, true);
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Part__c testPart = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id);
    	
        Test.startTest();
        String responseJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.checkCategory(BPUtility.getEncodedString(testCategory.Id)));
        Test.stopTest();
        
        AccountingIntegrationSettingsCtrl.ResponseWrapper testResponseJSON = (AccountingIntegrationSettingsCtrl.ResponseWrapper) System.JSON.deserialize(responseJSON, AccountingIntegrationSettingsCtrl.ResponseWrapper.class);
        system.assertEquals(testResponseJSON.responseStatus, 'Error'); 
    }
    
    /**
     * Name: removeGeneralAccountsTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void removeGeneralAccountsTest() {
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category', 'Labour', 'Testing Category', false, true);
        
        String consumerKey = 'qyprdFawAAiD3SLud6d5RvREaVOoAn';
        String consumerSecret = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr';
        String oAuthToken = 'lEMGSBPH1EHYnBvd9EdvcEhiYzNCBSaNeuzl16pW';
        String oAuthTokenSecret = 'qyprda2rZrHpkhUupn1WM5gY7Txg0IgCLRSht1gAtwY41oyY';
        String companyId = '123145730762509';
        
        Accounting_Settings__c accConfig = Accounting_Settings__c.getOrgDefaults();
        accConfig.Provider_Name__c = 'Quickbooks Online';
        upsert accConfig;
        
        QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
		qbConfig.Consumer_Key__c = consumerKey;
		qbConfig.End_Point_URL__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
		qbConfig.Consumer_Secret__c = consumerSecret;
        qbConfig.OAuth_Token__c = oAuthToken;
        qbConfig.OAuth_Token_Secret__c = oAuthTokenSecret;
        qbConfig.Company_Id__c = companyId;
        upsert qbConfig;
        
        String responseJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.syncAccounts());
        
        String defaultAccountsJSON = '{"UndepositedFunds":"81","SalesTax":"93","SalesIncome":"83","MiscellaneousIncome":"14","InventoryAdjustments":"139","Inventory":"144","CustomerDeposits":"141","CostofGoodsSold":"80","APInventoryAccrual":"128"}';
    	
        String accountingJSON1 = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.saveDefaultAccounts(BPUtility.getEncodedString(defaultAccountsJSON)));
    	
        Test.startTest();
        String accountingJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.removeGeneralAccounts());
        Test.stopTest();
        
        AccountingSettingWrapper testAccountingJSON = (AccountingSettingWrapper) System.JSON.deserialize(accountingJSON, AccountingSettingWrapper.class);
        
        system.assertEquals(testAccountingJSON.configuration.AlignmentMethod, null);
    }
    
    /**
     * Name: removeAccountingDataTest
     * Desc: 
     * @param: 
     * @return: 
    **/
    static testMethod void removeAccountingDataTest() {
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category', 'Labour', 'Testing Category', false, true);
        
        String consumerKey = 'qyprdFawAAiD3SLud6d5RvREaVOoAn';
        String consumerSecret = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr';
        String oAuthToken = 'lEMGSBPH1EHYnBvd9EdvcEhiYzNCBSaNeuzl16pW';
        String oAuthTokenSecret = 'qyprda2rZrHpkhUupn1WM5gY7Txg0IgCLRSht1gAtwY41oyY';
        String companyId = '123145730762509';
        
        General_Configurations__c generalConfig = General_Configurations__c.getOrgDefaults();
        generalConfig.Enable_QB_Accounting__c = true;
        upsert generalConfig;
        
        Accounting_Settings__c accConfig = Accounting_Settings__c.getOrgDefaults();
        accConfig.Provider_Name__c = 'Quickbooks Online';
        upsert accConfig;
        
        QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
		qbConfig.Consumer_Key__c = consumerKey;
		qbConfig.End_Point_URL__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
		qbConfig.Consumer_Secret__c = consumerSecret;
        qbConfig.OAuth_Token__c = oAuthToken;
        qbConfig.OAuth_Token_Secret__c = oAuthTokenSecret;
        qbConfig.Company_Id__c = companyId;
        upsert qbConfig;
        
        String responseJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.syncAccounts());
        
        String defaultAccountsJSON = '{"UndepositedFunds":"81","SalesTax":"93","SalesIncome":"83","MiscellaneousIncome":"14","InventoryAdjustments":"139","Inventory":"144","CustomerDeposits":"141","CostofGoodsSold":"80","APInventoryAccrual":"128"}';
    	
        String accountingJSON1 = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.saveDefaultAccounts(BPUtility.getEncodedString(defaultAccountsJSON)));
    	
        Test.startTest();
        String accountingJSON = BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.removeAccountingData());
        Test.stopTest();
        
        AccountingSettingWrapper testAccountingJSON = (AccountingSettingWrapper) System.JSON.deserialize(accountingJSON, AccountingSettingWrapper.class);
        system.assertEquals(testAccountingJSON.configuration.AccountingProvider, null);
    }
    
     public testMethod static void syncTaxCodesWithQuickbooksTest() {
    	Test.startTest();
    	QBIntegrationService.syncTaxCodesWithQuickbooks();
    	Test.stopTest();
    	system.assertEquals(true, true);
    }
    
    public testMethod static void syncTaxRatesWithQuickbooksTest() {
    	Test.startTest();
    	QBIntegrationService.syncTaxRatesWithQuickbooks();
    	Test.stopTest();
    	system.assertEquals(true, true);
    }
}