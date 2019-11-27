/**
 * Author: Tarun Khandelwal
 * Since: Nov. 13, 2014
 * Name: CustomerTrigger
 * Description: Trigger executes on before insert, before update and before delete events of Customer object
**/
trigger CustomerTrigger on Account (before delete, after insert, after update, before insert, before update) {
    
    CustomerTriggerHelper.accountNewList = Trigger.new;
    CustomerTriggerHelper.accountOldList = Trigger.old;
    CustomerTriggerHelper.accountNewMap = Trigger.newMap;
    CustomerTriggerHelper.accountOldMap = Trigger.oldMap;
    CustomerTriggerHelper.isTriggerRun = false;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('CustomerTrigger');
    
    if(system.isBatch()) {
        return;
    } 
    
    if(Trigger.isBefore && Trigger.isInsert && !utilObj.insertDisabled()) {
        CustomerTriggerHelper.populatesFieldsBeforeInsert();
    
    } else if(Trigger.isBefore && Trigger.isUpdate && !utilObj.updateDisabled()) {
        CustomerTriggerHelper.populatesAccountingSyncFields();
        CustomerTriggerHelper.populatesFieldsBeforeInsert();
    }
    
    if(Trigger.isAfter && Trigger.isInsert && !utilObj.insertDisabled()) {
    	CustomerTriggerHelper.accountInsertOperation();
    } else if(Trigger.isAfter && Trigger.isUpdate && !CustomerTriggerHelper.isTriggerRun && !utilObj.updateDisabled()) {
    	CustomerTriggerHelper.afterUpdateCalculations(); 
    } 
    
    if(Trigger.isAfter && Trigger.isUpdate && !utilObj.updateDisabled()) {
    	 if(!(CustomerTriggerHelper.preventOnAccountingSync || system.isFuture())) {
            CustomerTriggerHelper.preventOnAccountingSync = true;
            CustomerTriggerHelper.setCustomerAndVendorDataForAccountSync();
        }       
    }
}