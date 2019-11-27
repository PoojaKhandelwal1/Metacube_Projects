/**
 * Author: Nidhi Sharma
 * Since: Nov. 22, 2016 
 * Name: DealItemTrigger
 * Description: Trigger executes on before insert and after delete events of DealItem object
**/
trigger DealItemTrigger on Deal_Item__c (before insert, after insert, before update, after update, before delete, after delete) {
    
    if(DealItemTriggerHelper.isForceStopTrigger) {
    	return;
    }
    
    DealItemTriggerHelper.dealItemNewList = Trigger.new;
    DealItemTriggerHelper.dealItemOldList = Trigger.old;
    DealItemTriggerHelper.dealItemNewMap = Trigger.newMap;
    DealItemTriggerHelper.dealItemOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('DealItemTrigger');
    
    if(system.isBatch()) {
    	return;
    }
    
    if(Trigger.isBefore && Trigger.isInsert && !utilObj.insertDisabled()) {
        DealItemTriggerHelper.beforeInsertOperations();
    }
    if(Trigger.isAfter && Trigger.isInsert && !utilObj.insertDisabled()) {
        DealItemTriggerHelper.afterInsertOperations();
    }
    
    if(Trigger.isBefore && Trigger.isUpdate && !utilObj.updateDisabled()) {
    	DealItemTriggerHelper.onBeforeUpdate();
    }
    
    if(Trigger.isAfter && Trigger.isUpdate && !utilObj.updateDisabled()) {
        DealItemTriggerHelper.afterUpdateOperations();
        if(!(DealItemTriggerHelper.preventOnAccountingSync || System.isFuture())){
        	DealItemTriggerHelper.preventOnAccountingSync = true;
        	DealItemTriggerHelper.setDealItemDataForAccountSync();
    	}
    }
    
    if( Trigger.isBefore && Trigger.isDelete && !utilObj.deleteDisabled()) {
		DealItemTriggerHelper.beforeDeleteOperation();
    }
    if(Trigger.isAfter && Trigger.isDelete && !utilObj.deleteDisabled()) {
		DealItemTriggerHelper.afterDeleteOperation();
    }
}