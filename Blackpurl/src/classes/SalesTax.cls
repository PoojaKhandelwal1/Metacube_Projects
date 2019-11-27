/**
 * Author: Tarun Khandelwal
 * Since: May 25, 2015
 * Name: SalesTax
 * Description: Apex class to handle JSON related oprations of SalesTax object.
**/
public with sharing class SalesTax {
	
	public Boolean IsDefault;
	public String Id;
	public String SalesTaxName;
	public String AccountingId;
	public Boolean IsActive;
	public Decimal TaxRate;
	public Set<Integer> ApplicableTaxRateAccIdSet;
	public List<SalesTaxItem> salesTaxItemList;
	
	// Constructor
    public SalesTax(Sales_Tax__c salesTaxRec) {
    	this.SalesTaxName = salesTaxRec.Name__c ;
    	this.Id = salesTaxRec.Id;
    	this.IsDefault = salesTaxRec.Default__c;
    	this.IsActive = salesTaxRec.Active__c;
    	this.AccountingId = salesTaxRec.Accounting_Id__c;
    	this.TaxRate = (salesTaxRec.Rate__c != null) ? salesTaxRec.Rate__c : 0;
    }
    
    // Constructor
    public SalesTax(Sales_Tax__c salesTaxRec, List<Applicable_Taxes__c> applicableTaxList) {
    	this.SalesTaxName = salesTaxRec.Name__c ;
    	this.Id = salesTaxRec.Id;
    	this.IsDefault = salesTaxRec.Default__c;
    	this.IsActive = salesTaxRec.Active__c;
    	this.AccountingId = salesTaxRec.Accounting_Id__c;
    	this.TaxRate = (salesTaxRec.Rate__c != null) ? salesTaxRec.Rate__c : 0;
    	this.salesTaxItemList = new List<SalesTaxItem>();
    	this.ApplicableTaxRateAccIdSet = new Set<Integer>();
    	for(Applicable_Taxes__c applicableTax : applicableTaxList) {
    		this.salesTaxItemList.add(new SalesTaxItem(applicableTax));
    		if(String.isNotBlank(applicableTax.Sales_Tax_Item__r.AccountingId__c)) {
    			this.ApplicableTaxRateAccIdSet.add(Integer.valueOf(applicableTax.Sales_Tax_Item__r.AccountingId__c));
    		}
    	}
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> salesTaxFields = new List<String>{ 'Id',
	                                                    'Name__c', 
	                                                    'Default__c',
	                                                    'Active__c',
	                                                    'Accounting_Id__c'
                                               		 };
        return salesTaxFields;
    }
}