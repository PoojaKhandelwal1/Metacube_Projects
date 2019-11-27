public with sharing class FormulaSObjectValue {

	public class FormulaSObjectValueException extends Exception {

	}

	private SObject current;
	private SObject parent;

	public FormulaSObjectValue(SObject obj) {
		this(obj, null);
	}

	public FormulaSObjectValue(SObject obj, SObject parentObj) {
		if (obj == null) {
			throw new FormulaSObjectValueException();
		}
		current = obj;
		parent = parentObj;
	}

	public Object get(String fieldName) {
		try {
			Object value;
			if(fieldName.contains('.')) {
				if(parent != null) {
					value = parent.get(fieldName.split('\\.').get(1));    
				} else {
					SObject so = current.getSobject(fieldName.split('\\.').get(0));
					if(so != null) {
						value = so.get(fieldName.split('\\.').get(1));
					}
				}
			} else {
				value = current.get(fieldName);
			}
			return value;
		} catch (System.SObjectException exc) {
			return null;
		}
	}

	public Object getId() {
		try {
			return current.get('Id');
		} catch (System.SObjectException exc) {
			return null;
		}
	}
	
	public SObject getCurrent()
	{
	   return current;
	}

}