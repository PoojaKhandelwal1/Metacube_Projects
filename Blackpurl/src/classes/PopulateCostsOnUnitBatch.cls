/**
 * Author: Richa Mittal
 * Since: Jun 27, 2018
 * Name: PopulateCostsOnUnitBatch
 * Description: Batch for Populating WIP cost on stock unit
**/
global without sharing class PopulateCostsOnUnitBatch implements Database.Batchable<sobject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String strQuery = 'SELECT Id FROM CO_Invoice_Header__c WHERE Invoice_Status__c = \'Closed\' AND Checkout_Type__c = \'Deal\' ORDER BY CreatedDate DESC';
        return Database.getQueryLocator(strQuery); 
    }
    
    global void execute(Database.batchableContext bc, List<CO_Invoice_Header__c> coInvoiceList) {
        Map<Id, Customer_Owned_Unit__c> unitMapToUpdate = new Map<Id, Customer_Owned_Unit__c>();
        for(CO_Invoice_Header__c coInvoiceRec : coInvoiceList) {
        	List<Customer_Owned_Unit__c> unitList = CustomerOrderCtrl.calculateDealOptionsWIPCost(coInvoiceRec.Id);
        	for(Customer_Owned_Unit__c unitRec : unitList) {
        		unitMapToUpdate.put(unitRec.Id, unitRec);
        	}
        }
        if(unitMapToUpdate.size() > 0) {
            update unitMapToUpdate.values();
        }
    }
    
    global void finish(Database.batchableContext bc) {
        
    }
}