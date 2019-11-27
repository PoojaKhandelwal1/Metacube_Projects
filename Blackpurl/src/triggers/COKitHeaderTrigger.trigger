/**
 * Author: Tarun Khandelwal
 * Since: Feb 05, 2016
 * Name: COKitHeaderTrigger
 * Description: Trigger executes on after insert, after update event of CO Kit header object
**/
trigger COKitHeaderTrigger on CO_Kit_Header__c (after insert, before delete) {
    
    // Initialize List and Maps
    COKitHeaderTriggerHelper.cokhNewList = Trigger.new;
    COKitHeaderTriggerHelper.cokhOldList = Trigger.old;
    COKitHeaderTriggerHelper.cokhNewMap = Trigger.newMap;
    COKitHeaderTriggerHelper.cokhOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('COKitHeaderTrigger');
   
   if(trigger.isAfter && trigger.isInsert && !utilObj.insertDisabled()) {
        COKitHeaderTriggerHelper.afterInsertCalculation();
    }
    
    if(trigger.isBefore && trigger.isDelete && !utilObj.deleteDisabled()) {
        COKitHeaderTriggerHelper.beforeDeleteOperation();
    }
}