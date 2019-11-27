/**
 * Author: Tarun Khandelwal
 * Since: April 22, 2014
 * Name: CODeposit
 * Description: Used to convert CODeposit JSON serialize and deserialize operations
**/
public with sharing class CODeposit {
    
     // Deposit Name
    public String DepositName{get; set;}
    
    // COHeader Id
    public String COHeaderId{get; set;}
    
    // Assignee
    public String PaymentMethod{get; set;}
    
    // Assignee Name
    public Decimal Amount{get; set;}
    
    // Created Date
    public String CreatedDate {get; set;}
    public String CreatedDate_Formatted;	//For new Co
    
    // CO Deposit Id
    public String CODepositId {get; set;}
    
    // CO invoice Number
    public String COInvoiceNumber {get; set;}
    
    public String Deal {get; set;}
    
    public String RecordedFrom {get;set;}
    
    public String ReverseLink {get; set;}
    
    public String CashDrawerId {get;set;}
    
    public String PaymentDate {get;set;}
    
    public String PaymentDate_Formatted {get;set;}
    
    // Constructor 
    public CODeposit(CO_Deposit__c coDepositObj) { 
        this.DepositName = coDepositObj.Name; 
        this.COHeaderId = coDepositObj.CO_Header__c;
        this.PaymentMethod = coDepositObj.Payment_Method__c;
        this.Amount = (coDepositObj.Amount__c != null) ? coDepositObj.Amount__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
        if(coDepositObj.Id != null) {
            this.CODepositId = coDepositObj.Id;
            this.CreatedDate = BPUtility.getExtendedMonthFormat(DateTime.valueOf(coDepositObj.CreatedDate)); 
        	this.CreatedDate_Formatted = (coDepositObj.CreatedDate != null) ? 
								BPUtility.getFormatedDateTime(datetime.newInstance(coDepositObj.CreatedDate.year(), coDepositObj.CreatedDate.month(), coDepositObj.CreatedDate.day())) : '' ;
        } else {
            this.CreatedDate = '';
            this.CreatedDate_Formatted = '';
        }
        if(coDepositObj.CO_Invoice_Header__c != null) {
        	this.COInvoiceNumber = coDepositObj.CO_Invoice_Header__r.Invoice_Number__c;
        } else {
        	this.COInvoiceNumber = '';
        }  
        this.Deal = coDepositObj.Deal__c;
        this.RecordedFrom = coDepositObj.Recorded_From__c;  
        this.ReverseLink = coDepositObj.Reverse_Link__c;
        this.CashDrawerId = coDepositObj.Cash_Drawer__c;
    	this.PaymentDate = (coDepositObj.Payment_Date__c != null) ? BPUtility.getFormatedDateTime(Date.valueOf(coDepositObj.Payment_Date__c)) : BPUtility.getFormatedDateTime(date.today());
    	this.PaymentDate_Formatted = (coDepositObj.Payment_Date__c != null) ? BPUtility.getFormatedDateTimewithSeparator(coDepositObj.Payment_Date__c, '-'): BPUtility.getFormatedDateTime(date.today());
    }     
    
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: CODeposit - Class Object
    **/
      public static List<CODeposit> parse(String json) {
        return (List<CODeposit>) System.JSON.deserialize(json, List<CODeposit>.class);
      }
  
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> CODepositFields = new List<String>{ 'Id',
                            'Name', 
                            'CO_Header__c',
                            'Amount__c',
                            'Payment_Method__c',
                            'CreatedDate',
                            'CO_Invoice_Header__c',
                            'CO_Invoice_Header__r.Name',
                            'CO_Invoice_Header__r.Invoice_Number__c',
                            'Recorded_From__c',
                            'Deal__c',
                            'Reverse_Link__c',
                            'Cash_Drawer__c',
                            'Payment_Date__c'
                           };
        return CODepositFields;
    }
}