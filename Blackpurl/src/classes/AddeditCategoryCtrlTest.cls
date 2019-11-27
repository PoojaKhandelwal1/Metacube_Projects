/**
 * Author: Kajal Vaishnav
 * Since: April 25, 2017
 * Name: AddeditCategoryCtrlTest
 * Description: Test class for AddeditCategoryCtrl
**/

@isTest
private class AddeditCategoryCtrlTest {
    
    @testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
    }
    
    static testMethod void testGetCategoryMasterData() {
    	createTestData();
    	
    	Test.startTest();
        String categoryJSON = BPUtility.getDecodedString(AddeditCategoryCtrl.getCategoryMasterData());
        Test.stopTest();
        
    	AccountingSettingWrapper resultJsonRec = (AccountingSettingWrapper)Json.deserialize(categoryJSON, AccountingSettingWrapper.class);
    	//system.assert(false, resultJsonRec);
    	system.assertEquals('Quickbooks Online', resultJsonRec.configuration.AccountingProvider);
    }
    
    static testMethod void testGetCategoryDetails() {
    	/*String categoryJSON = BPUtility.getDecodedString(AddeditCategoryCtrl.getCategoryDetails());
        system.assertEquals(0, categoryJSON.length());//2??
    	system.assertEquals(null, categoryJSON);*/
    	
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Test.startTest();
        String categoryJSON = BPUtility.getDecodedString(AddeditCategoryCtrl.getCategoryDetails());
        Test.stopTest();
        
        system.assertEquals(true, categoryJSON.length() > 0);
    }
    
    static testMethod void testSaveCategoryData() {
    	Category__c testCategory = TestUtil.createCategory(false, 'Test Category');
        CategoryWrapper categoryWrapperObj = new CategoryWrapper(testCategory);
        String response = BPUtility.getDecodedString(AddeditCategoryCtrl.saveCategoryData(BPUtility.getEncodedString(System.JSON.serialize(categoryWrapperObj))));
        system.assertEquals('success', response);// for insert
        
        List<Category__c> categoryList = SOQLUtil.getAllCategoryDetails();
        categoryWrapperObj = new CategoryWrapper(categoryList[0]);
        categoryWrapperObj.CategoryName = 'Test Category 1';
        response = BPUtility.getDecodedString(AddeditCategoryCtrl.saveCategoryData(BPUtility.getEncodedString(System.JSON.serialize(categoryWrapperObj))));
        system.assertEquals('success', response); // for update
        
        Category__c testCategory1 = TestUtil.createCategory(false, 'Test Category 1');
        categoryWrapperObj = new CategoryWrapper(testCategory1);
        response = BPUtility.getDecodedString(AddeditCategoryCtrl.saveCategoryData(BPUtility.getEncodedString(System.JSON.serialize(categoryWrapperObj))));
        system.assertEquals('Duplicate Category Type and Name', response); // for insert
        
        /*Category__c testCategory2 = TestUtil.createCategory(false, 'Test Category 2', 'Tax', 'Testing Category', true, false);
        categoryWrapperObj = new CategoryWrapper(testCategory2);
        response = BPUtility.getDecodedString(AddeditCategoryCtrl.saveCategoryData(BPUtility.getEncodedString(System.JSON.serialize(categoryWrapperObj))));
        //system.assertEquals('You can\'t make inactive Category as default', response);
        categoryList = SOQLUtil.getAllCategoryDetails();
        system.assert(false, categoryList);*/
        /*Category__c testCategory2 = TestUtil.createCategory(false, 'Test Category 2', 'Tax', 'Testing Category', false, false);
        categoryWrapperObj = new CategoryWrapper(testCategory2);
        response = BPUtility.getDecodedString(AddeditCategoryCtrl.saveCategoryData(BPUtility.getEncodedString(System.JSON.serialize(categoryWrapperObj))));
        categoryList = SOQLUtil.getAllCategoryDetails();
        categoryWrapperObj = new CategoryWrapper(categoryList[(categoryList.size()-1)]);
        categoryWrapperObj.IsDefault = true;
        response = BPUtility.getDecodedString(AddeditCategoryCtrl.saveCategoryData(BPUtility.getEncodedString(System.JSON.serialize(categoryWrapperObj))));
        system.assertEquals('You can\'t make inactive Category as default', response);*/
        /*
        categoryList = SOQLUtil.getAllCategoryDetails();
        categoryWrapperObj = new CategoryWrapper(categoryList[0]);
        categoryWrapperObj.IsActive = false;
        categoryWrapperObj.IsDefault = true;
        response = BPUtility.getDecodedString(AddeditCategoryCtrl.saveCategoryData(BPUtility.getEncodedString(System.JSON.serialize(categoryWrapperObj))));
        system.assertEquals('You can\'t make inactive Category as default', response); // for update*/
    }
    
    static void createTestData() {
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
    	
    	String defaultAccountsJSON = '{"UndepositedFunds":"81","SalesTax":"93","SalesIncome":"83","MiscellaneousIncome":"14","InventoryAdjustments":"139","Inventory":"144","CustomerDeposits":"141","CostofGoodsSold":"80","APInventoryAccrual":"128"}';
    	AccountingSettingWrapper.DefaultAccountWrapper accountingWrapperObj = (AccountingSettingWrapper.DefaultAccountWrapper) System.JSON.deserialize(defaultAccountsJSON, AccountingSettingWrapper.DefaultAccountWrapper.class);
        Accounting_Default_Accounts__c accDefaultConfig = Accounting_Default_Accounts__c.getOrgDefaults();
        accDefaultConfig.Sales_Income__c = accountingWrapperObj.SalesIncome;
        accDefaultConfig.Cost_of_Goods_Sold__c = accountingWrapperObj.CostofGoodsSold;
        accDefaultConfig.Inventory__c = accountingWrapperObj.Inventory;
        accDefaultConfig.Miscellaneous_Income__c = accountingWrapperObj.MiscellaneousIncome;
        accDefaultConfig.Sales_Tax__c = accountingWrapperObj.SalesTax;
        upsert accDefaultConfig;
    }
}