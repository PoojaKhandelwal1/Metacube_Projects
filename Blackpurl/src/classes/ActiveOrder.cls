/**
 * Author: Ashish Garg
 * Since: Jun 27, 2015
 * Name: ActiveOrder
 * Description: Apex class to handle JSON related oprations of Active Order object.
**/
global with sharing class ActiveOrder implements Comparable{
	// Id
	public String Id;
	
	// Part Id
	public Decimal TotalOrder;
	
	// Part Id
	public Decimal ReceivedOrder;
	
	// Part Id
	public Decimal OutstandingOrder;
	
	// Needed Qty
	public Decimal Qty;
	
	// Vendor Id
	public String VendorId;
	
	// Purchase Order number
	public String PONumber;
	
	// Status
	public String Status;
	
    // Ticket#2366: Added By Pooja 15 Jun 2017
	// VoligStatus
	public String VoligStatus;
    
	// Projected Delivery date
	public String ProjectedDelivery;
	public String OrderType;
	
	
	
	public DateTime CreatedDate;
	// Constructor
    public ActiveOrder(Vendor_Order_Header__c activeOrder) { 
        this.Id	= activeOrder.Id;
        this.PONumber = activeOrder.Name;
        this.ProjectedDelivery = (activeOrder.Expected_Date__c != null) 
        						  ? BPUtility.getExtendedDateFormatWithoutTime(DateTime.newInstance(activeOrder.Expected_Date__c.year(), activeOrder.Expected_Date__c.month(), activeOrder.Expected_Date__c.day())) 
        						  : '';
        						  
   		this.OrderType = 'Vendor Order';
        this.VendorId = activeOrder.Vendor__c;
        this.Qty = 0;
        this.TotalOrder = 0;
        this.ReceivedOrder = 0;
        this.OutstandingOrder = 0;
        for(Vendor_Order_Line_Item_Group__c vog : activeOrder.Vendor_Order_Line_Item_Groups__r) {
        	if(vog.Part__c != null) {
        		vog.Cost__c = vog.Part__r.Last_Cost__c;
        	} else {
        		vog.Cost__c = 0; 
        	}
        	
        	if(vog.Need__c != null && vog.Cost__c != null) {
        		this.TotalOrder += (vog.Need__c * vog.Cost__c);
        	}
        	if(vog.Received_Qty__c != null && vog.Cost__c != null) {
        		this.ReceivedOrder += (vog.Received_Qty__c * vog.Cost__c);
        	}
        	if(vog.Unreceived_Qty__c != null && vog.Cost__c != null) {
        		this.OutstandingOrder += (vog.Unreceived_Qty__c * vog.Cost__c);
        	}
        	if(vog.Need__c != null) {
        		this.Qty += vog.Need__c;
        	}
        	//Commented by Nidhi #1691
        	/*
        	if(vog.Unreceived_Qty__c > 0 && vog.Received_Qty__c == 0) {
        		this.Status	= 'On Order';
        	} else if(vog.Unreceived_Qty__c > 0 && vog.Received_Qty__c > 0) {
        		this.Status	= 'Partially Received';
        	} else {
        		this.Status	= 'Stocked';
        	}*/
            
            // Start: Ticket#2366: Added By Pooja 15 Jun 2017
        	// For Active Vendor Order Of Part there is no use of "Stocked" and "Cancelled" Status
	        if(vog.Need__c > vog.Received_Qty__c && vog.Received_Qty__c > 0) {
	        	this.VoligStatus = 'Partially Received';
	        } else if(vog.Received_Qty__c == 0) {
	        	this.VoligStatus = 'On Order';
	        }
        	// End: Ticket#2366: Added By Pooja 15 Jun 2017
        }
        //Added by Nidhi #1691
        this.Status	= activeOrder.Status__c;
        if(String.isNotBlank(activeOrder.Status__c) && activeOrder.Status__c == 'Cancelled') {
        	this.TotalOrder = 0;
        	this.OutstandingOrder = 0;
        	this.Qty = 0;
        }
        
        this.CreatedDate = activeOrder.CreatedDate;
        
    }
    
    
     public ActiveOrder(Return_VO_Header__c  returnOrder) {
     	
     	this.Id	= returnOrder.Id;
        this.Qty = 0;
        this.PONumber = returnOrder.Name;
        this.OrderType = 'Vendor Return';
        
        for(Return_VO_Line_Item__c returnVOLIRec : returnOrder.Return_VO_Line_Items__r){
        	this.Qty += returnVOLIRec.Return_Qty__c != null ? returnVOLIRec.Return_Qty__c : 0 ;
        }
        this.Qty =  (Qty != 0  ? (-1) * Qty : 0 );
        this.TotalOrder = returnOrder.Total__c != null ? returnOrder.Total__c : 0 ;
        
        this.ProjectedDelivery = (returnOrder.Returned_Date__c != null) 
        						  ? BPUtility.getExtendedDateFormatWithoutTime(DateTime.newInstance(returnOrder.Returned_Date__c.year(), returnOrder.Returned_Date__c.month(), returnOrder.Returned_Date__c.day())) 
        						  : '';
        this.VendorId = returnOrder.Vendor__c;
        this.Status	= returnOrder.Status__c;
        this.VoligStatus = returnOrder.Status__c;
        this.CreatedDate = returnOrder.CreatedDate;
        this.ReceivedOrder = 0;
     	this.OutstandingOrder = returnOrder.Total__c != null ? returnOrder.Total__c : 0 ;
     	
     }
    
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: ActiveOrder - Class Object
    **/
    public static List<ActiveOrder> parse(String json) {
        return (List<ActiveOrder>) System.JSON.deserialize(json, List<ActiveOrder>.class);
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getFieldsListUsedInPart(){
        List<String> fieldsListUsedInPart = new List<String>{	'Id',
		        												'Part__c',
		        												'Vendor_Order_Header__c'
			                                               	};
        return fieldsListUsedInPart;
    }
    
    /**
     * Name: getFieldsListUsedInCOHeader
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getFieldsListUsedInCustomer(){
        List<String> fieldsListUsedInPart = new List<String>{	'Id',
		        												'( Select Vendor_Order_Header__c from Vendor_Order_Line_Items__r )',
		        												'CO_Header__c',
		        												'CO_Header__r.Customer__c'
			                                               	};
        return fieldsListUsedInPart;
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getActiveOrderfieldsList(){
        List<String> activeOrderfieldsList = new List<String>{	'Id',
			                                                   	'(Select Received_Qty__c, Need__c, Unreceived_Qty__c, Part__r.Last_Cost__c, Cost__c from Vendor_Order_Line_Item_Groups__r )',
			                                                   	'Vendor__c',
			                                                   	'Status__c',
			                                                   	'Name',
			                                                   	'Expected_Date__c',
			                                                   	'CreatedDate'
			                                               	};
        return activeOrderfieldsList;
    }
    
     /** Added by Ankit
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getActiveOrderfieldsListNew(){
        List<String> activeOrderfieldsList = new List<String>{	'Id',
			                                                   	'(Select Id, Need__c, Unreceived_Qty__c, Part__r.Last_Cost__c, Received_Qty__c, Cost__c from Vendor_Order_Line_Item_Groups__r where Part__c = : partId)',
			                                                   	'Vendor__c',
			                                                   	'Status__c',
			                                                   	'Name',
			                                                   	'Expected_Date__c',
			                                                   	'CreatedDate'
			                                               	};
        return activeOrderfieldsList;
    }
    
    /**
     * Name: getAllActiveOrdersForPart
     * Desc: Get all related Active Orders for a part record
     * @param:	(1) partId - String - Part Id for which parts need to retrieved
     * @return: String - JSON format for all the active orders
    **/
    public static List<ActiveOrder> getAllActiveOrdersForPart(Id partId, String pageSortAttrsJSON) {
		RelatedListPaginationSorting pageSortAttrs = ActiveOrder.parsePageAttrs(pageSortAttrsJSON);
		
		Map<String, String> sortFieldMap = new Map<String, String>();
    	if(pageSortAttrs.sorting != null && pageSortAttrs.sorting[0].sortDirection.length() != 0){
    		sortFieldMap.put('Name', pageSortAttrs.sorting[0].sortDirection);
    	}
		
		List<ActiveOrder> activeOrders = new List<ActiveOrder>();
		List<Vendor_Order_Line_Item_Group__c> vogList = SOQLUtil.getPartActiveOrderGroupsForPart(partId, null);
		Set<Id> vohIdSet = new Set<Id>();
		for(Vendor_Order_Line_Item_Group__c vog : vogList) {
			vohIdSet.add(vog.Vendor_Order_Header__c);
		}
		
		
		List<Return_VO_Line_Item__c> returnVOLIList = SOQLUtil.getPartActiveReturnOrderForPart(partId, null);
		Set<Id> RVOHIdSet = new Set<Id>();
		for(Return_VO_Line_Item__c rvoli : returnVOLIList) {
			RVOHIdSet.add(rvoli.Return_VO_Header__c);
		}
		
		
		List<Return_VO_Header__c> returnActiveOrdersList = SOQLUtil.getReturnActiveVOHeaderDetail(sortFieldMap,RVOHIdSet, partId);
		List<Vendor_Order_Header__c> activeVendorOrderList = SOQLUtil.getPartActiveOrdersForPart(vohIdSet, sortFieldMap,partId);
		List<sObject> objRecords = new List<sObject>();		
		objRecords.addAll((List<sObject>)returnActiveOrdersList);
		objRecords.addAll((List<sObject>)activeVendorOrderList);
		
		
		List<sObject> activeOrdersList = TaxExemption.getPaginatedRecords(objRecords,
																			pageSortAttrs.activeOrdersCurrentPage, 
			    															pageSortAttrs.activeOrdersPageSize 
																						);
		for(sObject activeOrder : activeOrdersList) {
			if(activeOrder instanceof  Vendor_Order_Header__c){
            	activeOrders.add(new ActiveOrder((Vendor_Order_Header__c)activeOrder));
			}else if(activeOrder instanceof  Return_VO_Header__c){
            	activeOrders.add(new ActiveOrder((Return_VO_Header__c)activeOrder));
			}
            
        }
        activeOrders.sort();
		return activeOrders;
    }
    
    /**
     * Name: getAllActiveOrdersForCOHeader
     * Desc: Get all related Active Orders for a part record
     * @param:	(1) partId - String - Part Id for which parts need to retrieved
     * @return: String - JSON format for all the active orders
    **/
    public static List<ActiveOrder> getAllActiveOrdersForCustomer(Id customerId, String pageSortAttrsJSON) {
		RelatedListPaginationSorting pageSortAttrs;
		if(pageSortAttrsJSON != null) {
			pageSortAttrs = ActiveOrder.parsePageAttrs(pageSortAttrsJSON);
		} else {
			pageSortAttrs = ActiveOrder.parsePageAttrs('{}');
		}
		
		Map<String, String> sortFieldMap = new Map<String, String>();
    	if(pageSortAttrs.sorting != null && pageSortAttrs.sorting[0].sortDirection.length() != 0){
    		sortFieldMap.put('Name', pageSortAttrs.sorting[0].sortDirection);
    	}
		
		List<ActiveOrder> activeOrders = new List<ActiveOrder>();
		List<CO_Line_Item__c> coliList = SOQLUtil.getActiveOrdersForCustomer(customerId, null);
		Set<Id> vohIdSet = new Set<Id>();
		for(CO_Line_Item__c coliRec : coliList) {
			for(Vendor_Order_Line_Item__c voliRec : coliRec.Vendor_Order_Line_Items__r) {
				vohIdSet.add(voliRec.Vendor_Order_Header__c);
			}
		}
		
		List<Vendor_Order_Header__c> activeOrdersList = TaxExemption.getPaginatedRecords(SOQLUtil.getPartActiveOrdersForPart(vohIdSet, sortFieldMap),
																							pageSortAttrs.activeOrdersCurrentPage, 
							    															pageSortAttrs.activeOrdersPageSize 
																						);
		for(Vendor_Order_Header__c activeOrder : activeOrdersList) {
            activeOrders.add(new ActiveOrder(activeOrder));
        }
        
		return activeOrders;
    }
    
    /**
     * Name: getAllActiveOrdersForVendor
     * Desc: Get all related Active Orders for a part record
     * @param:	(1) vendorId - String - vendor Id for which parts need to retrieved
     * @return: String - JSON format for all the active orders
    **/
    public static List<ActiveOrder> getAllActiveOrdersForVendor(Id vendorId, String pageSortAttrsJSON) {
		RelatedListPaginationSorting pageSortAttrs = ActiveOrder.parsePageAttrs(pageSortAttrsJSON);
		
		Map<String, String> sortFieldMap = new Map<String, String>();
    	if(pageSortAttrs.sorting != null && pageSortAttrs.sorting[0].sortDirection.length() != 0){
    		sortFieldMap.put('Vendor_Order_Header__r.createdDate', pageSortAttrs.sorting[0].sortDirection);
    	}
    	
    	
    	Map<String, String> sortFieldMap1 = new Map<String, String>();
    	if(pageSortAttrs.sorting != null && pageSortAttrs.sorting[0].sortDirection.length() != 0){
    		sortFieldMap1.put('Return_VO_Header__r.createdDate', pageSortAttrs.sorting[0].sortDirection);
    	}
    	
    	List<Return_VO_Header__c> returnActiveOrdersList = SOQLUtil.getReturnVendorActiveOrders(vendorId, sortFieldMap1);
		List<Vendor_Order_Header__c> activeVendorOrderList = SOQLUtil.getVendorActiveOrders(vendorId, sortFieldMap);
		List<sObject> objRecords = new List<sObject>();
		objRecords.addAll((List<sObject>)returnActiveOrdersList);
		objRecords.addAll((List<sObject>)activeVendorOrderList);
		
		
		List<ActiveOrder> activeOrders = new List<ActiveOrder>();
		List<Vendor_Order_Header__c> activeOrdersList = TaxExemption.getPaginatedRecords(objRecords,
																							pageSortAttrs.activeOrdersCurrentPage, 
							    															pageSortAttrs.activeOrdersPageSize 
																						);
		for(sObject activeOrder : activeOrdersList) {
			if(activeOrder instanceof  Vendor_Order_Header__c){
            	activeOrders.add(new ActiveOrder((Vendor_Order_Header__c)activeOrder));
			}else if(activeOrder instanceof  Return_VO_Header__c){
            	activeOrders.add(new ActiveOrder((Return_VO_Header__c)activeOrder));
			}
            
        }
        
        activeOrders.sort();
		return activeOrders;
    }
    
    /**
     * Name: getTotalActiveOrdersForPart
     * Desc: Get total count for related Active Orders of a part record
     * @param:	(1) partId - String - Part Id for which parts need to retrieved
     * @return: Integer - Total count
    **/
    public static Integer getTotalActiveOrdersForPart(Id partId) {
    	List<Vendor_Order_Line_Item_Group__c> vogList = SOQLUtil.getPartActiveOrderGroupsForPart(partId, null);
		Set<Id> vohIdSet = new Set<Id>();
		for(Vendor_Order_Line_Item_Group__c vog : vogList) {
			vohIdSet.add(vog.Vendor_Order_Header__c);
		}
		List<Vendor_Order_Header__c> activeOrdersList = SOQLUtil.getPartActiveOrdersForPart(vohIdSet, null);
		
		List<Return_VO_Line_Item__c> returnVOLIList = SOQLUtil.getPartActiveReturnOrderForPart(partId, null);
		Set<Id> RVOHIdSet = new Set<Id>();
		for(Return_VO_Line_Item__c rvoli : returnVOLIList) {
			RVOHIdSet.add(rvoli.Return_VO_Header__c);
		}
		
		
		List<Return_VO_Header__c> returnActiveOrdersList = SOQLUtil.getReturnActiveVOHeaderDetail(null,RVOHIdSet, null);
		
		
		return (activeOrdersList.size() + returnActiveOrdersList.size());
    }
    
    /**
     * Name: getTotalActiveOrdersForVendor
     * Desc: Get total count for related Active Orders of a vendor record
     * @param:	(1) vendorId - String - Vendor Id for which parts need to retrieved
     * @return: Integer - Total count
    **/ 
    public static Integer getTotalActiveOrdersForVendor(Id vendorId) {
		List<Vendor_Order_Header__c> activeOrdersList = SOQLUtil.getVendorActiveOrders(vendorId, null);
		List<Return_VO_Header__c> returnActiveOrdersList = SOQLUtil.getReturnVendorActiveOrders(vendorId, null);
		return (activeOrdersList.size() + returnActiveOrdersList.size());
    }
    
    // Wrapper class to hold taxt exemption record and total tax exemption records in database for a part
    public class ActiveOrderWrapper {
    	// ActiveOrder record
    	public ActiveOrder ActiveOrderRecord;
    	
    	// Total count in database for a part
    	public Integer TotalActiveOrders;
    	
    	// Total count in database for a part
    	public boolean isError;
    	
    	// Total count in database for a part
    	public String ErrorMsg;
    	
    	// Constructor
    	public ActiveOrderWrapper(Vendor_Order_Line_Item_Group__c ActiveOrderRecord, Id partId){
    		//this.ActiveOrderRecord = new ActiveOrder(ActiveOrderRecord);
    		this.TotalActiveOrders = ActiveOrder.getTotalActiveOrdersForPart(partId);
    		this.isError = false;
    	}
    	
    	// Constructor
    	public ActiveOrderWrapper(Vendor_Order_Line_Item_Group__c ActiveOrderRecord, Id vendorId, boolean isVendor){
    		//this.ActiveOrderRecord = new ActiveOrder(ActiveOrderRecord);
    		this.TotalActiveOrders = ActiveOrder.getTotalActiveOrdersForVendor(vendorId);
    		this.isError = false;
    	}
    	
    	// Constructor
    	public ActiveOrderWrapper(String ErrorMsg){
    		this.isError = true;
    		this.ErrorMsg = ErrorMsg;
    	}
    }
    
    /**
     * Name: parsePageAttrs
     * Desc: Method to Parse JSON String to class instance for Pagination and sort attributes
     * @param:  (1) JSONString - String - JSON String 
     * @return: RelatedListPaginationSorting - Class Object
    **/
    public static RelatedListPaginationSorting parsePageAttrs(String json) {
        return (RelatedListPaginationSorting) System.JSON.deserialize(json, RelatedListPaginationSorting.class);
    }
    
    // Wrapper class for related list pagination and sorting combination
    public class RelatedListPaginationSorting {
    	// Current page number
    	public Integer activeOrdersCurrentPage;
    	
    	// Current page size
    	public Integer activeOrdersPageSize;
    	
    	// Sorting list
    	public List<SortAttrs> sorting;
    }
    
    // SortAttrs for sorting attributes
    public class SortAttrs {
    	// Field name
    	public String fieldName;
    	
    	// Sort direction
    	public String sortDirection;
    }
    
    public Integer compareTo(Object compareToObj) {
    	ActiveOrder compareToWrapper = (ActiveOrder)compareToObj;
    	 //system.assert(false, compareToWrapper +' '+ this.CreatedDate + ' '+ this.PONumber);
    	if(this.CreatedDate < compareToWrapper.CreatedDate){
    		system.debug(this.PONumber +' '+ this.CreatedDate +' new vale '+ compareToWrapper.PONumber +' '+compareToWrapper.CreatedDate + ' return value 1');
    		return 1;
    	} else if(this.CreatedDate == compareToWrapper.CreatedDate){
    		system.debug(this.PONumber +' '+ this.CreatedDate +' new vale '+ compareToWrapper.PONumber +' '+compareToWrapper.CreatedDate + ' return value 0');
    		return 0;
    	}
    	
    	 system.debug(this.PONumber +' '+ this.CreatedDate +' new vale '+ compareToWrapper.PONumber +' '+compareToWrapper.CreatedDate + ' return value -1')	;	 
       return -1;  
    }
}