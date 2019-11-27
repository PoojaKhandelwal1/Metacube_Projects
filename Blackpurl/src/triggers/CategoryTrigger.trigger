/**
 * Author: Tarun Khandelwal
 * Since: Dec. 17, 2014
 * Name: CategoryTrigger
 * Description: Trigger executes on before insert event of Category object
**/
trigger CategoryTrigger on Category__c (before insert, before update, before delete, after insert, after update) {
    
    CategoryTriggerHelper.categoryNewList = Trigger.new;
    CategoryTriggerHelper.categoryOldList = Trigger.old;
    CategoryTriggerHelper.categoryNewMap = Trigger.newMap;
    CategoryTriggerHelper.categoryOldMap = Trigger.oldMap;
    
    if(system.isBatch()) {
    	return;
    }
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('CategoryTrigger');
    
    if(Trigger.isBefore) {
        if(Trigger.isInsert && !utilObj.insertDisabled()) {
            CategoryTriggerHelper.setAccountingSyncFlag();
            CategoryTriggerHelper.checkForUniqueNameByType();
        } else if (Trigger.isUpdate && !utilObj.updateDisabled()) {
            CategoryTriggerHelper.setAccountingSyncFlag();
            CategoryTriggerHelper.checkForUniqueNameByType();
        } else if (Trigger.isDelete && !utilObj.deleteDisabled()) {
            CategoryTriggerHelper.checkForDefaultDelete();
        } 
    }
    
    if(Trigger.isAfter) {
    	if((Trigger.isInsert && !utilObj.insertDisabled()) || 
    			(Trigger.isUpdate && !utilObj.updateDisabled())){
    		if(!System.isFuture()) {			
	        	//CategoryTriggerHelper.preventOnAccountingSync = true;
	        	CategoryTriggerHelper.setItemCategoryDataForAccountSync();
	        	CategoryTriggerHelper.updateTradeInDefaultCategory();
    		}
        }
    }
}