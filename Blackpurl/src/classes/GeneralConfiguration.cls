/**
 * Author: Prakhar Agrawal
 * Since: Jun 14 2016
 * Name: GeneralConfiguration
 * Description: Apex class to return all the custom fields of General Configurations
**/
public with sharing class GeneralConfiguration {
    
     /**
     * Name: getHomeSearchGridPageSize 
     * Desc: To get Home Search Grid Page Size
     * @param: 
     * @return: Decimal
    **/    
    public static Decimal getHomeSearchGridPageSize() {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().Home_Search_Grid_Page_Size__c  ;
    }
    
    /**
     * Name: getRelatedListPageSize
     * Desc: To get Related List Page Size
     * @param: 
     * @return: Decimal
    **/
    public static Decimal getRelatedListPageSize() {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().Related_List_Page_Size__c  ;
    }
    
    public static Boolean isARIPartSmartEnabled() {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().ARI_Partsmart__c;
    }
    
     /**
     * Name: isWidgetRemoveable
     * Desc: To check Widget Removeable 
     * @param: 
     * @return: Decimal
    **/
    
    public static boolean isWidgetRemoveable()    {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().Is_Widget_Removeable__c  ;
    }
    
     /**
     * Name: isLoadNewCustomerOrder
     * Desc: To check Load New Customer Order 
     * @param: 
     * @return: boolean
    **/
    
    public static boolean isLoadNewCustomerOrder()    {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().Load_New_Customer_Order__c;
    }
    
    public static boolean isLoadNewCO()    {
        return General_Configurations__c.getInstance().Load_New_Customer_Order__c;
    }
    
     /**
     * Name: isLoadNewUI
     * Desc: To check Load New UI
     * @param: 
     * @return: boolean
    **/
    
    public static boolean isLoadNewUI()    {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().Load_New_UI__c  ;
    }
    
     /**
     * Name: IsLoadNewHeader
     * Desc: To check Load New Header
     * @param: 
     * @return: boolean
    **/
     
    public static boolean IsLoadNewHeader()    {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().Load_New_Header__c  ;
    }
    
     /**
     * Name: isLoadTechnicianScheduling
     * Desc: To check whether to Load Technician Scheduling or not 
     * @param: 
     * @return: boolean
    **/
    
    public static boolean isLoadTechnicianScheduling()    {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().Technician_Scheduling__c  ;
    }
    
     /**
     * Name: IsFusionMappingEnabled
     * Desc: To check whether to Load Fusion Mapping or not 
     * @param: 
     * @return: boolean
    **/
    
    public static boolean IsFusionMappingEnabled()    {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().H_D_Dealer__c  ;
    }
    
    
       /**
     * Name: isLoadNewViewCustomer
     * Desc: To check Load New View Customer
     * @param: 
     * @return: boolean
    **/  
       
    public static boolean isLoadNewViewCustomer()    {
        return General_Configurations__c.getInstance().Load_New_View_Customer__c  ;
    }
    
           /**
     * Name: getNamespace
     * Desc: To get Namespace
     * @param: 
     * @return: String
    **/ 
    
    public static String getNamespace()    {
        if(ConfigurationScript.isPostInstallRunning) {return PostInstallClass.NAMESPACE;}
        
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('ApexClass') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        String nameSpace = General_Configurations__c.getInstance().Namespace__c;
        if(String.isBlank(nameSpace)) {
            nameSpace = [Select NamespacePrefix, Name, Id From ApexClass where Name = 'Constants'].NamespacePrefix;
            if(!String.isBlank(nameSpace)){
                nameSpace += '__';
            }
        }
        return (nameSpace == null) ? '' : nameSpace;
    }    
    
    /**
     * Name: getHomeSearchGridPageSize
     * Desc: To get Home Search Grid Page Size
     * @param: 
     * @return: Decimal
    **/
    public static Decimal getAustralianMarketSalesTaxRate() {
        return Australian_Market__c.getInstance().Sales_Tax_Rate__c ;
    }
    
    /**
     * Name: getTaxIncludingPricing
     * Desc: To get if tax Including pricing is true or not
     * @param: 
     * @return: Decimal
    **/
    public static Boolean getTaxIncludingPricing() {
        return Configurations__c.getOrgDefaults().Tax_Included_Pricing__c;
}
    
    public static Boolean getCalcTax_Invoice() {
        return Configurations__c.getOrgDefaults().CalcTax_Invoice__c;
    }
    
    public static String getOrderingTaxRate() {
        return Configurations__c.getOrgDefaults().Ordering_Tax_Rate__c;
    }
          
    public static Boolean getCalcTax_LineItem() {
        return Configurations__c.getOrgDefaults().CalcTax_LineItem__c;
    }
     
    public static Decimal getStampDutyRate() {
        return (Configurations__c.getOrgDefaults().Stamp_Duty_Rate__c != null) ? Configurations__c.getOrgDefaults().Stamp_Duty_Rate__c : 0;
    }
    
    public static Boolean getAccrueTradeTaxUntilUnitSold() {
        return Configurations__c.getOrgDefaults().Accrue_Trade_Tax_Until_Unit_Sold__c;
    }
       
    /**
     * Name: getIsTrialOrg
     * Desc: To get if trail Org is true or not
     * @param: 
     * @return: Boolean
    **/
    public static Boolean isTrialOrg() {
        String namespace = [Select NamespacePrefix, Name, Id From ApexClass where Name = 'Constants'].NamespacePrefix;

        List<PackageLicense> packLicRec = [SELECT Id,Status,Expirationdate, NamespacePrefix FROM PackageLicense WHERE
                             NamespacePrefix = :namespace];
        if(packLicRec.size()>0){
            if(packLicRec[0].Status.equalsIgnoreCase('trial')){
                return true;
            }           
        }
        return false;
        //return General_Configurations__c.getOrgDefaults().Is_Trial_Org__c; commented by Anurag
    }
    
    
    /**
     * Name: getTrialOrgDays
     * Desc: To get the number of days for trial Org
     * @param: 
     * @return: Integer
    **/
     public static Integer getTrialOrgDays() {
        if(AccessControl.ifObjectFieldIsAccessible('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        String namespace = [Select NamespacePrefix, Name, Id From ApexClass where Name = 'Constants'].NamespacePrefix;
        List<PackageLicense> packLicRec = [SELECT Id,Status,Expirationdate, NamespacePrefix FROM PackageLicense WHERE
                                            NamespacePrefix = :namespace];
        Integer noOfDays = 0;
        if(packLicRec.size() == 0){
            //noOfDays = 14;
        }
        if(packLicRec.size() > 0 && packLicRec[0].Status.equalsIgnoreCase('trial') && packLicRec[0].Expirationdate != null){
            Date startDate = Date.valueOf(packLicRec[0].Expirationdate);  
            noOfDays = (Date.today().daysBetween(startDate));
        }
        return noOfDays;
        //return General_Configurations__c.getOrgDefaults().Is_Trial_Org__c; commented by Anurag
    }
    
     /**  
     * Name: getIsSystemSettingVisites
     * Desc: To get if System Setting is visited or not
     * @param: 
     * @return: Boolean
    **/
    public static Boolean isSystemSettingVisited() {
        return General_Configurations__c.getOrgDefaults().Is_System_Setting_Visited__c;
    } 
    
    /**  
     * Name: communityLink
     * Desc: To get communityLink
     * @param: 
     * @return: String
    **/
    public static String communityLink() {
        return BP_Configurations__c.getOrgDefaults().Community_Link__c;
    } 
    
    /**  
     * Name: getSupportEmail
     * Desc: To get SupportEmail
     * @param: 
     * @return: String
    **/
    public static String getSupportEmail() {
        return BP_Configurations__c.getOrgDefaults().Support_Email__c;
    } 
    
    /**  
     * Name: getSupportEmailRecipient
     * Desc: To get SupportEmail for Recipient
     * @param: 
     * @return: String
    **/    
    public static String getSupportEmailRecipient() {
        return BP_Configurations__c.getOrgDefaults().Support_Email_Recipient__c;
    }
    
    /**  
     * Name: getSupportEmail
     * Desc: To get SupportEmail
     * @param: 
     * @return: String
    **/
    public static String getCompanyLogoUrl() {
        return BP_Configurations__c.getOrgDefaults().Company_Logo_URL__c;
    }   
    
    
    /**  
     * Name: getCompanyLogoUrl
     * Desc: To get SupportEmail
     * @param: 
     * @return: String
    **/
    public static boolean getIsDataLoadFlag() {
        return BP_Configurations__c.getOrgDefaults().Is_Data_Load__c;
    } 
    
    public static boolean getLoadFinanceSection() {
        return General_Configurations__c.getOrgDefaults().Load_Financing_Section__c;
    }
    
    /**  
     * Name: getMapAPIKey
     * Desc: To get google map api key
     * @param: 
     * @return: String
    **/
    public static String getMapAPIKey() {
        return BP_Configurations__c.getOrgDefaults().MapAPIKey__c;
    } 
    
    public static String getDefaultPriceLevelOnInternalService() {
        return Configurations__c.getOrgDefaults().Default_Price_Level_on_Internal_Service__c;
    }
    
    public static String getDefaultSalesTaxOnInternalService() {
        return Configurations__c.getOrgDefaults().Default_Sales_Tax_on_Internal_Service__c;
    }
    
    /**  
     * Name: getCashPaymenmtRoundingFactor
     * Desc: To get Cash Paymenmt Rounding Factor
     * @param: 
     * @return: String
    **/
    public static Decimal getCashPaymenmtRoundingFactor() {
        return Configurations__c.getOrgDefaults().Cash_Payment_Rounding_Factor__c;
    }
    
    /**  
     * Name: getCurrentUserGroupName
     * Desc: To get Group Name
     * @param: 
     * @return: String
    **/
    public static String getCurrentUserGroupName() {
        List<User_To_Group__c> userGroupList = [select User_Group__r.Name 
                                                from User_To_Group__c 
                                                where User__c = :UserInfo.getUserId()];
        String groupName = '';
        if(userGroupList.size() > 0 && userGroupList[0].User_Group__r.Name != null){
            groupName = userGroupList[0].User_Group__r.Name;
        }
        return groupName;
    }
    
    public static String getCurrentUserGroupId() {
        List<User_To_Group__c> userGroupList = [select User_Group__c, User_Group__r.Name 
                                                from User_To_Group__c 
                                                where User__c = :UserInfo.getUserId()];
        String groupId = '';
        if(userGroupList.size() > 0 && userGroupList[0].User_Group__r.Name != null){
            groupId = userGroupList[0].User_Group__c;
        }
        return groupId;
    }
    
    public static String getCurrentUserGroupColor() {
        List<User_To_Group__c> userGroupList = [select User_Group__c, User_Group__r.Colour_Code__c 
                                                from User_To_Group__c 
                                                where User__c = :UserInfo.getUserId()];
        String groupColor = '';
        if(userGroupList.size() > 0 && userGroupList[0].User_Group__r.Colour_Code__c != null){
            groupColor = userGroupList[0].User_Group__r.Colour_Code__c;
        }
        return groupColor;
    }
    
    
    /**  
     * Name: getCompanyLocale
     * Desc: To get Country Name of company
     * @param: 
     * @return: String
    **/
    public static String getCompanyLocale() {
        String locale = '';
        if(AccessControl.ifObjectFieldIsAccessible('Business_Profile__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Business_Profile__c> businessProfiles = [select Business_Country__r.Name__c
                                                        from Business_Profile__c 
                                                        limit 1];
        if(businessProfiles.size() > 0 && businessProfiles[0].Business_Country__r.Name__c != null){
            locale = businessProfiles[0].Business_Country__r.Name__c;
        }
        return locale;
    }
    
    /**
     * Name: getShopSuppliesCalculationMethod
     * Desc: Load Custom Settings for Shop Supplies
     * @return: ShopSuppliesCustomSetting
    **/
    public static ShopSuppliesCustomSetting getShopSuppliesCalculationMethod()    {
        if(AccessControl.ifObjectFieldIsAccessible('Shop_Supplies__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Shop_Supplies__c shopSupplies = Shop_Supplies__c.getInstance();
        if(shopSupplies != null) {
            return new ShopSuppliesCustomSetting(shopSupplies);
        }
        return null;
    }
    
    /**
     * Name: isCalculationMethodAvailable
     * Desc: To check if Shop Supplies CalculationMethod is available
     * @return: boolean
    **/
    public static boolean isCalculationMethodAvailable() {
        ShopSuppliesCustomSetting shopSuppliesCustomSetting = GeneralConfiguration.getShopSuppliesCalculationMethod();     
        return !(shopSuppliesCustomSetting == null || shopSuppliesCustomSetting.CalculationMethod == Constants.NOT_CALCULATED);
    }
    
    /**
     * Name: isItemizedByLaborCode
     * Desc: To check if Itemized by labor code for Shop Supplies
     * @return: boolean
    **/
    public static boolean isItemizedByLaborCode() {
        return Shop_Supplies__c.getOrgDefaults().Itemized_by_labor_code__c;
    }
    
    /**
     * Name: isDisplayTaxInvoice
     * Desc: To check if Tax Invoice 
     * @return: boolean
    **/
    public static boolean isDisplayTaxInvoice() {
        return General_Configurations__c.getOrgDefaults().Display_Tax_Invoice__c;
    }
    
   /**
     * Name: getDP360DealerId
     * Desc: To get DP360 dealer id
     * @param: 
     * @return: String
    **/  
       
    public static String getDP360DealerId() {
        return DP360_Configuration__c.getInstance().Dealer_Id__c  ;
    }
    
    public static String getTradeTaxExpenseCategory() {
        return Configurations__c.getOrgDefaults().Trade_Tax_Expense_Category__c  ;
    }
    public static String getTradeTaxLiabilityCategory() {
        return Configurations__c.getOrgDefaults().Trade_Tax_Liability_Category__c  ;
    }
    public static String getTradeTaxPendingSaleCategory() {
        return Configurations__c.getOrgDefaults().Trade_Tax_Pending_Sale_Category__c  ;
    }
    
    public static Boolean isAccruTradeTaxUntilUnitSold() {
        return Configurations__c.getOrgDefaults().Accrue_Trade_Tax_Until_Unit_Sold__c ;
    }
    
    public static Boolean isTradeTaxCreditCanNotExceedUnitTax() {
        return Configurations__c.getOrgDefaults().Trade_Tax_Credit_Can_Not_Exceed_Unit_Tax__c ;
    }
    
    /**
     * Name: getDP360LastSynchedDate
     * Desc: To get DP360 last synched date
     * @param: 
     * @return: DateTime
    **/  
       
    public static DateTime getDP360LastSynchedDate() {
        return DP360_Configuration__c.getInstance().Last_Synched_Date__c  ;
    }
    
    public static String getPartAgingPeriod1() {
        return Part_Aging_Period__c.getInstance().Period_1__c  ;
    }
    public static String getPartAgingPeriod2() {
        return Part_Aging_Period__c.getInstance().Period_2__c  ;
    }
    public static String getPartAgingPeriod3() {
        return Part_Aging_Period__c.getInstance().Period_3__c  ;
    }
    
    /**
     * Name: getSchedulerStartDay
     * Desc: get start day for scheduler
     * @return: Decimal
    **/
    public static Decimal getSchedulerStartDay() {
        if(AccessControl.ifObjectFieldIsAccessible('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return General_Configurations__c.getInstance().Scheduler_Start_Day__c  ;
    }
}