public with sharing class CriterionEvaluatorFactory {

	private static Map<String, ICriterionEvaluator> evaluatorInstanceMap = new Map<String, ICriterionEvaluator>();
	static {
		ICriterionEvaluator eval;

		evaluatorInstanceMap.put('DATETIME', new DateTimeCriterionEvaluator());
		evaluatorInstanceMap.put('DATE', new DateCriterionEvaluator());
		evaluatorInstanceMap.put('MULTIPICKLIST', new MultipicklistCriterionEvaluator());
		evaluatorInstanceMap.put('PICKLIST', new PicklistCriterionEvaluator());

		evaluatorInstanceMap.put('BOOLEAN', new BooleanCriterionEvaluator());

		evaluatorInstanceMap.put('ID',  new PicklistCriterionEvaluator());
		evaluatorInstanceMap.put('PHONE', new PhoneCriterionEvaluator());
		eval = new NumericCriterionEvaluator();
		evaluatorInstanceMap.put('DOUBLE', eval);
		evaluatorInstanceMap.put('CURRENCY', eval);
		evaluatorInstanceMap.put('INTEGER', eval);
		evaluatorInstanceMap.put('PERCENT', eval);
		evaluatorInstanceMap.put('NUMBER', eval);

		eval = new StringCriterionEvaluator();
		evaluatorInstanceMap.put('STRING', eval);
		evaluatorInstanceMap.put('REFERENCE', eval);
		evaluatorInstanceMap.put('TEXTAREA', eval);
		evaluatorInstanceMap.put('EMAIL', eval);
		evaluatorInstanceMap.put('URL', eval);
		evaluatorInstanceMap.put('ADDRESS', eval);
		evaluatorInstanceMap.put('COMBOBOX', eval);
	}
	public static ICriterionEvaluator createNew(String fieldType) {
		ICriterionEvaluator evaluator = evaluatorInstanceMap.get(fieldType);
		return evaluator;
	}
}