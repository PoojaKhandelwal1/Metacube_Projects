/**
 * Author: Nidhi Sharma
 * Since: Sept 12, 2018
 * Name: SetQtyAndAvgCostOnFIFOBktAndLIBatch
 * Description: Batch for Populating fields on part and vendor
**/
global without sharing class SetQtyAndAvgCostOnFIFOBktAndLIBatch implements Database.Batchable<sobject> {
	
	private Set<String> recordIds;
	global Boolean isTriggerDisabled = false;
	global SetQtyAndAvgCostOnFIFOBktAndLIBatch() {}
	global SetQtyAndAvgCostOnFIFOBktAndLIBatch(Set<String> recordIdSet) {
	    recordIds = recordIdSet;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		/*List<Trigger_Soft_Disable__c> custSettingList = Trigger_Soft_Disable__c.getAll().values();
        for(Trigger_Soft_Disable__c custSettingRec : custSettingList){
            if(custSettingRec.Name == 'PartTrigger'){
                isTriggerDisabled = true;
            }
        }
        if(!isTriggerDisabled) {
            BPScriptUtility.disbaleTrigger('PartTrigger');
        }*/
        String partStrQuery = 'SELECT Id, (Select Id, CreatedDate, Cost__c, Qty_In__c, Qty_In_Stock_When_Created__c, Average_Cost_When_Created__c ' +
        	'FROM Part_FIFO_Buckets__r WHERE Is_FIFO_Bucket__c = true Order By CreatedDate ASC) FROM Part__c';
        if(recordIds != null && recordIds.size() > 0) {
            partStrQuery += ' Where Id IN: recordIds';
        }
        partStrQuery += ' Order By CreatedDate ASC';
	    return Database.getQueryLocator(partStrQuery);
	}
	
    global void execute(Database.batchableContext bc, List<sObject> scope) {
    	List<Part__c> partList = (List<Part__c>) scope;
    	FIFOTransaction.updatePartFIFODetails(partList);
    }
    
    global void finish(Database.batchableContext bc) {
    	/*if(!isTriggerDisabled) {
       	    BPScriptUtility.enableTrigger('PartTrigger');
        }*/
    }
}