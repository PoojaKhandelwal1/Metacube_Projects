/**
 * Author: Pooja Khandelwal
 * Since: Dec. 23, 2014
 * Name: VendorInvoicingHeaderTrigger
 * Description: Trigger executes on before insert, before update and after update events of Vendor_Invoicing_Header object
**/
trigger VendorInvoicingHeaderTrigger on Vendor_Invoicing_Header__c(before update, after update) {
    
    VendorInvoicingHeaderTriggerHelper.invoiceNewList = Trigger.new;
    VendorInvoicingHeaderTriggerHelper.invoiceOldList = Trigger.old;
    VendorInvoicingHeaderTriggerHelper.invoiceNewMap = Trigger.newMap;
    VendorInvoicingHeaderTriggerHelper.invoiceOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('VendorInvoicingHeaderTrigger');
    
    if(system.isBatch()) {
    	return;
    }
    
    if(Trigger.isBefore && Trigger.isUpdate && !utilObj.updateDisabled()) {
        VendorInvoicingHeaderTriggerHelper.populatesAccountingSyncFields();
    }
    
    if(Trigger.isAfter && Trigger.isUpdate && !utilObj.updateDisabled()) { 
    	if(!(VendorInvoicingHeaderTriggerHelper.preventOnAccountingSync || system.isFuture())) {
        	VendorInvoicingHeaderTriggerHelper.preventOnAccountingSync = true;
        	VendorInvoicingHeaderTriggerHelper.setVendorInvoiceDataForAccountSync();
    	}
    }
}