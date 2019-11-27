/**
 * Author: Tarun Khandelwal
 * Since: Oct. 10, 2014
 * Name: SalesTaxTrigger
 * Description: Trigger executes on before insert and before update events of Price Level object
**/
trigger SalesTaxTrigger on Sales_Tax__c (before insert, before update, before delete) {
    
    // Initializes List of helper classes
    SalesTaxTriggerHelper.salesTaxNewList = Trigger.new;
    SalesTaxTriggerHelper.salesTaxOldList = Trigger.old;
    SalesTaxTriggerHelper.salesTaxNewMap = Trigger.newMap;
    SalesTaxTriggerHelper.salesTaxOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('SalesTaxTrigger');
    
    if( Trigger.isBefore ) {
        
        if( Trigger.isInsert && !utilObj.insertDisabled()) {
             // Update default field if new record default field is selected
             SalesTaxTriggerHelper.updateDefaultField();
        }
        
        if( Trigger.isUpdate && !utilObj.updateDisabled()) {
             // Update default field if new record default field is selected
             SalesTaxTriggerHelper.updateDefaultField();
        }
        
        if( Trigger.isDelete && !utilObj.deleteDisabled()) {
             // Validate the deleting record before deleting if it default and active record or not
             SalesTaxTriggerHelper.validateBeforeDel();
        }
    }
}