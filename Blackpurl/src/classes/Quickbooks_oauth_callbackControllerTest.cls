@isTest
private class Quickbooks_oauth_callbackControllerTest {
    @testSetup
    private static void setup() {
        QuickBooks_Configurations__c qbConfig = TestDataFactory.createQBConfig();
    }
    
    @isTest
    private static void saveAccessSecretsKeysTest() {
    	Quickbooks_oauth_callbackController qbCallBAck = new Quickbooks_oauth_callbackController();
        String oauth_token = 'qyprdLQ7LqRWHDouYt9mFIJSnYRYcoNP3hV1zDhLql5ik92O';
        String oauth_verifier = 'n593zhi';
        String realmId = '123145730762509';
        
        Test.startTest();
        String response = BPUtility.getDecodedString(Quickbooks_oauth_callbackController.saveAccessSecretsKeys(BPUtility.getEncodedString(oauth_token), BPUtility.getEncodedString(oauth_verifier), BPUtility.getEncodedString(realmId)));
        Test.stopTest();
        
        system.assertEquals(response, 'success');
    }
}