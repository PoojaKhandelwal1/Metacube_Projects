/**
 * Author: Gaurav Tak
 * Since: February 15, 2019
 * Name: XeroItemDTO
 * Description: Data Transfer Object Class for Xero "Item" Entity
**/
public without sharing class XeroItemDTO extends BaseXeroDTO {
	public String SFId {get; set;}
    public String ItemID {get; set;}
    public String Name {get; set;}
    public String Description {get; set;}
    public String Code {get; set;}
    public String UpdatedDateUTC {get; set;}
    public Details PurchaseDetails {get; set;}
    public Details SalesDetails {get; set;}
    
    public class Details {
    	public Decimal UnitPrice;
        public String AccountCode;
        
        public Details(String accountCode) {
            this.AccountCode = accountCode;
        }
    }
    
    public XeroItemDTO(AccountingItemCategory accountingItemCategoryRec) {
    	String updatedFields = accountingItemCategoryRec.QBUpdatedField;//Reason for not updating QB in the name is beacuse this name is used at different places and cannot be updated there
    	this.SFId = accountingItemCategoryRec.Id;
    	this.ItemID = accountingItemCategoryRec.XeroAccountingId;
    	this.Code = getCodeForAcAccountingCategoryRec(accountingItemCategoryRec);
        if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Name'))) {
        	this.Name = accountingItemCategoryRec.CategoryName;
        }     
        if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Income_GL__c'))) {
        	this.SalesDetails = new Details(accountingItemCategoryRec.IncomeAccountRef.Id);
        }
        if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('COGS_GL__c'))) {
        	this.PurchaseDetails = new Details(accountingItemCategoryRec.ExpenseAccountRef.Id);
        }
    }
    
    public static String getCodeForAcAccountingCategoryRec(AccountingItemCategory accountingItemCategoryRec) {
    	String code = (accountingItemCategoryRec.CategoryName != null ? accountingItemCategoryRec.CategoryName : '');
    	String categoryType = (accountingItemCategoryRec.Type != null ? ' [' + accountingItemCategoryRec.Type + ']' : '');
    	Integer charactersForCategoryName = 30 - categoryType.length(); // Item Code must not be more than than 30 characters long
        code = ((code.length() > charactersForCategoryName) ? code.substring(0,charactersForCategoryName) : code) + categoryType;
        return code;
    }
}