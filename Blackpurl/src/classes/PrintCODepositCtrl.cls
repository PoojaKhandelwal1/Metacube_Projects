/**
* Author: Richa Mittal
* Since: January 12, 2017
* Name: PrintCODepositCtrl
* Description: methods to handle operations related to print CO deposit.
**/
global with sharing class PrintCODepositCtrl {
    
    public String companyLogoURL { get{return GeneralConfiguration.getCompanyLogoUrl();} private set;}
    public PrintCODepositWrapper printCODepositRecord{get; private set;}
    public static String Application{get;}
    public static String Assests{get;}
    public static String Application_Images{get;}
    public String CoHeaderId {get; private set;}
    
    public PrintCODepositCtrl() {
    	Application = GlobalController.GetResourceURL('Application');
    	Application_Images = GlobalController.GetResourceURL('Application_Images');
    	Assests = GlobalController.GetResourceURL('Assests');
        CoHeaderId = ApexPages.currentPage().getParameters().get('id');
    	if(CoHeaderId  == '' || CoHeaderId == 'undefined' || CoHeaderId == null){
            return;
        }else{
        CoHeaderId = BPUtility.getEncodedString(CoHeaderId);
        String coDepositDetailJson = getPrintCODepositData(CoHeaderId);
        coDepositDetailJson = BPUtility.getDecodedString(coDepositDetailJson);
        printCODepositRecord = (PrintCODepositWrapper)JSON.deserialize(coDepositDetailJson, PrintCODepositWrapper.class);
        //system.assert(false,printCODepositRecord);
        
    }
    	
    }
    
    @RemoteAction
    global static String getPrintCODepositData(String coHeaderId) {
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> coHeaderList = [select Name, Customer__c, CreatedDate, Owner__r.Name, Deal_Total__c, (select Id from CO_Invoice_Headers__r) from CO_Header__c where Id=: coHeaderId];
        if(coHeaderList.size() == 0) {
            return '{}';
        }
        
        List<CO_Invoice_Header__c> coInvoiceHeaderIdSet = new   List<CO_Invoice_Header__c>();
        for(CO_Header__c coHeaderRec: coHeaderList) {
        	for(CO_Invoice_Header__c coInvoiceHeaderRec: coHeaderRec.CO_Invoice_Headers__r) {
        		coInvoiceHeaderIdSet.add(coInvoiceHeaderRec);
        	}
        }
        
        List<CO_Invoice_Payment__c> coInvoicePaymentsList = [select Id, Payment_Method__c, Amount__c from CO_Invoice_Payment__c where CO_Invoice_Header__c IN:coInvoiceHeaderIdSet];
        //system.assert(false, coInvoicePaymentsList);
        
        List<CO_Invoice_Payment__c> activeCOInvoicePaymentsList = [select Id, Amount__c, CO_Invoice_Header__r.Invoice_Number__c, Payment_Method__c, CreatedDate from CO_Invoice_Payment__c where CO_Invoice_Header__c IN:coInvoiceHeaderIdSet and CO_Invoice_Header__r.Status__c = 'Active'];
        //system.assert(false, activeCOInvoicePaymentsList);
        
        List<Account> customerList = new List<Account>();
        List<Service_Order_Header__c> soHeaderList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'CO_Header__c' => coHeaderId,
        																										'Deal__c' => null});
        List<CO_Line_Item__c> coLineItemsListFOrMerch = getCustomerOrderLineItems(coHeaderId);
        List<CO_Line_Item__c> coLineItemsListFOrMerchExcludingDealMerch = new List<CO_Line_Item__c>();
        for(CO_Line_Item__c coliRec: coLineItemsListFOrMerch) {
        	if(String.isBlank(coliRec.Deal__c)) {
        		coLineItemsListFOrMerchExcludingDealMerch.add(coliRec);
        	}
        }
        
        List<Business_Profile__c> businessProfileList = SOQLUtil.getBusinessProfileData(new List<id>());
        if(coHeaderList[0].Customer__c != null) { // Issue: Customer Info is not displaying on printCODeposit page: soHeaderList.size() > 0 && : Removed By Pooja 1 May 2017
            customerList = SOQLUtil.getCustomerDetailsByFieldName(new Map<String, String>{'Id' => coHeaderList[0].Customer__c});
        } 
        
        List<CO_Deposit__c> coDepositList = SOQLUtil.getCODepositByCOHeaderId(coHeaderId);
        
        List<Deal__c> dealList = [SELECT Id FROM Deal__c WHERE CO_Header__c =: coHeaderId];
        List<Deal_Item__c> dealItemList = new List<Deal_Item__c>();
        List<Deal_Finance__c> dealFinanceList = new List<Deal_Finance__c>();
        if(dealList.size() > 0) {
        	dealItemList = PrintCustomerOrderInvoiceCtrl.getDealHeaders(new List<Id>{coHeaderId}, new List<Id>{dealList[0].Id});
        	dealFinanceList = SOQLUtil.getDealFinanceRecord(new Map<String, String>{'Deal__c' => dealList[0].Id});
        }
        //system.assert(false, dealFinanceList);
        List<CO_Kit_Header__c> coKitHeadersList = getCOKitHeadersByCOHeaderId(coHeaderId); //SOQLUtil.getCOKHByCOHeaderId(coHeaderId);
        List<CO_Kit_Header__c> coKitHeadersListExcludingDealMerch = new List<CO_Kit_Header__c>();
        for(CO_Kit_Header__c cokhRec: coKitHeadersList) {
        	if(String.isBlank(cokhRec.Deal__c)) {
        		coKitHeadersListExcludingDealMerch.add(cokhRec);
        	}
        }
        //System.assert(false, coKitHeadersList);
        List<COHeaderWrapper.COKitHeader> COKHList = COHeaderWrapper.getCOLineItemsList(coLineItemsListFOrMerchExcludingDealMerch, coKitHeadersListExcludingDealMerch);
        //system.assert(false, COKHList);
        
        List<Individual_Tax__c> individualItemsList = [select CO_Line_Item__c, Tax_Rate__c, Form_Label__c, Sales_Tax_Item_Name__c, 
        														Taxable_Amount__c, Tax_Amount__c,
        														Applicable_Tax__c, List_Tax_items_on_forms__c
	    															from Individual_Tax__c where CO_Line_Item__c IN : coLineItemsListFOrMerchExcludingDealMerch
	    																OR CO_Line_Item__r.CO_Kit_Header__c IN :coKitHeadersListExcludingDealMerch
																		OR Service_Order_Line_Item__r.Service_Order_Header__c IN :soHeaderList
																		OR Option_Fee__r.Deal__c IN: dealList
																		OR Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c IN: dealList 
																		OR F_I_Product__r.Deal_Finance__r.Deal__c IN: dealList
																		OR (Deal_Item__r.Deal__c IN: dealList AND Deal_Item__r.Type__c = 'Trade In')];
	    
	    Map<String, Decimal> salesTaxNameToTaxValue = new Map<String, Decimal>();  
	    salesTaxNameToTaxValue = TaxCalculation.getTaxAmountWithFormLabel(individualItemsList);	
        
        PrintCODepositWrapper printCODepositWrapper = new PrintCODepositWrapper(coHeaderId, coLineItemsListFOrMerchExcludingDealMerch, soHeaderList, 
        																coDepositList, businessProfileList, customerList, coHeaderList[0], 
        																coInvoicePaymentsList, activeCOInvoicePaymentsList, COKHList, dealItemList, dealFinanceList,
        																salesTaxNameToTaxValue); 
        
        		
	    //system.assert(false, printCODepositWrapper.dealInfo);
        return BPUtility.getEncodedString(JSON.serialize(printCODepositWrapper)); 
    }
    
    private static List<CO_Line_Item__c> getCustomerOrderLineItems(Id coHeaderId) {
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : COLineItem.fieldsList()){
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        
        // Child Query
        query += '(SELECT Sales_Tax_Item_Name__c, Tax_Rate__c FROM Individual_Taxes__r)';
        
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Line_Item__c ';
        if(coHeaderId != null) {
            query += 'WHERE CO_Header__c = :coHeaderId AND Service_Order_Line_Item__c = null ORDER BY CreatedDate';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Line_Item__c> coLineItems = Database.query(query);
        return coLineItems;
    }
    
    /**
     * Name: getCOKHByCOHeaderId
     * Desc: To get Customer Order Kit Header by Header Id
     * @param: (1) coHeaderId - Id - Customer Order Header Id 
     * @return: List<Sobject> - Customer Order Kit Header records
    **/ 
    public static List<Sobject> getCOKitHeadersByCOHeaderId(Id coHeaderId) { 
        String query;    
        query = 'SELECT ';  
        for(String fieldsName : COHeaderWrapper.getCOKHFieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
         
        // Child Query
        query += '(SELECT ';
        for(String fieldsName : COLineItem.fieldsList()){
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Line_Items__r )';
        
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Kit_Header__c ';
        if(coHeaderId != null) {
            query += 'WHERE CO_Header__c = :coHeaderId ORDER BY CreatedDate';
        }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Kit_Header__c> coKitHeaders = Database.query(query);
        return coKitHeaders;
    }
}