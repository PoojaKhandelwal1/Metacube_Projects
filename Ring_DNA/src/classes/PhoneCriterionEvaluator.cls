public with sharing class PhoneCriterionEvaluator implements ICriterionEvaluator {

	public PhoneCriterionEvaluator() {

	}

	public Boolean equals(Object a, Object b) {
		if(a == null || b == null) { return false; }
		return (String.valueOf(a).equalsIgnoreCase(String.valueOf(b)) || getNumberInSimpleFormat(String.valueOf(a)).equalsIgnoreCase(getNumberInSimpleFormat(String.valueOf(b))));
	}

	public Boolean notEquals(Object a, Object b) {
		if(a == null || b == null) { return false; }
		return !(String.valueOf(a).equalsIgnoreCase(String.valueOf(b)) || getNumberInSimpleFormat(String.valueOf(a)).equalsIgnoreCase(getNumberInSimpleFormat(String.valueOf(b))));
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

	private String getNumberInSimpleFormat(String phoneNo) {
		phoneNo = phoneNo.replace('(', '');
		phoneNo = phoneNo.replace(')', '');
		phoneNo = phoneNo.replace(' ', '');
		phoneNo = phoneNo.replace('-', '');
		return phoneNo;
	}

}