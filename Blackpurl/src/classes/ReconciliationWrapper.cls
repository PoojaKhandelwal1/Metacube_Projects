/**
 * Author: Tarun Khandelwal
 * Since: Oct 10, 2017 
 * Name: ReconciliationWrapper
 * Description: Used to handle all JSON related work related to Cash Reconciliation
**/
public with sharing class ReconciliationWrapper {
	public ReconciliationInfo ReconciliationInfo;
	public Decimal Variance;
	public CashDrawerReconcilationWrapper.PaymentTypeWrapper TotalCashPaymentObj;
	public CashDrawerReconcilationWrapper.PaymentTypeWrapper TotalNonCashPaymentObj;
	public List<CashDrawerReconcilationWrapper> CashDrawerReconcilationObjList;
	
	//Unreconciled View
	public ReconciliationWrapper(List<Cash_Drawer__c> cashDrawerRecList, Map<String, Cash_Drawer_Reconciliation__c> cashDrawerIdToDrawerReconciliationRecMap, 
								List<Reconciliation_Payment__mdt> paymentTypeList, Cash_Reconciliation__c cashReconciliationRec, Boolean isSingleDrawerOrPrintView) {
    			
		this.ReconciliationInfo = new ReconciliationInfo(cashReconciliationRec);
		
		Integer numberOfActiveAndInactiveDrawerHavingAssociatedPayment = 0;
		for(Cash_Drawer__c cashDrawerRec : cashDrawerRecList) {
			if(cashDrawerRec.Active__c || (cashDrawerRec.CO_Invoice_Payments__r.size() > 0 || cashDrawerRec.CO_Deposits__r.size() > 0)) {
				numberOfActiveAndInactiveDrawerHavingAssociatedPayment++;
			}
		}
		
		Boolean isMultipleDrawerView = (isSingleDrawerOrPrintView ? false : ((numberOfActiveAndInactiveDrawerHavingAssociatedPayment > 1) ? true : false));
		if(isMultipleDrawerView) {
			this.Variance = 0;
			this.TotalCashPaymentObj = new CashDrawerReconcilationWrapper.PaymentTypeWrapper();
			this.TotalNonCashPaymentObj = new CashDrawerReconcilationWrapper.PaymentTypeWrapper();
		}
		this.CashDrawerReconcilationObjList = new List<CashDrawerReconcilationWrapper>();
		for(Cash_Drawer__c cashDrawerRec : cashDrawerRecList) {
			
			if(cashDrawerRec.Active__c || (cashDrawerRec.CO_Invoice_Payments__r.size() > 0 || cashDrawerRec.CO_Deposits__r.size() > 0)) {
				Cash_Drawer_Reconciliation__c cashDrawerReconciliationRec = (cashDrawerIdToDrawerReconciliationRecMap.containsKey(cashDrawerRec.Id) ? 
							cashDrawerIdToDrawerReconciliationRecMap.get(cashDrawerRec.Id) : 
							CashReconciliationService.getDummyCashDrawerReconciliationRec(cashReconciliationRec));
				cashDrawerReconciliationRec.Status__c = (String.isNotBlank(cashReconciliationRec.Status__c) && cashReconciliationRec.Status__c == 'Reconciled' ?
											cashReconciliationRec.Status__c : cashDrawerReconciliationRec.Status__c);		
				CashDrawerReconcilationWrapper reconciliationObj = new CashDrawerReconcilationWrapper(cashDrawerRec, cashDrawerReconciliationRec, paymentTypeList, isMultipleDrawerView);
				this.CashDrawerReconcilationObjList.add(reconciliationObj);
				
				if(isMultipleDrawerView) {
					this.TotalCashPaymentObj.ProcessedAmount += reconciliationObj.CashPaymentObj.ProcessedAmount;
					this.TotalCashPaymentObj.ActualAmount += reconciliationObj.CashPaymentObj.ActualAmount;
					this.TotalNonCashPaymentObj.ProcessedAmount += reconciliationObj.NonCashPaymentObj.ProcessedAmount;
				}
			}
		}
		this.Variance = (isMultipleDrawerView ? (this.TotalCashPaymentObj.ActualAmount - this.TotalCashPaymentObj.ProcessedAmount) : null);
	}
	
	public class ReconciliationInfo {
		public String Id;
		public String ReconciliationDate;
		public String CommitReconciliationDate;
		public String Status;
		
		public ReconciliationInfo(Cash_Reconciliation__c cashReconciliationRec) {
			this.Id = cashReconciliationRec.Id;
			this.ReconciliationDate = (cashReconciliationRec.Reconciliation_Date__c != null) ? 
											BPUtility.getFormatedDateTime(datetime.newInstance(cashReconciliationRec.Reconciliation_Date__c.year(), cashReconciliationRec.Reconciliation_Date__c.month(), cashReconciliationRec.Reconciliation_Date__c.day())) : '' ;
			this.Status = cashReconciliationRec.Status__c;
			this.CommitReconciliationDate = (cashReconciliationRec.Commit_Reconciliation_Date__c != null) ? 
											BPUtility.getFormatedDateTime(datetime.newInstance(cashReconciliationRec.Commit_Reconciliation_Date__c.year(), cashReconciliationRec.Commit_Reconciliation_Date__c.month(), cashReconciliationRec.Commit_Reconciliation_Date__c.day())) : '' ;
		}
	}
	
	public class MiniCalenderDate {
		public String StartDate;
		public String EndDate;
	}
    
    /**
     * Name: fieldsList
     * Desc: Method to get all fields related to Tag object
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getReconciliationFieldList() {
        return new List<String>{ 'Reconciliation_Date__c',
                                'Status__c',
                                'Total_Actual__c',
                                'Commit_Reconciliation_Date__c'
                        	};
    }
    
    public static List<String> getReconciliationPaymentFieldList() {
        return new List<String>{ 'Payment_Method__c',
                                'Actual_Amount__c',
                                'Processed_Amount__c',
                                'Cash_Reconciliation__c',
                                'Cash_Drawer_Reconciliation__r.Cash_Drawer__r.Name'
                        	};
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getCOInvoicePaymentfieldsList(){
        List<String> coInvoicePaymentFields = new List<String>{ 'Name',
	                                                        'Amount__c',
	                                                        'Payment_Method__c',
	                                                        'CO_Invoice_Header__r.CO_Header__r.Customer_Name__c',
	                                                        'CO_Invoice_Header__r.CO_Header__r.Name',
	                                                        'CO_Invoice_Header__r.CO_Header__c',
	                                                        'Cash_Drawer__c',
	                                                        'Cash_Drawer__r.Name'
	                                               		 };
        return coInvoicePaymentFields;
    }
    
    public static List<String> getCODepositFieldsList(){
        List<String> coDepositfields = new List<String>{ 'Name',
	                                                        'Amount__c',
	                                                        'Payment_Method__c',
	                                                        'CO_Header__r.Customer_Name__c',
	                                                        'CO_Header__r.Name',
	                                                        'CO_Header__c',
	                                                        'Cash_Drawer__c',
	                                                        'Cash_Drawer__r.Name'
	                                               		 };
        return coDepositfields;
    }
}