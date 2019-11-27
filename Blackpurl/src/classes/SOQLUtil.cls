/**
 * Author: Tarun Khandelwal
 * Since: Sept. 24, 2014
 * Name: SOQLUtil
 * Description: Apex class which contains all the queries and gives result.
**/
public with sharing class SOQLUtil {  
     
    /** 
     * Name: getAvailableQueryRowsLimit
     * Desc: Getter method which returns available  limit of query rows which can be returned by a SOQL in the context
     * @param:
     * @return: Integer - Available query rows limit  
    **/ 
    public static Integer getAvailableQueryRowsLimit() {
        return Limits.getLimitQueryRows() - Limits.getQueryRows();   
    }  
    
    /**
     * Name: getPicklistEntryValuesForObjField
     * Desc: To get all the picklist values for object piclist type field
     * @param: (1) objName - String - Object Name
     *         (2) fieldName - String - Picklist type field name in the object
     * @return: List<Schema.PicklistEntry>
    **/
    public static List<Schema.PicklistEntry> getPicklistEntryValuesForObjField(String objName, String fieldName) {
        objName = BPUtility.escapeSingleQuotes(objName);
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        Map<String, Schema.SObjectType> globalDesMap = Schema.getGlobalDescribe();
        Schema.SObjectType targetType = globalDesMap.get(objName);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        return field_map.get(fieldName).getDescribe().getPickListValues();
    }
    
    /**
     * Name: getSalesTaxItems
     * Desc: To get all the Sales Tax Item records from Database by executing query
     * @param: (1) salesTaxItemIdsSales - List<id> - Sales Tax Item Ids List 
     * @return: List of Sales Tax Item records
    **/
    public static List<Sobject> getSalesTaxItems(List<id> salesTaxItemIds) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : Constants.SALES_TAX_ITEM_FIELDS_TO_JSON_MAPPING.keyset()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Sales_Tax_Item__c ';
        if(salesTaxItemIds.size() > 0) {
            query += 'WHERE ID IN : salesTaxItemIds';
        }
        query += ' order by Active__c Desc, Name__c';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Sales_Tax_Item__c> salesTaxItems = Database.query(query);
        return salesTaxItems;
    }
    
    /**
     * Name: getActiveSalesTaxItemList
     * Desc: To get all the Sales Tax Item records which are active from Database by executing query
     * @param: (1) salesTaxItemIdsSales - List<id> - Sales Tax Item Ids List, 
     		   (2) fieldNameToFieldValueMap - Map<String, String> field Filter map for where clause
     * @return: List of Sales Tax Item records
    **/
    public static List<Sobject> getActiveSalesTaxItemList(List<id> salesTaxItemIds) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : Constants.SALES_TAX_ITEM_FIELDS_TO_JSON_MAPPING.keyset()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Sales_Tax_Item__c WHERE Active__c = true ';
        if(salesTaxItemIds.size() > 0) {
            query += 'AND ID IN : salesTaxItemIds';
        }
        
        query += ' order by Active__c Desc, Name__c';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Sales_Tax_Item__c> salesTaxItems = Database.query(query);
        return salesTaxItems;
    }
    
    /**
     * Name: getCountry
     * Desc: To get all the Sales Tax records from Database by executing query
     * @param: (1) countryIdList - List<String> - Countries Id  String List
               (2) currentNoOfCountry - Integer - Current number of countries in Grid
     * @return: List of Countries records
    **/
    public static List<Sobject> getCountry(List<String> countryIdList, Integer currentNoOfCountry) {
        String query;
        query = 'SELECT '; 
        for(String fieldsName : Constants.COUNTRY_FIELDS_TO_JSON_MAPPING.keyset()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Country__c ';
        if(countryIdList.size() > 0) {
            query += 'WHERE ID NOT IN : countryIdList'; 
        }
        if(currentNoOfCountry != null){
            query += ' order by Default__c DESC, Visible__c DESC, Name__c ASC LIMIT :currentNoOfCountry' ;
        } else {
            query += ' order by Name__c ASC ' ;
        }
        if(AccessControl.ifObjectFieldIsAccessible('Country__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Country__c> countries = Database.query(query);
        if(currentNoOfCountry != null && BlackPurlContentCtrl.isIncreaseCountriesMethodExecuted) {
            if(countries.size() + 5 < currentNoOfCountry ) {
                countries.clear();
            } else if (countries.size() > 1) {
                for(Integer i = 0; i < currentNoOfCountry - 6 ; i++) {
                    countries.remove(0);
                }
            } 
        }
        return countries;
    }
    
    /**
     * Name: getStateByCountry
     * Desc: To get all the State records from Database by executing query
     * @param: (1) countryId - Id - Parent Country Id
     * @return: List of States records
    **/
    public static List<Sobject> getStateByCountry(Id countryId) {
        String query;
        query = 'SELECT '; 
        for(String fieldsName : Constants.STATE_FIELDS_TO_JSON_MAPPING.keyset()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'State__c ';
        if(countryId != null) {
            query += 'WHERE Country__c = : countryId'; 
        }
        query += ' ORDER BY Default__c DESC, Name__c ASC';
        if(AccessControl.ifObjectFieldIsAccessible('State__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<State__c> states = Database.query(query);
        return states;
    }
    
    
    /**
     * Name: getRecordsForObj
     * Desc: To get object records with field included in query
     * @param: (1) sObjName - sObject name
     *         (2) fieldName - Field to include in query
     * @return: List of object records
    **/ 
    public static List<sObject> getRecordsForObj(String sObjName, String fieldName) {
        sObjName = BPUtility.escapeSingleQuotes(sObjName);
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        List<sObject> sObjRecords = new List<sObject>();
        if( Constants.OBJ_TYPE_NAME_TO_OBJ_API_NAME_MAP.containsKey(sObjName) ){
            String query = 'SELECT Id, ' 
                            + fieldName 
                            + ' FROM ' 
                            + Constants.OBJ_TYPE_NAME_TO_OBJ_API_NAME_MAP.get(sObjName)
                            + ' WHERE ' + fieldName + ' != null'
                            + ' ORDER BY ' + fieldName
                            + ' LIMIT ' + (Limits.getLimitQueries()  - Limits.getQueryRows());
            if(AccessControl.ifObjectFieldIsAccessible(Constants.OBJ_TYPE_NAME_TO_OBJ_API_NAME_MAP.get(sObjName)) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

            sObjRecords = Database.query(query);
        }
        return sObjRecords;
    }
    
    /**
     * Name: getSObjRecords
     * Desc: To get all object records from Database by executing query
     * @param:  (1) sObjName - sObject name
     *          (2) filterKey - Search string
     * @return: List of object records
    **/ 
    public static List<sObject> getSObjRecords(String sObjName, String filterKey) {
        sObjName = BPUtility.escapeSingleQuotes(sObjName);
        filterKey = BPUtility.escapeSingleQuotes(filterKey);
        List<sObject> sObjRecords = new List<sObject>();
        if( Constants.OBJ_TYPE_NAME_TO_OBJ_API_NAME_MAP.containsKey(sObjName) ){
            String query = 'SELECT ';
            
            // Add filter condition
            String filterCondition = '';
            
            // Add fields
            for(String fieldName : Constants.OBJ_TO_JSON_FIELDS_MAP.get(sObjName).keyset()){
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                query += fieldName + ', ';
                
                if(filterKey != null && !fieldName.equalsIgnoreCase('Id') ){
                    filterCondition += (filterCondition.length() > 0) ? ' OR ' : '';
                    filterCondition += fieldName + ' LIKE \'' + filterKey + '%\'';
                }
            }
            query = query.substring(0, query.length()-2);
            
            query += ' FROM ' + BPUtility.escapeSingleQuotes(Constants.OBJ_TYPE_NAME_TO_OBJ_API_NAME_MAP.get(sObjName));
            
            String whereCondition = BPUtility.escapeSingleQuotes(Constants.OBJ_TO_FILTER_CONDITION_MAP.get(sObjName));
            if( whereCondition != null ){
                query += ' WHERE ' + whereCondition;
                query += ' AND ( ' + filterCondition + ')';
            } else {
                query += ' WHERE ' + filterCondition;
            }
            
            query += ' ORDER BY ' + (Constants.OBJ_TO_ORDERBY_CLAUSE_MAP.get(sObjName));
            if(AccessControl.ifObjectFieldIsAccessible(sObjName) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            sObjRecords = Database.query(query);
        }
        return sObjRecords;
    }
    
    /**
     * Name: getAccount
     * Desc: To get all Customers records from Database by executing query
     * @param:  (1) accountIds - List<Id> - List of Account id
     *          (2) currentNoOfAccount - Integer - No of Account Currently
     *          (3) dropDownNumber - Integer - Number of records to be shown on page
     *          (4) isInactiveIncluded - Integer -Record is active or not
     *          (5) filterJSON - String - Filter JSON String
     *          (6) isCustomer- Boolean - Is Customer or not
     * @return: List of Customer records
    **/ 
    public static List<Sobject> getAccount(List<Id> accountIds, Integer currentNoOfAccount, Integer dropDownNumber, Boolean isInactiveIncluded, String filterJSON, Boolean isCustomer) {
        filterJSON = BPUtility.escapeSingleQuotes(filterJSON);
        Map<String,String> JSON_TO_FIELDS_MAPPING;
        Map<String,String> FIELDS_TO_JSON_MAPPING;
        
        if(isCustomer) {
            JSON_TO_FIELDS_MAPPING = Constants.CUSTOMER_JSON_TO_FIELDS_MAPPING;
            FIELDS_TO_JSON_MAPPING = Constants.CUSTOMER_FIELDS_TO_JSON_MAPPING;
        } else {
            JSON_TO_FIELDS_MAPPING = Constants.VENDOR_LIST_JSON_TO_FIELDS_MAPPING;
            FIELDS_TO_JSON_MAPPING = Constants.VENDOR_LIST_FIELDS_TO_JSON_MAPPING;
        }
             
        Map<String, String> filterFieldToSearchedStringMap = Utility.parseFilterJSON(filterJSON, JSON_TO_FIELDS_MAPPING);
        Map<String, String> filterFieldToSeachedOperatorStringMap = Utility.parseFilterJSONOperator(filterJSON, JSON_TO_FIELDS_MAPPING);
        
        List<Account> recentAccounts = new List<Account>();
        recentAccounts = getRecentAccount(isInactiveIncluded, filterFieldToSearchedStringMap, filterFieldToSeachedOperatorStringMap, FIELDS_TO_JSON_MAPPING, isCustomer);
        
        Integer remainingAccount = currentNoOfAccount - recentAccounts.size();
        
        String query;
        query = 'SELECT '; 
        for(String fieldName : FIELDS_TO_JSON_MAPPING.keyset()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Account ';
        
        Boolean isWhereClauseAdded = false;

        if(recentAccountIdList.size() > 0) {
            query += 'WHERE ID NOT IN : recentAccountIdList';
            isWhereClauseAdded = true;
        } 
        if(!isInactiveIncluded) {
            if(isWhereClauseAdded) {
                query += ' AND Active__c = true';
            } else {
                query += ' WHERE Active__c = true';
                isWhereClauseAdded = true;
            }
        }
        if(filterFieldToSearchedStringMap.keyset().size() > 0 ) {
            for(String fieldValue : filterFieldToSearchedStringMap.keyset()) {
                fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
                 if(isWhereClauseAdded) {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' AND ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if (filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'eq') {
                        query += ' AND ' + fieldValue + ' = \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '\'';
                    }
                 } else {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' WHERE ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'eq') {
                        query += ' WHERE ' + fieldValue + ' = \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '\'';
                    }
                    isWhereClauseAdded = true;
                 }
            }
        }

        if(isCustomer) {
            if(isWhereClauseAdded) {
                query += ' AND Is_Customer__c = true';
            } else {
                query += ' WHERE Is_Customer__c = true';
                isWhereClauseAdded = true;
            }
        } else {
            if(isWhereClauseAdded) {
                query += ' AND Is_Vendor__c = true';
            } else {
                query += ' WHERE Is_Vendor__c = true';
                isWhereClauseAdded = true;
            }
        }

        query += ' ORDER BY Name ASC LIMIT :remainingAccount';
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Account> remainingAccounts = Database.query(query);
        List<Account> accounts = new List<Account>();
        accounts.addAll(recentAccounts);
        accounts.addAll(remainingAccounts);
        
        if(BlackPurlContentCtrl.isIncreaseCustomersMethodExecuted || BlackPurlContentCtrl.isIncreaseVendorsMethodExecuted) {
            if(accounts.size() + dropDownNumber < currentNoOfAccount ) {
                accounts.clear();
            } else if (accounts.size() > 1) {
                for(Integer i = 0; i < currentNoOfAccount - dropDownNumber - 1 ; i++) {
                    accounts.remove(0);
                }
            } 
        }
        
        Boolean isWhereClauseAddedInAggQuery = false;
        if(filterFieldToSearchedStringMap.keyset().size() > 0 ) {
            query = 'SELECT count(Id) From Account';
            if(!isInactiveIncluded) {
                if(isWhereClauseAddedInAggQuery) {
                    query += ' AND Active__c = true';
                } else {
                    query += ' WHERE Active__c = true';
                    isWhereClauseAddedInAggQuery = true;
                }
            }
            if(isCustomer) {
                if(isWhereClauseAddedInAggQuery) {
                    query += ' AND Is_Customer__c = true';
                } else {
                    query += ' WHERE Is_Customer__c = true';
                    isWhereClauseAddedInAggQuery = true;
                }
            } else {
                if(isWhereClauseAddedInAggQuery) {
                    query += ' AND Is_Vendor__c = true';
                } else {
                    query += ' WHERE Is_Vendor__c = true';
                    isWhereClauseAddedInAggQuery = true;
                }
            }
            for(String fieldValue : filterFieldToSearchedStringMap.keyset()) {
                fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
                 if(isWhereClauseAddedInAggQuery) {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' AND ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'eq') {
                        query += ' AND ' + fieldValue + ' = \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '\'';
                    } 
                 } else {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' WHERE ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'eq') {
                        query += ' WHERE ' + fieldValue + ' = \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '\'';
                    }
                    isWhereClauseAddedInAggQuery = true;
                 }
            }

            List<AggregateResult> accountAggResult = Database.query(query);
            BlackPurlContentCtrl.customersRetrived = String.valueOf(accountAggResult[0].get('expr0'));
        }
        return accounts;
    }
    
    public static List<Id> recentAccountIdList = new List<Id>();
    
    /**

     * Name: getRecentAccount
     * Desc: To get all recent Customers records from Database by executing query
     * @param:  (1) isInactiveIncluded - Boolean - Record is active or not
     *          (2) filterFieldToSearchedStringMap - Map<String, String> - Map of Field to Search String  
     *          (3) filterFieldToSeachedOperatorStringMap - Map<String, String> - Map of Filter Field To Searched Operator String 
     *          (4) FIELDS_TO_JSON_MAPPING - Map<String, String>  - Field To JSon String Mapping
     *          (5) isCustomer - Boolean - is customer or not
     * @return: List of Customer records
    **/ 
    public static List<Sobject> getRecentAccount(Boolean isInactiveIncluded, Map<String, String> filterFieldToSearchedStringMap, Map<String, String> filterFieldToSeachedOperatorStringMap, Map<String, String> FIELDS_TO_JSON_MAPPING, Boolean isCustomer) {
        String query;
        if(isCustomer) {
            query = 'SELECT Customer__c FROM Recent_Customer__c WHERE CreatedById = \'' + UserInfo.getUserId() + '\' ORDER BY LastModifiedDate DESC LIMIT 20';  
            if(AccessControl.ifObjectFieldIsAccessible('Recent_Customer__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        } else {
            query = 'SELECT Vendor__c FROM Recent_Vendor__c WHERE CreatedById = \'' + UserInfo.getUserId() + '\' ORDER BY LastModifiedDate DESC LIMIT 20';
            if(AccessControl.ifObjectFieldIsAccessible('Recent_Vendor__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        }
        
        List<Sobject> recentAccounts = Database.query(query);
        
        for(Sobject recentAcc : recentAccounts) {
            if(isCustomer) {
                recentAccountIdList.add(Id.valueOf(BPUtility.escapeSingleQuotes(String.valueOf(recentAcc.get('Customer__c')))));
            } else {
                recentAccountIdList.add(Id.valueOf(BPUtility.escapeSingleQuotes(String.valueOf(recentAcc.get('Vendor__c')))));
            }
        }
        
        query = 'SELECT ';
        for(String fieldName : FIELDS_TO_JSON_MAPPING.keyset()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Account ';
        Boolean isWhereClauseAdded = false;

        if(recentAccountIdList.size() > 0) {
            query += 'WHERE ID IN : recentAccountIdList';
            isWhereClauseAdded = true;
        } 
        if(!isInactiveIncluded) {
            if(isWhereClauseAdded) {
                query += ' AND Active__c = true';
            } else {
                query += ' WHERE Active__c = true';
                isWhereClauseAdded = true;
            }
        }
        
        if(isCustomer) {
            if(isWhereClauseAdded) {
                query += ' AND Is_Customer__c = true';
            } else {
                query += ' WHERE Is_Customer__c = true';
                isWhereClauseAdded = true;
            }
        } else {
            if(isWhereClauseAdded) {
                query += ' AND Is_Vendor__c = true';
            } else {
                query += ' WHERE Is_Vendor__c = true';
                isWhereClauseAdded = true;
            }
        }
        
        if(filterFieldToSearchedStringMap.keyset().size() > 0 ) {
            for(String fieldValue : filterFieldToSearchedStringMap.keyset()) {
                fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
                if(isWhereClauseAdded) {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue)=='startswith') {
                        query += ' AND ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(filterFieldToSeachedOperatorStringMap.get(fieldValue)=='eq') {
                        query += ' AND ' + fieldValue + ' = \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '\'';
                    }
                 } else {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue)=='startswith'){
                         query += ' WHERE ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(filterFieldToSeachedOperatorStringMap.get(fieldValue)=='eq'){
                            query += ' WHERE ' + fieldValue + ' = \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '\'';
                    }
                    isWhereClauseAdded = true;
                 }
            }
        }
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Map<Id,Sobject> recAccountsMap = new Map<Id, Sobject>(Database.query(query));
        
        List<Sobject> recAccounts = new List<Sobject>();
        for(Id accountId : recentAccountIdList) {
            if(recAccountsMap.containsKey(accountId)) {
                recAccounts.add(recAccountsMap.get(accountId));
            }
        }
        return recAccounts;
    }
    
    public static List<Id> recentPartIdList = new List<Id>();
    
    /**
     * Name: getParts
     * Desc: To get all Customers records from Database by executing query
     * @param:  (1) partIds - List<Id> - List of Part Record Ids
     *          (2) currentNoOfParts - Integer - Currently No Of Parts  
     *          (3) dropDownNumber - Integer - Number of records to be shown on page
     *          (4) isInactiveIncluded - Boolean - Record is active or not
     *          (5) filterJSON - String - Filter JSON String
     * @return: List of Customer records
    **/ 
    public static List<Sobject> getParts(List<Id> partIds, Integer currentNoOfParts, Integer dropDownNumber, Boolean isInactiveIncluded, String filterJSON) {
        filterJSON = BPUtility.escapeSingleQuotes(filterJSON);
        Map<String, String> filterFieldToSearchedStringMap = Utility.parseFilterJSON(filterJSON, Constants.PART_JSON_TO_FIELDS_MAPPING);
        Map<String,String>  FilterFieldToSeachedOperatorStringMap = Utility.parseFilterJSONOperator(filterJSON, Constants.PART_JSON_TO_FIELDS_MAPPING);
        
        List<Part__c> recentParts = new List<Part__c>();
        recentParts = getRecentPart(isInactiveIncluded, filterFieldToSearchedStringMap, FilterFieldToSeachedOperatorStringMap);
        Integer remainingPart = currentNoOfParts - recentParts.size();
        
        String query;
        query = 'SELECT '; 
        for(String fieldName : Constants.PART_FIELDS_TO_JSON_MAPPING.keyset()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Part__c ';
        
        Boolean isWhereClauseAdded = false;
        if(recentPartIdList.size() > 0) {
            query += 'WHERE ID NOT IN : recentPartIdList';
            isWhereClauseAdded = true;
        } 
        if(!isInactiveIncluded) {
            if(isWhereClauseAdded) {
                query += ' AND Active__c = true';
            } else {
                query += ' WHERE Active__c = true';
                isWhereClauseAdded = true;
            }
        }
        if(filterFieldToSearchedStringMap.keyset().size() > 0 ) {
            for(String fieldValue : filterFieldToSearchedStringMap.keyset()) {
                fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
                 if(isWhereClauseAdded) {
                    if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='startswith'){
                        query += ' AND ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if (FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='eq') {
                        query += ' AND ' + fieldValue + ' = ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } else if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='contains') {
                        query += ' AND ' + fieldValue + ' Like \'%' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='gte') {
                        query += ' AND ' + fieldValue + ' > ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } else if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='lte') {
                        query += ' AND ' + fieldValue + ' < ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } 
                 } else {
                    if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='startswith'){
                        query += ' WHERE ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='eq') {
                        query += ' WHERE ' + fieldValue + ' = ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } else if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='contains') {
                        query += ' WHERE ' + fieldValue + ' Like \'%' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='gte') {
                        query += ' WHERE ' + fieldValue + ' > ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } else if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='lte') {
                        query += ' WHERE ' + fieldValue + ' < ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } 
                    isWhereClauseAdded = true;
                 }
            }
        }
        query += ' ORDER BY Part_ID__c LIMIT :remainingPart';
        
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Part__c> remainingParts = Database.query(query);
        List<Part__c> parts = new List<Part__c>();
        parts.addAll(recentParts);
        parts.addAll(remainingParts);
        if(BlackPurlContentCtrl.isIncreasePartsMethodExecuted) {
            if(parts.size() + dropDownNumber < currentNoOfParts ) {
                parts.clear();
            } else if (parts.size() > 1) {
                for(Integer i = 0; i < currentNoOfParts - dropDownNumber - 1 ; i++) {
                    parts.remove(0);
                }
            } 
        }
        
        Boolean isWhereClauseAddedInAggQuery = false;
        if(filterFieldToSearchedStringMap.keyset().size() > 0 ) {
            query = 'SELECT count(Id) From Part__c';
            if(!isInactiveIncluded) {
                if(isWhereClauseAddedInAggQuery) {
                    query += ' AND Active__c = true';
                } else {
                    query += ' WHERE Active__c = true';
                    isWhereClauseAddedInAggQuery = true;
                }
            }
            for(String fieldValue : filterFieldToSearchedStringMap.keyset()) {
                fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
                 if(isWhereClauseAddedInAggQuery) {
                    if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='startswith'){
                        query += ' AND ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if (FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='eq') {
                        query += ' AND ' + fieldValue + ' = ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } else if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='contains') {
                        query += ' AND ' + fieldValue + ' Like \'%' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='gte') {
                        query += ' AND ' + fieldValue + ' > ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } else if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='lte') {
                        query += ' AND ' + fieldValue + ' < ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } 
                 } else {
                    if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='startswith'){
                        query += ' WHERE ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='eq') {
                        query += ' WHERE ' + fieldValue + ' = ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } else if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='contains') {
                        query += ' WHERE ' + fieldValue + ' Like \'%' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='gte') {
                        query += ' WHERE ' + fieldValue + ' > ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } else if(FilterFieldToSeachedOperatorStringMap.get(fieldValue)=='lte') {
                        query += ' WHERE ' + fieldValue + ' < ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } 
                    isWhereClauseAddedInAggQuery = true;
                 }
            }
            
            List<AggregateResult> partAggResult = Database.query(query);
            BlackPurlContentCtrl.partsRetrived = String.valueOf(partAggResult[0].get('expr0'));
        }
        return parts;
    }
    
    /**
     * Name: getRecentPart
     * Desc: To get all recent Customers records from Database by executing query
     * @param:  (1) isInactiveIncluded - Boolean -Record is active or not
     *          (2) filterFieldToSearchedStringMap - Map<String, String> - Map of Field to Search String  
     *          (3) filterFieldToSeachedOperatorStringMap - Map<String, String> - Map of Filter Field To Searched Operator String 
     * @return: List of Customer records
    **/ 
    public static List<Sobject> getRecentPart(Boolean isInactiveIncluded, Map<String, String> filterFieldToSearchedStringMap, Map<String, String> FilterFiledToSeachedOperatorStringMap) {
        String query;
        query = 'SELECT Part__c FROM Recent_Part__c WHERE CreatedById = \'' + UserInfo.getUserId() + '\' ORDER BY LastModifiedDate DESC LIMIT 20';
        if(AccessControl.ifObjectFieldIsAccessible('Recent_Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Recent_Part__c> recentParts = Database.query(query);
        
        for(Recent_Part__c recentCust : recentParts) {
            recentPartIdList.add(recentCust.Part__c);
        }
        
        query = 'SELECT ';
        for(String fieldName : Constants.PART_FIELDS_TO_JSON_MAPPING.keyset()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Part__c ';
        Boolean isWhereClauseAdded = false;
        
        if(recentPartIdList.size() > 0) {
            query += 'WHERE ID IN : recentPartIdList';
            isWhereClauseAdded = true;
        } 
        if(!isInactiveIncluded) {
            if(isWhereClauseAdded) {
                query += ' AND Active__c = true';
            } else {
                query += ' WHERE Active__c = true';
                isWhereClauseAdded = true;
            }
        }
        
        if(filterFieldToSearchedStringMap.keyset().size() > 0 ) {
            for(String fieldValue : filterFieldToSearchedStringMap.keyset()) {
                fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
                if(isWhereClauseAdded) {
                    if(FilterFiledToSeachedOperatorStringMap.get(fieldValue)=='startswith') {
                        query += ' AND ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(FilterFiledToSeachedOperatorStringMap.get(fieldValue)=='eq') {
                        query += ' AND ' + fieldValue + ' = ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } else if(FilterFiledToSeachedOperatorStringMap.get(fieldValue)=='contains') {
                        query += ' AND ' + fieldValue + ' Like \'%' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(FilterFiledToSeachedOperatorStringMap.get(fieldValue)=='gte') {
                        query += ' AND ' + fieldValue + ' > ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } else if(FilterFiledToSeachedOperatorStringMap.get(fieldValue)=='lte') {
                        query += ' AND ' + fieldValue + ' < ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } 
                 } else {
                    if(FilterFiledToSeachedOperatorStringMap.get(fieldValue)=='startswith'){
                        query += ' WHERE ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(FilterFiledToSeachedOperatorStringMap.get(fieldValue)=='eq'){
                        query += ' WHERE ' + fieldValue + ' = ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } else if(FilterFiledToSeachedOperatorStringMap.get(fieldValue)=='contains') {
                        query += ' WHERE ' + fieldValue + ' Like \'%' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(FilterFiledToSeachedOperatorStringMap.get(fieldValue)=='gte') {
                        query += ' WHERE ' + fieldValue + ' > ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } else if(FilterFiledToSeachedOperatorStringMap.get(fieldValue)=='lte') {
                        query += ' WHERE ' + fieldValue + ' < ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } 
                    isWhereClauseAdded = true;
                 }
            }
        }
        //system.assert(false, query);
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Map<Id,Sobject> recPartsMap = new Map<Id, Sobject>(Database.query(query));
        
        List<Sobject> recParts = new List<Sobject>();
        for(Id PartId : recentPartIdList) {
            if(recPartsMap.containsKey(PartId)) {
                recParts.add(recPartsMap.get(PartId));

            }
        }
        
        return recParts;
    }
    
    /**
     * Name: getComapanyCustomer
     * Desc: To get Comapny Customers record for given id from Database by executing query
     * @param:  (1) String -  customerId - Id of customer
     * @return: Comapny Customer records
    **/ 
    public static Sobject getComapanyCustomer(String customerId) {
        customerId = BPUtility.escapeSingleQuotes(customerId);
        String query;
        query = 'SELECT '; 
        for(String fieldName : Constants.COMAPANY_CUSTOMER_FIELDS_TO_JSON_MAPPING.keyset()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Account ';
        if(customerId != null) {
            query += 'WHERE ID =: customerId';
        } 
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Account> customersList = Database.query(query);
        return customersList[0];
    }
    
    
    /**
     * Name: getPartsByPartId
     * Desc: To get part record by part id
     * @param:  (1) String - partId - Id of part
     * @return: part record
    **/ 
    public static Sobject getPartsByPartId(String partId) {
        partId = BPUtility.escapeSingleQuotes(partId);
        String query;
        query = 'SELECT '; 
        for(String fieldName : Constants.PART_ALL_FIELDS_TO_JSON_MAPPING.keyset()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Part__c ';
        if(partId != null) {
            query += 'WHERE ID =: partId';
        } 
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Part__c> partsList = Database.query(query);
        return partsList[0];
    }
    
    /**
     * Name: getPartRecord
     * Desc: To get part records list
     * @param: (1) List<Id>  - partIds - List of Part ids
     * @return: Part records list
    **/ 
    public static List<Part__c> getPartRecord(List<Id> partIds) {
        String query;
        query = 'SELECT '; 
        for(String fieldName : Part.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Part__c ';
        if(partIds != null) {
            query += 'WHERE ID IN: partIds';
        } 
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Part__c> partsList = Database.query(query);
        return partsList;
    }
    
    /**
     * Name: getAlternatePartRecords
     * Desc: To get Alternate part records list
     * @param:  List<Id> record Ids
     * @return: AlternatePart records list
    **/ 
    public static List<Part_Alternates__c> getAlternatePartRecords(List<Id> idsList) {
        String query;
        query = 'SELECT '; 
        for(String fieldName : AlternatePart.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Part_Alternates__c ';
        if(idsList != null) {
            query += 'WHERE ID IN: idsList';
        } 
        if(AccessControl.ifObjectFieldIsAccessible('Part_Alternates__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Part_Alternates__c> alternatePartsList = Database.query(query);
        return alternatePartsList;
    }
    
    /**
     * Name: getAlternatePartRecords
     * Desc: To get Alternate part records list
     * @param:  List<Id> record Ids
     * @return: AlternatePart records list
    **/ 
    public static List<Part_Alternates__c> getAlternatePartRecords(Map<String, String> fieldNameToFieldValueMap) {
        String query;
        query = 'SELECT '; 
        for(String fieldName : AlternatePart.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Part_Alternates__c ';
        Boolean isWhereClauseAdded = false;
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            if(isWhereClauseAdded) {
                query += ' AND ' + fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
            } else {
                query += ' WHERE ' + fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
                isWhereClauseAdded = true;
            }
        }
        if(AccessControl.ifObjectFieldIsAccessible('Part_Alternates__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Part_Alternates__c> alternatePartsList = Database.query(query);
        return alternatePartsList;
    }
    
    /**
     * Name: getPOTypeRecordsById
     * Desc: To get Alternate part records list
     * @param:  List<Id> record Ids
     * @return: AlternatePart records list
    **/ 
    public static List<PO_Type__c> getPOTypeRecordsById(List<Id> idsList) {
        String query;
        query = 'SELECT '; 
        for(String fieldName : POType.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'PO_Type__c ';
        if(idsList != null) {
            query += 'WHERE ID IN: idsList';
        } 
        if(AccessControl.ifObjectFieldIsAccessible('PO_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<PO_Type__c> poTypeRecordsList = Database.query(query);
        return poTypeRecordsList;
    }
    
    /**
     * Name: getProductRecordsById
     * Desc: To get Product records list
     * @param:  List<Id> record Ids
     * @return: Product records list
    **/ 
    public static List<Product__c> getProductRecordsById(List<Id> idsList) {
        String query;
        query = 'SELECT '; 
        for(String fieldName : VendorProduct.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Product__c ';
        if(idsList != null) {
            query += 'WHERE ID IN: idsList';
        } 
        if(AccessControl.ifObjectFieldIsAccessible('Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Product__c> productRecordsList = Database.query(query);
        return productRecordsList;
    }
    
    /**
     * Name: getPartActiveOrderGroupsForPart
     * Desc: To get Part Active Orders for a Part Id
     * @param:  (1) partId - Id - Part Id
     *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)
     * @return: Vendor Order Line Item Group Record  list
    **/ 
    public static List<Vendor_Order_Line_Item_Group__c> getPartActiveOrderGroupsForPart(Id partId, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : ActiveOrder.getFieldsListUsedInPart()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Item_Group__c ';
        // Added by Hitesh - Status__c != \'Cancelled\'
        query += 'WHERE Part__c =: partId and Status__c != \'Cancelled\' AND Unreceived_Qty__c > 0';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += sortKey + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            } 
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Vendor_Order_Line_Item_Group__c> partActiveOrders = Database.query(query);
        return partActiveOrders;
    }
    
    /**
     * Name: getCOLIForPart
     * Desc: To get Part Active Sales Orders for a Part Id
     * @param:  (1) partId - Id - Part Id
     *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)
     * @return: Customer Order Line Item Record  list
    **/ 
    public static List<CO_Line_Item__c> getCOLIForPart(Id partId, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : ActiveSalesOrder.getCOLIFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Line_Item__c ';
        query += 'WHERE Part__c =: partId';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<CO_Line_Item__c> coliRecords = Database.query(query);
        return coliRecords;
    }
    
    /**
     * Name: getActiveOrdersForCustomer
     * Desc: To get Part Active Orders for a Part Id
     * @param:  (1) customerId - Id - Customer Id
     *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)
     * @return: Customer Order line item record list
    **/ 
    public static List<CO_Line_Item__c> getActiveOrdersForCustomer(Id customerId, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : ActiveOrder.getFieldsListUsedInCustomer()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Line_Item__c ';
        query += 'WHERE CO_Header__r.Customer__c =: customerId';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Line_Item__c> customerActiveOrders = Database.query(query);
        return customerActiveOrders;
    }
    
    /**
     * Name: getPartActiveOrdersForPart
     * Desc: To get Part Active Orders for a Part Id
     * @param:  (1) vohIdSet - Set<Id>  - Set of Vendor Order header ids
     *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)
     * @return: Vendor Order header record list
    **/ 
    public static List<Vendor_Order_Header__c> getPartActiveOrdersForPart(Set<Id> vohIdSet, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : ActiveOrder.getActiveOrderfieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Header__c ';
        query += 'WHERE Id IN :vohIdSet and status__c != \'Received\'';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Vendor_Order_Header__c> partActiveOrders = Database.query(query);

        return partActiveOrders;
    }
    
    /**
     * Name: getPartActiveSalesOrdersForPart
     * Desc: To get Part Active Orders for a Part Id
     * @param:  (1) cohIdSet - Set<Id>  - Set of Vendor Order header ids
     *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)
     * @return: Vendor Order header record list
    **/ 
    public static List<CO_Header__c> getPartActiveSalesOrdersForPart(Id partId, Set<Id> cohIdSet, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : ActiveSalesOrder.getActiveSalesOrderfieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Header__c ';
        query += 'WHERE Id IN: cohIdSet and status__c = \'Open\'';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> partActiveSalesOrders = Database.query(query);
        return partActiveSalesOrders;
    }
    
    /**
     * Name: getLabourRecords
     * Desc: To get Labour records by SOQL
     * @param:  (1) labourIds- Set<Id> - Set Of Labour Ids
     *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)  
     * @return: Labour Code records list
    **/ 
    public static List<Labour_Code__c> getLabourRecords(Set<Id> labourIds, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : LabourRecord.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Labour_Code__c ';
        query += 'WHERE Id IN :labourIds';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Labour_Code__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Labour_Code__c> labourRecords = Database.query(query);
        return labourRecords;
    }
    
    /**
     * Name: getSimilarLabourRecords
     * Desc: Method to return all similar labour records
     * @param:  (1) labourCode - String - Code value by which to search
     *          (2) labourDescription - String - Description value by which to search
     * @return: Labour Code records list
    **/
    public static List<Labour_Code__c> getSimilarLabourRecords(String labourCode, String labourDescription) {
        labourCode = BPUtility.escapeSingleQuotes(labourCode);
        labourDescription = BPUtility.escapeSingleQuotes(labourDescription);
        String query;
        query = 'SELECT ';
        for(String fieldName : LabourRecord.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Labour_Code__c '; 
        
        
        Boolean isWhereClauseAdded = false;
        if(labourCode != null && labourCode != '') {
            isWhereClauseAdded = true;
            query += ' WHERE Code__c = \'' + labourCode + '\'';
        } 
        if(labourDescription != null && labourDescription != '') {
            if(isWhereClauseAdded) {
                query += ' OR Description__c LIKE \'%' + labourDescription + '%\'';
            } else {
                query += ' WHERE Description__c LIKE \'%' + labourDescription + '%\'';
            }
        }
        if(AccessControl.ifObjectFieldIsAccessible('Labour_Code__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Labour_Code__c> labourRecords = Database.query(query);
        return labourRecords;
    }
    
    /**
     * Name: getVendorActiveOrders
     * Desc: To get Vendor Active Orders for a Vendor Id
     * @param:  (1) vendorId - Id - Vendor Record Id
     *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)     
     * @return: Vendor Order Header record list
    **/ 
    public static List<Vendor_Order_Header__c> getVendorActiveOrders(Id vendorId, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : ActiveOrder.getActiveOrderfieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Header__c ';
        query += 'WHERE Vendor__c =: vendorId AND Status__c Not IN (\'Received\', \'Cancelled\')';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Header__c> vendorActiveOrders = Database.query(query);
        return vendorActiveOrders;
    }
    
    /**
     * Name: getPOTypesForVendor
     * Desc: To get Vendor PO Types for a vendor Id
     * @param:  (1) vendorId - Id - Vendor Record Id
     *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)    
     * @return: Vendor PO Types records list
    **/ 
    public static List<PO_Type__c> getPOTypesForVendor(Id vendorId, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : POType.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'PO_Type__c ';
        query += 'WHERE Vendor__c =: vendorId';
        
        // Order by clause
        query += ' ORDER BY IsDefault__c Desc, ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += 'LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('PO_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<PO_Type__c> poTypeRecords = Database.query(query);
        return poTypeRecords;
    }
    
    /**
     * Name: getAlternatePartRecordsForPart
     * Desc: To get Alternate part records list related to a Part Id
     * @param:  (1) vendorId - Id - Vendor Record Id
     *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)    
     * @return: AlternatePart records list
    **/ 
    public static List<Part_Alternates__c> getAlternatePartRecordsForPart(Id partId, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : AlternatePart.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        
        query += ' FROM ' + Constants.NAMESPACE + 'Part_Alternates__c ';
        query += 'WHERE Part_Id__c =: partId ';
        //query += 'WHERE Part_Id__c =: partId OR (Alternate_Part_ID__c =: partId AND Relation__c = \'Alternate\')';
        
        // Order by clause
        query += ' ORDER BY Preferred__c Desc, ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Part_Alternates__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Part_Alternates__c> alternatePartsList = Database.query(query);
        return alternatePartsList;
    }
    
    /**
     * Name: getPartTaxesWithSalesTaxesForPart
     * Desc: To get Part taxes with sales taxes information for a Part Id
     * @param:  (1) vendorId - Id - Vendor Record Id
     *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)    
     * @return: Part Taxes records list
    **/ 
    public static List<Part_Tax__c> getPartTaxesWithSalesTaxesForPart(Id partId, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : TaxExemption.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Part_Tax__c ';
        query += 'WHERE Part_Id__c =: partId';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Part_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Part_Tax__c> partTaxesList = Database.query(query);
        return partTaxesList;
    }
    
    /**
     * Name: getContactsForVendor
     * Desc: To get Part taxes with sales taxes information for a Part Id
     * @param:  (1) vendorId - Id - Vendor Record Id
     *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)    
     * @return: Contact list
    **/ 
    public static List<Contact> getContactsForVendor(Id vendorId, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : VendorContact.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Contact ';
        
        if(vendorId != null){
            query += 'WHERE AccountId =: vendorId';
        }
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Contact') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Contact> contactsList = Database.query(query);
        return contactsList;
    }
    
    /**
     * Name: getProductsForVendor
     * Desc: To get Vendor Products for a vendor Id
     * @param:  (1) vendorId - Id - Vendor Record Id
     *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)    
     * @return: Vendor Product records list
    **/ 
    public static List<Product__c> getProductsForVendor(Id vendorId, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : VendorProduct.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Product__c ';
        query += 'WHERE Vendor__c =: vendorId';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += 'LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Product__c> vendorProductRecords = Database.query(query);
        return vendorProductRecords;
    }
    
    /**
     * Name: getCOHeaderDetailsForCustomer
     * Desc: To get customer order header details
     * @param: 
     * @return: List<Sobject> - customer order header records
    **/
    public static List<Sobject> getCOHeaderDetailsForCustomer(Id customerId, Map<String, String> sortFieldMap) {
        String query;   
        String statusValue = 'Closed';
        query = 'SELECT '; 
        for(String fieldsName : COHeader.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', '; 
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Header__c ';
        if(customerId != null) {
            query += 'WHERE Customer__c =: customerId AND Order_Status__c !=: statusValue';
        }
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += 'Name asc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<CO_Header__c> coHeaderRec = Database.query(query);
        return coHeaderRec;
    }
    
    /**
     * Name: getCategory
     * Desc: To get Category records
     * @param:  (1) categoryIds - List<Id> Category Id List
     *          (2) currentNoOfCategories - Integer - Current No Of Categories
     *          (3) dropDownNumber - Integer - Number of records to be shown on page
     *          (4) isInactiveIncluded - Boolean - Record is active or not
     *          (5) filterJSON - String - Filter JSON String
     * @return: Category List
    **/ 
    public static List<Sobject> getCategory(List<Id> categoryIds, Integer currentNoOfCategories, Integer dropDownNumber, Boolean isInactiveIncluded, String filterJSON) {
        filterJSON = BPUtility.escapeSingleQuotes(filterJSON);
        Map<String, String> filterFieldToSearchedStringMap = Utility.parseFilterJSON(filterJSON, Constants.CATEGORY_LIST_JSON_TO_FIELDS_MAPPING);
        Map<String,String>  filterFieldToSeachedOperatorStringMap = Utility.parseFilterJSONOperator(filterJSON, Constants.CATEGORY_LIST_JSON_TO_FIELDS_MAPPING);
        
        String query;
        query = 'SELECT '; 
        for(String fieldName : Constants.CATEGORY_LIST_FIELDS_TO_JSON_MAPPING.keyset()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Category__c ';
        Boolean isWhereClauseAdded = false;
        if(categoryIds.size() > 0) {
            query += 'WHERE ID IN : categoryIds';
            isWhereClauseAdded = true;
        }
        if(!isInactiveIncluded) {
            if(isWhereClauseAdded) {
                query += ' AND Active__c = true';
            } else {
                query += ' WHERE Active__c = true';
                isWhereClauseAdded = true;
            }
        }
        
        if(filterFieldToSearchedStringMap.keyset().size() > 0 ) {
            for(String fieldValue : filterFieldToSearchedStringMap.keyset()) {
                fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
                 if(isWhereClauseAdded) {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' AND ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if (filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'eq') {
                        query += ' AND ' + fieldValue + ' = ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    }
                 } else {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' WHERE ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(filterFieldToSeachedOperatorStringMap.get(fieldValue)=='eq') {
                        query += ' WHERE ' + fieldValue + ' = ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } 
                    isWhereClauseAdded = true;
                 }
            }
        }
        query += ' ORDER BY Active__c DESC, Default__c DESC, Type__c ASC, Name ASC LIMIT : currentNoOfCategories'; 
        
        if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Category__c> categoryList = Database.query(query);
        
        if(BlackPurlContentCtrl.isIncreaseCateoriesMethodExecuted) {
            if(categoryList.size() + dropDownNumber < currentNoOfCategories ) {
                categoryList.clear();
            } else if (categoryList.size() > 1) {
                for(Integer i = 0; i < currentNoOfCategories - dropDownNumber - 1 ; i++) {
                    categoryList.remove(0);
                }
            } 
        }
        
        Boolean isWhereClauseAddedInAggQuery = false;
        if(filterFieldToSearchedStringMap.keyset().size() > 0 ) {
            query = 'SELECT count(Id) From Category__c';
            if(!isInactiveIncluded) {
                if(isWhereClauseAddedInAggQuery) {
                    query += ' AND Active__c = true';
                } else {
                    query += ' WHERE Active__c = true';
                    isWhereClauseAddedInAggQuery = true;
                }
            }
            for(String fieldValue : filterFieldToSearchedStringMap.keyset()) {
                fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
                 if(isWhereClauseAddedInAggQuery) {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' AND ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if (filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'eq') {
                        query += ' AND ' + fieldValue + ' = ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    }
                 } else {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' WHERE ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } else if(filterFieldToSeachedOperatorStringMap.get(fieldValue)=='eq') {
                        query += ' WHERE ' + fieldValue + ' = ' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue));
                    } 
                    isWhereClauseAddedInAggQuery = true;
                 }
            }
            
            List<AggregateResult> categoryAggResult = Database.query(query);
            BlackPurlContentCtrl.filterRecordsRetrived = String.valueOf(categoryAggResult[0].get('expr0'));
        }
        
        return categoryList;
    }
    
    /**
     * Name: getUnitMakes
     * Desc: To get Unit Makes records
     * @param:  (1) unitMakeIds - List<Id> Unit Make Id List
     *          (2) currentNoOfUnitMakes - Integer - Current No Of Unit Makes
     *          (3) dropDownNumber - Integer - Number of records to be shown on page
     *          (4) isInactiveIncluded - Boolean - Record is active or not
     *          (5) filterJSON - String - Filter JSON String
     * @return: Unit Makes records
    **/ 
    public static List<Sobject> getUnitMakes(List<Id> unitMakeIds, Integer currentNoOfUnitMakes, Integer dropDownNumber, Boolean isInactiveIncluded, String filterJSON) {
        filterJSON = BPUtility.escapeSingleQuotes(filterJSON);
        Map<String, String> filterFieldToSearchedStringMap = Utility.parseFilterJSON(filterJSON, Constants.UNIT_MAKE_LIST_JSON_TO_FIELDS_MAPPING);
        Map<String,String>  filterFieldToSeachedOperatorStringMap = Utility.parseFilterJSONOperator(filterJSON, Constants.UNIT_MAKE_LIST_JSON_TO_FIELDS_MAPPING);
        
        String query;
        query = 'SELECT '; 
        for(String fieldName : Constants.UNIT_MAKE_LIST_FIELDS_TO_JSON_MAPPING.keyset()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Unit_Make__c ';
        Boolean isWhereClauseAdded = false;
        if(unitMakeIds.size() > 0) {
            query += 'WHERE ID IN : unitMakeIds';
            isWhereClauseAdded = true;
        }
        if(!isInactiveIncluded) {
            if(isWhereClauseAdded) {
                query += ' AND Active__c = true';
            } else {
                query += ' WHERE Active__c = true';
                isWhereClauseAdded = true;
            }
        }
        
        if(filterFieldToSearchedStringMap.keyset().size() > 0 ) {
            for(String fieldValue : filterFieldToSearchedStringMap.keyset()) {
                fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
                 if(isWhereClauseAdded) {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' AND ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } 
                 } else {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' WHERE ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } 
                    isWhereClauseAdded = true;
                 }
            }
        }
        query += ' ORDER BY Active__c DESC, Name ASC LIMIT : currentNoOfUnitMakes'; 
        if(AccessControl.ifObjectFieldIsAccessible('Unit_Make__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Unit_Make__c> unitMakeList = Database.query(query);
        
        if(BlackPurlContentCtrl.isIncreaseUnitMakesMethodExecuted) {
            if(unitMakeList.size() + dropDownNumber < currentNoOfUnitMakes ) {
                unitMakeList.clear();
            } else if (unitMakeList.size() > 1) {
                for(Integer i = 0; i < currentNoOfUnitMakes - dropDownNumber - 1 ; i++) {
                    unitMakeList.remove(0);
                }
            } 
        }
        
        Boolean isWhereClauseAddedInAggQuery = false;
        if(filterFieldToSearchedStringMap.keyset().size() > 0 ) {
            query = 'SELECT count(Id) From Unit_Make__c';
            if(!isInactiveIncluded) {
                if(isWhereClauseAddedInAggQuery) {
                    query += ' AND Active__c = true';
                } else {
                    query += ' WHERE Active__c = true';
                    isWhereClauseAddedInAggQuery = true;
                }
            }
            for(String fieldValue : filterFieldToSearchedStringMap.keyset()) {
                fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
                 if(isWhereClauseAddedInAggQuery) {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' AND ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    }
                 } else {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' WHERE ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } 
                    isWhereClauseAddedInAggQuery = true;
                 }
            }
            
            List<AggregateResult> unitMakeAggResult = Database.query(query);
            BlackPurlContentCtrl.filterRecordsRetrived = String.valueOf(unitMakeAggResult[0].get('expr0'));
        }
        
        return unitMakeList;
    }
    
    /**
     * Name: getUnitModelsByUnitMakeId
     * Desc: To get Unit Makes records
     * @param:  (1) unitMakeId - String - Unit Make Id 
     *          (2) currentNoOfUnitModels - Integer - Current No Of Unit Models
     *          (3) dropDownNumber - Integer - Number of records to be shown on page
     *          (4) isInactiveIncluded - Boolean - Record is active or not
     *          (5) filterJSON - String - Filter JSON String
     * @return: Unit Model records
    **/ 
    public static List<Sobject> getUnitModelsByUnitMakeId(String unitMakeId, Integer currentNoOfUnitModels, Integer dropDownNumber, Boolean isInactiveIncluded, String filterJSON) {
        unitMakeId = BPUtility.escapeSingleQuotes(unitMakeId);
        filterJSON = BPUtility.escapeSingleQuotes(filterJSON);
        Map<String, String> filterFieldToSearchedStringMap = Utility.parseFilterJSON(filterJSON, Constants.UNIT_MODEL_LIST_JSON_TO_FIELDS_MAPPING);
        Map<String,String>  filterFieldToSeachedOperatorStringMap = Utility.parseFilterJSONOperator(filterJSON, Constants.UNIT_MODEL_LIST_JSON_TO_FIELDS_MAPPING);
        
        String query;
        query = 'SELECT '; 
        for(String fieldName : Constants.UNIT_MODEL_LIST_FIELDS_TO_JSON_MAPPING.keyset()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query += '(SELECT Id, Sub_Model_Name__c, Sub_Model_Description__c, VIN_Code__c, Active__c FROM Unit_Sub_Models__r)';
        query += ' FROM ' + Constants.NAMESPACE + 'Unit_Model__c ';
        Boolean isWhereClauseAdded = false;
        if(unitMakeId != null) {
            query += 'WHERE Unit_Make__c = :unitMakeId';
            isWhereClauseAdded = true;
        }
        if(!isInactiveIncluded) {
            if(isWhereClauseAdded) {
                query += ' AND Active__c = true';
            } else {
                query += ' WHERE Active__c = true';
                isWhereClauseAdded = true;
            }
        }
        
        if(filterFieldToSearchedStringMap.keyset().size() > 0 ) {
            for(String fieldValue : filterFieldToSearchedStringMap.keyset()) {
                fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
                 if(isWhereClauseAdded) {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' AND ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } 
                 } else {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' WHERE ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } 
                    isWhereClauseAdded = true;
                 }
            }
        }
        query += ' ORDER BY Active__c DESC, Name__c ASC LIMIT : currentNoOfUnitModels'; 
        if(AccessControl.ifObjectFieldIsAccessible('Unit_Model__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Unit_Model__c> unitModelList = Database.query(query);        
        if(BlackPurlContentCtrl.isIncreaseUnitModelsMethodExecuted) {
            if(unitModelList.size() + dropDownNumber < currentNoOfUnitModels ) {
                unitModelList.clear();
            } else if (unitModelList.size() > 1) {
                for(Integer i = 0; i < currentNoOfUnitModels - dropDownNumber - 1 ; i++) {
                    unitModelList.remove(0);
                }
            } 
        }
        
        Boolean isWhereClauseAddedInAggQuery = false;
        if(filterFieldToSearchedStringMap.keyset().size() > 0 ) {
            query = 'SELECT count(Id) From Unit_Model__c';
            if(!isInactiveIncluded) {
                if(isWhereClauseAddedInAggQuery) {
                    query += ' AND Active__c = true';
                } else {
                    query += ' WHERE Active__c = true';
                    isWhereClauseAddedInAggQuery = true;
                }
            }
            for(String fieldValue : filterFieldToSearchedStringMap.keyset()) {
                fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
                 if(isWhereClauseAddedInAggQuery) {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' AND ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    }
                 } else {
                    if(filterFieldToSeachedOperatorStringMap.get(fieldValue) == 'startswith'){
                        query += ' WHERE ' + fieldValue + ' Like \'' + BPUtility.escapeSingleQuotes(filterFieldToSearchedStringMap.get(fieldValue)) + '%\'';
                    } 
                    isWhereClauseAddedInAggQuery = true;
                 }
            }
            
            List<AggregateResult> unitModelAggResult = Database.query(query);
            BlackPurlContentCtrl.filterRecordsRetrived = BPUtility.escapeSingleQuotes(String.valueOf(unitModelAggResult[0].get('expr0')));
        }        
        return unitModelList;
    }
    

    /**
     * Name: getFilteredCategory
     * Desc: To get Filtered Category records
     * @param:  searchingString - Seraching KeyWord
     *          fieldAPIName - Field Name for which filter is applied
     * @return: Category List
    **/ 
    public static List<Sobject> getFilteredCategory(String searchingString, String fieldAPIName) {
        fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
        searchingString = BPUtility.escapeSingleQuotes(searchingString);
        String query;
        query = 'SELECT '+ fieldAPIName + ' From Category__c Where '+ fieldAPIName +' Like \'' + searchingString +'%\'' ;
        if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Category__c> searchedCategories = Database.query(query);
        return searchedCategories;
    }
        
    /**
     * Name: getFilteredAccount
     * Desc: To get Filtered Account records
     * @param:  (1) searchingString - Seraching KeyWord
     *          (2) fieldAPIName - Field Name for which filter is applied
     *          (3) isVendor - is vendor or not
     *          (4) isInactiveIncluded - Record is active or not
     * @return: Comapny Customer records
    **/ 
    public static List<Sobject> getFilteredAccount(String searchingString, String fieldAPIName, Boolean isVendor, Boolean isInactiveIncluded) {
        searchingString = BPUtility.escapeSingleQuotes(searchingString);
        fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
        String query;
        query = 'SELECT '+ fieldAPIName + ' From Account Where '+ fieldAPIName +' Like \'' + searchingString +'%\' ' ;
        if(isVendor) {
            query += ' AND Is_Vendor__c = true';
        } else {
            query += ' AND Is_Customer__c = true';
        }
        if(!isInactiveIncluded) {
            query += ' AND Active__c = true';
        }  
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Account> searchedAccounts = Database.query(query);
        return searchedAccounts;
    }
    
    /**
     * Name: getFilteredUnitMakes
     * Desc: To get Filtered Category records
     * @param:  (1) searchingString - Seraching KeyWord
     *          (2) fieldAPIName - Field Name for which filter is applied
     *          (3) isInactiveIncluded - Record is active or not
     * @return: Unit Make records
    **/ 
    public static List<Sobject> getFilteredUnitMakes(String searchingString, String fieldAPIName, Boolean isInactiveIncluded) {
        searchingString = BPUtility.escapeSingleQuotes(searchingString);
        fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
        String query;
        query = 'SELECT '+ fieldAPIName + ' From Unit_Make__c Where '+ fieldAPIName +' Like \'' + searchingString +'%\'' ;
        if(AccessControl.ifObjectFieldIsAccessible('Unit_Make__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Unit_Make__c> searchedUnitMakes = Database.query(query);
        return searchedUnitMakes;
    }
    
    /**
     * Name: getFilteredUnitModels
     * Desc: To get Filtered Category records
     * @param:  (1) unitMakeId - Unit Make Record Id
     *          (2) searchingString - Seraching KeyWord
     *          (3) fieldAPIName - Field Name for which filter is applied
     *          (4) isInactiveIncluded - Record is active or not
     * @return: Unit Model records
    **/ 
    public static List<Sobject> getFilteredUnitModels(String unitMakeId, String searchingString, String fieldAPIName, Boolean isInactiveIncluded) {
        searchingString = BPUtility.escapeSingleQuotes(searchingString);
        unitMakeId = BPUtility.escapeSingleQuotes(unitMakeId);
        fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
        String query;
        query = 'SELECT '+ fieldAPIName + ' From Unit_Model__c Where '+ fieldAPIName +' Like \'' + searchingString +'%\' AND Unit_Make__c = :unitMakeId' ;
        if(AccessControl.ifObjectFieldIsAccessible('Unit_Model__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Unit_Model__c> searchedUnitModels = Database.query(query);
        return searchedUnitModels;
    }
    
    /**
     * Name: getRecentItems
     * Desc: To get all recent items from Database by executing query
     * @param:  
     * @return: List of Recently Viewed records
    **/
    public static List<Sobject> getRecentItems() {
        String query;   
        query = 'SELECT Name FROM RecentlyViewed ';
        if(AccessControl.ifObjectFieldIsAccessible('RecentlyViewed') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<RecentlyViewed> recentItems = Database.query(query);
        return recentItems;
    }
    
    /**
     * Name: getApplicableTaxes
     * Desc: To get all applicable taxes from Database by executing query
     * @param:  SalesTaxId- Id - Sales Tax Record Id
     * @return: List of All applicable taxes records
    **/
    public static List<Sobject> getApplicableTaxes(Id SalesTaxId) {
        String query;
        query = 'SELECT Sales_Tax_Item__c, Sales_Tax__c, Sales_Tax_Item__r.Name__c, Sales_Tax_Item__r.AccountingId__c From Applicable_Taxes__c where Sales_Tax__c = : SalesTaxId ';
        if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Applicable_Taxes__c> applicableTaxes = Database.query(query);
        return applicableTaxes;
    }
    
    /**
     * Name: getAllCategories
     * Desc: To get all categories
     * @param:  
     * @return: List of All categorie records
    **/
    public static List<Sobject> getAllCategories() {
        String query;
        query = 'SELECT Id, Name, Type__c From Category__c';
        if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Category__c> categories = Database.query(query);
        return categories;
    }
    
    /**
     * Name: addApplicableTax
     * Desc: To Add applicable tax if selected checkbox on UI is true
     * @param: salesTaxId - Sales Tax record Id in String Format
     *         salesTaxItemId - Sales Tax Item record Id in String Format 
     * @return: 
    **/ 
    public static void addApplicableTax(String salesTaxId, String salesTaxItemId) {
        salesTaxId = BPUtility.escapeSingleQuotes(salesTaxId);
        salesTaxItemId = BPUtility.escapeSingleQuotes(salesTaxItemId);
        removeApplicableTax(salesTaxId, salesTaxItemId);
        Applicable_Taxes__c applicableTaxToInsert = new Applicable_Taxes__c(Sales_Tax__c = Id.valueOf(salesTaxId), Sales_Tax_Item__c = Id.valueOf(salesTaxItemId));     
        if(AccessControl.ifObjectFieldIsCreateable('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        insert applicableTaxToInsert;
    }
    
    /**
     * Name: removeApplicableTax
     * Desc: To remove applicable tax if selected checkbox on UI is false
     * @param: salesTaxId - Sales Tax record Id in String Format
     *         salesTaxItemId - Sales Tax Item record Id in String Format 
     * @return: 
    **/ 
    public static void removeApplicableTax(String salesTaxId, String salesTaxItemId) {
        try {
            salesTaxId = BPUtility.escapeSingleQuotes(salesTaxId);
            salesTaxItemId = BPUtility.escapeSingleQuotes(salesTaxItemId);
            String query;
            query = 'SELECT Id From Applicable_Taxes__c where Sales_Tax__c = : SalesTaxId AND Sales_Tax_Item__c = : salesTaxItemId';
            if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            Applicable_Taxes__c applicableTaxToDel = Database.query(query);
            if(applicableTaxToDel != null) {
                if(AccessControl.ifObjectIsDeletable('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
                delete applicableTaxToDel;
            }
        } catch (Exception e) {

        }
    }
    
    /**
     * Name: deleteSalesTax
     * Desc: Method delete the Sales Tax with Id value
     * @param: stId - Id - Sales Tax Record Id
     * @return: If successful 
    **/
    public static boolean deleteSalesTax(Id stId) {
        Sales_Tax__c stToDel = new Sales_Tax__c(Id = stId);
        if(AccessControl.ifObjectIsDeletable('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        delete stToDel;
        return true;
    }
    
    /**
     * Name: deleteSalesTaxItem
     * Desc: Method deletes the Sales Tax Item with Id value
     * @param: stiId - Id - Sales Tax Item Id
     * @return: If successfull
    **/
    public static boolean deleteSalesTaxItem(Id stiId) {
        Sales_Tax_Item__c stiToDel = new Sales_Tax_Item__c(Id = stiId);
        if(AccessControl.ifObjectIsDeletable('Sales_Tax_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        delete stiToDel;
        return true;
    }
    
    /**
     * Name: deletePriceLevel
     * Desc: Method deletes the Price Level record with Id value
     * @param: plId - Price Level Id
     * @return: If successfull
    **/
    public static boolean deletePriceLevel(Id plId) {
        Price_Level__c plToDel = new Price_Level__c(Id = plId);
        if(AccessControl.ifObjectIsDeletable('Price_Level__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        delete plToDel;
        return true;
    }
    
    /** 
     * Name: checkUserProfile
     * Desc: checks if user is system admin
     * @param:  
     * @return: boolean, if true current user is system admin
    **/
    public static boolean checkUserProfile() {
        if(AccessControl.ifObjectFieldIsAccessible('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Boolean isSystemAdmin = false;
        User currentUser = [select Profile.Name from User WHERE Id = :UserInfo.getUserId()];
        if(currentUser.Profile.Name == 'Black Purl Administrator' || currentUser.Profile.Name == 'System Administrator') {
            isSystemAdmin = true;
        }
        return isSystemAdmin;
    }
    
    /** 
     * Name: checkUserToAccessOnObject
     * Desc: checks if user has access to given object or not
     * @param: (1) sobjectToCheckAccess - String - sobject Name that has to be checked
     * @return: boolean, if true current user has access to object
    **/
    public static boolean checkUserToAccessOnObject(String sobjectToCheckAccess) {
        sobjectToCheckAccess = BPUtility.escapeSingleQuotes(sobjectToCheckAccess);
        Boolean hasAccess = false;
        Schema.DescribeSObjectResult sobject_describe = Schema.getGlobalDescribe().get(sobjectToCheckAccess).newSObject().getSObjectType().getDescribe();
            system.debug('UpdateAble' + sobject_describe.isUpdateable() + '\n\nAccessible' + sobject_describe.isAccessible());
        if(sobject_describe.isUpdateable() && sobject_describe.isAccessible()) { 
            hasAccess = true;
        }
        return hasAccess;
    }   

    
    /** 
     * Name: getObjectIdByItsName
     * Desc: Method to Get Record Id by its name
     * @param:  (1) recordName - String - Record name which id is to be found
                (2) ObjectName - String - Object Name
     * @return: Sting - Id of given record
    **/
    public static String getObjectIdByItsName(String recordName, String ObjectName) {
        recordName = BPUtility.escapeSingleQuotes(recordName);
        ObjectName = BPUtility.escapeSingleQuotes(ObjectName);
        String query;
        String recordId;
        if(recordName != null) {
            recordName = recordName.trim();
        }

        System.debug('IN SOQL UTIL \n' + recordName);
        query = 'SELECT Id, Name FROM ' + ObjectName + ' WHERE Name = : recordName';
        if(AccessControl.ifObjectFieldIsAccessible(ObjectName) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Sobject> recordList = Database.query(query);
        if(recordList.size() > 0) {
            recordId = String.valueOf(recordList[0].Id);
        } 
        return recordId;
    }
    
    /** 
     * Name: getCustomerPageSize
     * Desc: Method to Get customer page size that is used by user
     * @param: 
     * @return: List<Sobject> - page size object record for particular object
    **/
    public static List<Sobject> getCustomerPageSize() {
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Page_Size__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Customer_Page_Size__c> customerPageSizeList = [select User__c, Drop_Down_Number__c from Customer_Page_Size__c where User__c = :UserInfo.getUserId()];
        return customerPageSizeList;
    }
    
    /** 
     * Name: getFilterRecords
     * Desc: Method to Get all filter object records
     * @param: 
     * @return: List<Sobject> - List of filter object records
    **/
    public static List<Sobject> getFilterRecords() {
        if(AccessControl.ifObjectFieldIsAccessible('Filter__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Filter__c> filterRecordList = [select Filter_Label__c, 
                                                    Custom__c, 
                                                    Filter_JSON__c, 
                                                    Last_Modified_Date_Filter__c 
                                                    from Filter__c 
                                                    Where Filter_User__c =: UserInfo.getUserId()
                                                    order by Filter_Label__c 
                                                    limit :getAvailableQueryRowsLimit()];
        return filterRecordList;
    }
    
    /** 
     * Name: getFieldFilterRecords
     * Desc: Method to Get filter record by filter record Id
     * @param: (1) filterRecId - String - Filter Record Id which record is to be found
     * @return: List<Sobject> - List of filter object's record 
    **/
    public static List<Sobject> getFieldFilterRecords(String filterRecId) {
        filterRecId = BPUtility.escapeSingleQuotes(filterRecId);
        if(AccessControl.ifObjectFieldIsAccessible('Filter__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Filter__c> filterRecordJSON = [select Filter_Label__c, Custom__c, Filter_JSON__c, Last_Modified_Date_Filter__c from Filter__c Where Id =:filterRecId order by Filter_Label__c];
        return filterRecordJSON;
    }
    
    /**
     * Name: getRecordById
     * Desc: To get  record by Id
     * @param: (1) sobjectRecordIds - List<String> - List Of Record id String
     *         (2) objectFieldsToJsonMap - Map<String, String> - Map Object Field To JSON String 
     *         (3) objectName - String - Object Name
     * @return: List<Sobject> 
    **/
    public static List<Sobject> getRecordById(List<String> sobjectRecordIds, Map<String, String> objectFieldsToJsonMap, String objectName) {
        objectName = BPUtility.escapeSingleQuotes(objectName);
        String query;
        if(sobjectRecordIds.size() == 0) {
          return new List<Sobject>();
        }
        
        query = 'SELECT '; 
        for(String fieldsName : objectFieldsToJsonMap.keyset()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + objectName ;
        if(sobjectRecordIds.size() > 0) {
            query += ' WHERE ID IN : sobjectRecordIds';
        }
        //system.assert(false, query);
        if(AccessControl.ifObjectFieldIsAccessible(objectName) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Sobject> sobjectRecords = Database.query(query);
        return sobjectRecords;
    }
    
    /**
     * Name: updateCOHeader
     * Desc: Update Customer Order Header Record
     * @param:  (1) COHeaderId - String - Customer Order Header Id
                (2) customeId - String - Customer Id 
     * @return: 
    **/
    public static void updateCOHeader(String COHeaderId, String customerId) {
        COHeaderId = BPUtility.escapeSingleQuotes(COHeaderId);
        customerId = BPUtility.escapeSingleQuotes(customerId);
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        String query;
        query = 'SELECT '; 
        for(String fieldName : COHeader.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Header__c ';
        if(COHeaderId != null) {
            query += 'WHERE ID = \'' + COHeaderId + '\'';
        } 
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> coHeadersList = Database.query(query);
        
        if(coHeadersList.size() > 0) {
          coHeadersList[0].Customer__c = customerId;
          update coHeadersList;
        }
    }
    
    /**
     * Name: getCOLineItemByCOHeaderId
     * Desc: To get customer Order Line item By Customer Order Header Id
     * @param: (1) coHeaderId - Id - Customer Order Header Id
     * @return: List<Sobject> - Customer Order Line Item  records
    **/
    public static List<Sobject> getCOLineItemByCOHeaderId(Id coHeaderId) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : COLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        
        // Child Query
        query += '(SELECT ';
        for(String fieldsName : COLineItem.individualTaxFieldsList()){
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Individual_Taxes__r )';
        
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Line_Item__c ';
        if(coHeaderId != null) {
            query += 'WHERE CO_Header__c = :coHeaderId AND Service_Order_Line_Item__c = null AND Deal__c = null ORDER BY Name, CreatedDate';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Line_Item__c> coLineItems = Database.query(query);
        return coLineItems;
    }
    
    /**
     * Name: getCOKHByCOHeaderId
     * Desc: To get Customer Order Kit Header by Header Id
     * @param: (1) coHeaderId - Id - Customer Order Header Id 
     * @return: List<Sobject> - Customer Order Kit Header records
    **/ 
    public static List<Sobject> getCOKHByCOHeaderId(Id coHeaderId) { 
        String query;    
        query = 'SELECT ';  
        for(String fieldsName : COHeaderWrapper.getCOKHFieldsList()) {
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
         
        // Child Query
        query += '(SELECT ';
        for(String fieldsName : COLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Line_Items__r Order by Name, CreatedDate)';
        
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Kit_Header__c ';
        if(coHeaderId != null) {
            query += 'WHERE CO_Header__c = :coHeaderId AND Deal__c = null ORDER BY CreatedDate';
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Kit_Header__c> coKitHeaders = Database.query(query);
        return coKitHeaders;
    }
    
    /**
     * Name: getSpecialOrderByCOHeaderId
     * Desc: To Special Order By Customer Order Header Id
     * @param: (1) coHeaderId - Id - Customer Order Header Id 
     * @return: List<Sobject> - Customer Order Line Item  records
    **/
    public static List<Sobject> getSpecialOrderByCOHeaderId(Id coHeaderId) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : VendorOrderLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Item__c ';
        if(coHeaderId != null) {
            query += 'WHERE CO_Header__c = :coHeaderId AND (Is_required_For_Customer__c = true OR Is_Service__c = true) ORDER BY CreatedDate';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item__c> specialOrdersList = Database.query(query);
        return specialOrdersList;
    }
    
    /**
     * Name: getCOHeaderDetails
     * Desc: To get customer order header details
     * @param: (1) coHeaderId - Id - Customer Id 
     * @return: List<Sobject> - customer order header records
    **/
    public static List<Sobject> getCOHeaderDetails(Id coHeaderId) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : COHeader.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Header__c ';
        if(coHeaderId != null) {
            query += 'WHERE ID = :coHeaderId';
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> coHeaderRec = Database.query(query);
        return coHeaderRec;
    }
    
    /**
     * Name: getCurrentUserInfo
     * Desc: To get current user info
     * @param: 
     * @return: List<Sobject> - user record
    **/
    public static List<Sobject> getCurrentUserInfo() {
        String query;   
        query = 'SELECT LocaleSidKey, SO_Pinned_Info__c From User WHERE Id = \'' + UserInfo.getUserId() + '\''; 
        if(AccessControl.ifObjectFieldIsAccessible('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<User> userRec = Database.query(query);
        return userRec;
    }
    
    /**
     * Name: getCODepositByCOHeaderId
     * Desc: To get customer order deposit By customer order header id 
     * @param: (1) coHeaderId - Id - Customer Order Header Id 
     * @return: List<Sobject> - customer order deposit records
    **/
    public static List<Sobject> getCODepositByCOHeaderId(Id coHeaderId) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : CODeposit.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Deposit__c ';
        if(coHeaderId != null) {
            query += 'WHERE CO_Header__c = :coHeaderId ';
        }
        query += ' ORDER BY  CreatedDate ASC';//Desc by kajal #1587 02/24/2017
        if(AccessControl.ifObjectFieldIsAccessible('CO_Deposit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Deposit__c> coDeposits = Database.query(query);
        return coDeposits;
    }
    
    /**
     * Name: getCOInvoiceHeaderByCOHeaderId
     * Desc: To get customer order Invoice Header record by Header Id
     * @param: (1) coHeaderId - String - CO Header Id 
     * @return: List<Sobject> - CO Invoice Headers records
    **/
    public static List<Sobject> getCOInvoiceHeaderByCOHeaderId(Id coHeaderId) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : COInvoiceHeader.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Invoice_Header__c ';
        if(coHeaderId != null) {
            query += 'WHERE CO_Header__c = :coHeaderId AND Invoice_Status__c = \'Active\'';
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Header__c> coInvoiceHeaders = Database.query(query);
        return coInvoiceHeaders;
    }
    
    /**
     * Name: getCOInvoiceHeaderRecord
     * Desc: To get Customer Order Invoice Header  record by Customer Order Invoice Header Id
     * @param: (1) coInvoiceHeaderId - Id - CO Invoice Header Id 
     * @return: List<Sobject> - CO Invoice Headers record
    **/
    public static Sobject getCOInvoiceHeaderRecord(Id coInvoiceHeaderId) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : COInvoiceHeader.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Invoice_Header__c ';
        if(coInvoiceHeaderId != null) {
            query += 'WHERE Id = :coInvoiceHeaderId';
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Header__c> coInvoiceHeaderList = Database.query(query);
        CO_Invoice_Header__c coInvoiceHeaderRec;
        if(coInvoiceHeaderList.size() > 0) {
            coInvoiceHeaderRec = coInvoiceHeaderList[0];
        } else {
            coInvoiceHeaderRec = new CO_Invoice_Header__c();
        }

        return coInvoiceHeaderRec;
    }
    
    /**
     * Name: getCOInvoiceItemsByCOInvoiceHeaderId
     * Desc: To get customer order invoice item  record by customer order invoice header id
     * @param: (1) coInvoiceHeaderId - Id - CO Invoice Header Id 
     * @return: List<Sobject> - CO Invoice Headers record
    **/
    public static List<Sobject> getCOInvoiceItemsByCOInvoiceHeaderId(Id coInvoiceHeaderId) {
        //system.assert(false,coInvoiceHeaderId);
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : COInvoiceItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Invoice_Item__c ';
        if(coInvoiceHeaderId != null) {
            query += 'WHERE CO_Invoice_Header__c = :coInvoiceHeaderId ORDER BY CreatedDate ASC';
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Item__c> coInvoiceItems = Database.query(query);
        return coInvoiceItems;
    }
    
    /**
     * Name: getCOInvoicePaymentsByCOInvoiceHeaderId
     * Desc: To get co invoice payments record by CO Invoice Header Id
     * @param: (1) coInvoiceHeaderId - String - CO Invoice Header Id 
     * @return: List<Sobject> - CO Invoice Payments record
    **/
    public static List<Sobject> getCOInvoicePaymentsByCOInvoiceHeaderId(Id coInvoiceHeaderId) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : COInvoicePayment.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Invoice_Payment__c ';
        if(coInvoiceHeaderId != null) {
            query += 'WHERE CO_Invoice_Header__c = :coInvoiceHeaderId ORDER BY CreatedDate ASC';//DESC ==> ASC by kajal 03/03/2017 #1590
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Payment__c> coInvoiceItems = Database.query(query);
        return coInvoiceItems;
    }
    
    /**
     * Name: getInvoiceHistory
     * Desc: To get Invoice History
     * @param: (1) coHeaderId - String - CO Header Id 
     * @return: List<Sobject> - CO Invoice Headers record
    **/
    public static List<Sobject> getInvoiceHistory(Id coHeaderId) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : InvoiceHistory.coInvoiceHeaderFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        
        // child query
        query += '( SELECT ';
        for(String fieldsName : InvoiceHistory.coInvoiceItemsFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Invoice_Items__r )';
        
        // child query
        query += ',( SELECT ';
        for(String fieldsName : COInvoicePayment.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Invoice_Payments__r )';
        
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Invoice_Header__c ';
        if(coHeaderId != null) {
            query += 'WHERE CO_Header__c = :coHeaderId AND Invoice_Status__c = \'Closed\' ORDER BY CreatedDate DESC';
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Header__c> coInvoiceHeaders = Database.query(query);
        return coInvoiceHeaders;
    }
    
    /**
     * Name: getCustomer
     * Desc: To get customer record by Customer Id
     * @param: (1) customerId - String - Customer Id 
     *         (2) className - String - Customer or CustomerDetails 
     * @return: List<Sobject> - customer record
    **/
    public static List<Sobject> getCustomer(String customerId, String className) {
        customerId = BPUtility.escapeSingleQuotes(customerId);
        className = BPUtility.escapeSingleQuotes(className);
        String query;   
        query = 'SELECT '; 
        if(className == 'Customer' || className == null) {
            for(String fieldName : Customer.fieldsList()){
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                query += fieldName + ', ';
            }
        } else if(className == 'CustomerDetail'){
            //for(String fieldName : CustomerDetail.fieldsList()){
            //    query += fieldName + ', ';
            //}
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Account ';
        if(customerId != null) {
            query += 'WHERE Id = :customerId AND Is_Customer__c = true';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Account> customers = Database.query(query);
        return customers;
    }
    
     public static List<Sobject> getCustomer(String customerId, String className, Boolean isGetRelatedCOUs, String whereConditionOnCOU) {
        customerId = BPUtility.escapeSingleQuotes(customerId);
        className = BPUtility.escapeSingleQuotes(className);
        String query;   
        query = 'SELECT '; 
        if(className == 'Customer' || className == null) {
            for(String fieldName : Customer.fieldsList()){
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                query += fieldName + ', ';
            }
        } else if(className == 'CustomerDetail'){}
        
        if(isGetRelatedCOUs) {
            query += '(SELECT '; 
            for(String fieldName : CustomerOwnedUnit.fieldsList()){
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                query += fieldName + ', ';
            }
            query = query.substring(0, query.length()-2);
            query += ' FROM Customer_Owned_Units__r';
        }
        
        if(!String.isBlank(whereConditionOnCOU)) {
            query += ' WHERE ' + whereConditionOnCOU + ')  ';
        } else {
            query += ')  ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Account ';
        if(customerId != null) {
            query += 'WHERE Id = :customerId AND Is_Customer__c = true';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Account> customers = Database.query(query);
        return customers;
    }
    
    /**
     * Name: geCOUList
     * Desc: Get unit list by customer id
     * @param: (1) customerId - Customer Id  
     * @return: List<Customer_Owned_Units__c> - COU List
    **/
    public static List<Customer_Owned_Unit__c> geCOUList(String customerId, Map<String, String> fieldNameToFieldValueMap) {
        String query = 'SELECT '; 
        for(String fieldName : CustomerOwnedUnit.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Customer_Owned_Unit__c WHERE Account__c =: customerId';
        
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += ' AND ' + fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Customer_Owned_Unit__c> couRecords = Database.query(query);
        return couRecords;
    }
    
    /**
     * Name: getOtherSimilarCustomer
     * Desc: To Related Customer
     * @param: (1) customerRecord - Account - Customer Record  
     * @return: List<Sobject> - customer record
    **/
    public static List<Sobject> getOtherSimilarCustomer(Account customerRecord) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : CustomerSuggestion.fieldsList()){
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Account WHERE Is_Customer__c = true AND Type__c = \'' + customerRecord.Type__c + '\' AND ( ';
        
        Boolean isOrClauseAdded = false;
        for(String fieldValue : Constants.customerFieldToFieldAPINameMap.keyset()) {
            String fieldName = Constants.customerFieldToFieldAPINameMap.get(BPUtility.escapeSingleQuotes(fieldValue));
            if(isOrClauseAdded && customerRecord.get(fieldName) != null) {
                if(customerRecord.get(fieldName) == true || customerRecord.get(fieldName) == false){
                    query += ' OR ' + fieldName + ' = ' + customerRecord.get(fieldName);
                }else{
                    query += ' OR ' + fieldName + ' = \'' + customerRecord.get(fieldName) + '\'';
                }
            } else if(!isOrClauseAdded && customerRecord.get(fieldName) != null && fieldName != 'Is_Vendor__c' && fieldName != 'Is_Customer__c') {
                query += fieldName + ' = \'' + customerRecord.get(fieldName) + '\'';
                isOrClauseAdded = true;
            }
        }
        query += ') ORDER BY CreatedDate DESC';
        query += '';
        //system.assert(false, query);
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Account> customers = Database.query(query);
        return customers;
    }
    
    /**
     * Name: getSimilarCOUs
     * Desc: To get related Customer Owned unit 
     * @param: (1) VINNumber - String - Vehicle Identification Number of COU
     * @return: List<Sobject> - customer owned unit records
    **/
    public static List<Sobject> getSimilarCOUs(String VINNumber) {
        VINNumber = BPUtility.escapeSingleQuotes(VINNumber);
        String query;   
        query = 'SELECT '; 
        for(String fieldName : CustomerOwnedUnit.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Customer_Owned_Unit__c WHERE Status__c != \'Inactive\' AND VIN_Number__c = \'' + VINNumber + '\'';
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Customer_Owned_Unit__c> custOwnedUnits = Database.query(query);
        return custOwnedUnits;
    }
    
    /**
     * Name: getAllCountry
     * Desc: To geting all Country list
     * @param: 
     * @return: List<Sobject> - Country records
    **/
    public static List<Sobject> getAllCountry() {
        String query;
        query = 'SELECT '; 
        for(String fieldsName : Country.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Country__c ';
        query += ' ORDER BY Default__c DESC, Name__c ASC';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('Country__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Country__c> countryList = Database.query(query);
        return countryList;
    }
    
    /**
     * Name: getAllCountryWrapper
     * Desc: To Get All Country With States
     * @param:
     * @return: List<Sobject> - Country records
    **/
    public static List<Sobject> getAllCountryWrapper() {
        String query;
        query = 'SELECT '; 
        for(String fieldsName : Country.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }

        // child query
        query += '( SELECT ';
        for(String fieldsName : State.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM States__r ORDER BY Default__c DESC, Name__c ASC)';
        
        query += ', ( SELECT ';
        for(String fieldsName : Timezone.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Timezones__r ORDER BY Time_Shift__c DESC)';
        
        query += ' FROM Country__c ';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        //system.assert(false, query);
        if(AccessControl.ifObjectFieldIsAccessible('State__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Timezone__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Country__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Country__c> countryWrapperList = Database.query(query);
        return countryWrapperList;
    }
    
    
    /**
     * Name: getPriceLevel
     * Desc: To get all the Price Level records from Database by executing query
     * @param: (1) Price Level Ids List 
     * @return: List of Price Level records
    **/
    public static List<Sobject> getPriceLevel(List<Id> priceLevelIds) {
        String query;
        query = 'SELECT '; 
        for(String fieldsName : Constants.PRICE_LEVEL_FIELDS_TO_JSON_MAPPING.keyset()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Price_Level__c WHERE Active__c = TRUE';
        if(priceLevelIds.size() > 0) {
            query += ' AND ID IN : priceLevelIds'; 
        }
        query += ' order by Default__c DESC, Active__c DESC, Name__c';
        if(AccessControl.ifObjectFieldIsAccessible('Price_Level__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Price_Level__c> priceLevelList = Database.query(query);
        return priceLevelList;
    }
    
    /**
     * Name: getSalesTax
     * Desc: To get all the Sales Tax records from Database by executing query
     * @param: (1) salesTaxIds - List<id> - Sales Tax Ids List 
     * @return: List of Sales Tax records
    **/
    public static List<Sobject> getSalesTax(List<Id> salesTaxIds) {
        String query;
        query = 'SELECT '; 
        for(String fieldsName : Constants.SALES_TAX_FIELDS_TO_JSON_MAPPING.keyset()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Sales_Tax__c WHERE Active__c = true';
        if(salesTaxIds.size() > 0) {
            query += ' AND ID IN : salesTaxIds'; 
        }
        query += ' order by Default__c DESC, Active__c Desc, Name__c';
        if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Sales_Tax__c> salesTaxList = Database.query(query);
        return salesTaxList;
    }
    
    /**
     * Name: getPartCategory
     * Desc: To get all the Category records from Database by executing query
     * @param: (1) categoryIds - List<id> - Category Ids List 
     * @return: List of Category records
    **/
    public static List<Sobject> getPartCategory(List<Id> categoryIds) {
        String query;
        query = 'SELECT '; 
        for(String fieldsName : Category.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Category__c WHERE Type__c = \'Part\' AND Active__c = true';
        if(categoryIds.size() > 0) {
            query += ' AND ID IN : categoryIds'; 
        }
        query += ' order by Name';
        if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Category__c> categoryList = Database.query(query);
        return categoryList;
    }
    
     /**
     * Name: getCategoryById
     * Desc: To get all the category by Type of Categories
     * @param: (1) categoryIds - List<id> - Category Ids List 
     * @return: List of Category records  
    **/
    public static List<Sobject> getCategoryById(String categoryType) {
        categoryType = BPUtility.escapeSingleQuotes(categoryType);
        String query;
        query = 'SELECT '; 
        for(String fieldsName : Category.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Category__c ';
        query += 'WHERE Type__c =\'Internal Expense\' AND Active__c = true';
        query += ' order by Name';
        if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Category__c> categoryList = Database.query(query);
        return categoryList;
    }
    
    /**
     * Name: getUnitMake
     * Desc: To get all the Unit Make records from Database by executing query
     * @param: (1) unitMakeIds - List<id> - Unit Make Ids List 
     * @return: List of Unit Make records
    **/
    public static List<Sobject> getUnitMake(List<Id> unitMakeIds) {
        String query;
        query = 'SELECT '; 
        for(String fieldsName : UnitMake.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Unit_Make__c ';
        if(unitMakeIds.size() > 0) {
            query += 'WHERE ID IN : unitMakeIds'; 
        }
        query += ' order by Name ASC';
        if(AccessControl.ifObjectFieldIsAccessible('Unit_Make__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Unit_Make__c> unitMakeList = Database.query(query);
        return unitMakeList;
    }
    
    /**
     * Name: getUnitMakeWrapper
     * Desc: To get Unit Make with Unit Model record 
     * @param:  
     * @return: List<Sobject> - Unit  Make record
    **/
    public static List<Sobject> getUnitMakeWrapper() {
        String query;
        query = 'SELECT '; 
        for(String fieldsName : UnitMake.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }

        // child query
        query += '( SELECT ';
        for(String fieldsName : UnitModel.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Unit_Models__r where Active__c = true)';
        
        query += ' FROM Unit_Make__c where Active__c = true';
        if(AccessControl.ifObjectFieldIsAccessible('Unit_Make__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Unit_Model__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Unit_Make__c> unitMakeWrapperList = Database.query(query);
        return unitMakeWrapperList;
    }
    /**Ticket #1284 04/11/2016 Subhrant singh
     * Name: getUnitMake
     * Desc: To get Unit Make List
     * @param:  
     * @return: List<Sobject> - Unit  Make records
    **/
    public static List<Sobject> getUnitMake() {
        String query; 
        query = 'SELECT '; 
        for(String fieldsName : UnitMake.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Unit_Make__c where Active__c = true';
        
        if(AccessControl.ifObjectFieldIsAccessible('Unit_Make__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Unit_Make__c> unitMakeList = Database.query(query);
        return unitMakeList;
    } 
    
    /**Ticket #1284 04/11/2016 Subhrant singh
     * Name: getUnitMake
     * Desc: To get Unit Model List 
     * @param:  
     * @return: List<Sobject> - Unit model records
    **/
    public static List<Sobject> getUnitModel(String MakeId) {
        String query; 
        query = 'SELECT '; 
        for(String fieldsName : UnitModel.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Unit_Model__c where Active__c = true and Unit_Make__c = \'' + MakeId + '\'';
        
        if(AccessControl.ifObjectFieldIsAccessible('Unit_Model__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Unit_Model__c> unitModelList = Database.query(query);
       
        return unitModelList;
    } 
    
     /**Ticket #1284 04/11/2016 Subhrant singh
     * Name: getUnitMake
     * Desc: To get Unit Model List 
     * @param:  
     * @return: List<Sobject> - Unit Sub model records
    **/
    public static List<Sobject> getUnitSubModel(String ModelId,String MakeId) {
        String query; 
        query = 'SELECT '; 
        for(String fieldsName : UnitSubModel.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Unit_Sub_Model__c where Active__c = true  and Unit_Model__c = \'' + ModelId + '\'';
        
        if(AccessControl.ifObjectFieldIsAccessible('Unit_Sub_Model__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Unit_Sub_Model__c> unitSubModelList = Database.query(query);
        return unitSubModelList;
    }         
      
    /**
     * Name: getRelatedCustomer
     * Desc: To get customer record by Customer Id
     * @param:  (1) customerId - String - Customer Id 
     *          (2) isParent - Boolean  - Is Parent Record or not
     * @return: List<Sobject> - customer record
    **/
    public static List<Sobject> getRelatedCustomer(String customerId, Boolean isParent) {
        customerId = BPUtility.escapeSingleQuotes(customerId);
        String query = '';
        query += 'SELECT Parent_Customer1__c, Parent_Customer2__c, Relationship__c FROM People__c WHERE ';
        if(isParent) {
            query += ' Parent_Customer1__c';
        } else {
            query += ' Parent_Customer2__c';
        }
        query += ' = \'' + customerId + '\'';
        if(AccessControl.ifObjectFieldIsAccessible('People__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<People__c> relatedCustomerList = Database.query(query);
        return relatedCustomerList;
    }
    
    /**
     * Name: getRelatedAccountRecs
     * Desc: To get  Related customer record by Customer Id
     * @param: (1) accountIdSet - Set<String> - Customer Ids 
     * @return: List<Sobject> - customer record
    **/
    public static List<Sobject> getRelatedAccountRecs(Set<String> accountIdSet) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : RelatedCustomer.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Account WHERE Id IN : accountIdSet';
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Account> relatedAccountRecs = Database.query(query);
        return relatedAccountRecs;
    }
    
    /**
     * Name: getCOUListByCustomerId
     * Desc: To get customer owned unit record by Customer Id
     * @param: (1) customerId - String - Customer Id 
     * @return: List<Sobject> - customer owned unit records
     **/
    public static List<Sobject> getCOUListByCustomerId(String customerId) {
        return getCOUListByFieldName('Account__c', BPUtility.escapeSingleQuotes(customerId));
    }

   /**
     * Name: getCOUListByFieldName
     * Desc: To get customer onwed record 
     * @param: (1) fieldName - String - Field Name 
     *         (2) fieldValue- String - Field Value
     * @return: List<Sobject> - customer owned unit records
    **/
    public static List<Sobject> getCOUListByFieldName(String fieldName, String fieldValue) {
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
        String query;   
        query = 'SELECT '; 
        for(String field : CustomerOwnedUnit.fieldsList()){
            field = BPUtility.escapeSingleQuotes(field);
            query += field + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Customer_Owned_Unit__c WHERE ' + fieldName + ' = \'' + fieldValue + '\' ORDER BY LastModifiedDate DESC';
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Customer_Owned_Unit__c> custOwnedUnits = Database.query(query);
        return custOwnedUnits;
    }
    
    
    /**
     * Name: getCustomerContactByFieldName
     * Desc: To get Contact record by Customer Id
     * @param:  (1) fieldName -  String - Field Name
     *          (2) fieldValue - String - Field Value 
     * @return: List<Sobject> - Contact record
    **/
    public static List<Sobject> getCustomerContactByFieldName(String fieldName, String fieldValue) {
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
        String query;   
        query = 'SELECT '; 
        for(String fieldAPIName : CustomerContact.fieldsList()){
            fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
            query += fieldAPIName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Contact WHERE ' + fieldName + ' = \'' + fieldValue + '\'';
        if(AccessControl.ifObjectFieldIsAccessible('Contact') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Contact> contactList = Database.query(query);
        return contactList;
    }
    
    
    /**
     * Name: getCustomerStoreCreditByFieldName
     * Desc: To get Store Credit record by Customer Id
     * @param:  (1) fieldName -  String - Field Name
     *          (2) fieldValue - String - Field Value 
     * @return: List<Sobject> - Store Credit record
    **/
    public static List<Sobject> getCustomerStoreCreditByFieldName(String fieldName, String fieldValue) {
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
        String query;   
        query = 'SELECT '; 
        for(String fieldAPIName : StoreCredit.fieldsList()){
            fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
            query += fieldAPIName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Store_Credit__c WHERE ' + fieldName + ' = \'' + fieldValue + '\' ORDER BY CreatedDate DESC';
        if(AccessControl.ifObjectFieldIsAccessible('Store_Credit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Store_Credit__c> storeCreditList = Database.query(query);
        return storeCreditList;
    }
    
    /**
     * Name: getLastVisitOrderByCustomerId
     * Desc: To get customer record by Customer Id
     * @param: (1) customerId - String - Customer Id 
     * @return: List<Sobject> - customer record
    **/
    public static List<Sobject> getLastVisitOrderByCustomerId(String customerId) {
        customerId = BPUtility.escapeSingleQuotes(customerId);
        String query;   
        query = 'SELECT CreatedDate, Name From CO_Header__c WHERE Customer__c = \'' + customerId + '\' ORDER BY CreatedDate DESC LIMIT 1'; 
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> coHeaderList = Database.query(query);
        return coHeaderList;
    }
    
    /**
     * Name: getCOURecordByFieldName
     * Desc: To get customer owned unit record 
     * @param:  (1) fieldName -  String - Field Name
     *          (2) fieldValue - String - Field Value 
     * @return: List<Sobject> - customer owned unit records
    **/
    public static List<Sobject> getCOURecordByFieldName(String fieldName, String fieldValue) {
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
        String query;   
        query = 'SELECT '; 
        for(String fieldAPIName : CustomerOwnedUnit.fieldsList()){
            fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
            query += fieldAPIName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ', (Select Id, Total_Price__c, Total_Cost__c from Unit_Prices_Costs__r where Type__c = \'Base\') FROM Customer_Owned_Unit__c WHERE ' + fieldName + ' = \'' + fieldValue + '\'';// 28th april, 2016 #1937
        query += ' ORDER By CreatedDate';
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Customer_Owned_Unit__c> custOwnedUnits = Database.query(query);
        return custOwnedUnits;
    }
    
    /**
     * Name: getReocrdByGivenId
     * Desc: To get Sobject records by Record Id
     * @param: (1) recordId - String - Record Id 
     * @return: List<Sobject> - sobject records
    **/
    public static List<Sobject> getReocrdByGivenId(String recordId) {
        recordId = BPUtility.escapeSingleQuotes(recordId);
        String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(AccessControl.ifObjectFieldIsAccessible(sObjName) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        String query = 'SELECT Id from ' + sObjName + ' WHERE Id = \'' + recordId + '\'';
        List<Sobject> sobjectList = Database.query(query);
        return sobjectList;
    }
    
    /**
     * Name: getPartDetailRecordsByFieldName
     * Desc: To get part  records by Part Field Name
     * @param: (1) fieldName -  String - Field Name
     *         (2) fieldValue - String - Field Value 
     * @return: List<Sobject> - Part records
    **/
    public static List<Sobject> getPartDetailRecordsByFieldName(String fieldName, String fieldValue) {
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
        String query;   
        query = 'SELECT '; 
        for(String fieldAPIName : PartDetail.fieldsList()){
            fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
            query += fieldAPIName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Part__c WHERE ' + fieldName + ' = \'' + fieldValue + '\'';
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Part__c> parts = Database.query(query);
        return parts;
    }
    
    /**
     * Name: getVendorDetailRecord
     * Desc: To get Vendor records by Vendor Field Name
     * @param: (1) fieldName -  String - Field Name
     *         (2) fieldValue - String - Field Value 
     * @return: List<Sobject> - vendor records
    **/
    public static List<Sobject> getVendorDetailRecord(String fieldName, String fieldValue) {
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
        String query;   
        query = 'SELECT '; 
        for(String fieldAPIName : Vendor.fieldsList()){
            fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
            query += fieldAPIName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Account WHERE Is_Vendor__c = true AND '+ fieldName +' = \'' + fieldValue + '\'';
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Account> vendors = Database.query(query);
        return vendors;
    }
    
    /**
     * Name: getVendorOrderHeaderRecord
     * Desc: To get Vendor Order header record
     * @param:      (1) fieldName -  String - Field Name
     *              (2) fieldValue - String - Field Value 
     *              (3) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)
     *              (4) isOnOrder - Boolean  - Order Status
     * @return: List<Sobject> - vendor order header records
    **/
    public static List<Sobject> getVendorOrderHeaderRecords(String fieldName, String fieldValue, Map<String, String> sortFieldMap, Boolean isOnOrder) { 
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
        String query;   
        query = 'SELECT '; 
        for(String fieldAPIName : VendorOrderHeader.fieldsList()){
            fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
            query += fieldAPIName + ', ';
        }
        query = query.substring(0, query.length()-2);
        
        // If field name is 'Vendor__c', then include child records for VOLIGroups also
        if(fieldName == 'Vendor__c'){
            query += ', (SELECT '; 
            for(String fieldAPIName : VendorOrderLineItemGroup.fieldsList()){
                fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
                query += fieldAPIName + ', ';
            }
            query = query.substring(0, query.length()-2);
            query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Item_Groups__r Where Status__c != \'Cancelled\') ';
            
            query += ', (SELECT Vendor_Receiving_Header__c, Vendor_Receiving_Header__r.Name ';
            query += ' FROM ' + Constants.NAMESPACE + 'In_Progress_VRs__r Where Vendor_Receiving_Header__r.Status__c = \'In Progress\') ';
        }
        
        query += ' FROM Vendor_Order_Header__c WHERE '+ fieldName +' = \'' + fieldValue + '\'';
        
        if(isOnOrder) {
            query += ' AND ( Status__c = \'On Order\' OR Status__c = \'Partially Received\') ';
        }
        // Order by clause
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            query += ' ORDER BY ';
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length() - 2);
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('In_Progress_VR__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Vendor_Order_Header__c> voHeaders = Database.query(query);
        return voHeaders;
    }
    
    public static List<Vendor_Order_Header__c> getVendorOrderHeaderRecords(String fieldName, Set<Id> fieldValueSet, Map<String, String> sortFieldMap, Boolean isOnOrder) { 
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        String query;   
        query = 'SELECT '; 
        for(String fieldAPIName : VendorOrderHeader.fieldsList()){
            fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
            query += fieldAPIName + ', ';
        }
        query = query.substring(0, query.length()-2);
        
        // If field name is 'Vendor__c', then include child records for VOLIGroups also
        if(fieldName == 'Vendor__c'){
            query += ', (SELECT '; 
            for(String fieldAPIName : VendorOrderLineItemGroup.fieldsList()){
                fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
                query += fieldAPIName + ', ';
            }
            query = query.substring(0, query.length()-2);
            query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Item_Groups__r Where Status__c != \'Cancelled\') ';
            
            query += ', (SELECT Vendor_Receiving_Header__c, Vendor_Receiving_Header__r.Name ';
            query += ' FROM ' + Constants.NAMESPACE + 'In_Progress_VRs__r Where Vendor_Receiving_Header__r.Status__c = \'In Progress\') ';
        }
        
        query += ' FROM Vendor_Order_Header__c WHERE '+ fieldName +' IN : fieldValueSet ';
        
        if(isOnOrder) {
            query += ' AND ( Status__c = \'On Order\' OR Status__c = \'Partially Received\') ';
        }
        // Order by clause
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            query += ' ORDER BY ';
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length() - 2);
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('In_Progress_VR__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Vendor_Order_Header__c> voHeaders = Database.query(query);
        return voHeaders;
    }
    
    /**
     * Name: getOtherSimilarVendor
     * Desc: To get Similar Vendor records by Vendor Record
     * @param: (1) vendorRecord - Account - Vendor  Id 
     * @return: List<Sobject> - Vendor records
    **/
    public static List<Sobject> getOtherSimilarVendor(Account vendorRecord) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : VendorSuggestion.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Account WHERE Is_Vendor__c = true ';
        
        Boolean isOrClauseAdded = false;
        for(String fieldValue : Constants.vendorFieldToFieldAPINameMap.keyset()) {
            String fieldName = Constants.vendorFieldToFieldAPINameMap.get(BPUtility.escapeSingleQuotes(fieldValue));
            if(vendorRecord.get(fieldName) != null) {
                if(fieldName == 'Name' || fieldName == 'BillingStreet') {
                    if(isOrClauseAdded) {
                        query += ' OR ' + fieldName + ' LIKE \'' + vendorRecord.get(fieldName) + '%\'';
                    } else if(!isOrClauseAdded) {
                        query += ' AND ( ' + fieldName + ' LIKE \'' + vendorRecord.get(fieldName) + '%\'';
                        isOrClauseAdded = true;
                    }
                } 
            }
        }
        if(isOrClauseAdded) {
            query += ') ';
        }
        query += ' ORDER BY CreatedDate DESC LIMIT 1000';
        query += '';
        //system.assert(false, query);
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Account> vendors = Database.query(query);
        //system.assert(false, query + '\n\n' + vendors);
        return vendors;
    }
    
    /**
     * Name: getVOLineItem
     * Desc: To get Vendor Order Line Item records 
     * @param:  (1) vendorId - String - Vendor Id 
     *          (2) voHeaderId - String - Vendor Order Header Id
     *          (3) isRequiredForCustomer - Boolean - is Required For Customer or not
     * @return: List<Sobject> - Vendor Order Line Item records
    **/
    public static List<Sobject> getVOLineItem(String vendorId, String voHeaderId, Boolean isRequiredForCustomer) {
        vendorId = BPUtility.escapeSingleQuotes(vendorId);
        voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
        //List<Id> lockedLineItemsIds = getLineItemIdsListForLockedVOHeader(voHeaderId);
        
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : VendorOrderLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Item__c ';
        if(vendorId != null) {
            query += 'WHERE (Part__r.Vendor__c = :vendorId OR Sublet__r.Vendor__c = :vendorId)AND Vendor_Order_Header__c = null';
            
            if(isRequiredForCustomer != null){
                if(isRequiredForCustomer) {
                    query += ' AND (Is_required_For_Customer__c = ' + isRequiredForCustomer + ' OR Is_Service__c = true )';
                } else {
                    query += ' AND Is_required_For_Customer__c = ' + isRequiredForCustomer + ' AND Is_Service__c = false ';
                }
            }
            
            query += ' AND Is_From_Search__c = false ';
            
            /*if(lockedLineItemsIds.size() > 0) {
                query += 'AND Id IN: lockedLineItemsIds';
            }*/
            query += ' ORDER BY LastModifiedDate Desc';
        } else {
            return new List<Vendor_Order_Line_Item__c>();
        }
        //system.assert(false, query);
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item__c> voLineItems = Database.query(query);
        //system.assert(false, voLineItems);
        return voLineItems;
    }
    
    /**
     * Name: getVOLineItemWithSimilarParts
     * Desc: To get Vendor Order Line Item  records With Similar Parts
     * @param:  (1) vendorId - String - Vendor Id 
     *          (2) partId - String - Part Id 
     *          (3) voHeaderId - String - Vendor Order Header Id
     * @return: List<Sobject> - Vendor Order Line Item  record
    **/
    public static List<Sobject> getVOLineItemWithSimilarParts(String vendorId, String partId, String voHeaderId) {
        vendorId = BPUtility.escapeSingleQuotes(vendorId);
        partId = BPUtility.escapeSingleQuotes(partId);
        voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : VendorOrderLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Item__c ';
        if(vendorId != null) {
            query += 'WHERE Part__r.Vendor__c = :vendorId AND Part__c = :partId AND ( Vendor_Order_Header__c = null OR Vendor_Order_Header__c = :voHeaderId ) ORDER BY CreatedDate';
        }
        //system.assert(false, query);
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item__c> voLineItems = Database.query(query);
        //system.assert(false, voLineItems);
        return voLineItems;
    }
    
    /**
     * Name: getVOLineItemByFieldValue
     * Desc: To get Vendor Order Line Item  records 
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Map of Field Name to Field Value
     * @return: List<Sobject> - Vendor Order Line Item  records
    **/
    public static List<Sobject> getVOLineItemByFieldValue(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : VendorOrderLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Item__c ';
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
                    isWhereClauseAdded = true;
                } else {
                    if(fieldNameToFieldValueMap.get(fieldName) != null){
                        query += 'AND '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
                    } else {
                        query += 'AND '+ fieldName + ' = null';
                    }
                }
            }
        }
        query += ' ORDER BY CreatedDate';
        system.debug(query);
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item__c> voLineItems = Database.query(query);
        return voLineItems;
    }
    
    /**
     * Name: getVOLineItemByFieldValue
     * Desc: To get Vendor Order Line Item  records
     * @param:  (1) fieldNameToFieldValueMap - Map<String, String> - Map of Field Name to Field Value
     * @return: List<Sobject> - Vendor Order Line Item  records
    **/
    public static List<Sobject> getVOLineItemByFieldValue(Map<String, List<String>> fieldNameToFieldValuesMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : VendorOrderLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Item__c ';
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValuesMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValuesMap.keySet()) {
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                
                String fieldValueStr = '(';
                for(String fieldValue : fieldNameToFieldValuesMap.get(fieldName)){
                    if(fieldValue != null){
                        fieldValueStr += '\'' + fieldValue + '\'' + ',';
                    }
                }
                fieldValueStr = fieldValueStr.subString(0, fieldValueStr.length() - 1);
                if(fieldValueStr.length() > 1) {
                    fieldValueStr += ')';
                }
                
                if(fieldValueStr.length() > 2){
                    if(!isWhereClauseAdded) {
                        query += 'WHERE ' + fieldName + ' IN ' + fieldValueStr;
                        isWhereClauseAdded = true;
                    } else {
                        query += ' AND '+ fieldName + ' IN ' + fieldValueStr;
                    }
                }
                
                if(fieldValueStr.length() == 0 && fieldName == 'Id'){
                    if(!isWhereClauseAdded) {
                        query += 'WHERE Id = null ';
                        isWhereClauseAdded = true;
                    } else {
                        query += ' AND Id = null ';
                    }
                }
            }
        }
        query += ' ORDER BY CreatedDate';
        //system.debug(query);
        //system.assert(false, query);
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item__c> voLineItems = Database.query(query);
        return voLineItems;
    }
    
    /**
     * Name: getVOLineItemsForGivenPartAndVendorReceiving 
     * Desc: To get  Vendor Order Line Item  records by Vendor Receiving Header Id and Part Id
     * @param:  (1) partId - String - Part Id 
     *          (3) vrHeaderId - String - Vendor Receiving Header Id
     * @return: List<Sobject> -  Vendor Order Line Item  records
    **/
    public static List<Sobject> getVOLineItemsForGivenPartAndVendorReceiving(String partId, String vrHeaderId) {
        partId = BPUtility.escapeSingleQuotes(partId);
        vrHeaderId = BPUtility.escapeSingleQuotes(vrHeaderId);
        if(AccessControl.ifObjectFieldIsAccessible('In_Progress_VR__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<In_Progress_VR__c> inProgressVRList = [select Vendor_Order_Header__c from In_Progress_VR__c Where Vendor_Receiving_Header__c =: vrHeaderId];
        List<String> voHeaderIdList = new List<String>();
        for(In_Progress_VR__c inProgreeVIRec : inProgressVRList) {
            voHeaderIdList.add(inProgreeVIRec.Vendor_Order_Header__c);
        }
        
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : VendorOrderLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Item__c ';
        
        query += 'WHERE Vendor_Order_Header__c IN :voHeaderIdList AND '; 
        
        if(partId != null) {
            query += 'Part__c = :partId AND ';
        }
        
        query += ' Vendor_Receiving_Group__c = null ';
        query += ' ORDER BY CreatedDate';
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        //system.debug('@@@@' + query);
        List<Vendor_Order_Line_Item__c> voLineItems = Database.query(query);
        //system.assert(false, voLineItems);
        return voLineItems;
    }
    
    /**
     * Name: getVOLineItemById
     * Desc: To getVendor Order Line Item  records by Id
     * @param: (1) voliId - String - Vendor Order Line Item  Id 
     * @return: List<Sobject> -Vendor Order Line Item  records
    **/
    public static List<Sobject> getVOLineItemById(String voliId) {
        voliId = BPUtility.escapeSingleQuotes(voliId);
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : VendorOrderLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Item__c ';
        if(voliId != null) {
            query += 'WHERE Id = :voliId';
        }
        //system.assert(false, query);
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item__c> voLineItems = Database.query(query);
        //system.assert(false, voLineItems);
        return voLineItems;
    }
    
    /**
     * Name: getVOLIGroupByFieldName
     * Desc: To get Vendor Order Line Item  Group Records By Field Name
     * @param: (1) fieldName -  String - Field Name
     *         (2) fieldValue - String - Field Value 
     *         (3) voHeaderId - String  - Vendor Order Header Id
     * @return: List<Sobject> - Vendor Order Line Item  Group records
    **/
    public static List<Sobject> getVOLIGroupByFieldName(String fieldName, String fieldValue, String voHeaderId) {
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
        voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
        return getVOLIGroupsWithItems(fieldName, fieldValue, new List<String>{voHeaderId});
    }
    
    /**
     * Name: getVOLIGroupsWithItems
     * Desc: To get get Vendor Order Line Item  Group Records With Items
     * @param: (1) fieldName -  String - Field Name
     *         (2) fieldValue - String - Field Value 
     *         (3) voHeaderIds - List<String>  - Vendor Order Header Ids
     * @return: List<Sobject> - get Vendor Order Line Item  Group Records
    **/
    public static List<Sobject> getVOLIGroupsWithItems(String fieldName, String fieldValue, List<String> voHeaderIds) {
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : VendorOrderLineItemGroup.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        
        // Child query
        query += '( SELECT ';
        for(String fieldsName : VendorOrderLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Items__r Where Vendor_Receiving_Group__c = null) ';
        
        // Child query
        query += ', ( SELECT ';
        for(String fieldsName : VendorOrderLineItem.cancelledVOLIfieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Cancelled_VOLIs__r) ';
                
        
        
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Item_Group__c ';
        
        query += 'WHERE Vendor_Order_Header__c IN: voHeaderIds';
        if(fieldValue != null) {
            query += ' AND ' + fieldName + ' = :fieldValue ORDER BY LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item_Group__c> voLineItemGroups = Database.query(query);
        return voLineItemGroups;
    }
    
    /**
     * Name: getVOLIGroupsWithItemsInVO
     * Desc: To get get Vendor Order Line Item  Group Records With Items in Vendor Order
     * @param: (1) fieldName -  String - Field Name
     *         (2) fieldValue - String - Field Value 
     *         (3) voHeaderId - String  - Vendor Order Header Id
     * @return: List<Sobject> - To  get Vendor Order Line Item  Group Records With Items
    **/
    public static List<Sobject> getVOLIGroupsWithItemsInVO(String fieldName, String fieldValue, String voHeaderId) {
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
        voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : VendorOrderLineItemGroup.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        
        // Child query
        query += '( SELECT ';
        for(String fieldsName : VendorOrderLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Items__r) ';
        
        // Child query
        query += ' ,( SELECT ';
        for(String fieldsName : VendorOrderLineItem.cancelledVOLIfieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }  
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Cancelled_VOLIs__r) ';
        
        
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Item_Group__c ';
        
        query += 'WHERE Vendor_Order_Header__c = :voHeaderId';
        if(fieldValue != null) {
            query += ' AND ' + fieldName + ' = :fieldValue ORDER BY LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item_Group__c> voLineItemGroups = Database.query(query);
        return voLineItemGroups;
    }
    
    /**
     * Name: getVOLIGroups
     * Desc: To get  To  get Vendor Order Line Item  Group Records 
     * @param: (1) fieldName -  String - Field Name
     *         (2) fieldValue - String - Field Value 
     *         (3) voHeaderIds - List<String>  - Vendor Order Header Ids
     * @return: List<Sobject> -  To  get Vendor Order Line Item  Group Records 
    **/
    public static List<Sobject> getVOLIGroups(String fieldName, String fieldValue, List<String> voHeaderIds) {
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : VendorOrderLineItemGroup.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Item_Group__c ';
        query += 'WHERE Vendor_Order_Header__c IN: voHeaderIds';
        if(fieldValue != null) {
            query += ' AND ' + fieldName + ' = :fieldValue ORDER BY LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item_Group__c> voLineItemGroups = Database.query(query);
        return voLineItemGroups;
    }
    
    /*public static List<Id> getLineItemIdsListForLockedVOHeader(String voHeader){
        voHeader = BPUtility.escapeSingleQuotes(voHeader);
        if(AccessControl.ifObjectFieldIsAccessible('VO_Locked_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<VO_Locked_Line_Item__c> voLockedItemsList = [Select Id, Locked_Line_Item_Id__c from VO_Locked_Line_Item__c where Vendor_Order_Header__c =: voHeader];
        List<Id> voLineItemsIdsList = new List<Id>();
        
        if(voLockedItemsList.size() > 0){
            for(VO_Locked_Line_Item__c lockecdItem : voLockedItemsList){
                voLineItemsIdsList.add(lockecdItem.Locked_Line_Item_Id__c);
            }
        }
        return voLineItemsIdsList;
    }*/
    
    /**
     * Name: getVORDetails
     * Desc: To get Vendor Order Receiving record
     * @param: (1) fieldName -  String - Field Name
     *         (2) fieldValue - String - Field Value 
     * @return: List<Sobject> - Vendor Order Receiving records
    **/
    public static List<Sobject> getVORDetails(String fieldName, String fieldValue) {
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : VORHeader.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Receiving_Header__c ';
        query += ' WHERE '+ fieldName +' = \'' + fieldValue + '\'';
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Receiving_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Receiving_Header__c> vorRecords = Database.query(query);
        return vorRecords;
    }
    
    /**
     * Name: getVORGroupsWithItems
     * Desc: To get Venor Order Receiving Group records With Items
     * @param: (1) fieldName -  String - Field Name
     *         (2) fieldValue - String - Field Value 
     * @return: Venor Order Receiving Group records 
    **/
    public static List<Sobject> getVORGroupsWithItems(String fieldName, String fieldValue) {
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        fieldValue = BPUtility.escapeSingleQuotes(fieldValue);
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : VORGroup.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        
        // Child query
        query += '( SELECT ';
        for(String fieldsName : VendorOrderLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Items__r ), ';
        
        
        // 2 Child query
        query += '( SELECT ';
        for(String fieldsName : VendorOrderLineItem.stockExcessFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Receiving_Stock_Excesses__r ) ';
        
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Receiving_Group__c ';
        
        if(fieldName != null) {
            query += ' WHERE '+ fieldName + ' = \'' + fieldValue + '\'';
        }
        query += ' ORDER BY CreatedDate DESC ';
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Receiving_Stock_Excess__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Receiving_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Vendor_Receiving_Group__c> vorGroups = Database.query(query);
        return vorGroups;
    }
    
    /**
     * Name: getVIHeaderByFieldName
     * Desc: To get Vendor Invoicing Header Recs
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Vendor Invoicing Header Recs
    **/
    public static List<Sobject> getVIHeaderByFieldName(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : VendorInvoicingCtrl.viHeaderFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        
        // Child Query
        query += ' (SELECT In_Progress_VI__c FROM Vendor_Receiving_Headers__r) ';
        
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Invoicing_Header__c ';
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
        query += ' ORDER BY CreatedDate';
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Receiving_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Vendor_Invoicing_Header__c> viHeaderList = Database.query(query);
        //system.assert(false, voLineItems);
        return viHeaderList;
    }
    
    /**
     * Name: getVRByVendorId
     * Desc: To get Vendor Receiving Header Records
     * @param:  (1) vendorId - String - Vendor Id 
     *          (2) viHeaderId - String - Vendor Invoice Header Id
     *          (3) sortFieldMap -Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc) 
     * @return: List<Sobject> - Vendor Receiving Header Records
    **/
    public static List<Sobject> getVRByVendorId(String vendorId, String viHeaderId, Map<String, String> sortFieldMap) {
        vendorId = BPUtility.escapeSingleQuotes(vendorId);
        viHeaderId = BPUtility.escapeSingleQuotes(viHeaderId);
        String query;   
        query = 'SELECT '; 
        for(String fieldName : VendorInvoicingCtrl.voReceivingFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        
        // Child Query
        query += '(SELECT '; 
        for(String fieldName : VendorInvoicingCtrl.vrGroupFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Vendor_Receiving_Groups__r ), ';
        
        // Child Query
        query += '(SELECT Vendor_Order_Header__c, Vendor_Order_Header__r.Name FROM In_Progress_VRs__r) ';
        
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Receiving_Header__c ';
        
        if(vendorId != null) {
            query += ' WHERE Vendor__c = :vendorId AND (Status__c = \'Stocked\') ';
            query += ' AND ( In_Progress_VI__c = null OR In_Progress_VI__c = :viHeaderId ) ';
        }
        //system.assert(false, query);
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Receiving_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('In_Progress_VR__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Receiving_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Vendor_Receiving_Header__c> vrHeaderList = Database.query(query);
        //system.assert(false, voLineItems);
        return vrHeaderList;
    }
    
    
    /**
     * Name: getVIGroupByFieldName
     * Desc: To get Vendor Invoicing Header Group Records By Field Name
     * @param:  (1) fieldName - String - Field Name
     *          (2) idList - List<Id> - Id List
                (3) sortFieldMap -Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc) 
     * @return: List<Sobject> - Vendor Invoicing Header Group Records
    **/
    public static List<Sobject> getVIGroupByFieldName(String fieldName, List<Id> idList, Map<String, String> sortFieldMap) {
        fieldName = BPUtility.escapeSingleQuotes(fieldName);
        String query;   
        query = 'SELECT '; 
        for(String fieldNameStr : VendorInvoicingCtrl.viGroupFieldsList()){
            fieldNameStr = BPUtility.escapeSingleQuotes(fieldNameStr);
            query += fieldNameStr + ', ';
        } 
        query = query.substring(0, query.length()-2);
        
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Invoicing_Group__c ';
        boolean isWhereClauseAdded = false;
        query += 'WHERE '+ fieldName + ' IN : idList';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Invoicing_Group__c> viGroupList = Database.query(query);
        //system.assert(false, voLineItems);
        return viGroupList;
    }
    
    /**
     * Name: getVIHeaderDetailsByFieldName
     * Desc: To get Vendor Invoicing Header Records With its Group
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Vendor Invoicing Header Records
    **/
    public static List<Sobject> getVIHeaderDetailsByFieldName(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : VendorInvoicingCtrl.viHeaderFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        
        // Child Query
        query += '(SELECT '; 
        for(String fieldName : VendorInvoicingCtrl.viGroupFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Vendor_Invoicing_Groups__r ) ';
        
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Invoicing_Header__c ';
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
        query += ' ORDER BY CreatedDate';
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Vendor_Invoicing_Header__c> viHeaderList = Database.query(query);
        return viHeaderList;
    }
    
    public static List<Vendor_Receiving_Header__c> getVRHeaderList(String vrHeaderId) {
        vrHeaderId = BPUtility.escapeSingleQuotes(vrHeaderId);
        String query;
        query = 'SELECT '; 
        for(String fieldName : VendorInvoicingCtrl.voReceivingFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        
        // Child Query
        query += '(SELECT '; 
        for(String fieldName : VendorInvoicingCtrl.vrGroupFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Vendor_Receiving_Groups__r ) ';
        query += ' FROM Vendor_Receiving_Header__c WHERE Id = :vrHeaderId';
        
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Receiving_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Receiving_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Vendor_Receiving_Header__c> vrHeaderList = Database.query(query);
        return vrHeaderList;
    }
    
    /**
     * Name: getVOHeaderByFieldId
     * Desc: To get Vendor Invoicing Header Records With its Group
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Vendor Invoicing Header Records
    **/
    public static List<Sobject> getVOHeaderByFieldId(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : VendorOrderHeader.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
          
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Header__c ';
        
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
        
        query += ' AND Status__c = \'Open\' ';
        
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Header__c> voHeaderList = Database.query(query);
       
        return voHeaderList;
    }
    
    /**
     * Name: getVOHeaderByFieldName
     * Desc: To get Vendor Invoicing Header Records With its Group
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Vendor Invoicing Header Records
    **/
    public static List<Sobject> getVOHeaderByFieldName(Map<String, List<String>> fieldNameToFieldValueListMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : VendorOrderHeader.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Header__c ';
        
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueListMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueListMap.keySet()) {
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                List<String> fieldValues = fieldNameToFieldValueListMap.get(fieldName);
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' IN : fieldValues';
                    isWhereClauseAdded = true;
                } else {
                    query += 'AND '+ fieldName + ' IN : fieldValues';
                }
            }
        }
        query += ' AND Status__c = \'Open\' ';
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Header__c> voHeaderList = Database.query(query);
        return voHeaderList;
    }
    
    /**
     * Name: getKitHeaderRec
     * Desc: To get Kit Header Records 
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Kit Header Records
    **/
    public static List<Sobject> getKitHeaderRec(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : KitHeader.getKitHeaderFields()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        
        // Child Query
        query += '( SELECT '; 
        for(String fieldName : KitHeader.getKitTransactionTypeJunctionFields()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM  Kit_Transaction_Type_Junctions__r )';
        query += ' FROM ' + Constants.NAMESPACE + 'Kit_Header__c '; 
        
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
        query += ' ORDER BY CreatedDate';
        if(AccessControl.ifObjectFieldIsAccessible('Kit_Transaction_Type_Junction__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Kit_Header_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Kit_Header__c> kitHeaderList = Database.query(query);
        return kitHeaderList;
    }
    
    /**
     * Name: getKHLineItemRec
     * Desc: To get Kit Header Line Items records 
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Kit Header Line Items Records
    **/
    public static List<Sobject> getKHLineItemRec(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : ViewKitCtrl.getKitLineItemFields()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Kit_Header_Line_Item__c ';
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
        query += ' ORDER BY CreatedDate ASC';
        if(AccessControl.ifObjectFieldIsAccessible('Kit_Header_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Kit_Header_Line_Item__c> khLineItemList = Database.query(query);
        return khLineItemList;
    }
    
    /**
     * Name: getTransactionTypes
     * Desc: To get all the Transaction Type records from Database by executing query
     * @param: (1) ttIds - List<id> - Transaction Type Ids List 
     * @return: List of Transaction Type records
    **/
    public static List<Sobject> getTransactionTypes(List<Id> ttIds) {
        String query;
        query = 'SELECT '; 
        for(String fieldName : ServiceJobTypeWrapper.getTransactionTypeFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Transaction_Type__c ';
        
        if(ttIds.size() > 0) {
            query += 'WHERE ID IN : ttIds '; 
        } 
        query += ' order by Code_Label__c';
        
        if(AccessControl.ifObjectFieldIsAccessible('Transaction_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Transaction_Type__c> ttList = Database.query(query);
        return ttList;
    }
    
    /**
     * Name: getSimilarKits
     * Desc: To get Related Kit Header Records
     * @param: (1) kitHeaderRec - Kit_Header__c - Kit Header Record  
     * @return: List<Sobject> - Kit Header record
    **/
    public static List<Sobject> getSimilarKits(Kit_Header__c kitHeaderRec) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : KitHeader.getKitHeaderFields()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Kit_Header__c ';
        
        Boolean isWhereClauseAdded = false;
        if(kitHeaderRec.Code__c != null && kitHeaderRec.Code__c != '') {
            isWhereClauseAdded = true;
            query += ' WHERE Code__c = \'' + kitHeaderRec.Code__c + '\'';
        } 
        if(kitHeaderRec.Description__c != null && kitHeaderRec.Description__c != '') {
            if(isWhereClauseAdded) {
                query += ' OR Description__c LIKE \'%' + kitHeaderRec.Description__c + '%\'';
            } else {
                query += ' WHERE Description__c LIKE \'%' + kitHeaderRec.Description__c + '%\'';
            }
        }
        
        query += ' ORDER BY CreatedDate DESC';
        if(AccessControl.ifObjectFieldIsAccessible('Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Kit_Header_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Kit_Header__c> kitHeaders = Database.query(query);
        return kitHeaders;
    }
    
    
    /**
     * Name: getFeeByFieldName
     * Desc: To get Fee Records By Field Name
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Fee Records
    **/
    public static List<Sobject> getFeeByFieldName(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : Fee.getFeeFields()){
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Fee__c ';
        
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
        query += ' ORDER BY CreatedDate';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Fee__c> feeList = Database.query(query);
        return feeList;
    }
    
    /**
     * Name: getDefaultCategoryRecords
     * Desc: Get default category records
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Category Records
    **/
    public static List<Sobject> getDefaultCategoryRecords(Map<String, String> fieldNameToFieldValueMap) {
        List<String> categoryFields = new List<String>{'Id', 'Name', 'Unique_Category__c', 'Default__c', 'Active__c', 'Status__c', 'AccountingId__c'};
        String query;   
        query = 'SELECT '; 
        for(String fieldName : categoryFields){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Category__c ';
        
        query += 'WHERE Default__c = true ';
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                query += 'AND '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
            }
        }
        query += ' ORDER BY CreatedDate';
        if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Category__c> categoryList = Database.query(query);
        return categoryList;
    }
    
    /**
     * Name: getOtherSimilarFees
     * Desc: To get Related Fee Records
     * @param: (1) feeRec - Fee__c - Fee Record 
     * @return: List<Sobject> - Fee record
    **/
    public static List<Sobject> getOtherSimilarFees(Fee__c feeRec) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : Fee.getFeeFields()){
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Fee__c ';
        
        Boolean isWhereClauseAdded = false;
        if(feeRec.Code__c != null && feeRec.Code__c != '') {
            isWhereClauseAdded = true;
            query += ' WHERE Code__c = \'' + feeRec.Code__c + '\'';
        } 
        if(feeRec.Description__c != null && feeRec.Description__c != '') {
            if(isWhereClauseAdded) {
                query += ' OR Description__c LIKE \'%' + feeRec.Description__c + '%\'';
            } else {
                query += ' WHERE Description__c LIKE \'%' + feeRec.Description__c + '%\'';
            }
        }
        
        query += ' ORDER BY CreatedDate DESC';
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Fee__c> feeRecords = Database.query(query);
        return feeRecords;
    }
    
    
    /**
     * Name: getSODetailsByFieldName
     * Desc: To get Service Order Records By Field Name
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Service Order Header Records
    **/
    public static List<Sobject> getSODetailsByFieldName(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : SOHeaderWrapper.getSOHeaderFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        
        // Child Query
        query += '( SELECT '; 
        for(String fieldName : SOHeaderWrapper.getSOKitHeaderFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2); 
        query += ' FROM Service_Order_Kit_Headers__r )';
        
        query += ', ( SELECT '; 
        for(String fieldName : SOHeaderWrapper.getSOPaymentRoleFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM SO_Payment_Roles__r ORDER BY LastModifiedDate)';
        
        // Child Query
        query += ', ( SELECT '; 
        for(String fieldName : SOHeaderWrapper.getSOLineItemFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Service_Order_Line_Items__r ORDER BY Name)';
        
        // Child Query
        query += ', ( SELECT '; 
        for(String fieldName : SOHeaderWrapper.getHoursLoggedFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Hours_Logged__r ORDER BY CreatedDate)';
        
       // Child query for CusotmerApproval
        query += ', ( SELECT '; 
        for(String fieldName : SOHeaderWrapper.getCustomerApprovalList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM CustomerApprovals__r ORDER BY CreatedDate ASC)';
        
        // Child Query for customer approval
        query += ', (SELECT Customer_Approval__c From Service_Jobs_To_Customer_Approvals__r ORDER BY CreatedDate ASC)'; 
        
        // Child Query
        query += ', ( SELECT '; 
        for(String fieldName : SOHeaderWrapper.getAttachmentList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Attachments ORDER BY CreatedDate)';
        
         // Child Query
        query += ', ( SELECT '; 
        for(String fieldName : SOHeaderWrapper.getCOInvoiceItemList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM CO_Invoice_Items__r ORDER BY CreatedDate)';
        
        query += ' FROM Service_Order_Header__c ';
        
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                if(!isWhereClauseAdded) {
                    if(fieldNameToFieldValueMap.get(fieldName) == null) {
                        query += 'WHERE '+ fieldName + ' = ' + fieldNameToFieldValueMap.get(fieldName);
                    } else {
                        query += 'WHERE '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
                    }
                    isWhereClauseAdded = true;
                } else {
                    if(fieldNameToFieldValueMap.get(fieldName) == null) {
                        query += ' AND '+ fieldName + ' = ' + fieldNameToFieldValueMap.get(fieldName);
                    } else {
                        query += 'AND '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
                    }
                }
            }
        }
        query += ' ORDER BY Deal__c ASC NULLS LAST, CreatedDate ASC';
        
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('SO_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Hours_Logged__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CustomerApproval__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Service_Order_Header__c> soHeaderList = Database.query(query);
        return soHeaderList;
    }
    
    /**
     * Name: getSOKitHeaderByFieldName
     * Desc: To get Service Order Kit Header Records By Field Name
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Service Order Kit Header Records
    **/
    public static List<Sobject> getSOKitHeaderByFieldName(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        
        for(String fieldName : SOHeaderWrapper.getSOKitHeaderFieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        
        // Child Query
        query += '( SELECT '; 
        for(String fieldName : SOHeaderWrapper.getSOLineItemFieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        
        query = query.substring(0, query.length()-2);
        query += ' FROM Service_Order_Line_Items__r Order By Name, CreatedDate ASC)';
        
        query += ' FROM Service_Order_Kit_Header__c ';
        
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
        query += ' ORDER BY CreatedDate ASC';
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Kit_Header__c> soKitHeaderList = Database.query(query);
        return soKitHeaderList;
    }
    
    
    /**
     * Name: getTransactionTypesWithProvider
     * Desc: To get all the Transaction Type records from Database by executing query
     * @param: (1) ttIds - List<id> - Transaction Type Ids List 
     * @return: List of Transaction Type records
    **/
    public static List<Sobject> getTransactionTypesWithProvider(List<Id> ttIds) {
        String query;
        //query = 'SELECT Id, Type__c, Code_Label__c, (Select Name__c, Email__c, Phone__c FROM Providers__r) FROM Transaction_Type__c '; 
        query = 'SELECT Id, Type__c, Code_Label__c, Internal_Category__r.Id, Internal_Category__r.Name, Third_Party_Customer__r.Id, Third_Party_Customer__r.Name, (Select Name__c, Email__c, Phone__c FROM Providers__r) FROM Transaction_Type__c WHERE Active__c = true';  
        if(ttIds.size() > 0) {
            query += 'WHERE ID IN : ttIds '; 
        } 
        query += ' order by Code_Label__c';
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Transaction_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Transaction_Type__c> ttList = Database.query(query);
        return ttList;
    }
    
    /**
     * Name: getActiveOrders
     * Desc: To get Service Order Line Item Records
     * @param: (1) sobjectId - String - Record Id 
     * @return: Service Order Line Item Records
    **/
    public static List<Sobject> getActiveOrders(String sobjectId) {
        sobjectId = BPUtility.escapeSingleQuotes(sobjectId);
        String objectName = (Id.valueOf(sobjectId)).getSObjectType().getDescribe().getName();
        
        String query;
        query = 'SELECT Service_Order_Header__r.CO_Header__c, Service_Order_Header__r.CO_Header__r.Name, Service_Order_Header__r.CO_Header__r.Customer__r.Name, Service_Order_Header__r.CO_Header__r.Customer_Name__c, Service_Order_Header__r.CO_Header__r.Order_status__c, ';
        query += 'Service_Order_Header__r.CO_Header__r.Owner__r.Name FROM Service_Order_Line_Item__c '; 
        if(sobjectId != null) {
            query += 'WHERE ' + objectName + '= \'' + sobjectId + '\' AND Service_Order_Header__r.CO_Header__c != null'; 
        } 
        query += ' ORDER BY Service_Order_Header__r.CO_Header__r.Name';
        //system.assert(false, query);
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Line_Item__c> soliList = Database.query(query);
        return soliList;
    }
    
     /**
     * Name: getFeeDetailsForFeeId
     * Desc: To get  Fee Delails 
     * @param: (1) feeId - String - Record Id
     * @return: feeList 
    **/
    public static List<Sobject> getFeeDetailsForFeeId(Id feeId, Map<String, String> sortFieldMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName :  Fee.getFeeFields()){
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Fee__c ';
        if(feeId != null) {
            query += 'WHERE Id =: feeId ';
        }
        query += 'Order By CreatedDate DESC';
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Fee__c> feeList = Database.query(query);
        return feeList;
    }   
    
     /**
     * Name: getCOLIDetailsForKitId
     * Desc: To get  coli Delails 
     * @param: (1) kitId - String - Record Id
     * @return: feeList  
    **/
    public static List<Sobject> getCOLIDetailsForKitId(Id kitId, Map<String, String> sortFieldMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName :  COLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Line_Item__c ';
        if(kitId != null) {
            query += 'WHERE CO_Kit_Header__r.Kit_Header__c =: kitId ';
        }
        query += 'Order By CreatedDate DESC';
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Line_Item__c> coliListForKit = Database.query(query);
        return coliListForKit;
    }
    
    /**
     * Name: getCOHeaderDetailsForCustomer
     * Desc: To get customer order header details
     * @param: 
     * @return: List<Sobject> - customer order header records
    **/
    public static List<Sobject> getCOHeaderDetailsForFee(List<Id> coheaderIds, Map<String, String> sortFieldMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName :  COHeader.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Header__c ';
        if(coheaderIds != null && coheaderIds.size() != 0) {
            query += 'WHERE Id IN: coheaderIds';
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> coheaderRec = Database.query(query);
        return coheaderRec;
        } 
    
    
    /**
     * Name: getActiveOrdersForKit
     * Desc: To get  Service Order Kit Header Records
     * @param: (1) sobjectId - String - Record Id
     * @return: Service Order Kit Header Records
    **/
    public static List<Sobject> getActiveOrdersForKit(String sobjectId) {
        sobjectId = BPUtility.escapeSingleQuotes(sobjectId);
        String objectName = (Id.valueOf(sobjectId)).getSObjectType().getDescribe().getName();
        String query;
        query = 'SELECT Service_Order_Header__r.CO_Header__c, Service_Order_Header__r.CO_Header__r.Name, Service_Order_Header__r.CO_Header__r.Customer__r.Name, Service_Order_Header__r.CO_Header__r.Customer_Name__c, Service_Order_Header__r.CO_Header__r.Order_status__c, ';
        query += 'Service_Order_Header__r.CO_Header__r.Owner__r.Name FROM Service_Order_Kit_Header__c '; 
        if(sobjectId != null) {
            query += 'WHERE ' + objectName + '= \'' + sobjectId + '\' AND Service_Order_Header__r.CO_Header__c != null '; 
        } 
        query += 'ORDER BY Service_Order_Header__r.CO_Header__r.Name';
        //system.assert(false, query);
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Kit_Header__c> sokhList = Database.query(query);
        return sokhList;
    }
    
    
   /**
     * Name: getCoustmerOrderWidgetRecords
     * Desc: To get coustmer Order  Header Records which are not closed
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Coustmer Order Header Records
    **/
    public static List<Sobject> getCustomerOrderWidgetRecords(Map<String, String> fieldNameToFieldValueMap) {
        List<String> coHeaderFields = new List<String>{'Id', 'LastModifiedDate', 'Owner_Last_Visited__c' };
        String query = 'SELECT ';  
        for(String fieldName : coHeaderFields){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM CO_Header__c ';
        
        query += 'WHERE Status__c NOT IN (\'Closed\', \'Deleted\' ) ';
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                query += 'AND '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
            }
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> CustomerOrderRecordsList = Database.query(query);
        return CustomerOrderRecordsList;
    }
    
    /**
     * Name: getCoustmerOrderWidgetRecords
     * Desc: To get coustmer Order  Header Records which are not closed
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Coustmer Order Header Records
    **/
    public static List<Sobject> getCustomerOrderUpdatedRecords(Map<String, String> fieldNameToFieldValueMap) {
        List<String> coHeaderFields = new List<String>{'Id','LastModifiedById','owner__c', 'LastModifiedDate', 'Owner_Last_Visited__c' };
        String query = 'SELECT ';  
        for(String fieldName : coHeaderFields){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM CO_Header__c ';
        
        query += 'WHERE Status__c != \'Deleted\' ';
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                query += 'AND '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
            }
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> CustomerOrderRecordsList = Database.query(query);
        return CustomerOrderRecordsList;
    }
    /**
     * Name: getWidgetRecords
     * Desc: To get widget Records which are not closed
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - widget Records
    **/
    public static List<Sobject> getWidgetRecords(Map<String, String> fieldNameToFieldValueMap) {
        List<String> widgetFields = new List<String>{'Widget__c', 'Widget__r.Name', 'Widget__r.Widget_Name__c', 'WidgetOrder__c', 'Is_Visible__c'};
        String query = 'SELECT '; 
        for(String fieldName : widgetFields){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Widget_User_Junction__c ';
        
       query += 'WHERE WidgetOrder__c  != null ';
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                query += 'AND '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
            }
        }
        if(AccessControl.ifObjectFieldIsAccessible('Widget_User_Junction__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        query += ' ORDER BY WidgetOrder__c NULLS LAST' ;
        List<Widget_User_Junction__c> widgetList = Database.query(query);
        return widgetList;
    }
    
    /**
     * Name: getVendorOrderWidgetRecords
     * Desc: To get Vendor Order Widget Records whose status is not In Received and Deleted
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Coustmer Order Header Records
    **/
    public static List<Sobject> getVendorOrderWidgetRecords(Map<String, String> fieldNameToFieldValueMap) {
        List<String> vendorOrderFields = new List<String>{'Id', 'Status__c'};
        String query = 'SELECT ';  
        for(String fieldName : vendorOrderFields){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Vendor_Order_Header__c ';
        
        query += 'WHERE Status__c NOT IN (\'Received\', \'Deleted\' ) ';
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                query += 'AND '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
            }
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Header__c> vendorOrderRecordsList = Database.query(query);
        return vendorOrderRecordsList;
    }
    /**
     * Name: getVendorRecievingWidgetRecords
     * Desc: To get  Vendor Recieving Records whose status is not In Invoiced and Stocked
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Vendor Recieving Records
    **/
    public static List<Sobject> getVendorRecievingWidgetRecords(Map<String, String> fieldNameToFieldValueMap) {
        List<String> VendorRecievingFields = new List<String>{'Id', 'Status__c'};
        String query = 'SELECT ';  
        for(String fieldName : VendorRecievingFields){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Vendor_Receiving_Header__c ';
        
        query += 'WHERE Status__c NOT IN (\'Invoiced\', \'Stocked\' ) ';
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                query += 'AND '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
            }
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Receiving_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Receiving_Header__c> vendorRecievingRecordsList = Database.query(query);
        return vendorRecievingRecordsList;
    }
    
    /**
     * Name: getVendorInvoicingWidgetRecords
     * Desc: To get Vendor Invoicing Records whose status is not In Invoiced 
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Vendor Invoicing Records
    **/
    public static List<Sobject> getVendorInvoicingWidgetRecords(Map<String, String> fieldNameToFieldValueMap) {
        List<String> VendorInvoicingFields = new List<String>{'Id', 'Status__c'};
        String query = 'SELECT ';  
        for(String fieldName : VendorInvoicingFields){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Vendor_Invoicing_Header__c ';
        
        query += 'WHERE Status__c  != \'Invoiced\'';
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                query += 'AND '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
            }
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Invoicing_Header__c> vendorInvoicingRecordsList = Database.query(query);
        return vendorInvoicingRecordsList;
    }
    
    /**
     * Name: getAppLogRecById
     * Desc: To get App Log Rec By  Id
     * @param: (1) appLogId - Id - App Log Id
     * @return: List<Sobject> - App Log  records
    **/
    public static List<Sobject> getAppLogRecById(String appLogId) {
        appLogId = BPUtility.escapeSingleQuotes(appLogId);
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : SOWizard.appLogFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM App_Log__c ';
        query += 'WHERE Id = :appLogId';
        if(AccessControl.ifObjectFieldIsAccessible('App_Log__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<App_Log__c> appLogRec = Database.query(query);
        return appLogRec;
    }
    
    /**
     * Name: getTransactionTypesWithProvider
     * Desc: To get all the Transaction Type records from Database by executing query
     * @param: (1) ttIds - List<id> - Transaction Type Ids List 
     * @return: List of Transaction Type records
    **/
    public static List<Sobject> getProviderList() {
        String query;
        query = 'SELECT '; 
        for(String fieldsName : Vendor.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Account ';
        query += ' WHERE Claims_for_Service_Work__c = true AND Is_Vendor__c = true AND Active__c = true';
        query += ' ORDER BY Name';
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Account> providerList = Database.query(query);
        return providerList;
    }
    
    /**
     * Name: getFinanceCompanyList
     * Desc: To get all the Transaction Type records from Database by executing query
     * @param: (1) ttIds - List<id> - Transaction Type Ids List 
     * @return: List of Transaction Type records
    **/
    public static List<Sobject> getFinanceCompanyList() {
        String query;
        query = 'SELECT '; 
        for(String fieldsName : Vendor.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Account ';
        query += ' WHERE Finance_Company__c = true AND Is_Vendor__c = true AND Active__c = true';
        query += ' ORDER BY Name';
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Account> financeCompanyList = Database.query(query);
        return financeCompanyList;
    }
    
    
    public static List<Sobject> getSOHeaderById(String soHeaderId, String wizardName) {
        soHeaderId = BPUtility.escapeSingleQuotes(soHeaderId);
        wizardName = BPUtility.escapeSingleQuotes(wizardName);
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : SOWizard.getSOHeaderFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        
        // Child query for CusotmerApproval
        query += '( SELECT '; 
        for(String fieldName : SOHeaderWrapper.getCustomerApprovalList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM CustomerApprovals__r WHERE Section_key__c =: wizardName ORDER BY CreatedDate)';
        
        query += ' FROM Service_Order_Header__c ';
        //query = query.substring(0, query.length()-2);
        //query += ' FROM Service_Order_Header__c ';
        query += 'WHERE Id = :soHeaderId';
        if(AccessControl.ifObjectFieldIsAccessible('CustomerApproval__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Service_Order_Header__c> soHeaderRec = Database.query(query);
        return soHeaderRec;
    }
    
    public static Map<String, CustomerApproval__c> getCustomerApprovalsById(Set<String> idSet) {
        String query = 'SELECT '; 
        for(String fieldName : SOHeaderWrapper.getCustomerApprovalList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM CustomerApproval__c ORDER BY CreatedDate ASC';
        if(AccessControl.ifObjectFieldIsAccessible('CustomerApproval__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Map<String, CustomerApproval__c> customerApprovalIdToRecMap = new Map<String, CustomerApproval__c>((List<CustomerApproval__c>)Database.query(query));
        return customerApprovalIdToRecMap;
    }
    
    public static List<Sobject> getRecordTypeId(String objectAPIName, String recordTypeDeveloperName) {
        objectAPIName = BPUtility.escapeSingleQuotes(objectAPIName);
        recordTypeDeveloperName = BPUtility.escapeSingleQuotes(recordTypeDeveloperName);
        String query;
        query = 'SELECT Id FROM RecordType'; 
        query += ' WHERE sobjectType =: objectAPIName And DeveloperName =: recordTypeDeveloperName ';
        if(AccessControl.ifObjectFieldIsAccessible('RecordType') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<RecordType> recordTypeList = Database.query(query);
        return recordTypeList;
    }
    
    /**
     * Name: getSOPaymentWrapperById
     * Desc: To get  Rec By  Id
     * @param: (1) soHeaderId - Id - So Header Id
     * @return: List<Sobject> - So Header  records
    **/
    public static List<Sobject> getSOPaymentWrapperById(String recId, String status) {
        recId = BPUtility.escapeSingleQuotes(recId);
        status = BPUtility.escapeSingleQuotes(status);
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : SOPaymentWrapper.getSOPaymentRoleFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM SO_Payment_Role__c ';
        
        String objectName = (Id.valueOf(recId)).getSObjectType().getDescribe().getName();
        if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
            query += 'WHERE Service_Order_Header__c = :recId ' ;
        } else if(objectName == Constants.NAMESPACE + 'SO_Payment_Role__c') {
            query += 'WHERE Id = :recId ' ;
        } 
        
        if(status != null) {
            query += 'AND Deductible_Status__c =: status';
        }
        if(AccessControl.ifObjectFieldIsAccessible('SO_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<SO_Payment_Role__c> soPaymentRoleRec = Database.query(query);
        return soPaymentRoleRec;
    }
    
      /**
     * Name: getServiceOrderLineItemBySoHeadeder
     * Desc: to gell soli from service Order
     * @param: (1) soHeaderId - Id - So Header Id
     * @return: List<Service_Order_Line_Item__c> - So Header  records
    **/
    public static List<Service_Order_Line_Item__c> getServiceOrderLineItemBySOHeader(String soHeaderId){
        soHeaderId = BPUtility.escapeSingleQuotes(soHeaderId);
          String query;   
        query = 'SELECT '; 
        for(String fieldsName : SOHeaderWrapper.getSOLineItemFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        
        // Child Query
        query += '(SELECT ';
        for(String fieldsName : SOHeaderWrapper.individualTaxFieldsList()){
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Individual_Taxes__r )';
        
        query += ' FROM Service_Order_Line_Item__c ';
        query += 'WHERE Service_Order_Header__c = : soHeaderId';
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Line_Item__c> soLineItemRec = Database.query(query);
        return soLineItemRec;
    
    }
    
    /**
     * Name: getclaimDetailsBySOHeaderId
     * Desc: to get claim Record from service Order
     * @param: (1) soHeaderId - Id - So Header Id
     * @return: List<Claim__c> - claim  records
    **/
    public static List<Claim__c> getclaimDetailsBySOHeaderId(String soHeaderId){
        soHeaderId = BPUtility.escapeSingleQuotes(soHeaderId);
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : ClaimWizard.getClaimFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        
        query += '( SELECT '; 
        for(String fieldName : ClaimWizard.getClaimLineItemFieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2); 
        query += ' FROM Claim_Line_Items__r )';
        
        
        query += ' FROM Claim__c ';
        query += 'WHERE Service_Order_Header__c = : soHeaderId'; 
        if(AccessControl.ifObjectFieldIsAccessible('Claim__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Claim__c> claimRecList = Database.query(query);
        return claimRecList;
    
    }
    public static List<Part_FIFO_Bucket__c> getPartFIFOBucketByPartID(Map<String, String> fieldNameToFieldValueMap, boolean preview){
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : PartFifoBucket.getPartFIFOBucketList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        
        query += '( SELECT '; 
        for(String fieldName : PartFifoBucket.getPartFIFOBucketLineItemList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2); 
        query += ' FROM Part_FIFO_Bucket_Activity_Line_Items__r order by CreatedDate Asc )';
        
        
        query += ' FROM Part_FIFO_Bucket__c ';
        query += 'WHERE Is_FIFO_Bucket__c = true ';
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                query += 'AND '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
            }
        }
        if(!preview){
            query += ' AND Remaining_Qty__c != 0';
        }
        query += ' order by CreatedDate Asc';
        if(AccessControl.ifObjectFieldIsAccessible('Part_FIFO_Bucket_Activity_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Part_FIFO_Bucket__c> partFIFOrecList = Database.query(query);
        return partFIFOrecList;
    
    }
    
    //part Fifo Bucket by partIdset 
    public static List<Part_FIFO_Bucket__c> getPartFIFOBucketByPartList(Set<Id> PartIdSet){
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : PartFifoBucket.getPartFIFOBucketList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2); 
        query += ' FROM Part_FIFO_Bucket__c ';
        query += 'WHERE Is_FIFO_Bucket__c = true AND Remaining_Qty__c > 0  and Part__c IN : PartIdSet ';
        query += ' order by CreatedDate Asc';
        
        if(AccessControl.ifObjectFieldIsAccessible('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        // system.assert(false,query);
        List<Part_FIFO_Bucket__c> partFIFOrecList = Database.query(query);
        return partFIFOrecList;
    }   

    
     /**
     * Name: getTaxExemptionList
     * Desc: To get Part taxes with sales taxes information for a Part Id
     * @param:  (1) vendorId - Id - Vendor Record Id
      *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)    
     * @return: Part Taxes records list
    **/ 
    public static List<Tax_Exemption__c> getTaxExemptionList(Id customerId, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : TaxExemptions.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Tax_Exemption__c ';
        query += 'WHERE Customer__c =: customerId';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Tax_Exemption__c> taxExemptionList = Database.query(query);
        return taxExemptionList;
    }
    
     /**
     * Name: getTaxExemptionList
     * Desc: To get Part taxes with sales taxes information for a Part Id
     * @param:  (1) vendorId - Id - Vendor Record Id
     *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)    
     * @return: Part Taxes records list
    **/ 
    public static List<Sales_Tax_Item__c> getAllSalesTaxItemWithExemptions(Id customerId, Map<String, String> fieldNameToFieldValueMap) {
        String query;
        query = 'SELECT Name__c, Rate__c, Forms_Label__c, ';
        
        // child Query - Tax Exemptions
        query += '(SELECT Id, Customer__c from Tax_Exemptions__r WHERE Customer__c =: customerId)'; 
        query += ' FROM ' + Constants.NAMESPACE + 'Sales_Tax_Item__c ';
        query += ' WHERE Active__c = true';
        
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += 'AND '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Sales_Tax_Item__c> salesTaxItemList = Database.query(query);
        return salesTaxItemList;  
    }
    
    /**
     * Name: getBusinessProfileData
     * Desc: To get business profile records from Database by executing query
     * @param: (1) businessProfileIds - List<id> - Business profile Ids List 
     * @return: List of Business profile records
    **/
    public static List<Business_Profile__c> getBusinessProfileData(List<id> businessProfileIds) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : UserSettingCtrl.BUSINESS_PROFILE_FIELDS_TO_JSON_MAPPING.get('Business_Profile__c')){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Business_Profile__c ';
        if(businessProfileIds.size() > 0) {
            query += 'WHERE ID IN : businessProfileIds';
        }
        query += ' LIMIT 1';
        if(AccessControl.ifObjectFieldIsAccessible('Business_Profile__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Business_Profile__c> businessProfiles = Database.query(query);
        return businessProfiles;
    }

  /** Added by ANkit
     * Name: getPartActiveOrdersForPart
     * Desc: To get Part Active Orders for a Part Id
     * @param:  (1) vohIdSet - Set<Id>  - Set of Vendor Order header ids
     *          (2) sortFieldMap - Map<String, String> - Mapping of key -> Field and Value -> Sorting Type(ASC, Desc)
                (3) partid - id of the part
     * @return: Vendor Order header record list
    **/  
    public static List<Vendor_Order_Header__c> getPartActiveOrdersForPart(Set<Id> vohIdSet, Map<String, String> sortFieldMap,Id partId) {
        String query;
        query = 'SELECT ';
        for(String fieldName : ActiveOrder.getActiveOrderfieldsListNew()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Header__c ';
        query += 'WHERE Id IN :vohIdSet';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Header__c> partActiveOrders = Database.query(query);
        return partActiveOrders;
    }   
    
    /** 
     * Name: getOtherSimilarActiveUnits
     * Desc: To get other similar active based on conditions
     * @param:  (1) filterUnitRecord - Customer_Owned_Unit__c - unit record by which we have to filer other unit records
     * @return: Matching unit records
     * Added By - Tarun Khandelwal
    **/  
    public static List<Customer_Owned_Unit__c> getOtherSimilarActiveUnits(Customer_Owned_Unit__c filterUnitRecord) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : CustomerOwnedUnit.fieldsList()){
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Customer_Owned_Unit__c ';
        query += getActiveUnitWhereClause();
        
        Boolean isOrClauseAdded = false;
        String filterClause = '';
        for(String fieldName : CustomerOwnedUnit.getSimilarMatchingFieldsForUnits()) {
            if(fieldName == 'VIN_Number__c') {
                String vinValue;
                if(filterUnitRecord.get(fieldName) != null) {
                    vinValue = String.valueOf(filterUnitRecord.get(fieldName));
                }
                if(vinValue != null && vinValue.length() == 17) {
                    vinValue = vinValue.subString(11, 17); // Last Seven Characters check of VIN
                }
                if(isOrClauseAdded && vinValue != null) {
                    filterClause += ' OR ' + fieldName + ' LIKE \'%' + vinValue + '\'';
                } else if(!isOrClauseAdded && vinValue != null) {
                    filterClause += fieldName + ' LIKE \'%' + filterUnitRecord.get(fieldName) + '\'';
                    isOrClauseAdded = true;
                }
            } else {
                if(isOrClauseAdded && filterUnitRecord.get(fieldName) != null) {
                    filterClause += ' OR ' + fieldName + ' = \'' + filterUnitRecord.get(fieldName) + '\'';
                } else if(!isOrClauseAdded && filterUnitRecord.get(fieldName) != null) {
                    filterClause += fieldName + ' = \'' + filterUnitRecord.get(fieldName) + '\'';
                    isOrClauseAdded = true;
                }
            }
        }
        if(String.isNotBlank(filterClause)) {
            query += 'AND ( ' + filterClause + ' ) ORDER BY CreatedDate DESC';
        } else {
            return new List<Customer_Owned_Unit__c>();
        }
        //system.assert(false, query);
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Customer_Owned_Unit__c> units = Database.query(query);
        return units;
    }
    
    private static List<String> stockInactiveStatusList = new List<String>{'Traded', 'Delivered', 'Sold', 'Inactive'};
    private static String getActiveUnitWhereClause() {
        String whereClause = 'WHERE (';
        whereClause += ' (Unit_Type__c = \'COU\' AND Status__c = \'Active\') OR ';
        whereClause += ' (Unit_Type__c = \'STOCK\' AND Status__c NOT IN :stockInactiveStatusList) OR ';
        whereClause += ' (Unit_Type__c = \'ORDU\' AND Status__c = \'On Order\')';
        whereClause += ') ';
        return whereClause;
    }
    
    /**
     * Name: getUnitByFieldName
     * Desc: To get Unit Records By Field Name
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Key - Field Name
     *                                                            - Value - Field Value  
     * @return: List<Sobject> - Unit Records
    **/
    public static List<Sobject> getUnitByFieldName(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : UnitWrapper.fieldsListForUnitInfo()){
            query += fieldName + ', ';
        } 
        
        //Child query
        query += '(Select ';
        for(String fieldName : UnitWrapper.fieldsListForUnitPriceAndCostTracking()){
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Unit_Prices_Costs__r ORDER BY Type__c ASC, CreatedDate ASC) ';
        
        query += ' FROM Customer_Owned_Unit__c ';
        
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\'';
                    isWhereClauseAdded = true;
                } else {
                    System.debug(fieldNameToFieldValueMap.get(fieldName));
                    query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\'';
                }
            }
        }
        query += ' ORDER BY CreatedDate DESC';
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Customer_Owned_Unit__c> couList = new List<Customer_Owned_Unit__c>();
        couList = Database.query(query);
        return couList;
    }
    
    public static List<Account> getCardDetails(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        
        CustomerOrderWrapper.COCardDetail cardObj = new CustomerOrderWrapper.COCardDetail();
        for(String fieldName : cardObj.getCustomerCardFields()){
            query += fieldName + ', ';
        }
        
        for(String fieldName : COHeaderWrapper.priceLevelFields){
            query += fieldName + ', ';
        } 
        
        //Child query
        query += '( Select ';
        for(String fieldName : COHeaderWrapper.taxExemptionFields){
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Tax_Exemptions__r), ';
        
        //Child query
        query += '(Select Id FROM CO_Headers__r where Status__c = \'Open\') ';
        
        query += ' FROM Account ';
        
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\'';
                    isWhereClauseAdded = true;
                } else {
                    System.debug(fieldNameToFieldValueMap.get(fieldName));
                    query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\'';
                }
            }
        }
        //System.assert(false,'QUERY  ' + query);
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Account> customerList = new List<Account>();
        customerList = Database.query(query);
        return customerList;
    }
    
    public static List<Price_Level__c> getCardDetailsForCO() {
        return getCardDetailsForCO(null);
    }
    
    public static List<Price_Level__c> getCardDetailsForCO(Id priceLevelId) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : Constants.PRICE_LEVEL_FIELDS_TO_JSON_MAPPING.keyset()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Price_Level__c ';
        if(String.isBlank(priceLevelId)) {
            query += ' WHERE Default__c = true';
        } else {
            query += ' WHERE Id =: priceLevelId';
        }
        boolean isWhereClauseAdded = false; 
        //System.assert(false,'QUERY  ' + query);
        if(AccessControl.ifObjectFieldIsAccessible('Price_Level__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Price_Level__c> priceLevelList = new List<Price_Level__c>();
        priceLevelList = Database.query(query);
        return priceLevelList;
    }
    
    public static List<Deal__c> getDealDetails(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : DealWrapper.getDealFields()){
            query += fieldName + ', ';
        } 
         //Child Query for deposits 11/23 #1303
        query += '(Select ';
        for(String fieldName : CODeposit.fieldsList()){
            query += fieldName + ', ';  
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM CO_Deposits__r ORDER BY CreatedDate Desc), ';
        
        //Child Query for Invoice Items
        query += '(Select Is_Invoiceable__c, isActive__c FROM CO_Invoice_Items__r ), ';
        
        //Child query
        query += '(Select ';
        for(String fieldName : DealWrapper.getOptionAndFeeFields()){
            query += fieldName + ', ';  
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Options_Fees__r ORDER BY CreatedDate), ';
        
        query += '(Select ';
        for(String fieldName : DealItem.getDealItemFields()){
            query += fieldName + ', ';  
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Deal_Items__r) ';
             
        query += ' FROM Deal__c ';
         
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\'';
                    isWhereClauseAdded = true;
                } else {
                    System.debug(fieldNameToFieldValueMap.get(fieldName));
                    query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\'';
                }
            }
        }
        //System.assert(false,'QUERY  ' + query);
        if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal__c> dealList = Database.query(query);
        return dealList;
    }
    
    /**
     * Name: getDealItemDetails
     * Desc: To get deal item Records By Ids
     * @param: (1) dealItemIds - Set<Id> - Deal item Ids
     * @return: List<Sobject> - Deal item records
    **/
    public static List<Deal_Item__c> getDealItemDetails(Set<Id> dealItemIds) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : DealItem.getDealItemFields()){
            query += fieldName + ', ';
        } 
        
        //Child query for option and fee
        query += '(Select ';
        for(String fieldName : DealWrapper.getOptionAndFeeFields()){
            query += fieldName + ', ';  
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Options_Fees__r WHERE Deal_Kit_Header__c = null Order by Name ASC), ';
        
        //Child query for option and fee kit header
        query += '(Select ';
        for(String fieldName : DealWrapper.getDealKitHeaderFieldsList()){
            query += fieldName + ', ';  
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Deal_Kit_Headers__r Order by CreatedDate ASC), ';
        
        // Child Query for DealUnitPriceandcost
        query += '(Select ';
        for(String fieldName : DealWrapper.getDealUnitPriceCost()){
            query += fieldName + ', ';  
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Deal_Unit_Prices_Costs__r) ';
        
        query += ' FROM Deal_Item__c where Id IN :dealItemIds ORDER BY CreatedDate';
         
        //System.assert(false,'QUERY  ' + query);
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal_Item__c> dealItemList = Database.query(query);
        return dealItemList;
    }
    
    public static List<Customer_Owned_Unit__c> getStockUnitDetails(Set<Id> unitIds, Boolean isGetDataFromLastSynchedDate) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : UnitWrapper.fieldsListForUnitInfo()){
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Customer_Owned_Unit__c where Unit_Type__c = \'STOCK\'';
        
        if(unitIds != null && unitIds.size() > 0) {
            query += ' AND Id IN :unitIds';
        }
        if(isGetDataFromLastSynchedDate) {
            DateTime lastSyncDate = GeneralConfiguration.getDP360LastSynchedDate();
            query += ' AND (CreatedDate >= ' + lastSyncDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' OR LastModifiedDate >= ' +  + lastSyncDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' )';
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Customer_Owned_Unit__c> couList = Database.query(query);
        return couList;
    }
    
    /**
     * Name: getUnitDetails
     * Desc: To get Unit Records By Ids
     * @param: (1) unitIds - Set<Id> - Unit Ids
     * @return: List<Sobject> - Unit Records
    **/
    public static List<Customer_Owned_Unit__c> getUnitDetails(Set<Id> unitIds) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : UnitWrapper.fieldsListForUnitInfo()){
            query += fieldName + ', ';
        } 
        
        //Child query
        query += '(Select ';
        for(String fieldName : UnitWrapper.fieldsListForUnitPriceAndCostTracking()){
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Unit_Prices_Costs__r ORDER BY Type__c ASC, CreatedDate ASC) ';
        
        query += ' FROM Customer_Owned_Unit__c where Id IN :unitIds';
        
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Customer_Owned_Unit__c> couList = Database.query(query);
        return couList;
    }
    
    //START: Added By Nidhi - #129 - 09/24/2016 
    /**
     * Name: getSOHeaderListByCOHeaderId
     * Desc: To get Service Order Header records by Co Header Ids
     * @param: (1) coHeaderIds - Set<Id> - CO Header Ids
     * @return: List<CO_Header__c> - CO Header Records
    **/ 
    public static List<CO_Header__c> getSOHeaderListByCOHeaderId(Set<Id> coHeaderIds) {
        String query = 'SELECT (SELECT Id, Name__c, Customer_Owned_Unit__c, Customer_Owned_Unit__r.VIN_Number__c, Job_Type__c, Transaction_Type__r.Type__c, Transaction_Type__r.Code_Label__c, Work_Status__c, ' +
                        'Customer_Owned_Unit__r.Unit_Make__r.Name, Customer_Owned_Unit__r.Unit_Model__r.Name__c, Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c, ' + 
                       'Customer_Owned_Unit__r.Year__c FROM Service_Order_Headers__r) from CO_Header__c where Id In :coHeaderIds';
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> coList = Database.query(query);
        return coList;
    }
    
    /**
     * Name: getCustomerDetailsByFieldName
     * Desc: To get customer details by field name
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> 
     * @return: List<Account> - Account Records
    **/ 
    public static List<Account> getCustomerDetailsByFieldName(Map<String, String> fieldNameToFieldValueMap) {
        String query = 'SELECT ';
        for(String fieldName : SOWorkSheetWrapper.getCustomerFieldsList()) {
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account ';
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\'';
                    isWhereClauseAdded = true;
                } else {
                    System.debug(fieldNameToFieldValueMap.get(fieldName));
                    query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\'';
                }
            }
        }
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Account> customerList = Database.query(query);
        return customerList;
    }
    
    //END: Added By Nidhi - #129 - 09/24/2016  
    
    //START: Added By Nidhi - #129 - 11/4/2016 
    /**
     * Name: getDealMerchandiseLineItem
    **/ 
    public static List<CO_Line_Item__c> getCOLineItemByFieldValue(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : COLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        
        // Child Query
        query += '(SELECT ';
        for(String fieldsName : COLineItem.individualTaxFieldsList()){
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Individual_Taxes__r )';
        
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Line_Item__c ';
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                if(!isWhereClauseAdded) {
                    if(fieldNameToFieldValueMap.get(fieldName) == null) {
                        query += 'WHERE '+ fieldName + ' = ' + fieldNameToFieldValueMap.get(fieldName);
                    } else {
                    query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\'';
                    }
                    isWhereClauseAdded = true;
                } else {
                    System.debug(fieldNameToFieldValueMap.get(fieldName));
                    if(fieldNameToFieldValueMap.get(fieldName) == null) {
                        query += ' AND '+ fieldName + ' = ' + fieldNameToFieldValueMap.get(fieldName);
                    } else {
                    query += ' AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\'';
                }
            }
        }
        }
        if(AccessControl.ifObjectFieldIsAccessible('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Line_Item__c> coLineItems = Database.query(query);
        return coLineItems;
    }
    
    //END: Added By Nidhi - #129 - 11/4/2016 
    
    
    // Added by TK - 11/04/2016
    public static List<Deal_Item__c> getDealItemDetailsByFieldName(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : DealItem.getDealItemFields()){
            query += fieldName + ', ';
        } 
        
        //Child query
        query += '(Select ';
        for(String fieldName : DealWrapper.getOptionAndFeeFields()){
            query += fieldName + ', ';  
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Options_Fees__r WHERE Deal_Kit_Header__c = null Order by CreatedDate ASC), ';
        
        query += '(Select ';
        for(String fieldName : DealWrapper.getDealKitHeaderFieldsList()){
            query += fieldName + ', ';  
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Deal_Kit_Headers__r Order by CreatedDate ASC) ';
        
        query += ' FROM Deal_Item__c ';
         
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                    isWhereClauseAdded = true;
                } else {
                    query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                }
            }
        } 
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal_Item__c> dealItemList = Database.query(query);
        return dealItemList;
    }
    
    // Added by subhrant - 24/11
    public static List<CO_Deposit__c> getDealDeposits(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
         //Child Query for deposits 11/23 #1303
        query = 'Select ';
        for(String fieldName : CODeposit.fieldsList()){
            query += fieldName + ', ';  
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM CO_Deposit__c ';
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                    isWhereClauseAdded = true;
                } else {
                    query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                }
            }
        } 
        query += ' ORDER BY  CreatedDate ASC';//Desc by kajal #1587 02/24/2017
        if(AccessControl.ifObjectFieldIsAccessible('CO_Deposit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Deposit__c> dealCoDeposit = Database.query(query);
        return dealCoDeposit;
    }
    
    public static List<Option_Fee__c> getOptionAndFeeRecord(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : DealWrapper.getOptionAndFeeFields()){
            query += fieldName + ', ';  
        } 
        
        //Child query - COLIs
        query += '(Select ';
        for(String fieldName : COLineItem.fieldsList()){
            query += fieldName + ', ';  
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM CO_Line_Items__r Order by CreatedDate ASC), ';
        
        // Child Query for SOLIs
        query += '(Select ';
        for(String fieldName : SOHeaderWrapper.getSOLineItemFieldsList()){
            query += fieldName + ', ';  
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Service_Order_Line_Items__r Order by CreatedDate ASC) ';
        
        query += ' FROM Option_Fee__c ';
        
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                    isWhereClauseAdded = true;
                } else {
                    query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                }
            }
        } 
         
        //System.assert(false,'QUERY  ' + query); 
        if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Option_Fee__c> dealItemList = Database.query(query);
        return dealItemList;
    }
     
    //Added by Nidhi - 18-11-2016
    public static List<Deal_Unresolved_Fulfillment__c> getDealUnresolvedFulfillment(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : DealWrapper.getDealUnresolvedFulfillmentFields()){
            query += fieldName + ', ';
        }  

        query = query.substring(0, query.length()-2);
        query += ' FROM Deal_Unresolved_Fulfillment__c ';
         
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                    isWhereClauseAdded = true;
                } else {
                    query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                }
            }
        }
        query += ' AND Is_Resolved__c = false ORDER BY CreatedDate ASC';
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal_Unresolved_Fulfillment__c> dealUnresolvedFulfillmentList = Database.query(query);
        return dealUnresolvedFulfillmentList;
    }
     
    //Added by Nidhi - 28-11-2016
    public static List<Deal_Finance__c> getDealFinanceRecord(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : DealWrapper.getDealFinanceFields()){
            query += fieldName + ', ';  
        } 
         
        query += '(Select ';
        for(String fieldName : DealWrapper.getDealFIProductFields()){
            query += fieldName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM F_I_Products__r Order by CreatedDate ASC) ';
        
        query += 'FROM Deal_Finance__c ';
        
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                    isWhereClauseAdded = true;
                } else {
                    query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                }
            }
        } 
         
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Finance__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal_Finance__c> dealFinanceList = Database.query(query);
        return dealFinanceList;
    }
    
    public static List<F_I_Product__c> getDealFAndIProductRecord(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        for(String fieldName : DealWrapper.getDealFIProductFields()){
            query += fieldName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM F_I_Product__c ';
        
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                    isWhereClauseAdded = true;
                } else {
                    query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                }
            }
        } 
        query += 'Order by CreatedDate ASC';
         
        if(AccessControl.ifObjectFieldIsAccessible('F_I_Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<F_I_Product__c> dealFIProductList = Database.query(query);
        return dealFIProductList;
    }
    
     /**
     * Name: getDealKitHeaderDetailsByDealItemId 
    **/
    public static List<Deal_Kit_Header__c> getDealKitHeaderDetailsByDealItemId(Set<Id> dealItemIds) {
        String query;   
        query = 'SELECT '; 
        
        for(String fieldName : DealWrapper.getDealKitHeaderFieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        
        // Child Query
        query += '( SELECT '; 
        for(String fieldName : DealWrapper.getOptionAndFeeFields()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Options_Fees__r Order By CreatedDate, Name ASC)';
        
        query += ' FROM Deal_Kit_Header__c where Deal_Item__c In :dealItemIds ORDER BY CreatedDate ASC';
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal_Kit_Header__c> dealKitHeaderList = new List<Deal_Kit_Header__c>();
        dealKitHeaderList = Database.query(query);
        return dealKitHeaderList;
    }
    
    public static List<Deal_Kit_Header__c> getDealKitHeaderDetailsByFieldName(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        
        for(String fieldName : DealWrapper.getDealKitHeaderFieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName); 
            query += fieldName + ', ';
        }
        
        // Child Query
        query += '( SELECT '; 
        for(String fieldName : DealWrapper.getOptionAndFeeFields()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Options_Fees__r Order By CreatedDate, Name ASC)';
        
        query += ' FROM Deal_Kit_Header__c ';
        
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                    isWhereClauseAdded = true;
                } else {
                    query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                }
            }
        } 
        query += 'Order by CreatedDate ASC';
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal_Kit_Header__c> dealKitHeaderList = new List<Deal_Kit_Header__c>();
        dealKitHeaderList = Database.query(query);
        return dealKitHeaderList;
    }
    
    public static List<Sobject> getCOKHByFieldValue(Map<String, String> fieldNameToFieldValueMap) { 
        String query;    
        query = 'SELECT ';  
        for(String fieldsName : COHeaderWrapper.getCOKHFieldsList()) {
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
         
        // Child Query
        query += '(SELECT ';
        for(String fieldsName : COLineItem.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Line_Items__r Order BY Name, CreatedDate)';
        
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Kit_Header__c ';
        
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                    isWhereClauseAdded = true;
                } else {
                    query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                }
            }
        }
        query += 'Order by CreatedDate ASC';
        if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Kit_Header__c> coKitHeaders = Database.query(query);
        return coKitHeaders;
    }
    
    public static List<Deal_Kit_Header__c> getDealKitHeaderByFieldName(Map<String, String> fieldNameToFieldValueMap) {
        String query;   
        query = 'SELECT '; 
        
        for(String fieldName : DealWrapper.getDealKitHeaderFieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        
        // Child Query
        query += '( SELECT '; 
        for(String fieldName : DealWrapper.getOptionAndFeeFields()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Options_Fees__r ), (Select Id from CO_Kit_Headers__r), (Select Id, Service_Order_Header__c from Service_Order_Kit_Headers__r)';
        
        query += ' FROM Deal_Kit_Header__c ';
        
        boolean isWhereClauseAdded = false;
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                if(!isWhereClauseAdded) {
                    query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                    isWhereClauseAdded = true;
                } else {
                    query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                }
            }
        } 
        query += 'Order by CreatedDate ASC';
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal_Kit_Header__c> dealKitHeaderList = new List<Deal_Kit_Header__c>();
        dealKitHeaderList = Database.query(query);
        return dealKitHeaderList;
    }

    // Start: Added by richa 24/01/2017 for retrieving SO's for a unit
    public static List<Service_Order_Header__c> getUnitServiceOrdersByUnitId(Set<Id> unitIds) {
        String query;   
        query = 'SELECT '; 
        
        for(String fieldName : UnitWrapper.fieldsListForServiceOrders()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        
        query = query.substring(0, query.length()-2);
        
        query += ' FROM Service_Order_Header__c where Customer_Owned_Unit__c IN :unitIds AND CO_Header__r.Order_Status__c != \'Quote\'';
        
        query += ' ORDER BY LastModifiedDate DESC';
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Header__c> soList = new List<Service_Order_Header__c>();
        soList = Database.query(query);
        return soList;
    }
    // End: Added by richa 24/01/2017 for retrieving SO's for a unit

    // Start: Added by richa 26/01/2017 for retrieving all CO's for a customer
    /**
     * Name: getAllCustomerOrdersForCustomer
     * Desc: To get all customer order header details
     * @param: 
     * @return: List<Sobject> - customer order header records
    **/
    public static List<Sobject> getAllCustomerOrdersForCustomer(Id customerId) {
        String query;   
        String statusValue = 'Closed';
        query = 'SELECT '; 
        for(String fieldsName : COHeader.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', '; 
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Header__c ';
        if(customerId != null) {
            query += 'WHERE Customer__c =: customerId AND Order_Status__c =: statusValue';
        }
        // Order by clause
        query += ' ORDER BY Name DESC';
        
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<CO_Header__c> coHeaderRec = Database.query(query);
        
        //system.assert(false, coHeaderRec);
        return coHeaderRec;
    }
    // End: Added by richa 26/01/2017 for retrieving all CO's for a customer
    
    
    
    public static List<Category__c> getAllCategoryDetails() {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : CategoryWrapper.getCategoryFieldList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', '; 
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Category__c Order by CreatedDate ASC';
        
        if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Category__c> categoryList = Database.query(query);
         
        return categoryList;
    }
    
    /* Start: Added by richa 14 april #1879 */
    /**
     * Name: getSOKHBySOHeaderId
     * Desc: To get Service Order Kit Header by SOHeader Id
     * @param: (1) soHeaderId - Id - Service Order Header Id 
     * @return: List<Sobject> - Service Order Kit Header records
    **/ 
    public static List<Sobject> getSOKHBySOHeaderId(Id soHeaderId) { 
        String query;    
        query = 'SELECT ';  
        for(String fieldsName : SOHeaderWrapper.getSOKitHeaderFieldsList()) {
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
         
        // Child Query
        query += '(SELECT ';
        for(String fieldsName : SOHeaderWrapper.getSOLineItemFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Service_Order_Line_Items__r )';
        
        query += ' FROM ' + Constants.NAMESPACE + 'Service_Order_Kit_Header__c ';
        if(soHeaderId != null) {
            query += 'WHERE Service_Order_Header__c = :soHeaderId ORDER BY CreatedDate'; //  AND Deal__c = null
        }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Kit_Header__c> soKitHeaders = Database.query(query);
        return soKitHeaders;
    }
    /* End: Added by richa 14 april #1879 */
    
    public static List<Technician__c> getTechnicianListByFieldName(Map<String, String> fieldNameToFieldValueMap) {
        String query;    
        query = 'SELECT ';  
        for(String fieldsName : SOHeaderWrapper.getTechnicianFieldsList()) {
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
         
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Technician__c WHERE Active__c= true ';
        if(fieldNameToFieldValueMap.size() > 0) {
            for(String fieldName : fieldNameToFieldValueMap.keySet()) {
                query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
            }
        }
        query += 'Order by Technician_Name__c ASC';
        if(AccessControl.ifObjectFieldIsAccessible('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Technician__c> technicians = Database.query(query);
        return technicians;
    }
    
    public static List<Technician__c> getTechniciansWithLeaveWithinTimePeriod(Set<String> technicianIdSet, DateTime fromDate, DateTime toDate ) {
        String query;    
        query = 'SELECT ';  
        for(String fieldsName : TechnicianDetailWrapper.getTechnicianFieldsList()) {
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
        query += '(SELECT ';  
        for(String fieldsName : LeaveWrapper.getLeaveFieldsList()) {
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Leaves__r WHERE From__c <= : toDate AND To__c >= : fromDate )' ;
        query += ' From Technician__c WHERE Type__c = \'Technician\' AND Active__c= true';
        if(technicianIdSet != null &&  technicianIdSet.size() > 0) {
            query += ' AND Id IN : technicianIdSet';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Technician__c> technicians = Database.query(query);
        return technicians;
    }
    
    public static List<Leave__c> getTechnicianLeavesByTechnicianId(Set<String> technicianIdSet) {
        String query;    
        query = 'SELECT ';  
        for(String fieldsName : LeaveWrapper.getLeaveFieldsList()) {
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Leave__c WHERE Technician__c IN : technicianIdSet AND Technician__r.Type__c = \'Technician\'';
        if(AccessControl.ifObjectFieldIsAccessible('Leave__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Leave__c> leaves = Database.query(query);
        return leaves;
    }
    
    public static List<Activity_History__c> getActivityHistoryList(Map<String, String> fieldNameToFieldValueMap, Integer totalRecords,List<String> RestrictedSourceEntities, Boolean isIntegration) {
        String query;    
        query = 'SELECT Id';  
        for(String fieldName : ActivityHistory.getActivityHistoryFieldList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += ', ' + fieldName;  
        }
        query += ' FROM Activity_History__c ';
        boolean isWhereClauseAdded = false;
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            if(!isWhereClauseAdded) {
                query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                isWhereClauseAdded = true;
                
            } else {
                query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                
            }
        }
        if(isIntegration){
            if(!isWhereClauseAdded) {
                query += 'WHERE Action__c = \'DP360 Deal Create\'' ;
            } else {
                query += 'AND Action__c = \'DP360 Deal Create\'' ;
            }
        } else { 
            if(!isWhereClauseAdded) {
                query += 'WHERE Action__c != \'DP360 Deal Create\'' ;
            } else {
                query += 'AND Action__c != \'DP360 Deal Create\'' ;
            }
        }
        if(RestrictedSourceEntities.size() > 0 && isWhereClauseAdded){ 
                     query += 'AND Source_Entity__c NOT IN :RestrictedSourceEntities ';
                     system.debug('query-1--->'+query);
                }else if(RestrictedSourceEntities.size() > 0 && !isWhereClauseAdded){
                    query += 'WHERE Source_Entity__c NOT IN :RestrictedSourceEntities ';
                     system.debug('query-1--->'+query);
                }
        
        
        query += 'Order by CreatedDate DESC LIMIT: totalRecords';
        if(AccessControl.ifObjectFieldIsAccessible('Activity_History__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Activity_History__c> activityHistoryList = Database.query(query);
        return activityHistoryList;
    }
        
     public static List<Sobject> getAllUserGroup() { 
        String query;
        query = 'SELECT ';
        for(String fieldName : UserGroupWrapper.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        } 
        // Child Query
        query += '(SELECT ';
        for(String fieldName : UserGroupWrapper.userGroupJunctionFieldList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'User_To_Groups1__r )';
       
        query += ' FROM User_Group__c';
        query += ' order by CreatedDate Desc';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
            
            
        if(AccessControl.ifObjectFieldIsAccessible('User_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<User_Group__c> userGroups = Database.query(query);
        return userGroups;
    }
     
     
     public static List<Sobject> getUserToGroupList(Map<String, String> fieldNameToFieldValueMap){
        String query;
        query = 'SELECT ';
        for(String fieldName : UserGroupWrapper.userGroupJunctionFieldList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName); 
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM User_To_Group__c ';
            
        Boolean isWhereClauseAdded = false;
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            if(!isWhereClauseAdded) {
                query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                isWhereClauseAdded = true;
            } else {
                query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
            }
        }
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('User_To_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<User_To_Group__c> userGroups = Database.query(query);
        return userGroups;
     }
      public static List<Sobject> getUserGroupList( Map<String, String> fieldNameToFieldValueMap) {
     String query = 'SELECT ';
     for(String fieldsName : UserGroupWrapper.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM User_Group__c ';
        
        Boolean isWhereClauseAdded = false;
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            if(!isWhereClauseAdded) {
                query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                isWhereClauseAdded = true;
            } else {
                query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
            }
        }
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('User_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<User_Group__c> userGroups = Database.query(query);
        return userGroups;
    }
     
     public static List<User>  getUserListWithGroup(){ 
        List<Profile> profileList = [select Id from Profile where Name IN :Constants.BLACKPURL_USER_PROFILE_NAMES];
        String query;    
        query = 'SELECT ';
        for(String fieldsName : UserGroupWrapper.userFieldList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        // Child Query
        query += '(SELECT ';
        for(String fieldsName : UserGroupWrapper.userGroupJunctionFieldList()){
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2); 
        query += ' FROM ' + Constants.NAMESPACE + 'User_To_Groups1__r )';
        
        query += ' FROM User ';
        query += ' WHERE isActive = true'; 
        query += ' AND profileId IN :profileList';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('User_To_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<User> usersList = Database.query(query);
        return usersList;
     }
     
     
     public static List<Linked_Fee__c> getLinkedFeeList(Map<String, String> fieldNameToFieldValueMap){
        String query;
        query = 'SELECT '; 
        for(String fieldName : LinkedFeeWrapper.fieldsList()){ 
            fieldName = BPUtility.escapeSingleQuotes(fieldName); 
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Linked_Fee__c '; 
            
        Boolean isWhereClauseAdded = false;
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            if(!isWhereClauseAdded) {
                query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                isWhereClauseAdded = true;
            } else {
                query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
            }
        }
        query += ' ORDER BY LastModifiedDate DESC';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('Linked_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Linked_Fee__c> linkedFeeList = Database.query(query);
        return linkedFeeList;
     }
     
     /**
     * Name: getOtherChargesByFieldName
     * Desc: To get Other Charges Records By FieldName
     * @param: (1) fieldName - String - Field Name
     *         (2) idList - List<Id> - Id List
     * @return: Linked Fee Records
    **/
    public static List<Sobject> getOtherChargesByFieldName(Map<String, String> fieldNameToFieldValueMap) {
        String query = 'SELECT ';    
        for(String fieldNameStr : VendorInvoicingCtrl.otherChargesFieldsList()){
            fieldNameStr = BPUtility.escapeSingleQuotes(fieldNameStr);
            query += fieldNameStr + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Other_Charges__c ';
        
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
        
        // Order by clause
        query += ' ORDER BY CreatedDate ASC';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        
        if(AccessControl.ifObjectFieldIsAccessible('Other_Charges__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Other_Charges__c> otherChargesList = Database.query(query);
        //system.assert(false, otherChargesList);
        return otherChargesList;
    }
    
    /**
     * Name: getTagList
     * Desc: To get Tag Records By FieldName
     * @param: (1) fieldNameToFieldValueMap - Map<String, String> - Field Name
     * @return: Tags Record
    **/
    public static List<Tag__c> getTagList(Map<String, String> fieldNameToFieldValueMap){
        String query = 'SELECT Id'; 
        for(String fieldName : TagWrapper.getTagFieldList()){ 
            query += ', ' + fieldName;
        } 
        query += ' FROM Tag__c '; 
            
        Boolean isWhereClauseAdded = false;
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            if(!isWhereClauseAdded) {
                query += 'WHERE ';
                isWhereClauseAdded = true;
            } else {
                query += 'AND ';
            }
            
            if(fieldName == 'Active__c') {
                query += fieldName + ' = ' + fieldNameToFieldValueMap.get(fieldName) + ' ';
            } else {
                query += fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
            }
        }
        query += ' ORDER BY CreatedDate DESC';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('Tag__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); } 
        List<Tag__c> tagList = Database.query(query);
        return tagList;
    }
    
    public static List<Return_VO_Header__c> getReturnVOHeaderDetail(Map<String, String> fieldNameToFieldValueMap){
        String query;
        query = 'SELECT ';
        for(String fieldName : ReturnVOHeaderWrapper.getReturnVOFieldList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName); 
            query += fieldName + ', ';
        } 
        
        //Child query
        query += '(Select ';
        for(String fieldName : ReturnVOHeaderWrapper.getReturnVOLIFieldList()){
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Return_VO_Line_Items__r ) ';
        query += ' FROM Return_VO_Header__c ';
            
        Boolean isWhereClauseAdded = false;
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            if(!isWhereClauseAdded) {
                query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                isWhereClauseAdded = true;
            } else {
                query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
            }
        }
        query += ' ORDER BY LastModifiedDate DESC';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('Return_VO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Return_VO_Header__c> returnVOList = Database.query(query);
        return returnVOList;
     }
     
     public static List<Message_History__c> getMessageList(Map<String, String> fieldNameToFieldValueMap){
        String query = 'SELECT Id'; 
        for(String fieldName : CustomerDetail.getMessageFieldList()){ 
            query += ', ' + fieldName;
        } 
        query += ' FROM Message_History__c '; 
            
        Boolean isWhereClauseAdded = false;
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            if(!isWhereClauseAdded) {
                query += 'WHERE '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                isWhereClauseAdded = true;
            } else {
                query += 'AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' '; 
            }
        }
        query += ' ORDER BY CreatedDate DESC';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('Message_History__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Message_History__c> msgList = Database.query(query);
        return msgList;
     }
     
     public static List<Return_VO_Line_Item__c> getPartActiveReturnOrderForPart(Id partId, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : ReturnVOHeaderWrapper.getReturnVOLIFieldList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Return_VO_Line_Item__c ';
        // Added by Hitesh - Status__c != \'Cancelled\'
        query += 'WHERE Part__c =: partId ';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += sortKey + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            } 
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Return_VO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Return_VO_Line_Item__c> partActiveOrders = Database.query(query);
        return partActiveOrders;
    }
     
     public static List<Return_VO_Header__c> getReturnActiveVOHeaderDetail(Map<String, String> sortFieldMap,Set<Id> vohIdSet, String partId){
        String query;
        query = 'SELECT ';
        for(String fieldName : ReturnVOHeaderWrapper.getReturnVOFieldList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName); 
            query += fieldName + ', ';
        } 
        
        //Child query
        query += '(Select ';
        for(String fieldName : ReturnVOHeaderWrapper.getReturnVOLIFieldList()){
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM Return_VO_Line_Items__r' + ((partId != null) ? ' where Part__c =: partId)' : ')');
        //query += ' FROM Return_VO_Line_Items__r where Part__c =: partId) ';
        query += ' FROM Return_VO_Header__c ';
            
         query += 'WHERE Id IN :vohIdSet AND Status__c Not IN (\'Approved\', \'Credited\')';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Return_VO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Return_VO_Header__c> returnVOList = Database.query(query);
        return returnVOList;
     }
         
     public static List<Return_VO_Header__c> getReturnVendorActiveOrders(Id returnVendorId, Map<String, String> sortFieldMap) {
        String query;
        query = 'SELECT ';
        for(String fieldName : ReturnVOHeaderWrapper.getReturnVOFieldList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Return_VO_Header__c ';
        query += 'WHERE Vendor__c =: returnVendorId AND Status__c Not IN (\'Approved\', \'Credited\')';
        
        // Order by clause
        query += ' ORDER BY ';
        if(sortFieldMap != null && sortFieldMap.size() != 0){
            for(String sortKey : sortFieldMap.keySet()){
                query += BPUtility.escapeSingleQuotes(sortKey) + ' ' + BPUtility.escapeSingleQuotes(sortFieldMap.get(sortKey)) + ', ';
            }
            query = query.substring(0, query.length()-2);
        } else {
            query += ' LastModifiedDate Desc';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Return_VO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Return_VO_Header__c> returnVendorActiveOrders = Database.query(query);
        return returnVendorActiveOrders;
    }
    
    public static List<Cash_Reconciliation__c> getReconciliationList(Map<String, String> fieldNameToFieldValueMap) {
        String query = 'SELECT Id, '; 
        for(String fieldName : ReconciliationWrapper.getReconciliationFieldList()){ 
            query += fieldName + ', ';
        } 
        
        //Child query
        query += '(SELECT Id';
        for(String fieldName : ReconciliationWrapper.getReconciliationPaymentFieldList()){
            query += ', ' + fieldName;
        } 
        query += ' FROM Cash_Reconciliation_Payments__r ) ';
        
        query += ' FROM Cash_Reconciliation__c '; 
        Boolean isWhereClauseAdded = false;
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            if(!isWhereClauseAdded) {
                query += 'WHERE ';
                isWhereClauseAdded = true;
            } else {
                query += 'AND ';
            }
            
            if(fieldName == 'Reconciliation_Date__c') {
                query += fieldName + ' = ' + fieldNameToFieldValueMap.get(fieldName) + ' ';
            } else {
                query += fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
            }
        }
        query += ' ORDER BY CreatedDate DESC';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        
        if(AccessControl.ifObjectFieldIsAccessible('Cash_Reconciliation__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); } 
        List<Cash_Reconciliation__c> reconciliationList = Database.query(query);
        return reconciliationList;
    } 
    
    public static List<CO_Invoice_Payment__c> getCOInvoicePaymentsByDate(DateTime dtValue) {
        String query = 'SELECT Id'; 
        for(String fieldName : ReconciliationWrapper.getCOInvoicePaymentfieldsList()){
            query += ', ' + fieldName;
        }
        query += ' FROM CO_Invoice_Payment__c WHERE ';
        query += ' CreatedDate >= ' + dtValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        query += ' AND CreatedDate <= ' + dtValue.addDays(1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        query += ' ORDER BY Name ASC LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Payment__c> coInvoicePayments = Database.query(query);
        return coInvoicePayments;
    }
    
    public static List<CO_Deposit__c> getCODepositByDate(DateTime dtValue) {
        String query = 'SELECT Id'; 
        for(String fieldName : ReconciliationWrapper.getCODepositFieldsList()){
            query += ', ' + fieldName;
        }
        query += ' FROM CO_Deposit__c WHERE ';
        query += ' CreatedDate >= ' + dtValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        query += ' AND CreatedDate <= ' + dtValue.addDays(1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        query += ' AND Payment_Method__c != \'Invoice\'';
        query += ' ORDER BY Name ASC LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('CO_Deposit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Deposit__c> coDepositList = Database.query(query);
        return coDepositList;
    }
    
    /**
     * Name: getPayrollList
     * Desc: To get all the Payroll records from Database by executing query
     * @return: List of Payroll records
    **/
    public static List<Sobject> getPayrollList(Map<String, String> fieldNameToFieldValueMap) {
        String query = 'SELECT '; 
        for(String fieldName : PayrollWrapper.getPayrollFieldsList()){
            query += fieldName + ', ';
        } 
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Payroll_Time__c ';
        Boolean isWhereClauseAdded = false;
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            if(String.isNotBlank(fieldNameToFieldValueMap.get(fieldName))) {
                if(!isWhereClauseAdded) {
                    query += 'WHERE ';
                    isWhereClauseAdded = true;
                } else {
                    query += 'AND ';
                }
                
                if(fieldName == 'Start_Date__c') {
                    query += fieldName + ' >= ' + fieldNameToFieldValueMap.get(fieldName) + ' ';
                } else if(fieldName == 'End_Date__c') {
                    query += fieldName + ' <= ' + fieldNameToFieldValueMap.get(fieldName) + ' ';
                } else {
                    query += fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
                }
            }
        }
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        //system.assert(false, query);
        
        if(AccessControl.ifObjectFieldIsAccessible('Payroll_Time__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Payroll_Time__c> payrollList = Database.query(query);
        return payrollList;
    }
    
    /**
     * Name: getPayrollList
     * Desc: To get all the Payroll records from Database by executing query
     * @return: List of Payroll records
    **/
    public static List<Sobject> getTechnicianListWithPayroll(Map<String, String> fieldNameToFieldValueMap) {
        String query = 'SELECT '; 
        for(String fieldName : SOHeaderWrapper.getTechnicianFieldsList()){
            query += fieldName + ', ';
        }
        
        // Child Query
        query += '(SELECT ';
        for(String fieldName : PayrollWrapper.getPayrollFieldsList()){
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Payroll_Times__r WHERE Start_Date__c != null AND ' +  // CreatedDate = today
                                                ' End_Date__c = NULL Order by CreatedDate DESC LIMIT 1)' ;
        query += ' FROM ' + Constants.NAMESPACE + 'Technician__c WHERE Active__c = true ';
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            query += ' AND '+ fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' '; 
        }
        query += ' ORDER BY Technician_Name__c ASC ';
        query += ' LIMIT ' + getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('Payroll_Time__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Technician__c> technicianList = Database.query(query);
        return technicianList;
    }
    
    /**
     * Name: getCOInvoiceItemByFieldName
     * Desc: To get Alternate part records list
     * @param:  List<Id> record Ids
     * @return: COInvoiceItem records list
     **/
    public static List<CO_Invoice_Item__c> getCOInvoiceItemByFieldName(Map<String, String> fieldNameToFieldValueMap) {
        String query;
        query = 'SELECT '; 
        for(String fieldName : COInvoiceItem.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';
        }
        
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Invoice_Item__c ';
        Boolean isWhereClauseAdded = false;
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            /*String fieldValue = '(';
            for(String value : fieldNameToFieldValueMap.get(fieldName)) {
                fieldValue += '\'' + value + '\',';
            }
            fieldValue = fieldValue.subString(0, (fieldValue.length() - 1)) + ')';*/
            if(isWhereClauseAdded) {
                query += ' AND ' + fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' '; 
            } else {
                query += ' WHERE ' + fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' '; 
                isWhereClauseAdded = true;
            }
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Item__c> coInvoiceItemList = Database.query(query);
        return coInvoiceItemList;
    }
    
    /**
     * Name: getCategories
     * Desc: To get all category list based on fields
     * @param:  categoryType
     * @return: Category__c list
     **/
    public static List<Category__c> getCategories(Map<String, String> fieldNameToFieldValueMap) {
        if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        String query = 'SELECT Id, Name, Active__c, Type__c, Default__c FROM ' + Constants.NAMESPACE + 'Category__c WHERE Active__c = true'; 
        
        for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += ' AND ' + fieldName + ' = \'' + fieldNameToFieldValueMap.get(fieldName) + '\' ';
        }
        return Database.query(query);
    }
    
    public static Map<Id, SObject> getOpenDealByDealId(Map<String, List<String>> fieldNameToFieldValuesMap, Boolean isGetDataFromLastSynchedDate) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        String query = 'SELECT ';
        for(String fieldName : CreateLeadWrapper.fieldsList()) {
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Deal__c where Status__c != \'Invoiced\'';
        if(isGetDataFromLastSynchedDate) {
            DateTime lastSyncDate = GeneralConfiguration.getDP360LastSynchedDate();
            query += ' AND (CreatedDate >= ' + lastSyncDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' OR LastModifiedDate >= ' +  + lastSyncDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' )';
        }
        for(String fieldName : fieldNameToFieldValuesMap.keySet()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            
            if(fieldNameToFieldValuesMap.get(fieldName) == null) {
                continue;
            }
            String fieldValueStr = '(';
            for(String fieldValue : fieldNameToFieldValuesMap.get(fieldName)){
                if(fieldValue != null){
                    fieldValueStr += '\'' + fieldValue + '\'' + ',';
                }
            }
            fieldValueStr = fieldValueStr.subString(0, fieldValueStr.length() - 1);
            if(fieldValueStr.length() > 1) {
                fieldValueStr += ')';
            }
            
            if(fieldValueStr.length() > 2){
                query += ' AND '+ fieldName + ' IN ' + fieldValueStr;
            }
        }
        query += ' Order by LastModifiedDate DESC LIMIT 10';
        return new Map<Id, SObject>(Database.query(query));
    }    
    
    public static Map<Id, SObject> getDealItemForCOU(Map<String, List<String>> fieldNameToFieldValuesMap) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        String query = 'SELECT Deal__c, Customer_Owned_Unit__r.VIN_Number__c, Deal__r.CO_Header__r.Customer__r.Email__c FROM Deal_Item__c where ';
        
        
        for(String fieldName : fieldNameToFieldValuesMap.keySet()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            
            if(fieldNameToFieldValuesMap.get(fieldName) == null) {
                continue;
            }
            String fieldValueStr = '(';
            for(String fieldValue : fieldNameToFieldValuesMap.get(fieldName)){
                if(fieldValue != null){
                    fieldValueStr += '\'' + fieldValue + '\'' + ',';
                }
            }
            fieldValueStr = fieldValueStr.subString(0, fieldValueStr.length() - 1);
            if(fieldValueStr.length() > 1) {
                fieldValueStr += ')';
            }
            
            if(fieldValueStr.length() > 2){
                query +=  fieldName + ' IN ' + fieldValueStr + ' AND ';
            }
        }
        query = query.substring(0,query.length()-4);
        return new Map<Id, SObject>(Database.query(query));
    }
}