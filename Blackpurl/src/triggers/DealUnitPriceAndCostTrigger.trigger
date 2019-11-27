/**
 * Author: Nidhi Sharma
 * Since: Dec. 03, 2016
 * Name: DealUnitPriceAndCostTrigger
 * Description: Trigger executes on before insert and after delete events of Deal_Unit_Price_Cost__c object
**/
trigger DealUnitPriceAndCostTrigger on Deal_Unit_Price_Cost__c (after insert, after update, after delete) { 
    
    DealUnitPriceAndCostTriggerHelper.DealUnitPriceAndCostNewList = Trigger.new; 
    DealUnitPriceAndCostTriggerHelper.DealUnitPriceAndCostOldList = Trigger.old; 
    DealUnitPriceAndCostTriggerHelper.DealUnitPriceAndCostNewMap = Trigger.newMap;
    DealUnitPriceAndCostTriggerHelper.DealUnitPriceAndCostOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('DealUnitPriceAndCostTrigger');
    
    if(trigger.isAfter && trigger.isInsert && !utilObj.insertDisabled()) {
        DealUnitPriceAndCostTriggerHelper.afterInsertOperations();
    }
    if(trigger.isAfter && trigger.isUpdate && !utilObj.updateDisabled()) {
        DealUnitPriceAndCostTriggerHelper.afterUpdateOperations();
    }
    if(trigger.isAfter && trigger.isDelete && !utilObj.deleteDisabled()) {
        DealUnitPriceAndCostTriggerHelper.afterDeleteOperations();
    }
}