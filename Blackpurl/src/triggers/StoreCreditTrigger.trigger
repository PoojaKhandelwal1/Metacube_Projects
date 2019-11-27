/**
 * Author: Richa Mittal
 * Since: Aug 24, 2017
 * Name: StoreCreditTrigger
 * Description: Trigger executes on before insert and after insert events of Store_Credit__c object
**/
trigger StoreCreditTrigger on Store_Credit__c (after insert, before insert) {
    
    StoreCreditTriggerHelper.StoreCreditNewList = Trigger.new;
    StoreCreditTriggerHelper.StoreCreditOldList = Trigger.old;
    StoreCreditTriggerHelper.StoreCreditNewMap = Trigger.newMap;
    StoreCreditTriggerHelper.StoreCreditOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('StoreCreditTrigger');
    
    if(system.isBatch()) {
    	return;
    }
    
    if(Trigger.isBefore && Trigger.isInsert && !utilObj.insertDisabled()) {
        StoreCreditTriggerHelper.populatesAccountingSyncFields();
    }
    
    if(Trigger.isAfter && Trigger.isInsert && !utilObj.insertDisabled()){ 
    	if(!system.isFuture()){	
        	StoreCreditTriggerHelper.preventOnAccountingSync = true;
        	StoreCreditTriggerHelper.setStoreCreditDataForAccountSync();
    	}
    }
}