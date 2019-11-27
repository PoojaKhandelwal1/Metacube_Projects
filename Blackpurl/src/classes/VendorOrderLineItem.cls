/**
 * Author: Tarun Khandelwal
 * Since: July 22, 2015
 * Name: VendorOrderLineItem
 * Description: Apex class to handle JSON related oprations of VO Line Item object.
**/
public with sharing class VendorOrderLineItem implements Comparable{
	// Id
	public String Id;
	
	// VO Line Item Key ( Part Name + Part_Id)
    public String Item;
    
    // Qty required by customer
    public String NeededFor;
    
    // Customer 
    public String Customer;
    
    // Needed By - Date
    public String NeededBy;
    
    // Need - Qty Required For Customer
    public Decimal Need;
    
    // CO Line Item price per Qty
    public Decimal Cost;
    
    // Need * Cost
    public Decimal Total;
    
    // Part Id
    public String PartId;
    public String SubletId;
    
    // CO Header Id
    public String CoHeaderId;
    
    // Required for customer
    public Boolean IsRequiredForCustomer;
    
    // Is Service
    public Boolean IsService;
    
    // Item Desc
    public String ItemDesc;
    
    // Part Location
    public String Location;
    
    // Qty Available
    public Decimal QtyAvailable;
    
    // Incoming Qty
    public Decimal Incoming;
    
    // Is excess
    public Boolean IsExcess;
    
    // Is from search to add
    public Boolean IsSearchAdded;
    
    // Vendor Order Header Name
    public String VendorOrderHeaderName;
    
    // Received Qty
    public Decimal ReceivedQty;
    
    // Status
    public String Status;
    public Boolean IsReceivingStockExcess;
    
    // Constructor   
    public VendorOrderLineItem(Vendor_Order_Line_Item__c VendorOrderLineItemRec) { 
        //system.assert(false, VendorOrderLineItemRec);
        // Combination of Part Name + Part Id
        this.Id = VendorOrderLineItemRec.Id;
        if(VendorOrderLineItemRec.Part__c != null) {
        	this.Item = VendorOrderLineItemRec.Part__r.Part_Number__c + ' - ' + VendorOrderLineItemRec.Part__r.Description__c;
        	this.ItemDesc = this.Item;
        } else if(VendorOrderLineItemRec.Sublet__r != null) {
        	String itemDesc = (VendorOrderLineItemRec.Service_Order_Line_Item__r.Item_Code__c != null) ? VendorOrderLineItemRec.Service_Order_Line_Item__r.Item_Code__c : '';
        	itemDesc += (VendorOrderLineItemRec.Service_Order_Line_Item__r.Item_Description__c != null) ? 
        		((itemDesc.length() > 0 ? ' - ' : '' ) + VendorOrderLineItemRec.Service_Order_Line_Item__r.Item_Description__c) : '';
        	this.Item = itemDesc;
        	this.ItemDesc = itemDesc;
        }
        
        this.Location = VendorOrderLineItemRec.Part__r.Location__c;
    	this.QtyAvailable = VendorOrderLineItemRec.Part__r.AvailableParts__c;
    	this.Incoming = VendorOrderLineItemRec.Part__r.Qty_On_Order__c;
        
        if(VendorOrderLineItemRec.Is_required_For_Customer__c || VendorOrderLineItemRec.Is_Service__c) {
        	this.NeededFor = (VendorOrderLineItemRec.CO_Header__r.Name != null) ? 'Merch ' + VendorOrderLineItemRec.CO_Header__r.Name : ''; 
        } else {
        	this.NeededFor = 'Stock';
        }
        if(VendorOrderLineItemRec.CO_Header__r.Customer_Name__c != null) {
        	this.Customer = VendorOrderLineItemRec.CO_Header__r.Customer_Name__c;
        } else {
        	this.Customer = '';
        }
        this.NeededBy = BPUtility.getFormatedDateTime(DateTime.now());  // Hardcode
        this.Need = VendorOrderLineItemRec.Qty_Needed__c;
        this.Cost = VendorOrderLineItemRec.Line_Item_Cost__c;
        //system.assert(false, Cost +  '  ' + Need);
        if(this.Cost == null) {
        	this.Cost = 0;
        }
        this.Total = this.Cost * this.Need;
        this.PartId = VendorOrderLineItemRec.Part__c;
        this.SubletId = VendorOrderLineItemRec.Sublet__c;
        this.CoHeaderId = VendorOrderLineItemRec.CO_Header__c;
        this.IsRequiredForCustomer = (VendorOrderLineItemRec.Is_required_For_Customer__c != null) ? VendorOrderLineItemRec.Is_required_For_Customer__c : false;
        this.IsService = (VendorOrderLineItemRec.Is_Service__c != null) ? VendorOrderLineItemRec.Is_Service__c : false;
        this.IsExcess = VendorOrderLineItemRec.Is_Excess__c;
        this.IsSearchAdded = VendorOrderLineItemRec.Is_From_Search__c;
        if(VendorOrderLineItemRec.Vendor_Order_Line_Item_Group__c != null) {	
        	this.VendorOrderHeaderName = VendorOrderLineItemRec.Vendor_Order_Line_Item_Group__r.Vendor_Order_Header__r.Name;
        } else {
        	this.VendorOrderHeaderName = '';
        }
        this.ReceivedQty = VendorOrderLineItemRec.Received__c;
        /*if(this.ReceivedQty == this.Need && (VendorOrderLineItemRec.Receiving_Status__c == 'Stocked' || 
        										VendorOrderLineItemRec.Receiving_Status__c == 'Invoiced')) {
        	this.Status = 'Stocked';
        } else {
        	this.Status = 'On Order';
        }*/
        this.Status = VendorOrderLineItemRec.Line_Item_Status__c;
    }
    
    
    // Constructor for cancelled VOLI
    public VendorOrderLineItem(Cancelled_VOLI__c canelledVOLIRec) { 
        //system.assert(false, canelledVOLIRec);
        // Combination of Part Name + Part Id
        this.Id = canelledVOLIRec.Id;
    	this.Item = canelledVOLIRec.Part__r.Part_Number__c + ' - ' + canelledVOLIRec.Part__r.Description__c; 
    	this.ItemDesc = canelledVOLIRec.Part__r.Part_Number__c + ' - ' + canelledVOLIRec.Part__r.Description__c;
    	this.Location = canelledVOLIRec.Part__r.Location__c;
    	this.QtyAvailable = canelledVOLIRec.Part__r.AvailableParts__c;
    	this.Incoming = canelledVOLIRec.Part__r.Qty_On_Order__c;
		this.IsRequiredForCustomer = canelledVOLIRec.Is_required_For_Customer__c;
        this.IsService = canelledVOLIRec.Is_Service__c;
        this.IsExcess = canelledVOLIRec.Is_Excess__c;
        
        if(canelledVOLIRec.Is_required_For_Customer__c || canelledVOLIRec.Is_Service__c) {
        	this.NeededFor = (canelledVOLIRec.CO_Header__r.Name != null) ? 'Merch ' + canelledVOLIRec.CO_Header__r.Name : ''; 
        } else {
        	this.NeededFor = 'Stock';
        }
        if(canelledVOLIRec.CO_Header__r.Customer_Name__c != null) {
        	this.Customer = canelledVOLIRec.CO_Header__r.Customer_Name__c;
        } else {
        	this.Customer = '';
        }
        this.NeededBy = BPUtility.getFormatedDateTime(DateTime.now());  // Hardcode
        this.Need = canelledVOLIRec.Qty_Needed__c;
        this.Cost = canelledVOLIRec.Line_Item_Cost__c;
        //system.assert(false, Cost +  '  ' + Need);
        if(this.Cost == null) {
        	this.Cost = 0;
        }
        this.Total = this.Cost * this.Need;
        this.PartId = canelledVOLIRec.Part__c;
        this.CoHeaderId = canelledVOLIRec.CO_Header__c;
        this.IsSearchAdded = canelledVOLIRec.Is_From_Search__c;
        if(canelledVOLIRec.Vendor_Order_Line_Item_Group__c != null) {	
        	this.VendorOrderHeaderName = canelledVOLIRec.Vendor_Order_Line_Item_Group__r.Vendor_Order_Header__r.Name;
        } else {
        	this.VendorOrderHeaderName = '';
        }
        this.ReceivedQty = canelledVOLIRec.Received__c;
        this.Status = 'Cancelled';
    }
    
    // Constructor
    public VendorOrderLineItem(Vendor_Receiving_Stock_Excess__c vrseRec) { 
        this.Need = vrseRec.Received_Qty__c;
        this.VendorOrderHeaderName = vrseRec.OrderName__c;
        this.IsReceivingStockExcess = true;
    }
    
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: VendorOrderLineItem - Class Object
    **/
    public static VendorOrderLineItem parse(String json) {
        return (VendorOrderLineItem) System.JSON.deserialize(json, VendorOrderLineItem.class);
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> VOLineItemFields = new List<String>{ 	'Id',
	                                                        'Part__c',
                                                            'Sublet__c',
                                                            'Service_Order_Line_Item__r.Item_Code__c',
                                                            'Service_Order_Line_Item__r.Item_Description__c',
	                                                        'CO_Header__c',
	                                                        'Part__r.Name',
	                                                        'Part__r.Part_Id__c',
	                                                        'Part__r.Vendor__c',
	                                                        'CO_Header__r.Name',
	                                                        'Qty_Needed__c',
	                                                        'Cost__c',
	                                                        'Line_Item_Cost__c',
	                                                        'Status__c',
	                                                        'Line_Item_Status__c',
	                                                        'Vendor_Order_Header__r.Status__c',
	                                                        'CO_Header__r.Customer__r.Name',
	                                                        'Is_required_For_Customer__c',
	                                                        'Part__r.Description__c',
	                                                        'Part__r.Location__c',
	                                                        'Part__r.Part_Number__c',
	                                                        'Part__r.AvailableParts__c',
	                                                        'Part__r.Auto_reorder_Min__c',
	                                                        'Part__r.Auto_reorder_Max__c',
	                                                        'Part__r.Packaged_Part__c',
	                                                        'Part__r.Package_Qty__c',
	                                                        'Part__r.Package_Unit__c',
	                                                        'Part__r.Qty_On_Order__c',
	                                                        'Is_Excess__c',
	                                                        'Is_From_Search__c',
	                                                        'Is_Service__c',
	                                                        'CreatedDate',
	                                                        'LastModifiedDate',
	                                                        'CO_Line_Item__c',
	                                                        'CO_Line_Item__r.Status__c',
	                                                        'CO_Line_Item__r.VO_Number__c',
	                                                        'CO_Line_Item__r.Expected_Delivery_Date__c',
	                                                        'CO_Line_Item__r.VO_Status__c',
	                                                        'Vendor_Order_Line_Item_Group__c',
	                                                        'Vendor_Order_Line_Item_Group__r.Vendor_Order_Header__r.Name',
	                                                        'Vendor_Order_Header__c',
	                                                        'Vendor_Order_Header__r.Name',
	                                                        'Received__c',
	                                                        'Vendor_Receiving_Group__r.Vendor_Receiving_Header__c',
	                                                        'Vendor_Receiving_Group__r.Cost__c',
	                                                        'Receiving_Status__c', // Added by TK 03/09/2017
	                                                        'CO_Header__r.Customer_Name__c', // Added by richa 08/02/2017
	                                                        'CO_Header__r.Customer__r.Home_Number__c',
	                                                        'CO_Header__r.Customer__r.Formatted_Home_number__c',
	                                                        'CO_Header__r.Customer__r.Mobile__c',
	                                                        'CO_Header__r.Customer__r.Formatted_Mobile_Number__c',
	                                                        'CO_Header__r.Customer__r.Work_Number__c',
	                                                        'CO_Header__r.Customer__r.Formatted_Work_Number__c',
                                                            'Sublet__r.Code__c',
                                                            'Sublet__r.Description__c',
                                                            'Service_Order_Line_Item__r.Expected_Delivery_Date__c'
                                                };
        return VOLineItemFields;
    }
    
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> cancelledVOLIfieldsList(){
        List<String> VOLineItemFields = new List<String>{ 	'Id',
	                                                        'Part__c', 
	                                                        'CO_Header__c',
	                                                        'Part__r.Name',
	                                                        'Part__r.Part_Id__c',
	                                                        'Part__r.Vendor__c',
	                                                        'CO_Header__r.Name',
	                                                        'Qty_Needed__c',
	                                                        'Cost__c',
	                                                        'Line_Item_Cost__c',
	                                                        'Status__c',
	                                                        'Vendor_Order_Header__r.Status__c',
	                                                        'CO_Header__r.Customer__r.Name',
	                                                        'CO_Header__r.Customer_Name__c',
	                                                        'Is_required_For_Customer__c',
	                                                        'Part__r.Description__c',
	                                                        'Part__r.Location__c',
	                                                        'Part__r.Part_Number__c',
	                                                        'Part__r.AvailableParts__c',
	                                                        'Part__r.Auto_reorder_Min__c',
	                                                        'Part__r.Auto_reorder_Max__c',
	                                                        'Part__r.Packaged_Part__c',
	                                                        'Part__r.Package_Qty__c',
	                                                        'Part__r.Package_Unit__c',
	                                                        'Part__r.Qty_On_Order__c',
	                                                        'Is_Excess__c',
	                                                        'Is_From_Search__c',
	                                                        'Is_Service__c',
	                                                        'CreatedDate',
	                                                        'LastModifiedDate',
	                                                        'Vendor_Order_Line_Item_Group__c',
	                                                        'Vendor_Order_Line_Item_Group__r.Vendor_Order_Header__r.Name',
	                                                        'Vendor_Order_Header__c',
	                                                        'Vendor_Order_Header__r.Name',
	                                                        'Received__c',
	                                                        'Vendor_Receiving_Group__r.Vendor_Receiving_Header__c'
                                                };
        return VOLineItemFields;
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> stockExcessFieldsList(){
        List<String> stockExcessFields = new List<String>{ 	'Id',
	                                                        'OrderName__c', 
	                                                        'Received_Qty__c',
	                                                        'Vendor_Order_Line_Item_Group__c'
                                                };
        return stockExcessFields;
    }
    
    public static List<VendorOrderLineItem> getPaginatedRecords(List<VendorOrderLineItem> allrecords, Integer currentPage, integer pageSize) {
    	List<VendorOrderLineItem> objRecords = new List<VendorOrderLineItem>();
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
		VendorOrderLineItem compareToWrapperObj = ((VendorOrderLineItem)compareTo);
    	Integer returnVal = (compareToWrapperObj.Item < this.Item) ? 1 : ((compareToWrapperObj.Item == this.Item) ? 0 : -1);
    	
    	String sortMapKey = (this.IsRequiredForCustomer) ? 'Customers' : 'Stocks';
    	if( VendorOrderLineItemWrapper.sortFieldMap != null &&
    		VendorOrderLineItemWrapper.sortFieldMap.containsKey(sortMapKey) &&
    		VendorOrderLineItemWrapper.sortFieldMap.get(sortMapKey) == 'DESC'){
    		returnVal *= -1;
    	}
    	
    	return returnVal; 
	}
}