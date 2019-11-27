global with sharing class AutoCompleteCtrl {
 	
	public static String Application{get;}
	public static String Application_Images{get;}
 	
  	global AutoCompleteCtrl (NewHomePageCtrl controller){
  		Application = GlobalController.GetResourceURL('Application');
    	Application_Images = GlobalController.GetResourceURL('Application_Images');
  	}
    public AutoCompleteCtrl() {
    	Application = GlobalController.GetResourceURL('Application');
    	Application_Images = GlobalController.GetResourceURL('Application_Images');
    }
    
	@RemoteAction
    global static String getSearchResults(String JSONString) {
    	JSONString = BPUtility.getDecodedString(JSONString); 
        QueryJSON searchQueryJSON = parseQuery(JSONString);	
        String resultStr = getSearchResult(searchQueryJSON);
    	return BPUtility.getEncodedString(resultStr);
    }
    
    private static String getSearchResult(QueryJSON searchQueryJSON) {
    	String textToSearch = String.escapeSingleQuotes(searchQueryJSON.SearchText.toLowerCase());
    	//FilterJSON filterObj = createFilterClauseForSearchText(searchQueryJSON.SearchFieldName, textToSearch);
    	if(searchQueryJSON.FilterValues == null) {
    		searchQueryJSON.FilterValues = new List<FilterJSON>();
    	}
    	//searchQueryJSON.FilterValues.add(filterObj);
    	
    	String query = getQuery(searchQueryJSON.ObjectLabel, searchQueryJSON.FilterValues, textToSearch);
    	List<Sobject> sobjList = Database.query(query);
        
    	//START: Added by Nidhi - #160 - 10/03/2016 (Added and commented)
    	return sortSObjList(searchQueryJSON, sobjList);
    	//return createResultJSON(sobjList);
    	//END: Added by Nidhi - #160 - 10/03/2016 (Added and commented)
    }
    
    private static String getQuery(String objectLabel, List<FilterJSON> FilterValues, String textToSearch) {
    	if(FilterValues == null) {
    		FilterValues = new List<FilterJSON>();
    	}
    	String query = 'SELECT Id, ';
    	for(String fieldApiName : objNameToSearchableFieldListMap.get(objectLabel)) {
    		query += fieldApiName + ', ';
    	}
    	
    	query = query.subString(0, query.length() - 2);
    	query += ' FROM ' + objLabelToObjectApiNameMap.get(objectLabel);
    	query += getWhereClause(objectLabel, FilterValues, textToSearch);
    	query += ' order by LastModifiedDate DESC';
    	return query;
    }
    
    private static String getWhereClause(String objectLabel, List<FilterJSON> FilterValues, String textToSearch) {
    	String whereClause = '';
    	Boolean isWhereClauseAdded = false;
    	if(objectLabel == 'Customer') {
    		whereClause += ' WHERE Is_Customer__c = true';
    		isWhereClauseAdded = true;
    	} else if(objectLabel == 'Vendor') {
    		whereClause += ' WHERE Is_Vendor__c = true';
    		isWhereClauseAdded = true;
    	}
    	
    	if(!isWhereClauseAdded) {
            String whereSubClause = getStartsWithWhereClause(objectLabel, textToSearch);
            if(String.isNotBlank(whereSubClause)) {
                whereClause += ' WHERE ' + whereSubClause;
			isWhereClauseAdded = true;
            }
		} else {
            if(String.isNotBlank(textToSearch)) {
                whereClause += ' AND ' + getStartsWithWhereClause(objectLabel, textToSearch);
            }
        }
    	
    	for(FilterJSON filter : FilterValues) {
    		if(!isWhereClauseAdded) {
    			whereClause += ' WHERE ' + filter.Field + filter.Operator + filter.Value;
    			isWhereClauseAdded = true;
    		} else {
    			whereClause += ' AND ' + filter.Field + filter.Operator + filter.Value;
    		}
    	}
    	return whereClause;
    }
    
    public static String getStartsWithWhereClause(String objName, String searchText) {
    	List<FilterJSON> fieldFilterList = new List<FilterJSON>();
		
		if(!String.isBlank(searchText)) {
			List<String> textFieldsList = HomeSearchReportInterface.getFieldsByObjectName(objLabelToObjectApiNameMap.get(objName));
			for(String textFieldStr : textFieldsList) {
				fieldFilterList.add(new FilterJSON(textFieldStr, 'Like', '\'%' + searchText + '%\''));
			}
		}
		
		String containsClause = '( ';
		for(FilterJSON fieldFilterRec : fieldFilterList) {
			containsClause += fieldFilterRec.Field + ' ' + fieldFilterRec.Operator + ' ' + fieldFilterRec.Value + ' OR ';
		}
		if(fieldFilterList.size() == 0 || containsClause.length() <= 2) {
			containsClause = '';
		} else {
			containsClause = containsClause.substring(0, containsClause.length() - 3);
			containsClause += ')';
		}
		return containsClause;
    }
    
    /*
    private static String createResultJSON(List<Sobject> sobjList) {
    	List<ResultJSON> resultList = new List<ResultJSON>();
    	for(Sobject sobj : sobjList) {
    		resultList.add(new ResultJSON((Account)sobj));
    	}
    	//system.assert(false, system.JSON.serialize(resultList));
    	return system.JSON.serialize(resultList);
    }*/
    
    //START: Added by Nidhi - #160 - 09/30/2016
    public static String sortSObjList(QueryJSON searchQueryJSON, List<Sobject> sobjList) {
    	String textToSearch = String.escapeSingleQuotes(searchQueryJSON.SearchText.toLowerCase());
    	if(searchQueryJSON.ObjectLabel == 'Customer' || searchQueryJSON.ObjectLabel == 'Vendor') {//#1762 kajal 28th march 2017
	    	List<CustomerInfoWrapper> customerSortedList = new List<CustomerInfoWrapper>();
	    	Integer counter = 0;
	    	Set<Id> customerIdSet = new Set<Id>();
	    	for(Account customerRec : (List<Account>)sobjList) {
	    		for(String fieldAPIName : customerPriorityFieldList) {
	    			if(customerRec.get(fieldAPIName) != null && String.valueOf(customerRec.get(fieldAPIName)) != '' && String.valueOf(customerRec.get(fieldAPIName)) == textToSearch) {
	    				customerSortedList.add(new CustomerInfoWrapper((Account)customerRec, objLabelToObjectFieldAPINameToPriorityNumberMap.get(searchQueryJSON.ObjectLabel).get(fieldAPIName)));
		    			customerIdSet.add(String.valueOf(customerRec.Id));
		    			break;
		    		} else if(customerRec.get(fieldAPIName) != null && String.valueOf(customerRec.get(fieldAPIName)) != '' && String.valueOf(customerRec.get(fieldAPIName)).containsIgnoreCase(textToSearch)) {
	    				customerSortedList.add(new CustomerInfoWrapper((Account)customerRec, objLabelToObjectFieldAPINameToPriorityNumberMap.get(searchQueryJSON.ObjectLabel).get(fieldAPIName) + 1));
		    			customerIdSet.add(String.valueOf(customerRec.Id));
		    			break;
		    		} 
	    		}
	    		if(!customerIdSet.contains(String.valueOf(customerRec.Id))) {
	    			customerSortedList.add(new CustomerInfoWrapper((Account)customerRec, 100)); // Last Priority
	    		}
	    	}
	    	customerSortedList.sort();
    		ResultJSON resultJson = new ResultJSON(customerSortedList);
    		return system.JSON.serialize(resultJson);
        } else {
            List<ResultJSON> resultJsonObjList = new List<ResultJSON>();
            for(Sobject sobjRec : sobjList) {
                resultJsonObjList.add(new ResultJSON(sobjRec));
    	}
            return system.JSON.serialize(resultJsonObjList);
        }
    	return system.JSON.serialize('');
    }
    //END: Added by Nidhi - #160 - 09/30/2016
    
    private static Map<String, List<String>> objNameToSearchableFieldListMap = new Map<String, List<String>>{
    																						'Customer' => new List<String>{'Name','FirstName__c','LastName__c','Preferred_Phone__c', 'Preferred_Email__c','Type__c', 'Email__c', 'Work_Email__c', 'Other_Email__c', 'Home_Number__c', 'Mobile__c', 'Work_Number__c','Formatted_Home_number__c','Formatted_Mobile_Number__c','Formatted_Work_Number__c','Formatted_Preferred_Phone__c', 'Is_Customer__c'},
                                                                                            'Vendor' => new List<String>{'Name','FirstName__c','LastName__c','Preferred_Phone__c', 'Preferred_Email__c','Type__c', 'Email__c', 'Work_Email__c', 'Other_Email__c', 'Home_Number__c', 'Mobile__c', 'Work_Number__c','Formatted_Home_number__c','Formatted_Mobile_Number__c','Formatted_Work_Number__c','Formatted_Preferred_Phone__c', 'Is_Customer__c'},
                                                                                            'User' => new List<String>{'Name','Email'},
                                                                                            'Fee' => new List<String>{'Name','Code__c', 'Description__c', 'Price__c'}    
    																					};// Edited by kv 02/27/2017////#1762 kajal 28th march 2017
    
    private static Map<String, String> objLabelToObjectApiNameMap = new Map<String, String>{'Customer' => 'Account',
                                                                                            'Vendor' => 'Account',
                                                                                            'User' => 'User',
                                                                                            'Fee' => 'Fee__c'};
    																						
	private static Map<String, Map<String,Integer>> objLabelToObjectFieldAPINameToPriorityNumberMap = new Map<String, Map<String,Integer>>
														{'Customer' => new Map<String,Integer>{'Name'=>1,
									                                                        'LastName__c'=>3,
									                                                        'FirstName__c'=>5,
									                                                        'Preferred_Email__c'=>7,
									                                                        'Preferred_Phone__c'=>9,
									                                                        'Unmatched'=>11
									                                                        },
									                     'Vendor' => new Map<String,Integer>{'Name'=>1,
									                                                        'LastName__c'=>3,
									                                                        'FirstName__c'=>5,
									                                                        'Preferred_Email__c'=>7,
									                                                        'Preferred_Phone__c'=>9,
									                                                        'Unmatched'=>11
									                                                        }
    													};///#1762 kajal 28th march 2017
    													
	private static List<String> customerPriorityFieldList = new List<String>
													{'LastName__c','FirstName__c','Name','Preferred_Email__c','Preferred_Phone__c'};
    
    public static QueryJSON parseQuery(String jsonString) {
        return (QueryJSON) System.JSON.deserialize(jsonString, QueryJSON.class);
    }    
    
    public class QueryJSON {
        public String ObjectLabel {get; set;}
        public String SearchText {get; set;}
        public String SearchFieldName {get; set;}
        public List<FilterJSON> FilterValues {get; set;}
    }
    
    public class FilterJSON {
    	public String Field {get; set;}
    	public String Operator {get; set;}
    	public String Value {get; set;}
    	
    	public FilterJSON() {
    		
    	}
    	
    	public FilterJSON(String fieldName, String operator, String fieldValue) {
    		this.Field = fieldName;
    		this.Operator = operator;
    		this.Value = fieldValue;
    	}
    }
    
    //START: Modified by Nidhi - #160 - 09/30/2016
    public class ResultJSON {
    	public String Name;
    	public String Id;
    	public String Email;
    	public String Phone;
    	public List<CustomerInfoWrapper> CustomerList;
    	
    	public FeeWrapper feeDetails;
    	
    	public ResultJSON(Sobject sobjRec) {
    		this.Name = (sobjRec.get('Name') != null) ? String.valueOf(sobjRec.get('Name')) : '';
    		this.Id = String.valueOf(sobjRec.get('Id'));
    		
    		if(String.valueOf(sobjRec.getSObjectType()) == Constants.NAMESPACE + 'Fee__c'){
    			feeDetails = new FeeWrapper((Fee__c)sobjRec);
    		}
    	}
    	
    	public ResultJSON(List<CustomerInfoWrapper> customerSortedList) {
    		/*this.Name = accRec.Name;
    		this.Id = accRec.Id;
    		this.Phone = accRec.Preferred_Phone__c;
    		this.Email = accRec.Preferred_Email__c;*/
    		this.CustomerList = customerSortedList;
    	}
    }
    //END: Modified by Nidhi - #160 - 09/30/2016
    /* START: Added by kv 02/24/2017 */
    public static String formatphonenumber(String cphone) {
		String fphone = cphone.replaceAll('\\D','');
		if (fphone.length() == 10) {
			fphone = formatphonenum(fphone);
			return fphone;
		}
		else {
			return cphone;
		}
	}
		static String formatphonenum (String s) {
		s = '(' + s.substring(0, 3) + ') ' + s.substring(3, 6) + '-' + s.substring(6);
		return s;
	}
	/* END: Added by kv 02/24/2017 */
    //START: Added by Nidhi - #160 - 09/30/2016
	public class CustomerInfoWrapper implements Comparable {
		public String Id;
		public String Name;
		public String Email;
		public String Phone;
		public String FirstName;
    	public String LastName;
    	public String Type;
		public Integer PriorityValue;
    	
    	public CustomerInfoWrapper(Account customerRec, Integer priorityNumber) {
    		this.Id = customerRec.Id;
    		this.Name = customerRec.Name;
    		if(customerRec.Preferred_Email__c == null) {
                if(customerRec.Email__c != null) {
                    this.Email = customerRec.Email__c;
                } else if(customerRec.Work_Email__c != null) {
                    this.Email = customerRec.Work_Email__c;
                } else if(customerRec.Other_Email__c != null) {
                    this.Email = customerRec.Other_Email__c;
                }
            } else {
                this.Email = customerRec.Preferred_Email__c;
            }
            
            if(customerRec.Preferred_Phone__c == null) {
                if(customerRec.Home_Number__c != null) {
                    this.Phone = customerRec.Formatted_Home_number__c;
                } else if(customerRec.Mobile__c != null) {
                    this.Phone = customerRec.Formatted_Mobile_Number__c;
                } else if(customerRec.Work_Number__c != null) {
                    this.Phone = customerRec.Formatted_Work_Number__c;
                }
            } else {
                this.Phone = customerRec.Formatted_Preferred_Phone__c;
            }
    		this.FirstName = customerRec.FirstName__c;
    		this.LastName = customerRec.LastName__c;
    		this.PriorityValue = priorityNumber;
    		
    		if(customerRec.Is_Customer__c) {
    		    this.Type = customerRec.Type__c;
    		}
    	} 
    	
    	public Integer compareTo(Object compareTo) {
	    	CustomerInfoWrapper compareToWrapperObj = ((CustomerInfoWrapper)compareTo);
	    	Integer returnValue = 0;
	    	if (PriorityValue == compareToWrapperObj.PriorityValue) return 0;
	        if (PriorityValue > compareToWrapperObj.PriorityValue) return 1;
	        return -1; 
    	}
     }
     //END: Added by Nidhi - #160 - 09/30/2016
     
     
     public class FeeWrapper{
     	public String Code;
     	public String Description;
     	public Decimal Price;
     	
     	public FeeWrapper(Fee__c feeObj){
     		this.Code = feeObj.Code__c;
     		this.Description = feeObj.Description__c;
     		this.Price = feeObj.Price__c != null ? feeObj.Price__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
     	}
     }
}