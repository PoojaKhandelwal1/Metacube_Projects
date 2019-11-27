/**
 * Author: Rajat Jain
 * Since: October 8, 2018
 * Name: AccountTypeSOQLUtil
 * Description: SOQL Util class for Account Type
**/
public without sharing class AccountTypeSOQLUtil { 
    
    public static List<Account_Type__c> getAccountType(Map<String, String> fieldNameToFieldValueMap) { 
        String query = 'SELECT ';
        for(String fieldName : AccountTypeWrapper.getAccountTypeFields()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';  
        }
        // Child Query
        query += '(Select Id, Sales_Tax_Item__r.Name__c from Tax_Exemptions__r), (Select Id from Accounts__r), (Select Id from Accounts1__r)';  
        query += ' FROM Account_Type__c';
        query += getWhereClause(fieldNameToFieldValueMap);
        query += ' ORDER BY Applies_To__c ASC';
        query += ' LIMIT ' + SOQLUtil.getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query); 
    }
     
    public static List<Account_Type__c> getTaxExemptionRecForAccType(Map<String, String> fieldNameToFieldValueMap) {
        String query = 'SELECT ';
        for(String fieldName : AccountTypeWrapper.getAccountTypeFields()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';  
        }
        // Child Query
        query += '(Select Id, Customer__c, Sales_Tax_Item__r.Name__c, Sales_Tax_Item__r.Rate__c, Sales_Tax_Item__r.Forms_Label__c from Tax_Exemptions__r), (Select Id from Accounts__r), (Select Id from Accounts1__r)';
        query += ' FROM Account_Type__c';
        query += getWhereClause(fieldNameToFieldValueMap);
        if(AccessControl.ifObjectFieldIsAccessible('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
    
    public static List<Sales_Tax_Item__c> getAllSalesTaxItemWithExemptions() {
        if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        String query;
        query = 'SELECT Name__c, Rate__c, Forms_Label__c, ';
        
        // child Query - Tax Exemptions
        query += '(SELECT Id, Customer__c from Tax_Exemptions__r)'; 
        query += ' FROM ' + Constants.NAMESPACE + 'Sales_Tax_Item__c ';
        
        List<Sales_Tax_Item__c> salesTaxItemList = Database.query(query);
        return salesTaxItemList;  
    }
    private static String getWhereClause(Map<String, String> fieldNameToFieldValueMap) {
        String whereClause = '';
        Boolean isWhereClauseAdded = false;
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            if(isWhereClauseAdded) {
            	if(BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) == 'true') {
            		whereClause += ' AND ' + fieldName + ' = ' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName));
            	} else {
            		whereClause += ' AND ' + fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
            	}
            } else {
            	if(BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) == 'true') {
            		whereClause += ' AND ' + fieldName + ' = ' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName));
            	} else {
	                whereClause += ' WHERE ' + fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
	                isWhereClauseAdded = true;
            	}
            }
        }
        return whereClause;
    }
    
}