/**
 * Author: Tarun Khandelwal
 * Since: May 21, 2015
 * Name: CustomerSuggestion
 * Description: Apex class to handle JSON related oprations of suggestion of Customer records.
**/
global with sharing class CustomerSuggestion implements Comparable {

	public String CustomerName;
    public String FirstName;
    public String LastName;
    public String Type;
    public String BillingStreet1;
    public String HomeEmail;
    public String HomeNumber;
    public Integer PriorityValue;
    public List<CustomerOwnedUnitWrapper> COURecords;
    public String MatchKey;
    public String Id;
    
    // Constructor
    public CustomerSuggestion(Account customerRec, Integer priorityNumber) { 
    	this.CustomerName = customerRec.Name;
    	this.FirstName = customerRec.FirstName__c;
    	this.LastName = customerRec.LastName__c;
    	this.HomeEmail = (customerRec.Email__c == null) ? '' : customerRec.Email__c;
    	this.HomeNumber = (customerRec.Home_Number__c == null ) ? '' : customerRec.Home_Number__c;
    	this.Type = customerRec.Type__c;
    	this.PriorityValue = priorityNumber;
    	this.Id = customerRec.Id;
    	
    }
    
    public CustomerSuggestion(Account customerRec, Integer priorityNumber, List<Customer_Owned_Unit__c> couList) { 
    	this.CustomerName = customerRec.Name;
    	this.FirstName = customerRec.FirstName__c;
    	this.LastName = customerRec.LastName__c;
    	this.HomeEmail = (customerRec.Email__c == null) ? '' : customerRec.Email__c;
    	this.HomeNumber = (customerRec.Home_Number__c == null ) ? '' : customerRec.Home_Number__c;
    	this.Type = customerRec.Type__c;
    	this.PriorityValue = priorityNumber;
    	if(Constants.priorityNumberToMatchKeyNameMap.containsKey(priorityNumber)) {
    		this.MatchKey = Constants.priorityNumberToMatchKeyNameMap.get(priorityNumber);
    	}

    	this.Id = customerRec.Id;
    	this.COURecords = new List<CustomerOwnedUnitWrapper>();
    	for(Customer_Owned_Unit__c couRec : couList) {
    		this.COURecords.add(new CustomerOwnedUnitWrapper(couRec));
    	}
    }
    
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: COLineItem - Class Object
    **/
    public static CustomerSuggestion parse(String json) {
        return (CustomerSuggestion) System.JSON.deserialize(json, CustomerSuggestion.class);
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> customerSuggestionFields = new List<String>{ 'Id',
                                                        'Name',
                                                        'FirstName__c',
                                                        'LastName__c', 
                                                        'Facebook__c',
                                                        'Email__c',
                                                        'Home_Number__c',
                                                        'Is_Customer__c',
                                                        'LinkedIn__c',
                                                        'Mobile__c',
                                                        'Other_Email__c',
                                                        'Twitter__c',
                                                        'Work_Email__c',
                                                        'Work_Number__c',
                                                        'Type__c',
                                                        'BillingStreet',
                                                        '(Select Id, Unit_Id__c, Unit_Make__r.Name, Unit_Model__r.Name__c, Sub_Model__r.Sub_Model_Name__c, Year__c ' +
                                                        	'from Customer_Owned_Units__r where Unit_Type__c = \'COU\')'
                                                };
        return customerSuggestionFields;
    }
    
    
    global Integer compareTo(Object compareTo) {
    	CustomerSuggestion compareToWrapperObj = ((CustomerSuggestion)compareTo);
    	Integer returnValue = 0;
    	if (PriorityValue == compareToWrapperObj.PriorityValue) return 0;
        if (PriorityValue > compareToWrapperObj.PriorityValue) return 1;
        return -1; 
    }
    
    public class CustomerOwnedUnitWrapper {
    	public String Id;
    	public String Description;
    	
    	public CustomerOwnedUnitWrapper(Customer_Owned_Unit__c couRec) {
    		String make = (couRec.Unit_Make__c != null && String.isNotBlank(couRec.Unit_Make__r.Name)) ? ' ' + couRec.Unit_Make__r.Name : '';
    		String model = (couRec.Unit_Model__c != null && String.isNotBlank(couRec.Unit_Model__r.Name__c)) ? ' ' + couRec.Unit_Model__r.Name__c : '';
			String subModel =  (couRec.Sub_Model__c != null && String.isNotBlank(couRec.Sub_Model__r.Sub_Model_Name__c)) ? ' ' + couRec.Sub_Model__r.Sub_Model_Name__c : '';
			String year =  (couRec.Year__c != null) ? ' ' + couRec.Year__c : '';
    		this.Description = (String.isNotBlank(couRec.Unit_Id__c) ? couRec.Unit_Id__c : '') + make + model + subModel + year;
    		this.Id = couRec.Id;
    	}
    }
}