trigger DealTrigger on Deal__c (before insert, after insert, before update, after update, before delete) {
    DealTriggerHelper.dealNewList = Trigger.new;
    DealTriggerHelper.dealOldList = Trigger.old;
    DealTriggerHelper.dealNewMap = Trigger.newMap;
    DealTriggerHelper.dealOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('DealTrigger');
    
    if(Trigger.isBefore && Trigger.isInsert && !utilObj.insertDisabled()) {
        DealTriggerHelper.beforeInsertOperation();
    }
	
    if(Trigger.isAfter && Trigger.isUpdate && !utilObj.updateDisabled()) {
        DealTriggerHelper.populateDealCountFieldOnCO();
    }
    
     if(Trigger.isInsert && Trigger.isAfter && !utilObj.insertDisabled()) {
        DealTriggerHelper.populateDealCountFieldOnCO();
    }
    
    if(Trigger.isDelete && Trigger.isBefore && !utilObj.deleteDisabled()) {
    	DealTriggerHelper.populateDealCountFieldOnCOOnDelete();
    }
    
    if(Trigger.isBefore && Trigger.isUpdate && !utilObj.updateDisabled()) {
    	DealTriggerHelper.populatesAccountingSyncFields();
    }
}