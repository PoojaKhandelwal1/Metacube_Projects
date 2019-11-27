public with sharing class CustomerWrapper_V2 {
    
    public String BusinessName {get; set;}
    public String FirstName {get; set;}
    public String LastName {get; set;} 
    public Boolean Active {get; set;}
    public String Company {get; set;}
    public String HomeEmail {get; set;}
    public String WorkEmail {get; set;}
    public String OtherEmail {get; set;}
    public String HomeNumber {get; set;}
    public String OtherPhone {get; set;}
    public String WorkNumber {get; set;}
    public Boolean IsCustomer {get; set;}
    public Boolean IsVendor {get; set;}
    public Boolean IsBothAddressSame {get; set;}
    public String Type {get; set;}
    public String BillingStreet1 {get; set;}
    public String BillingStreet2 {get; set;}
    public String BillingCity {get; set;}
    public String BillingState {get; set;}
    public String BillingCountry {get; set;}
    public String BillingPostalCode {get; set;}
    public String Id {get; set;}
    public String CustomerNumber {get; set;}
    public String AccountTypeId {get; set;}
    public String Birthdate {get; set;}
    public String JobTitle {get; set;}
    public Integer BirthMonth {get; set;}
    public Integer BirthDay {get; set;}
    public Integer BirthYear {get; set;}
    public String DriversLicense {get; set;}

    // Constructor
    public CustomerWrapper_V2(Account customerRec) { 
        this.BusinessName = customerRec.Name;
        this.FirstName = customerRec.FirstName__c;
        this.LastName = customerRec.LastName__c;
        
        this.HomeEmail = (customerRec.Email__c == null) ? '' : customerRec.Email__c;
        this.HomeNumber = (customerRec.Home_Number__c == null ) ? '' : customerRec.Home_Number__c;
        
        // Address fields
        String billingStreet = (customerRec.BillingStreet == null ) ? '' : customerRec.BillingStreet;
        List<String> bsList = billingStreet.split('\n');
        this.BillingStreet1 = (bsList.size() > 0) ? bsList[0] : '';
        this.BillingStreet2 = (bsList.size() > 1) ? bsList[1] : '';
        this.BillingCity = (customerRec.BillingCity == null) ? '' : customerRec.BillingCity;
        this.BillingState = (customerRec.BillingState == null) ? '' : customerRec.BillingState;
        this.BillingCountry = (customerRec.BillingCountry == null) ? '' : customerRec.BillingCountry;
        this.BillingPostalCode = (customerRec.BillingPostalCode == null) ? '' : customerRec.BillingPostalCode;
        
        this.IsBothAddressSame = customerRec.SA_same_as_BA__c;
        
        this.Active = customerRec.Active__c;
        this.Company = (customerRec.Company_Name__c == null) ? '' : customerRec.Company_Name__c;
        
        this.WorkEmail = (customerRec.Work_Email__c == null) ? '' : customerRec.Work_Email__c;
        this.OtherEmail = (customerRec.Other_Email__c == null) ? '' : customerRec.Other_Email__c;
        this.OtherPhone = (customerRec.Mobile__c == null) ? '' : customerRec.Mobile__c;
        this.WorkNumber = (customerRec.Work_Number__c == null) ? '' : customerRec.Work_Number__c;
        
        this.IsCustomer = customerRec.Is_Customer__c;
        this.IsVendor = customerRec.Is_Vendor__c;
        this.Type = customerRec.Type__c;
        
        this.Id = (customerRec.Id == null) ? '' : customerRec.Id; 
        this.CustomerNumber = customerRec.Customer_Number__c;
        this.AccountTypeId = customerRec.Account_Type__c;
        this.JobTitle = (customerRec.Job_Title__c == null) ? '' : customerRec.Job_Title__c;
        this.DriversLicense = (customerRec.Drivers_License__c == null) ? '' : customerRec.Drivers_License__c;
    }
    
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: COLineItem - Class Object
    **/
    public static CustomerWrapper_V2 parse(String json) {
        return (CustomerWrapper_V2) System.JSON.deserialize(json, CustomerWrapper_V2.class);
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> customerFields = new List<String>{ 'Id',
                                                        'Name',
                                                        'FirstName__c',
                                                        'LastName__c',
                                                        'Active__c',
                                                        'Company_Name__c',
                                                        'Email__c',
                                                        'Home_Number__c',
                                                        'Is_Customer__c',
                                                        'Is_Vendor__c',
                                                        'Job_Title__c',
                                                        'LinkedIn__c',
                                                        'Mobile__c',
                                                        'Nickname__c',
                                                        'Other_Email__c',
                                                        'Type__c',
                                                        'Work_Email__c',
                                                        'Work_Number__c',
                                                        'SA_same_as_BA__c',
                                                        'BillingStreet',
                                                        'BillingCity',
                                                        'BillingState',
                                                        'BillingCountry',
                                                        'BillingPostalCode',
                                                        'LastModifiedDate',
                                                        'Customer_Number__c',
                                                        'Birth_Date__c',
                                                        'Drivers_License__c'
                                                };
        return customerFields;
    }
    
}