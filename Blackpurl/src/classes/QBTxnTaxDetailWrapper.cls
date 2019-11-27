public with sharing class QBTxnTaxDetailWrapper {
    public Decimal TotalTax; 
    public List<TaxLineWrapper> TaxLine;
    public QBTxnTaxDetailWrapper(Decimal TotalTax, List<AccountingCustomerInvoice.TaxDetail> taxDetails, Set<Id> applicableSalesTaxSet, Boolean isNonTaxableLIExists) {
        this.TaxLine = new List<TaxLineWrapper>();  
        this.TotalTax = TotalTax;
        List<Applicable_Taxes__c> applicableTaxList = new List<Applicable_Taxes__c>();
        List<Sales_Tax__c> salesTaxWithoutItemsList = new List<Sales_Tax__c>();
        Set<String> alreadyAddedTaxRates = new Set<String>();
        
        if(applicableSalesTaxSet.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            applicableTaxList = [SELECT Sales_Tax__c, Sales_Tax_Item__c FROM Applicable_Taxes__c WHERE Sales_Tax__c IN :applicableSalesTaxSet];
            salesTaxWithoutItemsList = [SELECT Accounting_Id__c FROM Sales_Tax__c WHERE Id IN :applicableSalesTaxSet AND Id NOT IN (SELECT Sales_Tax__c FROM Applicable_Taxes__c)];
        }
        
        Set<String> applicableSalesTaxItemSet = createSetOfApplicableSalesTaxItems(applicableTaxList);
        // add tax lines for applicable tax rates
        for(AccountingCustomerInvoice.TaxDetail taxRec : taxDetails) {
            if(applicableSalesTaxItemSet.contains(taxRec.Id)) {
                alreadyAddedTaxRates.add(taxRec.AccountingId);
                this.TaxLine.add(new TaxLineWrapper(taxRec));
            }
        }
        
        Set<String> qbTaxRatesSet = getQBTaxRatesForSalesTaxWithoutItems(salesTaxWithoutItemsList);
        // add tax lines for zero applicable sales tax
        for(String taxRateAccId: qbTaxRatesSet) {
            if(!alreadyAddedTaxRates.contains(taxRateAccId)) {
                alreadyAddedTaxRates.add(taxRateAccId);
                this.TaxLine.add(new TaxLineWrapper(new AccountingCustomerInvoice.TaxDetail('', '', 0, 0, taxRateAccId, '')));
            }
        }
        
        // add tax lines for non taxable LI's if exists
        if(isNonTaxableLIExists) {
            Map<String, List<String>> nonTaxCodeToRatesMap = QBUtil.getNonTaxableTaxCodeWithRates(QBUtil.SALES);
            if(nonTaxCodeToRatesMap.containsKey(QBUtil.nonTaxableCodeAccId)) {
                for(String taxRateAccId : nonTaxCodeToRatesMap.get(QBUtil.nonTaxableCodeAccId)) {
                    if(!alreadyAddedTaxRates.contains(taxRateAccId)) {
                        alreadyAddedTaxRates.add(taxRateAccId);
                        this.TaxLine.add(new TaxLineWrapper(new AccountingCustomerInvoice.TaxDetail('', '', 0, 0, taxRateAccId, '')));
                    }
                }
            }
        }
    }
    
    public QBTxnTaxDetailWrapper(Decimal totalTax, List<AccountingVendorReturn.TaxRateComponent> taxRateList) {
        this.TotalTax = totalTax;
        this.TaxLine = new List<TaxLineWrapper>();  
        if(taxRateList != null) {
           for(AccountingVendorReturn.TaxRateComponent taxRateRec : taxRateList) {
                this.TaxLine.add(new TaxLineWrapper(taxRateRec.TaxAmount, taxRateRec.TaxRateAcctId, taxRateRec.TaxableAmount));
            } 
        }
        
    }
    
    public QBTxnTaxDetailWrapper(Decimal totalTax, List<AccountingVendorInvoice.TaxRateComponent> taxComponents) {
        this.TotalTax = totalTax;
        this.TaxLine = new List<TaxLineWrapper>();  
        if(taxComponents != null) {
            for(AccountingVendorInvoice.TaxRateComponent taxComponentRec : taxComponents) {
                this.TaxLine.add(new TaxLineWrapper(taxComponentRec.TaxAmount, taxComponentRec.TaxRateAcctId, taxComponentRec.TaxableAmount));
            }
        }
    }
    
    public QBTxnTaxDetailWrapper(Decimal totalTax, List<AccountingUnit.TaxRateComponent> taxComponents) {
        this.TotalTax = totalTax;
        this.TaxLine = new List<TaxLineWrapper>();  
        if(taxComponents != null) {
            for(AccountingUnit.TaxRateComponent taxComponentRec : taxComponents) {
                this.TaxLine.add(new TaxLineWrapper(taxComponentRec.TaxAmount, taxComponentRec.TaxRateAcctId, taxComponentRec.TaxableAmount));
            }
        }
    }
    
    public QBTxnTaxDetailWrapper(){}
    
    public class TaxLineWrapper {
        public String DetailType; 
        public TaxLineDetailWrapper TaxLineDetail; 
        public Decimal Amount;
        
        public TaxLineWrapper(Decimal taxAmount, String taxRateAccountingId, Decimal taxableAmount) {
           this.DetailType = 'TaxLineDetail'; 
           this.TaxLineDetail = new TaxLineDetailWrapper(taxRateAccountingId, taxableAmount);
           this.Amount = taxAmount;
        }
        public TaxLineWrapper(AccountingCustomerInvoice.TaxDetail taxRec) {
            this.DetailType = 'TaxLineDetail';  
            this.TaxLineDetail = new TaxLineDetailWrapper(taxRec); 
            this.Amount = taxRec.TaxAmount;
        }
    }
    
    public class TaxLineDetailWrapper {
        public QBInnerEntityWrapper TaxRateRef; 
        public Decimal NetAmountTaxable;
        public TaxLineDetailWrapper(AccountingCustomerInvoice.TaxDetail taxRec) {
            this.TaxRateRef = new QBInnerEntityWrapper(taxRec.AccountingId, '');    
            this.NetAmountTaxable = taxRec.TaxableAmount;
        }
        public TaxLineDetailWrapper(String taxRateAccountingId, Decimal taxableAmount) {
            this.TaxRateRef = new QBInnerEntityWrapper(taxRateAccountingId, '');    
            this.NetAmountTaxable = taxableAmount;
        }
        public TaxLineDetailWrapper() {
            
        }
    }
    
    private Set<String> createSetOfApplicableSalesTaxItems(List<Applicable_Taxes__c> applicableTaxList) {
        Set<String> applicableSalesTaxItemSet = new Set<String>();
        for(Applicable_Taxes__c appTaxRec: applicableTaxList) {
            applicableSalesTaxItemSet.add(appTaxRec.Sales_Tax_Item__c);
        }
        return applicableSalesTaxItemSet;
    }
    
    private Set<String> getQBTaxRatesForSalesTaxWithoutItems(List<Sales_Tax__c> salesTaxWithoutItemsList) {
        Set<String> qbTaxRatesSet = new Set<String>();
        Set<String> taxCodesAccIdSet = new Set<String>();
        for(Sales_Tax__c salesTaxRec: salesTaxWithoutItemsList) {
            taxCodesAccIdSet.add(salesTaxRec.Accounting_Id__c);
        }
        
        List<QB_TaxCode__c> taxCodeWithZeroRateList = new List<QB_TaxCode__c>();
        if(taxCodesAccIdSet.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('QB_TaxCode__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            taxCodeWithZeroRateList = [SELECT Applicable_QB_Tax_Rates__c FROM QB_TaxCode__c WHERE Accounting_Id__c IN :taxCodesAccIdSet AND Tax_Applicable_On__c = :QBUtil.SALES];
        }
        
        for(QB_TaxCode__c qbTaxCodeRec: taxCodeWithZeroRateList) {
            if(String.isNotBlank(qbTaxCodeRec.Applicable_QB_Tax_Rates__c)) {
                 qbTaxRatesSet.addAll(qbTaxCodeRec.Applicable_QB_Tax_Rates__c.split(';'));
            }
        }
        return qbTaxRatesSet;
    }
}