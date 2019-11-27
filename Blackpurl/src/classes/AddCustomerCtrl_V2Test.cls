@isTest  
private class AddCustomerCtrl_V2Test {
    
    @testSetup
    private static void setupTestData() {
    	Account customerRec = TestDataFactory.createCustomer('Test001', 'Individual', 'Fname', 'Lname');
        Country__c countryRec = TestDataFactory.createCountry('Test country');
        State__c stateRec = TestDataFactory.createState('Test State', countryRec.Id);
        Timezone__c timezone = TestDataFactory.createTimezone('Test timezone', countryRec.Id, stateRec.Id);
    }  
       
    @isTest  
    private static void testGetMasterData() {
        Test.startTest();
        AddCustomerCtrl_V2 addCustomerObj = new AddCustomerCtrl_V2();
        AddCustomerCtrl_V2 addCustomerObjWithHomePage = new AddCustomerCtrl_V2(new NewHomePageCtrl());
        String masterJSON = BPUtility.getDecodedString(AddCustomerCtrl_V2.getMasterData());
        Test.stopTest();
        COUFieldWrapper resultJSON = (COUFieldWrapper)Json.deserialize(masterJSON, COUFieldWrapper.class);
        System.debug('In test' + resultJSON);
        System.assertEquals('Test country', resultJSOn.CountryList[0].CountryName);
    }
    
    @isTest
    private static void testGetOtherSimilarCustomerOfTypeIndividual() {
        List<Account> customerList = new List<Account>();
        for(Integer i = 0; i < 3; i++) {
        	customerList.add(TestDataFactory.sampleCustomer('Test customer ' + i, 'Individual', 'Test first' + i, 'Test last' + i));
        }
        insert customerList;
        Test.startTest();
        String customerJSONString = CustomerOrderCtrl.getCustomer(BPUtility.getEncodedString(customerList[0].Id));
        List<Customer> customerObjList = (List<Customer>) System.JSON.deserialize(BPUtility.getDecodedString(customerJSONString), List<Customer>.class);
        String similarCustomers = BPUtility.getDecodedString(AddCustomerCtrl_V2.getOtherSimilarCustomer
        																	(BPUtility.getEncodedString(system.JSON.serialize(customerObjList[0]))));
        Test.stopTest();
        List<CustomerSuggestion> customerSuggestionList = (List<CustomerSuggestion>)Json.deserialize(similarCustomers, List<CustomerSuggestion>.class);
        System.assertEquals(4, customerSuggestionList.size());
    }
    
    @isTest
    private static void testGetOtherSimilarCustomerOfTypeIndividual1() {
        List<Account> customerList = new List<Account>();
        for(Integer i = 0; i < 3; i++) {
        	customerList.add(TestDataFactory.sampleCustomer('Test customer ' + i, 'Individual', 'Test first' + i, 'Test last' + i));
        }
        customerList[0].Email__c = null;
        customerList[1].Email__c = null;
        customerList[2].Email__c = null;
        customerList[0].Work_Email__c = 'Test@gmail.com';
        customerList[1].Work_Email__c = 'Test@gmail.com';
        customerList[2].Other_Email__c = 'Test@gmail.com';
        insert customerList;
        Test.startTest();
        String customerJSONString = CustomerOrderCtrl.getCustomer(BPUtility.getEncodedString(customerList[0].Id));
        List<Customer> customerObjList = (List<Customer>) System.JSON.deserialize(BPUtility.getDecodedString(customerJSONString), List<Customer>.class);
        String similarCustomers = BPUtility.getDecodedString(AddCustomerCtrl_V2.getOtherSimilarCustomer
        																	(BPUtility.getEncodedString(system.JSON.serialize(customerObjList[0]))));
        Test.stopTest();
        List<CustomerSuggestion> customerSuggestionList = (List<CustomerSuggestion>)Json.deserialize(similarCustomers, List<CustomerSuggestion>.class);
        System.assertEquals(3, customerSuggestionList.size());
    }
    
    @isTest
    private static void testGetOtherSimilarCustomerOfTypeIndividual2() {
        List<Account> customerList = new List<Account>();
        for(Integer i = 0; i < 4; i++) {
        	customerList.add(TestDataFactory.sampleCustomer('Test customer ' + i, 'Individual', 'Test first' + i, 'Test last' + i));
        }
        customerList[0].Email__c = null;
        customerList[1].Email__c = null;
        customerList[2].Email__c = null;
        customerList[3].Email__c = null;
        customerList[0].Mobile__c = '12345678';
        customerList[0].Work_Number__c = '1234567';
        customerList[1].Home_Number__c = '12345678';
        customerList[2].Work_Number__c = '12345678';
        customerList[3].Mobile__c = '1234567';
        insert customerList;
        Test.startTest();
        String customerJSONString = CustomerOrderCtrl.getCustomer(BPUtility.getEncodedString(customerList[0].Id));
        List<Customer> customerObjList = (List<Customer>) System.JSON.deserialize(BPUtility.getDecodedString(customerJSONString), List<Customer>.class);
        String similarCustomers = BPUtility.getDecodedString(AddCustomerCtrl_V2.getOtherSimilarCustomer
        																	(BPUtility.getEncodedString(system.JSON.serialize(customerObjList[0]))));
        Test.stopTest();
        List<CustomerSuggestion> customerSuggestionList = (List<CustomerSuggestion>)Json.deserialize(similarCustomers, List<CustomerSuggestion>.class);
        System.assertEquals(4, customerSuggestionList.size());
    }
    
