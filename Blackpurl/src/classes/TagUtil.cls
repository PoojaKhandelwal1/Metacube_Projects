/** 
* Author: Tarun Khandelwal
* Since: Sept 13, 2017 
* Name: TagManagementCtrl 
* Description: Utility class for get and set tags for records.
**/
public with sharing class TagUtil {
    
    public static List<String> getTagsList(Sobject sobj) {
    	List<String> tagList = new List<String>();
    	tagList.addAll(convertStringIntoList(sobj, 'Assigned_Tag_1__c'));
    	tagList.addAll(convertStringIntoList(sobj, 'Assigned_Tag_2__c'));
    	return tagList;
    }
    
    public static List<String> convertStringIntoList(Sobject sobj, String fieldName) {
    	List<String> tagList = new List<String>();
    	if(sobj.get(fieldName) != null && String.valueOf(sobj.get(fieldName)).length() > 0) {
    		for(String assignedTagStr : String.valueOf(sobj.get(fieldName)).split(';')) {
    			if(assignedTagStr.trim().length() > 0) {
    				tagList.add(assignedTagStr);	
    			}
    		}
    	}
    	return tagList;
    }
    
    public static List<String> convertTagListIntoTagString(List<String> tagList) {
    	String field_1_Tag_Str = ';'; 
    	String field_2_Tag_Str = ';'; 
    	Integer MAX_LIMIT_PER_TEXT_FIELD = 12;
    	if(tagList.size() > 0) {
    		for(Integer i = 0; (i < MAX_LIMIT_PER_TEXT_FIELD && i < tagList.size()); i++) {
    			field_1_Tag_Str += (tagList[i] + ';');
    		}
    		if(tagList.size() > MAX_LIMIT_PER_TEXT_FIELD) {
	    		for(Integer i = MAX_LIMIT_PER_TEXT_FIELD; (i < (2 * MAX_LIMIT_PER_TEXT_FIELD) && i < tagList.size()); i++) {
	    			field_2_Tag_Str += (tagList[i] + ';');
	    		}
	    	}
    	}
    	if(field_1_Tag_Str.length() == 1) {
    		field_1_Tag_Str = '';
    	}
    	if(field_2_Tag_Str.length() == 1) {
    		field_2_Tag_Str = '';
    	}
    	List<String> tagStrListForFields = new List<String>();
    	tagStrListForFields.add(field_1_Tag_Str);
    	tagStrListForFields.add(field_2_Tag_Str);
    	return tagStrListForFields;
    }
    
    public static List<Sobject> getSObjectListWhereTagIsUsed(String tagName, List<String> objectAPIList) {
    	List<Sobject> sobjList = new List<Sobject>();
    	if(objectAPIList.size() < 3) {
    		for(String objectAPIName : objectAPIList) {
    			sobjList.addAll(getSObjectListWhereTagIsUsed(tagName, objectAPIName));
    		}
    	}
    	return sobjList;
    }
    
    public static List<Sobject> getSObjectListWhereTagIsUsed(String tagName, String objectAPIName) {
    	String query = 'SELECT Assigned_Tag_1__c, Assigned_Tag_2__c FROM ' + objectAPIName + ' WHERE Assigned_Tag_1__c LIKE \'%;'+ tagName + ';%\' ';
    	query += ' OR Assigned_Tag_2__c LIKE \'%;'+ tagName + ';%\' LIMIT ' + SOQLUtil.getAvailableQueryRowsLimit();
    	List<Sobject> sobjList = Database.query(query);
    	return sobjList;
    }
    
    public static void removeTagFromSobjectList(String tagName, List<Sobject> sobjectList) {
    	updateRelatedSobjectList(tagName, ';', sobjectList);
    }
    
    public static void replaceTagFromSobjectList(String oldTagName, String newTagName, List<Sobject> sobjectList) {
    	updateRelatedSobjectList(oldTagName, ';' + newTagName + ';', sobjectList);
    }
    
    private static void updateRelatedSobjectList(String oldTagName, String newTagName, List<Sobject> sobjectList) {
    	for(Sobject sobj : sobjectList) {
    		String assignedTag1 = (sobj.get('Assigned_Tag_1__c') != null) ? String.valueOf(sobj.get('Assigned_Tag_1__c')) : '';
    		if(assignedTag1.contains(';' + oldTagName + ';')) {
    			assignedTag1 = assignedTag1.replace(';' + oldTagName + ';', newTagName);
    		}
    		String assignedTag2 = (sobj.get('Assigned_Tag_2__c') != null) ? String.valueOf(sobj.get('Assigned_Tag_2__c')) : '';
    		if(assignedTag2.contains(';' + oldTagName + ';')) {
    			assignedTag2 = assignedTag2.replace(';' + oldTagName + ';', newTagName);
    		}
    		sobj.put('Assigned_Tag_1__c', assignedTag1);
    		sobj.put('Assigned_Tag_2__c', assignedTag2);
    	}
    	if(sobjectList.size() > 0) {
    		update sobjectList;
    	}
    }
}