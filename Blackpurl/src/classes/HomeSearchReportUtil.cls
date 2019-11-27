/**
 * Author: Tarun Khandelwal
 * Since: April 15, 2016
 * Name: HomeSearchReportUtil
 * Description: Apex class to handle all operations related to Home Search Reporting Data
**/
public with sharing class HomeSearchReportUtil {
	
	public Static String NUMERIC_TYPE_1 = 'Number';
	public Static String NUMERIC_TYPE_2 = 'Currency';
	public Static Set<String> textFieldTypes = new Set<String>{'Text', 'Date'};
	public static String COUNT_RECORD_ALIASE = 'TotalRecords';
	public static String COUNT_RECORD_LABEL = 'Total Records';
	public static final Integer QUERY_LIMIT_RECORDS = 2000;
	
	public static Set<String> fieldLabelSet = new Set<String>();
	public static Map<String, String> fieldLabelToTypeMap = new Map<String, String>();
	
	public static String getReportingResult(HomeSearchFilterWrapper filterWrapperObj) {
		String seachableObject = HomeSearchUtil.getGenericObjectNameBySelectedObject(filterWrapperObj.Type.Objects);
		Boolean isGroup = checkForGroup(seachableObject);
		 
		Map<String, List<String>> objeNameToNumericFieldAPINameMap = new Map<String, List<String>>();
		List<AggregateResult> aggregateResultList = new List<AggregateResult>();
		Set<String> NumericFieldAPINameSet = new Set<String>();
		List<HomeSearchReportResultWrapper> hsResultWrapper = new List<HomeSearchReportResultWrapper>();
		fieldLabelSet.add(COUNT_RECORD_ALIASE);
		
		Map<String, String> objNameToWhereClauseMap = HomeSearchReportInterface.getWhereClauseForObjects(filterWrapperObj);
		//Map<String, List<HomeSearchFilterInterface.FieldFilter>> objNameToFieldFilterListMap = HomeSearchFilterInterface.getFilterList(filterWrapperObj);
		//List<HomeSearchFilterInterface.FieldFilter> filterList = objectFiltersMap.get(objName);
		
		Set<String> objectsSet = new Set<String>();
		for(String objectName : filterWrapperObj.Type.Objects) {
			objectsSet.add(objectName);
			if(objectsSet.contains('Customer Payments')) {
				objectsSet.add('Customer Deposits');
			}
			if(objectsSet.contains('Vendor Orders')) {
				objectsSet.add('Vendor Return');
			}
			if(objectsSet.contains('Invoiced Items')) {
				objectsSet.add('SOLI');
				objectsSet.add('Option and Fee');
			}
			if(objectsSet.contains('Tax Detail')) {
			    objectsSet.remove('Tax Detail');
			    if(filterWrapperObj.Tax_Detail_Invoice_Type == '0') {
	                objectsSet.add('Tax Detail Customer Invoices');
	                objectsSet.add('Tax Detail Vendor Invoices');
	            } else if(filterWrapperObj.Tax_Detail_Invoice_Type == 'Customer Invoice') {
	                objectsSet.add('Tax Detail Customer Invoices');
	            } else if(filterWrapperObj.Tax_Detail_Invoice_Type == 'Vendor Invoice') {
	                objectsSet.add('Tax Detail Vendor Invoices');
	            }
            }
		}
		
		if(!isGroup) {
			objeNameToNumericFieldAPINameMap = getNumericColumns(seachableObject, filterWrapperObj.IsSummaryFormat);
			if(objectsSet.contains('Customer Payments')) {
				if(objeNameToNumericFieldAPINameMap.containsKey('Customer Payments')) {
					objeNameToNumericFieldAPINameMap.put('Customer Deposits', objeNameToNumericFieldAPINameMap.get('Customer Payments'));
				}
			}
			
			if(objectsSet.contains('Vendor Orders')) {
				if(objeNameToNumericFieldAPINameMap.containsKey('Vendor Orders')) {
					objeNameToNumericFieldAPINameMap.put('Vendor Return', HomeSearchUtil.objectNameToNumericFieldApiNameMap.get('Vendor Return'));
				}
			}
			
			if(objectsSet.contains('Tax Detail Customer Invoices')) {
				if(HomeSearchUtil.objectToCommonNumericFieldLabelName.containsKey('Tax Detail Customer Invoices')) {
					objeNameToNumericFieldAPINameMap.put('Tax Detail Customer Invoices', HomeSearchUtil.objectToCommonNumericFieldAPIName.get('Tax Detail Customer Invoices'));
					for(Integer i = 0; i < HomeSearchUtil.objectToCommonNumericFieldLabelName.get('Tax Detail Customer Invoices').size(); i++) {
						fieldAPINameToFieldLabelMap.put(HomeSearchUtil.objectToCommonNumericFieldAPIName.get('Tax Detail Customer Invoices')[i], HomeSearchUtil.objectToCommonNumericFieldLabelName.get('Tax Detail Customer Invoices')[i]);
						fieldLabelSet.add(HomeSearchUtil.objectToCommonNumericFieldLabelName.get('Tax Detail Customer Invoices')[i]);
						fieldLabelToTypeMap.put(HomeSearchUtil.objectToCommonNumericFieldLabelName.get('Tax Detail Customer Invoices')[i], NUMERIC_TYPE_2);
					}
				}
			}
			
			if(objectsSet.contains('Tax Detail Vendor Invoices')) {
				if(HomeSearchUtil.objectToCommonNumericFieldLabelName.containsKey('Tax Detail Vendor Invoices')) {
					objeNameToNumericFieldAPINameMap.put('Tax Detail Vendor Invoices', HomeSearchUtil.objectToCommonNumericFieldAPIName.get('Tax Detail Vendor Invoices'));
					for(Integer i = 0; i < HomeSearchUtil.objectToCommonNumericFieldLabelName.get('Tax Detail Vendor Invoices').size(); i++) {
						fieldAPINameToFieldLabelMap.put(HomeSearchUtil.objectToCommonNumericFieldAPIName.get('Tax Detail Vendor Invoices')[i], HomeSearchUtil.objectToCommonNumericFieldLabelName.get('Tax Detail Vendor Invoices')[i]);
						fieldLabelSet.add(HomeSearchUtil.objectToCommonNumericFieldLabelName.get('Tax Detail Vendor Invoices')[i]);
						fieldLabelToTypeMap.put(HomeSearchUtil.objectToCommonNumericFieldLabelName.get('Tax Detail Vendor Invoices')[i], NUMERIC_TYPE_2);
					}
				}
			}
            
			if(objectsSet.contains('Invoiced Items')) {
				if(objeNameToNumericFieldAPINameMap.containsKey('Invoiced Items')) {
					Map<String, Map<String, Boolean>> permissionsMap = HomeSearchUtil.getUserPermissions();
	 				Boolean primaryPermission = permissionsMap.get('Costs').get('read only');
	 				if(!primaryPermission) {
	 					objeNameToNumericFieldAPINameMap.put('SOLI Without Permission', HomeSearchUtil.objectNameToNumericFieldApiNameMap.get('SOLI'));
						objeNameToNumericFieldAPINameMap.put('Option and Fee Without Permission', HomeSearchUtil.objectNameToNumericFieldApiNameMap.get('Option and Fee'));
	 				} else {
                        objeNameToNumericFieldAPINameMap.put('SOLI', HomeSearchUtil.objectNameToNumericFieldApiNameMap.get('SOLI'));
                        objeNameToNumericFieldAPINameMap.put('Option and Fee', HomeSearchUtil.objectNameToNumericFieldApiNameMap.get('Option and Fee'));
	 				}
					fieldAPINameToFieldLabelMap.put('Qty_Needed__c', 'Qty_Sold');
				}
			}
			for(String objName : objectsSet) {
				if(objeNameToNumericFieldAPINameMap.containsKey(objName)) {
					aggregateResultList.addAll(getAggregateResultByObjName(objName, objeNameToNumericFieldAPINameMap.get(objName), objNameToWhereClauseMap.get(objName)));
				} else {
					aggregateResultList.addAll(getAggregateResultByObjName(objName, new List<String>(), objNameToWhereClauseMap.get(objName)));
				}
				/*if(objName == 'Customer Payments') {
					if(objeNameToNumericFieldAPINameMap.containsKey(objName)) {
						aggregateResultList.addAll(getAggregateResultByObjName('Customer Deposits', objeNameToNumericFieldAPINameMap.get(seachableObject), objNameToWhereClauseMap.get(objName)));
					} else {
						aggregateResultList.addAll(getAggregateResultByObjName('Customer Deposits', new List<String>(), objNameToWhereClauseMap.get(objName)));
					}
				}*/
			}
		} else {
			if(seachableObject != Label.Generic_Object_Label) {
				for(String objName : filterWrapperObj.Type.Objects) {
					List<String> fieldAPINameList = HomeSearchUtil.objectToCommonNumericFieldAPIName.get(objName);
					
					for(Integer i = 0; i < fieldAPINameList.size(); i++) {
						fieldAPINameToFieldLabelMap.put(fieldAPINameList[i], HomeSearchUtil.objectToCommonNumericFieldLabelName.get(objName)[i]);
						fieldLabelSet.add(HomeSearchUtil.objectToCommonNumericFieldLabelName.get(objName)[i]);
						fieldLabelToTypeMap.put(HomeSearchUtil.objectToCommonNumericFieldLabelName.get(objName)[i], HomeSearchUtil.objectToCommonNumericFieldTypeMap.get(objName)[i]);
					}
					aggregateResultList.addAll(getAggregateResultByObjName(objName, HomeSearchUtil.objectToCommonNumericFieldAPIName.get(objName), objNameToWhereClauseMap.get(objName)));
					if(objName == 'Customer Payments') {	
                        aggregateResultList.addAll(getAggregateResultByObjName('Customer Deposits', HomeSearchUtil.objectToCommonNumericFieldAPIName.get(objName), objNameToWhereClauseMap.get('Customer Deposits')));
					}
					
					if(objName == 'Vendor Orders') {	
                        aggregateResultList.addAll(getAggregateResultByObjName('Vendor Return', HomeSearchUtil.objectToCommonNumericFieldAPIName.get('Vendor Return'), objNameToWhereClauseMap.get('Vendor Return')));
					}
					
					if(objName == 'Invoiced Items') {	
                        aggregateResultList.addAll(getAggregateResultByObjName('SOLI', HomeSearchUtil.objectToCommonNumericFieldAPIName.get('SOLI'), objNameToWhereClauseMap.get('SOLI')));
                        aggregateResultList.addAll(getAggregateResultByObjName('Option and Fee', HomeSearchUtil.objectToCommonNumericFieldAPIName.get('Option and Fee'), objNameToWhereClauseMap.get('Option and Fee')));
					}
				}
			} else {
				Set<String> objectSet = new Set<String>();
				if(filterWrapperObj.Type.Objects.size() == 0 || (filterWrapperObj.Type.Objects.size() == 1 && filterWrapperObj.Type.Objects.contains(Label.Generic_Object_Label))) {
					objectSet = HomeSearchUtil.displayObjectNameToTypeNumber.keySet();
				} else {
					objectSet = filterWrapperObj.Type.Objects;
				}
                
                Set<String> objectNameCheckforDuplicateSet = new Set<String>();
				for(String objName : objectSet) {
                    if(HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objName) == 'Account' ||
                        !objectNameCheckforDuplicateSet.contains(HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objName)))
                    {
						aggregateResultList.addAll(getAggregateResultByObjName(objName, new List<String>(), objNameToWhereClauseMap.get(objName)));
						if(objName == 'Customer Payments') {
								aggregateResultList.addAll(getAggregateResultByObjName('Customer Deposits', new List<String>(), objNameToWhereClauseMap.get('Customer Deposits')));
						}
						if(objName == 'Vendor Orders') {
								aggregateResultList.addAll(getAggregateResultByObjName('Vendor Return', new List<String>(), objNameToWhereClauseMap.get('Vendor Return')));
						}
						if(objName == 'Invoiced Items') {
							aggregateResultList.addAll(getAggregateResultByObjName('SOLI', new List<String>(), objNameToWhereClauseMap.get('SOLI')));
							aggregateResultList.addAll(getAggregateResultByObjName('Option and Fee', new List<String>(), objNameToWhereClauseMap.get('Option and Fee')));
						}
	                    objectNameCheckforDuplicateSet.add(HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objName));
					}
				}
			}
		}
		hsResultWrapper = getWrapperList(fieldLabelSet, aggregateResultList);
		String objNameSelected = HomeSearchUtil.getGenericObjectNameBySelectedObject(filterWrapperObj.Type.Objects);
		List<HomeSearch_Grid_Column__mdt> hsColumnsSetting = CustomMetadataTypeUtil.getGridColumnsMetadataTypeSettings(objNameSelected);
		for(HomeSearch_Grid_Column__mdt hsColumn : hsColumnsSetting) {
			if((textFieldTypes.contains(hsColumn.Type__c) || (hsColumn.Label == 'Item' && hsColumn.Type__c == 'Link')
				|| (objectsSet.contains('Invoiced Items') && hsColumn.Label == 'Type' && hsColumn.Type__c == 'Icon')) && hsColumn.Field_API_Name__c != null) {
				hsResultWrapper.add(new HomeSearchReportResultWrapper(null, hsColumn.Label.replaceAll(' ', '_'), hsColumn.Type__c));
			}
		}
		return system.Json.serialize(hsResultWrapper);
	} 
	
	private static List<HomeSearchReportResultWrapper> getWrapperList(Set<String> fieldLabelNameSet, List<AggregateResult> aggregateResultList) {
		List<HomeSearchReportResultWrapper> hsResultWrapper = new List<HomeSearchReportResultWrapper>();
		for(String fieldLabelName : fieldLabelNameSet) {
			Decimal value = 0;
			for(AggregateResult aggregate : aggregateResultList) {
				try {
					if(aggregate.get(fieldLabelName) != null) {
						value += (Decimal)aggregate.get(fieldLabelName);
					}
				} catch(exception e) {
					
				}
			}
			hsResultWrapper.add(new HomeSearchReportResultWrapper(value, fieldLabelName, fieldLabelToTypeMap.get(fieldLabelName)));
		}
		return hsResultWrapper;
	}
	
	private static Boolean checkForGroup(String objName) {
		Boolean isGroup = false;
		if(HomeSearchUtil.groupNameToGroupObjectsMap.containsKey(objName) || objName == Label.Generic_Object_Label) {
			isGroup = true;
		}
		return isGroup;
	}
	
	private static Map<String, String> fieldAPINameToFieldLabelMap = new Map<String, String>();
	
	private static Map<String, List<String>> getNumericColumns(String objName, Boolean isSummaryFormat) {
		Map<String, List<String>> objeNameToNumericFieldAPINameMap = new Map<String, List<String>>();
		List<HomeSearch_Grid_Column__mdt> hsColumnsSetting = CustomMetadataTypeUtil.getGridColumnsMetadataTypeSettings(objName);
 		for(HomeSearch_Grid_Column__mdt hsColumn : hsColumnsSetting) {
 			if(objName != 'Invoiced Items' || (objName == 'Invoiced Items' && isSummaryFormat != null && 
 				((isSummaryFormat && hsColumn.Label != 'Revenue' && hsColumn.Label != 'Profit') || 
 				(!isSummaryFormat && hsColumn.Label != 'Total Revenue' && hsColumn.Label != 'Total Profit'))))
 			{	
				if((hsColumn.Type__c == NUMERIC_TYPE_1 || hsColumn.Type__c == NUMERIC_TYPE_2) && hsColumn.Field_API_Name__c != null) {
					if(!objeNameToNumericFieldAPINameMap.containsKey(hsColumn.Display_Object_Name__c)) {
						objeNameToNumericFieldAPINameMap.put(hsColumn.Display_Object_Name__c, new List<String>{hsColumn.Field_API_Name__c});
					} else {
						List<String> numericFieldAPINameList = objeNameToNumericFieldAPINameMap.get(hsColumn.Display_Object_Name__c);
						numericFieldAPINameList.add(hsColumn.Field_API_Name__c);
					}
					if(hsColumn.Label != null) {
						fieldAPINameToFieldLabelMap.put(hsColumn.Field_API_Name__c, hsColumn.Label.replaceAll(' ', '_'));
						fieldLabelSet.add(hsColumn.Label.replaceAll(' ', '_'));
						fieldLabelToTypeMap.put(hsColumn.Label.replaceAll(' ', '_'), hsColumn.Type__c);
					}
				} 
			}
		}
		fieldAPINameToFieldLabelMap.put('Id', COUNT_RECORD_ALIASE);
		return objeNameToNumericFieldAPINameMap;
	}
	
	public static List<AggregateResult> getAggregateResultByObjName(String objName, List<String> numericFieldAPINameList) {
		List<AggregateResult> aggregateResultList = new List<AggregateResult>();
		String query = '';
		
		query += 'SELECT COUNT(Id) ' + COUNT_RECORD_ALIASE + ', ';
		for(String fieldName : numericFieldAPINameList) {
			query += 'SUM(' + fieldName + ') ' + fieldAPINameToFieldLabelMap.get(fieldName) + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM ' + HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objName);
		
		//system.assert(false, query);
		if(HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objName) != null){
			if(AccessControl.ifObjectFieldIsAccessible(HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objName)) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		}
		aggregateResultList = Database.query(query);
		return aggregateResultList;
	}
	
	public static List<AggregateResult> getAggregateResultByObjName(String objName, List<String> numericFieldAPINameList, String whereClauseString) {
		List<AggregateResult> aggregateResultList = new List<AggregateResult>();
		String query = '';
		query += 'SELECT COUNT(Id) ' + COUNT_RECORD_ALIASE + ', ';
		for(String fieldName : numericFieldAPINameList) {
			query += 'SUM(' + fieldName + ') ' + fieldAPINameToFieldLabelMap.get(fieldName) + ', ';
		}
		query = query.substring(0, query.length() - 2);
		query += ' FROM ' + HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objName);
		
		// get where clause
		//String whereClauseString = getWhereClause(objName, filterList);
		if(HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objName) != null){
			if(HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objName).indexOf(',') != -1) {
    			List<String> objectsAPINameList = HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objName).split(',');
    			for(String objAPIName : objectsAPINameList) {
    				if(AccessControl.ifObjectFieldIsAccessible(HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objAPIName)) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    			}
			} else {
				if(AccessControl.ifObjectFieldIsAccessible(HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objName)) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
			}
		}
		
		if(String.isNotBlank(whereClauseString)) {
        	query += ' ' + whereClauseString;
        }
		
		system.debug('Aggregate Query BY TARUN : ' + query);
		
		//system.assert(false, query);
		aggregateResultList = Database.query(query);
		return aggregateResultList;
	}
	
	public static String getRportingDataByHomeSearchFilters(HomeSearchFilterWrapper filterWrapperObj, String selectedObjName, String uniqueValueFieldLastValue) {
		List<HomeSearchFilterInterface.FilterLabel> filterLabelList = HomeSearchFilterInterface.getFilterLabelList(filterWrapperObj);
		return (getRportingDataByHomeSearchFilters(filterWrapperObj, selectedObjName, uniqueValueFieldLastValue, filterLabelList));
    }
    
    public static String getRportingDataByHomeSearchFilters(HomeSearchFilterWrapper filterWrapperObj, 
    														String selectedObjName, 
    														String uniqueValueFieldLastValue,
    														List<HomeSearchFilterInterface.FilterLabel> filterLabelList
    													) {
    	String objAPIName = HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(selectedObjName);
    	
    	Map<String, List<sObject>> resultRecordsMap = getRportRecordsByHomeSearchFilters(filterWrapperObj, new Set<String>{selectedObjName}, uniqueValueFieldLastValue, null);
        List<sObject> resultRecords;
        if(resultRecordsMap.containsKey('Parts Order')) {
        	resultRecords = new List<sObject>((List<sObject>) resultRecordsMap.get('Parts Order'));
        } else {
        	resultRecords = new List<sObject>((List<sObject>) resultRecordsMap.get(objAPIName));
        }
    	if(objAPIName == 'CO_Invoice_Payment__c' && resultRecordsMap.containsKey('CO_Deposit__c')) {
    		resultRecords.addAll( (List<sObject>)resultRecordsMap.get('CO_Deposit__c') );
    	}
    	if(objAPIName == 'Vendor_Order_Header__c' && resultRecordsMap.containsKey('Return_VO_Header__c')) {
    		resultRecords.addAll( (List<sObject>)resultRecordsMap.get('Return_VO_Header__c') );
    	}
    	if(objAPIName == 'Part_FIFO_Bucket__c' && resultRecordsMap.containsKey('Part_FIFO_Bucket__c')) {
            resultRecords.addAll( (List<sObject>)resultRecordsMap.get('Part_FIFO_Bucket_Activity_Line_Item__c') );
        } 
		if(objAPIName == 'CO_Line_Item__c') {
    		if(resultRecordsMap.containsKey('Service_Order_Line_Item__c')) {
    			resultRecords.addAll( (List<sObject>)resultRecordsMap.get('Service_Order_Line_Item__c') );
    		}
    		if(resultRecordsMap.containsKey('Option_Fee__c')) {
    			resultRecords.addAll( (List<sObject>)resultRecordsMap.get('Option_Fee__c') );
    		}
    	}
    	
    	if(selectedObjName == 'Tax Detail') {
            if(filterWrapperObj.Tax_Detail_Invoice_Type == '0') {
            	resultRecords.addAll( (List<sObject>)resultRecordsMap.get('Vendor_Invoicing_Header__c') );
                resultRecords.addAll( (List<sObject>)resultRecordsMap.get('CO_Invoice_Header__c') );
            } else if(filterWrapperObj.Tax_Detail_Invoice_Type == 'Customer Invoice') {
                resultRecords.addAll( (List<sObject>)resultRecordsMap.get('CO_Invoice_Header__c') );
            } else if(filterWrapperObj.Tax_Detail_Invoice_Type == 'Vendor Invoice') {
                resultRecords.addAll( (List<sObject>)resultRecordsMap.get('Vendor_Invoicing_Header__c') );
            }
        }
        resultRecordsMap = null;
        // Get JSON string for result records in ResultWrapper instance
    	Integer totalRecordsFound = 0;
    	HomeSearchResultWrapper.getJSONForSObjectRecords( resultRecords, 
														  HomeSearchUtil.getGenericObjectNameBySelectedObject(filterWrapperObj.Type.Objects), 
														  totalRecordsFound,
														  null,
                                                          false, false, false, filterWrapperObj.Type.Objects 
														);
    	String lastRecordUniqueFieldValue = '';
    	if(resultRecords.size() > 0 && objAPIName != null) {
    		lastRecordUniqueFieldValue = String.valueOf(resultRecords[resultRecords.size() - 1].get(HomeSearchUtil.searchableObjectToUniqueValueFieldMap.get(objAPIName)));
    	}
    	Integer resultRecSize = resultRecords.size();
    	resultRecords = null;
    	//heap size left = 6000000
    	ReportWrapper ResultData = new ReportWrapper(HomeSearchResultWrapper.result, 
    												 lastRecordUniqueFieldValue,
    												 (resultRecSize < QUERY_LIMIT_RECORDS),
    												 resultRecSize,
    												 filterLabelList
    												);    												
    	HomeSearchResultWrapper.result = null;											
		return system.Json.serialize(ResultData);
    }
    
    public static Map<String, List<sObject>> getRportRecordsByHomeSearchFilters(HomeSearchFilterWrapper filterWrapperObj, 
    														Set<String> selectedObjNames, 
    														String uniqueValueFieldLastValue,
    														PaginationSorting pageAndSortMapping
    													) {
    	Map<String, List<sObject>> resultRecordsMap = new Map<String, List<sObject>>();
    	// Ensure the filter wrapper contains only single object
    	// Since, we are not querying the result in loop in apex, so we need to have only 1 object name in filter wrapper
    	// Next, remaining results of remaining objects will be queried in next context call by page so as to avoid governor limits
		filterWrapperObj.Type.Objects = selectedObjNames;
		
		Set<String> objectsSet = new Set<String>();
		for(String objectName : selectedObjNames) {
			objectsSet.add(objectName);
			if(objectsSet.contains('Customer Payments') && !objectsSet.contains('Customer Deposits')) {
				objectsSet.add('Customer Deposits');
			} else if(objectsSet.contains('Vendor Orders') && !objectsSet.contains('Vendor Return')) {
				objectsSet.add('Vendor Return');
			} else if(objectsSet.contains('Invoiced Items') && !objectsSet.contains('SOLI')) {
				objectsSet.add('SOLI');
				objectsSet.add('Option and Fee');
			} else if(objectsSet.contains('Part FIFO')) {
			    objectsSet.add('Part FIFO Line Item');
			} else if(objectsSet.contains('Tax Detail')) {
			    objectsSet.remove('Tax Detail');
			    if(filterWrapperObj.Tax_Detail_Invoice_Type == '0') {
                    objectsSet.add('Tax Detail Customer Invoices');
                    objectsSet.add('Tax Detail Vendor Invoices');
                } else if(filterWrapperObj.Tax_Detail_Invoice_Type == 'Customer Invoice') {
                    objectsSet.add('Tax Detail Customer Invoices');
                } else if(filterWrapperObj.Tax_Detail_Invoice_Type == 'Vendor Invoice') {
                    objectsSet.add('Tax Detail Vendor Invoices');
                }
            }
		}
		// Condition for CO Deposits				
    	// Get objects where clause from Home Search screen
    	Map<String,String> objectsWhereConditions = HomeSearchReportInterface.getWhereClauseForObjects(filterWrapperObj);
    	/*if(objectsWhereConditions.containsKey('Customer Payments')) {
    		objectsWhereConditions.put('Customer Deposits', objectsWhereConditions.get('Customer Payments'));
    	}*/
    	// Create query string:
    	for(String selectedObjName : objectsSet) {
        	String objAPIName;
    	    String objQuery;
    		if(HomeSearchUtil.displayObjectNameToObjectAPINameSpecialSearchMap.containsKey(selectedObjName)) {
    	        objAPIName = HomeSearchUtil.displayObjectNameToObjectAPINameSpecialSearchMap.get(selectedObjName);
    	        objQuery = createSOQLForObject(    objAPIName, 
                                                    objectsWhereConditions.get(selectedObjName),
                                                    HomeSearchUtil.searchableObjectToUniqueValueFieldMap.get(objAPIName),
                                                    uniqueValueFieldLastValue,
                                                    pageAndSortMapping, filterWrapperObj,
                                                    selectedObjName
                                                );
    	    } else {
    	        objAPIName = HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(selectedObjName);
    	        objQuery = createSOQLForObject(    objAPIName, 
                                                    objectsWhereConditions.get(selectedObjName),
                                                    HomeSearchUtil.searchableObjectToUniqueValueFieldMap.get(objAPIName),
                                                    uniqueValueFieldLastValue,
                                                    pageAndSortMapping, filterWrapperObj,
                                                    null
                                                );
    	    }
            
	    	system.debug('QUERYYYYYYY objAPIName: \n' + objQuery);
            if(selectedObjName == 'Parts Order') {
            	resultRecordsMap.put('Parts Order', (List<sObject>)Database.query(objQuery));
            } else {
		    	resultRecordsMap.put(objAPIName, (List<sObject>)Database.query(objQuery));
			}
            
        }
        //system.assert(false, a);
    	if(objectsSet.contains('Customer Deposits')) {
    		objectsSet.remove('Customer Deposits');
    	}
    	if(objectsSet.contains('Vendor Return')) {
    		objectsSet.remove('Vendor Return');
    	}
    	if(!objectsSet.contains('SOLI')) {
			objectsSet.remove('SOLI');
		}
		if(!objectsSet.contains('Option and Fee')) {
			objectsSet.remove('Option and Fee');
		}
		if(!objectsSet.contains('Part FIFO Line Item')) {
            objectsSet.remove('Part FIFO Line Item');
        }
    	return resultRecordsMap;
    }
    
    private static String createSOQLForObject(	String objName, 
    											String whereClause, 
    											String uniqueValueOrderByField, 
    											String uniqueValueFieldLastValue,
    											PaginationSorting pageAndSortMapping, HomeSearchFilterWrapper filterWrapperObj,
    											String specialObjectName
    										) {
    	
        if(AccessControl.ifObjectFieldIsAccessible(objName) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }	
    	
    	Map<String, String> childObjNameToFilterFieldName;
    	Map<String, List<HomeSearchFilterInterface.FieldFilter>> objNameToFieldFilterListMap;
    	String searchName;
        
    	if(HomeSearchUtil.searchNameToChildQueryObjNameToFieldToFilterNameMap.containsKey((HomeSearchUtil.displayObjectAPINameToObjectNameMap.get(CONSTANTS.NAMESPACE+objName)))) {
			searchName = HomeSearchUtil.displayObjectAPINameToObjectNameMap.get(CONSTANTS.NAMESPACE+objName);
			childObjNameToFilterFieldName = HomeSearchUtil.searchNameToChildQueryObjNameToFieldToFilterNameMap.get(searchName);
			objNameToFieldFilterListMap = HomeSearchFilterInterface.getFilterList(filterWrapperObj);
    	}
    	
    	String query = 'SELECT ';
    	Set<String> fieldSet;
    	if(String.isNotBlank(specialObjectName) && HomeSearchUtil.displayObjectNameToObjectAPINameSpecialSearchMap.containsKey(specialObjectName)
    											&& HomeSearchUtil.searchableSpecialObjectToFieldsMap.containsKey(objName)) {
    	    fieldSet = HomeSearchUtil.searchableSpecialObjectToFieldsMap.get(objName);
    	} else {
    	    fieldSet = HomeSearchUtil.searchableObjectToFieldsMap.get(objName);
    	}
    	
    	for(String fieldName : fieldSet) {	
    		if(childObjNameToFilterFieldName != null) {
    			String fieldAPIName;
    			String childObjAPIName;
    			for(String childObjName : childObjNameToFilterFieldName.keySet()) {
    				if(fieldName.contains(childObjName)) {
    					childObjAPIName = childObjName;
    					fieldAPIName = childObjNameToFilterFieldName.get(childObjName);
    					break;
    				}
    			}
    			if(String.isNotBlank(fieldAPIName)) {
    				Boolean isFieldToFilterFound = false;
    				HomeSearchFilterInterface.FieldFilter filterObj;
    				for(HomeSearchFilterInterface.FieldFilter fieldFilter : objNameToFieldFilterListMap.get(searchName)) {
    					if(fieldFilter.FieldName == fieldAPIName){
    						String actualAPIName = fieldAPIName;
	    					if(HomeSearchUtil.childObjNameToFilterFieldNameToAPIName.containsKey(childObjAPIName)) {
	    						actualAPIName = HomeSearchUtil.childObjNameToFilterFieldNameToAPIName.get(childObjAPIName).get(fieldFilter.FieldName);
	    					}
	    					if(!isFieldToFilterFound) {
	    						fieldName = fieldName.replace(')', ' WHERE ' + actualAPIName + ' ' + fieldFilter.Operator + ' ' + fieldFilter.FieldValue) + '),';
	    						query += fieldName;
	    					} else {
	    						query = query.subString(0, query.length() - 2);
	    						query += ' AND ' + actualAPIName + ' ' + fieldFilter.Operator + ' ' + fieldFilter.FieldValue + '),';
	    					}
    						
    						isFieldToFilterFound = true;
    					}
    				}
    				if(!isFieldToFilterFound) {
    					query += fieldName + ',';
    				}
    				
    			} else {
    				query += fieldName + ',';
    			}
    		} else {
    			query += fieldName + ',';
    		}
    	}
    	query = query.subString(0, query.length() - 1);
    	query += ' FROM ' + objName;
    	
    	if(whereClause != null && whereClause.trim().length() != 0) {
    		query += ' ' + whereClause;
    	}
    	
    	if(uniqueValueFieldLastValue != null && uniqueValueFieldLastValue.trim().length() != 0) {
    		if(whereClause != null && whereClause.trim().length() != 0) {
    			query += ' AND ';
    		} else {
    			query += ' WHERE ';
    		}
    		query += uniqueValueOrderByField + '>\'' + uniqueValueFieldLastValue + '\'';
    	}
        
    	if(pageAndSortMapping != null) {
            if(pageAndSortMapping.Sorting != null && pageAndSortMapping.Sorting.size() > 0) {
            	if(pageAndSortMapping.Sorting.size() == 1) {
            		if(pageAndSortMapping.Sorting[0].FieldName == 'LastModifiedDate__c') {
            			pageAndSortMapping.Sorting[0].FieldName = 'LastModifiedDate';
            		} else if(pageAndSortMapping.Sorting[0].FieldName == 'CreatedDate__c') {
            			pageAndSortMapping.Sorting[0].FieldName = 'CreatedDate';
            			if(objName == 'CO_Invoice_Header__c') {
            				pageAndSortMapping.Sorting[0].FieldName = 'Invoice_Date__c';
            			}
            		}
            	}
                String sortClause = ' ORDER BY ';
                for(PaginationSorting.SortAttrs sortAttr : pageAndSortMapping.Sorting) {
                    String sortFieldAPIName = getSortFieldNameForObject(objName, sortAttr.FieldName);
                    if(sortFieldAPIName != null && sortFieldAPIName != '' && sortFieldAPIName != 'Type') {
                        sortClause += sortFieldAPIName + ' ' + sortAttr.SortDirection + ' NULLS LAST, ';
                    }
                }
                
                if(sortClause != ' ORDER BY ') {
                    //sortClause = sortClause.subString(0, sortClause.length() - 2);
                    sortClause += ' NAME DESC '; // This is for to remove SOQL Issue. The records on page 3 and 4 are coming same.
                    query += sortClause;
                }
            }
            
            // Because we have removed pagination for "Technician Performance" Search - Added by TK -
            if(!HomeSearchUtil.objectWithNoPaginationSet.contains(objName) && 
                   !(String.isNotBlank(specialObjectName) && HomeSearchUtil.displayObjectNameToObjectAPINameSpecialSearchMap.containsKey(specialObjectName))) {
            	query += ' LIMIT ' + (pageAndSortMapping.CurrentPage * pageAndSortMapping.PageSize);
            }
        } else if(uniqueValueOrderByField != null && uniqueValueOrderByField.trim().length() != 0) {
            query += ' ORDER BY ' + uniqueValueOrderByField + ' ASC';
            query += ' LIMIT ' + QUERY_LIMIT_RECORDS;
        }
    	return query;
    }
    
    /**
     * Name: getSortFieldNameForObject
     * Desc: Method to Get sort Field for object
     * @param:  (1) objName - String - Object Name
     *			(2) fieldLabel - String - Field Label
     * @return: String  
     **/
	private static String getSortFieldNameForObject(String objAPIName, String fieldLabel) {
        String fieldAPIName;
        if(fieldLabel != null 
            && HomeSearchUtil.searchableObjectToFieldsMap.containsKey(objAPIName) 
            && HomeSearchUtil.searchableObjectToFieldsMap.get(objAPIName).contains(fieldLabel)
        ){
            fieldAPIName = fieldLabel;
        } else if(fieldLabel != null 
                    && HomeSearchUtil.obejctNameToMapOfSortLabelToAPIName.containsKey(objAPIName) 
                    && HomeSearchUtil.obejctNameToMapOfSortLabelToAPIName.get(objAPIName).containsKey(fieldLabel)
                ) {
            fieldAPIName = HomeSearchUtil.obejctNameToMapOfSortLabelToAPIName.get(objAPIName).get(fieldLabel);
        } else if(fieldLabel != null 
                    && HomeSearchUtil.obejctNameToMapOfSortLabelToAPIName.containsKey(CONSTANTS.NAMESPACE + objAPIName) 
                    && HomeSearchUtil.obejctNameToMapOfSortLabelToAPIName.get(CONSTANTS.NAMESPACE + objAPIName).containsKey(fieldLabel)
                ) {
            fieldAPIName = HomeSearchUtil.obejctNameToMapOfSortLabelToAPIName.get(CONSTANTS.NAMESPACE + objAPIName).get(fieldLabel);
        } else if(fieldLabel != null &&
					HomeSearchUtil.groupFieldNameToObjAPINameToFieldAPINameMap.containsKey(fieldLabel) &&
					HomeSearchUtil.groupFieldNameToObjAPINameToFieldAPINameMap.get(fieldLabel).containsKey(objAPIName)) {
			
			fieldAPIName = HomeSearchUtil.groupFieldNameToObjAPINameToFieldAPINameMap.get(fieldLabel).get(objAPIName);
		}
        
        //System.debug('@@@@ fieldAPIName: ' + fieldAPIName);
        return (fieldAPIName != null) ? fieldAPIName : '';
    }
    
    public class ReportWrapper {
    	public HomeSearchResultWrapper.ResultWrapper ResultData {private set; get;}
    	public String UniqueFieldName {private set; get;}
    	public Boolean IsProcessCompleted {private set; get;}
    	public Integer TotalRecords {private set; get;}
    	public List<HomeSearchFilterInterface.FilterLabel> FilterLabelList {private set; get;}
    	
    	public ReportWrapper(HomeSearchResultWrapper.ResultWrapper ResultData, 
    						 String UniqueFieldName, 
    						 Boolean IsProcessCompleted, 
    						 Integer TotalRecords,
    						 List<HomeSearchFilterInterface.FilterLabel> filterLabelList
    					) {
    		this.ResultData = ResultData;
    		this.UniqueFieldName = UniqueFieldName;
    		this.IsProcessCompleted = IsProcessCompleted;
    		this.TotalRecords = TotalRecords;
    		this.FilterLabelList = filterLabelList;
    	}
    }
}
