public with sharing class QB_TaxCodeService {
    
    private static final String NO_TAX_RATE_CODE = 'No Tax Rate';
    
    public static List<TaxCodeWrapper> getTaxCodeCombination() {
        List<TaxCodeWrapper> taxCodeWrapperList;
        if(QBUtil.isUSVersionQB()) {
            taxCodeWrapperList = getTaxCodeSetsForUSVersion();
        } else {
            taxCodeWrapperList = getTaxCodeSetsForInternationalVersion();
        }
        return taxCodeWrapperList;
    }
    
    public static String getTaxCodeId(String customerId) {
        String taxCodeId;
        if(QBUtil.isUSVersionQB()) {
            if(String.isNotBlank(customerId)) {
	            List<Sales_Tax_Item__c> applicableList = [Select Name__c from Sales_Tax_Item__c where Id NOT IN
	                                            (Select Sales_Tax_Item__c from Tax_Exemption__c where Customer__c =: customerId) AND 
	                                            Active__c = true Order BY Name__c];
	            String salesTaxItemStr = '';
	            if(applicableList.size() > 0) {
	                for(Sales_Tax_Item__c salesTaxRec : applicableList) {
	                    salesTaxItemStr += salesTaxRec.Name__c + '-';
	                }
	                salesTaxItemStr = salesTaxItemStr.length() > 1 ? salesTaxItemStr.subString(0, salesTaxItemStr.length() - 1) : salesTaxItemStr;
	            } else {
	                salesTaxItemStr = NO_TAX_RATE_CODE;
	            }
	            
	            List<QB_TaxCode__c> qbTaxCodeList = [Select Accounting_Id__c from QB_TaxCode__c where Name =: salesTaxItemStr];
	            if(qbTaxCodeList.size() > 0) {
	                taxCodeId = qbTaxCodeList[0].Accounting_Id__c;
	            }
	        }
        } else {
            List<QB_TaxCode__c> qbTaxCodeList = [Select Accounting_Id__c from QB_TaxCode__c limit 1];
            if(qbTaxCodeList.size() > 0) {
                taxCodeId = qbTaxCodeList[0].Accounting_Id__c;
            }
        }
        return taxCodeId;
    }
    
    private static List<TaxCodeWrapper> getTaxCodeSetsForInternationalVersion() {
        List<TaxCodeWrapper> taxCodeWrapperList = new List<TaxCodeWrapper>();
        List<Sales_Tax_Item__c> salesTaxItemList = [SELECT Name__c, AccountingId__c, Rate__c FROM Sales_Tax_Item__c 
                                                            WHERE Active__c = true Order by Name__c];
        
        taxCodeWrapperList.add(new TaxCodeWrapper(salesTaxItemList));
        return taxCodeWrapperList;
    }
    
    private static List<TaxCodeWrapper> getTaxCodeSetsForUSVersion() {
        List<TaxCodeWrapper> taxCodeWrapperList = new List<TaxCodeWrapper>();
        List<Sales_Tax_Item__c> salesTaxItemList = [SELECT Name__c, AccountingId__c, Rate__c FROM Sales_Tax_Item__c 
                                                             WHERE Active__c = true Order by Name__c];
        List<Sales_Tax_Item__c> salesTaxItemSubsetList;
        
        for(Integer i = 0; i < (1 << salesTaxItemList.size()); i++) {
            salesTaxItemSubsetList = new List<Sales_Tax_Item__c>();
            for(Integer j = 0; j < salesTaxItemList.size(); j++) {
                if((i & (1 << j)) > 0) {
                    salesTaxItemSubsetList.add(salesTaxItemList[j]);
                }
            }
            taxCodeWrapperList.add(new TaxCodeWrapper(salesTaxItemSubsetList));
        }
        return taxCodeWrapperList;
    }
    
    public class TaxCodeWrapper {
        public QB_TaxCode__c QBTaxCodeRec;
        public List<Sales_Tax_Item__c> SalesTaxItemList;
        
        public TaxCodeWrapper(List<Sales_Tax_Item__c> salesTaxItemList) {
            this.SalesTaxItemList = salesTaxItemList;
            String salesTaxItemStr = '';
            for(Sales_Tax_Item__c salesTaxItemRec : salesTaxItemList) {
                salesTaxItemStr += salesTaxItemRec.Name__c + '-';
            }
            salesTaxItemStr = salesTaxItemStr.length() > 1 ? salesTaxItemStr.subString(0, salesTaxItemStr.length() - 1) : salesTaxItemStr;
            this.QBTaxCodeRec = new QB_TaxCode__c(Name = (String.isNotBlank(salesTaxItemStr) ? salesTaxItemStr : NO_TAX_RATE_CODE));
        }
    }
}