/**
 * Author: Tarun Khandelwal
 * Since: May 15, 2015
 * Name: Customer
 * Description: Apex class to handle JSON related oprations of Customer object.
**/
public with sharing class Customer {
    
    // Customer Name
    public String BusinessName {get; set;}
    
    // Customer First Name
    public String FirstName {get; set;}
    
    // Customer Last Name
    public String LastName {get; set;} 
    
    // Active Customer
    public Boolean Active {get; set;}
    
    // Birth Date
    public Date Birthdate {get; set;}
    
    // Birth Month
    public Integer BirthMonth {get; set;}
    
    // Birth Date
    public Integer BirthDay {get; set;}
    
    // Birth Year
    public Integer BirthYear {get; set;}
    
    // Company Name
    public String Company {get; set;}
    
    // FaceBook Link
    public String FacebookLink {get; set;}
    
    // Twitter Link 
    public String TwitterLink {get; set;}
    
    // Linkedin Link
    public String LinkedInLink {get; set;}
    
    // Home Eamil Address
    public String HomeEmail {get; set;}
    
    // Work Email Address
    public String WorkEmail {get; set;}
    
    // Other Email Address
    public String OtherEmail {get; set;}
    
    // Home Number
    public String HomeNumber {get; set;}
    // Home Number
    public String FormattedHomeNumber {get; set;}
    
    // Mobile Number
    public String OtherPhone {get; set;}
    
    // Work Number
    public String WorkNumber {get; set;}
    
    // Mobile Number
    public String FormattedOtherPhone {get; set;}
    
    // Work Number
    public String FormattedWorkNumber {get; set;}
    
    // Is Home Number is treated as SMS ?
    public Boolean HomeNumberSMS {get; set;}
    
    // Is Mobile Number is treated as SMS ?
    public Boolean MobileNumberSMS {get; set;}
    
    // Is Work Number is treated as SMS ?
    public Boolean WorkNumberSMS {get; set;}
    
    // Is Customer
    public Boolean IsCustomer {get; set;}
    
    // Is vendor
    public Boolean IsVendor {get; set;}
    
    // Job Title
    public String JobTitle {get; set;}
    
    // Nick Name
    public String Nickname {get; set;}
    
    // Preferred Email
    public String PreferredEmail {get; set;}
    
    // Preferred Phone
    public String PreferredPhone {get; set;}
    
    // Preferred SMS
    public String PreferredSMS {get; set;}
    
    // Preferred Phone
    public String FormattedPreferredPhone {get; set;}
    
    // Preferred SMS
    public String FormattedPreferredSMS {get; set;}
    
    // Is Both Address Same - Shipping Address and Billing Address?
    public Boolean IsBothAddressSame {get; set;}
    
    // Type__c
    public String Type {get; set;}
    
    public String TaxExemptions {get; set;}
    
    // Billing Address Fields
    public String BillingStreet1 {get; set;}
    public String BillingStreet2 {get; set;}
    public String BillingCity {get; set;}
    public String BillingState {get; set;}
    public String BillingCountry {get; set;}
    public String BillingPostalCode {get; set;}
    
    // Shipping Address Fields
    public String ShippingStreet1 {get; set;}
    public String ShippingStreet2 {get; set;}
    public String ShippingCity {get; set;}
    public String ShippingState {get; set;}
    public String ShippingCountry {get; set;}
    public String ShippingPostalCode {get; set;}
    
    // Id
    public String Id {get; set;}
    
    // Price Level ID
    public String PriceLevelId {get; set;}
    
    // Price Leel Name
    public String PriceLevelName {get; set;}
    
    // SalesTax ID
    public String SalesTaxId {get; set;}
    
    // Price Leel Name
    public String SalesTaxName {get; set;}
    
    // SalesTax ID
    public String PurchaseTaxId {get; set;}
    
    // Price Leel Name
    public String PurchaseTaxName {get; set;}
    
    // Customer Number
    public String CustomerNumber {get; set;}
    
    public Decimal TotalStoreCredit;
    
    //Account type
    public String AccountTypeName;
    public String AccountTypeId;

    public String DriversLicense;
    public String Notes;
    
    // Constructor
    public Customer(Account customerRec) { 
        populateCustomerRec(customerRec);
    }
    
    public Customer(Account customerRec,String taxExmptionList) { 
        populateCustomerRec(customerRec);
        this.TaxExemptions = taxExmptionList;
    }
    
    private void populateCustomerRec(Account customerRec) {
    	this.BusinessName = customerRec.Name;
        this.FirstName = customerRec.FirstName__c;
        this.LastName = customerRec.LastName__c;
        
        this.HomeEmail = (customerRec.Email__c == null) ? '' : customerRec.Email__c;
        this.HomeNumber = (customerRec.Home_Number__c == null ) ? '' : customerRec.Home_Number__c;
        this.FormattedHomeNumber = (customerRec.Formatted_Home_number__c == null ) ? '' : customerRec.Formatted_Home_number__c;
        this.AccountTypeName = customerRec.Account_type__r.Name;
        this.AccountTypeId = customerRec.Account_type__r.Id;
        // Address fields
        String billingStreet = (customerRec.BillingStreet == null ) ? '' : customerRec.BillingStreet;
        List<String> bsList = billingStreet.split('\n');
        this.BillingStreet1 = (bsList.size() > 0) ? bsList[0] : '';
        this.BillingStreet2 = (bsList.size() > 1) ? bsList[1] : '';
        this.BillingCity = (customerRec.BillingCity == null) ? '' : customerRec.BillingCity;
        this.BillingState = (customerRec.BillingState == null) ? '' : customerRec.BillingState;
        this.BillingCountry = (customerRec.BillingCountry == null) ? '' : customerRec.BillingCountry;
        this.BillingPostalCode = (customerRec.BillingPostalCode == null) ? '' : customerRec.BillingPostalCode;
        
        String shippingStreet = (customerRec.ShippingStreet == null ) ? '' : customerRec.ShippingStreet;
        List<String> ssList = shippingStreet.split('\n');
        this.ShippingStreet1 = (ssList.size() > 0) ? ssList[0] : '';
        this.ShippingStreet2 = (ssList.size() > 1) ? ssList[1] : '';
        this.ShippingCity = (customerRec.ShippingCity == null) ? '' : customerRec.ShippingCity;
        this.ShippingState = (customerRec.ShippingState == null) ? '' : customerRec.ShippingState;
        this.ShippingCountry = (customerRec.ShippingCountry == null) ? '' : customerRec.ShippingCountry;
        this.ShippingPostalCode = (customerRec.ShippingPostalCode == null) ? '' : customerRec.ShippingPostalCode;
        this.IsBothAddressSame = customerRec.SA_same_as_BA__c;
        
        // Addtional Fields
        this.Birthdate = customerRec.Birth_Date__c;
        if(customerRec.Birth_Date__c != null) {
            this.BirthDay = customerRec.Birth_Date__c.day();
            this.BirthMonth = customerRec.Birth_Date__c.month();
            this.BirthYear = customerRec.Birth_Date__c.year();
        }
         
        this.Active = customerRec.Active__c;
        this.Company = (customerRec.Company_Name__c == null) ? '' : customerRec.Company_Name__c;
        this.JobTitle = (customerRec.Job_Title__c == null) ? '' : customerRec.Job_Title__c;
        
        // Phone And Email
        this.WorkEmail = (customerRec.Work_Email__c == null) ? '' : customerRec.Work_Email__c;
        this.OtherEmail = (customerRec.Other_Email__c == null) ? '' : customerRec.Other_Email__c;
        this.OtherPhone = (customerRec.Mobile__c == null) ? '' : customerRec.Mobile__c;
        this.FormattedOtherPhone = (customerRec.Formatted_Mobile_Number__c == null) ? '' : customerRec.Formatted_Mobile_Number__c;
        this.WorkNumber = (customerRec.Work_Number__c == null) ? '' : customerRec.Work_Number__c;
        this.FormattedWorkNumber = (customerRec.Formatted_Work_Number__c == null) ? '' : customerRec.Formatted_Work_Number__c;
        this.HomeNumberSMS = customerRec.Home_Number_SMS__c;
        this.MobileNumberSMS = customerRec.Mobile_Number_SMS__c;
        this.WorkNumberSMS = customerRec.Work_Number_SMS__c;
        
        if(customerRec.Preferred_Email__c != null) {
            if(customerRec.Preferred_Email__c == customerRec.Email__c) {
                this.PreferredEmail = 'HomeEmail';
            } else if(customerRec.Preferred_Email__c == customerRec.Work_Email__c) {
                this.PreferredEmail = 'WorkEmail';
            } else if(customerRec.Preferred_Email__c == customerRec.Other_Email__c) {
                this.PreferredEmail = 'OtherEmail';
            }
        } else {
            this.PreferredEmail = '';
        }
        
        if(customerRec.Preferred_Phone__c != null) {
            if(customerRec.Preferred_Phone__c == customerRec.Home_Number__c) {
                this.PreferredPhone = 'HomeNumber';
                this.FormattedPreferredPhone = 'FormattedHomeNumber';
            } else if(customerRec.Preferred_Phone__c == customerRec.Mobile__c) {
                this.PreferredPhone = 'OtherPhone';
                this.FormattedPreferredPhone = 'FormattedOtherPhone';
            } else if(customerRec.Preferred_Phone__c == customerRec.Work_Number__c) {
                this.PreferredPhone = 'WorkNumber';
                this.FormattedPreferredPhone = 'FormattedWorkNumber';
            }
        } else {
            this.PreferredPhone = '';
            this.FormattedPreferredPhone = '';
        }
        
        if(customerRec.Preferred_SMS__c != null) {
            if(customerRec.Preferred_SMS__c == customerRec.Home_Number__c) {
                this.PreferredSMS = 'HomeNumber';
                this.FormattedPreferredSMS = 'FormattedHomeNumber';
            } else if(customerRec.Preferred_SMS__c == customerRec.Mobile__c) {
                this.PreferredSMS = 'OtherPhone';
                this.FormattedPreferredSMS = 'FormattedOtherPhone';
            } else if(customerRec.Preferred_SMS__c == customerRec.Work_Number__c) {
                this.PreferredSMS = 'WorkNumber';
                this.FormattedPreferredSMS = 'FormattedOtherPhone';
            }
        } else {
            this.PreferredSMS = '';
            this.FormattedPreferredSMS = '';
        }
        
        this.IsCustomer = customerRec.Is_Customer__c;
        this.IsVendor = customerRec.Is_Vendor__c;
        this.Nickname = (customerRec.Nickname__c == null) ? '' : customerRec.Nickname__c;
        this.Type = customerRec.Type__c;
        this.FacebookLink = (customerRec.Facebook__c == null) ? '' : customerRec.Facebook__c;
        this.TwitterLink = (customerRec.Twitter__c == null) ? '' : customerRec.Twitter__c;
        this.LinkedInLink = (customerRec.LinkedIn__c == null) ? '' : customerRec.LinkedIn__c;
        
        this.Id = (customerRec.Id == null) ? '' : customerRec.Id; 
        
        this.PriceLevelId = customerRec.Price_Level__c;
        this.PriceLevelName = (customerRec.Price_Level__c == null) ? '' : customerRec.Price_Level__r.Name__c;
        this.SalesTaxId = customerRec.Sales_Tax__c;
        this.SalesTaxName = (customerRec.Sales_Tax__c == null) ? '' : customerRec.Sales_Tax__r.Name__c;
        this.PurchaseTaxId = customerRec.Purchase_Tax__c;
        this.PurchaseTaxName = (customerRec.Purchase_Tax__c == null) ? '' : customerRec.Purchase_Tax__r.Name__c;
        this.CustomerNumber = customerRec.Customer_Number__c;
        this.TotalStoreCredit = customerRec.Total_Store_Credit__c;
        this.Notes = customerRec.Notes__c;
        this.DriversLicense = customerRec.Drivers_License__c;
    }
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: COLineItem - Class Object
    **/
    public static Customer parse(String json) {
        return (Customer) System.JSON.deserialize(json, Customer.class);
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
                                                        'Birth_Date__c',
                                                        'Company_Name__c',
                                                        'Facebook__c',
                                                        'Email__c',
                                                        'Home_Number__c',
                                                        'Home_Number_SMS__c',
                                                        'Is_Customer__c',
                                                        'Is_Vendor__c',
                                                        'Job_Title__c',
                                                        'LinkedIn__c',
                                                        'Mobile__c',
                                                        'Mobile_Number_SMS__c', 
                                                        'Nickname__c',
                                                        'Other_Email__c',
                                                        'Preferred_Email__c',
                                                        'Preferred_Phone__c',
                                                        'Preferred_SMS__c',
                                                        'Twitter__c',
                                                        'Type__c',
                                                        'Work_Email__c',
                                                        'Work_Number__c',
                                                        'Work_Number_SMS__c',
                                                        'SA_same_as_BA__c',
                                                        'BillingStreet',
                                                        'BillingCity',
                                                        'BillingState',
                                                        'BillingCountry',
                                                        'BillingPostalCode',
                                                        'ShippingStreet',
                                                        'ShippingCity',
                                                        'ShippingState',
                                                        'ShippingCountry',
                                                        'ShippingPostalCode',
                                                        'LastModifiedDate',
                                                        'Sales_Tax__c',
                                                        'Sales_Tax__r.Name__c',
                                                        'Price_Level__c',
                                                        'Price_Level__r.Name__c',
                                                        'Purchase_Tax__c',
                                                        'Purchase_Tax__r.Name__c',
                                                        'Orders_Lifetime__c',
                                                        'Open_Orders__c',
                                                        'Average_Spend_per_Order__c',
                                                        'Customer_Number__c',
                                                        'Formatted_Home_number__c',
                                                        'Formatted_Work_Number__c',
                                                        'Formatted_Mobile_Number__c',
                                                        'Total_Store_Credit__c',
                                                        'Account_type__r.Id',
                                                        'Account_type__r.Name',
                                                        'Notes__c',
                                                        'Drivers_License__c'
                                                };
        return customerFields;
    }
    
}