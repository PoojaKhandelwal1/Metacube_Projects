/**
 * Author: Tarun Khandelwal
 * Since: March 27, 2014
 * Name: COLineItemTrigger
 * Description: Trigger executes on after update event of CO Line Item object
**/
trigger COLineItemTrigger on CO_Line_Item__c (before insert, after insert, before update, after update, before delete, after delete) {
    
    if(COLineItemTriggerHelper.isForceStopTrigger) {
    	return;
    }
    
    // Initialize List and Maps
    COLineItemTriggerHelper.COLineItemNewList = Trigger.new;
    COLineItemTriggerHelper.COLineItemOldList = Trigger.old;
    COLineItemTriggerHelper.COLineItemNewMap = Trigger.newMap;
    COLineItemTriggerHelper.COLineItemOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('COLineItemTrigger');
    
    if(trigger.isBefore && trigger.isInsert && !utilObj.insertDisabled()) {
        //COLineItemTriggerHelper.beforeInsertCalculation();
        COLineItemTriggerHelper.beforeInsertCalculation_Updated();
    }
    
    if(trigger.isAfter && trigger.isInsert && !utilObj.insertDisabled()) {
        //COLineItemTriggerHelper.afterInsertCalculation();
        COLineItemTriggerHelper.afterInsertCalculation_Updated();
        COLineItemTriggerHelper.populateOrderTotal();
        COLineItemTriggerHelper.populateStatusAndTotalsForMerchSection();
    }
    
    if(trigger.isBefore && trigger.isUpdate && !utilObj.updateDisabled()) {
        COLineItemTriggerHelper.beforeUpdateCalculation();
    }
    
    if(trigger.isAfter && trigger.isUpdate && !utilObj.updateDisabled()) {
        COLineItemTriggerHelper.afterUpdateCalculation();
        COLineItemTriggerHelper.populateOrderTotal();
        COLineItemTriggerHelper.populateStatusAndTotalsForMerchSection();
    }
    
    if(trigger.isBefore && trigger.isDelete && !utilObj.deleteDisabled()) {
        COLineItemTriggerHelper.beforeDeleteOperation();
    }
    
    if(trigger.isAfter && trigger.isDelete && !utilObj.deleteDisabled()) {
        COLineItemTriggerHelper.populateOrderTotal();
        COLineItemTriggerHelper.populateStatusAndTotalsForMerchSection();
    }
}