/**
 * Author: Pooja Khandelwal
 * Since: Dec 16, 2016
 * Name: AccountingItemCategory
 * Description: Apex class to handle JSON related oprations of Category object for Accounting.
**/
public with sharing class AccountingItemCategory {
	
	public String Id;
	public String CategoryName;
	public String Description;
	public Boolean Active;
	public String Type;
	public Boolean IsDefault;
    public String AccountingId;
    public String XeroAccountingId;
    public String SyncToken;
    public String accountingResponse;
    public AccountRefWrapper IncomeAccountRef;
    public AccountRefWrapper ExpenseAccountRef;
    public AccountRefWrapper AssetAccountRef;
    public String QBUpdatedField;
	
	// Constructor
    public AccountingItemCategory(Category__c categoryRec) {
    	this.CategoryName = categoryRec.Name;
    	this.Description = categoryRec.Description__c;
    	this.Active = categoryRec.Active__c;
    	this.Type = categoryRec.Type__c;
    	this.IsDefault = categoryRec.Default__c;
    	this.Id = categoryRec.Id;
    	this.AccountingId = categoryRec.AccountingId__c;
        this.XeroAccountingId = categoryRec.Xero_Accounting_Id__c;
    	this.SyncToken = categoryRec.SyncToken__c;
    	this.accountingResponse = categoryRec.AccountingResponse__c;
    	this.IncomeAccountRef = new AccountRefWrapper(categoryRec.Income_GL__c);
    	this.ExpenseAccountRef = new AccountRefWrapper(categoryRec.COGS_GL__c);
    	this.AssetAccountRef = new AccountRefWrapper(categoryRec.Inventory_GL__c);
    	this.QBUpdatedField = categoryRec.QB_Updated_Fields__c;
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> categoryFields = new List<String>{ 'Id',
	                                                    'Name', 
	                                                    'Active__c',
	                                                    'Default__c',
	                                                    'Description__c',
	                                                    'Type__c',
	                                                    'AccountingId__c',
                                                        'SyncToken__c',
                                                        'AccountingResponse__c',
                                                        'COGS_GL__c',
                                                        'Income_GL__c',
                                                        'Inventory_GL__c',
                                                        'QB_Updated_Fields__c',
                                                        'Available_For_Xero_Sync__c',
                                                        'Xero_Accounting_Id__c'
                                               		 };
        return categoryFields;
    }
    
    public class AccountRefWrapper {
     	public String Id;
    	public AccountRefWrapper(String Id) {
    		this.Id = Id;
    	}
    } 
}