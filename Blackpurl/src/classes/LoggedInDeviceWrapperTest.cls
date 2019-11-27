@isTest
private class LoggedInDeviceWrapperTest {
    @testsetup
    private static void setup(){
    	Logged_In_Device__c loggedInDevice = TestDataFactory.createLoggedInDevice();
    }
    
    @isTest
    private static void testLoggedInDeviceWrapper(){
    	Test.startTest();
    	String query;   
        query = 'SELECT '; 
        for(String fieldsName : LoggedInDeviceWrapper.getLoggedInDeviceFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM  Logged_In_Device__c LIMIT 1';
        Logged_In_Device__c loggedInDevice = Database.query(query);
        LoggedInDeviceWrapper loggedInDeviceWrapper = new LoggedInDeviceWrapper(loggedInDevice);
        system.assertEquals(loggedInDeviceWrapper.Id, loggedInDevice.Id);
    	Test.stopTest();
    }
}