@isTest 
private class SOQLUtilityTest {
    
    @testSetup
    private static void setupTestData() {
    	Account customerRec = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test', 'Customer');
    	List<CO_Header__c> coHeaderList = new List<CO_Header__c>();
    	for(Integer i = 0; i< 10; i++) {
    		coHeaderList.add(TestDataFactory.sampleCoHeader(customerRec.Id));
    	}
    	insert coHeaderList;
    	
    	Service_Order_Header__c serviceOrderHeaderRec = TestDataFactory.createSOHeader(coHeaderList[0].Id);
    }
    
    @isTest
    private static void getCOHeaderDetailsTest() {
    	CO_Header__c coHeaderRec = [SELECT Id from CO_Header__c LIMIT 1];
    	List<SObject> sObjectList = SOQLUtility.getCOHeaderDetails(coHeaderRec.Id, 1);
    	system.assertEquals(sObjectList.size(), 1);
    }
    
    @isTest
    private static void getSODetailsByFieldNameTest() {
    	Map<String, String> fieldNameValueMap = new Map<String,String>();
    	Service_Order_Header__c serviceOrderHeaderRec = [Select Id From Service_Order_Header__c LIMIT 1];
    	fieldNameValueMap.put('Id', serviceOrderHeaderRec.Id);
    	List<SObject> sObjectList = SOQLUtility.getSODetailsByFieldName(fieldNameValueMap);
    	system.assertEquals(sObjectList.size(), 1);
    }
}