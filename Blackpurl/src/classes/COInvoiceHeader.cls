/**
 * Author: Tarun Khandelwal
 * Since: April 10, 2015
 * Name: COInvoiceHeader
 * Description: Apex class to handle JSON related oprations of CO Invoice Header object.
**/
public with sharing class COInvoiceHeader {
    
    // CO Line Invoice Header Id
    public String COInvoiceHeaderId {get; set;}
    
    // Date when the Invoice is closed
    public String ClosedInvoiceDate {get; set;}
    
    // Invoice Status
    public String InvoiceStatus {get; set;}
    
    // Invoice Number
    public String COInvoiceHeaderNumber {get; set;}
    
    
    public Decimal SubTotal {get; set;}
    public Decimal SalesTax {get; set;}
    public Decimal Total {get; set;}
    
    // Constructor
    public COInvoiceHeader(CO_Invoice_Header__c coInvoiceHeaderRec) { 
        this.COInvoiceHeaderId = coInvoiceHeaderRec.Id;
        if(coInvoiceHeaderRec.Invoice_Date__c != null) {
        	this.ClosedInvoiceDate = (coInvoiceHeaderRec.Invoice_Date__c != null) ? BPUtility.getFormatedDateTime(coInvoiceHeaderRec.Invoice_Date__c) : '';
        } else {
        	this.ClosedInvoiceDate = '';
        }
        this.InvoiceStatus = coInvoiceHeaderRec.Invoice_Status__c;
        this.COInvoiceHeaderNumber = (coInvoiceHeaderRec.Invoice_Number__c == null) ? '' : coInvoiceHeaderRec.Invoice_Number__c;
        
        this.SubTotal = (coInvoiceHeaderRec.Sub_Total__c != null ? coInvoiceHeaderRec.Sub_Total__c : 0);
        this.SalesTax = (coInvoiceHeaderRec.SalesTax_Total__c != null ? coInvoiceHeaderRec.SalesTax_Total__c : 0);
        this.Total = (coInvoiceHeaderRec.Total__c != null ? coInvoiceHeaderRec.Total__c : 0);
        
    }
    
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: COLineItem - Class Object
    **/
    public static COInvoiceHeader parse(String json) {
        return (COInvoiceHeader) System.JSON.deserialize(json, COInvoiceHeader.class);
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> coInvoiceHeaderFields = new List<String>{ 	'Id',
		                                                        'Name', 
		                                                        'CO_Header__c',
		                                                        'Invoice_Date__c',
		                                                        'Invoice_Status__c',
		                                                        'Invoice_Number__c',
		                                                        'Sub_Total__c',
		                                                        'SalesTax_Total__c',
		                                                        'Total__c'
                                               		 	};
        return coInvoiceHeaderFields;
    }
}