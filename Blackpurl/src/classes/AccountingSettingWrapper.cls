public class AccountingSettingWrapper {
    public ConfigurationWrapper configuration;
    public List<GeneralAccountWrapper> accountingList;
    public DefaultAccountWrapper defaultAccounts;
        
    public AccountingSettingWrapper(Accounting_Settings__c accConfig, QuickBooks_Configurations__c qConfig, 
                                    List<General_Account__c> GeneralAccountList, Accounting_Default_Accounts__c accDefaultAccount){
        populateAccountSettingWrapper(accConfig, qConfig, GeneralAccountList, accDefaultAccount);
    }
    
    public AccountingSettingWrapper(Accounting_Settings__c accConfig, QuickBooks_Configurations__c qConfig, 
                                    List<General_Account__c> GeneralAccountList, Accounting_Default_Accounts__c accDefaultAccount, List<Category__c> categoryRecList){
        populateAccountSettingWrapper(accConfig, qConfig,  GeneralAccountList, accDefaultAccount);
        defaultAccounts = new DefaultAccountWrapper(accDefaultAccount, categoryRecList); 
    }
    
    private void populateAccountSettingWrapper(Accounting_Settings__c accConfig, QuickBooks_Configurations__c qConfig, 
                                    List<General_Account__c> GeneralAccountList, Accounting_Default_Accounts__c accDefaultAccount) {
    
        configuration = new ConfigurationWrapper(accConfig, qConfig);  
        User currentUser = [Select TimeZoneSidKey from User where Id =: UserInfo.getUserId()];
        accountingList = new List<GeneralAccountWrapper>();
        for(General_Account__c GA : GeneralAccountList) {
            accountingList.add(new GeneralAccountWrapper(GA, USerInfo.getTimeZone().getDisplayName()));
        }
        defaultAccounts = new DefaultAccountWrapper(accDefaultAccount); 
    }
    
    public class ConfigurationWrapper {
        public String AccountingProvider;
        public String AlignmentMethod;
        public String CompanyId;
        public String CompanyName;
        public String ConsumerKey;
        public String ConsumerSecret;
        public Boolean IsConnected;
        public String EndPointURL;
        public String OAuthToken;
        public String OAuthTokenSecret;
        public Boolean IsTaxCodesEnabled;
        public String NonTaxableTaxCode;
        public String NonTaxablePurchaseTaxCode;
        
        public ConfigurationWrapper(Accounting_Settings__c accConfig, QuickBooks_Configurations__c qConfig){
            this.CompanyId = qConfig.Company_Id__c;
            this.CompanyName = qConfig.Company_Name__c;
            this.ConsumerKey = qConfig.Consumer_Key__c;
            this.ConsumerSecret = qConfig.Consumer_Secret__c;  
            this.IsConnected = qConfig.Enable_QuickBooks__c;
            this.EndPointURL = qConfig.End_Point_URL__c;
            this.OAuthToken = qConfig.OAuth_Token__c;
            this.OAuthTokenSecret = qConfig.OAuth_Token_Secret__c;
            this.AccountingProvider = accConfig.Provider_Name__c;
            this.AlignmentMethod = accConfig.Alignment_Method__c;
            this.IsTaxCodesEnabled = QBUtil.isQBTaxCodesEnabled;
            if(this.IsTaxCodesEnabled) {
                this.NonTaxableTaxCode = qConfig.Non_Taxable_Tax_Code__c;
                this.NonTaxablePurchaseTaxCode = qConfig.Non_Taxable_Purchase_Tax_Code__c;
            }
        }
    }
    
    public class DefaultAccountWrapper {
        public String APInventoryAccrual;
        public String CostofGoodsSold;
        public String CustomerDeposits;
        public String Inventory;
        public String InventoryAdjustments;
        public String MiscellaneousIncome;
        public String SalesIncome;
        public String SalesTax;
        public String UndepositedFunds;
        public String CashRounding;
        public String StoreCreditAccural;
        public String StoreCreditExpense;
        public String StampDutyAccrual; 
        public String CashSaleCustomer;
        public String InternalServiceCustomer;
        public String StampDutyClearing;
        public String ClaimDeductibleClearing;
        public String StockedTradeClearing;
        public String LienPayoutClearing;
    	public String UndepositedDirectDeposit;
    	public String UndepositedFinancing;
        public String DealOptionClearing;
    	
        public DefaultAccountWrapper(Accounting_Default_Accounts__c AccDefConfig){
            populateDefaultAccountWrapper(AccDefConfig);
        }
        
        public DefaultAccountWrapper(Accounting_Default_Accounts__c AccDefConfig, List<Category__c> categoryRecList){
            populateDefaultAccountWrapper(AccDefConfig);
            for(Category__c categoryRec : categoryRecList) {
                if(categoryRec.Type__c == 'Stamp Duty') {
                    this.StampDutyClearing = categoryRec.Income_GL__c;
                } else if(categoryRec.Type__c == 'Deductible') {
                    this.ClaimDeductibleClearing = categoryRec.Income_GL__c;
                } else if(categoryRec.Type__c == 'Stocked Trade') {
                    this.StockedTradeClearing = categoryRec.Income_GL__c;
                } else if(categoryRec.Type__c == 'Lien Payout') {
                    this.LienPayoutClearing = categoryRec.Income_GL__c;
                }
            }
        }
        
        private void populateDefaultAccountWrapper(Accounting_Default_Accounts__c AccDefConfig) {
            this.APInventoryAccrual = AccDefConfig.A_P_Inventory_Accrual__c;
            this.CostofGoodsSold = AccDefConfig.Cost_of_Goods_Sold__c;
            this.CustomerDeposits = AccDefConfig.Customer_Deposits__c;
            this.Inventory = AccDefConfig.Inventory__c;
            this.InventoryAdjustments = AccDefConfig.Inventory_Adjustments__c;
            this.MiscellaneousIncome = AccDefConfig.Miscellaneous_Income__c;
            this.SalesIncome = AccDefConfig.Sales_Income__c;
            this.SalesTax = AccDefConfig.Sales_Tax__c;
            this.UndepositedFunds = AccDefConfig.Undeposited_Funds__c;
            this.CashRounding = AccDefConfig.Cash_Rounding__c;
            this.StoreCreditAccural = AccDefConfig.Store_Credit_Accrual__c;
            this.StoreCreditExpense = AccDefConfig.Store_Credit_Expense__c;
            this.StampDutyAccrual = AccDefConfig.Stamp_Duty_Accrual__c;
            this.CashSaleCustomer = AccDefConfig.Cash_Sale_Customer_Id__c;
            this.InternalServiceCustomer = AccDefConfig.Internal_Service_Customer_Id__c;
    		this.UndepositedDirectDeposit = AccDefConfig.Undeposited_Direct_Deposit__c;
    		this.UndepositedFinancing = AccDefConfig.Undeposited_Financing__c;
    		this.DealOptionClearing = AccDefConfig.Deal_Option_Clearing__c;
    	}
    }
}
