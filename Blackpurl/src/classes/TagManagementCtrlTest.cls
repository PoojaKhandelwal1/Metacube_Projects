@isTest 
private class TagManagementCtrlTest {
    
    @testSetup
    private static void setupTestData() {
    	List<Tag__c> tagList = new List<Tag__c>();
    	for(Integer i = 0; i < 5; i++) {
    		tagList.add(TestDataFactory.sampleTag('Test tag' + i));
    	}
    	insert tagList;
    }
    
    @isTest
    private static void getTagListTest() {
    	String tagList = BPUtility.getDecodedString(TagManagementCtrl.getTagList());
    	List<TagWrapper> resultJSON = (List<TagWrapper>)Json.deserialize(tagList, List<TagWrapper>.class);
    	system.assertEquals(5, resultJSON.size());
    }
    
    @isTest
    private static void saveTagTest() {
    	Tag__c tagRec = [SELECT Id, Name__c, Active__c, CreatedDate from Tag__c LIMIT 1];
    	TagWrapper tagWrapper = new TagWrapper(tagRec);
    	String tagJson = BPUtility.getEncodedString(System.JSON.serialize(tagWrapper, true));
    	String tagList = BPUtility.getDecodedString(TagManagementCtrl.saveTag(tagJson));
    	List<TagWrapper> resultJSON = (List<TagWrapper>)Json.deserialize(tagList, List<TagWrapper>.class);
    	system.assertEquals(5, resultJSON.size()); 
    }
    
    @isTest
    private static void getTagUsedCounterTest() {
    	Tag__c tagRec = [SELECT Id, Name__c, Active__c, CreatedDate from Tag__c LIMIT 1];
    	TagWrapper tagWrapper = new TagWrapper(tagRec);
    	String tagJson = BPUtility.getEncodedString(System.JSON.serialize(tagWrapper, true));
    	String tagList = BPUtility.getDecodedString(TagManagementCtrl.getTagUsedCounter(tagJson));
    	JSONGenerator gen = JSON.createGenerator(true);
     	gen.writeStartObject();
     	gen.writeNumberField('UsedCounter', 0);
     	gen.writeEndObject();
    	system.assertEquals(tagList, gen.getAsString());  
    }
    
    @isTest
    private static void removeTagTest() {
    	Tag__c tagRec = [SELECT Id, Name__c, Active__c, CreatedDate from Tag__c LIMIT 1];
    	TagWrapper tagWrapper = new TagWrapper(tagRec);
    	String tagJson = BPUtility.getEncodedString(System.JSON.serialize(tagWrapper, true));
    	String tagList = BPUtility.getDecodedString(TagManagementCtrl.removeTag(tagJson));
    	List<TagWrapper> resultJSON = (List<TagWrapper>)Json.deserialize(tagList, List<TagWrapper>.class);
    	system.assertEquals(4, resultJSON.size());
    }
    
    @isTest
    private static void getActiveTagListTest() {
    	List<TagWrapper> tagWrapperList = TagManagementCtrl.getActiveTagList();
    	system.assertEquals(5, tagWrapperList.size());
    }
}