/**
 * Author: Tarun Khandelwal
 * Since: March 08, 2016
 * Name: SOTrigger
 * Description: Trigger executes on after insert and after update events of SO Header object
**/
trigger SOTrigger on Service_Order_Header__c (before insert, before update, after update, before delete) {
	
	SOTriggerHelper.soHeaderNewList = Trigger.new;
	SOTriggerHelper.soHeaderOldList = Trigger.old;
	SOTriggerHelper.soHeaderNewMap = Trigger.newMap;
	SOTriggerHelper.soHeaderOldMap = Trigger.oldMap;
	
	Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('SOTrigger');
	
	if(Trigger.isBefore && Trigger.isInsert && !utilObj.insertDisabled()){
		SOTriggerHelper.beforeInsertOperation();
	}
	
	if(Trigger.isBefore && Trigger.isUpdate && !utilObj.updateDisabled()){
		SOTriggerHelper.beforeUpdateOperation();
	}
	
	if(Trigger.isAfter && Trigger.isUpdate && !utilObj.updateDisabled()){
		SOTriggerHelper.afterUpdateInsertOperation();
	}
	
	if(Trigger.isBefore && Trigger.isDelete && !utilObj.deleteDisabled()){
        SOTriggerHelper.beforeDeleteOperation();
    }
}