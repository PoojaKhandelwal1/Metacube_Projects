/**
 * Author: Hitesh Gupta
 * Since: Oct, 10, 2017
 * Name: ReturnVOHeaderTrigger
 * Description: Trigger executes on before insert, before update and after update events of Return_VO_Header object
**/
trigger ReturnVOHeaderTrigger on Return_VO_Header__c (before update, after update){
    
    ReturnVOHeaderTriggerHelper.returnVONewList = Trigger.new;
    ReturnVOHeaderTriggerHelper.returnVOOldList = Trigger.old;
    ReturnVOHeaderTriggerHelper.returnVONewMap = Trigger.newMap;
    ReturnVOHeaderTriggerHelper.returnVOOldMap = Trigger.oldMap; 
   
   	Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('ReturnVOHeaderTrigger');
    
    if(system.isBatch()) {
    	return;
    }
    
    if(Trigger.isBefore && Trigger.isUpdate && !utilObj.updateDisabled()) {
        ReturnVOHeaderTriggerHelper.populatesAccountingSyncFields();
    }
    
    if(Trigger.isAfter && Trigger.isUpdate && !utilObj.updateDisabled()) { 
    	if(!(ReturnVOHeaderTriggerHelper.preventOnAccountingSync || System.isFuture())) {
        	ReturnVOHeaderTriggerHelper.preventOnAccountingSync = true;
        	ReturnVOHeaderTriggerHelper.setVendorInvoiceDataForAccountSync();
    	}
    }
        
}