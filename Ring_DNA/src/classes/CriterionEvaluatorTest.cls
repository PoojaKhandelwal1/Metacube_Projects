@isTest
public with sharing class CriterionEvaluatorTest {

	@isTest
	static void stringCriterionEvaluatorTest() {

		StringCriterionEvaluator strEvaluator = new StringCriterionEvaluator();
		System.assertEquals(true, strEvaluator.equals('Test', 'Test'));
		System.assertEquals(true, strEvaluator.notEquals('Test', 'Test1'));
		System.assertEquals(false, strEvaluator.greater('Test', 'Test'));
		System.assertEquals(false, strEvaluator.lessThan('', ''));
		System.assertEquals(false, strEvaluator.lessOrEquals('', ''));
		System.assertEquals(false, strEvaluator.greaterOrEquals('', ''));
		System.assertEquals(true, strEvaluator.contains('Testing', 'Test'));
		System.assertEquals(true, strEvaluator.startWith('Testing', 'Test'));
		System.assertEquals(true, strEvaluator.notContains('Test', 'Work'));

	}

	@isTest
	static void booleanCriterionEvaluatorTest() {

		BooleanCriterionEvaluator boolEvaluator = new BooleanCriterionEvaluator();
		System.assertEquals(true, boolEvaluator.equals(true, true));
		System.assertEquals(true, boolEvaluator.notEquals(true, false));
		System.assertEquals(false, boolEvaluator.greater('Test', 'Test'));
		System.assertEquals(false, boolEvaluator.lessThan('', ''));
		System.assertEquals(false, boolEvaluator.lessOrEquals('', ''));
		System.assertEquals(false, boolEvaluator.greaterOrEquals('', ''));
		System.assertEquals(false, boolEvaluator.contains('Testing', 'Test'));
		System.assertEquals(false, boolEvaluator.startWith('Testing', 'Test'));
		System.assertEquals(false, boolEvaluator.notContains('Test', 'Work'));

	}

	@isTest
	static void numericCriterionEvaluatorTest() {

		NumericCriterionEvaluator numEvaluator = new NumericCriterionEvaluator();
		System.assertEquals(true, numEvaluator.equals(4, 4));
		System.assertEquals(true, numEvaluator.notEquals(4, 3));
		System.assertEquals(false, numEvaluator.greater(null, 3 ));
		System.assertEquals(true, numEvaluator.greater(4, null ));
		System.assertEquals(true, numEvaluator.greater(4, 3 ));
		System.assertEquals(false, numEvaluator.lessThan(null, 4));
		System.assertEquals(true, numEvaluator.lessThan(3, 4));
		System.assertEquals(false, numEvaluator.lessThan(3, null));
		System.assertEquals(false, numEvaluator.lessOrEquals(null, 4));
		System.assertEquals(true, numEvaluator.lessOrEquals(4, 4));
		System.assertEquals(false, numEvaluator.lessOrEquals(4, null));
		System.assertEquals(true, numEvaluator.lessOrEquals(0, null));
		System.assertEquals(false, numEvaluator.greaterOrEquals(null, 4));
		System.assertEquals(true, numEvaluator.greaterOrEquals(4, 4));
		System.assertEquals(true, numEvaluator.greaterOrEquals(0, null));
		System.assertEquals(true, numEvaluator.greaterOrEquals(4, null));
		System.assertEquals(false, numEvaluator.contains(1, 1));
		System.assertEquals(false, numEvaluator.startWith(1, 1));
		System.assertEquals(false, numEvaluator.notContains(1, 1));

	}

	@isTest
	static void picklistCriterionEvaluatorTest() {

		PicklistCriterionEvaluator pickEvaluator = new PicklistCriterionEvaluator();
		System.assertEquals(false, pickEvaluator.greater(4, 3));
		System.assertEquals(false, pickEvaluator.lessThan(3, 4));
		System.assertEquals(false, pickEvaluator.lessOrEquals(4, 4));
		System.assertEquals(false, pickEvaluator.greaterOrEquals(4, 4));
		System.assertEquals(false, pickEvaluator.contains(1, 1));
		System.assertEquals(false, pickEvaluator.startWith(1, 1));
		System.assertEquals(false, pickEvaluator.notContains(1, 1));

	}    

	@isTest
	static void dateCriterionEvaluatorTest() {

		DateCriterionEvaluator dateEvaluator = new DateCriterionEvaluator();
		System.assertEquals(true, dateEvaluator.equals(Date.valueOf('2019-01-29'), '2019-01-29'));
		System.assertEquals(true, dateEvaluator.notEquals(Date.valueOf('2019-01-29'), '2019-01-28'));
		System.assertEquals(true, dateEvaluator.greater(Date.valueOf('2019-01-30'), '2019-01-29'));
		System.assertEquals(true, dateEvaluator.lessThan(Date.valueOf('2019-01-28'), '2019-01-29'));
		System.assertEquals(true, dateEvaluator.lessOrEquals(Date.valueOf('2019-01-29'), '2019-01-29'));
		System.assertEquals(true, dateEvaluator.greaterOrEquals(Date.valueOf('2019-01-29'), '2019-01-29'));
		System.assertEquals(false, dateEvaluator.contains('Testing', 'Test'));
		System.assertEquals(false, dateEvaluator.startWith('Testing', 'Test'));
		System.assertEquals(false, dateEvaluator.notContains('Test', 'Work'));

	}

	@isTest
	static void dateTimeCriterionEvaluatorTest() {
		DateTimeCriterionEvaluator dateEvaluator = new DateTimeCriterionEvaluator();
		System.assertEquals(false, dateEvaluator.equals(DateTime.valueOf('2019-01-29 11:09:31'), '2019-01-29T11:12:00.000Z'));
		System.assertEquals(true, dateEvaluator.notEquals(DateTime.valueOf('2019-01-29 11:09:31'), '2019-01-29T11:12:00.000Z'));
		System.assertEquals(true, dateEvaluator.greater(DateTime.valueOf('2019-01-30 11:09:31'), '2019-01-29T11:12:00.000Z'));
		System.assertEquals(true, dateEvaluator.lessThan(DateTime.valueOf('2019-01-28 11:09:31'), '2019-01-29T11:12:00.000Z'));
		System.assertEquals(true, dateEvaluator.lessOrEquals(DateTime.valueOf('2019-01-28 11:09:31'), '2019-01-29T11:12:00.000Z'));
		System.assertEquals(true, dateEvaluator.greaterOrEquals(DateTime.valueOf('2019-01-31 11:09:31'), '2019-01-29T11:12:00.000Z'));
		System.assertEquals(false, dateEvaluator.contains('Testing', 'Test'));
		System.assertEquals(false, dateEvaluator.startWith('Testing', 'Test'));
		System.assertEquals(false, dateEvaluator.notContains('Test', 'Work'));
	}

	@isTest
	static void phoneCriterionEvaluatorTest() {
		PhoneCriterionEvaluator phoneEvaluator = new PhoneCriterionEvaluator();
		System.assertEquals(true, phoneEvaluator.equals('4087570350', '4087570350'));
		System.assertEquals(true, phoneEvaluator.notEquals('4084444444', '8888444888'));
		System.assertEquals(false, phoneEvaluator.greater('', ''));
		System.assertEquals(false, phoneEvaluator.lessThan('', ''));
		System.assertEquals(false, phoneEvaluator.lessOrEquals('', ''));
		System.assertEquals(false, phoneEvaluator.greaterOrEquals('', ''));
		System.assertEquals(false, phoneEvaluator.contains('', ''));
		System.assertEquals(false, phoneEvaluator.startWith('', ''));
		System.assertEquals(false, phoneEvaluator.notContains('', ''));
	}

}