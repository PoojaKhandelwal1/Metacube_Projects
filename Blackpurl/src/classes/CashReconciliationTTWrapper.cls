public with sharing class CashReconciliationTTWrapper {
    public String PaymentMethod;
    public String Icon;
    public Decimal TotalProcessedAmount;
    public Decimal TotalActualAmount;
    public Decimal TotalVarianceAmount;
    public List<CashDrawerDetailWrapper> CashDrawerDetailObjList;
    
    public CashReconciliationTTWrapper(Reconciliation_Payment__mdt paymentTypeRec, Map<String, List<Sobject>> drawerNameToCOPaymentListMap, Set<String> cashDrawerNameSet, Map<String, Decimal> drawerNameToActualAmountMap) {
        GlobalController obj = new GlobalController();
        this.PaymentMethod = paymentTypeRec.Label;
        this.Icon = GlobalController.Application_Images + paymentTypeRec.Icon_Link__c;
        this.TotalProcessedAmount = 0;
        this.TotalActualAmount = 0;
        this.TotalVarianceAmount = 0;
        CashDrawerDetailObjList = new List<CashDrawerDetailWrapper>();
        for(String drawerName: cashDrawerNameSet) {
            List<sObject> sObjectList = drawerNameToCOPaymentListMap != null && drawerNameToCOPaymentListMap.containsKey(drawerName) ? drawerNameToCOPaymentListMap.get(drawerName) : new List<sObject>();
            Decimal actualAmount = drawerNameToActualAmountMap != null && drawerNameToActualAmountMap.containsKey(drawerName) && drawerNameToActualAmountMap.get(drawerName) != null ? drawerNameToActualAmountMap.get(drawerName) : 0;
            CashDrawerDetailWrapper cashDrawerDetailObj = new CashDrawerDetailWrapper(drawerName, sObjectList, actualAmount);
            CashDrawerDetailObjList.add(cashDrawerDetailObj);
            this.TotalProcessedAmount += cashDrawerDetailObj.ProcessedAmount;
            this.TotalActualAmount += cashDrawerDetailObj.ActualAmount;
        }
        this.TotalProcessedAmount = this.TotalProcessedAmount.setScale(2, RoundingMode.HALF_UP);
        this.TotalActualAmount = this.TotalActualAmount.setScale(2, RoundingMode.HALF_UP);
        this.TotalVarianceAmount = this.TotalActualAmount - this.TotalProcessedAmount;
    }
    
    public class CashDrawerDetailWrapper {
        public String CashDrawerName;
        public Decimal ProcessedAmount;
        public Decimal ActualAmount;
        
        public CashDrawerDetailWrapper(String drawerName, List<sObject> sobjectList, Decimal actualAmount) {
            this.CashDrawerName = drawerName;
            this.ProcessedAmount = 0;
            this.ActualAmount = actualAmount;
            if(sobjectList == null) {
                sobjectList = new List<sObject>();
            }
            for(sObject sObjectRec : sobjectList) {
                Id sobjectId = String.valueOf(sobjectRec.get('Id'));
                if(sobjectId.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'CO_Invoice_Payment__c') {
                    CO_Invoice_Payment__c coInvoicePaymentRec = (CO_Invoice_Payment__c)sobjectRec;
                    this.ProcessedAmount += (coInvoicePaymentRec.Amount__c != null ? coInvoicePaymentRec.Amount__c : 0.00);
                } else if(sobjectId.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'CO_Deposit__c') {
                    CO_Deposit__c coDepositRec = (CO_Deposit__c)sobjectRec;
                    this.ProcessedAmount += (coDepositRec.Amount__c != null ? coDepositRec.Amount__c : 0.00);
                }
            }
        }
    }
}