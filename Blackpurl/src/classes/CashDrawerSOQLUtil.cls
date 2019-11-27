public with sharing class CashDrawerSOQLUtil {
	
    /** 
     * Name: getAvailableQueryRowsLimit
     * Desc: Getter method which returns available  limit of query rows which can be returned by a SOQL in the context
     * @param:
     * @return: Integer - Available query rows limit  
    **/ 
    public static Integer getAvailableQueryRowsLimit() {
        return Limits.getLimitQueryRows() - Limits.getQueryRows();   
    }  
    
    public static List<Cash_Drawer__c> getAllCashDrawerList(Boolean isIncludeInactive) {
    	String query = 'SELECT ';
        for(String fieldName : CashDrawerWrapper.getCashDrawerFieldsList()) {
        	fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Cash_Drawer__c ';
        if(!isIncludeInactive) {
        	query += ' WHERE Active__c = true ';
        }
        query += ' ORDER BY Name ASC';
        if(AccessControl.ifObjectFieldIsAccessible('Cash_Drawer__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
    
     public static List<Cash_Drawer__c> getCashDrawerDetailsByFieldValues(DateTime dtValue, String cashDrawerId) {
        String query = 'SELECT '; 
        for(String fieldName : CashDrawerWrapper.getCashDrawerFieldsList()) {
            query += fieldName + ', ';
        }
        // Invoice Payments child query
        query += '(SELECT ';
        for(String fieldsName : ReconciliationWrapper.getCOInvoicePaymentfieldsList()) {
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + 'CO_Invoice_Payments__r';
        query += ' WHERE Payment_Date__c >= ' + dtValue.format('yyyy-MM-dd');
        query += ' AND Payment_Date__c < ' + dtValue.addDays(1).format('yyyy-MM-dd') + ' ), ';
        
        // Deposits child query
        query += '(SELECT ';
        for(String fieldsName : ReconciliationWrapper.getCODepositFieldsList()) {
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + 'CO_Deposits__r';
        query += ' WHERE Payment_Date__c >= ' + dtValue.format('yyyy-MM-dd');
        query += ' AND Payment_Date__c < ' + dtValue.addDays(1).format('yyyy-MM-dd') + ' ), ';
        
        // Child Query
        query += '(SELECT ';
        for(String fieldsName : CashDrawerReconcilationWrapper.getCashDrawerReconciliationFieldsList()) {
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + 'Cash_Drawer_Reconciliations__r';
        query += ' WHERE Cash_Reconciliation__r.Reconciliation_Date__c = ' + dtValue.format('yyyy-MM-dd') + ')';
        
        query += ' FROM ' + 'Cash_Drawer__c';
        if(String.isNotBlank(cashDrawerId)) {
        	query += ' WHERE Id =: cashDrawerId';
        }
        query += ' ORDER BY Name ASC LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('Cash_Drawer__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Cash_Drawer__c> cashDrawers = Database.query(query);
        return cashDrawers;
    }
    
    public static List<Cash_Drawer_Reconciliation__c> getCashDrawerReconciliationByFieldValues(Map<String, String> fieldNameToValueMap) {
        String query = 'SELECT Id, '; 
        for(String fieldName : CashDrawerReconcilationWrapper.getCashDrawerReconciliationFieldsList()) {
            query += fieldName + ', ';
        }
        // Invoice Payments child query
        query += '(SELECT ';
        for(String fieldsName : ReconciliationWrapper.getReconciliationPaymentFieldList()){
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + 'Cash_Reconciliation_Payments__r)';
        
        query += ' FROM ' + 'Cash_Drawer_Reconciliation__c ';
        if(fieldNameToValueMap != null && fieldNameToValueMap.size() > 0) {
        	boolean isWhereClauseAdded = query.contains('WHERE');
            for(String fieldName : fieldNameToValueMap.keySet()) {
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                if(!isWhereClauseAdded) {
	                query += 'WHERE ';
	                isWhereClauseAdded = true;
	            } else {
	                query += 'AND ';
	            }
                
                if(fieldName == 'Cash_Reconciliation__r.Reconciliation_Date__c') {
	                query += fieldName + ' = ' + fieldNameToValueMap.get(fieldName) + ' ';
	            } else {
	                query += fieldName + ' = \'' + fieldNameToValueMap.get(fieldName) + '\' ';
	            }
            }
        }
        query += ' ORDER BY Name ASC LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('Cash_Drawer_Reconciliation__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Cash_Drawer_Reconciliation__c> cashDrawerReconciliationList = Database.query(query);
        return cashDrawerReconciliationList;
    }
    
    public static List<Cash_Reconciliation_Payment__c> getReconciliationPaymentsList(Map<String, String> fieldNameToFieldValueMap) {
        String query = 'SELECT Id, '; 
        for(String fieldName : ReconciliationWrapper.getReconciliationPaymentFieldList()){ 
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Cash_Reconciliation_Payment__c '; 
        Boolean isWhereClauseAdded = false;
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            if(!isWhereClauseAdded) {
                query += 'WHERE ';
                isWhereClauseAdded = true;
            } else {
                query += 'AND ';
            }
            if(fieldName == 'Cash_Reconciliation__r.Reconciliation_Date__c') {
                query += fieldName + ' = ' + fieldNameToFieldValueMap.get(fieldName) + ' ';
            } else {
                query += fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
            }
        }
        query += ' ORDER BY CreatedDate DESC';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('Cash_Reconciliation_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); } 
        List<Cash_Reconciliation_Payment__c> reconciliationPaymentList = Database.query(query);
        return reconciliationPaymentList;
    }
}