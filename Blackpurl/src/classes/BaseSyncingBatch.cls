global without sharing abstract class BaseSyncingBatch implements Database.Batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    public Set<Id> idSet;
    public String integrationEntityName;
    public List<BaseIntegrationService> integrationInstanceList;
    public List<WebService_Log__c> webserviceLogs;
    global List<Sobject> sobjctListToUpdate;
    
    public BaseSyncingBatch() {
        this.webserviceLogs = new List<WebService_Log__c>();
        sobjctListToUpdate = new List<Sobject>();
    }
    
    public BaseSyncingBatch(Set<Id> idSet, List<BaseIntegrationService> integrationInstanceList) {
        this.idSet = idSet;
        this.integrationInstanceList = integrationInstanceList;
    }
    
    global virtual Database.QueryLocator start(Database.BatchableContext bc) {
        return null;
    }
    
    global virtual void execute(Database.batchableContext bc, List<Sobject> listItemCategories) {
    }
    
    global virtual void finish(Database.batchableContext bc){
    }
    
    public void setIdSet(Set<Id> idSet) {
        this.idSet = idSet;
    }
    
    public void setIntegrationInstanceList(List<BaseIntegrationService> integrationInstanceList) {
        this.integrationInstanceList = integrationInstanceList;
    }
    
    public String getBaseQuery(String objectAPIName, List<String> fieldsList, String integrationEntityName) {
        return getBaseQuery(objectAPIName, fieldsList, integrationEntityName, new Map<String, List<String>>());
    }
    
    public String getBaseQuery(String objectAPIName, List<String> fieldsList, String integrationEntityName, 
                                                        Map<String, List<String>> childObjectAPINameToFieldsListMap) {
        this.integrationEntityName = integrationEntityName;
        String syncFlag = integrationInstanceList[0].integrationEntityNameToRecMap.get(integrationEntityName).Sync_Flag_API_Name__c;
        
        String query = 'SELECT ';
        for(String fieldName : fieldsList){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        for(String childObjectAPIName : childObjectAPINameToFieldsListMap.keyset()) {
        	query += '( SELECT ';
        	for(String fieldName : childObjectAPINameToFieldsListMap.get(childObjectAPIName)) {
	            fieldName = BPUtility.escapeSingleQuotes(fieldName);
	            query += fieldName + ', ';
	        }
	        query = query.substring(0, query.length() - 2);
        	query += ' FROM ' + childObjectAPIName + ' ), ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ' + objectAPIName + ' WHERE ' + syncFlag + ' = true';
        if(idSet != null) {
            query += ' AND Id IN: idSet';
        }
        return query;
    }
    
    public void finishAction() {
        updateSobjectList(this.sobjctListToUpdate);
        if(!integrationInstanceList[0].failedRecordsMap.IsEmpty()) {
            IntegrationExceptionHandler integrationExceptionHandler = new IntegrationExceptionHandler(this.integrationEntityName);
            for(String exceptionMessage : integrationInstanceList[0].failedRecordsMap.keySet()) {
                integrationExceptionHandler.handleException(exceptionMessage, integrationInstanceList[0].failedRecordsMap.get(exceptionMessage));
            }
        }
        if(integrationInstanceList[0].errorLogs.size() > 0) {
            insert integrationInstanceList[0].errorLogs;
        }
        if(!this.webserviceLogs.isEmpty()) {
           insert this.webserviceLogs;
        }
    }
    
    public void updateSobjectList(List<Sobject> sobjectList){
    	Map<Id,Sobject> IdToSObjectValueMap = new Map<Id,Sobject>();
    	for(Sobject sObjectRec : sobjectList) {
    		IdToSObjectValueMap.put(sObjectRec.Id,sObjectRec);
        }
	    if(IdToSObjectValueMap != null && IdToSObjectValueMap.size() > 0) {
	        update IdToSObjectValueMap.values();
		}
	}
}
