/**
 * Author: Tarun Khandelwal
 * Since: Sept 06, 2017
 * Name: OtherChargesTrigger
 * Description: Trigger executes events of Other Charges object
**/
trigger OtherChargesTrigger on Other_Charges__c (after delete, after insert, after update, before insert) {
    
    // Initialize List and Maps
    OtherChargesTriggerHelper.otherChargesNewList = Trigger.new;
    OtherChargesTriggerHelper.otherChargesOldList = Trigger.old;
    OtherChargesTriggerHelper.otherChargesNewMap = Trigger.newMap;
    OtherChargesTriggerHelper.otherChargesOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('OtherChargesTrigger');
    
    if(trigger.isBefore && trigger.isInsert ) {
        OtherChargesTriggerHelper.beforeInsertOperation();
    }
    
    if(trigger.isAfter && trigger.isInsert) {
        OtherChargesTriggerHelper.afterInsertOperation();
    }
    
    if(trigger.isAfter && trigger.isUpdate) {
        OtherChargesTriggerHelper.afterUpdateOperation();
    }
    
    if(trigger.isAfter && trigger.isDelete ) {
        OtherChargesTriggerHelper.afterDeleteOperation();
    }
    
}