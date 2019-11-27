/**
 * Author: Pooja Khandelwal
 * Since: Dec. 23, 2014
 * Name: COInvoiceTrigger
 * Description: Trigger executes on before update and after update events of COInvoice object
**/
trigger COInvoiceTrigger on CO_Invoice_Header__c(before update, after update) {
    
    COInvoiceTriggerHelper.invoiceNewList = Trigger.new;
    COInvoiceTriggerHelper.invoiceOldList = Trigger.old;
    COInvoiceTriggerHelper.invoiceNewMap = Trigger.newMap;
    COInvoiceTriggerHelper.invoiceOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('COInvoiceTrigger');
    
    if(system.isBatch()) {
        return;
    }
    
    if(Trigger.isBefore && Trigger.isUpdate && !utilObj.updateDisabled()) {
        COInvoiceTriggerHelper.populatesAccountingSyncFields();
    }
    
    if(Trigger.isAfter && Trigger.isUpdate && !utilObj.updateDisabled()) {
        system.debug('preventOnAccountingSync ' + COInvoiceTriggerHelper.preventOnAccountingSync);
        system.debug('System.isFuture()   ' + System.isFuture());
        if(!(COInvoiceTriggerHelper.preventOnAccountingSync || System.isFuture())) {
            COInvoiceTriggerHelper.preventOnAccountingSync = true;
            COInvoiceTriggerHelper.setCOInvoiceDataForAccountSync();
        }
    }
}
