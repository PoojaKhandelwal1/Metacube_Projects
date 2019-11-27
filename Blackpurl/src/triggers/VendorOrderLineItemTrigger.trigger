/**
 * Author: Tarun Khandelwal
 * Since: Aug. 04, 2015
 * Name: VendorOrderLineItemTrigger
 * Description: Trigger executes on after update events of VOLI
**/
trigger VendorOrderLineItemTrigger on Vendor_Order_Line_Item__c (before insert, before update, after update, before delete) {
	
	if(VendorOrderLineItemTriggerHelper.shouldTriggerRunStop) {
	    return;
	}
	VendorOrderLineItemTriggerHelper.voliNewList = Trigger.new;
	VendorOrderLineItemTriggerHelper.voliOldList = Trigger.old;
	VendorOrderLineItemTriggerHelper.voliNewMap = Trigger.newMap;
	VendorOrderLineItemTriggerHelper.voliOldMap = Trigger.oldMap;
	
	Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('VendorOrderLineItemTrigger');
	
	if(trigger.isAfter && trigger.isUpdate && !utilObj.updateDisabled()){
		VendorOrderLineItemTriggerHelper.afterUpdateCalculation();
	}
	if(trigger.isBefore && trigger.isUpdate && !utilObj.updateDisabled()){
		//VendorOrderLineItemTriggerHelper.beforeUpdateCalculation();
		VendorOrderLineItemTriggerHelper.beforeTriggerCalculation();
	}
	if(trigger.isBefore && trigger.isInsert && !utilObj.insertDisabled()){
		VendorOrderLineItemTriggerHelper.beforeTriggerCalculation();
	}
	if(trigger.isBefore && trigger.isDelete && !utilObj.deleteDisabled()){
		VendorOrderLineItemTriggerHelper.beforeDeleteOperation();
	}
}