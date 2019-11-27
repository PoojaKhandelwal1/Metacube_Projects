/**
 * Author: Tarun Khandelwal
 * Since: July 22, 2015
 * Name: VendorOrderLineItemGroup
 * Description: Apex class to handle JSON related oprations of VO Line Item group object.
**/
public with sharing class VendorOrderLineItemGroup implements Comparable{
    // Id
    public String Id;
    
    // Part Number + Part desc
    public String ItemDesc;
    
    public String PartNumber;
    
    // Need - Qty Required 
    public Decimal Need;
    
    // Qty required by customer
    public String NeededFor;
    
    // Needed By - Date
    public String NeededBy;
    
    // Order 
    public String OrderType;
    
    // Qty Unit Type
    public String UnitType;
    
    // Order Value
    public Decimal OrderValue;
    
    // CO Line Item price per Qty
    public Decimal Cost;
    
    // Need * Cost
    public Decimal Total;
    
    // Part Id
    public String PartId;
    public String SubletId;
    
    // Available Part
    public Decimal AvailablePart;
    
    // Related VOLI
    public List<VendorOrderLineItem> VendorOrderLineItemList;
    
    // Is Excess
    public Boolean IsExcess;
    
    // % Received 
    public Decimal PercentRecieved;
    
    // ReceivedQty
    public Decimal ReceivedQty;
    
    // VO Header Name
    public String VOHeaderName;
    
    // UnReceived Qty
    public Decimal UnreceivedQty;
    
    //Expected Date
    public String ExpectedDate;
    
    // Richa
    //Status
    public String Status;
    
    public Boolean IsBRPPart;
    
    // Constructor
    public VendorOrderLineItemGroup(Vendor_Order_Line_Item_Group__c voliGroupRec, VendorOrderHeader vendorOrderHeader) {
        this.Id = voliGroupRec.Id;
        this.VendorOrderLineItemList = new List<VendorOrderLineItem>();
        this.Cost = 0;
        this.IsExcess = false;
        this.Cost = (voliGroupRec.Cost__c != null) ? voliGroupRec.Cost__c : 0;
        
        Map<Id, VendorOrderLineItem> voliIdToVOLIRecMap = new Map<Id, VendorOrderLineItem>();
        List<VendorReceivingLineItem> vrlis = new List<VendorReceivingLineItem>();
            
        for(Vendor_Order_Line_Item__c voliRec : voliGroupRec.Vendor_Order_Line_Items__r) {
            VendorOrderLineItem voliObj = new VendorOrderLineItem(voliRec);
            this.VendorOrderLineItemList.add(voliObj);
            vrlis.add( new VendorReceivingLineItem(voliRec) );
            voliIdToVOLIRecMap.put(voliRec.Id, voliObj);
        }
        
        for(Cancelled_VOLI__c cancelvoliRec : voliGroupRec.Cancelled_VOLIs__r) {
            VendorOrderLineItem cancelvoliObj = new VendorOrderLineItem(cancelvoliRec);
            this.VendorOrderLineItemList.add(cancelvoliObj);
            vrlis.add( new VendorReceivingLineItem(cancelvoliRec) );
            voliIdToVOLIRecMap.put(cancelvoliRec.Id, cancelvoliObj);
        }
        
        this.NeededFor = getNeededForValue(voliGroupRec);
        this.NeededBy = getNeededByValue(voliGroupRec, vendorOrderHeader);
        
        vrlis.sort();
        this.VendorOrderLineItemList.clear();
        for(VendorReceivingLineItem vrli : vrlis){
            if(vrli.voli != null){
                this.VendorOrderLineItemList.add(voliIdToVOLIRecMap.get(vrli.voli.Id));
            }
            if(vrli.cancelvoli != null){
                this.VendorOrderLineItemList.add(voliIdToVOLIRecMap.get(vrli.cancelvoli.Id));
            }
        }
        this.Need = voliGroupRec.Need__c;
        if(voliGroupRec.Part__c != null) {
            setPartSpecificFields(voliGroupRec);
        } else if(voliGroupRec.Sublet__c != null) {
            setSubletSpecificFields(voliGroupRec);
        }
        
        this.Total = this.Cost * this.OrderValue;
        this.PartId = voliGroupRec.Part__c;
        this.SubletId = voliGroupRec.Sublet__c;
        this.ReceivedQty = voliGroupRec.Received_Qty__c;
        this.Status = getVOLIGroupStatus(VendorOrderLineItemList);
        
        this.UnreceivedQty = this.Need - this.ReceivedQty;
        if(this.UnreceivedQty < 0) {
            this.UnreceivedQty = 0;
        }
        
        if(this.Need > 0 && voliGroupRec.Received_Qty__c != null) {
            this.PercentRecieved = (voliGroupRec.Received_Qty__c / this.Need ) * 100 ;
        } else {
            this.PercentRecieved = 100;
        }
        this.ExpectedDate = BPUtility.getFormatedDateTime(datetime.newInstance(Date.Today().year(), Date.Today().month(),Date.Today().day()));
     
        this.IsBRPPart = voliGroupRec.Part__r != null ? BRPUtility.getAllBRPVendorsIdSet().contains(voliGroupRec.Part__r.Vendor__c): false;
    }
    
    private void setPartSpecificFields(Vendor_Order_Line_Item_Group__c voliGroupRec) {
        this.ItemDesc = voliGroupRec.Part__r.Part_Number__c + ' - ' + voliGroupRec.Part__r.Description__c;
		this.PartNumber = voliGroupRec.Part__r.Part_Number__c;
        this.UnitType = voliGroupRec.Part__r.Package_Unit__c;
        this.OrderType = '';
        this.OrderValue = this.Need;
        if(voliGroupRec.Part__r.Packaged_Part__c) {
            if(voliGroupRec.Part__r.Package_Qty__c == null) {
                voliGroupRec.Part__r.Package_Qty__c = 1;
            }
            this.OrderValue = this.Need / voliGroupRec.Part__r.Package_Qty__c;
            this.OrderType = 'Ordered as ' + voliGroupRec.Part__r.Package_Qty__c + '/' +voliGroupRec.Part__r.Package_Unit__c;
            if(voliGroupRec.Part__r.Order_Lots__c > 1) {
                this.OrderType += ' in Lots of ' + voliGroupRec.Part__r.Order_Lots__c;
            }
            this.Cost = (this.Cost * voliGroupRec.Part__r.Package_Qty__c).setScale(2, RoundingMode.HALF_UP);
        } else if(voliGroupRec.Part__r.Order_Lots__c > 1) {
            this.OrderType += 'Ordered as in Lots of ' + voliGroupRec.Part__r.Order_Lots__c;
        }
        this.AvailablePart = voliGroupRec.Part__r.AvailableParts__c;
    }

    private void setSubletSpecificFields(Vendor_Order_Line_Item_Group__c voliGroupRec) {
    	if(voliGroupRec.Vendor_Order_Line_Items__r.size() > 0) {
	    	this.ItemDesc = (voliGroupRec.Vendor_Order_Line_Items__r[0].Service_Order_Line_Item__r.Item_Code__c != null) ? voliGroupRec.Vendor_Order_Line_Items__r[0].Service_Order_Line_Item__r.Item_Code__c : '';
			this.ItemDesc += (voliGroupRec.Vendor_Order_Line_Items__r[0].Service_Order_Line_Item__r.Item_Description__c != null) ? 
				((this.ItemDesc.length() > 0 ? ' - ' : '' ) + voliGroupRec.Vendor_Order_Line_Items__r[0].Service_Order_Line_Item__r.Item_Description__c) : '';
    	} else {
    		this.ItemDesc = voliGroupRec.Sublet__r.Product_Unique_Name__c;
    	}
    	this.UnitType = '';
    	this.OrderType = '';
    	this.OrderValue = this.Need;
    	this.AvailablePart = 0;
    }
    
    private String getNeededForValue(Vendor_Order_Line_Item_Group__c voliGroupRec) {
        String neededFor;
        if((voliGroupRec.Vendor_Order_Line_Items__r.size() + voliGroupRec.Cancelled_VOLIs__r.size()) == 1) {
            if(voliGroupRec.Vendor_Order_Line_Items__r.size() > 0) {
                if(voliGroupRec.Vendor_Order_Line_Items__r[0].Is_required_For_Customer__c || 
                    voliGroupRec.Vendor_Order_Line_Items__r[0].Is_Service__c) {
                    neededFor = voliGroupRec.Vendor_Order_Line_Items__r[0].CO_Header__r.Name;
                } else {
                    neededFor = 'Stock';
                }
            } else if(voliGroupRec.Cancelled_VOLIs__r.size() > 0) {
                if(voliGroupRec.Cancelled_VOLIs__r[0].Is_required_For_Customer__c || 
                    voliGroupRec.Cancelled_VOLIs__r[0].Is_Service__c) {
                    neededFor = voliGroupRec.Cancelled_VOLIs__r[0].CO_Header__r.Name;
                } else {
                    neededFor = 'Stock';
                }
            }
        } else if((voliGroupRec.Vendor_Order_Line_Items__r.size() + voliGroupRec.Cancelled_VOLIs__r.size()) > 1) {
            neededFor = 'Multiple Sources';
        }
        return neededFor;
    }
    
    private String getNeededByValue(Vendor_Order_Line_Item_Group__c voliGroupRec, VendorOrderHeader vendorOrderHeader) {
        Integer leadTime = 0;
        if(vendorOrderHeader.OrderType != null){
            leadTime = vendorOrderHeader.OrderType.LeadTime;
        }
        String neededBy;
        Map<Id, Vendor_Order_Line_Item__c> voLineItemMap = new Map<Id, Vendor_Order_Line_Item__c>(voliGroupRec.Vendor_Order_Line_Items__r);
        
        if(voliGroupRec.Vendor_Order_Line_Items__r.size() > 1) {
            this.NeededBy = null;
            boolean isExcessRec = false;
            for(VendorOrderLineItem voliRec : VendorOrderLineItemList) {
                if(voliRec.Status != 'Cancelled') {
                    if(!voliRec.IsExcess) {
                        voliRec.NeededBy = BPUtility.getFormatedDateTime(((Vendor_Order_Line_Item__c)(voLineItemMap.get(voliRec.Id))).CreatedDate.addDays(leadTime));
                    } else {
                        isExcessRec = true;
                    }
                }
            }
            if(VendorOrderLineItemList.size() == 2 && isExcessRec) {
                this.NeededBy = BPUtility.getFormatedDateTime(voliGroupRec.CreatedDate.addDays(leadTime));
            }
        } else if(voliGroupRec.Vendor_Order_Line_Items__r.size() == 1){
            if(voliGroupRec.Vendor_Order_Header__r.Purchase_Order_Type__r.Lead_Time__c != null) {
                this.NeededBy = BPUtility.getFormatedDateTime(voliGroupRec.CreatedDate.addDays(Integer.valueOf(voliGroupRec.Vendor_Order_Header__r.Purchase_Order_Type__r.Lead_Time__c)));
            } else {
                this.NeededBy = null;
            }
        }
        return neededBy;
    }
    
    private String getVOLIGroupStatus(List<VendorOrderLineItem> voliList) {
        String status;
        Decimal noOfCancelledItems = 0;
        Decimal noOfStockedItems = 0;
        Decimal noOfInProgressReceivingItems = 0;
        for(VendorOrderLineItem voliObj : voliList) {
            if(voliObj.Status == 'Cancelled') {
                noOfCancelledItems++;
            } else if(voliObj.Status == 'Stocked') {
                noOfStockedItems++;
            } else if(voliObj.Status == 'In Receiving') {
                noOfInProgressReceivingItems++;
            }
        }
        
        if(voliList.size() == noOfCancelledItems) {
            status = 'Cancelled';
        } else if(voliList.size() == (noOfStockedItems + noOfCancelledItems)) {
            status = 'Stocked';
        } else if(noOfInProgressReceivingItems > 0) {
            status = 'In Receiving';
        } else if(noOfStockedItems > 0) {
            status = 'Partially Received';
        } else {
            status = 'On Order';
        }
        return status;
    }
    
    
    // Constructor
    public VendorOrderLineItemGroup(List<Vendor_Order_Line_Item__c> VendorOrderLineItemRecList, Vendor_Order_Line_Item_Group__c voliGroupRec, VendorOrderHeader vendorOrderHeader) {
        Boolean isReqForCustomerOrder = false;
        Boolean isReqForStock = false; 
        
        this.Need = 0;
        this.IsExcess = false;
        if(voliGroupRec.Part__c != null) {
            this.ItemDesc = voliGroupRec.Part__r.Part_Number__c + ' - ' + voliGroupRec.Part__r.Description__c;
            this.PartNumber = voliGroupRec.Part__r.Part_Number__c;
        } else if(voliGroupRec.Sublet__c != null) {
            if(voliGroupRec.Vendor_Order_Line_Items__r.size() > 0) {
		    	this.ItemDesc = (voliGroupRec.Vendor_Order_Line_Items__r[0].Service_Order_Line_Item__r.Item_Code__c != null) ? voliGroupRec.Vendor_Order_Line_Items__r[0].Service_Order_Line_Item__r.Item_Code__c : '';
				this.ItemDesc += (voliGroupRec.Vendor_Order_Line_Items__r[0].Service_Order_Line_Item__r.Item_Description__c != null) ? 
					((itemDesc.length() > 0 ? ' - ' : '' ) + voliGroupRec.Vendor_Order_Line_Items__r[0].Service_Order_Line_Item__r.Item_Description__c) : '';
        	} else {
        		this.ItemDesc = voliGroupRec.Sublet__r.Product_Unique_Name__c;
        	}
        }
        this.VendorOrderLineItemList = new List<VendorOrderLineItem>();
        
        Map<Id, Vendor_Order_Line_Item__c> voLineItemMap = new Map<Id, Vendor_Order_Line_Item__c>(VendorOrderLineItemRecList);
        Set<String> voHeaderNameSet = new Set<String>();
        List<VendorReceivingLineItem> vrlis = new List<VendorReceivingLineItem>();
        Map<Id, VendorOrderLineItem> voliIdToVOLIRecMap = new Map<Id, VendorOrderLineItem>();
        
        for(Vendor_Order_Line_Item__c voliRec : VendorOrderLineItemRecList) {
        	if(voliRec.Sublet__c != null && this.ItemDesc != null && this.ItemDesc.length() == 0) {
        		this.ItemDesc = (voliRec.Service_Order_Line_Item__r.Item_Code__c != null) ? voliRec.Service_Order_Line_Item__r.Item_Code__c : '';
        		this.ItemDesc += (voliRec.Service_Order_Line_Item__r.Item_Description__c != null) ? 
        			((itemDesc.length() > 0 ? ' - ' : '' ) + voliRec.Service_Order_Line_Item__r.Item_Description__c) : '';
        	}
            VendorOrderLineItem voliObj = new VendorOrderLineItem(voliRec);
            this.VendorOrderLineItemList.add(voliObj);
            this.Need += voliRec.Qty_Needed__c;
            voHeaderNameSet.add(voliRec.Vendor_Order_Line_Item_Group__r.Vendor_Order_Header__r.Name);
            if(voliRec.Is_Excess__c) {
                this.IsExcess = true;
            }
            vrlis.add( new VendorReceivingLineItem(voliRec) );
            voliIdToVOLIRecMap.put(voliRec.Id, voliObj);
            
            if(voliObj.IsRequiredForCustomer || voliObj.IsService) {
                isReqForCustomerOrder = true;
            } else {
                isReqForStock = true;
            }
        }
        
        // Sorting Order for VOLIs
        vrlis.sort();
        if(isReqForCustomerOrder) { 
            if(VendorOrderLineItemRecList.size() == 1) {
                this.NeededFor = VendorOrderLineItemRecList[0].CO_Header__r.Name;
            } else if(VendorOrderLineItemRecList.size() > 1) {
                this.NeededFor = 'Multiple Sources';
            }
        } else {
            this.NeededFor = 'Stock';
        }
        
        this.VendorOrderLineItemList.clear();
        for(VendorReceivingLineItem vrli : vrlis){
            this.VendorOrderLineItemList.add(voliIdToVOLIRecMap.get(vrli.voli.Id));
        }
        
        
        if(VendorOrderLineItemRecList.size() > 1) {
            //this.NeededFor = 'Multiple Sources';  // Hardcode
            this.NeededBy = null ;// Hardcode
            
            boolean isExcessRec = false;
            for(VendorOrderLineItem voliRec : VendorOrderLineItemList){
                if( !voliRec.IsExcess ){
                    voliRec.NeededBy = BPUtility.getFormatedDateTime( ((Vendor_Order_Line_Item__c)(voLineItemMap.get(voliRec.Id))).CreatedDate.addDays(vendorOrderHeader.OrderType.LeadTime));
                } else {
                    isExcessRec = true;
                }
            }
            
            if(VendorOrderLineItemList.size() == 2 && isExcessRec){
                this.NeededBy = BPUtility.getFormatedDateTime(voliGroupRec.CreatedDate.addDays(Integer.valueOf(voliGroupRec.Vendor_Order_Header__r.Purchase_Order_Type__r.Lead_Time__c)));
            }
        } else if(VendorOrderLineItemRecList.size() == 1){
            //this.NeededFor = (VendorOrderLineItemRecList[0].CO_Header__r.Name != null) ? 'Merch ' + VendorOrderLineItemRecList[0].CO_Header__r.Name : 'Multiple Sources';  // Hardcode
            if(voliGroupRec.Vendor_Order_Header__r.Purchase_Order_Type__r.Lead_Time__c != null) {
                this.NeededBy = BPUtility.getFormatedDateTime(voliGroupRec.CreatedDate.addDays(Integer.valueOf(voliGroupRec.Vendor_Order_Header__r.Purchase_Order_Type__r.Lead_Time__c)));
            } else {
                this.NeededBy = null;
            }
        }
        
        this.OrderType = '';
        this.OrderValue = this.Need;
        if(voliGroupRec.Part__r.Packaged_Part__c) {
            this.OrderValue = this.Need / voliGroupRec.Part__r.Package_Qty__c;
            this.OrderType = 'Ordered as ' + voliGroupRec.Part__r.Package_Qty__c + '/' +voliGroupRec.Part__r.Package_Unit__c;
            if(voliGroupRec.Part__r.Order_Lots__c > 1) {
                this.OrderType += ' in Lots of ' + voliGroupRec.Part__r.Order_Lots__c;
            }
        } else if(voliGroupRec.Part__r.Order_Lots__c > 1) {
            this.OrderType += 'Ordered as in Lots of ' + voliGroupRec.Part__r.Order_Lots__c;
        }
        
        if(voHeaderNameSet.size() > 1) {
            this.VOHeaderName = 'Multiple Sources';
        } else if(voHeaderNameSet.size() == 1){
            for(String voHeaderName : voHeaderNameSet) {
                this.VOHeaderName = voHeaderName;
            }
        }
        
        this.PartId = voliGroupRec.Part__c;
        this.SubletId = voliGroupRec.Sublet__c;
        this.ReceivedQty = voliGroupRec.Received_Qty__c;
        
        // Added by TK
        if(this.ReceivedQty == this.Need) {
            this.Status = 'Stocked';
        } else if(this.Need > this.ReceivedQty && this.ReceivedQty > 0) {
            this.Status = 'Partially Received';
        } else if(voliGroupRec.Cancelled_VOLIs__r.size() > 0) {
            this.Status = 'Cancelled';
        } else if(this.ReceivedQty == 0) {
            this.Status = 'On Order';
        }
        
        if(this.Need > 0) {
            this.PercentRecieved = (voliGroupRec.Received_Qty__c / this.Need ) * 100 ;
        }
    }
    
    
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> VOLineItemGroupFields = new List<String>{  'Id',
                                                                'Part__c', 
                                                                'Sublet__c',
                                                                'Part__r.Name',
                                                                'Part__r.Part_Number__c',
                                                                'Part__r.Description__c',
                                                                'Part__r.Package_Unit__c',
                                                                'Part__r.Vendor__c',
                                                                'Sublet__r.Product_Unique_Name__c',
                                                                'Need__c',
                                                                'Status__c',
                                                                'CreatedDate',
                                                                'Cost__c',
                                                                'Part__r.Packaged_Part__c',
                                                                'Part__r.Package_Qty__c',
                                                                'Part__r.Order_Lots__c',
                                                                'Part__r.AvailableParts__c',
                                                                'Vendor_Order_Header__r.Purchase_Order_Type__r.Lead_Time__c',
                                                                'Vendor_Order_Header__c',
                                                                'Vendor_Order_Header__r.Name',
                                                                'Unreceived_Qty__c',
                                                                'Received_Qty__c'
                                                };
        return VOLineItemGroupFields;
    }
    
    public static List<VendorOrderLineItemGroup> getPaginatedRecords(List<VendorOrderLineItemGroup> allrecords, Integer currentPage, integer pageSize) {
        List<VendorOrderLineItemGroup> objRecords = new List<VendorOrderLineItemGroup>();
        if(currentPage == null || currentPage == 0){
            currentPage = 1;
        }
        if(pageSize == null || pageSize == 0){
            pageSize = (Integer) General_Configurations__c.getInstance().Related_List_Page_Size__c;
        }
        
        for(Integer i = (currentPage * pageSize - pageSize); i < (currentPage * pageSize); i++){ 
            if(allrecords.size() > i){
                objRecords.add(allrecords.get(i));
            }
        }
        return objRecords;
    }
    
    public Integer compareTo(object compareTo){
        VendorOrderLineItemGroup compareToWrapperObj = ((VendorOrderLineItemGroup)compareTo);
        Integer returnVal = (compareToWrapperObj.ItemDesc < this.ItemDesc) ? 1 : ((compareToWrapperObj.ItemDesc == this.ItemDesc) ? 0 : -1);
        
        String sortMapKey = 'Items';
        if( VendorOrderLineItemWrapper.sortFieldMap != null &&
            VendorOrderLineItemWrapper.sortFieldMap.containsKey(sortMapKey) &&
            VendorOrderLineItemWrapper.sortFieldMap.get(sortMapKey) == 'DESC'){
            returnVal *= -1;
        }
        
        return returnVal;
    }
}