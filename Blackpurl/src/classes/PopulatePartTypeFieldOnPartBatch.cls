/**
 * Author: Richa Mittal
 * Since: Aug 27, 2018
 * Name: PopulatePartTypeFieldOnPartBatch
 * Description: Batch for Populating fields on part and vendor
**/
global with sharing class PopulatePartTypeFieldOnPartBatch implements Database.Batchable<sobject> {
	global Database.QueryLocator start(Database.BatchableContext bc) {
		BPScriptUtility.disbaleTrigger('PartTrigger');
		BPScriptUtility.disbaleTrigger('CustomerTrigger');
        String strQuery = 'SELECT Id, Part_Type__c, Vendor__c FROM Part__c WHERE Part_Type__c = null OR (Vendor__c != null AND Vendor__r.Part_Purchases__c = false)';
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.batchableContext bc, List<Part__c> partList) {
		List<Part__c> partListToUpdate = new List<Part__c>();
        List<Account> vendorListToUpdate = new List<Account>();
        
        Set<Id> vendorIdSet = new Set<Id>();
        for(Part__c partRec : partList) {
        	if(String.isBlank(partRec.Part_Type__c)) {
        		Part__c partToUpdate = new Part__c(Id = partRec.Id, Part_Type__c = 'Part');
        		partListToUpdate.add(partToUpdate);
        	}
        	if(String.isNotBlank(partRec.Vendor__c)) {
        		vendorIdSet.add(partRec.Vendor__c);
        	}
        }
        for(Id vendorId: vendorIdSet) {
			Account acc = new Account(Id = vendorId, Part_Purchases__c = true);
			vendorListToUpdate.add(acc);
		}
		if(partListToUpdate.size() > 0) {
            update partListToUpdate;
        }
        if(vendorListToUpdate.size() > 0) {
            update vendorListToUpdate;
        }
    }
    
    global void finish(Database.batchableContext bc) {
        BPScriptUtility.enableTrigger('PartTrigger');
		BPScriptUtility.enableTrigger('CustomerTrigger');
    }
}