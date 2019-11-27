public class QBAccounting {
    private static Map<String, String> accountNameToAccountTypeMap = new Map<String, String>();
    private static Map<String, String> accountTypeToAccountToIdMap = new Map<String, String>();
    private static void populateType() {
        accountNameToAccountTypeMap.put('Undeposited_Funds__c','Other Current Asset');
        accountNameToAccountTypeMap.put('Customer_Deposits__c','Bank');
        accountNameToAccountTypeMap.put('A_P_Inventory_Accrual__c','Expense');
        accountNameToAccountTypeMap.put('Cost_of_Goods_Sold__c','Cost of Goods Sold');
        accountNameToAccountTypeMap.put('Inventory_Adjustments__c','Income');
        accountNameToAccountTypeMap.put('Inventory__c','Other Current Asset');
        accountNameToAccountTypeMap.put('Miscellaneous_Income__c','Other Expense');
        accountNameToAccountTypeMap.put('Sales_Income__c','Income');
        accountNameToAccountTypeMap.put('Sales_Tax__c','Other Current Liability');
        accountNameToAccountTypeMap.put('Cash_Rounding__c','Other Expense');
        accountNameToAccountTypeMap.put('Internal_Service_Customer_Id__c','Expense');
        accountNameToAccountTypeMap.put('Cash_Sale_Customer_Id__c','Expense');
        accountNameToAccountTypeMap.put('Stamp_Duty_Accrual__c','Accounts Payable');
        accountNameToAccountTypeMap.put('Store_Credit_Accrual__c','Accounts Payable');
        accountNameToAccountTypeMap.put('Store_Credit_Expense__c','Expense');
    }
    
    public static void runAll() {
        syncAccountingId();
        syncItemCategory();
    }
    
    public static void syncAccountingId() {
        populateType();
        if(AccessControl.ifObjectFieldIsAccessible('General_Account__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<General_Account__c> genAccRecordList = [SELECT Account_Type__c, Accounting_Id__c FROM General_Account__c WHERE Account_Type__c IN :accountNameToAccountTypeMap.values()];
        for(General_Account__c genAccRec : genAccRecordList) {
            if(!accountTypeToAccountToIdMap.containsKey(genAccRec.Account_Type__c)) {
                accountTypeToAccountToIdMap.put(genAccRec.Account_Type__c, genAccRec.Accounting_Id__c);
            }
        }
        if(AccessControl.ifObjectFieldIsCreateable('Accounting_Default_Accounts__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Accounting_Default_Accounts__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        Accounting_Default_Accounts__c accountingSetting = Accounting_Default_Accounts__c.getOrgDefaults();
        for(String acctSettingField : accountNameToAccountTypeMap.keySet()) {
            accountingSetting.put(acctSettingField, accountTypeToAccountToIdMap.get(accountNameToAccountTypeMap.get(acctSettingField)));
        }
        upsert accountingSetting;
    }
    
    public static void syncItemCategory() {
    	if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsUpdateable('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        List<Category__c> itemCategoryList = [SELECT Id,Type__c, COGS_GL__c, Income_GL__c, Inventory_GL__c FROM Category__c LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
        Accounting_Default_Accounts__c accountSetting = Accounting_Default_Accounts__c.getOrgDefaults();
        for(Category__c itemCategory: itemCategoryList) {
            if(itemCategory.Type__c == 'Tax') {
                itemCategory.Income_GL__c = accountSetting.Sales_Tax__c;
                itemCategory.Inventory_GL__c = '';
                itemCategory.COGS_GL__c = '';
            } else if(itemCategory.Type__c == 'Fee' || itemCategory.Type__c == 'Internal Expense' || itemCategory.Type__c == 'Miscellaneous' || itemCategory.Type__c == 'Trade-in' || itemCategory.Type__c == 'Stamp Duty' || itemCategory.Type__c == 'Deductible') {
                itemCategory.Inventory_GL__c = '';
                itemCategory.COGS_GL__c = '';
                itemCategory.Income_GL__c = accountSetting.Miscellaneous_Income__c;
            } else if(itemCategory.Type__c == 'Labour' || itemCategory.Type__c == 'Part'  || itemCategory.Type__c == 'Sublet' || itemCategory.Type__c == 'Unit') {
                itemCategory.Inventory_GL__c = accountSetting.Inventory__c;
                itemCategory.COGS_GL__c = accountSetting.Cost_of_Goods_Sold__c;
                itemCategory.Income_GL__c = accountSetting.Sales_Income__c;
            }
        }
        update itemCategoryList;
    }
    public static void syncAccountSetting() {
        QBAccounting.syncAccountingId();
        QBAccounting.syncItemCategory();
    }
}