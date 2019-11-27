public with sharing class Customer_Service {
	
    public static String addCustomerToCO(String coId, String customerId) {
    	try{
    		coId = String.isBlank(coId) ? BPUtility.getDecodedString(BPGlobalHeaderCtrl.createCustomerOrder()) : coId;
            coId = BPUtility.escapeSingleQuotes(coId);
            
            if(isPaymentAddedByCustomer(coId)) {
                throw new BlackPurlException(BlackPurlException.getErrorMessage(Label.Changing_Customer_With_Payment_Error_Message, null));
            }
            CO_Header__c coHeaderRec = new CO_Header__c(Id = coId, Customer__c = customerId, Selling_Group__c = Constants.PART_SALE);
            updateCOWithCustomer(new List<CO_Header__c>{coHeaderRec}, customerId);
            return COService.getCOHeaderDetailsByGridName(coId, 'Customer Info');
    	}catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    private static void updateCOWithCustomer(List<CO_Header__c> coHeaderRecList, String customerId) {
        if(coHeaderRecList.size() == 0 ) {
            return;
        }
        CO_Header__c coHeaderRec = coHeaderRecList[0];
    	if(String.isBlank(customerId)) {
            coHeaderRec.CO_Type__c = Constants.CASH_SALE;
            coHeaderRec.Selling_Group__c = Constants.CASH_SALE;
        } else {
        	if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        	if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<CO_Header__c> coHeaderList =[Select Id, CO_Type__c, Customer__c, (Select Id from CO_Invoice_Headers__r where Invoice_Status__c = 'Closed'), (Select Id, Work_Status__c, Customer_Owned_Unit__c from Service_Order_Headers__r) from CO_Header__c where Id = :coHeaderRec.Id];
            
            if(coHeaderList.size() > 0  && coHeaderList[0].CO_Type__c == Constants.INTERNAL_SERVICE){
                throw new BlackPurlException(BlackPurlException.getErrorMessage(Label.Customer_On_Internal_Service_CO, null));
            } else if(coHeaderList.size() > 0 && coHeaderList[0].CO_Invoice_Headers__r.size() > 0) {
                throw new BlackPurlException(BlackPurlException.getErrorMessage(Label.Changing_Customer_After_Invoicing_Error_Message, null));
            }
            
            if(coHeaderList.size() > 0  && coHeaderList[0].CO_Type__c == Constants.CASH_SALE){
                coHeaderRec.Selling_Group__c = Constants.PART_SALE;
            }
            if(coHeaderList.size() > 0  && ((String.isNotBlank(coHeaderList[0].Customer__c)) && 
            				(coHeaderList[0].Customer__c != customerId)) && coHeaderList[0].Service_Order_Headers__r.size() > 0) {
            	for(Service_Order_Header__c soHeaderRec : coHeaderList[0].Service_Order_Headers__r) {
            		if(String.isNotBlank(soHeaderRec.Work_Status__c) && soHeaderRec.Work_Status__c == Constants.SERVICE_ORDER_STATUS_TO_CHECKOUT) {
            			throw new BlackPurlException(BlackPurlException.getErrorMessage(Label.Cannot_Change_Customer_With_Service_Job_Completed_Error_Message, null));
            		}
            		soHeaderRec.Customer_Owned_Unit__c = null;
            	}
            	update coHeaderList[0].Service_Order_Headers__r;
            }
            coHeaderRec.CO_Type__c = Constants.CHECKOUT_TYPE_CUSTOMER;
        }
        updateCOPricingAndTax(new List<CO_Header__c> {coHeaderRec}, customerId, true);
    }
    
    private static Boolean isPaymentAddedByCustomer(String coId) {
    	if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Header__c> coInvoiceHeaderList = [select Id, (select Id, Amount__c from CO_Invoice_Payments__r)
                                                                    from CO_Invoice_Header__c 
                                                                    where Invoice_Status__c = 'Active' AND CO_Header__c =:coId];
        Decimal totalPayment = 0;
        if(coInvoiceHeaderList.size() > 0) {
        	for(CO_Invoice_Payment__c payment: coInvoiceHeaderList[0].CO_Invoice_Payments__r) {
            	totalPayment += (payment.Amount__c != null ? payment.Amount__c : 0);
            }
        }
        
        if(coInvoiceHeaderList.size() > 0 && totalPayment != 0) {
        	return true;
        }
        return false;
    }
    
    private static void updateCOPricingAndTax(List<CO_Header__c> COHeaderRecList, String customerId, Boolean isCalculatePLandTax){ 
            
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        try{
        	CO_Header__c COHeaderRec;
        	if(COHeaderRecList.size() > 0){
        		COHeaderRec = COHeaderRecList[0];
        	}
        	COTriggerHelper.isCalculatePLandTax = isCalculatePLandTax; 
            update COHeaderRec;

            COLineItemTriggerHelper.isTotalCalculated = false;
            //COKH_Recalcualtion.AddCustomerCoForKititemUpdate(customerId, COHeaderRec.Id);
            COKH_Recalcualtion.changePriceWhenCustomerIsChanged(COHeaderRec.Id);
            //SO_KLI_Recalculation.SOPriceCalcultaionByPriceLevel(customerId, COHeaderRec.Id);
            SO_KLI_Recalculation.changePriceWhenCustomerIsChanged(new Set<Id>(), COHeaderRec.Id);
            DealKH_Recalculation.changePriceWhenCustomerIsChanged(customerId, COHeaderRec.Id);
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
}