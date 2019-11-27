/**
 * Author: Tarun Khandelwal
 * Since: Nov. 29, 2014
 * Name: PartTriggerHelper
 * Description: Helper class for triggers on Part object
**/
public with sharing class PartTriggerHelper {
    
    // List to store trigger new list
    public static List<Part__c> PartNewList = new List<Part__c>();
    
    // List to store trigger old list
    public static List<Part__c> PartOldList = new List<Part__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Part__c> PartNewMap = new Map<Id, Part__c>();

    // Map to store Old Trigger Map
    public static Map<Id, Part__c> PartOldMap = new Map<Id, Part__c>();
    
    public static Boolean isTriggerExecuted = false;
    public static Boolean isPartFromImport = true;
    public static Boolean isCoToQuoteAction = false;
    
    // Trigger run boolean: QB Integration
    public static Boolean preventOnAccountingSync = false;
    public static Boolean isDisableTriggerForSetQtyAndAvgCostOnFIFOBktAndLIBatch = false;
    public static Boolean isPreventOnDataLoad = false;
    
    private static BaseIntegrationService integrationRec;
    
    /**
     * Name: populateDefaults
     * Desc: populates default fields of part
     * @param: 
     * @return: 
    **/
    public static void populateDefaults() {
        if(!GeneralConfiguration.getIsDataLoadFlag()) {
            for(Part__c part : PartNewList) {
                part.Part_Id_Text__c = part.Part_Number__c + Part.Vendor_Code__c;
            }
        }
        List<Id> relatedVendorRecords = new List<Id>(); 
        for(Part__c partRec : PartNewList) { // populated old category of part for Accounting purpose: QB Integration
            if(partRec.Id != null && PartOldMap.get(partRec.Id).Category__c != partRec.Category__c && partRec.Total_Cost__c != null && partRec.Total_Cost__c != 0) {
                partRec.Old_Category__c = PartOldMap.get(partRec.Id).Category__c;
            }
            if(partRec.Vendor__c != null) {
                relatedVendorRecords.add(partRec.Vendor__c);
            }
        }
        if(!Test.isRunningTest()) { //FIXME
            populateVendorDefaultForPart(relatedVendorRecords);
        }
    }
    
    public static void populateVendorDefaultForPart(List<Id> relatedVendorRecords) {
        Map<Id, Account> vendorMap = new Map<Id, Account>([SELECT Id, Part_Purchases__c, Merchandise_Purchases__c, Merchandise_Category_Default__c, Part_Category_Default__c
                                        FROM Account WHERE Id IN :relatedVendorRecords]);
        List<Category__c> partDefaultCategoryList = [Select Id FROM Category__c WHERE Type__c = 'Part' AND Default__c = true];
        for(Part__c partRec : PartNewList) {
            if( vendorMap.containsKey(partRec.Vendor__c) 
                && ( partRec.Id == null 
                    || ( String.isBlank(PartOldMap.get(partRec.Id).Part_Type__c) && String.isBlank(partRec.Part_Type__c) ) ) ) {
                Account vendor = vendorMap.get(partRec.Vendor__c);
                if(vendor.Part_Purchases__c != null && vendor.Part_Purchases__c) {
                    partRec.Part_Type__c = 'Part';
                    partRec.Category__c = vendor.Part_Category_Default__c;
                } else if(vendor.Merchandise_Purchases__c != null && vendor.Merchandise_Purchases__c) {
                    partRec.Part_Type__c = 'Merchandise';
                    partRec.Category__c = vendor.Merchandise_Category_Default__c;
                } else {
                    partRec.Part_Type__c = 'Part';
                    partRec.Category__c = partDefaultCategoryList.size() > 0 ? partDefaultCategoryList[0].Id : vendor.Part_Category_Default__c;
                }
            }
        }
    }
    
    /**
     * Name: AfterInsertOperation
     * Desc: When Part record is inserted this method executes 
     * @param: 
     * @return: 
    **/
    public static void AfterInsertOperation() {
        if(!isTriggerExecuted) {
            AfterUpdateOperation();
            isTriggerExecuted = true;
        }
        // Create bucket for the parts after insert.
        if(isPartFromImport){
            FIFOTransaction.createFIFOBucketForPartImport(PartNewList);
        }        
    }
    
    public static void updateFIFOBucketItems() {
    	if(GeneralConfiguration.getIsDataLoadFlag()) {
    		Map<Id, PartFIFOAdjustmentService.PartCountAjustmentWrapper> partIdToCountAdjustmentWrapperMap = new Map<Id, PartFIFOAdjustmentService.PartCountAjustmentWrapper>();
    		for(Part__c partRec : PartNewList) {
    			if(PartOldMap.get(partRec.Id).Qty_In_Stock__c != partRec.Qty_In_Stock__c) {
    				partIdToCountAdjustmentWrapperMap.put(partRec.Id, new PartFIFOAdjustmentService.PartCountAjustmentWrapper(partRec.Id, PartOldMap.get(partRec.Id).Qty_In_Stock__c, PartOldMap.get(partRec.Id).Last_Cost__c));
    			}
    		}
    		PartFIFOAdjustmentService.adjustPartQty(partIdToCountAdjustmentWrapperMap);
    	}
    }
    
    /**
     * Name: PartUpdateOperation
     * Desc: When Part record is updated this method executes 
     * @param: 
     * @return: 
    **/
    public static void AfterUpdateOperation() {
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        // Entry Condition for Trigger
        Boolean isValidTriggerEntry = true;
        for(Part__c partRec : PartNewList) {
            if((Trigger.isUpdate) && (PartNewMap.get(partRec.Id).AvailableParts__c == PartOldMap.get(partRec.Id).AvailableParts__c 
                    && PartNewMap.get(partRec.Id).Auto_reorder_Min__c == PartOldMap.get(partRec.Id).Auto_reorder_Min__c 
                    && PartNewMap.get(partRec.Id).Auto_reorder_Max__c == PartOldMap.get(partRec.Id).Auto_reorder_Max__c 
                    && PartNewMap.get(partRec.Id).Qty_On_Order__c == PartOldMap.get(partRec.Id).Qty_On_Order__c))  {
                isValidTriggerEntry = false;
            } 
        }
        
        //system.assert(false, isValidTriggerEntry);
        // If Not Valid Entry Condition, return from trigger
        if(!isValidTriggerEntry || PartTriggerHelper.isCoToQuoteAction) {
            return;
        }
        
        List<Vendor_Order_Line_Item__c> voLineItemsToUpsert = new List<Vendor_Order_Line_Item__c>();
        List<Vendor_Order_Line_Item__c> voLineItemsToDelete = new List<Vendor_Order_Line_Item__c>();
        // #Changes 03/06
        List<Vendor_Order_Line_Item__c> existingVOLineItemList = [select Id, part__c, Qty_Needed__c, Received__c, Vendor_Order_Line_Item_Group__c,Vendor_Order_Header__c,Vendor_Order_Header__r.Status__c from 
                                                                 Vendor_Order_Line_Item__c where Part__c IN : PartNewList AND Is_required_For_Customer__c = false AND Is_Service__c = false AND Is_Excess__c = false 
                                                                 AND Is_From_Search__c = false AND (Vendor_Order_Header__c= null OR Vendor_Order_Header__r.Status__c ='Open' OR Vendor_Order_Header__r.Status__c ='Locked')];
        system.debug('####'+existingVOLineItemList);                                                                                                                    
        
        // Map to check if there is already VOLineItem is present for same part.
        Map<Id, Vendor_Order_Line_Item__c> partIdToVOLineItemRecMap = new Map<Id, Vendor_Order_Line_Item__c>();
        for(Vendor_Order_Line_Item__c voLineItemRec : existingVOLineItemList) {
            voLineItemRec.Received__c = (voLineItemRec.Received__c == null) ? 0 : voLineItemRec.Received__c;
            if(voLineItemRec.Qty_Needed__c > voLineItemRec.Received__c && !partIdToVOLineItemRecMap.containsKey(voLineItemRec.Part__c)) {
                partIdToVOLineItemRecMap.put(voLineItemRec.Part__c, voLineItemRec);
            } 
        }
        
        for(Part__c partRec : PartNewList) {
            Decimal need = 0;
            need = toppingUpCalculationWithoutPackage(partRec);
            if((partRec.AvailableParts__c + partRec.Qty_On_Order__c) <= partRec.Auto_reorder_Min__c && partRec.Auto_reorder_Min__c <= partRec.Auto_reorder_Max__c 
               && partRec.Auto_reorder_Max__c > 0 && need > 0){
                   
                Vendor_Order_Line_Item__c voLineItemRec = new Vendor_Order_Line_Item__c();
                if(partIdToVOLineItemRecMap.containsKey(partRec.Id)) {
                    if(partIdToVOLineItemRecMap.get(partRec.Id).Vendor_Order_Line_Item_Group__c == null ){
                        voLineItemRec.Id =  partIdToVOLineItemRecMap.get(partRec.Id).Id;
                        voLineItemRec.Qty_Needed__c = need; 
                        voLineItemRec.Line_Item_Cost__c = partRec.Last_Cost__c;
                        voLineItemsToUpsert.add(voLineItemRec);
                    }
                    /* DO NOTHING IF THERE IS ALREADY VOLI PRESENT FOR THAT PART */
                    //voLineItemRec.Id = partIdToVOLineItemRecMap.get(partRec.Id).Id;
                    //voLineItemRec.Qty_Needed__c = need + partIdToVOLineItemRecMap.get(partRec.Id).Qty_Needed__c;
                } else {
                    voLineItemRec.Qty_Needed__c = need;
                    voLineItemRec.Part__c = partRec.Id;
                    voLineItemRec.Line_Item_Cost__c = partRec.Last_Cost__c;
                    voLineItemRec.Is_required_For_Customer__c = false;
                    voLineItemsToUpsert.add(voLineItemRec);
                }
            } else if((partRec.AvailableParts__c + partRec.Qty_On_Order__c) > partRec.Auto_reorder_Min__c || (partRec.Auto_reorder_Min__c == partRec.Auto_reorder_Max__c)){
                if(partIdToVOLineItemRecMap.containsKey(partRec.Id)) {
                    Vendor_Order_Line_Item__c voLineItemRec = partIdToVOLineItemRecMap.get(partRec.Id);
                    if(voLineItemRec.Vendor_Order_Line_Item_Group__c == null) {
                        voLineItemsToDelete.add(voLineItemRec);
                    }
                }
            }
        }
        
        if(voLineItemsToUpsert.size() > 0 ){
            upsert voLineItemsToUpsert;
        }
        if(voLineItemsToDelete.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete voLineItemsToDelete;
        }
    }
    
    /**
     * Name: toppingUpCalculationWithoutPackage
     * Desc: Topping Up Calculation in case of packaged Part.
     * @param: 
     * @return: 
    **/
    private static Decimal toppingUpCalculationWithoutPackage(Part__c partRec) {
        Decimal need = 0;
        need = partRec.Auto_reorder_Max__c - (partRec.AvailableParts__c + partRec.Qty_On_Order__c); 
        return need;
    }
    /**
     * Name: toppingUpCalculation
     * Desc: Topping Up Calculation in case of packaged Part.
     * @param: 
     * @return: 
    **/
    private static Decimal toppingUpCalculation(Part__c partRec) {
        Decimal need = 0;
        need = partRec.Auto_reorder_Max__c - (partRec.AvailableParts__c + partRec.Qty_On_Order__c); 
        
        if(partRec.Packaged_Part__c) {
            Long packagedPartInNeed = (need / partRec.Package_Qty__c).longValue();
            if(packagedPartInNeed * partRec.Package_Qty__c < need) {
                packagedPartInNeed += 1;
            }
            need = packagedPartInNeed * partRec.Package_Qty__c;
        }
        
        if(partRec.Order_Lots__c > 1) {
            Long orderLotPartInNeed = (need / partRec.Order_Lots__c).longValue();
            if(orderLotPartInNeed * partRec.Order_Lots__c < need) {
                orderLotPartInNeed += 1;
            }
            need = orderLotPartInNeed * partRec.Order_Lots__c;
        }
        return need;
    }
    
    /**
     * Name: updateKitLineItems
     * Desc: Update Kit Line Item if Retail Price of Part is changed.
     * @param: 
     * @return: 
    **/
    public static void updateKitLineItems() {
        if(system.isBatch()) {
            return;
        }
        List<Id> partIdList = new List<Id>();
        for(Part__c partRec : PartNewList) {
            if(PartNewMap.get(partRec.Id).Retail_Price__c != PartOldMap.get(partRec.Id).Retail_Price__c) {
                partIdList.add(partRec.Id);
            }
        }
        //system.assert(false, partIdList);
        if(partIdList.size() > 0) {
            KitLineItemtriggerHelper.updateRetailofKitLineItems('Part__c', partIdList);
        }
    }
    
    public static void populatesAccountingSyncFields() {
        if(QBUtil.isQBEnabled()) {
            QBSyncFlagService.managePartJESyncFlagOnCategoryChange(PartNewList, PartOldMap);
        } else {
        	integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
        	if(integrationRec != null) {
                IntegrationSyncFlagService.managePartCategorySyncFlag(new List<BaseIntegrationService>{integrationRec}, PartNewList, PartOldMap);
        	}
        }
    }
    
    public static void setPartDataForAccountSync() {
        Set<Id> partIdSet = new Set<Id>();
        for(Part__c partRec : PartNewList) { 
        	if(QBUtil.isQBEnabled()) {
	            if(partRec.Avail_For_QB_Sync_Category__c) {
	                partIdSet.add(partRec.Id);
	            }
        	} else if(integrationRec != null) {
    	    	if(partRec.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.PART_CATEGORY).Sync_Flag_API_Name__c) != null && 
	    			Boolean.valueOf(partRec.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.PART_CATEGORY).Sync_Flag_API_Name__c))) {
    	        	partIdSet.add(partRec.Id);
    	    	}
        	}
        }
        if(partIdSet.size() > 0) {
        	if(QBUtil.isQBEnabled()) {
            	PartCategoryService.syncParts(partIdSet);
        	} else {
    			IntegrationBatchService.initiateBatch(partIdSet, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.PART_CATEGORY);
    		}
        }
    }
}
