public with sharing class CriterionSet {
	@AuraEnabled public Map<Integer, Criterion> criterions;
	@AuraEnabled public String condition;
	@AuraEnabled public String executionCriterion;
	@AuraEnabled public String criterionPriorityFormula;
	public String postFixExpression;

	public static CriterionSet parse(String json) {
		return (CriterionSet) System.JSON.deserialize(json, CriterionSet.class); 
	}
}