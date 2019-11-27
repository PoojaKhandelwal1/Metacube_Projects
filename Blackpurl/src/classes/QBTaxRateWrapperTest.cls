@isTest
private class QBTaxRateWrapperTest {
    @testsetup
    private static void setup(){
    	QB_Tax_Rate__c taxRateRec = TestDataFactory.createQBTaxRate();
    }
    
    @isTest
    private static void testQBTaxRateWrapper(){
    	Test.startTest();
    	String query = 'SELECT ';  
    	for(String fieldsName : QBTaxRateWrapper.getFieldList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
        	query += fieldsName + ', ';  
    	}
    	query = query.substring(0, query.length()-2);
    	query += ' FROM QB_Tax_Rate__c LIMIT 1';
    	QB_Tax_Rate__c taxRateRec = Database.query(query);
    	QBTaxRateWrapper taxRateObj = new QBTaxRateWrapper(taxRateRec);
    	system.assertEquals(taxRateRec.Name, taxRateObj.Name);
    	Test.stopTest();
    }
}