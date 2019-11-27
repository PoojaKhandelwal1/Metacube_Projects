/**
 * Author: Tarun Khandelwal
 * Since: Aug 03, 2016
 * Name: UnitSuggestion
 * Description: Apex class to handle JSON related oprations of similar units
**/
global with sharing class UnitSuggestion implements Comparable{
    
    public String Id;
    public String VIN;
    public String UnitType;
    public String UniqueId;
    
    public String MakeId;
    public String MakeName;
    public String ModelId;
    public String ModelName;
    public String SubModelName;
    public Decimal Year;
    
    public String InteriorColour;
    public String Status;
    public String StatusColor;
    public Integer PriorityNumber;
    
    public UnitSuggestion(Customer_Owned_Unit__c unitRec, Integer priorityNumber) {
    	this.VIN = unitRec.VIN_Number__c;
    	this.UnitType = unitRec.Unit_Type__c;
    	this.Id = unitRec.Id;
    	if(unitRec.Unit_Type__c == 'COU' || unitRec.Unit_Type__c == 'ORDU') {
    		this.UniqueId = unitRec.Unit_Id__c;
    	} else if(unitRec.Unit_Type__c == 'STOCK') {
    		this.UniqueId = unitRec.Stock_Id__c;
    	}
    	this.MakeId = unitRec.Unit_Make__c;
    	this.MakeName = (unitRec.Unit_Make__c != null) ? unitRec.Unit_Make__r.Name : '';
    	this.ModelId = unitRec.Unit_Model__c;
    	this.ModelName = (unitRec.Unit_Model__c != null) ? unitRec.Unit_Model__r.Name__c : '';
    	this.SubModelName = (unitRec.Unit_Make__c != null) ? unitRec.Unit_Model__r.Sub_Model__c : '';
    	this.SubModelName = (unitRec.Sub_Model__c != null) ? unitRec.Sub_Model__r.Sub_Model_Name__c : '';
    	this.Year = unitRec.Year__c;
    	this.InteriorColour = unitRec.Interior_Colour__c;
    	this.Status = unitRec.Status__c;
    	
    	if(this.UnitType == 'STOCK') {
    		if(unitRec.Status__c == 'Available') {
    			this.StatusColor = 'Green';
    		} else if(unitRec.Status__c == 'Reserved' || unitRec.Status__c == 'Sold'){
    			this.StatusColor = 'Red';
    		} else if(unitRec.Status__c == 'Traded' || unitRec.Status__c == 'Delivered'){
    			this.StatusColor = 'Black';
    		}
    	
    	} else if(this.UnitType == 'COU') {
    		if(unitRec.Status__c == 'Active') {
    			this.StatusColor = 'Green';
    		} else if(unitRec.Status__c == 'Inactive'){
    			this.StatusColor = 'Red';
    		} else if(unitRec.Status__c == 'Transferred'){
    			this.StatusColor = 'Black';
    		}
    	
    	} else if(this.UnitType == 'ORDU') {
    		if(unitRec.Status__c == 'On Order') {
    			this.StatusColor = 'Red';
    		} else if(unitRec.Status__c == 'Cancelled' || unitRec.Status__c == 'Traded'){
    			this.StatusColor = 'Black';
    		}
    	}
    	this.PriorityNumber = priorityNumber;
    }
    
    global Integer compareTo(Object compareTo) {
    	UnitSuggestion compareToWrapperObj = ((UnitSuggestion)compareTo);
    	Integer returnValue = 0;
    	if (PriorityNumber == compareToWrapperObj.PriorityNumber) return 0;
        if (PriorityNumber > compareToWrapperObj.PriorityNumber) return 1;
        return -1; 
    }
}