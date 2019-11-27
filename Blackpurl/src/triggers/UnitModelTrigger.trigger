trigger UnitModelTrigger on Unit_Model__c (before insert, before update) {
    
    UnitModelTriggerHelper.unitModelNewList = Trigger.new;
	UnitModelTriggerHelper.unitModelOldList = Trigger.old;
	UnitModelTriggerHelper.unitModelNewMap = Trigger.newMap;
	UnitModelTriggerHelper.unitModelOldMap = Trigger.oldMap;
	
	Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('UnitModelTrigger');
	
	if((trigger.isInsert && !utilObj.insertDisabled()) || (trigger.isUpdate && !utilObj.updateDisabled())) {
		UnitModelTriggerHelper.checkForUniqueModelBasedOnMake();		
	}
}