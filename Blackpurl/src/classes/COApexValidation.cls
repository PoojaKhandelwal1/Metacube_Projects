/** 
* Author: Tarun Khandelwal
* Since: March 13, 2019 
* Name: COApexValidation 
* Description: Apex class for CO page validation 
**/
public without sharing class COApexValidation {
    
    // This method also used for deposit date validate
    public static ResponseWrapper validatePaymentDate(String selectedPaymentDate) {
    	String errorMessage = '';
    	DateTime dtValue = HomeSearchFilterInterface.getDateFromString(selectedPaymentDate);
    	if(dtValue != null) {
            Date paymentDate = Date.newInstance(dtValue.year(), dtValue.month(), dtValue.day());
	    	if(isCashReconciliationDoneForTheDate(paymentDate)) {
	    		errorMessage = 'Cannot select a date which has already been reconciled.';
	    	}
    	}
		return ((String.isNotBlank(errorMessage)) ? new ResponseWrapper(400, errorMessage) : new ResponseWrapper(200, 'success'));
	}
	 
	private static Boolean isCashReconciliationDoneForTheDate(Date paymentDate) {
	    if(AccessControl.ifObjectFieldIsAccessible('Cash_Reconciliation__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
 		List<Cash_Reconciliation__c> cashReconciliationList = 
 		     [SELECT Id FROM Cash_Reconciliation__c WHERE Reconciliation_Date__c =: paymentDate AND Status__c = 'Reconciled' LIMIT 1];
 		return (cashReconciliationList.size() > 0);
	}
    
    public static ResponseWrapper validateInvoiceDate(String invoiceDateValidateJSONString) {
        invoiceDateValidateWrapper wrapperObj = 
            (invoiceDateValidateWrapper) system.JSON.deserialize(invoiceDateValidateJSONString, invoiceDateValidateWrapper.class);
        
        String errorMessage = '';
        DateTime dtValue = HomeSearchFilterInterface.getDateFromString(wrapperObj.SelectedInvoiceDate);
        
        if(dtValue != null) {
            Date invoiceDate = Date.newInstance(dtValue.year(), dtValue.month(), dtValue.day());
            if(isPaymentDateGreaterThanInvoiceDate(invoiceDate, wrapperObj.InvoiceId)) {
                errorMessage = 'Cannot select a date that is prior to the payment dates for this checkout.';
            } else {
                Set<Id> invoicableItemIdSet = getCoInvoiceItemList(wrapperObj.SelectInvoiceItemList);    
	            if(isSpecialOrderReceivedAfterInvoiceDate(invoiceDate, wrapperObj.COHeaderId, invoicableItemIdSet)) {
	                errorMessage = 'Cannot select a date that is prior to the date when special ordered items were received.';
	            } else if(isUnitStockedInDateAfterInvoiceDate(invoiceDate, wrapperObj.InvoiceId, wrapperObj.COHeaderId, invoicableItemIdSet)) {
	                errorMessage = 'Cannot select a date that is prior to the date when the units were received into inventory.';
	            } else if(isDealMerchOrDealServiceInvoicedAfterInvoiceDate(invoiceDate, wrapperObj.COHeaderId, invoicableItemIdSet)) {
	                errorMessage = 'Cannot select a date that is prior to when the deal options were fulfilled.';
	            } else if(isTradeStockedInDateAfterInvoiceDate(invoiceDate, wrapperObj.InvoiceId, wrapperObj.COHeaderId, invoicableItemIdSet)) {
	                errorMessage = 'Cannot select a date that is prior to when the trade-in was stocked in.';
	            }
            }
        }
        return ((String.isNotBlank(errorMessage)) ? new ResponseWrapper(400, errorMessage) : new ResponseWrapper(200, 'success'));
    }
    
    private static Set<Id> getCoInvoiceItemList(List<String> selectInvoiceItemList) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Item__c> coInvoiceItemList = [SELECT CO_Line_Item__c, CO_Kit_Header__c, Service_Order_Header__c, Deal__c 
                                                    FROM CO_Invoice_Item__c WHERE Id IN: selectInvoiceItemList];
        Set<Id> invoicableItemIdSet = new Set<Id>();
        for(CO_Invoice_Item__c invoiceItemRec : coInvoiceItemList) {
            invoicableItemIdSet.add(invoiceItemRec.CO_Line_Item__c);
            invoicableItemIdSet.add(invoiceItemRec.CO_Kit_Header__c);
            invoicableItemIdSet.add(invoiceItemRec.Service_Order_Header__c);
            invoicableItemIdSet.add(invoiceItemRec.Deal__c);
        }
        invoicableItemIdSet.remove(null);
        return invoicableItemIdSet;
    }
    
    private static Boolean isPaymentDateGreaterThanInvoiceDate(Date invoiceDate, String invoiceId) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Payment__c> coInvoicePaymentList = 
            [SELECT Id from CO_Invoice_Payment__c WHERE Payment_Date__c >: invoiceDate AND CO_Invoice_Header__c =: invoiceId 
                AND Reverse_Payment_From__c = null AND Payment_Method__c != 'Charge Account' LIMIT 1];
        return (coInvoicePaymentList.size() > 0);
    }
    
    private static Boolean isSpecialOrderReceivedAfterInvoiceDate(Date invoiceDate, String coHeaderId, Set<Id> invoicableItemIdSet) {
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item__c> specialOrderList = 
            [SELECT Id from Vendor_Order_Line_Item__c WHERE CO_Header__c =: coHeaderId AND 
                    Vendor_Receiving_Group__r.Vendor_Receiving_Header__r.Finalized_Date__c >: invoiceDate AND
                    (CO_Line_Item__c IN: invoicableItemIdSet OR Service_Order_Line_Item__r.Service_Order_Header__c IN: invoicableItemIdSet)
                    LIMIT 1];
        return (specialOrderList.size() > 0);
    }
    
    private static Boolean isUnitStockedInDateAfterInvoiceDate(Date invoiceDate, String invoiceId, String coHeaderId, Set<Id> invoicableItemIdSet) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Item__c> invoiceItemList = [SELECT Id FROM CO_Invoice_Item__c WHERE CO_Invoice_Header__c =: invoiceId AND 
                 Deal__c IN: invoicableItemIdSet AND Deal__c IN
                (SELECT Deal__c FROM Deal_Item__c WHERE Customer_Owned_Unit__r.Date_Stocked_In__c >: invoiceDate 
                            AND Deal__r.CO_Header__c =: coHeaderId) LIMIT 1];
        return (invoiceItemList.size() > 0);
    }
    
    private static Boolean isDealMerchOrDealServiceInvoicedAfterInvoiceDate(Date invoiceDate, String coHeaderId, Set<Id> invoicableItemIdSet) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<CO_Line_Item__c> dealMerchList = [SELECT Invoice_Number__c FROM CO_Line_Item__c WHERE Deal__c != null AND 
                                                    Deal__c IN: invoicableItemIdSet AND CO_Header__c =: coHeaderId];
        List<Service_Order_Header__c> dealServiceList = [SELECT Invoice_Number__c FROM Service_Order_Header__c WHERE Deal__c != null AND 
                                                     Deal__c IN: invoicableItemIdSet AND CO_Header__c =: coHeaderId];
        
        Set<Id> dealMerchOrDealServiceInvoiceIdSet = new Set<Id>();
        for(CO_Line_Item__c coLineItemRec : dealMerchList) {
            dealMerchOrDealServiceInvoiceIdSet.add(coLineItemRec.Invoice_Number__c);
        }
        for(Service_Order_Header__c soHeaderRec : dealServiceList) {
            dealMerchOrDealServiceInvoiceIdSet.add(soHeaderRec.Invoice_Number__c);
        }
        dealMerchOrDealServiceInvoiceIdSet.remove(null);
        List<CO_Invoice_Header__c> invoiceHeaderList = 
            [SELECT Id FROM CO_Invoice_Header__c WHERE Id IN: dealMerchOrDealServiceInvoiceIdSet AND Invoice_Date_Formula__c >: invoiceDate LIMIT 1];
        return (invoiceHeaderList.size() > 0);
    }
    
    private static Boolean isTradeStockedInDateAfterInvoiceDate(Date invoiceDate, String invoiceId, String coHeaderId, Set<Id> invoicableItemIdSet) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Item__c> invoiceItemList = [SELECT Id FROM CO_Invoice_Item__c WHERE CO_Invoice_Header__c =: invoiceId AND 
                    Deal__c IN: invoicableItemIdSet AND Deal__c IN
                    (SELECT Deal__c FROM Deal_Item__c WHERE Is_Stocked_In__c = true AND Stocked_In_Unit__r.Date_Stocked_In__c >: invoiceDate
                        AND Deal__r.CO_Header__c =: coHeaderId ) limit 1];
        return (invoiceItemList.size() > 0);
    }
    
    private class invoiceDateValidateWrapper {
        private String InvoiceId;
        private String COHeaderId;
        private String SelectedInvoiceDate;
        private List<String> SelectInvoiceItemList;
    }
}