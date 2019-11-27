/**
 * Author: Tarun Khandelwal
 * Since: Oct. 17, 2014
 * Name: StateTrigger
 * Description: Trigger executes on before insert, before update and before delete events of State object
**/
trigger StateTrigger on State__c (before delete, before insert, before update) {
	
	// Initializes List of helper classes
	StateTriggerHelper.stateNewList = Trigger.new;
	StateTriggerHelper.stateOldList = Trigger.old;
	StateTriggerHelper.stateNewMap = Trigger.newMap;
	StateTriggerHelper.stateOldMap = Trigger.oldMap;
	
	Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('StateTrigger');
	
	if(Trigger.isInsert && !utilObj.insertDisabled()) {
		StateTriggerHelper.updateDefaultfield();
	}
	
	if(Trigger.isUpdate && !utilObj.updateDisabled()) {
		StateTriggerHelper.updateDefaultfield();
	}
	
	if(Trigger.isDelete && !utilObj.deleteDisabled()) {
		StateTriggerHelper.checkDefaultOnDelete();
	}
}