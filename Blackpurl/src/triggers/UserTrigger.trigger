trigger UserTrigger on User (after insert, before insert, before update) {
	UserTriggerHelper.userNewList = Trigger.new;
	UserTriggerHelper.userOldList = Trigger.old;
	UserTriggerHelper.userNewMap = Trigger.newMap;
	UserTriggerHelper.userOldMap = Trigger.oldMap;
	
	Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('UserTrigger');
	
	if(!UserTriggerHelper.isRunTrigger) {
		return;
	}
	 
	if(Trigger.isAfter && Trigger.isInsert && !utilObj.insertDisabled()) { 
		UserTriggerHelper.createWidgetAndFilter();
	}
	
	if(Trigger.isBefore && Trigger.isInsert && !utilObj.insertDisabled()) { 
		UserTriggerHelper.populateDateFields();
	}
	
	if(Trigger.isBefore && Trigger.isUpdate && !utilObj.updateDisabled()) { 
		UserTriggerHelper.populateDateFields();
	}
}