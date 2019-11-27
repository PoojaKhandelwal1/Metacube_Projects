public class PerformCadenceActionBatchHelper {
   public static String formQuery(String participantType){
		if(participantType == CadenceConstants.CONTACT_OBJECT_NAME) {
			return formContactSelectQuery(getParticipantTypeToParentObjectListMap().get(CadenceConstants.CONTACT_OBJECT_NAME));
		} else if(participantType == CadenceConstants.LEAD_OBJECT_NAME) {
			return formLeadSelectQuery(getParticipantTypeToParentObjectListMap().get(CadenceConstants.LEAD_OBJECT_NAME));
		} else if(participantType == CadenceConstants.OPPORTUNITY_OBJECT_NAME) {
			return formOpportunityContactSelectQuery(getParticipantTypeToParentObjectListMap().get(CadenceConstants.OPPORTUNITY_OBJECT_NAME));
		}
		return '';
	} 
	
	private static String formContactSelectQuery(list<String> participantTypeToParentObjectList) {
		String query = 'Select ';
		Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
		List<Schema.SObjectField> contactFieldList = getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Contact');
		
		query = addFieldsInQuery(query, globalDescribedSchemaMap, contactFieldList, participantTypeToParentObjectList);
		
		query = query.subString(0, query.length() - 1);
		query += ' From Contact WHERE Cadence_ID__c != null AND Opportunity_Id__c = null';
		return query;
	}
	
	private static String formLeadSelectQuery(list<String> participantTypeToParentObjectList) {
		String query = 'Select ';
		Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
		List<Schema.SObjectField> leadFieldList = getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Lead');
		
		query = addFieldsInQuery(query, globalDescribedSchemaMap, leadFieldList, participantTypeToParentObjectList);
		
		query = query.subString(0, query.length() - 1);
		query += ' From Lead WHERE Cadence_ID__c != null';
		return query;
	}
	
	private static String formOpportunityContactSelectQuery(list<String> participantTypeToParentObjectList) {
		String query = 'Select ';
		Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
		List<Schema.SObjectField> opportunityFieldList = getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Opportunity');
		
		query = addFieldsInQuery(query, globalDescribedSchemaMap, opportunityFieldList, participantTypeToParentObjectList);
		
		query += ' (Select ContactId, OpportunityId, Role From OpportunityContactRoles)';
		query += ' From Opportunity WHERE Cadence_ID__c != null AND Id IN (Select OpportunityId From OpportunityContactRole)';
		return query;
	}
	
	public static List<Schema.SObjectField> getFieldListFromGlobalDescribedSchemaMap(Map <String, Schema.SObjectType> globalDescribedSchemaMap, String objectName) {
		List<Schema.SObjectField> fieldList = globalDescribedSchemaMap.get(objectName).getDescribe().fields.getMap().values();
		return fieldList;
	}
	
	public static String addFieldsInQuery(String query, Map <String, Schema.SObjectType> globalDescribedSchemaMap, 
											List<Schema.SObjectField> fieldList, list<String> participantTypeToParentObjectList) {
		for(Schema.SObjectField field : fieldList) {
			if (!field.getDescribe().isAccessible()) {
				continue; 
			}
			query += field.getDescribe().getname() + ',';
		}
		
		List<Schema.SObjectField> parentObjectFieldList;
		for(String parentObjectName : participantTypeToParentObjectList) {
			parentObjectFieldList = getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, parentObjectName);
		
			for(Schema.SObjectField parentObjectField : parentObjectFieldList) {
				if (!parentObjectField.getDescribe().isAccessible()) {
					continue; 
				}
				query += parentObjectName + '.' + parentObjectField.getDescribe().getname() + ',';
			}
		}
		return query;
	}
	
	public static Map<String, list<String>> getParticipantTypeToParentObjectListMap() {
		Map<String, list<String>> participantTypeToParentGroupsListMap = new Map<String, list<String>>{
																										CadenceConstants.CONTACT_OBJECT_NAME => new list<String>(),
																										CadenceConstants.LEAD_OBJECT_NAME => new list<String>(),
																										 CadenceConstants.OPPORTUNITY_OBJECT_NAME => new list<String>()
																									  };
		
		participantTypeToParentGroupsListMap.get(CadenceConstants.CONTACT_OBJECT_NAME).add(CadenceConstants.ACCOUNT_OBJECT_NAME);
		participantTypeToParentGroupsListMap.get(CadenceConstants.OPPORTUNITY_OBJECT_NAME).add(CadenceConstants.ACCOUNT_OBJECT_NAME);
		
		Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
		if(globalDescribedSchemaMap.get(CadenceConstants.DB_OBJECT_NAME) != null) {
			participantTypeToParentGroupsListMap.get(CadenceConstants.LEAD_OBJECT_NAME).add(CadenceConstants.DB_OBJECT_NAME);
		} 
		
		if(globalDescribedSchemaMap.get(CadenceConstants.CONTRACT_OBJECT_NAME) != null) {
			participantTypeToParentGroupsListMap.get(CadenceConstants.OPPORTUNITY_OBJECT_NAME).add(CadenceConstants.CONTRACT_OBJECT_NAME);
		}
		
		if(globalDescribedSchemaMap.get(CadenceConstants.PRICE_BOOK_OBJECT_NAME) != null) {
			participantTypeToParentGroupsListMap.get(CadenceConstants.OPPORTUNITY_OBJECT_NAME).add(CadenceConstants.PRICE_BOOK_OBJECT_NAME);
		}	
		return participantTypeToParentGroupsListMap;
	}
	
	public static List<Contact> getContactsRelatedToOpportunities(List<Opportunity> opportunityList) {
		List<String> participantTypeToParentObjectList = getParticipantTypeToParentObjectListMap().get(CadenceConstants.CONTACT_OBJECT_NAME);
		
		Set<Id> contactIdSet = new Set<Id>();
		for(Opportunity opportunity : opportunityList) {
			if(opportunity.OpportunityContactRoles != null) {
				for(OpportunityContactRole opportunityContactRole : opportunity.OpportunityContactRoles) {
					contactIdSet.add(opportunityContactRole.ContactId);
				}
			}
		}
		String query = 'Select ';
		Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
		List<Schema.SObjectField> contactFieldList = getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Contact');
		
		query = addFieldsInQuery(query, globalDescribedSchemaMap, contactFieldList, participantTypeToParentObjectList);
		
		query = query.subString(0, query.length() - 1);
		query += ' From Contact WHERE Cadence_ID__c != null AND ID IN: contactIdSet Limit ' + SequenceEngineHelper.getAvailableQueryRowsLimit();
		return DataBase.query(query);
	}
}