/**
 * Author: Tarun Khandelwal
 * Since: August 17, 2018
 * Name: FusionSOQLUtil
 * Description: SOQL Util class for Fusion Mapping ctrl class
**/
public without sharing class FusionSOQLUtil {
    
    public static List<Fusion_Report_Line_Item__c> getFusionLienItem(Map<String, String> fieldNameToFieldValueMap) {
        String query = 'SELECT ';
        for(String fieldName : FusionLineItemWrapper.getFusionLineItemsFields()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';  
        }
        
        // Junction object Child Query
        query += '(SELECT General_Account__c, General_Account__r.Account_Name__c, General_Account__r.Account_Number__c, ' +
                    'General_Account__r.Accounting_Id__c FROM Fusion_Line_Item_To_GL_Account_Junctions__r ORDER BY CreatedDate ASC, Name ASC)';  
        query += ' FROM Fusion_Report_Line_Item__c';
        query += getWhereClause(fieldNameToFieldValueMap);
        query += ' ORDER BY Order_Number__c ASC';
        if(AccessControl.ifObjectFieldIsAccessible('Fusion_Report_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
    
    public static List<General_Account__c> getGeneralAccounts(Map<String, String> fieldNameToFieldValueMap) {
        String query = 'SELECT ';
        for(String fieldName : GeneralAccountWrapper.getGeneralAccountFields()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM General_Account__c';
        query += getWhereClause(fieldNameToFieldValueMap);
        query += ' ORDER BY Account_Name__c ASC';
        if(AccessControl.ifObjectFieldIsAccessible('General_Account__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
    
    public static List<Fusion_Benchmarking__c> getFusionBenchmarkingDetail(Map<String, String> fieldNameToFieldValueMap) {
        String query = 'SELECT ';
        for(String fieldName : FusionBenchmarkingWrapper.getFusionBenchMarkingFields()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Fusion_Benchmarking__c';
        query += getWhereClause(fieldNameToFieldValueMap);
        if(AccessControl.ifObjectFieldIsAccessible('Fusion_Benchmarking__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
    
    private static String getWhereClause(Map<String, String> fieldNameToFieldValueMap) {
        String whereClause = '';
        Boolean isWhereClauseAdded = false;
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            if(isWhereClauseAdded) {
                whereClause += ' AND ' + fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
            } else {
                whereClause += ' WHERE ' + fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
                isWhereClauseAdded = true;
            }
        }
        return whereClause;
    }
}