/**
 * Author: Richa Mittal
 * Since: Jan. 16, 2017
 * Name: CODepositTrigger
 * Description: Trigger executes on before insert and after insert events of CO_Deposit__c object
**/
trigger CODepositTrigger on CO_Deposit__c (after insert, before insert) {
    
    CODepositTriggerHelper.CODepositNewList = Trigger.new;
    CODepositTriggerHelper.CODepositOldList = Trigger.old;
    CODepositTriggerHelper.CODepositNewMap = Trigger.newMap;
    CODepositTriggerHelper.CODepositOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('CODepositTrigger');
    
    
    if(system.isBatch() || CODepositTriggerHelper.preventOnAccountingSync) {
    	return;
    }
    
    if(Trigger.isBefore && Trigger.isInsert && !utilObj.insertDisabled()) {
    	CODepositTriggerHelper.populatesAccountingSyncFields();
    }
    
    if(Trigger.isAfter && Trigger.isInsert && !utilObj.insertDisabled()) { 
        CODepositTriggerHelper.preventOnAccountingSync = true;
        CODepositTriggerHelper.setCODepositDataForAccountSync();
    }
    
}