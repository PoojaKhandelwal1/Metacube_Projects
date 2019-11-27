/** 
* Author: Yash Sharma
* Since: Oct 23, 2018
* Name: TaxExemptionsBatch
* Description: Batch class to do the data updation for Sprint_75 release.
* Populating TaxExemptions on all existing Open CustomerOrders from their' Customer's AccountType. Similarly for ServiceOrderHeader as well.
**/
global with sharing class TaxExemptionsBatch implements Database.Batchable<sobject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        String baseQuery = 'Select Id, Customer__c, Order_Status__c, (select Id, Provider__c from Service_Order_Headers__r) from CO_Header__c';
        return Database.getQueryLocator(baseQuery); 
    }

    global void execute(Database.batchableContext bc, List<CO_Header__c> coHeaderList) {
        
        // Populate TaxExemptions for COHeader
        COTriggerHelper.populateTaxExemptions(coHeaderList, true);
        
        // Populate TaxExemptions for SOHeader for CO
        List<Service_Order_Header__c> soHeaderList = new List<Service_Order_Header__c>();
        for(CO_Header__c coHeaderRec : coHeaderList) {
            soHeaderList.addAll(coHeaderRec.Service_Order_Headers__r);
        }
        SOTriggerHelper.populateTaxExemptions(soHeaderList);
    }  
    
    global void finish(Database.batchableContext bc) {}
}