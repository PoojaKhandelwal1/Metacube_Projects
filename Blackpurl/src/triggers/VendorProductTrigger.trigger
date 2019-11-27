/**
 * Author: Nidhi Sharma
 * Since: June. 15, 2017
 * Name: VendorProductTrigger
 * Description: Trigger executes on before insert event of VendorProduct object
**/
trigger VendorProductTrigger on Product__c (after update) {
    
    VendorProductTriggerHelper.vendorProductNewList = Trigger.new;
    VendorProductTriggerHelper.vendorProductOldList = Trigger.old;
    VendorProductTriggerHelper.vendorProductNewMap = Trigger.newMap;
    VendorProductTriggerHelper.vendorProductOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('VendorProductTrigger');
    
    if(Trigger.isAfter && Trigger.isUpdate && !utilObj.updateDisabled()) {
        VendorProductTriggerHelper.afterUpdateOperation();
    }
}