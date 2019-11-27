/**
 * Author: Tarun Khandelwal
 * Since: Aug. 04, 2014
 * Name: VendorOrderLineItemTriggerHelper
 * Description: Helper class for triggers on VOLI.
**/
public with sharing class VendorOrderLineItemTriggerHelper {
    
    // List to store trigger new list
    public static List<Vendor_Order_Line_Item__c> voliNewList = new List<Vendor_Order_Line_Item__c>();
    
    // List to store trigger old list
    public static List<Vendor_Order_Line_Item__c> voliOldList = new List<Vendor_Order_Line_Item__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Vendor_Order_Line_Item__c> voliNewMap = new Map<Id, Vendor_Order_Line_Item__c>();
    
    // Map to store Old Trigger Map
    public static Map<Id, Vendor_Order_Line_Item__c> voliOldMap = new Map<Id, Vendor_Order_Line_Item__c>();
    
    public static Boolean isTriggerExecute = true;
    public static Boolean shouldTriggerRunStop = false;
    
    /**
     * Name: beforeUpdateCalculation
     * Desc: before update operations
     * @param: 
     * @return: 
    **
    public static void beforeUpdateCalculation() {
        // Update related vendor order group and received required qty amount
        Set<Vendor_Receiving_Group__c> vrgToUpdate = new Set<Vendor_Receiving_Group__c>();
        boolean isValidTriggerEntry = false;
        if(Trigger.isBefore && Trigger.isUpdate){
            for(Vendor_Order_Line_Item__c voli : voliNewList){
                if( (voliNewMap.get(voli.Id).Vendor_Receiving_Group__c != null || voliOldMap.get(voli.Id).Vendor_Receiving_Group__c != null) && voliNewMap.get(voli.Id).Vendor_Receiving_Group__c != voliOldMap.get(voli.Id).Vendor_Receiving_Group__c ){
                    isValidTriggerEntry = true;
                    
                    if(voliNewMap.get(voli.Id).Vendor_Receiving_Group__c == null){
                        vrgToUpdate.add(new Vendor_Receiving_Group__c(Id = voliOldMap.get(voli.Id).Vendor_Receiving_Group__c, Recieved__c = 0));
                    } else  if(voliOldMap.get(voli.Id).Vendor_Receiving_Group__c == null){
                        vrgToUpdate.add(new Vendor_Receiving_Group__c(Id = voliNewMap.get(voli.Id).Vendor_Receiving_Group__c));
                    } else {
                        vrgToUpdate.add(new Vendor_Receiving_Group__c(Id = voliOldMap.get(voli.Id).Vendor_Receiving_Group__c, Recieved__c = 0));
                        vrgToUpdate.add(new Vendor_Receiving_Group__c(Id = voliNewMap.get(voli.Id).Vendor_Receiving_Group__c));
                    }
                }
            }
        }
        List<Vendor_Receiving_Group__c> vrgListToUpdate = new List<Vendor_Receiving_Group__c>();
        
        if(vrgToUpdate.size() > 0) {
            vrgListToUpdate.addAll(vrgToUpdate);
        }
        
        
        system.debug('vrgListToUpdatevrgListToUpdate  : ' + vrgListToUpdate);
        if(isValidtriggerEntry && vrgListToUpdate.size() > 0){
            update vrgListToUpdate;
        }
    }
    
    /**
     * Name: afterUpdateCalculation
     * Desc: Update Special order field of COLI in case of require for customer VOLI.
     * @param: 
     * @return: 
    **/
    public static void afterUpdateCalculation() {
        if(AccessControl.ifObjectIsUpdateable('CO_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE);}
        Set<Id> specialOrderCOLineItemIdSet = new Set<Id>();
        Set<Id> notSpecialOrderCOLineItemIdSet = new Set<Id>();
        
        Set<Id> specialOrderSOLIIdSet = new Set<Id>();
        Set<Id> notSpecialOrderSOLIIdSet = new Set<Id>();
        
        for(Vendor_Order_Line_Item__c voliRec : voliNewList) {
            if(voliRec.Vendor_Order_Header__c != null && (voliRec.Is_required_For_Customer__c || voliRec.Is_Service__c) && (voliRec.CO_Line_Item__c != null || voliRec.Service_Order_Line_Item__c != null)) {
                if(voliRec.CO_Line_Item__c != null) {
                    specialOrderCOLineItemIdSet.add(voliRec.CO_Line_Item__c);
                } else if(voliRec.Service_Order_Line_Item__c != null) {
                    specialOrderSOLIIdSet.add(voliRec.Service_Order_Line_Item__c);
                }
            } else if(voliOldMap.get(voliRec.Id).Vendor_Order_Header__c != null && voliRec.Vendor_Order_Header__c == null && (voliRec.Is_required_For_Customer__c || voliRec.Is_Service__c)) {
                if(voliRec.CO_Line_Item__c != null) {
                    notSpecialOrderCOLineItemIdSet.add(voliRec.CO_Line_Item__c);
                } else if(voliRec.Service_Order_Line_Item__c != null) {
                    notSpecialOrderSOLIIdSet.add(voliRec.Service_Order_Line_Item__c);
                }
            }
        }


        if(specialOrderCOLineItemIdSet.size() == 0 && notSpecialOrderCOLineItemIdSet.size() == 0 && specialOrderSOLIIdSet.size() == 0 && notSpecialOrderSOLIIdSet.size() == 0) {
            return;
        }
        
        if(specialOrderCOLineItemIdSet.size() > 0 || notSpecialOrderCOLineItemIdSet.size() > 0) {
            List<CO_Line_Item__c> coLineItemListToUpdate = new List<CO_Line_Item__c>();
            
            if(AccessControl.ifObjectIsAccessible('CO_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
                List<CO_Line_Item__c> colIneItemList = [select Id, Special_Order__c from CO_Line_Item__c where Id IN :specialOrderCOLineItemIdSet OR Id IN :notSpecialOrderCOLineItemIdSet];
            for(CO_Line_Item__c coLineItemRec : colIneItemList) {
                coLineItemRec.Special_Order__c = specialOrderCOLineItemIdSet.contains(coLineItemRec.Id) ? true : false;
                coLineItemListToUpdate.add(coLineItemRec);
            }
        
            if(coLineItemListToUpdate.size() > 0 && isTriggerExecute) {
                COLineItemTriggerHelper.isTriggerExecute = true;
                if(!COLineItemTriggerHelper.isVOLIRecToChange)
                update coLineItemListToUpdate;
            }
        }
        /*
        if(specialOrderSOLIIdSet.size() > 0 || notSpecialOrderSOLIIdSet.size() > 0) {
            List<Service_Order_Line_Item__c> soliListToUpdate = new List<Service_Order_Line_Item__c>();
        
            if(AccessControl.ifObjectIsAccessible('CO_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            List<Service_Order_Line_Item__c> soliList = [select Id, Special_Order__c from Service_Order_Line_Item__c where Id IN :specialOrderSOLIIdSet OR Id IN :notSpecialOrderSOLIIdSet];
            for(Service_Order_Line_Item__c soLineItemRec : soliList) {
                soLineItemRec.Special_Order__c = specialOrderSOLIIdSet.contains(soLineItemRec.Id) ? true : false;
                soliListToUpdate.add(soLineItemRec);
            }
            
            if(soliListToUpdate.size() > 0 && isTriggerExecuted) {
                ServiceOrderLineItemTriggerHelper.isTriggerExecuted = true;
                if(!ServiceOrderLineItemTriggerHelper.isVOLIRecToChange)
                update soliListToUpdate;
            }
        }*/
        
        // To calculate VOG Need column
        updateRelatedVOLIGroup();
        updateRelatedSubmittedVOLIGroup();
    }
    
    public static void updateCOLIStatus() {
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        List<CO_Line_Item__c> coLineItemList = new List<CO_Line_Item__c>();
        List<Service_Order_Line_Item__c> soLineItemList = new List<Service_Order_Line_Item__c>();
        for(Vendor_Order_Line_Item__c voliRec : voliNewList) {
            if(voliRec.CO_Line_Item__c != null) {
                CO_Line_Item__c coliRec = new CO_Line_Item__c(Id = voliRec.CO_Line_Item__c);
                if(voliRec.Vendor_Order_Line_Item_Group__c != null) {
                    coliRec.Status__c = 'Ordered';
                } else {
                    coliRec.Status__c = 'Required';
                }
                coLineItemList.add(coliRec);
            } else if(voliRec.Service_Order_Line_Item__c != null) {
                Service_Order_Line_Item__c soliRec = new Service_Order_Line_Item__c(Id = voliRec.Service_Order_Line_Item__c);
                if(voliRec.Vendor_Order_Line_Item_Group__c != null) {
                    soliRec.Status__c = 'Ordered';
                } else {
                    soliRec.Status__c = 'Required';
                }
                soLineItemList.add(soliRec);
            }
        }
        if(coLineItemList.size() > 0 && isTriggerExecute) {
            COLineItemTriggerHelper.isTriggerExecute = true;
            isTriggerExecute = false;
            update coLineItemList;
        }
        if(soLineItemList.size() > 0 && isTriggerExecute) {
            ServiceOrderLineItemTriggerHelper.isTriggerExecuted = true;
            isTriggerExecute = false;
            update soLineItemList;
        }
    }
    
    /**
     * Name: beforeTriggerCalculation
     * Desc: Update Need for all group records for all line items
     * @param: 
     * @return: 
    **
    public static void beforeTriggerCalculation() {
        Boolean isValidEntry = false;
        Set<Id> voliGroupIdSet = new Set<Id>(); 
        List<Vendor_Order_Line_Item__c> triggerRecsList = (Trigger.isDelete) ? voliOldList : voliNewList;
        
        for(Vendor_Order_Line_Item__c voliRec : triggerRecsList) {
            if(trigger.isDelete && voliRec.Vendor_Order_Line_Item_Group__c != null){
                voliGroupIdSet.add(voliRec.Vendor_Order_Line_Item_Group__c);
                isValidEntry = true;
            } else if(voliOldMap.get(voliRec.Id).Vendor_Order_Line_Item_Group__c != voliNewMap.get(voliRec.Id).Vendor_Order_Line_Item_Group__c
                    || voliOldMap.get(voliRec.Id).Qty_Needed__c != voliNewMap.get(voliRec.Id).Qty_Needed__c ) {
                
                if(voliNewMap.get(voliRec.Id).Vendor_Order_Line_Item_Group__c != null){
                    voliGroupIdSet.add(voliNewMap.get(voliRec.Id).Vendor_Order_Line_Item_Group__c);
                }
                if(voliOldMap.get(voliRec.Id).Vendor_Order_Line_Item_Group__c != null){
                    voliGroupIdSet.add(voliOldMap.get(voliRec.Id).Vendor_Order_Line_Item_Group__c);
                }
                isValidEntry = true;
            }
        }
        
        System.debug('@@@@@@ Inside VOLITrigger ' + isValidEntry);
        if(isValidEntry) {
            VendorOrderLineItemTriggerHelper.updateNeedForVOGRecords(voliGroupIdSet);
        }
    }
    
    /**
     * Name: updateNeedForVOGRecords
     * Desc: Update "Need" on vendor order group records: total of needs of all vendor order line items
     * @param: Set<Id> vonder order group record Ids
     * @return: 
    **
    @future
    public static void updateNeedForVOGRecords(Set<Id> vogIds){
        List<Vendor_Order_Line_Item_Group__c> voliGroupList = [select Need__c, (select Id, Qty_Needed__c from Vendor_Order_Line_Items__r) from Vendor_Order_Line_Item_Group__c where Id IN: vogIds];
        for(Vendor_Order_Line_Item_Group__c voliGrpRec : voliGroupList) {
            Decimal need = 0;
            for(Vendor_Order_Line_Item__c voliRec : voliGrpRec.Vendor_Order_Line_Items__r) {
                need += voliRec.Qty_Needed__c;
            }
            voliGrpRec.Need__c = need;
        }
        
        if(voliGroupList.size() > 0) {
            update voliGroupList;
        }
    }*/
    
    public static void beforeTriggerCalculation() {
        populateDealerName();
    }
   
    private static void populateDealerName() {
        Boolean isNotRequiredForCustomer = false;
        for(Vendor_Order_Line_Item__c voliRec : voliNewList) {
            if(voliRec.Is_required_For_Customer__c != null && !voliRec.Is_required_For_Customer__c) {
                isNotRequiredForCustomer = true;
                break;
            }  
        }
        if(isNotRequiredForCustomer) {
            List<Business_Profile__c> businessProfileList = [Select Business_Name__c from Business_Profile__c LIMIT 1];
            if(businessProfileList.size() > 0) {
                for(Vendor_Order_Line_Item__c voliRec : voliNewList) {
                    if(voliRec.Is_required_For_Customer__c != null && !voliRec.Is_required_For_Customer__c) {
                        voliRec.Dealer_Name__c = businessProfileList[0].Business_Name__c;
                    }
                }
            }
        }
    }
    
    public static Boolean isUpdateQtyOnGroup = false; 
    
    private static Set<Id> getVOLIGroupIdSet() {
        Set<Id> voligGroupIdSet = new Set<Id>();
        for(Vendor_Order_Line_Item__c voliRec : voliOldList) {
            if(voliRec.Vendor_Order_Line_Item_Group__c != null) {
                voligGroupIdSet.add(voliRec.Vendor_Order_Line_Item_Group__c);
            }
        }
        voligGroupIdSet.remove(null);
        return voligGroupIdSet;
    }
    
    public static Boolean shouldTriggerRun = false;
    public static void beforeDeleteOperation() {
        if(!shouldTriggerRun) {
            return;
        }
        isUpdateQtyOnGroup = true;
        updateRelatedVOLIGroup();
    }
    
    public static void updateRelatedVOLIGroup() {
        if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        
        if(!isUpdateQtyOnGroup) {
            return;
        }
        isUpdateQtyOnGroup = false;
        Set<Id> voligGroupIdSet = getVOLIGroupIdSet();
        List<Vendor_Order_Line_Item_Group__c> voliGroupList = [select Part__c, Sublet__c, Part__r.Packaged_Part__c, Part__r.Package_Qty__c, Part__r.Order_Lots__c, Vendor_Order_Header__c, Part__r.Qty_On_Order__c,
                                                                (select Qty_Needed__c, Is_Excess__c, Is_required_For_Customer__c, Is_Service__c from Vendor_Order_Line_Items__r) 
                                                                from Vendor_Order_Line_Item_Group__c where Id IN :voligGroupIdSet]; 
    
        List<sObject> sObjToDel = new List<sObject>();
        List<sObject> sObjToUpdate = new List<sObject>();
        List<Vendor_Order_Line_Item__c> voliListToUpsert = new List<Vendor_Order_Line_Item__c>();
        for(Vendor_Order_Line_Item_Group__c voliGroupRec : voliGroupList) {
            if(voliGroupRec.Vendor_Order_Line_Items__r.size() == 1 && voliOldMap.containsKey(voliGroupRec.Vendor_Order_Line_Items__r[0].Id) 
                && trigger.isDelete) {
                    sObjToDel.add(voliGroupRec);
            } else if(voliGroupRec.Vendor_Order_Line_Items__r.size() == 2 && trigger.isDelete) {
                Boolean isNotToBeAddedInList = false;
                Vendor_Order_Line_Item__c excessRec;
                for(Vendor_Order_Line_Item__c voliRec : voliGroupRec.Vendor_Order_Line_Items__r) {
                    if(voliOldMap.containsKey(voliRec.Id) || (!voliOldMap.containsKey(voliRec.Id) && voliRec.Is_Excess__c)) {
                        isNotToBeAddedInList = false;
                        if(voliRec.Is_Excess__c) {
                            excessRec = voliRec;
                        }
                    } else {
                        isNotToBeAddedInList = true;
                        break;
                    }
                }
                if(!isNotToBeAddedInList) {
                    sObjToDel.add(voliGroupRec);
                    sObjToDel.add(excessRec);
                    
                    // Update Parts Qty On Order 
                    sObjToUpdate.add(updatePartOrderedQty(false, voliGroupRec.Part__c, voliGroupRec.Part__r.Qty_On_Order__c, 0, -(excessRec.Qty_Needed__c)));
                } else {
                    excessRec = recalculateNeedOnGroup(new List<Vendor_Order_Line_Item_Group__c> {voliGroupRec});
                    if(excessRec.Qty_Needed__c != 0) {
                        voliListToUpsert.add(excessRec);
                    } else if(excessRec.Qty_Needed__c == 0 && excessRec.Id != null) {
                        sObjToDel.add(excessRec);
                    }
                    sObjToUpdate.add(voliGroupRec);
                } 
            } else {
                Vendor_Order_Line_Item__c excessRec = recalculateNeedOnGroup(new List<Vendor_Order_Line_Item_Group__c> {voliGroupRec});
                if(excessRec != null) {
                    if(excessRec.Qty_Needed__c != 0) {
                        voliListToUpsert.add(excessRec);
                    } else if(excessRec.Qty_Needed__c == 0 && excessRec.Id != null) {
                        sObjToDel.add(excessRec);
                    }
                }
                sObjToUpdate.add(voliGroupRec);
            }
        }        
        if(sObjToDel.size() > 0) {
            shouldTriggerRun = false;
            delete sObjToDel;
        }
        if(voliListToUpsert.size() > 0) {
            upsert voliListToUpsert;
        }
        if(sObjToUpdate.size() > 0) {
            Map<Id, sObject> sobjIdToSobjectRecMap = new Map<Id, Sobject>();
            for(sObject sobj : sObjToUpdate) {
                sobjIdToSobjectRecMap.put(sobj.Id, sobj);
            }
            update sobjIdToSobjectRecMap.values();
        }
    }
    
    public static Boolean isUpdateQtyOnSubmittedGroup = false; 
    private static void updateRelatedSubmittedVOLIGroup() {
        if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(!isUpdateQtyOnSubmittedGroup) {
            return;
        }
        isUpdateQtyOnSubmittedGroup = false;
        Set<Id> voligGroupIdSet = getVOLIGroupIdSet();
        List<Vendor_Order_Line_Item_Group__c> voliGroupList = [select Part__c, Part__r.Packaged_Part__c, Part__r.Package_Qty__c, Part__r.Order_Lots__c, Part__r.Qty_On_Order__c,
                                                                (select Qty_Needed__c, Is_Excess__c, Part__c, Received__c, Is_required_For_Customer__c, CO_Line_Item__c, 
                                                                    CO_Header__c, Is_Service__c, Vendor_Order_Header__c, Vendor_Receiving_Group__c,
                                                                 Vendor_Order_Line_Item_Group__c, Cost__c, Line_Item_Cost__c from Vendor_Order_Line_Items__r WHERE Part__c != null) 
                                                                from Vendor_Order_Line_Item_Group__c where Id IN :voligGroupIdSet AND Part__c != null];
        Set<Id> coLineItemIdSet = new Set<Id>();
        Map<Id, Decimal> partIdToOrderedQtyMap = new Map<Id, Decimal>();
        for(Vendor_Order_Line_Item_Group__c voliGroupRec : voliGroupList) {
            for(Vendor_Order_Line_Item__c voliRec : voliGroupRec.Vendor_Order_Line_Items__r) {
                if(voliNewMap.containsKey(voliRec.Id)) {
                    coLineItemIdSet.add(voliRec.CO_Line_Item__c);
                }
            }
            if(voliGroupRec.Part__r.Qty_On_Order__c == null) {
                voliGroupRec.Part__r.Qty_On_Order__c = 0;
            }
            partIdToOrderedQtyMap.put(voliGroupRec.Part__c, voliGroupRec.Part__r.Qty_On_Order__c);
        }
    
        Map<Id, Boolean> coLineItemIdToHasAdditionalVOLineItemMap = new Map<Id, Boolean>();
        Map<Id, List<Vendor_Order_Line_Item__c>> coLineItemIdToVOLineItemsMap = new Map<Id, List<Vendor_Order_Line_Item__c>>();
        if(coLineItemIdSet.size() > 0) {
            List<CO_Line_Item__c> coLineItems = [select Id, (select Qty_Needed__c, Vendor_Order_Line_Item_Group__c, Vendor_Order_Header__c, 
                                                                Vendor_Receiving_Group__c 
                                                                from Vendor_Order_Line_Items__r where Vendor_Receiving_Group__c = null
                                                                order by CreatedDate ASC) 
                                                                from CO_Line_Item__c where Id IN: coLineItemIdSet];
            for(CO_Line_Item__c coliRec : coLineItems) {
                if(coliRec.Vendor_Order_Line_Items__r.size() == 2 && coliRec.Vendor_Order_Line_Items__r[1].Vendor_Order_Line_Item_Group__c == null) {
                    coLineItemIdToHasAdditionalVOLineItemMap.put(coliRec.Id, true);
                } else {
                    coLineItemIdToHasAdditionalVOLineItemMap.put(coliRec.Id, false);
                }
                coLineItemIdToVOLineItemsMap.put(coliRec.Id, coliRec.Vendor_Order_Line_Items__r);
            }                                           
        }
        
        
        List<sObject> sObjToInsert = new List<sObject>();
        List<sObject> sObjToUpdate = new List<sObject>();
        List<sObject> sObjToDelete = new List<sObject>();
        
        for(Vendor_Order_Line_Item_Group__c voliGroupRec : voliGroupList) {
            Vendor_Order_Line_Item__c alreadyExcessRec = new Vendor_Order_Line_Item__c();
            for(Vendor_Order_Line_Item__c voliRec : voliGroupRec.Vendor_Order_Line_Items__r) {
                if(voliRec.Is_Excess__c) {
                    alreadyExcessRec = voliRec;
                }   
            } 
            
            Decimal qtyNeeded = 0;
            for(Vendor_Order_Line_Item__c voliRec : voliGroupRec.Vendor_Order_Line_Items__r) {
                if(voliNewMap.containsKey(voliRec.Id)) {
                    Decimal qtyDifference = (voliOldMap.get(voliRec.Id).Qty_Needed__c - voliNewMap.get(voliRec.Id).Qty_Needed__c);
                    Decimal qtyDifferenceFromUI = -qtyDifference;
                        if(coLineItemIdToHasAdditionalVOLineItemMap.containsKey(voliRec.CO_Line_Item__c) && 
                            coLineItemIdToHasAdditionalVOLineItemMap.get(voliRec.CO_Line_Item__c)) {
                          qtyDifferenceFromUI = -(qtyDifference + coLineItemIdToVOLineItemsMap.get(voliRec.CO_Line_Item__c)[1].Qty_Needed__c);
                    }
                    if(qtyDifferenceFromUI < 0) {
                        if(coLineItemIdToHasAdditionalVOLineItemMap.containsKey(voliRec.CO_Line_Item__c)) {
                            Decimal qtyDifferenceFromUI_Mod = -(qtyDifferenceFromUI);
                            if(coLineItemIdToHasAdditionalVOLineItemMap.get(voliRec.CO_Line_Item__c)) {
                                Vendor_Order_Line_Item__c alreadyBuildAdditionalVOLIRec = coLineItemIdToVOLineItemsMap.get(voliRec.CO_Line_Item__c)[1];
                                if(qtyDifferenceFromUI_Mod < alreadyBuildAdditionalVOLIRec.Qty_Needed__c) {
                                    alreadyBuildAdditionalVOLIRec.Qty_Needed__c = alreadyBuildAdditionalVOLIRec.Qty_Needed__c - qtyDifferenceFromUI_Mod;
                                    sObjToUpdate.add(alreadyBuildAdditionalVOLIRec);
                                    // 
                                    voliRec.Qty_Needed__c = voliRec.Qty_Needed__c + qtyDifference;
                                    sObjToUpdate.add(voliRec);
                                } else if(qtyDifferenceFromUI_Mod == alreadyBuildAdditionalVOLIRec.Qty_Needed__c){
                                    sObjToDelete.add(alreadyBuildAdditionalVOLIRec);
                                    // 
                                    voliRec.Qty_Needed__c = voliRec.Qty_Needed__c + qtyDifference;
                                    sObjToUpdate.add(voliRec);
                                
                                } else {
                                    if(alreadyBuildAdditionalVOLIRec.Qty_Needed__c != null) {
                                        qtyDifferenceFromUI_Mod -= alreadyBuildAdditionalVOLIRec.Qty_Needed__c;
                                        sObjToDelete.add(alreadyBuildAdditionalVOLIRec);
                                    }
                                    if(qtyDifferenceFromUI_Mod > 0) {
                                        if(alreadyExcessRec.Id == null) {
                                            Vendor_Order_Line_Item__c cloneStockVOLIRec = voliRec.clone(false, false, false);
                                            cloneStockVOLIRec.Is_Service__c = false;
                                            cloneStockVOLIRec.Is_required_For_Customer__c = false;
                                            cloneStockVOLIRec.Is_Excess__c = true;
                                            cloneStockVOLIRec.CO_Line_Item__c = null;
                                            cloneStockVOLIRec.CO_Header__c = null;
                                            cloneStockVOLIRec.Received__c = 0;
                                            cloneStockVOLIRec.Qty_Needed__c = qtyDifferenceFromUI_Mod;
                                            sObjToInsert.add(cloneStockVOLIRec);
                                        } else {
                                            alreadyExcessRec.Qty_Needed__c = (alreadyExcessRec.Qty_Needed__c + qtyDifferenceFromUI_Mod);
                                            sObjToUpdate.add(alreadyExcessRec);
                                        }
                                        sObjToUpdate.add(voliRec);
                                    }
                                }
                            } else {
                                if(qtyDifferenceFromUI_Mod > 0) {
                                    if(alreadyExcessRec.Id == null) {
                                        Vendor_Order_Line_Item__c cloneStockVOLIRec = voliRec.clone(false, false, false);
                                        cloneStockVOLIRec.Is_Service__c = false;
                                        cloneStockVOLIRec.Is_required_For_Customer__c = false;
                                        cloneStockVOLIRec.Is_Excess__c = true;
                                        cloneStockVOLIRec.CO_Line_Item__c = null;
                                        cloneStockVOLIRec.CO_Header__c = null;
                                        cloneStockVOLIRec.Received__c = 0;
                                        cloneStockVOLIRec.Qty_Needed__c = qtyDifferenceFromUI_Mod;
                                        sObjToInsert.add(cloneStockVOLIRec);
                                    } else {
                                        alreadyExcessRec.Qty_Needed__c = (alreadyExcessRec.Qty_Needed__c + qtyDifferenceFromUI_Mod);
                                        sObjToUpdate.add(alreadyExcessRec);
                                    }
                                    sObjToUpdate.add(voliRec);
                                }
                            }
                            // Update Part Qty On Order -
                            Part__c partRec = new Part__c(Id = voliRec.Part__c);
                            partRec.Qty_On_Order__c = partIdToOrderedQtyMap.containsKey(partRec.Id) ? 
                                                            partIdToOrderedQtyMap.get(partRec.Id) + qtyDifferenceFromUI_Mod : null;
                            if(partRec.Qty_On_Order__c != null) {
                                sObjToUpdate.add(partRec);
                            }   
                        }
                    }
                    else if(qtyDifferenceFromUI > 0) {
                        if(coLineItemIdToHasAdditionalVOLineItemMap.containsKey(voliRec.CO_Line_Item__c)) {
                            if(coLineItemIdToHasAdditionalVOLineItemMap.get(voliRec.CO_Line_Item__c)) {
                                Vendor_Order_Line_Item__c alreadyBuildAdditionalVOLIRec = coLineItemIdToVOLineItemsMap.get(voliRec.CO_Line_Item__c)[1];
                                alreadyBuildAdditionalVOLIRec.Qty_Needed__c += qtyDifferenceFromUI;
                                sObjToUpdate.add(alreadyBuildAdditionalVOLIRec);
                            } else {
                                Vendor_Order_Line_Item__c cloneRFCVOLIRec = voliRec.clone(false, false, false);
                                cloneRFCVOLIRec.Vendor_Order_Line_Item_Group__c = null;
                                cloneRFCVOLIRec.Vendor_Receiving_Group__c = null;
                                cloneRFCVOLIRec.Vendor_Order_Header__c = null;
                                cloneRFCVOLIRec.Received__c = 0;
                                cloneRFCVOLIRec.Qty_Needed__c = -(qtyDifference);
                                sObjToInsert.add(cloneRFCVOLIRec);
                            }
                            // Update the Existing Record - Not to be changed.
                            voliRec.Qty_Needed__c = voliRec.Qty_Needed__c + qtyDifference;
                            sObjToUpdate.add(voliRec);
                        }
                    }
                }
            }
        }
        //system.assert(false, sObjToUpdate + ' \n\n ' + sObjToDelete + '\n\n' + sObjToInsert);
        
        if(sObjToInsert.size() > 0) {
            insert sObjToInsert;
        }
        if(sObjToUpdate.size() > 0) {
            update sObjToUpdate;
        }
        
        if(sObjToDelete.size() > 0) {
            delete sObjToDelete;
        }
    }
    
    
    private static Vendor_Order_Line_Item__c recalculateNeedOnGroup(List <Vendor_Order_Line_Item_Group__c> voliGroupRecList) {
        Vendor_Order_Line_Item_Group__c voliGroupRec;
        if(voliGroupRecList.size() > 0){
            voliGroupRec = voliGroupRecList[0];
        }
        
        Decimal needForVOLineItem = 0;
        Decimal previousExcessNeed = 0;
        Vendor_Order_Line_Item__c excessRec = new Vendor_Order_Line_Item__c();
        for(Vendor_Order_Line_Item__c voliRec : voliGroupRec.Vendor_Order_Line_Items__r) {
            if(trigger.isUpdate || (trigger.isDelete && !voliOldMap.containsKey(voliRec.Id))) {
                if(!voliRec.Is_Excess__c) {
                    needForVOLineItem += voliRec.Qty_Needed__c;
                } else {
                    excessRec = voliRec;
                    previousExcessNeed += voliRec.Qty_Needed__c;
                }
            }
        }
        if(voliGroupRec.Sublet__c != null) {
            voliGroupRec.Need__c = needForVOLineItem;
            return null;
        } else if(voliGroupRec.Part__c != null) {
            List<Part__c> partRecList = new List<Part__c>{new Part__c(Id = voliGroupRec.Part__c,
                                                                        Package_Qty__c = voliGroupRec.Part__r.Package_Qty__c,
                                                                        Order_Lots__c = voliGroupRec.Part__r.Order_Lots__c,
                                                                        Packaged_Part__c = voliGroupRec.Part__r.Packaged_Part__c)};
            //Topping Up In case of Packaged Part or Order Lots
            Decimal need = VendorOrderCtrl.toppingUpNeed(partRecList, needForVOLineItem);
            voliGroupRec.Need__c = need;

            if(excessRec.Id == null) {  
                excessRec = new Vendor_Order_Line_Item__c();
                excessRec.Part__c = voliGroupRec.Part__c;
                excessRec.Is_Excess__c = true; 
                excessRec.Vendor_Order_Header__c = voliGroupRec.Vendor_Order_Header__c;
                excessRec.Vendor_Order_Line_Item_Group__c = voliGroupRec.Id;
            } 
            excessRec.Qty_Needed__c = need - needForVOLineItem;

            // Update Parts Qty On Order 
            updatePartOrderedQty(true, voliGroupRec.Part__c, voliGroupRec.Part__r.Qty_On_Order__c, previousExcessNeed, excessRec.Qty_Needed__c);
        }
        return excessRec;
    }
    
    private static Part__c updatePartOrderedQty(Boolean isUpdate, Id partId, Decimal partQtyOnOrder, Decimal previousExcessNeed, Decimal newExcessNeed) {
        if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        Part__c partRec = new Part__c(Id = partId);
        partQtyOnOrder = (partQtyOnOrder != null) ? partQtyOnOrder : 0;
        previousExcessNeed = (previousExcessNeed != null) ? previousExcessNeed : 0;
        newExcessNeed = (newExcessNeed != null) ? newExcessNeed : 0;
        partRec.Qty_On_Order__c = partQtyOnOrder - previousExcessNeed + newExcessNeed;
        if(isUpdate) {
            update partRec;
        }
        return partRec;
    }
}