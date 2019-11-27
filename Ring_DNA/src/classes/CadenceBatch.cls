public with sharing class CadenceBatch implements Database.Batchable<sObject>, Database.stateful {

	public Cadence__c cadence;
	public String objName;
	public static String nameSpace = CadenceConstants.NAMESPACE;

	public CadenceBatch(Id cadID) {
		cadence = CadenceSelector.getCadenceById(cadId); 
		this.objName = cadence.Record_Type__c;
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		String query = formQuery(objName);
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc, List<sObject> scope) {
		RuleCriterionMatcher.participantsList = scope;
	}

	public void finish(Database.BatchableContext bc) {

	}

	private String formQuery(String objName){

		Set<String> allowedFields = new Set<String>();
		String query = 'Select ';

		Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
		for (Schema.SObjectField field : fieldMap.values()) {
			Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
			if (!fieldDescribe.isAccessible()) {
				continue; 
			}
			String fieldName = fieldDescribe.getName();
			allowedFields.add(fieldName);
		}

		if(allowedFields.size() > 0 && nameSpace != ''){
			String apiNameWithNamespace;
			for(String fld : allowedFields){
				apiNameWithNamespace = nameSpace + fld;
				if(allowedFields.contains(apiNameWithNamespace)){
					allowedFields.remove(fld); 
				}
			}
		}

		query += String.join(new List<String>(allowedFields), ',');
		query += ' FROM '+ objName +' WHERE '+nameSpace+'Cadence_Id__c = null';

		return query;
	} 

}