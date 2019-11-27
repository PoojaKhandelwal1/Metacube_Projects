/**
 * Author: Tarun Khandelwal
 * Since: Dec. 10, 2015
 * Name: LabourCodeTrigger
 * Description: Trigger executes on after update events of Labour_Code__c object
**/
trigger LabourCodeTrigger on Labour_Code__c (after update) {
    
    LabourCodeTriggerHelper.LabourNewList = Trigger.new;
    LabourCodeTriggerHelper.LabourOldList = Trigger.old;
    LabourCodeTriggerHelper.LabourNewMap = Trigger.newMap;
    LabourCodeTriggerHelper.LabourOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('LabourCodeTrigger');
    
    if(Trigger.isAfter) {
        if(Trigger.isUpdate && !utilObj.updateDisabled()) {
             LabourCodeTriggerHelper.updateKitLineItems();
        }
    }
}