/**
 * Author: Tarun Khandelwal
 * Since: May 8, 2015
 * Name: InvoiceHistory
 * Description: Apex class to handle JSON related oprations of Invoice History.
**/
public with sharing class InvoiceHistory {
	
	// Invoice Header Number
	public String InvoiceNumber {get; set;}
	
	// Closed Invoice Date
	public String ClosedInvoiceDate {get; set;}
	
	// Number Of CO Invoice Items
	public Decimal NumberOfItems {get; set;}
	
	// SubTotal (Without Tax)
	public Decimal SubTotal {get; set;}
	
	// Tax Included
	public Decimal Tax {get; set;}
	
	// Total
	public Decimal Total {get; set;}
	
	// Invoice id
	public String COInvoiceHeaderId {get; set;}
	
	public String CheckoutType;
	
	// List of CO Invoice History Record
    public List<COInvoicePayment> COInvoiceHeaderPaymentRecs {get; set;}
	
	// Constructor
    public InvoiceHistory(CO_Invoice_Header__c  coInvoiceHeaderRec) {
    	this.InvoiceNumber = coInvoiceHeaderRec !=null ? coInvoiceHeaderRec.Invoice_Number__c : '';	
    	this.ClosedInvoiceDate = String.valueOf(Date.valueOf(coInvoiceHeaderRec.Invoice_Date__c).format());
    	this.ClosedInvoiceDate = (coInvoiceHeaderRec.Invoice_Date__c != null) ? BPUtility.getFormatedDateTime(coInvoiceHeaderRec.Invoice_Date__c) : '';
    	this.COInvoiceHeaderPaymentRecs =  new List<COInvoicePayment>();
    	
    	Decimal noOfItems = 0;
    	Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
     	
     	for(CO_Invoice_Payment__c coInvoicePaymentRec : coInvoiceHeaderRec.CO_Invoice_Payments__r) {
    		COInvoiceHeaderPaymentRecs.add(new COInvoicePayment(coInvoicePaymentRec));
     	}
     	this.NumberOfItems = coInvoiceHeaderRec.CO_Invoice_Items__r.size();
 		this.SubTotal = (coInvoiceHeaderRec.Sub_Total__c != null ? coInvoiceHeaderRec.Sub_Total__c.setScale(2, RoundingMode.HALF_UP) : 0);
 		this.Tax = (coInvoiceHeaderRec.SalesTax_Total__c != null ? coInvoiceHeaderRec.SalesTax_Total__c.setScale(2, RoundingMode.HALF_UP) : 0);
 		this.Total = (coInvoiceHeaderRec.Total__c != null ? coInvoiceHeaderRec.Total__c.setScale(2, RoundingMode.HALF_UP) : 0);
     	
    	/*if(!isTaxIncludingPricing) {
	    	this.SubTotal = totalPrice;
	    	this.Tax = totalTax;
	    	this.Total = totalPrice + totalTax;
    	} else {
    		this.Total = this.SubTotal = totalPrice + totalTax;
    		this.Tax = totalTax;
    	}*/
    	
    	this.COInvoiceHeaderId = coInvoiceHeaderRec.Id;
    	this.CheckoutType = coInvoiceHeaderRec.Checkout_Type__c;
    	
     	// Calculation on CO Invoice Items
     	/*for(CO_Invoice_Item__c coInvoiceItemRec : coInvoiceHeaderRec.CO_Invoice_Items__r) {
    		noOfItems += 1;
    		if(coInvoiceItemRec.Deal__c != null) {
    			if(coInvoiceItemRec.Deal_Finance__c != null) {
    				totalPrice += ((coInvoiceItemRec.Deal__r.Total__c != null ? coInvoiceItemRec.Deal__r.Total__c : 0) + (coInvoiceItemRec.Deal_Finance__r.F_I_Total__c != null ? coInvoiceItemRec.Deal_Finance__r.F_I_Total__c : 0)
	            					 - (coInvoiceItemRec.Deal_Finance__r.Down_Payment__c != null ? coInvoiceItemRec.Deal_Finance__r.Down_Payment__c : 0)).setScale(2, RoundingMode.HALF_UP);
    				totalTax += ((coInvoiceItemRec.Deal__r.Deal_Tax_Total__c != null ? coInvoiceItemRec.Deal__r.Deal_Tax_Total__c : 0) + (coInvoiceItemRec.Deal_Finance__r.F_I_Product_Tax_Total__c != null ? coInvoiceItemRec.Deal_Finance__r.F_I_Product_Tax_Total__c : 0)).setScale(2, RoundingMode.HALF_UP);
    			} else {
					totalPrice += ((coInvoiceItemRec.Deal__r.Total__c != null ? coInvoiceItemRec.Deal__r.Total__c : 0) - (coInvoiceItemRec.Deal__r.Total_Deposit_And_Payment__c != null ? coInvoiceItemRec.Deal__r.Total_Deposit_And_Payment__c : 0)).setScale(2, RoundingMode.HALF_UP);
	            	totalTax += (coInvoiceItemRec.Deal__r.Deal_Tax_Total__c != null ? coInvoiceItemRec.Deal__r.Deal_Tax_Total__c : 0).setScale(2, RoundingMode.HALF_UP);
    			}    			
    		} else if(coInvoiceItemRec.CO_Line_Item__c != null) {
    			if(coInvoiceItemRec.CO_Line_Item__r.Tax__c == null) {
    				coInvoiceItemRec.CO_Line_Item__r.Tax__c = 0;
    			}
	    		totalPrice += coInvoiceItemRec.CO_Line_Item__r.Qty__c * coInvoiceItemRec.CO_Line_Item__r.Price__c;
	    		if(coInvoiceItemRec.CO_Line_Item__r.Deal__c != null ){
	    			totalTax = 0;
	    		}else{
	    			totalTax += coInvoiceItemRec.CO_Line_Item__r.Qty__c * coInvoiceItemRec.CO_Line_Item__r.Price__c * (coInvoiceItemRec.CO_Line_Item__r.Tax__c / 100);
	    		}
	    		
    		
    		} else if(coInvoiceItemRec.Service_Order_Header__c != null) {
    			if(coInvoiceItemRec.Service_Order_Header__r.Transaction_Type__c != null && coInvoiceItemRec.Service_Order_Header__r.Transaction_Type__r.Type__c == 'Third-Party') {
					totalPrice += (coInvoiceItemRec.SO_Payment_Role__r.Total_Amount__c != null) ? coInvoiceItemRec.SO_Payment_Role__r.Total_Amount__c : 0;
					totalTax += (coInvoiceItemRec.SO_Payment_Role__r.Tax_Amount__c != null) ? coInvoiceItemRec.SO_Payment_Role__r.Tax_Amount__c : 0;
    			} else {
    				totalPrice += (coInvoiceItemRec.Service_Order_Header__r.Total__c != null) ? coInvoiceItemRec.Service_Order_Header__r.Total__c : 0;
    				if(coInvoiceItemRec.Service_Order_Header__r.Transaction_Type__r.Type__c =='Deal'){
    					totalTax  = 0;
    				}else{ 
    					totalTax += (coInvoiceItemRec.Service_Order_Header__r.Tax_Amount__c != null) ? coInvoiceItemRec.Service_Order_Header__r.Tax_Amount__c : 0;
    				}
    				
    			}
    		} else if(coInvoiceItemRec.CO_Kit_Header__c != null) {
    			if(coInvoiceItemRec.CO_Kit_Header__r.Price__c != null){
	    			totalPrice += coInvoiceItemRec.CO_Kit_Header__r.Price__c;
    			}
	    		if(coInvoiceItemRec.CO_Kit_Header__r.Tax_Amount__c != null){
	    			totalTax += coInvoiceItemRec.CO_Kit_Header__r.Tax_Amount__c;
	    		}	    		
    		}
    	} */
    	
    } 
    
    /**
     * Name: coInvoiceHeaderFieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> coInvoiceHeaderFieldsList(){
        List<String> COInvoiceHeaderFields = new List<String>{ 'Id',
                                                        	'Name', 
                                                        	'CO_Header__c',
                                                        	'Invoice_Date__c',
                                                        	'Invoice_Status__c',
                                                        	'Checkout_Type__c',
                                                        	'Invoice_Number__c',
                                                        	'Sub_Total__c',
                                                        	'Total__c',
                                                        	'SalesTax_Total__c'
                                               			 };
        return COInvoiceHeaderFields;
    }
    
    /**
     * Name: coInvoiceItemsFieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> coInvoiceItemsFieldsList(){
        List<String> COInvoiceHeaderFields = new List<String>{ 'Id',
                                                        	'Name', 
                                                        	'CO_Line_Item__r.Tax__c',
                                                        	'CO_Line_Item__r.Price__c',
                                                        	'CO_Line_Item__r.Qty__c',
                                                        	'CO_Line_Item__r.Deal__c',
                                                        	'Service_Order_Header__c',
                                                        	'Service_Order_Header__r.Total__c',
                                                        	'Service_Order_Header__r.Tax_Amount__c',
                                                        	'CO_Kit_Header__c',
                                                        	'CO_Kit_Header__r.Price__c',
                                                        	'CO_Kit_Header__r.Tax_Amount__c',
                                                        	'SO_Payment_Role__r.Total_Amount__c',
                                                        	'SO_Payment_Role__r.Tax_Amount__c',
                                                        	'Service_Order_Header__r.Transaction_Type__r.Type__c',
                                                        	'Service_Order_Header__r.Transaction_Type__c',
                                                        	'Deal__c',
                                                        	'Deal__r.Total__c',
                                                        	'Deal_Finance__c',
                                                        	'Deal_Finance__r.F_I_Total__c',
                                                        	'Deal_Finance__r.Down_Payment__c',
                                                        	'Deal__r.Total_Deposit_And_Payment__c',
                                                        	'Deal_Finance__r.F_I_Product_Tax_Total__c',
                                                        	'Deal__r.Deal_Tax_Total__c'
                                               			 };
        return COInvoiceHeaderFields;
    }
}