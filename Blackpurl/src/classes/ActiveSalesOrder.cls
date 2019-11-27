/**
 * Name: ActiveSalesOrder
 * Description: 
 * 
**/
global with sharing class ActiveSalesOrder {
	// Id
	public String Id;
	
	// Part Id
	public Decimal TotalSalesOrder;
	
	// Part Id
	public Decimal CommittedQty;
	
	// Part Id
	public Decimal OutstandingQty;
	
	// Needed Qty
	public Decimal Qty;
	
	// Vendor Id
	public String CustomerId;
	
	// Customer Order number
	public String CONumber;
	
	// Status
	public String Status;
	
	public decimal TotalOrderValue;
	public decimal TotalDepositValue;
	public decimal TotalPaymentValue;
	
	public decimal DealTotal; // Added by richa 26/01/2017 for retrieving all CO's for a customer
	public decimal ServiceTotal; // Added by richa 26/01/2017 for retrieving all CO's for a customer
	public decimal MerchandiseTotal; // Added by richa 26/01/2017 for retrieving all CO's for a customer
	public String CustomerName;
	// Projected Delivery date
	// public String ProjectedDelivery;
	
	// Constructor
    public ActiveSalesOrder(CO_Header__c ActiveSalesOrder) { 
        this.Id	= ActiveSalesOrder.Id;
        this.CONumber = ActiveSalesOrder.Name;
        this.Status	= ActiveSalesOrder.Status__c;
        this.TotalOrderValue = ActiveSalesOrder.Order_Total__c;
        this.TotalDepositValue = ActiveSalesOrder.Total_Deposit__c;
        this.TotalPaymentValue = ActiveSalesOrder.Total_Payment__c;
        /*
        this.ProjectedDelivery = (ActiveSalesOrder.Expected_Date__c != null) 
        						  ? DateTime.newInstance(ActiveSalesOrder.Expected_Date__c.year(), ActiveSalesOrder.Expected_Date__c.month(), ActiveSalesOrder.Expected_Date__c.day()).format('MMMM d, yyyy') 
        						  : '';
        */
        this.CustomerId = ActiveSalesOrder.Customer__c;
        this.CustomerName = ActiveSalesOrder.Customer_Name__c;
        this.Qty = 0;
        this.TotalSalesOrder = 0;
        this.CommittedQty = 0;
        this.OutstandingQty = 0;
        for(CO_Line_Item__c coli : ActiveSalesOrder.CO_Line_Items__r) {
        	if(coli.Qty__c != null && coli.Price__c != null) {
        		this.TotalSalesOrder += (coli.Qty__c * coli.Price__c);
        	}
        	if(coli.Qty_Committed__c != null) {
        		this.CommittedQty += coli.Qty_Committed__c;
        	}
        	if(coli.Qty_To_Order__c != null) {
        		this.OutstandingQty += coli.Qty_To_Order__c;
        	}
        	if(coli.Qty__c != null) {
        		this.Qty += coli.Qty__c;
        	}
        }

		// Start: Added by richa 26/01/2017 for retrieving all CO's for a customer
        this.DealTotal = (ActiveSalesOrder.Deal_Total__c != null) ? ActiveSalesOrder.Deal_Total__c : 0.00;
        Decimal SOTotal = (ActiveSalesOrder.Total_SO__c != null) ? ActiveSalesOrder.Total_SO__c : 0.00;
        Decimal SOTaxTotal = (ActiveSalesOrder.Total_SO_Tax_Amount__c != null) ? ActiveSalesOrder.Total_SO_Tax_Amount__c : 0.00;
        this.ServiceTotal = (SOTotal + SOTaxTotal).setScale(2, RoundingMode.HALF_UP);
        this.MerchandiseTotal = (ActiveSalesOrder.Total_COLI_Clearfix__c != null) ? ActiveSalesOrder.Total_COLI_Clearfix__c : 0.00;
        // End: Added by richa 26/01/2017 for retrieving all CO's for a customer
    }
    // Constructor by Ankit
    public ActiveSalesOrder(CO_Line_Item__c coLineItemObj,CO_Header__c ActiveSalesOrder) { 
        this.Id	= ActiveSalesOrder.Id;
        this.CONumber =ActiveSalesOrder.Name;
        if(coLineItemObj.Closed_CO_Invoice_link__c != null) {
        	this.Status = 'Invoiced'; 
        } else {
			if((coLineItemObj.Qty__c == coLineItemObj.Qty_Committed__c) || coLineItemObj.Part__r.Non_Inventory_Part__c) {
        		if(coLineItemObj.Oversold_Qty__c != null && coLineItemObj.Oversold_Qty__c > 0){
		       		this.Status = 'Oversold';
	            } else {
        			this.Status = 'In Stock';   
	            }
        	} else if(coLineItemObj.Vendor_Order_Header__c != null) {
        		if(coLineItemObj.Vendor_Order_Header__r.Status__c  == 'Received' && coLineItemObj.Qty__c == coLineItemObj.Qty_Committed__c) {
        			this.Status = 'In Stock'; 
        		} else if(coLineItemObj.Status__c != null) {
        			this.Status = coLineItemObj.Status__c;
        		} 
	        } else if(coLineItemObj.Qty__c < 0) {
	        	this.Status = 'RETURN';
	        } else if(coLineItemObj.Qty__c > coLineItemObj.Qty_Committed__c ){
        		if(coLineItemObj.Status__c != null) {
	            	this.Status = coLineItemObj.Status__c;
	        }
        }
        }
        
        this.CustomerName = ActiveSalesOrder.Customer_Name__c;
        this.TotalOrderValue = ActiveSalesOrder.Order_Total__c;
        this.TotalDepositValue = ActiveSalesOrder.Total_Deposit__c;
        this.TotalPaymentValue = ActiveSalesOrder.Total_Payment__c;
        this.CustomerId = ActiveSalesOrder.Customer__c;
        this.Qty = 0;
        this.TotalSalesOrder = 0;
        this.CommittedQty = 0;
        this.OutstandingQty = 0;
        
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
       	Decimal lineItemPrice = 0.00;
       	if(isTaxIncludingPricing && String.isBlank(coLineItemObj.Deal__c)) {
        	lineItemPrice = (coLineItemObj.Price_When_Tax_Included__c != null) ? (coLineItemObj.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP) : 
												(coLineItemObj.Price__c * (1 + (coLineItemObj.Tax__c != null ? coLineItemObj.Tax__c : 0)/100)).setScale(2, RoundingMode.HALF_UP);
        } else {
            lineItemPrice = coLineItemObj.Price__c.setScale(2, RoundingMode.HALF_UP);
        }
        
        this.TotalSalesOrder += (coLineItemObj.Qty__c * lineItemPrice).setScale(2, RoundingMode.HALF_UP);
           
        if(coLineItemObj.Qty_Committed__c != null) {
        	this.CommittedQty += coLineItemObj.Qty_Committed__c;
        }
        if(coLineItemObj.Qty_To_Order__c != null) {
        	this.OutstandingQty += coLineItemObj.Qty_To_Order__c;
        }
        if(coLineItemObj.Qty__c != null) {
        	this.Qty += coLineItemObj.Qty__c;
    	}
        
    }
    
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: ActiveSalesOrder - Class Object
    **/
    public static List<ActiveSalesOrder> parse(String json) {
        return (List<ActiveSalesOrder>) System.JSON.deserialize(json, List<ActiveSalesOrder>.class);
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getActiveSalesOrderfieldsList(){
        List<String> activeSalesOrderfieldsList = new List<String>{	'Id',
			                                                   		'Name',
				                                                   	'Customer__c',
				                                                   	'Customer_Name__c',
				                                                   	'Status__c',
				                                                   	'Total_Deposit__c',
			                                                        'Order_Total__c',
			                                                        'Total_Payment__c',
			                                                        'Deal_Total__c',
																	'Total_SO__c',
																	'Total_SO_Tax_Amount__c',
																	'Total_COLI_Clearfix__c',
				                                                   	'(Select Name, Qty__c, Deal__c, Price_When_Tax_Included__c, Tax__c, Qty_Committed__c, Closed_CO_Invoice_link__c, Special_Order__c, Qty_To_Order__c, Price__c, Oversold_Qty__c, ' +
				                                                   	'Status__c, Vendor_Order_Header__c, Vendor_Order_Header__r.Status__c, Part__r.Non_Inventory_Part__c from CO_Line_Items__r WHERE Part__c =: partId)'
				                                               	};
        return activeSalesOrderfieldsList;
    }
    
    /**
     * Name: getCOLIFieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getCOLIFieldsList(){
        List<String> colifieldsList = new List<String>{	'Id',
                                                   		'Name',
	                                                   	'Part__c',
	                                                   	'Price__c',
	                                                   	'Status__c',
	                                                   	'CO_Header__c',
	                                                   	'CO_Header__r.Status__c',
	                                                   	'CO_Header__r.Customer__c'
	                                               	};
        return colifieldsList;
    }
    
    /**
     * Name: getAllActiveSalesOrdersForPart
     * Desc: Get all related Active Orders for a part record
     * @param:	(1) partId - String - Part Id for which parts need to retrieved
     * @return: String - JSON format for all the active orders
    **/
    public static List<ActiveSalesOrder> getAllActiveSalesOrdersForPart(Id partId, String pageSortAttrsJSON) {
		RelatedListPaginationSorting pageSortAttrs = ActiveSalesOrder.parsePageAttrs(pageSortAttrsJSON);
		
		Map<String, String> sortFieldMap = new Map<String, String>();
    	if(pageSortAttrs.sorting != null && pageSortAttrs.sorting[0].sortDirection.length() != 0){
    		sortFieldMap.put('Name', pageSortAttrs.sorting[0].sortDirection);
    	}
		
		List<ActiveSalesOrder> activeSalesOrders = new List<ActiveSalesOrder>();
		List<CO_Line_Item__c> coliList = SOQLUtil.getCOLIForPart(partId, null);
		Set<Id> cohIdSet = new Set<Id>();
		for(CO_Line_Item__c coli : coliList) {
			cohIdSet.add(coli.CO_Header__c);
		}
		
		List<CO_Header__c> activeSalesOrdersList = TaxExemption.getPaginatedRecords(SOQLUtil.getPartActiveSalesOrdersForPart(partId, cohIdSet, sortFieldMap),
																					pageSortAttrs.activeSalesOrdersCurrentPage, 
					    															pageSortAttrs.activeSalesOrdersPageSize 
																				);
		/** 
		for(CO_Header__c ActiveSalesOrder : activeSalesOrdersList) {
            activeSalesOrders.add(new ActiveSalesOrder(ActiveSalesOrder));
        }
        **/
        for(CO_Header__c ActiveSalesOrder : activeSalesOrdersList) {
			for(CO_Line_Item__c coLi : ActiveSalesOrder.CO_Line_Items__r){
				activeSalesOrders.add(new ActiveSalesOrder(coLi, ActiveSalesOrder));	
			}
		}
        
		return activeSalesOrders;
    }
    
    /**
     * Name: getTotalActiveOrdersForPart
     * Desc: Get total count for related Active Orders of a part record
     * @param:	(1) partId - String - Part Id for which parts need to retrieved
     * @return: Integer - Total count
    **/
    public static Integer getTotalActiveSalesOrdersForPart(Id partId) {
    	List<CO_Line_Item__c> coliList = SOQLUtil.getCOLIForPart(partId, null);
		Set<Id> cohIdSet = new Set<Id>();
		for(CO_Line_Item__c coli : coliList) {
			if(coli.CO_Header__r.Status__c == 'Open') {
				cohIdSet.add(coli.CO_Header__c);
			}
		}
		return cohIdSet.size();
    }
    
    // Wrapper class to hold taxt exemption record and total tax exemption records in database for a part
    public class ActiveSalesOrderWrapper {
    	// ActiveSalesOrder record
    	public ActiveSalesOrder ActiveSalesOrderRecord;
    	
    	// Total count in database for a part
    	public Integer TotalActiveSalesOrders;
    	
    	// Total count in database for a part
    	public boolean isError;
    	
    	// Total count in database for a part
    	public String ErrorMsg;
    	
    	// Constructor
    	public ActiveSalesOrderWrapper(Id partId){
    		//this.ActiveOrderRecord = new ActiveSalesOrder(ActiveOrderRecord);
    		this.TotalActiveSalesOrders = ActiveSalesOrder.getTotalActiveSalesOrdersForPart(partId);
    		this.isError = false;
    	}
    	
    	// Constructor
    	public ActiveSalesOrderWrapper(String ErrorMsg){
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
    	public Integer activeSalesOrdersCurrentPage;
    	
    	// Current page size
    	public Integer activeSalesOrdersPageSize;
    	
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
}