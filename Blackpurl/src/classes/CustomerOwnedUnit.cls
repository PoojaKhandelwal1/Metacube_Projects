/**
 * Author: Tarun Khandelwal
 * Since: May 20, 2015
 * Name: CustomerOwnedUnit
 * Description: Apex class to handle JSON related oprations of Customer Owned Unit object.
**/
public with sharing class CustomerOwnedUnit {
	
	public String Id;
    public String VIN;
    public Decimal Year;
    public String Make;
    public String MakeName;
    public String ModelName;
    public String Model;
    public String SubModel;
    public String SubModelName;
    public String MakeModelDescription;
    public String ManufacturedDate;
    public String Plate;
    
    public Decimal Mileage;
    public String Color;
    public String Name;
    public String OtherSerialNo;
    public String EngineSerialNo;
    public String MileageType;
    public String KeyNo;
    public String InteriorColour;
    public Decimal Displacement;
    public Decimal Cylinders;
    public Decimal Gears;
    public String UnitType;
    
    public Boolean IsTaxable;
    public Boolean IsActive;
    public String ApplicableTax;
    public String ApplicableTaxName;
    public Boolean IsAutomatic;
    
    public String Status;
    public Boolean IsNewUnit;
    public String DateIn;
    public String DateOut;
    public Decimal Age;
    public String Location;
    public String Category;
    public String CategoryName;
    public String StockId;
    public String UnitId;
    public String StatusColor;
    public String CustomerId;
    public String FactoryOrderNo;
    public String FormattedName;
    
    /* added by kajal 26th april, 2017 #1937 */
    public String BaseUnitId;
    public Decimal TotalBasePrice;
    public Decimal TotalBaseCost;
    /* added by kajal 26th april, 2017 #1937 */
    public String RegExpiryDate;/* added by kajal 1st may, 2017 #1975 */
    public String ComplianceDate;
    public String YearOf1stRego;
    public String RegistrationSerial;
    public List<String> AssignedTags;
    
    // Constructor
    public CustomerOwnedUnit(Customer_Owned_Unit__c coUnitRec) {
    	
    	this.VIN = coUnitRec.VIN_Number__c;
    	this.Year = coUnitRec.Year__c;
    	this.Make = coUnitRec.Unit_Make__c;
    	this.MakeName = (coUnitRec.Unit_Make__c != null) ? coUnitRec.Unit_Make__r.Name : '';
    	this.Name = coUnitRec.Name;
    	
    	this.Plate = coUnitRec.Plate__c;
    	this.Color = coUnitRec.Colour__c;
    	this.Id = coUnitRec.Id;
    	
    	this.Mileage = coUnitRec.Mileage_Value__c;
    	this.MileageType = coUnitRec.Mileage_Type__c;
    	this.OtherSerialNo = coUnitRec.Other_Serial_No__c;
    	this.KeyNo = coUnitRec.Key_No__c;
    	this.InteriorColour = coUnitRec.Interior_Colour__c;
    	this.EngineSerialNo = coUnitRec.Engine_Serial_No__c;
    	this.Displacement = coUnitRec.Displacement__c;
    	this.Cylinders = coUnitRec.Cylinders__c;
    	this.Gears = coUnitRec.Gears__c;
    	this.UnitType = coUnitRec.Unit_Type__c;
    	this.StockId = coUnitRec.Stock_Id__c;
    	this.UnitId = coUnitRec.Unit_Id__c;
        this.Model = coUnitRec.Unit_Model__c;
    	this.ModelName = (coUnitRec.Unit_Model__c != null) ? coUnitRec.Unit_Model__r.Name__c : '';
        this.SubModel = coUnitRec.Sub_Model__c;
		this.SubModelName =  (coUnitRec.Sub_Model__c != null) ? coUnitRec.Sub_Model__r.Sub_Model_Name__c : '';
    		
    	this.MakeModelDescription = (coUnitRec.Sub_Model__c != null) ? coUnitRec.Sub_Model__r.Sub_Model_Description__c : '';
    	if(coUnitRec.Manufactured_Date__c != null){
    		this.ManufacturedDate = BPUtility.getFormatedDateTime(datetime.newInstance(coUnitRec.Manufactured_Date__c.year(), coUnitRec.Manufactured_Date__c.month(),coUnitRec.Manufactured_Date__c.day()));
    	}
    	this.IsTaxable = coUnitRec.Taxable__c;
    	this.ApplicableTax = coUnitRec.Applicable_Tax__c;
    	this.ApplicableTaxName = (coUnitRec.Applicable_Tax__c != null) ? coUnitRec.Applicable_Tax__r.Name__c : '';
    	this.Displacement = coUnitRec.Displacement__c;
    	this.IsAutomatic = coUnitRec.Automatic__c;
    	
    	this.Status = coUnitRec.Status__c;
    	this.IsNewUnit = coUnitRec.New_Unit__c;
    	this.Category = coUnitRec.Category__c;
    	this.CategoryName = (coUnitRec.Category__c != null) ? coUnitRec.Category__r.Name : '';
    	this.CustomerId = coUnitRec.Account__c;
    	if(coUnitRec.Date_Stocked_In__c != null){
    		this.DateIn = BPUtility.getFormatedDateTime(datetime.newInstance(coUnitRec.Date_Stocked_In__c.year(), coUnitRec.Date_Stocked_In__c.month(),coUnitRec.Date_Stocked_In__c.day()));
    	}
    	if(coUnitRec.Date_Stocked_Out__c != null){
    		this.DateOut = BPUtility.getFormatedDateTime(datetime.newInstance(coUnitRec.Date_Stocked_Out__c.year(), coUnitRec.Date_Stocked_Out__c.month(),coUnitRec.Date_Stocked_Out__c.day()));
    	}
    	//this.DateIn = (coUnitRec.Date_Stocked_In__c != null) ? coUnitRec.Date_Stocked_In__c;
    	//this.DateOut = coUnitRec.Date_Stocked_Out__c;
		this.Age = coUnitRec.Age__c;
    	this.Location = coUnitRec.Location__c;
    	if(this.UnitType == 'STOCK') {
    		if(coUnitRec.Status__c == 'Available') {
    			this.StatusColor = 'Green';
    		} else if(coUnitRec.Status__c == 'Reserved' || coUnitRec.Status__c == 'Sold'){
    			this.StatusColor = 'Red';
    		} else if(coUnitRec.Status__c == 'Traded' || coUnitRec.Status__c == 'Delivered'){
    			this.StatusColor = 'Black';
    		}
    	
    	} else if(this.UnitType == 'COU') {
    		if(coUnitRec.Status__c == 'Active') {
    			this.StatusColor = 'Green';
    		} else if(coUnitRec.Status__c == 'Inactive'){
    			this.StatusColor = 'Red';
    		} else if(coUnitRec.Status__c == 'Transferred'){
    			this.StatusColor = 'Black';
    		}
    	
    	} else if(this.UnitType == 'ORDU') {
    		if(coUnitRec.Status__c == 'On Order') {
    			this.StatusColor = 'Red';
    		} else if(coUnitRec.Status__c == 'Cancelled' || coUnitRec.Status__c == 'Traded'){
    			this.StatusColor = 'Black';
    		}
    	}
    	
    	this.IsActive = (coUnitRec.Status__c == 'Inactive') ? false : true;
    	
    	this.FactoryOrderNo = coUnitRec.Factory_Order_No__c;
    	this.FormattedName = coUnitRec.Formatted_Name__c;
    	this.ComplianceDate = coUnitRec.Compliance_Date__c;
    	this.RegistrationSerial = coUnitRec.Registration_Serial__c;
    	this.YearOf1stRego = coUnitRec.Year_Of_1st_Rego__c;
    	/* added by kajal 26th april, 2017 #1937 */
    	if(coUnitRec.Unit_Prices_Costs__r.size() > 0) {
    		this.BaseUnitId = coUnitRec.Unit_Prices_Costs__r[0].Id;
    		this.TotalBaseCost = (coUnitRec.Unit_Prices_Costs__r[0].Total_Cost__c != null) ? coUnitRec.Unit_Prices_Costs__r[0].Total_Cost__c : 0;
    		this.TotalBasePrice = (coUnitRec.Unit_Prices_Costs__r[0].Total_Price__c != null) ? coUnitRec.Unit_Prices_Costs__r[0].Total_Price__c : 0;
    	} else {
    		this.TotalBaseCost = 0;
    		this.TotalBasePrice = 0;
    	}
    	/* added by kajal 26th april, 2017 #1937 */
    	/* added by kajal 1st may, 2017 #1975 */
    	if(coUnitRec.Reg_Expiry_Date__c != null){
    		this.RegExpiryDate = BPUtility.getFormatedDateTime(datetime.newInstance(coUnitRec.Reg_Expiry_Date__c.year(), coUnitRec.Reg_Expiry_Date__c.month(),coUnitRec.Reg_Expiry_Date__c.day()));
    	}
    	/* added by kajal 1st may, 2017 #1975 */
    	
    	this.AssignedTags = TagUtil.getTagsList(coUnitRec);
    }
    
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: COLineItem - Class Object
    **/
    public static List<CustomerOwnedUnit> parse(String json) {
        return (List<CustomerOwnedUnit>) System.JSON.deserialize(json, List<CustomerOwnedUnit>.class);
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> COUFields = new List<String>{ 'Id',
                                                    'Name', 
                                                    'VIN_Number__c',
                                                    'Account__c',
                                                    'Colour__c',
                                                    'Mileage_Value__c',
                                                    'Plate__c',
                                                    'Vendor__c',
                                                    'Submodel__c',
                                                    'Sub_Model__c',
                                                    'Sub_Model__r.Sub_Model_Name__c',
                                                    'Sub_Model__r.Sub_Model_Description__c',
                                                    'Unit_Make__c',
                                                    'Unit_Make__r.Name',
                                                    'Unit_Model__c',
                                                    'Unit_Model__r.Name__c',
                                                    'Unit_Model__r.Sub_Model__c',
                                                    'Unit_Model__r.Unit_Make__r.Name',
                                                    'Year__c',
                                                    'Manufactured_Date__c',
                                                    'Unit_Model__r.Model_Description__c',
                                                    'Mileage_Type__c',
                                                    'Key_No__c',
                                                    'Interior_Colour__c',
                                                    'Engine_Serial_No__c',
                                                    'Other_Serial_No__c',
                                                    'Displacement__c',
                                                    'Cylinders__c',
                                                    'Gears__c',
                                                    'Status__c',
                                                    'Unit_Type__c',
                                                    'Taxable__c',
                                                    'Applicable_Tax__c',
                                                    'Applicable_Tax__r.Name__c',
                                                    'Automatic__c',
                                                    'New_Unit__c',
                                                    'Category__c',
                                                    'Category__r.Name',
                                                    'Age__c',
                                                    'Location__c',
                                                    'Stock_Id__c',
                                                    'Unit_Id__c',
                                                    'Factory_Order_No__c',
                                                    'Formatted_Name__c',
                                                    'Date_Stocked_In__c',
                                                    'Date_Stocked_Out__c',
                                                    'Total_Base_Units_Cost__c',
                                                    'Total_Base_Unit_Price__c',
                                                    'Reg_Expiry_Date__c',
                                                    'Assigned_Tag_1__c',
                                                    'Assigned_Tag_2__c',
                                                    'Tax_Amount__c',
                                                    'ORDU_Stock_Id__c',
                                                    'Stocked_In_DateTime__c',
                                        			'Compliance_Date__c',
                                                    'Registration_Serial__c',
                                                    'Year_Of_1st_Rego__c'
                                                };/*total cost and price fields added by kajal 26th april, 2017 #1937 *//* Reg_Expiry_Date__c added by kajal 1st may, 2017 #1975 */
        return COUFields;
    }
    
    public static List<String> getSimilarMatchingFieldsForUnits() {
    	List<String> matchingFields = new List<String>{'Plate__c',
    													'Engine_Serial_No__c',
    													'Other_Serial_No__c',
    													'VIN_Number__c'
    													};
    	return matchingFields;
    }
}