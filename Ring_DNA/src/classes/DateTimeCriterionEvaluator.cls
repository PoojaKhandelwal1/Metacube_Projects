public with sharing class DateTimeCriterionEvaluator implements ICriterionEvaluator{

	public DateTimeCriterionEvaluator() {

	}

	public Boolean equals(Object a, Object b) {
		if(a == null || b == null) { return false; }
		return (DateTime.valueOf(a) == getDateTime(b));
	} 

	public Boolean notEquals(Object a, Object b) {
		if(a == null || b == null) { return false; }
		return (DateTime.valueOf(a) != getDateTime(b));
	}

	public Boolean greater(Object a, Object b) {
		if(a == null || b == null) { return false; }
		return (DateTime.valueOf(a) > getDateTime(b));
	}

	public Boolean lessThan(Object a, Object b) {
		if(a == null || b == null) { return false; }
		return (DateTime.valueOf(a) < getDateTime(b));
	}

	public Boolean lessOrEquals(Object a, Object b) {
		if(a == null || b == null) { return false; }
		return (DateTime.valueOf(a) <= getDateTime(b));
	}

	public Boolean greaterOrEquals(Object a, Object b) {
		if(a == null || b == null) { return false; }
		return (DateTime.valueOf(a) >= getDateTime(b));
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


	public DateTime getDateTime(Object dt) {
		String str = '"' + String.valueOf(dt) + '"';
		return DateTime.valueOf(json.deserialize(str, datetime.class));
	}
}