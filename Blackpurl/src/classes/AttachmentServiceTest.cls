@isTest
private class AttachmentServiceTest {
	
    @testsetup
    private static void setup() {
    	Account customer = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test First Name', 'Test Last Name');
    	CO_Header__c coHeader = TestDataFactory.createCoHeader(customer.Id);
    	List<Attachment> attachmentList = new List<Attachment>();
    	Service_Order_Header__c soHeader = TestDataFactory.createSOHeader(coHeader.Id);
    	for(Integer i = 0; i < 20; i++) {
    		attachmentList.add(TestDataFactory.sampleAttachment(soHeader.Id));
    	}
    	insert attachmentList;
    	Attachment attachment = TestDataFactory.createAttachment(coHeader.Id);
    }

	@isTest
    private static void testGetAttachmentListByParentId() {
    	Test.startTest();
    	CO_Header__c coHeader = [SELECT Id FROM CO_Header__c LIMIT 1];
    	Service_Order_Header__c soHeader = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	Map<Id, List<AttachmentWrapper>> attachmentMap = AttachmentService.getAttachmentListByParentId(coHeader.Id);
    	List<AttachmentWrapper> attachmentList = new List<AttachmentWrapper>(attachmentMap.get(soHeader.Id));
    	system.assertEquals(attachmentList.size(),20);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetAttachmentListByParentIdForSOHeader() {
    	Test.startTest();
    	Service_Order_Header__c soHeader = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	Map<Id, List<AttachmentWrapper>> attachmentMap = AttachmentService.getAttachmentListByParentId(soHeader.Id);
    	List<AttachmentWrapper> attachmentList = new List<AttachmentWrapper>(attachmentMap.get(soHeader.Id));
    	system.assertEquals(attachmentList.size(),20);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetAttachmentListByParentIdForNewMap() {
    	Test.startTest();
    	Account customer = [SELECT Id FROM Account WHERE Is_Customer__c = true LIMIT 1];
    	Map<Id, List<AttachmentWrapper>> attachmentMap = AttachmentService.getAttachmentListByParentId(customer.Id);
    	List<AttachmentWrapper> attachmentList = new List<AttachmentWrapper>(attachmentMap.get(customer.Id));
    	system.assertEquals(attachmentList.size(),0);
    	Test.stopTest();
    }
    
    @isTest
    private static void testDeleteAttachment() {
    	Test.startTest();
    	List<Attachment> attachmentListBeforeDeletion = new List<Attachment>([SELECT Id FROM Attachment]);
    	AttachmentService.deleteAttachment(attachmentListBeforeDeletion[0].Id);
    	List<Attachment> attachmentListAfterDeletion = new List<Attachment>([SELECT Id FROM Attachment]);
    	system.assertEquals(20, attachmentListAfterDeletion.size());
    	Test.stopTest();
    }
    
    @isTest
    private static void testUploadAttachment() {
    	Test.startTest();
    	CO_Header__c coHeader = [SELECT Id FROM CO_Header__c LIMIT 1];
    	Attachment attachment = TestDataFactory.sampleAttachment(coHeader.Id);
    	AttachmentWrapper attachmentWrapper = new AttachmentWrapper(attachment);
    	String attachmentJson = Json.serialize(attachmentWrapper, true);
    	AttachmentService.uploadAttachment(attachmentJson, 'Test Attachment body');
    	List<Attachment> attachmentList = new List<Attachment>([SELECT Id FROM Attachment]);
    	system.assertEquals(attachmentList.size(), 22);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetAttachmentBodyByParentIdAndName() {
    	Test.startTest();
    	CO_Header__c coHeader = [SELECT Id FROM CO_Header__c LIMIT 1];
    	String result = AttachmentService.getAttachmentBodyByParentIdAndName(coHeader.Id, 'Test Attachment');
    	system.assertEquals(EncodingUtil.base64Decode(result), EncodingUtil.base64Decode('Test Attachment body'));
    	Test.stopTest();
    }
}