public with sharing class GenericSearchSorting {
    
    public static List<GenericSearchUtil.SearchedSObjectWrapper> sortSearchedResults(Map<String, List<Sobject>> objNameToSearchRecordListMap, String searchString, 
                                                            Map<String, Search_Configuration__mdt> objNameToSearchConfigRecMap) {
        String objName = '';
        List<GenericSearchUtil.SearchedSObjectWrapper> sortedList = new List<GenericSearchUtil.SearchedSObjectWrapper>();
        system.debug('objNameToSearchRecordListMap \n\n\n' + objNameToSearchRecordListMap);
        for(String objectName : objNameToSearchRecordListMap.keySet()) {
        	Search_Configuration__mdt searchConfig = new Search_Configuration__mdt();
        	if(objNameToSearchConfigRecMap.containsKey(objectName)) {
        	    searchConfig = objNameToSearchConfigRecMap.get(objectName);
        	}
        	List<String> fieldNameList = getSearchableFieldNameList(searchConfig, objectName, objNameToSearchConfigRecMap);
        	
            for(Sobject searchedRec : objNameToSearchRecordListMap.get(objectName)) {
                setPriority(sortedList, searchedRec, setMatchingCriteriaToMatchedResultsMap(fieldNameList, searchString, searchedRec), searchConfig);
            }
        }
        sortedList.sort();
        return sortedList;
    }
    
    private static List<String> getSearchableFieldNameList(Search_Configuration__mdt searchConfig, String objectName, 
                                                            Map<String, Search_Configuration__mdt> objNameToSearchConfigRecMap) {
        List<String> fieldNameList = new List<String>();
        if(objNameToSearchConfigRecMap.containsKey(objectName)) {
            if(String.isNotBlank(searchConfig.Searchable_Field_Set__c)) {
                fieldNameList.addAll(searchConfig.Searchable_Field_Set__c.split(','));
            }
        }
        return fieldNameList;
    }
    
    private static Map<String, Boolean> setMatchingCriteriaToMatchedResultsMap(List<String> fieldNameList, String searchString, Sobject searchedRec) {
        Map<String, Boolean> matchingCriteriaToMatchedResultsMap = new Map<String, Boolean>();
        for(Integer counter = 0; counter < fieldNameList.size(); counter++) {
            String fieldAPIName = fieldNameList[counter];
            String fieldValue;
            if(fieldAPIName.contains('.')) {
                List<String> subList = fieldAPIName.split('\\.');
                if(subList.size() == 2) {
                    fieldValue = searchedRec.getSobject(subList[0]) != null && searchedRec.getSobject(subList[0]).get(subList[1]) != null ? 
                                (String.valueOf(searchedRec.getSobject(subList[0]).get(subList[1]))) : null;
                }
            } else {
                fieldValue = (searchedRec.get(fieldAPIName) != null) ? (String.valueOf(searchedRec.get(fieldAPIName))) : null;
            }
            if(fieldValue != null) {
                if(fieldValue.equalsIgnoreCase(searchString)) {
                    matchingCriteriaToMatchedResultsMap.put('Exact', true);
                    break;
                } else if(fieldValue.startsWithIgnoreCase(searchString)) {
                    matchingCriteriaToMatchedResultsMap.put('StartsWith', true);
                } else if(fieldValue.containsIgnoreCase(searchString)) {
                    matchingCriteriaToMatchedResultsMap.put('Contains', true);
                } else {
                    List<String> searchTextBlockList = new List<String>();
			        if(String.isNotBlank(searchString)) {
			            searchTextBlockList = searchString.split(' ');
			        }
                    for(Integer loopCounter = 0; loopCounter < searchTextBlockList.size(); loopCounter++) {
			        	if(!GenericSearchUtil.matchingCriteriaPriorityList.contains('Block Exact'+(loopCounter+1))) {
			        		GenericSearchUtil.matchingCriteriaPriorityList.add('Block Exact'+(loopCounter+1));
			        	}
			        }
			        for(Integer loopCounter = 0; loopCounter < searchTextBlockList.size(); loopCounter++) {
			        	if(!GenericSearchUtil.matchingCriteriaPriorityList.contains('Block StartsWith'+(loopCounter+1))) {
			        		GenericSearchUtil.matchingCriteriaPriorityList.add('Block StartsWith'+(loopCounter+1));
			        	}
			        }
			        for(Integer loopCounter = 0; loopCounter < searchTextBlockList.size(); loopCounter++) {
			        	if(!GenericSearchUtil.matchingCriteriaPriorityList.contains('Block Contains'+(loopCounter+1))) {
			        		GenericSearchUtil.matchingCriteriaPriorityList.add('Block Contains'+(loopCounter+1));
			        	}
			        }
                    for(Integer loopCounter = 0; loopCounter < searchTextBlockList.size(); loopCounter++) {
                        String textBlockStr = searchTextBlockList[loopCounter].trim();
                        if(String.isNotBlank(textBlockStr) && textBlockStr.length() >= GenericSearchUtil.MIN_SEARCH_CHAR_TO_SEARCH) {
                            if(fieldValue.equalsIgnoreCase(textBlockStr)) {
                                matchingCriteriaToMatchedResultsMap.put('Block Exact'+(loopCounter+1), true);
                                break;
                            } else if(fieldValue.startsWithIgnoreCase(textBlockStr)) {
                                matchingCriteriaToMatchedResultsMap.put('Block StartsWith'+(loopCounter+1), true);
                            } else if(fieldValue.containsIgnoreCase(textBlockStr)) {
                                matchingCriteriaToMatchedResultsMap.put('Block Contains'+(loopCounter+1), true);
                            }
                        }
                    }
                }
            }
        }
        system.debug('Richa  --->>> \n\n'  + matchingCriteriaToMatchedResultsMap);
        return matchingCriteriaToMatchedResultsMap;
    }
    
    
    private static void setPriority(List<GenericSearchUtil.SearchedSObjectWrapper> sortedList, SObject searchRec, 
    											Map<String, Boolean> matchingCriteriaToMatchedResultsMap, Search_Configuration__mdt searchConfig) {
        Decimal entityOrderNumber = searchConfig.Order__c;
        if(searchConfig.Label == 'Account') {
        	if(String.valueOf(searchRec.get(Constants.NAMESPACE +'Is_Customer__c')) != 'true' && String.valueOf(searchRec.get(Constants.NAMESPACE +'Is_Vendor__c')) == 'true') {
        		entityOrderNumber = entityOrderNumber != null ? entityOrderNumber + 1 : 20000;
        	}
        }
        for(Integer counter = 0; counter < GenericSearchUtil.matchingCriteriaPriorityList.size(); counter++) {
            if(matchingCriteriaToMatchedResultsMap.containsKey(GenericSearchUtil.matchingCriteriaPriorityList[counter])) {
                sortedList.add( new GenericSearchUtil.SearchedSObjectWrapper(searchRec, 
                                getPriorityNumber(entityOrderNumber, (counter + 1)), searchConfig.Label));
                break;
            }
        }
    }
    
    // Make sure there will be no configuration with Order number blank
    private static Decimal getPriorityNumber(Decimal entityPriority, Integer matchingCriteriaPriority) {
    	return ((100 * matchingCriteriaPriority) + entityPriority);
    }
}