/**
 * Author: Richa Mittal
 * Since: Jan. 23, 2019
 * Name: ClaimLineItemTrigger
 * Description: Trigger executes on after update event of Claim Line Item object
**/
trigger ClaimLineItemTrigger on Claim_Line_Item__c (after update) {
    ClaimLineItemTriggerHelper.claimLineItemNewList = Trigger.new;
    ClaimLineItemTriggerHelper.claimLineItemOldList = Trigger.old;
    ClaimLineItemTriggerHelper.claimLineItemNewMap = Trigger.newMap;
    ClaimLineItemTriggerHelper.claimLineItemOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('ClaimLineItemTrigger');
    
    if(Trigger.isAfter && (Trigger.isUpdate && !utilObj.updateDisabled())) {
        ClaimLineItemTriggerHelper.updateSOLIForClaimLI();
    }
}