/**
 * Author: Richa ittal
 * Since: Jan. 23, 2019
 * Name: ClaimLineItemTriggerHelper
 * Description: Helper class for triggers on Claim Line Item object
**/
public with sharing class ClaimLineItemTriggerHelper {
    
    public static Boolean isUpdateSOLI = true;
    // List to store trigger new list
    public static List<Claim_Line_Item__c> claimLineItemNewList = new List<Claim_Line_Item__c>();
    
    // List to store trigger old list
    public static List<Claim_Line_Item__c> claimLineItemOldList = new List<Claim_Line_Item__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Claim_Line_Item__c> claimLineItemNewMap = new Map<Id, Claim_Line_Item__c>();
    
    // Map to store Old Trigger Map
    public static Map<Id, Claim_Line_Item__c> claimLineItemOldMap = new Map<Id, Claim_Line_Item__c>();
    
    public static void updateSOLIForClaimLI() {
        if(!isUpdateSOLI) return;
        List<Service_Order_Line_Item__c> soliListToUpdate = new List<Service_Order_Line_Item__c>();
        for(Claim_Line_Item__c claimLIRec: claimLineItemNewList) {
            if(claimLIRec.Claimed_Qty__c != claimLineItemOldMap.get(claimLIRec.Id).Claimed_Qty__c ||
                claimLIRec.Claimed_Price__c != claimLineItemOldMap.get(claimLIRec.Id).Claimed_Price__c) {
                    Decimal claimedPrice = (claimLIRec.Claimed_Price__c != null ? claimLIRec.Claimed_Price__c : 0);
                    Service_Order_Line_Item__c soliRec = new Service_Order_Line_Item__c(Id = claimLIRec.Service_Order_Line_Item__c, Qty_Needed__c = claimLIRec.Claimed_Qty__c);
                    if(GeneralConfiguration.getTaxIncludingPricing()) {
                        soliRec.Price_When_Tax_Included__c = claimedPrice;
                        soliRec.kit_Price__c = (claimedPrice / (1 + claimLIRec.Tax__c / 100 ));
                    } else {
                        soliRec.Kit_Price__c = claimedPrice;
                    }
                    soliListToUpdate.add(soliRec);
                }
        }
        if(soliListToUpdate.size() > 0) {
            ServiceOrderLineItemTriggerHelper.isUpdateClaimLI = false;
    		Boolean isTriggerExecute = ServiceOrderLineItemTriggerHelper.isTriggerExecuted;
    		ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
            update soliListToUpdate;
			ServiceOrderLineItemTriggerHelper.isTriggerExecuted = isTriggerExecute;
            ServiceOrderLineItemTriggerHelper.isUpdateClaimLI = true;
        }
    }
}