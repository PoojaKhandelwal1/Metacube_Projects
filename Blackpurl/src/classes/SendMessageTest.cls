@isTest 
public class SendMessageTest {
	
	@testSetup
    private static void setupTestData() {
    	SMS_Configuration__c smsConfiguration = new SMS_Configuration__c();
    	smsConfiguration.Source_Number__c = '1837';
    	smsConfiguration.AuthId__c = '1234';
    	smsConfiguration.AuthToken__c = '2345';
    	insert smsConfiguration;
    }
    
    @isTest
    private static void getAreacodeFromCountryTest() {
    	system.assertEquals('91', SendMessage.getAreacodeFromCountry('India'));
    }
    
    @isTest
    private static void sendTest() {
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new SendMessageMockTest());
    	Test.stopTest();
    	system.assertEquals('available', SendMessage.send('5639', 'India'));
    }
}