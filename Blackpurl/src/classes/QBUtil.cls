public with sharing class QBUtil {
    public final static String US_VERSION = 'US';
    public final static String INTERNATIONAL_VERSION = 'International';
    public final static String AUS_VERSION = 'AUS';
    public final static String SALES_RECEIPT = 'salesreceipt';
    public final static String INVOICE = 'invoice';
    public final static String REFUND_RECEIPT = 'refundreceipt';
    public final static String CREDIT_MEMO = 'creditmemo';
    public final static String CO_INVOICE_NO_JE_MSG = 'All Line items either have zero cost or are fees. So, no line item to post to QB.';
    public final static String CO_INVOICE_NO_LI_MSG = 'No line item to post to QB while syncing invoice.';
    public final static String INTERNAL = 'Internal';
    public final static String DEAL = 'Deal';
    public final static String CLOSED = 'Closed';
    public final static String CHARGE_ACCOUNT = 'Charge Account';
    public final static String PART_CREATED = 'Part Created';
    public final static String OVERSOLD = 'Oversold';
    public final static String STOCKED = 'Stocked';
    public final static String DEAL_ITEM_TYPE_TRADE_IN = 'Trade In';
    public final static String TAX_NOT_APPLICABLE = 'NotApplicable';
    public final static String TAX_EXCLUDED = 'TaxExcluded';
    public final static String TAX_INCLUSIVE = 'TaxInclusive';
    public final static String SALES = 'Sales';
    public final static String PURCHASE = 'Purchase';
    public static Integer MAX_RECORDS_UPDATE_LIMIT = 500;
    public static Boolean isQBTaxCodesEnabled = (General_Configurations__c.getOrgDefaults() != null) ? General_Configurations__c.getOrgDefaults().Use_QB_accounting_tax_codes__c : false;
    public static String nonTaxableCodeAccId = (QuickBooks_Configurations__c.getOrgDefaults() != null) ? QuickBooks_Configurations__c.getOrgDefaults().Non_Taxable_Tax_Code__c : null;
    public static String nonTaxablePurchaseCodeAccId = (QuickBooks_Configurations__c.getOrgDefaults() != null) ? QuickBooks_Configurations__c.getOrgDefaults().Non_Taxable_Purchase_Tax_Code__c : null;
    
    public static Boolean isQBEnabled() {
        return (General_Configurations__c.getOrgDefaults() != null) ? General_Configurations__c.getOrgDefaults().Enable_QB_Accounting__c : false ;
    }
     
    public static Boolean isUSVersionQB() {
        return (getQBVersion() == US_VERSION);
    }
    
    public static String getQBVersion() {
        QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
        return qbConfig.Company_Country__c;
    }    
    
    public static String getCronExpForGivenTime(Integer second) {
        DateTime dtVal = system.now().addSeconds(second);
        String strSchedule = String.valueOf(dtVal.second()) + ' ' + String.valueOf(dtVal.minute()) + ' ' + String.valueOf(dtVal.hour()) + 
                                ' ' + String.valueOf(dtVal.day()) + ' ' + String.valueOf(dtVal.month()) + ' ?' + ' ' + String.valueOf(dtVal.year());
        return strSchedule;
    }
    
    public static void abortAlreadyScheduleJobs(String jobName) {
        List<CronTrigger> alreadyScheduledJobs = [Select Id from CronTrigger where CronJobDetail.Name =: jobName];
        if(alreadyScheduledJobs.size() > 0) {
            system.abortJob(alreadyScheduledJobs[0].Id);    
        }
    }
    
    public static String getDealUnitName(Deal_Item__c dealItem) {
        String Item = '';
        if(dealItem.Customer_Owned_Unit__c != null) {
            Boolean showDash = false;
            if(dealItem.Customer_Owned_Unit__r.Year__c != null){
                Item += dealItem.Customer_Owned_Unit__r.Year__c;
                showDash = true;
            }
            if(String.isNotBlank(dealItem.Customer_Owned_Unit__r.Unit_Make__r.Name)) {
                Item += ' ' + dealItem.Customer_Owned_Unit__r.Unit_Make__r.Name;
                showDash = true;
            }
            if(String.isNotBlank(dealItem.Customer_Owned_Unit__r.Unit_Model__r.Name__c)) {
                Item += ' ' + dealItem.Customer_Owned_Unit__r.Unit_Model__r.Name__c;
                showDash = true;
            }
            if(String.isNotBlank(dealItem.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c)) {
                Item += ' ' + dealItem.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c;
                showDash = true;
            }
            if(String.isNotBlank(dealItem.Customer_Owned_Unit__r.VIN_Number__c)) {
                if(showDash) {
                    Item += ' - ';
                }
                Item += dealItem.Customer_Owned_Unit__r.VIN_Number__c ;
            }
        }
        return Item;
    }
    
    public static String truncateString(String stringToTruncate, Integer noOfCharacters) {
    	return String.isNotBlank(stringToTruncate) && (stringToTruncate.length() > noOfCharacters) ? stringToTruncate.substring(0, noOfCharacters) : stringToTruncate ;
    }
    
    public static Map<String, List<String>> getNonTaxableTaxCodeWithRates(String taxType) {
    	Map<String, List<String>> nonTaxableTaxCodeToTaxRatesMap = new Map<String, List<String>>();
    	if(String.isNotBlank(nonTaxableCodeAccId)) {
    	    if(AccessControl.ifObjectFieldIsAccessible('QB_TaxCode__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    		List<QB_TaxCode__c> taxCodeList = [SELECT Applicable_QB_Tax_Rates__c FROM QB_TaxCode__c WHERE Accounting_Id__c = :nonTaxableCodeAccId AND Tax_Applicable_On__c =: taxType];
    		if(taxCodeList.size() > 0 && String.isNotBlank(taxCodeList[0].Applicable_QB_Tax_Rates__c)) {
    			 List<String> taxRates = taxCodeList[0].Applicable_QB_Tax_Rates__c.split(';');
    			 nonTaxableTaxCodeToTaxRatesMap.put(nonTaxableCodeAccId, taxRates);
    		}
    	}
    	return nonTaxableTaxCodeToTaxRatesMap;
    }
}
