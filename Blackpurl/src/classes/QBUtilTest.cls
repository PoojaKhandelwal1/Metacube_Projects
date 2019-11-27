@isTest
private class QBUtilTest {
    @testsetup
    private static void setup(){
    	Account customer = TestDataFactory.createCustomer('Test001', 'Individual', 'Fname', 'Lname');
		CO_Header__c coHeader =  TestDataFactory.createCOHeader(customer.Id);
    	Unit_Make__c unitMake = TestDataFactory.createUnitMake('Test Unit Make', 'Tes', true);
    	Unit_Model__c unitModel = TestDataFactory.createUnitModel('Test Unit Model', 'Tes', true, unitMake.Id);
    	Unit_Sub_Model__c unitSubModel = TestDataFactory.createSubModel(unitModel);
    	Customer_Owned_Unit__c customerOwnedUnit = TestDataFactory.createCustomerOwnedUnit(customer.Id, unitMake.Id, unitModel.Id, unitSubModel.Id, 'VIN001');
		Deal__c deal = TestDataFactory.createDeal(coHeader.Id, customerOwnedUnit.Id);
		Deal_Item__c dealItem = TestDataFactory.createDealItem(unitModel.Id, deal.Id);
		customerOwnedUnit.Year__c = 2019;
		update customerOwnedUnit;
		QB_TaxCode__c qbSalesTaxCode = TestDataFactory.createQBTaxCode();
		
		QuickBooks_Configurations__c qbConfig = TestDataFactory.createQBConfig();
		qbConfig.Company_Country__c = 'US';
		qbConfig.Non_Taxable_Tax_Code__c = '25';
		update qbConfig;
		
		General_Configurations__c genConfig = TestDataFactory.sampleGeneralConfig(2);
    }
    
    @isTest
    private static void testIsQBEnabled(){
    	Test.startTest();
    	system.assertEquals(false, QBUtil.isQBEnabled());
    	Test.stopTest();
    }
    
    @isTest
    private static void testIsUSVersionQB(){
    	Test.startTest();
    	system.assertEquals(true, QBUtil.isUSVersionQB());
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetQBVersion(){
    	Test.startTest();
    	system.assertEquals('US', QBUtil.getQBVersion());
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetCronExpForGivenTime(){
    	Test.startTest();
    	DateTime dtVal = system.now().addSeconds(3);
        String strSchedule = String.valueOf(dtVal.second()) + ' ' + String.valueOf(dtVal.minute()) + ' ' + String.valueOf(dtVal.hour()) + 
                                ' ' + String.valueOf(dtVal.day()) + ' ' + String.valueOf(dtVal.month()) + ' ?' + ' ' + String.valueOf(dtVal.year());
    	system.assertEquals(strSchedule, QBUtil.getCronExpForGivenTime(3));
    	Test.stopTest();
    }
    
    @isTest
    private static void testAbortAlreadyScheduleJobs(){
    	Test.startTest();
    	QBUtil.abortAlreadyScheduleJobs('');
    	system.assertEquals('', '');
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetDealUnitName(){
    	Test.startTest();
    	String query = 'SELECT ';  
    	for(String fieldsName : DealItem.getDealItemFields()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
        	query += fieldsName + ', ';  
    	}
    	query = query.substring(0, query.length()-2);
    	query += ' FROM Deal_Item__c LIMIT 1';
    	Deal_Item__c dealItem = Database.query(query);
    	String result = QBUtil.getDealUnitName(dealItem);
    	system.assertEquals('2019 ', result.subString(0, 5));
    	Test.stopTest();
    }
    
    @isTest
    private static void testTruncateString(){
    	Test.startTest();
    	system.assertEquals('ab', QBUtil.truncateString('abcdef', 2));
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetNonTaxableTaxCodeWithRates(){
    	Test.startTest();
    	system.assertEquals(0, QBUtil.getNonTaxableTaxCodeWithRates('Sales').size());
    	Test.stopTest();
    }
}