public with sharing class AccountingVendorReturn {
    
	public String Id;
	public String Name;
	public String SyncToken;
	public String AccountingId;
   	public String VendorAccountingId;
   	public String TaxCodeAccountingId;
   	public String VendorName;
	public Date CreditedDate;
   	public String RMANumber;
   	public String CreditMemoNumber;
   	public Decimal Tax;
   	public Decimal Total;
   	public Decimal SubTotal;
   	public AccountRefWrapper AccountRef1;
   	public List<ReturnVoLineItemWrapper> ReturnVOLIList;
   	public List<AccountingPurchaseTax> AccountingPurchaseTaxList {get; set;}
    public String XeroVendorAccountingId;
   
    public AccountingVendorReturn(Return_VO_Header__c returnVOHeaderRec){
		this.Id = returnVOHeaderRec.Id;
		this.Name = (returnVOHeaderRec.Credit_Memo__c != null) ? returnVOHeaderRec.Credit_Memo__c : returnVOHeaderRec.Name;
		this.AccountingId = returnVOHeaderRec.AccountingId__c;
		this.SyncToken = returnVOHeaderRec.SyncToken__c;
    	this.VendorAccountingId = returnVOHeaderRec.Vendor__r.Vendor_AccountingId__c != null ? returnVOHeaderRec.Vendor__r.Vendor_AccountingId__c : '';
    	this.XeroVendorAccountingId = returnVOHeaderRec.Vendor__r.Xero_Vendor_Accounting_Id__c;
    	this.VendorName = returnVOHeaderRec.Vendor__r.Name != null ? returnVOHeaderRec.Vendor__r.Name : '';
    	this.RMANumber = returnVOHeaderRec.RMA__c;
    	this.CreditMemoNumber = returnVOHeaderRec.Credit_Memo__c ;
    	this.Tax = returnVOHeaderRec.Tax__c != null ? returnVOHeaderRec.Tax__c : 0;
    	this.Total = returnVOHeaderRec.Return_Total__c != null ? returnVOHeaderRec.Return_Total__c : 0;
    	this.SubTotal = returnVOHeaderRec.SubTotal__c != null ? returnVOHeaderRec.SubTotal__c : 0;
    	this.AccountRef1 = new AccountRefWrapper(AccountingUtil.getChartofAccount('A/P Inventory Accrual'));
    	this.CreditedDate = returnVOHeaderRec.Credited_Date__c != null ? 
    					date.newinstance(returnVOHeaderRec.Credited_Date__c.year(), returnVOHeaderRec.Credited_Date__c.month(), returnVOHeaderRec.Credited_Date__c.day()) : 
    					date.newinstance(returnVOHeaderRec.CreatedDate.year(), returnVOHeaderRec.CreatedDate.month(), returnVOHeaderRec.CreatedDate.day());
    	
    	this.ReturnVOLIList = new List<ReturnVoLineItemWrapper>();
    	for(Return_VO_Line_Item__c returnVOLineItemRec  : returnVOHeaderRec.Return_VO_Line_Items__r){
			this.ReturnVOLIList.add(new ReturnVoLineItemWrapper(returnVOLineItemRec));
		}
		
		Id purchaseTaxId = returnVOHeaderRec.Vendor__r.Purchase_Tax__r.Id;
        List<Applicable_Taxes__c> applicableTaxList = [Select Name, Sales_Tax_Item__r.Name__c, Sales_Tax_Item__r.Rate__c, Sales_Tax_Item__r.Category__r.Income_GL__c, Sales_Tax_Item__r.AccountingId__c from Applicable_Taxes__c where Sales_Tax__r.Id = :purchaseTaxId];
        
        this.AccountingPurchaseTaxList = new List<AccountingPurchaseTax>();
        for(Applicable_Taxes__c ApplicableTaxRec : applicableTaxList) {
            this.AccountingPurchaseTaxList.add(new AccountingPurchaseTax(ApplicableTaxRec));
        }
    	this.TaxCodeAccountingId = (returnVOHeaderRec.Vendor__r.Purchase_Tax__c != null) ? returnVOHeaderRec.Vendor__r.Purchase_Tax__r.Accounting_Id__c : '';
    } 
    
    
    
   public class ReturnVoLineItemWrapper {
   
   	   public String Id;
	   public String ItemDescription;
	   public Decimal ReturnQty;
	   public Decimal ItemCost;
	   public Decimal InventoryCost;
	   public String Inventory_GL;
	   
	   public ReturnVoLineItemWrapper(Return_VO_Line_Item__c returnVOLIRec){
	   	this.Id = returnVOLIRec.Id;
	   	this.ItemDescription = returnVOLIRec.Item_Desc__c;
	   	this.ReturnQty = returnVOLIRec.Return_Qty__c != null ? returnVOLIRec.Return_Qty__c : 0;
	   	this.ItemCost = returnVOLIRec.Item_Cost__c != null ? returnVOLIRec.Item_Cost__c : 0;
	   	this.InventoryCost = returnVOLIRec.Inventory_Cost__c != null ? returnVOLIRec.Inventory_Cost__c : 0;
	   	this.Inventory_GL = (returnVOLIRec.Part__r.Category__c != null && returnVOLIRec.Part__r.Category__r.Inventory_GL__c != null) ? 
	   							returnVOLIRec.Part__r.Category__r.Inventory_GL__c : '';
	   }
	}
	
	public class AccountRefWrapper{
        public String AccountingId {get; set;}
        
        public AccountRefWrapper(String AccountingId) {
            this.AccountingId = AccountingId;
        }
    }
    
    public class AccountingPurchaseTax {
    	public String SalesTaxName {get; set;}
    	public Decimal SalesTaxRate {get; set;}
    	public String SalesTaxItemAccountingId {get; set;}
    	public String CategoyRef {get; set;}
    	
    	// Constructor
	    public AccountingPurchaseTax(Applicable_Taxes__c  applicableTaxRec) { 
	        this.SalesTaxName = applicableTaxRec.Sales_Tax_Item__r.Name__c;
	        this.SalesTaxRate = applicableTaxRec.Sales_Tax_Item__r.Rate__c;
	        this.CategoyRef = applicableTaxRec.Sales_Tax_Item__r.Category__r.Income_GL__c;
	        this.SalesTaxItemAccountingId = applicableTaxRec.Sales_Tax_Item__r.AccountingId__c;
	    }
    }
	
	public class TaxRateComponent {
        public Decimal TaxAmount;
        public Decimal TaxableAmount;
        public String TaxRateAcctId;
        public Decimal TaxRatePercent;
        public TaxRateComponent(Decimal taxAmount, Decimal taxableAmount, String acctId, Decimal taxPercent) {
            this.TaxAmount = (taxAmount != null) ? taxAmount : 0;
            this.TaxableAmount = taxableAmount;
            this.TaxRateAcctId = acctId;
            this.TaxRatePercent = taxPercent;
        }
    }

	public static List<String> getReturnVOFieldList(){
        List<String> returnVOFields = new List<String>{ 
        											'Id',
        											'Name',
        											'SyncToken__c',
        											'AccountingId__c',
        											'Vendor__c',
        											'Vendor__r.Vendor_AccountingId__c',
        											'Vendor__r.Name',
        											'RMA__c',
        											'Tax__c',
        											'Return_Total__c',
        											'SubTotal__c',
        											'Credited_Date__c',
        											'Credit_Memo__c',
        											'Total__c',
        											'CreatedDate',
        											'Vendor__r.Purchase_Tax__r.Id',
        											'Vendor__r.Purchase_Tax__c',
        											'Vendor__r.Purchase_Tax__r.Accounting_Id__c',
        											'Vendor__r.Xero_Vendor_Accounting_Id__c',
        											'Xero_Accounting_Id__c'
        };
        return returnVOFields;
    }
    
    
    public static List<String> getReturnVOLIFieldList(){
        List<String> returnVOLIFields = new List<String>{ 
        											'Id',
        											'Item_Desc__c',
        											'Return_Qty__c',
        											'Item_Cost__c',
        											'Inventory_Cost__c',
        											'Part__r.Category__c',
        											'Part__r.Category__r.Inventory_GL__c'
        };
        
        return returnVOLIFields;
    }    
}