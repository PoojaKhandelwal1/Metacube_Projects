@isTest
private class InternalCommentServiceTest {
    @testsetup
    private static void setup(){
    	Account customerRec = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test Fname', 'Test Lname');
    	CO_Header__c coHeaderRec = TestDataFactory.createCOHeader(customerRec.Id);
    	Internal_Comment__c internalCommentRec = TestDataFactory.createInternalComment(coHeaderRec.Id, 'Test Comment');
    }
    
    @isTest
    private static void testSaveInternalComment(){
    	Test.startTest();
    	CO_Header__c coHeaderRec = [SELECT Id FROM CO_Header__c LIMIT 1];
    	Internal_Comment__c internalCommentRec = TestDataFactory.sampleInternalComment(coHeaderRec.Id, 'Test Comment');
    	InternalCommentWrapper internalCommentObj = new InternalCommentWrapper(internalCommentRec);
    	InternalCommentService.saveInternalComment(internalCommentObj);
    	List<Internal_Comment__c> internalCommentList = new List<Internal_Comment__c>([SELECT Id FROM Internal_Comment__c]);
    	system.assertEquals(internalCommentList.size(), 2);
    	Test.stopTest(); 
    }
    
    @isTest
    private static void testSaveInternalCommentOnCO(){
    	Test.startTest();
    	CO_Header__c coHeaderRec = [SELECT Id FROM CO_Header__c LIMIT 1];
    	Internal_Comment__c internalCommentRec = TestDataFactory.sampleInternalComment(coHeaderRec.Id, 'Test Comment');
    	InternalCommentWrapper internalCommentObj = new InternalCommentWrapper(internalCommentRec);
    	InternalCommentService.saveInternalCommentOnCO(json.serialize(internalCommentObj));
    	List<Internal_Comment__c> internalCommentList = new List<Internal_Comment__c>([SELECT Id FROM Internal_Comment__c]);
    	system.assertEquals(internalCommentList.size(), 2);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetInternalCommentListByCOId(){
    	Test.startTest();
    	CO_Header__c coHeaderRec = [SELECT Id FROM CO_Header__c LIMIT 1];
    	List<InternalCommentWrapper> internalCommentObjList = new List<InternalCommentWrapper>(InternalCommentService.getInternalCommentListByCOId(coHeaderRec.Id));
    	system.assertEquals(internalCommentObjList.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testDeleteInternalCommentFromCO(){
    	Test.startTest();
    	Internal_Comment__c internalCommentRec = [SELECT Id FROM Internal_Comment__c LIMIT 1];
    	InternalCommentService.deleteInternalCommentFromCO(internalCommentRec.Id);
    	List<Internal_Comment__c> internalCommentListAfterDeletion = new List<Internal_Comment__c>([SELECT Id FROM Internal_Comment__c]);
    	system.assertEquals(internalCommentListAfterDeletion.size(), 0);
    	Test.stopTest();
    }
    
    @isTest
    private static void testDeleteInternalCommentsFromCO(){
    	Test.startTest();
    	CO_Header__c coHeaderRec = [SELECT Id FROM CO_Header__c LIMIT 1];
    	InternalCommentService.deleteInternalCommentsFromCO(coHeaderRec.Id);
    	List<Internal_Comment__c> internalCommentListAfterDeletion = new List<Internal_Comment__c>([SELECT Id FROM Internal_Comment__c]);
    	system.assertEquals(internalCommentListAfterDeletion.size(), 0);
    	Test.stopTest();
    }
}