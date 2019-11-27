trigger UnitPriceAndCostTrigger on Unit_Price_Cost__c (before insert, after delete, after insert, after update) {
	
	UnitPriceAndCostTriggerHelper.unitPriceAndCostNewList = Trigger.new;
    UnitPriceAndCostTriggerHelper.unitPriceAndCostOldList = Trigger.old;
    UnitPriceAndCostTriggerHelper.unitPriceAndCostNewMap = Trigger.newMap;
    UnitPriceAndCostTriggerHelper.unitPriceAndCostOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('UnitPriceAndCostTrigger');
    
    if(system.isBatch()) {
        return;
    }
    
    if(trigger.isBefore && trigger.isInsert && !utilObj.insertDisabled()) {
    	UnitPriceAndCostTriggerHelper.beforeInsertCalculation();
    }
    
	if(trigger.isAfter && trigger.isInsert && !utilObj.insertDisabled()) {
    	UnitPriceAndCostTriggerHelper.afterInsertCalculation();
    	if(!(UnitPriceAndCostTriggerHelper.preventOnAccountingSync || System.isFuture())){
	    	UnitPriceAndCostTriggerHelper.preventOnAccountingSync = true;
            UnitPriceAndCostTriggerHelper.setUnitPriceAndCostDataForAccountSync();
    	}
    }
     
    if(trigger.isDelete && !utilObj.deleteDisabled()) {
    	UnitPriceAndCostTriggerHelper.afterDeleteCalculation();
    }
    
    if(trigger.isUpdate && !utilObj.updateDisabled()) {
    	UnitPriceAndCostTriggerHelper.afterUpdateCalculation();
    	UnitPriceAndCostTriggerHelper.setUnitPriceAndCostDataForAccountSync();
    }
}