    @isTest
    private static void testGetOtherSimilarCustomerOfTypeIndividual3() {
        List<Account> customerList = new List<Account>();
        for(Integer i = 0; i < 2; i++) {
        	customerList.add(TestDataFactory.sampleCustomer('Test customer ' + i, 'Individual', 'Test first' + i, 'Test last' + i));
        }  
        customerList[0].Email__c = null;
        customerList[1].Email__c = null;
        customerList[0].LinkedIn__c = 'abc';
        customerList[1].LinkedIn__c = 'abc';
        insert customerList;
        Test.startTest();
        String customerJSONString = CustomerOrderCtrl.getCustomer(BPUtility.getEncodedString(customerList[0].Id));
        List<Customer> customerObjList = (List<Customer>) System.JSON.deserialize(BPUtility.getDecodedString(customerJSONString), List<Customer>.class);
        String similarCustomers = BPUtility.getDecodedString(AddCustomerCtrl_V2.getOtherSimilarCustomer
        																	(BPUtility.getEncodedString(system.JSON.serialize(customerObjList[0]))));
        Test.stopTest();
        List<CustomerSuggestion> customerSuggestionList = (List<CustomerSuggestion>)Json.deserialize(similarCustomers, List<CustomerSuggestion>.class);
        System.debug('In test similar ' + customerSuggestionList);
        System.assertEquals(1, customerSuggestionList.size());
    }
    
    @isTest
    private static void testGetOtherSimilarCustomerOfTypeBusiness() {
        List<Account> customerList = new List<Account>();
        for(Integer i = 0; i < 4; i++) {
        	customerList.add(TestDataFactory.sampleCustomer('Test customer ' + i, 'Business', 'Test first' + i, 'Test last' + i));
        }
        insert customerList;
        Test.startTest();
        String customerJSONString = CustomerOrderCtrl.getCustomer(BPUtility.getEncodedString(customerList[0].Id));
        List<Customer> customerObjList = (List<Customer>) System.JSON.deserialize(BPUtility.getDecodedString(customerJSONString), List<Customer>.class);
        String similarCustomers = BPUtility.getDecodedString(AddCustomerCtrl_V2.getOtherSimilarCustomer
        																	(BPUtility.getEncodedString(system.JSON.serialize(customerObjList[0]))));
        Test.stopTest();
        List<CustomerSuggestion> customerSuggestionList = (List<CustomerSuggestion>)Json.deserialize(similarCustomers, List<CustomerSuggestion>.class);
        System.assertEquals(4, customerSuggestionList.size());
    }
    
    @isTest
    private static void testSaveCustomer(){
    	Test.startTest();
    	String query = 'SELECT ';  
    	for(String fieldsName : CustomerWrapper_V2.fieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
        	query += fieldsName + ', ';  
    	}
    	query = query.substring(0, query.length()-2);
    	query += ', Account_Type__c FROM Account WHERE Is_Customer__c = true LIMIT 1';
    	Account customerRec = Database.query(query);
    	CustomerWrapper_V2 customerWrapper = new CustomerWrapper_V2(customerRec);
    	String jsonString = json.serialize(customerWrapper);
    	String result = AddCustomerCtrl_V2.saveCustomer(BPUtility.getEncodedString(jsonString));
    	system.assertEquals(result, customerRec.Id);
    	
    	Test.stopTest();
    }
    
    @isTest
    private static void testSaveCustomerWithIdNull(){
    	Test.startTest();
    	Price_Level__c priceLevelRec = TestDataFactory.createPriceLevel('Test price level');
    	priceLevelRec.Default__c = true;
    	update priceLevelRec;
    	String query = 'SELECT ';  
    	for(String fieldsName : CustomerWrapper_V2.fieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
        	query += fieldsName + ', ';  
    	}
    	query = query.substring(0, query.length()-2);
    	query += ', Account_Type__c FROM Account WHERE Is_Customer__c = true LIMIT 1';
    	Account customerRec = Database.query(query);
    	CustomerWrapper_V2 customerWrapper = new CustomerWrapper_V2(customerRec);
    	customerWrapper.Id = null;
    	String jsonString = json.serialize(customerWrapper);
    	String result = AddCustomerCtrl_V2.saveCustomer(BPUtility.getEncodedString(jsonString));
		List<Account> customerList = [SELECT Id FROM Account WHERE Is_Customer__c = true];
		system.assertEquals(2, customerList.size());    	
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetAllAccountTypeData(){
    	Test.startTest();
    	String result = BPUtility.getDecodedString(AddCustomerCtrl_V2.getAllAccountTypeData());
    	List<AccountTypeWrapper> accountTypeWrapperList = (List<AccountTypeWrapper>)json.deserialize(result, List<AccountTypeWrapper>.class);
    	system.assertEquals(accountTypeWrapperList.size(), 0);
    	Test.stopTest();
    }
}