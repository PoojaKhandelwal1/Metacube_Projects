/**
 * Author: Richa Mittal
 * Since: Dec 15, 2017
 * Name: AccountingUnitPriceAndCost
 * Description: Apex class to handle JSON related oprations of unit price and cost for Accounting.
**/
public with sharing class AccountingUnitPriceAndCost {
    
    public String Id;
    public String RefrenceNumber;
    public String UnitId;
    public String StockNumber;
    public String UnitStatus;
    
    public String Type;
    public String Inventory_GL;
    public String COGS_GL;
    public Decimal TotalCost;
    public Decimal Qty;
    public Date CreatedDate;
    
    public EntityRefWrapper EntityRef;
	public String JournalEntryAccountingId;
    public String JournalEntrySyncToken;
    public String JournalEntryAccountingResponse;
    public String XeroAccountingId;
    public String ItemDescription;
    public String CustomerOwnedUnitId;
   	public String VIN;
    
    // Constructor
    public AccountingUnitPriceAndCost(Unit_Price_Cost__c adjstmentRec) {
    	this.Id = adjstmentRec.Id;
        this.RefrenceNumber = adjstmentRec.Ref_No__c;
        this.UnitId = adjstmentRec.Customer_Owned_Unit__r.Unit_Id__c;
        this.StockNumber = adjstmentRec.Customer_Owned_Unit__r.Stock_Id__c;
        this.UnitStatus = adjstmentRec.Customer_Owned_Unit__r.Status__c;
        this.Type = adjstmentRec.Type__c;
        this.Inventory_GL = adjstmentRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
        this.COGS_GL = adjstmentRec.Customer_Owned_Unit__r.Category__r.COGS_GL__c;
        this.TotalCost = adjstmentRec.Total_Cost__c;
        this.Qty = adjstmentRec.Qty__c;
        this.CreatedDate = adjstmentRec.CreatedDate.Date();
        
        this.EntityRef = new EntityRefWrapper(adjstmentRec.Customer_Owned_Unit__r.Referenced_Unit__r.Vendor__r.Vendor_AccountingId__c, adjstmentRec.Customer_Owned_Unit__r.Referenced_Unit__r.Vendor__r.Name);
        this.JournalEntryAccountingId = adjstmentRec.AccountingId__c;
        this.JournalEntrySyncToken = adjstmentRec.SyncToken__c;
        this.JournalEntryAccountingResponse = adjstmentRec.AccountingResponse__c;
        this.XeroAccountingId = adjstmentRec.Xero_Accounting_Id__c ;
        this.ItemDescription = adjstmentRec.Item_Description__c;
        this.CustomerOwnedUnitID = adjstmentRec.Customer_Owned_Unit__r.Id;
        this.VIN = adjstmentRec.Customer_Owned_Unit__r.VIN_Number__c;
    }     
  
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> UnitPriceAndCOstFields = new List<String>{ 'Id',
                            'Name',
                            'Customer_Owned_Unit__r.Unit_Id__c',
                            'Customer_Owned_Unit__r.Category__r.Inventory_GL__c',
                            'Customer_Owned_Unit__r.Category__r.COGS_GL__c',
                            'Customer_Owned_Unit__r.Stock_Id__c',
                            'Customer_Owned_Unit__r.Status__c',
            				'Type__c',
                            'Cost__c',
                            'Total_Cost__c',
                            'CreatedDate',
                            'Ref_No__c',
                            'Qty__c',
                            'Customer_Owned_Unit__r.Referenced_Unit__r.Vendor__c',
                            'Customer_Owned_Unit__r.Referenced_Unit__r.Vendor__r.Vendor_AccountingId__c',
                            'Customer_Owned_Unit__r.Referenced_Unit__r.Vendor__r.Name',
                            'AccountingResponse__c',
                            'AccountingId__c',
                            'SyncToken__c',
                            'Xero_Accounting_Id__c',
                            'Item_Description__c',
                            'Customer_Owned_Unit__r.Id',
                            'Customer_Owned_Unit__r.VIN_Number__c'
                           };
        return UnitPriceAndCOstFields;
    }
    
    public class EntityRefWrapper{
        public String AccountingId;
        public String Name;
        
        public EntityRefWrapper(String AccountingId, String Name) {
            this.AccountingId = AccountingId;
            this.Name = Name;
        }
    }
    
}