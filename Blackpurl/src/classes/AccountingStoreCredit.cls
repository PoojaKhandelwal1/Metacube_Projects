/**
 * Author: Richa Mittal
 * Since: Aug 24, 2017
 * Name: AccountingStoreCredit
 * Description: Apex class to handle JSON related oprations of store credits of customer for Accounting.
**/
public with sharing class AccountingStoreCredit {
    
     // Deposit Name
    public String StoreCreditName{get; set;}
    
    public String StoreCreditReference{get; set;}
    
    // Assignee Name
    public Decimal Amount{get; set;}
    
    // Created Date
    public Date CreatedDate {get; set;}
    
    // CO Deposit Id
    public String StoreCreditId {get; set;}
    
    // Customer payment Journal Entry AccountingId
	public String JournalEntryAccountingId;
	    
    // Customer payment Journal Entry SyncToken
    public String JournalEntrySyncToken;
    
    public String JournalEntryAccountingResponse;
    
    public CustomerWrapper customer {get; set;}
    
    public String XeroAccountingId;
    
    // Constructor
    public AccountingStoreCredit(Store_Credit__c storeCredit) {
        this.StoreCreditName = storeCredit.Name;
        this.StoreCreditReference = storeCredit.Reference__c;
        this.Amount = (storeCredit.Amount__c != null) ? storeCredit.Amount__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
        if(storeCredit.Id != null) {
            this.StoreCreditId = storeCredit.Id;
            this.CreatedDate = DateTimeUtility.getDateFromFormattedDateStr(DateTimeUtility.getFormttedDateFromDateTime(storeCredit.CreatedDate, 'dd/MM/yyyy')); //String.valueOf(DateTime.valueOf(storeCredit.CreatedDate).format('dd/MMM/yyyy')); 
        }
        
        this.JournalEntryAccountingId = storeCredit.AccountingId__c;
        this.JournalEntrySyncToken = storeCredit.SyncToken__c;
        this.JournalEntryAccountingResponse = storeCredit.AccountingResponse__c;
        
        this.customer = new CustomerWrapper(storeCredit.Customer__r.AccountingId__c, storeCredit.Customer__r.Name, storeCredit.Customer__r.Id);
        this.XeroAccountingId = storeCredit.Xero_Accounting_Id__c;
        
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
                            'Amount__c',
                            'Reference__c',
            				'availForQBSync__c',
                            'AccountingResponse__c',
                            'AccountingId__c',
                            'SyncToken__c',
                            'Customer__c',
                            'Customer__r.Name',
                            'Customer__r.AccountingId__c',
                            'CreatedDate',
                            'Xero_Accounting_Id__c',
                            'Available_For_Xero_Sync__c',
                            'Customer__r.Id'
                           };
        return CODepositFields;
    }
    
    public class CustomerWrapper{
    	
    	public String AccountingId {get; set;}
    	public String Name {get; set;} 
    	public String customerId;
    	
    	public CustomerWrapper(String AccountingId, String Name, String customerId) {
    		this.AccountingId = AccountingId;
    		this.Name = Name;
    		this.customerId = customerId;
    		
    	}
    }
    
}