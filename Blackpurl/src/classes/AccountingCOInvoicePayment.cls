/**
 * Author: Richa Mittal
 * Since: Dec 26, 2016
 * Name: AccountingCOInvoicePayment
 * Description: Apex class to handle JSON related oprations of paymrnt of CO Invoice for Accounting.
**/
public with sharing class AccountingCOInvoicePayment {
    
    // CO Invoice Header Id
    public String COInvoiceHeaderId {get; set;}
    
    // Customer Id
    public String CustomerId {get; set;}
    
    // Amount
    public Decimal Amount {get; set;}
    
    // CO Invoice Payment Number
    public String COInvoicePaymentNumber {get; set;}
    
    // CO Invoice Payment Id
    public String COInvoicePaymentId {get; set;}
    
    // Reverse Link
    public String ReverseLink {get; set;}
    
    // Payment Method
    public String PaymentMethod {get; set;}
    
    // Created Date
    public String CreatedDate {get; set;} 
    
    // Is Reverse Payment
    public Boolean IsReverse {get; set;} // 05/11/2016
    
    // Customer AccountingId
    public String AccountingId;
    
    // Customer Name
    public String SyncToken;
    
    public String accountingResponse;
    
    // Customer payment Journal Entry AccountingId
	public String JournalEntryAccountingId;
	    
    // Customer payment Journal Entry SyncToken
    public String JournalEntrySyncToken;
    
    public String JournalEntryAccountingResponse;
    
    public CustomerWrapper customer {get; set;}
    
    public COInvoiceHeaderWrapper COInvoiceHeaderRec {get; set;}
    
    public String CustomerOrderNumber;
    
    public String COType;
    
    public String XeroAccountingId;
    
    public String CustomerOrderId;
    
    public String Id;
    
    public Date PaymentDate;
    
    // Constructor
    public AccountingCOInvoicePayment(CO_Invoice_Payment__c  coInvoicePaymentRec) { 
        this.COInvoiceHeaderId = coInvoicePaymentRec.CO_Invoice_Header__c;
        this.CustomerId = coInvoicePaymentRec.CO_Invoice_Header__r.CO_Header__r.Customer__c;
        this.COInvoicePaymentId = coInvoicePaymentRec.Id;
        this.Amount = (coInvoicePaymentRec.Amount__c != null) ? coInvoicePaymentRec.Amount__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
        this.COInvoicePaymentNumber = coInvoicePaymentRec.Name;
        this.ReverseLink = coInvoicePaymentRec.Reverse_Link__c;
        this.PaymentMethod = coInvoicePaymentRec.Payment_Method__c;
        this.PaymentDate = coInvoicePaymentRec.Payment_Date__c;
        this.CreatedDate = DateTimeUtility.getFormttedDateFromDateTime(coInvoicePaymentRec.CreatedDate, 'dd/MM/yyyy');
        this.IsReverse = (coInvoicePaymentRec.Is_Reverse__c != null) ? coInvoicePaymentRec.Is_Reverse__c : false; // 05/11/2016 
        
        /*
        this.AccountingId = coInvoicePaymentRec.AccountingId__c;
        this.SyncToken = coInvoicePaymentRec.SyncToken__c;
        this.accountingResponse = coInvoicePaymentRec.AccountingResponse__c;
        */
        
        this.JournalEntryAccountingId = coInvoicePaymentRec.AccountingIdForJournalEntry__c;
        this.JournalEntrySyncToken = coInvoicePaymentRec.SyncTokenForJournalEntry__c;
        this.JournalEntryAccountingResponse = coInvoicePaymentRec.AccountingResponseForJournalEntry__c;
        
        this.customer = new CustomerWrapper(coInvoicePaymentRec.CO_Invoice_Header__r.CO_Header__r.Customer__r.AccountingId__c, coInvoicePaymentRec.CO_Invoice_Header__r.CO_Header__r.Customer__r.Name);
        
        this.COInvoiceHeaderRec = new COInvoiceHeaderWrapper(coInvoicePaymentRec.CO_Invoice_Header__r.AccountingId__c);
        
        this.CustomerOrderNumber = coInvoicePaymentRec.CO_Invoice_Header__r.CO_Header__r.Name;
        this.COType = coInvoicePaymentRec.CO_Invoice_Header__r.CO_Header__r.CO_Type__c;
        
        this.XeroAccountingId = coInvoicePaymentRec.Xero_Accounting_Id__c;
        this.CustomerOrderId = coInvoicePaymentRec.CO_Invoice_Header__r.CO_Header__c;
        this.Id = coInvoicePaymentRec.Id;
    }
    
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: COLineItem - Class Object
    **/ 
    public static List<COInvoicePayment> parse(String json) {
        return (List<COInvoicePayment>) System.JSON.deserialize(json, List<COInvoicePayment>.class);
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> coInvoiceItemFields = new List<String>{ 'Id',
                                                        'Name', 
                                                        'CO_Invoice_Header__c',
                                                        'Payment_Method__c',
                                                        'Amount__c',
                                                        'Reverse_Link__c',
                                                        'CreatedDate',
                                                        'Is_Reverse__c', // 05/11/2016
            											'availForQBJournalEntrySync__c',
                                                        'AccountingResponseForJournalEntry__c',
                                                        'AccountingIdForJournalEntry__c',
                                                        'Xero_Accounting_Id__c',
                                                        'Available_For_Xero_Sync__c',
                                                        'SyncTokenForJournalEntry__c',
                                                        'CO_Invoice_Header__r.Id',
				                                        'CO_Invoice_Header__r.Name', 
				                                        'CO_Invoice_Header__r.CO_Header__c',
				                                        'CO_Invoice_Header__r.Invoice_Date__c',
				                                        'CO_Invoice_Header__r.Invoice_Status__c',
				                                        'CO_Invoice_Header__r.Invoice_Number__c',
				                                        'CO_Invoice_Header__r.AccountingId__c',
				                                        'CO_Invoice_Header__r.Total_Payment__c',
				                                        'CO_Invoice_Header__r.SyncToken__c',
				                                        'CO_Invoice_Header__r.AccountingResponse__c',
				                                        'CO_Invoice_Header__r.CO_Header__r.Customer__c',
				                                        'CO_Invoice_Header__r.CO_Header__r.Customer__r.AccountingId__c',
				                                        'CO_Invoice_Header__r.CO_Header__r.Customer__r.Name',
            											'CO_Invoice_Header__r.CO_Header__r.Name',
            											'CO_Invoice_Header__r.CO_Header__r.CO_Type__c',
            											'Payment_Date__c'
                                               		 };
        return coInvoiceItemFields;
    }
    
    
    /*public static Map<String, Set<String>> objectToFieldMap = new Map<String, Set<String>>{
    	'COInvoicePayment'		=> new Set<String>{ 'Id',
                                                'Name', 
                                                'CO_Invoice_Header__c',
                                                'Payment_Method__c',
                                                'Amount__c',
                                                'Reverse_Link__c',
                                                'CreatedDate',
                                                'Is_Reverse__c', // 05/11/2016
                                                'AccountingId__c',
                                                'SyncToken__c',
                                                'AccountingResponse__c'
                                       		 },
    	'COInvoiceHeader'		=> new Set<String>{	'Id',
	                                        'Name', 
	                                        'CO_Header__c',
	                                        'Invoice_Date__c',
	                                        'Invoice_Status__c',
	                                        'Invoice_Number__c',
	                                        'AccountingId__c',
	                                        'Total_Payment__c',
	                                        'SyncToken__c',
	                                        'AccountingResponse__c',
	                                        'CO_Header__r.Customer__r.AccountingId__c',
	                                        'CO_Header__r.Customer__r.Name'
            								}
    };*/
    
    
    public class CustomerWrapper{
    	
    	public String AccountingId {get; set;}
    	public String Name {get; set;} 
    	
    	public CustomerWrapper(String AccountingId, String Name) {
    		this.AccountingId = AccountingId;
    		this.Name = Name;
    		
    	}
    }
    
    public class COInvoiceHeaderWrapper{
    	
    	public String AccountingId {get; set;}
    	
    	public COInvoiceHeaderWrapper(String AccountingId) {
    		this.AccountingId = AccountingId;
    		
    	}
    }
}
