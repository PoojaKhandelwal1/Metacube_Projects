@isTest
private class QBAccountingTest {
    @testsetup
    private static void setup(){
    	Category__c categoryRec1 = TestDataFactory.createCategory('category001');
    	Category__c categoryRec2 = TestDataFactory.createCategory('category002');
    	Category__c categoryRec3 = TestDataFactory.createCategory('category003');
    	categoryRec1.Type__c = 'Fee';
    	categoryRec2.Type__c = 'Tax';
    	categoryRec3.Type__c = 'Labour';
    	update categoryRec1;
    	update categoryRec2;
    	update categoryRec3;
    }
    
    @isTest
    private static void testRunAll(){
    	Test.startTest();
    	Category__c categoryRec = [SELECT Name FROM Category__c LIMIT 1];
    	QBAccounting.runAll();
    	system.assertEquals(categoryRec.Name, 'category001');
    	Test.stopTest();
    }
    
    @isTest
    private static void testSyncAccountSetting(){
    	Test.startTest();
    	Category__c categoryRec = [SELECT Name FROM Category__c LIMIT 1];
    	QBAccounting.syncAccountSetting();
    	system.assertEquals(categoryRec.Name, 'category001');
    	Test.stopTest();
    }
}