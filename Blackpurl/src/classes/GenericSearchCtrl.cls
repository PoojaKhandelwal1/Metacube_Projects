public without sharing class GenericSearchCtrl {
    
    public static String getSearchResults(String searchQueryJsonStr) {
        searchQueryJsonStr = BPUtility.getDecodedString(searchQueryJsonStr);
        GenericSearchUtil.QueryJSON searchObj = (GenericSearchUtil.QueryJSON) system.JSON.deserialize(searchQueryJsonStr, GenericSearchUtil.QueryJSON.class);
        
        // Get Configurations for Searching
        List<Search_Configuration__mdt> searchConfigList = getSearchConfigurations(searchObj.SearchableObjects, (searchObj.IsSpecialSearch != null ? searchObj.IsSpecialSearch : false));
        
        Map<String, Search_Configuration__mdt> objNameToSearchConfigRecMap = new Map<String, Search_Configuration__mdt>();
        for(Search_Configuration__mdt searchConfigRec : searchConfigList) {
            objNameToSearchConfigRecMap.put(searchConfigRec.Label, searchConfigRec);
        }
        
        Map<String, List<Sobject>> objNameToSearchRecordListMap = 
                    getSearchingRecord(searchObj.ObjectLabel, searchObj.SearchText, searchObj.FilterValues, searchConfigList);
        
        // Apply sorting
        List<GenericSearchUtil.SearchedSObjectWrapper> searchedResultsToSortList = 
                    GenericSearchSorting.sortSearchedResults(objNameToSearchRecordListMap, searchObj.SearchText, objNameToSearchConfigRecMap);
        //system.assert(false, searchedResultsToSortList.size());
        // Create Return JSON
        String searchJSONString = createJSON(searchedResultsToSortList, objNameToSearchConfigRecMap);
        return searchJSONString;
    }
    
    public static List<GenericSearchUtil.SearchedSObjectWrapper> getGobalSearchResults(GenericSearchUtil.QueryJSON searchObj, String keyWordName) {
        // Get Configurations for Searching
        List<Search_Configuration__mdt> searchConfigList = getSearchConfigurations(searchObj.SearchableObjects, false);
        
        Map<String, Search_Configuration__mdt> objNameToSearchConfigRecMap = new Map<String, Search_Configuration__mdt>();
        for(Search_Configuration__mdt searchConfigRec : searchConfigList) {
            objNameToSearchConfigRecMap.put(searchConfigRec.Label, searchConfigRec);
        }
        
        Map<String, List<Sobject>> objNameToSearchRecordListMap = 
                    getSearchingRecord(searchObj.ObjectLabel, searchObj.SearchText, searchObj.FilterValues, searchConfigList);
        List<SObject> vendorRecordsList = new List<SObject>();
        if(objNameToSearchRecordListMap.containsKey('Account')) {
        	List<SObject> accountRecordsList = objNameToSearchRecordListMap.get('Account');
        	for(Integer counter = 0; counter < accountRecordsList.size(); counter++) {
	            if((String.valueOf(accountRecordsList[counter].get(Constants.NAMESPACE +'Is_Customer__c')) == 'true') &&
	                         (String.valueOf(accountRecordsList[counter].get(Constants.NAMESPACE +'Is_Vendor__c')) == 'true')) {
	                         	
	                if(String.isNotBlank(keyWordName)) {
	                	if(keyWordName == 'Customers') {
	                		accountRecordsList[counter].put(Constants.NAMESPACE +'Is_Vendor__c', false);
	                	} else if(keyWordName == 'Vendors') {
	                		accountRecordsList[counter].put(Constants.NAMESPACE +'Is_Customer__c', false);
	                	}
	                } else {
	                	SObject vendor = accountRecordsList[counter].clone(true, true);
		                vendor.put(Constants.NAMESPACE +'Is_Customer__c', false);
		                vendorRecordsList.add(vendor);
		                accountRecordsList[counter].put(Constants.NAMESPACE +'Is_Vendor__c', false);
	                }
	            }
	        }
	        accountRecordsList.addAll(vendorRecordsList);
	        objNameToSearchRecordListMap.put('Account', accountRecordsList);
        }
        // Apply sorting
        List<GenericSearchUtil.SearchedSObjectWrapper> searchedResultsToSortList = 
                    GenericSearchSorting.sortSearchedResults(objNameToSearchRecordListMap, searchObj.SearchText, objNameToSearchConfigRecMap);
        //system.assert(false, searchedResultsToSortList.size());
        return searchedResultsToSortList;
    }
    
    private static Set<String> searchConfigFieldSet = new Set<String> {'Searchable_Field_Set__c',
                                                                         'Order__c',
                                                                         'Label',
                                                                         'Additional_Fields_To_Query__c',
                                                                         'Display_Field_Name__c',
                                                                         'Additional_Info_To_Display__c',
                                                                         'Fixed_Where_Clause__c'
                                                                        };
                                                                        
    private static List<Search_Configuration__mdt> getSearchConfigurations(String searchableObjects, Boolean isSpecialSearch) {
        List<String> objectList = new List<String>();
        if(searchableObjects != null && searchableObjects.trim().length() > 0){
            for(String objName : searchableObjects.split(',')) {
                objectList.add(GenericSearchUtil.getObjectAPIName(objName));
            }
        }
        
        String configQuery = 'SELECT ';
        for(String searchableField : searchConfigFieldSet) {
            configQuery += searchableField + ',';
        }
        configQuery = configQuery.subString(0, configQuery.length() - 1);
        configQuery += ' FROM Search_Configuration__mdt ';
        if(objectList.size() > 0) {
            configQuery += + 'WHERE Label IN: objectList';
        }
        if(!isSpecialSearch) {
        	if(configQuery.contains('WHERE')) {
            	configQuery += ' AND Is_Special_Search__c = false';
        	} else {
        		configQuery += ' WHERE Is_Special_Search__c = false';
        	}
        }
        List<Search_Configuration__mdt> searchConfigList = Database.query(configQuery);
        return searchConfigList;
    }
    
    public static Map<String, List<Sobject>> getSearchingRecord(String objectName, String searchText, List<GenericSearchUtil.FilterJSON> filterValues, List<Search_Configuration__mdt> searchConfigList) {
        Map<String, List<Sobject>> objNameToSearchRecordListMap = new Map<String, List<Sobject>>();
        searchText = (searchText != null) ? searchText : '';
        //searchText = SOSLUtil.formatTextValueToBeSearched(searchText);
        searchText = String.escapeSingleQuotes(searchText);
        String query = '';
        for(Search_Configuration__mdt searchConfig : searchConfigList) {
            query = getSOQLQuery(searchConfig, searchText, filterValues);
            //system.assert(false, query + '  ' + query);
            List<sObject> resultRecords = (List<sObject>)Database.query(query);
            objNameToSearchRecordListMap.put(searchConfig.Label, resultRecords);
        }
        
        return objNameToSearchRecordListMap;
    }
    
    private static String getSOQLQuery(Search_Configuration__mdt searchConfig, String searchText, List<GenericSearchUtil.FilterJSON> filterList) {
        String query = 'SELECT ';
        if(String.isNotBlank(searchConfig.Searchable_Field_Set__c)) {
            query += searchConfig.Searchable_Field_Set__c + ',';
        }
        if(String.isNotBlank(searchConfig.Additional_Fields_To_Query__c)) {
            query += searchConfig.Additional_Fields_To_Query__c + ',';
        }
        query = query.subString(0, query.length() - 1);
        query += ' FROM ' + GenericSearchUtil.getObjectAPIName(searchConfig.Label);
        query += getWhereClause(searchText, searchConfig, filterList);
        query += ' ORDER BY LastModifiedDate DESC LIMIT ' + SOQLUtil.getAvailableQueryRowsLimit();
        return query;
    }
    
    
    public static String getWhereClause(String searchText, Search_Configuration__mdt searchConfig, List<GenericSearchUtil.FilterJSON> filterList) {
        String whereClause = getFilterClause(searchText, searchConfig.Fixed_Where_Clause__c, filterList, searchConfig.Label);
        String containsClause = getContainsClause(searchText, searchConfig);
        
        if(String.isNotBlank(whereClause) && String.isNotBlank(containsClause)) {
            whereClause = whereClause + ' AND ' + containsClause;
        } else if(String.isBlank(whereClause) && String.isNotBlank(containsClause)) {
            whereClause = ' WHERE ' + containsClause;
        }
        return whereClause;
    }
    
    
    public static String getFilterClause(String searchText, String fixedWhereClause, List<GenericSearchUtil.FilterJSON> filterList, String objName) {
        String whereClause = '';
        for(GenericSearchUtil.FilterJSON fieldFilter : filterList) {
            if(fieldFilter.FilterObject.equalsIgnoreCase(objName)) {
	            whereClause += (String.isBlank(whereClause)) ? ' WHERE ' : ' AND ';
	            if(fieldFilter.Field != null && fieldFilter.Field.trim().length() > 0) {
	                String filterFieldName = fieldFilter.Field;
	                whereClause += (fieldFilter.Field + ' ' + fieldFilter.Operator + ' ' + fieldFilter.Value);
	            } else {
	                whereClause += fieldFilter.Value;
	            }
            }
        }
        whereClause += (String.isNotBlank(fixedWhereClause)) ? ((whereClause.contains('WHERE')) ? ' AND ' : ' WHERE ') + fixedWhereClause : '';
        
        return whereClause;
    }
    
    public static String getContainsClause(String searchText, Search_Configuration__mdt searchConfig) {
        List<GenericSearchUtil.FieldFilter> fieldFilterList = new List<GenericSearchUtil.FieldFilter>();
        
        if(String.isNotBlank(searchText)) {
            List<String> searchTextList = searchText.split(' ');
            List<String> textFieldsList = new List<String>();
            if(String.isNotBlank(searchConfig.Searchable_Field_Set__c)) {
                textFieldsList.addAll(searchConfig.Searchable_Field_Set__c.split(','));
            }
            for(String searchTexSubStr : searchTextList) {
                if(searchTexSubStr.length() >= GenericSearchUtil.MIN_SEARCH_CHAR_TO_SEARCH) {
		            for(String textFieldStr : textFieldsList) {
		                fieldFilterList.add(new GenericSearchUtil.FieldFilter(textFieldStr, 'Like', '\'%' + searchTexSubStr + '%\''));
		            }
                }
            }
        }
        
        String containsClause = '( ';
        for(GenericSearchUtil.FieldFilter fieldFilterRec : fieldFilterList) {
            containsClause += fieldFilterRec.FieldName + ' ' + fieldFilterRec.Operator + ' ' + fieldFilterRec.FieldValue + ' OR ';
        }
        if(fieldFilterList.size() == 0 || containsClause.length() <= 2) {
            containsClause = '';
        } else {
            containsClause = containsClause.substring(0, containsClause.length() - 3);
            containsClause += ')';
        }
        return containsClause;
    }
    
    public static String createJSON(List<GenericSearchUtil.SearchedSObjectWrapper> searchedResultsToSortList, Map<String, Search_Configuration__mdt> objNameToSearchConfigRecMap) {
        List<GenericSearchResultsWrapper> suggestionRecords = new List<GenericSearchResultsWrapper>();
        
        Integer counter = 0;
        if(searchedResultsToSortList.size() > 0) {
            for(GenericSearchUtil.SearchedSObjectWrapper resultWrapperRecord : searchedResultsToSortList) {
            	if(resultWrapperRecord.objectName == 'Service_Order_Header__c' && (((List<LookedUpFromActivity>) resultWrapperRecord.SearchedObj.getSobjects('Activities__r')) != null && 
            		(((List<LookedUpFromActivity>) resultWrapperRecord.SearchedObj.getSobjects('Activities__r')).size() > 0))) {
            		continue;
            	}
            	
                suggestionRecords.add(new GenericSearchResultsWrapper(resultWrapperRecord, objNameToSearchConfigRecMap.get(resultWrapperRecord.objectName)));
                counter++;
                if(counter == GenericSearchUtil.MAX_RECORDS_TO_DISPLAY) {
                    break;
                }
            }
        }
        return system.JSON.serialize(suggestionRecords, true);
    }
}