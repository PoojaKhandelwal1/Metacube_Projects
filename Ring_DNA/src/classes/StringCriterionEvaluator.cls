public with sharing class StringCriterionEvaluator implements ICriterionEvaluator{

	public StringCriterionEvaluator() {

	}
	public Boolean equals(Object a, Object b) {
		return String.valueOf(a).equalsIgnoreCase(String.valueOf(b));
	}

	public Boolean notEquals(Object a, Object b) {
		return !String.valueOf(a).equalsIgnoreCase(String.valueOf(b));
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
		return String.valueOf(a).containsIgnoreCase(String.valueOf(b));
	}

	public Boolean startWith(Object a, Object b) {
		return String.valueOf(a).startsWithIgnoreCase(String.valueOf(b));
	}

	public Boolean notContains(Object a, Object b) {
		return !String.valueOf(a).containsIgnoreCase(String.valueOf(b));
	}
}