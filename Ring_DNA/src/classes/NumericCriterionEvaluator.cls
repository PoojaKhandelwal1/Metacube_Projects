public with sharing class NumericCriterionEvaluator implements ICriterionEvaluator{
	public NumericCriterionEvaluator() {

	}
	public Boolean equals(Object a, Object b) {
		if (a == null || b == null) { return false; }
		return Decimal.valueOf(String.valueOf(a)) == Decimal.valueOf(String.valueOf(b));
	}

	public Boolean notEquals(Object a, Object b) {
		if (a == null || b == null) { return false; }
		return Decimal.valueOf(String.valueOf(a)) != Decimal.valueOf(String.valueOf(b));
	}

	public Boolean greater(Object a, Object b) {
		if (a == null) { return false; }
		if (b == null) { b = 0; }
		return Decimal.valueOf(String.valueOf(a)) > Decimal.valueOf(String.valueOf(b));
	}

	public Boolean lessThan(Object a, Object b) {
		if (a == null) { return false; }
		if (b == null) { b = 0; }
		return Decimal.valueOf(String.valueOf(a)) < Decimal.valueOf(String.valueOf(b));
	}

	public Boolean lessOrEquals(Object a, Object b) {
		if (a == null) { return false; }
		if (b == null) { b = 0; }
		return Decimal.valueOf(String.valueOf(a)) <= Decimal.valueOf(String.valueOf(b));
	}

	public Boolean greaterOrEquals(Object a, Object b) {
		if (a == null) { return false; }
		if (b == null) { b = 0; }
		return Decimal.valueOf(String.valueOf(a)) >= Decimal.valueOf(String.valueOf(b));
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