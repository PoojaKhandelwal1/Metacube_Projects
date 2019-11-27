/**
 * Author: Pooja Khandelwal
 * Since: Dec 19, 2016
 * Name: AccountingSalesTax
 * Description: Apex class to handle JSON related oprations of SalesTax object for Accounting.
**/
public with sharing class AccountingSalesTax {
	
	// Name
	public String SalesTaxName;
	
	// Active
	public Boolean Active;
	
	// Customer AccountingId
    public String AccountingId;
    
    public List<SalesTaxItemWrapper> salesTaxItemsList;
    
    
    public AccountingSalesTax(List<Sales_Tax_Item__c> salesTaxItemsList) {
    	QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
    	this.SalesTaxName =  qbConfig.TaxCode_Name__c != null ? qbConfig.TaxCode_Name__c : 'BP Code';
    	this.salesTaxItemsList = new List<SalesTaxItemWrapper>();
    	for(Sales_Tax_Item__c salesTaxItemRec : salesTaxItemsList)	{
    		this.salesTaxItemsList.add(new SalesTaxItemWrapper(salesTaxItemRec));
    	}
    	
    	this.AccountingId = qbConfig.TaxCode_Id__c;
    }
    
    public static Map<String, Set<String>> objectToFieldMap = new Map<String, Set<String>>{
    	'SalesTax'		=> new Set<String>{	'Id',
                                            'Name__c', 
                                            'Default__c',
                                            'Active__c'
            								}
    };
    
    
    public class SalesTaxItemWrapper{
 	
     	public String SalesTaxItem_AccountingId;
     	public String TaxItemName;
     	public String SalesTaxItem_Name;
     	public Decimal SalesTaxItem_Rate;
     	public String SalesTaxItem_Id;
     	public String SalesTaxItem_TaxAgencyId;
    	
    	public SalesTaxItemWrapper(Sales_Tax_Item__c salesTaxItemRec) {
			this.SalesTaxItem_AccountingId = salesTaxItemRec.AccountingId__c;    		
			this.SalesTaxItem_Name = Constants.TAX_CODE_PREFIX_FOR_QB + '' +salesTaxItemRec.Name__c; 
			this.TaxItemName = salesTaxItemRec.Name__c; 
			this.SalesTaxItem_Rate = salesTaxItemRec.Rate__c;
			this.SalesTaxItem_Id = salesTaxItemRec.Id;
			this.SalesTaxItem_TaxAgencyId = QuickBooks_Configurations__c.getOrgDefaults().Tax_Agency_Id__c;   
    	}
     }
}