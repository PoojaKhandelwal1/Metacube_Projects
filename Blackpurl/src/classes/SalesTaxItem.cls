/**
 * Author: Pooja Khandelwal
 * Since: Nov. 30, 2018
 * Name: SalesTaxItem
 * Description: Tempalate class for BP Sales Tax Item
**/ 
public class SalesTaxItem {
    public String Name;
    public String Id;
    public Decimal TaxRate;
    public Boolean IsActive;
	public String AccountingId;
	
    public SalesTaxItem(Sales_Tax_Item__c salesTaxItem) {
        this.Name = (salesTaxItem.Name__c != null) ? salesTaxItem.Name__c : '';
        this.Id = salesTaxItem.Id;
        this.IsActive = salesTaxItem.Active__c;
        this.TaxRate = (salesTaxItem.Rate__c != null) ? salesTaxItem.Rate__c : 0;
        this.AccountingId = salesTaxItem.AccountingId__c;
    }
    
    public SalesTaxItem(Applicable_Taxes__c applicableTax) {
        this.Id = applicableTax.Sales_Tax_Item__c;
        this.AccountingId = applicableTax.Sales_Tax_Item__r.AccountingId__c;
    }
}