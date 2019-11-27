public with sharing class COPaymentService {
    
    public static CO_Invoice_Payment__c createCOPaymentRecord(COInvoicePayment coInvoicePaymentObj) {
        CO_Invoice_Payment__c coInvoicePaymentRec = new CO_Invoice_Payment__c();
        coInvoicePaymentRec.Amount__c = coInvoicePaymentObj.Amount;
        coInvoicePaymentRec.Payment_Method__c = coInvoicePaymentObj.PaymentMethod ;
        coInvoicePaymentRec.CO_Invoice_Header__c = coInvoicePaymentObj.COInvoiceHeaderId;
        coInvoicePaymentRec.Is_Reverse__c = (coInvoicePaymentObj.IsReverse != null) ? coInvoicePaymentObj.IsReverse : false;
        coInvoicePaymentRec.Id = coInvoicePaymentObj.COInvoicePaymentId;
        coInvoicePaymentRec.Cash_Drawer__c  = coInvoicePaymentObj.CashDrawerId;
        DateTime dtValue = HomeSearchFilterInterface.getDateFromString(coInvoicePaymentObj.PaymentDate);
    	coInvoicePaymentRec.Payment_Date__c = (coInvoicePaymentObj.PaymentDate != null) ? Date.newInstance(dtValue.year(), dtValue.month(), dtValue.day()) : date.today();
        
        if(coInvoicePaymentObj.ReverseLink != null) {
            coInvoicePaymentRec.Reverse_Link__c = coInvoicePaymentObj.ReverseLink;
            coInvoicePaymentRec.Reverse_Payment_From__c = coInvoicePaymentObj.ReverseLink;
        }
        return coInvoicePaymentRec;
    }
}