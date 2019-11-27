/**
 * Author: Gaurav Tak
 * Since: February 15, 2019
 * Name: BaseIntegrationService
**/
public without sharing abstract class BaseIntegrationService {
	//TODO Get Set
    public IFW_IntegrationConfig__c integrationConfigRec;
    public Map<String, Integration_Entity__mdt> integrationEntityNameToRecMap;
    public String integrationName;
    public Map<String, List<Object>> failedRecordsMap;
    public List<Log__c> errorLogs;
    public virtual Map<String, List<Object>> getAndResetFailedRecordsMap(){ return null;}
    
    public BaseIntegrationService() {
        failedRecordsMap = new Map<String, List<Object>>();
        errorLogs = new List<Log__c>();
    }
    
    public virtual List<WebService_Log__c> sync(List<Object> syncObjList, List<sObject> sobjListToUpdate, String entityType, Map<String, String> integrationEntityNameToActionMap) {
        return null;
    }
    
    public List<IFW_IntegrationConfigItem__c> getIntegrationConfigItemByFieldValues(String integrationConfigId, Map<String, String> integrationEntityNameToActionMap) {
    	if(String.isBlank(integrationConfigId)) {
    		throw new BlackpurlException('Unknown Integration Configuration');
    	}
    	String query = 'SELECT IFW_IntegrationConfig__c, Endpoint_URL__c, HTTP_Method__c, Timeout__c FROM IFW_IntegrationConfigItem__c ' + 
    					'WHERE IFW_IntegrationConfig__c =: integrationConfigId';
    	if(integrationEntityNameToActionMap != null && integrationEntityNameToActionMap.size() > 0) {
    		query += ' AND (';
    		for(String xeroEntityName : integrationEntityNameToActionMap.keySet()) {
    			query += '(Entity_Name__c = \'' + xeroEntityName + '\' AND (Entity_Action__c includes (\'' + integrationEntityNameToActionMap.get(xeroEntityName) + '\'))) OR ';
    		}
    		query = query.subString(0, query.length() - 4);
    		query += ')';
    	}
    	return Database.query(query);													
    }	
}
