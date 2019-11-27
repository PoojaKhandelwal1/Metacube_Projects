trigger CustomerOwnedUnitTrigger on Customer_Owned_Unit__c(before insert, after insert, before update, after update) {
    
    CustomerOwnedUnitTriggerHelper.customerOwnerUnitNewList = Trigger.new;
    CustomerOwnedUnitTriggerHelper.customerOwnerUnitOldList = Trigger.old;
    CustomerOwnedUnitTriggerHelper.customerOwnerUnitNewMap = Trigger.newMap;
    CustomerOwnedUnitTriggerHelper.customerOwnerUnitOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('CustomerOwnedUnitTrigger');
    
    if(system.isBatch()) {
        return;
    }
    
    if(Trigger.isBefore) {
        if(Trigger.isInsert && !utilObj.insertDisabled()){
            CustomerOwnedUnitTriggerHelper.beforeInsertOperations();
            CustomerOwnedUnitTriggerHelper.populatesAccountingSyncFields();
        } else if(Trigger.isUpdate && !utilObj.updateDisabled()) {
            CustomerOwnedUnitTriggerHelper.populatesFieldsBeforeUpdate();
            CustomerOwnedUnitTriggerHelper.populateCategoryChangeAccountingSyncFields();
        }
    }   
    
    if(Trigger.isAfter) {
        if(trigger.isInsert && !utilObj.insertDisabled()) {
            if(!(CustomerOwnedUnitTriggerHelper.preventOnAccountingSync || system.isFuture())) {
                CustomerOwnedUnitTriggerHelper.setCOUDataForAccountSync();
            }
        } else if(Trigger.isUpdate && !utilObj.updateDisabled()) {
            if(!(CustomerOwnedUnitTriggerHelper.preventOnAccountingSync || system.isFuture())) {
                CustomerOwnedUnitTriggerHelper.setUnitDataForCategoryChangeAccountSync();
            }
        }
	    
	    if((trigger.isInsert || trigger.isUpdate) && !utilObj.insertDisabled() && !utilObj.updateDisabled() && !system.isFuture()) {
    		CustomerOwnedUnitTriggerHelper.syncInventoryWithDP360();
    	}
    }
}