public with sharing class BooleanCriterionEvaluator implements ICriterionEvaluator{
	public BooleanCriterionEvaluator() {

	}

	public Boolean equals(Object a, Object b) {
		if (a == null || b == null) { return false; }
		return String.valueOf(b).equalsIgnoreCase('true') == Boolean.valueOf(String.valueOf(a));
	}

	public Boolean notEquals(Object a, Object b) {
		if (a == null || b == null) { return false; }
		return String.valueOf(b).equalsIgnoreCase('true') != Boolean.valueOf(String.valueOf(a));
	}

	public Boolean greater(Object a, Object b) {
		return false;
	}

	public Boolean lessThan(Object a, Object b) {
		return false;
	}

	public Boolean lessOrEquals(Object a, Object b) {
		return false;
	}

	public Boolean greaterOrEquals(Object a, Object b) {
		return false;
	}

	public Boolean contains(Object a, Object b) {
		return false;
	}

	public Boolean startWith(Object a, Object b) {
		return false;
	}

	public Boolean notContains(Object a, Object b) {
		return false;
	}
}