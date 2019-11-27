/**
 * Author: Tarun Khandelwal
 * Since: April 20, 2016
 * Name: HomeSearchReportInterface
 * Description: Class used to hold utility methods, variables and mapping used in Home Search screen
 * 
**/
public with sharing class HomeSearchReportInterface {
	public static Set<String> validTextTypes = new Set<String>{'STRING', 'PICKLIST', 'URL', 'EMAIL', 'PHONE'} ;//MULTIPICKLIST
	public static Set<String> specialFields = new Set<String>{'Name'} ;

	public static Map<String,String> getWhereClauseForObjects(HomeSearchFilterWrapper filterWrapperObj){
		Map<String, String> filterConditionMap = new map<String, String>();
        Set<String> selectedObjSetFromPage = new Set<String>();
        
        if(filterWrapperObj != null && filterWrapperObj.Type.Objects.size() > 0) {
            selectedObjSetFromPage.addAll(filterWrapperObj.Type.Objects);
        }

		Map<String, List<HomeSearchFilterInterface.FieldFilter>> objNameToFieldFilterListMap = HomeSearchFilterInterface.getFilterList(filterWrapperObj);
		Map<String, String> objNameToWhereClauseStringMap = new Map<String, String>();
		
		Set<String> objectSet = new Set<String>();
        if(selectedObjSetFromPage.size() == 0 || (selectedObjSetFromPage.size() == 1 && selectedObjSetFromPage.contains(Label.Generic_Object_Label))) {
			objectSet = HomeSearchUtil.displayObjectNameToTypeNumber.keySet();
		} else {
            objectSet = selectedObjSetFromPage;
		}
		Set<String> objectsSet = new Set<String>();
		for(String objectName : objectSet) {
			objectsSet.add(objectName);
			if(objectsSet.contains('Customer Payments')) {
				objectsSet.add('Customer Deposits');
			} else if(objectsSet.contains('Vendor Orders')) {
				objectsSet.add('Vendor Return');
			} else if(objectsSet.contains('Invoiced Items')) {
				objectsSet.add('SOLI');
				objectsSet.add('Option and Fee');
			} else if(objectsSet.contains('Part FIFO')) {
                objectsSet.add('Part FIFO Line Item');
            }  else if(objectsSet.contains('Tax Detail')) {
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
		Boolean isPeopleAdded = false;
        if(objectsSet.contains('Customers') && objectsSet.contains('Vendors')) {
        	isPeopleAdded = true;
        }
        
		for(String objName : objectsSet) {  
			String whereClause = '';
			if((objName == 'Customers' || objName == 'Vendors') && isPeopleAdded && objNameToFieldFilterListMap.containsKey('People')) {
            	whereClause = getWhereClause(objName, objNameToFieldFilterListMap.get('People'));
            }else{
	            if(objNameToFieldFilterListMap.containsKey(objName)) {
	                whereClause = getWhereClause(objName, objNameToFieldFilterListMap.get(objName));
	            } else {
	                whereClause = getWhereClause(objName, new List<HomeSearchFilterInterface.FieldFilter>());
	            }
            }
			String containsClause = getContainsCondition(objName, filterWrapperObj.SearchText);
			if(whereClause != '' && containsClause != '') {
				whereClause = whereClause + ' AND ' + containsClause;
			} else if(whereClause == '' && containsClause != ''){
				whereClause = ' WHERE ' + containsClause;
			}
			
			// Tags Clause
			if(objName == 'Parts' || objName == 'Inventory Unit' || objName == 'Customer Unit' || objName == 'Deal Units') {
				String tagsClause = getAssignedTagClause(objName, filterWrapperObj.AssignedTags);
				if(whereClause != '' && tagsClause != '') {
					whereClause = whereClause + ' AND ' + tagsClause;
				} else if(whereClause == '' && tagsClause != ''){
					whereClause = ' WHERE ' + tagsClause;
				}
			}
			objNameToWhereClauseStringMap.put(objName, whereClause);
		}
		return objNameToWhereClauseStringMap;  
	}
	
	private static String getWhereClause(String objName, List<HomeSearchFilterInterface.FieldFilter> filterList) {
		system.debug('Helllo  ' + objName);
		system.debug('filterList  ' + filterList);
		String queryWhereClause = (filterList != null && filterList.size() > 0) ? ' WHERE ' : '';
		for(HomeSearchFilterInterface.FieldFilter fieldFilter : filterList) {
			if(!(HomeSearchUtil.searchNameToFieldToFilterNameMap.containsKey(objName) && HomeSearchUtil.searchNameToFieldToFilterNameMap.get(objName).contains(fieldFilter.FieldName))) {
				queryWhereClause += (queryWhereClause == ' WHERE ') ? '' : ' AND ';
				if(fieldFilter.FieldName != null && fieldFilter.FieldName.trim().length() != 0) {
					String filterFielName = fieldFilter.FieldName;
					if(filterFielName == 'OwnerId' && HomeSearchUtil.objectToOwnerObjectFieldName.containsKey(objName)) {
						String ownerField = HomeSearchUtil.objectToOwnerObjectFieldName.get(objName);
						ownerField = (ownerField.endsWith('__c')) ? ownerField : (ownerField + '.' + filterFielName);
						filterFielName = ownerField;
					} else if(filterFielName == 'OwnerId' && objName == 'User') {
						filterFielName = 'CreatedById';
					}
					
					queryWhereClause += filterFielName + ' ' + fieldFilter.Operator + ' ' + fieldFilter.FieldValue;
				} else {
					// In else case add the value as whole filter
					queryWhereClause += fieldFilter.FieldValue;
				}
			}
		}
		system.debug('queryWhereClause  ' + queryWhereClause);
		return (queryWhereClause == ' WHERE ') ? '' : queryWhereClause;
	}
	
	public static String getAssignedTagClause(String objName, List<String> tagsList) {
		List<FieldFilter> fieldFilterList = new List<FieldFilter>();
		
		if(tagsList != null && tagsList.size() > 0) {
			for(String tagStr : tagsList) {
				if(objName == 'Deal Units') {
					fieldFilterList.add(new FieldFilter('Customer_Owned_Unit__r.Assigned_Tag_1__c', 'Like', '\'%;' + tagStr + ';%\''));
					fieldFilterList.add(new FieldFilter('Customer_Owned_Unit__r.Assigned_Tag_2__c', 'Like', '\'%;' + tagStr + ';%\''));
				} else {
					fieldFilterList.add(new FieldFilter('Assigned_Tag_1__c', 'Like', '\'%;' + tagStr + ';%\''));
					fieldFilterList.add(new FieldFilter('Assigned_Tag_2__c', 'Like', '\'%;' + tagStr + ';%\''));
				}
			}
		}
		
		String tagWhereClause = '( ';
		for(FieldFilter fieldFilterRec : fieldFilterList) {
			tagWhereClause += fieldFilterRec.FieldName + ' ' + fieldFilterRec.Operator + ' ' + fieldFilterRec.FieldValue + ' OR ';
		}
		if(fieldFilterList.size() == 0 || tagWhereClause.length() <= 2) {
			tagWhereClause = '';
		} else {
			tagWhereClause = tagWhereClause.substring(0, tagWhereClause.length() - 3);
			tagWhereClause += ')';
		}
		return tagWhereClause;
	}
	
	public static String getContainsCondition(String objName, String searchText) {
		List<FieldFilter> fieldFilterList = new List<FieldFilter>();
		
		if(!String.isBlank(searchText)) {
    		searchText = BPUtility.escapeSingleQuotes(searchText);  
			List<String> textFieldsList = getFieldsByObjectName(HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objName));
			for(String textFieldStr : textFieldsList) {
				fieldFilterList.add(new FieldFilter(textFieldStr, 'Like', '\'%' + searchText + '%\''));
			}
		}
		
		String containsClause = '( ';
		for(FieldFilter fieldFilterRec : fieldFilterList) {
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
	
	public static List<String> getFieldsByObjectName(String objAPIName) {
		List<String> textFieldsList = new List<String>();
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		objAPIName = objAPIName.contains('__c') ? CONSTANTS.NAMESPACE + objAPIName : objAPIName;
		List<Schema.SObjectField> sfieldList = schemaMap.get(objAPIName).getDescribe().fields.getMap().values();
		for(Schema.SObjectField sField : sfieldList) {
			if(objAPIName == CONSTANTS.NAMESPACE + 'CO_Invoice_Header__c' && sField.getDescribe().getName() == CONSTANTS.NAMESPACE + 'Invoice_Number__c'){
                textFieldsList.add(sField.getDescribe().getName());
            }
            if(specialFields.contains(sField.getDescribe().getName()) || (validTextTypes.contains(sfield.getDescribe().getType().Name()) && sfield.getDescribe().isUpdateable())) {
                if(objAPIName == CONSTANTS.NAMESPACE + 'CO_Invoice_Header__c' && sField.getDescribe().getName() == 'Name'){
                    continue;
                }
                textFieldsList.add(sField.getDescribe().getName());
            }
        }
        
        if(objNameToSearchFieldMap.containsKey(objAPIName)) {
        	textFieldsList.addAll(new List<String>(objNameToSearchFieldMap.get(objAPIName)));
        }
        
        return textFieldsList;
	}
	
	public static Map<String, Set<String>> objNameToSearchFieldMap = new Map<String, Set<String>> {
																					CONSTANTS.NAMESPACE + 'CO_Line_Item__c' => new Set<String>{'Invoice_Number__r.Invoice_Number__c'},
    																				CONSTANTS.NAMESPACE + 'Service_Order_Line_Item__c' => 
																												new Set<String>{'Service_Order_Header__r.Invoice_Number__r.Invoice_Number__c'},
    																				CONSTANTS.NAMESPACE + 'Option_Fee__c' => 
    																											new Set<String>{'Deal__r.Invoice_Number__r.Invoice_Number__c'},
    																				CONSTANTS.NAMESPACE + 'Hours_Logged__c' => 
    																											new Set<String>{'Service_Order_Header__r.CO_Header__r.Name', 'Task__r.Name__c'}
                                                                                };
	
	public class FieldFilter {
		public String FieldName;
		public String Operator;
		public Object FieldValue;
		
		public FieldFilter(String fieldName, String operator, Object value){
		 	this.FieldName = fieldName;
		 	this.Operator = operator;
		 	this.FieldValue = value;
		 }
	}
}