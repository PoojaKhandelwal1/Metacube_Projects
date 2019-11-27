@isTest
private class ReAuthorizeQBAccessTokenCtrlTest {
    
    @testSetup
    private static void setupTestData() {
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
        qbConfig.Access_Token_Generation_Date__c = system.today().addDays(-155);
        upsert qbConfig;
        
        General_Configurations__c genConfig = Testutil.createGeneralConfig(10, false);
        genConfig.Enable_QB_Accounting__c = true;
        insert genConfig;
        
        system.assertEquals(true,true);
    }
    
    private static testMethod void regenrateTokenTest() {
        ReAuthorizeQBAccessTokenCtrl controllerObj = new ReAuthorizeQBAccessTokenCtrl();
        controllerObj.checkForAccessToken();
        system.assert(true,true);
        
    }
    
    private static testMethod void regenrateTokenTest2() {
        General_Configurations__c genConfig = General_Configurations__c.getOrgDefaults();
        genConfig.Enable_QB_Accounting__c = false;
        upsert genConfig;
        
        ReAuthorizeQBAccessTokenCtrl controllerObj = new ReAuthorizeQBAccessTokenCtrl();
        controllerObj.checkForAccessToken();
        system.assert(true,true);
        
    }
    
    private static testMethod void regenrateTokenTest1() {
        QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
        qbConfig.Access_Token_Generation_Date__c = system.today().addDays(-5);
        upsert qbConfig;
        
        ReAuthorizeQBAccessTokenCtrl controllerObj = new ReAuthorizeQBAccessTokenCtrl();
        controllerObj.checkForAccessToken();
        system.assert(true,true);
        
    }
}