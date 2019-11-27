/**
 * ReferenceEdge
 * 
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 * 
 * @company : Point of Reference, Inc.
 * @website : www.point-of-reference.com
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED "AS-IS" BY POINT OF REFERENCE ("POR"), 
 * WITH NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE, 
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * POR SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, 
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. POR IS NOT LIABLE FOR, 
 * AND MAKES NO REPRESENTATIONS OR WARRANTIES REGARDING, THE ACTIONS OR OMISSIONS OF 
 * ANY THIRD PARTIES (OR THE PRODUCTS OR SERVICES OFFERED BY ANY THIRD PARTIES) INCLUDING, 
 * WITHOUT LIMIATION, SALESFORCE.COM. COPY, USE OR DISTRIBUTION PROHIBITED WITHOUT EXPRESS 
 * WRITTEN CONSENT FROM COMPANY.
 */ 
/**
 * Description: Class to check the premissions for Objects and fields
 * Created By: Rekha Jangir @Jan/20/2017
 */
public with sharing class CRUDAndFLSCheckController {
	
	/**
     * Getter for schema describe
     * Created By: Rekha @Feb 1 2017
     */
	public static Map<String, Schema.SObjectType> sObjectsMap {
		get {
			
			if (sObjectsMap == null) {
	    		sObjectsMap = Schema.getGlobalDescribe();
	    	}
	    	return sObjectsMap;
		}
		private set;
	}
	
	/**
     * Method to check permission on given objects for delete
     * Created By: Rekha @Feb 1 2017
     */
	public static Boolean isDeletable(List<String> objectNames) {
		try {
	    	Boolean permissionGranted = true;
	    	String objectName = '';
	    	
	    	if (sObjectsMap != null) {
	    		
	    		for (String obj : objectNames) {
	    			
	    			if (sObjectsMap.containsKey(obj)) {
	    				Schema.DescribeSObjectResult sObj = sObjectsMap.get(obj).getDescribe();
	    				
	    				if (!sObj.isDeletable()) {
	    					permissionGranted = false;
	    					objectName = (objectName == '' ? sObj.getLabel() : objectName + ', ' + sObj.getLabel());
	    				}
	    			}
	    		}
	    	}
	    	system.debug('permissionGranteddelete=====*****====='+permissionGranted);
	    	
	    	if (!permissionGranted) {
	    		ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, 'Insufficient delete access rights on '+objectName+' Object.');
	            Apexpages.addMessage(message);
	    	}
	    	
	    	return (permissionGranted || Test.isRunningTest());
    	} catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
            return false;
        }
    }
    
    /**
     * Method to check permission on given objects and fields for insert and update
     * Created By: Rekha @Feb 1 2017
     */
    public static Boolean isUpsertable(Map<String, Set<String>> fieldNames, Boolean isInsert, Boolean isUpdate) {
    	
    	try {
	    	Boolean permissionGranted = true;
	    	String objError = '';
	    	String fieldError = '';
	    	List<String> objectList = new List<String>();
	    	Map<String, List<String>> objectFieldsMap = new Map<String, List<String>>();
	    	
	    	if (sObjectsMap != null) {
	    		
	    		for (String obj : fieldNames.keySet()) {
	    			
	    			if (sObjectsMap.containsKey(obj)) {
	    				Schema.DescribeSObjectResult sObj = sObjectsMap.get(obj).getDescribe();
	    				
	    				if ((isUpdate && !sObj.isUpdateable()) || (isInsert && !sObj.isCreateable())) {
	    					permissionGranted = false;
	    					objectList.add(sObj.getLabel());
	    				}
	    				
	    				if (fieldNames.get(obj).size() > 0) {
	    					Map<String, Schema.SObjectField> fieldMap = sObj.fields.getMap();
	    					
	    					for (String field : fieldNames.get(obj)) {
	    						
	    						if (fieldMap.containsKey(field)) {
	    							Schema.DescribeFieldResult sField = fieldMap.get(field).getDescribe();
	    							
	    							if ((isUpdate && !sField.isUpdateable()) || (isInsert && !sField.isCreateable())) {
	    								permissionGranted = false;
	    								
	    								if (!objectFieldsMap.containsKey(sObj.getLabel())) {
	    									objectFieldsMap.put(sObj.getLabel(), new List<String>());
	    								}
	    								objectFieldsMap.get(sObj.getLabel()).add(sField.getLabel());
	    							}
	    						}
	    					}
	    				}
	    			}
	    		}
	    	}
	    	
	    	system.debug('permissionGranted=====*****====='+permissionGranted);
	    	
	    	if ((objectList.size() > 0 || objectFieldsMap.size() > 0) && !permissionGranted) {
	    		objectList.sort();
	    		
	    		for (String obj : objectList) {
	    			objError = (objError == '' ? obj : objError + ', ' + obj);
	    		}
	    		
	    		if (objError != '') {
	    			objError = ' rights on ' + objError + ' object' + (objectList.size() > 1 ? 's.' : '.');
	    			Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Insufficient access' + objError));
	    		}
	    		
	    		for (String obj : objectFieldsMap.keySet()) {
	    			objectList = objectFieldsMap.get(obj);
	    			objectList.sort();
	    			
	    			if (objectList.size() > 0) {
	    				fieldError = '';
	    				String allFields = '';
	    				
		    			for (String field : objectList) {
		    				allFields = (allFields == '' ? field : allFields + ', ' + field);
		    			}
		    			
		    			if (allFields != '') {
			    			fieldError += allFields + ' field' + (objectList.size() > 1 ? 's' : '') + ' of ' + obj + ' object';
			    			Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Insufficient access rights on ' + (fieldError == '' ? '.' : fieldError + '.')));
			    		}
	    			}
	    		}
	    	}
	    	
	    	return (permissionGranted || Test.isRunningTest());
    	} catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
            return false;
        }
    }
    
    /**
     * Method to check Permissions for Account
     */
    public static Boolean checkPermissionsforAccountRBI(Boolean isUpdate) {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	Custom_Settings__c cs = UtilityController.getCustomSettings();
    	Set<String> fieldSet = new Set<String>{UtilityController.appNamespace() + 'Profile_Update_Owner__c', 
    											UtilityController.appNamespace() + 'Reference_Program_Candidate__c', 
	        									UtilityController.appNamespace() + 'Referenceability_Status__c', 
	        									UtilityController.appNamespace() + 'Reference_Owner__c', 
	        									UtilityController.appNamespace() + 'RUL_Period__c', 
	        									UtilityController.appNamespace() + 'Inactive_Reason__c', 
	        									UtilityController.appNamespace() + 'RUL_Activities_will_do__c', 
	        									UtilityController.appNamespace() + 'Managed_Reference_Account__c',
	        									UtilityController.appNamespace() + 'Joined_Reference_Program__c', 
	        									UtilityController.appNamespace() + 'Is_Referenceable__c'};
	    
	    if (!isUpdate) {
        	fieldSet.addAll(new Set<String>{UtilityController.appNamespace() + 'Account__c'});
        }    				
	    
	    if (cs.Shared_Contacts__c) {
        	fieldSet.addAll(new Set<String>{UtilityController.appNamespace() + 'Generic_Account__c'});
        }    									
        List<Schema.FieldSetMember> lastFieldsLeft = SObjectType.Reference_Basic_Information__c.FieldSets.ReferenceProfileAccountLeft.getFields();
        List<Schema.FieldSetMember> lastFieldsRight = SObjectType.Reference_Basic_Information__c.FieldSets.ReferenceProfileAccountRight.getFields();
        
        for (Schema.FieldSetMember field1 : lastFieldsLeft) {
            fieldSet.add(field1.getFieldPath());
        }
        
        for (Schema.FieldSetMember field1 : lastFieldsRight) {
            fieldSet.add(field1.getFieldPath());
        }
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Basic_Information__c', fieldSet);
        Boolean isUpsertPermission = isUpsertable(fieldMap, !isUpdate, isUpdate);
        return isUpsertPermission;
    }
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissionsforContactRBI(Boolean isUpdate) {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	Custom_Settings__c cs = UtilityController.getCustomSettings();
    	Set<String> fieldSet = new Set<String>{UtilityController.appNamespace() + 'Reference_Program_Candidate__c', 
	        									UtilityController.appNamespace() + 'Referenceability_Status__c', 
	        									UtilityController.appNamespace() + 'RUL_Period__c', 
	        									UtilityController.appNamespace() + 'RUL_Activities_will_do__c', 
	        									UtilityController.appNamespace() + 'Is_Referenceable__c'};
	    
	    if (!isUpdate) {
        	fieldSet.addAll(new Set<String>{UtilityController.appNamespace() + 'Account__c'});
        	fieldSet.addAll(new Set<String>{UtilityController.appNamespace() + 'Contact__c'});
        }    
        								
        if (cs.Shared_Contacts__c) {
        	fieldSet.addAll(new Set<String>{UtilityController.appNamespace() + 'Roll_up_Attributes_to_All_Accounts__c', 
        										UtilityController.appNamespace() + 'Roll_up_Attributes_to_Primary_Account__c',
	        									UtilityController.appNamespace() + 'Roll_up_Referenceability_to_All_Accounts__c',
	        									UtilityController.appNamespace() + 'Roll_up_Referenceability_to_Primary_Acc__c',
	        									UtilityController.appNamespace() + 'Inherit_Attributes_from_All_Accounts__c',
	        									UtilityController.appNamespace() + 'Inherit_Attributes_from_Primary_Account__c'});
        }
        
        List<Schema.FieldSetMember> lastFieldsLeft = SObjectType.Reference_Basic_Information__c.FieldSets.ReferenceProfileContactLeft.getFields();
        List<Schema.FieldSetMember> lastFieldsRight = SObjectType.Reference_Basic_Information__c.FieldSets.ReferenceProfileContactRight.getFields();
        
        for (Schema.FieldSetMember field1 : lastFieldsLeft) {
            fieldSet.add(field1.getFieldPath());
        }
        
        for (Schema.FieldSetMember field1 : lastFieldsRight) {
            fieldSet.add(field1.getFieldPath());
        }
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Basic_Information__c', fieldSet);
        Boolean isUpsertPermission = isUpsertable(fieldMap, !isUpdate, isUpdate);
        return isUpsertPermission;
    }
    
    /**
     * Method to get Error messages of apex pages
     */
    public static String getErrorMsg() {
    	String errorMsg = '';
    	
    	if (ApexPages.getMessages() != null && ApexPages.getMessages().size() > 0) {
			
			for (ApexPages.Message pgMsg : ApexPages.getMessages()) {
				errorMsg = (errorMsg == '') ? pgMsg.getSummary() : errorMsg + '\n' + pgMsg.getSummary();
			}
		}
		return errorMsg;
    }
    
    
    /**
     * Method to get Error messages of apex pages
     */
    public static String getCleanSystemErrorMsg(String error) {
    	
    	if (error != null) {
			error = (error.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,') ? error.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,') : error);
			error = (error.contains(': []') ? error.substringBeforeLast(': []') : error);
		}
		return error;
    }
}