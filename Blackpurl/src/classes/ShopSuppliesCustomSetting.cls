public with sharing class ShopSuppliesCustomSetting {
    
    public String CalculationMethod;
    public Decimal SuppliesRate;
    public Decimal MaximumPerInvoice;
    public String ApplicableFee;
    public Boolean ItemizedByLaborCode;
    
    public ShopSuppliesCustomSetting(Shop_Supplies__c shopSupplies) {
        this.CalculationMethod = shopSupplies.Calculation_Method__c != null ? shopSupplies.Calculation_Method__c : Constants.NOT_CALCULATED;
        this.SuppliesRate = shopSupplies.Supplies_Rate__c != null ? shopSupplies.Supplies_Rate__c : 0;
        this.MaximumPerInvoice = shopSupplies.Maximum_Per_Invoice__c != null ? shopSupplies.Maximum_Per_Invoice__c : 0;
        this.ApplicableFee = shopSupplies.Applicable_Fee__c;
        this.ItemizedByLaborCode = shopSupplies.Itemized_by_labor_code__c;
    }
}