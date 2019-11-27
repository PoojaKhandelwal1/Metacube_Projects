/**
 * Author: Ashish Garg
 * Since: Aug. 20, 2015
 * Name: VendorReceivingGroupTrigger
 * Description: Trigger for Vendor_Receiving_Group__c
**/
trigger VendorReceivingGroupTrigger on Vendor_Receiving_Group__c (before delete, before update, after update, after insert) {
    VendorReceivingGroupTriggerHelper.newList   = Trigger.new;
    VendorReceivingGroupTriggerHelper.oldList   = Trigger.old;
    VendorReceivingGroupTriggerHelper.newMap    = Trigger.newMap;
    VendorReceivingGroupTriggerHelper.oldMap    = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('VendorReceivingGroupTrigger');
    
    if(trigger.isBefore && !utilObj.updateDisabled() && !utilObj.deleteDisabled()){
        VendorReceivingGroupTriggerHelper.updateLineItemsReceivedQty();
    }
    
    if(Trigger.isBefore && Trigger.isUpdate && !utilObj.updateDisabled()) {
    	VendorReceivingGroupTriggerHelper.beforeUpdateOperation();
    }
    
    if(Trigger.isBefore && Trigger.isDelete && !utilObj.deleteDisabled()) {
    	VendorReceivingGroupTriggerHelper.beforeDeleteOperation(); 
    }
    
    if(Trigger.isAfter && Trigger.isUpdate && !utilObj.updateDisabled()) {
    	VendorReceivingGroupTriggerHelper.afterUpdateOperation();
    }
    
    if(Trigger.isAfter && Trigger.isInsert && !utilObj.insertDisabled()) {
    	VendorReceivingGroupTriggerHelper.afterUpdateOperation();
    }
}