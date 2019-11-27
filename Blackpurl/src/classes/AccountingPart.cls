/**
 * Author: Richa Mittal
 * Since: Jun 12, 2018
 * Name: AccountingPart
 * Description: Apex class to handle JSON related oprations of part for Accounting.
**/
public with sharing class AccountingPart {
    public String Id;
    public String PartNumber;
    public Decimal TotalInventoryValuation;
    public Date ModifiedDate;
    public String NewCategoryName;
    public String OldCategoryName;
    public String NewCategoryInventoryGL;
    public String OldCategoryInventoryGL;
    public String AccountingIdCategory;
    public String SyncTokenCategory;
    public String AccountingResponseCategory;
    public String XeroAccountingId;
    
    public AccountingPart(Part__c partRec) {
        this.Id = partRec.Id;
        this.PartNumber = partRec.Part_Number__c;
        this.TotalInventoryValuation = partRec.Total_Cost__c != null ? partRec.Total_Cost__c : 0;
        this.ModifiedDate = Date.valueOf(partRec.LastModifiedDate);
        this.NewCategoryName = partRec.Category__r.Name;
        this.NewCategoryInventoryGL = partRec.Category__r.Inventory_GL__c;
        this.OldCategoryName = partRec.Old_Category__r.Name;
        this.OldCategoryInventoryGL = partRec.Old_Category__r.Inventory_GL__c;
        this.AccountingIdCategory = partRec.Accounting_Id_Category__c;
        this.SyncTokenCategory = partRec.Sync_Token_Category__c;
        this.AccountingResponseCategory = partRec.Accounting_Response_Category__c;
        this.XeroAccountingId = partRec.Xero_Accounting_Id__c;
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList() {
        List<String> partFields = new List<String>{ 'Id', 'Total_Cost__c', 'LastModifiedDate', 'Old_Category__r.Name', 'Old_Category__r.Inventory_GL__c', 
                                                    'Category__r.Name', 'Category__r.Inventory_GL__c', 'Accounting_Id_Category__c', 
                                                    'Part_Number__c', 'Sync_Token_Category__c', 'Accounting_Response_Category__c','Xero_Accounting_Id__c'
                                                    };
        return partFields;
    }
}
