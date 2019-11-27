public with sharing class AccountingUtil {
    
    public static String getChartofAccount(string accountType){
        Accounting_Default_Accounts__c defaultAccounts = Accounting_Default_Accounts__c.getOrgDefaults();
        String accountId = '';
        if(String.isNotBlank(accountType)){
            if(accountType.equalsIgnoreCase('A/P Inventory Accrual')) {
                accountId = defaultAccounts.A_P_Inventory_Accrual__c;
            }
            else if(accountType.equalsIgnoreCase('Cost of Goods Sold')) {
                accountId = defaultAccounts.Cost_of_Goods_Sold__c;
            }
            else if(accountType.equalsIgnoreCase('Customer Deposits')) {
                accountId = defaultAccounts.Customer_Deposits__c;
            }
            else if(accountType.equalsIgnoreCase('Inventory')) {
                accountId = defaultAccounts.Inventory__c;
            }
            else if(accountType.equalsIgnoreCase('Inventory Adjustments')) {
                accountId = defaultAccounts.Inventory_Adjustments__c;
            }
            else if(accountType.equalsIgnoreCase('Miscellaneous Income')) {
                accountId = defaultAccounts.Miscellaneous_Income__c;
            }
            else if(accountType.equalsIgnoreCase('Sales Income')) {
                accountId = defaultAccounts.Sales_Income__c;
            }
            else if(accountType.equalsIgnoreCase('Sales Tax')) {
                accountId = defaultAccounts.Sales_Tax__c;
            }
            else if(accountType.equalsIgnoreCase('Undeposited Funds')) {
                accountId = defaultAccounts.Undeposited_Funds__c;
            }
            else if(accountType.equalsIgnoreCase('Cash Rounding')) {
                accountId = defaultAccounts.Cash_Rounding__c;
            }
            else if(accountType.equalsIgnoreCase('Cash Sale Customer')) {
                accountId = defaultAccounts.Cash_Sale_Customer_Id__c;
            } 
            else if(accountType.equalsIgnoreCase('Internal Service Customer')) {
                accountId = defaultAccounts.Internal_Service_Customer_Id__c;
            } 
            else if(accountType.equalsIgnoreCase('Store Credit Accrual')) {
                accountId = defaultAccounts.Store_Credit_Accrual__c;
            }
            else if(accountType.equalsIgnoreCase('Store Credit Expense')) {
                accountId = defaultAccounts.Store_Credit_Expense__c;
            }
            else if(accountType.equalsIgnoreCase('Stamp Duty Accrual')) {
                accountId = defaultAccounts.Stamp_Duty_Accrual__c;
            }
    		else if(accountType.equalsIgnoreCase('Undeposited Direct Deposit')) {
    			accountId = defaultAccounts.Undeposited_Direct_Deposit__c;
        	}
    		else if(accountType.equalsIgnoreCase('Undeposited Financing')) {
    			accountId = defaultAccounts.Undeposited_Financing__c;
    		}
            else if(accountType.equalsIgnoreCase('Deal Option Clearing')) {
                accountId = defaultAccounts.Deal_Option_Clearing__c;
            }
    	}
        return accountId;
    }
    
    
    public static List<Category__c> getStampDutyCategory(){
        List<Category__c> stampDutyCategory = [select Name, AccountingId__c, Income_GL__c from Category__c
                                                    where Type__c = 'Stamp Duty' AND Active__c = true AND Default__c = true];
        return stampDutyCategory;
    }
    
    
    public static List<Category__c> getTradeInCategory(){
        List<Category__c> tradeInCategory = [select Name, AccountingId__c, Income_GL__c from Category__c
                                                    where Type__c = 'Trade-in' AND Active__c = true AND Default__c = true];
        return tradeInCategory;
    }
    
    public static List<Category__c> getSystemDefaultCategory(String categoryType){
    	List<Category__c> systemDefaultCategory = [SELECT Name, AccountingId__c, Income_GL__c, Inventory_GL__c FROM Category__c 
    											WHERE Type__c =: categoryType AND Default__c = true AND Active__c = true];
		return systemDefaultCategory;
    }
    
    public static Map<String, List<Unit_Price_Cost__c>> setDealItemIdToPriceCostListMap(List<Deal_Item__c> dealItemList) {
        Map<String, String> dealItemIdToUnitIdMap = new Map<String, String>();
        DateTime invoicedDate;
        for(Deal_Item__c dealItemRec : dealItemList) {
            invoicedDate = dealItemRec.Deal__r.Invoice_Number__r.Closed_Invoice_Date__c != null ? dealItemRec.Deal__r.Invoice_Number__r.Closed_Invoice_Date__c : dealItemRec.Deal__r.Invoice_Number__r.Invoice_Date__c;
            dealItemIdToUnitIdMap.put(dealItemRec.Id, dealItemRec.Customer_Owned_Unit__c);
        }
        
        Map<String, List<Unit_Price_Cost__c>> unitIdToPriceCostListMap = new Map<String, List<Unit_Price_Cost__c>>();
        Map<String, Customer_Owned_Unit__c> unitIdToRecMap;
        if(dealItemIdToUnitIdMap.size() > 0) {
            unitIdToRecMap = new Map<String, Customer_Owned_Unit__c>([SELECT Id, (SELECT Type__c, Total_Cost__c, Total_Price__c, Qty__c from Unit_Prices_Costs__r WHERE CreatedDate <= :invoicedDate) 
                                                            FROM Customer_Owned_Unit__c WHERE Id IN: dealItemIdToUnitIdMap.values()]);
        }
        
        Map<String, List<Unit_Price_Cost__c>> dealItemIdToPriceCostListMap = new Map<String, List<Unit_Price_Cost__c>>();
        for(String dealItemId : dealItemIdToUnitIdMap.keyset()) {
            String unitId = dealItemIdToUnitIdMap.get(dealItemId);
            if(unitIdToRecMap.containsKey(unitId)) {
                dealItemIdToPriceCostListMap.put(dealItemId, unitIdToRecMap.get(unitId).Unit_Prices_Costs__r);
            }
        }
        return dealItemIdToPriceCostListMap;
    }
    
    public static String getURL(String entityId, String pageName) {
        String url = BP_Configurations__c.getInstance().Org_Base_Url__c;
        if(String.isBlank(url)) {
            url =  System.Url.getSalesforceBaseUrl().toExternalForm();
        }
        url +=  '/apex/Blackpurl#/' + pageName + '?Id=' + entityId;
        return url;
    }
}
