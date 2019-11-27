public with sharing class Criterion {
	@AuraEnabled public Integer id;
	@AuraEnabled public String fieldName;
	@AuraEnabled public String fieldLabel;
	@AuraEnabled public String fieldDataType;
	@AuraEnabled public String operation;
	@AuraEnabled public String value;
	@AuraEnabled public List<String> listPicklistValues;
	@AuraEnabled public List<PicklistData> picklistApiNameAndValues;


	public class PicklistData{
		@AuraEnabled public string picklistAPIName;
		@AuraEnabled public string picklistLable;
	} 

	public Boolean matches(FormulaSObjectValue valueObj) { 
		ICriterionEvaluator criterionEvaluator = CriterionEvaluatorFactory.createNew(this.fieldDataType.toUpperCase());
		return this.invokeCriterionEvaluator(criterionEvaluator, valueObj);
	}

	private Boolean invokeCriterionEvaluator(ICriterionEvaluator criterionEvaluator, FormulaSObjectValue valueObj) {
		Boolean ret = false;
		Object fieldValue = valueObj.get(this.fieldName);
		if (fieldValue == null || this.value == null) {
			return false;
		}
		if ('equals'.equalsIgnoreCase(this.operation)) {
			ret = criterionEvaluator.equals(fieldValue, this.value); 
		} else if ('not_equals'.equalsIgnoreCase(this.operation)) {
			ret = criterionEvaluator.notEquals(fieldValue, this.value);
		} else if ('greater'.equalsIgnoreCase(this.operation)) {
			ret = criterionEvaluator.greater(fieldValue, this.value);
		} else if ('less_than'.equalsIgnoreCase(this.operation)) {
			ret = criterionEvaluator.lessThan(fieldValue, this.value);
		} else if ('less_or_equals'.equalsIgnoreCase(this.operation)) {
			ret = criterionEvaluator.lessOrEquals(fieldValue, this.value);
		} else if ('greater_or_equals'.equalsIgnoreCase(this.operation)) {
			ret = criterionEvaluator.greaterOrEquals(fieldValue, this.value);
		} else if ('contains'.equalsIgnoreCase(this.operation)) {
			ret = criterionEvaluator.contains(fieldValue, this.value);
		} else if ('start_with'.equalsIgnoreCase(this.operation)) {
			ret = criterionEvaluator.startWith(fieldValue, this.value);
		} else if ('not_contains'.equalsIgnoreCase(this.operation)) {
			ret = criterionEvaluator.notContains(fieldValue, this.value);
		}
		return ret;
	}

	public static List<PicklistData> getPicklistApiNameAndValues(String objectStr, String field) {
		List<PicklistData> picklistValues = new List<PicklistData>();
		Schema.sObjectType sObjectName = Schema.getGlobalDescribe().get(objectStr);
		Map<String, Schema.SObjectField> fieldsMap = sObjectName.getDescribe().fields.getMap();
		Schema.sObjectField fieldAPIName = fieldsMap.get(field);
		Schema.DescribeFieldResult fieldResult = fieldAPIName.getDescribe();
		List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry picklistVal : values) {
			PicklistData pld = New PicklistData();
			pld.picklistAPIName = picklistVal.getValue();
			pld.picklistLable = picklistVal.getLabel();
			picklistValues.add(pld); 
		}     
		return picklistValues;
	}

}