@isTest
private class PartCategoryServiceTest {
    @testsetup
    private static void setup(){
    	Account vendor = TestDataFactory.createVendor('Test Vendor');
    	Category__c categoryRec = TestDataFactory.createCategory('category001');
    	Part__c part = TestDataFactory.createPart(vendor.Id,  10, 20, 50, 100, 100, categoryRec.Id);
    }
    
    @isTest
    private static void testSyncParts(){
    	Test.startTest();
    	List<Part__c> partList = [SELECT Id FROM Part__c];
    	Set<Id> partIdSet = new Set<Id>();
    	for(Part__c part : partList){
    		partIdSet.add(part.Id);
    	}
    	PartCategoryService.syncParts(partIdSet);
    	system.assertEquals(partList.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testSyncAccountingServer(){
    	Test.startTest();
    	String query;   
        query = 'SELECT '; 
        for(String fieldsName : AccountingPart.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM  Part__c LIMIT 1';
        Part__c partRec = Database.query(query);
        AccountingPart partRecord = new AccountingPart(partRec);
        List<Part__c> partList = [SELECT Id FROM Part__c];
        
        PartCategoryService.syncAccountingServer(partRecord, partList);
        system.assertEquals(partList.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testSyncToQuickBooks(){
    	Test.startTest();
    	TestDataFactory.createQBConfig();
    	TestDataFactory.createGeneralConfig(10);
    	String query;   
        query = 'SELECT '; 
        for(String fieldsName : AccountingPart.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM  Part__c LIMIT 1';
        Part__c partRec = Database.query(query);
        AccountingPart partRecord = new AccountingPart(partRec);
        List<Part__c> partList = [SELECT Id FROM Part__c];
        PartCategoryService.syncToQuickBooks(partRecord, partList);
        system.assertEquals(partList.size(), 2);
    	Test.stopTest();
    }
    
    @isTest
    private static void testSyncToQuickBooksWithNullEndPointURL(){
    	Test.startTest();
    	QuickBooks_Configurations__c qbConfig = TestDataFactory.createQBConfig();
    	qbConfig.End_Point_URL__c = null;
    	update qbConfig;
    	TestDataFactory.createGeneralConfig(10);
    	String query;   
        query = 'SELECT '; 
        for(String fieldsName : AccountingPart.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM  Part__c LIMIT 1';
        Part__c partRec = Database.query(query);
        AccountingPart partRecord = new AccountingPart(partRec);
        List<Part__c> partList = [SELECT Id FROM Part__c];
        PartCategoryService.syncToQuickBooks(partRecord, partList);
        system.assertEquals(partList.size(), 2);
    	Test.stopTest();
    }
    
    @isTest
    private static void testSyncToQuickBooksForException(){
    	Test.startTest();
    	String query;   
        query = 'SELECT '; 
        for(String fieldsName : AccountingPart.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM  Part__c LIMIT 1';
        Part__c partRec = Database.query(query);
        AccountingPart partRecord = new AccountingPart(partRec);
        List<Part__c> partList = [SELECT Id FROM Part__c];
        PartCategoryService.syncToQuickBooks(partRecord, partList);
        system.assertEquals(partList.size(), 2);
    	Test.stopTest();
    }
}