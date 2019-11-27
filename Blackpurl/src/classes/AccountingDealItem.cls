/**
 * Author: Richa Mittal
 * Since: Sept 9, 2018
 * Name: AccountingDealItem
 * Description: Apex class to handle JSON related oprations of Deal Item for Accounting.
**/
public with sharing class AccountingDealItem {
    public String Id;
    public String COHeaderNumber;
    public String UnitDescription;
    public Decimal ActualCashValue;
    public Date StockedInDate;
    public String InventoryGL;
    public String AccountingId;
    public String SyncToken;
    public String AccountingResponse;
    public String StockedUnitStockNumber;
    public String StockedUnitVin;
    public String COHeaderId;
    
    public AccountingDealItem(Deal_Item__c dealItemRec) {
        this.Id = dealItemRec.Id;
        this.COHeaderNumber = dealItemRec.Deal__r.CO_Header__r.Name;
        this.UnitDescription = '';
        if(dealItemRec.Stocked_In_Unit__r.Unit_Make__r.Name !=null && dealItemRec.Stocked_In_Unit__r.Unit_Make__r.Name !=''){
            this.UnitDescription += dealItemRec.Stocked_In_Unit__r.Unit_Make__r.Name + ' ';
        }
        if(dealItemRec.Stocked_In_Unit__r.Unit_Model__r.Name__c != null && dealItemRec.Stocked_In_Unit__r.Unit_Model__r.Name__c !=''){
            this.UnitDescription += dealItemRec.Stocked_In_Unit__r.Unit_Model__r.Name__c + ' ';
        }
        if(dealItemRec.Stocked_In_Unit__r.Sub_Model__r.Sub_Model_Name__c != null && dealItemRec.Stocked_In_Unit__r.Sub_Model__r.Sub_Model_Name__c !=''){ 
            this.UnitDescription += dealItemRec.Stocked_In_Unit__r.Sub_Model__r.Sub_Model_Name__c;
        }
        this.ActualCashValue = dealItemRec.Actual_Cash_Value__c != null ? dealItemRec.Actual_Cash_Value__c.setScale(2, RoundingMode.HALF_UP) : 0;
    	this.StockedInDate = DateTimeUtility.getDateFromFormattedDateStr(DateTimeUtility.getFormttedDateFromDateTime(dealItemRec.CreatedDate, 'dd/MM/yyyy')); //Date.valueOf(dealItemRec.CreatedDate);
        this.InventoryGL = dealItemRec.Stocked_In_Unit__r.Category__r.Inventory_GL__c;
        this.AccountingId = dealItemRec.Accounting_Id__c;
        this.SyncToken = dealItemRec.Sync_Token__c;
        this.StockedUnitStockNumber = dealItemRec.Stocked_In_Unit__r.Stock_Id__c;
        this.StockedUnitVin = dealItemRec.Stocked_In_Unit__r.VIN_Number__c;
        this.COHeaderId = dealItemRec.Deal__r.CO_Header__c;
        this.AccountingResponse = dealItemRec.Accounting_Response__c;
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList() {
        List<String> partFields = new List<String>{ 'Id','Deal__r.CO_Header__c', 'Deal__r.CO_Header__r.Name', 'Actual_Cash_Value__c', 'CreatedDate', 'Stocked_In_Unit__r.Category__r.Inventory_GL__c', 'Accounting_Id__c',
                                                        'Sync_Token__c', 'Xero_Accounting_Id__c', 'Available_For_Xero_Sync__c', 'Accounting_Response__c', 'Stocked_In_Unit__r.Unit_Make__r.Name', 'Stocked_In_Unit__r.Unit_Model__r.Name__c', 'Stocked_In_Unit__r.Sub_Model__r.Sub_Model_Name__c', 'Stocked_In_Unit__r.VIN_Number__c', 'Stocked_In_Unit__r.Stock_Id__c'
                                                    };
        return partFields;
    }
}