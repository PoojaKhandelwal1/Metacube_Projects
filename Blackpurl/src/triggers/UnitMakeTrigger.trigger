trigger UnitMakeTrigger on Unit_Make__c (before insert, before update) {
    
    UnitMakeTriggerHelper.unitMakeNewList = Trigger.new;
	UnitMakeTriggerHelper.unitMakeOldList = Trigger.old;
	UnitMakeTriggerHelper.unitMakeNewMap = Trigger.newMap;
	UnitMakeTriggerHelper.unitMakeOldMap = Trigger.oldMap;
	
	Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('UnitMakeTrigger');
	
	if((trigger.isInsert && !utilObj.insertDisabled()) || (trigger.isUpdate && !utilObj.updateDisabled())) {
		UnitMakeTriggerHelper.checkForUniqueMake();		
	}
}