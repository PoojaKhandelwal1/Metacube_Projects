/*
    Apex batch class to update part records 
*/
global with sharing class CalculatePartRetailPrice_Batch implements Database.Batchable<sobject>, Database.Stateful {

    public String baseQuery;
    public Set<Id> setVendorIds;
    private List<Kit_Header_Line_Item__c> kitLineItemsToUpdate;
    
    global CalculatePartRetailPrice_Batch(){
       
    }
    global CalculatePartRetailPrice_Batch(Set<Id> setVendorIdsVal, Integer batchSize){
        CalculatePartRetailPrice_Batch clsPartBatch = new CalculatePartRetailPrice_Batch();
        clsPartBatch.setVendorIds = setVendorIdsVal;
        Id batchstart = Database.executeBatch(clsPartBatch, batchSize);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        baseQuery = 'SELECT '; 
        for(String fieldName : PartDetail.fieldsList()){
            fieldName = BPUtility.escapeSingleQuotes(fieldName); 
            baseQuery += fieldName + ', ';
        }
        baseQuery += ' (SELECT Retail_Price__c FROM Kit_Header_Line_Items__r)';
        baseQuery += ' FROM Part__c WHERE Vendor__c IN :setVendorIds';
        return Database.getQueryLocator(baseQuery); 
    } 

    global void execute(Database.batchableContext bc, List<Part__c> partList) {
    	kitLineItemsToUpdate = new List<Kit_Header_Line_Item__c>();
        for(Part__c partRec : partList){
        	for(Kit_Header_Line_Item__c kitLineItemRec : partRec.Kit_Header_Line_Items__r) {
    			kitLineItemsToUpdate.add(kitLineItemRec);
    		}
            ViewPartCtrl.calculatePartRetailPrice(partRec);
        }
        if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        update partList;
        if(AccessControl.ifObjectFieldIsUpdateable('Kit_Header_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        update kitLineItemsToUpdate;
    } 
 
    global void finish(Database.batchableContext bc){
    }
}