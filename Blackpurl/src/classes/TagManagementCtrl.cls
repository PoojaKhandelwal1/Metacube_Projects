/** 
* Author: Tarun Khandelwal
* Since: Sept 13, 2017 
* Name: TagManagementCtrl 
* Description: Apex class which contains all remoted methods related to Tag management Page.
**/
global with sharing class TagManagementCtrl {
    
    global TagManagementCtrl (NewHomePageCtrl controller){}
	public TagManagementCtrl() {}
	
	@RemoteAction
    global static String getTagList() {
    	List<Tag__c> tagList = SOQLUtil.getTagList(new Map<String, String>{});
    	List<TagWrapper> tagWrapperList = new List<TagWrapper>();
    	for(Tag__c tagRec : tagList){
    		tagWrapperList.add(new TagWrapper(tagRec)); 
    	}
    	return BPUtility.getEncodedString(System.JSON.serialize(tagWrapperList));
    }
    
    @RemoteAction
    global static String saveTag(String tagJSONString) {
    	tagJSONString = BPUtility.getDecodedString(tagJSONString);
    	TagWrapper tagObj = (TagWrapper) System.JSON.deserialize(tagJSONString, TagWrapper.class);
    	try {
	    	if(String.isNotBlank(tagObj.Name)) {
	    		List<Tag__c> tagList;
	    		if(tagObj.Id != null) {
	    			if(AccessControl.ifObjectFieldIsAccessible('Tag__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
	    			tagList = [Select Name__c from Tag__c where Id =: tagObj.Id];
	    		}
	    		Tag__c tagRec = new Tag__c(Id = tagObj.Id);
	    		tagRec.Name__c = tagObj.Name;
	    		tagRec.Active__c = (tagObj.IsActive != null) ? tagObj.IsActive : false;
	    		
	    		if(AccessControl.ifObjectFieldIsUpdateable('Tag__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	    		if(AccessControl.ifObjectFieldIsCreateable('Tag__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	    		upsert tagRec;
	    		if(tagObj.Id != null && tagList.size() > 0) {
	    			replaceTagFromSobjects(tagList[0].Name__c, tagObj.Name);
	    		}
	    	}
    	} catch(Exception e) {
    		JSONGenerator gen = JSON.createGenerator(true);
         	gen.writeStartArray();
         	gen.writeStartObject();
         	gen.writeStringField('ErrorMessage', 'Tag - ' + tagObj.Name + ' already exists.');
         	gen.writeEndObject();
         	gen.writeEndArray();
         	return BPUtility.getEncodedString(gen.getAsString());
    	}
    	return getTagList();
    }
    
    @RemoteAction
    global static String getTagUsedCounter(String tagJSONString) {
    	tagJSONString = BPUtility.getDecodedString(tagJSONString);
    	TagWrapper tagObj = (TagWrapper) System.JSON.deserialize(tagJSONString, TagWrapper.class);
    	Integer tagUsedCounter = 0;
    	if(String.isNotBlank(tagObj.Name)) {
    		tagUsedCounter = TagUtil.getSObjectListWhereTagIsUsed(tagObj.Name, new List<String>{'Part__c', 'Customer_Owned_Unit__c'}).size();
    	}
    	JSONGenerator gen = JSON.createGenerator(true);
     	gen.writeStartObject();
     	gen.writeNumberField('UsedCounter', tagUsedCounter);
     	gen.writeEndObject();
    	return BPUtility.getEncodedString(gen.getAsString());
    }
    
    @RemoteAction
    global static String removeTag(String tagJSONString) {
    	tagJSONString = BPUtility.getDecodedString(tagJSONString);
    	TagWrapper tagObj = (TagWrapper) System.JSON.deserialize(tagJSONString, TagWrapper.class);
    	
    	if(String.isNotBlank(tagObj.Id)) {
    		Tag__c tagRec = new Tag__c(Id = tagObj.Id);
    		if(AccessControl.ifObjectIsDeletable('Tag__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
    		delete tagRec;
    	}
    	removeTagFromSobjects(tagObj.Name);
    	return getTagList();
    }
    
    public static void removeTagFromSobjects(String tagNameToRemove) {
    	List<Sobject> sobjectList = TagUtil.getSObjectListWhereTagIsUsed(tagNameToRemove, new List<String>{'Part__c', 'Customer_Owned_Unit__c'});
    	TagUtil.removeTagFromSobjectList(tagNameToRemove, sobjectList);
    }
    
    public static void replaceTagFromSobjects(String oldTagName, String newTagName) {
    	List<Sobject> sobjectList = TagUtil.getSObjectListWhereTagIsUsed(oldTagName, new List<String>{'Part__c', 'Customer_Owned_Unit__c'});
    	TagUtil.replaceTagFromSobjectList(oldTagName, newTagName, sobjectList);
    }
    
    public static List<TagWrapper> getActiveTagList() {
    	List<Tag__c> tagList = SOQLUtil.getTagList(new Map<String, String>{'Active__c' => 'true'});
    	List<TagWrapper> tagWrapperList = new List<TagWrapper>();
    	for(Tag__c tagRec : tagList){
    		tagWrapperList.add(new TagWrapper(tagRec)); 
    	}
    	return tagWrapperList;
    }
}