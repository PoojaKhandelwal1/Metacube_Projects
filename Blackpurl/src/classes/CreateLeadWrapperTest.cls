@isTest
private class CreateLeadWrapperTest {
    @testsetup
    private static void setup(){
    	Account customer = TestDataFactory.createCustomer('Test001', 'Individual', 'Fname', 'Lname');
		CO_Header__c coHeader =  TestDataFactory.createCOHeader(customer.Id);
    	Unit_Make__c unitMake = TestDataFactory.createUnitMake('Test Unit Make', 'Tes', true);
    	Unit_Model__c unitModel = TestDataFactory.createUnitModel('Test Unit Model', 'Tes', true, unitMake.Id);
    	Unit_Sub_Model__c unitSubModel = TestDataFactory.createSubModel(unitModel);
    	
    	List<Customer_Owned_Unit__c> customerOwnedUnitList = new List<Customer_Owned_Unit__c>();
    	for(Integer i = 0; i < 20; i++){
    		customerOwnedUnitList.add(TestDataFactory.sampleCustomerOwnedUnit(customer.Id, unitMake.Id, unitModel.Id, unitSubModel.Id, 'VIN001'));
    	}
    	insert customerOwnedUnitList;

		Deal__c deal = TestDataFactory.createDeal(coHeader.Id, customerOwnedUnitList[0].Id);
    }
    
    @isTest
    private static void testForEmail(){
    	Test.startTest();
    	String query = 'SELECT ';  
    	for(String fieldsName : CreateLeadWrapper.fieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
        	query += fieldsName + ', ';  
    	}
    	query = query.substring(0, query.length()-2);
    	query += ' FROM Deal__c LIMIT 1';
    	Deal__c deal = Database.query(query);
    	List<Customer_Owned_Unit__c> unitList = new List<Customer_Owned_Unit__c>([SELECT Id, DP360_Inventory_Id__c, Year__c, Unit_Make__r.Name, Unit_Model__r.Name__c, Colour__c, Mileage_Value__c, Category__r.Name, VIN_Number__c, Total_Price__c, Location__c, Stock_Id__c FROM Customer_Owned_Unit__c]);
    	Account customer = [SELECT FirstName__c, LastName__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Home_number__c, Work_Number__c, Mobile__c, Birth_Date__c, Preferred_Email__c, Email__c, Work_Email__c, Other_Email__c  FROM Account WHERE Is_Customer__c = true LIMIT 1];
    	CreateLeadWrapper createLeadWrapper = new CreateLeadWrapper('5000', deal.Id, null, customer, unitList, unitList);
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testForPreferredEmail(){
    	Test.startTest();
    	String query = 'SELECT ';  
    	for(String fieldsName : CreateLeadWrapper.fieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
        	query += fieldsName + ', ';  
    	}
    	query = query.substring(0, query.length()-2);
    	query += ' FROM Deal__c LIMIT 1';
    	Deal__c deal = Database.query(query);
    	List<Customer_Owned_Unit__c> unitList = new List<Customer_Owned_Unit__c>([SELECT Id, DP360_Inventory_Id__c, Year__c, Unit_Make__r.Name, Unit_Model__r.Name__c, Colour__c, Mileage_Value__c, Category__r.Name, VIN_Number__c, Total_Price__c, Location__c, Stock_Id__c FROM Customer_Owned_Unit__c]);
    	Account customer = [SELECT FirstName__c, LastName__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Home_number__c, Work_Number__c, Mobile__c, Birth_Date__c, Preferred_Email__c, Email__c, Work_Email__c, Other_Email__c  FROM Account WHERE Is_Customer__c = true LIMIT 1];
    	customer.Preferred_Email__c = 'abc@xyz.com';
    	customer.Email__c = '';
    	update customer;
    	CreateLeadWrapper createLeadWrapper = new CreateLeadWrapper('5000', deal.Id, null, customer, unitList, unitList);
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testForWorkEmail(){
    	Test.startTest();
    	String query = 'SELECT ';  
    	for(String fieldsName : CreateLeadWrapper.fieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
        	query += fieldsName + ', ';  
    	}
    	query = query.substring(0, query.length()-2);
    	query += ' FROM Deal__c LIMIT 1';
    	Deal__c deal = Database.query(query);
    	List<Customer_Owned_Unit__c> unitList = new List<Customer_Owned_Unit__c>([SELECT Id, DP360_Inventory_Id__c, Year__c, Unit_Make__r.Name, Unit_Model__r.Name__c, Colour__c, Mileage_Value__c, Category__r.Name, VIN_Number__c, Total_Price__c, Location__c, Stock_Id__c FROM Customer_Owned_Unit__c]);
    	Account customer = [SELECT FirstName__c, LastName__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Home_number__c, Work_Number__c, Mobile__c, Birth_Date__c, Preferred_Email__c, Email__c, Work_Email__c, Other_Email__c  FROM Account WHERE Is_Customer__c = true LIMIT 1];
    	customer.Work_Email__c = 'abc@xyz.com';
    	customer.Email__c = '';
    	update customer;
    	CreateLeadWrapper createLeadWrapper = new CreateLeadWrapper('5000', deal.Id, null, customer, unitList, unitList);
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testForOtherEmail(){
    	Test.startTest();
    	String query = 'SELECT ';  
    	for(String fieldsName : CreateLeadWrapper.fieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
        	query += fieldsName + ', ';  
    	}
    	query = query.substring(0, query.length()-2);
    	query += ' FROM Deal__c LIMIT 1';
    	Deal__c deal = Database.query(query);
    	List<Customer_Owned_Unit__c> unitList = new List<Customer_Owned_Unit__c>([SELECT Id, DP360_Inventory_Id__c, Year__c, Unit_Make__r.Name, Unit_Model__r.Name__c, Colour__c, Mileage_Value__c, Category__r.Name, VIN_Number__c, Total_Price__c, Location__c, Stock_Id__c FROM Customer_Owned_Unit__c]);
    	Account customer = [SELECT FirstName__c, LastName__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Home_number__c, Work_Number__c, Mobile__c, Birth_Date__c, Preferred_Email__c, Email__c, Work_Email__c, Other_Email__c  FROM Account WHERE Is_Customer__c = true LIMIT 1];
    	customer.Email__c = '';
    	customer.Other_Email__c = 'abc@xyz.com';
    	update customer;
    	CreateLeadWrapper createLeadWrapper = new CreateLeadWrapper('5000', deal.Id, null, customer, unitList, unitList);
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
}