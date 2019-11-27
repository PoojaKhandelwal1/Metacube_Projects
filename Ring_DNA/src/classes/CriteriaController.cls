public with sharing class CriteriaController {
	@AuraEnabled
	public static List<CriterionWrapper> getFields(String objectStr){
		List<CriterionWrapper> criterions = CadenceService.getFieldsWithLabels(new List<String>{objectStr});
		return criterions;
	}
}