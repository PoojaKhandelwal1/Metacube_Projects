/**
 * Author: Nidhi Sharma
 * Since: July 17, 2017
 * Name: ActivityHistory
**/
public with sharing class ActivityHistory {
    
    private static Set<String> numberTypeLiteralSet = new Set<String> {'DOUBLE', 'DECIMAL', 'LONG', 'CURRENCY'}; 
                                                           
    @future
    public static void createActivityHistory(String action, String sourceEntity, String sourceEntityId, String alternateEntity, 
    											String alternateEntityId, String referenceEntityId) {
        if(AccessControl.ifObjectFieldIsCreateable('Activity_History__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        Activity_History__c activityHistoryRec = setFields(action, sourceEntityId, sourceEntity, alternateEntityId, alternateEntity);
        activityHistoryRec = getFeedText(action, sourceEntity, sourceEntityId, alternateEntity, alternateEntityId, new List<Activity_History__c> {activityHistoryRec});
        if(String.isNotBlank(referenceEntityId)) {
        	activityHistoryRec.Source_Entity_Id__c = referenceEntityId;
        }
        if(activityHistoryRec.Action__c == 'Price File Import') {
        	activityHistoryRec.Source_Entity__c = 'Price File';
        }
        insert activityHistoryRec;
    }
    
    private static Activity_History__c setFields(String action, Id sourceEntityId, String sourceEntity, Id alternateEntityId, String alternateEntity) {
        Activity_History__c activityHistoryRec = new Activity_History__c(User__c = UserInfo.getUserId());
        activityHistoryRec.Action__c = action;
        activityHistoryRec.Source_Entity_Id__c = sourceEntityId;
        activityHistoryRec.Source_Entity__c = sourceEntity;
        activityHistoryRec.Alternate_Entity_Id__c = alternateEntityId;
        activityHistoryRec.Alternate_Entity__c = alternateEntity;
        return activityHistoryRec;
    }
    
    private static Activity_History__c getFeedText(String action, String sourceEntity, String sourceEntityId, String alternateEntity, String alternateEntityId, List<Activity_History__c> activityHistoryRecList) {
        if(AccessControl.ifObjectFieldIsAccessible('Activity_History_Template__mdt') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
       	Activity_History__c activityHistoryRec;
      	if(activityHistoryRecList.size() > 0){
       		activityHistoryRec = activityHistoryRecList[0];
      	 }
        List<Activity_History_Template__mdt> activityHistoryTemplateMTDT = 
                [SELECT Fields_To_Query__c, Feed_Text_Template__c, Color_Code__c FROM Activity_History_Template__mdt
                        WHERE Action__c =: action AND Source_Entity__c =: sourceEntity AND Alternate_Entity__c =: alternateEntity];
        
        List<String> fieldsToQuery = new List<String>();
        String feedText;
        if(activityHistoryTemplateMTDT.size() > 0) {                    
            
            String objName = (Id.valueOf(sourceEntityId)).getSObjectType().getDescribe().getName();
            fieldsToQuery = activityHistoryTemplateMTDT[0].Fields_To_Query__c.split(',');
            String query = 'SELECT Id';
            for(String fieldName : fieldsToQuery) {
                query += ', ' + fieldName;
            }
            query += ' FROM ' + objName + ' WHERE Id =: sourceEntityId';
            List<SObject> sobjList = Database.query(query);
            
            String namespace = '';
            if(objName.contains(Constants.NAMESPACE)) {
            	namespace = Constants.NAMESPACE;
            }
            if(sobjList.size() > 0) {
            	Sobject sobjRec = sobjList[0];
            	feedText = activityHistoryTemplateMTDT[0].Feed_Text_Template__c;
            
	            if(String.isBlank(alternateEntityId)) {
	                feedText = feedText.replace('<a href="#/ViewCustomer?Id=$#hrefId">', '').replace('</a>', '');
	            } else if(feedText.contains('hrefId')) {
	                feedText = feedText.replace('$#hrefId', alternateEntityId);
	            }
	            
	            for(String fieldName : fieldsToQuery) {
	                String value = '';
	                if(fieldName.countMatches('.') == 0) {
	                	String fieldType = String.valueOf(sobjRec.getSObjectType().getDescribe().fields.getMap().get(namespace + fieldName).getDescribe().getType());
	                	if(numberTypeLiteralSet.contains(fieldType)) {
	                		value = String.valueOf((Decimal.valueOf(String.valueOf(sobjRec.get(fieldName)))).setScale(2, RoundingMode.HALF_UP));
	                	} else {
	                    	value = String.valueOf(sobjRec.get(fieldName));
	                	}
	                } else if(fieldName.countMatches('.') == 1) {
	                    value = String.valueOf(sobjRec.getSobject(Constants.NAMESPACE + fieldName.substringBefore('.')).get(fieldName.substringAfter('.')));
	                } else if(fieldName.countMatches('.') == 2) {
	                    value = String.valueOf(sobjRec.getSobject(Constants.NAMESPACE + fieldName.substringBefore('.')).getSobject(Constants.NAMESPACE + fieldName.substringAfter('.')).get(fieldName.substringAfterLast('.')));
	                }
	                feedText = feedText.replace('$#' + fieldName, value);
	            }
	            activityHistoryRec.Color_Code__c = activityHistoryTemplateMTDT[0].Color_Code__c;
	        	activityHistoryRec.Feed_Text__c = feedText;
            }
        }
        return activityHistoryRec;
    }
    
    public static List<String> getActivityHistoryFieldList() {
        return new List<String> {'Feed_Text__c',
                                'Source_Entity_Id__c',
                                'Source_Entity__c',
                                'Time_Period__c',
                                'User__r.Name',
                                'Color_Code__c'
                                };
    }
    
    public static String getActivityHistoryList(String historyTypeJSON) {
    	
    	String permissionsJson = NewHomePageCtrl.getUserPermissions(UserInfo.getUserId());
		UserGroupWrapper groupDetails = (UserGroupWrapper)System.JSON.deserialize(permissionsJson, UserGroupWrapper.class);
		Map<String, Map<String,Boolean>> permissionNameToPermissionTypeToIsAccessibleMap = groupDetails.GroupOnlyPermissions; 
		List<String> sourceEntityByPermissions = new List<String>(); 
    	for(String  permissionType:  Constants.permissionTypeToSourceEntityMap.keyset()){
    		String[] permissionTypeList = permissionType.split(','); 
    		Boolean isPermitted = false;
    		for(String permissionTypeRecord : permissionTypeList){
    			if(permissionNameToPermissionTypeToIsAccessibleMap.get(permissionTypeRecord).get(Constants.permissionTypeToLabelListMap.get(permissionTypeRecord)[0])){
    				isPermitted = true;
    				break;
    			} 
    		}
    		if(isPermitted == false){
    			SourceEntityByPermissions.add(Constants.permissionTypeToSourceEntityMap.get(permissionType));
    		}
    	}
    																			
    	ActivityTypeWrapper historyTypeObject = (ActivityTypeWrapper)System.JSON.deserialize(historyTypeJSON, ActivityTypeWrapper.class);
    	List<Activity_History__c> activityHistoryList = new List<Activity_History__c>();
        if(historyTypeObject.Type == 'My Activity') {
            activityHistoryList = SOQLUtil.getActivityHistoryList(new Map<String, String>{'User__c' => UserInfo.getUserId()}, historyTypeObject.RequiredNumberOfRecords,SourceEntityByPermissions,false);
        } else if(historyTypeObject.Type == 'Store Activity'){
            activityHistoryList = SOQLUtil.getActivityHistoryList(new Map<String, String>(), historyTypeObject.RequiredNumberOfRecords,SourceEntityByPermissions,false);
        } else if(historyTypeObject.Type == 'Integration'){
            activityHistoryList = SOQLUtil.getActivityHistoryList(new Map<String, String>(), historyTypeObject.RequiredNumberOfRecords,SourceEntityByPermissions,true);
        }
        List<ActivityHistoryWrapper> activityWrapperObjList = new List<ActivityHistoryWrapper>();
        for(Activity_History__c activityHistoryRec : activityHistoryList) {
            if(activityHistoryRec.Feed_Text__c.contains('[You/username]')) {
                String actionCreatedBy = (UserInfo.getUserId() == activityHistoryRec.User__c) ? 'You' : activityHistoryRec.User__r.Name;
                activityHistoryRec.Feed_Text__c = activityHistoryRec.Feed_Text__c.replace('[You/username]', actionCreatedBy);
            }
            if(activityHistoryRec.Feed_Text__c.contains('[time period]')) {
                activityHistoryRec.Feed_Text__c = activityHistoryRec.Feed_Text__c.replace('[time period]', activityHistoryRec.Time_Period__c);
            }
            activityWrapperObjList.add(new ActivityHistoryWrapper(activityHistoryRec));
        } 
        return System.JSON.serialize(activityWrapperObjList);
    }
    
    
    public class ActivityHistoryWrapper {
         
        public String FeedText;
        public String SourceEntityId;
        public String SourceEntityName;
        public String ColorCode;
        
        public ActivityHistoryWrapper(Activity_History__c activityHistoryRec) {
            this.FeedText = activityHistoryRec.Feed_Text__c;
            this.SourceEntityId = activityHistoryRec.Source_Entity_Id__c;
            this.SourceEntityName = activityHistoryRec.Source_Entity__c;
            this.ColorCode = activityHistoryRec.Color_Code__c;
        }
    }
    
    public class ActivityTypeWrapper {
    	public String Type;
    	public Integer RequiredNumberOfRecords;
    	
    	public ActivityTypeWrapper() {
    		
    	}
    }
}