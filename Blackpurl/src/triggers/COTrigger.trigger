/**
 * Author: Tarun Khandelwal
 * Since: March 27, 2014
 * Name: COTrigger
 * Description: Trigger executes on after update event of CO Hearder object
**/
trigger COTrigger on CO_Header__c (before insert, before update, after update) {
    
    if(COTriggerHelper.isForceStopTrigger) {
        return;
    }
    
    COTriggerHelper.COHeaderNewList = Trigger.new;
    COTriggerHelper.COHeaderOldList = Trigger.old;
    COTriggerHelper.COHeaderNewMap = Trigger.newMap;
    COTriggerHelper.COHeaderOldMap = Trigger.oldMap;
    COTriggerHelper.isTriggerExecute = false;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('COTrigger');
    
    if(trigger.isBefore && trigger.isInsert && !utilObj.insertDisabled()) {
        COTriggerHelper.beforeInsertOperation();
    }
    
    if(trigger.isBefore && trigger.isUpdate  && !utilObj.updateDisabled()) {
        COTriggerHelper.beforeUpdateOperation();
    }
    
    if(trigger.isAfter && trigger.isUpdate  && !utilObj.updateDisabled()) {
        COTriggerHelper.afterUpdateCalculation();
        COTriggerHelper.updateAccountFields();
    }
    
}