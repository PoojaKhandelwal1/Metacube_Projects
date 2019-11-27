public with sharing class SOQLUtility {
    
    public static Integer getAvailableQueryRowsLimit() {
		return Limits.getLimitQueryRows() - Limits.getQueryRows();   
	}
	
	public static List<Sobject> getSODetailsByFieldName(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : SOHeaderWrapper.getSOHeaderFieldsList()){
        	fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        
        query = query.substring(0, query.length()-2);
        query += ' FROM Service_Order_Header__c ';
        
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            	fieldName = BPUtility.escapeSingleQuotes(fieldName);
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
                    isWhereClauseAdded = true;
                } else {
                    query += 'AND '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
                }
            }
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Service_Order_Header__c> soHeaderList = Database.query(query);
        return soHeaderList;
    }
    
    public static List<Sobject> getCOHeaderDetails(Id coHeaderId, Integer fieldsToQueryLevel) {
        String query;   
        query = 'SELECT '; 
        CustomerOrderWrapper.COHeader coWrapperObj = new CustomerOrderWrapper.COHeader(fieldsToQueryLevel);
        for(String fieldsName : coWrapperObj.fieldsList()){
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        
        query += '(SELECT Id from CO_Invoice_Headers__r WHERE Invoice_Status__c = \'Active\')';
        
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Header__c ';
        if(coHeaderId != null) {
            query += 'WHERE ID = :coHeaderId';
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> coHeaderRec = Database.query(query);
        return coHeaderRec;
    }
}