public with sharing class DateCriterionEvaluator implements ICriterionEvaluator {

	public DateCriterionEvaluator() {

	}

	public Boolean equals(Object a, Object b) {
		if(a == null || b == null) { return false; }
		return (Date.valueOf(a) == Date.valueOf((String)b));
	} 

	public Boolean notEquals(Object a, Object b) {
		if(a == null || b == null) { return false; }
		return (Date.valueOf(a) != Date.valueOf((String)b));
	}

	public Boolean greater(Object a, Object b) {
		if(a == null || b == null) { return false; }
		return (Date.valueOf(a) > Date.valueOf((String)b));
	}

	public Boolean lessThan(Object a, Object b) {
		if(a == null || b == null) { return false; }
		return (Date.valueOf(a) < Date.valueOf((String)b));
	}

	public Boolean lessOrEquals(Object a, Object b) {
		if(a == null || b == null) { return false; }
		return (Date.valueOf(a) <= Date.valueOf((String)b));
	}

	public Boolean greaterOrEquals(Object a, Object b) {
		if(a == null || b == null) { return false; }
		return (Date.valueOf(a) >= Date.valueOf((String)b));
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