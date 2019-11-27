/**
 * Author: Pooja Khandelwal
 * Since: Jun 18, 2018
 * Name: COSalesReceiptCtrl
 * Description: Ctrl Class to Fetch CO Sales Receipt details on PDF Page
**/
global with sharing class COSalesReceiptCtrl {
    public static String Application{get;}
    public static String Assests{get;}
    public static String Application_Images{get;}
    
    public COSalesReceiptCtrl() { 
        Application = GlobalController.GetResourceURL('Application');
        Application_Images = GlobalController.GetResourceURL('Application_Images');
        Assests = GlobalController.GetResourceURL('Assests');
    }
    
    /**
     * Name: getCOInvoiceDetailsWithFinalize
     * Desc: to get CO Sales Receipt details
     * @param:  (1) coInvoiceIdStr (2) isFinalized
     * @return: String - JSON String
    **/
    @RemoteAction
    global static String getCOInvoiceDetailsWithFinalize(String coInvoiceIdStr, Boolean isFinalized) {
    	String coInvoiceDetails;
    	coInvoiceIdStr = BPUtility.getDecodedString(coInvoiceIdStr);
    	Id coInvoiceId = coInvoiceIdStr;
    	List<CO_Invoice_Header__c> coInvoices = PrintCustomerOrderInvoiceCtrl.getCustomerOrderInvoiceHeaders(new List<Id>{coInvoiceId});
    	if(coInvoices.size() > 0) {
    		CO_Invoice_Header__c coInvRec = coInvoices[0];
    		List<Business_Profile__c> businessProfileList = SOQLUtil.getBusinessProfileData(new List<Id>());
    		
    		List<Id> coliIds = new List<Id>();
    		List<Id> cokhIds = new List<Id>();
    		List<Id> sohTaxableItemIds = new List<Id>();
    		List<Id> sohIds = new List<Id>();
    		List<Id> dealIds = new List<Id>();
            for(CO_Invoice_Item__c coInvoiceItem : coInvoices[0].CO_Invoice_Items__r) {
            	if(coInvoiceItem.CO_Line_Item__c != null) {
	                coliIds.add(coInvoiceItem.CO_Line_Item__c);
	            }
	            if(coInvoiceItem.CO_Kit_Header__c != null) {
	                cokhIds.add(coInvoiceItem.CO_Kit_Header__c);
	            }
	            if(coInvoiceItem.Service_Order_Header__c != null) {
	                if(coInvoiceItem.SO_Payment_Role__c == null || coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName != 'Deductible') {
	                    sohTaxableItemIds.add(coInvoiceItem.Service_Order_Header__c);
	                }
	                sohIds.add(coInvoiceItem.Service_Order_Header__c);
	            }
	            if(coInvoiceItem.Deal__c != null) {
	                dealIds.add(coInvoiceItem.Deal__c);
	            }
            }
            
            
    		List<Individual_Tax__c> individualItemsList = [select CO_Line_Item__c, Tax_Rate__c, Form_Label__c, Sales_Tax_Item_Name__c, 
                                                                Taxable_Amount__c, Tax_Amount__c, Taxable_Amount_To_Invoice__c, Tax_Amount_To_Invoice__c, 
                                                                Applicable_Tax__c, List_Tax_items_on_forms__c
                                                                from Individual_Tax__c where CO_Line_Item__c IN : coliIds
                                                                    OR CO_Line_Item__r.CO_Kit_Header__c IN :cokhIds
                                                                    OR Service_Order_Line_Item__r.Service_Order_Header__c IN :sohTaxableItemIds
                                                                    OR Option_Fee__r.Deal__c IN: dealIds
                                                                    OR Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c IN: dealIds
                                                                    OR F_I_Product__r.Deal_Finance__r.Deal__c IN: dealIds
                                                                    OR (Deal_Item__r.Deal__c IN: dealIds AND Deal_Item__r.Type__c = 'Trade In')];
             
			Map<String, Decimal> salesTaxNameToTaxValue = new Map<String, Decimal>();                                                          
			salesTaxNameToTaxValue = TaxCalculation.getTaxAmountWithFormLabel(individualItemsList);    
             
             Id coId = coInvoices[0].CO_Header__c;
             List<CO_Header__c> coHeadersList = PrintCustomerOrderInvoiceCtrl.getCustomerOrderHeaders(new List<Id>{coId}, coliIds);
             List<CO_Kit_Header__c> coKitHeadersList = PrintCustomerOrderInvoiceCtrl.getKitHeaders(new List<Id>{coId}, cokhIds);
             List<COHeaderWrapper.COKitHeader> COKHList = COHeaderWrapper.getCOLineItemsList(coHeadersList[0].CO_Line_Items__r, coKitHeadersList);
             List<Deal_Item__c> dealItemList = PrintCustomerOrderInvoiceCtrl.getDealHeaders(new List<Id>{coId}, dealIds);
             
             Set<Id> dealItemIds = new Set<Id>();
             for(Deal_Item__c dealItemRec : dealItemList) { 
                dealItemIds.add(dealItemRec.Id);
             }
            
             Map<Id, List<Deal_Kit_Header__c>> dealItemIdToDKHListMap = new Map<Id, List<Deal_Kit_Header__c>>();
             List<Deal_Kit_Header__c> dealKitHeaderList = SOQLUtil.getDealKitHeaderDetailsByDealItemId(new Set<Id>(dealItemIds));
             for(Deal_Kit_Header__c dealKitHeaderRec : dealKitHeaderList) {
             	if(dealItemIdToDKHListMap.containsKey(dealKitHeaderRec.Deal_Item__c)) {
                	List<Deal_Kit_Header__c> dealKitHeaders = dealItemIdToDKHListMap.get(dealKitHeaderRec.Deal_Item__c);
                    dealKitHeaders.add(dealKitHeaderRec);
                    dealItemIdToDKHListMap.put(dealKitHeaderRec.Deal_Item__c, dealKitHeaders);
                } else {
                    dealItemIdToDKHListMap.put(dealKitHeaderRec.Deal_Item__c, new List<Deal_Kit_Header__c>{dealKitHeaderRec});
                }
         	}
            
			List<Service_Order_Header__c> soHeadersList = PrintCustomerOrderInvoiceCtrl.getServiceOrderHeaders(new List<Id>{coId}, sohIds);
            Map<String, String> dealObjFieldNameToFieldValueMap = new Map<String, String>();
            List<F_I_Product__c> dealFAndIProductList = new List<F_I_Product__c>();
            if(dealIds.size() > 0) {
            	dealFAndIProductList = SOQLUtil.getDealFAndIProductRecord(new Map<String, String>{'Deal__c' => dealIds[0]});
            }
    		COSalesReceiptDetail coSalesReceiptDetailObj = new COSalesReceiptDetail(businessProfileList, coInvRec, salesTaxNameToTaxValue, COKHList, coHeadersList[0].CO_Line_Items__r, coKitHeadersList, dealItemList, dealItemIdToDKHListMap, soHeadersList, dealFAndIProductList);
    		coInvoiceDetails = System.JSON.serialize(coSalesReceiptDetailObj);
    	}
                
    	return BPUtility.getEncodedString(coInvoiceDetails);
    }
}