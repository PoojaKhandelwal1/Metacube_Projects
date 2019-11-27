public interface ICriterionEvaluator {
	Boolean equals(Object a, Object b);
	Boolean notEquals(Object a, Object b);
	Boolean greater(Object a, Object b);
	Boolean lessThan(Object a, Object b);
	Boolean lessOrEquals(Object a, Object b);
	Boolean greaterOrEquals(Object a, Object b);
	Boolean contains(Object a, Object b);
	Boolean startWith(Object a, Object b);
	Boolean notContains(Object a, Object b);
}