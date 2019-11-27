public with sharing class CashDrawerWrapper {
    public String Id;
    public String CashDrawerName;
    public Boolean IsActive;
    
    public CashDrawerWrapper(Cash_Drawer__c cashDrawerRec) {
        this.Id = cashDrawerRec.Id;
        this.CashDrawerName = cashDrawerRec.Name;
        this.IsActive = cashDrawerRec.Active__c;
    }
    
    public static List<String> getCashDrawerFieldsList() {
       return new List<String>{ 'Id', 'Name', 'Active__c'};
    }
}