/**
 * Author: Pooja Khandelwal
 * Since: Nov. 27, 2018
 * Name: AccountingLienPayout
 * Description: Tempalate class for Accounting Deal Trade In Unit - Lien Payout ((Bill - QB Integration))
**/ 

public with sharing class AccountingLienPayout {
    public String Id;
    public VendorWrapper FinanceCompany;
    public String SyncToken;
    public String AccountingId;
	public Decimal LienPayout;
	public String UnitVinNumber;
	public String CategoyIncomeGLAccountRef;
	public String InvoiceNumber;
	public Date InvoiceDate;
	public String SkuId;
	public String SkuMake;
	public String SkuModel;
	public String SkuSubModel;
	public String SkuYear;
	public String CustomerName;
	public String XeroCustomerAccountingId;
	public String SkuVINNumber;
	public String CoHeaderId;
	
    // Constructor
    public AccountingLienPayout(Deal_Item__c dealItem) { 
        this.Id = dealItem.Id;
        this.CoHeaderId = dealItem.Deal__r.CO_Header__r.Id;
        this.FinanceCompany = new VendorWrapper(dealItem.Finance_Company__r.Vendor_AccountingId__c, dealItem.Finance_Company__r.Name);
        this.SyncToken = dealItem.Lien_Payout_Sync_Token__c;
        this.AccountingId = dealItem.Lien_Payout_Accounting_Id__c;
        this.LienPayout = dealItem.Lien_Payout__c;
        this.UnitVinNumber = dealItem.Customer_Owned_Unit__r.VIN_Number__c;
        this.SkuVINNumber = dealItem.Stocked_In_Unit__r.VIN_Number__c;
        
        List<Category__c> lienPayoutCategoryList = AccountingUtil.getSystemDefaultCategory('Lien Payout');
        this.CategoyIncomeGLAccountRef = (lienPayoutCategoryList.size() > 0) ? lienPayoutCategoryList[0].Income_GL__c : null;
        
        this.InvoiceNumber = (dealItem.Deal__r.Invoice_Number__r.Invoice_Number__c != null) ? dealItem.Deal__r.Invoice_Number__r.Invoice_Number__c  : '';
        this.InvoiceDate = (dealItem.Deal__r.Invoice_Number__r.Invoice_Date__c != null) ? dealItem.Deal__r.Invoice_Number__r.Invoice_Date__c.date() : null;
        
        this.SkuId = dealItem.Stocked_In_Unit__r.Stock_Id__c;
        this.SkuMake = dealItem.Stocked_In_Unit__r.Make_Name__c;
        this.SkuModel = dealItem.Stocked_In_Unit__r.Model_Name__c;
        this.SkuSubModel = dealItem.Stocked_In_Unit__r.Sub_Model__r.Sub_Model_Name__c;
        this.SkuYear = dealItem.Stocked_In_Unit__r.Year__c != null ? String.valueOf(Integer.valueof(dealItem.Stocked_In_Unit__r.Year__c)) : '';
        this.CustomerName = dealItem.Deal__r.CO_Header__r.Customer__r.Name;
        this.XeroCustomerAccountingId = dealItem.Deal__r.CO_Header__r.Customer__r.Xero_Customer_Accounting_Id__c;
    }
    
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: COLineItem - Class Object
    **/
    public static AccountingLienPayout parse(String json) {
        return (AccountingLienPayout) System.JSON.deserialize(json, AccountingCustomer.class);
    }
	
	/**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> dealItemFields = new List<String>{ 'Id',
        												'Finance_Company__c',
        												'Finance_Company__r.Vendor_AccountingId__c',
        												'Finance_Company__r.Name',
        												'Lien_Payout_Sync_Token__c',
        												'Lien_Payout_Accounting_Id__c',
        												'Lien_Payout__c',
        												'Customer_Owned_Unit__r.VIN_Number__c',
        												'Deal__r.Invoice_Number__r.Invoice_Number__c',
        												'Deal__r.Invoice_Number__r.Invoice_Date__c',
        												'Stocked_In_Unit__r.Stock_Id__c',
        												'Stocked_In_Unit__r.Make_Name__c',
        												'Stocked_In_Unit__r.Model_Name__c',
        												'Stocked_In_Unit__r.Sub_Model__r.Sub_Model_Name__c',
        												'Stocked_In_Unit__r.Year__c',
        												'Stocked_In_Unit__r.VIN_Number__c',
        												'Deal__r.CO_Header__r.Id',
        												'Deal__r.CO_Header__r.Customer__r.Name',
        												'Deal__r.CO_Header__r.Customer__r.Xero_Customer_Accounting_Id__c',
        												'Lien_Payout_Avail_For_Xero_Sync__c',
        												'Lien_Payout_Xero_Accounting_Id__c'
        												};
        return dealItemFields;
    }
    
     /**
     * Name: VendorWrapper
     * Description: Vendor Class
    **/
    public class VendorWrapper{
        public String AccountingId;
        public String Name;
        
        public VendorWrapper(String AccountingId, String Name) {
            this.AccountingId = AccountingId;
            this.Name = Name;
        }
    }
}