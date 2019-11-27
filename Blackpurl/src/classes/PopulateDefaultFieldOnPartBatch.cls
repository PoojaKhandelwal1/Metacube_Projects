/**
 * Author: Richa Mittal
 * Since: Jun 27, 2018
 * Name: PopulateDefaultFieldOnPartBatch
 * Description: Batch for Populating Part Id Text field on Part record
**/
global without sharing class PopulateDefaultFieldOnPartBatch implements Database.Batchable<sobject> {
	
    global Database.QueryLocator start(Database.BatchableContext bc) {
    	BPScriptUtility.disbaleTrigger('PartTrigger');
        String strQuery = 'SELECT Part_Number__c, Vendor_Code__c FROM Part__c';
        return Database.getQueryLocator(strQuery); 
    }
    
    global void execute(Database.batchableContext bc, List<Part__c> partList) {
        for(Part__c partRec : partList) {
        	partRec.Part_Id_Text__c = partRec.Part_Number__c + partRec.Vendor_Code__c;
        }
        if(partList.size() > 0) {
            update partList;
        }
    }
    
    global void finish(Database.batchableContext bc) {
        BPScriptUtility.enableTrigger('PartTrigger');
    }
}