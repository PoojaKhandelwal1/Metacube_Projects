/**
 * Author: Tarun Khandelwal
 * Since: Jun 26, 2017
 * Name: PopulateTotalsOnInvoiceBatch
 * Description: Batch for Populating Totals on invoice
**/
global without sharing class PopulateTotalsOnInvoiceBatch implements Database.Batchable<sobject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String strQuery = 'SELECT Name, Total_Payment__c, CO_Header__r.Customer__r.Total_Store_Credit__c, Invoice_Status__c,' + 
                            '(SELECT CO_Line_Item__c, Service_Order_Header__c, CO_Kit_Header__c, Deal__c, SO_Payment_Role__c, ' + 
                            'SO_Payment_Role__r.RecordType.DeveloperName FROM CO_Invoice_Items__r)' + 
                           'FROM CO_Invoice_Header__c WHERE Status__c = \'Closed\' ORDER BY CreatedDate DESC';
        return Database.getQueryLocator(strQuery); 
    }
    
    global void execute(Database.batchableContext bc, List<CO_Invoice_Header__c> coInvoiceList) {
        List<CO_Invoice_Header__c> coInvoiceHeaderListToUpdate = new List<CO_Invoice_Header__c>();
        for(CO_Invoice_Header__c coInvoiceRec : coInvoiceList) {
            coInvoiceHeaderListToUpdate.add(COService.populateFieldsOnInvoice(coInvoiceRec.Id));
        }
        if(coInvoiceHeaderListToUpdate.size() > 0) {
            update coInvoiceHeaderListToUpdate;
        }
    }
    
    global void finish(Database.batchableContext bc) {
        
    }
}