/**
 * Author: Nidhi Sharma
 * Since: Dec 16, 2018
 * Name: ReconciliationWrapper
 * Description: Used to handle all JSON related work related to Cash Drawer Reconciliation
**/
public without sharing class CashDrawerReconcilationWrapper {
    public String Id;
    public String DrawerId;
	public String DrawerName;
	public String Status;
	public String ReconciliationDate;
	public String CommitReconciliationDate;
	
	public PaymentTypeWrapper CashPaymentObj;
	public PaymentTypeWrapper NonCashPaymentObj;
	public Decimal Variance;
	
	public List<ReconciliationPayment> CashReconciliationPaymentList;
	public List<ReconciliationPayment> OtherReconciliationPaymentList;
	
	public CashDrawerReconcilationWrapper(Cash_Drawer__c cashDrawerRec, Cash_Drawer_Reconciliation__c cashDrawerReconciliationRec,  
											List<Reconciliation_Payment__mdt> paymentTypeList, Boolean isMultipleDrawer) {
		
		this.Id = cashDrawerReconciliationRec.Id;
		this.DrawerId = cashDrawerRec.Id;
        this.DrawerName = cashDrawerRec.Name;
        this.Status = (String.isNotBlank(cashDrawerReconciliationRec.Status__c) ? cashDrawerReconciliationRec.Status__c : 'Unreconciled');
        this.ReconciliationDate = this.CommitReconciliationDate = '';
		if(cashDrawerReconciliationRec.Cash_Reconciliation__r.Reconciliation_Date__c != null) {
			this.ReconciliationDate = BPUtility.getFormatedDateTime(datetime.newInstance(cashDrawerReconciliationRec.Cash_Reconciliation__r.Reconciliation_Date__c.year(), 
				cashDrawerReconciliationRec.Cash_Reconciliation__r.Reconciliation_Date__c.month(), cashDrawerReconciliationRec.Cash_Reconciliation__r.Reconciliation_Date__c.day()));
		}
		if(cashDrawerReconciliationRec.Cash_Reconciliation__r.Commit_Reconciliation_Date__c != null) {
			this.CommitReconciliationDate = BPUtility.getFormatedDateTime(datetime.newInstance(cashDrawerReconciliationRec.Cash_Reconciliation__r.Commit_Reconciliation_Date__c.year(), 
			cashDrawerReconciliationRec.Cash_Reconciliation__r.Commit_Reconciliation_Date__c.month(), cashDrawerReconciliationRec.Cash_Reconciliation__r.Commit_Reconciliation_Date__c.day()));
		}
		
		if(isMultipleDrawer) {
			this.CashPaymentObj = new PaymentTypeWrapper();
			this.NonCashPaymentObj = new PaymentTypeWrapper();
		} else {
			this.CashReconciliationPaymentList = new List<ReconciliationPayment>();
			this.OtherReconciliationPaymentList = new List<ReconciliationPayment>();
		}
		setRelatedFields(cashDrawerRec, cashDrawerReconciliationRec, paymentTypeList, isMultipleDrawer);
		this.Variance = (isMultipleDrawer) ? (this.CashPaymentObj.ActualAmount - this.CashPaymentObj.ProcessedAmount) : null;
	}
    
    private void setRelatedFields(Cash_Drawer__c cashDrawerRec, Cash_Drawer_Reconciliation__c cashDrawerReconciliationRec, List<Reconciliation_Payment__mdt> paymentTypeList, 
    												Boolean isMultipleDrawerView) {
    	
    	Map<String, List<Sobject>> paymentTypeToCOPaymentListMap = 
							CashReconciliationService.createPaymentTypeToCOPaymentListMap(cashDrawerRec.CO_Invoice_Payments__r, cashDrawerRec.CO_Deposits__r);
							
    	Map<String, Cash_Reconciliation_Payment__c> paymentTypeToReconciledPaymentMap = new Map<String, Cash_Reconciliation_Payment__c>();
		for(Cash_Reconciliation_Payment__c reconciliationPaymentRec : cashDrawerReconciliationRec.Cash_Reconciliation_Payments__r) {
			paymentTypeToReconciledPaymentMap.put(reconciliationPaymentRec.Payment_Method__c, reconciliationPaymentRec);
		}
		
		GlobalController obj = new GlobalController();											
    	for(Reconciliation_Payment__mdt paymentTypeRec : paymentTypeList) {
			List<sObject> sobjectList = new List<CO_Invoice_Payment__c>();
			
			if(paymentTypeToCOPaymentListMap.containsKey(paymentTypeRec.Payment_Method__c)) {
				sobjectList = paymentTypeToCOPaymentListMap.get(paymentTypeRec.Payment_Method__c);
			}
			
			Cash_Reconciliation_Payment__c reconciledPaymentRec = new Cash_Reconciliation_Payment__c();
			if(paymentTypeToReconciledPaymentMap.containsKey(paymentTypeRec.Payment_Method__c)) {
				reconciledPaymentRec = paymentTypeToReconciledPaymentMap.get(paymentTypeRec.Payment_Method__c);
			}
			
			if(isMultipleDrawerView) {
				if(paymentTypeRec.Type__c == 'Cash/Credit') {
					for(SObject rec : sobjectList) {
						this.CashPaymentObj.ProcessedAmount += (rec.get('Amount__c') != null ? Decimal.valueOf(String.valueOf(rec.get('Amount__c'))) : 0);
					}
					
					this.CashPaymentObj.ActualAmount += (reconciledPaymentRec.Actual_Amount__c != null) ? reconciledPaymentRec.Actual_Amount__c.setScale(2, RoundingMode.HALF_UP) : 0;
				} else if(paymentTypeRec.Type__c == 'Other') {
					for(SObject rec : sobjectList) {
						this.NonCashPaymentObj.ProcessedAmount += (rec.get('Amount__c') != null ? Decimal.valueOf(String.valueOf(rec.get('Amount__c'))) : 0);
					}
				}
			} else {
				if(paymentTypeRec.Type__c == 'Cash/Credit') {
					this.CashReconciliationPaymentList.add(new ReconciliationPayment(sobjectList, paymentTypeRec, reconciledPaymentRec));
				} else if(paymentTypeRec.Type__c == 'Other') {
					this.OtherReconciliationPaymentList.add(new ReconciliationPayment(sobjectList, paymentTypeRec, reconciledPaymentRec));
				}
			}
		}
    }
    
    public class PaymentTypeWrapper {
    	public Decimal ProcessedAmount;
		public Decimal ActualAmount;
		
		public PaymentTypeWrapper() {
			this.ProcessedAmount = 0;
			this.ActualAmount = 0;
		}
    }
    
    
	public class ReconciliationPayment {
		public String Id;
		public String ReconciliationId;
		public String PaymentMethod;
		public String ActualPaymentMethodName;
		public Decimal ProcessedAmount;
		public Decimal ActualAmount;
		public String Icon;
		public List<PaymentInfo> PaymentDetailList;
		
		public ReconciliationPayment(List<sObject> sobjectList, Reconciliation_Payment__mdt paymentTypeRec,
											Cash_Reconciliation_Payment__c reconciledPaymentRec) {
	 		this.Icon = GlobalController.Application_Images + paymentTypeRec.Icon_Link__c;
	 		this.ProcessedAmount = 0;
	 		PaymentDetailList = new List<PaymentInfo>();
	 		for(sObject sobjectRec : sobjectList) {
	 			Id sobjectId = String.valueOf(sobjectRec.get('Id'));
	 			if(sobjectId.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'CO_Invoice_Payment__c') {
	 				CO_Invoice_Payment__c coInvoicePaymentRec = (CO_Invoice_Payment__c)sobjectRec;
 					this.ProcessedAmount += (coInvoicePaymentRec.Amount__c != null ? coInvoicePaymentRec.Amount__c : 0.00);
 					PaymentDetailList.add(new PaymentInfo(coInvoicePaymentRec));
	 			} else if(sobjectId.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'CO_Deposit__c') {
	 				CO_Deposit__c coDepositRec = (CO_Deposit__c)sobjectRec;
	 				this.ProcessedAmount += (coDepositRec.Amount__c != null ? coDepositRec.Amount__c : 0.00);
	 				PaymentDetailList.add(new PaymentInfo(coDepositRec));
	 			}
	 		}
	 		this.PaymentMethod = paymentTypeRec.Label;
	 		this.ActualPaymentMethodName = paymentTypeRec.Payment_Method__c;
	 		this.ActualAmount = (reconciledPaymentRec.Actual_Amount__c != null) ? reconciledPaymentRec.Actual_Amount__c.setScale(2, RoundingMode.HALF_UP) : null;
	 		this.Id = reconciledPaymentRec.Id;
	 		this.ReconciliationId = reconciledPaymentRec.Cash_Reconciliation__c;
		}
	}
	
	
	public class PaymentInfo {
		public String Id;
		public Decimal Amount;
		public String CustomerName;
		public String PaymentNumber;
		public String COHeaderId;
		public String COHeaderName;
		
		public PaymentInfo(CO_Invoice_Payment__c coInvoicePaymentRec) {
			this.Id = coInvoicePaymentRec.Id;
			this.Amount = coInvoicePaymentRec.Amount__c;
			this.PaymentNumber = coInvoicePaymentRec.Name;
			if(coInvoicePaymentRec.CO_Invoice_Header__r.CO_Header__c != null) {
				this.CustomerName = coInvoicePaymentRec.CO_Invoice_Header__r.CO_Header__r.Customer_Name__c;
				this.COHeaderName = coInvoicePaymentRec.CO_Invoice_Header__r.CO_Header__r.Name;
				this.COHeaderId = coInvoicePaymentRec.CO_Invoice_Header__r.CO_Header__c;
			}
		}
		
		public PaymentInfo(CO_Deposit__c coDepositRec) {
			this.Id = coDepositRec.Id;
			this.Amount = coDepositRec.Amount__c;
			this.PaymentNumber = coDepositRec.Name;
			if(coDepositRec.CO_Header__c != null) {
				this.CustomerName = coDepositRec.CO_Header__r.Customer_Name__c;
				this.COHeaderName = coDepositRec.CO_Header__r.Name;
				this.COHeaderId = coDepositRec.CO_Header__c;
			}
		}
		
	}
	
	/**
     * Name: getCashDrawerReconciliationFieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getCashDrawerReconciliationFieldsList(){
        List<String> cashDrawerFields = new List<String>{ 'Name',
        										'Cash_Drawer__c',
        										'Status__c',
        										'Cash_Reconciliation__c',
        										'Cash_Reconciliation__r.Reconciliation_Date__c',
        										'Cash_Reconciliation__r.Status__c',
        										'Cash_Reconciliation__r.Total_Actual__c',
        										'Cash_Reconciliation__r.Commit_Reconciliation_Date__c'
                                       		 };
        return cashDrawerFields;
    }
}
