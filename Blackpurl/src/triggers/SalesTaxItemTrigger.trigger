/**
 * Author: Tarun Khandelwal
 * Since: Oct. 11, 2014
 * Name: SalesTaxItemTrigger
 * Description: Trigger executes on before delete and after update events of Sales Tax Item object
**/
trigger SalesTaxItemTrigger on Sales_Tax_Item__c (after insert, after update, before delete) {
	
	SalesTaxItemTriggerHelper.oldMap = trigger.oldMap;
	SalesTaxItemTriggerHelper.newMap = trigger.newMap;
	SalesTaxItemTriggerHelper.newList = trigger.new;
	SalesTaxItemTriggerHelper.oldList = trigger.old;
	
	Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('SalesTaxItemTrigger');
	
	if(system.isBatch() || system.isFuture()){
    	return;
    }
	
	if(trigger.isDelete && !utilObj.deleteDisabled()) {
		SalesTaxItemTriggerHelper.beforeDeleteOperations();
	}
	
	if(trigger.isUpdate && !utilObj.updateDisabled()) {
		SalesTaxItemTriggerHelper.afterUpdateOperation();
	}
	
	
	/*if(Trigger.isAfter) {
		if((Trigger.isInsert && !utilObj.insertDisabled())
			|| (Trigger.isUpdate && !utilObj.updateDisabled())){
        	if(QBUtil.isQBEnabled()) {
        		QB_TaxSyncScheduler.syncTaxCode();
        	}
        }
	}*/
}