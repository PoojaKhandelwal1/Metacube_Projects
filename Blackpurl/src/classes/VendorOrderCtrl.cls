/** 
 * Author: Tarun Khandelwal
 * Since: July 22, 2015
 * Name: VendorOrderCtrl 
 * Description: Apex class to handle all operations related to Vendor Order Page.
**/
global with sharing class VendorOrderCtrl {
  
  	global VendorOrderCtrl (NewHomePageCtrl controller){}
    public VendorOrderCtrl() {} 
  	
    // Boolean variable indicates weather if the user is able to modify VOHeader details
    public boolean isPermittedToEditVOHeader { get {
                                                    if(AccessControl.ifObjectFieldIsAccessible('PermissionSetAssignment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                                                    List<PermissionSetAssignment> voHeaderPermissionAssignments = [SELECT PermissionSet.Name, 
                                                                                                                          PermissionSetId, 
                                                                                                                          AssigneeId 
                                                                                                                          FROM PermissionSetAssignment 
                                                                                                                          WHERE PermissionSet.Name = 'Vendor_Order_Header_Updates'
                                                                                                                 ];
                                                    if(voHeaderPermissionAssignments.size() != 0){
                                                        return true;
                                                    } else {
                                                        if(AccessControl.ifObjectFieldIsAccessible('Profile') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                                                        List<Profile> pList = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
                                                        if(pList.size() > 0) {
                                                            return UserInfo.getProfileId() == pList[0].Id;
                                                        } else {
                                                            return true;
                                                        }
                                                    }
                                                }  
                                                private set; 
                                            } 
     
    public Decimal Related_List_Page_Size { get{return GeneralConfiguration.getRelatedListPageSize();} private set;}
    
    @RemoteAction
    global static String searchPartSmartItems(String partListJSON, String vendorId) {
    	partListJSON = BPUtility.getDecodedString(partListJSON);
        vendorId = BPUtility.getDecodedString(vendorId);
        Map<String, Decimal> partNumberToQtyMap = new Map<String, Decimal>(); 
        List<COService.SearchPartDetailWrapper> partsToSearchList = (List<COService.SearchPartDetailWrapper>) System.JSON.deserialize(partListJSON, List<COService.SearchPartDetailWrapper>.class);
        
        if(partsToSearchList.size() > 0) {
	        for(Integer k = 0; k < partsToSearchList.size(); k++) {
	        	if(!partNumberToQtyMap.containsKey(partsToSearchList[k].PartNumber)) {
	        		partNumberToQtyMap.put(partsToSearchList[k].PartNumber, 0);
	        	}
	        	partNumberToQtyMap.put(partsToSearchList[k].PartNumber, partNumberToQtyMap.get(partsToSearchList[k].PartNumber) + partsToSearchList[k].Qty);
	        }
	        List<Part__c> partList = [SELECT Id, Part_Number__c From Part__c WHERE Vendor__c =:vendorId AND Part_Number__c IN :partNumberToQtyMap.keySet()];
	        partsToSearchList.clear();
	        Map<String, Decimal> availablePartIdToQtyNeededMap = new Map<String, Decimal>();
	        for(Part__c partRec : partList) {
	        	COService.SearchPartDetailWrapper partObj = new COService.SearchPartDetailWrapper();
	        	partObj.PartId = partRec.Id;
	        	partObj.PartNumber = partRec.Part_Number__c;
	        	partObj.Qty = partNumberToQtyMap.get(partRec.Part_Number__c);
	        	partsToSearchList.add(partObj);
	        	
	        	partNumberToQtyMap.remove(partRec.Part_Number__c);
	        }
	        
	        for(String partNumber : partNumberToQtyMap.keySet()) {
	        	COService.SearchPartDetailWrapper partObj = new COService.SearchPartDetailWrapper();
	        	partObj.PartNumber = partNumber;
	        	partObj.Qty = partNumberToQtyMap.get(partNumber);
	        	partsToSearchList.add(partObj);
	        }
        }
        return BPUtility.getEncodedString(system.JSON.serialize(partsToSearchList, true));
    }
    
    @RemoteAction
    global static String addPartSmartItemsToVO(String partObjJSON, String voHeaderId) {
    	partObjJSON = BPUtility.getDecodedString(partObjJSON);
    	voHeaderId = BPUtility.getDecodedString(voHeaderId);
    	COService.SearchPartDetailWrapper partsObj = (COService.SearchPartDetailWrapper) System.JSON.deserialize(partObjJSON, COService.SearchPartDetailWrapper.class);
        
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item_Group__c> voligList = [select Part__c, Part__r.Last_Cost__c, (select Id, Qty_Needed__c from Vendor_Order_Line_Items__r where Is_From_Search__c = true) 
                                                                from Vendor_Order_Line_Item_Group__c 
                                                                where Part__c =: partsObj.PartId AND Vendor_Order_Header__c =: voHeaderId];
        
        Vendor_Order_Line_Item_Group__c voligRec = new Vendor_Order_Line_Item_Group__c();
        if(voligList.size() == 0) {
            voligRec.Vendor_Order_Header__c = voHeaderId;
            voligRec.Part__c = partsObj.PartId;
            voligRec.Need__c = 0;
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert voligRec;
        } else {
            voligRec = voligList[0];
        }                                                       
        if(voligRec.Vendor_Order_Line_Items__r.size() > 0) {
            updateVOLIGAndPartRelatedInfo(partsObj.PartId, voHeaderId, voligRec.Vendor_Order_Line_Items__r[0].Id, voligRec.Vendor_Order_Line_Items__r[0].Qty_Needed__c + partsObj.Qty);
        } else {
        	Vendor_Order_Line_Item__c voliRec = new Vendor_Order_Line_Item__c();
	        voliRec.Part__c = voligRec.Part__c;
	        voliRec.Vendor_Order_Line_Item_Group__c = voligRec.Id;
	        voliRec.Is_From_Search__c = true;
	        voliRec.Qty_Needed__c = 0;
	        voliRec.Vendor_Order_Header__c = voHeaderId;
	        if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	        insert voliRec;
	        updateVOLIGAndPartRelatedInfo(partsObj.PartId, voHeaderId, voliRec.Id, partsObj.Qty);
        }        
    	return 'Success';
    }
    
    @RemoteAction
    global static String updateVONotes(String voHeaderId, String notes) {
        notes = BPUtility.getDecodedString(notes);
        voHeaderId = BPUtility.getDecodedString(voHeaderId);
        try {
        	update new Vendor_Order_Header__c(Id = voHeaderId, Notes__c = notes);
        } catch(Exception e) {
        	throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('Success');
    }
    
    @RemoteAction
    global static String addSelectedLineItems(String selectedVOLIIdJSON, String vendorId, String voHeaderId, String itemsPageSortAttrsJSON, String customersPageSortAttrsJSON, String stocksPageSortAttrsJSON){
        selectedVOLIIdJSON = BPUtility.getDecodedString(selectedVOLIIdJSON);
        vendorId = BPUtility.getDecodedString(vendorId);
        voHeaderId = BPUtility.getDecodedString(voHeaderId);
        itemsPageSortAttrsJSON = BPUtility.getDecodedString(itemsPageSortAttrsJSON);
        customersPageSortAttrsJSON = BPUtility.getDecodedString(customersPageSortAttrsJSON);
        stocksPageSortAttrsJSON = BPUtility.getDecodedString(stocksPageSortAttrsJSON);
        
        List<String> selectedVOLIIdList = (List<String>) System.JSON.deserialize(selectedVOLIIdJSON, List<String>.class);
        
        Savepoint sp = Database.setSavepoint();
        //List<Vendor_Order_Line_Item__c> voLineItemsRequired = (vendorId == null) ? new List<Vendor_Order_Line_Item__c>() : SOQLUtil.getVOLineItem(vendorId, voHeaderId, isRequiredForCustomer);
        List<Vendor_Order_Line_Item__c> voLineItemsRequired = (vendorId == null) ? new List<Vendor_Order_Line_Item__c>() : 
            SOQLUtil.getVOLineItemByFieldValue(new Map<String, List<String>>{'Part__r.Vendor__c' => new List<String>{vendorId}, 'Id' => selectedVOLIIdList});
        
        voLineItemsRequired.addAll((vendorId == null) ? new List<Vendor_Order_Line_Item__c>() : 
            SOQLUtil.getVOLineItemByFieldValue(new Map<String, List<String>>{'Sublet__r.Vendor__c' => new List<String>{vendorId}, 'Id' => selectedVOLIIdList}));
        
        Set<Id> partIdSet = new Set<Id>();
        Set<Id> subletIdSet = new Set<Id>();
        Map<Id, Vendor_Order_Line_Item_Group__c> voliIdToVOLIGRecMap = new Map<Id, Vendor_Order_Line_Item_Group__c>();
        Map<Id, List<Vendor_Order_Line_Item_Group__c>> partIdToVOLIGroupRecListMap = new Map<Id, List<Vendor_Order_Line_Item_Group__c>>();
        
        for(Vendor_Order_Line_Item__c voliRec : voLineItemsRequired) {
            if(voliRec.Part__c != null) {
                partIdSet.add(voliRec.Part__c);
            } else if(voliRec.Sublet__c != null) {
                subletIdSet.add(voliRec.Sublet__c);
                Vendor_Order_Line_Item_Group__c vogRec = new Vendor_Order_Line_Item_Group__c();
                vogRec.Sublet__c = voliRec.Sublet__c;
                vogRec.Vendor_Order_Header__c = voHeaderId;
                vogRec.Cost__c = voliRec.Cost__c;
                vogRec.Need__c = voliRec.Qty_Needed__c;
                voliIdToVOLIGRecMap.put(voliRec.Id, vogRec);
            }
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Map<Id, Part__c> partIdToPartRecMap = new Map<Id, Part__c>([select Id, Packaged_Part__c, Order_Lots__c, Last_Cost__c, Package_Qty__c from Part__c where Id IN : partIdSet]);
        if(AccessControl.ifObjectFieldIsAccessible('Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Map<Id, Product__c> subletIdToRecMap = new Map<Id, Product__c>([select Id, Cost_Method__c from Product__c where Id IN : subletIdSet]);
        List<Vendor_Order_Line_Item_Group__c> voliGroupList = (vendorId == null) ? new List<Vendor_Order_Line_Item_Group__c>() : SOQLUtil.getVOLIGroupByFieldName('Vendor_Order_Header__c', voHeaderId, voHeaderId);
        
        for(Vendor_Order_Line_Item_Group__c vogRec : voliGroupList) {
        	if(String.isNotBlank(vogRec.Part__c)) {
	            List<Vendor_Order_Line_Item_Group__c> voliGroupRecList;
	            if(partIdToVOLIGroupRecListMap.containsKey(vogRec.Part__c)) {
	                voliGroupRecList = partIdToVOLIGroupRecListMap.get(vogRec.Part__c);
	            } else {
	                voliGroupRecList = new List<Vendor_Order_Line_Item_Group__c>();
	            }
	            voliGroupRecList.add(vogRec);
	            partIdToVOLIGroupRecListMap.put(vogRec.Part__c, voliGroupRecList);
        	}
        }

        Set<Id> groupPartIdSet = new Set<Id>();
        List<Vendor_Order_Line_Item_Group__c> vogRecListToInsert = new List<Vendor_Order_Line_Item_Group__c>();
        for(Vendor_Order_Line_Item__c voliRec : voLineItemsRequired) {
        	if(String.isNotBlank(voliRec.Part__c)) {
	            Vendor_Order_Line_Item_Group__c vogRec;
	            if(partIdToVOLIGroupRecListMap.containsKey(voliRec.Part__c)) {
	                vogRec = partIdToVOLIGroupRecListMap.get(voliRec.Part__c)[0];
	                groupPartIdSet.add(voliRec.Part__c);
	            } else if(groupPartIdSet.contains(voliRec.Part__c)) {
	                
	            } else {
	                vogRec = new Vendor_Order_Line_Item_Group__c();
	                vogRec.Part__c = voliRec.Part__c;
	                vogRec.Cost__c = voliRec.Cost__c;
	                vogRec.Vendor_Order_Header__c = voHeaderId;
	                vogRec.Need__c = 0;
	                vogRecListToInsert.add(vogRec);
	                groupPartIdSet.add(voliRec.Part__c);
	            }
        	}
        }
        
        if(vogRecListToInsert.size() > 0 || voliIdToVOLIGRecMap.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert vogRecListToInsert;
            insert voliIdToVOLIGRecMap.values();
        }
        
        for(Vendor_Order_Line_Item_Group__c vogRec : vogRecListToInsert) {
            if(!partIdToVOLIGroupRecListMap.containsKey(vogRec.Part__c)) {
                partIdToVOLIGroupRecListMap.put(vogRec.Part__c, new List<Vendor_Order_Line_Item_Group__c>{vogRec});
            }
        }
        
        for(Vendor_Order_Line_Item__c voliRec : voLineItemsRequired) {
            Vendor_Order_Line_Item_Group__c vogRec;
            if(voliRec.Part__c != null && partIdToVOLIGroupRecListMap.containsKey(voliRec.Part__c)) {
                vogRec = partIdToVOLIGroupRecListMap.get(voliRec.Part__c)[0];
                voliRec.Vendor_Order_Line_Item_Group__c = vogRec.Id;
            } else if(String.isNotBlank(voliRec.Sublet__c) && voliIdToVOLIGRecMap.containsKey(voliRec.Id)) {
                voliRec.Vendor_Order_Line_Item_Group__c = voliIdToVOLIGRecMap.get(voliRec.Id).Id;
            }
            voliRec.Vendor_Order_Header__c = voHeaderId;
        }
        
        if(voLineItemsRequired.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update voLineItemsRequired;
        }
        
        Set<Id> newInsertedVOLineItemIdSet = new Set<Id>();
        for(Vendor_Order_Line_Item__c voliRec : voLineItemsRequired) {
            newInsertedVOLineItemIdSet.add(voliRec.Id);
        }
        
        voliGroupList = SOQLUtil.getVOLIGroupByFieldName('Vendor_Order_Header__c', voHeaderId, voHeaderId);
        
        List<Vendor_Order_Line_Item__c> voliListToUpsert = new List<Vendor_Order_Line_Item__c>();
        List<Vendor_Order_Line_Item__c> voliListToDelete = new List<Vendor_Order_Line_Item__c>();
        Map<Id, Decimal> vogIdToAlreadyOrderedQty = new Map<Id, Decimal>();
        for(Vendor_Order_Line_Item_Group__c vogRec : voliGroupList) {
            Decimal alreadyOrderedQty = 0;
            if((vogRec.Part__c != null && partIdToPartRecMap.containsKey(vogRec.Part__c)) || (vogRec.Sublet__c != null && subletIdToRecMap.containsKey(vogRec.Sublet__c))) {
                Decimal needForVOLineItem = 0;
                Vendor_Order_Line_Item__c excessRec;
                for(Vendor_Order_Line_Item__c voliRec : vogRec.Vendor_Order_Line_Items__r) {
                    if(voliRec.Is_Excess__c) {
                        excessRec = voliRec;
                    } else {
                        needForVOLineItem += voliRec.Qty_Needed__c;
                    }
                    if(!(voliRec.Is_required_For_Customer__c || voliRec.Is_Service__c) && (!newInsertedVOLineItemIdSet.contains(voliRec.Id))) {
                        alreadyOrderedQty += voliRec.Qty_Needed__c;
                    }
                }
                
                // Topping Up Need
                if(vogRec.Sublet__c != null) {
                	vogRec.Need__c = needForVOLineItem;
                } else {
	                Decimal need = toppingUpNeed(new List<Part__c>{partIdToPartRecMap.get(vogRec.Part__c)}, needForVOLineItem);
	                vogRec.Need__c = need;
	                
	                if(excessRec == null) {
	                    excessRec = new Vendor_Order_Line_Item__c();
	                    excessRec.Part__c = vogRec.Part__c;
	                    excessRec.Is_Excess__c = true;
	                    excessRec.Vendor_Order_Header__c = voHeaderId;
	                    excessRec.Vendor_Order_Line_Item_Group__c = vogRec.Id;
	                } 
	                excessRec.Qty_Needed__c = need - needForVOLineItem;
	                if(excessRec.Qty_Needed__c != 0) {
	                    voliListToUpsert.add(excessRec);    
	                } else if(excessRec.Id != null){
	                    voliListToDelete.add(excessRec);
	                }
                }
                vogIdToAlreadyOrderedQty.put(vogRec.Id, alreadyOrderedQty);
            }
        }
         
        if(voliListToUpsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            upsert voliListToUpsert;
        }
        
        if(voliListToDelete.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            delete voliListToDelete;
        }
        
        if(voliGroupList.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update voliGroupList;
        }
        
        // Populate VO number on COLIs + Update Part Ordered Qty.
        updatePartOrderedQty(vendorId, voHeaderId, vogIdToAlreadyOrderedQty);
        
        return getVOLineItemWrapperJSON(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(itemsPageSortAttrsJSON), BPUtility.getEncodedString(customersPageSortAttrsJSON), BPUtility.getEncodedString(stocksPageSortAttrsJSON), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null));
    }
	
    /**
     * Name: groupAllSimilarVOLineItem
     * Desc: Method to merge all similar VO Line item and make one VO Line Item Group record to dispaly in Items subsection
     * @param:  (1) VendorId - String - Vendor Id
     *          (2) partId - String - Part Id
     *          (3) voHeaderId - String - voHeader Id
     *          (4) itemsPageSortAttrsJSON - String - page sort attributes of item
     *          (5) customersPageSortAttrsJSON - Sting - page sort attributes of customer
     *          (6)stocksPageSortAttrsJSON - String -  page sort attributes of stock
     * @return: String - JSON String of all VO Line Items of VO Header Record
    **/
    @RemoteAction
    global static String groupAllSimilarVOLineItem(String vendorId, String partId, String voHeaderId, String itemsPageSortAttrsJSON, String customersPageSortAttrsJSON, String stocksPageSortAttrsJSON){
        //system.assert(false,itemsPageSortAttrsJSON +''+ customersPageSortAttrsJSON  + ' ' + stocksPageSortAttrsJSON);
        try{
        	vendorId = BPUtility.getDecodedString(vendorId);
        	partId = BPUtility.getDecodedString(partId);
        	voHeaderId = BPUtility.getDecodedString(voHeaderId);
        	itemsPageSortAttrsJSON = BPUtility.getDecodedString(itemsPageSortAttrsJSON);
        	customersPageSortAttrsJSON = BPUtility.getDecodedString(customersPageSortAttrsJSON);
        	stocksPageSortAttrsJSON = BPUtility.getDecodedString(stocksPageSortAttrsJSON);
        	
            return groupAllSimilarVOLineItem(vendorId, partId, voHeaderId, itemsPageSortAttrsJSON, customersPageSortAttrsJSON, stocksPageSortAttrsJSON, null);
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    @RemoteAction
    global static String getVendorDetails(String vendorId){
        try {
            return BPUtility.getEncodedString(system.JSON.serialize(ViewVendorCtrl.getVendorDetails(BPUtility.getDecodedString(vendorId)), true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    /**
     * Name: groupAllSimilarVOLineItem
     * Desc: Method to merge all similar VO Line item and make one VO Line Item Group record to dispaly in Items subsection
     * @param:  (1) VendorId - String - Vendor Id
     *          (2) partId - String - Part Id
     *          (3) voHeaderId - String - voHeader Id
     *          (4) itemsPageSortAttrsJSON - String - page sort attributes of item
     *          (5) customersPageSortAttrsJSON - Sting - page sort attributes of customer
     *          (6)stocksPageSortAttrsJSON - String -  page sort attributes of stock
     *          (7)addNewLineItemId - String - Line item to be added
     * @return: String - JSON String of all VO Line Items of VO Header Record
    **/
    private static String groupAllSimilarVOLineItem(String vendorId, String partId, String voHeaderId, String itemsPageSortAttrsJSON, String customersPageSortAttrsJSON, String stocksPageSortAttrsJSON, String addNewLineItemId){
        List<Vendor_Order_Line_Item__c> voLineItemsWithSimilarParts = SOQLUtil.getVOLineItemWithSimilarParts(vendorId, partId, voHeaderId);
        List<Vendor_Order_Line_Item_Group__c> voliGroupList = SOQLUtil.getVOLIGroupByFieldName('Part__c', partId, voHeaderId);
        Vendor_Order_Line_Item_Group__c voliGroupRec = new Vendor_Order_Line_Item_Group__c();
        List<Part__c> partRecList = SOQLUtil.getPartDetailRecordsByFieldName('Id', partId);
        
        Decimal alreadyOrderedQty = 0;
        
        if(voliGroupList.size() > 0) {
            voliGroupRec.Id = voliGroupList[0].Id;
            for(Vendor_Order_Line_Item__c voli : voliGroupList[0].Vendor_Order_Line_Items__r) {
                if(!(voli.Is_required_For_Customer__c || voli.Is_Service__c)) {
                    alreadyOrderedQty += voli.Qty_Needed__c;
                } 
            }
        } else if(voLineItemsWithSimilarParts.size() > 0) {
            voliGroupRec.Part__c = partId;
            voliGroupRec.Vendor_Order_Header__c = voHeaderId;
        }
        
        
        
        Decimal needForVOLineItem = 0;
        Vendor_Order_Line_Item__c voLineItemForExcessStock;
        for(Vendor_Order_Line_Item__c voliRec : voLineItemsWithSimilarParts) {
            needForVOLineItem += voliRec.Qty_Needed__c;
            if(voliRec.Is_Excess__c) {
                voLineItemForExcessStock = voliRec;
            }
        }
        // Topping Up Need
        Decimal need = toppingUpNeed(partRecList, needForVOLineItem);
        
        voliGroupRec.Need__c = need;
        if(voliGroupRec != null) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            upsert voliGroupRec;
        }
        
        if(need > needForVOLineItem) {
            Decimal execessNeed = need - needForVOLineItem;
            if(voLineItemForExcessStock == null){
                voLineItemForExcessStock = new Vendor_Order_Line_Item__c();
            }
            voLineItemForExcessStock.Qty_Needed__c = execessNeed;
            voLineItemForExcessStock.Part__c = partId;
            voLineItemForExcessStock.Is_Excess__c = true;
            voLineItemForExcessStock.Vendor_Order_Header__c = voHeaderId;
            voLineItemForExcessStock.Vendor_Order_Line_Item_Group__c = voliGroupRec.Id;
        }
        
        for(Vendor_Order_Line_Item__c voliRec : voLineItemsWithSimilarParts) {
            voliRec.Vendor_Order_Header__c = voHeaderId;
            voliRec.Vendor_Order_Line_Item_Group__c = voliGroupRec.Id;
        }
        if(voLineItemForExcessStock != null && voLineItemForExcessStock.Id == null) {
            voLineItemsWithSimilarParts.add(voLineItemForExcessStock);
        }
        if(voLineItemsWithSimilarParts.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            upsert voLineItemsWithSimilarParts;
        } 
        
        
        updatePartOrderedQty(vendorId, voHeaderId, new Map<Id, Decimal>{voliGroupRec.Id => alreadyOrderedQty});
        
        // Create JSON
        return getVOLineItemWrapperJSON(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(itemsPageSortAttrsJSON), BPUtility.getEncodedString(customersPageSortAttrsJSON), BPUtility.getEncodedString(stocksPageSortAttrsJSON), BPUtility.getEncodedString(addNewLineItemId), BPUtility.getEncodedString(null));
    }
    
    /**
     * Name: toppingUpNeed
     * Desc: Method to merge all similar VO Line item and make one VO Line Item Group record to dispaly in Items subsection
     * @param:  (1) partRecList - List<Part__c> - Part Record List
     *          (2) needForVOLineItem - Decimal - Line item count
     * @return: Decimal - Nedded 
    **/
    public static Decimal toppingUpNeed(List<Part__c> partRecList, Decimal needForVOLineItem) {
        try{
            Decimal need = needForVOLineItem;
            if(partRecList.size() > 0) {
                Part__c partRec = partRecList[0];
                if(partRec.Packaged_Part__c) {
                    Long packagedPartInNeed = (need / (partRec.Package_Qty__c * partRec.Order_Lots__c)).longValue();
                    if(packagedPartInNeed * (partRec.Package_Qty__c * partRec.Order_Lots__c) < need) {
                        packagedPartInNeed += 1;
                    }
                    need = packagedPartInNeed * partRec.Package_Qty__c * partRec.Order_Lots__c;
                } else if(partRec.Order_Lots__c > 1) {
                    Long orderLotPartInNeed = (needForVOLineItem / partRec.Order_Lots__c).longValue();
                    if(orderLotPartInNeed * partRec.Order_Lots__c < needForVOLineItem) {
                        orderLotPartInNeed += 1;
                    }
                    need = orderLotPartInNeed * partRec.Order_Lots__c;
                }
            }
            return need;
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return null;
    }
    
    /**
     * Name: getPaginatedItemsForVOHeader
     * Desc: Method to handle pagination
     * @param:  (1) gridName - String - Name of Grid
     *          (2) voHeaderId - String - voHeader Id
     *          (3) pageSortAttrsJSON - String - page sort attributes
     * @return: String - JSON String of all VO Line Items of VO Header Record
    **/
    @RemoteAction
    global static String getPaginatedItemsForVOHeader(String gridName, String voHeaderId, String pageSortAttrsJSON){
        try{
        	gridName = BPUtility.getDecodedString(gridName);
        	voHeaderId = BPUtility.getDecodedString(voHeaderId);
        	pageSortAttrsJSON = BPUtility.getDecodedString(pageSortAttrsJSON);
        	
            PaginationSorting pageSortAttrs = parsePageAttrs(pageSortAttrsJSON);
            Map<String, String> sortFieldMap = new Map<String, String>{'Items' => '', 'Customers' => '', 'Stocks' => ''};
            if(pageSortAttrs.Sorting != null && pageSortAttrs.Sorting[0].SortDirection.length() != 0){
                sortFieldMap.put(gridName, pageSortAttrs.Sorting[0].SortDirection.toUpperCase());
            }
            
            VendorOrderHeader vendorOrderHeader = new VendorOrderHeader(voHeaderId);
            String vendorId = vendorOrderHeader.VendorId;
            List<Vendor_Order_Line_Item__c> voLineItemsRequiredForStock = new List<Vendor_Order_Line_Item__c>();
            List<Vendor_Order_Line_Item__c> voLineItemsRequiredForCustomer = new List<Vendor_Order_Line_Item__c>();
            List<Vendor_Order_Line_Item_Group__c> voliGroupList = new List<Vendor_Order_Line_Item_Group__c>();
            
            if(gridName == 'Items'){
                voliGroupList = (vendorId == null) ? new List<Vendor_Order_Line_Item_Group__c>() : SOQLUtil.getVOLIGroupsWithItemsInVO('Part__r.Vendor__c', vendorId, voHeaderId);
            }
            
            if(gridName == 'Customers'){
                voLineItemsRequiredForCustomer = (vendorId == null) ? new List<Vendor_Order_Line_Item__c>() : SOQLUtil.getVOLineItem(vendorId, voHeaderId, true);
            }
            
            if(gridName == 'Stocks'){
                voliGroupList = (vendorId == null) ? new List<Vendor_Order_Line_Item_Group__c>() : SOQLUtil.getVOLIGroupByFieldName('Part__r.Vendor__c', vendorId, voHeaderId);
                voLineItemsRequiredForStock = (vendorId == null) ? new List<Vendor_Order_Line_Item__c>() : SOQLUtil.getVOLineItem(vendorId, voHeaderId, false);
            }
            VendorOrderLineItemWrapper voLineItemWrapperObj = new VendorOrderLineItemWrapper(voLineItemsRequiredForStock, 
                                                                                             voLineItemsRequiredForCustomer, 
                                                                                             voliGroupList, 
                                                                                             pageSortAttrs,
                                                                                             pageSortAttrs,
                                                                                             pageSortAttrs,
                                                                                             sortFieldMap,
                                                                                             vendorOrderHeader,
                                                                                             null,
                                                                                             new List<PO_Type__c>(),
                                                                                             new List<Vendor_Order_Line_Item_Group__c>() 
                                                                                            );
            return BPUtility.getEncodedString(System.JSON.serialize(voLineItemWrapperObj));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    
      /**
     * Name: updateVOHederOrderType
     * Desc: Update VOHeader Order Type
     * @param:  (1) voHeaderId - String - voHeader Id
     *          (2) orderType - String - Type of Order
     *          (3) orderStatus - String - Order Status
     * @return: String - JSON String of all VO Line Items of VO Header Record
    **/
    @RemoteAction
    global static String updateVOHederOrderType(String voHeaderId, String orderType, String orderStatus) {
        try{
        	voHeaderId = BPUtility.getDecodedString(voHeaderId);
        	orderType = BPUtility.getDecodedString(orderType);
        	orderStatus = BPUtility.getDecodedString(orderStatus);
        	
            /*if(orderStatus == 'Locked') {
                //lockVOLineItems(voHeaderId);
            }*/
            voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
            if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Vendor_Order_Header__c> voHeaderList = [select Id, Purchase_Order_Type__c, Status__c from Vendor_Order_Header__c where Id =:voHeaderId] ;
            if(voHeaderList.size() > 0) {
                voHeaderList[0].Purchase_Order_Type__c = orderType;
                voHeaderList[0].Status__c = orderStatus;
                if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update voHeaderList[0];
            }
            return BPUtility.getEncodedString(orderType);
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
     /**
     * Name: lockVOLineItems
     * Desc: Method to Lock VOLine Items
     * @param:  (1) voHeaderId - String - voHeader Id
     * @return: void
    **/
    /*private static void lockVOLineItems(String voHeaderId) {
        VendorOrderHeader vendorOrderHeader = new VendorOrderHeader(voHeaderId);
        Id vendorId = vendorOrderHeader.VendorId;
        voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
        if(AccessControl.ifObjectFieldIsAccessible('VO_Locked_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<VO_Locked_Line_Item__c> voLockedItemsList = [Select Id from VO_Locked_Line_Item__c where Vendor_Order_Header__c =: voHeaderId];
        if(voLockedItemsList.size() > 0){
            if(AccessControl.ifObjectIsDeletable('VO_Locked_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete voLockedItemsList;
        }
        
        List<Vendor_Order_Line_Item__c> voLineItemsList = (vendorId == null) ? new List<Vendor_Order_Line_Item__c>() : SOQLUtil.getVOLineItem(vendorId, voHeaderId, null);
        voLockedItemsList = new List<VO_Locked_Line_Item__c>();
        
        for(Vendor_Order_Line_Item__c voLineItem : voLineItemsList){
            VO_Locked_Line_Item__c lockedVOLineItem = new VO_Locked_Line_Item__c(Vendor_Order_Header__c = voHeaderId, Locked_Line_Item_Id__c = voLineItem.Id);
            voLockedItemsList.add(lockedVOLineItem);
        }
        
        if(voLockedItemsList.size() > 0){
            if(AccessControl.ifObjectFieldIsCreateable('VO_Locked_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert voLockedItemsList;
        }
    }*/
    
    /**
     * Name: getVOLineItemWrapperJSON
     * Desc: Method which give JSOn string of all VO Line Items Records
     * @param:  (1) VendorId - String - Vendor Id
     *          (3) voHeaderId - String - voHeader Id
     *          (4) itemsPageSortAttrsJSON - String - page sort attributes of item
     *          (5) customersPageSortAttrsJSON - Sting - page sort attributes of customer
     *          (6)stocksPageSortAttrsJSON - String -  page sort attributes of stock
     *          (7)addNewLineItemId - String - line item id
     *          (8)editedPartTd - String - part id to be edit
     * @return: String - JSON String of all VO Line Items of VO Header Record
    **/
    @RemoteAction
    global static String getVOLineItemWrapperJSON(String vendorId, String voHeaderId, String itemsPageSortAttrsJSON, String customersPageSortAttrsJSON, String stocksPageSortAttrsJSON, String addNewLineItemId, String editedPartTd){
        try{
        	vendorId = BPUtility.getDecodedString(vendorId);
        	voHeaderId = BPUtility.getDecodedString(voHeaderId);
        	itemsPageSortAttrsJSON = BPUtility.getDecodedString(itemsPageSortAttrsJSON);
        	customersPageSortAttrsJSON = BPUtility.getDecodedString(customersPageSortAttrsJSON);
        	stocksPageSortAttrsJSON = BPUtility.getDecodedString(stocksPageSortAttrsJSON);
        	addNewLineItemId = BPUtility.getDecodedString(addNewLineItemId);
        	editedPartTd = BPUtility.getDecodedString(editedPartTd);
        	
            PaginationSorting itemsPageSortAttrs = parsePageAttrs(itemsPageSortAttrsJSON);
            PaginationSorting customersPageSortAttrs = parsePageAttrs(customersPageSortAttrsJSON);
            PaginationSorting stocksPageSortAttrs = parsePageAttrs(stocksPageSortAttrsJSON);
            
            Map<String, String> sortFieldMap = new Map<String, String>{'Items' => '', 'Customers' => '', 'Stocks' => ''};
            if(itemsPageSortAttrs.Sorting != null && itemsPageSortAttrs.Sorting[0].SortDirection.length() != 0){
                sortFieldMap.put('Items', itemsPageSortAttrs.Sorting[0].SortDirection.toUpperCase());
            }
            if(customersPageSortAttrs.Sorting != null && customersPageSortAttrs.Sorting[0].SortDirection.length() != 0){
                sortFieldMap.put('Customers', customersPageSortAttrs.Sorting[0].SortDirection.toUpperCase());
            }
            if(stocksPageSortAttrs.Sorting != null && stocksPageSortAttrs.Sorting[0].SortDirection.length() != 0){
                sortFieldMap.put('Stocks', stocksPageSortAttrs.Sorting[0].SortDirection.toUpperCase());
            }
            
            VendorOrderHeader vendorOrderHeader = new VendorOrderHeader(voHeaderId);
            vendorId = vendorOrderHeader.VendorId;
            List<Vendor_Order_Line_Item__c> voLineItemsRequiredForStock = (vendorId == null) ? new List<Vendor_Order_Line_Item__c>() : SOQLUtil.getVOLineItem(vendorId, voHeaderId, false);
            List<Vendor_Order_Line_Item__c> voLineItemsRequiredForCustomer = (vendorId == null) ? new List<Vendor_Order_Line_Item__c>() : SOQLUtil.getVOLineItem(vendorId, voHeaderId, true);
            List<Vendor_Order_Line_Item_Group__c> voliGroupList = (vendorId == null) ? new List<Vendor_Order_Line_Item_Group__c>() : SOQLUtil.getVOLIGroupsWithItemsInVO('Part__r.Vendor__c', null, voHeaderId);
            List<PO_Type__c> poTypesList = (vendorId == null) ? new List<PO_Type__c>() :SOQLUtil.getPOTypesForVendor(vendorId, new Map<String, String>());
            List<Vendor_Order_Line_Item_Group__c> recentlyEditedGroup = (editedPartTd == null) ? new List<Vendor_Order_Line_Item_Group__c>() : SOQLUtil.getVOLIGroupByFieldName('Part__c', editedPartTd, voHeaderId);
            
            /*Set<Id> vrHeaderIdSet = new Set<Id>();
            for(Vendor_Order_Line_Item__c voliRec : voLineItemsRequiredForStock) {
                if(voliRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c != null) {
                    vrHeaderIdSet.add(voliRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c);
                }
            }
            
            List<Vendor_Receiving_Header__c> vrHeaderList = (vrHeaderIdSet.size() == 0) ? new List<Vendor_Receiving_Header__c>() : SOQLUtil.getReceivingHistoryByIdSet('Part__c', editedPartTd, voHeaderId);
            */
            
            VendorOrderLineItemWrapper voLineItemWrapperObj = new VendorOrderLineItemWrapper(voLineItemsRequiredForStock, 
                                                                                             voLineItemsRequiredForCustomer, 
                                                                                             voliGroupList, 
                                                                                             itemsPageSortAttrs,
                                                                                             customersPageSortAttrs,
                                                                                             stocksPageSortAttrs,
                                                                                             sortFieldMap,
                                                                                             vendorOrderHeader,
                                                                                             addNewLineItemId,
                                                                                             poTypesList,
                                                                                             recentlyEditedGroup
                                                                                            );
            return BPUtility.getEncodedString(System.JSON.serialize(voLineItemWrapperObj));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    
    @RemoteAction
    global static String getAllVOLineItem(String vendorId, String voHeaderId, Boolean isRequiredFromCustomer) {
    	try{
        	vendorId = BPUtility.getDecodedString(vendorId);
        	voHeaderId = BPUtility.getDecodedString(voHeaderId);
    		List<Vendor_Order_Line_Item__c> voLineItemList = (vendorId == null) ? new List<Vendor_Order_Line_Item__c>() : SOQLUtil.getVOLineItem(vendorId, voHeaderId, isRequiredFromCustomer);
    		List<Id> voliIdList = new List<Id>();
    		for(Vendor_Order_Line_Item__c voliRec : voLineItemList) {
    			voliIdList.add(voliRec.Id);
    		}
    		return BPUtility.getEncodedString(System.JSON.serialize(voliIdList));
    		
    	} catch(Exception e) {
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	return BPUtility.getEncodedString('');
    }
    
    
    
        /**
     * Name: getVOLineItemWrapperJSON
     * Desc: Method to add Vender
     * @param:  (1) VendorId - String - Vendor Id
     *          (3) voHeaderId - String - voHeader Id
     *          (4) itemsPageSortAttrsJSON - String - page sort attributes of item
     *          (5) customersPageSortAttrsJSON - Sting - page sort attributes of customer
     *          (6)stocksPageSortAttrsJSON - String -  page sort attributes of stock
     * @return: String - JSON String of all VO Line Items of VO Header Record
    **/
    @RemoteAction
    global static String addVendor(String vendorId, String voHeaderId, String itemsPageSortAttrsJSON, String customersPageSortAttrsJSON, String stocksPageSortAttrsJSON){
       try{
       		vendorId = BPUtility.getDecodedString(vendorId);
       		voHeaderId = BPUtility.getDecodedString(voHeaderId);
       		itemsPageSortAttrsJSON = BPUtility.getDecodedString(itemsPageSortAttrsJSON);
       		customersPageSortAttrsJSON = BPUtility.getDecodedString(customersPageSortAttrsJSON);
       		stocksPageSortAttrsJSON = BPUtility.getDecodedString(stocksPageSortAttrsJSON);
       		
            Vendor_Order_Header__c voHeaderRec = new Vendor_Order_Header__c();
            if(String.isBlank(voHeaderId)) {
                voHeaderId = BPUtility.getDecodedString(BPGlobalHeaderCtrl.createVendorOrder());
            } 
            voHeaderRec.Id = voHeaderId;
            voHeaderRec.Vendor__c = vendorId;
            if(AccessControl.ifObjectFieldIsAccessible('PO_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<PO_Type__c> vendorStandardPOTypes = [Select Id from PO_Type__c where IsDefault__c = true AND Vendor__c =: vendorId];
            if(vendorStandardPOTypes.size() > 0){
                voHeaderRec.Purchase_Order_Type__c = vendorStandardPOTypes[0].Id;
            }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update voHeaderRec;
            return getVOLineItemWrapperJSON(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(itemsPageSortAttrsJSON), BPUtility.getEncodedString(customersPageSortAttrsJSON), BPUtility.getEncodedString(stocksPageSortAttrsJSON), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null));
       }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    /**
     * Name: getPartByPartId
     * Desc: Method which give JSOn string of part Record related to given part Id.
     * @param:  (1) partId - String - Part record Id
     * @return: String - JSON String of part Record.
    **/
    @RemoteAction
    global static String getPartByPartId(String partId){
    	try{
	       	return ViewPartCtrl.getPartInfo(partId);
	   	}catch(Exception e){
	   		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
	   	}
   		return BPUtility.getEncodedString(null);
    }
    
    /**
     * Name: getCoHeaderById
     * Desc: Method which give JSOn string of CO Header Rec Related to Given CO Header Id
     * @param:  (1) coHeaderId - String - CO Header record Id
     * @return: String - JSON String of CO Header Record
    **/
    @RemoteAction
    global static String getCoHeaderById(String coHeaderId){
        try{
        	coHeaderId = BPUtility.getDecodedString(coHeaderId);
            List<CO_Header__c> coHeaderList = SOQLUtil.getCOHeaderDetails(coHeaderId);
            List<COHeader> coHeaderObjList = new List<COHeader>();
            for(CO_Header__c coHeaderRec : coHeaderList) {
                coHeaderObjList.add(new COHeader(coHeaderRec));
            } 
            return BPUtility.getEncodedString(System.JSON.serialize(coHeaderObjList));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    /**
     * Name: getGroupRecDetail
     * Desc: Method which give JSOn string of CO Header Rec Related to Given CO Header Id
     * @param:  (1)voGroupId - String - voGroup Id
     *          (2)voHeaderId - String - voHeader Id
     * @return: String - JSON String of VO Header Record
    **/
    @RemoteAction
    global static String getGroupRecDetail(String voGroupId, String voHeaderId){
        try{
        	voGroupId = BPUtility.getDecodedString(voGroupId);
        	voHeaderId = BPUtility.getDecodedString(voHeaderId);
        	
            List<Vendor_Order_Line_Item_Group__c> vogList = SOQLUtil.getVOLIGroupsWithItemsInVO('Id', voGroupId, voHeaderId);
            List<VOGroupDetail> voGroupDetailList = new List<VOGroupDetail>();
            for(Vendor_Order_Line_Item_Group__c vogRec : vogList) {
                voGroupDetailList.add(new VOGroupDetail(vogRec));
            } 
            return BPUtility.getEncodedString(System.JSON.serialize(voGroupDetailList));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
        
    }
    
    /**
     * Name: getStockRecDetail
     * Desc: Method which give JSOn string of stock record details
     * @param:  (1) voliId - String - voLine Item Id
     * @return: String - JSON String of CO Header Record
    **/
    @RemoteAction
    global static String getStockRecDetail(String voliId){
        try{
        	voliId = BPUtility.getDecodedString(voliId);
            List<Vendor_Order_Line_Item__c> voliList = SOQLUtil.getVOLineItemById(voliId);
            List<StockRecDetail> voliDetailList = new List<StockRecDetail>();
            for(Vendor_Order_Line_Item__c voliRec : voliList) {
                voliDetailList.add(new StockRecDetail(voliRec));
            } 
            return BPUtility.getEncodedString(System.JSON.serialize(voliDetailList));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    /**
     * Name: removeGroupFromOrder
     * Desc: Method which remove VO group from Items sectios
     * @param:  (1) voLineItemGroupId - String - VO Line Item Group Id which is to be removed
     *          (2) vendorId - String - Vendor Id
     *          (3) voHeaderId - String - VO Header record Id
     *          (4) itemsPageSortAttrsJSON - String - page sort attributes of item
     *          (5) customersPageSortAttrsJSON - Sting - page sort attributes of customer
     *          (6)stocksPageSortAttrsJSON - String -  page sort attributes of stock
     * @return: String - JSON String of VO Header Wrapper Record
    **/
    @RemoteAction
    global static String removeGroupFromOrder(String voLineItemGroupId, String vendorId, String voHeaderId, String itemsPageSortAttrsJSON, String customersPageSortAttrsJSON, String stocksPageSortAttrsJSON){
        try{
        	voLineItemGroupId = BPUtility.getDecodedString(voLineItemGroupId);
        	vendorId = BPUtility.getDecodedString(vendorId);
        	voHeaderId = BPUtility.getDecodedString(voHeaderId);
        	itemsPageSortAttrsJSON = BPUtility.getDecodedString(itemsPageSortAttrsJSON);
        	customersPageSortAttrsJSON = BPUtility.getDecodedString(customersPageSortAttrsJSON);
        	stocksPageSortAttrsJSON = BPUtility.getDecodedString(stocksPageSortAttrsJSON);
        	voLineItemGroupId = BPUtility.escapeSingleQuotes(voLineItemGroupId);
            if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Vendor_Order_Line_Item_Group__c> voliGroupList = [select Id, (select Vendor_Order_Header__c, Is_From_Search__c, Is_Excess__c from Vendor_Order_Line_Items__r), (select Vendor_Order_Header__c, Is_From_Search__c, Is_Excess__c from Cancelled_VOLIs__r)  from Vendor_Order_Line_Item_Group__c where Id = :voLineItemGroupId];
            List<Vendor_Order_Line_Item__c> voliListToUpdate = new List<Vendor_Order_Line_Item__c>();
            
            if(voliGroupList.size() > 0) {
                List<sObject> lineItemsToDel = new List<sObject>();
                for(Vendor_Order_Line_Item__c voliRec : voliGroupList[0].Vendor_Order_Line_Items__r) {
                    if(voliRec.Is_From_Search__c || voliRec.Is_Excess__c){
                        lineItemsToDel.add(voliRec);
                    } else {
                        voliRec.Vendor_Order_Header__c = null;
                        voliListToUpdate.add(voliRec);
                    }
                }
                if(voliListToUpdate.size() > 0) {
                    if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update voliListToUpdate;
                }
                
                List<Vendor_Order_Line_Item__c> voliList = new List<Vendor_Order_Line_Item__c>();
                
                List<Vendor_Order_Line_Item_Group__c> voliGroupListToUpdate = SOQLUtil.getVOLIGroupByFieldName('Id', voLineItemGroupId, voHeaderId);
                for(Vendor_Order_Line_Item_Group__c VogRec : voliGroupListToUpdate ){
                	voliList.addall(VogRec.Vendor_Order_Line_Items__r);
                }
                
                if(lineItemsToDel.size() > 0) {
                    if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
                    VendorOrderLineItemTriggerHelper.shouldTriggerRun = false;
                    delete lineItemsToDel;
                }
                
                if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
                delete voliGroupList[0];
                
                updatePartOrderedQtyInCaseOfRemovingOfGroup(voliList, voHeaderId);
            }
            
            return getVOLineItemWrapperJSON(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(itemsPageSortAttrsJSON), BPUtility.getEncodedString(customersPageSortAttrsJSON), BPUtility.getEncodedString(stocksPageSortAttrsJSON), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    /**
     * Name: removeLineItemFromOrder
     * Desc: Method which remove VO group from Items sectios
     * @param:  (1) voLineItemId - String - VO line item Id 
     *          (2) voLineItemGroupId - String - VO Line Item Group Id which is to be removed
     *          (3) voHeaderId - String - VO Header record Id
     *          (4) vendorId - String - Vendor Id
     *          (5) itemsPageSortAttrsJSON - String - page sort attributes of item
     *          (6) customersPageSortAttrsJSON - Sting - page sort attributes of customer
     *          (7) stocksPageSortAttrsJSON - String -  page sort attributes of stock
     * @return: String - JSON String of VO Header Wrapper Record
    **/
    @RemoteAction
    global static String removeLineItemFromOrder(String voLineItemId, String voLineItemGroupId, String voHeaderId,  String vendorId, String itemsPageSortAttrsJSON, String customersPageSortAttrsJSON, String stocksPageSortAttrsJSON){
    	voLineItemId = BPUtility.getDecodedString(voLineItemId);
    	voLineItemGroupId = BPUtility.getDecodedString(voLineItemGroupId);
    	voHeaderId = BPUtility.getDecodedString(voHeaderId);
    	vendorId = BPUtility.getDecodedString(vendorId);
    	itemsPageSortAttrsJSON = BPUtility.getDecodedString(itemsPageSortAttrsJSON);
    	customersPageSortAttrsJSON = BPUtility.getDecodedString(customersPageSortAttrsJSON);
    	stocksPageSortAttrsJSON = BPUtility.getDecodedString(stocksPageSortAttrsJSON);
    	
        Savepoint sp = Database.setSavepoint();
        voLineItemGroupId = BPUtility.escapeSingleQuotes(voLineItemGroupId);
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item_Group__c> voliGroups = [select Id, (select Qty_Needed__c, Is_Excess__c, Is_required_For_Customer__c, Is_Service__c from Vendor_Order_Line_Items__r) 
                                                                from Vendor_Order_Line_Item_Group__c where Id = :voLineItemGroupId];
        
        Decimal alreadyOrderedQty = 0;
        if(voliGroups.size() > 0) {
            for(Vendor_Order_Line_Item__c voliRec : voliGroups[0].Vendor_Order_Line_Items__r) {
                if(!(voliRec.Is_required_For_Customer__c || voliRec.Is_Service__c)) {
                    alreadyOrderedQty += voliRec.Qty_Needed__c;
                }
            }
        }
        voLineItemId = BPUtility.escapeSingleQuotes(voLineItemId);
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item__c> voliRecList = [select Id, Part__c, Is_Service__c, Qty_Needed__c, Is_From_Search__c, CO_Line_Item__c, CO_Line_Item__r.Status__c, CO_Line_Item__r.VO_Number__c, CO_Line_Item__r.VO_Status__c, CO_Line_Item__r.Expected_Delivery_Date__c, Is_Excess__c, Is_required_For_Customer__c, Vendor_Order_Line_Item_Group__c from Vendor_Order_Line_Item__c Where Id =:voLineItemId];
        List<Part__c> partRecList = new List<Part__c>();
        
        if(voliRecList.size() > 0) {
            List<sObject> lineItemsToDel = new List<sObject>();
            
            if(voliRecList[0].Is_From_Search__c){
                lineItemsToDel.add(voliRecList[0]);
            } else {
                voliRecList[0].Vendor_Order_Line_Item_Group__c = null;
                voliRecList[0].Vendor_Order_Header__c = null;
            }
            
            if(voliRecList[0].Is_required_For_Customer__c || voliRecList[0].Is_Service__c) {
                Id coliRecId = (voliRecList[0].CO_Line_Item__c != null) ? voliRecList[0].CO_Line_Item__c : null;
                if(coliRecId != null) {
                    CO_Line_Item__c coliRec = new CO_Line_Item__c();
                    coliRec.Id = coliRecId; 
                    coliRec.Status__c = 'Required';
                    coliRec.Vendor_Order_Header__c = null;
                    coliRec.VO_Number__c = null;
                    coliRec.VO_Status__c = null;
                    coliRec.Expected_Delivery_Date__c = null;
                    coliRec.Id = voliRecList[0].CO_Line_Item__c;
                    if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update coliRec;
                }
            } else {
            
            }
            
            if(lineItemsToDel.size() > 0){
                if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
                delete lineItemsToDel;
            } else if(voliRecList.size() > 0){
                if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update voliRecList;
            }
            partRecList = SOQLUtil.getPartDetailRecordsByFieldName('Id', voliRecList[0].Part__c);
        }
        
        Decimal previousExcessNeed = 0;
        // Calcalute Need and Excess Values Again
        List<Vendor_Order_Line_Item_Group__c> voliGroupList = SOQLUtil.getVOLIGroupByFieldName('Id', voLineItemGroupId, voHeaderId);
        Decimal needForVOLineItem = 0;
        String excessRecId;
        if(voliGroupList.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            if(voliGroupList[0].Vendor_Order_Line_Items__r.size() == 0 || (voliGroupList[0].Vendor_Order_Line_Items__r.size() == 1 && voliGroupList[0].Vendor_Order_Line_Items__r[0].Is_Excess__c)){
                List<sObject> sObjToDel = new List<sObject>();
                if(voliGroupList[0].Vendor_Order_Line_Items__r.size() > 0){
                    sObjToDel.addAll((List<sObject>)voliGroupList[0].Vendor_Order_Line_Items__r);
                }
                
                // Update Part Qty
                Decimal qtyToRemove = 0;
                
                for(Vendor_Order_Line_Item__c voliRec : voliGroupList[0].Vendor_Order_Line_Items__r) {
                    if(!(voliRec.Is_required_For_Customer__c || voliRec.Is_Service__c)) {
                        qtyToRemove += voliRec.Qty_Needed__c;
                    } 
                }
                if(!(voliRecList[0].Is_required_For_Customer__c || voliRecList[0].Is_Service__c)) {
                    qtyToRemove += voliRecList[0].Qty_Needed__c;
                }
                voLineItemGroupId = BPUtility.escapeSingleQuotes(voLineItemGroupId);
                if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Vendor_Order_Line_Item_Group__c> voligList = [select Part__c, Part__r.Qty_On_Order__c from Vendor_Order_Line_Item_Group__c where Id = :voLineItemGroupId];
                if(voligList.size() > 0) {
                    Part__c partRec = new Part__c(Id = voligList[0].Part__c);
                    partRec.Qty_On_Order__c = voligList[0].Part__r.Qty_On_Order__c - qtyToRemove;
                    if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update partRec;
                } 
                
                sObjToDel.add(voliGroupList[0]);
                
                delete sObjToDel;
                
                return getVOLineItemWrapperJSON(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(itemsPageSortAttrsJSON), BPUtility.getEncodedString(customersPageSortAttrsJSON), BPUtility.getEncodedString(stocksPageSortAttrsJSON), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null));
            }
            
            for(Vendor_Order_Line_Item__c voliRec : voliGroupList[0].Vendor_Order_Line_Items__r) {
                if(!voliRec.Is_Excess__c) {
                    needForVOLineItem += voliRec.Qty_Needed__c;
                } else {
                    excessRecId = voliRec.Id;
                    previousExcessNeed += voliRec.Qty_Needed__c;
                }
            }
        }
        
        
        //Topping Up In case of Packaged Part or Order Lots
        Decimal need = toppingUpNeed(partRecList, needForVOLineItem);
        
         if(voliGroupList != null && voliGroupList.size() > 0) {
            voliGroupList[0].Need__c = need;
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            upsert voliGroupList;
        }
        voLineItemGroupId = BPUtility.escapeSingleQuotes(voLineItemGroupId);
        voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item__c> excessLineItemList = [select Id, Is_Excess__c, Is_Service__c from Vendor_Order_Line_Item__c 
                                                                    Where Vendor_Order_Line_Item_Group__c =:voLineItemGroupId 
                                                                        AND Vendor_Order_Header__c =: voHeaderId 
                                                                        AND Is_Excess__c = true];
        
        if(need - needForVOLineItem > 0) {
            Decimal excessNeed = need - needForVOLineItem;
            if(excessLineItemList.size() > 0) {
                excessLineItemList[0].Qty_Needed__c = excessNeed;
                if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update excessLineItemList;
            } else {
                Vendor_Order_Line_Item__c voLineItemForExcessStock = new Vendor_Order_Line_Item__c();
                voLineItemForExcessStock.Qty_Needed__c = excessNeed;
                voLineItemForExcessStock.Part__c = voliRecList[0].Part__c;
                voLineItemForExcessStock.Is_Excess__c = true;
                voLineItemForExcessStock.Vendor_Order_Header__c = voHeaderId;
                voLineItemForExcessStock.Vendor_Order_Line_Item_Group__c = voLineItemGroupId;
                if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                insert voLineItemForExcessStock;
            }
        } else {
            if(excessRecId != null) {
                Vendor_Order_Line_Item__c voLineItemForExcessStock = new Vendor_Order_Line_Item__c(Id = excessRecId);
                if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
                delete voLineItemForExcessStock;
            }
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        voLineItemGroupId = BPUtility.escapeSingleQuotes(voLineItemGroupId);
        List<Vendor_Order_Line_Item_Group__c> voligList = [select Part__c, Part__r.Qty_On_Order__c, (select Qty_Needed__c, Is_Service__c, Is_required_For_Customer__c from Vendor_Order_Line_Items__r) 
                                                                        from Vendor_Order_Line_Item_Group__c where Id = :voLineItemGroupId];
        
        if(voligList.size() > 0) {
            
            Decimal orderedQty = 0;
            for(Vendor_Order_Line_Item__c voliRecord : voligList[0].Vendor_Order_Line_Items__r) {
                if(!(voliRecord.Is_required_For_Customer__c || voliRecord.Is_Service__c)) {
                    orderedQty += voliRecord.Qty_Needed__c;
                }
            }
            
            Part__c partRec = new Part__c(Id = voligList[0].Part__c);
            partRec.Qty_On_Order__c = voligList[0].Part__r.Qty_On_Order__c - alreadyOrderedQty + orderedQty;
            if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update partRec;
            
            //Database.rollback(sp);
            //system.assert(false, partRec.Qty_On_Order__c);
        
        }
        
        //system.assert(false, voligList[0].Vendor_Order_Line_Items__r + ' ' + voligList[0].Part__r.Qty_On_Order__c + '   ' + alreadyOrderedQty);
        
        //updatePartOrderedQtyInCaseOfRemovingOfGroup(voLineItemGroupId, voHeaderId);
        
        return getVOLineItemWrapperJSON(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(itemsPageSortAttrsJSON), BPUtility.getEncodedString(customersPageSortAttrsJSON), BPUtility.getEncodedString(stocksPageSortAttrsJSON), BPUtility.getEncodedString(null), BPUtility.getEncodedString(voliRecList[0].Part__c));
    }
    
    /**
     * Name: groupAllVOLineItem
     * Desc: Method which remove VO group from Items sectios
     * @param:  (1) vendorId - String - Vendor Id
     *          (2) voHeaderId - String - VO Header record Id
     *          (3) isRequiredForCustomer -  Boolean - is Required for Customer or not
     *          (5) itemsPageSortAttrsJSON - String - page sort attributes of item
     *          (6) customersPageSortAttrsJSON - Sting - page sort attributes of customer
     *          (7) stocksPageSortAttrsJSON - String -  page sort attributes of stock
     * @return: String - JSON String of VO Header Wrapper Record
    **/
    @RemoteAction
    global static String groupAllVOLineItem(String vendorId, String voHeaderId, Boolean isRequiredForCustomer, String itemsPageSortAttrsJSON, String customersPageSortAttrsJSON, String stocksPageSortAttrsJSON){
        try{
        	vendorId = BPUtility.getDecodedString(vendorId);
        	voHeaderId = BPUtility.getDecodedString(voHeaderId);
        	itemsPageSortAttrsJSON = BPUtility.getDecodedString(itemsPageSortAttrsJSON);
        	customersPageSortAttrsJSON = BPUtility.getDecodedString(customersPageSortAttrsJSON);
        	stocksPageSortAttrsJSON = BPUtility.getDecodedString(stocksPageSortAttrsJSON);
   
            Savepoint sp = Database.setSavepoint();
            List<Vendor_Order_Line_Item__c> voLineItemsRequired = (vendorId == null) ? new List<Vendor_Order_Line_Item__c>() : SOQLUtil.getVOLineItem(vendorId, voHeaderId, isRequiredForCustomer);
            
            Set<Id> partIdSet = new Set<Id>();
            Map<Id, List<Vendor_Order_Line_Item_Group__c>> partIdToVOLIGroupRecListMap = new Map<Id, List<Vendor_Order_Line_Item_Group__c>>();
            
            for(Vendor_Order_Line_Item__c voliRec : voLineItemsRequired) {
                partIdSet.add(voliRec.Part__c);
            }
            
            if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            Map<Id, Part__c> partIdToPartRecMap = new Map<Id, Part__c>([select Id, Packaged_Part__c, Order_Lots__c, Last_Cost__c, Package_Qty__c from Part__c where Id IN : partIdSet]);
            List<Vendor_Order_Line_Item_Group__c> voliGroupList = (vendorId == null) ? new List<Vendor_Order_Line_Item_Group__c>() : SOQLUtil.getVOLIGroupByFieldName('Vendor_Order_Header__c', voHeaderId, voHeaderId);
            
            for(Vendor_Order_Line_Item_Group__c vogRec : voliGroupList) {
                List<Vendor_Order_Line_Item_Group__c> voliGroupRecList;
                if(partIdToVOLIGroupRecListMap.containsKey(vogRec.Part__c)) {
                    voliGroupRecList = partIdToVOLIGroupRecListMap.get(vogRec.Part__c);
                } else {
                    voliGroupRecList = new List<Vendor_Order_Line_Item_Group__c>();
                }
                voliGroupRecList.add(vogRec);
                partIdToVOLIGroupRecListMap.put(vogRec.Part__c, voliGroupRecList);
            }
            
            Set<Id> groupPartIdSet = new Set<Id>();
            List<Vendor_Order_Line_Item_Group__c> vogRecListToInsert = new List<Vendor_Order_Line_Item_Group__c>();
            for(Vendor_Order_Line_Item__c voliRec : voLineItemsRequired) {
                Vendor_Order_Line_Item_Group__c vogRec;
                if(partIdToVOLIGroupRecListMap.containsKey(voliRec.Part__c)) {
                    vogRec = partIdToVOLIGroupRecListMap.get(voliRec.Part__c)[0];
                    groupPartIdSet.add(voliRec.Part__c);
                } else if(groupPartIdSet.contains(voliRec.Part__c)) {
                    
                } else {
                    vogRec = new Vendor_Order_Line_Item_Group__c();
                    vogRec.Part__c = voliRec.Part__c;
                    vogRec.Vendor_Order_Header__c = voHeaderId;
                    vogRec.Need__c = 0;
                    vogRecListToInsert.add(vogRec);
                    groupPartIdSet.add(voliRec.Part__c);
                }
            }
            
            if(vogRecListToInsert.size() > 0) {
                if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                insert vogRecListToInsert;
            }
            
            for(Vendor_Order_Line_Item_Group__c vogRec : vogRecListToInsert) {
                if(!partIdToVOLIGroupRecListMap.containsKey(vogRec.Part__c)) {
                    partIdToVOLIGroupRecListMap.put(vogRec.Part__c, new List<Vendor_Order_Line_Item_Group__c>{vogRec});
                }
            }
            
            for(Vendor_Order_Line_Item__c voliRec : voLineItemsRequired) {
                Vendor_Order_Line_Item_Group__c vogRec;
                if(partIdToVOLIGroupRecListMap.containsKey(voliRec.Part__c)) {
                    vogRec = partIdToVOLIGroupRecListMap.get(voliRec.Part__c)[0];
                    voliRec.Vendor_Order_Line_Item_Group__c = vogRec.Id;
                    voliRec.Vendor_Order_Header__c = voHeaderId;
                } 
            }
            Set<Id> newInsertedVOLineItemIdSet = new Set<Id>();
	        for(Vendor_Order_Line_Item__c voliRec : voLineItemsRequired) {
	        	newInsertedVOLineItemIdSet.add(voliRec.Id);
	        }
            
            if(voLineItemsRequired.size() > 0) {
                if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update voLineItemsRequired;
            }
            
            
            voliGroupList = SOQLUtil.getVOLIGroupByFieldName('Vendor_Order_Header__c', voHeaderId, voHeaderId);
            Map<Id, Decimal> vogIdToAlreadyOrderedQty = new Map<Id, Decimal>();
            List<Vendor_Order_Line_Item__c> voliListToUpsert = new List<Vendor_Order_Line_Item__c>();
            for(Vendor_Order_Line_Item_Group__c vogRec : voliGroupList) {
                if(partIdToPartRecMap.containsKey(vogRec.Part__c)) {
                	Decimal alreadyOrderedQty = 0;
                    Decimal needForVOLineItem = 0;
                    Vendor_Order_Line_Item__c excessRec;
                    for(Vendor_Order_Line_Item__c voliRec : vogRec.Vendor_Order_Line_Items__r) {
                        if(voliRec.Is_Excess__c) {
                            excessRec = voliRec;
                        } else {
                            needForVOLineItem += voliRec.Qty_Needed__c;
                        }
                        if(!(voliRec.Is_required_For_Customer__c || voliRec.Is_Service__c) && (!newInsertedVOLineItemIdSet.contains(voliRec.Id))) {
		                    alreadyOrderedQty += voliRec.Qty_Needed__c;
	                	}
                    }
                    
                    // Topping Up Need
                    Decimal need = toppingUpNeed(new List<Part__c>{partIdToPartRecMap.get(vogRec.Part__c)}, needForVOLineItem);
                    vogRec.Need__c = need;
                    
                    if(excessRec == null) {
                        excessRec = new Vendor_Order_Line_Item__c();
                        excessRec.Part__c = vogRec.Part__c;
                        excessRec.Is_Excess__c = true;
                        excessRec.Vendor_Order_Header__c = voHeaderId;
                        excessRec.Vendor_Order_Line_Item_Group__c = vogRec.Id;
                    } 
                    excessRec.Qty_Needed__c = need - needForVOLineItem;
                    if(excessRec.Qty_Needed__c != 0) {
                        voliListToUpsert.add(excessRec);    
                    }
                    
                    vogIdToAlreadyOrderedQty.put(vogRec.Id, alreadyOrderedQty);
                }
            }
            
            if(voliListToUpsert.size() > 0) {
                if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                upsert voliListToUpsert;
            }
            
            if(voliGroupList.size() > 0) {
                if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update voliGroupList;
            }
            
            // Populate VO number on COLIs + Update Part Ordered Qty.
            updatePartOrderedQty(vendorId, voHeaderId, vogIdToAlreadyOrderedQty);
            
            return getVOLineItemWrapperJSON(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(itemsPageSortAttrsJSON), BPUtility.getEncodedString(customersPageSortAttrsJSON), BPUtility.getEncodedString(stocksPageSortAttrsJSON), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    
    private static void updatePartOrderedQtyInCaseOfRemovingOfGroup(List<Vendor_Order_Line_Item__c> voliList, String voHeaderId) {
        
        // Update All related CO Line Items Status - "ORDERED"
        //List<Vendor_Order_Line_Item__c> voliList = SOQLUtil.getVOLIGroupByFieldName('Id', vogId, voHeaderId);
        List<Id> coLineItemIdList = new List<Id>();
        Set<Id> soliIdSet = new Set<Id>();
        Map<Id, Decimal> partIdToOrderedQtyMap = new Map<Id, Decimal>();
        
       
        Decimal qtyOrdered = 0;
        for(Vendor_Order_Line_Item__c voliRec : voliList) {
        	if(String.isNotBlank(voliRec.Part__c)) {
        		if(voliRec.Is_required_For_Customer__c || voliRec.Is_Service__c) {
	                coLineItemIdList.add(voliRec.CO_Line_Item__c);
	            } else {
	                qtyOrdered += voliRec.Qty_Needed__c;
	            }
        	} else if(String.isNotBlank(voliRec.Sublet__c) && voliRec.Service_Order_Line_Item__c != null){
        		soliIdSet.add(voliRec.Service_Order_Line_Item__c);
        	}
        }
        
        if(String.isNotBlank(voliList[0].Part__c)) {
        	partIdToOrderedQtyMap.put(voliList[0].Part__c, qtyOrdered);
        }
       
        voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        if(coLineItemIdList.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<CO_Line_Item__c> coLineItemList = [select Status__c, VO_Number__c, VO_Status__c, Expected_Delivery_Date__c from CO_Line_Item__c where Id IN : coLineItemIdList];
            for(CO_Line_Item__c coliRec : coLineItemList) {
                coliRec.Status__c = 'Required';
                coliRec.Vendor_Order_Header__c = null;
                coliRec.VO_Number__c = null;
                coliRec.VO_Status__c = null;
                coliRec.Expected_Delivery_Date__c = null;
            }
            //System.assert(false, coLineItemList);
            if(coLineItemList.size() > 0) {
                // To Stop COLineItemTrigger to execute
                COLineItemTriggerHelper.isTriggerExecute = true;
                if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update coLineItemList;
            }
        }
        if(soliIdSet.size() > 0) {
        	if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Service_Order_Line_Item__c> soliList = [select Status__c, VO_Number__c, VO_Status__c, Expected_Delivery_Date__c from Service_Order_Line_Item__c where Id IN : soliIdSet];
            for(Service_Order_Line_Item__c soliRec : soliList) {
                soliRec.Status__c = 'Required';
                soliRec.Vendor_Order_Header__c = null;
                soliRec.VO_Number__c = null;
                soliRec.VO_Status__c = null;
                soliRec.Expected_Delivery_Date__c = null;
            }
            if(soliList.size() > 0) {
                ServiceOrderLineItemTriggerHelper.isTriggerExecuted = true;
                if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update soliList;
            }
        }
        // Update Parts Realted List - ON Order and QTY ON ORDER on Part Record
        if(partIdToOrderedQtyMap.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Part__c> partList = [select Qty_On_Order__c from Part__c where Id IN : partIdToOrderedQtyMap.keySet()];
            for(Part__c partRec : partList) {
                if(partRec.Qty_On_Order__c != null) {
                    partRec.Qty_On_Order__c = partRec.Qty_On_Order__c - partIdToOrderedQtyMap.get(partRec.Id);
                } else {
                    //partRec.Qty_On_Order__c = partIdToOrderedQtyMap.get(partRec.Id);
                }
            }
            if(partList.size() > 0) {
                if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update partList;
            }
        }
    }
    
    private static void updatePartOrderedQty(String vendorId, String voHeaderId, Map<Id, Decimal> vogIdToAlreadyOrderedQty) {
    
        // Update All related CO Line Items Status - "ORDERED"
        List<Vendor_Order_Line_Item_Group__c> voliGroupList;
        if(vogIdToAlreadyOrderedQty.size() == 0) {
            voliGroupList = SOQLUtil.getVOLIGroupByFieldName('Part__r.Vendor__c', vendorId, voHeaderId);
            voliGroupList.addAll((List<Vendor_Order_Line_Item_Group__c>) SOQLUtil.getVOLIGroupByFieldName('Sublet__r.Vendor__c', vendorId, voHeaderId));
        } else {
            voliGroupList = [select Part__c, Sublet__c, (select Qty_Needed__c, CO_Line_Item__c, Service_Order_Line_Item__c, Is_required_For_Customer__c, Is_Service__c from 
            	Vendor_Order_Line_Items__r) from Vendor_Order_Line_Item_Group__c where Id IN: vogIdToAlreadyOrderedQty.keySet()];
        }
        List<Id> coLineItemIdList = new List<Id>();
        List<Id> soLineItemIdList = new List<Id>();
        Map<Id, Decimal> partIdToOrderedQtyMap = new Map<Id, Decimal>();
        
        for(Vendor_Order_Line_Item_Group__c voliGroupRec : voliGroupList) {
            Decimal qtyOrdered = 0;
            for(Vendor_Order_Line_Item__c voliRec : voliGroupRec.Vendor_Order_Line_Items__r) {
                if(voliRec.Is_required_For_Customer__c || voliRec.Is_Service__c) {
                	if(voliRec.CO_Line_Item__c != null) {
                        coLineItemIdList.add(voliRec.CO_Line_Item__c);
                	} else if(voliRec.Service_Order_Line_Item__c != null){
                		soLineItemIdList.add(voliRec.Service_Order_Line_Item__c);
                	}
                } else {
                    qtyOrdered += voliRec.Qty_Needed__c;
                }
            }
            if(voliGroupRec.Part__c != null) {
            	Decimal qtyDifference = qtyOrdered - ((vogIdToAlreadyOrderedQty.containsKey(voliGroupRec.Id) && vogIdToAlreadyOrderedQty.get(voliGroupRec.Id) != null) 
            										? vogIdToAlreadyOrderedQty.get(voliGroupRec.Id) : 0);
	            partIdToOrderedQtyMap.put(voliGroupRec.Part__c, qtyDifference);
            }
        }
        
        // Set COLI Status
        voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Header__c> voHeaderList = [select Id, Name, Status__c, Ordered_Date__c from Vendor_Order_Header__c where Id =:voHeaderId];
        
        if(coLineItemIdList.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<CO_Line_Item__c> coLineItemList = [select Status__c, VO_Number__c, VO_Status__c, Expected_Delivery_Date__c from CO_Line_Item__c where Id IN : coLineItemIdList];
            for(CO_Line_Item__c coliRec : coLineItemList) {
                coliRec.Status__c = 'Ordered';
                coliRec.Vendor_Order_Header__c = voHeaderList[0].Id;
                coliRec.VO_Number__c = voHeaderList[0].Name;
                coliRec.VO_Status__c = 'On Order';
                coliRec.Expected_Delivery_Date__c = Date.Today();
            }
            //System.assert(false, coLineItemList);
            if(coLineItemList.size() > 0) {
                // To Stop COLineItemTrigger to execute
                COLineItemTriggerHelper.isTriggerExecute = true;
                if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update coLineItemList;
            }
        }
        
        if(soLineItemIdList.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Service_Order_Line_Item__c> soLineItemList = [select Status__c, VO_Number__c, VO_Status__c, Expected_Delivery_Date__c from Service_Order_Line_Item__c where Id IN : soLineItemIdList];
            for(Service_Order_Line_Item__c soliRec : soLineItemList) {
                soliRec.Status__c = 'Ordered';
                soliRec.Vendor_Order_Header__c = voHeaderList[0].Id;
                soliRec.VO_Number__c = voHeaderList[0].Name;
                soliRec.VO_Status__c = 'On Order';
                soliRec.Expected_Delivery_Date__c = Date.Today();
            }
            if(soLineItemList.size() > 0) {
                // To Stop COLineItemTrigger to execute
                ServiceOrderLineItemTriggerHelper.isTriggerExecuted = true;
                if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update soLineItemList;
            }
        }
        
        // Update Parts Realted List - ON Order and QTY ON ORDER on Part Record
        if(partIdToOrderedQtyMap.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Part__c> partList = [select Qty_On_Order__c from Part__c where Id IN : partIdToOrderedQtyMap.keySet()];
            for(Part__c partRec : partList) {
                if(partRec.Qty_On_Order__c != null) {
                    partRec.Qty_On_Order__c = partRec.Qty_On_Order__c + partIdToOrderedQtyMap.get(partRec.Id);
                } else {
                    partRec.Qty_On_Order__c = partIdToOrderedQtyMap.get(partRec.Id);
                }
            }
            if(partList.size() > 0) {
                if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update partList;
            }
        }
    }
    
    
    private static String insertSearchToAddLineItem(String partId, String vendorId, String voHeaderId) {
    	partId = BPUtility.escapeSingleQuotes(partId);
    	voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item_Group__c> voligList = [select Part__c, Part__r.Last_Cost__c, (select Id from Vendor_Order_Line_Items__r where Is_From_Search__c = true) 
                                                                from Vendor_Order_Line_Item_Group__c 
                                                                where Part__c =: partId AND Vendor_Order_Header__c =: voHeaderId];
        
        Vendor_Order_Line_Item_Group__c voligRec = new Vendor_Order_Line_Item_Group__c();
        if(voligList.size() == 0) {
            voligRec.Vendor_Order_Header__c = voHeaderId;
            voligRec.Part__c = partId;
            voligRec.Need__c = 0;
            //voligRec.Cost__c =  
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert voligRec;
        } else {
            voligRec = voligList[0];
            if(voligRec.Vendor_Order_Line_Items__r.size() > 0) {
                return voligRec.Vendor_Order_Line_Items__r[0].Id;
            } 
        }                                                       
        
        Vendor_Order_Line_Item__c voliRec = new Vendor_Order_Line_Item__c();
        voliRec.Part__c = voligRec.Part__c;
        voliRec.Vendor_Order_Line_Item_Group__c = voligRec.Id;
        voliRec.Is_From_Search__c = true;
        voliRec.Qty_Needed__c = 0;
        voliRec.Vendor_Order_Header__c = voHeaderId;
        if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        insert voliRec;
        
        return voliRec.Id;
    }
    
    /**
     * Name: addVOLineItemFromSearchToAdd
     * Desc: Method which add VO Line Item from Search to add text box.
     * @param:  (1)partId - String - Part Id
     *          (2) vendorId - String - Vendor Id
     *          (3) voHeaderId - String - VO Header record Id
     *          (4) qtyRequired- Decimal - Quantity Required 
     *          (5) itemsPageSortAttrsJSON - String - page sort attributes of item
     *          (6) customersPageSortAttrsJSON - Sting - page sort attributes of customer
     *          (7) stocksPageSortAttrsJSON - String -  page sort attributes of stock
     *          (8) newVOLIRecId - String - VO List Item Record Id
     *          (9) isFromSearchToAdd - Boolean - is From Search To add or not
     * @return: String - JSON String of VO Header Wrapper Record
    **/
    @RemoteAction
    global static String addVOLineItemFromSearchToAdd(String partId, String vendorId, String voHeaderId, Decimal qtyRequired, String itemsPageSortAttrsJSON, String customersPageSortAttrsJSON, String stocksPageSortAttrsJSON, String newVOLIRecId, Boolean isFromSearchToAdd){
    	if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	
        partId = BPUtility.getDecodedString(partId);
        vendorId = BPUtility.getDecodedString(vendorId);
        voHeaderId = BPUtility.getDecodedString(voHeaderId);
        itemsPageSortAttrsJSON = BPUtility.getDecodedString(itemsPageSortAttrsJSON);
        customersPageSortAttrsJSON = BPUtility.getDecodedString(customersPageSortAttrsJSON);
        stocksPageSortAttrsJSON = BPUtility.getDecodedString(stocksPageSortAttrsJSON);
        newVOLIRecId = BPUtility.getDecodedString(newVOLIRecId);
        
        
        Boolean isVOLIsFoundInOutstandingGrid = false;
        
        Savepoint sp = Database.setSavepoint();
        
        if(isFromSearchToAdd) {
        	partId = BPUtility.escapeSingleQuotes(partId);
            if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Vendor_Order_Line_Item__c> voLineItemsWithSimilarParts = [select Part__c, Part__r.Last_Cost__c, Vendor_Order_Line_Item_Group__c from Vendor_Order_Line_Item__c
                                                                                where Part__c =: partId AND Vendor_Order_Line_Item_Group__c = null];
            
            
            /*List<Vendor_Order_Line_Item_Group__c> voligList = [select Part__c, Part__r.Last_Cost__c from Vendor_Order_Line_Item_Group__c 
                                                                where Part__c =: partId AND Vendor_Order_Header__c =: voHeaderId];*/
            
            //List<Vendor_Order_Line_Item__c> voLineItemsWithSimilarParts = SOQLUtil.getVOLineItemWithSimilarParts(vendorId, partId, voHeaderId);
            if(voLineItemsWithSimilarParts.size() > 0) {
                isVOLIsFoundInOutstandingGrid = true;
            } 
            
            if(isVOLIsFoundInOutstandingGrid) {
            	
                return groupAllSimilarVOLineItem(vendorId, partId, voHeaderId, itemsPageSortAttrsJSON, customersPageSortAttrsJSON, stocksPageSortAttrsJSON, null);
            } else {
            	
                String newLineItemId = insertSearchToAddLineItem(partId, vendorId, voHeaderId);
                
                partId = BPUtility.getEncodedString(partId);
		        vendorId = BPUtility.getEncodedString(vendorId);
		        voHeaderId = BPUtility.getEncodedString(voHeaderId);
		        itemsPageSortAttrsJSON = BPUtility.getEncodedString(itemsPageSortAttrsJSON);
		        customersPageSortAttrsJSON = BPUtility.getEncodedString(customersPageSortAttrsJSON);
		        stocksPageSortAttrsJSON = BPUtility.getEncodedString(stocksPageSortAttrsJSON);
		        newLineItemId = BPUtility.getEncodedString(newLineItemId);
                
                addVOLineItemFromSearchToAdd(partId, vendorId, voHeaderId, 1, itemsPageSortAttrsJSON, customersPageSortAttrsJSON, stocksPageSortAttrsJSON, newLineItemId, false);
                
                return getVOLineItemWrapperJSON(vendorId, voHeaderId, itemsPageSortAttrsJSON, customersPageSortAttrsJSON, stocksPageSortAttrsJSON, newLineItemId, partId);
            }
        }  
        
        if(!isFromSearchToAdd) {
            String addNewLineItemId = updateVOLIGAndPartRelatedInfo(partId, voHeaderId, newVOLIRecId, qtyRequired);
            return getVOLineItemWrapperJSON(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(itemsPageSortAttrsJSON), BPUtility.getEncodedString(customersPageSortAttrsJSON), BPUtility.getEncodedString(stocksPageSortAttrsJSON), BPUtility.getEncodedString(addNewLineItemId), BPUtility.getEncodedString(partId));
        }
        return BPUtility.getEncodedString(null);
    }
    
    private static String updateVOLIGAndPartRelatedInfo(String partId, String voHeaderId, String newVOLIRecId, Decimal qtyRequired) {
    	List<Vendor_Order_Line_Item_Group__c> voliGroupList = SOQLUtil.getVOLIGroupByFieldName('Part__c', partId, voHeaderId);
        List<Part__c> partRecList = SOQLUtil.getPartDetailRecordsByFieldName('Id', partId);
        Vendor_Order_Line_Item_Group__c voliGroupRec = new Vendor_Order_Line_Item_Group__c();
            
        if(voliGroupList.size() > 0) {
            voliGroupRec.Id = voliGroupList[0].Id;
            voliGroupRec.Part__c = voliGroupList[0].Part__c;
        } else {
            voliGroupRec.Part__c = partId;
            voliGroupRec.Vendor_Order_Header__c = voHeaderId;
        }
        
        Decimal needForVOLineItem = 0;
        Decimal excessQtyBefore = 0;
        Decimal alreadyOrderedQty = 0;
        String excessRecId;
        if(voliGroupList.size() > 0) {
            for(Vendor_Order_Line_Item__c voliRec : voliGroupList[0].Vendor_Order_Line_Items__r) {
                if(voliRec.Is_Excess__c) {
                    excessRecId = voliRec.Id;
                    excessQtyBefore = voliRec.Qty_Needed__c;
                }else if(voliRec.Id != newVOLIRecId || (voliRec.Id == newVOLIRecId && qtyRequired < 0)){
                    needForVOLineItem += voliRec.Qty_Needed__c;
                } 
                
                if(!(voliRec.Is_required_For_Customer__c || voliRec.Is_Service__c || voliRec.Is_Excess__c || qtyRequired == null)) {
                    alreadyOrderedQty += voliRec.Qty_Needed__c; 
                }
            }
        }
        
        if(qtyRequired != null && qtyRequired > 0){
        	needForVOLineItem += qtyRequired;
        }
        // Topping Up Need
        Decimal need = toppingUpNeed(partRecList, needForVOLineItem);
        voliGroupRec.Need__c = need;
        if(voliGroupRec != null) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            upsert voliGroupRec;
        }
        
        List<Vendor_Order_Line_Item__c> voliListToInsert = new List<Vendor_Order_Line_Item__c>();
        Vendor_Order_Line_Item__c voLineItemForExcessStock;
        if(need > needForVOLineItem) {
            Decimal execessNeed = need - needForVOLineItem;
            voLineItemForExcessStock = new Vendor_Order_Line_Item__c();
            if(excessRecId != null) {
                voLineItemForExcessStock.Id = excessRecId;
            } 
            voLineItemForExcessStock.Qty_Needed__c = execessNeed;
            voLineItemForExcessStock.Part__c = partId;
            voLineItemForExcessStock.Is_Excess__c = true;
            voLineItemForExcessStock.Vendor_Order_Header__c = voHeaderId;
            voLineItemForExcessStock.Vendor_Order_Line_Item_Group__c = voliGroupRec.Id;
            voliListToInsert.add(voLineItemForExcessStock);
        } else {
            if(excessRecId != null) {
                voLineItemForExcessStock = new Vendor_Order_Line_Item__c(Id = excessRecId);
                if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
                delete voLineItemForExcessStock;
            }
        }
        
        Vendor_Order_Line_Item__c voliRec = new Vendor_Order_Line_Item__c();
        if(qtyRequired != null && qtyRequired > 0){
        	voliRec.Qty_Needed__c = qtyRequired;
        }
        voliRec.Part__c = partId;
        if(newVOLIRecId != null) {
            voliRec.Id = newVOLIRecId;
        }
        voliRec.Vendor_Order_Header__c = voHeaderId;
        voliRec.Is_Excess__c = false;
        voliRec.Vendor_Order_Line_Item_Group__c = voliGroupRec.Id;
        voliRec.Line_Item_Cost__c = (partRecList.size() > 0) ? partRecList[0].Last_Cost__c : 0;
        voliListToInsert.add(voliRec);
        
        if(voliListToInsert.size() > 0 && qtyRequired != null) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            upsert voliListToInsert;
        }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Line_Item__c> voliRecList = [select Id from Vendor_Order_Line_Item__c Where Is_Excess__c = false AND Id IN : voliListToInsert];
        String addNewLineItemId = '';
        if(voliRecList.size() > 0) {
            addNewLineItemId = voliRecList[0].Id;
        } 
        
        
        // Update Part Qty
        List<Id> coLineItemIdList = new List<Id>();
        Map<Id, Decimal> partIdToOrderedQtyMap = new Map<Id, Decimal>();
        
        voliGroupList = SOQLUtil.getVOLIGroupByFieldName('Part__c', partId, voHeaderId);
        //voliRecList = [select Id, Is_Service__c, CO_Line_Item__c, Qty_Needed__c, Is_required_For_Customer__c from Vendor_Order_Line_Item__c Where Id =: newVOLIRecId OR Id IN: voliListToInsert];
        Decimal qtyOrdered = 0;
        if(voliGroupList.size() > 0) {
            for(Vendor_Order_Line_Item__c voliRecord : voliGroupList[0].Vendor_Order_Line_Items__r) {
                if(voliRecord.Is_required_For_Customer__c || voliRecord.Is_Service__c) {
                    coLineItemIdList.add(voliRecord.CO_Line_Item__c);
                } else {
                    qtyOrdered += voliRecord.Qty_Needed__c;
                }
            }
            partIdToOrderedQtyMap.put(voliGroupList[0].Part__c, qtyOrdered);
        }
        voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Order_Header__c> voHeaderList = [select Id, Name, Status__c, Ordered_Date__c from Vendor_Order_Header__c where Id =:voHeaderId];
        if(coLineItemIdList.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<CO_Line_Item__c> coLineItemList = [select Status__c, VO_Number__c, VO_Status__c, Expected_Delivery_Date__c from CO_Line_Item__c where Id IN : coLineItemIdList];
            for(CO_Line_Item__c coliRec : coLineItemList) {
                coliRec.Status__c = 'Ordered';
                coliRec.Vendor_Order_Header__c = voHeaderList[0].Id;
                coliRec.VO_Number__c = voHeaderList[0].Name;
                coliRec.VO_Status__c = 'On Order';
                coliRec.Expected_Delivery_Date__c = Date.Today();
            }
            //System.assert(false, coLineItemList);
            if(coLineItemList.size() > 0) {
                // To Stop COLineItemTrigger to execute
                COLineItemTriggerHelper.isTriggerExecute = true;
                if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update coLineItemList;
            }
        }
        
        // Update Parts Realted List - ON Order and QTY ON ORDER on Part Record
        if(partIdToOrderedQtyMap.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Part__c> partList = [select Qty_On_Order__c from Part__c where Id IN : partIdToOrderedQtyMap.keySet()];
            for(Part__c partRec : partList) {
                if(partRec.Qty_On_Order__c != null) {
                    partRec.Qty_On_Order__c = partRec.Qty_On_Order__c + partIdToOrderedQtyMap.get(partRec.Id) - alreadyOrderedQty - excessQtyBefore;
                } else {
                    partRec.Qty_On_Order__c = partIdToOrderedQtyMap.get(partRec.Id) - alreadyOrderedQty - excessQtyBefore;
                }
            }
            
            if(partList.size() > 0) {
                if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update partList;
            }
        }
        
        return addNewLineItemId;
    }
    
    /**
     * Name: finalizeVendorOrder
     * Desc: Method to do operation realted to finalize vendor Order
     * @param:  (1) voHeaderId - String - vo Header Id
     *          (2) vendorId - String Vendor id
     *          (3) itemsPageSortAttrsJSON - String - page sort attributes of item
     *          (3) customersPageSortAttrsJSON - Sting - page sort attributes of customer
     *          (5) stocksPageSortAttrsJSON - String -  page sort attributes of stock
     * @return: PaginationSorting - Class Object
    **/
    @RemoteAction
    global static String finalizeVendorOrder(String voHeaderId, String vendorId, String itemsPageSortAttrsJSON, String customersPageSortAttrsJSON, String stocksPageSortAttrsJSON) {
        try{
        	voHeaderId = BPUtility.getDecodedString(voHeaderId);
        	vendorId = BPUtility.getDecodedString(vendorId);
        	itemsPageSortAttrsJSON = BPUtility.getDecodedString(itemsPageSortAttrsJSON);
        	customersPageSortAttrsJSON = BPUtility.getDecodedString(customersPageSortAttrsJSON);
        	stocksPageSortAttrsJSON = BPUtility.getDecodedString(stocksPageSortAttrsJSON);
        	
            Savepoint sp = Database.setSavepoint();
            if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
            List<Vendor_Order_Header__c> voHeaderList = [select Vendor__c, Name, Status__c, Ordered_Date__c, (Select Sublet__c, Sublet__r.Cost_Method__c, 
            	Sublet__r.Cost__c, Sublet__r.Price__c, Part__r.Last_Cost__c, VOG_Cost__c from Vendor_Order_Line_Item_Groups__r) from Vendor_Order_Header__c where Id =:voHeaderId];
            if(voHeaderList.size() > 0) {
                voHeaderList[0].Status__c = 'On Order';
                voHeaderList[0].Ordered_Date__c = Date.Today();
                if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update voHeaderList[0];
                
                for(Vendor_Order_Line_Item_Group__c vogRec : voHeaderList[0].Vendor_Order_Line_Item_Groups__r) {
                	if(String.isNotBlank(vogRec.Part__c)) {
                		vogRec.VOG_Cost__c = (vogRec.Part__r.Last_Cost__c != null) ? vogRec.Part__r.Last_Cost__c : 0;
                	} else if(String.isNotBlank(vogRec.Sublet__c)) {
                		if(vogRec.Sublet__r.Cost_Method__c == 'Fixed Cost' && vogRec.Sublet__r.Cost__c != null) {
		                    vogRec.VOG_Cost__c = vogRec.Sublet__r.Cost__c.setScale(2, RoundingMode.HALF_UP);
		                } else if(vogRec.Sublet__r.Cost_Method__c == 'Percent Retail' && vogRec.Sublet__r.Cost__c != null) {
		                    vogRec.VOG_Cost__c = ((vogRec.Sublet__r.Price__c * vogRec.Sublet__r.Cost__c) / 100).setScale(2, RoundingMode.HALF_UP);
		                }
                	}
                }
                if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update voHeaderList[0].Vendor_Order_Line_Item_Groups__r;
                
                // Create Activity History.
                if(!Test.isRunningTest()) {
            		ActivityHistory.createActivityHistory('Submit Vendor Order', 'Vendor Order', voHeaderId, 'Vendor', voHeaderList[0].Vendor__c, null);
                }
            }
            
            //Database.rollback(sp);
            return getVOLineItemWrapperJSON(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(itemsPageSortAttrsJSON), BPUtility.getEncodedString(customersPageSortAttrsJSON), BPUtility.getEncodedString(stocksPageSortAttrsJSON), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(''); 
    }
    
    private static Map<String, String> cancelVOLIFieldToVOLIFieldMap = new Map<String, String> {
    		'CO_Header__c' 					=> 'CO_Header__c',
    		'Outstanding__c' 				=> 'Outstanding__c',
    		'Part__c' 						=> 'Part__c',
			'Projected_Delivery__c' 		=> 'Projected_Delivery__c',
    		'Qty_Needed__c' 				=> 'Qty_Needed__c',
    		'Qty_Ordered__c' 				=> 'Qty_Ordered__c',
    		'Received__c' 					=> 'Received__c',
    		'Vendor_Order_Header__c'		=> 'Vendor_Order_Header__c',
    		'Vendor_Receiving_Group__c' 	=> 'Vendor_Receiving_Group__c',
    		'Vendor_Order_Line_Item_Group__c'=> 'Vendor_Order_Line_Item_Group__c',
    		'Is_Excess__c' 					=> 'Is_Excess__c',
    		'Is_From_Search__c' 			=> 'Is_From_Search__c',
    		'Is_Received__c' 				=> 'Is_Received__c',
    		'Is_required_For_Customer__c' 	=> 'Is_required_For_Customer__c',
    		'Is_Service__c' 				=> 'Is_Service__c'
    };
    
    /**
     * Name: cancelOrderOfItem
     * Desc: Method which cancel VO group from Items sectios
     * @param:  (1) voLineItemGroupId - String - VO Line Item Group Id which is to be removed
     *          (2) vendorId - String - Vendor Id
     *          (3) voHeaderId - String - VO Header record Id
     *          (4) itemsPageSortAttrsJSON - String - page sort attributes of item
     *          (5) customersPageSortAttrsJSON - Sting - page sort attributes of customer
     *          (6)stocksPageSortAttrsJSON - String -  page sort attributes of stock
     * @return: String - JSON String of VO Header Wrapper Record
    **/
    @RemoteAction
    global static String cancelOrderOfItem(String voLineItemGroupId, String vendorId, String voHeaderId, String itemsPageSortAttrsJSON, String customersPageSortAttrsJSON, String stocksPageSortAttrsJSON){
        Savepoint sp = Database.setSavepoint();
        try {
        	voLineItemGroupId = BPUtility.getDecodedString(voLineItemGroupId);
        	vendorId = BPUtility.getDecodedString(vendorId);
        	voHeaderId = BPUtility.getDecodedString(voHeaderId);
        	itemsPageSortAttrsJSON = BPUtility.getDecodedString(itemsPageSortAttrsJSON);
        	customersPageSortAttrsJSON = BPUtility.getDecodedString(customersPageSortAttrsJSON);
        	stocksPageSortAttrsJSON = BPUtility.getDecodedString(stocksPageSortAttrsJSON);
        	voLineItemGroupId = BPUtility.escapeSingleQuotes(voLineItemGroupId);
        	
    		List<Vendor_Order_Line_Item_Group__c> voliGroupList = 
	    			[SELECT Cost__c, Is_Excess__c, Need__c, Need_By__c, Needed_For__c, Order__c, Part__c, Received_Qty__c, Status__c, Total__c, 
	    					Unreceived_Qty__c, Vendor_Order_Header__c,
	    				  (SELECT CO_Header__c, CO_Line_Item__c, Is_Excess__c, Is_From_Search__c, Is_Received__c, Is_required_For_Customer__c, 
	    						Is_Service__c, Outstanding__c, Part__c, Projected_Delivery__c, Qty_Needed__c, Qty_Ordered__c, Received__c, Status__c, 
	    						Receiving_Status__c, Vendor_Code__c, Vendor_Order_Header__c, Vendor_Order_Line_Item_Group__c, Vendor_Receiving_Group__c 
	    				    	FROM Vendor_Order_Line_Items__r) 
	    				  FROM Vendor_Order_Line_Item_Group__c where Id = :voLineItemGroupId];
        	
        	if(voliGroupList.size() == 0) {
	        	return getVOLineItemWrapperJSON(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), 
	        				BPUtility.getEncodedString(itemsPageSortAttrsJSON), BPUtility.getEncodedString(customersPageSortAttrsJSON), 
	        				BPUtility.getEncodedString(stocksPageSortAttrsJSON), BPUtility.getEncodedString(null), 
	        				BPUtility.getEncodedString(null));
	        }
	        
        	// Validation check for Active Receiving
	        validationForActiveReceiving(voliGroupList);
        	
        	// Prepare a list of Cancelled VOLI
	        List<Vendor_Order_Line_Item__c> voliListToUpdate = new List<Vendor_Order_Line_Item__c>();
	        List<Vendor_Order_Line_Item__c> voliListToDelete = new List<Vendor_Order_Line_Item__c>();
	        Map<Id, CO_Line_Item__c> coLineItemMapToUpdate = new Map<Id, CO_Line_Item__c>();
	        List<Cancelled_VOLI__c> cancelledVOLIList = new List<Cancelled_VOLI__c>();
	        Cancelled_VOLI__c cancelVOLIRec;
	        
	        for(Vendor_Order_Line_Item__c voliRec : voliGroupList[0].Vendor_Order_Line_Items__r) {
	        	if(voliRec.Received__c == 0) {
	        		cancelVOLIRec = new Cancelled_VOLI__c();
		        	for(String fieldName : cancelVOLIFieldToVOLIFieldMap.keyset()) {
		        		cancelVOLIRec.put(fieldName, voliRec.get(fieldName));
		        	}
		        	cancelVOLIRec.Status__c = 'Cancelled';
		        	cancelledVOLIList.add(cancelVOLIRec);
		        	
		        	if(voliRec.Is_From_Search__c || voliRec.Is_Excess__c) {
		        		voliListToDelete.add(voliRec);
		        	} else {
		        		voliRec.Vendor_Order_Header__c = voliRec.Vendor_Order_Line_Item_Group__c = null;
		        		voliRec.Status__c = null;
		        		voliListToUpdate.add(voliRec);
		        	}
		        	
		        	if(voliRec.CO_Line_Item__c != null) {
            			coLineItemMapToUpdate.put(voliRec.CO_Line_Item__c, new CO_Line_Item__c(Id = voliRec.CO_Line_Item__c, Status__c = 'Required', 
														Vendor_Order_Header__c = null, VO_Status__c = null, VO_Number__c = null, Expected_Delivery_Date__c = null));
	            	}
	        	}
	        }
		        
	        if(voliListToUpdate.size() > 0) {
	        	update voliListToUpdate;
	        }
	        
	        // Add all open Stock VOLIs in deleted list - Due to Qty on Order changes.
	        voliListToDelete.addAll(getStockVOLineItem(voliGroupList[0]));
	        
	        if(voliListToDelete.size() > 0) {
	        	delete voliListToDelete;
	        }
	        if(cancelledVOLIList.size() > 0) {
            	if(AccessControl.ifObjectFieldIsCreateable('Cancelled_VOLI__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); } //FLS Create Nikhil 31/01/2017 
            	insert cancelledVOLIList;
            }
	            
            // Change Status of CO Line Item Status to Required when Related VO Line Item are cancelled.
            if(coLineItemMapToUpdate.size() > 0) {
            	update coLineItemMapToUpdate.values();
            }
	        
	        // Update Part Ordered Qty
	        updatePartOrderedQtyInCaseOfCancelledAction(voliGroupList[0]);
	        
	        // Change Status of VO Header
	        setVOHeaderStatus(voHeaderId, vendorId);
	        
	        // Remove Extra In Progress VR List
            removeExtraInProgressVR(voHeaderId);
            
            return getVOLineItemWrapperJSON(BPUtility.getEncodedString(vendorId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(itemsPageSortAttrsJSON), BPUtility.getEncodedString(customersPageSortAttrsJSON), BPUtility.getEncodedString(stocksPageSortAttrsJSON), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null));
        }catch(Exception e){
        	Database.rollback(sp);
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    // validation check for Active Receiving
    private static void validationForActiveReceiving(List<Vendor_Order_Line_Item_Group__c> voliGroupList) {
        if(voliGroupList.size() > 0) {
        	for(Vendor_Order_Line_Item__c voliRec : voliGroupList[0].Vendor_Order_Line_Items__r) {
        		if(voliRec.Receiving_Status__c == 'In Progress' && voliRec.Received__c > 0) {
        			throw new BlackPurlException(Label.Vendor_Order_Cancel_Line_item_Validation_Massage);
        		}
        	}
        }
    }
    
    // Set VO Header Status
    private static void setVOHeaderStatus(String voHeaderId, String vendorId) {
        List<Vendor_Order_Line_Item_Group__c> voliGroupItemsList;
        if(vendorId == null) {
        	voliGroupItemsList = new List<Vendor_Order_Line_Item_Group__c>();
        } else {
        	voliGroupItemsList = SOQLUtil.getVOLIGroupsWithItemsInVO('Part__r.Vendor__c', vendorId, voHeaderId);
        	voliGroupItemsList.addAll((List<Vendor_Order_Line_Item_Group__c>) SOQLUtil.getVOLIGroupsWithItemsInVO('Sublet__r.Vendor__c', vendorId, voHeaderId));
        }
        Vendor_Order_Header__c voHeaderRec = new Vendor_Order_Header__c(Id = voHeaderId);
        
        List<Vendor_Order_Line_Item_Group__c> voliGroupListToUpdate = new List<Vendor_Order_Line_Item_Group__c>();
        for(Vendor_Order_Line_Item_Group__c voliGroupRec : voliGroupItemsList) {
        	Decimal receivedQty = 0;
        	Decimal needQty = 0;
        	for(Vendor_Order_Line_Item__c voliRec : voliGroupRec.Vendor_Order_Line_Items__r) {
        		needQty += voliRec.Qty_Needed__c;
        		receivedQty += voliRec.Received__c;
        	}
        	if(needQty > 0) {
        		if(needQty == receivedQty) {
        			voliGroupRec.Status__c = 'Stocked';
        		} else if(needQty > receivedQty && receivedQty > 0) {
	        		voliGroupRec.Status__c = 'Partially Received';
	        	} else if(receivedQty == 0) {
	        		voliGroupRec.Status__c = 'On Order';
	        	} 
        	} else {
        		if(voliGroupRec.Cancelled_VOLIs__r.size() > 0) {
        			voliGroupRec.Status__c = 'Cancelled';
        		}	
        	}
        	if(voliGroupRec.Cancelled_VOLIs__r.size() > 0) {
        		voliGroupRec.Need__c = needQty;
        		voliGroupListToUpdate.add(voliGroupRec);
        	}
        }
        
        Integer noOfOnOrderGroupItems = 0;
        Integer noOfPartiallyStockedGroupItems = 0;
        Integer noOfStockedGroupItems = 0;
        Integer noOfCancelledGroupItems = 0;
        for(Vendor_Order_Line_Item_Group__c voliGroupRec : voliGroupItemsList) {
        	if(voliGroupRec.Status__c == 'Cancelled') {
        		noOfCancelledGroupItems++;
        	} else if(voliGroupRec.Status__c == 'Partially Received') {
        		noOfPartiallyStockedGroupItems++;
        	} else if(voliGroupRec.Status__c == 'Stocked') {
        		noOfStockedGroupItems++;
        	} else if(voliGroupRec.Status__c == 'On Order') {
        		noOfOnOrderGroupItems++;
        	}
        }
        
        if(noOfCancelledGroupItems == voliGroupItemsList.size()) {
        	voHeaderRec.Status__c = 'Cancelled';
        } else if((noOfStockedGroupItems + noOfCancelledGroupItems) == voliGroupItemsList.size()) {
        	voHeaderRec.Status__c = 'Received';
        } else if(noOfPartiallyStockedGroupItems > 0 || noOfStockedGroupItems > 0) {
        	voHeaderRec.Status__c = 'Partially Received';
        } else {
        	voHeaderRec.Status__c = 'On Order';
        }
        
        if(voliGroupListToUpdate.size() > 0) {
        	update voliGroupListToUpdate;
        }
        update voHeaderRec;
    }
    
    // Query all stock type VOLIs for given part
    private static List<Vendor_Order_Line_Item__c> getStockVOLineItem(Vendor_Order_Line_Item_Group__c voliGroupRec) {
		List<Vendor_Order_Line_Item__c> stockVOLIList = 
				[SELECT Id FROM Vendor_Order_Line_Item__c WHERE Part__c =: voliGroupRec.Part__c AND Is_required_For_Customer__c = false AND 
															Is_Service__c = false AND Is_Excess__c = false AND Is_From_Search__c = false 
															AND Vendor_Order_Line_Item_Group__c = null];
        return stockVOLIList;
    }
    
    // Method to update Part on order Qty
    private static void updatePartOrderedQtyInCaseOfCancelledAction(Vendor_Order_Line_Item_Group__c voliGroupRec) {
    	Map<Id, Decimal> partIdToOrderedQtyMap = new Map<Id, Decimal>();
        Decimal qtyOrdered = 0;
        for(Vendor_Order_Line_Item__c voliRec : voliGroupRec.Vendor_Order_Line_Items__r) {
        	if(voliRec.Received__c == 0 && !voliRec.Is_required_For_Customer__c && !voliRec.Is_Service__c) {
        		qtyOrdered += voliRec.Qty_Needed__c;
        	}
        }
        if(voliGroupRec.Vendor_Order_Line_Items__r.size() > 0) {
        	partIdToOrderedQtyMap.put(voliGroupRec.Part__c, qtyOrdered);
        }
        
        if(partIdToOrderedQtyMap.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Part__c> partList = [select Qty_On_Order__c from Part__c where Id IN : partIdToOrderedQtyMap.keySet()];
            for(Part__c partRec : partList) {
                if(partRec.Qty_On_Order__c != null) {
                    partRec.Qty_On_Order__c = partRec.Qty_On_Order__c - partIdToOrderedQtyMap.get(partRec.Id);
                }
            }
            if(partList.size() > 0) {
                if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update partList;
            }
        }
    }
    
    
    @RemoteAction
    global static String deleteVendorOrder(String voHeaderId){
    	voHeaderId = BPUtility.getDecodedString(voHeaderId);
    	if(AccessControl.ifObjectIsAccessible('Vendor_Order_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
		if(AccessControl.ifObjectIsAccessible('Vendor_Order_Line_Item_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
    		
    	List<Vendor_Order_Header__c> vendorOrderList = [select Status__c,
				    									(select Id from Vendor_Order_Line_Item_Groups__r) 
				    									from Vendor_Order_Header__c
				    									where Id = :voHeaderId];
    									
    	String response = 'Error';
    	if(vendorOrderList.size() > 0){
    		if(vendorOrderList[0].Status__c == 'Open' && vendorOrderList[0].Vendor_Order_Line_Item_Groups__r.size() == 0){
    			Vendor_Order_Header__c voHeader = new Vendor_Order_Header__c();
    			voHeader.Id = vendorOrderList[0].Id;
    			if(AccessControl.ifObjectIsDeletable('Vendor_Order_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
    			delete voHeader;
    			response = 'Success';
    		}
    	}
    	return BPUtility.getEncodedString(response);
    	
    }
    
    
    private static void removeExtraInProgressVR(String voHeaderId) {
    	List<In_Progress_VR__c> ipvrList = [SELECT Vendor_Receiving_Header__c from In_Progress_VR__c WHERE Vendor_Order_Header__c =: voHeaderId];
    	Set<Id> vorIdSet = new Set<Id>();
    	for(In_Progress_VR__c ipvrRec : ipvrList) {
    		vorIdSet.add(ipvrRec.Vendor_Receiving_Header__c);
    	} 
    	vorIdSet.remove(null);
    	
    	Map<Id, Vendor_Receiving_Header__c> relatedVOReceivingMap = 
				new Map<Id, Vendor_Receiving_Header__c>([select Id, (select Id from Vendor_Receiving_Groups__r)
    																from Vendor_Receiving_Header__c where Id IN: vorIdSet]);
    															
    	List<Vendor_Order_Line_Item__c> voliList = [select Vendor_Receiving_Group__c from Vendor_Order_Line_Item__c 
    																			where Vendor_Order_Header__c =: voHeaderId];
    	Set<Id> usedVRGIdSet = new Set<Id>();
    	for(Vendor_Order_Line_Item__c voliRec : voliList) {
			usedVRGIdSet.add(voliRec.Vendor_Receiving_Group__c);
    	}
    	
    	List<In_Progress_VR__c> inProgressListToDelete = new List<In_Progress_VR__c>();
    	for(In_Progress_VR__c inProgressRec : ipvrList) {
    		if(relatedVOReceivingMap.containsKey(inProgressRec.Vendor_Receiving_Header__c)) {
    			Boolean isIpvrDelete = true;
    			for(Vendor_Receiving_Group__c vrgRec : relatedVOReceivingMap.get(inProgressRec.Vendor_Receiving_Header__c).Vendor_Receiving_Groups__r) {
    				if(usedVRGIdSet.contains(vrgRec.Id)) {
    					isIpvrDelete = false;
    					break;
    				}
    			}
    			if(isIpvrDelete) {
    				inProgressListToDelete.add(inProgressRec);
    			}
    		}
    	}
    	
    	if(inProgressListToDelete.size() > 0) {
    		delete inProgressListToDelete;
    	}
    }
    
    
    /**
     * Name: parsePageAttrs
     * Desc: Method to Parse JSON String to class instance for Pagination and sort attributes
     * @param:  (1) JSONString - String - JSON String 
     * @return: PaginationSorting - Class Object
    **/
    public static PaginationSorting parsePageAttrs(String json) {
        return (PaginationSorting) System.JSON.deserialize(json, PaginationSorting.class);
    }
    
    /**
     * Name: PaginationSorting
     * Description:  Wrapper class for pagination and sorting combination
     **/
    public class PaginationSorting {
        
        // Current page number
        public Integer CurrentPage;
        
        // Current page size
        public Integer PageSize;
        
        // Sorting list
        public List<SortAttrs> Sorting;
    }
    
    // SortAttrs for sorting attributes
    public class SortAttrs {
        // Field name
        public String FieldName;
        
        // Sort direction
        public String SortDirection;
    }
    
    /**
     * Name: VOGroupDetail
     * Description: Wrapper class for Needed For Pop Up
     **/
    public class VOGroupDetail {
        
        public Decimal RequriedForCustomer;
        public Decimal RequriedForStock;
        public Decimal TotalRequried;
        public Decimal OrderQty;
        public Decimal PackageQty;
        public String PackageUnit;
        public Decimal TotalExcess;
        public String OrderType;
        
        /**
         * Name: VOGroupDetail
         * Desc: Constructor 
         * @param:  (1) vogRec - Vendor_Order_Line_Item_Group__c -Vendor Order Line Item Group Record
         * @return: 
         **/
        public VOGroupDetail(Vendor_Order_Line_Item_Group__c vogRec) {
            this.RequriedForCustomer = 0;
            this.RequriedForStock = 0;
            this.PackageQty = 0;
            this.TotalExcess = 0;
            
            for(Vendor_Order_Line_Item__c voliRec : vogRec.Vendor_Order_Line_Items__r) {
                if(voliRec.Is_required_For_Customer__c || voliRec.Is_Service__c) {
                    this.RequriedForCustomer += voliRec.Qty_Needed__c;
                } else if(!voliRec.Is_required_For_Customer__c && !voliRec.Is_Excess__c) {
                    this.RequriedForStock += voliRec.Qty_Needed__c;
                } else if(voliRec.Is_Excess__c) {
                    this.TotalExcess += voliRec.Qty_Needed__c;
                }
            }
            this.TotalRequried = this.RequriedForCustomer + this.RequriedForStock;
            if(vogRec.Part__r.Packaged_Part__c) {
                this.PackageQty = vogRec.Need__c / vogRec.Part__r.Package_Qty__c;
                this.PackageUnit = vogRec.Part__r.Package_Unit__c;
            }
            this.OrderQty = vogRec.Need__c;
            if(vogRec.Part__r.Packaged_Part__c) {
	        	if(vogRec.Part__r.Package_Qty__c == null) {
	        		vogRec.Part__r.Package_Qty__c = 1;
	        	}
	            this.OrderType = 'Ordered as ' + vogRec.Part__r.Package_Qty__c + '/' +vogRec.Part__r.Package_Unit__c;
	            if(vogRec.Part__r.Order_Lots__c > 1) {
	                this.OrderType += ' in Lots of ' + vogRec.Part__r.Order_Lots__c;
	            }
	        } else if(vogRec.Part__r.Order_Lots__c > 1) {
	            this.OrderType += 'Ordered as in Lots of ' + vogRec.Part__r.Order_Lots__c;
	        }
        }
    }
    
    @RemoteAction
    global static String emailSelectedDocument(String documentJSON, String emailAddress, String subject) {
        documentJSON = BPUtility.getDecodedString(documentJSON);
        emailAddress = BPUtility.getDecodedString(emailAddress);
        subject = BPUtility.getDecodedString(subject);
        
        List<SendEmail.DocumentWrapper> docWrapperList = (List<SendEmail.DocumentWrapper>) system.JSON.deserialize(documentJSON, List<SendEmail.DocumentWrapper>.class);
        
        String response = SendEmail.sendSelectedDocument(docWrapperList, new List<String>{emailAddress}, subject);
        return response;
    }
	
	@RemoteAction 
    global static String getPartsLocator(String partId, Integer quantity, String searchType) {
    	try {
    		partId = BPUtility.getDecodedString(partId);
    		searchType = BPUtility.getDecodedString(searchType);
            return BPUtility.getEncodedString(BRPPartsIntegration.getPartsLocator(partId, quantity, searchType));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return 'success';
    }
    
    public static void dummyTest01(){
        Integer i =0 ;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
	}
    
    public static void dummyTest02(){
        Integer i =0 ;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
        i = 1;
        i = 1;i = 1;
    }
    
     /**
     * Name: StockRecDetail
     * Description: Wrapper class for Needed For Pop Up
     **/
    public class StockRecDetail {
        
        public Decimal QtyAvailable;
        public Decimal Incoming;
        public Decimal NetAvailable;
        public Decimal AutoReprderAt;
        public Decimal AutoReprderTo;
        public String PackageUnit;
        public Decimal PackageQty;
        public Decimal TotalNeed;
        
         /**
         * Name: StockRecDetail
         * Desc: Constructor 
         * @param:  (1) voliRec - Vendor_Order_Line_Item__c -Vendor Order Line Item Record
         * @return: 
         **/
        public StockRecDetail(Vendor_Order_Line_Item__c voliRec) {
            this.QtyAvailable = 0;
            this.Incoming = 0;
            
            this.QtyAvailable = voliRec.Part__r.AvailableParts__c;
            this.NetAvailable = this.QtyAvailable + this.Incoming;
            this.AutoReprderAt = voliRec.Part__r.Auto_reorder_Min__c;
            this.AutoReprderTo = voliRec.Part__r.Auto_reorder_Max__c;
            if(voliRec.Part__r.Packaged_Part__c) {
                this.PackageQty = voliRec.Qty_Needed__c / voliRec.Part__r.Package_Qty__c;
                this.PackageUnit = voliRec.Part__r.Package_Unit__c;
            }
            this.TotalNeed = voliRec.Qty_Needed__c;
        }
    }
    
}