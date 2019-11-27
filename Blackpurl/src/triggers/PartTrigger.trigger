/**
 * Author: Tarun Khandelwal
 * Since: Nov. 29, 2014
 * Name: PartTrigger
 * Description: Trigger executes on before insert, before update and before delete events of Part object
**/
trigger PartTrigger on Part__c (before insert, after insert, before update, after update) {
    
    PartTriggerHelper.PartNewList = Trigger.new;
    PartTriggerHelper.PartOldList = Trigger.old;
    PartTriggerHelper.PartNewMap = Trigger.newMap;
    PartTriggerHelper.PartOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('PartTrigger');
    if(PartTriggerHelper.isDisableTriggerForSetQtyAndAvgCostOnFIFOBktAndLIBatch) {
    	return;	
    }
    if(Trigger.isBefore) {
        if(Trigger.isInsert && !utilObj.insertDisabled()) {
            PartTriggerHelper.populateDefaults();
        } else if(Trigger.isUpdate && !utilObj.updateDisabled()) {
             PartTriggerHelper.populateDefaults();
             if(!(system.isBatch() || System.isFuture() || PartTriggerHelper.preventOnAccountingSync)) {
                 PartTriggerHelper.populatesAccountingSyncFields();
             }
        }
    }
    
    if(Trigger.isAfter) {
        if(Trigger.isUpdate && !utilObj.updateDisabled() && !PartTriggerHelper.isPreventOnDataLoad) {
            PartTriggerHelper.AfterUpdateOperation();
            PartTriggerHelper.updateKitLineItems();
            if(!(system.isBatch() || System.isFuture() || PartTriggerHelper.preventOnAccountingSync)) {
		    	PartTriggerHelper.preventOnAccountingSync = true;
	            PartTriggerHelper.setPartDataForAccountSync();
	    	}
            PartTriggerHelper.updateFIFOBucketItems();
        }
        
        if(Trigger.isInsert && !utilObj.insertDisabled()) {
        	PartTriggerHelper.AfterInsertOperation();
        }
    }
}