@isTest
private class CustomerWrapper_V2Test {
    
    @testsetup
    private static void setup(){
        Account customerRec = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test Fname', 'Test Lname');
    }
    
    @isTest
    private static void testCustomerWrapper_V2(){
        String query = 'SELECT ';  
        for(String fieldsName : CustomerWrapper_V2.fieldsList()) {
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ', Account_Type__c FROM Account WHERE Is_Customer__c = true LIMIT 1';
        Account customerRec = Database.query(query);
        CustomerWrapper_V2 customerWrapper = new CustomerWrapper_V2(customerRec);
        system.assertEquals('Test Fname', customerWrapper.FirstName);
    }
    
    @isTest
    private static void testParse(){
        String json = '{"FirstName": "Test"}';
        CustomerWrapper_V2 customerWrapper = CustomerWrapper_V2.parse(json);
        system.assertEquals('Test', customerWrapper.FirstName);
    }
}