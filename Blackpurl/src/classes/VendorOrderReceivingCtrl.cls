/**
 * Author: Ashish Garg
 * Since: Aug 6, 2015 
 * Name: VendorOrderReceivingCtrl
 * Description: Apex class to handle all operations related to Vendor Order Receiving Page.
**/
global with sharing class VendorOrderReceivingCtrl { 
    // Static variable to use current Vendor Order receiving Id
    public static Id Vendor_Order_Receiving_Id;
     

    // Vendor Orders sort order
    public static String VO_Sort_Order;  
    
    // Sort order map
    public static Map<String, String> sortingMap;
    
    public Decimal Related_List_Page_Size { get{return GeneralConfiguration.getRelatedListPageSize();} private set;}
    
    global VendorOrderReceivingCtrl (NewHomePageCtrl controller){}
    public VendorOrderReceivingCtrl() {}
    
    /**
     * Name: addVendor
     * Desc: Method to add selected vendor to vendor receiving order
     * @param:      (1) selectedVendorId - Id - Vendor Id
     *              (2) vorId - String - Vendor Order Receiving Id
     * @return: String - Vendor_Receiving_Header__c Id if successfully selected
    **/
    @RemoteAction
    global static String addVendor(String selectedVendorId, String vorId){
        try{
            selectedVendorId = BPUtility.getDecodedString(selectedVendorId);
            vorId = BPUtility.getDecodedString(vorId);
            Vendor_Receiving_Header__c vrHeader = new Vendor_Receiving_Header__c();
            if(vorId != null){
                vrHeader.Id = vorId;
            }
            vrHeader.Vendor__c = selectedVendorId;
            vrHeader.Owner__c = UserInfo.getUserId();
            vrHeader.Status__c = 'In Progress';
            
            try{
                if(AccessControl.ifObjectIsCreateable('Vendor_Receiving_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
                if(AccessControl.ifObjectIsUpdateable('Vendor_Receiving_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE);}
                upsert vrHeader;
                
                // After Insert, Update all Vendor Order Header for the vendor which are unreceived
                updateVendorOrdersReceiving(vrHeader.Id, true);
            } catch(Exception e){
                //system.assert(false, e);
                return BPUtility.getEncodedString(null);
            }
            return BPUtility.getEncodedString(vrHeader.Id);
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(null);
    }
    
    /**
     * Name: getVORDetails
     * Desc: Method to get all page details for a Vendor Order Receiving record
     * @param:  (1) vorId - String - Vendor Order Receiving Id
     *          (2) gridName - String - Grid Name
     *          (3) lastEditedPartId - Id - Edited Part Id Recently
     *          (4) vendorOrdersPageSortAttrsJSON - String -Vendor Order Headers Grid Paging and sorting JSON
     *          (5) groupItemsPageSortAttrsJSON - String - Items Grid Paging and sorting JSON
     *          (6) outstandingVOGPageSortAttrsJSON - String - Outstanding Grid Paging and sorting JSON
     * @return: String - JSON String of all CO Line Items of CO Header Record
    **/
    @RemoteAction
    global static String getVORDetails( String vorId, 
                                        String gridName,
                                        String lastEditedPartId,
                                        String vendorOrdersPageSortAttrsJSON, 
                                        String groupItemsPageSortAttrsJSON, 
                                        String outstandingVOGPageSortAttrsJSON){
        try{
            vorId = BPUtility.getDecodedString(vorId);
            gridName = BPUtility.getDecodedString(gridName);
            lastEditedPartId = BPUtility.getDecodedString(lastEditedPartId);
            vendorOrdersPageSortAttrsJSON = BPUtility.getDecodedString(vendorOrdersPageSortAttrsJSON);
            groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
            outstandingVOGPageSortAttrsJSON = BPUtility.getDecodedString(outstandingVOGPageSortAttrsJSON);
            
            Vendor_Order_Receiving_Id = vorId;
            PaginationSorting vendorOrdersPageSortAttrs = PaginationSorting.parsePageAttrs(vendorOrdersPageSortAttrsJSON);
            PaginationSorting groupItemsPageSortAttrs = PaginationSorting.parsePageAttrs(groupItemsPageSortAttrsJSON);
            PaginationSorting outstandingVOGPageSortAttrs = PaginationSorting.parsePageAttrs(outstandingVOGPageSortAttrsJSON);
            
            VendorOrderReceiving voReceiving = new VendorOrderReceiving(vorId, gridName, lastEditedPartId, vendorOrdersPageSortAttrs, groupItemsPageSortAttrs, outstandingVOGPageSortAttrs);
            return BPUtility.getEncodedString(System.JSON.serialize(voReceiving));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(null);
    }
    
    /**
     * Name: updateVORHeaderDetails
     * Desc: Method to update various details of vendor receiving header
     * @param:  (1) vorId - String - Vendor Order Receiving Id
     *          (2) VORHeaderJSON- String - Vendor Receiving Header Records JSON String
     * @return:  JSON String of ids of Vendor Receiving Header Record
    **/
    @RemoteAction
    global static String updateVORHeaderDetails(String vorId, String VORHeaderJSON){
        vorId = BPUtility.getDecodedString(vorId);
        VORHeaderJSON = BPUtility.getDecodedString(VORHeaderJSON);
        
        VORHeader VORHeaderRec = VORHeader.parse(VORHeaderJSON);
        Vendor_Receiving_Header__c vorHeaderToUpdate = new Vendor_Receiving_Header__c(  Id = vorId,
                                                                                        Packing_Slip_Number__c = VORHeaderRec.PackagingSlipNumber,
                                                                                        Is_Receiving_From_Invoice__c = VORHeaderRec.IsReceivingFromInvoice,
                                                                                        Receiving_From_Invoice_Total__c = VORHeaderRec.ReceivingFromInvoiceTotal);
        try{
            if(AccessControl.ifObjectIsUpdateable('Vendor_Receiving_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE);}
            if(!isSimilarPackingSlipNumberExists(VORHeaderRec)) {
                update vorHeaderToUpdate;
            } 
            return BPUtility.getEncodedString(System.JSON.serialize(VORHeader.getVORDetails(vorId)));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(null);
    }
    
    private static Boolean isSimilarPackingSlipNumberExists(VORHeader VORHeaderRec) {
        if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        List<Vendor_Receiving_Header__c> vorList = [Select Packing_Slip_Number__c from Vendor_Receiving_Header__c where Vendor__c = :VORHeaderRec.VendorId];
        for(Vendor_Receiving_Header__c vorRec : vorList) {
            if(String.isNotBlank(vorRec.Packing_Slip_Number__c) && String.isNotBlank(VORHeaderRec.PackagingSlipNumber) && vorRec.Packing_Slip_Number__c.equalsIgnoreCase(VORHeaderRec.PackagingSlipNumber)) {
                return true;
            }
        }
        return false;
    }
    /**
     * Name: receiveVendorOrderItems
     * Desc: Method to add/remove slelected vendor order items for receiving
     * @param:  (1) vohId - Selected vendor order Id
     *          (2) vorId - String - Vendor Order Receiving Id
     *          (3) isSelected - boolean - is Selected or not
     * @return: String - boolean if successfully selected
    **/
    @RemoteAction
    global static String receiveVendorOrderItems(String vohId, String vorId, boolean isSelected){
        try{
            vohId = BPUtility.getDecodedString(vohId);
            vorId = BPUtility.getDecodedString(vorId);
            if(vohId != null){
                return updateVendorOrdersReceiving(vohId, vorId);
            } else {
                return updateVendorOrdersReceiving(vorId, isSelected);
            }
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(null);
    }
    
    /**
     * Name: updateVendorOrdersReceiving
     * Desc: Method to add/remove selected vendor order items for receiving
     * @param:  (1) vohId - Selected vendor order Id
     *          (2) vorId - String - Vendor Order Receiving Id
     * @return: String - boolean if successfully selected
    **/
    private static String updateVendorOrdersReceiving(String vohId, String vorId){
        if(vorId != null) {
            In_Progress_VR__c inProgressVRRec = new In_Progress_VR__c();
            inProgressVRRec.Vendor_Order_Header__c = vohId;
            inProgressVRRec.Vendor_Receiving_Header__c = vorId;
            
            try{
                if(AccessControl.ifObjectIsCreateable('In_Progress_VR__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);} 
                insert inProgressVRRec;
            } catch(Exception e){
                return BPUtility.getEncodedString('false');
            }
        } else {
            if(AccessControl.ifObjectIsAccessible('In_Progress_VR__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            if(AccessControl.ifObjectIsAccessible('Vendor_Order_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            // Remove 
            List<In_Progress_VR__c> inProgressVRList = [select Vendor_Receiving_Header__c from In_Progress_VR__c 
                                                            Where Vendor_Receiving_Header__r.Status__c = 'In Progress' 
                                                                    AND Vendor_Order_Header__c = :vohId];
            
            String VendorReceivingHeader = '';
            for(In_Progress_VR__c ipvr : inProgressVRList){
                    VendorReceivingHeader = ipvr.Vendor_Receiving_Header__c ; 
            }
            
            if(!string.Isblank(VendorReceivingHeader)){
            
            //added by subhrant to remove VO header FRom receivng
                
                List<Vendor_Receiving_Group__c>  InProgressRecevingGroupList = [select Id from Vendor_Receiving_Group__c where Vendor_Receiving_Header__c  =: VendorReceivingHeader];
                
                set<Id> InProgressRecevingGroupSet = new set<Id>();
                
                for(Vendor_Receiving_Group__c  recevingGroupItem  : InProgressRecevingGroupList){
                    InProgressRecevingGroupSet.add(recevingGroupItem.Id);
                }                                                   
                //added by subhrant to remove VO header FRom receivng
                List<Vendor_Order_Line_Item__c> listToUpdateVendorOrderLineItem = [select Qty_Needed__c,Received__c,Vendor_Receiving_Group__c
                                                                                 From Vendor_Order_Line_Item__c where Vendor_Order_Header__c =:vohId 
                                                                                  and Vendor_Receiving_Group__c IN :(InProgressRecevingGroupSet)  ]; // add status condtion also
                    
            
                set<Id>  ImpactedVendorRecievingGroup = new set<Id>();
             
                for(Vendor_Order_Line_Item__c voliItem : listToUpdateVendorOrderLineItem ){
                    ImpactedVendorRecievingGroup.add(voliItem.Vendor_Receiving_Group__c);
                    voliItem.Received__c = 0;
                    voliItem.Vendor_Receiving_Group__c = null;
                }   
            
                if(listToUpdateVendorOrderLineItem.size() > 0){
                    if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update  listToUpdateVendorOrderLineItem;
                } 
                
                List<Vendor_Receiving_Group__c> vrGroupList = [select Id, Recieved__c, (select Qty_Needed__c,Received__c from Vendor_Order_Line_Items__r) from Vendor_Receiving_Group__c where Id IN :ImpactedVendorRecievingGroup];
                
                List<Vendor_Receiving_Group__c> vrGroupTodelete = new List<Vendor_Receiving_Group__c>();
                List<Vendor_Receiving_Group__c> vrGroupListToUpdate = new List<Vendor_Receiving_Group__c>();
                
                for(Vendor_Receiving_Group__c vrgRec : vrGroupList) {
                    Decimal need = 0;
                    Decimal received = 0;
                    if(vrgRec.Vendor_Order_Line_Items__r !=null && vrgRec.Vendor_Order_Line_Items__r.size() > 0){
                        for(Vendor_Order_Line_Item__c voliRec : vrgRec.Vendor_Order_Line_Items__r) {
                            received += voliRec.Received__c;
                        }
                        vrgRec.Recieved__c = received;
                        vrGroupListToUpdate.add(vrgRec);
                    }else{
                        vrGroupTodelete.add(vrgRec);
                    }
                    
                }
                
                //Remove It 
                if(vrGroupListToUpdate.size() > 0) {
                    if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Receiving_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update vrGroupListToUpdate;
                }
                if(vrGroupTodelete.size() > 0 ){
                    if(AccessControl.ifObjectIsDeletable('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                    delete vrGroupTodelete;
                }
            }
            //system.assert(false,inProgressVRList);
            if(inProgressVRList.size() > 0) {
                if(AccessControl.ifObjectIsDeletable('In_Progress_VR__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                delete inProgressVRList;
            }                                                       
        }
        return BPUtility.getEncodedString('true');
    }
    
    /**
     * Name: updateVendorOrdersReceiving
     * Desc: Method to update selected vendor order items for receiving
     * @param:  (1) vorId - String - Vendor Order Receiving Id
     *          (2) isSelected - boolean  - is Selected or not
     * @return: String - boolean if successfully selected
    **/
    private static String updateVendorOrdersReceiving(String vorId, boolean isSelected){
        List<In_Progress_VR__c> inProgressVRList = new List<In_Progress_VR__c>();
        if(AccessControl.ifObjectIsAccessible('In_Progress_VR__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}

        if(isSelected){
            List<In_Progress_VR__c> inProgressList = [select Vendor_Receiving_Header__c,
                                                           Vendor_Order_Header__c
                                                           from In_Progress_VR__c  
                                                           Where Vendor_Receiving_Header__r.Status__c = 'In Progress' 
                                                  ];
            List<Vendor_Receiving_Header__c> vorHeaderRecords = SOQLUtil.getVORDetails('Id', vorId);
            if(vorHeaderRecords.size() > 0){
                Set<Id> inProgressVOIds = new Set<id>();
                for(In_Progress_VR__c ipvr : inProgressList){
                    inProgressVOIds.add(ipvr.Vendor_Order_Header__c);
                }
                
                List<Vendor_Order_Header__c> voList = SOQLUtil.getVendorOrderHeaderRecords('Vendor__c', vorHeaderRecords[0].Vendor__c, null, true);
                In_Progress_VR__c inProgressVRRec;
                for(Vendor_Order_Header__c vo : voList){
                    inProgressVRRec = new In_Progress_VR__c();
                    if( !inProgressVOIds.contains(vo.Id) ){
                        inProgressVRRec.Vendor_Order_Header__c = vo.Id;
                        inProgressVRRec.Vendor_Receiving_Header__c = vorId;
                        inProgressVRList.add(inProgressVRRec);
                    }
                }
                if(inProgressVRList.size() > 0) {
                    if(AccessControl.ifObjectIsCreateable('In_Progress_VR__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
                    insert inProgressVRList;
                }
            }
        } else {
            inProgressVRList = [select Vendor_Receiving_Header__c,
                                                           Vendor_Order_Header__c
                                                           from In_Progress_VR__c  
                                                           Where Vendor_Receiving_Header__r.Status__c = 'In Progress' 
                                                           AND Vendor_Receiving_Header__c = :vorId
                                                  ];
            if(inProgressVRList.size() > 0) {
                if(AccessControl.ifObjectIsDeletable('In_Progress_VR__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                delete inProgressVRList;
            }                                                       
        }
        return BPUtility.getEncodedString(String.valueOf(true));
    }
    
    
    @RemoteAction
    global static String getAllVOLIGroupItem(String vendorId, String vrHeaderId) {
        try{
            vendorId = BPUtility.getDecodedString(vendorId);
            vrHeaderId = BPUtility.getDecodedString(vrHeaderId);
            
            List<In_Progress_VR__c> inProgressVRList = [select Vendor_Order_Header__c, Vendor_Receiving_Header__c 
                                                                from In_Progress_VR__c where Vendor_Receiving_Header__r.Status__c = 'In Progress'];
                                                                
            List<Id> selectedVOHeaderIdList = new List<Id>();
            for(In_Progress_VR__c inProgressVrRec : inProgressVRList){
                if(inProgressVrRec.Vendor_Receiving_Header__c ==  vrHeaderId ){
                    selectedVOHeaderIdList.add(inProgressVrRec.Vendor_Order_Header__c); 
                }
            }
            List<Vendor_Order_Line_Item__c> voLineItems = [select Part__c, Sublet__c, Cost__c, Vendor_Receiving_Group__c 
                                                            from Vendor_Order_Line_Item__c where Vendor_Order_Header__r.In_Progress_VR__c != :vrHeaderId 
                                                            AND Vendor_Order_Header__c IN : selectedVOHeaderIdList
                                                            AND Vendor_Receiving_Group__c = null];
                                        
            //List<Vendor_Order_Line_Item_Group__c> voLineItemGroupList = SOQLUtil.getVOLIGroupsWithItems('Vendor_Order_Header__r.Vendor__c', vendorId, selectedVOHeaderIdList);
            
            Set<Id> selectedRecIdList = new Set<Id>();
            for(Vendor_Order_Line_Item__c voliRec : voLineItems) {
                if(voliRec.Part__c != null) {
                    selectedRecIdList.add(voliRec.Part__c);
                } else if(voliRec.Sublet__c != null) {
                    selectedRecIdList.add(voliRec.Id);
                }
            }
            //system.assert(false, selectedRecIdList);
            return BPUtility.getEncodedString(System.JSON.serialize(selectedRecIdList));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    
    @RemoteAction 
    global static String groupSelectedLineItems(String vrHeaderId, String selectedRecIds, String vendorOrdersPageSortAttrsJSON, String groupItemsPageSortAttrsJSON, String outstandingVOGPageSortAttrsJSON){
        try {
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Receiving_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            
            vrHeaderId = BPUtility.getDecodedString(vrHeaderId);
            selectedRecIds = BPUtility.getDecodedString(selectedRecIds);
            vendorOrdersPageSortAttrsJSON = BPUtility.getDecodedString(vendorOrdersPageSortAttrsJSON);
            groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
            outstandingVOGPageSortAttrsJSON = BPUtility.getDecodedString(outstandingVOGPageSortAttrsJSON);
            
            List<String> selectedRecIdList = (List<String>) System.JSON.deserialize(selectedRecIds, List<String>.class);
            List<In_Progress_VR__c> inProgressVRList = [select Vendor_Order_Header__c from In_Progress_VR__c where Vendor_Receiving_Header__c =: vrHeaderId
                                                                        AND Vendor_Receiving_Header__r.Status__c = 'In Progress'];
            List<Id> selectedVOHeaderIdList = new List<Id>();
            for(In_Progress_VR__c inProgressVrRec : inProgressVRList){
                selectedVOHeaderIdList.add(inProgressVrRec.Vendor_Order_Header__c); 
            }
                
            List<Vendor_Order_Line_Item__c> voLineItems = new List<Vendor_Order_Line_Item__c>();
            //voLineItems = SOQLUtil.getVOLineItemByFieldValue(new Map<String, List<String>> {'Vendor_Order_Line_Item_Group__c' => selectedGroupIdList});
            voLineItems = [select Id, Part__c, Qty_Needed__c, Sublet__c, Cost__c, Vendor_Receiving_Group__c, Service_Order_Line_Item__c 
                                        from Vendor_Order_Line_Item__c where Vendor_Order_Header__c IN :selectedVOHeaderIdList 
                                        AND (Part__c IN : selectedRecIdList OR Id IN : selectedRecIdList)
                                        AND Vendor_Receiving_Group__c = null];
                                        
            List<Vendor_Order_Line_Item__c> tempVOLIItems = new List<Vendor_Order_Line_Item__c>(voLineItems);
            voLineItems.clear();
            for(Vendor_Order_Line_Item__c voli : tempVOLIItems){
                if(voli.Vendor_Receiving_Group__c == null){
                    voLineItems.add(voli);
                }
            }
            
            if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            vrHeaderId = BPUtility.escapeSingleQuotes(vrHeaderId);
            List<Vendor_Receiving_Group__c> vrGroupList = [select Id, Part__c from Vendor_Receiving_Group__c where Vendor_Receiving_Header__c = :vrHeaderId];
            
            //Savepoint sp = Database.setSavepoint();
            
            Map<Id, Id> partIdToVRGroupIdMap = new Map<Id, Id>();
            for(Vendor_Receiving_Group__c vrGroup : vrGroupList) {
                if(vrGroup.Part__c != null) {
                    if(!partIdToVRGroupIdMap.containsKey(vrGroup.Part__c)) {
                        partIdToVRGroupIdMap.put(vrGroup.Part__c, vrGroup.Id);
                    }
                }
            }
            
            List<Vendor_Receiving_Group__c> vrGroupListToInsert = new List<Vendor_Receiving_Group__c>(); 
            List<Id> subletVRGIdList = new List<Id>();
            for(Vendor_Order_Line_Item__c voliRec : voLineItems) {
                Vendor_Receiving_Group__c vrGroupRec;
                if(voliRec.Part__c != null) {
                    if(!partIdToVRGroupIdMap.containsKey(voliRec.Part__c)) {
                        vrGroupRec = new Vendor_Receiving_Group__c();
                        vrGroupRec.Part__c = voliRec.Part__c;
                        vrGroupRec.Cost__c = voliRec.Cost__c;
                        vrGroupRec.Vendor_Receiving_Header__c = vrHeaderId;
                        vrGroupListToInsert.add(vrGroupRec);
                        partIdToVRGroupIdMap.put(voliRec.Part__c, null);
                    }
                } else if(voliRec.Sublet__c != null && voliRec.Vendor_Receiving_Group__c == null) {
                    vrGroupRec = new Vendor_Receiving_Group__c();
                    vrGroupRec.Sublet__c = voliRec.Sublet__c;
                    vrGroupRec.Cost__c = voliRec.Cost__c;
                    vrGroupRec.Vendor_Receiving_Header__c = vrHeaderId;
                    vrGroupRec.Service_Order_Line_Item__c = voliRec.Service_Order_Line_Item__c;
                    vrGroupListToInsert.add(vrGroupRec);
                }
            }
            
            if(vrGroupListToInsert.size() > 0) {
                if(AccessControl.ifObjectIsCreateable('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
                insert vrGroupListToInsert;
            }
            
            for(Vendor_Receiving_Group__c vrGroupRec: vrGroupListToInsert) {
                if(vrGroupRec.Sublet__c != null && vrGroupRec.Part__c == null) {
                    subletVRGIdList.add(vrGroupRec.Id);
                }
            }
            
            for(Vendor_Receiving_Group__c vrgRec : vrGroupListToInsert) {
                if(vrgRec.Part__c != null) {
                    if(partIdToVRGroupIdMap.containsKey(vrgRec.Part__c)) {
                        partIdToVRGroupIdMap.put(vrgRec.Part__c, vrgRec.Id);
                    }
                }
            }
            Integer counter = 0;
            for(Vendor_Order_Line_Item__c voliRec : voLineItems) {
                if(voliRec.Part__c != null) {
                    voliRec.Vendor_Receiving_Group__c = partIdToVRGroupIdMap.get(voliRec.Part__c);
                } else if(voliRec.Sublet__c != null && voliRec.Vendor_Receiving_Group__c == null) {
                    voliRec.Vendor_Receiving_Group__c = subletVRGIdList[counter];
                    voliRec.Received__c = voliRec.Qty_Needed__c;
                    counter++;
                }
            }
            
            if(voLineItems.size() > 0) {
                update voLineItems;
            }
            
            vrGroupList = [select Id, Recieved__c, (select Qty_Needed__c from Vendor_Order_Line_Items__r) from Vendor_Receiving_Group__c where Id IN :partIdToVRGroupIdMap.values() OR Id IN :subletVRGIdList];
            for(Vendor_Receiving_Group__c vrgRec : vrGroupList) {
                Decimal need = 0;
                for(Vendor_Order_Line_Item__c voliRec : vrgRec.Vendor_Order_Line_Items__r) {
                    need += voliRec.Qty_Needed__c;
                }
                vrgRec.Recieved__c = need;
            }
            
            if(vrGroupList.size() > 0) {
                update vrGroupList;
            }
            
            return getVORDetails(BPUtility.getEncodedString(vrHeaderId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), 
                                BPUtility.getEncodedString(vendorOrdersPageSortAttrsJSON), BPUtility.getEncodedString(groupItemsPageSortAttrsJSON), 
                                BPUtility.getEncodedString(outstandingVOGPageSortAttrsJSON));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(null);
    }
    
    /**
     * Name: addToItemSubsection
     * Desc: Method to add/remove selected vendor order items for receiving
     * @param:  (1) vorId - Id - Selected vendor Receiving Id
     *          (2) partId - Id- Part Id
     *          (3) vendorId - String - Vendor Id
     *          (4) isFromSearchToAdd - Boolean - Search from Add
     *          (5) vendorOrdersPageSortAttrsJSON - String - Vendor Order Headers Grid Paging and sorting JSON
     *          (6) groupItemsPageSortAttrsJSON - String - Items Grid Paging and sorting JSON
     *          (7) outstandingVOGPageSortAttrsJSON - String - Outstanding Grid Paging and sorting JSON
     * @return: String - Json String of Vendor Receiving Header Records 
    **/
    @RemoteAction 
    global static String addToItemSubsection(String vorId, 
                                             String partId, 
                                             String vendorId,
                                             boolean isFromSearchToAdd,
                                             String vendorOrdersPageSortAttrsJSON, 
                                             String groupItemsPageSortAttrsJSON, 
                                             String outstandingVOGPageSortAttrsJSON
                                            ){
        try{
            vorId = BPUtility.getDecodedString(vorId);
            partId = BPUtility.getDecodedString(partId);
            vendorId = BPUtility.getDecodedString(vendorId);
            vendorOrdersPageSortAttrsJSON = BPUtility.getDecodedString(vendorOrdersPageSortAttrsJSON);
            groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
            outstandingVOGPageSortAttrsJSON = BPUtility.getDecodedString(outstandingVOGPageSortAttrsJSON);
            vorId = BPUtility.escapeSingleQuotes(vorId);
            partId = BPUtility.escapeSingleQuotes(partId);
            vendorId = BPUtility.escapeSingleQuotes(vendorId);
            List<Vendor_Order_Line_Item__c> voLineItems = SOQLUtil.getVOLineItemsForGivenPartAndVendorReceiving(partId, vorId);
            if(voLineItems.size() == 0 && isFromSearchToAdd) {
                if(AccessControl.ifObjectIsAccessible('Vendor_Order_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
                if(AccessControl.ifObjectIsAccessible('Vendor_Order_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
                voLineItems = [select Id from Vendor_Order_Line_Item__c where Vendor_Order_Header__r.In_Progress_VR__c != :vorId 
                                                                                AND Part__c =: partId 
                                                                                AND Vendor_Order_Header__r.Vendor__c =: vendorId
                                                                                ];
                if(voLineItems.size() > 0) {                                                                
                    PaginationSorting vendorOrdersPageSortAttrs = PaginationSorting.parsePageAttrs(vendorOrdersPageSortAttrsJSON);
                    PaginationSorting groupItemsPageSortAttrs = PaginationSorting.parsePageAttrs(groupItemsPageSortAttrsJSON);
                    PaginationSorting outstandingVOGPageSortAttrs = PaginationSorting.parsePageAttrs(outstandingVOGPageSortAttrsJSON);
                    
                    VendorOrderReceiving voReceiving = new VendorOrderReceiving(vorId, null, null, vendorOrdersPageSortAttrs, groupItemsPageSortAttrs, outstandingVOGPageSortAttrs);
                    voReceiving.isFoundPartInOtherVOHeader = true;
                    return BPUtility.getEncodedString(System.JSON.serialize(voReceiving));
                } else {
                    addToItemSubsectionAfterConfimation(BPUtility.getEncodedString(vorId),BPUtility.getEncodedString(partId), true, BPUtility.getEncodedString(vendorOrdersPageSortAttrsJSON),BPUtility.getEncodedString(groupItemsPageSortAttrsJSON),BPUtility.getEncodedString(outstandingVOGPageSortAttrsJSON));
                } 
            } else {
                return addToItemSubsectionAfterConfimation(BPUtility.getEncodedString(vorId),BPUtility.getEncodedString(partId), false,BPUtility.getEncodedString(vendorOrdersPageSortAttrsJSON),BPUtility.getEncodedString(groupItemsPageSortAttrsJSON),BPUtility.getEncodedString(outstandingVOGPageSortAttrsJSON));
            }
            return getVORDetails(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(partId), 
                                    BPUtility.getEncodedString(vendorOrdersPageSortAttrsJSON), 
                                    BPUtility.getEncodedString(groupItemsPageSortAttrsJSON), BPUtility.getEncodedString(outstandingVOGPageSortAttrsJSON));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(null);
    }
    
    /**
     * Name: addToItemSubsectionAfterConfimation
     * Desc: Method to add/remove slelected vendor order items for receiving
     * @param:  (1) vorId - Selected vendor Receiving Id
                (2) partId - Id- Part Id
     *          (3) isStockExcessGenerated - Boolean - Stock Excess or not 
     *          (4) vendorOrdersPageSortAttrsJSON - String - Vendor Order Headers Grid Paging and sorting JSON
     *          (5) groupItemsPageSortAttrsJSON - String - Items Grid Paging and sorting JSON
     *          (6) outstandingVOGPageSortAttrsJSON - String - Outstanding Grid Paging and sorting JSON
     * @return: String - Json String of Vendor Receiving Header Records
    **/
    @RemoteAction
    global static String addToItemSubsectionAfterConfimation(String vorId, String partId, Boolean isStockExcessGenerated, String vendorOrdersPageSortAttrsJSON, String groupItemsPageSortAttrsJSON, String outstandingVOGPageSortAttrsJSON) {
        try{
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Receiving_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Vendor_Receiving_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            
            vorId = BPUtility.getDecodedString(vorId);
            partId = BPUtility.getDecodedString(partId);
            vendorOrdersPageSortAttrsJSON = BPUtility.getDecodedString(vendorOrdersPageSortAttrsJSON);
            groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
            outstandingVOGPageSortAttrsJSON = BPUtility.getDecodedString(outstandingVOGPageSortAttrsJSON);
            partId = BPUtility.escapeSingleQuotes(partId);
            vorId = BPUtility.escapeSingleQuotes(vorId);
            List<Vendor_Receiving_Group__c> vrGroupList = [select Id,Cost__c,Recieved__c,Part__r.Last_Cost__c ,Part__r.Packaged_Part__c, Part__r.Package_Qty__c from Vendor_Receiving_Group__c where Part__c = :partId AND Vendor_Receiving_Header__c = :vorId];
            List<Part__c> PartList = [select Last_Cost__c ,Packaged_Part__c,Package_Qty__c from Part__c where ID = :partId ];
            Vendor_Receiving_Group__c vrGroupRec = new Vendor_Receiving_Group__c();
            if(vrGroupList.size() > 0) {
                vrGroupRec.Id = vrGroupList[0].Id;
            } else {
                vrGroupRec.Cost__c = (PartList.size() > 0) ? PartList[0].Last_Cost__c : 0;
                vrGroupRec.Part__c = partId;
                vrGroupRec.Vendor_Receiving_Header__c = vorId;
                if(isStockExcessGenerated) {
                    vrGroupRec.Recieved__c = 0;
                    vrGroupRec.Order__c = 0;
                }
            }
            
            if(vrGroupRec.Id == null) {
                if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
                if(AccessControl.ifObjectIsCreateable('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
                insert vrGroupRec;
            }
            if(!isStockExcessGenerated) {
                List<Vendor_Order_Line_Item__c> voLineItems = SOQLUtil.getVOLineItemsForGivenPartAndVendorReceiving(partId, vorId);
                Decimal qty = 0;
                
                for(Vendor_Order_Line_Item__c voliRec : voLineItems) {
                    voliRec.Vendor_Receiving_Group__c = vrGroupRec.Id;
                    qty += voliRec.Qty_Needed__c;
                }
                if(voLineItems.size() == 0) {
                    vrGroupRec.Recieved__c = (vrGroupRec.Recieved__c == null || vrGroupRec.Recieved__c == 0) ?  ( PartList[0].Packaged_Part__c ? PartList[0].Package_Qty__c: 1 ) : 0;
                    //system.assert(false, vrGroupRec);
                    //update vrGroupRec; 
                } else {
                    if(voLineItems.size() > 0) {
                        if(AccessControl.ifObjectIsUpdateable('Vendor_Order_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE);}
                        update voLineItems;
                    }
                    
                    if(vrGroupRec.Recieved__c == null) {
                        vrGroupRec.Recieved__c = 0; 
                    }   
                    
                    vrGroupRec.Recieved__c = vrGroupRec.Recieved__c + qty;
                    vrGroupRec.Cost__c = voLineItems[0].Line_Item_Cost__c;
                }
                if(vrGroupRec.Id != null) {
                    update vrGroupRec;
                }
            } else {
                if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
                vrGroupList = [select Id, Recieved__c, Part__r.Order_Lots__c, Part__r.Last_Cost__c, Part__r.Packaged_Part__c, Part__r.Package_Qty__c from Vendor_Receiving_Group__c where Id =:vrGroupRec.Id];
                if(vrGroupList.size() > 0) {
                    if(vrGroupList[0].Part__r.Packaged_Part__c) {
                        if(vrGroupList[0].Part__r.Order_Lots__c != null && vrGroupList[0].Part__r.Order_Lots__c > 1) {
                            vrGroupList[0].Recieved__c = vrGroupList[0].Recieved__c + (vrGroupList[0].Part__r.Package_Qty__c * vrGroupList[0].Part__r.Order_Lots__c);
                        } else {
                        vrGroupList[0].Recieved__c = vrGroupList[0].Recieved__c + vrGroupList[0].Part__r.Package_Qty__c;
                        }
                    } else {
                        if(vrGroupList[0].Part__r.Order_Lots__c != null && vrGroupList[0].Part__r.Order_Lots__c > 1) {
                            vrGroupList[0].Recieved__c = vrGroupList[0].Recieved__c + vrGroupList[0].Part__r.Order_Lots__c;
                        } else {
                        vrGroupList[0].Recieved__c = vrGroupList[0].Recieved__c + 1;
                    }
                    }
                    
                    vrGroupList[0].Cost__c = vrGroupList[0].Part__r.Last_Cost__c;
                }
                if(vrGroupList.size() > 0) { 
                    if(AccessControl.ifObjectIsCreateable('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
                    update vrGroupList;
                }
                /*Vendor_Receiving_Stock_Excess__c vrseRec = new Vendor_Receiving_Stock_Excess__c();
                vrseRec.Vendor_Receiving_Group__c = vrGroupRec.Id;
                if(partIdList.size() > 0) {
                    if(partIdList[0].Packaged_Part__c) {
                        vrseRec.Received_Qty__c = partIdList[0].Package_Qty__c;
                    } else {
                        vrseRec.Received_Qty__c = 1;
                    }
                }
                if(vrseRec.Id == null) {
                    insert vrseRec;
                }*/
            }
            return getVORDetails(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(partId), 
                                BPUtility.getEncodedString(vendorOrdersPageSortAttrsJSON), BPUtility.getEncodedString(groupItemsPageSortAttrsJSON), 
                                BPUtility.getEncodedString(outstandingVOGPageSortAttrsJSON));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(null);
    }
    
    
    /**
     * Name: updateItemsSection
     * Desc: Method to update VR Group record qty and cost.
     * @param:  (1) vorId - Vendor Receiving Header Id
     *          (2) partId - Part Id
     *          (3) vrGroupId - Vendor Receiving Group Id which is to be updated
     *          (4) qty - Qtantity Receiving
     *          (5) cost - Cost
     *          (6) vendorOrdersPageSortAttrsJSON - Vendor Order Headers Grid Paging and sorting JSON
     *          (7) groupItemsPageSortAttrsJSON - Items Grid Paging and sorting JSON
     *          (8) outstandingVOGPageSortAttrsJSON - Outstanding Grid Paging and sorting JSON
     * @return: String - JSON String
    **/
    @RemoteAction 
    global static String updateItemsSection(String vorId, String partId, String vrGroupId, Decimal qty, Decimal cost, String vendorOrdersPageSortAttrsJSON, String groupItemsPageSortAttrsJSON, String outstandingVOGPageSortAttrsJSON){
        try{
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Receiving_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectIsDeletable('Vendor_Receiving_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            
            vorId = BPUtility.getDecodedString(vorId);
            partId = BPUtility.getDecodedString(partId);
            vrGroupId = BPUtility.getDecodedString(vrGroupId);
            vendorOrdersPageSortAttrsJSON = BPUtility.getDecodedString(vendorOrdersPageSortAttrsJSON);
            groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
            outstandingVOGPageSortAttrsJSON = BPUtility.getDecodedString(outstandingVOGPageSortAttrsJSON);
            
            if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            vrGroupId = BPUtility.escapeSingleQuotes(vrGroupId);
            
            List<Vendor_Receiving_Group__c> vrGroupList = [SELECT Part__c, Part__r.Packaged_Part__c, Part__r.Package_Qty__c, Part__r.Package_Cost__c, Sublet__c,
                                                                 (SELECT Vendor_Order_Line_Item_Group__c from Vendor_Order_Line_Items__r WHERE Sublet__c != null)
                                                                 from Vendor_Receiving_Group__c where Id = :vrGroupId];
            if(vrGroupList.size() > 0) {
                Vendor_Receiving_Group__c vrGroupRec = vrGroupList[0];
                if(qty <= 0) {
                    delete vrGroupRec;
                } else {
                    if(vrGroupRec.Part__c != null && vrGroupRec.Part__r.Packaged_Part__c) {
                        vrGroupRec.Recieved__c = qty * vrGroupRec.Part__r.Package_Qty__c ;
                        vrGroupRec.Cost__c = cost / vrGroupRec.Part__r.Package_Qty__c;
                    } else {
                        vrGroupRec.Recieved__c = qty;
                        vrGroupRec.Cost__c = cost;
                        if(vrGroupRec.Sublet__c != null && vrGroupRec.Vendor_Order_Line_Items__r.size() > 0) {
                            Vendor_Order_Line_Item__c voliToUpdate = vrGroupRec.Vendor_Order_Line_Items__r[0];
                            voliToUpdate.Received__c = qty;
                            voliToUpdate.Qty_Needed__c = qty;
                            voliToUpdate.Line_Item_Cost__c = cost;
                            update voliToUpdate;
                            
                            Vendor_Order_Line_Item_Group__c volig = new Vendor_Order_Line_Item_Group__c(Id = voliToUpdate.Vendor_Order_Line_Item_Group__c);
                            volig.Received_Qty__c = qty;
                            volig.Need__c = qty;
                            volig.Cost__c = cost;
                            volig.VOG_Cost__c = cost;
                            volig.Total__c = qty*cost;
                            update volig;
                        }
                    }
                    update vrGroupRec;
                }
            }
            return getVORDetails(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(partId),
                                    BPUtility.getEncodedString(vendorOrdersPageSortAttrsJSON), 
                                    BPUtility.getEncodedString(groupItemsPageSortAttrsJSON), 
                                    BPUtility.getEncodedString(outstandingVOGPageSortAttrsJSON));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(null);
    }
    
    /**
     * Name: updateLineItemsOfItemsSection
     * Desc: Method to update VR Group line items (VOLIs) qty.
     * @param:  (1) vorId - Vendor Receiving Header Id
     *          (2) partId - Part Id
     *          (3) vrGroupId - Vendor Receiving Group Id which is to be updated
     *          (4) groupJSONString - JSON String of VR Group record.
     *          (5) vendorOrdersPageSortAttrsJSON - Vendor Order Headers Grid Paging and sorting JSON
     *          (6) groupItemsPageSortAttrsJSON - Items Grid Paging and sorting JSON
     *          (7) outstandingVOGPageSortAttrsJSON - Outstanding Grid Paging and sorting JSON
     * @return: String - JSON String
    **/
    @RemoteAction 
    global static String updateLineItemsOfItemsSection(String vorId, String partId, String vrGroupId, String groupJSONString, String vendorOrdersPageSortAttrsJSON, String groupItemsPageSortAttrsJSON, String outstandingVOGPageSortAttrsJSON){
        try{
            vorId = BPUtility.getDecodedString(vorId);
            partId = BPUtility.getDecodedString(partId);
            vrGroupId = BPUtility.getDecodedString(vrGroupId);
            groupJSONString = BPUtility.getDecodedString(groupJSONString);
            vendorOrdersPageSortAttrsJSON = BPUtility.getDecodedString(vendorOrdersPageSortAttrsJSON);
            groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
            outstandingVOGPageSortAttrsJSON = BPUtility.getDecodedString(outstandingVOGPageSortAttrsJSON);
            
            List<VORGroup> vorGrpList = (List<VORGroup>) System.JSON.deserialize(groupJSONString, List<VORGroup>.class);
            Map<Id, Decimal> voliIdToReceivingQtyMap = new Map<Id, Decimal>();
            for(VORGroup vrgObj : vorGrpList) {
                for(VendorOrderLineItem voliRec : vrgObj.VendorOrderLineItemList) {
                    if(!voliIdToReceivingQtyMap.containsKey(voliRec.Id)) {
                        voliIdToReceivingQtyMap.put(voliRec.Id, voliRec.ReceivedQty);
                    } 
                }
            }
            
            if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            if(AccessControl.ifObjectIsAccessible('Vendor_Order_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            vrGroupId = BPUtility.escapeSingleQuotes(vrGroupId);
            List<Vendor_Receiving_Group__c> vrGroupList = [select Id, (select Id, Received__c from Vendor_Order_Line_Items__r) from Vendor_Receiving_Group__c where Id = :vrGroupId];
            
            List<Vendor_Order_Line_Item__c> voliListToUpdate = new List<Vendor_Order_Line_Item__c>();
            for(Vendor_Receiving_Group__c vrgRec : vrGroupList) {
                for(Vendor_Order_Line_Item__c voliRec : vrgRec.Vendor_Order_Line_Items__r) {
                    if(voliIdToReceivingQtyMap.containsKey(voliRec.Id)) {
                        voliRec.Received__c = voliIdToReceivingQtyMap.get(voliRec.Id);
                        voliListToUpdate.add(voliRec);
                    }
                }
            }
            
            if(voliListToUpdate.size() > 0) {
                if(AccessControl.ifObjectIsUpdateable('Vendor_Order_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE);}
                update voliListToUpdate;
            }
            
            return getVORDetails(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(partId), 
                                    BPUtility.getEncodedString(vendorOrdersPageSortAttrsJSON), BPUtility.getEncodedString(groupItemsPageSortAttrsJSON), 
                                    BPUtility.getEncodedString(outstandingVOGPageSortAttrsJSON));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(null);
    }
    
    
    /**
     * Name: addAllLineItemsToItemSubsection
     * Desc: Method to add all vendor order items form outstanding Grid to Items Section
     * @param:  (1) vorId - Vendor Receiving Header Id
     *          (2) voHeaderId -  Vendor Order Header Record Id
     *          (3) voGroupId -  Vendor Order Group Record Id
     *          (4) vendorOrdersPageSortAttrsJSON - Vendor Order Headers Grid Paging and sorting JSON
     *          (5) groupItemsPageSortAttrsJSON - Items Grid Paging and sorting JSON
     *          (6) outstandingVOGPageSortAttrsJSON - Outstanding Grid Paging and sorting JSON
     * @return: String - Json String
    **/
    @RemoteAction 
    global static String addAllLineItemsToItemSubsection(String vorId, String voHeaderId, String voGroupId, String vendorOrdersPageSortAttrsJSON, String groupItemsPageSortAttrsJSON, String outstandingVOGPageSortAttrsJSON){
        try{
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Receiving_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            
            vorId = BPUtility.getDecodedString(vorId);
            voHeaderId = BPUtility.getDecodedString(voHeaderId);
            voGroupId = BPUtility.getDecodedString(voGroupId);
            vendorOrdersPageSortAttrsJSON = BPUtility.getDecodedString(vendorOrdersPageSortAttrsJSON);
            groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
            outstandingVOGPageSortAttrsJSON = BPUtility.getDecodedString(outstandingVOGPageSortAttrsJSON);
            
            List<Vendor_Order_Line_Item__c> voLineItems = new List<Vendor_Order_Line_Item__c>();
            if(vorId != null) {
                if(AccessControl.ifObjectIsAccessible('In_Progress_VR__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
                if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
                vorId = BPUtility.escapeSingleQuotes(vorId);
                List<In_Progress_VR__c> inProgressVRList = [select Vendor_Order_Header__c from In_Progress_VR__c Where Vendor_Receiving_Header__c =: vorId AND Vendor_Receiving_Header__r.Status__c = 'In Progress'];
                
                List<String> voHeaderIdList = new List<String>();
                for(In_Progress_VR__c inProgreeVIRec : inProgressVRList) {

                    voHeaderIdList.add(inProgreeVIRec.Vendor_Order_Header__c);
                }
                voLineItems = SOQLUtil.getVOLineItemByFieldValue(new Map<String, List<String>> {'Vendor_Order_Header__c' => voHeaderIdList});
                
                List<Vendor_Order_Line_Item__c> tempVOLIItems = new List<Vendor_Order_Line_Item__c>(voLineItems);
                voLineItems.clear();
                for(Vendor_Order_Line_Item__c voli : tempVOLIItems){
                    if(voli.Vendor_Receiving_Group__c == null){
                        voLineItems.add(voli);
                    }
                }
            } else if(voHeaderId != null) {
                voLineItems = SOQLUtil.getVOLineItemByFieldValue(new Map<String, String> {'Vendor_Order_Header__c' => voHeaderId});
            } else if(voGroupId != null) {
                voLineItems = SOQLUtil.getVOLineItemByFieldValue(new Map<String, String> {'Vendor_Order_Line_Item_Group__c' => voGroupId, 'Vendor_Order_Header__c' => null});
            }
            
            if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            vorId = BPUtility.escapeSingleQuotes(vorId);
            List<Vendor_Receiving_Group__c> vrGroupList = [select Id, Part__c from Vendor_Receiving_Group__c where Vendor_Receiving_Header__c = :vorId];
            
            //Savepoint sp = Database.setSavepoint();
            
            Map<Id, Id> partIdToVRGroupIdMap = new Map<Id, Id>();
            for(Vendor_Receiving_Group__c vrGroup : vrGroupList) {
                if(!partIdToVRGroupIdMap.containsKey(vrGroup.Part__c)) {
                    partIdToVRGroupIdMap.put(vrGroup.Part__c, vrGroup.Id);
                }
            }
            
            List<Vendor_Receiving_Group__c> vrGroupListToInsert = new List<Vendor_Receiving_Group__c>(); 
            Vendor_Receiving_Group__c vrGroupRec;
            for(Vendor_Order_Line_Item__c voliRec : voLineItems) {
                if(!partIdToVRGroupIdMap.containsKey(voliRec.Part__c)) {
                    vrGroupRec = new Vendor_Receiving_Group__c();
                    vrGroupRec.Part__c = voliRec.Part__c;
                    vrGroupRec.Cost__c = voliRec.Cost__c;
                    vrGroupRec.Vendor_Receiving_Header__c = vorId;
                    vrGroupListToInsert.add(vrGroupRec);
                    partIdToVRGroupIdMap.put(voliRec.Part__c, null);
                }
            }
            
            if(vrGroupListToInsert.size() > 0) {
                if(AccessControl.ifObjectIsCreateable('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
                insert vrGroupListToInsert;
            }
            
            for(Vendor_Receiving_Group__c vrgRec : vrGroupListToInsert) {
                if(partIdToVRGroupIdMap.containsKey(vrgRec.Part__c)) {
                    partIdToVRGroupIdMap.put(vrgRec.Part__c, vrgRec.Id);
                }
            }
            
            for(Vendor_Order_Line_Item__c voliRec : voLineItems) {
                voliRec.Vendor_Receiving_Group__c = partIdToVRGroupIdMap.get(voliRec.Part__c);
            }
            
            if(voLineItems.size() > 0) {
                update voLineItems;
            }
            
            vrGroupList = [select Id, Recieved__c, (select Qty_Needed__c from Vendor_Order_Line_Items__r) from Vendor_Receiving_Group__c where Id IN :vrGroupListToInsert];
            for(Vendor_Receiving_Group__c vrgRec : vrGroupList) {
                Decimal need = 0;
                for(Vendor_Order_Line_Item__c voliRec : vrgRec.Vendor_Order_Line_Items__r) {
                    need += voliRec.Qty_Needed__c;
                }
                vrgRec.Recieved__c = need;
            }
            
            if(vrGroupList.size() > 0) {
                if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Receiving_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update vrGroupList;
            }
            
            return getVORDetails(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), 
                                BPUtility.getEncodedString(vendorOrdersPageSortAttrsJSON), BPUtility.getEncodedString(groupItemsPageSortAttrsJSON), 
                                BPUtility.getEncodedString(outstandingVOGPageSortAttrsJSON));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(null);
    }
    
    
    /**
     * Name: removeItem
     * Desc: Method to remove VR Group Record
     * @param:  (1) vorId - Selected vendor Receiving Id
     *          (2) vrGroupId - VR Group Id which is to be removed
     *          (3) vendorOrdersPageSortAttrsJSON - Vendor Order Headers Grid Paging and sorting JSON
     *          (4) groupItemsPageSortAttrsJSON - Items Grid Paging and sorting JSON
     *          (5) outstandingVOGPageSortAttrsJSON - Outstanding Grid Paging and sorting JSON
     * @return: String - JSON String
    **/
    @RemoteAction 
    global static String removeItem(String vorId, String vrGroupId, String vendorOrdersPageSortAttrsJSON, String groupItemsPageSortAttrsJSON, String outstandingVOGPageSortAttrsJSON){
        try{
            vorId = BPUtility.getDecodedString(vorId);
            vrGroupId = BPUtility.getDecodedString(vrGroupId);
            vendorOrdersPageSortAttrsJSON = BPUtility.getDecodedString(vendorOrdersPageSortAttrsJSON);
            groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
            outstandingVOGPageSortAttrsJSON = BPUtility.getDecodedString(outstandingVOGPageSortAttrsJSON);
            
            if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            vrGroupId = BPUtility.escapeSingleQuotes(vrGroupId);
            List<Vendor_Receiving_Group__c> vrGroupList = [select Id from Vendor_Receiving_Group__c where Id = :vrGroupId];
            if(vrGroupList.size() > 0) {
                if(AccessControl.ifObjectIsDeletable('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                delete vrGroupList[0];
            }
            
            return getVORDetails(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), 
                                BPUtility.getEncodedString(vendorOrdersPageSortAttrsJSON), BPUtility.getEncodedString(groupItemsPageSortAttrsJSON), 
                                BPUtility.getEncodedString(outstandingVOGPageSortAttrsJSON));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(null);
    }
    
    /**
     * Name: removeAllItemsFromItemSubSection
     * Desc: Method to remove all VR Group
     * @param:  (1) vorId - Selected vendor Receiving Id
     *          (2) vendorOrdersPageSortAttrsJSON - Vendor Order Headers Grid Paging and sorting JSON
     *          (3) groupItemsPageSortAttrsJSON - Items Grid Paging and sorting JSON
     *          (4) outstandingVOGPageSortAttrsJSON - Outstanding Grid Paging and sorting JSON
     * @return: String - JSON String
    **/
    @RemoteAction 
    global static String removeAllItemsFromItemSubSection(String vorId, String vendorOrdersPageSortAttrsJSON, String groupItemsPageSortAttrsJSON, String outstandingVOGPageSortAttrsJSON){
        try{
            vorId = BPUtility.getDecodedString(vorId);
            vendorOrdersPageSortAttrsJSON = BPUtility.getDecodedString(vendorOrdersPageSortAttrsJSON);
            groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
            outstandingVOGPageSortAttrsJSON = BPUtility.getDecodedString(outstandingVOGPageSortAttrsJSON);
            
            if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            vorId = BPUtility.escapeSingleQuotes(vorId);
            List<Vendor_Receiving_Group__c> vrGroupList = [select Id from Vendor_Receiving_Group__c where Vendor_Receiving_Header__c = :vorId];
            if(vrGroupList.size() > 0) {
                if(AccessControl.ifObjectIsDeletable('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                delete vrGroupList;
            }
            return getVORDetails(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(null), BPUtility.getEncodedString(null), 
                                BPUtility.getEncodedString(vendorOrdersPageSortAttrsJSON), BPUtility.getEncodedString(groupItemsPageSortAttrsJSON), 
                                BPUtility.getEncodedString(outstandingVOGPageSortAttrsJSON));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return null;
    }
    
    
    /**
     * Name: getPartByPartId
     * Desc: Method which give JSON string of part Record related to given part Id.
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
        return null;
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
        return BPUtility.getEncodedString(null);
    }
    
    /**
     * Name: getGroupRecDetail
     * Desc: Method which give JSOn string of CO Header Rec Related to Given CO Header Id
     * @param:  (1) coHeaderId - String - CO Header record Id
     * @return: String - JSON String of CO Header Record
    **/
    @RemoteAction
    global static String getGroupRecDetail(String vrGroupId){
        try{
            vrGroupId = BPUtility.getDecodedString(vrGroupId);
            List<Vendor_Receiving_Group__c> vrGroupList = SOQLUtil.getVORGroupsWithItems('Id', vrGroupId);
            List<VRGroupDetail> vrGroupDetailList = new List<VRGroupDetail>();
            for(Vendor_Receiving_Group__c vrGroupRec : vrGroupList) {
                vrGroupDetailList.add(new VRGroupDetail(vrGroupRec));
            } 
            return BPUtility.getEncodedString(System.JSON.serialize(vrGroupDetailList));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(null);
    }
    
    @RemoteAction
    global static String commitRecevingAction(String vrHeaderId){
        vrHeaderId = BPUtility.escapeSingleQuotes(BPUtility.getDecodedString(vrHeaderId));
        Savepoint sp = Database.setSavepoint();
        
        List<Vendor_Receiving_Group__c> existingVRGroupList = 
                [select Recieved__c, Cost__c, Part__c, Part__r.Qty_On_Order__c, Part__r.Last_Cost__c, Part__r.Qty_In_Stock__c,
                            Part__r.Packaged_Part__c, Part__r.Package_Qty__c, Vendor_Receiving_Header__r.Vendor__c, Sublet__c,
                        Vendor_Receiving_Header__r.Packing_Slip_Number__c,
	        			(select Received__c, Is_required_For_Customer__c, CO_Line_Item__c, Is_Service__c, Part__c, Sublet__c, Service_Order_Line_Item__c from Vendor_Order_Line_Items__r)
                    FROM Vendor_Receiving_Group__c WHERE Vendor_Receiving_Header__c =: vrHeaderId];
        
        Vendor_Receiving_Header__c vrHeaderRec = updateVRHeader(vrHeaderId);
        
        updatePart(existingVRGroupList, vrHeaderId);
        
        String vendorId;
        Map<Id, Vendor_Order_Line_Item__c> existingVOLineItemMap = new Map<Id, Vendor_Order_Line_Item__c>();
        for(Vendor_Receiving_Group__c vrGroupRec : existingVRGroupList) {
            for(Vendor_Order_Line_Item__c voliRec : vrGroupRec.Vendor_Order_Line_Items__r) {
                voliRec.Line_Item_Cost__c = (vrGroupRec.Cost__c != null) ? vrGroupRec.Cost__c : 0;
                existingVOLineItemMap.put(voliRec.Id, voliRec);
            }
            if(String.isBlank(vendorId)) {
                vendorId = vrGroupRec.Vendor_Receiving_Header__r.Vendor__c;
            }
        }
        
        existingVOLineItemMap = updateRelatedCOLineItem(existingVOLineItemMap, vrHeaderId);
        if(existingVOLineItemMap.size() > 0) {
            update existingVOLineItemMap.values();
        }
        
        
        // Receiving in case of Stock 
        stockVOLIsReceiving(vrHeaderId);
        
        // Changes in VO Header -   1. Remove Extra In Progress VR List
        //                          2. Update VOLI Group Cost and Received Qty.
        //                          3. Set VO Status.
        changesRelatedToVOHeader(vrHeaderId, existingVRGroupList);
        
        // Update other VOLIG Cost with Status = "Open/Locked".
        updateOtherVOLIGCost(existingVRGroupList);
        
        // Create Activity History.
        if(!Test.isRunningTest()) {
            ActivityHistory.createActivityHistory('Commit Vendor Receiving', 'Vendor Receiving', vrHeaderId, 'Vendor', vendorId, null);
        }
        
        // Return JSON Status of VR Header
        return BPUtility.getEncodedString(createVRHeaderJSON(vrHeaderRec.Status__c));
    }
    
    
    private static Vendor_Receiving_Header__c updateVRHeader(String vrHeaderId) {
        Vendor_Receiving_Header__c vrHeaderRec = new Vendor_Receiving_Header__c(Id = vrHeaderId);
        vrHeaderRec.Status__c = 'Stocked';
        vrHeaderRec.Finalized_Date__c = Date.today();
        if(vrHeaderId != null) {
            if(AccessControl.ifObjectIsUpdateable('Vendor_Receiving_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE);}
            update vrHeaderRec;
        }
        return vrHeaderRec;
    }
    
    private static void updatePart(List<Vendor_Receiving_Group__c> existingVRGroupList, String vrHeaderId) {
        Map<Id, Part__c> partIdToPartMap = new Map<Id, Part__c>();
        Part__c partRec;
        for(Vendor_Receiving_Group__c vrGroupRec : existingVRGroupList) {
            if(vrGroupRec.Part__c != null && vrGroupRec.Sublet__c == null) {
                partRec = new Part__c(Id = vrGroupRec.Part__c);
                partRec.Last_Cost__c = (vrGroupRec.Cost__c != null) ? vrGroupRec.Cost__c : 0;
                
                //Added by Nidhi- To update Package cost when changing cost on VendorReceiving
                if(vrGroupRec.Part__r.Packaged_Part__c != null && vrGroupRec.Part__r.Packaged_Part__c) {
                    Decimal packageQty = (vrGroupRec.Part__r.Package_Qty__c != null) ? vrGroupRec.Part__r.Package_Qty__c : 1;
                    partRec.Package_Cost__c = (partRec.Last_Cost__c * packageQty);
                }
                
                Decimal receiviedStockQty = 0;
                for(Vendor_Order_Line_Item__c voliRecord : vrGroupRec.Vendor_Order_Line_Items__r) {
                    if(!voliRecord.Is_required_For_Customer__c && !voliRecord.Is_Service__c) {
                        receiviedStockQty += ((voliRecord.Received__c != null) ? voliRecord.Received__c : 0);
                    }
                }
                partRec.Qty_On_Order__c = vrGroupRec.Part__r.Qty_On_Order__c - receiviedStockQty;
                if(partRec.Qty_On_Order__c < 0) {
                    partRec.Qty_On_Order__c = 0;
                }
                partRec.Qty_In_Stock__c = vrGroupRec.Recieved__c; // This is Used for Creating In stock Qty of FIFO bucket.
                partIdToPartMap.put(partRec.Id, partRec);
            }
        }
        
        // Create FIFO Bucket AND Udpate Part Record
        if(partIdToPartMap.size() > 0) {
            FIFOTransaction.createFIFOBucketForVendorReceiving(partIdToPartMap, vrHeaderId);
        }
    }
    
    // This method is for Only merch section.
    private static Map<Id, Vendor_Order_Line_Item__c> updateRelatedCOLineItem(Map<Id, Vendor_Order_Line_Item__c> existingVOLineItemMap, String vrHeaderId) {
        Set<Id> coliIdSet = new Set<Id>();
        Set<Id> subletSOLISet = new Set<Id>();
        Savepoint sp = Database.setSavepoint();
        for(Vendor_Order_Line_Item__c voliRec : existingVOLineItemMap.values()) {
            if(voliRec.Part__c != null) {
                coliIdSet.add(voliRec.CO_Line_Item__c);
            } else if(voliRec.Sublet__c != null) {
                subletSOLISet.add(voliRec.Service_Order_Line_Item__c);
            }
        }
        if(coliIdSet.size() == 0 && subletSOLISet.size() == 0) {
            return new Map<Id, Vendor_Order_Line_Item__c>();
        }
        List<Service_Order_Line_Item__c> soliListToUpdate = new List<Service_Order_Line_Item__c>();
        List<CO_Line_Item__c> coliListToUpdate = new List<CO_Line_Item__c>();
        List<Vendor_Order_Line_Item__c> voliListToInsert = new List<Vendor_Order_Line_Item__c>();
        if(subletSOLISet.size() > 0) {
            List<Service_Order_Line_Item__c> solineItemList = 
                    [SELECT Qty_Committed__c, Qty_Needed__c, Status__c, 
                            (select Vendor_Order_Line_Item_Group__c, Qty_Needed__c, Received__c, Is_Received__c, Vendor_Receiving_Group__r.Cost__c, 
                                Vendor_Receiving_Group__r.Vendor_Receiving_Header__c, Status__c, Vendor_Receiving_Group__r.Recieved__c from Vendor_Order_Line_Items__r 
                                where Is_Received__c = false)
                        FROM Service_Order_Line_Item__c WHERE Id IN: subletSOLISet];
            for(Service_Order_Line_Item__c soliRec : solineItemList) {
                Decimal receivedQty = 0;
                Decimal cost = 0;
                for(Vendor_Order_Line_Item__c voliRec : soliRec.Vendor_Order_Line_Items__r) {
                    if(voliRec.Vendor_Order_Line_Item_Group__c != null && voliRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c == vrHeaderId) {
                        receivedQty = (voliRec.Vendor_Receiving_Group__r.Recieved__c != null) ? voliRec.Vendor_Receiving_Group__r.Recieved__c : 0;
                        cost = voliRec.Vendor_Receiving_Group__r.Cost__c != null ? voliRec.Vendor_Receiving_Group__r.Cost__c : 0;
                        if(existingVOLineItemMap.containsKey(voliRec.Id)) {
                            existingVOLineItemMap.get(voliRec.Id).Status__c = 'Received';
                            existingVOLineItemMap.get(voliRec.Id).Is_Received__c = true;
                        }
                    }
                }
                if(receivedQty > 0) {
                    soliRec.Qty_Committed__c = ((soliRec.Qty_Committed__c != null) ? (soliRec.Qty_Committed__c + receivedQty) : receivedQty);
                    soliRec.Qty_Needed__c = soliRec.Qty_Committed__c;
                    soliRec.Status__c = 'Ready';
                    soliRec.Cost__c = cost;
                    soliListToUpdate.add(soliRec);
                }
            }
        }
        
        if(coliIdSet.size() > 0) {
            List<CO_Line_Item__c> colineItemList = 
                    [SELECT Qty__c, Qty_Committed__c, Special_Order__c, CO_Kit_Header__c, CO_Header__c, Part__c, Price__c, Tax__c, 
                            Service_Order_Line_Item__c, Vendor_Order_Header__c,
                            (select Vendor_Order_Line_Item_Group__c, CO_Header__c, Vendor_Receiving_Group__c, Vendor_Order_Header__c, CO_Line_Item__c, 
                                    Part__c, Qty_Needed__c, Received__c, Qty_Ordered__c, Is_Received__c, Is_Excess__c, Is_From_Search__c, 
                                    Is_required_For_Customer__c, Is_Service__c, Vendor_Receiving_Group__r.Vendor_Receiving_Header__c, 
                                    Vendor_Order_Line_Item_Group__r.VOG_Cost__c, Status__c, Line_Item_Cost__c from Vendor_Order_Line_Items__r 
                                where Is_Received__c = false)
                        FROM CO_Line_Item__c WHERE Id IN: coliIdSet];
        
            Decimal receivedQty;
            for(CO_Line_Item__c coliRec : colineItemList) {
                receivedQty = 0;
                for(Vendor_Order_Line_Item__c voliRec : coliRec.Vendor_Order_Line_Items__r) {
                    if(voliRec.Vendor_Order_Line_Item_Group__c != null && voliRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c == vrHeaderId){
                        receivedQty += ((voliRec.Received__c != null) ? voliRec.Received__c : 0);
                    }
                }
                
                if(receivedQty > 0) {
                    coliRec.Qty_Committed__c = ((coliRec.Qty_Committed__c != null) ? (coliRec.Qty_Committed__c + receivedQty) : receivedQty);
                    if(coliRec.Qty__c == coliRec.Qty_Committed__c) {
                        coliRec.Status__c = 'In Stock';
                        coliRec.VO_Status__c = 'Received';
                    }
                    if(coliRec.Service_Order_Line_Item__c != null) {
                        Service_Order_Line_Item__c soliRec = new Service_Order_Line_Item__c(Id = coliRec.Service_Order_Line_Item__c);
                        soliRec.Qty_Committed__c = coliRec.Qty_Committed__c;
                        soliListToUpdate.add(soliRec);
                    }
                }
                
                // Breaking of VO Line Items in both case - In COLI, SOLI, CO Kit Header. Because now only VOLI is breaking, not COLI.
                List<Vendor_Order_Line_Item__c> relatedVOLineItemList = new List<Vendor_Order_Line_Item__c>();
                for(Vendor_Order_Line_Item__c voliRec : coliRec.Vendor_Order_Line_Items__r) {
                    if(voliRec.Vendor_Order_Line_Item_Group__c != null && voliRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c == vrHeaderId) {
                        voliRec.Received__c = (voliRec.Received__c != null) ? voliRec.Received__c : 0;
                        
                        if(voliRec.Qty_Needed__c > voliRec.Received__c && voliRec.Received__c > 0) {
                            Vendor_Order_Line_Item__c voliCloneRec = voliRec.clone(false, false, false, false);
                            voliCloneRec.Received__c = 0;
                            voliCloneRec.Qty_Needed__c = (voliRec.Qty_Needed__c - voliRec.Received__c);
                            voliCloneRec.Status__c = 'Ordered';
                            voliListToInsert.add(voliCloneRec);
                            
                            // Reduce Qty Needed Same as Received Qty
                            voliRec.Qty_Needed__c = voliRec.Received__c;
                            voliRec.Status__c = 'Received';
                            voliRec.Is_Received__c = true;
                        
                            // Set Status of COLIs in case of Partial Receiving
                            coliRec.Status__c = 'Ordered';
                            coliRec.VO_Status__c = 'On Order';
                        }
                        relatedVOLineItemList.add(voliRec);
                    }
                }
                
                
                // Set VOLI status and Line Item Cost
                for(Vendor_Order_Line_Item__c voliRec : relatedVOLineItemList) {
                    if(voliRec.Qty_Needed__c == voliRec.Received__c) {
                        if(existingVOLineItemMap.containsKey(voliRec.Id)) {
                            existingVOLineItemMap.get(voliRec.Id).Status__c = 'Received';
                            existingVOLineItemMap.get(voliRec.Id).Is_Received__c = true;
                            existingVOLineItemMap.get(voliRec.Id).Qty_Needed__c = existingVOLineItemMap.get(voliRec.Id).Received__c;
                        }
                    }
                }
                
                // Set Status of COLI if there is already a required Line item present
                for(Vendor_Order_Line_Item__c voliRec : coliRec.Vendor_Order_Line_Items__r) {
                    if(voliRec.Vendor_Order_Line_Item_Group__c == null) {
                        coliRec.Status__c = 'Required';
                        coliRec.VO_Status__c = null;
                    }
                } 
                coliRec.Special_Order__c = false;
                coliListToUpdate.add(coliRec);
            }
        }
        
        if(soliListToUpdate.size() > 0) {
            ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
            COLineItemTriggerHelper.isVOLIInsertFromVRPage = false;
            if(AccessControl.ifObjectIsUpdateable('Service_Order_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE);}
            update soliListToUpdate;

            // To update Is Invoicable check box.
            update soliListToUpdate;
        }
        
        if(coliListToUpdate.size() > 0) {
            COLineItemTriggerHelper.isTriggerExecute = false;
            COLineItemTriggerHelper.isVOLIInsertFromVRPage = false;
            
            if(AccessControl.ifObjectIsUpdateable('CO_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE);}
            update coliListToUpdate;
        }
        
        if(voliListToInsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert voliListToInsert;
        }
        
        return existingVOLineItemMap;
    }
    
    private static void stockVOLIsReceiving(String vrHeaderId) {
        if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        List<Vendor_Order_Line_Item__c> volis = 
                [SELECT Part__c, Sublet__c, CO_Header__c, Vendor_Order_Line_Item_Group__c, Line_Item_Cost__c, Vendor_Order_Header__c, Is_Service__c, Is_Excess__c, 
                        CO_Line_Item__c, CO_Line_Item__r.Qty_Committed__c, Is_required_For_Customer__c, Qty_Needed__c, Received__c, 
                        Vendor_Receiving_Group__c, Vendor_Order_Line_Item_Group__r.VOG_Cost__c
                    FROM Vendor_Order_Line_Item__c Where Vendor_Receiving_Group__r.Vendor_Receiving_Header__c =: vrHeaderId];
        
        // Stocking Partial Receiving
        List<Vendor_Order_Line_Item__c> stockVOLIListToInsert = new List<Vendor_Order_Line_Item__c>();
        List<Vendor_Order_Line_Item__c> stockVOLIListToUpdate = new List<Vendor_Order_Line_Item__c>();
        for(Vendor_Order_Line_Item__c voliRec : volis) {
            if(voliRec.Part__c != null && voliRec.Sublet__c == null && !voliRec.Is_required_For_Customer__c && !voliRec.Is_Service__c && 
                    voliRec.Qty_Needed__c > voliRec.Received__c && voliRec.Received__c > 0) {
                        
                Vendor_Order_Line_Item__c newVoliRec = new Vendor_Order_Line_Item__c();
                newVoliRec = voliRec.clone(false, true, false, false);
                newVoliRec.Received__c = 0;
                newVoliRec.Line_Item_Cost__c = (voliRec.Vendor_Order_Line_Item_Group__r.VOG_Cost__c != null) ? 
                                                    voliRec.Vendor_Order_Line_Item_Group__r.VOG_Cost__c : voliRec.Cost__c;
                newVoliRec.Qty_Needed__c = voliRec.Qty_Needed__c - voliRec.Received__c;
                newVoliRec.Vendor_Receiving_Group__c = null;
                newVoliRec.Status__c = 'Ordered';
                stockVOLIListToInsert.add(newVoliRec);
                
                voliRec.Qty_Needed__c = voliRec.Received__c;
            }
            if(voliRec.Received__c == 0) {
                voliRec.Vendor_Receiving_Group__c = null;
                voliRec.Line_Item_Cost__c = (voliRec.Vendor_Order_Line_Item_Group__r.VOG_Cost__c != null) ? 
                                                voliRec.Vendor_Order_Line_Item_Group__r.VOG_Cost__c : voliRec.Cost__c;
            }
            stockVOLIListToUpdate.add(voliRec); 
        }
        
        for(Vendor_Order_Line_Item__c voliRec : stockVOLIListToUpdate) {
            if(voliRec.Received__c > 0 && voliRec.Qty_Needed__c == voliRec.Received__c) {
                voliRec.Status__c = 'Received';
                voliRec.Is_Received__c = true;
            }
        }
        
        if(stockVOLIListToInsert.size() > 0) {
            insert stockVOLIListToInsert;
        } 
        
        if(stockVOLIListToUpdate.size() > 0) {
            update stockVOLIListToUpdate;
        }
    }
    
    private static void changesRelatedToVOHeader(String vrHeaderId, List<Vendor_Receiving_Group__c> existingVRGroupList) {
        List<In_Progress_VR__c> ipvrList = [SELECT Vendor_Order_Header__c from In_Progress_VR__c WHERE Vendor_Receiving_Header__c =: vrHeaderId];
        Set<Id> voHeaderIdSet = new Set<Id>();
        for(In_Progress_VR__c ipvrRec : ipvrList) {
            voHeaderIdSet.add(ipvrRec.Vendor_Order_Header__c);
        }
        voHeaderIdSet.remove(null);
        
        // 1. Delete Extra generated In Progress VR records - Hips Issues - 05/21/2017
        Set<Id> extraVOHeaderIdSet = removeExtraInProgressVR(ipvrList, voHeaderIdSet, existingVRGroupList);
        
        // 2. Update VOLI Group Cost and Received Qty.
        if(AccessControl.ifObjectIsAccessible('Vendor_Order_Line_Item_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        List<Vendor_Order_Line_Item_Group__c> voliGroupList = 
                [SELECT Vendor_Order_Header__c, Need__c, Received_Qty__c, Status__c, Cost__c, 
                            (Select Line_Item_Cost__c, Cost__c, Received__c, Qty_Needed__c from Vendor_Order_Line_Items__r) 
                        FROM Vendor_Order_Line_Item_Group__c 
                        WHERE Vendor_Order_Header__c IN :voHeaderIdSet AND Vendor_Order_Header__c NOT IN: extraVOHeaderIdSet];
                        
        Map<Id, Vendor_Order_Header__c> voHeaderMapToUpdate = new Map<Id, Vendor_Order_Header__c>();
        for(Vendor_Order_Line_Item_Group__c volig : voliGroupList) {
            Decimal voligTotalCost = 0;
            Decimal receivedQty = 0;
            Decimal neededQty = 0;
            String voStatus;
            for(Vendor_Order_Line_Item__c voliRec : volig.Vendor_Order_Line_Items__r) {
                
                //Added by Nidhi - To update Cost on VOLIG when updating cost on VR page, 
                // On voli cost is formula field so it gets automatically update, but volig should be updated to update total on home search
                receivedQty += ((voliRec.Received__c != null) ? voliRec.Received__c : 0);
                voliRec.Line_Item_Cost__c = (voliRec.Line_Item_Cost__c == null) ? 0 : voliRec.Line_Item_Cost__c;
                voliRec.Received__c = (voliRec.Received__c == null) ? 0 : voliRec.Received__c;
                voliRec.Qty_Needed__c = (voliRec.Qty_Needed__c == null) ? 0 : voliRec.Qty_Needed__c;
                
                if(voliRec.Qty_Needed__c == voliRec.Received__c) {
                    voligTotalCost += (voliRec.Line_Item_Cost__c * voliRec.Received__c);
                } else if((voliRec.Qty_Needed__c > voliRec.Received__c) && (voliRec.Received__c != 0)) {
                    voligTotalCost += (((voliRec.Qty_Needed__c - voliRec.Received__c) * voliRec.Line_Item_Cost__c) + (voliRec.Cost__c * voliRec.Received__c));
                } else if(voliRec.Received__c == 0) {
                    voligTotalCost += (voliRec.Line_Item_Cost__c * voliRec.Qty_Needed__c);
                }
                neededQty += (voliRec.Qty_Needed__c);
            }
            if(volig.Vendor_Order_Line_Items__r.size() > 0) {
                volig.Cost__c = (voligTotalCost / neededQty).setScale(3);
            }
            volig.Received_Qty__c = receivedQty;
            
            // Setting VO Status per VOLI Group. Since There may be multiple VO Header, So this should be in for Loop.
            if(volig.Received_Qty__c == volig.Need__c) {
                voStatus = 'Received';
            } else if(volig.Status__c != 'Cancelled'){  // Added By Hitesh If condition if(volig.Status__c != 'Cancelled')
                voStatus = 'Partially Received';
            }
            Vendor_Order_Header__c voHeaderRec = new Vendor_Order_Header__c(Id = volig.Vendor_Order_Header__c);
            voHeaderRec.Status__c = voStatus;
            if(!voHeaderMapToUpdate.containsKey(voHeaderRec.Id)) {
                voHeaderMapToUpdate.put(voHeaderRec.Id, voHeaderRec);
            } else if(voStatus == 'Partially Received'){
                voHeaderMapToUpdate.put(voHeaderRec.Id, voHeaderRec);
            } 
        }
        
        if(voliGroupList.size() > 0) {
            if(AccessControl.ifObjectIsUpdateable('Vendor_Order_Line_Item_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE);}
            update voliGroupList;
        }
        
        if(voHeaderMapToUpdate.size() > 0) {
            if(AccessControl.ifObjectIsUpdateable('Vendor_Order_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE);}
            update voHeaderMapToUpdate.values();
        }
    }
    
    private static String createVRHeaderJSON(String vrHeaderStatus) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('Status', vrHeaderStatus); 
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        return jsonString;
    }
    
    private static Set<Id> removeExtraInProgressVR(List<In_Progress_VR__c> ipvrList, Set<Id> voHeaderIdSet, List<Vendor_Receiving_Group__c> vrGroupList) {
        List<In_Progress_VR__c> inProgressListToDelete = new List<In_Progress_VR__c>();
        Map<Id, Vendor_Order_Header__c> relatedVOHeaderMap = 
                    new Map<Id, Vendor_Order_Header__c>([select Id, (select Vendor_Receiving_Group__c from Vendor_Order_Line_Items__r 
                                                                    where Vendor_Receiving_Group__c IN: vrGroupList)
                                                            from Vendor_Order_Header__c where Id IN: voHeaderIdSet]);
                                                                
        Set<Id> vrgIdSet = new Set<Id>();
        for(Vendor_Receiving_Group__c vrgRec : vrGroupList) {
            vrgIdSet.add(vrgRec.Id);
        }
        
        Set<Id> extraVOHeaderIdSet = new Set<Id>();
        for(In_Progress_VR__c inProgressRec : ipvrList) {
            if(relatedVOHeaderMap.containsKey(inProgressRec.Vendor_Order_Header__c)) {
                Boolean isIvprDelete = true;
                for(Vendor_Order_Line_Item__c voliRec : relatedVOHeaderMap.get(inProgressRec.Vendor_Order_Header__c).Vendor_Order_Line_Items__r) {
                    if(vrgIdSet.contains(voliRec.Vendor_Receiving_Group__c)) {
                        isIvprDelete = false;
                        break;
                    }
                }
                if(isIvprDelete) {
                    extraVOHeaderIdSet.add(inProgressRec.Vendor_Order_Header__c);
                    inProgressListToDelete.add(inProgressRec);
                }
            }
        }
        
        if(inProgressListToDelete.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('In_Progress_VR__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete inProgressListToDelete;
        }
        extraVOHeaderIdSet.remove(null);
        return extraVOHeaderIdSet;
    }
    
    
    // Update other VOLIG Cost with Status = "Open/Locked".
    private static void updateOtherVOLIGCost(List<Vendor_Receiving_Group__c> vrGroupList) {
        // Create part Id Set
        Set<Id> partIdSet = new Set<Id>();
        for(Vendor_Receiving_Group__c vrGroupRec : vrGroupList) {
            partIdSet.add(vrGroupRec.Part__c);
        } 
        partIdSet.remove(null);
        if(partIdSet.size() == 0) {
            return;
        }
        List<Vendor_Order_Line_Item_Group__c> voliGroupList = [select Vendor_Order_Header__c, Status__c, Cost__c, 
                                    (Select Line_Item_Cost__c, Part__r.Last_Cost__c, Qty_Needed__c from Vendor_Order_Line_Items__r) 
                                from Vendor_Order_Line_Item_Group__c 
                                where Part__c IN: partIdSet AND 
                                    (Vendor_Order_Header__r.Status__c = 'Open' OR Vendor_Order_Header__r.Status__c = 'Locked')];
                                 
        for(Vendor_Order_Line_Item_Group__c voligRec : voliGroupList) {
            Decimal voligCost = 0;
            Decimal totalQty = 0;
            for(Vendor_Order_Line_Item__c voliRec : voligRec.Vendor_Order_Line_Items__r) {
                voliRec.Part__r.Last_Cost__c = (voliRec.Part__r.Last_Cost__c != null) ? voliRec.Part__r.Last_Cost__c : 0;
                voliRec.Qty_Needed__c = (voliRec.Qty_Needed__c != null) ? voliRec.Qty_Needed__c : 0;
                voligCost += (voliRec.Part__r.Last_Cost__c * voliRec.Qty_Needed__c);
                totalQty += voliRec.Qty_Needed__c;
            }
            voligRec.Cost__c = voligCost / ((totalQty < 1) ? 1 : totalQty);
        }
        if(voliGroupList.size() > 0) {
            update voliGroupList;
        }
    }
    
    @RemoteAction
    global static String deleteVendorOrderRecieving(String vorId){
        try{ 
            vorId = BPUtility.getDecodedString(vorId);
            vorId = BPUtility.escapeSingleQuotes(vorId);
            if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            List<Vendor_Receiving_Header__c> vorHeaderRecList = [Select Status__c, In_Progress_VI__c, (Select Id From Vendor_Receiving_Groups__r) From Vendor_Receiving_Header__c  where ID =: vorId];
            
            String response = 'Error';
            if(vorHeaderRecList.size() > 0){
                if(vorHeaderRecList[0].Status__c == 'In Progress' && vorHeaderRecList[0].Vendor_Receiving_Groups__r.size() == 0){
                    Vendor_Receiving_Header__c viReceivingHeader = new Vendor_Receiving_Header__c(Id = vorHeaderRecList[0].Id);
                    
                    List<In_Progress_VR__c> IPVRList = [select Id from In_Progress_VR__c
                                                        Where Vendor_Receiving_Header__c = :vorId];
                    
                    if(AccessControl.ifObjectIsDeletable('Vendor_Receiving_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                    delete viReceivingHeader;
                    
                    if(AccessControl.ifObjectIsDeletable('In_Progress_VR__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                    if(IPVRList.size() > 0){
                        delete IPVRList;
                    }
                    response = 'Success';
                }
            }
            return BPUtility.getEncodedString(response);
            
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String getLabelPrintingData(String vrHeaderId){
        vrHeaderId = BPUtility.getDecodedString(vrHeaderId);
        List<Vendor_Receiving_Group__c> vrGroupList = SOQLUtil.getVORGroupsWithItems('Vendor_Receiving_Header__c', vrHeaderId);
        List<Business_Profile__c> businessProfileList = SOQLUtil.getBusinessProfileData(new List<Id>());
        Business_Profile__c businessProfileRec = new Business_Profile__c();
        if(businessProfileList.size() > 0) {
            businessProfileRec = businessProfileList[0];
        }
        List<LabelPrinting> labelPrintingList = new List<LabelPrinting>();
        for(Vendor_Receiving_Group__c vrGroupRec : vrGroupList) {
            if(vrGroupRec.Part__c != null) {
                labelPrintingList.add(new LabelPrinting(vrGroupRec, businessProfileRec));
            }
        }
        return BPUtility.getEncodedString(System.JSON.serialize(labelPrintingList));
    }
    
    public class LabelPrinting {
        
        public String ProductDesc;
        public String Id;
        public Boolean IsSelected;
        public Decimal NoOfStockLabels;
        public Decimal NoOfCustomerLabels;
        public String BusinessName;
        public String PartId;
        public String PartDesc;
        public Decimal RetailPrice;
        public String PartLocation;
        public List<CustomerInfo> CustomerDetailList;
        
        public LabelPrinting(Vendor_Receiving_Group__c vrGroupRec, Business_Profile__c businessProfileRec) {
            this.Id = vrGroupRec.Part__c;
            this.ProductDesc = vrGroupRec.Part__r.Part_Number__c + ' - ' + vrGroupRec.Part__r.Description__c;
            this.IsSelected = true;
            this.NoOfStockLabels = 0;
            this.NoOfCustomerLabels = 0;
            this.CustomerDetailList = new List<CustomerInfo>();
            for(Vendor_Order_Line_Item__c voliRec : vrGroupRec.Vendor_Order_Line_Items__r) {
                if(voliRec.Is_required_For_Customer__c || voliRec.Is_Service__c) {
                    this.NoOfCustomerLabels += ((voliRec.Received__c != null) ? voliRec.Received__c : 0);
                    CustomerDetailList.add(new CustomerInfo(voliRec));
                } else {
                    this.NoOfStockLabels += ((voliRec.Received__c != null) ? voliRec.Received__c : 0);
                }
            }
            for(Vendor_Receiving_Stock_Excess__c stockVOLIRec : vrGroupRec.Vendor_Receiving_Stock_Excesses__r) {
                this.NoOfStockLabels += ((stockVOLIRec.Received_Qty__c != null) ? stockVOLIRec.Received_Qty__c : 0);
            }
            
            if(vrGroupRec.Part__r.Packaged_Part__c) {
                if(vrGroupRec.Part__r.Package_Qty__c == 0 || vrGroupRec.Part__r.Package_Qty__c == null) {
                    vrGroupRec.Part__r.Package_Qty__c = 1;
                }
                this.NoOfStockLabels = (this.NoOfStockLabels / vrGroupRec.Part__r.Package_Qty__c).round(system.RoundingMode.CEILING);
            }
            this.BusinessName = (businessProfileRec.Business_Name__c != null) ? businessProfileRec.Business_Name__c : '';
            this.PartId = vrGroupRec.Part__r.Part_ID__c;
            this.PartDesc = vrGroupRec.Part__r.Description__c;
            this.PartLocation = (vrGroupRec.Part__r.Location__c != null) ? vrGroupRec.Part__r.Location__c : '';
            this.RetailPrice = vrGroupRec.Part__r.Retail_Price__c;
        }
    }
    
    public class CustomerInfo {
        
        public String CONumber;
        public String CustomerName;
        public String PhoneNumber;
        public Decimal NoOfLabels;
        
        public CustomerInfo(Vendor_Order_Line_Item__c voliRec) {
            this.CONumber = voliRec.CO_Header__r.Name;
            this.CustomerName = voliRec.CO_Header__r.Customer_Name__c;
            if(voliRec.CO_Header__r.Customer__r.Home_Number__c != null) {
                this.PhoneNumber = voliRec.CO_Header__r.Customer__r.Formatted_Home_number__c;
                //this.PhoneNumber = voliRec.CO_Header__r.Customer__r.Home_Number__c;
            } else if(voliRec.CO_Header__r.Customer__r.Mobile__c != null) {
                this.PhoneNumber = voliRec.CO_Header__r.Customer__r.Formatted_Mobile_Number__c;
                //this.PhoneNumber = voliRec.CO_Header__r.Customer__r.Mobile__c;
            } else if(voliRec.CO_Header__r.Customer__r.Work_Number__c != null) {
                this.PhoneNumber = voliRec.CO_Header__r.Customer__r.Formatted_Work_Number__c;
                //this.PhoneNumber = voliRec.CO_Header__r.Customer__r.Work_Number__c;
            } 
            
            this.NoOfLabels = voliRec.Qty_Needed__c;
        }
    }
    
     /**
     * Name: VendorOrderReceiving
     * Description: Vendor Order Receiving Wrapper Class
     **/
    // Wrapper class for Vendor Order Receiving attributes
    public class VendorOrderReceiving {
        // Vendor Order Receiving Header details
        public VORHeader VOR_Header;
        
        // Checkbox value if all vendor orders are selected
        public boolean isAllVOSelected;
        
        // Total number of vendor Orders found for selected vendor
        public Integer totalVendorOrders;
        
        // vendor orders list for selected vendor
        public List<VendorOrderHeader> vendorOrdersList;
        
        // List of selected Vendor Order Names list for current receiving record
        public Set<String> SelectedVendorOrdersList;
        
        // Total number of outstanding Items found for selected vendor
        public Integer totalOutstandingItems;
        
        // List of Outstanding Vendor Order Groups with respective Line Items list
        public List<VendorOrderLineItemGroup> outstandingVOGList;
        
        // Total number of group Items found for selected vendor
        public Integer totalGroupItems;
        
        // List of Vendor Receiving group
        public List<VORGroup> VORGroupList;
        
        // Total cost of Receiving items and groups
        public Decimal GroupTotalCost;
        
        // Invoicing History List
        public List<VIHistory> VIHistoryList;
        
        // Set to hold part ids
        private transient Set<Id> vendorAllPartIdsSet;
        
        // Is Found Record 
        public Boolean isFoundPartInOtherVOHeader = false;
        
        // List of Last Edited Vendor Receiving group
        public List<VORGroup> RecentlyEditedVORGroupList;
        
        /**
         * Name: VendorOrderReceiving
         * Desc: Constructor
         * @param:  (1) vorId - String - Vendor Order Receiving Id
         *          (2) gridName - String - Grid Name
         *          (3) lastEditedPartId - Id - Edited Part Id Recently
         *          (4) vendorOrdersPageSortAttrsJSON - PaginationSorting -Vendor Order Headers Grid Paging and sorting JSON
         *          (5) groupItemsPageSortAttrsJSON - PaginationSorting - Items Grid Paging and sorting JSON
         *          (6) outstandingVOGPageSortAttrsJSON - PaginationSorting - Outstanding Grid Paging and sorting JSON
         * @return: 
         **/
        public VendorOrderReceiving(Id vorId, String gridName, Id lastEditedPartId,
                                    PaginationSorting vendorOrdersPageSortAttrs, 
                                    PaginationSorting groupItemsPageSortAttrs,
                                    PaginationSorting outstandingVOGPageSortAttrs
                                ){
            VOR_Header = VORHeader.getVORDetails(vorId);
            GroupTotalCost = 0;
            totalVendorOrders = 0;
            isAllVOSelected = true;
            vendorOrdersList = new List<VendorOrderHeader>();
            SelectedVendorOrdersList = new Set<String>();
            outstandingVOGList = new List<VendorOrderLineItemGroup>();
            VORGroupList = new List<VORGroup>();
            vendorAllPartIdsSet = new Set<Id>();
            RecentlyEditedVORGroupList = new List<VORGroup>();
            VIHistoryList = new List<VIHistory>();
            
            // populate vendor orders
            if(VOR_Header != null && (gridName == null || gridName.toLowerCase() == 'vendororder')){
                populateVendorOrderDetails(vorId, vendorOrdersPageSortAttrs);
            }
            
            // populate outstanding vendor order groups list
            if(VOR_Header != null && (gridName == null || gridName.toLowerCase() == 'outstanding')){
                populateOutstandingItems(vorId, outstandingVOGPageSortAttrs);
            }
            
            // populate outstanding vendor order groups list
            if(VOR_Header != null && (gridName == null || gridName.toLowerCase() == 'groupitems')){
                populateItemsSubsection(vorId, VOR_Header.VendorId, groupItemsPageSortAttrs);
            }
            
            if(lastEditedPartId != null) {
                for(VORGroup vorGroupObj : VORGroupList) {
                    if(vorGroupObj.PartId == lastEditedPartId) {
                        RecentlyEditedVORGroupList.add(vorGroupObj);
                    }
                }
            }
            
            for(VORGroup vrGroupObj : VORGroupList) {
                this.GroupTotalCost += vrGroupObj.Total;
            }
            
            // Sort and paginate list
            VORGroupList.sort();
            VORGroupList = VORGroup.getPaginatedRecords(VORGroupList, groupItemsPageSortAttrs.CurrentPage, groupItemsPageSortAttrs.PageSize);
            
            populateVIHistoryList(vorId);
        }
        
        /**
         * Name: populateVendorOrderDetails
         * Desc: Method to populate only vendor Orders for vendor receiving
         * @param:  (1) vorId - String - Vendor Order Receiving Id
         *          (2) vendorOrdersPageSortAttrsJSON - PaginationSorting -Vendor Order Headers Grid Paging and sorting JSON
         * @return: 
        **/
        private void populateVendorOrderDetails(Id vorId, PaginationSorting vendorOrdersPageSortAttrs){
            // If there is a vendor assigned to VRO record, then populate the lists
            if(VOR_Header.VendorId != null){
                Map<String, String> sortFieldMap = new Map<String, String>();
                if(vendorOrdersPageSortAttrs.sorting != null && vendorOrdersPageSortAttrs.sorting[0].sortDirection.length() != 0){
                    sortFieldMap.put('Name', vendorOrdersPageSortAttrs.sorting[0].sortDirection);
                    VO_Sort_Order = vendorOrdersPageSortAttrs.sorting[0].sortDirection;
                }
                
                List<Vendor_Order_Header__c> voList = SOQLUtil.getVendorOrderHeaderRecords('Vendor__c', VOR_Header.VendorId, sortFieldMap, true);
                totalVendorOrders = voList.size();
                
                Integer rowCount = 0;
                
                for(Vendor_Order_Header__c vo : voList){
                    VendorOrderHeader voh = new VendorOrderHeader(vo);
                    voh.populateVendorOrderGroups(vo);
                    vendorOrdersList.add(voh);
                    voh.ExpectedDate = BPUtility.getFormatedDateTime(datetime.newInstance(Date.Today().year(), Date.Today().month(), Date.Today().day()));
                    
                    // Set isAllVOSelected flag
                    //if(vo.In_Progress_VR__c == null || (vo.In_Progress_VR__c != null && vo.In_Progress_VR__c != vorId))
                    for(In_Progress_VR__c inProgressVRRec : vo.In_Progress_VRs__r) {
                        if(inProgressVRRec.Vendor_Receiving_Header__c != vorId) {
                            isAllVOSelected = false;
                            rowCount++;
                            break;
                        }
                    }
                    
                    if(vo.In_Progress_VRs__r == null || vo.In_Progress_VRs__r.size() == 0){
                        isAllVOSelected = false;
                    }
                    
                    // Populate partIdToVOHNameMap
                    for( VendorOrderLineItemGroup vog : voh.VOLIGroups){
                        vendorAllPartIdsSet.add(vog.PartId);
                    }
                }
                if(isAllVOSelected == false && rowCount == voList.size()){
                    isAllVOSelected = null;
                }

                // get paginated records
                vendorOrdersList.sort();    // Sorting implication to move all those vendor orders in last which are already part of any other vendor receiving records
                vendorOrdersList = VendorOrderHeader.getPaginatedRecords(vendorOrdersList, vendorOrdersPageSortAttrs.CurrentPage, vendorOrdersPageSortAttrs.PageSize);
            }
            //system.assert(false, vendorOrdersList);
            for(VendorOrderHeader voh : vendorOrdersList){
                if(voh.InProgressVR != null && voh.InProgressVRId == vorId){
                    SelectedVendorOrdersList.add(voh.VOName);
                }
            }
        }
        
        /**
         * Name: populateOutstandingItems
         * Desc: Method to add/remove slelected vendor order items for receiving
         * @param:  (1) vorId - Selected vendor Receiving Id
         *          (2) outstandingVOGPageSortAttrsJSON - PaginationSorting - Outstanding Grid Paging and sorting JSON
         * @return: void
        **/
        private void populateOutstandingItems(String vorId, PaginationSorting outstandingVOGPageSortAttrs){
            if(VOR_Header.VendorId != null){
                if(AccessControl.ifObjectIsAccessible('In_Progress_VR__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
                if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
                List<In_Progress_VR__c> inProgressVRList = [select Vendor_Order_Header__c, Vendor_Receiving_Header__c 
                                                                from In_Progress_VR__c where Vendor_Receiving_Header__r.Status__c = 'In Progress'];
                
                List<Id> selectedVOHeaderIdList = new List<Id>();
                
                Map<String, String> sortFieldMap = new Map<String, String>{'Items' => ''};
                if(outstandingVOGPageSortAttrs.Sorting != null && outstandingVOGPageSortAttrs.Sorting[0].SortDirection.length() != 0){
                    sortFieldMap.put('Items', outstandingVOGPageSortAttrs.Sorting[0].SortDirection.toUpperCase());
                }
                VendorOrderLineItemWrapper.sortFieldMap = sortFieldMap;
                
                for(In_Progress_VR__c inProgressVrRec : inProgressVRList){
                    if(inProgressVrRec.Vendor_Receiving_Header__c ==  vorId ){
                        selectedVOHeaderIdList.add(inProgressVrRec.Vendor_Order_Header__c); 
                    }
                    
                }
                List<Vendor_Order_Line_Item_Group__c> voLineItemGroupList = SOQLUtil.getVOLIGroupsWithItems('Vendor_Order_Header__r.Vendor__c', VOR_Header.VendorId, selectedVOHeaderIdList);
                Map<Id, List<Vendor_Order_Line_Item__c>> partIdToListOfVOLIRecMap = new Map<Id, List<Vendor_Order_Line_Item__c>>();
                Map<Id, Vendor_Order_Line_Item_Group__c> partIdToVOLIGroupRecMap = new Map<Id, Vendor_Order_Line_Item_Group__c>();
                
                Map<Id, List<Vendor_Order_Line_Item__c>> subetVOLIGroupIdToListOfVOLIRecMap = new Map<Id, List<Vendor_Order_Line_Item__c>>();
                Map<Id, Vendor_Order_Line_Item_Group__c> subetVOLIGroupIdToVOLIGroupRecMap = new Map<Id, Vendor_Order_Line_Item_Group__c>();
                
                for(Vendor_Order_Line_Item_Group__c voliGroup : voLineItemGroupList) {
                    if(voliGroup.Part__c != null) {
                        List<Vendor_Order_Line_Item__c> voliList = (partIdToListOfVOLIRecMap.containsKey(voliGroup.Part__c)) ? partIdToListOfVOLIRecMap.get(voliGroup.Part__c) : new List<Vendor_Order_Line_Item__c>();
                        voliList.addAll(voliGroup.Vendor_Order_Line_Items__r);
                        
                        partIdToListOfVOLIRecMap.put(voliGroup.Part__c, voliList);
                        partIdToVOLIGroupRecMap.put(voliGroup.Part__c, voliGroup);
                    } else if(voliGroup.Sublet__c != null) {
                        List<Vendor_Order_Line_Item__c> voliList = (subetVOLIGroupIdToListOfVOLIRecMap.containsKey(voliGroup.Id)) ? subetVOLIGroupIdToListOfVOLIRecMap.get(voliGroup.Id) : new List<Vendor_Order_Line_Item__c>();
                        voliList.addAll(voliGroup.Vendor_Order_Line_Items__r);
                        
                        subetVOLIGroupIdToListOfVOLIRecMap.put(voliGroup.Id, voliList);
                        subetVOLIGroupIdToVOLIGroupRecMap.put(voliGroup.Id, voliGroup);
                    }
                }
                
                Set<Id> VOHeaderIdSet = new Set<Id>();
                for(Id partId : partIdToListOfVOLIRecMap.keyset()) {
                    VOHeaderIdSet.add(partIdToVOLIGroupRecMap.get(partId).Vendor_Order_Header__c);
                }
                for(Id voligId : subetVOLIGroupIdToVOLIGroupRecMap.keyset()) {
                    VOHeaderIdSet.add(subetVOLIGroupIdToVOLIGroupRecMap.get(voligId).Vendor_Order_Header__c);
                }
                
                List<Vendor_Order_Header__c> voHeaderList = SOQLUtil.getVendorOrderHeaderRecords('Id', VOHeaderIdSet, null, false);
                Map<Id, Vendor_Order_Header__c> voHeaderIdToRecordMap = new Map<Id, Vendor_Order_Header__c>();
                for(Vendor_Order_Header__c voHeaderRec : voHeaderList){
                    voHeaderIdToRecordMap.put(voHeaderRec.Id, voHeaderRec);
                }
                
                for(Id partId : partIdToListOfVOLIRecMap.keyset()) {
                    if(voHeaderIdToRecordMap.containsKey(partIdToVOLIGroupRecMap.get(partId).Vendor_Order_Header__c)){
                        VendorOrderHeader vendorOrderHeader = new VendorOrderHeader(voHeaderIdToRecordMap.get(partIdToVOLIGroupRecMap.get(partId).Vendor_Order_Header__c));
                    
                        if(partIdToListOfVOLIRecMap.get(partId).size() > 0){
                            outstandingVOGList.add(new VendorOrderLineItemGroup(partIdToListOfVOLIRecMap.get(partId), partIdToVOLIGroupRecMap.get(partId), vendorOrderHeader));
                        }
                    }
                    
                }
                
                for(Id voligId : subetVOLIGroupIdToVOLIGroupRecMap.keyset()) {
                    if(voHeaderIdToRecordMap.containsKey(subetVOLIGroupIdToVOLIGroupRecMap.get(voligId).Vendor_Order_Header__c)){
                        VendorOrderHeader vendorOrderHeader = new VendorOrderHeader(voHeaderIdToRecordMap.get(subetVOLIGroupIdToVOLIGroupRecMap.get(voligId).Vendor_Order_Header__c));
                    
                        if(subetVOLIGroupIdToListOfVOLIRecMap.get(voligId).size() > 0) {
                            outstandingVOGList.add(new VendorOrderLineItemGroup(subetVOLIGroupIdToListOfVOLIRecMap.get(voligId), subetVOLIGroupIdToVOLIGroupRecMap.get(voligId), vendorOrderHeader));
                        }
                    }
                }
                
                totalOutstandingItems = outstandingVOGList.size();
                
                // Sort and paginate list
                outstandingVOGList.sort();
                outstandingVOGList = VendorOrderLineItemGroup.getPaginatedRecords(outstandingVOGList, outstandingVOGPageSortAttrs.CurrentPage, outstandingVOGPageSortAttrs.PageSize);
            }
        }
        
        
        /**
         * Name: populateItemsSubsection
         * Desc: populate items Sub Section
         * @param:  (1) vorId - Selected vendor Receiving Id
         *          (2)vendorId - Vendor Record Id
         *          (3) groupItemsPageSortAttrsJSON - PaginationSorting - Items Grid Paging and sorting JSON
         * @return: void 
        **/
        private void populateItemsSubsection(Id vorId, String vendorId, PaginationSorting groupItemsPageSortAttrs){
            Map<Id, List<String>> partIdToOtherVOHeaderNameListMap = getPartIdToUnreceivedVOHNamesMap(vorId, vendorAllPartIdsSet, vendorId);
            List<Vendor_Receiving_Group__c> vrGroupList = SOQLUtil.getVORGroupsWithItems('Vendor_Receiving_Header__c', vorId);
            for(Vendor_Receiving_Group__c vrgRec : vrGroupList) {
                VORGroupList.add(new VORGroup(vrgRec, partIdToOtherVOHeaderNameListMap));
            } 
            
            VendorOrderReceivingCtrl.sortingMap = new Map<String, String>();
            if(groupItemsPageSortAttrs.sorting != null && groupItemsPageSortAttrs.sorting[0].sortDirection.length() != 0){
                VendorOrderReceivingCtrl.sortingMap.put('CreatedDate', groupItemsPageSortAttrs.sorting[0].sortDirection);
                VO_Sort_Order = groupItemsPageSortAttrs.sorting[0].sortDirection;
            }
            
            totalGroupItems = VORGroupList.size();
        }
        
        
        /**
         * Name: getPartIdToUnreceivedVOHNamesMap
         * Desc: Method used to populate a map of vendor related parts Ids used in all Vendor Orders to all unreceived VO names
         * @param:  (1) vorId - Selected vendor Receiving Id
         *          (2) partIdSet - Set Of Part Id
         *          (3) vendorId - String - Vendor Id
         * @return: Map<Id, List<String>>
        **/
        private Map<Id, List<String>> getPartIdToUnreceivedVOHNamesMap(String vorId, Set<Id> partIdSet, Id vendorId){
            List<Id> vohIdsToExclude = new List<Id>();
            vendorId = BPUtility.escapeSingleQuotes(vendorId);
            if(AccessControl.ifObjectIsAccessible('In_Progress_VR__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            if(AccessControl.ifObjectIsAccessible('Vendor_Order_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            for(In_Progress_VR__c ivr : [SELECT Vendor_Order_Header__c 
                                                FROM In_Progress_VR__c 
                                                WHERE Vendor_Order_Header__r.Vendor__c =: vendorId]){
                vohIdsToExclude.add(ivr.Vendor_Order_Header__c);
            }

            Map<Id, List<String>> partIdToVOHeaderNameListMap = new Map<Id, List<String>>();
            if(AccessControl.ifObjectIsAccessible('Vendor_Order_Line_Item_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            List<Vendor_Order_Line_Item_Group__c> voLineItemGroupList = [select Part__c, Vendor_Order_Header__r.Name from Vendor_Order_Line_Item_Group__c Where Part__c IN: partIdSet 
                                                                                                    AND Vendor_Order_Header__c NOT IN: vohIdsToExclude 
                                                                                                    AND Vendor_Order_Header__r.Vendor__c =: vendorId];
            List<String> voHeaderNameList;
            for(Vendor_Order_Line_Item_Group__c voliGroupRec : voLineItemGroupList) {
                if(partIdToVOHeaderNameListMap.containsKey(voliGroupRec.Part__c)) {
                    voHeaderNameList = partIdToVOHeaderNameListMap.get(voliGroupRec.Part__c);
                    voHeaderNameList.add(voliGroupRec.Vendor_Order_Header__r.Name);
                } else {
                    voHeaderNameList = new List<String>();
                    voHeaderNameList.add(voliGroupRec.Vendor_Order_Header__r.Name);
                }
                partIdToVOHeaderNameListMap.put(voliGroupRec.Part__c, voHeaderNameList);
            }
            return partIdToVOHeaderNameListMap;
        }
        
        /**
         * Name: populateVIHistoryList
         * Desc: Method used to populate a map of vendor related parts Ids used in all Vendor Orders to all unreceived VO names
         * @param:  (1) vorId - Selected vendor Receiving Id
         * @return: Map<Id, List<String>>
        **/
        private void populateVIHistoryList(String vorId){
            vorId = BPUtility.escapeSingleQuotes(vorId);
            if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
            List<Vendor_Receiving_Header__c> vrHeaderList = [select In_Progress_VI__c from Vendor_Receiving_Header__c where Id =: vorId];
            if(vrHeaderList.size() > 0 && vrHeaderList[0].In_Progress_VI__c != null) {
                List<Vendor_Invoicing_Header__c> viHeaderList = SOQLUtil.getVIHeaderDetailsByFieldName(new Map<String, String>{'Id' => vrHeaderList[0].In_Progress_VI__c});
                for(Vendor_Invoicing_Header__c viHeaderRec : viHeaderList) {
                    this.VIHistoryList.add(new VIHistory(viHeaderRec));
                }
            }
        }
    }
    
     /**
     * Name: VRGroupDetail
     * Description: Wrapper class for Needed For Pop Up
     **/
    public class VRGroupDetail {
        
        public Decimal RequriedForCustomer;
        public Decimal RequriedForStock;
        public Decimal TotalRequried;
        public Decimal OrderQty;
        public Decimal PackageQty;
        public String PackageUnit;
        public Decimal TotalExcess;
        
         /**
         * Name: VRGroupDetail
         * Desc: Constructor
         * @param:  (1) vrgRec - Vendor Receiving Group Record
         * @return:
         **/
        public VRGroupDetail(Vendor_Receiving_Group__c vrgRec) {
            this.RequriedForCustomer = 0;
            this.RequriedForStock = 0;
            this.PackageQty = 0;
            this.TotalExcess = 0;
            
            for(Vendor_Order_Line_Item__c voliRec : vrgRec.Vendor_Order_Line_Items__r) {
                if(voliRec.Is_required_For_Customer__c) {
                    this.RequriedForCustomer += voliRec.Qty_Needed__c;
                } else if(!voliRec.Is_required_For_Customer__c && !voliRec.Is_Excess__c && !voliRec.Is_From_Search__c) {
                    this.RequriedForStock += voliRec.Qty_Needed__c;
                } else if(voliRec.Is_Excess__c) {
                    this.TotalExcess += voliRec.Qty_Needed__c;
                }
            }
            this.TotalRequried = this.RequriedForCustomer + this.RequriedForStock;
            if(vrgRec.Part__r.Packaged_Part__c) {
                this.PackageQty = (this.TotalRequried + this.TotalExcess) / vrgRec.Part__r.Package_Qty__c;
                this.PackageUnit = vrgRec.Part__r.Package_Unit__c;
            }
            this.OrderQty = vrgRec.Part__r.Order_Lots__c;
        }
    }
    
     /**
     * Name: VIHistory
     * Description: Wrapper class for Vendor Invoice History Section
     **/
    public class VIHistory {
        
        public String InvoiceNumber;
        public String InvoiceDate;
        public String InvoicedByName;
        public String InvoicedById;
        public String VIHeaderId;
        public Decimal TotalLineItems;
        public Decimal TotalCost;
        public String Status;
        
         /**
         * Name: VIHistory
         * Desc: Constructor
         * @param:  (1) viHeaderRec -Vendor Invoice Header Record 
         * @return:
         **/
        public VIHistory(Vendor_Invoicing_Header__c viHeaderRec) {
            
            this.InvoiceNumber = ((viHeaderRec.Invoice_Number__c != null) && (viHeaderRec.Invoice_Number__c != '')) ? viHeaderRec.Invoice_Number__c : viHeaderRec.Name;
            if(viHeaderRec.Invoice_Date__c != null) {
                this.InvoiceDate = BPUtility.getFormatedDateTime(datetime.newInstance(viHeaderRec.Invoice_Date__c.year(), viHeaderRec.Invoice_Date__c.month(), viHeaderRec.Invoice_Date__c.day()));
            }
            this.InvoicedByName = viHeaderRec.Owner__r.Name;
            this.InvoicedById = viHeaderRec.Owner__c;
            this.VIHeaderId = viHeaderRec.Id;
            
            this.TotalLineItems = 0;
            this.TotalCost = 0;
            for(Vendor_Invoicing_Group__c viGroupRec : viHeaderRec.Vendor_Invoicing_Groups__r ) {
                this.TotalLineItems += 1;
                this.TotalCost += viGroupRec.VI_SubTotal__c;
            }
            this.TotalCost = this.TotalCost.setScale(2, RoundingMode.HALF_UP);
            this.Status = viHeaderRec.Status__c;
        }
    }
}