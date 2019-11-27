public without sharing class IndividualTaxWrapper {
    public String Id;
    public String SalesTaxItemName;
    public Decimal TaxRate;
    
    public IndividualTaxWrapper(Individual_Tax__c individualTaxRec) {
        this.Id = individualTaxRec.Id;
        this.SalesTaxItemName = individualTaxRec.Sales_Tax_Item_Name__c;
        this.TaxRate = individualTaxRec.Tax_Rate__c;
    }
}