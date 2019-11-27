/**
 * Author: Richa Mittal
 * Since: August 12, 2016
 * Name: GlobalSearchCtrl
 * Description: Controller class to handle methods for global Search
**/
global with sharing class GlobalSearchCtrl {
    
    
    public Static Integer MAX_RECORDS_TO_DISPLAY = 5;
    
    @RemoteAction 
    global static String getGlobalSearchResult(String searchQueryJson) {
        searchQueryJson = BPUtility.getDecodedString(searchQueryJson);
        GlobalSearchResultsWrapper.GlobalQueryJSON globalQueryJSON = (GlobalSearchResultsWrapper.GlobalQueryJSON)System.JSON.deserialize(searchQueryJson, GlobalSearchResultsWrapper.GlobalQueryJSON.class);
        GenericSearchUtil.QueryJSON queryJSON= new GenericSearchUtil.QueryJSON();
        queryJSON.SearchText = globalQueryJSON.GlobalSearchText;
        queryJSON.SearchableObjects = '';
        queryJSON.FilterValues = new List<GenericSearchUtil.FilterJSON>();
        
        String objectAPIName = '';
        
        Set<String> objectNameSetToSearch = displayObjectNameToObjectAPINameMap.keySet();
        List<String> objectNameListToSearch = HomeSearchUtil.filterListBasedOnPermissions(new List<String>(objectNameSetToSearch), HomeSearchUtil.objectNameToPermissionNameMap);       
        for(String objectName : objectNameListToSearch) {
            if(objectName != 'People' && (String.isBlank(globalQueryJSON.GlobalSearchKeyword) || (String.isNotBlank(globalQueryJSON.GlobalSearchKeyword) && 
                            (((globalQueryJSON.GlobalSearchKeyword).equalsIgnoreCase(objectName) || (displayObjNameDuplicateObjNameMap.containsKey(globalQueryJSON.GlobalSearchKeyword) && objectName == displayObjNameDuplicateObjNameMap.get(globalQueryJSON.GlobalSearchKeyword))))))) {
                objectAPIName = displayObjectNameToObjectAPINameMap.get(objectName);
                queryJSON.SearchableObjects += objectAPIName + ',';
                
                if(String.isNotBlank(globalQueryJSON.GlobalSearchKeyword) && objectName == 'Customers') {
                    queryJSON.FilterValues.add(new GenericSearchUtil.FilterJSON('Is_Customer__c', '=', 'true', 'Account'));
                } else if(String.isNotBlank(globalQueryJSON.GlobalSearchKeyword) && objectName == 'Vendors') {
                    queryJSON.FilterValues.add(new GenericSearchUtil.FilterJSON('Is_Vendor__c', '=', 'true', 'Account'));
                }
               
                if(String.isNotBlank(globalQueryJSON.GlobalSearchKeywordKey) 
                    && (globalQueryJSON.GlobalSearchKeywordKey.equalsIgnoreCase('skit')
                        || globalQueryJSON.GlobalSearchKeywordKey.equalsIgnoreCase('Service Kit'))){
                        queryJSON.FilterValues.add(new GenericSearchUtil.FilterJSON('Service_Kit__c', '=', 'true', 'Kit_Header__c'));
                }
            }
        }
        queryJSON.SearchableObjects = queryJSON.SearchableObjects.subString(0, queryJSON.SearchableObjects.length() - 1);
        List<GenericSearchUtil.SearchedSObjectWrapper> sortedResults = GenericSearchCtrl.getGobalSearchResults(queryJSON, globalQueryJSON.GlobalSearchKeyword);
        List<SObject> searchedResultsList = new List<SObject>();
        for(Integer counter=0; counter<MAX_RECORDS_TO_DISPLAY && counter<sortedResults.size() ; counter++){
            searchedResultsList.add(sortedResults[counter].SearchedObj);
        }
        GlobalSearchResultsWrapper globalSearchResults = new GlobalSearchResultsWrapper(sortedResults.size(), searchedResultsList);
        return BPUtility.getEncodedString(System.JSON.serialize(globalSearchResults, true));
    }
    
    /**
     * Name: getGlobalSearchResults
     * Description: Function get records for the search
     * @Param: 
     * @Return: String - Search List String 
    **/
    @RemoteAction 
    global static String getGlobalSearchResults(String searchQueryJson) {
        searchQueryJson = BPUtility.getDecodedString(searchQueryJson);
        GlobalSearchResultsWrapper.GlobalQueryJSON globalQueryJSON = (GlobalSearchResultsWrapper.GlobalQueryJSON)System.JSON.deserialize(searchQueryJson, GlobalSearchResultsWrapper.GlobalQueryJSON.class);
        
        // serach text entered by the user
        String searchText = globalQueryJSON.GlobalSearchText; 
        
        // keyword to search given by the user
        String searchKeyword = globalQueryJSON.GlobalSearchKeyword;
        // List to Hold all the query record
        List<Sobject> searchedResultsList = new List<Sobject>();
        // query to SOQL records
        String query;
        // variable to Hold object API Name
        String objectAPIName;
        
        Set<String> objectNameSetToSearch = displayObjectNameToObjectAPINameMap.keySet();
        List<String> objectNameListToSearch = HomeSearchUtil.filterListBasedOnPermissions(new List<String>(objectNameSetToSearch), HomeSearchUtil.objectNameToPermissionNameMap);       
        for(String objectName : objectNameListToSearch){ // objectNameSetToSearch
            /*if(objectName == 'People' || (searchKeyword != null && searchKeyword != '' && !searchKeyword.equalsIgnoreCase(objectName))){
                continue;
            }*/
            
            if(objectName != 'People' && (String.isBlank(searchKeyword) || (String.isNotBlank(searchKeyword) && 
                            ((searchKeyword.equalsIgnoreCase(objectName) || (displayObjNameDuplicateObjNameMap.containsKey(searchKeyword) && objectName == displayObjNameDuplicateObjNameMap.get(searchKeyword))))))) {
                objectAPIName = displayObjectNameToObjectAPINameMap.get(objectName);
                query = 'SELECT '; 
                for(String fieldsName : HomeSearchUtil.searchableObjectToFieldsMap.get(objectAPIName)){
                    fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                    query += fieldsName + ', ';
                }
                
                String objectAPINameforQuery;
                if(objectAPIName.indexOf((Constants.NAMESPACE).toLowerCase()) == -1 && objectAPIName.indexOf('__c') != -1) {
                    objectAPINameforQuery = Constants.NAMESPACE + objectAPIName;
                }else{
                    objectAPINameforQuery = objectAPIName;
                }
                
                
                query = query.substring(0, query.length()-2);
                query += ' FROM ' + objectAPINameforQuery;
                
                // Start: Ticket#108: Added by Hitesh 26-09-2016
                if(!String.isBlank(searchText)) {
                    List<String> searchTextList = searchText.split(' ');
                    for(Integer i=0; i<searchTextList.size(); i++ ){
                        if(!String.isBlank(searchTextList[i].trim())){
                            if(i == 0){
                                query += ' WHERE '+ HomeSearchReportInterface.getContainsCondition(objectName, searchTextList[i].trim());
                            }else{
                                query += ' AND '+ HomeSearchReportInterface.getContainsCondition(objectName, searchTextList[i].trim());
                            }
                        }
                    }
                }
                //query += ' WHERE '+ HomeSearchReportInterface.getContainsCondition(objectName, searchText);
                // End: Ticket#108: Added by Hitesh 26-09-2016
                
                //System.assert(false, query);
                System.debug(query);
                if(objectName == 'Customers') {
                    query += 'AND (Is_Customer__c = true) '; 
                }else if(objectName == 'Vendors'){
                        query += 'AND (Is_Vendor__c = true) '; 
                }
               
                if(!String.isBlank(globalQueryJSON.GlobalSearchKeywordKey) 
                    && (globalQueryJSON.GlobalSearchKeywordKey.equalsIgnoreCase('skit')
                        || globalQueryJSON.GlobalSearchKeywordKey.equalsIgnoreCase('Service Kit'))){
                        query += query.containsIgnoreCase('where') ? ' AND Service_Kit__c = true ' : ' Where Service_Kit__c = true ';
                }
                 
                // Added by TK - To exclude Inactive Records
                if(BPUtility.objectAPINameToActiveFlagAPIName.containsKey(objectAPINameforQuery)) {
                    query += query.containsIgnoreCase('where') ? (' AND ' + BPUtility.objectAPINameToActiveFlagAPIName.get(objectAPINameforQuery) + ' = TRUE ') 
                                : (' WHERE ' + BPUtility.objectAPINameToActiveFlagAPIName.get(objectAPINameforQuery) + ' = TRUE ');
                }
                
                 
                /*query += ' ORDER BY Default__c DESC, Name__c ASC';*/
                if(AccessControl.ifObjectFieldIsAccessible(objectAPIName) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                searchedResultsList.addAll((List<Sobject>)Database.query(query));
            }
        }
        
        // Sorting Code START HERE
        List<HSSObjectInstance> HSSObjectList = sortSobjectList(searchedResultsList);
        //System.assert(false, HSSObjectList);
        searchedResultsList = new List<Sobject>();
        Set<String> recordIdSet = new Set<String>();
        for(Integer i=0; i<MAX_RECORDS_TO_DISPLAY && i<HSSObjectList.size() ; i++){
            if(!recordIdSet.contains(String.valueOf(HSSObjectList[i].record.get('Id')))) {
                recordIdSet.add(String.valueOf(HSSObjectList[i].record.get('Id')));
                
                if(String.isNotBlank(searchKeyword) && searchKeyword == 'Vendors' && String.valueOf(HSSObjectList[i].record.get(Constants.NAMESPACE +'Is_Customer__c')) == 'true') {
                    HSSObjectList[i].record.put(Constants.NAMESPACE +'Is_Customer__c', false);
                } else if(String.isNotBlank(searchKeyword) && searchKeyword == 'Customers' && String.valueOf(HSSObjectList[i].record.get(Constants.NAMESPACE +'Is_Vendor__c')) == 'true') {
                    HSSObjectList[i].record.put(Constants.NAMESPACE +'Is_Vendor__c', false);
                }
            searchedResultsList.add(HSSObjectList[i].record);
                
            } else if(String.valueOf(HSSObjectList[i].record.getSObjectType()) == 'Account' && (String.valueOf(HSSObjectList[i].record.get(Constants.NAMESPACE +'Is_Customer__c')) == 'true') &&
                         (String.valueOf(HSSObjectList[i].record.get(Constants.NAMESPACE +'Is_Vendor__c')) == 'true')){
                HSSObjectList[i].record.put(Constants.NAMESPACE +'Is_Customer__c', false);
                searchedResultsList.add(HSSObjectList[i].record);
            }
        }
        // Sorting Code END HERE
        
        //System.assert(false, searchedResultsList);
        // List to return the result 
        GlobalSearchResultsWrapper globalSearchResults = new GlobalSearchResultsWrapper(HSSObjectList.size(), searchedResultsList);
        return BPUtility.getEncodedString(System.JSON.serialize(globalSearchResults));
    }
    
    /**
     * Name: sortSobjectList
     * Description: Function to Sort the list of sObjects
     * @Param: List<Sobject> sObjectList
     * @Return: List<HSSObjectInstance> - HSSObjectInstance List 
    **/
    private static List<HSSObjectInstance> sortSobjectList(List<Sobject> sObjectList){
        List<HSSObjectInstance> HSSObjectList = new List<HSSObjectInstance>();
        for(Sobject sObj : sObjectList) {
            HSSObjectList.add(new HSSObjectInstance(sObj));
        }
        if(HSSObjectList.size() > 0){
            HSSObjectList.sort();
        }
        return HSSObjectList;
    }
    
    
    public static Map<String, String> displayObjectNameToObjectAPINameMap = new Map<String, String>{'People'            => 'Account',
                                                                                                    'Customers'         => 'Account',
                                                                                                    'Vendors'           => 'Account',
                                                                                                    'Parts'             => 'Part__c',
                                                                                                    'Kits'              => 'Kit_Header__c',
                                                                                                    'Fees'              => 'Fee__c',
                                                                                                    'Labor Codes'       => 'Labour_Code__c',
                                                                                                    'Vendor Product'            => 'Product__c', // Sublets -> Vendor Products
                                                                                                    'Users'             => 'User',
                                                                                                    'Employees'         => 'Technician__c',
                                                                                                    'Customer Orders'   => 'CO_Header__c',
                                                                                                    'Customer Invoices' => 'CO_Invoice_Header__c',
                                                                                                    //'Customer Payments' => 'CO_Invoice_Payment__c',
                                                                                                    'Vendor Orders'     => 'Vendor_Order_Header__c',
                                                                                                    'Vendor Return' => 'Return_VO_Header__c',
                                                                                                    'Vendor Receivings' => 'Vendor_Receiving_Header__c',
                                                                                                    'Vendor Invoices'   => 'Vendor_Invoicing_Header__c',
                                                                                                    'Item Categories'   => 'Category__c',
                                                                                                    'Price Levels'      => 'Price_Level__c',
                                                                                                    'Sales Taxes'       => 'Sales_Tax__c',
                                                                                                    'Inventory Unit'   => 'Customer_Owned_Unit__c' //Added by Pooja 8 Dec. 2016
                                                                                                };
    
    public static Map<String, String> displayObjNameDuplicateObjNameMap = new Map<String, String>{'Vendor Orders' => 'Vendor Return'
                                                                                                };
}