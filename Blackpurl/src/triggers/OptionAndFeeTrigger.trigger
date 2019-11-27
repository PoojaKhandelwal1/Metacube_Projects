/**
 * Author: Tarun Khandelwal 
 * Since: Oct 21, 2016
 * Name: OptionAndFeeTrigger
 * Description: Trigger executes on after update event of Option & Fee object
**/
trigger OptionAndFeeTrigger on Option_Fee__c (before insert, after insert, before update, after update, after delete) {
    
    if(OptionAndFeeTriggerHelper.isForceStopTrigger) {
    	return;
    }
    
    // Initialize List and Maps
    OptionAndFeeTriggerHelper.OptionAndFeeNewList = Trigger.new;
    OptionAndFeeTriggerHelper.OptionAndFeeOldList = Trigger.old; 
    OptionAndFeeTriggerHelper.OptionAndFeeNewMap = Trigger.newMap;
    OptionAndFeeTriggerHelper.OptionAndFeeOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('OptionAndFeeTrigger');
    
    if(trigger.isBefore && trigger.isInsert && !utilObj.insertDisabled()) {
    	OptionAndFeeTriggerHelper.beforeInsertCalculation();
    }
    if(trigger.isAfter && trigger.isInsert && !utilObj.insertDisabled()) {
    	OptionAndFeeTriggerHelper.afterInsertCalculation();
    }
    
    if(trigger.isBefore && trigger.isUpdate && !utilObj.updateDisabled()) {
    	OptionAndFeeTriggerHelper.beforeUpdateCalculation();
    }
    if(trigger.isAfter && trigger.isUpdate && !utilObj.updateDisabled()) {
    	OptionAndFeeTriggerHelper.afterUpdateCalculation();
    }
    
    if(trigger.isAfter && trigger.isDelete && !utilObj.deleteDisabled()) {
    	OptionAndFeeTriggerHelper.afterDeleteCalculation();
    }
}