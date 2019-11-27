/**
 * Author: Richa Mittal
 * Since: Jan 05, 2017
 * Name: AccountingCODeposit
 * Description: Apex class to handle JSON related oprations of deposit of CO header for Accounting.
**/
public with sharing class AccountingCODeposit {
    
     // Deposit Name
    public String DepositName{get; set;}
    
    // COHeader Id
    public String COHeaderId{get; set;}
    
    // Assignee
    public String PaymentMethod{get; set;}
    
    // Assignee Name
    public Decimal Amount{get; set;}
    
    // Created Date
    public Date CreatedDate {get; set;}
    
    // CO Deposit Id
    public String CODepositId {get; set;}
    
    // CO invoice Number
    public String COInvoiceNumber {get; set;}
    
    // Customer payment Journal Entry AccountingId
	public String JournalEntryAccountingId;
	    
    // Customer payment Journal Entry SyncToken
    public String JournalEntrySyncToken;
    
    public String JournalEntryAccountingResponse;
    
    public CustomerWrapper customer {get; set;}
    
    public String CustomerOrderNumber;
    
    public Date PaymentDate;
    
    public String COType;
    
    public String XeroAccountingId;
    
    public String ReverseLink;
    
    // Constructor
    public AccountingCODeposit(CO_Deposit__c coDepositObj) {
        this.DepositName = coDepositObj.Name;
        this.COHeaderId = coDepositObj.CO_Header__c;
        this.PaymentMethod = coDepositObj.Payment_Method__c;
        this.Amount = (coDepositObj.Amount__c != null) ? coDepositObj.Amount__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
        if(coDepositObj.Id != null) {
            this.CODepositId = coDepositObj.Id;
            this.CreatedDate = DateTimeUtility.getDateFromFormattedDateStr(DateTimeUtility.getFormttedDateFromDateTime(coDepositObj.CreatedDate, 'dd/MM/yyyy'));//String.valueOf(DateTime.valueOf(coDepositObj.CreatedDate).format('dd/MMM/yyyy')); 
        	this.PaymentDate = coDepositObj.Payment_Date__c;
        }  
        if(coDepositObj.CO_Invoice_Header__c != null) {
        	this.COInvoiceNumber = coDepositObj.CO_Invoice_Header__r.Invoice_Number__c;
        } else {
        	this.COInvoiceNumber = '';
        } 
         
        this.JournalEntryAccountingId = coDepositObj.AccountingIdForJournalEntry__c;
        this.JournalEntrySyncToken = coDepositObj.SyncTokenForJournalEntry__c;
        this.JournalEntryAccountingResponse = coDepositObj.AccountingResponseForJournalEntry__c;
        
        this.customer = new CustomerWrapper(coDepositObj.CO_Header__r.Customer__r.AccountingId__c, coDepositObj.CO_Header__r.Customer__r.Name);
        
        this.CustomerOrderNumber = coDepositObj.CO_Header__r.Name;
        
        this.COType = coDepositObj.CO_Header__r.CO_Type__c;
        this.XeroAccountingId = coDepositObj.Xero_Accounting_Id__c;
        this.ReverseLink = coDepositObj.Reverse_Link__c;
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
            				'CO_Header__r.Name',
            				'CO_Header__r.Customer__c',
            				'CO_Header__r.Customer__r.AccountingId__c',
            				'CO_Header__r.Customer__r.Name',
                            'Amount__c',
                            'Payment_Method__c',
                            'CreatedDate',
                            'CO_Invoice_Header__c',
                            'CO_Invoice_Header__r.Name',
                            'CO_Invoice_Header__r.Invoice_Number__c',
            				'availForQBJournalEntrySync__c',
                            'AccountingResponseForJournalEntry__c',
                            'AccountingIdForJournalEntry__c',
                            'SyncTokenForJournalEntry__c',
                            'CO_Header__r.CO_Type__c',
                            'Xero_Accounting_Id__c',
                            'Reverse_Link__c',
                            'Payment_Date__c'
                           };
        return CODepositFields;
    }
    
    public class CustomerWrapper{
    	
    	public String AccountingId {get; set;}
    	public String Name {get; set;} 
    	
    	public CustomerWrapper(String AccountingId, String Name) {
    		this.AccountingId = AccountingId;
    		this.Name = Name;
    		
    	}
    }
    
}